// Made by Raven; Steam Acc: https://steamcommunity.com/id/amaroklopcic

local DEV_TESTING = false

include("shared.lua")

function ENT:Initialize()

	if CLIENT then
		hook.Add( "HUDPaint", self, self.DrawHUD )
		hook.Add( "PostDrawOpaqueRenderables", self, self.Draw3D2D )
	end
	
	self.alphaSwitch = 1
	self.alpha = 0
	
end

function ENT:Draw()
	
	self:DrawModel()
	
	tow_launcher = self
	
end

function ENT:DrawHUD()

	local tow_launcher = self
	tow_launcher.missile_ent = self:GetNWEntity( "currentAirborneMissile" )
	tow_launcher.owner = self:GetNWEntity("owner")

	if self:GetNWBool("isOccupied") && LocalPlayer() == tow_launcher.owner then
		
		if self:GetNWBool("isMissileAirborne") && !DEV_TESTING then
		
			if !self:GetNWBool("isRendered") then
			
				local tow_launcher_missle_cam = vgui.Create( 'DFrame' )
				tow_launcher_missle_cam:SetSize( ScrW(), ScrH() )
				tow_launcher_missle_cam:SetPos( 0, 0 )
				tow_launcher_missle_cam:ShowCloseButton(false)
				tow_launcher_missle_cam:SetTitle("")
				tow_launcher_missle_cam.Paint = function( self, w, h )
					
					if tow_launcher == NULL || tow_launcher == nil then self:Close() return end
					if tow_launcher.missile_ent == NULL || tow_launcher.missile_ent == nil then self:Close() return end
					
					if !self.zoom then self.zoom = 0 end
					
					self.zoomDist = ( tow_launcher:GetPos():DistToSqr( tow_launcher.missile_ent:GetPos() ) )
					self.zoom = math.Approach( self.zoom, self.zoomDist, FrameTime() * 20 ) -- max is prob like 30
					
					self.angle = ( tow_launcher.missile_ent:GetPos() - tow_launcher:GetPos() ):GetNormalized():Angle()
					
					self.plyFOV = math.Clamp( LocalPlayer():GetFOV() - self.zoom, 40, 90 )
					
					render.RenderView( {
						origin = tow_launcher:GetPos() - Vector( 0, 0, -50 ),
						angles = self.angle,
						x = 0,
						y = 0,
						w = ScrW(),
						h = ScrH(),
						fov = self.plyFOV,
						drawhud = true,
						drawviewmodel = false
					 } )
					
				end
				
				self:SetNWBool( "isRendered", true )
				
			end
			
		else
		
			self:SetNWBool( "isRendered", false )
			
			if !self:GetNWBool("isReloading") && self:GetNWInt("ammoLeft") > 1 then
				draw.SimpleText( "1 / "..self:GetNWInt("ammoLeft") - 1, "tow_hud40", ScrW() * 0.8, ScrH() * 0.8, Color( 255, 255, 255 ) )
			elseif !self:GetNWBool("isReloading") && self:GetNWInt("ammoLeft") == 1  then
				draw.SimpleText( "1 / "..self:GetNWInt("ammoLeft") - 1, "tow_hud40", ScrW() * 0.8, ScrH() * 0.8, Color( 255, 255, 255 ) )
			else
				draw.SimpleText( "0 / "..self:GetNWInt("ammoLeft"), "tow_hud40", ScrW() * 0.8, ScrH() * 0.8, Color( 255, 255, 255 ) )
			end
			
			if self.alpha == 255 then
				self.alphaSwitch = 1
			elseif self.alpha == 0 then
				self.alphaSwitch = 0
			end
			
			if self.alphaSwitch == 1 then
				self.alpha = math.Approach( self.alpha, 0, 800 * FrameTime() )
			elseif self.alphaSwitch == 0 then
				self.alpha = math.Approach( self.alpha, 255, 800 * FrameTime() )
			end
			
			if self:GetNWBool("isReloading") && self:GetNWInt("ammoLeft") > 0 then
				draw.SimpleText( "RELOADING", "tow_hud40", ScrW() * 0.8, ScrH() * 0.75, Color( 255, 255, 255, self.alpha ) )
			end
			
		end
		
	end

end

function ENT:Draw3D2D()
	
	if !self:GetNWBool("isOccupied") && LocalPlayer():GetPos():DistToSqr(self:GetPos()) < 1000000 then
	
		local angle = LocalPlayer():EyeAngles()
		local pos = self:GetPos() + angle:Up() + Vector( 0,0, 65 )
	 
		angle:RotateAroundAxis( angle:Forward(), 90 )
		angle:RotateAroundAxis( angle:Right(), 90 )
		
		cam.Start3D2D( pos, Angle( 0, angle.y, 90 ), 0.25 )
			draw.DrawText( "Ammo Left: "..self:GetNWInt("ammoLeft"), "tow_hud30", 2, 2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
		cam.End3D2D()
		
	end
	
end

function ENT:OnRemove()

	self:SetNWBool( "isOccupied", false )
	
	if tow_launcher_missle_cam then
		tow_launcher_missle_cam:Close()
	end

end