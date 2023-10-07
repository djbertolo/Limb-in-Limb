--SERVICES--
local RunService = game:GetService("RunService")
--FOLDERS--
--MODULES--
--VARIABLES + EVENT CONNECTIONS--
local LimbCharacter = {}
LimbCharacter.__index = LimbCharacter

local LimbCharactersTable = {}
LimbCharacter.DefaultAttributesTable = {
	["IsALimb"] = true,
	["Health"] = 100,
	["MaxHealth"] = 100,
	["CanRegen"] = true,
	["Enabled"] = true,
}
LimbCharacter.DefaultLimbsTable = {
	"Head",
	"Right Arm",
	"Left Arm",
	"Torso",
	"Right Leg",
	"Left Leg",
	"RightUpperArm",
	"RightLowerArm",
	"RightHand",
	"RightUpperLeg",
	"RightLowerLeg",
	"RightFoot",
	"LeftUpperArm",
	"LeftLowerArm",
	"LeftHand",
	"LeftUpperLeg",
	"LeftLowerLeg",
	"LeftFoot",
	"UpperTorso",
	"LowerTorso",
}
--FUNCTIONS--
--Combines AttributesTable with AdditionalAttributes and removes BlacklistAttributes
local GetAttributes = function(AdditionalAttributes, BlacklistAttributes)
	local AttributesTable = LimbCharacter.DefaultAttributesTable
	--Add Additional Attributes
	if AdditionalAttributes then
		for AttributeName, Value in pairs(AdditionalAttributes) do
			AttributesTable[AttributeName] = Value
		end
	end
	--Remove Blacklisted Attributes
	if BlacklistAttributes then
		for AttributeName, _ in pairs(AdditionalAttributes) do
			if table.find(AttributeName, BlacklistAttributes) then
				AttributesTable[AttributeName] = nil
			end
		end
	end

	return AttributesTable
end
--Combines LimbsTable with AdditionalLimbs and removes BlacklistLimbs
local GetLimbs = function(AdditionalLimbs, BlacklistLimbs)
	local LimbsTable = LimbCharacter.DefaultLimbsTable
	--Add Additional Limbs
	if AdditionalLimbs then
		for _, Limb in pairs(AdditionalLimbs) do
			table.insert(LimbsTable, Limb)
		end
	end
	--Remove Blacklist Limbs
	if BlacklistLimbs then
		for Index, Limb in pairs(LimbsTable) do
			if table.find(BlacklistLimbs, Limb) then
				table.remove(LimbsTable, Index)
			end
		end
	end

	return LimbsTable
end
--Toggles Ragdoll On
local RagdollOn = function(Character: Model, Limb)
	local LimbPart = Character:FindFirstChild(Limb)
	if not LimbPart then
		return
	end
	local Joint: Motor6D = LimbPart:FindFirstChildOfClass("Motor6D")
	if not Joint then
		return
	end

	local Attachment0 = Instance.new("Attachment")
	Attachment0.Name = "LimbCharacter_RagdollAttachment0"
	Attachment0.CFrame = Joint.C0
	Attachment0.Parent = Joint.Part0

	local Attachment1 = Instance.new("Attachment")
	Attachment1.Name = "LimbCharacter_RagdollAttachment1"
	Attachment1.CFrame = Joint.C1
	Attachment1.Parent = Joint.Part1

	local BallSocketConstraint = Instance.new("BallSocketConstraint")
	BallSocketConstraint.Name = "LimbCharacter_RagdollJoint"
	BallSocketConstraint.Attachment0 = Attachment0
	BallSocketConstraint.Attachment1 = Attachment1
	BallSocketConstraint.LimitsEnabled = true
	BallSocketConstraint.TwistLimitsEnabled = true
	BallSocketConstraint.Parent = Joint.Parent

	Joint.Enabled = false
end
--Toggles Ragdoll Off
local RagdollOff = function(Character: Model, Limb)
	local LimbPart = Character:FindFirstChild(Limb)
	if not LimbPart then
		return
	end
	local Joint: Motor6D = LimbPart:FindFirstChildOfClass("Motor6D")
	if not Joint then
		return
	end
	local BallSocketConstraint: BallSocketConstraint =
		LimbPart:FindFirstChild("LimbCharacter_RagdollJoint") :: BallSocketConstraint
	if not BallSocketConstraint then
		return
	end

	local Attachment0 = BallSocketConstraint.Attachment0
	local Attachment1 = BallSocketConstraint.Attachment1

	Attachment0:Destroy()
	Attachment1:Destroy()
	BallSocketConstraint:Destroy()

	Joint.Enabled = true
end

--Loop through Limbs List and SetUp Attributes
local SetAttributes = function(self)
	for _, Limb in pairs(self.LimbsTable) do
		for AttributeName, Value in pairs(self.AttributesTable) do
			local LimbPart: Part = self.Character:FindFirstChild(Limb)
			if not LimbPart then
				continue
			end
			LimbPart:SetAttribute(AttributeName, Value)
		end
	end

	self.Character:SetAttribute("Loaded", true)
end
--SCRIPT--
--[[
	Creates a LimbCharacter based on provided Character: Model
]]
--
function LimbCharacter.new(Character: Model, AdditionalLimbs, BlacklistLimbs, AdditionalAttributes, BlacklistAttributes)
	if not Character then
		return
	end
	local self = setmetatable({}, LimbCharacter)
	self.Character = Character
	self.LimbsTable = GetLimbs(AdditionalLimbs, BlacklistLimbs)
	self.AttributesTable = GetAttributes(AdditionalAttributes, BlacklistAttributes)

	--Set Attributes for all Limbs
	SetAttributes(self)
	--Make table read only to prevent from bricking the object
	table.freeze(self)
	--Add Character to table so other scripts can access
	LimbCharactersTable[Character] = self
	--Remove Character from table upon Character removal
	Character.Destroying:Connect(function()
		LimbCharactersTable[Character] = nil
	end)

	return self
end

function LimbCharacter.GetLimbCharactersTable()
	return LimbCharactersTable
end

function LimbCharacter:DisableLimb(Limb)
	local LimbPart = self.Character:FindFirstChild(Limb)
	if LimbPart then
		LimbPart:SetAttribute("LimbEnabled", false)
	end
end

function LimbCharacter:EnableLimb(Limb)
	local LimbPart = self.Character:FindFirstChild(Limb)
	if LimbPart then
		LimbPart:SetAttribute("LimbEnabled", true)
	end
end

function LimbCharacter:DamageLimb(Limb, DamageAmount)
	local LimbPart = self.Character:FindFirstChild(Limb)
	if not LimbPart then
		return
	end
	LimbPart:SetAttribute("Health", LimbPart:GetAttribute("Health") - DamageAmount)
	if LimbPart:GetAttribute("Health") < 0 then
		LimbPart:SetAttribute("Health", 0)
	end
end

function LimbCharacter:HealLimb(Limb, HealAmount)
	local LimbPart = self.Character:FindFirstChild(Limb)
	if not LimbPart then
		return
	end
	if LimbPart:GetAttribute("Health") < LimbPart:GetAttribute("MaxHealth") then
		LimbPart:SetAttribute("Health", LimbPart:GetAttribute("Health") + HealAmount)
	end
end

function LimbCharacter:RagdollOn(LimbsToRagdoll, LimbsToNotRagdoll)
	if LimbsToRagdoll and #LimbsToRagdoll > 0 then
		for _, Limb in pairs(LimbsToRagdoll) do
			RagdollOn(self.Character, Limb)
		end
	else
		for _, Child in pairs(self.Character:GetChildren()) do
			if Child:GetAttribute("IsALimb") == true then
				if LimbsToNotRagdoll and table.find(LimbsToNotRagdoll, Child.Name) then
					continue
				end
				RagdollOn(self.Character, Child)
			end
		end
	end
end

function LimbCharacter:RagdollOff(LimbsToUnragdoll, LimbsNotToUnragdoll)
	if LimbsToUnragdoll and #LimbsToUnragdoll > 0 then
		for _, Limb in pairs(LimbsToUnragdoll) do
			RagdollOff(self.Character, Limb)
		end
	else
		for _, Child in pairs(self.Character:GetChildren()) do
			if Child:GetAttribute("IsALimb") == true then
				if LimbsNotToUnragdoll and table.find(LimbsNotToUnragdoll, Child.Name) then
					continue
				end
				RagdollOff(self.Character, Child.Name)
			end
		end
	end
end

function LimbCharacter:RemoveLimb(Limb)
	local Humanoid: Humanoid = self.Character:WaitForChild("Humanoid") :: Humanoid

	local RemoveMeansDeath = { "Head", "Torso", "UpperTorso", "LowerTorso" }
	local LimbPart: Part = self.Character:FindFirstChild(Limb) :: Part
	if LimbPart then
		LimbPart.CanCollide = true
	end

	local Torso: Part = self.Character:FindFirstChild("Torso") or self.Character:FindFirstChild("LowerTorso")
	if Torso.Name == "LowerTorso" then
		local RemoveJoint
		repeat
			RemoveJoint = LimbPart:FindFirstChildOfClass("Motor6D")
			if not RemoveJoint.Part0 then
				return
			end
			if not table.find(self.LimbsTable, RemoveJoint.Part0.Name) then
				RemoveJoint = nil
			end
			RunService.Heartbeat:Wait()
		until RemoveJoint ~= nil
		RemoveJoint:Destroy()
	else
		local RemoveJoint
		for _, Child in pairs(Torso:GetChildren()) do
			if not Child:IsA("Motor6D") then
				return
			end
			if not Child.Part1 then
				return
			end
			if Child.Part1.Name == LimbPart.Name then
				RemoveJoint = Child
			end
		end
		if RemoveJoint then
			RemoveJoint:Destroy()
		end
	end

	if table.find(RemoveMeansDeath, Limb) then
		Humanoid.Health = 0
	end
end

return LimbCharacter
