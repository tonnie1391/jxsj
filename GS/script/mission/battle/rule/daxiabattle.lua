-- 文件名　：daxiabattle.lua
-- 创建者　：zhouchenfei
-- 创建时间：2010-8-6 9:49:07
-- 文件说明：大侠保卫战规则文件


Require("\\script\\mission\\battle\\rule\\rulebase.lua");

-- 元帅npcid
Battle.tb_DaXia_MarshelId = {};

-- 玩家变身大侠id
Battle.tbDaXiaId = {};

Battle.DEF_DAXIA_TIMER_ADD_MARSHAL		= Env.GAME_FPS * 60 * 40;	-- 出现元帅的最早时间
Battle.DEF_DAXIA_TIMER_ADD_DAJIANG		= Env.GAME_FPS * 60 * 15;	-- 出现大将的时间
Battle.DEF_DAXIA_TIMER_ADD_BOUNS		= Env.GAME_FPS * 60 * 0.5;	-- 护卫大将、元帅奖分间隔
Battle.DEF_DAXIA_TIMER_PROCESS_BATTLE	= Env.GAME_FPS * 2;	-- 两秒钟处理一次大侠保卫战模式的一些事件，如是否重刷npc，是否让玩家身上的npc消失
Battle.DEF_DAXIA_TIME_CHANGE_PLAYERNPC	= 60 * 5; -- npc消失，或者变换npc位置的时间间隔
Battle.DEF_DAXIA_POINT_KILLPLAYER		= { 20, 30, 35, 40, 45, 50, 80, 100, 150, 200 }; -- 击伤玩家得分
Battle.DEF_DAXIA_POINT_KILLPLAYER_NORMAL = 20;
Battle.DEF_DAXIA_POINT_KILLPLAYER_PLAYERNPC = 250;
Battle.DEF_DAXIA_NPCID					= {
	[Battle.CAMPID_SONG]	= {7038}, 
	[Battle.CAMPID_JIN]		= {7039},
};

Battle.DEF_DAXIA_CHANGENPC_SKILL_ID		= 1631;
Battle.DEF_DAXIA_CHANGER_NPC_RES_NUM	= 9;
Battle.DEF_DAXIA_CHANGE_TIME_BUF		= 474;
Battle.DEF_DAXIA_CHANGENPC_QINGGONG		= 1161;
Battle.DEF_DAXIA_CHANGENPC_SINGLE_FIGHTSKILL = 1641;

local tbRuleBase	= Battle:GetRuleClass(5, "Chiến Thần Đơn");

tbRuleBase.RANKID_DAJIANG		= 9;
tbRuleBase.RANKID_YUANSHUAI		= 10;

tbRuleBase.DISTANCE_ADD_BOUNS	= 32;	-- 护卫大将、元帅奖分范围

-- 小地图图标显示
tbRuleBase.NPCATTACK			= 5;
tbRuleBase.NPCDEAD				= 6;
tbRuleBase.NPCMINIMAPFLAG		= 9;
tbRuleBase.NPCBOUNSFORCAMP_YUANSHUAI = 100000; --杀死元帅本方

tbRuleBase.MINIMAP_FLAG					= {
			[1] = 7,
			[2] = 8,
	};

-- 杀不同Npc获得的积分
tbRuleBase.BOUNS_KILL_NPC	= { 5, 5, 10, 10, 60, 60, 100, 100, 500, 1500 };

if EventManager.IVER_bOpenTiFu == 1 then
	tbRuleBase.BOUNS_KILL_NPC	= { 1, 1, 2, 2, 12, 12, 20, 20, 100, 300 };
end
-- 杀大将、元帅为本阵营所有玩家加的积分
tbRuleBase.BOUNS_KILL_BOSS	= {
	[tbRuleBase.RANKID_DAJIANG]		= 200,
	[tbRuleBase.RANKID_YUANSHUAI]	= 500,
};

-- 护卫大将、元帅的奖励积分
tbRuleBase.BOUNS_PROTECT_BOSS	= {
	[tbRuleBase.RANKID_DAJIANG]		= 15,
	[tbRuleBase.RANKID_YUANSHUAI]	= 15,
};

-- 比赛开始（之后）
function tbRuleBase:OnStart()
	self.tbYunshuaiAppear 	= {
			[1] = 0,
			[2] = 0,
		};
	self.tbMission.szKillYuanName = nil;
	self.tbPlayerNpcState = {};
	for nCampId, tbMapInfo in pairs(self.tbMapInfoCamp) do
		-- 加载野外战斗Npc
		for nRankId, tbAddNpc in pairs(self.tbAddNpcList[nCampId]) do
			local nNpcNume = tbAddNpc.tbNumber[self.nMapNpcNumType] or 0;
			if (nRankId < tbRuleBase.RANKID_DAJIANG and nNpcNume > 0) then	-- 大将、元帅不刷到野外
				self:AddFightNpc(nCampId, "Npc_yewai", nRankId);
			end
		end
		self:AddEffectNpc(nCampId, "Effect_daying");
		self:AddEffectNpc(nCampId, "Effect_qianying");
		self:AddPlayerNpc(nCampId);
		self.tbPlayerNpcState[nCampId] = 1;
	end
	
	self.tbMission:CreateTimer(Battle.DEF_DAXIA_TIMER_ADD_DAJIANG,		self.OnTimer_AddDaJiang, self);
	self.tbMission:CreateTimer(Battle.DEF_DAXIA_TIMER_ADD_MARSHAL,		self.OnTimer_AddMarshal, self);
	self.tbMission:CreateTimer(Battle.DEF_DAXIA_TIMER_ADD_BOUNS,		self.OnTimer_AddBouns, self);
	self.tbMission:CreateTimer(Battle.DEF_DAXIA_TIMER_PROCESS_BATTLE,	self.OnTimer_ProcessBattleEvent, self);
end

function tbRuleBase:OnTimer_ProcessBattleEvent()
	for nCampId, tbCamp in pairs(self.tbCamps) do
		self:ProcessPlayerNpc(nCampId);
	end
end

function tbRuleBase:GetChangeNpcId(nCampId)
	local tbDaXia = Battle.tbDaXiaId[nCampId];
	local nRandom = MathRandom(#tbDaXia);
	local nNpcId	= tbDaXia[nRandom] or 0;
	return nNpcId;
end

function tbRuleBase:GetNpcId(nCampId)
	local tbDaXia = Battle.DEF_DAXIA_NPCID[nCampId];
	local nRandom = MathRandom(#tbDaXia);
	local nNpcId	= tbDaXia[nRandom] or 0;
	return nNpcId;
end


-- 处理npc消失再生事件
function tbRuleBase:ProcessPlayerNpc(nCampId)
	local tbCamp = self.tbCamps[nCampId];
	-- 检查玩家npc是否到时间
	if (tbCamp.nGetPlayerNpcTime) then
		if (GetTime() - tbCamp.nGetPlayerNpcTime >= Battle.DEF_DAXIA_TIME_CHANGE_PLAYERNPC) then
			local pPlayer = KPlayer.GetPlayerObjById(tbCamp.nPlayerIsNpc);
			if (pPlayer) then
				self:DelPlayerNpc(pPlayer);
			else
				Battle:WriteLog("[ERROR] There is no player tbRuleBase 4 ProcessPlayerNpc");
			end
			self.tbCamps[nCampId].nGetPlayerNpcTime = nil;
			self.tbCamps[nCampId].nPlayerIsNpc		= 0;
			self:AddPlayerNpc(nCampId);
			return;
		end
	end
	
	-- 检查未找到的npc是否到时间可以换位置
	if (tbCamp.nAddPlayerNpcTime) then
		if (GetTime() - tbCamp.nAddPlayerNpcTime >= Battle.DEF_DAXIA_TIME_CHANGE_PLAYERNPC) then
			if (tbCamp.nAddPlayerNpcId) then
				local pHim		= KNpc.GetById(tbCamp.nAddPlayerNpcId);
				if (pHim) then
					pHim.Delete();
				end
			end
			self.tbCamps[nCampId].nAddPlayerNpcId = nil;
			self.tbCamps[nCampId].nAddPlayerNpcTime = nil;
			self:AddPlayerNpc(nCampId);
		end
	end
	
	-- 如果旗子突然消失了需要重新加
	if ((not tbCamp.nPlayerIsNpc or tbCamp.nPlayerIsNpc == 0) and (not tbCamp.nAddPlayerNpcId or tbCamp.nAddPlayerNpcId == 0)) then
		self.tbCamps[nCampId].nAddPlayerNpcId = nil;
		self.tbCamps[nCampId].nAddPlayerNpcTime = nil;
		self:AddPlayerNpc(nCampId);
	end
end

-- 判断比赛胜负，返回胜利的一方，平局返回0
function tbRuleBase:GetWinCamp()
	local tbCampSong	= self.tbMission.tbCampSong;
	local tbCampJin		= self.tbMission.tbCampJin;
	
	-- 先看元帅数量
	local nYuanshuaiSong	= (tbCampSong.pNpcYuanShuai and 1) or 0;
	local nYuanshuaiJin		= (tbCampJin.pNpcYuanShuai and 1) or 0;
	if (nYuanshuaiSong > nYuanshuaiJin) then
		if (self.tbYunshuaiAppear[1] == self.tbYunshuaiAppear[2]) then
			return Battle.CAMPID_SONG;
		end
	elseif (nYuanshuaiSong < nYuanshuaiJin) then
		if (self.tbYunshuaiAppear[1] == self.tbYunshuaiAppear[2]) then 
			return Battle.CAMPID_JIN;
		end
	end

	
	-- 根据大将数量定输赢
	local nDajiangSong	= (tbCampSong.tbDajiang and tbCampSong.tbDajiang.n) or 0;
	local nDajiangJin	= (tbCampJin.tbDajiang and tbCampJin.tbDajiang.n) or 0;
	if (nDajiangSong > nDajiangJin) then
		return Battle.CAMPID_SONG;
	elseif (nDajiangSong < nDajiangJin) then
		return Battle.CAMPID_JIN;
	end
	
	-- 最后按积分计算
	if (tbCampSong.nBouns > tbCampJin.nBouns) then
		return Battle.CAMPID_SONG;
	elseif (tbCampSong.nBouns < tbCampJin.nBouns) then
		return Battle.CAMPID_JIN;		
	end

	return 0;
end

function tbRuleBase:GetEndBoardMsg(nWinCampId)
	local szMsg = "";
	return szMsg;
end

function tbRuleBase:GetKillNpcBoardMsg(nRankId, nNpcBouns, pNpc)
	local szMsg		= "";
	local nMidMsg	= 0;
	if (1 < nRankId and 9 > nRankId) then
		szMsg = string.format("Bạn hạ gục %s", Battle.NAME_RANK[nRankId]);
	elseif (9 <= nRankId) then
		local szNpcName = pNpc.szName;
		nMidMsg = 2;
		szMsg 	= string.format("Hạ gục <color=yellow>%s<color>, nhận được <color=yellow>%d<color> điểm thưởng.", szNpcName, nNpcBouns);
		if (9 == nRankId) then
			nMidMsg = 1;
		end
	end
	return szMsg, nMidMsg;
end


-- 大将被杀
function tbRuleBase:OnDeath_Dajiang(nCampId)
	local tbCamp	= self.tbCamps[nCampId];
	assert(tbCamp.tbDajiang[him.dwId]);
	self:SetNpcDeadHigh(him, nCampId, self.NPCDEAD);
	
	tbCamp.tbDajiang[him.dwId]	= nil;
	tbCamp.tbDajiang.n			= tbCamp.tbDajiang.n - 1;
	
	self:GiveKillBossCampBouns(tbCamp.tbOppCamp.nCampId, self.RANKID_DAJIANG);
	
	self:TryAddMarshal(nCampId, 0);
end

-- 元帅被杀
function tbRuleBase:OnDeath_Yuanshuai(nCampId, pNpc)
	local tbCamp = self.tbCamps[nCampId];
	self.tbCamps[nCampId].pNpcYuanShuai	= nil;
	self.tbMission.szKillYuanName = pNpc.szName;
	self:GiveKillBossCampBouns(tbCamp.tbOppCamp.nCampId, self.RANKID_YUANSHUAI);
	
	local szKillerName	= pNpc.szName;
	
	if (szKillerName) then
		local nLoseCampId 	= nCampId;
		local nWinCampId	= 1;
		if (1 == nLoseCampId) then
			nWinCampId = 2;
		end
		local szMsg = string.format("<color=yellow>%s<color>-<color=yellow>%s<color> anh dũng tiêu diệt <color=yellow>%s-Nguyên Soái<color>, phe %s nhận được 10 vạn điểm tích lũy.", Battle.NAME_CAMP[nWinCampId], szKillerName, Battle.NAME_CAMP[nLoseCampId], Battle.NAME_CAMP[nWinCampId]);
		local tbPlayerList 	= self.tbMission:GetPlayerList();
		for _, pPlayer in pairs(tbPlayerList) do
			Dialog:SendInfoBoardMsg(pPlayer, szMsg);
		end
	end	
	
	tbCamp.tbOppCamp.nBouns = tbCamp.tbOppCamp.nBouns + self.NPCBOUNSFORCAMP_YUANSHUAI;
	
	-- 结束比赛
--	self.tbMission:GoNextState();
end

function tbRuleBase:SetNpcDeadHigh(pNpc, nCampId, nPicId)
	local tbPlayerList 	= self.tbMission:GetPlayerList();
	local nSubWorld, nPosX, nPosY = pNpc.GetWorldPos();
	for _, pPlayer in pairs(tbPlayerList) do
		pPlayer.SetHighLightPoint(nPosX, nPosY, nPicId, pNpc.dwId, pNpc.szName, 60000);
	end
end

-- 尝试看看到没到刷元帅的时候
function tbRuleBase:TryAddMarshal(nCampId, bForce)
	-- 已经加过元帅了
	if (self.tbYunshuaiAppear[nCampId] == 1) then
		return;
	end
	
	local tbDajiang	= self.tbCamps[nCampId].tbDajiang
	Battle:DbgOut("tbRuleBase:TryAddMarshal", nCampId, tbDajiang and tbDajiang.n);
	if (self.tbCamps[nCampId].pNpcYuanShuai) then
		return;	-- 已经加过元帅
	end
	if (bForce ~= 1 and tbDajiang.n > 0) then
		return;	-- 时机未到
	end
	
	-- 刷元帅
	local tbNpcObj		= self:AddFightNpc(nCampId, "Npc_yuanshuai", tbRuleBase.RANKID_YUANSHUAI, 1);
	assert(#tbNpcObj == 1);	-- 按照需求，有且仅有一个元帅
	self.tbCamps[nCampId].pNpcYuanShuai	= tbNpcObj[1];
	Npc:RegPNpcOnDeath(tbNpcObj[1], self.OnDeath_Yuanshuai, self, nCampId);
	self.tbCamps[nCampId]:PushNpcHighPoint(tbNpcObj[1], self.NPCMINIMAPFLAG, self.NPCATTACK);
	local szCampName = Battle.NAME_CAMP[nCampId];
	self.tbYunshuaiAppear[nCampId] = 1;
	local szMsg	= string.format("%s-Nguyên Soái đã xuất chiến, phe %s mau quay về bảo vệ Nguyên Soái!", szCampName, szCampName);
	local tbPlayerList	= self.tbMission:GetPlayerList(nCampId);
	for _, pPlayer in pairs(tbPlayerList) do
		Dialog:SendInfoBoardMsg(pPlayer, szMsg);
	end
end

-- 可以刷元帅的时间到
function tbRuleBase:OnTimer_AddMarshal()
	self:TryAddMarshal(Battle.CAMPID_SONG, 1);
	self:TryAddMarshal(Battle.CAMPID_JIN, 1);
	return 0;
end

--  加载大将
function tbRuleBase:OnTimer_AddDaJiang()
	for nCampId, tbMapInfo in pairs(self.tbMapInfoCamp) do		
		-- 加载大将
		local tbNpcObj	= self:AddFightNpc(nCampId, "Npc_dajiang", tbRuleBase.RANKID_DAJIANG, 1);
		local tbDajiang	= { n = #tbNpcObj };
		self.tbCamps[nCampId].tbDajiang	= tbDajiang;
		for _, pNpc in pairs(tbNpcObj) do
			tbDajiang[pNpc.dwId]	= pNpc;
			Npc:RegPNpcOnDeath(pNpc, self.OnDeath_Dajiang, self, nCampId);
			self.tbCamps[nCampId]:PushNpcHighPoint(pNpc, self.NPCMINIMAPFLAG, self.NPCATTACK);
		end
		
		local szCampName	= Battle.NAME_CAMP[nCampId];
		local szMsg			= string.format("%s-Đại Tướng đã xuất chiến, phe %s mau quay về bảo vệ Đại Tướng!", szCampName, szCampName);
		self.tbMission:BroadcastMsg(nCampId, szMsg);
		local tbPlayerList	= self.tbMission:GetPlayerList(nCampId);
		for _, pPlayer in pairs(tbPlayerList) do
			Dialog:SendInfoBoardMsg(pPlayer, szMsg);
		end
	end	
	return 0;
end

-- 定时为护卫大将/元帅的玩家加积分
function tbRuleBase:OnTimer_AddBouns()
	local nDistanceSqure	= self.DISTANCE_ADD_BOUNS * self.DISTANCE_ADD_BOUNS;
	
	for nCampId = Battle.CAMPID_SONG, Battle.CAMPID_JIN do
		local tbCamp	= self.tbCamps[nCampId];
		local tbBoss	= {};
		local nRankId	= 0;
		if (tbCamp.pNpcYuanShuai) then
			tbBoss		= {tbCamp.pNpcYuanShuai};
			nRankId		= tbRuleBase.RANKID_YUANSHUAI;
			self:AddProtectBouns(tbCamp, tbBoss, nRankId, nCampId, nDistanceSqure);	
		end

		if (tbCamp.tbDajiang and tbCamp.tbDajiang.n > 0) then
			tbBoss	= tbCamp.tbDajiang;
			nRankId	= tbRuleBase.RANKID_DAJIANG;
			self:AddProtectBouns(tbCamp, tbBoss, nRankId, nCampId, nDistanceSqure);
		end
	end
end

function tbRuleBase:AddProtectBouns(tbCamp, tbBoss, nRankId, nCampId, nDistanceSqure)
	local nAddBouns	= self.BOUNS_PROTECT_BOSS[nRankId];
	local szMsg		= string.format("Bảo vệ %s-%s, nhận được <color=yellow>%d<color> điểm tích lũy.", tbCamp.szCampName, Battle.NAME_RANK[nRankId], nAddBouns);
	local tbBossPos	= {};
	for varKey, pNpc in pairs(tbBoss) do
		if (varKey ~= "n") then
			local _, nX, nY	= pNpc.GetWorldPos();
			tbBossPos[#tbBossPos+1]	= {nX, nY};
		end
	end
	
	local tbPlayerList	= self.tbMission:GetPlayerList(nCampId);
	for _, pPlayer in pairs(tbPlayerList) do
		if (pPlayer and pPlayer.IsDead() == 0) then
			local _, nX, nY	= pPlayer.GetWorldPos();
			for _, tbPos in pairs(tbBossPos) do
				local nDx	= tbPos[1] - nX;
				local nDy	= tbPos[2] - nY;
				if (nDx*nDx + nDy*nDy <= nDistanceSqure) then
					local tbBattleInfo	= Battle:GetPlayerData(pPlayer);
					if (0 < tbBattleInfo:AddBounsWithoutCamp(nAddBouns)) then
						tbBattleInfo.nProtectBouns = tbBattleInfo.nProtectBouns + nAddBouns;
					end
					pPlayer.Msg(szMsg);
					break;
				end
			end
		end
	end
end

-- 为全阵营增加杀大将、元帅积分
function tbRuleBase:GiveKillBossCampBouns(nCampId, nRankId)
	local tbOurCamp	= self.tbCamps[nCampId];
	local tbOppCamp	= tbOurCamp.tbOppCamp;
	local nAddBouns	= self.BOUNS_KILL_BOSS[nRankId];
	local szMsg	= string.format("%s-%s bị tiêu diệt, nhận được <color=yellow>%d<color> điểm tích lũy.", tbOppCamp.szCampName, Battle.NAME_RANK[nRankId], nAddBouns);
	if (10 == nRankId) then
		szMsg = szMsg .. " Điểm tích lũy tăng 10 vạn.";
	end
	self.tbMission:BroadcastMsg(nCampId, szMsg);
	tbOurCamp:AddCampBouns(nAddBouns);
end

function tbRuleBase:GetTopRankInfo(tbBattleInfo)
	local tbPlayerInfo		= {
		[1]	= Battle.NAME_CAMP[tbBattleInfo.tbCamp.nCampId];	
		[2]	= tbBattleInfo.szFacName;
		[3]	= tbBattleInfo.pPlayer.szName;
		[4]	= tbBattleInfo:GetKinTongName();
		[5]	= tbBattleInfo.nKillPlayerNum;
		[6]	= tbBattleInfo.nMaxSeriesKillNum;
		[7]	= tbBattleInfo.nKillNpcNum;
		[8]	= tbBattleInfo.nBouns;
		[9] = tbBattleInfo.nPlayerNpcKillNum;
	};
	return tbPlayerInfo;
end

-- 整理玩家信息
function tbRuleBase:GetSyncInfo_Self(tbBattleInfo, nRemainTime)
	local tbMission			= tbBattleInfo.tbMission;

	local tbMyInfo			= {
		nBTMode				= self.nRuleType;
		nKillPlayerNum		= tbBattleInfo.nKillPlayerNum;
		nKillBouns			= tbBattleInfo.nBouns - tbBattleInfo.nTriSeriesNum * Battle.SERIESKILLBOUNS;
		nTriSeriesNum		= tbBattleInfo.nTriSeriesNum;
		nSeriesBouns		= tbBattleInfo.nTriSeriesNum * Battle.SERIESKILLBOUNS;
		nBouns				= tbBattleInfo.nBouns;
		nMaxSeriesKill		= tbBattleInfo.nMaxSeriesKillNum;
		nSeriesKill			= tbBattleInfo.nSeriesKillNum;
		szName				= self.szRuleName;
		nCamp				= tbBattleInfo.tbCamp.nCampId;
		nListRank			= tbBattleInfo.nListRank;
		szBTName			= tbMission.szBattleName;
		nTotalSongBouns		= tbMission.tbCampSong.nBouns;
		nTotalJinBouns		= tbMission.tbCampJin.nBouns;
		nRemainBTTime		= nRemainTime;
		nMyCampNum			= tbBattleInfo.tbCamp.nPlayerCount;
		nEnemyCampNum		= tbBattleInfo.tbCamp.tbOppCamp.nPlayerCount;
		nKillPlayerBouns	= tbBattleInfo.nKillPlayerBouns;
		nKillNpcBouns		= tbBattleInfo.nKillNpcBouns;
		nProtectBouns		= tbBattleInfo.nProtectBouns;
		nKillNpcNum			= tbBattleInfo.nKillNpcNum;
		nPlayerNpcKillNum	= tbBattleInfo.nPlayerNpcKillNum;
	};
	return tbMyInfo;
end

-- 不同的规则加不同的分
function tbRuleBase:OnKillPlayer(tbKillerBattleInfo, tbDeathBattleInfo)
	tbKillerBattleInfo.nKillPlayerNum	= tbKillerBattleInfo.nKillPlayerNum + 1;
	
	-- 要不要做安全性检测呢？
	local nMeRank		= tbDeathBattleInfo.pPlayer.GetHonorLevel();
	
	local nPoints		= Battle.DEF_DAXIA_POINT_KILLPLAYER[nMeRank] or Battle.DEF_DAXIA_POINT_KILLPLAYER_NORMAL;
	local tbOptCamp		= tbDeathBattleInfo.tbCamp;
	if (tbOptCamp.nPlayerIsNpc and tbOptCamp.nPlayerIsNpc == tbDeathBattleInfo.pPlayer.nId) then
		nPoints = Battle.DEF_DAXIA_POINT_KILLPLAYER_PLAYERNPC;
	end
	
	local tbCamp		= tbKillerBattleInfo.tbCamp;
	if (tbCamp.nPlayerIsNpc and tbCamp.nPlayerIsNpc == tbKillerBattleInfo.pPlayer.nId) then
		tbKillerBattleInfo.nPlayerNpcKillNum = tbKillerBattleInfo.nPlayerNpcKillNum + 1;
	end

	
	local nBounsDif		= Battle:AddShareBouns(tbKillerBattleInfo, nPoints)
	if (nBounsDif > 0) then
		tbKillerBattleInfo.nKillPlayerBouns = tbKillerBattleInfo.nKillPlayerBouns + nPoints;
	end

	Battle:ProcessSeriesBouns(tbKillerBattleInfo, tbDeathBattleInfo);
end

-- 获得战旗的坐标
function tbRuleBase:GetNpcAddPos(nCampId)
	local szPosName = "OuterCamp5";
	return self.tbMission.tbCamps[nCampId]:GetMapPos(szPosName);
end

-- 在szPosName位置添加玩家面具npc
function tbRuleBase:AddPlayerNpc(nCampId)
	local tbPos				= self:GetNpcAddPos(nCampId);
	local nOppCampId		= self.tbCamps[nCampId].tbOppCamp.nCampId;
	
	local tbNpcObj		= {};
	local bRevive		= 0;
	-- 添加战旗NPC
	local nNpcId		= self:GetNpcId(nCampId);
	tbNpcObj		= KNpc.Add2(nNpcId, 1, -1, tbPos[1], tbPos[2], tbPos[3], bRevive);
	self.tbCamps[nCampId]:PushNpcHighPoint(tbNpcObj, self.MINIMAP_FLAG[nCampId]);
	local szMsg		= string.format("<color=yellow>%s-Chiến Thần Đơn<color> đã xuất hiện, binh sĩ %s nhanh chân truy tìm!", Battle.NAME_CAMP[nCampId], Battle.NAME_CAMP[nCampId]);
	self.tbMission:BroadcastMsg(szMsg);
	local tbPlayerList	= self.tbMission:GetPlayerList();
	for _, pPlayer in pairs(tbPlayerList) do
		Dialog:SendInfoBoardMsg(pPlayer, szMsg);
	end
	self.tbCamps[nCampId].tbSrcFlagPos			= tbPos;
	self.tbCamps[nCampId].nAddPlayerNpcId		= tbNpcObj.dwId;
	self.tbCamps[nCampId].nAddPlayerNpcTime		= GetTime();
	self.tbCamps[nCampId].nPlayerIsNpc			= 0;
	return tbNpcObj;
end

-- 删除有战旗玩家的战旗，在玩家死亡，离开战场的时候，回到后营的时候需要用到
function tbRuleBase:DelPlayerNpc(pPlayer)
	local tbBattleInfo = Battle:GetPlayerData(pPlayer);

	-- 判断是否需要删除玩家身上的战旗，是否是战斗期间，是否有战旗，是否是同一个拿战旗
	if ((2 == self.tbMission.nState) and (1 == tbBattleInfo.bHaveNpc) and (tbBattleInfo.pPlayer.nId == tbBattleInfo.tbCamp.nPlayerIsNpc)) then
		-- 当玩家进入后营，获得大营或者前营的生成战旗坐标
		local nCampId	= tbBattleInfo.tbCamp.nCampId;
		self.tbCamps[nCampId].nGetPlayerNpcTime = nil;
		self.tbCamps[nCampId].nPlayerIsNpc		= 0;
		self:RestorePlayerState(tbBattleInfo.pPlayer);
		tbBattleInfo.tbCamp:PopNpcHighPoint(tbBattleInfo.pPlayer.GetNpc());
	end
	tbBattleInfo.bHaveNpc = 0;
end

function tbRuleBase:ChangePlayerState(pPlayer)
	local nLevel = pPlayer.nLevel;
	local nSkillLevel = MathRandom(Battle.DEF_DAXIA_CHANGER_NPC_RES_NUM);
	Battle:ChangeFeature(pPlayer, Battle.DEF_DAXIA_CHANGENPC_SKILL_ID, nSkillLevel, Battle.DEF_DAXIA_TIME_CHANGE_PLAYERNPC);
	pPlayer.CallClientScript({"Battle:ChangeRightSkill", Battle.RULE_PROTECTFLAG_CHANGERIGHTSKILL});
	pPlayer.AddSkillState(Battle.DEF_DAXIA_CHANGE_TIME_BUF, 1, 0, Battle.DEF_DAXIA_TIME_CHANGE_PLAYERNPC, 1, 1);
	pPlayer.AddFightSkill(Battle.DEF_DAXIA_CHANGENPC_QINGGONG, 20);
	pPlayer.AddFightSkill(Battle.DEF_DAXIA_CHANGENPC_SINGLE_FIGHTSKILL, 10);
	local tbBattleInfo = Battle:GetPlayerData(pPlayer);
	tbBattleInfo:ChangeCurShortCut();
end

function tbRuleBase:RestorePlayerState(pPlayer)
	Battle:RestoreFeature(pPlayer, Battle.DEF_DAXIA_CHANGENPC_SKILL_ID);
	pPlayer.CallClientScript({"Battle:RestoreRightSkill"});

	if pPlayer.GetSkillState(Battle.DEF_DAXIA_CHANGE_TIME_BUF) > 0 then
		pPlayer.RemoveSkillState(Battle.DEF_DAXIA_CHANGE_TIME_BUF);
	end	

	if (pPlayer.IsHaveSkill(Battle.DEF_DAXIA_CHANGENPC_QINGGONG) == 1) then
		pPlayer.DelFightSkill(Battle.DEF_DAXIA_CHANGENPC_QINGGONG);
	end

	if (pPlayer.IsHaveSkill(Battle.DEF_DAXIA_CHANGENPC_SINGLE_FIGHTSKILL) == 1) then
		pPlayer.DelFightSkill(Battle.DEF_DAXIA_CHANGENPC_SINGLE_FIGHTSKILL);
	end
	local tbBattleInfo = Battle:GetPlayerData(pPlayer);
	tbBattleInfo:RecoverShortCut();
end

function tbRuleBase:OnLeave(pPlayer)
	self:DelPlayerNpc(pPlayer);
	self:RestorePlayerState(pPlayer);
end
