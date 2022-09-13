-- 文件名　：missionlevel20_base.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-09-20 10:22:12
-- 描述：20级教育副本base


local tbBase = Mission:New();

Task.PrimerLv20 = Task.PrimerLv20 or {};
local PrimerLv20 = Task.PrimerLv20;
PrimerLv20.tbBase = tbBase;

--初始化room
function tbBase:InitRoom(nStatic)
	if nStatic and nStatic == 1 then
		self.tbRoom = Lib:NewClass(PrimerLv20.tbStaticRoom);
	else
		self.tbRoom = Lib:NewClass(PrimerLv20.tbRoom);
	end
	self.tbRoom.tbBase = self;
end

--初始化mission
function tbBase:InitGame(nMapId,nServerId, nPlayerId,nStatic)
	self.nMapId = nMapId;
	self.nServerId = nServerId;
	self.nPlayerId = nPlayerId;
	self.nIsStatic = nStatic or 0;
	self.nIsEnded = 0;	--是否已经关闭
	self.tbIsTrapOpen = {0,0};	--两个障碍是否打开的开关
	self.tbMisCfg = 
	{
		nForbidSwitchFaction = 1,
		nFightState = 1,
		tbEnterPos = {},
		tbLeavePos	= {},	-- 离开坐标
		tbDeathRevPos = {},		-- 死亡重生点
		nOnDeath = 1, 		-- 死亡脚本可用
		nDeathPunish = 1,
		nPkState = Player.emKPK_STATE_PRACTISE,
	};
	for i = 1 ,#PrimerLv20.ENTER_POS do
		table.insert(self.tbMisCfg.tbEnterPos, {self.nMapId, unpack(PrimerLv20.ENTER_POS[i])});
		table.insert(self.tbMisCfg.tbDeathRevPos, {self.nMapId, unpack(PrimerLv20.ENTER_POS[i])});
	end
	table.insert(self.tbMisCfg.tbLeavePos,{PrimerLv20:GetReturnBackMap(1),PrimerLv20.LEAVE_POS[1],PrimerLv20.LEAVE_POS[2]});
	self:InitRoom(nStatic);
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
	GCExcute{"Task.PrimerLv20:EndGame_GC",self.nPlayerId,self.nServerId,self.nMapId};
end

--申请完之后就开启了
function tbBase:GameStart()
	--如果已经开启，不进行游戏开启操作
	if self.nIsGameStart == 1 then
		return 0;
	end
	if self.nIsStatic ~= 1 then
		self.nGameTimerId = Timer:Register(PrimerLv20.MAX_TIME * Env.GAME_FPS, self.GameTimeUp, self);
		self.nWaringTimerId = Timer:Register(Env.GAME_FPS, self.WaringMsg, self);
		self.nCurrentStep = 0;	--起始阶段
		self.tbRoom:AddTrapNpc();
	end
	self.nIsGameStart = 1;
	self:StartStep(1);		--游戏一开始就刷第一波怪
end

function tbBase:WaringMsg()
	if (not self.nCurSec) then
		self.nCurSec = 1;
	else
		self.nCurSec = self.nCurSec + 1;
	end
	
	if (self.nCurSec % 300 == 0) then
		self:AllBlackBoard("当前距离碧落谷副本关闭还有"..math.floor((PrimerLv20.MAX_TIME - self.nCurSec)/60).."分钟");
		self:PlayerMsg("当前距离碧落谷副本关闭还有"..math.floor((PrimerLv20.MAX_TIME - self.nCurSec)/60).."分钟");
	end
end

function tbBase:GameTimeUp()
	self.nGameTimerId = 0;
	self:PlayerMsg("副本时间结束，若未完成任务请重新进入。");
	self:AllBlackBoard("副本时间结束，若未完成任务请重新进入。");
	self.tbMisCfg.tbLeavePos = {};
	table.insert(self.tbMisCfg.tbLeavePos,{PrimerLv20:GetReturnBackMap(2),PrimerLv20.LEAVE_POS_TIMEUP[1],PrimerLv20.LEAVE_POS_TIMEUP[2]});
	self:EndGame();
	return 0;
end

--关闭前清理
function tbBase:OnClose()
	self.tbRoom:ClearRoom();
	ClearMapNpc(self.nMapId);
	self.nIsEnded = 1;	--是否已经关闭过了，防止onleave时重复关闭
end

--离开时
function tbBase:OnLeave()
	me.SetFightState(0);	-- 非战斗状态
	me.DisabledStall(0);	-- 允许摆摊
	me.DisableOffer(0);		-- 允许贩卖
	me.RemoveSkillState(476);
	me.RemoveSkillState(1970);
	self:ClearTask();		
	if not self.nIsEnded or self.nIsEnded ~= 1 and self.nIsStatic ~= 1 then
		self:EndGame();			-- 离开的时候把副本关闭
	end
end

--把任务清空和对应的任务变量清空
function tbBase:ClearTask()
	--如果任务已经完成，则不用将任务置空
	if me.GetTask(1025,32) == 2 then
		Task:DoAccept(PrimerLv20.NEXT_TASK_MAIN_ID,PrimerLv20.NEXT_TASK_SUB_ID);	--离开时候自动接上下一个任务
	elseif me.GetTask(1025,32) == 1 then
		self:WriteFailLog();
		for _,nId in pairs(PrimerLv20.tbTaskSubId) do
			me.SetTask(1025,nId,0);
		end
		Task:CloseTask(tonumber(PrimerLv20.TASK_MAIN_ID,16));
		Task:DoAccept(PrimerLv20.TASK_MAIN_ID,PrimerLv20.TASK_SUB_ID);
	end
	me.GetTempTable("Task").nKillPrimerZergCount = nil;
	me.GetTempTable("Task").tbKillMashRoom = nil;
	me.GetTempTable("Task").nKillXieziCount = nil;
	return 1;
end

function tbBase:WriteFailLog()
	local tbTask = Task:GetPlayerTask(me).tbTasks[tonumber(PrimerLv20.TASK_MAIN_ID,16)]
	if tbTask then
		StatLog:WriteStatLog("stat_info", "qianchenbiluo","step",me.nId,tbTask.nCurStep);
	end
end

function tbBase:OnJoin(nGroupId)
	me.SetLogoutRV(1);			-- 服务器宕机保护
	me.DisabledStall(1);		-- 禁止摆摊
	me.DisableOffer(1);			-- 禁止贩卖
	self:SetPlayerLeftFightSkill(me);

	--设置任务变量，完成任务第一个步骤
	me.SetTask(1025,25,1);
	local pNpc = me.GetNpc();
	if pNpc then
		pNpc.CastSkill(476,1, -1,pNpc.nIndex,1);	--加个30分钟的菜时间
	end
	if self.nIsStatic and self.nIsStatic == 1 then	--静态副本加个状态
		me.AddSkillState(1970,1,0,60 * 60 * 24 * 7 * Env.GAME_FPS,1);
	end
	local tbInfo = PrimerLv20.tbAddBuffInfo;
	local nId = tbInfo[1];
	local nLevel = tbInfo[2];
	local nTime = tbInfo[3];
	me.AddSkillState(nId,nLevel,1,nTime * Env.GAME_FPS,1,1,1);
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
	pPlayer.CallClientScript({"Task.PrimerLv20:SetLeftSkill"});
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

function tbBase:PlayerTalk(szChat)
	if not szChat or #szChat == 0 then
		return 0;
	end
	local tbPlayer,nCount = self:GetPlayerList();
	if nCount > 0 then
		for _,pPlayer in pairs(tbPlayer) do
			if pPlayer then
				local pNpc = pPlayer.GetNpc();
				if pNpc then
					pNpc.SendChat(szChat);
				end
				pPlayer.Msg(szChat,pPlayer.szName);
			end
		end
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

function tbBase:AddXiezi()
	if self.nIsStatic == 1 then
		return 0;
	end
	self.tbRoom:AddXiezi();
end

--function tbBase:OpenBottle()
--	self.tbRoom:OpenBottle();
--end

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