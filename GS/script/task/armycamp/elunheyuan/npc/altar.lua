-- 对话萨满
local tbNpcSaman_Dialog = Npc:GetClass("elunheyuan_dlg_saman");

function tbNpcSaman_Dialog:OnDialog()
	local nSubWorld = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if tbInstancing.tbTollgateReset[4] ~= 1 then
		return;
	end
	-- 上一关打完才能开启下一关
	if tbInstancing.tbTollgateReset[3] ~= 2 then
		Dialog:Say("你们心太急了，先去把之前的挑战都完成了再来找我吧");
		return;
	end
	local szMsg = string.format("%s：这里是草原的中心，腾格里庇佑之地。外来人，你们要接受草原之神的考验么。", him.szName);
	local tbOpt = {
		{"请开始吧", self.StartFight, self, me.nId, him.dwId},
		{"Ta chỉ xem qua"},
	}
	Dialog:Say(szMsg, tbOpt);
end

-- 对话转战斗
function tbNpcSaman_Dialog:StartFight(nPlayerId, nNpcId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	local pNpc = KNpc.GetById(nNpcId);
	if (not pPlayer or not pNpc) then
		return;
	end
	local nSubWorld, nPosX, nPosY = pNpc.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if tbInstancing.tbTollgateReset[4] ~= 1 then
		return;
	end
	-- 出现特效
	local pEffectNpc = KNpc.Add2(2976, 10, -1, nSubWorld, nPosX, nPosY);
	assert(pEffectNpc);
	tbInstancing:ChangeTollgateState(4,0);
	pNpc.Delete();
	tbInstancing.tbAltar.nNpcSaman_Dialog = nil;
	Timer:Register(5 * Env.GAME_FPS, self.CallBoss, self, pEffectNpc.dwId);
	local tbPlayList, _ = KPlayer.GetMapPlayer(nSubWorld);
	for _, teammate in ipairs(tbPlayList) do
		teammate.NewWorld(nSubWorld, 1731, 3396);
		tbInstancing.tbAttendPlayerList[teammate.nId] = 1;
		teammate.SetFightState(1);
		Setting:SetGlobalObj(teammate);
		TaskAct:Talk("<npc=9955>：“向长生天诉说你的迷茫吧，年轻人。诚意，专注，问心。你们就能够通过考验。”");
		Setting:RestoreGlobalObj();
	end
end

-- 添加boss
function tbNpcSaman_Dialog:CallBoss(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc) then
		return 0;
	end
	local nSubWorld, nX, nY = pNpc.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		return 0;
	end
	local pBoss = KNpc.Add2(9955, tbInstancing.nNpcLevel, -1, nSubWorld, nX, nY);
	if pBoss then
		pNpc.Delete();
		tbInstancing.tbAltar.nNpcSaman_Fight = pBoss.dwId;
		local tbFightNpc = Npc:GetClass("elunheyuan_fight_saman");
		-- 定时召唤炸弹兵
		Timer:Register(tbFightNpc.nCallSoldierSpeTime, tbFightNpc.CallSoldier, tbFightNpc, pBoss.dwId);
		pBoss.AddLifePObserver(50);
		Timer:Register(7 * Env.GAME_FPS, tbFightNpc.FightPrompt, tbFightNpc, pBoss.dwId, "阻拦献火祭祀！不要让他们靠近祭坛中心！");
		for nLifePercent, szTxt in pairs(tbFightNpc.tbText) do
			pBoss.AddLifePObserver(nLifePercent);
		end
	else
		return Env.GAME_FPS; 
	end
	return 0;
end

-- 战斗萨满
local tbNpcSaman_Fight = Npc:GetClass("elunheyuan_fight_saman");
tbNpcSaman_Fight.nCallSoldierSpeTime = 16 * 18; -- 出小怪的时间间隔
tbNpcSaman_Fight.nEverPosSoldierNum = 1;	-- 每个点出1个小怪
tbNpcSaman_Fight.szFilePath = "\\setting\\task\\armycamp\\elunheyuan\\soldier_born.txt";
tbNpcSaman_Fight.tbSoldierBornPos = {};
tbNpcSaman_Fight.tbText = {
	[85] = "你们持有着勇气，但是你们对于自己拥有的勇气是否有着迷茫？",
	[65] = "看看周围的献火祭祀，信仰的火堆就是靠他们一点点变得明亮。",
	[45] = "认识这些剑图腾吗？他们在绽放的时候会震撼你——你的肉体和灵魂，在做好准备承受之前，还是远离的好。",
	[20] = "腾格里就和神山上的白雪一样纯净，人的心灵也应该一样。",	
};


function tbNpcSaman_Fight:OnDeath(pKiller)
	local nSubWorld = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if him.dwId ~= tbInstancing.tbAltar.nNpcSaman_Fight then
		return;
	end
	if tbInstancing.tbTollgateReset[4] ~= 0 then
		return;
	end
	tbInstancing:ChangeTollgateState(4, 2);
	tbInstancing.tbAttendPlayerList = {};
	local tbPlayList, _ = KPlayer.GetMapPlayer(nSubWorld);
	for _, teammate in ipairs(tbPlayList) do
		if (teammate.IsDead() == 1) then
			teammate.ReviveImmediately(1);
		end
		teammate.SetTask(1025, 74, 1);
		teammate.SetFightState(0);
		Setting:SetGlobalObj(teammate);
		TaskAct:Talk("<npc=9955>：“我看到你们心中仍然存在着迷茫……不过，那并不影响你们通过了我的考验，希望前方的路途能够解除你的迷茫，年轻人，请继续前进吧。”");
		Setting:RestoreGlobalObj();
		Dialog:SendBlackBoardMsg(teammate, "Chúc mừng đã vượt qua thử thách, hãy đến nơi tiếp theo!");
	end
	tbInstancing.tbAltar.nNpcSaman_Fight = nil;
	-- 清除萨满兵
	for _, nNpcId in pairs(tbInstancing.tbAltar.tbNpcSamanbingId) do
		tbInstancing:DeleteNpc(nNpcId);
	end
	tbInstancing.tbAltar.tbNpcSamanbingId = {};
	local pKillerPlayer = pKiller.GetPlayer();
	if not pKillerPlayer then
		return 0;
	end
	Achievement:FinishAchievement(pKillerPlayer, 484);
end

--定时释放萨满兵
function tbNpcSaman_Fight:CallSoldier(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local nSubWorld, nX, nY = pNpc.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		return 0;
	end
	if not self.tbSoldierBornPos or #self.tbSoldierBornPos == 0 then
		local tbFile = Lib:LoadTabFile(self.szFilePath);
		if not tbFile then
			print("elunheyuan LoadTabFile", self.szFilePath);
			return 0;
		end
		for nIndex, tbTemp in ipairs(tbFile) do
			table.insert(self.tbSoldierBornPos, {tonumber(tbTemp["POSX"]/32), tonumber(tbTemp["POSY"]/32)});
		end
	end
	local tbNpcSamanBing = Npc:GetClass("elunheyuan_samanbing")
	for _, tbTemp in pairs(self.tbSoldierBornPos) do
		for i = 1, self.nEverPosSoldierNum do
			local pSoldier = KNpc.Add2(9956, pNpc.nLevel, -1, nSubWorld, tbTemp[1], tbTemp[2]);
			if pSoldier then
				table.insert(tbInstancing.tbAltar.tbNpcSamanbingId, pSoldier.dwId);
				pSoldier.GetTempTable("Npc").tbOnArrive = {tbNpcSamanBing.OnArrive1, tbNpcSamanBing, nNpcId, pSoldier.dwId};
				pSoldier.SetActiveForever(1)
				pSoldier.AI_ClearPath();
				pSoldier.AI_AddMovePos(1727*32, 3392*32);
				pSoldier.SetNpcAI(9, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0);
				Timer:Register(2 * Env.GAME_FPS, self.SoldierChat, self, pSoldier.dwId);
			end
		end
	end
	pNpc.SendChat("献祭！");
end

function tbNpcSaman_Fight:SoldierChat(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local tbMsg = {"以我之信念为火", "为了腾格里！"};
	local nRand = MathRandom(#tbMsg);
	pNpc.SendChat(tbMsg[nRand]);
end

function tbNpcSaman_Fight:OnLifePercentReduceHere(nLifePercent)
	if nLifePercent == 50 then
		him.SendChat("迅速避开大祭祀放下的图腾！");
	end
	local nSubWorld = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	tbInstancing:NpcSay(him.dwId, self.tbText[nLifePercent]);
end

function tbNpcSaman_Fight:FightPrompt(nNpcId, szMsg)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local nSubWorld, nX, nY = pNpc.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		return 0;
	end
	tbInstancing:SendPrompt(szMsg, 0, 1, 1, 0);
	return 0;
end

-- 萨满兵
local tbNpcSamanBing = Npc:GetClass("elunheyuan_samanbing");

-- 死亡之后从npc列表移除
function tbNpcSamanBing:OnDeath(pKiller)
	local nSubWorld = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	local nIndex = 0;
	for i, nSamanbingId in ipairs(tbInstancing.tbAltar.tbNpcSamanbingId) do
		if nSamanbingId == nNpcId then
			nIndex = i;
			break;
		end
	end
	if nIndex > 0 then
		table.remove(tbInstancing.tbAltar.tbNpcSamanbingId, nIndex);
	end
end

-- 萨满兵走到指令位置boss放技能
function tbNpcSamanBing:OnArrive1(nBossId, nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local nSubWorld = pNpc.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	pNpc.Delete();
	if not tbInstancing then
		return 0;
	end
	local nIndex = 0;
	for i, nSamanbingId in pairs(tbInstancing.tbAltar.tbNpcSamanbingId) do
		if nSamanbingId == nNpcId then
			nIndex = i;
			break;
		end
	end
	if nIndex > 0 then
		table.remove(tbInstancing.tbAltar.tbNpcSamanbingId, nIndex);
		local pBoss = KNpc.GetById(nBossId);
		if not pBoss then
			return 0;
		end
		-- boss放技能
		local _, nX, nY = pBoss.GetWorldPos();
		pBoss.CastSkill(2507, 3, nX * 32, nY * 32);
		pBoss.SendChat("在神的力量下颤抖吧！");
	end
	return 0;
end
