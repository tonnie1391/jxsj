-- 文件名　：enhance_transfer.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-02-28 16:36:46
-- 描述：强化转移

--转义符classname
Item.ENHANCE_TRANSFER = "enhancetransfer";	
Item.TRANSFER_REBATE  = 0.3;	--转移符的折扣率

local MAX_BEYOND_VALUE = 16796;	--最大超出价值量
local ENHITEM_CLASS 	= "xuanjing";
local emWeapon  = 1;
local emAromr   = 2;
local emJewelry = 3;

Item.nDisCount = 9;  	--转移装备等级9 免费传送符用	

Item.TRANSFER_EQUIP_CLASS =  {	    -- 武器
									[emWeapon] = {Item.EQUIP_MELEE_WEAPON, 
											  Item.EQUIP_RANGE_WEAPON},
									-- 防具									  
									[emAromr]  = {Item.EQUIP_ARMOR,
											  Item.EQUIP_BOOTS,
											  Item.EQUIP_BELT,
											  Item.EQUIP_HELM,
											  Item.EQUIP_CUFF},
									-- 饰品							
									[emJewelry] = {Item.EQUIP_RING,
											   Item.EQUIP_NECKLACE,
											   Item.EQUIP_AMULET,
											   Item.EQUIP_PENDANT}
								};


--检测装备类型
function Item:GetEquipType(pEquip)
	if not pEquip then
		return 0;
	end
	local nDetail = pEquip.nDetail;
	for nType,tbDetail in pairs(Item.TRANSFER_EQUIP_CLASS) do
		if tbDetail then
			for _,nDet in pairs(tbDetail) do
				if nDetail == nDet then
					return nType;
				end 
			end
		end
	end
	return 0;
end


--检测放入的东西
function Item:CheckDropItem(tbTransferItem)
	local bHasEquip,bHasTransferItem = 0,0;
	local bHasOtherItem = 0;
	local nEquipCount,nTransferItemCount = 0,0;
	for _,pItem in pairs(tbTransferItem) do
		local nParam = tonumber(pItem.GetExtParam(1));
		if pItem and pItem.szClass == Item.ENHANCE_TRANSFER then
			nTransferItemCount = nTransferItemCount + 1;
			bHasTransferItem = 1;
		end
		if pItem and pItem.IsEquip() == 1 then
			bHasEquip = 1;
			nEquipCount = nEquipCount + 1;
		end
		if pItem and pItem.IsEquip() ~= 1 and pItem.szClass ~= ENHITEM_CLASS and pItem.szClass ~= Item.ENHANCE_TRANSFER then
			bHasOtherItem = 1;
		end
	end
	--放入2个转移符或者2个道具
	if nTransferItemCount >= 2 or nEquipCount >=2 then
		return 0,"只能放入一件要转移的装备，且可以加入一件强化传承符或玄晶!";
	end
	--是否有其它物品存在
	if bHasEquip == 1 and bHasOtherItem ~= 1 then
		return 1,bHasTransferItem;
	elseif bHasOtherItem == 1 then
		return 0,"请不要放入转移不需要的物品!";
	else
		return 0,"请在下方放入要转移所需要的物品!"
	end 
end

--检测是否在可以剥离状态
function Item:IsInTransferTime(pEquip, pRegionEquip)
	if not pEquip then
		return 0;
	end
	local nCurrEnhTimes = pEquip.nEnhTimes;
	-- 强化12以上的装备 
	if nCurrEnhTimes >= 12 then
		if (pEquip.nLevel < 10 and pRegionEquip.nLevel < 10) then
			if(pEquip.IsBind()==1 and pRegionEquip.IsBind()==1) then
				return 1;
			end
		end
		local nTime = me.GetTask(self.TASK_PEEL_APPLY_GID, self.TASK_PEEL_APPLY_TIME);
		-- 没有申请过剥离
		if nTime <= 0 then
			me.Msg("请先到冶炼大师处申请高强化装备剥离","系统");
			Dialog:SendBlackBoardMsg(me, "请先到冶炼大师处申请高强化装备剥离。");
			return 0;
			-- 申请过则判断时间是否在允许段内(申请3小时-剥离3小时)
		else
			-- 取申请时间差
			local nDiffTime = GetTime() - nTime;
			-- 出错的情况
			if nDiffTime <= 0 then 
				return 0;
			-- 已经申请还不能剥离
			elseif nDiffTime <= Item.VALID_PEEL_TIME then
				me.Msg("尚未到可剥离时间，请稍等。","系统");
				Dialog:SendBlackBoardMsg(me, "尚未到可剥离时间，请稍等。");
				return 0;
			-- 过了申请期
			elseif nDiffTime >= Item.MAX_PEEL_TIME then
				me.Msg("您的上次剥离申请已经超时，请重新申请。","系统");
				Dialog:SendBlackBoardMsg(me, "您的上次剥离申请已经超时，请重新申请。");
				me.SetTask(Item.TASK_PEEL_APPLY_GID, Item.TASK_PEEL_APPLY_TIME, 0);
				return 0;
			end
		end
	end
	return 1;
end


--检测装备
function Item:CheckDropEquip(pEquip)
	if not pEquip then
		return 0;
	end
	if (1 == pEquip.IsWhite()) then
		me.Msg("参与五行激活的装备才能进行强化转移！","系统");
		return	0;
	end	
	if (pEquip.nDetail < Item.MIN_COMMON_EQUIP) or (pEquip.nDetail > Item.MAX_COMMON_EQUIP) then
		me.Msg("参与五行激活的装备才能进行强化转移！","系统");
		return	0;
	end	
	if (pEquip.nEnhTimes == Item:CalcMaxEnhanceTimes(pEquip)) then
		me.Msg("该装备已强化到极限，不可被强化转移！","系统");
		return	0;
	end
	return 1;
end

--检测原始装备
function Item:CheckRegionEquip(pEquip, pTransEquip)
	if not pEquip then
		return 0;
	end
	if (1 == pEquip.IsWhite()) then
		me.Msg("参与五行激活的装备才能进行转移！","系统");
		return	0;
	end		
	if (pEquip.nDetail < Item.MIN_COMMON_EQUIP) or (pEquip.nDetail > Item.MAX_COMMON_EQUIP) then
		me.Msg("参与五行激活的装备才能进行转移！","系统");
		return	0;
	end
	if (pEquip.nEnhTimes < 8 and (pTransEquip.nLevel > self.nDisCount or pEquip.nLevel > self.nDisCount)) then
		me.Msg("10级装备强化转移时强化等级不能低于8级！","系统");
		return	0;
	end
	--强化8以下的不可进行转移
	if (pEquip.nEnhTimes < 8 and self.bHasOtherTransferItem <= 0 ) then
		me.Msg("强化等级低于8级的装备需要免费强化转移符才可以转移！","系统");
		return	0;
	end	
	return 1;
end


--获取要转移的装备
function Item:GetRegionEquip(tbTransferItem)
	if not tbTransferItem then
		return;
	end
	local nRet,bHasTransferItem = Item:CheckDropItem(tbTransferItem);
	if nRet ~= 1 then
		return;
	else
		for _,pItem in pairs(tbTransferItem) do
			if pItem and pItem.IsEquip() == 1 then
				return pItem,bHasTransferItem;
			end
		end
	end
end

--计算需求的玄晶价值
function Item:CalcNeedXuanjingValue(pRegionEquip,bHasTransferItem)
	if not pRegionEquip then
		return 0;
	end
	local nRegionValue = Item:CalcEnhanceValue(pRegionEquip) or 0;
	local nRebate = bHasTransferItem == 1 and Item.TRANSFER_REBATE or 0;
	local nNeedXuanjingValue = 0.1 * nRegionValue * (1 - nRebate);
	return nNeedXuanjingValue;
end

--计算放入的玄晶价值
function Item:CalcDropXuanjingValue(tbTransferItem)
	if not tbTransferItem then
		return 0;
	end
	local nXuanjingValue = 0;
	for _, pItem in ipairs(tbTransferItem) do
		if pItem.szClass == ENHITEM_CLASS then
			nXuanjingValue = nXuanjingValue + pItem.nValue;
		end
	end	
	return nXuanjingValue;
end

--计算需要的银两
function Item:CalcTransferCost(pEquip,pRegionEquip,bHasTransferItem, nOtherRebate)	
	local nMoney = 0;
	local bConZoneRate = 0 ;
	if not pRegionEquip then
		return 0;
	end
	if not pEquip then
		return 0;
	end
	if nOtherRebate == 1 and (pRegionEquip.nLevel > self.nDisCount or pEquip.nLevel > self.nDisCount) then
		bHasTransferItem = 0;
	end
	local nRegionValue = Item:CalcEnhanceValue(pRegionEquip) or 0;
	local nNewValue = Item:CalcEnhanceValue(pEquip) or 0;
	local _,nReturnMoney = Item:CalcPeelItem(pRegionEquip);	
	local nRebate = (bHasTransferItem or 0 ) == 1 and Item.TRANSFER_REBATE or 0; 
	--强化优惠
	local nFreeCount, tbExecute, nExpMultipe = SpecialEvent.ExtendAward:DoCheck("EnhanceEquip", me);
	--合服优惠，合服7天后过期
	if GetTime() < KGblTask.SCGetDbTaskInt(DBTASK_COZONE_TIME) + 7 * 24 * 60 * 60 and nExpMultipe == 1 then
		bConZoneRate = 1;
	end
	--*************************************
	nMoney = math.ceil((0.1 * nRegionValue * (1 - nRebate ) * nExpMultipe * (bConZoneRate == 1 and 0.8 or 1)  - 0.1 * nNewValue) * self:GetJbPrice() - (nReturnMoney or 0)) ;
	return nMoney;
end


--计算转移度
function Item:CalcTransferProb(pEquip,tbTransferItem)
	if not pEquip then
		return -1;
	end
	local pRegionEquip,bHasTransferItem = Item:GetRegionEquip(tbTransferItem);
	local nOtherRebate, nEquipLevel = Item:CheckHasOtherRebate(pEquip,tbTransferItem);	
	if nOtherRebate == 1 and (nEquipLevel > self.nDisCount or pEquip.nLevel > self.nDisCount) then
		bHasTransferItem = 0;
	end
	if not tbTransferItem then
		return -1;
	end
	local nDropValue = Item:CalcDropXuanjingValue(tbTransferItem);
	local nNewValue =  Item:CalcEnhanceValue(pEquip);
	local nRegionValue = Item:CalcEnhanceValue(pRegionEquip);
	local nRebate = (bHasTransferItem or 0) == 1 and Item.TRANSFER_REBATE or 0;
	local nProb = (nDropValue + 0.9 * nNewValue + 0.8 * nRegionValue + 0.1 * nRegionValue * nRebate) / (nRegionValue * 0.9);
	return nProb;
end


--检测是否可以转移
function Item:CheckCanTransfer(pEquip,tbTransferItem)
	local pRegionEquip,bHasTransferItem = Item:GetRegionEquip(tbTransferItem);
	local nProb = Item:CalcTransferProb(pEquip,tbTransferItem);
	local nTransferDiscount = me.GetSkillState(2220);
	local nOtherRebate, nEquipLevel = Item:CheckHasOtherRebate(pEquip,tbTransferItem);		--转移9级以下装备，放的是新的传承符
	--强化传承优惠100%折扣
	if bHasTransferItem == 1 and ((nTransferDiscount == 1 and nOtherRebate == 0) or (nOtherRebate == 1 and nEquipLevel <= self.nDisCount and pEquip.nLevel <= self.nDisCount)) and nProb < 1 then
		nProb = 1;
	end	
	local nDropValue = Item:CalcDropXuanjingValue(tbTransferItem);
	local nNewValue =  Item:CalcEnhanceValue(pEquip);
	local pRegionEquip = Item:GetRegionEquip(tbTransferItem);
	if not pEquip then 
		return 0;
	end
	if not pRegionEquip then
		me.Msg("没有可进行强化转移的装备!","系统");
		return 0;
	end
	if nProb == -1 then
		me.Msg("没有可进行强化转移的装备!","系统");
		return 0;
	end
	if Item:CheckDropItem(tbTransferItem) ~= 1 then
		local _,szMsg = Item:CheckDropItem(tbTransferItem);
		me.Msg(szMsg,"系统");
		return 0;
	end
	if Item:CheckDropEquip(pEquip) ~= 1 then
		return 0;
	end
	if Item:CheckRegionEquip(pRegionEquip, pEquip) ~= 1 then
		return 0;
	end
	if Item:GetEquipType(pEquip) ~= Item:GetEquipType(pRegionEquip) then
		me.Msg("只能进行同类型装备之间的强化转移！","系统");
		return 0;
	end
	if pEquip.nEnhTimes > pRegionEquip.nEnhTimes then
		me.Msg("无法将强化等级低的装备转向到强化等级高的装备！","系统");
		return 0;
	end
	--[[
	if Item:CalcMaxEnhanceTimes(pEquip) ~= Item:CalcMaxEnhanceTimes(pRegionEquip) then
		me.Msg("无法转移不同最大强化等级的装备！","系统");
		return 0;
	end	--]]
	if pRegionEquip.nEnhTimes > Item:CalcMaxEnhanceTimes(pEquip) then
		me.Msg("转移装备的强化等级不能高于被转移装备的最大强化等级！","系统");
		return 0;
	end
	if Item:IsInTransferTime(pRegionEquip, pEquip) ~= 1 then
		return 0;
	end
	if nProb >= 1.2 and nDropValue + nNewValue > MAX_BEYOND_VALUE then
		me.Msg("转移度过高，无法进行转移！","系统");
		return 0;
	elseif nProb < 1.2 and nProb >= 1.0 then
		return 1;
	else
		return 0;
	end
end


--转移过程,服务器调用
function Item:EnhanceTransfer(pEquip,tbTransferItem,nMoneyType,nParam)
	if not pEquip then
		return 0;
	end
	if not tbTransferItem then
		return 0;
	end
	local nRet = Item:CheckCanTransfer(pEquip,tbTransferItem);
	if nRet ~= 1 then
		return 0;
	end
	local nTransferDiscount = me.GetSkillState(2220);
	local nOtherRebate, nEquipLevel = Item:CheckHasOtherRebate(pEquip,tbTransferItem);
	local pRegionEquip,bHasTransferItem = Item:GetRegionEquip(tbTransferItem);
	bHasTransferItem = bHasTransferItem or 0;
	local nMoney = Item:CalcTransferCost(pEquip, pRegionEquip, bHasTransferItem, nOtherRebate);
	--强化传承优惠100%折扣
	if bHasTransferItem == 1 and ((nTransferDiscount  == 1 and nOtherRebate == 0) or (nOtherRebate == 1 and nEquipLevel <= self.nDisCount and pEquip.nLevel <= self.nDisCount))  then
		nMoney = 0;
	end
	if nMoney >= 0 then
		if (me.CostBindMoney(nMoney, Player.emKBINDMONEY_COST_TRANSFER) ~= 1) then
			if (me.nCashMoney + me.GetBindMoney() < nMoney) then
				me.Msg("你身上的银两不足，不能进行转移！","系统");
				return 0;
			else
				local nBindMoney = me.GetBindMoney();
				me.CostBindMoney(nBindMoney, Player.emKBINDMONEY_COST_TRANSFER);
				me.CostMoney(nMoney - nBindMoney, Player.emKPAY_ENHANCE_TRANSFER);
				KStatLog.ModifyAdd("bindjxb", "[消耗]强化转移", "总量", nBindMoney);
				KStatLog.ModifyAdd("jxb", "[消耗]强化转移", "总量", nMoney - nBindMoney);			
			end
		else
			KStatLog.ModifyAdd("bindjxb", "[消耗]强化转移", "总量", nMoney);
		end
	elseif nMoney < 0 then
		me.AddBindMoney(math.abs(nMoney), Player.emKBINDMONEY_ADD_EQUIP_TRANSFER);
		KStatLog.ModifyAdd("bindjxb", "[产出]强化转移", "总量", math.abs(nMoney));
	end
	local nRegionValue = Item:CalcEnhanceValue(pRegionEquip) or 0;
	local nDropXuanjingValue = Item:CalcDropXuanjingValue(tbTransferItem);	
	
	--记录扣除的玄晶和传承符信息，用于写LOG
	local tbDelItemInfo = {};
		
	if nDropXuanjingValue > 0 then
		for _, tbItem in pairs(tbTransferItem) do
				if tbItem.szClass == ENHITEM_CLASS then
					local szItemName = tbItem.szName;
					tbDelItemInfo[szItemName] = tbDelItemInfo[szItemName] or 0;
					
					if me.DelItem(tbItem, Player.emKLOSEITEM_VALUE_TRANSFER_DEL) ~= 1 then -- 扣除玄晶失败！
						Dbg:WriteLog("EhanceTransfer", "角色名:"..me.szName, "帐号:"..me.szAccount, "扣除玄晶失败", unpack(tbItem));
						return 0;
					end
					
					tbDelItemInfo[szItemName] = tbDelItemInfo[szItemName] + 1;
				end 
		end
	end
	-- 扣道具
	if bHasTransferItem == 1 and (nOtherRebate == 0 or (nOtherRebate == 1 and nEquipLevel <= self.nDisCount and pEquip.nLevel <= self.nDisCount)) then
		for _, tbItem in pairs(tbTransferItem) do
			if tbItem.szClass ==  Item.ENHANCE_TRANSFER then
				local szItemName = tbItem.szName;
				tbDelItemInfo[szItemName] = tbDelItemInfo[szItemName] or 0;
				
				if tbItem.nCount > 1 then
					tbItem.SetCount(tbItem.nCount - 1, Player.emKLOSEITEM_VALUE_TRANSFER_DEL);
				else
					local nRet =  me.DelItem(tbItem, Player.emKLOSEITEM_VALUE_TRANSFER_DEL);
					if nRet ~= 1 then	--扣除失败		
						Dbg:WriteLog("EhanceTransfer", "角色名:"..me.szName, "帐号:"..me.szAccount, "扣除道具失败", unpack(tbItem));
						return 0;
					end
				end
				
				tbDelItemInfo[szItemName] = tbDelItemInfo[szItemName] + 1;
			end
		end
	end
	
	-- 在regenerate之前，记录道具信息，记录LOG
	local szSrcEquipName = pRegionEquip.szName;
	local nSrcEquipOldEnh = pRegionEquip.nEnhTimes;
	local szDestEquipName = pEquip.szName;
	local nDestEquipOldEnh = pEquip.nEnhTimes;	
	local szDelItemLog = "";
	local nIndex = 0;
	for szItemName, nCout in pairs(tbDelItemInfo) do
		local szPrefix = (nIndex == 0) and "" or ",";
		szDelItemLog = szDelItemLog..string.format("%s%d个%s", szPrefix, nCout, szItemName);
		nIndex = nIndex + 1;
	end
		
	
	--客服log------------
	local szPlayerLog = string.format("玩家: %s，尝试将装备{%s_%d}强化转移至装备{%s_%d}，扣除道具成功{%s}",
		me.szName, szSrcEquipName, nSrcEquipOldEnh, szDestEquipName, nDestEquipOldEnh, szDelItemLog);
	--me.PlayerLog(Log.emKITEMLOG_TYPE_USE, szPlayerLog);
	me.ItemLog(pEquip, 0, Log.emKITEMLOG_TYPE_USE, szPlayerLog);
	---------------------
	local nOldEnhTimes = pRegionEquip.nEnhTimes; --新道具的强化
	local nNewEnhTimes = 0;	--原来道具
	local nOldStrengthen = pRegionEquip.nStrengthen; --新道具的改造属性
	local nOldRet = pRegionEquip.Regenerate(
		pRegionEquip.nGenre,
		pRegionEquip.nDetail,
		pRegionEquip.nParticular,
		pRegionEquip.nLevel,
		pRegionEquip.nSeries,
		nNewEnhTimes,			-- 变成未强化状态
		pRegionEquip.nLucky,
		pRegionEquip.GetGenInfo(),
		0,
		pRegionEquip.dwRandSeed,
		0
	);
	pRegionEquip.Bind(1);
	local nSrcEquipNewEnh = pRegionEquip.nEnhTimes;
	
	if nOldRet ~= 1 then
		Dbg:WriteLog("EhanceTransfer", "角色名:"..me.szName, "帐号:"..me.szAccount, "Regenerate道具失败");		
		if nOldEnhTimes < 12 or nTransferDiscount ~= 1 or bHasTransferItem ~= 1 or nOtherRebate == 1 then
			--清除剥离申请状态
			me.SetTask(self.TASK_PEEL_APPLY_GID, self.TASK_PEEL_APPLY_TIME, 0);
			me.RemoveSkillState(1358);
		end
		return 0;
	end
	local nNewRet = pEquip.Regenerate(
		pEquip.nGenre,
		pEquip.nDetail,
		pEquip.nParticular,
		pEquip.nLevel,
		pEquip.nSeries,
		nOldEnhTimes,			--变成新的强化等级
		pEquip.nLucky,
		pEquip.GetGenInfo(),
		0,
		pEquip.dwRandSeed,
		nOldStrengthen
	);
	pEquip.Bind(1);  	-- 强制绑定
	local nDestEquipNewEnh = pEquip.nEnhTimes;
	
	if nNewRet ~= 1 then
		Dbg:WriteLog("EhanceTransfer", "角色名:"..me.szName, "帐号:"..me.szAccount, "Regenerate道具失败");
		if nOldEnhTimes < 12 or nTransferDiscount ~= 1 or bHasTransferItem ~= 1 or nOtherRebate == 1 then	--强12以上有优惠buff切不为初级符
			--清除剥离申请状态
			me.SetTask(self.TASK_PEEL_APPLY_GID, self.TASK_PEEL_APPLY_TIME, 0);
			me.RemoveSkillState(1358);
		end
		return 0;
	end
	if nOldRet == 1 and nNewRet == 1 then
		--加财富
		if bHasTransferItem ~= 1 or ((nOtherRebate ~= 0 or nTransferDiscount ~= 1) and (nOtherRebate ~= 1 or nEquipLevel > self.nDisCount or pEquip.nLevel > self.nDisCount)) then
			PlayerHonor:AddConsumeValue(me, nRegionValue * 0.1, "ehancetransfer");
		end
		--数据埋点
		local szTypeName = Item.EQUIPPOS_NAME[KItem.EquipType2EquipPos(pEquip.nDetail)];
		local szLevel = tostring(pRegionEquip.nLevel);
		local szOldEnhanceLevel = tostring(nOldEnhTimes);
		local szTargetLevel = tostring(pEquip.nLevel);
		StatLog:WriteStatLog("stat_info", "zhuangbei","transfer", me.nId,szTypeName,szLevel,szOldEnhanceLevel,szTargetLevel);
		--公告,大于12的转移公告		
		if nOldEnhTimes >= 12 then
			--清除剥离申请状态			
			if nTransferDiscount ~= 1 or bHasTransferItem ~= 1 or nOtherRebate == 1 then
				me.SetTask(self.TASK_PEEL_APPLY_GID, self.TASK_PEEL_APPLY_TIME, 0);
				me.RemoveSkillState(1358);
			end
			me.SendMsgToFriend("Hảo hữu [" .. me.szName .. "]通过强化转移将" .. szTypeName .. "强化到+" .. szOldEnhanceLevel .. "。");
			Player:SendMsgToKinOrTong(me,"通过强化转移将" .. szTypeName .. "强化到" .. szOldEnhanceLevel .. "。", 0);
		end
		
		--客服log------------
		local szPlayerLog = string.format("玩家: %s，成功将装备{%s_%d}强化转移至装备{%s_%d}，结果：原装备变成{%s_%d}，目的装备变为{%s_%d}",
			me.szName, szSrcEquipName, nSrcEquipOldEnh, szDestEquipName, nDestEquipOldEnh,
			szSrcEquipName, nSrcEquipNewEnh, szDestEquipName, nDestEquipNewEnh);
		--me.PlayerLog(Log.emKITEMLOG_TYPE_USE, szPlayerLog);
		me.ItemLog(pEquip, 0, Log.emKITEMLOG_TYPE_USE, szPlayerLog);
	end
	me.Msg("转移成功！你的装备<color=gold>"..pRegionEquip.szName.."<color>的强化等级成功转移到<color=gold>".. pEquip.szName .."<color>!");
	return 1;
end

--检测是不是青铜武器
function Item:CheckIsQinTongWep(pEquip)
	local tbEquipInfo = {};
	local bIsQinTongWep = 0;
	local tbRefineSetting = Item:GetExternSetting("refine",1);
	for i, tb in pairs(tbRefineSetting.m_tbRefine[13]) do
		if tb.tbProduce[1] == pEquip.nGenre and tb.tbProduce[2] == pEquip.nDetail and tb.tbProduce[3] == pEquip.nParticular and tb.tbProduce[4] == pEquip.nLevel then
			tbEquipInfo.nGenre = tb.tbEquip[1];
			tbEquipInfo.nDetail = tb.tbEquip[2];
			tbEquipInfo.nParticular = tb.tbEquip[3];
			tbEquipInfo.nLevel = tb.tbEquip[4];
			bIsQinTongWep = 1;			
			return bIsQinTongWep, tbEquipInfo;
		end
	end
	return bIsQinTongWep, tbEquipInfo;
end

--青铜武器剥离
function Item:WeaponPeel(pEquip,nParam)	
	local bIsQinTongWep, tbOldEquipInfo = self:CheckIsQinTongWep(pEquip);
	if bIsQinTongWep ~= 1 then
		me.Msg("您放入的装备不是青铜武器。");
		Dialog:SendBlackBoardMsg(me, "您放入的装备不是青铜武器。");
		return 0;
	end
	if me.CountFreeBagCell() < 1  then
		me.Msg("Hành trang không đủ 1 ô trống.");
		Dialog:SendBlackBoardMsg(me, "Hành trang không đủ 1 ô trống.");
		return 0;
	end
	local nAppTime = me.GetTask(self.TASK_PEEL_APPLY_GID, self.TASK_PEEL_APPLY_TIME);
	if nAppTime == 0 then
		me.Msg("您没有申请剥离。");
		Dialog:SendBlackBoardMsg(me, "您没有申请剥离。");
		return 0;
	end
	local nDiffTime = GetTime() - nAppTime;
	if nDiffTime <= self.VALID_PEEL_TIME then
		me.Msg("尚未到可剥离时间，请稍等。");
		Dialog:SendBlackBoardMsg(me, "尚未到可剥离时间，请稍等。");
		return 0;
	-- 过了申请期
	elseif nDiffTime >= self.MAX_PEEL_TIME then
		me.Msg("您的上次剥离申请已经超时，请重新申请。");
		Dialog:SendBlackBoardMsg(me, "您的上次剥离申请已经超时，请重新申请。");
		me.SetTask(self.TASK_PEEL_APPLY_GID, self.TASK_PEEL_APPLY_TIME, 0);
		return 0;
	end
	if jbreturn:GetMonLimit(me) > 0 then
		me.Msg("您的账号有异常");
		Dialog:SendBlackBoardMsg(me, "您的账号有异常");		
		return 0;	
	end
	local szOldName = pEquip.szName;
	local nOldRet = pEquip.Regenerate(
			tbOldEquipInfo.nGenre,
			tbOldEquipInfo.nDetail,
			tbOldEquipInfo.nParticular,
			tbOldEquipInfo.nLevel,
			pEquip.nSeries,
			pEquip.nEnhTimes,			-- 变成未强化状态
			pEquip.nLucky,
			pEquip.GetGenInfo(),
			0,
			pEquip.dwRandSeed,
			0
		);	
	pEquip.Bind(1);
	--青铜武器转移时拆出5个绑定和氏玉	
	me.AddStackItem(22, 1, 81, 1, {bForceBind = 1}, 5);
	me.SetTask(self.TASK_PEEL_APPLY_GID, self.TASK_PEEL_APPLY_TIME, 0);
	me.RemoveSkillState(1358);
	Dbg:WriteLog("EhanceTransfer", "角色名:"..me.szName, "帐号:"..me.szAccount, "剥离青铜武器获得和氏玉5个");
	--me.PlayerLog(Log.emKITEMLOG_TYPE_USE, "剥离青铜武器获得和氏玉5个");
	me.ItemLog(pEquip, 0, Log.emKITEMLOG_TYPE_USE, "剥离青铜武器获得和氏玉5个");
	me.Msg("剥离成功！你的装备<color=gold>"..szOldName.."<color>剥离成<color=gold>".. pEquip.szName .."<color>，同时获得5个绑定和氏玉!");
	return 1;
end

--检测放入的东西
function Item:CheckHasOtherRebate(pEquip, tbTransferItem)
	local nEquipLevel = -1;	--转移的装备等级
	local nRet = 0;
	self.bHasOtherTransferItem = 0;
	for _,pItem in pairs(tbTransferItem) do
		if pItem and pItem.szClass == Item.ENHANCE_TRANSFER then
			local nParam = tonumber(pItem.GetExtParam(1));
			if nParam > 0 then
				self.bHasOtherTransferItem = nParam;
				nRet = 1;
			end
		end
		if pItem and pItem.IsEquip() == 1 then
			nEquipLevel = pItem.nLevel;
		end
	end
	return nRet, nEquipLevel;
end
