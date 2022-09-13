-------------------------------------------------------
-- 文件名　：keyimen_task.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2012-08-22 11:31:58
-- 文件描述：
-------------------------------------------------------

if MODULE_GAMESERVER then
	Require("\\script\\boss\\keyimen\\keyimen_def.lua");
else
	Require("\\script\\boss\\keyimen\\keyimen_client.lua");
end

function Keyimen:InitFile()
	self:LoadTaskConfig();
	self:InitMainTask();
	self:InitSubTask();
end

function Keyimen:LoadTaskConfig()
	
	self.TaskFile = {};			-- 各事件表
	self.TaskAwardFile = {};	-- 奖励表
	self.TaskContent = {};		-- 固定内容表：
	
	for nCamp, tbCamp in ipairs(self.NPC_DRAGON_LIST) do
		self.TaskFile[nCamp] = {};
		for i, tbInfo in ipairs(tbCamp) do
			local szStaticDesc = "";
			local szDynamicDesc = string.format("Đánh bại <pos=%s,%s,%s,%s>, nhấp vào Long Hồn", tbInfo.szName, unpack(tbInfo.tbPos));
			self.TaskFile[nCamp][i] = {};
			self.TaskFile[nCamp][i].szStaticDesc = szStaticDesc;
			self.TaskFile[nCamp][i].szDynamicDesc = szDynamicDesc;
		end
		local tbBoss = self.NPC_BOSS_LIST[nCamp];
		local szStaticDesc = "";
		local szDynamicDesc = string.format("Đánh bại %s", tbBoss.szDragonName);
		self.TaskFile[nCamp][self.FINAL_DRAGON] = {};
		self.TaskFile[nCamp][self.FINAL_DRAGON].szStaticDesc = szStaticDesc;
		self.TaskFile[nCamp][self.FINAL_DRAGON].szDynamicDesc = szDynamicDesc;
	end
	
	self:LoadContent();
end

function Keyimen:LoadContent()
	
	self.TaskContent.tbReferData = {};
	
	local tbVisable = {};
	local tbAccept = {};
	self.TaskContent.tbReferData.tbVisable = tbVisable;
	self.TaskContent.tbReferData.tbAccept  = tbAccept;
	
	self.TaskContent.tbSubData = {};
	
	local tbAttribute = {};
	tbAttribute.tbDialog = {};
	tbAttribute.tbDialog["Start"] 		= {szMsg= ""};
	tbAttribute.tbDialog["Procedure"] 	= {szMsg = ""};
	tbAttribute.tbDialog["Error"] 		= {szMsg = ""};
	tbAttribute.tbDialog["Prize"] 		= {szMsg = ""};
	tbAttribute.tbDialog["End"] 		= {szMsg = ""};
	
	self.TaskContent.tbSubData.tbAttribute = tbAttribute;
end

function Keyimen:InitMainTask()
	
	local nTaskId = self.TASK_MAIN_ID;
	local tbTaskData = {};
	tbTaskData.nId = nTaskId;
	tbTaskData.szName = "[Nhiệm vụ bang-Khắc Di Môn]";
	
	-- 主任务的基础属性
	local tbAttribute = {};
	tbTaskData.tbAttribute = tbAttribute;
	
	tbAttribute["Order"]		= Lib:Str2Val("linear");	-- 任务流程：线性
	tbAttribute["Repeat"]		= Lib:Str2Val("true");		-- 是否可重做：是
	tbAttribute["Context"]		= Lib:Str2Val("");			-- 任务描述
	tbAttribute["Share"]		= Lib:Str2Val("false");		-- 是否可共享
	tbAttribute["TaskType"]		= Lib:Str2Val("3");			-- 任务类型：3、随机任务
	tbAttribute["AutoTrack"]	= Lib:Str2Val("true");		-- 自动跟踪
	
	-- 主任务下的子任务
	local tbReferIds = {};
	tbTaskData.tbReferIds = tbReferIds;
	
	local nReferId = nTaskId; 	-- 引用子任务Id
	local nReferIdx = 1; 		-- 引用子任务索引
	tbReferIds[nReferIdx] = nReferId;
	
	-- 不能存在已有任务
	assert(not Task.tbReferDatas[nReferId]);
	Task.tbReferDatas[nReferId] = self:NewRefer(nReferId); 
	Task.tbTaskDatas[self.TASK_MAIN_ID]	= tbTaskData;
end

function Keyimen:NewRefer(nReferId)
	
	local nReferIdx 	= 1; -- 引用子任务索引
	local tbReferData 	= {};
	
	tbReferData.nReferId		= nReferId;
	tbReferData.nReferIdx		= nReferIdx;
	tbReferData.nTaskId			= nReferId
	tbReferData.nSubTaskId		= nReferId;
	tbReferData.szName			= "Nhiệm vụ bang-Khắc Di Môn";
	tbReferData.tbDesc			= {};
	tbReferData.tbDesc.szMainDesc	="Phá hủy 5 U Huyền Long Trụ, phóng thích Xích Diệm Long Hồn.";
	tbReferData.tbDesc.tbStepsDesc	={""};
	
	tbReferData.tbVisable	= self.TaskContent.tbReferData.tbVisable;	    -- 可见条件
	tbReferData.tbAccept	= self.TaskContent.tbReferData.tbAccept; 		-- 可接条件
	
	tbReferData.bCanGiveUp	= Lib:Str2Val("false");
	
	tbReferData.szGossip = "";			-- 流言文字
	tbReferData.nAcceptNpcId = 0;		-- 接任务npc
	tbReferData.nReplyNpcId	= 0			-- 交任务npc
	tbReferData.szReplyDesc	= "";		-- 回复文字
	tbReferData.nBagSpaceCount = 3;		-- 背包空间检查
	tbReferData.nLevel = 100;			-- 角色等级
	tbReferData.szIntrDesc = "";
	tbReferData.nDegree = 1;
	tbReferData.tbAwards = 
	{
		tbFix	= 
		{
			{
				szType = "exp", 
				varValue = self.AWARD_EXP, 
				nSprIdx = "",
				szDesc = "Kinh nghiệm", 
			},
			{
				szType = "item", 
				varValue = {18, 1, 1800, 1}, 
				nSprIdx = "",
				szDesc = "Thỏi bạc-Lương", 
				szAddParam1 = 1,
			},
			{
				szType = "item", 
				varValue = {18, 1, 1801, 1}, 
				nSprIdx = "",
				szDesc = "Long Cẩm Ngọc Hạp", 
				szAddParam1 = 1,
			},
			{
				szType = "item", 
				varValue = {18, 1, 1802, 1}, 
				nSprIdx = "",
				szDesc = "Long Ảnh Ngọc Hạp", 
				szAddParam1 = 1,
			},
		}, 
		tbOpt	= {},
		tbRand	= {},
	};
	
	return tbReferData;
end

function Keyimen:InitSubTask()
	local nSubTaskId = self.TASK_MAIN_ID;
	local tbSubData = self:NewSubTask(nSubTaskId);
	Task.tbSubDatas[nSubTaskId]	= tbSubData;
	return tbSubData;
end

function Keyimen:NewSubTask(nSubTaskId)
	
	local tbSubData 	= {};
	tbSubData.nId		= nSubTaskId;
	tbSubData.szName	= "Nhiệm vụ con Khắc Di Môn";
	tbSubData.szDesc	= "";
	
	tbSubData.tbSteps	= {};
	tbSubData.tbExecute = {};
	tbSubData.tbStartExecute = {};
	tbSubData.tbFailedExecute = {};
	tbSubData.tbFinishExecute = {};
	
	-- 任务属性
	tbSubData.tbAttribute	= self.TaskContent.tbSubData.tbAttribute;
	
	-- 任务步骤
	local tbStep = {};
	table.insert(tbSubData.tbSteps, tbStep);
	
	-- 开始事件，这里设一个空的npc
	local tbEvent	= {};
	tbStep.tbEvent	= tbEvent;
	tbEvent.nType	= 1;
	tbEvent.nValue	= 0;

	-- 任务目标
	local tbTargets	= {};
	tbStep.tbTargets = tbTargets;

	-- 步骤条件
	tbStep.tbJudge = {};
	tbStep.tbExecute = {};
	
	return tbSubData;
end

function Keyimen:LoadData(nTaskId, tbTarget)
	if nTaskId == self.TASK_MAIN_ID then
		self:SyncTask(tbTarget);
	end
end

function Keyimen:SyncTask(tbTarget)
	
	if not Task:GetPlayerTask(me).tbTasks[self.TASK_MAIN_ID] then
		return 0;
	end
	
	if not tbTarget then
		tbTarget = {};
		for i = 1, #self.TASK_TARGET do
			tbTarget[i] = me.GetTask(self.TASK_GID, self.TASK_TARGET[i]);
		end
	end
	
	local nCamp = 3 - me.GetTask(self.TASK_GID, self.TASK_CAMP);
	
	Task:GetPlayerTask(me).tbTasks[self.TASK_MAIN_ID].tbReferData = self:NewRefer(self.TASK_MAIN_ID);
	Task:GetPlayerTask(me).tbTasks[self.TASK_MAIN_ID].tbSubData = self:NewSubTask(self.TASK_MAIN_ID);
	
	local tbSubTask = Task:GetPlayerTask(me).tbTasks[self.TASK_MAIN_ID].tbSubData;
	local tbReferTask = Task:GetPlayerTask(me).tbTasks[self.TASK_MAIN_ID].tbReferData;
	
	tbReferTask.tbDesc.szMainDesc = "";
	tbSubTask.szDesc = "";
	local szDescribe =  "Chiến trường khắc nghiệt với những trận chiến quyết liệt, Khắc Di Môn với địa thế hiểm trở đã trở thành nơi tranh đấu nảy lửa. Tương truyền, vùng này có long mạch, bọn gây rối đã niệm chú cho Long Trụ trấn giữ, cản trở long khí hiện thế. Chỉ cần phá hủy Long Trụ, giải phong ấn Xích Diệm Long Hồn, sẽ được thưởng phong phú.";
	tbReferTask.tbDesc.tbStepsDesc[1] = szDescribe;
	
	local tbParams = {};
	for i = 1, #tbTarget do
		local nTempValue = me.GetTask(self.TASK_GID, self.TASK_FINISH[i]);
		tbParams[i] = {self.TASK_GID, self.TASK_FINISH[i], nTempValue, 1, self.TaskFile[nCamp][tbTarget[i]].szStaticDesc, self.TaskFile[nCamp][tbTarget[i]].szDynamicDesc};
	end
	
	tbSubTask.tbSteps[1].szAwardDesc = "";
	tbSubTask.tbSteps[1].tbExecute 	 = {};
	local tbTargets	= tbSubTask.tbSteps[1].tbTargets;
	local tbTagLib	= Task.tbTargetLib["RequireTaskValue"];
	assert(tbTagLib, 'Target["RequireTaskValue"] not found!!!');
	
	for i = 1, #tbTarget do
		local tbTarget = Lib:NewClass(tbTagLib);
		tbTarget:Init(unpack(tbParams[i]));
		tbTargets[i] = tbTarget;
	end
	
	if MODULE_GAMESERVER then
		me.CallClientScript({"Keyimen:SyncTask", tbTarget});
	end
end

function Keyimen:OnAccept()
	if MODULE_GAMESERVER then
		local nCamp = Keyimen:GetPlayerTongCamp(me);
		local tbTarget = Keyimen:GetPlayerTongTask(me);
		for i, nValue in ipairs(tbTarget) do
			me.SetTask(self.TASK_GID, self.TASK_TARGET[i], nValue);
		end
		me.SetTask(self.TASK_GID, self.TASK_CAMP, nCamp);
		local szBlackMsg = "Giọng nói thần bí: \"Đợi ngươi đã lâu, long khí truyền thuyết sắp hiện thế. Ta quan sát thiên tượng trăm năm nay nhưng không thể đoán trước tương lai, ngươi muốn trả lại sự yên bình cho Khắc Di Môn ư?\"<end>";
		szBlackMsg = szBlackMsg .."<playername>: \"Đồng ý! Ta một lòng vì dân vì nước!\"";
		TaskAct:Talk(szBlackMsg);
		me.SetTask(self.TASK_GID, self.TASK_STATE, 1);
		self:LoadData(self.TASK_MAIN_ID, tbTarget);
	end
end

function Keyimen:DoAccept(tbTask, nTaskId, nReferId)
	if nTaskId == self.TASK_MAIN_ID and nReferId == self.TASK_MAIN_ID then
		self:OnAccept();
	end
end
