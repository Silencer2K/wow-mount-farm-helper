local addonName, addon = ...

LibStub('AceAddon-3.0'):NewAddon(addon, addonName, 'AceEvent-3.0')

local L = LibStub('AceLocale-3.0'):GetLocale(addonName)
local LBB = LibStub('LibBabble-Boss-3.0'):GetUnstrictLookupTable()

local EMPTY_LINE = ' '

local COLOR_WHITE = { 1, 1, 1 }

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
            minimap = {
                hide = false,
            },
        },
    }, true)

    self.ldb = LibStub('LibDataBroker-1.1'):NewDataObject(addonName, {
        type = 'launcher',
        text = "Mount Farm Helper",
        icon = 'Interface\\ICONS\\ABILITY_MOUNT_GOLDENGRYPHON',
        OnTooltipShow = function(tooltip)
            self.tooltip = tooltip
            self:UpdateTooltip(tooltip)
        end,
    })

    self.icon = LibStub('LibDBIcon-1.0')
    self.icon:Register(addonName, self.ldb, self.db.profile.minimap)

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

    return _G[tooltip:GetName() .. 'TextLeft1']:GetText()
end

function addon:UpdateTooltip(tooltip)
    local i, j

    local playerMounts = {}
    for i = 1, C_MountJournal.GetNumMounts() do
        local _, spellId, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfo(i)
        if isCollected then
            playerMounts[spellId] = 1
        end
    end

    local savedRaids = {}
    for i = 1, GetNumSavedInstances() do
        local raidName, _, _, _, locked, extended, _, _, _, _, numBosses = GetSavedInstanceInfo(i)
        if locked and not extended then
            savedRaids[raidName] = {}

            for j = 1, numBosses do
                local bossName, _, killed = GetSavedInstanceEncounterInfo(i, j)
                if killed then
                    savedRaids[raidName][bossName] = 1
                end
            end
        end
    end

    local playerFaction = string.lower(UnitFactionGroup('player'))
    local playerLevel = UnitLevel('player')

    local raidMounts, worldMounts = {}, {}

    local mountId, mountData
    for mountId, mountData in pairs(MFH_DB_MOUNTS) do
        if not playerMounts[mountData.spell_id] and (not mountData.faction or mountData.faction == playerFaction) then
            local mountName, mountLink = GetItemInfo(mountId)

            local mountSource
            for _, mountSource in pairs(mountData.from) do
                if mountSource.level <= playerLevel then
                    if mountSource.type == 'dungeon' or mountSource.type == 'raid' or mountSource.type == 'world' then
                        local zoneName = GetMapNameByID(mountSource.zone_id)
                        local npcName = self:GetNpcName(mountSource.npc_id)
                        local raidSave = mountSource.raid_save and LBB[mountSource.raid_save] or npcName

                        local add
                        if mountSource.type == 'world' then
                            add = IsQuestFlaggedCompleted(mountSource.quest_id)
                        elseif mountSource.type == 'dungeon' and not mountSource.subtype then
                            add = not self.db.profile.hide_normal
                        else
                            add = not(savedRaids[zoneName] and savedRaids[zoneName][raidSave])
                        end

                        if add then
                            local zoneData
                            if mountSource.type == 'world' then
                                zoneData = worldMounts[zoneName] or { items = {}, sort = mountSource.for_sort }
                                worldMounts[zoneName] = zoneData
                            else
                                zoneData = raidMounts[zoneName] or { items = {}, sort = mountSource.for_sort }
                                raidMounts[zoneName] = zoneData
                            end

                            zoneData.sort = min(zoneData.sort, mountSource.for_sort)

                            local npcData = zoneData.items[npcName] or { items = {}, sort = mountSource.for_sort }
                            zoneData.items[npcName] = npcData

                            npcData.sort = min(zoneData.sort, mountSource.for_sort)

                            table.insert(npcData.items, { link = mountLink })
                        end
                    end
                end
            end
        end
    end

    tooltip:ClearLines();
    tooltip:AddLine(L.title, unpack(COLOR_WHITE));

    local mountTable
    for _, mountTable in pairs({{ items = raidMounts, title = 'raid' }, { items = worldMounts, title = 'world' }}) do
        if not tableIsEmpty(mountTable.items) then
            tooltip:AddLine(EMPTY_LINE)
            tooltip:AddLine(L['title_' .. mountTable.title], unpack(COLOR_WHITE))

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
                        tooltip:AddLine(string.format('%s / %s', firstName, secondName))
                    else
                        if not titlePrinted then
                            tooltip:AddLine(string.format('%s', firstName))
                            titlePrinted = 1
                        end
                        tooltip:AddLine(string.format('    %s', secondName))
                    end

                    local mountData
                    for _, mountData in pairs(secondData.items) do
                        tooltip:AddLine(string.format('        %s', mountData.link:gsub('%[', ''):gsub('%]', '')))
                    end
                end
            end
        end
    end
end
