-- 文件名  : treasuremap2_gs.lua
-- 创建者  : huangxiaoming
-- 创建时间: 2012-08-30 11:10:41
-- 描述    : 

Require("\\script\\task\\treasuremap2\\treasuremap2_def.lua")

-- 增加每周通过令牌次数
function TreasureMap2:AddWeekCommonCount(pPlayer)
	local nTaskWeek = pPlayer.GetTask(self.TASK_GROUP, self.TASK_ID_COUNTWEEK);
	local nWeek = Lib:GetLocalWeek();
	if nTaskWeek < nWeek then
		local nCount = pPlayer.GetTask(self.TASK_GROUP, self.TASK_ID_COMMONTASK);
		if nCount + self.NUMBER_WEEK_COMMON > self.NUMBER_MAX_TREASURE_TIMES then
			return 0, "Số lượt khiêu chiến tích lũy là 20, hãy tham gia khiêu chiến để nhận thêm lượt mỗi ngày.";
		end
		pPlayer.SetTask(self.TASK_GROUP, self.TASK_ID_COMMONTASK, nCount + self.NUMBER_WEEK_COMMON);
		pPlayer.SetTask(self.TASK_GROUP, self.TASK_ID_COUNTWEEK, nWeek);
		StatLog:WriteStatLog("stat_info", "TreasureMap", "get_times", pPlayer.nId, 0, self.NUMBER_WEEK_COMMON);
		return self.NUMBER_WEEK_COMMON, string.format("Chúc mừng bạn nhận được %s lượt khiêu chiến Tàng Bảo Đồ", self.NUMBER_WEEK_COMMON);
	end
	return 0, "Bạn đã nhận 2 lượt khiêu chiến Tàng Bảo Đồ thông dụng trong tuần này.";
end

-- 增加每日次数
function TreasureMap2:AddDayRandCount(pPlayer)
	local nTaskDay = pPlayer.GetTask(self.TASK_GROUP, self.TASK_ID_COUNTDAY);
	local nDay = KGblTask.SCGetDbTaskInt(DBTASK_TREASUREMAP_RANDDAY);
	local nRandSeed = KGblTask.SCGetDbTaskInt(DBTASK_TREASUREMAP_RANDSEED);
	local nPlayerLevel = pPlayer.nLevel;
	local nLevelIndex = 0;
	for nLevelLimit, _ in pairs(self.LEVEL_TASKIID) do
		if nPlayerLevel >= nLevelLimit and nLevelLimit > nLevelIndex then
			nLevelIndex = nLevelLimit;
		end
	end
	if nLevelIndex <= 0 then
		return 0, "Không thể tìm thấy phó bản ở cấp độ này.";
	end
	local nAddTimes = 1;
	if nPlayerLevel < 50 then
		nAddTimes = 2;
	end
	if nTaskDay < nDay then
		local nRand = math.mod(nRandSeed, #self.LEVEL_TASKIID[nLevelIndex]) + 1;
		local nTaskIndex = self.LEVEL_TASKIID[nLevelIndex][nRand];
		assert(nTaskIndex > 0);
		local nTaskGroup = self.TEMPLATE_LIST[nTaskIndex].tbTaskGroupId[1];
		local nTaskId = self.TEMPLATE_LIST[nTaskIndex].tbTaskGroupId[2];
		assert(nTaskGroup > 0 and nTaskId > 0);
		local nCurCount = pPlayer.GetTask(nTaskGroup, nTaskId);
		if nCurCount + nAddTimes > self.NUMBER_MAX_TREASURE_TIMES then
			return 0, "Số lượt khiêu chiến tích lũy là 20, hãy tham gia khiêu chiến để nhận thêm lượt mỗi ngày.";
		end
		pPlayer.SetTask(nTaskGroup, nTaskId, nCurCount + nAddTimes);
		pPlayer.SetTask(self.TASK_GROUP, self.TASK_ID_COUNTDAY, nDay);
		StatLog:WriteStatLog("stat_info", "TreasureMap", "get_times", pPlayer.nId, nTaskIndex, nAddTimes);
		return nAddTimes, string.format("Chúc mừng bạn nhận được %s lượt khiêu chiến %s", nAddTimes, self.TEMPLATE_LIST[nTaskIndex].szName);
	end
	return 0, "Đã nhận lượt khiêu chiến Tàng Bảo Đồ hôm nay.";
end

-- 获取今日藏宝图任务变量
function TreasureMap2:GetTodayTaskID(nPlayerLevel)
	local nLevelIndex = 0;
	for nLevelLimit, _ in pairs(self.LEVEL_TASKIID) do
		if nPlayerLevel >= nLevelLimit and nLevelLimit > nLevelIndex then
			nLevelIndex = nLevelLimit;
		end
	end
	if not #self.LEVEL_TASKIID[nLevelIndex] then
		return nil;
	end
	local nRandSeed = KGblTask.SCGetDbTaskInt(DBTASK_TREASUREMAP_RANDSEED);
	assert(nRandSeed > 0);
	local nRand = math.mod(nRandSeed, #self.LEVEL_TASKIID[nLevelIndex]) + 1;
	local nTaskIndex = self.LEVEL_TASKIID[nLevelIndex][nRand];
	local nTaskGroup = self.TEMPLATE_LIST[nTaskIndex].tbTaskGroupId[1];
	local nTaskId = self.TEMPLATE_LIST[nTaskIndex].tbTaskGroupId[2];
	return nTaskGroup, nTaskId;
end
