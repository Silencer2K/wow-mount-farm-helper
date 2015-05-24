local addonName, addon = ...

LibStub('AceAddon-3.0'):NewAddon(addon, addonName, 'AceEvent-3.0', 'AceTimer-3.0')

local L = LibStub('AceLocale-3.0'):GetLocale(addonName)
local LBB = LibStub('LibBabble-Boss-3.0'):GetUnstrictLookupTable()
local LBZ = LibStub('LibBabble-SubZone-3.0'):GetUnstrictLookupTable()

local qtip = LibStub('LibQTip-1.0')
local S2K = LibStub('S2KTools-1.0')

local TOOLTIP_SEPARATOR     = { 1, 1, 1, 1, 0.5 }

local COLOR_DUNGEON         = { 1, 1, 0, 1 }
local COLOR_CURRENT_ZONE    = { 0, 1, 0, 1 }
local COLOR_COMMENT         = { 0, 1, 0, 1 }

local COLOR_ITEM_TOOLTIP            = { 1, 1, 1 }
local COLOR_ITEM_TOOLTIP_SOURCE     = { 1, 1, 0 }
local COLOR_ITEM_TOOLTIP_SOURCE_2L  = { 1, 1, 0, 0, 1, 0 }

function addon:OnInitialize()
    self.db = LibStub('AceDB-3.0'):New(addonName .. 'DB', {
        profile = {
            hide_normal = false,
            hide_raid = false,
            hide_world = false,
            hide_quest = false,

            minimap = {
                hide = false,
            },
        },
    }, true)

    self.ldb = LibStub('LibDataBroker-1.1'):NewDataObject(addonName, {
        type = 'launcher',
        icon = 'Interface\\ICONS\\ABILITY_MOUNT_GOLDENGRYPHON',
        label = "Mount Farm Helper",
        OnEnter = function(...)
            self:UpdateTooltip(...)
        end,
        OnLeave = function()
        end,
        OnClick = function(obj, button)
            if button == 'RightButton' then
                InterfaceOptionsFrame_OpenToCategory(addonName)
            elseif self.ac then
                if AltCraftFrame:IsShown() and AltCraftMFHTabFrame:IsShown() then
                    AltCraftFrame:Hide()
                else
                    AltCraftFrame:Show()
                    AltCraftFrame:OnSelectTab(self.acTabNum)
                end
            end
        end,
    })

    self.icon = LibStub('LibDBIcon-1.0')
    self.icon:Register(addonName, self.ldb, self.db.profile.minimap)

    self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED', function(...)
        addon:OnCombatEvent(...)
    end)

    GameTooltip:HookScript('OnTooltipCleared', function(self)
        addon:OnGameTooltipCleared(self)
    end)

    GameTooltip:HookScript('OnTooltipSetItem', function(self)
        addon:OnGameTooltipSetItem(self)
    end)

    LibStub('AceConfig-3.0'):RegisterOptionsTable(addonName, self:GetOptions())
    LibStub('AceConfigDialog-3.0'):AddToBlizOptions(addonName, addonName, nil)

    if not MountJournal_OnLoad then
        UIParentLoadAddOn('Blizzard_Collections')
    end

    self.trackNpc = {}

    local mountId, mountData
    for mountId, mountData in pairs(MFH_DB_MOUNTS) do
        GetItemInfo(mountId)
        local mountSource

        for _, mountSource in pairs(mountData.from) do
            if mountSource.npc_id then
                self:GetNpcName(mountSource.npc_id)

                if mountSource.type == 'raid' or (mountSource.type == 'dungeon' and mountSource.subtype) and not mountSource.dont_autoupdate then
                    self.trackNpc[mountSource.npc_id] = 1
                end
            end
        end
    end

    self:ScheduleTimer(function()
        self.ac = LibStub('AceAddon-3.0'):GetAddon('AltCraft', true)
        if self.ac then
            self.acTabNum = AltCraftFrame:AddTab(AltCraftMFHTabFrame, 'Mount Farm Helper')
        end
    end, 0.5)
end

function addon:GetNpcName(npcId)
    local tooltip = self.scanTooltip

    if not tooltip then
        tooltip = CreateFrame('GameTooltip', 'MFH_SCAN_TOOLTIP', UIParent, 'GameTooltipTemplate')
        self.scanTooltip = tooltip
    end

    tooltip:SetOwner(UIParent, 'ANCHOR_NONE')
    tooltip:SetHyperlink(string.format('unit:Creature-0-0-0-0-%d:0000000000', npcId))

    local npcName = _G[tooltip:GetName() .. 'TextLeft1']:GetText()

    if not npcName then
        if MFH_DB_BOSSES[npcId] and MFH_DB_BOSSES[npcId].name then
            npcName = LBB[MFH_DB_BOSSES[npcId].name] or MFH_DB_BOSSES[npcId].name
        else
            npcName = string.format('npc#%d', npcId)
        end
    end

    return npcName
end

function addon:OnCombatEvent(event, timeStamp, logEvent, hideCaster,
    sourceGuid, sourceName, sourceFlags, sourceFlags2,
    destGuid, destName, destFlags, destFlags2, ...
)
    if destGuid then
        local type, id = S2K:UnitInfoFromGuid(destGuid)

        if type == 'Creature' or type == 'Vehicle' then
            if (logEvent == 'UNIT_DIED' or logEvent == 'PARTY_KILL') and self.trackNpc[id] then
                RequestRaidInfo()

                self:ScheduleTimer(function()
                    RequestRaidInfo()
                end, 5)
            end
        end
    end
end

function addon:UpdateTooltip(anchor)
    if not InCombatLockdown() then
        if qtip:IsAcquired('MountFarmHelper') and self.tooltip then
            self.tooltip:Clear()
        else
            self.tooltip = qtip:Acquire('MountFarmHelper', 5, 'LEFT', 'LEFT', 'LEFT', 'RIGHT')
        end

        self:UpdateTooltipData(self.tooltip)

        if anchor then
            self.tooltip:SmartAnchorTo(anchor)
            self.tooltip:SetAutoHideDelay(0.05, anchor)
        end

        self.tooltip:UpdateScrolling()
        self.tooltip:Show()
    end
end

function addon:BuildTooltipData()
    local i, j

    local mountIndexes, playerMounts = {}, {}
    for i = 1, C_MountJournal.GetNumMounts() do
        local _, spellId, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfo(i)

        mountIndexes[spellId] = i

        if isCollected then
            playerMounts[spellId] = 1
        end
    end

    local savedRaids = {}
    for i = 1, GetNumSavedInstances() do
        local raidName, _, _, _, locked, extended, _, _, _, _, numBosses = GetSavedInstanceInfo(i)
        if locked and not extended then
            savedRaids[raidName] = {}

            local numRemains = 0

            for j = 1, numBosses do
                local bossName, _, killed = GetSavedInstanceEncounterInfo(i, j)
                if killed then
                    savedRaids[raidName][bossName] = 1
                else
                    numRemains = numRemains + 1
                end
            end

            if numRemains < 1 then
                savedRaids[raidName] = 1
            end
        end
    end

    local playerFaction = string.lower(UnitFactionGroup('player'))
    local playerLevel = UnitLevel('player')
    local playerZoneName = GetRealZoneText()

    local normalMounts, raidMounts, worldMounts, questMounts = {}, {}, {}, {}

    local mountId, mountData
    for mountId, mountData in pairs(MFH_DB_MOUNTS) do
        if not playerMounts[mountData.spell_id] and (not mountData.faction or mountData.faction == playerFaction) then
            local mountName, mountLink = GetItemInfo(mountId)

            local mountSource
            for _, mountSource in pairs(mountData.from) do
                if not mountSource.faction or mountSource.faction == playerFaction then
                    if mountSource.level <= playerLevel then
                        local zoneName = GetMapNameByID(mountSource.zone_id)

                        local npcName
                        if mountSource.type == 'special' then
                            npcName = L['special_' .. mountSource.subtype]
                        else
                            npcName = self:GetNpcName(mountSource.npc_id)
                        end

                        local raidSaveZone = MFH_DB_ZONES[mountSource.zone_id] and MFH_DB_ZONES[mountSource.zone_id].raid and LBZ[MFH_DB_ZONES[mountSource.zone_id].raid] or zoneName
                        local raidSaveBoss = MFH_DB_BOSSES[mountSource.npc_id] and MFH_DB_BOSSES[mountSource.npc_id].raid and LBB[MFH_DB_BOSSES[mountSource.npc_id].raid] or npcName

                        local comment
                        if mountSource.subtype and mountSource.type ~= 'special' then
                            comment = L['type_' .. mountSource.subtype]
                        end
                        if mountSource.cond then
                            comment = (comment and (comment .. ' + ') or '') .. L['cond_' .. mountSource.cond]
                        end

                        local add
                        if mountSource.type == 'dungeon' and not mountSource.subtype then
                            add = 1
                        elseif mountSource.type == 'dungeon' or mountSource.type == 'raid' then
                            add = not(savedRaids[raidSaveZone] and (type(savedRaids[raidSaveZone]) ~= 'table' or savedRaids[raidSaveZone][raidSaveBoss]))
                        elseif mountSource.quest_id then
                            add = not IsQuestFlaggedCompleted(mountSource.quest_id)
                        end

                        if add then
                            local zoneData = {
                                items = {}, sort = mountSource.for_sort,
                                isCurrent = playerZoneName == (MFH_DB_ZONES[mountSource.zone_id] and MFH_DB_ZONES[mountSource.zone_id].map and LBZ[MFH_DB_ZONES[mountSource.zone_id].map] or zoneName),
                            }

                            if mountSource.type == 'dungeon' and not mountSource.subtype then
                                if normalMounts[zoneName] then
                                    zoneData = normalMounts[zoneName]
                                else
                                    normalMounts[zoneName] = zoneData
                                end
                            elseif mountSource.type == 'dungeon' or mountSource.type == 'raid' then
                                if raidMounts[zoneName] then
                                    zoneData = raidMounts[zoneName]
                                else
                                    raidMounts[zoneName] = zoneData
                                end
                            elseif mountSource.type == 'world' then
                                if worldMounts[zoneName] then
                                    zoneData = worldMounts[zoneName]
                                else
                                    worldMounts[zoneName] = zoneData
                                end
                            else
                                if questMounts[zoneName] then
                                    zoneData = questMounts[zoneName]
                                else
                                    questMounts[zoneName] = zoneData
                                end
                            end

                            zoneData.sort = min(zoneData.sort, mountSource.for_sort)

                            local npcData = zoneData.items[npcName] or { items = {}, sort = mountSource.for_sort }
                            zoneData.items[npcName] = npcData

                            npcData.sort = min(zoneData.sort, mountSource.for_sort)

                            table.insert(npcData.items, { link = mountLink, mountIndex = mountIndexes[mountData.spell_id], comment = comment })
                        end
                    end
                end
            end
        end
    end

    return {
        { items = normalMounts, title = 'normal' },
        { items = raidMounts  , title = 'raid'   },
        { items = worldMounts , title = 'world'  },
        { items = questMounts , title = 'quest'  },
    }
end

function addon:BuildAltCraftList()
    local list, added = {}, {}

    local itemId, data
    for itemId, data in pairs(MFH_DB_MOUNTS) do
        local name, link, icon = unpackByIndex({ GetItemInfo(itemId) }, 1, 2, 10 )

        local source
        for _, source in pairs(data.from) do
            local zoneName = GetMapNameByID(source.zone_id)

            local npcName
            if source.type == 'special' then
                npcName = L['special_' .. source.subtype]
            else
                npcName = self:GetNpcName(source.npc_id)
            end

            local comment
            if source.subtype and source.type ~= 'special' then
                comment = L['type_' .. source.subtype]
            end
            if source.cond then
                comment = (comment and (comment .. ' + ') or '') .. L['cond_' .. source.cond]
            end

            if added[itemId] then
                table.insert(added[itemId].sources, {
                    zone    = zoneName,
                    source  = npcName,
                    comment = comment,
                    sort    = source.for_sort,
                })

                table.sort(added[itemId].sources, function(a, b) return a.sort < b.sort end)

                added[itemId].sort = added[itemId].sources[1].sort
            else
                added[itemId] = {
                    itemId  = itemId,
                    name    = name,
                    link    = link,
                    icon    = icon,
                    sort    = source.for_sort,
                    sources = {{
                        zone    = zoneName,
                        source  = npcName,
                        comment = comment,
                        sort    = source.for_sort,
                    }},
                }

                table.insert(list, added[itemId])
            end
        end
    end

    table.sort(list, function(a, b) return a.sort < b.sort end)

    return list
end

function addon:UpdateTooltipData(tooltip)
    local lineNo, mountTable

    local zoneName = GetRealZoneText()

    for _, mountTable in pairs(self:BuildTooltipData()) do
        if not tableIsEmpty(mountTable.items) then
            if lineNo then
                tooltip:AddSeparator(unpack(TOOLTIP_SEPARATOR))
            end

            if self.db.profile['hide_' .. mountTable.title] then
                lineNo = tooltip:AddLine()
                tooltip:SetCell(lineNo, 1, '|TInterface\\Buttons\\UI-PlusButton-Up:16|t' .. L['title_' .. mountTable.title], nil, nil, 4)

                tooltip:SetLineScript(lineNo, 'OnMouseUp', function()
                    self.db.profile['hide_' .. mountTable.title] = false
                    self:UpdateTooltip()
                end)
            else
                lineNo = tooltip:AddLine()
                tooltip:SetCell(lineNo, 1, '|TInterface\\Buttons\\UI-MinusButton-Up:16|t' .. L['title_' .. mountTable.title], nil, nil, 4)

                tooltip:SetLineScript(lineNo, 'OnMouseUp', function()
                    self.db.profile['hide_' .. mountTable.title] = true
                    self:UpdateTooltip()
                end)

                local firstSorted, firstName = {}

                for firstName in pairs(mountTable.items) do
                    table.insert(firstSorted, firstName)
                end

                table.sort(firstSorted, function(a, b)
                    if mountTable.items[a].isCurrent then
                        if mountTable.items[b].isCurrent then
                            return mountTable.items[a].sort < mountTable.items[b].sort
                        end
                        return true
                    end
                    if mountTable.items[b].isCurrent then
                        return false
                    end
                    return mountTable.items[a].sort < mountTable.items[b].sort
                end)

                for _, firstName in pairs(firstSorted) do
                    local firstData = mountTable.items[firstName]
                    local zoneColor = firstName == zoneName and COLOR_CURRENT_ZONE or COLOR_DUNGEON

                    local secondSorted, secondName, titlePrinted = {}

                    for secondName in pairs(firstData.items) do
                        table.insert(secondSorted, secondName)
                    end

                    table.sort(secondSorted, function(a, b)
                        return firstData.items[a].sort < firstData.items[b].sort
                    end)

                    for _, secondName in pairs(secondSorted) do
                        local secondData = firstData.items[secondName]

                        if tableLength(firstData.items) == 1 then
                            lineNo = tooltip:AddLine()

                            tooltip:SetCell(lineNo, 1, string.format('%s / %s', firstName, secondName), nil, nil, 4)
                            tooltip:SetCellTextColor(lineNo, 1, unpack(zoneColor))
                        else
                            if not titlePrinted then
                                lineNo = tooltip:AddLine()

                                tooltip:SetCell(lineNo, 1, firstName, nil, nil, 4)
                                tooltip:SetCellTextColor(lineNo, 1, unpack(zoneColor))

                                titlePrinted = 1
                            end

                            lineNo = tooltip:AddLine()

                            tooltip:SetCell(lineNo, 2, secondName, nil, nil, 3)
                            tooltip:SetCellTextColor(lineNo, 2, unpack(zoneColor))
                        end

                        local mountData
                        for _, mountData in pairs(secondData.items) do
                            lineNo = tooltip:AddLine()

                            if mountData.comment then
                                tooltip:SetCell(lineNo, 3, mountData.link:gsub('%[', ''):gsub('%]', ''))

                                tooltip:SetCell(lineNo, 4, mountData.comment)
                                tooltip:SetCellTextColor(lineNo, 4, unpack(COLOR_COMMENT))
                            else
                                tooltip:SetCell(lineNo, 3, mountData.link:gsub('%[', ''):gsub('%]', ''), nil, nil, 2)
                            end

                            if mountData.mountIndex then
                                tooltip:SetLineScript(lineNo, 'OnMouseUp', function()
                                    self:OpenMountJournal(mountData.mountIndex)
                                end)
                            end
                        end
                    end
                end
            end
        end
    end

    tooltip:AddLine()
end

function addon:OpenMountJournal(index)
    if not CollectionsJournal:IsShown() then
        ToggleCollectionsJournal()
    end

    CollectionsJournal_SetTab(CollectionsJournal, 1)

    if index then
        MountJournal_Select(index)
    end
end

function addon:OnGameTooltipCleared(tooltip)
end

function addon:OnGameTooltipSetItem(tooltip)
    local link = select(2, tooltip:GetItem())

    if link then
        local itemId = 0 + (link:match('|Hitem:(%d+):') or 0)

        if MFH_DB_MOUNTS[itemId] then
            tooltip:AddLine(' ')
            tooltip:AddLine(string.format('%s:', L.tooltip_source), unpack(COLOR_ITEM_TOOLTIP))

            local source
            for _, source in pairs(MFH_DB_MOUNTS[itemId].from) do
                local zoneName = GetMapNameByID(source.zone_id)

                local npcName
                if source.type == 'special' then
                    npcName = L['special_' .. source.subtype]
                else
                    npcName = self:GetNpcName(source.npc_id)
                end

                local comment
                if source.subtype and source.type ~= 'special' then
                    comment = L['type_' .. source.subtype]
                end
                if source.cond then
                    comment = (comment and (comment .. ' + ') or '') .. L['cond_' .. source.cond]
                end

                if comment then
                    tooltip:AddDoubleLine(string.format('%s / %s', zoneName, npcName), comment, unpack(COLOR_ITEM_TOOLTIP_SOURCE_2L))
                else
                    tooltip:AddLine(string.format('%s / %s', zoneName, npcName, unpack(COLOR_ITEM_TOOLTIP_SOURCE)))
                end
            end
        end
    end
end
