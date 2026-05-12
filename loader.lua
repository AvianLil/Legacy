--[[
    SWILL Deep Scanner v2.0
    Сканирует ВСЕ GUI-элементы включая CoreGui
    Сохраняет результаты в файл
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- Функция для записи в файл (сохраняем на раб столе)
local function writeToFile(content)
    pcall(function()
        if writefile then
            writefile("SWILL_scan_results.txt", content)
            print("[SWILL] Результаты сохранены в SWILL_scan_results.txt")
        end
    end)
end

-- Сбор всей информации
local function deepScan()
    local results = {}
    table.insert(results, "==================== СКАНИРОВАНИЕ " .. os.date() .. " ====================")
    
    local allGuis = {}
    
    -- PlayerGui
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        table.insert(allGuis, {"PlayerGui", playerGui})
    end
    
    -- CoreGui
    table.insert(allGuis, {"CoreGui", CoreGui})
    
    -- Ищем вообще все ScreenGui
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("ScreenGui") and obj ~= playerGui and obj.Parent ~= CoreGui then
            table.insert(allGuis, {"Unknown ScreenGui: " .. obj.Name, obj})
        end
    end
    
    -- Сканируем каждый GUI
    for _, guiData in ipairs(allGuis) do
        local guiName = guiData[1]
        local guiObj = guiData[2]
        
        table.insert(results, "\n📁 " .. guiName .. " (" .. guiObj.ClassName .. ")")
        
        local foundInThis = 0
        for _, obj in ipairs(guiObj:GetDescendants()) do
            if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                foundInThis = foundInThis + 1
                pcall(function()
                    local info = "├─ [" .. obj.ClassName .. "]"
                    info = info .. " Name: " .. tostring(obj.Name)
                    if obj:IsA("TextButton") then
                        info = info .. " | Text: '" .. tostring(obj.Text) .. "'"
                    end
                    info = info .. " | Visible: " .. tostring(obj.Visible)
                    info = info .. " | Active: " .. tostring(obj.Active)
                    info = info .. " | Size: " .. tostring(obj.AbsoluteSize.X) .. "x" .. tostring(obj.AbsoluteSize.Y)
                    info = info .. " | Pos: " .. tostring(obj.AbsolutePosition.X) .. "," .. tostring(obj.AbsolutePosition.Y)
                    if obj.Parent then
                        info = info .. " | Parent: " .. tostring(obj.Parent.Name)
                    end
                    table.insert(results, info)
                end)
            end
            -- Текстовые метки
            if obj:IsA("TextLabel") and obj.Visible then
                pcall(function()
                    local text = tostring(obj.Text)
                    if #text > 2 and #text < 200 then
                        table.insert(results, "├─ [TEXT] '" .. text .. "' | Parent: " .. tostring(obj.Parent.Name))
                    end
                end)
            end
        end
        table.insert(results, "└─ Всего найдено: " .. foundInThis .. " кнопок")
    end
    
    table.insert(results, "==================== КОНЕЦ СКАНИРОВАНИЯ ====================")
    
    local fullText = table.concat(results, "\n")
    print(fullText)
    writeToFile(fullText)
    
    return fullText
end

-- Ждём 5 секунд после запуска, потом сканируем
print("[SWILL] Сканер запущен. Жду 5 секунд...")
print("[SWILL] Через 5 секунд буду сканировать ВСЕ кнопки на экране.")
print("[SWILL] СПЕЦИАЛЬНО ВЫЗОВИ ОШИБКУ ИНТЕРНЕТА (выдерни кабель/WiFi)")
print("[SWILL] И когда появится окно с Reconnect - НАЖМИ В КОНСОЛИ ДЕЛЬТЫ КНОПКУ:")
print("[SWILL] ==> СКАНИРОВАТЬ СНОВА <==")
print("[SWILL] Или просто подожди 30 секунд, сканер сам всё проверит")

-- Первое сканирование через 5 секунд (что есть на экране сейчас)
task.wait(5)
print("\n[SWILL] === ПЕРВОЕ СКАНИРОВАНИЕ (то что на экране сейчас) ===")
deepScan()

-- Автоматическое сканирование каждые 15 секунд (на случай если ошибка появится)
local scanCount = 0
while true do
    task.wait(15)
    scanCount = scanCount + 1
    print("\n[SWILL] === АВТОСКАНИРОВАНИЕ #" .. scanCount .. " ===")
    
    -- Проверяем есть ли на экране что-то похожее на ошибку
    pcall(function()
        local allTexts = ""
        for _, guiObj in ipairs({LocalPlayer:FindFirstChild("PlayerGui"), CoreGui}) do
            if guiObj then
                for _, obj in ipairs(guiObj:GetDescendants()) do
                    if obj:IsA("TextLabel") and obj.Visible then
                        pcall(function()
                            allTexts = allTexts .. tostring(obj.Text):lower() .. " "
                        end)
                    end
                end
            end
        end
        
        local errorKeywords = {"disconnect", "timeout", "reconnect", "lost connection", "timed out", "error"}
        for _, kw in ipairs(errorKeywords) do
            if allTexts:find(kw) then
                print("[SWILL] 🚨 НАЙДЕНА ОШИБКА! Ключевое слово: " .. kw)
                print("[SWILL] Делаю глубокое сканирование прямо сейчас...")
                deepScan()
                break
            end
        end
    end)
end
