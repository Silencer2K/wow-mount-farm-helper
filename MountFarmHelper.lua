local addonName, addon = ...

LibStub('AceAddon-3.0'):NewAddon(addon, addonName, 'AceEvent-3.0')

local L = LibStub('AceLocale-3.0'):GetLocale(addonName)

local COLOR_WHITE = 'ffffffff'

local INSTANCE_MOUNTS = {
    -- Burning Crusade
    sethekk_halls = {
        anzu = {
            { item = 32768, spell = 41252 },    -- Reins of the Raven Lord
        },
    },
    karazhan = {
        attumen_the_huntsman = {
            { item = 30480, spell = 36702 },    -- Fiery Warhorse's Reins
        },
    },
    the_eye = {
        kaelthas_sunstrider = {
            { item = 32458, spell = 40192 },    -- Ashes of Al'ar
        },
    },
    utgarde_pinnacle = {
        skadi_the_ruthless = {
            { item = 44151, spell = 59996 },    -- Reins of the Blue Proto-Drake
        },
    },
    -- Wrath of the Lich King
    onyxias_lair = {
        onyxia = {
            { item = 49636, spell = 69395 },    -- Reins of the Onyxian Drake
        },
    },
    the_eye_of_eternity = {
        malygos = {
            { item = 43952, spell = 59567 },    -- Reins of the Azure Drake
            { item = 43953, spell = 59568 },    -- Reins of the Blue Drake
        },
    },
    ulduar = {
        yogg_saron = {
            { item = 45693, spell = 63796 },    -- Mimiron's Head
        },
    },
    icecrown_citadel = {
        the_lich_king = {
            { item = 50818, spell = 72286 },    -- Invincible's Reins
        },
    },
    -- Cataclysm
    throne_of_the_four_winds = {
        alakir = {
            { item = 63041, spell = 88744 },    -- Reins of the Drake of the South Wind
        },
    },
    firelands = {
        alysrazor = {
            { item = 71665, spell = 101542 },   -- Flametalon of Alysrazor
        },
        ragnaros = {
            { item = 69224, spell = 97493 },    -- Smoldering Egg of Millagazor
        },
    },
    dragon_soul = {
        ultraxion = {
            { item = 78919, spell = 110039 },   -- Experiment 12-B
        },
        madness_of_deathwing = {
            { item = 77067, spell = 107842 },   -- Reins of the Blazing Drake
            { item = 77069, spell = 107845 },   -- Life-Binder's Handmaiden
        },
    },
}

function addon:OnInitialize()
    self.db = LibStub('AceDB-3.0'):New(addonName .. 'DB', {
        profile = {
            minimap = {
                hide = false,
            },
        },
    })

    self.ldb = LibStub("LibDataBroker-1.1"):NewDataObject(addonName, {
        type = "launcher",
        text = "Mount Farm Helper",
        icon = "Interface\\ICONS\\ABILITY_MOUNT_GOLDENGRYPHON",
        OnTooltipShow = function(...)
            addon:UpdateTooltip(...)
        end,
    });

    self.icon = LibStub("LibDBIcon-1.0")
    self.icon:Register(addonName, self.ldb, self.db.profile.minimap)
end

function addon:UpdateTooltip(tooltip)
    tooltip:AddLine(string.format("|c%s%s|r", COLOR_WHITE, L.title))

    local hasRaids, hasWorldBosses
    local i, j, k, v

    local mounts = {}
    for i = 1, C_MountJournal.GetNumMounts() do
        local _, spell, _, _, _, _, _, _, _, _, collected = C_MountJournal.GetMountInfo(i)
        if collected then
            mounts[spell] = 1
        end
    end

    local im = {}
    local raid, boss, mount

    for raid in pairs(INSTANCE_MOUNTS) do
        im[raid] = {}

        for boss in pairs(INSTANCE_MOUNTS[raid]) do
            for _, mount in pairs(INSTANCE_MOUNTS[raid][boss]) do
                if not mounts[mount.spell] then
                    im[raid][boss] = 1
                end
            end
        end
    end

    local lr, lb = {}, {}
    for k, v in pairs(L) do
        if strsub(k, 1, 5) == 'raid_' then
            lr[v] = strsub(k, 6)
        elseif strsub(k, 1, 5) == 'boss_' then
            lb[v] = strsub(k, 6)
        end
    end

    for i = 1, GetNumSavedInstances() do
        local raidName, _, _, _, locked, extended, _, _, _, _, numBosses = GetSavedInstanceInfo(i)
        raid = lr[raidName]

        if raid and im[raid] and locked and not extended then
            for j = 1, numBosses do
                local bossName, _, killed = GetSavedInstanceEncounterInfo(i, j)
                boss = lb[bossName]

                if boss and im[raid][boss] and killed then
                    im[raid][boss] = nil
                end
            end
        end
    end

    for raid in pairs(im) do
        local rp, bp
        for boss in pairs(im[raid]) do
            if not hasRaids then
                tooltip:AddLine(string.format("|c%s%s:|r", COLOR_WHITE, L.title_raids))
                hasRaids = 1
            end

            if not rp  then
                tooltip:AddLine(string.format("%s:", L['raid_' .. raid]))
                rp = 1
            end

            for _, mount in pairs(INSTANCE_MOUNTS[raid][boss]) do
                if not mounts[mount.spell] then
                    local _, link = GetItemInfo(mount.item)

                    if not bp then
                        tooltip:AddDoubleLine(string.format("%s:", L['boss_' .. boss]), link)
                        bp = 1
                    else
                        tooltip:AddDoubleLine('', link)
                    end
                end
            end
        end
    end
end
