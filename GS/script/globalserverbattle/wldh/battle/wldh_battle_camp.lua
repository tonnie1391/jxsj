-------------------------------------------------------
-- 文件名　：wldh_battle_camp.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-08-24 16:51:51
-- 文件描述：
-------------------------------------------------------

Require("\\script\\globalserverbattle\\wldh\\battle\\wldh_battle_def.lua");

local tbCampBase = Wldh.Battle.tbCampBase or {};	-- 支持重载
Wldh.Battle.tbCampBase = tbCampBase;

-- 构造初始化
function tbCampBase:init(nCampId, tbMapCampData, szLeagueName, tbMission)

	self.nCampId	= nCampId;
	self.tbMapData	= tbMapCampData;
	self.tbMission	= tbMission;

	self.szCampName		= Wldh.Battle.NAME_CAMP[nCampId];
	self.nDbTskId_PlCnt	= Wldh.Battle.DBTASKID_PLAYER_COUNT[tbMission.nBattleIndex][nCampId];
	self.szLeagueName 	= szLeagueName;
	self.nBouns			= 0;
	self.tbBTSaveData	= {};
	self:SetPlayerCount(0);

	self:AddDialogNpc("Npc_chuwuxiang", Wldh.Battle.NPCID_WUPINBAOGUANYUAN);
	self:AddDialogNpc("Npc_junyiguan", Wldh.Battle.NPCID_HOUYINGJUNYIGUAN);
	self:AddDialogNpc("Npc_chefu", Wldh.Battle.NPCID_CHEFU);
end

-- 比赛开始
function tbCampBase:OnStart()
	local tbPlayerList = self.tbMission:GetPlayerList(self.nCampId);
	for _, pPlayer in pairs(tbPlayerList) do
		pPlayer.SetTask(Wldh.Battle.TASK_GROUP_ID, Wldh.Battle.TASKID_PLAYER_KEY, self.tbMission.nBattleKey);
		pPlayer.SetTask(Wldh.Battle.TASK_GROUP_ID, Wldh.Battle.TASKID_CAMP, self.nCampId);
	end
end

-- 比赛结束，处理本方阵营奖励等
function tbCampBase:OnEnd(nResult)	
	
	-- 发送胜败消息
	local tbPlayerList = self.tbMission:GetPlayerList(self.nCampId);
	local szMsg	= string.format(Wldh.Battle.MSG_CAMP_RESULT[nResult], self.tbMission:GetFullName(), self.szCampName);
	
	for _, pPlayer in pairs(tbPlayerList) do
		Dialog:SendInfoBoardMsg(pPlayer, szMsg);
		local tbBattleInfo = Wldh.Battle:GetPlayerData(pPlayer);
		pPlayer.Msg(string.format("你最后排名是：<color=green>%d<color>, 获得的积分是：<color=yellow>%d<color>", tbBattleInfo.nListRank, tbBattleInfo.nBouns));
	end
end

-- 本方有玩家加入
function tbCampBase:OnJoin(pPlayer)
	
	-- 人数增加
	self:SetPlayerCount(self.nPlayerCount + 1);
	
	local tbBattleInfo = self:FindBTData(pPlayer);
	if not tbBattleInfo then
		tbBattleInfo = Lib:NewClass(Wldh.Battle.tbPlayerBase, pPlayer, self);
	else
		tbBattleInfo.pPlayer = pPlayer;	
	end

	-- 回后营时间
	tbBattleInfo.nBackTime	= GetTime();
	
	-- 职业
	tbBattleInfo.szFacName	= Player:GetFactionRouteName(pPlayer.nFaction, pPlayer.nRouteId);

	pPlayer.GetTempTable("Wldh").tbPlayerBattleInfo = tbBattleInfo;
	
	-- 头衔
	tbBattleInfo.pPlayer.AddTitle(2, self.nCampId, tbBattleInfo.nRank, 0);	
	
	-- 显示时间
	if 2 == self.tbMission.nState then
		local nRemainFrame	= self.tbMission:GetStateLastTime(self.tbMission.nState);
		tbBattleInfo:SetRightBattleInfo(nRemainFrame);
	else
		tbBattleInfo:DeleteRightBattleInfo();
	end
end

-- 本方有玩家离开
function tbCampBase:OnLeave(pPlayer)
	
	self:SetPlayerCount(self.nPlayerCount - 1);
	self:SaveBTData(pPlayer);
	
	pPlayer.RemoveSkillState(Wldh.Battle.SKILL_DAMAGEDEFENCE_ID);
	local tbBattleInfo = Wldh.Battle:GetPlayerData(pPlayer);
	
	if tbBattleInfo then
		
		-- 关闭战斗信息显示
		tbBattleInfo:DeleteRightBattleInfo();
		
		-- 去掉头衔
		tbBattleInfo.pPlayer.RemoveTitle(2, self.nCampId, tbBattleInfo.nRank, 0);
	end
end

-- 本方有玩家被对方玩家杀
function tbCampBase:OnPlayerDeath(tbDeathBattleInfo)
	tbDeathBattleInfo.nSeriesKill		= 0;
	tbDeathBattleInfo.nSeriesKillNum	= 0;
	tbDeathBattleInfo.nBackTime			= GetTime();	-- 从1970年1月1日0时算起的秒数
	DeRobot:OnMissionDeath(tbDeathBattleInfo);
end

-- 本方有玩家杀死对方玩家
function tbCampBase:OnKillPlayer(tbKillerBattleInfo, tbDeathBattleInfo)
	Wldh.Battle:GiveKillerBouns(tbKillerBattleInfo, tbDeathBattleInfo);
	Wldh.Battle:ProcessSeriesBouns(tbKillerBattleInfo, tbDeathBattleInfo);
end

-- 设置阵营人数
function tbCampBase:SetPlayerCount(nPlayerCount)
	self.nPlayerCount = nPlayerCount;
	KGblTask.SCSetTmpTaskInt(self.nDbTskId_PlCnt, nPlayerCount + 1);	-- 按照人数+1保存
end

-- 获得阵营人数
function tbCampBase:GetPlayerCount()
	return self.nPlayerCount;
end

-- 传送
function tbCampBase:TransTo(pPlayer, szPosName)
	local tbPos	= self:GetMapPos(szPosName);
	pPlayer.NewWorld(unpack(tbPos));
end

-- 获得随机点
function tbCampBase:GetMapPos(szPosName)
	local tbPoss = self.tbMapData[szPosName];
	local nRand	= MathRandom(#tbPoss);
	return tbPoss[nRand];
end

-- 增加对话NPC
function tbCampBase:AddDialogNpc(szPosName, nNpcId)
	for _, tbPos in pairs(self.tbMapData[szPosName]) do
		KNpc.Add2(nNpcId, 1, 0, tbPos[1], tbPos[2], tbPos[3]);
	end
end

-- 保存玩家战场信息
function tbCampBase:SaveBTData(pPlayer)
	
	local tbPLInfo = {};
	
	tbPLInfo.nPLId= pPlayer.nId;
	tbPLInfo.tbPlayerBattleInfo	= Wldh.Battle:GetPlayerData(pPlayer);
	
	if not tbPLInfo.tbPlayerBattleInfo then
		return;
	end
	
	self.tbBTSaveData[#self.tbBTSaveData + 1] = tbPLInfo;
	tbPLInfo.pPlayer = nil;
end

-- 搜索玩家战场信息
function tbCampBase:FindBTData(pPlayer)
	
	local tbPlayerBattleInfo = nil;
	local nId = pPlayer.nId;
	local nDelId = 0;
	
	for nKey, tbPLInfo in pairs(self.tbBTSaveData) do
		if tbPLInfo.nPLId == nId then
			nDelId = nKey;
			tbPlayerBattleInfo = tbPLInfo.tbPlayerBattleInfo; 
			break;
		end
	end
	
	if 0 ~= nDelId then
		table.remove(self.tbBTSaveData, nDelId);
	end	
	return tbPlayerBattleInfo;
end

-- 为本方所有玩家加积分
function tbCampBase:AddCampBouns(nAddBouns)
	
	local tbPlayerInfoList = self.tbMission:GetPlayerInfoList(self.nCampId);
	
	-- 阵营奖励积分
	for _, tbBattleInfo in pairs(tbPlayerInfoList) do
		tbBattleInfo:AddBounsWithoutCamp(nAddBouns);
	end
end
