-------------------------------------------------------
-- 文件名　 : superbattle_gc.lua
-- 创建者　 : zhangjinpin@kingsoft
-- 创建时间 : 2011-06-02 15:31:01
-- 文件描述 :
-------------------------------------------------------

if not MODULE_GC_SERVER then
	return 0;
end

Require("\\script\\globalserverbattle\\superbattle\\superbattle_def.lua");

-------------------------------------------------------
-- 启动相关
-------------------------------------------------------

-- 中心服启动报名
function SuperBattle:StartSignup_GA()
	
	-- global only
	if self:CheckIsOpen() ~= 1 or self:CheckIsGlobal() ~= 1 then
		return 0;
	end
	
	-- daily period
	if self:GetDailyPeriod() < 1 then
		return 0;
	end
	
	-- 避免重复开
	if self:CheckIsSignup() == 1 then
		return 0;
	end
	
	-- 初始化表
	self.tbPlayerQueue_GA = {};
	self.tbPlayerGame_GA = {};
	self.tbPlayerData_GA = {};
	self.tbMissionList_GA = {};
	self.nLastGameTime = GetTime();
	
	-- 大区公告
	self:GlobalAnnounce_GA("Liên Server: <color=green>Hồi Mộng Thái Thạch Cơ<color> đã mở, giang hồ lần nữa lại dậy sóng!");
	
	-- 启动计时器
	self:StartTimer(self.DEAMON_TIME, self.TimerDeamon_GA, "deamon");
	
	-- 开启标记
	SetGlobalSportTask(self.GA_DBTASK_GID, self.GA_DBTASK_SIGNUP, 1);
end

-- 中心服停止报名
function SuperBattle:StopSignup_GA()
	
	-- global only
	if self:CheckIsOpen() ~= 1 or self:CheckIsGlobal() ~= 1 then
		return 0;
	end
	
	-- daily period
	if self:GetDailyPeriod() < 1 then
		return 0;
	end
	
	-- 关闭计时器
	for szType, _ in pairs(self.tbTimerId) do
		self:ClearTimer(szType);
	end
	
	-- 大区公告
	self:GlobalAnnounce_GA("Liên Server: <color=green>Hồi Mộng Thái Thạch Cơ<color> đã ngừng đăng ký!");
	
	-- 关闭标记
	SetGlobalSportTask(self.GA_DBTASK_GID, self.GA_DBTASK_SIGNUP, 0);
	
	-- 队列清0
	SetGlobalSportTask(self.GA_DBTASK_GID, self.GA_DBTASK_QUEUE, 0);
end

-------------------------------------------------------
-- 排队相关
-------------------------------------------------------

-- 守护计时器
function SuperBattle:TimerDeamon_GA()
	return self:Deamon_GA();
end

-- 守护函数，便于重载
function SuperBattle:Deamon_GA()
	
	-- global only
	if self:CheckIsOpen() ~= 1 or self:CheckIsGlobal() ~= 1 then
		return 0;
	end
	
	self._nAnn = (self._nAnn or 0) + 1;
	if self._nAnn > self.MAX_OVERFLOW then
		self._nAnn = 0;
	end
	
	if math.mod(self._nAnn, 60) == 1 then 
		self:GlobalAnnounce_GA("Liên Server: <color=green>Hồi Mộng Thái Thạch Cơ<color> đã mở, quý nhân sỹ đã báo danh hãy nhanh chân tham chiến.");
	end
	
	-- 过了报名期
	if self:CheckIsSignup() ~= 1 then
		for _, tbInfo in pairs(self.tbPlayerQueue_GA) do
			self:SendMessage_GA(tbInfo.szName, self.MSG_BOTTOM, "Xin lỗi, thời gian đăng ký đã hết. Hãy quay lại vào lần sau!");
		end
		return 0;
	end
	
	-- 判断是否能开一场
	local nQueueLength = 0;
	if #self.tbPlayerQueue_GA >= self.MAX_QUEUE then
		nQueueLength = self.MAX_QUEUE;
	elseif #self.tbPlayerQueue_GA >= self.MIN_QUEUE and GetTime() - self.nLastGameTime >= self.GAME_WAITING then
		nQueueLength = #self.tbPlayerQueue_GA;
	else
		-- 通知本服
		SetGlobalSportTask(self.GA_DBTASK_GID, self.GA_DBTASK_QUEUE, #self.tbPlayerQueue_GA);
		return self.DEAMON_TIME;
	end
	
	-- 生成一组成员
	local tbGroup = {};
	for i = 1, nQueueLength do
		tbGroup[i] = self.tbPlayerQueue_GA[i];
	end
	
	-- 找一个未分配的gs
	local nServerId = 0;
	for i = 1, GCEvent.SERVER_COUNT do 
		if self.tbMissionList_GA[i] ~= 1 then
			nServerId = i;
			break;
		end
	end

	-- 召唤gs启动游戏
	if nServerId ~= 0 then
		
		-- 战斗力排序
		table.sort(tbGroup, function(a, b) return a.nPower > b.nPower end);
		
		-- 标记分组
		local nLen = 1;
		while (nLen + 1 <= #tbGroup) do
			tbGroup[nLen].nCamp = 1;
			tbGroup[nLen + 1].nCamp = 2;
			nLen = nLen + 2;
		end
		if #tbGroup == nLen then
			tbGroup[#tbGroup].nCamp = 1;
		end
		
		-- 召唤gs启动
		GlobalExcute({"SuperBattle:StartGame_GS", nServerId});
		
		-- gc标记
		self.tbMissionList_GA[nServerId] = 1;
		self.nLastGameTime = GetTime();
		self.tbPlayerGame_GA[nServerId] = {};
		self.tbPlayerGame_GA[nServerId].nFlag = 1;
		self.tbPlayerGame_GA[nServerId].tbGroup = tbGroup;
		
		-- 移除排队
		for i = 1, nQueueLength do
			table.remove(self.tbPlayerQueue_GA, 1);
		end
	end
	
	return self.DEAMON_TIME;
end

-- 开启失败
function SuperBattle:StartGameFailed_GA(nServerId)
	
	if not self.tbPlayerGame_GA[nServerId] then
		return 0;
	end
	
	-- 这组玩家重新排队
	local tbGroup = self.tbPlayerGame_GA[nServerId].tbGroup;
	for _, tbInfo in pairs(tbGroup) do
		self:AddPlayerQueue_GA(tbInfo.szName, tbInfo.nPower);
	end
	
	-- 清出游戏表
	self.tbPlayerGame_GA[nServerId] = nil;
end

-- 成功开启一场
function SuperBattle:StartGameSuccess_GA(nServerId)
	
	if not self.tbPlayerGame_GA[nServerId] then
		return 0;
	end
	
	-- 生成玩家数据
	local tbGroup = self.tbPlayerGame_GA[nServerId].tbGroup;
	for _, tbInfo in pairs(tbGroup) do
		self.tbPlayerData_GA[tbInfo.szName] = {nServerId = nServerId, nCamp = tbInfo.nCamp, nPower = tbInfo.nPower};
		GC_AllExcute({"SuperBattle:StartGameSuccess_GC", tbInfo.szName});
	end
	
	-- 同步数据
	self:SyncTable_GA("tbMissionPlayer", self.tbPlayerGame_GA[nServerId].tbGroup, nServerId);
	
	-- 流水号+1
	SetGlobalSportTask(self.GA_DBTASK_GID, self.GA_DBTASK_SESSION, self:GetSession() + 1);
end

-- 通知本服
function SuperBattle:StartGameSuccess_GC(szPlayerName)
	GlobalExcute({"SuperBattle:StartGameSuccess_GS", szPlayerName});
end

-- 停止游戏成功
function SuperBattle:StopGameSuccess_GA(nServerId)
	self.tbMissionList_GA[nServerId] = 0;
	local tbGroup = self.tbPlayerGame_GA[nServerId].tbGroup;
	for _, tbInfo in pairs(tbGroup) do
		self.tbPlayerData_GA[tbInfo.szName] = nil;
	end
	self.tbPlayerGame_GA[nServerId] = nil;
	self:SaveBuffer_GC();
end

-- 增加玩家
function SuperBattle:AddPlayerQueue_GA(szPlayerName, nFightPower)
	for i, tbInfo in pairs(self.tbPlayerQueue_GA) do
		if tbInfo.szName == szPlayerName then
			return 0;
		end
	end
	table.insert(self.tbPlayerQueue_GA, {szName = szPlayerName, nPower = nFightPower});
end

-- 移除玩家
function SuperBattle:RemovePlayerQueue_GA(szPlayerName)
	for i, tbInfo in pairs(self.tbPlayerQueue_GA) do
		if tbInfo.szName == szPlayerName then
			table.remove(self.tbPlayerQueue_GA, i);
		end
	end
end

-- 查找玩家
function SuperBattle:FindPlayerQueue_GA(szPlayerName)
	for i, tbInfo in pairs(self.tbPlayerQueue_GA) do
		if tbInfo.szName == szPlayerName then
			return i;
		end
	end
	return 0;
end

-- 本服GC报名
function SuperBattle:SignupBattle_GC(szPlayerName, nFightPower)
	GC_AllExcute({"SuperBattle:SignupBattle_GA", szPlayerName, nFightPower});
end

-- 中心服GC报名
function SuperBattle:SignupBattle_GA(szPlayerName, nFightPower)
	if self.tbPlayerData_GA[szPlayerName] then
		GC_AllExcute({"SuperBattle:SignupBattleFailed_GC", szPlayerName, 1});
		return 0;
	end
	if self:FindPlayerQueue_GA(szPlayerName) == 0 then
		self:AddPlayerQueue_GA(szPlayerName, nFightPower);
		GC_AllExcute({"SuperBattle:SignupBattleSuccess_GC", szPlayerName});
	else
		GC_AllExcute({"SuperBattle:SignupBattleFailed_GC", szPlayerName, 2});
	end
end

-- 报名成功
function SuperBattle:SignupBattleSuccess_GC(szPlayerName)
	GlobalExcute({"SuperBattle:SignupBattleSuccess_GS", szPlayerName});
end

-- 报名失败
function SuperBattle:SignupBattleFailed_GC(szPlayerName, nType)
	GlobalExcute({"SuperBattle:SignupBattleFailed_GS", szPlayerName, nType});
end

-- 本服GC取消报名
function SuperBattle:CancelSignup_GC(szPlayerName)
	GC_AllExcute({"SuperBattle:CancelSignup_GA", szPlayerName});
end

-- 中心服GC取消报名
function SuperBattle:CancelSignup_GA(szPlayerName)
	if self.tbPlayerData_GA[szPlayerName] then
		GC_AllExcute({"SuperBattle:CancelSignupFailed_GC", szPlayerName, 1});
	elseif self:FindPlayerQueue_GA(szPlayerName) == 0 then
		GC_AllExcute({"SuperBattle:CancelSignupFailed_GC", szPlayerName, 2});
	else
		self:RemovePlayerQueue_GA(szPlayerName);
		GC_AllExcute({"SuperBattle:CancelSignupSuccess_GC", szPlayerName});
	end
end

-- 取消报名成功
function SuperBattle:CancelSignupSuccess_GC(szPlayerName)
	GlobalExcute({"SuperBattle:CancelSignupSuccess_GS", szPlayerName});
end

-- 取消报名失败
function SuperBattle:CancelSignupFailed_GC(szPlayerName, nType)
	GlobalExcute({"SuperBattle:CancelSignupFailed_GS", szPlayerName, nType});
end

-- 打开选择界面
function SuperBattle:SelectState_GC(szPlayerName, nOnlyApplyState)
	GC_AllExcute({"SuperBattle:SelectState_GA", szPlayerName, nOnlyApplyState});
end

function SuperBattle:SelectState_GA(szPlayerName, nOnlyApplyState)
	if self.tbPlayerData_GA[szPlayerName] then
		GC_AllExcute({"SuperBattle:SelectStateResult_GC", szPlayerName, 3, nOnlyApplyState});
	elseif self:FindPlayerQueue_GA(szPlayerName) > 0 then
		GC_AllExcute({"SuperBattle:SelectStateResult_GC", szPlayerName, 2, nOnlyApplyState});
	else
		GC_AllExcute({"SuperBattle:SelectStateResult_GC", szPlayerName, 1, nOnlyApplyState});
	end
end

function SuperBattle:SelectStateResult_GC(szPlayerName, nType, nOnlyApplyState)
	GlobalExcute({"SuperBattle:SelectStateResult_GS", szPlayerName, nType, nOnlyApplyState});
end

-- 中心服进入战场
function SuperBattle:EnterBattle_GA(szPlayerName)
	local tbInfo = self.tbPlayerData_GA[szPlayerName];
	if tbInfo then
		GlobalExcute({"SuperBattle:EnterBattleSuccess_GS", szPlayerName, tbInfo});
	else
		GlobalExcute({"SuperBattle:EnterBattleFailed_GS", szPlayerName});
	end
end

-- 设置结果
function SuperBattle:SetPlayerResult_GA(szPlayerName, nPoint, nSort, nRst, nExp, szGateway, nRepute)
	local nId = KGCPlayer.GetPlayerIdByName(szPlayerName);
	if nId then
		-- 积分
		SetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_POINT, nPoint);
		-- 排名
		SetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_SORT, nSort);
		-- 经验
		local nOwnExp = GetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_EXP) or 0;
		SetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_EXP, nOwnExp + nExp);
		-- 威望
		SetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_REPUTE, nRepute);
		-- 换周了，清掉之前的记录
		local nWeek = GetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_WEEK) or 0;
		if self:GetWeek() > nWeek then
			for _, nTask in ipairs(self.GA_TASK_RST) do
				SetPlayerSportTask(nId, self.GA_TASK_GID, nTask, 0);
			end
			SetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_WEEK, self:GetWeek());
			if nRst > 0 then
				local nOwnBox = GetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_BOX) or 0;
				SetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_BOX, nOwnBox + self.BASE_BOX);
			end
		end
		-- 排行点
		local nTag = 0;
		local nMinTask, nMinRst = self:GetMinRst(nId);
		if nRst > nMinRst then
			nTag = nRst - nMinRst;
			SetPlayerSportTask(nId, self.GA_TASK_GID, nMinTask, nRst);
		end
		-- 更新gpa
		local nGpa = 0;
		for _, nTask in ipairs(self.GA_TASK_RST) do
			nGpa = nGpa + GetPlayerSportTask(nId, self.GA_TASK_GID, nTask) or 0;
		end
		SetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_GPA, nGpa);
		-- 计算箱子
		if nTag > 0 then
			local nBox = self:CalcPlayerAward(nTag);
			local nOwnBox = GetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_BOX) or 0;
			SetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_BOX, nOwnBox + nBox);
		end
		-- 更新排行榜
		self:UpdateBuffer_GC(szPlayerName, nGpa, szGateway);
	end
end

-- 设置奖励
function SuperBattle:UpdatePlayerAward_GA()
	
	-- global only
	if self:CheckIsOpen() ~= 1 or self:CheckIsGlobal() ~= 1 then
		return 0;
	end
	
	-- daily period
	if self:GetDailyPeriod() < 2 then
		return 0;
	end
	
	-- update
	for i, tbInfo in ipairs(self.tbGlobalBuffer) do
		local nBox = self:CalcPlayerAwardEx(i, #self.tbGlobalBuffer);
		local nId = KGCPlayer.GetPlayerIdByName(tbInfo[1]);
		if nId then
			local nOwnBox = GetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_BOX) or 0;
			SetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_BOX, nOwnBox + nBox);
			if i <= self.MAX_MANTLE or tbInfo[2] >= 450 then
				SetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_MANTLE, 1);
			end
			nBox = nBox + nOwnBox;
			-- 上周积分、排名
			SetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_LAST_GPA, tbInfo[2]);
			SetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_LAST_SORT, i);
		end
		SuperBattle:StatLog("week_award", nId, self:GetWeek(), i, tbInfo[2], nBox);
	end
	
	-- week number
	SetGlobalSportTask(self.GA_DBTASK_GID, self.GA_DBTASK_WEEK, self:GetWeek() + 1);
	self:ClearBuffer_GC();
end

-- gc获取buffer
function SuperBattle:GetMantleBuffer_GC(szPlayerName)
	GC_AllExcute({"SuperBattle:GetMantleBuffer_GA", szPlayerName});
end

-- ga设置buffer
function SuperBattle:GetMantleBuffer_GA(szPlayerName)
	local nId = KGCPlayer.GetPlayerIdByName(szPlayerName);
	if nId then
		SetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_MANTLE, 0);
	end
end

-- gc完成任务
function SuperBattle:FinishTask_GC(szPlayerName, nType)
	GC_AllExcute({"SuperBattle:FinishTask_GA", szPlayerName, nType});
end

-- ga完成任务
function SuperBattle:FinishTask_GA(szPlayerName, nType)
	local tbTask = {self.GA_TASK_TASK1, self.GA_TASK_TASK2};
	local nId = KGCPlayer.GetPlayerIdByName(szPlayerName);
	if nId and tbTask[nType] then
		SetPlayerSportTask(nId, self.GA_TASK_GID, tbTask[nType], 0);
	end
end

-------------------------------------------------------
-- 系统相关
-------------------------------------------------------

-- 中心服名字广播
function SuperBattle:SendMessage_GA(szPlayerName, nType, szMsg)
	GC_AllExcute({"SuperBattle:SendMessage_GC", szPlayerName, nType, szMsg});
end

-- 本地服名字广播
function SuperBattle:SendMessage_GC(szPlayerName, nType, szMsg)
	GlobalExcute({"SuperBattle:SendMessage_GS", szPlayerName, nType, szMsg});
end

-- 全大区广播
function SuperBattle:GlobalAnnounce_GA(szMsg)
	Dialog:GlobalNewsMsg_Center(szMsg);
	Dialog:GlobalMsg2SubWorld_Center(szMsg);
end

-- 同步一个table
function SuperBattle:SyncTable_GA(szT, tbT, nServerId)
	for k, v in pairs(tbT) do
		GlobalExcute({"SuperBattle:SyncTable_GS", szT, k, v, nServerId});
	end
end

-------------------------------------------------------
-- buffer
-------------------------------------------------------

-- load
function SuperBattle:LoadBuffer_GC()
	local tbLoadBuffer = GetGblIntBuf(self.nBufferIndex, 0);
	if tbLoadBuffer and type(tbLoadBuffer) == "table" then
		self.tbGlobalBuffer = tbLoadBuffer;
	end
end

-- save
function SuperBattle:SaveBuffer_GC()
	SetGblIntBuf(self.nBufferIndex, 0, 1, self.tbGlobalBuffer);
	GlobalExcute({"SuperBattle:LoadBuffer_GS"});
end

-- clear
function SuperBattle:ClearBuffer_GC()
	self.tbGlobalBuffer = {};
	SetGblIntBuf(self.nBufferIndex, 0, 1, {});
	GlobalExcute({"SuperBattle:ClearBuffer_GS"});
end

-- sort
function SuperBattle:UpdateBuffer_GC(szPlayerName, nPoint, szGateway)
	
	if #self.tbGlobalBuffer == 0 then
		table.insert(self.tbGlobalBuffer, {szPlayerName, nPoint, szGateway});
	else
		for i, tbInfo in pairs(self.tbGlobalBuffer) do
			if tbInfo[1] == szPlayerName then
				if nPoint == tbInfo[2] then
					return 0;
				else
					table.remove(self.tbGlobalBuffer, i);
				end
			end
		end
		local nIns = 0;
		for i = 1, #self.tbGlobalBuffer do
			if self.tbGlobalBuffer[i][2] < nPoint then
				table.insert(self.tbGlobalBuffer, i, {szPlayerName, nPoint, szGateway});
				nIns = i;
				break;
			end
		end
		if nIns == 0 then
			table.insert(self.tbGlobalBuffer, {szPlayerName, nPoint, szGateway});
		end
	end
	for i = self.MAX_BUFFER_LEN + 1, #self.tbGlobalBuffer do
		self.tbGlobalBuffer[i] = nil;
	end
end

-- 启动事件
function SuperBattle:StartEvent_GC()
	if self:CheckIsGlobal() ~= 1 then
		return 0;
	end
	self:LoadBuffer_GC();
	SetGlobalSportTask(self.GA_DBTASK_GID, self.GA_DBTASK_SIGNUP, 0);
	SetGlobalSportTask(self.GA_DBTASK_GID, self.GA_DBTASK_QUEUE, 0);
end

-- 注册gamecenter启动事件
GCEvent:RegisterGCServerStartFunc(SuperBattle.StartEvent_GC, SuperBattle);

SuperBattle.tbPlayerQueue_GA = SuperBattle.tbPlayerQueue_GA or {};
SuperBattle.tbPlayerGame_GA = SuperBattle.tbPlayerGame_GA or {};
SuperBattle.tbPlayerData_GA = SuperBattle.tbPlayerData_GA or {};
SuperBattle.tbMissionList_GA = SuperBattle.tbMissionList_GA or {};
