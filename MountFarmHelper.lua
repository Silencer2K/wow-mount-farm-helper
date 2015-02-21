local addonName, addon = ...

LibStub('AceAddon-3.0'):NewAddon(addon, addonName, 'AceEvent-3.0')

local L = LibStub('AceLocale-3.0'):GetLocale(addonName)
local LBB = LibStub('LibBabble-Boss-3.0'):GetUnstrictLookupTable()

local qtip = LibStub('LibQTip-1.0')

local TOOLTIP_SEPARATOR = { 1, 1, 1, 1, 0.5 }

local COLOR_DUNGEON = { 1, 1, 0, 1 }
local COLOR_COMMENT = { 0, 1, 0, 1 }

function tableIsEmpty(table)
    for _ in pairs(table) do
        return false
    end
    return true
end

function tableLength(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

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
        OnClick = function()
        end,
    })

    self.icon = LibStub('LibDBIcon-1.0')
    self.icon:Register(addonName, self.ldb, self.db.profile.minimap)

    if not MountJournal_OnLoad then
        UIParentLoadAddOn('Blizzard_PetJournal')
    end

    local mountId, mountData
    for mountId, mountData in pairs(MFH_DB_MOUNTS) do
        GetItemInfo(mountId)
        local mountSource

        for _, mountSource in pairs(mountData.from) do
            if mountData.npc_id then
                self:GetNpcName(mountData.npc_id)
            end
        end
    end
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
        npcName = MFH_DB_NPC_NAMES[npcId]
        if not npcName then
            npcName = string.format('npc#%d', npcId)
        else
            npcName = LBB[npcName] or npcName
        end
    end

    return npcName
end

function addon:UpdateTooltip(anchor)
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

function addon:UpdateTooltipData(tooltip)
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
            if numBosses > 0 then
                savedRaids[raidName] = {}

                for j = 1, numBosses do
                    local bossName, _, killed = GetSavedInstanceEncounterInfo(i, j)
                    if killed then
                        savedRaids[raidName][bossName] = 1
                    end
                end
            else
                savedRaids[raidName] = 1
            end
        end
    end

    local playerFaction = string.lower(UnitFactionGroup('player'))
    local playerLevel = UnitLevel('player')

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

                        local raidSave = mountSource.raid_save and LBB[mountSource.raid_save] or npcName

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
                            add = not(savedRaids[zoneName] and (type(savedRaids[zoneName]) ~= 'table' or savedRaids[zoneName][raidSave]))
                        elseif mountSource.quest_id then
                            add = not IsQuestFlaggedCompleted(mountSource.quest_id)
                        end

                        if add then
                            local zoneData
                            if mountSource.type == 'dungeon' and not mountSource.subtype then
                                zoneData = normalMounts[zoneName] or { items = {}, sort = mountSource.for_sort }
                                normalMounts[zoneName] = zoneData
                            elseif mountSource.type == 'dungeon' or mountSource.type == 'raid' then
                                zoneData = raidMounts[zoneName] or { items = {}, sort = mountSource.for_sort }
                                raidMounts[zoneName] = zoneData
                            elseif mountSource.type == 'world' then
                                zoneData = worldMounts[zoneName] or { items = {}, sort = mountSource.for_sort }
                                worldMounts[zoneName] = zoneData
                            else
                                zoneData = questMounts[zoneName] or { items = {}, sort = mountSource.for_sort }
                                questMounts[zoneName] = zoneData
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

    local lineNo = tooltip:AddHeader();
    tooltip:SetCell(lineNo, 1, L.title, nil, nil, 4)

    local mountTable
    for _, mountTable in pairs({
        { items = normalMounts, title = 'normal' },
        { items = raidMounts, title = 'raid' },
        { items = worldMounts, title = 'world' },
        { items = questMounts, title = 'quest' },
    }) do
        if not tableIsEmpty(mountTable.items) then
            tooltip:AddSeparator(unpack(TOOLTIP_SEPARATOR))

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
                    return mountTable.items[a].sort < mountTable.items[b].sort
                end)

                for _, firstName in pairs(firstSorted) do
                    local firstData = mountTable.items[firstName]

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
                            tooltip:SetCellTextColor(lineNo, 1, unpack(COLOR_DUNGEON))
                        else
                            if not titlePrinted then
                                lineNo = tooltip:AddLine()

                                tooltip:SetCell(lineNo, 1, firstName, nil, nil, 4)
                                tooltip:SetCellTextColor(lineNo, 1, unpack(COLOR_DUNGEON))

                                titlePrinted = 1
                            end

                            lineNo = tooltip:AddLine()

                            tooltip:SetCell(lineNo, 2, secondName, nil, nil, 3)
                            tooltip:SetCellTextColor(lineNo, 2, unpack(COLOR_DUNGEON))
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
    if not PetJournalParent:IsShown() then
        TogglePetJournal()
    end

    PetJournalParent_SetTab(PetJournalParent, 1)

    if index then
        MountJournal_Select(index)
    end
end
