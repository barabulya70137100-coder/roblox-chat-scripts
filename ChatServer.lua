-- Chat Server Script
-- Серверная часть чата

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Создаем RemoteEvent для общения
local ChatEvent = Instance.new("RemoteEvent")
ChatEvent.Name = "CustomChatEvent"
ChatEvent.Parent = ReplicatedStorage

-- Игроки с доступом к чату
local playersWithChat = {}

-- Проверка доступа
local function hasAccess(player)
    return playersWithChat[player.UserId] == true
end

-- Выдача доступа
local function grantAccess(player)
    playersWithChat[player.UserId] = true
    print("Chat access granted to: " .. player.Name)
end

-- Обработка сообщений
ChatEvent.OnServerEvent:Connect(function(player, messageType, ...)
    if not hasAccess(player) then return end
    
    if messageType == "SendMessage" then
        local message = ...
        if typeof(message) == "string" and message ~= "" then
            local filtered = game:GetService("Chat"):FilterStringAsync(message, player, Players:GetPlayers())
            
            for _, target in pairs(Players:GetPlayers()) do
                if hasAccess(target) then
                    ChatEvent:FireClient(target, "ReceiveMessage", player.Name, filtered)
                end
            end
        end
    elseif messageType == "RequestAccess" then
        grantAccess(player)
        ChatEvent:FireClient(player, "AccessGranted", true)
    end
end)

-- Автоматическая выдача доступа при входе
Players.PlayerAdded:Connect(function(player)
    grantAccess(player)
end)

-- Удаление доступа при выходе
Players.PlayerRemoving:Connect(function(player)
    playersWithChat[player.UserId] = nil
end)

print("Chat Server loaded")
