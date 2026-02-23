-- Chat GUI Enhancement Script
-- Улучшения для интерфейса чата

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Настройки анимации
local TWEEN_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Цветовые темы
local themes = {
    default = {
        background = Color3.new(0.1, 0.1, 0.1),
        input = Color3.new(0.2, 0.2, 0.2),
        button = Color3.new(0.2, 0.6, 1),
        text = Color3.new(1, 1, 1),
        accent = Color3.new(0.3, 0.8, 1)
    },
    dark = {
        background = Color3.new(0.05, 0.05, 0.05),
        input = Color3.new(0.15, 0.15, 0.15),
        button = Color3.new(0.1, 0.4, 0.8),
        text = Color3.new(0.9, 0.9, 0.9),
        accent = Color3.new(0.2, 0.6, 0.9)
    },
    light = {
        background = Color3.new(0.9, 0.9, 0.9),
        input = Color3.new(0.8, 0.8, 0.8),
        button = Color3.new(0.3, 0.7, 1),
        text = Color3.new(0.1, 0.1, 0.1),
        accent = Color3.new(0.2, 0.6, 1)
    }
}

local currentTheme = "default"

-- Функция применения темы
local function applyTheme(themeName)
    local theme = themes[themeName]
    if not theme then return end
    
    local screenGui = player:WaitForChild("PlayerGui"):FindFirstChild("CustomChatGUI")
    if not screenGui then return end
    
    local chatFrame = screenGui:FindFirstChild("ChatFrame")
    local inputBox = chatFrame:FindFirstChild("InputBox")
    local sendButton = chatFrame:FindFirstChild("SendButton")
    local toggleButton = screenGui:FindFirstChild("ToggleButton")
    
    if chatFrame then
        local tween = TweenService:Create(chatFrame, TWEEN_INFO, {BackgroundColor3 = theme.background})
        tween:Play()
    end
    
    if inputBox then
        local tween = TweenService:Create(inputBox, TWEEN_INFO, {
            BackgroundColor3 = theme.input,
            TextColor3 = theme.text,
            PlaceholderColor3 = Color3.new(theme.text.R * 0.7, theme.text.G * 0.7, theme.text.B * 0.7)
        })
        tween:Play()
    end
    
    if sendButton then
        local tween = TweenService:Create(sendButton, TWEEN_INFO, {
            BackgroundColor3 = theme.button,
            TextColor3 = theme.text
        })
        tween:Play()
    end
    
    if toggleButton then
        local tween = TweenService:Create(toggleButton, TWEEN_INFO, {
            BackgroundColor3 = theme.button,
            TextColor3 = theme.text
        })
        tween:Play()
    end
    
    currentTheme = themeName
end

-- Функция добавления эффектов при наведении
local function addHoverEffects()
    local screenGui = player:WaitForChild("PlayerGui"):FindFirstChild("CustomChatGUI")
    if not screenGui then return end
    
    local sendButton = screenGui:FindFirstChild("ChatFrame"):FindFirstChild("SendButton")
    local toggleButton = screenGui:FindFirstChild("ToggleButton")
    
    if sendButton then
        sendButton.MouseEnter:Connect(function()
            local tween = TweenService:Create(sendButton, TWEEN_INFO, {BackgroundColor3 = themes[currentTheme].accent})
            tween:Play()
        end)
        
        sendButton.MouseLeave:Connect(function()
            local tween = TweenService:Create(sendButton, TWEEN_INFO, {BackgroundColor3 = themes[currentTheme].button})
            tween:Play()
        end)
    end
    
    if toggleButton then
        toggleButton.MouseEnter:Connect(function()
            local tween = TweenService:Create(toggleButton, TWEEN_INFO, {BackgroundColor3 = themes[currentTheme].accent})
            tween:Play()
        end)
        
        toggleButton.MouseLeave:Connect(function()
            local tween = TweenService:Create(toggleButton, TWEEN_INFO, {BackgroundColor3 = themes[currentTheme].button})
            tween:Play()
        end)
    end
end

-- Функция добавления анимации появления/скрытия
local function addToggleAnimations()
    local screenGui = player:WaitForChild("PlayerGui"):FindFirstChild("CustomChatGUI")
    if not screenGui then return end
    
    local chatFrame = screenGui:FindFirstChild("ChatFrame")
    if not chatFrame then return end
    
    -- Сохраняем оригинальную позицию
    local originalPosition = chatFrame.Position
    local hiddenPosition = UDim2.new(originalPosition.X.Scale, originalPosition.X.Offset, 1.1, 0)
    
    -- Анимация появления
    chatFrame:GetPropertyChangedSignal("Visible"):Connect(function()
        if chatFrame.Visible then
            chatFrame.Position = hiddenPosition
            local tween = TweenService:Create(chatFrame, TWEEN_INFO, {Position = originalPosition})
            tween:Play()
        end
    end)
end

-- Функция добавления индикатора набора текста
local function addTypingIndicator()
    local screenGui = player:WaitForChild("PlayerGui"):FindFirstChild("CustomChatGUI")
    if not screenGui then return end
    
    local inputBox = screenGui:FindFirstChild("ChatFrame"):FindFirstChild("InputBox")
    if not inputBox then return end
    
    local isTyping = false
    
    inputBox:GetPropertyChangedSignal("Text"):Connect(function()
        if inputBox.Text ~= "" and not isTyping then
            isTyping = true
            -- Здесь можно добавить индикатор набора текста
        elseif inputBox.Text == "" then
            isTyping = false
        end
    end)
end

-- Функция добавления горячих клавиш для смены темы
local function addThemeHotkeys()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        -- Ctrl+1 - тема по умолчанию
        if input.KeyCode == Enum.KeyCode.One and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            applyTheme("default")
        -- Ctrl+2 - темная тема
        elseif input.KeyCode == Enum.KeyCode.Two and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            applyTheme("dark")
        -- Ctrl+3 - светлая тема
        elseif input.KeyCode == Enum.KeyCode.Three and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            applyTheme("light")
        end
    end)
end

-- Инициализация улучшений
spawn(function()
    wait(1) -- Ждем загрузки основного GUI
    
    addHoverEffects()
    addToggleAnimations()
    addTypingIndicator()
    addThemeHotkeys()
    
    print("Chat GUI enhancements loaded")
end)

-- Экспорт функций
return {
    applyTheme = applyTheme,
    themes = themes,
    addHoverEffects = addHoverEffects,
    addToggleAnimations = addToggleAnimations
}
