-- 答题npc
local tbNpcQuestion = Npc:GetClass("elunheyuan_question");
tbNpcQuestion.nPassAnswerNum = 5;	-- 答对五题就可通关
tbNpcQuestion.nCallTeamateSepTime = 45; -- 每45秒可以召唤一个队友进来
tbNpcQuestion.tbQuestion = {};
function tbNpcQuestion:LoadQuestion()
	self.tbQuestion = {};
	local tbFile = Lib:LoadTabFile("\\setting\\task\\armycamp\\elunheyuan\\question.txt");
	assert(tbFile);
	for nIndex, tbTemp in ipairs(tbFile) do
		table.insert(self.tbQuestion, tbTemp);
	end
end
-- 启动加载题库
tbNpcQuestion:LoadQuestion();
function tbNpcQuestion:OnDialog()
	local nSubWorld = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	-- 上一关打完才能开启下一关
	if tbInstancing.tbTollgateReset[5] ~= 2 then
		Dialog:Say("先打败了木华黎再来找我吧。");
		return;
	end
	local tbOpt = {};
	local szMsg = "";
	-- 第一个对话的人开启该关卡
	if tbInstancing.tbTollgateReset[6] == 1 then
		szMsg = "确定要挑战可汗吗？确定我会把你的队友都传送过来，回答正确我的问题就可以进入挑战";
		table.insert(tbOpt, 1, {"开始挑战", self.OpenTollgate, self, him.dwId});
	elseif tbInstancing.tbTollgateReset[6] == 2 then
		szMsg = "你们连大汗都打败了，真了不起";
	elseif tbInstancing.tbTollgateReset[6] == 0 then
		local nFlag = 0; -- 是否在参赛列表中
		if tbInstancing.tbAttendPlayerList[me.nId] == 1 and tbInstancing.tbKehandazhang.tbEnterDazhangList[me.nId] ~= 1 then -- 再参赛列表中
			table.insert(tbOpt, 1, {"开始答题", self.StartQuestion, self, him.dwId, 0});
			szMsg = "只有累积答对5题才可以进入哦";
		else -- 中途进来的或者死亡了下线重新登录的
			szMsg = "我可记得你们当初有多少人来参战，先等着吧，等你的队友挑战成功之后才能进入";
		end
	end
	tbOpt[#tbOpt+1] = {"我只是路过"}; 
	Dialog:Say(szMsg, tbOpt);
end

function tbNpcQuestion:OpenTollgate(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return;
	end
	local nSubWorld = pNpc.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if tbInstancing.tbTollgateReset[6] == 2 then
		return;
	end
	-- 将玩家都传到指定位置，地图内的所有玩家都加入到参赛列表中
	if tbInstancing.tbTollgateReset[6] == 1 then
		tbInstancing:ChangeTollgateState(6,0);
		local tbPlayList, _ = KPlayer.GetMapPlayer(nSubWorld);
		for _, teammate in ipairs(tbPlayList) do
			if teammate.nId ~= me.nId then
				teammate.NewWorld(nSubWorld, 1702, 3251);
			end
			tbInstancing.tbAttendPlayerList[teammate.nId] = 1;
			teammate.SetFightState(0);
			Setting:SetGlobalObj(teammate);
			TaskAct:Talk("<npc=9966>：“答对了我的问题才能进入哦”");
			Setting:RestoreGlobalObj();
		end
		tbInstancing.tbKehandazhang.nCallTeamateTime = GetTime();
	elseif tbInstancing.tbTollgateReset[6] == 0 then
		Dialog:Say("你的队友已经开启关卡了");
	end
end

-- 答题，step：第几轮, answerid:第几个答案
function tbNpcQuestion:StartQuestion(nNpcId, nStep, nQuestionId, nAnswerId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return;
	end
	local nSubWorld = pNpc.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if tbInstancing.tbKehandazhang.tbEnterDazhangList[me.nId] == 1 then
		return;
	end
	local szMsg = "";
	-- 正常答题
	if nStep > 0 then
		if not self.tbQuestion[nQuestionId] then
			return;
		end
		if tonumber(self.tbQuestion[nQuestionId]["RIGHT"]) == nAnswerId then
			szMsg = string.format("恭喜你答对了，你已经累积答对了%s题", nStep);
			nStep = nStep + 1;
		else
			szMsg = string.format("太可惜了，答错了哦，你已经累积答对了%s题", nStep-1);
		end
	else
		nStep = 1;
	end
	if nStep > self.nPassAnswerNum then -- 答对了五题通关
		tbInstancing.tbKehandazhang.tbEnterDazhangList[me.nId] = 1;
		me.NewWorld(nSubWorld, 1719, 3218);
		TaskAct:Talk("<npc=9975>：“哦？这就是我们的勇士么。能得到上上下下一众人等的赞赏，不愧是有勇有谋的俊杰。没能亲眼看到你们的表现实在是太遗憾了。不如这样，拖雷，你来跟勇士们比斗一番，也让本汗感受一下勇士的风采！“");
		Dialog:SendBlackBoardMsg(me, "Ngươi cũng khá hiểu biết, ta cho phép qua");
		self:AllComeIn(tbInstancing)
	else
		local nRand = MathRandom(#self.tbQuestion);
		local tbFlag = {"A", "B", "C"};
		local tbOpt = {};
		for i = 1, 3 do
			tbOpt[i] = {string.format("%s %s", tbFlag[i], self.tbQuestion[nRand]["ANSWER"..i]), self.StartQuestion, self, nNpcId, nStep, nRand, i};
		end
		szMsg = string.format("%s\n%s", szMsg, self.tbQuestion[nRand]["TITLE"]);
		Dialog:Say(szMsg, tbOpt);
	end
	
end

function tbNpcQuestion:TalkEnd(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		Task.tbArmyCampInstancingManager:ShowTip(pPlayer, "Đà Lôi nhận lệnh ra ứng phó", 15);
		pPlayer.Msg("Đà Lôi nhận lệnh ra ứng phó");
	end
end

function tbNpcQuestion:AllComeIn(tbInstancing)
	local nAllComein = 1;
	for nPlayerId, _ in pairs(tbInstancing.tbAttendPlayerList) do
		if not tbInstancing.tbKehandazhang.tbEnterDazhangList[nPlayerId] then
			nAllComein = 0;
			break;
		end
	end
	-- 全部人进入了帐内放个剧情
	if nAllComein == 1 then
		for nPlayerId, _ in pairs(tbInstancing.tbAttendPlayerList) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				Setting:SetGlobalObj(pPlayer);
				TaskAct:Talk("<npc=9975>：“哦？这就是我们的勇士么。拖雷，你来跟勇士们比斗一番，看看是否是真才实学。”", self.TalkEnd, self, nPlayerId);
				Setting:RestoreGlobalObj();
			end
		end
	end
end

function tbNpcQuestion:CallTeamate(nNpcId, nPlayerId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	local nSubWorld = pNpc.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if tbInstancing.tbTollgateReset[6] ~= 0 then
		return 0;
	end
	if tbInstancing.tbKehandazhang.tbEnterDazhangList[nPlayerId] then
		return 0;
	end
	if GetTime() >= tbInstancing.tbKehandazhang.nCallTeamateTime + self.nCallTeamateSepTime then
		tbInstancing.tbKehandazhang.nCallTeamateTime = GetTime();
		tbInstancing.tbKehandazhang.tbEnterDazhangList[nPlayerId] = 1;
		pPlayer.NewWorld(nSubWorld, 1719, 3218);
		tbInstancing:SendPrompt(string.format("Đồng đội [%s] được triệu hồi", pPlayer.szName), 0, 1, 0, 0);
		Dialog:SendBlackBoardMsg(pPlayer, "Được đồng đội triệu hồi!");
		self:AllComeIn(tbInstancing);
	else
		Dialog:Say("Cứ mỗi 45 giây sẽ triệu hồi được 1 đồng đội!");
	end
end

-- 对话托雷
local tbNpcTuolei_Dialog = Npc:GetClass("elunheyuan_dlg_tuolei");
tbNpcTuolei_Dialog.tbWineName = {"Hạnh Hoa Thôn", "Đạo Hương Thôn", "Tây Bắc Vọng", "Đỗ Khang"};
function tbNpcTuolei_Dialog:OnDialog()
	local nSubWorld = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if tbInstancing.tbTollgateReset[6] ~= 0 then
		Dialog:Say(string.format("%s：%s, xin chào!！", him.szName, me.szName));
		return;
	end
	local tbNpcData = him.GetTempTable("Task"); 
	if tbNpcData.nFailure == 1 then
		if tbNpcData.nDrinkState == 1 then
			local szDrinkMsg = "";
			for i = 1, #tbInstancing.tbKehandazhang.tbWineOrder do
				szDrinkMsg = szDrinkMsg .. self.tbWineName[tbInstancing.tbKehandazhang.tbWineOrder[i]];
				if i ~= #tbInstancing.tbKehandazhang.tbWineOrder then
					szDrinkMsg = szDrinkMsg .. ", ";
				end
			end
			szDrinkMsg = string.format("Ngươi cần uống theo thứ tự %s để thưởng thức hương vị thực sự của rượu!", szDrinkMsg);
			Dialog:Say(szDrinkMsg);
		else
			Dialog:Say("Các ngươi đúng là có chút bản lĩnh.");
		end
		return;
	end
	-- 检查是否全部玩家都已经进入大帐
	for nPlayerId, _ in pairs(tbInstancing.tbAttendPlayerList) do
		if not tbInstancing.tbKehandazhang.tbEnterDazhangList[nPlayerId] then
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				local szMsg = string.format("Đồng đội [%s] vẫn chưa kịp đến, khi cả nhóm tập trung mới có thể khiêu chiến", pPlayer.szName);
				local tbOpt = {
					{"Triệu hồi đồng đội", tbNpcQuestion.CallTeamate, tbNpcQuestion, him.dwId, nPlayerId},
					{"Để ta suy nghĩ thêm"}};
				Dialog:Say(szMsg, tbOpt);
				return;
			end
		end
	end
	local szMsg = "Hảo hán sao? Hãy ứng chiến đi!";
	local tbOpt = {
		{"Khiêu chiến", self.StartFight, self, me.nId, him.dwId},
		{"Ta chỉ xem qua"}
		};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpcTuolei_Dialog:StartFight(nPlayerId, nNpcId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	local pNpc = KNpc.GetById(nNpcId);
	if (not pPlayer or not pNpc) then
		return;
	end
	local nSubWorld, nPosX, nPosY = pNpc.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if tbInstancing.tbTollgateReset[6] ~= 0 then
		return;
	end
	-- 出现特效
	local pEffectNpc = KNpc.Add2(2976, 10, -1, nSubWorld, 1725, 3223);
	assert(pEffectNpc);
	tbInstancing:ChangeTollgateState(6,0);
	pNpc.Delete();
	tbInstancing.tbKehandazhang.nNpcTuolei_Dialog = nil;
	Timer:Register(5 * Env.GAME_FPS, self.CallBoss, self, pEffectNpc.dwId);
	for nPlayerId, nFlag in pairs(tbInstancing.tbAttendPlayerList) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			pPlayer.NewWorld(nSubWorld, 1726, 3222);
			pPlayer.SetFightState(1);
			pPlayer.Msg("Hạ gục Đà Lôi và Thiết Mộc Chân");
			Setting:SetGlobalObj(pPlayer);
			TaskAct:Talk("<npc=9968>：“来吧”");
			Setting:RestoreGlobalObj();
		end
	end
end

function tbNpcTuolei_Dialog:CallBoss(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc) then
		return 0;
	end
	local nSubWorld, nX, nY = pNpc.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		return 0;
	end
	local pBoss = KNpc.Add2(9968, tbInstancing.nNpcLevel, -1, nSubWorld, nX, nY);
	if pBoss then
		pNpc.Delete();
		tbInstancing.tbKehandazhang.nNpcTuolei_Fight = pBoss.dwId;
		local tbFightNpc = Npc:GetClass("elunheyuan_fight_tuolei");
		-- boss技能
		Timer:Register(tbFightNpc.nCallSoldierTime, tbFightNpc.CallSoldier, tbFightNpc, pBoss.dwId);
		Timer:Register(20 * Env.GAME_FPS, tbFightNpc.SaySomething, tbFightNpc, pBoss.dwId, tbFightNpc.tbText);
	else
		return Env.GAME_FPS; 
	end
	return 0;
end

-- 战斗托雷
local tbNpcTuolei_Fight = Npc:GetClass("elunheyuan_fight_tuolei");
tbNpcTuolei_Fight.tbWinePos = {{1721,3221}, {1728,3228}, {1734,3221}, {1727,3215}};
tbNpcTuolei_Fight.tbWineId = {9970, 9971, 9972, 9973};
tbNpcTuolei_Fight.nDrinkTime = 50 * 18; -- 喝酒的时间
tbNpcTuolei_Fight.nCallSoldierTime = 180;	-- 召唤小兵的间隔
tbNpcTuolei_Fight.tbCallSoldierInfo = {
	-- npcid, npc走到之后释放的技能id
	[1] = {9977, 2515, 6, "取我刀来"},
	[2] = {9978, 2517, 1, "取我弓来"},
	[3] = {9979, 2518, 1, "取我枪来"},
	};
tbNpcTuolei_Fight.tbText = {
	"身为草原上的男儿，当然要英勇善战！既然英勇善战，自然要精通各种兵器！",
	"多年没有看到你们这样的勇士了，机会难得！来，战个痛快！<pic=25>",
	"兵器换得勤，并不是因为质量差。主要是总用一样的兵器实在很是无趣<pic=29>",
	"父汗就在上面看着，拿出你们的真本事来！",
	"你们！不要乱碰我的兵器！<pic=6>",
};
tbNpcTuolei_Fight.tbSoldierPos = {{1697, 3222}, {1719, 3192}, {1724, 3250}, {1742, 3217}};

-- boss喊喊话
function tbNpcTuolei_Fight:SaySomething(nNpcId, tbText)
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
	nIndex = math.mod(nIndex + 1, #tbText) + 1;
	tbInstancing:NpcSay(nNpcId, tbText[nIndex]);
	pNpc.GetTempTable("Task").nPromptIndex = nIndex;
end

function tbNpcTuolei_Fight:OnDeath(pKiller)
	local nSubWorld = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if him.dwId ~= tbInstancing.tbKehandazhang.nNpcTuolei_Fight then
		return;
	end
	if tbInstancing.tbTollgateReset[6] ~= 0 then
		return;
	end
	for nNpcId, _ in pairs(tbInstancing.tbKehandazhang.tbNpcSoldierInfo) do
		tbInstancing:DeleteNpc(nNpcId);
	end
	tbInstancing.tbKehandazhang.tbNpcSoldierInfo = {};
	local szDrinkMsg = "";
	-- 添加观战npc
	local pNpc = KNpc.Add2(9967, 110, -1, nSubWorld, 1718, 3216);
	if pNpc then
		tbInstancing.tbKehandazhang.nNpcTuolei_Dialog = pNpc.dwId;
		local tbNpcData = pNpc.GetTempTable("Task"); 
		tbNpcData.nFailure = 1; -- 战败的npc
		tbNpcData.nDrinkState = 1; -- 是否在喝酒阶段
		szDrinkMsg = "Uống rượu thì phải hỏi ta... Ha ha..."; 
		pNpc.SendChat(szDrinkMsg);
		tbNpcData.nChatTimer = Timer:Register(5*Env.GAME_FPS, self.DrinkChat, self, pNpc.dwId, szDrinkMsg);
		pNpc.SendChat(szDrinkMsg);
	end
	for nPlayerId, nFlag in pairs(tbInstancing.tbAttendPlayerList) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			Setting:SetGlobalObj(pPlayer);
			TaskAct:Talk("<npc=9975>：“好，果然是一等一的勇士！来人，上我们最好的美酒，我要和勇士们共饮！”")
			Setting:RestoreGlobalObj();
			pPlayer.Msg("Nếu không uống theo thứ tự sẽ khó chống lại Thiết Mộc Chân");
		end
	end
	-- 开启饮酒，过一分钟自动进入战斗
	for i = 1, #self.tbWineId do
		local pNpcWine = KNpc.Add2(self.tbWineId[i], 110, -1, nSubWorld, self.tbWinePos[i][1], self.tbWinePos[i][2]);
		if pNpcWine then
			table.insert(tbInstancing.tbKehandazhang.tbNpcWineId, pNpcWine.dwId);
		end
	end
	local tbNpcTiemuzhen_Dialog = Npc:GetClass("elunheyuan_dlg_tiemuzhen")
	tbInstancing.tbKehandazhang.nDrinkTimerId = Timer:Register(self.nDrinkTime, tbNpcTiemuzhen_Dialog.StartFight, tbNpcTiemuzhen_Dialog, tbInstancing.tbKehandazhang.nNpcTiemuzhen_Dialog);
	for nPlayerId, nFlag in pairs(tbInstancing.tbAttendPlayerList) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			-- 打开喝酒倒计时
			local szTimeMsg =  "<color=green>\nThời gian nếm rượu: <color> <color=white>%s<color>";
			Dialog:SetBattleTimer(pPlayer, szTimeMsg, self.nDrinkTime);
			Dialog:SendBattleMsg(pPlayer, "");
			Dialog:ShowBattleMsg(pPlayer, 1, 0);
			pPlayer.Msg("Tham khảo thứ tự uống tại Đà Lôi.");
		end
	end
	local pKillerPlayer = pKiller.GetPlayer();
	if not pKillerPlayer then
		return 0;
	end
	tbInstancing.tbKehandazhang.nKillTuoleiPlayerId = pKillerPlayer.nId;
end

function tbNpcTuolei_Fight:DrinkChat(nNpcId, szMsg)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local tbNpcData = pNpc.GetTempTable("Task"); 
	if tbNpcData.nDrinkState ~= 1 then
		return 0;
	end
	pNpc.SendChat(szMsg);
end

function tbNpcTuolei_Fight:CallSoldier(nBossId)
	local pBoss = KNpc.GetById(nBossId);
	if not pBoss then
		return 0;
	end
	local nSubWorld, nPosX, nPosY = pBoss.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		return 0;
	end
	if pBoss.GetTempTable("Task").nCallSoldierPrompt ~= 1 then
		pBoss.GetTempTable("Task").nCallSoldierPrompt = 1;
		tbInstancing:SendPrompt("Ngăn cản binh lính đến gần kiếp nổ!", 0, 1, 1, 0);
	end
	local nRand = MathRandom(#self.tbCallSoldierInfo);
	local nPosRand = MathRandom(#self.tbSoldierPos);
	local pSoldier = KNpc.Add2(self.tbCallSoldierInfo[nRand][1], tbInstancing.nNpcLevel, -1, nSubWorld, self.tbSoldierPos[nPosRand][1], self.tbSoldierPos[nPosRand][2]);
	if pSoldier then
		tbInstancing.tbKehandazhang.tbNpcSoldierInfo[pSoldier.dwId] = nRand;
		pSoldier.SetActiveForever(1);
		pSoldier.GetTempTable("Npc").tbOnArrive = {self.OnSoldierArrive, self, nBossId, pSoldier.dwId};
		pSoldier.AI_ClearPath();
		pSoldier.AI_AddMovePos(1725*32, 3223*32);
		pSoldier.SetNpcAI(9, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0);
		pBoss.SendChat(self.tbCallSoldierInfo[nRand][4]);
	end
end

function tbNpcTuolei_Fight:OnSoldierArrive(nBossId, nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	pNpc.Delete();
	local pBoss = KNpc.GetById(nBossId);
	if not pBoss then
		return 0;
	end
	local nSubWorld, nPosX, nPosY = pBoss.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		return 0;
	end
	local nType = tbInstancing.tbKehandazhang.tbNpcSoldierInfo[nNpcId];
	if not nType then
		return 0;
	end
	tbInstancing.tbKehandazhang.tbNpcSoldierInfo[nNpcId] = nil;-- 从索引中删除
	local tbPlayerList = KNpc.GetAroundPlayerList(nBossId, 1000);
	for _, pPlayer in ipairs(tbPlayerList) do
		if pPlayer.IsDead() ~= 1 then
			pBoss.CastSkill(self.tbCallSoldierInfo[nType][2], self.tbCallSoldierInfo[nType][3], -1, pPlayer.GetNpc().nIndex);
			break;
		end
	end
	return 0;
end

-- 对话铁木真
local tbNpcTiemuzhen_Dialog = Npc:GetClass("elunheyuan_dlg_tiemuzhen");

function tbNpcTiemuzhen_Dialog:OnDialog()
	local nSubWorld, nPosX, nPosY = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if tbInstancing.tbTollgateReset[6] == 2 then
		Dialog:Say("  其实我早就知道你们是来探究蒙古军队的，你们都是热血好汉，豪爽热情，希望你们能成为蒙古人的朋友。");
	elseif tbInstancing.tbTollgateReset[6] == 0 then
		Dialog:Say("只要你们打败了托雷，品尝了我们草原的美酒，我会亲自会会你们。");
	else
		Dialog:Say(string.format("%s：%s, xin chào!", him.szName, me.szName));
	end
end

function tbNpcTiemuzhen_Dialog:StartFight(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local nSubWorld, nPosX, nPosY = pNpc.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		return 0;
	end
	local pTuoLei = KNpc.GetById(tbInstancing.tbKehandazhang.nNpcTuolei_Dialog);
	if pTuoLei then
		pTuoLei.GetTempTable("Task").nDrinkState = 0;
	end
	tbInstancing.tbKehandazhang.nDrinkTimerId = nil;
	if tbInstancing.tbTollgateReset[6] ~= 0 then
		return 0;
	end
	-- 先把酒坛子删了
	for _, nNpcWineId in ipairs(tbInstancing.tbKehandazhang.tbNpcWineId) do
		tbInstancing:DeleteNpc(nNpcWineId);
	end
	tbInstancing.tbKehandazhang.tbWineId = {};
	-- 出现特效
	local pEffectNpc = KNpc.Add2(2976, 10, -1, nSubWorld, 1725, 3223);
	if not pEffectNpc then
		return 0;
	end
	pNpc.Delete();
	tbInstancing.tbKehandazhang.nNpcTiemuzhen_Dialog = nil;
	Timer:Register(5 * Env.GAME_FPS, self.CallBoss, self, pEffectNpc.dwId);
	for nPlayerId, nFlag in pairs(tbInstancing.tbAttendPlayerList) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			Setting:SetGlobalObj(pPlayer);
			TaskAct:Talk("<npc=9975>：“不错，真的不错，好一个威武的————大宋勇士！不用试图分辨，在草原上欺骗是会遭到天罚的。无论你们到这里所欲何为，腾格里敬重勇士，我给你们一个生的机会。战胜我，你们可以回去见自己的父母亲人！不然，就给草原留下几道勇士之魂吧！”");
			Setting:RestoreGlobalObj();
			Dialog:ShowBattleMsg(pPlayer, 0, 0);
		end
	end
	return 0;
end

function tbNpcTiemuzhen_Dialog:CallBoss(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc) then
		return 0;
	end
	local nSubWorld, nX, nY = pNpc.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		return 0;
	end
	local pBoss = KNpc.Add2(9975, tbInstancing.nNpcLevel, -1, nSubWorld, nX, nY);
	if pBoss then
		pNpc.Delete();
		tbInstancing.tbKehandazhang.nNpcTiemuzhen_Fight = pBoss.dwId;
		-- 70%血量就可以通关了
		pBoss.AddLifePObserver(70);
		pBoss.AddLifePObserver(90);
		pBoss.AddLifePObserver(80);
		-- boss技能
		local tbFightNpcTuolei = Npc:GetClass("elunheyuan_fight_tuolei");
		local tbFightNpcTiemuzhen = Npc:GetClass("elunheyuan_fight_tiemuzhen");
		Timer:Register(20 * Env.GAME_FPS, tbFightNpcTuolei.SaySomething, tbFightNpcTuolei, pBoss.dwId, tbFightNpcTiemuzhen.tbText);
	else
		return Env.GAME_FPS; 
	end
	return 0;
end

-- 喝酒回调
function tbNpcTiemuzhen_Dialog:OnDrink(nPlayerId, nNpcId, nType)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return;
	end
	local nMapId = pNpc.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nMapId);
	assert(tbInstancing);
	if not tbInstancing.tbAttendPlayerList[nPlayerId] then
		return;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	tbInstancing.tbKehandazhang.tbPlayerDrinkInfo[nPlayerId] = tbInstancing.tbKehandazhang.tbPlayerDrinkInfo[nPlayerId] or {};
	if #tbInstancing.tbKehandazhang.tbPlayerDrinkInfo[nPlayerId] == #tbInstancing.tbKehandazhang.tbWineOrder then
		Dialog:SendBlackBoardMsg(pPlayer, "Ngươi không cần uống nữa, hãy nhường phần cho người khác.");
		return;
	end
	table.insert(tbInstancing.tbKehandazhang.tbPlayerDrinkInfo[nPlayerId], nType);
	-- 比较喝酒的顺序是否正确
	local nFlag = 1;
	for i = 1, #tbInstancing.tbKehandazhang.tbPlayerDrinkInfo[nPlayerId] do
		if tbInstancing.tbKehandazhang.tbPlayerDrinkInfo[nPlayerId][i] ~= tbInstancing.tbKehandazhang.tbWineOrder[i] then
			nFlag = 0;
			break;
		end
	end
	if nFlag == 0 then
		tbInstancing.tbKehandazhang.tbPlayerDrinkInfo[nPlayerId] = {};
		Dialog:SendBlackBoardMsg(pPlayer, "Uống không đúng thứ tự rồi!");
	else
		-- 5种酒喝完了
		if #tbInstancing.tbKehandazhang.tbPlayerDrinkInfo[nPlayerId] == #tbInstancing.tbKehandazhang.tbWineOrder then
			-- 添加一个buff
			me.AddSkillState(2677, 1, 1, 18000);
			Dialog:SendBlackBoardMsg(pPlayer,"Bạn đã uống rượu đúng cách và rất chân thành!");
			pPlayer.Msg("Bạn đã uống rượu đúng cách và rất chân thành!");
		else
			Dialog:SendBlackBoardMsg(pPlayer,"Hãy uống nào!");
			pPlayer.Msg(string.format("Bạn đã uống <color=yellow>%s<color>", pNpc.szName));
		end
	end
end

-- 战斗铁木真
local tbNpcTiemuzhen_Fight = Npc:GetClass("elunheyuan_fight_tiemuzhen");

tbNpcTiemuzhen_Fight.tbText = {
	"勇士，就是勇士，无论你来自草原，宋国，金国或者其他什么地方，在草原上，都一视同仁！",
	"无论你们到这里来是抱着什么目的，现在我都给你们机会，击败我，你们就可以活着回去！",
	"草原上以勇气为重，你已经赢得了草原人的尊敬！不过就这样放走了大宋的奸细实在太没有面子了，不是吗<pic=1>",
	"什么叫做王者之相？明忠奸，知进退，敢下手，敢担当，对子民负责。再多一个字都是无用。",	
};

function tbNpcTiemuzhen_Fight:OnLifePercentReduceHere(nLifePercent)
	local nSubWorld, nX, nY = him.GetWorldPos();
	if nLifePercent == 90 or nLifePercent == 80 then
		local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
		assert(tbInstancing);
		him.SendChat("让我来测试下你的勇气！");
		for nPlayerId, nFlag in pairs(tbInstancing.tbAttendPlayerList) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer and pPlayer.IsDead() ~= 1 then
				pPlayer.Msg("果然没有喝酒就没有直面成吉思汗的勇气啊！");
			end
		end
		him.CastSkill(2676, 20, nX * 32, nY * 32);
	elseif nLifePercent == 70 then
		local nBossId = him.dwId;
		local nTemplateId = him.nTemplateId;
		him.Delete();
		local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
		assert(tbInstancing);
		if nBossId ~= tbInstancing.tbKehandazhang.nNpcTiemuzhen_Fight then
			return;
		end
		if tbInstancing.tbTollgateReset[6] ~= 0 then
			return;
		end
		tbInstancing:ChangeTollgateState(6, 2);
		local nKillerPlayerId = nil;
		local tbAttendList = {}; -- 参与了这关的玩家
		-- 从参与了最后一关的玩家中选择一个开机关
		for nPlayerId, _ in pairs(tbInstancing.tbAttendPlayerList) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				tbAttendList[#tbAttendList + 1] = nPlayerId;
				if tbInstancing.tbKehandazhang.nKillTuoleiPlayerId == nPlayerId then
					nKillerPlayerId = nPlayerId;
				end
			end
		end
		
		tbInstancing.tbAttendPlayerList = {};
		local tbPlayList, nCount = KPlayer.GetMapPlayer(nSubWorld);
		for _, teammate in ipairs(tbPlayList) do
			teammate.SetTask(1025, 60, 1);
			if (teammate.IsDead() == 1) then
				teammate.ReviveImmediately(1);
			end
			if teammate.GetSkillState(2677) > 0 then
				teammate.RemoveSkillState(2677);
			end
			teammate.SetTask(1025, 73, 1);
			teammate.SetFightState(0);
			Setting:SetGlobalObj(teammate);
			TaskAct:Talk("铁木真在占尽上风时突然收手，并下令让我们安全离去。此间发生的一应事宜需得尽速回去禀报。");
			Setting:RestoreGlobalObj();
		end
		tbInstancing.tbKehandazhang.nNpcTiemuzhen_Fight = nil;
		-- 添加对话的铁木真
		local pNpc = KNpc.Add2(9969, 110, -1, nSubWorld, 1747, 3199);
		if pNpc then
			tbInstancing.tbKehandazhang.nNpcTiemuzhen_Dialog = pNpc.dwId;
			local tbNpcData = pNpc.GetTempTable("Task"); 
			tbNpcData.nFailure = 1; -- 挑战失败的npc
		end
	
		-- 添加游龙真气
		local pYoulongzhenqi = KNpc.Add2(10118, 120, -1, tbInstancing.nMapId, 1736, 3215);
		if pYoulongzhenqi then
			local tbNpcYoulongzhenqi = Npc:GetClass("elunheyuan_youlongzhenqi");
			local tbNpcInfo = pYoulongzhenqi.GetTempTable("Task");
			tbNpcInfo.nAssignPlayerId = tbAttendList[MathRandom(#tbAttendList)];
			for _, teammate in ipairs(tbPlayList) do
				Task.tbArmyCampInstancingManager:ShowTip(teammate, string.format("Mời %s lựa chọn Du Long Chân Khí", KGCPlayer.GetPlayerName(tbNpcInfo.nAssignPlayerId)), 20);
				teammate.Msg(string.format("Mời %s lựa chọn Du Long Chân Khí", KGCPlayer.GetPlayerName(tbNpcInfo.nAssignPlayerId)));
			end
			tbNpcInfo.tbAwardIndex = {};
			for i = 1, #tbNpcYoulongzhenqi.tbRandOptionName do
				tbNpcInfo.tbAwardIndex[i] = i;
			end
			Lib:SmashTable(tbNpcInfo.tbAwardIndex);
			tbNpcInfo.nTimerId = Timer:Register(tbNpcYoulongzhenqi.nAutoSelectTime * Env.GAME_FPS, tbNpcYoulongzhenqi.SwitchAward, tbNpcYoulongzhenqi, pYoulongzhenqi.dwId, tbNpcInfo.nAssignPlayerId, MathRandom(#tbNpcYoulongzhenqi.tbRandOptionName));
		end
		
		--------军营常规完成设置-------------
		-- 用于老玩家召回任务完成任务记录
		for _, player in ipairs(tbPlayList) do 
			Task.OldPlayerTask:AddPlayerTaskValue(player.nId, 2082, 4);
		end;
		local pPlayer = tbPlayList[1];	
		-- 增加队长的领袖荣誉
		local tbHonor = {[3] = 24, [4] = 36, [5] = 48, [6] = 60}; -- 3、4、5、6人队长的领袖荣誉表
		local tbTeamPlayer, _ = KTeam.GetTeamMemberList(pPlayer.nTeamId);
		local _, nCount = KPlayer.GetMapPlayer(tbInstancing.nMapId);	
		if tbHonor[nCount] and tbTeamPlayer then
			PlayerHonor:AddPlayerHonorById_GS(tbTeamPlayer[1], PlayerHonor.HONOR_CLASS_LINGXIU, 0, tbHonor[nCount]);
		end
		-- 完成无尽的征程
		for _, player in ipairs(tbPlayList) do 
			local tbPlayerTasks	= Task:GetPlayerTask(player).tbTasks;
			local tbTask1 = tbPlayerTasks[490];
			if tbTask1 and tbTask1.nReferId == 703 then
				player.SetTask(1025, 68, player.GetTask(1025, 68) + 1);
			end;
			
			-- 额外奖励回调
			local nFreeCount, tbFunExecute = SpecialEvent.ExtendAward:DoCheck("ArmyCampBoss", player);
			SpecialEvent.ExtendAward:DoExecute(tbFunExecute);
			
			--通过军营累积次数
			local nTimes = player.GetTask(SpecialEvent.tbPJoinEventTimes.TASKGID, SpecialEvent.tbPJoinEventTimes.TASK_OVER_ARMY);
			player.SetTask(SpecialEvent.tbPJoinEventTimes.TASKGID, SpecialEvent.tbPJoinEventTimes.TASK_OVER_ARMY, nTimes + 1);
			
			-- 成就，通过额仑河源
			Achievement:FinishAchievement(player, 481);
			Achievement:FinishAchievement(player, 482);
			-- 记录杀死boss的log
			StatLog:WriteStatLog("stat_info", "junying", "killboss", player.nId, player.GetHonorLevel(), pPlayer.nTeamId, nTemplateId, tbInstancing.szOpenTime);
			
			-- 完成军营任务记录次数
			Player:AddJoinRecord_DailyCount(player, Player.EVENT_JOIN_RECORD_JUNYINGRENWU, 1);
			
			SpecialEvent.ActiveGift:AddCounts(player, 26);		--完成军营活跃度
			SpecialEvent.BuyOver:AddCounts(pPlayer, SpecialEvent.BuyOver.TASK_QUANDOANH);
			if TimeFrame:GetState("Keyimen") == 1 then
				Item:ActiveDragonBall(player);
			end
		end
		if nKillerPlayerId then
			local pKillerPlayer = KPlayer.GetPlayerObjById(nKillerPlayerId);
			if pKillerPlayer then
				Achievement:FinishAchievement(pKillerPlayer, 486);
			end
		end
	end
end

function tbNpcTiemuzhen_Fight:OnDeath(pKiller)
	-- 如果血量触发没走到
	self:OnLifePercentReduceHere(70);
end

-- 五种酒
local tbNpcWine1 = Npc:GetClass("elunheyuan_wine1");

function tbNpcWine1:OnDialog()
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
	GeneralProcess:StartProcess("Đang nếm thử", 2 * Env.GAME_FPS, 
			{tbNpcTiemuzhen_Dialog.OnDrink, tbNpcTiemuzhen_Dialog, me.nId, him.dwId, 1}, 
			nil, 
			tbEvent);
end

local tbNpcWine2 = Npc:GetClass("elunheyuan_wine2");

function tbNpcWine2:OnDialog()
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
	GeneralProcess:StartProcess("Đang nếm thử", 2 * Env.GAME_FPS, 
			{tbNpcTiemuzhen_Dialog.OnDrink, tbNpcTiemuzhen_Dialog, me.nId, him.dwId, 2}, 
			nil, 
			tbEvent);
end

local tbNpcWine3 = Npc:GetClass("elunheyuan_wine3");

function tbNpcWine3:OnDialog()
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
	GeneralProcess:StartProcess("Đang nếm thử", 2 * Env.GAME_FPS, 
			{tbNpcTiemuzhen_Dialog.OnDrink, tbNpcTiemuzhen_Dialog, me.nId, him.dwId, 3}, 
			nil, 
			tbEvent);
end

local tbNpcWine4 = Npc:GetClass("elunheyuan_wine4");

function tbNpcWine4:OnDialog()
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
	GeneralProcess:StartProcess("Đang nếm thử", 2 * Env.GAME_FPS, 
			{tbNpcTiemuzhen_Dialog.OnDrink, tbNpcTiemuzhen_Dialog, me.nId, him.dwId, 4}, 
			nil, 
			tbEvent);
end
local tbNpcWine5 = Npc:GetClass("elunheyuan_wine5");

function tbNpcWine5:OnDialog()
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
	GeneralProcess:StartProcess("Đang nếm thử", 2 * Env.GAME_FPS, 
			{tbNpcTiemuzhen_Dialog.OnDrink, tbNpcTiemuzhen_Dialog, me.nId, him.dwId, 5}, 
			nil, 
			tbEvent);
end

--托雷召唤的3种小兵
-- 士兵
local tbNpcBubing = Npc:GetClass("elunheyuan_bubing2");

function tbNpcBubing:OnDeath(pKiller)
	local nSubWorld = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	tbInstancing.tbJiaochang.tbNpcSoldierInfo[him.dwId] = nil;
end

local tbNpcGongbing = Npc:GetClass("elunheyuan_gongbing2");

function tbNpcGongbing:OnDeath(pKiller)
	local nSubWorld = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	tbInstancing.tbJiaochang.tbNpcSoldierInfo[him.dwId] = nil;
end

local tbNpcQibing = Npc:GetClass("elunheyuan_qibing2");

function tbNpcQibing:OnDeath(pKiller)
	local nSubWorld = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	tbInstancing.tbJiaochang.tbNpcSoldierInfo[him.dwId] = nil;
end

-- 游龙真气
local tbNpcYoulongzhenqi = Npc:GetClass("elunheyuan_youlongzhenqi");
-- 自动选择时间
tbNpcYoulongzhenqi.nAutoSelectTime = 40;  -- 60秒的选择等待时间
tbNpcYoulongzhenqi.tbRandOptionName = {
	[1] = "青龙",
	[2] = "白虎",
	[3] = "朱雀",
	[4] = "玄武",
	};
tbNpcYoulongzhenqi.tbAwardInfo = 
{
	[1] = {"翡翠", 4000000},
	[2] = {"黄金", 3000000},
	[3] = {"白银", 2600000},
	[4] = {"青铜", 2000000},	
};

tbNpcYoulongzhenqi.nSelectExtraAwardRand = 10; -- 被点名的玩家10%的概率额外获得个人奖励
tbNpcYoulongzhenqi.tbExtraAward = {18,1,1,10};

function tbNpcYoulongzhenqi:OnDialog()
	self:SwitchAward(him.dwId);
end

-- 定时器传回来的nSelectPlayerId，nindex必须存在且有效
function tbNpcYoulongzhenqi:SwitchAward(nNpcId, nSelectPlayerId, nIndex)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local nSubWorld = pNpc.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		return 0;
	end
	local tbNpcInfo = pNpc.GetTempTable("Task");
	if not tbNpcInfo.nAssignPlayerId or not tbNpcInfo.tbAwardIndex or #tbNpcInfo.tbAwardIndex ~= #self.tbAwardInfo then
		return 0;
	end
	-- 已经领过奖
	if tbNpcInfo.nHaveAward then
		return 0;
	end
	local tbOpt = {};
	if not nIndex then
		for i = 1, #self.tbRandOptionName do
			tbOpt[#tbOpt+1] = {self.tbRandOptionName[i], self.SwitchAward, self, nNpcId, me.nId, i};
		end
		Dialog:Say("请在青龙，白虎，朱雀，玄武四神中任意选择1项，将会获得翡翠，黄金，白银，青铜四种经验奖励中的随机1种。", tbOpt);
		return 0;
	end
	if nSelectPlayerId ~= tbNpcInfo.nAssignPlayerId then
		Dialog:Say("您不是本轮抽到的前来幸运选点的玩家。");
		return 0;
	end
	tbNpcInfo.nHaveAward = 1;
	pNpc.Delete();
	local nLevel = #self.tbAwardInfo;
	for i = 1, #self.tbAwardInfo do
		if tbNpcInfo.tbAwardIndex[i] == nIndex then
			nLevel = i;
			break;
		end
	end
	local tbPlayList, _ = KPlayer.GetMapPlayer(tbInstancing.nMapId);
	-- 地图内玩家都有能获得对应奖励
	for _, teammate in ipairs(tbPlayList) do
		teammate.AddExp(self.tbAwardInfo[nLevel][2]);
		teammate.Msg(string.format("Chúc mừng nhận được phần thưởng cấp %s và thêm %s kinh nghiệm", self.tbAwardInfo[nLevel][1], self.tbAwardInfo[nLevel][2]));
		Dialog:SendBlackBoardMsg(teammate, string.format("Chúc mừng nhận được phần thưởng cấp %s", self.tbAwardInfo[nLevel][1]));
	end
	-- 选择的玩家有几率获得额外奖励
	local pPlayer = KPlayer.GetPlayerObjById(nSelectPlayerId);
	if pPlayer then
		Achievement:FinishAchievement(pPlayer, 492);
	end
	-- 增加军营传送人
	local pNpcExit = KNpc.Add2(9976, 120, -1, tbInstancing.nMapId, 1744, 3190);
	tbInstancing:ResetXiakeBoss();
	return 0;
end

