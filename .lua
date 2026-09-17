I’ll pull the current Lua file so I can send you the exact version that is in the workspace.

Read 

Place this **LocalScript** in `StarterPlayer > StarterPlayerScripts`:

```lua
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("GalaxyOptimisationGui")
if oldGui then
	oldGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GalaxyOptimisationGui"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 100
screenGui.Parent = playerGui

local settings = {
	Particles = true,
	Shadows = false,
	Decals = true,
	LowGraphics = false,
}

local function applyParticles()
	for _, descendant in ipairs(Workspace:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") then
			descendant.Enabled = settings.Particles
		end
	end
end

local function applyShadows()
	Lighting.GlobalShadows = settings.Shadows
end

local function applyDecals()
	for _, descendant in ipairs(Workspace:GetDescendants()) do
		if descendant:IsA("Decal") or descendant:IsA("Texture") then
			descendant.Transparency = settings.Decals and 0 or 1
		end
	end
end

local function applyLowGraphics()
	if settings.LowGraphics then
		Lighting.Brightness = 1
		Lighting.EnvironmentDiffuseScale = 0
		Lighting.EnvironmentSpecularScale = 0
	else
		Lighting.Brightness = 2
		Lighting.EnvironmentDiffuseScale = 1
		Lighting.EnvironmentSpecularScale = 1
	end
end

local function applySetting(name)
	if name == "Particles" then
		applyParticles()
	elseif name == "Shadows" then
		applyShadows()
	elseif name == "Decals" then
		applyDecals()
	elseif name == "LowGraphics" then
		applyLowGraphics()
	end
end

local function addCorner(instance, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = instance
end

local panel = Instance.new("Frame")
panel.Name = "Menu"
panel.Size = UDim2.new(0, 240, 0, 240)
panel.Position = UDim2.new(1, -16, 0, 66)
panel.AnchorPoint = Vector2.new(1, 0)
panel.BackgroundColor3 = Color3.fromRGB(25, 28, 34)
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = screenGui
addCorner(panel, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -24, 0, 38)
title.Position = UDim2.new(0, 12, 0, 8)
title.BackgroundTransparency = 1
title.Text = "Graphics"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local list = Instance.new("Frame")
list.Size = UDim2.new(1, -24, 1, -58)
list.Position = UDim2.new(0, 12, 0, 50)
list.BackgroundTransparency = 1
list.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 7)
layout.Parent = list

local function addToggle(name, labelText)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = UDim2.new(1, 0, 0, 39)
	button.BackgroundColor3 = Color3.fromRGB(52, 57, 66)
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamSemibold
	button.TextSize = 14
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Parent = list
	addCorner(button, 7)

	local function updateText()
		button.Text = "  " .. labelText .. ": " .. (settings[name] and "ON" or "OFF")
		button.BackgroundColor3 = settings[name]
			and Color3.fromRGB(48, 125, 82)
			or Color3.fromRGB(52, 57, 66)
	end

	button.Activated:Connect(function()
		settings[name] = not settings[name]
		updateText()
		applySetting(name)
	end)

	updateText()
end

addToggle("Particles", "Particles")
addToggle("Shadows", "Shadows")
addToggle("Decals", "Textures / Decals")
addToggle("LowGraphics", "Low Graphics")

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleMenu"
toggleButton.Size = UDim2.new(0, 116, 0, 42)
toggleButton.Position = UDim2.new(1, -16, 0, 16)
toggleButton.AnchorPoint = Vector2.new(1, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(48, 125, 82)
toggleButton.BorderSizePixel = 0
toggleButton.Text = "GRAPHICS"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 13
toggleButton.Parent = screenGui
addCorner(toggleButton, 8)

toggleButton.Activated:Connect(function()
	panel.Visible = not panel.Visible
	toggleButton.Text = panel.Visible and "CLOSE" or "GRAPHICS"
end)

applyShadows()

print("Galaxy's Optimisation loaded. Press GRAPHICS to open the menu.")
```