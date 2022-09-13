-- castlefight_console.lua
-- zhouchenfei
-- 城堡战控制类
-- 2010/11/6 13:53:08

Require("\\script\\mission\\castlefight\\castlefight_def.lua");

local tbConsole = Console:New(CastleFight.DEF_EVENT_TYPE);

CastleFight.CaslteConsole = tbConsole;

function tbConsole:init()
	self.tbCfg = {};
	self.tbMissionLists = {};
	self.tbPlayerCfg   = {};
	self.tbPlayerMis = self.tbPlayerMis or {};		--玩家Id索引，记录mission；
end

function tbConsole:LoadCfgFile()
	self.tbMissionLists = {};
	self.tbPlayerCfg   = {};
	self.tbPlayerMis = self.tbPlayerMis or {};		--玩家Id索引，记录mission；

	local tbFile = Lib:LoadTabFile(CastleFight.DEF_EVENT_FILE);

	self.tbCfg = {
			tbMap			= {},
			tbDyInPos		= {},
			tbEventTimeList	= {},
		};

	if not tbFile then
		print("CastleFight读取文件错误，文件不存在castlefight_cfg.txt");
		return;
	end
	

	for nId, tbParam in ipairs(tbFile) do
		if nId > 1 then
			local szEventName	= tbParam.szName;
			local nDynamicMap	= tonumber(tbParam.MatchMap);				-- 动态地图模板，比赛用图
			local nMaxPlayer	= tonumber(tbParam.MaxReadyPlayer);			-- 最大参加玩家数
			local nMinDynPlayer	= tonumber(tbParam.MinCount);				-- 最少开启数
			local nMaxDynPlayer	= tonumber(tbParam.MaxCount);				-- 比赛地图最大玩家数		
			local nReadyTime	= tonumber(tbParam.ReadyTime);				-- 准备场时间
			local nDyInPosX		= tonumber(tbParam.MatchMapX);				-- 动态入场地图X坐标
			local nDyInPosY		= tonumber(tbParam.MatchMapY);				-- 动态入场地图Y坐标
			local nPkTime		= tonumber(tbParam.PkTime);					-- 比赛时间
			local nTimeStart	= tonumber(tbParam.Time_Start);				-- 每天活动开放开始时间
			local nTimeEnd		= tonumber(tbParam.Time_End);				-- 每天活动关闭时间
			local nTimeLong		= tonumber(tbParam.Time_Long);				-- 一场比赛时长，包括准备时间
			local nReadyMap		= tonumber(tbParam.ReadyMap);				-- 准备场地图
			local nReadyMapX	= tonumber(tbParam.ReadyMapX);				-- 准备场X坐标
			local nReadyMapY	= tonumber(tbParam.ReadyMapY);				-- 准备场Y坐标
			local szOpenWords	= tbParam.OpenWords;							-- 报名开始时的广播
			local szWaitWords	= tbParam.WaitWords;							-- 进入准备场后的消息
			local nMinTeamMember= tonumber(tbParam.MinTeamMember);			-- 一个队伍最少人数
			local nMaxTeamMember= tonumber(tbParam.MaxTeamMember);			-- 一个队伍最多人数
			local szJoinItem	= tbParam.JoinItem;
			local nEnterItemCount	= tonumber(tbParam.EnterItemMaxCount);
			local szSkillId			= tbParam.ItemEffect;
			local nEventStartTime	= tonumber(tbParam.EventStartTime);
			local nEventEndTime		= tonumber(tbParam.EventEndTime);
			local nEventAwardTime	= tonumber(tbParam.EventAwardTime);
			local nMaxDynamic	= tonumber(tbParam.MaxDyMapNum);
			local nMinLevel		= tonumber(tbParam.MinLevel);
			local szMission		= tbParam.Mission;
			local nBagNeedFree	= tonumber(tbParam.BagNeedFree);
			
			if (szEventName and szEventName ~= "") then
				self.tbCfg.szEventName		= szEventName;
			end
			
			if (nDynamicMap) then
				self.tbCfg.nDynamicMap		= nDynamicMap;
			end
			
			if (nMaxPlayer) then
				self.tbCfg.nMaxPlayer		= nMaxPlayer;
			end
			
			if (nMinDynPlayer) then
				self.tbCfg.nMinDynPlayer	= nMinDynPlayer;
			end
			
			if (nMaxDynPlayer) then
				self.tbCfg.nMaxDynPlayer	= nMaxDynPlayer;
			end
	
			if (nReadyTime) then
				self.tbCfg.nReadyTime = nReadyTime * Env.GAME_FPS;
			end
			
			if (nPkTime) then
				self.tbCfg.nPkTime = nPkTime;
			end
			
			if (nReadyMap) then
				local tbReadyMap = {};
				tbReadyMap.tbInPos = {nReadyMapX, nReadyMapY};
				self.tbCfg.tbMap[nReadyMap] = tbReadyMap;
			end
			
			if (nDyInPosX and nDyInPosY) then
				table.insert(self.tbCfg.tbDyInPos, {nDyInPosX, nDyInPosY});
			end
			
			if (nTimeStart and nTimeEnd and nTimeLong) then
				--table.insert(self.tbCfg.tbEventTimeList, {nTimeStart, nTimeEnd, nTimeLong});
				local nTime = nTimeStart;
				while nTime < nTimeEnd do
					table.insert(self.tbCfg.tbEventTimeList, nTime);
					nTime = nTime + nTimeLong
					local nMod = math.fmod(nTime, 100);
					if (nMod >= 60) then
						nTime = nTime + 100 - 60;
					end
				end
			end
			
			if (szOpenWords and szOpenWords ~= "") then
				self.tbCfg.szOpenWords = szOpenWords;
			end
			
			if (szWaitWords and szWaitWords ~= "") then
				self.tbCfg.szWaitWords = szWaitWords;
			end
			
			if (nMaxTeamMember) then
				self.tbCfg.nMaxTeamMember = nMaxTeamMember;
			end
			
			if (nMinTeamMember) then
				self.tbCfg.nMinTeamMember = nMinTeamMember;
			end
			
			if (szJoinItem and string.len(szJoinItem) > 0) then
				local tbItem = Lib:SplitStr(szJoinItem);
				if (#tbItem > 0) then
					local tbInfo = {};
					for _, nId in ipairs(tbItem) do
						tbInfo[#tbInfo + 1] = tonumber(nId);
					end
					local tbItemSkill = {};
					if (szSkillId and szSkillId ~= "") then
						local tbList = Lib:SplitStr(szSkillId);
						for i, nId in ipairs(tbList) do
							tbList[i] = tonumber(nId);
						end
						tbItemSkill = tbList;
					end
					local tbItemInfo = {tbItem = tbInfo, tbItemSkill = tbItemSkill};
					if (not self.tbCfg.tbJoinItem) then
						self.tbCfg.tbJoinItem = {};
					end
					table.insert(self.tbCfg.tbJoinItem, tbItemInfo);
				end
			end
			
			if (nEnterItemCount) then
				self.tbCfg.nEnterItemCount = nEnterItemCount;
			end
	
			if (nEventStartTime) then
				self.tbCfg.nEventStartTime = nEventStartTime;
			end
	
			if (nEventEndTime) then
				self.tbCfg.nEventEndTime = nEventEndTime;
			end
	
			if (nEventAwardTime) then
				self.tbCfg.nEventAwardTime = nEventAwardTime;
			end

			if (nMaxDynamic) then
				self.tbCfg.nMaxDynamic = nMaxDynamic;
			end
			
			if (nMinLevel) then
				self.tbCfg.nMinLevel = nMinLevel;
			end
			
			if (szMission and szMission ~= "") then
				self.tbCfg.Mission = szMission;	
			end
	
			if (nBagNeedFree) then
				self.tbCfg.nBagNeedFree = nBagNeedFree;
			end
		end
	end
	
end

function tbConsole:LoadAwardFile()
	local tbFile = Lib:LoadTabFile(CastleFight.DEF_AWARD_FILE);

	self.tbAward = {};

	if not tbFile then
		print("CastleFight读取文件错误，文件不存在castlefight_cfg.txt");
		return;
	end

	for nId, tbParam in ipairs(tbFile) do
	end
end

-- MODULE_GAMESERVER gs 部分
if (MODULE_GAMESERVER) then

--GS开启报名回调
function tbConsole:OnMySignUp()
	if self.tbMissionLists then
		for _, tbWaitList in pairs(self.tbMissionLists) do
			for _, tbMis in pairs(tbWaitList) do
				if tbMis:IsOpen() == 1 then
					tbMis:EndGame();
				end
			end
		end
	else
		self.tbMissionLists = {};
	end
	self.tbPlayerMis	= {};
	self.tbPlayerCfg	= {};
	KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, self.tbCfg.szOpenWords);
	KDialog.Msg2SubWorld(self.tbCfg.szOpenWords);
end


--进入活动场地后
function tbConsole:OnJoin()
	self:SetJoinGameState(1);
	me.SetFightState(1);
end

--离开活动场地后
function tbConsole:OnLeave()	
	if self.tbPlayerMis[me.nId] and self.tbPlayerMis[me.nId]:IsOpen() == 1 then
		if self.tbPlayerMis[me.nId]:GetPlayerGroupId(me) > 0 then
			self.tbPlayerMis[me.nId]:KickPlayer(me);
			self.tbPlayerMis[me.nId] = nil;
		end
	end
	
	self:SetLeaveGameState();
end

--进入准备场后
function tbConsole:OnJoinWaitMap()	
	self:SetJoinGameState(1);
	local szMsg = "<color=green>Thời gian bắt đầu: <color=white>%s<color>";
	local nLastFrameTime = self:GetRestTime();
	self:OpenSingleUi(me, szMsg, nLastFrameTime);
	Dialog:SendBlackBoardMsg(me, self.tbCfg.szWaitWords);	
	self:UnpdateWaitMapPlayerCount(me.nMapId, 1);
end

--离开准备场后
function tbConsole:OnLeaveWaitMap()
	if self.tbPlayerCfg[me.nId] and self.tbPlayerCfg[me.nId][1] == 1 then
		return 0;
	end
	if self.tbPlayerMis[me.nId] and self.tbPlayerMis[me.nId]:IsOpen() == 1 then
		if self.tbPlayerMis[me.nId]:GetPlayerGroupId(me) > 0 then
			self.tbPlayerMis[me.nId]:KickPlayer(me);
			self.tbPlayerMis[me.nId] = nil;
		end
	end
	self:SetLeaveGameState();
	if self:GetConsoleState() < 2 then
		self:UnpdateWaitMapPlayerCount(me.nMapId, 0);
	end
	Dialog:ShowBattleMsg(me, 0, 0);
end

-- 更新准备场人数(地图id，是否同步自己)
function tbConsole:UnpdateWaitMapPlayerCount(nMapId, nSynSelf)
	local nPlayerCount = self:GetPlayerNumInMap(nMapId);
	local szMsg2 = string.format("<color=green>当前准备场地人数：<color=white>%s<color>", nPlayerCount);
	local tbPlayerIdList = self:GetPlayerIdList(nMapId);
	for _, nPlayerId in pairs(tbPlayerIdList) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			if nSynSelf == 1 or pPlayer.nId ~= me.nId then
				self:UpdateMsgUi(pPlayer, szMsg2);
			end
		end
	end	
end

--开始活动场；
function tbConsole:OnMyStart(tbCfg)
	--开启前先关闭未关闭的mission
	local nWaitMapId	= tbCfg.nWaitMapId;		--准备场Id
	local nDyMapId 	 	= tbCfg.nDyMapId;		--活动场Id
	local tbGroupLists 	= tbCfg.tbGroupLists;	--队伍列表
	local nRandom		= MathRandom(#self.tbCfg.tbDyInPos);
	local tbRandomPos	= self.tbCfg.tbDyInPos[nRandom];
	self.tbMissionLists = self.tbMissionLists or {};
	self.tbMissionLists[nWaitMapId] = self.tbMissionLists[nWaitMapId] or {};
	local tbBaseMission = KLib.GetValByStr(self.tbCfg.Mission);
	self.tbMissionLists[nWaitMapId][nDyMapId] = self.tbMissionLists[nWaitMapId][nDyMapId] or Lib:NewClass(tbBaseMission);
	local tbMission = self.tbMissionLists[nWaitMapId][nDyMapId];
	
	local nLeaveMapId, nLeavePosX, nLeavePosY = self:GetLeaveMapPos();

	tbMission:Init({nDyMapId}, {1,1600,3200}, 2);

	local nCamp			= 0;
	for nGroupId, tbGroup in pairs(tbGroupLists) do
		local nCaptionAId = 0;
		nCamp = nCamp + 1;
		for _, nPlayerId in pairs(tbGroup.tbList) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				self.tbPlayerMis[pPlayer.nId] = tbMission;
				self.tbPlayerCfg[pPlayer.nId] = {1};
				tbMission:JoinPlayer(pPlayer, nCamp);
				if nCaptionAId == 0 then
					KTeam.CreateTeam(nPlayerId);	--建立队伍
					nCaptionAId = nPlayerId;
				else
					KTeam.ApplyJoinPlayerTeam(nCaptionAId, nPlayerId);	--加入队伍
				end
				-- 数据埋点
				local nMemberCount = self:GetBaoMingMemberCout(nWaitMapId, pPlayer.nId);
				if nMemberCount == 1 then
					StatLog:WriteStatLog("stat_info", "fight_YLG", "join", pPlayer.nId, "single", 1);
				elseif nMemberCount > 1 then
					StatLog:WriteStatLog("stat_info", "fight_YLG", "join", pPlayer.nId, "team", nMemberCount);
				end
			end
		end
	end


	if (tbMission:GetPlayerCount() <= 0) then
		print("[CastleFight]OnMyStart 人数不足关闭mission!");
		tbMission:EndGame();
		return 0;
	end

	tbMission:StartGame();
--	tbMission:UpdataAllUi();	
end

function tbConsole:OnGroupLogic(nWaitMapId)
	self:GroupLogic(nWaitMapId); -- 用的是默认分配规则
end

function tbConsole:LogOutRV()
	self:OnLeaveWaitMap();
end

function tbConsole:ConsumeTask(pPlayer)
	CastleFight:ConsumeTask(pPlayer);
end

function tbConsole:OnSingUpSucess(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		pPlayer.SendMsgToFriend("Hảo hữu [<color=yellow>"..pPlayer.szName.."<color>] đăng ký tham gia “Quyết chiến Dạ Lam Quan”!");
	end
end


end

-- MODULE_GAMESERVER END

-- MODULE_GC_SERVER gc 部分
if (MODULE_GC_SERVER) then

function tbConsole:RegisterScheduleTask()
	if (not self.tbCfg or not self.tbCfg.tbEventTimeList) then
		print("[ERROR] CastleFight is no cfg table");
		return 0;
	end
	
	if tbConsole:CheckState() == 0 then
		print("活动已经关闭");
		return 0;
	end
	
	Console:RegisterScheduleTask_TimeTask("决战夜岚关", "CastleFight", "ScheduleCallOut_Common", self.tbCfg.tbEventTimeList);
end

end

CastleFight.CaslteConsole:LoadCfgFile();

