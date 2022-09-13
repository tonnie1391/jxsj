-- 文件名　：missionlevel20_room.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-09-20 10:22:42
-- 描述：20级教育副本logic

Task.PrimerLv20 = Task.PrimerLv20 or {};

local PrimerLv20 = Task.PrimerLv20;

PrimerLv20.tbRoom = {};

local tbRoom = PrimerLv20.tbRoom;

tbRoom.tbStepInfo = 
{
	[1] = {"AddZerg"},	--加毒虫
	[2] = {"AddMashRoom"},	--加蘑菇
	[3] = {"AddBossMan"},	--加守园人
	[4] = {"AddOpenXieziSwitch"},	--加打开毒蝎的柱子
	[5] = {"AddNormalBoss"},		--加三个守护者
	[6] = {"AddBossGirl"},			--加夕岚
	[7] = {"AddFinalBoss_Safe"},	--非战斗夕亭
	[8] = {"AddFinalBoss_Fight"},	--战斗状态夕亭
};

function tbRoom:AddTrapNpc()
	self.tbTrapNpc = {};
	self.tbTrapNpc[1] = {};
	self.tbTrapNpc[2] = {};
	local tbNpcInfo1 = PrimerLv20.tbTrapNpcStep1;
	for _,tbInfo in pairs(tbNpcInfo1) do
		local nTemplateId = tbInfo[1];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,20,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if pNpc then
						table.insert(self.tbTrapNpc[1],pNpc.dwId); 
					end
				end
			end
		end 
	end
	self.tbTrapNpcStep2 = {};
	local tbNpcInfo2 = PrimerLv20.tbTrapNpcStep2;
	for _,tbInfo in pairs(tbNpcInfo2) do
		local nTemplateId = tbInfo[1];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,20,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if pNpc then
						table.insert(self.tbTrapNpc[2],pNpc.dwId); 
					end
				end
			end
		end
	end
end

function tbRoom:DeleteTrapNpc(nStep)
	if not self.tbTrapNpc or not self.tbTrapNpc[nStep] then
		return 0;
	end
	for _,nId in pairs(self.tbTrapNpc[nStep]) do
		local pNpc = KNpc.GetById(nId);
		if pNpc then
			pNpc.Delete();
		end
	end
end

function tbRoom:AddZerg(nAddStep)
	self.nZergCount = 0;
	local nStep = nAddStep or 1;
	local tbNpcInfo = PrimerLv20.tbZergInfo[nStep];
	local nTemplateId = tbNpcInfo[1];
	for _,tbPos in pairs(tbNpcInfo) do
		if nTemplateId then
			if type(tbPos) == "table" then
				local pNpc = KNpc.Add2(nTemplateId,20,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
				if pNpc then
					self.nZergCount = self.nZergCount + 1;
					Npc:RegPNpcOnDeath(pNpc,self.OnZergDeath,self,nStep); 
				end
			end
		end
	end
end

function tbRoom:OnZergDeath(nStep)
	self.nZergCount = self.nZergCount - 1;
	if self.nZergCount <= 0 then
		self.nZergCount = 0;
		if nStep + 1 > 3 then
			--设置任务变量，完成任务26
			self.tbBase:SetTask(1025,26,1);
			self:ProcessStep(2);
		else
			self:AddZerg(nStep + 1);
		end
	end	
end

function tbRoom:AddMashRoom()
	self.nMashRoomCount = 0;
	local tbNpcInfo = PrimerLv20.tbMashRoomInfo;
	for _,tbInfo in pairs(tbNpcInfo) do
		local nTemplateId = tbInfo[1];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,20,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if pNpc then
						self.nMashRoomCount = self.nMashRoomCount + 1;
						Npc:RegPNpcOnDeath(pNpc,self.OnMashRoomDeath,self); 
					end
				end
			end
		end
	end
end

function tbRoom:OnMashRoomDeath(pKiller)
	local pPlayer = pKiller.GetPlayer();
	self.nMashRoomCount = self.nMashRoomCount - 1;
	if self.nMashRoomCount <= 0 then
		self.nMashRoomCount = 0;
		--设置任务变量，完成任务步骤27
		self.tbBase:SetTask(1025,27,1);	
		self:ProcessStep(3);
	end
end

function tbRoom:AddBossMan()
	local tbNpcInfo = PrimerLv20.tbBossManInfo;
	for _,tbInfo in pairs(tbNpcInfo) do
		local nTemplateId = tbInfo[1];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,20,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if pNpc then
						Npc:RegPNpcOnDeath(pNpc,self.OnBossManDeath,self); 
					end
				end
			end
		end
	end
end

function tbRoom:OnBossManDeath()
	--设置任务变量,完成任务步骤28
	self.tbBase:SetTask(1025,28,1);
	self:DeleteTrapNpc(1);	--删除障碍1
	self.tbBase.tbIsTrapOpen[1] = 1;
	self:ProcessStep(4);
end

function tbRoom:AddOpenXieziSwitch()
	local tbNpcInfo = PrimerLv20.tbXieziSWitchInfo;
	for _,tbInfo in pairs(tbNpcInfo) do
		local nTemplateId = tbInfo[1];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,20,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
				end
			end
		end
	end
end

function tbRoom:AddXiezi()
	local tbNpcInfo = PrimerLv20.tbXieziInfo;
	self.nXieziCount = 0;
	for _,tbInfo in pairs(tbNpcInfo) do
		local nTemplateId = tbInfo[1];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,20,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if pNpc then
						Npc:RegPNpcOnDeath(pNpc,self.OnXieziDeath,self); 
						self.nXieziCount = self.nXieziCount + 1;
					end
				end
			end
		end
	end
end

function tbRoom:OnXieziDeath()
	self.nXieziCount = self.nXieziCount - 1;
	if self.nXieziCount <= 0 then
		self.nXieziCount = 0;
		--设置任务变量,完成任务步骤,30
		self.tbBase:SetTask(1025,30,1);
		self:ProcessStep(5);
	end
end

function tbRoom:AddNormalBoss()
	local tbNpcInfo = PrimerLv20.tbShouhuzheStep2_Safe;
	self.tbShouhuzheSafe = {};
	for _,tbInfo in ipairs(tbNpcInfo) do
		local nTemplateId = tbInfo[1];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,20,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if pNpc then
						table.insert(self.tbShouhuzheSafe,pNpc.dwId);
					end
				end
			end
		end
	end
	self:ProcessShouhuzhe(1);
end

function tbRoom:ProcessShouhuzhe(nStep)
	local nId = self.tbShouhuzheSafe[nStep];
	local pNpc = KNpc.GetById(nId);
	if pNpc then
		pNpc.Delete()
	end
	local tbNpcInfo = PrimerLv20.tbShouhuzheStep2_Fight[nStep];
	if tbNpcInfo then
		local nTemplateId = tbNpcInfo[1];
		if nTemplateId then
			for _,tbPos in pairs(tbNpcInfo) do
				if type(tbPos) == "table" then
					local pBoss = KNpc.Add2(nTemplateId,20,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if pBoss then
						if PrimerLv20.tbShouhuzheContent[pBoss.nTemplateId] then
							self.tbBase:AllBlackBoard(PrimerLv20.tbShouhuzheContent[pBoss.nTemplateId]);
						end
						Npc:RegPNpcOnDeath(pBoss,self.OnShouhuzheDeath,self,nStep); 
					end
				end
			end
		end
	end
end

function tbRoom:OnShouhuzheDeath(nStep)
	--设置任务变量,完成任务步骤,31,50,51
	local nTaskSub = PrimerLv20.tbShouhuzheTask[him.nTemplateId];
	if nTaskSub then
		self.tbBase:SetTask(1025,nTaskSub,1);
	end
	local nNextStep = nStep + 1;
	if nNextStep > 3 then
		self:ProcessStep(6);
	else
		self:ProcessShouhuzhe(nNextStep);
	end
end

function tbRoom:AddBossGirl()
	local tbNpcInfo = PrimerLv20.tbBossGirlInfo;
	for _,tbInfo in pairs(tbNpcInfo) do
		local nTemplateId = tbInfo[1];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,20,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if pNpc then
						Npc:RegPNpcOnDeath(pNpc,self.OnBossGirlDeath,self);
--						for _,nPercent in pairs(PrimerLv20.tbAddMashRoomPercent) do
--							Npc:RegPNpcLifePercentReduce(pNpc,nPercent,self.OnBossGirlPercent,self,pNpc.dwId); 
--						end
					end
				end
			end
		end
	end
end

--function tbRoom:OnBossGirlPercent(nId,nPercent)
--	local tbNpcInfo = PrimerLv20.tbMashRoom_Step2Info[nPercent];
--	if not tbNpcInfo then
--		return 0;
--	end
--	self.nMashRoomStep3Count = 0;
--	local nTemplateId = tbNpcInfo[1];
--	for _,tbPos in pairs(tbNpcInfo) do
--		if nTemplateId then
--			if type(tbPos) == "table" then
--				local pNpc = KNpc.Add2(nTemplateId,20,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
--				if pNpc then
--					self.nMashRoomStep3Count = self.nMashRoomStep3Count + 1;
--					Npc:RegPNpcOnDeath(pNpc,self.OnMashRoomStep3Death,self,nId);
--				end
--			end
--		end
--	end
--	local pBoss = KNpc.GetById(nId);
--	if pBoss then
--		pBoss.AddSkillState(999,10,1,120 * Env.GAME_FPS);	--有蘑菇在的时候非战斗
--	end
--	if self.nWarningKillMashRoomTimer and self.nWarningKillMashRoomTimer > 0 then
--		Timer:Close(self.nWarningKillMashRoomTimer);
--		self.nWarningKillMashRoomTimer = 0;
--	end
--	--黑条提示杀掉蘑菇
--	self:WarningKillMashRoom();
--	self.nWarningKillMashRoomTimer = Timer:Register(5 * Env.GAME_FPS,self.WarningKillMashRoom,self);
--end
--
--function tbRoom:WarningKillMashRoom()
--	if self.nMashRoomStep3Count > 0 then
--		self.tbBase:AllBlackBoard("击杀夕岚召唤出的毒蘑，夕岚的金钟罩就会解除");
--		return 5 * Env.GAME_FPS;
--	else
--		self.nWarningKillMashRoomTimer = 0;
--		return 0;
--	end
--end

function tbRoom:OnMashRoomStep3Death(nId)
	self.nMashRoomStep3Count = self.nMashRoomStep3Count - 1;
	if self.nMashRoomStep3Count <= 0 then
		self.nMashRoomStep3Count = 0;
		local pBoss = KNpc.GetById(nId);
		if pBoss then
			pBoss.RemoveSkillState(999);	--取消非战斗状态
		end		
	end
end

function tbRoom:OnBossGirlDeath()
--	if self.nWarningKillMashRoomTimer and self.nWarningKillMashRoomTimer > 0 then
--		Timer:Close(self.nWarningKillMashRoomTimer);
--		self.nWarningKillMashRoomTimer = 0;
--	end
--	ClearMapNpcWithTemplateId(self.tbBase.nMapId,9761);
--	ClearMapNpcWithTemplateId(self.tbBase.nMapId,9762);
	--设置任务变量，完成任务步骤 52
	self.tbBase:SetTask(1025,52,1);
	self:DeleteTrapNpc(2);	--删除障碍2
	self.tbBase.tbIsTrapOpen[2] = 1;	--标记已经可以通过
	local tbNpcInfo = PrimerLv20.tbBossGirlInfo;
	for _,tbInfo in pairs(tbNpcInfo) do
		local nTemplateId = tbInfo[1];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,20,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if pNpc then
						pNpc.SetCurCamp(6);
						local tbAiPos = PrimerLv20.tbBossGirlAiPos;
						pNpc.AI_ClearPath();
						for i = 1,#tbAiPos do
							pNpc.AI_AddMovePos(tbAiPos[i][1],tbAiPos[i][2]);
						end
						pNpc.SetNpcAI(9,0,0,0,0,0,0,0);
						pNpc.SetActiveForever(1);
						pNpc.GetTempTable("Npc").tbOnArrive = {self.OnBossGirlArrive,self,pNpc.dwId};
					end
				end
			end
		end
	end	
end

function tbRoom:OnBossGirlArrive(nId)
	local pNpc = KNpc.GetById(nId);
	if pNpc then
		self.tbBase:AllBlackBoard("夕岚跑着跑着突然消失了...");
		pNpc.Delete();
	end
	self:ProcessStep(7);
end

function tbRoom:AddFinalBoss_Safe()
	local tbNpcInfo = PrimerLv20.tbFinalBoss_Safe;
	for _,tbInfo in pairs(tbNpcInfo) do
		local nTemplateId = tbInfo[1];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,20,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
				end
			end
		end
	end
end

function tbRoom:AddFinalBoss_Fight()
	local tbNpcInfo = PrimerLv20.tbFinalBoss_Fight;
	for _,tbInfo in pairs(tbNpcInfo) do
		local nTemplateId = tbInfo[1];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,20,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if pNpc then
						for _,nPercent in pairs(PrimerLv20.tbFinalBossPercent) do
							Npc:RegPNpcLifePercentReduce(pNpc,nPercent,self.OnFinalBossPercent,self,pNpc.dwId);
						end
						pNpc.SetCurCamp(6);	--先进行阵营转换，冒泡泡
						self.pBossStep3 = pNpc;
					end
				end
			end
		end
	end
	if self.nTalkTimer and self.nTalkTimer > 0 then
		Timer:Close(self.nTalkTimer);
		self.nTalkTimer = 0;
	end
	self.nTalkTimer = Timer:Register(3 * Env.GAME_FPS,self.TalkEnd,self);
	self.nTalkState = 1;
end


function tbRoom:TalkEnd()
	if self.pBossStep3  then
		if self.nTalkState == 1 then
			self.tbBase:NpcTalk(self.pBossStep3.dwId,"都给我停手！哪里来的泼猴儿，敢在这里撒野。");
			self.nTalkState = self.nTalkState + 1;
			return 3 * Env.GAME_FPS;
		elseif self.nTalkState == 2 then
			self.tbBase:NpcTalk(self.pBossStep3.dwId,"你擅闯我碧落谷，是何居心……");
			self.nTalkState = self.nTalkState + 1;
			return 3 * Env.GAME_FPS;
		elseif self.nTalkState == 3 then
			self.tbBase:NpcTalk(self.pBossStep3.dwId,"等等！原来是你……十八年前你还是个婴儿呢。");
			self.nTalkState = self.nTalkState + 1;
			return 3 * Env.GAME_FPS;
		elseif self.nTalkState == 4 then
			self.tbBase:PlayerTalk("前辈当时果真在场？恳请告知我父母当年血战金兵之事！");
			self.nTalkState = self.nTalkState + 1;
			return 3 * Env.GAME_FPS;
		elseif self.nTalkState == 5 then
			self.tbBase:NpcTalk(self.pBossStep3.dwId,"……我不知道，你请回吧。夕岚，送客。");
			self.pBossStep3.SetCurCamp(5);	--变为战斗状态
			self.nTalkTimer = 0;
			return 0;
		end
	else
		self.nTalkTimer = 0;
		return 0;
	end
end

function tbRoom:OnFinalBossPercent(nId,nPercent)
	local pNpc = KNpc.GetById(nId);
	if not pNpc then
		return 0;
	end
	if nPercent == 95 then
		if not self.tbHelperNpc then
			self.tbHelperNpc = {};
		end
		local tbNpcInfo = PrimerLv20.tbHelperInfo;
		for _,tbInfo in pairs(tbNpcInfo) do
			local nTemplateId = tbInfo[1];
			if nTemplateId then
				for _,tbPos in pairs(tbInfo) do
					if type(tbPos) == "table" then
						local pNpc = KNpc.Add2(nTemplateId,20,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
						pNpc.SetCurCamp(0);
						table.insert(self.tbHelperNpc,pNpc.dwId);
					end
				end
			end
		end
		if self.nHelperTalkTimer and self.nHelperTalkTimer > 0 then
			Timer:Close(self.nHelperTalkTimer);
			self.nHelperTalkTimer = 0;
		end
		self.nHelperTalkTimer = Timer:Register(5 * Env.GAME_FPS,self.OnHelperTalk,self);
	elseif nPercent == 70 then
		self.nBottleCount = 0;
--		local tbNpcInfo = PrimerLv20.tbBottleInfo;
--		for _,tbInfo in pairs(tbNpcInfo) do
--			local nTemplateId = tbInfo[1];
--			if nTemplateId then
--				for _,tbPos in pairs(tbInfo) do
--					if type(tbPos) == "table" then
--						local pNpc = KNpc.Add2(nTemplateId,20,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
--						self.nBottleCount = self.nBottleCount + 1;
--					end
--				end
--			end
--		end
--		if self.pBossStep3 then
--			self.pBossStep3.AddSkillState(999,10,1,120 * Env.GAME_FPS);	--有蘑菇在的时候非战斗--加一个金钟罩
--		end
--		if self.nWarningOpenBottleTimer and self.nWarningOpenBottleTimer > 0 then
--			Timer:Close(self.nWarningOpenBottleTimer);
--			self.nWarningOpenBottleTimer = 0;
--		end
--		--黑条提示开启药罐
--		self:WarningOpenBottle();
--		self.nWarningOpenBottleTimer = Timer:Register(5 * Env.GAME_FPS,self.WarningOpenBottle,self);
	elseif nPercent == 50 then
		self:DelayEnd();
	end
end

--function tbRoom:WarningOpenBottle()
--	if self.nBottleCount > 0 then
--		self.tbBase:AllBlackBoard("开启所有毒瓶，夕亭的金钟罩就会解除");
--		return 5 * Env.GAME_FPS;
--	else
--		self.nWarningOpenBottleTimer = 0;
--		return 0;
--	end
--end

--甜酒叔等人的循环泡泡
function tbRoom:OnHelperTalk()
	if not self.nHelperTalkState then
		self.nHelperTalkState = 1;
	end
	for _,nId in pairs(self.tbHelperNpc) do
		local pNpc = KNpc.GetById(nId);
		if pNpc and PrimerLv20.tbHelperTalkContent[pNpc.nTemplateId] and 
			PrimerLv20.tbHelperTalkContent[pNpc.nTemplateId][self.nHelperTalkState] then 
			self.tbBase:NpcTalk(nId,PrimerLv20.tbHelperTalkContent[pNpc.nTemplateId][self.nHelperTalkState]);
		end
	end
	self.nHelperTalkState = self.nHelperTalkState + 1;
	if self.nHelperTalkState > 3 then
		self.nHelperTalkState = 1;
	end
	return 5 * Env.GAME_FPS;
end

--function tbRoom:OpenBottle()
--	self.nBottleCount = self.nBottleCount - 1;
--	if self.nBottleCount <= 0 then
--		self.nBottleCount = 0;
--		if self.pBossStep3 then
--			self.pBossStep3.RemoveSkillState(999); --去除金钟罩
--		end
--	end
--end

function tbRoom:DelayEnd()
--	if self.nWarningOpenBottleTimer and self.nWarningOpenBottleTimer > 0 then
--		Timer:Close(self.nWarningOpenBottleTimer);
--		self.nWarningOpenBottleTimer = 0;
--	end
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,9763);
	local pNpc = KNpc.GetById(self.pBossStep3.dwId);
	if pNpc then
		pNpc.Delete();
	end
	for _,nId in pairs(self.tbHelperNpc) do
		local pNpc = KNpc.GetById(nId);
		if pNpc then
			pNpc.Delete();
		end
	end
	if self.nHelperTalkTimer and self.nHelperTalkTimer > 0 then
		Timer:Close(self.nHelperTalkTimer);
		self.nHelperTalkTimer = 0;
	end
	local tbNpcInfo = PrimerLv20.tbFinalBoss_Fight;
	for _,tbInfo in pairs(tbNpcInfo) do
		local nTemplateId = tbInfo[1];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,20,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if pNpc then
						pNpc.SetCurCamp(6);	--先进行阵营转换，冒泡泡
						self.pBossStep3 = pNpc;
					end
				end
			end
		end
	end
	local tbNpcInfo2 = PrimerLv20.tbPasserbyStep3;
	for nIndex,tbInfo in pairs(tbNpcInfo2) do
		local nTemplateId = tbInfo[1];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,20,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if nIndex == 1 then
						self.pBaiqiulin = pNpc;
					end
				end
			end
		end
	end
	if self.nTalkTimer and self.nTalkTimer > 0 then
		Timer:Close(self.nTalkTimer);
		self.nTalkTimer = 0;
	end
	self.nTalkTimer = Timer:Register(3 * Env.GAME_FPS,self.TalkEndStep2,self);
	self.nTalkState = 1;
	return 0;
end

function tbRoom:TalkEndStep2()
	if self.nTalkState == 1 then
		self.tbBase:NpcTalk(self.pBaiqiulin.dwId,"夕亭，我家少主人有劳管教。");
		self.nTalkState = self.nTalkState + 1;
		return 3 * Env.GAME_FPS;
	elseif self.nTalkState == 2 then
		self.tbBase:NpcTalk(self.pBossStep3.dwId,"哼。小辈，我亦不知你父母的下落。");
		self.nTalkState = self.nTalkState + 1;
		return 3 * Env.GAME_FPS;
	elseif self.nTalkState == 3 then
		self.tbBase:NpcTalk(self.pBossStep3.dwId,"当日遇敌，他们替我引开金兵，相救于我");
		self.nTalkState = self.nTalkState + 1;
		return 3 * Env.GAME_FPS;
	elseif self.nTalkState == 4 then
		self.tbBase:NpcTalk(self.pBossStep3.dwId,"救我的是宋人，绝杀我族人的亦是宋人");
		self.nTalkState = self.nTalkState + 1;
		return 3 * Env.GAME_FPS;
	elseif self.nTalkState == 5 then
		self.tbBase:NpcTalk(self.pBossStep3.dwId,"你们的天下又与我有何干系！");
		self.nTalkState = self.nTalkState + 1;
		return 3 * Env.GAME_FPS;
	elseif self.nTalkState == 6 then
		self.tbBase:NpcTalk(self.pBossStep3.dwId,"请速去吧，休再要扰此地清净");
		self.nTalkState = self.nTalkState + 1;
		return 3 * Env.GAME_FPS;
	elseif self.nTalkState == 7 then
		self.tbBase:NpcTalk(self.pBaiqiulin.dwId,"如此谢过。 少主人，还不快随我回去！");
		self.nTalkState = self.nTalkState + 1;
		return 3 * Env.GAME_FPS;
	elseif self.nTalkState == 8 then
		if KNpc.GetById(self.pBossStep3.dwId) then
			self.pBossStep3.Delete();
		end
		--设置任务变量，完成任务步骤,53
		self.tbBase:SetTask(1025,53,1);
		self.nTalkTimer = 0;
		
		local tbPlayer,nCount = self.tbBase:GetPlayerList();
		if nCount > 0 then
			for _,pPlayer in pairs(tbPlayer) do
				if pPlayer then
					SpecialEvent.ActiveGift:AddCounts(pPlayer, 13);		--通关20级副本活跃度
				end
			end
		end	
		
		return 0;
	end
end

function tbRoom:ProcessStep(nStep)
	local tbStep = self.tbStepInfo[nStep];
	if not tbStep then
		return 0;
	end
	local szFun = tbStep[1];
	local pFun = self[szFun];
	if pFun then
		pFun(self);
	end
end

function tbRoom:ClearRoom()
	self.tbTrapNpc = nil;
	self.tbShouhuzheSafe = nil;
	self.pBossStep3 = nil;
	self.pBaiqiulin = nil;
	self.tbHelperNpc = nil;
	if self.nTalkTimer and self.nTalkTimer > 0 then
		Timer:Close(self.nTalkTimer);
		self.nTalkTimer = 0;
	end
	if self.nHelperTalkTimer and self.nHelperTalkTimer > 0 then
		Timer:Close(self.nHelperTalkTimer);
		self.nHelperTalkTimer = 0;
	end
--	if self.nWarningOpenBottleTimer and self.nWarningOpenBottleTimer > 0 then
--		Timer:Close(self.nWarningOpenBottleTimer);
--		self.nWarningOpenBottleTimer = 0;
--	end
--	if self.nWarningKillMashRoomTimer and self.nWarningKillMashRoomTimer > 0 then
--		Timer:Close(self.nWarningKillMashRoomTimer);
--		self.nWarningKillMashRoomTimer = 0;
--	end
end
