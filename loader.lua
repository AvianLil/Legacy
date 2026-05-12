--[[
    SWILL Auto Reconnect v2.1 LITE
    Для слабых ПК. Проверка раз в 2 секунды.
]]

local success, err = pcall(function()

    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local CoreGui = game:GetService("CoreGui")

    print("[SWILL] Auto Reconnect LITE запущен")

    local function clickButton(button)
        if not button then return false end
        pcall(function()
            if not button.Visible then return end
            local pos = button.AbsolutePosition
            local size = button.AbsoluteSize
            local x = pos.X + size.X / 2
            local y = pos.Y + size.Y / 2
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
            task.wait(0.1)
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
        end)
        return true
    end

    local function findAndClickReconnect()
        -- Только CoreGui, без лишних проходов
        for _, obj in ipairs(CoreGui:GetDescendants()) do
            if obj:IsA("TextButton") and obj.Visible then
                pcall(function()
                    local text = obj.Text:lower()
                    if text:find("accept") or text:find("ok") or text:find("reconnect") 
                        or text:find("retry") or text:find("restart") or text:find("continue")
                        or text:find("yes") or text:find("confirm") or text:find("rejoin") then
                        clickButton(obj)
                        print("[SWILL] Нажата кнопка: " .. tostring(obj.Text))
                    end
                end)
            end
        end
    end

    -- Главный цикл — проверка раз в 2 секунды
    while true do
        pcall(findAndClickReconnect)
        task.wait(30)
    end

end)

if not success then
    warn("[SWILL] Ошибка: " .. tostring(err))
end
