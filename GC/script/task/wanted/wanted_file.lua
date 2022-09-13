--官府通缉令
--孙多良
--2008.08.05
Require("\\script\\task\\wanted\\wanted_def.lua");

function Wanted:LoadLevelGroup()
	self.LevelGroup = {};
	self.LevelGroupName = {};
	local tbFile = Lib:LoadTabFile("\\setting\\task\\wanted\\level_group.txt");
	if not tbFile then
		return;
	end
	for i=2, #tbFile do 
		local nLevel = tonumber(tbFile[i].Level);
		local nLevelGroup = tonumber(tbFile[i].LevelGroup);
		local szGroupName = tbFile[i].GroupName or "";
		self.LevelGroup[nLevelGroup] = nLevel;
		self.LevelGroupName[nLevelGroup] = szGroupName;
	end
end

function Wanted:LoadWeekGroup()
	self.TaskWeekSeg = {};
	local tbFile = Lib:LoadTabFile("\\setting\\task\\wanted\\group_npc_week.txt");
	if not tbFile then
		return;
	end
	for i=1, #tbFile do 
		local nGroup 			= tonumber(tbFile[i].Group);
		local nLastWeekSum 		= tonumber(tbFile[i].LastWeekSum);
		local nOnlyTaskCount 	= tonumber(tbFile[i].OnlyTaskCount);
		self.TaskWeekSeg[nGroup] = self.TaskWeekSeg[nGroup] or {};
		local tbParam = {nLastWeekSum = nLastWeekSum, nTaskCount = nOnlyTaskCount};
		table.insert(self.TaskWeekSeg[nGroup], tbParam);
	end
end

function Wanted:LoadTimeGroup()
	self.TaskTimeSeg = {};
	local tbFile = Lib:LoadTabFile("\\setting\\task\\wanted\\group_npc_time.txt");
	if not tbFile then
		return;
	end
	for i=1, #tbFile do 
		local nGroup 			= tonumber(tbFile[i].Group);
		local nOpenSeverDay 	= tonumber(tbFile[i].OpenSeverDay);
		local nOnlyTaskCount 	= tonumber(tbFile[i].OnlyTaskCount);
		self.TaskTimeSeg[nGroup] = self.TaskTimeSeg[nGroup] or {};
		local tbParam = {nTimeDay = nOpenSeverDay, nTaskCount = nOnlyTaskCount};
		table.insert(self.TaskTimeSeg[nGroup], tbParam);
	end
end

function Wanted:LoadCallBossRate()
	self.CallBossRateSeg = {};
	local tbFile = Lib:LoadTabFile("\\setting\\task\\wanted\\wanted_callboss_seg.txt");
	if not tbFile then
		return;
	end
	for i=1, #tbFile do 	
		local nId 				= tonumber(tbFile[i].Id);
		local nOpenServerDay 	= tonumber(tbFile[i].OpenServerDay);
		self.CallBossRateSeg[nId] = nOpenServerDay;
	end
	
	self.CallBossRate = {};
	local tbFile = Lib:LoadTabFile("\\setting\\task\\wanted\\wanted_callboss.txt");
	if not tbFile then
		return;
	end
	for i=1, #tbFile do 
		local nNpcId 			= tonumber(tbFile[i].NpcId);
		local nLevel		 	= tonumber(tbFile[i].Level);
		local tbNpcInFor = {nNpcId = nNpcId, nLevel = nLevel};
		for nId in pairs(self.CallBossRateSeg) do
			local nRate = tonumber(tbFile[i]["Rate"..nId]) or 0;
			self.CallBossRate[nId] 	= self.CallBossRate[nId] or {nMaxRate =1, tbBoss={}};
			local tbParam = {tbNpcInFor = tbNpcInFor, nRate = nRate};
			table.insert(self.CallBossRate[nId].tbBoss, tbParam);
		end
	end
	for nId, tbSegParam in pairs(self.CallBossRate) do
		local nMaxRate = 0;
		for _, tbParam in pairs(tbSegParam.tbBoss or {}) do
			nMaxRate = nMaxRate + tbParam.nRate;
		end
		tbSegParam.nMaxRate = nMaxRate;
	end
end

function Wanted:LoadTask()
	self.TaskFile = {};
	self.Npc2TaskId = {};
	self.TaskLevelSeg = {};
	self.TaskLevelSegActionKind = {};
	local tbFile = Lib:LoadTabFile("\\setting\\task\\wanted\\wanted_killnpc.txt");
	if not tbFile then
		return;
	end
	for i=2, #tbFile do
		local nTaskId	= tonumber(tbFile[i].TaskId);
		local nLevelSeg	= tonumber(tbFile[i].LevelSeg);
		local nActionKind = tonumber(tbFile[i].ActionKind) or 0;
		local tbTemp = {
		 szTaskName	= (tbFile[i].TaskName),
		 szTargetName= (tbFile[i].TaskType),
		 nMapId		= tonumber(tbFile[i].MapId),
		 nPosX		= math.floor(tonumber(tbFile[i].PosX)),
		 nPosY		= math.floor(tonumber(tbFile[i].PosY)),
		 szMapName	= (tbFile[i].MapName),
		 nNpcId		= tonumber(tbFile[i].NpcId),
		 nNum		= tonumber(tbFile[i].Num) or 1,	
		 nRandCallBoss = tonumber(tbFile[i].RandCallBoss) or 0,
		 nBossId	= tonumber(tbFile[i].BossId) or 0;
		 nLevelSeg  = nLevelSeg;
		 nActionKind = nActionKind;
		}
		self.TaskFile[nTaskId] = tbTemp;
		self.Npc2TaskId[tonumber(tbFile[i].NpcId) or 0] = nTaskId;
		if not self.TaskLevelSeg[nLevelSeg] then
			self.TaskLevelSeg[nLevelSeg] = {};
		end
		self.TaskLevelSegActionKind[nLevelSeg] = self.TaskLevelSegActionKind[nLevelSeg] or {};
		self.TaskLevelSegActionKind[nLevelSeg][nActionKind] = self.TaskLevelSegActionKind[nLevelSeg][nActionKind] or {};
		table.insert(self.TaskLevelSeg[nLevelSeg], nTaskId);
		table.insert(self.TaskLevelSegActionKind[nLevelSeg][nActionKind], nTaskId);
	end
end

-- 初始化任务链表格
function Wanted:InitFile()
	-- 根据等级段来选择任务
	self:LoadLevelGroup();
	self:LoadWeekGroup();
	self:LoadTimeGroup();
	self:LoadCallBossRate();
	self:LoadTask();
	self:ReadMainTask();
	self:ReadTaskFile();
end;

function Wanted:ReadTaskFile()
	self.tbSubTaskData = {};
	for nTaskId, tbSubFile in pairs(self.TaskFile) do
		local tbParams = {};
		if tbSubFile.szTargetName == "KillNpc" then
			tbParams = {tbSubFile.nNpcId, tbSubFile.nMapId, tbSubFile.nNum};
		end;
		-- 服务端才载入子任务
		if (MODULE_GAMESERVER) then
			self:ReadSubTask(nTaskId, tbSubFile.szTaskName, tbSubFile.szTargetName, tbParams);
		else
			-- 给客户端用的缓存
			if self.tbSubTaskData[nTaskId]==nil then
				self.tbSubTaskData[nTaskId] = {};
			end;
			self.tbSubTaskData[nTaskId].szTaskName	= tbSubFile.szTaskName;
			self.tbSubTaskData[nTaskId].szTargetName	= tbSubFile.szTargetName;
			self.tbSubTaskData[nTaskId].tbParams		= tbParams;			
		end;
	end;
end;

function Wanted:ReadMainTask()
	
	local tbTaskData	= {};
	tbTaskData.nId		= self.TASK_MAIN_ID;
	tbTaskData.szName	= self.TEXT_NAME;
	
	
	-- 主任务的基础属性
	local tbAttribute	= {};
	tbTaskData.tbAttribute	= tbAttribute;
	
	tbAttribute["Order"]		= Lib:Str2Val("linear");	-- 任务流程：线性
	tbAttribute["Repeat"]		= Lib:Str2Val("true");		-- 是否可重做：是
	tbAttribute["Context"]		= Lib:Str2Val("");			-- 任务描述
	tbAttribute["Share"]		= Lib:Str2Val("false");		-- 是否可共享
	tbAttribute["TaskType"]		= Lib:Str2Val("3");			-- 任务类型：3、随机任务
	tbAttribute["AutoTrack"]	= Lib:Str2Val("true");
	
	-- 主任务下的子任务
	local tbReferIds	= {};
	tbTaskData.tbReferIds	= tbReferIds;
		
	for nTaskId, tbSubFile in pairs(self.TaskFile) do

		local nReferId		= nTaskId;  -- 引用子任务Id
		local nReferIdx		= #tbReferIds + 1;	-- 引用子任务索引
		local tbReferData	= {};
		
		-- 不能存在已有的任务
		assert(not Task.tbReferDatas[nReferId]);
		
		Task.tbReferDatas[nReferId]	= tbReferData;
		
		tbReferIds[nReferIdx]		= nReferId;
		tbReferData.nReferId		= nReferId;
		tbReferData.nReferIdx		= nReferIdx;
		tbReferData.nTaskId			= self.TASK_MAIN_ID;
		tbReferData.nSubTaskId		= nTaskId;
		tbReferData.szName			= string.format("缉拿江洋大盗%s",tbSubFile.szTaskName);
		tbReferData.tbDesc			= {};
		tbReferData.tbDesc.tbStepsDesc = {};
		tbReferData.tbDesc.tbStepsDesc[1] = string.format("刑部衙门广发海捕文书，江洋大盗<pos=%s,%s,%s,%s>近日出现在<color=yellow>%s<color=white>，你务必将其缉拿归案，恢复当地安宁。",tbSubFile.szTaskName,tbSubFile.nMapId, tbSubFile.nPosX, tbSubFile.nPosY, tbSubFile.szMapName);
		
		tbReferData.tbVisable	= {};	-- 可见条件
		tbReferData.tbAccept	= {}; 	-- 可接条件
		
		tbReferData.nAcceptNpcId	= 0;
		
		tbReferData.bCanGiveUp	= Lib:Str2Val("false");
		
		tbReferData.szGossip = "";			-- 流言文字
		tbReferData.nReplyNpcId	= 0;		-- 回复 NPC
		tbReferData.szReplyDesc	= "";		-- 回复文字
		tbReferData.nBagSpaceCount = 0;		-- 背包空间检查
		tbReferData.nLevel = 50;
		tbReferData.szIntrDesc = "";
		tbReferData.nDegree = 1;
		tbReferData.tbAwards	= {
			tbFix	= {},
			tbOpt	= {},
			tbRand	= {},
		};
	end;
	
	Task.tbTaskDatas[self.TASK_MAIN_ID]	= tbTaskData;
	return tbTaskData;
end;

-- 读入子任务，子任务 id，子任务类型（杀怪、寻物等），任务中文名
function Wanted:ReadSubTask(nSubTaskId, szTaskName, szTargetName, tbParams)

	local tbSubData		= {};
	tbSubData.nId		= nSubTaskId;
	tbSubData.szName	= szTaskName;
	tbSubData.szDesc	= string.format("刑部衙门广发海捕文书，江洋大盗<pos=%s,%s,%s,%s>近日出现在<color=yellow>%s<color=white>，你务必将其缉拿归案，恢复当地安宁。",szTaskName,self.TaskFile[nSubTaskId].nMapId, self.TaskFile[nSubTaskId].nPosX, self.TaskFile[nSubTaskId].nPosY, self.TaskFile[nSubTaskId].szMapName);
	tbSubData.tbSteps	= {};
	tbSubData.tbExecute = {};
	tbSubData.tbStartExecute = {};
	tbSubData.tbFailedExecute = {};
	tbSubData.tbFinishExecute = {};
	-- 任务属性
	local tbAttribute	= {};
	tbSubData.tbAttribute	= tbAttribute;
	
	-- 开始对话
	local tbDialog	= {};
	tbAttribute.tbDialog	= tbDialog;
	tbAttribute.tbDialog["Start"] = {szMsg= ""};
	tbAttribute.tbDialog["Procedure"] = {szMsg = ""};
	tbAttribute.tbDialog["Error"] = {szMsg = ""};
	tbAttribute.tbDialog["Prize"] = {szMsg = ""};
	tbAttribute.tbDialog["End"] = {szMsg = ""};	

	-- 步骤
	local tbStep	= {};
	table.insert(tbSubData.tbSteps, tbStep);

	-- 开始事件，这里设一个空的 npc
	local tbEvent	= {};
	tbStep.tbEvent	= tbEvent;
	tbEvent.nType	= 1;
	tbEvent.nValue	= 0;

	-- 任务目标
	local tbTargets		= {};
	tbStep.tbTargets	= tbTargets;

	local tbTagLib	= Task.tbTargetLib[szTargetName];
	assert(tbTagLib, "Target["..szTargetName.."] not found!!!");
	local tbTarget	= Lib:NewClass(tbTagLib);--根据函数名new目标
	tbTarget:Init(unpack(tbParams));--从子任务文件把目标数据读入
	tbTargets[#tbTargets+1]	= tbTarget;


	-- 步骤条件
	tbStep.tbJudge	= {};
	tbStep.tbExecute = {};

	
	Task.tbSubDatas[nSubTaskId]	= tbSubData;
	return tbSubData;
end;
