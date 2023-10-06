--SERVICES--
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
--FOLDERS--
--MODULES--
local LimbCharacterClass = require(ServerStorage.LimbCharacter)
--VARIABLES--
local HEALTH_REGEN = 1

local Character: Model = script.Parent
local LimbCharactersTable = LimbCharacterClass.GetLimbCharactersTable()
local LimbCharacter = LimbCharactersTable[Character]
--FUNCTIONS--
local Regeneration = function(DeltaTime: number)
	for _, Child in pairs(Character:GetChildren()) do
		if not table.find(LimbCharacter.LimbsTable, Child.Name) then
			continue
		end
		if Child:GetAttribute("CanRegen") == false then
			continue
		end

		LimbCharacter:HealLimb(Child.Name, HEALTH_REGEN * DeltaTime)
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
