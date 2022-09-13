local tbItem = Item:GetClass("shengwanglingpai_baihutang")
local	tbShengWang = 
{
	[1] = 50,
	[2] = 100,
	[3] = 150,
}

--tbItem.USED_LIMIT = 10;

function tbItem:OnUse()
	local nLevel = it.nLevel;
	local nUesd = me.GetTask(BaiHuTang.TSKGID, BaiHuTang.TASK_USED_NUM);
	local nWeek = me.GetTask(BaiHuTang.TSKGID, BaiHuTang.TASK_WEEK_ID)
	local nNowWeek = tonumber(GetLocalDate("%W"));
	local szSeries = Env.SERIES_NAME[me.nSeries];
	if nWeek ~= nNowWeek then
		me.SetTask(BaiHuTang.TSKGID, BaiHuTang.TASK_WEEK_ID, nNowWeek);
		nUesd = 0;
	end
--	if (nUesd >= self.USED_LIMIT) then
--		me.Msg("你本周已经使用了"..self.USED_LIMIT.."个白虎堂声望令牌，不能再使用！");
--		return 0;
--	end
	-- zhengyuhua:庆公测活动临时内容
	local nMuti = 100;
	local nBufLevel = me.GetSkillState(881)
	local nBufLevel_vn = me.GetSkillState(2211)	--越南声望令牌
	if nBufLevel > 0 or nBufLevel_vn > 0 then
		nMuti = nMuti * 1.5
	end

	local nFlag = Player:AddRepute(me, BaiHuTang.BAIHUTANG_REPUTE_CAMP, BaiHuTang.BAIHUTANG_REPUTE_CALSS, math.floor(tbShengWang[nLevel] * nMuti / 100));
	
	if (0 == nFlag) then
		return;
	elseif (1 == nFlag) then
		me.Msg("您已经达到白虎堂声望（" .. szSeries .. "）最高等级，将无法使用白虎堂令牌");
		return;
	end
	
	me.Msg("你本周已经使用了"..(nUesd + 1).."个白虎堂声望令牌!");
	me.SetTask(BaiHuTang.TSKGID, BaiHuTang.TASK_USED_NUM, nUesd + 1);
	return 1;
end

