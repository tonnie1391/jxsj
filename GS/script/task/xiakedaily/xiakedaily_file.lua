-- 文件名　：xiakedaily.lua
-- 创建者　：huangxiaoming
-- 创建时间：2011-03-05 15:01:10
-- 描  述  ：侠客日常任务

Require("\\script\\task\\xiakedaily\\xiakedaily_def.lua")

function XiakeDaily:InitFile()
	self:LoadTaskConfig();
	self:InitMainTask();
	self:InitSubTask();
end

function XiakeDaily:LoadTaskConfig()
	self.TaskFile = {};	-- 各事件表
	self.TaskAwardFile = {};	-- 奖励表
	self.TaskContent = {};		--固定内容表：
	local tbFile = Lib:LoadTabFile(self.FILE_TASK_INI_PATH);
	if not tbFile then
		print("Error: XiakeDaily:LoadTaskConfig loadtabfile failure");
		return;
	end
	for i = 2, #tbFile do
		local nFubenId = tonumber(tbFile[i].FubenId) or 0;
		local szFubenName = tbFile[i].FubenName;
		local nTypeId = tonumber(tbFile[i].TypeId) or 0;
		local szTypeName = tbFile[i].TypeName;
		local szStaticDesc = tbFile[i].StaticDesc;
		local szDynamicDesc = tbFile[i].DynamicDesc;
		local szDetailDesc	= tbFile[i].DetailDesc;
		local ndifficult = tonumber(tbFile[i].Difficult) or -1;
		
		self.TaskFile[nFubenId] = {};
		self.TaskFile[nFubenId].szFubenName = szFubenName;
		self.TaskFile[nFubenId].nTypeId = nTypeId;
		self.TaskFile[nFubenId].szTypeName = szTypeName;
		self.TaskFile[nFubenId].szStaticDesc = szStaticDesc;
		self.TaskFile[nFubenId].szDynamicDesc = szDynamicDesc;
		self.TaskFile[nFubenId].szDetailDesc = szDetailDesc;
		self.TaskFile[nFubenId].ndifficult = ndifficult;
	end
	self:LoadContent();
end

function XiakeDaily:InitMainTask()
	local nTaskId = self.TASK_MAIN_ID;
	local tbTaskData 	= {};
	tbTaskData.nId		= nTaskId;
	tbTaskData.szName	= self.TEXT_NAME;
	
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

function XiakeDaily:NewRefer(nReferId)
	local nReferIdx 	= 1; -- 引用子任务索引
	local tbReferData 	= {};
	
	tbReferData.nReferId		= nReferId;
	tbReferData.nReferIdx		= nReferIdx;
	tbReferData.nTaskId			= nReferId
	tbReferData.nSubTaskId		= nReferId;
	tbReferData.szName			= "Nhiệm vụ hiệp khách";
	tbReferData.tbDesc			= {};
	tbReferData.tbDesc.szMainDesc="Mỗi ngày hoàn thành 2 nhiệm vụ chỉ định sẽ nhận được phần thưởng phong phú.\nMỗi tuần nếu hoàn thành nhiệm vụ lần thứ 6 còn nhận được thêm phần thưởng lệnh bài.";
	tbReferData.tbDesc.tbStepsDesc={""};
	
	tbReferData.tbVisable	= self.TaskContent.tbReferData.tbVisable;	    -- 可见条件
	tbReferData.tbAccept	= self.TaskContent.tbReferData.tbAccept; 		-- 可接条件
	
	tbReferData.nAcceptNpcId	= 0--self.ACCEPT_NPC_ID;
	
	tbReferData.bCanGiveUp	= Lib:Str2Val("false");
	
	tbReferData.szGossip = "";			-- 流言文字
	tbReferData.nReplyNpcId	= 0--self.ACCEPT_NPC_ID;	-- 回复 NPC
	tbReferData.szReplyDesc	= "";--"请找木良领取奖励";		-- 回复文字
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

function XiakeDaily:LoadContent()
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

function XiakeDaily:NewSubTask(nSubTaskId)
	local tbSubData = {};
	tbSubData.nId		= nSubTaskId;
	tbSubData.szName	= self.TEXT_NAME;
	tbSubData.szDesc	= "";
	
	tbSubData.tbSteps	= {};
	tbSubData.tbExecute = {};
	tbSubData.tbStartExecute = {};
	tbSubData.tbFailedExecute = {};
	tbSubData.tbFinishExecute = {"return XiakeDaily:FinishExecute()",};
	
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

function XiakeDaily:InitSubTask()
	local nSubTaskId = self.TASK_MAIN_ID;
	local tbSubData = self:NewSubTask(nSubTaskId);
	Task.tbSubDatas[nSubTaskId]	= tbSubData;
	return tbSubData;
end

function XiakeDaily:LoadDate(nTaskId, nTarget1, nTarget2)
	if nTaskId == self.TASK_MAIN_ID then
		self:SyncTask(nTarget1, nTarget2);
	end
end

function XiakeDaily:SyncTask(nTarget1, nTarget2)
	if not Task:GetPlayerTask(me).tbTasks[self.TASK_MAIN_ID] then
		return 0;
	end
	if not nTarget1 or not nTarget2 then
		nTarget1 = self:GetTask(self.TASK_TARGET1_ID);
		nTarget2 = self:GetTask(self.TASK_TARGET2_ID);
	else
		self:SetTask(self.TASK_TARGET1_ID, nTarget1);
		self:SetTask(self.TASK_TARGET2_ID, nTarget2);
	end
	Task:GetPlayerTask(me).tbTasks[self.TASK_MAIN_ID].tbReferData = self:NewRefer(self.TASK_MAIN_ID);
	Task:GetPlayerTask(me).tbTasks[self.TASK_MAIN_ID].tbSubData = self:NewSubTask(self.TASK_MAIN_ID);
	local TbSubTask = Task:GetPlayerTask(me).tbTasks[self.TASK_MAIN_ID].tbSubData;
	local TBReferTask = Task:GetPlayerTask(me).tbTasks[self.TASK_MAIN_ID].tbReferData;
	TBReferTask.tbDesc.szMainDesc = "";--TBReferTask.tbDesc.szMainDesc .. "1." .. self.TaskFile[nTarget1].szStaticDesc .. "\n2." .. self.TaskFile[nTarget2].szStaticDesc;
	TbSubTask.szDesc = "";--self.TaskFile[nTarget1].szStaticDesc .. "和" .. self.TaskFile[nTarget2].szStaticDesc;
	local szDescribe =  "Hiệp khách chân chính trên giang hồ chính là kẻ hào hiệp nhiệt tình giúp đỡ người khác, trọng chữ tín, trừ hung bạo giúp kẻ yếu thế.\n";
	szDescribe = szDescribe .. "<color=yellow>" .. self.TaskFile[nTarget1].szDynamicDesc .. "<color>: " .. self.TaskFile[nTarget1].szDetailDesc .. "\n";
	szDescribe = szDescribe .. "<color=yellow>" .. self.TaskFile[nTarget2].szDynamicDesc .. "<color>: " .. self.TaskFile[nTarget2].szDetailDesc .. "\n";
	szDescribe = szDescribe .. "Sau khi hoàn thành nhiệm vụ đến Lâm An Phủ tìm <pos=Hạ Hầu Nguyên Thao,29,1643,3946> để nhận phần thưởng.";
	TBReferTask.tbDesc.tbStepsDesc[1] = szDescribe;
	local tbParams1 = {self.TASK_GROUP, self.TASK_FIRST_TARGET, 0, 1, self.TaskFile[nTarget1].szStaticDesc,self.TaskFile[nTarget1].szDynamicDesc};
	local tbParams2 = {self.TASK_GROUP, self.TASK_SECOND_TARGET, 0, 1, self.TaskFile[nTarget2].szStaticDesc, self.TaskFile[nTarget2].szDynamicDesc};
	TbSubTask.tbSteps[1].szAwardDesc = "";
	TbSubTask.tbSteps[1].tbExecute 	 = {};
	local tbTargets		= TbSubTask.tbSteps[1].tbTargets;
	local tbTagLib	= Task.tbTargetLib["RequireTaskValue"];
	assert(tbTagLib, 'Target["RequireTaskValue"] not found!!!');
	local tbTarget1	= Lib:NewClass(tbTagLib);--根据函数名new目标
	tbTarget1:Init(unpack(tbParams1));--从子任务文件把目标数据读入
	local tbTarget2 = Lib:NewClass(tbTagLib);
	tbTarget2:Init(unpack(tbParams2));
	tbTargets[1]	= tbTarget1;
	tbTargets[2]	= tbTarget2;
	
	if MODULE_GAMESERVER then
		me.CallClientScript({"XiakeDaily:SyncTask", nTarget1, nTarget2});
	end
end