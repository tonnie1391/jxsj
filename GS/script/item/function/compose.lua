
-- 玄晶合成功能脚本

------------------------------------------------------------------------------------------
local COMITEM_CLASS = "xuanjing";	-- 道具类型：玄晶
local PEEL_ITEM = { nGenre = Item.SCRIPTITEM, nDetail = 1, nParticular = 1 };	-- 玄晶

-- 各等级玄晶的信息表
local tbCrystal;

local function InitCrystalTable(tbComItem)
	tbCrystal = {};
	for i = 1, 12 do
		tbCrystal[i] = KItem.GetItemBaseProp(18, 1, 1, i);
	end 
end


--获取放入的玄晶的最高等级
function Item:GetComItemMaxLevel(tbComItem)
	local nMaxLevel = 0;
	for i,pItem in pairs(tbComItem) do
		if pItem.szClass ~= COMITEM_CLASS then
			return 0;
		end
		if pItem.nLevel >= nMaxLevel then
			nMaxLevel = pItem.nLevel;
		end
	end
	return nMaxLevel;
end


-- 计算合成价值预算(服务端客户端共用)
function Item:GetComposeBudget(tbComItem, nMoneyType)
	local nTotalValue = 0;
	local bBind = 0;
	if not tbCrystal then
		InitCrystalTable();
	end
	local nTime = 0;
	local tbAbsTime;
	local tbCalcuate = {};
	for i, pItem in pairs(tbComItem) do
		nTotalValue = nTotalValue + pItem.nValue;
		if pItem.IsBind() == 1 then	-- 有一个玄晶绑定则绑定
			bBind = 1;
		end
		if pItem.szClass ~= COMITEM_CLASS then
			return 0;
		end
		local tbTime = me.GetItemAbsTimeout(pItem);
		if tbTime then
			local nNewTime = tbTime[1] * 100000000 + tbTime[2] * 1000000 + 
				tbTime[3] * 10000 + tbTime[4] * 100 + tbTime[5];
			if nTime == 0 or nNewTime < nTime then
				nTime = nNewTime;
				tbAbsTime = tbTime;
			end
		end
		local szName = pItem.szName
		if not tbCalcuate[szName] then
			tbCalcuate[szName] = 0;
		end
		tbCalcuate[szName] = tbCalcuate[szName] + 1;
	end
	local szLog = ""
	if MODULE_GAMESERVER then
		for szName, nCount in pairs(tbCalcuate) do
			szLog = szLog..szName..nCount.."个  ";
		end
	end
	local nMinLevel = 0;
	for i = 1, 12 do
		if nTotalValue >= tbCrystal[i].nValue then
			nMinLevel = i;
		end
	end
	local nFee = math.ceil(nTotalValue / 10 * self:GetJbPrice());
	
	local nMinLevelRate = 0;
	local nMaxLevelRate = 0
	if nMinLevel >= 12 then
		nMinLevel = 11;
		nMinLevelRate = 0;
		nMaxLevelRate = 1;
	else
		nMinLevelRate = tbCrystal[nMinLevel + 1].nValue - nTotalValue;
		nMaxLevelRate = nTotalValue - tbCrystal[nMinLevel].nValue;
	end
	if (bBind == 0) and (nMoneyType == Item.BIND_MONEY) then
		bBind = 1;
	end
	return nMinLevel, nMinLevelRate, nMinLevel + 1, nMaxLevelRate, nFee, bBind, tbAbsTime, szLog;
end


function Item:Compose(tbComItem, nMoneyType, nParam)
	local nTeQuanFlag, szTeQuanMsg = SpecialEvent.tbTequan["openhexuan"]:Check(me.nId);
	if nTeQuanFlag == 2 then
		return; -- 是特权用户，但是当前地图不能合玄，则直接返回
	end
	
	-- nTeQuanFlag == 1 则满足合玄条件，nTeQuanFlag == 0 ，则表示不是特权用户，需要走原有的判断流程
	if nTeQuanFlag == 0 then
		if (me.nFightState ~= 0) then
			me.Msg("战斗状态下不能进行此操作！");
			return 0;
		end
	end
	local nIbValue = 0;
	local nMinLevel, nMinLevelRate, nMaxLevel, nMaxLevelRate, nFee, bBind, tbAbsTime, szLog = Item:GetComposeBudget(tbComItem, nMoneyType);
	local nMaxLevelInComItem = Item:GetComItemMaxLevel(tbComItem);
	if nMinLevel < 1 then
		me.Msg("不能合成！合成物中有非玄晶道具！")
		return 0;
	end
	
	if nMaxLevelInComItem == nMinLevel and 100*nMaxLevelRate/(nMaxLevelRate+nMinLevelRate) < 1 then
		me.Msg("不能合成！当前合成率无法合成更高级的玄晶！");
		return 0;
	end 
	
	-- 合成玄晶不需检查背包空间的前提是玄晶不可叠加，如果可叠加需要检查背包空间
	-- TODO
	local nUnBindLogType = Player.emKPAY_COMPOSE;
	if bBind == 1 then
		nUnBindLogType = Player.emKPAY_COMPOSE_BIND;
	end
		
	if (nMoneyType == Item.NORMAL_MONEY and me.CostMoney(nFee, nUnBindLogType) ~= 1) then	-- 扣除金钱
		me.Msg("你身上银两不足，不能合成！");
		return 0;
	elseif (nMoneyType == Item.BIND_MONEY and me.CostBindMoney(nFee, Player.emKBINDMONEY_COST_COMPOSE) ~= 1) then
		me.Msg("你身上的绑定银两不足，不能合成！");
		return 0;
	elseif (nMoneyType ~= Item.NORMAL_MONEY)and (nMoneyType ~= Item.BIND_MONEY) then
		return 0;
	end
	
	if nMoneyType == Item.NORMAL_MONEY then
		KStatLog.ModifyAdd("jxb", "[消耗]玄晶合成", "总量", nFee);
	end
	
	if nMoneyType == Item.BIND_MONEY then
		KStatLog.ModifyAdd("bindjxb", "[消耗]玄晶合成", "总量", nFee);
	end
	
	--if nMoneyType == Item.NORMAL_MONEY then
	--	nIbValue = nIbValue + nFee / Spreader.ExchangeRate_Gold2Jxb;
	--end
	
	local szSucc = "成功率:"..nMaxLevelRate.."/"..(nMinLevelRate + nMaxLevelRate).."的概率能合成"..nMaxLevel.."级玄晶";
	Dbg:WriteLog("Compose", "角色名:"..me.szName, "帐号:"..me.szAccount, "原料:"..szLog, szSucc);
	
	-- 删除玄晶
	for i = 1, #tbComItem do
		if tbComItem[i].nBuyPrice > 0 then -- 有Ib价值量
			nIbValue = nIbValue + tbComItem[i].nBuyPrice; -- Ib价值仍然附在非绑定玄晶上
		end

		local szItemName = tbComItem[i].szName;
		local nRet = me.DelItem(tbComItem[i], Player.emKLOSEITEM_TYPE_COMPOSE);		-- 扣除玄晶
		if nRet ~= 1 then
			Dbg:WriteLog("Compose", "角色名:"..me.szName, "帐号:"..me.szAccount, "扣除"..szItemName.."失败");
			return 0;
		end
	end
	
	local nRandom = Random(nMinLevelRate + nMaxLevelRate);
	local nResultLevel = 0;
	if nRandom < nMinLevelRate then
		nResultLevel = nMinLevel;
	else
		-- 合成了较高级的玄晶
		nResultLevel = nMaxLevel;
	end
	-- 给予玄晶
	local pItem;
	local tbGive = {}
	tbGive.bForceBind = bBind;
	if tbAbsTime then
		tbGive.bTimeOut = 1;
	end
	pItem = me.AddItemEx(PEEL_ITEM.nGenre, PEEL_ITEM.nDetail, PEEL_ITEM.nParticular, nResultLevel, tbGive, Player.emKITEMLOG_TYPE_COMPOSE);
	if pItem and tbAbsTime then
		local nTime = os.time({year = tbAbsTime[1], month=tbAbsTime[2], day=tbAbsTime[3], hour=tbAbsTime[4], min=tbAbsTime[5]});
		me.SetItemTimeout(pItem, os.date("%Y/%m/%d/%H/%M/00", nTime));
	end
	if not pItem then
		-- 给予玄晶失败？记个log吧
		Dbg:WriteLog("Compose", "角色名:"..me.szName, "帐号:"..me.szAccount,"给予"..nResultLevel.."级玄晶失败！");
		return 0;
	else
		Dbg:WriteLog("Compose", "角色名:"..me.szName, "合成一个"..pItem.szName);
	end

	if bBind ~= 1 then
		pItem.nBuyPrice = nIbValue;
	else
		Spreader:AddConsume(nIbValue, 1, "[玄晶合成]玄晶");
	end

	return nResultLevel;
end

