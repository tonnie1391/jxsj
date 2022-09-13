-- 文件名  : castlefight_mission.lua
-- 创建者  : zounan
-- 创建时间: 2010-11-04 15:59:55
-- 描述    : 基础MISSION

Require("\\script\\mission\\castlefight\\castlefight_def.lua");

CastleFight.Mission = CastleFight.Mission or Mission:New();
local tbMission = CastleFight.Mission;

--排序	
local sort_cmp = function (tb1, tb2)
	return tb1[2] > tb2[2];
end

function tbMission:SetMissionBattleTimer(szMsg, nTime, nClear)
	for _, pPlayer in pairs(self:GetPlayerList()) do
		Dialog:ShowBattleMsg(pPlayer, 1, 0);
		Dialog:SetBattleTimer(pPlayer, szMsg, nTime);
		if nClear and nClear == 1 then
			Dialog:SendBattleMsg(pPlayer, "");	
		end
	end
end

function tbMission:SetMatchTimer(szMsg, nTime)	
	for _, pPlayer in pairs(self:GetPlayerList()) do
		Dialog:ShowBattleMsg(pPlayer, 1, 0);
		Dialog:SetBattleTimer(pPlayer, szMsg, nTime);
	end
end



function tbMission:Init(tbEnterPos, tbLeavePos, nMatchType) -- tbLeavePos
---	print(">>>>>>>>>",nMapId);
	if self:IsOpen() == 1 then
		print("Đã khởi tạo lại!");
		return;
	end
-- ?pl me.NewWorld(1834,1636,3179)
	self.tbMisCfg = {
		tbEnterPos				= {[1] = {tbEnterPos[1][1], tbEnterPos[1][2], tbEnterPos[1][3]}, [2] = {tbEnterPos[2][1], tbEnterPos[2][2], tbEnterPos[2][3]}},	-- 进入坐标
		tbLeavePos				= {[0] = tbLeavePos},	-- 离开坐标
		tbCamp					= {[1]=1,[2]=2},
		--nPkState				= Player.emKPK_STATE_PRACTISE,
		nPkState				= Player.emKPK_STATE_CAMP,		
		nInLeagueState			= 1,
		nDeathPunish			= 1,
		-- nOnDeath				= 1,
		nForbidStall			= 1,
		nFightState				= 1,
		--nOnKillNpc 		= 1,
		nForbidSwitchFaction	= 1,
		nLogOutRV				= Mission.LOGOUTRV_DEF_MISSION_CASTLEFIGHT,
	};	

	-- mission 基类的数据
	self.nStateJour 	= 0;
	self.tbGroups	= {};
	self.tbPlayers	= {};
	self.tbTimers	= {};	
	self.tbMisEventList	= CastleFight.tbMisEventList;
			
	self.tbPlayerShotSkill		= {};		--每个玩家左键的快捷键
	self.nMapId		= tbEnterPos[1][1];
	self.nMatchType = nMatchType or 0;
	self.nAddMoneyFrame = 0;
	self.nActiveTimes   = 0;
	
	self.tbTrapList		= CastleFight:GetTrapInfo(self.nMapId);
	self.tbPLayerTrap   = self.tbTrapList.tbPlayerTrap;
	self.tbGroupCaptain = {};
	self.tbPlayerEx 	= {};
	self.tbResult		= {};			--结果
	self:InitCampInfo();
	
	self.nLoseCamp 		= 0;
	self.nGameOver		= 0;	
	self.nIsPlaying		= 0;
	self.nCloseRemainTime = 0;
	self.nGameOverType	= 1;
	
	self.tbGroupName = {};
	self.nGroupNum = 0;
	self.nMatchType = nMatchType or 0;
	self.tbGroupCaptain = {};
	self.tbItemSkill = {};
	self.nWinAddBouns = 10000;
	if (2 == self.nMatchType) then
		self.nWinAddBouns = 1000;
	end
	self.tbLogBuildingNum = {
			[16] = 0,
			[17] = 0,
			[18] = 0,
			[19] = 0,
			[20] = 0,
			[31] = 0,
		};
end

function tbMission:InitCampInfo()
	-- 两个阵营
	self.tbCampList = {};
	for i = 1, 2 do
		self.tbCampList[i] = Lib:NewClass(CastleFight.tbBaseCamp);
		self.tbCampList[i]:Init(self,i, self.tbTrapList.tbNpcTrap[i],CastleFight.TEMP_OBJ[i], CastleFight.NPC_MOVE[i], CastleFight.BOSS_POS[i]);
	end
end


function tbMission:StartGame()	
	self:SetMissionBattleTimer("<color=green>Thời gian chuẩn bị: <color=white>%s<color>\n", CastleFight.WAIT_TIME_FPS, 1);
	self:BroadcastBlackBoardMsg("Sử dụng các phím tắt trên điểm xanh dưới đất.");

	for i = 1 , 2 do
		self.tbCampList[i]:OnStart();
	end	
	
	self:GoNextState();
	-- 数据埋点
	StatLog:WriteStatLog("stat_info", "fight_YLG", "start", 0, 1);
end

function tbMission:BeginPlay()
	self.nIsPlaying = 1;
	self:BroadcastBlackBoardMsg("Hãy xây dựng kiến trúc để tấn công và phòng thủ.");	
	self:BroadcastSystemMsg("<color=green>[Dạ Lam Quan-Giới thiệu]<color> <color=yellow>Xây dựng kiến trúc bằng cách tiêu thụ quân hưởng, phá hủy kiến trúc đối phương để nhận quân hưởng, tích lũy.<color>");
	self:SetMissionBattleTimer("<color=green>Thời gian kết thúc: <color=white>%s<color>\n", CastleFight.MATCH_TIME_FPS);
	self:CreateTimer(Env.GAME_FPS, self.Active, self);	
end

function tbMission:EndPlay()
	self.nGameOver  = 1;
	self.nIsPlaying = 0;
	--刷新界面
	if self.nLoseCamp == 0 then
		self:BroadcastBlackBoardMsg(string.format("Thi đấu kết thúc!"));
		self:BroadcastSystemMsg(string.format("Thi đấu kết thúc!"));
	else
		for i = 1 ,2 do
			if self.nLoseCamp == i then
				if (2 ~= self.nMatchType) then
					self:BroadcastBlackBoardMsg(string.format("Rất tiếc vì không giành được chiến thắng."),i);
				end
				
			--	self:BroadcastBlackBoardMsg(string.format("Thi đấu kết thúc!很遗憾你们输了。"),i);
			--	self:BroadcastSystemMsg(string.format("Thi đấu kết thúc!很遗憾你们输了。"),i);
			else
				if (2 ~= self.nMatchType) then
					self:BroadcastBlackBoardMsg(string.format("Chúc mừng đội giành được chiến thắng!"),i);
				else
					for nPlayerId, tbInfo in pairs(self.tbPlayerEx) do
						if (tbInfo.nCamp == i) then
							tbInfo.nScore = math.floor(tbInfo.nScore * CastleFight.WIN_ADD_SCORE_TIMES) + tbInfo.nScore;
						end
					end
				end

				local tbWinCamp = self:GetCampInfo(i);
				if (tbWinCamp) then
					tbWinCamp:AddCampScore(self.nWinAddBouns);
				end
			--	self:BroadcastBlackBoardMsg(string.format("Thi đấu kết thúc!恭喜你们获得比赛的胜利"),i);
			--	self:BroadcastSystemMsg(string.format("Thi đấu kết thúc!恭喜你们获得比赛的胜利"),i);
			end
		end
	end
	
	local tbScore = self:GenerateAndSendMsg();
	
	self:SetMissionBattleTimer("<color=green>Thời gian nghỉ ngơi: <color=white>%s<color>\n", CastleFight.ENDREST_TIME_FPS);

	--默认只能算单人成绩
	if not tbScore or #tbScore <= 0 then
		for nPlayerId, tbInfo in pairs(self.tbPlayerEx) do
			table.insert(self.tbResult, {nPlayerId, tbInfo.nScore});
		end	
		local sort_cmp = function (tb1, tb2)
			return tb1[2] > tb2[2];
		end
		table.sort(self.tbResult, sort_cmp);
	else
		for _, tbInfo in ipairs(tbScore) do
			table.insert(self.tbResult, {tbInfo[6], tbInfo[2]});
		end
	end

	self:CalcPlayerInfo();
	for i = 1 ,2 do
		(self:GetCampInfo(i)):Close();
	end

	--团体比赛奖励
--	self:SetAword();
	
	-- 数据埋点
	local nCosumeTime = math.floor((CastleFight.MATCH_TIME_FPS - self.nCloseRemainTime) / 18);
	StatLog:WriteStatLog("stat_info", "kin_game", "waste_time", 0, 4, self.nMatchType, nCosumeTime);
	
	local szLog = "";
	local nFlag = 0;
	for nId, nNum in pairs(self.tbLogBuildingNum) do
		if (nFlag > 0) then
			szLog = szLog .. ",";
		end
		szLog = szLog .. string.format("%s,%s", nId, nNum);
		nFlag = 1;
	end
	StatLog:WriteStatLog("stat_info", "kin_game", "castlefight_buildnum", 0, szLog);
	
	--提前到休息时间就算最终奖励了
	if self.tbCallbackOnClose then
		Lib:CallBack(self.tbCallbackOnClose);
	end
	
	for _, pPlayer in pairs(self:GetPlayerList()) do
		if self.tbCallbackEndPlay and type(self.tbCallbackEndPlay[1]) == "function" then
			self.tbCallbackEndPlay[1](self.tbCallbackEndPlay[2], pPlayer);
		end
	end
end

function tbMission:GetCurRank(pPlayer)
	for nRank, tbRank in pairs(self.tbResult) do
		if tbRank[1] == pPlayer.nId then
			return nRank;
		end
	end
	return 0;
end

function tbMission:GetResult()
	return self.tbResult;
end

--设置奖励
function tbMission:SetAword()	
	local nResult = 3;	
	if self.tbResult[1][2] > self.tbResult[2][2] then
		nResult = 1;
	elseif self.tbResult[1][2] < self.tbResult[2][2] then
		nResult = 2;
	end
--	if self:GetPlayerCount(2) <= 0 then
--		nResult = 1;
--	end
--	if self:GetPlayerCount(1) <= 0 then
--		nResult = 2;
--	end


	local tbResult_Ex = {};
	for nPlayerId, tbInfo in pairs(self.tbPlayerEx) do
		tbResult_Ex[tbInfo.nCamp] = tbResult_Ex[tbInfo.nCamp] or {};
		table.insert(tbResult_Ex[tbInfo.nCamp], {tbInfo.szName,tbInfo.nScore});
	end 
	for i  = 1, 2 do
		table.sort(tbResult_Ex[i], sort_cmp);
	end
	

	CastleFight:AwardSingleSport(self:GetPlayerIdList(1), self:GetPlayerIdList(2), nResult, tbResult_Ex, self.nGameOverType);

 	CastleFight:UpdateLadder(); -- 刷排行榜
end



function tbMission:EndGame()
	self.nGameOver  = 1;
	self.nIsPlaying = 0;	
	ClearMapNpc(self.nMapId);
	ClearMapObj(self.nMapId);	
	self:Close();
	return 0;
end

function tbMission:OnClose()
	
end


-- MISSION 主循环
function tbMission:Active()
	if self:IsPlaying() == 0 then
		return 0;
	end	
	
	self:SysAddMoney();
	for i = 1 , 2 do
		self.tbCampList[i]:OnActive();
	end
	self:GenerateAndSendMsg();
end

function tbMission:IsGameOver()
	return self.nGameOver or 1;
end

function tbMission:IsPlaying()
	return self.nIsPlaying;
end

--变身
function tbMission:Transform(pPlayer, nGroup)	
	if pPlayer.GetSkillState(CastleFight.TRANSFORM_SKILL_ID) <= 0 then
		local nMapId, nX, nY = pPlayer.GetWorldPos();
		local tbLevel = {[0] = {1,3,5},[1] = {2,4,6}};
		if not tbLevel[pPlayer.nSex] then
			tbLevel[pPlayer.nSex] = {1,3,5};
		end
		local nSkillLevel = tbLevel[pPlayer.nSex][Random(3) + 1];
		pPlayer.CastSkill(CastleFight.TRANSFORM_SKILL_ID, nSkillLevel, nX, nY);		
	end
end

-- 获取结果TODO
-- {[1] --> (nGroupId, grade), [2] --> ...}
--function tbMission:GetResult()
--	return self.tbResult;
--end

-- 右侧排名
function tbMission:GenerateAndSendMsg()
	local tbMsg = {};
	local tbMsgEx = {};
	local tbScore = {};
	local szName  = "";
	for nPlayerId, tbInfo in pairs(self.tbPlayerEx) do
		table.insert(tbScore,{tbInfo.nCamp, tbInfo.nScore, tbInfo.szName, tbInfo.nColor, tbInfo.nOnLine, nPlayerId});
	end
	local szMsg = "";

	--table.sort(self.tbGrade_player, sort_cmp);
	table.sort(tbScore, sort_cmp);
	--if (2 ~= self.nMatchType) then
	tbMsg = {"\nBảng điểm:"};
	for i = 1, 2 do
		table.insert(tbMsg, string.format("%s <color=white>%d<color>",  CastleFight:AddStrColor(string.format("%-16s","Đội-"..(self.tbGroupCaptain[i] or "")),i), self:GetCampScore(i)));
	end
	szMsg = table.concat(tbMsg, "\n");
	--end
	
	tbMsgEx = {"\n\nXếp hạng người chơi:"};	
	for _, tbInfo in ipairs(tbScore) do
		local szPlayerMsg  = string.format("%s <color=white>%d<color>", CastleFight:AddStrColor(string.format("%-16s",tbInfo[3]),tbInfo[4], tbInfo[5]), tbInfo[2]);
		table.insert(tbMsgEx, szPlayerMsg);	
	end
	szMsg = szMsg..(table.concat(tbMsgEx, "\n"));
	
	for _, pPlayer in pairs(self:GetPlayerList())do
		local szMsgEx = "";
		if (2 ~= self.nMatchType) then
			szMsgEx = szMsg..string.format("\n\n<color=yellow>Kỹ năng Tất Sát-Toàn Đội: %s\nQuân hưởng còn lại: %s\n",self:GetCampSkillCountByPlayer(pPlayer), CastleFight:GetPlayerMoney(pPlayer));
		else
			szMsgEx = szMsg..string.format("\n\n<color=yellow>Kỹ năng Tất Sát: %s\nQuân hưởng còn lại: %s\n",CastleFight:GetFinalSkillTimes(pPlayer), CastleFight:GetPlayerMoney(pPlayer));
		end
		Dialog:SendBattleMsg(pPlayer, szMsgEx, 1);
--		pPlayer.Msg(">>>>>>>>>>",szMsgEx);
	end
	return tbScore;
end

--发黑色广告
function tbMission:BroadcastBlackBoardMsg(szMsg,nGroupId)
	nGroupId = nGroupId or 0;
	for _, pPlayer in pairs(self:GetPlayerList(nGroupId)) do
		Dialog:SendBlackBoardMsg(pPlayer, szMsg);
	end
end


function tbMission:BroadcastSystemMsg(szMsg,nGroupId)
	nGroupId = nGroupId or 0;
	for _, pPlayer in pairs(self:GetPlayerList(nGroupId)) do
		pPlayer.Msg(szMsg);
	end	
end

function tbMission:OnJoin(nGroupId)
	if nGroupId ~= 1 and nGroupId ~= 2 then
		print("【ERR】CastleFight: tbMission:OnJoin nGroupId error:",nGroupId);
		return;
	end
	
	if self:GetPlayerCount(nGroupId) == 1 then -- 第一个进的默认为队长
		self.tbGroupCaptain[nGroupId] = me.szName;
	end
	
	self:Transform(me, nGroupId);
	CastleFight:SetPlayerMoney(me, CastleFight.SYS_ADDMONEY_START);
	--me.SetFightState(0);	
	--记录玩家技能快捷键并设置新的键
	Player:SaveShotCut(self.tbPlayerShotSkill);	
	CastleFight:AddPlayerItem(me);	
	
	for i =1, #CastleFight.ITEM_LIST do
		FightSkill:SetShortcutItem(me, CastleFight.ITEM_TO_SHORTCUT[i], CastleFight.ITEM_LIST[i], 1);
		--FightSkill:SetShortcutItem(me, i, CastleFight.ITEM_LIST[i], 1);
		--FightSkill:SetShortcutItem(me, i, CastleFight.ITEM_LIST[i]);
	end
	
	
	
--  加大招 TODO
--	if me.IsHaveSkill(CastleFight.FINAL_SKILL_ID) <= 0 then
--		me.AddFightSkill(CastleFight.FINAL_SKILL_ID, 1);
--	end
--	FightSkill:SetShortcutSkill(me, #CastleFight.ITEM_LIST + 1, CastleFight.FINAL_SKILL_ID,1);

	-- NPC 被动无敌
--	if me.IsHaveSkill(CastleFight.WUDI_SKILL_ID) <= 0 then
--		me.AddFightSkill(CastleFight.WUDI_SKILL_ID, 1);
--	end
	CastleFight:SetFinalSkillTimes(me,CastleFight.FINAL_SKILL_TIMES);
	self:GetCampInfo(nGroupId):AddSkillCount(CastleFight.FINAL_SKILL_TIMES);


	local tbPlayerTempTable = CastleFight:GetPlayerTempTable(me);
	tbPlayerTempTable.tbMission = self;
	tbPlayerTempTable.nCamp 	= nGroupId;	
	self.tbPlayerEx[me.nId] = {nCamp = nGroupId,nScore = 0 ,nColor = nGroupId, szName = me.szName, nGetMoney = 0,nKillNpc = 0,nBuild = 0, nOnLine = 1,};
	
	
	self.tbPLayerTrap[nGroupId]:AttachCharacterToTrap(me);
end

function tbMission:OnLeave(nGroupId, szReason)	
	-- 打回原形
	if me.GetSkillState(CastleFight.TRANSFORM_SKILL_ID) > 0 then
		me.RemoveSkillState(CastleFight.TRANSFORM_SKILL_ID);
	end
	
	me.RestoreLife();
	me.LeaveTeam();
	
	if me.IsHaveSkill(CastleFight.FINAL_SKILL_ID) == 1 then
		me.DelFightSkill(CastleFight.FINAL_SKILL_ID);
	end	
	
--	if me.IsHaveSkill(CastleFight.WUDI_SKILL_ID) == 1 then
--		me.DelFightSkill(CastleFight.WUDI_SKILL_ID);
--	end		

	--恢复快捷键	
	Player:RestoryShotCut(self.tbPlayerShotSkill);
	--清掉所有买的东西
	CastleFight:ClearPlayerItem(me);
	self:GetCampInfo(nGroupId):ConsumSkillCount(CastleFight:GetFinalSkillTimes(me));
	CastleFight:SetFinalSkillTimes(me,0);	
	
	-- 回到入口处
	-- me.SetFightState(0);
	Dialog:ShowBattleMsg(me,  0,  0);

	--清掉军饷
	CastleFight:SetPlayerMoney(me, 0);

	local tbPlayerTempTable = CastleFight:GetPlayerTempTable(me);
	tbPlayerTempTable.tbMission = nil;
	tbPlayerTempTable.nCamp 	= nil;	
	self.tbPLayerTrap[1]:DettachCharacterToTrap(me);
--	if self:GetPlayerCount(nGroupId) == 0 and self.nStateJour < 4  and self.nAwordFlag ~= 1 then -- 全队早退会输掉比赛
--	end

	--FightAfter:Fly2City(me);
	self.tbPlayerEx[me.nId].nOnLine = 0;
	if self:IsGameOver() == 0 and self:GetPlayerCount() == 0 then	-- 全部玩家掉线
		self:TerminateGame();
	end
	if self.tbOnLevelMision then
		Lib:CallBack(self.tbOnLevelMision);
	end
end

function tbMission:AddPlayerScore(nPlayerId,nAddScore)
	if not nPlayerId or not self.tbPlayerEx[nPlayerId] then
		return;
	end
	self.tbPlayerEx[nPlayerId].nScore = self.tbPlayerEx[nPlayerId].nScore + nAddScore;	
	self.tbCampList[self.tbPlayerEx[nPlayerId].nCamp]:AddCampScore(nAddScore);
end

function tbMission:GetPlayerScore(nPlayerId)
	return self.tbPlayerEx[nPlayerId].nScore;
end

function tbMission:GetCampScore(nCamp)
	return self.tbCampList[nCamp].nScore;
end

function tbMission:GetCampSkillCountByPlayer(pPlayer)
	local nCamp = self.tbPlayerEx[pPlayer.nId].nCamp;
	return self:GetCampSkillCount(nCamp);
end

function tbMission:GetCampSkillCount(nCamp)
	return self.tbCampList[nCamp].nSkillCount;
end

function tbMission:ConsumSkillCount(nPlayerId,nConsum)
	local nCamp = self.tbPlayerEx[nPlayerId].nCamp;
	self:GetCampInfo(nCamp):ConsumSkillCount(nConsum);
end

function tbMission:GetCampInfo(nCamp)
	return self.tbCampList[nCamp];	
end

-- 系统发钱
function tbMission:SysAddMoney()
	self.nAddMoneyFrame = self.nAddMoneyFrame + 1;	
	self.nAddMoneyFrame = self.nAddMoneyFrame % CastleFight.SYS_ADDMONEY_INTERVAL;
	if self.nAddMoneyFrame ~= 1 then
		return;
	end
	
	local tbPlayer = self:GetPlayerList();
	local nAddMoney = CastleFight.SYS_ADDMONEY_NUM;
	for _, pPlayer in pairs(tbPlayer) do	
		CastleFight:AddPlayerMoney(pPlayer,nAddMoney);	
		self:AddPlayerGetMoneyNum(pPlayer.nId,nAddMoney);
	end
end

function tbMission:OnNpcDeath(pNpc, pKiller)
	local pPlayer = pKiller.GetPlayer();			
	local tbNpcInfo = CastleFight.NPC_TEMPLATE[CastleFight:GetNpcId(pNpc)];
	local nDeathMoney = tbNpcInfo.nDeathMoney;
	if pPlayer then
		if (self.tbItemSkill and self.tbItemSkill[pPlayer.nId] and self.tbItemSkill[pPlayer.nId] == 1) then
			nDeathMoney = nDeathMoney + tbNpcInfo.nDeathSpeMoney;
		end

		self:AddPlayerScore(pPlayer.nId, tbNpcInfo.nDeathScore);
		CastleFight:AddPlayerMoney(pPlayer,nDeathMoney);
		self:AddPlayerKillNpcNum(pPlayer.nId);
		self:AddPlayerGetMoneyNum(pPlayer.nId,nDeathMoney);
	else		
		local nPlayerId = CastleFight:GetNpcOwnerId(pKiller);

		if (self.tbItemSkill and self.tbItemSkill[nPlayerId] and self.tbItemSkill[nPlayerId] == 1) then
			nDeathMoney = nDeathMoney + tbNpcInfo.nDeathSpeMoney;
		end		
		
		pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		self:AddPlayerScore(nPlayerId, tbNpcInfo.nDeathScore);	
		self:AddPlayerKillNpcNum(nPlayerId);
		if pPlayer and self:GetPlayerGroupId(pPlayer) ~= -1 then
			CastleFight:AddPlayerMoney(pPlayer,nDeathMoney);
			self:AddPlayerGetMoneyNum(nPlayerId,nDeathMoney);
		end
	end
	
	if tbNpcInfo.nIsBuilding == 1 then
		(self:GetCampInfo(pNpc.GetTempTable("Npc").nCamp)):DelBuilding(pNpc);		
	end		
end

function tbMission:OnBossDeath(pNpc, pKiller)
	if self:IsPlaying() == 0 then
		return;
	end
	self.nGameOverType = 2;
	self.nCloseRemainTime = self:GetStateLastTime(); -- 获取剩余时间,用于计算耗时
	self.nLoseCamp = pNpc.GetTempTable("Npc").nCamp;
	self:GoNextState();
end

function tbMission:AddNpcBuff(nCamp,nBuffId)
	self:GetCampInfo(nCamp):AddNpcBuff(nBuffId);
end

-- 以下函数皆为统计用 蛮无聊的~~~ nGetMoney = 0,nKillNpc = 0,nBuild = 0,};

-- 统计玩家总共获得了多少军饷
function tbMission:AddPlayerGetMoneyNum(nPlayerId,nAddMoney)
	if nPlayerId and self.tbPlayerEx[nPlayerId] and nAddMoney > 0 then
		self.tbPlayerEx[nPlayerId].nGetMoney = self.tbPlayerEx[nPlayerId].nGetMoney + nAddMoney;
	end
end

-- 统计玩家总共杀死了多少个NPC
function tbMission:AddPlayerKillNpcNum(nPlayerId)
	if nPlayerId and self.tbPlayerEx[nPlayerId] then
		self.tbPlayerEx[nPlayerId].nKillNpc = self.tbPlayerEx[nPlayerId].nKillNpc + 1;
	end
end

-- 统计玩家总共造了多少个建筑
function tbMission:AddPlayerBuildNum(nPlayerId)
	if nPlayerId and self.tbPlayerEx[nPlayerId] then
		self.tbPlayerEx[nPlayerId].nBuild = self.tbPlayerEx[nPlayerId].nBuild + 1;
	end
end

--统计以上
function tbMission:CalcPlayerInfo()
	local tbKillNpc = {};
	local tbBuild	= {};
	local tbMoney	= {};
	
	local tbPlayer = self:GetPlayerList(); -- 要不要改成不在线也可以？
	
	for _, pPlayer in pairs(tbPlayer) do	
		table.insert(tbKillNpc,{pPlayer.szName,self.tbPlayerEx[pPlayer.nId].nKillNpc});
		table.insert(tbBuild,  {pPlayer.szName,self.tbPlayerEx[pPlayer.nId].nBuild});
		table.insert(tbMoney,  {pPlayer.szName,self.tbPlayerEx[pPlayer.nId].nGetMoney});
	end
	
	table.sort(tbKillNpc, sort_cmp);
	table.sort(tbBuild,  sort_cmp);
	table.sort(tbMoney,  sort_cmp);
	
	if #tbMoney > 0 then
		self:BroadcastSystemMsg(string.format("Top 1 Quân hưởng: <color=yellow>%s<color>",tbMoney[1][1]));
	end

	if #tbBuild > 0 then
		self:BroadcastSystemMsg(string.format("Top 1 Kiến trúc: <color=yellow>%s<color>",tbBuild[1][1]));
		
	end
	
	if #tbKillNpc > 0 then
		self:BroadcastSystemMsg(string.format("Top 1 hạ địch: <color=yellow>%s<color>",tbKillNpc[1][1]));
	end	

end

--[[
?pl CastleFight.temp = CastleFight.temp or Lib:NewClass(CastleFight.Mission);
local tbMission = CastleFight.temp;
   tbMission:Init(1834,{1,1600,3200},1);
   tbMission:JoinPlayer(me,1);
   --]]
   

-- 所有人掉线
function tbMission:TerminateGame()
	if (self.nIsPlaying == 1) then
		self:EndPlay();
	else
		for i = 1 ,2 do
			(self:GetCampInfo(i)):Close();
		end		
	end	
	
	self.nGameOver  = 1;
	self.nIsPlaying = 0;
	ClearMapNpc(self.nMapId);
	ClearMapObj(self.nMapId);	
	self:Close();
	StatLog:WriteStatLog("stat_info", "fight_YLG", "award", 0, 0, "fallline");
	return 0;
end

function tbMission:__start()
	self:StartGame();
end

function tbMission:AddGroupName(pPlayer, nGroupId, szGroupName)
	if szGroupName then
		self.tbGroupName[nGroupId] = szGroupName;
		return;
	end
	
	if self.tbGroupName[nGroupId] then
		return;
	end
	if pPlayer.nTeamId == 0 then
		self.tbGroupName[nGroupId] = pPlayer.szName;
	else
		local tbPlayerList = KTeam.GetTeamMemberList(pPlayer.nTeamId);
		local pCaptin = KPlayer.GetPlayerObjById(tbPlayerList[1]);
		if pCaptin then
			self.tbGroupName[nGroupId] = pCaptin.szName;
		else
			self.tbGroupName[nGroupId] = pPlayer.szName;
		end
	end
end

function tbMission:GetGroupName(nGroup)
	return self.tbGroupName[nGroup] or tostring(nGroup);
end

function tbMission:GetGroupIdByName(szName)
	for nGroupId, szGroupName in pairs(self.tbGroupName) do
		if (szGroupName == szName) then
			return nGroupId;
		end
	end
	return 0;
end


