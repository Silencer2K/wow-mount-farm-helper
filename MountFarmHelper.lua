local addonName, addon = ...

LibStub("AceAddon-3.0"):NewAddon(addon, addonName, "AceEvent-3.0", "AceTimer-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local qtip = LibStub("LibQTip-1.0")

function addon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New(addonName .. "DB", {
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

    -- settings page
    LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, self:GetOptions())

    LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, nil, nil, "general")
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, self.options.args.profiles.name, addonName, "profiles")

    -- minimap icon
    self.ldb = LibStub("LibDataBroker-1.1"):NewDataObject(addonName, {
        type = "launcher",
        icon = "Interface\\ICONS\\ABILITY_MOUNT_GOLDENGRYPHON",
        label = addonName,
        OnEnter = function(...)
            self:ShowTooltip(...)
        end,
        OnLeave = function()
        end,
        OnClick = function(obj, button)
            if button == "RightButton" then
                InterfaceOptionsFrame_OpenToCategory(addonName)
            else
                self:OpenCollection()
            end
        end,
    })

    LibStub("LibDBIcon-1.0"):Register(addonName, self.ldb, self.db.profile.minimap)

    -- envents
    self:RegisterEvent("PLAYER_LOGIN", function(...)
        if not MountJournal_OnLoad then
            UIParentLoadAddOn("Blizzard_Collections")
        end
    end)
end

function addon:ShowTooltip(anchor)
    if not (InCombatLockdown() or (self.tooltip and self.tooltip:IsShown())) then
        if not (qtip:IsAcquired(addonName) and self.tooltip) then
            self.tooltip = qtip:Acquire(addonName, 2, "LEFT")

            self.tooltip.OnRelease = function()
                self.tooltip = nil
            end
        end

        if anchor then
            self.tooltip:SmartAnchorTo(anchor)
            self.tooltip:SetAutoHideDelay(0.05, anchor)
        end

        self:UpdateTooltip(self.tooltip)
    end
end

function addon:UpdateTooltip(tooltip)
    tooltip:Clear()

    tooltip:AddLine("")

    local data = self:BuildTooltipData()

    tooltip:UpdateScrolling()
    tooltip:Show()
end

function addon:GetSavedRaids()
    local raids = {}

    local i
    for i = 1, GetNumSavedInstances() do
    end

    return raids
end

function addon:BuildTooltipData()
    local raids = self:GetSavedRaids()
    local collected, xlat = self:GetCollectedItems()
end

function addon:GetCollectedItems()
    local mounts, spells = {}, {}

    for id in table.s2k_values(C_MountJournal.GetMountIDs()) do
        local spell, collected = table.s2k_select({ C_MountJournal.GetMountInfoByID(id) }, 2, 11)

        spells[spell] = id

        if collected then
            mounts[spell] = 1
        end
    end

    return mounts, spells
end

function addon:OpenCollection(id, xlat)
    if not CollectionsJournal:IsShown() then
        ToggleCollectionsJournal()
    end

    CollectionsJournal_SetTab(CollectionsJournal, 1)

    if id then
        MountJournal.selectedMountID = id
        MountJournal.selectedSpellID = xlat

        MountJournal_HideMountDropdown()
        MountJournal_UpdateMountList()
        MountJournal_UpdateMountDisplay()
    else
        MountJournal_Select(1)
    end
end
