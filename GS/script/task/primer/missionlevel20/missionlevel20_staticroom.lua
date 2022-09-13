-- 文件名　：missionlevel20_staticroom.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-10-24 10:52:19
-- 描述：20级新手副本静态地图

Task.PrimerLv20 = Task.PrimerLv20 or {};

local PrimerLv20 = Task.PrimerLv20;

PrimerLv20.tbStaticRoom = {};

local tbRoom = PrimerLv20.tbStaticRoom;

tbRoom.tbStepInfo = 
{
	[1] = {"AddAllNpc"},	--加毒虫
};


tbRoom.nKillXieziMaxCount   = 5;	
tbRoom.nKillZergMaxCount 	= 9;


function tbRoom:AddAllNpc()
	self:AddZerg();
	self:AddMashRoom();
	self:AddBossMan();
	self:AddOpenXieziSwitch();
	self:AddXiezi();
	self:AddNormalBoss();
	self:AddBossGirl();
	self:AddFinalBoss_Fight();
	self:AddHelperNpc();
	if self.nAddStaticTimer and self.nAddStaticTimer > 0 then
		Timer:Close(self.nAddStaticTimer);
		self.nAddStaticTimer = 0;
	end	
	self.nAddStaticTimer = Timer:Register(PrimerLv20.REFRESH_NPC_DELAY * Env.GAME_FPS,self.OnScanAddStaticNpc,self);
	return 0;
end


function tbRoom:OnScanAddStaticNpc()
	if self.tbZergNpc then
		for nIndex,tbNpcInfo in pairs(self.tbZergNpc) do
			local nId = tbNpcInfo[1];
			local nTemplateId = tbNpcInfo[2];
			local nX,nY = tbNpcInfo[3],tbNpcInfo[4];
			local pNpc = KNpc.GetById(nId);
			if not pNpc then
				pNpc = KNpc.Add2(nTemplateId,10,-1,self.tbBase.nMapId,nX,nY);
				self.tbZergNpc[nIndex] = {pNpc.dwId,nTemplateId,nX,nY};
				Npc:RegPNpcOnDeath(pNpc,self.OnZergDeath,self);
			end
		end
	end
	if self.tbMashRoomNpc then
		for nIndex,tbNpcInfo in pairs(self.tbMashRoomNpc) do
			local nId = tbNpcInfo[1];
			local nTemplateId = tbNpcInfo[2];
			local nX,nY = tbNpcInfo[3],tbNpcInfo[4];
			local pNpc = KNpc.GetById(nId);
			if not pNpc then
				pNpc = KNpc.Add2(nTemplateId,10,-1,self.tbBase.nMapId,nX,nY);
				self.tbMashRoomNpc[nIndex] = {pNpc.dwId,nTemplateId,nX,nY};
				Npc:RegPNpcOnDeath(pNpc,self.OnMashRoomDeath,self);
			end
		end
	end
	if self.tbBossManNpc then
		for nIndex,tbNpcInfo in pairs(self.tbBossManNpc) do
			local nId = tbNpcInfo[1];
			local nTemplateId = tbNpcInfo[2];
			local nX,nY = tbNpcInfo[3],tbNpcInfo[4];
			local pNpc = KNpc.GetById(nId);
			if not pNpc then
				pNpc = KNpc.Add2(nTemplateId,10,-1,self.tbBase.nMapId,nX,nY);
				self.tbBossManNpc[nIndex] = {pNpc.dwId,nTemplateId,nX,nY};
				Npc:RegPNpcOnDeath(pNpc,self.OnBossManDeath,self); 
			end
		end
	end
	if self.tbXieziSwitchNpc then
		for nIndex,tbNpcInfo in pairs(self.tbXieziSwitchNpc) do
			local nId = tbNpcInfo[1];
			local nTemplateId = tbNpcInfo[2];
			local nX,nY = tbNpcInfo[3],tbNpcInfo[4];
			local pNpc = KNpc.GetById(nId);
			if not pNpc then
				pNpc = KNpc.Add2(nTemplateId,10,-1,self.tbBase.nMapId,nX,nY);
				self.tbXieziSwitchNpc[nIndex] = {pNpc.dwId,nTemplateId,nX,nY};
			end
		end
	end
	if self.tbXieziNpc then
		for nIndex,tbNpcInfo in pairs(self.tbXieziNpc) do
			local nId = tbNpcInfo[1];
			local nTemplateId = tbNpcInfo[2];
			local nX,nY = tbNpcInfo[3],tbNpcInfo[4];
			local pNpc = KNpc.GetById(nId);
			if not pNpc then
				pNpc = KNpc.Add2(nTemplateId,10,-1,self.tbBase.nMapId,nX,nY);
				self.tbXieziNpc[nIndex] = {pNpc.dwId,nTemplateId,nX,nY};
				Npc:RegPNpcOnDeath(pNpc,self.OnXieziDeath,self);
			end
		end
	end
	if self.tbShouhuzheNpc then
		for nIndex,tbNpcInfo in pairs(self.tbShouhuzheNpc) do
			local nId = tbNpcInfo[1];
			local nTemplateId = tbNpcInfo[2];
			local nX,nY = tbNpcInfo[3],tbNpcInfo[4];
			local pNpc = KNpc.GetById(nId);
			if not pNpc then
				pNpc = KNpc.Add2(nTemplateId,10,-1,self.tbBase.nMapId,nX,nY);
				self.tbShouhuzheNpc[nIndex] = {pNpc.dwId,nTemplateId,nX,nY};
				Npc:RegPNpcOnDeath(pNpc,self.OnShouhuzheDeath,self);
			end
		end
	end
	if self.tbBossGirlNpc then
		for nIndex,tbNpcInfo in pairs(self.tbBossGirlNpc) do
			local nId = tbNpcInfo[1];
			local nTemplateId = tbNpcInfo[2];
			local nX,nY = tbNpcInfo[3],tbNpcInfo[4];
			local pNpc = KNpc.GetById(nId);
			if not pNpc then
				pNpc = KNpc.Add2(nTemplateId,10,-1,self.tbBase.nMapId,nX,nY);
				self.tbBossGirlNpc[nIndex] = {pNpc.dwId,nTemplateId,nX,nY};
				Npc:RegPNpcOnDeath(pNpc,self.OnBossGirlDeath,self);
			end
		end
	end
	if self.tbFinalBossNpc then
		for nIndex,tbNpcInfo in pairs(self.tbFinalBossNpc) do
			local nId = tbNpcInfo[1];
			local nTemplateId = tbNpcInfo[2];
			local nX,nY = tbNpcInfo[3],tbNpcInfo[4];
			local pNpc = KNpc.GetById(nId);
			if not pNpc then
				pNpc = KNpc.Add2(nTemplateId,10,-1,self.tbBase.nMapId,nX,nY);
				self.tbFinalBossNpc[nIndex] = {pNpc.dwId,nTemplateId,nX,nY};
				Npc:RegPNpcOnDeath(pNpc,self.OnFinalBossDeath,self);
			end
		end
	end
	if self.tbHelperNpc then
		for nIndex,tbNpcInfo in pairs(self.tbHelperNpc) do
			local nId = tbNpcInfo[1];
			local nTemplateId = tbNpcInfo[2];
			local nX,nY = tbNpcInfo[3],tbNpcInfo[4];
			local pNpc = KNpc.GetById(nId);
			if not pNpc then
				pNpc = KNpc.Add2(nTemplateId,10,-1,self.tbBase.nMapId,nX,nY);
				self.tbHelperNpc[nIndex] = {pNpc.dwId,nTemplateId,nX,nY};
			end
		end
	end
end


function tbRoom:AddZerg()
	if not self.tbZergNpc then
		self.tbZergNpc = {};
	end
	local tbNpcInfo = PrimerLv20.tbZergInfo;
	for _,tbInfo in pairs(tbNpcInfo) do
		local nTemplateId = tbInfo[1];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,20,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if pNpc then
						table.insert(self.tbZergNpc,{pNpc.dwId,nTemplateId,tbPos[1],tbPos[2]});
						Npc:RegPNpcOnDeath(pNpc,self.OnZergDeath,self); 
					end
				end
			end
		end
	end
end

function tbRoom:OnZergDeath(pKiller)
	local pPlayer = pKiller.GetPlayer();
	if not pPlayer then
		return 0;
	end
	local funFinish = function(pMember)
		if pMember.GetTask(1025,26) == 1 then
			return 0;
		end
		pMember.GetTempTable("Task").nKillPrimerZergCount = (pMember.GetTempTable("Task").nKillPrimerZergCount or 0) + 1;
		if pMember.GetTempTable("Task").nKillPrimerZergCount >= self.nKillZergMaxCount then
			pMember.SetTask(1025,26,1);
		end
	end
	self.tbBase:TeamExcete(pPlayer,funFinish);
end

function tbRoom:AddMashRoom()
	if not self.tbMashRoomNpc then
		self.tbMashRoomNpc = {};
	end
	local tbNpcInfo = PrimerLv20.tbMashRoomInfo;
	for _,tbInfo in pairs(tbNpcInfo) do
		local nTemplateId = tbInfo[1];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,20,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if pNpc then
						table.insert(self.tbMashRoomNpc,{pNpc.dwId,nTemplateId,tbPos[1],tbPos[2]});
						Npc:RegPNpcOnDeath(pNpc,self.OnMashRoomDeath,self); 
					end
				end
			end
		end
	end
end

function tbRoom:OnMashRoomDeath(pKiller)
	local pPlayer = pKiller.GetPlayer();
	if not pPlayer then
		return 0;
	end
	local funFinish = function(pMember)
		if pMember.GetTask(1025,26) ~= 1 then	--没杀毒虫
			return 0;
		end
		if pMember.GetTask(1025,27) == 1 then	--杀过蘑菇
			return 0;
		end
		if not pMember.GetTempTable("Task").tbKillMashRoom then
			pMember.GetTempTable("Task").tbKillMashRoom = {};
		end
		pMember.GetTempTable("Task").tbKillMashRoom[him.nTemplateId] = 1;
		local tbNpcInfo = PrimerLv20.tbMashRoomInfo;
		local nIsAllKill = 1;
		for _,tbInfo in pairs(tbNpcInfo) do
			local nTemplateId = tbInfo[1];
			if nTemplateId then
				if not pMember.GetTempTable("Task").tbKillMashRoom[nTemplateId] or
					pMember.GetTempTable("Task").tbKillMashRoom[nTemplateId] ~= 1 then
					nIsAllKill = 0;
				end
			end
		end
		if nIsAllKill == 1 then		
			pMember.SetTask(1025,27,1);	
		end
	end
	self.tbBase:TeamExcete(pPlayer,funFinish);
end


function tbRoom:AddBossMan()
	if not self.tbBossManNpc then
		self.tbBossManNpc = {};
	end
	local tbNpcInfo = PrimerLv20.tbBossManInfo;
	for _,tbInfo in pairs(tbNpcInfo) do
		local nTemplateId = tbInfo[1];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,20,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if pNpc then
						table.insert(self.tbBossManNpc,{pNpc.dwId,nTemplateId,tbPos[1],tbPos[2]});
						Npc:RegPNpcOnDeath(pNpc,self.OnBossManDeath,self); 
					end
				end
			end
		end
	end
end

function tbRoom:OnBossManDeath(pKiller)
	local pPlayer = pKiller.GetPlayer();
	if not pPlayer then
		return 0;
	end
	local funFinish = function(pMember)
		if pMember.GetTask(1025,27) ~= 1 then	--没杀蘑菇
			return 0;
		end
		if pMember.GetTask(1025,28) == 1 then	--杀过毒一风
			return 0;
		end
		pMember.SetTask(1025,28,1);
	end
	self.tbBase:TeamExcete(pPlayer,funFinish);
end


function tbRoom:AddOpenXieziSwitch()
	if not self.tbXieziSwitchNpc then
		self.tbXieziSwitchNpc = {};
	end
	local tbNpcInfo = PrimerLv20.tbXieziSWitchInfo;
	for _,tbInfo in pairs(tbNpcInfo) do
		local nTemplateId = tbInfo[1];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,20,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if pNpc then
						table.insert(self.tbXieziSwitchNpc,{pNpc.dwId,nTemplateId,tbPos[1],tbPos[2]});
					end
				end
			end
		end
	end
end


function tbRoom:AddXiezi()
	if not self.tbXieziNpc then
		self.tbXieziNpc = {};
	end
	local tbNpcInfo = PrimerLv20.tbXieziInfo;
	for _,tbInfo in pairs(tbNpcInfo) do
		local nTemplateId = tbInfo[1];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,20,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if pNpc then
						table.insert(self.tbXieziNpc,{pNpc.dwId,nTemplateId,tbPos[1],tbPos[2]});
						Npc:RegPNpcOnDeath(pNpc,self.OnXieziDeath,self); 
					end
				end
			end
		end
	end
end

function tbRoom:OnXieziDeath(pKiller)
	local pPlayer = pKiller.GetPlayer();
	if not pPlayer then
		return 0;
	end
	local funFinish = function(pMember)
		if pMember.GetTask(1025,29) ~= 1 then	--没开柱子
			return 0;
		end
		if pMember.GetTask(1025,30) == 1 then	--杀过蝎子
			return 0;
		end
		pMember.GetTempTable("Task").nKillXieziCount = (pMember.GetTempTable("Task").nKillXieziCount or 0) + 1;
		if pMember.GetTempTable("Task").nKillXieziCount >= self.nKillXieziMaxCount then
			pMember.SetTask(1025,30,1);
		end
	end
	self.tbBase:TeamExcete(pPlayer,funFinish);
end

function tbRoom:AddNormalBoss()
	if not self.tbShouhuzheNpc then
		self.tbShouhuzheNpc = {};
	end
	local tbNpcInfo = PrimerLv20.tbShouhuzheStep2_Fight;
	for _,tbInfo in ipairs(tbNpcInfo) do
		local nTemplateId = tbInfo[1];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,20,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if pNpc then
						table.insert(self.tbShouhuzheNpc,{pNpc.dwId,nTemplateId,tbPos[1],tbPos[2]});
						Npc:RegPNpcOnDeath(pNpc,self.OnShouhuzheDeath,self); 
					end
				end
			end
		end
	end
end


function tbRoom:OnShouhuzheDeath(pKiller)
	--设置任务变量,完成任务步骤,31,50,51
	local pPlayer = pKiller.GetPlayer();
	if not pPlayer then
		return 0;
	end
	local funFinish = function(pMember)
		if pMember.GetTask(1025,30) ~= 1 then	--没杀蝎子
			return 0;
		end
		local nTaskSub = PrimerLv20.tbShouhuzheTask[him.nTemplateId];
		if nTaskSub then
			if pMember.GetTask(1025,nTaskSub) ~= 1 then
				pMember.SetTask(1025,nTaskSub,1);
			end
		end
	end
	self.tbBase:TeamExcete(pPlayer,funFinish);
end

function tbRoom:AddBossGirl()
	if not self.tbBossGirlNpc then
		self.tbBossGirlNpc = {};
	end
	local tbNpcInfo = PrimerLv20.tbBossGirlInfo;
	for _,tbInfo in pairs(tbNpcInfo) do
		local nTemplateId = tbInfo[1];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,20,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if pNpc then
						table.insert(self.tbBossGirlNpc,{pNpc.dwId,nTemplateId,tbPos[1],tbPos[2]});
						Npc:RegPNpcOnDeath(pNpc,self.OnBossGirlDeath,self);
					end
				end
			end
		end
	end
end

function tbRoom:OnBossGirlDeath(pKiller)
	local pPlayer = pKiller.GetPlayer();
	if not pPlayer then
		return 0;
	end
	local funFinish = function(pMember)
		local nLastFinish = 1;
		for _,nSubId in pairs(PrimerLv20.tbShouhuzheTask) do
			if pMember.GetTask(1025,nSubId) ~= 1 then
				nLastFinish = 0;
			end
		end
		if nLastFinish ~= 1 then	--没杀守护者
			return 0;
		end
		if pMember.GetTask(1025,52) == 1 then	--杀过夕岚
			return 0;
		end
		--设置任务变量，完成任务步骤 52
		pMember.SetTask(1025,52,1);
	end
	self.tbBase:TeamExcete(pPlayer,funFinish);
	local tbNpcInfo = PrimerLv20.tbBossGirlInfo;
	for _,tbInfo in pairs(tbNpcInfo) do
		local nTemplateId = tbInfo[1];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,20,-1,self.tbBase.nMapId,tbPos[1] + 2,tbPos[2] + 2);	
					if pNpc then
						pNpc.SetCurCamp(6);
						local tbAiPos = PrimerLv20.tbBossGirlAiPos;
						pNpc.AI_ClearPath();
						for i = 1,#tbAiPos do
							pNpc.AI_AddMovePos(tbAiPos[i][1],tbAiPos[i][2]);
						end
						pNpc.SetNpcAI(9,0,0,0,0,0,0,0);
						pNpc.SetActiveForever(1);
						pNpc.GetTempTable("Npc").tbOnArrive = {self.OnBossGirlArrive,self,pNpc.dwId,pPlayer.nId};
					end
				end
			end
		end
	end	
end

function tbRoom:OnBossGirlArrive(nNpcId,nPlayerId)
	local pNpc = KNpc.GetById(nNpcId);
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pNpc then
		if pPlayer then
			local funFinish = function(pMember)
				self.tbBase:BlackBoard(pMember,"夕岚跑着跑着突然消失了...");
			end
			self.tbBase:TeamExcete(pPlayer,funFinish);
		end
		pNpc.Delete();
	end
end

function tbRoom:AddFinalBoss_Fight()
	if not self.tbFinalBossNpc then
		self.tbFinalBossNpc = {};
	end
	local tbNpcInfo = PrimerLv20.tbFinalBoss_Fight;
	for _,tbInfo in pairs(tbNpcInfo) do
		local nTemplateId = tbInfo[1];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,20,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if pNpc then
						table.insert(self.tbFinalBossNpc,{pNpc.dwId,nTemplateId,tbPos[1],tbPos[2]});
						Npc:RegPNpcOnDeath(pNpc,self.OnFinalBossDeath,self);
					end
				end
			end
		end
	end
end

function tbRoom:AddHelperNpc()
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
					table.insert(self.tbHelperNpc,{pNpc.dwId,nTemplateId,tbPos[1],tbPos[2]});
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
					if pNpc then
						table.insert(self.tbHelperNpc,{pNpc.dwId,nTemplateId,tbPos[1],tbPos[2]});
					end
				end
			end
		end
	end
end

function tbRoom:OnFinalBossDeath(pKiller)
	local pPlayer = pKiller.GetPlayer();
	if not pPlayer then
		return 0;
	end
	local funFinish = function(pMember)
		if pMember.GetTask(1025,52) ~= 1 then	--没杀夕岚
			return 0;
		end
		if pMember.GetTask(1025,53) == 1 then
			return 0;
		end
		pMember.SetTask(1025,53,1);
		SpecialEvent.ActiveGift:AddCounts(pMember,13);		--通关20级副本活跃度
	end
	self.tbBase:TeamExcete(pPlayer,funFinish);
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

