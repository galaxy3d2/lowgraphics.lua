-- Galaxy's Optimisation
-- Place in StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GalaxyOptimisationGui"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 10
screenGui.Parent = playerGui

local settings = {
    MaxFPS = 60,
    RenderDistance = 200,
    ShadowQuality = 0,
    ParticleScale = 0.4,
    TextureQuality = 1,
    DecalQuality = 1,
    Brightness = 1,
    SoundVolume = 0.6,
    CleanupDelay = 30,
    AutoCleanup = true,
}

local defaults = {
    MaxFPS = 60,
    RenderDistance = 200,
    ShadowQuality = 0,
    ParticleScale = 0.4,
    TextureQuality = 1,
    DecalQuality = 1,
    Brightness = 1,
    SoundVolume = 0.6,
    CleanupDelay = 30,
    AutoCleanup = true,
}

local presets = {
    Balanced = {
        MaxFPS = 60,
        RenderDistance = 200,
        ShadowQuality = 0,
        ParticleScale = 0.4,
        TextureQuality = 1,
        DecalQuality = 1,
        Brightness = 1,
        SoundVolume = 0.6,
        CleanupDelay = 30,
        AutoCleanup = true,
    },
    LowMemory = {
        MaxFPS = 45,
        RenderDistance = 130,
        ShadowQuality = 0,
        ParticleScale = 0.25,
        TextureQuality = 0,
        DecalQuality = 0,
        Brightness = 0.8,
        SoundVolume = 0.35,
        CleanupDelay = 20,
        AutoCleanup = true,
    },
    Extreme = {
        MaxFPS = 30,
        RenderDistance = 80,
        ShadowQuality = 0,
        ParticleScale = 0.1,
        TextureQuality = 0,
        DecalQuality = 0,
        Brightness = 0.6,
        SoundVolume = 0.2,
        CleanupDelay = 12,
        AutoCleanup = true,
    },
}

local function clamp(value, minValue, maxValue)
    return math.max(minValue, math.min(value, maxValue))
end

local function formatValue(key, value)
    if key == "MaxFPS" then
        return tostring(math.floor(value))
    elseif key == "RenderDistance" then
        return tostring(math.floor(value)) .. " studs"
    elseif key == "ShadowQuality" then
        return tostring(math.floor(value))
    elseif key == "ParticleScale" then
        return string.format("%.2f", value)
    elseif key == "TextureQuality" then
        return tostring(math.floor(value))
    elseif key == "DecalQuality" then
        return tostring(math.floor(value))
    elseif key == "Brightness" then
        return string.format("%.2f", value)
    elseif key == "SoundVolume" then
        return string.format("%.2f", value)
    elseif key == "CleanupDelay" then
        return tostring(math.floor(value)) .. "s"
    end

    return tostring(value)
end

local applySettings

local function setPreset(name)
    local preset = presets[name]

    if not preset then
        return
    end

    for key, value in pairs(preset) do
        settings[key] = value
    end

    applySettings()
end

applySettings = function()
    Lighting.Brightness = settings.Brightness
    Lighting.GlobalShadows = settings.ShadowQuality > 0
    Lighting.OutdoorAmbient = Color3.fromRGB(130, 130, 130)
    Lighting.Ambient = Color3.fromRGB(100, 100, 100)

    if settings.TextureQuality <= 0 then
        Lighting.Quality = Enum.LightingQuality.Performance
    elseif settings.TextureQuality == 1 then
        Lighting.Quality = Enum.LightingQuality.Medium
    else
        Lighting.Quality = Enum.LightingQuality.High
    end

    Workspace.StreamingEnabled = true
    Workspace.StreamingTargetRadius = settings.RenderDistance
    Workspace.StreamingMinRadius = math.max(
        10,
        math.floor(settings.RenderDistance * 0.35)
    )

    local camera = Workspace.CurrentCamera

    if camera then
        camera.FieldOfView = clamp(
            80 - (settings.MaxFPS - 30) * 0.2,
            50,
            90
        )
    end

    for _, descendant in ipairs(playerGui:GetDescendants()) do
        if descendant:IsA("Sound") then
            descendant.Volume = math.clamp(
                descendant.Volume * settings.SoundVolume,
                0,
                10
            )
        end
    end

    for _, descendant in ipairs(Workspace:GetDescendants()) do
        if descendant:IsA("Sound") then
            descendant.Volume = math.clamp(
                descendant.Volume * settings.SoundVolume,
                0,
                10
            )
        end
    end

    for _, descendant in ipairs(Workspace:GetDescendants()) do
        if descendant:IsA("ParticleEmitter") then
            descendant.Enabled = settings.ParticleScale > 0.08
            descendant.Rate = math.max(
                0,
                descendant.Rate * settings.ParticleScale
            )
        elseif descendant:IsA("Trail") then
            descendant.Enabled = settings.ParticleScale > 0.08
        elseif descendant:IsA("Decal") then
            descendant.Transparency = settings.DecalQuality <= 0 and 1 or 0
        end
    end
end

local function aggressiveCleanup()
    local removedParticles = 0
    local removedTrails = 0
    local removedSounds = 0

    for _, descendant in ipairs(Workspace:GetDescendants()) do
        if descendant:IsA("ParticleEmitter") then
            if settings.ParticleScale < 0.2 and removedParticles < 50 then
                descendant:Destroy()
                removedParticles += 1
            elseif settings.ParticleScale < 0.2 then
                descendant.Enabled = false
            end
        elseif descendant:IsA("Trail") then
            if settings.ParticleScale < 0.2 and removedTrails < 25 then
                descendant:Destroy()
                removedTrails += 1
            else
                descendant.Enabled = false
            end
        elseif descendant:IsA("Sound") then
            if settings.SoundVolume < 0.25 and removedSounds < 20 then
                descendant:Destroy()
                removedSounds += 1
            else
                descendant.Volume = math.min(
                    descendant.Volume,
                    settings.SoundVolume
                )
            end
        end
    end

    collectgarbage("collect")
end

local function addSlider(
    parent,
    labelText,
    key,
    minValue,
    maxValue,
    stepValue
)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -18, 0, 56)
    holder.BackgroundColor3 = Color3.fromRGB(28, 31, 37)
    holder.BorderSizePixel = 0
    holder.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = holder

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.5, 0, 0.36, 0)
    title.Position = UDim2.new(0, 10, 0, 4)
    title.BackgroundTransparency = 1
    title.Text = labelText
    title.TextColor3 = Color3.fromRGB(245, 245, 245)
    title.Font = Enum.Font.GothamSemibold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = holder

    local valueText = Instance.new("TextLabel")
    valueText.Size = UDim2.new(0.38, 0, 0.36, 0)
    valueText.Position = UDim2.new(0.62, 0, 0, 4)
    valueText.BackgroundTransparency = 1
    valueText.Text = formatValue(key, settings[key])
    valueText.TextColor3 = Color3.fromRGB(110, 220, 140)
    valueText.Font = Enum.Font.GothamBold
    valueText.TextSize = 12
    valueText.TextXAlignment = Enum.TextXAlignment.Right
    valueText.Parent = holder

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -20, 0, 10)
    track.Position = UDim2.new(0, 10, 0.53, 0)
    track.BackgroundColor3 = Color3.fromRGB(43, 45, 52)
    track.BorderSizePixel = 0
    track.Parent = holder

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(93, 150, 255)
    fill.BorderSizePixel = 0
    fill.Parent = track

    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Text = ""
    knob.AutoButtonColor = false
    knob.Parent = track

    local dragging = false

    local function updateVisual()
        local percent = (settings[key] - minValue) / (maxValue - minValue)
        percent = clamp(percent, 0, 1)

        fill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, -6, 0.5, -6)
        valueText.Text = formatValue(key, settings[key])
    end

    local function setFromScreenX(screenX)
        local trackX = track.AbsolutePosition.X
        local trackW = track.AbsoluteSize.X
        local ratio = clamp((screenX - trackX) / trackW, 0, 1)
        local rawValue = minValue + (maxValue - minValue) * ratio
        local snapped = math.floor(rawValue / stepValue + 0.5) * stepValue

        settings[key] = clamp(snapped, minValue, maxValue)

        updateVisual()
        applySettings()
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setFromScreenX(input.Position.X)
        end
    end)

    track.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input, gameProcessed)
        if dragging and not gameProcessed then
            if input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch then
                setFromScreenX(input.Position.X)
            end
        end
    end)

    updateVisual()
end

local function createMenu()
    local panel = Instance.new("Frame")
    panel.Name = "GalaxyOptimisationMenu"
    panel.AnchorPoint = Vector2.new(0.5, 0.5)
    panel.Position = UDim2.new(0.5, 0, 0.5, 0)
    panel.Size = UDim2.new(0, 390, 0, 600)
    panel.BackgroundColor3 = Color3.fromRGB(18, 20, 25)
    panel.BorderSizePixel = 0
    panel.Parent = screenGui

    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 18)
    panelCorner.Parent = panel

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -24, 0, 44)
    title.Position = UDim2.new(0, 12, 0, 14)
    title.BackgroundTransparency = 1
    title.Text = "Galaxy's Optimisation"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 25
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = panel

    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, -24, 0, 18)
    subtitle.Position = UDim2.new(0, 12, 0, 52)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Reduce memory + improve stability"
    subtitle.TextColor3 = Color3.fromRGB(146, 154, 170)
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 12
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = panel

    local presetBar = Instance.new("Frame")
    presetBar.Size = UDim2.new(1, -20, 0, 58)
    presetBar.Position = UDim2.new(0, 10, 0, 82)
    presetBar.BackgroundColor3 = Color3.fromRGB(25, 28, 33)
    presetBar.BorderSizePixel = 0
    presetBar.Parent = panel

    local presetCorner = Instance.new("UICorner")
    presetCorner.CornerRadius = UDim.new(0, 12)
    presetCorner.Parent = presetBar

    local presetNames = {"Balanced", "LowMemory", "Extreme"}

    for index, name in ipairs(presetNames) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1 / #presetNames, -8, 1, -10)
        btn.Position = UDim2.new(
            (index - 1) / #presetNames,
            4,
            0,
            5
        )
        btn.BackgroundColor3 = Color3.fromRGB(93, 120, 255)
        btn.BorderSizePixel = 0
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.Parent = presetBar

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 10)
        btnCorner.Parent = btn

        btn.Activated:Connect(function()
            setPreset(name)
        end)
    end

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -18, 1, -172)
    scroll.Position = UDim2.new(0, 9, 0, 150)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.CanvasSize = UDim2.new(0, 0, 0, 500)
    scroll.ScrollBarThickness = 6
    scroll.Parent = panel

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 8)
    listLayout.Parent = scroll

    addSlider(scroll, "FPS Target", "MaxFPS", 30, 144, 1)
    addSlider(scroll, "Render Distance", "RenderDistance", 50, 500, 10)
    addSlider(scroll, "Shadow Quality", "ShadowQuality", 0, 3, 1)
    addSlider(scroll, "Particle Scale", "ParticleScale", 0.05, 2, 0.05)
    addSlider(scroll, "Texture Quality", "TextureQuality", 0, 3, 1)
    addSlider(scroll, "Decal Quality", "DecalQuality", 0, 3, 1)
    addSlider(scroll, "Brightness", "Brightness", 0.3, 2, 0.1)
    addSlider(scroll, "Sound Volume", "SoundVolume", 0, 1, 0.05)
    addSlider(scroll, "Cleanup Delay", "CleanupDelay", 5, 120, 5)

    local bottomBar = Instance.new("Frame")
    bottomBar.Size = UDim2.new(1, -20, 0, 42)
    bottomBar.Position = UDim2.new(0, 10, 1, -50)
    bottomBar.BackgroundColor3 = Color3.fromRGB(24, 27, 31)
    bottomBar.BorderSizePixel = 0
    bottomBar.Parent = panel

    local bottomCorner = Instance.new("UICorner")
    bottomCorner.CornerRadius = UDim.new(0, 12)
    bottomCorner.Parent = bottomBar

    local applyBtn = Instance.new("TextButton")
    applyBtn.Size = UDim2.new(0.58, 0, 1, 0)
    applyBtn.BackgroundColor3 = Color3.fromRGB(70, 135, 255)
    applyBtn.BorderSizePixel = 0
    applyBtn.Text = "Apply"
    applyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    applyBtn.Font = Enum.Font.GothamBold
    applyBtn.TextSize = 15
    applyBtn.Parent = bottomBar

    local resetBtn = Instance.new("TextButton")
    resetBtn.Size = UDim2.new(0.42, 0, 1, 0)
    resetBtn.Position = UDim2.new(0.58, 0, 0, 0)
    resetBtn.BackgroundColor3 = Color3.fromRGB(75, 75, 80)
    resetBtn.BorderSizePixel = 0
    resetBtn.Text = "Reset"
    resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    resetBtn.Font = Enum.Font.GothamBold
    resetBtn.TextSize = 15
    resetBtn.Parent = bottomBar

    local applyCorner = Instance.new("UICorner")
    applyCorner.CornerRadius = UDim.new(0, 10)
    applyCorner.Parent = applyBtn

    local resetCorner = Instance.new("UICorner")
    resetCorner.CornerRadius = UDim.new(0, 10)
    resetCorner.Parent = resetBtn

    applyBtn.Activated:Connect(function()
        applySettings()
    end)

    resetBtn.Activated:Connect(function()
        for key, value in pairs(defaults) do
            settings[key] = value
        end

        applySettings()
    end)

    panel.Visible = false

    return panel
end

local menu = createMenu()

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "GalaxyToggle"
toggleButton.Size = UDim2.new(0, 122, 0, 42)
toggleButton.Position = UDim2.new(0.5, 0, 0.5, 0)
toggleButton.AnchorPoint = Vector2.new(0.5, 0.5)
toggleButton.BackgroundColor3 = Color3.fromRGB(51, 182, 110)
toggleButton.BorderSizePixel = 0
toggleButton.Text = "OPT"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 17
toggleButton.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 15)
toggleCorner.Parent = toggleButton

local menuOpen = false

local function toggleMenu()
    menuOpen = not menuOpen
    menu.Visible = menuOpen
    toggleButton.Visible = not menuOpen
end

toggleButton.Activated:Connect(toggleMenu)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end

    if input.KeyCode == Enum.KeyCode.RightShift then
        toggleMenu()
    end
end)

applySettings()

task.spawn(function()
    while true do
        task.wait(settings.CleanupDelay)

        if settings.AutoCleanup then
            aggressiveCleanup()
        end
    end
end)

print("Galaxy's Optimisation loaded. Press the OPT button or RightShift to open the menu.")