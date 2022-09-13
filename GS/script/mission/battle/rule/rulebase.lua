-- 文件名　：base.lua
-- 创建者　：FanZai
-- 创建时间：2007-12-03 21:44:37
-- 文件说明：规则总基类

Require("\\script\\mission\\battle\\define.lua");
Require("\\script\\mission\\battle\\battle.lua");

local tbRuleBase	= Battle.tbRuleBases[0] or {};	-- 支持重载


--== 规则数据，可以重定义的数据 ==--

-- 杀不同Npc获得的积分
tbRuleBase.BOUNS_KILL_NPC	= { 5, 5, 30, 30, 150, 150, 250, 250, 500, 1000 };

if EventManager.IVER_bOpenTiFu == 1 then
	tbRuleBase.BOUNS_KILL_NPC	= { 1, 1, 6, 6, 30, 30, 50, 50, 100, 200 };
end
--== 应用函数，可以重定义的函数 ==--

-- 开始报名（之后）
function tbRuleBase:OnInit()
end

-- 比赛开始（之后）
function tbRuleBase:OnStart()
	for nCampId, tbMapInfo in pairs(self.tbMapInfoCamp) do
		-- 加载野外战斗Npc
		for nRankId, tbAddNpc in pairs(self.tbAddNpcList[nCampId]) do
			local nNpcNume = tbAddNpc.tbNumber[self.nMapNpcNumType] or 0;
			if (nNpcNume > 0) then
				self:AddFightNpc(nCampId, "Npc_yewai", nRankId);
			end
		end
		self:AddEffectNpc(nCampId, "Effect_daying");
		self:AddEffectNpc(nCampId, "Effect_qianying");
	end
end

-- 比赛结束（之前）
function tbRuleBase:OnClose()
end

function tbRuleBase:OnLeave(pPlayer)
end

-- 判断比赛胜负，返回胜利的一方，平局返回0
function tbRuleBase:GetWinCamp()
	local tbCampSong	= self.tbMission.tbCampSong;
	local tbCampJin		= self.tbMission.tbCampJin;
	
	-- 按积分计算
	if (tbCampSong.nBouns > tbCampJin.nBouns) then
		return Battle.CAMPID_SONG;
	elseif (tbCampSong.nBouns < tbCampJin.nBouns) then
		return Battle.CAMPID_JIN;
	else
		return 0;
	end
end

function tbRuleBase:GetEndBoardMsg() -- TODO
	local szMsg = "";
	return szMsg;
end

function tbRuleBase:GetKillNpcBoardMsg(nRankId, nBouns, nNpcBouns) -- TODO
	local szMsg = "";
	szMsg = string.format("Bạn hạ gục %s", Battle.NAME_RANK[nRankId]);
	return szMsg;
end


--== 基础函数，各种规则通用的函数等 ==--

-- 构造初始化
function tbRuleBase:Init(tbRuleData, tbMission)
	self.tbMission		= tbMission;
	self.tbCamps		= tbMission.tbCamps;

	assert(self.nRuleType == tbRuleData.nRuleType);
	
	self.nBattleLevel	= tbMission.nBattleLevel;
	self.tbAddNpcList	= tbRuleData.tbAddNpcList;
	self.tbNpcRankId	= tbRuleData.tbNpcRankId;
	self.nMapNpcNumType	= tbMission.nMapNpcNumType or 1;
	
	self.tbMapInfoCamp	= {
		[Battle.CAMPID_SONG]	= tbMission.tbCampSong.tbMapInfo;
		[Battle.CAMPID_JIN]		= tbMission.tbCampJin.tbMapInfo;
	};
	
	self.szLevelName	= Battle.NAME_GAMELEVEL[tbMission.nBattleLevel];
	
	self:OnInit();
end

-- 在szPosName位置添加特定nRankId的战斗Npc（nRankId决定了NpcId、等级、数量）
function tbRuleBase:AddFightNpc(nCampId, szPosName, nRankId, bNoRevive)
	local tbPoss	= self.tbMapInfoCamp[nCampId][szPosName];
	if (not tbPoss.nPosIndex) then	-- 尚未经过打乱
		Lib:SmashTable(tbPoss);		-- 得到打乱的点
		tbPoss.nPosIndex	= 1;	-- 循环选取点的当前指针
	end
	
	local tbAddNpc	= self.tbAddNpcList[nCampId][nRankId];	-- ID、等级、数量
	
	local tbNpcObj	= {};
	
	local bRevive	= (bNoRevive == 1 and 0) or 1;
	
	local nNpcNumber = tbAddNpc.tbNumber[self.nMapNpcNumType];
	
	if (not nNpcNumber) then
		return 0;
	end
	
	for i = 1, nNpcNumber do
		if (tbPoss.nPosIndex <= 1) then
			tbPoss.nPosIndex	= #tbPoss;
		else
			tbPoss.nPosIndex	= tbPoss.nPosIndex - 1;
		end
		local tbPos	= tbPoss[tbPoss.nPosIndex];
		-- TODO:	最好不用Index
		tbNpcObj[#tbNpcObj+1]	= KNpc.Add2(tbAddNpc.nNpcId, tbAddNpc.nLevel, -1,
									tbPos[1], tbPos[2], tbPos[3], bRevive);
	end
	
	return tbNpcObj;
end

function tbRuleBase:AddEffectNpc(nCampId, szPosName)
	if (not self.tbMapInfoCamp[nCampId] or not self.tbMapInfoCamp[nCampId][szPosName]) then
		return;
	end

	local tbNpcObj	= {};
	local tbPoss	= self.tbMapInfoCamp[nCampId][szPosName];

	for _, tbPos in pairs(tbPoss) do
		tbNpcObj[#tbNpcObj+1]	= KNpc.Add2(Battle.tbEffectNPC[nCampId], 1, -1, tbPos[1], tbPos[2], tbPos[3], 1);
	end

	return tbNpcObj;
end

-- 获取杀Npc应得的积分
function tbRuleBase:GetKillNpcBouns(pNpc)
	local nNpcRankId	= self.tbNpcRankId[pNpc.nTemplateId];
	if (not nNpcRankId or not self.BOUNS_KILL_NPC[nNpcRankId]) then
		Battle:WriteLog("GetKillNpcBouns Error!", pNpc.szName, pNpc.nTemplateId);
	end
	return self.BOUNS_KILL_NPC[nNpcRankId], nNpcRankId;
end

-- 获得成功护旗积分
function tbRuleBase:GetProtectFlagBouns()
	return 0;
end

-- 得到特定的规则模板
function Battle:GetRuleClass(nRuleType, szRuleName)
	local tbRuleBase	= Battle.tbRuleBases[nRuleType];
	if (not tbRuleBase) then
		tbRuleBase	= Lib:NewClass(Battle.tbRuleBases[0]);
		tbRuleBase.nRuleType	= nRuleType;
		tbRuleBase.szRuleName	= szRuleName;
		Battle.tbRuleBases[nRuleType]	= tbRuleBase;
	end
	return tbRuleBase;
end

function tbRuleBase:GetTopRankInfo(tbBattleInfo)
	local tbPlayerInfo		= {
		[1]	= Battle.NAME_CAMP[tbBattleInfo.tbCamp.nCampId];	
		[2]	= tbBattleInfo.szFacName;
		[3]	= tbBattleInfo.pPlayer.szName;
		[4]	= tbBattleInfo:GetKinTongName();
		[5]	= tbBattleInfo.nKillPlayerNum;
		[6]	= tbBattleInfo.nMaxSeriesKillNum;
		[7]	= tbBattleInfo.nBouns;
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
		szName				= self.szRuleName;
		nSeriesKill			= tbBattleInfo.nSeriesKillNum;
		szName				= tbMission.szBattleName;
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
	};
	return tbMyInfo;
end

function tbRuleBase:OnKillPlayer(tbKillerBattleInfo, tbDeathBattleInfo)
	Battle:GiveKillerBouns(tbKillerBattleInfo, tbDeathBattleInfo);
	Battle:ProcessSeriesBouns(tbKillerBattleInfo, tbDeathBattleInfo);
end

function tbRuleBase:OnPlayerDeath(tbDeathBattleInfo)
	tbDeathBattleInfo.nSeriesKill		= 0;
	tbDeathBattleInfo.nSeriesKillNum	= 0;
	tbDeathBattleInfo.nBackTime			= GetTime();	-- 从1970年1月1日0时算起的秒数
	DeRobot:OnMissionDeath(tbDeathBattleInfo);
end

Battle.tbRuleBases[0]	= tbRuleBase;
