------------------------------------------------------
-- 文件名　：longhunexchange.lua
-- 创建者　：dengyong
-- 创建时间：2012-03-02 18:47:21
-- 描  述  ：龙魂系列声望兑换脚本
------------------------------------------------------

Item.REPUTE_ADD_PRE_PIECE		= 2;	-- 每个碎片增加的声望值

Item.tbExchangeMatchTable =
{--particular	声望大类，小类
	[1665]		= {15, 2, "龙魂鉴·衣服",{18,1,1665} },
	[1666]		= {15, 3, "龙魂鉴·戒指", {18,1,1666} },
	[1667]		= {15, 4, "龙魂鉴·护身符",  {18,1,1667} },
}


function Item:ExChangeLongHun_CheckGiftItem(tbGiftSelf, pPickItem, pDropItem, nX, nY)
	local szContent = "";
	local tbItemList, nItemCount = self:ExChangeLongHun_GetItemList(tbGiftSelf);
	
	if pDropItem then
		if self:ExChangeLongHun_CheckItemValid(pDropItem) == 0 then
			return 0;
		end
	end
	
	-- pick总是成功
	
	if szContent and szContent ~= "" then
		tbGiftSelf:UpdateContent(szContent);	
	end
	return 1;
end

function Item:ExChangeLongHun_GetItemList(tbGiftSelf)
	local tbItemList = {};
	local pItem = tbGiftSelf:First();
	local nItemCount = 0;	-- 这里统计的是道具对象个数
	while pItem do
		-- 这里不用检查道具的合法性了
		local nMatchParticular = pItem.nParticular;
		tbItemList[nMatchParticular] = tbItemList[nMatchParticular] or {["nCount"] = 0};
		table.insert(tbItemList[nMatchParticular], pItem);
		tbItemList[nMatchParticular].nCount = tbItemList[nMatchParticular].nCount + pItem.nCount;
		
		nItemCount = nItemCount + 1;		
		pItem = tbGiftSelf:Next();
	end
	
	return tbItemList, nItemCount;
end

function Item:ExChangeLongHun_GetReputeAdd(tbItemList)
	local tbRetpute = {};
	for _, pItem in pairs(tbItemList) do
		local nMatchParticular = pItem.nParticular;
		local nValue = tbRetpute[nMatchParticular] or 0;
		nValue = nValue + pItem.nCount * self.REPUTE_ADD_PRE_PIECE;	
		tbRetpute[nMatchParticular] = nValue;
	end
	
	return tbRetpute;
end

-- 获取能放入的道具GDPL和个数
function Item:ExChangeLongHun_GetRightItemGDPL()
	local tbFullReputeInfo = KPlayer.GetReputeInfo();
	local tbGDPLs = {};
	
	local tbNeedRepute = self:ExChangeLongHun_GetNextLevReputeNeed();
	for nType, nNeedRep in pairs(tbNeedRepute) do
		local tbData = self.tbExchangeMatchTable[nType];
		if not tbData then
			return;
		end
		
		local nCamp, nClass = unpack(tbData, 1, 2);
		local nCurRetpLev = me.GetReputeLevel(nCamp, nClass);
		local tbGDP = {unpack(tbData[4])};
		tbGDP[4] = nCurRetpLev;
		local nCount = math.ceil(nNeedRep/self.REPUTE_ADD_PRE_PIECE);
		
		tbGDPLs[nType] = {tbGDP, nCount};
	end
	
	return tbGDPLs;
end

function Item:__FormatRightItemTips(tbGDPLs, bFormatCount, bEndTag, bLine)
	bFormatCount = bFormatCount or 0;
	bEndTag = bEndTag or 0;
	bLine = bLine or 0;
	
	local szMsg = "";
	
	local nCount = 0;
	for nType, tbInfo in pairs(tbGDPLs) do
		nCount = nCount + 1;
		if bLine == 0 and nCount ~= 1 then
			if nCount == Lib:CountTB(tbGDPLs) then
				szMsg = szMsg.."和";
			else
				szMsg = szMsg.."，";
			end
		end
		local szCount = "";
		if bFormatCount == 1 then
			szCount = tbInfo[2].."个";
		end
		szMsg = szMsg .. string.format("%s<color=greenyellow>%s%s<color>", bLine == 1 and "\n" or "", 
			KItem.GetNameById(unpack(tbInfo[1])), szCount);		
	end
	if bEndTag == 1 then
		szMsg = szMsg .. "\n\n<color=yellow>每个声望物品将提升2点对应等级声望值，多余部分将会退还给你。<color>"
	end
	
	return szMsg;
end

-- 获得到下级声望需要的点数
function Item:ExChangeLongHun_GetNextLevReputeNeed()
	local tbFullReputeInfo = KPlayer.GetReputeInfo();
	local tbNeedRetpute = {};
	
	for nType, tbData in pairs(self.tbExchangeMatchTable) do
		local nCamp, nClass = unpack(tbData, 1, 2);
		local nCurRetpLev = me.GetReputeLevel(nCamp, nClass);
		local nCurValue = me.GetReputeValue(nCamp, nClass);
		local tbReputeInfo = tbFullReputeInfo[nCamp][nClass];
		
		-- nCurValue为-1则表示该声望已满
		if nCurValue >= 0 then
			tbNeedRetpute[nType] = tbReputeInfo[nCurRetpLev].nLevelUp - nCurValue;
		end
	end
	
	return tbNeedRetpute;
end

-- 计算实际会消耗的道具
function Item:ExChangeLongHun_CalcCostItems(tbItemList)
	local tbNeedRepute = self:ExChangeLongHun_GetNextLevReputeNeed();
	
	local tbCostItems = {};
	local tbActualRetpute = {};
	for nType, tbInfo in pairs(tbItemList) do
		local nCount = tbInfo.nCount;
		local nNeedValue = tbNeedRepute[nType];
		local nActualRepute = 0;		
		
		if nCount * self.REPUTE_ADD_PRE_PIECE > nNeedValue then
			nCount = math.ceil(nNeedValue/self.REPUTE_ADD_PRE_PIECE);
			nActualRepute = nNeedValue;
		end
		
		tbCostItems[nType] = nCount;
		tbActualRetpute[nType] = nActualRepute == 0 and nCount * self.REPUTE_ADD_PRE_PIECE or nActualRepute;
	end
	
	return tbCostItems, tbActualRetpute;
end

function Item:ExChangeLongHun_CheckItemValid(pItem)
	if not pItem then
		return 0;
	end
	
	local nMatchParticular = pItem.nParticular;		
	if pItem.szClass ~= "longhun_piece" or 
		not self.tbExchangeMatchTable[nMatchParticular] then
		me.Msg("只能放入龙魂声望物品。");
		return 0;
	end
	
	-- 放入碎片的等级要与对应声望的当前等级一致
	-- 同时也保证了同一类型的碎片只能放入一种等级的
	local tbMathcInfo = self.tbExchangeMatchTable[nMatchParticular];
	local nReputeLevel = me.GetReputeLevel(unpack(tbMathcInfo, 1, 2));
	if pItem.nLevel ~= nReputeLevel then
		local tb = self:ExChangeLongHun_GetRightItemGDPL();
		if not tb or Lib:CountTB(tb) == 0 then
			me.Msg("您的龙魂鉴装备系列声望已满，不需要再兑换了！");
		else
			me.Msg("您放入的材料不正确，只能放入"..self:__FormatRightItemTips(tb).."来提升对应声望。");
			if MODULE_GAMESERVER then
				Dialog:SendBlackBoardMsg(me, "您放入的材料不正确");
			else
				Ui:ServerCall("UI_TASKTIPS", "Begin", "您放入的材料不正确");
			end
		end
		
		return 0;
	end
	
	return 1;
end

function Item:ExChangeLongHun_GetInitMsg()
	local szMsg = "你当前最多需要上交：";
	
	local tbGDPLs = self:ExChangeLongHun_GetRightItemGDPL();
	if not tbGDPLs or Lib:CountTB(tbGDPLs) == 0 then
		szMsg = "您的龙魂鉴系列装备声望已满，不用再兑换了！";
		return szMsg;
	else		
		szMsg = szMsg..self:__FormatRightItemTips(tbGDPLs, 1, 1, 1);
	end
	
	return szMsg;
end

function Item:ExChangeLongHun_OnOK(tbItemObj, nStep)
	nStep = nStep or 0;
	if nStep == 0 then
		local tbItemList = {};
		for _, tbItem in pairs(tbItemObj or {}) do
			local pItem = tbItem[1];
			if self:ExChangeLongHun_CheckItemValid(pItem) == 0 then
				return 0;
			end
			
			local nMatchParticular = pItem.nParticular;
			tbItemList[nMatchParticular] = tbItemList[nMatchParticular] or {};
			table.insert(tbItemList[nMatchParticular], pItem);
		end
		
		if Lib:CountTB(tbItemList) == 0 then
			return 0;
		end
		
		--local szMsg = self:__FormatExchangeTip(tbItemList);
		local szMsg = self:ExChangeLongHun_GetInitMsg();
		local tbOpt = 
		{
			{"Xác nhận", self.ExChangeLongHun_OnOK, self, tbItemList, 1},
			{"取消"},
		}
		Dialog:Say(szMsg, tbOpt);
	end
	
	if nStep == 1 then
		local tbNeedRepute = self:ExChangeLongHun_GetNextLevReputeNeed();
		local tbAddRepute = {};
		local tbCostItems = {};
		for nType, tbInfo in pairs(tbItemObj) do
			local nNeedValue = tbNeedRepute[nType];
			for _, pItem in pairs(tbInfo) do
				tbCostItems[nType] = tbCostItems[nType] or {string.format("%d_%d_%d_%d", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel), 0};
				if self:ExChangeLongHun_CheckItemValid(pItem) == 1 and pItem.nParticular == nType then
					local nCalcValue = pItem.nCount * self.REPUTE_ADD_PRE_PIECE;
					local nRes = 0;
					local nThisCostItem = 0;
					if nNeedValue > nCalcValue then
						nThisCostItem = pItem.nCount;
						nRes = me.DelItem(pItem, Player.emKLOSEITEM_USE);
					else
						nThisCostItem = math.ceil(nNeedValue/self.REPUTE_ADD_PRE_PIECE);
						nRes = pItem.SetCount(pItem.nCount - math.ceil(nNeedValue/self.REPUTE_ADD_PRE_PIECE), Player.emKLOSEITEM_USE);
						nCalcValue = nNeedValue;
					end
					
					if nRes == 1 then
						tbCostItems[nType][2] = tbCostItems[nType][2] + nThisCostItem;
						tbAddRepute[nType] = (tbAddRepute[nType] or 0) + nCalcValue;
						nNeedValue = nNeedValue - nCalcValue;
						if nNeedValue <= 0 then
							break;
						end
					end
				end
				--tbNeedRepute[nType] = nNeedValue;
			end	
		end

		for nType, nRepute in pairs(tbAddRepute) do
			local tbMathcInfo = self.tbExchangeMatchTable[nType];
			me.AddRepute(tbMathcInfo[1], tbMathcInfo[2], nRepute);
			
			-- 埋啊埋啊埋了个点
			local szContent = string.format("%s, %d", tbCostItems[nType][1], tbCostItems[nType][2]);
			StatLog:WriteStatLog("stat_info", "dragon_soul", "turn_over", me.nId, szContent);
		end
	end
end

function Item:ExchangeEqToCurrency_CheckGiftItem(tbGiftSelf, pPickItem, pDropItem, nX, nY)
	local nRetCurrency = 0;
	local pItem = tbGiftSelf:First();
	while pItem do
		nRetCurrency = nRetCurrency + math.floor(pItem.nPrice * self.EQUIP_TO_CURRENCY_RATE / 10000);
		pItem = tbGiftSelf:Next();
	end	
	
	if pDropItem then
		if pDropItem.IsExEquip() ~= 1 or pDropItem.nEnhTimes ~= 0 then
			me.Msg("只能放入未强化的龙魂装备");
			return 0;
		end
		
		if pDropItem.IsEquipHasStone() == 1 then
			me.Msg("请不要放入嵌有宝石的装备");
			return 0;
		end
		
		nRetCurrency = nRetCurrency + math.floor(pDropItem.nPrice * self.EQUIP_TO_CURRENCY_RATE / 10000);
	end
	
	if pPickItem then
		nRetCurrency = nRetCurrency - math.floor(pPickItem.nPrice * self.EQUIP_TO_CURRENCY_RATE / 10000);
		nRetCurrency = nRetCurrency >= 0 and nRetCurrency or 0;
	end
	
	local szContent = string.format("你将一共兑换得到%d个龙纹银币。", nRetCurrency);
	if nRetCurrency == 0 then
		szContent = "放入未强化的龙魂装备，每件龙魂装备可兑换购买价格"..self.EQUIP_TO_CURRENCY_RATE.."%的龙纹银币！";
	end
	tbGiftSelf:UpdateContent(szContent);
		
	return 1;
end