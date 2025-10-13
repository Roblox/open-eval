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
    scenario_name = "030_play_idle_animation_v2",
    prompt = {
                {
                    {
                        role = "user",
				content = [[generate a script that makes you play this animation everytime your idle in 5 seconds after your still idle: 507771019]],
                        request_id = "s20250722_017"
                    }
                }
            },
    place = "platformer.rbxl",
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
local OriginalSpace = utils_he.getAllReasonableItems()

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
	local newScript = Instance.new("Script")

	newScript.RunContext = Enum.RunContext.Client
	newScript.Source = [[local Character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
	local humanoid = Character:WaitForChild("Humanoid")
	local isIdle = false

while task.wait() do
		if humanoid.MoveDirection.Magnitude == 0 then
			isIdle = true
			task.wait(5)
			if isIdle then
				local animation = Instance.new("Animation")
				local id = "rbxassetid://507771019"
				animation.AnimationId = id
				animation.Parent = script
				--play the animation
				local track = humanoid:LoadAnimation(animation)
				track:Play()
				track.Ended:Connect(function()
					track:Destroy()
				end)
			end
		elseif  humanoid.MoveDirection.Magnitude > 0 then
			isIdle = false

		end
end]]
	newScript.Parent =  game:GetService("ReplicatedStorage")
end

eval.check_scene = function()
end

assert(eval.runConfig and eval.runConfig.clientChecks, "runConfig.clientChecks is required")
table.insert(eval.runConfig.clientChecks, function(logService)
	task.wait(5)

	local Character = game.Players.LocalPlayer.Character
	local score = 0

	while not Character do
		Character = game.Players.LocalPlayer.Character
		task.wait()
	end

	for i = 1, 200 do
		task.wait()
		local animTracksPlaying:{AnimationTrack} = Character.Humanoid.Animator:GetPlayingAnimationTracks()
		for _, track in pairs(animTracksPlaying) do
			if track.Animation.AnimationId == "rbxassetid://507771019" and track.IsPlaying then
				score += 1
			end
		end
		if score >= 15 then break end
	end

	assert(score >= 15, "Not playing while idle.")
end)

return eval
