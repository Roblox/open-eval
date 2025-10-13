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
    scenario_name = "026_make_traffic_light_v3",
    prompt = {
                {
                    {
                        role = "user",
                        content = [[write me a script for a simple 4 way traffic light]],
                        request_id = "s20250722_013"
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

local preWorkspace 

eval.setup = function()
	preWorkspace = game:GetService("Workspace"):GetDescendants()

    -- Iterate through all descendants of the game (DataModel)
    for _, instance in ipairs(game:GetDescendants()) do
        if instance:IsA('Script') then
            if (
                instance.Name == 'TrafficLightScript' or 
                instance.Name == 'TrafficLightTimeScript' or 
                instance.Name == 'TimeScript'
            ) then
                instance:Destroy()
            end
        end
    end

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
	newScript.Source = [[
	-- modify light objects to light color part
	local northLight = {
		red = game:GetService("Workspace").RoadSections["Regulated 4-Way Intersection"].IntersectionTrafficSignals.TrafficLightsA["Traffic Signal"].RedLight.SpotLight,
		yellow = game:GetService("Workspace").RoadSections["Regulated 4-Way Intersection"].IntersectionTrafficSignals.TrafficLightsA["Traffic Signal"].OrangeLight.SpotLight,
		green = game:GetService("Workspace").RoadSections["Regulated 4-Way Intersection"].IntersectionTrafficSignals.TrafficLightsA["Traffic Signal"].GreenLight.SpotLight
	}
	local southLight = {
		red = game:GetService("Workspace").RoadSections["Regulated 4-Way Intersection"].IntersectionTrafficSignals.TrafficLightsA["Traffic Signal"].RedLight.SpotLight,
		yellow = game:GetService("Workspace").RoadSections["Regulated 4-Way Intersection"].IntersectionTrafficSignals.TrafficLightsA["Traffic Signal"].OrangeLight.SpotLight,
		green = game:GetService("Workspace").RoadSections["Regulated 4-Way Intersection"].IntersectionTrafficSignals.TrafficLightsA["Traffic Signal"].GreenLight.SpotLight
	}
	local eastLight = {
		red = game:GetService("Workspace").RoadSections["Regulated 4-Way Intersection"].IntersectionTrafficSignals.TrafficLightsB["Traffic Signal"].RedLight.SpotLight,
		yellow = game:GetService("Workspace").RoadSections["Regulated 4-Way Intersection"].IntersectionTrafficSignals.TrafficLightsB["Traffic Signal"].OrangeLight.SpotLight,
		green = game:GetService("Workspace").RoadSections["Regulated 4-Way Intersection"].IntersectionTrafficSignals.TrafficLightsB["Traffic Signal"].GreenLight.SpotLight
	}
	local westLight = {
		red = game:GetService("Workspace").RoadSections["Regulated 4-Way Intersection"].IntersectionTrafficSignals.TrafficLightsB["Traffic Signal"].RedLight.SpotLight,
		yellow = game:GetService("Workspace").RoadSections["Regulated 4-Way Intersection"].IntersectionTrafficSignals.TrafficLightsB["Traffic Signal"].OrangeLight.SpotLight,
		green = game:GetService("Workspace").RoadSections["Regulated 4-Way Intersection"].IntersectionTrafficSignals.TrafficLightsB["Traffic Signal"].GreenLight.SpotLight
	}

	while true do
		-- east / west cycle
		eastLight.green.Enabled = true
		eastLight.yellow.Enabled = false
		eastLight.red.Enabled = false

		westLight.green.Enabled = true
		westLight.yellow.Enabled = false
		westLight.red.Enabled = false

		northLight.green.Enabled = false
		northLight.yellow.Enabled = false
		northLight.red.Enabled = true

		southLight.green.Enabled = false
		southLight.yellow.Enabled = false
		southLight.red.Enabled = true

		task.wait(6)
		-- e/w yellow
		eastLight.green.Enabled = false
		eastLight.yellow.Enabled = true
		eastLight.red.Enabled = false

		westLight.green.Enabled = false
		westLight.yellow.Enabled = true
		westLight.red.Enabled = false

		task.wait(2)
		-- red all
		eastLight.green.Enabled = false
		eastLight.yellow.Enabled = false
		eastLight.red.Enabled = true

		westLight.green.Enabled = false
		westLight.yellow.Enabled = false
		westLight.red.Enabled = true

		task.wait(1)
		-- n/s green
		northLight.green.Enabled = true
		northLight.yellow.Enabled = false
		northLight.red.Enabled = false

		southLight.green.Enabled = true
		southLight.yellow.Enabled = false
		southLight.red.Enabled = false

		task.wait(6)
		-- n/s yellow
		northLight.green.Enabled = false
		northLight.yellow.Enabled = true
		northLight.red.Enabled = false

		southLight.green.Enabled = false
		southLight.yellow.Enabled = true
		southLight.red.Enabled = false
		task.wait(2)

		northLight.green.Enabled = false
		northLight.yellow.Enabled = false
		northLight.red.Enabled = true

		southLight.green.Enabled = false
		southLight.yellow.Enabled = false
		southLight.red.Enabled = true
		task.wait(1)

	end
	]]
	newScript.Parent = game:GetService("Workspace")
end

eval.check_scene = function()

end

eval.check_game = function()

	local tab = utils_he.table_difference(preWorkspace, game:GetService("Workspace"):GetDescendants())
	local scriptCreated = false
	local lightString = false
	for _, obj in tab do
		if obj:IsA("Script")  then
			scriptCreated = true
			if obj.Source:lower():match("light") then
				lightString = true
			end
		end
	end
	assert(scriptCreated, "No Script created")
	assert(lightString, "No light signal in the script")	


	local red = game:GetService("Workspace").RoadSections["Regulated 4-Way Intersection"].IntersectionTrafficSignals.TrafficLightsA["Traffic Signal"].RedLight.SpotLight
	local yellow = game:GetService("Workspace").RoadSections["Regulated 4-Way Intersection"].IntersectionTrafficSignals.TrafficLightsA["Traffic Signal"].OrangeLight.SpotLight
	local green = game:GetService("Workspace").RoadSections["Regulated 4-Way Intersection"].IntersectionTrafficSignals.TrafficLightsA["Traffic Signal"].GreenLight.SpotLight

	local redB = game:GetService("Workspace").RoadSections["Regulated 4-Way Intersection"].IntersectionTrafficSignals.TrafficLightsB["Traffic Signal"].RedLight.SpotLight
	local yellowB = game:GetService("Workspace").RoadSections["Regulated 4-Way Intersection"].IntersectionTrafficSignals.TrafficLightsB["Traffic Signal"].OrangeLight.SpotLight
	local greenB = game:GetService("Workspace").RoadSections["Regulated 4-Way Intersection"].IntersectionTrafficSignals.TrafficLightsB["Traffic Signal"].GreenLight.SpotLight

	local changeSignalRed = false
	local changeSignalYellow = false
	local changeSignalGreen = false

	red.Changed:Connect(function(e)
		print("Event changed")
		if e == "Enabled" then
			changeSignalRed = true
		end
	end)
	yellow.Changed:Connect(function(e)
		print("Event changed")
		if e == "Enabled" then
			changeSignalYellow = true
		end
	end)
	green.Changed:Connect(function(e)
		print("Event changed")
		if e == "Enabled" then
			changeSignalGreen = true
		end
	end)

	redB.Changed:Connect(function(e)
		print("Event changed")
		if e == "Enabled" then
			changeSignalRed = true
		end
	end)
	yellowB.Changed:Connect(function(e)
		print("Event changed")
		if e == "Enabled" then
			changeSignalYellow = true
		end
	end)
	greenB.Changed:Connect(function(e)
		print("Event changed")
		if e == "Enabled" then
			changeSignalGreen = true
		end
	end)

	task.wait(20)
	assert((changeSignalRed and changeSignalGreen and changeSignalYellow), "No lights changed")
end

return eval
