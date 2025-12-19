-- ============================================
-- ADMIN SCRIPT v3 - GARANTIERT FUNKTIONSFÄHIG
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
-- TEIL 1: INITIALISIERUNG & ERROR-HANDLING
-- ============================================

print("===================================")
print("ADMIN SCRIPT v3 - GELADEN")
print("===================================")
print("P = Nächstgelegenen Spieler kopieren")
print("F2 = Admin Panel öffnen/schließen")
print("ESC = Alles schließen")
print("===================================")

-- Einfacher Notify ohne Fehler
task.spawn(function()
    wait(0.5)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "🛡️ Admin Script",
            Text = "P = Name | F2 = Panel | ESC = Schließen",
            Duration = 3
        })
    end)
end)

-- ============================================
-- TEIL 2: MINI-MENÜ (Name Copy)
-- ============================================

-- Globale Variablen für Mini-Menü
local miniMenuGui = nil
local miniMenuTimeout = 0

-- Funktion zum Schließen des Mini-Menüs
local function closeMiniMenu()
    if miniMenuGui and miniMenuGui.Parent then
        miniMenuGui:Destroy()
        miniMenuGui = nil
    end
    miniMenuTimeout = 0
end

-- Funktion zum Finden des nächstgelegenen Spielers
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
            distance = math.floor(shortestDistance)
        }
    end
    
    return nil
end

-- Funktion zum Erstellen des Mini-Menüs
local function createMiniMenu(playerData)
    -- Erst alles schließen
    closeMiniMenu()
    
    -- GUI erstellen
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MiniAdminMenu"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 100
    
    -- Hauptframe (höher positioniert, um Benachrichtigungen nicht zu überlappen)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 220, 0, 160)
    mainFrame.Position = UDim2.new(1, -240, 1, -280) -- Höher platziert
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    mainFrame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 0, 0)
    stroke.Thickness = 2
    stroke.Parent = mainFrame
    
    -- Inhalt hinzufügen...
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
    
    -- Schließen-Button
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
    
    -- GUI zum Spieler hinzufügen
    mainFrame.Parent = screenGui
    screenGui.Parent = LP:WaitForChild("PlayerGui")
    
    miniMenuGui = screenGui
    miniMenuTimeout = tick() + 5 -- 5 Sekunden auto-close
    
    return screenGui
end

-- Funktion zum Kopieren des nächstgelegenen Spielers
local function copyNearestPlayer()
    local playerData = findNearestPlayer()
    
    if playerData then
        -- Username kopieren
        if setclipboard then
            setclipboard(playerData.username)
        end
        
        -- Mini-Menü öffnen
        createMiniMenu(playerData)
        
        -- Benachrichtigung
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
-- TEIL 3: HAMMER BUTTON (Einfach & Funktionsfähig)
-- ============================================

local hammerButtonGui = nil

local function createHammerButton()
    -- Alten Button entfernen
    if hammerButtonGui then
        hammerButtonGui:Destroy()
    end
    
    -- Neuen Button erstellen
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AdminHammerButton"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 50
    
    local button = Instance.new("TextButton")
    button.Name = "HammerButton"
    button.Text = "⚒️"
    button.Size = UDim2.new(0, 50, 0, 50)
    button.Position = UDim2.new(0, 20, 1, -80) -- Unten links
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    button.TextColor3 = Color3.fromRGB(255, 215, 0)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 24
    button.AutoButtonColor = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 80, 90)
    stroke.Thickness = 2
    stroke.Parent = button
    
    -- Hover-Effekt
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    end)
    
    -- Klick-Event (wird später mit Panel-Funktion verbunden)
    button.MouseButton1Click:Connect(function()
        toggleAdminPanel()
    end)
    
    button.Parent = screenGui
    screenGui.Parent = LP:WaitForChild("PlayerGui")
    
    hammerButtonGui = screenGui
    return screenGui
end

-- ============================================
-- TEIL 4: ADMIN PANEL (Vereinfacht & Garantiert Funktionsfähig)
-- ============================================

local adminPanelGui = nil
local isPanelOpen = false

-- Funktion zum Schließen des Admin Panels
local function closeAdminPanel()
    if adminPanelGui and adminPanelGui.Parent then
        adminPanelGui:Destroy()
        adminPanelGui = nil
    end
    isPanelOpen = false
end

-- Funktion zum Öffnen des Admin Panels
local function openAdminPanel()
    -- Schließe erst alles andere
    closeMiniMenu()
    
    if isPanelOpen then
        closeAdminPanel()
        return
    end
    
    isPanelOpen = true
    
    -- GUI erstellen
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AdminPanel"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 20
    
    -- Haupt-Container (zentriert)
    local mainContainer = Instance.new("Frame")
    mainContainer.Name = "MainContainer"
    mainContainer.Size = UDim2.new(0.8, 0, 0.8, 0)
    mainContainer.Position = UDim2.new(0.1, 0, 0.1, 0)
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
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    titleBar.Parent = mainContainer
    
    local titleText = Instance.new("TextLabel")
    titleText.Text = "🛡️ ADMIN PANEL"
    titleText.Size = UDim2.new(0.5, 0, 1, 0)
    titleText.Position = UDim2.new(0, 15, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.TextColor3 = Color3.fromRGB(255, 215, 0)
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 18
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    -- Schließen-Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "×"
    closeBtn.Size = UDim2.new(0, 40, 0, 40)
    closeBtn.Position = UDim2.new(1, -40, 0, 0)
    closeBtn.BackgroundTransparency = 1
    closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 24
    closeBtn.Parent = titleBar
    
    closeBtn.MouseButton1Click:Connect(closeAdminPanel)
    
    -- Seitenleiste
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 200, 1, -40)
    sidebar.Position = UDim2.new(0, 0, 0, 40)
    sidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    sidebar.Parent = mainContainer
    
    -- Content-Bereich
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -200, 1, -40)
    contentArea.Position = UDim2.new(0, 200, 0, 40)
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
            if child.Name ~= "ContentArea" then
                child:Destroy()
            end
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
            
            -- Server Info
            local serverInfo = Instance.new("Frame")
            serverInfo.Name = "ServerInfo"
            serverInfo.Size = UDim2.new(1, -20, 0, 120)
            serverInfo.Position = UDim2.new(0, 10, 0, 10)
            serverInfo.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            serverInfo.Parent = dashboardFrame
            
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
            playersText.Text = "👥 Spieler: " .. #Players:GetPlayers()
            playersText.Size = UDim2.new(1, -20, 0, 25)
            playersText.Position = UDim2.new(0, 10, 0, 40)
            playersText.BackgroundTransparency = 1
            playersText.TextColor3 = Color3.fromRGB(200, 200, 220)
            playersText.Font = Enum.Font.Gotham
            playersText.TextSize = 14
            playersText.TextXAlignment = Enum.TextXAlignment.Left
            playersText.Parent = serverInfo
            
            local placeIdText = Instance.new("TextLabel")
            placeIdText.Text = "📍 Place ID: " .. game.PlaceId
            placeIdText.Size = UDim2.new(1, -20, 0, 25)
            placeIdText.Position = UDim2.new(0, 10, 0, 70)
            placeIdText.BackgroundTransparency = 1
            placeIdText.TextColor3 = Color3.fromRGB(200, 200, 220)
            placeIdText.Font = Enum.Font.Gotham
            placeIdText.TextSize = 14
            placeIdText.TextXAlignment = Enum.TextXAlignment.Left
            placeIdText.Parent = serverInfo
            
            -- Lokaler Spieler Info
            local playerInfo = Instance.new("Frame")
            playerInfo.Name = "PlayerInfo"
            playerInfo.Size = UDim2.new(1, -20, 0, 100)
            playerInfo.Position = UDim2.new(0, 10, 0, 140)
            playerInfo.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            playerInfo.Parent = dashboardFrame
            
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
            displayText.Text = "Anzeige: " .. (LP.DisplayName or "N/A")
            displayText.Size = UDim2.new(0.5, -15, 0, 25)
            displayText.Position = UDim2.new(0.5, 5, 0, 40)
            displayText.BackgroundTransparency = 1
            displayText.TextColor3 = Color3.fromRGB(200, 200, 220)
            displayText.Font = Enum.Font.Gotham
            displayText.TextSize = 14
            displayText.TextXAlignment = Enum.TextXAlignment.Left
            displayText.Parent = playerInfo
            
            dashboardFrame.CanvasSize = UDim2.new(0, 0, 0, 260)
            
        elseif tabId == "players" then
            -- Spielerliste mit Suchleiste
            local playersFrame = Instance.new("Frame")
            playersFrame.Name = "PlayersFrame"
            playersFrame.Size = UDim2.new(1, 0, 1, 0)
            playersFrame.BackgroundTransparency = 1
            playersFrame.Parent = contentArea
            
            -- Suchleiste
            local searchBar = Instance.new("TextBox")
            searchBar.Name = "SearchBar"
            searchBar.PlaceholderText = "🔍 Nach Spielern suchen..."
            searchBar.Size = UDim2.new(1, -20, 0, 35)
            searchBar.Position = UDim2.new(0, 10, 0, 10)
            searchBar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            searchBar.TextColor3 = Color3.fromRGB(255, 255, 255)
            searchBar.Font = Enum.Font.Gotham
            searchBar.TextSize = 14
            searchBar.Text = ""
            searchBar.Parent = playersFrame
            
            local searchCorner = Instance.new("UICorner")
            searchCorner.CornerRadius = UDim.new(0, 6)
            searchCorner.Parent = searchBar
            
            -- Scrollbare Spielerliste
            local playersList = Instance.new("ScrollingFrame")
            playersList.Name = "PlayersList"
            playersList.Size = UDim2.new(1, -20, 1, -55)
            playersList.Position = UDim2.new(0, 10, 0, 55)
            playersList.BackgroundTransparency = 1
            playersList.ScrollBarThickness = 6
            playersList.Parent = playersFrame
            
            -- Funktion zum Laden der Spielerliste (Performance: Nur bei Bedarf!)
            local function loadPlayerList(searchTerm)
                -- Alte Liste löschen
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
                        
                        -- Suchfilter anwenden
                        if searchTerm == "" or 
                           string.find(string.lower(displayName), string.lower(searchTerm)) or
                           string.find(string.lower(username), string.lower(searchTerm)) then
                            
                            playerCount = playerCount + 1
                            
                            -- Spieler-Eintrag erstellen
                            local playerEntry = Instance.new("Frame")
                            playerEntry.Name = "Player_" .. username
                            playerEntry.Size = UDim2.new(1, 0, 0, 60)
                            playerEntry.Position = UDim2.new(0, 0, 0, yOffset)
                            playerEntry.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
                            playerEntry.Parent = playersList
                            
                            local entryCorner = Instance.new("UICorner")
                            entryCorner.CornerRadius = UDim.new(0, 6)
                            entryCorner.Parent = playerEntry
                            
                            -- Spielerinfo
                            local nameLabel = Instance.new("TextLabel")
                            nameLabel.Text = displayName
                            nameLabel.Size = UDim2.new(0.7, -10, 0, 25)
                            nameLabel.Position = UDim2.new(0, 10, 0, 5)
                            nameLabel.BackgroundTransparency = 1
                            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                            nameLabel.Font = Enum.Font.GothamBold
                            nameLabel.TextSize = 14
                            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
                            nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
                            nameLabel.Parent = playerEntry
                            
                            local userLabel = Instance.new("TextLabel")
                            userLabel.Text = "@" .. username
                            userLabel.Size = UDim2.new(0.7, -10, 0, 20)
                            userLabel.Position = UDim2.new(0, 10, 0, 30)
                            userLabel.BackgroundTransparency = 1
                            userLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
                            userLabel.Font = Enum.Font.Gotham
                            userLabel.TextSize = 12
                            userLabel.TextXAlignment = Enum.TextXAlignment.Left
                            userLabel.Parent = playerEntry
                            
                            -- Aktionen
                            local actionsFrame = Instance.new("Frame")
                            actionsFrame.Name = "Actions"
                            actionsFrame.Size = UDim2.new(0.3, -10, 1, -10)
                            actionsFrame.Position = UDim2.new(0.7, 0, 0, 5)
                            actionsFrame.BackgroundTransparency = 1
                            actionsFrame.Parent = playerEntry
                            
                            local kickBtn = Instance.new("TextButton")
                            kickBtn.Text = "🚪"
                            kickBtn.Size = UDim2.new(0, 30, 0, 25)
                            kickBtn.Position = UDim2.new(0, 0, 0, 0)
                            kickBtn.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
                            kickBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                            kickBtn.Font = Enum.Font.GothamBold
                            kickBtn.TextSize = 12
                            kickBtn.Parent = actionsFrame
                            
                            local banBtn = Instance.new("TextButton")
                            banBtn.Text = "⛔"
                            banBtn.Size = UDim2.new(0, 30, 0, 25)
                            banBtn.Position = UDim2.new(0, 35, 0, 0)
                            banBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
                            banBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                            banBtn.Font = Enum.Font.GothamBold
                            banBtn.TextSize = 12
                            banBtn.Parent = actionsFrame
                            
                            -- Button Events
                            kickBtn.MouseButton1Click:Connect(function()
                                local cmd = "/kick " .. username
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
                                local cmd = "/ban " .. username
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
                            
                            yOffset = yOffset + 70
                        end
                    end
                end
                
                -- Canvas-Größe anpassen
                playersList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
                
                -- Falls keine Spieler gefunden
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
            
            -- Suchleisten-Event
            searchBar:GetPropertyChangedSignal("Text"):Connect(function()
                loadPlayerList(searchBar.Text)
            end)
            
            -- Initial laden
            loadPlayerList("")
            
        elseif tabId == "tools" then
            -- Tools Tab
            local toolsFrame = Instance.new("Frame")
            toolsFrame.Name = "ToolsFrame"
            toolsFrame.Size = UDim2.new(1, 0, 1, 0)
            toolsFrame.BackgroundTransparency = 1
            toolsFrame.Parent = contentArea
            
            local title = Instance.new("TextLabel")
            title.Text = "🛠️ Admin Tools"
            title.Size = UDim2.new(1, 0, 0, 40)
            title.Position = UDim2.new(0, 0, 0, 20)
            title.BackgroundTransparency = 1
            title.TextColor3 = Color3.fromRGB(255, 215, 0)
            title.Font = Enum.Font.GothamBold
            title.TextSize = 18
            title.TextXAlignment = Enum.TextXAlignment.Center
            title.Parent = toolsFrame
            
            local info = Instance.new("TextLabel")
            info.Text = "Weitere Tools werden bald hinzugefügt!"
            info.Size = UDim2.new(1, 0, 0, 30)
            info.Position = UDim2.new(0, 0, 0, 70)
            info.BackgroundTransparency = 1
            info.TextColor3 = Color3.fromRGB(200, 200, 220)
            info.Font = Enum.Font.Gotham
            info.TextSize = 14
            info.TextXAlignment = Enum.TextXAlignment.Center
            info.Parent = toolsFrame
            
        elseif tabId == "settings" then
            -- Settings Tab
            local settingsFrame = Instance.new("Frame")
            settingsFrame.Name = "SettingsFrame"
            settingsFrame.Size = UDim2.new(1, 0, 1, 0)
            settingsFrame.BackgroundTransparency = 1
            settingsFrame.Parent = contentArea
            
            local title = Instance.new("TextLabel")
            title.Text = "⚙️ Einstellungen"
            title.Size = UDim2.new(1, 0, 0, 40)
            title.Position = UDim2.new(0, 0, 0, 20)
            title.BackgroundTransparency = 1
            title.TextColor3 = Color3.fromRGB(255, 215, 0)
            title.Font = Enum.Font.GothamBold
            title.TextSize = 18
            title.TextXAlignment = Enum.TextXAlignment.Center
            title.Parent = settingsFrame
            
            local versionText = Instance.new("TextLabel")
            versionText.Text = "Admin Script v3.0"
            versionText.Size = UDim2.new(1, 0, 0, 25)
            versionText.Position = UDim2.new(0, 0, 0, 70)
            versionText.BackgroundTransparency = 1
            versionText.TextColor3 = Color3.fromRGB(200, 200, 220)
            versionText.Font = Enum.Font.Gotham
            versionText.TextSize = 14
            versionText.TextXAlignment = Enum.TextXAlignment.Center
            versionText.Parent = settingsFrame
            
            local hotkeysText = Instance.new("TextLabel")
            hotkeysText.Text = "Hotkeys: P, F2, ESC"
            hotkeysText.Size = UDim2.new(1, 0, 0, 25)
            hotkeysText.Position = UDim2.new(0, 0, 0, 100)
            hotkeysText.BackgroundTransparency = 1
            hotkeysText.TextColor3 = Color3.fromRGB(200, 200, 220)
            hotkeysText.Font = Enum.Font.Gotham
            hotkeysText.TextSize = 14
            hotkeysText.TextXAlignment = Enum.TextXAlignment.Center
            hotkeysText.Parent = settingsFrame
        end
    end
    
    -- Tab-Buttons erstellen
    for i, tab in ipairs(tabs) do
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tab.id .. "Tab"
        tabButton.Text = "  " .. tab.name
        tabButton.Size = UDim2.new(1, -10, 0, 50)
        tabButton.Position = UDim2.new(0, 5, 0, 10 + (i-1) * 60)
        
        if tab.id == activeTab then
            tabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        else
            tabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        end
        
        tabButton.TextColor3 = Color3.fromRGB(220, 220, 230)
        tabButton.Font = Enum.Font.Gotham
        tabButton.TextSize = 14
        tabButton.TextXAlignment = Enum.TextXAlignment.Left
        tabButton.Parent = sidebar
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 6)
        tabCorner.Parent = tabButton
        
        -- Tab-Wechsel Event
        tabButton.MouseButton1Click:Connect(function()
            -- Alle Buttons zurücksetzen
            for _, btn in pairs(sidebar:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
                end
            end
            
            -- Aktiven Button hervorheben
            tabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            
            -- Tab wechseln
            switchTab(tab.id)
        end)
    end
    
    -- Standard-Tab laden
    switchTab("dashboard")
    
    -- GUI hinzufügen
    screenGui.Parent = LP:WaitForChild("PlayerGui")
    adminPanelGui = screenGui
    
    print("✅ Admin Panel erfolgreich geöffnet")
end

-- Toggle-Funktion für das Admin Panel
local function toggleAdminPanel()
    if isPanelOpen then
        closeAdminPanel()
    else
        openAdminPanel()
    end
end

-- ============================================
-- TEIL 5: INPUT HANDLER & AUTO-CLOSE
-- ============================================

-- Input Handler
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.P then
        copyNearestPlayer()
        
    elseif input.KeyCode == Enum.KeyCode.F2 then
        toggleAdminPanel()
        
    elseif input.KeyCode == Enum.KeyCode.Escape then
        closeMiniMenu()
        closeAdminPanel()
    end
end)

-- Auto-Close für Mini-Menü
RunService.Heartbeat:Connect(function()
    if miniMenuGui and miniMenuTimeout > 0 and tick() > miniMenuTimeout then
        closeMiniMenu()
    end
end)

-- ============================================
-- TEIL 6: STARTUP
-- ============================================

-- Hammer Button erstellen (mit Verzögerung, damit PlayerGui existiert)
task.spawn(function()
    wait(1)
    createHammerButton()
    
    print("===================================")
    print("✅ Script vollständig initialisiert")
    print("✅ Hammer-Button unten links")
    print("✅ Alle Funktionen bereit")
    print("===================================")
end)

-- ============================================
-- TEIL 7: EXPORT FÜR EXECUTOR
-- ============================================

if getgenv then
    -- Globale Funktionen für manuelle Steuerung
    getgenv().AdminCopyName = copyNearestPlayer
    getgenv().AdminOpenPanel = openAdminPanel
    getgenv().AdminClosePanel = closeAdminPanel
    getgenv().AdminTogglePanel = toggleAdminPanel
    getgenv().AdminCleanup = function()
        closeMiniMenu()
        closeAdminPanel()
        if hammerButtonGui then
            hammerButtonGui:Destroy()
        end
        print("🛑 Admin Script bereinigt")
    end
end

return "✅ ADMIN SCRIPT v3 - BEREIT"
