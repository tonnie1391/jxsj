-- 对话木华黎
local tbNpcMuhuali_Dialog = Npc:GetClass("elunheyuan_dlg_muhuali");
-- 战斗木华黎
local tbNpcMuhuali_Fight = Npc:GetClass("elunheyuan_fight_muhuali");
tbNpcMuhuali_Dialog.nChangshengcaoMaxNum = 4;	-- 长生草最大数量
tbNpcMuhuali_Dialog.nChangshengcaoRefreshNum = 2;-- 长生草每轮刷新的数量
tbNpcMuhuali_Dialog.nChangshengcaoRefreshTime = 10 * 18; -- 长生草刷新间隔
function tbNpcMuhuali_Dialog:OnDialog()
	local nSubWorld = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if tbInstancing.tbTollgateReset[5] ~= 1 then
		return;
	end
	-- 上一关打完才能开启下一关
	if tbInstancing.tbTollgateReset[4] ~= 2 then
		Dialog:Say("先打败了大祭司再来找我吧。");
		return;
	end
	local szMsg = string.format("%s：哦？你们这么快就来了,哈哈哈我等你们好半天了。听说有几名勇士再说有的项目中夺魁，又能通过大祭司的考验。着实不一般！看到我的军阵了么，这是我军的战阵，叫做金狼阵！来，勇士，闯了我的军阵！往前就是大汗的营帐！", him.szName);
	local tbOpt = {
		{"好，我要开始破阵！", self.StartFight, self, me.nId, him.dwId},
		{"Ta chỉ xem qua"},
	}
	Dialog:Say(szMsg, tbOpt);
end

function tbNpcMuhuali_Dialog:StartFight(nPlayerId, nNpcId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	local pNpc = KNpc.GetById(nNpcId);
	if (not pPlayer or not pNpc) then
		return;
	end
	local nSubWorld, nPosX, nPosY = pNpc.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if tbInstancing.tbTollgateReset[5] ~= 1 then
		return;
	end
	-- 出现特效
	local pEffectNpc = KNpc.Add2(2976, 10, -1, nSubWorld, 1652, 3315);
	assert(pEffectNpc);
	tbInstancing:ChangeTollgateState(5,0);
	pNpc.Delete();
	tbInstancing.tbJiaochang.nNpcMuhuali_Dialog = nil;
	Timer:Register(5 * Env.GAME_FPS, self.CallBoss, self, pEffectNpc.dwId);
	local tbPlayList, _ = KPlayer.GetMapPlayer(nSubWorld);
	for _, teammate in ipairs(tbPlayList) do
		teammate.NewWorld(nSubWorld, 1653, 3316);
		tbInstancing.tbAttendPlayerList[teammate.nId] = 1;
		teammate.SetFightState(1);
		Setting:SetGlobalObj(teammate);
		TaskAct:Talk("<npc=9957>：“看清这军阵了么，这是我军的战阵，叫做金狼阵！来，勇士，闯了我的军阵！刀枪在手，绝不容情，你们身在阵中，一定要有身在战阵的觉悟！”");
		Setting:RestoreGlobalObj();
	end
end

function tbNpcMuhuali_Dialog:CallBoss(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc) then
		return 0;
	end
	local nSubWorld, nX, nY = pNpc.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		return 0;
	end
	local pBoss = KNpc.Add2(9957, tbInstancing.nNpcLevel, -1, nSubWorld, nX, nY);
	if pBoss then
		pNpc.Delete();
		tbInstancing.tbJiaochang.nNpcMuhuali_Fight = pBoss.dwId;
		pBoss.AddLifePObserver(77); -- 提示
		pBoss.AddLifePObserver(27); -- 提示
		-- 血量每下降百分之五插旗
		for i = 75, 50, -5 do
			pBoss.AddLifePObserver(i);
		end
		for i = 25, 5, -5 do
			pBoss.AddLifePObserver(i);
		end
		Timer:Register(self.nChangshengcaoRefreshTime, self.RefreshChangshengcao, self, pBoss.dwId);
		Timer:Register(20 * Env.GAME_FPS, self.SaySomething, self, pBoss.dwId);
		tbInstancing:SendPrompt("Phá trận pháp, hạ Mộc Hoa Lê", 0, 0, 1, 0);
	else
		return Env.GAME_FPS; 
	end
	return 0;
end

-- 定时刷长生草
function tbNpcMuhuali_Dialog:RefreshChangshengcao(nBossId)
	local pBoss = KNpc.GetById(nBossId);
	if (not pBoss) then
		return 0;
	end
	local nSubWorld, nX, nY = pBoss.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		return 0;
	end
	-- 找两个点刷草,场内同时最多有四堆草
	local nRefreshNum = self.nChangshengcaoRefreshNum;
	local nMaxRemain = self.nChangshengcaoMaxNum - #tbInstancing.tbJiaochang.tbNpcChangshengcaoId;
	if nMaxRemain > 0 then
		if nRefreshNum > nMaxRemain then
			nRefreshNum = nMaxRemain;
		end
		for i = 1, nRefreshNum do
			local nRand = MathRandom(#tbNpcMuhuali_Fight.tbChangshengcaoPos);
			local pNpc = KNpc.Add2(9958, 110, -1, nSubWorld, tbNpcMuhuali_Fight.tbChangshengcaoPos[nRand][1], tbNpcMuhuali_Fight.tbChangshengcaoPos[nRand][2]);
			if pNpc then
				table.insert(tbInstancing.tbJiaochang.tbNpcChangshengcaoId, pNpc.dwId);
			end
		end 
	end
	return;
end

tbNpcMuhuali_Dialog.tbText = {
	"虎翼之阵，长枪铁盾，杀气盈满，若贸然击毁阵旗，必然被杀气激荡，身受重伤！",
	"锋矢之阵，铁马秋风狂荡过，正骑兵！锋矢阵旗受铁骑锐气斧凿，杀气犹如实质，小心应对！",
	"此战虽为切磋，但战阵之内刀枪无眼，各位勇士还需谨慎。",
	"雁行之阵，轻骑散列，箭发如雨。雁行阵旗宛若擎弓在手，受到伤害便会迎头痛击！",
	"草原军队虽然大多注重个人素质，但是这战阵排布，仍是一支军队所不可或缺的技艺。",	
};

-- boss喊喊话
function tbNpcMuhuali_Dialog:SaySomething(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local nSubWorld, _, _	= pNpc.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		return 0;
	end
	local nIndex = pNpc.GetTempTable("Task").nPromptIndex or 0;
	nIndex = math.mod(nIndex + 1, #self.tbText) + 1;
	tbInstancing:NpcSay(nNpcId, self.tbText[nIndex]);
	pNpc.GetTempTable("Task").nPromptIndex = nIndex;
end


tbNpcMuhuali_Fight.tbRandNpcFlagId = {9959, 9960, 9961};
tbNpcMuhuali_Fight.tbRandNpcSoldierId = {9963, 9964, 9965};
tbNpcMuhuali_Fight.tbRandNpcChatMsg = {"阵转虎翼，枪阵！盾墙！", "射手斜进，变阵雁行，射！", "轻骑飞射，精骑擎刃，突！"}
tbNpcMuhuali_Fight.tbOneAddFlagNum = 3;	
tbNpcMuhuali_Fight.tbOneAddSoldierNum = 2;
tbNpcMuhuali_Fight.tbFlagPos = {};
tbNpcMuhuali_Fight.tbSoldierPos = {};
tbNpcMuhuali_Fight.tbChangshengcaoPos = {};
-- 旗子出现时附带的状态ID，等级，时间
tbNpcMuhuali_Fight.tbFlagBornState = {{374,1,360},{1091,5,360},{1836,0,360}};
tbNpcMuhuali_Fight.nFlagStateRand = 50;	-- 旗子出现状态的概率

function tbNpcMuhuali_Fight:LoadPosSetting()
	self.tbFlagPos = {};
	self.tbSoldierPos = {};
	self.tbChangshengcaoPos = {};
	local tbFile1 = Lib:LoadTabFile("\\setting\\task\\armycamp\\elunheyuan\\muhualiflag_born.txt");
	assert(tbFile1);
	for nIndex, tbTemp in ipairs(tbFile1) do
		table.insert(self.tbFlagPos, {tonumber(tbTemp["POSX"]/32), tonumber(tbTemp["POSY"]/32)});
	end
	local tbFile2 = Lib:LoadTabFile("\\setting\\task\\armycamp\\elunheyuan\\muhualisoldier_born.txt");
	assert(tbFile2);
	for nIndex, tbTemp in ipairs(tbFile2) do
		table.insert(self.tbSoldierPos, {tonumber(tbTemp["POSX"]/32), tonumber(tbTemp["POSY"]/32)});
	end
	local tbFile3 = Lib:LoadTabFile("\\setting\\task\\armycamp\\elunheyuan\\muhualichangshengcao_born.txt");
	assert(tbFile3);
	for nIndex, tbTemp in ipairs(tbFile3) do
		table.insert(self.tbChangshengcaoPos, {tonumber(tbTemp["POSX"]/32), tonumber(tbTemp["POSY"]/32)});
	end
end
tbNpcMuhuali_Fight:LoadPosSetting();
-- 血量观察
function tbNpcMuhuali_Fight:OnLifePercentReduceHere(nLifePercent)
	local tbNpcInfo = him.GetTempTable("Task");
	tbNpcInfo.tbLifeObsever = tbNpcInfo.tbLifeObsever or {};
	if tbNpcInfo.tbLifeObsever[nLifePercent] then
		return;
	end
	tbNpcInfo.tbLifeObsever[nLifePercent] = 1;
	local nSubWorld = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if nLifePercent == 77 then
		him.SendChat("该让你们见识一下的我的军阵！！");
		tbInstancing:SendPrompt("Mộc Hoa Lê bày trận pháp, hãy cẩn thận!", 0, 1, 1, 0);
		tbInstancing:SendPrompt("Một số Kỳ trận được bảo hộ, hãy xác định cẩn thận", 0, 0, 1, 0);
		return;
	end
	if nLifePercent == 27 then
		him.SendChat("看你们还能否再破我的军阵！！");
		tbInstancing:SendPrompt("Mộc Hoa Lê bày trận pháp, hãy cẩn thận!", 0, 1, 1, 0);
		return;
	end
	-- 把boss的免疫伤害去除了
	if nLifePercent == 5 or nLifePercent == 50 then
		him.RemoveSkillState(1332);
		him.SendChat("了不起，竟然破了我的阵法。");
		-- 删除旗帜
		for nNpcId, _ in pairs(tbInstancing.tbJiaochang.tbNpcFlagInfo) do
			tbInstancing:DeleteNpc(nNpcId);
		end
		tbInstancing.tbJiaochang.tbNpcFlagInfo = {};
		return;
	end
	-- 95血量的时候给boss加一个化解伤害百分之百
	if nLifePercent == 75 or nLifePercent == 25 then
		him.AddSkillState(1332, 20, 1, 180000);
		him.SendChat("布阵");
		tbInstancing:SendPrompt("Trực tiếp tấn công Mộc Hoa Lê không đạt hiệu quả!", 0, 1, 1, 0);
		tbInstancing:SendPrompt("Thu thập Trường Sinh Thảo để giảm hiệu quả có hại!", 0, 0, 1, 1);
	end
	local nRand = MathRandom(#self.tbRandNpcFlagId);
	local nFlagId = self.tbRandNpcFlagId[nRand];
	local nSoldierId = self.tbRandNpcSoldierId[nRand];
	him.SendChat(self.tbRandNpcChatMsg[nRand]);
	Lib:SmashTable(self.tbFlagPos);
	-- 添加旗帜
	for i = 1, self.tbOneAddFlagNum do
		local pNpc = KNpc.Add2(nFlagId, tbInstancing.nNpcLevel, -1, nSubWorld, self.tbFlagPos[i][1], self.tbFlagPos[i][2]);
		if pNpc then
			tbInstancing.tbJiaochang.tbNpcFlagInfo[pNpc.dwId] = nRand;
			-- 旗子加个状态
			if MathRandom(100) <= self.nFlagStateRand and self.tbFlagBornState[nRand] then
				if self.tbFlagBornState[nRand][1] > 0 and self.tbFlagBornState[nRand][2] then
					pNpc.AddSkillState(self.tbFlagBornState[nRand][1], self.tbFlagBornState[nRand][2], 1, self.tbFlagBornState[nRand][3]);
				end
			end
		end
		for nPlayerId, nFlag in pairs(tbInstancing.tbAttendPlayerList) do
			if nFlag == 1 then
				local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
				if pPlayer then
					pPlayer.AddSkillState(2514, 3, 1, 180000);
				end
			end
		end
	end
	-- 添加士兵
	for i = 1, self.tbOneAddSoldierNum do
		local pNpc = KNpc.Add2(nSoldierId, tbInstancing.nNpcLevel, -1, nSubWorld, self.tbSoldierPos[i][1], self.tbFlagPos[i][2]);
		if pNpc then
			tbInstancing.tbJiaochang.tbNpcSoldierInfo[pNpc.dwId] = nRand;
		end
	end
end

function tbNpcMuhuali_Fight:OnDeath(pKiller)
	local nSubWorld = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	-- 清除场上的旗帜，士兵，长生草
	for nNpcId, _ in pairs(tbInstancing.tbJiaochang.tbNpcFlagInfo) do
		tbInstancing:DeleteNpc(nNpcId);
	end
	tbInstancing.tbJiaochang.tbNpcFlagInfo = {};
	for nNpcId, _ in pairs(tbInstancing.tbJiaochang.tbNpcSoldierInfo) do
		tbInstancing:DeleteNpc(nNpcId);
	end
	tbInstancing.tbJiaochang.tbNpcSoldierInfo = {};
	for _, nNpcId in ipairs(tbInstancing.tbJiaochang.tbNpcChangshengcaoId) do
		tbInstancing:DeleteNpc(nNpcId);
	end
	tbInstancing.tbJiaochang.tbNpcChangshengcaoId = {};
	-- 设置玩家状态
	tbInstancing:ChangeTollgateState(5, 2);
	tbInstancing.tbAttendPlayerList = {};
	local tbPlayList, _ = KPlayer.GetMapPlayer(nSubWorld);
	for _, teammate in ipairs(tbPlayList) do
		if (teammate.IsDead() == 1) then
			teammate.ReviveImmediately(1);
		end
		teammate.SetTask(1025, 72, 1);
		-- 清楚状态
		teammate.RemoveSkillState(2514);
		teammate.SetFightState(0);
		Setting:SetGlobalObj(teammate);
		TaskAct:Talk("<npc=9957>：“好！有勇有谋，破我大阵，有资格去面见大汗！”");
		Setting:RestoreGlobalObj();
		teammate.Msg("Vượt qua thử thách của Mộc Hoa Lê! Đến Đại Doanh Kha Hãn thôi!");
		Dialog:SendBlackBoardMsg(teammate, "Vượt qua thử thách của Mộc Hoa Lê! Đến Đại Doanh Kha Hãn thôi!");
	end
	local pKillerPlayer = pKiller.GetPlayer();
	if not pKillerPlayer then
		return 0;
	end
	Achievement:FinishAchievement(pKillerPlayer, 485);
end

tbNpcMuhuali_Fight.tbReduceLifeValue = {[1] = 0.025, [2] = 0.025, [3] = 0.025}; -- 每种旗帜扣boss的血量比例

-- 召唤的旗帜死亡
function tbNpcMuhuali_Fight:OnCallFlagDeath(nMapId, nType, nCastSkill, nSkillLevel)
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nMapId);
	assert(tbInstancing);
	local nBossId = tbInstancing.tbJiaochang.nNpcMuhuali_Fight;
	if not nBossId then
		return;
	end
	local pBoss = KNpc.GetById(nBossId);
	if not pBoss then
		return;
	end
	-- boss扣百分之2.5的血
	local nBlood = math.floor(pBoss.nMaxLife * self.tbReduceLifeValue[nType]);
	if nBlood > pBoss.nCurLife then
		nBlood = pBoss.nCurLife - 1;
	end
	pBoss.ReduceLife(nBlood);
	-- 如果怪死亡时候有buff则放buff
	if nCastSkill > 0 then
		local _, nX, nY = pBoss.GetWorldPos();
		pBoss.CastSkill(nCastSkill, nSkillLevel, nX * 32, nY * 32);
	end
end

-- 去buff的长生草
local tbNpcChangshengcao = Npc:GetClass("elunheyuan_changshengcao");

function tbNpcChangshengcao:OnDialog()
	if me.GetSkillState(2514) <= 0 then
		me.Msg("我好像不需要长生草，还是留给需要的队友吧。");
		return;
	end
	local tbEvent = 
	{
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
		Player.ProcessBreakEvent.emEVENT_SITE,
		Player.ProcessBreakEvent.emEVENT_USEITEM,
		Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
		Player.ProcessBreakEvent.emEVENT_DROPITEM,
		Player.ProcessBreakEvent.emEVENT_SENDMAIL,
		Player.ProcessBreakEvent.emEVENT_TRADE,
		Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
		Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
		Player.ProcessBreakEvent.emEVENT_DEATH,
	}
	GeneralProcess:StartProcess("采集中", Env.GAME_FPS, 
		{self.ClearBuff, self, me.nId, him.dwId}, nil, tbEvent);
end

function tbNpcChangshengcao:ClearBuff(nPlayerId, nNpcId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	local pNpc = KNpc.GetById(nNpcId);
	if (not pPlayer or not pNpc) then
		return;
	end
	local nSubWorld = pNpc.GetWorldPos();
	pNpc.Delete();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	-- 从列表中移除
	local nIndex = 0;
	for i, nChangshengcaoId in ipairs(tbInstancing.tbJiaochang.tbNpcChangshengcaoId) do
		if nChangshengcaoId == nNpcId then
			nIndex = i;
			break;
		end
	end
	if nIndex > 0 then
		table.remove(tbInstancing.tbJiaochang.tbNpcChangshengcaoId, nIndex);
		-- 清除指定buff
		if pPlayer.GetSkillState(2514) > 0 then
			pPlayer.RemoveSkillState(2514);
			pPlayer.Msg("长生草让你浑身又充满了力量！");
		end
	end
end

-- buff旗帜
local tbNpcHuyi = Npc:GetClass("elunheyuan_huyi");

function tbNpcHuyi:OnDeath(pKiller)
	local nSubWorld = him.GetWorldPos();
	local nCastSkill = 0;
	local nLevel = 0;
	-- 如果身上有某种buff
	if him.GetSkillState(374) > 0 then
		nCastSkill = 1838;
		nLevel = 20;
	end
	tbNpcMuhuali_Fight:OnCallFlagDeath(nSubWorld, 1, nCastSkill, nLevel);
end

local tbNpcYanxing = Npc:GetClass("elunheyuan_yanxing");

function tbNpcYanxing:OnDeath(pKiller)
	local nSubWorld = him.GetWorldPos();
	tbNpcMuhuali_Fight:OnCallFlagDeath(nSubWorld, 1, 0, 0);
end

local tbNpcShifeng = Npc:GetClass("elunheyuan_shifeng");

function tbNpcShifeng:OnDeath(pKiller)
	local nSubWorld = him.GetWorldPos();
	tbNpcMuhuali_Fight:OnCallFlagDeath(nSubWorld, 1, 0, 0);
end

-- 士兵
local tbNpcBubing = Npc:GetClass("elunheyuan_bubing");

function tbNpcBubing:OnDeath(pKiller)
	local nSubWorld = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	tbInstancing.tbJiaochang.tbNpcSoldierInfo[him.dwId] = nil;
end

local tbNpcGongbing = Npc:GetClass("elunheyuan_gongbing");

function tbNpcGongbing:OnDeath(pKiller)
	local nSubWorld = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	tbInstancing.tbJiaochang.tbNpcSoldierInfo[him.dwId] = nil;
end

local tbNpcQibing = Npc:GetClass("elunheyuan_qibing");

function tbNpcQibing:OnDeath(pKiller)
	local nSubWorld = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	tbInstancing.tbJiaochang.tbNpcSoldierInfo[him.dwId] = nil;
end
