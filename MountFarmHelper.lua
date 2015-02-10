local addonName, addon = ...

LibStub('AceAddon-3.0'):NewAddon(addon, addonName, 'AceEvent-3.0')

local L = LibStub('AceLocale-3.0'):GetLocale(addonName)

local COLOR_WHITE = 'ffffffff'

local INSTANCE_MOUNTS = {
    -- Burning Crusade
    sethekk_halls = {
        level = 70, ilevel_max = 115,
        bosses = {
            anzu = {
                mounts = {
                    -- Reins of the Raven Lord
                    { item = 32768, spell = 41252, type = "heroic" },
                },
            },
        },
    },
    magisters_terrace = {
        level = 70, ilevel_max = 125,
        bosses = {
            kaelthas_sunstrider = {
                mounts = {
                    -- Swift White Hawkstrider
                    { item = 35513, spell = 46628, type = "heroic" },
                },
            },
        },
    },
    karazhan = {
        level = 70, ilevel_max = 125,
        bosses = {
            attumen_the_huntsman = {
                mounts = {
                    -- Fiery Warhorse's Reins
                    { item = 30480, spell = 36702 },
                },
            },
        },
    },
    the_eye = {
        level = 70, ilevel_max = 141,
        bosses = {
            kaelthas_sunstrider = {
                mounts = {
                    -- Ashes of Al'ar
                    { item = 32458, spell = 40192 },
                },
            },
        },
    },
    -- Wrath of the Lich King
    utgarde_pinnacle = {
        level = 80, ilevel_max = 200,
        bosses = {
            skadi_the_ruthless = {
                mounts = {
                    -- Reins of the Blue Proto-Drake
                    { item = 44151, spell = 59996, type = "heroic" },
                },
            },
        },
    },
    the_eye_of_eternity = {
        level = 80, ilevel_max = 226,
        bosses = {
            malygos = {
                mounts = {
                    -- Reins of the Azure Drake
                    { item = 43952, spell = 59567 },
                    -- Reins of the Blue Drake
                    { item = 43953, spell = 59568 },
                },
            },
        },
    },
    ulduar = {
        level = 80, ilevel_max = 239,
        bosses = {
            yogg_saron = {
                mounts = {
                    -- Mimiron's Head
                    { item = 45693, spell = 63796, type = "heroic" },
                },
            },
        },
    },
    onyxias_lair = {
        level = 80, ilevel_max = 245,
        bosses = {
            onyxia = {
                mounts = {
                    -- Reins of the Onyxian Drake
                    { item = 49636, spell = 69395 },
                },
            },
        },
    },
    vault_of_archavon = {
        level = 80, ilevel_max = 251,
        bosses = {
            koralon_the_flame_watcher = {
                mounts = {
                    -- Reins of the Grand Black War Mammoth (alliance)
                    { item = 43959, spell = 61465, faction = "Alliance" },
                    -- Reins of the Grand Black War Mammoth (horde)
                    { item = 44083, spell = 61467, faction = "Horde" },
                },
            },
            emalon_the_storm_watcher = {
                mounts = {
                    -- Reins of the Grand Black War Mammoth (alliance)
                    { item = 43959, spell = 61465, faction = "Alliance" },
                    -- Reins of the Grand Black War Mammoth (horde)
                    { item = 44083, spell = 61467, faction = "Horde" },
                },
            },
            archavon_the_stone_watcher = {
                mounts = {
                    -- Reins of the Grand Black War Mammoth (alliance)
                    { item = 43959, spell = 61465, faction = "Alliance" },
                    -- Reins of the Grand Black War Mammoth (horde)
                    { item = 44083, spell = 61467, faction = "Horde" },
                },
            },
            toravon_the_ice_watcher = {
                mounts = {
                    -- Reins of the Grand Black War Mammoth (alliance)
                    { item = 43959, spell = 61465, faction = "Alliance" },
                    -- Reins of the Grand Black War Mammoth (horde)
                    { item = 44083, spell = 61467, faction = "Horde" },
                },
            },
        },
    },
    icecrown_citadel = {
        level = 80, ilevel_max = 284,
        bosses = {
            the_lich_king = {
                mounts = {
                    -- Invincible's Reins
                    { item = 50818, spell = 72286, type = "heroic_25" },
                },
            },
        },
    },
    -- Cataclysm
    zulgurub = {
        level = 85, ilevel_max = 353,
        bosses = {
            bloodlord_mandokir = {
                mounts = {
                    -- Armored Razzashi Raptor
                    { item = 68823, spell = 96491, type = "heroic" },
                },
            },
            high_priestess_kilnara = {
                mounts = {
                    -- Swift Zulian Panther
                    { item = 68824, spell = 96499, type = "heroic" },
                },
            },
        },
    },
    throne_of_the_four_winds = {
        level = 85, ilevel_max = 372,
        bosses = {
            alakir = {
                mounts = {
                    -- Reins of the Drake of the South Wind
                    { item = 63041, spell = 88744 },
                },
            },
        },
    },
    firelands = {
        level = 85, ilevel_max = 397,
        bosses = {
            alysrazor = {
                mounts = {
                    -- Flametalon of Alysrazor
                    { item = 71665, spell = 101542 },
                },
            },
            ragnaros = {
                mounts = {
                    -- Smoldering Egg of Millagazor
                    { item = 69224, spell = 97493 },
                },
            },
        },
    },
    dragon_soul = {
        level = 85, ilevel_max = 416,
        bosses = {
            ultraxion = {
                mounts = {
                    -- Experiment 12-B
                    { item = 78919, spell = 110039 },
                },
            },
            madness_of_deathwing = {
                mounts = {
                    -- Reins of the Blazing Drake
                    { item = 77067, spell = 107842 },
                    -- Life-Binder's Handmaiden
                    { item = 77069, spell = 107845, type = "heroic" },
                },
            },
        },
    },
    -- Mists of Pandaria
    mogushan_vaults = {
        level = 90, ilevel_max = 502,
        bosses = {
            elegon = {
                mounts = {
                    -- Reins of the Astral Cloud Serpent
                    { item = 87777, spell = 127170 },
                },
            },
        },
    },
    throne_of_thunder = {
        level = 90, ilevel_max = 541,
        bosses = {
            jikun = {
                mounts = {
                    -- Clutch of Ji-Kun
                    { item = 95059, spell = 139448 },
                },
            },
            horridon = {
                mounts = {
                    -- Spawn of Horridon
                    { item = 93666, spell = 136471 },
                },
            },
        },
    },
    siege_of_orgrimmar = {
        level = 90, ilevel_max = 620,
        bosses = {
            garrosh_hellscream = {
                mounts = {
                    -- Kor'kron Juggernaut
                    { item = 104253, spell = 148417, type = "mythic" },
                },
            },
        },
    },
}

local WORLD_BOSSES_MOUNTS = {
    -- Mists of Pandaria
    sha_of_anger = {
        level = 90, ilevel_max = 483,
        mounts = {
            -- Reins of the Heavenly Onyx Cloud Serpent
            { quest = 32099, item = 87771, spell = 127158 },
        },
    },
    galleon = {
        level = 90, ilevel_max = 496,
        mounts = {
            -- Son of Galleon's Saddle
            { quest = 32098, item = 89783, spell = 130965 },
        },
    },
    nalak = {
        level = 90, ilevel_max = 522,
        mounts = {
            -- Reins of the Thundering Cobalt Cloud Serpent
            { quest = 32518, item = 95057, spell = 139442 },
        },
    },
    oondasta = {
        level = 90, ilevel_max = 522,
        mounts = {
            -- Reins of the Cobalt Primordial Direhorn
            { quest = 32519, item = 94228, spell = 138423 },
        },
    },
    -- Warlords of Draenor
    rukhmar = {
        level = 100, ilevel_max = 665,
        mounts = {
            -- Solar Spirehawk
            { quest = 37464, item = 116771, spell = 171828 },
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
    }, true)

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

    -- precache
    local raid, boss, mount
    for raid in pairs(INSTANCE_MOUNTS) do
        for boss in pairs(INSTANCE_MOUNTS[raid].bosses) do
            for _, mount in pairs(INSTANCE_MOUNTS[raid].bosses[boss].mounts) do
                GetItemInfo(mount.item)
            end
        end
    end

    for boss in pairs(WORLD_BOSSES_MOUNTS) do
        for _, mount in pairs(WORLD_BOSSES_MOUNTS[boss].mounts) do
            GetItemInfo(mount.item)
        end
    end
end

function addon:UpdateTooltip(tooltip)
    local level = UnitLevel("player")
    local faction = UnitFactionGroup("player")

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

    local im, wm = {}, {}
    local raid, boss, mount

    for raid in pairs(INSTANCE_MOUNTS) do
        im[raid] = {}

        for boss in pairs(INSTANCE_MOUNTS[raid].bosses) do
            if INSTANCE_MOUNTS[raid].level <= level then
                for _, mount in pairs(INSTANCE_MOUNTS[raid].bosses[boss].mounts) do
                    if not mounts[mount.spell]
                        and (not mount.faction or mount.faction == faction)
                    then
                        im[raid][boss] = 1
                    end
                end
            end
        end
    end

    for boss in pairs(WORLD_BOSSES_MOUNTS) do
        if WORLD_BOSSES_MOUNTS[boss].level <= level then
            for _, mount in pairs(WORLD_BOSSES_MOUNTS[boss].mounts) do
                if not mounts[mount.spell]
                    and not (mount.quest and IsQuestFlaggedCompleted(mount.quest))
                    and (not mount.faction or mount.faction == faction)
                then
                    wm[boss] = 1
                end
            end
        end
    end

    local lr, lb, lw = {}, {}, {}
    for k, v in pairs(L) do
        if strsub(k, 1, 5) == 'raid_' then
            lr[v] = strsub(k, 6)
        elseif strsub(k, 1, 5) == 'boss_' then
            lb[v] = strsub(k, 6)
        elseif strsub(k, 1, 11) == 'world_boss_' then
            lw[v] = strsub(k, 12)
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

    for i = 1, GetNumSavedWorldBosses() do
        local bossName = GetSavedWorldBossInfo(i)
        boss = lw[bossName]

        if boss and wm[boss] then
            wm[boss] = nil
        end
    end

    local raids = {}
    for raid in pairs(im) do
        table.insert(raids, raid)
    end
    table.sort(raids, function(a, b)
        return INSTANCE_MOUNTS[a].ilevel_max < INSTANCE_MOUNTS[b].ilevel_max
    end)

    for _, raid in pairs(raids) do
        for boss in pairs(im[raid]) do
            if not hasRaids then
                tooltip:AddLine(string.format("|c%s%s:|r", COLOR_WHITE, L.title_raids))
                hasRaids = 1
            end

            tooltip:AddLine(string.format("%s / %s:", L['raid_' .. raid], L['boss_' .. boss]))

            for _, mount in pairs(INSTANCE_MOUNTS[raid].bosses[boss].mounts) do
                if not mounts[mount.spell]
                    and (not mount.faction or mount.faction == faction)
                then
                    local _, link = GetItemInfo(mount.item)
                    if link then
                        link = link:gsub('%[', ''):gsub('%]', '')
                        if mount.type then
                            tooltip:AddLine(string.format("    %s |c%s(%s)|r", link, COLOR_WHITE, L['type_' .. mount.type]))
                        else
                            tooltip:AddLine(string.format("    %s", link))
                        end
                    end
                end
            end
        end
    end

    local bosses = {}
    for boss in pairs(wm) do
        table.insert(bosses, boss)
    end
    table.sort(bosses, function(a, b)
        return WORLD_BOSSES_MOUNTS[a].ilevel_max < WORLD_BOSSES_MOUNTS[b].ilevel_max
    end)

    for _, boss in pairs(bosses) do
        if not hasWorldBosses then
            tooltip:AddLine(string.format("|c%s%s:|r", COLOR_WHITE, L.title_world_bosses))
            hasWorldBosses = 1
        end

        tooltip:AddLine(string.format("%s:", L['world_boss_' .. boss]))

        for _, mount in pairs(WORLD_BOSSES_MOUNTS[boss].mounts) do
            if not mounts[mount.spell]
                and (not mount.faction or mount.faction == faction)
            then
                local _, link = GetItemInfo(mount.item)
                if link then
                    link = link:gsub('%[', ''):gsub('%]', '')
                    if mount.type then
                        tooltip:AddLine(string.format("    %s |c%s(%s)|r", link, COLOR_WHITE, L['type_' .. mount.type]))
                    else
                        tooltip:AddLine(string.format("    %s", link))
                    end
                end
            end
        end
    end
end
