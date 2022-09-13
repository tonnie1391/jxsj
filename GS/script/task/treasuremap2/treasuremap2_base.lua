-- 文件名  : treasuremap2_base.lua
-- 创建者  : zounan
-- 创建时间: 2010-08-29 22:17:41
-- 描述    : 
Require("\\script\\task\\treasuremap2\\treasuremap2_def.lua")

function TreasureMap2:GetMapTempletList()		
	if not self.MapTempletList then
		self.MapTempletList = {};
		self.MapTempletList.tbBelongList = {};
		self.MapTempletList.nCount = 0;
	end	
	return self.MapTempletList;
end

-- 玩家申请一个FB
function TreasureMap2:CreateInstancing(pPlayer,nTreasureId, nTreasureLevel, nCityMapId)
	--地图分配	
	local nApplyMapId = self:GetFreeMap(nTreasureId);
	
	self:GetMapTempletList();

	if self.MapTempletList.nCount >= self.INSTANCE_LIMIT then
		return 0;
	end

	-- 通知GC载入地图
	if (not nApplyMapId) then
		if self:CheckDynMapLimit(nTreasureId) == 0 then  --没有的话不让申请
			return 0;
		end

		if (Map:LoadDynMap(Map.DYNMAP_TREASUREMAP, self.TEMPLATE_LIST[nTreasureId].nTemplateMapId, {self.OnLoadMapFinish, self, pPlayer.nId,nCityMapId, nTreasureId, nTreasureLevel}) == 1) then
			self.MapTempletList.tbBelongList[pPlayer.nId] = {nCityMapId,  0};
			self.MapTempletList.nCount = self.MapTempletList.nCount + 1;
		--	GCExcute({"TreasureMap2:Apply_GC", pPlayer.nId, nCityMapId});
			--GlobalExcute({"TreasureMap2:SyncMap",  pPlayer.nId, nCityMapId});
			return 1;
		else
			print("CreateInstancing Error!");
			return 0;
		end
	else
		self.MapTempletList.tbBelongList[pPlayer.nId] = {nCityMapId,  0};
		self.MapTempletList.nCount = self.MapTempletList.nCount + 1;
	--	GCExcute({"TreasureMap2:Apply_GC", pPlayer.nId, nCityMapId, nLevel});	
		--GlobalExcute({"TreasureMap2:SyncMap",  pPlayer.nId, nCityMapId});	
		self:OpenInstance(pPlayer.nId, nTreasureId, nTreasureLevel, nApplyMapId,nCityMapId, 0);
		return 1;
	end
end

function TreasureMap2:CheckDynMapLimit(nTreasureId)
	if TreasureMap2.tbDynMapList[nTreasureId] > 0 then
		TreasureMap2.tbDynMapList[nTreasureId] = TreasureMap2.tbDynMapList[nTreasureId] - 1;
		return 1;
	end
	
	if TreasureMap2.tbDynMapList[0] > 0 then
		TreasureMap2.tbDynMapList[0] = TreasureMap2.tbDynMapList[0] - 1;
		return 1;
	end	
	
	return 0;
end

-- GC载入地图完毕 GC回调
function TreasureMap2:OnLoadMapFinish(nPlayerId, nCityMapId, nTreasureId, nTreasureLevel, nMapId)
	local tbTreasureMap = self:GetTreasureMapList(nTreasureId);

	tbTreasureMap.tbUseIdx[#tbTreasureMap.tbUseIdx + 1] = nMapId;	
	tbTreasureMap.tbId2Index[nMapId] = #tbTreasureMap.tbUseIdx;
	
	self:OpenInstance(nPlayerId, nTreasureId, nTreasureLevel, nMapId,nCityMapId, 1);
end

-- 开启副本地图
function TreasureMap2:OpenInstance(nPlayerId, nTreasureId, nTreasureLevel, nMapId,nCityMapId, bNewMap)	
	GCExcute({"TreasureMap2:Apply_GC", nPlayerId, nCityMapId});	 -- OPEN的时候再同步比较好
	self.MapTempletList.tbBelongList[nPlayerId][2] = nMapId;
	
	self:MapInit(nTreasureId, nTreasureLevel,nMapId,nPlayerId, bNewMap);	
	
	local tbInstancingBase = TreasureMap2:GetInstancingBase(nTreasureId);
	local tbInstancing = Lib:NewClass(tbInstancingBase);	
	

	self.MissionList = self.MissionList or {};

	if not self.MissionList[nPlayerId] then
		self.MissionList[nPlayerId] = tbInstancing;
	end
	self.tbOpenedList[nMapId] = self.MissionList[nPlayerId];
	
	tbInstancing:StartGame(nPlayerId, nMapId,nCityMapId, nTreasureId, nTreasureLevel);	
end

function TreasureMap2:GetInstancing(nMapId)
	return self.tbOpenedList[nMapId];	
end

function TreasureMap2:GetInstancingByPlayerId(nPlayerId)
	return self.MissionList[nPlayerId];	
end

function TreasureMap2:GetTreasureMapList(nTreasureId)
	if not self.tbTotalMapList[nTreasureId] then
		self.tbTotalMapList[nTreasureId] = { tbUseIdx = {}, tbFreeIdx = {}, tbId2Index = {}, };		
	end	
	return self.tbTotalMapList[nTreasureId];
end

function TreasureMap2:GetFreeMap(nTreasureId)
	local tbTreasureMap = self:GetTreasureMapList(nTreasureId);

	if #tbTreasureMap.tbFreeIdx ~= 0 then
		local nApplyMapId = tbTreasureMap.tbFreeIdx[#tbTreasureMap.tbFreeIdx];		
		tbTreasureMap.tbUseIdx[#tbTreasureMap.tbUseIdx + 1] = nApplyMapId;	
		tbTreasureMap.tbFreeIdx[#tbTreasureMap.tbFreeIdx] = nil;	
		tbTreasureMap.tbId2Index[nApplyMapId] = #tbTreasureMap.tbUseIdx;
		return nApplyMapId;
	end	
	return;
end

function TreasureMap2:SetFreeMap(nTreasureId, nMapId)
	local tbTreasureMap = self.tbTotalMapList[nTreasureId];
	if not tbTreasureMap then
		print("[ERR]TreasureMap2:SetMapFree: NO TreasureMap!", nTreasureId,nMapId);
		return;
	end
		
	tbTreasureMap.tbFreeIdx[#tbTreasureMap.tbFreeIdx + 1] = nMapId;	
		
	local nIndex = tbTreasureMap.tbId2Index[nMapId];
	if not nIndex or nIndex == 0 then
		print("[ERR]TreasureMap2:SetMapFree: Index Error!", nTreasureId,nMapId);
		return;	
	end
	
	tbTreasureMap.tbUseIdx[nIndex] = tbTreasureMap.tbUseIdx[#tbTreasureMap.tbUseIdx];	
	tbTreasureMap.tbUseIdx[#tbTreasureMap.tbUseIdx] = nil;
	tbTreasureMap.tbId2Index[nMapId] = 0;    --FREE 之后要清0
	
end	

function TreasureMap2:SyncMap(nPlayerId, nCityMapId)
	self:GetMapTempletList();
	if not self.MapTempletList.tbBelongList[nPlayerId] then
		self.MapTempletList.tbBelongList[nPlayerId] = {nCityMapId, 0};
	end
end

function TreasureMap2:ReleaseMap(nPlayerId)
	self:GetMapTempletList();
	if self.MapTempletList.tbBelongList[nPlayerId] then
		self.MapTempletList.tbBelongList[nPlayerId] = nil;
	end
end

function TreasureMap2:GetTreasure(nTreasureId)
	if not self.TEMPLATE_LIST[nTreasureId] then
		print("[ERR] GetTreasure", nTreasureId);
		assert(false);
		return;
	end
	return self.TEMPLATE_LIST[nTreasureId];
end

--次数
function TreasureMap2:CheckPlayerTimes(pPlayer)
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	local nTskDate = pPlayer.GetTask(self.TSK_GROUP, self.TSK_PLAYDATE);
	if nTskDate ~= nCurDate then
		return 1;
	end
	
	local nPlayerTimes = pPlayer.GetTask(self.TSK_GROUP, self.TSK_PLAYTIMES);
	if nPlayerTimes < self.TIMES_LIMIT then
		return 1;
	end
	
	return 0;
end


--次数
function TreasureMap2:GetPlayerTimes(pPlayer)
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	local nTskDate = pPlayer.GetTask(self.TSK_GROUP, self.TSK_PLAYDATE);
	if nTskDate ~= nCurDate then
		return 0;
	end
	
	local nPlayerTimes = pPlayer.GetTask(self.TSK_GROUP, self.TSK_PLAYTIMES);
	return nPlayerTimes;
end

function TreasureMap2:AddPlayerTimes(pPlayer)
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	local nTskDate = pPlayer.GetTask(self.TSK_GROUP, self.TSK_PLAYDATE);
	if nTskDate ~= nCurDate then
		pPlayer.SetTask(self.TSK_GROUP, self.TSK_PLAYDATE, nCurDate);
		pPlayer.SetTask(self.TSK_GROUP, self.TSK_PLAYTIMES, 1);
		return;
	end	
	local nPlayerTimes = pPlayer.GetTask(self.TSK_GROUP, self.TSK_PLAYTIMES);
	pPlayer.SetTask(self.TSK_GROUP, self.TSK_PLAYTIMES, nPlayerTimes + 1);	
end

function TreasureMap2:SetPlayerTimes(pPlayer, nTimes)
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	local nTskDate = pPlayer.GetTask(self.TSK_GROUP, self.TSK_PLAYDATE);
	if nTskDate ~= nCurDate then
		pPlayer.SetTask(self.TSK_GROUP, self.TSK_PLAYDATE, nCurDate);
		pPlayer.SetTask(self.TSK_GROUP, self.TSK_PLAYTIMES, nTimes);
		return;
	end	
	local nPlayerTimes = pPlayer.GetTask(self.TSK_GROUP, self.TSK_PLAYTIMES);
	pPlayer.SetTask(self.TSK_GROUP, self.TSK_PLAYTIMES, nTimes);	
end


--道具
function TreasureMap2:CheckPlayerItem(pPlayer, nTreasureId,nTreasureLevel)
	local tbTreasure = self:GetTreasure(nTreasureId);
	if not tbTreasure then
		return 0;
	end
	if tbTreasure.tbTaskGroupId[1] and tbTreasure.tbTaskGroupId[2] then
		local nCount = pPlayer.GetTask(tbTreasure.tbTaskGroupId[1], tbTreasure.tbTaskGroupId[2]);
		if nCount >= 1 then
			return 1;
		end
	end
	local nCommonCount = pPlayer.GetTask(self.TASK_GROUP, self.TASK_ID_COMMONTASK);
	if nCommonCount >= 1 then
		return 1;
	end
	--[[
	local tbFind = nil;
	if tbTreasure.tbXiaKeDailyItem[nTreasureLevel] then
		tbFind = pPlayer.FindItemInBags(unpack(tbTreasure.tbXiaKeDailyItem[nTreasureLevel]));
		--print(unpack(tbTreasure.tbXiaKeDailyItem[nTreasureLevel]));
		if #tbFind > 0 then
			return 1;
		end
	end
	local tbFind = pPlayer.FindItemInBags(unpack(self.DEFAULT_ITEM));
	if #tbFind > 0 then
		return 1;
	end
	
	tbFind = pPlayer.FindItemInBags(unpack(tbTreasure.tbItem));
	if #tbFind > 0 then
		return 1;
	end
	
	tbFind = pPlayer.FindItemInBags(unpack(self.DEFALUT_LEVEL_ITEM[nTreasureLevel]));
	if #tbFind > 0 then
		return 1;
	end	
	
	tbFind = pPlayer.FindItemInBags(unpack(tbTreasure.tbLevelItem[nTreasureLevel]));
	if #tbFind > 0 then
		return 1;
	end	
	]]--
	return 0;
end

function TreasureMap2:ConsumePlayerItem(pPlayer, nTreasureId, nTreasureLevel)
	local tbTreasure = self:GetTreasure(nTreasureId);
	assert(tbTreasure);
	if tbTreasure.tbTaskGroupId[1] and tbTreasure.tbTaskGroupId[2] then
		local nCount = pPlayer.GetTask(tbTreasure.tbTaskGroupId[1], tbTreasure.tbTaskGroupId[2]);
		if nCount >= 1 then
			pPlayer.SetTask(tbTreasure.tbTaskGroupId[1], tbTreasure.tbTaskGroupId[2], nCount - 1);
			self:WriteLog("参与副本情况",string.format("%s,%s%d星令牌,%s,%d", pPlayer.szName,tbTreasure.szName,nTreasureLevel,tbTreasure.szName, nTreasureLevel));
			return 1;
		end
	end
	local nCommonCount = me.GetTask(self.TASK_GROUP, self.TASK_ID_COMMONTASK);
	if nCommonCount >= 1 then
		pPlayer.SetTask(self.TASK_GROUP, self.TASK_ID_COMMONTASK, nCommonCount - 1);
		return 1;
	end
	--[[
	local tbFind = nil;
	-- 先扣侠客任务令牌
	if tbTreasure.tbXiaKeDailyItem[nTreasureLevel] then
		tbFind = pPlayer.FindItemInBags(unpack(tbTreasure.tbXiaKeDailyItem[nTreasureLevel]));
		if #tbFind > 0 then
			pPlayer.ConsumeItemInBags(1, unpack(tbTreasure.tbXiaKeDailyItem[nTreasureLevel]));
			return 1;
		end
	end
	--再扣常规令牌
	tbFind = pPlayer.FindItemInBags(unpack(tbTreasure.tbLevelItem[nTreasureLevel]));
	if #tbFind > 0 then
		pPlayer.ConsumeItemInBags(1, unpack(tbTreasure.tbLevelItem[nTreasureLevel]));
		
		self:WriteLog("参与副本情况",string.format("%s,%s%d星令牌,%s,%d", pPlayer.szName,tbTreasure.szName,nTreasureLevel,tbTreasure.szName, nTreasureLevel));
		return 1;
	end	


	--再扣 副本通用令牌
	tbFind = pPlayer.FindItemInBags(unpack(tbTreasure.tbItem));
	if #tbFind > 0 then
		pPlayer.ConsumeItemInBags(1, unpack(tbTreasure.tbItem));
		
		self:WriteLog("参与副本情况",string.format("%s,%s通用令牌,%s,%d", pPlayer.szName,tbTreasure.szName,tbTreasure.szName, nTreasureLevel));
		return 1;
	end		
	
	-- 再扣星级通用令牌
	tbFind = pPlayer.FindItemInBags(unpack(self.DEFALUT_LEVEL_ITEM[nTreasureLevel]));
	if #tbFind > 0 then
		pPlayer.ConsumeItemInBags(1, unpack(self.DEFALUT_LEVEL_ITEM[nTreasureLevel]));		
		self:WriteLog("参与副本情况",string.format("%s,通用%d星令牌,%s,%d", pPlayer.szName,nTreasureLevel,tbTreasure.szName, nTreasureLevel));
		return 1;
	end			
	

	--再扣 通用令牌
	tbFind = pPlayer.FindItemInBags(unpack(self.DEFAULT_ITEM));
	if #tbFind > 0 then
		pPlayer.ConsumeItemInBags(1, unpack(self.DEFAULT_ITEM));
		
		self:WriteLog("参与副本情况",string.format("%s,金丝令牌,%s,%d", pPlayer.szName,tbTreasure.szName, nTreasureLevel));
		return 1;
	end	]]--
	return 0;	
end

--星级难度
--[[
function TreasureMap2:CheckPlayerInstanceLevel(pPlayer, nTreasureId, nTreasureLevel)
	local tbTreasure = self:GetTreasure(nTreasureId);
	if pPlayer.GetTask(tbTreasure.nTskGroupId,tbTreasure.nTskInstanceLevelId) < (nTreasureLevel - 1) then
		return 0;
	end
	
	return 1;
end

function TreasureMap2:SetPlayerInstanceLevel(pPlayer, nTreasureId, nTreasureLevel)
	local tbTreasure = self:GetTreasure(nTreasureId);
	pPlayer.SetTask(tbTreasure.nTskGroupId,tbTreasure.nTskInstanceLevelId, nTreasureLevel);
end
--]]
function TreasureMap2:CheckPlayer(nPlayerId, nMapId, nTreasureId, nTreasureLevel)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	local tbTreasure = self:GetTreasure(nTreasureId);
	if not pPlayer or pPlayer.nMapId ~= nMapId then
		return 0, "Không ở gần đây";
	end
	
	if pPlayer.nTeamId <= 0 then
		return 0, "Không có tổ đội";
	end
	
	if pPlayer.nLevel < tbTreasure.tbInstanceInfo[nTreasureLevel].nRequirePlayerLevel then
		return 0, "Đẳng cấp không đủ";
	end
	
	if pPlayer.GetCamp() == 0 then
		return 0, "Không có môn phái";
	end
	
	if self:CheckPlayerTimes(pPlayer) == 0 then
		return 0, "Quá nhiều người tham gia";
	end
	
	if self:CheckPlayerItem(pPlayer, nTreasureId, nTreasureLevel) == 0 then
		return -1, "Hết lượt";
	end
	
--	if self:CheckPlayerInstanceLevel(pPlayer, nTreasureId, nTreasureLevel) == 0 then
--		return 0, "星级不够";
--	end
	
	return 1;
end


--开启界面
function TreasureMap2:OpenSingleUi(pPlayer, szMsg, nMapFrameTime, nLastFrameTime)
	if nLastFrameTime then
		nLastFrameTime = nLastFrameTime * Env.GAME_FPS;
	end
	
	if nMapFrameTime then
		nMapFrameTime = nMapFrameTime * Env.GAME_FPS;
	end
	
	Dialog:SetBattleTimer(pPlayer,  szMsg, nMapFrameTime, nLastFrameTime);
	Dialog:ShowBattleMsg(pPlayer,  1,  0); --开启界面
end

--关闭界面
function TreasureMap2:CloseSingleUi(pPlayer)
	Dialog:ShowBattleMsg(pPlayer,  0,  0); -- 关闭界面
end

--更新界面时间
function TreasureMap2:UpdateTimeUi(pPlayer, szMsg, nMapFrameTime, nLastFrameTime)
	if nLastFrameTime then
		nLastFrameTime = nLastFrameTime * Env.GAME_FPS;
	end
	
	if nMapFrameTime then
		nMapFrameTime = nMapFrameTime * Env.GAME_FPS;
	end	
	
	
	Dialog:SetBattleTimer(pPlayer,  szMsg, nMapFrameTime, nLastFrameTime);
end

--更新界面信息
function TreasureMap2:UpdateMsgUi(pPlayer, szMsg)
	Dialog:SendBattleMsg(pPlayer, szMsg);
end


function TreasureMap2:MapInit(nTreasureId, nTreasureLevel,nMapId,nPlayerId, bNewMap)
	ClearMapNpc(nMapId);
	ClearMapObj(nMapId);
	local tbTreasure = self:GetTreasure(nTreasureId);
	local tbNpcInfo  = tbTreasure.tbInstanceInfo[nTreasureLevel];
	if not tbNpcInfo or (not tbNpcInfo.tbNpcInfo) then
		print("[ERR] TreasureMap2:MapInit", nTreasureId, nTreasureLevel);
		assert(false);
	end
	
	-- 刷NPC
	for _, tbInstanceNpc in ipairs(tbNpcInfo.tbNpcInfo) do
		if tbInstanceNpc.nNpcCount ~= #tbInstanceNpc.tbNpcPos then --一样的话 没有打乱的必要
			Lib:SmashTable(tbInstanceNpc.tbNpcPos);   --打乱
		end	
			
		for i = 1, tbInstanceNpc.nNpcCount do
			local nIndex = i%(#tbInstanceNpc.tbNpcPos);
			if nIndex == 0 then
				nIndex = #tbInstanceNpc.tbNpcPos;
			end
			local pNpc  = KNpc.Add2(tbInstanceNpc.nTemplateId, tbInstanceNpc.nNpcLevel, -1, nMapId, 
				tbInstanceNpc.tbNpcPos[nIndex][1], tbInstanceNpc.tbNpcPos[nIndex][2]);	
				
			if pNpc then	
				pNpc.GetTempTable("TreasureMap2").nCaptainId = nPlayerId;	
				--print(">>>>>>>>addnpc,>>>",nMapId, tbInstanceNpc.nTemplateId,tbInstanceNpc.tbNpcPos[nIndex][1], tbInstanceNpc.tbNpcPos[nIndex][2]);
				pNpc.GetTempTable("TreasureMap2").nNpcScore = tbInstanceNpc.nNpcScore;
				pNpc.szName = tbInstanceNpc.szName;
			end
		end
	end
	
	-- 刷TRAP
	if bNewMap and bNewMap == 1 then
		for szClassName,tbTrapPoint  in pairs(tbTreasure.tbTrapInfo) do
			for _, tbPoint in ipairs(tbTrapPoint) do
				AddMapTrap(nMapId, tbPoint[1] * 32, tbPoint[2] * 32, szClassName);
			end
		end		
	end
	
end

function TreasureMap2:AddInstanceScore(tbInstancing, nScore)
	if not tbInstancing or not nScore or nScore == 0 then
		return;
	end
	
	tbInstancing.tbInstance.nScore	= tbInstancing.tbInstance.nScore + nScore;
	tbInstancing:UpdateMsgUI();	
end

function TreasureMap2:AddKillNpcNum(tbInstancing)
	tbInstancing.tbInstance.nKillNpc	= tbInstancing.tbInstance.nKillNpc + 1;	
--	TreasureMap2:AddInstanceScore(tbInstancing, nScore);
end

function TreasureMap2:AddKillBossNum(tbInstancing)	
	tbInstancing.tbInstance.nKillBoss	= tbInstancing.tbInstance.nKillBoss + 1;
end

function TreasureMap2:GetWeakPercent(pPlayer,nTreasureId, nCurTreasureLevel)	
	local tbTreasure = self:GetTreasure(nTreasureId);
	local nTreasureSuitLevel = 0;
	
	for nTreasureLevel, tbInstanceInfo in ipairs(tbTreasure.tbInstanceInfo) do
		if pPlayer.nLevel < tbInstanceInfo.nRequirePlayerLevel then
			nTreasureSuitLevel = nTreasureLevel - 1;
			break;
		end		
	end
	
	local nWeak = TreasureMap2.WEAK_RATE[nTreasureSuitLevel - nCurTreasureLevel];
	nWeak = nWeak or 100;
	return nWeak; 	
end


function TreasureMap2:GetAwardLevel(pPlayer,nTreasureId,nTreasureLevel)
	local tbTreasure = self:GetTreasure(nTreasureId);
	local tbAward = tbTreasure.tbInstanceInfo[nTreasureLevel].tbAward;
	
	local nLevel = 1;
	for nAwardLevel, tbInfo in ipairs(tbAward) do
		if pPlayer.nLevel >= tbInfo.nPlayerLevel then
			nLevel = nAwardLevel;
		else
			break;
		end
	end
	
	return nLevel; 	
end

function TreasureMap2:GetPlayerAwardInfo(nAwardLevel,nGrade,nTreasureId,nTreasureLevel)
	local tbTreasure = self:GetTreasure(nTreasureId);
	local tbAward = tbTreasure.tbInstanceInfo[nTreasureLevel].tbAward[nAwardLevel];
	local tbPlayerAward = {};
	tbPlayerAward.tbItem = tbAward.tbItem;
	tbPlayerAward.nCount = 	tbAward.tbLevelAward[nGrade];
	return tbPlayerAward; 		
end

function TreasureMap2:GetPresentLingPaiLevel(pPlayer)
	local nPlayerLevel = pPlayer.nLevel;
	local nLingpaiLevel = 0;
	for nIndex, nLevel in ipairs(self.LINGPAI_PRESENT_LEVEL) do
		if nPlayerLevel >= nLevel then
			nLingpaiLevel = nIndex;
		else
			break;
		end
	end
	return nLingpaiLevel;
end

function TreasureMap2:GetWabaoLingPaiLevel(pPlayer)
	local nPlayerLevel = pPlayer.nLevel;
	local nLingpaiLevel = 0;
	for nIndex, nLevel in ipairs(self.LINGPAI_WABAO_LEVEL) do
		if nPlayerLevel >= nLevel then
			nLingpaiLevel = nIndex;
		else
			break;
		end
	end
	return nLingpaiLevel;
end

function TreasureMap2:WriteLog(szType,szMsg)
	Dbg:WriteLogEx(Dbg.LOG_INFO, "TheTreasureMap", szType, szMsg);
end

function TreasureMap2:AwardLog(nTreasureId,nTreasureLevel,szPlayerName,szItemName,nItemCount)		
	local tbTreasure = self:GetTreasure(nTreasureId);
	self:WriteLog("奖励获得",string.format("%s,%s,%s,%d",szPlayerName,tbTreasure.szName, szItemName,nItemCount));
end

