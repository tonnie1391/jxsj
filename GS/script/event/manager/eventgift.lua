
Require("\\script\\lib\\gift.lua");
EventManager.Gift = Gift:New();

local tbGift = EventManager.Gift;

function tbGift:OnSwitch(pPickItem, pDropItem, nX, nY)
	if pDropItem then
		local szParam = string.format("%s,%s,%s,%s",pDropItem.nGenre,pDropItem.nDetail,pDropItem.nParticular,pDropItem.nLevel);
		if self._tbParam[szParam] == nil then
			me.Msg("我不需要这个物品，请重新放入我所需的物品。");
			return 0;
		end
	end	
	return	1;
end

function tbGift:OnUpdateParam(szContent,tbParam)
	self._szContent = szContent;
	self._tbParam = {};
	for ni, tbItem in ipairs(tbParam) do
		if tbItem.nGenre ~= 0 and tbItem.nDetail ~= 0 and tbItem.nParticular ~= 0 then
			local szParam = string.format("%s,%s,%s,%s",tbItem.nGenre, tbItem.nDetail, tbItem.nParticular, tbItem.nLevel);
			self._tbParam[szParam] = 1;
		end
	end
end

function tbGift:OnOK(tbAwardParam, tbGParam)
	local tbParam = {};
	local tbAward ={};
	local nEventPartId = 0;
	for nParam, szParam in ipairs(tbGParam) do
		local nSit = string.find(szParam, ":");
		local szFlag = string.sub(szParam, 1, nSit - 1);
		local szContent = string.sub(szParam, nSit + 1, string.len(szParam));
		if szFlag == "SetAwardIdUi" then
			local tbParam = EventManager.tbFun:SplitStr(szContent);
			tbAward[nParam] = tonumber(tbParam[1]);
			nEventPartId = tonumber(tbParam[2]) or 0;
		else
			tbParam[nParam] = szParam;
		end
	end
	
	self.tbItemList = {};
	local nMoney = 0;
	local nBindMoney = 0;
	local nCoin = 0;
	for ni, tbItem in ipairs(tbAwardParam.tbMareial) do
		if tbItem.nGenre ~= 0 and tbItem.nDetail ~= 0 and tbItem.nParticular ~= 0 then
			local szParam = string.format("%s,%s,%s,%s",tbItem.nGenre, tbItem.nDetail, tbItem.nParticular, tbItem.nLevel);
			self.tbItemList[szParam] = tbItem.nAmount;
		end
		if tbItem.nRandRate == 0 and tbItem.nJxMoney > 0 then
			nMoney = nMoney + tbItem.nJxMoney;
		end
		if tbItem.nRandRate == 0 and tbItem.nJxBindMoney > 0 then
			nBindMoney = nBindMoney + tbItem.nJxBindMoney;
		end
		if tbItem.nRandRate == 0 and tbItem.nJxCoin > 0 then
			nCoin = nCoin + tbItem.nJxCoin;
		end
	end
	
	if nMoney ~= 0 then
		if me.nCashMoney < nMoney then
			me.Msg("对不起，您身上的银两不足。");
			return 0;
		end
	end
	
	if nBindMoney ~= 0 then
		if me.GetBindMoney() < nBindMoney then			
			me.Msg("对不起，您身上的银两不足。");
			return 0;
		end
	end
	
	if nCoin ~= 0 then
		if me.nBindingCoinMoney < tbItem.nCoin then		
			me.Msg(string.format("对不起，您的绑定%s不足。", IVER_g_szCoinName));
			return 0;
		end
	end
	
	local pFind = self:First();
	while pFind do
		if self:DecreaseItemInList(pFind, self.tbItemList) == 0 then
			me.Msg("您放入的物品数量不对。");
			return 0;
		end
		pFind = self:Next();
	end
	
	if self:CheckItemInList(self.tbItemList) == 0 then
		me.Msg("您放入的物品数量不对。");
		return 0;
	end
	
	local nFlag, szMsg = EventManager.tbFun:CheckParam(tbParam);
	if nFlag == 1 then
		me.Msg(szMsg);
		return 0;
	end
	-- 删除物品
	local pFind = self:First();
	while pFind do
		Dbg:WriteLog("活动系统",  me.szName..",给予界面扣除物品:", pFind.szName);
		if me.DelItem(pFind, Player.emKLOSEITEM_TYPE_EVENTUSED) ~= 1 then
			return 0;
		end
		pFind = self:Next();
	end
	
	--扣除银两
	if nMoney > 0 then
		me.CostMoney(nMoney,Player.emKEARN_EVENT);
	end
	
	--扣除绑银
	if nBindMoney > 0 then
		me.CostBindMoney(nBindMoney, Player.emKEARN_EVENT);
	end
	
	local nFlag, szMsg = EventManager.tbFun:ExeParam(tbParam);
	if nFlag == 1 then
		me.Msg(szMsg)
		return 0;
	end
	for _, nParam in pairs(tbAward) do
		EventManager.tbFun:_GetRandomAward(EventManager.tbFun.AwardList[nParam].nMaxProb, EventManager.tbFun.AwardList[nParam].tbAward);
	end
	if nEventPartId > 0 then
		Lib:ShowTB(tbGParam)
		local nEventId 	= tonumber(EventManager.tbFun:GetParam(tbGParam, "__nEventId")[1]);
		local nPartId 	= tonumber(EventManager.tbFun:GetParam(tbGParam, "__nPartId")[1]);
		if nEventPartId == nPartId then
			print("【活动系统】Error!!!CheckTaskGotoEvent重复调用自己");
			return 0;
		end		
		return EventManager:GotoEventPartTable(nEventId, nEventPartId, 2);
	end
end

function tbGift:CheckItemInList(tbItemList)
	for szParam, nCount in pairs(tbItemList) do
		return 0;
	end 
	return 1;
end
-- 判断指定物品是否在靠标物品列表中，若在则把数量 -1
function tbGift:DecreaseItemInList(pFind, tbItemList)
	for szItem, nCount in pairs(tbItemList) do
		local szParam = string.format("%s,%s,%s,%s",pFind.nGenre, pFind.nDetail, pFind.nParticular, pFind.nLevel);
		if szItem == szParam then
			tbItemList[szItem] = tbItemList[szItem] - pFind.nCount;
			if tbItemList[szItem] == 0 then
				tbItemList[szItem] = nil 
			elseif tbItemList[szItem] < 0 then
				return 0;
			end
			return 1;
		end
	end
	return 0;
end

function tbGift:OnOpen(szContent, tbParam, tbGParam)
	me.CallClientScript({"EventManager.Gift:OnUpdateParam", szContent, tbParam.tbMareial});
	Dialog:Gift("EventManager.Gift", tbParam, tbGParam);
end
