
-- 装备，强化功能脚本

------------------------------------------------------------------------------------------
-- initialize
local nScriptVersion = Item.IVER_nEquipEnhance;

local ENHITEM_CLASS 		= "xuanjing";			-- 强化道具类型：玄晶
local ENHANCE_DISCOUNT		= "enhancediscount";	--强化道具类型：强化优惠符
local PEEL_ITEM = { nGenre = Item.SCRIPTITEM, nDetail = 1, nParticular = 1 };	-- 玄晶

Item.c2sFun = Item.c2sFun or {};

Item.ERROR_FLAG_ENHANCE_NOT_SAME_EHN_TIMES = 1;		-- 不是将要强化的等级
Item.ERROR_FLAG_ENHANCE_NOT_SAME_EHN_EQUIP = 2;		-- 装备和强化优惠符不是同一类

------------------------------------------------------------------------------------------
-- private

local function CheckEnhItem(pEquip, tbEnhItem, nMoneyType)		-- 服务端检查装备和玄晶的合法性

	if (not pEquip) or (pEquip.IsEquip() ~= 1) or (pEquip.IsWhite() == 1) then
		return 0;			-- 非装备或白色装备不能强化
	end

	if (pEquip.nDetail < Item.MIN_COMMON_EQUIP) or (pEquip.nDetail > Item.MAX_COMMON_EQUIP) then
		return 0;			-- 非可强化类型装备不能强化
	end

	if (pEquip.nEnhTimes >= Item:CalcMaxEnhanceTimes(pEquip)) then
		return 0;			-- 已强化到最高级则不能强化
	end

	if (#tbEnhItem <= 0) then
		return 0;			-- 没有玄晶
	end

	-- 越南版特殊需求，可以自动解绑的装备不能用绑定的玄晶和银两强化
	if pEquip.GetLockIntervale() > 0 and nMoneyType == Item.BIND_MONEY then
		return 0;
	end
	local nDiscountItemCount = 0;
	for _, pEnhItem in ipairs(tbEnhItem) do
		if (not pEnhItem) or (pEnhItem.szClass ~= ENHITEM_CLASS and pEnhItem.szClass ~= ENHANCE_DISCOUNT) then
			return 0;		-- 不是玄晶
		end
		
		if pEnhItem.szClass == ENHANCE_DISCOUNT then
			nDiscountItemCount = nDiscountItemCount + 1;			
		end
		
		-- 越南版特殊需求，可以自动解绑的装备不能用绑定的玄晶和银两强化
		if (pEquip.GetLockIntervale() > 0) and pEnhItem.IsBind() == 1 then
			return 0;
		end
	end

	if nDiscountItemCount > 1 then
		return 0;
	end
	return 1;

end

local function CheckPeelItem(pEquip)		-- 服务端检查装备和玄晶的合法性

	if (not pEquip) or (pEquip.IsEquip() ~= 1) or (pEquip.IsWhite() == 1) then
		return 0;			-- 非装备或白色装备不能剥离
	end

	if (pEquip.nDetail < Item.MIN_COMMON_EQUIP) or (pEquip.nDetail > Item.MAX_COMMON_EQUIP) then
		return 0;			-- 非可强化类型装备不能剥离
	end

	if (pEquip.nEnhTimes <= 0) then
		return	0;			-- 未强化过装备不能剥离
	end

	return 1;

end

------------------------------------------------------------------------------------------
-- public

Item.STRENGTHEN_TYPE_DIS =  {
	-- 武器
	[1] = {Item.EQUIP_MELEE_WEAPON, 
			 Item.EQUIP_RANGE_WEAPON},
	-- 防具
	[2] = {Item.EQUIP_ARMOR,
			Item.EQUIP_BOOTS,
			Item.EQUIP_BELT,
			Item.EQUIP_HELM,
			Item.EQUIP_CUFF},
	-- 饰品
	[3] = {Item.EQUIP_RING,
			   Item.EQUIP_NECKLACE,
			   Item.EQUIP_AMULET,
			   Item.EQUIP_PENDANT}
};

-- by zhangjinpin@kingsoft
Item.TASK_PEEL_APPLY_GID = 	2085;	-- 高强化装备剥离申请任务变量
Item.TASK_PEEL_APPLY_TIME = 1;		-- 申请高强化剥离的时间
Item.VALID_PEEL_TIME = 30;	-- 有效的剥离时间
Item.MAX_PEEL_TIME =30 * 60;	-- 完整的申请到消失时间

if EventManager.IVER_bOpenTiFu == 1 then
	Item.VALID_PEEL_TIME = 60;	-- 体服调整为1分钟
end

-- 申请装备剥离
function Item:ApplyPeelHighEquipSure()
	-- SkillId : 1358
	if 1 == me.AddSkillState(1358, 1, 1, self.MAX_PEEL_TIME * Env.GAME_FPS, 1, 0, 1) then
		me.SetTask(self.TASK_PEEL_APPLY_GID, self.TASK_PEEL_APPLY_TIME, GetTime());
		me.Msg("你成功申请了高强化装备剥离。");
	end
end
Item.c2sFun["ApplyPeel"]	= Item.ApplyPeelHighEquipSure;
-- 取消装备剥离
function Item:CancelPeelHighEquipSure()
	me.SetTask(self.TASK_PEEL_APPLY_GID, self.TASK_PEEL_APPLY_TIME, 0);
	-- SkillId : 1358
	me.RemoveSkillState(1358);
	me.Msg("你取消了装备剥离申请。");
end
Item.c2sFun["CancelPeel"]	= Item.CancelPeelHighEquipSure;

-- 判断显示选项
function Item:CheckApplyPeelState()
	
	--取任务标量
	local nTime = me.GetTask(Item.TASK_PEEL_APPLY_GID, Item.TASK_PEEL_APPLY_TIME);

	if nTime == 0 then	-- 显示申请选项
		return 0;
	else
		local nDiffTime = GetTime() - nTime;
		
		-- 出错情况(视为需要重新申请)
		if nDiffTime < 0 then
			return 0;
			
		-- 显示取消选项
		elseif nDiffTime <= Item.MAX_PEEL_TIME then	
			return 1;
			
		-- 显示申请选项
		elseif nDiffTime > Item.MAX_PEEL_TIME then
			return 0;
		end
	end
end

 
function Item:GetJbPrice() 		-- 获取金币汇率
	local nJbPrice = 0;
	if (MODULE_GAMECLIENT) then
		nJbPrice = JbExchange.nAvgPrice;
	elseif (MODULE_GAMESERVER) then
		nJbPrice = JbExchange.GetPrvAvgPrice; -- 获取前一周的汇率
	end
	nJbPrice = math.max(50, nJbPrice);
	nJbPrice = math.min(200, nJbPrice);
	return nJbPrice / 100;
end

function Item:Enhance(pEquip, tbEnhItem, nMoneyType, nParam)	-- 程序接口：服务端执行装备强化
	local nOpen = KGblTask.SCGetDbTaskInt(DBTASK_ENHANCESIXTEEN_OPEN);
	if nOpen == 1 and pEquip.nEnhTimes >= Item.nEnhTimesLimitOpen - 1 then
		me.Msg("强16功能暂不开放。");
		return -1;
	end
	if CheckEnhItem(pEquip, tbEnhItem, nMoneyType) ~= 1 then
		return -1;
	end

	local nIbValue = 0;
	
	-- by zhangjinpin@kingsoft
	local nProb, nMoney, bBind, szLog, nValue, nTrueProb, bHasDisItem, nDisCountErrorFlag = Item:CalcEnhanceProb(pEquip, tbEnhItem, nMoneyType);
	
	-- 强化装备成功率低于10%时，不可强化
	-- 强化装备成功率超过120%，且玄晶价值量大于16796，不可强化
	if nProb < 10 then
		me.Msg("本次强化成功率过低，不可强化。");
		return -1;
	elseif (nTrueProb > 120 and nValue > 16796) then
		me.Msg("您放入的玄晶过多，请勿浪费。");
		return -1;
	elseif (nMoneyType == Item.NORMAL_MONEY and me.CostMoney(nMoney, Player.emKPAY_ENHANCE) ~= 1) then	-- 扣除金钱
		me.Msg("你身上银两不足，不能强化！");
		return -1;
	elseif (nMoneyType == Item.BIND_MONEY and me.CostBindMoney(nMoney, Player.emKBINDMONEY_COST_ENHANCE) ~= 1) then
		me.Msg("你身上绑定银两不足，不能强化！");
		return -1;
	elseif (nMoneyType ~= Item.NORMAL_MONEY)and (nMoneyType ~= Item.BIND_MONEY) then
		return -1;
	elseif (bHasDisItem == 1 and nProb < 100) then
		me.Msg("使用强化优惠符强化需要成功率超过100%才能强化！");
		return -1;
	elseif (nDisCountErrorFlag > 0) then
		local szErrorMsg = "";
		if (nDisCountErrorFlag == self.ERROR_FLAG_ENHANCE_NOT_SAME_EHN_TIMES) then
			szErrorMsg = "你放入的强化符不是当前可以优惠的强化等级！";
		elseif (nDisCountErrorFlag == self.ERROR_FLAG_ENHANCE_NOT_SAME_EHN_EQUIP) then
			szErrorMsg = "你放入的强化符与当前强化的物品类型不一致！";
		end
		me.Msg(szErrorMsg);
		return -1;
	end
	
	if nMoneyType == Item.NORMAL_MONEY then
		--nIbValue = nIbValue + nMoney / Spreader.ExchangeRate_Gold2Jxb;
		KStatLog.ModifyAdd("jxb", "[消耗]装备强化", "总量", nMoney);
	end
	
	if nMoneyType == Item.BIND_MONEY then
		KStatLog.ModifyAdd("bindjxb", "[消耗]装备强化", "总量", nMoney);
	end
	
	local szSucc = "成功率:"..nProb.."%%";
	Dbg:WriteLog("Enhance", "角色名:"..me.szName, "帐号:"..me.szAccount, "原料:"..szLog, szSucc, "客户端计算成功率:"..nParam.."%%");
	
	if nParam > nProb and self.__OPEN_ENHANCE_LIMIT == 1 then
		me.Msg("您的客户端显示的成功率有误，为避免造成不必要的损失，禁止您的强化操作，请尽快与客服联系。");
		return -1;
	end
	
	for i = 1, #tbEnhItem do
		if tbEnhItem[i].nBuyPrice > 0 then -- Ib玄晶或者从Ib玄晶合成而来
			nIbValue = nIbValue + tbEnhItem[i].nBuyPrice;
		end
		
		local szItemName = tbEnhItem[i].szName;
		local nRet = me.DelItem(tbEnhItem[i], Player.emKLOSEITEM_TYPE_ENHANCE);		-- 扣除玄晶
		if nRet ~= 1 then
			Dbg:WriteLog("Enhance", "角色名:"..me.szName, "帐号:"..me.szAccount, "扣除"..szItemName.."失败");
			return 0;
		end
	end

	if pEquip.IsBind() ~= 1 then
		pEquip.nBuyPrice = pEquip.nBuyPrice + nIbValue;
	else
		Spreader:AddConsume(nIbValue, 1, "强化装备玄晶");
	end

	local szTypeName = "";
	local szMsg = "";
	if (pEquip.nEnhTimes >= 11) then
		szTypeName = Item.EQUIPPOS_NAME[KItem.EquipType2EquipPos(pEquip.nDetail)];
		szMsg = "Hảo hữu ["..me.szName.."] với xác suất "..nProb.."% cường hóa "..szTypeName;
	end
	
	--成就,无论成功与否
	Achievement:FinishAchievement(me,412);
	SpecialEvent.ActiveGift:AddCounts(me, 45);		--强化活跃度
	if (MathRandom(100) > nProb) then
		Dbg:WriteLog("Enhance", "角色名:"..me.szName, "帐号:"..me.szAccount, "强化失败");
		if (pEquip.nEnhTimes >= 11) then
			me.SendMsgToFriend(szMsg.." cường hóa +"..pEquip.nEnhTimes + 1 .. " thất bại.");
			Player:SendMsgToKinOrTong(me, " với xác suất "..nProb.."% cường hóa "..szTypeName.." +"..pEquip.nEnhTimes + 1 .. " thất bại.", 0);
		end
		self:FinishEnhanceAchievement(pEquip.nEnhTimes + 1,nProb,0);
		--失败数据埋点
		if pEquip.nEnhTimes >= 4 then
			local szLevel = tostring(pEquip.nLevel);
			local szEnhanceLevel = tostring(pEquip.nEnhTimes + 1);
			local szProb = tostring(nProb);
			local szRet = tostring(0);
			local szType = Item.EQUIPPOS_NAME[KItem.EquipType2EquipPos(pEquip.nDetail)];
			StatLog:WriteStatLog("stat_info", "Zhuangbei","qianghua", me.nId,szType,szLevel,szEnhanceLevel,szProb,szRet);
		end
		return 0;
	end	
	
	local nRet = pEquip.Regenerate(
		pEquip.nGenre,
		pEquip.nDetail,
		pEquip.nParticular,
		pEquip.nLevel,
		pEquip.nSeries,
		pEquip.nEnhTimes + 1,			-- 强化次数加一
		pEquip.nLucky,
		pEquip.GetGenInfo(),
		0,
		pEquip.dwRandSeed,
		0
	);

	if (1 ~= nRet) then
		Dbg:WriteLog("Enhance", "角色名:"..me.szName, "帐号:"..me.szAccount, "Regenerate失败")
		if (pEquip.nEnhTimes >= 11) then
			me.SendMsgToFriend(szMsg.." +"..pEquip.nEnhTimes + 1 .. " thất bại.");
			Player:SendMsgToKinOrTong(me, " đem "..szTypeName.." cường hóa +"..pEquip.nEnhTimes + 1 .. " thất bại.", 0);
			self:FinishEnhanceAchievement(pEquip.nEnhTimes + 1,nProb,0);
			--失败数据埋点
			if pEquip.nEnhTimes >= 4 then
				local szLevel = tostring(pEquip.nLevel);
				local szEnhanceLevel = tostring(pEquip.nEnhTimes + 1);
				local szProb = tostring(nProb);
				local szRet = tostring(0);
				local szType = Item.EQUIPPOS_NAME[KItem.EquipType2EquipPos(pEquip.nDetail)];
				StatLog:WriteStatLog("stat_info", "Zhuangbei","qianghua", me.nId,szType,szLevel,szEnhanceLevel,szProb,szRet);
			end
		end
		return 0;
	end
	self:FinishEnhanceAchievement(pEquip.nEnhTimes,nProb,1);
	if (pEquip.nEnhTimes >= 12) then
		me.SendMsgToFriend("Hảo hữu ["..me.szName.."] với xác suất "..nProb.."% cường hóa "..szTypeName.." +"..pEquip.nEnhTimes..".");
		Player:SendMsgToKinOrTong(me, " với xác suất "..nProb.."% cường hóa "..szTypeName.." +"..pEquip.nEnhTimes..".", 0);
	end
	--新手强化任务
	if me.GetTask(1025,46) ~=1 and pEquip.nEnhTimes >= 1 then
		me.SetTask(1025,46,1);
	end
	Dbg:WriteLog("Enhance", "角色名:"..me.szName, "帐号:"..me.szAccount, "强化成功")
	if bBind == 1 then
		pEquip.Bind(1);					-- 强制绑定装备
		Spreader:OnItemBound(pEquip);
	end
	
	--强化+14及以上,向客户端推送SNS通知
	-- if (pEquip.nEnhTimes >= 14) then
		-- local szPopupMessage = string.format("祝贺您成功将<color=yellow>%s<color>强化到<color=yellow>+%d<color>！\n把这个好消息<color=yellow>截图<color>分享给朋友们吧！", szTypeName, pEquip.nEnhTimes);
		-- local szTweet = "#剑侠世界# 我的"..szTypeName..nProb.."%概率强"..pEquip.nEnhTimes.."成功啦！呵呵……";
		-- Sns:NotifyClientNewTweet(me, szPopupMessage, szTweet);
	-- end
	
	--强化数据埋点
	if pEquip.nEnhTimes - 1 >= 4 then
		local szLevel = tostring(pEquip.nLevel);
		local szEnhanceLevel = tostring(pEquip.nEnhTimes);
		local szProb = tostring(nProb);
		local szRet = tostring(1);
		local szType = Item.EQUIPPOS_NAME[KItem.EquipType2EquipPos(pEquip.nDetail)];
		StatLog:WriteStatLog("stat_info", "Zhuangbei","qianghua", me.nId,szType,szLevel,szEnhanceLevel,szProb,szRet);
	end
	return 1;
end


function Item:Peel(pEquip, nParam)		-- 程序接口：服务端执行玄晶剥离
	if Atlantis:CheckIsSuper(pEquip) == 1 then
		return -1;
	end
	if CheckPeelItem(pEquip) ~= 1 then
		return -1;
	end

	local tbPeelItem, nMoney, bBind, nPeelValue = Item:CalcPeelItem(pEquip);
	
	if (not tbPeelItem) then
		return -1;
	end

	-- 判断是否是空表,因为该表有洞,不能使用#tbPeelItem这种方式来判断.
	local nCheckNum = 0;
	for nX, nY in pairs(tbPeelItem) do
		nCheckNum = nCheckNum + 1;
	end
	if nCheckNum == 0 then
		me.Msg("装备价值量过低,不能拆分出玄晶!");
		return -1;
	end
	
	if me.GetMaxCarryMoney() < me.GetBindMoney() + nMoney then
		me.Msg("你身上带的绑定银两已经超过上限。");
		return -1;
	end

	local tbItemBag = {};	-- 判断空间是否够
	for nLevel, nNum in pairs(tbPeelItem) do
		local tbItem =
		{
			nGenre		= PEEL_ITEM.nGenre,
			nDetail 	= PEEL_ITEM.nDetail,
			nParticular	= PEEL_ITEM.nParticular,
			nLevel		= nLevel,
			nSeries		= Env.SERIES_NONE,
			bBind		= 1,
			nCount		= nNum,
		};
		table.insert(tbItemBag, tbItem);
	end

	if me.CanAddItemIntoBag(unpack(tbItemBag)) ~= 1 then
		me.Msg("您的背包放不下剥离后的物品，请整理后再进行剥离!");
		return -1;
	end
	
	-- 装备剥离延迟：by zhangjinpin@kingsoft
	local nCurrEnhTimes = pEquip.nEnhTimes;
	
	-- 强化12以上的装备 
	if nCurrEnhTimes >= 12 then
		
		local nTime = me.GetTask(self.TASK_PEEL_APPLY_GID, self.TASK_PEEL_APPLY_TIME);
		
		-- 没有申请过剥离
		if nTime <= 0 then
			me.Msg("请先到冶炼大师处申请高强化装备剥离");
			Dialog:SendBlackBoardMsg(me, "请先到冶炼大师处申请高强化装备剥离。");
			return -1;
		
		-- 申请过则判断时间是否在允许段内(申请3小时-剥离3小时)
		else
			-- 取申请时间差
			local nDiffTime = GetTime() - nTime;
			-- 出错的情况
			if nDiffTime <= 0 then 
				return -1;
				
			-- 已经申请还不能剥离
			elseif nDiffTime <= self.VALID_PEEL_TIME then
				me.Msg("尚未到可剥离时间，请稍等。");
				Dialog:SendBlackBoardMsg(me, "尚未到可剥离时间，请稍等。");
				return -1;
				
			-- 过了申请期
			elseif nDiffTime >= self.MAX_PEEL_TIME then
				me.Msg("您的上次剥离申请已经超时，请重新申请。");
				Dialog:SendBlackBoardMsg(me, "您的上次剥离申请已经超时，请重新申请。");
				me.SetTask(self.TASK_PEEL_APPLY_GID, self.TASK_PEEL_APPLY_TIME, 0);
				return -1;
			end
		end
	end
	
	if pEquip.szOrgName == "Ngọc Bội Du Long Giác" or pEquip.szOrgName == "Hương Nang Du Long Giác"  then
		Dialog:SendBlackBoardMsg(me, "Không thể tách trang bị này.");
		return -1;
	end
	
	local nLastEnhTimes = pEquip.nEnhTimes;
	local nRet = pEquip.Regenerate(
		pEquip.nGenre,
		pEquip.nDetail,
		pEquip.nParticular,
		pEquip.nLevel,
		pEquip.nSeries,
		0,			-- 变成未强化状态
		pEquip.nLucky,
		pEquip.GetGenInfo(),
		0,
		pEquip.dwRandSeed,
		0
	);

	if (1 ~= nRet) then
		return 0;
	end

	if bBind == 1 then
		pEquip.Bind(1);					-- 强制绑定装备
	end

	for nLevel, nNum in pairs(tbPeelItem) do
		for i = 1, nNum do
			local pItem = me.AddItemEx(PEEL_ITEM.nGenre, PEEL_ITEM.nDetail, PEEL_ITEM.nParticular, nLevel, {bForceBind = 1}, 
				Player.emKITEMLOG_TYPE_UNENHANCE);	-- 获得玄晶
		end
	end
	
	--print ("返还钱"..nMoney)

	-- 返还钱
	--me.Earn(nMoney);
	me.AddBindMoney(nMoney, Player.emKBINDMONEY_ADD_PEEL);
	KStatLog.ModifyAdd("bindjxb", "[产出]装备剥离", "总量", nMoney);
	-- 记录强化价值量的10%
	PlayerHonor:AddConsumeValue(me, math.floor(nPeelValue * 10 / 100), "peel");
	
	-- 清除剥离申请状态：by zhangjinpin@kingsoft
	if nCurrEnhTimes >= 12 then
		me.SetTask(self.TASK_PEEL_APPLY_GID, self.TASK_PEEL_APPLY_TIME, 0);
		me.RemoveSkillState(1358);
	end
	
	--剥离数据埋点
	if nLastEnhTimes >= 12 and nRet == 1 then
		local szTypeName = Item.EQUIPPOS_NAME[KItem.EquipType2EquipPos(pEquip.nDetail)];
		local szLevel = tostring(pEquip.nLevel);
		local szEnhanceLevel = tostring(nLastEnhTimes);
		StatLog:WriteStatLog("stat_info", "Zhuangbei","boli", me.nId,szTypeName,szLevel,szEnhanceLevel);
	end
	
	return 1;
end

function Item:CalcPeelItem(pEquip) 		-- 计算玄晶剥离，客户端与服务端共用

	if not pEquip then
		return 0;
	end
	
	local tbSetting = Item:GetExternSetting("value", pEquip.nVersion);
	if (not tbSetting) then
		return;
	end

	local bBind = 0;
	if pEquip.IsBind() == 1 then
		bBind = 1;
	end

	local nEnhTimes = pEquip.nEnhTimes;
	local nPeelValue = 0;

	--这部分是强化的价值量
	repeat
		local nEnhValue = tbSetting.m_tbEnhanceValue[nEnhTimes] or 0;
		nPeelValue = nPeelValue + nEnhValue;
		nEnhTimes = nEnhTimes - 1;
	until (nEnhTimes <= 0);

	if (nPeelValue <= 0) then
		return;
	end
	
	--再加上改造的价值量（如果有改造的话）
	--改造不需要叠加价值量，所以只算一次就可以了
	if pEquip.nStrengthen == 1 then
		nPeelValue = nPeelValue + tbSetting.m_tbStrengthenValue[pEquip.nEnhTimes];
	end
	
	local nTypeRate = (tbSetting.m_tbEquipTypeRate[pEquip.nDetail] or 100) / 100;
	nPeelValue      = nPeelValue * nTypeRate;
	
	-- 计算返还的钱
	local nEnhLevel = pEquip.nEnhTimes;
	local nMoney = 0;
	if nEnhLevel >= 12 and nEnhLevel <= 13 then
		nMoney = math.floor(nPeelValue * self.PEEL_RESTORE_RATE_12);
	elseif nEnhLevel >= 14 and nEnhLevel <= 16 then
		nMoney = math.floor(nPeelValue * self.PEEL_RESTORE_RATE_14);
	end

	local nPeels = math.floor(nPeelValue * 0.8);
	local tbPeelItem = {};

	tbPeelItem = Item:ValueToItem(nPeels, 4);
	
	--print ("计算返还钱"..nMoney)
	return tbPeelItem, nMoney, bBind, nPeelValue;
end



-- 价值转换成不同等级的玄晶
-- 因为拆解高级玄晶与其它的价值量转换操作有些细微的差别，第三个参数用来表明是拆玄还是其它操作
function Item:ValueToItem(nValue, nProductNum, bBreakUpXuan)
	
	local tbItemValue = {};
	local tbItem = {};
	bBreakUpXuan = bBreakUpXuan or 0;	-- 默认为其它操作
	
	for nLevel = 1, 12 do
		local tbBaseProp = KItem.GetItemBaseProp(PEEL_ITEM.nGenre, PEEL_ITEM.nDetail, PEEL_ITEM.nParticular, nLevel);
		if tbBaseProp then
		   tbItemValue[nLevel] = tbBaseProp.nValue;
		end
	end
	
	for nCount = 1, nProductNum do				--最多精确计算到nProductNum种等级的玄晶
		for nLevel = 12, 1, -1 do				--对1～12种等级的玄晶进行计算
			if tbItemValue[nLevel] and (nValue / tbItemValue[nLevel]) >= 1 then
				local nNum = math.floor(nValue / tbItemValue[nLevel])
				-- 当是拆解玄晶的时候，10玄11玄12玄都可以拆分，不可以自动降级
				-- 玄晶拆解结果：n玄 ==> 3*(n-1)玄+2*(n-2)玄+2*(n-4)玄
				-- 当是其它操作方式的时候，10玄不能自动降级成低玄，11玄12玄要自动降级
				
				-- TODO: 这个逻辑条件不好，要改！
				if nNum > 1 or (nLevel < 11 and bBreakUpXuan == 0) then	 -- 10级以上的玄晶都可拆分
					tbItem[nLevel] = nNum;
					nValue = math.mod(nValue, tbItemValue[nLevel]);
					break;
				end
			end
		end
		if ((nValue / tbItemValue[1]) < 1) or (nValue == 0) then
			break;
		end
	end

	return tbItem;
end


function Item:ValueToItemAndMoney(nValue)
	local tbItemValue = {};
	local tbItem = {};
	
	for nLevel = 1, 12 do
		local tbBaseProp = KItem.GetItemBaseProp(PEEL_ITEM.nGenre, PEEL_ITEM.nDetail, PEEL_ITEM.nParticular, nLevel);
		if tbBaseProp then
		   tbItemValue[nLevel] = tbBaseProp.nValue;
		end
	end
	
	for nLevel = 12, 1, -1 do				--对1～12种等级的玄晶进行计算
		if (nValue / tbItemValue[nLevel]) >= 1 then
			tbItem[nLevel] = math.floor(nValue / tbItemValue[nLevel]);
			nValue = math.mod(nValue, tbItemValue[nLevel]);
			return tbItem, nLevel, nValue; 
		end
	end	
	return tbItem, 0, nValue;
end


function Item:CalcEnhanceProb(pEquip, tbEnhItem, nMoneyType)	-- 计算强化成功率，客户端与服务端共用
  	local tbSetting = Item:GetExternSetting("value", pEquip.nVersion);
	if (not tbSetting) then
		return	0;
	end
	local nEnhItemVal = 0;
	local bBind       = 0;
	local tbCalcuate  = {};
	local nType = 0;
	local nDisCount = 100;
	local nEnhTimesLimit = -1;
	local bHasDisItem = 0;
	for _, pEnhItem in ipairs(tbEnhItem) do
		if pEnhItem.szClass == ENHITEM_CLASS then
			nEnhItemVal = nEnhItemVal + pEnhItem.nValue;
			if (pEnhItem.IsBind() == 1) then
				bBind = 1;		-- 如果有绑定的玄晶则要绑定装备
			end
			local szName = pEnhItem.szName
			if not tbCalcuate[szName] then
				tbCalcuate[szName] = 0;
			end
			tbCalcuate[szName] = tbCalcuate[szName] + 1;
		elseif pEnhItem.szClass == ENHANCE_DISCOUNT then
			nDisCount = tonumber(pEnhItem.GetExtParam(1));
			nType = tonumber(pEnhItem.GetExtParam(2));
			nEnhTimesLimit = tonumber(pEnhItem.GetExtParam(3));
			bHasDisItem = 1;
		end
	end		-- 计算所有玄晶的价值总和
	
	--符合条件的优惠符扩大价值量总和
	local nValueDiscount = 100;
	local nDisCountErrorFlag = 0;
	if bHasDisItem == 1 then
		if (pEquip.nEnhTimes + 1 == nEnhTimesLimit and self:CheckItemType(pEquip, nType) == 1) then
			nValueDiscount = nDisCount;
		else
			if (self:CheckItemType(pEquip, nType) ~= 1) then
				nDisCountErrorFlag = self.ERROR_FLAG_ENHANCE_NOT_SAME_EHN_EQUIP;
			elseif (pEquip.nEnhTimes + 1 ~= nEnhTimesLimit) then
				nDisCountErrorFlag = self.ERROR_FLAG_ENHANCE_NOT_SAME_EHN_TIMES;
			end
		end
	end
	
	local szLog = ""
	if MODULE_GAMESERVER then
		for szName, nCount in pairs(tbCalcuate) do
			szLog = szLog..szName..nCount.."个  ";
		end
	end
	
	local nProb, nMoney, nTrueProb = Item:CalcProb(pEquip, nEnhItemVal, Item.ENHANCE_MODE_ENHANCE, nValueDiscount);
	if not nMoney then
		return	0;
	end
	
	if nMoneyType == Item.BIND_MONEY then
		bBind = 1;
	end
	--有强化优惠符
	if bHasDisItem == 1 then
		bBind = 1;
	end
	if (bBind == 1) and (pEquip.IsBind() == 1) then
		bBind = 0;			-- 如果是已绑定装备则不需要再绑
	end
	
	-- 增加2个返回值：by zhangjinpin@kingsoft
	return	nProb, nMoney, bBind, szLog, nEnhItemVal, nTrueProb, bHasDisItem, nDisCountErrorFlag;
end

function Item:CalcMaxEnhanceTimes(pEquip)	-- 计算一个可强化装备能强化的次数(最大强化等级)
	if (not pEquip) then
		return 0;
	end
	local nLevel = pEquip.nLevel;
	local nRefineLevel = pEquip.nRefineLevel
	
	if pEquip.IsExEquip() == 1 then
		nRefineLevel = pEquip.GetEquipExValue(Item.ITEM_TASKVAL_EX_SUBID_ExRefLevel);
	end	
	
	if nScriptVersion == 1 then
		if (nLevel <= 3) then
			return 4;					-- 1~3级可强化4次
		elseif (nLevel <= 6) then
			return 8;					-- 4~6级可强化8次
		elseif (nLevel < 9) then		
			return 12;					-- 7~9级可强化12次
		elseif (nLevel > 9) and (nRefineLevel >= 1) then-- 炼化1级的才能强16
			return 16;		
		else
			return 14;		
		end
	else
		if (nLevel <= 3) then
			return 4;					-- 1~3级可强化4次
		elseif (nLevel <= 6) then
			return 8;					-- 4~6级可强化8次
		elseif (nLevel < 9) then		
			return 12;					-- 7~9级可强化12次
		elseif (nLevel == 9) then
			return 14
		else
			return 16;					-- 10级可强化16次
		end
	end
end

function Item:CheckItemType(pEquip, nType)
	if not self.STRENGTHEN_TYPE_DIS[nType] then
		return 0;
	end
	for _, nDetail in ipairs(self.STRENGTHEN_TYPE_DIS[nType]) do
		if nDetail == pEquip.nDetail then
			return 1;
		end
	end
	return 0;
end
-- 玄晶拆解
-- pItem必须是玄晶
-- nParam没有使用
function Item:BreakupXuanjing(pItem, nParam)
	local pPlayer = me;
	local NEEDLEVEL_MIN	= 10;	-- 至少要10级的玄晶才能拆
	local NEEDLEVEL_MAX	= 12;	-- 12级以上的玄晶不能拆（目前玄晶等级最高12级）
	
	local tbLogItem = {}
	if not pItem then
		pPlayer.Msg("没有找到您要拆解的玄晶！")
		return 0;
	end
	
	if pItem.szClass ~= Item.STRENGTHEN_STUFF_CLASS or
			pItem.nLevel < NEEDLEVEL_MIN or
			pItem.nLevel > NEEDLEVEL_MAX or
			pItem.IsBind() ~= 1 then
	
	   	pPlayer.Msg("只能放10级至12级的绑定玄晶！");
	   	return 0;
	else
		if not tbLogItem[pItem.nLevel] then 
			tbLogItem[pItem.nLevel] = 0;
		end
		tbLogItem[pItem.nLevel] = tbLogItem[pItem.nLevel] + 1;
	end
	
	local tbBreakUpItem = Item:ValueToItem(pItem.nValue, 3, 1);	-- 最后一个参数是标志位，表示是拆玄
	local nNum = 0;
	for nItemLevel, nItemNum in pairs(tbBreakUpItem) do
		nNum = nNum + nItemNum;
	end
	
	if pPlayer.CountFreeBagCell() < nNum then
		pPlayer.Msg(string.format("Hành trang không đủ ，您需要%s个空间格子。", nNum));
		return 0;
	end
	
	-- 删除物品
	local nTimeType, nTime = pItem.GetTimeOut();
	if nTimeType and nTimeType == 0 and nTime > 0 then
		Dbg:WriteLog("breakupxuanjing",  pPlayer.szName, "扣除物品:", pItem.szName, "时限为："..os.date("%Y/%m/%d/%H/%M/00", nTime));
	elseif nTimeType and nTimeType == 1 and nTime > 0 then
		Dbg:WriteLog("breakupxuanjing",  pPlayer.szName, "扣除物品:", pItem.szName, "时限还有："..Lib:TimeDesc(nTime));
	else
		Dbg:WriteLog("breakupxuanjing",  pPlayer.szName, "扣除物品:", pItem.szName);
	end
	
	if pPlayer.DelItem(pItem, Player.emKLOSEITEM_BREAKUP) ~= 1 then
		Dbg:WriteLog("breakupxuanjing",  pPlayer.szName, "扣除物品失败, 要扣除的物品为:", pItem.szName);
		return 0;
	end
	
	-- 添加物品
	local szLogMsg = "["..pPlayer.szName.."]获得了："; 
	for nItemLevel, nItemNum in pairs(tbBreakUpItem) do
		for i = 1, nItemNum do
			local pItem = pPlayer.AddItemEx(Item.SCRIPTITEM, 1, 114, nItemLevel, nil, Player.emKITEMLOG_TYPE_BREAKUP);
			if nTimeType and nTime and nTime ~= 0 then
				if nTimeType == 0 then
					pPlayer.SetItemTimeout(pItem, os.date("%Y/%m/%d/%H/%M/00", nTime), 1);
				elseif nTimeType == 1 then
					pPlayer.SetItemTimeout(pItem, math.ceil(nTime / 60), 0);
				end
				pItem.Sync();
			end
		end
		szLogMsg = szLogMsg..nItemLevel.."级玄晶"..nItemNum.."个 ";
	end
	
	if nTimeType and nTimeType == 0 and nTime > 0 then
		szLogMsg = szLogMsg.."时限为："..os.date("%Y/%m/%d/%H/%M/00", nTime);
	elseif nTimeType and nTimeType == 1 and nTime > 0 then
		szLogMsg = szLogMsg.."时限还有："..Lib:TimeDesc(nTime);
	end
	Dbg:WriteLog("breakupxuanjing", szLogMsg);
	
	return 1;
end

-- 印鉴重铸
-- tbItem只能包含一个道具
-- nMoneyType 和 nParam 都没有用到
function Item:YinjianRecast(pTarget, tbItem, nMoneyType, nParam)
	if not pTarget or not tbItem then
		me.Msg("请放入印鉴！");
		return 0;
	end
	
	if #tbItem > 1 then
		me.Msg("您放入了多余的物品！");
		return 0;
	end
	
	local pHight = pTarget;
	local pLow = tbItem[1];
	if not pHight or not pLow then
		me.Msg("你放入的物品不对!");
		return 0;
	end

	if 1 ~= pHight.nGenre or 16 ~= pHight.nDetail or 1 ~= pLow.nGenre or 16 ~= pLow.nDetail then
		me.Msg("只能放入印鉴！");
		return 0;
	end
	
	if pHight.nLevel <= pLow.nLevel then
		me.Msg("印鉴重铸只能用低级的印鉴向高级的印鉴重铸！");
		return 0;
	end
	
	self:ExchangeSignet(pLow, pHight);
	me.Msg("恭喜您重铸印鉴成功!");
	
	return 1;
end

------------------------------------------------------------------------------------------
