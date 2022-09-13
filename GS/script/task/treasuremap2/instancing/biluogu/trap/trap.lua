------------------------------------------------------
-- 文件名　：trap.lua
-- 创建者　：dengyong
-- 创建时间：2012-08-03 12:12:02
-- 描  述  ：碧落谷副本trap
------------------------------------------------------

local tbMap			= Map:GetClass(TreasureMap2.TEMPLATE_LIST[7].nTemplateMapId);

local function GetMission(pPlayer)
	local nMapId, nMapX, nMapY	= pPlayer.GetWorldPos();
	local tbInstancing = TreasureMap2:GetInstancing(nMapId);
	assert(tbInstancing);
	
	return tbInstancing;	
end

local tbTrap1 		= tbMap:GetTrapClass("trap1");
function tbTrap1:OnPlayer()
	local tbInstancing = GetMission(me);
	if tbInstancing.nObstacleStepClear < 1 then
		me.NewWorld(me.nMapId, unpack(tbInstancing.tbTrapBackPos[1]));
		Dialog:SendInfoBoardMsg(me, "<color=red>这些紫色石花上的毒刺使你赶紧退了回来！<color>");
	end
end

local tbTrap2 		= tbMap:GetTrapClass("trap2");
function tbTrap2:OnPlayer()
	local tbInstancing = GetMission(me);
	if tbInstancing.nObstacleStepClear < 2 then
		me.NewWorld(me.nMapId, unpack(tbInstancing.tbTrapBackPos[2]));
		Dialog:SendInfoBoardMsg(me, "<color=red>这些紫色石花上的毒刺使你赶紧退了回来！<color>");
	end
end

local tbTrap3 		= tbMap:GetTrapClass("trap3");
function tbTrap3:OnPlayer()
	local tbInstancing = GetMission(me);
	if tbInstancing.nObstacleStepClear < 3 then
		me.NewWorld(me.nMapId, unpack(tbInstancing.tbTrapBackPos[3]));
		Dialog:SendInfoBoardMsg(me, "<color=red>这些紫色石花上的毒刺使你赶紧退了回来！<color>");
	end
end

local tbTrap4		= tbMap:GetTrapClass("trap4");
function tbTrap4:OnNpc()
	local tbInstancing = GetMission(him);
	if tbInstancing.WATER_FIGHT_FINISHED ~= 1 then
		return;
	end
	if him.IsCarrier() == 1 then
		him.TakeOffAllPassenger();
	end
end