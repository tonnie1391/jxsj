-------------------------------------------------------
-- 文件名　：viptransfer_gs.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-11-19 11:18:32
-- 文件描述：
-------------------------------------------------------

Require("\\script\\vipplayer\\viptransfer\\viptransfer_def.lua");

if (not MODULE_GAMESERVER) then
	return 0;
end

local tbVipTransfer = VipPlayer.VipTransfer;

-- 同步转出数据
function tbVipTransfer:SyncBufferOut_GS(szPlayerName, tbInfo)
	self.tbGlobalBuffer.tbApplyOut[szPlayerName] = tbInfo;
end

-- 同步转入数据
function tbVipTransfer:SyncBufferIn_GS(szAccount, tbInfo)
	self.tbGlobalBuffer.tbApplyIn[szAccount] = tbInfo;
end

-- 增加转出数据
function tbVipTransfer:AddApplyOut_GS(szPlayerName, szOrgGateway, szDstGateway, tbInfo)
	GCExcute({"VipPlayer.VipTransfer:AddApplyOut_GC", szPlayerName, szOrgGateway, szDstGateway, tbInfo});
end

-- 增加转入数据
function tbVipTransfer:AddApplyIn_GS(szAccount, tbInfo)
	GCExcute({"VipPlayer.VipTransfer:AddApplyIn_GC", szAccount, tbInfo});
end

-- 清除全局数据表
function tbVipTransfer:ClearBuffer_GS()
	self.tbGlobalBuffer = {tbApplyOut = {}, tbApplyIn = {}};
end

-- 检查资格
function tbVipTransfer:CheckQualification(pPlayer)
	
	-- 暂时只对内部ip可见
	if jbreturn:IsPermitIp(pPlayer) ~= 1 then
		return 0;
	end
	
	-- 申请资格
	if self:GetTransferRate(pPlayer) > 0 then
		return 1;
	end
	
	-- 领奖资格
	if self.tbGlobalBuffer.tbApplyIn[pPlayer.szAccount] then
		return 2;
	end
	
	-- 绑银和银两
	if me.GetTask(self.TASK_GROUP_ID, self.TASK_BIND_MONEY) > 0 or me.GetTask(self.TASK_GROUP_ID, self.TASK_MONEY) > 0 then
		return 3;
	end
	
	-- 补领声望资格
	for nIndex, nTaskId in pairs(self.TASK_REPUTE) do
		local nCamp, nClass, nLevel, nRepute = self:LoadReputeTask(pPlayer, nTaskId);
		if nLevel + nRepute > 1 then
			return 3;
		end
	end
	
	return 0;
end

-- 用资格来存1-100的比率，默认100
function tbVipTransfer:GetTransferRate(pPlayer)
	return pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_QUALIFICATION);
end
	
-- 检查是否能获得奖励
function tbVipTransfer:CheckGetAward(pPlayer)
	
	-- 检查数据
	if not self.tbGlobalBuffer.tbApplyIn[pPlayer.szAccount] then
		Dialog:Say("你没有转服奖励可以领取。");
		return 0;
	end
	
	-- 检查等级
	if pPlayer.nLevel > 60 then
		Dialog:Say("你的等级太高，无法领取奖励。");
		return 0;
	end

	-- 检查网关
	if GetGatewayName() ~= self.tbGlobalBuffer.tbApplyIn[pPlayer.szAccount].szNewGateway then
		return 0;
	end
	
	-- 密码锁
	if pPlayer.IsAccountLock() ~= 0 then
		Dialog:Say("你的账号处于锁定状态，无法领取奖励。");
		return 0;
	end
	
	return 1;
end

--计算装备的强化价值量
function tbVipTransfer:CaculateEquipValue(pEquip)

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
    return math.floor(nEnhValue / 10000);
end

-- 计算装备价值量
function tbVipTransfer:CalculateValue(pPlayer)

	local tbValue =
	{
		-- 绑定价值
		tbBindValue =
		{
			tbEquip =
			{
				[Item.EQUIPPOS_HEAD]		= {0,0},	-- 头
				[Item.EQUIPPOS_BODY]		= {0,0},    -- 衣服
				[Item.EQUIPPOS_BELT]		= {0,0},    -- 腰带
				[Item.EQUIPPOS_WEAPON]		= {0,0},    -- 武器
				[Item.EQUIPPOS_FOOT]		= {0,0},    -- 鞋子
				[Item.EQUIPPOS_CUFF]		= {0,0},    -- 护腕
				[Item.EQUIPPOS_AMULET]		= {0,0},    -- 护身
				[Item.EQUIPPOS_RING]		= {0,0},    -- 戒指
				[Item.EQUIPPOS_NECKLACE]	= {0,0},    -- 项链
				[Item.EQUIPPOS_PENDANT]		= {0,0},    -- 腰坠
			},
			nXuanjing = 0,		-- 玄晶
			nBindMoney = 0,		-- 绑银
			nBindCoin = 0,		-- 绑金
			nSignet = 0,		-- 五行印
		},
		-- 不绑定价值
		tbNoBindValue =
		{
			nMoney = 0,			-- 银两
			nMKP = 0,			-- 精力
			nGTP = 0,			-- 活力
		},
		tbRepute = {},			-- 保留声望
		nBindValue = 0,			-- 绑定价值量
		nNoBindValue = 0,		-- 不绑价值量
	};

	-- 装备的价值量
	for i = 0, 9 do
		local pEquip = pPlayer.GetItem(Item.ROOM_EQUIP, i);
		if pEquip then
			local nEnhValue = self:CaculateEquipValue(pEquip);
			tbValue.tbBindValue.tbEquip[i][1] = nEnhValue;
			tbValue.nBindValue = tbValue.nBindValue + nEnhValue;
		end
		local pEquipEx = pPlayer.GetItem(Item.ROOM_EQUIPEX, i);
		if pEquipEx then
			local nEnhValue = self:CaculateEquipValue(pEquipEx);
			tbValue.tbBindValue.tbEquip[i][2] = nEnhValue;
			tbValue.nBindValue = tbValue.nBindValue + nEnhValue;
		end
	end
	
	-- 背包里的玄和装备
	for i = 0, Item.ROOM_MAINBAG_HEIGHT - 1 do
		for j = 0, Item.ROOM_MAINBAG_WIDTH - 1 do
			local pItem = pPlayer.GetItem(Item.ROOM_MAINBAG, j, i);
			if pItem then
				if self:CheckXuanjing(pItem) == 1 then
					tbValue.tbBindValue.nXuanjing =  tbValue.tbBindValue.nXuanjing + math.floor(pItem.nValue / 10000);
					tbValue.nBindValue = tbValue.nBindValue + math.floor(pItem.nValue / 10000);
				elseif pItem.IsEquip() == 1 then
					local nEnhValue = self:CaculateEquipValue(pItem);
					tbValue.nBindValue = tbValue.nBindValue + nEnhValue;
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
						tbValue.tbBindValue.nXuanjing =  tbValue.tbBindValue.nXuanjing + math.floor(pItem.nValue / 10000);
						tbValue.nBindValue = tbValue.nBindValue + math.floor(pItem.nValue / 10000);
					elseif pItem.IsEquip() == 1 then
						local nEnhValue = self:CaculateEquipValue(pItem);
						tbValue.nBindValue = tbValue.nBindValue + nEnhValue;
					end
				end
			end
		end
	end
	
	-- 五行印
	local pSignet = pPlayer.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_SIGNET);
	if pSignet then
		tbValue.tbBindValue.nSignet = math.floor(pSignet.nValue / 10000);
		tbValue.nBindValue = tbValue.nBindValue + math.floor(pSignet.nValue / 10000);
	end
	
	-- 魂石
	local nFind = pPlayer.GetItemCountInBags(18, 1, 205, 1);
	if nFind > 0 then
		tbValue.nBindValue = tbValue.nBindValue + math.floor(nFind * 8 / 100);
	end

	-- 精活
	tbValue.tbNoBindValue.nMKP = pPlayer.dwCurMKP;
	tbValue.tbNoBindValue.nGTP = pPlayer.dwCurGTP;
	tbValue.nNoBindValue = tbValue.nNoBindValue + math.floor((pPlayer.dwCurMKP + pPlayer.dwCurGTP) / 1250);
		
	-- 声望
	for _, tbRow in pairs(self.tbRepute) do
		local nCamp = tbRow[1];
		local nClass = tbRow[2];
		local nLevel = pPlayer.GetReputeLevel(nCamp, nClass);
		local nRepute = pPlayer.GetReputeValue(nCamp, nClass);
		
		-- 祈福声望特殊处理
		if nCamp == 5 and nClass == 4 and nLevel == 5 then
			nRepute = -1;
		end
		
		if nRepute + nLevel > 1 then
			table.insert(tbValue.tbRepute, {nCamp, nClass, nLevel, nRepute});
		end
	end
	
	-- 同伴
	local nPartnerValue = me.GetTask(PlayerHonor.TSK_GROUP, PlayerHonor.TSK_ID_PARTNER_VALUE);
	tbValue.nBindValue = tbValue.nBindValue + math.floor(nPartnerValue / 50000);
	
	-- 等级
	if me.nLevel > 100 then
		local nLevelValue = (me.nLevel - 100) ^ 2 * 10;
		tbValue.nBindValue = tbValue.nBindValue + nLevelValue;
	end
	
	-- add new rule
	tbValue.nBindValue = math.floor(tbValue.nBindValue * 0.5);
	
	-- 金币价格
	local nJbPrice = math.max(100, JbExchange.GetPrvAvgPrice) * 100;
	
	-- 银两
	tbValue.tbNoBindValue.nMoney = pPlayer.nCashMoney;
	tbValue.nNoBindValue = tbValue.nNoBindValue + math.floor(pPlayer.nCashMoney / nJbPrice);
	
	-- 绑金绑银
	tbValue.tbBindValue.nBindCoin = pPlayer.nBindCoin;
	tbValue.nBindValue = tbValue.nBindValue + math.floor(pPlayer.nBindCoin / 100);
	
	tbValue.tbBindValue.nBindMoney = pPlayer.GetBindMoney();
	tbValue.nBindValue = tbValue.nBindValue + math.floor(pPlayer.GetBindMoney() / nJbPrice);
	
	-- 真元
	local tbFind = pPlayer.FindClassItemOnPlayer("zhenyuan");
	Lib:MergeTable(tbFind, pPlayer.FindClassItem(Item.ROOM_EQUIP, "zhenyuan"));
	
	if tbFind and Lib:CountTB(tbFind) > 0 then
		for _, tbFind in pairs(tbFind) do
			tbValue.nBindValue = tbValue.nBindValue + math.floor(Item.tbZhenYuan:GetZhenYuanValue(tbFind.pItem) / 300000);
		end
	end

	-- 自定义转服比率
	local nRate = self:GetTransferRate(pPlayer);
	tbValue.nBindValue = math.floor(tbValue.nBindValue * nRate / 100);
	
	return tbValue;
end

-- 32 bits(0-31)：[ nCamp:4(0-15) | nClass:3(0-7) nLevel:3(0-7) | nRepute:22(0-4194303) ]

-- 存声望任务变量
function tbVipTransfer:SetReputeTask(pPlayer, nTaskId, nCamp, nClass, nLevel, nRepute)
	
	local nTask = 0;
	
	nTask = Lib:SetBits(nTask, nCamp, 0, 3);
	nTask = Lib:SetBits(nTask, nClass, 4, 6);
	nTask = Lib:SetBits(nTask, nLevel, 7, 9);
	nTask = Lib:SetBits(nTask, nRepute, 10, 31);

	pPlayer.SetTask(self.TASK_GROUP_ID, nTaskId, nTask);
end

-- 读声望任务变量
function tbVipTransfer:LoadReputeTask(pPlayer, nTaskId)
	
	local nTask = pPlayer.GetTask(self.TASK_GROUP_ID, nTaskId);
	
	local nCamp = Lib:LoadBits(nTask, 0, 3);
	local nClass = Lib:LoadBits(nTask, 4, 6);
	local nLevel = Lib:LoadBits(nTask, 7, 9);
	local nRepute = Lib:LoadBits(nTask, 10, 31);
	
	return nCamp, nClass, nLevel, nRepute;
end
