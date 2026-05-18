--==============================================================================
-- SquadRimStudia | Skibi Defense Utility
-- Версия с исправленным поиском кнопок "Click to Start" и стабильными кликами
--==============================================================================

local ConfigFile = "SquadRimConfig.json"
local HttpService = game:GetService("HttpService")

local Flags = {
    AutoPlay = false,
    AutoSkip = false,
    AutoMaxUnits = false,
    AutoSpeedUp = false,
    TargetSpeed = 16,
    AntiAFK = true
}

local function saveSettings()
    local success, encoded = pcall(function()
        return HttpService:JSONEncode(Flags)
    end)
    if success and writefile then
        writefile(ConfigFile, encoded)
    end
end

local function loadSettings()
    if readfile and isfile and isfile(ConfigFile) then
        local success, decoded = pcall(function()
            return HttpService:JSONDecode(readfile(ConfigFile))
        end)
        if success and type(decoded) == "table" then
            for k, v in pairs(decoded) do
                Flags[k] = v
            end
        end
    end
end

loadSettings()

-- ВСТРОЕННАЯ БИБЛИОТЕКА ИНТЕРФЕЙСА (KAVO)
local KavoLibrary = {}
do
    local CoreGui = game:GetService("CoreGui")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    function KavoLibrary:CreateMenu(title)
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "SquadRimStudia_GUI"
        ScreenGui.ResetOnSpawn = false
        
        if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end
        ScreenGui.Parent = CoreGui

        local MainFrame = Instance.new("Frame")
        MainFrame.Name = "MainFrame"
        MainFrame.Size = UDim2.new(0, 450, 0, 350)
        MainFrame.Position = UDim2.new(0.5, -225, 0.5, -175)
        MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        MainFrame.BorderSizePixel = 0
        MainFrame.Active = true
        MainFrame.Draggable = true
        MainFrame.Parent = ScreenGui

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = MainFrame

        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Size = UDim2.new(1, -40, 0, 35)
        TitleLabel.Position = UDim2.new(0, 15, 0, 0)
        TitleLabel.Text = title
        TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TitleLabel.TextSize = 18
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
        CloseBtn.MouseButton1Click:Connect(function()
            ScreenGui:Destroy()
        end)

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

        local UserInputService = game:GetService("UserInputService")
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and (input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.G) then
                MainFrame.Visible = not MainFrame.Visible
            end
        end)

        local Elements = {}

        function Elements:AddToggle(name, startValue, callback)
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(1, -6, 0, 40)
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.Parent = Container
            Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 6)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -60, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.Text = name
            Label.TextColor3 = Color3.fromRGB(230, 230, 230)
            Label.TextSize = 15
            Label.Font = Enum.Font.SourceSans
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1
            Label.Parent = ToggleFrame

            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(0, 45, 0, 24)
            Button.Position = UDim2.new(1, -55, 0.5, -12)
            
            local enabled = startValue
            if enabled then
                Button.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
                Button.Text = "ВКЛ"
            else
                Button.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
                Button.Text = "ВЫКЛ"
            end
            
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
            Button.TextSize = 12
            Button.Font = Enum.Font.SourceSansBold
            Button.Parent = ToggleFrame
            Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 4)

            Button.MouseButton1Click:Connect(function()
                enabled = not enabled
                if enabled then
                    Button.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
                    Button.Text = "ВКЛ"
                else
                    Button.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
                    Button.Text = "ВЫКЛ"
                end
                pcall(callback, enabled)
            end)
            
            if enabled then
                task.spawn(pcall, callback, true)
            end
        end

        function Elements:AddSlider(name, min, max, default, callback)
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(1, -6, 0, 50)
            SliderFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            SliderFrame.BorderSizePixel = 0
            SliderFrame.Parent = Container
            Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 6)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -100, 0, 25)
            Label.Position = UDim2.new(0, 10, 0, 2)
            Label.Text = name
            Label.TextColor3 = Color3.fromRGB(230, 230, 230)
            Label.TextSize = 14
            Label.Font = Enum.Font.SourceSans
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1
            Label.Parent = SliderFrame

            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Size = UDim2.new(0, 80, 0, 25)
            ValueLabel.Position = UDim2.new(1, -90, 0, 2)
            ValueLabel.Text = tostring(default)
            ValueLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
            ValueLabel.TextSize = 14
            ValueLabel.Font = Enum.Font.SourceSansBold
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Parent = SliderFrame

            local SlideBar = Instance.new("TextButton")
            SlideBar.Size = UDim2.new(1, -20, 0, 8)
            SlideBar.Position = UDim2.new(0, 10, 1, -15)
            SlideBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            SlideBar.Text = ""
            SlideBar.Parent = SliderFrame
            Instance.new("UICorner", SlideBar).CornerRadius = UDim.new(0, 4)

            local SlideFill = Instance.new("Frame")
            SlideFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            SlideFill.BackgroundColor3 = Color3.fromRGB(65, 140, 240)
            SlideFill.BorderSizePixel = 0
            SlideFill.Parent = SlideBar
            Instance.new("UICorner", SlideFill).CornerRadius = UDim.new(0, 4)

            local isSliding = false

            local function updateSlider(input)
                local currentX = input.Position.X
                local barAbsoluteX = SlideBar.AbsolutePosition.X
                local barAbsoluteSizeX = SlideBar.AbsoluteSize.X
                local percentage = math.clamp((currentX - barAbsoluteX) / barAbsoluteSizeX, 0, 1)
                SlideFill.Size = UDim2.new(percentage, 0, 1, 0)
                
                local value = math.floor(min + (max - min) * percentage)
                ValueLabel.Text = tostring(value)
                pcall(callback, value)
            end

            SlideBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isSliding = true
                    updateSlider(input)
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isSliding = false
                end
            end)
        end

        return Elements
    end
end

--==============================================================================
-- ИНИЦИАЛИЗАЦИЯ ИНТЕРФЕЙСА И ФУНКЦИЙ С КЛИКАМИ
--==============================================================================
local Menu = KavoLibrary:CreateMenu("SquadRimStudia | Skibi Defense")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Исправленный поиск: ищет вхождение подстроки (более надежно для "Click to Start")
local function findButtonByText(textToFind)
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return nil end
    
    for _, object in ipairs(playerGui:GetDescendants()) do
        if object:IsA("TextButton") then
            -- Проверяем, содержит ли текст кнопки искомую фразу
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

-- ДОБАВЛЕНИЕ ЭЛЕМЕНТОВ УПРАВЛЕНИЯ

-- 1. Переключатель Auto Play (С исправленным алгоритмом)
Menu:AddToggle("Включить Auto Play", Flags.AutoPlay, function(Value)
    Flags.AutoPlay = Value
    saveSettings()
    if Value then
        while Flags.AutoPlay do
            -- Проверка кнопки Replay
            local replayBtn = findButtonByText("Replay")
            if replayBtn then
                clickGuiButton(replayBtn)
                task.wait(2)
            end

            -- Нажатие на плюсик "+"
            local plusBtn = findButtonByText("+")
            if plusBtn then
                clickGuiButton(plusBtn)
                task.wait(1.5) -- Чуть увеличили паузу, чтобы игра успела среагировать
            end
            
            -- Поиск и нажатие "Click to Start"
            local clickToStartBtn = findButtonByText("Click to Start")
            if clickToStartBtn then
                clickGuiButton(clickToStartBtn)
                task.wait(17) -- Ожидание загрузки уровня
                
                -- Повторное нажатие после загрузки
                local clickToStartBtn2 = findButtonByText("Click to Start")
                if clickToStartBtn2 then
                    clickGuiButton(clickToStartBtn2)
                    task.wait(1.5)
                end
            end
            
            -- Нажатие кнопки подтверждения "Yes"
            local yesBtn = findButtonByText("Yes")
            if yesBtn then
                clickGuiButton(yesBtn)
                task.wait(2)
            end
            task.wait(1)
        end
    end
end)

-- 2. Переключатель Auto Speed-Up (4x)
Menu:AddToggle("Auto Speed-Up (4x)", Flags.AutoSpeedUp, function(Value)
    Flags.AutoSpeedUp = Value
    saveSettings()
    if Value then
        while Flags.AutoSpeedUp do
            local speedBtn = findButtonByText("1x")
            if speedBtn then
                for i = 1, 4 do
                    if not Flags.AutoSpeedUp then break end
                    clickGuiButton(speedBtn)
                    task.wait(0.2)
                end
            end
            task.wait(1)
        end
    end
end)

-- 3. Переключатель Auto Skip Waves
Menu:AddToggle("Auto Skip Waves", Flags.AutoSkip, function(Value)
    Flags.AutoSkip = Value
    saveSettings()
    if Value then
        while Flags.AutoSkip do
            local skipBtn = findButtonByText("Auto Skip Wave") or findButtonByText("Skip Wave")
            if skipBtn then
                clickGuiButton(skipBtn)
            end
            task.wait(1)
        end
    end
end)

-- 4. Переключатель Auto Max Units
Menu:AddToggle("Auto Max Units", Flags.AutoMaxUnits, function(Value)
    Flags.AutoMaxUnits = Value
    saveSettings()
    if Value then
        while Flags.AutoMaxUnits do
            local maxUnitsBtn = findButtonByText("Auto Max Units")
            if maxUnitsBtn then
                clickGuiButton(maxUnitsBtn)
            end
            task.wait(1)
        end
    end
end)

-- 5. Переключатель Улучшенного Anti-AFK (Рандомные шаги раз в 3 минуты)
Menu:AddToggle("Включить Anti-AFK", Flags.AntiAFK, function(Value)
    Flags.AntiAFK = Value
    saveSettings()
    if Value then
        local VirtualUser = game:GetService("VirtualUser")
        
        task.spawn(function()
            while Flags.AntiAFK do
                if LocalPlayer and LocalPlayer:FindFirstChild("Idled") then
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new(0, 0))
                end
                task.wait(15)
            end
        end)
        
        task.spawn(function()
            while Flags.AntiAFK do
                task.wait(180)
                if not Flags.AntiAFK then break end
                
                if LocalPlayer and LocalPlayer.Character then
                    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        local randomX = math.random(-10, 10)
                        local randomZ = math.random(-10, 10)
                        humanoid:MoveTo(LocalPlayer.Character.PrimaryPart.Position + Vector3.new(randomX, 0, randomZ))
                    end
                end
            end
        end)
    end
end)

-- 6. Слайдер Скорости (WalkSpeed)
Menu:AddSlider("WalkSpeed персонажа", 16, 120, Flags.TargetSpeed, function(Value)
    Flags.TargetSpeed = Value
    saveSettings()
end)

-- Цикл удержания WalkSpeed персонажа
game:GetService("RunService").Heartbeat:Connect(function()
    if LocalPlayer and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.WalkSpeed ~= Flags.TargetSpeed then
            humanoid.WalkSpeed = Flags.TargetSpeed
        end
    end
end)

-- Независимый перехватчик события Idled
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    if Flags.AntiAFK then
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(0.5)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end
end)
