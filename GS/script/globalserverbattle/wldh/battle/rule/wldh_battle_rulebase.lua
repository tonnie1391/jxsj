-------------------------------------------------------
-- 文件名　：wldh_battle_rulebase.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-08-26 07:38:25
-- 文件描述：
-------------------------------------------------------

Require("\\script\\globalserverbattle\\wldh\\battle\\wldh_battle.lua");

local tbRuleBase = Wldh.Battle.tbRuleBases[0] or {};	-- 支持重载
Wldh.Battle.tbRuleBases[0]	= tbRuleBase;


-- 开始报名（之后）
function tbRuleBase:OnInit()
	
end

-- 比赛开始（之后）
function tbRuleBase:OnStart()

end

-- 比赛结束（之前）
function tbRuleBase:OnClose()
	
end

function tbRuleBase:OnLeave(pPlayer)
	
end

-- 判断比赛胜负，返回胜利的一方，平局返回0
function tbRuleBase:GetWinCamp()
	
	local tbCampSong = self.tbMission.tbCampSong;
	local tbCampJin	= self.tbMission.tbCampJin;
	
	-- 按积分计算
	if (tbCampSong.nBouns > tbCampJin.nBouns) then
		return Wldh.Battle.CAMPID_SONG;
		
	elseif (tbCampSong.nBouns < tbCampJin.nBouns) then
		return Wldh.Battle.CAMPID_JIN;
		
	else
		return 0;
	end
end

-- 构造初始化
function tbRuleBase:Init(tbMission)
	
	self.tbMission		= tbMission;
	self.tbCamps		= tbMission.tbCamps;
	
	self.tbMapInfoCamp	= 
	{
		[Wldh.Battle.CAMPID_SONG]	= tbMission.tbCampSong.tbMapInfo;
		[Wldh.Battle.CAMPID_JIN]	= tbMission.tbCampJin.tbMapInfo;
	};
	
	self:OnInit();
end

-- 得到特定的规则模板
function Wldh.Battle:GetRuleClass(nRuleType, szRuleName)
	
	local tbRuleBase = Wldh.Battle.tbRuleBases[nRuleType];
	
	if (not tbRuleBase) then
		tbRuleBase	= Lib:NewClass(Wldh.Battle.tbRuleBases[0]);
		tbRuleBase.nRuleType	= nRuleType;
		tbRuleBase.szRuleName	= szRuleName;
		Wldh.Battle.tbRuleBases[nRuleType]	= tbRuleBase;
	end
	
	return tbRuleBase;
end

function tbRuleBase:GetTopRankInfo(tbBattleInfo)
	
	local tbPlayerInfo	= 
	{
		[1]	= Wldh.Battle.NAME_CAMP[tbBattleInfo.tbCamp.nCampId];	
		[2]	= tbBattleInfo.szFacName;
		[3]	= tbBattleInfo.pPlayer.szName;
		[4]	= self.tbMission.tbLeagueName[tbBattleInfo.tbCamp.nCampId];
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
		nKillBouns			= tbBattleInfo.nBouns - tbBattleInfo.nTriSeriesNum * Wldh.Battle.SERIESKILLBOUNS;
		nTriSeriesNum		= tbBattleInfo.nTriSeriesNum;
		nSeriesBouns		= tbBattleInfo.nTriSeriesNum * Wldh.Battle.SERIESKILLBOUNS;
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
	};
	return tbMyInfo;
end

