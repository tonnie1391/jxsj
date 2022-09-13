Require("\\script\\mission\\battle\\define.lua");

Battle.DEF_MAX_KILL_DROP_PROP = 10000;
Battle.DEF_BASE_DROPFILE_ADDRESS = "\\setting\\npc\\droprate\\songjinbattle\\";
Battle.DEF_MAX_TOTAL_DROP_BOUNS = 100000000;

function Battle:GetItemList()
	
	local tbsortpos = Lib:LoadTabFile(self.SZITEMFILE);
	local nLineCount = #tbsortpos;
	local tbClassItemList = {};
	
	for nLine=2, nLineCount do
		local nHonorLevel = tonumber(tbsortpos[nLine].HonorLevel);
		local nValue	= tonumber(tbsortpos[nLine].Value) or 0;
		local nProbability = tonumber(tbsortpos[nLine].Probability) or 0;
		local szName = tbsortpos[nLine].Name;
		local szDesc = tbsortpos[nLine].Desc;
		local nBindMoney = tonumber(tbsortpos[nLine].BindMoney) or 0;
		local nMoney = tonumber(tbsortpos[nLine].Money) or 0;
		local nGenre = tonumber(tbsortpos[nLine].Genre) or 0;
		local nDetailType = tonumber(tbsortpos[nLine].DetailType)or 0;
		local nParticularType = tonumber(tbsortpos[nLine].ParticularType) or 0;
		local nLevel = tonumber(tbsortpos[nLine].Level)or 0;
		local nSeries = tonumber(tbsortpos[nLine].Series) or 0;
		local nEnhTimes = tonumber(tbsortpos[nLine].EnhTimes) or 0;
		local nAmount = tonumber(tbsortpos[nLine].Amount) or 1;
		local nExp = tonumber(tbsortpos[nLine].Exp) or 0;
		local nBaseExp = tonumber(tbsortpos[nLine].BaseExp) or 0;
		local nMKP = tonumber(tbsortpos[nLine].MKP) or 0;
		local nGTP = tonumber(tbsortpos[nLine].GTP) or 0;
		local szTimeLimit = tbsortpos[nLine].TimeLimit;
		local nBind = tonumber(tbsortpos[nLine].Bind) or 0;
		local nCoin = tonumber(tbsortpos[nLine].Coin) or 0;
		local nAnnounce = tonumber(tbsortpos[nLine].Announce) or 0;
		local nFriendMsg = tonumber(tbsortpos[nLine].FriendMsg) or 0;
		
		if tbClassItemList[nHonorLevel] == nil then
			tbClassItemList[nHonorLevel] = {};
			tbClassItemList[nHonorLevel].nMaxProp = 0;
		end
		local nPosNo = (#tbClassItemList[nHonorLevel]+ 1);
		tbClassItemList[nHonorLevel][nPosNo] = {};
		tbClassItemList[nHonorLevel][nPosNo].nProbability = nProbability;
		tbClassItemList[nHonorLevel][nPosNo].szName = szName;
		tbClassItemList[nHonorLevel][nPosNo].nBindMoney = nBindMoney;
		tbClassItemList[nHonorLevel][nPosNo].nValue = nValue;
		tbClassItemList[nHonorLevel][nPosNo].nMoney = nMoney;
		tbClassItemList[nHonorLevel][nPosNo].nGenre = nGenre;
		tbClassItemList[nHonorLevel][nPosNo].nDetailType = nDetailType;
		tbClassItemList[nHonorLevel][nPosNo].nParticularType = nParticularType;
		tbClassItemList[nHonorLevel][nPosNo].nLevel = nLevel;
		tbClassItemList[nHonorLevel][nPosNo].nSeries = nSeries;
		tbClassItemList[nHonorLevel][nPosNo].nEnhTimes = nEnhTimes;
		tbClassItemList[nHonorLevel][nPosNo].nAmount = nAmount;
		tbClassItemList[nHonorLevel][nPosNo].nExp = nExp;
		tbClassItemList[nHonorLevel][nPosNo].nBaseExp = nBaseExp;
		tbClassItemList[nHonorLevel][nPosNo].nMKP = nMKP;
		tbClassItemList[nHonorLevel][nPosNo].nGTP = nGTP;
		tbClassItemList[nHonorLevel][nPosNo].szTimeLimit = szTimeLimit;
		tbClassItemList[nHonorLevel][nPosNo].nBind = nBind;
		tbClassItemList[nHonorLevel][nPosNo].nCoin = nCoin;
		tbClassItemList[nHonorLevel][nPosNo].nAnnounce = nAnnounce;
		tbClassItemList[nHonorLevel][nPosNo].nFriendMsg = nFriendMsg;
		tbClassItemList[nHonorLevel][nPosNo].szDesc = szDesc;

		if nProbability >= 0 then
			tbClassItemList[nHonorLevel].nMaxProp =
			tbClassItemList[nHonorLevel].nMaxProp + nProbability;
		end
	end
	return tbClassItemList;
end

function Battle:GetItemDropProp()
	local tbData = Lib:LoadTabFile(self.ITEM_DROP_PROP);
	local tbItemDropProp = {};
	for i, tbRow in pairs(tbData) do
		if (i >= 1) then
			local tbDropProp = {};
			local nHonorLevel = tonumber(tbRow["HONORLEVEL"]);
			for j=5, 11 do
				tbDropProp[j] = tonumber(tbRow["HONOR_" .. j]) or 0;
			end
			if (nHonorLevel) then
				tbItemDropProp[nHonorLevel] = tbDropProp;
			end
		end
	end
	return tbItemDropProp;
end

function Battle:DropItem(pKiller, pDeather, nkind)
	--任务变量检测  每天的和总共的
	local nBagCellNeeded = 0; -- 所需背包空间
	local nMaxProbability = self.tbItemList[nkind].nMaxProp;
	local nRate = Random(nMaxProbability) + 1;
	local nRateSum = 0;
	local nMustGet = 0; -- 100%概率的item个数
	local nNeedMax = 0;
	
	for nitem=1, #self.tbItemList[nkind] do
		nRateSum = nRateSum + self.tbItemList[nkind][nitem].nProbability;
		if nRate <= nRateSum and self.tbItemList[nkind][nitem].nProbability ~= -1 then
			if self:GetItem(pKiller, self.tbItemList[nkind][nitem]) == 0 then
				return 1;
			else
				local tbBattleInfo	= Battle:GetPlayerData(pKiller);
				local tbMission		= tbBattleInfo.tbMission;
				tbMission.nDropItemBouns = tbMission.nDropItemBouns - self.tbItemList[nkind][nitem].nValue;
				local szItemName = self.tbItemList[nkind][nitem].szName;
				if (not tbBattleInfo.tbLogData[szItemName]) then
					tbBattleInfo.tbLogData[szItemName] = 0;
				end
				tbBattleInfo.tbLogData[szItemName] = tbBattleInfo.tbLogData[szItemName] + 1;
				local tbPlayerList	= tbBattleInfo.tbMission:GetPlayerList();
				local szMsg = string.format("<color=yellow>%s<color> hạ <color=yellow>%s<color> nhận được <color=yellow>%s<color>", pKiller.szName, pDeather.szName, szItemName);
				for _, pPlayer in pairs(tbPlayerList) do
					Dialog:SendInfoBoardMsg(pPlayer, szMsg);
				end
				local nKillHonorLevel 	= self:GetHonorLevel(pKiller);
				local nDeathHonorLevel 	= self:GetHonorLevel(pDeather);
				local tbItemInfo = self.tbItemList[nkind][nitem];
				local szGDPL = string.format("%s,%s,%s,%s", tbItemInfo.nGenre, tbItemInfo.nDetailType, tbItemInfo.nParticularType, tbItemInfo.nLevel);
				StatLog:WriteStatLog("stat_info", "battle", "itemdrop", pKiller.nId, string.format("%s,%s,%s,%s,%s", pDeather.szName, nKillHonorLevel, nDeathHonorLevel, szItemName, szGDPL));
				return 1;
			end
		end
	end
	return 1; -- 如果该随机物品表只有概率为0的必得物品.
end

function Battle:GetItem(pPlayer, tbitem)
	--if self:CheckItemFree(pPlayer, 1) == 0 then
	--	return 0;
	--end
	if tbitem.nBindMoney ~= 0 then
		pPlayer.AddBindMoney(tbitem.nBindMoney, Player.emKBINDMONEY_ADD_RANDOMITEM);
	end
	if tbitem.nMoney ~= 0 then
		local nAddMoney = pPlayer.Earn(tbitem.nMoney, Player.emKEARN_RANDOM_ITEM);
	end
	if tbitem.nCoin ~= 0 then
		local nAddCoin = pPlayer.AddBindCoin(tbitem.nCoin, Player.emKBINDCOIN_ADD_RANDOM_ITEM); -- 只会加绑金
	end
	if tbitem.nGenre ~= 0 and tbitem.nDetailType ~= 0 and tbitem.nParticularType ~= 0 then
		local nCount = tonumber(tbitem.nAmount) or 1;
		
		-- 如果背包不足就掉到地上
		if (nCount > pPlayer.CountFreeBagCell()) then
			local nMapId, nPosX, nPosY = pPlayer.GetWorldPos();
			local pItem = KItem.AddItemInPos(nMapId, nPosX, nPosY, tbitem.nGenre, tbitem.nDetailType, tbitem.nParticularType, tbitem.nLevel ,0, 0, 0, nil, nil, 0, 0, pPlayer);
			pItem.SetOnlyBelongPick(1);
			return 1;
		end
		
		-- by zhangjinpin@kingsoft
		local tbItemInfo = {};
		tbItemInfo.nSeries = tbitem.nSeries;
		tbItemInfo.nEnhTimes = tbitem.nEnhTimes;
		
		if tbitem.szTimeLimit and tbitem.szTimeLimit ~= "" then
			tbItemInfo.bTimeOut = 1;
		end
		
		if tbitem.nBind > 0 then
			tbItemInfo.bForceBind = tbitem.nBind;
		end
		
		if tbItemInfo.bTimeOut ~= 1 then
			local nAddCount = pPlayer.AddStackItem(tbitem.nGenre, tbitem.nDetailType, tbitem.nParticularType, tbitem.nLevel, tbItemInfo, nCount);
			if nAddCount > 0 then
			else
				return 0;
			end
		else
			for i= 1, nCount do
				local pItem = pPlayer.AddItemEx(tbitem.nGenre, tbitem.nDetailType, tbitem.nParticularType, tbitem.nLevel, tbItemInfo, Player.emKITEMLOG_TYPE_JOINEVENT);
				if pItem then
					if tbitem.szTimeLimit ~= "" then
						self:LimitTime(pPlayer, tbitem.szTimeLimit, pItem);
					end
				else
					return 0;
				end
			end
		end
		-- end
	end
	
	if tbitem.nExp ~= 0 then
		pPlayer.AddExp(tbitem.nExp)
	end
	
	if tbitem.nBaseExp ~= 0 then
		pPlayer.AddExp(pPlayer.GetBaseAwardExp() * tbitem.nBaseExp);
	end
		
	if tbitem.nMKP ~= 0 then
		pPlayer.ChangeCurMakePoint(tbitem.nMKP)
	end
	
	if tbitem.nGTP ~= 0 then
		pPlayer.ChangeCurGatherPoint(tbitem.nGTP)
	end

	return 1;
end

function Battle:CheckItemFree(pPlayer, nCount)
	if pPlayer.CountFreeBagCell() < nCount then
		local szAnnouce = "Hành trang không đủ "..nCount.." chỗ trống.";
		pPlayer.Msg(szAnnouce);
		return 0;
	end
	return 1;
end

function Battle:LimitTime(pPlayer, szParam, pItem)
	if szParam == nil then
		return 1;
	end
	if not pItem then
		return 0;
	end
	if tonumber(szParam) ~= nil then
		local szDate = os.date("%Y/%m/%d/%H/%M/%S", GetTime() + tonumber(szParam) * 60);
		pPlayer.SetItemTimeout(pItem,szDate);
	else
		local tbStr = Lib:SplitStr(szParam, "/");
		if #tbStr == 3 then
			--当天H:M:S消失
			local nNowDate = GetLocalDate("%Y/%m/%d");
			local szTime = string.format("%s/%s", nNowDate, szParam);
			pPlayer.SetItemTimeout(pItem,szTime);
		elseif #tbStr == 4 then
			--d天后H:M:S消失
			if tonumber(tbStr[1]) > 0 then
				local nNowDate = GetLocalDate("%Y/%m");
				local nHour = tonumber(GetLocalDate("%H"));
				local nMin = tonumber(GetLocalDate("%M"));
				local nSecond = tonumber(GetLocalDate("%S"));
				local nLastTime = 24 * 3600 - (nHour * 3600 + nMin *60 + nSecond);
				local nLastTime2 = tonumber(tbStr[2]) * 3600 + tonumber(tbStr[3]) * 60 + tonumber(tbStr[4]);
				local nLimitTime = nLastTime + ((tonumber(tbStr[1]) - 1)* 24 * 3600) + nLastTime2;
				local szDate = os.date("%Y/%m/%d/%H/%M/%S", GetTime() + nLimitTime);
				pPlayer.SetItemTimeout(pItem,szDate);
			else
				local nNowDate = GetLocalDate("%Y/%m/%d");
				local szTime = string.format("%s/%s/%s/%s", nNowDate, tonumber(tbStr[2]), tonumber(tbStr[3]), tonumber(tbStr[4]));
				pPlayer.SetItemTimeout(pItem,szTime);				
			end			
		elseif #tbStr == 6 then
			--Y-m-d H:M:S后消失
			pPlayer.SetItemTimeout(pItem,szParam);
		end
	end
	return 0;
end

function Battle:DeathDropProp(pKiller, pDeather)
	local tbBattleInfo		= Battle:GetPlayerData(pKiller);
	local tbMission			= tbBattleInfo.tbMission;
	local nMaxNum			= tbMission:GetPlayerCount();
	local nKillHonorLevel 	= self:GetHonorLevel(pKiller);
	local nDeathHonorLevel 	= self:GetHonorLevel(pDeather);
	
	local nAddBouns			= Battle.DEF_DAXIA_POINT_KILLPLAYER[nDeathHonorLevel] or Battle.DEF_DAXIA_POINT_KILLPLAYER_NORMAL;
	
	if (11 == nDeathHonorLevel) then
		nAddBouns = Battle.DEF_DAXIA_POINT_KILLPLAYER_PLAYERNPC;
	end

	tbMission.nDropItemBouns = tbMission.nDropItemBouns + nAddBouns;
	tbMission.nLog_KillBouns = tbMission.nLog_KillBouns + nAddBouns;
	
	if (tbMission.nDropItemBouns > Battle.DEF_MAX_TOTAL_DROP_BOUNS) then
		tbMission.nDropItemBouns = Battle.DEF_MAX_TOTAL_DROP_BOUNS;
	end

	local nTotalBouns	= tbMission.nDropItemBouns;
	local nLowBouns		= self:GetLowBouns(nMaxNum);

	if (nTotalBouns < nLowBouns) then
		return 0;
	end
	
	if (not self.tbKillDropProp or 
		not self.tbKillDropProp[nKillHonorLevel] or 
		not self.tbKillDropProp[nKillHonorLevel][nDeathHonorLevel]) then
		return 0;
	end

	local nRandom = MathRandom(Battle.DEF_MAX_KILL_DROP_PROP);
	local nProp = self.tbKillDropProp[nKillHonorLevel][nDeathHonorLevel] or 0;

	if (nRandom <= nProp) then
		self:DropItem(pKiller, pDeather, nDeathHonorLevel);
	end
	return 1;
end

function Battle:GetHonorLevel(pPlayer)
	local nHonorLevel = 0;
	nHonorLevel = pPlayer.GetHonorLevel();
	
	local tbBattleInfo	= Battle:GetPlayerData(pPlayer);
	if (tbBattleInfo.bHaveNpc and tbBattleInfo.bHaveNpc == 1) then
		nHonorLevel = 11;
	end
	
	return nHonorLevel;
end

function Battle:GetLowBouns(nMaxPlayerNum)
	local nLowBouns = 999999999;
	for i, tbInfo in ipairs(self.NUM_TO_DROP_BOUNS) do
		if (tbInfo[1] <= nMaxPlayerNum) then
			nLowBouns = tbInfo[2];
		end
	end
	return nLowBouns;
end

Battle.tbItemList		= Battle:GetItemList();
Battle.tbKillDropProp	= Battle:GetItemDropProp();
