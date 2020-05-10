// Made by Raven; Steam Acc: https://steamcommunity.com/id/amaroklopcic

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

local RELOAD_SPEED = 4
local TOW_DEFAULT_DMG = 500
local TOW_DEFAULT_RADIUS = 200

function ENT:Initialize()

	self:SetModel("models/kali/weapons/tow/parts/bgm-71 tow missile.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	
	if phys:IsValid() then
	
		phys:Wake()
		
	end
	
	self.rocketSound = 1
	self.runOnce = 0
	
	self.parent_launcher.isReloading = false
	
	if ConVarExists("tow_damage_modifier") then
		self.damageModifier = TOW_DEFAULT_DMG * GetConVar("tow_damage_modifier"):GetFloat()
	else
		self.damageModifier = TOW_DEFAULT_DMG
	end
	
	if ConVarExists("tow_radius_modifier") then
		self.radiusModifier = TOW_DEFAULT_RADIUS * GetConVar("tow_radius_modifier"):GetFloat()
	else
		self.radiusModifier = TOW_DEFAULT_RADIUS
	end
	
end

function ENT:Think()

	if !self.parent_launcher:IsValid() then 
		
		self:StopSound("tow_launcher_missile_fire")
		
		self:Remove()
		
		return 
	end
	
	local phys = self:GetPhysicsObject()
	
	local missile_effect_data = EffectData()
	missile_effect_data:SetOrigin( self:GetPos() )
	missile_effect_data:SetMagnitude( 1 )
	util.Effect( "MuzzleEffect", missile_effect_data )
	util.Effect( "ElectricSpark", missile_effect_data )
	
	if self.rocketSound == 1 then
		self:EmitSound( "tow_launcher_missile_fire", 100, 100, 1, CHAN_AUTO )
		self:EmitSound( "tow_missile_blast", 100, 100, 1, CHAN_AUTO )
		self.rocketSound = 0
	end
	
	phys:SetVelocity( self:GetVelocity() + self:GetAngles():Forward() * 1000 )
	self:SetAngles( self.parent_launcher.boneAng:Right():Angle() )
	
	-- runs when self collides
	if self.hasCollided == true && self.physCollide_data.HitEntity != self.parent_launcher then
		
		self.parent_launcher.missile_fire_time = CurTime() + RELOAD_SPEED
		
		local explosion = ents.Create("env_explosion")
		explosion:SetPos(self.physCollide_data.HitPos)
		explosion:SetOwner( self.parent_launcher.owner )
		explosion:SetKeyValue( "iMagnitude", "100" )
		explosion:Fire( "Explode", 0, 0 )
		explosion:EmitSound( "ambient/explosions/exp1.wav", 200, 200 )
		
		util.BlastDamage( self.parent_launcher, self.parent_launcher.owner, self.physCollide_data.HitPos, self.radiusModifier, self.damageModifier )
		
		self.parent_launcher.missile_blast_sound = 1
		self.parent_launcher:setMissileAirborne(false)
		
		self.parent_launcher:SetNWBool( "isReloading", true )
		self.parent_launcher.isReloading = true
		self.parent_launcher.reloadSndPlayed = false
		
		self:StopSound("tow_launcher_missile_fire")
		
		self:Remove()
		
	end
	
	-- Runs :Think at max speed
	self:NextThink( CurTime() )
	return true
		
end

function ENT:PhysicsCollide( data, physCollide )
	
	self.hasCollided = true
	self.physCollide_data = data

end