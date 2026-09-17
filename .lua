-- Galaxy's Optimisation
-- Place this in StarterPlayer > StarterPlayerScripts as a LocalScript

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("GalaxyOptimisationGui")
if oldGui then
    oldGui:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "GalaxyOptimisationGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 100
gui.Enabled = true
gui.Parent = playerGui

local settings = {
    MaxFPS = 60,
    RenderDistance = 200,
    ShadowQuality = 0,
    ParticleScale = 0.4,
    DecalQuality = 1,
    Brightness = 1,
    SoundVolume = 0.6,
    CleanupDelay = 30,
    AutoCleanup = true,
}

local defaults = {}
for key, value in pairs(settings) do
    defaults[key] = value
end

local presets = {
    Balanced = {
        MaxFPS = 60,
        RenderDistance = 200,
        ShadowQuality = 0,
        ParticleScale = 0.4,
        DecalQuality = 1,
        Brightness = 1,
        SoundVolume = 0.6,
        CleanupDelay = 30,
    },

    LowMemory = {
        MaxFPS = 45,
        RenderDistance = 130,
        ShadowQuality = 0,
        ParticleScale = 0.25,
        DecalQuality = 0,
        Brightness = 0.8,
        SoundVolume = 0.35,
        CleanupDelay = 20,
    },

    Extreme = {
        MaxFPS = 30,
        RenderDistance = 80,
        ShadowQuality = 0,
        ParticleScale = 0.1,
        DecalQuality = 0,
        Brightness = 0.6,
        SoundVolume = 0.2,
        CleanupDelay = 12,
    },
}

local function clamp(value, minimum, maximum)
    return math.max(minimum, math.min(value, maximum))
end

local function formatValue(key, value)
    if key == "RenderDistance" then
        return math.floor(value) .. " studs"
    elseif key == "CleanupDelay" then
        return math.floor(value) .. "s"
    elseif key == "ParticleScale"
        or key == "Brightness"
        or key == "SoundVolume" then
        return string.format("%.2f", value)
    end

    return tostring(math.floor(value))
end

local function addCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
end

local function applySettings()
    Lighting.Brightness = settings.Brightness
    Lighting.GlobalShadows = settings.ShadowQuality > 0
    Lighting.Ambient = Color3.fromRGB(100, 100, 100)
    Lighting.OutdoorAmbient = Color3.fromRGB(130, 130, 130)

    pcall(function()
        Workspace.StreamingTargetRadius = settings.RenderDistance
        Workspace.StreamingMinRadius = math.max(
            10,
            math.floor(settings.RenderDistance * 0.35)
        )
    end)

    local camera = Workspace.CurrentCamera
    if camera then
        camera.FieldOfView = clamp(
            80 - (settings.MaxFPS - 30) * 0.2,
            50,
            90
        )
    end

    for _, object in ipairs(Workspace:GetDescendants()) do
        if object:IsA("ParticleEmitter") then
            object.Enabled = settings.ParticleScale > 0.08
        elseif object:IsA("Trail") then
            object.Enabled = settings.ParticleScale > 0.08
        elseif object:IsA("Decal") or object:IsA("Texture") then
            object.Transparency = settings.DecalQuality <= 0 and 1 or 0
        elseif object:IsA("Sound") then
            object.Volume = math.clamp(object.Volume, 0, settings.SoundVolume)
        end
    end
end

local function makeSlider(parent, labelText, key, minimum, maximum, step)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -12, 0, 58)
    holder.BackgroundColor3 = Color3.fromRGB(28, 31, 37)
    holder.BorderSizePixel = 0
    holder.Parent = parent
    addCorner(holder, 10)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.55, 0, 0, 24)
    label.Position = UDim2.fromOffset(10, 3)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(245, 245, 245)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = holder

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.4, -10, 0, 24)
    valueLabel.Position = UDim2.new(0.6, 0, 0, 3)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = Color3.fromRGB(110, 220, 140)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 12
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = holder

    local track = Instance.new("TextButton")
    track.Size = UDim2.new(1, -20, 0, 10)
    track.Position = UDim2.fromOffset(10, 38)
    track.BackgroundColor3 = Color3.fromRGB(55, 58, 65)
    track.BorderSizePixel = 0
    track.Text = ""
    track.AutoButtonColor = false
    track.Parent = holder
    addCorner(track, 5)

    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = Color3.fromRGB(70, 135, 255)
    fill.BorderSizePixel = 0
    fill.Parent = track
    addCorner(fill, 5)

    local dragging = false

    local function updateVisual()
        local percent = clamp(
            (settings[key] - minimum) / (maximum - minimum),
            0,
            1
        )

        fill.Size = UDim2.new(percent, 0, 1, 0)
        valueLabel.Text = formatValue(key, settings[key])
    end

    local function setValueFromX(screenX)
        local trackWidth = math.max(track.AbsoluteSize.X, 1)
        local ratio = clamp(
            (screenX - track.AbsolutePosition.X) / trackWidth,
            0,
            1
        )

        local rawValue = minimum + (maximum - minimum) * ratio
        local snappedValue = math.floor(rawValue / step + 0.5) * step

        settings[key] = clamp(snappedValue, minimum, maximum)
        updateVisual()
        applySettings()
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            setValueFromX(input.Position.X)
        end
    end)

    track.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then

            setValueFromX(input.Position.X)
        end
    end)

    updateVisual()
end

local panel = Instance.new("Frame")
panel.Name = "GalaxyOptimisationMenu"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.new(1, -20, 1, -20)
panel.BackgroundColor3 = Color3.fromRGB(18, 20, 25)
panel.BorderSizePixel = 0
panel.Visible = true
panel.Parent = gui
addCorner(panel, 18)

local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MaxSize = Vector2.new(390, 600)
sizeConstraint.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -24, 0, 36)
title.Position = UDim2.fromOffset(12, 12)
title.BackgroundTransparency = 1
title.Text = "Galaxy's Optimisation"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 23
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -24, 0, 20)
subtitle.Position = UDim2.fromOffset(12, 48)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Reduce memory and improve stability"
subtitle.TextColor3 = Color3.fromRGB(146, 154, 170)
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 12
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = panel

local presetBar = Instance.new("Frame")
presetBar.Size = UDim2.new(1, -20, 0, 46)
presetBar.Position = UDim2.fromOffset(10, 76)
presetBar.BackgroundColor3 = Color3.fromRGB(25, 28, 33)
presetBar.BorderSizePixel = 0
presetBar.Parent = panel
addCorner(presetBar, 10)

for index, presetName in ipairs({"Balanced", "LowMemory", "Extreme"}) do
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1 / 3, -8, 1, -8)
    button.Position = UDim2.new((index - 1) / 3, 4, 0, 4)
    button.BackgroundColor3 = Color3.fromRGB(70, 135, 255)
    button.BorderSizePixel = 0
    button.Text = presetName
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.Parent = presetBar
    addCorner(button, 8)

    button.Activated:Connect(function()
        for key, value in pairs(presets[presetName]) do
            settings[key] = value
        end

        applySettings()
    end)
end

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -18, 1, -178)
scroll.Position = UDim2.fromOffset(9, 132)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 5
scroll.CanvasSize = UDim2.fromOffset(0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 7)
layout.Parent = scroll

makeSlider(scroll, "FPS Target", "MaxFPS", 30, 144, 1)
makeSlider(scroll, "Render Distance", "RenderDistance", 50, 500, 10)
makeSlider(scroll, "Shadow Quality", "ShadowQuality", 0, 3, 1)
makeSlider(scroll, "Particle Scale", "ParticleScale", 0.05, 2, 0.05)
makeSlider(scroll, "Decal Quality", "DecalQuality", 0, 3, 1)
makeSlider(scroll, "Brightness", "Brightness", 0.3, 2, 0.1)
makeSlider(scroll, "Sound Volume", "SoundVolume", 0, 1, 0.05)
makeSlider(scroll, "Cleanup Delay", "CleanupDelay", 5, 120, 5)

local applyButton = Instance.new("TextButton")
applyButton.Size = UDim2.new(0.58, -4, 0, 38)
applyButton.Position = UDim2.new(0, 10, 1, -48)
applyButton.BackgroundColor3 = Color3.fromRGB(70, 135, 255)
applyButton.BorderSizePixel = 0
applyButton.Text = "Apply"
applyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
applyButton.Font = Enum.Font.GothamBold
applyButton.TextSize = 14
applyButton.Parent = panel
addCorner(applyButton, 9)

applyButton.Activated:Connect(function()
    applySettings()
end)

local resetButton = Instance.new("TextButton")
resetButton.Size = UDim2.new(0.42, -4, 0, 38)
resetButton.Position = UDim2.new(0.58, 4, 1, -48)
resetButton.BackgroundColor3 = Color3.fromRGB(75, 75, 80)
resetButton.BorderSizePixel = 0
resetButton.Text = "Reset"
resetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
resetButton.Font = Enum.Font.GothamBold
resetButton.TextSize = 14
resetButton.Parent = panel
addCorner(resetButton, 9)

resetButton.Activated:Connect(function()
    for key, value in pairs(defaults) do
        settings[key] = value
    end

    applySettings()
end)

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "GalaxyToggle"
toggleButton.Size = UDim2.fromOffset(88, 34)
toggleButton.Position = UDim2.new(1, -12, 0, 12)
toggleButton.AnchorPoint = Vector2.new(1, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(51, 182, 110)
toggleButton.BorderSizePixel = 0
toggleButton.Text = "OPT"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 15
toggleButton.Parent = gui
addCorner(toggleButton, 10)

toggleButton.Activated:Connect(function()
    panel.Visible = not panel.Visible
end)

applySettings()

print("Galaxy's Optimisation loaded. The menu is visible.")