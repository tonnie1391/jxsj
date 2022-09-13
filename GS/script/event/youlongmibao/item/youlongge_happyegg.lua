-- 文件名　：youlongge_happyegg.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-11-11 09:08:59
-- 描  述  ：这个是游龙开心蛋，还有个盛夏开心蛋

local tbItem = Item:GetClass("youlongge_happyegg");
tbItem.TSK_GROUP 		= 2106;
tbItem.TSK_COUNT 		= 4;
tbItem.TSK_DATE	 		= 5;

tbItem.TSK_GROUP_LIMIT 	= 2206;
tbItem.TSK_LIMIT	 	= 1;

tbItem.DEF_BINDMONEY	= 120000;
tbItem.DEF_BINDCOIN		= 2000;
tbItem.DEF_MAXCOUNT 	= 7;

function tbItem:OnUse()
	self:OnLoginDay(1);
	local nCount = me.GetTask(self.TSK_GROUP, self.TSK_COUNT);
	if nCount > self.DEF_MAXCOUNT or nCount < 0 then
		me.SetTask(self.TSK_GROUP, self.TSK_COUNT, 0);
		nCount = 0;
	end
	local szMsg = string.format("<color=yellow>Trứng du long càng ăn càng ngon<color>\n\n Mỗi ngày tham gia hoạt động du long và mở trứng có thể nhận được phần thưởng hấp dẫn.");
	local tbOpt = {
		{string.format("<color=yellow>2000 %s khóa<color>", IVER_g_szCoinName), self.GetItem, self, it.dwId, 1},
		{"<color=yellow>12 vạn bạc khóa<color>", self.GetItem, self, it.dwId, 2},
		{"Không mở nữa"},
		};
	Dialog:Say(szMsg, tbOpt);
	return 0;
end

function tbItem:GetItem(nItemId, nType)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	
	local nTuCach = me.GetTask(self.TSK_GROUP_LIMIT, self.TSK_LIMIT);
	local nCurDate = GetTime();
	local bIsCanGetCard = 0;
	
	local nCount = me.GetTask(self.TSK_GROUP, self.TSK_COUNT);
	if nTuCach < nCurDate then
		if nCount <= 0 then
			Dialog:Say("Hôm nay bạn đã hết lượt sử dụng.");
			return 0;
		end
	end
	
	-- if nCurDate >= 20090921 and nCurDate < 20091011 then
		-- bIsCanGetCard = 1;
	-- end
	-- if bIsCanGetCard == 1 and me.CountFreeBagCell() < 1 then
		-- Dialog:Say("Hành trang đã đầy, vui lòng thử lại");
		-- return 0;
	-- end
	
	if nType == 2 then
		if me.GetBindMoney() + self.DEF_BINDMONEY > me.GetMaxCarryMoney() then
			Dialog:Say("Số tiền được mang đã quá giới hạn, vui lòng thử lại");
			return 0;
		end
	end
	
	if me.DelItem(pItem) == 1 then
		if nType == 1 then
			me.AddBindCoin(self.DEF_BINDCOIN, Player.emKBINDCOIN_ADD_HAPPYEGG);
			me.SendMsgToFriend(string.format("Hảo hữu [%s] mở Trứng Du Long nhận được %s %s khóa", me.szName, self.DEF_BINDCOIN, IVER_g_szCoinName));
			Player:SendMsgToKinOrTong(me, string.format(" mở Trứng Du Long nhận được %s %s khóa", self.DEF_BINDCOIN, IVER_g_szCoinName), 1);
			Dbg:WriteLog("happyegg", me.szAccount, string.format("%s sử dụng Trứng Du Long nhận %s %s khóa", me.szName, self.DEF_BINDCOIN, IVER_g_szCoinName));
			me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("%s sử dụng Trứng Du Long nhận %s %s khóa", me.szName, self.DEF_BINDCOIN, IVER_g_szCoinName));
			KStatLog.ModifyAdd("bindcoin", "Trứng Du Long", "toàn bộ", self.DEF_BINDCOIN);
		end
		if nType == 2 then
			me.AddBindMoney(self.DEF_BINDMONEY, Player.emKBINDMONEY_ADD_HAPPYEGG);
			me.SendMsgToFriend(string.format("Hảo hữu [%s] mở Trứng Du Long nhận được %s bạc khóa", me.szName, self.DEF_BINDMONEY));
			Player:SendMsgToKinOrTong(me, string.format(" mở Trứng Du Long nhận được %s bạc khóa", self.DEF_BINDMONEY), 1);
			Dbg:WriteLog("happyegg", me.szAccount, string.format("%s sử dụng Trứng Du Long nhận %s bạc khóa", me.szName, self.DEF_BINDMONEY));			
			me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("%s sử dụng Trứng Du Long nhận %s bạc khóa", me.szName, self.DEF_BINDMONEY));		
			KStatLog.ModifyAdd("bindjxb", "Trứng Du Long", "toàn bộ", self.DEF_BINDMONEY);
		end
		me.AddKinReputeEntry(2);
		if nTuCach < nCurDate then
			me.SetTask(self.TSK_GROUP, self.TSK_COUNT, nCount - 1);
		else
			me.Msg("Tư cách sử dụng Trứng Du Long không giới hạn.")
		end
		-- if bIsCanGetCard == 1 then
			-- local pItem = me.AddItemEx(18,1,402,1, {bForceBind=1}, Player.emKITEMLOG_TYPE_JOINEVENT);
			-- if pItem then
				-- me.SetItemTimeout(pItem, 4320, 0);
				-- pItem.Sync();
			-- end
		-- end
		
		StudioScore:OnActivityFinish("happyegg", me);
		
		SpecialEvent.ActiveGift:AddCounts(me, 6);		--使用开心蛋活跃度
		
		return 1;
		
	end
	Dbg:WriteLog("happyegg",  string.format("%s không trừ được vật phẩm", me.szName));
end

function tbItem:OnLoginDay(nUse)
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	local nCurDay  =Lib:GetLocalDay();
	if me.GetTask(self.TSK_GROUP, self.TSK_DATE) == 0 then
		me.SetTask(self.TSK_GROUP, self.TSK_DATE, nCurDay);
		me.SetTask(self.TSK_GROUP, self.TSK_COUNT, 1);
		return 0;
	end
	
	local nDayCount = nCurDay - me.GetTask(self.TSK_GROUP, self.TSK_DATE);
	if nDayCount <= 0 then
		return 0;
	end
	
	local nDayCount = nDayCount + me.GetTask(self.TSK_GROUP, self.TSK_COUNT);
	if nDayCount > self.DEF_MAXCOUNT then
		nDayCount = self.DEF_MAXCOUNT;
	end
	
	me.SetTask(self.TSK_GROUP, self.TSK_COUNT, nDayCount);
	me.SetTask(self.TSK_GROUP, self.TSK_DATE, nCurDay);
	return 1;
end

PlayerEvent:RegisterOnLoginEvent(tbItem.OnLoginDay, tbItem);
