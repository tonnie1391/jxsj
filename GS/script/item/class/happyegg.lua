-- 文件名　：happyegg.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-07-20 10:02:03
-- 描  述  ：这个是盛夏开心蛋（还有个游龙开心蛋）

local tbItem = Item:GetClass("happyegg");
tbItem.TSK_GROUP = 2027;
tbItem.TSK_COUNT = 71;
tbItem.TSK_DATE	 = 72;
tbItem.DEF_DATE_START 	= 20090721;
tbItem.DEF_DATE_END 	= 20091021;
tbItem.DEF_BINDMONEY	= 50000;
tbItem.DEF_BINDCOIN		= 2000;
tbItem.DEF_MAXCOUNT 	= 7;

function tbItem:OnUse()
	self:OnLoginDay(1);
	local nCount= me.GetTask(self.TSK_GROUP, self.TSK_COUNT);
	local szMsg = string.format("<color=yellow>盛夏天天开心蛋，天天都开心。<color>\n\n你今天还可以开启<color=yellow>%s个<color>开心蛋，打开后可以选择领取以下的其中一项，请选择你要领取的选项。", nCount);
	local tbOpt = {
		{"<color=yellow>2000绑定金币<color>", self.GetItem, self, it.dwId, 1},
		{"<color=yellow>50000绑定银两<color>", self.GetItem, self, it.dwId, 2},
		{"Để ta suy nghĩ lại"},
		};
	Dialog:Say(szMsg, tbOpt);
	return 0;
end

function tbItem:GetItem(nItemId, nType)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	local nCount= me.GetTask(self.TSK_GROUP, self.TSK_COUNT);
	if nCount <= 0 then
		Dialog:Say("今天你已经不能再开启开心蛋了。");
		return 0;
	end
	local bIsCanGetCard = 0;
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	if nCurDate >= 20090921 and nCurDate < 20091011 then
		bIsCanGetCard = 1;
	end
	if bIsCanGetCard == 1 and me.CountFreeBagCell() < 1 then
		Dialog:Say("你的背包空间不足，请整理1格背包空间。");
		return 0;
	end
	
	if nType == 2 then
		if me.GetBindMoney() + self.DEF_BINDMONEY > me.GetMaxCarryMoney() then
			Dialog:Say("你的绑定银两携带达上限了，请先整理背包的绑定银两。");
			return 0;
		end
	end
	
	if me.DelItem(pItem) == 1 then
		if nType == 1 then
			me.AddBindCoin(self.DEF_BINDCOIN, Player.emKBINDCOIN_ADD_HAPPYEGG);
			me.SendMsgToFriend(string.format("你的好友[%s]开启盛夏天天开心蛋获得了%s绑定金币", me.szName, self.DEF_BINDCOIN));
			Player:SendMsgToKinOrTong(me, string.format("开启盛夏天天开心蛋获得了%s绑定金币", self.DEF_BINDCOIN), 1);
			--Dbg:WriteLog("盛夏开心蛋", me.szAccount, me.szName, "盛夏开心蛋", "兑换绑定金币", self.DEF_BINDCOIN));
			Dbg:WriteLog("hyppyegg", me.szAccount, string.format("%s开启盛夏开心蛋获得了%s绑定金币", me.szName, self.DEF_BINDCOIN));
			me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("%s开启开心蛋获得了%s绑定金币", me.szName, self.DEF_BINDCOIN));
			KStatLog.ModifyAdd("bindcoin", "[产出]开心蛋开出", "总量", self.DEF_BINDCOIN);
		end
		if nType == 2 then
			me.AddBindMoney(self.DEF_BINDMONEY, Player.emKBINDMONEY_ADD_HAPPYEGG);
			me.SendMsgToFriend(string.format("你的好友[%s]开启盛夏天天开心蛋获得了%s绑定银两", me.szName, self.DEF_BINDMONEY));
			Player:SendMsgToKinOrTong(me, string.format("开启盛夏天天开心蛋获得了%s绑定银两", self.DEF_BINDMONEY), 1);
			--Dbg:WriteLog("盛夏开心蛋",  me.szAccount, me.szName, "盛夏开心蛋", "兑换绑定银两", self.DEF_BINDMONEY));
			Dbg:WriteLog("hyppyegg", me.szAccount, string.format("%s开启盛夏开心蛋获得了%s绑定银两", me.szName, self.DEF_BINDMONEY));			
			me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("%s开启开心蛋获得了%s绑定银两", me.szName, self.DEF_BINDMONEY));		
			KStatLog.ModifyAdd("bindjxb", "[产出]开心蛋开出", "总量", self.DEF_BINDMONEY);
		end
		me.AddKinReputeEntry(2);
		me.SetTask(self.TSK_GROUP, self.TSK_COUNT, nCount - 1);
		if bIsCanGetCard == 1 then
			local pItem = me.AddItemEx(18,1,402,1, {bForceBind=1}, Player.emKITEMLOG_TYPE_JOINEVENT);
			if pItem then
				me.SetItemTimeout(pItem, 4320, 0);
				pItem.Sync();
			end
		end
		return 1;
	end
	Dbg:WriteLog("hyppyegg",  string.format("%s开启开心蛋扣除物品失败", me.szName));
end

function tbItem:OnLoginDay(nUse)
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	local nCurDay  =Lib:GetLocalDay();
	if nCurDate < self.DEF_DATE_START or nCurDate >= self.DEF_DATE_END then
		return 0;
	end
	if TimeFrame:GetState("OpenLevel79") ~= 1 then
		return 0;
	end
	if me.GetTask(self.TSK_GROUP, self.TSK_DATE) == 0 then
		me.SetTask(self.TSK_GROUP, self.TSK_DATE, nCurDay);
		me.SetTask(self.TSK_GROUP, self.TSK_COUNT, 1);
		if not nUse then
			me.Msg("<color=yellow>你今天又可以砸开盛夏天天开心蛋了。<color>");
			Dialog:SendBlackBoardMsg(me, "你今天又可以砸开盛夏天天开心蛋了。");
		end
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
	
	if nDayCount > 0 and not nUse then
		me.Msg("<color=yellow>你今天又可以砸开盛夏天天开心蛋了。<color>");
		Dialog:SendBlackBoardMsg(me, "你今天又可以砸开盛夏天天开心蛋了。")
	end
	
	me.SetTask(self.TSK_GROUP, self.TSK_COUNT, nDayCount);
	me.SetTask(self.TSK_GROUP, self.TSK_DATE, nCurDay);
	return 1;
end

PlayerEvent:RegisterOnLoginEvent(tbItem.OnLoginDay, tbItem);
