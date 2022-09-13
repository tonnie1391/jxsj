-- 文件名　：stats_logic.lua
-- 创建者　：furuilei
-- 创建时间：2009-05-18 17:50:18
-- 描述：用来对玩家流失进行统计分析

if (MODULE_GAMECLIENT) then
	return;
end

-- 记录没有登陆游戏的最大天数
function Stats:LogUnLoginTime(bIsExecute)
	if (bIsExecute == self.LOGINEXE) then
		if (me.nLastSaveTime == 0) then
			return;
		end
		local nUnLoginTime = math.floor(GetTime() / self.ONEDAYTIME - me.nLastSaveTime / self.ONEDAYTIME);
		if (nUnLoginTime > me.GetTask(self.TASK_GROUP, self.TASK_ID_UNLOGINTIME)) then
			me.SetTask(self.TASK_GROUP, self.TASK_ID_UNLOGINTIME, nUnLoginTime);
		end
	end
end

-- 记录没有获取到江湖威望的最大天数
function Stats:LogUnFetchReputeTime(bIsExecute)
	if (bIsExecute == self.LOGOUTEXE) then
		if (me.GetTask(self.TASK_GROUP, self.TASK_ID_LASTGETREPUTETIME) == 0) then
			return;
		end
		local nLastGetReputeTime = me.GetTask(self.TASK_GROUP, self.TASK_ID_LASTGETREPUTETIME);
		local nUnFetchReputeTime = math.floor(GetTime() / self.ONEDAYTIME - nLastGetReputeTime / self.ONEDAYTIME);
		if (nUnFetchReputeTime > me.GetTask(self.TASK_GROUP, self.TASK_ID_UNGETREPUTETIME)) then
			me.SetTask(self.TASK_GROUP, self.TASK_ID_UNGETREPUTETIME, nUnFetchReputeTime);
		end
	end
end

-- 在获取江湖威望的时候实时地触发
function Stats:UpdateGetReputeTime(pPlayer)
	local nLoginTime = pPlayer.GetTask(self.TASK_GROUP_LOGIN, self.TASK_ID_LOGINTIME);
	local nLastGetReputeTime = pPlayer.GetTask(self.TASK_GROUP, self.TASK_ID_LASTGETREPUTETIME);
	local nLastTimePoint = nLoginTime;
	if (nLastGetReputeTime > nLoginTime) then
		nLastTimePoint = nLastGetReputeTime;
	end
	local nDifTime = math.floor(GetTime() / self.ONEDAYTIME - nLastTimePoint / self.ONEDAYTIME);
	if (nDifTime > 0 and nDifTime > pPlayer.GetTask(self.TASK_GROUP, self.TASK_ID_UNGETREPUTETIME)) then
		pPlayer.SetTask(self.TASK_GROUP, self.TASK_ID_UNGETREPUTETIME, nDifTime);
	end
	
	pPlayer.SetTask(self.TASK_GROUP, self.TASK_ID_LASTGETREPUTETIME, GetTime());
end

-- 达到条件但没有使用福利精活的最大天数
function Stats:LogUnUseFuliJinghuoTime(bIsExecute)
	if (bIsExecute == self.LOGOUTEXE) then
		self:MarkPlayerType();
		local nPlayerType = me.GetTask(self.TASK_GROUP, self.TASK_ID_PLAYERTYPE);
		if (2 == nPlayerType) then
			if (me.GetTask(self.TASK_GROUP, self.TASK_ID_LASTGETFULITIME) == 0) then
				return;
			end
			local nLastGetFuliTime = me.GetTask(self.TASK_GROUP, self.TASK_ID_LASTGETFULITIME);
			local nUnUseFuliTime = math.floor(GetTime() / self.ONEDAYTIME - nLastGetFuliTime / self.ONEDAYTIME);
			local nMaxUnUseFuliTime = me.GetTask(self.TASK_GROUP, self.TASK_ID_UNUSEFULITIME);
			if (nUnUseFuliTime > nMaxUnUseFuliTime) then
				me.SetTask(self.TASK_GROUP, self.TASK_ID_UNUSEFULITIME, nUnUseFuliTime);
			end
		end
	end
end

-- 在获取福利精活的时候实时地更新
function Stats:UpdateGetFuliTime()
	local nLoginTime = me.GetTask(self.TASK_GROUP_LOGIN, self.TASK_ID_LOGINTIME);
	local nLastGetFuliTime = me.GetTask(self.TASK_GROUP, self.TASK_ID_LASTGETFULITIME);
	local nLastTimePoint = nLoginTime;
	if (nLastGetFuliTime > nLoginTime) then
		nLastTimePoint = nLastGetFuliTime;
	end
	local nDifTime = math.floor(GetTime() / self.ONEDAYTIME - nLastTimePoint /self.ONEDAYTIME);
	if (nDifTime > 0 and nDifTime > me.GetTask(self.TASK_GROUP, self.TASK_ID_UNUSEFULITIME)) then
		me.SetTask(self.TASK_GROUP, self.TASK_ID_UNUSEFULITIME, nDifTime);
	end
	
	me.SetTask(Stats.TASK_GROUP, self.TASK_ID_PLAYERTYPE, 3);
	me.SetTask(self.TASK_GROUP, self.TASK_ID_LASTGETFULITIME, GetTime());
end

function Stats:MarkPlayerType()
	local nPlayerType = 1;	-- 默认为没有达到领取福利的标准
	local tbBuyJinghuo = Player.tbBuyJingHuo;
	if (me.nLevel > tbBuyJinghuo.nLevelMax) then
		local nPrestige = tbBuyJinghuo:GetTodayPrestige();
		if (nPrestige > 0 and me.nPrestige >= nPrestige) then
			local nLastGetFuliTime = tonumber(os.date("%Y%m%d", me.GetTask(self.TASK_GROUP, self.TASK_ID_LASTGETFULITIME)));
			local nNowTime = tonumber(os.date("%Y%m%d", GetTime()));
			if (nLastGetFuliTime == nNowTime) then
				nPlayerType = 3;	-- 达到标准并且已经领取福利
			else
				nPlayerType = 2;	-- 达到标准但是没有领取福利
			end
		end
	end
	me.SetTask(self.TASK_GROUP, self.TASK_ID_PLAYERTYPE, nPlayerType);
end

-- 记录不足平均在线时间一半的最大天数
function Stats:LogHalfAvgTime(bIsExecute, bIsBelowHalfTime)
	if (not bIsBelowHalfTime or bIsBelowHalfTime ~= 1)then
		return;
	end
	local nBelowHalfAvgTime = self:GetTaskValue(self.TASK_ID_CURBELOWHALFTIME);
	local nMaxBelowHalfTime = me.GetTask(self.TASK_GROUP, self.TASK_ID_BELOWHALFTIME);
	if (nBelowHalfAvgTime > nMaxBelowHalfTime) then
		me.SetTask(self.TASK_GROUP, self.TASK_ID_BELOWHALFTIME, nBelowHalfAvgTime);
	end
end

-- 记录在线时间不足4小时的最大天数
function Stats:LogBelow4HoursTime(bIsExecute, bIsBelow4HoursTime)
	if (not bIsBelow4HoursTime or bIsBelow4HoursTime ~= 1) then
		return;
	end
	local nBelow4HoursTime = self:GetTaskValue(self.TASK_ID_CURBELOW4HOURSTIME);
	local nMaxBelow4HoursTime = me.GetTask(self.TASK_GROUP, self.TASK_ID_BELOW4HOURSTIME);
	if (nBelow4HoursTime > nMaxBelow4HoursTime) then
		me.SetTask(self.TASK_GROUP, self.TASK_ID_BELOW4HOURSTIME, nBelow4HoursTime);
	end
end

-- 记录玩家的当天在线时间
-- 存在两个返回值（是否超过平均在线时间的一半，是否超过4小时）
function Stats:RecordOnLineTime(bIsExecute)
	local nLastSaveTime  = tonumber(os.date("%Y%m%d", me.nLastSaveTime));
	local nNowTime = tonumber(os.date("%Y%m%d", GetTime()));
	local nHalfTime = self:CalcAvgTime() / 2;
	if (bIsExecute == self.LOGINEXE) then
		return self:ProcLoginOnlineTime(bIsExecute, nLastSaveTime, nNowTime, nHalfTime);
	elseif (bIsExecute == self.LOGOUTEXE) then
		return self:ProcLogoutOnlineTime(bIsExecute, nNowTime, nHalfTime);
	end
end

-- 用来处理登录时的在线时间
function Stats:ProcLoginOnlineTime(bIsExecute, nLastSaveTime, nNowTime, nHalfTime)
	local bIsBelowHalfTime = 0;
	local bIsBelow4Hours = 0;
	if (nLastSaveTime ~= nNowTime) then
		local nLastDayOnlineTime = me.GetTask(self.TASK_GROUP, self.TASK_ID_TODAYONLINETIME);
		self:SetTaskBitFlag(self.TASK_ID_CURBELOW4HOURSTIME, self.PLAYER_STATE_TODAY_NOTADD);
		self:SetTaskBitFlag(self.TASK_ID_CURBELOWHALFTIME, self.PLAYER_STATE_TODAY_NOTADD);
		me.SetTask(self.TASK_GROUP, self.TASK_ID_TODAYONLINETIME, 0);	-- 日期发生改变，把当天在线时间清零重新计算
		bIsBelowHalfTime = self:AppHalfTimeStatus(bIsExecute, nLastDayOnlineTime, nHalfTime);
		bIsBelow4Hours = self:App4HourStatus(bIsExecute, nLastDayOnlineTime);
	end
	return bIsBelowHalfTime, bIsBelow4Hours;
end

-- 用来处理下线时的在线时间
function Stats:ProcLogoutOnlineTime(bIsExecute, nNowTime, nHalfTime)
	local bIsBelowHalfTime = 0;
	local bIsBelow4Hours = 0;
	local nLastLoginTime = me.GetTask(self.TASK_GROUP_LOGIN, self.TASK_ID_LOGINTIME);
	local nLoginTime = tonumber(os.date("%Y%m%d", nLastLoginTime));
	if (nLoginTime == nNowTime) then
		local nTodayOnlineTime = me.GetTask(self.TASK_GROUP, self.TASK_ID_TODAYONLINETIME) + (GetTime() - nLastLoginTime);
		me.SetTask(self.TASK_GROUP, self.TASK_ID_TODAYONLINETIME, nTodayOnlineTime);
		bIsBelowHalfTime = self:AppHalfTimeStatus(bIsExecute, nTodayOnlineTime, nHalfTime);
		bIsBelow4Hours = self:App4HourStatus(bIsExecute, nTodayOnlineTime);
	else
		-- 在线时间跨天的情况
		local nZeroSec = Lib:GetDate2Time(nLoginTime) + self.ONEDAYTIME;	-- 玩家在线时间跨天时，登录时间所在天的24点对应的秒数
		local nTodayZeroSec = Lib:GetDate2Time(nNowTime);	-- 玩家在线时间跨天时，下线时间所在天的0点对应的秒数
		-- 玩家登陆时间所在天的在线时间
		local nLastDayOnlineTime = me.GetTask(self.TASK_GROUP, self.TASK_ID_TODAYONLINETIME) + (nZeroSec - nLastLoginTime);
		local bIsCrossAbove1Day = 0;
		if ((nTodayZeroSec - nZeroSec) > self.ONEDAYTIME) then
			bIsCrossAbove1Day = 1;
		end
		
		
		me.SetTask(self.TASK_GROUP, self.TASK_ID_TODAYONLINETIME, GetTime() - nTodayZeroSec);
		self:Cross0Clock(nLastDayOnlineTime, self.TASK_ID_BELOW4HOURSTIME, bIsCrossAbove1Day);
		self:Cross0Clock(nLastDayOnlineTime, self.TASK_ID_BELOWHALFTIME, bIsCrossAbove1Day);
	end
	return bIsBelowHalfTime, bIsBelow4Hours;
end

-- 处理玩家在线时间跨天的情况
function Stats:Cross0Clock(nLastDayOnlineTime, nTaskId, bIsCrossAbove1Day)
	local nTodayOnlineTime = me.GetTask(self.TASK_GROUP, self.TASK_ID_TODAYONLINETIME);
	local nHalfTime = self:CalcAvgTime() / 2;
	local nCmpTime = nHalfTime;
	local nCurTaskId = self.TASK_ID_CURBELOWHALFTIME;
	if (nTaskId == self.TASK_ID_BELOW4HOURSTIME) then
		nCmpTime = self.ONLINETIME;
		nCurTaskId = self.TASK_ID_CURBELOW4HOURSTIME;
	end
	if (nLastDayOnlineTime < nCmpTime) then
		if (self:GetTaskBitFlag(nCurTaskId) ~= self.PLAYER_STATE_TODAY_ADD) then
		 	local nTime = self:GetTaskValue(nCurTaskId) + 1;
			self:SetTaskBitFlag(nCurTaskId, self.PLAYER_STATE_TODAY_ADD);
			self:SetTaskValue(nCurTaskId, nTime);
		end
		if (nTaskId == self.TASK_ID_BELOWHALFTIME) then
			self:LogHalfAvgTime(self.LOGOUTEXE, 1);
		else
			self:LogBelow4HoursTime(self.LOGOUTEXE, 1);
		end
		
		if (bIsCrossAbove1Day == 1) then
			me.SetTask(self.TASK_GROUP, nCurTaskId, 0);
			self:SetTaskBitFlag(nCurTaskId, self.PLAYER_STATE_TODAY_NOTADD);
		end
		
		if (nTodayOnlineTime < nCmpTime) then
			local nCurTimes = self:GetTaskValue(nCurTaskId) + 1;
			self:SetTaskValue(nCurTaskId, nCurTimes);
			self:SetTaskBitFlag(nCurTaskId, self.PLAYER_STATE_TODAY_ADD);
		else
			me.SetTask(self.TASK_GROUP, nCurTaskId, 0);
			self:SetTaskBitFlag(nCurTaskId, self.PLAYER_STATE_TODAY_NOTADD);
		end
	else
		me.SetTask(self.TASK_GROUP, nCurTaskId, 0);
		self:SetTaskBitFlag(nCurTaskId, self.PLAYER_STATE_TODAY_NOTADD);
		if (nTodayOnlineTime < nCmpTime) then
			local nCurTimes = self:GetTaskValue(nCurTaskId) + 1;
			self:SetTaskValue(nCurTaskId, nCurTimes);
			self:SetTaskBitFlag(nCurTaskId, self.PLAYER_STATE_TODAY_ADD);
		end
	end
end

-- 返回玩家的一天在线总时间是否超过4小时
function Stats:App4HourStatus(bIsExecute, nDayOnlineTime)
	local bIsBelow4Hours = 0;
	if (nDayOnlineTime <= self.ONLINETIME) then
		if (bIsExecute == self.LOGINEXE) then
			bIsBelow4Hours = 1;
		else
			if (self:GetTaskBitFlag(self.TASK_ID_CURBELOW4HOURSTIME) ~= self.PLAYER_STATE_TODAY_ADD) then
				local nCurBelow4HoursTime = self:GetTaskValue(self.TASK_ID_CURBELOW4HOURSTIME) + 1;
				self:SetTaskValue(self.TASK_ID_CURBELOW4HOURSTIME, nCurBelow4HoursTime);
				self:SetTaskBitFlag(self.TASK_ID_CURBELOW4HOURSTIME, self.PLAYER_STATE_TODAY_ADD);
			end
		end
	else
		me.SetTask(self.TASK_GROUP, self.TASK_ID_CURBELOW4HOURSTIME, 0);
		self:SetTaskBitFlag(self.TASK_ID_CURBELOW4HOURSTIME, self.PLAYER_STATE_TODAY_NOTADD);
	end
	return bIsBelow4Hours;
end

-- 返回玩家的一天在线总时间是否低于平均在线时间的一般
function Stats:AppHalfTimeStatus(bIsExecute, nDayOnlineTime, nHalfTime)
	local bIsBelowHalfTime = 0;
	if (nDayOnlineTime <= nHalfTime) then
		if (bIsExecute == self.LOGINEXE) then
			bIsBelowHalfTime = 1;
		else
			if (self:GetTaskBitFlag(self.TASK_ID_CURBELOWHALFTIME) ~= self.PLAYER_STATE_TODAY_ADD) then
				local nCurBelowHalfTime = self:GetTaskValue(self.TASK_ID_CURBELOWHALFTIME) + 1;
				self:SetTaskValue(self.TASK_ID_CURBELOWHALFTIME, nCurBelowHalfTime);
				self:SetTaskBitFlag(self.TASK_ID_CURBELOWHALFTIME, self.PLAYER_STATE_TODAY_ADD);
			end
		end
	else
		me.SetTask(self.TASK_GROUP, self.TASK_ID_CURBELOWHALFTIME, 0);
		self:SetTaskBitFlag(self.TASK_ID_CURBELOWHALFTIME, self.PLAYER_STATE_TODAY_NOTADD);
	end
	return bIsBelowHalfTime;
end

-- 计算玩家的平均在线时间
function Stats:CalcAvgTime()
	local nRoleCreateTime = Lib:GetDate2Time(me.GetRoleCreateDate());
	local nRoleExistDay = math.floor(GetTime() / self.ONEDAYTIME - nRoleCreateTime / self.ONEDAYTIME);
	if (nRoleExistDay == 0) then
		return me.nOnlineTime;
	else
		return math.floor(me.nOnlineTime / nRoleExistDay);
	end
end

-- 如果开始新一轮的统计的话，把过去的统计全部清零，重新开始统计
function Stats:Init()
	local nKey = me.GetTask(self.TASK_GROUP, self.TASK_ID_STATS_KEY);
	local nGlobleKey = KGblTask.SCGetDbTaskInt(DBTASK_STATS_KEY);
	if (nKey ~= nGlobleKey) then
		me.SetTask(self.TASK_GROUP, self.TASK_ID_STATS_KEY, nGlobleKey);
		for i = 2, self.COUNT_TASK_ID do
			me.SetTask(self.TASK_GROUP, i, 0);
		end
	end
end

function Stats:OnLogin(bExchangeServerComing)
	if (not bExchangeServerComing or 1 == bExchangeServerComing) then
		return;
	end
	
	self:Init();
	
	local bLoginExe = self.LOGINEXE;
	local bIsBelowHalfTime, bIsBelow4Hours = self:RecordOnLineTime(bLoginExe);
	self:LogUnLoginTime(bLoginExe);
	self:LogHalfAvgTime(bLoginExe, bIsBelowHalfTime);
	self:LogBelow4HoursTime(bLoginExe, bIsBelow4Hours);
end

function Stats:OnLogout(szReason)
	if (not szReason or "Logout" ~= szReason) then
		return;
	end
	
	local bLogoutExe = self.LOGOUTEXE;
	local bIsBelowHalfTime, bIsBelow4Hours = self:RecordOnLineTime(bLogoutExe);
	self:LogUnFetchReputeTime(bLogoutExe);
	self:LogUnUseFuliJinghuoTime(bLogoutExe);
	self:LogHalfAvgTime(bLogoutExe, bIsBelowHalfTime);
	self:LogBelow4HoursTime(bLogoutExe, bIsBelow4Hours);
end

-- 注册通用上线事件
PlayerEvent:RegisterGlobal("OnLogin", Stats.OnLogin, Stats);

-- 注册通用下线事件
PlayerEvent:RegisterGlobal("OnLogout", Stats.OnLogout, Stats);
