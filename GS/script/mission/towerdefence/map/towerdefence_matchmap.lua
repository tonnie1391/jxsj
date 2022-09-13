--竞技赛(比赛场)
--孙多良
--2008.12.2

Require("\\script\\mission\\towerdefence\\towerdefence_def.lua");

local tbMap = Map:GetClass(TowerDefence.DEF_MAP_TEMPLATE_ID);

local tbTrapLeft 	= tbMap:GetTrapClass("trap_left"); 
local tbTrapRight 	= tbMap:GetTrapClass("trap_right"); 

-- 玩家接触Trap点,改变战斗状态
function tbTrapLeft:OnPlayer()
	local tbPlayerTempTable = me.GetPlayerTempTable();	
	local tbMission = tbPlayerTempTable.tbMission;	
	
	if not tbMission or tbMission:IsOpen() ~= 1 then		
		return 0;
	end	

	if me.nFightState == 1 then
		me.NewWorld(me.nMapId,1618,3244);
	end
	if me.nFightState == 0 then
		me.NewWorld(me.nMapId,1611,3238);
	end
	me.SetFightState(1 - me.nFightState);	
end

-- 玩家接触Trap点,改变战斗状态
function tbTrapRight:OnPlayer()
	local tbPlayerTempTable = me.GetPlayerTempTable();
	local tbMission = tbPlayerTempTable.tbMission;
	
	if not tbMission or tbMission:IsOpen() ~= 1 then		
		return 0;
	end
	
	if me.nFightState == 1 then
		me.NewWorld(me.nMapId,1618,3244);
	end
	if me.nFightState == 0 then
		me.NewWorld(me.nMapId,1623,3250);
	end
	me.SetFightState(1 - me.nFightState);	
end

local tbMap2 = Map:GetClass(TowerDefence.DEF_MAP_TEMPLATE_ID2);

local tbTrapLeft2 	= tbMap2:GetTrapClass("trap_left"); 
local tbTrapRight2 	= tbMap2:GetTrapClass("trap_right"); 

-- 玩家接触Trap点,改变战斗状态
function tbTrapLeft2:OnPlayer()
	local tbPlayerTempTable = me.GetPlayerTempTable();	
	local tbMission = tbPlayerTempTable.tbMission;	
	
	if not tbMission or tbMission:IsOpen() ~= 1 then		
		return 0;
	end	

	if me.nFightState == 1 then
		me.NewWorld(me.nMapId,1618,3244);
	end
	if me.nFightState == 0 then
		me.NewWorld(me.nMapId,1611,3238);
	end
	me.SetFightState(1 - me.nFightState);	
end

-- 玩家接触Trap点,改变战斗状态
function tbTrapRight2:OnPlayer()
	local tbPlayerTempTable = me.GetPlayerTempTable();
	local tbMission = tbPlayerTempTable.tbMission;
	
	if not tbMission or tbMission:IsOpen() ~= 1 then		
		return 0;
	end
	
	if me.nFightState == 1 then
		me.NewWorld(me.nMapId,1618,3244);
	end
	if me.nFightState == 0 then
		me.NewWorld(me.nMapId,1623,3250);
	end
	me.SetFightState(1 - me.nFightState);	
end
