
-- ====================== 文件信息 ======================

-- 剑侠世界任务链头文件（第二版）
-- Edited by peres
-- 2007/12/25 PM 00:00 圣诞节前夜

-- 很多事情不需要预测
-- 预测会带来犹豫
-- 因为心里会有恐惧

-- ======================================================

Require("\\script\\task\\linktask\\linktask_file.lua");
Require("\\script\\task\\linktask\\linktask_award.lua");
Require("\\script\\lib\\gift.lua");

-- 任务ID
LinkTask.TSKG_LINKTASK		= 6;  -- 整个任务链的任务组 ID

LinkTask.TSK_TASKNUM		= 1;  -- 任务进行次数
LinkTask.TSK_TASKOPEN		= 2;  -- 是否接受正式开始任务
LinkTask.TSK_CANCELNUM		= 3;  -- 取消任务的次数
LinkTask.TSK_CANCELTIME		= 4;  -- 取消任务的时间记录
LinkTask.TSK_CONTAIN		= 5;  -- 取消任务的容忍次数

LinkTask.TSK_TASKID			= 6;  -- 记录当前接任务的ID，表格内指定
LinkTask.TSK_TASKTYPE		= 7;  -- 记录当前接任务的类型

LinkTask.TSK_TASKTEXT		= 8;  -- 记录任务的文字索引号

LinkTask.TSK_DATE			= 9;  -- 记录完成任务的日期
LinkTask.TSK_NUM_PERDAY		= 10; -- 记录每日完成任务的数量

LinkTask.TSK_AWARDSAVE		= 11;  -- 记录领奖中断状态
LinkTask.TSK_RANDOMSEED		= 12; -- 记录奖励时的随机种子

LinkTask.TSK_LINKAWARDDATE	= 13; -- 记录领取链奖励的日期，即使取消了任务也不能重复领
LinkTask.TSK_TOTALNUM_PERDAY= 14; -- 记录每天完成任务的总量
LinkTask.TSK_TOTAL_10_TIMTES	= 15; -- 记录一天共有个连续10次

LinkTask.TSK_EX_MONEY_20		= 20;
LinkTask.TSK_EX_MONEY_30		= 21;
LinkTask.TSK_EX_MONEY_40		= 22;
LinkTask.TSK_EX_MONEY_50		= 23;

LinkTask.AWARDED_WEIWANG 			= 101;  --记录通过老包总共已经获取了多少威望的任务变量ID

-- 额外金钱记录的变量组
LinkTask.tbExMoneyAward			= {
		[20] = LinkTask.TSK_EX_MONEY_20,
		[30] = LinkTask.TSK_EX_MONEY_30,
		[40] = LinkTask.TSK_EX_MONEY_40,
		[50] = LinkTask.TSK_EX_MONEY_50,
	}

-- 常量
LinkTask.CONTAIN_LIMIT   = 3;    -- 最大容忍次数
LinkTask.PAUSE_TIME      = 300;  -- 任务暂停不能接的时间（秒）

LinkTask.PERDAY_NUM_MAX	= 50;	-- 每天最多可以做 50 次，包括取消

LinkTask.MAX_AWARDED_WEIWANG = 60;  -- 通过老包最多可以获得多少威望

-- 给予界面实例
LinkTask.tbGiftDialog = Gift:New();
LinkTask.tbGiftDialog._szTitle = "给予物品";

LinkTask.tbBillDialog	= Gift:New();
LinkTask.tbBillDialog.szTitle = "银票兑换";

LinkTask.TSKGID				= 2015;
LinkTask.TSK_LIMITWEIWANG	= 1;
LinkTask.LIMITWEIWANG		= 30;
LinkTask.JINGLI				= 250;
LinkTask.HUOLI				= 250;

LinkTask.TSK_RANDOMNUMBER	= {1001,1002,1003,1004,1005,1006,1007,1008,1009}; -- 记录奖励时的随机数3个

-- 初始化表格文件以及任务数据
function LinkTask:OnInit()
--	self:InitFile();
end;

LinkTask:OnInit();
LinkTask:InitAward();

-- 确定玩家属于哪个任务等级段
function LinkTask:SelectLevelGroup()
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
end;

-- 随机选择一个任务，返回这个任务的编号
function LinkTask:SelectTask()

	local nLevelGroup = self:SelectLevelGroup();
	local nTypeRow = self.tbfile_TaskType:CountRate("Level"..nLevelGroup);
	
	if nTypeRow<1 then
		self:_Debug("Select task type error!");
		return
	end;
	
	local nType = self.tbfile_TaskType:GetCellInt("TypeId", nTypeRow);
	
	self:_Debug("Task level group: "..nLevelGroup);
	self:_Debug("Select task type: "..nType);
	
	-- 各个相对应的任务表
	local tbTask = {};
	
	tbTask = self.tbfile_SubTask[nType];

	local nTaskRow = 0;
	--  打怪任务只随机本服的地图
	if (nType == 20000) then
		nTaskRow = tbTask:CountRateWithMap("Level"..nLevelGroup);
	end
	
	if (nTaskRow < 1) then
		nTaskRow = tbTask:CountRate("Level"..nLevelGroup);
	end
	
	
	
	if nTaskRow<1 then
		self:_Debug("Select task row error!");
		return
	end;
	
	local nTaskId  = tbTask:GetCellInt("TaskId", nTaskRow);
		
		self:_Debug("Select a task Id: "..nTaskId);
	
	-- 储存任务类型和行数在玩家变量里
	self:SetTask(self.TSK_TASKID, nTaskId);
	self:SetTask(self.TSK_TASKTYPE, nType);
	
	-- 选择一个任务文字描述
	self:SetTaskText(me, nType);
	
	self:_Debug("Select task return ", nType, nTaskId);
	return nType, nTaskId;
end;

-- 给玩家开始一个任务
function LinkTask:StartTask()
	
	-- 每天固定次数的限制
	local nTotalNum	= self:GetTaskTotalNum_PerDay();
	
	if nTotalNum >= self.PERDAY_NUM_MAX then
		return 0, 0;
	end;
	
	local nTaskType, nSubTaskId = self:SelectTask();
	local tbTask 	= Task:GetPlayerTask(me).tbTasks[nTaskType];
	
	-- 如果当前玩家已经有了这个主任务，则应该关掉，避免加不上任务的情况
	Task:CloseTask(nTaskType, "linktask_finish");

	self:_Debug("Start Task: "..nTaskType..", "..nSubTaskId);
	
	local tbTask = Task:DoAccept(nTaskType, nSubTaskId);
	if (not tbTask) then
		return;
	end
	
	return nTaskType, nSubTaskId;
end;


-- 正式开始任务链，不可逆
function LinkTask:Open()
	
	self:SetTask(self.TSK_TASKOPEN, 1);
	
	-- 清空所有的任务数据
	self:SetTask(self.TSK_TASKNUM, 0);
	self:SetTask(self.TSK_CANCELNUM, 0);
	self:SetTask(self.TSK_CANCELTIME, 0);
	self:SetTask(self.TSK_CONTAIN, 0);
	self:SetTask(self.TSK_TASKID, 0);
	self:SetTask(self.TSK_TASKTYPE, 0);
	self:SetTask(self.TSK_TASKTEXT, 0);
	self:SetTask(self.TSK_DATE, 0);
	self:SetTask(self.TSK_NUM_PERDAY, 0);
	self:SetTask(self.TSK_AWARDSAVE, 0);
	self:SetTask(self.TSK_RANDOMSEED, 0);
	self:SetTask(self.TSK_TOTALNUM_PERDAY, 0);
	self:SetTask(self.TSK_TOTAL_10_TIMTES, 0);

end;


-- 把任务总数和每天完成的任务次数 +1
function LinkTask:AddTaskNum()
	local nTaskNum = self:GetTask(self.TSK_TASKNUM);
	
	nTaskNum = nTaskNum + 1;

	self:SetTask(self.TSK_TASKNUM, nTaskNum);
	
	-- 给每天完成的次数 + 1;
	self:AddTaskNum_PerDay();	
end;


-- 给每天完成的任务次数 +1
function LinkTask:AddTaskNum_PerDay()
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));  -- 获取日期：XXXX/XX/XX 格式
	local nOldDate = self:GetTask(self.TSK_DATE);
	local nNum = self:GetTaskNum_PerDay();
	local nTotalNum = self:GetTaskTotalNum_PerDay();
	-- 计算一天内连续10次任务的个数
	local n10TimesNum = self:GetTask(self.TSK_TOTAL_10_TIMTES);
	
	if nNowDate~=nOldDate then
		nNum 	= 0;
		nTotalNum = 0;
		n10TimesNum = 0;
		
		-- 清空阶段性金钱奖励
		self:SetTask(self.TSK_LINKAWARDDATE, 0);
		
		for i, j in pairs(self.tbExMoneyAward) do
			self:SetTask(self.tbExMoneyAward[i], 0);
		end;
				
	end;
	
	nNum = nNum + 1;
	nTotalNum = nTotalNum + 1;

	self:SetTask(self.TSK_DATE, nNowDate);	
	self:SetTaskNum_PerDay(nNum);
	-- 记录当天完成任务的总数
	self:SetTaskTotalNum_PerDay(nTotalNum);

	local n10Flag = math.fmod(nNum, 10);
	if (0 == n10Flag) then
		n10TimesNum = n10TimesNum + 1;
		self:SetTask(self.TSK_TOTAL_10_TIMTES, n10TimesNum);
	end
	
	-- 记录玩家完成义军任务的次数
	Stats.Activity:AddCount(me, Stats.TASK_COUNT_YIJUN, 1);

	-- 记录每天完成的最大次数
	--KStatLog.ModifyMax("LinkTask", me.szName, "当天连续完成任务链最大次数", nNum);
end;


-- 检查每天的任务是否过期，清除任务数量
function LinkTask:CheckPerDayTask()
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));  -- 获取日期：XXXX/XX/XX 格式
	local nOldDate = self:GetTask(self.TSK_DATE);
	local nNum = self:GetTaskNum_PerDay();
	local nTotalNum = self:GetTaskTotalNum_PerDay();
	local n10TimesNum = self:GetTask10TimesNum_PerDay();
	
	if nNowDate~=nOldDate then
		nNum = 0;
		nTotalNum = 0;
		n10TimesNum = 0;

		-- 清空阶段性金钱奖励
		self:SetTask(self.TSK_LINKAWARDDATE, 0);
		
		-- 清空阶段性金钱奖励
		for i, j in pairs(self.tbExMoneyAward) do
			self:SetTask(self.tbExMoneyAward[i], 0);
		end;
	end;
	
	self:SetTask(self.TSK_DATE, nNowDate);	
	self:SetTaskNum_PerDay(nNum);
	-- 记录当天完成任务的总数
	self:SetTaskTotalNum_PerDay(nTotalNum);
	self:SetTask10TimesNum_PerDay(n10TimesNum);
end;


-- 获取当前已经做了多少次任务
function LinkTask:GetTaskNum()
	return self:GetTask(self.TSK_TASKNUM);
end;

-- 获取每天完成的连续10次任务的数量
function LinkTask:GetTask10TimesNum_PerDay()
	return self:GetTask(self.TSK_TOTAL_10_TIMTES);
end

-- 获取每天完成任务的总数量
function LinkTask:GetTaskTotalNum_PerDay()
	return self:GetTask(self.TSK_TOTALNUM_PERDAY);
end;

-- 设置做了多少次任务
function LinkTask:SetTaskNum(nNum)
	self:SetTask(self.TSK_TASKNUM, nNum);
end;

-- 获取每天完成的任务数量
function LinkTask:GetTaskNum_PerDay()
	return self:GetTask(self.TSK_NUM_PERDAY);
end;

-- 设置每天完成任务的数量
function LinkTask:SetTaskNum_PerDay(nNum)
	self:SetTask(self.TSK_NUM_PERDAY, nNum);
end;

-- 设置每天完成任务的总数量
function LinkTask:SetTaskTotalNum_PerDay(nNum)
	self:SetTask(self.TSK_TOTALNUM_PERDAY, nNum);
end;

-- 记录一天中连续10次的个数
function LinkTask:SetTask10TimesNum_PerDay(num)
	self:SetTask(self.TSK_TOTAL_10_TIMTES, num);
end 

function LinkTask:SetTask(nTaskId, nValue)
	me.SetTask(self.TSKG_LINKTASK, nTaskId, nValue);
end;

function LinkTask:GetTask(nTaskId)
	return me.GetTask(self.TSKG_LINKTASK, nTaskId);
end;


-- 检测任务除了交物品任务之外还有没有未完成的目标
function LinkTask:CheckTaskFinish()
	local nTaskType		= LinkTask:GetTask(LinkTask.TSK_TASKTYPE);
	local tbTask	 	= Task:GetPlayerTask(me).tbTasks[nTaskType];
	
	-- 还有未完成的目标
	for _, tbCurTag in pairs(tbTask.tbCurTags) do
		if (not tbCurTag:IsDone()) then
			self:_Debug("Check task state: underway  Tags Name: "..tbCurTag.szTargetName);
			return 0;
		end;
	end;
	
	-- 全部目标完成
	return 1;
end;

-- 检测任务里是否有收集物品任务
function LinkTask:CheckHaveItemTarget()
	local nSubTaskId	= self:GetTask(self.TSK_TASKID);
	local tbTaget		= Task.tbSubDatas[nSubTaskId].tbSteps[1].tbTargets[1];
	local szTargetName	= tbTaget.szTargetName; -- 得到这个目标的名字
	
	if szTargetName == "SearchItemWithDesc" or szTargetName == "SearchItemBySuffix" then
		return 1;
	else
		return 0;
	end;
end;

-- 给与界面的处理
function LinkTask:ShowGiftDialog()
	-- 在这里获取任务所需的物品	
	Dialog:Gift("LinkTask.tbGiftDialog");
end;


function LinkTask.tbGiftDialog:OnUpdate()
--	local nSubTaskId	= me.GetTask(1,6);
--	local tbSubDatas	= Task.tbSubDatas[nSubTaskId];
--		if not tbSubDatas then
--			LinkTask.tbGiftDialog._szContent = "<color=red>客户端错误，无任务数据，请升级客户端！<color>";
--			return;
--		end;
--	local tbTaget		= tbSubDatas.tbSteps[1].tbTargets[1];
--		if not tbTargets then
--			LinkTask.tbGiftDialog._szContent = "<color=red>客户端错误，无任务目标数据，请升级客户端！<color>";
--			return;
--		end;
--	local szNeed		= "<color=yellow>"..tbTaget.nNeedCount.."个"..tbTaget.szItemName.."<color>";
--	local szMain		= "请把我需要的"..szNeed.."放到这里来吧！";
	
	LinkTask.tbGiftDialog._szContent	= "请把我需要的物品放到这里来吧！";

end;


function LinkTask.tbGiftDialog:OnOK()
	local nSubTaskId	= LinkTask:GetTask(LinkTask.TSK_TASKID);
	local tbTaget		= Task.tbSubDatas[nSubTaskId].tbSteps[1].tbTargets[1];
	local szTargetName	= tbTaget.szTargetName;
	
	local pFind = LinkTask.tbGiftDialog:First();
	local tbNeed, tbNow, tbDelItem	= {}, {}, {};
	local nAccordNum	= 0;
	
	if szTargetName == "SearchItemWithDesc" then
		tbNeed.nGenre		= tbTaget.nGenre;
		tbNeed.nDetail		= tbTaget.nDetail;
		tbNeed.nParticular	= tbTaget.nParticular;
		tbNeed.nLevel		= tbTaget.nLevel;
		tbNeed.nSeries		= tbTaget.nFive;
		tbNeed.nNeedCount	= tbTaget.nNeedCount;
	elseif szTargetName == "SearchItemBySuffix" then
		tbNeed.szItemName	= tbTaget.szItemName;
		tbNeed.szSuffix		= tbTaget.szSuffix;
		tbNeed.nNeedCount	= tbTaget.nNeedCount;
	end;
	
	LinkTask:_Debug("Target need count: ", tbNeed.nNeedCount);
	
	if pFind==nil then
		Dialog:Say("你没放入任何物品！");
		tbDelItem = {};
		return;
	end;
	
	while pFind do
		
		if szTargetName == "SearchItemWithDesc" then
			tbNow.nGenre      = pFind.nGenre;
			tbNow.nDetail     = pFind.nDetail;
			tbNow.nParticular = pFind.nParticular;
			tbNow.nLevel      = pFind.nLevel;
			tbNow.nSeries     = pFind.nSeries;
			
			if (tbNow.nGenre == tbNeed.nGenre) and (tbNow.nDetail == tbNeed.nDetail) and (tbNow.nParticular == tbNeed.nParticular) and (tbNow.nLevel == tbNeed.nLevel) and (tbNow.nSeries == tbNeed.nSeries) then
				nAccordNum = nAccordNum + pFind.nCount;
				table.insert(tbDelItem, pFind);
			end;
			
		elseif szTargetName == "SearchItemBySuffix" then
			tbNow.szItemName	= pFind.szOrgName;
			tbNow.szSuffix		= pFind.szSuffix;
			
			LinkTask:_Debug("Get Name & Need Name: ", tbNow.szItemName, tbNow.szSuffix, " / ", tbNeed.szItemName, tbNeed.szSuffix);
			
			me.Msg(tbNow.szItemName .."-".. tbNeed.szItemName)
			me.Msg(tbNow.szSuffix .."-".. tbNeed.szSuffix)
			
			if (tbNow.szItemName == tbNeed.szItemName) and (tbNow.szSuffix == tbNeed.szSuffix) then
				nAccordNum = nAccordNum + pFind.nCount;
				table.insert(tbDelItem, pFind);
			end;
		end;
		pFind = LinkTask.tbGiftDialog:Next();
	end;
	
	if nAccordNum == tbNeed.nNeedCount then
		for i=1, #tbDelItem do
			if tbDelItem[i].Delete(me) ~= 1 then
				return ;
			end
		end;
		
		LinkTask:OnAward();
		
		return;
	else
		LinkTask:_Debug("Check item faile, get right count: "..nAccordNum.." , need: "..tbNeed.nNeedCount);
		
		Dialog:Say("Số lượng không khớp, hãy kiểm tra lại số lượng đã đúng chưa!");
		tbDelItem = {};
		return;
	end;
end;


-- 任务引擎直接调用的奖励函数
function LinkTask:OnAward()
	
	-- 将状态设置为开始发奖状态
	self:SetAwardState(1);
	
	local nFreeCell = me.CountFreeBagCell();
	local nTaskNum	= self:GetTaskNum_PerDay();
	local nFreeCount, tbExecute = SpecialEvent.ExtendAward:DoCheck("LinkTask", me, nTaskNum + 1);
	if nFreeCell < 6 + nFreeCount then
		Dialog:Say(string.format("请你把背包清理出<color=yellow> %s 格以上的空间<color>再来领取奖励吧！",(6 + nFreeCount)));
		return;
	end;
	
	-- 调用奖励函数发奖
	self:ShowAwardDialog(self:SelectAwardType());
end;

-- 保存奖励状态，以防玩家掉线不能领奖
function LinkTask:SetAwardState(nState)
	self:_Debug("Set Award State: "..nState);
	self:SetTask(self.TSK_AWARDSAVE, nState);
end;

function LinkTask:GetAwardState()
	return self:GetTask(self.TSK_AWARDSAVE);
end;

--修正为存储随机数，不是随机种子
function LinkTask:SaveRandomSeed(nRandom, nBit)
	me.SetTask(self.TSKGID, self.TSK_RANDOMNUMBER[nBit], nRandom or 0);
end;

function LinkTask:ClearRandomSeed()
	for _, nTask in pairs(self.TSK_RANDOMNUMBER) do
		me.SetTask(self.TSKGID, nTask, 0);
	end
end

--修正为存储随机数，不是随机种子
function LinkTask:GetRandomSeed(nBit)
	return me.GetTask(self.TSKGID, self.TSK_RANDOMNUMBER[nBit]);
end;

-- 发完奖的后续处理
function LinkTask:AwardFinish()
	
	-- 设置已经发完奖励，首先执行此语句以保证安全性
	self:SetAwardState(2);
		
	local nTaskType			= self:GetTask(LinkTask.TSK_TASKTYPE);
	local nTaskNum			= self:GetTaskNum_PerDay();
	local n10TimesNum		= self:GetTask10TimesNum_PerDay();
	
	local nDailyAward		= self:GetTask(self.TSK_LINKAWARDDATE);	
	local nNowDate			= tonumber(GetLocalDate("%Y%m%d"));

	local nTaskTotalNum		= self:GetTaskTotalNum_PerDay();
	local nAwardFlag		= math.fmod(nTaskNum + 1, 10);

	-- 每天完成的第一轮任务获得3点威望和200000心得
	if (0 == nAwardFlag and 0 == n10TimesNum and nDailyAward ~= nNowDate) then
		-- by zhangjinpin@kingsoft
		if me.nLevel < 80 then
			self:AwardWeiWang(2, 30);
		end
		-- end
		self:AwardXinDe(300000);
		me.AddItem(18,1,84,1);	-- 义军令牌
		
		-- 加任务用品，义军精英令牌
		if me.GetTask(1022, 116) == 1 and me.GetItemCountInBags(20, 1, 261, 1) == 0 then
			me.AddItem(20,1,261,1);
		end;
		
		-- 第一次 10 轮加黄金福袋 x 2，两天的保质期
		for i=1, 2 do
			local pItem = me.AddItem(18, 1, 80, 1);
		end;
				
		if (me.GetTrainingTeacher()) then	-- 如果玩家的身份是徒弟，并且完成了10次义军任务，那么师徒任务当中的义军任务次数加1
			-- local tbItem = Item:GetClass("teacher2student");
			local nNeed_YiJun = me.GetTask(Relation.TASK_GROUP, Relation.TASK_ID_SHITU_YIJUN) + 1;
			me.SetTask(Relation.TASK_GROUP, Relation.TASK_ID_SHITU_YIJUN, nNeed_YiJun);
		end
		
		-- 获取师徒成就：完成一轮包万同义军任务
		Achievement_ST:FinishAchievement(me.nId, Achievement_ST.YIJUN);
		
		DeRobot:OnFinishLinkTaskTurn();
	elseif (nAwardFlag == 0 and n10TimesNum > 0) then
		-- by zhangjinpin@kingsoft
		if me.nLevel < 80 then
			self:AwardWeiWang(0, 10);
		end
		-- end
		self:AwardXinDe(100000);
		
		-- 以后每一次 10 轮加一个黄金福袋
		local pItem = me.AddItem(18, 1, 80, 1);
		--me.SetItemTimeout(pItem, os.date("%Y/%m/%d/%H/%M/%S", GetTime() + 3600 * 24 * 2));
		DeRobot:OnFinishLinkTaskTurn();
	end
	
	local tbInfo = Kinsalary.EVENT_TYPE[Kinsalary.EVENT_YIJUN];
	Kinsalary:AddSalary_GS(me, Kinsalary.EVENT_YIJUN, tbInfo.nRate);
	
	local nFreeCount, tbExecute = SpecialEvent.ExtendAward:DoCheck("LinkTask", me, nTaskNum + 1);
	SpecialEvent.ExtendAward:DoExecute(tbExecute);
	
	--完成一轮义军任务
	SpecialEvent.tbGoldBar:AddTask(me, 2);		--金牌联赛义军任务
	
	-- 写入领取链奖励的日期
	if nTaskNum == 9 then
		
		self:SetTask(self.TSK_LINKAWARDDATE, tonumber(GetLocalDate("%Y%m%d")));
		
	elseif nTaskNum > 10 and math.fmod(nTaskNum + 1, 10) == 0 then
		
		self:SetTask(self.tbExMoneyAward[nTaskNum + 1], 1);
		
	end;
	
	-- 用于修改老玩家召回任务变量修改
	Task.OldPlayerTask:AddPlayerTaskValue(me.nId, 2082, 1);	
	
	-- 次数 +1
	self:AddTaskNum();

	-- 将容忍次数清零
	self:SetTask(self.TSK_CONTAIN, 0);
	
	self:ClearRandomSeed();
	Task:CloseTask(nTaskType, "linktask_finish");
	
	SpecialEvent.ActiveGift:AddCounts(me, 8);		--一轮老包活跃度
	-- 记录完成次数
	--KStatLog.ModifyAdd("LinkTask", me.szName, "当天完成任务链次数", 1);
	--KStatLog.ModifyAdd("RoleDailyEvent", me.szName, "当天完成任务链次数", 1);
	
	SpecialEvent.BuyOver:AddCounts(me, SpecialEvent.BuyOver.TASK_BAOVANDONG);
end;


function LinkTask:AwardShengWang(nShengWang)
	me.AddRepute(1, 1, nShengWang);
end


function LinkTask:AwardWeiWang(nWeiWang, nGongXian)
	local nAwardedWeiWang = me.GetTask(self.TSKG_LINKTASK, self.AWARDED_WEIWANG);
	if nWeiWang + nAwardedWeiWang > self.MAX_AWARDED_WEIWANG then
		nWeiWang = self.MAX_AWARDED_WEIWANG - nAwardedWeiWang;
	end
	if nWeiWang <= 0 then
		return;
	end
	me.AddKinReputeEntry(nWeiWang, "linktask");
	me.SetTask(self.TSKG_LINKTASK, self.AWARDED_WEIWANG, nWeiWang + nAwardedWeiWang);
end

function LinkTask:AwardXinDe(nXinDe)
	if (nXinDe <= 0) then
		return;
	end
	local pPlayer = me;
	Setting:SetGlobalObj(pPlayer);
	Task:AddInsight(nXinDe);
	Setting:RestoreGlobalObj();
end

function LinkTask:AwardJingHuo()
	local nEffect	= Player:GetLevelEffect(me.nLevel);
	local nJing = math.floor(self.JINGLI * nEffect);
	local nHuo 	= math.floor(self.HUOLI * nEffect);
	return nJing, nHuo ; -- 活力
end


-- 取消任务
function LinkTask:Cancel()
	local nTaskType		= LinkTask:GetTask(LinkTask.TSK_TASKTYPE);
	
	local nCancel = self:GetTask(self.TSK_CANCELNUM);
	local nContain = self:GetTask(self.TSK_CONTAIN);
	
	if nCancel>=1 then
		nCancel = nCancel - 1;
		self:SetTask(self.TSK_CANCELNUM, nCancel);
		
		-- 使用任务引擎的放弃机制
		Task:CloseTask(nTaskType, "giveup");
		me.Msg("您使用了一次取消机会来取消任务！您现在的取消机会为：<color=yellow>"..nCancel.."<color>");
	else
		-- 如果没有取消机会的情况下取消，总任务数清 0
		self:SetTaskNum(0);
		self:SetTaskNum_PerDay(0);
		
		nContain = nContain + 1;
		self:SetTask(self.TSK_CONTAIN, nContain);
		Task:CloseTask(nTaskType, "giveup");
		
		me.Msg("<color=yellow>你在没有取消机会的情况下取消了任务，任务总数清空<color>！");
		
		if nContain >= self.CONTAIN_LIMIT then
			self:Pause();
			return 1;
		end;
	end;
	
	return 0;

end;

-- 超过容忍次数，任务暂停，并清空任务
function LinkTask:Pause()
	local nNowTime = me.nOnlineTime;
	self:SetTask(self.TSK_CANCELTIME, nNowTime);
	self:SetTaskNum(0);
	self:SetTaskNum_PerDay(0);
	me.Msg("您取消任务已经超过"..self.CONTAIN_LIMIT.."次，还是休息一下吧！");
end;




-- 返回任务的价值量，返回值为 TABLE，{Value1, Value2}
function LinkTask:GetTaskValue()
	local nSubTaskId	= self:GetTask(self.TSK_TASKID);
	local nTaskType		= self:GetTask(LinkTask.TSK_TASKTYPE);
	local tbTask  = 0;
	
	if nTaskType>0 then
		tbTask = self.tbfile_SubTask[nTaskType];
	else
		self:_Debug("function:GetTaskValue  Get Type Error!");
		return {0, 0};
	end;
	
	local nTaskRow = tbTask:GetDateRow("TaskId", nSubTaskId);
	local nTaskValue1 = tbTask:GetCellInt("Value1", nTaskRow);
	local nTaskValue2 = tbTask:GetCellInt("Value2", nTaskRow);
	
	if not nTaskValue1  or not nTaskValue2 then
		return {0, 0};
	end
		
	self:_Debug("Get task value: "..nTaskValue1.." / "..nTaskValue2);
	return {nTaskValue1, nTaskValue2};
end;



-- ====================== 组队相关函数 ======================

-- 当队长共享时，队员所显示的对话框
function LinkTask:Team_ShowTaskInfo(pPlayer, szCaptainName, nTaskType, nSubTaskId)
	local szTaskName	= Task.tbSubDatas[nSubTaskId].szName;
	
	Dialog:Say(
			"你所在队伍的队长<color=yellow>"..szCaptainName.."<color>想要与你共享义军任务：<color=green>"..szTaskName.."<color>，你愿意接受吗？",
			{
				{"是", LinkTask.Team_AcceptTask, LinkTask, pPlayer, szCaptainName, nTaskType, nSubTaskId},
				{"否"},
			}
		);
end;


-- 这里的 ME 会不会有问题？？？
function LinkTask:Team_AcceptTask(pPlayer, szCaptainName, nTaskType, nSubTaskId)

--	print ("Team get task: "..me.szName, pPlayer.szName);
	-- 如果当前玩家已经有了这个主任务，则应该关掉，避免加不上任务的情况
	Task:CloseTask(nTaskType, "linktask_finish");

	self:_Debug("Start Task: "..nTaskType..", "..nSubTaskId);
	
	local tbTask = Task:DoAccept(nTaskType, nSubTaskId);
	if (not tbTask) then
		return;
	end
	
--	print ("LinkTask get param: ", szCaptainName, nTaskType, nSubTaskId);
	
	-- 储存任务类型和行数在玩家变量里
	pPlayer.SetTask(LinkTask.TSKG_LINKTASK, LinkTask.TSK_TASKTYPE, nTaskType);	
	pPlayer.SetTask(LinkTask.TSKG_LINKTASK, LinkTask.TSK_TASKID, nSubTaskId);
	
	LinkTask:SetTaskText(pPlayer, nTaskType);
	
end;



-- 义军银票兑换过程

-- 给与界面的处理
function LinkTask:ShowBillGiftDialog(nNpcId)
	
	if not nNpcId then nNpcId = 0; end;
	LinkTask.tbBillDialog.nNpcId	= nNpcId;
	-- 在这里获取任务所需的物品	
	Dialog:Gift("LinkTask.tbBillDialog");
end;

function LinkTask.tbBillDialog:OnUpdate()
	local nAvailablyDay = me.GetTask(2057, 1);
	local nToday = tonumber(os.date("%Y%m%d", GetTime()));
	if (nAvailablyDay >= nToday) then
		local nYear = math.floor(nAvailablyDay / 10000);
		local nMonth = math.floor(nAvailablyDay % 10000 / 100);
		local nDay = math.floor(nAvailablyDay % 100);
		LinkTask.tbBillDialog._szContent	= "请将银票放进这里，一次可以放入多张银票。\n\n截至到<color=yellow>"..nYear.."年"..nMonth.."月"..nDay.."<color>日，可以到义军军需官那里直接兑换银票。";
	else
		LinkTask.tbBillDialog._szContent	= "请将银票放进这里，一次可以放入多张银票。";
	end 
end;

function LinkTask.tbBillDialog:OnOK()
	local pFind = LinkTask.tbBillDialog:First();
	local tbDelItem = {};
	local nBillCount = 0; -- 一共有多少张银票
	
	if pFind==nil then
		Dialog:Say("你没放入任何物品！");
		tbDelItem = {};
		return;
	end;
	
	while pFind do
		
		if pFind.nGenre == 18 and pFind.nDetail == 1 and pFind.nParticular == 262 then
			nBillCount = nBillCount + pFind.nCount;
			table.insert(tbDelItem, pFind);
		else
			Dialog:Say("我这里只能兑换银票哦，你看看是不是多放了些别的什么东西？");
			tbDelItem = {};
			return;
		end;	
		pFind = LinkTask.tbBillDialog:Next();
	end;

	for i=1, #tbDelItem do
		if tbDelItem[i].Delete(me) ~= 1 then
			-- 删除银票出错直接返回，不发钱了
			tbDelItem = {};
			nBillCount = 0;
			return ;
		end
	end;
	
	-- 发钱
	for i=1, nBillCount do
		me.Earn( (10000 * LinkTask:_CountLevelProductivity()) / 2, Player.emKEARN_YIJUN );
	end;

	-- 累加变量
	if LinkTask.tbBillDialog.nNpcId ~=0 then
		local nLimit = BaiHuTang.tbGetAwardCount[LinkTask.tbBillDialog.nNpcId] or 0;
		nLimit = nLimit + 1;
		BaiHuTang.tbGetAwardCount[LinkTask.tbBillDialog.nNpcId] = nLimit;
	end;
end;