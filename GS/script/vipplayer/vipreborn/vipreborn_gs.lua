-------------------------------------------------------
-- 文件名　：vipreborn_gs.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2011-02-23 12:24:42
-- 文件描述：
-------------------------------------------------------

Require("\\script\\vipplayer\\VipReborn\\VipReborn_def.lua");

if not MODULE_GAMESERVER then
	return 0;
end

local tbVipReborn = VipPlayer.VipReborn;

-- 检查资格
function tbVipReborn:CheckQualification(pPlayer)
	
	-- 暂时只对内部ip可见
	if jbreturn:IsPermitIp(pPlayer) ~= 1 then
		return 0;
	end
	
	-- 旧版数据处理
	local tbOldVip = VipPlayer.VipTransfer;
	if pPlayer.GetTask(tbOldVip.TASK_GROUP_ID, tbOldVip.TASK_BIND_MONEY) > 0 or pPlayer.GetTask(tbOldVip.TASK_GROUP_ID, tbOldVip.TASK_MONEY) > 0 then
		return 4;
	end

	for nIndex, nTaskId in pairs(tbOldVip.TASK_REPUTE) do
		local nCamp, nClass, nLevel, nRepute = tbOldVip:LoadReputeTask(pPlayer, nTaskId);
		if nLevel + nRepute > 1 then
			return 4;
		end
	end
	
	-- 申请资格
	if self:GetTransferRate(pPlayer) > 0 then
		return 1;
	end
	
	-- 领奖资格
	if self.tbGlobalBuffer[pPlayer.szAccount] then
		return 2;
	end
	
	-- 剩余价值量
	if pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_BIND_VALUE) > 0 or pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_NOBIND_VALUE) > 0 then
		return 3;
	end
	
	return 0;
end

-- 计算声望索引
function tbVipReborn:GetReputeValue(nCamp, nClass, nLevel)
	for nIndex, tbInfo in pairs(self.tbReputeValue) do
		if tbInfo.tbRepute[1] == nCamp and tbInfo.tbRepute[2] == nClass then
			return tbInfo.tbLevel[nLevel] or 0;
		end
	end
	return 0;
end

-- 检测玄晶
function tbVipReborn:CheckXuanjing(pItem)
	for _, tbItemId in pairs(self.tbXuanjing) do
		if pItem.nGenre == tbItemId[1] and pItem.nDetail == tbItemId[2] and pItem.nParticular == tbItemId[3] and pItem.nLevel == tbItemId[4] then
			return 1;
		end
	end
	return 0;
end

-- 检测内部账号
function tbVipReborn:CheckSepcailAccount(pPlayer)
	if jbreturn:IsPermitIp(pPlayer) ~= 1 then
		return 0;
	end
	if jbreturn:GetMonLimit(pPlayer) <= 0 then
		return 0;
	end
	return 1;
end

-- 用资格来存1-100的比率，默认100
function tbVipReborn:GetTransferRate(pPlayer)
	return math.min(pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_QUALIFICATION), 80);
end
	
-- 检查是否能获得奖励
function tbVipReborn:CheckFinishReborn(pPlayer)
	
	-- 检查数据
	if not self.tbGlobalBuffer[pPlayer.szAccount] then
		Dialog:Say("你没有转服奖励可以领取。");
		return 0;
	end
	
	-- 检查等级
	if self:CheckSepcailAccount(pPlayer) ~= 1 and pPlayer.nLevel > 60 then
		Dialog:Say("你的等级太高，无法领取奖励。");
		return 0;
	end

	-- 检查网关
	if GetGatewayName() ~= self.tbGlobalBuffer[pPlayer.szAccount].szNewGateway then
		return 0;
	end
	
	-- 密码锁
	if pPlayer.IsAccountLock() ~= 0 then
		Dialog:Say("你的账号处于锁定状态，无法领取奖励。");
		return 0;
	end
	
	return 1;
end

-- 计算装备的强化价值量
function tbVipReborn:CaculateEquipValue(pEquip)

	if not pEquip then
		return 0;
	end

	local nBaseValue = 0;
    local nEnhValue = 0;

	local tbSetting = Item:GetExternSetting("value", pEquip.nVersion);
	if tbSetting then

		local nTypeRate = ((tbSetting.m_tbEquipTypeRate[pEquip.nDetail] or 100) / 100) or 1;
		local nEnhTimes = pEquip.nEnhTimes;

		repeat
			nEnhValue = nEnhValue + (tbSetting.m_tbEnhanceValue[nEnhTimes] or 0) * nTypeRate;
			nEnhTimes = nEnhTimes - 1;
		until (nEnhTimes <= 0);
			
		if pEquip.nStrengthen == 1 then
			nEnhValue = nEnhValue + (tbSetting.m_tbStrengthenValue[pEquip.nEnhTimes] or 0) * nTypeRate;
		end
	end

    nBaseValue = pEquip.nValue - nEnhValue;
    return math.floor(nEnhValue / 20000);
end

-- 计算装备价值量
function tbVipReborn:CalculateValue(pPlayer)

	local tbValue = {nBindValue = 0, nNobindValue = 0};
	local nJbPrice = math.max(100, JbExchange.GetPrvAvgPrice) * 100;
	
	-------------------------------------------------------
	-- 绑定价值量
	-------------------------------------------------------
	
	-- 装备的价值量
	for i = 0, 9 do
		local pEquip = pPlayer.GetItem(Item.ROOM_EQUIP, i);
		if pEquip then
			tbValue.nBindValue = tbValue.nBindValue + self:CaculateEquipValue(pEquip);
			--me.Msg(string.format("%s - %s", pEquip.szName, self:CaculateEquipValue(pEquip)));
		end
		local pEquipEx = pPlayer.GetItem(Item.ROOM_EQUIPEX, i);
		if pEquipEx then
			tbValue.nBindValue = tbValue.nBindValue + self:CaculateEquipValue(pEquipEx);
			--me.Msg(string.format("%s - %s", pEquipEx.szName, self:CaculateEquipValue(pEquipEx)));
		end
	end
	
	-- 背包里的玄和装备
	for i = 0, Item.ROOM_MAINBAG_HEIGHT - 1 do
		for j = 0, Item.ROOM_MAINBAG_WIDTH - 1 do
			local pItem = pPlayer.GetItem(Item.ROOM_MAINBAG, j, i);
			if pItem then
				if self:CheckXuanjing(pItem) == 1 then
					tbValue.nBindValue = tbValue.nBindValue + math.floor(pItem.nValue / 20000);
					--me.Msg(string.format("%s - %s", pItem.szName, math.floor(pItem.nValue / 20000)));
				elseif pItem.IsEquip() == 1 then
					tbValue.nBindValue = tbValue.nBindValue + self:CaculateEquipValue(pItem);
					--me.Msg(string.format("%s - %s", pItem.szName, self:CaculateEquipValue(pItem)));
				end
			end
		end
	end
	
	-- 扩展背包
	for i = Item.ROOM_EXTBAG1, Item.ROOM_EXTBAG3 do
		for j = 0, Item.ROOM_EXTBAG_HEIGHT - 1 do
			for k = 0, Item.ROOM_EXTBAG_WIDTH do
				local pItem = pPlayer.GetItem(i, k, j);
				if pItem then
					if self:CheckXuanjing(pItem) == 1 then
						tbValue.nBindValue = tbValue.nBindValue + math.floor(pItem.nValue / 20000);
						--me.Msg(string.format("%s - %s", pItem.szName, math.floor(pItem.nValue / 20000)));
					elseif pItem.IsEquip() == 1 then
						tbValue.nBindValue = tbValue.nBindValue + self:CaculateEquipValue(pItem);
						--me.Msg(string.format("%s - %s", pItem.szName, self:CaculateEquipValue(pItem)));
					end
				end
			end
		end
	end
	
	-- 五行印
	local pSignet = pPlayer.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_SIGNET);
	if pSignet then
		tbValue.nBindValue = tbValue.nBindValue + math.floor(pSignet.nValue / 20000);
		--me.Msg(string.format("%s - %s", pSignet.szName, math.floor(pSignet.nValue / 20000)));
	end
	
	-- 五行魂石
	local nFind = pPlayer.GetItemCountInBags(18, 1, 205, 1);
	if nFind > 0 then
		tbValue.nBindValue = tbValue.nBindValue + math.floor(nFind * 4 / 100);
		--me.Msg(string.format("%s - %s", "五行魂石", math.floor(nFind * 4 / 100)));
	end
	
	-- 游龙古币
	local nFind2 = pPlayer.GetItemCountInBags(18, 1, 553, 1);
	if nFind2 > 0 then
		tbValue.nBindValue = tbValue.nBindValue + math.floor(nFind2 * 30 / 100);
		--me.Msg(string.format("%s - %s", "游龙古币", math.floor(nFind2 * 30 / 100)));
	end
	
	-- 游龙战书
	local nFind3 = pPlayer.GetItemCountInBags(18, 1, 524, 4);
	if nFind3 > 0 then
		tbValue.nBindValue = tbValue.nBindValue + math.floor(nFind3 * 150 / 100);
		--me.Msg(string.format("%s - %s", "游龙战书", math.floor(nFind3 * 150 / 100)));
	end
	
	-- 等级
	if me.nLevel > 100 then
		tbValue.nBindValue = tbValue.nBindValue + (me.nLevel - 100) ^ 2 * 10;
		--me.Msg(string.format("%s - %s", "等级", (me.nLevel - 100) ^ 2 * 10));
	end
	
	-- 同伴
	local nPartnerValue = me.GetTask(PlayerHonor.TSK_GROUP, PlayerHonor.TSK_ID_PARTNER_VALUE);
	tbValue.nBindValue = tbValue.nBindValue + math.floor(nPartnerValue / 100000);
	--me.Msg(string.format("%s - %s", "同伴", math.floor(nPartnerValue / 100000)));
	
	-- 真元
	local tbFind = pPlayer.FindClassItemOnPlayer("zhenyuan");
	Lib:MergeTable(tbFind, pPlayer.FindClassItem(Item.ROOM_EQUIP, "zhenyuan"));
	if tbFind and Lib:CountTB(tbFind) > 0 then
		for _, tbFind in pairs(tbFind) do
			tbValue.nBindValue = tbValue.nBindValue + math.floor(Item.tbZhenYuan:GetZhenYuanValue(tbFind.pItem) / 500000);
			--me.Msg(string.format("%s - %s", "真元", math.floor(Item.tbZhenYuan:GetZhenYuanValue(tbFind.pItem) / 500000)));
		end
	end
	
	-- 绑金绑银
	tbValue.nBindValue = tbValue.nBindValue + math.floor(pPlayer.nBindCoin / 100);
	tbValue.nBindValue = tbValue.nBindValue + math.floor(pPlayer.GetBindMoney() / nJbPrice);
	--me.Msg(string.format("%s - %s", "绑金", math.floor(pPlayer.nBindCoin / 100)));
	--me.Msg(string.format("%s - %s", "绑银", math.floor(pPlayer.GetBindMoney() / nJbPrice)));
	
	-- 声望
	for nIndex, tbInfo in pairs(self.tbReputeValue) do
		local nCamp = tbInfo.tbRepute[1];
		local nClass = tbInfo.tbRepute[2];
		local nLevel = me.GetReputeLevel(nCamp, nClass);
		tbValue.nBindValue = tbValue.nBindValue + self:GetReputeValue(nCamp, nClass, nLevel);
		--me.Msg(string.format("%s - %s", tbInfo.szName, self:GetReputeValue(nCamp, nClass, nLevel)));
	end
	
	-------------------------------------------------------
	-- 非绑价值量
	-------------------------------------------------------
	-- 精活
	tbValue.nNobindValue = tbValue.nNobindValue + math.floor((pPlayer.dwCurMKP + pPlayer.dwCurGTP) / 1250);
	--me.Msg(string.format("%s - %s", "精活", math.floor((pPlayer.dwCurMKP + pPlayer.dwCurGTP) / 1250)));
	
	-- 银两
	tbValue.nNobindValue = tbValue.nNobindValue + math.floor(pPlayer.nCashMoney / nJbPrice);
	--me.Msg(string.format("%s - %s", "银两", math.floor(pPlayer.nCashMoney / nJbPrice)));
	
	-- 自定义转服比率
	local nRate = self:GetTransferRate(pPlayer);
	tbValue.nBindValue = math.floor(tbValue.nBindValue * nRate / 100);
	--me.Msg(string.format("%s - %s", "绑定价值", tbValue.nBindValue));
	--me.Msg(string.format("%s - %s", "非绑价值", tbValue.nNobindValue));
	
	-- 未领取
	tbValue.nBindValue = tbValue.nBindValue + me.GetTask(self.TASK_GROUP_ID, self.TASK_BIND_VALUE);
	tbValue.nNobindValue = tbValue.nNobindValue + me.GetTask(self.TASK_GROUP_ID, self.TASK_NOBIND_VALUE);
	
	return tbValue;
end

-- load buffer
function tbVipReborn:LoadBuffer_GS()
	local tbLoadBuffer = GetGblIntBuf(self.nBufferIndex, 0);
	if tbLoadBuffer and type(tbLoadBuffer) == "table" then
		self.tbGlobalBuffer = tbLoadBuffer;
	end
end

-- clear buffer
function tbVipReborn:ClearBuffer_GS()
	self.tbGlobalBuffer = {};
end

-- gs启动事件
function tbVipReborn:StartEvent_GS()
	self:LoadBuffer_GS();
end

-- 每月事件
function tbVipReborn:MonthEvent_GS()
	me.SetTask(self.TASK_GROUP_ID, self.TASK_MONTH_VALUE, 0);
end

PlayerSchemeEvent:RegisterGlobalMonthEvent({VipPlayer.VipReborn.MonthEvent_GS, VipPlayer.VipReborn});

-- 注册启动事件
ServerEvent:RegisterServerStartFunc(VipPlayer.VipReborn.StartEvent_GS, VipPlayer.VipReborn);
