--==============================================================================
-- SquadRimStudia | Skibi Defense Utility (With Saved Macros & Advanced Speed-Up)
--==============================================================================

local ConfigFile = "SquadRimConfig.json"
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Flags = {
    AutoPlay = false,
    AutoSkip = false,
    AutoMaxUnits = false,
    AutoSpeedUp = false,
    TargetSpeed = 16,
    AntiAFK = true
}

-- Настройки и переменные макросов
local Macros = {}
local SelectedMacro = nil
local IsRecording = false
local IsPlaying = false
local RecordStartTime = 0
local CurrentRecord = {}

-- Таблица для динамического обновления списка в GUI
local MacroNamesList = {"Нет макросов"}
local MacroDropdown = nil

-- Функция сериализации CFrame в таблицу для сохранения в JSON
local function cframeToTable(cf)
    local x, y, z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = cf:GetComponents()
    return {x, y, z, R00, R01, R02, R10, R11, R12, R20, R21, R22}
end

-- Функция восстановления CFrame из таблицы
local function tableToCFrame(t)
    return CFrame.new(t[1], t[2], t[3], t[4], t[5], t[6], t[7], t[8], t[9], t[10], t[11], t[12])
end

local function saveSettings()
    local pcallSuccess, encoded = pcall(function()
        local savedMacros = {}
        for macroName, frames in pairs(Macros) do
            savedMacros[macroName] = {}
            for _, frame in ipairs(frames) do
                table.insert(savedMacros[macroName], {
                    Time = frame.Time,
                    CFrame = cframeToTable(frame.CFrame),
                    Jump = frame.Jump
                })
            end
        end
        
        local dataToSave = {
            Flags = Flags,
            Macros = savedMacros
        }
        return HttpService:JSONEncode(dataToSave)
    end)
    
    if pcallSuccess and writefile then 
        writefile(ConfigFile, encoded) 
    end
end

local function loadSettings()
    if readfile and isfile and isfile(ConfigFile) then
        local pcallSuccess, decoded = pcall(function() 
            return HttpService:JSONDecode(readfile(ConfigFile)) 
        end)
     
        if pcallSuccess and type(decoded) == "table" then
            -- Восстанавливаем флаги
            if decoded.Flags then
                for k, v in pairs(decoded.Flags) do Flags[k] = v end
            end
            
            -- Восстанавливаем макросы
            if decoded.Macros then
                Macros = {}
                MacroNamesList = {}
                for macroName, frames in pairs(decoded.Macros) do
                    Macros[macroName] = {}
                    for _, frame in ipairs(frames) do
                        table.insert(Macros[macroName], {
                            Time = frame.Time,
                            CFrame = tableToCFrame(frame.CFrame),
                            Jump = frame.Jump
                        })
                    end
                    table.insert(MacroNamesList, macroName)
                end
                if #MacroNamesList == 0 then table.insert(MacroNamesList, "Нет макросов") end
            end
        end
    end
end

loadSettings()

--==============================================================================
-- БИБЛИОТЕКА ИНТЕРФЕЙСА (KAVO LIGHT)
--==============================================================================
local KavoLibrary = {}
do
    local CoreGui = game:GetService("CoreGui")
    local UserInputService = game:GetService("UserInputService")

    function KavoLibrary:CreateMenu(title)
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "SquadRimStudia_GUI"
        ScreenGui.ResetOnSpawn = false
        if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end
        ScreenGui.Parent = CoreGui

        local MainFrame = Instance.new("Frame")
        MainFrame.Name = "MainFrame"
        MainFrame.Size = UDim2.new(0, 450, 0, 420)
        MainFrame.Position = UDim2.new(0.5, -225, 0.5, -210)
        MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        MainFrame.BorderSizePixel = 0
        MainFrame.Active = true
        MainFrame.Draggable = true
        MainFrame.Parent = ScreenGui

        Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Size = UDim2.new(1, -40, 0, 35)
        TitleLabel.Position = UDim2.new(0, 15, 0, 0)
        TitleLabel.Text = title
        TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TitleLabel.TextSize = 16
        TitleLabel.Font = Enum.Font.SourceSansBold
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Parent = MainFrame

        local CloseBtn = Instance.new("TextButton")
        CloseBtn.Size = UDim2.new(0, 30, 0, 30)
        CloseBtn.Position = UDim2.new(1, -35, 0, 5)
        CloseBtn.Text = "X"
        CloseBtn.TextColor3 = Color3.fromRGB(255, 85, 85)
        CloseBtn.TextSize = 18
        CloseBtn.Font = Enum.Font.SourceSansBold
        CloseBtn.BackgroundTransparency = 1
        CloseBtn.Parent = MainFrame
        CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

        local Container = Instance.new("ScrollingFrame")
        Container.Size = UDim2.new(1, -30, 1, -50)
        Container.Position = UDim2.new(0, 15, 0, 45)
        Container.BackgroundTransparency = 1
        Container.CanvasSize = UDim2.new(0, 0, 0, 0)
        Container.ScrollBarThickness = 4
        Container.Parent = MainFrame

        local ListLayout = Instance.new("UIListLayout")
        ListLayout.Padding = UDim.new(0, 8)
        ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ListLayout.Parent = Container

        ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Container.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
        end)

        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and (input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.G) then
                MainFrame.Visible = not MainFrame.Visible
            end
        end)

        local Elements = {}

        function Elements:AddToggle(name, startValue, callback)
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, -6, 0, 40)
            Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            Frame.Parent = Container
            Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

            local Lbl = Instance.new("TextLabel")
            Lbl.Size = UDim2.new(1, -60, 1, 0)
            Lbl.Position = UDim2.new(0, 10, 0, 0)
            Lbl.Text = name
            Lbl.TextColor3 = Color3.fromRGB(230, 230, 230)
            Lbl.TextSize = 14
            Lbl.Font = Enum.Font.SourceSans
            Lbl.TextXAlignment = Enum.TextXAlignment.Left
            Lbl.BackgroundTransparency = 1
            Lbl.Parent = Frame

            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(0, 50, 0, 24)
            Btn.Position = UDim2.new(1, -60, 0.5, -12)
            
            local active = startValue
            local function red()
                Btn.BackgroundColor3 = active and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(200, 50, 50)
                Btn.Text = active and "ВКЛ" or "ВЫКЛ"
            end
            red()

            Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            Btn.Font = Enum.Font.SourceSansBold
            Btn.TextSize = 12
            Btn.Parent = Frame
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)

            Btn.MouseButton1Click:Connect(function()
                active = not active
                red()
                pcall(callback, active)
            end)
            if active then task.spawn(pcall, callback, true) end
        end

        function Elements:AddSlider(name, min, max, default, callback)
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, -6, 0, 50)
            Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            Frame.Parent = Container
            Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

            local Lbl = Instance.new("TextLabel")
            Lbl.Size = UDim2.new(1, -100, 0, 25)
            Lbl.Position = UDim2.new(0, 10, 0, 2)
            Lbl.Text = name
            Lbl.TextColor3 = Color3.fromRGB(230, 230, 230)
            Lbl.TextSize = 14
            Lbl.Font = Enum.Font.SourceSans
            Lbl.TextXAlignment = Enum.TextXAlignment.Left
            Lbl.BackgroundTransparency = 1
            Lbl.Parent = Frame

            local Vbl = Instance.new("TextLabel")
            Vbl.Size = UDim2.new(0, 80, 0, 25)
            Vbl.Position = UDim2.new(1, -90, 0, 2)
            Vbl.Text = tostring(default)
            Vbl.TextColor3 = Color3.fromRGB(150, 200, 255)
            Vbl.Font = Enum.Font.SourceSansBold
            Vbl.TextSize = 14
            Vbl.TextXAlignment = Enum.TextXAlignment.Right
            Vbl.BackgroundTransparency = 1
            Vbl.Parent = Frame

            local Bar = Instance.new("TextButton")
            Bar.Size = UDim2.new(1, -20, 0, 8)
            Bar.Position = UDim2.new(0, 10, 1, -15)
            Bar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            Bar.Text = ""
            Bar.Parent = Frame
            Instance.new("UICorner", Bar).CornerRadius = UDim.new(0, 4)

            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            Fill.BackgroundColor3 = Color3.fromRGB(65, 140, 240)
            Fill.BorderSizePixel = 0
            Fill.Parent = Bar
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 4)

            local sliding = false
            local function updateSlider(input)
                local pct = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                Fill.Size = UDim2.new(pct, 0, 1, 0)
                local val = math.floor(min + (max - min) * pct)
                Vbl.Text = tostring(val)
                pcall(callback, val)
            end

            Bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = true updateSlider(i) end end)
            UserInputService.InputChanged:Connect(function(i) if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then updateSlider(i) end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = false end end)
        end

        function Elements:AddTextBox(placeholder, callback)
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, -6, 0, 40)
            Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            Frame.Parent = Container
            Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

            local Box = Instance.new("TextBox")
            Box.Size = UDim2.new(1, -20, 1, 0)
            Box.Position = UDim2.new(0, 10, 0, 0)
            Box.PlaceholderText = placeholder
            Box.Text = ""
            Box.TextColor3 = Color3.fromRGB(255, 255, 255)
            Box.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
            Box.TextSize = 14
            Box.Font = Enum.Font.SourceSans
            Box.TextXAlignment = Enum.TextXAlignment.Left
            Box.BackgroundTransparency = 1
            Box.Parent = Frame

            Box.FocusLost:Connect(function(enter)
                if enter and Box.Text ~= "" then
                    pcall(callback, Box.Text)
                    Box.Text = ""
                end
            end)
        end

        function Elements:AddButton(name, callback)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, -6, 0, 35)
            Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            Btn.Text = name
            Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            Btn.TextSize = 14
            Btn.Font = Enum.Font.SourceSansBold
            Btn.Parent = Container
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
            Btn.MouseButton1Click:Connect(function() pcall(callback) end)
            return Btn
        end

        function Elements:AddDropdown(name, list, callback)
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, -6, 0, 40)
            Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            Frame.ClipsDescendants = true
            Frame.Parent = Container
            Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 0, 40)
            Btn.BackgroundTransparency = 1
            Btn.Text = name .. " : Выберите"
            Btn.TextColor3 = Color3.fromRGB(220, 220, 220)
            Btn.TextSize = 14
            Btn.Font = Enum.Font.SourceSans
            Btn.Parent = Frame

            local DropContainer = Instance.new("Frame")
            DropContainer.Size = UDim2.new(1, 0, 0, #list * 30)
            DropContainer.Position = UDim2.new(0, 0, 0, 40)
            DropContainer.BackgroundTransparency = 1
            DropContainer.Parent = Frame

            local DropLayout = Instance.new("UIListLayout")
            DropLayout.Parent = DropContainer

            local opened = false
            Btn.MouseButton1Click:Connect(function()
                opened = not opened
                Frame.Size = opened and UDim2.new(1, -6, 0, 40 + (#list * 30)) or UDim2.new(1, -6, 0, 40)
            end)

            local dropMethods = {}
            dropMethods.Refresh = function(self, newList)
                for _, c in ipairs(DropContainer:GetChildren()) do 
                    if c:IsA("TextButton") then c:Destroy() end 
                end
                for _, item in ipairs(newList) do
                    local ItemBtn = Instance.new("TextButton")
                    ItemBtn.Size = UDim2.new(1, 0, 0, 30)
                    ItemBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                    ItemBtn.Text = tostring(item)
                    ItemBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
                    ItemBtn.Font = Enum.Font.SourceSans
                    ItemBtn.TextSize = 13
                    ItemBtn.Parent = DropContainer

                    ItemBtn.MouseButton1Click:Connect(function()
                        Btn.Text = name .. " : " .. tostring(item)
                        opened = false
                        Frame.Size = UDim2.new(1, -6, 0, 40)
                        pcall(callback, item)
                    end)
                end
                if opened then Frame.Size = UDim2.new(1, -6, 0, 40 + (#newList * 30)) end
            end
            
            dropMethods:Refresh(list)
            return dropMethods
        end

        return Elements
    end
end

--==============================================================================
-- СЕРВИСНЫЕ ФУНКЦИИ И ПОИСК КНОПОК
--==============================================================================
local function findButtonByText(textToFind)
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return nil end
  
    for _, object in ipairs(playerGui:GetDescendants()) do
        if object:IsA("TextButton") then
            if string.find(string.lower(object.Text), string.lower(textToFind)) then
                if object.Visible and (object.AbsoluteSize.X > 0) then
                    return object
                end
            end
        end
    end
    return nil
end

local function clickGuiButton(button)
    if button then
        if firesignal then
            firesignal(button.MouseButton1Click)
            firesignal(button.MouseButton1Down)
            firesignal(button.MouseButton1Up)
        else
            button:Activated()
        end
        return true
    end
    return false
end

-- Логика безопасного переключения скорости через RemoteEvent
local changeSpeed = ReplicatedStorage:WaitForChild("Game", 5) and ReplicatedStorage.Game:WaitForChild("Speed", 5) and ReplicatedStorage.Game.Speed:WaitForChild("Change", 5)

local function triggerServerSpeed(speedValue)
    if changeSpeed and changeSpeed:IsA("RemoteEvent") then
        changeSpeed:FireServer(speedValue)
    end
end

-- Авто-восстановление скорости после завершения раунда / реплея
task.spawn(function()
    while task.wait(1) do
        if Flags.AutoSpeedUp then
            local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
            local gameEnded = playerGui and playerGui:FindFirstChild("GameEnded")
            if gameEnded then
                -- Ждем пока панель конца игры закроется (означает рестарт матча)
                gameEnded:GetPropertyChangedSignal("Visible"):Wait()
                if not gameEnded.Visible and Flags.AutoSpeedUp then
                    task.wait(1.5) -- Небольшая задержка для загрузки карты
                    triggerServerSpeed(5) -- Ставим х5 из второго скрипта
                end
            end
        end
    end
end)

--==============================================================================
-- СТАБИЛЬНЫЙ МЕХАНИЗМ ЗАПИСИ И ХРАНЕНИЯ МАКРОСОВ (ПАКЕТНЫЙ МЕТОД)
--==============================================================================
RunService.Heartbeat:Connect(function()
    if not IsRecording or not LocalPlayer.Character then return end
    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    
    if root and hum then
        table.insert(CurrentRecord, {
            Time = tick() - RecordStartTime,
            CFrame = root.CFrame,
            Jump = (hum.FloorMaterial == Enum.CellMaterial.Empty)
        })
    end
end)

local function playMacro(macroData)
    IsPlaying = true
    local startPlayTime = tick()
    local index = 1

    while IsPlaying and index <= #macroData do
        local elapsed = tick() - startPlayTime
        local frameData = macroData[index]

        if elapsed >= frameData.Time then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = frameData.CFrame
                if frameData.Jump then
                    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum.Jump = true end
                end
            end
            index = index + 1
        end
        RunService.Heartbeat:Wait()
    end
    IsPlaying = false
end

--==============================================================================
-- СБОРКА ИНТЕРФЕЙСА (ВСЕ ФУНКЦИИ НА ОДНОМ ЭКРАНЕ)
--==============================================================================
local UI = KavoLibrary:CreateMenu("SquadRimStudia | Skibi Defense")

-- 1. Традиционные автоматизации
UI:AddToggle("Включить Auto Play", Flags.AutoPlay, function(Value)
    Flags.AutoPlay = Value
    saveSettings()
    if Value then
        while Flags.AutoPlay do
            local replayBtn = findButtonByText("Replay")
            if replayBtn then clickGuiButton(replayBtn) task.wait(2) end

            local plusBtn = findButtonByText("+")
            if plusBtn then clickGuiButton(plusBtn) task.wait(1.5) end
