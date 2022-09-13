-- 文件名　：missionlevel10_base.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-09-19 16:54:43
-- 描述：10级新手教育副本base

local tbBase = Mission:New();

Task.PrimerLv10 = Task.PrimerLv10 or {};
local PrimerLv10 = Task.PrimerLv10;
PrimerLv10.tbBase = tbBase;


--初始化room
function tbBase:InitRoom(nStatic)
	if nStatic and nStatic == 1 then
		self.tbRoom = Lib:NewClass(PrimerLv10.tbStaticRoom);	
	else
		self.tbRoom = Lib:NewClass(PrimerLv10.tbRoom);	
	end
	self.tbRoom.tbBase = self;
end

--初始化mission
function tbBase:InitGame(nMapId,nServerId,nPlayerId,nIsStatic)
	self.nMapId = nMapId;
	self.nServerId = nServerId;
	self.nPlayerId = nPlayerId;
	self.nIsStatic = nIsStatic or 0;
	self.nIsEnded = 0;
	self.tbMisCfg = 
	{
		nForbidSwitchFaction = 1,
		nFightState = 1,
		tbEnterPos = {},
		tbLeavePos	= {},	-- 离开坐标
		tbDeathRevPos = {},	-- 死亡重生点
		nOnDeath = 1, 		-- 死亡脚本可用
		nDeathPunish = 1,
		nPkState = Player.emKPK_STATE_PRACTISE,
	};
	for i = 1 ,#PrimerLv10.ENTER_POS do
		table.insert(self.tbMisCfg.tbEnterPos, {self.nMapId, unpack(PrimerLv10.ENTER_POS[i])});
		table.insert(self.tbMisCfg.tbDeathRevPos, {self.nMapId, unpack(PrimerLv10.ENTER_POS[i])});
	end
	table.insert(self.tbMisCfg.tbLeavePos,{PrimerLv10:GetReturnBackMap(),PrimerLv10.LEAVE_POS[1],PrimerLv10.LEAVE_POS[2]});
	self:InitRoom(self.nIsStatic);
	self:Open();
	self:GameStart();
end

function tbBase:JoinGame(pPlayer)
	self:JoinPlayer(pPlayer,1);	-- 只有一个阵营
end

--结束mission
function tbBase:EndGame()
	if self.nGameTimerId and self.nGameTimerId > 0 then
		Timer:Close(self.nGameTimerId);
		self.nGameTimerId = 0;
	end
	if self.nWaringTimerId and self.nWaringTimerId > 0 then
		Timer:Close(self.nWaringTimerId);
		self.nWaringTimerId = 0;
	end
	self:Close();
	GCExcute{"Task.PrimerLv10:EndGame_GC",self.nPlayerId,self.nServerId,self.nMapId};
end

--申请完之后就开启了
function tbBase:GameStart()
	--如果已经开启，不进行游戏开启操作
	if self.nIsGameStart == 1 then
		return 0;
	end
	self.nCurrentStep = 0;	--起始阶段
	self.nIsGameStart = 1;
	if self.nIsStatic ~= 1 then	--静态的副本申请一次后就不用释放了
		self.nGameTimerId = Timer:Register(PrimerLv10.MAX_TIME * Env.GAME_FPS, self.GameTimeUp, self);
		self.nWaringTimerId = Timer:Register(Env.GAME_FPS, self.WaringMsg, self);
		self:AddFireAndWounded();	--加火种和伤员	
	 end
	 self:StartStep(1);
end

function tbBase:GameTimeUp()
	self.nGameTimerId = 0;
	self:PlayerMsg("副本时间结束，若未完成任务请重新进入。");
	self:AllBlackBoard("副本时间结束，若未完成任务请重新进入。");
	self:EndGame();
	return 0;
end

function tbBase:WaringMsg()
	if (not self.nCurSec) then
		self.nCurSec = 1;
	else
		self.nCurSec = self.nCurSec + 1;
	end
	
	if (self.nCurSec % 300 == 0) then
		self:AllBlackBoard("当前距离试炼山庄副本关闭还有"..math.floor((PrimerLv10.MAX_TIME - self.nCurSec)/60).."分钟");
		self:PlayerMsg("当前距离试炼山庄副本关闭还有"..math.floor((PrimerLv10.MAX_TIME - self.nCurSec)/60).."分钟");
	end
end

--关闭前清理
function tbBase:OnClose()
	self.nIsEnded = 1;
	self.tbRoom:ClearRoom();
	ClearMapNpc(self.nMapId);
	ClearMapObj(self.nMapId);
end

--离开时
function tbBase:OnLeave()
	me.SetFightState(0);	-- 非战斗状态
	me.DisabledStall(0);	-- 允许摆摊
	me.DisableOffer(0);		-- 允许贩卖
	me.RemoveSkillState(476);
	self:ClearTask();	
	if not self.nIsEnded or self.nIsEnded ~= 1 and self.nIsStatic ~= 1 then
		self:EndGame();			-- 离开的时候把副本关闭
	end
end

--把任务清空和对应的任务变量清空
function tbBase:ClearTask()
	--如果任务已经完成，则不用将任务置空
	if me.GetTask(1025,33) == 2 then
		Task:DoAccept(PrimerLv10.TASK_MAIN_ID,PrimerLv10.TASK_NEXT_SUB_ID);	--离开时候自动接上下一个任务
	elseif me.GetTask(1025,33) == 1 then
		self:WriteFailLog();
		for _,nId in pairs(PrimerLv10.tbTaskSubId) do
			me.SetTask(1025,nId,0);
		end
		Task:CloseTask(tonumber(PrimerLv10.TASK_MAIN_ID,16));
		Task:DoAccept(PrimerLv10.TASK_MAIN_ID,PrimerLv10.TASK_SUB_ID);
	end
	me.GetTempTable("Task").nKillNormalBossCount = nil;
	return 1;
end

function tbBase:WriteFailLog()
	local tbTask = Task:GetPlayerTask(me).tbTasks[tonumber(PrimerLv10.TASK_MAIN_ID,16)]
	if tbTask then
		StatLog:WriteStatLog("stat_info", "shilianzhixing","step",me.nId,tbTask.nCurStep);
	end
end


function tbBase:OnJoin(nGroupId)
	me.SetLogoutRV(1);			-- 服务器宕机保护
	me.DisabledStall(1);		-- 禁止摆摊
	me.DisableOffer(1);			-- 禁止贩卖
	self:SetPlayerLeftFightSkill(me);
	me.SetTask(1025,34,1);
	local pNpc = me.GetNpc();
	if pNpc then
		pNpc.CastSkill(476,1, -1,pNpc.nIndex,1);	--加个30分钟的菜时间
	end
end

function tbBase:OnDeath()
	me.ReviveImmediately(0);
	if me.nFightState == 0 then
		me.SetFightState(1);
	end
end

function tbBase:StartStep(nStep)
	if not self.tbRoom then
		return 0;
	end
	self.tbRoom:ProcessStep(nStep);
	self.nCurrentStep = nStep;
end

--设置玩家左键技能
function tbBase:SetPlayerLeftFightSkill(pPlayer)
	if not pPlayer then
		return 0;
	end
	pPlayer.CallClientScript({"Task.PrimerLv10:SetLeftSkill"});
end

--副本一开启就刷出伤员和火还有水井
function tbBase:AddFireAndWounded()
	local tbPassby = PrimerLv10.tbPasserby;
	if not tbPassby then
		return 0;
	end
	for nTemplateId,tbInfo in pairs(tbPassby) do
		for _,tbPos in pairs(tbInfo) do
			local pNpc = KNpc.Add2(nTemplateId,10,-1,self.nMapId,tbPos[1],tbPos[2]);
			if not pNpc then
				print("PrimerLv10 Add Passerby Error!",nTemplateId);
			end
		end
	end
	return 0;
end

--对应的五行怪物刷出
function tbBase:AddSeriesBoss(nNpcId,nSeries,nPlayerSeries)
	self.tbRoom:AddSeriesBoss(nNpcId,nSeries,nPlayerSeries);
end

--黑条通知
function tbBase:BlackBoard(pPlayer,szMsg)
	if pPlayer and szMsg and #szMsg ~= 0 then
		Dialog:SendBlackBoardMsg(pPlayer, szMsg);
	end
end

--集体黑条
function tbBase:AllBlackBoard(szMsg)
	local tbPlayer,nCount = self:GetPlayerList();
	if nCount > 0 then
		for _,pPlayer in pairs(tbPlayer) do
			if pPlayer then
				self:BlackBoard(pPlayer,szMsg);
			end
		end
	end
end

--npc说话
function tbBase:NpcTalk(nNpcId,szChat)
	local pNpc = KNpc.GetById(nNpcId);
	if not szChat or #szChat == 0 then
		return 0;
	end
	if pNpc then
		pNpc.SendChat(szChat);
		local tbNearPlayer = KNpc.GetAroundPlayerList(nNpcId,30);
		if tbNearPlayer then
			for _, pPlayer in ipairs(tbNearPlayer) do
				pPlayer.Msg(szChat, pNpc.szName);
			end
		end
	else
		return 0;
	end
end

function tbBase:PlayerMsg(szMsg)
	if not szMsg or #szMsg == 0 then
		return 0;
	end
	local tbPlayer,nCount = self:GetPlayerList();
	if nCount > 0 then
		for _,pPlayer in pairs(tbPlayer) do
			if pPlayer then
				pPlayer.Msg(szMsg,"系统");
			end
		end
	end
end

function tbBase:SetTask(nTaskId,nGroupId,nValue,bSync)
	local tbPlayer,nCount = self:GetPlayerList();
	if nCount > 0 then
		for _,pPlayer in pairs(tbPlayer) do
			if pPlayer then
				pPlayer.SetTask(nTaskId,nGroupId,nValue,bSync or 0);
			end
		end
	end
end

function tbBase:PushFire(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local nPushFireNum = pPlayer.GetTask(1025,39);
	if nPushFireNum >= PrimerLv10.MAX_PUSH_FIRE_NUM then
		return 0;
	end
	--设置任务变量，完成灭火步骤
	pPlayer.SetTask(1025,39,nPushFireNum + 1);	
end

function tbBase:CureWounded(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local nCureNum = pPlayer.GetTask(1025,40);
	if nCureNum >= PrimerLv10.MAX_CURE_NUM then
		return 0;
	end
	pPlayer.SetTask(1025,40,nCureNum + 1);
end

function tbBase:TeamExcete(pPlayer,varFun)
	if not pPlayer or not varFun or type(varFun) ~= "function" then
		return 0;
	end
	if pPlayer.nTeamId <= 0 then
		varFun(pPlayer);
	else
		local nMapId = pPlayer.nMapId;
		local tbMemeber = pPlayer.GetTeamMemberList();
		for _ ,pMember in pairs(tbMemeber) do
			if pMember and pMember.nMapId == nMapId then
				varFun(pMember);
			end
		end
	end
end