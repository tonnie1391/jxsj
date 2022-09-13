
-- ====================== 文件信息 ======================

-- 剑侠世界随机任务处理头文件
-- Edited by peres
-- 2007/04/03 PM 19:51

-- 后来又笑自己的狷介。
-- 每个人有自己的宿命，一切又与他人何干。
-- 太多人太多事，只是我们的借口和理由。

-- ======================================================
 
RandomTask.TSKG_ID = 2;         -- 随机任务的任务变量组分配

RandomTask.LIMIT_NUM = 10;  -- 每个玩家每天随机任务的上限
RandomTask.CHECKTIME     = 6000; -- 多少秒触发一次随机任务判断点
RandomTask.TASKRATE      = 100;  -- 每次触发点有百分之几的概率可获得随机任务

-- 各个主任务的 ID，编辑器生成
RandomTask.nMainTaskId = {
		[1] = tonumber("63", 16),
		[2] = tonumber("64", 16),
	}

-- 各种任务类型的表格
-- 1 为杀怪
-- 2 为收集物品
RandomTask.tbTaskType = {[1]={}, [2]={}};

-- 随机任务第一层卷轴的物品 ID
RandomTask.tbItemId = {18,1,6};

RandomTask.TSK_NUM       = 1;  -- 记录今天已经领了多少次任务
RandomTask.TSK_DATE      = 2;  -- 记录领取的天数


-- 随机任务类初始化
function RandomTask:OnInit()
	self.tbfile_TaskLevelGroup     = Lib:NewClass(Lib.readTabFile);
	self.tbfile_TaskType           = Lib:NewClass(Lib.readTabFile);
	self.tbfile_EntityKillNpc      = Lib:NewClass(Lib.readTabFile);
	self.tbfile_EntityFindItem     = Lib:NewClass(Lib.readTabFile);	
	self.tbfile_EntityTaskBook     = Lib:NewClass(Lib.readTabFile);
		
	self:_Debug("Start load tabfile!");
	
	self.tbfile_TaskLevelGroup:OnInit("\\setting\\task\\random\\level_group.txt");
	self.tbfile_TaskType:OnInit("\\setting\\task\\random\\type_select.txt");

	self.tbfile_EntityKillNpc:OnInit("\\setting\\task\\random\\entity_killnpc.txt");
	self.tbfile_EntityFindItem:OnInit("\\setting\\task\\random\\entity_finditem.txt");

	self.tbTaskType[1] = self.tbfile_EntityKillNpc;
	self.tbTaskType[2] = self.tbfile_EntityFindItem;

end


-- 随机任务的触发点
function RandomTask:OnStart()
	self:_Debug("Start random task check point!");
	local nRandom = 0;
		nRandom = MathRandom(1,100);
		if nRandom <= self.TASKRATE then
			-- self:GiveTask();
			-- 临时关掉随机任务
			return;
		end
end


-- 选择等级段
function RandomTask:SelectLevelGroup()
	local nLevel = me.nLevel; --GetLevel();
	local nTabLevel = 0;
	local nGroup = 0;
	
	local nRow = self.tbfile_TaskLevelGroup:GetRow();
	local i=0;
	
	self:_Debug("Get the level group file row: "..nRow);
	
	for i=1, nRow do
		nTabLevel = self.tbfile_TaskLevelGroup:GetCellInt("Level", i);
		nGroup    = self.tbfile_TaskLevelGroup:GetCellInt("LevelGroup", i);
		if nLevel<=nTabLevel then
			return nGroup;
		end;
	end;
end


-- 选择一个任务 ID
function RandomTask:SelectTask()
	local nLevelGroup = self:SelectLevelGroup();
	local nTypeRow = self.tbfile_TaskType:CountRate("Level"..nLevelGroup);
	
	if nTypeRow<1 then
		self:_Debug("Select task type error!");
		return;
	end;
	
	-- 先选择一个任务类型，是杀怪还是收集物品
	local nType = self.tbfile_TaskType:GetCellInt("TypeId", nTypeRow);
	
	self:_Debug("Task level group: "..nLevelGroup);
	self:_Debug("Select task type: "..nType);
	
	local nTaskRow = self.tbTaskType[nType]:CountRate("Level"..nLevelGroup);
	
	if nTaskRow<1 then
		self:_Debug("Select task row error!");
		return;
	end;
	
	-- 得到任务 ID 字符
	local nTaskId = self.tbTaskType[nType]:GetCell("TaskId", nTaskRow);
	
	nTaskId = tonumber(nTaskId, 16);
	
	return nTaskId;
	
end


-- 给予玩家随机任务
function RandomTask:GiveTask()

	-- 当天已达上限，不能再发卷轴了
	if self:ApplyAddScroll()==0 then
		return;
	end;	

	local nTaskId = self:SelectTask();
	
	self:AddScroll(nTaskId);
end


-- 给玩家加一个任务卷轴
function RandomTask:AddScroll(nTaskId)
	
	if nTaskId==0 then
		self:_Debug("AddScroll: Select task id error!");
		return;
	end;
	
	local pItem = me.AddScriptItem(self.tbItemId[2], self.tbItemId[3], 1, 0, {nTaskId}, 0);
	
	me.Msg("<color=yellow>您得到了一个任务卷轴<color>！");
	
	if pItem==nil then
		self:_Debug("Add scroll item error!");
		return;
	end;
	
end;


-- 检查当天的任务是否已达上限，可以继续发给卷轴的话就返回 1
function RandomTask:ApplyAddScroll()
	local nNum = self:GetTask(self.TSK_NUM);
	local nOldDate = self:GetTask(self.TSK_DATE);
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));  -- 获取日期：XXXX/XX/XX 格式
	
	if nOldDate == nNowDate then
		if nNum + 1 >= self.LIMIT_NUM then
			return 0;
		end;
	else
		nNum = 0;
	end;
	
	nNum = nNum + 1;
	
	self:SetTask(self.TSK_NUM, nNum);
	self:SetTask(self.TSK_DATE, nNowDate);
	return 1;
end;


-- 检查一个玩家身上是否正在进行随机任务
function RandomTask:HaveRandomTask()
	local tbTask  = nil;
	
	for i=1, #self.nMainTaskId do
		tbTask = Task:GetPlayerTask(me).tbTasks[self.nMainTaskId[i]];
		if tbTask ~= nil then
			return tbTask.tbReferData;
		end;
	end;
	return nil;
end;

function RandomTask:GetTaskInfo(nTaskId)
	local szInfo = Task.tbReferDatas[nTaskId].tbDesc.szMainDesc;
	if szInfo=="" then
		return "无法获取任务描述！";
	end;
	return szInfo;
end;


function RandomTask:GetTask(nTaskId)
	return me.GetTask(self.TSKG_ID, nTaskId);
end;


function RandomTask:SetTask(nTaskId, nValue)
	me.SetTask(self.TSKG_ID, nTaskId, nValue);
end;


function RandomTask:_Debug(szMsg)
	print ("[RandomTask]: "..szMsg);
end;


function RandomTask:_Log(szLog)
	return
end;


-- 定时器的处理

-- 玩家上线时注册一次计时器
function RandomTask:Register()
	
	self:_Debug("Start register randomtask event.");
	
	local tbData = self:PlayerTempData();
	if (not tbData.nTimerId) then
		self:_Debug("Register timer event!");
		tbData.nTimerId	= Timer:Register(self.CHECKTIME * 18, self.OnTimer, self, me.nId);
	end;
	-- 注册下线事件
	if (not tbData.nLogoutId) then
		self:_Debug("Register logout id!");
		tbData.nLogoutId = PlayerEvent:Register("OnLogout", RandomTask.OnLogout, RandomTask);
	end;
	
end;

function RandomTask:OnTimer(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if (not pPlayer) then
		return;
	end
	Setting:SetGlobalObj(pPlayer)
	self:OnStart();
	Setting:RestoreGlobalObj()
	return self.CHECKTIME * 18;  -- 设置多少秒刷新一次
end;


-- 玩家的下线事件
function RandomTask:OnLogout()
	self:StopTimer();
end;


-- 下线时调用
function RandomTask:StopTimer()
	self:_Debug("Player logout, remove timer event.");
	Timer:Close(self:GetPlayerTimerId());
end;

-- 获取玩家的随机任务 Timer ID，如果没有，返回 -1
function RandomTask:GetPlayerTimerId()

		if (not self:PlayerTempData().nTimerId) then
			self:_Debug("Can't get temp timer id!");
			return -1;
		end;
		
		return self:PlayerTempData().nTimerId;
end;


-- 玩家的临时数据
function RandomTask:PlayerTempData()
	local tbPlayerData	 = me.GetTempTable("Task");  -- 玩家的临时表格
	if (not tbPlayerData.RandomTask) then
		tbPlayerData.RandomTask = {};
	end;
	return tbPlayerData.RandomTask;
end;


-- RandomTask:OnInit();
