-- player_event_joinrecord.lua
-- zhouchenfei
-- 台湾版玩家参加各类活动统计记录，主要给他们运营发奖励用，因为每次有很多这样的需求，所以做成统一的
-- 2011-2-15 10:14:24

Player.DEF_JOIN_RECORD_TASK_GROUP = 2153;

-- 下面是各个活动的标识
Player.EVENT_JOIN_RECORD_DENGMI				= "guessgame";				-- 灯谜活动标志
Player.EVENT_JOIN_RECORD_BAIHUTANG			= "baihutang";			-- 白虎堂
Player.EVENT_JOIN_RECORD_MENPAIJINGJI		= "menpaijingji";		-- 门派竞技
Player.EVENT_JOIN_RECORD_JUNYINGRENWU		= "armycamp";		-- 军营任务
Player.EVENT_JOIN_RECORD_XOYOGAME			= "xoyogame";			-- 逍遥谷
Player.EVENT_JOIN_RECORD_LINGTUZHAN			= "lingtuzhan";			-- 领土战
Player.EVENT_JOIN_RECORD_WLLS				= "wlls";				-- 武林联赛
Player.EVENT_JOIN_RECORD_JIAZUJINGJI		= "jiazujingji";		-- 家族竞技
Player.EVENT_JOIN_RECORD_SONGJINBATTLE		= "songjinbattle";		-- 宋金战场

-- 玩家任务变量，记录玩家日参加活动次数
Player.TASK_JOIN_RECORD_ID_DAILY_COUNT	= {
		[Player.EVENT_JOIN_RECORD_DENGMI]			= 1,
		[Player.EVENT_JOIN_RECORD_BAIHUTANG]		= 2,
		[Player.EVENT_JOIN_RECORD_MENPAIJINGJI]		= 3,
		[Player.EVENT_JOIN_RECORD_JUNYINGRENWU]		= 4,
		[Player.EVENT_JOIN_RECORD_XOYOGAME]			= 5,
		[Player.EVENT_JOIN_RECORD_LINGTUZHAN]		= 6,
		[Player.EVENT_JOIN_RECORD_WLLS]				= 7,
		[Player.EVENT_JOIN_RECORD_JIAZUJINGJI]		= 8,
	};

-- 玩家任务变量，记录玩家月参加活动次数
Player.TASK_JOIN_RECORD_ID_MONTH_COUNT	= {
		[Player.EVENT_JOIN_RECORD_WLLS]				= 9,
		[Player.EVENT_JOIN_RECORD_JIAZUJINGJI]		= 10,
	};

-- 玩家任务变量，记录玩家参加活动的积分
Player.TASK_JOIN_RECORD_ID_MONTH_POINT	= {
		[Player.EVENT_JOIN_RECORD_WLLS]				= 11,
		[Player.EVENT_JOIN_RECORD_JIAZUJINGJI]		= 12,	
	};

-- 设置日次数
---------------------------------------------------------------------
function Player:SetJoinRecord_DailyCount(pPlayer, szEventFlag, nCount)
	if (not pPlayer) then
		return 0;
	end

	local nTaskId = self.TASK_JOIN_RECORD_ID_DAILY_COUNT[szEventFlag];

	if (not nTaskId) then
		return 0;
	end
	
	pPlayer.SetTask(self.DEF_JOIN_RECORD_TASK_GROUP, nTaskId, nCount);
	return 1;
end

function Player:GetJoinRecord_DailyCount(pPlayer, szEventFlag)
	if (not pPlayer) then
		return 0;
	end

	local nTaskId = self.TASK_JOIN_RECORD_ID_DAILY_COUNT[szEventFlag];

	if (not nTaskId) then
		return 0;
	end
	
	return pPlayer.GetTask(self.DEF_JOIN_RECORD_TASK_GROUP, nTaskId);
end

function Player:AddJoinRecord_DailyCount(pPlayer, szEventFlag, nCount)
	if (not pPlayer) then
		return 0;
	end
	local nOrgCount = self:GetJoinRecord_DailyCount(pPlayer,szEventFlag);
	return self:SetJoinRecord_DailyCount(pPlayer, szEventFlag, nCount + nOrgCount);
end

-- 设置月次数
---------------------------------------------------------------------
function Player:SetJoinRecord_MonthCount(pPlayer, szEventFlag, nCount)
	if (not pPlayer) then
		return 0;
	end

	local nTaskId = self.TASK_JOIN_RECORD_ID_MONTH_COUNT[szEventFlag];

	if (not nTaskId) then
		return 0;
	end
	
	pPlayer.SetTask(self.DEF_JOIN_RECORD_TASK_GROUP, nTaskId, nCount);
	return 1;
end

function Player:GetJoinRecord_MonthCount(pPlayer, szEventFlag)
	if (not pPlayer) then
		return 0;
	end

	local nTaskId = self.TASK_JOIN_RECORD_ID_MONTH_COUNT[szEventFlag];

	if (not nTaskId) then
		return 0;
	end
	
	return pPlayer.GetTask(self.DEF_JOIN_RECORD_TASK_GROUP, nTaskId);
end

function Player:AddJoinRecord_MonthCount(pPlayer, szEventFlag, nCount)
	if (not pPlayer) then
		return 0;
	end
	local nOrgCount = self:GetJoinRecord_MonthCount(pPlayer, szEventFlag);
	return self:SetJoinRecord_MonthCount(pPlayer, szEventFlag, nCount + nOrgCount);
end

-- 设置月积分
---------------------------------------------------------------------
function Player:SetJoinRecord_MonthPoint(pPlayer, szEventFlag, nCount)
	if (not pPlayer) then
		return 0;
	end

	local nTaskId = self.TASK_JOIN_RECORD_ID_MONTH_POINT[szEventFlag];

	if (not nTaskId) then
		return 0;
	end
	
	pPlayer.SetTask(self.DEF_JOIN_RECORD_TASK_GROUP, nTaskId, nCount);
	return 1;
end

function Player:GetJoinRecord_MonthPoint(pPlayer, szEventFlag)
	if (not pPlayer) then
		return 0;
	end

	local nTaskId = self.TASK_JOIN_RECORD_ID_MONTH_POINT[szEventFlag];

	if (not nTaskId) then
		return 0;
	end
	
	return pPlayer.GetTask(self.DEF_JOIN_RECORD_TASK_GROUP, nTaskId);
end

function Player:AddJoinRecord_MonthPoint(pPlayer, szEventFlag, nCount)
	if (not pPlayer) then
		return 0;
	end
	local nOrgCount = self:GetJoinRecord_MonthPoint(pPlayer, szEventFlag);
	return self:SetJoinRecord_MonthPoint(pPlayer, szEventFlag, nCount + nOrgCount);
end

function Player:ClearJoinRecord_DailyCount(pPlayer)
	for szEventFlag, nTaskId in pairs(self.TASK_JOIN_RECORD_ID_DAILY_COUNT) do
		self:SetJoinRecord_DailyCount(pPlayer, szEventFlag, 0);
	end
end

function Player:ClearJoinRecord_MonthCount(pPlayer)
	for szEventFlag, nTaskId in pairs(self.TASK_JOIN_RECORD_ID_MONTH_COUNT) do
		self:SetJoinRecord_MonthCount(pPlayer, szEventFlag, 0);
	end
end

function Player:ClearJoinRecord_MonthPoint(pPlayer)
	for szEventFlag, nTaskId in pairs(self.TASK_JOIN_RECORD_ID_MONTH_POINT) do
		self:SetJoinRecord_MonthPoint(pPlayer, szEventFlag, 0);
	end
end

function Player:UpdateJoinRecord_WllsPoint(pPlayer)
	if (not pPlayer) then
		return 0;
	end
	
	local szLeagueName = League:GetMemberLeague(Wlls.LGTYPE, pPlayer.szName);
	if not szLeagueName then
		return 0;
	end
	local nSession	= pPlayer.GetTask(Wlls.TASKID_GROUP, Wlls.TASKID_HELP_SESSION);
	
	-- 如果不是一届的就不更新
	if (nSession ~= Wlls:GetMacthSession()) then
		return 0;
	end

	local nTotal	= pPlayer.GetTask(Wlls.TASKID_GROUP, Wlls.TASKID_HELP_TOTLE);
	local nWin		= pPlayer.GetTask(Wlls.TASKID_GROUP, Wlls.TASKID_HELP_WIN);
	local nTie		= pPlayer.GetTask(Wlls.TASKID_GROUP, Wlls.TASKID_HELP_TIE);
	local nLoss		= nTotal - nWin - nTie;
	
	local nPoint = nWin * Wlls.MACTH_POINT_WIN + nTie * Wlls.MACTH_POINT_TIE + nLoss * Wlls.MACTH_POINT_LOSS;
	
	self:SetJoinRecord_MonthPoint(pPlayer, self.EVENT_JOIN_RECORD_WLLS, nPoint);
	return 1;
end

function Player:PlayerJoinRecord_DailyEvent()
	self:ClearJoinRecord_DailyCount(me);
end

function Player:PlayerJoinRecord_MonthEvent()
	self:ClearJoinRecord_MonthCount(me);
	self:ClearJoinRecord_MonthPoint(me);
end

PlayerSchemeEvent:RegisterGlobalDailyEvent({Player.PlayerJoinRecord_DailyEvent, Player});

PlayerSchemeEvent:RegisterGlobalMonthEvent({Player.PlayerJoinRecord_MonthEvent, Player});
