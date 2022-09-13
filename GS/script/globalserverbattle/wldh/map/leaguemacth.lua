--武林大会会场，准备场，比赛场
--
--会场
Wldh.WAIT_TO_MAP =
{
	{1549, 1560},
}


--准备场
Wldh.MACTH_TO_MAP = 
{
	{1561, 1572},
}

--比赛场
Wldh.MACTHPK_TO_MAP = 
{
	{1573, 1608},
}

local tbWaitMap = {};
local tbMap = {};
local tbMapPk = {};

function tbWaitMap:OnEnter()
	me.SetLogoutRV(1);
	local nType = Wldh:GetAttendThisType(me);
	Wldh.WaitMapMemList[me.nId] = 1;
	local nReadyId = Wldh:GetMacthMapSeriesId(nType, me.nMapId)
	local nUsefulTime = 1 * 3600 * 18;
	Wldh:SyncAdvMatchUiSingle(nType, me, nReadyId, nUsefulTime);
end

function tbWaitMap:OnLeave()
	Wldh.WaitMapMemList[me.nId] = nil;
	Wldh:SyncAdvMatchUiSingle(0, me, 0, 0);
end


-- 定义玩家进入事件
function tbMap:OnEnter()
	--Wldh.MACTH_ENTER_FLAG[me.nId] = 0;
	local nType = Wldh:GetAttendThisType(me);
	if nType <= 0 then
		return 0;
	end	
	local nLGType = Wldh:GetLGType(nType);
	local szLeagueName = League:GetMemberLeague(nLGType, me.szName);
	if not szLeagueName then
		Wldh:KickPlayer(me, "Không có chiến đội.", nType);
		return
	end
	
	local nReadyId = League:GetLeagueTask(nLGType, szLeagueName, Wldh.LGTASK_ATTEND);
	if Wldh.tbReadyTimer[nType] <= 0 or nType == 0 then
		if nType == 0 then
			nType = 1;
		end
		Wldh:KickPlayer(me, "Trận đấu đã bắt đầu", nType)
		return
	end
	Wldh:SetStateJoinIn(1);
	me.SetFightState(0);	  	--设置战斗状态
	Wldh:AddGroupMember(nType, nReadyId, szLeagueName, me.nId, me.szName);
	local nLastFrameTime = tonumber(Timer:GetRestTime(Wldh.tbReadyTimer[nType]));
	local szMsg = "<color=green>Thời gian còn lại: <color=white>%s<color>";
	Wldh:OpenSingleUi(me, szMsg, nLastFrameTime);
	Wldh:UpdateAllMsgUi(nType, nReadyId, szLeagueName);
	Dialog:SendBlackBoardMsg(me, "Bước vào khu chuẩn bị, khi thời gian kết thúc, sẽ tự động bắt đầu.")
	me.Msg("Bước vào khu chuẩn bị, <color=yellow>sau khi thời gian kết thúc<color>, bạn sẽ <color=yellow>tự tham chiến<color>.");
	local nUsefulTime = 15 * 60 * 18;
	Wldh:SyncAdvMatchUiSingle(nType, me, nReadyId, nUsefulTime)
	local szLog = string.format("[Tien vao khu chuan bi] chien doi: %s", szLeagueName);
	Wldh:WriteLog(szLog, me.nId);
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, szLog);
end

-- 定义玩家离开事件
function tbMap:OnLeave()
	local nType = Wldh:GetAttendThisType(me);
	if nType <= 0 then
		return 0;
	end	
	local nLGType = Wldh:GetLGType(nType);	
	--if Wldh.MACTH_ENTER_FLAG[me.nId] == 1 then
	--	Wldh.MACTH_ENTER_FLAG[me.nId] = nil;
	--	return 0;
	--end
	Wldh:LeaveGame();
	local szLeagueName = League:GetMemberLeague(nLGType, me.szName);
	if not szLeagueName then
		return 0;
	end
	local nReadyId = League:GetLeagueTask(nLGType, szLeagueName, Wldh.LGTASK_ATTEND);
	if nReadyId <= 0 or nType <= 0 then
		return 0
	end
	Wldh:DelGroupMember(nType, nReadyId, szLeagueName, me.nId);
	Wldh:CloseSingleUi(me)
	Wldh:UpdateAllMsgUi(nType, nReadyId, szLeagueName);
	Wldh:SyncAdvMatchUiSingle(0, me, 0, 0)
end

function tbMapPk:OnLeave()
	local nType = Wldh:GetAttendThisType(me);
	if nType <= 0 then
		return 0;
	end
	local nLGType = Wldh:GetLGType(nType);	
	local szLeagueName = League:GetMemberLeague(nLGType, me.szName);
	if not szLeagueName then
		return 0;
	end	
	local nReadyId = League:GetLeagueTask(nLGType, szLeagueName, Wldh.LGTASK_ATTEND);	
	if nReadyId <=0 or not Wldh.MissionList[nType] or not Wldh.MissionList[nType][nReadyId] or Wldh.MissionList[nType][nReadyId]:IsOpen() ~= 1 then
		return 0;
	end
	if Wldh.MissionList[nType][nReadyId]:GetPlayerGroupId(me) >= 0 then
		Wldh.MissionList[nType][nReadyId]:KickPlayer(me);
	end
end

for _, varMap in pairs(Wldh.WAIT_TO_MAP) do
	if type(varMap) == "table" then
		for nMapId = varMap[1], varMap[2] do
			local tbBattleMap = Map:GetClass(nMapId);
			for szFnc in pairs(tbWaitMap) do
				tbBattleMap[szFnc] = tbWaitMap[szFnc];
			end
		end
	else
		local tbBattleMap = Map:GetClass(varMap);
		for szFnc in pairs(tbWaitMap) do
			tbBattleMap[szFnc] = tbWaitMap[szFnc];
		end
	end
end

for _, varMap in pairs(Wldh.MACTH_TO_MAP) do
	if type(varMap) == "table" then
		for nMapId = varMap[1], varMap[2] do
			local tbBattleMap = Map:GetClass(nMapId);
			for szFnc in pairs(tbMap) do
				tbBattleMap[szFnc] = tbMap[szFnc];
			end
		end
	else
		local tbBattleMap = Map:GetClass(varMap);
		for szFnc in pairs(tbMap) do
			tbBattleMap[szFnc] = tbMap[szFnc];
		end
	end	
end

for _, varMap in pairs(Wldh.MACTHPK_TO_MAP) do
	if type(varMap) == "table" then
		for nMapId = varMap[1], varMap[2] do
			local tbBattleMap = Map:GetClass(nMapId);
			for szFnc in pairs(tbMapPk) do
				tbBattleMap[szFnc] = tbMapPk[szFnc];
			end
		end
	else
		local tbBattleMap = Map:GetClass(varMap);
		for szFnc in pairs(tbMapPk) do
			tbBattleMap[szFnc] = tbMapPk[szFnc];
		end
	end
end
