--武林联赛
--周辰飞
--2010.05.24
--多功能mission
if (MODULE_GC_SERVER) then
	return 0;
end

Require("\\script\\mission\\wlls\\wlls_def.lua")

--	table.insert(tbMis_List, {"PkToPkChoose", 		Env.GAME_FPS * 5, 					"OnGamePkChoose"});
--	table.insert(tbMis_List, {"PkToPkChooseEnd",	Env.GAME_FPS * (nChooseTime - 5), 	"OnGamePkChooseEnd"});
--	table.insert(tbMis_List, {"PkToPkStart", 		Env.GAME_FPS * 10, 					"OnGamePk"	});
--	table.insert(tbMis_List, {"PkStartToRest", 		Env.GAME_FPS * (nTime - 15), 		"OnGameRest"});
--	table.insert(tbMis_List, {"PkToPkStart", 		Env.GAME_FPS * 5, 					"OnGamePk"	});
--	table.insert(tbMis_List, {"PkStartToEnd", 		Env.GAME_FPS * (nTime - 15), 		"OnGameRest"});
--	table.insert(tbMis_List, {"PkOver", 			Env.GAME_FPS * 5, 					"OnGameOver"});			



--	table.insert(tbMis_UI, {"<color=gold>%s Vs %s\n\n", "<color=green>Thời gian bắt đầu: <color=white>%s<color>\n\n", ""});
--	table.insert(tbMis_UI, {"<color=gold>%s Vs %s\n\n", "<color=green>剩余选择时间：<color=white>%s<color>\n\n", ""});
--	table.insert(tbMis_UI, {"<color=gold>%s Vs %s\n\n", "<color=green>Thời gian bắt đầu: <color=white>%s<color>\n\n", "<color=green>对方受伤总量：<color=red>%s\n<color=green>本方受伤总量：<color=blue>%s"});
--	table.insert(tbMis_UI, {"<color=gold>%s Vs %s\n\n", "<color=green>Thời gian còn lại: <color=white>%s<color>\n\n", "<color=green>对方受伤总量：<color=red>%s\n<color=green>本方受伤总量：<color=blue>%s"});


-- 建立一个Mission类
local MissionBase = Mission:New();
Wlls.Mission_PerPk_Part = MissionBase;

-- 当Mission被开启“后”被调用
--function MissionBase:OnOpen()
--end;

-- 在Mission被关闭“前”被调用
--function MissionBase:OnClose()
--end;

-- 开启活动
function MissionBase:StartGame(nReadyId, nGameLevel, nIndex)
	-- 设定可选配置项
	local nState		= Wlls:GetMacthState();
	local nSession		= Wlls:GetMacthSession();
	local tbMacthCfg	= Wlls:GetMacthTypeCfg(Wlls:GetMacthType());
	local tbMacthLevelCfg = Wlls:GetMacthLevelCfg(Wlls:GetMacthType(), nGameLevel);
	
	--随机会场
	local tbLeaveMap =  Wlls:GetLeaveMapPos(tbMacthCfg, tbMacthLevelCfg, nReadyId);
	
	self.tbMisCfg	= {
		tbEnterPos		= {},					-- 进入坐标
		tbLeavePos		= {[1]= tbLeaveMap, [2] = tbLeaveMap},	-- 离开坐标
		tbCamp			= {[1] = 1, [2] = 2},	-- 分别设定阵营
		nForbidTeam		= 1,
		nPkState		= Player.emKPK_STATE_PRACTISE,--战斗模式
		nDeathPunish	= 1,
		nOnDeath 		= 1, 	-- 死亡脚本可用
		nInLeagueState	= 1,	-- 联赛模式
	}
	self.nMacthMap  = tbMacthLevelCfg.tbMacthMap[nReadyId];
	self.nMacthMapPatch	= tbMacthLevelCfg.tbMacthMapPatch[nReadyId];	--后备地图
	
	self.nGameLevel = nGameLevel;
	self.nGameState = 0;		--开始准备pk阶段
	self.tbLeagueList = {};		--战队成员表
	self.tbMisEventList	= Wlls.SUB_MIS_LIST;
	self.MIS_UI			= Wlls.SUB_MIS_UI;
	self.tbGroups	= {};
	self.tbPlayers	= {};
	self.tbTimers	= {};
	self.tbLooker	= {};
	self.nStateJour = 0;
	self.tbNowStateTimer	= nil;
	self.nMissionIndex		= nIndex;
	self.nMissionReadyId	= nReadyId;
	self.nChooseState		= 0;
	self.nRoundIndex		= 0;
	self.nRoundCount		= 0;
	self.nOverGameFlag		= 0;
	
	if (Wlls.DEF_STATE_ADVMATCH == nState) then
		self.nRoundCount	= #tbMacthCfg.tbMacthCfg.tbPKTime_Adv;
	else
		self.nRoundCount	= #tbMacthCfg.tbMacthCfg.tbPKTime_Common;
	end

--	self:GoNextState()	-- 开始报名
end

-- mission开启函数
function MissionBase:OnStart()
	if (self:GetPlayerCount() <= 0) then
		print("人数不足未开启！");
		return 0;
	end
	
	-- 如果发现有一方队伍的人都离场，那么就要提前结束比赛
	if (self:ProcessDirOverGame(self.nRoundIndex + 1) == 1) then
		self.nGameState = 1;
		self.nStateJour = #self.tbMisEventList;
		self:OnGameOver();
		return 0;
	end

	self:GoNextState();

	for _, pPlayer in pairs(self:GetPlayerList()) do
		local szLeagueName = League:GetMemberLeague(Wlls.LGTYPE, pPlayer.szName);
		if not szLeagueName then
			return 0;
		end
		local szMacthName = self.tbLeagueList[szLeagueName].szMacthName;
		local szMsg = string.format(Wlls.MIS_UI[self:GetGameState()][1], szLeagueName, szMacthName);
		local szMsg2 = string.format(Wlls.MIS_UI[self:GetGameState()][3], 0, 0);
		Wlls:OpenSingleUi(pPlayer, szMsg..Wlls.MIS_UI[self:GetGameState()][2], self:GetStateLastTime());
		local szExMsg	= self:GetExUiMsg(szLeagueName);
		szMsg2 = szMsg2 .. "\n" .. szExMsg;
		Wlls:UpdateMsgUi(pPlayer, szMsg2);
	end
end

-- 当玩家加入Mission“后”被调用
function MissionBase:OnJoin(nGroupId)
	Wlls:SetStateJoinIn(1);
	me.SetCurCamp(nGroupId);
	Dialog:SendBlackBoardMsg(me, "进入比赛场,比赛即将开始")
	Wlls:WriteLog(string.format("玩家进入比赛场:%s", me.nMapId), me.nId);
end;

-- 检查是否是本轮玩家
function MissionBase:CheckIsCurRoundPlayer(szLeagueName, szPlayerName, nRoundIndex)
	local nFLag = 0;
	if (not szPlayerName) then
		return 0;
	end
	local tbCurRoundInfo = self:GetCurRoundInfo(szLeagueName, nRoundIndex);
	if (tbCurRoundInfo and tbCurRoundInfo.tbPlayer) then
		for i, szName in pairs(tbCurRoundInfo.tbPlayer) do
			if (szName == szPlayerName) then
				return 1;
			end
		end
	end
	return 0;
end

-- 当玩家加入Mission“后”被调用
function MissionBase:OnDeath()
	local szLeagueName = League:GetMemberLeague(Wlls.LGTYPE, me.szName);

	self:OnSyncDamage();
	me.ReviveImmediately(1);
	self.tbLeagueList[szLeagueName].tbDamage[me.nId] = me.GetDamageCounter();
	self:OnLeaveRound(me, 0);

--	self:KickPlayer(me, 0);
end;

-- 当玩家离开Mission“前”被调用
--function MissionBase:BeforeLeave(nGroupId, nState)
--end

-- 当玩家离开Mission“后”被调用
function MissionBase:OnLeave(nGroupId, nState)
	local szLeagueName = League:GetMemberLeague(Wlls.LGTYPE, me.szName);
	local szMacthName = self.tbLeagueList[szLeagueName].szMacthName;
	
	self:OnLeaveRound(me, nState);

	me.RemoveSkillState(Looker.DEF_SKILL);
	Wlls:LeaveGame()
	Wlls:CloseSingleUi(me)
end;

-- 0表示没有直接结束pk，1表示有一方未参加比赛，2表示双方有队员都未参加比赛，3是连参赛队都没参赛
function MissionBase:CheckDirOverRound()
	local tbLeagueList = {};
	for szLeagueName, tbInfo in pairs(self.tbLeagueList) do
		local tbCurRoundInfo = self:GetCurRoundInfo(szLeagueName, self.nRoundIndex);
		tbLeagueList[#tbLeagueList +1] = { szLeagueName = szLeagueName, tbInfo = tbCurRoundInfo };
	end
	local nFlagA	= 0;
	local nFlagB	= 0;
	
	if (tbLeagueList[1] and tbLeagueList[1].tbInfo and tbLeagueList[1].tbInfo.tbPlayer) then
		if (Wlls:CountTableLeng(tbLeagueList[1].tbInfo.tbPlayer) <= 0) then
			nFlagA = 1;
		end
	end

	if (tbLeagueList[2] and tbLeagueList[2].tbInfo and tbLeagueList[2].tbInfo.tbPlayer) then
		if (Wlls:CountTableLeng(tbLeagueList[2].tbInfo.tbPlayer) <= 0) then
			nFlagB = 1;
		end
	end

	if (1 == nFlagA or 1 == nFlagB) then
		return 1;
	end

	return 0;
end

function MissionBase:SetPartPkResult(szLeagueName, nResult, nRound, nMatchTime)
	if (not self.tbLeagueList) then
		return 0;
	end
	
	local tbLeague = self.tbLeagueList[szLeagueName];
	if (not tbLeague) then
		return 0;
	end
	
	if (not tbLeague.tbPart) then
		return 0;
	end
	
	if (not tbLeague.tbPart[nRound]) then
		return 0;
	end
	
	self.tbLeagueList[szLeagueName].tbPart[nRound].nResult = nResult;
	self.tbLeagueList[szLeagueName].tbPart[nRound].nMatchTime = nMatchTime;
	return 1;
end

function MissionBase:OnGamePk()
	self.nGameState = 2;
	
	-- 如果本轮没有对手就直接跳过
	if (self:CheckDirOverRound() ~= 0) then
		self.nStateJour = self.nStateJour + 1;
		self:GoNextState();
		return 0;
	end
	
	for szLName, tbInfo in pairs(self.tbLeagueList) do
		local tbCurRoundInfo = self:GetCurRoundInfo(szLName, self.nRoundIndex);
		if (tbCurRoundInfo) then
			for _, szPlayerName in pairs(tbCurRoundInfo.tbPlayer) do
				local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
				if (pPlayer and self:GetPlayerGroupId(pPlayer) >= 0) then
					pPlayer.SetFightState(1);
					pPlayer.SetBroadHitState(1);
					pPlayer.nPkModel = Player.emKPK_STATE_BUTCHER;
					Dialog:SendBlackBoardMsg(pPlayer, "比赛正式开始");
					local szLeagueName = League:GetMemberLeague(Wlls.LGTYPE, pPlayer.szName);
					if not szLeagueName then
						return 0;
					end
				end
			end
		end
	end
	--self:BroadcastMsg("进入正式比赛", "test");	-- 广播消息
	
	for _, pPlayer in pairs(self:GetPlayerList()) do
		if (pPlayer) then
			local szLeagueName = League:GetMemberLeague(Wlls.LGTYPE, pPlayer.szName);
			self:OnGamePkUi(pPlayer, szLeagueName);
		end
	end	
	
	for szLookLeagueName, tbLooker in pairs(self.tbLooker) do
		for nLookId in pairs(tbLooker) do
			local pPlayer = KPlayer.GetPlayerObjById(nLookId);
			if pPlayer then
				self:OnGamePkUi(pPlayer, szLookLeagueName);
			end
		end
	end
	
	
	self.tbTimer = self:CreateTimer(Wlls.MACTH_TIME_PK_DAMAGE, self.OnSyncDamage, self);
end

function MissionBase:OnGamePkUi(pPlayer, szLeagueName)
	if (self:GetGameState()+1 > #self.MIS_UI) then
		return 0;
	end

	local szMacthName = self.tbLeagueList[szLeagueName].szMacthName;
	local szMsg = string.format(self.MIS_UI[self:GetGameState()+1][1], szLeagueName, szMacthName);
	local szMsg2 = "";
	if (self:GetGameState()+1 == #self.MIS_UI) then
		szMsg2 = self.MIS_UI[self:GetGameState()+1][3];
	else
		szMsg2 = string.format(self.MIS_UI[self:GetGameState()+1][3], 0, 0);
	end

	if (self.nRoundIndex > 0) then		
		local szExMsg	= self:GetExUiMsg(szLeagueName);
		szMsg2 = szMsg2 .. "\n" .. szExMsg;
	end

	Wlls:UpdateTimeUi(pPlayer, szMsg..self.MIS_UI[self:GetGameState()+1][2], self.tbMisEventList[self:GetGameState()+1][2]);
	Wlls:UpdateMsgUi(pPlayer, szMsg2);
end

-- TODO
function MissionBase:GetExUiMsg(szLeagueName)
	if (self.nRoundIndex <= 0) then
		return "";
	end
	
	local szMacthName = self.tbLeagueList[szLeagueName].szMacthName;
	local tbLeaguePart = self.tbLeagueList[szLeagueName].tbPart or {};
	local tbOpLeaguePart = self.tbLeagueList[szMacthName].tbPart or {};
	local szMsg = "";
	local tbResultName = {
			[1] = "胜",
			[2]	= "平",
			[3] = "负",
		};
	for i, tbPart in pairs(tbLeaguePart) do
		local tbOpPart = tbOpLeaguePart[i];
		local szName = "";
		local szOpName = "";
		szName = self:GetNameStr(tbPart);
		szOpName = self:GetNameStr(tbOpPart);
		if (tbPart and tbPart.nResult and tbPart.nResult > 0) then
			szName = string.format("%s（%s）", szName, tbResultName[tbPart.nResult] or "Vô");
		end

		if (tbOpPart and tbOpPart.nResult and tbOpPart.nResult > 0) then
			szOpName = string.format("%s（%s）", szOpName, tbResultName[tbOpPart.nResult] or "Vô");
		end
		local szNameMsg = string.format("%s  VS  %s", szName, szOpName);
		if (self.nRoundIndex == i) then
			szNameMsg = string.format("<color=yellow>%s<color>", szNameMsg);
		end
		szNameMsg = szNameMsg .. "\n";
		szMsg = szMsg .. szNameMsg;
	end
	return szMsg;
end

function MissionBase:GetNameStr(tbPart)
	local szNameStr = "";
	if (not tbPart) then
		return "无参赛队员";
	end
	local nFlag = 0;
	for i, szName in pairs(tbPart.tbLogPlayer) do
		if (nFlag == 1) then
			szNameStr = szNameStr .. "，";
		end
		szNameStr = szNameStr .. szName;
	end
	if (szNameStr == "") then
		szNameStr = "无参赛队员";
	end
	return szNameStr;
end

function MissionBase:OnGameOver(nDirClose)
	if (not nDirClose or nDirClose ~= 1) then
		if self.nGameState ~= 2 and self.nGameState ~= 1 then
			return 0;
		end
	end
	if (self.tbTimer) then
		self.tbTimer:Close();
	end
	
	self.nGameState = 3;
	self:EndGame();
	return 0;
end

--同步伤血量
-- nSyn 标示为1标示强行同步
function MissionBase:OnSyncDamage(nSyn)
	if (not nSyn or nSyn ~= 1) then
		if self:GetGameState() <= 0 or self.nGameState ~= 2 then
			if (self.nGameState == 1) then
				return;
			end
			return 0;
		end
	end

	for _, pPlayer in pairs(self:GetPlayerList()) do
		local szLeagueName = League:GetMemberLeague(Wlls.LGTYPE, pPlayer.szName);
		self.tbLeagueList[szLeagueName].tbDamage[pPlayer.nId] = pPlayer.GetDamageCounter();
	end

	for szLeagueName, tbParam in pairs(self.tbLeagueList) do
		local tbCurRoundInfo = self:GetCurRoundInfo(szLeagueName, self.nRoundIndex);
		local nMaxD = 0;
		tbParam.nMaxDamage = 0;
		for _, nDamage in pairs(tbParam.tbDamage) do
			tbParam.nMaxDamage = tbParam.nMaxDamage + nDamage;
		end
		if (tbCurRoundInfo) then
			if (tbCurRoundInfo and tbCurRoundInfo.tbPlayer and Wlls:CountTableLeng(tbCurRoundInfo.tbPlayer) > 0) then
				for nId, szPlayerName in pairs(tbCurRoundInfo.tbPlayer) do
					nMaxD = nMaxD + tbParam.tbDamage[nId];
				end
				if (nMaxD > 0) then
					self:SetPartDamage(szLeagueName, self.nRoundIndex, nMaxD);
				end
			end
		end
		
	end
	
	for _, pPlayer in pairs(self:GetPlayerList()) do
		local szLeagueName = League:GetMemberLeague(Wlls.LGTYPE, pPlayer.szName);
		self:OnSyncDamageUi(pPlayer, szLeagueName, 0);
	end
	
	for szLookLeagueName, tbLooker in pairs(self.tbLooker) do
		for nLookId, nIsOn in pairs(tbLooker) do
			local pPlayer = KPlayer.GetPlayerObjById(nLookId);
			if pPlayer and nIsOn == 1 then
				self:OnSyncDamageUi(pPlayer, szLookLeagueName, 1);
			end
		end
	end
end

function MissionBase:SetPartDamage(szLeagueName, nRound, nMaxDamage)
	if (self.tbLeagueList[szLeagueName]) then
		local tbLeague = self.tbLeagueList[szLeagueName];
		if (tbLeague and tbLeague.tbPart) then
			local tbPart = tbLeague.tbPart[nRound];
			if (tbPart) then
				self.tbLeagueList[szLeagueName].tbPart[nRound].nMaxDamage = nMaxDamage;
			end
		end
	end
end

function MissionBase:GetPartDamage(szLeagueName, nRound)
	if (self.tbLeagueList[szLeagueName]) then
		local tbLeague = self.tbLeagueList[szLeagueName];
		if (tbLeague and tbLeague.tbPart) then
			local tbPart = tbLeague.tbPart[nRound];
			if (tbPart) then
				return tbPart.nMaxDamage;
			end
		end
	end
	return 0;
end

function MissionBase:OnSyncDamageUi(pPlayer, szLeagueName, nIsLooker)
	local szMacthName = self.tbLeagueList[szLeagueName].szMacthName;
	if self.MIS_UI[self:GetGameState()] and self.tbLeagueList[szMacthName] and self.tbLeagueList[szLeagueName] then
		local nMaxMyDamage = self:GetPartDamage(szLeagueName, self.nRoundIndex) or 0;
		local nMaxMatchDamage = self:GetPartDamage(szMacthName, self.nRoundIndex) or 0;
		if self.MIS_UI[self:GetGameState()][3] and nMaxMyDamage and nMaxMatchDamage then
			local szMsg2 = string.format(self.MIS_UI[self:GetGameState()][3], nMaxMatchDamage, nMaxMyDamage);
			if nIsLooker == 1 then
				szMsg2 = string.format(Wlls.MIS_UI_LOOKER, szMacthName, nMaxMyDamage, szLeagueName, nMaxMyDamage);
			end
			local szExMsg	= self:GetExUiMsg(szLeagueName);
			szMsg2 = szMsg2 .. "\n" .. szExMsg;
			Wlls:UpdateMsgUi(pPlayer, szMsg2);
		end
	end	
end

-- 1表示因为有队员提前离开赛场结束
-- 我打算把所有的胜负判断放在这里，只要在这里判断的时候如果有一方队员不在，那么另一方在的就算胜利
-- 当然会出现一些特例或者异常情况导致胜负判断有问题
function MissionBase:OnEndRound(nRound)
	local tbLeagueList = {};
	
	if (nRound <= 0 or nRound > self.nRoundCount) then
		return 0;
	end
	
	for szLeagueName, tbInfo in pairs(self.tbLeagueList) do
		local tbCurRoundInfo = self:GetCurRoundInfo(szLeagueName, nRound);
		if (tbCurRoundInfo.nResult <= 0) then
			tbLeagueList[#tbLeagueList +1] = { 
				szLeagueName = szLeagueName, 
				tbInfo	=	tbCurRoundInfo,
			};
		end
	end
	local nFlagA	= 0;
	local nFlagB	= 0;
	
	if (#tbLeagueList < 2) then
		return 0;
	end
	
	if (tbLeagueList[1]) then
		local tbInfo = tbLeagueList[1].tbInfo;
		if (tbInfo and Wlls:CountTableLeng(tbInfo.tbPlayer) <= 0) then
			nFlagA = 1;
		end
	end

	if (tbLeagueList[2]) then
		local tbInfo = tbLeagueList[2].tbInfo;
		if (tbInfo and Wlls:CountTableLeng(tbInfo.tbPlayer) <= 0) then
			nFlagB = 1;
		end
	end

	local nMatchTime = self.tbMisEventList[self:GetGameState()][2] + self.tbMisEventList[self:GetGameState() - 1][2];
	
	local szWin		= tbLeagueList[1].szLeagueName;
	local szLose	= tbLeagueList[2].szLeagueName;
	local nWin		= 1;
	local nWinTime	= nMatchTime;
	local nLose		= 3;
	local nLoseTime	= 0;


	if (0 == nFlagA and 0 == nFlagB) then
		local nMaxDamageA = self:GetPartDamage(szWin, nRound) or 0;
		local nMaxDamageB = self:GetPartDamage(szLose, nRound) or 0;
		if (nMaxDamageA == nMaxDamageB) then
			nWin = 2;
			nLose = 2;
			nLoseTime = nMatchTime;
		elseif (nMaxDamageA > nMaxDamageB) then
			szWin = tbLeagueList[2].szLeagueName;
			szLose = tbLeagueList[1].szLeagueName;
		end
	elseif (0 == nFlagA and 1 == nFlagB) then
		-- A组获胜
	elseif (1 == nFlagA and 0 == nFlagB) then
		szWin = tbLeagueList[2].szLeagueName;
		szLose = tbLeagueList[1].szLeagueName;
	elseif (1 == nFlagA and 1 == nFlagB) then
		nWin = 2;
		nLose = 2;
		nLoseTime = nMatchTime;
	end

	self:SetPartPkResult(szWin, nWin, nRound, nMatchTime);
	self:SendResultMsg(szWin, szLose, self.tbLeagueList[szWin].tbPlayerList, nWin, nRound);
	self:LookerRoundResult(nRound, szWin, nWin);
	
	self:SetPartPkResult(szLose, nLose, nRound, nMatchTime);
	self:SendResultMsg(szLose, szWin, self.tbLeagueList[szLose].tbPlayerList, nLose, nRound);
	self:LookerRoundResult(nRound, szLose, nLose);
	
	self:KickRoundPlayer(nRound);

	return 1;
end

function MissionBase:SendResultMsg(szLeagueName, szMacthName, tbPlayerList, nResult, nRound)
	local tbMsg = 
	{
		[1] = {string.format("<color=yellow>您的战队在第%s局中战胜了%s，恭喜获得了胜利。<color>", nRound, szMacthName or "")},
		[2] = {string.format("<color=green>您的战队在第%s局中战平了%s，表现还不错。<color>", nRound, szMacthName or "")},
		[3] = {string.format("<color=blue>您的战队在第%s局中败给了%s，下次继续努力吧。<color>", nRound, szMacthName or "")},
	}

	for nId, szName in pairs(tbPlayerList) do
		local pPlayer = KPlayer.GetPlayerByName(szName);
		if pPlayer and tbMsg[nResult] and tbMsg[nResult][1] then
			Dialog:SendBlackBoardMsg(pPlayer, tbMsg[nResult][1]);
			local szMsg = string.format("<color=red>[本场比赛公告]<color>%s", tbMsg[nResult][1]);
			pPlayer.Msg(szMsg);
		end
	end
	if (tbMsg[nResult] and tbMsg[nResult][1]) then
		Wlls:WriteLog("[Wlls]RoundResult" .. "\t" .. szLeagueName .. "\t" .. szMacthName .. "\t" .. nResult .. "\t" .. nRound);
	end
end

function MissionBase:KickRoundPlayer(nRound)
	for szLeagueName, tbInfo in pairs(self.tbLeagueList) do
		local tbCurRoundInfo = self:GetCurRoundInfo(szLeagueName, nRound);
		if (tbCurRoundInfo and tbCurRoundInfo.tbPlayer) then
			for i, szPlayerName in pairs(tbCurRoundInfo.tbPlayer) do
				local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
				if (pPlayer) then
					self:OnLeaveRound(pPlayer, 1);
				end
			end
		end
	end
end

-- 加入活动
function MissionBase:JoinGame(pPlayer, nCamp)
	self:JoinPlayer(pPlayer, nCamp);
end

function MissionBase:GetCurRoundInfo(szLeagueName, nRound)
	if (not szLeagueName or not nRound) then
		return;
	end

	if (not self.tbLeagueList[szLeagueName]) then
		return;
	end
	
	local tbLeague = self.tbLeagueList[szLeagueName];

	if (not tbLeague or not tbLeague.tbPart) then
		return;
	end
	
	local tbPart = tbLeague.tbPart[nRound];
	return tbPart;
end

function MissionBase:RemovePlayerFromPart(szPlayerName)
	for szLeagueName, tbInfo in pairs(self.tbLeagueList) do
		if (tbInfo.tbPart) then
			for i, tbPart in pairs(tbInfo.tbPart) do
				if (tbPart.tbPlayer) then
					for j, szName in pairs(tbPart.tbPlayer) do
						if (szName == szPlayerName) then
							self.tbLeagueList[szLeagueName].tbPart[i].tbPlayer[j] = nil;
							return 1;
						end
					end
				end
			end
		end
	end
end

function MissionBase:OnLeaveRound(pPlayer, nState)
	local szLeagueName		= League:GetMemberLeague(Wlls.LGTYPE, pPlayer.szName);
	local szMacthName		= self.tbLeagueList[szLeagueName].szMacthName;
	local nCurPlayerFlag	= self:CheckIsCurRoundPlayer(szLeagueName, pPlayer.szName, self.nRoundIndex);

	self:SetPkPlayerState(pPlayer, 0);
	self:RemovePlayerFromPart(pPlayer.szName);
	self.tbLeagueList[szLeagueName].tbAtGameList[pPlayer.nId] = nil;
	
	
	local nMaxDamageA = self:GetPartDamage(szLeagueName, self.nRoundIndex) or 0;
	local nMaxDamageB = self:GetPartDamage(szMacthName, self.nRoundIndex) or 0;		

	if self.nGameState == 1 or self.nGameState == 2 then
		if (nCurPlayerFlag == 1) then	
			pPlayer.Msg(string.format("\n<color=green>对方受伤总量：<color=red>%s\n<color=green>本方受伤总量：<color=blue>%s", nMaxDamageB, nMaxDamageA));
		end

		local nFlagGoNext = 0;
		if (nState ~= 1 and 1 == nCurPlayerFlag and self.nGameState == 2) then
			local tbCurRoundInfo = self:GetCurRoundInfo(szLeagueName, self.nRoundIndex);
			if (tbCurRoundInfo and tbCurRoundInfo.tbPlayer and (Wlls:CountTableLeng(tbCurRoundInfo.tbPlayer) <= 0)) then
				self:OnEndRound(self.nRoundIndex);
				nFlagGoNext = 1;
			end
		end
		if (self.nOverGameFlag == 1) then
			return 0;
		end

		-- 提前结束比赛
		if (Wlls:CountTableLeng(self.tbLeagueList[szLeagueName].tbAtGameList) <= 0) then
			if (self.nStateJour < #self.tbMisEventList - 1) then
				self.nStateJour = #self.tbMisEventList - 1;
			end
			self:ProcessDirOverGame(self.nRoundIndex + 1);
			self.nOverGameFlag = 1;
			nFlagGoNext = 1;
			
			if (self.nGameState == 1) then
				nFlagGoNext = 0;
			end
			
		end

		if (nFlagGoNext == 1) then
			self:GoNextState();
		end
	end
	return 0;
end

-- 结束活动
function MissionBase:EndGame()
	self:OnEndGame();
	for _, pPlayer in pairs(self:GetPlayerList()) do
		self:KickPlayer(pPlayer, 1);
	end
	
	for szLookLeagueName, tbLooker in pairs(self.tbLooker) do
		self:KickLooker(szLookLeagueName);
	end	
	self:Close();
end

function MissionBase:GetGameState()
	return self.nStateJour;
end

function MissionBase:AddLeague(pPlayer, szName, szLeagueName, szMacthName)
	if not self.tbLeagueList[szLeagueName] then
		self.tbLeagueList[szLeagueName] = {};
		self.tbLeagueList[szLeagueName].szMacthName		= szMacthName;
		self.tbLeagueList[szLeagueName].tbDamage		= {};
		self.tbLeagueList[szLeagueName].nMaxDamage		= 0;
		self.tbLeagueList[szLeagueName].tbAtGameList	= {};
		self.tbLeagueList[szLeagueName].tbPlayerList	= {};
		self.tbLeagueList[szLeagueName].tbPart			= self:GetNewPartList();
	end
	if not self.tbLeagueList[szMacthName] then
		self.tbLeagueList[szMacthName] = {};
		self.tbLeagueList[szMacthName].szMacthName	= szLeagueName;
		self.tbLeagueList[szMacthName].tbDamage		= {};
		self.tbLeagueList[szMacthName].nMaxDamage	= 0;
		self.tbLeagueList[szMacthName].tbAtGameList = {};
		self.tbLeagueList[szMacthName].tbPlayerList = {};
		self.tbLeagueList[szMacthName].tbPart		= self:GetNewPartList();	
	end
	self.tbLeagueList[szLeagueName].tbDamage[pPlayer.nId] = 0;
	self.tbLeagueList[szLeagueName].tbAtGameList[pPlayer.nId] = szName;
	self.tbLeagueList[szLeagueName].tbPlayerList[pPlayer.nId] = szName;
	
	for i, tbPart in ipairs(self.tbLeagueList[szLeagueName].tbPart) do
		if (tbPart.nPlayerCount <= 0) then
			self.tbLeagueList[szLeagueName].tbPart[i].tbPlayer[pPlayer.nId] = szName;
			table.insert(self.tbLeagueList[szLeagueName].tbPart[i].tbLogPlayer, szName);
			self.tbLeagueList[szLeagueName].tbPart[i].nPlayerCount = self.tbLeagueList[szLeagueName].tbPart[i].nPlayerCount + 1;
			break;
		end
	end
	
	return 0;
end

-- 让队长安排出场顺序
function MissionBase:OnGamePkChoose()
	self.nChooseState	= 1;
	self.nGameState		= 1;
	if (not self.tbLeagueList) then
		return 0;
	end

	for _, pPlayer in pairs(self:GetPlayerList()) do
		pPlayer.SetFightState(0);
	end	
	
	for szLeagueName, tbInfo in pairs(self.tbLeagueList) do
		local tbTeam = Wlls:GetLeagueMemberList(szLeagueName);
		if (not tbTeam) then
			return 0;
		end
		
		if (tbInfo.tbPart) then
			for _, szMemberName in ipairs(tbTeam) do
				local pPlayer = KPlayer.GetPlayerByName(szMemberName);
				if (pPlayer and pPlayer.IsCaptain() == 1 and self:GetPlayerGroupId(pPlayer) >= 0) then
					local tbNameList = {};
					self:RefreshPlayerPart(szLeagueName);
					for i, tbPart in ipairs(tbInfo.tbPart) do
						if (tbPart.tbPlayer and Wlls:CountTableLeng(tbPart.tbPlayer) > 0) then
							tbNameList[#tbNameList + 1] = { nOrgIndex = i, tbPlayer = tbPart.tbPlayer };
						end
					end
					pPlayer.CallClientScript({"UiManager:OpenWindow", "UI_WLLSCHOOSEWIN", tbNameList});
				end
				
				if (self:GetPlayerGroupId(pPlayer) >= 0) then
					self:OnGamePkUi(pPlayer, szLeagueName);
				end
			end
		end		
	end
end

function MissionBase:RefreshPlayerPart(szLeagueName)
	local tbTemp = {};
	local tbLostPlayer = {};
	if (not self.tbLeagueList or not self.tbLeagueList[szLeagueName]) then
		return 0;
	end
	local tbPartList = self.tbLeagueList[szLeagueName].tbPart;
	for i, tbPart in pairs(tbPartList) do
		if (tbPart.tbPlayer and Wlls:CountTableLeng(tbPart.tbPlayer) > 0) then
			table.insert(tbTemp, tbPart);
		else
			table.insert(tbLostPlayer, tbPart);
		end
	end
	for i, tbPart in pairs(tbLostPlayer) do
		table.insert(tbTemp, tbPart);
	end

	if (#tbTemp > 0) then
		self.tbLeagueList[szLeagueName].tbPart = tbTemp;
	end
end

-- 给出选择结果
function MissionBase:OnGamePkChooseEnd()
	self.nChooseState = 0;

	for szLeagueName, tbInfo in pairs(self.tbLeagueList) do
		local tbTeam = Wlls:GetLeagueMemberList(szLeagueName);
		if (tbTeam) then
			for _, szMemberName in ipairs(tbTeam) do
				local pPlayer = KPlayer.GetPlayerByName(szMemberName);
				if (pPlayer and pPlayer.IsCaptain() == 1) then
					pPlayer.CallClientScript({"UiManager:CloseWindow", "UI_WLLSCHOOSEWIN"});
					break;
				end
			end
		end
	end

	for _, pPlayer in pairs(self:GetPlayerList()) do
		self:SetPkPlayerState(pPlayer, 0);
	end

	self:OnGameRest();
end

function MissionBase:OnReadyPkPlayer(nRound)
	for szLeagueName, tbInfo in pairs(self.tbLeagueList) do
		local tbCurRoundInfo = self:GetCurRoundInfo(szLeagueName, nRound);
		if (tbCurRoundInfo and tbCurRoundInfo.tbPlayer) then
			for i, szName in pairs(tbCurRoundInfo.tbPlayer) do
				local pPlayer = KPlayer.GetPlayerByName(szName);
				-- 表示人在，且在mission里
				if (pPlayer and self:GetPlayerGroupId(pPlayer) >= 0) then
					self:SetPkPlayerState(pPlayer, 1);
				end
			end
		end
	end
end

-- 0 表示场内队员观战状态，1 表示战斗准备状态消除隐身
function MissionBase:SetPkPlayerState(pPlayer, nState)
	
	if (not pPlayer or self:GetPlayerGroupId(pPlayer) < 0) then
		return 0;
	end
	
	if (0 == nState) then
		pPlayer.SetFightState(0);
		pPlayer.SetBroadHitState(0);		
		pPlayer.AddSkillState(Looker.DEF_SKILL, 1, 1, 3600*18);
	else
		pPlayer.RemoveSkillState(Looker.DEF_SKILL);
		pPlayer.SetFightState(1);
	end
	
	pPlayer.nPkModel = Player.emKPK_STATE_PRACTISE;
end

-- 一局过后休息一下，并把下场玩家传上来
function MissionBase:OnGameRest()
	self.nGameState = 1;
	if (self.nRoundIndex > self.nRoundCount) then
		self:OnGameOver();
		return 0;
	end

	for _, pPlayer in pairs(self:GetPlayerList()) do
		if (pPlayer) then
			local szLeagueName = League:GetMemberLeague(Wlls.LGTYPE, pPlayer.szName);
			self:OnGamePkUi(pPlayer, szLeagueName);
		end
	end

	if (self.nOverGameFlag and self.nOverGameFlag == 1) then
		return;
	end
	
	self:OnSyncDamage(1);

	if (self.nRoundIndex > 0) then
		self:OnEndRound(self.nRoundIndex);
		for szLeagueName, tbInfo in pairs(self.tbLeagueList) do
			local tbCurRoundInfo = self:GetCurRoundInfo(szLeagueName, self.nRoundIndex);
			if (tbCurRoundInfo and tbCurRoundInfo.tbPlayer) then
				for i, szName in pairs(tbCurRoundInfo.tbPlayer) do
					local pPlayer = KPlayer.GetPlayerByName(szName);
					if (pPlayer and self:GetPlayerGroupId(pPlayer) >= 0) then
						self:SetPkPlayerState(pPlayer, 0);
					end
				end
			end
		end
	end

	self.nRoundIndex = self.nRoundIndex + 1;

	self:OnReadyPkPlayer(self.nRoundIndex);
end

function MissionBase:ProcessDirOverGame(nCurRound)
	for szLeagueName, tbInfo in pairs(self.tbLeagueList) do
		if (Wlls:CountTableLeng(self.tbLeagueList[szLeagueName].tbAtGameList) == 0) then
			local szMacthName = self.tbLeagueList[szLeagueName].szMacthName;
			for i = nCurRound, self.nRoundCount do 
				local tbRoundInfo = self:GetCurRoundInfo(szMacthName, i);
				if (tbRoundInfo and tbRoundInfo.tbPlayer and Wlls:CountTableLeng(tbRoundInfo.tbPlayer) > 0) then
					self:SetPartPkResult(szMacthName, 1, i, 0);
				end
			end
			return 1;
		end
	end
	return 0;
end

function MissionBase:OnEndGame()
	local tbLeagueList = {};
	
	for szLeagueName, tbInfo in pairs(self.tbLeagueList) do
		local nResult = 0;
		local nMatchTime = 0;
		if (tbInfo.tbPart) then
			for i, tbPart in pairs(tbInfo.tbPart) do
				if (tbPart.nResult and tbPart.nResult == 1) then
					nResult = nResult + 1;
				end
				nMatchTime = nMatchTime + tbPart.nMatchTime;
			end
		end
		tbLeagueList[#tbLeagueList + 1] = {
			szLeagueName	= szLeagueName,
			nResult			= nResult;
			nMatchTime		= math.floor(nMatchTime / Env.GAME_FPS);
		};
	end
	
	if (not tbLeagueList or #tbLeagueList <= 0) then
		return 0;
	end
	
	local szWin		= tbLeagueList[1].szLeagueName;
	local nWinTime	= tbLeagueList[1].nMatchTime;
	local szLoss	= tbLeagueList[2].szLeagueName;
	local nLossTime	= tbLeagueList[2].nMatchTime;
	
	local nTie		= 0;
	if (tbLeagueList[1].nResult == tbLeagueList[2].nResult) then
		nTie = 1;
	elseif (tbLeagueList[1].nResult < tbLeagueList[2].nResult) then
		szWin		= tbLeagueList[2].szLeagueName;
		nWinTime	= tbLeagueList[2].nMatchTime;
		szLoss		= tbLeagueList[1].szLeagueName;
		nLossTime	= tbLeagueList[1].nMatchTime;
	end
	
	if (1 == nTie) then
		Wlls:MacthAward(szWin, szLoss, self.tbLeagueList[szWin].tbPlayerList, 2, nWinTime);
		Wlls:MacthAward(szLoss, szWin, self.tbLeagueList[szLoss].tbPlayerList, 2, nLossTime);
		self:LookerResult(szWin, 2);
		self:LookerResult(szLoss, 2);
		self:KickLooker(szWin, string.format("比赛结束，<color=yellow>%s<color> 和 <color=yellow>%s<color> 打为平手。", szWin, szLoss));
		self:KickLooker(szLoss, string.format("比赛结束，<color=yellow>%s<color> 和 <color=yellow>%s<color> 打为平手。", szWin, szLoss));	
	else
		Wlls:MacthAward(szWin, szLoss, self.tbLeagueList[szWin].tbPlayerList, 1, nWinTime);
		Wlls:MacthAward(szLoss, szWin, self.tbLeagueList[szLoss].tbPlayerList, 3, nLossTime);
		self:LookerResult(szWin, 1);
		self:LookerResult(szLoss, 3);
		self:KickLooker(szWin, string.format("比赛结束，<color=yellow>%s<color> 战胜了 <color=yellow>%s<color>。", szWin, szLoss));
		self:KickLooker(szLoss, string.format("比赛结束，<color=yellow>%s<color> 败给了 <color=yellow>%s<color>。", szLoss, szWin));
	end

	if Wlls.AdvMatchState == 5 then
		Wlls:SetAdvMacthResult(self.nMissionReadyId);
	end

	self.tbLeagueList[szLoss].tbAtGameList = {};
	self.tbLeagueList[szWin].tbAtGameList = {};
	Wlls:RemoveLookerLeague(szWin);
	Wlls:RemoveLookerLeague(szLoss);	
end

function MissionBase:KickLooker(szLeagueName, szResult)
	if self.tbLooker[szLeagueName] then
		for nLookId in pairs(self.tbLooker[szLeagueName]) do
			local pPlayer = KPlayer.GetPlayerObjById(nLookId);
			if pPlayer then
				Looker:Leave(pPlayer);
				if szResult then
					pPlayer.Msg(szResult);
				end
			end
		end
		self.tbLooker[szLeagueName] = nil;
	end		
end

function MissionBase:LookerRoundResult(nRound, szLeagueName, nResult)
	if self.tbLooker[szLeagueName] then
		local szMacthName = self.tbLeagueList[szLeagueName].szMacthName;
		local szMsg2 = nil; 
		if self.tbLeagueList[szMacthName] and self.tbLeagueList[szLeagueName] then
			local nMaxDamage = self:GetPartDamage(szLeagueName, nRound);
			local nMatchDamage = self:GetPartDamage(szMacthName, nRound);
			if nMaxDamage and nMatchDamage then
				szMsg2 = string.format(Wlls.MIS_UI_LOOKER, szMacthName, nMatchDamage, szLeagueName, nMaxDamage);
			end
		end
		if szMsg2 then
			if nResult == 1 then
				szMsg2 = szMsg2 .. string.format("\n<color=green>本轮胜利方：<color><color=gold>%s<color>", szLeagueName);
			else
				szMsg2 = szMsg2 .. string.format("\n<color=green>本轮胜利方: <color><color=gold>%s<color>", szMacthName);
			end
			local szExMsg	= self:GetExUiMsg(szLeagueName);
			szMsg2			= szMsg2 .. "\n" .. szExMsg;

			for nLookId in pairs(self.tbLooker[szLeagueName]) do
				local pPlayer = KPlayer.GetPlayerObjById(nLookId);
				if pPlayer then	
					self.tbLooker[szLeagueName][nLookId] = 2;
					Wlls:UpdateMsgUi(pPlayer, szMsg2);
				end
			end
		end
	end
end

function MissionBase:LookerResult(szLeagueName, nResult)
	if self.tbLooker[szLeagueName] then
		local szMacthName = self.tbLeagueList[szLeagueName].szMacthName;
		local szMsg2 = nil; 
		if self.tbLeagueList[szMacthName] and self.tbLeagueList[szLeagueName] then
			if self.tbLeagueList[szMacthName].nMaxDamage and self.tbLeagueList[szLeagueName].nMaxDamage then
				szMsg2 = string.format(Wlls.MIS_UI_LOOKER, szMacthName, self.tbLeagueList[szMacthName].nMaxDamage, szLeagueName, self.tbLeagueList[szLeagueName].nMaxDamage);
			end
		end	
		if szMsg2 then
			if nResult == 1 then
				szMsg2 = szMsg2 .. string.format("\n<color=green>胜利方：<color><color=gold>%s<color>", szLeagueName);
			else
				szMsg2 = szMsg2 .. string.format("\n<color=green>胜利方: <color><color=gold>%s<color>", szMacthName);
			end
			local szExMsg	= self:GetExUiMsg(szLeagueName);
			szMsg2			= szMsg2 .. "\n" .. szExMsg;

			for nLookId in pairs(self.tbLooker[szLeagueName]) do
				local pPlayer = KPlayer.GetPlayerObjById(nLookId);
				if pPlayer then	
					self.tbLooker[szLeagueName][nLookId] = 2;
					Wlls:UpdateMsgUi(pPlayer, szMsg2);
				end
			end
		end
	end
end

function MissionBase:GiveChooseResult(szPlayerName, tbPartList)
	if (not szPlayerName or not tbPartList) then
		return 0;
	end

	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if (not pPlayer) then
		return 0;
	end
	
	if (self.nChooseState ~= 1) then
		pPlayer.Msg("安排出场顺序的时间已过！");
		return 0;
	end
	
	if (self:GetPlayerGroupId(pPlayer) < 0) then
		return 0;
	end

	if (pPlayer.IsCaptain() ~= 1) then
		return 0;
	end
	
	local szLeagueName = League:GetMemberLeague(Wlls.LGTYPE, szPlayerName);
	if (not szLeagueName) then
		return 0;
	end
	
	local tbLeague = self.tbLeagueList[szLeagueName];
	
	if (not tbLeague) then
		return 0;
	end
	
	local tbPart = tbLeague.tbPart;
	if (not tbPart) then
		return 0;
	end

	local tbFlag = {};
	for i, nIndex in pairs(tbPartList) do
		local nOrgIndex = i;
		local nChange	= nIndex;
		while (nChange and (nChange > 0) and (nChange <= self.nRoundCount) and not tbFlag[nChange]) do
			local tbTempChange	= tbPart[nChange];
			tbPart[nChange]		= tbPart[nOrgIndex];
			tbPart[nOrgIndex]	= tbTempChange;
			tbFlag[nChange]		= 1;
			nChange = tbPartList[nChange];
		end
	end

	pPlayer.Msg("出场次序安排成功，请耐心等待比赛开始！");
end

function MissionBase:GetNewPartList()
	local tbTempPart = {};
	for i=1, self.nRoundCount do
		local tbPart		= {};
		tbPart.tbPlayer		= {};
		tbPart.tbLogPlayer	= {};
		tbPart.nMaxDamage	= 0;
		tbPart.nResult		= 0;
		tbPart.nPlayerCount	= 0;
		tbPart.nMatchTime	= 0;
		table.insert(tbTempPart, tbPart);
	end
	return tbTempPart
end

function MissionBase:JoinLooker(szLeagueName, nPlayerId)
	self.tbLooker[szLeagueName] = self.tbLooker[szLeagueName] or {};
	self.tbLooker[szLeagueName][nPlayerId] = 1;
end

function MissionBase:LeaveLooker(szLeagueName, nPlayerId)
	if not self.tbLooker[szLeagueName] then
		return 0;
	end
	self.tbLooker[szLeagueName][nPlayerId] = nil;
	return 1;
end

-- end Mission_PerPk_Part
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
-- 大mission，负责管理旗下各个小mission
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------

local ManagerMissionBase = Mission:New();
Wlls.GameMission_PerPk = ManagerMissionBase;

-- 开启活动
function ManagerMissionBase:StartGame(nReadyId, nGameLevel, nNowMissionType)
	-- 设定可选配置项
	local tbMacthCfg = Wlls:GetMacthTypeCfg(Wlls:GetMacthType());
	local tbMacthLevelCfg = Wlls:GetMacthLevelCfg(Wlls:GetMacthType(), nGameLevel);
	
	--随机会场
	local tbLeaveMap =  Wlls:GetLeaveMapPos(tbMacthCfg, tbMacthLevelCfg, nReadyId);
	
	self.tbMisCfg	= {
		tbEnterPos		= {},					-- 进入坐标
		tbLeavePos		= {},	-- 离开坐标
		tbCamp			= {},	-- 分别设定阵营
		nForbidTeam		= 1,
		nPkState		= Player.emKPK_STATE_PRACTISE,--战斗模式
		nInLeagueState	= 1,	-- 联赛模式
	}
	self.nMacthMap  = tbMacthLevelCfg.tbMacthMap[nReadyId];
	self.nMacthMapPatch	= tbMacthLevelCfg.tbMacthMapPatch[nReadyId];	--后备地图
	
	self.nGameLevel = nGameLevel;
	self.nGameState = 1;		--开始准备pk阶段
	self.tbLeagueList = {};		--战队成员表
	self.tbMisEventList	= Wlls.MIS_LIST;
	self.tbGroups	= {};
	self.tbPlayers	= {};
	self.tbTimers	= {};
	self.tbLooker	= {};
	self.nStateJour = 0;
	self.tbMissionList = self.tbMissionList or {};
	self.tbMisFlag	= {};
	self.nMissionType = nNowMissionType;
	self.nReadyId = nReadyId;
	self.tbNowStateTimer = nil;
	self:GoNextState()	-- 开始报名
	for nIndex, tbMission in pairs(self.tbMissionList) do
		tbMission:StartGame(nReadyId, nGameLevel, nIndex);
	end
end

function ManagerMissionBase:GetMissionType()
	return self.nMissionType;
end

function ManagerMissionBase:OnGamePk()
	self.nGameState = 2;
	for i, tbMission in pairs(self.tbMissionList) do
		tbMission:OnStart();
	end
end

function ManagerMissionBase:OnGameOver(nDirClose)
	if (not nDirClose or nDirClose ~= 1) then	
		if self.nGameState ~= 2 then
			return 0;
		end
	end
	for i, tbMission in pairs(self.tbMissionList) do
		if (tbMission and tbMission:IsOpen() ~= 0) then
			tbMission:OnGameOver();
		end
	end
	self.nGameState = 3;
	self:EndGame();
	return 0;
end

-- 加入活动
function ManagerMissionBase:JoinGame(pPlayer, nCamp)
	local szLeagueName = League:GetMemberLeague(Wlls.LGTYPE, pPlayer.szName);
	if (not szLeagueName) then
		return 0;
	end
	local tbLeague = self.tbLeagueList[szLeagueName];
	local tbMission = self.tbMissionList[tbLeague.nMissionIndex];
	if (not tbMission) then
		return 0;
	end
	tbMission:JoinGame(pPlayer, nCamp);

	local szMacthName = self.tbLeagueList[szLeagueName].szMacthName;
	local szMsg = string.format("<color=gold>%s Vs %s\n\n", szLeagueName, szMacthName);
	Wlls:OpenSingleUi(pPlayer, szMsg.."<color=green>离比赛开始还有：<color=white>%s<color>\n\n", self:GetStateLastTime());
end

-- 结束活动
function ManagerMissionBase:EndGame()
	self:Close();
end

function ManagerMissionBase:GetGameState()
	return self.nStateJour;
end

function ManagerMissionBase:AddLeague(pPlayer, szName, szLeagueName, szMacthName)
	if not self.tbLeagueList[szLeagueName] then
		self.tbLeagueList[szLeagueName] = {};
		self.tbLeagueList[szLeagueName].szMacthName = szMacthName;
		self.tbLeagueList[szLeagueName].tbDamage = {};
		self.tbLeagueList[szLeagueName].nMaxDamage = 0;
		self.tbLeagueList[szLeagueName].tbAtGameList = {};
		self.tbLeagueList[szLeagueName].tbPlayerList = {};
		self.tbLeagueList[szLeagueName].nMissionIndex = 0;
	end
	if not self.tbLeagueList[szMacthName] then
		self.tbLeagueList[szMacthName] = {};
		self.tbLeagueList[szMacthName].szMacthName = szLeagueName;
		self.tbLeagueList[szMacthName].tbDamage = {};
		self.tbLeagueList[szMacthName].nMaxDamage = 0;
		self.tbLeagueList[szMacthName].tbAtGameList = {};
		self.tbLeagueList[szMacthName].tbPlayerList = {};
		self.tbLeagueList[szMacthName].nMissionIndex = 0;
	end
	self.tbLeagueList[szLeagueName].tbDamage[pPlayer.nId] = 0;
	self.tbLeagueList[szLeagueName].tbAtGameList[pPlayer.nId] = szName;
	self.tbLeagueList[szLeagueName].tbPlayerList[pPlayer.nId] = szName;
	
	local tbMyMission = self.tbMissionList[self.tbLeagueList[szLeagueName].nMissionIndex];

	if (not tbMyMission) then
		local nMissionIndex = 0;
		for nIndex, tbMission in pairs(self.tbMissionList) do
			if (not self.tbMisFlag[nIndex] or (self.tbMisFlag[nIndex] and self.tbMisFlag[nIndex] == 0)) then
				nMissionIndex = nIndex;
				tbMyMission = tbMission;
				break;
			end
		end
		if (nMissionIndex <= 0) then
			tbMyMission = Lib:NewClass(Wlls.Mission_PerPk_Part);
			if (not tbMyMission) then
				Wlls:WriteLog("There is no tbMyMission " .. szName .. "  " .. szLeagueName .. " " .. szMacthName);
				return 0;
			end

			self.tbMissionList[#self.tbMissionList + 1] = tbMyMission;
			nMissionIndex = #self.tbMissionList;
			
			tbMyMission:StartGame(self.nReadyId, self.nGameLevel, nMissionIndex);
		end
		self.tbMisFlag[nMissionIndex] = 1;
		self.tbLeagueList[szLeagueName].nMissionIndex = nMissionIndex;
		self.tbLeagueList[szMacthName].nMissionIndex = nMissionIndex;
	end
	
	tbMyMission:AddLeague(pPlayer, szName, szLeagueName, szMacthName);
	
	return 0;
end

function ManagerMissionBase:KickGame(pPlayer)
	local szLeagueName = League:GetMemberLeague(Wlls.LGTYPE, pPlayer.szName);
	if (not szLeagueName) then
		return 0;
	end
	local tbLeague = self.tbLeagueList[szLeagueName];
	local tbMission = self.tbMissionList[tbLeague.nMissionIndex];
	if (not tbMission) then
		return 0;
	end
	if tbMission:GetPlayerGroupId(pPlayer) >= 0 then
		tbMission:KickPlayer(pPlayer);
	end
end

-- 认为其中有一个开着就算此系统都开着
--function ManagerMissionBase:IsOpen()
--	if (self.nGameState == 3) then
--		return 0;
--	end
--	return 1;
--end

function ManagerMissionBase:GetPlayerGroupId(pPlayer)
	if (not pPlayer) then
		return -1;
	end
	
	local szLeagueName = League:GetMemberLeague(Wlls.LGTYPE, pPlayer.szName);
	if (not szLeagueName) then
		return -1;
	end
	local tbLeague = self.tbLeagueList[szLeagueName];
	local tbMission = self.tbMissionList[tbLeague.nMissionIndex];
	if (not tbMission) then
		return -1;
	end
	return tbMission:GetPlayerGroupId(pPlayer);
end

function ManagerMissionBase:GiveChooseResult(szPlayerName, tbResult)
	if (not tbResult or not szPlayerName) then
		return 0;
	end
	
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if (not pPlayer) then
		return 0;
	end

	local szLeagueName		= League:GetMemberLeague(Wlls.LGTYPE, szPlayerName);

	if (not szLeagueName) then
		return 0;
	end
	
	local tbMission = self:GetLeagueMission(szLeagueName);

	if (not tbMission) then
		return 0;
	end
	
	tbMission:GiveChooseResult(szPlayerName, tbResult);
	return 1;
end

function ManagerMissionBase:JoinLooker(szLeagueName, nPlayerId)
	local tbMission = self:GetLeagueMission(szLeagueName);

	if (not tbMission) then
		return 0;
	end

	tbMission:JoinLooker(szLeagueName, nPlayerId);
end

function ManagerMissionBase:LeaveLooker(szLeagueName, nPlayerId)
	local tbMission = self:GetLeagueMission(szLeagueName);
	
	if (not tbMission) then
		return 0;
	end

	return tbMission:LeaveLooker(szLeagueName, nPlayerId);
end

function ManagerMissionBase:GetLeagueMission(szLeagueName)
	if (not szLeagueName) then
		return;
	end
	
	local tbLeague = self.tbLeagueList[szLeagueName];
	
	if (not tbLeague) then
		return;
	end
	
	if (not tbLeague.nMissionIndex) then
		return;
	end
	
	return self.tbMissionList[tbLeague.nMissionIndex];	
end

Wlls.tbMissionType[1] = Wlls.GameMission_PerPk;
