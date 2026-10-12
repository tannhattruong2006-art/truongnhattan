-- MrDon Utility v2 | Run through loadstring in Studio's edit-time Command Bar.
-- This installer creates a normal LocalScript; press Play after installation.
local CLIENT_SOURCE = [====[
-- Roblox Utility Menu v2 | one LocalScript | StarterPlayer > StarterPlayerScripts
-- All editable settings are here. No other scripts, modules, or remotes are required.
local CONFIG = {
	Version = "2.0.0",
	MenuToggleKey = Enum.KeyCode.RightShift,
	GuiName = "MrDonUtilityMenu",
	WalkSpeed = { Min = 8, Max = 80, Default = 24, Step = 1 },
	JumpPower = { Min = 0, Max = 150, Default = 70, Step = 1 },
	JumpHeight = { Min = 0, Max = 40, Default = 12, Step = 0.5 },
	EnemyTag = "FarmableEnemy",
	EnemyFolderPath = { "Enemies" }, -- Relative to Workspace; e.g. {"NPCs", "Enemies"}.
	LootTags = { "LootChest", "DevilFruit" },
	EnemyHeight = 7,
	LootStoppingDistance = 4,
	TweenSpeed = 55, -- studs/second
	TargetSearchInterval = 0.4,
	AttackInterval = 0.6,
	CollectInterval = 0.8,
	ArrivalTolerance = 1.5,
	RetargetDistance = 5,
	MaxTweenDuration = 20,
	FollowResponsiveness = 25,
	FollowMaxForce = 1000000,
	FollowMaxTorque = 1000000,
	FollowMaxVelocity = 100,
	Motion = { StallTimeout = 5, ProgressEpsilon = 0.35, RetryDelay = 2, ArrivalGrace = 1.5, MaxGoalLead = 12 },
	Combat = {
		ToolNames = {}, -- Exact names of YOUR combat Tools. Empty = no automatic Tool activation.
		MaxRange = 10, TapDuration = 0.12,
	},
	LootInteraction = {
		UseProximityPrompts = true,
		PromptNames = {}, -- Empty = any existing visible prompt inside the selected tagged item.
		HoldPadding = 0.1, RetryDelay = 1.2,
	},
	Graphics = {
		DecorationTag = "UtilityDecorative", -- Explicit opt-in for material/texture changes.
		ProtectedTag = "UtilityProtected",
		FogEnd = 100000,
		ProcessBudget = 100, -- Max queued visual instances processed per Heartbeat.
		SimpleMaterial = Enum.Material.SmoothPlastic,
		Brightness = 2,
		Ambient = Color3.fromRGB(145, 145, 145),
		OutdoorAmbient = Color3.fromRGB(165, 165, 165),
		ExposureCompensation = 0.15,
	},
	ESP = {
		OutlineColor = Color3.fromRGB(88, 190, 255),
		FillColor = Color3.fromRGB(55, 130, 210),
		TextColor = Color3.fromRGB(235, 242, 255),
		HealthyColor = Color3.fromRGB(80, 210, 145),
		LowHealthColor = Color3.fromRGB(245, 95, 95),
		FillTransparency = 0.88,
		OutlineTransparency = 0,
		ShowNames = true,
		ShowHealth = true,
		ShowDistance = true,
		HideSameTeam = false,
		UpdateInterval = 0.2,
		MaxDistance = 10000,
		BillboardWidth = 180,
		BillboardHeight = 60,
		StudsOffset = Vector3.new(0, 3.5, 0),
	},
	UI = {
		Width = 340, Height = 510, HeaderHeight = 44, Margin = 12,
		TabHeight = 36, TouchDragThreshold = 8, NotificationLimit = 4,
		NotificationSeconds = 4, DropdownHeight = 180, RefreshInterval = 1,
		OverrideWarningInterval = 5, ErrorNoticeInterval = 5,
		Background = Color3.fromRGB(20, 25, 36),
		Card = Color3.fromRGB(31, 38, 52),
		Accent = Color3.fromRGB(80, 170, 245),
		Text = Color3.fromRGB(235, 242, 255),
		Muted = Color3.fromRGB(155, 171, 193),
		Success = Color3.fromRGB(90, 215, 150),
		Error = Color3.fromRGB(250, 115, 115),
	},
}

local function isFinite(value)
	return type(value) == "number" and value == value and math.abs(value) < math.huge
end
local function validateRangeValue(value, limits)
	if not isFinite(value) or value < limits.Min or value > limits.Max then
		return false, string.format("Giá trị phải từ %s đến %s.", limits.Min, limits.Max)
	end
	return true
end
local function validateConfiguration()
	local function number(path, value, minimum, maximum)
		assert(isFinite(value) and value >= minimum and value <= (maximum or math.huge),
			"CONFIG." .. path .. " must be a finite number in the allowed range")
	end
	local function names(path, values, allowEmpty)
		assert(type(values) == "table" and (allowEmpty or #values > 0), "CONFIG." .. path .. " must be a list")
		for _, value in ipairs(values) do
			assert(type(value) == "string" and value:match("%S"), "CONFIG." .. path .. " contains an empty name")
		end
	end
	for _, name in ipairs({ "WalkSpeed", "JumpPower", "JumpHeight" }) do
		local limits = CONFIG[name]
		number(name .. ".Min", limits.Min, 0)
		number(name .. ".Max", limits.Max, limits.Min)
		assert(limits.Max > limits.Min, "CONFIG." .. name .. ".Max must exceed Min")
		number(name .. ".Default", limits.Default, limits.Min, limits.Max)
		number(name .. ".Step", limits.Step, 0.001, limits.Max - limits.Min)
	end
	names("EnemyFolderPath", CONFIG.EnemyFolderPath, true)
	names("LootTags", CONFIG.LootTags, false)
	names("Combat.ToolNames", CONFIG.Combat.ToolNames, true)
	names("LootInteraction.PromptNames", CONFIG.LootInteraction.PromptNames, true)
	for _, name in ipairs({ "TweenSpeed", "TargetSearchInterval", "AttackInterval", "CollectInterval", "ArrivalTolerance",
		"RetargetDistance", "MaxTweenDuration", "FollowMaxForce", "FollowMaxTorque", "FollowMaxVelocity" }) do
		number(name, CONFIG[name], 0.01)
	end
	number("EnemyHeight", CONFIG.EnemyHeight, 0)
	number("LootStoppingDistance", CONFIG.LootStoppingDistance, 0)
	number("FollowResponsiveness", CONFIG.FollowResponsiveness, 5, 200)
	for name, value in pairs(CONFIG.Motion) do number("Motion." .. name, value, 0.01) end
	number("Combat.MaxRange", CONFIG.Combat.MaxRange, 0.01)
	number("Combat.TapDuration", CONFIG.Combat.TapDuration, 0.01)
	number("LootInteraction.HoldPadding", CONFIG.LootInteraction.HoldPadding, 0)
	number("LootInteraction.RetryDelay", CONFIG.LootInteraction.RetryDelay, 0.1)
	for _, name in ipairs({ "Width", "Height", "HeaderHeight", "TabHeight", "TouchDragThreshold", "NotificationLimit",
		"NotificationSeconds", "DropdownHeight", "RefreshInterval", "OverrideWarningInterval", "ErrorNoticeInterval" }) do
		number("UI." .. name, CONFIG.UI[name], 1)
	end
	number("UI.Margin", CONFIG.UI.Margin, 0)
	number("Graphics.ProcessBudget", CONFIG.Graphics.ProcessBudget, 1)
	number("Graphics.FogEnd", CONFIG.Graphics.FogEnd, 1)
	number("ESP.UpdateInterval", CONFIG.ESP.UpdateInterval, 0.05)
	number("ESP.MaxDistance", CONFIG.ESP.MaxDistance, 0)
	assert(typeof(CONFIG.MenuToggleKey) == "EnumItem" and CONFIG.MenuToggleKey.EnumType == Enum.KeyCode,
		"CONFIG.MenuToggleKey must be an Enum.KeyCode")
	for _, value in ipairs({ CONFIG.GuiName, CONFIG.EnemyTag, CONFIG.Graphics.DecorationTag, CONFIG.Graphics.ProtectedTag }) do
		assert(type(value) == "string" and value:match("%S"), "CONFIG contains an empty GUI name or tag")
	end
end
validateConfiguration()

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
	error("UtilityMenu must run as a LocalScript in StarterPlayerScripts.")
end
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
if not PlayerGui then
	error("UtilityMenu could not find PlayerGui within 10 seconds.")
end
-- A second copy leaves the running controller intact; destroying only its GUI would leak it.
if PlayerGui:FindFirstChild(CONFIG.GuiName) then
	warn("[UtilityMenu] A menu is already running; the duplicate LocalScript stopped.")
	return
end

local State = {
	alive = true, character = nil, humanoid = nil, root = nil,
	features = {}, enemyType = nil, lootTypes = {},
	walkSpeed = CONFIG.WalkSpeed.Default,
	jumpValues = { JumpPower = CONFIG.JumpPower.Default, JumpHeight = CONFIG.JumpHeight.Default },
	statuses = { Farm = "Disabled", Loot = "Disabled" },
}
local notifySink
local function notify(message, isError)
	if notifySink and State.alive then
		notifySink(tostring(message), isError == true)
	elseif isError then
		warn("[UtilityMenu] " .. tostring(message))
	end
end
local errorTimes = {}
local function reportError(context, err)
	local message = tostring(context) .. ": " .. tostring(err)
	local now = os.clock()
	if not errorTimes[context] or now - errorTimes[context] > CONFIG.UI.ErrorNoticeInterval then
		errorTimes[context] = now
		warn("[UtilityMenu] " .. message)
		notify(message, true)
	end
end
local function checkedCall(context, callback, ...)
	local ok, result = xpcall(callback, debug.traceback, ...)
	if not ok then reportError(context, result) end
	return ok, result
end
local function newInstance(className, properties, parent)
	local instance = Instance.new(className)
	for property, value in pairs(properties or {}) do instance[property] = value end
	instance.Parent = parent
	return instance
end

local Scope = {}
do
	Scope.__index = Scope
	function Scope.new()
		return setmetatable({ alive = true, cleaners = {} }, Scope)
	end
	function Scope:add(cleaner)
		if self.alive then table.insert(self.cleaners, cleaner)
		else checkedCall("Late cleanup", cleaner) end
		return cleaner
	end
	function Scope:connect(signal, callback)
		local connection = signal:Connect(function(...)
			if self.alive and State.alive then checkedCall("Event callback", callback, ...) end
		end)
		self:add(function() connection:Disconnect() end)
		return connection
	end
	function Scope:clean()
		if not self.alive then return end
		self.alive = false
		for index = #self.cleaners, 1, -1 do
			checkedCall("Scope cleanup", self.cleaners[index])
		end
		table.clear(self.cleaners)
	end
end
local mainScope = Scope.new()
local Gui = newInstance("ScreenGui", {
	Name = CONFIG.GuiName, ResetOnSpawn = false, DisplayOrder = 50,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets,
	ClipToDeviceSafeArea = true,
}, PlayerGui)
Gui:SetAttribute("UtilityVersion", CONFIG.Version)

local Noclip = {}
do
	local requests = {}
	local activeScope, activeCharacter
	local function stop()
		if activeScope then activeScope:clean() end
		activeScope, activeCharacter = nil, nil
	end
	local function wanted()
		return next(requests) ~= nil and State.character and State.humanoid
			and State.humanoid.Health > 0 and State.character:IsDescendantOf(Workspace)
			and LocalPlayer.Character == State.character
	end
	local function start(character)
		activeScope, activeCharacter = Scope.new(), character
		local originals = {}
		local function restore(part)
			local original = originals[part]
			if original ~= nil then
				if part.Parent then checkedCall("Restore CanCollide", function() part.CanCollide = original end) end
				originals[part] = nil
			end
		end
		local function track(part)
			if part:IsA("BasePart") and part:IsDescendantOf(character) then
				if originals[part] == nil then originals[part] = part.CanCollide end
				part.CanCollide = false
			end
		end
		for _, descendant in ipairs(character:GetDescendants()) do track(descendant) end
		activeScope:connect(character.DescendantAdded, track)
		activeScope:connect(character.DescendantRemoving, restore)
		activeScope:add(function()
			for part in pairs(originals) do restore(part) end
		end)
		activeScope:connect(RunService.PreSimulation, function()
			if not wanted() then stop(); return end
			for part in pairs(originals) do
				if part:IsDescendantOf(character) then part.CanCollide = false else restore(part) end
			end
		end)
	end
	function Noclip.refresh()
		if activeCharacter ~= State.character or not wanted() then stop() end
		if wanted() and not activeScope then start(State.character) end
	end
	function Noclip.request(owner, enabled)
		requests[owner] = enabled and true or nil
		Noclip.refresh()
	end
	function Noclip.destroy()
		table.clear(requests)
		stop()
	end
end
local function setNoclipRequest(owner, enabled) Noclip.request(owner, enabled) end
local statusSink
local function onAutomationStatus(mode, text)
	State.statuses[mode] = text
	if statusSink then statusSink(mode, text) end
end

local HumanoidControls = {}
do
	local boundHumanoid, speedScope, jumpScope
	local jumpModeSink
	local function stopSpeed()
		if speedScope then speedScope:clean(); speedScope = nil end
	end
	local function stopJump()
		if jumpScope then jumpScope:clean(); jumpScope = nil end
	end
	local function jumpProperty()
		return boundHumanoid and not boundHumanoid.UseJumpPower and "JumpHeight" or "JumpPower"
	end
	local function startSpeed()
		stopSpeed()
		if not boundHumanoid or boundHumanoid.Health <= 0 or not State.features.Speed then return end
		local humanoid, original = boundHumanoid, boundHumanoid.WalkSpeed
		local lastWarning = -math.huge
		speedScope = Scope.new()
		speedScope:add(function()
			if humanoid.Parent then humanoid.WalkSpeed = original end
		end)
		humanoid.WalkSpeed = State.walkSpeed
		speedScope:connect(humanoid:GetPropertyChangedSignal("WalkSpeed"), function()
			if math.abs(humanoid.WalkSpeed - State.walkSpeed) > 0.01
				and os.clock() - lastWarning >= CONFIG.UI.OverrideWarningInterval then
				lastWarning = os.clock()
				notify("WalkSpeed was changed by the server or another game script.", true)
			end
		end)
	end
	local function startJump()
		stopJump()
		if not boundHumanoid or boundHumanoid.Health <= 0 or not State.features.Jump then return end
		local humanoid, property = boundHumanoid, jumpProperty()
		local original = humanoid[property]
		jumpScope = Scope.new()
		jumpScope:add(function()
			if humanoid.Parent then humanoid[property] = original end
		end)
		humanoid[property] = State.jumpValues[property]
	end
	local modeScope
	function HumanoidControls.bind(humanoid)
		stopSpeed(); stopJump()
		if modeScope then modeScope:clean(); modeScope = nil end
		boundHumanoid = humanoid
		if humanoid then
			modeScope = Scope.new()
			modeScope:connect(humanoid:GetPropertyChangedSignal("UseJumpPower"), function()
				startJump()
				if jumpModeSink then jumpModeSink(jumpProperty()) end
			end)
			startSpeed(); startJump()
		end
		if jumpModeSink then jumpModeSink(jumpProperty()) end
	end
	function HumanoidControls.setModeSink(sink) jumpModeSink = sink; sink(jumpProperty()) end
	function HumanoidControls.getJumpProperty() return jumpProperty() end
	function HumanoidControls.setSpeedEnabled(enabled)
		if enabled then startSpeed() else stopSpeed() end
	end
	function HumanoidControls.setJumpEnabled(enabled)
		if enabled then startJump() else stopJump() end
	end
	function HumanoidControls.setSpeed(value)
		local valid, message = validateRangeValue(value, CONFIG.WalkSpeed)
		if not valid then notify(message, true); return false end
		State.walkSpeed = value
		if boundHumanoid and State.features.Speed then boundHumanoid.WalkSpeed = value end
		return true
	end
	function HumanoidControls.setJump(value, expectedProperty)
		local property = jumpProperty()
		if expectedProperty and expectedProperty ~= property then
			notify("Chế độ nhảy đã đổi. Nhập lại giá trị cho " .. property .. ".", true)
			return false
		end
		local valid, message = validateRangeValue(value, CONFIG[property])
		if not valid then notify(message, true); return false end
		State.jumpValues[property] = value
		if boundHumanoid and State.features.Jump then boundHumanoid[property] = value end
		return true
	end
	function HumanoidControls.destroy() HumanoidControls.bind(nil); jumpModeSink = nil end
end


-- Graphics changes are reversible. Only tagged decorations are simplified.
local Graphics = {}
do
    local lagEnabled = false
    local brightEnabled = false
    local lagScope = nil
    local playerScopes = {}
    local instanceScopes = {}
    local originals = setmetatable({}, { __mode = "k" })
    local lightingOriginals = {}
    local lightingLayers = {}
    local queue, queued, queueHead, queueTail = {}, {}, 1, 0
    local enqueue, cancelQueued, processInstance
    local effectClasses = {
        ParticleEmitter = true, Trail = true, Beam = true, Smoke = true,
        Fire = true, Sparkles = true, PointLight = true, SpotLight = true,
        SurfaceLight = true, BloomEffect = true, BlurEffect = true,
        SunRaysEffect = true, ColorCorrectionEffect = true,
        DepthOfFieldEffect = true,
    }

    local function readProperty(instance, property)
        local ok, value = pcall(function() return instance[property] end)
        if not ok then reportError("Read graphics property " .. property, value) end
        return ok, value
    end

    local function writeProperty(instance, property, value)
        local ok, err = pcall(function() instance[property] = value end)
        if not ok then reportError("Restore/apply graphics property " .. property, err) end
        return ok
    end

    local function refreshLighting()
        local desired = {}
        for _, owner in ipairs({ "FixLag", "FullBright" }) do
            for property, value in pairs(lightingLayers[owner] or {}) do
                desired[property] = value
            end
        end
        for property, value in pairs(desired) do
            if lightingOriginals[property] == nil then
                local ok, original = readProperty(Lighting, property)
                if ok then lightingOriginals[property] = original end
            end
            if lightingOriginals[property] ~= nil then writeProperty(Lighting, property, value) end
        end
        for property, original in pairs(lightingOriginals) do
            if desired[property] == nil then
                writeProperty(Lighting, property, original)
                lightingOriginals[property] = nil
            end
        end
    end

    local function fallbackEnemyFolder()
        local folder = Workspace
        for _, name in ipairs(CONFIG.EnemyFolderPath) do
            folder = folder:FindFirstChild(name)
            if not folder then return nil end
        end
        return folder ~= Workspace and folder or nil
    end

    local function isProtected(instance)
        local cursor = instance
        local enemyFolder = fallbackEnemyFolder()
        while cursor and cursor ~= game do
            if cursor == enemyFolder or cursor:IsA("Tool") or cursor:IsA("Terrain")
                or cursor:IsA("GuiBase2d") or cursor:IsA("LayerCollector") then return true end
            if CollectionService:HasTag(cursor, CONFIG.Graphics.ProtectedTag)
                or CollectionService:HasTag(cursor, CONFIG.EnemyTag) then return true end
            for _, tag in ipairs(CONFIG.LootTags) do
                if CollectionService:HasTag(cursor, tag) then return true end
            end
            if cursor:IsA("Model") and (cursor:FindFirstChildOfClass("Humanoid")
                or Players:GetPlayerFromCharacter(cursor)) then return true end
            cursor = cursor.Parent
        end
        return false
    end

    local function isDecoration(instance)
        local cursor = instance
        while cursor and cursor ~= Workspace and cursor ~= Lighting and cursor ~= game do
            if CollectionService:HasTag(cursor, CONFIG.Graphics.DecorationTag) then return true end
            cursor = cursor.Parent
        end
        return false
    end

    local function restoreInstance(instance)
        local scope = instanceScopes[instance]
        if scope then scope:clean(); instanceScopes[instance] = nil end
        local saved = originals[instance]
        if not saved then return end
        if saved.Material ~= nil then writeProperty(instance, "Material", saved.Material) end
        for property, original in pairs(saved) do
            if property ~= "Material" then writeProperty(instance, property, original) end
        end
        originals[instance] = nil
    end

    local function restoreTree(root)
        restoreInstance(root)
        for _, instance in ipairs(root:GetDescendants()) do restoreInstance(instance) end
    end

    local function overridesFor(instance)
        local desired = {}
        if isProtected(instance) then return desired end
        if effectClasses[instance.ClassName] then desired.Enabled = false end
        if instance:IsA("Light") then desired.Shadows = false end
        if instance:IsA("Atmosphere") then
            desired.Density, desired.Haze, desired.Glare = 0, 0, 0
        end
        if not isDecoration(instance) then return desired end
        if instance:IsA("BasePart") then
            -- Changing Material can change physics. Limit it to fixed, non-colliding decoration.
            if instance.Anchored and not instance.CanCollide then
                desired.Material, desired.MaterialVariant = CONFIG.Graphics.SimpleMaterial, ""
            end
            desired.Reflectance, desired.CastShadow = 0, false
        end
        if instance:IsA("Decal") then desired.Transparency = 1 end
        -- Keep the original Content value, including an EditableImage reference.
        if instance:IsA("MeshPart") then desired.TextureContent = Content.none end
        if instance:IsA("SpecialMesh") then desired.TextureId = "" end
        -- SurfaceAppearance has no Enabled property. Preserve these PBR assets intact.
        return desired
    end

    local function inGraphicsWorld(instance)
        return instance:IsDescendantOf(Workspace) or instance:IsDescendantOf(Lighting)
    end

    local function watchInstance(instance)
        if instanceScopes[instance] then return end
        local scope = Scope.new()
        instanceScopes[instance] = scope
        -- AncestryChanged also covers moves between folders under the same Workspace.
        -- Only instances actually changed by this feature receive these connections.
        scope:connect(instance.AncestryChanged, function()
            if not lagEnabled then return end
            if not inGraphicsWorld(instance) or isProtected(instance) then
                cancelQueued(instance)
                restoreInstance(instance)
            else
                enqueue(instance)
            end
        end)
        if instance:IsA("BasePart") then
            local function physicsChanged()
                if lagEnabled then processInstance(instance) end
            end
            scope:connect(instance:GetPropertyChangedSignal("Anchored"), physicsChanged)
            scope:connect(instance:GetPropertyChangedSignal("CanCollide"), physicsChanged)
        end
    end

    processInstance = function(instance)
        if not inGraphicsWorld(instance) then
            restoreInstance(instance)
            return
        end
        local desired = overridesFor(instance)
        local saved = originals[instance] or {}
        if saved.Material ~= nil and desired.Material == nil then
            writeProperty(instance, "Material", saved.Material)
            saved.Material = nil
        end
        for property, original in pairs(saved) do
            if desired[property] == nil then
                writeProperty(instance, property, original)
                saved[property] = nil
            end
        end
        for property, value in pairs(desired) do
            if saved[property] == nil then
                local ok, original = readProperty(instance, property)
                if ok and original ~= value then saved[property] = original end
            end
        end
        if desired.Material ~= nil and saved.Material ~= nil then
            writeProperty(instance, "Material", desired.Material)
        end
        for property, value in pairs(desired) do
            if property ~= "Material" and saved[property] ~= nil then
                writeProperty(instance, property, value)
            end
        end
        originals[instance] = next(saved) and saved or nil
        if originals[instance] then
            watchInstance(instance)
        else
            local scope = instanceScopes[instance]
            if scope then scope:clean(); instanceScopes[instance] = nil end
        end
    end

    enqueue = function(instance)
        if not lagEnabled or queued[instance] then return end
        if not effectClasses[instance.ClassName] and not instance:IsA("Light")
            and not instance:IsA("BasePart") and not instance:IsA("Decal")
            and not instance:IsA("SpecialMesh") and not instance:IsA("Atmosphere") then return end
        queueTail = queueTail + 1
        queued[instance] = queueTail
        queue[queueTail] = instance
    end

    cancelQueued = function(instance)
        local index = queued[instance]
        if not index then return end
        -- Clear the reference immediately, even when a large initial queue is pending.
        queue[index], queued[instance] = false, nil
    end

    local function onDescendantRemoving(instance)
        cancelQueued(instance)
        restoreInstance(instance)
    end

    local function enqueueTree(root)
        enqueue(root)
        for _, instance in ipairs(root:GetDescendants()) do
            if not lagEnabled then return end
            enqueue(instance)
        end
    end

    local function onDescendantAdded(instance)
        if instance:IsA("Humanoid") and instance.Parent then restoreTree(instance.Parent) end
        enqueue(instance)
    end

    local function unwatchPlayer(player)
        local scope = playerScopes[player]
        if scope then scope:clean(); playerScopes[player] = nil end
    end

    local function watchPlayer(player)
        if playerScopes[player] then return end
        local scope = Scope.new()
        playerScopes[player] = scope
        scope:connect(player.CharacterAdded, restoreTree)
        if player.Character then restoreTree(player.Character) end
    end

    local function watchProtectionTags()
        local tags = { CONFIG.Graphics.ProtectedTag, CONFIG.EnemyTag }
        for _, tag in ipairs(CONFIG.LootTags) do tags[#tags + 1] = tag end
        local watched = {}
        for _, tag in ipairs(tags) do
            if not watched[tag] then
                watched[tag] = true
                lagScope:connect(CollectionService:GetInstanceAddedSignal(tag), function(instance)
                    restoreTree(instance)
                end)
                lagScope:connect(CollectionService:GetInstanceRemovedSignal(tag), enqueueTree)
            end
        end
        lagScope:connect(CollectionService:GetInstanceAddedSignal(CONFIG.Graphics.DecorationTag), enqueueTree)
        lagScope:connect(CollectionService:GetInstanceRemovedSignal(CONFIG.Graphics.DecorationTag), enqueueTree)
    end

    local function startLagProcessing()
        lagScope = Scope.new()
        lagScope:connect(Workspace.DescendantAdded, onDescendantAdded)
        lagScope:connect(Lighting.DescendantAdded, onDescendantAdded)
        lagScope:connect(Workspace.DescendantRemoving, onDescendantRemoving)
        lagScope:connect(Lighting.DescendantRemoving, onDescendantRemoving)
        lagScope:connect(Players.PlayerAdded, watchPlayer)
        lagScope:connect(Players.PlayerRemoving, unwatchPlayer)
        for _, player in ipairs(Players:GetPlayers()) do watchPlayer(player) end
        watchProtectionTags()
        enqueueTree(Workspace)
        enqueueTree(Lighting)
    end

    function Graphics.setFixLag(enabled)
        enabled = enabled == true
        if lagEnabled == enabled then return end
        lagEnabled = enabled
        if enabled then
            lightingLayers.FixLag = { GlobalShadows = false, FogStart = 0, FogEnd = CONFIG.Graphics.FogEnd }
            refreshLighting()
            startLagProcessing()
        else
            if lagScope then lagScope:clean(); lagScope = nil end
            for player in pairs(playerScopes) do unwatchPlayer(player) end
            queue, queued, queueHead, queueTail = {}, {}, 1, 0
            for instance in pairs(originals) do restoreInstance(instance) end
            lightingLayers.FixLag = nil
            refreshLighting()
        end
    end

    function Graphics.setFullBright(enabled)
        enabled = enabled == true
        if brightEnabled == enabled then return end
        brightEnabled = enabled
        lightingLayers.FullBright = enabled and {
            Brightness = CONFIG.Graphics.Brightness, Ambient = CONFIG.Graphics.Ambient,
            OutdoorAmbient = CONFIG.Graphics.OutdoorAmbient,
            ExposureCompensation = CONFIG.Graphics.ExposureCompensation, GlobalShadows = false,
        } or nil
        refreshLighting()
    end

    function Graphics.step(_dt)
        if not lagEnabled then return end
        local budget = math.max(1, math.floor(tonumber(CONFIG.Graphics.ProcessBudget) or 100))
        for _ = 1, budget do
            if queueHead > queueTail then
                queue, queued, queueHead, queueTail = {}, {}, 1, 0
                break
            end
            local instance = queue[queueHead]
            queue[queueHead], queueHead = nil, queueHead + 1
            if instance then
                queued[instance] = nil
                processInstance(instance)
            end
        end
    end

    function Graphics.destroy()
        Graphics.setFixLag(false)
        Graphics.setFullBright(false)
    end
end


local ESP = {}
do
    local settings = CONFIG.ESP
    local enabled = false
    local opponentsOnly = settings.HideSameTeam == true
    local featureScope = nil
    local localCharacterScope = nil
    local localCharacter = nil
    local localRoot = nil
    local elapsed = 0
    local records = {}
    local createVisuals, clearVisuals

    local function cleanScope(scope, context)
        if not scope then return end
        local ok, err = pcall(function() scope:clean() end)
        if not ok then reportError("ESP " .. context, err) end
    end

    local function destroyInstance(instance)
        if not instance then return end
        local ok, err = pcall(function() instance:Destroy() end)
        if not ok then reportError("ESP object cleanup", err) end
    end

    local function connect(scope, signal, context, callback)
        local live = true
        scope:add(function() live = false end)
        scope:connect(signal, function(...)
            if not live then return end
            local ok, err = pcall(callback, ...)
            if not ok then reportError("ESP " .. context, err) end
        end)
    end

    local function available(instance, character, excluded)
        return instance ~= nil and instance:IsDescendantOf(character)
            and instance ~= excluded
            and (excluded == nil or not instance:IsDescendantOf(excluded))
    end

    local function findNamedPart(character, name, excluded)
        local part = character:FindFirstChild(name, true)
        if part and part:IsA("BasePart") and available(part, character, excluded) then
            return part
        end
        return nil
    end

    local function findRoot(character, excluded)
        if not character then return nil end
        local root = findNamedPart(character, "HumanoidRootPart", excluded)
        if root then return root end
        local primary = character.PrimaryPart
        if available(primary, character, excluded) then return primary end
        return findNamedPart(character, "Head", excluded)
    end

    local function findHumanoid(character, excluded)
        local humanoid = character:FindFirstChildWhichIsA("Humanoid", true)
        if available(humanoid, character, excluded) then return humanoid end
        if not excluded then return nil end
        for _, descendant in ipairs(character:GetDescendants()) do
            if descendant:IsA("Humanoid") and available(descendant, character, excluded) then
                return descendant
            end
        end
        return nil
    end

    local function isOpponent(player)
        if not opponentsOnly then return true end
        if LocalPlayer.Neutral or player.Neutral then return true end
        return LocalPlayer.Team == nil or player.Team == nil or player.Team ~= LocalPlayer.Team
    end

    local function refreshVisibility(record)
        local character = record.character
        local humanoid = record.humanoid
        local visible = enabled and character ~= nil and humanoid ~= nil
            and character:IsDescendantOf(Workspace) and humanoid.Health > 0
            and record.inRange and isOpponent(record.player)
        visible = visible == true
        if record.highlight and record.highlightVisible ~= visible then
            record.highlight.Enabled = visible
            record.highlightVisible = visible
        end
        if record.billboard then
            local adornee = record.head or record.root
            if record.billboardAdornee ~= adornee then
                record.billboard.Adornee = adornee
                record.billboardAdornee = adornee
            end
            local billboardVisible = visible and adornee ~= nil
            if record.billboardVisible ~= billboardVisible then
                record.billboard.Enabled = billboardVisible
                record.billboardVisible = billboardVisible
            end
        end
    end

    local function refreshDetails(record)
        if not record.detailsLabel then return end
        local details = {}
        if settings.ShowHealth and record.humanoid then
            local health = math.max(0, record.humanoid.Health)
            local maximum = math.max(0, record.humanoid.MaxHealth)
            table.insert(details, string.format("%.0f / %.0f HP", health, maximum))
        end
        if settings.ShowDistance and record.distance then
            table.insert(details, string.format("%.0f studs", record.distance))
        end
        local text, visible = table.concat(details, "  |  "), #details > 0
        if record.detailsText ~= text then
            record.detailsLabel.Text = text
            record.detailsText = text
        end
        if record.detailsVisible ~= visible then
            record.detailsLabel.Visible = visible
            record.detailsVisible = visible
        end
    end

    local function refreshHealth(record)
        local humanoid = record.humanoid
        local usable = enabled and record.character and record.character:IsDescendantOf(Workspace)
            and humanoid and humanoid.Health > 0 and (record.root or record.head)
        if usable then
            if not record.billboard then createVisuals(record) end
        else
            clearVisuals(record)
            record.distance, record.inRange = nil, false
        end
        if record.healthFill and humanoid then
            local ratio = humanoid.MaxHealth > 0 and humanoid.Health / humanoid.MaxHealth or 0
            ratio = math.clamp(ratio, 0, 1)
            if record.healthRatio ~= ratio then
                record.healthFill.Size = UDim2.new(ratio, 0, 1, 0)
                record.healthFill.BackgroundColor3 = settings.LowHealthColor:Lerp(settings.HealthyColor, ratio)
                record.healthRatio = ratio
            end
        end
        refreshDetails(record)
        refreshVisibility(record)
    end

    local function refreshDistance(record)
        record.distance = nil
        record.inRange = false
        if localRoot and record.root and localCharacter
            and localRoot:IsDescendantOf(localCharacter)
            and localCharacter:IsDescendantOf(Workspace)
            and record.character and record.character:IsDescendantOf(Workspace)
            and record.root:IsDescendantOf(record.character)
            and record.humanoid and record.humanoid.Health > 0 then
            record.distance = (localRoot.Position - record.root.Position).Magnitude
            record.inRange = record.distance <= math.max(0, settings.MaxDistance)
        end
        refreshDetails(record)
        refreshVisibility(record)
    end

    local function refreshAllDistances()
        for _, record in pairs(records) do refreshDistance(record) end
    end

    local function refreshAllVisibility()
        for _, record in pairs(records) do refreshVisibility(record) end
    end

    local function refreshName(record)
        if not record.nameLabel then return end
        local player = record.player
        local text = player.DisplayName == player.Name and player.Name
            or player.DisplayName .. " (@" .. player.Name .. ")"
        if record.nameText ~= text then
            record.nameLabel.Text = text
            record.nameText = text
        end
    end

    createVisuals = function(record)
        record.billboard = newInstance("BillboardGui", {
            Name = "ClientUtilityESP", Size = UDim2.fromOffset(settings.BillboardWidth, settings.BillboardHeight),
            StudsOffset = settings.StudsOffset, AlwaysOnTop = true, LightInfluence = 0,
            MaxDistance = math.max(0, settings.MaxDistance), ResetOnSpawn = false, Enabled = false,
        }, PlayerGui)
        record.nameLabel = newInstance("TextLabel", {
            Name = "PlayerName", Size = UDim2.new(1, 0, 0, 23), BackgroundTransparency = 1,
            Font = Enum.Font.GothamSemibold, TextSize = 13, TextColor3 = settings.TextColor,
            TextStrokeTransparency = 0.55, TextTruncate = Enum.TextTruncate.AtEnd,
            Visible = settings.ShowNames, Text = "",
        }, record.billboard)
        record.detailsLabel = newInstance("TextLabel", {
            Name = "HealthAndDistance", Size = UDim2.new(1, 0, 0, 20),
            Position = UDim2.fromOffset(0, settings.ShowNames and 23 or 4), BackgroundTransparency = 1,
            Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = settings.TextColor,
            TextStrokeTransparency = 0.55, TextTruncate = Enum.TextTruncate.AtEnd, Text = "",
        }, record.billboard)
        local bar = newInstance("Frame", {
            Name = "HealthBar", Size = UDim2.new(1, -20, 0, 4), Position = UDim2.new(0, 10, 1, -9),
            BackgroundColor3 = settings.OutlineColor, BackgroundTransparency = 0.75,
            BorderSizePixel = 0, Visible = settings.ShowHealth, ClipsDescendants = true,
        }, record.billboard)
        record.healthFill = newInstance("Frame", {
            Name = "Fill", Size = UDim2.fromScale(0, 1), BackgroundColor3 = settings.HealthyColor,
            BorderSizePixel = 0,
        }, bar)
        record.highlight = newInstance("Highlight", {
            Name = "ClientUtilityESPOutline", Adornee = record.character, Enabled = false,
            DepthMode = Enum.HighlightDepthMode.AlwaysOnTop, FillColor = settings.FillColor,
            OutlineColor = settings.OutlineColor, FillTransparency = settings.FillTransparency,
            OutlineTransparency = settings.OutlineTransparency,
        }, record.character)
        refreshName(record)
    end

    clearVisuals = function(record)
        destroyInstance(record.billboard)
        destroyInstance(record.highlight)
        record.billboard, record.highlight = nil, nil
        record.nameLabel, record.detailsLabel, record.healthFill = nil, nil, nil
        record.nameText, record.detailsText, record.detailsVisible, record.healthRatio = nil, nil, nil, nil
        record.highlightVisible, record.billboardVisible, record.billboardAdornee = nil, nil, nil
    end

    local function clearCharacter(record)
        record.character = nil
        cleanScope(record.healthScope, "health connections cleanup")
        cleanScope(record.characterScope, "character connections cleanup")
        record.healthScope, record.characterScope = nil, nil
        clearVisuals(record)
        record.humanoid, record.root, record.head = nil, nil, nil
        record.distance, record.inRange = nil, false
    end

    local function bindHumanoid(record, humanoid)
        if record.humanoid == humanoid then return end
        cleanScope(record.healthScope, "old health connections cleanup")
        record.healthScope = nil
        record.humanoid = humanoid
        if not humanoid then return end
        local healthScope = Scope.new()
        record.healthScope = healthScope
        local function changed()
            if enabled and record.humanoid == humanoid then
                refreshHealth(record)
                refreshDistance(record)
            end
        end
        connect(healthScope, humanoid.HealthChanged, "health changed", changed)
        connect(healthScope, humanoid.Died, "character died", changed)
        connect(healthScope, humanoid:GetPropertyChangedSignal("MaxHealth"), "maximum health changed", changed)
    end

    local function refreshReferences(record, excluded)
        if not record.character then return end
        if not record.character:IsDescendantOf(Workspace) then
            record.root, record.head = nil, nil
            bindHumanoid(record, nil)
            record.distance, record.inRange = nil, false
            clearVisuals(record)
            return
        end
        record.root = findRoot(record.character, excluded)
        record.head = findNamedPart(record.character, "Head", excluded)
        bindHumanoid(record, findHumanoid(record.character, excluded))
        refreshHealth(record)
        refreshDistance(record)
    end

    local function bindCharacter(record, character)
        clearCharacter(record)
        if not enabled or not character then return end
        record.character = character
        local scope = Scope.new()
        record.characterScope = scope
        local function changed(excluded)
            if enabled and record.character == character then refreshReferences(record, excluded) end
        end
        -- Character events also handle parts arriving or leaving through streaming.
        connect(scope, character.DescendantAdded, "character descendant added", function(instance)
            if instance:IsA("BasePart") or instance:IsA("Humanoid") then changed(nil) end
        end)
        connect(scope, character.DescendantRemoving, "character descendant removing", function(instance)
            if instance:IsA("BasePart") or instance:IsA("Humanoid") then changed(instance) end
        end)
        connect(scope, character:GetPropertyChangedSignal("PrimaryPart"), "character primary part changed", function() changed(nil) end)
        connect(scope, character.AncestryChanged, "character ancestry changed", function() changed(nil) end)
        local ok, err = pcall(function()
            refreshReferences(record, nil)
        end)
        if not ok then
            clearCharacter(record)
            reportError("ESP character setup", err)
        end
    end

    local function removePlayer(player)
        local record = records[player]
        if not record then return end
        records[player] = nil
        cleanScope(record.playerScope, "player connections cleanup")
        clearCharacter(record)
    end

    local function addPlayer(player)
        if not enabled or player == LocalPlayer or records[player] then return end
        local record = { player = player, playerScope = Scope.new(), inRange = false }
        records[player] = record
        connect(record.playerScope, player.CharacterAdded, "player respawn", function(character)
            if enabled and records[player] == record then bindCharacter(record, character) end
        end)
        connect(record.playerScope, player.CharacterRemoving, "player character removing", function(character)
            if record.character == character then clearCharacter(record) end
        end)
        connect(record.playerScope, player:GetPropertyChangedSignal("Team"), "player team changed", function()
            refreshVisibility(record)
        end)
        connect(record.playerScope, player:GetPropertyChangedSignal("Neutral"), "player neutral changed", function()
            refreshVisibility(record)
        end)
        connect(record.playerScope, player:GetPropertyChangedSignal("DisplayName"), "player name changed", function()
            refreshName(record)
        end)
        if player.Character then bindCharacter(record, player.Character) end
    end

    local function refreshLocalRoot(excluded)
        localRoot = localCharacter and localCharacter:IsDescendantOf(Workspace)
            and findRoot(localCharacter, excluded) or nil
        refreshAllDistances()
    end

    local function bindLocalCharacter(character)
        if character and not enabled then return end
        localCharacter, localRoot = nil, nil
        cleanScope(localCharacterScope, "local character connections cleanup")
        localCharacterScope = nil
        localCharacter = character
        if not character then
            refreshAllDistances()
            return
        end
        local scope = Scope.new()
        localCharacterScope = scope
        local function changed(excluded)
            if enabled and localCharacter == character then refreshLocalRoot(excluded) end
        end
        connect(scope, character.DescendantAdded, "local descendant added", function(instance)
            if instance:IsA("BasePart") then changed(nil) end
        end)
        connect(scope, character.DescendantRemoving, "local descendant removing", function(instance)
            if instance:IsA("BasePart") then changed(instance) end
        end)
        connect(scope, character:GetPropertyChangedSignal("PrimaryPart"), "local primary part changed", function() changed(nil) end)
        connect(scope, character.AncestryChanged, "local ancestry changed", function() changed(nil) end)
        refreshLocalRoot(nil)
    end

    local function stop()
        enabled = false
        elapsed = 0
        cleanScope(featureScope, "feature connections cleanup")
        featureScope = nil
        bindLocalCharacter(nil)
        local playersToRemove = {}
        for player in pairs(records) do table.insert(playersToRemove, player) end
        for _, player in ipairs(playersToRemove) do removePlayer(player) end
    end

    local function start()
        enabled = true
        featureScope = Scope.new()
        connect(featureScope, Players.PlayerAdded, "player joined", addPlayer)
        connect(featureScope, Players.PlayerRemoving, "player left", removePlayer)
        connect(featureScope, LocalPlayer.CharacterAdded, "local respawn", bindLocalCharacter)
        connect(featureScope, LocalPlayer.CharacterRemoving, "local character removing", function(character)
            if localCharacter == character then bindLocalCharacter(nil) end
        end)
        connect(featureScope, LocalPlayer:GetPropertyChangedSignal("Team"), "local team changed", refreshAllVisibility)
        connect(featureScope, LocalPlayer:GetPropertyChangedSignal("Neutral"), "local neutral changed", refreshAllVisibility)
        bindLocalCharacter(LocalPlayer.Character)
        for _, player in ipairs(Players:GetPlayers()) do addPlayer(player) end
    end

    function ESP.setEnabled(value)
        local requested = value == true
        if requested == enabled then return enabled end
        if not requested then
            stop()
            return false
        end
        local ok, err = pcall(start)
        if not ok then
            stop()
            reportError("ESP enable", err)
            notify("Player ESP could not start. Check the Output window.", true)
        end
        return enabled
    end

    function ESP.setOpponentsOnly(value)
        opponentsOnly = value == true
        settings.HideSameTeam = opponentsOnly
        refreshAllVisibility()
    end

    function ESP.update(dt)
        if not enabled then return end
        elapsed = elapsed + math.max(0, dt)
        if elapsed < math.max(0.05, settings.UpdateInterval) then return end
        elapsed = 0
        local ok, err = pcall(refreshAllDistances)
        if not ok then reportError("ESP distance update", err) end
    end

    function ESP.destroy()
        stop()
    end
end


-- Official interaction adapters. They request the existing game's behavior only.
-- Tool names must be explicitly configured; no damage or item awards are created here.
local Interactions = {}
do
	local scope = Scope.new()
	local visiblePrompts = setmetatable({}, { __mode = "k" })
	local retryAt = setmetatable({}, { __mode = "k" })
	local toolNames, promptNames = {}, {}
	local mode, heldPrompt, activeTool, now = nil, nil, nil, 0
	local destroyed = false
	local trackedItem, itemScope
	local candidates = {}
	for _, name in ipairs(CONFIG.Combat.ToolNames) do toolNames[name] = true end
	for _, name in ipairs(CONFIG.LootInteraction.PromptNames) do promptNames[name] = true end
	local function inWorld(instance)
		return instance and instance.Parent and instance:IsDescendantOf(Workspace)
	end
	local function ready(requiredMode)
		return not destroyed and State.alive and mode == requiredMode and State.character == LocalPlayer.Character
			and inWorld(State.character) and State.humanoid and State.humanoid.Health > 0
			and State.root and State.root:IsDescendantOf(State.character)
	end
	local function belongsTo(instance, item)
		return instance == item or instance:IsDescendantOf(item)
	end
	local function promptPosition(prompt)
		local parent = prompt.Parent
		if not parent then return nil end
		if parent:IsA("Attachment") then return parent.WorldPosition end
		if parent:IsA("BasePart") then return parent.Position end
		if parent:IsA("Model") and parent.PrimaryPart then return parent.PrimaryPart.Position end
		return nil
	end
	local function eligiblePrompt(prompt, item, requireShown)
		return prompt:IsA("ProximityPrompt") and prompt.Enabled and inWorld(prompt)
			and belongsTo(prompt, item) and (not next(promptNames) or promptNames[prompt.Name])
			and (not requireShown or visiblePrompts[prompt]) and promptPosition(prompt) ~= nil
	end
	local function clearPromptCache()
		if itemScope then itemScope:clean(); itemScope = nil end
		trackedItem = nil
		table.clear(candidates)
	end
	local function trackItem(item)
		if trackedItem == item then return end
		clearPromptCache()
		trackedItem, itemScope = item, Scope.new()
		local function added(instance)
			if instance:IsA("ProximityPrompt") then candidates[instance] = true end
		end
		for _, descendant in ipairs(item:GetDescendants()) do added(descendant) end
		itemScope:connect(item.DescendantAdded, added)
		itemScope:connect(item.DescendantRemoving, function(instance) candidates[instance] = nil end)
		itemScope:connect(item.AncestryChanged, function()
			if not inWorld(item) then clearPromptCache() end
		end)
	end
	local function findPrompt(item, requireShown)
		if not inWorld(item) then return nil end
		trackItem(item)
		local best, shortest
		for descendant in pairs(candidates) do
			if eligiblePrompt(descendant, item, requireShown) then
				local distance = State.root and (State.root.Position - promptPosition(descendant)).Magnitude or 0
				if not shortest or distance < shortest then best, shortest = descendant, distance end
			end
		end
		return best
	end
	local function hasLineOfSight(prompt, item, position)
		if not prompt.RequiresLineOfSight then return true end
		local camera = Workspace.CurrentCamera
		if not camera then return false end
		local origin = camera.CFrame.Position
		local ray = position - origin
		if ray.Magnitude <= 0.01 then return true end
		local parameters = RaycastParams.new()
		parameters.FilterType = Enum.RaycastFilterType.Exclude
		parameters.FilterDescendantsInstances = { State.character }
		local hit = Workspace:Raycast(origin, ray, parameters)
		return hit == nil or belongsTo(hit.Instance, item)
	end
	local function canUsePrompt(prompt, item)
		if not ready("Loot") or not ProximityPromptService.Enabled
			or not eligiblePrompt(prompt, item, true) then return false end
		local position = promptPosition(prompt)
		if (State.root.Position - position).Magnitude > prompt.MaxActivationDistance then return false end
		return hasLineOfSight(prompt, item, position)
	end
	local function releaseTool()
		local record = activeTool
		activeTool = nil
		if record and record.tool.Parent then
			checkedCall("Tool deactivate", function() record.tool:Deactivate() end)
		end
	end
	local function releasePrompt()
		local record = heldPrompt
		heldPrompt = nil
		if record and record.prompt.Parent then
			checkedCall("Prompt hold release", function() record.prompt:InputHoldEnd() end)
		end
	end
	function Interactions.cancel()
		releasePrompt()
		releaseTool()
		clearPromptCache()
	end
	function Interactions.setMode(value)
		if destroyed or mode == value then return end
		Interactions.cancel()
		mode = value
	end
	function Interactions.attack(target)
		if not ready("Farm") or not inWorld(target) or not target:IsA("Model") then return false, "Chờ nhân vật/mục tiêu hợp lệ" end
		local humanoid = target:FindFirstChildOfClass("Humanoid")
		local root = target:FindFirstChild("HumanoidRootPart") or (humanoid and humanoid.RootPart) or target.PrimaryPart
		if not humanoid or humanoid.Health <= 0 or not root or not root:IsA("BasePart") or not root:IsDescendantOf(target) then
			return false, "Mục tiêu không còn sống"
		end
		if (State.root.Position - root.Position).Magnitude > CONFIG.Combat.MaxRange then
			return false, "Mục tiêu ngoài tầm đánh đã cấu hình"
		end
		if not next(toolNames) then return false, "Điền tên Tool vào CONFIG.Combat.ToolNames" end
		local tool
		for _, child in ipairs(State.character:GetChildren()) do
			if child:IsA("Tool") and toolNames[child.Name] then tool = child; break end
		end
		if not tool then return false, "Hãy trang bị Tool chiến đấu đã cấu hình" end
		if not tool.Enabled then return false, "Tool đang tạm khóa" end
		if tool.RequiresHandle and not tool:FindFirstChild("Handle") then return false, "Tool thiếu Handle" end
		if activeTool and activeTool.tool == tool then return true, "Đang kích hoạt Tool" end
		releaseTool()
		activeTool = { tool = tool, releaseAt = now + CONFIG.Combat.TapDuration }
		local ok, err = checkedCall("Tool activate", function() tool:Activate() end)
		if not ok then releaseTool(); return false, tostring(err) end
		return true, "Đã yêu cầu Tool đánh; chờ hệ thống game xử lý"
	end
	function Interactions.lootGoal(item, part)
		if not destroyed and CONFIG.LootInteraction.UseProximityPrompts then
			local prompt = findPrompt(item, false)
			if prompt then return promptPosition(prompt) end
		end
		return part.Position
	end
	function Interactions.lootRange(item)
		if not destroyed and CONFIG.LootInteraction.UseProximityPrompts then
			local prompt = findPrompt(item, false)
			if prompt then return math.min(CONFIG.LootStoppingDistance, math.max(0, prompt.MaxActivationDistance * 0.75)) end
		end
		return CONFIG.LootStoppingDistance
	end
	function Interactions.collect(item)
		if not ready("Loot") or not inWorld(item) then return false, "Loot không còn trong Workspace" end
		if not CONFIG.LootInteraction.UseProximityPrompts then return false, "Cần nối collectLoot với hệ thống loot riêng" end
		if heldPrompt then
			if heldPrompt.item == item then return true, "Đang giữ ProximityPrompt theo HoldDuration" end
			releasePrompt()
		end
		if (retryAt[item] or 0) > now then return false, "Chờ xác nhận hoặc thử lại tương tác loot" end
		local prompt = findPrompt(item, true)
		if not prompt then
			return false, "Chờ ProximityPrompt hiển thị; ClickDetector cần kết nối riêng"
		end
		if not canUsePrompt(prompt, item) then return false, "Prompt chưa hợp lệ, bị che hoặc ngoài tầm" end
		heldPrompt = { prompt = prompt, item = item, startedAt = now, holdDuration = prompt.HoldDuration }
		retryAt[item] = now + math.max(prompt.HoldDuration + CONFIG.LootInteraction.HoldPadding, CONFIG.LootInteraction.RetryDelay)
		local ok, err = checkedCall("Prompt hold begin", function() prompt:InputHoldBegin() end)
		if not ok then releasePrompt(); return false, tostring(err) end
		return true, "Đã bắt đầu tương tác loot; chưa xác nhận đã nhận vật phẩm"
	end
	function Interactions.update(dt)
		if destroyed then return end
		now = now + math.max(0, dt)
		if activeTool and (not ready("Farm") or activeTool.tool.Parent ~= State.character or now >= activeTool.releaseAt) then releaseTool() end
		local record = heldPrompt
		if not record then return end
		if not canUsePrompt(record.prompt, record.item) then releasePrompt(); return end
		record.holdDuration = math.max(record.holdDuration, record.prompt.HoldDuration)
		if now - record.startedAt >= record.holdDuration + CONFIG.LootInteraction.HoldPadding then releasePrompt() end
	end
	function Interactions.destroy()
		if destroyed then return end
		destroyed = true
		Interactions.cancel()
		mode = nil
		scope:clean()
		table.clear(visiblePrompts); table.clear(retryAt)
	end
	scope:connect(ProximityPromptService.PromptShown, function(prompt) visiblePrompts[prompt] = true end)
	scope:connect(ProximityPromptService.PromptHidden, function(prompt)
		visiblePrompts[prompt] = nil
		if heldPrompt and heldPrompt.prompt == prompt then releasePrompt() end
	end)
	scope:connect(ProximityPromptService.PromptTriggered, function(prompt, player)
		if player == LocalPlayer and heldPrompt and heldPrompt.prompt == prompt then
			-- The engine accepted prompt input; only the game's system can confirm an award.
			releasePrompt()
		end
	end)
end


-- Interaction adapters use the game's existing client entry points and never award
-- damage or loot locally. Keep these delegates non-yielding.
local function attackTarget(target)
	return Interactions.attack(target)
end

local function collectLoot(item)
	return Interactions.collect(item)
end

local Automation = {}
do
	local cacheScope = Scope.new()
	local folderScope = Scope.new()
	local taggedEnemies, enemyWatchers, folderEnemies, lootMembership = {}, {}, {}, {}
	local lootTagSet, enemyFolder = {}, nil
	local useTaggedEnemies, sourceDirty, destroyed = false, true, false
	local activeMode, target, targetSource, targetPart, lootDirection, motion, noclipOwner
	local elapsed, nextCacheAt, nextSearchAt, nextReplanAt, nextHookAt = 0, 0, 0, 0, 0
	local generation, lastHookStatus = 0, nil
	local retryUntil, retryStatus = 0, nil
	local tuning = CONFIG.Motion or {}
	local lastStatus = {}

	local function motionSetting(name, fallback, minimum)
		local value = tuning[name]
		if type(value) ~= "number" or value ~= value or math.abs(value) == math.huge then value = fallback end
		return math.max(minimum, value)
	end

	local function maxGoalLead()
		return math.max(CONFIG.ArrivalTolerance + 0.1, motionSetting("MaxGoalLead", 12, 0.1))
	end

	local function status(mode, message)
		if mode and lastStatus[mode] ~= message then
			lastStatus[mode] = message
			onAutomationStatus(mode, message)
		end
	end

	local function searchInterval()
		return math.max(0.1, CONFIG.TargetSearchInterval)
	end

	local function present(instance)
		return instance ~= nil and instance.Parent ~= nil and instance:IsDescendantOf(Workspace)
	end

	local function npcParts(model)
		if not present(model) or not model:IsA("Model") then return nil, nil end
		local humanoid = model:FindFirstChildOfClass("Humanoid")
		if not humanoid then return nil, nil end
		local root = model:FindFirstChild("HumanoidRootPart")
		if not root or not root:IsA("BasePart") then root = humanoid.RootPart end
		if not root or not root:IsDescendantOf(model) then root = model.PrimaryPart end
		if not root or not root:IsA("BasePart") or not root:IsDescendantOf(model) then
			return humanoid, nil
		end
		return humanoid, root
	end

	local function lootPart(item)
		if not present(item) then return nil end
		if item:IsA("BasePart") then return item end
		if not item:IsA("Model") then return nil end
		local part = item.PrimaryPart
		if not part or not part:IsA("BasePart") or not part:IsDescendantOf(item) then
			part = item:FindFirstChildWhichIsA("BasePart", true)
		end
		return part
	end

	local function addEnemy(instance)
		if not instance:IsA("Model") or taggedEnemies[instance] then return end
		taggedEnemies[instance] = true
		local watcher = Scope.new()
		enemyWatchers[instance] = watcher
		watcher:connect(instance.AncestryChanged, function() sourceDirty = true; nextSearchAt = 0 end)
		sourceDirty = true
		nextSearchAt = 0
	end

	local function removeEnemy(instance)
		taggedEnemies[instance] = nil
		local watcher = enemyWatchers[instance]
		enemyWatchers[instance] = nil
		if watcher then watcher:clean() end
		sourceDirty = true
		nextSearchAt = 0
	end

	local function refreshEnemySource()
		if not sourceDirty then return end
		sourceDirty = false
		useTaggedEnemies = false
		for instance in pairs(taggedEnemies) do
			if present(instance) then useTaggedEnemies = true; break end
		end
	end

	local function resolveEnemyFolder()
		local path = CONFIG.EnemyFolderPath
		if type(path) ~= "table" or #path == 0 then return nil end
		local folder = Workspace
		for _, name in ipairs(path) do
			folder = folder:FindFirstChild(name)
			if not folder then return nil end
		end
		return folder ~= Workspace and folder or nil
	end

	local function discoverEnemyFolder()
		local folder = resolveEnemyFolder()
		if folder == enemyFolder then return end
		folderScope:clean()
		folderScope = Scope.new()
		enemyFolder, folderEnemies = folder, {}
		if not folder then return end
		if folder:IsA("Model") then folderEnemies[folder] = true end
		for _, instance in ipairs(folder:GetDescendants()) do
			if instance:IsA("Model") then folderEnemies[instance] = true end
		end
		folderScope:connect(folder.DescendantAdded, function(instance)
			if instance:IsA("Model") then folderEnemies[instance] = true; nextSearchAt = 0 end
		end)
		folderScope:connect(folder.DescendantRemoving, function(instance)
			folderEnemies[instance] = nil
		end)
	end

	local function addLoot(item, tag)
		local tags = lootMembership[item]
		if not tags then tags = {}; lootMembership[item] = tags end
		tags[tag] = true
		nextSearchAt = 0
	end

	local function removeLoot(item, tag)
		local tags = lootMembership[item]
		if not tags then return end
		tags[tag] = nil
		if next(tags) == nil then lootMembership[item] = nil end
		nextSearchAt = 0
	end

	local function matchesLoot(item)
		local tags = lootMembership[item]
		if not tags then return false end
		for tag in pairs(tags) do
			if State.lootTypes[tag] == true then return true end
		end
		return false
	end

	function Automation.validate(mode)
		if mode == "Farm" then
			if type(State.enemyType) ~= "string" or State.enemyType == "" then
				return false, "Select an enemy type first"
			end
			return true
		elseif mode == "Loot" then
			for tag in pairs(lootTagSet) do
				if State.lootTypes[tag] == true then return true end
			end
			return false, "Select at least one loot type first"
		end
		return false, "Unknown automatic movement mode"
	end

	local function characterReady()
		local character, humanoid, root = State.character, State.humanoid, State.root
		if not State.alive or not character or LocalPlayer.Character ~= character then
			return false, "Waiting for character to respawn"
		end
		if not humanoid or not root or not root:IsA("BasePart") then
			return false, "Waiting for character to respawn"
		end
		if not present(character) or not humanoid:IsDescendantOf(character)
			or not root:IsDescendantOf(character) or humanoid.Health <= 0 then
			return false, "Waiting for character to respawn"
		end
		if root.Anchored then return false, "Waiting for character root to be unanchored" end
		if humanoid.SeatPart or humanoid.Sit then return false, "Stand up to resume automatic movement" end
		return true
	end

	local function requestNoclip(enabled)
		if noclipOwner and (not enabled or noclipOwner ~= activeMode) then
			setNoclipRequest(noclipOwner, false)
			noclipOwner = nil
		end
		if enabled and activeMode and noclipOwner ~= activeMode then
			setNoclipRequest(activeMode, true)
			noclipOwner = activeMode
		end
	end

	local function cancelPath(movement)
		movement.tween, movement.pathActive = nil, false
		local scope = movement.pathScope
		movement.pathScope = nil
		if scope then scope:clean() end
	end

	local function releaseMotion()
		local movement = motion
		motion = nil
		if movement then cancelPath(movement); movement.scope:clean() end
	end

	local function clearTarget()
		generation = generation + 1
		local cancelled, cancelError = pcall(Interactions.cancel)
		requestNoclip(false)
		releaseMotion()
		target, targetSource, targetPart, lootDirection = nil, nil, nil, nil
		lastHookStatus = nil
		retryUntil, retryStatus = 0, nil
		nextSearchAt, nextReplanAt, nextHookAt = 0, 0, 0
		if not cancelled then reportError("Interaction cancellation", cancelError) end
	end

	local function pauseAndRetry(message, context, err)
		clearTarget()
		retryUntil = elapsed + motionSetting("RetryDelay", 2, 0.1)
		nextSearchAt, retryStatus = retryUntil, message
		status(activeMode, message)
		if context then reportError(context, err) end
	end

	local function ownInstance(movement, className, properties, parent)
		local instance = newInstance(className, properties, parent)
		movement.scope:add(function() instance:Destroy() end)
		return instance
	end

	local function createMotion()
		local movement = {
			scope = Scope.new(), root = State.root, humanoid = State.humanoid,
			progressPosition = State.root.Position, lastProgressAt = elapsed,
		}
		motion = movement
		local ok, err = pcall(function()
			local originalAutoRotate = movement.humanoid.AutoRotate
			movement.scope:add(function()
				if movement.humanoid.Parent then movement.humanoid.AutoRotate = originalAutoRotate end
			end)
			movement.humanoid.AutoRotate = false
			movement.attachment = ownInstance(movement, "Attachment", {Name = "UtilityMovementAttachment"}, movement.root)
			movement.goal = ownInstance(movement, "CFrameValue", {Value = movement.root.CFrame}, nil)
			movement.position = ownInstance(movement, "AlignPosition", {
				Name = "UtilityMovementPosition", Mode = Enum.PositionAlignmentMode.OneAttachment,
				Attachment0 = movement.attachment, Position = movement.root.Position,
				ApplyAtCenterOfMass = true, ReactionForceEnabled = false, RigidityEnabled = false,
				MaxForce = CONFIG.FollowMaxForce, MaxVelocity = math.max(CONFIG.FollowMaxVelocity, CONFIG.TweenSpeed),
				Responsiveness = CONFIG.FollowResponsiveness,
			}, movement.root)
			movement.orientation = ownInstance(movement, "AlignOrientation", {
				Name = "UtilityMovementOrientation", Mode = Enum.OrientationAlignmentMode.OneAttachment,
				Attachment0 = movement.attachment, CFrame = movement.root.CFrame - movement.root.Position,
				ReactionTorqueEnabled = false, RigidityEnabled = false,
				MaxTorque = CONFIG.FollowMaxTorque, Responsiveness = CONFIG.FollowResponsiveness,
			}, movement.root)
		end)
		if not ok then releaseMotion() end
		return ok, err
	end

	local function faceTarget(movement, lookPosition)
		local position = movement.root.Position
		local offset = lookPosition - position
		local direction = Vector3.new(offset.X, 0, offset.Z)
		if direction.Magnitude >= 0.05 then
			movement.heading = direction.Unit
		elseif not movement.heading then
			local heading = movement.root.CFrame.LookVector
			direction = Vector3.new(heading.X, 0, heading.Z)
			if direction.Magnitude < 0.001 then direction = Vector3.new(0, 0, -1) end
			movement.heading = direction.Unit
		end
		return CFrame.lookAt(position, position + movement.heading)
	end

	local function lootPointAndRange(part, item)
		item = item or target
		local point = Interactions.lootGoal and Interactions.lootGoal(item, part) or nil
		if typeof(point) ~= "Vector3" or point.X ~= point.X or point.Y ~= point.Y or point.Z ~= point.Z
			or math.abs(point.X) == math.huge or math.abs(point.Y) == math.huge or math.abs(point.Z) == math.huge then
			point = part.Position
		end
		local range = Interactions.lootRange and Interactions.lootRange(item) or CONFIG.LootStoppingDistance
		if type(range) ~= "number" or range ~= range or math.abs(range) == math.huge then range = CONFIG.LootStoppingDistance end
		return point, math.clamp(range, 0, math.max(0, CONFIG.LootStoppingDistance))
	end

	local function desiredPosition(part)
		if activeMode == "Farm" then return part.Position + Vector3.new(0, CONFIG.EnemyHeight, 0), part.Position end
		local point, stop = lootPointAndRange(part)
		local margin = math.min(math.max(0.1, CONFIG.ArrivalTolerance * 0.5), stop * 0.2)
		return point + lootDirection * math.max(0, stop - margin), point
	end

	local function arrivalTolerance(part)
		if activeMode ~= "Loot" then return CONFIG.ArrivalTolerance end
		local _, range = lootPointAndRange(part)
		-- Small prompts require a tighter physical arrival than the general farm
		-- tolerance; otherwise a blocked character could wait just outside range.
		return math.min(CONFIG.ArrivalTolerance, math.max(0.05, range * 0.2))
	end

	local function startPath(destination)
		local movement = motion
		cancelPath(movement)
		movement.following = false
		if not movement.finalDestination or (destination - movement.finalDestination).Magnitude >= math.max(0.1, CONFIG.RetargetDistance) then
			movement.arrivalDeadline = nil
		end
		movement.finalDestination = destination
		-- Continue from the current goal. Resetting to a lagging physical root on
		-- every segment causes the goal to jump backwards and never converge.
		local origin = movement.goal.Value.Position
		local delta = destination - origin
		local speed = math.max(0.1, CONFIG.TweenSpeed)
		local distance = delta.Magnitude
		local availableLead = math.max(0, maxGoalLead() - (origin - movement.root.Position).Magnitude)
		if distance <= CONFIG.ArrivalTolerance and (destination - movement.root.Position).Magnitude <= maxGoalLead() then
			movement.goal.Value = CFrame.new(destination)
			movement.arrivalDeadline = movement.arrivalDeadline or elapsed + motionSetting("ArrivalGrace", 1.5, 0.1)
			return true
		end
		local length = math.min(distance, speed * math.max(0.01, CONFIG.MaxTweenDuration), availableLead)
		if length <= 0.001 then return true end -- Keep the goal still while physics catches up.
		local endpoint = origin + delta.Unit * length
		movement.endpoint = endpoint
		local pathScope = Scope.new()
		movement.pathScope = pathScope
		local ok, err = pcall(function()
			local tween = TweenService:Create(movement.goal, TweenInfo.new(length / speed, Enum.EasingStyle.Linear), {
				Value = CFrame.new(endpoint),
			})
			movement.tween, movement.pathActive = tween, true
			pathScope:add(function() tween:Cancel(); tween:Destroy() end)
			pathScope:connect(tween.Completed, function()
				if motion == movement and movement.tween == tween then
					movement.pathActive = false
					if length >= distance - 0.001 then
						movement.arrivalDeadline = movement.arrivalDeadline or elapsed + motionSetting("ArrivalGrace", 1.5, 0.1)
					end
				end
			end)
			tween:Play()
		end)
		if not ok then cancelPath(movement) end
		return ok, err
	end

	local function validEnemy(model, source)
		if not model or model.Name ~= State.enemyType then return nil end
		if source == "Tagged" then
			if not useTaggedEnemies or not taggedEnemies[model] then return nil end
		else
			if useTaggedEnemies or not enemyFolder or not folderEnemies[model] then return nil end
			if model ~= enemyFolder and not model:IsDescendantOf(enemyFolder) then return nil end
		end
		local humanoid, root = npcParts(model)
		if humanoid and root and humanoid.Health > 0 then return root end
		return nil
	end

	local function currentTargetPart()
		if activeMode == "Farm" then return validEnemy(target, targetSource) end
		if target and matchesLoot(target) then return lootPart(target) end
		return nil
	end

	local function nearestEnemy()
		local candidates = useTaggedEnemies and taggedEnemies or folderEnemies
		local source = useTaggedEnemies and "Tagged" or "Folder"
		local best, bestPart, bestDistance
		for candidate in pairs(candidates) do
			local part = validEnemy(candidate, source)
			if part then
				local offset = State.root.Position - part.Position
				local distance = offset:Dot(offset)
				if not bestDistance or distance < bestDistance then best, bestPart, bestDistance = candidate, part, distance end
			end
		end
		return best, bestPart, source
	end

	local function nearestLoot()
		local best, bestPart, bestDistance
		for candidate in pairs(lootMembership) do
			local part = matchesLoot(candidate) and lootPart(candidate) or nil
			if part then
				local point = lootPointAndRange(part, candidate)
				local offset = State.root.Position - point
				local distance = offset:Dot(offset)
				if not bestDistance or distance < bestDistance then best, bestPart, bestDistance = candidate, part, distance end
			end
		end
		return best, bestPart, "Loot"
	end

	local function acquireTarget()
		if activeMode == "Farm" then target, targetPart, targetSource = nearestEnemy()
		else target, targetPart, targetSource = nearestLoot() end
		if not target then return false end
		if activeMode == "Loot" then
			local point = lootPointAndRange(targetPart)
			local direction = State.root.Position - point
			lootDirection = direction.Magnitude > 0.001 and direction.Unit or Vector3.new(0, 0, 1)
		end
		local created, createError = createMotion()
		if not created then pauseAndRetry("Movement setup failed; retrying shortly", "Automatic movement setup", createError); return false end
		nextReplanAt = elapsed + searchInterval()
		local started, pathError = startPath(desiredPosition(targetPart))
		if started then requestNoclip(true)
		else pauseAndRetry("Movement failed; retrying shortly", "Automatic movement tween", pathError) end
		return started
	end

	local function updateMotion(part)
		local movement = motion
		local destination, lookPosition = desiredPosition(part)
		local remaining = (movement.root.Position - destination).Magnitude
		local tolerance = arrivalTolerance(part)
		local shouldReplan = elapsed >= nextReplanAt
		if shouldReplan then nextReplanAt = elapsed + searchInterval() end
		if remaining <= tolerance then
			if not movement.following then cancelPath(movement) end
			movement.following, movement.arrivalDeadline = true, nil
			movement.lastProgressAt, movement.progressPosition = elapsed, movement.root.Position
		end
		if movement.following then
			if shouldReplan and remaining > math.max(CONFIG.RetargetDistance, tolerance * 2) then
				local started, err = startPath(destination)
				if not started then return remaining, "Movement failed; retrying shortly", err end
			elseif remaining <= maxGoalLead() then
				movement.goal.Value = CFrame.new(destination)
			end
		else
			local drift = (destination - movement.finalDestination).Magnitude
			-- Segment continuation is independent of target search throttling. A
			-- short MaxTweenDuration must not insert one search interval of idle
			-- time between every segment and reduce the configured travel speed.
			if (shouldReplan and drift >= math.max(0.1, CONFIG.RetargetDistance))
				or (not movement.pathActive and not movement.arrivalDeadline) then
				local started, err = startPath(destination)
				if not started then return remaining, "Movement failed; retrying shortly", err end
			end
		end
		movement.position.Position = movement.goal.Value.Position
		movement.orientation.CFrame = faceTarget(movement, lookPosition)

		-- Only physical progress towards the commanded goal refreshes the stall
		-- timer; a completed goal tween does not prove the character moved.
		local displacement = movement.root.Position - movement.progressPosition
		local heading = movement.goal.Value.Position - movement.progressPosition
		local epsilon = motionSetting("ProgressEpsilon", 0.35, 0.01)
		if displacement.Magnitude >= epsilon and heading.Magnitude > 0.001 and displacement:Dot(heading.Unit) >= epsilon then
			movement.progressPosition, movement.lastProgressAt = movement.root.Position, elapsed
		end
		if remaining > tolerance then
			if movement.arrivalDeadline and elapsed >= movement.arrivalDeadline then
				return remaining, "Character could not reach the goal; retrying shortly"
			end
			if elapsed - movement.lastProgressAt >= motionSetting("StallTimeout", 5, 0.1) then
				return remaining, "Movement blocked or corrected by server; retrying shortly"
			end
		end
		return remaining
	end

	local function runHook(part, remaining)
		local closeEnough = remaining <= CONFIG.ArrivalTolerance
		if activeMode == "Loot" then
			local point, range = lootPointAndRange(part)
			closeEnough = (State.root.Position - point).Magnitude <= range
		end
		if not closeEnough or elapsed < nextHookAt then return end
		nextHookAt = elapsed + math.max(0.1, activeMode == "Farm" and CONFIG.AttackInterval or CONFIG.CollectInterval)
		local currentGeneration, currentMode, currentTarget = generation, activeMode, target
		local hook = currentMode == "Farm" and attackTarget or collectLoot
		local ok, accepted, message = pcall(hook, currentTarget)
		if currentGeneration ~= generation or activeMode ~= currentMode or target ~= currentTarget then return end
		if not ok then
			pauseAndRetry(currentMode == "Farm" and "Combat adapter failed; retrying shortly" or "Loot adapter failed; retrying shortly",
				currentMode .. " integration hook", accepted)
		elseif type(message) == "string" and message ~= "" then lastHookStatus = message
		elseif accepted == true then
			lastHookStatus = currentMode == "Farm" and "Combat interaction requested" or "Loot interaction requested; waiting for removal"
		else lastHookStatus = currentMode == "Farm" and "Combat hook did not request an attack" or "Loot hook did not request collection" end
	end

	function Automation.setMode(mode)
		if destroyed or activeMode == mode then return end
		local oldMode = activeMode
		requestNoclip(false)
		clearTarget()
		activeMode = mode
		Interactions.setMode(mode)
		if oldMode then status(oldMode, "Off") end
		if mode then
			local ready, message = characterReady()
			status(mode, ready and "Searching..." or message)
		end
	end

	function Automation.selectionChanged()
		clearTarget()
		if not activeMode then return end
		local valid, message = Automation.validate(activeMode)
		if not valid then requestNoclip(false) end
		status(activeMode, valid and "Searching..." or message)
	end

	function Automation.onCharacterChanged()
		clearTarget()
		requestNoclip(false)
		if activeMode then status(activeMode, "Waiting for character to respawn") end
	end

	function Automation.getEnemyTypes()
		if destroyed then return {} end
		discoverEnemyFolder()
		refreshEnemySource()
		local names, result = {}, {}
		local candidates = useTaggedEnemies and taggedEnemies or folderEnemies
		for model in pairs(candidates) do
			local eligible = useTaggedEnemies or model:FindFirstChildOfClass("Humanoid") ~= nil
			if eligible and present(model) and (useTaggedEnemies or model == enemyFolder or model:IsDescendantOf(enemyFolder)) then
				if not names[model.Name] then names[model.Name] = true; table.insert(result, model.Name) end
			end
		end
		table.sort(result, function(a, b) if a:lower() == b:lower() then return a < b end; return a:lower() < b:lower() end)
		return result
	end

	local function waitingStatus()
		return activeMode == "Farm" and "Waiting for enemy to spawn" or "Waiting for loot to spawn"
	end

	function Automation.update(dt)
		if destroyed then return end
		elapsed = elapsed + math.max(0, dt)
		if not activeMode then return end
		if elapsed >= nextCacheAt then
			nextCacheAt = elapsed + searchInterval()
			discoverEnemyFolder()
		end
		refreshEnemySource()
		local valid, message = Automation.validate(activeMode)
		if valid then valid, message = characterReady() end
		if not valid then
			if target or motion then clearTarget() end
			requestNoclip(false)
			status(activeMode, message)
			return
		end
		if motion and (motion.root ~= State.root or motion.humanoid ~= State.humanoid) then clearTarget() end
		local part = target and currentTargetPart() or nil
		if target and not part then clearTarget() end
		if not target and elapsed >= retryUntil and elapsed >= nextSearchAt then
			nextSearchAt = elapsed + searchInterval()
			retryStatus = nil
			local ok, err = pcall(acquireTarget)
			if not ok then pauseAndRetry("Target setup failed; retrying shortly", "Automatic target setup", err) end
			part = targetPart
		end
		if not target or not motion then requestNoclip(false); status(activeMode, retryStatus or waitingStatus()); return end
		targetPart = part
		local ok, remaining, failure, motionError = pcall(updateMotion, part)
		if not ok then pauseAndRetry("Movement failed; retrying shortly", "Automatic movement update", remaining); return end
		if failure then
			pauseAndRetry(failure, motionError and "Automatic movement tween" or nil, motionError)
			return
		end
		local hookOk, hookError = pcall(runHook, part, remaining)
		if not hookOk then pauseAndRetry("Interaction adapter failed; retrying shortly", "Automatic interaction update", hookError); return end
		if not target then return end
		if currentTargetPart() == nil then clearTarget(); status(activeMode, waitingStatus()); return end
		local text = lastHookStatus or (remaining <= CONFIG.ArrivalTolerance and "Following " or "Moving to ") .. target.Name
		status(activeMode, text)
	end

	function Automation.destroy()
		if destroyed then return end
		destroyed = true
		requestNoclip(false)
		clearTarget()
		activeMode = nil
		Interactions.setMode(nil)
		cacheScope:clean()
		folderScope:clean()
		for _, watcher in pairs(enemyWatchers) do watcher:clean() end
		taggedEnemies, enemyWatchers, folderEnemies, lootMembership = {}, {}, {}, {}
	end

	for _, instance in ipairs(CollectionService:GetTagged(CONFIG.EnemyTag)) do addEnemy(instance) end
	cacheScope:connect(CollectionService:GetInstanceAddedSignal(CONFIG.EnemyTag), addEnemy)
	cacheScope:connect(CollectionService:GetInstanceRemovedSignal(CONFIG.EnemyTag), removeEnemy)
	for _, configuredTag in ipairs(CONFIG.LootTags) do
		local tag = configuredTag
		if not lootTagSet[tag] then
			lootTagSet[tag] = true
			for _, item in ipairs(CollectionService:GetTagged(tag)) do addLoot(item, tag) end
			cacheScope:connect(CollectionService:GetInstanceAddedSignal(tag), function(item) addLoot(item, tag) end)
			cacheScope:connect(CollectionService:GetInstanceRemovedSignal(tag), function(item) removeLoot(item, tag) end)
		end
	end
	status("Farm", "Off")
	status("Loot", "Off")
	discoverEnemyFolder()
	refreshEnemySource()
end


local UI = {}
do
	local colors, labels = CONFIG.UI, CONFIG.UI.Labels or {}
	local function text(key, fallback) return labels[key] or fallback end
	local toggles, statusLabels, controls, tabs, cards = {}, {}, {}, {}, {}
	local setFeature, stopFeatures
	local interaction, dropdownScope, optionScope, dropdownState
	local pointerInputs = {}
	local dropdown, outside, searchBox, optionsList
	local collapsed, visible, destroyed, activeTab = false, true, false, "Graphics"
	local currentNotice, noticeUntil, refreshElapsed = nil, 0, 0
	local noticeQueue = {}
	local tabHeight = colors.TabHeight or 36
	local touchThreshold = colors.TouchDragThreshold or 8
	local surface = newInstance("Frame", {
		Name = "SafeSurface", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
	}, Gui)
	local panel = newInstance("Frame", {
		Name = "Panel", Position = UDim2.fromOffset(colors.Margin, colors.Margin),
		Size = UDim2.fromOffset(colors.Width, colors.Height),
		BackgroundColor3 = colors.Background, BorderSizePixel = 0,
	}, surface)
	local function round(parent, radius)
		newInstance("UICorner", { CornerRadius = UDim.new(0, radius or 8) }, parent)
	end
	local function label(parent, content, properties)
		local props = {
			BackgroundTransparency = 1, Text = content, TextColor3 = colors.Text,
			Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, BorderSizePixel = 0,
		}
		for key, value in pairs(properties or {}) do props[key] = value end
		return newInstance("TextLabel", props, parent)
	end
	local function button(parent, content, properties)
		local props = {
			Text = content, TextColor3 = colors.Text, Font = Enum.Font.GothamMedium,
			TextSize = 13, BackgroundColor3 = colors.Card, BorderSizePixel = 0, AutoButtonColor = true,
		}
		for key, value in pairs(properties or {}) do props[key] = value end
		local instance = newInstance("TextButton", props, parent)
		round(instance, 7)
		return instance
	end
	round(panel, 12)
	newInstance("UIStroke", { Color = colors.Muted, Transparency = 0.8 }, panel)
	local header = newInstance("Frame", {
		Size = UDim2.new(1, 0, 0, colors.HeaderHeight), BackgroundTransparency = 1,
	}, panel)
	local dragHandle = label(header, "  " .. text("Title", "MrDon Utility"), {
		Name = "DragHandle", Size = UDim2.new(1, -92, 1, 0), Active = true,
		Font = Enum.Font.GothamBold, TextSize = 15,
	})
	local minimize = button(header, "−", {
		Name = "Minimize", Position = UDim2.new(1, -86, 0, 5), Size = UDim2.fromOffset(38, 34), TextSize = 20,
	})
	local close = button(header, "×", {
		Name = "Close", Position = UDim2.new(1, -44, 0, 5), Size = UDim2.fromOffset(38, 34), TextSize = 20,
	})
	local tabBar = newInstance("Frame", {
		Name = "Tabs", Position = UDim2.fromOffset(10, colors.HeaderHeight),
		Size = UDim2.new(1, -20, 0, tabHeight), BackgroundTransparency = 1,
	}, panel)
	newInstance("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder,
	}, tabBar)
	local body = newInstance("ScrollingFrame", {
		Name = "Features", Position = UDim2.fromOffset(0, colors.HeaderHeight + tabHeight + 8),
		Size = UDim2.new(1, 0, 1, -colors.HeaderHeight - tabHeight - 14), BackgroundTransparency = 1,
		BorderSizePixel = 0, ScrollBarThickness = 4, ScrollBarImageColor3 = colors.Accent,
		CanvasSize = UDim2.fromOffset(0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y, ScrollingEnabled = true,
	}, panel)
	newInstance("UIPadding", {
		PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
	}, body)
	newInstance("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, body)
	local launcher = button(surface, text("Launcher", "Utility"), {
		Name = "OpenMenu", AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -12, 1, -12),
		Size = UDim2.fromOffset(82, 40), BackgroundColor3 = colors.Accent,
	})
	local notice = label(surface, "", {
		Name = "Notification", AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -12, 1, -62), Size = UDim2.fromOffset(colors.Width, 70),
		BackgroundTransparency = 0.04, BackgroundColor3 = colors.Card,
		TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 40, Visible = false,
	})
	round(notice)
	newInstance("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, notice)
	local function showNotice(item)
		currentNotice = item
		notice.Text, notice.Visible = item.message, true
		notice.TextColor3 = item.isError and colors.Error or colors.Success
		noticeUntil = os.clock() + colors.NotificationSeconds
	end
	notifySink = function(message, isError)
		if destroyed then return end
		if currentNotice and currentNotice.message == message and currentNotice.isError == isError then return end
		for _, item in ipairs(noticeQueue) do
			if item.message == message and item.isError == isError then return end
		end
		local item = { message = message, isError = isError }
		if not currentNotice then showNotice(item); return end
		local limit = math.max(1, math.floor(colors.NotificationLimit or 4))
		if limit == 1 then
			if isError and not currentNotice.isError then showNotice(item) end
			return
		end
		if #noticeQueue >= limit - 1 then
			local discard
			for index, queued in ipairs(noticeQueue) do
				if not queued.isError then discard = index; break end
			end
			if not discard and isError and #noticeQueue > 0 then discard = 1 end
			if not discard then return end
			table.remove(noticeQueue, discard)
		end
		if isError then
			local insertAt = #noticeQueue + 1
			for index, queued in ipairs(noticeQueue) do
				if not queued.isError then insertAt = index; break end
			end
			table.insert(noticeQueue, insertAt, item)
		else
			table.insert(noticeQueue, item)
		end
	end
	local function cancelEdits()
		for _, control in ipairs(controls) do control.cancelEdit() end
	end
	local function finishInteraction(cancelled, endX)
		local previous = interaction
		interaction = nil
		if not previous then return end
		if previous.scrollEnabled ~= nil then body.ScrollingEnabled = previous.scrollEnabled end
		if not cancelled and previous.kind == "sliderPending" and visible and not collapsed then
			previous.control.setFromX(endX or previous.origin.X)
		end
	end
	local function closeDropdown()
		if optionScope then optionScope:clean(); optionScope = nil end
		if dropdownScope then dropdownScope:clean(); dropdownScope = nil end
		local previousSearch = searchBox
		dropdownState, searchBox, optionsList = nil, nil, nil
		if previousSearch and previousSearch:IsFocused() then previousSearch:ReleaseFocus(false) end
		if dropdown then dropdown:Destroy() end
		if outside then outside:Destroy() end
		dropdown, outside = nil, nil
	end
	-- Use the reported keyboard rectangle rather than assuming a keyboard height.
	local function availableSize()
		local size, origin = surface.AbsoluteSize, surface.AbsolutePosition
		local height = size.Y
		if UserInputService.OnScreenKeyboardVisible then
			local keyboardSize, keyboardPosition = UserInputService.OnScreenKeyboardSize, UserInputService.OnScreenKeyboardPosition
			if keyboardSize.X > 0 and keyboardSize.Y > 0
				and keyboardPosition.X < origin.X + size.X and keyboardPosition.X + keyboardSize.X > origin.X
				and keyboardPosition.Y < origin.Y + height and keyboardPosition.Y + keyboardSize.Y > origin.Y then
				height = math.clamp(keyboardPosition.Y - origin.Y, 0, height)
			end
		end
		return Vector2.new(size.X, height)
	end
	local function clampPanel()
		local available = availableSize()
		local width = math.max(1, math.min(colors.Width, available.X - colors.Margin * 2))
		local minimum = collapsed and colors.HeaderHeight or colors.HeaderHeight + tabHeight + 28
		local height = math.max(1, math.min(collapsed and colors.HeaderHeight or colors.Height, available.Y - colors.Margin * 2))
		panel.Size = UDim2.fromOffset(width, height)
		tabBar.Visible = not collapsed and height >= minimum
		body.Visible = not collapsed and height >= minimum
		local x = math.clamp(panel.Position.X.Offset, 0, math.max(0, available.X - width))
		local y = math.clamp(panel.Position.Y.Offset, 0, math.max(0, available.Y - height))
		panel.Position = UDim2.fromOffset(x, y)
		notice.Size = UDim2.fromOffset(math.max(1, math.min(colors.Width, surface.AbsoluteSize.X - 24)), 70)
		notice.Position = UDim2.fromOffset(math.max(0, surface.AbsoluteSize.X - 12), math.max(0, available.Y - 62))
	end
	local function setVisible(value)
		if not value then cancelEdits(); closeDropdown() end
		finishInteraction(true)
		visible, panel.Visible = value, value
	end
	local function selectTab(key)
		cancelEdits(); finishInteraction(true); closeDropdown()
		activeTab = key
		for tabKey, tab in pairs(tabs) do tab.BackgroundColor3 = tabKey == activeTab and colors.Accent or colors.Card end
		for _, item in ipairs(cards) do item.frame.Visible = item.tab == activeTab end
		body.CanvasPosition = Vector2.new(0, 0)
	end
	for index, item in ipairs({
		{ "Graphics", text("GraphicsTab", "Đồ họa") }, { "Movement", text("MovementTab", "Di chuyển") },
		{ "Auto", text("AutoTab", "Tự động") }, { "Players", text("PlayersTab", "Người chơi") },
	}) do
		local key = item[1]
		local tab = button(tabBar, item[2], {
			Name = "Tab" .. key, Size = UDim2.new(0.25, -3, 1, 0), LayoutOrder = index, TextSize = 11,
		})
		tabs[key] = tab
		mainScope:connect(tab.Activated, function() selectTab(key) end)
	end
	local cardOrder = 0
	local function card(tab, title)
		cardOrder = cardOrder + 1
		local frame = newInstance("Frame", {
			Name = tab .. "Card" .. tostring(cardOrder), Size = UDim2.new(1, -2, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = colors.Card, BorderSizePixel = 0, LayoutOrder = cardOrder,
		}, body)
		table.insert(cards, { frame = frame, tab = tab })
		round(frame)
		newInstance("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, frame)
		label(frame, title, {
			Size = UDim2.new(1, 0, 0, 30), Font = Enum.Font.GothamBold, TextColor3 = colors.Muted, Text = "   " .. title,
		})
		return frame
	end
	local function toggle(parent, key, content, callback)
		local row = button(parent, content, {
			Name = key, Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1,
			Text = "   " .. content, TextXAlignment = Enum.TextXAlignment.Left,
		})
		local badge = label(row, text("Off", "TẮT"), {
			AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
			Size = UDim2.fromOffset(48, 25), TextXAlignment = Enum.TextXAlignment.Center,
			BackgroundTransparency = 0, BackgroundColor3 = colors.Background, TextSize = 11,
		})
		round(badge, 6)
		toggles[key] = function(enabled)
			badge.Text = enabled and text("On", "BẬT") or text("Off", "TẮT")
			badge.BackgroundColor3 = enabled and colors.Accent or colors.Background
		end
		mainScope:connect(row.Activated, callback)
		return row
	end
	local function isFinite(value)
		return type(value) == "number" and value == value and math.abs(value) < math.huge
	end
	local function slider(parent, title, getBounds, getValue, commit, getIdentity)
		local row = newInstance("Frame", {
			Name = title, Size = UDim2.new(1, 0, 0, 76), BackgroundTransparency = 1,
		}, parent)
		local caption = label(row, title, { Position = UDim2.fromOffset(12, 3), Size = UDim2.new(1, -100, 0, 25) })
		local entry = newInstance("TextBox", {
			Name = "Value", Position = UDim2.new(1, -82, 0, 0), Size = UDim2.fromOffset(70, 30), Text = "",
			BackgroundColor3 = colors.Background, BorderSizePixel = 0, TextColor3 = colors.Text,
			Font = Enum.Font.Gotham, TextSize = 13, ClearTextOnFocus = false,
		}, row)
		round(entry, 6)
		local hitArea = button(row, "", {
			Name = "Slider", Position = UDim2.fromOffset(12, 32), Size = UDim2.new(1, -24, 0, 38),
			BackgroundTransparency = 1, AutoButtonColor = false,
		})
		local track = newInstance("Frame", {
			Name = "Track", Position = UDim2.new(0, 0, 0.5, -3), Size = UDim2.new(1, 0, 0, 6),
			BackgroundColor3 = colors.Background, BorderSizePixel = 0,
		}, hitArea)
		round(track, 3)
		local fill = newInstance("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = colors.Accent, BorderSizePixel = 0 }, track)
		round(fill, 3)
		local thumb = newInstance("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(18, 18),
			Position = UDim2.fromScale(0, 0.5), BackgroundColor3 = colors.Text, BorderSizePixel = 0,
		}, track)
		round(thumb, 9)
		local control, editing, editIdentity = {}, false, nil
		function control.refresh(newTitle)
			local bounds, value = getBounds(), getValue()
			local fraction = math.clamp((value - bounds.Min) / math.max(0.001, bounds.Max - bounds.Min), 0, 1)
			fill.Size, thumb.Position = UDim2.fromScale(fraction, 1), UDim2.fromScale(fraction, 0.5)
			if not entry:IsFocused() then entry.Text = tostring(value) end
			if newTitle then caption.Text = newTitle end
		end
		function control.cancelEdit()
			editing, editIdentity = false, nil
			if entry:IsFocused() then entry:ReleaseFocus(false) end
			entry.Text = tostring(getValue())
		end
		function control.modeChanged(newTitle)
			if editing and getIdentity and editIdentity ~= getIdentity() then
				control.cancelEdit()
				notify(text("JumpModeChanged", "Chế độ nhảy đã đổi; nhập lại giá trị mới."), true)
			end
			if interaction and interaction.control == control then finishInteraction(true) end
			control.refresh(newTitle)
		end
		function control.setFromX(x)
			local bounds = getBounds()
			local fraction = math.clamp((x - track.AbsolutePosition.X) / math.max(1, track.AbsoluteSize.X), 0, 1)
			local value = bounds.Min + fraction * (bounds.Max - bounds.Min)
			local step = math.max(0.001, bounds.Step)
			value = math.clamp(math.floor(value / step + 0.5) * step, bounds.Min, bounds.Max)
			if value ~= getValue() then commit(value, getIdentity and getIdentity() or nil) end
			control.refresh()
		end
		mainScope:connect(hitArea.InputBegan, function(input)
			if interaction or not visible or collapsed then return end
			local touch = input.UserInputType == Enum.UserInputType.Touch
			if touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				cancelEdits()
				interaction = { kind = touch and "sliderPending" or "slider", input = input, control = control, origin = input.Position }
				if not touch then
					interaction.scrollEnabled = body.ScrollingEnabled
					body.ScrollingEnabled = false
					control.setFromX(input.Position.X)
				end
			end
		end)
		mainScope:connect(entry.Focused, function()
			editing, editIdentity = true, getIdentity and getIdentity() or nil
		end)
		mainScope:connect(entry.FocusLost, function()
			local shouldCommit, expectedIdentity = editing and visible and not collapsed and not destroyed and State.alive, editIdentity
			editing, editIdentity = false, nil
			if shouldCommit and getIdentity and expectedIdentity ~= getIdentity() then
				shouldCommit = false
				notify(text("JumpModeChanged", "Chế độ nhảy đã đổi; nhập lại giá trị mới."), true)
			end
			if shouldCommit then
				local value, bounds = tonumber(entry.Text), getBounds()
				if not isFinite(value) or value < bounds.Min or value > bounds.Max then
					notify(string.format(text("ValueRange", "Nhập số từ %s đến %s."), bounds.Min, bounds.Max), true)
				elseif commit(value, expectedIdentity) ~= false then
					notify(text("ValueApplied", "Đã đặt giá trị: ") .. tostring(value), false)
				end
			end
			control.refresh()
		end)
		table.insert(controls, control)
		control.refresh()
		return control
	end
	local function drawOptions()
		local state = dropdownState
		if not state or not searchBox or not optionsList then return end
		if next(pointerInputs) or os.clock() < (state.quietUntil or 0) then state.pendingDraw = true; return end
		state.pendingDraw = false
		local query, availableOptions, seen = string.lower(searchBox.Text), {}, {}
		for _, option in ipairs(state.getOptions()) do
			if type(option) == "string" and not seen[option] then seen[option] = true; table.insert(availableOptions, option) end
		end
		local signatureParts = { query }
		for _, option in ipairs(availableOptions) do
			table.insert(signatureParts, tostring(#option) .. ":" .. option .. ":" .. tostring(state.isSelected(option)))
		end
		local signature = table.concat(signatureParts, "|")
		if signature == state.signature then return end
		state.signature = signature
		if optionScope then optionScope:clean() end
		optionScope = Scope.new()
		for _, child in ipairs(optionsList:GetChildren()) do
			if child:IsA("TextButton") or child:IsA("TextLabel") then child:Destroy() end
		end
		local count = 0
		for _, option in ipairs(availableOptions) do
			if string.find(string.lower(option), query, 1, true) then
				count = count + 1
				local chosen = state.isSelected(option)
				local row = button(optionsList, (chosen and "✓  " or "    ") .. option, {
					Name = "Option", Size = UDim2.new(1, -4, 0, 36), TextXAlignment = Enum.TextXAlignment.Left,
					BackgroundColor3 = chosen and colors.Accent or colors.Card, LayoutOrder = count, ZIndex = 32,
				})
				optionScope:connect(row.Activated, function()
					if dropdownState ~= state then return end
					state.choose(option)
					if state.multi then drawOptions() else closeDropdown() end
				end)
			end
		end
		if count == 0 then label(optionsList, text("NoMatches", "Không có loại phù hợp"), { Size = UDim2.new(1, 0, 0, 36), ZIndex = 32 }) end
	end
	local function placeDropdown()
		if not dropdownState then return end
		local anchor, available = dropdownState.anchor, availableSize()
		local origin = surface.AbsolutePosition
		local width = math.max(1, math.min(panel.AbsoluteSize.X - 24, available.X - 12))
		local height = math.max(1, math.min(colors.DropdownHeight, available.Y - 12))
		local x = math.clamp(anchor.AbsolutePosition.X - origin.X, 0, math.max(0, available.X - width))
		local y = anchor.AbsolutePosition.Y - origin.Y + anchor.AbsoluteSize.Y + 3
		if y + height > available.Y then y = anchor.AbsolutePosition.Y - origin.Y - height - 3 end
		y = math.clamp(y, 0, math.max(0, available.Y - height))
		dropdown.Position, dropdown.Size = UDim2.fromOffset(x, y), UDim2.fromOffset(width, height)
		dropdown.Visible = available.Y >= 48 and available.X >= 80
		optionsList.Visible = height >= 80
		optionsList.Size = UDim2.new(1, -16, 0, math.max(0, height - 50))
	end
	local function openDropdown(settings)
		if dropdownState and dropdownState.anchor == settings.anchor then closeDropdown(); return end
		cancelEdits(); finishInteraction(true); closeDropdown()
		dropdownState, dropdownScope = settings, Scope.new()
		outside = newInstance("TextButton", {
			Name = "DropdownOutside", Size = UDim2.fromScale(1, 1), Text = "", AutoButtonColor = false,
			BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 29,
		}, surface)
		dropdown = newInstance("Frame", {
			Name = "Dropdown", BackgroundColor3 = colors.Background, BorderSizePixel = 0, ZIndex = 30, Active = true,
		}, surface)
		round(dropdown)
		newInstance("UIStroke", { Color = colors.Accent, Thickness = 1 }, dropdown)
		searchBox = newInstance("TextBox", {
			Name = "Search", Position = UDim2.fromOffset(8, 6), Size = UDim2.new(1, -49, 0, 32),
			PlaceholderText = text("Search", "Tìm loại…"), Text = "", TextColor3 = colors.Text,
			PlaceholderColor3 = colors.Muted, BackgroundColor3 = colors.Card, BorderSizePixel = 0,
			ClearTextOnFocus = false, Font = Enum.Font.Gotham, TextSize = 13, ZIndex = 31,
		}, dropdown)
		round(searchBox, 6)
		local dismiss = button(dropdown, "×", { Name = "Dismiss", Position = UDim2.new(1, -36, 0, 6), Size = UDim2.fromOffset(30, 32), ZIndex = 31 })
		optionsList = newInstance("ScrollingFrame", {
			Name = "Options", Position = UDim2.fromOffset(8, 44), Size = UDim2.new(1, -16, 1, -50),
			BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
			CanvasSize = UDim2.fromOffset(0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y, ZIndex = 31,
		}, dropdown)
		newInstance("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }, optionsList)
		dropdownScope:connect(searchBox:GetPropertyChangedSignal("Text"), drawOptions)
		dropdownScope:connect(dismiss.Activated, closeDropdown)
		dropdownScope:connect(outside.Activated, closeDropdown)
		placeDropdown(); drawOptions()
	end
	local function selector(parent, initial, name)
		local holder = newInstance("Frame", { Size = UDim2.new(1, 0, 0, 42), BackgroundTransparency = 1 }, parent)
		return button(holder, initial, {
			Name = name, Position = UDim2.fromOffset(12, 2), Size = UDim2.new(1, -24, 0, 36),
			BackgroundColor3 = colors.Background, TextTruncate = Enum.TextTruncate.AtEnd,
		})
	end
	local function addStatus(parent, mode)
		statusLabels[mode] = label(parent, "   " .. text("Disabled", "Đang tắt"), {
			Size = UDim2.new(1, 0, 0, 50), TextWrapped = true, TextSize = 11, TextColor3 = colors.Muted,
		})
		newInstance("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }, statusLabels[mode])
	end
	local graphicsCard = card("Graphics", text("GraphicsTitle", "ĐỒ HỌA"))
	toggle(graphicsCard, "FixLag", text("FixLag", "Giảm hiệu ứng"), function() setFeature("FixLag", not State.features.FixLag) end)
	toggle(graphicsCard, "FullBright", text("FullBright", "Tăng ánh sáng"), function() setFeature("FullBright", not State.features.FullBright) end)
	local movementCard = card("Movement", text("MovementTitle", "DI CHUYỂN"))
	toggle(movementCard, "Speed", text("Speed", "Tốc độ đi"), function() setFeature("Speed", not State.features.Speed) end)
	slider(movementCard, "WalkSpeed", function() return CONFIG.WalkSpeed end,
		function() return State.walkSpeed end, HumanoidControls.setSpeed)
	toggle(movementCard, "Jump", text("Jump", "Nhảy cao"), function() setFeature("Jump", not State.features.Jump) end)
	local jumpControl = slider(movementCard, "JumpPower", function() return CONFIG[HumanoidControls.getJumpProperty()] end,
		function() return State.jumpValues[HumanoidControls.getJumpProperty()] end, HumanoidControls.setJump, HumanoidControls.getJumpProperty)
	HumanoidControls.setModeSink(function(property) jumpControl.modeChanged(property) end)
	toggle(movementCard, "Noclip", text("Noclip", "Xuyên vật cản"), function() setFeature("Noclip", not State.features.Noclip) end)
	local farmCard = card("Auto", text("FarmTitle", "TỰ ĐỘNG ĐÁNH"))
	toggle(farmCard, "Farm", text("Farm", "Auto Farm"), function() setFeature("Farm", not State.features.Farm) end)
	local enemySelector = selector(farmCard, text("SelectEnemy", "Chọn loại NPC") .. "  ▾", "EnemySelector")
	addStatus(farmCard, "Farm")
	local lootCard = card("Auto", text("LootTitle", "TỰ ĐỘNG NHẶT"))
	toggle(lootCard, "Loot", text("Loot", "Auto Loot"), function() setFeature("Loot", not State.features.Loot) end)
	local lootSelector = selector(lootCard, text("SelectLoot", "Chọn loại vật phẩm") .. "  ▾", "LootSelector")
	addStatus(lootCard, "Loot")
	local espCard = card("Players", text("PlayersTitle", "NGƯỜI CHƠI"))
	toggle(espCard, "ESP", text("ESP", "Hiện người chơi"), function() setFeature("ESP", not State.features.ESP) end)
	local opponentsOnly = CONFIG.ESP.HideSameTeam
	toggle(espCard, "Opponents", text("Opponents", "Chỉ hiện đội đối thủ"), function()
		opponentsOnly = not opponentsOnly
		ESP.setOpponentsOnly(opponentsOnly)
		toggles.Opponents(opponentsOnly)
	end)
	toggles.Opponents(opponentsOnly)
	label(body, string.format(text("Help", "× tắt mọi tính năng. Utility / %s mở lại menu."), CONFIG.MenuToggleKey.Name), {
		Size = UDim2.new(1, -4, 0, 42), TextWrapped = true, TextSize = 10,
		TextColor3 = colors.Muted, LayoutOrder = 100,
	})
	local function refreshSelectors()
		enemySelector.Text = (State.enemyType or text("SelectEnemy", "Chọn loại NPC")) .. "  ▾"
		local selected = {}
		for _, tag in ipairs(CONFIG.LootTags) do if State.lootTypes[tag] then table.insert(selected, tag) end end
		lootSelector.Text = (#selected > 0 and table.concat(selected, ", ") or text("SelectLoot", "Chọn loại vật phẩm")) .. "  ▾"
	end
	mainScope:connect(enemySelector.Activated, function()
		openDropdown({ anchor = enemySelector, multi = false, getOptions = Automation.getEnemyTypes,
			isSelected = function(name) return State.enemyType == name end,
			choose = function(name)
				State.enemyType = name; refreshSelectors(); Automation.selectionChanged()
			end,
		})
	end)
	mainScope:connect(lootSelector.Activated, function()
		openDropdown({ anchor = lootSelector, multi = true, getOptions = function() return CONFIG.LootTags end,
			isSelected = function(tag) return State.lootTypes[tag] == true end,
			choose = function(tag)
				State.lootTypes[tag] = not State.lootTypes[tag] and true or nil
				refreshSelectors(); Automation.selectionChanged()
				if State.features.Loot and not next(State.lootTypes) then setFeature("Loot", false) end
			end,
		})
	end)
	statusSink = function(mode, content) if statusLabels[mode] then statusLabels[mode].Text = content end end
	mainScope:connect(launcher.Activated, function() setVisible(not visible) end)
	-- Cancel before stopping features, including a FocusLost event already queued by a click.
	mainScope:connect(close.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then cancelEdits() end
	end)
	mainScope:connect(close.Activated, function()
		cancelEdits(); finishInteraction(true); closeDropdown()
		local stopped = stopFeatures()
		setVisible(false)
		if stopped == false then
			notify(text("ClosedRestoreError", "Đã đóng; khôi phục một phần bị lỗi. Xem Output."), true)
		else
			notify(text("Closed", "Đã đóng menu và tắt mọi tính năng."), false)
		end
	end)
	mainScope:connect(minimize.Activated, function()
		cancelEdits(); finishInteraction(true); closeDropdown()
		collapsed = not collapsed
		minimize.Text = collapsed and "+" or "−"
		clampPanel()
	end)
	mainScope:connect(dragHandle.InputBegan, function(input)
		if interaction then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			cancelEdits(); closeDropdown()
			interaction = { kind = "drag", input = input, origin = input.Position, position = panel.Position }
		end
	end)
	mainScope:connect(UserInputService.InputChanged, function(input)
		if not interaction then return end
		local isTouch = interaction.input.UserInputType == Enum.UserInputType.Touch
		if (isTouch and input ~= interaction.input) or (not isTouch and input.UserInputType ~= Enum.UserInputType.MouseMovement) then return end
		if input.UserInputState == Enum.UserInputState.Cancel then finishInteraction(true); return end
		if interaction.kind == "sliderPending" then
			local delta = input.Position - interaction.origin
			if math.max(math.abs(delta.X), math.abs(delta.Y)) < touchThreshold then return end
			if math.abs(delta.Y) >= math.abs(delta.X) then finishInteraction(true); return end
			interaction.kind, interaction.scrollEnabled = "slider", body.ScrollingEnabled
			body.ScrollingEnabled = false
		end
		if interaction.kind == "slider" then interaction.control.setFromX(input.Position.X)
		else
			local delta = input.Position - interaction.origin
			panel.Position = UDim2.fromOffset(interaction.position.X.Offset + delta.X, interaction.position.Y.Offset + delta.Y)
			clampPanel()
		end
	end)
	mainScope:connect(UserInputService.InputEnded, function(input)
		pointerInputs[input] = nil
		if dropdownState then dropdownState.quietUntil = os.clock() + 0.05 end
		if interaction and (input == interaction.input
			or (interaction.input.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseButton1)) then
			finishInteraction(input.UserInputState == Enum.UserInputState.Cancel, input.Position.X)
		end
		refreshElapsed = colors.RefreshInterval
	end)
	mainScope:connect(UserInputService.WindowFocusReleased, function()
		cancelEdits(); finishInteraction(true); table.clear(pointerInputs)
	end)
	mainScope:connect(UserInputService.InputBegan, function(input, processed)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then pointerInputs[input] = true end
		if not processed and not UserInputService:GetFocusedTextBox() and input.KeyCode == CONFIG.MenuToggleKey then setVisible(not visible) end
	end)
	mainScope:connect(surface:GetPropertyChangedSignal("AbsoluteSize"), function()
		finishInteraction(true); clampPanel(); placeDropdown()
	end)
	for _, property in ipairs({ "OnScreenKeyboardVisible", "OnScreenKeyboardSize", "OnScreenKeyboardPosition" }) do
		mainScope:connect(UserInputService:GetPropertyChangedSignal(property), function()
			finishInteraction(true); clampPanel(); placeDropdown()
		end)
	end
	mainScope:connect(body:GetPropertyChangedSignal("CanvasPosition"), closeDropdown)
	mainScope:add(closeDropdown)
	function UI.bindActions(featureAction, stopAction) setFeature, stopFeatures = featureAction, stopAction end
	function UI.updateToggle(key, enabled) if toggles[key] then toggles[key](enabled) end end
	function UI.refreshValues()
		for _, control in ipairs(controls) do control.refresh() end
		refreshSelectors()
	end
	function UI.update(dt)
		if destroyed then return end
		if dropdownState and dropdownState.pendingDraw and not next(pointerInputs)
			and os.clock() >= (dropdownState.quietUntil or 0) then drawOptions() end
		if currentNotice and os.clock() >= noticeUntil then
			currentNotice = nil
			if #noticeQueue > 0 then showNotice(table.remove(noticeQueue, 1)) else notice.Visible = false end
		end
		refreshElapsed = refreshElapsed + dt
		if refreshElapsed >= colors.RefreshInterval then
			refreshElapsed = 0
			if dropdownState then drawOptions() end
		end
	end
	function UI.destroy()
		if destroyed then return end
		destroyed = true
		cancelEdits(); closeDropdown(); finishInteraction(true)
		table.clear(pointerInputs); table.clear(noticeQueue)
		currentNotice, notifySink, statusSink = nil, nil, nil
		notice.Visible = false
	end
	selectTab(activeTab)
	clampPanel()
end



local FeatureManager = {}
do
	local featureNames = {
		FixLag = "Giảm lag", FullBright = "Tăng sáng", Speed = "Tốc độ chạy", Jump = "Nhảy cao",
		Farm = "Auto Farm", Loot = "Auto Loot", Noclip = "Noclip", ESP = "ESP người chơi",
	}
	local changing = {}
	local function apply(key, enabled)
		if key == "FixLag" then Graphics.setFixLag(enabled)
		elseif key == "FullBright" then Graphics.setFullBright(enabled)
		elseif key == "Speed" then HumanoidControls.setSpeedEnabled(enabled)
		elseif key == "Jump" then HumanoidControls.setJumpEnabled(enabled)
		elseif key == "Noclip" then setNoclipRequest("Manual", enabled)
		elseif key == "ESP" then return ESP.setEnabled(enabled) == enabled
		elseif key == "Farm" or key == "Loot" then Automation.setMode(enabled and key or nil)
		else error("Unknown feature: " .. tostring(key)) end
		return true
	end
	function FeatureManager.set(key, enabled, quiet, force)
		if not featureNames[key] or changing[key] then return false end
		enabled = enabled == true
		if not force and (State.features[key] == true) == enabled then return true end
		if enabled and (key == "Farm" or key == "Loot") then
			local ok, valid = checkedCall("Validate " .. key, function()
				local accepted, reason = Automation.validate(key)
				if not accepted then notify(reason, true) end
				return accepted
			end)
			if not ok or not valid then return false end
			if not FeatureManager.set(key == "Farm" and "Loot" or "Farm", false, true, true) then return false end
		end
		changing[key], State.features[key] = true, enabled
		local ok, applied = checkedCall("Change " .. key, apply, key, enabled)
		if not ok or not applied then
			State.features[key] = false
			checkedCall("Rollback " .. key, apply, key, false)
			UI.updateToggle(key, false)
			changing[key] = nil
			notify("Không thể đổi " .. featureNames[key] .. ". Đã yêu cầu dừng và khôi phục; xem Output.", true)
			return false
		end
		UI.updateToggle(key, enabled)
		changing[key] = nil
		if not quiet then notify(featureNames[key] .. (enabled and ": bật." or ": tắt."), false) end
		return true
	end
	function FeatureManager.stopAll()
		local success = true
		for _, key in ipairs({ "Farm", "Loot", "Noclip", "Speed", "Jump", "ESP", "FixLag", "FullBright" }) do
			local ok, stopped = checkedCall("Stop " .. key, FeatureManager.set, key, false, true, true)
			if not ok or not stopped then success = false end
		end
		return success
	end
end

do
	UI.bindActions(FeatureManager.set, FeatureManager.stopAll)
	local characterScope, humanoidScope, observedHumanoid, controlsHumanoid
	local refreshCharacter
	local function usable(instance, character, excluding)
		return instance and instance:IsDescendantOf(character) and instance ~= excluding
			and (not excluding or not instance:IsDescendantOf(excluding))
	end
	local function bindHumanoid(humanoid)
		if humanoid == observedHumanoid then return end
		if humanoidScope then humanoidScope:clean(); humanoidScope = nil end
		observedHumanoid, controlsHumanoid = humanoid, nil
		HumanoidControls.bind(nil)
		if not humanoid then return end
		humanoidScope = Scope.new()
		local function healthChanged()
			local desired = humanoid.Health > 0 and humanoid or nil
			if controlsHumanoid ~= desired then
				controlsHumanoid = desired
				HumanoidControls.bind(desired)
				Automation.onCharacterChanged()
			end
			Noclip.refresh()
		end
		humanoidScope:connect(humanoid.HealthChanged, healthChanged)
		humanoidScope:connect(humanoid.Died, healthChanged)
		humanoidScope:connect(humanoid:GetPropertyChangedSignal("RootPart"), function() refreshCharacter() end)
		healthChanged()
	end
	refreshCharacter = function(excluding)
		local character = State.character
		if not character then return end
		if not character:IsDescendantOf(Workspace) then
			local changed = State.humanoid ~= nil or State.root ~= nil
			State.humanoid, State.root = nil, nil
			bindHumanoid(nil)
			Noclip.refresh()
			if changed then Automation.onCharacterChanged() end
			return
		end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not usable(humanoid, character, excluding) then humanoid = nil end
		local root
		local candidates = { (humanoid and humanoid.RootPart) or false,
			character:FindFirstChild("HumanoidRootPart") or false, character.PrimaryPart or false }
		for _, candidate in ipairs(candidates) do
			if candidate and candidate:IsA("BasePart") and usable(candidate, character, excluding) then root = candidate; break end
		end
		local changed = humanoid ~= State.humanoid or root ~= State.root
		State.humanoid, State.root = humanoid, root
		bindHumanoid(humanoid)
		if changed then Automation.onCharacterChanged() end
		Noclip.refresh()
	end
	local function bindCharacter(character)
		if characterScope then characterScope:clean(); characterScope = nil end
		State.character, State.humanoid, State.root = nil, nil, nil
		bindHumanoid(nil)
		Noclip.refresh(); Automation.onCharacterChanged()
		State.character = character
		if not character then return end
		characterScope = Scope.new()
		local function relevant(instance)
			return instance:IsA("BasePart") or instance:IsA("Humanoid") or instance:IsA("Model")
		end
		characterScope:connect(character.DescendantAdded, function(instance)
			if relevant(instance) then refreshCharacter() end
		end)
		characterScope:connect(character.DescendantRemoving, function(instance)
			if relevant(instance) then refreshCharacter(instance) end
		end)
		characterScope:connect(character:GetPropertyChangedSignal("PrimaryPart"), function() refreshCharacter() end)
		characterScope:connect(character.AncestryChanged, function() refreshCharacter() end)
		refreshCharacter()
	end
	mainScope:connect(LocalPlayer.CharacterAdded, bindCharacter)
	mainScope:connect(LocalPlayer.CharacterRemoving, function(character)
		if State.character == character then bindCharacter(nil) end
	end)
	mainScope:add(function()
		if characterScope then characterScope:clean() end
		if humanoidScope then humanoidScope:clean() end
	end)
	bindCharacter(LocalPlayer.Character)
	mainScope:connect(RunService.Heartbeat, function(dt)
		checkedCall("Graphics update", Graphics.step, dt)
		checkedCall("Interactions update", Interactions.update, dt)
		checkedCall("Automation update", Automation.update, dt)
		checkedCall("ESP update", ESP.update, dt)
		checkedCall("UI update", UI.update, dt)
	end)
	local shuttingDown = false
	local function shutdown(guiIsDestroying)
		if shuttingDown then return end
		shuttingDown = true
		FeatureManager.stopAll()
		checkedCall("Automation cleanup", Automation.destroy)
		checkedCall("Interactions cleanup", Interactions.destroy)
		checkedCall("ESP cleanup", ESP.destroy)
		checkedCall("Graphics cleanup", Graphics.destroy)
		checkedCall("Movement cleanup", HumanoidControls.destroy)
		checkedCall("Noclip cleanup", Noclip.destroy)
		checkedCall("UI cleanup", UI.destroy)
		mainScope:clean()
		State.alive = false
		if not guiIsDestroying and Gui.Parent then Gui:Destroy() end
	end
	mainScope:connect(Gui.Destroying, function() shutdown(true) end)
	mainScope:connect(script.Destroying, function() shutdown(false) end)
	notify("Utility v" .. CONFIG.Version .. " sẵn sàng. Dùng Utility / " .. CONFIG.MenuToggleKey.Name .. ".", false)
end
]====]

local RunService = game:GetService("RunService")
assert(RunService:IsStudio() and not RunService:IsRunning(),
	"Bấm Stop rồi chạy bộ cài trong Command Bar của Roblox Studio.")
local starterScripts = game:GetService("StarterPlayer"):FindFirstChildOfClass("StarterPlayerScripts")
assert(starterScripts, "Không tìm thấy StarterPlayer > StarterPlayerScripts.")
local SCRIPT_NAME, MANAGED_ATTRIBUTE = "MrDonUtility", "MrDonUtilityManaged"

local function reportSelection(instance)
	local ok, err = pcall(function() game:GetService("Selection"):Set({ instance }) end)
	if not ok then warn("[MrDon Installer] Không chọn được script vừa cài: " .. tostring(err)) end
end

local existing
for _, child in ipairs(starterScripts:GetChildren()) do
	if child.Name == SCRIPT_NAME then
		assert(not existing, "Có nhiều đối tượng tên MrDonUtility. Đổi tên bản trùng trước khi cài.")
		existing = child
	end
end
if existing then
	assert(existing:IsA("LocalScript") and existing:GetAttribute(MANAGED_ATTRIBUTE) == true,
		"Tên MrDonUtility đang được đối tượng khác sử dụng. Đổi tên nó trước khi cài.")
	reportSelection(existing)
	print("[MrDon Installer] Đã có MrDonUtility; giữ nguyên mã đang chỉnh. Mở script đó hoặc bấm Play.")
	if not existing.Enabled then
		print("[MrDon Installer] MrDonUtility đang tắt. Bật Enabled trong Properties nếu muốn chạy menu.")
	end
	return existing
end

-- Recognize only the earlier delivered menu variants. Keep them as backups.
local function isPreviousMenu(instance)
	if not instance:IsA("LocalScript") then return false end
	local source = instance.Source
	local standaloneHeader = "-- Roblox Utility Menu v2 | one LocalScript | StarterPlayer > StarterPlayerScripts"
	if source:sub(1, #standaloneHeader) == standaloneHeader then return true end
	if instance.Name ~= "UtilityLoader" then return false end
	local module = instance:FindFirstChild("UtilityMenu")
	if not module or not module:IsA("ModuleScript") then return false end
	local moduleHeader = "-- MrDon Utility v2 | ModuleScript named UtilityMenu, child of UtilityLoader."
	local moduleSource = module.Source
	if moduleSource:sub(1, #moduleHeader) ~= moduleHeader then return false end
	local expected = 'require(assert(script:WaitForChild("UtilityMenu",10),"Thiếu ModuleScript UtilityMenu"))(script)'
	return source:gsub("%s+$", "") == expected
end

local previousMenus = {}
for _, child in ipairs(starterScripts:GetChildren()) do
	if isPreviousMenu(child) then table.insert(previousMenus, child) end
end

local staged, originalEnabled = nil, {}
local ok, result = xpcall(function()
	staged = Instance.new("LocalScript")
	staged.Name, staged.Enabled = SCRIPT_NAME, false
	staged.Source = CLIENT_SOURCE
	staged:SetAttribute(MANAGED_ATTRIBUTE, true)
	staged:SetAttribute("UtilityVersion", "2.0.0")
	for _, previous in ipairs(previousMenus) do
		originalEnabled[previous] = previous.Enabled
		previous.Enabled = false
	end
	staged.Parent = starterScripts
	staged.Enabled = true
	return staged
end, debug.traceback)

if not ok then
	if staged then
		local cleaned, cleanupError = pcall(function() staged:Destroy() end)
		if not cleaned then warn("[MrDon Installer] Lỗi dọn bản cài: " .. tostring(cleanupError)) end
	end
	for previous, enabled in pairs(originalEnabled) do
		local restored, restoreError = pcall(function() previous.Enabled = enabled end)
		if not restored then warn("[MrDon Installer] Lỗi khôi phục bản cũ: " .. tostring(restoreError)) end
	end
	error("[MrDon Installer] Không cài được: " .. tostring(result), 0)
end

reportSelection(result)
print("[MrDon Installer] Đã cài StarterPlayer > StarterPlayerScripts > MrDonUtility. Bấm Play để mở menu.")
if #previousMenus > 0 then
	print("[MrDon Installer] Đã tắt bản menu cũ và giữ lại mã làm bản dự phòng.")
end
return result
