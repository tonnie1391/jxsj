-------------------------------------------------------
-- 文件名　：ercengnpc.lua
-- 文件描述：海陵王墓
-- 创建者　：ZhangDeheng
-- 创建时间：2009-03-17 08:46:04
-------------------------------------------------------

local tbNpc = Npc:GetClass("hl_guess2");

tbNpc.szDesc = "Số được tạo ngẫu nhiên từ <color=red>1-100<color> đoán theo thứ tự.";

function tbNpc:OnInit(tbInstancing, nMin, nMax)

	tbInstancing.nCurGuess2No		= nMin;
	tbInstancing.nGuess2Max			= nMax;
	
	tbInstancing.nGuessState2		= 0;
	tbInstancing.nGuessNo2			= MathRandom(nMax - nMin) + nMin;
end;

function tbNpc:OnDialog()
	local nSubWorld, _, _ = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if (not tbInstancing) then
		return;
	end;
	if (tbInstancing.nZhuZiOpen ~= 1) then
		return;
	end;
	
	if (tbInstancing.nGuessState2 == 0) then
		local tbOpt = {
			{"Bắt đầu đoán", self.GuessStart, self, tbInstancing, him.dwId},
			{"Kết thúc đối thoại"},
		}
		Dialog:Say(self.szDesc, tbOpt);	
	end;
	if (tbInstancing.nGuessState2 == 1) then
		local pPlayer = KPlayer.GetPlayerObjById(tbInstancing.nCurGuessPlayer);
		if (not pPlayer) then -- 如果当前猜字的玩家不在了，则下一位
			pPlayer = tbInstancing:GetNextPlayerFromTable(tbInstancing.tbGuessTable);
		end;
		
		if (not pPlayer) then -- 副本中没人了，出错返回
			return;
		end;
		tbInstancing.nCurGuessPlayer = pPlayer.nId;
		
		if (me.nId == tbInstancing.nCurGuessPlayer) then
			Dialog:AskNumber("Hãy nhập con số của bạn", tbInstancing.nGuess2Max, self.InputNo, self, tbInstancing, him.dwId, me.nId);
		else
			Dialog:SendInfoBoardMsg(me, "Đang là lượt của <color=yellow>" .. pPlayer.szName .. "<color>, hãy chờ đợi.");
			me.Msg("Đang là lượt của <color=yellow>" .. pPlayer.szName .. "<color>, hãy chờ đợi.");
		end;
	end;
end;

function tbNpc:GuessStart(tbInstancing, dwId)
	if (tbInstancing.nGuessState2 ~= 0) then
		return;
	end;
	 
	tbInstancing:SetGuessTable(tbInstancing.tbGuessTable);
	Lib:SmashTable(tbInstancing.tbGuessTable);
	local pPlayer = tbInstancing:GetNextPlayerFromTable(tbInstancing.tbGuessTable);
	if (pPlayer ~= nil) then
		local tbPlayList, _ = KPlayer.GetMapPlayer(tbInstancing.nMapId);
		for _, teammate in ipairs(tbPlayList) do
			Dialog:SendInfoBoardMsg(teammate, "Trò chơi bắt đầu, số may mắn <color=green>" ..tbInstancing.nCurGuess2No .. " - " .. tbInstancing.nGuess2Max .."<color>, mời <color=yellow>" .. pPlayer.szName .. "<color>");
			teammate.Msg("Trò chơi bắt đầu, số may mắn <color=green>" ..tbInstancing.nCurGuess2No .. " - " .. tbInstancing.nGuess2Max .."<color>, mời <color=yellow>" .. pPlayer.szName .. "<color>");
		end;
		
		tbInstancing.nGuessTimerId = Timer:Register(Env.GAME_FPS * 30, self.OnBreath, self, tbInstancing, dwId);
		tbInstancing.nGuessState2 = 1;
		tbInstancing.nCurGuessPlayer = pPlayer.nId;
	end;

end;

function tbNpc:OnBreath(tbInstancing, nNpcId)	
	local pPlayer = KPlayer.GetPlayerObjById(tbInstancing.nCurGuessPlayer);
	if (not pPlayer) then
		return;
	end;

	if (tbInstancing.nGuessTimerId) then
		Timer:Close(tbInstancing.nGuessTimerId);
		tbInstancing.nGuessTimerId = nil;
	end;

	local nNo = MathRandom(tbInstancing.nGuess2Max - tbInstancing.nCurGuess2No) + tbInstancing.nCurGuess2No;
	local szMsg = "<color=green>";
	szMsg = szMsg .. nNo;
	szMsg = szMsg .. "<color>";
	Dialog:SendInfoBoardMsg(pPlayer, "AFK quá 30 giây, hệ thống chọn giúp bạn số " .. szMsg ..".");
	pPlayer.Msg("AFK quá 30 giây, hệ thống chọn giúp bạn số " .. szMsg ..".");
	self:InputNo(tbInstancing, nNpcId, pPlayer.nId, nNo);
	return 0;
end;

function tbNpc:InputNo(tbInstancing, nNpcId, nId, nCount)
	if (nId ~= tbInstancing.nCurGuessPlayer) then
		return;
	end;
	
	if (tbInstancing.nGuessTimerId) then
		Timer:Close(tbInstancing.nGuessTimerId);
		tbInstancing.nGuessTimerId = nil;
	end;
	
	local pCurPlayer = KPlayer.GetPlayerObjById(tbInstancing.nCurGuessPlayer);
	if (tbInstancing.nGuessNo2 == nCount) then
		tbInstancing.nCurGuessPlayer = nil;
		local tbPlayList, _ = KPlayer.GetMapPlayer(tbInstancing.nMapId);
		for _, teammate in ipairs(tbPlayList) do
			Dialog:SendInfoBoardMsg(teammate, "Chúc mừng <color=yellow>" .. pCurPlayer.szName .. "<color> đoán trúng số may mắn, nhận 1 Rương Hoàng Kim");
			teammate.Msg("Chúc mừng <color=yellow>" .. pCurPlayer.szName .. "<color> đoán trúng số may mắn, nhận 1 Rương Hoàng Kim");
		end;

		if (pCurPlayer.CountFreeBagCell() >= 1) then
			pCurPlayer.AddItem(18, 1, 330, 1)
		else
			local nMapId, nPosX, nPosY = pCurPlayer.GetWorldPos();
			local pItem = KItem.AddItemInPos(nMapId, nPosX, nPosY, 18, 1, 330, 1,0, 0, 0, nil, nil, 0, 0, pCurPlayer);
			pItem.SetOnlyBelongPick(1);
		end;
		
		tbInstancing.nErCengWinner	 = pCurPlayer.nId;
		tbInstancing.nGuessState2 = 2;
		tbInstancing.nTrap5Pass	= 1;
		
		-- 成就，幸运数字
		Achievement:FinishAchievement(pCurPlayer, 267);
		
		local pNpc = KNpc.GetById(nNpcId);
		if (pNpc) then
			local _, nPosX, nPosY = pNpc.GetWorldPos();
			pNpc.Delete();
			local pNpc = KNpc.Add2(4227, 120, -1, tbInstancing.nMapId, nPosX, nPosY);
			pNpc.szName = "Lối vào tầng 3";
		end;
	else
		local pPlayer = tbInstancing:GetNextPlayerFromTable(tbInstancing.tbGuessTable);
		if not pPlayer then -- 加层判断 zounan
			return;
		end
		local tbPlayList, _ = KPlayer.GetMapPlayer(tbInstancing.nMapId);
		for _, teammate in ipairs(tbPlayList) do
			local szMsg = "";
			
			if (nCount < tbInstancing.nGuessNo2) then
				if (tbInstancing.nCurGuess2No < nCount) then
					tbInstancing.nCurGuess2No = nCount;
				end;
			else
				if (tbInstancing.nGuess2Max > nCount) then
					tbInstancing.nGuess2Max = nCount;
				end;
			end;
			Dialog:SendInfoBoardMsg(teammate, "Con số <color=green>" .. nCount.. "<color> không đúng, mời <color=yellow>" .. pPlayer.szName .. "<color>! Số may mắn từ <color=green>" ..tbInstancing.nCurGuess2No .. " - " .. tbInstancing.nGuess2Max .."<color>.");
			teammate.Msg("Con số <color=green>" .. nCount.. "<color> không đúng, mời <color=yellow>" .. pPlayer.szName .. "<color>! Số may mắn từ <color=green>" ..tbInstancing.nCurGuess2No .. " - " .. tbInstancing.nGuess2Max .."<color>.");
		end;
		tbInstancing.nGuessTimerId = Timer:Register(Env.GAME_FPS * 30, self.OnBreath, self, tbInstancing, nNpcId);
		tbInstancing.nCurGuessPlayer = pPlayer.nId;
	end;
end;

local tbZhuZi2 = Npc:GetClass("hl_zhuzi2");

tbZhuZi2.szDesc = "二层柱子";

function tbZhuZi2:OnDialog()
	local nSubWorld, _, _ = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if (not tbInstancing) then
		return;
	end;
	
	if (tbInstancing.tbOpen[him.dwId] ~= 0 or tbInstancing.nZhuZiOpen ~= 0) then
		return;
	end;
	if (tbInstancing.nOpenZhuZiTime ~= 2) then
		--进度条
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
		GeneralProcess:StartProcess("Đang mở...", 5 * 18, {self.OnOpen, self, him.dwId, me.nId, tbInstancing}, {me.Msg, "Mở gián đoạn"}, tbEvent);
	end;
end;


function tbZhuZi2:OnOpen(nNpcId, nPlayerId, tbInstancing)
	tbInstancing.nOpenZhuZiTime = 1;
	tbInstancing.tbOpen[nNpcId] = 1;
end;

-- 一层开BOSS2机关
local tbJiGuan = Npc:GetClass("hl_round3");

tbJiGuan.szDesc = "二层开BOSS2开关";
tbJiGuan.szText = "<npc=4183>：我征服的疆土比你们见过的还多，放马过来吧，年轻人。"
tbJiGuan.EFFECT_NPC	= 2976
tbJiGuan.tbHuWeiPos = {
		{1762, 3558},
		{1768, 3565},
		{1762, 3571},
		{1765, 3564},
	}
tbJiGuan.tbHuWeiId = {
			4185, 4186, 4187, 4188, 4189, 4190, 
			4191, 4192, 4193, 4194, 4195, 4196, 
			4197, 4198, 4199, 4200, 4201, 4202, 
			4203, 4204, 4205, 4206, 4207, 4208, 
		}
		
function tbJiGuan:OnDialog()
	local nMapId, _, _ = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nMapId);

	if (not tbInstancing or tbInstancing.nBoss3Out ~= 0) then
		return;
	end;
	
	local tbPlayList, _ = KPlayer.GetMapPlayer(nMapId);
	for _, teammate in ipairs(tbPlayList) do
		Setting:SetGlobalObj(teammate);
		TaskAct:Talk(self.szText, self.TalkEnd, self, him.dwId, tbInstancing);
		Setting:RestoreGlobalObj();
	end;	
end;

function tbJiGuan:TalkEnd(dwId, tbInstancing)

	local pNpc = KNpc.GetById(dwId);
	if (not pNpc or tbInstancing.nBoss3Out == 1) then
		return;
	end;
	local nMapId, nPosX, nPosY	= pNpc.GetWorldPos();
	pNpc.Delete();
	
	local pNpc = KNpc.Add2(self.EFFECT_NPC, 10, -1, tbInstancing.nMapId, nPosX, nPosY);
	Timer:Register(5 * Env.GAME_FPS, self.CallBoss, self, nMapId, pNpc.dwId);
end;

function tbJiGuan:CallBoss(nMapId, dwId)
	local pNpc = KNpc.GetById(dwId);
	if (not pNpc) then
		return 0;	
	end;

	local nMapId, nPosX, nPosY	= pNpc.GetWorldPos();
	pNpc.Delete();
	
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nMapId);
	if (not tbInstancing or tbInstancing.nBoss3Out == 1) then
		return 0;
	end;
		
	local pNpc = KNpc.Add2(4183, tbInstancing.nNpcLevel, -1, nMapId, nPosX, nPosY);
	pNpc.CastSkill(1163, 10, -1, pNpc.nIndex);
	for i = 1, 9 do
		pNpc.AddLifePObserver(i * 10);
	end;
	tbInstancing.nBoss3Out = 1;	
	
	for i = 1, 4 do
		Lib:SmashTable(self.tbHuWeiId);
		KNpc.Add2(self.tbHuWeiId[i], tbInstancing.nNpcLevel, -1, nMapId, self.tbHuWeiPos[i][1], self.tbHuWeiPos[i][2]);
	end;
end;
-- BOSS3
local tbBoss3 = Npc:GetClass("hl_boss3");

tbBoss3.szDesc = "BOSS3";
tbBoss3.tbText = {
			[90] = "无需我出手，护卫们抓刺客。",
			[80] = "我驰骋江湖的时候你们都还没出生呢。",
			[70] = "不是我倚老卖老，你们打不过我的。",
			[60] = "你们勇气可嘉，但是依照军法按律当斩。",
			[50] = "想当年岳家军也要让我三分。",
			[40] = "我倒要给你们看看，老狗也有几颗牙。",
			[30] = "坚强起来，我骨子里流的可是大金的血。",
			[20] = "这是最后一击了，我不会败给你们的。",
			[10] = "无论你建立多少丰功伟业，你都无法承受岁月的煎熬。",
			[0]  = "<npc=4183>：大金的江山岂是尔等鼠辈可以动摇的，你们永远无法征服我们狂野的心。",
	}
function tbBoss3:OnLifePercentReduceHere(nLifePercent)
	local nSubWorld, _, _ = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if (not tbInstancing) then
		return;
	end;
	
	if (self.tbText[nLifePercent]) then
		him.SendChat(self.tbText[nLifePercent]);
		
		local tbPlayList, _ = KPlayer.GetMapPlayer(tbInstancing.nMapId);
		for _, teammate in ipairs(tbPlayList) do
			teammate.Msg(self.tbText[nLifePercent], him.szName);
		end;
	end;
end;

function tbBoss3:OnDeath(pNpc)
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	
	tbInstancing.nTrap6Pass = 1;
	
	local tbPlayList, _ = KPlayer.GetMapPlayer(nSubWorld);
	for _, teammate in ipairs(tbPlayList) do
		Setting:SetGlobalObj(teammate);
		TaskAct:Talk(self.tbText[0]);
		Setting:RestoreGlobalObj();
	end;
	local pNpc = KNpc.Add2(4151, 120, -1, tbInstancing.nMapId, 55840 / 32, 116736 / 32);
	pNpc.szName = "";
end;

local tbErCengSend = Npc:GetClass("hl_ceng2chuansong");

tbErCengSend.szDesc = "二层传送";

function tbErCengSend:OnDialog()
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	
	Dialog:Say("是否进入？", 
		{"好", self.Enter, self, me.nId, him.dwId, tbInstancing},
		{"暂时不去"})
end;

function tbErCengSend:Enter(nPlayerId, nNpcId, tbInstancing)
	local pNpc = KNpc.GetById(nNpcId);
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pNpc or not pPlayer) then
		return;
	end;
	local tbData = pNpc.GetTempTable("Task");
	if (not tbData or not tbData.tbNo) then
		return;
	end;
	if not tbInstancing then
		return;
	end
	me.NewWorld(tbInstancing.nMapId, tbInstancing.ERCENG_SEND_POS[tbData.tbNo[1]][tbData.tbNo[2]][tbData.tbNo[3]][1] / 32, tbInstancing.ERCENG_SEND_POS[tbData.tbNo[1]][tbData.tbNo[2]][tbData.tbNo[3]][2] / 32);
end;

local tbSend2 = Npc:GetClass("hl_ceng2send");

tbSend2.szDesc 		= "猜点2后的传送门"
tbSend2.tbSendPos 	= {1775, 3490}; 

function tbSend2:OnDialog()
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	
	Dialog:Say("是否进入？", 
		{"好", self.Enter, self, me.nId, tbInstancing},
		{"暂时不去"})
end;

function tbSend2:Enter(nPlayerId, tbInstancing)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end;
	
	me.NewWorld(tbInstancing.nMapId, self.tbSendPos[1], self.tbSendPos[2]);
end;


-- 一层指引
local tbZhiYin = Npc:GetClass("hl_yindao2");

tbZhiYin.szDesc = "二层指引";

tbZhiYin.szText = "写给后来的人们：\n    到达迷宫角落，四个人<color=red>同时开启光影石<color>，游龙会再次降临，按照他的指示，猜中答案，就会出现下层的通道，但是这次与上层不同，<color=red>猜对的人将会得到丰厚的奖励<color>。"

tbZhiYin.szDianShu = "猜点的游戏规则：\n    由系统写出其中的任意一个数字，(以1-100为例，写出88)，再由所有游戏者按顺序每人说一个数字，而游戏者说出的数字有三种可能性，一个比写好的大，一个比写好的小，一个正好, 如果比写好的数字大的话(比如99)，出题者就应该缩小范围为此游戏者说的数字与最小数字之间(出题者应该说1-99)，再由下一个游戏者说出一个数字, 如果比写好的数字小的话(比如11)，出题者就应该缩小范围为此游戏者说的数字与最大数字之间(出题者应该说11-100)，再由下一个游戏者说出一个数字，(再延伸一下，下一个游戏者说90，出题者说11-90，再下一游戏者说60，出题者说60-90，依次类推) 直到游戏者说出出题者写出的数字，游戏结束。"

function tbZhiYin:OnDialog()
	Dialog:Say(self.szText, 
			{
				{"猜点规则", self.Say, self},
				{"Kết thúc đối thoại"},	
			}
		);
end;

function tbZhiYin:Say()
	Dialog:Say(self.szDianShu,
			{
				{"Kết thúc đối thoại"},	
			}
		);	
end;