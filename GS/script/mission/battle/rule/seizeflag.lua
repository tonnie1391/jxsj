-- 文件名　：marshal.lua
-- 创建者　：FanZai
-- 创建时间：2007-12-03 21:44:37
-- 文件说明：夺旗规则文件


Require("\\script\\mission\\battle\\rule\\rulebase.lua");

local tbRuleBase	= Battle:GetRuleClass(3, "Hộ Kỳ");

-- 杀不同Npc获得的积分
tbRuleBase.BOUNS_KILL_NPC				= { 5, 5, 10, 10, 60, 60, 100, 100, 0, 0 };
if EventManager.IVER_bOpenTiFu == 1 then
	tbRuleBase.BOUNS_KILL_NPC	= { 1, 1, 2, 2, 12, 12, 20, 20, 0, 0 };
end
-- 玩家护旗成功奖励积分
tbRuleBase.BOUNS_PROTECT_FLAG_PLAYER	= 600;
-- 本方护旗成功所有玩家奖励
tbRuleBase.BOUNS_PROTECT_FLAG_CAMP		= 50;

tbRuleBase.DISTANCE_ADD_PROTECT_SUCBOUNS= 32;	-- 护旗成功奖励范围
tbRuleBase.PROTECT_SUCBOUNS_FOR_NEARPLAYER	= 300;	-- 护旗成功奖励给一定范围内玩家奖励

-- 战旗ID
tbRuleBase.FLAG_ID						= {
			[Battle.CAMPID_SONG]	= 2522,
			[Battle.CAMPID_JIN]		= 2523,
};

tbRuleBase.NOFLAGDES				= 2676;

-- 旗标
tbRuleBase.FLAGDES_ID					= {
			[Battle.CAMPID_SONG]	= 2677,
			[Battle.CAMPID_JIN]		= 2678,
	};
-- 护旗模式护旗成功距离
tbRuleBase.FLAGDIS						= 8;
-- 双方护旗战旗上限
tbRuleBase.MAX_FLAGNUM					= 30;
-- 迷你地图的图标
tbRuleBase.MINIMAP_FLAG					= {
			[1] = 7,
			[2] = 8,
	};
	
tbRuleBase.MINIMAP_DESFLAG				= 9;

tbRuleBase.FLAG_PROTECT_BOUNS			= 15;
tbRuleBase.DISTANCE_ADD_BOUNS			= 32;
tbRuleBase.nDuringProtect_TimeFlag		= 0; 	-- 标记当前是十五秒还是15秒的2倍

-- 比赛开始（之后）
function tbRuleBase:OnStart()
	for nCampId, tbMapInfo in pairs(self.tbMapInfoCamp) do
		self.tbCamps[nCampId].nFlagLimit = self.MAX_FLAGNUM;
		-- 加载野外战斗Npc
		for nRankId, tbAddNpc in pairs(self.tbAddNpcList[nCampId]) do
			local nNpcNume = tbAddNpc.tbNumber[self.nMapNpcNumType] or 0;
			if (nNpcNume > 0) then
				self:AddFightNpc(nCampId, "Npc_yewai", nRankId);
			end
		end
		self:AddEffectNpc(nCampId, "Effect_daying");
		self:AddEffectNpc(nCampId, "Effect_qianying");
		self:AddFlag(nCampId);				-- 生成战旗
		self:SetFlagDestination(nCampId);	-- 生成战旗目的坐标
	end
	-- 创建时间事件
	self.tbMission:CreateTimer(2 * 18, self.OnTimer_ReachToTheFlagDes, self);
	self.nDuringProtect_TimeFlag	= 0;
	self.tbMission:CreateTimer(15 * 18, self.OnTimer_AddProtectBouns, self);
	
end

-- 获得战旗的坐标
function tbRuleBase:GetFlagAddPos(nCampId)
	local szPosName = "OuterCamp1";
	return self.tbMission.tbCamps[nCampId]:GetMapPos(szPosName);
end

-- 在szPosName位置添加战旗
function tbRuleBase:AddFlag(nCampId)
	if (0 >= self.tbCamps[nCampId].nFlagLimit) then
		return;
	end
	local tbPos				= self:GetFlagAddPos(nCampId);
	local nOppCampId		= self.tbMission.tbCamps[nCampId].tbOppCamp.nCampId;
	local tbOppFlagDesPos	= self.tbMission.tbCamps[nOppCampId].tbFlagDesPos; 
	
	-- 如果存在敌方的战旗目标地在本方大营或者后营中时需要检查是否会重叠
	if (tbOppFlagDesPos) then
		while true do
			if (tbPos and tbPos[2] and (tbPos[2] ~= tbOppFlagDesPos[2]) or (tbPos[3] ~= tbOppFlagDesPos[3])) then
				break;
			end
			tbPos = self:GetFlagAddPos(nCampId);
		end
	end
	
	local tbNpcObj		= {};
	local bRevive		= 0;
	-- 添加战旗NPC
	tbNpcObj		= KNpc.Add2(self.FLAG_ID[nCampId], 1, -1, tbPos[1], tbPos[2], tbPos[3], bRevive);
	self.tbCamps[nCampId]:PushNpcHighPoint(tbNpcObj, self.MINIMAP_FLAG[nCampId]);
	local szMsg		= string.format("<color=yellow>%s<color>-Quân kỳ xuất hiện tại <color=green>(%d, %d)<color>。", Battle.NAME_CAMP[nCampId], tbPos[2] / 8, tbPos[3] / 16);
	self.tbMission:BroadcastMsg(szMsg);
	self.tbMission.tbCamps[nCampId].tbSrcFlagPos = tbPos;
	return tbNpcObj;
end

-- 设置护旗目的地
function tbRuleBase:SetFlagDestination(nCampId)
	if (0 >= self.tbCamps[nCampId].nFlagLimit) then
		return;
	end
	local nOppCampId	= self.tbMission.tbCamps[nCampId].tbOppCamp.nCampId;
	local tbOppFlagPos	= self.tbMission.tbCamps[nOppCampId].tbSrcFlagPos;
	local tbPos			= self:GetFlagAddPos(nOppCampId);
	
	-- 如果存在敌方的战旗在本方大营或者前营中时需要检查是否会重叠
	if (tbOppFlagPos) then
		while true do
			if (tbPos and tbPos[2] and (tbPos[2] ~= tbOppFlagPos[2]) or (tbPos[3] ~= tbOppFlagPos[3])) then
				break;
			end
			tbPos = self:GetFlagAddPos(nOppCampId);
		end
	end

	local tbNpcObj		= {};
	local bRevive		= 0;
	tbNpcObj = KNpc.Add2(self.NOFLAGDES, 1, -1, tbPos[1], tbPos[2], tbPos[3], bRevive);
	self.tbCamps[nCampId]:PushNpcHighPoint(tbNpcObj, self.MINIMAP_DESFLAG);
	self.tbMission.tbCamps[nCampId].nDesFlagId		= tbNpcObj.dwId;
	self.tbMission.tbCamps[nCampId].tbFlagDesPos 	= tbPos;
	return tbPos;
end

function tbRuleBase:GetFlagNowPos(nCampId)
	local tbPos		= {};
	local tbCamp	= self.tbMission.tbCamps[nCampId]; 
	-- 说明旗子已经在玩家手上
	if (tbCamp.nPlayerIsFlag > 0) then
		local pPlayer		= KPlayer.GetPlayerObjById(tbCamp.nPlayerIsFlag);
		if (pPlayer) then
			local nWorldId, nPosX, nPosY = pPlayer.GetWorldPos();
			tbPos[1]	= nPosX;
			tbPos[2]	= nPosY;
			return tbPos;
		end
	end
	
	if (tbCamp.tbSrcFlagPos) then
		tbPos[1] = tbCamp.tbSrcFlagPos[2];
		tbPos[2] = tbCamp.tbSrcFlagPos[3];
		return tbPos;
	end
end

-- 护旗模式离开战场的操作，名字不好取，其实是作为对外借口，做模式一些特殊操作
function tbRuleBase:OnLeave(pPlayer)
	self:RestorePlayerState(pPlayer);
	self:DeletePlayerFlag(pPlayer);
end

-- 删除有战旗玩家的战旗，在玩家死亡，离开战场的时候，回到后营的时候需要用到
function tbRuleBase:DeletePlayerFlag(pPlayer)
	local tbBattleInfo = Battle:GetPlayerData(pPlayer);
	pPlayer.SetAForbitSkill(Battle.SKILL_FORBID_ID, 0);
	-- 判断是否需要删除玩家身上的战旗，是否是战斗期间，是否有战旗，是否是同一个拿战旗
	if ((2 == self.tbMission.nState) and (1 == tbBattleInfo.bHaveFlag) and (tbBattleInfo.pPlayer.nId == tbBattleInfo.tbCamp.nPlayerIsFlag)) then
		local nWorldId, nPosX, nPosY = pPlayer.GetWorldPos();
		-- 当玩家进入后营，获得大营或者前营的生成战旗坐标
		if (0 == pPlayer.nFightState) then
			local tbPos	= self:GetFlagAddPos(tbBattleInfo.tbCamp.nCampId);
			nWorldId	= tbPos[1];
			nPosX		= tbPos[2];
			nPosY		= tbPos[3];
		end
		local nCampId	= tbBattleInfo.tbCamp.nCampId;
		local tbNpcObj	= {};
		local bRevive	= 0;
		tbNpcObj		= KNpc.Add2(self.FLAG_ID[nCampId], 1, -1, nWorldId, nPosX, nPosY, bRevive);
		tbBattleInfo.tbCamp:PushNpcHighPoint(tbNpcObj, self.MINIMAP_FLAG[nCampId]);
		local szMsg		= string.format("%s-Quân kỳ rơi tại (%d, %d).", Battle.NAME_CAMP[nCampId], nPosX / 8, nPosY / 16);
		self.tbMission:BroadcastMsg(szMsg);
		tbBattleInfo.tbCamp.nPlayerIsFlag	= 0;
		tbBattleInfo.tbCamp.tbSrcFlagPos	= {nWorldId, nPosX, nPosY};
		tbBattleInfo.bHaveFlag = 0;
		self:RestorePlayerState(tbBattleInfo.pPlayer);
		tbBattleInfo.tbCamp:PopNpcHighPoint(tbBattleInfo.pPlayer.GetNpc());
	end
	tbBattleInfo.bHaveFlag = 0;
end

-- 判断比赛胜负，返回胜利的一方，平局返回0
function tbRuleBase:GetWinCamp()
	local tbCampSong	= self.tbMission.tbCampSong;
	local tbCampJin		= self.tbMission.tbCampJin;

	-- 根据大将数量定输赢
	local nFlagSong	= tbCampSong.nFlags;
	local nFlagJin	= tbCampJin.nFlags;
	if (nFlagSong > nFlagJin) then
		return Battle.CAMPID_SONG;
	elseif (nFlagSong < nFlagJin) then
		return Battle.CAMPID_JIN;
	end
	
	-- 最后按积分计算
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

-- 杀死NPC时会告诉玩家杀的人是谁
function tbRuleBase:GetKillNpcBoardMsg(nRankId, nNpcBouns, pNpc)
	local szMsg		= "";
	szMsg = string.format("Hạ gục %s", Battle.NAME_RANK[nRankId]);
	return szMsg, 0;
end

-- 护旗成功
function tbRuleBase:ProtectFlagSuccess(tbBattleInfo)
	local tbPos 	= tbBattleInfo.tbCamp.tbFlagDesPos;			-- 获得护旗目的地坐标
	local nCampId	= tbBattleInfo.tbCamp.nCampId;
	-- 删除目的地npc
	local pHim		= KNpc.GetById(tbBattleInfo.tbCamp.nDesFlagId);
	assert(pHim);
	pHim.Delete();
	local tbNpcObj	= KNpc.Add2(self.FLAGDES_ID[nCampId], 1, -1, tbPos[1], tbPos[2], tbPos[3], 0);
	self.tbMission.tbCamps[tbBattleInfo.tbCamp.nCampId].nDesFlagId = tbNpcObj.dwId;
	-- 五秒钟后npc自动消失
	self.tbMission:CreateTimer(5 * 18, self.OnTimer_ResetFlagNpc, self, nCampId);
end

-- 每2秒钟检测护旗玩家是否到达目的地
function tbRuleBase:OnTimer_ReachToTheFlagDes()
	self:ReachToFlagDes(1);
	self:ReachToFlagDes(2);
	return;
end

-- 对于每个阵营都要检测是否到达目的地
function tbRuleBase:ReachToFlagDes(nCampId)
	local tbCamp		= self.tbMission.tbCamps[nCampId];
	if (0 == tbCamp.nPlayerIsFlag) then
		return;
	end
	local pPlayer		= KPlayer.GetPlayerObjById(tbCamp.nPlayerIsFlag);
	assert(pPlayer);
	local tbDesPos		= tbCamp.tbFlagDesPos;
	assert(tbDesPos);
	-- 获取玩家当前坐标
	local nWorldId, nPosX, nPosY = pPlayer.GetWorldPos();
	local nDis		= (nPosX - tbDesPos[2]) * (nPosX - tbDesPos[2]) + (nPosY - tbDesPos[3]) * (nPosY - tbDesPos[3]);
	if (self.FLAGDIS * self.FLAGDIS < nDis) then
		if (1 == tbCamp.bIsProtectFlag) then
			pPlayer.CloseGenerProgress();
			tbCamp.bIsProtectFlag = 0;
		end
		return;
	end
	
	if (1 == pPlayer.HasTimerBar()) then
		return;
	end

	Setting:SetGlobalObj(pPlayer);
	local tbEvent = 
	{
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
		Player.ProcessBreakEvent.emEVENT_DEATH,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
	}
	GeneralProcess:StartProcess("Đang kéo Quân kỳ...", 3 * Env.GAME_FPS, {self.ReachToFlagDesSuc, self, tbCamp, pPlayer.nId}, 
							{self.ForceCloseTimeBar, self, tbCamp}, tbEvent);
	tbCamp.bIsProtectFlag = 1;
	Setting:RestoreGlobalObj();
end

function tbRuleBase:ReachToFlagDesSuc(tbCamp, nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end
	if self.tbMission:IsOpen() ~= 1 then
		return;
	end
	self.tbMission:OnProtectFlag(pPlayer);
	-- 玩家变身
	self:RestorePlayerState(pPlayer);
	pPlayer.SetAForbitSkill(Battle.SKILL_FORBID_ID, 0);
	tbCamp.nPlayerIsFlag 	= 0;
	tbCamp.bIsProtectFlag	= 0;
	local tbBattleInfo		= Battle:GetPlayerData(pPlayer);
	tbBattleInfo.tbCamp:PopNpcHighPoint(tbBattleInfo.pPlayer.GetNpc());
	tbBattleInfo.bHaveFlag 	= 0;
	tbCamp.nFlagLimit = tbCamp.nFlagLimit - 1;
end

function tbRuleBase:ForceCloseTimeBar(tbCamp)
	tbCamp.bIsProtectFlag	= 0;	
end

-- 重置战旗
function tbRuleBase:OnTimer_ResetFlagNpc(nCampId)
	local pHim		= KNpc.GetById(self.tbMission.tbCamps[nCampId].nDesFlagId);
	if (pHim) then
		pHim.Delete();
	end
	self:AddFlag(nCampId);
	self:SetFlagDestination(nCampId);
	return 0;
end

function tbRuleBase:OnTimer_AddProtectBouns()
	local nDistanceSqure	= self.DISTANCE_ADD_BOUNS * self.DISTANCE_ADD_BOUNS;
	local tbPlayerList 		= self.tbMission:GetPlayerInfoList();
	local szMsg				= "";
	for _, tbInfo in pairs(tbPlayerList) do
		local pPlayer	= tbInfo.pPlayer;
		local nAddBouns	= 0;
		
		if (pPlayer) then
			if (pPlayer.IsDead() == 0) then
				-- 本方阵营旗子
				local tbCamp	= tbInfo.tbCamp;
				if (1 == self.nDuringProtect_TimeFlag) then
					local tbPos 	= self:GetFlagNowPos(tbCamp.nCampId);			-- 获得护旗目的地坐标
					if (tbPos and tbPos[1]) then
						local _, nX, nY	= pPlayer.GetWorldPos();
						local nDx	= tbPos[1] - nX;
						local nDy	= tbPos[2] - nY;
						if (nDx*nDx + nDy*nDy <= nDistanceSqure) then
							nAddBouns	= self.FLAG_PROTECT_BOUNS;
							szMsg		= string.format("Hộ kỳ di chuyển, nhận thưởng <color=yellow>%d<color> điểm.", nAddBouns);
							pPlayer.Msg(szMsg);
						end
					end
				end
				
				-- 两边只能加一个
				if (0 == nAddBouns) then
					-- 敌方阵营旗子
					tbCamp	= tbInfo.tbCamp.tbOppCamp;
					local tbPos 	= self:GetFlagNowPos(tbCamp.nCampId);			-- 获得护旗目的地坐标
					if (tbPos and tbPos[1]) then
						local _, nX, nY	= pPlayer.GetWorldPos();
						local nDx	= tbPos[1] - nX;
						local nDy	= tbPos[2] - nY;
						if (nDx*nDx + nDy*nDy <= nDistanceSqure) then
							nAddBouns	= self.FLAG_PROTECT_BOUNS;
							szMsg		= string.format("Hộ kỳ di chuyển, nhận thưởng <color=yellow>%d<color> điểm.", nAddBouns);
							pPlayer.Msg(szMsg);
						end
					end
				end
			end
		end
		
		if (nAddBouns > 0) then
			tbInfo:AddBounsWithoutCamp(nAddBouns);
		end
	end
	
	self.nDuringProtect_TimeFlag = math.fmod(self.nDuringProtect_TimeFlag + 1, 2);	

	return;
end

-- 护旗成功时给本阵营玩家加分
function tbRuleBase:GiveFlagCampBouns(nCampId, tbBattleInfo)
	local tbOurCamp	= self.tbCamps[nCampId];
	local tbOppCamp	= tbOurCamp.tbOppCamp;
	local nAddBouns	= self.BOUNS_PROTECT_FLAG_CAMP;
	tbOurCamp:AddCampBouns(nAddBouns);
	local szMsg	= string.format("%s %s hộ kỳ thành công, bạn nhận được <color=yellow>%d<color> điểm.", Battle.NAME_RANK[tbBattleInfo.nRank], tbBattleInfo.pPlayer.szName, nAddBouns);
	self.tbMission:BroadcastMsg(nCampId, szMsg);
end

-- 护旗成功给旗手周围的玩家300分奖励
function tbRuleBase:GiveProtectFlagBounsForNearPlayer(nCampId, tbBattleInfo)
	if (not tbBattleInfo or not tbBattleInfo.pPlayer) then
		return;
	end
	local nAddBouns			= self.PROTECT_SUCBOUNS_FOR_NEARPLAYER;
	local nDistance			= self.DISTANCE_ADD_PROTECT_SUCBOUNS;
	local tbPlayerInfoList	= self.tbMission:GetPlayerInfoList(nCampId);
	local nProtectPlayerId	= tbBattleInfo.pPlayer.nId; 
	local _, nMapX, nMapY	= tbBattleInfo.pPlayer.GetWorldPos();
	for _, tbPlayer in pairs(tbPlayerInfoList) do
		if (tbPlayer and tbPlayer.pPlayer) then
			local _, nX, nY = tbPlayer.pPlayer.GetWorldPos();
			local nDetX = nX - nMapX;
			local nDetY	= nY - nMapY;
			if (((nDetX * nDetX + nDetY * nDetY) <= nDistance * nDistance) and tbPlayer.pPlayer.nId ~= nProtectPlayerId) then
				tbPlayer:AddBounsWithoutCamp(nAddBouns);
				local szMsg	= string.format("Nhận thưởng công hộ kỳ <color=yellow>%d<color> điểm.", nAddBouns);
				tbPlayer.pPlayer.Msg(szMsg);
			end
		end
	end
end

-- 获得成功护旗积分
function tbRuleBase:GetProtectFlagBouns()
	return tbRuleBase.BOUNS_PROTECT_FLAG_PLAYER;
end

function tbRuleBase:GetProtectFlagMsg(tbBattleInfo)
	local szMsg = "";
	return szMsg;
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
		[8] = tbBattleInfo.nFlagNum;
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
		nTotalSongFlags		= tbMission.tbCampSong.nFlags;
		nTotalJinFlags		= tbMission.tbCampJin.nFlags;
		nRemainBTTime		= nRemainTime;
		nMyCampNum			= tbBattleInfo.tbCamp.nPlayerCount;
		nEnemyCampNum		= tbBattleInfo.tbCamp.tbOppCamp.nPlayerCount;
		nKillPlayerBouns	= tbBattleInfo.nKillPlayerBouns;
		nKillNpcBouns		= tbBattleInfo.nKillNpcBouns;
		nKillNpcNum			= tbBattleInfo.nKillNpcNum;
		nFlagNum			= tbBattleInfo.nFlagNum;
		nFlagsBouns			= tbBattleInfo.nFlagsBouns;
	};
	return tbMyInfo;
end

function tbRuleBase:ChangePlayerState(pPlayer)
	local nLevel = pPlayer.nLevel;
	local nSkillLevel = math.floor(nLevel / 10) - 7;
	Battle:ChangeFeature(pPlayer, Battle.RULE_PROTECTFLAG_CHANGESKILL, nSkillLevel, 3600 * 18);
	pPlayer.CallClientScript({"Battle:ChangeRightSkill", Battle.RULE_PROTECTFLAG_CHANGERIGHTSKILL});
end

function tbRuleBase:RestorePlayerState(pPlayer)
	Battle:RestoreFeature(pPlayer, Battle.RULE_PROTECTFLAG_CHANGESKILL);
	pPlayer.CallClientScript({"Battle:RestoreRightSkill"});
end

