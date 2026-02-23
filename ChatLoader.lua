-- Custom Chat Loader System
-- Загрузчик скриптов кастомного чата

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- URL где будут храниться ваши скрипты чата
local SCRIPT_BASE_URL = "https://raw.githubusercontent.com/yourusername/roblox-chat-scripts/main/"

-- Таблица с именами скриптов для загрузки
local CHAT_SCRIPTS = {
    "ChatServer.lua",
    "ChatClient.lua", 
    "ChatGUI.lua",
    "ChatCommands.lua"
}

-- Функция для загрузки скрипта из URL
local function loadScriptFromURL(scriptName, url)
    local success, result = pcall(function()
        return HttpService:GetAsync(url)
    end)
    
    if success then
        print("Successfully loaded: " .. scriptName)
        return result
    else
        warn("Failed to load " .. scriptName .. ": " .. tostring(result))
        return nil
    end
end

-- Функция для выполнения загруженного скрипта
local function executeScript(scriptName, scriptCode)
    if not scriptCode then
        warn("Cannot execute " .. scriptName .. " - no code loaded")
        return false
    end
    
    local success, error = pcall(function()
        local func = loadstring(scriptCode)
        if func then
            func()
            print("Successfully executed: " .. scriptName)
            return true
        else
            warn("Failed to compile " .. scriptName)
            return false
        end
    end)
    
    if not success then
        warn("Error executing " .. scriptName .. ": " .. tostring(error))
        return false
    end
    
    return success
end

-- Основная функция загрузчика
local function loadChatScripts()
    print("Starting Custom Chat Loader...")
    
    local loadedScripts = 0
    local totalScripts = #CHAT_SCRIPTS
    
    for _, scriptName in pairs(CHAT_SCRIPTS) do
        local url = SCRIPT_BASE_URL .. scriptName
        local scriptCode = loadScriptFromURL(scriptName, url)
        
        if scriptCode then
            if executeScript(scriptName, scriptCode) then
                loadedScripts = loadedScripts + 1
            end
        end
        
        -- Небольшая задержка между загрузками
        wait(0.1)
    end
    
    print(string.format("Chat Loader completed: %d/%d scripts loaded", loadedScripts, totalScripts))
    
    if loadedScripts == totalScripts then
        print("All chat scripts loaded successfully!")
        
        -- Уведомление для игрока
        if Players.LocalPlayer then
            local StarterGui = game:GetService("StarterGui")
            StarterGui:SetCore("ChatMakeSystemMessage", {
                Text = "[Custom Chat] All scripts loaded successfully!";
                Color = Color3.new(0, 1, 0);
                Font = Enum.Font.SourceSansBold;
            })
        end
    else
        warn("Some chat scripts failed to load")
        
        -- Уведомление об ошибке
        if Players.LocalPlayer then
            local StarterGui = game:GetService("StarterGui")
            StarterGui:SetCore("ChatMakeSystemMessage", {
                Text = "[Custom Chat] Some scripts failed to load!";
                Color = Color3.new(1, 0, 0);
                Font = Enum.Font.SourceSansBold;
            })
        end
    end
end

-- Функция для проверки доступности URL
local function checkURLAvailability()
    local testUrl = SCRIPT_BASE_URL .. "test.txt"
    local success, result = pcall(function()
        return HttpService:GetAsync(testUrl)
    end)
    
    return success
end

-- Автоматическая загрузка при запуске
spawn(function()
    if checkURLAvailability() then
        loadChatScripts()
    else
        warn("Cannot connect to script repository")
        
        if Players.LocalPlayer then
            local StarterGui = game:GetService("StarterGui")
            StarterGui:SetCore("ChatMakeSystemMessage", {
                Text = "[Custom Chat] Cannot connect to script repository!";
                Color = Color3.new(1, 0.5, 0);
                Font = Enum.Font.SourceSansBold;
            })
        end
    end
end)

-- Экспорт функций для использования в других скриптах
return {
    loadScriptFromURL = loadScriptFromURL,
    executeScript = executeScript,
    loadChatScripts = loadChatScripts,
    checkURLAvailability = checkURLAvailability
}

