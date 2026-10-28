_G.autofarm = false
_G.tpspeed = 0.9          
_G.maxTweenTime = 2      

local ts = game:GetService("TweenService")
local players = game:GetService("Players")
local player = players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--// Create the toggle button
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutofarmGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local button = Instance.new("TextButton")
button.Name = "ToggleButton"
button.Size = UDim2.new(0, 160, 0, 45)
button.Position = UDim2.new(1, -180, 1, -70)
button.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Font = Enum.Font.GothamBold
button.TextSize = 16
button.Text = "Autofarm: OFF"
button.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = button

--// Notification helper
local function notify(text, duration)
	game.StarterGui:SetCore("SendNotification", {
		Title = "Autofarm",
		Text = text,
		Duration = duration or 1
	})
end

--// Find the closest resource node
local function getClosestNode(position)
	local closest = nil
	local closestDist = math.huge
	
	local nodesFolder = workspace:FindFirstChild("Scene") and workspace.Scene:FindFirstChild("ResourceNodes1")
	if not nodesFolder then return nil end
	
	for _, v in pairs(nodesFolder:GetChildren()) do
		if v:IsA("Part") and v:FindFirstChild("Prefab") then
			local dist = (v.Position - position).Magnitude
			if dist < closestDist then
				closestDist = dist
				closest = v
			end
		end
	end
	
	return closest
end

--// Farming loop
local farming = false

local function startFarming()
	if farming then return end
	farming = true
	
	task.spawn(function()
		while _G.autofarm do
			local character = player.Character
			local hrp = character and character:FindFirstChild("HumanoidRootPart")
			
			if hrp then
				local target = getClosestNode(hrp.Position)
				
				if target then
					local distance = (target.Position - hrp.Position).Magnitude
					
					-- Within 50 studs = fixed 0.2, farther = slower
					local tweenTime
					if distance <= 300 then
						tweenTime = _G.tpspeed
					else
						tweenTime = math.clamp(distance * 0.007, _G.tpspeed, _G.maxTweenTime)
					end
					
					local tween = ts:Create(
						hrp,
						TweenInfo.new(tweenTime),
						{CFrame = target.CFrame}
					)
					tween:Play()
					tween.Completed:Wait()
					
					if target:FindFirstChild("NodeType") then
						local nodeType = target.NodeType.Value
						if nodeType == 1 then
							notify("Exp orb collected", 0.3)
						elseif nodeType == 2 then
							notify("Coin orb collected", 0.3)
						else
							notify("Speed Orb collected", 0.3)
						end
					end
				end
			end
			
			task.wait(0.05)
		end
		farming = false
	end)
end

--// Button click
button.MouseButton1Click:Connect(function()
	_G.autofarm = not _G.autofarm
	
	if _G.autofarm then
		button.Text = "Autofarm: ON"
		button.BackgroundColor3 = Color3.fromRGB(40, 160, 60)
		notify("Autofarm has been enabled", 1.5)
		startFarming()
	else
		button.Text = "Autofarm: OFF"
		button.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
		notify("Autofarm has been disabled", 1.5)
	end
end)