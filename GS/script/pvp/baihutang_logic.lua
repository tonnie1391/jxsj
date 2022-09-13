-------------------------------------------------------------------
--File		: baihutang_logic.lua
--Author	: ZouYing
--Date		: 2008-8-22 9:14
--Describe	: 白虎堂活动logic脚本
-------------------------------------------------------------------

-- BaiHuTang基础类，提供默认操作以及基础处理函数
local tbBase =  Mission:New();
BaiHuTang.tbMissionBase = tbBase;

function tbBase:SetCofig(nMapId)
	local tbTemp = {};
	for nIndex, tbPos in ipairs(BaiHuTang.tbDaDianPos) do
		table.insert(tbTemp, {nMapId, tbPos.nX / 32, tbPos.nY / 32});
	end
	--设置Mission的tbMisCfg
	self.tbMisCfg = 
	{
		nOnDeath = 1;
		nDeathPunish = 1;
		nPkState =  Player.emKPK_STATE_TONG;
		tbLeavePos    = {[0] = tbTemp };	
		tbDeathRevPos = {[0] = tbTemp };	
		nOnMovement		= 1,								-- 参加某项活动
		nDisableFriendPlane = 1,							-- 禁止好友界面
		nDisableStallPlane	= 1,							-- 禁止交易界面
	}
end

function tbBase:OnStartGame()
	self.tbGroups	= {};
	self.tbPlayers	= {};
	self.tbTimers	= {};
	self.tbMapCount = {};
	self.nStateJour = 0;
	self.tbNowStateTimer = nil;
end

function tbBase:OnLeave()
	BaiHuTang:_SetLeaveFightState(me);
	Dialog:ShowBattleMsg(me, 0, 0);
end

function tbBase:OnDeath(pKillerNpc)
	
	local pKillerPlayer = pKillerNpc.GetPlayer();
	local nFloor  = 0;
	if (pKillerPlayer) then
		
		nFloor = BaiHuTang:GetFloor(pKillerPlayer.nMapId)		
		local szKillerRouter	= Player:GetFactionRouteName(pKillerPlayer.nFaction, pKillerPlayer.nRouteId);
		local szDeathRouter		= Player:GetFactionRouteName(me.nFaction, me.nRouteId);
	
		BaiHuTang.tbKillerChu[szKillerRouter] = (BaiHuTang.tbKillerChu[szKillerRouter] or 0) + 1;
		BaiHuTang.tbDeathChu[szDeathRouter] = (BaiHuTang.tbDeathChu[szDeathRouter] or 0 ) + 1;
		pKillerPlayer.Msg("<color=green>Bạn đã đánh bại "..me.szName..".<color>");
		local tbPlayer, nCount = KPlayer.GetMapPlayer(me.nMapId);
		
		if (nCount > 2 ) then
			local szMsg = pKillerPlayer.szName.." đánh bại " .. me.szName .. ".";
			for _, pPlayer in pairs(tbPlayer) do
				if (pPlayer.szName ~= me.szName and pPlayer.szName ~= pKillerPlayer.szName) then
					pPlayer.Msg(szMsg, "Hệ thống");		
				end
			end
		end		
		local tbAchievement = 
		{
			[1] = {154,155,156},
			[2] = {163,164,165},
			[3] = {172,173,174},
		}
		if tbAchievement[nFloor] then
			for _, nAchievementId in pairs(tbAchievement[nFloor]) do
				Achievement:FinishAchievement(pKillerPlayer, nAchievementId);
			end
		end
		DataLog:WriteELog(pKillerPlayer.szName, 4, 3, me.szName, me.nMapId);
	end
	--1、2层3条命
	if EventManager.IVER_bOpenBaiHuliftLimit == 1 then
		nFloor = BaiHuTang:GetFloor(me.nMapId);
		if nFloor <= 2 and me.GetPlayerTempTable().nCount and me.GetPlayerTempTable().nCount > 0 then
			me.GetPlayerTempTable().nCount = me.GetPlayerTempTable().nCount - 1;
			return;
		end
	end
	self:KickPlayer(me);
end

function tbBase:AddPlayerCount(nMapId)
	self.tbMapCount[nMapId] = self.tbMapCount[nMapId] or 0;
	self.tbMapCount[nMapId] = self.tbMapCount[nMapId] + 1;
end

function tbBase:GetPlayerCount(nMapId)
	self.tbMapCount[nMapId] = self.tbMapCount[nMapId] or 0;
	return self.tbMapCount[nMapId];
end

function tbBase:DelPlayerCount(nMapId)
	if self.tbMapCount[nMapId] then
		self.tbMapCount[nMapId] = self.tbMapCount[nMapId] - 1;
		if self.tbMapCount[nMapId] < 0 then
			self.tbMapCount[nMapId] = 0;
		end
	end
end

function tbBase:BeforeLeave(nGroupId, szReason)
	self:DelPlayerCount(me.nMapId);
end

-------------------白虎堂独立逻辑---------------------------------------------------

BaiHuTang.tbMissionList = {};
function BaiHuTang:CreateMissions()
	for i, nMapId in pairs(self.tbMapList) do
		self.tbMissionList[nMapId] = self.tbMissionList[nMapId] or Lib:NewClass(tbBase);
		self.tbMissionList[nMapId]:SetCofig(nMapId);
	end
end

function BaiHuTang:Open()
	for i, tbMission in pairs(self.tbMissionList) do
		tbMission:OnStartGame();
	end
end

function BaiHuTang:MissionStop()
	for nMapId, tbMission in pairs(self.tbMissionList) do
		if (tbMission:IsOpen() == 1) then
			tbMission:Close();
		end		
	end
	self.tbPlayerInBossDeathMap = {};	--每次白虎结束时候将此设置为空
end


--加入Mission
function BaiHuTang:JoinGame(nMapId, pPlayer, nNewMapId, nX, nY)
	local bEnter = 0;
	local tbMis = nil;
	for n, tbMission in pairs(self.tbMissionList) do
		if (n == nMapId and tbMission:IsOpen() == 1) then
			tbMis = tbMission;
			break;
		end
	end
	if (not tbMis) then
		pPlayer.Msg("Bạch Hổ Đường đang bảo trì");
		return;
	end
	if tbMis:GetPlayerCount(nNewMapId) >= self.MAX_NUMBER then
		pPlayer.Msg("Cửa này đã đạt tối đa số lượng, hãy tham gia ở cửa khác!");
		return;
	end
	tbMis:JoinPlayer(pPlayer, 1);
	tbMis:AddPlayerCount(nNewMapId);
	self:_SetPKState(pPlayer);		--进入战斗状态
	self:ShowTimeInfo(pPlayer);
	--popo提示
	pPlayer.CallClientScript({"PopoTip:ShowPopo", 18});
	pPlayer.NewWorld(nNewMapId, nX, nY);
	return 1;
end

function BaiHuTang:KickOutMission(pPlayer, nMapId)
	for i, tbMission in pairs(self.tbMissionList) do
		
		if (nMapId == i) then
			tbMission:KickPlayer(pPlayer);
		end
	end
end

function BaiHuTang:OnKickPlayer(pPlayer, nMapId)
	if self.tbMissionList and self.tbMissionList[nMapId] then
		if self.tbMissionList[nMapId]:IsOpen() == 1 then
			if self.tbMissionList[nMapId]:GetPlayerGroupId(pPlayer) >= 0 then
				self.tbMissionList[nMapId]:KickPlayer(pPlayer);
			end
		end
	end
end
