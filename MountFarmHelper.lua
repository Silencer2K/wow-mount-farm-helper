local addonName, addon = ...

LibStub("AceAddon-3.0"):NewAddon(addon, addonName, "AceEvent-3.0", "AceTimer-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

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
        end,
        OnLeave = function()
        end,
        OnClick = function(obj, button)
            if button == "RightButton" then
                InterfaceOptionsFrame_OpenToCategory(addonName)
            end
        end,
    })

    LibStub("LibDBIcon-1.0"):Register(addonName, self.ldb, self.db.profile.minimap)
end
