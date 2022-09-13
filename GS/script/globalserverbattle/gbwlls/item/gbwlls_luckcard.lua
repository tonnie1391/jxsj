-- 跨服联赛幸运卡

local tbItem = Item:GetClass("gbwlls_luckycard");

function tbItem:OnUse()
	Dialog:Say("跨服联赛幸运卡的开启时间在<color=yellow>今天22点后到明天15点以前<color>，不要错过了开启时间哟！你确定开吗？", {
			{"Xác nhận", self.OnSureOpenCard, self, it.dwId},
			{"考虑考虑"},
		});
	return 0;
end

function tbItem:OnSureOpenCard(nItemId)
	local pItem = KItem.GetObjById(nItemId);	
	if not pItem then
		return 1;
	end
	
	local nGetTime = pItem.GetGenInfo(1);
	if (GbWlls:ServerIsCanJoinGbWlls() == 0) then
		Dialog:Say("跨服联赛还未开启无法开跨服联赛幸运卡！");
		return 0;
	end
	
	local nGblSession = GbWlls:GetGblWllsOpenState();
	if (nGblSession <= 0) then
		Dialog:Say("跨服联赛还未开启无法开跨服联赛幸运卡！");
		return 0;
	end
	
	local nTime			= GetTime();
	local tbTime		= os.date("*t", nTime);
	local nNowDay		= Lib:GetLocalDay(nTime);
	local nCardGetDay	= Lib:GetLocalDay(nGetTime);

	if (GbWlls:CheckOpenMonth(nTime) == 0) then
		Dialog:Say("不是在跨服联赛时间段，无法开跨服联赛幸运卡！");
		return 0;
	end

	local nState = GbWlls:GetGblWllsState();

	if (nNowDay == nCardGetDay) then
		if (tbTime.hour < GbWlls.DEF_NOT_OPEN_LUCKCARD_TIME_END) then
			Dialog:Say(string.format("这张卡片是今天领的，只有在今天%s点后才能打开！", GbWlls.DEF_NOT_OPEN_LUCKCARD_TIME_END));
			return 0;
		end
	end
	
	if (tbTime.hour >= GbWlls.DEF_NOT_OPEN_LUCKCARD_TIME_START and tbTime.hour < GbWlls.DEF_NOT_OPEN_LUCKCARD_TIME_END) then
		Dialog:Say(string.format("在每天的%s点到%s点之间是无法开启幸运卡的！", GbWlls.DEF_NOT_OPEN_LUCKCARD_TIME_START, GbWlls.DEF_NOT_OPEN_LUCKCARD_TIME_END));
		return 0;
	end

	if me.CountFreeBagCell() < 2 then
		Dialog:Say(string.format("您的背包空间不够,请整理%s格背包空间。", 2));
		return 0;
	end
	GbWlls:GiveLuckCardAward(me, nGetTime);	

	if (me.DelItem(pItem, Player.emKLOSEITEM_USE) ~= 1) then
		return 0;
	end
	return 1;
end
