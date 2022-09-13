
-- ====================== 文件信息 ======================

-- 剑侠世界随机任务任务卷轴头文件
-- Edited by peres
-- 2007/06/03 PM 11:18

-- 她的眼泪轻轻地掉落下来
-- 抚摸着自己的肩头，寂寥的眼神
-- 是，褪掉繁华和名利带给的空洞安慰，她只是一个一无所有的女子
-- 不爱任何人，亦不相信有人会爱她

-- ======================================================

ScrollTask.tbItemId = {18,1,5};  -- 卷轴的 ID 定义

ScrollTask.ITEM_TASKID = 1;      -- 储存任务ID的物品索引

ScrollTask.nMainTaskId = tonumber("62", 16);

function ScrollTask:OnInit()
	
	self:_Debug("Start init scroll task! ");
	
	self.tbfile_EntityScrollTask     = Lib:NewClass(Lib.readTabFile);
	self.tbfile_LevelGroup           = Lib:NewClass(Lib.readTabFile);
	
	self.tbfile_EntityScrollTask:OnInit("\\setting\\task\\scroll\\scrolltask.txt");
	self.tbfile_LevelGroup:OnInit("\\setting\\task\\scroll\\level_group.txt");
end;

function ScrollTask:SelectLevelGroup()
	local nLevel = me.nLevel; --GetLevel();
	local nTabLevel = 0;
	local nGroup = 0;
	
	local nRow = self.tbfile_LevelGroup:GetRow();
	local i=0;
	
	self:_Debug("Get the level group file row: "..nRow);
	
	for i=1, nRow do
		nTabLevel = self.tbfile_LevelGroup:GetCellInt("Level", i);
		nGroup    = self.tbfile_LevelGroup:GetCellInt("LevelGroup", i);
		if nLevel<=nTabLevel then
			return nGroup;
		end;
	end;
end;

function ScrollTask:SelectTask()
	local nLevelGroup = self:SelectLevelGroup();
	
	local tbTask = self.tbfile_EntityScrollTask;
	local nTaskRow = tbTask:CountRate("Level"..nLevelGroup);
	
	local nTaskId  = tbTask:GetCell("TaskId", nTaskRow);
		
		if nTaskId == nil or nTaskId=="" then
			self:_Debug("Select task id error! ");
			return 0;
		end;
		
		nTaskId = tonumber(nTaskId, 16);
		self:_Debug("Select a task Id: "..nTaskId);
		
		return nTaskId;
end;

-- 给玩家加一个任务卷轴
function ScrollTask:AddScroll(nTaskNum)
	local nTaskId = self:SelectTask();
	
	-- 如果有传进来的参数，直接按照传进来的生成
	if nTaskNum~=nil then
		nTaskId = nTaskNum;
	end;
	
	if nTaskId==0 then
		self:_Debug("AddScroll: Select task id error!");
		return;
	end;
	
	local pItem = me.AddScriptItem(self.tbItemId[2], self.tbItemId[3], 1, 0, {nTaskId}, 0);
	
	if pItem==nil then
		self:_Debug("Add scroll item error!");
		return;
	end;
	
end;

-- 检查一个玩家身上是否正在进行卷轴任务
function ScrollTask:HaveScrollTask()
	local tbTask  = nil;
	
	tbTask = Task:GetPlayerTask(me).tbTasks[self.nMainTaskId];
	if tbTask ~= nil then
		return tbTask.tbReferData;
	end;

	return nil;
end;



function ScrollTask:GetTaskInfo(nTaskId)
	local szInfo = Task.tbReferDatas[nTaskId].tbDesc.szMainDesc;
	if szInfo=="" then
		return "无法获取任务描述！";
	end;
	return szInfo;
end;


function ScrollTask:GetTaskAwardText(nTaskId)
	local tbAwards	= Task:GetAwardsForMe(nTaskId);
	local szAwardMain = "";
	
	local tbFix, tbRandom;
	
	-- 固定奖励
	if (tbAwards.tbFix and #tbAwards.tbFix > 0) then
		szAwardMain = szAwardMain.."<color=yellow>固定奖励<color><enter>";
		for _, tbFix in ipairs(tbAwards.tbFix) do
			szAwardMain = szAwardMain..tbFix.szDesc.."<enter>";
		end;
		szAwardMain = szAwardMain.."<enter>";
	end;

	-- 随机奖励
	if (tbAwards.tbRand and #tbAwards.tbRand > 0) then
		szAwardMain = szAwardMain.."<color=yellow>随机奖励<color><enter>";
		for _, tbRandom in ipairs(tbAwards.tbRand) do
			szAwardMain = szAwardMain.."<color=green>"..tbRandom.szDesc.."<color>   "..tbRandom.nRate.."% 的概率<enter>";
		end;
		szAwardMain = szAwardMain.."<enter>";
	end;
	
	return szAwardMain;
end;


function ScrollTask:_Debug(szMsg)
	print ("[ScrollTask]: "..szMsg);
end;

-- ScrollTask:OnInit();
