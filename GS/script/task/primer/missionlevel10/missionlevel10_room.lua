-- 文件名　：missionlevel10_room.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-09-19 19:28:00
-- 描述：10级新手副本逻辑

Task.PrimerLv10 = Task.PrimerLv10 or {};

local PrimerLv10 = Task.PrimerLv10;

PrimerLv10.tbRoom = {};

local tbRoom = PrimerLv10.tbRoom;

tbRoom.tbStepInfo = 	--对应task步骤对应的触发函数
{
	[1] = {"AddBlueEnemy"},	--刷精英怪
	[2] = {"AddXizuo"},		--刷细作
	[3] = {"AddNormalBoss"},--刷五行boss
	[4] = {"AddFinalBoss"},	--刷大boss
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


--刷精英怪和首领
function tbRoom:AddBlueEnemy()
	self.nBlueCount = 0;
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
						self.nBlueCount = self.nBlueCount + 1;
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
					self.nBlueCount = self.nBlueCount + 1;
					Npc:RegPNpcOnDeath(pNpc,self.OnBlueEnemyDeath,self,0); 
				end
			end
		end
	end
end

function tbRoom:OnBlueEnemyDeath(bBlue,pKiller)
--	local pPlayer = pKiller.GetPlayer();
--	if pPlayer then
--		local nCount = pPlayer.GetTask(1025,35);
--		pPlayer.SetTask(1025,35,nCount + 1);	
--	end
--	self.nBlueCount = self.nBlueCount - 1;
--	if self.nBlueCount <= 0 then
--		self.tbBase:SetTask(1025,35,1);
--	end
	if bBlue == 1 then
		--掉篝火
		local _,nX,nY   = him.GetWorldPos();
		KItem.AddItemInPos(self.tbBase.nMapId,nX,nY,18,1,105,1);
		self.tbBase:AllBlackBoard("野外精英首领怪掉落篝火，组队并且点燃篝火后烤火可提升经验");
		self.tbBase:PlayerMsg("野外精英首领怪掉落篝火，组队并且点燃篝火后烤火可提升经验");
	end
end

function tbRoom:AddXizuo()
	local tbNpcInfo = PrimerLv10.tbXizuo;
	for _,tbInfo in pairs(tbNpcInfo) do
		local nTemplateId = tbInfo[1];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,20,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if pNpc then
						Npc:RegPNpcOnDeath(pNpc,self.OnXizuoDeath,self); 
					end
				end
			end
		end
	end
end

function tbRoom:OnXizuoDeath()
	self.tbBase:SetTask(1025,36,1);
end


function tbRoom:AddNormalBoss()
	local tbNpcInfo = PrimerLv10.tbOpenNormalBoss;
	self.nNormalBossCount = 0;
	for nTemplateId,tbInfo in pairs(tbNpcInfo) do
		if nTemplateId then
			for nSeries,tbPos in ipairs(tbInfo) do	--按金木水火土顺序
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,10,nSeries,self.tbBase.nMapId,tbPos[1],tbPos[2],0,0,0,0,nSeries - 1);
					if pNpc then
						pNpc.GetTempTable("Task").nSeries = nSeries;
						self.nNormalBossCount = self.nNormalBossCount + 1;
						pNpc.szName = PrimerLv10.tbSeriesName[nSeries];
						pNpc.Sync();
					end
				end
			end
		end
	end
	self.tbBase:SetTask(2014,1,0,1);	--打5行boss之前清0
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
		if tbSeries[nPlayerSeries] == nSeries then
			--相克则给boss加个弱化状态
			pBoss.AddSkillState(1651,20,1,300 * Env.GAME_FPS);
			self.tbBase:AllBlackBoard("你克我，以后遇到我这种五行你便有优势了！");
		elseif tbSeries[nSeries] == nPlayerSeries then
			--相弱则给boss加个强化状态
			pBoss.AddSkillState(1962,5,1,300 * Env.GAME_FPS);
			self.tbBase:AllBlackBoard("我克你，以后遇到我这种五行需要格外小心！");
		end
		Npc:RegPNpcOnDeath(pBoss,self.OnNormalBossDeath,self,nSeries);
		pNpc.Delete();
	end
end


function tbRoom:OnNormalBossDeath(nSeries)
	local nTaskSub = PrimerLv10.tbNormalBossTaskSub[nSeries];
	if nTaskSub then
		self.tbBase:SetTask(1025,nTaskSub,1);
	end
	self.nNormalBossCount = self.nNormalBossCount - 1;
	if self.nNormalBossCount <= 0 then
		self.tbBase:SetTask(1025,37,1);
		self.tbBase:SetTask(2014,1,9999,1);	--打最后一个boss时候设置为9999，打完就曝气
	end
end


function tbRoom:AddFinalBoss()
	local tbNpcInfo = PrimerLv10.tbFinalBoss;
	for _,tbInfo in pairs(tbNpcInfo) do
		local nTemplateId = tbInfo[1];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,20,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if pNpc then
						Npc:RegPNpcOnDeath(pNpc,self.OnFinalBossDeath,self); 
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
				end
			end
		end
	end	
end

function tbRoom:OnFinalBossDeath()
	self.tbBase:SetTask(1025,38,1);
	
	local tbPlayer,nCount = self.tbBase:GetPlayerList();
	if nCount > 0 then
		for _,pPlayer in pairs(tbPlayer) do
			if pPlayer then
				SpecialEvent.ActiveGift:AddCounts(pPlayer, 11);		--通关10级副本活跃度
			end
		end
	end
	
end


function tbRoom:ClearRoom()
	self.nBlueCount = 0;
	self.nNormalBossCount = 0;
end



