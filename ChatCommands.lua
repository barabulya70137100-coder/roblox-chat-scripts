-- Chat Commands Script
-- Команды для управления чатом

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local ChatEvent = ReplicatedStorage:WaitForChild("CustomChatEvent")

-- Список команд
local commands = {
    help = function(args)
        local helpText = "[Custom Chat Commands]:\n"
        helpText = helpText .. "/help - Show this help\n"
        helpText = helpText .. "/clear - Clear chat history\n"
        helpText = helpText .. "/me <action> - Send action message\n"
        helpText = helpText .. "/ping - Check connection\n"
        
        StarterGui:SetCore("ChatMakeSystemMessage", {
            Text = helpText;
            Color = Color3.new(0.3, 0.8, 1);
            Font = Enum.Font.SourceSans;
        })
    end,
    
    clear = function(args)
        -- Очистка истории чата
        local screenGui = player:WaitForChild("PlayerGui"):FindFirstChild("CustomChatGUI")
        if screenGui then
            local messageContainer = screenGui:FindFirstChild("ChatFrame"):FindFirstChild("MessageContainer")
            if messageContainer then
                for _, child in pairs(messageContainer:GetChildren()) do
                    child:Destroy()
                end
                
                StarterGui:SetCore("ChatMakeSystemMessage", {
                    Text = "[Custom Chat] Chat history cleared!";
                    Color = Color3.new(0.5, 0.5, 0.5);
                    Font = Enum.Font.SourceSans;
                })
            end
        end
    end,
    
    me = function(args)
        if #args > 0 then
            local action = table.concat(args, " ")
            ChatEvent:FireServer("SendMessage", "* " .. player.Name .. " " .. action)
        else
            StarterGui:SetCore("ChatMakeSystemMessage", {
                Text = "[Custom Chat] Usage: /me <action>";
                Color = Color3.new(1, 0.5, 0);
                Font = Enum.Font.SourceSans;
            })
        end
    end,
    
    ping = function(args)
        local startTime = tick()
        
        ChatEvent:FireServer("PingRequest", startTime)
        
        -- Ответ будет обработан в remote event
    end
}

-- Функция для парсинга команд
local function parseCommand(message)
    if message:sub(1, 1) == "/" then
        local parts = {}
        for part in message:gmatch("%S+") do
            table.insert(parts, part)
        end
        
        local command = parts[1]:sub(2):lower()
        local args = {}
        
        for i = 2, #parts do
            table.insert(args, parts[i])
        end
        
        if commands[command] then
            commands[command](args)
            return true
        else
            StarterGui:SetCore("ChatMakeSystemMessage", {
                Text = "[Custom Chat] Unknown command: " .. command;
                Color = Color3.new(1, 0, 0);
                Font = Enum.Font.SourceSans;
            })
            return true
        end
    end
    
    return false
end

-- Перехват сообщений для обработки команд
local originalSendMessage = nil

-- Подключаемся к RemoteEvent для обработки пинга
ChatEvent.OnClientEvent:Connect(function(messageType, ...)
    if messageType == "PingResponse" then
        local startTime = ...
        local ping = math.floor((tick() - startTime) * 1000)
        
        StarterGui:SetCore("ChatMakeSystemMessage", {
            Text = "[Custom Chat] Ping: " .. ping .. "ms";
            Color = Color3.new(0, 1, 0.5);
            Font = Enum.Font.SourceSans;
        })
    end
end)

-- Экспорт функции парсинга для использования в ChatClient
return {
    parseCommand = parseCommand,
    commands = commands
}
