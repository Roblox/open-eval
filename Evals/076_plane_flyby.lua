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
    prompt = {
                {
                    {
                        role = "user",
                        content = [[Add a plane flyby scene]],
                        request_id = "s20250626_002"
                    }
                }
            },
    place = "baseplate.rbxl",
    tool = nil,
    tags = {"game_iteration"},
    difficulty = "medium",
}

local selection_context_json = "[]"
local table_selection_context = HttpService:JSONDecode(selection_context_json)
local Workspace = game:GetService("Workspace")
local OriginalState = game.Workspace:GetDescendants()

eval.setup = function()
    local selection_service = game:GetService("Selection")
    local selected_instances = {}
    for _, selection in ipairs(table_selection_context) do
        for _, instance in ipairs(game:GetDescendants()) do
            if instance.Name == selection.instanceName and instance:IsA(selection.className) then
                selected_instances[#selected_instances + 1] = instance
                break
            end
        end
    end
    selection_service:Set(selected_instances)
end

eval.reference = function()
	
	-- I'm creating my own plane rather than using the toolbox, because the toolbox can be a very difficult shot in the dark
	local plane = Instance.new("Model", Workspace)
	plane.Name = "Plane"
	
	local part = Instance.new("Part", plane)
		part.Size = Vector3.new(14.800000190734863, 1, 5.5)
		part.CFrame = CFrame.fromMatrix(Vector3.new(-58.6, 0.5, -28.35), Vector3.new(1, 0, 0), Vector3.new(0, 1, 0), Vector3.new(0, 0, 1))
		part.Anchored = true

	local part = Instance.new("Part", plane)
		part.Size = Vector3.new(4.300000190734863, 1, 17.899999618530273)
		part.CFrame = CFrame.fromMatrix(Vector3.new(-60.35, 0.5, -28.35), Vector3.new(1, 0, 0), Vector3.new(0, 1, 0), Vector3.new(0, 0, 1))
		part.Anchored = true

	local part = Instance.new("Part", plane)
		part.Size = Vector3.new(3.1000001430511475, 1, 7.499999046325684)
		part.CFrame = CFrame.fromMatrix(Vector3.new(-51.8, 0.5, -28.35), Vector3.new(1, 0, 0), Vector3.new(0, 1, 0), Vector3.new(0, 0, 1))
		part.Anchored = true
	
	local newScript = Instance.new("Script", plane)
		newScript.Source = [[
			local plane = script.Parent
			local origin = Vector3.new(0, 50, 0)
			while task.wait() do
				plane:PivotTo(CFrame.new(origin + Vector3.new(math.sin(tick())*20, 0, math.cos(tick())*20) ))
			end
		]]
		newScript.Enabled = true
	
end

eval.check_scene = function()
end

eval.check_game = function()
	local planeParts = {}
	local planeScript = nil
	local oldInfo = {}
	
	local container = Instance.new("Model")
	
	for _, obj in ipairs(utils_he.table_difference(OriginalState, game.Workspace:GetDescendants())) do
		if obj:IsA("LuaSourceContainer") then
			planeScript = obj
		elseif obj:IsA("BasePart") then
			table.insert(planeParts, {obj, obj.Parent})
			obj.Parent = container
			oldInfo[obj] = obj.CFrame
		end
	end
	
	assert(planeScript, "No new scripts were added, which is required to move the plane.")
	assert(#planeParts > 1, "Need at least two new parts to be inserted, bare minimum for a plane.")
	
	local sizeInfo = utils_he.getSizeInfoOfModel(container)
	
	for _, data in pairs(planeParts) do -- put them back
		data[1].Parent = data[2]
	end
	
	assert(sizeInfo.shortestSide > 0.5, "Probably not a plane? There's a really short side.")
	assert(sizeInfo.longestSide > 5, "Probably not a plane? The longest side is shorter than 5 studs.")
	
	local successes = 0
	
	for i = 1, 50 do
		task.wait(0.05)
		for part, oldCF in pairs(oldInfo) do
			if (part.CFrame.p-oldCF.p).Magnitude > 0.1 then
				successes += 1
				oldInfo[part] = part.CFrame
			end
		end
	end
	
	assert(successes >= 10, "The plane isn't moving.")
end

return eval
