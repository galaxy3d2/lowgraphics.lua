local guiParent = (gethui and gethui()) or game:GetService("CoreGui")

local oldGui = guiParent:FindFirstChild("BlankMenu")
if oldGui then
	oldGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BlankMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = guiParent

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0, 100, 0, 36)
toggle.Position = UDim2.new(1, -110, 0, 10)
toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggle.BorderSizePixel = 0
toggle.Text = "MENU"
toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
toggle.TextSize = 14
toggle.Parent = screenGui

local menu = Instance.new("Frame")
menu.Size = UDim2.new(0, 260, 0, 180)
menu.Position = UDim2.new(1, -270, 0, 56)
menu.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
menu.BorderSizePixel = 0
menu.Visible = false
menu.Parent = screenGui

toggle.Activated:Connect(function()
	menu.Visible = not menu.Visible
end)
