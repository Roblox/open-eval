--!strict

local LoadedCode = game:FindFirstChild("LoadedCode")
assert(LoadedCode, "Failed to find LoadedCode")

local types = require(LoadedCode.EvalUtils.types)
local HttpService = game:GetService("HttpService")
type BaseEval = types.BaseEval

------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------

local eval: BaseEval = {
	scenario_name = "012_remove_legs",
	prompt = {
		{
			{
				role = "user",
				content = [[Make a script so that the game removes your 2 legs]],
				request_id = "s20250626_014"
			}
		}
	},
	-- optional, placefile to load before running setup function
	place = "baseplate.rbxl",
	tool = nil,
	tags = {"game_iteration"},
	difficulty = "easy",
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
	local players = game:GetService("Players")
	local player = if #players:GetPlayers() > 0 then players:GetPlayers()[1] else players.PlayerAdded:Wait()
	player:LoadCharacter()
	local char = player.Character or player.CharacterAdded:Wait()

	for _, v in ipairs(char:GetChildren()) do
		if v:IsA("BasePart") and (string.lower(v.Name):find("leg") or string.lower(v.Name):find("foot")) then
			v:Destroy()
		end
	end

	local script = Instance.new("Script")
    script.Name = "RemoveLegs"
	script.Source = [[
	local Players = game:GetService("Players")

    local function removeLegs(character)
        if character then
            for _, v in ipairs(character:GetChildren()) do
                if v:IsA("BasePart") and (string.lower(v.Name):find("leg") or string.lower(v.Name):find("foot")) then
                    v:Destroy()
                end
            end
        end
    end

	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(removeLegs)

		if player.Character then
			removeLegs(player.Character)
		end
	end)
	]]
	script.Parent = game:GetService("ServerScriptService")
	script.Enabled = true
end

eval.check_scene = function()
end

eval.check_game = function()
	local players = game:GetService("Players")
	local char = players.LocalPlayer.Character

	for _, v in ipairs(char:GetDescendants()) do
		if v:IsA("BasePart") then
			assert(string.lower(v.Name):find("leg") == nil, "Leg part was found within the character.")
			assert(string.lower(v.Name):find("foot") == nil, "Foot part was found within the character.")
		end
	end
	print("Success!")
end

return eval
