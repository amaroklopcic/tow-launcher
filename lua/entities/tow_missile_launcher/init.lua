// Made by Raven; Steam Acc: https://steamcommunity.com/id/amaroklopcic

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

local STARTING_AMMO = 4
----====----====----====----====----

function ENT:Initialize()

	self:SetModel("models/kali/weapons/tow/m220 tow launcher.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	
	if phys:IsValid() then
	
		phys:Wake()
		phys:EnableMotion(false)
		
	end
	
	self.missile_fire_time = 0
	
	self:SetAngles( self:GetAngles() + Angle( 0, 180, 0 ) ) -- rotates 180 on spawn
	self:SetPos( self:GetPos() - Vector( 0, 0, 10 ) ) -- levels the tow launcher with the ground (model is sorta fucked :/)
	self:setMissileAirborne(false)
	
	hook.Add( "PlayerDeath", self, self.OnPlayerDeath )
	hook.Add( "PlayerFootstep", self, self.RemovePlayerFootsteps )
	hook.Add( "KeyPress", self, self.UseKey )
	
	if ConVarExists("tow_ammo_on_spawn") then
		self:SetNWInt("ammoLeft", GetConVar("tow_ammo_on_spawn"):GetInt() )
	else
		self:SetNWInt("ammoLeft", STARTING_AMMO )
	end
	
end

function ENT:setOccupied( bool )
	self:SetNWBool( "isOccupied", bool )
end

function ENT:isOccupied()
	return self:GetNWBool("isOccupied")
end

function ENT:setMissileAirborne( bool )
	self:SetNWBool( "isMissileAirborne", bool )
end

function ENT:isMissileAirborne()
	return self:GetNWBool("isMissileAirborne")
end

function ENT:setRendered( bool )
	self:SetNWBool( "isRendered", bool )
end

function ENT:isRendered()
	return self:GetNWBool("isRendered")
end

ENT.useCooldown = 0

function ENT:Use( activator, caller )
	
	if !( CurTime() > self.useCooldown ) then return end
	
	local vec = self:GetPos()
	
	if !self:isOccupied() then
		
		if caller:GetActiveWeapon():IsValid() then
			caller.prevWeapon = caller:GetActiveWeapon():GetClass()
		end
		
		caller:Give("tow_missile_launcher_swep")
		caller:SelectWeapon("tow_missile_launcher_swep")
		
		caller:SetPos( vec + self:GetRight() * -40 - self:GetForward() * 40 )
		caller:SetEyeAngles( Angle( self:GetAngles():Forward(), self:GetAngles().y, self:GetAngles().z ) )
		
		caller:SetMoveType(MOVETYPE_NONE)
		caller:SetParent(self)
		
		self:setOccupied(true)
		
		caller.isInTOWLauncher = true
		
	end
	
	self.useCooldown = CurTime() + 1
	
	self.owner = caller
	self:SetNWEntity( "owner", caller )
	
end

function ENT:UseKey( ply, key ) -- added this in so you don't have to look at the entity to exit

	if self:isOccupied() && !self:isMissileAirborne() && key == IN_USE then
	
		ply:StripWeapon("tow_missile_launcher_swep")
		
		if ply.prevWeapon then
			ply:SelectWeapon(ply.prevWeapon)
		end
		ply.prevWeapon = nil
		
		ply.isInTOWLauncher = true
		
		ply:SetPos( self:GetPos() + self:GetRight() * -40 )
		ply:SetEyeAngles( self.boneAng:Right():Angle() )
		
		ply:SetMoveType(MOVETYPE_WALK)
		ply:SetParent(nil)
		
		self:setOccupied(false)
		
		self.useCooldown = CurTime() + 1
		
	end

end

function ENT:Think()
	-- Bone: 	13	Launcher_Rot
	-- Bone: 	17	Launcher_Elev
	
	local reset = Angle( 0, 0, 0 )
	
	if self:isOccupied() then
		
		local testAng = self.owner:EyeAngles()
		local localAng = self:WorldToLocalAngles( testAng )
		
		self.boneVec, self.boneAng = self:GetBonePosition(17)
		
		self.clampAngX = math.Clamp( -localAng.x, -45, 45 )
		self.clampAngY = math.Clamp( localAng.y, -70, 70 )
		
		self:ManipulateBoneAngles( 17, Angle( 0, self.clampAngX, 0 ) ) -- main tube that every upper bone is parented to
		self:ManipulateBoneAngles( 13, Angle( 0, 0, self.clampAngY ) ) -- bone that the tube is parented to so we can rotate properly
		
		self.boneToGrndTrace = util.TraceLine( {
			start = self.boneVec,
			endpos = self.boneVec + ( self.boneAng:Right() * 1000 ),
			filter = self
		} )
		
		self.safetyTr = self.boneToGrndTrace.HitPos:DistToSqr( self.owner:GetPos() )
		
		if self.owner:KeyDown(IN_ATTACK) && CurTime() > self.missile_fire_time && !self:isMissileAirborne() && self.safetyTr > 700000 && self:GetNWInt("ammoLeft") > 0 then
			
			local missile = ents.Create("tow_missile")
			
			if !( IsValid( missile ) ) then return end
			
			missile.parent_launcher = self
			
			missile:Spawn()
			missile:SetPos( self.boneVec + self.boneAng:Right() * 55 )
			missile:SetAngles( self.boneAng:Right():Angle() )
			
			self:SetNWEntity( "currentAirborneMissile", missile )
			
			self.missile_sound_reset = 1
			self:SetNWInt( "ammoLeft", self:GetNWInt("ammoLeft") - 1 )
			
			self:setMissileAirborne(true)
			
		end
		
	else
	
		self:ManipulateBoneAngles( 17, reset )
		self:ManipulateBoneAngles( 13, reset )
		
	end
	
	if CurTime() > self.missile_fire_time then
		self:SetNWBool( "isReloading", false )
	end
	
	if !self:isMissileAirborne() && self.isReloading && !self.reloadSndPlayed && self:GetNWInt("ammoLeft") > 0 then
		self:EmitSound( "tow_reload" )
		self.reloadSndPlayed = true
	end
	
	self:NextThink( CurTime() ) -- increases the speed at which the :Think hook runs
	
	return true
	
end

function ENT:OnRemove()
	
	if self:isOccupied() then
	
		self.owner:SetMoveType(MOVETYPE_WALK)
		self.owner:SetParent(nil)
		self.owner:SetEyeAngles( self:GetForward():Angle() )
		
	end
	
	if self.owner && self.owner.prevWeapon then
		self.owner:SelectWeapon(self.owner.prevWeapon)
		self.owner:StripWeapon("tow_missile_launcher_swep")
		self.owner.prevWeapon = nil
	end
	
	self:StopSound("tow_reload")

end

function ENT:OnPlayerDeath( victim, inflictor, attacker ) -- args not needed

	victim:SetMoveType(MOVETYPE_WALK)
	victim:SetParent(nil)
	self:setOccupied(false)

end

function ENT:RemovePlayerFootsteps( ply, pos, foot, sound, volume )

	if self:isOccupied() && self.owner == ply then
		return true
	else
		return false
	end

end