--竞技类(GS，GC使用)
--孙多良
--2008.12.25

function Esport:CheckState(nState)
	if not nState then
		nState = 2;
	end
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	if nCurDate >= self.SNOWFIGHT_STATE[1] and nCurDate < self.SNOWFIGHT_STATE[nState] then
		return 1;
	end
	return 0;
end

function Esport:OnInit()
	--local nOnLoadMap = 0;
	for _,nMapId in pairs(self.DEF_READY_MAP) do
		self.tbGroupLists[nMapId] = {};
		self.tbGroupLists[nMapId].tbGroupList = {};
		self.tbGroupLists[nMapId].nPlayerMax = 0;
		if MODULE_GAMESERVER then
			if SubWorldID2Idx(nMapId) > 0 then
				Esport:ApplyDyMap(nMapId);
				--nOnLoadMap = 1;
			end
		end
	end
	self.tbPlayerLists = {};
	self.tbMissionLists = self.tbMissionLists or {};	--初始化，重用mission
end

--报名时间开始
function Esport:StartSignUp()
	if self.nReadyTimerId > 0 then
		Timer:Close(self.nReadyTimerId);
		self.nReadyTimerId = 0;
		if MODULE_GAMESERVER then
			
		local nLeaveMapId, nLeavePosX, nLeavePosY = Esport:GetLeavePos();
		for _,nMapId in pairs(self.DEF_READY_MAP) do
			if SubWorldID2Idx(nMapId) > 0 and self.tbGroupLists[nMapId] then
				for _, tbGroup in pairs(self.tbGroupLists[nMapId].tbGroupList) do
					for _, nPlayerId in pairs(tbGroup) do
						local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
						if pPlayer then
							pPlayer.NewWorld(nLeaveMapId, nLeavePosX, nLeavePosY);
						end
					end
				end	
			end
		end
		
		end
	end
	self.tbMissionLists = {};	--安全性，暂时不重用
	if MODULE_GAMESERVER then
--		for _, tbMapMis in pairs(self.tbMissionLists) do
--			for _, tbMis in pairs(tbMapMis) do
--				--关闭接口
--				if tbMis:IsOpen() == 1 then
--					tbMis:OnEndPlay();
--				end
--			end
--		end
		KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, "新年打雪仗开始接受报名，请50级以上玩家到各新手村的晏若雪处报名参加");
	end	
	self:OnInit();
	self.nReadyState = 0;
	self.nReadyTimerId = Timer:Register(self.DEF_READY_TIME,  self.SportStart,  self);
end

--开始比赛
function Esport:SportStart()
	if self.nReadyState == 0 then
		self.nReadyState = 1;
		if MODULE_GAMESERVER then
			self:OnAllLeaveTeam();
		end
		return self.DEF_READY_TIME2;
	end
	self.nReadyTimerId = 0;
	if MODULE_GAMESERVER then
		self:SportStartLogic();
	end
	return 0;
end

function Esport:OnAllLeaveTeam()
	for nMapId, tbGroup in pairs(self.tbGroupLists) do
		if SubWorldID2Idx(nMapId) > 0 and tbGroup.tbGroupList then
			for _, tbGroupTemp in ipairs(tbGroup.tbGroupList) do
				for _, nPlayerId in pairs(tbGroupTemp) do
					local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
					if pPlayer then
						pPlayer.TeamApplyLeave();		--离开队伍
					end
				end
			end
		end
	end
end

--进入准备场加入名单
function Esport:JoinGroupList(nMapId, tbPlayerList)
	self.tbGroupLists[nMapId].nPlayerMax = self.tbGroupLists[nMapId].nPlayerMax + #tbPlayerList;	
	table.insert(self.tbGroupLists[nMapId].tbGroupList, {});
	local nGId = #self.tbGroupLists[nMapId].tbGroupList;
	for nId, nPlayerId in pairs(tbPlayerList) do
		local nCaptain = 0;
		if nId == 1 then
			nCaptain = 1;
		end 
		self.tbPlayerLists[nPlayerId] = {nMapId, nGId, 0, nCaptain};
	end
end

function Esport:OnJoinReady(nPlayerId)
	if not self.tbPlayerLists[nPlayerId] then
		return 0;
	end
	local nCaptain = self.tbPlayerLists[nPlayerId][4];
	local nGId = self.tbPlayerLists[nPlayerId][2];
	local nMapId = self.tbPlayerLists[nPlayerId][1];
	
	if nCaptain == 1 then
		table.insert(self.tbGroupLists[nMapId].tbGroupList[nGId], 1, nPlayerId);
	else
		table.insert(self.tbGroupLists[nMapId].tbGroupList[nGId], nPlayerId);
	end
end

--离开准备场删除名单
function Esport:LeaveGroupList(nLeaveId)
	if not self.tbPlayerLists[nLeaveId] then
		return 0;
	end
	local nMapId = self.tbPlayerLists[nLeaveId][1];
	local nGId	 = self.tbPlayerLists[nLeaveId][2];
	if not self.tbGroupLists[nMapId] or not self.tbGroupLists[nMapId].tbGroupList[nGId] then
		return 0;
	end
	for nId, nPlayerId in pairs(self.tbGroupLists[nMapId].tbGroupList[nGId]) do
		if nPlayerId == nLeaveId then
			table.remove(self.tbGroupLists[nMapId].tbGroupList[nGId], nId);
			self.tbGroupLists[nMapId].nPlayerMax = self.tbGroupLists[nMapId].nPlayerMax - 1;
			break;
		end
	end
end

--增加荣誉点
function Esport:AddHonor(szName, nHonor)
	if nHonor == 0 then
		return
	end
	if MODULE_GAMESERVER then
		GCExcute{"Esport:AddHonor", szName, nHonor};
		
		--公告
		local nPlayerId = KGCPlayer.GetPlayerIdByName(szName);
		if nPlayerId and nPlayerId > 0 then
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				pPlayer.Msg(string.format("恭喜您获得了<color=yellow>%s点<color>飞絮崖荣誉点", nHonor));
			end
		end
		return 0;
	end
	local nAddHonor = GetPlayerHonorByName(szName, PlayerHonor.HONOR_CLASS_SPRING, 0) + nHonor;
	SetPlayerHonorByName(szName, PlayerHonor.HONOR_CLASS_SPRING, 0, nAddHonor);
end

function Esport:WriteLog(szLog, nPlayerId)
	if nPlayerId then
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
		if (pPlayer) then
			Dbg:WriteLog("Esport", "新年雪仗", pPlayer.szAccount, pPlayer.szName, szLog);
			return 1;
		end
	end
	Dbg:WriteLog("Esport","新年雪仗", szLog);
end
