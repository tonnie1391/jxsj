-------------------------------------------------------------------
--File: 	mengpaijingjilingpai.lua
--Author: 	zhengyuhua
--Date: 	2008-3-10 20:37
--Describe:	门派竞技令牌道具脚本
-------------------------------------------------------------------

local tbLingPai = Item:GetClass("mengpaijingjilingpai");
tbLingPai.ADD_SHENGWANG = {30, 60, 100}	-- 令牌等级对应增加的门派声望
tbLingPai.USED_LIMIT	= 5;

function tbLingPai:OnUse()
	local nLevel = it.nLevel;
	if (nLevel < 1 or nLevel > 3) then
		return 0;
	end
	if (me.nFaction == 0) then
		me.Msg("你还没入门派!");
		return 0;
	end
	local szFactionName = Player:GetFactionRouteName(me.nFaction);
	local nUesd = me.GetTask(FactionBattle.TASK_GROUP_ID, FactionBattle.TASK_USED_LINGPAI);
	local nTime = me.GetTask(FactionBattle.TASK_GROUP_ID, FactionBattle.TASK_LINGPAI_DATE)
	local nNowDate = tonumber(GetLocalDate("%y%m%d"));
	if nTime ~= nNowDate then
		me.SetTask(FactionBattle.TASK_GROUP_ID, FactionBattle.TASK_LINGPAI_DATE, nNowDate);
		nUesd = 0;
	end
--	if (nUesd >= self.USED_LIMIT) then
--		me.Msg("你今天已经使用了"..self.USED_LIMIT.."个门派竞技令牌，不能再使用！");
--		return 0;
--	end
-- zhengyuhua:庆公测活动临时内容
	local nMuti = 100;
	local nBufLevel = me.GetSkillState(881)
	local nBufLevel_vn = me.GetSkillState(2211)	--越南声望令牌
	if nBufLevel > 0 or nBufLevel_vn > 0 then
		nMuti = nMuti * 1.5
	end
	
	local nFlag = Player:AddRepute(me, Player.CAMP_FACTION, me.nFaction, math.floor(self.ADD_SHENGWANG[nLevel] * nMuti / 100));
	
	if (0 == nFlag) then
		return;
	elseif (1 == nFlag) then
		me.Msg("您已经达到" .. szFactionName .. "门派声望最高等级，将无法使用门派竞技令牌");
		return;
	end

	me.Msg("你今天使用了第"..(nUesd + 1).."个门派竞技令牌!");
	me.SetTask(FactionBattle.TASK_GROUP_ID, FactionBattle.TASK_USED_LINGPAI, nUesd + 1);
	return 1;
end
