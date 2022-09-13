-- 文件名　：define.lua
-- 创建者　：huangxiaoming
-- 创建时间：2011-05-17 09:46:10
-- 描  述  ：

Require("\\script\\event\\specialevent\\duanwu2011\\duanwu2011_def.lua");
SpecialEvent.DuanWu2011 = SpecialEvent.DuanWu2011 or {};
local tbDuanWu2011 = SpecialEvent.DuanWu2011 or {};

-- 使用物品检查
function tbDuanWu2011:CheckCanUse(pPlayer)
	if self:CheckOpen() ~= 1 then
		return 0, "现在不在活动期间，无法使用。";
	end
	if pPlayer.nLevel < tbDuanWu2011.PLAYER_LEVEL_LIMIT or pPlayer.nFaction <= 0 then
		return 0, "只有达到60级并且加入门派的玩家才能使用。";
	end
	return 1;
end

-- 制作粽子检查
function tbDuanWu2011:CheckCanMake(pPlayer, nNum)
	if self:CheckOpen() ~= 1 then
		return 0, "现在不在活动期间，无法制作。";
	end
	if GetMapType(pPlayer.nMapId) ~= "city" and GetMapType(pPlayer.nMapId) ~= "village" then
		return 0, "该物品只能在各大新手村和城市使用";
	end
	nNum = nNum or 1;
	local szErrMsg = "";
	if pPlayer.CountFreeBagCell() < 1 then
		szErrMsg = "Hành trang không đủ <color=yellow>1 ô<color> trống, không thể thao tác!";
		return 0, szErrMsg;
	end
	local nNeedGTPMKP = self.NUM_GTPMKP_MAKE * nNum;
	if (pPlayer.dwCurGTP < nNeedGTPMKP or pPlayer.dwCurMKP < nNeedGTPMKP) then
		szErrMsg = string.format("你的精活不足，制作<color=yellow>%s个<color>粽子需要消耗精力和活力各<color=yellow>%s点<color>。",nNum, nNeedGTPMKP);
		return 0, szErrMsg;
	end
	local nCanMakeNum = self:CheckTodayMakeRemainNum(pPlayer);
	if nCanMakeNum < nNum then
		szErrMsg = string.format("你今日最多还能制作<color>%s个<color>粽子。", nCanMakeNum);
		return 0, szErrMsg;
	end
	local nMaterialCount1 = pPlayer.GetItemCountInBags(unpack(self.ITEM_MATERIAL_MEAT_ID));
	local nMaterialCount2 = pPlayer.GetItemCountInBags(unpack(self.ITEM_MATERIAL_RICE_ID));
	local nMaterialCount3 = pPlayer.GetItemCountInBags(unpack(self.ITEM_MATERIAL_LEAF_ID));
	if nMaterialCount1 < nNum or nMaterialCount2 < nNum or nMaterialCount3 < nNum then
		szErrMsg = "做粽子的材料不足。制作每个粽子需要肉、糯米、粽叶各1份。";
		return 0, szErrMsg;
	end
	return 1;
end

-- 今日剩余制作个数
function tbDuanWu2011:CheckTodayMakeRemainNum(pPlayer)
	local nDay = Lib:GetLocalDay(GetTime());
	local nTaskDate = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_LAST_MAKE_DAY);
	if nTaskDate < nDay then
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_LAST_MAKE_DAY, nDay);
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_TODAY_MAKE_NUM, 0);
	end
	local nTodayNum = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_TODAY_MAKE_NUM);
	local nCanMakeNum = self.DAY_MAKE_NUM_LIMIT - nTodayNum;
	local nRemainNum = self.TOTAL_MAKE_NUM_LIMIT - pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_TOTAL_MAKE_NUM);
	if nCanMakeNum > nRemainNum then
		nCanMakeNum = nRemainNum;
	end
	return nCanMakeNum;
end

function tbDuanWu2011:MakeDumplingDlg(nCount, nSure)
	if nCount <= 0 then
		return 0;
	end
	local nRet, szErrMsg = self:CheckCanMake(me, nCount);
	if nRet ~= 1 then
		Dialog:Say(szErrMsg);
		return 0;
	end
	if not nSure then
		local szMsg = string.format("制作<color=yellow>%s个<color>粽子一共需要消耗精力、活力各<color=yellow>%s点<color>以及肉、糯米、棕叶各<color=yellow>%s份<color>。\n\n确定制作？", nCount, nCount * self.NUM_GTPMKP_MAKE, nCount);
		local tbOpt = 
		{
			{"Xác nhận", self.MakeDumplingDlg, self, nCount, 1},
			{"Để ta suy nghĩ thêm"},	
		};
		Dialog:Say(szMsg, tbOpt);
		return 1;
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
		
	GeneralProcess:StartProcess("肉粽加工中", 5 * Env.GAME_FPS, 
		{self.MakeDumpling, self, me.nId, nCount}, nil, tbEvent);
end

-- 真正做粽子
function tbDuanWu2011:MakeDumpling(nPlayerId, nCount)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	if self:CheckCanMake(pPlayer, nCount) ~= 1 then
		return 0;
	end
	pPlayer.ConsumeItemInBags(nCount, self.ITEM_MATERIAL_MEAT_ID[1], self.ITEM_MATERIAL_MEAT_ID[2], self.ITEM_MATERIAL_MEAT_ID[3], self.ITEM_MATERIAL_MEAT_ID[4], -1);
	pPlayer.ConsumeItemInBags(nCount, self.ITEM_MATERIAL_RICE_ID[1], self.ITEM_MATERIAL_RICE_ID[2], self.ITEM_MATERIAL_RICE_ID[3], self.ITEM_MATERIAL_RICE_ID[4], -1);
	pPlayer.ConsumeItemInBags(nCount, self.ITEM_MATERIAL_LEAF_ID[1], self.ITEM_MATERIAL_LEAF_ID[2], self.ITEM_MATERIAL_LEAF_ID[3], self.ITEM_MATERIAL_LEAF_ID[4], -1);
	local nNeedGTPMKP = self.NUM_GTPMKP_MAKE * nCount;
	pPlayer.ChangeCurGatherPoint(-nNeedGTPMKP);
	pPlayer.ChangeCurMakePoint(-nNeedGTPMKP);
	--[[for i = 1, nCount do
		local pItem = pPlayer.AddItem(unpack(self.ITEM_DUMPLING_MEAT_ID));
		if not pItem then
			Dbg:WriteLog("DuanWu2011", "dumpling failed", i, nCount);
			pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_TODAY_MAKE_NUM, pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_TODAY_MAKE_NUM) + i - 1);
			pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_TOTAL_MAKE_NUM, pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_TOTAL_MAKE_NUM) + i - 1);
			return 0;
		end
		pItem.Bind(1);
		--local szDate = os.date("%Y/%m/%d/%H/%M/%S", GetTime() + self.ITEM_VALIDITY_DUMPLING);
       	--pPlayer.SetItemTimeout(pItem, szDate);
	end]]--
	local nAddCount = pPlayer.AddStackItem(self.ITEM_DUMPLING_MEAT_ID[1], self.ITEM_DUMPLING_MEAT_ID[2], self.ITEM_DUMPLING_MEAT_ID[3], self.ITEM_DUMPLING_MEAT_ID[4], {bForceBind = 1}, nCount);
	if nAddCount < nCount then
		Dbg:WriteLog("DuanWu2011", "dumpling failed", nAddCount, nCount);
	end
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_TODAY_MAKE_NUM, pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_TODAY_MAKE_NUM) + nAddCount);
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_TOTAL_MAKE_NUM, pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_TOTAL_MAKE_NUM) + nAddCount);
	StatLog:WriteStatLog("stat_info", "duanwujie_2011", "item_get", nPlayerId, nAddCount);
	return 1;
end

-- 检查是否是喂食时间
function tbDuanWu2011:CheckInFishTime()
	local nTime = tonumber(GetLocalDate("%H%M%S"));
	if nTime < self.FISH_START_TIME or nTime > self.FISH_CLOSE_TIME then
		return 0;
	end
	return 1;
end

-- 使用粽子喂鱼检查,如果可以喂食则返回的第二个参数为鱼群id
function tbDuanWu2011:CheckCanFish(pPlayer)
	if self:CheckOpen() ~= 1 then
		return 0, "现在不在活动期间，无法喂鱼。请在6月2日-8日9：00-23：55分期间，找到鱼儿并且投粽喂鱼吧！";
	end 
	local szErrMsg = "";
	if pPlayer.CountFreeBagCell() < 2 then
		return 0, "需要<color=yellow>2格<color>背包空间，整理下再来！";
	end
	if pPlayer.GetItemCountInBags(unpack(self.ITEM_DUMPLING_MEAT_ID)) < 1 then
		return 0, "你身上没有粽子,请参加逍遥谷、宋金战场、白虎堂、军营活动获得材料吧。";
	end
	local nCanFishNum = self:CheckTodayFishRemainNum(pPlayer);
	if nCanFishNum < 1 then
		return 0, "每人每天最多只能喂食鱼儿30次，你还是等明天再喂吧。";
	end
	if GetMapType(pPlayer.nMapId) ~= "village" and  GetMapType(pPlayer.nMapId) ~= "city" then
		return 0, "只能在各新手村和城市有鱼的河道投粽，切勿浪费哦。";
	end
	if self:CheckInFishTime() ~= 1 then
		return 0, "现在不在喂鱼时间，在6月2日-8日9：00-23：55分期间，找到鱼儿并且投粽喂鱼吧！";
	end
	local nRet, nShoalId = self:CheckShoalNearly(pPlayer);
	if nRet == 0 then
		return 0, "周围没有鱼群可供喂食。去新手村和城市的河道中找一找贪食的鱼儿吧!";
	end
	if nRet == -1 then
		return 0, "这个鱼群已经吃的很饱了，换一群鱼儿投粽吧。";
	end
	return 1, nShoalId;
end

-- 检查周围是否有鱼群
function tbDuanWu2011:CheckShoalNearly(pPlayer)
	local nRet = 0;
	local tbNpcList = KNpc.GetAroundNpcList(pPlayer, self.MAX_FISH_RANGE);
	for _, pNpc in ipairs(tbNpcList) do
		if pNpc.nTemplateId == self.NPC_SHAOL_ID then
			local nRet1 = self:CheckShoalCanFeeding(pNpc.dwId);
			if nRet1 == -1 then
				nRet = nRet1;
			end
			if nRet1 == 1 then
				return 1, pNpc.dwId;
			end
		end
	end
	return nRet;
end

-- 检查该鱼是否还可喂食
function tbDuanWu2011:CheckShoalCanFeeding(dwNpcId)
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then
		return 0;
	end
	local tbNpcShoal = pNpc.GetTempTable("Npc").tbNpcShoal;
	if not tbNpcShoal then
		return 0;
	end
	tbNpcShoal.nFeedTimes = tbNpcShoal.nFeedTimes or 0;
	if tbNpcShoal.nFeedTimes < self.MAX_FEED_TIMES then
		return 1;
	end
	return -1;
end


-- 今日使用粽子喂鱼剩余次数
function tbDuanWu2011:CheckTodayFishRemainNum(pPlayer)
	local nDay = Lib:GetLocalDay(GetTime());
	local nTaskDate = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_LAST_FISH_DAY);
	if nTaskDate < nDay then
		local nYestoday = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_TODAY_FISH_NUM);
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_LAST_FISH_DAY, nDay);
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_TODAY_FISH_NUM, 0);
		if nTaskDate == nDay - 1 then
			pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_YESTODAY_FISH_NUM, nYestoday);
		else
			pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_YESTODAY_FISH_NUM, 0); -- 超过一天的直接置0
		end
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_GET_AWARD, 0);
	end
	local nTodayNum = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_TODAY_FISH_NUM);
	local nCanFishNum = self.DAY_FISH_NUM_LIMIT - nTodayNum;
	local nRemainNum = self.TOTAL_FISH_NUM_LIMIT - pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_TOTAL_FISH_NUM);
	if nCanFishNum > nRemainNum then
		nCanFishNum = nRemainNum;
	end
	return nCanFishNum;
end

-- 给鱼群喂食
function tbDuanWu2011:FeedingFish(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	if self:CheckCanUse(pPlayer) ~= 1 then
		return 0;
	end
	local nRet, var = tbDuanWu2011:CheckCanFish(pPlayer);-- 成功返回的是鱼群id，失败范围的是提示
	if nRet ~= 1 then
		pPlayer.Msg(var);
		return 0;
	end
	local pNpcShoal = KNpc.GetById(var);
	if not pNpcShoal then
		return 0;
	end
	local tbNpcShoal = pNpcShoal.GetTempTable("Npc").tbNpcShoal;
	tbNpcShoal.nFeedTimes = tbNpcShoal.nFeedTimes + 1;
	local nPosIndex = math.mod(tbNpcShoal.nFeedTimes, #self.TABLE_DUMPLING_POS) + 1;
	local nSholeMapId, nSholePosX, nSholePosY = pNpcShoal.GetWorldPos();
	-- 在鱼群周围加一个粽子
	local pNpcDumpling = KNpc.Add2(self.NPC_DUMPLING_ID, 100, -1, nSholeMapId, nSholePosX+self.TABLE_DUMPLING_POS[nPosIndex][1], nSholePosY+self.TABLE_DUMPLING_POS[nPosIndex][2]);
	if not pNpcDumpling then
		return 0;
	end
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_TODAY_FISH_NUM, pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_TODAY_FISH_NUM) + 1);
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_TOTAL_FISH_NUM, pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_TOTAL_FISH_NUM) + 1);
	if pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_TOTAL_FISH_NUM) == self.TOTAL_FISH_NUM_LIMIT then
		pPlayer.AddTitle(6, 75, 1, 1);
	end
	pPlayer.ConsumeItemInBags(1, self.ITEM_DUMPLING_MEAT_ID[1], self.ITEM_DUMPLING_MEAT_ID[2], self.ITEM_DUMPLING_MEAT_ID[3], self.ITEM_DUMPLING_MEAT_ID[4], -1);
	StatLog:WriteStatLog("stat_info", "duanwujie_2011", "get_fish", nPlayerId, 1);
	pPlayer.Msg(string.format("粽子已经投下了，你今日喂食次数<color=yellow>%s/%s次<color>。",self.DAY_FISH_NUM_LIMIT - self:CheckTodayFishRemainNum(pPlayer), self.DAY_FISH_NUM_LIMIT));
	Dialog:SendBlackBoardMsg(pPlayer, "粽子已经投下了，等一下就能收获了！");
	pNpcDumpling.GetTempTable("Npc").nTimerId = Timer:Register(self.DELAY_FEED_TIME, self.FishEatedDumpling, self, nPlayerId, pNpcShoal.dwId, pNpcDumpling.dwId, pPlayer.nMapId, tbNpcShoal.nFeedTimes);
	if self:RandMedals() == 1 then
		local pItem = pPlayer.AddItem(unpack(self.ITEM_MEDALS_ID));
		if pItem then
			pPlayer.Msg("恭喜你获得了端午忠魂勋章。");
			pItem.Bind(1);
			local szDate = os.date("%Y/%m/%d/00/00/00", GetTime() + 3600 * 24); -- 当天有效
       		pPlayer.SetItemTimeout(pItem, szDate);
		end
	end
end

-- 鱼群吃完了粽子
function tbDuanWu2011:FishEatedDumpling(nPlayerId, dwShoalId, dwDumplingId, nMapId, nFeedTimes)
	local pNpcDumpling = KNpc.GetById(dwDumplingId);
	if not pNpcDumpling then
		print("tbDuanWu201", "tbDuanWu2011:FishEatedDumpling not find dumpling", dwDumplingId);
		return 0;
	end
	
	local pNpcShoal = KNpc.GetById(dwShoalId);
	if not pNpcShoal then
		pNpcDumpling.Delete();
		print("tbDuanWu201", "tbDuanWu2011:FishEatedDumpling not find owner shoal", dwShoalId);
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		if pPlayer.CountFreeBagCell() >= 1 and nMapId == pPlayer.nMapId then
			local nHonorRank = PlayerHonor:GetPlayerHonorRankByName(pPlayer.szName, PlayerHonor.HONOR_CLASS_MONEY, 0);
			local nType = 1;
			--if not nHonorRank or nHonorRank <= 0 or nHonorRank > self.MIN_WEALTHORDER then
			--	nType = 2;
			--end
			local nFishId = self:RandFish(nType);
			local pItem = pPlayer.AddItem(unpack(self.ITEM_TBALBE_FISH_ID[nFishId]));
			if not pItem then
				Dbg:WriteLog("tbDuanWu201", "add fish failed");
			else
				pItem.Bind(1);
				local szDate = os.date("%Y/%m/%d/00/00/00", GetTime() + 3600 * 24); -- 当天有效
	       		pPlayer.SetItemTimeout(pItem, szDate);
	       		Dialog:SendBlackBoardMsg(pPlayer, string.format("恭喜你获得一条%s", pItem.szName));
			end
		else
			if nMapId ~= pPlayer.nMapId then
				Dialog:SendBlackBoardMsg(pPlayer, "获取失败，你已经离开了投粽地图。");
			else
				Dialog:SendBlackBoardMsg(pPlayer, "获取失败，背包空间不足！");
			end
		end
	end
	
	pNpcDumpling.Delete();
	local tbNpcShoal = pNpcShoal.GetTempTable("Npc").tbNpcShoal;
	if not tbNpcShoal then
		return 0;
	end
	local nExistShoalIndex = tbNpcShoal.nExistIndex;
	if nFeedTimes and nFeedTimes >= self.MAX_FEED_TIMES then
		pNpcShoal.Delete();
		self:UpdateShoal(nExistShoalIndex);
	end
	return 0;
end

-- 启动的时候或者活动开始的时候刷一遍鱼群
function tbDuanWu2011:RefreshNpc()
	if self.tbExistShoalInfo and #self.tbExistShoalInfo > 0 then -- 已经刷过了
		return 0;
	end
	local tbTempFile = Lib:LoadTabFile(self.SHOAL_FILEPATH);
	if not tbTempFile or #tbTempFile == 0 then
		self.tbShoalFile = {};
		Dbg:WriteLog("duanwu2011", "load shoal file failure");
		return 0;
	end
	self.tbShoalPos = {}; -- 所有可用的鱼群表
	for i = 1, #tbTempFile do
		local tbTemp = {};
		tbTemp[1] = tonumber(tbTempFile[i]["MAPID"]);
		tbTemp[2] = tonumber(tbTempFile[i]["POSX"]) / 32;
		tbTemp[3] = tonumber(tbTempFile[i]["POSY"]) / 32;
		if SubWorldID2Idx(tbTemp[1]) >= 0 then
			table.insert(self.tbShoalPos, tbTemp);
		end
	end
	Lib:SmashTable(self.tbShoalPos);-- 打乱表,随机刷点
	self.tbExistShoalInfo = {};	-- 已经add的鱼群表
	for i = 1, self.FISH_REFRESH_COUNT do
		if self.tbShoalPos[i] then
			local pNpc = KNpc.Add2(self.NPC_SHAOL_ID, 100, -1, self.tbShoalPos[i][1], self.tbShoalPos[i][2], self.tbShoalPos[i][3]);
			if pNpc then
				local tbTemp = {};
				tbTemp[1] = i;	-- 鱼群表索引
				tbTemp[2] = pNpc.dwId;	-- 鱼群索引
				table.insert(self.tbExistShoalInfo, tbTemp);
				pNpc.GetTempTable("Npc").tbNpcShoal = {};
				pNpc.GetTempTable("Npc").tbNpcShoal.nExistIndex = #self.tbExistShoalInfo; -- 存在索引，删除鱼群以及刷新鱼群的时候使用
			else
				Dbg:WriteLog("duanwu2011", "add shoal failure");
			end
		end
	end
end

-- 到时间了清除鱼群
function tbDuanWu2011:CleanAllShoal()
	local tbMapId = {1,2,3,4,5,6,7,8,23,24,26,27,29};
	for _, nMapId in ipairs(tbMapId) do
		if SubWorldID2Idx(nMapId) >= 0 then
			ClearMapNpcWithTemplateId(nMapId, self.NPC_SHAOL_ID);
		end
	end
	self.tbExistShoalInfo = {};
	return 1;
end


-- 更新一个鱼群,随机更新的鱼群的位置
function tbDuanWu2011:UpdateShoal(nUpdateIndex)
	if not self.tbExistShoalInfo or not self.tbShoalPos or not self.tbExistShoalInfo[nUpdateIndex] then
		return 0;
	end
	local tbTemp = {};
	for nIndex, tbInfo in pairs(self.tbExistShoalInfo) do
		tbTemp[tbInfo[1]] = nIndex;
	end
	local nRand = MathRandom(#self.tbShoalPos);
	local nUsefulIndex = 0;
	for i = 0, #self.tbShoalPos - 1 do
		local nIndex = math.mod(nRand+i, #self.tbShoalPos) + 1;
		if not tbTemp[nIndex] then
			nUsefulIndex = nIndex;
		end
	end
	self.tbExistShoalInfo[nUpdateIndex] = nil;	-- 置空需要更新的鱼群
	if nUsefulIndex > 0 then	-- 如果有鱼群可以交换
		self.tbExistShoalInfo[nUpdateIndex] = {};
		self.tbExistShoalInfo[nUpdateIndex][1] = nUsefulIndex;
		self.tbExistShoalInfo[nUpdateIndex][2] = 0;	-- 鱼群还未加上
		Timer:Register(self.DELAY_ADDSHOAL_TIME, self.AddShoal, self, nUpdateIndex);
	end
end

-- 在指定的位置添加一个鱼群
function tbDuanWu2011:AddShoal(nUpdateIndex)
	if not self.tbExistShoalInfo or not self.tbExistShoalInfo[nUpdateIndex] then
		return 0;
	end
	local nShoalPosIndex = self.tbExistShoalInfo[nUpdateIndex][1];
	if not self.tbShoalPos or not self.tbShoalPos[nShoalPosIndex] then
		return 0;
	end
	if self:CheckInFishTime() ~= 1 then	-- 过了活动时间了，不刷鱼了
		return 0;
	end
	local pNpc = KNpc.Add2(self.NPC_SHAOL_ID, 100, -1, self.tbShoalPos[nShoalPosIndex][1], self.tbShoalPos[nShoalPosIndex][2], self.tbShoalPos[nShoalPosIndex][3]);
	if pNpc then
		self.tbExistShoalInfo[nUpdateIndex][2] = pNpc.dwId;
		pNpc.GetTempTable("Npc").tbNpcShoal = {};
		pNpc.GetTempTable("Npc").tbNpcShoal.nExistIndex = nUpdateIndex; -- 存在索引，删除鱼群以及刷新鱼群的时候使用
	end
	return 0;
end

function tbDuanWu2011:StartEvent_GS()
	if self:CheckOpen() ~= 1 then
		return 0;
	end
	if self:CheckInFishTime() ~= 1 then	-- 不是刷鱼时间不管
		return 0;
	end
	self:RefreshNpc();
end

-- gc返回领奖结果
function tbDuanWu2011:GetMedalsAward_GS2(nResult, nKinId, nMemberId, nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if nResult ~= 1 then
		if pPlayer then
			pPlayer.AddWaitGetItemNum(-1);
			pPlayer.Msg("领取失败！");
			Dialog:SendBlackBoardMsg(pPlayer, "领奖失败！");
		end
	else
		self.tbAwardRecord[nKinId] = 1;
		if pPlayer then
			local pItem = pPlayer.AddItem(unpack(self.ITEM_LINGPAI_ID));
			if pItem then
				pItem.Bind(1);
				local szDate = os.date("%Y/%m/%d/23/59/00", GetTime()); -- 当天有效
       			pPlayer.SetItemTimeout(pItem, szDate);
			end
			pPlayer.AddWaitGetItemNum(-1);
			pPlayer.Msg("成功获得一个端午忠魂令。");
			Dialog:SendBlackBoardMsg(pPlayer, "成功获得一个端午忠魂令。");
			Dbg:WriteLog("duanwu2011", "medalsaward", nKinId, nMemberId, nPlayerId);
		end
		
	end
end

-- 注册启动事件
ServerEvent:RegisterServerStartFunc(tbDuanWu2011.StartEvent_GS, tbDuanWu2011);

-- 添加端午忠魂
function tbDuanWu2011:AddDuanWuZhongHun(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local nKinId, nMemberId = pPlayer.GetKinMember();
	if Kin:CheckSelfRight(nKinId, nMemberId, 2) ~= 1 then
		return 0;
	end
	local tbNpcList = KNpc.GetAroundNpcList(pPlayer, 10);
	for _, pNpc in ipairs(tbNpcList) do
		if pNpc.nTemplateId == self.NPC_QUYUAN_ID then
			return 0;
		end
	end
	local nMapId, nPosX, nPosY = pPlayer.GetWorldPos();
	if GetMapType(nMapId) ~= "fight" then
		return 0;
	end
	local tbFind = pPlayer.FindItemInBags(unpack(self.ITEM_LINGPAI_ID));
	if not tbFind[1] then
		return 0;
	end
	pPlayer.ConsumeItemInBags(1, self.ITEM_LINGPAI_ID[1], self.ITEM_LINGPAI_ID[2], self.ITEM_LINGPAI_ID[3], self.ITEM_LINGPAI_ID[4], -1);
	local pNpcBoss = KNpc.Add2(self.NPC_BOSS_ID, 100, -1, nMapId, nPosX, nPosY);
	if not pNpcBoss then
		Dbg:WriteLog("duanwu2011", "add_boss", nKinId, nMemberId);
		return 0;
	end
	local szTime = os.date("%Y%m%d", GetTime() + 24 * 3600);
	local nOverTime = Lib:GetDate2Time(szTime);
	pNpcBoss.SetLiveTime((nOverTime - GetTime()) * Env.GAME_FPS);
	pNpcBoss.GetTempTable("Npc").tbNpcBoss = {};
	local tbNpcBoss = pNpcBoss.GetTempTable("Npc").tbNpcBoss;
	tbNpcBoss.nPlayerId = nPlayerId;
	tbNpcBoss.nKinId = nKinId;
	tbNpcBoss.nOverTime = nOverTime;
	tbNpcBoss.nDate = tonumber(GetLocalDate("%Y%m%d"));
	tbNpcBoss.nMapId = nMapId;
	tbNpcBoss.nPosX = nPosX;
	tbNpcBoss.nPosY = nPosY;
end
