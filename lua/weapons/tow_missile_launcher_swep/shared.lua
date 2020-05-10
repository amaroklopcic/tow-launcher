-- Made by Raven; Steam Acc: https://steamcommunity.com/id/amaroklopcic

if SERVER then
	AddCSLuaFile("shared.lua")
elseif CLIENT then
	SWEP.PrintName = ""
	SWEP.DrawCrosshair = true
end

SWEP.Category = "Other"

SWEP.Spawnable = false
SWEP.AdminSpawnable = false

SWEP.ViewModel = "models/weapons/v_hands.mdl"
SWEP.WorldModel = ""



SWEP.Primary.Ammo = "none"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1

SWEP.Secondary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1

SWEP.UseHands = false

function SWEP:Initialize()
	self:SetWeaponHoldType("magic")
end

function SWEP:PrimaryAttack()
	return
end

function SWEP:SecondaryAttack()
	return
end