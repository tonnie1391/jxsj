if not MODULE_GC_SERVER then
	return;
end

Require("\\script\\autoteam\\autoteam_def.lua");

local SETTING_PATH_MONEY_HONOR	= "\\setting\\autoteam\\moneyhonor.txt";

--目标传送点
local tbPosXoyo =
{
	{ 341, 1625, 3180 },	--逍遥谷报名点1
	{ 342, 1625, 3180 },	--逍遥谷报名点2
};
local tbPosArmy =
{
	{24, 1917, 3444},
	{25, 1464, 3061},
	{29, 1606, 4139},
};

function AutoTeam:Init()
	self.nNextTeamId = 1;
	self:InitDataContainer();
	self:LoadSettings();
end

function AutoTeam:GetNextTeamId()
	local nTeamId = self.nNextTeamId;
	self.nNextTeamId = nTeamId + 1;
	return nTeamId;
end

function AutoTeam:InitDataContainer()
	--Key是team的ID, value是nTimerId
	self.tbTimer = {};
	
	--Key是参与自动匹配组队的玩家的ID
	--Value是玩家所在队伍的table
	self.tbPlayer = {};
	
	--下面的table存储队伍
	--Key是作为队伍中心的player的ID
	--Value是队伍的table，这些table同时也是self.tbPlayer中的值
	
	--逍遥谷
	self[AutoTeam.XOYO_PUTONG]		= {};
	self[self.XOYO_KUNNAN]		= {};
	self[self.XOYO_CHUANSHUO]	= {};
	self[self.XOYO_DIYU]		= {};
	
	--军营
	self[self.ARMY_FUNIUSHAN]		= {};
	self[self.ARMY_BAIMANSHAN]		= {};
	self[self.ARMY_HAIWANGLINGMU]	= {};
end

function AutoTeam:LoadSettings()
	local tbSetting = Lib:LoadTabFile(SETTING_PATH_MONEY_HONOR);
	if not tbSetting then 
		return 0;
	end
	
	local tbMoneyHonor = {};
	for _, tbRow in ipairs(tbSetting) do
		tbMoneyHonor[tbRow.Level] = tbRow;
	end
	self.tbMoneyHonor = tbMoneyHonor;
	return 1;
end

function AutoTeam:IsPlayerCompatible(nMoneyLevel, nNewPlayerId)
	local szMoneyLevel = tostring(nMoneyLevel);
	local szMoneyLevelNewPlayer	 = tostring(PlayerHonor:GetPlayerMoneyHonorLevel(nNewPlayerId));
	local tbLevel = self.tbMoneyHonor[szMoneyLevel];
	return tonumber(tbLevel[szMoneyLevelNewPlayer]);
end
	
function AutoTeam:MakePlayerInfo(nPlayerId)
	local szPlayerName	= KGCPlayer.GetPlayerName(nPlayerId);
	local nLevel		= KGCPlayer.OptGetTask(nPlayerId, KGCPlayer.LEVEL);
	local nFaction		= KGCPlayer.OptGetTask(nPlayerId, KGCPlayer.TSK_FACTION);
	local nMoneyLevel	= PlayerHonor:GetPlayerMoneyHonorLevel(nPlayerId);
	
	return
	{
		["nId"]				= nPlayerId,
		["szName"]			= szPlayerName,
		["nLevel"]			= nLevel,
		["nFaction"]		= nFaction,
		["nMoneyLevel"]		= nMoneyLevel,
	};
end

function AutoTeam:GetTeamData(nTeamType)
	return assert(self[nTeamType]);
end

function AutoTeam:CreateTeam(nTeamType, nPlayerId)
	local nMoneyLevel	= PlayerHonor:GetPlayerMoneyHonorLevel(nPlayerId);
	
	local tbTeamData = self:GetTeamData(nTeamType);
	local tbPlayerInfo = self:MakePlayerInfo(nPlayerId);
	local nTeamId = self:GetNextTeamId();
	local tbTeam =
	{
		["nId"]			= nTeamId,
		["nMoneyLevel"]	= nMoneyLevel,
		["nTeamType"]	= nTeamType,
		["tbMember"]	= { tbPlayerInfo },
	};
	tbTeamData[nTeamId] = tbTeam;
	self.tbPlayer[nPlayerId] = tbTeam;
	return tbTeam;
end

function AutoTeam:RemoveTeam(nTeamType, nTeamId)
	local tbTeamData = self:GetTeamData(nTeamType);
	local tbTeam = tbTeamData[nTeamId];
	tbTeamData[nTeamId] = nil;
	if tbTeam then
		local tbPlayerIdArray = {};
		for _, tbMemberInfo in ipairs(tbTeam.tbMember) do
			self.tbPlayer[tbMemberInfo.nId] = nil;
			tbPlayerIdArray[#tbPlayerIdArray + 1] = tbMemberInfo.nId;
		end
		if #tbPlayerIdArray > 0 then
			AutoTeam:ClearClientData(tbPlayerIdArray);
		end
	end
end

function AutoTeam:ClearClientData(tbPlayerIdArray, szMsgOptional)
	GlobalExecute({ "AutoTeam:ClearClientData", tbPlayerIdArray, szMsgOptional });
end

function AutoTeam:AddPlayer(nTeamType, nNewPlayerId)
	--一个玩家同时只能排一种类型的队
	if self.tbPlayer[nNewPlayerId] then
		return 0;
	end
	
	StatLog:WriteStatLog("stat_info", "ziyouzudui", "apply", nNewPlayerId);
	
	local tbTeamData = self:GetTeamData(nTeamType);
	for _, tbTeam in pairs(tbTeamData) do
		local nMemberCount = #(tbTeam.tbMember);
		if nMemberCount < self.MAX_TEAM_MEMBER then
			-- local bIsCompatible = self:IsPlayerCompatible(tbTeam.nMoneyLevel, nNewPlayerId);
			-- if bIsCompatible == 1 then
				self:AddPlayerToTeam(tbTeam, nNewPlayerId);
				return 1;
			-- end
		end
	end
	
	local tbTeam = self:CreateTeam(nTeamType, nNewPlayerId);
	self:SyncTeamDataToAllClient(tbTeam);
	return 1;
end

function AutoTeam:AddPlayerToTeam(tbTeam, nNewPlayerId)
	local tbPlayerInfo = self:MakePlayerInfo(nNewPlayerId);
	table.insert(tbTeam.tbMember, tbPlayerInfo);
	self.tbPlayer[nNewPlayerId] = tbTeam;
	local nMemberCount = #(tbTeam.tbMember);
	local szName = KGCPlayer.GetPlayerName(nNewPlayerId);
	local szMsg = string.format("<color=yellow>%s<color> đã gia nhập, số lượng hàng chờ là <color=yellow>%d", szName, nMemberCount);
	self:SyncTeamDataToAllClient(tbTeam, szMsg, nNewPlayerId);
	if nMemberCount == self.MAX_TEAM_MEMBER then
		self:OnTeamDone(tbTeam);
	end	
end

function AutoTeam:SyncTeamDataToAllClient(tbTeam, szMsgOptional, nPlayerIdNoMsg)
	GlobalExecute({ "AutoTeam:SyncTeamDataToAllClient", tbTeam, szMsgOptional, nPlayerIdNoMsg });
end

--GS调用此函数
function AutoTeam:SyncTeamDataToOneClient(nPlayerId)
	local tbTeam = self.tbPlayer[nPlayerId];
	if tbTeam then
		local nGSConnectId = assert(_G.GCEvent.nGCExecuteFromId);
		GSExecute(nGSConnectId, { "AutoTeam:SyncTeamDataToOneClient_Callback", nPlayerId, tbTeam });
	end
end

--GS调用此函数
function AutoTeam:OnClientConfirm(nPlayerId, nConfirmCode)
	local tbTeam = self.tbPlayer[nPlayerId];
	if tbTeam then
		if nConfirmCode == self.CONFIRM_OK then
			local nTimerId = self.tbTimer[tbTeam.nId];
			if nTimerId then
				self:SetConfirm(tbTeam.tbMember, nPlayerId);
				local tb = self:GetUnConfirmedPlayer(tbTeam);
				if #tb == 0 and #(tbTeam.tbMember) == self.MAX_TEAM_MEMBER then
					self:CompleteTeam(tbTeam, 0);
				else
					self:SyncTeamDataToAllClient(tbTeam);
				end
			end
		else
			-- self:RemovePlayer(nPlayerId, 1, "你拒绝了组队，被移出了自动组队系统。");
			local szName = KGCPlayer.GetPlayerName(nPlayerId);
			local szOtherMsg = string.format("<color=yellow>%s<color> từ chối nhóm, đội tiếp tục ghép, vui lòng chờ đợi.", szName);
			self:SyncTeamDataToAllClient(tbTeam, szOtherMsg);
		end
	end
end

function AutoTeam:ClearTimer(tbTeam)
	local nTimerId = self.tbTimer[tbTeam.nId];
	if nTimerId then
		Timer:Close(nTimerId);
		self.tbTimer[tbTeam.nId] = nil;
	end
end

function AutoTeam:SetConfirm(tbMember, nPlayerId)
	for _, tbMemberInfo in ipairs(tbMember) do
		if tbMemberInfo.nId == nPlayerId then
			tbMemberInfo.bConfirmed = 1;
		end
	end
end

function AutoTeam:ClearConfirm(tbTeam)
	for _, tbMemberInfo in ipairs(tbTeam.tbMember) do
		tbMemberInfo.bConfirmed = nil;
	end
end

function AutoTeam:MakeStatLogPlayerString(tbMember)
	local szName;
	local s = "";
	for n, tbMemberInfo in ipairs(tbMember) do
		szName = KGCPlayer.GetPlayerName(tbMemberInfo.nId);
		if (n ~= 1) then
			s = s .. ",";
		end
		s = s .. szName;
	end
	return s;
end

function AutoTeam:OnTeamDone(tbTeam)
	local nTimerId = self.tbTimer[tbTeam.nId];
	if nTimerId then
		Timer:Close(nTimerId);
	end
	nTimerId = Timer:Register(Env.GAME_FPS * self.CONFIRM_COUNTDOWN_SECONDS, self.CompleteTeam, self, tbTeam, 1);
	self.tbTimer[tbTeam.nId] = nTimerId;
	self:ClearConfirm(tbTeam);
	GlobalExecute({ "AutoTeam:OnTeamDone", tbTeam });
	
	local nCaptainId = self:GetCaptainId(tbTeam.tbMember);
	local szMemberNames = self:MakeStatLogPlayerString(tbTeam.tbMember);
	StatLog:WriteStatLog("stat_info", "ziyouzudui", "matching", nCaptainId, szMemberNames);
end

function AutoTeam:CompleteTeam(tbTeam, bNeedCheck)
	local nTeamId = tbTeam.nId;
	local nTimerId = self.tbTimer[nTeamId];
	if nTimerId then
		Timer:Close(nTimerId);
		self.tbTimer[nTeamId] = nil;
	end
	local tbTeamData = self:GetTeamData(tbTeam.nTeamType);
	if tbTeamData[nTeamId] ~= tbTeam then
		return;
	end
	
	local bDone;
	if bNeedCheck == 0 then
		bDone = 1;
	else
 		local tb = self:GetUnConfirmedPlayer(tbTeam);
 		if #tb == 0 and #(tbTeam.tbMember) == self.MAX_TEAM_MEMBER then
 			bDone = 1;
 		else
 			for _, nPlayerId in ipairs(tb) do
 				self:RemovePlayerSingle(tbTeam, nPlayerId);
 			end
 			self:ClearClientData(tb, "Bạn đã không xác nhận và được đưa ra khỏi hệ thống tự động.");
 			if #(tbTeam.tbMember) > 0 then
 				self:ClearConfirm(tbTeam);
 				self:SyncTeamDataToAllClient(tbTeam, "Một thành viên chưa xác nhận, đội tiếp tục ghép, vui lòng chờ đợi");
 			end
 		end
	end
	
	if bDone == 1 then
		local nCaptainId = self:ApplyMakeTeam(tbTeam);
		self:TransferPlayer(tbTeam);
		self:RemoveTeam(tbTeam.nTeamType, tbTeam.nId);
		
		local szMemberNames = self:MakeStatLogPlayerString(tbTeam.tbMember);
		StatLog:WriteStatLog("stat_info", "ziyouzudui", "finish", nCaptainId, szMemberNames);
	end
end

function AutoTeam:GetUnConfirmedPlayer(tbTeam)
	local tb = {};
	for _, tbMemberInfo in ipairs(tbTeam.tbMember) do
		if tbMemberInfo.bConfirmed ~= 1 then
			tb[#tb + 1] = tbMemberInfo.nId;
		end
	end
	return tb;
end

function AutoTeam:GetCaptainId(tbMember)
	assert(tbMember);
	local nMoneyHonor = 0;
	local nCaptainId = nil;
	for n, tbMemberInfo in ipairs(tbMember) do
		local nTemp = KGCPlayer.OptGetTask(tbMemberInfo.nId, KGCPlayer.MONEY_HONOR);
		if nTemp >= nMoneyHonor then
			nMoneyHonor = nTemp;
			nCaptainId = tbMemberInfo.nId;
		end
	end
	return nCaptainId;
end

function AutoTeam:ApplyMakeTeam(tbTeam)
	local nCaptainId = self:GetCaptainId(tbTeam.tbMember);
	local nTeamId = KGCPlayer.OptGetTask(nCaptainId, KGCPlayer.TEAM_ID);
	if (nTeamId > 0) then
		KTeam.DelTeamMember(nTeamId, nCaptainId);
	end
	KTeam.CreateTeam(nCaptainId);
	for n, tbMemberInfo in ipairs(tbTeam.tbMember) do
		local nMemberId = tbMemberInfo.nId;
		if nMemberId ~= nCaptainId then
			nTeamId = KGCPlayer.OptGetTask(nMemberId, KGCPlayer.TEAM_ID);
			if (nTeamId > 0) then
				KTeam.DelTeamMember(nTeamId, nMemberId);
			end
			KTeam.ApplyJoinPlayerTeam(nCaptainId, nMemberId);
		end
	end
	return nCaptainId;
end

function AutoTeam:GetTransferPos(nTeamType)
	if self:IsTeamTypeXoyo(nTeamType) == 1 then
	   	local n = MathRandom(1, 2);
	   	return tbPosXoyo[n];
	elseif self:IsTeamTypeArmy(nTeamType) == 1 then
		local n = MathRandom(1, 3);
	   	return tbPosArmy[n];
	else
		assert(false);
	end
end

function AutoTeam:TransferPlayer(tbTeam)
	local tbPos = self:GetTransferPos(tbTeam.nTeamType);
	GlobalExecute({ "AutoTeam:TransferPlayer", tbTeam, tbPos });
end

--gs调用此函数
function AutoTeam:RemovePlayer(nPlayerId, bNotifyClient, szNotifyMsg)
	local tbTeam = self.tbPlayer[nPlayerId];
	if tbTeam then
		self:RemovePlayerSingle(tbTeam, nPlayerId);

		--只要有人离开了队伍，就应当清除timer和已确认的记录
		self:ClearTimer(tbTeam);
		self:ClearConfirm(tbTeam);
		
		local szName = KGCPlayer.GetPlayerName(nPlayerId);
		local szOtherPlayerMsg = string.format("<color=yellow>%s<color> rời khỏi đội, số lượng còn lại là <color=yellow>%d", szName, #(tbTeam.tbMember));
		self:SyncTeamDataToAllClient(tbTeam, szOtherPlayerMsg, nPlayerId);
		if bNotifyClient == 1 then
			local nGSConnectId = assert(_G.GCEvent.nGCExecuteFromId);
			GSExecute(nGSConnectId, { "AutoTeam:RemovePlayer_Callback", nPlayerId, szNotifyMsg });
		end
	end
end

function AutoTeam:RemovePlayerSingle(tbTeam, nPlayerId)
	local tbTeamData = self:GetTeamData(tbTeam.nTeamType);
	self.tbPlayer[nPlayerId] = nil;
	local nIndex = nil;
	local tbMember = tbTeam.tbMember;
	for n, tbInfo in ipairs(tbMember) do
		if tbInfo.nId == nPlayerId then
			nIndex = n;
			break;
		end
	end
	
	assert(nIndex);
	table.remove(tbMember, nIndex);
	if #tbMember == 0 then
		self:RemoveTeam(tbTeam.nTeamType, tbTeam.nId);
		return;
	end
end

AutoTeam:Init();
