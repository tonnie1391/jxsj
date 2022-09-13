-- zhouchenfei
-- 新手礼包改版
-- 2012/8/20 0:02:08

SpecialEvent.PlayerLevelUpGift = {};
local PlayerLevelUpGift = SpecialEvent.PlayerLevelUpGift;

PlayerLevelUpGift.IS_OPEN = 1;
PlayerLevelUpGift.TASK_GROUP_ID = 2122;
PlayerLevelUpGift.TASK_CURRENT_INDEX = 21;
PlayerLevelUpGift.TASK_GET_BAG = 22;
PlayerLevelUpGift.TASK_PAY_AWARD = 23;

PlayerLevelUpGift.INDEX_AWARD_CLASS_FREE = 1;
PlayerLevelUpGift.INDEX_AWARD_CLASS_PAY	= 2;

PlayerLevelUpGift.LIMIT_MONTH_PAY = 50;

PlayerLevelUpGift.tbAwardInfo = {};

-- tbAwardInfo[nIndex]
-- {
--		nLevel,
--		tbAwardClass 
--		{
--			[免费] = 
--			{
--				nNeedFreeBag,
--				nMaxBindMoney,
--				tbAwardList
--				{
--				},
--			},
--			[收费] = 
--			{
--				nNeedFreeBag,
--				nMaxBindMoney,
--				tbAwardList
--				{
--				},
--			},
--		},
-- }

PlayerLevelUpGift.szAwardFile = "\\setting\\player\\playerlevelupgift.txt";

function PlayerLevelUpGift:LoadAwardFile()
	local tbData = Lib:LoadTabFile(self.szAwardFile);
	if (not tbData) then
		print("PlayerLevelUpGift 文件加载失败");
		return 0;
	end
	self.tbAwardInfo = {};
	local tbAwardInfo = {};
	for nId, tbRow in ipairs(tbData) do
		if (nId > 1) then
			local nAwardId = tonumber(tbRow.Id) or 0;
			local nClass = tonumber(tbRow.Class) or 0;
			local nLevel = tonumber(tbRow.Level) or 0;
			local nEffect = tonumber(tbRow.Effect) or 0;
			local szType = tbRow.Type;
			local szParam1 = tbRow.Param1;
			local szParam2 = tbRow.Param2;
			if (nAwardId > 0 and nClass > 0 and nLevel > 0) then
				local tbOneAwards = tbAwardInfo[nAwardId];
				if (not tbOneAwards) then
					tbOneAwards = {};
					tbOneAwards.nLevel = nLevel;
					tbOneAwards.tbAwardClass = {};
					tbAwardInfo[nAwardId] = tbOneAwards;
				end
				
				local tbOneClassAward = tbOneAwards.tbAwardClass[nClass];
				if (not tbOneClassAward) then
					tbOneClassAward = {};
					tbOneClassAward.nNeedFreeBag = 0;
					tbOneClassAward.nMaxBindMoney = 0;
					tbOneClassAward.tbAwardList = {};
					tbOneAwards.tbAwardClass[nClass] = tbOneClassAward;
				end
				
				local tbAward = {};
				tbAward = self:ParseAward(szType, szParam1, szParam2, nEffect);
				tbOneClassAward.nNeedFreeBag	= tbOneClassAward.nNeedFreeBag + self:GetNeedFreeBag(tbAward);
				tbOneClassAward.nMaxBindMoney	= tbOneClassAward.nMaxBindMoney + self:GetMaxBindMoney(tbAward);
				tbOneClassAward.tbAwardList[#tbOneClassAward.tbAwardList + 1] = tbAward;
			end
		end
	end
	self.tbAwardInfo = tbAwardInfo;
end

function PlayerLevelUpGift:ParseAward(szType, szParam1, szParam2, nEffect)
	local tbAward = {};
	if (szType == "Item") then
		tbAward.szType = szType;
		tbAward.tbItemList = {};
		local tbItem = self:ParseParamToItemTab(szParam1);
		tbAward.tbItemList[1] = tbItem;
		tbItem = self:ParseParamToItemTab(szParam2);
		tbAward.tbItemList[2] = tbItem;
		tbAward.nEffect = nEffect;
	elseif (szType == "Title") then
		tbAward.szType = szType;
		local tbItem = self:ParseParamToItemTab(szParam1);
		tbAward.tbTitle = tbItem;
		tbAward.szTitle	= szParam2;
	elseif (szType == "SpeTitle") then
		tbAward.szType = szType;
		local tbItem = self:ParseParamToItemTab(szParam2);
		tbAward.szTitle	= szParam1;
		tbAward.tbTitleParam = tbItem;
	elseif (szType == "CustomEquip" or szType == "BindMoney" or szType == "BindCoin") then
		tbAward.szType = szType;
		tbAward.nValue = tonumber(szParam1);
	end
	return tbAward;
end

function PlayerLevelUpGift:ParseParamToItemTab(szParam)
	local tbParam = Lib:SplitStr(szParam, ",");
	for nId, value in pairs(tbParam) do
		tbParam[nId] = tonumber(value) or 0;
	end
	return tbParam;
end

function PlayerLevelUpGift:GetMaxAwardIndex()
	return #self.tbAwardInfo;
end

function PlayerLevelUpGift:GetNeedFreeBag(tbAward)
	if (tbAward.szType == "Item") then
		local tbItem = tbAward.tbItemList[1];
		if (tbItem) then
			return tbItem[5] or 0;
		end
	elseif (tbAward.szType == "CustomEquip") then
		return 1;
	end
	return 0;
end

function PlayerLevelUpGift:GetMaxBindMoney(tbAward)
	if (tbAward.szType == "BindMoney") then
		return tbAward.nValue;
	end
	return 0;
end

function PlayerLevelUpGift:GetCurrFreeAwardIndex(pPlayer)
	local nIndex =  pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_CURRENT_INDEX);
	if nIndex >= #self.tbAwardInfo + 1 then
		return nil;
	end
	
	if nIndex == 0 then
		nIndex = 1;
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_CURRENT_INDEX, 1);
	end
	return nIndex;
end

function PlayerLevelUpGift:SetCurrFreeAwardIndex(pPlayer, nIndex)
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_CURRENT_INDEX, nIndex);
end

function PlayerLevelUpGift:GetPayAwardFlag(pPlayer, nIndex)
	local nPayParam =  pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_PAY_AWARD);
	local nIsGetPayAward = Lib:LoadBits(nPayParam, nIndex - 1, nIndex - 1);
	return nIsGetPayAward;
end

function PlayerLevelUpGift:SetPayAwardFlag(pPlayer, nIndex, nFlag)
	local nPayParam = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_PAY_AWARD);
	nPayParam = Lib:SetBits(nPayParam, nFlag, nIndex - 1, nIndex - 1);
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_PAY_AWARD, nPayParam);
end

function PlayerLevelUpGift:GetAwardInfo(nIndex, nClass)
	if (not nIndex or nIndex <= 0 or nIndex >= #self.tbAwardInfo + 1) then
		return nil;
	end
	local tbAwardClass = self.tbAwardInfo[nIndex];
	if (not tbAwardClass) then
		return nil;
	end

	if (not nClass) then
		return tbAwardClass.nLevel;
	end
	return tbAwardClass.nLevel, tbAwardClass.tbAwardClass[nClass];
end

function PlayerLevelUpGift:GetAwardInfoPlayerLevel(nIndex)
	return self:GetAwardInfo(nIndex);
end

function PlayerLevelUpGift:GetFreeAwardInfo(nIndex)
	return self:GetAwardInfo(nIndex, self.INDEX_AWARD_CLASS_FREE);
end

function PlayerLevelUpGift:GetPayAwardInfo(nIndex)
	return self:GetAwardInfo(nIndex, self.INDEX_AWARD_CLASS_PAY);
end

function PlayerLevelUpGift:GetCanGetPayAwardIndex(pPlayer)
	for nIndex, tbOneAwardInfo in pairs(self.tbAwardInfo) do
		local tbAwardClass = tbOneAwardInfo.tbAwardClass;
		if (tbAwardClass[self.INDEX_AWARD_CLASS_PAY]) then
			local nFlag = self:GetPayAwardFlag(pPlayer, nIndex);
			if (nFlag == 0) then
				return nIndex;
			end
		end
	end
	return;
end

function PlayerLevelUpGift:IsCanGetAward(pPlayer, nAwardIndex, nClass)
	if (self.INDEX_AWARD_CLASS_FREE == nClass) then
		local nMaxIndex = self:GetMaxAwardIndex();
		local nCurIndex = self:GetCurrFreeAwardIndex(pPlayer);
		if (not nCurIndex or nAwardIndex ~= nCurIndex) then
			return 0, "不是你目前能领取的奖励。";
		end
		return 1;
	elseif (self.INDEX_AWARD_CLASS_PAY == nClass) then
		local nFlag = self:GetPayAwardFlag(pPlayer, nAwardIndex);
		local szMsg = "";
		if (1 == nFlag) then
			nFlag = 0;
			szMsg = "您已经领取过充值新手奖励了。";
		else
			nFlag = 1;
		end
		return nFlag, szMsg;
	end
	return 0, "没有奖励可以领取";
end

function PlayerLevelUpGift:IsGetAllAward(pPlayer)
	local nFlag = 0;
	local nFreeIndex = self:GetCurrFreeAwardIndex(pPlayer);
	if (not nFreeIndex) then
		nFlag = nFlag + 1;
	end
	-- for nIndex, tbOneAwardInfo in pairs(self.tbAwardInfo) do
		-- if (tbOneAwardInfo.tbAwardClass[self.INDEX_AWARD_CLASS_PAY]) then
			-- local nPayFlag = self:GetPayAwardFlag(pPlayer, nIndex);
			-- if (0 == nPayFlag) then
				-- return 0;
			-- end
		-- end
	-- end
	nFlag = nFlag + 1;
	if (2 == nFlag) then
		return 1;
	end
	return 0;
end

SpecialEvent.PlayerLevelUpGift:LoadAwardFile();
