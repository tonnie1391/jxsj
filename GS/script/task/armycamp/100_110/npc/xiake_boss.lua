-- 文件名　：xiake_boss.lua
-- 创建者　：huangxiaoming
-- 创建时间：2011-03-15 12:10:10
-- 描  述  ：百蛮山新增boss

local tbNpcOuYangZiYan	= Npc:GetClass("xiake_ouyangziyan"); -- 欧阳紫嫣

function tbNpcOuYangZiYan:OnDeath(pNpc)
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		return 0;
	end
	tbInstancing.nOuYangMeiOut = 0;
	local pPlayer = pNpc.GetPlayer();
	local nTeamId = 0;
	if pPlayer then
		nTeamId = pPlayer.nTeamId;
	end
	local szSendText =  "<npc=7315>：“再见了，我亲爱的姐姐。对不起，我失败了。”<end>";
	szSendText = szSendText .. "<npc=7316>:“真的那么渴求一死吗？我很乐意成全你们。我便是百蛮山真正的领主！”<end>";
	local tbPlayList, _ = KPlayer.GetMapPlayer(nSubWorld);
	for _, teammate in ipairs(tbPlayList) do
		Setting:SetGlobalObj(teammate);
		TaskAct:Talk(szSendText, self.TalkEnd, self, tbInstancing, nSubWorld);
		Setting:RestoreGlobalObj();
		StatLog:WriteStatLog("stat_info", "junying", "killboss", teammate.nId, teammate.GetHonorLevel(), nTeamId, him.nTemplateId, tbInstancing.szOpenTime);
	end
	Task.ArmyCamp:ClearData(him.dwId);
end

function tbNpcOuYangZiYan:TalkEnd(tbInstancing, nSubWorld)
	if tbInstancing.nOuYangMeiOut ~= 0 then
		return 0;
	end
	tbInstancing.nOuYangMeiOut = 1;
	local pTempNpc = KNpc.Add2(2976, 10, -1, nSubWorld, 1820, 2846);
	if pTempNpc then
		Timer:Register(5 * Env.GAME_FPS, self.CallOuYangMei, self, pTempNpc.dwId);
	end
end

function tbNpcOuYangZiYan:CallOuYangMei(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc) then
		return 0;
	end;
	local nMapId, nPosX, nPosY	= pNpc.GetWorldPos();
	pNpc.Delete();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nMapId);
	if not tbInstancing then
		return 0;
	end
	local pNpcOuYangMei = KNpc.Add2(7316, tbInstancing.nNpcLevel, -1, nMapId, nPosX, nPosY);
	if pNpcOuYangMei then
		pNpcOuYangMei.AddLifePObserver(50);
	end
	return 0;
end

local tbNpcOuYangMei= Npc:GetClass("xiake_ouyangmei"); -- 欧阳梅
tbNpcOuYangMei.nLimitCD = 8;	-- 同时死亡时间

function tbNpcOuYangMei:OnLifePercentReduceHere(nLifePercent)
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		return 0;
	end
	if nLifePercent == 50 then
		local tbNpcData = him.GetTempTable("Task");
		if not tbNpcData.nTrigTimes or tbNpcData.nTrigTimes == 0 then
			him.SendChat("为我而战，我的英雄。");
			local pNpc = KNpc.Add2(7320, tbInstancing.nNpcLevel, -1, nSubWorld, 1822, 2843);	-- 招慕容复
			if pNpc then
				tbNpcData.nTrigTimes = 1;
				tbNpcData.nHusbandId = pNpc.dwId;
				tbNpcData.nHusbandIsDead = 0;
				local tbHusbandData = pNpc.GetTempTable("Task");
				tbHusbandData.nWifeId = him.dwId;
				tbHusbandData.nWifeIsDead = 0;
				pNpc.SendChat("为你而战，我的娘子。");
				local tbPlayList, _ = KPlayer.GetMapPlayer(nSubWorld);
				for _, teammate in ipairs(tbPlayList) do
					Dialog:SendBlackBoardMsg(teammate, "此二人武功深不可测，必须同时击杀。");
					teammate.Msg("慕容复：娘子，我来助你！");
					teammate.Msg("欧阳梅：哈哈哈，只要我们还有一个活着，我们就能重新来过。");
					teammate.Msg("此二人武功深不可测，必须同时击杀。");
				end
			end
		end
	end
end

function tbNpcOuYangMei:OnDeath(pKillNpc)
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		return 0;
	end
	local tbNpcData = him.GetTempTable("Task");
	if tbNpcData.nHusbandId then	-- 他有老公
		if tbNpcData.nHusbandIsDead ~= 1 then	-- 他老公还活着
			local pNpc = KNpc.GetById(tbNpcData.nHusbandId);
			if not pNpc then	-- 各种原因导致不存在，重来一遍
				self:Relive(tbInstancing.nNpcLevel, nSubWorld);
				return 0;
			end
			local tbHusbandData = pNpc.GetTempTable("Task");
			if tbHusbandData.nWifeId ~= him.dwId then
				return 0;
			end
			tbHusbandData.nWifeIsDead = 1;
			tbHusbandData.nWifeDeadTime = GetTime();	-- 在他老公身上记录自己的死亡时间
			tbHusbandData.nWifeDeadTimer = Timer:Register(self.nLimitCD * 18, self.CheckDead, self, pNpc.dwId);
			local tbPlayList, _ = KPlayer.GetMapPlayer(nSubWorld);
			for _, teammate in ipairs(tbPlayList) do
				Dialog:SendBlackBoardMsg(teammate, "欧阳梅马上就要重生了，速度消灭慕容复");		
			end
			return 0;
		elseif tbNpcData.nHusbandDeadTime then	-- 他老公已经死了 
			local nNowTime = GetTime();
			if  nNowTime - tbNpcData.nHusbandDeadTime < self.nLimitCD and nNowTime - tbNpcData.nHusbandDeadTime > 0 then 
				if tbNpcData.nHusbandDeadTimer then
					if Timer:GetRestTime(tbNpcData.nHusbandDeadTimer) > 0 then	--保护
						Timer:Close(tbNpcData.nHusbandDeadTimer);
					end
					tbNpcData.nHusbandDeadTimer = nil;
				end
				local pPlayer = pKillNpc.GetPlayer();
				local tbPlayList, _ = KPlayer.GetMapPlayer(nSubWorld);
				local szTalk = "<npc=7316>:“我愿我们能够羽化成蝶，下辈子我要找寻世界每一个角落，我还要让你像现在一样得爱我,保护我,可以么？”<end>";
				szTalk = szTalk .. "<npc=7320>：“爱之火，在我俩的心中燃起，我们从此永不分离”<end>";
				for _, teammate in ipairs(tbPlayList) do
					XiakeDaily:AchieveTask(teammate, 1, 2);
					Setting:SetGlobalObj(teammate);
					TaskAct:Talk(szTalk);
					Setting:RestoreGlobalObj();
					Achievement:FinishAchievement(teammate, 378);
					StatLog:WriteStatLog("stat_info", "junying", "killboss", teammate.nId, teammate.GetHonorLevel(), pPlayer.nTeamId, 7316, tbInstancing.szOpenTime);
					-- 解一下buf
					teammate.RemoveSkillState(1887);
				end
				if type(XiakeDaily.DROPRATE) == "string" then
					him.DropRateItem(XiakeDaily.DROPRATE, 12, pPlayer.nId, -1, pPlayer.nId);
				end
				return 0;
			end
		else
			return 0;
		end
	end
	self:Relive(tbInstancing.nNpcLevel, nSubWorld);
end

function tbNpcOuYangMei:CheckDead(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then	-- 检查的npc不见了，不需要做什么了
		return 0;
	end
	self:ChangeAnger(pNpc);
	return 0;
end

function tbNpcOuYangMei:Relive(nLevel, nSubWorld)
	local pNewNpc = KNpc.Add2(7316, nLevel, -1, nSubWorld, 1820, 2846);	-- 招欧阳梅
	if pNewNpc then 
		pNewNpc.AddLifePObserver(50);
	end
	local tbPlayList, _ = KPlayer.GetMapPlayer(nSubWorld);
	for _, teammate in ipairs(tbPlayList) do
		Dialog:SendBlackBoardMsg(teammate, "欧阳梅：也许是缘，但更多是怨，我不甘心！");		
	end
end


function tbNpcOuYangMei:ChangeAnger(pNpc)	-- 怒了
	pNpc.AddSkillState(1080,60,0,32400,0,0,1);
	pNpc.AddSkillState(1332,10,0,32400,0,0,1);
	local nSubWorld, _, _	= pNpc.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		return 0;
	end
	Timer:Register(20 * 18, self.Reset, self, pNpc.dwId, tbInstancing.nNpcLevel, nSubWorld);
	local tbPlayList, _ = KPlayer.GetMapPlayer(nSubWorld);
	for _, teammate in ipairs(tbPlayList) do
		Dialog:SendBlackBoardMsg(teammate, "未将二人同时击杀，爱人的离去让孤单的人儿狂怒！");		
	end
end

function tbNpcOuYangMei:Reset(nNpcId, nLevel, nSubWorld)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then	-- 检查的npc不见了，不需要做什么了
		return 0;
	end
	pNpc.Delete();
	self:Relive(nLevel, nSubWorld);
	return 0;
end

local tbNpcMuRongFu	= Npc:GetClass("xiake_murongfu"); -- 慕容复
tbNpcMuRongFu.nLimitCD = tbNpcOuYangMei.nLimitCD;

function tbNpcMuRongFu:OnDeath(pKillNpc)
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		return 0;
	end
	local tbNpcData = him.GetTempTable("Task");
	if tbNpcData.nWifeId then	-- 压根他老婆就没出现，理论上不可能的
		if tbNpcData.nWifeIsDead ~= 1 then	-- 他老婆还活着
			local pNpc = KNpc.GetById(tbNpcData.nWifeId);
			if not pNpc then	-- 各种原因导致不存在，重来一遍
				tbNpcOuYangMei:Relive(tbInstancing.nNpcLevel, nSubWorld);
				return 0;
			end
			local tbWifeData = pNpc.GetTempTable("Task");
			if tbWifeData.nHusbandId ~= him.dwId then	-- 死的不是他老婆，无视
				return 0;
			end
			tbWifeData.nHusbandIsDead = 1;
			tbWifeData.nHusbandDeadTime = GetTime();	-- 在他老婆身上记录自己的死亡时间
			tbWifeData.nHusbandDeadTimer = Timer:Register(self.nLimitCD * 18, tbNpcOuYangMei.CheckDead, tbNpcOuYangMei, pNpc.dwId);
			local tbPlayList, _ = KPlayer.GetMapPlayer(nSubWorld);
			for _, teammate in ipairs(tbPlayList) do
				Dialog:SendBlackBoardMsg(teammate, "欧阳梅马上就要恢复了，速度消灭她");		
			end
			return 0;
		elseif tbNpcData.nWifeDeadTime then	-- 他老婆已经死了 
			local nNowTime = GetTime();
			if  nNowTime - tbNpcData.nWifeDeadTime < self.nLimitCD and nNowTime - tbNpcData.nWifeDeadTime > 0 then 
				if tbNpcData.nWifeDeadTimer then
					Timer:Close(tbNpcData.nWifeDeadTimer);
					tbNpcData.nWifeDeadTimer = nil;
				end
				local pPlayer = pKillNpc.GetPlayer();
				local tbPlayList, _ = KPlayer.GetMapPlayer(nSubWorld);
				local szTalk = "<npc=7316>:“我愿我们能够羽化成蝶，下辈子我要找寻世界每一个角落，我还要让你像现在一样得爱我,保护我,可以么？”<end>";
				szTalk = szTalk .. "<npc=7320>：“爱之火，在我俩的心中燃起，我们从此永不分离”<end>";
				for _, teammate in ipairs(tbPlayList) do
					XiakeDaily:AchieveTask(teammate, 1, 2);
					Setting:SetGlobalObj(teammate);
					TaskAct:Talk(szTalk);
					Setting:RestoreGlobalObj();
					Achievement:FinishAchievement(teammate, 378);
					StatLog:WriteStatLog("stat_info", "junying", "killboss", teammate.nId, teammate.GetHonorLevel(), pPlayer.nTeamId, 7316, tbInstancing.szOpenTime);
					teammate.RemoveSkillState(1887);
				end
				if type(XiakeDaily.DROPRATE) == "string" then
					him.DropRateItem(XiakeDaily.DROPRATE, 12, pPlayer.nId, -1, pPlayer.nId);
				end
				return 0;
			end
		else
			return 0;
		end
	end
	tbNpcOuYangMei:Relive(tbInstancing.nNpcLevel, nSubWorld);
end