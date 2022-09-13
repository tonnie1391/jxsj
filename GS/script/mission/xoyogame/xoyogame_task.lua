-- 逍遥谷挑战
XoyoGame.XoyoChallenge = XoyoGame.XoyoChallenge or {};
local XoyoChallenge = XoyoGame.XoyoChallenge;

-- NpcId索引的数据列表
--            打怪掉落率                                    随机卡开出来的概率
-- npcId --> {"nDropRate","tbCardGDPL", "id", "szCardGDPL", "nProbability"}
XoyoChallenge.tbNpcId2Data = {};
XoyoChallenge.tbNpcId2Data_id = {}; -- 内容与tbNpcId2Data一样，但用每行开头的id做索引

-- 物品GDPL索引的数据列表
-- "g,d,p,l" --> {"nNeededNum", "tbItemGDPL", "tbCardGDPL", "id", "szCardGDPL", "nProbability"}
XoyoChallenge.tbItem2Data = {};
XoyoChallenge.tbItem2Data_id = {}; -- 内容与tbItem2Data一样，但用每行开头的id做索引

-- 房间编号索引的数据列表
-- nRoomId --> {"tbCardGDPL", "id", "nDropRate", "szCardGDPL", "nProbability"}
XoyoChallenge.tbRoom2Data = {};
XoyoChallenge.tbRoom2Data_id = {}; -- 内容与tbRoom2Data一样，但用每行开头的id做索引

-- 反向索引，卡片储存在哪个地方
--                  [1]    [2]    [3]    [4]
-- "g,d,p,l" --> {nTaskId, nBit, nIndex, nId, 
-- szDesc, tbCardGDPL}
XoyoChallenge.tbCardStorage = {};
-- {self.nProbabilitySum, v.tbCardStorage}
XoyoChallenge.tbCardStorage_probability = {};

-- 把卡片收集情况储存在任务变量中，一位表示一张卡片
-- 由第1位开始，一个任务变量存满后就用下一个
XoyoChallenge.TASKGID = 2050;
XoyoChallenge.TASK_NPC_BEGIN = 20; -- npc任务用，每个2位，1表示已收集卡片，2表示已使用卡片
XoyoChallenge.TASK_ITEM_BEGIN = 24; -- 收集物品用
XoyoChallenge.TASK_ROOM_BEGIN = 28; -- 过房间用
XoyoChallenge.TASK_END = 32; -- 这个不使用
XoyoChallenge.TASK_GET_XOYOLU_MONTH = 41; -- 记录获得逍遥录的年和月，如200903
XoyoChallenge.TASK_HANDUP_XOYOLU_MONTH = 42; -- 上交的是那个时候获得的逍遥录，如200903
XoyoChallenge.TASK_SPECIAL_CARD_DATE = 43; -- 获得特殊卡的日期，如20090312
XoyoChallenge.TASK_SPECIAL_CARD_NUM = 44; -- 当天成功换特殊卡的数量
XoyoChallenge.TASK_GET_AWARD_MONTH = 45; -- 领奖时间，例如玩家在200906拿了逍遥录，他在下个月领奖后，就会把这个变量记上200906（拿逍遥录的月份）
XoyoChallenge.TASK_GET_AWARD_MONTH_COPY = 46; --7月临时使用领奖时间任务变量

XoyoChallenge.tbSpecialCard = {18,1,314,1}; -- 特殊卡
XoyoChallenge.tbXoyolu = {18,1,318,1}; -- 逍遥录
XoyoChallenge.MAX_SPECIAL_CARD_NUM = 2; -- 每天最多换两张特殊卡

XoyoChallenge.MINUTE_OF_MONTH = 32*24*60;

-------------- load file ---------------------------

function XoyoChallenge:LoadCommonEntry(nRowNum, tbRow)
	local g,d,p,l = tonumber(tbRow.CARD_G), tonumber(tbRow.CARD_D), tonumber(tbRow.CARD_P), tonumber(tbRow.CARD_L);
	local id = tonumber(tbRow.Id);
	assert(id == nRowNum);
	local tb = {["tbCardGDPL"] = {g,d,p,l}, ["szCardGDPL"] = string.format("%d,%d,%d,%d",g,d,p,l),
			["id"] = id, ["szDesc"] = tbRow.CARD_DESC, ["nWeight"] = tonumber(tbRow.CARD_WEIGHT), ["nProbability"] = tbRow.PROBABILITY};
	return tb, id;
end

function XoyoChallenge:__LoadDropRate(tbRow, szKey)
	local tbId = Lib:SplitStr(tbRow[szKey], "|"); -- ROOM_ID或者NPC_ID
	for i = 1, #tbId do
		tbId[i] = assert(tonumber(tbId[i]));
	end
	
	local tbDropRate = Lib:SplitStr(tbRow.DROP_RATE, "|");
	for i = 1, #tbDropRate do
		tbDropRate[i] = assert(tonumber(tbDropRate[i]));
	end
	
	assert(#tbId == #tbDropRate);
	return tbId, tbDropRate;
end

function XoyoChallenge:LoadFile()
local tbFile = Lib:LoadTabFile("\\setting\\xoyogame\\card_kill_npc.txt");
for i = 1, #tbFile do
	local tbRow = tbFile[i];
	
	local tbNpcId, tbDropRate = self:__LoadDropRate(tbRow, "NPCID");
	
	for j = 1, #tbNpcId do
		local nNpcId = tbNpcId[j];
		local nDropRate = tbDropRate[j];
		assert(XoyoChallenge.tbNpcId2Data[nNpcId] == nil, tostring(nNpcId));
		local tb, id = XoyoChallenge:LoadCommonEntry(i, tbRow);
		tb["nDropRate"] = nDropRate;
		XoyoChallenge.tbNpcId2Data[nNpcId] = tb;
		XoyoChallenge.tbNpcId2Data_id[id] = tb;
	end
end

tbFile = Lib:LoadTabFile("\\setting\\xoyogame\\card_collect_item.txt");
for i = 1, #tbFile do
	local tbRow = tbFile[i];
	local szKey = string.format("%s,%s,%s,%s", tbRow.ITEM_G, tbRow.ITEM_D, tbRow.ITEM_P, tbRow.ITEM_L);
	local nNum = tonumber(tbRow.NUM);
	assert(XoyoChallenge.tbItem2Data[szKey] == nil);
	local tb, id = XoyoChallenge:LoadCommonEntry(i, tbRow);
	tb["nNeededNum"] = nNum;
	tb["tbItemGDPL"] = {tonumber(tbRow.ITEM_G), tonumber(tbRow.ITEM_D), tonumber(tbRow.ITEM_P), tonumber(tbRow.ITEM_L)};
	XoyoChallenge.tbItem2Data[szKey] = tb;
	XoyoChallenge.tbItem2Data_id[id] = tb;
end

tbFile = Lib:LoadTabFile("\\setting\\xoyogame\\card_room.txt");
for i = 1, #tbFile do
	local tbRow = tbFile[i];
	local tbRoomId, tbDropRate = self:__LoadDropRate(tbRow, "ROOM_ID");
	
	for j = 1, #tbRoomId do
		local nRoomId = tbRoomId[j];
		local nDropRate = tbDropRate[j];
		assert(XoyoChallenge.tbRoom2Data[nRoomId] == nil);
		local tb, id = XoyoChallenge:LoadCommonEntry(i, tbRow);
		tb["nDropRate"] = nDropRate;
		XoyoChallenge.tbRoom2Data[nRoomId] = tb;
		XoyoChallenge.tbRoom2Data_id[id] = tb;
	end
end
end
--------------- load file end------------------------

XoyoChallenge.nCardNum = 0; -- 卡片总数
XoyoChallenge.nProbabilitySum = 0; -- 概率总和
function XoyoChallenge:InitCardStorage()
	local tbCtrl = {
		{self.tbNpcId2Data, self.TASK_NPC_BEGIN},
		{self.tbItem2Data,  self.TASK_ITEM_BEGIN},
		{self.tbRoom2Data,  self.TASK_ROOM_BEGIN},
		{nil, 				self.TASK_END}
	};
	
	for i = 1, #tbCtrl - 1 do
		local info = tbCtrl[i];
		
		for _, v in pairs(info[1]) do
			local szKey = string.format("%d,%d,%d,%d", unpack(v.tbCardGDPL));
			local nTaskId = info[2] + math.floor((v.id - 1)*2 / 32);
			local nBit = math.fmod((v.id - 1)*2, 32);
			
			assert(nTaskId < tbCtrl[i + 1][2], string.format("i:%d, id:%d", i, v.id)); -- 不能超过该类任务的数量限制(id太大)
			
			if self.tbCardStorage[szKey] and
				not (self.tbCardStorage[szKey][3] == i and self.tbCardStorage[szKey][4] == v.id) then -- npc表有多个npcId对应同一个卡片的情况
					
				assert(false, string.format("prev i:%d, prev id:%d, curr i:%d, curr id:%d, gdpl:%s", 
					self.tbCardStorage[szKey][3], self.tbCardStorage[szKey][3], i, v.id, szKey)); -- 卡片gdpl不能重复
			end
			
			if not self.tbCardStorage[szKey] then
				self.nProbabilitySum = self.nProbabilitySum + v.nProbability;
				self.tbCardStorage[szKey] = {nTaskId, nBit, i, v.id}; -- i和v.id构成该行的唯一标识
				self.tbCardStorage[szKey]["szDesc"] = v.szDesc;
				self.tbCardStorage[szKey]["tbCardGDPL"] = v.tbCardGDPL;
				self.tbCardStorage[szKey]["nWeight"] = v.nWeight;
				table.insert(self.tbCardStorage_probability, {self.nProbabilitySum, v.tbCardGDPL});
				self.nCardNum = self.nCardNum + 1;
			end
		end
	end
	
	self.nTotalWeight = 0;
	for _, v in pairs(self.tbCardStorage) do
		self.nTotalWeight = self.nTotalWeight + v.nWeight;
	end
	self.__tbRange = self:TransRange({self.MINUTE_OF_MONTH, self.nTotalWeight, self.nCardNum});
end

-- 获取卡片收集状况，已收集返回1，未收集返回0
function XoyoChallenge:GetCardState(pPlayer, szCardGDPL)
	local info = self.tbCardStorage[szCardGDPL];
	assert(info, szCardGDPL);
	local nTask = info[1];
	local nBit = info[2];
	
	local nVal = pPlayer.GetTask(self.TASKGID, nTask);
	return Lib:LoadBits(nVal, nBit, nBit+1);
end

-- 设置卡片收集状态
function XoyoChallenge:SetCardState(pPlayer, szCardGDPL, value)
	local info = self.tbCardStorage[szCardGDPL];
	assert(info, szCardGDPL);
	local nTask = info[1];
	local nBit = info[2];
	local nVal = pPlayer.GetTask(self.TASKGID, nTask);
	nVal = Lib:SetBits(nVal, value, nBit, nBit+1);
	pPlayer.SetTask(self.TASKGID, nTask, nVal);
end

if MODULE_GAMECLIENT then

function XoyoChallenge:InitXoyoluTips()
	local tbTipsRef = {
		[1] = XoyoChallenge.tbNpcId2Data_id,
		[2] = XoyoChallenge.tbRoom2Data_id,
		[3] = XoyoChallenge.tbItem2Data_id,
	};
	
	local nXoyoluTipsCol = 4; -- 4列
	local nXoyoluTipsRow = math.ceil(XoyoChallenge.nCardNum/nXoyoluTipsCol);
	local nTipsRefIdx = 1;
	local nTipsRefId  = 1;	
	XoyoChallenge.tbTips = {};	
	for col = 1, nXoyoluTipsCol do
		for row = 1, nXoyoluTipsRow do
			if not self.tbTips[row] then
				table.insert(self.tbTips, {});
			end
			table.insert(self.tbTips[row], tbTipsRef[nTipsRefIdx][nTipsRefId].szCardGDPL);
			nTipsRefId = nTipsRefId + 1;
			if nTipsRefId > #tbTipsRef[nTipsRefIdx] then
				nTipsRefIdx = nTipsRefIdx + 1;
				nTipsRefId = 1;
				if not tbTipsRef[nTipsRefIdx] then
					return;
				end
			end
		end
	end
end

-- 获取逍遥录tips
-- 返回一个string
function XoyoChallenge:GetXoyoluTips(pPlayer)
	local szTips = "";
	szTips = "<color=green>已收集（"..self:GetGatheredCardNum(pPlayer).."/"..self:GetTotalCardNum().."）张卡片<color>\n\n";
	for _, tbRow in ipairs(self.tbTips) do
		local tbSz = {};
		local nCount = 0;
		for _, szCardGDPL in ipairs(tbRow) do
			local nShowLen = GetTextShowLen(self.tbCardStorage[szCardGDPL].szDesc);
			local szEntry = self.tbCardStorage[szCardGDPL].szDesc;
			nCount = nCount + 1;
			if (nCount % 4 ~= 0) then				-- 4列一行，最后的不用补空格
				for i=1, 10 - nShowLen do
					szEntry = szEntry .. " ";
				end
			end			
			if self:GetCardState(pPlayer, szCardGDPL) == 2 then
				szEntry = "<color=yellow>" .. szEntry .. "<color>";
			end
			table.insert(tbSz, szEntry);
		end
		
		for _, sz in ipairs(tbSz) do
			szTips = szTips .. sz;
		end
		szTips = szTips .. "\n";
	end	
	
	return szTips;
end

end

-- 可否物品换卡片
-- return 1 or 0, szMsg
function XoyoChallenge:CanHandUpItemForCard(pPlayer)
	local nRes, szMsg = self:GetXoyoluState(pPlayer, tonumber(GetLocalDate("%Y%m")));
	if nRes == 0 then
		return 0, szMsg;
	end
	return 1;
end


-- 可否获取特殊卡
-- tbItems为Dialog:OpenGift返回的对象表
-- return 1 or 0, szMsg
function XoyoChallenge:CanGetSpecialCard(pPlayer, _nToday)
	local nToday;
	if _nToday then
		nToday = _nToday;
	else
		nToday = tonumber(GetLocalDate("%Y%m%d"));
	end
	
	local nRes, szMsg = self:GetXoyoluState(pPlayer, math.floor(nToday/100));
	
	if nRes == 0 then
		return 0, szMsg;
	end
	
	local nLastGetDate = pPlayer.GetTask(self.TASKGID, self.TASK_SPECIAL_CARD_DATE);
	if nToday > nLastGetDate then
		pPlayer.SetTask(self.TASKGID, self.TASK_SPECIAL_CARD_NUM, 0);
	end
	
	local nCardNum = pPlayer.GetTask(self.TASKGID, self.TASK_SPECIAL_CARD_NUM);
	if nCardNum >= self.MAX_SPECIAL_CARD_NUM then
		return 0, string.format("你今天已经换%d张卡了，明天再来吧。", nCardNum);
	end
	
	if pPlayer.CountFreeBagCell() < self.MAX_SPECIAL_CARD_NUM then
		return 0, string.format("Hành trang không đủ chỗ trống。请空出%d格再来领取。", self.MAX_SPECIAL_CARD_NUM);
	end
	
	return 1;
end

-- 尝试获取特殊卡
-- tbItems为Dialog:OpenGift返回的对象表
-- return 1 or 0, szMsg
function XoyoChallenge:GetSpecialCard(pPlayer, tbItems)
	local nToday = tonumber(GetLocalDate("%Y%m%d"));
	local nRes, szMsg = self:CanGetSpecialCard(pPlayer, nToday);
	if nRes == 0 then
		return nRes, szMsg;
	end
	
	local nCardNum = pPlayer.GetTask(self.TASKGID, self.TASK_SPECIAL_CARD_NUM);
	local tbXoyoItem = {}; -- 逍遥谷成品表
	local nItemNum = 0;
	for _, tbItem in ipairs(tbItems) do
		local pItem = tbItem[1];
		if pItem.szClass == "xoyoitem" then
			table.insert(tbXoyoItem, pItem);
			nItemNum = nItemNum + pItem.nCount;
		end
	end
		
	local nGetCardNum = 0;
	local nCanGiveNum = math.min(self.MAX_SPECIAL_CARD_NUM - nCardNum, nItemNum);
	for i = 1, nCanGiveNum do
		local pItem = pPlayer.AddItem(unpack(self.tbSpecialCard));
		if pItem then
			self:__RemoveItem(pPlayer, 1, tbXoyoItem);
			nGetCardNum = nGetCardNum + 1;
		else
			break;
		end
	end
	
	if nGetCardNum > 0 then
		pPlayer.SetTask(self.TASKGID, self.TASK_SPECIAL_CARD_NUM, nGetCardNum + nCardNum);
		pPlayer.SetTask(self.TASKGID, self.TASK_SPECIAL_CARD_DATE, nToday);
	end
	
	return 1;
end

-- 上交物品获得卡片，尽可能多的匹配
-- 如果得到卡片的话就作相应记录
-- tbItems为Dialog:OpenGift返回的对象表
function XoyoChallenge:HandUpItemForCard(pPlayer, tbItems, tbItem2Data)
	if self:CanHandUpItemForCard(pPlayer) == 0 then
		return 0;
	end
	
	local tbItemsSorted = {}; -- "g,d,p,l" --> {pItem1, pItem2...}
		
	for _, tbItem in ipairs(tbItems) do
		local szKey = tbItem[1].SzGDPL();
		if tbItemsSorted[szKey] then
			table.insert(tbItemsSorted[szKey], tbItem[1]);
		elseif self.tbItem2Data[szKey] then
			tbItemsSorted[szKey] = {tbItem[1]};
		end
	end
	
	local nAlreadyHasSomeCard = 0;
	for k, tbItem in pairs(tbItemsSorted) do
		if self:HasItem(pPlayer, self.tbItem2Data[k].tbCardGDPL) == 0 
			and self:GetCardState(pPlayer, self.tbItem2Data[k].szCardGDPL) ~= 2 then
			local nNeededNum = self.tbItem2Data[k].nNeededNum;
			local nItemNum = 0;
			for _, pItem in ipairs(tbItem) do
				nItemNum = nItemNum + pItem.nCount;
			end
			
			if nItemNum >= nNeededNum then
				local tbData = self.tbItem2Data[k];
				
				if pPlayer.CountFreeBagCell() < 1 then
					return 0, "Hành trang không đủ chỗ trống.";
				end
				
				local nRes = self:_TryGiveCard(pPlayer, tbData);
				if nRes == 1 then
					self:__RemoveItem(pPlayer, nNeededNum, tbItem);
				else
					return 0;
				end
			end
		else
			nAlreadyHasSomeCard = 1;
		end
	end
	
	local szMsg;
	if nAlreadyHasSomeCard == 1 then
		szMsg = "有一些卡片你已经收集过啦，这回就先不再给你了。";
	end
	return 1, szMsg;
end

-- 获取卡片换物品的信息
function XoyoChallenge:ItemForCardDesc()
	
	local szDesc = ""
	for _, v in ipairs(self.tbItem2Data_id) do
		local szItemName = string.format("%-8s",KItem.GetNameById(unpack(v.tbItemGDPL)));
		local szCardName = KItem.GetNameById(unpack(v.tbCardGDPL));
		szDesc = szDesc .. string.format("%s%s<enter>", szItemName .. " x " .. tostring(v.nNeededNum) .. ":", szCardName);
	end
	return szDesc;
end

-- 把tbItem中nNeededNum数量的道具删除掉
-- 处理了可叠加道具的情况
-- 外界需要保证tbItem中道具数量足够多
function XoyoChallenge:__RemoveItem(pPlayer, nNeededNum, tbItem)
	local nDeletedNum = 0;
	while nDeletedNum < nNeededNum do
		local pItem = table.remove(tbItem);
		local nCanDelete = math.min(nNeededNum - nDeletedNum, pItem.nCount);
		local nNewCount = pItem.nCount - nCanDelete;
		if nNewCount == 0 then
			pItem.Delete(pPlayer);
		else
			pItem.SetCount(nNewCount, Item.emITEM_DATARECORD_REMOVE);
			table.insert(tbItem,pItem);
		end
		assert(nCanDelete > 0);
		nDeletedNum = nDeletedNum + nCanDelete;
	end
	assert(nDeletedNum == nNeededNum);
end

-- 杀死npc给队员卡片
function XoyoChallenge:KillNpcForCard(pPlayer, pNpc)
	if not pPlayer then
		return 0;
	end
	
	local nNpcTemplateId = pNpc.nTemplateId;
	if not self.tbNpcId2Data[nNpcTemplateId] then
		return 0;
	end
	
	local tbCandidatePlayer = {pPlayer};
	local nTeamId = pPlayer.nTeamId;
	if nTeamId > 0 then
		local tbPlayerList = KNpc.GetAroundPlayerList(pNpc.dwId, 50);
		for _, pPlayerNearby in ipairs(tbPlayerList) do
			if pPlayerNearby.nTeamId == nTeamId and pPlayer.nId ~= pPlayerNearby.nId then
				table.insert(tbCandidatePlayer, pPlayerNearby);
			end
		end
	end
	
	for _, pPlayer in ipairs(tbCandidatePlayer) do
		local nRes, tbData = self:_Check(pPlayer, nNpcTemplateId, self.tbNpcId2Data);
		if nRes == 1 then
			local nRand = math.floor(MathRandom(1, 100) / XoyoGame.CARD_RATE_TIMES);
			if nRand <= tbData.nDropRate then
				self:_TryGiveCard(pPlayer, tbData);
			end
		end
	end
end

-- 过房间获得卡片
-- 如果得到卡片的话就作相应记录并返回1
-- 得不到卡片就返回0
function XoyoChallenge:PassRoomForCard(pPlayer, nRoomId)
	local nRes, tbData = self:_Check(pPlayer, nRoomId, self.tbRoom2Data);
	if nRes == 0 then
		return 0;
	end
	local nRand = math.floor(MathRandom(1, 100) / XoyoGame.CARD_RATE_TIMES);
	if nRand <= tbData.nDropRate then
		self:_TryGiveCard(pPlayer, tbData);
	end
end

-- 找背包和储物箱看看有没有这个东西
function XoyoChallenge:HasItem(pPlayer, tbGDPL)
	local tb1 = pPlayer.FindItemInRepository(unpack(tbGDPL)); 
	local tb2 = pPlayer.FindItemInBags(unpack(tbGDPL));
	if not tb1[1] and not tb2[1] then
		return 0;
	else
		return 1;
	end
end

-- 获取玩家逍遥录状态
-- 那里都没有的话返回0, szMsg
-- 有的话返回1
function XoyoChallenge:GetXoyoluState(pPlayer, nCurrYearMonth)
	if not nCurrYearMonth then
		nCurrYearMonth = tonumber(GetLocalDate("%Y%m"));
	end
	
	local nGetXoyoluMonth = pPlayer.GetTask(self.TASKGID, self.TASK_GET_XOYOLU_MONTH);
	--local nHandUpXoyoluMonth = pPlayer.GetTask(self.TASKGID, self.TASK_HANDUP_XOYOLU_MONTH);
	
	if nGetXoyoluMonth < nCurrYearMonth then
		return 0, "你这个月还没领逍遥录啊。";
	end
	
	--if nHandUpXoyoluMonth == nGetXoyoluMonth then 
	--	return 0, self:MsgAlreadyHandUp(pPlayer);
	--end	
	
	return 1;
end

function XoyoChallenge:_Check(pPlayer, key, tb)
	local tbData = tb[key];
	if not tbData then
		return 0;
	end
	
	if self:HasItem(pPlayer, tbData.tbCardGDPL) == 1 then -- 身上已有卡片
		return 0;
	end
	
	local nCurrYearMonth = tonumber(os.date("%Y%m", GetTime()));
	
	if self:GetXoyoluState(pPlayer, nCurrYearMonth) == 0 then -- 没有逍遥录
		return 0;
	end
		
	local nCardState = self:GetCardState(pPlayer, tbData.szCardGDPL);
	if nCardState == 2 then -- 已经放入逍遥录（已使用）
		return 0;
	end
	
	if pPlayer.CountFreeBagCell() < 1 then
		return 0;
	end
	
	return 1, tbData;
end

function XoyoChallenge:_TryGiveCard(pPlayer, tbData)
	local pItem = pPlayer.AddItem(unpack(tbData.tbCardGDPL));
	
	if not pItem then
		return 0;
	end
	
	if self.tbCardStorage[tbData.szCardGDPL].nWeight >= 10 then
		pPlayer.SendMsgToFriend("Hảo hữu ["..pPlayer.szName.."]在逍遥录收集任务中获得一张" .. pItem.szName .. "。");
	end
	
	return 1;
end

-- 清除卡片记录
function XoyoChallenge:ClearCardRecord(pPlayer)
	for i = self.TASK_NPC_BEGIN, self.TASK_END - 1 do
		pPlayer.SetTask(self.TASKGID, i, 0);
	end
end

-- 清除全部记录
function XoyoChallenge:Clear(pPlayer)
	for task = self.TASK_NPC_BEGIN, self.TASK_GET_AWARD_MONTH do
		pPlayer.SetTask(self.TASKGID, task, 0);
	end
end

-- 可否获取逍遥录
-- return 1 or 0, szMsg
function XoyoChallenge:CanGetXoyolu(pPlayer)
	if TimeFrame:GetState("OpenXoyoGameTask") ~= 1 then
		return 0;
	end
	
	local nCurrYearMonth, nPrevMonth = XoyoChallenge:__GetYearMonth();
	local nPrevGetMonth = pPlayer.GetTask(self.TASKGID, self.TASK_GET_XOYOLU_MONTH);
	local nGetAwardMonth = pPlayer.GetTask(self.TASKGID, self.TASK_GET_AWARD_MONTH);

	if nCurrYearMonth == 200907 and Task.IVER_nXoyo_GetAward_Fix == 1 then
		local nGetAwardCopy = pPlayer.GetTask(self.TASKGID, self.TASK_GET_AWARD_MONTH_COPY);
		if nPrevGetMonth == nPrevMonth and nGetAwardCopy == 0 then
			return 0, "你上个月的奖励还没领取，先把奖励领了再来拿逍遥录吧！";
		end
	else
		if nPrevGetMonth == nPrevMonth and nGetAwardMonth < nPrevMonth then
			return 0, "你上个月的奖励还没领取，先把奖励领了再来拿逍遥录吧！";
		end
	end
	
	if nPrevGetMonth >= nCurrYearMonth then
		return 0, "这个月已经给过你一本了，本小姐记性可是好得很，别想忽悠我。";
	end
	
	if pPlayer.CountFreeBagCell() < 1 then
		return 0, "Hành trang không đủ chỗ trống,清空一格再来领取逍遥录吧！";
	end
	
	return 1;
end

-- 获取逍遥录
-- return 1 or 0
function XoyoChallenge:GetXoyolu(pPlayer)
	local nRes, szMsg = self:CanGetXoyolu(pPlayer);
	if nRes == 0 then
		return 0, szMsg;
	end
	
	local nYearMonth = tonumber(GetLocalDate("%Y%m"));
	local pItem = pPlayer.AddItem(unpack(self.tbXoyolu));
	
	if not pItem then
		return 0;
	end
	
	self:ClearCardRecord(pPlayer);
	pPlayer.SetTask(self.TASKGID, self.TASK_GET_XOYOLU_MONTH, nYearMonth);
	return 1;
end

-- 背包里有没有逍遥录
function XoyoChallenge:HasXoyoluInBags(pPlayer)
	local tbFind = pPlayer.FindItemInBags(unpack(self.tbXoyolu));
	if not tbFind[1] then
		return 0;
	end
	return 1, tbFind[1].pItem;
end

-- 可否上交逍遥录
-- bDontCheckBag: 不检查背包
--function XoyoChallenge:CanHandUpXoyolu(pPlayer, bDontCheckBag)
--	local nCurrYearMonth = tonumber(os.date("%Y%m"));
--	local nPrevYearMonth = pPlayer.GetTask(self.TASKGID, self.TASK_HANDUP_XOYOLU_MONTH);
--	if nCurrYearMonth == nPrevYearMonth then
--		return 0, "这个月你已经交过逍遥录啦，下个月再来领奖吧！";
--	end
--	
--	if not bDontCheckBag then
--		local nRes, pItem = self:HasXoyoluInBags(pPlayer);
--		if  nRes == 0 then
--			return 0, "你身上的逍遥录呢?";
--		end
--	end
--	
--	return 1;
--end


-- 上交逍遥录
-- return 1, szMsg or 0, szMsg
--function XoyoChallenge:HandUpXoyolu(pPlayer, tbItems)
--	local pXoyolu;
--	
--	for _, tbItem in ipairs(tbItems) do
--		local pItem = tbItem[1];
--		if pItem.Equal(unpack(self.tbXoyolu)) == 1 then
--			pXoyolu = pItem;
--			break;
--		end
--	end
--	
--	if not pXoyolu then
--		return 0, "你的逍遥录呢？我怎么看不到啊？";
--	end
--	
--	local nRes = self:CanHandUpXoyolu(pPlayer, 1);
--	if nRes == 0 then
--		return 0, szMsg;
--	end
--	
--	local nFinishedNum = 0; -- 完成了几个任务
--	local nTotalWeight = 0;
--	for k, v in pairs(self.tbCardStorage) do
--		if self:GetCardState(pPlayer, k) == 2 then
--			nFinishedNum = nFinishedNum + 1;
--			nTotalWeight = nTotalWeight + v.nWeight;
--		end
--	end
--	
--	local nPoints = nFinishedNum * 10000 + nTotalWeight;
--	
--	if nPoints == 0 then
--		return 0, "你一张卡片都没收集到就要交把逍遥录上来啦？";
--	end
--	
--	PlayerHonor:SetPlayerXoyoPointsByName(pPlayer.szName, nPoints);
--	
--	pXoyolu.Delete(pPlayer);
--	self:ClearCardRecord(pPlayer);
--	local nGetXoyoluMonth = pPlayer.GetTask(self.TASKGID, self.TASK_GET_XOYOLU_MONTH);
--	pPlayer.SetTask(self.TASKGID, self.TASK_HANDUP_XOYOLU_MONTH, nGetXoyoluMonth);
--	
--	Dbg:WriteLog("XoyoChallenge:HandUpXoyolu", "points:" .. tostring(nPoints) .. "player:" .. pPlayer.szName);
--	
--	return 1, string.format("你这个月交上来的逍遥录里共收集了<color=green>%d/%d<color>张卡片，本小姐已经记下来了，等下个月1号排名出来后再来领奖吧。",
--		nFinishedNum, self.nCardNum);
--	
--	-- GC GS同步需要时间，不能调MsgAlreadyHandUp
--	--return 1, self:MsgAlreadyHandUp(pPlayer); 
--end

function XoyoChallenge:TransRange(tbRange, nMax)
	local tbRes = {}
	local n = 1
	for _, v in ipairs(tbRange) do
		n = n*(v+1)
		table.insert(tbRes,n)
	end
	local max = table.remove(tbRes)
	if not nMax then nMax = 2147483648 end
	assert(max < nMax)
	table.insert(tbRes, 1, 0)
	return tbRes
end

function XoyoChallenge:PackNumber(tbR, tbData)
	local n = 0;
	local i = #tbData;
	while i > 1 do
		n = n + tbData[i]*tbR[i]
		i = i - 1
	end
	n = n + tbData[1]
	return n
end

function XoyoChallenge:UnpackNumber(tbR, nNum)
	local tbRes = {}
	local i = #tbR
	while i > 1 do
		table.insert(tbRes, 1, math.floor((nNum)/tbR[i]))
		nNum = math.fmod(nNum, tbR[i])
		i = i - 1
	end
	table.insert(tbRes, 1, nNum)
	return tbRes
end

-- 获取当前任务变量记录的总分
function XoyoChallenge:GetTotalPoint(pPlayer)
	local tbTime = os.date("*t", GetTime());
	local nMinRemain = self.MINUTE_OF_MONTH - (tbTime.day*1440 + tbTime.hour*60 + tbTime.min);
	local nCardNum = 0;
	local nWeightSum = 0;
	
	for szCardGDPL, tbData in pairs(self.tbCardStorage) do
		if self:GetCardState(pPlayer, szCardGDPL) == 2 then
			nCardNum = nCardNum+1;
			nWeightSum = nWeightSum+tbData.nWeight;
		end
	end
	
	if nCardNum > 0 then
		return self:PackNumber(self.__tbRange, {nMinRemain, nWeightSum, nCardNum});
	else
		return 0;
	end
end

-- 获取排行榜描述
function XoyoChallenge:GetLadderDesc(nPoints)
	local tbData = self:UnpackNumber(self.__tbRange, nPoints);
	local nCardNum = tbData[3];
	local nLastUseCardDate = tbData[1]
	local tbTime = os.date("*t", GetTime());
	local nMonth = tbTime.month
	if tbTime.day == 1 then -- 1号看到的还是上个月的排名
		if nMonth == 1 then
			nMonth = 12;
		else
			nMonth = nMonth - 1;
		end
	end
	local nDay = math.floor((self.MINUTE_OF_MONTH - nLastUseCardDate)/1440);
	local nHour = math.floor((self.MINUTE_OF_MONTH -nLastUseCardDate - nDay*1440)/60);
	local nMin = self.MINUTE_OF_MONTH - nLastUseCardDate - nDay*1440 - nHour*60;
	local szContext = string.format("%d张\n最后卡片使用时间：%d月%d日 %.2d:%.2d", nCardNum, nMonth, nDay, nHour, nMin);
	local szTxt1 = string.format("%d张", nCardNum);
	return szContext, szTxt1;
end

-- 排行榜分数转换为卡片数
function XoyoChallenge:Point2CardNum(nPoints)
	return self:UnpackNumber(self.__tbRange, nPoints)[3];
end
 
-- 使用卡片
-- return 1, or 0, szMsg
function XoyoChallenge:UseCard(pPlayer, pCard)
	if self:HasXoyoluInBags(pPlayer) == 0 then
		return 0, "你身上没有逍遥录，不能使用卡片。快到逍遥谷晓菲那儿领一本吧。";
	end
	
	if self:GetCardState(pPlayer, pCard.SzGDPL()) == 2 then
		return 0, "你本月已经收集过这张卡片了。";
	end
	
	self:SetCardState(pPlayer, pCard.SzGDPL(), 2);
	pCard.Delete(pPlayer);
	SpecialEvent.ActiveGift:AddCounts(pPlayer, 20);		--收集逍遥谷卡片活跃度
	local nPrevPoint = GetXoyoPointsByName(pPlayer.szName); -- 这个月的点数
	local nCurrPoint = self:GetTotalPoint(pPlayer);
	if nCurrPoint > nPrevPoint then
		PlayerHonor:SetPlayerXoyoPointsByName(pPlayer.szName, nCurrPoint);
	end
	
	return 1;
end

function XoyoChallenge:__GetYearMonth()
	local tbTime = os.date("*t", GetTime());
	local nYearMonth = tbTime.year * 100 + tbTime.month;
	local nPrevMonth;
	if tbTime.month == 1 then
		nPrevMonth = (tbTime.year - 1)*100 + 12;
	else
		nPrevMonth = nYearMonth - 1;
	end
	return nYearMonth, nPrevMonth;
end

function XoyoChallenge:CanGetAward(pPlayer)
	local nLastGetAwardMonth = pPlayer.GetTask(self.TASKGID, self.TASK_GET_AWARD_MONTH);
	local nGetXoyoluMonth    = pPlayer.GetTask(self.TASKGID, self.TASK_GET_XOYOLU_MONTH);
	local nYearMonth, nPrevMonth = self:__GetYearMonth();
	
	if nYearMonth == 200907 and Task.IVER_nXoyo_GetAward_Fix == 1  then
		local nGetAwardCopy = pPlayer.GetTask(self.TASKGID, self.TASK_GET_AWARD_MONTH_COPY);
		if nGetAwardCopy > 0 then
			return 0, "你这个月已经领过奖了，别想忽悠本小姐。";
		end
	else
		if nLastGetAwardMonth >= nPrevMonth then
			return 0, "你这个月已经领过奖了，别想忽悠本小姐。";
		end
	end
	
	if nPrevMonth > nGetXoyoluMonth then -- 很久前领的逍遥录
		return 0, "你上个月没领逍遥录，还想要奖励？";
	end
	
	if nYearMonth == nGetXoyoluMonth then -- 当月领的逍遥录，尚未排名
		return 0, "你这个月领了逍遥录，下个月再来领奖吧。";
	end
	
	if KGblTask.SCGetDbTaskInt(DBTASK_XOYO_FINAL_LADDER_MONTH) ~= nYearMonth then
		return 0, "上个月排名还没出来呢。";
	end
	
	if nYearMonth == 200907 and Task.IVER_nXoyo_GetAward_Fix == 1  then
		local nGetAwardCopy = pPlayer.GetTask(self.TASKGID, self.TASK_GET_AWARD_MONTH_COPY);
		assert(nGetXoyoluMonth == nPrevMonth);
		assert(nGetAwardCopy == 0);
	else
		assert(nGetXoyoluMonth == nPrevMonth);
		assert(nLastGetAwardMonth < nPrevMonth);
	end
	
	return 1, nYearMonth, nPrevMonth;
end

function XoyoChallenge:GetAwardType(nRank)
	local nRankType = 5;
	if (3 == EventManager.IVER_nXoyoGameTaskAwardType) then
		nRankType = 6
		if nRank > 0 and nRank <= 1 then
			nRankType = 1;
		elseif nRank > 1 and nRank <= 10 then
			nRankType = 2;
		elseif nRank > 10 and nRank <= 50 then
			nRankType = 3;
		elseif nRank > 50 and nRank <= 150 then
			nRankType = 4;
		elseif nRank > 150 and nRank <= 500 then
			nRankType = 5;
		end		
	else
		if nRank > 0 and nRank <= 10 then
			nRankType = 1;
		elseif nRank > 10 and nRank <= 100 then
			nRankType = 2;
		elseif nRank > 100 and nRank <= 500 then
			nRankType = 3;
		elseif nRank > 500 and nRank <= 1500 then
			nRankType = 4;
		end
	end
	return nRankType;
end

function XoyoChallenge:GetAwardTable()
	local tbFinishAward = {};
	tbFinishAward[1] = {
		--大陆,马来
		[1]=
		{
			[1] = --1-10
			{
				{tbItem={18,1,114,10}, nCount=1, nTime=43200},
				{tbItem={18,1,114,9},  nCount=2, nTime=43200},
			},
			[2] = --11-100
			{
				{tbItem={18,1,114,9},	 nCount=3, nTime=43200},
			},
			[3] = --101-500
			{
				{tbItem={18,1,114,9},  nCount=1, nTime=43200},
				{tbItem={18,1,114,8},  nCount=2, nTime=43200},
			},
			[4] = --501-1500
			{
				{tbItem={18,1,114,8},  nCount=3, nTime=43200},
			},
			[5] = --1501-3000或24张卡
			{
				{tbItem={18,1,114,8},  nCount=1, nTime=43200},
				{tbItem={18,1,114,7},  nCount=2, nTime=43200},
			},
		}, 
		--越南版
		[2]=
		{
			[1] = {{tbItem={18,1,460,2},  nCount=5, nTime=43200}},--1-10
			[2] = {{tbItem={18,1,460,2},  nCount=3, nTime=43200}},--11-100
			[3] = {{tbItem={18,1,460,2},  nCount=2, nTime=43200}},--101-500
			[4] = {{tbItem={18,1,460,2},  nCount=1, nTime=43200}},--501-1500
			[5] = {{tbItem={18,1,460,1},  nCount=2, nTime=43200}},--1501-3000或24张卡
		}, 
		[3]= -- 盛大版
		{
			[1] = --1
			{
				{tbItem={18,1,114,10},	nCount=1, nTime=43200},
				{tbItem={18,1,114,9},	nCount=2, nTime=43200},
			},
			[2] = --2-10
			{
				{tbItem={18,1,114,10},	nCount=1, nTime=43200},
				{tbItem={18,1,114,9},	nCount=1, nTime=43200},
			},
			[3] = --11-50
			{
				{tbItem={18,1,114,9},	nCount=3, nTime=43200},
			},
			[4] = --51-150
			{
				{tbItem={18,1,114,9},	nCount=2, nTime=43200},
			},
			[5] = --151-500
			{
				{tbItem={18,1,114,9},	nCount=1, nTime=43200},
			},
			[6] = --24张卡
			{
				{tbItem={18,1,114,8},	nCount=2, nTime=43200},
			},
		}, 	
	};
	tbFinishAward[2] = {
		--大陆,马来
		[1]=
		{
			[1] = --1-10
			{
				{tbItem={18,1,114,10}, nCount=1, nTime=43200},
				{tbItem={18,1,114,9},  nCount=3, nTime=43200},
			},
			[2] = --11-100
			{
				{tbItem={18,1,114,10}, nCount=1, nTime=43200},
			},
			[3] = --101-500
			{
				{tbItem={18,1,114,9},  nCount=1, nTime=43200},
				{tbItem={18,1,114,8},  nCount=3, nTime=43200},
			},
			[4] = --501-1500
			{
				{tbItem={18,1,114,9},  nCount=1, nTime=43200},
			},
			[5] = --1501-3000或24张卡
			{
				{tbItem={18,1,114,8},  nCount=1, nTime=43200},
				{tbItem={18,1,114,7},  nCount=3, nTime=43200},
			},
		}, 
		--越南版
		[2]=
		{
			[1] = {{tbItem={18,1,460,2},  nCount=5, nTime=43200}},--1-10
			[2] = {{tbItem={18,1,460,2},  nCount=3, nTime=43200}},--11-100
			[3] = {{tbItem={18,1,460,2},  nCount=2, nTime=43200}},--101-500
			[4] = {{tbItem={18,1,460,2},  nCount=1, nTime=43200}},--501-1500
			[5] = {{tbItem={18,1,460,1},  nCount=2, nTime=43200}},--1501-3000或24张卡
		},
		[3]= -- 盛大版
		{
			[1] = --1
			{
				{tbItem={18,1,114,10},	nCount=1, nTime=43200},
				{tbItem={18,1,114,9},	nCount=2, nTime=43200},
			},
			[2] = --2-10
			{
				{tbItem={18,1,114,10},	nCount=1, nTime=43200},
				{tbItem={18,1,114,9},	nCount=1, nTime=43200},
			},
			[3] = --11-50
			{
				{tbItem={18,1,114,9},	nCount=3, nTime=43200},
			},
			[4] = --51-150
			{
				{tbItem={18,1,114,9},	nCount=2, nTime=43200},
			},
			[5] = --151-500
			{
				{tbItem={18,1,114,9},	nCount=1, nTime=43200},
			},
			[6] = --24张卡
			{
				{tbItem={18,1,114,8},	nCount=2, nTime=43200},
			},
		},
	};
	return tbFinishAward;
end

-- 给奖励
-- return 1, or 0, szMsg
function XoyoChallenge:GetAward(pPlayer)
	local nRes, var, nPrevMonth = self:CanGetAward(pPlayer);
	if nRes == 0 then
		return nRes, var;
	end
	
	local nYearMonth = var;
	local nRank = GetXoyoPointsRank(pPlayer.szName);
	local nLastMonthPoint = GetXoyoLastPointsByName(pPlayer.szName); -- 上个月的点数
	local nCardNum = self:Point2CardNum(nLastMonthPoint);
	
	if (not ((0 <nRank and nRank <= EventManager.IVER_nXoyoGameTaskAwardMaxRank) or nCardNum>=24 )) or -- 最后一个条件是排不上名次，但收集了24+张卡
		(nYearMonth <= 200909 and self:GetGatheredCardNum(pPlayer) <= 0) -- 上个月卡片数为0
	then 
		--SetXoyoPointsRank(pPlayer.szName, 0);
		pPlayer.SetTask(self.TASKGID, self.TASK_GET_AWARD_MONTH, nPrevMonth);
		pPlayer.SetTask(self.TASKGID, self.TASK_GET_AWARD_MONTH_COPY, nPrevMonth);
		
		local szLog = string.format("玩家名：%s 无奖励。 名次: %d, 分数: %d, 卡片收集数:% d", 
			pPlayer.szName, nRank, nLastMonthPoint, nCardNum);
		Dbg:WriteLog("XoyoChallenge:GetAward", szLog);
		pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "逍遥谷挑战领奖：" .. szLog);
		
		return 0, "我这里没有你的奖励记录，请继续努力吧。";
	end
	
	local tbFinishAward = self:GetAwardTable();

	local nRankType = self:GetAwardType(nRank); -- 获取奖励类型
	local nCanGetKinAward = self:CanGetKinAwardEx(pPlayer) or 0;
	local tbGiveAward = tbFinishAward[nCanGetKinAward+1][EventManager.IVER_nXoyoGameTaskAwardType][nRankType];

	-- 宝石奖励表	
	local tbStoneAward = 
	{
		[1] = {{tbItem={18,1,1294,1}, nCount=13}},
		[2] = {{tbItem={18,1,1294,1}, nCount=11}},
		[3] = {{tbItem={18,1,1294,1}, nCount=7}},
		[4] = {{tbItem={18,1,1294,1}, nCount=5}},
		[5] = {{tbItem={18,1,1294,1}, nCount=2}},
	}
	-- 开放宝石了，才送宝石相关的奖励
	if Item.tbStone:GetOpenDay() ~= 0 then
		-- todo 逍遥暂时不产出
		--Lib:MergeTable(tbGiveAward, tbStoneAward[nRankType]);
	end	
	

	local nBagCount = 0;
	for _, tbTemp in ipairs(tbGiveAward) do
		nBagCount = nBagCount + tbTemp.nCount;
	end
	if pPlayer.CountFreeBagCell() < nBagCount then
		return 0, string.format("清理好背包再来领奖吧。<color=red>（需要%s格背包空间。）<color>", nBagCount);
	end
	local szAwardName = "";
	
	for _, tbTemp in ipairs(tbGiveAward) do
		local nAddCount = 0;
		local szItemName;
		for i=1, tbTemp.nCount do
			local pItem = pPlayer.AddItem(unpack(tbTemp.tbItem));
			if pItem then 
				if tbTemp.nTime then
					pPlayer.SetItemTimeout(pItem, tbTemp.nTime, 0);
					pItem.Sync();
				end
				nAddCount   = nAddCount  + 1;
				szItemName = pItem.szName;
			end
		end
		if szAwardName ~= "" then
			szAwardName = szAwardName .. "，";
		end
		szAwardName  = szAwardName .. string.format("%s个%s", tbTemp.nCount, szItemName);
		Item:CheckXJRecord(Item.emITEM_XJRECORD_EVENT, "逍遥录奖励", 
			{tbTemp.tbItem[1], tbTemp.tbItem[2], tbTemp.tbItem[3], tbTemp.tbItem[4], 1, nAddCount});
	end
	
	SetXoyoPointsRank(pPlayer.szName, 0);
	pPlayer.SetTask(self.TASKGID, self.TASK_GET_AWARD_MONTH, nPrevMonth); -- 领取的是那个月的奖励
	pPlayer.SetTask(self.TASKGID, self.TASK_GET_AWARD_MONTH_COPY, nPrevMonth);
	--成就 
		 XoyoGame.Achievement:XoyoRank(pPlayer,nRank);
		 XoyoGame.Achievement:XoyoCardNum(pPlayer,nCardNum);
	--
	--log
	local szLog = string.format("玩家名：%s 奖励: %s, 名次: %d, 分数: %d 卡片收集数: %d", 
		pPlayer.szName, szAwardName, nRank, nLastMonthPoint, nCardNum);
	Dbg:WriteLog("XoyoChallenge:GetAward", szLog);
	pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "逍遥谷挑战领奖：" .. szLog);
	
	-- msg
	if 1 <= nRank and nRank <= 100 then
		if nCanGetKinAward == 1 then
			pPlayer.SendMsgToFriend(string.format("Hảo hữu [%s]在上个月的逍遥录收集任务中排名第%d位，家族的地狱逍遥积分排名前10，获得%s奖励。",
				pPlayer.szName, nRank, szAwardName));
		else
			pPlayer.SendMsgToFriend(string.format("Hảo hữu [%s]在上个月的逍遥录收集任务中排名第%d位，获得%s奖励。",
				pPlayer.szName, nRank, szAwardName));
		end
	end
	
	local szMsg;
	if nRank > 0 then
		szMsg = string.format("恭喜你在上个月的逍遥录收集任务获得第%d名！", nRank);
	else
		szMsg = string.format("你在上个月的逍遥录收集任务中收集了%d张卡片，干得不错哈！", nCardNum);
	end
		
	return 1, szMsg;
end

-- 家族是否在前10
function XoyoChallenge:CanGetKinAwardEx(pPlayer)
	local nKinId, nMemberId = pPlayer.GetKinMember();
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	local cMember = cKin.GetMember(nMemberId)
	if not cMember then
		return 0;
	end
	if cMember.GetFigure() == Kin.FIGURE_SIGNED then -- 记名成员不能享受加成
		return 0;
	end
	local nMonth = tonumber(GetLocalDate("%Y%m"));
	local nRecordMonth = KGblTask.SCGetDbTaskInt(DBTASK_XOYO_RANK_LAST_MONTH);
	if nMonth ~= nRecordMonth then	-- 比较数据版本，异常则不给
		return 0;
	end
	local tbAllXoyoKinRank = GetGblIntBuf(GBLINTBUF_XOYO_KIN_RANK, 0) or {}; -- 从buf里取，保证是最新的数据
	local tbKinRank = tbAllXoyoKinRank.tbLastRank or {};
	local szName = cKin.GetName();
	if tbKinRank and #tbKinRank > 0 then
		for nIndex, tbTemp in ipairs(tbKinRank) do
			if nIndex > XoyoGame.KIN_MAX_RANK then
				break;
			end
			if tbTemp.szName == szName then
				return 1;
			end
		end		
	end

	local tbAllXoyoKinRank = GetGblIntBuf(GBLINTBUF_XOYO_KIN_RANK_EX, 0) or {}; -- 从buf里取，保证是最新的数据
	local tbKinRank = tbAllXoyoKinRank.tbLastRank or {};
	if tbKinRank and #tbKinRank > 0 then
		for nIndex, tbTemp in ipairs(tbKinRank) do
			if nIndex > XoyoGame.KIN_MAX_RANK then
				break;
			end
			if tbTemp.szName == szName then
				return 1;
			end
		end		
	end

	return 0;
end

-- 随机一个卡片
-- return tbCardGDPL
function XoyoChallenge:GetRandomCard()
	local nRand = MathRandom(1, self.nProbabilitySum);
	local tbCardGDPL;
	for _, v in pairs(self.tbCardStorage_probability) do
		tbCardGDPL = v[2]; -- 保证返回有效值
		if nRand <= v[1] then
			break;
		end
	end
	return tbCardGDPL;
end

-- 获取已上交卡片数
function XoyoChallenge:GetGatheredCardNum(pPlayer)
	local nFinishedNum = 0;
	for k, _ in pairs(self.tbCardStorage) do
		if self:GetCardState(pPlayer, k) == 2 then
			nFinishedNum = nFinishedNum + 1;
		end
	end
	return nFinishedNum;
end

--function XoyoChallenge:MsgAlreadyHandUp(pPlayer)
--	local nPoint = GetXoyoPointsByName(pPlayer.szName); -- 这个月的点数
--	return string.format("你这个月交上来的逍遥录里一共收集了<color=green>%d/%d<color>张卡片，本小姐已经记下来了，等下个月1号排名出来后再来领奖吧。",
--		math.floor(nPoint / 10000), self.nCardNum);
--end

-- 获取卡片总数
function XoyoChallenge:GetTotalCardNum()
	return self.nCardNum;
end

function XoyoChallenge:GetAwardRemind()
	local nYearMonth, nPrevMonth = self:__GetYearMonth();
	local nPrevGetMonth = me.GetTask(self.TASKGID, self.TASK_GET_XOYOLU_MONTH);
	local nGetAwardMonth = me.GetTask(self.TASKGID, self.TASK_GET_AWARD_MONTH);
	local nGetAwardCopy = me.GetTask(self.TASKGID, self.TASK_GET_AWARD_MONTH_COPY);
	if nYearMonth == 200907 and Task.IVER_nXoyo_GetAward_Fix == 1 then
		if nPrevGetMonth == nPrevMonth and nGetAwardCopy == 0 and 
			KGblTask.SCGetDbTaskInt(DBTASK_XOYO_FINAL_LADDER_MONTH) == nYearMonth
		then
			me.Msg("Bạn chưa nhận phần thưởng Tiêu Dao Lục ở tháng trước, hãy mau đến nhận.");
		end
	else
		if nPrevGetMonth == nPrevMonth and nGetAwardMonth < nPrevMonth and
			KGblTask.SCGetDbTaskInt(DBTASK_XOYO_FINAL_LADDER_MONTH) == nYearMonth
		then
			me.Msg("Bạn chưa nhận phần thưởng Tiêu Dao Lục ở tháng trước, hãy mau đến nhận.");
		end
	end
end

function XoyoChallenge:__debug__output_curr_rank()
	me.Msg("__debug__output_curr_rank " .. GetLocalDate("%H:%M"))
	local tbName = {}
	for i = 1, 100 do 
		local szName = KGCPlayer.GetPlayerName(i)
		if not szName then
			break;
		end
		table.insert(tbName, szName)
	end
	
	for i, name in ipairs(tbName) do
		local nPoint = GetXoyoPointsByName(name);
		me.Msg(string.format("%-20s分数：%d",name, nPoint));
	end
end

XoyoChallenge:LoadFile();
XoyoChallenge:InitCardStorage();


if MODULE_GAMECLIENT then
	XoyoChallenge:InitXoyoluTips();
end

-- ?pl DoScript("\\script\\mission\\xoyogame\\xoyogame_task.lua")

if (MODULE_GC_SERVER) then
	
function XoyoChallenge:RefreshXoyoLadderGC()
	local nCurWeight = self.__tbRange[3];
	local nPreWeight = KGblTask.SCGetDbTaskInt(DBTASK_XOYOGAME_WEIGHT);
	if nCurWeight == nPreWeight then
		return;
	end
	if nPreWeight == 0 then
		KGblTask.SCSetDbTaskInt(DBTASK_XOYOGAME_WEIGHT, nCurWeight);
		return;
	end 		
	local tbRange = {};
	tbRange[1] = self.__tbRange[1]; 
	tbRange[2] = self.__tbRange[2];
	tbRange[3] = nPreWeight;
	local nType = 0;
	local tbLadderCfg = Ladder.tbLadderConfig[PlayerHonor.HONOR_CLASS_XOYOGAME];
	nType = Ladder:GetType(0, tbLadderCfg.nLadderClass, tbLadderCfg.nLadderType, tbLadderCfg.nLadderSmall);
	local tbShowLadder= GetTotalLadder(nType) or {};
	local nValue = 0;
	local nPrePoint = 0;
	local tbRes = nil;
	local nNewPoint = 0;
	for _,tbPlayerList in ipairs(tbShowLadder) do 
		nPrePoint = tbPlayerList["dwValue"];
		if nPrePoint > 0 then
			tbRes = self:UnpackNumber(tbRange, nPrePoint);			
			nNewPoint = self:PackNumber(self.__tbRange, tbRes);
			if nNewPoint > 0 then	
				PlayerHonor:SetPlayerXoyoPointsByName(tbPlayerList["szPlayerName"], nNewPoint);
			end
		end
	end
	PlayerHonor:UpdateXoyoLadder(0);
	KGblTask.SCSetDbTaskInt(DBTASK_XOYOGAME_WEIGHT, nCurWeight);
end

GCEvent:RegisterGCServerStartFunc(XoyoGame.XoyoChallenge.RefreshXoyoLadderGC, XoyoGame.XoyoChallenge);
end

if MODULE_GAMESERVER then
	
function XoyoChallenge:RefreshPlayerValue()
	local nPrevPoint = GetXoyoPointsByName(me.szName);
	local nPrevCardNum = self:Point2CardNum(nPrevPoint);
	local nCurrCardNum = self:GetGatheredCardNum(me);
	if nCurrCardNum == nPrevCardNum then
		return;
	end	
	local nCurrYearMonth = tonumber(GetLocalDate("%Y%m"));		
	local nGetXoyoluMonth = me.GetTask(self.TASKGID, self.TASK_GET_XOYOLU_MONTH);	
	if nCurrYearMonth ~= nGetXoyoluMonth then 
		return;
	end	
	local nValue = self:GetTotalPoint(me);
	if 0 == nValue then 
		return;
	end
	PlayerHonor:SetPlayerXoyoPointsByName(me.szName, nValue);
end

PlayerEvent:RegisterOnLoginEvent(XoyoChallenge.RefreshPlayerValue, XoyoChallenge);
PlayerEvent:RegisterOnLoginEvent(XoyoChallenge.GetAwardRemind, XoyoChallenge);
end
