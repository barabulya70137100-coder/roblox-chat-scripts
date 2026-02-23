-- Chat Client Script
-- Клиентская часть чата

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local ChatEvent = ReplicatedStorage:WaitForChild("CustomChatEvent")

-- GUI переменные
local screenGui, chatFrame, messageContainer, inputBox, sendButton
local chatVisible = false
local MAX_MESSAGES = 50

-- Создание GUI
local function createGUI()
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CustomChatGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false
    
    -- Основной фрейм чата
    chatFrame = Instance.new("Frame")
    chatFrame.Size = UDim2.new(0.3, 0, 0.4, 0)
    chatFrame.Position = UDim2.new(0.02, 0, 0.6, 0)
    chatFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    chatFrame.BorderSizePixel = 0
    chatFrame.Parent = screenGui
    
    Instance.new("UICorner", chatFrame).CornerRadius = UDim.new(0, 8)
    
    -- Контейнер сообщений
    messageContainer = Instance.new("ScrollingFrame")
    messageContainer.Size = UDim2.new(1, -10, 1, -40)
    messageContainer.Position = UDim2.new(0, 5, 0, 5)
    messageContainer.BackgroundTransparency = 1
    messageContainer.BorderSizePixel = 0
    messageContainer.ScrollBarThickness = 4
    messageContainer.Parent = chatFrame
    
    -- Поле ввода
    inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(1, -50, 0, 30)
    inputBox.Position = UDim2.new(0, 5, 1, -35)
    inputBox.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    inputBox.BorderSizePixel = 0
    inputBox.Text = ""
    inputBox.PlaceholderText = "Type a message..."
    inputBox.TextColor3 = Color3.new(1, 1, 1)
    inputBox.Font = Enum.Font.SourceSans
    inputBox.TextSize = 14
    inputBox.Parent = chatFrame
    
    Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 4)
    
    -- Кнопка отправки
    sendButton = Instance.new("TextButton")
    sendButton.Size = UDim2.new(0, 40, 0, 30)
    sendButton.Position = UDim2.new(1, -45, 1, -35)
    sendButton.BackgroundColor3 = Color3.new(0.2, 0.6, 1)
    sendButton.BorderSizePixel = 0
    sendButton.Text = "Send"
    sendButton.TextColor3 = Color3.new(1, 1, 1)
    sendButton.Font = Enum.Font.SourceSans
    sendButton.TextSize = 12
    sendButton.Parent = chatFrame
    
    Instance.new("UICorner", sendButton).CornerRadius = UDim.new(0, 4)
    
    -- Кнопка переключения
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 100, 0, 30)
    toggleButton.Position = UDim2.new(0.02, 0, 0.02, 0)
    toggleButton.BackgroundColor3 = Color3.new(0.2, 0.6, 1)
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = "Toggle Chat (/)"
    toggleButton.TextColor3 = Color3.new(1, 1, 1)
    toggleButton.Font = Enum.Font.SourceSans
    toggleButton.TextSize = 12
    toggleButton.Parent = screenGui
    
    Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0, 4)
    
    chatFrame.Visible = false
    
    -- Обработчики кнопок
    sendButton.MouseButton1Click:Connect(function()
        if chatVisible and inputBox.Text ~= "" then
            ChatEvent:FireServer("SendMessage", inputBox.Text)
            inputBox.Text = ""
        end
    end)
    
    toggleButton.MouseButton1Click:Connect(function()
        chatVisible = not chatVisible
        chatFrame.Visible = chatVisible
        if chatVisible then
            inputBox:CaptureFocus()
        else
            inputBox:ReleaseFocus()
        end
    end)
    
    inputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed and chatVisible and inputBox.Text ~= "" then
            ChatEvent:FireServer("SendMessage", inputBox.Text)
            inputBox.Text = ""
        end
    end)
end

-- Добавление сообщения
local function addMessage(sender, message)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 20)
    label.Position = UDim2.new(0, 5, 0, #messageContainer:GetChildren() * 22)
    label.BackgroundTransparency = 1
    label.Text = sender .. ": " .. message
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = messageContainer
    
    -- Ограничение сообщений
    local messages = messageContainer:GetChildren()
    if #messages > MAX_MESSAGES then
        messages[1]:Destroy()
        for i, msg in ipairs(messages) do
            if i > 1 then
                msg.Position = UDim2.new(0, 5, 0, (i-2) * 22)
            end
        end
    end
    
    messageContainer.CanvasPosition = Vector2.new(0, messageContainer.CanvasSize.Y.Offset)
end

-- Обработка remote событий
ChatEvent.OnClientEvent:Connect(function(messageType, ...)
    if messageType == "ReceiveMessage" then
        addMessage(...)
    elseif messageType == "AccessGranted" then
        StarterGui:SetCore("ChatMakeSystemMessage", {
            Text = "[Custom Chat] Access granted! Press / to toggle chat.";
            Color = Color3.new(0, 1, 0);
            Font = Enum.Font.SourceSansBold;
        })
    end
end)

-- Обработка ввода
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Slash then
        chatVisible = not chatVisible
        chatFrame.Visible = chatVisible
        if chatVisible then
            inputBox:CaptureFocus()
        else
            inputBox:ReleaseFocus()
        end
    elseif input.KeyCode == Enum.KeyCode.Escape and chatVisible then
        chatVisible = false
        chatFrame.Visible = false
        inputBox:ReleaseFocus()
    end
end)

-- Инициализация
createGUI()
ChatEvent:FireServer("RequestAccess")

print("Chat Client loaded")
