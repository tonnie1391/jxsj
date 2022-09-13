
-- 逍遥谷GC逻辑
function XoyoGame:InitGC()
	self.tbData = {};
	self.tbXoyoRank = {};
	self.tbLastMonthXoyoRank = {};
	self.tbXoyoKinRank = {};
	self.tbLastMonthXoyoKinRank = {};
	self.nLastSaveTime = GetTime();
	self.nRankChangeTimes = 0;
end

function XoyoGame:LoadRankData_GC()
	local nMonth = tonumber(GetLocalDate("%Y%m"));
	local nRecordMonth = KGblTask.SCGetDbTaskInt(DBTASK_XOYO_RANK_LAST_MONTH);
	if nRecordMonth == 0 then	-- 第一次启动清buf
		SetGblIntBuf(GBLINTBUF_XOYO_RANK, 0, 1, {});
		SetGblIntBuf(GBLINTBUF_LAST_MONTH_XOYO_RANK, 0, 1, {});
		SetGblIntBuf(GBLINTBUF_XOYO_KIN_RANK, 0, 1, {});
		SetGblIntBuf(GBLINTBUF_XOYO_KIN_RANK_EX, 0, 1, {});
		KGblTask.SCSetDbTaskInt(DBTASK_XOYO_RANK_LAST_MONTH, nMonth);
	end
	self.tbXoyoRank = GetGblIntBuf(GBLINTBUF_XOYO_RANK, 0) or {};
	self.tbLastMonthXoyoRank = GetGblIntBuf(GBLINTBUF_LAST_MONTH_XOYO_RANK, 0) or {};
	local tbAllXoyoKinRank = GetGblIntBuf(GBLINTBUF_XOYO_KIN_RANK, 0) or {};
	self.tbXoyoKinRank = tbAllXoyoKinRank.tbRank or {};
	self.tbLastMonthXoyoKinRank = tbAllXoyoKinRank.tbLastRank or {};
	XoyoGame:ChangeMonthData();
end

function XoyoGame:ChangeMonthData() -- 月初更新数据
	local nMonth = tonumber(GetLocalDate("%Y%m"));
	local nRecordMonth = KGblTask.SCGetDbTaskInt(DBTASK_XOYO_RANK_LAST_MONTH);
	if nMonth > nRecordMonth then
		local tbTempXoyoKinRank = {};
		tbTempXoyoKinRank.tbRank = {};
		tbTempXoyoKinRank.tbLastRank = self.tbXoyoKinRank;
		SetGblIntBuf(GBLINTBUF_XOYO_RANK, 0, 1, {});
		SetGblIntBuf(GBLINTBUF_LAST_MONTH_XOYO_RANK, 0, 1, self.tbXoyoRank);
		SetGblIntBuf(GBLINTBUF_XOYO_KIN_RANK, 0, 1, tbTempXoyoKinRank);
		SetGblIntBuf(GBLINTBUF_XOYO_KIN_RANK_EX, 0, 1, {});
		KGblTask.SCSetDbTaskInt(DBTASK_XOYO_RANK_LAST_MONTH, nMonth);
		self.tbLastMonthXoyoRank = self.tbXoyoRank;
		self.tbXoyoRank = {};
		self.tbLastMonthXoyoKinRank = self.tbXoyoKinRank;
		self.tbXoyoKinRank = {};
		GSExcute(-1, {"XoyoGame:LoadDataBuf"});
	end
end
-- 同步变量不同步buf
function XoyoGame:UpdateKinRankData(nKinId, nTollGatePoint, nAchieveTime)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return;
	end
	if not nTollGatePoint or nTollGatePoint <= 0 then
		return;
	end
	local nMonth = cKin.GetXoyoMonth();
	local nTaskMonth = KGblTask.SCGetDbTaskInt(DBTASK_XOYO_RANK_LAST_MONTH);
	local nKinPoint = nTollGatePoint;
	if nMonth > nTaskMonth then	-- 这种情况是异常的
		Dbg:WriteLog("XoyoGame:UpdateKinRankData Error 家族ID：" .. nKinId .. "的地狱逍遥谷数据数据异常");
		return;
	end
	if nTaskMonth > nMonth then
		cKin.SetXoyoMonth(nTaskMonth);
	else
		nKinPoint = nKinPoint + cKin.GetXoyoPoint();
	end
	cKin.SetXoyoPoint(nKinPoint);
	local nNowTime = nAchieveTime or GetTime();
	cKin.SetXoyoLastTime(nNowTime);
	local nHandle = 0;	-- 是否已处理
	local tbXoyoKinRank = self.tbXoyoKinRank;
	local tbNewRecord = {szName = cKin.GetName(), nPoint = nKinPoint, nTime = nNowTime};
	-- 查找是否在记录中
	for nRank, tbTempRecord in ipairs(tbXoyoKinRank) do
		if tbTempRecord.szName == tbNewRecord.szName then -- 有记录了则覆盖
			tbXoyoKinRank[nRank].nPoint = tbNewRecord.nPoint;
			tbXoyoKinRank[nRank].nTime = tbNewRecord.nTime;
			table.sort(tbXoyoKinRank, self._KinRankCmp);
			nHandle = 1;
			if MODULE_GC_SERVER then
				self:SaveKinRankData_GC();
			end
		end
	end
	if nHandle == 0 and #tbXoyoKinRank < XoyoGame.KIN_MAX_RANK then
		table.insert(tbXoyoKinRank, tbNewRecord);
		table.sort(tbXoyoKinRank, self._KinRankCmp);
		nHandle = 1;
		if MODULE_GC_SERVER then
			self:SaveKinRankData_GC();
		end
	elseif nHandle == 0 then
		if (tbXoyoKinRank[XoyoGame.KIN_MAX_RANK].nPoint < tbNewRecord.nPoint) or (tbXoyoKinRank[XoyoGame.KIN_MAX_RANK].nPoint == tbNewRecord.nPoint and tbXoyoKinRank[XoyoGame.KIN_MAX_RANK].nTime > tbNewRecord.nTime) then
			table.insert(tbXoyoKinRank, tbNewRecord);
			table.sort(tbXoyoKinRank, self._KinRankCmp);
			tbXoyoKinRank[XoyoGame.KIN_MAX_RANK + 1] = nil;
			nHandle = 1;
			if MODULE_GC_SERVER then
				self:SaveKinRankData_GC();
			end
		end
	end
	if MODULE_GC_SERVER then
		GSExcute(-1, {"XoyoGame:UpdateKinRankData", nKinId, nTollGatePoint, nNowTime});
	end
end

XoyoGame._KinRankCmp = function (tb1, tb2)
	if tb1.nPoint ~= tb2.nPoint then
		return tb1.nPoint > tb2.nPoint;
	end
	return tb1.nTime < tb2.nTime;
end

function XoyoGame:SaveKinRankData_GC(nFlag)
	self.nRankChangeTimes = self.nRankChangeTimes + 1;
	local tbAllKinRecord = {};
	tbAllKinRecord.tbRank = self.tbXoyoKinRank;
	tbAllKinRecord.tbLastRank = self.tbLastMonthXoyoKinRank;
	if nFlag and nFlag == 1 then
		SetGblIntBuf(GBLINTBUF_XOYO_KIN_RANK, 0, 1, tbAllKinRecord);	-- 强制存盘同步一下
		return;
	end
	local nNowTime = GetTime();
	if nNowTime - self.nLastSaveTime > XoyoGame.KIN_RANK_SYN_CD then	-- 超过30秒的间隔存盘一次
		SetGblIntBuf(GBLINTBUF_XOYO_KIN_RANK, 0, 1, tbAllKinRecord);
		self.nLastSaveTime = nNowTime;
	elseif self.nRankChangeTimes > XoyoGame.KIN_RANK_CHANGGE_TIMES then	-- 数据变化了两百次同步一次,防止gs宕机重启的时候数据不准确
		self.nRankChangeTimes = 0;
		self:SynKinRecordData();
	end
end

function XoyoGame:SaveRankData()
	SetGblIntBuf(GBLINTBUF_XOYO_RANK, 0, 1, self.tbXoyoRank);
end

function XoyoGame:SynKinRecordData()
	self:SaveKinRankData_GC(1)
	GSExcute(-1, {"XoyoGame:LoadDataBuf"});
end

function XoyoGame:DeleteRankData(nDifficuty, nRank)
	if (XoyoGame.tbXoyoRank[nDifficuty] == nil or #XoyoGame.tbXoyoRank[nDifficuty] == 0) then
		return;
	end
	if (nRank < 1 or nRank > XoyoGame.RANK_RECORD) then
		return;
	end
	local tbRank = self.tbXoyoRank[nDifficuty];
	for i = nRank, #tbRank[nRank] do
		tbRank[i] = tbRank[i + 1];
	end
end

function XoyoGame:ApplySyncData()
	GSExcute(-1, {"XoyoGame:OnSyncRankData", self.tbXoyoRank});
end

function XoyoGame:RecordRankData(nNewTime, nDifficuty, tbMember)
	if MODULE_GAMESERVER then
		GCExcute({"XoyoGame:RecordRankData", nNewTime, nDifficuty, tbMember});
	elseif MODULE_GC_SERVER then
		XoyoGame.tbXoyoRank[nDifficuty] = XoyoGame.tbXoyoRank[nDifficuty] or {};
		local tbRank = self.tbXoyoRank[nDifficuty];
		local tbNewRecord = { nDate = GetTime(), nTime = nNewTime, tbMember = tbMember };
		table.insert(tbRank, tbNewRecord);
		table.sort(tbRank, function (tb1, tb2)
			return tb1.nTime < tb2.nTime;
		end);
		if (#tbRank > XoyoGame.RANK_RECORD) then
			tbRank[XoyoGame.RANK_RECORD + 1] = nil;
		end
		self:SaveRankData();
		XoyoGame:ApplySyncData();
	end
end

function XoyoGame:CreateManager_GC(nMapId)
	if not XoyoGame.MANAGER_GROUP[nMapId] then
		return 0;
	end
	local tbCurData = {}
	for i, nGameId in pairs(self.MANAGER_GROUP[nMapId]) do
		tbCurData[nGameId] = self.tbData[nGameId];
	end
	GlobalExcute {"XoyoGame:CreateManager_GS2", nMapId, tbCurData};
end

function XoyoGame:SyncGameData_GC(nCityMapId, nData)
	self.tbData[nCityMapId] = nData;
	GlobalExcute{"XoyoGame:SyncGameData_GS2", nCityMapId, nData};
end

function XoyoGame:ReduceTeam_GC(nGameId, nData)
	self.tbData[nGameId] = nData;
	GlobalExcute{"XoyoGame:ReduceTeam_GS2", nGameId};
end

-- 开始新的一轮闯关
function XoyoGame:StartNewRound()
	GlobalExcute{"XoyoGame:LockManager", 1};		-- 先锁所有的manager
	Timer:Register(self.LOCK_MANAGER_TIME * Env.GAME_FPS, self.StartGame_GC, self)	-- 一定时间后执行开始操作
end

function XoyoGame:StartGame_GC()
	GlobalExcute{"XoyoGame:StartGame_GS2"};
	return 0;
end

-- 每天更新逍遥排行榜数据
function XoyoGame:ChallengeDailyRankUpdate()
	local tbTime = os.date("*t", GetTime());
	if tbTime.day == 1 then
		PlayerHonor:UpdateXoyoLadder(1);
		SetXoyoAwardResult();
		ClearXoyoLadderData();
		KGblTask.SCSetDbTaskInt(DBTASK_XOYO_FINAL_LADDER_MONTH, tbTime.year*100+tbTime.month);
		self:SaveKinRankData_GC(1);
		self:ChangeMonthData();
	else
		PlayerHonor:UpdateXoyoLadder(0);
		self:SynKinRecordData();	-- 每天0点修正一下家族排行榜数据
	end
end

function XoyoGame:ProcessCoZoneAndSubZoneBuf(tbSubBuf)
	self.tbXoyoRank = {};
	self:SaveRankData();
	local tbAllXoyoKinRank = GetGblIntBuf(GBLINTBUF_XOYO_KIN_RANK, 0) or {};
	self.tbXoyoKinRank = tbAllXoyoKinRank.tbRank or {};
	self.tbLastMonthXoyoKinRank = tbAllXoyoKinRank.tbLastRank or {};
	
	local tbXoyoKinRank = self.tbXoyoKinRank;
	local tbNowSubKinRank = tbSubBuf.tbRank or {};
	for i, tbNewRecord in pairs(tbNowSubKinRank) do
		if #tbXoyoKinRank < XoyoGame.KIN_MAX_RANK then
			table.insert(tbXoyoKinRank, tbNewRecord);
			table.sort(tbXoyoKinRank, self._KinRankCmp);
		else
			if (tbXoyoKinRank[XoyoGame.KIN_MAX_RANK].nPoint < tbNewRecord.nPoint) or (tbXoyoKinRank[XoyoGame.KIN_MAX_RANK].nPoint == tbNewRecord.nPoint and tbXoyoKinRank[XoyoGame.KIN_MAX_RANK].nTime > tbNewRecord.nTime) then
				table.insert(tbXoyoKinRank, tbNewRecord);
				table.sort(tbXoyoKinRank, self._KinRankCmp);
				tbXoyoKinRank[XoyoGame.KIN_MAX_RANK + 1] = nil;
			end
		end
	end
	
	self.tbXoyoKinRank = tbXoyoKinRank;
	self:SaveKinRankData_GC(1);
	SetGblIntBuf(GBLINTBUF_XOYO_KIN_RANK_EX, 0, 1, tbSubBuf or {});
end

XoyoGame:InitGC();


if GCEvent ~= nil and GCEvent.RegisterGCServerStartFunc ~= nil then
	GCEvent:RegisterGCServerStartFunc(XoyoGame.LoadRankData_GC, XoyoGame);
end
if MODULE_GC_SERVER then
	GCEvent:RegisterGCServerShutDownFunc(XoyoGame.SaveKinRankData_GC, XoyoGame, 1);
end
