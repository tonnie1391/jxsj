
-- 装备修理功能脚本

local REPAIR_ITEM_CLASS	= "jinxi";				-- 修理消耗品：金犀
------------------------------------------------------------------------------------------
--define
Item.DUR_COST_PER_YEAR = (2 / 5) * 3600 * 6 * 365 / 20;		--每天打怪6小时,一年365天消耗的耐久上限点数
Item.EQUIP_TOTAL_RATE = 4 * 1 + 1.5 * 4 + 1 * 5;			-- 所有装备总比率 武器*4，首饰*1.5，防具*1
Item.ALL_EQUIP_MIN_VALUE = 5000000							-- 全套装备价值量最小值（500W）
Item.ALL_EQUIP_MAX_VALUE = 500000000						-- 全套装备价值量最大值（50000W）
Item.VALUEPERCEN_PER_YEAR = 0.3								-- 全年修理费用是总价值量的 30%

------------------------------------------------------------------------------------------
-- interface

function Item:CommonRepair()					-- 程序回调接口：普通修理

	-- 是否可以修理
	if (it.IsEquip() ~= 1) then					-- 不是装备就不修
		return	0;
	end
	if (it.nCurDur >= it.nMaxDur) then			-- 不需要修理
		return	0;
	end

	-- 扣钱
	local nPrice = self:CalcCommonRepairPrice(it);
	if (me.nCashMoney < nPrice) then			-- 钱不够则不修
		me.Msg("Không đủ bạc!");
		return	0;
	end
	if (me.CostMoney(nPrice, Player.emKPAY_REPAIR) ~= 1) then				-- 扣钱失败，异常错误
		me.Msg("Không đủ bạc!");
		return	0;
	end
	if nPrice > 0 then
		KStatLog.ModifyAdd("jxb", "[Tiêu hao] Sửa chữa trang bị", "Tổng", nPrice);
	end
	local nOldMax = math.floor(it.nMaxDur / 10);

	if (it.nMaxDur <= Item.DUR_WARNING) then	-- 最大耐久太低，给出提示
		if (MathRandom(100) < 30) then			-- 30%的几率损坏
			it.nMaxDur = 0;
			it.nCurDur = 0;
			me.Msg("<"..it.szName.."> của bạn đã hỏng, bạn cần phục hồi độ bền lớn nhất mới có thể sử dụng.");
			return	1;
		end
	else
		local nMaxDur = self:CalcCommentDurReduce(it);
		if nMaxDur <= Item.DUR_WARNING then
			nMaxDur = Item.DUR_WARNING;
		end
		it.nMaxDur = nMaxDur;	-- 降低最大耐久
	end

	if (it.nMaxDur <= Item.DUR_WARNING) then
		me.Msg("<"..it.szName.."> đã xuống mức thấp nhất, có thể hỏng bất cứ lúc nào, bạn cần dùng <Kim Tê> để sửa.");
	end

	it.nCurDur = it.nMaxDur;	-- 进行修理
	local nDelta = nOldMax - math.floor(it.nMaxDur / 10);
	me.Msg(""..it.szName.." của bạn đã phục hồi, độ bền lớn nhất giảm "..nDelta.." điểm.");
	SpecialEvent.ActiveGift:AddCounts(me, 42);		--修理装备活跃度
	return	1;

end

function Item:SpecialRepair()					-- 程序回调接口：特殊修理
	
	if (GLOBAL_AGENT and Player.bForbid_GblSever_SpeRepair == 1) then
		me.Msg("Liên Server không thể sửa chữa trang bị.");
		return 0;
	end
	
	-- 是否可以修理
	if (it.IsEquip() ~= 1) then					-- 不是装备就不修
		return	0;
	end

	local nPrice = self:CalcSpecialRepairPrice(it);
	if (nPrice <= 0) then		-- 不需要修理
		return	0;
	end

	-- 扣钱
	if (me.CostBindMoney(nPrice, Player.emKBINDMONEY_COST_REPAIR2) ~= 1) then
		if (me.nCashMoney + me.GetBindMoney() < nPrice) then
			me.Msg("Số bạc bạn đem theo không đủ!");
			return -1;
		else
			local nBindMoney = me.GetBindMoney();
			me.CostBindMoney(nBindMoney, Player.emKBINDMONEY_COST_REPAIR2);
			me.CostMoney(nPrice - nBindMoney, Player.emKPAY_REPAIR2);
			KStatLog.ModifyAdd("bindjxb", "[Tiêu hao] Sửa chữa trang bị", "Tổng", nBindMoney);
			KStatLog.ModifyAdd("jxb", "[Tiêu hao] Sửa chữa trang bị", "Tổng", nPrice - nBindMoney);
		end
	else
		KStatLog.ModifyAdd("bindjxb", "[Tiêu hao] Sửa chữa trang bị", "Tổng", nPrice);
	end

	-- 修理程序
	it.nMaxDur = Item.DUR_MAX;					-- 补满最大耐久
	it.nCurDur = it.nMaxDur;					-- 补满当前耐久
	me.Msg(""..it.szName.." đã phục hồi.");
	SpecialEvent.ActiveGift:AddCounts(me, 42);		--修理装备活跃度
	return	1;

end

function Item:ItemRepair(pUseItem)				-- 程序回调接口：使用道具修理

	if (pUseItem.szClass ~= REPAIR_ITEM_CLASS) then
		return;									-- 不是修理消耗品，不能修理
	end

	-- 检查道具有效性，防止BUG
	local nItemDur = pUseItem.GetGenInfo(1);	-- 取修理消耗品耐久
	if (nItemDur <= 0) then
		me.DelItem(pUseItem, Player.emKLOSEITEM_REPAIR);
	end

	-- 是否可以修理
	if (it.IsEquip() ~= 1) then					-- 不是装备就不修
		return	0;
	end
	
	self:CommonRepair();

	-- 扣道具耐久
	local nPrice, nAddDur = self:CalcItemRepairPrice(it, nItemDur);
	if (nPrice < 0) then
		me.Msg("Trang bị còn tốt, khỏi sửa");
		return	0;
	end

	if (nAddDur <= 0) then
		me.Msg("Độ bền của Kim Tê không đủ!");
		return	0;
	end

	nItemDur = nItemDur - nPrice;

	if (nItemDur <= 0) then
		if me.DelItem(pUseItem, Player.emKLOSEITEM_REPAIR) ~= 1 then					-- 如果耐久减到0则扣除修理消耗品
			return 0;
		end
	else
		pUseItem.SetGenInfo(1, nItemDur);		-- 设置新耐久
		pUseItem.Sync();
	end

	-- 修理程序
	local nMaxDur = it.nMaxDur + nAddDur;		-- 增加最大耐久
	if (nMaxDur > Item.DUR_MAX) then
		nMaxDur = Item.DUR_MAX;
	end
	it.nMaxDur = nMaxDur;
	it.nCurDur = it.nMaxDur;					-- 补满当前耐久
	me.Msg(""..it.szName.." đã phục hồi "..nAddDur.." điểm.");
	SpecialEvent.ActiveGift:AddCounts(me, 42);		--修理装备活跃度
	return	1;

end

function Item:CalcCommonRepairPrice(pEquip)		-- 计算普通修理价钱(JXB)
	return	0;									-- 普修不要钱
end

function Item:CalcCommentDurReduce(pEquip)		-- 计算普通修理后的最大耐久
	return pEquip.nMaxDur - math.ceil((pEquip.nMaxDur - pEquip.nCurDur) / 20);
end

function Item:CalcSpecialRepairPrice(pEquip)	-- 计算特殊修理价钱(JXB)
	local nCurMaxDur = self:CalcCommentDurReduce(pEquip);
	local nAddDur = Item.DUR_MAX - nCurMaxDur;
	local nMoneyCostPerDur = self:CalcSpecialRepairCoin(pEquip) * self:GetJbPrice() * 100;	--修理每点耐久上限需要的银两数量
	if (nAddDur <= 0) then
		return -1;
	end
	return	math.max(math.ceil(nAddDur * nMoneyCostPerDur), 1);
end

function Item:CalcItemRepairPrice(pEquip, nItemDur)	-- 计算特殊修理价钱(修理消耗品的耐久)
	local nCurMaxDur = self:CalcCommentDurReduce(pEquip);
	local nLostDur = Item.DUR_MAX - nCurMaxDur;
	local nAddDur  = nLostDur;
	local JINXI2COIN 	= 10000/600;	--600金币10000点金犀耐久
	local JINXIAGIO		= 0.8;			--鼓励金犀修理,打8折
	if (nLostDur <= 0) then
		return -1;
	end
	local nItemDurCostPerDur = self:CalcSpecialRepairCoin(pEquip) * JINXI2COIN * JINXIAGIO;	--修理每点耐久上限需要的金犀耐久
	if nItemDur then	-- 计算指定的消耗品耐久可以修复多少点当前装备的最大耐久
		nAddDur = math.floor(nItemDur / nItemDurCostPerDur);
		if (nAddDur > nLostDur) then
			nAddDur = nLostDur;
		end
	end
	return math.max(math.ceil(nAddDur * nItemDurCostPerDur), 1), nAddDur;
end

function Item:CalcSpecialRepairCoin(pEquip)
	local tbSetting = Item:GetExternSetting("value", pEquip.nVersion);
	if (not tbSetting) then
		return -1;
	end
	local nRate = (tbSetting.m_tbEquipTypeRate[pEquip.nDetail] or 100) / 100;
	local nFinalValue = math.max(pEquip.nValue, self.ALL_EQUIP_MIN_VALUE * nRate / self.EQUIP_TOTAL_RATE);
	nFinalValue = math.min(nFinalValue, self.ALL_EQUIP_MAX_VALUE * nRate / self.EQUIP_TOTAL_RATE);
	local nCoinCostPerDur = (nFinalValue * self.VALUEPERCEN_PER_YEAR / self.DUR_COST_PER_YEAR)/100;--修理每点耐久上限需要的金币数
	return nCoinCostPerDur;
end


