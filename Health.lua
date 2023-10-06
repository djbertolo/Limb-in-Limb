--SERVICES--
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
--FOLDERS--
local PlayerModules = ServerStorage.PlayerModules
--MODULES--
local CharacterFunctions = require(PlayerModules.CharacterFunctions)
--VARIABLES--
local Character: Model = script.Parent

local HEALTH_REGEN = 1

local LimbsTable = CharacterFunctions.CharacterLimbsList[Character]
--FUNCTIONS--
local Regeneration = function(DeltaTime: number)
	for _, Child in pairs(Character:GetChildren()) do
		if not table.find(LimbsTable, Child.Name) then continue end
		if Child:GetAttribute("CanRegen") == false then continue end
		CharacterFunctions.HealLimb(Character, Child.Name, HEALTH_REGEN * DeltaTime)
	end
end

local HealthManager = function(DeltaTime: number)
	Regeneration(DeltaTime)
end
--SCRIPT--
repeat
	RunService.Heartbeat:Wait()
until Character:GetAttribute("Loaded") == true
RunService.Heartbeat:Connect(HealthManager)