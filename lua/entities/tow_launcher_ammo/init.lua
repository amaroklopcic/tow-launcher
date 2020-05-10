// Made by Raven; Steam Acc: https://steamcommunity.com/id/amaroklopcic

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()

	self:SetModel("models/kali/weapons/tow/parts/m220 tow launcher missile tube.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	
	if phys:IsValid() then
	
		phys:Wake()
		
	end
	
end

function ENT:Think()
	
	if self.hasCollided then
		self.entityHit:SetNWInt( "ammoLeft", self.entityHit:GetNWInt("ammoLeft") + 1 )
		self:EmitSound("tow_ammo_sound")
		self:Remove()
	end
	
end

function ENT:PhysicsCollide( data, physCollide )
	
	if data.HitEntity:GetClass() == "tow_missile_launcher" then
		self.hasCollided = true
		self.entityHit = data.HitEntity
	end

end