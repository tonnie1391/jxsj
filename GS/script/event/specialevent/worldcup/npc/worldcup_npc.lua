-- 文件名　：worldcup_npc.lua
-- 创建者　：furuilei
-- 创建时间：2010-05-17 17:36:59
-- 功能描述：世界杯npc

SpecialEvent.tbWroldCup = SpecialEvent.tbWroldCup or {};
local tbEvent = SpecialEvent.tbWroldCup;

local tbNpc = tbEvent.tbNpc or {};
tbEvent.tbNpc = tbNpc;

function tbNpc:OnDialog()
	local szMsg = "2010年盛夏活动的事宜。";
	local tbOpt = {};
	table.insert(tbOpt, {"答题", self.QADlg, self});
	table.insert(tbOpt, {"回收卡册", self.RecycleDlg, self});
	table.insert(tbOpt, {"领取卡册", self.GetCardColloctionDlg, self});
	table.insert(tbOpt, {"领取排名奖励", self.GetScoreAwardDlg, self});
	table.insert(tbOpt, {"Để ta suy nghĩ lại"});
	Dialog:Say(szMsg, tbOpt);
end

-- 答题对话
function tbNpc:QADlg()
	if (tbEvent:GetOpenState() ~= 1) then
		Dialog:Say("现在没在活动期间，盛夏答题暂不开放。");
		return;
	end
	
	local szMsg = "我有几个关于世界杯的知识要考考你，答对有奖，答错没有啊！！另外，每人每天只有3次机会，一定要谨慎答题啊！";
	local tbOpt = {};
	table.insert(tbOpt, {"我要开始答题", self.AskQuestion, self});
	table.insert(tbOpt, {"Để ta suy nghĩ lại"});
	Dialog:Say(szMsg, tbOpt);
end

-- 回收卡册对话
function tbNpc:RecycleDlg()
	local nCurState = tbEvent:GetOpenState();
	if (tbEvent:GetOpenState() < 2) then
		Dialog:Say("活动还没有结束，卡册回收功能暂不开放。");
		return;
	end
	local szMsg = "在盛夏活动结束之后，可以把卡册交还给我，我会根据卡册的价值给予你们一定的奖励。";
	local tbOpt = {};
	table.insert(tbOpt, {"上交卡册", self.Recycle, self});
	table.insert(tbOpt, {"Để ta suy nghĩ lại"});
	Dialog:Say(szMsg, tbOpt);
end

-- 领取卡片收集册对话
function tbNpc:GetCardColloctionDlg()
	if (tbEvent:CheckOpenState() == 0) then
		Dialog:Say("活动已经结束，不要再来领取卡册了。");
		return;
	end
	
	local szMsg = "如果你的卡片收集册丢失了，你可以在我这里重新领取一个。";
	local tbOpt = {};
	table.insert(tbOpt, {"领取卡册", self.GetCardColloction, self});
	table.insert(tbOpt, {"Để ta suy nghĩ lại"});
	Dialog:Say(szMsg, tbOpt);
end

-- 领取积分奖励的对话
function tbNpc:GetScoreAwardDlg()
	local nCurState = tbEvent:GetOpenState();
	if (nCurState < 2) then
		Dialog:Say("活动还没有结束，排名奖励还不能发放。");
		return;
	end
	if (nCurState >= 3) then
		Dialog:Say("奖励发放时间已经过了，现在不在发放奖励。");
		return;
	end
	
	local szMsg = "如果你已经积攒了足够的积分，可以在我这里兑换相应的奖励。";
	local tbOpt = {};
	table.insert(tbOpt, {"领取奖励", self.GetScoreAward, self});
	table.insert(tbOpt, {"Để ta suy nghĩ lại"});
	Dialog:Say(szMsg, tbOpt);	
end

-- 领取积分奖励
function tbNpc:GetScoreAward()
	local nCurDate = tonumber(os.date("%Y%m%d", GetTime()));
	if (nCurDate < tbEvent.TIME_END) then
		Dialog:Say("盛夏活动还没有结束，不能兑换积分奖励。");
		return 0;		
	end
	
	if (nCurDate > tbEvent.TIME_END_SCORE_AWARD) then
		Dialog:Say("盛夏活动积分兑换奖励活动已经结束，现在不能兑换。");
		return 0;
	end
	
	tbEvent:GetScoreAward();
end

-- 领取卡册
function tbNpc:GetCardColloction()
	tbEvent:GetCardCollection();
end

-- 回收卡册
function tbNpc:Recycle()
	local nCurDate = tonumber(os.date("%Y%m%d", GetTime()));
	if (nCurDate < tbEvent.TIME_END) then
		Dialog:Say("盛夏活动还没有结束，不能上交卡册。");
		return 0;		
	end
	
	tbEvent:RecycleCardCollection();
end

-- 检查一个玩家是不是有资格进行答题
function tbNpc:CheckCanQA()
	local szErrMsg = "";
	local nCurDate = tonumber(os.date("%Y%m%d", GetTime()));
	
	if (nCurDate < tbEvent.TIME_START or nCurDate > tbEvent.TIME_END) then
		szErrMsg = "活动已经结束，不能再答题了。";
		return 0, szErrMsg;
	end
	
	local nBeforDate = me.GetTask(tbEvent.TASK_GROUP, tbEvent.TASKID_DATE_LASTQA);
	if (nCurDate > nBeforDate) then
		me.SetTask(tbEvent.TASK_GROUP, tbEvent.TASKID_DATE_LASTQA, nCurDate);
		me.SetTask(tbEvent.TASK_GROUP, tbEvent.TASKID_NUM_TODAYQA, 0);	
		return 1;
	end
	
	if (nCurDate == nBeforDate) then
		local nTodayNum = me.GetTask(tbEvent.TASK_GROUP, tbEvent.TASKID_NUM_TODAYQA);
		if (nTodayNum < tbEvent.MAX_TIME_PERDAYQA) then
			return 1;
		else
			szErrMsg = "很抱歉，你今天的答题机会已经用完。";
			return 0, szErrMsg;
		end
	end
	
	if (nCurDate < nBeforDate) then
		return 0;
	end
end

function tbNpc:AskQuestion()
	if (me.GetTask(tbEvent.TASK_GROUP, tbEvent.TASKID_FLAG_QAAWARD) == 1) then
		self:GetLastAwardDlg();
		return;
	end
	
	local bCanQA, szErrMsg = self:CheckCanQA();
	if (not bCanQA or 0 == bCanQA) then
		local szMsg = "条件不符，不能答题。请确认你是否符合答题条件。";
		if (szErrMsg and szErrMsg ~= "") then
			szMsg = szErrMsg;
		end
		Dialog:Say(szMsg);
		return;
	end
	
	local nTodayNum = me.GetTask(tbEvent.TASK_GROUP, tbEvent.TASKID_NUM_TODAYQA) + 1;
	if (nTodayNum > tbEvent.MAX_TIME_PERDAYQA) then
		nTodayNum = tbEvent.MAX_TIME_PERDAYQA;
	end
	me.SetTask(tbEvent.TASK_GROUP, tbEvent.TASKID_NUM_TODAYQA, nTodayNum);
	
	Question:Ask_Smash(1, 6, "SpecialEvent.tbWroldCup.tbNpc:AnswerCallBack");
end

-- 获取上一层的答题奖励
function tbNpc:GetLastAwardDlg()
	local szMsg = "您上次的答题奖励还没有领取，请先领取奖励再答题吧。";
	local tbOpt = {
		{"领取奖励", self.GetLastAward, self},
		{"以后再来"},
		};
	Dialog:Say(szMsg, tbOpt);
end

-- 获取上一层的答题奖励
function tbNpc:GetLastAward()
	if (me.CountFreeBagCell() < 1) then
		me.Msg("请清理出<color=yellow>1<color>格包裹空间再来领取答题奖励吧。");
		return;
	end
	
	local pItem = me.AddItem(18, 1, 658, 1);
	if (pItem) then
		pItem.Bind(1);
		me.SetItemTimeout(pItem, tbEvent.TIME_OUT_DATE, 0);
		me.SetTask(tbEvent.TASK_GROUP, tbEvent.TASKID_FLAG_QAAWARD, 0);
	end
end

function tbNpc:AnswerCallBack(nRet)
	if (not nRet) then
		return;
	end
	
	local nTodayNum = me.GetTask(tbEvent.TASK_GROUP, tbEvent.TASKID_NUM_TODAYQA);
	local nRemainNum = tbEvent.MAX_TIME_PERDAYQA - nTodayNum;
	if (0 == nRet) then
		local szMsg = string.format("很抱歉地通知您，这次答题错误。您今天还有<color=yellow>%s<color>次答题机会。答题请谨慎！", nRemainNum);
		Dialog:Say(szMsg);
		return;
	end
	
	if (1 == nRet) then
		local szMsg = string.format("很恭喜您，本轮答题全部正确。您今天还有<color=yellow>%s<color>次答题机会。", nRemainNum);
		Dialog:Say(szMsg);
		self:GiveAward();
		return;
	end
end

function tbNpc:GiveAward()
	if (me.CountFreeBagCell() < 1) then
		me.Msg("请清理出<color=yellow>1<color>格包裹空间再来领取答题奖励吧。");
		me.SetTask(tbEvent.TASK_GROUP, tbEvent.TASKID_FLAG_QAAWARD, 1);
		return 0;
	end
	
	local pItem = me.AddItem(18, 1, 658, 1);
	if (pItem) then
		pItem.Bind(1);
		me.SetItemTimeout(pItem, tbEvent.TIME_OUT_DATE, 0);
	end
	
	local szLog = "通过盛夏答题，得到随机卡片1张";
	Dbg:WriteLog("2010盛夏活动", me.szName, szLog);
	return 1;
end
