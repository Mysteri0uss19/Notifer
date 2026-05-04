local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local WEBHOOK_URLS = {
    [4520749081]  = "",
    [6381829480]  = "",
    [15759515082] = "",
}

local WEBHOOK_URL = WEBHOOK_URLS[game.PlaceId] or WEBHOOK_URLS[4520749081]

local BOSS_CONFIG = {
    ["Sea King"]                 = { label="Sea King",                   emoji="🌊", color=3447003  },
    ["SeaKing"]                  = { label="Sea King",                   emoji="🌊", color=3447003  },
    ["Serpent"]                  = { label="Serpent",                    emoji="🐍", color=3447003  },
    ["HydraSeaKing"]             = { label="Hydra Sea King",             emoji="🐙", color=10038562 },
    ["ThirdSeaDragon"]           = { label="Drakenfyr the Inferno King", emoji="🔥", color=15158332 },
    ["SeaDragon"]                = { label="Sea Dragon (Tyrant)",        emoji="🐲", color=15158332 },
    ["Sea Dragon"]               = { label="Sea Dragon (Tyrant)",        emoji="🐲", color=15158332 },
    ["Shark Galleon Boss"]       = { label="Shark Galleon Boss",         emoji="🦈", color=3447003  },
    ["Kraken Galleon Boss"]      = { label="Kraken Galleon Boss",        emoji="🦑", color=5763719  },
    ["Pteranodon [Lv. 12500]"]   = { label="Pteranodon",                 emoji="🦕", color=5763719  },
    ["GhostShip"]                = { label="Ghost Ship",                 emoji="👻", color=9807270  },
    ["Whale Galleon Boss"]       = { label="Whale Galleon Boss",         emoji="🐋", color=3447003  },
    ["ThirdSeaEldritch Crab"]    = { label="Eldritch Crab",              emoji="🦀", color=10038562 },
    ["Lord of Saber [Lv. 8500]"] = { label="Lord of Saber",              emoji="⚔️", color=15844367 },
    ["Ashen Talon [Lv. 10000]"]  = { label="Ashen Talon",                emoji="🦅", color=15105570 },
    ["FuryTentacle"]             = { label="Kraken",                     emoji="🐙", color=10038562 },
    ["Whirlpool"]                = { label="Whirlpool",                  emoji="🌀", color=1752220  },
    ["King Samurai [Lv. 3500]"]  = { label="King Samurai",               emoji="⚔️", color=15105570 },
    ["Ms. Mother [Lv. 7500]"]    = { label="Ms. Mother",                 emoji="🍖", color=15844367 },
}

local NOTIFY_COOLDOWN = 90
local Notiboss = {}

local function getTimeOfDay()
    local lighting = game:GetService("Lighting")
    local totalMinutes = lighting.ClockTime * 60
    local h, m = math.floor(totalMinutes / 60) % 24, math.floor(totalMinutes % 60)
    return string.format("%02d:%02d", h, m)
end

local function getWorldName()
    local id = game.PlaceId
    if id == 4520749081  then return "🌍 World 1"
    elseif id == 6381829480  then return "🌏 World 2"
    elseif id == 15759515082 then return "🌐 World 3"
    else return "🗺️ Unknown" end
end

local TRACKER_WEBHOOK = "https://discord.com/api/webhooks/1491672353992605858/LsB3vhfe5fdgfwUfFdu-mgeXG_Y2arD_Jz4Bl9AGZOIanyI73eqMbc1lq90qQcfU_t5i"

local seenUsers = {}
local RESET_INTERVAL = 43200

local function sendUserTracker()
    local plr = Players.LocalPlayer
    local userId = plr.UserId
    local now = tick()

    if seenUsers[userId] and (now - seenUsers[userId]) < RESET_INTERVAL then
        return
    end

    seenUsers[userId] = now

    task.spawn(function()
        local payload = HttpService:JSONEncode({
            username = "📊 AxelHub Tracker",
            embeds = {{
                title = "👤 User Running Script",
                description =
                    "**User ID:** `" .. userId .. "`\n" ..
                    "**Player:** `" .. plr.Name .. "`\n" ..
                    "**World:** " .. getWorldName(),
                color = 5763719,
                footer = { text = "🕐 " .. os.date("!%Y-%m-%d %H:%M:%S") .. " UTC" }
            }}
        })
        pcall(function()
            local requestFunc = syn and syn.request or http and http.request or (typeof(request) == "function" and request)
            if requestFunc then
                requestFunc({
                    Url = TRACKER_WEBHOOK,
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/json" },
                    Body = payload,
                })
            else
                HttpService:PostAsync(TRACKER_WEBHOOK, payload, Enum.HttpContentType.ApplicationJson)
            end
        end)
    end)
end

sendUserTracker()

local function sendRequest(payload)
    pcall(function()
        local requestFunc = syn and syn.request or http and http.request or (typeof(request) == "function" and request)
        if requestFunc then
            requestFunc({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = payload,
            })
        else
            HttpService:PostAsync(WEBHOOK_URL, payload, Enum.HttpContentType.ApplicationJson)
        end
    end)
end

local function sendWebhook(cfg)
    local description =
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n" ..
        cfg.emoji .. "  **" .. cfg.label .. " Spawned !**\n" ..
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n" ..
        "🌐 **World**\n> " .. getWorldName() .. "\n\n" ..
        "⏰ **Server Time**\n> `" .. getTimeOfDay() .. "`\n\n" ..
        "👥 **Players**\n> `" .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers .. "`\n\n" ..
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n" ..
        "*Detected by AxelHub Notifier*"

    task.spawn(function()
        local payload = HttpService:JSONEncode({
            username = "⚔️ AxelHub Notifier",
            content  = "```" .. game.JobId .. "```",
            embeds = {{
                title       = cfg.emoji .. "  Boss Alert — King Legacy",
                description = description,
                color       = cfg.color,
                footer      = { text = "🕐 " .. os.date("!%Y-%m-%d %H:%M:%S") .. " UTC" },
                thumbnail   = { url = "https://www.roblox.com/favicon.ico" },
            }}
        })
        sendRequest(payload)
    end)
end

local function tryNotify(mobName, mob)
    local cfg = nil
    local keyName = ""

    if BOSS_CONFIG[mobName] then
        cfg = BOSS_CONFIG[mobName]
        keyName = mobName
    else
        for key, data in pairs(BOSS_CONFIG) do
            if mobName:find(key, 1, true) or key:find(mobName, 1, true) then
                cfg = data
                keyName = key
                break
            end
        end
    end

    local hum = mob:FindFirstChildOfClass("Humanoid") or mob:FindFirstChildWhichIsA("Humanoid", true)
    if not (hum and hum.Health > 0) then
        Notiboss[keyName] = nil
        return
    end

    local now = tick()
    if Notiboss[keyName] and (now - Notiboss[keyName]) < NOTIFY_COOLDOWN then return end

    Notiboss[keyName] = now
    sendWebhook(cfg)
end

local function scanSpecialEvents()
    local e = workspace:FindFirstChild("Effects")
    local wp = e and (e:FindFirstChild("SerpentWhirlpool") or e:FindFirstChild("SeaKingWhirlpool") or e:FindFirstChild("Whirlpool"))
    if wp then
        if not Notiboss["Whirlpool"] or (tick() - Notiboss["Whirlpool"]) > NOTIFY_COOLDOWN then
            Notiboss["Whirlpool"] = tick()
            sendWebhook(BOSS_CONFIG["Whirlpool"])
        end
    else
        Notiboss["Whirlpool"] = nil
    end

    local gs = workspace:FindFirstChild("GhostMonster")
    if gs then
        local alive = false
        for _, v in ipairs(gs:GetDescendants()) do
            if v:IsA("Humanoid") and v.Health > 0 then alive = true break end
        end
        if alive then
            if not Notiboss["GhostShip"] or (tick() - Notiboss["GhostShip"]) > NOTIFY_COOLDOWN then
                Notiboss["GhostShip"] = tick()
                sendWebhook(BOSS_CONFIG["GhostShip"])
            end
        end
    else
        Notiboss["GhostShip"] = nil
    end
end

-- ──────────────────────────────────────────
--  Island Notifier
-- ──────────────────────────────────────────
local ISLAND_WEBHOOK = "https://discord.com/api/webhooks/1496816783053688893/YPEoGkA0Yz8uiFgImmf1E6mes-7X2TsuGyCZdoG70nIZzmNeaXJyKW71XwCqoCxEG9f6"

local ISLAND_CONFIG = {
    ["Human Island"]  = { label = "Human Island",  emoji = "👤", color = 15844367 },
    ["Animal Island"] = { label = "Animal Island", emoji = "🐾", color = 5763719  },
    ["Angel Island"]  = { label = "Angel Island",  emoji = "😇", color = 16777215  },
    ["Fish Island"]   = { label = "Fish Island",   emoji = "🐟", color = 3447003  },
}

local ISLAND_COOLDOWN = 120
local NotiIsland = {}

local function sendIslandRequest(payload)
    pcall(function()
        local requestFunc = syn and syn.request or http and http.request or (typeof(request) == "function" and request)
        if requestFunc then
            requestFunc({
                Url = ISLAND_WEBHOOK,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = payload,
            })
        else
            HttpService:PostAsync(ISLAND_WEBHOOK, payload, Enum.HttpContentType.ApplicationJson)
        end
    end)
end

local function sendIslandWebhook(cfg)
    local description =
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n" ..
        cfg.emoji .. "  **" .. cfg.label .. " is in this server!**\n" ..
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n" ..
        "🌐 **World**\n> " .. getWorldName() .. "\n\n" ..
        "⏰ **Server Time**\n> `" .. getTimeOfDay() .. "`\n\n" ..
        "👥 **Players**\n> `" .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers .. "`\n\n" ..
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n" ..
        "*Detected by AxelHub Notifier*"

    task.spawn(function()
        local payload = HttpService:JSONEncode({
            username = "🏝️ AxelHub Island Tracker",
            content  = "```" .. game.JobId .. "```",
            embeds = {{
                title       = cfg.emoji .. "  Island Alert — King Legacy",
                description = description,
                color       = cfg.color,
                footer      = { text = "🕐 " .. os.date("!%Y-%m-%d %H:%M:%S") .. " UTC" },
                thumbnail   = { url = "https://www.roblox.com/favicon.ico" },
            }}
        })
        sendIslandRequest(payload)
    end)
end

task.spawn(function()
    while true do
        pcall(function()
            local islandFolder = workspace:FindFirstChild("Island")
            if islandFolder then
                for islandName, cfg in pairs(ISLAND_CONFIG) do
                    local found = islandFolder:FindFirstChild(islandName)
                    if found then
                        local now = tick()
                        if not NotiIsland[islandName] or (now - NotiIsland[islandName]) > ISLAND_COOLDOWN then
                            NotiIsland[islandName] = now
                            sendIslandWebhook(cfg)
                        end
                    else
                        NotiIsland[islandName] = nil
                    end
                end
            end
        end)
        task.wait(10)
    end
end)

-- ──────────────────────────────────────────
--  Boss Scan Loop
-- ──────────────────────────────────────────
task.spawn(function()
    while true do
        pcall(function()
            local monsterFolder = workspace:FindFirstChild("Monster")
            if monsterFolder then
                local bossFolder = monsterFolder:FindFirstChild("Boss")
                if bossFolder then
                    for _, mob in ipairs(bossFolder:GetChildren()) do
                        tryNotify(mob.Name, mob)
                    end
                end
            end

            local seaFolder = workspace:FindFirstChild("SeaMonster")
            if seaFolder then
                for _, mob in ipairs(seaFolder:GetChildren()) do
                    tryNotify(mob.Name, mob)
                end
            end

            local mobFolder = workspace:FindFirstChild("MOB")
            if mobFolder then
                for _, mob in ipairs(mobFolder:GetChildren()) do
                    tryNotify(mob.Name, mob)
                end
            end

            local pteroFolder = workspace:FindFirstChild("Pteranodon_KL")
            if pteroFolder then
                for _, mob in ipairs(pteroFolder:GetChildren()) do
                    tryNotify("Pteranodon [Lv. 12500]", mob)
                end
            end

            scanSpecialEvents()
        end)
        task.wait(5)
    end
end)
