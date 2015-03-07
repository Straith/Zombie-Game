include("shared.lua")
include("database/cl_database.lua")
include("database/items.lua")

GM.FirstPerson = CreateClientConVar( "mb_firstperson", 0, true, true )

local function keyQ()
	if input.IsKeyDown(KEY_Q) then
		net.Start("KEY_Q")
		net.SendToServer()
		
		hook.Call("KEY_Q", GAMEMODE, ply)
	end
end
hook.Add( "Think", "q_pressed", keyQ )

function GM:ShouldDrawLocalPlayer()
	if !self.FirstPerson:GetBool() then
		return true
	end
	return false
end

function GM:CalcView(ply, pos, angles, fov)
	--if self:IsCSpectating() && IsValid(self:GetCSpectatee()) then
--		ply = self:GetCSpectatee()
--	end
	if ply:IsPlayer() && !ply:Alive() then
		ply = ply:GetRagdollEntity()
	end
	if IsValid(ply) then
		if !self.FirstPerson:GetBool() || ply != LocalPlayer() then
			local trace = {}
			trace.start = ply:GetPos() + Vector(0, 0, 100)
			trace.endpos = trace.start + Vector(0, 0, 300)
			trace.filter = ply
			-- trace.mask = MASK_SHOT
			local tr = util.TraceLine(trace)

			local view = {}
			view.origin = tr.HitPos + Vector(0, 0, -5)
			view.angles = Angle(90,90,0)
			view.fov = fov
			return view
		end
	end
end

local lastangles = Angle()
function GM:CreateMove( cmd )

	if LocalPlayer():Alive() then
		if cmd:KeyDown(IN_JUMP) then
			cmd:SetButtons(bit.bor(cmd:GetButtons(), IN_JUMP))
		end
		if cmd:KeyDown(IN_DUCK) then
			cmd:SetButtons(bit.bor(cmd:GetButtons(), IN_ATTACK2))
		end
		--cmd:RemoveKey(IN_JUMP)
		--cmd:RemoveKey(IN_DUCK)
		cmd:SetUpMove(0)

		if !self.FirstPerson:GetBool() then
			cmd:ClearMovement()

			local vec = Vector(0, 0, 0)
			if cmd:KeyDown(IN_FORWARD) then
				cmd:SetForwardMove(100000)
				vec.y = 1
			elseif cmd:KeyDown(IN_BACK) then
				cmd:SetForwardMove(100000)
				vec.y = -1
			end

			if cmd:KeyDown(IN_MOVELEFT) then
				cmd:SetForwardMove(100000)
				lastangles = Angle(0, 180, 0)
				vec.x = -1
			elseif cmd:KeyDown(IN_MOVERIGHT) then
				cmd:SetForwardMove(100000)
				lastangles = Angle(0, 0, 0)
				vec.x = 1
			end

			if vec:Length() > 0 then
				lastangles = vec:Angle()
			end
			cmd:SetViewAngles(lastangles)
		else
		
		end
	end
end