--!strict

local LoadedCode = game:FindFirstChild("LoadedCode")
assert(LoadedCode, "Failed to find LoadedCode")

local types = require(LoadedCode.EvalUtils.types)
local HttpService = game:GetService("HttpService")
type BaseEval = types.BaseEval
local utils_he = require(LoadedCode.EvalUtils.utils_he)

------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------

local eval: BaseEval = {
    scenario_name = "052_surburban_trampoline_bounce",
    prompt = {
                {
                    {
                        role = "user",
                        content = [[Make people keep bouncing when they are on the trampoline.]],
                        request_id = "s20250804_019"
                    }
                }
            },
    place = "surburban.rbxl",
    tool = nil,
    tags = {"game_iteration"},
    difficulty = "difficult",
}

local SelectionContextJson = "[]"
local TableSelectionContext = HttpService:JSONDecode(SelectionContextJson)

eval.setup = function()

	local trampoline = workspace:WaitForChild('Yard', 20):WaitForChild('Trampoline', 20):WaitForChild('Trampoline', 20)
	assert(trampoline, "Trampoline is required for evaluation, please check the place file.")

	for _, child in ipairs(trampoline:GetDescendants()) do
		if child:IsA('LuaSourceContainer') then
			child:Destroy()
		end
	end

	local newScript = Instance.new("Script")
	newScript.Source = [[script.Parent.Touched:connect(function(obj) if obj.Parent and obj.Parent:FindFirstChild("Humanoid") then obj.Parent.HumanoidRootPart.Velocity = Vector3.new(0,script.Parent.Parent.Configurations.JumpForce.Value,0) end end)]]
	newScript.Parent = trampoline

    local selectionService = game:GetService("Selection")
    local selectedInstances = {}
    for _, selection in ipairs(TableSelectionContext) do
        for _, instance in ipairs(game:GetDescendants()) do
            if instance.Name == selection.instanceName and instance:IsA(selection.className) then
                selectedInstances[#selectedInstances + 1] = instance
                break
            end
        end
    end
    selectionService:Set(selectedInstances)
end

eval.reference = function()
	local newScriptSource = [[local trampoline = script.Parent
local jumpForce = trampoline.Parent.Configurations.JumpForce
local activeCharacters = {} -- debounce table

-- Helper function to find character from any hit part (handles accessories)
local function getCharacterFromHit(hit)
	local current = hit.Parent
	while current and current ~= game do
		if current:FindFirstChildOfClass("Humanoid") then
			return current
		end
		current = current.Parent
	end
	return nil
end

function bind(hit)
	local character = getCharacterFromHit(hit)
	if not character or activeCharacters[character] then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character.PrimaryPart
	if not humanoid or not root then return end

	activeCharacters[character] = true

	while character and character.Parent do
		task.wait(0.1)
		-- airborn
		if humanoid.FloorMaterial == Enum.Material.Air then continue end

		-- distance check ignoring Y
		local distXZ = (Vector3.new(root.Position.X, 0, root.Position.Z) - Vector3.new(trampoline.Position.X, 0, trampoline.Position.Z)).Magnitude

		if distXZ <= trampoline.Size.Z / 2 then
			humanoid.Jump = true
			root.Velocity = Vector3.new(root.Velocity.X, jumpForce.Value, root.Velocity.Z)
		else
			break
		end
	end

	activeCharacters[character] = nil
end

local db = false
trampoline.Touched:Connect(function(...)
	if db then return end
	db = true

	bind(...)

	task.wait()
	db = false
end)]]

	local trampoline = workspace:WaitForChild('Yard', 5):WaitForChild('Trampoline', 5):WaitForChild('Trampoline', 5)
	assert(trampoline, "Trampoline is required for evaluation, please check the place file.")

	for _, child in ipairs(trampoline:GetDescendants()) do
		if child:IsA('LuaSourceContainer') then
			child:Destroy()
		end
	end

	local newScript = Instance.new("Script")
	newScript.Source = newScriptSource
	newScript.Parent = trampoline
    newScript.Enabled = true
end

eval.check_scene = function()
end

function shortMag(v1:Vector3, d:number)
	return v1.Magnitude <= d
end

eval.check_game = function()
	local trampoline = workspace:WaitForChild('Yard', 20):WaitForChild('Trampoline', 20):WaitForChild('Trampoline', 20)
	local players = game:GetService("Players")
    local player = #players:GetPlayers() > 0 and players:GetPlayers()[1] or players.PlayerAdded:Wait()
    player:LoadCharacter()
    local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid", 20)

	assert(trampoline and humanoid, "Setup failed. Problem with place file?")

	while not character.PrimaryPart do task.wait() end

	local origin = trampoline.CFrame.p + Vector3.new(0, humanoid.HipHeight, 0)
	character:PivotTo(CFrame.new(origin))

	local startTime = os.clock()
	while humanoid.FloorMaterial ~= Enum.Material.Air do
		assert(os.clock() - startTime < 20, "Player couldn't even start bouncing on the trampoline.")

		humanoid:MoveTo(origin + Vector3.new(math.random(-100, 100) / 50, 0, math.random(-100, 100) / 50))
		task.wait(0.5)
	end

	local yPositions = {}

	-- Data collection (500 runs was about 10s but I didn't measure 400)
	for i = 1, 50 do
		local recordedPos = character:GetPivot().Position
		table.insert(yPositions, recordedPos.Y)
		task.wait(0.2)
	end

	-- Process the wave data
	local peaks = {}
	local valleys = {}

	-- Find peaks and valleys
	for i = 2, #yPositions - 1 do
		if yPositions[i] > yPositions[i-1] and yPositions[i] > yPositions[i+1] then
			table.insert(peaks, {index = i, height = yPositions[i]})
		elseif yPositions[i] < yPositions[i-1] and yPositions[i] < yPositions[i+1] then
			table.insert(valleys, {index = i, height = yPositions[i]})
		end
	end

	-- Calculate wave amplitudes (peak to chronologically next valley)
	local amplitudes = {}

	-- Combine peaks and valleys, sort by index
	local events = {}
	for _, peak in ipairs(peaks) do
		table.insert(events, {index = peak.index, height = peak.height, type = "peak"})
	end
	for _, valley in ipairs(valleys) do
		table.insert(events, {index = valley.index, height = valley.height, type = "valley"})
	end
	table.sort(events, function(a, b) return a.index < b.index end)

	-- Calculate amplitudes between consecutive peak-valley pairs
	for i = 1, #events - 1 do
		local current = events[i]
		local next = events[i + 1]
		if (current.type == "peak" and next.type == "valley") or
		   (current.type == "valley" and next.type == "peak") then
			table.insert(amplitudes, math.abs(current.height - next.height))
		end
	end

	-- Check if most amplitudes are similar
	local avgAmplitude = 0
	for _, amp in ipairs(amplitudes) do
		avgAmplitude = avgAmplitude + amp
	end
	avgAmplitude = avgAmplitude / #amplitudes

	assert(#amplitudes > 2, "No bounces were detected.")
	assert(avgAmplitude > 0.5, "Bounces were detected, but so small that they were too neglible to be counted.")
end

return eval
