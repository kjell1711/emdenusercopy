-- Simple Name Copy - Admin Version
-- P = Kopieren + Admin-Menü (Performance optimiert)

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

-- Start message
print("=== Simple Name Copy - Admin Version ===")
print("Taste: P")
print("Respektiert Menüs/Chat")

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "✅ Admin Script aktiv",
        Text = "Drücke P für Name + Admin-Menü",
        Duration = 3
    })
end)

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

-- GUI Verwaltung
local adminGui = nil
local guiTimeout = 0
local currentPlayerData = nil

local function destroyAdminGui()
    if adminGui then
        adminGui:Destroy()
        adminGui = nil
        currentPlayerData = nil
        guiTimeout = 0
    end
end

local function createAdminGui(username, displayName, hp, dist)
    -- Altes GUI zerstören
    destroyAdminGui()
    
    -- Aktuelle Daten speichern
    currentPlayerData = {
        username = username,
        displayName = displayName,
        hp = hp,
        dist = dist
    }
    
    -- GUI erstellen
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AdminCopyGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 10  -- Über anderen GUIs
    
    -- Haupt-Frame (unten rechts)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 220, 0, 160)
    mainFrame.Position = UDim2.new(1, -230, 1, -170)  -- Unten rechts mit Abstand
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    mainFrame.BorderSizePixel = 1
    mainFrame.BorderColor3 = Color3.fromRGB(60, 60, 70)
    mainFrame.Parent = screenGui
    
    -- Abgerundete Ecken
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    -- Drop Shadow für besseren Kontrast
    local shadow = Instance.new("UIStroke")
    shadow.Color = Color3.fromRGB(0, 0, 0)
    shadow.Thickness = 2
    shadow.Parent = mainFrame
    
    -- Titel
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Text = "👑 Admin Menü"
    title.Size = UDim2.new(1, -20, 0, 30)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255, 215, 0)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = mainFrame
    
    -- Close Button (X)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Text = "×"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -40, 0, 10)
    closeBtn.BackgroundTransparency = 1
    closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 20
    closeBtn.Parent = mainFrame
    
    -- Spieler Info
    local playerName = Instance.new("TextLabel")
    playerName.Name = "PlayerName"
    playerName.Text = displayName
    playerName.Size = UDim2.new(1, -20, 0, 24)
    playerName.Position = UDim2.new(0, 10, 0, 50)
    playerName.BackgroundTransparency = 1
    playerName.TextColor3 = Color3.fromRGB(255, 255, 255)
    playerName.Font = Enum.Font.Gotham
    playerName.TextSize = 14
    playerName.TextXAlignment = Enum.TextXAlignment.Left
    playerName.TextTruncate = Enum.TextTruncate.AtEnd
    playerName.Parent = mainFrame
    
    local usernameLabel = Instance.new("TextLabel")
    usernameLabel.Name = "Username"
    usernameLabel.Text = "@" .. username
    usernameLabel.Size = UDim2.new(1, -20, 0, 20)
    usernameLabel.Position = UDim2.new(0, 10, 0, 74)
    usernameLabel.BackgroundTransparency = 1
    usernameLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    usernameLabel.Font = Enum.Font.Gotham
    usernameLabel.TextSize = 12
    usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    usernameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    usernameLabel.Parent = mainFrame
    
    -- Stats
    local statsText = Instance.new("TextLabel")
    statsText.Name = "Stats"
    statsText.Text = string.format("❤️ %d HP | 📏 %d Studs", hp, math.floor(dist))
    statsText.Size = UDim2.new(1, -20, 0, 20)
    statsText.Position = UDim2.new(0, 10, 0, 96)
    statsText.BackgroundTransparency = 1
    statsText.TextColor3 = Color3.fromRGB(150, 220, 255)
    statsText.Font = Enum.Font.Gotham
    statsText.TextSize = 12
    statsText.TextXAlignment = Enum.TextXAlignment.Left
    statsText.Parent = mainFrame
    
    -- Button Container
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Name = "ButtonContainer"
    buttonContainer.Size = UDim2.new(1, -20, 0, 40)
    buttonContainer.Position = UDim2.new(0, 10, 1, -50)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = mainFrame
    
    -- Kick Button
    local kickBtn = Instance.new("TextButton")
    kickBtn.Name = "KickButton"
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
    
    -- Ban Button
    local banBtn = Instance.new("TextButton")
    banBtn.Name = "BanButton"
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
    
    -- GUI ins PlayerGui einfügen
    screenGui.Parent = LP:WaitForChild("PlayerGui")
    adminGui = screenGui
    guiTimeout = tick() + 5  -- 5 Sekunden Timer
    
    -- Events
    closeBtn.MouseButton1Click:Connect(function()
        destroyAdminGui()
    end)
    
    kickBtn.MouseButton1Click:Connect(function()
        local cmd = "/kick " .. username
        if setclipboard then
            setclipboard(cmd)
        end
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "✅ Kick-Befehl kopiert",
                Text = cmd,
                Duration = 2
            })
        end)
        destroyAdminGui()
    end)
    
    banBtn.MouseButton1Click:Connect(function()
        local cmd = "/ban " .. username
        if setclipboard then
            setclipboard(cmd)
        end
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "✅ Ban-Befehl kopiert",
                Text = cmd,
                Duration = 2
            })
        end)
        destroyAdminGui()
    end)
    
    -- Hover Effects (nur visuell, keine Performance-Belastung)
    local function setupHoverEffect(button, normalColor, hoverColor)
        button.MouseEnter:Connect(function()
            button.BackgroundColor3 = hoverColor
        end)
        button.MouseLeave:Connect(function()
            button.BackgroundColor3 = normalColor
        end)
    end
    
    setupHoverEffect(kickBtn, Color3.fromRGB(220, 60, 60), Color3.fromRGB(240, 80, 80))
    setupHoverEffect(banBtn, Color3.fromRGB(180, 50, 50), Color3.fromRGB(200, 70, 70))
    setupHoverEffect(closeBtn, Color3.fromRGB(0, 0, 0, 0), Color3.fromRGB(60, 60, 70))
    
    return screenGui
end

-- GUI Auto-Close Check (Läuft nur wenn GUI existiert)
local lastGuiCheck = 0
RunService.RenderStepped:Connect(function()
    if not adminGui or tick() - lastGuiCheck < 0.1 then return end
    lastGuiCheck = tick()
    
    if tick() > guiTimeout then
        destroyAdminGui()
    end
end)

-- Einfache Find-Funktion
local function findAndCopy()
    -- 1. Character check
    local char = LP.Character
    if not char then return false end
    
    local myRoot = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
    if not myRoot then return false end
    
    local myPos = myRoot.Position
    
    -- 2. Find nearest
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
    
    -- 3. Process if found
    if nearest then
        local username = nearest.Name
        
        -- Copy name to clipboard
        if setclipboard then
            setclipboard(username)
        end
        
        -- Create admin GUI
        createAdminGui(username, display, hp, minDist)
        
        -- Short notification
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "✅ " .. display,
                Text = "Name kopiert | Admin-Menü geöffnet",
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

-- EINFACHER Input Handler (respektiert Menüs)
local lastPress = 0
UIS.InputBegan:Connect(function(input, gameProcessed)
    -- RESPEKTIERE gameProcessed - das verhindert GUI Freeze
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.P then
        -- Anti-spam
        local now = tick()
        if now - lastPress < 0.5 then return end
        lastPress = now
        
        -- Einfach ausführen
        findAndCopy()
    end
end)

-- Character update
LP.CharacterAdded:Connect(function()
    print("Character updated - Script ready")
end)

-- Cleanup
local function cleanup()
    allPlayers = {}
    destroyAdminGui()
    print("🛑 Script deaktiviert")
    
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Admin Script",
            Text = "Deaktiviert",
            Duration = 2
        })
    end)
end

-- Für Executor
if getgenv then
    getgenv().CopyName = findAndCopy
    getgenv().CleanupNameCopy = cleanup
    getgenv().DestroyAdminGUI = destroyAdminGui
end

print("✅ Admin Script loaded successfully")
print("✅ Press P to copy nearest name + admin menu")
print("✅ GUI auto-closes after 5 seconds")

return "✅ Admin script loaded"
