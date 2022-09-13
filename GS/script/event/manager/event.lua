-------------------------------------------------------------------
--File: 	event.lua
--Author: sunduoliang
--Date: 	2008-4-15
--Describe:	活动管理系统
--InterFace1:Init(...) 初始化数据
--InterFace2:CreateEvent() 建立大活动
--InterFace2:OnEventTime() 激活大活动

-------------------------------------------------------------------

local Event = {};
EventManager.Event = Event;
Event.tbEventParts = {};
function Event:ClearEventTables()
	Event.tbEventParts = nil;
end
function Event:Init(tbEvent)
	--初始化数据
	--print("Event Init ........");
	self.tbEvent = tbEvent;
--	self.tbEvent.nId 			= tonumber(tbEvent.nId) or 0 ;
--	self.tbEvent.szName 		= tbEvent.szName or "" ;
--	self.tbEvent.szDescript 	= tbEvent.szDescript or "";
--	self.tbEvent.nStartDate 	= tonumber(tbEvent.nStartDate) or 0;
--	self.tbEvent.nEndDate 		= tonumber(tbEvent.nEndDate) or 0;
--	self.tbEvent.szTable 		= tbEvent.szTable or "";
	
	self.tbDialog 	= {};	--初始化
	self.tbTimer 	= {};	--初始化
	self.tbNpcDrop	= {};	--初始化
	self.tbTimerId 	= {};	--初始化
	
	
	self.tbParam 	= {};
	self.tbEventPart= self.tbEventPart or {};
	if self.tbEvent.szTable == "" then
		return 0;
	end
	if Event.tbEventParts[self.tbEvent.szTable] == nil then				
		Event.tbEventParts[self.tbEvent.szTable] = Lib:LoadTabFile(self.tbEvent.szTable);
	end	
	local tbAllEventPart = Event.tbEventParts[self.tbEvent.szTable];
	if tbAllEventPart == nil then
		print("【活动系统出错】 活动组合表nil:", self.tbEvent.szName);
		return 0;
	end	
	for nEvent, tbEvent in ipairs(tbAllEventPart) do
		if nEvent >= 2 then
			--时间判断
			local nEventId = tonumber(tbEvent.EventId);
			if nEventId == self.tbEvent.nId then				
				local nStartDate = EventManager.tbFun:ClearString(tbEvent.StartDate);
				local nEndDate = EventManager.tbFun:ClearString(tbEvent.EndDate);
				nStartDate, nEndDate = EventManager.tbFun:DateFormat(nStartDate, nEndDate);
				if nEndDate == nil then
					return 0;
				end
				local nId = tonumber(tbEvent.PartId) or 0;
				self.tbParam[nId] = {};
				self.tbParam[nId].nId 			= tonumber(nId);
				self.tbParam[nId].szName 		= EventManager.tbFun:ClearString(tbEvent.Name);
				--self.tbParam[nId].szKind		= EventManager.tbFun:ClearString(tbEvent.Kind);
				self.tbParam[nId].szSubKind	 	= EventManager.tbFun:ClearString(tbEvent.SubKind);
				self.tbParam[nId].szExClass		= EventManager.tbFun:ClearString(tbEvent.ExClass);
				self.tbParam[nId].nStartDate 	= tonumber(nStartDate);
				self.tbParam[nId].nEndDate 		= tonumber(nEndDate);
				self.tbParam[nId].tbParam 		= {};
				self.tbParam[nId].tbParamIndex	= {};
				--if self.tbParam[nId].szKind == "" then
				--	self.tbParam[nId].szKind = "default";
				--end
				
				if self.tbParam[nId].szSubKind == "" then
					self.tbParam[nId].szSubKind = "default";
				end
						
				--20个参数读入
				for nParam = 1, EventManager.EVENT_PARAM_MAX do
					local szParamName = string.format("ExParam%s", nParam);
					local szParam = EventManager.tbFun:ClearString(tbEvent[szParamName]);
					if szParam ~= "" then
						table.insert(self.tbParam[nId].tbParam, szParam);
						self.tbParam[nId].tbParamIndex[nParam] = #self.tbParam[nId].tbParam;
					end
				end
			end
		end
	end
end

function Event:CreateEvent(bGmCmd)
	--读取szTable表, 把所有EventPark实例化
	for nEventPart, tbEventPart in pairs(self.tbParam) do
		self.tbEventPart[tbEventPart.nId] = self.tbEventPart[tbEventPart.nId] or Lib:NewClass(EventManager.EventPart);
		self.tbEventPart[tbEventPart.nId]:Init(self.tbEvent, tbEventPart, bGmCmd);
	end
	self:InsertDialog();--获取NpcPart对话建立对话表self.tbDialog
	self:InsertNpcDrop();--获取NpcPart掉落Npc，建立self.tbNpcDrop
	self:InsertTimer();	--获取NpcPart定时表建立定时表self.tbTimer
	if (MODULE_GC_SERVER) then
		self:OnEventTimeGC();--激活活动和关闭活动.启动定时器.
	end
	if (MODULE_GAMESERVER and bGmCmd ~= 1) then
		self:OnEventTimeGS();
	end

end

function Event:InsertDialog()
	for nPart, tbPart in pairs(self.tbEventPart) do 
		local tbPartDialog = tbPart:GetDialog(tbPart);
		if tbPartDialog ~= nil then
			--把对话插入tbDialog中.
			for nDialog, tbNpcDialog in ipairs(tbPartDialog) do
				local nNpcId 		= tbNpcDialog.nNpcId;
				local tbDialog 		= tbNpcDialog.tbDialog;
				local tbPartTime 	= tbNpcDialog.tbPartTime;
				if self.tbDialog[nNpcId] == nil then
					self.tbDialog[nNpcId] = {};
				end
				table.insert(self.tbDialog[nNpcId], 1, {tbDialog, tbPartTime});
			end
		end
		
	end
	
end

function Event:InsertTimer()
	for nPart, tbPart in pairs(self.tbEventPart) do 
		local tbPartTimer = tbPart:GetTimer(tbPart);
		if #tbPartTimer ~= 0 then
			for _, tbItem in ipairs(tbPartTimer) do
				table.insert(self.tbTimer, tbItem);
			end
		end	
	end
end

function Event:InsertNpcDrop()
	for nPart, tbPart in pairs(self.tbEventPart) do 
		local tbPartDropNpc = tbPart:GetNpcDrop(tbPart);
		if tbPartDropNpc ~= nil then
			
			for nDropNpc, tbNpcDrop in ipairs(tbPartDropNpc) do
				local nNpcId 	= tbNpcDrop.nNpcId;
				local szNpcName = tbNpcDrop.szNpcName;
				local tbDialog 	= tbNpcDrop.tbFun;
				local nStartDate= tbNpcDrop.nStartDate;
				local nEndDate 	= tbNpcDrop.nEndDate;
				local szNpcType = nil;
				if nNpcId then
					szNpcType = nNpcId;
				elseif szNpcName then
					szNpcType = szNpcName;
				end
				if szNpcType then
					if self.tbNpcDrop[szNpcType] == nil then
						self.tbNpcDrop[szNpcType] = {};
					end
					table.insert(self.tbNpcDrop[szNpcType], 1, tbNpcDrop);
				end
			end
		end	
	end
end
-----------GAMEGCSERVER 函数START-----
if (MODULE_GC_SERVER) then
	
--维护事件,24小时维护一次.
function Event:MaintainGC()
	self:CloseTimerGC();
	self:OnEventTimeGC(1);
end

function Event:CloseTimerGC()
	if self.tbTimerId == nil then
		return 1;
	end
	for nId, nTimerId in pairs(self.tbTimerId) do
		if nTimerId > 0 then
			if Timer:GetRestTime(nTimerId) > 0 then
				Timer:Close(nTimerId);
			end
		end
	end
	self.tbTimerId = {};
	return 0;		
end

--销毁,关闭事件
function Event:DestroyGC()
	GlobalExcute({"EventManager.Event:DestroyGS", self.tbEvent.nId});
	self.tbEvent.nStartDate = EventManager.EVENT_CLOSE_DATE;
	self:CloseTimerGC();
	self:CreateEvent();
end


function Event:OnEventTimeGC(nMaintain)
	--根据有效时间, 设置激活活动和关闭活动.启动定时器.
	--建立Npc对话
	--双倍开关
	--print("OnEventTime")
	if self.tbEvent.nStartDate == EventManager.EVENT_CLOSE_DATE then	--关闭该活动;
		self:OnTimeEndGC(0);
		return 1;
	end
	local nNowSec  	= GetTime();
	local nNowDate 	= tonumber(os.date("%Y%m%d%H%M", nNowSec));
	local nStartSec = Lib:GetDate2Time(self.tbEvent.nStartDate);
	local nEndSec 	= Lib:GetDate2Time(self.tbEvent.nEndDate);	
	
	--by jiazhenwei 启动的时候判定下时间轴是否满足，不满足return			
	local nFlag , nTimer = self:CheckTime(self.tbEvent.szTimeFrame);	
	if nFlag == 1 then 		--活动不满足时间轴，还没开启	
		if nTimer > 0 then	
			Timer:Register((nTimer + 5) * Env.GAME_FPS, self.EventStartGC, self, nMaintain);		--时间加5秒防止临界值有冲突
		else
			return 1;
		end
	elseif nFlag == 2 then				--活动不满足时间轴，已经结束
		self:OnTimeEndGC(0);
		return 1;
	elseif nFlag == 0  then	--活动满足时间轴		
		if nTimer > 0 then
			Timer:Register(nTimer * Env.GAME_FPS, self.OnTimeEndGC, self, 0);
		end	
	end
	--end
	
	--再次维护如果已经开启了的活动不再重新开启(开始后已经过了10秒认为已经开启);
	if (nMaintain == 1 and (nNowSec >= nStartSec + 10) and ( nNowSec < nEndSec or self.tbEvent.nEndDate == 0)) then
		self:OnPartTimerEndGC();
		self:OnPartTimerStartGC(nMaintain); --开启
	elseif (nNowSec >= nStartSec) and ( nNowSec < nEndSec or self.tbEvent.nEndDate == 0) then
		--执行开启
		self:OnTimeStartGC(0);
	end
	
	if nStartSec > nNowSec then
		--活动还没开始, 设置定时器.
		--离活动开始还有24小时内, 启动开始定时器.
		if nStartSec - nNowSec < EventManager.TIME_MAX_MAINTAIN then
			local nTimer = (nStartSec - nNowSec) * Env.GAME_FPS;
			if nTimer > 0 then
				local nTimerIdNo = #self.tbTimerId + 1;
				local nTimerId = Timer:Register(nTimer, self.OnTimeStartGC, self, nTimerIdNo);
				self.tbTimerId[nTimerIdNo] = nTimerId;
			end
		end
	end
	
	if nEndSec >= nNowSec then
		--活动还没结束, 设置定时器.
		--离活动结束还有24小时内, 设置定时器.
		if nEndSec == nNowSec then
			self:OnTimeEndGC();
		
		elseif nEndSec - nNowSec < EventManager.TIME_MAX_MAINTAIN then
			local nTimer = (nEndSec - nNowSec)* Env.GAME_FPS;
			if nTimer > 0 then
				local nTimerIdNo = #self.tbTimerId + 1;
				local nTimerId = Timer:Register(nTimer, self.OnTimeEndGC, self, nTimerIdNo);
				self.tbTimerId[nTimerIdNo] = nTimerId;
			end
		end
	end	
	return 0;
end

function Event:OnPartTimerEndGC()
	local nCurTime = GetTime();
	local nNTime = tonumber(os.date("%H%M", nCurTime))
	local nNSecond = tonumber(os.date("%S",nCurTime))
	for _, tbItem in pairs(self.tbTimer) do
		for _,tbTime in pairs(tbItem.tbEndTime) do
			local nTime = tonumber(tbTime.nTime);
			local tbFun = tbTime.tbFun;
			local nPartId = tbTime.nId;
			local nPartStartDate = tbTime.tbPartDate[1];
			local nPartEndDate = tbTime.tbPartDate[2];
			if nPartEndDate > 0 and nTime == EventManager.EVENT_TIMER_DATE_RSTART then
				local nEndSec	= Lib:GetDate2Time(nPartEndDate);
				if nCurTime < nEndSec and (nEndSec - nCurTime < EventManager.TIME_MAX_MAINTAIN) then
					nTime = tonumber(os.date("%H%M", nEndSec));
				end
			end
			if nTime ~= nil and nTime >= 0 then
				local nHour = math.floor(nTime/100);
				local nMin = nTime - nHour * 100;
				local nNHour = math.floor(nNTime/100);
				local nNMin = nNTime - nNHour * 100;
				if nTime <= nNTime then
					local nLastMin = (24 * 60 - (nNHour * 60 + nNMin)) + (nHour * 60 + nMin);
					local nLastSecond = (nLastMin * 60) - nNSecond;
					local nTimerIdNo = #self.tbTimerId + 1;
					local nTimerId = Timer:Register(nLastSecond * Env.GAME_FPS, self.DelTimerIdGC, self, tbFun, nPartId, nTimerIdNo);
					self.tbTimerId[nTimerIdNo] = nTimerId;
				else
					local nLastMin = (nHour * 60 + nMin) - (nNHour * 60 + nNMin);
					local nLastSecond = (nLastMin * 60) - nNSecond;
					local nTimerIdNo = #self.tbTimerId + 1;
					local nTimerId = Timer:Register(nLastSecond * Env.GAME_FPS, self.DelTimerIdGC, self, tbFun, nPartId, nTimerIdNo);
					self.tbTimerId[nTimerIdNo] = nTimerId;
				end
			end
		end
	end	
end

function Event:OnPartTimerStartGC(nMaintain)
	--开启
	local nCurTime = GetTime();
	local nNTime = tonumber(os.date("%H%M", nCurTime));
	local nNSecond = tonumber(os.date("%S",nCurTime));
	for _, tbItem in pairs(self.tbTimer) do
		for _,tbTime in pairs(tbItem.tbStartTime) do
			local nTime = tonumber(tbTime.nTime);
			local nPartStartDate = tbTime.tbPartDate[1];
			local nPartEndDate = tbTime.tbPartDate[2];
			local nPartId = tbTime.nId;
			local tbFun = tbTime.tbFun;
			
			if nTime == EventManager.EVENT_TIMER_DATE_RSTART then
				local nStartSec = Lib:GetDate2Time(nPartStartDate);
				local nEndSec	= Lib:GetDate2Time(nPartEndDate);
				if (nMaintain == 1 and (nCurTime >= nStartSec + 10) and ( nCurTime < nEndSec or nEndSec == 0)) then
					--不处理，已经开启了；不再重复开启
				elseif nCurTime >= nStartSec and (nCurTime < nEndSec or nEndSec == 0) then
					nTime = EventManager.EVENT_TIMER_DATE_START;
				elseif nCurTime < nStartSec and ((nStartSec - nCurTime) < EventManager.TIME_MAX_MAINTAIN) then
					nTime = tonumber(os.date("%H%M", nStartSec));
				end
			end
			if nTime ~= nil then
				if nTime == EventManager.EVENT_TIMER_DATE_START then
					self:DelTimerIdGC(tbFun, nPartId, 0);
				elseif nTime >= 0 then
					local nHour = math.floor(nTime/100);
					local nMin = nTime - nHour * 100;
					local nNHour = math.floor(nNTime/100);
					local nNMin = nNTime - nNHour * 100;
					if nTime <= nNTime then
						local nLastMin = (24 * 60 - (nNHour * 60 + nNMin)) + (nHour * 60 + nMin);
						local nLastSecond = (nLastMin * 60) - nNSecond;
						local nTimerIdNo = #self.tbTimerId + 1;
						local nTimerId = Timer:Register(nLastSecond * Env.GAME_FPS, self.DelTimerIdGC, self, tbFun, nPartId, nTimerIdNo);
						self.tbTimerId[nTimerIdNo] = nTimerId;
					else
						local nLastMin = (nHour * 60 + nMin) - (nNHour * 60 + nNMin);
						local nLastSecond = (nLastMin * 60) - nNSecond;
						local nTimerIdNo = #self.tbTimerId + 1;
						local nTimerId = Timer:Register(nLastSecond * Env.GAME_FPS, self.DelTimerIdGC, self, tbFun, nPartId, nTimerIdNo);
						self.tbTimerId[nTimerIdNo] = nTimerId;
					end
				end
			end
		end
	end
end

--定时启动
function Event:OnTimeStartGC(nSaveTimerIdNo)	
	--Npc对话开启
	GlobalExcute({"EventManager.Event:ExeDialog",self.tbEvent.nId});
	--计时器开启
	--to do
	local nCurTime = GetTime();
	local nNTime = tonumber(os.date("%H%M", nCurTime))
	local nNSecond = tonumber(os.date("%S",nCurTime))
	
	self:OnPartTimerEndGC();   --关闭
	self:OnPartTimerStartGC(); --开启

	
	--npc掉落
	for szNpcName, tbItem in pairs(self.tbNpcDrop) do
		for ni, tbNpcDrop in pairs(tbItem) do
			local szNpcName = tbNpcDrop.szNpcName;
			local nNpcId = tbNpcDrop.nNpcId;
			local tbFun 	= tbNpcDrop.tbFun;
			local nStartDate= tbNpcDrop.nStartDate;
			local nEndDate 	= tbNpcDrop.nEndDate;
			local nPartId	= tbNpcDrop.nId
			local nStartSec = Lib:GetDate2Time(nStartDate);
			local nEndSec 	= Lib:GetDate2Time(nEndDate);
			if nStartDate == 0 or (nStartSec <= nCurTime) then 
				self:DelTimerIdGC(tbFun, nPartId, 0);
			elseif (nStartSec > nCurTime) and (nStartSec - nCurTime) < EventManager.TIME_MAX_MAINTAIN then
				local nTimer = (nStartSec - nCurTime) * Env.GAME_FPS;
				if nTimer > 0 then
					local nTimerIdNo = #self.tbTimerId + 1;
					local nTimerId = Timer:Register(nTimer, self.DelTimerIdGC, self, tbFun, nPartId, nTimerIdNo);
					self.tbTimerId[nTimerIdNo] = nTimerId;
				end
			end
			
			--开启关闭函数交换
			local tbEndFun = {};
			Lib:MergeTable(tbEndFun, tbFun);
			tbEndFun[1], tbEndFun[2] = tbEndFun[2], tbEndFun[1];
			--关闭
			if nEndDate ~= 0 and nEndSec > nCurTime and (nEndSec - nCurTime) < EventManager.TIME_MAX_MAINTAIN then
				local nTimer = (nEndSec - nCurTime) * Env.GAME_FPS;
				if nTimer > 0 then
					local nTimerIdNo = #self.tbTimerId + 1;
					local nTimerId = Timer:Register(nTimer, self.DelTimerIdGC, self, tbEndFun, nPartId, nTimerIdNo);
					self.tbTimerId[nTimerIdNo] = nTimerId;
				end
			end
			
		end
	end
	
	
	if nSaveTimerIdNo > 0 then
		self.tbTimerId[nSaveTimerIdNo] = -1;
	end
	return 0;
end

function Event:OnTimeEndGC(nSaveTimerIdNo)
	--Npc对话关闭
	GlobalExcute({"EventManager.Event:ExeDelDialog",self.tbEvent.nId});
	--双倍关闭
	--to do
	--关闭
	local tbTimerTemp = {};
	for _, tbTime in pairs(self.tbTimer) do 
		for _, tbItem in pairs(tbTime.tbStartTime) do
			local szStartFun = tbItem.tbFun[1];	--关闭
			local szEndFun = tbItem.tbFun[2];
			local nPartId = tbItem.nId;
			local tbTimerFun = {szEndFun};
			if EventManager.tbFun:CheckTableEqual(tbTimerTemp, tbTimerFun) == 0 then
				tbTimerTemp[nPartId] = tbTimerFun;
			end
		end
	end
	
	for _, tbTime in pairs(self.tbTimer) do 
		for _, tbItem in pairs(tbTime.tbEndTime) do
			local szEndFun = tbItem.tbFun[1];	--关闭
			local nPartId = tbItem.nId;
			local tbTimerFun = {szEndFun, nPartId};
			if EventManager.tbFun:CheckTableEqual(tbTimerTemp, tbTimerFun) == 0 then
				tbTimerTemp[nPartId] = tbTimerFun;
			end
		end
	end
	
	for szNpcName, tbItem in pairs(self.tbNpcDrop) do
		for ni,tbNpcDrop in pairs(tbItem) do
			local szEndFun 	= tbNpcDrop.tbFun[2];	--关闭
			local nPartId 	= tbNpcDrop.nId;
			local tbTimerFun = {szEndFun, nPartId};
			if EventManager.tbFun:CheckTableEqual(tbTimerTemp, tbTimerFun) == 0 then
				tbTimerTemp[nPartId] = tbTimerFun;
			end
			
		end
	end		
	
	for nPartId, tbFun in pairs(tbTimerTemp) do
		self:DelTimerIdGC(tbFun, nPartId, nSaveTimerIdNo)
	end
	
	if nSaveTimerIdNo > 0 then
		self.tbTimerId[nSaveTimerIdNo] = -1;
	end
	self:CloseTimerGC();
	--大活动结束,停止并删除所有计时器
	return 0;
end

function Event:DelTimerIdGC(tbFun, nPartId, nTimerIdNo)
	local szExFun = tbFun[1][1];
	--print("类型：", tbFun[1][2], tbFun[1][3]);
	if szExFun then
		if tbFun[1][2] == nil then
			GlobalExcute({"EventManager.Event:ExeTimer",self.tbEvent.nId, nPartId ,tbFun[1], 1});
		elseif tbFun[1][2] == EventManager.KIND_CALLBOSS_GC then
			--print("调用CallNpcGC")
			self:CallNpcGC(nPartId ,tbFun[1]);
		end
	end
	if nTimerIdNo > 0 then
		self.tbTimerId[nTimerIdNo] = -1;
	end
	return 0
end

function Event:CallNpcGC(nPartId, tbFun)
	local nMapPath = tbFun[3];
	local tbMapInfo = EventManager.tbFun.CallNpcList[nMapPath];
	--print("CallNpcGCIn", szMapPath)
	if tbMapInfo == nil or tbMapInfo.tbNpc == nil then
		return 0;
	end
	for ni, tbNpc in ipairs(tbMapInfo.tbNpc) do
		if tbNpc.nRandRate == 0 then
			local tbMapFun = {tbFun[1]};
			tbMapFun[2] = {
					 nMapId 	= tbNpc.nMapId,
					 nPosX 		= tbNpc.nPosX,
					 nPosY 		= tbNpc.nPosY,
					 nNpcId 	= tbNpc.nNpcId,
					 nLevel 	= tbNpc.nLevel,
					 nSeries 	= tbNpc.nSeries,
					 szAnnouce 	= tbNpc.szAnnouce,
					 szName		= tbNpc.szName,
					 nRate		= tbNpc.nRandRate,				
				};
			
			GlobalExcute({"EventManager.Event:ExeTimer",self.tbEvent.nId, nPartId ,tbMapFun, 1});
		end
	end
	if tbMapInfo.nMaxProb > 0 then
		local nRate = MathRandom(1, tbMapInfo.nMaxProb);
		local nRateSum = 0;
		for ni, tbNpc in ipairs(tbMapInfo.tbNpc) do
			nRateSum = nRateSum + tbNpc.nRandRate;
			if nRate <= nRateSum then
				local tbMapFun = {tbFun[1]};
				tbMapFun[2] = {
						 nMapId 	= tbNpc.nMapId,
						 nPosX 		= tbNpc.nPosX,
						 nPosY 		= tbNpc.nPosY,
						 nNpcId 	= tbNpc.nNpcId,
						 nLevel 	= tbNpc.nLevel,
						 nSeries 	= tbNpc.nSeries,
						 nAnnouce 	= tbNpc.nAnnouce,
						 szName		= tbNpc.szName,
					}
				GlobalExcute({"EventManager.Event:ExeTimer",self.tbEvent.nId, nPartId ,tbMapFun, 1});		
				return 1;
			end
		end
	end
end

function Event:OnTimeDropNpcGC()
	
end

end
-----------GAMEGCSERVER 函数END-----

-----------GAMESERVER 函数Start-----
if (MODULE_GAMESERVER) then

function Event:OnEventTimeGS()
	--根据有效时间, 设置激活活动和关闭活动.启动定时器.
	--建立Npc对话
	--双倍开关
	if self.tbEvent.nStartDate == EventManager.EVENT_CLOSE_DATE then	--关闭该活动;
		self:OnTimeEndGS();
		return 1;
	end
	if self:CheckTimeFrame(self.tbEvent.szTimeFrame) == 1 then
		local nNowDate = tonumber(GetLocalDate("%Y%m%d%H%M"));
		if (nNowDate >= self.tbEvent.nStartDate) and ( nNowDate <= self.tbEvent.nEndDate or self.tbEvent.nEndDate == 0) then
			--执行
			self:OnTimeStartGS();
		end
	end
end

function Event:OnTimeStartGS()
	--Npc对话开启
	self:ExeDialog(self.tbEvent.nId);
	
	local nCurTime = GetTime();
	--计时器开启
	local nNTime = tonumber(os.date("%H%M",nCurTime))
	
	--开启
	for _, tbItem in pairs(self.tbTimer) do
		for _,tbTime in pairs(tbItem.tbStartTime) do
			local nTime = tonumber(tbTime.nTime);
			local nPartId = tbTime.nId;
			local tbFun = tbTime.tbFun;
			local nPartStartDate = tbTime.tbPartDate[1];
			local nPartEndDate = tbTime.tbPartDate[2];
						
			if nTime == EventManager.EVENT_TIMER_DATE_RSTART then
				local nStartSec = Lib:GetDate2Time(nPartStartDate);
				local nEndSec	= Lib:GetDate2Time(nPartEndDate);
				if nCurTime >= nStartSec and (nCurTime < nEndSec or nEndSec == 0) then
					nTime = EventManager.EVENT_TIMER_DATE_START;
				elseif nCurTime < nStartSec and ((nStartSec - nCurTime) < EventManager.TIME_MAX_MAINTAIN) then
					nTime = tonumber(os.date("%H%M", nStartSec));
				end
			end			
			
			if nTime ~= nil then
				if nTime == -1 then
					self:DelTimerIdGS(tbFun, nPartId);
				elseif nTime == nNTime then
						self:DelTimerIdGS(tbFun, nPartId);
				end
			end
		end
	end
	
--	--开启
--	local nNowDate = tonumber(os.date("%Y%m%d%H%M",nCurTime));
--	for szNpcName, tbItem in pairs(self.tbNpcDrop) do
--		for ni, tbNpcDrop in pairs(tbItem) do
--			local szNpcName = tbNpcDrop.szNpcName;
--			local tbFun 	= tbNpcDrop.tbFun;
--			local nStartDate= tbNpcDrop.nStartDate;
--			local nEndDate 	= tbNpcDrop.nEndDate;
--			local nPartId	= tbNpcDrop.nId
--			if nStartDate == 0 or (nNowDate >= nStartDate and (nNowDate < nEndDate or nEndDate == 0)) then
--				self:DelTimerIdGS(tbFun, nPartId);
--			end
--		end
--	end	
	
	return 0;
end

--定时关闭
function Event:OnTimeEndGS()
	--Npc对话关闭
	self:ExeDelDialog(self.tbEvent.nId);
	return 0;
end

function Event:DelTimerIdGS(tbFun, nPartId)
	local szExFun = tbFun[1][1];
	--print("类型：", tbFun[1][2], tbFun[1][3]);
	if szExFun then
		if tbFun[1][2] == nil then
			self:ExeTimer(self.tbEvent.nId, nPartId, tbFun[1]);
		--elseif tbFun[1][2] == EventManager.KIND_CALLBOSS_GC then
			--print("调用CallNpcGC")
			--self:CallNpcGC(nPartId ,tbFun[1]);
		end
	end
	return 0
end

function Event:ExeTimer(nEventId, nPartId, tbFun, bGCFlag)
	if not EventManager.EventManager.tbEvent[nEventId].tbEventPart or not EventManager.EventManager.tbEvent[nEventId].tbEventPart[nPartId] then
		return 0;
	end
	local szSelfFun = EventManager.EventManager.tbEvent[nEventId].tbEventPart[nPartId].tbEventKind;
	local szFun = EventManager.EventManager.tbEvent[nEventId].tbEventPart[nPartId].tbEventKind[tbFun[1]];
	local tbParam = {};
	for ni, szParam in ipairs(tbFun) do
		if ni ~= 1 then
			table.insert(tbParam, szParam);
		end
	end
	if szFun then
		szFun(szSelfFun, tbParam, bGCFlag);
	end
end

function Event:ExeDialog(nEventId)
	local tbEvent = EventManager.EventManager.tbEvent[nEventId];
	for varNpc, tbNpcDialogParam in pairs(tbEvent.tbDialog) do
		local nEffectCount, tbTimeTable = self:CheckEffectDialog(nEventId, varNpc);
		if  nEffectCount > 0 then
			local tbNpc = EventManager:GetNpcClass(varNpc, 1);
			local tbDialog = {};
			Lib:MergeTable(tbDialog, tbNpc.tbEventDialog);
			local tbNewDialog = {tbEvent.tbEvent.szName, tbEvent.OnDialog, tbEvent, varNpc, tbTimeTable};
			EventManager.tbFun:InsertDialog(tbDialog, tbNewDialog, 1);
			EventManager.tbFun:InsertDialog(tbDialog, {EventManager.DIALOG_CLOSE}, 0);
			tbNpc.tbEventDialog = tbDialog;
		end
	end			
end

--检查对话是否已经失效
function Event:CheckEffectDialog(nEventId, varNpc)
	local tbEvent = EventManager.EventManager.tbEvent[nEventId];
	
	local nSec = GetTime();
	local nEffectCount = 0; 
	local tbTimeTable = {};
	for _, tbNpcDialog in pairs(tbEvent.tbDialog[varNpc]) do
		local tbPartTime = tbNpcDialog[2];
		if tbPartTime[1] == 0 or (tbPartTime[2] == 0 or nSec < Lib:GetDate2Time(tbPartTime[2])) then
			nEffectCount = nEffectCount + 1;
			table.insert(tbTimeTable, {Lib:GetDate2Time(tbPartTime[1]), Lib:GetDate2Time(tbPartTime[2])});
		end
	end
	if nEffectCount == 0 then
		self:ExeDelDialogNpc(nEventId, varNpc)
	end
	
	return nEffectCount, tbTimeTable;
end

function Event:ExeDelDialog(nEventId)
	local tbEvent = EventManager.EventManager.tbEvent[nEventId];
	for varNpc, tbNpcDialogParam in pairs(tbEvent.tbDialog) do
		Event:ExeDelDialogNpc(nEventId, varNpc)
	end		
end

function Event:ExeDelDialogNpc(nEventId, varNpc)
	local tbEvent = EventManager.EventManager.tbEvent[nEventId];
	local tbNpc = EventManager:GetNpcClass(varNpc, 1);
	--local tbNpc = Npc:GetClass(szNpcName);
	local tbNewDialog = {tbEvent.tbEvent.szName, tbEvent.OnDialog, tbEvent, nNpcId};
	if tbNpc.tbEventDialog ~= nil or #tbNpc.tbEventDialog ~= 0 then
		local tbDialog = {};
		Lib:MergeTable(tbDialog, tbNpc.tbEventDialog);
		EventManager.tbFun:DelDialog(tbDialog, tbNewDialog);
		tbNpc.tbEventDialog = tbDialog;
	end	
end

--对话
function Event:OnDialog(nNpcId, tbTimeTable)
	local tbDialog = {};
	local nSec = GetTime();
	for nDialog, tbNpcDialogParam in pairs(self.tbDialog[nNpcId]) do
		local tbNpcDialog = tbNpcDialogParam[1];
		local tbPartTime = tbNpcDialogParam[2];
		if tbPartTime[2] == 0 or (nSec >= Lib:GetDate2Time(tbPartTime[1]) and nSec < Lib:GetDate2Time(tbPartTime[2])) then
			EventManager.tbFun:InsertDialog(tbDialog, tbNpcDialog, 1, 1);
		end
	end
	EventManager.tbFun:InsertDialog(tbDialog, {EventManager.DIALOG_CLOSE}, 0);
	Dialog:Say(EventManager.tbFun:StrVal(self.tbEvent.szDescript), tbDialog);
end

function Event:DestroyGS(nEventId)
	local tbClassEvent = EventManager.EventManager.tbEvent[nEventId];
	tbClassEvent.tbEvent.nStartDate = EventManager.EVENT_CLOSE_DATE;
	tbClassEvent:CreateEvent();
	tbClassEvent:OnEventTimeGS();
end

end

function Event:EventStartGC(nMaintain)
	self:OnEventTimeGC(nMaintain);
	return 0;
end

function Event:CheckTimeFrame(szTimeFrame)
	if szTimeFrame == "" or szTimeFrame == nil then
		return 1;
	end
	local tb = Lib:SplitStr(szTimeFrame, "/");
	local tbData1 = Lib:SplitStr(tb[1], ":");
	local tbData2 = Lib:SplitStr(tb[2], ":");
	if tonumber(tbData1[1]) ~= 0 and self:CheckTimeFrameEx(tb[1]) == 1 then
		return 0;
	elseif tonumber(tbData2[1]) ~= 0 and self:CheckTimeFrameEx(tb[2]) == 0 then
		return 0;
	end
	return 1;
end

--时间轴要求的时间比现在的时间比较，比现在时间长返回1，否则返回0
function Event:CheckTimeFrameEx(szData)
	local tbData = Lib:SplitStr(szData, ":");
	local nStartSever = tonumber(KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME));
	local nNowDate = GetTime();	
	if nNowDate - nStartSever < (tonumber(tbData[1]) - 1) * 3600 *24 + tonumber(tbData[2])/100 * 3600 then
		return 1;
	end
	return 0;
end

function Event:CheckTime(szData)
	if szData == "" or szData == nil then
		return 0,0;
	end
	local tb = Lib:SplitStr(szData, "/");
	local tbData1 = Lib:SplitStr(tb[1], ":");
	local tbData2 = Lib:SplitStr(tb[2], ":");
	local nStartSever = tonumber(KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME));
	local nNowDate = GetTime();
	local nTime1 = 0;
	local nTime2 = 0;
	if tonumber(tbData1[1]) ~= 0 and self:CheckTimeFrameEx(tb[1]) == 1 then
		nTime1 =  nStartSever + (tonumber(tbData1[1]) - 1) * 86400 + tonumber(tbData1[2])/100 * 3600  - nNowDate;		
		if nTime1 < EventManager.TIME_MAX_MAINTAIN then
			return 1, nTime1;
		end
		return 1, 0;
	elseif tonumber(tbData2[1]) ~= 0 and self:CheckTimeFrameEx(tb[2]) == 0 then
		return 2, 0;
	end
	if tonumber(tbData2[1]) == 0 then
		return 0, 0;
	end
	nTime2 = nStartSever + (tonumber(tbData2[1]) - 1) * 86400 + tonumber(tbData2[2])/100 * 3600  - nNowDate;
	if nTime2 < EventManager.TIME_MAX_MAINTAIN then
		return 0, nTime2;
	end
	return 0, 0;	
end

-----------GAMESERVER 函数end-----
