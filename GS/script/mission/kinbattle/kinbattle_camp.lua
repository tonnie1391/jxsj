-------------------------------------------------------
-- 文件名　：kinbattle_player.lua
-- 创建者　：huangxiaoming
-- 创建时间：2010-12-7 13:27:20
-- 文件描述：
-------------------------------------------------------
if not MODULE_GAMESERVER then
	return 0;
end

local tbCamp = KinBattle.tbCamp or {};
KinBattle.tbCamp = tbCamp;

function tbCamp:init(nCampId, nKinId, szKinName, nCampIdMate, nKinIdMate, szKinNameMate, tbMission)
	self.nCampId 			= nCampId;
	self.nKinId				= nKinId;
	self.szKinName			= szKinName;
	self.nCampIdMate 		= nCampIdMate;
	self.nKinIdMate			= nKinIdMate;
	self.szKinNameMate		= szKinNameMate;
	self.tbMission			= tbMission;
	self.tbFirstPromt		= {};
	self.nPlayerCount		= 0;
	self.nKillCount 		= 0;
	self.nBeKillCount		= 0;
	self.nBouns 			= 0;
	self.nJiuZhuanCount 	= 0;
	self.tbBattleSaveData	= {};
end

-- 本方有玩家加入
function tbCamp:OnJoin(pPlayer)
	local tbPlayerInfo = self:FindPlayerInfo(pPlayer);
	if not tbPlayerInfo then
		tbPlayerInfo = Lib:NewClass(KinBattle.tbPlayer, pPlayer, self);
	else
		tbPlayerInfo.pPlayer = pPlayer;
	end
	tbPlayerInfo.nBackTime = GetTime();
	pPlayer.GetTempTable("Mission").tbKinBattlePlayerInfo = tbPlayerInfo; --临时保存玩家数据
	local nRemainFrame = self.tbMission:GetStateLastTime();
	local nState = self.tbMission:GetGameState();
	tbPlayerInfo:SetRightBattleInfo(nRemainFrame, nState);
	self:SetPlayerCount(self.nPlayerCount + 1);
end

--本方有玩家离开
function tbCamp:OnLeave(pPlayer)
	self:SetPlayerCount(self.nPlayerCount - 1);
	local tbPlayerInfo = KinBattle:GetPlayerInfo(pPlayer);
	if tbPlayerInfo then
		tbPlayerInfo:DeleteRightBattleInfo();
	end
	self:SavePlayerData(pPlayer);
end

--保存玩家的战场信息
function tbCamp:SavePlayerData(pPlayer)
	local tbPlayerInfo = KinBattle:GetPlayerInfo(pPlayer);
	if not tbPlayerInfo then
		return;
	end
	local nPlayerId = pPlayer.nId;
	self.tbBattleSaveData[nPlayerId] = tbPlayerInfo;
	self.tbBattleSaveData[nPlayerId].pPlayer = nil;
	pPlayer.GetTempTable("Mission").tbKinBattlePlayerInfo = nil;
end

--设置本方人数
function tbCamp:SetPlayerCount(nPlayerCount)
	self.nPlayerCount = nPlayerCount;
	local tbAllPlayer = self.tbMission:GetPlayerList();
	for _, pPlayer in pairs(tbAllPlayer) do 
		local tbPlayerInfo = KinBattle:GetPlayerInfo(pPlayer);
		if tbPlayerInfo then
			tbPlayerInfo:ShowPlayerCount();
		end
	end
end

--搜索战场中的玩家信息
function tbCamp:FindPlayerInfo(pPlayer)
	local tbPlayerInfo 	= nil;
	local nId 			= pPlayer.nId;
	for nPlayerId, tbTempPlayerInfo in pairs(self.tbBattleSaveData) do
		if nPlayerId == nId then
			tbPlayerInfo = tbTempPlayerInfo;
			break;
		end
	end
	return tbPlayerInfo;
end

--传送到战场
function tbCamp:TransToBattle(pPlayer, nIndex)
	local nMissionId = self.tbMission.nMissionId;
	local nMapType = self.tbMission.nMapType;
	local nMapId = KinBattle.MAP_LIST[nMissionId][1];
	-- 保护时间
	Player:AddProtectedState(pPlayer, KinBattle.SUPER_TIME);
	local tbPlayerInfo = KinBattle:GetPlayerInfo(pPlayer);
	tbPlayerInfo.nMissionFlag = 1;
	tbPlayerInfo:UpdateMatchTimes();
	pPlayer.NewWorld(nMapId, KinBattle.MAP_ENTER_POS[nMapType][nIndex][1], KinBattle.MAP_ENTER_POS[nMapType][nIndex][2]);
end

--传送到安全区
function tbCamp:TransToPrepare(pPlayer)
	local nMissionId = self.tbMission.nMissionId;
	local nCampId = self.nCampId;
	local nMapId = KinBattle.MAP_LIST[nMissionId][nCampId + 1];
	local tbPlayerInfo = KinBattle:GetPlayerInfo(pPlayer);
	pPlayer.NewWorld(nMapId, KinBattle.PREPARE_POS[1], KinBattle.PREPARE_POS[2]);
end
