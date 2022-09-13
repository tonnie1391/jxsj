-- 文件名　：marshal.lua
-- 创建者　：FanZai
-- 创建时间：2007-12-03 21:44:37
-- 文件说明：元帅保卫规则文件


Require("\\script\\mission\\battle\\rule\\rulebase.lua");

local tbRuleBase	= Battle:GetRuleClass(2, "Bảo vệ Nguyên Soái");

if (EventManager.IVER_bOpenTiFu == 1) then
	tbRuleBase.TIMER_ADD_MARSHAL	= Env.GAME_FPS * 60 * 30;	-- 出现元帅的最早时间
	tbRuleBase.TIMER_ADD_DAJIANG	= Env.GAME_FPS * 60 * 10;	-- 出现大将的时间
else
	tbRuleBase.TIMER_ADD_MARSHAL	= Env.GAME_FPS * 60 * 40;	-- 出现元帅的最早时间
	tbRuleBase.TIMER_ADD_DAJIANG	= Env.GAME_FPS * 60 * 15;	-- 出现大将的时间
end

tbRuleBase.TIMER_ADD_BOUNS		= Env.GAME_FPS * 60 * 0.5;	-- 护卫大将、元帅奖分间隔

tbRuleBase.RANKID_DAJIANG		= 9;
tbRuleBase.RANKID_YUANSHUAI		= 10;

tbRuleBase.DISTANCE_ADD_BOUNS	= 32;	-- 护卫大将、元帅奖分范围

-- 小地图图标显示
tbRuleBase.NPCATTACK			= 5;
tbRuleBase.NPCDEAD				= 6;
tbRuleBase.NPCMINIMAPFLAG		= 9;
tbRuleBase.NPCBOUNSFORCAMP_YUANSHUAI = 100000; --杀死元帅本方

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
	end
	
	self.tbMission:CreateTimer(self.TIMER_ADD_DAJIANG, self.OnTimer_AddDaJiang, self);
	self.tbMission:CreateTimer(self.TIMER_ADD_MARSHAL, self.OnTimer_AddMarshal, self);
	self.tbMission:CreateTimer(self.TIMER_ADD_BOUNS, self.OnTimer_AddBouns, self);
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
		[8] = tbBattleInfo.nProtectBouns;
		[9]	= tbBattleInfo.nBouns;
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
	};
	return tbMyInfo;
end
