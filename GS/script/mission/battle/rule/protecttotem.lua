Require("\\script\\mission\\battle\\rule\\rulebase.lua");

local tbRuleBase = Battle:GetRuleClass(6, "Bảo vệ Long trụ");

--开龙柱所需时间10S
tbRuleBase.SEIZE_TOTEM_PROCESS_TIME = 10;
--龙柱开启后需要等待时间20S
tbRuleBase.SEIZE_TOTEM_WAIT_TIME = 20;
--占领龙柱后增加对应阵营积分间隔时间15S
tbRuleBase.CAMP_POINT_INTERVAL = 15;
--占领龙柱增加个人积分200分
tbRuleBase.SEIZE_TOTEM_PERSONAL_POINT = 200;
--占领龙柱后每次增加对应阵营积分20分
tbRuleBase.CAMP_POINT_PER_ONCE = 20;
--保护龙柱每次增加个人积分10分
tbRuleBase.PERSONAL_POINT_PER_ONCE = 10;
--胜利所需阵营积分
tbRuleBase.MATCH_POINT = 12000;
--保护龙柱加分范围
tbRuleBase.DISTANCE_ADD_BOUNS = 32;

-- 龙柱ID
tbRuleBase.TOTEM_ID = 
{
	[Battle.CAMPID_NEUTRAL]	= 20000,
	[Battle.CAMPID_SONG]		= 20000,
	[Battle.CAMPID_JIN]		= 20000,
};

tbRuleBase.TOTEM_NAME = 
{
	[Battle.CAMPID_NEUTRAL]	= "Trung lập",
	[Battle.CAMPID_SONG]	= "Mông Cổ",
	[Battle.CAMPID_JIN]		= "Tây hạ",
};

tbRuleBase.TOTEM_TITLE = 
{
	[Battle.CAMPID_NEUTRAL]	= string.format("<bclr=gray><color=white>%s<color><bclr>","Long trụ"),
	[Battle.CAMPID_SONG]	= string.format("<bclr=red><color=yellow>%s<color><bclr>","Long trụ"),
	[Battle.CAMPID_JIN]		= string.format("<bclr=purple><color=#FF400080>%s<color><bclr>","Long trụ"),
};

-- 迷你地图的图标
tbRuleBase.MINIMAP_TOTEM = 
{
	[Battle.CAMPID_NEUTRAL] = 11,
	[Battle.CAMPID_SONG] = 7,
	[Battle.CAMPID_JIN] = 8,
};

-- 比赛开始（之后）
function tbRuleBase:OnStart()
	if (_tbBase and type(_tbBase.OnStart) =="function") then
		_tbBase.OnStart(self);
	end
	
	for nCampId, tbMapInfo in pairs(self.tbMapInfoCamp) do
		--添加龙柱
		self:AddTotem(nCampId);
	end
end

-- 在szPosName位置添加龙柱, 初始化为中立
function tbRuleBase:AddTotem(nCampId)
	local tbNpcObj = {};
	local tbData = {};
	local bRevive = 0;
	
	if (self.tbCamps[nCampId].tbMapInfo["Npc_Totem"]) then
		for _, tbPos in pairs(self.tbCamps[nCampId].tbMapInfo["Npc_Totem"]) do
			tbNpcObj = KNpc.Add2(self.TOTEM_ID[Battle.CAMPID_NEUTRAL], 1, -1, tbPos[1], tbPos[2], tbPos[3], bRevive);
			tbData = tbNpcObj.GetTempTable("Npc");
			tbData.nCampId = Battle.CAMPID_NEUTRAL;
			tbData.nChangingToCampId = Battle.CAMPID_NEUTRAL;
			tbNpcObj.szName = self.TOTEM_NAME[tbData.nCampId];
			tbNpcObj.SetTitle(self.TOTEM_TITLE[tbData.nCampId]);
			self.tbCamps[Battle.CAMPID_SONG]:PushNpcHighPoint(tbNpcObj, self.MINIMAP_TOTEM[Battle.CAMPID_NEUTRAL]);
		end
	end
end

-- 判断比赛胜负，返回胜利的一方，平局返回0
function tbRuleBase:GetWinCamp()
	local tbCampSong	= self.tbMission.tbCampSong;
	local tbCampJin	= self.tbMission.tbCampJin;

	--阵营按积分计算
	if (tbCampSong.nBouns > tbCampJin.nBouns) then
		return Battle.CAMPID_SONG;
	elseif (tbCampSong.nBouns < tbCampJin.nBouns) then
		return Battle.CAMPID_JIN;
	end
	
	--按个人积分第一名的阵营计算
	local tbSortedList = self.tbMission:GetSortPlayerInfoList();
	if (tbSortedList[1]) then
		return tbSortedList[1].tbCamp.nCampId;
	end
	
	return Battle.CAMPID_NEUTRAL;
end

function tbRuleBase:OnTimer_WaitSeizeEnd(dwNpcId, nPlayerId)
	local pNpc = KNpc.GetById(dwNpcId);
	
	if (pNpc == nil) then
		return 0; -- 停止TIMER
	end
	
	local tbData = pNpc.GetTempTable("Npc");
	
	-- 被别人开走了
	if (tbData.nSeizePlayerId ~= nPlayerId) then
		return 0; -- 停止TIMER
	end
	
	local nMapId, nX, nY = pNpc.GetWorldPos();
	local tbNewNpc = {};
	local tbNewData = {};
	
	tbNewNpc = KNpc.Add2(self.TOTEM_ID[tbData.nChangingToCampId], 1, -1, nMapId, nX, nY, 0);
	tbNewData = tbNewNpc.GetTempTable("Npc");
	
	tbNewData.nChangingToCampId = Battle.CAMPID_NEUTRAL;
	tbNewData.nCampId = tbData.nChangingToCampId;
	tbNewData.nSeizePlayerId = nil;
	tbNewData.tbTimerList = {};
	self.tbCamps[Battle.CAMPID_SONG]:PopNpcHighPoint(pNpc);
	self.tbCamps[Battle.CAMPID_SONG]:PushNpcHighPoint(tbNewNpc, self.MINIMAP_TOTEM[tbNewData.nCampId]);
	tbNewNpc.szName = self.TOTEM_NAME[tbNewData.nCampId];
	tbNewNpc.SetTitle(self.TOTEM_TITLE[tbNewData.nCampId]);
	if (tbData.tbTimerList) then
		for _,tbTimer in pairs(tbData.tbTimerList) do
			tbTimer:Close();
		end
	end
	tbData.tbTimerList = {};
	pNpc.Delete();
	
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	
	if (pPlayer ~= nil) then
		local tbBattleInfo = Battle:GetPlayerData(pPlayer);
		tbBattleInfo:AddBounsWithoutCamp(self.SEIZE_TOTEM_PERSONAL_POINT);
		self.tbMission:BroadcastMsg(string.format("<color=yellow>%s<color>-%s <color=yellow>%s<color> chiếm lĩnh %s<enter>(<pos=%d,%d,%d>)",
				self.tbCamps[tbNewData.nCampId].szCampName,Battle.NAME_RANK[tbBattleInfo.nRank], pPlayer.szName, "Long trụ", nMapId, nX, nY));

	else
		self.tbMission:BroadcastMsg(string.format("<color=yellow>%s<color> chiếm đóng %s<enter>(<pos=%d,%d,%d>)",
				self.tbCamps[tbNewData.nCampId].szCampName, "Long trụ", nMapId, nX, nY));
	end
				
	local tbAddPointTimer = self.tbMission:CreateTimer(self.CAMP_POINT_INTERVAL * Env.GAME_FPS,
										self.OnTimer_AddCampPoint, self, tbNewNpc.dwId);
	tbNewData.tbTimerList["tbAddPointTimer"] = tbAddPointTimer;
	return 0; -- 停止TIMER
end

function tbRuleBase:OnTimer_AddCampPoint(dwNpcId)
	local pNpc = KNpc.GetById(dwNpcId);
	if (pNpc == nil) then
		return 0; -- 停止TIMER
	end
	
	local tbData = pNpc.GetTempTable("Npc");
	
	-- 处于争夺状态
	if (tbData.nChangingToCampId ~= Battle.CAMPID_NEUTRAL or
		tbData.nCampId == Battle.CAMPID_NEUTRAL) then
		return 0; -- 停止TIMER
	end
	
	-- 加对应阵营积分
	self.tbMission.tbCamps[tbData.nCampId].nBouns = self.tbMission.tbCamps[tbData.nCampId].nBouns + self.CAMP_POINT_PER_ONCE;
	
	-- 加周围本阵营个人积分
	local nDistanceSqure	= self.DISTANCE_ADD_BOUNS * self.DISTANCE_ADD_BOUNS;
	local tbPlayerList 		= self.tbMission:GetPlayerInfoList();
	local szMsg			= "";
	local tbTotemPos = {pNpc.GetWorldPos()};
	
	for _, tbInfo in pairs(tbPlayerList) do
		local pPlayer	= tbInfo.pPlayer;
		local nAddBouns	= 0;
		if (pPlayer and pPlayer.IsDead() == 0) then
			local tbBattleInfo = Battle:GetPlayerData(pPlayer);
			
			-- 本方阵营, 并且在周围
			if (tbBattleInfo.tbCamp.nCampId == tbData.nCampId) then
				local _, nX, nY	= pPlayer.GetWorldPos();
				local nDx = tbTotemPos[2] - nX;
				local nDy = tbTotemPos[3] - nY;
				if (nDx*nDx + nDy*nDy <= nDistanceSqure) then
					szMsg = string.format("Bảo vệ %s, nhận <color=yellow>%d<color> điểm tích lũy.", "Long trụ", self.PERSONAL_POINT_PER_ONCE);
					pPlayer.Msg(szMsg);
					tbBattleInfo:AddBounsWithoutCamp(self.PERSONAL_POINT_PER_ONCE);
				end
			end
		end
	end
	
	-- 阵营积分到上限了 比赛结束
	if (self.tbMission.tbCamps[tbData.nCampId].nBouns >= self.MATCH_POINT) then
		Battle:CloseBattle(self.tbMission.nBattleLevel, self.tbMission.nBattleKey, self.tbMission.nBattleSeq);
		return 0;
	end
	
	-- 让timer 继续运行
	return;
end

function tbRuleBase:OnKillPlayer(tbKillerBattleInfo, tbDeathBattleInfo)
	self:GiveKillerBouns(tbKillerBattleInfo, tbDeathBattleInfo);
	self:ProcessSeriesBouns(tbKillerBattleInfo, tbDeathBattleInfo);
end

-- 重写不加阵营积分
function tbRuleBase:GiveKillerBouns(tbKillerBattleInfo, tbDeathBattleInfo)
	tbKillerBattleInfo.nKillPlayerNum	= tbKillerBattleInfo.nKillPlayerNum + 1;
	
	-- 要不要做安全性检测呢？
	local nMeRank		= tbDeathBattleInfo.nRank;
	local nPLRank		= tbKillerBattleInfo.nRank;
	
	local nRadioRank	= 1;
	nRadioRank			= (10 - (nPLRank - nMeRank)) / 10;
	local nPoints		= math.floor(Battle.tbBonusBase.KILLPLAYER * nRadioRank);
	local nBounsDif		= self:AddShareBouns(tbKillerBattleInfo, nPoints)
	if (nBounsDif > 0) then
		tbKillerBattleInfo.nKillPlayerBouns = tbKillerBattleInfo.nKillPlayerBouns + nPoints;
	end
end

-- 重写不加阵营积分
function tbRuleBase:ProcessSeriesBouns(tbKillerBattleInfo, tbDeathBattleInfo)
	local nMeRank			= tbDeathBattleInfo.nRank;
	local nPLRank			= tbKillerBattleInfo.nRank;
	local pPlayer			= tbKillerBattleInfo.pPlayer;
	-- 符合连斩条件 计算有效连斩
	if (5 >= (nPLRank - nMeRank)) then
		local nSeriesKill	= tbKillerBattleInfo.nSeriesKill + 1;
		tbKillerBattleInfo.nSeriesKill	= nSeriesKill;

		if (math.fmod(nSeriesKill, 3) == 0) then	
			tbKillerBattleInfo.nTriSeriesNum	= tbKillerBattleInfo.nTriSeriesNum + 1;
			self:AddShareBouns(tbKillerBattleInfo, Battle.SERIESKILLBOUNS)
			tbKillerBattleInfo.pPlayer.Msg(string.format("%s-%s %s đẩy lùi %d, nhận %d điểm phần thưởng liên trảm", Battle.NAME_CAMP[tbKillerBattleInfo.tbCamp.nCampId], Battle.NAME_RANK[tbKillerBattleInfo.nRank], tbKillerBattleInfo.pPlayer.szName, tbKillerBattleInfo.nSeriesKill, Battle.SERIESKILLBOUNS));
		end

		if (tbKillerBattleInfo.nMaxSeriesKill < nSeriesKill) then
			tbKillerBattleInfo.nMaxSeriesKill = nSeriesKill;
		end
	end
	
	-- 计算连斩	
	local nSeriesKillNum	= tbKillerBattleInfo.nSeriesKillNum + 1;
	tbKillerBattleInfo.nSeriesKillNum	= nSeriesKillNum;

	if (tbKillerBattleInfo.nMaxSeriesKillNum < nSeriesKillNum) then
		tbKillerBattleInfo.nMaxSeriesKillNum = nSeriesKillNum;
	end
	local tbAchievementSeriesKill = 
	{
		[3] = 138,
		[10] = 139,
		[30] = 140,
		[50] = 141,
		[100] = 142,
	};
	if tbAchievementSeriesKill[nSeriesKillNum] then
		Achievement:FinishAchievement(pPlayer, tbAchievementSeriesKill[nSeriesKillNum]);	--连斩。
	end
	Achievement:FinishAchievement(pPlayer, 125);	--个人击退一名敌对玩家。
	Achievement:FinishAchievement(pPlayer, 126);	--个人击退20名敌对玩家
	Achievement:FinishAchievement(pPlayer, 127);	--个人击退200名敌对玩家。
end

-- 重写不加阵营积分
function tbRuleBase:AddShareBouns(tbBattleInfo, nBouns)
	local tbShareTeamMember = tbBattleInfo.pPlayer.GetTeamMemberList(1);
	if (not tbShareTeamMember) then
		return tbBattleInfo:AddBounsWithoutCamp(nBouns);
	end
	
	local nResult	= 0;	
	local nCount	= #tbShareTeamMember;
	if (0 < nCount) then
		local nTimes	= Battle.tbPOINT_TIMES_SHARETEAM[nCount];
		local nPoints	= nBouns * nTimes;
		nResult			= tbBattleInfo:AddBounsWithoutCamp(nPoints);
	end

-- 组队共享暂时不用
--	for _, pPlayer in pairs(tbShareTeamMember) do
--		if (pPlayer.nId ~= tbBattleInfo.pPlayer.nId) then
--			local nFaction, nRoutId = Battle:GetFactionNumber(pPlayer);
--			if (0 ~= nFaction) then
--				local nTimes	= Battle.tbPOINT_TIMES_SHAREFACTION[nFaction][nRoutId];
--				local nPoints	= nBouns * nTimes;
--				Battle:GetPlayerData(pPlayer):AddBounsWithoutCamp(nPoints);
--			end
--		end
--	end
	return nResult;
end
	