--
-- FileName: wuyimeijiujie_gs.lua
-- Author: hanruofei
-- Time: 2011/4/19 16:37
-- Comment: 五一美酒节功能实现
--
Require("\\script\\event\\jieri\\20110501_meijiujie\\wuyimeijiujie_gs_def.lua");


SpecialEvent.tbMeijiujie20110501 =  SpecialEvent.tbMeijiujie20110501 or {};
local tbMeijiujie20110501 = SpecialEvent.tbMeijiujie20110501;

-- 活动中各种读条的打断事件
tbMeijiujie20110501.tbBreakEvent = 
{
	Player.ProcessBreakEvent.emEVENT_MOVE,
	Player.ProcessBreakEvent.emEVENT_ATTACK,
	Player.ProcessBreakEvent.emEVENT_SITE,
	Player.ProcessBreakEvent.emEVENT_USEITEM,
	Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
	Player.ProcessBreakEvent.emEVENT_DROPITEM,
	Player.ProcessBreakEvent.emEVENT_SENDMAIL,		
	Player.ProcessBreakEvent.emEVENT_TRADE,
	Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
	Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
	Player.ProcessBreakEvent.emEVENT_ATTACKED,
	Player.ProcessBreakEvent.emEVENT_DEATH,
	Player.ProcessBreakEvent.emEVENT_LOGOUT,
};

-- 判断当前时间是否在活动期间
function tbMeijiujie20110501:IsInTime()
	local nNowTime = tonumber(GetLocalDate("%Y%m%d"));
	if nNowTime < self.nStartTime then
		return 0, "五一美酒节活动还没有开始。";
	end
	if nNowTime > self.nEndTime then
		return 0, "五一美酒节活动已经结束了。";	
	end
	return 1;
end

-- 指定的玩家是否是可以参加活动的有效玩家
-- 返回1表示是有效率玩家，返回0表示是无效玩家，如果有第二个返回值，则表示无效的原因
function tbMeijiujie20110501:IsValidPlayer(pPlayer)

	if pPlayer.nFaction <= 0 then
		return 0, "这位大侠，请先加入门派再来参加活动吧。";
	end
	
	if pPlayer.nLevel < self.nMinLevel then
		return 0, "这位大侠，您还没有到" .. tostring(self.nMinLevel) .. "级。";
	end
	
	return 1;
end

-- 获得pPlayer当天已经领取酒的次数
function tbMeijiujie20110501:GetUsedCountOfGettingWine(pPlayer)
	local nNowTime = tonumber(GetLocalDate("%Y%m%d"));
	if nNowTime ~= pPlayer.GetTask(self.TASK_GROUP_ID, self.DATE_ID) then
		pPlayer.SetTask(self.TASK_GROUP_ID, self.DATE_ID, nNowTime);
		pPlayer.SetTask(self.TASK_GROUP_ID, self.USED_COUNT_ID,  0);
	end
	return pPlayer.GetTask(self.TASK_GROUP_ID, self.USED_COUNT_ID);
end

-- 设置当天领酒次数
function tbMeijiujie20110501:SetUsedCountOfGettingWine(pPlayer, nUsedCount)
	pPlayer.SetTask(self.TASK_GROUP_ID, self.USED_COUNT_ID,  nUsedCount);
end

-- 检查指定的玩家当前是否可以从酒缸上取酒
-- 返回0表示不可以，如果有第二个返回值，则其表示不可以的原因
-- 返回1表示可以
function tbMeijiujie20110501:CheckConditionForGettingWine(pPlayer)
	if self.bIsOpen ~= 1 then
		return 0, "活动已经关闭。";
	end
	local bOk, szErrorMsg = self:IsInTime();
	if bOk == 0 then
		return bOk, szErrorMsg;
	end
	
	bOk, szErrorMsg = self:IsValidPlayer(pPlayer);
	if bOk == 0 then
		return bOk, szErrorMsg;
	end
	
	local nCount = pPlayer.GetItemCountInBags(unpack(self.tbKaixinjiubeiGDPL));
	if nCount < 1 then
		return 0, "你身上没有携带开心酒杯。在各大城市广场中央卖火柴的小女孩处可以买到开心酒杯，每天可以在酒坛处取酒三瓶。"
	end
	
	local nUsedCount = self:GetUsedCountOfGettingWine(pPlayer);
	if nUsedCount >= self.nMaxUseCountPerDay then
		return 0, "你今天已经拿满了三瓶酒，美酒虽好，可不要贪杯哦。";
	end
	
	if pPlayer.CountFreeBagCell() < self.nFreeCellCountNeededWhileGettingWine then
		return 0, "你的背包空间不足，请整理出" .. tostring(self.nFreeCellCountNeededWhileGettingWine) .. "各空间后再来取酒。";
	end
	
	return 1;
end

-- 检查pPlayer是否可以喝酒，召唤舞者
function tbMeijiujie20110501:CheckConditonForDrinking(pPlayer)
	if self.bIsOpen ~= 1 then
		return 0, "活动已经关闭。";
	end
	local bOk, szErrorMsg = self:IsInTime();
	if bOk == 0 then
		return bOk, szErrorMsg;
	end
	
	bOk, szErrorMsg = self:IsValidPlayer(pPlayer);
	if bOk == 0 then
		return bOk, szErrorMsg;
	end

	-- 是否还有奖励没有领取
	local nTime = pPlayer.GetTask(self.TASK_GROUP_ID, self.HAS_AWARD_ID);
	if nTime ~= 0 then
		local nDeltaTime = GetTime() - nTime;
		if nDeltaTime < 0 then
			-- 不应该出现的地方，写Log
		elseif nDeltaTime < self.nCannotAwardDuration then
			-- 已经召唤了一个舞者，不能再召唤
			return 0, "您已经喝醉了，稍微休息一下吧。";
		else
			return 0, "您还有一个五一劳动者宝箱没有领取，请先到卖火柴的小女孩处领取，然后再喝下一杯酒吧。";
		end
	end
	
--[[	-- 有酒吗？
	local bHasWine = 0;
	for _, v in ipairs(self.tbWines) do
		local tbItems = pPlayer.FindItemInBags(unpack(self.tbKaixinjiubeiGDPL));
		if tbItems then
			bHasWine = 1;
			break;
		end
	end
	if bHasWine == 0 then
		return 0, "只有酒杯没有酒，您喝醉了。";
	end--]]
	
	local bIsAroundGouhuo = false;
	local tbAroundNpcList = KNpc.GetAroundNpcList(pPlayer, self.nValidRange);
	if tbAroundNpcList then
		for _, pNpc in ipairs(tbAroundNpcList) do
			if self.nGouhuoNpcTemplateId == pNpc.nTemplateId then
				bIsAroundGouhuo = true;
				break;
			end
		end
	end
	if not bIsAroundGouhuo then
		return 0, "请移玉步到各大城市篝火周围与大家痛饮，岂不快哉！";
	end
	
	if self:GetAPos(pPlayer) == 0 then
		return 0, "这个位置人太多了，换个地方吧！";
	end
	
	return 1;
end

-- 随机获得一个奖励倍数
function tbMeijiujie20110501:GetAdditionalCoe()
	local nRet = self.tbMapProToCoe[1]
	local nValue = MathRandom(1000000);
	for _, v in ipairs(self.tbMapProToCoe) do
		if v[1] >= nValue then
			nRet = v[2];
			break;
		end
		nValue = nValue - v[1];
	end
	return nRet;
end

function tbMeijiujie20110501:CaclAWardLevel(pPlayer)   
	local nHonorRank = PlayerHonor:GetPlayerHonorRankByName(pPlayer.szName, PlayerHonor.HONOR_CLASS_MONEY, 0);
	if not nHonorRank or nHonorRank <= 0 or nHonorRank > self.nUpperRank then
		nHonorRank = self.nUpperRank;
	end
	local fArg = 100 * nHonorRank / self.nUpperRank / 50;
	local fEAward= (fArg ^ 0.25 / (fArg ^ 10 + 1) + 0.2) * 300;
	local nAdditionCoe = self:GetAdditionalCoe();
	local nAwardValue = fEAward * nAdditionCoe;
	local nLevel = 1;
	for i = #self.tbAwards, 1, -1 do
		if nAwardValue >= self.tbAwards[i][3] then
			nLevel = self.tbAwards[i][1];
			break;
		end
	end
	return nLevel;
end

-- 从一个有nCollectionCount个不同元素的集合中，随机拿nMaxCount(只是复制一个出来，集合中的元素不改变)个出来，
-- 保证有且有nCount个元素不同
function tbMeijiujie20110501:GetIndexSeq(nCount, nMaxCount, nCollectionCount)
	if	nCount <= 0 or nMaxCount <= 0  or nCollectionCount <= 0 or 
		nCount > nMaxCount or nCount > nCollectionCount then
		return 0, "对于指定的参数，无法求解这个问题";
	end

	local tbCollection = {};
	for i = 1, nCollectionCount do
		tbCollection[i] = 0;
	end
	local tbRetIndexes = {};
	local nLeftCount = nMaxCount;
	for i = 1, nMaxCount do
		if nCount == 0 then
			break;
		end
		nLeftCount = nMaxCount - i + 1;
		if nLeftCount == nCount then
			break;
		end
		local nIndex = MathRandom(nCollectionCount);
		table.insert(tbRetIndexes, nIndex);
		tbCollection[nIndex] = tbCollection[nIndex] + 1;
		if tbCollection[nIndex] == 1 then
			nCount = nCount - 1;
		end
	end
	
	local tbNewTemp = {};
	if nCount == 0 then
		for k, v in ipairs(tbCollection) do
			if v ~= 0 then
				table.insert(tbNewTemp, k);
			end
		end
		for i = 1, nLeftCount do
			local nIndex = MathRandom(#tbNewTemp);
			table.insert(tbRetIndexes, tbNewTemp[nIndex]);
		end
	else
		for k, v in pairs(tbCollection) do
			if v == 0 then
				table.insert(tbNewTemp, k);
			end
		end
		for i = 1, nLeftCount do
			local nIndex = MathRandom(#tbNewTemp);
			table.insert(tbRetIndexes, table.remove(tbNewTemp, nIndex));
		end
	end
		
	return 1, tbRetIndexes;
end

-- 通过奖励级别获得对应的瓶子数量
function tbMeijiujie20110501:AwardLevelToCount(nLevel)
	local nCount = self.tbAwards[1][2];
	for _,v in pairs(self.tbAwards) do
		if v[1] == nLevel then
			nCount = v[2];
			break;
		end
	end
	return nCount;
end

-- 随机获得一种酒，返回其对应的GDPL
function tbMeijiujie20110501:GetARandomWine(pPlayer)
	local nAwardLevel = pPlayer.GetTask(self.TASK_GROUP_ID, self.AWARD_LEVEL_ID);
	if nAwardLevel == 0 then
		nAwardLevel = self:CaclAWardLevel(pPlayer);
		pPlayer.SetTask(self.TASK_GROUP_ID, self.AWARD_LEVEL_ID, nAwardLevel);
		local nCount = self:AwardLevelToCount(nAwardLevel);
		local nMaxCount = self.nMaxCount
		local nCollectionCount = #self.tbWines;
		local bOk, tbIndexes = self:GetIndexSeq(nCount, nMaxCount, nCollectionCount);
		if bOk == 1 then
			for i = self.JIU_START_ID, self.JIU_END_ID do
				pPlayer.SetTask(self.TASK_GROUP_ID, i, tbIndexes[i - self.JIU_START_ID + 1 ]);
			end
		else
			-- 出错了，写Log
			--error("生成酒的序列出错！");
		end
	end

	local tbRetWine = self.tbWines[1];
	for i = self.JIU_START_ID, self.JIU_END_ID do
		local nIndex = pPlayer.GetTask(self.TASK_GROUP_ID, i);
		if nIndex ~= 0 then
			pPlayer.SetTask(self.TASK_GROUP_ID, i, 0);
			tbRetWine = self.tbWines[nIndex];
			break;
		end
	end
	return tbRetWine;
end

-- 获得酒的操作的执行者
function tbMeijiujie20110501:DoGetWine(nPlayerId, nStep)
	if not nPlayerId then
		return 0;
	end

	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	nStep = nStep or 0;
	
	local bOk, szErrorMsg = self:CheckConditionForGettingWine(pPlayer);
	if szErrorMsg then
		Dialog:Say(szErrorMsg);
	end
	if bOk == 0 then
		return 0;
	end
	
	if nStep == 0 then
		local tbCallBack = {self.DoGetWine, self, nPlayerId, 1};
		GeneralProcess:StartProcess(self.szMsgWhileGettingWine, self.nDurationWhileGettingWine, tbCallBack, nil, self.tbBreakEvent);
		return 1;
	end

	if nStep == 1 then
		-- 酒杯使用过的次数+1
		local tbItems = pPlayer.FindItemInBags(unpack(self.tbKaixinjiubeiGDPL));
		local pItem = tbItems[1].pItem;
		local nUsedCount = pItem.GetGenInfo(self.nGenInfoIndexOfUsedCount);
		nUsedCount = nUsedCount + 1;
		if nUsedCount >= self.nMaxUseCountOfKaixinjiubei then
			pItem.Delete(pPlayer);
		else
			pItem.SetGenInfo(self.nGenInfoIndexOfUsedCount, nUsedCount);
		end
		
		-- 当天已取酒次数+1
		local nUsedCount = self:GetUsedCountOfGettingWine(pPlayer)
		self:SetUsedCountOfGettingWine(pPlayer, nUsedCount + 1);
		
		local tbWineGDPL = self:GetARandomWine(pPlayer);
		local pItem = pPlayer.AddItem(unpack(tbWineGDPL));
		if pItem then
			pPlayer.SetItemTimeout(pItem, "2011/05/04/23/00/00", 0);
		else
			
		end
		
		pPlayer.AddExp(self.nExpWhenGetWine * pPlayer.GetBaseAwardExp());				-- 加经验
		return 1;
	end
	return 0;
end

-- nPlayerId点击酒坛，希望获得一瓶酒（获取酒的入口）
-- 返回0表示失败，如果有第二个返回值，则其表示失败原因
-- 返回1表示成功获得一瓶酒
function tbMeijiujie20110501:GetWine(pPlayer)
	if self.bIsOpen ~= 1 then
		Dialog:Say("活动已经关闭。");
		return;
	end

	local tbOpt =
	{
		{"来瓶酒", self.DoGetWine, self, pPlayer.nId},
		{"我不能再喝了"}
	};
	Dialog:Say(self.szMsgOnDialog, tbOpt);
end

-- 获得pItem对应的空就瓶
function tbMeijiujie20110501:GetEmptyJiuping(pItem)
	local szKey = string.format("%s,%s,%s,%s", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel);
	return self.tbJiupingMaps[szKey];
end

-- 在pPlayer周围找一个空位置来防止舞者
function tbMeijiujie20110501:GetAPos(pPlayer)
	local nMapId, nPosX, nPosY = pPlayer.GetWorldPos();
	local tbNpcList = KNpc.GetAroundNpcList(pPlayer, self.nDistanceNoNpc);
	for _, pNpc in ipairs(tbNpcList) do
		if pNpc.nKind == 3 then
			return 0, string.format("这个位置会把<color=green>%s<color>给挡住了，还是挪个地方吧。", pNpc.szName);
		end
	end
	return 1, {nMapId, nPosX, nPosY};
end


function tbMeijiujie20110501:CaclDistance(pA, pB)
	local bOk = 0;
	local nDistance = 0;
	local nMapIdA, nPosXA, nPosYA = pA.GetWorldPos();
	local nMapIdB, nPosXB, nPosYB = pB.GetWorldPos();
	if nMapIdA == nMapIdB then
		bOk = 1;
		nDistance = math.floor(math.sqrt((nPosXA - nPosXB) ^ 2 + (nPosYA - nPosYB) ^ 2));
	end
	return bOk, nDistance;
end

function tbMeijiujie20110501:IsInValidDistance(pA, pB)
	local bOk, nDistance = self:CaclDistance(pA, pB);
	if bOk == 0 or nDistance > self.nDistanceNoAward then
		return 0;
	end
	return 1;
end

-- 计算奖励系数
function tbMeijiujie20110501:GetAwardCoefficient(pPlayer, pNpc)
	local nCoefficient = 1.0;
	local nValidPlayerCount = 0; -- 影响加成系数的玩家的数量
	local tbTeammeberList = pPlayer.GetTeamMemberList() or {};
	local tbAroundPlayerList = KNpc.GetAroundPlayerList(pNpc.dwId, self.nAroundDistance) or {};
	for _, v in ipairs(tbTeammeberList) do
		for _, v1 in ipairs(tbAroundPlayerList) do
			if v.nId ~= pPlayer.nId and v.nId == v1.nId and v.GetSkillState(self.nSkillId) then
				nValidPlayerCount = nValidPlayerCount + 1;
			end
		end
	end
	
	return nCoefficient + 0.1 * nValidPlayerCount;
end

-- nNpcId周期性给nPlayerId加经验加绑银
function tbMeijiujie20110501:AddAward_Timer(nGroupId)
	if not self.tbDataGroup[nGroupId] then
		return 0;
	end
	local nNpcId = nGroupId;
	local nPlayerId = self.tbDataGroup[nGroupId][1];
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		self.tbDataGroup[nGroupId] = nil;
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			Dialog:SendBlackBoardMsg(pPlayer, self.szMsgNotifyRandomBox);	
		end
		return 0;
	end
	
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	
	local tbData = self.tbDataGroup[nNpcId];
	local bFlag = tbData[4];
	
	local bOk, szErrorMsg = self:IsInValidDistance(pPlayer, pNpc);
	tbData[4] = bOk;
	if bOk == 0 then
		if bFlag == 1 then
			Dialog:SendBlackBoardMsg(pPlayer, self.szMsgFarwayFromDancer);
		end
		return;
	end
	
	pPlayer.CastSkill(self.nSkillId, self.nBuffDuration, -1, pPlayer.GetNpc().nIndex);
	
	local nCoefficient = self:GetAwardCoefficient(pPlayer, pNpc);-- 计算奖励系数
	
	local nProValue = MathRandom(100);
	if nProValue >= self.tbProAddExp[1] and nProValue <= self.tbProAddExp[2] then 
		pPlayer.AddExp(self.nExpCoeEverytime * nCoefficient * pPlayer.GetBaseAwardExp());				-- 加经验
	elseif nProValue >= self.tbProAddBindMoney[1] and nProValue <= self.tbProAddBindMoney[2] then
		pPlayer.AddBindMoney(self.nBindMoneyEverytime * nCoefficient);	-- 加绑银
	else
	end
	
	return;
end

tbMeijiujie20110501.tbDataGroup = {}; -- 用于存储NPC， Player，以及相关Timer的表

-- 召唤一个pPlayer对应的舞者
function tbMeijiujie20110501:CallDancer(pPlayer)
	local _, tbPos = self:GetAPos(pPlayer);-- 先找一个位置
	local nNpcId = self.tbDancers[pPlayer.nSex];
	local pNpc = KNpc.Add2(nNpcId, 1, -1, tbPos[1], tbPos[2], tbPos[3]);
	if not pNpc then
		return;
	end
	-- 设置NPC的生存周期
	pNpc.SetLiveTime(self.nAwardDuration);
	pNpc.SetTitle(string.format("<color=pink>%s的舞者<color>",pPlayer.szName));
	local nGroupId = pNpc.dwId;
	self.tbDataGroup[nGroupId] = {};
	local tbData = self.tbDataGroup[nGroupId];
	
	table.insert(tbData, pPlayer.nId);
	
	-- 设置周期性加经验加绑银的回调
	local nTimerId = Timer:Register(self.nCycleTime, self.AddAward_Timer, self, nGroupId);
	table.insert(tbData, nTimerId);
	
	table.insert(tbData, 1); -- 初次召唤，则必然在有效范围内

end

--喝酒的执行者
function tbMeijiujie20110501:DoDrinking(nPlayerId, nItemId, nStep)
	if not nPlayerId or not nItemId then
		return 0;
	end
	
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	
	nStep = nStep or 0;
	local bOk, szErrorMsg = self:CheckConditonForDrinking(pPlayer);
	if szErrorMsg then
		Dialog:Say(szErrorMsg);
	end
	if bOk == 0 then
		return 0;
	end
	
	if nStep == 0 then
		local tbCallBack = {self.DoDrinking, self, nPlayerId, nItemId, 1};
		GeneralProcess:StartProcess(self.szMsgWhileDrinking, tbMeijiujie20110501.nDurationWhileDrinking, tbCallBack, nil, self.tbBreakEvent);
		return 1;
	end
	
	if nStep == 1 then

		StatLog:WriteStatLog("stat_info", "worker_2011_drink", "use_item", nPlayerId, 1);
	
		local szName = pItem.szName;
		local tbEmptyJiupingGDPL = self:GetEmptyJiuping(pItem);
		pItem.Delete(pPlayer);-- 删除酒
		local szMsg = nil;
		-- 添加一个空瓶子
		local tbItems = pPlayer.FindItemInAllPosition(unpack(tbEmptyJiupingGDPL))
		if not tbItems or #tbItems == 0 then
			local pAddedItem = pPlayer.AddItem(unpack(tbEmptyJiupingGDPL));
			if pAddedItem then
				pPlayer.SetItemTimeout(pAddedItem, "2011/05/11/23/59/00", 0);
				szMsg = string.format(self.szMsgGetEmptyGlassB, pAddedItem.szName);
			else
				--print("添加空瓶子失败1!", unpack(tbEmptyJiupingGDPL));
			end
		else
			--print("添加空瓶子失败2!", unpack(tbEmptyJiupingGDPL));
		end
		-- 召唤舞者
		self:CallDancer(pPlayer);
		
		if szMsg then
			szMsg = self.szMsgCalledADancer .. "，" .. szMsg;
		else
			szMsg = self.szMsgCalledADancer .. "。";
		end
		
		Dialog:SendBlackBoardMsg(pPlayer, self.szMsgCalledADancer);
		-- 记录有一个五一劳动者礼包要领
		pPlayer.SetTask(self.TASK_GROUP_ID, self.HAS_AWARD_ID, GetTime());
	end
	
	return 0;
end

-- pPlayer喝酒pItem，召唤舞者
-- 喝酒的入口
function tbMeijiujie20110501:Drink(pPlayer, pItem)
	if self.bIsOpen ~= 1 then
		Dialog:Say("活动已经关闭。");
		return;
	end
	self:DoDrinking(pPlayer.nId, pItem.dwId);	
end

tbMeijiujie20110501.tbNpcs = {}; -- 篝火，酒坛

--[[-- 从tbPositions中随机选10个
function tbMeijiujie20110501:GetRandom10Positions(tbPositions)
	local tbTemp = {};
	for _, v in ipairs(tbPositions) do
		table.insert(tbTemp, v);
	end
	local tbRet = {};
	for i =1, 10 do
		local nKey = MathRandom(#tbTemp);
		table.insert(tbRet, table.remove(tbTemp, nKey));
	end
	return tbRet;
end--]]

-- 随机得到一个酒坛的TemplateId
function tbMeijiujie20110501:GetARandomJiutanTemplateId()
	local nKey = MathRandom(#self.tbJiutanNpcTemplateIds);
	return self.tbJiutanNpcTemplateIds[nKey];
end

-- 刷篝火，刷酒坛
function tbMeijiujie20110501:CallEventNpc()
	if self.bIsNpcCalled == 1 then
		return;
	end
	-- 刷篝火
	for _,v in ipairs(self.tbGouhuoPositions) do
		if SubWorldID2Idx(v[1]) >= 0  then
			local pNpc = KNpc.Add2(self.nGouhuoNpcTemplateId, 1, -1, v[1], unpack(v[2]));
			if pNpc then
				table.insert(self.tbNpcs, pNpc.dwId);
			else
				-- 写Log
			end
		end
	end
	
	-- 刷酒坛
	for k, v in pairs(self.tbJiutanPositions) do
		if SubWorldID2Idx(k) >= 0 then
			for _, v1 in pairs(v) do
				local nNpcTemplateId = self:GetARandomJiutanTemplateId();
				local pNpc = KNpc.Add2(nNpcTemplateId, 1, -1, k, unpack(v1));
				if pNpc then
					table.insert(self.tbNpcs, pNpc.dwId);
				else
					-- 写Log
				end
			end
		end
	end
	
	self.bIsNpcCalled = 1;
end

-- 删除篝火，删除酒坛
function tbMeijiujie20110501:RemoveEventNpc()
	if self.bIsNpcCalled == 0 then
		return;
	end
	for _, v in pairs(self.tbNpcs) do
		local pNpc = KNpc.GetById(v);
		if pNpc then
			pNpc.Delete();
		end
	end
	self.tbNpcs = {};
	self.bIsNpcCalled = 0;
end

function tbMeijiujie20110501:GetAwardInfo(nCount)
	local tbAwards = self.tbMapProToCoe[1][4];
	for _, v in ipairs(self.tbAwards) do
		if v[2] == nCount then
			tbAwards = v[4];
			break;
		end
	end
	
	local nCountFreeCell = tbAwards[1] - nCount
	if nCountFreeCell <= 0 then
		return 0, tbAwards;
	else
		return nCountFreeCell, tbAwards;
	end
	
end

-- 用空瓶兑奖
function tbMeijiujie20110501:Duijiang()
	local bHasGlassInCangku = 0;
	local tbAllItems = {};
	local nCount = 0;
	for _, v in pairs(self.tbJiupingMaps) do
		local tbItems = me.FindItemInRepository(unpack(v))
		if tbItems and #tbItems ~= 0 then
			bHasGlassInCangku = 1;
			break;
		end
		local tbItems = me.FindItemInBags(unpack(v));
		if tbItems and #tbItems ~= 0 then
			table.insert(tbAllItems, tbItems);
			nCount = nCount + 1;
		end
	end
	
	if bHasGlassInCangku == 1 then
		Dialog:Say("请把储物箱中的空酒瓶也带来吧！");
		return;
	end
	
	if nCount == 0 then
		Dialog:Say("你身上没有空酒瓶，不能兑奖！");
		return;
	end
	
	local nCellNeeded, tbAwards = self:GetAwardInfo(nCount);
	if nCellNeeded > 0 and me.CountFreeBagCell() < nCellNeeded then
		Dialog:Say("Hành trang không đủ chỗ trống，请整理出" .. tostring(nCellNeeded) .. "格空间再来兑换奖励。");
		return ;
	end
	
	-- 删除所有空瓶子
	for _, v in ipairs(tbAllItems) do
		for _, v1 in ipairs(v) do
			v1.pItem.Delete(me);
		end
	end
	
	local szName = "美酒";
	for i = 1, tbAwards[1] do 
		local pItem = me.AddItem(unpack(tbAwards[2]));
		if pItem then
			if szName == "美酒" then
				szName = pItem.szName;
			end
			me.SetItemTimeout(pItem, "2011/06/04/23/59/00", 0);
		end
	end
	
	local nKind = tbAwards[2][4] - 20;
	
	StatLog:WriteStatLog("stat_info", "worker_2011_drink", "get_box", me.nId, tostring(nKind) .. "," .. tostring(tbAwards[1]));
	Dialog:SendBlackBoardMsg(me, string.format(self.szMsgDuijiang, tbAwards[1], szName));
end

-- 领五一劳动者宝箱
function tbMeijiujie20110501:GetLibao()
	local nTime = me.GetTask(self.TASK_GROUP_ID, self.HAS_AWARD_ID);
	if nTime == 0 then
		Dialog:Say("你没有五一劳动者宝箱可以领取。");
		return;
	end
	
	if GetTime() - nTime < self.nAwardDuration / Env.GAME_FPS then
		Dialog:Say("你没有五一劳动者宝箱可以领取。");
		return;
	end

	if me.CountFreeBagCell()  < 1 then
		Dialog:Say("Hành trang không đủ chỗ trống，请整理出1格空间再来领取五一劳动者宝箱。");
		return ;
	end
	local pItem = me.AddItem(unpack(self.tbLaodonglibaoGDPL));
	if not pItem then
		Dialog:Say("发生了意外，领不到五一劳动者宝箱。");
		return;
	else
		me.SetItemTimeout(pItem, "2011/06/04/23/59/00", 0);
	end
	
	StatLog:WriteStatLog("stat_info", "worker_2011_drink", "get_box", me.nId, "0,1");
	
	Dialog:SendBlackBoardMsg(me, "你获得了一个五一劳动者宝箱。");
	me.SetTask(self.TASK_GROUP_ID, self.HAS_AWARD_ID, 0);
end


-- 服务器启动
function tbMeijiujie20110501:OnServerStart()
	if self.bIsOpen == 0 then
		return;
	end
	
	if self:IsInTime() == 0 then
		return;
	end
	
	local nNowTime = tonumber(GetLocalDate("%H%M"));
	local bNpcShouldBeCalled = 0;
	for _, v in ipairs(self.tbTimes) do
		if nNowTime >= v[0]  and nNowTime <= v[1] then
			bNpcShouldBeCalled = 1;
			break;
		end
	end
	
	if bNpcShouldBeCalled == 1 then
		self:CallEventNpc()
	end
end
if tbMeijiujie20110501:IsInTime() == 1 then
	ServerEvent:RegisterServerStartFunc(tbMeijiujie20110501.OnServerStart, tbMeijiujie20110501)
end

