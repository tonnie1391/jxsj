-- 文件名　：missionlevel10_staticroom.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-10-17 17:30:29
-- 描述：静态的room


Task.PrimerLv10 = Task.PrimerLv10 or {};

local PrimerLv10 = Task.PrimerLv10;

PrimerLv10.tbStaticRoom = {};

local tbRoom = PrimerLv10.tbStaticRoom;

tbRoom.nKillBlueEnemyMaxCount = 8;
tbRoom.nKillNormalBossMaxCount = 5;

tbRoom.tbStepInfo = 	--对应task步骤对应的触发函数
{
	[1] = {"AddStaticNpc"},
	[2] = {"AddBlueEnemy"},	--刷精英怪
	[3] = {"AddXizuo"},		--刷细作
	[4] = {"AddNormalBoss"},--刷五行boss
	[5] = {"AddFinalBoss"},	--刷大boss
};

--执行某个阶段
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

function tbRoom:AddStaticNpc()
	local tbPassby = PrimerLv10.tbPasserby;
	if not tbPassby then
		return 0;
	end
	for nTemplateId,tbInfo in pairs(tbPassby) do
		for _,tbPos in pairs(tbInfo) do
			local pNpc = KNpc.Add2(nTemplateId,10,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
			if not pNpc then
				print("PrimerLv10 Add Passerby Error!",nTemplateId);
			else
				if not self.tbPasserbyNpc then
					self.tbPasserbyNpc = {};
				end
				table.insert(self.tbPasserbyNpc,{pNpc.dwId,nTemplateId,tbPos[1],tbPos[2]});
			end
		end
	end
	self:ProcessStep(2);
	self:ProcessStep(3);
	self:ProcessStep(4);
	self:ProcessStep(5);
	if self.nAddStaticTimer and self.nAddStaticTimer > 0 then
		Timer:Close(self.nAddStaticTimer);
		self.nAddStaticTimer = 0;
	end	
	self.nAddStaticTimer = Timer:Register(PrimerLv10.REFRESH_NPC_DELAY * Env.GAME_FPS,self.OnScanAddStaticNpc,self);
	return 0;
end

function tbRoom:OnScanAddStaticNpc()
	if self.tbPasserbyNpc then
		for nIndex,tbNpcInfo in pairs(self.tbPasserbyNpc) do
			local nId = tbNpcInfo[1];
			local nTemplateId = tbNpcInfo[2];
			local nX,nY = tbNpcInfo[3],tbNpcInfo[4];
			local pNpc = KNpc.GetById(nId);
			if not pNpc then
				pNpc = KNpc.Add2(nTemplateId,10,-1,self.tbBase.nMapId,nX,nY);
				self.tbPasserbyNpc[nIndex] = {pNpc.dwId,nTemplateId,nX,nY};
			end
		end
	end
	if self.tbBlueEnemy then
		for nIndex,tbNpcInfo in pairs(self.tbBlueEnemy) do
			local nId = tbNpcInfo[1];
			local nTemplateId = tbNpcInfo[2];
			local nX,nY = tbNpcInfo[3],tbNpcInfo[4];
			local nBlue = tbNpcInfo[5];
			local pNpc = KNpc.GetById(nId);
			if not pNpc then
				if nBlue == 1 then	
					pNpc = KNpc.Add2(nTemplateId,20,-1,self.tbBase.nMapId,nX,nY,0,2);
					pNpc.ChangeType(30);
				else
					pNpc = KNpc.Add2(nTemplateId,10,-1,self.tbBase.nMapId,nX,nY);
				end
				Npc:RegPNpcOnDeath(pNpc,self.OnBlueEnemyDeath,self,nBlue); 
				self.tbBlueEnemy[nIndex] = {pNpc.dwId,nTemplateId,nX,nY,nBlue};
			end
		end
	end
	if self.tbXizuo then
		for nIndex,tbNpcInfo in pairs(self.tbXizuo) do
			local nId = tbNpcInfo[1];
			local nTemplateId = tbNpcInfo[2];
			local nX,nY = tbNpcInfo[3],tbNpcInfo[4];
			local pNpc = KNpc.GetById(nId);
			if not pNpc then
				pNpc = KNpc.Add2(nTemplateId,10,-1,self.tbBase.nMapId,nX,nY);
				Npc:RegPNpcOnDeath(pNpc,self.OnXizuoDeath,self);	
				self.tbXizuo[nIndex] = {pNpc.dwId,nTemplateId,nX,nY};
			end
		end
	end
	if self.tbSeriesBoss then
		for nIndex,tbNpcInfo in pairs(self.tbSeriesBoss) do
			local nId = tbNpcInfo[1];
			local nTemplateId = tbNpcInfo[2];
			local nX,nY = tbNpcInfo[3],tbNpcInfo[4];
			local nSeries = tbNpcInfo[5];
			local pNpc = KNpc.GetById(nId);
			if not pNpc then
				pNpc = KNpc.Add2(nTemplateId,10,nSeries,self.tbBase.nMapId,nX,nY,0,0,0,0,nSeries - 1);
				pNpc.GetTempTable("Task").nSeries = nSeries;
				pNpc.szName = PrimerLv10.tbSeriesName[nSeries];
				pNpc.Sync();
				self.tbSeriesBoss[nIndex] = {pNpc.dwId,nTemplateId,nX,nY,nSeries};
			end
		end
	end
	if self.tbFinalBossNpc then
		for nIndex,tbNpcInfo in pairs(self.tbFinalBossNpc) do
			local nId = tbNpcInfo[1];
			local nTemplateId = tbNpcInfo[2];
			local nX,nY = tbNpcInfo[3],tbNpcInfo[4];
			local nIsBoss = tbNpcInfo[5];
			local pNpc = KNpc.GetById(nId);
			if not pNpc then
				pNpc = KNpc.Add2(nTemplateId,10,-1,self.tbBase.nMapId,nX,nY);
				if nIsBoss == 1 then
					Npc:RegPNpcOnDeath(pNpc,self.OnFinalBossDeath,self); 
				end
				self.tbFinalBossNpc[nIndex] = {pNpc.dwId,nTemplateId,nX,nY,nIsBoss};
			end
		end
	end
	return PrimerLv10.REFRESH_NPC_DELAY * Env.GAME_FPS;
end

--刷精英怪和首领
function tbRoom:AddBlueEnemy()
	if not self.tbBlueEnemy then
		self.tbBlueEnemy = {};
	end
	local tbNpcInfo = PrimerLv10.tbBlueEnemy;
	for _,tbInfo in pairs(tbNpcInfo) do
		local nTemplateId = tbInfo[1];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,20,-1,self.tbBase.nMapId,tbPos[1],tbPos[2],0,2);
					if pNpc then
						pNpc.ChangeType(30);
						Npc:RegPNpcOnDeath(pNpc,self.OnBlueEnemyDeath,self,1); 
						table.insert(self.tbBlueEnemy,{pNpc.dwId,nTemplateId,tbPos[1],tbPos[2],1});
					end
				end
			end
		end
	end
	local tbNpcInfo2 = PrimerLv10.tbNormalEnemy;
	for _,tbInfo in pairs(tbNpcInfo2) do
		local nTemplateId = tbInfo[1];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,20,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					Npc:RegPNpcOnDeath(pNpc,self.OnBlueEnemyDeath,self,0); 
					table.insert(self.tbBlueEnemy,{pNpc.dwId,nTemplateId,tbPos[1],tbPos[2],0});
				end
			end
		end
	end
end

function tbRoom:OnBlueEnemyDeath(bBlue,pKiller)
--	local pPlayer = pKiller.GetPlayer();
--	if not pPlayer then
--		return 0;
--	end
--	local nCount = pPlayer.GetTask(1025,35);
--	pPlayer.SetTask(1025,35,nCount + 1);	
--	pPlayer.GetTempTable("Task").nKillPrimerBlueEnemyCount = (pPlayer.GetTempTable("Task").nKillPrimerBlueEnemyCount or 0) + 1;
--	if pPlayer.GetTempTable("Task").nKillPrimerBlueEnemyCount and 
--		pPlayer.GetTempTable("Task").nKillPrimerBlueEnemyCount >= self.nKillBlueEnemyMaxCount then
--		pPlayer.SetTask(1025,35,1);
--	end
end

function tbRoom:AddXizuo()
	local tbNpcInfo = PrimerLv10.tbXizuo;
	if not self.tbXizuo then
		self.tbXizuo = {};
	end
	for _,tbInfo in pairs(tbNpcInfo) do
		local nTemplateId = tbInfo[1];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,20,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if pNpc then
						Npc:RegPNpcOnDeath(pNpc,self.OnXizuoDeath,self); 
						table.insert(self.tbXizuo,{pNpc.dwId,nTemplateId,tbPos[1],tbPos[2]});
					end
				end
			end
		end
	end
end

function tbRoom:OnXizuoDeath(pKiller)
	local pPlayer = pKiller.GetPlayer();
	if not pPlayer then
		return 0;
	end
	local funFinish = function(pMember)
		if pMember.GetTask(1025,40) ~= 5 then	--杀细作上一步没完成，杀了细作没用
			return 0;
		end
		pMember.SetTask(1025,36,1);
		pMember.SetTask(2014,1,0,1);	--打5行boss之前清0		
	end
	self.tbBase:TeamExcete(pPlayer,funFinish);
end

function tbRoom:AddNormalBoss()
	if not self.tbSeriesBoss then
		self.tbSeriesBoss = {};
	end
	local tbNpcInfo = PrimerLv10.tbOpenNormalBoss;
	for nTemplateId,tbInfo in pairs(tbNpcInfo) do
		if nTemplateId then
			for nSeries,tbPos in ipairs(tbInfo) do	--按金木水火土顺序
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,10,nSeries,self.tbBase.nMapId,tbPos[1],tbPos[2],0,0,0,0,nSeries - 1);
					if pNpc then
						table.insert(self.tbSeriesBoss,{pNpc.dwId,nTemplateId,tbPos[1],tbPos[2],nSeries});
						pNpc.GetTempTable("Task").nSeries = nSeries;
						pNpc.szName = PrimerLv10.tbSeriesName[nSeries];
						pNpc.Sync();
					end
				end
			end
		end
	end
end

function tbRoom:AddSeriesBoss(nNpcId,nSeries,nPlayerSeries)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local nTemplateId = PrimerLv10.tbNormalBoss[nSeries];
	if not nTemplateId then
		return 0;
	end
	if not PrimerLv10.tbNormalBossPos[nTemplateId] then
		return 0;
	end
	local tbPos = PrimerLv10.tbNormalBossPos[nTemplateId];
	local pBoss = KNpc.Add2(nTemplateId,10,nSeries,pNpc.nMapId,tbPos[1],tbPos[2]);
	local tbSeries = PrimerLv10.tbSeriesRelation;
	if pBoss then
		Npc:RegPNpcOnDeath(pBoss,self.OnNormalBossDeath,self,nSeries);
		pNpc.Delete();
	end
end

function tbRoom:OnNormalBossDeath(nSeries,pKiller)
	local pPlayer = pKiller.GetPlayer();
	if not pPlayer then
		return 0;
	end
	local funFinish = function(pMember)
		if pMember.GetTask(1025,36) ~= 1 then	--细作没有杀死
			return 0;
		end
		pMember.GetTempTable("Task").nKillNormalBossCount = (pMember.GetTempTable("Task").nKillNormalBossCount or 0) + 1;
		local nTaskSub = PrimerLv10.tbNormalBossTaskSub[nSeries];
		if nTaskSub then
			pMember.SetTask(1025,nTaskSub,1);
		end
		if pMember.GetTempTable("Task").nKillNormalBossCount and 
			pMember.GetTempTable("Task").nKillNormalBossCount >= self.nKillNormalBossMaxCount then
			pMember.SetTask(1025,37,1);
			pMember.SetTask(2014,1,9999,1);	--打最后一个boss时候设置为9999，打完就曝气
		end
	end
	self.tbBase:TeamExcete(pPlayer,funFinish);
end


function tbRoom:AddFinalBoss()
	if not self.tbFinalBossNpc then
		self.tbFinalBossNpc = {};
	end
	local tbNpcInfo = PrimerLv10.tbFinalBoss;
	for _,tbInfo in pairs(tbNpcInfo) do
		local nTemplateId = tbInfo[1];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,20,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if pNpc then
						Npc:RegPNpcOnDeath(pNpc,self.OnFinalBossDeath,self); 
						table.insert(self.tbFinalBossNpc,{pNpc.dwId,nTemplateId,tbPos[1],tbPos[2],1});
					end
				end
			end
		end
	end
	local tbEnemy = PrimerLv10.tbFinalEnemy;
	for _,tbInfo in pairs(tbEnemy) do
		local nTemplateId = tbInfo[1];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,20,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if pNpc then
						table.insert(self.tbFinalBossNpc,{pNpc.dwId,nTemplateId,tbPos[1],tbPos[2],0});
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
		if pMember.GetTask(1025,37) ~= 1 then	--没杀死五行boss
			return 0;
		end
		pMember.SetTask(1025,38,1);
		SpecialEvent.ActiveGift:AddCounts(pMember, 11);		--通关10级副本活跃度
	end
	self.tbBase:TeamExcete(pPlayer,funFinish);
end




