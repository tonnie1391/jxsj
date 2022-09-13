-------------------------------------------------------
-- 文件名　：hongliandiyunpc.lua
-- 文件描述：红莲地狱
-- 创建者　：ZhangDeheng
-- 创建时间：2009-03-19 16:36:22
-------------------------------------------------------
-- 一层开BOSS2机关
local tbJiGuan = Npc:GetClass("hl_round5");

tbJiGuan.szDesc = "红莲地狱开BOSS5开关";
tbJiGuan.szSendText = "<npc=4184>：你们来干什么，我要把你们送到无间的红莲地狱。<end>（不知谁无意间碰处了海陵王棺椁上的机关，只听一声巨响天塌地陷，众人眼前一黑，坠入无尽深渊）";
tbJiGuan.szBossText = "<npc=4184>：多少年了，为什么吵醒我，你们会付出代价的。"
tbJiGuan.EFFECT_NPC	= 2976;
tbJiGuan.tbSendPos	= {1922, 3803};

function tbJiGuan:OnDialog()
	local nMapId, _, _ = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nMapId);
	if (not tbInstancing) then
		return;
	end;
	
	local tbPlayList, _ = KPlayer.GetMapPlayer(nMapId);
	if (tbInstancing.nHL_Round4_Count == 0) then
		for _, teammate in ipairs(tbPlayList) do
			Setting:SetGlobalObj(teammate);
			TaskAct:Talk(self.szSendText, self.TalkEndToSend, self, teammate.nId, him.dwId, tbInstancing);
			Setting:RestoreGlobalObj();
			tbInstancing.nHL_Round4_Count = 1;
		end;
	elseif (tbInstancing.nTrap10Pass == 1) then
		for _, teammate in ipairs(tbPlayList) do
			Setting:SetGlobalObj(teammate);
			TaskAct:Talk(self.szBossText, self.AddBoss, self, him.dwId, tbInstancing);
			Setting:RestoreGlobalObj();
		end;
	else
		TaskAct:Talk(self.szSendText, self.TalkEndToSend, self, me.nId, him.dwId, tbInstancing);
	end;	
end;

function tbJiGuan:TalkEndToSend(nId, dwId, tbInstancing)
	local pPlayer = KPlayer.GetPlayerObjById(nId);
	pPlayer.NewWorld(tbInstancing.nMapId, self.tbSendPos[1], self.tbSendPos[2]);
	pPlayer.SetFightState(1);
	tbInstancing:OnCoverEnd(pPlayer);
end;


function tbJiGuan:AddBoss(dwId, tbInstancing)
	
	local pNpc = KNpc.GetById(dwId);
	if (not pNpc) then
		return;
	end;
	local _, nPosX, nPosY	= pNpc.GetWorldPos();
	pNpc.Delete();
	
	local pNpc = KNpc.Add2(self.EFFECT_NPC, 10, -1, tbInstancing.nMapId, 1842, 3627);
	Timer:Register(5 * Env.GAME_FPS, self.CallBoss, self, pNpc.dwId);
end;

function tbJiGuan:CallBoss(dwId)
	local pNpc = KNpc.GetById(dwId);
	if (not pNpc) then
		return 0;
	end;
	
	local nMapId, nPosX, nPosY = pNpc.GetWorldPos();
	pNpc.Delete();
	
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nMapId);
	if (not tbInstancing or tbInstancing.nBoss5Out == 1) then
		return 0;
	end;
		
	local pNpc = KNpc.Add2(4184, tbInstancing.nNpcLevel, -1, nMapId, nPosX, nPosY);
	pNpc.CastSkill(1163, 10, -1, pNpc.nIndex);
	for i = 1, 9 do
		pNpc.AddLifePObserver(i * 10);
	end;
	tbInstancing.nBoss5Out = 1;	
	return 0;
end;

local tbBoss5 = Npc:GetClass("hl_boss5");

tbBoss5.szDesc = "BOSS5"
tbBoss5.tbText = {
			[90] = "来到这里，你们有些能力。",
			[80] = "你们想得到金国龙脉风水图？是的，就在我手上。",
			[70] = "徽钦二宗是什么下场，我想你们应该知道。",
			[60] = "苦海无边，回头是岸。",
			[50] = "还有多少人来，你们一起上吧。",
			[40] = "胡乱行事，你们不知道的事情太多了。",
			[30] = "以完颜先祖的名义，消灭你们。",
			[20] = "非我族类，其心必异。",
			[10] = "你们永远无法知晓大金的秘密。",
			[0]  = "<npc=4184>：尘归尘土归土，荣华富贵不过是过眼云烟，没有什么是永恒的。",
	}
function tbBoss5:OnLifePercentReduceHere(nLifePercent)
	local nSubWorld, _, _ = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if (not tbInstancing) then
		return;
	end;
	
	if (self.tbText[nLifePercent]) then
		--him.SendChat(self.tbText[nLifePercent]);
		
		local tbPlayList, _ = KPlayer.GetMapPlayer(tbInstancing.nMapId);
		for _, teammate in ipairs(tbPlayList) do
			teammate.Msg(self.tbText[nLifePercent], him.szName);
		end;
	end;
end;

function tbBoss5:OnDeath(pNpc)
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		return 0;
	end
	local pPlayer = pNpc.GetPlayer();
	
	tbInstancing.nTrap11Pass = 1;
	
	local tbPlayList, _ = KPlayer.GetMapPlayer(nSubWorld);
	for _, teammate in ipairs(tbPlayList) do
		Setting:SetGlobalObj(teammate);
		TaskAct:Talk(self.tbText[0], self.TalkEnd, self, tbInstancing);
		Setting:RestoreGlobalObj();
	end;
	
	-- 出口
	local pNpc = KNpc.Add2(4151, 120, -1, tbInstancing.nMapId, 59328 / 32, 114752 / 32);
	pNpc.szName = "返回义军营地";
	
	local tbHonor = {[3] = 24, [4] = 36, [5] = 48, [6] = 60}; -- 3、4、5、6人队长的领袖荣誉表
	if not pPlayer then  --如果杀死NPC的玩家掉线 那就随便给个 zounan
		pPlayer = tbPlayList[1];
	end

	local tbTeamPlayer, _ = KTeam.GetTeamMemberList(pPlayer.nTeamId);
	local _, nCount = KPlayer.GetMapPlayer(tbInstancing.nMapId);	
	if tbHonor[nCount] and tbTeamPlayer then
		PlayerHonor:AddPlayerHonorById_GS(tbTeamPlayer[1], PlayerHonor.HONOR_CLASS_LINGXIU, 0, tbHonor[nCount]);
	end
	
			-- 四次任务
	for _, player in ipairs(tbPlayList) do 
		local tbPlayerTasks	= Task:GetPlayerTask(player).tbTasks;
		local tbTask1 = tbPlayerTasks[381];
		local tbTask2 = tbPlayerTasks[429]
		local tbTask3 = tbPlayerTasks[490];
		if ((tbTask1 and tbTask1.nReferId == 565) or (tbTask2 and tbTask2.nReferId == 622) 
			or (tbTask3 and tbTask3.nReferId == 703)) then
			player.SetTask(1022, 202, player.GetTask(1022, 202) + 1);
		end;
		
		-- 额外奖励回调
		local nFreeCount, tbFunExecute = SpecialEvent.ExtendAward:DoCheck("ArmyCampBoss", player);
		SpecialEvent.ExtendAward:DoExecute(tbFunExecute);
		
		--通过军营累积次数
		local nTimes = player.GetTask(SpecialEvent.tbPJoinEventTimes.TASKGID, SpecialEvent.tbPJoinEventTimes.TASK_OVER_ARMY);
		player.SetTask(SpecialEvent.tbPJoinEventTimes.TASKGID, SpecialEvent.tbPJoinEventTimes.TASK_OVER_ARMY, nTimes + 1);
		
		-- 成就，通过海王陵墓
		Achievement:FinishAchievement(player, 259);
		Achievement:FinishAchievement(player, 260);
		-- 记录杀死boss的log
		StatLog:WriteStatLog("stat_info", "junying", "killboss", player.nId, player.GetHonorLevel(), pPlayer.nTeamId, him.nTemplateId, tbInstancing.szOpenTime);
		-- 完成军营任务记录次数
		Player:AddJoinRecord_DailyCount(player, Player.EVENT_JOIN_RECORD_JUNYINGRENWU, 1);
		
		SpecialEvent.ActiveGift:AddCounts(player, 26);		--完成军营活跃度
		SpecialEvent.BuyOver:AddCounts(pPlayer, SpecialEvent.BuyOver.TASK_QUANDOANH);
	end;

end;

function tbBoss5:TalkEnd(tbInstancing)
	if (tbInstancing.nJinDiZhiMenOut ~= 0) then
		return;
	end;
	
	tbInstancing.nJinDiZhiMenOut = 1;
	local pBox = KNpc.Add2(4280, 120, -1, tbInstancing.nMapId, 1842, 3627);
	local tbNpcData = pBox.GetTempTable("Task");
	tbNpcData.nHongLianDiYu = 1;
	tbNpcData.CUR_LOCK_COUNT = 0;
	
end;
local tbNpc = Npc:GetClass("hl_hldy_fire");
tbNpc.szDesc = "红莲地狱-火";

function tbNpc:OnDialog()
	local tbEvent = 
	{
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
		Player.ProcessBreakEvent.emEVENT_SITE,
		Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
		Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
		Player.ProcessBreakEvent.emEVENT_ATTACKED,
		Player.ProcessBreakEvent.emEVENT_DEATH,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
	}
	
	GeneralProcess:StartProcess("灭火中...", Env.GAME_FPS,{self.CrushOut, self, him.dwId}, {me.Msg, "Mở gián đoạn"}, tbEvent);	
end;

function tbNpc:CrushOut(dwId)
	local pNpc = KNpc.GetById(dwId);
	if (not pNpc ) then
		return;
	end;
	
	local nMapId, _, _ = pNpc.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nMapId);
	if (not tbInstancing) then
		return;
	end;
	
	tbInstancing.tbFireOutTime[pNpc.dwId] = nil;		
	pNpc.Delete();
	
	-- 成就，灭火
	Achievement:FinishAchievement(me, 268);
end;

-- hl_diyu1
local tbDiYuNpc = Npc:GetClass("hl_hldy_npc");

tbDiYuNpc.szDesc = "红莲地狱-地狱";

tbDiYuNpc.tbFirePos = {
	[7] = {
			{62912, 121824}, {62944, 121728}, {62912, 121984}, {62912, 122144}, {62848, 121888}, {62848, 122080}, {62944, 122272}, {62784, 121984}, 
			{63008, 121824}, {63104, 121824}, {63072, 121728}, {63008, 122144}, {63104, 121984}, {63104, 122144}, {63168, 121888}, {63072, 122272},
		},
	[8] = {
			{62432, 119136}, {62432, 119008}, {62432, 119296}, {62368, 119072}, {62368, 119264}, {62304, 119168}, {62528, 119008}, {62624, 119136}, 
			{62528, 119264}, {62624, 119008}, {62624, 119296}, {62560, 118880}, {62464, 118880}, {62464, 119424}, {62720, 119104}, {62720, 119264},
		},
	[9] = {
			{63840, 116256}, {63936, 116384}, {63744, 116384}, {63840, 116544}, {63936, 116256}, {63744, 116256}, {63744, 116544}, {63936, 116544}, 
			{63808, 116128}, {63904, 116128}, {63904, 116704}, {63808, 116704}, {63648, 116352}, {63648, 116512}, {64032, 116320}, {64032, 116480},
		},
						
	}
	
tbDiYuNpc.tbSendPos = {
		[7]  = {1970, 3837},
		[8]  = {1948, 3741},
		[9]  = {1989, 3663},
	}

function tbDiYuNpc:OnDialog()
	local nMapId, _, _ = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nMapId);
	if (not tbInstancing) then
		return;
	end;
	
	local tbData = him.GetTempTable("Task");
	if (not tbData or not tbData.nTrapNo or tbInstancing.tbDiYuTrap[tbData.nTrapNo] ~= 0 or tbInstancing.nTrap10Pass == 1) then
		return;
	end;
	
	local tbEvent = 
	{
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
		Player.ProcessBreakEvent.emEVENT_SITE,
		Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
		Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
		Player.ProcessBreakEvent.emEVENT_ATTACKED,
		Player.ProcessBreakEvent.emEVENT_DEATH,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
	}
	
	GeneralProcess:StartProcess("Đang mở...", Env.GAME_FPS * 5,{self.Open, self, him.dwId, tbInstancing}, {me.Msg, "Mở gián đoạn"}, tbEvent);		
end;

function tbDiYuNpc:Open(dwId, tbInstancing)
	local pNpc = KNpc.GetById(dwId);
	if (not pNpc) then
		return;
	end;
	
	local tbData = pNpc.GetTempTable("Task");
	if (tbInstancing.tbDiYuTrap[tbData.nTrapNo] ~= 0 or tbInstancing.nTrap10Pass == 1) then
		return;
	end;
	
	tbInstancing.tbDiYuTrap[tbData.nTrapNo] = 1;

	Task.tbArmyCampInstancingManager:Tip2MapPlayer(tbInstancing.nMapId, "Cơ quan đã mở, ngươi có thể đi tiếp rồi!");
	
	-- for nId, _ in pairs(tbInstancing.tbFireOutTime) do 
		-- local pNpc = KNpc.GetById(nId);
		-- if (pNpc) then
			-- pNpc.Delete();
		-- end;
		-- tbInstancing.tbFireOutTime[nId] = nil;		
	-- end;
	
	-- if (tbInstancing.nDY_TimerId) then
		-- Timer:Close(tbInstancing.nDY_TimerId);
		-- tbInstancing.nDY_TimerId = nil;
	-- end;
	
	-- tbInstancing.nDY_TimerId = Timer:Register(Env.GAME_FPS * 5, self.OnBreath, self, tbInstancing, tbData.nTrapNo);
end;

function tbDiYuNpc:OnBreath(tbInstancing, nNo)
	if (tbInstancing.nTrap10Pass == 1) then
		for nId, _ in pairs(tbInstancing.tbFireOutTime) do 
			local pNpc = KNpc.GetById(nId);
			if (pNpc) then
				pNpc.Delete();
			end;
			tbInstancing.tbFireOutTime[nId] = nil;		
		end;
	
		if (tbInstancing.nDY_TimerId) then
			Timer:Close(tbInstancing.nDY_TimerId);
			tbInstancing.nDY_TimerId = nil;
		end;
		return 0;	
	end;
	
	local nIndex1 = MathRandom(#self.tbFirePos[nNo]);
	local nIndex2 = MathRandom(#self.tbFirePos[nNo]);
	while nIndex1 == nIndex2 do
		nIndex2 = MathRandom(#self.tbFirePos[nNo]);
	end;

	local pNpc = KNpc.Add2(4235, 120, -1, tbInstancing.nMapId, self.tbFirePos[nNo][nIndex1][1] / 32, self.tbFirePos[nNo][nIndex1][2] / 32);
	pNpc.GetTempTable("Task").nDiYuNo = nNo; -- 用于标示是那个区域的火
	tbInstancing.tbFireOutTime[pNpc.dwId] = 0;
	
	local pNpc = KNpc.Add2(4235, 120, -1, tbInstancing.nMapId, self.tbFirePos[nNo][nIndex2][1] / 32, self.tbFirePos[nNo][nIndex2][2] / 32);
	pNpc.GetTempTable("Task").nDiYuNo = nNo; -- 用于标示是那个区域的火
	tbInstancing.tbFireOutTime[pNpc.dwId] = 0;
end;

function tbDiYuNpc:TimeOver(nNo, tbInstancing)
	if (tbInstancing.nTrap10Pass == 1) then
		return;
	end;
	
	Task.tbArmyCampInstancingManager:Tip2MapPlayer(tbInstancing.nMapId, "Ngọn lửa đã phá hủy cơ quan, hãy mở lại!");
	
	for nId, nTime in pairs(tbInstancing.tbFireOutTime) do
		local pNpc = KNpc.GetById(nId);
		if (pNpc) then
			pNpc.Delete();
		end;
		tbInstancing.tbFireOutTime[nId] = nil;
	end;

	local tbPlayList, _ = KPlayer.GetMapPlayer(tbInstancing.nMapId);
	for _, teammate in ipairs(tbPlayList) do
		teammate.NewWorld(tbInstancing.nMapId, self.tbSendPos[nNo][1], self.tbSendPos[nNo][2]);
		teammate.SetFightState(1);
		tbInstancing:OnCoverEnd(teammate);
	end;	
	tbInstancing.tbDiYuTrap[nNo] = 0;
	if (tbInstancing.tbDiYuTrap[nNo + 1] == 1) then
		tbInstancing.tbDiYuTrap[nNo + 1] = 0;
	end;

	if (tbInstancing.nDY_TimerId) then
		Timer:Close(tbInstancing.nDY_TimerId);
		tbInstancing.nDY_TimerId = nil;
	end;
end;

-- hl_boss4 火凤凰
local tbDiYuBoss4 = Npc:GetClass("hl_hldy_fenghuang");

tbDiYuBoss4.szDesc = "红莲地狱-火凤凰";
tbDiYuBoss4.szText = "所有机关都已解开，终于可以离开这里了。";

function tbDiYuBoss4:OnDeath(pNpc)
	local nMapId, _, _ = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nMapId);
	if (not tbInstancing) then
		return;
	end;
	
	tbInstancing.nTrap10Pass = 1;

	for nId, _ in pairs(tbInstancing.tbFireOutTime) do
		local pNpc = KNpc.GetById(nId);
		if (pNpc) then	
			pNpc.Delete();
		end;
		tbInstancing.tbFireOutTime[nId] = nil;
		
	end;
	if (tbInstancing.nDY_TimerId) then
		Timer:Close(tbInstancing.nDY_TimerId);
		tbInstancing.nDY_TimerId = nil;
	end;
		
	Task.tbArmyCampInstancingManager:Tip2MapPlayer(tbInstancing.nMapId, self.szText);
	
	local pNpc = KNpc.Add2(4151, 120, -1, tbInstancing.nMapId, 62112 / 32, 115040 / 32);	
	pNpc.szName = "";
end;

-- 3层指引
local tbZhiYin = Npc:GetClass("hl_yindao3");

tbZhiYin.szDesc = "地狱指引";

tbZhiYin.szText = "写给后来的人们：\n    消灭地狱守卫，机关会打开，切忌不要让<color=red>冥火<color>烧毁他，否则大家都要重新来过。尽头有地狱犬，小心。"

function tbZhiYin:OnDialog()
	Dialog:Say(self.szText, 
			{
				{"Kết thúc đối thoại"},	
			}
		);
end;