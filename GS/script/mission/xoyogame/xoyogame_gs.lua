-- 
-- 逍遥谷关卡 GS逻辑
--
Require("\\script\\mission\\xoyogame\\xoyogame_def.lua");
XoyoGame.BaseManager = {};
XoyoGame.tbNpcLevel = {};
XoyoGame.tbXoyoRank = {};
XoyoGame.tbLastMonthXoyoRank	= {};
XoyoGame.tbXoyoKinRank			= {};
XoyoGame.tbLastMonthXoyoKinRank	= {};
local BaseManager = XoyoGame.BaseManager;

function BaseManager:Init(nMapId, tbData)
	self.nManagerId = nMapId;
	self.tbData = tbData;
end

function XoyoGame:Init()
	self.tbGameIdToManager = {};			-- 地图关卡对象映射表
	self.tbGame = {};
	self.tbManager = {};
	self.tbMap2Game = {};
	self.tbStartTime = {};
	for nManagerId, tbCitySet in pairs(self.MANAGER_GROUP) do
		for _, nDataId in ipairs(tbCitySet) do
			self.tbGameIdToManager[nDataId] = nManagerId;
		end
	end
end

function XoyoGame:OnSyncRankData(tbData)
	self.tbXoyoRank = tbData;
end

function XoyoGame:RecordTime(nDifficuty, nTimeUsed, nTeamId)
	XoyoGame.tbXoyoRank[nDifficuty] = XoyoGame.tbXoyoRank[nDifficuty] or {};
	local tbRank = XoyoGame.tbXoyoRank[nDifficuty];
	local nRank = 0;
	if (#tbRank < XoyoGame.RANK_RECORD) then
		nRank = #tbRank + 1;
	end
	for i = #tbRank, 1, -1 do
		if (tbRank[i].nTime > nTimeUsed) then
			nRank = i;
		end
	end
	if nRank > 0 then
		local tbMember = {};
		local tbList, nCount = KTeam.GetTeamMemberList(nTeamId);
		if nCount == 0 then
			return nRank;
		end
		for nIndex, nPlayerId in pairs(tbList) do
			tbMember[nIndex] = KGCPlayer.GetPlayerName(nPlayerId);
		end
		XoyoGame:RecordRankData(nTimeUsed, nDifficuty, tbMember);
	end
	return nRank;
end

function XoyoGame:CalcTotalTime(nDifficuty, nStartTime, nTeamId)
	local nTimeUsed = GetTime() - nStartTime;
	local szUsed = os.date("%M分%S秒", nTimeUsed);
	local szDesc;
	local szDifficuty = XoyoGame.LevelDesp[nDifficuty][2];
	local nRank = self:RecordTime(nDifficuty, nTimeUsed, nTeamId);
	if nRank > 0 then
		szDesc = string.format("Chúc mừng phá kỷ lục Tiêu Dao Cốc [Độ khó %s], thời gian vượt ải: %s, xếp hạng: %d", szDifficuty, szUsed, nRank);
	else
		szDesc = string.format("Chúc mừng vượt ải Tiêu Dao Cốc [Độ khó %s], thời gian vượt ải: %s", szDifficuty, szUsed);
	end
	local tbMember, nCount = KTeam.GetTeamMemberList(nTeamId);
	if nCount == 0 then
		return;
	end
	for _, nPlayerId in pairs(tbMember) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			pPlayer.CallClientScript({"Ui:ServerCall", "UI_TASKTIPS", "Begin", szDesc});
		end		
	end
end

-- 创建管理对象(回调)
function XoyoGame:CreateManager_GS2(nMapId, tbData)
	if self.tbManager and self.tbManager[nMapId] then
		self.tbManager[nMapId]:Init(nMapId, tbData);
	end
end

-- 同步关卡数据(队伍数)
function XoyoGame:SyncGameData_GS2(nGameId, nData)
	if self.tbGameIdToManager[nGameId] then
		local nManagerId = self.tbGameIdToManager[nGameId]
		if self.tbManager[nManagerId] and self.tbManager[nManagerId].tbData then
			self.tbManager[nManagerId].tbData[nGameId] = nData;
		end
	end
end

-- 队伍减少
function XoyoGame:ReduceTeam_GS2(nGameId)
	if self.tbGameIdToManager[nGameId] then
		local nManagerId = self.tbGameIdToManager[nGameId]
		if self.tbManager[nManagerId] and self.tbManager[nManagerId].tbData and self.tbManager[nManagerId].tbData[nGameId] then
			self.tbManager[nManagerId].tbData[nGameId] = self.tbManager[nManagerId].tbData[nGameId] - 1;
		end
	end
end

-- 创建关卡对象
function XoyoGame:CreatGame()
	--GCExcute({"XoyoGame:ApplySyncData"});
	self:LoadDataBuf();
	local tbNpcLevel = Lib:LoadTabFile(XoyoGame.NPC_LEVEL_FILE);
	for _, tbInfo in pairs(tbNpcLevel) do
		XoyoGame.tbNpcLevel[tonumber(tbInfo.nBase)] = tbInfo;
	end
	
	XoyoGame.nBroadcastTimerId = Timer:Register(Env.GAME_FPS * 30, XoyoGame.BroadcastRank, XoyoGame);
	local tbLoadedCity = {};
	for nManagerMap,_ in pairs(self.MANAGER_GROUP) do
		if IsMapLoaded(nManagerMap) == 1 then
			self.tbManager[nManagerMap] = Lib:NewClass(self.BaseManager);
			GCExcute{"XoyoGame:CreateManager_GC", nManagerMap};
		end
	end
	for nCityMapId, tbIndexMap in pairs(self.MAP_GROUP) do
		if IsMapLoaded(nCityMapId) == 1 and IsMapLoaded(tbIndexMap[1]) == 1 then
			--新加入了6，7，8关卡，每个关卡的地图组是个table，所以进行特殊处理
			local tbMap = {};
			self.tbGame[nCityMapId] = Lib:NewClass(self.BaseGame);
			for _,tbMapIndex in pairs(tbIndexMap) do
				if type(tbMapIndex) == "number" then
					table.insert(tbMap,tbMapIndex)
				elseif type(tbMapIndex) == "table" then
					for _,nMapId in pairs(tbMapIndex) do
						table.insert(tbMap,nMapId)
					end
				end
			end
			self.tbGame[nCityMapId]:InitGame(tbIndexMap, nCityMapId);
			for _, nMapId in pairs(tbMap) do
				self.tbMap2Game[nMapId] = self.tbGame[nCityMapId];
			end
			GCExcute{"XoyoGame:SyncGameData_GC", nCityMapId, 0};
		end
	end
end

function XoyoGame:LoadDataBuf()
	self.tbXoyoRank = GetGblIntBuf(GBLINTBUF_XOYO_RANK, 0) or {};
	self.tbLastMonthXoyoRank = GetGblIntBuf(GBLINTBUF_LAST_MONTH_XOYO_RANK, 0) or {};
	local tbAllXoyoKinRank = GetGblIntBuf(GBLINTBUF_XOYO_KIN_RANK, 0) or {};
	self.tbXoyoKinRank = tbAllXoyoKinRank.tbRank or {};
	self.tbLastMonthXoyoKinRank = tbAllXoyoKinRank.tbLastRank or {};
end
function XoyoGame:GetPlayerRoom(nPlayerId)
	local tbGame = self:GetPlayerGame(nPlayerId);
	if tbGame then
		return tbGame:GetPlayerRoom(nPlayerId);
	end
end

function XoyoGame:GetPlayerGame(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer or not self.tbMap2Game then
		return;
	end
	
	--local nMapId, _, _ = pPlayer.GetWorldPos();
	--local tbGame = self.tbMap2Game[nMapId];
	local tbGame = pPlayer.GetTempTable("XoyoGame").tbGame;
	return tbGame;
end

function XoyoGame:__close()
	for _, tbGame in pairs(self.tbGame) do
		tbGame:CloseGame();
	end
	XoyoGame.BaseGame:CloseGame(); -- TestRoom/TestPKRoom 用
end

function XoyoGame:LockManager()
	for _, tbManager in pairs(self.tbManager) do
		if tbManager.tbData then
			for i, nData in pairs(tbManager.tbData) do
				tbManager.tbData[i] = nil; 
			end
		end
	end
end

function XoyoGame:StartGame_GS2()
	for i, tbGame in pairs(self.tbGame) do
		tbGame:StartNewGame();
	end
end

function XoyoGame:NpcUnLock(pNpc)
	local tbTmp = pNpc.GetTempTable("XoyoGame")
	if not tbTmp then
		return 0;
	end
	if (not tbTmp.tbRoom) or (not tbTmp.nLock) then
		return 0;
	end
	if not tbTmp.tbRoom.tbLock[tbTmp.nLock] then
		return 0;
	end
	tbTmp.tbRoom.tbLock[tbTmp.nLock]:UnLockMulti();
end

function XoyoGame:NpcClearLock(pNpc)
	local tbTmp = pNpc.GetTempTable("XoyoGame")
	if not tbTmp then
		return 0;
	end
	tbTmp.tbRoom = nil;
	tbTmp.nLock = nil;
end

function XoyoGame:IsInLock(pNpc)
	local tbTmp = pNpc.GetTempTable("XoyoGame")
	if not tbTmp then
		return 0;
	end
	if (not tbTmp.tbRoom) or (not tbTmp.nLock) then
		return 0;
	end
	return 1;
end

if MODULE_GAMESERVER then
	XoyoGame:Init();
	ServerEvent:RegisterServerStartFunc(XoyoGame.CreatGame, XoyoGame);
end
