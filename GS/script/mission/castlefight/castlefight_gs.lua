-- castlefight_gs.lua
-- zhouchenfei
-- 奖励函数
-- 2010-11-22 17:05:54

if (MODULE_GC_SERVER) then
	return 0;
end

--参加一次比赛
function CastleFight:ConsumeTask(pPlayer)
	--总场次＋1
	pPlayer.SetTask(self.TSK_GROUP, self.TSK_ATTEND_TOTAL, pPlayer.GetTask(self.TSK_GROUP, self.TSK_ATTEND_TOTAL) + 1);
	
	--次数－1
	local nCount = pPlayer.GetTask(self.TSK_GROUP, self.TSK_ATTEND_COUNT);
	local nExCount = pPlayer.GetTask(self.TSK_GROUP, self.TSK_ATTEND_EXCOUNT)
	if nCount > 0 then
		pPlayer.SetTask(self.TSK_GROUP, self.TSK_ATTEND_COUNT, nCount - 1);
		return 1;
	end
	if nExCount > 0 then
		pPlayer.SetTask(self.TSK_GROUP, self.TSK_ATTEND_EXCOUNT, nExCount - 1);
		return 1;
	end	
	return 0;
end

function CastleFight:TaskDayEvent()
	local tbConsole = self:GetConsole();
	
	if (not tbConsole) then
		return 0;
	end
	
	if tbConsole:CheckState() ~= 1 then
		return 0;
	end       
	
	local tbCfg = self:GetConsoleCfg();
	
	local nTime		= GetTime();
	local nNowDay 	= Lib:GetLocalDay(nTime);
	local nLastTime  = me.GetTask(self.TSK_GROUP, self.TSK_UPDATE_ITEM_TIME);
	local nKeepDay	= Lib:GetLocalDay(nLastTime);
		
	if me.nLevel < tbCfg.nMinLevel or me.nFaction <= 0 then
		return 0;
	end
	
	local nTotal = me.GetTask(CastleFight.TSK_GROUP, CastleFight.TSK_ATTEND_TOTAL);
	local nCountSum, nCount, nCountEx = CastleFight:IsSignUpByTask(me);

	local nAleadyNum = nTotal + nCountSum;
	local nMaxNum = math.ceil((CastleFight.DEF_MAX_TOTAL_NUM - nAleadyNum) / CastleFight.DEF_CHANGENUME);

	if nKeepDay <= 0 then
		nKeepDay = Lib:GetLocalDay(Lib:GetDate2Time(tbCfg.nEventStartTime)) - 1;
	end
	if (nNowDay - nKeepDay) > 0 then
		local nCount = me.GetTask(self.TSK_GROUP, self.TSK_USE_ITEM_TIMES) + (nNowDay - nKeepDay);
		if nCount >= nMaxNum then
			nCount = nMaxNum;
		end
		
		me.SetTask(self.TSK_GROUP, self.TSK_USE_ITEM_TIMES, nCount);
		me.SetTask(self.TSK_GROUP, self.TSK_UPDATE_ITEM_TIME, nTime);
		self:WriteLog("增加次数："..nCount, me.nId);
	end
end

function CastleFight:CheckEnterCount(pPlayer, tbJoinItem)
	if (not tbJoinItem or not pPlayer) then
		return -1;
	end
	local nCount = 0;
	for _, tbItemInfo in pairs(tbJoinItem) do
		if (tbItemInfo.tbItem and #tbItemInfo.tbItem > 0) then
			nCount = nCount + pPlayer.GetItemCountInBags(unpack(tbItemInfo.tbItem));
		end
	end
	
	return nCount;
end

function CastleFight:GetItemName(tbItem)
	return KItem.GetNameById(unpack(tbItem));
end

function CastleFight:ProcessItemCheckFun(pPlayer, tbJoinItem)
	if (not pPlayer or not tbJoinItem) then
		return 0, "Không tìm thấy vật phẩm cần thiết";
	end
	
	local tbItemList = {};
	local tbItemListInfo = {};
	for _, tbItemInfo in pairs(tbJoinItem) do
		if (tbItemInfo.tbItem) then
			local tbInfo = pPlayer.FindItemInBags(unpack(tbItemInfo.tbItem));
			if (tbInfo and #tbInfo > 0) then
				tbItemList = tbInfo;
				tbItemListInfo = tbItemInfo;
				break;
			end
		end
	end
	if (not tbItemList) then
		return 0, "Không tìm thấy vật phẩm cần thiết";
	end

	local pItem = nil;
	for _, tbItemInfo in pairs(tbItemList) do
		if (tbItemInfo.pItem) then
			pItem = tbItemInfo.pItem;
			break;
		end
	end
	if (not pItem) then
		return 0, "Không tìm thấy vật phẩm cần thiết";
	end
	
	local szClassName = pItem.szClass;
	if (szClassName and szClassName ~= "") then
		local tbItem = Item:GetClass(szClassName);
		if (tbItem and tbItem.ItemCheckFun) then
			return tbItem:ItemCheckFun(pItem);
		end
	end

	return 1;
end

function CastleFight:UpdateLadder()
	GCExcute({"CastleFight:UpdateLadder"});
end

--玩家登陆执行后次数增加
PlayerEvent:RegisterOnLoginEvent(CastleFight.TaskDayEvent, CastleFight);


