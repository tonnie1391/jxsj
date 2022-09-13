-- 文件名　：plantform_control_gs.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-09-20 20:54:26
-- 功能    ：无差别竞技

if (MODULE_GC_SERVER) then
	return 0;
end

--比赛结束
function NewEPlatForm:GameOver()
	if self.ReadyTimerId > 0 then
		if Timer:GetRestTime(self.ReadyTimerId) > 0 then
			Timer:Close(self.ReadyTimerId);
			self.ReadyTimerId = 0;
		end		
	end
	self:CloseMission();
end

--关闭准备场时间计时
function NewEPlatForm:CloseGameTimer()
	self.ReadyTimerId = 0;
	return 0;
end

--初始化数据
function NewEPlatForm:InitDate()
	self:GameOver();
	local tbMacthLevelCfg2 = self:GetMacthTypeCfg(self:GetMacthType());
	for nReadyId, nMapId in pairs(tbMacthLevelCfg2.tbReadyMap) do
		if not self.GroupList[nReadyId] then
			self.GroupList[nReadyId] = {};
		end
		for _, tbPlayerList in pairs(self.GroupList[nReadyId]) do
			local nLeaveId = nil;
			for _, nPlayerId in pairs(tbPlayerList) do
				local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
				if pPlayer then
					nLeaveId = self:KickPlayer(pPlayer, "Sai quy trình!!!", nLeaveId);
				end
			end
		end
		self.GroupList[nReadyId] = {};
	end
end

--准备场启动开始
function NewEPlatForm:GameStart()
	local tbMacthLevelCfg = self:GetMacthTypeCfg(self:GetMacthType());
	local szMsg = string.format("Hoạt động gia tộc [%s] bắt đầu báo danh, đến tìm [Án Nhược Tuyết] tại các Tân Thủ Thôn", tbMacthLevelCfg.szName);
	KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, szMsg);
	Dialog:GlobalMsg2SubWorld_GS(szMsg);
	self:ApplyDynMatchMap();
	self.ReadyTimerId = Timer:Register(self.MACTH_TIME_READY,  self.CloseGameTimer,  self);
	self.nMatchTaskId	= 0;
	self.GameState = 1;
end

function NewEPlatForm:ApplyDynMatchMap()
	local tbMacthLevelCfg = self:GetMacthTypeCfg(self:GetMacthType());
	for nReadyId, nMapId in pairs(tbMacthLevelCfg.tbReadyMap) do
		if SubWorldID2Idx(nMapId) >= 0 then
			local nDynCount = math.ceil((self.nCurReadyMaxCount or 0) / self.nCurMatchMaxTeamCount);
			local nDynTempMapId = tbMacthLevelCfg.tbMacthMap[1];
			if (not tbMacthLevelCfg.tbDynMapLists[nReadyId]) then
				tbMacthLevelCfg.tbDynMapLists[nReadyId] = {};
			end
			local nCurCount = #tbMacthLevelCfg.tbDynMapLists[nReadyId];
			if nCurCount < nDynCount then
				for i=1, (nDynCount - nCurCount) do
					if (Map:LoadDynMap(1, nDynTempMapId, {self.OnLoadMapFinish, self, nMapId}) ~= 1) then
						print("无差别竞技平台地图加载失败。。", nDynTempMapId, nMapId);
					end
				end
			end
		end
	end
end

--比赛地图动态加载成功
function NewEPlatForm:OnLoadMapFinish(nMapId, nDyMapId)
	local tbMacthCfg = self:GetMacthTypeCfg(self:GetMacthType());
	if (not tbMacthCfg) then
		print("OnLoadMapFinish not tbMacthCfg  Error !!!!!!!!!!!!!!");
		return;
	end
	local nReadyId = self:GetReadyIdByMapId(nMapId);
	if (nReadyId <= 0) then
		return;
	end
	tbMacthCfg.tbDynMapLists[nReadyId] = tbMacthCfg.tbDynMapLists[nReadyId] or {};
	table.insert(tbMacthCfg.tbDynMapLists[nReadyId], nDyMapId);	
end

function NewEPlatForm:GetReadyIdByMapId(nCurMapId)
	local tbMacthCfg = self:GetMacthTypeCfg(self:GetMacthType());
	for nReadyId, nMapId in pairs(tbMacthCfg.tbReadyMap) do
		if (nCurMapId == nMapId) then
			return nReadyId;
		end
	end
	return 0;
end

--比赛场开始
function NewEPlatForm:GamePkStart()
	self.GameState = 2;
	local tbMacthLevelCfg = self:GetMacthTypeCfg(self:GetMacthType());
	local szMsg = string.format("Hoạt động gia tộc [%s] đã bắt đầu, hãy chuẩn bị", tbMacthLevelCfg.szName);
	KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, szMsg);
	Dialog:GlobalMsg2SubWorld_GS(szMsg);
	self.nMatchTaskId = 0;
	self:OpenMission();
	self:EnterPkMapRule();
	self:StartGame();
	self:ClearReadyMap();
end

function NewEPlatForm:StartGame()	
	local tbMacthLevelCfg = self:GetMacthTypeCfg(self:GetMacthType());
	if (not tbMacthLevelCfg or not tbMacthLevelCfg.tbDynMapLists) then
		return 0;
	end
	for nReadyId, tbMapId in pairs(tbMacthLevelCfg.tbDynMapLists) do
		local nReadyMapId = tbMacthLevelCfg.tbReadyMap[nReadyId];
		for nId, nMapId in pairs(tbMapId) do
			if self.MissionList[nReadyId] then
				local tbMission = self.MissionList[nReadyId][nId];				
				if (tbMission and tbMission:IsOpen() ~= 0) then
					local nCount = tbMission:GetGroupCount() or 0;					
					if (nCount > 0) then
						tbMission:StartGame();
					else
						tbMission:CloseGame();
					end
				end
			end
		end
	end
end

--开启比赛场mission
function NewEPlatForm:OpenMission()
	local tbMacthLevelCfg = self:GetMacthTypeCfg(self:GetMacthType());
	local szBaseMission = tbMacthLevelCfg.tbMacthCfg.szBaseMission;
	local fnFunc, tbSelf	= KLib.GetValByStr(szBaseMission);	
	if (not tbMacthLevelCfg or not tbMacthLevelCfg.tbDynMapLists) then
		return 0;
	end
	for nReadyId, tbMapId in pairs(tbMacthLevelCfg.tbDynMapLists) do
		local nReadyMapId = tbMacthLevelCfg.tbReadyMap[nReadyId];
		if SubWorldID2Idx(nReadyMapId) >= 0 then
			for nId, nMapId in pairs(tbMapId) do
				if SubWorldID2Idx(nMapId) >= 0 then
					if not self.MissionList[nReadyId] then 
						self.MissionList[nReadyId] = {};
					end

					local tbEnterPos = {};
					for _, tbPos in pairs (tbMacthLevelCfg.tbPkPos) do
						tbEnterPos[#tbEnterPos + 1]	= {nMapId, tbPos[1], tbPos[2]};
					end

					local nLeaveMap, nLX, nLY = self:GetLeaveMapPos();
					local tbLeavePos	= {nLeaveMap, nLX, nLY};					
					
					--每次切换的时候需要重新new新的mission
					if not self.MissionList[nReadyId][nId] or self.nCurEventType ~= self:GetMacthSession() then
						self.MissionList[nReadyId][nId] = fnFunc(tbSelf);
					end
					
					if (self.MissionList[nReadyId][nId]) then						
						self.MissionList[nReadyId][nId]:OpenMission(tbEnterPos, tbLeavePos, 2, nReadyId);
					else
						self:WriteLog("OpenMission failed! ", nMapId, nReadyMapId);
					end
				end
			end
		end
	end
	if self.nCurEventType ~= self:GetMacthSession() then
		self.nCurEventType = self:GetMacthSession();
	end
end

--关闭比赛场mission
function NewEPlatForm:CloseMission()
	if not self.MissionList then
		self.MissionList = {};
	end
	for nReadyId, tbMissions in pairs(self.MissionList) do
		for nId, tbMission in pairs(tbMissions) do
			if tbMission:IsOpen() ~= 0 then
				tbMission:CloseGame();
			end
		end
	end
end

--开启界面
function NewEPlatForm:OpenSingleUi(pPlayer, szMsg, nLastFrameTime)
	if not pPlayer or pPlayer == 0 then
		return 0;
	end
	Dialog:SetBattleTimer(pPlayer,  szMsg, nLastFrameTime);
	Dialog:ShowBattleMsg(pPlayer,  1,  0); --开启界面
end

--关闭界面
function NewEPlatForm:CloseSingleUi(pPlayer)
	if not pPlayer or pPlayer == 0 then
		return 0;
	end
	Dialog:ShowBattleMsg(pPlayer,  0,  0); -- 关闭界面
end

--更新界面时间
function NewEPlatForm:UpdateTimeUi(pPlayer, szMsg, nLastFrameTime)
	if not pPlayer or pPlayer == 0 then
		return 0;
	end
	Dialog:SetBattleTimer(pPlayer,  szMsg, nLastFrameTime);
end

--更新界面信息
function NewEPlatForm:UpdateMsgUi(pPlayer, szMsg)
	if not pPlayer or pPlayer == 0 then
		return 0;
	end
	Dialog:SendBattleMsg(pPlayer, szMsg, 1);
end

--提示准备场已满
function NewEPlatForm:MapStateFull(tbPlayerId)
	for _, nPlayerId in ipairs(tbPlayerId) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			pPlayer.Msg("Số người tham gia đã đầy.");
			Dialog:SendBlackBoardMsg(pPlayer, "Số người tham gia đã đầy.");
		end
	end
end

--玩家进入准备场
function NewEPlatForm:EnterReadyMap(tbPlayerId, szLeagueName, nReadyId)
	for _, nPlayerId in ipairs(tbPlayerId) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			pPlayer.GetTempTable("NewEPlatForm").szLeagueName = szLeagueName;
			local tbMacthLevelCfg = self:GetMacthTypeCfg(self:GetMacthType());
			pPlayer.SetTask(self.TASKID_GROUP, self.TASKID_ENTER_READY, nReadyId);
			pPlayer.SetTaskStr(self.TASKID_GROUP, self.TASKID_LEAGUENAME, szLeagueName);
			local tbPos = tbMacthLevelCfg.tbReadyPos[MathRandom(1, #tbMacthLevelCfg.tbReadyPos)];		
			pPlayer.NewWorld(tbMacthLevelCfg.tbReadyMap[nReadyId], unpack(tbPos));
		end
	end
end

--把玩家踢到会场
function NewEPlatForm:KickPlayer(pPlayer, szMsg, nLeaveId)
	if (not pPlayer) then
		return 0;
	end
	
	if szMsg then
		pPlayer.Msg(szMsg);
	end
	-- 传回当前服务器的新手村
	if nLeaveId then
		pPlayer.NewWorld(self:GetLeaveMapPos());
	else
		nLeaveId = pPlayer.NewWorld(self:GetLeaveMapPos());
	end
	
	return nLeaveId;
end

-- 过界要清
function NewEPlatForm:ClearMissionList()
	self.MissionList = {};
end

function NewEPlatForm:GetLadderPart(nLadderType, nStart, nLength)
	local nMaxList = #self.tbLadderManager;
	local nMaxNum = math.min(math.min(self.MAX_VISIBLE_LADDER, nStart + nLength - 1), nMaxList);
	if nStart > nMaxNum then
		return;
	end
	local tbLadder = {};
	for i = nStart, nMaxNum do
		local szName = "Không biết";
		local nValue = 0;
		if self.tbLadderManager[i] then		--保护
			local cKin = KKin.GetKin(self.tbLadderManager[i][1]);
			if cKin then
				szName = cKin.GetName();
				nValue = self.tbLadderManager[i][2];
			else
				Dbg:WriteLog("NewEPlatForm", "找不到家族", self.tbLadderManager[i][1]);
			end
		end
		local tbInfo = {};
		tbInfo.szPlayerName = szName;
		tbInfo.dwValue = nValue;
		tbLadder[#tbLadder + 1] = tbInfo;
	end
	return tbLadder, nMaxList
end

function NewEPlatForm:GetLadderRankByPlayerName(nLadderType, szName, nSearchType)
	if nSearchType == Ladder.SEARCHTYPE_PLAYERNAME then
		local nPlayerId = KGCPlayer.GetPlayerIdByName(szName);
		if not nPlayerId then
			return -1, szName .. "所在的家族";
		end
		local nKinId = KGCPlayer.GetKinId(nPlayerId);
		if not nKinId or nKinId <= 0 then
			return -1, szName .. "所在的家族";
		end
		local tbInfo = self.tbKinId2Index[nKinId];
		if not tbInfo then
			return -1, szName .. "所在的家族";
		end
		return tbInfo[2];
	elseif nSearchType == Ladder.SEARCHTYPE_KINNAME then
		local nKinId = KKin.GetKinNameId(szName);
		if not nKinId or nKinId <= 0 then
			return -1, szName;
		end
		local tbInfo = self.tbKinId2Index[nKinId];
		if not tbInfo then
			return -1, szName;
		end
		return tbInfo[2];
	end
	return -1, szName;
end

function NewEPlatForm:LoadLadder_GS(tbConnectDate)
	self.tbLadderManager = tbConnectDate;
	self.tbKinId2Index = {};
	for i, tb in ipairs(self.tbLadderManager) do
		self.tbKinId2Index[tb[1]] = {tb[2], i};
	end
end
