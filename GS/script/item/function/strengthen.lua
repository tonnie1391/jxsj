------------------------------------------------------------------------------------------
-- 文件说明：装备改造
-- 作者：fenghewen
-- 时间：2009.10.29
------------------------------------------------------------------------------------------

-- initialize

-- 改造符的ClassName定义
Item.STRENGTHEN_RECIPE_WEAPON = "strengthen_recipe_weapon";	-- 武器改造符
Item.STRENGTHEN_RECIPE_JEWELRY = "strengthen_recipe_jewwlry";	-- 首饰改造符
Item.STRENGTHEN_RECIPE_ARMOR = "strengthen_recipe_armor";	-- 防具改造符
-- 改造符与对应的物品类型
Item.STRENGTHEN_RECIPE_CALSS =  {	-- 武器
									[Item.STRENGTHEN_RECIPE_WEAPON] = {Item.EQUIP_MELEE_WEAPON, 
																	  Item.EQUIP_RANGE_WEAPON},
									-- 防具									  
									[Item.STRENGTHEN_RECIPE_ARMOR] = {Item.EQUIP_ARMOR,
																		Item.EQUIP_BOOTS,
																		Item.EQUIP_BELT,
																		Item.EQUIP_HELM,
																		Item.EQUIP_CUFF},
									-- 饰品							
									[Item.STRENGTHEN_RECIPE_JEWELRY] = {Item.EQUIP_RING,
																	   Item.EQUIP_NECKLACE,
																	   Item.EQUIP_AMULET,
																	   Item.EQUIP_PENDANT}
								};
-- 改造材料道具类型：玄晶								
Item.STRENGTHEN_STUFF_CLASS = "xuanjing";	
-- 改造限定的强化等级
Item.STRENGTHEN_TIMES = {15}
------------------------------------------------------------------------------------------

-- 改造
function Item:Strengthen(pEquip, tbStrItem, nMoneyType, nParam)
	local nRes, szMsg = self:CheckStrengthenEquip(pEquip);
	if nRes ~= 1 then
		me.Msg(szMsg);
		return 0;
	end
	
	local nRes, szMsg, nStuffVal, bBind, tbStuffItem, pStrengthenRecipe = self:CalStrengthenStuff(pEquip, tbStrItem);
	if nRes ~= 1 then
		me.Msg(szMsg);
		return 0;
	end
	
	-- 越南版特殊需求，可以自动解绑的装备不能用绑定的玄晶和银两改造
	if pEquip.GetLockIntervale() > 0 and (bBind == 1 or nMoneyType == Item.BIND_MONEY) then
		me.Msg("该装备只能不绑玄和不绑银来改造！");
		return 0;
	end

	local nProb, nMoney, nTrueProb = Item:CalcProb(pEquip, nStuffVal, Item.ENHANCE_MODE_STRENGTHEN);
	-- 改造度低于100%时，不可改造
	-- 改造度超过120%不可改造
	if nProb < 100 then
		me.Msg("改造度未满100%，还不能改造");
		return 0;
	elseif (nTrueProb > 120) then
		me.Msg("您放入的玄晶过多，请勿浪费。");
		return 0;
	elseif (nMoneyType == Item.BIND_MONEY and me.CostBindMoney(nMoney, Player.emKBINDMONEY_COST_STRENGTHEN) ~= 1) then
		me.Msg("你身上绑定银两不足，不能改造！");
		return 0;
	elseif (nMoneyType == Item.NORMAL_MONEY and me.CostMoney(nMoney, Player.emKPAY_STRENGTHEN) ~= 1) then	-- 扣除金钱
		me.Msg("你身上银两不足，不能改造！");
		return 0;
	elseif (nMoneyType ~= Item.NORMAL_MONEY)and (nMoneyType ~= Item.BIND_MONEY) then
		return 0;
	end
	
	if nMoneyType == Item.NORMAL_MONEY then
		KStatLog.ModifyAdd("jxb", "[消耗]装备改造", "总量", nMoney);
	end
	if nMoneyType == Item.BIND_MONEY then
		KStatLog.ModifyAdd("bindjxb", "[消耗]装备改造", "总量", nMoney);
	end
		
	local szSucc = "改造度:"..nProb.."%%";
	Dbg:WriteLog("Strengthen", "角色名:"..me.szName, "帐号:"..me.szAccount, "原料:"..szMsg, szSucc, "客户端计算改造度:"..nParam.."%%");
	
	if nParam > nProb and self.__OPEN_ENHANCE_LIMIT == 1 then
		me.Msg("您的客户端显示的改造度有误，为避免造成不必要的损失，禁止您的改造操作，请尽快与客服联系。");
		return 0;
	end
	
	local nIbValue = 0;
	-- 扣玄晶
	for i, pItem in ipairs(tbStuffItem) do
		if pItem.nBuyPrice > 0 then -- Ib玄晶或者从Ib玄晶合成而来
			nIbValue = nIbValue + pItem.nBuyPrice;
		end
		
		if me.DelItem(pItem, Player.emKLOSEITEM_STRENGTHEN) ~= 1 then
			Dbg:WriteLog("Strengthen", "角色名:"..me.szName, "帐号:"..me.szAccount, "扣除玄晶失败", unpack(pItem));
			return 0;
		end
	end
	
	nIbValue = nIbValue + pStrengthenRecipe.nBuyPrice;
	-- 扣改造符
	if me.DelItem(pStrengthenRecipe) ~= 1 then
		Dbg:WriteLog("Strengthen", "角色名:"..me.szName, "帐号:"..me.szAccount, "扣改造符失败", unpack(pStrengthenRecipe));
		return 0;
	end
	
	if pEquip.IsBind() ~= 1 then
		pEquip.nBuyPrice = pEquip.nBuyPrice + nIbValue;
	else
		Spreader:AddConsume(nIbValue, 1, "[装备改造]玄晶");
	end

	local nRet = pEquip.Regenerate(
		pEquip.nGenre,
		pEquip.nDetail,
		pEquip.nParticular,
		pEquip.nLevel,
		pEquip.nSeries,
		pEquip.nEnhTimes,
		pEquip.nLucky,
		pEquip.GetGenInfo(),
		0,
		pEquip.dwRandSeed,
		1
	);
	
	if nRet == 0 then

		Dbg:WriteLog("Strengthen", "角色名:"..me.szName, "帐号:"..me.szAccount, "装备改造失败", unpack(pEquip));
		return 0;
	end

	if nMoneyType == Item.BIND_MONEY then
		bBind = 1;
	end
	-- 如果是已绑定装备则不需要再绑, 如果装备和材料都不绑也不需要再绑
	local bNeedBind = 1;
	if (bBind == pEquip.IsBind()) then
		bNeedBind = 0;			
	end
	
	if bNeedBind == 1 then
		pEquip.Bind(1);					-- 强制绑定装备
		Spreader:OnItemBound(pEquip);
	end

	Dbg:WriteLog("Strengthen", "角色名:"..me.szName, "帐号:"..me.szAccount, "改造成功")
	
	-- 频道提示：好友、帮会/家族（和强化一致，优先家族）
	local szTypeName = Item.EQUIPPOS_NAME[KItem.EquipType2EquipPos(pEquip.nDetail)];
	me.SendMsgToFriend(string.format("Hảo hữu [%s]将+%d的%s改造成功。", me.szName, pEquip.nEnhTimes, szTypeName));
	Player:SendMsgToKinOrTong(me, string.format("将+%d的%s改造成功。", pEquip.nEnhTimes, szTypeName), 0);

	return 1;
end

-- 检测改造装备是否合法
function Item:CheckStrengthenEquip(pEquip)
	if (not pEquip) or (pEquip.IsEquip() ~= 1) or (pEquip.IsWhite() == 1) then
		return 0, "该物品不能强化！";			-- 非装备或白色装备不能改造
	end
	if pEquip.nStrengthen ~= 0 then
		return 0,"该物品已经改造过了!";
	end
	if (pEquip.nDetail < Item.MIN_COMMON_EQUIP) or (pEquip.nDetail > Item.MAX_COMMON_EQUIP) then
		return 0, "参与五行激活的装备才能强化！";			-- 非可强化类型装备不能改造
	end
	

	-- 检测装备的改造属性，看看是否能改造
	local tbMASS = pEquip.GetStrMASS();		-- 获得道具强化激活魔法属性
	local nCount = 0;					-- 改造属性计数
	for _, tbMA in ipairs(tbMASS) do
		if (tbMA.szName ~= "") and (tbMA.bVisible == 1) then
			nCount = nCount + 1;
		end
	end
	if nCount == 0 then
		return 0, "该装备没有改造属性，不能改造。";
	end
	
	-- 检测装备的强化的次数是否能改造
	local bCanStrengthen = 0;
	for i = 1, #self.STRENGTHEN_TIMES do
		if pEquip.nEnhTimes == self.STRENGTHEN_TIMES[i] then
			bCanStrengthen = 1;
		end
	end	
	if bCanStrengthen == 0 then
		return 0, "该强化等级的装备不能改造";
	end
	return 1;
end

-- 检测改造符是否合法
function Item:CheckRecipe(pItem, pEquip)
	if not pItem or not pEquip or not self.STRENGTHEN_RECIPE_CALSS[pItem.szClass] then
		return 0;
	end
	for i, nDetail in ipairs(self.STRENGTHEN_RECIPE_CALSS[pItem.szClass]) do
		if pEquip.nDetail == nDetail then
			if pEquip.nEnhTimes == pItem.nLevel then
				return 1;
			end
		end
	end

	return 0;
end	

-- 计算改造材料
function Item:CalStrengthenStuff(pEquip, tbStrItem)
	local pStrengthenRecipe = nil;
	local szMsg = "";
	local nStuffVal = 0;
	local tbStuff = {};
	local bBind  = 0;
	local tbCalcuate  = {};
	
	for _, pItem in ipairs(tbStrItem) do
		
		if self:CheckRecipe(pItem, pEquip) == 1 then
			if pStrengthenRecipe then
				return 0, "放入了两个或以上的改造符";
			end
			pStrengthenRecipe = pItem;
		elseif pItem.szClass == self.STRENGTHEN_STUFF_CLASS then
			nStuffVal = nStuffVal + pItem.nValue; -- 计算所有玄晶的价值总和
			table.insert(tbStuff, pItem);
			if (pItem.IsBind() == 1) then
				bBind = 1;		-- 如果有绑定的玄晶则要绑定装备
			end
			local szName = pItem.szName;
			if not tbCalcuate[szName] then
				tbCalcuate[szName] = 0;
			end
			tbCalcuate[szName] = tbCalcuate[szName] + 1;
		end
	end		
	
	if not pStrengthenRecipe then
		return 0, "没有改造符";
	end
	
	if nStuffVal == 0 then
		return 0, "没有玄晶";
	end
	
	local szMsg = "";
	if MODULE_GAMESERVER then
		for szName, nCount in pairs(tbCalcuate) do
			szMsg = szMsg..szName..nCount.."个  ";
		end
	end
	
	return 1, szMsg, nStuffVal, bBind, tbStuff, pStrengthenRecipe;
end

-- 计算改造价值和花销，客户端与服务端共用
function Item:CalcProb(pEquip, nStuffVal, nModeType, nValueDiscount)
	local tbSetting = Item:GetExternSetting("value", pEquip.nVersion);
	if (not tbSetting) then
		return 0;
	end
	
	local nSrcValue = 0;
	if nModeType == Item.ENHANCE_MODE_STRENGTHEN then
		nSrcValue = tbSetting.m_tbStrengthenValue[pEquip.nEnhTimes];
		if (not nSrcValue) then
			return 0;
		end
	elseif nModeType == Item.ENHANCE_MODE_ENHANCE then
		nSrcValue = tbSetting.m_tbEnhanceValue[pEquip.nEnhTimes + 1];
		if (not nSrcValue) then
			return 0;
		end
		
		if pEquip.nStrengthen == 1 then
			nSrcValue = nSrcValue - tbSetting.m_tbStrengthenValue[pEquip.nEnhTimes];
		end
		
		if nValueDiscount then
			nSrcValue = math.floor(nSrcValue * nValueDiscount / 100);
		end		
	else
		return 0;
	end
	
	local nTypeRate = (tbSetting.m_tbEquipTypeRate[pEquip.nDetail] or 100) / 100;
	local nCostValue = nSrcValue * nTypeRate;
	local nMoney	 = nCostValue * 0.1;
	nCostValue		 = nCostValue - nMoney;
	nMoney 			 = math.floor(nMoney * self:GetJbPrice()); 	-- 金币交易所兑换系数
	
	
	-- *******活动折扣区*******************
		--houxuan: 081110 装备强化费用调整统一接口
	local nFreeCount, tbExecute, nExpMultipe = SpecialEvent.ExtendAward:DoCheck("EnhanceEquip", me);
	nMoney = math.ceil(nMoney * nExpMultipe);
		-- 合服优惠，合服7天后过期
	if GetTime() < KGblTask.SCGetDbTaskInt(DBTASK_COZONE_TIME) + 7 * 24 * 60 * 60 and nExpMultipe == 1 then
		nMoney = math.floor(nMoney * 8 / 10);
	end
	-- *************************************

	local nProb = math.floor(nStuffVal / nCostValue * 100);
	-- 真实成功率
	local nTrueProb = nProb;
	if (nProb > 100) then
		nProb = 100;
	end
	return	nProb, nMoney, nTrueProb;
end
