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
    scenario_name = "055_surburban_tree_fallcolor_approach",
    prompt = {
                {
                    {
                        role = "user",
                        content = [[Make trees change color to red when player approach it.]],
                        request_id = "s20250804_023"
                    }
                }
            },
    place = "surburban.rbxl",
    tool = nil,
    tags = {"game_iteration"},
    difficulty = "medium",
}

local SelectionContextJson = "[]"
local TableSelectionContext = HttpService:JSONDecode(SelectionContextJson)

eval.setup = function()

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
	local source = [[local trees = {}

for _, tree in game.Workspace.Trees:GetChildren() do
	trees[tree] = false
end

game.Workspace.Trees.ChildAdded:Connect(function(c)
	trees[c] = false
end)

-- this reference is not 100% what I would do in a prod env
-- but its fine and faster for the test

local plr = game.Players:GetPlayers()[1] or game.Players.PlayerAdded:Wait()
local character = plr.Character or plr.CharacterAdded:Wait()

while task.wait(0.25) do
	for tree, isRed in trees do
		local pos = character:GetPivot().p
		local treePos = tree:GetPivot().p

		local shouldBeRed = Vector3.new(pos.X - treePos.X, 0, pos.Z - treePos.Z).Magnitude < 20

		if shouldBeRed ~= isRed then
			trees[tree] = shouldBeRed

			for _, container in tree:GetChildren() do
				if container.Name == "Leaves" then
					for _, leaf in container:GetChildren() do
						if leaf:IsA("BasePart") then
							leaf.Color = shouldBeRed and Color3.new(1,0,0) or Color3.new(0,0.5,0)
						end
					end
				end
			end
		end
	end
end]]
	local newScript = Instance.new("Script")
	newScript.Source = source
	newScript.Parent = game.ServerScriptService
end

eval.check_scene = function()
end

eval.check_game = function()
	local trees = game:GetService("Workspace").Trees
	local players = game:GetService("Players")
    local player = #players:GetPlayers() > 0 and players:GetPlayers()[1] or players.PlayerAdded:Wait()
    player:LoadCharacter()
    local character = player.Character or player.CharacterAdded:Wait()

	local function treeIsRed(tree)
		for _, leaf in tree:GetDescendants() do
			if leaf:IsA("BasePart") and leaf.Parent.Name == "Leaves" then
				local h, s, v = leaf.Color:ToHSV()
				local out = h * 360 < 15 or h * 360 > 340 -- red hue
				out = out and s * 100 > 30 and v * 100 > 30 -- needs some sat/val

				if not out then
					return false
				end
			end
		end

		return true
	end

	for _, tree in trees:GetChildren() do
		assert(not treeIsRed(tree), "A tree started red.")
	end

	for _, tree in trees:GetChildren() do
		character:PivotTo(tree:GetPivot())
		task.wait(0.5)
		assert(treeIsRed(tree), "Tree is not red despite being next to it.")
	end

	character:PivotTo(game:GetService("Workspace").SpawnLocation.CFrame)

	task.wait(0.2)

	for _, tree in trees:GetChildren() do
		assert(not treeIsRed(tree), "Trees haven't reverted to red.")
	end
end

return eval
