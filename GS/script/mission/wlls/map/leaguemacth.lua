--武林联赛会场，准备场，比赛场
--
--会场
Wlls.WAIT_TO_MAP =
{
	1401,
	1437,
	-- {1401, 1412},
	-- {1437, 1448},
}


--准备场
Wlls.MACTH_TO_MAP = 
{
	1413,
	1449,
	-- 1413,1414,1415,1416,1417,1418,1419,1420,1421,1422,1423,1424,2264,
	-- 1449,1450,1451,1452,1453,1454,1455,1456,1457,1458,1459,1460,2267,
}

--比赛场
Wlls.MACTHPK_TO_MAP = 
{
	1425,
	1461,
	1473,
	1485,
	-- 1425,1426,1427,1428,1429,1430,1431,1432,1433,1434,1435,1436,2265,
	-- 1461,1462,1463,1464,1465,1466,1467,1468,1469,1470,1471,1472,2268,
	-- 1473,1474,1475,1476,1477,1478,1479,1480,1481,1482,1483,1484,2269,
	-- 1485,1486,1487,1488,1489,1490,1491,1492,1493,1494,1495,1496,2270,
	-- {1508,1531},
}

if (GLOBAL_AGENT) then
Wlls.WAIT_TO_MAP =
{
	1893,
	1929,
	-- {1893, 1904},
	-- {1929, 1940},
}


--准备场
Wlls.MACTH_TO_MAP = 
{
	1905,
	1941,
	-- 1905,1906,1907,1908,1909,1910,1911,1912,1913,1914,1915,1916,2274,
	-- 1941,1942,1943,1944,1945,1946,1947,1948,1949,1950,1951,1952,2279,
}

--比赛场
Wlls.MACTHPK_TO_MAP = 
{
	1917,
	1953,
	1965,
	1977,
	-- 1917,1918,1919,1920,1921,1922,1923,1924,1925,1926,1927,1928,2275,
	-- 1953,1954,1955,1956,1957,1958,1959,1960,1961,1962,1963,1964,2277,
	-- 1965,1966,1967,1968,1969,1970,1971,1972,1973,1974,1975,1976,2280,
	-- 1977,1978,1979,1980,1981,1982,1983,1984,1985,1986,1987,1988,2282,
	-- {1989,2012},
}
end

local tbWaitMap = {};
local tbMap = {};
local tbMapPk = {};

function tbWaitMap:OnEnter()
	Wlls.WaitMapMemList[me.nId] = 1;
	local nUsefulTime = 1 * 3600 * 18;
	local szLeagueName = League:GetMemberLeague(Wlls.LGTYPE, me.szName);
	me.SetLogoutRV(1);
	if szLeagueName then
		local nMacthLevel = League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_MLEVEL);
		local nReadyId = Wlls:GetMacthMapSeriesId(nMacthLevel, me.nMapId, 1);
		Wlls:SyncAdvMatchUiSingle(me, nReadyId, nUsefulTime);
	end
end

function tbWaitMap:OnLeave()
	Wlls.WaitMapMemList[me.nId] = nil;
	Wlls:SyncAdvMatchUiSingle(me, 1, 0);
end


-- 定义玩家进入事件
function tbMap:OnEnter()
	Wlls.MACTH_ENTER_FLAG[me.nId] = 0;
	local szLeagueName = League:GetMemberLeague(Wlls.LGTYPE, me.szName);
	if not szLeagueName then
		Wlls:KickPlayer(me, "Không có chiến đội.", 1);
		return
	end
	local nReadyId = League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_ATTEND);
	local nGameLevel = League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_MLEVEL);	
	if Wlls.ReadyTimerId <= 0 or nGameLevel == 0 then
		if nGameLevel == 0 then
			nGameLevel = 1;
		end
		Wlls:KickPlayer(me, "Trận đấu đã bắt đầu", nGameLevel)
		return
	end
	Wlls:SetStateJoinIn(1);
	me.SetFightState(0);	  	--设置战斗状态
	Wlls:AddGroupMember(nGameLevel, nReadyId, szLeagueName, me.nId, me.szName);
	local nLastFrameTime = tonumber(Timer:GetRestTime(Wlls.ReadyTimerId));
	local szMsg = "<color=green>Thời gian còn lại: <color=white>%s<color>";
	Wlls:OpenSingleUi(me, szMsg, nLastFrameTime);
	Wlls:UpdateAllMsgUi(nGameLevel, nReadyId, szLeagueName);
	Dialog:SendBlackBoardMsg(me, "Bước vào khu chuẩn bị, khi thời gian kết thúc, sẽ tự động bắt đầu.")
	me.Msg("Bước vào khu chuẩn bị, <color=yellow>sau khi thời gian kết thúc<color>, bạn sẽ <color=yellow>tự tham chiến<color>.");
	local nUsefulTime = 15 * 60 * 18;
	Wlls:SyncAdvMatchUiSingle(me, nReadyId, nUsefulTime)
	Wlls:WriteLog(string.format("Nguoi choi %s vao: %s", nReadyId, me.nMapId), me.nId);
	
	--成就	
	local tbAchievement = Wlls.tbAchievementAttend;
	local nMacthType = Wlls:GetMacthType();
	if (not GLOBAL_AGENT) then
		if tbAchievement[nMacthType] then
			Achievement:FinishAchievement(me, tbAchievement[nMacthType]);
		end
	end
	--成就
end

-- 定义玩家离开事件
function tbMap:OnLeave()
	if Wlls.MACTH_ENTER_FLAG[me.nId] == 1 then
		Wlls.MACTH_ENTER_FLAG[me.nId] = nil;
		return 0;
	end
	Wlls:LeaveGame();
	local szLeagueName = League:GetMemberLeague(Wlls.LGTYPE, me.szName);
	if not szLeagueName then
		return 0;
	end
	local nReadyId = League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_ATTEND);
	local nGameLevel = League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_MLEVEL);
	if nReadyId <= 0 or nGameLevel <= 0 then
		return 0
	end
	--if Wlls.GameState == 1 then
	Wlls:DelGroupMember(nGameLevel, nReadyId, szLeagueName, me.nId);
	Wlls:CloseSingleUi(me)
	Wlls:UpdateAllMsgUi(nGameLevel, nReadyId, szLeagueName);
	Wlls:SyncAdvMatchUiSingle(me, nReadyId, 0)
	--end
end

function tbMapPk:OnLeave()
	local szLeagueName = League:GetMemberLeague(Wlls.LGTYPE, me.szName);
	if not szLeagueName then
		return 0;
	end	
	local nReadyId = League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_ATTEND);	
	local nGameLevel = League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_MLEVEL);
	if nReadyId <=0 or not Wlls.MissionList[nGameLevel] or not Wlls.MissionList[nGameLevel][nReadyId] or Wlls.MissionList[nGameLevel][nReadyId]:IsOpen() ~= 1 then
		return 0;
	end
	if Wlls.MissionList[nGameLevel][nReadyId]:GetPlayerGroupId(me) >= 0 then
		Wlls.MissionList[nGameLevel][nReadyId]:KickGame(me);
	end
end

for _, varMap in pairs(Wlls.WAIT_TO_MAP) do
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

for _, varMap in pairs(Wlls.MACTH_TO_MAP) do
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

for _, varMap in pairs(Wlls.MACTHPK_TO_MAP) do
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
