--动物园管理员
local tbManager = Npc:GetClass("elunheyuan_animalmanager");
tbManager.tbExtraAward = 
{
	-- 名称，所需数量
	[1] = {"Thỏ", 40},
	[2] = {"Hươu", 35},
	[3] = {"Sói", 30},
	[4] = {"Hổ", 25},
	[5] = {"Gấu", 20},
};
tbManager.nExtraExpAward = 5000000; -- 猎人特殊任务经验奖励
tbManager.szAnimalBornPosFile = "\\setting\\task\\armycamp\\elunheyuan\\animal_born.txt";
tbManager.tbAnimalBornPos = {};	-- 出生点
tbManager.nRefreshAnimalNum = 15; -- 第一波刷新npc的个数
tbManager.nStateHugeMaxNum = 6; -- 同时最多允许刷6波大型怪
tbManager.tbPointAward = 	-- 积分奖励
{
	[1] = {250, 1000000, "Săn bắn bậc 1"},
	[2] = {300, 1500000, "Săn bắn bậc 2"},
	[3] = {500, 2000000, "Săn bắn bậc 3"},
	[4] = {800, 2500000, "Săn bắn bậc 4"},
	[5] = {1500, 3500000, "Săn bắn bậc 5"},
};
tbManager.nTotalTime = 4 * 60 * 18;	-- 关卡总时间5分钟
tbManager.nSpecialAnimalExsitTime = 10 * 18; -- 特殊动物存在的时间
tbManager.nAddNpcTimeSpe = 2 * 18; -- 一个npc死亡之后刷新新npc的间隔
function tbManager:OnDialog()
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	-- 上一关打完才能开启下一关
	if tbInstancing.tbTollgateReset[2] ~= 2 then
		Dialog:Say("Hãy bắt ngựa trước rồi hãy đến tìm ta.");
		return;
	end
	local szMsg = "Hãy săn bắt đi, không đủ thì về nhà mà luyện thêm!";
	local tbOpt = {
		{"<color=yellow>Bảng xếp hạng cao thủ<color>", self.ViewRank, self},
		{"Ta chỉ xem qua"},
		};
	if tbInstancing.tbTollgateReset[3] == 0 then
		szMsg = szMsg .. "\nĐồng đội đang chiến đấu, hãy chờ đợi";
	elseif tbInstancing.tbTollgateReset[3] == 1 then
		table.insert(tbOpt, 1, {"Bắt đầu khiêu chiến!", self.StartHunting, self, him.dwId});
		szMsg = szMsg .. "\nLần đầu khiêu chiến sẽ có thêm nhiệm vụ, sau khi khiêu chiến xong hãy trở lại gặp ta";
	elseif tbInstancing.tbTollgateReset[3] == 2 then
		szMsg = szMsg .. "\nNgươi khá lắm.";
		table.insert(tbOpt, 1, {"Đi đến ải tiếp theo", self.GoNext, self, him.dwId});
		-- 第一次挑战
		if tbInstancing.tbHuntingGround.nFirstChallenge == 1 then
			local nType = tbInstancing.tbHuntingGround.nExtraAwardType;
			szMsg = szMsg .. string.format("\n<color=yellow>Gần đây, %s đang quấy nhiễu dân làng, nếu ngươi giúp ta thu thập đủ số lượng, ta sẽ trọng thưởng.<color>", self.tbExtraAward[nType][1]);
			table.insert(tbOpt, 1, {"<color=green>Ta đang có thứ anh cần<color>", self.ExtraAward, self, him.dwId})
		end
	end
	Dialog:Say(szMsg, tbOpt);
end

function tbManager:ViewRank()
	local tbRankList = Task.tbArmyCampInstancingManager:GetHuntingRank();
	if not tbRankList or #tbRankList <= 0 then
		Dialog:Say("最近我还没看到很优秀的猎人。");
		return;
	end
	local szMsg = "最近一周，我在这里见到狩猎成绩最优秀的队伍就是他们了，你应该以他们为目标努力！\n";
	for nRank = 1, #tbRankList do
		szMsg = szMsg .. string.format("Hạng %d:\n", nRank);
		szMsg = szMsg .. string.format("Điểm: <color=yellow>%s<color>\n", tbRankList[nRank].nPoint);
		szMsg = szMsg .. "参与队员：";
		for _, szName in ipairs(tbRankList[nRank].tbMember) do
			szMsg = szMsg .. "<color=yellow>" .. szName .. "<color> ";
		end
		szMsg = szMsg .. "\n"
	end
	Dialog:Say(szMsg);
end

function tbManager:UpdateRank(tbInstancing, nPoint)
	local tbRankList = Task.tbArmyCampInstancingManager:GetHuntingRank();
	if not tbRankList then
		return;
	end
	if #tbRankList > 5 and nPoint <= tbRankList[5].nPoint then
		return;
	end
	local tbRank = {};
	tbRank.nPoint = nPoint;
	tbRank.tbMember = {};
	for nPlayerId, _ in pairs(tbInstancing.tbAttendPlayerList) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			table.insert(tbRank.tbMember, pPlayer.szName);
		end
	end
	local nRank = Task.tbArmyCampInstancingManager:UpdateHuntingRank(tbRank);
end

-- 进入下一关
function tbManager:GoNext(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc) then
		return;
	end
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	me.NewWorld(tbInstancing.nMapId, 1750, 3413);
	if tbInstancing.tbTollgateReset[4] == 1 then
		TaskAct:Talk("我们成功的在那达慕大会中夺魁，赢得蒙人尊重的同时获得了面见大汗的资格。但是想要面见大汗，仍需要通过一些考验。部落萨满教的大祭祀深受草原人敬仰，他的考验一定不好应付，一定要慎之又慎。");
	end
end

-- 开始狩猎
function tbManager:StartHunting(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc) then
		return;
	end
	local nSubWorld, _, _	= pNpc.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if tbInstancing.tbTollgateReset[3] ~= 1 then
		return;
	end
	tbInstancing:ChangeTollgateState(3, 0);
	local tbPlayList, _ = KPlayer.GetMapPlayer(nSubWorld);
	for _, teammate in ipairs(tbPlayList) do
		teammate.NewWorld(nSubWorld, 1823, 3537);
		teammate.SetFightState(1);
		tbInstancing.tbAttendPlayerList[teammate.nId] = 1;
		local szTimeMsg =  "<color=green>\nThời gian còn lại: <color> <color=white>%s<color>";
		Dialog:SetBattleTimer(teammate, szTimeMsg, self.nTotalTime);
		local szMsg = self:GetPlayerInfoTxt(tbInstancing, teammate.nId);
		Dialog:SendBattleMsg(teammate, szMsg);
		Dialog:ShowBattleMsg(teammate, 1, 0);
		Dialog:SendBlackBoardMsg(teammate, "Nhanh chóng săn bắt một ít thú rừng!");
	end
	if not self.tbAnimalBornPos or #self.tbAnimalBornPos == 0 then
		local tbFile = Lib:LoadTabFile(self.szAnimalBornPosFile);
		assert(tbFile);
		for nIndex, tbTemp in ipairs(tbFile) do
			table.insert(self.tbAnimalBornPos, {tonumber(tbTemp["POSX"]/32), tonumber(tbTemp["POSY"]/32)});
		end
	end
	-- 添加动物
	for i = 1, self.nRefreshAnimalNum do
		self:AddAnimal(tbInstancing, tbInstancing.tbHuntingGround.tbAnimalId);
	end
	tbInstancing.tbHuntingGround.nEndTimer = Timer:Register(self.nTotalTime, self.HuntingTimerEnd, self, him.dwId);
end
tbManager.tbNormalAnimalRandInfo = 
{
	-- 1:随到该Npc的概率(总概率是总合)，2:npcId，3:有反弹光环的概率, 4:积分,5: 死亡出特殊怪的概率（总概率1000）,6:反弹光环的持续时间
	[1] = {40, 9949, 20, 1, 100, 10},
	[2] = {20, 9950, 20, 2, 120, 10},
	[3] = {20, 9951, 20, 2, 150, 10},
	[4] = {15, 9952, 20, 5, 200, 10},
	[5] = {5, 9953, 20, 5, 300, 10},	
};
-- 每种动物杀到一定个数都会刷出一个王
tbManager.tbKingAnimalRandInfo = 
{
	-- ID, 累积个数，最多刷几个
	[1] = {10122, 10, 5},
	[2] = {10123, 10, 5},
	[3] = {10124, 5, 5},
	[4] = {10125, 5, 5},
	[5] = {10126, 5, 5},	
};
-- 各种特殊猎物的概率（在已经要刷出特殊猎物的前提）,
tbManager.tbSpecialAnimalRandInfo = 
{
	-- 概率，ID， 处理函数，参数表
	[1] = {300, 10127, {10}},	-- 双倍积分,{持续时间}
	[2] = {300, 10128, {40, 3, 6}},	-- 刷小怪, {每波的个数，一共多少波，猎物存在时间（也是刷新间隔）}
	[3] = {600, 10129, {2705, 10, 10}},	-- 加攻击, {状态ID， 状态等级， 持续时间}
	[4] = {300, 10130, {2706, 10, 5}},	-- 减攻击,清有益状态, {状态ID, 状态等级}
		
};
-- 添加动物，随机位置，和动物种类，以及初始是否有反弹光环
function tbManager:AddAnimal(tbInstancing, tbStorageTable, nIsHuge, nLiveTime) 
	local nRandSum = 0;
	for i = 1, #self.tbNormalAnimalRandInfo do
		nRandSum = nRandSum + self.tbNormalAnimalRandInfo[i][1];
	end
	local nRand = MathRandom(nRandSum);
	local nSum = 0;
	local nIndex = 1; -- 动物的索引
	for i = 1, #self.tbNormalAnimalRandInfo do
		nSum = nSum + self.tbNormalAnimalRandInfo[i][1];
		if nSum >= nRand then
			nIndex = i;
			break;
		end
	end
	local nPosRand = MathRandom(#self.tbAnimalBornPos);
	local nLevel = tbInstancing.nNpcLevel;
	if nIsHuge == 1 then
		nLevel = nLevel - 5;
	end
	local pNpc = KNpc.Add2(self.tbNormalAnimalRandInfo[nIndex][2], nLevel, -1, tbInstancing.nMapId, self.tbAnimalBornPos[nPosRand][1], self.tbAnimalBornPos[nPosRand][2]);
	if pNpc then
		table.insert(tbStorageTable, pNpc.dwId);
		-- 添加反弹3秒的反弹状态,大波刷出的怪没有反弹
		if nIsHuge ~= 1 and  MathRandom(100) < self.tbNormalAnimalRandInfo[nIndex][3] then
			pNpc.AddSkillState(2704, 7, 1, self.tbNormalAnimalRandInfo[nIndex][6] * Env.GAME_FPS);
		end
		if nLiveTime and nLiveTime > 0 then
			pNpc.SetLiveTime(nLiveTime * Env.GAME_FPS);
		end
	end
	return 0;
end

-- 添加王
function tbManager:AddKingAnimal(tbInstancing, nType)
	local nPosRand = MathRandom(#self.tbAnimalBornPos);
	local pNpc = KNpc.Add2(self.tbKingAnimalRandInfo[nType][1], tbInstancing.nNpcLevel, -1, tbInstancing.nMapId, self.tbAnimalBornPos[nPosRand][1], self.tbAnimalBornPos[nPosRand][2]);
	if pNpc then
		table.insert(tbInstancing.tbHuntingGround.tbKingAnimalId, pNpc.dwId);
		pNpc.SetLiveTime(20 * Env.GAME_FPS);
		-- 定时删除npc，方便列表管理
		Timer:Register(self.nSpecialAnimalExsitTime, self.DeteleSpecialNpc, self, tbInstancing.tbHuntingGround.tbKingAnimalId, pNpc.dwId);
	end
end

-- 添加各种特殊动物
function tbManager:AddSpecialAnimal(tbInstancing, nType)
	nType = nType or 0;
	if nType == 0 then	-- 随机添加的类型
		local nRandSum = 0;
		for i = 1, #self.tbSpecialAnimalRandInfo do
			nRandSum = nRandSum + self.tbSpecialAnimalRandInfo[i][1];
		end
		local nRand = MathRandom(nRandSum);
		local nIndex = 4; -- 动物的索引
		local nSum = 0;
		for i = 1, #self.tbSpecialAnimalRandInfo do
			nSum = nSum + self.tbSpecialAnimalRandInfo[i][1];
			if nSum >= nRand then
				nIndex = i;
				break;
			end
		end
		nType = nIndex;
	end
	local nPosRand = MathRandom(#self.tbAnimalBornPos);
	local pNpc = KNpc.Add2(self.tbSpecialAnimalRandInfo[nType][2], tbInstancing.nNpcLevel, -1, tbInstancing.nMapId, self.tbAnimalBornPos[nPosRand][1], self.tbAnimalBornPos[nPosRand][2]);
	if pNpc then
		table.insert(tbInstancing.tbHuntingGround.tbSpecialAnimalId, pNpc.dwId);
		pNpc.SetLiveTime(13 * Env.GAME_FPS);
		-- 定时删除npc，方便列表管理
		Timer:Register(self.nSpecialAnimalExsitTime, self.DeteleSpecialNpc, self, tbInstancing.tbHuntingGround.tbSpecialAnimalId, pNpc.dwId);
	end
end

-- 到时间删除特殊的动物，包括王
function tbManager:DeteleSpecialNpc(tbNpcIdList, nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	pNpc.Delete();
	local nIndex = 0;
	for i, nId in ipairs(tbNpcIdList) do
		if nId == nNpcId then
			nIndex = i;
			break;
		end
	end
	if nIndex > 0 then
		table.remove(tbNpcIdList, nIndex);
	end
	return 0;
end


-- 发布奖励
function tbManager:ExtraAward(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc) then
		return;
	end
	local nSubWorld, _, _	= pNpc.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if tbInstancing.tbTollgateReset[3] ~= 2 then
		return;
	end
	local tbPlayerInfo = tbInstancing.tbHuntingGround.tbPlayerInfo[me.nId] or {};
	local nType = tbInstancing.tbHuntingGround.nExtraAwardType;
	local szMsg = string.format("今天我这里需要<color=yellow>%s只%s<color>,你本轮的战绩", self.tbExtraAward[nType][2], self.tbExtraAward[nType][1]);
	local szGrade = "";
	for i = 1, #self.tbExtraAward do
		szGrade = szGrade .. string.format("%s:%s\t%s\n", i, self.tbExtraAward[i][1], tbPlayerInfo[i] or 0);
	end
	szMsg = string.format("%s\n%s", szMsg, szGrade);
	local tbOpt = {};
	if tbPlayerInfo[nType] and tbPlayerInfo[nType] >= self.tbExtraAward[nType][2] then
		if tbInstancing.tbHuntingGround.tbExtraAwardFlag[me.nId] == 1 then
			szMsg = string.format("%s你身上的%s都已经跟我交换了，下次打到了再来吧", szMsg, self.tbExtraAward[nType][1]);
		else
			szMsg = string.format("%s哈哈哈谢谢你，草原人懂得知恩图报！这个就给你了！", szMsg);
			tbOpt[#tbOpt+1] = {"上交给猎户", self.GetExtraAward, self, nNpcId};
		end
	else
		szMsg = string.format("%s敢骗我？你明明没有狩猎到足够的%s！走开！", szMsg, self.tbExtraAward[nType][1]);
	end
	tbOpt[#tbOpt+1] = {"Ta chỉ xem qua"};
	Dialog:Say(szMsg, tbOpt);
end

function tbManager:GetExtraAward(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc) then
		return;
	end
	local nSubWorld, _, _	= pNpc.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if tbInstancing.tbTollgateReset[3] ~= 2 then
		return;
	end
	local tbPlayerInfo = tbInstancing.tbHuntingGround.tbPlayerInfo[me.nId];
	if not tbPlayerInfo then
		return;
	end
	local nType = tbInstancing.tbHuntingGround.nExtraAwardType;
	if tbPlayerInfo[nType] and tbPlayerInfo[nType] >= self.tbExtraAward[nType][2] and tbInstancing.tbHuntingGround.tbExtraAwardFlag[me.nId] ~= 1 then
		me.AddExp(self.nExtraExpAward);
		Dialog:SendBlackBoardMsg(me, "Chúc mừng bạn đã nhận được kinh nghiệm từ buổi săn bắt!");
		tbInstancing.tbHuntingGround.tbExtraAwardFlag[me.nId] = 1;
		Achievement:FinishAchievement(me, 489);
	end
end

-- 添加Addnpc计时器
function tbManager:AddNpcTimer(tbInstancing, nIndex)
	self:AddAnimal(tbInstancing, tbInstancing.tbHuntingGround.tbAnimalId);
	tbInstancing.tbHuntingGround.tbAddAnimalTimer[nIndex] = nil;
	return 0;
end
-- 动物死亡回调，给玩家加分
function tbManager:KillAnimal(nNpcId, nMapId, nPlayerId, nType, nIsKing)
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nMapId);
	assert(tbInstancing);
	if tbInstancing.tbTollgateReset[3] ~= 0 then
		return;
	end
	local pKillerPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pKillerPlayer then
		return 0;
	end
	local nIndex = 0;
	local tbId = nil;
	if nIsKing == 1 then
		tbId = tbInstancing.tbHuntingGround.tbKingAnimalId;
	else
		tbId = tbInstancing.tbHuntingGround.tbAnimalId;
	end
	for i, nAnimalId in pairs(tbId) do
		if nAnimalId == nNpcId then
			nIndex = i;
			break;
		end
	end
	if nIndex <= 0 then
		return 0;
	end
	table.remove(tbId, nIndex);
	if self:AddKillPoint(tbInstancing, pKillerPlayer.nId, nType, nIsKing) == 1 then
		if nIsKing ~= 1 then -- 往只能单纯的加分，一次性动物
			-- 找到空闲的计时器索引
			nIndex = 0;
			for i = 1, self.nRefreshAnimalNum do
				if not tbInstancing.tbHuntingGround.tbAddAnimalTimer[i] or tbInstancing.tbHuntingGround.tbAddAnimalTimer[i] == 0 then
					nIndex = i;
					break;
				end
			end
			if nIndex > 0 then
				local nTimerId = Timer:Register(self.nAddNpcTimeSpe, self.AddNpcTimer, self, tbInstancing, nIndex);
				tbInstancing.tbHuntingGround.tbAddAnimalTimer[nIndex] = nTimerId;
			end
		end
		-- 达到刷王的条件刷一只王
		tbInstancing.tbHuntingGround.tbKingAnimalRrefreshNum[nType] = tbInstancing.tbHuntingGround.tbKingAnimalRrefreshNum[nType] or 0;
		if math.mod(tbInstancing.tbHuntingGround.tbAnimalAccumulationNum[nType], self.tbKingAnimalRandInfo[nType][2]) == 0 
		and tbInstancing.tbHuntingGround.tbKingAnimalRrefreshNum[nType] < self.tbKingAnimalRandInfo[nType][3] then
			tbInstancing.tbHuntingGround.tbKingAnimalRrefreshNum[nType] = tbInstancing.tbHuntingGround.tbKingAnimalRrefreshNum[nType] + 1;
			self:AddKingAnimal(tbInstancing, nType);
		end
		-- 每次死亡都有概率出特殊的动物,不同的动物死亡出现特殊怪的概率是不同的
		local nSpecialRand = MathRandom(1000);
		if nSpecialRand <= self.tbNormalAnimalRandInfo[nType][5] then
			self:AddSpecialAnimal(tbInstancing);
		end
		-- 更新玩家的分数显示
		for nPlayerId, nFlag in pairs(tbInstancing.tbAttendPlayerList) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				local szMsg = self:GetPlayerInfoTxt(tbInstancing, nPlayerId);
				Dialog:SendBattleMsg(pPlayer, szMsg);
				Dialog:ShowBattleMsg(pPlayer, 1, 0);
			end
		end
		Achievement:FinishAchievement(pKillerPlayer, 491);
	end
end

-- 打死特殊怪,给副本加特殊状态
function tbManager:AddSpecialState(nNpcId, nMapId, nPlayerId, nType)
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nMapId);
	assert(tbInstancing);
	if tbInstancing.tbTollgateReset[3] ~= 0 then
		return;
	end
	local pKillerPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pKillerPlayer then
		return 0;
	end
	local nIndex = 0;
	for i, nAnimalId in pairs(tbInstancing.tbHuntingGround.tbSpecialAnimalId) do
		if nAnimalId == nNpcId then
			nIndex = i;
			break;
		end
	end
	if nIndex <= 0 then
		return 0;
	end
	table.remove(tbInstancing.tbHuntingGround.tbSpecialAnimalId, nIndex);
	if nType == 1 then	-- 双倍
		-- 如果双倍中则关掉计时器重新计时
		if tbInstancing.tbHuntingGround.nStateDoubleTimerId then
			Timer:Close(tbInstancing.tbHuntingGround.nStateDoubleTimerId);
		end
		tbInstancing.tbHuntingGround.nDoublePointState = 1;
		tbInstancing.tbHuntingGround.nStateDoubleTimerId = Timer:Register(self.tbSpecialAnimalRandInfo[nType][3][1] * Env.GAME_FPS, self.SpecialState_DoubleTimeEnd, self, tbInstancing)
		for nPlayerId, nFlag in pairs(tbInstancing.tbAttendPlayerList) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				local szMsg = self:GetPlayerInfoTxt(tbInstancing, nPlayerId);
				Dialog:SendBattleMsg(pPlayer, szMsg);
				Dialog:ShowBattleMsg(pPlayer, 1, 0);
			end
		end
		tbInstancing:SendPrompt("Thời điểm vàng, được nhân đôi số điểm.", 0, 1, 1, 0);
	elseif nType == 2 then -- 大波怪
		local nWave = self.tbSpecialAnimalRandInfo[nType][3][2];
		local nCount = self.tbSpecialAnimalRandInfo[nType][3][1];
		for i = 1, nWave do
			local nTimerIndex = 0;
			for j = 1, self.nStateHugeMaxNum do
				if tbInstancing.tbHuntingGround.tbStateHugeTimerId[j] == nil then
					nTimerIndex = j;
					break;
				end
			end
			-- 要刷的怪太多了，不要再刷了
			if nTimerIndex <= 0 then
				break;
			end
			local nLiveTime = self.tbSpecialAnimalRandInfo[nType][3][3];
			local nSpeTime = i * nLiveTime + 1;
			if i == 1 then	-- 第一波怪下一秒就刷
				nSpeTime = 1;
			end
			local nTimerId = Timer:Register(nSpeTime * Env.GAME_FPS, self.SpecialState_HugeTimeEnd, self, tbInstancing, nCount, nTimerIndex, nLiveTime);
			tbInstancing.tbHuntingGround.tbStateHugeTimerId[nTimerIndex] = nTimerId;
		end
		tbInstancing:SendPrompt("Một đàn thú hoang chuẩn bị xuất hiện!", 0, 1, 1, 0);
	elseif nType == 3 then -- 加攻击
		local tbParam = self.tbSpecialAnimalRandInfo[nType][3];
		pKillerPlayer.AddSkillState(tbParam[1], tbParam[2], 1, tbParam[3] * Env.GAME_FPS);
		Dialog:SendBlackBoardMsg(pKillerPlayer, "Hãy ra sức nào!");
	elseif nType == 4 then	-- debuff
		if tbInstancing.tbHuntingGround.nStateDoubleTimerId then
			Timer:Close(tbInstancing.tbHuntingGround.nStateDoubleTimerId);
			tbInstancing.tbHuntingGround.nStateDoubleTimerId = nil;
			self:SpecialState_DoubleTimeEnd(tbInstancing);
		end
		tbInstancing:ClearHuntingGroundState();
		local nBuffSkillId = self.tbSpecialAnimalRandInfo[3][3][1];
		local tbParam = self.tbSpecialAnimalRandInfo[4][3];
		for nPlayerId, nFlag in pairs(tbInstancing.tbAttendPlayerList) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				if pPlayer.GetSkillState(nBuffSkillId) > 0 then
					pPlayer.RemoveSkillState(nBuffSkillId);
				end
				pPlayer.AddSkillState(tbParam[1], tbParam[2], 1, tbParam[3] * Env.GAME_FPS);
			end
		end
		tbInstancing:SendPrompt("Không hay rồi, đã tấn công sai mục tiêu!", 0, 1, 1, 0);
	end
	Achievement:FinishAchievement(pKillerPlayer, 491);
end

-- 双倍时间到
function tbManager:SpecialState_DoubleTimeEnd(tbInstancing)
	tbInstancing.tbHuntingGround.nDoublePointState = 0;
	tbInstancing.tbHuntingGround.nStateDoubleTimerId = nil;
	-- 更新玩家的分数显示
	for nPlayerId, nFlag in pairs(tbInstancing.tbAttendPlayerList) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			local szMsg = self:GetPlayerInfoTxt(tbInstancing, nPlayerId);
			Dialog:SendBattleMsg(pPlayer, szMsg);
			Dialog:ShowBattleMsg(pPlayer, 1, 0);
		end
	end
	return 0;
end

-- 到时间刷一大波怪
function tbManager:SpecialState_HugeTimeEnd(tbInstancing, nCount, nTimerIndex, nLiveTime)
	tbInstancing.tbHuntingGround.tbStateHugeTimerId[nTimerIndex] = nil;
	-- 怪物是有生存时间的，存一下索引再副本关闭或者重开关卡的时候可以及时删除
	tbInstancing.tbHuntingGround.tbStateHugeNpcId[nTimerIndex] = {};
	for i = 1, nCount do
		self:AddAnimal(tbInstancing, tbInstancing.tbHuntingGround.tbStateHugeNpcId[nTimerIndex], 1, nLiveTime);
	end
	return 0;
end

-- 获取玩家右侧显示的文字
function tbManager:GetPlayerInfoTxt(tbInstancing, nPlayerId)
	local nDeadTimes = tbInstancing.tbHuntingGround.tbReviveList[nPlayerId] or 0;
	local szMsg = string.format("<color=green>Số lần trọng thương: %s/%s<color>\n", nDeadTimes, tbInstancing.nReviveTimesInHuntingGround);
	if tbInstancing.tbHuntingGround.nDoublePointState == 1 then
		szMsg = szMsg .. "\n<color=yellow>Điểm gấp đôi...<color>\n";
	end
	local nNextPoint = "---";
	for i = 1, #self.tbPointAward do
		if tbInstancing.tbHuntingGround.nTotalPoint < self.tbPointAward[i][1] then
			nNextPoint = self.tbPointAward[i][1];
			break;
		end
	end
	szMsg = string.format("\n%s Điểm đội: %s/%s\n", szMsg, tbInstancing.tbHuntingGround.nTotalPoint, nNextPoint);
	local tbPlayerInfo = tbInstancing.tbHuntingGround.tbPlayerInfo[nPlayerId] or {};
	local szGrade = "";
	for i = 1, #self.tbExtraAward do
		szGrade = szGrade .. string.format("%s: %s  %s\n", i, self.tbExtraAward[i][1], tbPlayerInfo[i] or 0);
	end
	szMsg = szMsg .. szGrade;
	return szMsg;
end

-- 给玩家加分数
function tbManager:AddKillPoint(tbInstancing, nPlayerId, nType, nIsKing)
	if not tbInstancing.tbAttendPlayerList[nPlayerId] then
		return 0;
	end
	local nMultip = 1;
	if tbInstancing.tbHuntingGround.nDoublePointState == 1 then
		nMultip = 2;
	end
	-- 添加到队伍死亡统计
	tbInstancing.tbHuntingGround.tbAnimalAccumulationNum[nType] = tbInstancing.tbHuntingGround.tbAnimalAccumulationNum[nType] or 0;
	tbInstancing.tbHuntingGround.tbAnimalAccumulationNum[nType] = tbInstancing.tbHuntingGround.tbAnimalAccumulationNum[nType] + nMultip;
	if nIsKing == 1 then -- 一个王抵五个普通怪,但不计入队伍杀怪个数
		nMultip = 5 * nMultip;
	end
	tbInstancing.tbHuntingGround.tbPlayerInfo[nPlayerId] = tbInstancing.tbHuntingGround.tbPlayerInfo[nPlayerId] or {};
	tbInstancing.tbHuntingGround.tbPlayerInfo[nPlayerId][nType] = tbInstancing.tbHuntingGround.tbPlayerInfo[nPlayerId][nType] or 0;
	tbInstancing.tbHuntingGround.tbPlayerInfo[nPlayerId][nType] = tbInstancing.tbHuntingGround.tbPlayerInfo[nPlayerId][nType] + nMultip;
	tbInstancing.tbHuntingGround.nTotalPoint = tbInstancing.tbHuntingGround.nTotalPoint + self.tbNormalAnimalRandInfo[nType][4] * nMultip;
	return 1;
end

-- 打猎时间到
function tbManager:HuntingTimerEnd(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc) then
		return 0;
	end
	local nSubWorld, _, _	= pNpc.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		return 0;
	end
	tbInstancing.tbHuntingGround.nEndTimer = nil;
	if tbInstancing.tbTollgateReset[3] ~= 0 then
		return 0;
	end
	-- 过关
	if tbInstancing.tbHuntingGround.nTotalPoint >= self.tbPointAward[1][1] then
		local nLevel = 1;
		for i = #self.tbPointAward, 1, -1 do
			if tbInstancing.tbHuntingGround.nTotalPoint >= self.tbPointAward[i][1] then
				nLevel = i;
				break;
			end
		end 
		tbInstancing:ChangeTollgateState(3, 2);
		self:UpdateRank(tbInstancing, tbInstancing.tbHuntingGround.nTotalPoint);
		-- 关闭npc死亡重生计时器
		if tbInstancing.tbHuntingGround.tbAddAnimalTimer and #tbInstancing.tbHuntingGround.tbAddAnimalTimer > 0 then
			for _, nTimerId in pairs(tbInstancing.tbHuntingGround.tbAddAnimalTimer) do
				Timer:Close(nTimerId);
			end
			tbInstancing.tbHuntingGround.tbAddAnimalTimer = {};
		end
		-- 删除场上的动物
		if tbInstancing.tbHuntingGround.tbAnimalId and #tbInstancing.tbHuntingGround.tbAnimalId > 0 then
			for _, nNpcId in ipairs(tbInstancing.tbHuntingGround.tbAnimalId) do
				tbInstancing:DeleteNpc(nNpcId);
			end
			tbInstancing.tbHuntingGround.tbAnimalId = {};
		end
		if tbInstancing.tbHuntingGround.tbKingAnimalId and #tbInstancing.tbHuntingGround.tbKingAnimalId > 0 then
			for _, nNpcId in ipairs(tbInstancing.tbHuntingGround.tbKingAnimalId) do
				tbInstancing:DeleteNpc(nNpcId);
			end
			tbInstancing.tbHuntingGround.tbKingAnimalId = {};
		end
		tbInstancing:ClearHuntingGroundState();
		local tbPlayList, _ = KPlayer.GetMapPlayer(tbInstancing.nMapId);
		-- 给所有地图内的人都设上任务标志
		for _, teammate in ipairs(tbPlayList) do
			teammate.SetTask(1025, 59, 1);
			teammate.Msg(string.format("Đã vượt qua cấp độ %s. Hãy đối thoại với NPC để tăng cấp độ thử thách.", nLevel));
			Dialog:SendBlackBoardMsg(teammate, "Hãy đối thoại với NPC để tăng cấp độ thử thách.");
		end
		for nPlayerId, nFlag in pairs(tbInstancing.tbAttendPlayerList) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				Dialog:ShowBattleMsg(pPlayer, 0, 0);
				if (pPlayer.IsDead() == 1) then -- 原地复活
					pPlayer.ReviveImmediately(1);
				end
				pPlayer.SetFightState(0);
				-- 根据队伍分数给奖励
				pPlayer.AddExp(self.tbPointAward[nLevel][2])
				StatLog:WriteStatLog("stat_info", "xinjunying", "shoulie", pPlayer.nId, nLevel);
				Dialog:SendBlackBoardMsg(pPlayer, string.format("Vượt qua cấp độ %s, hãy đối thoại với NPC để tăng cấp độ thử thách.", self.tbPointAward[nLevel][3]));
				if nLevel == #self.tbPointAward then
					Achievement:FinishAchievement(pPlayer, 490);
				end
			end
		end
		tbInstancing.tbAttendPlayerList = {};
	else
		-- 把所有人传送回准备区，然后关卡复位
		for nPlayerId, nFlag in pairs(tbInstancing.tbAttendPlayerList) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				Dialog:ShowBattleMsg(pPlayer, 0, 0);
				if (pPlayer.IsDead() == 1) then
					pPlayer.ReviveImmediately(0);
				else
					pPlayer.NewWorld(tbInstancing.nMapId, unpack(tbInstancing.tbSetting.tbRevivePos));
				end
				
				pPlayer.SetFightState(0);
			end
		end
		tbInstancing.tbAttendPlayerList = {};
		tbInstancing:RestartTollgate(); -- 还原关卡重新开始
	end
	return 0;
end