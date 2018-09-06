-- repair replacer skills

	Skill_RepSnipe = TankDefault:new{
		Name = "Focus Shot",
		Description = "Fire a 5 damage projectile only damaging enemies exactly 5 tiles away.",
		ProjectileArt = "effects/shot_sniper",
		Damage = 5,
		Push = 0,
		LaunchSound = "/weapons/unstable_cannon",
		ImpactSound = "/impact/generic/explosion",
		--TipImage = 
		TipImage = {
			Unit = Point(2,5),
			Enemy = Point(2,0),
			Target = Point(2,1),
		},
		CustomTipImage = "Skill_RepSnipe_Tip",
	}

	function Skill_RepSnipe:GetSkillEffect(p1,p2)
		local ret = SkillEffect()
		local direction = GetDirection(p2 - p1)
		local target = GetProjectileEnd(p1,p2)  
		local dir = GetDirection(p2 - p1)
		local origDamage = self.Damage
		if p1:Manhattan(target) ~= 5 then
			origDamage = 0
		end
		local damage = SpaceDamage(target, origDamage)
		damage.sAnimation = "explopush1_"..dir
		ret:AddProjectile(damage, self.ProjectileArt)
		return ret
	end
	
	Skill_RepSnipe_Tip = Skill_RepSnipe:new{}

	function Skill_RepSnipe_Tip:GetSkillEffect(p1, p2)
		local ret = SkillEffect()
		ret:AddScript([[
			local effect = SkillEffect()
			local damage = SpaceDamage(Point(2, 0), 5)
			damage.sAnimation = "explopush1_0"
			effect.piOrigin = Point(2, 5)
			effect:AddProjectile(damage, Skill_RepSnipe.ProjectileArt)
			Board:AddEffect(effect)
		]])
		return ret
	end

	Skill_RepRanged = TankDefault:new{
		Name = "Ranged Repair",
		Description = "Launch a projectile that repairs mechanical units for 2 health.",
		Damage = -2,
		Push = 0,
		LaunchSound = "/weapons/gravwell",
		ProjectileArt = "effects/shot_pull",
		TipImage = {
			Unit = Point(2,2),
			Friendly_Damaged = Point(2,0),
			Target = Point(2,0),
			Fire1 = Point(2,0),
		},
	}

	function Skill_RepRanged:GetSkillEffect(p1,p2)
		local ret = SkillEffect()
		local direction = GetDirection(p2 - p1)
		local target = GetProjectileEnd(p1,p2)  
		local origDamage = 0
		if Board:GetPawn(target) then
			if Board:GetPawn(target):GetTeam() == TEAM_PLAYER then
				origDamage = self.Damage
			end
		end
		local damage = SpaceDamage(target, origDamage)
		if Board:GetPawn(target) then
			if Board:GetPawn(target):GetTeam() == TEAM_PLAYER then
				damage.iFire = EFFECT_REMOVE
				damage.iAcid = EFFECT_REMOVE
				damage.iFrozen = EFFECT_REMOVE
			end
		end	
		ret:AddProjectile(damage, self.ProjectileArt)
		return ret
	end

	Skill_RepShield = SelfTarget:new{ 
		Name = "Preemptive Shield",
		Description = "Shields mech, but does not repair.",
		LaunchSound = "/weapons/area_shield",
		Explosion = "ExploRepulse1",
		Shield = 1,
		ShieldSelf = 1,
		TipImage = {
			Unit_Damaged = Point(2,3),
			Target = Point(2,3),
		},
	}
	
	function Skill_RepShield:GetSkillEffect(p1, p2)
		local ret = SkillEffect()
		ret:AddBounce(p1,-1)
		local selfDamage = SpaceDamage(p1,0)
		selfDamage.iShield = 1
		selfDamage.sAnimation = "ExploRepulse1"
		ret:AddDamage(selfDamage)
		return ret
	end	

-- TileShift

TileShiftSkill = {}

function TileShiftSkill:SetTileData(pawn, p1, p2)
	local TileShiftData = {{nil, 0, 0, 0}, {nil, 0, 0, 0}}
	-- TERRAIN_WATER
	-- TERRAIN_LAVA
	-- TERRAIN_ACID
	-- TERRAIN_HOLE
	if Board:GetTerrain(p1) ~= TERRAIN_WATER and Board:GetTerrain(p1) ~= TERRAIN_ICE
	and Board:GetTerrain(p1) ~= TERRAIN_HOLE
	and Board:GetTerrain(p2) ~= TERRAIN_WATER and Board:GetTerrain(p2) ~= TERRAIN_LAVA
	and Board:GetTerrain(p2) ~= TERRAIN_ACID and Board:GetTerrain(p2) ~= TERRAIN_HOLE then
		TileShiftData[1][1] = p1
		TileShiftData[1][2] = Board:IsFire(p1) and 1 or EFFECT_REMOVE
		TileShiftData[1][3] = Board:IsSmoke(p1) and 1 or EFFECT_REMOVE
		TileShiftData[1][4] = pawn:IsAcid() and 1 or EFFECT_REMOVE
		TileShiftData[2][1] = p2
		TileShiftData[2][2] = Board:IsFire(p2) and 1 or EFFECT_REMOVE
		TileShiftData[2][3] = Board:IsSmoke(p2) and 1 or EFFECT_REMOVE
		TileShiftData[2][4] = Board:IsAcid(p2) and 1 or EFFECT_REMOVE
		modApi:writeProfileData("TileShiftData", TileShiftData)
	end
	return TileShiftData
end

function TileShiftSkill:ShiftTilesTo(pawn, TileShiftData)
	-- 0 = manual move, 1 = undo
	-- if TileShiftData[1][1] then
		if TileShiftData[1][2] ~= TileShiftData[2][2] or 
			TileShiftData[1][3] ~= TileShiftData[2][3] or 
			TileShiftData[2][4] == 1 then
			local effect = SkillEffect()
			local damage = SpaceDamage(TileShiftData[2][1], 0)
			damage.iFire = TileShiftData[1][2] ~= TileShiftData[2][2] and TileShiftData[1][2] or 0
			damage.iSmoke = TileShiftData[1][3] ~= TileShiftData[2][3] and TileShiftData[1][3] or 0
			effect:AddDamage(damage)
			Board:AddEffect(effect)
			
			effect = SkillEffect()
			damage = SpaceDamage(TileShiftData[1][1], 0)
			damage.iFire = TileShiftData[1][2] ~= TileShiftData[2][2] and TileShiftData[2][2] or 0
			damage.iSmoke = TileShiftData[1][3] ~= TileShiftData[2][3] and TileShiftData[2][3] or 0
			if TileShiftData[2][4] == 1 then
				damage.iAcid = 1
			end
			effect:AddDamage(damage)
			Board:AddEffect(effect)
			pawn:SetAcid(TileShiftData[1][4] == 1)
		end
	-- end
end

function TileShiftSkill:ShiftTilesRev(pawn, TileShiftData)
	-- 0 = manual move, 1 = undo
	-- if TileShiftData[1][1] then
		if TileShiftData[1][2] ~= TileShiftData[2][2] or 
			TileShiftData[1][3] ~= TileShiftData[2][3] or 
			TileShiftData[2][4] == 1 then
			local effect = SkillEffect()
			local damage = SpaceDamage(TileShiftData[1][1], 0)
			damage.iFire = TileShiftData[1][2] ~= TileShiftData[2][2] and TileShiftData[1][2] or 0
			damage.iSmoke = TileShiftData[1][3] ~= TileShiftData[2][3] and TileShiftData[1][3] or 0
			effect:AddDamage(damage)
			Board:AddEffect(effect)
			pawn:SetAcid(TileShiftData[1][4] == 1)
			
			effect = SkillEffect()
			damage = SpaceDamage(TileShiftData[2][1], 0)
			damage.iFire = TileShiftData[1][2] ~= TileShiftData[2][2] and TileShiftData[2][2] or 0
			damage.iSmoke = TileShiftData[1][3] ~= TileShiftData[2][3] and TileShiftData[2][3] or 0
			if TileShiftData[2][4] == 1 then
				damage.iAcid = TileShiftData[2][4]
			end
			effect:AddDamage(damage)
			Board:AddEffect(effect)
		end
	-- end
end



-- KnoxMove

KnoxMove = {}

function KnoxMove:GetTargetArea(point)
	local ret = PointList()
	ret = Board:GetReachable(point, Pawn:GetMoveSpeed(), Pawn:GetPathProf())
	local retNeg = PointList()
	retNeg = Board:GetReachable(point, 3, Pawn:GetPathProf())
	local newRet = PointList()
	for i = 1, ret:size() do
		if not list_contains(extract_table(retNeg), ret:index(i)) then
			newRet:push_back(ret:index(i))
		end
	end
	return newRet
end

-- JustynFreeze

JustynFreeze = {}

function JustynFreeze:Freeze(point)
	local effect = SkillEffect()
	local damage = SpaceDamage(point, -1)
	damage.iFrozen = EFFECT_CREATE
	effect:AddDamage(damage)
	Board:AddEffect(effect)
end

-- AisaReflex

AisaReflex = {}

function AisaReflex:DoReflex(pawn, launchPos)
	if (pawn:GetSpace() == launchPos + DIR_VECTORS[DIR_UP] or
		pawn:GetSpace() == launchPos + DIR_VECTORS[DIR_DOWN] or
		pawn:GetSpace() == launchPos + DIR_VECTORS[DIR_LEFT] or
		pawn:GetSpace() == launchPos + DIR_VECTORS[DIR_RIGHT])
		and (not Board:IsPod(pawn:GetSpace()))
		and (Board:GetTerrain(pawn:GetSpace()) ~= TERRAIN_BUILDING)
		then
		--[[
		local doReflex = true
		for i = 1, #GAME.MezzPData[8][2] do
			if pawn:GetId() == GAME.MezzPData[8][2][i] then
				doReflex = false
				break
			end
		end
		if doReflex then]]--
			local effect = SkillEffect()
			local damage = SpaceDamage(pawn:GetSpace(), 1)
			damage.sAnimation = "SwipeClaw1"
			damage.sSound = "/weapons/sword"
			effect:AddDamage(damage)
			Board:AddEffect(effect)
			-- GAME.MezzPData[8][2][#GAME.MezzPData[8][2] + 1] = pawn:GetId()
			-- modApi:writeProfileData("MezzPData", GAME.MezzPData)
		-- end
	end
end

-- AkemiReturnFire

AkemiReturnFire = {}

function AkemiReturnFire:DoReturnFire(pawn, launchPos)
	local aimPos = pawn:GetSpace()
	if (launchPos.x == aimPos.x or
		launchPos.y == aimPos.y) then
		-- X: +bottom-right, right+/left
		-- Y: +bottom-left, down+/up
		local effect = SkillEffect()
		local dir = GetDirection(aimPos - launchPos)
		local target = GetProjectileEnd(launchPos, aimPos, PATH_PROJECTILE)
		local damage = SpaceDamage(target, 2)
		damage.sAnimation = "explopush1_"..dir
		effect:AddSound("/weapons/modified_cannons")
		effect:AddSound("/impact/generic/explosion")
		-- effect:AddProjectile(damage, "effects/shot_mechtank", 0.1)
		effect:AddDamage(damage)
		Board:AddEffect(effect)
		-- effect:AddProjectile(damage, "effects/shot_mechtank", NO_DELAY)
	end
end


--[[ Volta

VoltaSkill = {}
voltaUsed = false

function VoltaSkill:DoTheVolta()
	-- i name my functions however i want nerds
	local mechs = extract_table(Board:GetPawns(TEAM_PLAYER))
	for i,id in pairs(mechs) do
		if not Board:GetPawn(id):IsAbility("Volta") then
			local effect = SkillEffect()
			local damage = SpaceDamage(Board:GetPawnSpace(id), -1)
			damage.iFire = EFFECT_REMOVE
			damage.iAcid = EFFECT_REMOVE
			damage.iFrozen = EFFECT_REMOVE
			damage.iShield = EFFECT_CREATE
			ret:AddDamage(damage)
			effect:AddDamage(damage)
			Board:AddEffect(effect)
		end
	end
end

function VoltaSkill:CheckStatus()
	if MezzPData[5] and (not voltaUsed) then
		if Board:GetPawn(MezzPData[5]):IsDead() then
			VoltaSkill:DoTheVolta()
			voltaUsed = true
		end
	end
end
]]--
