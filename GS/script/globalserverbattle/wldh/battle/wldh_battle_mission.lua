-------------------------------------------------------
-- 文件名　：wldh_battle_mission.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-08-24 09:46:53
-- 文件描述：
-------------------------------------------------------

Require("\\script\\globalserverbattle\\wldh\\battle\\wldh_battle_def.lua");

local tbMissionBase = Wldh.Battle.tbMissionBase or Mission:New();
Wldh.Battle.tbMissionBase = tbMissionBase;

-- 当前战场状态：
--	0、战役未开启
--	1、战役报名中
--	2、战役战斗进行中
--	3、战役刚刚结束了
tbMissionBase.nState = nil;	
						
-- 构造初始化
-- 第几场，地图id，地图数据，时间，宋战队名，金战队名
function tbMissionBase:init(nBattleIndex, nMapId, tbMapData, szBattleTime, szLeagueNameSong, szLeagueNameJin, nFinalStep)

	assert(self ~= Battle.tbMissionBase);
	assert(not self.nState);
	
	-- 未开始
	self:_SetState(0);

	self.nBattleIndex		= nBattleIndex;  		-- 第几个场地
	self.nMapId				= nMapId;				-- 地图ID	
	self.tbMapData 			= tbMapData;			-- 地图数据
	self.nFinalStep			= nFinalStep;			-- 决赛标志(1-半决赛,2-决赛)
	
	self.tbLeagueName =
	{
		[Wldh.Battle.CAMPID_SONG] = szLeagueNameSong,
		[Wldh.Battle.CAMPID_JIN] = szLeagueNameJin,		
	};
		
	self.szBattleName		= tbMapData.szMapName;	-- 名字
	self.nRuleType 			= 4;					-- 模式类型
	self.tbPlayerJoin		= {} 					-- 参加过的玩家的ID表
	self.nBattleKey			= tonumber(szBattleTime .. nBattleIndex);	-- 安全检查用

	-- 指定场地
	local tbMapDataSong	= tbMapData[1];
	local tbMapDataJin = tbMapData[3];

	-- 双方阵营
	local tbCampSong = Lib:NewClass(Wldh.Battle.tbCampBase, Wldh.Battle.CAMPID_SONG, tbMapDataSong, szLeagueNameSong, self);
	local tbCampJin	= Lib:NewClass(Wldh.Battle.tbCampBase, Wldh.Battle.CAMPID_JIN, tbMapDataJin, szLeagueNameJin, self);
	
	-- 对手阵营
	tbCampSong.tbOppCamp = tbCampJin;
	tbCampJin.tbOppCamp = tbCampSong;
	
	self.tbCamps = 
	{
		[Wldh.Battle.CAMPID_SONG] = tbCampSong,
		[Wldh.Battle.CAMPID_JIN] = tbCampJin,
	};
	
	self.tbCampSong	= tbCampSong;
	self.tbCampJin = tbCampJin;
	
	-- 比赛规则
	self.tbRule	= Lib:NewClass(Wldh.Battle.tbRuleBases[self.nRuleType]);
	self.tbRule:Init(self);

	-- 地图控制（Trap点事件）
	local tbMapCamp	= 
	{
		[1]	= tbCampSong,
		[3]	= tbCampJin,
	};
	
	-- 加入到map表中**不知道干啥用
	local tbMapClass = Lib:NewClass(Wldh.Battle.tbMapBase, tbMapCamp);
	Map.tbClass[nMapId]	= tbMapClass;
	
	-- 后营坐标点
	local tbBaseCampPos	= 
	{
		[Wldh.Battle.CAMPID_SONG]	= tbMapDataSong["BaseCamp"],
		[Wldh.Battle.CAMPID_JIN]	= tbMapDataJin["BaseCamp"],
	};

	local tbSongIcon 	= {"\\image\\ui\\001a\\main\\chatchanel\\chanel_song.spr", 	"\\image\\ui\\001a\\main\\chatchanel\\btn_chanel_song.spr"};
	local tbKingIcon	= {"\\image\\ui\\001a\\main\\chatchanel\\chanel_jin.spr",	"\\image\\ui\\001a\\main\\chatchanel\\btn_chanel_jin.spr"};
	local tbChannel		=
	{
		[Wldh.Battle.CAMPID_SONG]	= {string.format("宋方赛场%d", nBattleIndex), 20, tbSongIcon[1], tbSongIcon[2]},
		[Wldh.Battle.CAMPID_JIN]	= {string.format("金方赛场%d", nBattleIndex), 20, tbKingIcon[1], tbKingIcon[2]},
	};
	
	-- 设定Mission可选配置项
	self.tbMisCfg	= 
	{
		tbLeavePos		= Wldh.Battle.tbSignUpInfo[nMapId],	-- 离开坐标
		tbEnterPos		= tbBaseCampPos,					-- 进入坐标
		tbDeathRevPos	= tbBaseCampPos,					-- 死亡重生点
		tbChannel		= tbChannel,						-- 聊天频道
		tbCamp			= Wldh.Battle.NPC_CAMP_MAP,			-- 分别设定临时阵营
		nForbidTeam		= 0,								-- 禁止组队换色
		nInBattleState	= 1,								-- 禁止不同阵营组队
		nPkState		= Player.emKPK_STATE_CAMP,			-- PK状态
		nDeathPunish	= 1,								-- 无死亡惩罚
		nOnDeath		= 1,								-- 开启玩家死亡回调
		nOnMovement		= 1,								-- 参加某项活动
		nForbidSwitchFaction = 1,							-- 禁止切换门派
		nForbidStall	= 1,								-- 禁止摆摊
		nDisableOffer	= 1,								-- 禁止...未知
		nDisableFriendPlane = 1,							-- 禁止好友界面
		nDisableStallPlane	= 1,							-- 禁止交易界面
	};
	
	self.tbMisEventList = 
	{
		{1, Wldh.Battle.TIMER_SIGNUP, "OnTimer_SignupEnd"},
		{2, Wldh.Battle.TIMER_GAME, "OnTimer_GameEnd"},
	};
	
	self.nStateJour = 0;
	self.tbNowStateTimer = nil;
end

-- mission开启
function tbMissionBase:OnOpen()
	
	self:_SetState(1, 0);
	self:GoNextState();

	self:CreateTimer(Wldh.Battle.TIMER_SIGNUP_MSG, self.OnTimer_SignupMsg, self);
	self:CreateTimer(Wldh.Battle.TIMER_SYNCDATA, self.OnTimer_SyncData, self);
	
	self.nGameSyncCount	= math.floor((Wldh.Battle.TIMER_GAME + Wldh.Battle.TIMER_SIGNUP) / Wldh.Battle.TIMER_SYNCDATA);
	self.nSignUpMsgCount = math.floor(Wldh.Battle.TIMER_SIGNUP / Wldh.Battle.TIMER_SIGNUP_MSG);
end

-- 关闭mission
function tbMissionBase:OnClose()
	
	self.tbRule:OnClose();

	if 2 ~= self.nState then	-- 因人数不够等情况引起的未开战就结束
		self:_SetState(3);
	else
		self:_SetState(3, 2);
		
		local nWinCampId	= self.tbRule:GetWinCamp();		
		local nSongResult	= nil;
		local nJinResult	= nil;
		
		
		-- 计算胜负结果
		if nWinCampId == Wldh.Battle.CAMPID_SONG then
			nSongResult	= Wldh.Battle.RESULT_WIN;
			nJinResult = Wldh.Battle.RESULT_LOSE;
		
		elseif nWinCampId == Wldh.Battle.CAMPID_JIN then
			nSongResult	= Wldh.Battle.RESULT_LOSE;
			nJinResult = Wldh.Battle.RESULT_WIN;
		
		else
			nSongResult	= Wldh.Battle.RESULT_TIE;
			nJinResult = Wldh.Battle.RESULT_TIE;
		end
	
		self.tbCampSong:OnEnd(nSongResult);
		self.tbCampJin:OnEnd(nJinResult);	

		-- 返回结果
		local tbResult = 
		{
			[1] = {self.tbLeagueName[1], nSongResult},
			[2] = {self.tbLeagueName[2], nJinResult},
		};

		if self.nFinalStep then
			Wldh.Battle:FinalEnd_GS(self.nBattleIndex, tbResult, self.nFinalStep);
		else
			Wldh.Battle:RoundEnd_GS(self.nBattleIndex, tbResult);
		end
	end
	
	-- 标记比赛结束
	self.tbCampSong:SetPlayerCount(-1);
	self.tbCampJin:SetPlayerCount(-1);

	Wldh.Battle.tbMissions[self.nBattleIndex] = nil;
end
	
-- 加入Mission
function tbMissionBase:OnJoin(nGroupId)
	
	local tbCamp = self.tbCamps[nGroupId];
	local pPlayer = me;
	
	-- 加入阵营
	tbCamp:OnJoin(pPlayer);
	
	-- 离队
	pPlayer.TeamApplyLeave();
	
	-- add 禁止仇杀
	pPlayer.ForbidEnmity(1);
	pPlayer.ForbidExercise(1);		
	
	if self.tbPlayerJoin[pPlayer.nId] == nil then
		self.tbPlayerJoin[pPlayer.nId] = 1;
	end
	
	-- 参加次数加1
	local nAttend = GetPlayerSportTask(pPlayer.nId, Wldh.GBTASKID_GROUP, Wldh.GBTASKID_BATTLE_ATTEND_ID) or 0;
	
	nAttend = nAttend + 1;
	if nAttend > Wldh.Battle.MAX_MATCH then
		nAttend = Wldh.Battle.MAX_MATCH;
	end
	
	SetPlayerSportTask(pPlayer.nId, Wldh.GBTASKID_GROUP, Wldh.GBTASKID_BATTLE_ATTEND_ID, nAttend);
	
	-- 反外挂
	DeRobot:OnMissionJoin(pPlayer);
end

-- 玩家离开前
function tbMissionBase:BeforeLeave(nGroupId)
	local pPlayer = me;
	self.tbRule:OnLeave(pPlayer);
end

-- 玩家离开战场
function tbMissionBase:OnLeave(nGroupId)
	
	local pPlayer = me;
	
	self.tbCamps[nGroupId]:OnLeave(pPlayer);

	pPlayer.TeamApplyLeave();
	pPlayer.SetFightState(0);
	
	pPlayer.ForbidEnmity(0);
	pPlayer.ForbidExercise(0);		
	
	DeRobot:OnMissionLeave(pPlayer)
end

-- 死亡处理
function tbMissionBase:OnDeath(pKillerNpc) 
	
	local pPlayer = me;
	local nGroupId = self:GetPlayerGroupId(pPlayer);
	
	self.tbRule:OnLeave(pPlayer);
	
	local tbDeathBattleInfo	= Wldh.Battle:GetPlayerData(pPlayer);
	self.tbCamps[nGroupId]:OnPlayerDeath(tbDeathBattleInfo);
	
	local pKillerPlayer = pKillerNpc.GetPlayer();
	if pKillerPlayer then
		
		local nKillerGroupId = self:GetPlayerGroupId(pKillerPlayer);
		if nKillerGroupId == nGroupId then
			return;
		end

		local tbKillerBattleInfo = Wldh.Battle:GetPlayerData(pKillerPlayer);

		-- 文字要改
		local szMsg	= string.format("%s方%s <color=yellow>%s<color> 击退了 %s方%s <color=yellow>%s<color>",
			Wldh.Battle.NAME_CAMP[nKillerGroupId], Wldh.Battle.NAME_RANK[tbKillerBattleInfo.nRank], tbKillerBattleInfo.pPlayer.szName,
			Wldh.Battle.NAME_CAMP[nGroupId], Wldh.Battle.NAME_RANK[tbDeathBattleInfo.nRank], tbDeathBattleInfo.pPlayer.szName);

		tbKillerBattleInfo.pPlayer.Msg(szMsg);	
		
		self.tbCamps[nKillerGroupId]:OnKillPlayer(tbKillerBattleInfo, tbDeathBattleInfo);
		
		self:DecreaseDamageDefence(tbKillerBattleInfo.pPlayer);
		self:IncreaseDamageDefence(tbDeathBattleInfo.pPlayer);
		
		tbDeathBattleInfo.nBeenKilledNum = tbDeathBattleInfo.nBeenKilledNum + 1;
	end
end

-- 连续死亡给防御等级
function tbMissionBase:IncreaseDamageDefence(pPlayer)
	
	local nDamDefenceLevel = pPlayer.GetSkillState(Wldh.Battle.SKILL_DAMAGEDEFENCE_ID);

	if 0 >= nDamDefenceLevel then
		nDamDefenceLevel = 1;
	else
		nDamDefenceLevel = nDamDefenceLevel + 1;
	end
	
	if 5 >= nDamDefenceLevel then
		pPlayer.AddSkillState(Wldh.Battle.SKILL_DAMAGEDEFENCE_ID, nDamDefenceLevel, 1, Wldh.Battle.SKILL_DAMAGEDEFENCE_TIME, 1);
	end
	
	nDamDefenceLevel = pPlayer.GetSkillState(Wldh.Battle.SKILL_DAMAGEDEFENCE_ID);
end

-- 减防御等级
function tbMissionBase:DecreaseDamageDefence(pPlayer)
	
	local nDamDefenceLevel = pPlayer.GetSkillState(Wldh.Battle.SKILL_DAMAGEDEFENCE_ID);

	nDamDefenceLevel = nDamDefenceLevel - 2;
	pPlayer.RemoveSkillState(Wldh.Battle.SKILL_DAMAGEDEFENCE_ID);
	
	if 0 < nDamDefenceLevel then
		pPlayer.AddSkillState(Wldh.Battle.SKILL_DAMAGEDEFENCE_ID, nDamDefenceLevel, 1, Wldh.Battle.SKILL_DAMAGEDEFENCE_TIME, 1);
	end
end

-- 检查战场是否打开
function tbMissionBase:CheckOpenBattle()
	
	local nSongNum	= self.tbCamps[Wldh.Battle.CAMPID_SONG].nPlayerCount;
	local nJinNum	= self.tbCamps[Wldh.Battle.CAMPID_JIN].nPlayerCount;
	
	-- 以后再加判断
	if nSongNum >= Wldh.Battle.BTPLNUM_LOWBOUND and nJinNum >= Wldh.Battle.BTPLNUM_LOWBOUND then
		return 1;
	end
	
	return 0;
end

-- 定时器：报名结束，开始战斗
function tbMissionBase:OnTimer_SignupEnd()
	
	-- 已经开启
	if self.nState == 2 then
		return 1;
	end
	
	-- 战场没打开
	if 0 == self:CheckOpenBattle() then
		
		-- 怎么处理
		self:BroadcastMsg(0, "没开启成功");
		self:Close();
		
		return 0;
	end
	
	self:_SetState(2, 1);
	
	local szMsg	= string.format("武林大会团体赛报名时间到，%s已正式开始了!", self.szBattleName);
	self:BroadcastMsg(szMsg);
	
	self.tbCampSong:OnStart();
	self.tbCampJin:OnStart();
	self.tbRule:OnStart();
		
	local tbAllPlayer = self:GetPlayerList();
	local nNowTime = GetTime();
	
	for _, pPlayer in pairs(tbAllPlayer) do	
		
		-- 设置时间，battletimer
		Wldh.Battle:GetPlayerData(pPlayer):SetRightBattleInfo(Wldh.Battle.TIMER_GAME);
		
		-- -10的目的 就是让玩家刚开始比赛时能够马上离开后营
		Wldh.Battle:GetPlayerData(pPlayer).nBackTime = nNowTime - 10; 
	end
	
	-- 每分钟加分
	self:CreateTimer(Wldh.Battle.TIMER_ADD_BOUNS, self.OnTimer_AddBouns, self);
	
	return 1;	-- 关闭Timer
end

-- 每分钟给队员加分
function tbMissionBase:OnTimer_AddBouns()
	
	local tbAllPlayer = self:GetPlayerList();
	
	if 2 == self.nState then
		for _, pPlayer in pairs(tbAllPlayer) do	
			
			-- 每分钟给所有人加1分
			Wldh.Battle:GetPlayerData(pPlayer):AddBounsWithCamp(1);	
		end
	else
		return 0;
	end
end

-- 定时器：报名期间广播消息
function tbMissionBase:OnTimer_SignupMsg()
	
	self.nSignUpMsgCount = self.nSignUpMsgCount - 1;
	
	if self.nSignUpMsgCount > 0 then
		local nFrame = self.nSignUpMsgCount * Wldh.Battle.TIMER_SIGNUP_MSG;
		local szMsg	= string.format("战斗尚未开始，还剩%d秒", nFrame / Env.GAME_FPS);
		self:BroadcastMsg(szMsg);
	else
		return 0;
	end
end

-- 定时器：比赛结束，关闭Mission
function tbMissionBase:OnTimer_GameEnd()
	Wldh.Battle:CloseBattle(self.nBattleKey, self.nBattleIndex);
	return 0;
end

-- 定时器：战斗期间同步客户端信息
function tbMissionBase:OnTimer_SyncData()
	
	self.nGameSyncCount	= self.nGameSyncCount - 1;
	
	if self.nGameSyncCount <= 0 then
		return 0;
	end
	
	local nRemainTime = self.nGameSyncCount * Wldh.Battle.TIMER_SYNCDATA / Env.GAME_FPS;
	
	if 2 ~= self.nState then
		nRemainTime = 0;
	end
	
	self:UpdateBattleInfo(nRemainTime);
end


function tbMissionBase:UpdateBattleInfo(nRemainTime)
	
	local tbPlayerList = self:GetSortPlayerInfoList();
	
	-- 玩家排名更新
	for i = 1, #tbPlayerList do
		local tbBattleInfo	= tbPlayerList[i];
		local nOldRank 		= tbBattleInfo.nListRank;
		tbBattleInfo.nListRank = i;
		if nOldRank ~= i and 2 == self.nState then
			tbBattleInfo:ShowRightBattleInfo();
		end
	end	
	
	local tbPlayerInfoList = self:GetSyncInfo_List(tbPlayerList);	

	if tbPlayerInfoList then
		for _, tbPlayer in pairs(tbPlayerList) do
			local tbPlayerInfo = self.tbRule:GetSyncInfo_Self(tbPlayer, nRemainTime);
			local tbPlayerListResult = self:FindMyInfoHighLight(tbPlayer.pPlayer, tbPlayerInfoList);
			local tbAllData	= {};
			
			tbAllData.tbPlayerInfo = tbPlayerInfo;
			tbAllData.tbPlayerInfoList = tbPlayerListResult
			
			local nUseFullTime = 12;
			if nRemainTime == 0 then
				nUseFullTime = 60 * 10;
			end
			
			-- 客户端ui接受界面
			Dialog:SyncCampaignDate(tbPlayer.pPlayer, "SongJinBattle", tbAllData, nUseFullTime * Env.GAME_FPS);
		end
	end

	for _, tbBattleInfo in pairs(tbPlayerList) do
		
		local nBackTime	= tbBattleInfo.nBackTime;
		
		if 0 == tbBattleInfo.pPlayer.nFightState and 2 == self.nState then			
			local nRemainTime = Wldh.Battle.TIME_PLAYER_STAY - (GetTime() - nBackTime);		
			if 0 >= nRemainTime then
				tbBattleInfo.pPlayer.Msg("你在后营停留时间太长，军令已下，命你即刻出战！");
				tbBattleInfo.tbCamp:TransTo(tbBattleInfo.pPlayer, "OuterCamp1");
				tbBattleInfo.pPlayer.SetFightState(1);
			end
		end
		
		local nLiveTime	= Wldh.Battle.TIME_PALYER_LIVE - (GetTime() - nBackTime);
		if 0 >= nLiveTime then
			if 1 == tbBattleInfo.pPlayer.IsDead() then
				tbBattleInfo.pPlayer.Revive(0);
			end
		end
	end	
end

-- 高亮条
function tbMissionBase:FindMyInfoHighLight(pPlayer, tbPlayerInfoList)
	
	local tbPlayerListResult = {};
	
	for key, value in ipairs(tbPlayerInfoList) do
		
		local tbPlayerHighInfo = {};
		local nColor = 0;		
		
		if value[3] == pPlayer.szName then
			nColor = 1;
		end
		
		tbPlayerHighInfo = value;
		tbPlayerHighInfo.nC = nColor;
		tbPlayerListResult[key] = tbPlayerHighInfo;
	end
	
	return tbPlayerListResult;
end

-- 整理排行榜信息
function tbMissionBase:GetSyncInfo_List(tbPlayerList)
	
	local tbPlayerInfoList 	= {};
	local nBattleListNum	= 0;
	
	if 30 <= #tbPlayerList then
		nBattleListNum	= 20;
		
	elseif 10 <= #tbPlayerList then
		nBattleListNum	= 10;
		
	else
		nBattleListNum	= #tbPlayerList;
	end
	
	for i = 1, nBattleListNum do
		local tbPlayerInfo = self.tbRule:GetTopRankInfo(tbPlayerList[i]);
		tbPlayerInfoList[#tbPlayerInfoList + 1] = tbPlayerInfo;
	end

	return tbPlayerInfoList;
end

-- 获得排了序的玩家列表
function tbMissionBase:GetSortPlayerInfoList()
	
	local tbPlayerInfoList	= self:GetPlayerInfoList();
	table.sort(tbPlayerInfoList, self._PlayerCmp);
	
	return tbPlayerInfoList;
end

function tbMissionBase:GetPlayerInfoList(nCampId)
	
	local tbPlayerList, nCount = self:GetPlayerList(nCampId);
	local tbPlayerInfoList = {};

	for i, pPlayer in pairs(tbPlayerList) do
		tbPlayerInfoList[i] = Wldh.Battle:GetPlayerData(pPlayer);
	end

	return tbPlayerInfoList, nCount;
end

-- 比较函数
tbMissionBase._PlayerCmp = function(tbPlayerA, tbPlayerB)
	return tbPlayerA.nBouns > tbPlayerB.nBouns;
end

-- 设置战场状态
function tbMissionBase:_SetState(nState, nOldState)
	
	-- 状态出错
	if nOldState then
		if self.nState ~= nOldState then
			local szMsg	= string.format("[ERROR]MS:SetState %d=>%d, but old = %s", nOldState, nState, tostring(self.nState));
			error(szMsg, 2);
		end
	end
	
	self.nState	= nState;
end

-- 获得全称 ## 去掉了等级
function tbMissionBase:GetFullName()
	return self.szBattleName .. "-" .. self.nBattleIndex
end
