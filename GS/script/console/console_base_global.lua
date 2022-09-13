-- 文件名　：console_base_global.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-05-06 14:26:51
-- 描  述  ：

Console.Base = Console.Base or {};
local tbBase = Console.Base;

--是否开启,0为开启,1准备阶段,2比赛阶段
function tbBase:IsOpen()
	return self.nState or 0;
end

function tbBase:CheckState()
	local tbEventCfg = self.tbCfg;
	
	if (not tbEventCfg) then
		return 0;
	end
	
	local nStartTime	= tbEventCfg.nEventStartTime;
	local nEndTime		= tbEventCfg.nEventEndTime;

	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	if nCurDate >= nStartTime and nCurDate < nEndTime then
		return 1;
	end
	return 0;
end

function tbBase:CheckAwardState()
	local tbEventCfg = self.tbCfg;
	
	if (not tbEventCfg) then
		return 0;
	end
	
	local nEndTime		= tbEventCfg.nEventEndTime;
	local nEventAwardTime	= tbEventCfg.nEventAwardTime;

	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	if nCurDate > nEndTime and nCurDate <= nEventAwardTime then
		return 1;
	end
	return 0;
end

--判断是否满人,返回可进入的地图Id
function tbBase:IsFull(nPlayerCount)
	for nMapId, tbGroup in pairs(self.tbGroupLists) do
		if tbGroup.nMaxPlayer < self.tbCfg.nMaxPlayer then
			if (self.tbCfg.nMaxPlayer - tbGroup.nMaxPlayer) >= nPlayerCount then
				return nMapId;
			end
		end
	end
	return 0;
end

function tbBase:JoinGroupList(nMapId, tbPlayerList)
	if self:IsOpen() == 0 then
		return 0;
	end
	self.tbGroupLists[nMapId].nMaxPlayer = self.tbGroupLists[nMapId].nMaxPlayer + #tbPlayerList;	
	table.insert(self.tbGroupLists[nMapId].tbList, {});
	local nGroupId = #self.tbGroupLists[nMapId].tbList;
	for nId, nPlayerId in pairs(tbPlayerList) do
		local nCaptain = 0;
		if nId == 1 then
			nCaptain = 1;
		end 
		self.tbPlayerData[nMapId][nPlayerId] = 
		{
			nCaptain = nCaptain;
			nGroupId = nGroupId;
			nMapId 	 = nMapId;
		};
	end
end

function tbBase:LeaveGroupList(nMapId, nId)
	local tbData = self:GetPlayerData(nMapId, nId);
	if tbData and self.tbGroupLists[nMapId] and self.tbGroupLists[nMapId].tbList[tbData.nGroupId] then
		for i, nLeaveId in pairs(self.tbGroupLists[nMapId].tbList[tbData.nGroupId]) do
			if nLeaveId == nId then
				table.remove(self.tbGroupLists[nMapId].tbList[tbData.nGroupId], i);
				self.tbGroupLists[nMapId].nMaxPlayer = self.tbGroupLists[nMapId].nMaxPlayer - 1;
				break;
			end
		end
	end	
end


function tbBase:Init()
	self.nState 	  = 0;
	self.tbPlayerData = {}; --玩家数据
	self.tbGroupLists = {}; --队伍数据	
	self.tbTimerList  = {}; --队伍数据	
	self.tbMapGroupList= {};--比赛地图成员管理
	self.tbDynMapLists = self.tbDynMapLists or {};

	for nMapId, tbPos in pairs(self.tbCfg.tbMap) do
		local nReadyMapId = nMapId;		
		self.tbDynMapLists[nMapId] = self.tbDynMapLists[nMapId] or {};
		self.tbMapGroupList[nReadyMapId] = {};		
		self.tbPlayerData[nReadyMapId] = {};	
		self.tbGroupLists[nReadyMapId]  = {tbList = {}, nMaxPlayer = 0};	
	end
end

function tbBase:GetPlayerNumInMap(nMapId)
	return self.tbGroupLists[nMapId].nMaxPlayer;
end

function tbBase:GetPlayerIdList(nMapId)
	local tbPlayerIdList = {};
	for nPlayerId, _ in pairs(self.tbPlayerData[nMapId]) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer and pPlayer.nMapId == nMapId then
			table.insert(tbPlayerIdList, nPlayerId);
		end
	end
	return tbPlayerIdList;
end

function tbBase:GetConsoleState()
	return self.nState;
end

function tbBase:GetBaoMingMemberCout(nMapId, nPlayerId)
	local tbData = self:GetPlayerData(nMapId, nPlayerId);
	if not tbData then
		return -1;
	end
	return #self.tbGroupLists[nMapId].tbList[tbData.nGroupId];
end