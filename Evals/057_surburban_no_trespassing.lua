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
	scenario_name = "057_surburban_no_trespassing",
	prompt = {
		{
			{
				role = "user",
				content = [[No trespassing: when player enters the fenced yard, they will receive 10 damage.]],
				request_id = "s20250804_025"
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
	local boundsModel = Instance.new("Model");
	boundsModel.Name = "FenceBounds";
	boundsModel.Parent = game:GetService("Workspace");

	local function addBounds(cframe: CFrame, size: Vector3)
		local trigger1 = Instance.new("Part");
		trigger1.Size = size + Vector3.new(0,10,0);
		trigger1.CFrame = cframe*CFrame.new(0,0,0.2);
		trigger1.Transparency = 1;
		trigger1.Anchored = true;
		trigger1.CanCollide = false;
		trigger1.Name = "Damage";
		trigger1.Parent = boundsModel;
		local trigger2 = Instance.new("Part");
		trigger2.Size = size + Vector3.new(0,10,0);
		trigger2.CFrame = cframe*CFrame.new(0,0,1);
		trigger2.Transparency = 1;
		trigger2.Anchored = true;
		trigger2.CanCollide = false;
		trigger2.Name = "Safe";
		trigger2.Parent = boundsModel;
	end

	local fenceParts = game:GetService("Workspace").Yard.Fence:GetChildren();
	for _,part in fenceParts do
		if (part:IsA("BasePart") and part.Size.Y == 9) then
			local cframe = part.CFrame;
			if (part.Orientation.Y == 180 or part.Orientation.Y == 0) then
				cframe *= CFrame.Angles(0,math.rad(180),0);
			end
			addBounds(cframe, part.Size);
		end
	end
	addBounds(CFrame.new(-35.4, 6.5, 121.3), Vector3.new(8,9,0.2));
	addBounds(CFrame.new(101, 6.5, 139.3), Vector3.new(8,9,0.2));

	local damageScript = Instance.new("Script");
	damageScript.Source = [[
local safePlayerMap = {};
local debouncePlayerMap = {};

for _,boundPart in script.Parent:GetChildren() do
	if (boundPart:IsA("BasePart")) then
		if (boundPart.Name == "Damage") then
			boundPart.Touched:Connect(function(part)
				if (safePlayerMap[part.Parent]) then
					safePlayerMap[part.Parent] = nil;
					debouncePlayerMap[part.Parent] = 0.5;
				elseif (not safePlayerMap[part.Parent] and not debouncePlayerMap[part.Parent] and part.Parent:FindFirstChild("Humanoid")) then
					part.Parent.Humanoid.Health = part.Parent.Humanoid.Health - 10;
					debouncePlayerMap[part.Parent] = 0.5;
				end
			end);
		elseif (boundPart.Name == "Safe") then
			boundPart.Touched:Connect(function(part)
				if (part.Parent:FindFirstChild("Humanoid")) then
					safePlayerMap[part.Parent] = true;
				end
			end);
		end
	end
end

game:GetService("RunService").Stepped:Connect(function(time, deltaTime)
	for player, debounce in debouncePlayerMap do
		debouncePlayerMap[player] -= deltaTime;
		if (debouncePlayerMap[player] <= 0) then
			debouncePlayerMap[player] = nil;
		end
	end
end);
		]];
	damageScript.Parent = boundsModel;
end

eval.check_scene = function()
end

eval.check_game = function()
	local fence = game:GetService("Workspace").Yard.Fence;
	local players = game:GetService("Players")
	local player = #players:GetPlayers() > 0 and players:GetPlayers()[1] or players.PlayerAdded:Wait()
	player:LoadCharacter()

	player.Character:PivotTo(CFrame.new(-35.4, 6.5, 121.3)*CFrame.new(0,0,-5));
	task.wait(0.5);
	player.Character.Humanoid:MoveTo((CFrame.new(-35.4, 6.5, 121.3)*CFrame.new(0,0,5)).Position);
	task.wait(1);
	local currentHealth = player.Character.Humanoid.Health;
	assert(player.Character.Humanoid.Health < player.Character.Humanoid.MaxHealth, "Player did not take damage from walking into the back yard");
	task.wait(0.5);
	player.Character.Humanoid:MoveTo((CFrame.new(-35.4, 6.5, 121.3)*CFrame.new(0,0,-5)).Position);
	task.wait(1);
	assert(player.Character.Humanoid.Health >= currentHealth, "Player took damage from exiting the back yard");

end

return eval
