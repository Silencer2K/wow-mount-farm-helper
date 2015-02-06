local addonName, addon = ...

LibStub('AceAddon-3.0'):NewAddon(addon, addonName, 'AceEvent-3.0')

local L = LibStub('AceLocale-3.0'):GetLocale(addonName)

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
    self:RegisterEvent('PLAYER_ENTERING_WORLD', function(...)
        addon:PrintAvailable()
    end)
end

function addon:PrintAvailable()
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
        local rp
        for boss in pairs(im[raid]) do
            if not rp  then
                print(L['raid_' .. raid])
                rp = 1
            end

            print('-', L['boss_' .. boss])
        end
    end
end
