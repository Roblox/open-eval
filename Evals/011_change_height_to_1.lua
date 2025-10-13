--!strict

local LoadedCode = game:FindFirstChild("LoadedCode")
assert(LoadedCode, "Failed to find LoadedCode")

local types = require(LoadedCode.EvalUtils.types)
local HttpService = game:GetService("HttpService")
type BaseEval = types.BaseEval

------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------

local eval: BaseEval = {
    scenario_name = "011_change_height_to_1",
    prompt = {
                {
                    {
                        role = "user",
                        content = [[chahge players height to 1]],
                        request_id = "s20250626_009"
                    }
                }
            },
    place = "baseplate.rbxl",
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
    -- Scale to 1 stud tall
    local script = Instance.new("Script")
    script.Name = "ShrinkPlayerHeight"
	script.Source = [[
	local Players = game:GetService("Players")

    local function shrinkCharacter(character)
        if character then
            local _, size = character:GetBoundingBox()
            character:ScaleTo(1/size.Y)
        end
    end

    local function onPlayerAdded(player)
        player.CharacterAdded:Connect(shrinkCharacter)

        if player.Character then
            shrinkCharacter(player.Character)
        end
    end

    Players.PlayerAdded:Connect(onPlayerAdded)
    for _, player in Players:GetPlayers() do
        onPlayerAdded(player)
    end
	]]
	script.Parent = game:GetService("ServerScriptService")
	script.Enabled = true
end

eval.check_scene = function()
end

eval.check_game = function()
	local players = game:GetService("Players")
	local player = if #players:GetPlayers() > 0 then players:GetPlayers()[1] else players.PlayerAdded:Wait()
	player:LoadCharacter()
	local char = player.Character or player.CharacterAdded:Wait()
    task.wait(1) -- wait for the character to be loaded and scaled
	local _, size = char:GetBoundingBox()
    print("size", size)

	assert(size.Y>0.95 and size.Y<1.05, "Player isn't 1 stud tall.")
end

return eval
