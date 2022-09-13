local tbItem = Item:GetClass("shengwanglingpai_kin")
local	tbShengWang = 
{
	[1] = 50,
	[2] = 100,
	[3] = 150,
}

--tbItem.USED_LIMIT = 10;

function tbItem:OnUse()
	local nLevel = it.nLevel;
	local nUesd = me.GetTask(KinGame.TASK_GROUP_ID, KinGame.TASK_USED_NUM);
	local nWeek = me.GetTask(KinGame.TASK_GROUP_ID, KinGame.TASK_WEEK_ID)
	local nNowWeek = tonumber(GetLocalDate("%W"));
	local szSeries = Env.SERIES_NAME[me.nSeries];
	if nWeek ~= nNowWeek then
		me.SetTask(KinGame.TASK_GROUP_ID, KinGame.TASK_WEEK_ID, nNowWeek);
		nUesd = 0;
	end
--	if (nUesd >= self.USED_LIMIT) then
--		me.Msg("你本周已经使用了"..self.USED_LIMIT.."个家族声望令牌，不能再使用！");
--		return 0;
--	end
	-- zhengyuhua:庆公测活动临时内容
	local nMuti = 100;
	local nBufLevel = me.GetSkillState(881)
	local nBufLevel_vn = me.GetSkillState(2211)	--越南声望令牌
	if nBufLevel > 0 or nBufLevel_vn > 0 then
		nMuti = nMuti * 1.5
	end

	local nFlag = Player:AddRepute(me, KinGame.KIN_REPUTE_CAMP, KinGame.KIN_REPUTE_CALSS, math.floor(tbShengWang[nLevel] * nMuti / 100));
	
	if (0 == nFlag) then
		return;
	elseif (1 == nFlag) then
		me.Msg("您已经达到家族关卡（" .. szSeries .. "）声望最高等级，将无法使用家族关卡令牌");
		return;
	end

	me.Msg("你本周已经使用了"..(nUesd + 1).."个家族声望令牌!");
	me.SetTask(KinGame.TASK_GROUP_ID, KinGame.TASK_USED_NUM, nUesd + 1);
	return 1;
end

