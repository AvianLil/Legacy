--[[
    SWILL Auto Farm v3.0
    Legacy Toilet Tower Defense
    Полный автомат: выбор сложности, авторестарт, автоскип
]]

local success, err = pcall(function()

    -- === СЕРВИСЫ ===
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local TeleportService = game:GetService("TeleportService")
    local LocalPlayer = Players.LocalPlayer
    local GuiService = game:GetService("GuiService")

    -- === НАСТРОЙКИ ===
    local Settings = {
        Difficulty = "Nightmare", -- Easy, Hard, Insane, Nightmare
        AutoRestart = true,
        AutoSkip = true,
        AutoVote = true,
        WalkSpeed = 21
    }

    -- === ФУНКЦИЯ КЛИКА ПО КНОПКЕ ===
    local function clickButton(button)
        if not button or not button.Visible then return false end
        local pos = button.AbsolutePosition
        local size = button.AbsoluteSize
        local x = pos.X + size.X / 2
        local y = pos.Y + size.Y / 2

        VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
        wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
        return true
    end

    -- === ПОИСК КНОПКИ ПО ТЕКСТУ ===
    local function findButton(searchText, caseSensitive)
        local gui = LocalPlayer.PlayerGui
        for _, obj in pairs(gui:GetDescendants()) do
            if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                local checkText = ""
                pcall(function()
                    checkText = obj.Text or obj.Name
                end)
                if not caseSensitive then
                    checkText = checkText:lower()
                    searchText = searchText:lower()
                end
                if checkText:find(searchText) then
                    return obj
                end
            end
        end
        return nil
    end

    -- === ПОИСК КНОПКИ СЛОЖНОСТИ ПО ЦВЕТУ ===
    local function findDifficultyButton(difficulty)
        local gui = LocalPlayer.PlayerGui
        local targetColors = {
            Easy = Color3.fromRGB(0, 255, 0),
            Hard = Color3.fromRGB(255, 255, 0),
            Insane = Color3.fromRGB(255, 0, 0),
            Nightmare = Color3.fromRGB(100, 0, 200)
        }

        local targetColor = targetColors[difficulty]

        for _, obj in pairs(gui:GetDescendants()) do
            if obj:IsA("TextButton") then
                local hasColor = pcall(function()
                    return obj.BackgroundColor3
                end)

                if hasColor then
                    local color = obj.BackgroundColor3
                    if color and math.abs(color.R - targetColor.R) < 0.1
                        and math.abs(color.G - targetColor.G) < 0.1
                        and math.abs(color.B - targetColor.B) < 0.1 then
                        return obj
                    end
                end
            end
        end
        return nil
    end

    -- === ВЫБОР СЛОЖНОСТИ ===
    local function selectDifficulty(difficulty)
        local diffButton = findDifficultyButton(difficulty)
        if diffButton then
            clickButton(diffButton)
            return true
        end

        -- Запасной вариант: ищем по тексту
        local textButton = findButton(difficulty:lower(), false)
        if textButton then
            clickButton(textButton)
            return true
        end

        return false
    end

    -- === АВТОСКИП ВОЛН ===
    local function autoSkipWave()
        local skipButton = findButton("skip", false)
        if skipButton then
            clickButton(skipButton)
        end
    end

    -- === ПРОВЕРКА ОКОНЧАНИЯ ИГРЫ ===
    local function checkGameOver()
        local gameOverTexts = {"defeat", "victory", "game over", "you lose", "you win", "wave"}
        for _, text in pairs(gameOverTexts) do
            local found = false
            for _, obj in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
                if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                    local objText = ""
                    pcall(function()
                        objText = obj.Text:lower()
                    end)
                    if objText:find(text) and obj.Visible then
                        found = true
                        break
                    end
                end
            end
            if found then return true end
        end
        return false
    end

    -- === АВТОРЕСТАРТ ===
    local function autoRestart()
        -- Ищем кнопки перезапуска/продолжения
        local restartTexts = {"retry", "restart", "play again", "continue", "replay", "играть", "заново"}
        for _, text in pairs(restartTexts) do
            local button = findButton(text, false)
            if button then
                clickButton(button)
                wait(1)
                -- После рестарта снова выбираем сложность
                selectDifficulty(Settings.Difficulty)
                return true
            end
        end
        return false
    end

    -- === ТЕЛЕПОРТ К ТУАЛЕТУ (ФАРМ) ===
    local function findToilet()
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local name = obj.Name:lower()
                if name:find("toilet") then
                    return obj
                end
            end
        end
        return nil
    end

    local function walkToToilet()
        local character = LocalPlayer.Character
        if not character then return end
        local humanoid = character:FindFirstChild("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not rootPart then return end

        local toilet = findToilet()
        if toilet then
            rootPart.CFrame = toilet.CFrame + Vector3.new(0, 3, 0)
        end
    end

    -- === GUI МЕНЮ ===
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SWILL_FarmMenu"
    ScreenGui.Parent = LocalPlayer.PlayerGui
    ScreenGui.ResetOnSpawn = false

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 220, 0, 290)
    Frame.Position = UDim2.new(0, 10, 0, 10)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Frame.BorderColor3 = Color3.fromRGB(0, 255, 0)
    Frame.BorderSizePixel = 2
    Frame.Active = true
    Frame.Draggable = true
    Frame.Parent = ScreenGui

    -- Заголовок
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 200, 0, 20)
    Title.Position = UDim2.new(0, 10, 0, 5)
    Title.Text = "SWILL AUTO FARM v3.0"
    Title.TextColor3 = Color3.fromRGB(0, 255, 0)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 14
    Title.Parent = Frame

    local y = 28

    local function createButton(text, posY, callback, color)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0, 200, 0, 24)
        button.Position = UDim2.new(0, 10, 0, posY)
        button.Text = text
        button.BackgroundColor3 = color or Color3.fromRGB(45, 45, 45)
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.BorderSizePixel = 0
        button.Font = Enum.Font.SourceSans
        button.TextSize = 12
        button.Parent = Frame
        button.MouseButton1Click:Connect(callback)
        return button
    end

    -- Выбор сложности
    local diffLabel = Instance.new("TextLabel")
    diffLabel.Size = UDim2.new(0, 200, 0, 16)
    diffLabel.Position = UDim2.new(0, 10, 0, y)
    diffLabel.Text = "Сложность: Nightmare"
    diffLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    diffLabel.BackgroundTransparency = 1
    diffLabel.Font = Enum.Font.SourceSans
    diffLabel.TextSize = 11
    diffLabel.Parent = Frame
    y = y + 17

    local difficulties = {"Easy", "Hard", "Insane", "Nightmare"}
    local diffColors = {
        Easy = Color3.fromRGB(0, 150, 0),
        Hard = Color3.fromRGB(200, 200, 0),
        Insane = Color3.fromRGB(200, 0, 0),
        Nightmare = Color3.fromRGB(100, 0, 200)
    }
    local diffIndex = 4
    local diffButton = createButton("Сменить сложность", y, function()
        diffIndex = diffIndex % #difficulties + 1
        Settings.Difficulty = difficulties[diffIndex]
        diffLabel.Text = "Сложность: " .. Settings.Difficulty
        diffButton.BackgroundColor3 = diffColors[Settings.Difficulty]
        selectDifficulty(Settings.Difficulty)
    end, diffColors["Nightmare"])
    y = y + 27

    -- Автоскип
    local skipButton = createButton("AutoSkip: ON", y, function()
        Settings.AutoSkip = not Settings.AutoSkip
        skipButton.Text = "AutoSkip: " .. (Settings.AutoSkip and "ON" or "OFF")
        skipButton.BackgroundColor3 = Settings.AutoSkip and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(45, 45, 45)
    end, Color3.fromRGB(0, 120, 0))
    y = y + 27

    -- Авторестарт
    local restartButton = createButton("AutoRestart: ON", y, function()
        Settings.AutoRestart = not Settings.AutoRestart
        restartButton.Text = "AutoRestart: " .. (Settings.AutoRestart and "ON" or "OFF")
        restartButton.BackgroundColor3 = Settings.AutoRestart and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(45, 45, 45)
    end, Color3.fromRGB(0, 120, 0))
    y = y + 27

    -- Выбор сложности сейчас
    createButton("ВЫБРАТЬ СЛОЖНОСТЬ СЕЙЧАС", y, function()
        selectDifficulty(Settings.Difficulty)
    end, Color3.fromRGB(100, 0, 200))
    y = y + 27

    -- Телепорт к туалету
    createButton("Телепорт к туалету", y, function()
        walkToToilet()
    end, Color3.fromRGB(45, 120, 45))
    y = y + 27

    -- Инфо
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(0, 200, 0, 40)
    infoLabel.Position = UDim2.new(0, 10, 0, y)
    infoLabel.Text = "Скрипт сам выберет\nсложность при старте"
    infoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Font = Enum.Font.SourceSans
    infoLabel.TextSize = 10
    infoLabel.Parent = Frame

    -- === ГЛАВНЫЙ ЦИКЛ АВТОФАРМА ===
    spawn(function()
        -- Сразу выбираем сложность при загрузке
        wait(2)
        selectDifficulty(Settings.Difficulty)

        while true do
            if Settings.AutoSkip then
                pcall(autoSkipWave)
            end

            if Settings.AutoRestart then
                pcall(function()
                    if checkGameOver() then
                        wait(1)
                        autoRestart()
                    end
                end)
            end

            wait(0.3)
        end
    end)

    print("SWILL Auto Farm v3.0 загружен! Режим: " .. Settings.Difficulty)

end)

if not success then
    warn("SWILL Script Error: " .. tostring(err))
end
