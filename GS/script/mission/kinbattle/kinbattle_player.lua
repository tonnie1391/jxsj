-------------------------------------------------------
-- 文件名　：kinbattle_player.lua
-- 创建者　：huangxiaoming
-- 创建时间：2010-12-7 17:00:20
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return 0;
end

Require("\\script\\mission\\kinbattle\\kinbattle_def.lua");

local tbPlayer = KinBattle.tbPlayer or {};
KinBattle.tbPlayer = tbPlayer;

function tbPlayer:init(pPlayer, tbCamp)
	self.szName			= pPlayer.szName;		-- 玩家名字
	self.nKillCount		= 0;		-- 杀敌总数
	self.nRank			= 1;		-- 排名
	self.nBeKillCount	= 0;		-- 死亡次数
	self.nMaxSeries		= 0; 		-- 最大连斩数
	self.nSeries		= 0; 		-- 当前连斩数
	self.nBackTime		= 0;		-- 最后一次回营时间
	self.szFacName		= Player:GetFactionRouteName(pPlayer.nFaction, pPlayer.nRouteId) or "Vô";	-- 玩家门派名称
	self.tbBeKillerHonor	=		-- 杀死的披风等级
	{
		[1] = 0,
		[2] = 0,
		[3] = 0,
		[4] = 0,
		[5] = 0,
		[6] = 0,
		[7] = 0,
		[8] = 0,
		[9] = 0,
		[10] = 0,
	};
	self.nJiuZhuanCount	= 0;		--使用九转数
	self.pPlayer		= pPlayer;	-- 玩家
	self.tbMission		= tbCamp.tbMission;	-- 所属mission
	self.tbCamp			= tbCamp;	-- 所属阵营
	self.nFirstEnterFlag= 0;		-- 是否是第一次进入,非0则表示不是第一次进入
	self.nLastKillTime	= GetTime();
	self.nTaskMaxSeries	= pPlayer.GetTask(KinBattle.TASK_GROUP_ID, KinBattle.TASK_MAX_SERIES);
	self.nTaskMaxKillcount = pPlayer.GetTask(KinBattle.TASK_GROUP_ID, KinBattle.TASK_MAX_KILL);
end

--设置右侧信息
function tbPlayer:SetRightBattleInfo(nRemainFrame, nState)
	if nState == 1 then
		local szMsgFormat = "<color=green>等待时间：<color> <color=white>%s<color>";
		Dialog:SetBattleTimer(self.pPlayer, szMsgFormat, nRemainFrame);
		Dialog:SendBattleMsg(self.pPlayer, "");
		Dialog:ShowBattleMsg(self.pPlayer, 1, 0);
	elseif nState == 2 then
		local szMsgFormat = "<color=green>Thời gian còn lại: <color> <color=white>%s<color>";
		Dialog:SetBattleTimer(self.pPlayer, szMsgFormat, nRemainFrame);
		self:ShowRightBattleInfo();
	end	
end

--显示双方人数
function tbPlayer:ShowPlayerCount()
	if 1 == self.tbMission:GetGameState() then
		local szMsg = string.format("<color=green>本方人数：<color><color=white>%s<color>\n<color=green>对方人数：<color><color=white>%s<color>", self.tbCamp.nPlayerCount, self.tbMission.tbCamps[self.tbCamp.nCampIdMate].nPlayerCount);
		Dialog:SendBattleMsg(self.pPlayer, szMsg);	
		Dialog:ShowBattleMsg(self.pPlayer, 1, 0);
	end
end

--显示战场信息
function tbPlayer:ShowRightBattleInfo()
	local szMsg = string.format("<color=green>战场排名：<color> <color=yellow>%d<color>\n<color=green>伤敌玩家： <color><color=red>%d<color>", self.nRank, self.nKillCount);
	Dialog:SendBattleMsg(self.pPlayer, szMsg);	
	Dialog:ShowBattleMsg(self.pPlayer, 1, 0);
end

-- 删除右侧信息
function tbPlayer:DeleteRightBattleInfo()
	if self.pPlayer == nil then
		return 0;
	end
	Dialog:ShowBattleMsg(self.pPlayer, 0, 0);
end

--前往战场等待时间
function tbPlayer:GetTranRemainTime()
	local nCurTime = GetTime();
	local nDiffTime = nCurTime - self.nBackTime;
	return KinBattle.TIME_DEATHWAIT - nDiffTime;
end

function tbPlayer:HandleBeKiller()
	self.nBeKillCount = self.nBeKillCount + 1;
	self.tbCamp.nBeKillCount = self.tbCamp.nBeKillCount + 1;
	self.nBackTime = GetTime();
	self.nSeries = 0;	-- 清空连斩
end

function tbPlayer:HandleKiller(nHonorLevel)
	self:IncreaseSeries();
	self.nKillCount = self.nKillCount + 1;
	self.tbCamp.nKillCount = self.tbCamp.nKillCount + 1;
	self.nLastKillTime = GetTime();
	if nHonorLevel > 0 and nHonorLevel <= 10 then
		self.tbBeKillerHonor[nHonorLevel] = self.tbBeKillerHonor[nHonorLevel] + 1;
	end
	self:ShowRightBattleInfo();
	if not self.pPlayer then
		return 0;
	end
	if self.nKillCount > self.nTaskMaxKillcount then
		self.pPlayer.SetTask(KinBattle.TASK_GROUP_ID, KinBattle.TASK_MAX_KILL, self.nKillCount);
		self.nTaskMaxKillcount = self.nKillCount;
	end
	self.pPlayer.SetTask(KinBattle.TASK_GROUP_ID, KinBattle.TASK_LAST_KILL, self.nKillCount);
	local nTotalTimes = self.pPlayer.GetTask(KinBattle.TASK_GROUP_ID, KinBattle.TASK_KILL);
	self.pPlayer.SetTask(KinBattle.TASK_GROUP_ID, KinBattle.TASK_KILL, nTotalTimes + 1);
	if not self.tbMission.tbFirstPromt.nFirstBlood or self.tbMission.tbFirstPromt.nFirstBlood ~= 1 then
		KKin.Msg2Kin(self.tbCamp.nKinId, string.format(KinBattle.PROMPT_KINMSG[3], self.szName, self.tbCamp.szKinNameMate), 0);
		local szKillMsg = string.format(KinBattle.PROMPT_MAPMSG[3], self.tbCamp.szKinName, self.szName);
		self.tbMission:BroadcastMsg(szKillMsg);
		self.tbMission:Msg2Looker(szKillMsg);
		self.tbMission.tbFirstPromt.nFirstBlood = 1;
		self.tbCamp.tbFirstPromt.nKinFirstBlood = 1;
	else
		if not self.tbCamp.tbFirstPromt.nKinFirstBlood or self.tbCamp.tbFirstPromt.nKinFirstBlood  ~= 1 then
			KKin.Msg2Kin(self.tbCamp.nKinId, string.format(KinBattle.PROMPT_KINMSG[4], self.szName, self.tbCamp.szKinNameMate), 0);
			self.tbCamp.tbFirstPromt.nKinFirstBlood = 1;
		end
	end
	for i = 1, #KinBattle.SPECIAL_TITLE[2] do 
		if self.nKillCount == KinBattle.SPECIAL_TITLE[2][i].nLimit then		
			self:AddSpeTitle(2, i);
			-- 检查是否是第一个
			if not self.tbMission.tbFirstPromt.tbFirstKillCount then
				self.tbMission.tbFirstPromt.tbFirstKillCount = {};
			end
			if not self.tbCamp.tbFirstPromt.tbFirstKillCount then
					self.tbCamp.tbFirstPromt.tbFirstKillCount = {};
				end
			if not self.tbMission.tbFirstPromt.tbFirstKillCount[i] or self.tbMission.tbFirstPromt.tbFirstKillCount[i] ~= 1 then
				local szMsg = string.format(KinBattle.PROMPT_MAPMSG[5],self.tbCamp.szKinName, self.szName, self.nKillCount,  KinBattle.SPECIAL_TITLE[2][i].szTitle);
				self.tbMission:BroadcastMsg(szMsg);
				self.tbMission:Msg2Looker(szMsg);
				KKin.Msg2Kin(self.tbCamp.nKinId, string.format(KinBattle.PROMPT_KINMSG[6], self.szName, self.tbCamp.szKinNameMate, self.nKillCount), 0);
				self.tbMission.tbFirstPromt.tbFirstKillCount[i] = 1;
				self.tbCamp.tbFirstPromt.tbFirstKillCount[i] = 1;
			else	
				if not self.tbCamp.tbFirstPromt.tbFirstKillCount[i] or self.tbCamp.tbFirstPromt.tbFirstKillCount[i] ~= 1 then
					KKin.Msg2Kin(self.tbCamp.nKinId, string.format(KinBattle.PROMPT_KINMSG[8], self.szName, self.tbCamp.szKinNameMate, self.nKillCount, self.nKillCount), 0);
					self.tbCamp.tbFirstPromt.tbFirstKillCount[i] = 1;
				else	
					KKin.Msg2Kin(self.tbCamp.nKinId, string.format(KinBattle.PROMPT_KINMSG[2], self.szName, self.tbCamp.szKinNameMate, self.nKillCount), 0);
				end
				local szMsg = string.format(KinBattle.PROMPT_MAPMSG[2],self.tbCamp.szKinName, self.szName, self.nKillCount, KinBattle.SPECIAL_TITLE[2][i].szTitle);
				self.tbMission:BroadcastMsg(szMsg);
				self.tbMission:Msg2Looker(szMsg);
			end
		end
	end
end

--增加连斩
function tbPlayer:IncreaseSeries()
	self.nSeries = self.nSeries + 1;
	if self.nMaxSeries < self.nSeries then
		self.nMaxSeries = self.nSeries;
		if self.pPlayer then
			self.pPlayer.SetTask(KinBattle.TASK_GROUP_ID, KinBattle.TASK_LAST_MAXSERIES, self.nMaxSeries);
		end
	end
	if not self.pPlayer then
		return 0;
	end
	if self.nMaxSeries > self.nTaskMaxSeries then
		self.pPlayer.SetTask(KinBattle.TASK_GROUP_ID, KinBattle.TASK_MAX_SERIES, self.nMaxSeries);
		self.nTaskMaxSeries = self.nMaxSeries;
	end
	for i = 1, #KinBattle.SPECIAL_TITLE[1] do
		 if self.nSeries == KinBattle.SPECIAL_TITLE[1][i].nLimit then
			self:AddSpeTitle(1, i);
			-- 检查是否是第一个
			if not self.tbMission.tbFirstPromt.tbFirstSeries then
				self.tbMission.tbFirstPromt.tbFirstSeries = {};
			end
			if not self.tbCamp.tbFirstPromt.tbFirstSeries then
				self.tbCamp.tbFirstPromt.tbFirstSeries = {};
			end
			if not self.tbMission.tbFirstPromt.tbFirstSeries[i] or self.tbMission.tbFirstPromt.tbFirstSeries[i] ~= 1 then
				local szMsg = string.format(KinBattle.PROMPT_MAPMSG[4],self.tbCamp.szKinName, self.szName, self.nSeries, KinBattle.SPECIAL_TITLE[1][i].szTitle);
				self.tbMission:BroadcastMsg(szMsg);
				self.tbMission:Msg2Looker(szMsg);
				KKin.Msg2Kin(self.tbCamp.nKinId, string.format(KinBattle.PROMPT_KINMSG[5], self.szName, self.tbCamp.szKinNameMate, self.nSeries), 0);
				self.tbMission.tbFirstPromt.tbFirstSeries[i] = 1;
				self.tbCamp.tbFirstPromt.tbFirstSeries[i] = 1;
			else
				if not self.tbCamp.tbFirstPromt.tbFirstSeries[i] or self.tbCamp.tbFirstPromt.tbFirstSeries[i] ~= 1 then
					KKin.Msg2Kin(self.tbCamp.nKinId, string.format(KinBattle.PROMPT_KINMSG[7], self.szName, self.tbCamp.szKinNameMate, self.nSeries, self.nSeries), 0);
					self.tbCamp.tbFirstPromt.tbFirstSeries[i] = 1;
				else
					KKin.Msg2Kin(self.tbCamp.nKinId, string.format(KinBattle.PROMPT_KINMSG[1], self.szName, self.tbCamp.szKinNameMate, self.nSeries), 0);
				end
				local szMsg = string.format(KinBattle.PROMPT_MAPMSG[1], self.tbCamp.szKinName, self.szName, self.nSeries, KinBattle.SPECIAL_TITLE[1][i].szTitle);
				self.tbMission:BroadcastMsg(szMsg);
				self.tbMission:Msg2Looker(szMsg);
			end
		end
	end
end

-- 增加九转计数
function tbPlayer:IncreaseJiuZhuanCount()
	if 2 ~= self.tbMission:GetGameState() then
		return 0;
	end
	if self.pPlayer and self.pPlayer.nMapId == KinBattle.MAP_LIST[self.tbMission.nMissionId][1] then
		self.nJiuZhuanCount = self.nJiuZhuanCount + 1;
		self.tbCamp.nJiuZhuanCount = self.tbCamp.nJiuZhuanCount + 1;
	end
end

-- 设置家族战参战次数
function tbPlayer:UpdateMatchTimes()
	if not self.pPlayer then
		return 0;
	end
	if self.nFirstEnterFlag == 0 then		
		local nTimes = self.pPlayer.GetTask(KinBattle.TASK_GROUP_ID, KinBattle.TASK_MATCH_COUNT);
		self.pPlayer.SetTask(KinBattle.TASK_GROUP_ID, KinBattle.TASK_MATCH_COUNT, nTimes+1);
		self.pPlayer.SetTask(KinBattle.TASK_GROUP_ID, KinBattle.TASK_LAST_KILL, 0);
		self.pPlayer.SetTask(KinBattle.TASK_GROUP_ID, KinBattle.TASK_LAST_MAXSERIES, 0);
		StatLog:WriteStatLog("stat_info", "jiazuleitai", "join", self.pPlayer.nId, self.tbCamp.szKinName);
		self.nFirstEnterFlag = 1;
	end
end

-- 找寻最高等级称号索引
function tbPlayer:AddSpeTitle(nType, nIndex)
	for i = #KinBattle.SPECIAL_TITLE[nType], 1, -1 do
		if self.pPlayer.FindTitle(unpack(KinBattle.SPECIAL_TITLE[nType][i].tbId)) == 1 then
			if nIndex >= i then
				self.pPlayer.AddTitle(unpack(KinBattle.SPECIAL_TITLE[nType][nIndex].tbId));
				self.pPlayer.SetCurTitle(unpack(KinBattle.SPECIAL_TITLE[nType][nIndex].tbId));
			end
			return 0;
		end
	end
	self.pPlayer.AddTitle(unpack(KinBattle.SPECIAL_TITLE[nType][nIndex].tbId));
	self.pPlayer.SetCurTitle(unpack(KinBattle.SPECIAL_TITLE[nType][nIndex].tbId));
end