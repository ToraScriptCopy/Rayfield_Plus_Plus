local RayfieldPlus = {}
function RayfieldPlus.extend(Rayfield)
	if not Rayfield or not Rayfield.CreateWindow then
		error("Rayfield библиотека не найдена или повреждена")
	end
	local Icons_Geist = {
		["home"] = {assetId = 123456789, rect = Vector2.new(24,24), offset = Vector2.new(0,0)},
	}
	local Icons_Craft = {
		["settings"] = {assetId = 987654321, rect = Vector2.new(24,24), offset = Vector2.new(0,0)},
	}
	local originalResolveIcon = Rayfield._resolveIcon or function(icon) end
	Rayfield._resolveIcon = function(icon)
		if type(icon) == "string" then
			local prefix, name = icon:match("^(%a+):(.+)$")
			if prefix and name then
				local lib = prefix:lower()
				if lib == "geist" then
					local data = Icons_Geist[name]
					if data then
						return "rbxassetid://" .. data.assetId, data.offset, data.rect
					end
				elseif lib == "craft" then
					local data = Icons_Craft[name]
					if data then
						return "rbxassetid://" .. data.assetId, data.offset, data.rect
					end
				end
			end
		end
		if originalResolveIcon then
			return originalResolveIcon(icon)
		end
		return Rayfield._resolveIcon_original(icon)
	end
	if not Rayfield._resolveIcon_original then
		Rayfield._resolveIcon_original = Rayfield._resolveIcon
	end
	local originalCreateWindow = Rayfield.CreateWindow
	Rayfield.CreateWindow = function(Settings)
		local Window = originalCreateWindow(Settings)
		local windowSettings = Settings
		local windowInstance = Window._windowInstance
		function Window:SetBackgroundTransparency(transparency)
			local main = windowInstance.Main
			main.BackgroundTransparency = transparency
		end
		function Window:SetBackgroundImage(imageId)
			local main = windowInstance.Main
			local bg = main:FindFirstChild("BackgroundImage")
			if not bg then
				bg = Instance.new("ImageLabel")
				bg.Name = "BackgroundImage"
				bg.Parent = main
				bg.Size = UDim2.new(1,0,1,0)
				bg.BackgroundTransparency = 1
				bg.ZIndex = 0
				main:MoveToFront(bg)
			end
			bg.Image = "rbxassetid://" .. imageId
		end
		function Window:EnableRainbowEffect(speed)
			local main = windowInstance.Main
			local hue = 0
			local connection
			connection = game:GetService("RunService").Heartbeat:Connect(function()
				hue = (hue + (speed or 0.5) * 0.01) % 1
				main.BackgroundColor3 = Color3.fromHSV(hue, 0.8, 0.8)
			end)
			windowInstance._rainbowConnection = connection
		end
		function Window:DisableRainbowEffect()
			if windowInstance._rainbowConnection then
				windowInstance._rainbowConnection:Disconnect()
				windowInstance._rainbowConnection = nil
			end
		end
		local miniContainer = Instance.new("Frame")
		miniContainer.Name = "MinisContainer"
		miniContainer.Parent = windowInstance
		miniContainer.Size = UDim2.new(1,0,1,0)
		miniContainer.BackgroundTransparency = 1
		miniContainer.ZIndex = 1000
		function Window:CreateMiniToggle(settings)
			local mini = Instance.new("Frame")
			mini.Name = "MiniToggle"
			mini.Parent = miniContainer
			mini.Size = UDim2.new(0, 60, 0, 30)
			mini.Position = UDim2.new(0, 10, 0, 10)
			mini.BackgroundColor3 = Rayfield.Theme.Default.ElementBackground
			mini.BorderSizePixel = 0
			local label = Instance.new("TextLabel")
			label.Parent = mini
			label.Size = UDim2.new(1, -30, 1, 0)
			label.BackgroundTransparency = 1
			label.Text = settings.Name or "Toggle"
			label.TextColor3 = Rayfield.Theme.Default.TextColor
			label.Font = Enum.Font.SourceSans
			label.TextSize = 12
			label.TextXAlignment = Enum.TextXAlignment.Left
			local button = Instance.new("ImageButton")
			button.Parent = mini
			button.Size = UDim2.new(0, 20, 0, 20)
			button.Position = UDim2.new(1, -25, 0.5, -10)
			button.BackgroundColor3 = Rayfield.Theme.Default.ToggleDisabled
			button.BorderSizePixel = 0
			local value = settings.CurrentValue or false
			local callback = settings.Callback
			local function update()
				if value then
					button.BackgroundColor3 = Rayfield.Theme.Default.ToggleEnabled
				else
					button.BackgroundColor3 = Rayfield.Theme.Default.ToggleDisabled
				end
			end
			update()
			button.MouseButton1Click:Connect(function()
				value = not value
				update()
				if callback then callback(value) end
			end)
			local dragging = false
			local offset = Vector2.new()
			mini.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					offset = input.Position - mini.AbsolutePosition
				end
			end)
			game:GetService("UserInputService").InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end)
			game:GetService("RunService").RenderStepped:Connect(function()
				if dragging then
					local pos = game:GetService("UserInputService"):GetMouseLocation() - offset
					mini.Position = UDim2.new(0, pos.X, 0, pos.Y)
				end
			end)
			local self = {}
			function self:Set(newValue)
				value = newValue
				update()
			end
			function self:Get()
				return value
			end
			return self
		end
		function Window:CreateMiniButton(settings)
			local mini = Instance.new("ImageButton")
			mini.Name = "MiniButton"
			mini.Parent = miniContainer
			mini.Size = UDim2.new(0, 40, 0, 40)
			mini.Position = UDim2.new(0, 60, 0, 10)
			mini.BackgroundColor3 = Rayfield.Theme.Default.ElementBackground
			mini.BorderSizePixel = 0
			mini.Image = settings.Icon or ""
			if settings.Icon then
				local img, off, rect = Rayfield._resolveIcon(settings.Icon)
				mini.Image = img or ""
				if off then mini.ImageRectOffset = off end
				if rect then mini.ImageRectSize = rect end
			end
			mini.MouseButton1Click:Connect(function()
				if settings.Callback then settings.Callback() end
			end)
			local dragging = false
			local offset = Vector2.new()
			mini.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					offset = input.Position - mini.AbsolutePosition
				end
			end)
			game:GetService("UserInputService").InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end)
			game:GetService("RunService").RenderStepped:Connect(function()
				if dragging then
					local pos = game:GetService("UserInputService"):GetMouseLocation() - offset
					mini.Position = UDim2.new(0, pos.X, 0, pos.Y)
				end
			end)
			return mini
		end
		Window._windowInstance = windowInstance
		local originalCreateTab = Window.CreateTab
		Window.CreateTab = function(Name, Image, Ext)
			local Tab = originalCreateTab(Name, Image, Ext)
			function Tab:CreatePopup(settings)
				local popup = Instance.new("Frame")
				popup.Name = "Popup"
				popup.Parent = windowInstance
				popup.Size = UDim2.new(0, 300, 0, 200)
				popup.Position = UDim2.new(0.5, -150, 0.5, -100)
				popup.BackgroundColor3 = Rayfield.Theme.Default.Background
				popup.BorderSizePixel = 0
				popup.ZIndex = 500
				popup.Visible = false
				local title = Instance.new("TextLabel")
				title.Parent = popup
				title.Size = UDim2.new(1,0,0,30)
				title.BackgroundTransparency = 1
				title.Text = settings.Title or "Popup"
				title.TextColor3 = Rayfield.Theme.Default.TextColor
				title.Font = Enum.Font.SourceSansBold
				title.TextSize = 18
				title.TextXAlignment = Enum.TextXAlignment.Left
				title.Position = UDim2.new(0,10,0,5)
				local content = Instance.new("TextLabel")
				content.Parent = popup
				content.Size = UDim2.new(1, -20, 1, -60)
				content.Position = UDim2.new(0,10,0,35)
				content.BackgroundTransparency = 1
				content.Text = settings.Content or ""
				content.TextColor3 = Rayfield.Theme.Default.TextColor
				content.Font = Enum.Font.SourceSans
				content.TextSize = 14
				content.TextXAlignment = Enum.TextXAlignment.Left
				content.TextYAlignment = Enum.TextYAlignment.Top
				content.TextWrapped = true
				local closeBtn = Instance.new("ImageButton")
				closeBtn.Parent = popup
				closeBtn.Size = UDim2.new(0, 20, 0, 20)
				closeBtn.Position = UDim2.new(1, -30, 0, 5)
				closeBtn.BackgroundTransparency = 1
				closeBtn.Image = "rbxassetid://10137832201"
				closeBtn.MouseButton1Click:Connect(function()
					popup.Visible = false
				end)
				function self:Show()
					popup.Visible = true
				end
				function self:Hide()
					popup.Visible = false
				end
				function self:SetContent(newContent)
					content.Text = newContent
				end
				return self
			end
			function Tab:CreateTag(settings)
				local tag = Elements.Template.Label:Clone()
				tag.Title.Text = settings.Text or "Tag"
				tag.Visible = true
				tag.Parent = TabPage
				return tag
			end
			function Tab:CreateKeyValueDisplay(settings)
				local frame = Elements.Template.Keybind:Clone()
				frame.Title.Text = settings.Name or "Key"
				frame.Visible = true
				frame.Parent = TabPage
				frame.KeybindFrame.KeybindBox.Text = tostring(settings.CurrentValue or "")
				frame.KeybindFrame.KeybindBox.Interactable = false
				frame.KeybindFrame.Size = UDim2.new(0, 100, 0, 30)
				local self = {}
				function self:Set(newValue)
					frame.KeybindFrame.KeybindBox.Text = tostring(newValue)
					if settings.Callback then settings.Callback(newValue) end
				end
				function self:Get()
					return frame.KeybindFrame.KeybindBox.Text
				end
				return self
			end
			function Tab:CreateProgressBar(settings)
				local frame = Elements.Template.Slider:Clone()
				frame.Title.Text = settings.Name or "Progress"
				frame.Visible = true
				frame.Parent = TabPage
				frame.Main.Interact.Visible = false
				frame.Main.Progress.Size = UDim2.new(settings.CurrentValue / 100, 0, 1, 0)
				frame.Main.Information.Text = tostring(settings.CurrentValue) .. "%"
				local self = {}
				function self:Set(newValue)
					local clamped = math.clamp(newValue, 0, 100)
					frame.Main.Progress.Size = UDim2.new(clamped / 100, 0, 1, 0)
					frame.Main.Information.Text = tostring(clamped) .. "%"
					if settings.Callback then settings.Callback(clamped) end
				end
				function self:Get()
					return tonumber(frame.Main.Information.Text:gsub("%%", ""))
				end
				return self
			end
			function Tab:CreateImageHolder(settings)
				local frame = Elements.Template.Label:Clone()
				frame.Title.Text = settings.Name or "Image"
				frame.Visible = true
				frame.Parent = TabPage
				local img = Instance.new("ImageLabel")
				img.Parent = frame
				img.Size = UDim2.new(1, -20, 0, 150)
				img.Position = UDim2.new(0,10,0,25)
				img.BackgroundTransparency = 1
				img.Image = settings.ImageId and ("rbxassetid://" .. settings.ImageId) or ""
				img.ScaleType = Enum.ScaleType.Fit
				return img
			end
			function Tab:CreateConsoleButton(settings)
				local btn = Tab:CreateButton({
					Name = settings.Name or "Console",
					Callback = function()
						game:GetService("StarterGui"):SetCore("DevConsoleVisible", true)
					end
				})
				return btn
			end
			function Tab:CreateLockableElement(element, conditionFlag, checkFunction)
				local locked = false
				local function updateLock()
					local unlocked = checkFunction()
					if unlocked then
						element.Visible = true
					else
						element.Visible = false
					end
				end
				local connection = game:GetService("RunService").Heartbeat:Connect(updateLock)
				updateLock()
				return {
					Destroy = function()
						connection:Disconnect()
					end
				}
			end
			return Tab
		end
		return Window
	end
	local originalCreateKeybind = Rayfield.CreateWindow._createKeybind
	function Rayfield:SetKeybindHandler(callback)
		self._keybindHandler = callback
	end
	function Window:CreateImprovedKeybind(settings)
		local keybind = nil
	end
	function Rayfield:CreatePopup(settings)
		local popup = Instance.new("Frame")
		popup.Name = "GlobalPopup"
		popup.Parent = game:GetService("CoreGui")
		popup.Size = UDim2.new(0, 400, 0, 250)
		popup.Position = UDim2.new(0.5, -200, 0.5, -125)
		popup.BackgroundColor3 = Rayfield.Theme.Default.Background
		popup.BorderSizePixel = 0
		popup.ZIndex = 999
		popup.Visible = false
		local title = Instance.new("TextLabel")
		title.Parent = popup
		title.Size = UDim2.new(1,0,0,30)
		title.BackgroundTransparency = 1
		title.Text = settings.Title or "Popup"
		title.TextColor3 = Rayfield.Theme.Default.TextColor
		title.Font = Enum.Font.SourceSansBold
		title.TextSize = 18
		title.Position = UDim2.new(0,10,0,5)
		local content = Instance.new("TextLabel")
		content.Parent = popup
		content.Size = UDim2.new(1, -20, 1, -60)
		content.Position = UDim2.new(0,10,0,35)
		content.BackgroundTransparency = 1
		content.Text = settings.Content or ""
		content.TextColor3 = Rayfield.Theme.Default.TextColor
		content.Font = Enum.Font.SourceSans
		content.TextSize = 14
		content.TextWrapped = true
		local closeBtn = Instance.new("ImageButton")
		closeBtn.Parent = popup
		closeBtn.Size = UDim2.new(0, 20, 0, 20)
		closeBtn.Position = UDim2.new(1, -30, 0, 5)
		closeBtn.BackgroundTransparency = 1
		closeBtn.Image = "rbxassetid://10137832201"
		closeBtn.MouseButton1Click:Connect(function()
			popup.Visible = false
		end)
		local dragging = false
		local offset = Vector2.new()
		popup.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				offset = input.Position - popup.AbsolutePosition
			end
		end)
		game:GetService("UserInputService").InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)
		game:GetService("RunService").RenderStepped:Connect(function()
			if dragging then
				local pos = game:GetService("UserInputService"):GetMouseLocation() - offset
				popup.Position = UDim2.new(0, pos.X, 0, pos.Y)
			end
		end)
		local self = {}
		function self:Show()
			popup.Visible = true
		end
		function self:Hide()
			popup.Visible = false
		end
		function self:Destroy()
			popup:Destroy()
		end
		return self
	end
	local saveQueue = {}
	local saveTimer = nil
	function Rayfield:QueueSave(flag, value)
		saveQueue[flag] = value
		if saveTimer then return end
		saveTimer = task.delay(2, function()
			saveTimer = nil
			for flag, val in pairs(saveQueue) do
				local element = Rayfield.Flags[flag]
				if element then
					if element.Type == "ColorPicker" then
					else
						element.CurrentValue = val
					end
				end
			end
			saveQueue = {}
			if Rayfield._saveConfiguration then
				Rayfield._saveConfiguration()
			end
		end)
	end
	return Rayfield
end
return RayfieldPlus
