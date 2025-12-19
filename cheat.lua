-- Simple Name Copy - Admin Version mit Panel
-- P = Kopieren + Admin-Menü | F2 = Admin Panel

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local TextService = game:GetService("TextService")
local LP = Players.LocalPlayer

-- Start message
print("=== Admin Script v2 ===")
print("P = Name kopieren + Mini-Menü")
print("F2 = Admin Panel öffnen/schließen")
print("ESC schließt alle GUIs")

-- Notification
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "🛡️ Admin Script aktiv",
        Text = "P = Name | F2 = Panel | ESC = Schließen",
        Duration = 4
    })
end)

-- ============================
-- TEIL 1: Mini-Menü (Name Copy)
-- ============================

-- Einfacher Player Cache
local allPlayers = {}
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LP then
        allPlayers[#allPlayers + 1] = p
    end
end

Players.PlayerAdded:Connect(function(p)
    if p ~= LP then
        allPlayers[#allPlayers + 1] = p
    end
end)

Players.PlayerRemoving:Connect(function(p)
    for i = #allPlayers, 1, -1 do
        if allPlayers[i] == p then
            table.remove(allPlayers, i)
            break
        end
    end
end)

-- Mini-Menü GUI
local miniGui = nil
local miniGuiTimeout = 0

local function destroyMiniGui()
    if miniGui then
        miniGui:Destroy()
        miniGui = nil
        miniGuiTimeout = 0
    end
end

local function createMiniGui(username, displayName, hp, dist)
    destroyMiniGui()
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AdminMiniGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 8  -- Unter dem Admin-Panel
    
    -- Haupt-Frame (verschoben, um Benachrichtigungen nicht zu überlappen)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 220, 0, 160)
    mainFrame.Position = UDim2.new(1, -230, 1, -220)  -- Höher gesetzt (-220 statt -170)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    mainFrame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    local shadow = Instance.new("UIStroke")
    shadow.Color = Color3.fromRGB(0, 0, 0)
    shadow.Thickness = 2
    shadow.Parent = mainFrame
    
    -- GUI-Inhalt (gleiche wie vorher, gekürzt für Übersicht)
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
    
    -- ... (restlicher Mini-GUI Code wie vorher) ...
    
    screenGui.Parent = LP:WaitForChild("PlayerGui")
    miniGui = screenGui
    miniGuiTimeout = tick() + 5
    
    return screenGui
end

local function findAndCopy()
    local char = LP.Character
    if not char then return false end
    
    local myRoot = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
    if not myRoot then return false end
    
    local myPos = myRoot.Position
    local nearest = nil
    local minDist = math.huge
    local hp = 100
    local display = ""
    
    for i = 1, #allPlayers do
        local p = allPlayers[i]
        local targetChar = p.Character
        if targetChar then
            local targetRoot = targetChar:FindFirstChild("HumanoidRootPart") or targetChar.PrimaryPart
            if targetRoot then
                local dist = (myPos - targetRoot.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearest = p
                    display = p.DisplayName
                    
                    local hum = targetChar:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hp = math.floor(hum.Health)
                    end
                end
            end
        end
    end
    
    if nearest then
        local username = nearest.Name
        
        if setclipboard then
            setclipboard(username)
        end
        
        createMiniGui(username, display, hp, minDist)
        
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "✅ " .. display,
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

-- ============================
-- TEIL 2: Admin Panel
-- ============================

local adminPanel = nil
local panelOpen = false
local currentPanelTab = "dashboard"
local playerListData = {}
local playerDetailCache = {}
local espEnabled = false
local espConnections = {}

-- Hammer Symbol Button (Toggle)
local function createHammerButton()
    local hammerGui = Instance.new("ScreenGui")
    hammerGui.Name = "HammerToggle"
    hammerGui.ResetOnSpawn = false
    hammerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    hammerGui.DisplayOrder = 9
    
    local hammerBtn = Instance.new("TextButton")
    hammerBtn.Name = "HammerButton"
    hammerBtn.Text = "⚒️"
    hammerBtn.Size = UDim2.new(0, 45, 0, 45)
    hammerBtn.Position = UDim2.new(0, 20, 1, -75)  -- Unten links
    hammerBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    hammerBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
    hammerBtn.Font = Enum.Font.GothamBold
    hammerBtn.TextSize = 20
    hammerBtn.AutoButtonColor = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = hammerBtn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 80, 90)
    stroke.Thickness = 2
    stroke.Parent = hammerBtn
    
    -- Hover Effect
    hammerBtn.MouseEnter:Connect(function()
        hammerBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    end)
    hammerBtn.MouseLeave:Connect(function()
        hammerBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    end)
    
    -- Toggle Panel
    hammerBtn.MouseButton1Click:Connect(function()
        toggleAdminPanel()
    end)
    
    hammerBtn.Parent = hammerGui
    hammerGui.Parent = LP:WaitForChild("PlayerGui")
    
    return hammerGui
end

-- Panel Toggle
local function toggleAdminPanel()
    if panelOpen then
        destroyAdminPanel()
    else
        createAdminPanel()
    end
end

-- Panel zerstören (Performance: alles aufräumen)
local function destroyAdminPanel()
    if adminPanel then
        adminPanel:Destroy()
        adminPanel = nil
    end
    panelOpen = false
    
    -- ESP ausschalten wenn Panel geschlossen
    if espEnabled then
        toggleESP(false)
    end
    
    -- Cache leeren
    playerListData = {}
    playerDetailCache = {}
end

-- Dashboard Inhalt (Performance: nur wenn benötigt)
local function createDashboardContent(parentFrame)
    local container = Instance.new("ScrollingFrame")
    container.Name = "DashboardContent"
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.ScrollBarThickness = 6
    container.ScrollingDirection = Enum.ScrollingDirection.Y
    container.Parent = parentFrame
    
    -- Server Info
    local serverInfo = Instance.new("Frame")
    serverInfo.Name = "ServerInfo"
    serverInfo.Size = UDim2.new(1, -20, 0, 120)
    serverInfo.Position = UDim2.new(0, 10, 0, 10)
    serverInfo.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    serverInfo.Parent = container
    
    local serverTitle = Instance.new("TextLabel")
    serverTitle.Text = "🖥️ Server Information"
    serverTitle.Size = UDim2.new(1, -20, 0, 30)
    serverTitle.Position = UDim2.new(0, 10, 0, 5)
    serverTitle.BackgroundTransparency = 1
    serverTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
    serverTitle.Font = Enum.Font.GothamBold
    serverTitle.TextSize = 16
    serverTitle.TextXAlignment = Enum.TextXAlignment.Left
    serverTitle.Parent = serverInfo
    
    local playersText = Instance.new("TextLabel")
    playersText.Text = string.format("👥 Spieler: %d/%d", #Players:GetPlayers(), game.PrivateServerMaxPlayers or 12)
    playersText.Size = UDim2.new(0.5, -15, 0, 25)
    playersText.Position = UDim2.new(0, 10, 0, 40)
    playersText.BackgroundTransparency = 1
    playersText.TextColor3 = Color3.fromRGB(200, 200, 220)
    playersText.Font = Enum.Font.Gotham
    playersText.TextSize = 14
    playersText.TextXAlignment = Enum.TextXAlignment.Left
    playersText.Parent = serverInfo
    
    local placeIdText = Instance.new("TextLabel")
    placeIdText.Text = "📍 Place ID: " .. game.PlaceId
    placeIdText.Size = UDim2.new(0.5, -15, 0, 25)
    placeIdText.Position = UDim2.new(0.5, 5, 0, 40)
    placeIdText.BackgroundTransparency = 1
    placeIdText.TextColor3 = Color3.fromRGB(200, 200, 220)
    placeIdText.Font = Enum.Font.Gotham
    placeIdText.TextSize = 14
    placeIdText.TextXAlignment = Enum.TextXAlignment.Left
    placeIdText.Parent = serverInfo
    
    local jobIdText = Instance.new("TextLabel")
    jobIdText.Text = "🔑 Job ID: " .. game.JobId
    jobIdText.Size = UDim2.new(1, -20, 0, 25)
    jobIdText.Position = UDim2.new(0, 10, 0, 70)
    jobIdText.BackgroundTransparency = 1
    jobIdText.TextColor3 = Color3.fromRGB(200, 200, 220)
    jobIdText.Font = Enum.Font.Gotham
    jobIdText.TextSize = 14
    jobIdText.TextXAlignment = Enum.TextXAlignment.Left
    jobIdText.TextTruncate = Enum.TextTruncate.AtEnd
    jobIdText.Parent = serverInfo
    
    -- Local Player Info
    local playerInfo = Instance.new("Frame")
    playerInfo.Name = "PlayerInfo"
    playerInfo.Size = UDim2.new(1, -20, 0, 100)
    playerInfo.Position = UDim2.new(0, 10, 0, 140)
    playerInfo.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    playerInfo.Parent = container
    
    local playerTitle = Instance.new("TextLabel")
    playerTitle.Text = "👤 Lokaler Spieler"
    playerTitle.Size = UDim2.new(1, -20, 0, 30)
    playerTitle.Position = UDim2.new(0, 10, 0, 5)
    playerTitle.BackgroundTransparency = 1
    playerTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
    playerTitle.Font = Enum.Font.GothamBold
    playerTitle.TextSize = 16
    playerTitle.TextXAlignment = Enum.TextXAlignment.Left
    playerTitle.Parent = playerInfo
    
    local nameText = Instance.new("TextLabel")
    nameText.Text = "Name: " .. LP.Name
    nameText.Size = UDim2.new(0.5, -15, 0, 25)
    nameText.Position = UDim2.new(0, 10, 0, 40)
    nameText.BackgroundTransparency = 1
    nameText.TextColor3 = Color3.fromRGB(200, 200, 220)
    nameText.Font = Enum.Font.Gotham
    nameText.TextSize = 14
    nameText.TextXAlignment = Enum.TextXAlignment.Left
    nameText.Parent = playerInfo
    
    local displayText = Instance.new("TextLabel")
    displayText.Text = "Anzeige: " .. LP.DisplayName
    displayText.Size = UDim2.new(0.5, -15, 0, 25)
    displayText.Position = UDim2.new(0.5, 5, 0, 40)
    displayText.BackgroundTransparency = 1
    displayText.TextColor3 = Color3.fromRGB(200, 200, 220)
    displayText.Font = Enum.Font.Gotham
    displayText.TextSize = 14
    displayText.TextXAlignment = Enum.TextXAlignment.Left
    displayText.Parent = playerInfo
    
    local userIdText = Instance.new("TextLabel")
    userIdText.Text = "User ID: " .. tostring(LP.UserId)
    userIdText.Size = UDim2.new(1, -20, 0, 25)
    userIdText.Position = UDim2.new(0, 10, 0, 70)
    userIdText.BackgroundTransparency = 1
    userIdText.TextColor3 = Color3.fromRGB(200, 200, 220)
    userIdText.Font = Enum.Font.Gotham
    userIdText.TextSize = 14
    userIdText.TextXAlignment = Enum.TextXAlignment.Left
    userIdText.Parent = playerInfo
    
    -- Live Uhrzeit (nur wenn Panel offen)
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Name = "TimeLabel"
    timeLabel.Text = "🕒 Uhrzeit: --:--:--"
    timeLabel.Size = UDim2.new(1, -20, 0, 25)
    timeLabel.Position = UDim2.new(0, 10, 0, 250)
    timeLabel.BackgroundTransparency = 1
    timeLabel.TextColor3 = Color3.fromRGB(150, 220, 150)
    timeLabel.Font = Enum.Font.GothamBold
    timeLabel.TextSize = 14
    timeLabel.TextXAlignment = Enum.TextXAlignment.Left
    timeLabel.Parent = container
    
    -- Live Update (nur wenn Panel offen)
    local timeConnection
    timeConnection = RunService.Heartbeat:Connect(function()
        if not panelOpen then
            timeConnection:Disconnect()
            return
        end
        local time = os.date("%H:%M:%S")
        timeLabel.Text = "🕒 Uhrzeit: " .. time
    end)
    
    container.CanvasSize = UDim2.new(0, 0, 0, 300)
    return container
end

-- Spielerliste (Performance: nur laden wenn Tab aktiv)
local function createPlayerListContent(parentFrame)
    local container = Instance.new("ScrollingFrame")
    container.Name = "PlayerListContent"
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.ScrollBarThickness = 6
    container.ScrollingDirection = Enum.ScrollingDirection.Y
    container.Parent = parentFrame
    
    local yOffset = 10
    playerListData = {}
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP then
            local playerFrame = Instance.new("Frame")
            playerFrame.Name = "Player_" .. player.Name
            playerFrame.Size = UDim2.new(1, -20, 0, 60)
            playerFrame.Position = UDim2.new(0, 10, 0, yOffset)
            playerFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            playerFrame.Parent = container
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = playerFrame
            
            -- Spielername
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Text = player.DisplayName
            nameLabel.Size = UDim2.new(0.7, -10, 0, 25)
            nameLabel.Position = UDim2.new(0, 10, 0, 5)
            nameLabel.BackgroundTransparency = 1
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextSize = 14
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
            nameLabel.Parent = playerFrame
            
            local usernameLabel = Instance.new("TextLabel")
            usernameLabel.Text = "@" .. player.Name
            usernameLabel.Size = UDim2.new(0.7, -10, 0, 20)
            usernameLabel.Position = UDim2.new(0, 10, 0, 30)
            usernameLabel.BackgroundTransparency = 1
            usernameLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
            usernameLabel.Font = Enum.Font.Gotham
            usernameLabel.TextSize = 12
            usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
            usernameLabel.Parent = playerFrame
            
            -- Aktionen Buttons
            local actionsFrame = Instance.new("Frame")
            actionsFrame.Name = "Actions"
            actionsFrame.Size = UDim2.new(0.3, -10, 1, -10)
            actionsFrame.Position = UDim2.new(0.7, 0, 0, 5)
            actionsFrame.BackgroundTransparency = 1
            actionsFrame.Parent = playerFrame
            
            local kickBtn = Instance.new("TextButton")
            kickBtn.Name = "KickBtn"
            kickBtn.Text = "🚪"
            kickBtn.Size = UDim2.new(0, 30, 0, 25)
            kickBtn.Position = UDim2.new(0, 0, 0, 0)
            kickBtn.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
            kickBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            kickBtn.Font = Enum.Font.GothamBold
            kickBtn.TextSize = 12
            kickBtn.Parent = actionsFrame
            
            local banBtn = Instance.new("TextButton")
            banBtn.Name = "BanBtn"
            banBtn.Text = "⛔"
            banBtn.Size = UDim2.new(0, 30, 0, 25)
            banBtn.Position = UDim2.new(0, 35, 0, 0)
            banBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
            banBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            banBtn.Font = Enum.Font.GothamBold
            banBtn.TextSize = 12
            banBtn.Parent = actionsFrame
            
            -- Hover Effects
            kickBtn.MouseButton1Click:Connect(function()
                local cmd = "/kick " .. player.Name
                if setclipboard then
                    setclipboard(cmd)
                end
                pcall(function()
                    StarterGui:SetCore("SendNotification", {
                        Title = "✅ Kick kopiert",
                        Text = cmd,
                        Duration = 2
                    })
                end)
            end)
            
            banBtn.MouseButton1Click:Connect(function()
                local cmd = "/ban " .. player.Name
                if setclipboard then
                    setclipboard(cmd)
                end
                pcall(function()
                    StarterGui:SetCore("SendNotification", {
                        Title = "✅ Ban kopiert",
                        Text = cmd,
                        Duration = 2
                    })
                end)
            end)
            
            -- Details anzeigen bei Klick
            playerFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    showPlayerDetails(player)
                end
            end)
            
            table.insert(playerListData, playerFrame)
            yOffset = yOffset + 70
        end
    end
    
    container.CanvasSize = UDim2.new(0, 0, 0, yOffset)
    return container
end

-- Spieler Details Popup
local function showPlayerDetails(player)
    if playerDetailCache[player] then
        playerDetailCache[player]:Destroy()
        playerDetailCache[player] = nil
        return
    end
    
    local detailGui = Instance.new("ScreenGui")
    detailGui.Name = "PlayerDetails"
    detailGui.ResetOnSpawn = false
    detailGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    detailGui.DisplayOrder = 100
    
    local detailFrame = Instance.new("Frame")
    detailFrame.Name = "DetailFrame"
    detailFrame.Size = UDim2.new(0, 300, 0, 250)
    detailFrame.Position = UDim2.new(0.5, -150, 0.5, -125)
    detailFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    detailFrame.Parent = detailGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = detailFrame
    
    -- Inhalt (ähnlich wie Mini-Menü aber mit mehr Infos)
    -- ... (gekürzt für Übersicht) ...
    
    detailGui.Parent = LP:WaitForChild("PlayerGui")
    playerDetailCache[player] = detailGui
    
    -- Schließen Button
    local closeBtn = detailFrame:FindFirstChild("CloseButton")
    if closeBtn then
        closeBtn.MouseButton1Click:Connect(function()
            detailGui:Destroy()
            playerDetailCache[player] = nil
        end)
    end
end

-- ESP System (Performance: nur wenn aktiviert)
local function toggleESP(enabled)
    espEnabled = enabled
    
    -- Alte Connections aufräumen
    for _, conn in pairs(espConnections) do
        conn:Disconnect()
    end
    espConnections = {}
    
    if not enabled then return end
    
    -- Nur wenn ESP aktiv ist, werden die Boxen erstellt
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP then
            local function updateESP()
                local char = player.Character
                if char then
                    -- ESP Box erstellen/updaten
                    -- ... (ESP-Logik hier) ...
                end
            end
            
            local conn = player.CharacterAdded:Connect(updateESP)
            table.insert(espConnections, conn)
            updateESP()
        end
    end
end

-- Haupt-Panel erstellen
local function createAdminPanel()
    if panelOpen then return end
    
    destroyMiniGui()  -- Mini-Menü schließen
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AdminPanelGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 10
    
    -- Haupt-Container
    local mainContainer = Instance.new("Frame")
    mainContainer.Name = "MainContainer"
    mainContainer.Size = UDim2.new(0.9, 0, 0.85, 0)
    mainContainer.Position = UDim2.new(0.05, 0, 0.1, 0)
    mainContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    mainContainer.Parent = screenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainContainer
    
    -- Titel Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    titleBar.Parent = mainContainer
    
    local titleText = Instance.new("TextLabel")
    titleText.Text = "🛡️ Admin Panel"
    titleText.Size = UDim2.new(0.5, 0, 1, 0)
    titleText.Position = UDim2.new(0, 15, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.TextColor3 = Color3.fromRGB(255, 215, 0)
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 18
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Text = "×"
    closeBtn.Size = UDim2.new(0, 40, 0, 40)
    closeBtn.Position = UDim2.new(1, -40, 0, 0)
    closeBtn.BackgroundTransparency = 1
    closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 24
    closeBtn.Parent = titleBar
    
    closeBtn.MouseButton1Click:Connect(function()
        destroyAdminPanel()
    end)
    
    -- Seitenleiste
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 180, 1, -40)
    sidebar.Position = UDim2.new(0, 0, 0, 40)
    sidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    sidebar.Parent = mainContainer
    
    -- Tab Buttons
    local tabs = {
        {name = "dashboard", text = "📊 Dashboard", icon = "📊"},
        {name = "players", text = "👥 Spielerliste", icon = "👥"},
        {name = "tools", text = "🛠️ Tools", icon = "🛠️"},
        {name = "settings", text = "⚙️ Einstellungen", icon = "⚙️"}
    }
    
    local tabButtons = {}
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -180, 1, -40)
    contentArea.Position = UDim2.new(0, 180, 0, 40)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = mainContainer
    
    for i, tab in ipairs(tabs) do
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = tab.name .. "Tab"
        tabBtn.Text = " " .. tab.text
        tabBtn.Size = UDim2.new(1, -10, 0, 45)
        tabBtn.Position = UDim2.new(0, 5, 0, 10 + (i-1) * 55)
        tabBtn.BackgroundColor3 = tab.name == "dashboard" and Color3.fromRGB(50, 50, 60) or Color3.fromRGB(40, 40, 45)
        tabBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
        tabBtn.Font = Enum.Font.Gotham
        tabBtn.TextSize = 14
        tabBtn.TextXAlignment = Enum.TextXAlignment.Left
        tabBtn.Parent = sidebar
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = tabBtn
        
        tabBtn.MouseButton1Click:Connect(function()
            currentPanelTab = tab.name
            -- Alle Tabs zurücksetzen
            for _, btn in pairs(tabButtons) do
                btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            end
            tabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            
            -- Alten Content löschen
            for _, child in pairs(contentArea:GetChildren()) do
                child:Destroy()
            end
            
            -- Neuen Content laden (Performance: nur bei Bedarf)
            if tab.name == "dashboard" then
                createDashboardContent(contentArea)
            elseif tab.name == "players" then
                createPlayerListContent(contentArea)
            elseif tab.name == "tools" then
                -- Tools Tab (könnte ESP Toggle enthalten)
            elseif tab.name == "settings" then
                -- Settings Tab
            end
        end)
        
        tabButtons[tab.name] = tabBtn
    end
    
    -- Dashboard als Standard laden
    createDashboardContent(contentArea)
    
    -- GUI einfügen
    screenGui.Parent = LP:WaitForChild("PlayerGui")
    adminPanel = screenGui
    panelOpen = true
    
    -- ESC zum Schließen
    local escConnection
    escConnection = UIS.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.Escape then
            destroyAdminPanel()
            destroyMiniGui()
            escConnection:Disconnect()
        end
    end)
    
    print("✅ Admin Panel geöffnet")
end

-- ============================
-- INPUT HANDLER
-- ============================

local lastPress = 0
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.P then
        local now = tick()
        if now - lastPress < 0.5 then return end
        lastPress = now
        findAndCopy()
        
    elseif input.KeyCode == Enum.KeyCode.F2 then
        toggleAdminPanel()
    end
end)

-- ============================
-- INITIALISIERUNG
-- ============================

-- Hammer Button erstellen
local hammerBtn = createHammerButton()

-- Auto-Close für Mini-GUI
RunService.Heartbeat:Connect(function()
    if miniGui and tick() > miniGuiTimeout then
        destroyMiniGui()
    end
end)

print("✅ Admin Script v2 erfolgreich geladen")
print("✅ P = Name kopieren + Mini-Menü")
print("✅ F2 = Admin Panel öffnen/schließen")
print("✅ Hammer-Button unten links")
print("✅ ESC schließt alle GUIs")

-- Für Executor
if getgenv then
    getgenv().CopyName = findAndCopy
    getgenv().ToggleAdminPanel = toggleAdminPanel
    getgenv().CleanupAdminScript = function()
        destroyMiniGui()
        destroyAdminPanel()
        if hammerBtn then hammerBtn:Destroy() end
        print("🛑 Alles bereinigt")
    end
end

return "✅ Admin Script v2 bereit"
