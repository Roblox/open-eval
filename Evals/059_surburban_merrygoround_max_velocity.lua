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
    scenario_name = "059_surburban_merrygoround_max_velocity",
    prompt = {
                {
                    {
                        role = "user",
                        content = [[User's speed on MerryGoRound should cap at 1.]],
                        request_id = "s20250804_027"
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

local ServerEvalScriptSource = [[ -- struggle to get this to work with client/server differences
	local dummy = script:WaitForChild("Dummy")

	dummy.Parent = game.Workspace

	local merry = game:GetService("Workspace").Playground.MerryGoRound

	local function occupySeat(seat)
		local newDummy = dummy:Clone()
		newDummy.Parent = game:GetService("Workspace")
		task.wait(0.1)
		seat:Sit(newDummy:WaitForChild("Humanoid", 20))
	end

	for _, seat in merry:GetChildren() do
		if seat:IsA("Seat") then
			occupySeat(seat)
			seat:GetPropertyChangedSignal("Occupant"):Connect(function()
				task.wait()
				if seat.Occupant == nil then
					occupySeat(seat)
				end
			end)
		end
	end]]

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
	
	local _, dummy = next(game:GetObjects("rbxassetid://623773712"))
	local _, hat = next(game:GetObjects("rbxassetid://13700820")) hat.Parent = dummy -- check comment in check_scene for explaination
	local _, hat = next(game:GetObjects("rbxassetid://126383812997223")) hat.Parent = dummy
	for _, v in dummy:GetChildren() do if v:IsA("BasePart") then v.BrickColor = BrickColor.new("Medium brown") end end
	dummy.Name = "Dummy"

	local dummyScript = Instance.new("Script")
	dummy.Parent = dummyScript
	dummyScript.Source = ServerEvalScriptSource
	dummyScript.Name = "EvalScript"
	dummyScript.Parent = game:GetService("Workspace")
end

eval.reference = function()
	local merry = game:GetService("Workspace").Playground.MerryGoRound
	for _, obj in merry:GetDescendants() do
		if obj:IsA("LuaSourceContainer") then
			obj:Destroy()
		end
	end
	local newScript = Instance.new("Script")
	newScript.Source = [[local velocity = script.Parent.Platform.BodyAngularVelocity
local occupants = {}
local seats = {}

----- SETUP -----

for i, v in pairs(script.Parent:GetChildren()) do
	if v.ClassName == "Seat" then
		table.insert(seats, v)
	end
end

----- SEATS -----

for _, v in pairs(seats) do
	v.ChildAdded:Connect(function(obj) -- added
		if obj.Name == "SeatWeld" then
			local player = ""
			if player then
				table.insert(occupants, obj.Part1.Parent)
			end
		end
	end)
	v.ChildRemoved:Connect(function(obj) -- removed
		if obj.Name == "SeatWeld" then
			local player = ""
			if player then
				for i, occupant in pairs(occupants) do
					if occupant == player then
						table.remove(occupants, i)
					end
				end
			end
		end
	end)
end


----- FLING -----

function flingPlayer(player)
	player.Humanoid.PlatformStand = true
	wait(math.random(1,2))
	player.Humanoid.PlatformStand = false
end

----- RUN MERRY-GO-ROUND -----

while wait() do
	if #occupants > 0 then
		velocity.AngularVelocity = Vector3.new(
			velocity.AngularVelocity.X, 
			math.clamp(velocity.AngularVelocity.Y + 0.2, 0, 1),
			velocity.AngularVelocity.Z
		)
		wait(0.1)
		for i = 1, #occupants do -- finding occupants to possibly fling :P
			if occupants[i] then
				local randNum = 1
				if math.ceil(occupants[i].HumanoidRootPart.Velocity.Magnitude) > 1 then
					randNum = math.random(1, math.ceil(occupants[i].HumanoidRootPart.Velocity.Magnitude))
				end
				if randNum >= 40 then
					flingPlayer(occupants[i])
					table.remove(occupants, i)
				end
			end
		end
	elseif velocity.AngularVelocity.Y > 0 then -- slowing down
		velocity.AngularVelocity = velocity.AngularVelocity - Vector3.new(0, math.min(0.3, velocity.AngularVelocity.Y), 0)
	end
end]]
	newScript.Parent = merry

end

eval.check_scene = function()
end

eval.check_game = function()
	-- https://tenor.com/view/monkes-spinny-spin-spin-spinning-monkeys-monkey-spinnin'-spinnin-monkey-right-round-monke-monke-fun-spinny-gif-17124308933475975248
	
	-- failing the eval if it messed with my set up script
	local evalScript = game:GetService("Workspace"):FindFirstChild("EvalScript")
	assert(evalScript and evalScript.Enabled and evalScript.Source == ServerEvalScriptSource, "Part of the eval was deleted or modified. Please run setup again.")
	
	local vel = game:GetService("Workspace").Playground.MerryGoRound:WaitForChild("Platform", 20):WaitForChild("BodyAngularVelocity", 20)
	
	for i = 1, 10 do -- shortened from 30 to accelerate the test
		assert(vel.AngularVelocity.Magnitude <= 1, "Velocity exceeded 1.") -- lowered velocity cap to accelerate the test
		task.wait(0.5)
	end
	print("Success")
end

return eval
