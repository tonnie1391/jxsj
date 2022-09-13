-- 此函数在上线的时候和计时器时间到的时候(0点)触发
function PlayerSchemeEvent:OnDailyEvent()
	local pPlayer 		= me;
	local nNowTime		= GetTime();
	local nLastTime		= pPlayer.GetTask(2004, 1);
	local bChangeFlag 	= 0;
	if (0 ~= nLastTime) then
		for _, tbEvent in ipairs(self.tbPlayerSchemeEventSet) do
			local nDifNum	= tbEvent.CalFun(Lib, nNowTime) - tbEvent.CalFun(Lib, nLastTime);
			if (nDifNum > 0) then
				bChangeFlag = 1;
				for _, callback in ipairs(tbEvent.tbCall) do
					local tbCallBack = {unpack(callback)};
					tbCallBack[#tbCallBack + 1] = nDifNum;
					Lib:CallBack(tbCallBack);
				end
			end
		end
	else
		bChangeFlag = 1;
	end
	
	if (bChangeFlag) then
		pPlayer.SetTask(2004, 1, nNowTime);
	end

	local tbToday			= os.date("*t", nNowTime);
	local nTodayLostTime	= 0;
	if (tbToday.hour and tbToday.min and tbToday.sec) then
		nTodayLostTime	= tbToday.hour * 3600 + tbToday.min * 60 + tbToday.sec
	end
	local nTodayRemainTime	= 24 * 60 * 60 - nTodayLostTime  + MathRandom(10);
	Player:RegisterTimer(nTodayRemainTime * Env.GAME_FPS, PlayerSchemeEvent.OnDailyEvent, PlayerSchemeEvent);

	return 0;
end

-- 注册DailyEvent,每天0时调用
-- fnCallBack, varParam1, varParam2
function PlayerSchemeEvent:RegisterGlobalDailyEvent(...)
	assert(arg[1]);
	local tbPlayerSchemeEventSet = self:GetGlobalEvent();
	tbPlayerSchemeEventSet[1].tbCall[#tbPlayerSchemeEventSet[1].tbCall + 1] = arg[1];
end

function PlayerSchemeEvent:RegisterGlobalWeekEvent(...)
	assert(arg[1]);
	local tbPlayerSchemeEventSet = self:GetGlobalEvent();
	tbPlayerSchemeEventSet[2].tbCall[#tbPlayerSchemeEventSet[2].tbCall + 1] = arg[1];
end

function PlayerSchemeEvent:RegisterGlobalMonthEvent(...)
	assert(arg[1]);
	local tbPlayerSchemeEventSet = self:GetGlobalEvent();
	tbPlayerSchemeEventSet[3].tbCall[#tbPlayerSchemeEventSet[3].tbCall + 1] = arg[1];
end


function PlayerSchemeEvent:GetGlobalEvent()
	if (not self.tbPlayerSchemeEventSet) then
		self.tbPlayerSchemeEventSet	= {};
		self.tbPlayerSchemeEventSet[1] = { CalFun = Lib.GetLocalDay, tbCall = {}};
		self.tbPlayerSchemeEventSet[2] = { CalFun = Lib.GetLocalWeek, tbCall = {}};
		self.tbPlayerSchemeEventSet[3] = { CalFun = Lib.GetLocalMonth, tbCall = {}};
	end

	return self.tbPlayerSchemeEventSet;
end

