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
    scenario_name = "018_weather_machine",
    prompt = {
                {
                    {
                        role = "user",
                        content = [[Create a 'WeatherMachine' part that, when activated, cycles through sunny, rainy, and foggy conditions every 3 seconds, visually affecting the entire game world.]],
                        request_id = "s20250722_004"
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

local LastCloudDetails:{cover:number, density:number} = {cover = nil, density = nil}
local LastAtmosphereDetails:{density:number,offset:number,color:Color3} = {density = nil, offset= nil,color=nil}

local LastSkyDetails = {
	front = nil,
	back = nil,
	left = nil,
	right = nil,
	up = nil,
	down = nil
}

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

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
	local weatherPart = Instance.new("Part")
		weatherPart.Size = Vector3.one * 2
		weatherPart.Anchored = true
		weatherPart.Position = Vector3.new(0,5,10)
		weatherPart.Color = Color3.fromRGB()
		weatherPart.Name = "WeatherMachine"
		weatherPart.Parent = Workspace
	local prompt = Instance.new("ProximityPrompt")
		prompt.Parent = weatherPart
	
	local weatherControllerScript = Instance.new("Script")
		weatherControllerScript.Name = "Weather Controller"
		weatherControllerScript.Parent = weatherPart
	
	local source = [[
			
local weatherPart = script.Parent


type conditions = "Sunny" | "Foggy" | "Rainy"
type skySettings = {
	up:string,
	down:string,
	left:string,
	right:string,
	front:string,
	back:string
}
type conditionDetails = {
	condition:conditions,
	cloudCover:number,
	cloudDensity:number,
	cloudColor:Color3,
	atmosphereDensity:number,
	atmosphereOffset:number,
	rainEnabled:boolean,
	skyInfo:skySettings,
	
	
}


function descendantsOfClass(className, descList)
	local out = {}
	descList = descList or game.Workspace:GetDescendants()
	for _, asset in pairs(descList) do
		if asset:IsA(className) then
			table.insert(out, asset)
		end
	end
	return out
end


local conditions:{conditionDetails} = {
	{
		condition = "Sunny",
		cloudCover = 0,
		cloudDensity = 0,
		cloudColor = Color3.fromRGB(255,255,255),
		atmosphereDensity = 0,
		atmosphereOffset = 0,
		rainEnabled = false,
		skyInfo = {
			up = "http://www.roblox.com/asset/?id=150335642",
			down ="http://www.roblox.com/asset/?id=150335585",
			left = "http://www.roblox.com/asset/?id=150335620",
			right = "http://www.roblox.com/asset/?id=150335610",
			front = "http://www.roblox.com/asset/?id=150335628",
			back = "http://www.roblox.com/asset/?id=150335574"
		}
	},
	{
		condition = "Foggy",
		cloudCover = .85,
		cloudDensity = 1,
		cloudColor = Color3.fromRGB(87, 88, 88),
		atmosphereDensity = 0.86,
		atmosphereOffset = 0.2,
		rainEnabled = false,
		skyInfo = {
			up = "http://www.roblox.com/asset/?id=11409819588",
			down ="http://www.roblox.com/asset/?id=11409818416",
			left = "http://www.roblox.com/asset/?id=11409818944",
			right = "http://www.roblox.com/asset/?id=11409819279",
			front = "http://www.roblox.com/asset/?id=11409818944",
			back = "http://www.roblox.com/asset/?id=11409818390"
		}
	},
	{
		condition = "Rainy",
		cloudCover = .85,
		cloudDensity = .25,
		cloudColor = Color3.fromRGB(87, 88, 88),
		atmosphereDensity = .253,
		atmosphereOffset = 0.2,
		rainEnabled = true,
		skyInfo = {
			up = "http://www.roblox.com/asset/?id=11409819588",
			down ="http://www.roblox.com/asset/?id=11409818416",
			left = "http://www.roblox.com/asset/?id=11409818944",
			right = "http://www.roblox.com/asset/?id=11409819279",
			front = "http://www.roblox.com/asset/?id=11409818944",
			back = "http://www.roblox.com/asset/?id=11409818390"
		}
	}
	
}

local enabled:boolean = false
local currentConditionIdx:number = 1



local function SetCondition(condition:conditionDetails)
	
	do 
		local currentSky = game.Lighting:FindFirstChildOfClass("Sky")
		if (not currentSky) then
			currentSky = Instance.new("Sky")
			currentSky.Parent = game.Lighting
		end
		currentSky.SkyboxFt = condition.skyInfo.front
		currentSky.SkyboxBk = condition.skyInfo.back
		currentSky.SkyboxUp = condition.skyInfo.up
		currentSky.SkyboxDn = condition.skyInfo.down
		currentSky.SkyboxLf = condition.skyInfo.left
		currentSky.SkyboxRt = condition.skyInfo.right
		
	end
	
	do
		local clouds:Clouds = workspace.Terrain:FindFirstChildOfClass("Clouds")

		if (not clouds) then
			clouds = Instance.new("Clouds")
			clouds.Parent = workspace.Terrain
		end

		clouds.Cover = condition.cloudCover
		clouds.Density = condition.cloudDensity
		clouds.Color = condition.cloudColor
	end
	
	do
		local atmosphere = game.Lighting:FindFirstChildOfClass("Atmosphere")
		atmosphere.Density = condition.atmosphereDensity
		atmosphere.Offset = condition.atmosphereOffset
	end
	
	do 
		local allEmitters:{ParticleEmitter} = descendantsOfClass("ParticleEmitter")

		for i,v in allEmitters do
			if (v.Name:lower():find("rain")) then
				v.Enabled = condition.rainEnabled
			end
		end
		
		
		
	end
	
end

local lastActivation:number = nil
local cooldown:number = 6
local currentTask:thread = nil
weatherPart.Touched:Connect(function(otherPart: BasePart) 
	if (lastActivation) then
		if (os.clock() - lastActivation < cooldown) then return
		else
			lastActivation = os.clock()
		end
	else
		lastActivation = os.clock()
	end
	
	enabled = not enabled
	weatherPart.Color = enabled and Color3.fromRGB(60, 255, 0) or Color3.fromRGB(255, 24, 0)
	
	if (enabled) then
		currentTask = task.spawn(function()
			while true do
				if (currentConditionIdx > #conditions) then
					currentConditionIdx = 1
				end
				SetCondition(conditions[currentConditionIdx])
				currentConditionIdx += 1
				task.wait(1)

			end
		end)
	else
		if (currentTask) then task.cancel(currentTask) end
	end
end)


	
	]]
	weatherControllerScript.Source = source
	
end


eval.check_scene = function()
	local weatherMachine:PVInstance = Workspace:FindFirstChild("WeatherMachine") or Workspace:FindFirstChild("Weather Machine")
	assert(weatherMachine ~= nil, `No model or part named "Weather Machine" was found in the Workspace`)
end

eval.check_game = function()
	local finished = false
	
	local weatherMachine:PVInstance = Workspace:FindFirstChild("WeatherMachine", true)
	assert(weatherMachine ~= nil and weatherMachine:IsA("BasePart"), `No model or part named "Weather Machine" was found in the Workspace`)
	
	local player = if #Players:GetPlayers() > 0 then Players:GetPlayers()[1] else Players.PlayerAdded:Wait()
	if not player.Character then
        player:LoadCharacter()
    end
    local character = player.Character
	
	local function CompareAtmosphere():boolean
		local atmosphere:Atmosphere = game:GetService("Lighting").Atmosphere
		local hasDifference:boolean = false

		if (atmosphere.Density ~= LastAtmosphereDetails.density) then hasDifference = true end
		if (atmosphere.Offset ~= LastAtmosphereDetails.offset) then hasDifference = true end
		if (atmosphere.Color ~= LastAtmosphereDetails.color) then hasDifference = true end

		return hasDifference

	end

	local function CompareSky():boolean
		local hasDifference = false
		local sky = Lighting:FindFirstChildOfClass("Sky")
		if (sky.SkyboxBk ~= LastSkyDetails.back) then hasDifference = true end
		if (sky.SkyboxFt ~= LastSkyDetails.front) then hasDifference = true end
		if (sky.SkyboxLf ~= LastSkyDetails.left) then hasDifference = true end 
		if (sky.SkyboxRt ~= LastSkyDetails.right) then hasDifference = true end 
		if (sky.SkyboxUp ~= LastSkyDetails.up) then hasDifference = true end 
		if (sky.SkyboxDn ~= LastSkyDetails.down) then hasDifference = true end 

		return hasDifference

	end

	local function SetEnviromentDetails()
		-- Set Atmosphere Details
		local atmosphere:Atmosphere = game:GetService("Lighting").Atmosphere
		LastAtmosphereDetails = {
			color = atmosphere.Color,
			density = atmosphere.Density,
			offset = atmosphere.Offset
		}

		-- Set sky details
		local sky = Lighting:FindFirstChildOfClass("Sky")
			LastSkyDetails.front = sky.SkyboxFt
			LastSkyDetails.back	 = sky.SkyboxBk
			LastSkyDetails.left = sky.SkyboxLf
			LastSkyDetails.right = sky.SkyboxRt
			LastSkyDetails.up = sky.SkyboxUp
			LastSkyDetails.down = sky.SkyboxDn
	end

	local function CompareEnvironments()
		local hasDifference = false

		if (CompareSky() == true or CompareAtmosphere() == true) then hasDifference = true end

		return hasDifference
	end

	local function RunTests():number
		local successfulRuns = 0
		task.wait(1)
		for i=1,3 do
			successfulRuns = CompareEnvironments() == true and successfulRuns + 1 or successfulRuns
			SetEnviromentDetails()
			task.wait(1)
		end
		return successfulRuns
	end


	SetEnviromentDetails()
	
	--Activated by touch
	character:PivotTo(weatherMachine:GetPivot())
	
	--Activated by proximity prompt
	local proxPrompt:ProximityPrompt? = weatherMachine:FindFirstChildWhichIsA("ProximityPrompt", true)
	if proxPrompt then
		proxPrompt:InputHoldBegin()
		task.wait(proxPrompt.HoldDuration + 0.1)
		proxPrompt:InputHoldEnd()
	end
	
	task.delay(1,function()
		character:PivotTo(CFrame.identity + Vector3.new(0,5,0))
	end)
	
	local goodRuns = RunTests()
	assert(goodRuns >= 2, "Insufficent amount of valid environment changes!")
end

return eval
