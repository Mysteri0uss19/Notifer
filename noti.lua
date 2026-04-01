local WEBHOOK_URL = "https://discord.com/api/webhooks/1488442806992109710/Ua4BOZiqbRCFQKrrWX1MTiPB9j6gPI8sIHzAwAxT2qKs18_soIEDmqvO0mjHCR4MSY8T"
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local BOSS_CONFIG = {
    ["Sea King"]                 = { label="Sea King",                   emoji="🌊", color=3447003  },
    ["Serpent"]                  = { label="Serpent",                    emoji="🐍", color=3447003  },
    ["HydraSeaKing"]             = { label="Hydra Sea King",             emoji="🐙", color=10038562 },
    ["ThirdSeaDragon"]           = { label="Drakenfyr the Inferno King", emoji="🔥", color=15158332 },
    ["SeaDragon"]                = { label="Sea Dragon (Tyrant)",        emoji="🐲", color=15158332 },
    ["Shark Galleon Boss"]       = { label="Shark Galleon Boss",         emoji="🦈", color=3447003  },
    ["Kraken Galleon Boss"]      = { label="Kraken Galleon Boss",        emoji="🦑", color=5763719  },
    ["Pteranodon [Lv. 12500]"]   = { label="Pteranodon",                 emoji="🦕", color=5763719  },
    ["GhostShip"]                = { label="Ghost Ship",                 emoji="👻", color=9807270  },
    ["Whale Galleon Boss"]       = { label="Whale Galleon Boss",         emoji="🐋", color=3447003  },
    ["ThirdSeaEldritch Crab"]    = { label="Eldritch Crab",              emoji="🦀", color=10038562 },
    ["Lord of Saber [Lv. 8500]"] = { label="Lord of Saber",             emoji="⚔️", color=15844367 },
    ["Ashen Talon [Lv. 10000]"]  = { label="Ashen Talon",               emoji="🦅", color=15105570 },
    ["FuryTentacle"]             = { label="Kraken",                     emoji="🐙", color=10038562 },
}

local NOTIFY_COOLDOWN = 90
local Notiboss = {}

local function getTimeOfDay()
    local lighting     = game:GetService("Lighting")
    local totalMinutes = lighting.ClockTime * 60
    local h = math.floor(totalMinutes / 60) % 24
    local m = math.floor(totalMinutes % 60)
    local s = math.floor((totalMinutes % 1) * 60)
    return string.format("%02d:%02d:%02d", h, m, s)
end

local function getPlayerCount()
    return #Players:GetPlayers() .. "/" .. Players.MaxPlayers
end

local function getWorldName()
    local id = game.PlaceId
    if id == 4520749081  then return "🌍 World 1"
    elseif id == 6381829480  then return "🌏 World 2"
    elseif id == 15759515082 then return "🌐 World 3"
    else return "🗺️ Unknown World" end
end

local function sendRequest(payload)
    pcall(function()
        local requestFunc = syn and syn.request
            or http and http.request
            or (typeof(request) == "function" and request)
            or nil

        if requestFunc then
            requestFunc({
                Url     = WEBHOOK_URL,
                Method  = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body    = payload,
            })
        else
            HttpService:PostAsync(WEBHOOK_URL, payload, Enum.HttpContentType.ApplicationJson)
        end
    end)
end

sendWebhook = function(cfg)
    local description =
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n" ..
        cfg.emoji .. "  **" .. cfg.label .. " Spawned !**\n" ..
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n" ..
        "🌐 **World**\n> " .. getWorldName() .. "\n\n" ..
        "⏰ **Server Time**\n> `" .. getTimeOfDay() .. "`\n\n" ..
        "👥 **Players**\n> `" .. getPlayerCount() .. "`\n\n" ..
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n" ..
        "🔑 **Job ID** → `" .. game.JobId .. "`\n\n" ..
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n" ..
        "*Detected by AxelHub Notifier*"

    task.spawn(function()
        local payload1 = HttpService:JSONEncode({
            username = "⚔️ AxelHub Notifier",
            content  = "🔑 **Job ID** → `" .. game.JobId .. "`",
            embeds = {{
                title       = cfg.emoji .. "  Boss Alert — King Legacy",
                description = description,
                color       = cfg.color,
                footer      = { text = "🕐 " .. os.date("!%Y-%m-%d %H:%M:%S") .. " UTC  •  AxelHub v0.0.3" },
                thumbnail   = { url = "https://www.roblox.com/favicon.ico" },
            }}
        })
        sendRequest(payload1)

        task.wait(0.5)

        local payload2 = HttpService:JSONEncode({
            username = "⚔️ AxelHub Notifier",
            content  = game.JobId,
        })
        sendRequest(payload2)
    end)
end

local function findHumAndRoot(mob)
    local hum  = mob:FindFirstChildOfClass("Humanoid")
    local root = mob:FindFirstChild("HumanoidRootPart")
                 or mob:FindFirstChild("Tentacle")
                 or mob.PrimaryPart
    if hum and root then return hum, root end

    for _, child in ipairs(mob:GetChildren()) do
        if child:IsA("Model") then
            local h = child:FindFirstChildOfClass("Humanoid")
            local r = child:FindFirstChild("HumanoidRootPart")
                      or child:FindFirstChild("Tentacle")
                      or child.PrimaryPart
            if h and r then return h, r end
        end
    end

    local h = mob:FindFirstChildWhichIsA("Humanoid", true)
    local r = mob:FindFirstChild("HumanoidRootPart", true)
              or mob:FindFirstChild("Tentacle", true)
              or mob.PrimaryPart
    return h, r
end

local function tryNotify(mobName, mob)
    local cfg = BOSS_CONFIG[mobName]
    if not cfg then return end

    local hum, root = findHumAndRoot(mob)

    if not (hum and root and hum.Health > 0) then
        Notiboss[mobName] = nil
        return
    end

    local now = tick()
    if Notiboss[mobName] and (now - Notiboss[mobName]) < NOTIFY_COOLDOWN then return end
    Notiboss[mobName] = now
    sendWebhook(cfg)
end

local function scanFolder(folder)
    if not folder then return end
    for _, mob in ipairs(folder:GetChildren()) do
        tryNotify(mob.Name, mob)
    end
end

local function scanGhostShip()
    local ghostRoot = workspace:FindFirstChild("GhostMonster")
    if not ghostRoot then Notiboss["GhostShip"] = nil return end
    local hasAlive = false
    for _, obj in ipairs(ghostRoot:GetDescendants()) do
        if obj:IsA("Model") then
            local hum = obj:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then hasAlive = true break end
        end
    end
    if hasAlive then
        local now = tick()
        if not Notiboss["GhostShip"] or (now - Notiboss["GhostShip"]) > NOTIFY_COOLDOWN then
            Notiboss["GhostShip"] = now
            sendWebhook(BOSS_CONFIG["GhostShip"])
        end
    else
        Notiboss["GhostShip"] = nil
    end
end

task.spawn(function()
    while true do
        pcall(function()
            local monsterFolder = workspace:FindFirstChild("Monster")
            if monsterFolder then
                scanFolder(monsterFolder:FindFirstChild("Boss"))
            end

            scanFolder(workspace:FindFirstChild("SeaMonster"))

            local mobFolder = workspace:FindFirstChild("MOB")
            if mobFolder then
                scanFolder(mobFolder)
            end

            local pteroKL = workspace:FindFirstChild("Pteranodon_KL")
            if pteroKL then
                for _, mob in ipairs(pteroKL:GetChildren()) do
                    tryNotify("Pteranodon [Lv. 12500]", mob)
                end
            end

            scanGhostShip()
        end)
        task.wait(5)
    end
end)
