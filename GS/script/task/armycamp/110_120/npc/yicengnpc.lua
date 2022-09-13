-------------------------------------------------------
-- 文件名　：yicengnpc.lua
-- 文件描述：副本一层NPC脚本
-- 创建者　：ZhangDeheng
-- 创建时间：2009-03-16 10:54:32
-------------------------------------------------------

local tbNpc = Npc:GetClass("hl_guess1");

tbNpc.tbDesc = {
		"Vòng đầu tiên: Đáp án đúng từ <color=red>6-36<color>, mời các thành viên đoán.",
		"Vòng thứ hai: Đáp án đúng từ <color=red>5-30<color>, mời các thành viên đoán.",
		"Vòng cuối cùng: Đáp án đúng từ <color=red>4-24<color>, mời các thành viên đoán.",
	}

tbNpc.GUESS_GIFT = {
				{"Rương Bạch Ngân", 18, 1, 331, 1},
				{"Rương Thanh Đồng", 18, 1, 332, 1},
				{"Rương Huyền Thiết", 18, 1, 333, 1},
		}

function tbNpc:OnInit(tbInstancing, nMin, nMax)
	tbInstancing.nCurGuessPlayer 	= 0;

	tbInstancing.nCurGuess1No		= nMin - 1;
	tbInstancing.nGuess1Max			= nMax;
	
	tbInstancing.nOpen1 			= 1;
	tbInstancing.nGuessState1		= 0;
	tbInstancing.nGuessNo1			= MathRandom(nMax - nMin) + nMin;
	tbInstancing.nPassGuess			= {};
	tbInstancing.nReturnGuess		= {};
end;

function tbNpc:OnDialog()
	local nSubWorld, _, _ = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if (not tbInstancing) then
		return;
	end;
	if (tbInstancing.nOpenJiGuan ~= 4) then
		return;
	end;
	
	if (tbInstancing.nGuessState1 == 0) then
		local tbOpt = {
			{"Bắt đầu trò chơi", self.GuessStart, self, tbInstancing},
			{"Kết thúc đối thoại"},
		}
		Dialog:Say(self.tbDesc[tbInstancing.nYiCengGuessCount + 1], tbOpt);	
	end;
	if (tbInstancing.nGuessState1 == 1) then
		local pPlayer = KPlayer.GetPlayerObjById(tbInstancing.nCurGuessPlayer);
		if (not pPlayer) then -- 如果当前猜字的玩家不在了，则下一位
			pPlayer = tbInstancing:GetNextPlayerFromTable(tbInstancing.tbGuessTable);
		end;
		
		if (not pPlayer) then -- 副本中没人了，出错Trở về
			return;
		end;
		tbInstancing.nCurGuessPlayer = pPlayer.nId;
		
		if (me.nId == tbInstancing.nCurGuessPlayer) then
			local szMsg = "Hãy chọn đi nào: "
			local nNo = tbInstancing.nCurGuess1No;
			local tbOpt = {
					{string.format("%d", nNo + 1), self.InputNo, self, me.nId, him.dwId, tbInstancing, 1},
					{string.format("%d,%d", nNo + 1, nNo + 2), self.InputNo, self, me.nId, him.dwId, tbInstancing, 2},
					{string.format("%d,%d,%d", nNo + 1, nNo + 2, nNo + 3), self.InputNo, self, me.nId, him.dwId, tbInstancing, 3},
				};
			if (not tbInstancing.nPassGuess[tbInstancing.nCurGuessPlayer] or tbInstancing.nPassGuess[tbInstancing.nCurGuessPlayer] ~= 1) then
				if (not tbInstancing.nReturnGuess[tbInstancing.nCurGuessPlayer] or tbInstancing.nReturnGuess[tbInstancing.nCurGuessPlayer] ~= 1) then
					tbOpt[#tbOpt + 1] = {"Bỏ qua", self.InputNo, self, me.nId, him.dwId, tbInstancing, 4};
					tbOpt[#tbOpt + 1] = {"Trở về", self.InputNo, self, me.nId, him.dwId, tbInstancing, 5};
				end;
			end;
			Dialog:Say(szMsg, tbOpt);
		else
			Dialog:SendInfoBoardMsg(me, "Bạn không thể đoán bây giờ, hãy đợi <color=yellow>" .. pPlayer.szName .. "<color>");
			me.Msg("Bạn không thể đoán bây giờ, hãy đợi <color=yellow>" .. pPlayer.szName .. "<color>");
		end;
	end;
end;

function tbNpc:GuessStart(tbInstancing)
	if (tbInstancing.nGuessState1 ~= 0) then
		return;
	end;
	
	tbInstancing:SetGuessTable(tbInstancing.tbGuessTable);
	Lib:SmashTable(tbInstancing.tbGuessTable);
	local pPlayer = tbInstancing:GetNextPlayerFromTable(tbInstancing.tbGuessTable);
	if (pPlayer ~= nil) then
		local tbPlayList, _ = KPlayer.GetMapPlayer(tbInstancing.nMapId);
		for _, teammate in ipairs(tbPlayList) do
			Dialog:SendInfoBoardMsg(teammate, "Trò chơi bắt đầu, đáp án vòng này <color=green>" ..(tbInstancing.nCurGuess1No + 1) .." - " .. tbInstancing.nGuess1Max .."<color>, mời <color=yellow>" .. pPlayer.szName .. "<color>");
			teammate.Msg("Trò chơi bắt đầu, đáp án vòng này <color=green>" ..(tbInstancing.nCurGuess1No + 1) .." - " .. tbInstancing.nGuess1Max .."<color>, mời <color=yellow>" .. pPlayer.szName .. "<color>");
		end;
		
		if (tbInstancing.nGuessTimerId) then
			Timer:Close(tbInstancing.nGuessTimerId);
			tbInstancing.nGuessTimerId = nil;
		end;
		tbInstancing.nGuessTimerId = Timer:Register(Env.GAME_FPS * 30, self.OnBreath, self, him.dwId, tbInstancing);
		tbInstancing.nCurGuessPlayer = pPlayer.nId;
		tbInstancing.nGuessState1 = 1;
	end;
end;

function tbNpc:OnBreath(nId, tbInstancing)
	local pPlayer = KPlayer.GetPlayerObjById(tbInstancing.nCurGuessPlayer);
	if (not pPlayer) then
		return;
	end;

	if (tbInstancing.nGuessTimerId) then
		Timer:Close(tbInstancing.nGuessTimerId);
		tbInstancing.nGuessTimerId = nil;
	end;
			
	local nNo = MathRandom(3);
	local szMsg = "<color=green>";
	for i = 1, nNo do
		local n = tbInstancing.nCurGuess1No + i;
		szMsg = szMsg .. n .. " ";
	end;
	szMsg = szMsg .. "<color>";
	Dialog:SendInfoBoardMsg(pPlayer, "AFK quá 30 giây, hệ thống chọn giúp bạn số " .. szMsg ..".");
	pPlayer.Msg("AFK quá 30 giây, hệ thống chọn giúp bạn số " .. szMsg ..".");
	self:InputNo(pPlayer.nId, nId, tbInstancing, nNo);
	return 0;
end;
	
function tbNpc:InputNo(nId, dwId, tbInstancing, nCount)
	if(nId ~= tbInstancing.nCurGuessPlayer) then
		return;
	end;
	
	if (tbInstancing.nGuessTimerId) then
		Timer:Close(tbInstancing.nGuessTimerId);
		tbInstancing.nGuessTimerId = nil;
	end;
	local pCurPlayer = KPlayer.GetPlayerObjById(tbInstancing.nCurGuessPlayer);
	local tbPlayList, _ = KPlayer.GetMapPlayer(tbInstancing.nMapId);
	
	if (nCount == 4) then
		local pCurPlayer = KPlayer.GetPlayerObjById(tbInstancing.nCurGuessPlayer);
		local pPlayer = tbInstancing:GetNextPlayerFromTable(tbInstancing.tbGuessTable);
		local tbPlayList, _ = KPlayer.GetMapPlayer(tbInstancing.nMapId);
		for _, teammate in ipairs(tbPlayList) do
			Dialog:SendInfoBoardMsg(teammate, "<color=yellow>" .. pCurPlayer.szName .."<color> chọn <color=green>Bỏ qua<color>, mời <color=yellow>" .. pPlayer.szName .. "<color>");
			teammate.Msg("<color=yellow>" .. pCurPlayer.szName .."<color> chọn <color=green>Bỏ qua<color>, mời <color=yellow>" .. pPlayer.szName .. "<color>");
			tbInstancing.nCurGuessPlayer = pPlayer.nId;
		end;
		
		if (tbInstancing.nGuessTimerId) then
			Timer:Close(tbInstancing.nGuessTimerId);
			tbInstancing.nGuessTimerId = nil;
		end;
	
		tbInstancing.nGuessTimerId = Timer:Register(Env.GAME_FPS * 30, self.OnBreath, self, dwId, tbInstancing);
		tbInstancing.nPassGuess[pCurPlayer.nId] = 1;
	elseif (nCount == 5) then
		local pCurPlayer = KPlayer.GetPlayerObjById(tbInstancing.nCurGuessPlayer);
		tbInstancing.tbGuessTable = tbInstancing:ConverseTable(tbInstancing.tbGuessTable);
		local pPlayer = tbInstancing:GetNextPlayerFromTable(tbInstancing.tbGuessTable);
		local tbPlayList, _ = KPlayer.GetMapPlayer(tbInstancing.nMapId);
		for _, teammate in ipairs(tbPlayList) do
			Dialog:SendInfoBoardMsg(teammate, "<color=yellow>" .. pCurPlayer.szName .."<color> chọn <color=green>Trở về<color>, mời <color=yellow>" .. pPlayer.szName .. "<color>");
			teammate.Msg("<color=yellow>" .. pCurPlayer.szName .."<color> chọn <color=green>Trở về<color>, mời <color=yellow>" .. pPlayer.szName .. "<color>");
			tbInstancing.nCurGuessPlayer = pPlayer.nId;
		end;
		
		if (tbInstancing.nGuessTimerId) then
			Timer:Close(tbInstancing.nGuessTimerId);
			tbInstancing.nGuessTimerId = nil;
		end;
	
		tbInstancing.nGuessTimerId = Timer:Register(Env.GAME_FPS * 30, self.OnBreath, self, dwId, tbInstancing);
		tbInstancing.nReturnGuess[pCurPlayer.nId] = 1;
	else
		if (tbInstancing.nGuessNo1 >= tbInstancing.nCurGuess1No + 1 and tbInstancing.nGuessNo1 <= tbInstancing.nCurGuess1No + nCount) then
			tbInstancing.nYiCengGuessCount = tbInstancing.nYiCengGuessCount + 1;
			if (tbInstancing.nYiCengGuessCount ~= 3) then
				for _, teammate in ipairs(tbPlayList) do
					Dialog:SendInfoBoardMsg(teammate, "<color=yellow>" .. pCurPlayer.szName .. "<color> chọn trúng số xui, mời tham gia vòng kế tiếp");
					teammate.Msg("<color=yellow>" .. pCurPlayer.szName .. "<color> chọn trúng số xui, mời tham gia vòng kế tiếp");
				end;
				if (tbInstancing.nYiCengGuessCount == 1) then
					self:OnInit(tbInstancing, 5, 30);
				elseif (tbInstancing.nYiCengGuessCount == 2) then
					self:OnInit(tbInstancing, 4, 24);
				end;
				
				tbInstancing.tbYiCengWinner[tbInstancing.nYiCengGuessCount] = pCurPlayer.nId;
			else
				tbInstancing.tbYiCengWinner[tbInstancing.nYiCengGuessCount] = pCurPlayer.nId;
				self:GameOver(dwId, tbInstancing);
			end;
			
			-- 成就，猜到倒霉数字
			Achievement:FinishAchievement(pCurPlayer, 266);
		else
			local pPlayer = tbInstancing:GetNextPlayerFromTable(tbInstancing.tbGuessTable);
			if not pPlayer then  -- 加层判断zounan
				return;
			end	
			local szMsg = "";
			for i = tbInstancing.nCurGuess1No + 1, tbInstancing.nCurGuess1No + nCount do
				szMsg = szMsg .. i .. " ";
			end;
			for _, teammate in ipairs(tbPlayList) do
				Dialog:SendInfoBoardMsg(teammate, "<color=yellow>" .. pCurPlayer.szName .."<color> chọn <color=green>" .. szMsg .. "<color> chọn xong, mời <color=yellow>" .. pPlayer.szName .. "<color>");
				teammate.Msg("<color=yellow>" .. pCurPlayer.szName .."<color> chọn <color=green>" .. szMsg .. "<color> chọn xong, mời <color=yellow>" .. pPlayer.szName .. "<color>");
			end;
			
			if (tbInstancing.nGuessTimerId) then
				Timer:Close(tbInstancing.nGuessTimerId);
				tbInstancing.nGuessTimerId = nil;
			end;
	
			tbInstancing.nGuessTimerId = Timer:Register(Env.GAME_FPS * 30, self.OnBreath, self, dwId, tbInstancing);
			tbInstancing.nCurGuess1No = tbInstancing.nCurGuess1No + nCount;
			tbInstancing.nCurGuessPlayer = pPlayer.nId;
		end;
	end;
end;

function tbNpc:GameOver(nNpcId, tbInstancing)
	local tbPlayList, _ = KPlayer.GetMapPlayer(tbInstancing.nMapId);
	local pCurPlayer = KPlayer.GetPlayerObjById(tbInstancing.nCurGuessPlayer);
	
	for _, teammate in ipairs(tbPlayList) do
		local nWinCount = 1;
		for i = 1, #tbInstancing.tbYiCengWinner do
			if (tbInstancing.tbYiCengWinner[i] == teammate.nId) then
				nWinCount = nWinCount + 1;
			end;
		end;
		if (self.GUESS_GIFT[nWinCount]) then
			if (teammate.CountFreeBagCell() >= 1) then
				teammate.AddItem(self.GUESS_GIFT[nWinCount][2], self.GUESS_GIFT[nWinCount][3], self.GUESS_GIFT[nWinCount][4], self.GUESS_GIFT[nWinCount][5])
			else
				local nMapId, nPosX, nPosY = teammate.GetWorldPos();
				local pItem = KItem.AddItemInPos(nMapId, nPosX, nPosY, self.GUESS_GIFT[nWinCount][2], self.GUESS_GIFT[nWinCount][3], self.GUESS_GIFT[nWinCount][4], self.GUESS_GIFT[nWinCount][5], 0, 0, 0, nil, nil, 0, 0, teammate);
				pItem.SetOnlyBelongPick(1);
			end;
			Dialog:SendInfoBoardMsg(teammate, "Không may <color=yellow>" .. pCurPlayer.szName .. "<color> chọn trúng số xui, trò chơi kết thúc. Nhận được 1 <color=yellow>" .. self.GUESS_GIFT[nWinCount][1] .. "<color>!");
			teammate.Msg("Không may <color=yellow>" .. pCurPlayer.szName .. "<color> chọn trúng số xui, trò chơi kết thúc. Nhận được 1 <color=yellow>" .. self.GUESS_GIFT[nWinCount][1] .. "<color>!");
		else
			Dialog:SendInfoBoardMsg(teammate, "Không may <color=yellow>" .. pCurPlayer.szName .. "<color> chọn trúng số xui, trò chơi kết thúc. "); 
			teammate.Msg("Không may <color=yellow>" .. pCurPlayer.szName .. "<color> chọn trúng số xui, trò chơi kết thúc. "); 
		end;
	end;
	
	local pNpc = KNpc.GetById(nNpcId);
	local nPosX = 58912 / 32;
	local nPosY = 102752 / 32;
	if (pNpc) then
		local _, nX, nY = pNpc.GetWorldPos();
		nPosX = nX;
		nPosY = nY;
		
		pNpc.Delete();
	end;
	
	local pNpc = KNpc.Add2(4226, 120, -1, tbInstancing.nMapId, nPosX, nPosY);
	pNpc.szName = "Lối vào tầng 2";
end;

-- 一层机关，按照风 林 火 山 顺序开启
local tbJiGuan = Npc:GetClass("hl_jiguan");

tbJiGuan.szDesc = "一层机关";
tbJiGuan.szText = "<npc=4224>：你们找到了我，很好，但是要想Bỏ qua这里，你们必须帮我找到三个答案。<end><npc=4224>：忘了说了，答到数字的人将会受到惩罚。<end><npc=4224>：想好了就开始游戏，你们尽情享受吧，哈哈哈哈……<end>";

function tbJiGuan:OnDialog()
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	
	if (tbInstancing.nOpenJiGuan == 4) then
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
	GeneralProcess:StartProcess("Đang mở...", 5 * 18, {self.OnOpen, self, him.dwId, me.nId, tbInstancing}, {me.Msg, "Mở gián đoạn"}, tbEvent);
end;

function tbJiGuan:OnOpen(dwNpcId, nPlayerId, tbInstancing)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	local pNpc = KNpc.GetById(dwNpcId);
	if (not pPlayer or not pNpc) then
		return;
	end;
	
	if (tbInstancing.nOpenJiGuan >= 4) then
		return;
	end;
	
	local tbNpcData = pNpc.GetTempTable("Task"); 
	assert(tbNpcData);

	if (tbNpcData.nNo ~= (tbInstancing.nOpenJiGuan + 1)) then
		local tbPlayList, _ = KPlayer.GetMapPlayer(tbInstancing.nMapId);
		for _, teammate in ipairs(tbPlayList) do
			Task.tbArmyCampInstancingManager:ShowTip(teammate, "Thứ tự mở không đúng, hãy bắt đầu lại!");
			teammate.Msg("Thứ tự mở không đúng, hãy bắt đầu lại!");
		end;
		tbInstancing.nOpenJiGuan = 0;
		return;
	end;
	
	tbInstancing.nOpenJiGuan = tbInstancing.nOpenJiGuan + 1;
	pPlayer.Msg("Mở thành công!");
	
	if (tbInstancing.nOpenJiGuan == 4) then
		local tbPlayList, _ = KPlayer.GetMapPlayer(tbInstancing.nMapId);
		for _, teammate in ipairs(tbPlayList) do
			teammate.NewWorld(tbInstancing.nMapId, 58880 / 32, 102688 / 32);
			tbInstancing:OnCoverBegin(teammate);
			teammate.SetFightState(1);
			
			Setting:SetGlobalObj(teammate);
			TaskAct:Talk(self.szText);
			Setting:RestoreGlobalObj();		
		end;	
			
		-- 猜点NPC
		KNpc.Add2(4224, 120, -1, tbInstancing.nMapId, 58912 / 32, 102752 / 32);
	end;
end;

-- 一层指引
local tbZhiYin = Npc:GetClass("hl_yindao1");

tbZhiYin.szDesc = "一层指引";

tbZhiYin.szText = "写给后来的人们：\n    找到四面的擎天柱，按照<color=red>风，林，火，山<color>的顺序开启，游龙会降临，按照他的指示，猜出三个密码，就会出现下层的通道，但是，<color=red>猜对的人将会付出代价<color>。"

tbZhiYin.szDianShu = "猜点游戏规则：\n    1， 首先由系统在规定范围内之间随机挑一个数字（三轮的范围分别是6-36，5-30，4-24）。\n    2， 玩家轮流报数，第一个玩家从最小的数字开始报，以第一轮为例，可以报6，67，678，三种选择方式，如果报数中没有系统选定的数字，则安全Bỏ qua。第二个玩家延续第一个玩家的报数顺序往下报，也是三种选择，以此类推如果有一位玩家的报数与系统挑中的数字相同，那么他就输掉了比赛。\n    3， 在数字的三种组合选择之外，玩家还可以选择Bỏ qua和Trở về，顾名思义，觉得下个数字危险，选择Bỏ qua下家不报数，或者Trở về给上家报数，将报数的顺序逆过来。在一局比赛中，玩家只能选择一次Bỏ qua或者Trở về，使用之后，这两个选项将不会在面板中出现。\n    4， 当一个玩家猜中倒霉数字，则被标记为输掉本轮比赛。待到三轮结束后，按照综合成绩颁发奖励，一次未输者奖励最高。";

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

-- 一层开BOSS2机关
local tbJiGuan = Npc:GetClass("hl_round2");

tbJiGuan.szDesc = "一层开BOSS2开关";
tbJiGuan.szText = "<npc=4182>：我闻到了活人的味道，我的宝刀已经好久没有尝过鲜血了。"
tbJiGuan.EFFECT_NPC	= 2976

function tbJiGuan:OnDialog()
	local nMapId, _, _ = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nMapId);

	if (not tbInstancing or tbInstancing.nBoss2Out ~= 0) then
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
	if (not pNpc) then
		return;
	end;
	
	local nMapId, nPosX, nPosY	= pNpc.GetWorldPos();
	pNpc.Delete();
	
	local pNpc = KNpc.Add2(self.EFFECT_NPC, 10, -1, tbInstancing.nMapId, nPosX, nPosY);
	Timer:Register(5 * Env.GAME_FPS, self.CallBoss, self, nMapId, pNpc.dwId);
end;

function tbJiGuan:CallBoss(nMapId, nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc) then
		return 0;	
	end;

	local nMapId, nPosX, nPosY	= pNpc.GetWorldPos();
	pNpc.Delete();
		
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nMapId);
	if (not tbInstancing or tbInstancing.nBoss2Out == 1) then
		return 0;
	end;
		
	local pNpc = KNpc.Add2(4182, tbInstancing.nNpcLevel, -1, nMapId, nPosX, nPosY);
	pNpc.CastSkill(1163, 10, -1, pNpc.nIndex);
	for i = 1, 9 do
		pNpc.AddLifePObserver(i * 10);
	end;
	tbInstancing.nBoss2Out = 1;	
	return 0;
end;

local tbBoss2 = Npc:GetClass("hl_boss2");

tbBoss2.szDesc = "BOSS2"
tbBoss2.tbText = {
			[90] = "不许你们扰乱主人休息，去死吧。",
			[80] = "金国第一刀客可不是浪得虚名的。",
			[70] = "没有人能够Bỏ qua这里，没有人。",
			[60] = "我烧，我烧，我烧烧烧。",
			[50] = "今晚加个菜，我要把你们变成烧烤的野味。",
			[40] = "入侵者，格杀勿论。",
			[30] = "我要出全力了，看招。。",
			[20] = "能把我逼到如此地步，还是第一次。",
			[10] = "完颜不破时刻守护在主人身边。",
			[0]  = "<npc=4182>：你们赢了，过去吧，希望你们把这些力量用在正义的事业上，大地母亲与你同在。",
	}
function tbBoss2:OnLifePercentReduceHere(nLifePercent)	
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

function tbBoss2:OnDeath(pNpc)
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	
	tbInstancing.nTrap4Pass = 1;
	
	local tbPlayList, _ = KPlayer.GetMapPlayer(nSubWorld);
	for _, teammate in ipairs(tbPlayList) do
		Setting:SetGlobalObj(teammate);
		TaskAct:Talk(self.tbText[0]);
		Setting:RestoreGlobalObj();
	end;
	
	local pNpc = KNpc.Add2(4151, 120, -1, tbInstancing.nMapId, 56192 / 32, 110528 / 32);
	pNpc.szName = "";
end;

local tbSend1 = Npc:GetClass("hl_ceng1send");

tbSend1.szDesc 		= "猜数字1后的传送门"
tbSend1.tbSendPos 	= {1788, 3293}; 

function tbSend1:OnDialog()
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	
	Dialog:Say("是否传送？", 
		{"好", self.Enter, self, me.nId, tbInstancing},
		{"暂时不去"})
end;

function tbSend1:Enter(nPlayerId, tbInstancing)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end;
	
	me.NewWorld(tbInstancing.nMapId, self.tbSendPos[1], self.tbSendPos[2]);
end;