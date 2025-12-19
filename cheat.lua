-- ============================================
-- ADMIN PANEL ULTIMATE v4 - PERFORMANCE OPTIMIERT
-- ============================================

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")

-- ============================================
-- KONFIGURATION
-- ============================================

local SCRIPT_VERSION = "v4.0"
local UPDATE_RATE = 1 -- Sekunden zwischen Updates
local ESP_ENABLED = false
local ESP_ITEMS = {}

-- ============================================
-- INITIALISIERUNG
-- ============================================

print("=========================================")
print("ADMIN PANEL ULTIMATE " .. SCRIPT_VERSION)
print("=========================================")
print("P = Nächstgelegenen Spieler kopieren")
print("F2 = Admin Panel öffnen/schließen")
print("ESC = Alles schließen")
print("=========================================")

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
-- TEIL 1: MINI-MENÜ (Name Copy) - UNVERÄNDERT
-- ============================================

local miniMenuGui = nil
local miniMenuTimeout = 0

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
            userId = nearestPlayer.UserId
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
    mainFrame.Size = UDim2.new(0, 220, 0, 160)
    mainFrame.Position = UDim2.new(1, -240, 1, -280)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    mainFrame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 0, 0)
    stroke.Thickness = 2
    stroke.Parent = mainFrame
    
    -- Inhalt (gekürzt, gleiche wie vorher)
    local title = Instance.new("TextLabel")
    title.Text = "👑 Admin Menü"
    title.Size = UDim2.new(1, -20, 0, 30)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255, 215, 0)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = mainFrame
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "×"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -40, 0, 10)
    closeBtn.BackgroundTransparency = 1
    closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 24
    closeBtn.Parent = mainFrame
    
    closeBtn.MouseButton1Click:Connect(closeMiniMenu)
    
    -- Spielerinfo
    local playerInfo = Instance.new("TextLabel")
    playerInfo.Text = playerData.name
    playerInfo.Size = UDim2.new(1, -20, 0, 24)
    playerInfo.Position = UDim2.new(0, 10, 0, 50)
    playerInfo.BackgroundTransparency = 1
    playerInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
    playerInfo.Font = Enum.Font.Gotham
    playerInfo.TextSize = 14
    playerInfo.TextXAlignment = Enum.TextXAlignment.Left
    playerInfo.TextTruncate = Enum.TextTruncate.AtEnd
    playerInfo.Parent = mainFrame
    
    local usernameText = Instance.new("TextLabel")
    usernameText.Text = "@" .. playerData.username
    usernameText.Size = UDim2.new(1, -20, 0, 20)
    usernameText.Position = UDim2.new(0, 10, 0, 74)
    usernameText.BackgroundTransparency = 1
    usernameText.TextColor3 = Color3.fromRGB(180, 180, 200)
    usernameText.Font = Enum.Font.Gotham
    usernameText.TextSize = 12
    usernameText.TextXAlignment = Enum.TextXAlignment.Left
    usernameText.TextTruncate = Enum.TextTruncate.AtEnd
    usernameText.Parent = mainFrame
    
    local statsText = Instance.new("TextLabel")
    statsText.Text = string.format("❤️ %d HP | 📏 %d Studs", playerData.hp, playerData.distance)
    statsText.Size = UDim2.new(1, -20, 0, 20)
    statsText.Position = UDim2.new(0, 10, 0, 96)
    statsText.BackgroundTransparency = 1
    statsText.TextColor3 = Color3.fromRGB(150, 220, 255)
    statsText.Font = Enum.Font.Gotham
    statsText.TextSize = 12
    statsText.TextXAlignment = Enum.TextXAlignment.Left
    statsText.Parent = mainFrame
    
    -- Buttons
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Size = UDim2.new(1, -20, 0, 40)
    buttonContainer.Position = UDim2.new(0, 10, 1, -50)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = mainFrame
    
    local kickBtn = Instance.new("TextButton")
    kickBtn.Text = "🚪 Kick"
    kickBtn.Size = UDim2.new(0.48, 0, 1, 0)
    kickBtn.Position = UDim2.new(0, 0, 0, 0)
    kickBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    kickBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    kickBtn.Font = Enum.Font.GothamBold
    kickBtn.TextSize = 14
    kickBtn.Parent = buttonContainer
    
    local kickCorner = Instance.new("UICorner")
    kickCorner.CornerRadius = UDim.new(0, 6)
    kickCorner.Parent = kickBtn
    
    local banBtn = Instance.new("TextButton")
    banBtn.Text = "⛔ Ban"
    banBtn.Size = UDim2.new(0.48, 0, 1, 0)
    banBtn.Position = UDim2.new(0.52, 0, 0, 0)
    banBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    banBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    banBtn.Font = Enum.Font.GothamBold
    banBtn.TextSize = 14
    banBtn.Parent = buttonContainer
    
    local banCorner = Instance.new("UICorner")
    banCorner.CornerRadius = UDim.new(0, 6)
    banCorner.Parent = banBtn
    
    -- Button Events
    kickBtn.MouseButton1Click:Connect(function()
        local command = "/kick " .. playerData.username
        if setclipboard then
            setclipboard(command)
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = "✅ Kick-Befehl kopiert",
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
                    Title = "✅ Ban-Befehl kopiert",
                    Text = command,
                    Duration = 2
                })
            end)
        end
        closeMiniMenu()
    end)
    
    mainFrame.Parent = screenGui
    screenGui.Parent = LP:WaitForChild("PlayerGui")
    
    miniMenuGui = screenGui
    miniMenuTimeout = tick() + 5
    
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
-- TEIL 2: ESP SYSTEM (PERFORMANCE OPTIMIERT)
-- ============================================

local function createESP(player)
    if not ESP_ENABLED then return end
    
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    -- Box ESP
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "ESP_Box_" .. player.Name
    box.Adornee = humanoidRootPart
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Size = Vector3.new(4, 6, 2)
    box.Color3 = Color3.fromRGB(0, 255, 0)
    box.Transparency = 0.7
    box.Parent = humanoidRootPart
    
    -- Name ESP
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Name_" .. player.Name
    billboard.Adornee = humanoidRootPart
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 500
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.DisplayName or player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextSize = 18
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Parent = billboard
    
    billboard.Parent = humanoidRootPart
    
    ESP_ITEMS[player] = {box = box, billboard = billboard}
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

local function toggleESP(enabled)
    ESP_ENABLED = enabled
    
    if enabled then
        -- ESP für alle Spieler erstellen
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LP then
                createESP(player)
            end
        end
        
        -- Events für neue Spieler
        local playerAddedConn = Players.PlayerAdded:Connect(function(player)
            wait(1) -- Warten bis Character geladen
            createESP(player)
        end)
        
        local playerRemovingConn = Players.PlayerRemoving:Connect(function(player)
            removeESP(player)
        end)
        
        -- Character added event
        local function setupPlayerESP(player)
            if player ~= LP then
                local conn = player.CharacterAdded:Connect(function()
                    wait(0.5)
                    if ESP_ENABLED then
                        createESP(player)
                    end
                end)
                return conn
            end
            return nil
        end
        
        for _, player in pairs(Players:GetPlayers()) do
            setupPlayerESP(player)
        end
        
    else
        -- Alles ESP entfernen
        for player, espItems in pairs(ESP_ITEMS) do
            removeESP(player)
        end
        ESP_ITEMS = {}
    end
end

-- ============================================
-- TEIL 3: ERWEITERTES ADMIN PANEL
-- ============================================

local adminPanelGui = nil
local isPanelOpen = false
local currentInspectPlayer = nil
local inspectGui = nil
local lastUpdateTime = 0

local function closeInspectGui()
    if inspectGui then
        inspectGui:Destroy()
        inspectGui = nil
        currentInspectPlayer = nil
    end
end

local function createInspectGui(player)
    closeInspectGui()
    currentInspectPlayer = player
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PlayerInspectGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 150
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 350, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
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
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    titleBar.Parent = mainFrame
    
    local titleText = Instance.new("TextLabel")
    titleText.Text = "🔍 Spieler Inspizieren"
    titleText.Size = UDim2.new(1, -50, 1, 0)
    titleText.Position = UDim2.new(0, 15, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.TextColor3 = Color3.fromRGB(255, 215, 0)
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 16
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "×"
    closeBtn.Size = UDim2.new(0, 40, 0, 40)
    closeBtn.Position = UDim2.new(1, -40, 0, 0)
    closeBtn.BackgroundTransparency = 1
    closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 24
    closeBtn.Parent = titleBar
    
    closeBtn.MouseButton1Click:Connect(closeInspectGui)
    
    -- Inhalt
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -20, 1, -60)
    content.Position = UDim2.new(0, 10, 0, 50)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 6
    content.Parent = mainFrame
    
    local yOffset = 10
    
    -- Funktion zum Erstellen von Info-Rows mit Kopier-Button
    local function createInfoRow(label, value, copyValue)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 40)
        row.Position = UDim2.new(0, 0, 0, yOffset)
        row.BackgroundTransparency = 1
        row.Parent = content
        
        local labelText = Instance.new("TextLabel")
        labelText.Text = label
        labelText.Size = UDim2.new(0.5, -10, 1, 0)
        labelText.Position = UDim2.new(0, 0, 0, 0)
        labelText.BackgroundTransparency = 1
        labelText.TextColor3 = Color3.fromRGB(200, 200, 220)
        labelText.Font = Enum.Font.Gotham
        labelText.TextSize = 14
        labelText.TextXAlignment = Enum.TextXAlignment.Left
        labelText.Parent = row
        
        local valueFrame = Instance.new("Frame")
        valueFrame.Size = UDim2.new(0.5, -10, 1, 0)
        valueFrame.Position = UDim2.new(0.5, 0, 0, 0)
        valueFrame.BackgroundTransparency = 1
        valueFrame.Parent = row
        
        local valueText = Instance.new("TextLabel")
        valueText.Text = value
        valueText.Size = UDim2.new(0.7, 0, 1, 0)
        valueText.Position = UDim2.new(0, 0, 0, 0)
        valueText.BackgroundTransparency = 1
        valueText.TextColor3 = Color3.fromRGB(255, 255, 255)
        valueText.Font = Enum.Font.Gotham
        valueText.TextSize = 14
        valueText.TextXAlignment = Enum.TextXAlignment.Left
        valueText.TextTruncate = Enum.TextTruncate.AtEnd
        valueText.Parent = valueFrame
        
        local copyBtn = Instance.new("TextButton")
        copyBtn.Text = "📋"
        copyBtn.Size = UDim2.new(0, 30, 0, 30)
        copyBtn.Position = UDim2.new(1, -35, 0, 5)
        copyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        copyBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        copyBtn.Font = Enum.Font.GothamBold
        copyBtn.TextSize = 12
        copyBtn.Parent = valueFrame
        
        local copyCorner = Instance.new("UICorner")
        copyCorner.CornerRadius = UDim.new(0, 6)
        copyCorner.Parent = copyBtn
        
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
        
        yOffset = yOffset + 45
        return valueText
    end
    
    -- Spieler-Informationen (statisch)
    local displayName = player.DisplayName or player.Name
    local username = player.Name
    local userId = tostring(player.UserId)
    
    local nameText = createInfoRow("Anzeigename:", displayName, displayName)
    local userText = createInfoRow("Username:", "@" .. username, username)
    local idText = createInfoRow("Roblox ID:", userId, userId)
    
    -- Live-Informationen (dynamisch)
    local hpText = createInfoRow("Leben:", "Berechne...", "0")
    local distText = createInfoRow("Entfernung:", "Berechne...", "0")
    local statusText = createInfoRow("Status:", "Online", "Online")
    
    -- Special Buttons
    yOffset = yOffset + 20
    
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Size = UDim2.new(1, 0, 0, 100)
    buttonContainer.Position = UDim2.new(0, 0, 0, yOffset)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = content
    
    -- Bring Button
    local bringBtn = Instance.new("TextButton")
    bringBtn.Text = "🚀 Bring"
    bringBtn.Size = UDim2.new(0.48, 0, 0, 40)
    bringBtn.Position = UDim2.new(0, 0, 0, 0)
    bringBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
    bringBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    bringBtn.Font = Enum.Font.GothamBold
    bringBtn.TextSize = 14
    bringBtn.Parent = buttonContainer
    
    local bringCorner = Instance.new("UICorner")
    bringCorner.CornerRadius = UDim.new(0, 8)
    bringCorner.Parent = bringBtn
    
    -- TP2 Button
    local tp2Btn = Instance.new("TextButton")
    tp2Btn.Text = "📍 TP2"
    tp2Btn.Size = UDim2.new(0.48, 0, 0, 40)
    tp2Btn.Position = UDim2.new(0.52, 0, 0, 0)
    tp2Btn.BackgroundColor3 = Color3.fromRGB(80, 160, 100)
    tp2Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    tp2Btn.Font = Enum.Font.GothamBold
    tp2Btn.TextSize = 14
    tp2Btn.Parent = buttonContainer
    
    local tp2Corner = Instance.new("UICorner")
    tp2Corner.CornerRadius = UDim.new(0, 8)
    tp2Corner.Parent = tp2Btn
    
    -- Button Events
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
    
    tp2Btn.MouseButton1Click:Connect(function()
        local command = "/tp2 " .. username
        if setclipboard then
            setclipboard(command)
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = "✅ TP2 kopiert",
                    Text = command,
                    Duration = 2
                })
            end)
        end
    end)
    
    yOffset = yOffset + 110
    
    -- Update-Funktion für Live-Daten (Performance: nur bei Bedarf)
    local function updateLiveData()
        if not inspectGui or inspectGui.Parent == nil then
            return -- GUI geschlossen
        end
        
        local now = tick()
        if now - lastUpdateTime < UPDATE_RATE then
            return -- Zu früh für Update
        end
        lastUpdateTime = now
        
        local targetChar = player.Character
        if targetChar then
            -- Leben
            local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
            if humanoid then
                hpText.Text = math.floor(humanoid.Health) .. " HP"
            else
                hpText.Text = "N/A"
            end
            
            -- Entfernung
            local localChar = LP.Character
            if localChar then
                local localRoot = localChar:FindFirstChild("HumanoidRootPart") or localChar.PrimaryPart
                local targetRoot = targetChar:FindFirstChild("HumanoidRootPart") or targetChar.PrimaryPart
                
                if localRoot and targetRoot then
                    local distance = math.floor((localRoot.Position - targetRoot.Position).Magnitude)
                    distText.Text = distance .. " Studs"
                else
                    distText.Text = "N/A"
                end
            else
                distText.Text = "N/A"
            end
            
            -- Status
            if targetChar:FindFirstChild("Humanoid") then
                statusText.Text = "Online"
            else
                statusText.Text = "Offline"
            end
        else
            hpText.Text = "N/A"
            distText.Text = "N/A"
            statusText.Text = "Offline"
        end
    end
    
    -- Live-Update Connection (nur wenn GUI offen)
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
    
    content.CanvasSize = UDim2.new(0, 0, 0, yOffset)
    
    screenGui.Parent = LP:WaitForChild("PlayerGui")
    inspectGui = screenGui
    
    -- Sofort erste Daten laden
    updateLiveData()
    
    return screenGui
end

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
    screenGui.Name = "AdminPanelUltimate"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 20
    
    local mainContainer = Instance.new("Frame")
    mainContainer.Name = "MainContainer"
    mainContainer.Size = UDim2.new(0.85, 0, 0.85, 0)
    mainContainer.Position = UDim2.new(0.075, 0, 0.075, 0)
    mainContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    mainContainer.Parent = screenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainContainer
    
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(60, 60, 70)
    mainStroke.Thickness = 2
    mainStroke.Parent = mainContainer
    
    -- Titel-Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 50)
    titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    titleBar.Parent = mainContainer
    
    local titleText = Instance.new("TextLabel")
    titleText.Text = "🛡️ ADMIN PANEL " .. SCRIPT_VERSION
    titleText.Size = UDim2.new(0.5, 0, 1, 0)
    titleText.Position = UDim2.new(0, 20, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.TextColor3 = Color3.fromRGB(255, 215, 0)
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 20
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "×"
    closeBtn.Size = UDim2.new(0, 50, 0, 50)
    closeBtn.Position = UDim2.new(1, -50, 0, 0)
    closeBtn.BackgroundTransparency = 1
    closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 28
    closeBtn.Parent = titleBar
    
    closeBtn.MouseButton1Click:Connect(closeAdminPanel)
    
    -- Seitenleiste
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 220, 1, -50)
    sidebar.Position = UDim2.new(0, 0, 0, 50)
    sidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    sidebar.Parent = mainContainer
    
    -- Content-Bereich
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -220, 1, -50)
    contentArea.Position = UDim2.new(0, 220, 0, 50)
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
    local tabContents = {}
    
    -- Funktion zum Wechseln der Tabs
    local function switchTab(tabId)
        activeTab = tabId
        
        -- Alten Content entfernen
        for _, child in pairs(contentArea:GetChildren()) do
            child:Destroy()
        end
        
        -- Neuen Content basierend auf Tab erstellen
        if tabId == "dashboard" then
            -- Dashboard Content
            local dashboardFrame = Instance.new("ScrollingFrame")
            dashboardFrame.Name = "DashboardFrame"
            dashboardFrame.Size = UDim2.new(1, 0, 1, 0)
            dashboardFrame.BackgroundTransparency = 1
            dashboardFrame.ScrollBarThickness = 6
            dashboardFrame.Parent = contentArea
            
            local yOffset = 20
            
            -- Willkommens-Banner
            local welcomeBanner = Instance.new("Frame")
            welcomeBanner.Size = UDim2.new(1, -40, 0, 80)
            welcomeBanner.Position = UDim2.new(0, 20, 0, yOffset)
            welcomeBanner.BackgroundColor3 = Color3.fromRGB(40, 40, 120)
            welcomeBanner.Parent = dashboardFrame
            
            local welcomeCorner = Instance.new("UICorner")
            welcomeCorner.CornerRadius = UDim.new(0, 10)
            welcomeCorner.Parent = welcomeBanner
            
            local welcomeText = Instance.new("TextLabel")
            welcomeText.Text = "Willkommen, Admin!"
            welcomeText.Size = UDim2.new(1, -20, 0, 40)
            welcomeText.Position = UDim2.new(0, 10, 0, 10)
            welcomeText.BackgroundTransparency = 1
            welcomeText.TextColor3 = Color3.fromRGB(255, 255, 255)
            welcomeText.Font = Enum.Font.GothamBold
            welcomeText.TextSize = 22
            welcomeText.TextXAlignment = Enum.TextXAlignment.Left
            welcomeText.Parent = welcomeBanner
            
            local versionText = Instance.new("TextLabel")
            versionText.Text = "Version: " .. SCRIPT_VERSION
            versionText.Size = UDim2.new(1, -20, 0, 25)
            versionText.Position = UDim2.new(0, 10, 0, 45)
            versionText.BackgroundTransparency = 1
            versionText.TextColor3 = Color3.fromRGB(200, 200, 255)
            versionText.Font = Enum.Font.Gotham
            versionText.TextSize = 14
            versionText.TextXAlignment = Enum.TextXAlignment.Left
            versionText.Parent = welcomeBanner
            
            yOffset = yOffset + 100
            
            -- Server-Info Card
            local serverCard = Instance.new("Frame")
            serverCard.Size = UDim2.new(1, -40, 0, 150)
            serverCard.Position = UDim2.new(0, 20, 0, yOffset)
            serverCard.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            serverCard.Parent = dashboardFrame
            
            local serverCorner = Instance.new("UICorner")
            serverCorner.CornerRadius = UDim.new(0, 10)
            serverCorner.Parent = serverCard
            
            local serverTitle = Instance.new("TextLabel")
            serverTitle.Text = "🖥️ Server Information"
            serverTitle.Size = UDim2.new(1, -20, 0, 30)
            serverTitle.Position = UDim2.new(0, 10, 0, 10)
            serverTitle.BackgroundTransparency = 1
            serverTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
            serverTitle.Font = Enum.Font.GothamBold
            serverTitle.TextSize = 16
            serverTitle.TextXAlignment = Enum.TextXAlignment.Left
            serverTitle.Parent = serverCard
            
            local playersText = Instance.new("TextLabel")
            playersText.Text = "👥 Spieler: " .. #Players:GetPlayers()
            playersText.Size = UDim2.new(0.5, -10, 0, 25)
            playersText.Position = UDim2.new(0, 10, 0, 50)
            playersText.BackgroundTransparency = 1
            playersText.TextColor3 = Color3.fromRGB(200, 200, 220)
            playersText.Font = Enum.Font.Gotham
            playersText.TextSize = 14
            playersText.TextXAlignment = Enum.TextXAlignment.Left
            playersText.Parent = serverCard
            
            local placeIdText = Instance.new("TextLabel")
            placeIdText.Text = "📍 Place ID: " .. game.PlaceId
            placeIdText.Size = UDim2.new(0.5, -10, 0, 25)
            placeIdText.Position = UDim2.new(0.5, 0, 0, 50)
            placeIdText.BackgroundTransparency = 1
            placeIdText.TextColor3 = Color3.fromRGB(200, 200, 220)
            placeIdText.Font = Enum.Font.Gotham
            placeIdText.TextSize = 14
            placeIdText.TextXAlignment = Enum.TextXAlignment.Left
            placeIdText.Parent = serverCard
            
            local jobIdText = Instance.new("TextLabel")
            jobIdText.Text = "🔑 Job ID: " .. game.JobId
            jobIdText.Size = UDim2.new(1, -20, 0, 25)
            jobIdText.Position = UDim2.new(0, 10, 0, 80)
            jobIdText.BackgroundTransparency = 1
            jobIdText.TextColor3 = Color3.fromRGB(200, 200, 220)
            jobIdText.Font = Enum.Font.Gotham
            jobIdText.TextSize = 14
            jobIdText.TextXAlignment = Enum.TextXAlignment.Left
            jobIdText.Parent = serverCard
            
            local gameNameText = Instance.new("TextLabel")
            gameNameText.Text = "🎮 Spiel: " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
            gameNameText.Size = UDim2.new(1, -20, 0, 25)
            gameNameText.Position = UDim2.new(0, 10, 0, 110)
            gameNameText.BackgroundTransparency = 1
            gameNameText.TextColor3 = Color3.fromRGB(200, 200, 220)
            gameNameText.Font = Enum.Font.Gotham
            gameNameText.TextSize = 14
            gameNameText.TextXAlignment = Enum.TextXAlignment.Left
            gameNameText.TextTruncate = Enum.TextTruncate.AtEnd
            gameNameText.Parent = serverCard
            
            yOffset = yOffset + 170
            
            -- Admin-Info Card
            local adminCard = Instance.new("Frame")
            adminCard.Size = UDim2.new(1, -40, 0, 130)
            adminCard.Position = UDim2.new(0, 20, 0, yOffset)
            adminCard.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            adminCard.Parent = dashboardFrame
            
            local adminCorner = Instance.new("UICorner")
            adminCorner.CornerRadius = UDim.new(0, 10)
            adminCorner.Parent = adminCard
            
            local adminTitle = Instance.new("TextLabel")
            adminTitle.Text = "👤 Admin Information"
            adminTitle.Size = UDim2.new(1, -20, 0, 30)
            adminTitle.Position = UDim2.new(0, 10, 0, 10)
            adminTitle.BackgroundTransparency = 1
            adminTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
            adminTitle.Font = Enum.Font.GothamBold
            adminTitle.TextSize = 16
            adminTitle.TextXAlignment = Enum.TextXAlignment.Left
            adminTitle.Parent = adminCard
            
            local adminNameText = Instance.new("TextLabel")
            adminNameText.Text = "Name: " .. LP.Name
            adminNameText.Size = UDim2.new(0.5, -10, 0, 25)
            adminNameText.Position = UDim2.new(0, 10, 0, 50)
            adminNameText.BackgroundTransparency = 1
            adminNameText.TextColor3 = Color3.fromRGB(200, 200, 220)
            adminNameText.Font = Enum.Font.Gotham
            adminNameText.TextSize = 14
            adminNameText.TextXAlignment = Enum.TextXAlignment.Left
            adminNameText.Parent = adminCard
            
            local adminDisplayText = Instance.new("TextLabel")
            adminDisplayText.Text = "Anzeige: " .. (LP.DisplayName or "N/A")
            adminDisplayText.Size = UDim2.new(0.5, -10, 0, 25)
            adminDisplayText.Position = UDim2.new(0.5, 0, 0, 50)
            adminDisplayText.BackgroundTransparency = 1
            adminDisplayText.TextColor3 = Color3.fromRGB(200, 200, 220)
            adminDisplayText.Font = Enum.Font.Gotham
            adminDisplayText.TextSize = 14
            adminDisplayText.TextXAlignment = Enum.TextXAlignment.Left
            adminDisplayText.Parent = adminCard
            
            local adminIdText = Instance.new("TextLabel")
            adminIdText.Text = "ID: " .. LP.UserId
            adminIdText.Size = UDim2.new(1, -20, 0, 25)
            adminIdText.Position = UDim2.new(0, 10, 0, 80)
            adminIdText.BackgroundTransparency = 1
            adminIdText.TextColor3 = Color3.fromRGB(200, 200, 220)
            adminIdText.Font = Enum.Font.Gotham
            adminIdText.TextSize = 14
            adminIdText.TextXAlignment = Enum.TextXAlignment.Left
            adminIdText.Parent = adminCard
            
            dashboardFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 150)
            
        elseif tabId == "players" then
            -- Spielerliste mit Suchleiste
            local playersFrame = Instance.new("Frame")
            playersFrame.Name = "PlayersFrame"
            playersFrame.Size = UDim2.new(1, 0, 1, 0)
            playersFrame.BackgroundTransparency = 1
            playersFrame.Parent = contentArea
            
            -- Suchleiste
            local searchContainer = Instance.new("Frame")
            searchContainer.Size = UDim2.new(1, -20, 0, 50)
            searchContainer.Position = UDim2.new(0, 10, 0, 10)
            searchContainer.BackgroundTransparency = 1
            searchContainer.Parent = playersFrame
            
            local searchBar = Instance.new("TextBox")
            searchBar.Name = "SearchBar"
            searchBar.PlaceholderText = "🔍 Nach Spielern suchen..."
            searchBar.Size = UDim2.new(1, -100, 1, 0)
            searchBar.Position = UDim2.new(0, 0, 0, 0)
            searchBar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            searchBar.TextColor3 = Color3.fromRGB(255, 255, 255)
            searchBar.Font = Enum.Font.Gotham
            searchBar.TextSize = 14
            searchBar.Text = ""
            searchBar.Parent = searchContainer
            
            local searchCorner = Instance.new("UICorner")
            searchCorner.CornerRadius = UDim.new(0, 8)
            searchCorner.Parent = searchBar
            
            local playerCountText = Instance.new("TextLabel")
            playerCountText.Text = "Spieler: 0"
            playerCountText.Size = UDim2.new(0, 90, 1, 0)
            playerCountText.Position = UDim2.new(1, -90, 0, 0)
            playerCountText.BackgroundTransparency = 1
            playerCountText.TextColor3 = Color3.fromRGB(200, 200, 220)
            playerCountText.Font = Enum.Font.Gotham
            playerCountText.TextSize = 14
            playerCountText.TextXAlignment = Enum.TextXAlignment.Right
            playerCountText.Parent = searchContainer
            
            -- Scrollbare Spielerliste
            local playersList = Instance.new("ScrollingFrame")
            playersList.Name = "PlayersList"
            playersList.Size = UDim2.new(1, -20, 1, -70)
            playersList.Position = UDim2.new(0, 10, 0, 70)
            playersList.BackgroundTransparency = 1
            playersList.ScrollBarThickness = 8
            playersList.Parent = playersFrame
            
            -- Funktion zum Laden der Spielerliste
            local function loadPlayerList(searchTerm)
                for _, child in pairs(playersList:GetChildren()) do
                    if child:IsA("Frame") then
                        child:Destroy()
                    end
                end
                
                local yOffset = 0
                local playerCount = 0
                
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LP then
                        local displayName = player.DisplayName or player.Name
                        local username = player.Name
                        
                        if searchTerm == "" or 
                           string.find(string.lower(displayName), string.lower(searchTerm)) or
                           string.find(string.lower(username), string.lower(searchTerm)) then
                            
                            playerCount = playerCount + 1
                            
                            local playerEntry = Instance.new("Frame")
                            playerEntry.Name = "Player_" .. username
                            playerEntry.Size = UDim2.new(1, 0, 0, 70)
                            playerEntry.Position = UDim2.new(0, 0, 0, yOffset)
                            playerEntry.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
                            playerEntry.Parent = playersList
                            
                            local entryCorner = Instance.new("UICorner")
                            entryCorner.CornerRadius = UDim.new(0, 8)
                            entryCorner.Parent = playerEntry
                            
                            -- Avatar
                            local avatarFrame = Instance.new("Frame")
                            avatarFrame.Size = UDim2.new(0, 50, 0, 50)
                            avatarFrame.Position = UDim2.new(0, 10, 0, 10)
                            avatarFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                            avatarFrame.Parent = playerEntry
                            
                            local avatarCorner = Instance.new("UICorner")
                            avatarCorner.CornerRadius = UDim.new(0, 6)
                            avatarCorner.Parent = avatarFrame
                            
                            -- Spielerinfo
                            local infoFrame = Instance.new("Frame")
                            infoFrame.Size = UDim2.new(0.5, -70, 1, -20)
                            infoFrame.Position = UDim2.new(0, 70, 0, 10)
                            infoFrame.BackgroundTransparency = 1
                            infoFrame.Parent = playerEntry
                            
                            local nameLabel = Instance.new("TextLabel")
                            nameLabel.Text = displayName
                            nameLabel.Size = UDim2.new(1, 0, 0, 25)
                            nameLabel.Position = UDim2.new(0, 0, 0, 0)
                            nameLabel.BackgroundTransparency = 1
                            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                            nameLabel.Font = Enum.Font.GothamBold
                            nameLabel.TextSize = 14
                            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
                            nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
                            nameLabel.Parent = infoFrame
                            
                            local userLabel = Instance.new("TextLabel")
                            userLabel.Text = "@" .. username
                            userLabel.Size = UDim2.new(1, 0, 0, 20)
                            userLabel.Position = UDim2.new(0, 0, 0, 25)
                            userLabel.BackgroundTransparency = 1
                            userLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
                            userLabel.Font = Enum.Font.Gotham
                            userLabel.TextSize = 12
                            userLabel.TextXAlignment = Enum.TextXAlignment.Left
                            userLabel.Parent = infoFrame
                            
                            -- Aktionen
                            local actionsFrame = Instance.new("Frame")
                            actionsFrame.Size = UDim2.new(0.4, -10, 1, -20)
                            actionsFrame.Position = UDim2.new(0.6, 0, 0, 10)
                            actionsFrame.BackgroundTransparency = 1
                            actionsFrame.Parent = playerEntry
                            
                            -- Inspect Button (Lupe)
                            local inspectBtn = Instance.new("TextButton")
                            inspectBtn.Text = "🔍"
                            inspectBtn.Size = UDim2.new(0, 40, 0, 40)
                            inspectBtn.Position = UDim2.new(0, 0, 0, 0)
                            inspectBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 180)
                            inspectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                            inspectBtn.Font = Enum.Font.GothamBold
                            inspectBtn.TextSize = 16
                            inspectBtn.Parent = actionsFrame
                            
                            local inspectCorner = Instance.new("UICorner")
                            inspectCorner.CornerRadius = UDim.new(0, 6)
                            inspectCorner.Parent = inspectBtn
                            
                            -- Kick Button
                            local kickBtn = Instance.new("TextButton")
                            kickBtn.Text = "🚪"
                            kickBtn.Size = UDim2.new(0, 40, 0, 40)
                            kickBtn.Position = UDim2.new(0, 50, 0, 0)
                            kickBtn.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
                            kickBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                            kickBtn.Font = Enum.Font.GothamBold
                            kickBtn.TextSize = 14
                            kickBtn.Parent = actionsFrame
                            
                            local kickCorner = Instance.new("UICorner")
                            kickCorner.CornerRadius = UDim.new(0, 6)
                            kickCorner.Parent = kickBtn
                            
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
                            
                            yOffset = yOffset + 80
                        end
                    end
                end
                
                playersList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
                playerCountText.Text = "Spieler: " .. playerCount
                
                if playerCount == 0 then
                    local noPlayers = Instance.new("TextLabel")
                    noPlayers.Text = "Keine Spieler gefunden"
                    noPlayers.Size = UDim2.new(1, 0, 0, 50)
                    noPlayers.Position = UDim2.new(0, 0, 0, 10)
                    noPlayers.BackgroundTransparency = 1
                    noPlayers.TextColor3 = Color3.fromRGB(150, 150, 150)
                    noPlayers.Font = Enum.Font.Gotham
                    noPlayers.TextSize = 14
                    noPlayers.Parent = playersList
                end
            end
            
            searchBar:GetPropertyChangedSignal("Text"):Connect(function()
                loadPlayerList(searchBar.Text)
            end)
            
            loadPlayerList("")
            
        elseif tabId == "tools" then
            -- Tools Tab mit ESP
            local toolsFrame = Instance.new("ScrollingFrame")
            toolsFrame.Name = "ToolsFrame"
            toolsFrame.Size = UDim2.new(1, 0, 1, 0)
            toolsFrame.BackgroundTransparency = 1
            toolsFrame.ScrollBarThickness = 6
            toolsFrame.Parent = contentArea
            
            local yOffset = 20
            
            -- ESP Section
            local espCard = Instance.new("Frame")
            espCard.Size = UDim2.new(1, -40, 0, 180)
            espCard.Position = UDim2.new(0, 20, 0, yOffset)
            espCard.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            espCard.Parent = toolsFrame
            
            local espCorner = Instance.new("UICorner")
            espCorner.CornerRadius = UDim.new(0, 10)
            espCorner.Parent = espCard
            
            local espTitle = Instance.new("TextLabel")
            espTitle.Text = "👁️ ESP (Sichtbarkeit)"
            espTitle.Size = UDim2.new(1, -20, 0, 40)
            espTitle.Position = UDim2.new(0, 10, 0, 10)
            espTitle.BackgroundTransparency = 1
            espTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
            espTitle.Font = Enum.Font.GothamBold
            espTitle.TextSize = 18
            espTitle.TextXAlignment = Enum.TextXAlignment.Left
            espTitle.Parent = espCard
            
            local espDesc = Instance.new("TextLabel")
            espDesc.Text = "Zeigt Spieler durch Wände an\n(Achtung: Performance-Intensiv!)"
            espDesc.Size = UDim2.new(1, -20, 0, 40)
            espDesc.Position = UDim2.new(0, 10, 0, 50)
            espDesc.BackgroundTransparency = 1
            espDesc.TextColor3 = Color3.fromRGB(200, 200, 220)
            espDesc.Font = Enum.Font.Gotham
            espDesc.TextSize = 12
            espDesc.TextXAlignment = Enum.TextXAlignment.Left
            espDesc.TextYAlignment = Enum.TextYAlignment.Top
            espDesc.Parent = espCard
            
            -- ESP Toggle
            local espToggle = Instance.new("TextButton")
            espToggle.Text = ESP_ENABLED and "✅ ESP AKTIV" or "❌ ESP INAKTIV"
            espToggle.Size = UDim2.new(1, -40, 0, 45)
            espToggle.Position = UDim2.new(0, 20, 0, 100)
            espToggle.BackgroundColor3 = ESP_ENABLED and Color3.fromRGB(60, 160, 60) or Color3.fromRGB(160, 60, 60)
            espToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
            espToggle.Font = Enum.Font.GothamBold
            espToggle.TextSize = 16
            espToggle.Parent = espCard
            
            local toggleCorner = Instance.new("UICorner")
            toggleCorner.CornerRadius = UDim.new(0, 8)
            toggleCorner.Parent = espToggle
            
            espToggle.MouseButton1Click:Connect(function()
                ESP_ENABLED = not ESP_ENABLED
                toggleESP(ESP_ENABLED)
                espToggle.Text = ESP_ENABLED and "✅ ESP AKTIV" or "❌ ESP INAKTIV"
                espToggle.BackgroundColor3 = ESP_ENABLED and Color3.fromRGB(60, 160, 60) or Color3.fromRGB(160, 60, 60)
                
                pcall(function()
                    StarterGui:SetCore("SendNotification", {
                        Title = ESP_ENABLED and "✅ ESP aktiviert" or "❌ ESP deaktiviert",
                        Text = ESP_ENABLED and "Spieler werden angezeigt" or "ESP ausgeschaltet",
                        Duration = 2
                    })
                end)
            end)
            
            yOffset = yOffset + 200
            
            -- Info Card
            local infoCard = Instance.new("Frame")
            infoCard.Size = UDim2.new(1, -40, 0, 120)
            infoCard.Position = UDim2.new(0, 20, 0, yOffset)
            infoCard.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            infoCard.Parent = toolsFrame
            
            local infoCorner = Instance.new("UICorner")
            infoCorner.CornerRadius = UDim.new(0, 10)
            infoCorner.Parent = infoCard
            
            local infoTitle = Instance.new("TextLabel")
            infoTitle.Text = "ℹ️ Info"
            infoTitle.Size = UDim2.new(1, -20, 0, 30)
            infoTitle.Position = UDim2.new(0, 10, 0, 10)
            infoTitle.BackgroundTransparency = 1
            infoTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
            infoTitle.Font = Enum.Font.GothamBold
            infoTitle.TextSize = 16
            infoTitle.TextXAlignment = Enum.TextXAlignment.Left
            infoTitle.Parent = infoCard
            
            local infoText = Instance.new("TextLabel")
            infoText.Text = "ESP zeigt:\n• Grüne Box um Spieler\n• Namen über Spielern\n• Funktioniert durch Wände"
            infoText.Size = UDim2.new(1, -20, 0, 80)
            infoText.Position = UDim2.new(0, 10, 0, 40)
            infoText.BackgroundTransparency = 1
            infoText.TextColor3 = Color3.fromRGB(200, 200, 220)
            infoText.Font = Enum.Font.Gotham
            infoText.TextSize = 12
            infoText.TextXAlignment = Enum.TextXAlignment.Left
            infoText.TextYAlignment = Enum.TextYAlignment.Top
            infoText.Parent = infoCard
            
            toolsFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 140)
            
        elseif tabId == "settings" then
            -- Settings Tab
            local settingsFrame = Instance.new("ScrollingFrame")
            settingsFrame.Name = "SettingsFrame"
            settingsFrame.Size = UDim2.new(1, 0, 1, 0)
            settingsFrame.BackgroundTransparency = 1
            settingsFrame.ScrollBarThickness = 6
            settingsFrame.Parent = contentArea
            
            local yOffset = 20
            
            -- Version Card
            local versionCard = Instance.new("Frame")
            versionCard.Size = UDim2.new(1, -40, 0, 100)
            versionCard.Position = UDim2.new(0, 20, 0, yOffset)
            versionCard.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            versionCard.Parent = settingsFrame
            
            local versionCorner = Instance.new("UICorner")
            versionCorner.CornerRadius = UDim.new(0, 10)
            versionCorner.Parent = versionCard
            
            local versionTitle = Instance.new("TextLabel")
            versionTitle.Text = "📦 Script Information"
            versionTitle.Size = UDim2.new(1, -20, 0, 30)
            versionTitle.Position = UDim2.new(0, 10, 0, 10)
            versionTitle.BackgroundTransparency = 1
            versionTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
            versionTitle.Font = Enum.Font.GothamBold
            versionTitle.TextSize = 16
            versionTitle.TextXAlignment = Enum.TextXAlignment.Left
            versionTitle.Parent = versionCard
            
            local versionText = Instance.new("TextLabel")
            versionText.Text = "Admin Panel Ultimate " .. SCRIPT_VERSION .. "\nErstellt für Roblox Admin"
            versionText.Size = UDim2.new(1, -20, 0, 60)
            versionText.Position = UDim2.new(0, 10, 0, 40)
            versionText.BackgroundTransparency = 1
            versionText.TextColor3 = Color3.fromRGB(200, 200, 220)
            versionText.Font = Enum.Font.Gotham
            versionText.TextSize = 14
            versionText.TextXAlignment = Enum.TextXAlignment.Left
            versionText.Parent = versionCard
            
            yOffset = yOffset + 120
            
            -- Hotkeys Card
            local hotkeysCard = Instance.new("Frame")
            hotkeysCard.Size = UDim2.new(1, -40, 0, 150)
            hotkeysCard.Position = UDim2.new(0, 20, 0, yOffset)
            hotkeysCard.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            hotkeysCard.Parent = settingsFrame
            
            local hotkeysCorner = Instance.new("UICorner")
            hotkeysCorner.CornerRadius = UDim.new(0, 10)
            hotkeysCorner.Parent = hotkeysCard
            
            local hotkeysTitle = Instance.new("TextLabel")
            hotkeysTitle.Text = "⌨️ Hotkeys"
            hotkeysTitle.Size = UDim2.new(1, -20, 0, 30)
            hotkeysTitle.Position = UDim2.new(0, 10, 0, 10)
            hotkeysTitle.BackgroundTransparency = 1
            hotkeysTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
            hotkeysTitle.Font = Enum.Font.GothamBold
            hotkeysTitle.TextSize = 16
            hotkeysTitle.TextXAlignment = Enum.TextXAlignment.Left
            hotkeysTitle.Parent = hotkeysCard
            
            local hotkeysList = Instance.new("TextLabel")
            hotkeysList.Text = "P = Nächstgelegenen Spieler kopieren\nF2 = Admin Panel öffnen/schließen\nESC = Alle GUIs schließen\n\nIm Panel:\n🔍 = Spieler inspizieren\n📋 = Wert kopieren\n🚀 = Bring-Befehl kopieren\n📍 = TP2-Befehl kopieren"
            hotkeysList.Size = UDim2.new(1, -20, 0, 110)
            hotkeysList.Position = UDim2.new(0, 10, 0, 40)
            hotkeysList.BackgroundTransparency = 1
            hotkeysList.TextColor3 = Color3.fromRGB(200, 200, 220)
            hotkeysList.Font = Enum.Font.Gotham
            hotkeysList.TextSize = 13
            hotkeysList.TextXAlignment = Enum.TextXAlignment.Left
            hotkeysList.TextYAlignment = Enum.TextYAlignment.Top
            hotkeysList.Parent = hotkeysCard
            
            yOffset = yOffset + 170
            
            -- Performance Card
            local perfCard = Instance.new("Frame")
            perfCard.Size = UDim2.new(1, -40, 0, 100)
            perfCard.Position = UDim2.new(0, 20, 0, yOffset)
            perfCard.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            perfCard.Parent = settingsFrame
            
            local perfCorner = Instance.new("UICorner")
            perfCorner.CornerRadius = UDim.new(0, 10)
            perfCorner.Parent = perfCard
            
            local perfTitle = Instance.new("TextLabel")
            perfTitle.Text = "⚡ Performance"
            perfTitle.Size = UDim2.new(1, -20, 0, 30)
            perfTitle.Position = UDim2.new(0, 10, 0, 10)
            perfTitle.BackgroundTransparency = 1
            perfTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
            perfTitle.Font = Enum.Font.GothamBold
            perfTitle.TextSize = 16
            perfTitle.TextXAlignment = Enum.TextXAlignment.Left
            perfTitle.Parent = perfCard
            
            local perfText = Instance.new("TextLabel")
            perfText.Text = "Alle Features sind performance-optimiert:\n• ESP nur bei Aktivierung\n• Live-Daten nur bei Bedarf\n• Keine unnötigen Updates"
            perfText.Size = UDim2.new(1, -20, 0, 60)
            perfText.Position = UDim2.new(0, 10, 0, 40)
            perfText.BackgroundTransparency = 1
            perfText.TextColor3 = Color3.fromRGB(200, 200, 220)
            perfText.Font = Enum.Font.Gotham
            perfText.TextSize = 12
            perfText.TextXAlignment = Enum.TextXAlignment.Left
            perfText.TextYAlignment = Enum.TextYAlignment.Top
            perfText.Parent = perfCard
            
            settingsFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 120)
        end
    end
    
    -- Tab-Buttons erstellen
    for i, tab in ipairs(tabs) do
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tab.id .. "Tab"
        tabButton.Text = "  " .. tab.name
        tabButton.Size = UDim2.new(1, -20, 0, 55)
        tabButton.Position = UDim2.new(0, 10, 0, 20 + (i-1) * 65)
        
        if tab.id == activeTab then
            tabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            tabButton.TextColor3 = Color3.fromRGB(255, 215, 0)
        else
            tabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            tabButton.TextColor3 = Color3.fromRGB(220, 220, 230)
        end
        
        tabButton.Font = Enum.Font.Gotham
        tabButton.TextSize = 15
        tabButton.TextXAlignment = Enum.TextXAlignment.Left
        tabButton.Parent = sidebar
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 8)
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
    
    print("✅ Admin Panel Ultimate geöffnet")
end

local function toggleAdminPanel()
    if isPanelOpen then
        closeAdminPanel()
    else
        openAdminPanel()
    end
end

-- ============================================
-- TEIL 4: INPUT HANDLER & AUTO-CLOSE
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
-- TEIL 5: STARTUP & CLEANUP
-- ============================================

print("✅ Admin Panel Ultimate " .. SCRIPT_VERSION .. " initialisiert")
print("✅ Alle Systeme bereit")
print("✅ Performance optimiert")

if getgenv then
    getgenv().AdminCopyName = copyNearestPlayer
    getgenv().AdminOpenPanel = openAdminPanel
    getgenv().AdminClosePanel = closeAdminPanel
    getgenv().AdminTogglePanel = toggleAdminPanel
    getgenv().AdminToggleESP = function()
        ESP_ENABLED = not ESP_ENABLED
        toggleESP(ESP_ENABLED)
        return ESP_ENABLED
    end
    getgenv().AdminCleanup = function()
        closeMiniMenu()
        closeAdminPanel()
        closeInspectGui()
        toggleESP(false)
        print("🛑 Admin Panel komplett bereinigt")
    end
end

return "✅ ADMIN PANEL ULTIMATE " .. SCRIPT_VERSION .. " - BEREIT"
