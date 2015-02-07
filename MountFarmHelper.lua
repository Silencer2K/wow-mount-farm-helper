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
                    { item = 32768, spell = 41252 },    -- Reins of the Raven Lord
                },
            },
        },
    },
    karazhan = {
        level = 70, ilevel_max = 125,
        bosses = {
            attumen_the_huntsman = {
                mounts = {
                    { item = 30480, spell = 36702 },    -- Fiery Warhorse's Reins
                },
            },
        },
    },
    the_eye = {
        level = 70, ilevel_max = 141,
        bosses = {
            kaelthas_sunstrider = {
                mounts = {
                    { item = 32458, spell = 40192 },    -- Ashes of Al'ar
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
                    { item = 44151, spell = 59996 },    -- Reins of the Blue Proto-Drake
                },
            },
        },
    },
    the_eye_of_eternity = {
        level = 80, ilevel_max = 226,
        bosses = {
            malygos = {
                mounts = {
                    { item = 43952, spell = 59567 },    -- Reins of the Azure Drake
                    { item = 43953, spell = 59568 },    -- Reins of the Blue Drake
                },
            },
        },
    },
    ulduar = {
        level = 80, ilevel_max = 239,
        bosses = {
            yogg_saron = {
                mounts = {
                    { item = 45693, spell = 63796 },    -- Mimiron's Head
                },
            },
        },
    },
    onyxias_lair = {
        level = 80, ilevel_max = 245,
        bosses = {
            onyxia = {
                mounts = {
                    { item = 49636, spell = 69395 },    -- Reins of the Onyxian Drake
                },
            },
        },
    },
    icecrown_citadel = {
        level = 80, ilevel_max = 284,
        bosses = {
            the_lich_king = {
                mounts = {
                    { item = 50818, spell = 72286 },    -- Invincible's Reins
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
                    { item = 68823, spell = 96491 },    -- Armored Razzashi Raptor
                },
            },
            high_priestess_kilnara = {
                mounts = {
                    { item = 68824, spell = 96499 },    -- Swift Zulian Panther
                },
            },
        },
    },
    throne_of_the_four_winds = {
        level = 85, ilevel_max = 372,
        bosses = {
            alakir = {
                mounts = {
                    { item = 63041, spell = 88744 },    -- Reins of the Drake of the South Wind
                },
            },
        },
    },
    firelands = {
        level = 85, ilevel_max = 397,
        bosses = {
            alysrazor = {
                mounts = {
                    { item = 71665, spell = 101542 },   -- Flametalon of Alysrazor
                },
            },
            ragnaros = {
                mounts = {
                    { item = 69224, spell = 97493 },    -- Smoldering Egg of Millagazor
                },
            },
        },
    },
    dragon_soul = {
        level = 85, ilevel_max = 416,
        bosses = {
            ultraxion = {
                mounts = {
                    { item = 78919, spell = 110039 },   -- Experiment 12-B
                },
            },
            madness_of_deathwing = {
                mounts = {
                    { item = 77067, spell = 107842 },   -- Reins of the Blazing Drake
                    { item = 77069, spell = 107845 },   -- Life-Binder's Handmaiden
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
                    { item = 87777, spell = 127170 },   -- Reins of the Astral Cloud Serpent
                },
            },
        },
    },
    throne_of_thunder = {
        level = 90, ilevel_max = 541,
        bosses = {
            jikun = {
                mounts = {
                    { item = 95059, spell = 139448 },   -- Clutch of Ji-Kun
                },
            },
            horridon = {
                mounts = {
                    { item = 93666, spell = 136471 },   -- Spawn of Horridon
                },
            },
        },
    },
    siege_of_orgrimmar = {
        level = 90, ilevel_max = 620,
        bosses = {
            garrosh_hellscream = {
                mounts = {
                    { item = 104253, spell = 148417 },  -- Kor'kron Juggernaut
                },
            },
        },
    },
}

local WORLD_BOSSES_MOUNTS = {
    -- Mists of Pandaria
    galleon = {
        level = 90, ilevel_max = 496,
        mounts = {
            { item = 89783, spell = 130965 },       -- Son of Galleon's Saddle
        },
    },
    nalak = {
        level = 90, ilevel_max = 522,
        mounts = {
            { item = 95057, spell = 139442 },       -- Reins of the Thundering Cobalt Cloud Serpent
        },
    },
    oondasta = {
        level = 90, ilevel_max = 522,
        mounts = {
            { item = 94228, spell = 138423 },       -- Reins of the Cobalt Primordial Direhorn
        },
    },
    -- Warlords of Draenor
    rukhmar = {
        level = 100, ilevel_max = 665,
        mounts = {
            { quest = 37464, item = 116771, spell  = 171828 },      -- Solar Spirehawk
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
                    if not mounts[mount.spell] then
                        im[raid][boss] = 1
                    end
                end
            end
        end
    end

    for boss in pairs(WORLD_BOSSES_MOUNTS) do
        if WORLD_BOSSES_MOUNTS[boss].level <= level then
            for _, mount in pairs(WORLD_BOSSES_MOUNTS[boss].mounts) do
                if not mounts[mount.spell] and not (mount.quest and IsQuestFlaggedCompleted(mount.quest)) then
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
                if not mounts[mount.spell] then
                    local _, link = GetItemInfo(mount.item)
                    if link then
                        link = link:gsub('%[', ''):gsub('%]', '')
                        tooltip:AddLine(string.format("    %s", link))
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
            if not mounts[mount.spell] then
                local _, link = GetItemInfo(mount.item)
                if link then
                    link = link:gsub('%[', ''):gsub('%]', '')
                    tooltip:AddLine(string.format("    %s", link))
                end
            end
        end
    end
end
