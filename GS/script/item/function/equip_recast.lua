-- 文件名　：equip_recast.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-02-28 16:36:33
-- 描述：装备重铸

-- 重铸符classname
Item.RECAST_ITEM_CLASS = "recastitem";

Item.emITEM_COUNT_RANDOM = 6;	--随机属性种子个数

Item.emEQUIP_LONGHUN_RECAST_PRICE_RATE  = 20;	-- 龙魂装备重铸货币消耗万分比
Item.tbLonghunCurrencyItemId			= {18,1,1672,1};	-- 龙纹银币道具ID

-- 这个跟代码里定义的货币类型不是相同的
Item.emEQUIP_RECAST_CURRENCY_MONEY 		= 1;	-- 银两、绑银
Item.emEQUIP_RECAST_CURRENCY_LONGHUN	= 2;	-- 龙纹银币



--计算重铸需要的钱
function Item:CalcRecastMoney(pEquip)
	if not pEquip then
		return 0;
	end
	
	local nCurrencyType = self.emEQUIP_RECAST_CURRENCY_MONEY;
	local nPrice = pEquip.nPrice;
	if not nPrice then
		return 0;
	end
	
	if pEquip.IsExEquip() == 1 then
		nPrice = math.ceil(nPrice/10000 * self.emEQUIP_LONGHUN_RECAST_PRICE_RATE);
		nCurrencyType = self.emEQUIP_RECAST_CURRENCY_LONGHUN;
	end	
	
	return nPrice, nCurrencyType;
end


--检测重铸放入的东西
function Item:CheckDropRecastItem(tbRecastItem)
	local bHasEquip,bHasRecastItem = 0,0;
	local nItemCount = 0;
	for _,pItem in pairs(tbRecastItem) do
		if pItem and pItem.IsEquip() == 1 then
			bHasEquip = 1;
		end
		if pItem and pItem.szClass == Item.RECAST_ITEM_CLASS then
			bHasRecastItem = 1;
		end
		nItemCount = nItemCount + 1; 	
	end
	if nItemCount ~= 2 then
		--提示放入过多东西,或者不够
		return 0,"请放入要重铸的装备和重铸符!";
	end
	if bHasEquip == 1 and bHasRecastItem == 1 then
		return 1;
	else
		--提示要放入重铸的武器和重铸符
		return 0,"请放入要重铸的装备和重铸符!";
	end
end

--获得要重铸的装备
function Item:GetOldEquip(tbRecastItem)
	if not tbRecastItem then
		return;
	end
	local bCanRecast = self:CheckDropRecastItem(tbRecastItem);
	if bCanRecast == 0 then
		return;
	else
		for _,pItem in pairs(tbRecastItem) do
			if pItem and pItem.IsEquip() == 1  then
				return pItem;
			end
		end
	end
end

--获得重铸符
function Item:GetRecastItem(tbRecastItem)
	if not tbRecastItem then
		return;
	end
	local bCanRecast = self:CheckDropRecastItem(tbRecastItem);
	if bCanRecast == 0 then
		return;
	else
		for _,pItem in pairs(tbRecastItem) do
			if pItem and pItem.szClass == Item.RECAST_ITEM_CLASS  then
				return pItem;
			end
		end
	end
end


--计算重铸需要的数据
function Item:CalcRecast(pOldEquip)
	if not pOldEquip then
		return;
	end
	local nNewRandSeed = GetRandSeed(1);
	local tbRandMa	= {};
	for i = 1, Item.emITEM_COUNT_RANDOM do
		tbRandMa[i] = MathRandom(0,255);
	end
	local nNeedMoney, nCurrencyType = self:CalcRecastMoney(pOldEquip);
	return tbRandMa,nNewRandSeed,nNeedMoney, nCurrencyType;
end

-- 消耗货币
function Item:CostRecastCurrency(nValue, nType)
	nType = nType or self.emEQUIP_RECAST_CURRENCY_MONEY;  -- 默认消耗银两？？？

	if nType == self.emEQUIP_RECAST_CURRENCY_MONEY then
		if (me.nCashMoney  < nValue) then
			me.Msg("你身上的银两不足，不能重铸！");
			return 0;
		else
			me.CostMoney(nValue, Player.emKPAY_EQUIP_RECAST);
			KStatLog.ModifyAdd("jxb", "[消耗]装备重铸", "总量", nValue);			
		end
	elseif nType == self.emEQUIP_RECAST_CURRENCY_LONGHUN then
		local nCount = me.GetItemCountInBags(unpack(self.tbLonghunCurrencyItemId));
		if nCount < nValue then
			me.Msg("你身上的龙纹银币数量不足，不能重铸！");
			return 0;
		end
		
		local nLeftCount = me.ConsumeItemInBags(nValue, unpack(self.tbLonghunCurrencyItemId));
		if nLeftCount ~= 0 then
			Dbg:WriteLog("Recast", "角色名："..me.szName, "消耗"..(nValue-nLeftCount).."个龙纹银币，数量不足，未能重铸！");
			return 0;
		end
--		if me.PayValueCoin(self.emLONGHUN_CURRENCY_INDEX, nValue) ~= 1 then
--			me.Msg("你的龙纹银币数量不足，不能重铸！");
--			return 0;
--		else
--			-- TODO:龙纹银币的消耗是不是记成这样？？
--			KStatLog.ModifyAdd("lhyb", "[消耗]装备重铸", "总量", nValue);	
--		end
	else
		return 0;
	end
	
	return 1;
end


--重铸
function Item:EquipRecast(tbRecastItem, nMoneyType, nIndex)
	me.GetTempTable("Item").tbEquip = nil;
	local tbPlayerEquip = me.GetTempTable("Item");
	local bCheck,szMsg = self:CheckDropRecastItem(tbRecastItem);
	if bCheck == 0 then
		me.Msg(szMsg,"系统");
		return 0;
	end
	local pOldEquip = self:GetOldEquip(tbRecastItem);
	if not pOldEquip then
		Dbg:WriteLog("EquipRecast", "角色名:"..me.szName, "帐号:"..me.szAccount, "旧装备异常");
		return 0;
	end
	local pRecastItem = self:GetRecastItem(tbRecastItem);
	if not pRecastItem then
		Dbg:WriteLog("EquipRecast", "角色名:"..me.szName, "帐号:"..me.szAccount, "重铸符异常");
		return 0;
	end
	--存储服务器上的装备info
	local tbRandMa,nNewRandSeed,nMoney, nCurrencyType = self:CalcRecast(pOldEquip);
	tbPlayerEquip.tbEquip = {};
	tbPlayerEquip.tbEquip.dwEquipId = pOldEquip.dwId;
	tbPlayerEquip.tbEquip.nNewRandSeed = nNewRandSeed;
	tbPlayerEquip.tbEquip.tbRandMa = {};
	tbPlayerEquip.tbEquip.nItemBindType = pRecastItem.IsBind();
	for i = 1,#tbRandMa do
		tbPlayerEquip.tbEquip.tbRandMa[i] = tbRandMa[i];
	end
	if pOldEquip.IsEquip() == 1 and 
				(pOldEquip.nDetail < Item.MIN_COMMON_EQUIP or 
				pOldEquip.nDetail > Item.MAX_COMMON_EQUIP) then
		me.Msg("参与五行激活的装备才能进行重铸！");
		return 0;
	end
	if pOldEquip.nGenre == 1 then
		me.Msg("该装备不能参与重铸！");
		return 0;
	end
	if pRecastItem.szClass ~= Item.RECAST_ITEM_CLASS or pOldEquip.IsEquip() ~= 1 then
		me.Msg("只能放置重铸的装备和重铸符！");
		return 0;
	end
	
	if self:CostRecastCurrency(nMoney, nCurrencyType) ~= 1 then
		return 0;
	end
	
	-- 记录道具信息，写LOG
	local szEquipName = pOldEquip.szName;
	local nOldEnhTimes = pOldEquip.nEnhTimes;
	local szItemName = pRecastItem.szName;	
	
	if pRecastItem.nCount > 1 then
		pRecastItem.SetCount(pRecastItem.nCount - 1, Player.emKLOSEITEM_RECAST_DEL);
	else
		local nRet =  me.DelItem(pRecastItem, Player.emKLOSEITEM_RECAST_DEL);
		if nRet ~= 1 then	--扣除失败		
			Dbg:WriteLog("Recast", "角色名:"..me.szName, "帐号:"..me.szAccount, "扣除重铸符失败", tostring(pRecastItem.dwId),pRecastItem.szName);
			return 0;
		end
	end	

	--客服log------------
	local szPlayerLog = string.format("玩家: %s ,重铸装备{%s_%d} ,扣除道具%s成功!",me.szName, szEquipName, nOldEnhTimes, szItemName);
	me.PlayerLog(Log.emKITEMLOG_TYPE_USE, szPlayerLog);
	---------------------
	--数据埋点
	local szTypeName = Item.EQUIPPOS_NAME[KItem.EquipType2EquipPos(pOldEquip.nDetail)];
	local szLevel = tostring(pOldEquip.nLevel);
	local szEnhanceLevel = tostring(pOldEquip.nEnhTimes);
	StatLog:WriteStatLog("stat_info", "zhuangbei","recast", me.nId,szTypeName,szLevel,szEnhanceLevel);

	return 1,nNewRandSeed or 0,tbRandMa;
end




