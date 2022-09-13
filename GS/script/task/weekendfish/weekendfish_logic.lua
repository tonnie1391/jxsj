-- 文件名　：weekendfish_logic.lua
-- 创建者　：huangxiaoming
-- 创建时间：2011-08-05 14:12:10
-- 描  述  ：gc和gs通用文件

Require("\\script\\task\\weekendfish\\weekendfish_def.lua")
-- 是否开启
function WeekendFish:CheckOpen() -- 开放89才开放
	if TimeFrame:GetState("WeekendFish") ~= 1 then
		return 0;
	end
	return self._OPEN;
end


-- 加载排行榜
function WeekendFish:LoadLuckFishRank()
	local tbData = GetGblIntBuf(GBLINTBUF_WEEKEND_FISH, 0) or {};
	self.nDataVer = tbData.nDataVer or -1;	-- 数据版本
	self.nOpenLuckRankAward = tbData.nOpenLuckRankAward or 0;	-- 是否开启领奖
	self.tbLuckFishRank = tbData.tbLuckFishRank or {};
	self.tbLuckFishRank[1] = self.tbLuckFishRank[1] or {};-- 只记前10名{name, weight,nTime, nFlag}
	self.tbLuckFishRank[2] = self.tbLuckFishRank[2] or {};
	self.tbLuckFishRank[3] = self.tbLuckFishRank[3] or {};
	
	local tbData = GetGblIntBuf(GBLINTBUF_WEEKEND_FISH_EX, 0) or {};
	self.tbLuckFishRank_Ex = tbData.tbLuckFishRank or {};
	self.tbLuckFishRank_Ex[1] = self.tbLuckFishRank_Ex[1] or {};-- 只记前10名{name, weight,nTime, nFlag}
	self.tbLuckFishRank_Ex[2] = self.tbLuckFishRank_Ex[2] or {};
	self.tbLuckFishRank_Ex[3] = self.tbLuckFishRank_Ex[3] or {};
end

-- 玩家的幸运鱼领奖情况,-1领过奖，0没有领奖资格，1第一档奖励，2第二档奖励
function WeekendFish:CheckPlayerLuckAward(szPlayerName, nType)
	for nIndex = 1 , #self.tbLuckFishRank[nType] do
		if self.tbLuckFishRank[nType][nIndex][1] == szPlayerName and nIndex <= self.MAX_LUCKFISH_AWARD_RANK then
			if self.tbLuckFishRank[nType][nIndex][4] == 1 then
				return -1;-- 领过奖了
			else
				return nIndex;
			end
		end
	end

	if (self.tbLuckFishRank_Ex and self.tbLuckFishRank_Ex[nType]) then
		for nIndex = 1 , #self.tbLuckFishRank_Ex[nType] do
			if (self.tbLuckFishRank_Ex[nType][nIndex]) then
				if self.tbLuckFishRank_Ex[nType][nIndex][1] == szPlayerName and nIndex <= self.MAX_LUCKFISH_AWARD_RANK then
					if self.tbLuckFishRank_Ex[nType][nIndex][4] == 1 then
						return -1;-- 领过奖了
					else
						return nIndex;
					end
				end
			end
		end
	end
	return 0;
end

-- 根据幸运鱼排行给奖励
function WeekendFish:GetAwardLevelByLuckFishRank(nRank)
	if nRank == 1 then
		return 1;
	elseif nRank <= self.MAX_LUCKFISH_AWARD_RANK then
		return 2;
	end
	return 0;
end

-- 更新排行榜，只记前10名
function WeekendFish:UpdateLuckFishRank(nType, szPlayerName, nWeight)
	if nWeight <= 0 then
		return 0;
	end
	local tbInfo = {szPlayerName, nWeight, GetTime(), 0};
	local nSaveFlag = 0;
	local nUpdateFlag = 0;
	for nIndex = 1, #self.tbLuckFishRank[nType] do
		if self.tbLuckFishRank[nType][nIndex][1] == szPlayerName then
			self.tbLuckFishRank[nType][nIndex][2] = nWeight;
			self.tbLuckFishRank[nType][nIndex][3] = GetTime();
			nUpdateFlag = 1;
			break;
		end
	end
	if nUpdateFlag == 0 then
		if #self.tbLuckFishRank[nType] < self.MAX_LUCKFISH_RANK then
			table.insert(self.tbLuckFishRank[nType], tbInfo);
			table.sort(self.tbLuckFishRank[nType], self._RankCmp);
			nSaveFlag = 1;
		else
			if self.tbLuckFishRank[nType][self.MAX_LUCKFISH_RANK][2] < nWeight then
				self.tbLuckFishRank[nType][self.MAX_LUCKFISH_RANK][1] = szPlayerName;
				self.tbLuckFishRank[nType][self.MAX_LUCKFISH_RANK][2] = nWeight;
				self.tbLuckFishRank[nType][self.MAX_LUCKFISH_RANK][3] = GetTime();
				self.tbLuckFishRank[nType][self.MAX_LUCKFISH_RANK][4] = 0;
				table.sort(self.tbLuckFishRank[nType], self._RankCmp);
				nSaveFlag = 1;
			end
		end
	else
		table.sort(self.tbLuckFishRank[nType], self._RankCmp);
		nSaveFlag = 1;
	end
	if MODULE_GC_SERVER then
		if nSaveFlag == 1 then -- 前10名有变动存盘一下
			self:SaveLuckFishRank_GC();
		end
	end
	
end


WeekendFish._RankCmp = function (tbA, tbB)
	if tbA[2] == tbB[2] then
		return tbA[3] < tbB[3];
	end
	return tbA[2] > tbB[2];
end

-- 是否是钓鱼时间
function WeekendFish:CheckFishTime()
	local nWeek = tonumber(GetLocalDate("%w"));
	local nFlag = 0;
	for _, nTemp in pairs(WeekendFish.TB_ACCEPTTASKWEEKDAY) do
		if nTemp == nWeek then
			nFlag = 1;
			break;
		end
	end
	if nFlag ~= 1 then
		return 0, "今天可不是钓鱼的日子,请到周末再来吧！";
	end
	local nNowTime = tonumber(GetLocalDate("%H%M%S"));
	for _, tbTime in pairs(self.REFRESHFISHTIME_BEG) do
		if nNowTime >= tbTime[1] and nNowTime <= tbTime[2] then
			return 1;
		end
	end
	return 0, "现在不是钓鱼时间";
end

-- 检查是否是周末接任务时间
function WeekendFish:CheckAcceptTaskTime()
	local nWeek = tonumber(GetLocalDate("%w"));
	local nFlag = 0;
	for _, nTemp in pairs(WeekendFish.TB_ACCEPTTASKWEEKDAY) do
		if nTemp == nWeek then
			nFlag = 1;
			break;
		end
	end
	if nFlag ~= 1 then
		return 0, "今天可不是钓鱼的日子，请到周末再来吧。";
	end
	local nNowTime = tonumber(GetLocalDate("%H%M%S"));
	if nNowTime < WeekendFish.ACCEPTTASKWEEKDAY_BEG then
		return 0, "你来太早了，我还没想好今天想要什么鱼。";
	end
	if nNowTime > WeekendFish.ACCEPTTASKWEEKDAY_END then
		return 0, "今天的任务都已经分出去了，你来晚了。";
	end 
	return 1;
end

-- 检查是否是可交任务的时间
function WeekendFish:CheckAwardTaskTime()
	local nWeek = tonumber(GetLocalDate("%w"));
	local nFlag = 0;
	for _, nTemp in pairs(WeekendFish.TB_ACCEPTTASKWEEKDAY) do
		if nTemp == nWeek then
			nFlag = 1;
		end
	end
	if nFlag ~= 1 then
		return 0, "今天可不是收鱼的日子，请到周末再来吧。";
	end
	local nNowTime = tonumber(GetLocalDate("%H%M%S"));
	if nNowTime < WeekendFish.AWARDTASKWEEKDAY_BEG then
		return 0, "晚点再来交吧，现在没空。";
	end
	if nNowTime > WeekendFish.AWARDTASKWEEKDAY_END then
		return 0, "不收了不收了，每天23：30分收鱼结束，下次赶早。"
	end
	return 1;
end

-- 检查是否是刷鱼时间
function WeekendFish:CheckRefreshFishTime()
	return self:CheckFishTime();	-- 与是否能钓鱼是一致的
end

-- 获取nbeg到nend的随机表
function WeekendFish:GetSmashTable(nBeg, nEnd)
	local tbRand = {};
	for i = nBeg, nEnd do 
		tbRand[i] = i;
	end
	Lib:SmashTable(tbRand);
	return tbRand;
end

-- 获取今日的钓鱼任务
function WeekendFish:RandPlayerFishList(pPlayer)
	local tbTaskList = {};
	tbTaskList[1] = KGblTask.SCGetDbTaskInt(DBTASK_WEEKENDFISH_TASK_ID1);
	tbTaskList[2] = KGblTask.SCGetDbTaskInt(DBTASK_WEEKENDFISH_TASK_ID2);
	tbTaskList[3] = KGblTask.SCGetDbTaskInt(DBTASK_WEEKENDFISH_TASK_ID3);
	if pPlayer then	-- 玩家组队接任务在接之前已经设置好了
		local nTaskIdGroup = pPlayer.GetTask(self.TASK_GROUP, self.TASK_TEAM_IDGROUP);
		if nTaskIdGroup > 0 then
			tbTaskList[4] = math.mod(nTaskIdGroup, 100);
			tbTaskList[5] = math.mod(math.floor(nTaskIdGroup/100), 100);
			--tbTaskList[6] = math.mod(math.floor(nTaskIdGroup/10000), 100);
			return tbTaskList;
		end
	end
	tbTaskList = self:RandFishListHaveParam(tbTaskList);
	return tbTaskList;
end

-- 随机组队模式下的2个任务
function WeekendFish:RandTeamFishShareTaskList()
	local tbTaskList = {};
	tbTaskList[1] = KGblTask.SCGetDbTaskInt(DBTASK_WEEKENDFISH_TASK_ID1);
	tbTaskList[2] = KGblTask.SCGetDbTaskInt(DBTASK_WEEKENDFISH_TASK_ID2);
	tbTaskList[3] = KGblTask.SCGetDbTaskInt(DBTASK_WEEKENDFISH_TASK_ID3);
	tbTaskList = self:RandFishListHaveParam(tbTaskList);
	local nTaskValue = tbTaskList[4] + tbTaskList[5] * 100 ;--+ tbTaskList[6] * 10000;
	return nTaskValue;
end


-- 每个区域随一个，且包含参数的值
function WeekendFish:RandFishListHaveParam(tbFixValue)
	local tbValue2Area = {};
	for nArea, tbTemp in pairs(self.AREA_INDEX) do
		for _, nValue in pairs(tbTemp) do
			tbValue2Area[nValue] = nArea;
		end
	end
	local tbTaskList = {};
	local tbTaskListExtent = {};
	local nIndex = 1;
	-- 每个区域各随一个
	for i = 1, #self.AREA_INDEX do
		local nRand = MathRandom(1, #self.AREA_INDEX[i]);
		tbTaskList[i] = self.AREA_INDEX[i][nRand];
		local nInArea = 0;
		for _, nValue in pairs(tbFixValue) do
			if tbValue2Area[tbTaskList[i]] == tbValue2Area[nValue] then -- 替换同区域的固定点
				tbTaskList[i] = nValue;
				nInArea = 1;
				break;
			end
		end
		if nInArea == 0 then
			tbTaskListExtent[nIndex] = tbTaskList[i]; -- 记录两个随机区域的点
			nIndex = nIndex + 1;
		end
	end
	for i = 1, #tbFixValue do
		tbTaskList[i] = tbFixValue[i];
	end
	for i = 1, #tbTaskListExtent do
		tbTaskList[#tbFixValue + i] = tbTaskListExtent[i];
	end
	--[[local tbRand = self:GetSmashTable(1, self.MAX_FISH_KIND);
	local nIndex = #self.AREA_INDEX + 1;
	for i = 1, self.MAX_FISH_KIND do 
		local nFlag = 0;
		for j = 1, #self.AREA_INDEX do
			if tbTaskList[j] == tbRand[i] then
				nFlag = 1;
				break;
			end
		end
		if nFlag == 0 then
			tbTaskList[nIndex] = tbRand[i];
			nIndex = nIndex  + 1;
		end
		if nIndex > self.FISH_TASK_NUM then
			break;
		end
	end]]--
	return tbTaskList;
end

-- 根据鱼编号获取区域id
function WeekendFish:GetAreaIdByFishId(nFishId)
	if not self.FishId2AreaId then
		self.FishId2AreaId = {};
		for nAreaId, tbTemp in pairs(self.AREA_INDEX) do
			for i = 1, #tbTemp do
				self.FishId2AreaId[tbTemp[i]] = nAreaId;
			end
		end
	end
	return self.FishId2AreaId[nFishId];
end


-- 随机是否钓上了鱼,方便重载
function WeekendFish:RandFishSuccess()
	local nRand = MathRandom(100);
	if nRand <= self.RAND_HOOKED then
		return 1;
	end
	return 0;
end

-- 随机钓到的是否是鱼
function WeekendFish:RandIsFish()
	local nRand = MathRandom(100);
	if nRand <= self.RAND_IS_FISH then
		return 1;
	end
	return 0;
end

-- 随机鱼的斤两
function WeekendFish:RandFishWeight(nType)
	nType = nType or 1;
	if nType > 4 then
		nType = 4;
	end
	local nTotalRand = 0;
	for i = 1, #self.RAND_FISHWEIGHT[nType] do
		nTotalRand = nTotalRand + self.RAND_FISHWEIGHT[nType][i][1];
	end
	local nRand = MathRandom(nTotalRand);
	local nIndex = 1;
	local nSum = 0;
	for i = 1, #self.RAND_FISHWEIGHT[nType] do
		nSum = nSum + self.RAND_FISHWEIGHT[nType][i][1];
		if nSum >= nRand then
			nIndex = i;
			break;
		end
	end
	local nWeight = MathRandom(self.RAND_FISHWEIGHT[nType][nIndex][2], self.RAND_FISHWEIGHT[nType][nIndex][3]);
	return nWeight;
end

-- 随机杂物
function WeekendFish:RandSundries()
	local nRand = MathRandom(#self.ITEM_SUNDRIES_ID);
	return nRand;
end

-- 根据重量获取鱼的等级
function WeekendFish:GetLevelByWeight(nWeight)
	for i = #self.FISH_WEIGHT_LEVEL, 1, -1 do
		if nWeight >= self.FISH_WEIGHT_LEVEL[i] then
			return i;
		end
	end
	return 0;
end

-- 检查是否是需要处理合服数据的时间
function WeekendFish:CheckMergeServerTime()
	return self:CheckAwardTaskTime();
end
