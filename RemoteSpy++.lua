if getgenv().SoroniceV1SpyLoaded then
    if game.CoreGui:FindFirstChild("cenirosoRemoteSpy") then
        game.CoreGui.cenirosoRemoteSpy:Destroy()
    end
end
getgenv().SoroniceV1SpyLoaded = true

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

_G.RawCode = ""

local RemoteQueue = {}
local IsSlowMode = false
local MAX_QUEUE_SIZE = 150

local Blacklist = {
    ["Look"] = true,
    ["MaterialOrColorChange"] = true,
    ["SlotTime"] = true,
    ["1Cloc1k"] = true
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "cenirosoRemoteSpy"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- ==========================================
-- ЭКРАН ЗАГРУЗКИ
-- ==========================================
local LoadingLabel = Instance.new("TextLabel")
LoadingLabel.Size = UDim2.new(0, 300, 0, 50)
LoadingLabel.Position = UDim2.new(0.5, -150, 0.5, -25)
LoadingLabel.BackgroundTransparency = 1
LoadingLabel.Font = Enum.Font.GothamBold
LoadingLabel.Text = "Инициализация..."
LoadingLabel.TextColor3 = Color3.fromRGB(138, 43, 226)
LoadingLabel.TextSize = 18
LoadingLabel.Parent = ScreenGui

task.wait(0.6)
TweenService:Create(LoadingLabel, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
task.wait(0.3)
LoadingLabel:Destroy()

-- ==========================================
-- ОСНОВНОЙ ИНТЕРФЕЙС
-- ==========================================
local MainFrame = Instance.new("CanvasGroup")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 19, 23)
MainFrame.BorderSizePixel = 0
MainFrame.Size = UDim2.new(0, 560, 0, 360)
MainFrame.Active = true
MainFrame.GroupTransparency = 1

MainFrame.Position = UDim2.new(0.5, -275, 1, 50)
local targetPosition = UDim2.new(0.5, -275, 0.5, -175)

TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = targetPosition}):Play()
TweenService:Create(MainFrame, TweenInfo.new(0.5), {GroupTransparency = 0}):Play()

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(12, 13, 16)
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(1, 0, 0, 35)

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 10)
TopBarCorner.Parent = TopBar

local TopBarHider = Instance.new("Frame")
TopBarHider.Parent = TopBar
TopBarHider.BackgroundColor3 = Color3.fromRGB(12, 13, 16)
TopBarHider.BorderSizePixel = 0
TopBarHider.Position = UDim2.new(0, 0, 1, -5)
TopBarHider.Size = UDim2.new(1, 0, 0, 5)

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Size = UDim2.new(0.5, 0, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "REMOTE SPY ++"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = TopBar
CloseButton.BackgroundTransparency = 1
CloseButton.Position = UDim2.new(1, -35, 0, 0)
CloseButton.Size = UDim2.new(0, 35, 1, 0)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(150, 150, 150)
CloseButton.TextSize = 13

CloseButton.MouseEnter:Connect(function()
    TweenService:Create(CloseButton, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(219, 68, 85)}):Play()
end)
CloseButton.MouseLeave:Connect(function()
    TweenService:Create(CloseButton, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
end)

local RemotesList = Instance.new("ScrollingFrame")
RemotesList.Name = "RemotesList"
RemotesList.Parent = MainFrame
RemotesList.Active = true
RemotesList.BackgroundColor3 = Color3.fromRGB(12, 13, 16)
RemotesList.BorderSizePixel = 0
RemotesList.Position = UDim2.new(0, 12, 0, 48)
RemotesList.Size = UDim2.new(0, 190, 1, -100)
RemotesList.CanvasSize = UDim2.new(0, 0, 0, 0)
RemotesList.ScrollBarThickness = 3
RemotesList.ScrollBarImageColor3 = Color3.fromRGB(138, 43, 226)

local ListCorner = Instance.new("UICorner")
ListCorner.CornerRadius = UDim.new(0, 8)
ListCorner.Parent = RemotesList

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = RemotesList
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 4)

local CodeDisplay = Instance.new("TextLabel")
CodeDisplay.Name = "CodeDisplay"
CodeDisplay.Parent = MainFrame
CodeDisplay.BackgroundColor3 = Color3.fromRGB(12, 13, 16)
CodeDisplay.BorderSizePixel = 0
CodeDisplay.Position = UDim2.new(0, 214, 0, 48)
CodeDisplay.Size = UDim2.new(1, -226, 1, -100)
CodeDisplay.Font = Enum.Font.Code
CodeDisplay.Text = "<font color=\"#5C6370\">-- Ожидание ремоутов...\n-- Перехваченный код появится здесь.</font>"
CodeDisplay.TextColor3 = Color3.fromRGB(230, 230, 230)
CodeDisplay.TextSize = 13
CodeDisplay.TextXAlignment = Enum.TextXAlignment.Left
CodeDisplay.TextYAlignment = Enum.TextYAlignment.Top
CodeDisplay.RichText = true
CodeDisplay.TextWrapped = true

local CodeCorner = Instance.new("UICorner")
CodeCorner.CornerRadius = UDim.new(0, 8)
CodeCorner.Parent = CodeDisplay

local UIPadding = Instance.new("UIPadding")
UIPadding.Parent = CodeDisplay
UIPadding.PaddingTop = UDim.new(0, 12)
UIPadding.PaddingLeft = UDim.new(0, 12)

local ControlPanel = Instance.new("Frame")
ControlPanel.Parent = MainFrame
ControlPanel.BackgroundTransparency = 1
ControlPanel.Position = UDim2.new(0, 12, 1, -42)
ControlPanel.Size = UDim2.new(1, -24, 0, 32)

local UIListHorizontal = Instance.new("UIListLayout")
UIListHorizontal.Parent = ControlPanel
UIListHorizontal.FillDirection = Enum.FillDirection.Horizontal
UIListHorizontal.SortOrder = Enum.SortOrder.LayoutOrder
UIListHorizontal.Padding = UDim.new(0, 10)

local function createStyledButton(name, text, bg, parent)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Parent = parent
    btn.BackgroundColor3 = bg
    btn.BorderSizePixel = 0
    btn.Size = UDim2.new(0, 172, 1, 0)
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = bg:Lerp(Color3.fromRGB(255, 255, 255), 0.15)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = bg}):Play()
    end)
    
    return btn
end

local CopyButton = createStyledButton("CopyButton", "Копировать", Color3.fromRGB(138, 43, 226), ControlPanel)
local SlowButton = createStyledButton("SlowButton", "Замедление: ВЫКЛ", Color3.fromRGB(35, 38, 47), ControlPanel)
local ClearButton = createStyledButton("ClearButton", "Очистить лог", Color3.fromRGB(219, 68, 85), ControlPanel)

-- ==========================================
-- ИСПРАВЛЕННЫЙ ПЛАВНЫЙ И НАДЕЖНЫЙ DRAG
-- ==========================================
local dragging = false
local dragStart = Vector3.new()
local startPos = UDim2.new()
local targetDragPos = UDim2.new()

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        targetDragPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        targetDragPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Супер-плавное следование за курсором через Lerp в цикле рендера
RunService.RenderStepped:Connect(function()
    if MainFrame and MainFrame.Parent then
        -- Чем меньше коэффициент (например, 0.08), тем медленнее и плавнее двигается интерфейс
        MainFrame.Position = MainFrame.Position:Lerp(targetDragPos, 0.08)
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    local closeTween = TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0.5, -275, 1, 50)})
    TweenService:Create(MainFrame, TweenInfo.new(0.3), {GroupTransparency = 1}):Play()
    closeTween:Play()
    closeTween.Completed:Connect(function()
        ScreenGui:Destroy()
    end)
end)

-- ==========================================
-- СИНТАКСИС И ФОРМАТИРОВАНИЕ
-- ==========================================
local function ApplySyntaxHighlighting(codeString)
    local highlighted = codeString:gsub("<", "&lt;"):gsub(">", "&gt;")
    highlighted = highlighted:gsub('("[^"]*")', '<font color="#E5C07B">%1</font>')
    highlighted = highlighted:gsub("([%s%[,=])(%d+%.?%d*)([%s%],;])", "%1<font color=\"#D19A66\">%2</font>%3")
    highlighted = highlighted:gsub("^(%d+%.?%d*)([%s%],;])", "<font color=\"#D19A66\">%1</font>%2")
    highlighted = highlighted:gsub("(FireServer)", '<font color="#61AFEF">%1</font>')
    highlighted = highlighted:gsub("(InvokeServer)", '<font color="#61AFEF">%1</font>')

    local keywords = {
        "local", "function", "return", "if", "then", "else", "elseif", 
        "end", "for", "while", "do", "in", "and", "or", "not", 
        "true", "false", "nil", "unpack"
    }

    for _, kw in pairs(keywords) do
        highlighted = highlighted:gsub("([^%a_])("..kw..")([^%a_])", "%1<font color=\"#C678DD\">%2</font>%3")
        highlighted = highlighted:gsub("^("..kw..")([^%a_])", "<font color=\"#C678DD\">%1</font>%2")
        highlighted = highlighted:gsub("([^%a_])("..kw..")$", "%1<font color=\"#C678DD\">%2</font>")
    end

    return highlighted
end

local function getPathToInstance(instance)
    local path = {}
    local current = instance
    while current and current ~= game do
        local name = current.Name
        if name:sub(1, 4) == "Game" then
            name = "game" .. name:sub(5)
        end
        table.insert(path, 1, name)
        current = current.Parent
    end
    return table.concat(path, ".")
end

local function formatValue(value)
    if typeof(value) == "string" then
        return string.format("%q", value)
    elseif typeof(value) == "number" then
        return tostring(value)
    elseif typeof(value) == "boolean" then
        return value and "true" or "false"
    elseif typeof(value) == "Instance" then
        return getPathToInstance(value)
    elseif typeof(value) == "Vector3" then
        return string.format("Vector3.new(%f, %f, %f)", value.X, value.Y, value.Z)
    elseif typeof(value) == "CFrame" then
        return string.format("CFrame.new(%f, %f, %f)", value.X, value.Y, value.Z)
    else
        return string.format("%q", tostring(value))
    end
end

local function Format(args)
    local formattedArgs = {}
    for i, arg in ipairs(args) do
        formattedArgs[i] = string.format("[%d] = %s", i, formatValue(arg))
    end
    return formattedArgs
end

local function CreateRemoteButton(remoteName, generatedCode)
    local RemoteBtn = Instance.new("TextButton")
    RemoteBtn.Name = remoteName
    RemoteBtn.Parent = RemotesList
    RemoteBtn.BackgroundColor3 = Color3.fromRGB(24, 26, 32)
    RemoteBtn.BorderSizePixel = 0
    RemoteBtn.Size = UDim2.new(1, -8, 0, 28)
    RemoteBtn.Position = UDim2.new(0, 4, 0, 0)
    RemoteBtn.Font = Enum.Font.Gotham
    RemoteBtn.Text = "  " .. remoteName
    RemoteBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    RemoteBtn.TextSize = 12
    RemoteBtn.TextXAlignment = Enum.TextXAlignment.Left

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 5)
    BtnCorner.Parent = RemoteBtn

    RemotesList.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)

    RemoteBtn.MouseButton1Click:Connect(function()
        _G.RawCode = generatedCode 
        local coloredCode = ApplySyntaxHighlighting(generatedCode)
        CodeDisplay.Text = coloredCode
    end)
end

-- ==========================================
-- ЛОГИКА ПЕРЕХВАТА И СЛУЖЕБНЫЕ ЦИКЛЫ
-- ==========================================
task.spawn(function()
    while true do
        if #RemoteQueue > 0 then
            if IsSlowMode then
                local eventData = table.remove(RemoteQueue, 1)
                CreateRemoteButton(eventData.Name, eventData.Code)
                task.wait(4)
            else
                for i = 1, #RemoteQueue do
                    local eventData = table.remove(RemoteQueue, 1)
                    CreateRemoteButton(eventData.Name, eventData.Code)
                end
                task.wait(0.1)
            end
        else
            task.wait(0.1)
        end
    end
end)

local function handleRemote(remote)
    if Blacklist[remote.Name] then return end

    local path = {}
    local current = remote
    while current and current.Parent ~= game do
        local name = current.Name
        if name:sub(1, 4) == "Game" then
            name = "game" .. name:sub(5)
        end
        table.insert(path, 1, name)
        current = current.Parent
    end
    local fullPath = table.concat(path, ".")

    if remote:IsA("RemoteEvent") then
        remote.OnClientEvent:Connect(function(...)
            local args = {...}
            local argsFormatted = Format(args)
            local argsString = table.concat(argsFormatted, ",\n    ")
            local code = string.format("local args = {\n    %s\n}\n\n%s:FireServer(unpack(args))", argsString, fullPath)
            
            if #RemoteQueue < MAX_QUEUE_SIZE then
                table.insert(RemoteQueue, {Name = remote.Name, Code = code})
            end
        end)
    elseif remote:IsA("RemoteFunction") then
        remote.OnClientInvoke = function(...)
            local args = {...}
            local argsFormatted = Format(args)
            local argsString = table.concat(argsFormatted, ",\n    ")
            local code = string.format("local args = {\n    %s\n}\n\nlocal response = %s:InvokeServer(unpack(args))", argsString, fullPath)
            
            if #RemoteQueue < MAX_QUEUE_SIZE then
                table.insert(RemoteQueue, {Name = remote.Name, Code = code})
            end
            return ...
        end
    end
end

local function wrapRemotes(folder)
    for _, obj in ipairs(folder:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            handleRemote(obj)
        end
    end
    folder.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("RemoteEvent") or descendant:IsA("RemoteFunction") then
            handleRemote(descendant)
        end
    end)
end

local folders = {
    game:GetService("ReplicatedStorage"),
    game:GetService("StarterGui"),
    game:GetService("StarterPack"),
    game:GetService("StarterPlayer")
}

for _, folder in ipairs(folders) do
    wrapRemotes(folder)
end

CopyButton.MouseButton1Click:Connect(function()
    if setclipboard and _G.RawCode ~= "" then
        setclipboard(_G.RawCode)
        CopyButton.Text = "Скопировано!"
        task.wait(1)
        CopyButton.Text = "Копировать"
    end
end)

SlowButton.MouseButton1Click:Connect(function()
    IsSlowMode = not IsSlowMode
    if IsSlowMode then
        SlowButton.Text = "Замедление: ВКЛ"
        SlowButton.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    else
        SlowButton.Text = "Замедление: ВЫКЛ"
        SlowButton.BackgroundColor3 = Color3.fromRGB(35, 38, 47)
    end
end)

ClearButton.MouseButton1Click:Connect(function()
    RemoteQueue = {}
    for _, child in pairs(RemotesList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    RemotesList.CanvasSize = UDim2.new(0, 0, 0, 0)
    CodeDisplay.Text = "<font color=\"#5C6370\">-- Ожидание ремоутов...\n-- Перехваченный код появится здесь.</font>"
    _G.RawCode = ""
end)
