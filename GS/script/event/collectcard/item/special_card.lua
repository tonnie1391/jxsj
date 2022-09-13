Require("\\script\\event\\collectcard\\define.lua")

local tbItem = Item:GetClass("chanjuan_card"); -- 千里共婵娟
local CollectCard = SpecialEvent.CollectCard;

function tbItem:OnUse()
	self:OpenPage(it.dwId, 0);
	return 0;
end

function tbItem:OpenPage(nItemId, nNowPage)
	local pItem = KItem.GetObjById(nItemId);
	if (not pItem) then
		return;
	end	
	if me.GetTask(CollectCard.TASK_GROUP_ID, CollectCard.TASK_COLLECT_FINISH) == 1 then
		me.Msg("您已集齐了所有卡片，获得了一张幸运卡。");
		local nP = KGblTask.SCGetDbTaskInt(DBTASD_EVENT_COLLECTCARD_RANDOM);
		if me.DelItem(pItem, Player.emKLOSEITEM_TYPE_EVENTUSED) ~= 1 then
			CollectCard:WriteLog("删除千里共婵娟失败", me.nId);
			return;
		end
		local pItemAdd = me.AddItem(18, 1, nP, 1);
		if pItemAdd then
			pItemAdd.Bind(1);
			local szDate = GetLocalDate("%Y/%m/%d/24/00/00");
			me.SetItemTimeout(pItemAdd, szDate);
		end
		return 1;
	end
	local szMsg = "请选择您需要换取的卡片";
	local tbOpt = {};
	local nPage = 5; -- 每页显示5张卡片
	local nCount = nNowPage * nPage;
	local nSum = 0;
	for nP, tbTask in pairs(CollectCard.TASK_CARD_ID) do
		if me.GetTask(CollectCard.TASK_GROUP_ID, tbTask[1]) == 0 then
			--print(nCount, nSum, tbTask[1], tbTask[2])
			nSum = nSum + 1;
			if nSum > nCount then
				nCount = nCount + 1;
				if nCount > (nPage * (nNowPage + 1)) then
					table.insert(tbOpt, {"Trang sau", self.OpenPage, self, nItemId, nNowPage + 1});
					break;
				end
				local tbTemp = {tbTask[2], self.OnUseSure, self, me.nId, nItemId, nP};
				table.insert(tbOpt, tbTemp);
			end
		end
	end
	
	if nSum > 0 then
		table.insert(tbOpt, {"我先想想"});
		Dialog:Say(szMsg, tbOpt);
	else
		local nLuckyId = KGblTask.SCGetDbTaskInt(DBTASD_EVENT_COLLECTCARD_RANDOM);
		me.AddItem(18,1,nLuckyId,1);
		pItem.Delete(me);
	end
end

function tbItem:OnUseSure(nPlayerId, nItemId, nP)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if (not pPlayer) then
		return;
	end		
	local pItem = KItem.GetObjById(nItemId);
	if (not pItem) then
		return;
	end
	if pPlayer.DelItem(pItem, Player.emKLOSEITEM_TYPE_EVENTUSED) ~= 1 then
		CollectCard:WriteLog("删除千里共婵娟失败", pPlayer.nId);		
		return;
	end
	local pItemAdd = me.AddItem(18, 1, nP, 1);
	if pItemAdd then
		pItemAdd.Bind(1);
		local szDate = GetLocalDate("%Y/%m/%d/24/00/00");
		pPlayer.SetItemTimeout(pItemAdd, szDate);
		CollectCard:WriteLog(string.format("千里共婵娟，换取了一张%s", pItemAdd.szName), pPlayer.nId);		
	end
end

function tbItem:InitGenInfo()
	local nTime = tonumber(os.date("%Y%m%d", GetTime()));
	nTime = Lib:GetDate2Time(nTime);
	nTime = nTime + 86400
	it.SetTimeOut(0, nTime);
	return {};
end
