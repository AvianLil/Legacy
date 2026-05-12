--[[
    SWILL Auto Reconnect v2.0
    Целится точно в кнопки CoreGui
]]

local success, err = pcall(function()

    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local CoreGui = game:GetService("CoreGui")

    print("[SWILL] Auto Reconnect v2.0 запущен")
    print("[SWILL] Мониторю CoreGui на ошибки соединения...")

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
            task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
            print("[SWILL] Клик по кнопке: " .. tostring(button.Name))
        end)
        return true
    end

    -- === ПОИСК КНОПОК RECONNECT В COREGUI ===
    local function findReconnectInCoreGui()
        -- Ищем по всем элементам CoreGui
        for _, obj in ipairs(CoreGui:GetDescendants()) do
            if obj:IsA("TextButton") and obj.Visible then
                pcall(function()
                    local text = obj.Text:lower()
                    local name = obj.Name:lower()

                    -- Ключевые слова для поиска
                    local keywords = {
                        "accept",
                        "ok",
                        "okay",
                        "reconnect",
                        "rejoin",
                        "retry",
                        "continue",
                        "restart",
                        "yes",
                        "confirm"
                    }

                    for _, kw in ipairs(keywords) do
                        if text:find(kw) or name:find(kw) then
                            return obj
                        end
                    end
                end)
            end
        end
        return nil
    end

    -- === ПОИСК ТЕКСТА ОШИБКИ В COREGUI ===
    local function isErrorInCoreGui()
        local errorPhrases = {
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
            "kicked",
            "please wait",
            "restart",
            "warning",
            "headset disconnected",
            "teleporting"
        }

        for _, obj in ipairs(CoreGui:GetDescendants()) do
            if (obj:IsA("TextLabel") or obj:IsA("TextButton")) and obj.Visible then
                pcall(function()
                    local text = obj.Text:lower()
                    for _, phrase in ipairs(errorPhrases) do
                        if text:find(phrase) then
                            print("[SWILL] Обнаружен текст ошибки: '" .. tostring(obj.Text) .. "'")
                            return true
                        end
                    end
                end)
            end
        end
        return false
    end

    -- === ТАКЖЕ ПРОВЕРЯЕМ PLAYERGUI ===
    local function isErrorInPlayerGui()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then return false end

        local errorPhrases = {
            "disconnected",
            "connection timed out",
            "lost connection",
            "reconnect",
            "timeout",
            "timed out"
        }

        for _, obj in ipairs(playerGui:GetDescendants()) do
            if (obj:IsA("TextLabel") or obj:IsA("TextButton")) and obj.Visible then
                pcall(function()
                    local text = obj.Text:lower()
                    for _, phrase in ipairs(errorPhrases) do
                        if text:find(phrase) then
                            print("[SWILL] Обнаружена ошибка в PlayerGui: '" .. tostring(obj.Text) .. "'")
                            return true
                        end
                    end
                end)
            end
        end
        return false
    end

    -- === ГЛАВНЫЙ ЦИКЛ ===
    local lastClickTime = 0

    while true do
        pcall(function()
            local hasError = isErrorInCoreGui() or isErrorInPlayerGui()

            if hasError then
                local now = tick()
                if now - lastClickTime > 1 then -- Задержка между попытками
                    local button = findReconnectInCoreGui()
                    if button then
                        print("[SWILL] Найдена кнопка: " .. tostring(button.Name) .. " | Текст: " .. tostring(button.Text))
                        clickButton(button)
                        lastClickTime = now
                    else
                        print("[SWILL] Ошибка обнаружена, но кнопка не найдена. Пробую ещё раз через секунду...")
                    end
                end
            end
        end)
        task.wait(0.5) -- Проверка каждые полсекунды
    end

end)

if not success then
    warn("[SWILL] Критическая ошибка: " .. tostring(err))
    task.wait(3)
    -- Автоперезапуск
    loadstring(game:HttpGet("https://raw.githubusercontent.com/AvianLil/Legacy/main/loader.lua"))()
end
