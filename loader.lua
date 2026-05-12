--[[
    SWILL Auto Reconnect v1.0
    Фоновый мониторинг разрыва соединения
    Никаких меню, никакого фарма — только реконнект
]]

local success, err = pcall(function()

    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local RunService = game:GetService("RunService")

    -- === НАСТРОЙКИ ===
    local CHECK_INTERVAL = 0.5 -- Проверка каждые полсекунды
    local CLICK_DELAY = 0.1 -- Задержка между кликами если кнопка не исчезает

    -- === ФУНКЦИЯ КЛИКА ===
    local function clickButton(button)
        if not button then return false end
        pcall(function()
            if not button.Visible then return end
            local pos = button.AbsolutePosition
            local size = button.AbsoluteSize
            local x = pos.X + size.X / 2
            local y = pos.Y + size.Y / 2

            VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
            task.wait(0.03)
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
        end)
        return true
    end

    -- === ПОИСК КНОПКИ RECONNECT ===
    local function findReconnectButton()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then return nil end

        -- Проходим по ВСЕМ объектам GUI
        for _, obj in ipairs(playerGui:GetDescendants()) do
            if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                pcall(function()
                    local objText = ""
                    if obj:IsA("TextButton") then
                        objText = obj.Text
                    end

                    local reconnectKeywords = {
                        "reconnect",
                        "rejoin",
                        "connect",
                        "retry",
                        "play again",
                        "continue",
                        "ok"
                    }

                    local lowerText = objText:lower()
                    for _, keyword in ipairs(reconnectKeywords) do
                        if lowerText:find(keyword) then
                            -- Дополнительная проверка: рядом должен быть текст об ошибке
                            return obj
                        end
                    end
                end)
            end
        end
        return nil
    end

    -- === ПРОВЕРКА НАЛИЧИЯ ОШИБКИ СОЕДИНЕНИЯ ===
    local function isConnectionError()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then return false end

        local disconnectPhrases = {
            "disconnected",
            "connection timed out",
            "lost connection",
            "connection lost",
            "timeout",
            "timed out",
            "no internet",
            "network error",
            "error 277",
            "error 260",
            "error 268",
            "please reconnect",
            "check your internet",
            "reconnect to",
            "server disconnected",
            "kicked"
        }

        for _, obj in ipairs(playerGui:GetDescendants()) do
            if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                pcall(function()
                    local objText = ""
                    if obj:IsA("TextLabel") then
                        objText = obj.Text
                    elseif obj:IsA("TextButton") then
                        objText = obj.Text
                    end

                    local lowerText = objText:lower()
                    for _, phrase in ipairs(disconnectPhrases) do
                        if lowerText:find(phrase) and obj.Visible then
                            return true
                        end
                    end
                end)
            end
        end
        return false
    end

    -- === ГЛАВНАЯ ЛОГИКА ===
    local lastClickTime = 0
    local reconnectAttempts = 0
    local maxAttempts = 10 -- Максимум попыток чтобы не зациклиться

    local function attemptReconnect()
        local currentTime = tick()

        -- Защита от слишком частых кликов
        if currentTime - lastClickTime < CLICK_DELAY then return end
        if reconnectAttempts >= maxAttempts then
            task.wait(5) -- Пауза, если кнопка не пропадает
            reconnectAttempts = 0
            return
        end

        local button = findReconnectButton()
        if button then
            clickButton(button)
            lastClickTime = currentTime
            reconnectAttempts = reconnectAttempts + 1
        end
    end

    -- === ЦИКЛ МОНИТОРИНГА ===
    print("[SWILL] Auto Reconnect активен. Мониторинг соединения...")

    while true do
        pcall(function()
            if isConnectionError() then
                print("[SWILL] Обнаружен разрыв соединения! Пытаюсь переподключиться...")
                attemptReconnect()
            else
                -- Сброс счётчика попыток если ошибки нет
                reconnectAttempts = 0
            end
        end)
        task.wait(CHECK_INTERVAL)
    end

end)

if not success then
    warn("[SWILL] Ошибка скрипта: " .. tostring(err))
    -- Перезапуск при ошибке
    task.wait(3)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/AvianLil/Legacy/main/loader.lua"))()
end
