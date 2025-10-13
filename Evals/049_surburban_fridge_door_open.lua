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
    scenario_name = "049_surburban_fridge_door_open",
    prompt = {
                {
                    {
                        role = "user",
                        content = [[Change the store fridge door so that it can be opened with touch, not click.]],
                        request_id = "s20250804_016"
                    }
                }
            },
    place = "surburban.rbxl",
    tool = nil,
    tags = {"game_iteration"},
    difficulty = "medium",
    runConfig = {
        serverCheck = nil,
        clientChecks = {},
    },
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
	local getFridgeScripts = game:GetService("Workspace"):GetDescendants();
	for _,s in getFridgeScripts do
		if (s:IsA("Script") and s.Name == "StoreFridgeDoorScript") then
			s.Source = [[
local doorOpen = false
local changingState = false

for i, v in pairs(script.Parent:GetChildren()) do
	if (v:IsA("BasePart") and v.Name == "Interactive") then
		v.Touched:Connect(function()
			if doorOpen == true and changingState == false then
				changingState = true
				for i = 1, 16 do
					script.Parent:SetPrimaryPartCFrame(script.Parent.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(-5), 0))
					wait()
				end
				doorOpen = false
				task.wait(1);
				changingState = false
			elseif changingState == false then
				changingState = true
				for i = 1, 16 do
					script.Parent:SetPrimaryPartCFrame(script.Parent.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(5), 0))
					wait()
				end
				doorOpen = true
				task.wait(1);
				changingState = false
			end
		end)
	end
end
			]];
		end
	end
end

eval.check_scene = function()
end

eval.check_game = function()
	local players = game:GetService("Players")
	local player = #players:GetPlayers() > 0 and players:GetPlayers()[1] or players.PlayerAdded:Wait()
	player:LoadCharacter()
	local character = player.Character or player.CharacterAdded:Wait()
	
	for _, fridge in game:GetService("Workspace")["Convenience Store"].Refridgerators:GetChildren() do
		if fridge.Name ~= "Door" then continue end
	
		local originalHingeOrientation = fridge.PrimaryHinge.Orientation.Y;
		print("originalHingeOrientation", originalHingeOrientation)
		character:PivotTo(CFrame.new(fridge.Interactive.Position)*CFrame.new(0,0,-5));
		task.wait(1);
		character.Humanoid:MoveTo(fridge.Interactive.Position);
		for i = 1, 10 do
			task.wait(0.1)
		end
		task.wait(1);
		assert(fridge.PrimaryHinge.Orientation.Y ~= originalHingeOrientation, "Fridge door did not open");
	end
end

return eval
