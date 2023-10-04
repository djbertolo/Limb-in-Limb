--SERVICES--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
--FOLDERS--
--MODULES--
--VARIABLES + EVENT CONNECTIONS--
--FUNCTIONS--
--SCRIPT--
local CharacterFunctions = {}

function CharacterFunctions.CharacterAdded(Character: Model)
	repeat
		RunService.Heartbeat:Wait()
	until Character.Parent ~= nil
	Character.Parent = workspace.Live

	local LimbsTable = { "Head", "Right Arm", "Left Arm", "Torso", "Right Leg", "Left Leg", "Brain", "Heart" }
	for Index, Child in pairs(Character:GetChildren()) do
		if table.find(LimbsTable, Child.Name) then
			Child:SetAttribute("Health", 100)
			Child:SetAttribute("MaxHealth", 100)
			Child:SetAttribute("Strength", 100)
			Child:SetAttribute("MaxStrength", 100)
			Child:SetAttribute("CanRegen", true)
			Child:SetAttribute("Enabled", true)
		end
	end
	Character:SetAttribute("DefaultSpeed", 12)
	Character:SetAttribute("CanSprint", true)
	Character:SetAttribute("CanDodge", true)

	print("Added all attributes")
	Character:SetAttribute("Loaded", true)
end

function CharacterFunctions.DisableLimb(Character: Model, Limb)
	local LimbPart = Character:FindFirstChild(Limb)
	if LimbPart then
		LimbPart:SetAttribute("Enabled", false)
	end
end

function CharacterFunctions.HealLimb(Character: Model, Limb, HealAmount)
	local LimbPart = Character:FindFirstChild(Limb)
	if LimbPart and LimbPart:GetAttribute("Health") < LimbPart:GetAttribute("MaxHealth") then
		LimbPart:SetAttribute("Health", LimbPart:GetAttribute("Health") + HealAmount)
	end
end

function CharacterFunctions.RemoveLimb(Character: Model, Limb)
	local Humanoid: Humanoid = Character:WaitForChild("Humanoid") :: Humanoid
	local JointTable = {
		["Head"] = "Neck",
		["Right Arm"] = "Right Shoulder",
		["Left Arm"] = "Left Shoulder",
		["Right Leg"] = "Right Hip",
		["Left Leg"] = "Left Hip",
	}
	local RemoveMeansDeath = { "Head", "Brain", "Heart", "Torso" }
	local LimbPart: Part = Character:FindFirstChild(Limb) :: Part
	if LimbPart then
		LimbPart.CanCollide = true
	end
	local RemoveJoint = Character:WaitForChild("Torso"):FindFirstChild(JointTable[Limb])
	if RemoveJoint then
		RemoveJoint:Destroy()
	end
	if table.find(RemoveMeansDeath, Limb) then
		Humanoid.Health = 0
	end
end

return CharacterFunctions
