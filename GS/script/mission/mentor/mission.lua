-- 文件名　：mission.lua
-- 创建者　：zhaoyu
-- 创建时间：2009/10/26 14:39:51
-- 描  述  ：
Require("\\script\\mission\\mentor\\mentor.lua");

Esport.MentorMission = Mission:New();
local tbMission = Esport.MentorMission;
local Mentor = Esport.Mentor;

function tbMission:OnStart(nDyMapId)
	-- 设定可选配置项
	self.tbMisCfg	= {
		nFightState	= 1,						-- 战斗状态
		nPkState		= Player.emKPK_STATE_PRACTISE,--战斗模式
		nDeathPunish	= 1,
		nForbidSwitchFaction	= 1,
		nOnDeath		= 1,
		nOnKillNpc		= 1,
		tbDeathRevPos	= { {nDyMapId, Mentor.ENTER_X, Mentor.ENTER_Y} },
		tbEnterPos 		= { {nDyMapId, Mentor.ENTER_X, Mentor.ENTER_Y} },
	}
	self.nMisMapId = nDyMapId;
	self:Reset();
end

--重置到初始状态
function tbMission:Reset()
	self.bStarted 				= false;
	self.nDegree 				= 0; --获取副本进度
	self.nStep 					= 0; --副本事件Id
	self.nApprenticePlayerId 	= nil; --徒弟的Player
	self.nMasterPlayerId 		= nil; --师傅的Player
	self.tbAiNpcList = {};
	
	tbMission.tbMonsterList = 
		{--nNpcId	nNpcCount
			[2459] = 0,		--进度1事件一小怪
			[2460] = 0,		--进度1事件二蛮族首领
			[2461] = 0,		--进度1事件二护送NPC,该值可以被视为一个布尔值，值大于0时表示正在护送，当值为0时表示护送完成
			[2464] = 0,		--进度2左BOSS
			[2465] = 0,		--进度2右BOSS
			[2467] = 0,		--进度3BOSS
		}

	ClearMapNpc(self.nMisMapId);
	ClearMapObj(self.nMisMapId);
end

function tbMission:OnOpen()

	self:Reset();
	self:InitGame();
end

--初始化游戏副本，此时的me只能是徒弟
function tbMission:InitGame()
	local pApprenticePlayer = Mentor:GetApprentice(me.nId);
	local pMasterPlayer = Mentor:GetMaster(me.nId);
	self.nApprenticePlayerId = pApprenticePlayer.nId;	--设置徒弟的PlayerId
	self.nMasterPlayerId = pMasterPlayer.nId;			--设置师傅的PlayerId
	self:JoinPlayer(pApprenticePlayer, 1);				--加入徒弟到副本，并初始化self.tbMisCfg中的相关设置
	self:JoinPlayer(pMasterPlayer, 1);					--加入师傅到副本，并初始化self.tbMisCfg中的相关设置	
	self.nApprenticeLevel = pApprenticePlayer.nLevel;	--徒弟等级
	self.nMasterLevel	  = pMasterPlayer.nLevel;		--师傅等级
	self.nDegree = Mentor:GetDegree(self.nApprenticePlayerId);	
	self:ResetCurDegree();

	--扣除徒弟副本进度
	local nDaily = pApprenticePlayer.GetTask(Mentor.nGroupTask, Mentor.nSubDailyTimes);
	local nWeek = pApprenticePlayer.GetTask(Mentor.nGroupTask, Mentor.nSubWeeklyTimes);
	pApprenticePlayer.SetTask(Mentor.nGroupTask, Mentor.nSubDailyTimes, nDaily - 1);
	pApprenticePlayer.SetTask(Mentor.nGroupTask, Mentor.nSubWeeklyTimes, nWeek - 1);
	
	self.tbFightTimer = self:CreateTimer(Mentor.TIMEOUT * 60 * Env.GAME_FPS, self.OnGameOver, self); --副本超时
	local szMsg = string.format("冰封堡已经开启，您必须在%d分钟内完成任务。", Mentor.TIMEOUT);
	self:SendMessage(szMsg);
	
	--在传送进入副本之前判定该玩家身上是否有陷阱道具，如果有再判定是否合法
	self:ClearShituItem();
end

--根据nDegree和nStep添加npc，bClear不为空则清除原来npc
function tbMission:RefreshNpc(bClear)

	local tbSetting = Mentor.tbSetting;
	local nLevel;
	if bClear then
		ClearMapNpc(self.nMisMapId);
		
		--将记录怪物个数的数组清空
		for _, nNpcCount in pairs(self.tbMonsterList) do
			nNpcCount = 0;
		end
	end

	local pApprenticePlayer = KPlayer.GetPlayerObjById(self.nApprenticePlayerId);
	local pMasterPlayer = KPlayer.GetPlayerObjById(self.nMasterPlayerId);
	for _, tbValue  in ipairs(Mentor.tbSetting) do
		if tonumber(tbValue.nDegree) == self.nDegree and tonumber(tbValue.nStep) == self.nStep then
			if tonumber(tbValue.nLevel) == -1 then
				nLevel = self.nMasterLevel;
			elseif tonumber(tbValue.nLevel) == -2 then
				nLevel = self.nApprenticeLevel;
			else
				nLevel = tbValue.nLevel;
			end
			if tonumber(tbValue.bRoute) == 0 then
				local pNpc = KNpc.Add2(tonumber(tbValue.nNpcId), tonumber(nLevel), -1,
					self.nMisMapId, tbValue.nX / 32, tbValue.nY / 32, 0, tonumber(tbValue.nNpcType));
				self.tbAiNpcList[tonumber(tbValue.nNpcId)] = pNpc.dwId;
			elseif  tonumber(tbValue.bRoute) == 1 then
				local dwId = self.tbAiNpcList[tonumber(tbValue.nNpcId)];
				local pNpc = KNpc.GetById(dwId)	
				pNpc.AI_AddMovePos(tonumber(tbValue.nX), tonumber(tbValue.nY));
			end
			--记录指定类型怪物的个数 
			if self.tbMonsterList[tonumber(tbValue.nNpcId)] then
				self.tbMonsterList[tonumber(tbValue.nNpcId)] = self.tbMonsterList[tonumber(tbValue.nNpcId)] + 1;
			end
		end
	end
	
end

--副本已经准备好，开始游戏
--function tbMission:OnGameStart() 
--end

--根据任务变量，添加接头npc
function tbMission:BeginGame()
	self.bStarted = true;
	self:RefreshNpc();
	return 0;
end

function tbMission:GoNextStep()
	--如果当前进度大于3，出问题了，写个日志，关闭副本
	if self.nDegree > Mentor.WEEKLY_SCHEDULE then
		local pMasterPlayer 	= KPlayer.GetPlayerObjById(self.nMasterPlayerId);
		local pApprenticePlayer = KPlayer.GetPlayerObjById(self.nApprenticePlayerId);
		Dbg:WriteLog("Mentor_shitufuben", string.format("队伍{%s, %s}在师徒副本中的进度大于当前最大限制！！", 
			pMasterPlayer.szName, pApprenticePlayer.szName));
		
		self:EndGame(); --强制关闭副本
	end
	
	self.nStep = self.nStep + 1;
	local fnCall = Mentor.tbGameStepFunc[self.nDegree][self.nStep];
	if fnCall == nil then	
		--成功完成了当前进度，记录到任务变量
		local pApprenticePlayer = KPlayer.GetPlayerObjById(self.nApprenticePlayerId);
		
		if pApprenticePlayer then
			local nTaskDegree = pApprenticePlayer.GetTask(Mentor.nGroupTask, Mentor.nSubCurDegree);
			
			if nTaskDegree ~= self.nDegree and nTaskDegree == 1 then		--刚刚更新了每周的任务变量
				pApprenticePlayer.SetTask(Mentor.nGroupTask, Mentor.nSubCurDegree, nTaskDegree);
			elseif nTaskDegree == self.nDegree then
				pApprenticePlayer.SetTask(Mentor.nGroupTask, Mentor.nSubCurDegree, self.nDegree + 1);
			else
				--走到这里，是遇到了异常情况
				local pMasterPlayer 	= KPlayer.GetPlayerObjById(self.nMasterPlayerId);
				Dbg:WriteLog("Mentor_shitufuben",  string.format("队伍{%s, %s}在师徒副本中的进度异常！！", 
					pMasterPlayer.szName, pApprenticePlayer.szName)); 	
			end
		end
		
		self:EndGame();
	elseif type(fnCall) == "function" then
		self:CreateTimer(5 * Env.GAME_FPS, fnCall, self);
	end;
end

--玩家死亡事件回调
function tbMission:OnDeath()

	--进度1中某个玩家死后不需要重置副本,只需要把该玩家传送到副本开始点即可
	
	--将死亡玩家传送到副本开始点
	me.ReviveImmediately(0);
	me.SetFightState(1);
	if self.nDegree ~= 1 then
		local pOtherPlayerId = (me.nId == self.nApprenticePlayerId) and self.nMasterPlayerId or self.nApprenticePlayerId;
		local pOtherPlayer = KPlayer.GetPlayerObjById(pOtherPlayerId);
		--将另一个玩家传送到副本起始点
		if pOtherPlayer and pOtherPlayer.nMapId == self.nMisMapId then
			pOtherPlayer.NewWorld(unpack(self.tbMisCfg.tbEnterPos[1]));
		end

		--重置副本进度
		self:ResetCurDegree();
	end
end

--将当前进度重置为刚进入时的状态
function tbMission:ResetCurDegree()
	--先清除所有NPC
	ClearMapNpc(self.nMisMapId);
	
	--怪物数组全清0
	tbMission.tbMonsterList = 
		{--nNpcId	nNpcCount
			[2459] = 0,		--进度1事件一小怪
			[2460] = 0,		--进度1事件二蛮族首领
			[2461] = 0,		--进度1事件二护送NPC,该值可以被视为一个布尔值，值大于0时表示正在护送，当值为0时表示护送完成
			[2464] = 0,		--进度2左BOSS
			[2465] = 0,		--进度2右BOSS
			[2467] = 0,		--进度3BOSS
		}
	
	--再重新加载副本进度
	self.nStep = 0;
	self:GoNextStep();
	
	--重置的时候将任务技能道具删除
	--正常情况下，只需要判断徒弟就可以了，这里对师傅也做判断，以免出现师傅也有道具的情况
	self:ClearShituItem();
end

--玩家杀死NPC事件回调
function tbMission:OnKillNpc()
	assert(him);
	
	if not self.tbMonsterList or not self.tbMonsterList[him.nTemplateId] then
		return;
	end
	
	if self.tbMonsterList[him.nTemplateId] <= 0 then
		return;
	end
	
	self.tbMonsterList[him.nTemplateId] = self.tbMonsterList[him.nTemplateId] - 1;
	
	if self:IsAllMonstersClear() == 1 then
		--如果完成了进度2，则将为进度2杀死两个BOSS所启的timer关闭
		if self.tbTimer_Boss2 then
			self.tbTimer_Boss2 = nil;
		end
		self:GoNextStep();
	else
		--进度2的完成条件特殊，需要拿出来做个单独判定
		if self.nDegree == 2 then
			--进度2下只是杀死了其中的一个BOSS，启一个timer
			
			--由于该NPC之后会马上被DEL掉，这里保存它的相关信息，以便于复活该NPC
			local tbNpcInfo = {};
			tbNpcInfo.nTemplateId = him.nTemplateId;
			tbNpcInfo.nLevel = him.nLevel;
			tbNpcInfo.nX, tbNpcInfo.nY = him.GetMpsPos();
			tbNpcInfo.nNpcType = him.GetNpcType();

			self.tbTimer_Boss2 = self:CreateTimer(5 * Env.GAME_FPS, self.OnKillOneOfBoss2, self, tbNpcInfo);		--需要在5秒内杀死另外一个BOSS
		end
	end
end

--如果self.tbMonsterList中所有项的值都为0，则返回1，否则返回0
function tbMission:IsAllMonstersClear()
	for _, nNpcCount in pairs(self.tbMonsterList) do
		if nNpcCount ~= 0 then
			return 0;
		end
	end
	
	return 1;
end

--5秒内没有杀死另一NPC，复活该NPC
function tbMission:OnKillOneOfBoss2(tbNpcInfo)
	KNpc.Add2(tbNpcInfo.nTemplateId, tbNpcInfo.nLevel, -1, self.nMisMapId, tbNpcInfo.nX/32, tbNpcInfo.nY/32, 0, tbNpcInfo.nNpcType);
	self.tbMonsterList[tbNpcInfo.nTemplateId] = 1;		--怪重生之后，视为还没有杀死这个怪
	return 0;
end

--事件一：刷一批与师傅能力相当的小怪
function tbMission:BeginGame1_1()
	self:RefreshNpc();
	return 0;
end

--事件二：刷蛮族首领，刷出护送NPC
function tbMission:BeginGame1_2()
	--self:RefreshNpc();
	return 0;
end

--事件二：刷护送路上的怪，开启护送任务
function tbMission:BeginGame1_3()
	self:RefreshNpc();
	--删除对话NPC
	local dwId = self.tbAiNpcList[2458];
	local pNpc = KNpc.GetById(dwId);
	pNpc.Delete();

	--给护送NPC设置AI
	dwId = self.tbAiNpcList[2461];
	self.dwProtecNpcId = dwId;		--记录护送NPC的ID，以便该NPC被杀死时能够通过该值找到mission
	pNpc = KNpc.GetById(dwId);
	pNpc.SetNpcAI(9, nAttact or 0, bRetort or 1, -1, 25, 25, 25, 0, 0, 0, 0);
	pNpc.GetTempTable("Npc").tbOnArrive = { self.OnArrive, self };
	
	return 0;
end

--护送NPC到达指定地点
function tbMission:OnArrive()
	tbMission.tbMonsterList[2461] = 0;
	if  self:IsAllMonstersClear() == 1 then
		self:GoNextStep();
	end
end

--刷出2个战斗NPC
function tbMission:BeginGame2_1()
	self:RefreshNpc();
	return 0;
end
	
--刷出战斗NPC
function tbMission:BeginGame3_1()
	self:RefreshNpc(true);
	self:GoNextStep();
	return 0;
end

--NPC召唤守卫
function tbMission:BeginGame3_2()
	self:RefreshNpc();
	return 0;
end

--副本时间到
function tbMission:OnGameOver()
	local szMsg = "很遗憾，冰封堡已经关闭，下次努力吧。";
	self:SendMessage(szMsg);
	self:ClearShituItem();
	self:TransPlayerOut();
	self:Close();
	return 0;
end

--向师徒发送信息
function tbMission:SendMessage(szMsg)
	local pApprenticePlayer = KPlayer.GetPlayerObjById(self.nApprenticePlayerId);
	local pMasterPlayer = KPlayer.GetPlayerObjById(self.nMasterPlayerId);
	if pApprenticePlayer then
		Dialog:SendInfoBoardMsg(pApprenticePlayer, szMsg);
	end
	if pMasterPlayer then
		Dialog:SendInfoBoardMsg(pMasterPlayer, szMsg);
	end
end

function tbMission:TransPlayerOut()
	local tbLeavePos = {Mentor.LEAVE_MAP, Mentor.LEAVE_X, Mentor.LEAVE_Y };
	
	local pApprenticePlayer = KPlayer.GetPlayerObjById(self.nApprenticePlayerId);
	local pMasterPlayer = KPlayer.GetPlayerObjById(self.nMasterPlayerId);
	
	if pApprenticePlayer and pApprenticePlayer.nMapId == self.nMisMapId then
		pApprenticePlayer.NewWorld(unpack(tbLeavePos));
	end
	
	if pMasterPlayer and pMasterPlayer.nMapId == self.nMisMapId then
		pMasterPlayer.NewWorld(unpack(tbLeavePos));
	end
end

function tbMission:BeginAward()
	self.tbFightTimer = nil;
	self.tbAwardTimer = self:CreateTimer(Mentor.AwardTimer * Env.GAME_FPS, self.EndGame, self);	--5分钟后退出副本
	--初始化奖励相关设置...
end

--成功完成副本
function tbMission:EndGame()
	--传玩家出副本
	self:ClearShituItem();
	self:TransPlayerOut();
	self:Close();
	
	return 0;
end

function tbMission:OnClose()
	--self:ClearMapNpc(self.nMisMapId);
	self:Reset();
	Mentor:ReleaseMission(self);
end

--玩家离开副本
function tbMission:OnLeave()
	--可能清除道具
	me.SetFightState(0);
end

function tbMission:ReEnterMission(nPlayerId)
	--在传送进入副本之前判定该玩家身上是否有陷阱道具，如果有再判定是否合法
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	Setting:SetGlobalObj(pPlayer);
	local tbFindBoom = GM:GMFindAllRoom(Esport.Mentor.tbBoom);
	local tbFindFreeze = GM:GMFindAllRoom(Esport.Mentor.tbFreeze);
	local tbFindInfo = {};
	Lib:MergeTable(tbFindInfo, tbFindBoom);
	Lib:MergeTable(tbFindInfo, tbFindFreeze);
	self:CheckShituItem(tbFindInfo);
	
	me.NewWorld(unpack(self.tbMisCfg.tbEnterPos[1]));
	self:JoinPlayer(me, 1);
	
	Setting:RestoreGlobalObj();
end	

function tbMission:ClearShituItem()
	
	local pApprenticePlayer = KPlayer.GetPlayerObjById(self.nApprenticePlayerId)
	local pMasterPlayer = KPlayer.GetPlayerObjById(self.nMasterPlayerId);
	
	local pTeamMember = {};	--队伍只能有两个人
	table.insert( pTeamMember, pApprenticePlayer );
	table.insert( pTeamMember, pMasterPlayer );
	for i = 1, #pTeamMember do		
	   	Setting:SetGlobalObj(pTeamMember[i]);
		local tbFindBoom = GM:GMFindAllRoom(Esport.Mentor.tbBoom);
		local tbFindFreeze = GM:GMFindAllRoom(Esport.Mentor.tbFreeze);
		local tbFindInfo = {};
		Lib:MergeTable(tbFindInfo, tbFindBoom);
		Lib:MergeTable(tbFindInfo, tbFindFreeze);
		self:CheckShituItem(tbFindInfo);
		Setting:RestoreGlobalObj();
	end
	
end

function tbMission:CheckShituItem(tbFindInfo)
	if not tbFindInfo then
		return;
	end
	
	for _, tbBoomItem in pairs(tbFindInfo) do
		GM:_ClearOneItem(tbBoomItem.pItem, tbBoomItem.pItem.IsBind(), tbBoomItem.pItem.nCount);
	end
		
	--如果该玩家不是徒弟，则不需要考虑将合法的任务道具删除的情况
	if self.nApprenticePlayerId ~= me.nId then
		return;
	end
		
	if self.nDegree == 1 and self.nStep == 3 then		
		me.AddItem(unpack(Esport.Mentor.tbBoom));
	end
	if self.nDegree == 3 and self.nStep == 2 then
		me.AddItem(unpack(Esport.Mentor.tbFreeze));
	end		
end
Mentor.tbGameStepFunc = {
	{  tbMission.BeginGame, tbMission.BeginGame1_1, tbMission.BeginGame1_2, tbMission.BeginGame1_3 },
	{  tbMission.BeginGame, tbMission.BeginGame2_1 },
	{  tbMission.BeginGame, tbMission.BeginGame3_1, tbMission.BeginGame3_2 },
};
	