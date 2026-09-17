local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local screenGui = Instance.new("ScreenGui")
local toggleButton = Instance.new("TextButton")

-- Configure the toggle button
toggleButton.Size = UDim2.new(0, 150, 0, 50)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.Text = "Optimize On/Off"
toggleButton.Parent = screenGui

local optimizationEnabled = false

local function optimizePerformance()
    if optimizationEnabled then
        -- Example: Disable unnecessary scripts or parts
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                -- Reduce rendering load
                part.Material = Enum.Material.SmoothPlastic
            end
        end
        -- Additional optimization code can be added here
    else
        -- Restore or reset settings if needed
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                -- Reset material or other properties
                part.Material = Enum.Material.Wood
            end
        end
    end
end

toggleButton.MouseButton1Click:Connect(function()
    optimizationEnabled = not optimizationEnabled
    optimizePerformance()
    toggleButton.Text = optimizationEnabled and "Optimize Off" or "Optimize On"
end)

-- Add the GUI to the player's screen
local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
screenGui.Parent = playerGui