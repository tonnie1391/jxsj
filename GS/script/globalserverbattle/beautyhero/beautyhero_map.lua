-- 文件名  : beautyhero_map.lua
-- 创建者  : zounan
-- 创建时间: 2010-09-17 11:11:21
-- 描述    : 

Require("\\script\\globalserverbattle\\beautyhero\\beautyhero_def.lua")

local tbMap = {};

-- 离开地图
function tbMap:OnLeave()
	Faction:SetForbidSwitchFaction(me, 0); -- 禁止换门派	
	local tbMissionInfo = BeautyHero:GetMissionInfo(me.nMapId);
	local nPlayerId = me.nId;
	if tbMissionInfo then
		if tbMissionInfo:FindAttendPlayer(nPlayerId) == 1 then		-- 暂时恢复原来状态
			tbMissionInfo:KickPlayerFromArena(nPlayerId);
			tbMissionInfo:ResumeNormalState(nPlayerId);
			tbMissionInfo:DelAttendPlayer(nPlayerId);
		end
		tbMissionInfo:DelMapPlayerTable(nPlayerId);
	end
	me.nForbidChangePK = 0;
	me.ForbidEnmity(0);		--仇杀
	me.ForbidExercise(0); 	--切磋 
	me.DisabledStall(0);	--摆摊
end

-- 进入地图
function tbMap:OnEnter()
	me.SetLogoutRV(1);	
	Faction:SetForbidSwitchFaction(me, 1); -- 禁止换门派	
	local tbMissionInfo = BeautyHero:GetMissionInfo(me.nMapId);
	if tbMissionInfo then
		tbMissionInfo:AddMapPlayerTable(me.nId);
		if tbMissionInfo.nState == BeautyHero.SIGN_UP then
			Dialog:SendBlackBoardMsg(me, "你进入了巾帼英雄比赛场，想要参加比赛的话记得报名哦。");
		end
	end
--	self:TrapIn(me);
	me.SetFightState(0);
	me.nPkModel = Player.emKPK_STATE_PRACTISE;
	me.nForbidChangePK = 1;
	me.ForbidEnmity(1);		-- 禁止仇杀
	me.ForbidExercise(1); 	-- 禁止切磋 
	me.DisabledStall(1);	--禁止摆摊
end

for  _, nMapId in pairs(BeautyHero.MAP_SERIES) do
	local tbMapTemplet = Map:GetClass(nMapId);
	for szFnc in pairs(tbMap) do
		tbMapTemplet[szFnc] = tbMap[szFnc];
	end
	tbMapTemplet.nMapId = nMapId;
end

for  _, nMapId in pairs(BeautyHero.MAP_MELEE) do
	local tbMapTemplet = Map:GetClass(nMapId);
	for szFnc in pairs(tbMap) do
		tbMapTemplet[szFnc] = tbMap[szFnc];
	end
	tbMapTemplet.nMapId = nMapId;
end

