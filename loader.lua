--[[
    SWILL Legit Script v2.0
    Legacy Toilet Tower Defense
    Все действия эмулируют поведение реального игрока
]]

local success, err = pcall(function()

    -- === СЕРВИСЫ ===
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local LocalPlayer = Players.LocalPlayer
    local Mouse = LocalPlayer:GetMouse()

    -- === НАСТРОЙКИ ===
    local Settings = {
        AutoFarm = false,
        FarmLocation = "Toilet", -- "Toilet", "Spawn", "Middle"
        AutoSkip = false,
        AutoSummon = false,
        AutoSell = false,
        WalkSpeed = 16 -- нормальная скорость ходьбы
    }

    -- === ПОИСК ОБЪЕКТОВ (ТОЛЬКО ПОИСК, БЕЗ ТЕЛЕПОРТОВ) ===
    local function findLocation(locationName)
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local name = obj.Name:lower()
                if locationName == "Toilet" and name:find("toilet") then
                    return obj
                elseif locationName == "Spawn" and name:find("spawn") then
                    return obj
                elseif locationName == "Middle" and name:find("middle") then
                    return obj
                end
            end
        end
        -- Если не нашли по имени, возвращаем случайную точку для фарма
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            return character.HumanoidRootPart
        end
        return nil
    end

    local function findSummonButton()
        local gui = LocalPlayer.PlayerGui
        for _, obj in pairs(gui:GetDescendants()) do
            if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                local name = obj.Name:lower()
                local text = ""
                pcall(function() text = obj.Text:lower() end)
                if name:find("summon") or text:find("summon") then
                    return obj
                end
            end
        end
        return nil
    end

    local function findSellButton()
        local gui = LocalPlayer.PlayerGui
        for _, obj in pairs(gui:GetDescendants()) do
            if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                local name = obj.Name:lower()
                local text = ""
                pcall(function() text = obj.Text:lower() end)
                if name:find("sell") or text:find("sell") then
                    return obj
                end
            end
        end
        return nil
    end

    local function findSkipButton()
        local gui = LocalPlayer.PlayerGui
        for _, obj in pairs(gui:GetDescendants()) do
            if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                local name = obj.Name:lower()
                local text = ""
                pcall(function() text = obj.Text:lower() end)
                if name:find("skip") or text:find("skip") then
                    return obj
                end
            end
        end
        return nil
    end

    -- === ЛЕГИТНЫЕ ФУНКЦИИ (БЕЗ ТЕЛЕПОРТОВ, ВСЁ ЧЕРЕЗ ПУТИ) ===
    local function walkTo(targetPart)
        local character = LocalPlayer.Character
        if not character then return false end
        local humanoid = character:FindFirstChild("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not rootPart then return false end

        humanoid.WalkSpeed = Settings.WalkSpeed
        humanoid:MoveTo(targetPart.Position)
        return true
    end

    local function legitFarm()
        local location = findLocation(Settings.FarmLocation)
        if location then
            walkTo(location)
        end
    end

    local function legitAutoSkip()
        local skipButton = findSkipButton()
        if skipButton and skipButton.Visible then
            -- Эмуляция клика мыши по кнопке
            local buttonPos = skipButton.AbsolutePosition
            local buttonSize = skipButton.AbsoluteSize
            local clickX = buttonPos.X + buttonSize.X / 2
            local clickY = buttonPos.Y + buttonSize.Y / 2

            VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 0)
            wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 0)
        end
    end

    local function legitSummon()
        local summonButton = findSummonButton()
        if summonButton and summonButton.Visible then
            local buttonPos = summonButton.AbsolutePosition
            local buttonSize = summonButton.AbsoluteSize
            local clickX = buttonPos.X + buttonSize.X / 2
            local clickY = buttonPos.Y + buttonSize.Y / 2

            for i = 1, 5 do
                VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 0)
                wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 0)
                wait(0.3)
            end
        end
    end

    local function legitSell()
        local sellButton = findSellButton()
        if sellButton and sellButton.Visible then
            local buttonPos = sellButton.AbsolutePosition
            local buttonSize = sellButton.AbsoluteSize
            local clickX = buttonPos.X + buttonSize.X / 2
            local clickY = buttonPos.Y + buttonSize.Y / 2

            VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 0)
            wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 0)
        end
    end

    -- === GUI МЕНЮ ===
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SWILL_LegitMenu"
    ScreenGui.Parent = LocalPlayer.PlayerGui
    ScreenGui.ResetOnSpawn = false

    local Frame = Instance.new("Frame")
    Frame.Name = "MainFrame"
    Frame.Size = UDim2.new(0, 220, 0, 260)
    Frame.Position = UDim2.new(0, 10, 0, 10)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Frame.BorderColor3 = Color3.fromRGB(0, 255, 0)
    Frame.BorderSizePixel = 2
    Frame.Active = true
    Frame.Draggable = true
    Frame.Parent = ScreenGui

    -- Заголовок
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 200, 0, 20)
    Title.Position = UDim2.new(0, 10, 0, 5)
    Title.Text = "SWILL LEGIT FARM v2.0"
    Title.TextColor3 = Color3.fromRGB(0, 255, 0)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 14
    Title.Parent = Frame

    local yOffset = 30

    local function createButton(text, y, callback)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0, 200, 0, 22)
        button.Position = UDim2.new(0, 10, 0, y)
        button.Text = text
        button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.BorderSizePixel = 0
        button.Font = Enum.Font.SourceSans
        button.TextSize = 12
        button.Parent = Frame
        button.MouseButton1Click:Connect(callback)
        return button
    end

    -- AutoFarm Toggle
    local farmButton = createButton("AutoFarm: OFF", yOffset, function()
        Settings.AutoFarm = not Settings.AutoFarm
        farmButton.Text = "AutoFarm: " .. (Settings.AutoFarm and "ON" or "OFF")
        farmButton.BackgroundColor3 = Settings.AutoFarm and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(45, 45, 45)
    end)
    yOffset = yOffset + 25

    -- Выбор локации
    local locationText = Instance.new("TextLabel")
    locationText.Size = UDim2.new(0, 200, 0, 18)
    locationText.Position = UDim2.new(0, 10, 0, yOffset)
    locationText.Text = "Локация: Toilet"
    locationText.TextColor3 = Color3.fromRGB(200, 200, 200)
    locationText.BackgroundTransparency = 1
    locationText.Font = Enum.Font.SourceSans
    locationText.TextSize = 12
    locationText.Parent = Frame
    yOffset = yOffset + 20

    local locationButton = createButton("Сменить: Toilet", yOffset, function()
        local locations = {"Toilet", "Spawn", "Middle"}
        local currentIndex = 1
        for i, loc in pairs(locations) do
            if loc == Settings.FarmLocation then
                currentIndex = i
                break
            end
        end
        currentIndex = currentIndex % #locations + 1
        Settings.FarmLocation = locations[currentIndex]
        locationText.Text = "Локация: " .. Settings.FarmLocation
        locationButton.Text = "Сменить: " .. Settings.FarmLocation
    end)
    yOffset = yOffset + 25

    -- AutoSkip Toggle
    local skipButton = createButton("AutoSkip: OFF", yOffset, function()
        Settings.AutoSkip = not Settings.AutoSkip
        skipButton.Text = "AutoSkip: " .. (Settings.AutoSkip and "ON" or "OFF")
        skipButton.BackgroundColor3 = Settings.AutoSkip and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(45, 45, 45)
    end)
    yOffset = yOffset + 25

    -- AutoSummon
    local summonButton = createButton("Summon x5 (разово)", yOffset, function()
        legitSummon()
    end)
    summonButton.BackgroundColor3 = Color3.fromRGB(45, 45, 120)
    yOffset = yOffset + 25

    -- AutoSell
    local sellButton = createButton("Sell Item (разово)", yOffset, function()
        legitSell()
    end)
    sellButton.BackgroundColor3 = Color3.fromRGB(120, 120, 45)
    yOffset = yOffset + 25

    -- WalkSpeed
    local speedText = Instance.new("TextLabel")
    speedText.Size = UDim2.new(0, 200, 0, 18)
    speedText.Position = UDim2.new(0, 10, 0, yOffset)
    speedText.Text = "WalkSpeed: 16 (normal)"
    speedText.TextColor3 = Color3.fromRGB(200, 200, 200)
    speedText.BackgroundTransparency = 1
    speedText.Font = Enum.Font.SourceSans
    speedText.TextSize = 12
    speedText.Parent = Frame
    yOffset = yOffset + 20

    local speeds = {16, 21, 30, 50}
    local speedIndex = 1
    local speedButton = createButton("Speed: Normal", yOffset, function()
        speedIndex = speedIndex % #speeds + 1
        Settings.WalkSpeed = speeds[speedIndex]
        local speedNames = {"Normal", "Fast", "Super Fast", "Turbo"}
        speedButton.Text = "Speed: " .. speedNames[speedIndex]
        speedText.Text = "WalkSpeed: " .. speeds[speedIndex] .. " (" .. speedNames[speedIndex] .. ")"
    end)

    -- === ГЛАВНЫЕ ЦИКЛЫ ===
    -- AutoFarm цикл (ходит пешком, не телепортируется)
    RunService.RenderStepped:Connect(function()
        if Settings.AutoFarm then
            legitFarm()
        end
    end)

    -- AutoSkip цикл (проверяет кнопку skip каждые 0.5 секунд)
    spawn(function()
        while true do
            if Settings.AutoSkip then
                pcall(function()
                    legitAutoSkip()
                end)
            end
            wait(0.5)
        end
    end)

end)

if not success then
    warn("SWILL Script Error: " .. tostring(err))
end
