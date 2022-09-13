-- 文件名　：weekendfish_file.lua
-- 创建者　：huangxiaoming
-- 创建时间：2011-08-05 19:18:10
-- 描  述  ：

if MODULE_GAMESERVER then
	Require("\\script\\task\\weekendfish\\weekendfish_def.lua")
else
	Require("\\script\\task\\weekendfish\\weekendfish_cdef.lua")
end

function WeekendFish:InitFile()
	self:LoadTaskConfig();
	self:InitMainTask();
	self:InitSubTask();
end

function WeekendFish:LoadTaskConfig()
	self.TaskFile = {};	-- 各事件表
	self.TaskAwardFile = {};	-- 奖励表
	self.TaskContent = {};		--固定内容表：
	local tbFile = Lib:LoadTabFile(self.FILE_TASK_INI_PATH);
	if not tbFile then
		print("Error: WeekendFish:LoadTaskConfig loadtabfile failure, path:" .. self.FILE_TASK_INI_PATH);
		return;
	end
	for i = 2, #tbFile do
		local nFishId = tonumber(tbFile[i].FishID) or 0;
		local szFishName = tbFile[i].FishName or "";
		local nAreaId = tonumber(tbFile[i].AreaId) or 0;
		local szAreaName = tbFile[i].AreaName or "";
		local szStaticDesc = tbFile[i].StaticDesc or "";
		local szDynamicDesc = tbFile[i].DynamicDesc or "";
		local szDetailDesc = string.format("%s sống ở %s, mời %s", szFishName, szAreaName, string.format(szStaticDesc, 0, self.TASK_NEED_FISH_NUM));
		
		self.TaskFile[nFishId] = {};
		self.TaskFile[nFishId].szFishName = szFishName;
		self.TaskFile[nFishId].nAreaId = nAreaId;
		self.TaskFile[nFishId].szAreaName = szAreaName;
		self.TaskFile[nFishId].szStaticDesc = szStaticDesc;
		self.TaskFile[nFishId].szDynamicDesc = szDynamicDesc;
		self.TaskFile[nFishId].szDetailDesc = szDetailDesc;
	end
	self:LoadContent();
end

function WeekendFish:LoadContent()
	self.TaskContent.tbReferData = {};
	local tbVisable = {};
	local tbAccept = {};
	self.TaskContent.tbReferData.tbVisable = tbVisable;
	self.TaskContent.tbReferData.tbAccept  = tbAccept;
	
	self.TaskContent.tbSubData = {};
	local tbAttribute	= {};
	tbAttribute.tbDialog	= {};
	tbAttribute.tbDialog["Start"] = {szMsg= ""};
	tbAttribute.tbDialog["Procedure"] = {szMsg = ""};
	tbAttribute.tbDialog["Error"] = {szMsg = ""};
	tbAttribute.tbDialog["Prize"] = {szMsg = ""};
	tbAttribute.tbDialog["End"] = {szMsg = ""};	
	self.TaskContent.tbSubData.tbAttribute = tbAttribute;
end

function WeekendFish:InitMainTask()
	local nTaskId = self.TASK_MAIN_ID;
	local tbTaskData = {};
	tbTaskData.nId = nTaskId;
	tbTaskData.szName = self.TXT_NAME;
	
	-- 主任务的基础属性
	local tbAttribute = {};
	tbTaskData.tbAttribute = tbAttribute;
	
	tbAttribute["Order"]		= Lib:Str2Val("linear");	-- 任务流程：线性
	tbAttribute["Repeat"]		= Lib:Str2Val("true");		-- 是否可重做：是
	tbAttribute["Context"]		= Lib:Str2Val("");			-- 任务描述
	tbAttribute["Share"]		= Lib:Str2Val("false");		-- 是否可共享
	tbAttribute["TaskType"]		= Lib:Str2Val("3");			-- 任务类型：3、随机任务
	tbAttribute["AutoTrack"]	= Lib:Str2Val("true");
	
	-- 主任务下的子任务
	local tbReferIds	= {};
	tbTaskData.tbReferIds	= tbReferIds;
	
	local nReferId 		= nTaskId; -- 引用子任务Id
	local nReferIdx 	= 1; -- 引用子任务索引
	tbReferIds[nReferIdx] = nReferId;
	-- 不能存在已有任务
	assert(not Task.tbReferDatas[nReferId]);
	Task.tbReferDatas[nReferId] = self:NewRefer(nReferId); 
	Task.tbTaskDatas[self.TASK_MAIN_ID]	= tbTaskData;
	
end

function WeekendFish:NewRefer(nReferId)
	local nReferIdx 	= 1; -- 引用子任务索引
	local tbReferData 	= {};
	
	tbReferData.nReferId		= nReferId;
	tbReferData.nReferIdx		= nReferIdx;
	tbReferData.nTaskId			= nReferId
	tbReferData.nSubTaskId		= nReferId;
	tbReferData.szName			= "Hoạt động câu cá";
	tbReferData.tbDesc			= {};
	tbReferData.tbDesc.szMainDesc="Thứ 7 và chú nhật hằng tuần có thể đến chỗ ta để nhận nhiệm vụ câu cá, hoàn thành nhiệm vụ sẽ nhận được nhiều kinh nghiệm. Mỗi ngày có thể câu 50 con cá, mang số cá câu được giao cho ta, ngươi sẽ nhận được phần thưởng phong phú.<enter>Câu cá cần phải có <color=green>cần câu, mồi câu cá, cẩm nang cá<color>, những dụng cụ này có thể mua ở chỗ ta.";
	tbReferData.tbDesc.tbStepsDesc={""};
	
	tbReferData.tbVisable	= self.TaskContent.tbReferData.tbVisable;	    -- 可见条件
	tbReferData.tbAccept	= self.TaskContent.tbReferData.tbAccept; 		-- 可接条件
	
	tbReferData.nAcceptNpcId	= 0--self.ACCEPT_NPC_ID;
	
	tbReferData.bCanGiveUp	= Lib:Str2Val("false");
	
	tbReferData.szGossip = "";			-- 流言文字
	tbReferData.nReplyNpcId	= 0--self.ACCEPT_NPC_ID;	-- 回复 NPC
	tbReferData.szReplyDesc	= "";--"请找新手村秦洼处领取奖励";		-- 回复文字
	tbReferData.nBagSpaceCount = 1;		-- 背包空间检查
	tbReferData.nLevel = 50;
	tbReferData.szIntrDesc = "";
	tbReferData.nDegree = 1;
	tbReferData.tbAwards	= {
		tbFix	= {}, 
		tbOpt	= {},
		tbRand	= {},
	};
	return tbReferData;
end

function WeekendFish:InitSubTask()
	local nSubTaskId = self.TASK_MAIN_ID;
	local tbSubData = self:NewSubTask(nSubTaskId);
	Task.tbSubDatas[nSubTaskId]	= tbSubData;
	return tbSubData;
end

function WeekendFish:NewSubTask(nSubTaskId)
	local tbSubData = {};
	tbSubData.nId		= nSubTaskId;
	tbSubData.szName	= self.TEXT_NAME;
	tbSubData.szDesc	= "";
	
	tbSubData.tbSteps	= {};
	tbSubData.tbExecute = {};
	tbSubData.tbStartExecute = {};
	tbSubData.tbFailedExecute = {};
	tbSubData.tbFinishExecute = {};
	
	-- 任务属性
	tbSubData.tbAttribute	= self.TaskContent.tbSubData.tbAttribute;
	
	-- 步骤
	local tbStep	= {};
	table.insert(tbSubData.tbSteps, tbStep);
	
	-- 开始事件，这里设一个空的 npc
	local tbEvent	= {};
	tbStep.tbEvent	= tbEvent;
	tbEvent.nType	= 1;
	tbEvent.nValue	= 0;

	-- 任务目标
	local tbTargets	= {};
	tbStep.tbTargets	= tbTargets;

	-- 步骤条件
	tbStep.tbJudge	= {};
	tbStep.tbExecute = {};
	return tbSubData;
end

function WeekendFish:LoadDate(nTaskId, tbTaskList)
	if nTaskId == self.TASK_MAIN_ID then
		self:SyncTask(tbTaskList);
	end
end

function WeekendFish:SyncTask(tbTaskList)
	if not Task:GetPlayerTask(me).tbTasks[self.TASK_MAIN_ID] then
		return 0;
	end
	
	if not tbTaskList then
		tbTaskList = {};
		for i = 1, self.FISH_TASK_NUM do
			tbTaskList[i] = me.GetTask(self.TASK_GROUP, self.TASK_FISH_ID1 + i - 1);
		end
	else
		for i = 1, self.FISH_TASK_NUM do
			me.SetTask(self.TASK_GROUP, self.TASK_FISH_ID1 + i - 1, tbTaskList[i]);
		end
	end
	Task:GetPlayerTask(me).tbTasks[self.TASK_MAIN_ID].tbReferData = self:NewRefer(self.TASK_MAIN_ID);
	Task:GetPlayerTask(me).tbTasks[self.TASK_MAIN_ID].tbSubData = self:NewSubTask(self.TASK_MAIN_ID);
	local TbSubTask = Task:GetPlayerTask(me).tbTasks[self.TASK_MAIN_ID].tbSubData;
	local TBReferTask = Task:GetPlayerTask(me).tbTasks[self.TASK_MAIN_ID].tbReferData;
	TBReferTask.tbDesc.szMainDesc = "";
	TbSubTask.szDesc = "";
	local szDescribe =  "Câu cá là 1 thú vui, câu cá là 1 tinh thần. Bây giờ là mùa nước xanh cá béo, hi vọng các vị giúp ta câu cá, Tần Oa ta nhất định sẽ báo đáp các vị!\n";
	szDescribe = szDescribe .. "Sau khi hoàn thành nhiệm vụ đến Tân Thủ Thôn tìm <color=yellow>Tần Oa<color> nhận phần thưởng.\n";
	szDescribe = szDescribe .. string.format("<color=green>Cá may mắn hôm nay: <color><color=yellow>%s %s %s<color>\n", self.TaskFile[tbTaskList[1]].szFishName, self.TaskFile[tbTaskList[2]].szFishName, self.TaskFile[tbTaskList[3]].szFishName);
	szDescribe = szDescribe .. "<color=yellow>Phần thưởng nhiệm vụ:<color> \n<color=green>1. Lượng lớn kinh nghiệm\n2. Chứng nhận thủy sản (Có thể x2 phần thưởng câu cá trong ngày)\n3. Chúc phúc của Tần Oa (Hoàn thành 2 lần nhiệm vụ câu cá mỗi tuần, tuần sau khi nhận nhiệm vụ sẽ tự động nhận được, có thể tăng điểm may mắn câu cá)<color>";
	TBReferTask.tbDesc.tbStepsDesc[1] = szDescribe;
	local tbParams = {};
	for i = 1, self.FISH_TASK_NUM do
		local nTempValue = me.GetTask(self.TASK_GROUP, self.TASK_TARGET1 + i - 1);
		tbParams[i] = {self.TASK_GROUP, self.TASK_TARGET1 + i - 1, nTempValue, self.TASK_NEED_FISH_NUM, self.TaskFile[tbTaskList[i]].szStaticDesc, self.TaskFile[tbTaskList[i]].szDynamicDesc, 1};
	end
	TbSubTask.tbSteps[1].szAwardDesc = "";
	TbSubTask.tbSteps[1].tbExecute 	 = {};
	local tbTargets		= TbSubTask.tbSteps[1].tbTargets;
	local tbTagLib	= Task.tbTargetLib["RequireTaskValue"];
	assert(tbTagLib, 'Target["RequireTaskValue"] not found!!!');
	for i = 1, self.FISH_TASK_NUM do
		local tbTarget = Lib:NewClass(tbTagLib);
		tbTarget:Init(unpack(tbParams[i]));
		tbTargets[i] = tbTarget;
	end
	if MODULE_GAMESERVER then
		me.CallClientScript({"WeekendFish:SyncTask", tbTaskList});
	end
end