--[[
    SWILL GUI Scanner
    Сканирует все кнопки на экране при появлении ошибки
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

print("[SWILL Scanner] Запущен. Жду ошибку соединения...")
print("[SWILL Scanner] Когда появится окно с ошибкой — посмотри в консоль")

local function scanAllButtons()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then
        print("[SWILL Scanner] PlayerGui не найден")
        return
    end

    print("==================== НАЧАЛО СКАНИРОВАНИЯ ====================")
    local foundCount = 0

    for _, obj in ipairs(playerGui:GetDescendants()) do
        if obj:IsA("TextButton") or obj:IsA("ImageButton") then
            foundCount = foundCount + 1
            pcall(function()
                local info = ""
                info = info .. "Имя: " .. tostring(obj.Name)
                info = info .. " | Класс: " .. tostring(obj.ClassName)
                if obj:IsA("TextButton") then
                    info = info .. " | Текст: " .. tostring(obj.Text)
                end
                info = info .. " | Visible: " .. tostring(obj.Visible)
                info = info .. " | Active: " .. tostring(obj.Active)
                if obj.Parent then
                    info = info .. " | Родитель: " .. tostring(obj.Parent.Name)
                end
                print("[SWILL Scanner] КНОПКА #" .. foundCount .. ": " .. info)
            end)
        end
    end

    -- Сканируем текстовые метки тоже (там может быть текст ошибки)
    print("==================== ТЕКСТОВЫЕ МЕТКИ ====================")
    for _, obj in ipairs(playerGui:GetDescendants()) do
        if obj:IsA("TextLabel") and obj.Visible then
            pcall(function()
                local text = tostring(obj.Text)
                if text ~= "" and #text > 3 then
                    print("[SWILL Scanner] ТЕКСТ: " .. text .. " | Родитель: " .. tostring(obj.Parent.Name))
                end
            end)
        end
    end

    print("==================== КОНЕЦ СКАНИРОВАНИЯ ====================")
    print("[SWILL Scanner] Найдено кнопок: " .. foundCount)
end

-- Проверяем каждую секунду, не появилась ли ошибка
local disconnectPhrases = {
    "disconnected", "connection timed out", "lost connection",
    "connection lost", "timeout", "timed out", "no internet",
    "network error", "error 277", "error 260", "error 268",
    "please reconnect", "check your internet", "reconnect to",
    "server disconnected", "kicked"
}

local scanned = false

while true do
    pcall(function()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui and not scanned then
            for _, obj in ipairs(playerGui:GetDescendants()) do
                if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                    pcall(function()
                        local text = ""
                        if obj:IsA("TextLabel") then text = obj.Text
                        elseif obj:IsA("TextButton") then text = obj.Text end
                        local lowerText = text:lower()
                        for _, phrase in ipairs(disconnectPhrases) do
                            if lowerText:find(phrase) and obj.Visible then
                                print("[SWILL Scanner] ОБНАРУЖЕНА ОШИБКА: " .. text)
                                scanAllButtons()
                                scanned = true
                                return
                            end
                        end
                    end)
                end
            end
        end
    end)
    task.wait(1)
end
