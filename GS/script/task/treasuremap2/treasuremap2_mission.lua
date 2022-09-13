-- 文件名  : treasuremap2_mission.lua
-- 创建者  : zounan
-- 创建时间: 2010-08-17 14:16:25
-- 描述    : 
Require("\\script\\fightafter\\fightafter_def.lua");
Require("\\script\\task\\treasuremap2\\treasuremap2_def.lua");

local Mission = Mission:New();
TreasureMap2.Mission = Mission;

-- 当玩家加入Mission“后”被调用
function Mission:OnJoin(nGroupId)	
	me.NewWorld(self.nMapId, unpack(TreasureMap2.TEMPLATE_LIST[self.nTreasureId].tbBirthPos));
--	me.SetDeathType(1);
	me.SetLogoutRV(1);
	TreasureMap2:OpenSingleUi(me, TreasureMap2.MSG_REMAIN, self:GetRemainTime()); --侧边显示 TODO
	TreasureMap2:UpdateMsgUi(me, string.format(TreasureMap2.MSG_INSTANCE,TreasureMap2.TEMPLATE_LIST[self.nTreasureId].szName, self.nTreasureLevel, math.floor(self.tbInstance.nScore)));
	
	me.GetTempTable("TreasureMap2").nCaptainId = self.nCaptainId;
	
	me.AddSkillState(TreasureMap2.SKILL_ID, TreasureMap2.SKILL_LEVEL[self.nTreasureLevel], 1, 2 * 3600 * Env.GAME_FPS, 1, 0, 1);	
	
--	TreasureMap2:SetMyInstancingTreasureId(me,self.nTreasureId);
	
	--没有参加过的话要扣ITEM
	if not self.tbMissionPlayerHasJoin[me.nId] then
		TreasureMap2:AddPlayerTimes(me);
		TreasureMap2:ConsumePlayerItem(me, self.nTreasureId, self.nTreasureLevel);
		self:PlayerFirstJoin(me);
	elseif not	self.tbMissionPlayerHasJoin[me.nId].nWeak then --没有记录
		self:PlayerFirstJoin(me);
	end
	
	TreasureMap2:WriteLog("副本进出情况",string.format("%s,进入", me.szName));
	if self.AfterJoin then
		self:AfterJoin();
	end
end;


function Mission:PlayerFirstJoin(pPlayer)
		self.tbMissionPlayerHasJoin[pPlayer.nId] = {};		
		self.tbMissionPlayerHasJoin[pPlayer.nId].nWeak  = TreasureMap2:GetWeakPercent(pPlayer,self.nTreasureId, self.nTreasureLevel);
		self.tbMissionPlayerHasJoin[pPlayer.nId].nLevel = TreasureMap2:GetAwardLevel(pPlayer,self.nTreasureId, self.nTreasureLevel);	
end

-- 当玩家离开Mission“后”被调用
function Mission:OnLeave(nGroupId, szReason)
	if self.DoLeave then
		self:DoLeave();
	end
	me.RemoveSkillState(TreasureMap2.SKILL_ID);	
	me.SetLogoutRV(0);
--	me.SetDeathType(0);	
	me.GetTempTable("TreasureMap2").nCaptainId = 0;
	TreasureMap2:CloseSingleUi(me);
	TreasureMap2:WriteLog("副本进出情况",string.format("%s,退出", me.szName));	
end;


function Mission:GetGameState()
	return self.nStateJour;
end

function Mission:GetStartTime()
	return self.nStartTime;
end

function Mission:IsOnceInMission(nPlayerId)
	if self.tbMissionPlayerHasJoin[nPlayerId] then
		return 1;
	else
		return 0;
	end
end


-- 开启活动
function Mission:StartGame(nPlayerId, nMapId,nCityMap, nTreasureId, nTreasureLevel)
	-- 设定可选配置项

	local tbLeavePos = nil;
--	if pPlayer then
--		local nLeaveMapId, nLeavePosX, nLeavePosY = pPlayer.GetWorldPos();
--		tbLeavePos = {nLeaveMapId, nLeavePosX, nLeavePosY};
--	end

	self.nCaptainId = nPlayerId;


	self.nMapId 		= nMapId;
	self.nTreasureMapId = nMapId; -- 兼容
	self.nCityMap 		= nCityMap;
	self.nTreasureId	= nTreasureId;
	self.nTreasureLevel = nTreasureLevel;
	self.szName			= TreasureMap2.TEMPLATE_LIST[nTreasureId].szName;
--	self.bMissionComplete	= 1;
	self.nStartTime = GetTime(); -- 开启时间
	if FightAfter.TB_NEW_WORLD[nCityMap] then --使用事后系统的传送点
		tbLeavePos = TreasureMap2.TB_NEW_WORLD[nCityMap];  -- 没啥用
	end
	
	self.tbMisCfg	= {
		nFightState	= 1,						-- 战斗状态
	--	tbLeavePos = tbLeavePos, 				-- 直接使用事后的leave
		tbDeathRevPos = {[0]= {nMapId, TreasureMap2.TEMPLATE_LIST[nTreasureId].tbBirthPos[1], TreasureMap2.TEMPLATE_LIST[nTreasureId].tbBirthPos[2]}},
		nOnDeath 		= 1, 	-- 死亡脚本可用
		nForbidSwitchFaction = 1, -- 禁止切换门派
		nForbidStall	= 1,    --禁止摆摊
	};
		
	self.tbMissionPlayerHasJoin = {[nPlayerId]={},}; -- 玩家使用过地图		
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);	
	if pPlayer then
		self:PlayerFirstJoin(pPlayer);
	end
	self.tbGroups	= {};
	self.tbPlayers	= {};
	self.tbTimers	= {};
	self.tbFavor	= {};     --副本记录表
	self.nStateJour = 0;
	self.tbNowStateTimer = nil;
	self.tbMisEventList	= 	--mission时间表
	{
--		{"StartEvent", Env.GAME_FPS * 60 * Task.FourfoldMap.TIME_GET_READY, "OnStartGame"},
-- 		对接事后 TODO
		{"EndEvent", Env.GAME_FPS * TreasureMap2.INSTANCE_TIME, "EndGame"}, 
	};
	
	-- Instance初始化

	self.tbInstance = {};     --副本记录表
	self.tbInstance.bComplete 	   = 0;
	self.tbInstance.nTreasureId    = nTreasureId; 	
	self.tbInstance.nLevel    = nTreasureLevel; 
	self.tbInstance.nScore	  = 0;
	self.tbInstance.nKillNpc  = 0;
	self.tbInstance.nKillBoss = 0;
	self.tbInstance.nType	  = 1;
	self.tbInstance.nUseTime  = 0;
	self.tbInstance.nGrade	  = 1;
	self.tbInstance.szName	  = "Tàng Bảo Đồ - "..(TreasureMap2.TEMPLATE_LIST[nTreasureId].szName);
	self.tbInstance.nType	  = FightAfter.emTYPE_TREASURE;

	self:DeriveAction();
	self:GoNextState();	-- 开始报名	

end


function Mission:OnStartGame()

end

function Mission:DeriveAction()
	if self.OnNew then
		self:OnNew();
	end
	self.nCurStep = 1;	

	if (self.GetSteps and #self:GetSteps() > 0) then
		self:CreateTimer(TreasureMap2.MISSION_ACTIVE_TIME, TreasureMap2.OnInstancingTimer, TreasureMap2, self.nMapId);
	end
	
end

function Mission:OnDeath(pKillerNpc) 	
	me.ReviveImmediately(0);	
	me.SetFightState(1);
end

function Mission:MissionComplete()
	--MissionComplete
	self.tbInstance.bComplete = 1;
	
	local nFavor = TreasureMap2.TEMPLATE_LIST[self.nTreasureId].tbInstanceInfo[self.nTreasureLevel].nFavor or 0;
	--亲密度
	if nFavor > 0 then
		self:AddFriendFavor(nFavor);
	end	
	
	
	self:ComputeInstance();	
	
	for _, pPlayer in pairs(self:GetPlayerList()) do	
		--[[ 星级 相关 先不要	
		local nTask  =	pPlayer.GetTask(TreasureMap2.TEMPLATE_LIST[self.nTreasureId].nTskGroupId, 
				TreasureMap2.TEMPLATE_LIST[self.nTreasureId].nTskInstanceLevelId);
		if nTask < self.nTreasureLevel then		
			pPlayer.SetTask(TreasureMap2.TEMPLATE_LIST[self.nTreasureId].nTskGroupId, 
				TreasureMap2.TEMPLATE_LIST[self.nTreasureId].nTskInstanceLevelId,
				self.nTreasureLevel);				
		end
		--]]
		
		-- 师徒成就	
		if TreasureMap2.TEMPLATE_LIST[self.nTreasureId].nAchievementId then
			Achievement_ST:FinishAchievement(pPlayer.nId, TreasureMap2.TEMPLATE_LIST[self.nTreasureId].nAchievementId);
		end	
		
		-- LOG 
		TreasureMap2:WriteLog("副本完成情况",string.format("%s,%s,%d,%d分钟", pPlayer.szName,
			TreasureMap2.TEMPLATE_LIST[self.nTreasureId].szName,self.nTreasureLevel, math.floor(self.tbInstance.nUseTime/60)));		
		
	end	

	self:ProcessTask();
	
	for _, pPlayer in pairs(self:GetPlayerList()) do
		local nXiakeLevel = self.nTreasureLevel;
		if nXiakeLevel > 2 then
			nXiakeLevel = 2;
		end
		XiakeDaily:AchieveTask(pPlayer, 2, self.nTreasureId * 10 + nXiakeLevel);
		SpecialEvent.ActiveGift:AddCounts(pPlayer, 7);		--通关藏宝图活跃度
		SpecialEvent.tbGoldBar:AddTask(pPlayer, 6);		--金牌联赛通关藏宝图
		SpecialEvent.BuyOver:AddCounts(pPlayer, SpecialEvent.BuyOver.TASK_TANGBAODO);
		
		local tbInfo = Kinsalary.EVENT_TYPE[Kinsalary.EVENT_BAOTU];
		Kinsalary:AddSalary_GS(pPlayer, Kinsalary.EVENT_BAOTU, tbInfo.nRate);
			
		--活动系统调用 
		local nFreeCount,tbFunExecute = SpecialEvent.ExtendAward:DoCheck("TreasureMapComplete",pPlayer,self.nTreasureId,self.nTreasureLevel);
		SpecialEvent.ExtendAward:DoExecute(tbFunExecute);
		
		if TimeFrame:GetState("Keyimen") == 1 then
			Item:ActiveDragonBall(pPlayer);
		end
		
		--教育任务完成判断
		local nTaskMainId = tonumber(TreasureMap2.TASK_MAIN_ID, 16);
		local nTaskSubId = tonumber(TreasureMap2.TASK_SUB_ID, 16);
		
		local tbPlayerTasks	= Task:GetPlayerTask(pPlayer).tbTasks;
		local tbTask = tbPlayerTasks[nTaskMainId];	-- 主任务ID
		
		if tbTask and tbTask.nReferId == nTaskSubId then
			if (tbPlayerTasks[nTaskMainId].nCurStep == TreasureMap2.TASK_STEP) then
				pPlayer.SetTask(TreasureMap2.TSK_GROUP_TASK_MAIN, TreasureMap2.TSK_GROUP_TASK_SUB, 1);
			end
		end
	end

	self:SendBlackBoardMsgByTeam("Vượt phó bản thành công. Chuẩn bị vào Đắc Duyệt Phường!");	
	
	self:UpdateTimeUI();
 	self:CreateTimer(TreasureMap2.MISSION_COMPLETE_WAITING * Env.GAME_FPS, self.EndGame, self);
	ClearMapNpc(self.nMapId);
	ClearMapObj(self.nMapId);
	TreasureMap2.MissionList[self.nCaptainId] = nil;  -- 直接不让进
	--TreasureMap2.tbOpenedList[self.nMapId] = nil;
end

function Mission:ComputeInstance()	
	self.tbInstance.tbTeamer = {};
	self.nEndTime 			 = GetTime();
	self.tbInstance.nEndTime = self.nEndTime;
	self.tbInstance.nUseTime = self.nEndTime - self.nStartTime;	
	
	local nTimeRate = 0;
	if	self.tbInstance.bComplete == 1 then  -- 完成才有 时间加成
		for i, tbData in ipairs(TreasureMap2.TEMPLATE_LIST[self.nTreasureId].tbTimeRate) do
			if self.tbInstance.nUseTime < tbData[1] then
				nTimeRate = tbData[2];
				break;
			end
		end
	end	
	
	self.tbInstance.nScoreFight = math.floor(self.tbInstance.nScore);
	self.tbInstance.nScoreFight = math.floor(self.tbInstance.nScoreFight * (1 + nTimeRate/100));
	self.tbInstance.nScore 		= self.tbInstance.nScoreFight;
	
	if nTimeRate > 0 then
 		self:SendMsgByTeam(string.format("Chúc mừng! Thời gian vượt phó bản %d phút, tương ứng phần thưởng <color=yellow>%d%%<color>",math.floor(self.tbInstance.nUseTime/60),nTimeRate));
 	end
	self:UpdateMsgUI();	 -- 分数变了要刷新
	--战斗积分要转为评价积分
	self.tbInstance.nScore   	= math.floor(self.tbInstance.nScoreFight / TreasureMap2.SCORE_RATE);
	self.tbInstance.nGrade	 	= math.floor(self.tbInstance.nScore /10) + 1;	
	-- 万一过百了。。。
	if self.tbInstance.nScore >= 100 then
		self.tbInstance.nGrade  = 10;
	end

	local szPlayersName = "";
	for _, pPlayer in pairs(self:GetPlayerList()) do
		local tbPlayerFavor = self.tbFavor[pPlayer.szName] or {};
		local nAwardLevel   = self.tbMissionPlayerHasJoin[pPlayer.nId].nLevel;
		local tbPlayerAward =  TreasureMap2:GetPlayerAwardInfo(nAwardLevel,self.tbInstance.nGrade,self.nTreasureId,self.nTreasureLevel);
		table.insert(self.tbInstance.tbTeamer,
			 {szName = pPlayer.szName, nWeak = self.tbMissionPlayerHasJoin[pPlayer.nId].nWeak,
			 	tbFavor = tbPlayerFavor, tbAward = tbPlayerAward,});
		szPlayersName = szPlayersName..","..pPlayer.szName;
	end	

	-- 队伍情况加上 副本名称和星级
	local szTmp = string.format("%s,%s,%s",TreasureMap2.IS_COMPLETE[self.tbInstance.bComplete],
		TreasureMap2.TEMPLATE_LIST[self.nTreasureId].szName,self.nTreasureLevel);
		
	 -- log 	
	TreasureMap2:WriteLog("Tình hình",szTmp..szPlayersName);
end


function Mission:EndGame()
	if self.tbInstance.bComplete == 0 then
		self:SendBlackBoardMsgByTeam("Vượt phó bản thất bại. Chuẩn bị vào Đắc Duyệt Phường!");
		self:ComputeInstance();
	end
	
	
--	TreasureMap2.MapTempletList.tbMapList[self.nMapId] = 0;
	TreasureMap2.MapTempletList.nCount = TreasureMap2.MapTempletList.nCount - 1;
	GCExcute({"TreasureMap2:Release_GC", self.nCaptainId});
--	GlobalExcute({"TreasureMap2:ReleaseMap", self.nCaptainId});
	TreasureMap2.MissionList[self.nCaptainId] = nil;
	TreasureMap2.tbOpenedList[self.nMapId] = nil;
	TreasureMap2:SetFreeMap(self.nTreasureId, self.nMapId);

	if #self.tbInstance.tbTeamer > 0 then
		for _, tbPlayerInfo in ipairs(self.tbInstance.tbTeamer) do 
			local pPlayer = GetPlayerObjFormRoleName(tbPlayerInfo.szName);
			if not pPlayer or self:GetPlayerGroupId(pPlayer) == -1 then -- 不在mission中则不NewWorld
				tbPlayerInfo.bNewWorld = 0;
			end
		end
	end		

	-- Leave
	ClearMapNpc(self.nMapId);
	ClearMapObj(self.nMapId);	
	self:Close();
	
	if #self.tbInstance.tbTeamer > 0 then  --放在之后 me.LogOutRV() 的原因
		FightAfter:FinishInstance(self.tbInstance);
	end	
	return 0;
end

function Mission:GetRemainTime()
	local nReMainTime =  TreasureMap2.INSTANCE_TIME + self.nStartTime - GetTime();
	if nReMainTime <= 0 then
		nReMainTime = 0;
	end
	
	if self.tbInstance.bComplete == 0 then
		return nReMainTime;
	end
	
	local nCompleteLeft = TreasureMap2.MISSION_COMPLETE_WAITING + self.nEndTime - GetTime();
	if nCompleteLeft <= 0 then
		return 0;
	end
	if nReMainTime > nCompleteLeft then
		nReMainTime = nCompleteLeft;
	end
	return nReMainTime;
end

function Mission:UpdateMsgUI()	
	for _, pPlayer in pairs(self:GetPlayerList()) do
		TreasureMap2:UpdateMsgUi(pPlayer,  string.format(TreasureMap2.MSG_INSTANCE,TreasureMap2.TEMPLATE_LIST[self.nTreasureId].szName, self.nTreasureLevel, math.floor(self.tbInstance.nScore)));		
	end	
end

function Mission:UpdateTimeUI()
	for _, pPlayer in pairs(self:GetPlayerList()) do
		TreasureMap2:UpdateTimeUi(pPlayer, TreasureMap2.MSG_REMAIN, self:GetRemainTime());
	end
end

function Mission:SendBlackBoardMsgByTeam(szMsg)
	for _, pPlayer in pairs(self:GetPlayerList()) do
		Dialog:SendBlackBoardMsg(pPlayer, szMsg);
	end
end

function Mission:SendMsgByTeam(szMsg)
	for _, pPlayer in pairs(self:GetPlayerList()) do
		pPlayer.Msg(szMsg);
	end
end


function Mission:NpcTalk(nNpcId,szChat)
	local pNpc = KNpc.GetById(nNpcId);
	if not szChat or #szChat == 0 then
		return 0;
	end
	if pNpc then
		pNpc.SendChat(szChat);
		local tbNearPlayer = KNpc.GetAroundPlayerList(nNpcId,40);
		if tbNearPlayer then
			for _, pPlayer in ipairs(tbNearPlayer) do
				pPlayer.Msg(szChat, pNpc.szName);
			end
		end
	else
		return 0;
	end
end


function Mission:AwardWeiWangAndXinde(nWeiWang, nGongXian, nXinDe)	
	for _, pPlayer in pairs(self:GetPlayerList()) do
		TreasureMap2:AwardWeiWang(pPlayer, nWeiWang, nGongXian);
		TreasureMap2:AwardXinDe(pPlayer, nXinDe);
	end
end

-- 对副本各种剧情任务的处理
function Mission:ProcessTask(pPlayer, MapId)
	local tbTask = TreasureMap2.TEMPLATE_LIST[self.nTreasureId].tbTask;
	if not tbTask then
		return;
	end
	

	for _, pPlayer in pairs(self:GetPlayerList()) do
		if pPlayer.GetTask(TreasureMap2.TSKGID, tbTask[1]) == 1 then
			pPlayer.SetTask(TreasureMap2.TSKGID, tbTask[1], 2, 1);
		end;
		
		if pPlayer.GetTask(TreasureMap2.TSKGID, tbTask[2]) == 1 then
			pPlayer.SetTask(TreasureMap2.TSKGID,tbTask[2], 2, 1);
		end;
	end
end;

function Mission:AddFriendFavor(nFavor)
	local tbPlayerList = self:GetPlayerList();
	
	for i = 1, #tbPlayerList do
		for j = i + 1, #tbPlayerList do
			if tbPlayerList[i].IsFriendRelation(tbPlayerList[j].szName) == 1 then
				Relation:AddFriendFavor(tbPlayerList[i].szName, tbPlayerList[j].szName, nFavor);
				tbPlayerList[i].Msg(string.format("Bạn và <color=yellow>%s<color> độ thân mật tăng %d điểm", tbPlayerList[j].szName, nFavor));
				tbPlayerList[j].Msg(string.format("Bạn và <color=yellow>%s<color> độ thân mật tăng %d điểm", tbPlayerList[i].szName, nFavor));
				self.tbFavor[tbPlayerList[i].szName] = self.tbFavor[tbPlayerList[i].szName] or {};
				self.tbFavor[tbPlayerList[i].szName][tbPlayerList[j].szName] = nFavor;
				self.tbFavor[tbPlayerList[j].szName] = self.tbFavor[tbPlayerList[j].szName] or {};
				self.tbFavor[tbPlayerList[j].szName][tbPlayerList[i].szName] = nFavor;
			end
		end
	end
end	


function Mission:AddInstanceScore(nScore)
	if not nScore or nScore == 0 then
		return;
	end
	
	self.tbInstance.nScore	= self.tbInstance.nScore + nScore;
	self:UpdateMsgUI();	
end

function Mission:AddKillNpcNum(nScore)
	self.tbInstance.nKillNpc	= self.tbInstance.nKillNpc + 1;	
end

function Mission:AddKillBossNum(pNpc)	
	self.tbInstance.nKillBoss	= self.tbInstance.nKillBoss + 1;
	local nScore = pNpc.GetTempTable("TreasureMap2").nNpcScore;
	if not nScore or nScore == 0 then
		return;
	end
	
	self:SendMsgByTeam(string.format("Tổ đội hạ gục <color=yellow>%s<color>, nhận <color=yellow>%d<color> điểm tích lũy.",pNpc.szName, nScore));
	self:AddInstanceScore(pNpc.GetTempTable("TreasureMap2").nNpcScore);
end


	
function TreasureMap2:OnInstancingTimer(nTreasureMapId)
	local tbInstancing = self.tbOpenedList[nTreasureMapId];
	if (not tbInstancing) then
		return;
	end
	local tbSteps = tbInstancing:GetSteps();
	local tbStep = tbSteps[tbInstancing.nCurStep]
	if (not tbStep) then
	--	tbInstancing.nTimerId = nil;
		return 0;
	end
	
	-- 满足condition
	if (self:CheckConditions(tbStep.tbConditions) == 1) then
		tbInstancing.nCurStep = tbInstancing.nCurStep + 1;
		self:DoActions(tbStep.tbActions);
		return tbStep.nTime * Env.GAME_FPS;
	end
	
	return self.MISSION_ACTIVE_TIME;
end


function TreasureMap2:CheckConditions(tbConditions)
	if (not tbConditions) then
		return 1;
	end
	
	for _, tbCondition in ipairs(tbConditions) do
		local _, nRet	= Lib:CallBack(tbCondition);
		if (nRet ~= 1) then
			return 0
		end
	end
	
	return 1;
end

function TreasureMap2:DoActions(tbActions)
	if (not tbActions) then
		return;
	end
	
	for _, tbAction in ipairs(tbActions) do
		Lib:CallBack(tbAction);
	end
end
