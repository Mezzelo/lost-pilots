local oldOrderMods = mod_loader.orderMods
function mod_loader.orderMods(self, options, savedOrder)
	local ret = oldOrderMods(self, options, savedOrder)
	
	local mod = mod_loader.mods["Mezz_Pilots"]
	mod.icon = mod.resourcePath .."img/icons/mod_icon.png"
	
	return ret
end

	local MezzPData = {{nil, 0}, nil, {nil, 0, 0, -1}, nil, nil, {nil, 0, false}, nil, {nil, {}}, {nil, true}}
	
	local TileShiftData = {{nil, 0, 0, 0}, {nil, 0, 0, 0}}
	local AzothData = {}
	
	local MezzProcessReload = false
	local MezzProcessReset = false
	local MezzTeamTurn = false

local function init(self)
	if modApiExt then
		mezzUniPilots_modApiExt = modApiExt
	else
		mezzUniPilots_modApiExt = require(self.scriptPath.."modApiExt/modApiExt")
		mezzUniPilots_modApiExt:init(self.scriptPath.."modApiExt/")
	end
	-- require(self.scriptPath.."hooks")
	require(self.scriptPath.."skills")
	require(self.scriptPath.."personalities/personalities")
	mezzUniPilots_replaceRepair = require(self.scriptPath.. "replaceRepair/replaceRepair")
	mezzUniPilots_replaceRepair:init(self, mezzUniPilots_modApiExt)
	-- a lot of this information should probably be parsed via the csv, but too lazy to integrate that here.
	-- if you make a pilot mod feel free to rip this.  that's what everyone else has been doing, but the more the merrier ^^
	-- this is made for bulk pilot additions, you're probably better off hardcoding 1 or 2.
	local customPilots = {
	{"Pilot_Veteran", "Veteran", "Victoria Swift", 0, SEX_FEMALE, "/voice/chen", "PassAllySpeed", "Command", "-1 move, all other allied mechs gain +1 move."},
	{"Pilot_Angel", "Angel", "Akemi Kobayashi", 0, SEX_FEMALE, "/voice/bethany", "RetRanged", "Return Fire", "Fires a 2 damage ranged attack towards any enemy that attacks when aligned with this mech."},
	{"Pilot_Ace", "Ace", "Knox Mandaba", 0, SEX_FEMALE, "/voice/bethany", "MoveRange", "Jetstream", "+3 move, but must move a minimum of 4 tiles to move at all."},
	{"Pilot_Physicist", "Physicist", "Solomon Renfield", 0, SEX_MALE, "/voice/ralph", "PassAccel", "Inertial Engines", "-1 move, mech gains 1 movement per turn."},
	{"Pilot_Sniper", "Sniper", "Grizzly Saeki", 0, SEX_FEMALE, "/voice/rust", "RepSnipe", "Focus Shot", "Instead of repairing, fires a 5 damage attack only damaging units exactly 5 tiles away."},
	{"Pilot_Orphan", "Orphan", "Masao Sy", 0, SEX_MALE, "/voice/rust", "RepRanged", "Ranged Repair", "Repair friendly mechs with a projectile for 2 health, cannot repair self."},
	{"Pilot_Climate", "Climate", "Arvin Sanjrani", 0, SEX_MALE, "/voice/henry", "TileShift", "Status Shift", "Swaps fire, smoke and A.C.I.D. of destination with current tile when manually moving between land tiles."},
	{"Pilot_Widow", "Widow", "Leta Narvaez", 0, SEX_FEMALE, "/voice/camila", "RepShield", "Preemptive Shield", "Shields on repair instead of repairing."},
	{"Pilot_Scavenger", "Scavenger", "Justyn Attlee", 0, SEX_MALE, "/voice/isaac", "RetFreeze", "Flash Freeze", "If injured, alive, and unfrozen when the player turn ends, mech automatically freezes and heals."},
	{"Pilot_Law", "Law", "Aisa Minh", 0, SEX_FEMALE, "/voice/lily", "RetMove", "Reflex", "Launches a 1 damage melee attack every time an enemy moves adjacent to this mech."},
	{"Pilot_Alchemist", "Alchemist", "Ezel Sinai", 0, SEX_MALE, "/voice/abe", "PassSlow", "Azoth", "Enemies lose 1 move a turn, enemies with over 3 move lose 2 move once."},
	-- {"Pilot_Poet", "Poet", "Sassoon", 1, SEX_MALE, "/voice/archimedes", "Volta", "Volta", "When disabled, repair and shield for all allied mechs. Immune to death."},
	}
	
	-- modApi:appendAsset("img/effects/repairBall.png", self.resourcePath.."img/effects/repairBall.png")
	
	for i = 1, #customPilots do
		modApi:appendAsset("img/portraits/pilots/"..customPilots[i][1]..".png", self.resourcePath.."img/portraits/pilots/"..customPilots[i][1]..".png")
		modApi:appendAsset("img/portraits/pilots/"..customPilots[i][1].."_2.png", self.resourcePath.."img/portraits/pilots/"..customPilots[i][1].."_2.png")
		modApi:appendAsset("img/portraits/pilots/"..customPilots[i][1].."_blink.png", self.resourcePath.."img/portraits/pilots/"..customPilots[i][1].."_blink.png")
		
		CreatePilot{
			Id = customPilots[i][1],
			Personality = customPilots[i][2],
			Name = customPilots[i][3],
			PowerCost = customPilots[i][4],
			Sex = customPilots[i][5],
			Voice = customPilots[i][6],
			Skill = customPilots[i][7],
		}
	end
	local oldSkillInfo = GetSkillInfo
	function GetSkillInfo(skill)
		for i = 1, #customPilots do
			if skill == customPilots[i][7] then 
				return PilotSkill(customPilots[i][8], customPilots[i][9])
			end
		end
		return oldSkillInfo(skill)
	end
	
	mezzUniPilots_replaceRepair:ForPilot("RepSnipe", "Skill_RepSnipe", 
		{"Focus Shot", "Fire a 5 damage projectile only damaging enemies exactly 5 tiles away."}, self.resourcePath.."img/weapons/repSnipe.png")
	mezzUniPilots_replaceRepair:ForPilot("RepRanged", "Skill_RepRanged", 
		{"Ranged Repair", "Repair mechs for 2 health with a projectile."}, self.resourcePath.."img/weapons/repRanged.png")
	mezzUniPilots_replaceRepair:ForPilot("RepShield", "Skill_RepShield", 
		{"Preemptive Shield", "Shields mech instead of repairing."}, self.resourcePath.."img/weapons/repShield.png")
	
end

-- forewarning: a lot of these solutions are messy as FUCK
-- some of them are surprisingly eloquent for the workarounds I've needed.
-- pick and choose as desired.

local function getOGWS(searchId)
	return _G[Board:GetPawn(searchId):GetType()].MoveSpeed
end

local function initializeAbilityData()
	TileShiftData = {{nil, 0, 0, 0}, {nil, 0, 0, 0}}
	AzothData = {}
	MezzPData = {{nil, 0}, nil, {nil, 0, 0, -1}, nil, nil, {nil, 0, false}, nil, {nil, {}}, {nil, true}}
	MezzTeamTurn = false
	-- 1:swift, 2:farfan, 3:renfield, 4:sinai, 5:arvin, 6:attlee, 7:kobayashi, 8:minh, 9:saeki
	-- general stored data for pilots, typically only necessary for pilots requiring routine checks after actions (i.e. turn passes or enemy acts) requiring lookup
	-- clunky solution but I wanted something that didn't require constant lookups.  maybe I'll modularize it later.
	-- lua data types gone WILD
end

local function rwAbilityData(shouldWrite)
	-- detect pilots with passive abilities when the mission starts.
	if (shouldWrite) then
		local mechs = extract_table(Board:GetPawns(TEAM_PLAYER))
		for i,id in pairs(mechs) do
			if Board:GetPawn(id):IsAbility("PassAllySpeed") then
				MezzPData[1] = {id, 1}
				-- is pilot alive: 1 = alive, 0 = dead, -1 = requires processing.
			elseif Board:GetPawn(id):IsAbility("MoveRange") then 
				MezzPData[2] = id
			elseif Board:GetPawn(id):IsAbility("PassAccel") then 
				MezzPData[3] = {id, 0, getOGWS(id), -1}
			elseif Board:GetPawn(id):IsAbility("PassSlow") then 
				MezzPData[4] = id
			elseif Board:GetPawn(id):IsAbility("TileShift") then 
				MezzPData[5] = id
			elseif Board:GetPawn(id):IsAbility("RetFreeze") then
				MezzPData[6] = {id, Board:GetPawn(id):GetHealth(), false}
			elseif Board:GetPawn(id):IsAbility("RetRanged") then
				MezzPData[7] = id
			elseif Board:GetPawn(id):IsAbility("RetMove") then
				MezzPData[8] = {id, {}}
			elseif Board:GetPawn(id):IsAbility("RepSnipe") then
				MezzPData[9] = {id, true}
			end
		end
		modApi:writeProfileData("MezzPData", MezzPData)
		modApi:writeProfileData("AzothData", AzothData)
		modApi:writeProfileData("MezzTeamTurn", MezzTeamTurn)
		modApi:writeProfileData("TileShiftData", TileShiftData)
	else
		MezzPData = modApi:readProfileData("MezzPData")
		-- GAME.BWS = modApi:readProfileData("BWS")
		AzothData = modApi:readProfileData("AzothData")
		MezzTeamTurn = modApi:readProfileData("MezzTeamTurn")
		TileShiftData = modApi:readProfileData("TileShiftData")
	end
end

local function processMoveSpeeds()
	local mechs = extract_table(Board:GetPawns(TEAM_PLAYER))
	for i,id in pairs(mechs) do
		if MezzPData[1][1] then
			if id == MezzPData[1][1] then
				Board:GetPawn(id):SetMoveSpeed(getOGWS(id) - 1)
			else
				Board:GetPawn(id):SetMoveSpeed(getOGWS(id) + MezzPData[1][2])
			end
		else
			Board:GetPawn(id):SetMoveSpeed(getOGWS(id))
		end
		-- Board:GetPawn(id):SetMoveSpeed(getOGWS(id)
		-- + (MezzPData[1][1] and not Board:GetPawn(id):IsAbility("PassAllySpeed") and (getOGWS(id) > 0) and MezzPData[1][2] == 1 and 1 or 0)
		-- + (MezzPData[1][1] and Board:GetPawn(id):IsAbility("PassAllySpeed") and (getOGWS(id) > 0) and MezzPData[1][2] == 1 and -1 or 0)
		-- )
	end
	if MezzPData[3][1] then
		Board:GetPawn(MezzPData[3][1]):SetMoveSpeed(MezzPData[3][3] + MezzPData[3][4] +
			MezzPData[1][2])
	end
	if MezzPData[4] then
		-- Board:GetPawn(MezzPData[4]):SetMoveSpeed(getOGWS(MezzPData[4]) - 1 +
		-- MezzPData[1][2])
		for g = 1, #AzothData do
			if Board:GetPawn(AzothData[g][1]) then
				Board:GetPawn(AzothData[g][1]):SetMoveSpeed(math.max(AzothData[g][3] - AzothData[g][2]
					- (AzothData[g][3] > 3 and 1 or 0), 0))
				-- math.floor(AzothData[g][3]/2)
			end
		end
	end
	if MezzPData[2] then
		Board:GetPawn(MezzPData[2]):SetMoveSpeed(getOGWS(MezzPData[2]) + 3 +
		MezzPData[1][2])
	end
end

-- normally averse to haphazardly throwing around calls like this but i GOTTA GET WRITIN' SOON
-- theoretically, this should always be safe to call w/out destroying any data.
local function runUpdateCorrections()
	if TileShiftData ~= nil and MezzPData then
		if TileShiftData[1][1] ~= nil and TileShiftData[2][1] ~= nil and MezzPData[5] ~= nil 
			and Board then
			if Board:GetPawn(MezzPData[5]) then
				if Board:GetPawn(MezzPData[5]):IsAcid() ~= (TileShiftData[1][4] == 1) then
					Board:GetPawn(MezzPData[5]):SetAcid(TileShiftData[1][4] == 1)
				end
			end
		end
	end
	if MezzProcessReload then
		initializeAbilityData()
		rwAbilityData(false)
		MezzProcessReload = false
		processMoveSpeeds()
	end
	if MezzProcessReset then
		if MezzPData[9][1] then
			MezzPData[9][2] = true
		end
		if MezzPData[1][1] and Board:GetPawn(MezzPData[1][1]) then
			MezzPData[1][2] = Board:GetPawn(MezzPData[1][1]):IsDead() and 0 or 1
		end
		TileShiftData = {{nil, 0, 0, 0}, {nil, 0, 0, 0}}
		processMoveSpeeds()
		modApi:writeProfileData("MezzPData", MezzPData)
		modApi:writeProfileData("TileShiftData", TileShiftData)
		MezzProcessReset = false
	end
end

	-- OVERRIDES
	
	local origMoveArea = Move.GetTargetArea
	
	function Move:GetTargetArea(point)
		if Board:GetPawn(point):IsAbility("MoveRange") then
			return KnoxMove:GetTargetArea(point)
		end
		return origMoveArea(self, point)
	end

local function load(self,options,version)
	mezzUniPilots_modApiExt:load(self, options, version)
	mezzUniPilots_replaceRepair:load(self, options, version)
	
	modApi:addPostStartGameHook(function()
		if MezzPData == nil then MezzPData = {{nil, 0}, nil, {nil, 0, 0, -1}, nil, nil, {nil, 0, false}, nil, {nil, {}}, {nil, true}} end
		if TileShiftData == nil then TileShiftData = {{nil, 0, 0, 0}, {nil, 0, 0, 0}} end
		-- fire, smoke, acid.
		if AzothData == nil then AzothData = {} end
		MezzProcessReset = false
		MezzProcessReload = false
		-- using this to run a jank post turnresethook/gameloadedhook because order of hook calls doesn't work for my needs :/.	
		MezzTeamTurn = false
		-- which team's turn it is based on the last action taken cause nextturnhook doesn't call when you end your turn, rather when vek end their attacks.
		-- true = players, false = enemies.
		-- TODO: REMOVE THIS JANK ASS CHECK
		initializeAbilityData()
	end)
	
	-- modApi:addPostStartGameHook(function()
	
	-- end)
					
	
	modApi:addMissionStartHook(function()
		if MezzPData == nil then MezzPData = {{nil, 0}, nil, {nil, 0, 0, -1}, nil, nil, {nil, 0, false}, nil, {nil, {}}, {nil, true}} end
		if TileShiftData == nil then TileShiftData = {{nil, 0, 0, 0}, {nil, 0, 0, 0}} end
		-- fire, smoke, acid.
		if AzothData == nil then AzothData = {} end
		MezzProcessReset = false
		MezzProcessReload = false
		-- using this to run a jank post turnresethook/gameloadedhook because order of hook calls doesn't work for my needs :/.	
		MezzTeamTurn = false
		
		initializeAbilityData()
		rwAbilityData(true)
		processMoveSpeeds()
	end)
	
	modApi:addNextTurnHook(function()		
		-- LOG("TURN STARTING NOW: "..Game:GetTurnCount())
		-- VoltaSkill:CheckStatus()
		if Game:GetTeamTurn() == TEAM_PLAYER then
			processMoveSpeeds()
			if MezzPData[6][1] then
				if Board:GetPawn(MezzPData[6][1]):GetHealth() < MezzPData[6][2] and (not Board:GetPawn(MezzPData[6][1]):IsFrozen())
					and (not Board:GetPawn(MezzPData[6][1]):IsDead()) and (not MezzPData[6][3]) and MezzTeamTurn == TEAM_PLAYER then
					-- probably some redundant checks here, clean up later.
					JustynFreeze:Freeze(Board:GetPawnSpace(MezzPData[6][1]))
				end
				MezzPData[6][3] = false
				modApi:writeProfileData("MezzPData", MezzPData)
			end
			if MezzPData[4] then
				for g = 1, #AzothData do
					if Board:GetPawn(AzothData[g][1]) then
						if (not Board:GetPawn(AzothData[g][1]):IsDead()) then AzothData[g][2] = AzothData[g][2] + 1 end
						Board:GetPawn(AzothData[g][1]):SetMoveSpeed(math.max(AzothData[g][3] - AzothData[g][2]
							- (AzothData[g][3] > 3 and 1 or 0), 0))
						-- math.floor(AzothData[g][3]/2)
					end
				end
				modApi:writeProfileData("AzothData", AzothData)
			end
		elseif Game:GetTeamTurn() == TEAM_ENEMY then
			TileShiftData = {{nil, 0, 0, 0}, {nil, 0, 0, 0}}
			if MezzPData[8][1] then
				MezzPData[8][2] = {}
				-- mod:writeProfileData("MezzPData", MezzPData)
			end
			if MezzPData[6][1] then
				if Board:GetPawn(MezzPData[6][1]):GetHealth() < MezzPData[6][2] and (not Board:GetPawn(MezzPData[6][1]):IsFrozen())
					and (not Board:GetPawn(MezzPData[6][1]):IsDead()) and (not MezzPData[6][3]) and MezzTeamTurn == TEAM_PLAYER then
					-- probably some redundant checks here, clean up later.
					JustynFreeze:Freeze(Board:GetPawnSpace(MezzPData[6][1]))
				end
				MezzPData[6][3] = false
				modApi:writeProfileData("MezzPData", MezzPData)
			end
			if MezzPData[3][1] then
				if MezzPData[3][2] ~= Game:GetTurnCount() and not Board:GetPawn(MezzPData[3][1]):IsDead() then
					MezzPData[3][4] = MezzPData[3][4] + 1
					Board:GetPawn(MezzPData[3][1]):SetMoveSpeed(MezzPData[3][3] + MezzPData[3][4] +
						MezzPData[1][2])
					MezzPData[3][2] = Game:GetTurnCount()
					modApi:writeProfileData("MezzPData", MezzPData)
				end
			end
		end
		MezzTeamTurn = Game:GetTeamTurn() == TEAM_PLAYER
	end)
	
	modApi:addMissionEndHook(function()
		-- reset walkspeed of all units just to be safe.
		local mechs = extract_table(Board:GetPawns(TEAM_PLAYER))
		for i,id in pairs(mechs) do
			if (getOGWS(id) > -1) then
				Board:GetPawn(id):SetMoveSpeed(getOGWS(id))
			end
		end
		
		--[[
		if MezzPData[5] then
			if (Board:GetPawn(MezzPData[5]):IsDead()) then
				local effect = SkillEffect()
				local damage = SpaceDamage(Board:GetPawnSpace(MezzPData[5]), -1)
				effect:AddDamage(damage)
				Board:AddEffect(effect)
			end
		end
		]]--
	end)
	
	mezzUniPilots_modApiExt:addPawnTrackedHook(function(mission, pawn)
		if pawn then
			if MezzPData[4] and pawn:GetTeam() == TEAM_ENEMY then
				if AzothData == nil then
					AzothData = {}
				end
				AzothData[#AzothData + 1] = {pawn:GetId(), 0, getOGWS(pawn:GetId())}
				modApi:writeProfileData("AzothData", AzothData)
			end
		end
	end)
	
	mezzUniPilots_modApiExt:addSkillBuildHook(function(mission, pawn, weaponId, p1, p2, skillEffect)
		-- been calling for me from hangar or some similar point for some reason.
		if GetCurrentMission() then
			runUpdateCorrections()
			-- probably conflicts with overwatch unfortunately, although I haven't tested.  no way to determine whose turn specifically, see above :/
			if MezzPData[6][1] and pawn:GetTeam() == TEAM_ENEMY and MezzTeamTurn then
				if Board:GetPawn(MezzPData[6][1]):GetHealth() < MezzPData[6][2] and (not Board:GetPawn(MezzPData[6][1]):IsFrozen())
					and (not Board:GetPawn(MezzPData[6][1]):IsDead()) then
					JustynFreeze:Freeze(Board:GetPawnSpace(MezzPData[6][1]))
					modApi:writeProfileData("MezzPData", MezzPData)
				end
				MezzPData[6][3] = true
			end
			MezzTeamTurn = pawn:GetTeam() ~= TEAM_ENEMY
		end
	end)
	
	mezzUniPilots_modApiExt:addPawnPositionChangedHook(function(mission, pawn, oldPosition)
		if pawn:GetTeam() == TEAM_ENEMY then
			if MezzPData[8][1] then
				if (not Board:GetPawn(MezzPData[8][1]):IsDead()) and (not Board:GetPawn(MezzPData[8][1]):IsFrozen()) then
					AisaReflex:DoReflex(pawn, Board:GetPawnSpace(MezzPData[8][1]))
				end
			end
		end
	end)
	
	mezzUniPilots_modApiExt:addPawnDamagedHook(function(mission, pawn, damageTaken)

	end)
	
	mezzUniPilots_modApiExt:addSkillEndHook(function(mission, pawn, skillId, p1, p2)
		if MezzPData[1][1] then
			if (MezzPData[1][2] == 1 and Board:GetPawn(MezzPData[1][1]):IsDead() or MezzPData[1][2] == 0 and (not Board:GetPawn(MezzPData[1][1]):IsDead())) then
				MezzPData[1][2] = Board:GetPawn(MezzPData[1][1]):IsDead() and 0 or 1
				processMoveSpeeds()
				modApi:writeProfileData("MezzPData", MezzPData)
			end
		end
		if skillId == "Move" and pawn:IsAbility("TileShift") then
			TileShiftSkill:ShiftTilesTo(pawn, TileShiftData)
		elseif skillId == "Move" and pawn:IsAbility("RepSnipe") then
			MezzPData[9][2] = false
			modApi:writeProfileData("MezzPData", MezzPData)
		end
		-- VoltaSkill:CheckStatus()
	end)
	
	mezzUniPilots_modApiExt:addSkillStartHook(function(mission, pawn, skillId, p1, p2)
		if skillId == "Move" and pawn:IsAbility("TileShift") then
			TileShiftData = TileShiftSkill:SetTileData(pawn, p1, p2)
		elseif skillId ~= "Move" and pawn:IsAbility("TileShift") then
			TileShiftData = {{nil, 0, 0, 0}, {nil, 0, 0, 0}}
			modApi:writeProfileData("TileShiftData", TileShiftData)
		end
	end)
	
	mezzUniPilots_modApiExt:addPawnUndoMoveHook(function(mission, pawn, undonePosition)
		if MezzPData[1][1] then
			if (MezzPData[1][2] == 1 and Board:GetPawn(MezzPData[1][1]):IsDead() or MezzPData[1][2] == 0 and (not Board:GetPawn(MezzPData[1][1]):IsDead())) then
				MezzPData[1][2] = Board:GetPawn(MezzPData[1][1]):IsDead() and 0 or 1
				processMoveSpeeds()
				modApi:writeProfileData("MezzPData", MezzPData)
			end
		end
		if pawn:IsAbility("TileShift") then
			TileShiftData[1][1] = pawn:GetSpace()
			TileShiftData[2][1] = undonePosition
			TileShiftSkill:ShiftTilesRev(pawn, TileShiftData)
			TileShiftData = {{nil, 0, 0, 0}, {nil, 0, 0, 0}}
			modApi:writeProfileData("TileShiftData", TileShiftData)
		end
		if pawn:IsAbility("RepSnipe") then
			MezzPData[9][2] = true
			modApi:writeProfileData("MezzPData", MezzPData)
		end
	end)
	
	
	mezzUniPilots_modApiExt:addQueuedSkillEndHook(function(mission, pawn, skillId, p1, p2)
		if pawn:GetTeam() == TEAM_ENEMY and MezzPData[7] then
			if (not Board:GetPawn(MezzPData[7]):IsDead()) and
				(not Board:GetPawn(MezzPData[7]):IsFrozen()) then
				AkemiReturnFire:DoReturnFire(pawn, Board:GetPawnSpace(MezzPData[7]))
			end
		end
		if MezzPData[1][1] then
			if (MezzPData[1][2] == 1 and Board:GetPawn(MezzPData[1][1]):IsDead() or MezzPData[1][2] == 0 and (not Board:GetPawn(MezzPData[1][1]):IsDead())) then
				MezzPData[1][2] = Board:GetPawn(MezzPData[1][1]):IsDead() and 0 or 1
				processMoveSpeeds()
				modApi:writeProfileData("MezzPData", MezzPData)
			end
		end
	end)
	
	mezzUniPilots_modApiExt:addPawnKilledHook(function(mission, pawn)
		if MezzPData[1][1] then
			if Board:GetPawn(MezzPData[1][1]) then
				if (MezzPData[1][2] == 1 and Board:GetPawn(MezzPData[1][1]):IsDead() or MezzPData[1][2] == 0 and (not Board:GetPawn(MezzPData[1][1]):IsDead())) then
					MezzPData[1][2] = Board:GetPawn(MezzPData[1][1]):IsDead() and 0 or 1
					processMoveSpeeds()
					modApi:writeProfileData("MezzPData", MezzPData)
				end
			end
		end
	end)
	
	mezzUniPilots_modApiExt:addResetTurnHook(function(mission)
		MezzProcessReset = true
		-- movespeed is reset *after* resetTurnHook.  Man, that's irritating!
	end)
	
	-- TODO: REPLACE WITH PAWNDESELECTED HOOK
	-- The intent was for this hook to be used as it fires less regularly than missionUpdate
	-- but it still fires a lot.  we should be able to optimize this further
	-- (except for arvin's ability: not terribly sure how we're going to deal with that.)
	mezzUniPilots_modApiExt:addTileHighlightedHook(function(mission, point)
		runUpdateCorrections()
	end)
	
	mezzUniPilots_modApiExt:addGameLoadedHook(function(mission)
		if GetCurrentMission() then
			MezzProcessReload = true
		end
	end)
	
end

return {
	id = "Mezz_Pilots",
	name = "Lost Pilots",
	version = "5.6",
	-- YOU WERE SUPPOSED TO DESTROY THE VERSION NUMBERS!  NOT JOIN THEM!
	requirements = {},
	init = init,
	load = load,
}