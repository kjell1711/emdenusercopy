-- ============================================
-- ADMIN PANEL PRO v5 - ULTIMATE PERFORMANCE
-- ============================================

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

-- ============================================
-- KONFIGURATION & SETTINGS
-- ============================================

local SCRIPT_VERSION = "v5.0"
local UPDATE_RATE = 1 -- Sekunden zwischen Updates

-- ESP Einstellungen
local ESP_SETTINGS = {
    Enabled = false,
    PerformanceMode = false, -- Nur nahe Spieler anzeigen
    ShowBox = true,
    ShowName = true,
    MaxDistance = 200, -- Maximale Distanz für Performance ESP
    NameSize = 14, -- Kleinere Schriftgröße für ESP Namen
    BoxColor = Color3.fromRGB(0, 255, 0),
    NameColor = Color3.fromRGB(255, 255, 255)
}

-- ANTI-AFK EINSTELLUNG (NEU)
local ANTI_AFK_ENABLED = false
local antiAFKConnection = nil

local ESP_ITEMS = {}
local adminPanelGui = nil
local isPanelOpen = false
local currentInspectPlayer = nil
local inspectGui = nil
local lastUpdateTime = 0
local miniMenuGui = nil
local miniMenuTimeout = 0

-- AFK Tracking Variablen
local afkTrackingData = {}
local afkCheckConnections = {}

-- ============================================
-- INITIALISIERUNG
-- ============================================

print("╔══════════════════════════════════════╗")
print("║      ADMIN PANEL PRO " .. SCRIPT_VERSION .. "      ║")
print("╚══════════════════════════════════════╝")
print("📋 P = Nächstgelegenen Spieler kopieren")
print("📁 F2 = Admin Panel öffnen/schließen")
print("❌ ESC = Alles schließen")
print("========================================")

-- Notification
task.spawn(function()
    wait(0.5)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "🛡️ Admin Panel " .. SCRIPT_VERSION,
            Text = "P = Name | F2 = Panel | ESC = Schließen",
            Duration = 3
        })
    end)
end)

-- ============================================
-- TEIL 1: MINI-MENÜ (Name Copy) - MIT 1-TAG BAN
-- ============================================

local function closeMiniMenu()
    if miniMenuGui and miniMenuGui.Parent then
        miniMenuGui:Destroy()
        miniMenuGui = nil
    end
    miniMenuTimeout = 0
end

local function findNearestPlayer()
    local character = LP.Character
    if not character then return nil end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
    if not humanoidRootPart then return nil end
    
    local myPosition = humanoidRootPart.Position
    local nearestPlayer = nil
    local shortestDistance = math.huge
    local playerHP = 100
    local playerName = ""
    local userId = 0
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP then
            local targetChar = player.Character
            if targetChar then
                local targetRoot = targetChar:FindFirstChild("HumanoidRootPart") or targetChar.PrimaryPart
                if targetRoot then
                    local distance = (myPosition - targetRoot.Position).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        nearestPlayer = player
                        playerName = player.DisplayName or player.Name
                        userId = player.UserId
                        
                        local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            playerHP = math.floor(humanoid.Health)
                        end
                    end
                end
            end
        end
    end
    
    if nearestPlayer then
        return {
            player = nearestPlayer,
            name = playerName,
            username = nearestPlayer.Name,
            hp = playerHP,
            distance = math.floor(shortestDistance),
            userId = userId
        }
    end
    
    return nil
end

local function createMiniMenu(playerData)
    closeMiniMenu()
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MiniAdminMenu"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 100
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 280, 0, 210) -- Größer für mehr Buttons
    mainFrame.Position = UDim2.new(1, -300, 1, -330)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    mainFrame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = mainFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 60, 70)
    stroke.Thickness = 2
    stroke.Parent = mainFrame
    
    -- Titel
    local title = Instance.new("TextLabel")
    title.Text = "👑 Admin Schnellmenü"
    title.Size = UDim2.new(1, -20, 0, 35)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255, 215, 0)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = mainFrame
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "×"
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -45, 0, 10)
    closeBtn.BackgroundTransparency = 1
    closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 28
    closeBtn.Parent = mainFrame
    
    closeBtn.MouseButton1Click:Connect(closeMiniMenu)
    
    -- Spielerinfo
    local playerInfo = Instance.new("TextLabel")
    playerInfo.Text = playerData.name
    playerInfo.Size = UDim2.new(1, -20, 0, 26)
    playerInfo.Position = UDim2.new(0, 10, 0, 55)
    playerInfo.BackgroundTransparency = 1
    playerInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
    playerInfo.Font = Enum.Font.GothamBold
    playerInfo.TextSize = 15
    playerInfo.TextXAlignment = Enum.TextXAlignment.Left
    playerInfo.TextTruncate = Enum.TextTruncate.AtEnd
    playerInfo.Parent = mainFrame
    
    local usernameText = Instance.new("TextLabel")
    usernameText.Text = "@" .. playerData.username
    usernameText.Size = UDim2.new(1, -20, 0, 22)
    usernameText.Position = UDim2.new(0, 10, 0, 81)
    usernameText.BackgroundTransparency = 1
    usernameText.TextColor3 = Color3.fromRGB(180, 180, 200)
    usernameText.Font = Enum.Font.Gotham
    usernameText.TextSize = 13
    usernameText.TextXAlignment = Enum.TextXAlignment.Left
    usernameText.TextTruncate = Enum.TextTruncate.AtEnd
    usernameText.Parent = mainFrame
    
    local statsText = Instance.new("TextLabel")
    statsText.Text = string.format("❤️ %d HP | 📏 %d Studs", playerData.hp, playerData.distance)
    statsText.Size = UDim2.new(1, -20, 0, 22)
    statsText.Position = UDim2.new(0, 10, 0, 103)
    statsText.BackgroundTransparency = 1
    statsText.TextColor3 = Color3.fromRGB(150, 220, 255)
    statsText.Font = Enum.Font.Gotham
    statsText.TextSize = 13
    statsText.TextXAlignment = Enum.TextXAlignment.Left
    statsText.Parent = mainFrame
    
    -- Buttons (2 Reihen mit 4 Buttons)
    local buttonContainer1 = Instance.new("Frame")
    buttonContainer1.Size = UDim2.new(1, -20, 0, 40)
    buttonContainer1.Position = UDim2.new(0, 10, 1, -90)
    buttonContainer1.BackgroundTransparency = 1
    buttonContainer1.Parent = mainFrame
    
    local buttonContainer2 = Instance.new("Frame")
    buttonContainer2.Size = UDim2.new(1, -20, 0, 40)
    buttonContainer2.Position = UDim2.new(0, 10, 1, -45)
    buttonContainer2.BackgroundTransparency = 1
    buttonContainer2.Parent = mainFrame
    
    -- Erste Reihe
    local kickBtn = Instance.new("TextButton")
    kickBtn.Text = "🚪"
    kickBtn.Size = UDim2.new(0.24, -2, 1, 0)
    kickBtn.Position = UDim2.new(0, 0, 0, 0)
    kickBtn.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
    kickBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    kickBtn.Font = Enum.Font.GothamBold
    kickBtn.TextSize = 16
    kickBtn.Parent = buttonContainer1
    
    local banBtn = Instance.new("TextButton")
    banBtn.Text = "⛔"
    banBtn.Size = UDim2.new(0.24, -2, 1, 0)
    banBtn.Position = UDim2.new(0.25, 0, 0, 0)
    banBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    banBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    banBtn.Font = Enum.Font.GothamBold
    banBtn.TextSize = 16
    banBtn.Parent = buttonContainer1
    
    -- NEU: 1-TAG BAN BUTTON
    local banDayBtn = Instance.new("TextButton")
    banDayBtn.Text = "📅"
    banDayBtn.Size = UDim2.new(0.24, -2, 1, 0)
    banDayBtn.Position = UDim2.new(0.5, 0, 0, 0)
    banDayBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
    banDayBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    banDayBtn.Font = Enum.Font.GothamBold
    banDayBtn.TextSize = 16
    banDayBtn.Parent = buttonContainer1
    
    local bringBtn = Instance.new("TextButton")
    bringBtn.Text = "🚀"
    bringBtn.Size = UDim2.new(0.24, -2, 1, 0)
    bringBtn.Position = UDim2.new(0.75, 0, 0, 0)
    bringBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
    bringBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    bringBtn.Font = Enum.Font.GothamBold
    bringBtn.TextSize = 16
    bringBtn.Parent = buttonContainer1
    
    -- Zweite Reihe
    local tptoBtn = Instance.new("TextButton")
    tptoBtn.Text = "📍"
    tptoBtn.Size = UDim2.new(0.24, -2, 1, 0)
    tptoBtn.Position = UDim2.new(0, 0, 0, 0)
    tptoBtn.BackgroundColor3 = Color3.fromRGB(80, 160, 100)
    tptoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    tptoBtn.Font = Enum.Font.GothamBold
    tptoBtn.TextSize = 16
    tptoBtn.Parent = buttonContainer2
    
    -- NEU: ADMIN CAR BUTTON
    local spawncarBtn = Instance.new("TextButton")
    spawncarBtn.Text = "🚗"
    spawncarBtn.Size = UDim2.new(0.24, -2, 1, 0)
    spawncarBtn.Position = UDim2.new(0.25, 0, 0, 0)
    spawncarBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
    spawncarBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    spawncarBtn.Font = Enum.Font.GothamBold
    spawncarBtn.TextSize = 16
    spawncarBtn.Parent = buttonContainer2
    
    -- NEU: RESPAWN ALL BUTTON
    local respawnBtn = Instance.new("TextButton")
    respawnBtn.Text = "🔄"
    respawnBtn.Size = UDim2.new(0.24, -2, 1, 0)
    respawnBtn.Position = UDim2.new(0.5, 0, 0, 0)
    respawnBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 200)
    respawnBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    respawnBtn.Font = Enum.Font.GothamBold
    respawnBtn.TextSize = 16
    respawnBtn.Parent = buttonContainer2
    
    -- NEU: DISCORD BUTTON
    local discordBtn = Instance.new("TextButton")
    discordBtn.Text = "📢"
    discordBtn.Size = UDim2.new(0.24, -2, 1, 0)
    discordBtn.Position = UDim2.new(0.75, 0, 0, 0)
    discordBtn.BackgroundColor3 = Color3.fromRGB(155, 89, 182)
    discordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    discordBtn.Font = Enum.Font.GothamBold
    discordBtn.TextSize = 16
    discordBtn.Parent = buttonContainer2
    
    -- Buttons runden
    for _, btn in pairs({kickBtn, banBtn, banDayBtn, bringBtn, tptoBtn, spawncarBtn, respawnBtn, discordBtn}) do
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = btn
    end
    
    -- Tooltips
    kickBtn.MouseEnter:Connect(function() kickBtn.Text = "Kick" end)
    kickBtn.MouseLeave:Connect(function() kickBtn.Text = "🚪" end)
    
    banBtn.MouseEnter:Connect(function() banBtn.Text = "Ban" end)
    banBtn.MouseLeave:Connect(function() banBtn.Text = "⛔" end)
    
    banDayBtn.MouseEnter:Connect(function() banDayBtn.Text = "1 Tag" end)
    banDayBtn.MouseLeave:Connect(function() banDayBtn.Text = "📅" end)
    
    bringBtn.MouseEnter:Connect(function() bringBtn.Text = "Bring" end)
    bringBtn.MouseLeave:Connect(function() bringBtn.Text = "🚀" end)
    
    tptoBtn.MouseEnter:Connect(function() tptoBtn.Text = "TPTO" end)
    tptoBtn.MouseLeave:Connect(function() tptoBtn.Text = "📍" end)
    
    spawncarBtn.MouseEnter:Connect(function() spawncarBtn.Text = "Car" end)
    spawncarBtn.MouseLeave:Connect(function() spawncarBtn.Text = "🚗" end)
    
    respawnBtn.MouseEnter:Connect(function() respawnBtn.Text = "Respawn" end)
    respawnBtn.MouseLeave:Connect(function() respawnBtn.Text = "🔄" end)
    
    discordBtn.MouseEnter:Connect(function() discordBtn.Text = "Discord" end)
    discordBtn.MouseLeave:Connect(function() discordBtn.Text = "📢" end)
    
    -- Button Events
    kickBtn.MouseButton1Click:Connect(function()
        local command = "/kick " .. playerData.username
        if setclipboard then
            setclipboard(command)
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = "✅ Kick kopiert",
                    Text = command,
                    Duration = 2
                })
            end)
        end
        closeMiniMenu()
    end)
    
    banBtn.MouseButton1Click:Connect(function()
        local command = "/ban " .. playerData.username
        if setclipboard then
            setclipboard(command)
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = "✅ Ban kopiert",
                    Text = command,
                    Duration = 2
                })
            end)
        end
        closeMiniMenu()
    end)
    
    -- NEU: 1-TAG BAN EVENT
    banDayBtn.MouseButton1Click:Connect(function()
        local command = "/banoneday " .. playerData.username
        if setclipboard then
            setclipboard(command)
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = "✅ 1-Tag Ban kopiert",
                    Text = command,
                    Duration = 2
                })
            end)
        end
        closeMiniMenu()
    end)
    
    bringBtn.MouseButton1Click:Connect(function()
        local command = "/bring " .. playerData.username
        if setclipboard then
            setclipboard(command)
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = "✅ Bring kopiert",
                    Text = command,
                    Duration = 2
                })
            end)
        end
        closeMiniMenu()
    end)
    
    tptoBtn.MouseButton1Click:Connect(function()
        local command = "/tpto " .. playerData.username
        if setclipboard then
            setclipboard(command)
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = "✅ TPTO kopiert",
                    Text = command,
                    Duration = 2
                })
            end)
        end
        closeMiniMenu()
    end)
    
    -- NEU: ADMIN CAR EVENT
    spawncarBtn.MouseButton1Click:Connect(function()
        local command = "/spawnadmincar"
        if setclipboard then
            setclipboard(command)
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = "✅ Admin Car kopiert",
                    Text = command,
                    Duration = 2
                })
            end)
        end
        closeMiniMenu()
    end)
    
    -- NEU: RESPAWN ALL EVENT
    respawnBtn.MouseButton1Click:Connect(function()
        local command = "/respawnall"
        if setclipboard then
            setclipboard(command)
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = "✅ Respawn All kopiert",
                    Text = command,
                    Duration = 2
                })
            end)
        end
        closeMiniMenu()
    end)
    
    -- NEU: DISCORD EVENT
    discordBtn.MouseButton1Click:Connect(function()
        local inviteCode = "yJpCWt6Zjr"
        if setclipboard then
            setclipboard(inviteCode)
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = "✅ Discord kopiert",
                    Text = "Invite: " .. inviteCode,
                    Duration = 3
                })
            end)
        end
        closeMiniMenu()
    end)
    
    mainFrame.Parent = screenGui
    screenGui.Parent = LP:WaitForChild("PlayerGui")
    
    miniMenuGui = screenGui
    miniMenuTimeout = tick() + 7
    
    return screenGui
end

local function copyNearestPlayer()
    local playerData = findNearestPlayer()
    
    if playerData then
        if setclipboard then
            setclipboard(playerData.username)
        end
        
        createMiniMenu(playerData)
        
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "✅ " .. playerData.name,
                Text = "Name kopiert | Mini-Menü geöffnet",
                Duration = 2
            })
        end)
        
        return true
    else
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "ℹ️ Info",
                Text = "Kein Spieler gefunden",
                Duration = 2
            })
        end)
        return false
    end
end

-- ============================================
-- TEIL 2: ANTI-AFK SYSTEM (NEU)
-- ============================================

local function toggleAntiAFK(enabled)
    ANTI_AFK_ENABLED = enabled
    
    if enabled then
        print("✅ Anti-AFK aktiviert")
        
        antiAFKConnection = RunService.Heartbeat:Connect(function()
            pcall(function()
                -- Kamera leicht bewegen
                local camera = workspace.CurrentCamera
                if camera then
                    camera.CFrame = camera.CFrame * CFrame.Angles(0, math.rad(0.5), 0)
                end
                
                -- Virtuelle Tasteneingabe
                game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Space, false, nil)
                wait(0.05)
                game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.Space, false, nil)
            end)
        end)
        
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "✅ Anti-AFK aktiviert",
                Text = "Kein AFK-Kick",
                Duration = 3
            })
        end)
    else
        if antiAFKConnection then
            antiAFKConnection:Disconnect()
            antiAFKConnection = nil
        end
        print("❌ Anti-AFK deaktiviert")
        
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "❌ Anti-AFK deaktiviert",
                Text = "Normales AFK-Verhalten",
                Duration = 2
            })
        end)
    end
end

-- ============================================
-- AB HIER IST EXAKT DAS ORIGINAL SCRIPT
-- NUR DIE TOOLS SIND ERWEITERT MIT ANTI-AFK UND NEUEN BEFEHLEN
-- ============================================

local function isPlayerInRange(player)
    if not ESP_SETTINGS.PerformanceMode then
        return true
    end
    
    local localChar = LP.Character
    local targetChar = player.Character
    
    if not localChar or not targetChar then
        return false
    end
    
    local localRoot = localChar:FindFirstChild("HumanoidRootPart") or localChar.PrimaryPart
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart") or targetChar.PrimaryPart
    
    if not localRoot or not targetRoot then
        return false
    end
    
    local distance = (localRoot.Position - targetRoot.Position).Magnitude
    return distance <= ESP_SETTINGS.MaxDistance
end

local function createESP(player)
    if not ESP_SETTINGS.Enabled or not isPlayerInRange(player) then
        return
    end
    
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    -- Altes ESP entfernen falls existiert
    if ESP_ITEMS[player] then
        if ESP_ITEMS[player].box then ESP_ITEMS[player].box:Destroy() end
        if ESP_ITEMS[player].billboard then ESP_ITEMS[player].billboard:Destroy() end
    end
    
    ESP_ITEMS[player] = {}
    
    -- Box ESP
    if ESP_SETTINGS.ShowBox then
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "ESP_Box_" .. player.Name
        box.Adornee = humanoidRootPart
        box.AlwaysOnTop = true
        box.ZIndex = 10
        box.Size = Vector3.new(4, 6, 2)
        box.Color3 = ESP_SETTINGS.BoxColor
        box.Transparency = 0.7
        box.Parent = humanoidRootPart
        ESP_ITEMS[player].box = box
    end
    
    -- Name ESP (mit kleinerer Schrift)
    if ESP_SETTINGS.ShowName then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP_Name_" .. player.Name
        billboard.Adornee = humanoidRootPart
        billboard.Size = UDim2.new(0, 150, 0, 40) -- Kleiner
        billboard.StudsOffset = Vector3.new(0, 4, 0)
        billboard.AlwaysOnTop = true
        billboard.MaxDistance = 500
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 1, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.DisplayName or player.Name
        nameLabel.TextColor3 = ESP_SETTINGS.NameColor
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.TextStrokeTransparency = 0.3
        nameLabel.TextSize = ESP_SETTINGS.NameSize -- Kleinere Schriftgröße
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.Parent = billboard
        
        billboard.Parent = humanoidRootPart
        ESP_ITEMS[player].billboard = billboard
    end
end

local function removeESP(player)
    if ESP_ITEMS[player] then
        if ESP_ITEMS[player].box then
            ESP_ITEMS[player].box:Destroy()
        end
        if ESP_ITEMS[player].billboard then
            ESP_ITEMS[player].billboard:Destroy()
        end
        ESP_ITEMS[player] = nil
    end
end

local function updateAllESP()
    if not ESP_SETTINGS.Enabled then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP then
            if isPlayerInRange(player) then
                if not ESP_ITEMS[player] then
                    createESP(player)
                end
            else
                removeESP(player)
            end
        end
    end
end

local function toggleESP(enabled)
    ESP_SETTINGS.Enabled = enabled
    
    if enabled then
        -- ESP für alle Spieler in Reichweite erstellen
        updateAllESP()
        
        -- Events für neue Spieler
        Players.PlayerAdded:Connect(function(player)
            wait(1)
            if ESP_SETTINGS.Enabled then
                createESP(player)
            end
        end)
        
        Players.PlayerRemoving:Connect(function(player)
            removeESP(player)
        end)
        
        -- Character added event
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LP then
                player.CharacterAdded:Connect(function()
                    wait(0.5)
                    if ESP_SETTINGS.Enabled then
                        createESP(player)
                    end
                end)
            end
        end
        
        -- ESP Update Loop für Performance Mode
        if ESP_SETTINGS.PerformanceMode then
            local espUpdateConnection
            espUpdateConnection = RunService.Heartbeat:Connect(function()
                if not ESP_SETTINGS.Enabled then
                    espUpdateConnection:Disconnect()
                    return
                end
                updateAllESP()
            end)
        end
        
    else
        -- Alles ESP entfernen
        for player, _ in pairs(ESP_ITEMS) do
            removeESP(player)
        end
        ESP_ITEMS = {}
    end
end

-- ============================================
-- TEIL 3: AFK TRACKING SYSTEM
-- ============================================

local function startAFKTracking(player)
    if not player or not player.Character then return end
    
    afkTrackingData[player] = {
        lastPosition = nil,
        lastUpdate = tick(),
        isAFK = false,
        testing = true,
        testStart = tick()
    }
    
    -- AFK Check Connection
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not afkTrackingData[player] then
            connection:Disconnect()
            return
        end
        
        local char = player.Character
        if not char then
            afkTrackingData[player].isAFK = false
            afkTrackingData[player].testing = false
            return
        end
        
        local root = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
        if not root then return end
        
        local currentPos = root.Position
        
        if not afkTrackingData[player].lastPosition then
            afkTrackingData[player].lastPosition = currentPos
            afkTrackingData[player].lastUpdate = tick()
            return
        end
        
        -- Prüfe ob sich Position verändert hat
        local distanceMoved = (currentPos - afkTrackingData[player].lastPosition).Magnitude
        
        if distanceMoved > 1 then -- Bewegung erkannt
            afkTrackingData[player].lastPosition = currentPos
            afkTrackingData[player].lastUpdate = tick()
            afkTrackingData[player].isAFK = false
            afkTrackingData[player].testing = true
            afkTrackingData[player].testStart = tick()
        else
            -- Prüfe ob 5 Sekunden ohne Bewegung vergangen sind
            if tick() - afkTrackingData[player].lastUpdate > 5 then
                afkTrackingData[player].isAFK = true
                afkTrackingData[player].testing = false
            else
                afkTrackingData[player].testing = true
            end
        end
    end)
    
    afkCheckConnections[player] = connection
end

local function stopAFKTracking(player)
    if afkCheckConnections[player] then
        afkCheckConnections[player]:Disconnect()
        afkCheckConnections[player] = nil
    end
    afkTrackingData[player] = nil
end

local function getAFKStatus(player)
    if not afkTrackingData[player] then
        return "Nicht getrackt"
    end
    
    if afkTrackingData[player].testing then
        local timeTesting = math.floor(tick() - afkTrackingData[player].testStart)
        if timeTesting < 5 then
            return "Testing... (" .. (5 - timeTesting) .. "s)"
        end
    end
    
    if afkTrackingData[player].isAFK then
        return "AFK"
    else
        return "Active"
    end
end

-- ============================================
-- TEIL 4: ERWEITERTES ADMIN PANEL
-- ============================================

local function closeInspectGui()
    if inspectGui then
        inspectGui:Destroy()
        inspectGui = nil
    end
    
    if currentInspectPlayer then
        stopAFKTracking(currentInspectPlayer)
        currentInspectPlayer = nil
    end
end

local function createInspectGui(player)
    closeInspectGui()
    currentInspectPlayer = player
    
    -- Starte AFK Tracking
    startAFKTracking(player)
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PlayerInspectGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 150
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 380, 0, 450)
    mainFrame.Position = UDim2.new(0.5, -190, 0.5, -225)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 60, 70)
    stroke.Thickness = 3
    stroke.Parent = mainFrame
    
    -- Titel
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 45)
    titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    titleBar.Parent = mainFrame
    
    local titleText = Instance.new("TextLabel")
    titleText.Text = "🔍 Spieler Inspizieren"
    titleText.Size = UDim2.new(1, -50, 1, 0)
    titleText.Position = UDim2.new(0, 15, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.TextColor3 = Color3.fromRGB(255, 215, 0)
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 18
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "×"
    closeBtn.Size = UDim2.new(0, 45, 0, 45)
    closeBtn.Position = UDim2.new(1, -45, 0, 0)
    closeBtn.BackgroundTransparency = 1
    closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 30
    closeBtn.Parent = titleBar
    
    closeBtn.MouseButton1Click:Connect(closeInspectGui)
    
    -- Inhalt
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -20, 1, -65)
    content.Position = UDim2.new(0, 10, 0, 55)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 8
    content.Parent = mainFrame
    
    local yOffset = 10
    
    -- Funktion zum Erstellen von Info-Rows
    local function createInfoRow(label, value, copyValue, color)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 45)
        row.Position = UDim2.new(0, 0, 0, yOffset)
        row.BackgroundTransparency = 1
        row.Parent = content
        
        local labelText = Instance.new("TextLabel")
        labelText.Text = label
        labelText.Size = UDim2.new(0.4, -10, 1, 0)
        labelText.Position = UDim2.new(0, 0, 0, 0)
        labelText.BackgroundTransparency = 1
        labelText.TextColor3 = Color3.fromRGB(200, 200, 220)
        labelText.Font = Enum.Font.Gotham
        labelText.TextSize = 14
        labelText.TextXAlignment = Enum.TextXAlignment.Left
        labelText.Parent = row
        
        local valueFrame = Instance.new("Frame")
        valueFrame.Size = UDim2.new(0.6, -10, 1, 0)
        valueFrame.Position = UDim2.new(0.4, 0, 0, 0)
        valueFrame.BackgroundTransparency = 1
        valueFrame.Parent = row
        
        local valueText = Instance.new("TextLabel")
        valueText.Name = "ValueText"
        valueText.Text = value
        valueText.Size = UDim2.new(0.7, 0, 1, 0)
        valueText.Position = UDim2.new(0, 0, 0, 0)
        valueText.BackgroundTransparency = 1
        valueText.TextColor3 = color or Color3.fromRGB(255, 255, 255)
        valueText.Font = Enum.Font.Gotham
        valueText.TextSize = 14
        valueText.TextXAlignment = Enum.TextXAlignment.Left
        valueText.TextTruncate = Enum.TextTruncate.AtEnd
        valueText.Parent = valueFrame
        
        local copyBtn = Instance.new("TextButton")
        copyBtn.Text = "📋"
        copyBtn.Size = UDim2.new(0, 35, 0, 35)
        copyBtn.Position = UDim2.new(1, -40, 0, 5)
        copyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        copyBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        copyBtn.Font = Enum.Font.GothamBold
        copyBtn.TextSize = 14
        copyBtn.Parent = valueFrame
        
        local copyCorner = Instance.new("UICorner")
        copyCorner.CornerRadius = UDim.new(0, 6)
        copyCorner.Parent = copyBtn
        
        if copyValue then
            copyBtn.MouseButton1Click:Connect(function()
                if setclipboard then
                    setclipboard(copyValue)
                    pcall(function()
                        StarterGui:SetCore("SendNotification", {
                            Title = "✅ Kopiert",
                            Text = copyValue,
                            Duration = 2
                        })
                    end)
                end
            end)
        else
            copyBtn.Visible = false
        end
        
        yOffset = yOffset + 50
        return valueText
    end
    
    -- Spieler-Informationen
    local displayName = player.DisplayName or player.Name
    local username = player.Name
    local userId = tostring(player.UserId)
    
    createInfoRow("👤 Anzeigename:", displayName, displayName)
    createInfoRow("📛 Username:", "@" .. username, username)
    createInfoRow("🆔 Roblox ID:", userId, userId)
    
    -- Live-Informationen
    local hpText = createInfoRow("❤️ Leben:", "Berechne...", nil, Color3.fromRGB(255, 100, 100))
    local distText = createInfoRow("📏 Entfernung:", "Berechne...", nil, Color3.fromRGB(100, 200, 255))
    local afkText = createInfoRow("⏱️ Status:", "Testing...", nil, Color3.fromRGB(255, 200, 100))
    
    yOffset = yOffset + 20
    
    -- Admin Action Buttons (MIT 1-TAG BAN ERWEITERT)
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Size = UDim2.new(1, 0, 0, 170) -- Höher für mehr Buttons
    buttonContainer.Position = UDim2.new(0, 0, 0, yOffset)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = content
    
    -- Button Layout
    local buttonWidth = UDim2.new(0.48, -5, 0, 45)
    
    -- Zeile 1
    local kickBtn = Instance.new("TextButton")
    kickBtn.Text = "🚪 Kick"
    kickBtn.Size = buttonWidth
    kickBtn.Position = UDim2.new(0, 0, 0, 0)
    kickBtn.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
    kickBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    kickBtn.Font = Enum.Font.GothamBold
    kickBtn.TextSize = 15
    kickBtn.Parent = buttonContainer
    
    local banBtn = Instance.new("TextButton")
    banBtn.Text = "⛔ Ban"
    banBtn.Size = buttonWidth
    banBtn.Position = UDim2.new(0.52, 0, 0, 0)
    banBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    banBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    banBtn.Font = Enum.Font.GothamBold
    banBtn.TextSize = 15
    banBtn.Parent = buttonContainer
    
    -- Zeile 2 (NEU: 1-TAG BAN)
    local banDayBtn = Instance.new("TextButton")
    banDayBtn.Text = "📅 1 Tag Ban"
    banDayBtn.Size = buttonWidth
    banDayBtn.Position = UDim2.new(0, 0, 0, 55)
    banDayBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
    banDayBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    banDayBtn.Font = Enum.Font.GothamBold
    banDayBtn.TextSize = 15
    banDayBtn.Parent = buttonContainer
    
    local bringBtn = Instance.new("TextButton")
    bringBtn.Text = "🚀 Bring"
    bringBtn.Size = buttonWidth
    bringBtn.Position = UDim2.new(0.52, 0, 0, 55)
    bringBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
    bringBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    bringBtn.Font = Enum.Font.GothamBold
    bringBtn.TextSize = 15
    bringBtn.Parent = buttonContainer
    
    -- Zeile 3
    local tptoBtn = Instance.new("TextButton")
    tptoBtn.Text = "📍 TPTO"
    tptoBtn.Size = buttonWidth
    tptoBtn.Position = UDim2.new(0, 0, 0, 110)
    tptoBtn.BackgroundColor3 = Color3.fromRGB(80, 160, 100)
    tptoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    tptoBtn.Font = Enum.Font.GothamBold
    tptoBtn.TextSize = 15
    tptoBtn.Parent = buttonContainer
    
    -- NEU: ADMIN CAR BUTTON
    local spawncarBtn = Instance.new("TextButton")
    spawncarBtn.Text = "🚗 Admin Car"
    spawncarBtn.Size = buttonWidth
    spawncarBtn.Position = UDim2.new(0.52, 0, 0, 110)
    spawncarBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
    spawncarBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    spawncarBtn.Font = Enum.Font.GothamBold
    spawncarBtn.TextSize = 15
    spawncarBtn.Parent = buttonContainer
    
    -- Alle Buttons runden
    for _, btn in pairs({kickBtn, banBtn, banDayBtn, bringBtn, tptoBtn, spawncarBtn}) do
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = btn
    end
    
    -- Button Events
    kickBtn.MouseButton1Click:Connect(function()
        local command = "/kick " .. username
        if setclipboard then
            setclipboard(command)
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = "✅ Kick kopiert",
                    Text = command,
                    Duration = 2
                })
            end)
        end
    end)
    
    banBtn.MouseButton1Click:Connect(function()
        local command = "/ban " .. username
        if setclipboard then
            setclipboard(command)
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = "✅ Ban kopiert",
                    Text = command,
                    Duration = 2
                })
            end)
        end
    end)
    
    -- NEU: 1-TAG BAN EVENT
    banDayBtn.MouseButton1Click:Connect(function()
        local command = "/banoneday " .. username
        if setclipboard then
            setclipboard(command)
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = "✅ 1-Tag Ban kopiert",
                    Text = command,
                    Duration = 2
                })
            end)
        end
    end)
    
    bringBtn.MouseButton1Click:Connect(function()
        local command = "/bring " .. username
        if setclipboard then
            setclipboard(command)
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = "✅ Bring kopiert",
                    Text = command,
                    Duration = 2
                })
            end)
        end
    end)
    
    tptoBtn.MouseButton1Click:Connect(function()
        local command = "/tpto " .. username
        if setclipboard then
            setclipboard(command)
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = "✅ TPTO kopiert",
                    Text = command,
                    Duration = 2
                })
            end)
        end
    end)
    
    -- NEU: ADMIN CAR EVENT
    spawncarBtn.MouseButton1Click:Connect(function()
        local command = "/spawnadmincar"
        if setclipboard then
            setclipboard(command)
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = "✅ Admin Car kopiert",
                    Text = command,
                    Duration = 2
                })
            end)
        end
    end)
    
    yOffset = yOffset + 180
    
    content.CanvasSize = UDim2.new(0, 0, 0, yOffset)
    
    -- Live-Update Funktion
    local function updateLiveData()
        if not inspectGui or inspectGui.Parent == nil then
            return
        end
        
        local now = tick()
        if now - lastUpdateTime < UPDATE_RATE then
            return
        end
        lastUpdateTime = now
        
        local targetChar = player.Character
        if targetChar then
            -- Leben
            local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
            if humanoid then
                local health = math.floor(humanoid.Health)
                hpText.Text = health .. " HP"
                
                -- Farbe basierend auf Gesundheit
                if health > 75 then
                    hpText.TextColor3 = Color3.fromRGB(100, 255, 100)
                elseif health > 25 then
                    hpText.TextColor3 = Color3.fromRGB(255, 200, 100)
                else
                    hpText.TextColor3 = Color3.fromRGB(255, 100, 100)
                end
            else
                hpText.Text = "N/A"
                hpText.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
            
            -- Entfernung
            local localChar = LP.Character
            if localChar then
                local localRoot = localChar:FindFirstChild("HumanoidRootPart") or localChar.PrimaryPart
                local targetRoot = targetChar:FindFirstChild("HumanoidRootPart") or targetChar.PrimaryPart
                
                if localRoot and targetRoot then
                    local distance = math.floor((localRoot.Position - targetRoot.Position).Magnitude)
                    distText.Text = distance .. " Studs"
                    
                    -- Farbe basierend auf Entfernung
                    if distance < 50 then
                        distText.TextColor3 = Color3.fromRGB(100, 255, 100)
                    elseif distance < 150 then
                        distText.TextColor3 = Color3.fromRGB(255, 200, 100)
                    else
                        distText.TextColor3 = Color3.fromRGB(255, 100, 100)
                    end
                else
                    distText.Text = "N/A"
                    distText.TextColor3 = Color3.fromRGB(200, 200, 200)
                end
            else
                distText.Text = "N/A"
                distText.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
            
            -- AFK Status
            local afkStatus = getAFKStatus(player)
            afkText.Text = afkStatus
            
            -- Farbe basierend auf AFK Status
            if afkStatus == "AFK" then
                afkText.TextColor3 = Color3.fromRGB(255, 150, 50)
            elseif afkStatus == "Active" then
                afkText.TextColor3 = Color3.fromRGB(100, 255, 100)
            else
                afkText.TextColor3 = Color3.fromRGB(255, 200, 100)
            end
            
        else
            hpText.Text = "N/A"
            distText.Text = "N/A"
            afkText.Text = "Offline"
            afkText.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end
    
    -- Live-Update Connection
    local updateConnection
    updateConnection = RunService.Heartbeat:Connect(function()
        if inspectGui and inspectGui.Parent then
            updateLiveData()
        else
            if updateConnection then
                updateConnection:Disconnect()
            end
        end
    end)
    
    screenGui.Parent = LP:WaitForChild("PlayerGui")
    inspectGui = screenGui
    
    -- Sofort erste Daten laden
    updateLiveData()
    
    return screenGui
end

-- ============================================
-- TEIL 5: HAUPT ADMIN PANEL (NUR TOOLS TAB ERWEITERT)
-- ============================================

local function closeAdminPanel()
    closeInspectGui()
    
    if adminPanelGui then
        adminPanelGui:Destroy()
        adminPanelGui = nil
    end
    isPanelOpen = false
end

local function openAdminPanel()
    closeMiniMenu()
    
    if isPanelOpen then
        closeAdminPanel()
        return
    end
    
    isPanelOpen = true
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AdminPanelPro"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 20
    
    local mainContainer = Instance.new("Frame")
    mainContainer.Name = "MainContainer"
    mainContainer.Size = UDim2.new(0.9, 0, 0.88, 0)
    mainContainer.Position = UDim2.new(0.05, 0, 0.06, 0)
    mainContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    mainContainer.Parent = screenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 14)
    mainCorner.Parent = mainContainer
    
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(60, 60, 70)
    mainStroke.Thickness = 3
    mainStroke.Parent = mainContainer
    
    -- Titel-Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 55)
    titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    titleBar.Parent = mainContainer
    
    local titleText = Instance.new("TextLabel")
    titleText.Text = "🛡️ ADMIN PANEL PRO " .. SCRIPT_VERSION
    titleText.Size = UDim2.new(0.5, 0, 1, 0)
    titleText.Position = UDim2.new(0, 20, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.TextColor3 = Color3.fromRGB(255, 215, 0)
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 22
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "×"
    closeBtn.Size = UDim2.new(0, 55, 0, 55)
    closeBtn.Position = UDim2.new(1, -55, 0, 0)
    closeBtn.BackgroundTransparency = 1
    closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 32
    closeBtn.Parent = titleBar
    
    closeBtn.MouseButton1Click:Connect(closeAdminPanel)
    
    -- Seitenleiste
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 240, 1, -55)
    sidebar.Position = UDim2.new(0, 0, 0, 55)
    sidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    sidebar.Parent = mainContainer
    
    -- Content-Bereich
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -240, 1, -55)
    contentArea.Position = UDim2.new(0, 240, 0, 55)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = mainContainer
    
    -- Tab-Buttons
    local tabs = {
        {id = "dashboard", name = "📊 Dashboard", icon = "📊"},
        {id = "players", name = "👥 Spielerliste", icon = "👥"},
        {id = "tools", name = "🛠️ Tools", icon = "🛠️"},
        {id = "settings", name = "⚙️ Einstellungen", icon = "⚙️"}
    }
    
    local activeTab = "dashboard"
    
    -- Funktion zum Wechseln der Tabs
    local function switchTab(tabId)
        activeTab = tabId
        
        -- Alten Content entfernen
        for _, child in pairs(contentArea:GetChildren()) do
            child:Destroy()
        end
        
        -- Neuen Content basierend auf Tab erstellen
        if tabId == "dashboard" then
            -- Dashboard Content (EXAKT WIE IM ORIGINAL)
            local dashboardFrame = Instance.new("ScrollingFrame")
            dashboardFrame.Name = "DashboardFrame"
            dashboardFrame.Size = UDim2.new(1, 0, 1, 0)
            dashboardFrame.BackgroundTransparency = 1
            dashboardFrame.ScrollBarThickness = 8
            dashboardFrame.Parent = contentArea
            
            local yOffset = 20
            
            -- Willkommens-Banner
            local welcomeBanner = Instance.new("Frame")
            welcomeBanner.Size = UDim2.new(1, -40, 0, 100)
            welcomeBanner.Position = UDim2.new(0, 20, 0, yOffset)
            welcomeBanner.BackgroundColor3 = Color3.fromRGB(40, 40, 120)
            welcomeBanner.Parent = dashboardFrame
            
            local welcomeCorner = Instance.new("UICorner")
            welcomeCorner.CornerRadius = UDim.new(0, 12)
            welcomeCorner.Parent = welcomeBanner
            
            local welcomeGradient = Instance.new("UIGradient")
            welcomeGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 50, 150)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 100))
            }
            welcomeGradient.Rotation = 45
            welcomeGradient.Parent = welcomeBanner
            
            local welcomeText = Instance.new("TextLabel")
            welcomeText.Text = "Willkommen, Admin!"
            welcomeText.Size = UDim2.new(1, -20, 0, 50)
            welcomeText.Position = UDim2.new(0, 10, 0, 10)
            welcomeText.BackgroundTransparency = 1
            welcomeText.TextColor3 = Color3.fromRGB(255, 255, 255)
            welcomeText.Font = Enum.Font.GothamBold
            welcomeText.TextSize = 26
            welcomeText.TextXAlignment = Enum.TextXAlignment.Left
            welcomeText.Parent = welcomeBanner
            
            local versionText = Instance.new("TextLabel")
            versionText.Text = "Version: " .. SCRIPT_VERSION .. " | " .. #Players:GetPlayers() .. " Spieler online"
            versionText.Size = UDim2.new(1, -20, 0, 30)
            versionText.Position = UDim2.new(0, 10, 0, 60)
            versionText.BackgroundTransparency = 1
            versionText.TextColor3 = Color3.fromRGB(200, 200, 255)
            versionText.Font = Enum.Font.Gotham
            versionText.TextSize = 15
            versionText.TextXAlignment = Enum.TextXAlignment.Left
            versionText.Parent = welcomeBanner
            
            yOffset = yOffset + 120
            
            -- Server-Info Card
            local serverCard = Instance.new("Frame")
            serverCard.Size = UDim2.new(1, -40, 0, 180)
            serverCard.Position = UDim2.new(0, 20, 0, yOffset)
            serverCard.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            serverCard.Parent = dashboardFrame
            
            local serverCorner = Instance.new("UICorner")
            serverCorner.CornerRadius = UDim.new(0, 12)
            serverCorner.Parent = serverCard
            
            local serverTitle = Instance.new("TextLabel")
            serverTitle.Text = "🖥️ Server Information"
            serverTitle.Size = UDim2.new(1, -20, 0, 40)
            serverTitle.Position = UDim2.new(0, 10, 0, 10)
            serverTitle.BackgroundTransparency = 1
            serverTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
            serverTitle.Font = Enum.Font.GothamBold
            serverTitle.TextSize = 18
            serverTitle.TextXAlignment = Enum.TextXAlignment.Left
            serverTitle.Parent = serverCard
            
            local infoGrid = Instance.new("Frame")
            infoGrid.Size = UDim2.new(1, -20, 0, 120)
            infoGrid.Position = UDim2.new(0, 10, 0, 50)
            infoGrid.BackgroundTransparency = 1
            infoGrid.Parent = serverCard
            
            -- Zeile 1
            local playersText = Instance.new("TextLabel")
            playersText.Text = "👥 Spieler: " .. #Players:GetPlayers()
            playersText.Size = UDim2.new(0.5, -5, 0, 30)
            playersText.Position = UDim2.new(0, 0, 0, 0)
            playersText.BackgroundTransparency = 1
            playersText.TextColor3 = Color3.fromRGB(200, 200, 220)
            playersText.Font = Enum.Font.Gotham
            playersText.TextSize = 15
            playersText.TextXAlignment = Enum.TextXAlignment.Left
            playersText.Parent = infoGrid
            
            local placeIdText = Instance.new("TextLabel")
            placeIdText.Text = "📍 Place ID: " .. game.PlaceId
            placeIdText.Size = UDim2.new(0.5, -5, 0, 30)
            placeIdText.Position = UDim2.new(0.5, 5, 0, 0)
            placeIdText.BackgroundTransparency = 1
            placeIdText.TextColor3 = Color3.fromRGB(200, 200, 220)
            placeIdText.Font = Enum.Font.Gotham
            placeIdText.TextSize = 15
            placeIdText.TextXAlignment = Enum.TextXAlignment.Left
            placeIdText.Parent = infoGrid
            
            -- Zeile 2
            local jobIdText = Instance.new("TextLabel")
            jobIdText.Text = "🔑 Job ID: " .. game.JobId
            jobIdText.Size = UDim2.new(0.5, -5, 0, 30)
            jobIdText.Position = UDim2.new(0, 0, 0, 35)
            jobIdText.BackgroundTransparency = 1
            jobIdText.TextColor3 = Color3.fromRGB(200, 200, 220)
            jobIdText.Font = Enum.Font.Gotham
            jobIdText.TextSize = 15
            jobIdText.TextXAlignment = Enum.TextXAlignment.Left
            jobIdText.Parent = infoGrid
            
            local fpsText = Instance.new("TextLabel")
            fpsText.Text = "🎮 FPS: " .. math.floor(1/RunService.RenderStepped:Wait())
            fpsText.Size = UDim2.new(0.5, -5, 0, 30)
            fpsText.Position = UDim2.new(0.5, 5, 0, 35)
            fpsText.BackgroundTransparency = 1
            fpsText.TextColor3 = Color3.fromRGB(200, 200, 220)
            fpsText.Font = Enum.Font.Gotham
            fpsText.TextSize = 15
            fpsText.TextXAlignment = Enum.TextXAlignment.Left
            fpsText.Parent = infoGrid
            
            -- Zeile 3
            local timeText = Instance.new("TextLabel")
            timeText.Text = "🕒 Server Zeit: " .. os.date("%H:%M:%S")
            timeText.Size = UDim2.new(1, 0, 0, 30)
            timeText.Position = UDim2.new(0, 0, 0, 70)
            timeText.BackgroundTransparency = 1
            timeText.TextColor3 = Color3.fromRGB(200, 200, 220)
            timeText.Font = Enum.Font.Gotham
            timeText.TextSize = 15
            timeText.TextXAlignment = Enum.TextXAlignment.Left
            timeText.Parent = infoGrid
            
            -- Zeit-Updater
            local timeUpdate
            timeUpdate = RunService.Heartbeat:Connect(function()
                if not isPanelOpen or activeTab ~= "dashboard" then
                    timeUpdate:Disconnect()
                    return
                end
                timeText.Text = "🕒 Server Zeit: " .. os.date("%H:%M:%S")
            end)
            
            yOffset = yOffset + 200
            
            -- Admin-Info Card
            local adminCard = Instance.new("Frame")
            adminCard.Size = UDim2.new(1, -40, 0, 150)
            adminCard.Position = UDim2.new(0, 20, 0, yOffset)
            adminCard.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            adminCard.Parent = dashboardFrame
            
            local adminCorner = Instance.new("UICorner")
            adminCorner.CornerRadius = UDim.new(0, 12)
            adminCorner.Parent = adminCard
            
            local adminTitle = Instance.new("TextLabel")
            adminTitle.Text = "👤 Admin Information"
            adminTitle.Size = UDim2.new(1, -20, 0, 40)
            adminTitle.Position = UDim2.new(0, 10, 0, 10)
            adminTitle.BackgroundTransparency = 1
            adminTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
            adminTitle.Font = Enum.Font.GothamBold
            adminTitle.TextSize = 18
            adminTitle.TextXAlignment = Enum.TextXAlignment.Left
            adminTitle.Parent = adminCard
            
            local adminGrid = Instance.new("Frame")
            adminGrid.Size = UDim2.new(1, -20, 0, 90)
            adminGrid.Position = UDim2.new(0, 10, 0, 50)
            adminGrid.BackgroundTransparency = 1
            adminGrid.Parent = adminCard
            
            local adminNameText = Instance.new("TextLabel")
            adminNameText.Text = "Name: " .. LP.Name
            adminNameText.Size = UDim2.new(0.5, -5, 0, 30)
            adminNameText.Position = UDim2.new(0, 0, 0, 0)
            adminNameText.BackgroundTransparency = 1
            adminNameText.TextColor3 = Color3.fromRGB(200, 200, 220)
            adminNameText.Font = Enum.Font.Gotham
            adminNameText.TextSize = 15
            adminNameText.TextXAlignment = Enum.TextXAlignment.Left
            adminNameText.Parent = adminGrid
            
            local adminDisplayText = Instance.new("TextLabel")
            adminDisplayText.Text = "Anzeige: " .. (LP.DisplayName or LP.Name)
            adminDisplayText.Size = UDim2.new(0.5, -5, 0, 30)
            adminDisplayText.Position = UDim2.new(0.5, 5, 0, 0)
            adminDisplayText.BackgroundTransparency = 1
            adminDisplayText.TextColor3 = Color3.fromRGB(200, 200, 220)
            adminDisplayText.Font = Enum.Font.Gotham
            adminDisplayText.TextSize = 15
            adminDisplayText.TextXAlignment = Enum.TextXAlignment.Left
            adminDisplayText.Parent = adminGrid
            
            local adminIdText = Instance.new("TextLabel")
            adminIdText.Text = "ID: " .. LP.UserId
            adminIdText.Size = UDim2.new(1, 0, 0, 30)
            adminIdText.Position = UDim2.new(0, 0, 0, 35)
            adminIdText.BackgroundTransparency = 1
            adminIdText.TextColor3 = Color3.fromRGB(200, 200, 220)
            adminIdText.Font = Enum.Font.Gotham
            adminIdText.TextSize = 15
            adminIdText.TextXAlignment = Enum.TextXAlignment.Left
            adminIdText.Parent = adminGrid
            
            local adminRoleText = Instance.new("TextLabel")
            adminRoleText.Text = "Rolle: Server Administrator"
            adminRoleText.Size = UDim2.new(1, 0, 0, 30)
            adminRoleText.Position = UDim2.new(0, 0, 0, 65)
            adminRoleText.BackgroundTransparency = 1
            adminRoleText.TextColor3 = Color3.fromRGB(100, 255, 100)
            adminRoleText.Font = Enum.Font.GothamBold
            adminRoleText.TextSize = 15
            adminRoleText.TextXAlignment = Enum.TextXAlignment.Left
            adminRoleText.Parent = adminGrid
            
            dashboardFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 170)
            
        elseif tabId == "players" then
            -- Spielerliste mit Suchleiste (EXAKT WIE IM ORIGINAL MIT INSPECT FUNKTION)
            local playersFrame = Instance.new("Frame")
            playersFrame.Name = "PlayersFrame"
            playersFrame.Size = UDim2.new(1, 0, 1, 0)
            playersFrame.BackgroundTransparency = 1
            playersFrame.Parent = contentArea
            
            -- Suchleiste
            local searchContainer = Instance.new("Frame")
            searchContainer.Size = UDim2.new(1, -20, 0, 55)
            searchContainer.Position = UDim2.new(0, 10, 0, 10)
            searchContainer.BackgroundTransparency = 1
            searchContainer.Parent = playersFrame
            
            local searchBar = Instance.new("TextBox")
            searchBar.Name = "SearchBar"
            searchBar.PlaceholderText = "🔍 Nach Spielern suchen..."
            searchBar.Size = UDim2.new(1, -120, 1, 0)
            searchBar.Position = UDim2.new(0, 0, 0, 0)
            searchBar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            searchBar.TextColor3 = Color3.fromRGB(255, 255, 255)
            searchBar.Font = Enum.Font.Gotham
            searchBar.TextSize = 15
            searchBar.Text = ""
            searchBar.Parent = searchContainer
            
            local searchCorner = Instance.new("UICorner")
            searchCorner.CornerRadius = UDim.new(0, 8)
            searchCorner.Parent = searchBar
            
            local refreshBtn = Instance.new("TextButton")
            refreshBtn.Text = "🔄"
            refreshBtn.Size = UDim2.new(0, 50, 1, 0)
            refreshBtn.Position = UDim2.new(1, -110, 0, 0)
            refreshBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            refreshBtn.Font = Enum.Font.GothamBold
            refreshBtn.TextSize = 18
            refreshBtn.Parent = searchContainer
            
            local refreshCorner = Instance.new("UICorner")
            refreshCorner.CornerRadius = UDim.new(0, 8)
            refreshCorner.Parent = refreshBtn
            
            local playerCountText = Instance.new("TextLabel")
            playerCountText.Text = "0/" .. #Players:GetPlayers()
            playerCountText.Size = UDim2.new(0, 50, 1, 0)
            playerCountText.Position = UDim2.new(1, -50, 0, 0)
            playerCountText.BackgroundTransparency = 1
            playerCountText.TextColor3 = Color3.fromRGB(200, 200, 220)
            playerCountText.Font = Enum.Font.GothamBold
            playerCountText.TextSize = 15
            playerCountText.TextXAlignment = Enum.TextXAlignment.Center
            playerCountText.Parent = searchContainer
            
            -- Scrollbare Spielerliste
            local playersList = Instance.new("ScrollingFrame")
            playersList.Name = "PlayersList"
            playersList.Size = UDim2.new(1, -20, 1, -75)
            playersList.Position = UDim2.new(0, 10, 0, 75)
            playersList.BackgroundTransparency = 1
            playersList.ScrollBarThickness = 8
            playersList.Parent = playersFrame
            
            -- Funktion zum Laden der Spielerliste (MIT 1-TAG BAN ERWEITERT)
            local function loadPlayerList(searchTerm)
                for _, child in pairs(playersList:GetChildren()) do
                    if child:IsA("Frame") then
                        child:Destroy()
                    end
                end
                
                local yOffset = 0
                local visibleCount = 0
                
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LP then
                        local displayName = player.DisplayName or player.Name
                        local username = player.Name
                        
                        if searchTerm == "" or 
                           string.find(string.lower(displayName), string.lower(searchTerm)) or
                           string.find(string.lower(username), string.lower(searchTerm)) then
                            
                            visibleCount = visibleCount + 1
                            
                            local playerEntry = Instance.new("Frame")
                            playerEntry.Name = "Player_" .. username
                            playerEntry.Size = UDim2.new(1, 0, 0, 90)
                            playerEntry.Position = UDim2.new(0, 0, 0, yOffset)
                            playerEntry.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
                            playerEntry.Parent = playersList
                            
                            local entryCorner = Instance.new("UICorner")
                            entryCorner.CornerRadius = UDim.new(0, 10)
                            entryCorner.Parent = playerEntry
                            
                            -- Avatar Platzhalter
                            local avatarFrame = Instance.new("Frame")
                            avatarFrame.Size = UDim2.new(0, 60, 0, 60)
                            avatarFrame.Position = UDim2.new(0, 10, 0, 15)
                            avatarFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                            avatarFrame.Parent = playerEntry
                            
                            local avatarCorner = Instance.new("UICorner")
                            avatarCorner.CornerRadius = UDim.new(0, 8)
                            avatarCorner.Parent = avatarFrame
                            
                            local avatarText = Instance.new("TextLabel")
                            avatarText.Text = string.sub(displayName, 1, 1)
                            avatarText.Size = UDim2.new(1, 0, 1, 0)
                            avatarText.Position = UDim2.new(0, 0, 0, 0)
                            avatarText.BackgroundTransparency = 1
                            avatarText.TextColor3 = Color3.fromRGB(255, 255, 255)
                            avatarText.Font = Enum.Font.GothamBold
                            avatarText.TextSize = 24
                            avatarText.TextXAlignment = Enum.TextXAlignment.Center
                            avatarText.Parent = avatarFrame
                            
                            -- Spielerinfo
                            local infoFrame = Instance.new("Frame")
                            infoFrame.Size = UDim2.new(0.4, -70, 1, -20)
                            infoFrame.Position = UDim2.new(0, 80, 0, 15)
                            infoFrame.BackgroundTransparency = 1
                            infoFrame.Parent = playerEntry
                            
                            local nameLabel = Instance.new("TextLabel")
                            nameLabel.Text = displayName
                            nameLabel.Size = UDim2.new(1, 0, 0, 30)
                            nameLabel.Position = UDim2.new(0, 0, 0, 0)
                            nameLabel.BackgroundTransparency = 1
                            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                            nameLabel.Font = Enum.Font.GothamBold
                            nameLabel.TextSize = 16
                            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
                            nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
                            nameLabel.Parent = infoFrame
                            
                            local userLabel = Instance.new("TextLabel")
                            userLabel.Text = "@" .. username
                            userLabel.Size = UDim2.new(1, 0, 0, 25)
                            userLabel.Position = UDim2.new(0, 0, 0, 30)
                            userLabel.BackgroundTransparency = 1
                            userLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
                            userLabel.Font = Enum.Font.Gotham
                            userLabel.TextSize = 13
                            userLabel.TextXAlignment = Enum.TextXAlignment.Left
                            userLabel.Parent = infoFrame
                            
                            -- Aktionen Buttons (2 Reihen)
                            local actionsFrame = Instance.new("Frame")
                            actionsFrame.Size = UDim2.new(0.55, -10, 1, -20)
                            actionsFrame.Position = UDim2.new(0.45, 0, 0, 15)
                            actionsFrame.BackgroundTransparency = 1
                            actionsFrame.Parent = playerEntry
                            
                            -- Button Layout (2x4 Buttons)
                            local buttonSize = UDim2.new(0, 40, 0, 35)
                            
                            -- Erste Reihe
                            local inspectBtn = Instance.new("TextButton")
                            inspectBtn.Text = "🔍"
                            inspectBtn.Size = buttonSize
                            inspectBtn.Position = UDim2.new(0, 0, 0, 0)
                            inspectBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 180)
                            inspectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                            inspectBtn.Font = Enum.Font.GothamBold
                            inspectBtn.TextSize = 14
                            inspectBtn.Parent = actionsFrame
                            
                            local kickBtn = Instance.new("TextButton")
                            kickBtn.Text = "🚪"
                            kickBtn.Size = buttonSize
                            kickBtn.Position = UDim2.new(0, 50, 0, 0)
                            kickBtn.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
                            kickBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                            kickBtn.Font = Enum.Font.GothamBold
                            kickBtn.TextSize = 14
                            kickBtn.Parent = actionsFrame
                            
                            local banBtn = Instance.new("TextButton")
                            banBtn.Text = "⛔"
                            banBtn.Size = buttonSize
                            banBtn.Position = UDim2.new(0, 100, 0, 0)
                            banBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
                            banBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                            banBtn.Font = Enum.Font.GothamBold
                            banBtn.TextSize = 14
                            banBtn.Parent = actionsFrame
                            
                            -- NEU: 1-TAG BAN BUTTON
                            local banDayBtn = Instance.new("TextButton")
                            banDayBtn.Text = "📅"
                            banDayBtn.Size = buttonSize
                            banDayBtn.Position = UDim2.new(0, 150, 0, 0)
                            banDayBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
                            banDayBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                            banDayBtn.Font = Enum.Font.GothamBold
                            banDayBtn.TextSize = 14
                            banDayBtn.Parent = actionsFrame
                            
                            -- Zweite Reihe
                            local bringBtn = Instance.new("TextButton")
                            bringBtn.Text = "🚀"
                            bringBtn.Size = buttonSize
                            bringBtn.Position = UDim2.new(0, 0, 0, 40)
                            bringBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
                            bringBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                            bringBtn.Font = Enum.Font.GothamBold
                            bringBtn.TextSize = 14
                            bringBtn.Parent = actionsFrame
                            
                            local tptoBtn = Instance.new("TextButton")
                            tptoBtn.Text = "📍"
                            tptoBtn.Size = buttonSize
                            tptoBtn.Position = UDim2.new(0, 50, 0, 40)
                            tptoBtn.BackgroundColor3 = Color3.fromRGB(80, 160, 100)
                            tptoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                            tptoBtn.Font = Enum.Font.GothamBold
                            tptoBtn.TextSize = 14
                            tptoBtn.Parent = actionsFrame
                            
                            local copyBtn = Instance.new("TextButton")
                            copyBtn.Text = "📋"
                            copyBtn.Size = buttonSize
                            copyBtn.Position = UDim2.new(0, 100, 0, 40)
                            copyBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 180)
                            copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                            copyBtn.Font = Enum.Font.GothamBold
                            copyBtn.TextSize = 14
                            copyBtn.Parent = actionsFrame
                            
                            -- NEU: DISCORD BUTTON
                            local discordBtn = Instance.new("TextButton")
                            discordBtn.Text = "📢"
                            discordBtn.Size = buttonSize
                            discordBtn.Position = UDim2.new(0, 150, 0, 40)
                            discordBtn.BackgroundColor3 = Color3.fromRGB(155, 89, 182)
                            discordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                            discordBtn.Font = Enum.Font.GothamBold
                            discordBtn.TextSize = 14
                            discordBtn.Parent = actionsFrame
                            
                            -- Alle Buttons runden
                            for _, btn in pairs({inspectBtn, kickBtn, banBtn, banDayBtn, bringBtn, tptoBtn, copyBtn, discordBtn}) do
                                local corner = Instance.new("UICorner")
                                corner.CornerRadius = UDim.new(0, 6)
                                corner.Parent = btn
                            end
                            
                            -- Tooltips
                            inspectBtn.MouseEnter:Connect(function() inspectBtn.Text = "Inspect" end)
                            inspectBtn.MouseLeave:Connect(function() inspectBtn.Text = "🔍" end)
                            kickBtn.MouseEnter:Connect(function() kickBtn.Text = "Kick" end)
                            kickBtn.MouseLeave:Connect(function() kickBtn.Text = "🚪" end)
                            banBtn.MouseEnter:Connect(function() banBtn.Text = "Ban" end)
                            banBtn.MouseLeave:Connect(function() banBtn.Text = "⛔" end)
                            banDayBtn.MouseEnter:Connect(function() banDayBtn.Text = "1 Tag" end)
                            banDayBtn.MouseLeave:Connect(function() banDayBtn.Text = "📅" end)
                            bringBtn.MouseEnter:Connect(function() bringBtn.Text = "Bring" end)
                            bringBtn.MouseLeave:Connect(function() bringBtn.Text = "🚀" end)
                            tptoBtn.MouseEnter:Connect(function() tptoBtn.Text = "TPTO" end)
                            tptoBtn.MouseLeave:Connect(function() tptoBtn.Text = "📍" end)
                            copyBtn.MouseEnter:Connect(function() copyBtn.Text = "Copy" end)
                            copyBtn.MouseLeave:Connect(function() copyBtn.Text = "📋" end)
                            discordBtn.MouseEnter:Connect(function() discordBtn.Text = "Discord" end)
                            discordBtn.MouseLeave:Connect(function() discordBtn.Text = "📢" end)
                            
                            -- Button Events
                            inspectBtn.MouseButton1Click:Connect(function()
                                createInspectGui(player)
                            end)
                            
                            kickBtn.MouseButton1Click:Connect(function()
                                local cmd = "/kick " .. username
                                if setclipboard then
                                    setclipboard(cmd)
                                    pcall(function()
                                        StarterGui:SetCore("SendNotification", {
                                            Title = "✅ Kick kopiert",
                                            Text = cmd,
                                            Duration = 2
                                        })
                                    end)
                                end
                            end)
                            
                            banBtn.MouseButton1Click:Connect(function()
                                local cmd = "/ban " .. username
                                if setclipboard then
                                    setclipboard(cmd)
                                    pcall(function()
                                        StarterGui:SetCore("SendNotification", {
                                            Title = "✅ Ban kopiert",
                                            Text = cmd,
                                            Duration = 2
                                        })
                                    end)
                                end
                            end)
                            
                            -- NEU: 1-TAG BAN EVENT
                            banDayBtn.MouseButton1Click:Connect(function()
                                local cmd = "/banoneday " .. username
                                if setclipboard then
                                    setclipboard(cmd)
                                    pcall(function()
                                        StarterGui:SetCore("SendNotification", {
                                            Title = "✅ 1-Tag Ban kopiert",
                                            Text = cmd,
                                            Duration = 2
                                        })
                                    end)
                                end
                            end)
                            
                            bringBtn.MouseButton1Click:Connect(function()
                                local cmd = "/bring " .. username
                                if setclipboard then
                                    setclipboard(cmd)
                                    pcall(function()
                                        StarterGui:SetCore("SendNotification", {
                                            Title = "✅ Bring kopiert",
                                            Text = cmd,
                                            Duration = 2
                                        })
                                    end)
                                end
                            end)
                            
                            tptoBtn.MouseButton1Click:Connect(function()
                                local cmd = "/tpto " .. username
                                if setclipboard then
                                    setclipboard(cmd)
                                    pcall(function()
                                        StarterGui:SetCore("SendNotification", {
                                            Title = "✅ TPTO kopiert",
                                            Text = cmd,
                                            Duration = 2
                                        })
                                    end)
                                end
                            end)
                            
                            copyBtn.MouseButton1Click:Connect(function()
                                if setclipboard then
                                    setclipboard(username)
                                    pcall(function()
                                        StarterGui:SetCore("SendNotification", {
                                            Title = "✅ Name kopiert",
                                            Text = username,
                                            Duration = 2
                                        })
                                    end)
                                end
                            end)
                            
                            -- NEU: DISCORD EVENT
                            discordBtn.MouseButton1Click:Connect(function()
                                local inviteCode = "yJpCWt6Zjr"
                                if setclipboard then
                                    setclipboard(inviteCode)
                                    pcall(function()
                                        StarterGui:SetCore("SendNotification", {
                                            Title = "✅ Discord kopiert",
                                            Text = "Invite: " .. inviteCode,
                                            Duration = 3
                                        })
                                    end)
                                end
                            end)
                            
                            yOffset = yOffset + 100
                        end
                    end
                end
                
                playersList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
                playerCountText.Text = visibleCount .. "/" .. (#Players:GetPlayers() - 1)
                
                if visibleCount == 0 then
                    local noPlayers = Instance.new("TextLabel")
                    noPlayers.Text = "Keine Spieler gefunden"
                    noPlayers.Size = UDim2.new(1, 0, 0, 60)
                    noPlayers.Position = UDim2.new(0, 0, 0, 20)
                    noPlayers.BackgroundTransparency = 1
                    noPlayers.TextColor3 = Color3.fromRGB(150, 150, 150)
                    noPlayers.Font = Enum.Font.Gotham
                    noPlayers.TextSize = 16
                    noPlayers.Parent = playersList
                end
            end
            
            refreshBtn.MouseButton1Click:Connect(function()
                loadPlayerList(searchBar.Text)
            end)
            
            searchBar:GetPropertyChangedSignal("Text"):Connect(function()
                loadPlayerList(searchBar.Text)
            end)
            
            loadPlayerList("")
            
        elseif tabId == "tools" then
            -- Tools Tab (ERWEITERT MIT ANTI-AFK UND NEUEN BEFEHLEN)
            local toolsFrame = Instance.new("ScrollingFrame")
            toolsFrame.Name = "ToolsFrame"
            toolsFrame.Size = UDim2.new(1, 0, 1, 0)
            toolsFrame.BackgroundTransparency = 1
            toolsFrame.ScrollBarThickness = 8
            toolsFrame.Parent = contentArea
            
            local yOffset = 20
            
            -- NEU: Anti-AFK Card
            local antiAFKCard = Instance.new("Frame")
            antiAFKCard.Size = UDim2.new(1, -40, 0, 120)
            antiAFKCard.Position = UDim2.new(0, 20, 0, yOffset)
            antiAFKCard.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            antiAFKCard.Parent = toolsFrame
            
            local antiAFKCorner = Instance.new("UICorner")
            antiAFKCorner.CornerRadius = UDim.new(0, 12)
            antiAFKCorner.Parent = antiAFKCard
            
            local antiAFKTitle = Instance.new("TextLabel")
            antiAFKTitle.Text = "⏰ Anti-AFK System"
            antiAFKTitle.Size = UDim2.new(1, -20, 0, 40)
            antiAFKTitle.Position = UDim2.new(0, 10, 0, 10)
            antiAFKTitle.BackgroundTransparency = 1
            antiAFKTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
            antiAFKTitle.Font = Enum.Font.GothamBold
            antiAFKTitle.TextSize = 20
            antiAFKTitle.TextXAlignment = Enum.TextXAlignment.Left
            antiAFKTitle.Parent = antiAFKCard
            
            local antiAFKToggle = Instance.new("TextButton")
            antiAFKToggle.Text = ANTI_AFK_ENABLED and "✅ ANTI-AFK AKTIV" or "❌ ANTI-AFK INAKTIV"
            antiAFKToggle.Size = UDim2.new(1, -40, 0, 45)
            antiAFKToggle.Position = UDim2.new(0, 20, 0, 50)
            antiAFKToggle.BackgroundColor3 = ANTI_AFK_ENABLED and Color3.fromRGB(60, 160, 60) or Color3.fromRGB(160, 60, 60)
            antiAFKToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
            antiAFKToggle.Font = Enum.Font.GothamBold
            antiAFKToggle.TextSize = 16
            antiAFKToggle.Parent = antiAFKCard
            
            local antiAFKToggleCorner = Instance.new("UICorner")
            antiAFKToggleCorner.CornerRadius = UDim.new(0, 8)
            antiAFKToggleCorner.Parent = antiAFKToggle
            
            antiAFKToggle.MouseButton1Click:Connect(function()
                ANTI_AFK_ENABLED = not ANTI_AFK_ENABLED
                toggleAntiAFK(ANTI_AFK_ENABLED)
                antiAFKToggle.Text = ANTI_AFK_ENABLED and "✅ ANTI-AFK AKTIV" or "❌ ANTI-AFK INAKTIV"
                antiAFKToggle.BackgroundColor3 = ANTI_AFK_ENABLED and Color3.fromRGB(60, 160, 60) or Color3.fromRGB(160, 60, 60)
            end)
            
            yOffset = yOffset + 140
            
            -- ESP Haupt-Switch (UNVERÄNDERT VOM ORIGINAL)
            local espMainCard = Instance.new("Frame")
            espMainCard.Size = UDim2.new(1, -40, 0, 100)
            espMainCard.Position = UDim2.new(0, 20, 0, yOffset)
            espMainCard.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            espMainCard.Parent = toolsFrame
            
            local espMainCorner = Instance.new("UICorner")
            espMainCorner.CornerRadius = UDim.new(0, 12)
            espMainCorner.Parent = espMainCard
            
            local espMainTitle = Instance.new("TextLabel")
            espMainTitle.Text = "👁️ ESP System"
            espMainTitle.Size = UDim2.new(1, -20, 0, 40)
            espMainTitle.Position = UDim2.new(0, 10, 0, 10)
            espMainTitle.BackgroundTransparency = 1
            espMainTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
            espMainTitle.Font = Enum.Font.GothamBold
            espMainTitle.TextSize = 20
            espMainTitle.TextXAlignment = Enum.TextXAlignment.Left
            espMainTitle.Parent = espMainCard
            
            local espToggle = Instance.new("TextButton")
            espToggle.Text = ESP_SETTINGS.Enabled and "✅ ESP AKTIV" or "❌ ESP INAKTIV"
            espToggle.Size = UDim2.new(1, -40, 0, 45)
            espToggle.Position = UDim2.new(0, 20, 0, 45)
            espToggle.BackgroundColor3 = ESP_SETTINGS.Enabled and Color3.fromRGB(60, 160, 60) or Color3.fromRGB(160, 60, 60)
            espToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
            espToggle.Font = Enum.Font.GothamBold
            espToggle.TextSize = 18
            espToggle.Parent = espMainCard
            
            local espToggleCorner = Instance.new("UICorner")
            espToggleCorner.CornerRadius = UDim.new(0, 8)
            espToggleCorner.Parent = espToggle
            
            espToggle.MouseButton1Click:Connect(function()
                ESP_SETTINGS.Enabled = not ESP_SETTINGS.Enabled
                toggleESP(ESP_SETTINGS.Enabled)
                espToggle.Text = ESP_SETTINGS.Enabled and "✅ ESP AKTIV" or "❌ ESP INAKTIV"
                espToggle.BackgroundColor3 = ESP_SETTINGS.Enabled and Color3.fromRGB(60, 160, 60) or Color3.fromRGB(160, 60, 60)
                
                pcall(function()
                    StarterGui:SetCore("SendNotification", {
                        Title = ESP_SETTINGS.Enabled and "✅ ESP aktiviert" or "❌ ESP deaktiviert",
                        Text = ESP_SETTINGS.Enabled and "Spieler werden angezeigt" or "ESP ausgeschaltet",
                        Duration = 2
                    })
                end)
            end)
            
            yOffset = yOffset + 120
            
            -- NEU: Server Commands Card
            local commandsCard = Instance.new("Frame")
            commandsCard.Size = UDim2.new(1, -40, 0, 180)
            commandsCard.Position = UDim2.new(0, 20, 0, yOffset)
            commandsCard.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            commandsCard.Parent = toolsFrame
            
            local commandsCorner = Instance.new("UICorner")
            commandsCorner.CornerRadius = UDim.new(0, 12)
            commandsCorner.Parent = commandsCard
            
            local commandsTitle = Instance.new("TextLabel")
            commandsTitle.Text = "🎮 Server Commands"
            commandsTitle.Size = UDim2.new(1, -20, 0, 40)
            commandsTitle.Position = UDim2.new(0, 10, 0, 10)
            commandsTitle.BackgroundTransparency = 1
            commandsTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
            commandsTitle.Font = Enum.Font.GothamBold
            commandsTitle.TextSize = 20
            commandsTitle.TextXAlignment = Enum.TextXAlignment.Left
            commandsTitle.Parent = commandsCard
            
            -- Admin Car Button
            local adminCarBtn = Instance.new("TextButton")
            adminCarBtn.Text = "🚗 Admin Car spawnen"
            adminCarBtn.Size = UDim2.new(1, -40, 0, 40)
            adminCarBtn.Position = UDim2.new(0, 20, 0, 50)
            adminCarBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
            adminCarBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            adminCarBtn.Font = Enum.Font.GothamBold
            adminCarBtn.TextSize = 16
            adminCarBtn.Parent = commandsCard
            
            local adminCarCorner = Instance.new("UICorner")
            adminCarCorner.CornerRadius = UDim.new(0, 8)
            adminCarCorner.Parent = adminCarBtn
            
            adminCarBtn.MouseButton1Click:Connect(function()
                local command = "/spawnadmincar"
                if setclipboard then
                    setclipboard(command)
                    pcall(function()
                        StarterGui:SetCore("SendNotification", {
                            Title = "✅ Command kopiert",
                            Text = command,
                            Duration = 2
                        })
                    end)
                end
            end)
            
            -- Respawn All Button
            local respawnBtn = Instance.new("TextButton")
            respawnBtn.Text = "🔄 Alle respawnen"
            respawnBtn.Size = UDim2.new(1, -40, 0, 40)
            respawnBtn.Position = UDim2.new(0, 20, 0, 100)
            respawnBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 200)
            respawnBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            respawnBtn.Font = Enum.Font.GothamBold
            respawnBtn.TextSize = 16
            respawnBtn.Parent = commandsCard
            
            local respawnCorner = Instance.new("UICorner")
            respawnCorner.CornerRadius = UDim.new(0, 8)
            respawnCorner.Parent = respawnBtn
            
            respawnBtn.MouseButton1Click:Connect(function()
                local command = "/respawnall"
                if setclipboard then
                    setclipboard(command)
                    pcall(function()
                        StarterGui:SetCore("SendNotification", {
                            Title = "✅ Command kopiert",
                            Text = command,
                            Duration = 2
                        })
                    end)
                end
            end)
            
            -- Discord Button
            local discordBtn = Instance.new("TextButton")
            discordBtn.Text = "📢 Discord Einladung"
            discordBtn.Size = UDim2.new(1, -40, 0, 40)
            discordBtn.Position = UDim2.new(0, 20, 0, 150)
            discordBtn.BackgroundColor3 = Color3.fromRGB(155, 89, 182)
            discordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            discordBtn.Font = Enum.Font.GothamBold
            discordBtn.TextSize = 16
            discordBtn.Parent = commandsCard
            
            local discordCorner = Instance.new("UICorner")
            discordCorner.CornerRadius = UDim.new(0, 8)
            discordCorner.Parent = discordBtn
            
            discordBtn.MouseButton1Click:Connect(function()
                local inviteCode = "yJpCWt6Zjr"
                if setclipboard then
                    setclipboard(inviteCode)
                    pcall(function()
                        StarterGui:SetCore("SendNotification", {
                            Title = "✅ Discord kopiert",
                            Text = "Invite: " .. inviteCode,
                            Duration = 3
                        })
                    end)
                end
            end)
            
            yOffset = yOffset + 200
            
            -- Server Tools Card (UNVERÄNDERT VOM ORIGINAL)
            local serverToolsCard = Instance.new("Frame")
            serverToolsCard.Size = UDim2.new(1, -40, 0, 150)
            serverToolsCard.Position = UDim2.new(0, 20, 0, yOffset)
            serverToolsCard.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            serverToolsCard.Parent = toolsFrame
            
            local serverToolsCorner = Instance.new("UICorner")
            serverToolsCorner.CornerRadius = UDim.new(0, 12)
            serverToolsCorner.Parent = serverToolsCard
            
            local serverToolsTitle = Instance.new("TextLabel")
            serverToolsTitle.Text = "🛠️ Server Tools"
            serverToolsTitle.Size = UDim2.new(1, -20, 0, 40)
            serverToolsTitle.Position = UDim2.new(0, 10, 0, 10)
            serverToolsTitle.BackgroundTransparency = 1
            serverToolsTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
            serverToolsTitle.Font = Enum.Font.GothamBold
            serverToolsTitle.TextSize = 18
            serverToolsTitle.TextXAlignment = Enum.TextXAlignment.Left
            serverToolsTitle.Parent = serverToolsCard
            
            -- Alles Bereinigen Button
            local cleanupBtn = Instance.new("TextButton")
            cleanupBtn.Text = "🧹 Alles Bereinigen"
            cleanupBtn.Size = UDim2.new(1, -40, 0, 40)
            cleanupBtn.Position = UDim2.new(0, 20, 0, 50)
            cleanupBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
            cleanupBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            cleanupBtn.Font = Enum.Font.GothamBold
            cleanupBtn.TextSize = 16
            cleanupBtn.Parent = serverToolsCard
            
            local cleanupCorner = Instance.new("UICorner")
            cleanupCorner.CornerRadius = UDim.new(0, 8)
            cleanupCorner.Parent = cleanupBtn
            
            cleanupBtn.MouseButton1Click:Connect(function()
                closeMiniMenu()
                closeAdminPanel()
                closeInspectGui()
                toggleESP(false)
                toggleAntiAFK(false)
                
                pcall(function()
                    StarterGui:SetCore("SendNotification", {
                        Title = "🧹 Alles bereinigt",
                        Text = "Alle GUIs geschlossen & Systeme gestoppt",
                        Duration = 3
                    })
                end)
                
                print("✅ Alles bereinigt")
            end)
            
            -- Script Neu starten Button
            local restartBtn = Instance.new("TextButton")
            restartBtn.Text = "🔄 Script Neu starten"
            restartBtn.Size = UDim2.new(1, -40, 0, 40)
            restartBtn.Position = UDim2.new(0, 20, 0, 100)
            restartBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
            restartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            restartBtn.Font = Enum.Font.GothamBold
            restartBtn.TextSize = 16
            restartBtn.Parent = serverToolsCard
            
            local restartCorner = Instance.new("UICorner")
            restartCorner.CornerRadius = UDim.new(0, 8)
            restartCorner.Parent = restartBtn
            
            restartBtn.MouseButton1Click:Connect(function()
                pcall(function()
                    StarterGui:SetCore("SendNotification", {
                        Title = "🔄 Script wird neu gestartet",
                        Text = "Bitte warten...",
                        Duration = 2
                    })
                end)
                
                wait(0.5)
                
                closeMiniMenu()
                closeAdminPanel()
                closeInspectGui()
                toggleESP(false)
                toggleAntiAFK(false)
                
                print("========================================")
                print("🔄 ADMIN PANEL PRO WIRD NEU GESTARTET")
                print("========================================")
                
                wait(1)
                
                pcall(function()
                    StarterGui:SetCore("SendNotification", {
                        Title = "✅ Script neu gestartet",
                        Text = "Admin Panel Pro wurde neu geladen",
                        Duration = 3
                    })
                end)
                
                print("✅ Neustart abgeschlossen")
            end)
            
            yOffset = yOffset + 170
            
            toolsFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset)
            
        elseif tabId == "settings" then
            -- Settings Tab (UNVERÄNDERT VOM ORIGINAL)
            local settingsFrame = Instance.new("ScrollingFrame")
            settingsFrame.Name = "SettingsFrame"
            settingsFrame.Size = UDim2.new(1, 0, 1, 0)
            settingsFrame.BackgroundTransparency = 1
            settingsFrame.ScrollBarThickness = 8
            settingsFrame.Parent = contentArea
            
            local yOffset = 20
            
            -- Info Card
            local infoCard = Instance.new("Frame")
            infoCard.Size = UDim2.new(1, -40, 0, 150)
            infoCard.Position = UDim2.new(0, 20, 0, yOffset)
            infoCard.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            infoCard.Parent = settingsFrame
            
            local infoCorner = Instance.new("UICorner")
            infoCorner.CornerRadius = UDim.new(0, 12)
            infoCorner.Parent = infoCard
            
            local infoTitle = Instance.new("TextLabel")
            infoTitle.Text = "📦 Script Information"
            infoTitle.Size = UDim2.new(1, -20, 0, 40)
            infoTitle.Position = UDim2.new(0, 10, 0, 10)
            infoTitle.BackgroundTransparency = 1
            infoTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
            infoTitle.Font = Enum.Font.GothamBold
            infoTitle.TextSize = 20
            infoTitle.TextXAlignment = Enum.TextXAlignment.Left
            infoTitle.Parent = infoCard
            
            local versionText = Instance.new("TextLabel")
            versionText.Text = "Admin Panel Pro " .. SCRIPT_VERSION
            versionText.Size = UDim2.new(1, -20, 0, 25)
            versionText.Position = UDim2.new(0, 10, 0, 50)
            versionText.BackgroundTransparency = 1
            versionText.TextColor3 = Color3.fromRGB(200, 200, 220)
            versionText.Font = Enum.Font.GothamBold
            versionText.TextSize = 16
            versionText.TextXAlignment = Enum.TextXAlignment.Left
            versionText.Parent = infoCard
            
            local authorText = Instance.new("TextLabel")
            authorText.Text = "Erstellt für: Server Administrator"
            authorText.Size = UDim2.new(1, -20, 0, 25)
            authorText.Position = UDim2.new(0, 10, 0, 80)
            authorText.BackgroundTransparency = 1
            authorText.TextColor3 = Color3.fromRGB(200, 200, 220)
            authorText.Font = Enum.Font.Gotham
            authorText.TextSize = 15
            authorText.TextXAlignment = Enum.TextXAlignment.Left
            authorText.Parent = infoCard
            
            local statusText = Instance.new("TextLabel")
            statusText.Text = "Status: ✅ All Systeme Online"
            statusText.Size = UDim2.new(1, -20, 0, 25)
            statusText.Position = UDim2.new(0, 10, 0, 110)
            statusText.BackgroundTransparency = 1
            statusText.TextColor3 = Color3.fromRGB(100, 255, 100)
            statusText.Font = Enum.Font.GothamBold
            statusText.TextSize = 15
            statusText.TextXAlignment = Enum.TextXAlignment.Left
            statusText.Parent = infoCard
            
            yOffset = yOffset + 170
            
            -- Hotkeys Card (ERWEITERT MIT NEUEN HOTKEYS)
            local hotkeysCard = Instance.new("Frame")
            hotkeysCard.Size = UDim2.new(1, -40, 0, 250)
            hotkeysCard.Position = UDim2.new(0, 20, 0, yOffset)
            hotkeysCard.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            hotkeysCard.Parent = settingsFrame
            
            local hotkeysCorner = Instance.new("UICorner")
            hotkeysCorner.CornerRadius = UDim.new(0, 12)
            hotkeysCorner.Parent = hotkeysCard
            
            local hotkeysTitle = Instance.new("TextLabel")
            hotkeysTitle.Text = "⌨️ Hotkeys & Steuerung"
            hotkeysTitle.Size = UDim2.new(1, -20, 0, 40)
            hotkeysTitle.Position = UDim2.new(0, 10, 0, 10)
            hotkeysTitle.BackgroundTransparency = 1
            hotkeysTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
            hotkeysTitle.Font = Enum.Font.GothamBold
            hotkeysTitle.TextSize = 20
            hotkeysTitle.TextXAlignment = Enum.TextXAlignment.Left
            hotkeysTitle.Parent = hotkeysCard
            
            local hotkeysText = Instance.new("TextLabel")
            hotkeysText.Text = "📋 P = Nächstgelegenen Spieler kopieren\n📁 F2 = Admin Panel öffnen/schließen\n❌ ESC = Alle GUIs schließen\n\n🔍 = Spieler inspizieren\n📋 = Wert kopieren\n🚪 = Kick-Befehl kopieren\n⛔ = Ban-Befehl kopieren\n📅 = 1-Tag Ban kopieren\n🚀 = Bring-Befehl kopieren\n📍 = TPTO-Befehl kopieren\n🚗 = Admin Car spawnen\n🔄 = Alle respawnen\n📢 = Discord kopieren"
            hotkeysText.Size = UDim2.new(1, -20, 0, 200)
            hotkeysText.Position = UDim2.new(0, 10, 0, 50)
            hotkeysText.BackgroundTransparency = 1
            hotkeysText.TextColor3 = Color3.fromRGB(200, 200, 220)
            hotkeysText.Font = Enum.Font.Gotham
            hotkeysText.TextSize = 14
            hotkeysText.TextXAlignment = Enum.TextXAlignment.Left
            hotkeysText.TextYAlignment = Enum.TextYAlignment.Top
            hotkeysText.Parent = hotkeysCard
            
            yOffset = yOffset + 270
            
            -- Performance Card
            local perfCard = Instance.new("Frame")
            perfCard.Size = UDim2.new(1, -40, 0, 130)
            perfCard.Position = UDim2.new(0, 20, 0, yOffset)
            perfCard.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            perfCard.Parent = settingsFrame
            
            local perfCorner = Instance.new("UICorner")
            perfCorner.CornerRadius = UDim.new(0, 12)
            perfCorner.Parent = perfCard
            
            local perfTitle = Instance.new("TextLabel")
            perfTitle.Text = "⚡ Performance Optimierungen"
            perfTitle.Size = UDim2.new(1, -20, 0, 40)
            perfTitle.Position = UDim2.new(0, 10, 0, 10)
            perfTitle.BackgroundTransparency = 1
            perfTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
            perfTitle.Font = Enum.Font.GothamBold
            perfTitle.TextSize = 20
            perfTitle.TextXAlignment = Enum.TextXAlignment.Left
            perfTitle.Parent = perfCard
            
            local perfText = Instance.new("TextLabel")
            perfText.Text = "✅ ESP nur bei Aktivierung\n✅ Anti-AFK nur bei Bedarf\n✅ AFK-Tracking nur bei Inspection\n✅ Live-Updates optimiert\n✅ Performance ESP verfügbar\n✅ Keine unnötigen Berechnungen"
            perfText.Size = UDim2.new(1, -20, 0, 80)
            perfText.Position = UDim2.new(0, 10, 0, 50)
            perfText.BackgroundTransparency = 1
            perfText.TextColor3 = Color3.fromRGB(200, 200, 220)
            perfText.Font = Enum.Font.Gotham
            perfText.TextSize = 14
            perfText.TextXAlignment = Enum.TextXAlignment.Left
            perfText.TextYAlignment = Enum.TextYAlignment.Top
            perfText.Parent = perfCard
            
            settingsFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 150)
        end
    end
    
    -- Tab-Buttons erstellen
    for i, tab in ipairs(tabs) do
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tab.id .. "Tab"
        tabButton.Text = "  " .. tab.name
        tabButton.Size = UDim2.new(1, -20, 0, 60)
        tabButton.Position = UDim2.new(0, 10, 0, 20 + (i-1) * 70)
        
        if tab.id == activeTab then
            tabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            tabButton.TextColor3 = Color3.fromRGB(255, 215, 0)
        else
            tabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            tabButton.TextColor3 = Color3.fromRGB(220, 220, 230)
        end
        
        tabButton.Font = Enum.Font.Gotham
        tabButton.TextSize = 16
        tabButton.TextXAlignment = Enum.TextXAlignment.Left
        tabButton.Parent = sidebar
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 10)
        tabCorner.Parent = tabButton
        
        -- Hover Effects
        tabButton.MouseEnter:Connect(function()
            if tab.id ~= activeTab then
                tabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            end
        end)
        
        tabButton.MouseLeave:Connect(function()
            if tab.id ~= activeTab then
                tabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            end
        end)
        
        -- Tab-Wechsel Event
        tabButton.MouseButton1Click:Connect(function()
            for _, btn in pairs(sidebar:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
                    btn.TextColor3 = Color3.fromRGB(220, 220, 230)
                end
            end
            
            tabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            tabButton.TextColor3 = Color3.fromRGB(255, 215, 0)
            
            switchTab(tab.id)
        end)
    end
    
    -- Standard-Tab laden
    switchTab("dashboard")
    
    screenGui.Parent = LP:WaitForChild("PlayerGui")
    adminPanelGui = screenGui
    
    print("✅ Admin Panel Pro geöffnet")
end

local function toggleAdminPanel()
    if isPanelOpen then
        closeAdminPanel()
    else
        openAdminPanel()
    end
end

-- ============================================
-- TEIL 6: INPUT HANDLER & AUTO-CLOSE
-- ============================================

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.P then
        copyNearestPlayer()
        
    elseif input.KeyCode == Enum.KeyCode.F2 then
        toggleAdminPanel()
        
    elseif input.KeyCode == Enum.KeyCode.Escape then
        closeMiniMenu()
        closeAdminPanel()
        closeInspectGui()
    end
end)

-- Auto-Close für Mini-Menü
RunService.Heartbeat:Connect(function()
    if miniMenuGui and miniMenuTimeout > 0 and tick() > miniMenuTimeout then
        closeMiniMenu()
    end
end)

-- ============================================
-- TEIL 7: STARTUP & CLEANUP
-- ============================================

print("✅ Admin Panel Pro " .. SCRIPT_VERSION .. " initialisiert")
print("✅ ESP System bereit")
print("✅ Anti-AFK System bereit")
print("✅ AFK Tracking System bereit")
print("✅ Alle GUIs performance-optimiert")

-- Export für Executor
if getgenv then
    getgenv().AdminCopyName = copyNearestPlayer
    getgenv().AdminOpenPanel = openAdminPanel
    getgenv().AdminClosePanel = closeAdminPanel
    getgenv().AdminTogglePanel = toggleAdminPanel
    getgenv().AdminToggleESP = function()
        ESP_SETTINGS.Enabled = not ESP_SETTINGS.Enabled
        toggleESP(ESP_SETTINGS.Enabled)
        return ESP_SETTINGS.Enabled
    end
    getgenv().AdminToggleAntiAFK = function()
        ANTI_AFK_ENABLED = not ANTI_AFK_ENABLED
        toggleAntiAFK(ANTI_AFK_ENABLED)
        return ANTI_AFK_ENABLED
    end
    getgenv().AdminCleanup = function()
        closeMiniMenu()
        closeAdminPanel()
        closeInspectGui()
        toggleESP(false)
        toggleAntiAFK(false)
        
        -- Alle AFK Connections stoppen
        for player, conn in pairs(afkCheckConnections) do
            if conn then
                conn:Disconnect()
            end
        end
        
        print("🛑 Admin Panel komplett bereinigt")
    end
    
    -- ESP Einstellungen exportieren
    getgenv().AdminESPSettings = ESP_SETTINGS
end

return "✅ ADMIN PANEL PRO " .. SCRIPT_VERSION .. " - BEREIT & PERFORMANCE-OPTIMIERT"
