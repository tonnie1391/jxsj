-------------------------------------------------------
-- 文件名　：SeventhEvening_kuixing.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-07-22 19:14:21
-- 文件描述：
-------------------------------------------------------

local tbNpc = Npc:GetClass("QX_kuixing");
SpecialEvent.SeventhEvening = SpecialEvent.SeventhEvening or {};
local tbSeventhEvening = SpecialEvent.SeventhEvening;
tbSeventhEvening.Kuixing = tbNpc;

function tbNpc:CheckState()
	--return 1;
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	if nCurDate >= 20100822 and nCurDate <= 20100831 then
		return 1;
	elseif nCurDate >= 20100901 and nCurDate <= 20100907 then
		return 2;
	end
	return 0;
end

function tbNpc:OnDialog()
	
	if self:CheckState() <= 0 then
		Dialog:Say("魁星："..me.szName..", xin chào!");
		return 0;
	end

	local szMsg = "纤云弄巧，飞星传恨，银汉迢迢暗渡。金风玉露一相逢，便胜却人间无数。每年这个时候我都会下凡来到人间，许多人求我保佑他们考取功名，仕途坦荡。<enter>在8月22日-8月31日期间，侠客们可以找我来回答我国民俗相关的问题，答对7题的，可以获得我随机赠与的鹊桥仙诗册中的7个字。活动结束后一周之内，将集好的诗册交给我，可以换取丰硕的奖励。侠侣们可以组队由队长进行答题，答对7题的可获得浪漫的七夕烟花礼包。";
	local tbOpt = 
	{
		{"领取诗集", self.OnGetShiji, self},
		{"我要答题", self.OnQuestion, self},
		{"领取奖励", self.OnGetAward, self},
		{"Để ta suy nghĩ thêm"},
	};
	
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:OnGetShiji()
	if self:CheckState() ~= 1 then
		Dialog:Say("活动已经结束了！");
		return 0;
	end
	if me.GetTask(tbSeventhEvening.TASKID_GROUP, tbSeventhEvening.TASK_GET_SHIJI) == 1 then
		Dialog:Say("对不起，你已经领取过鹊桥仙诗集了。");
		return 0;
	end
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("请留出1格背包空间。");
		return 0;
	end
	local pItem = me.AddItem(unpack(tbSeventhEvening.tbShijiId));
	if pItem then
		local nSec = Lib:GetDate2Time(20100908);
		pItem.SetTimeOut(0, nSec);
		pItem.Sync();
		me.SetTask(tbSeventhEvening.TASKID_GROUP, tbSeventhEvening.TASK_GET_SHIJI, 1);
	end
end

function tbNpc:OnQuestion()
	
	if self:CheckState() ~= 1 then
		Dialog:Say("对不起，活动已经结束，无法参加问答。")
		return 0;
	end
	
	if me.GetTask(tbSeventhEvening.TASKID_GROUP, tbSeventhEvening.TASK_GET_SHIJI) ~= 1 then
		Dialog:Say("对不起，请先领取鹊桥仙诗集，并妥善保存。");
		return 0;
	end
	
	if me.GetTask(tbSeventhEvening.TASKID_GROUP, tbSeventhEvening.TASK_DAILY_QUESTION) == 1 then
		Dialog:Say("对不起，今天你已经答过题了。");
		return 0;
	end
	
	if me.nLevel < 60 then
		Dialog:Say("对不起，你的等级不满60级，无法参加问答。");
		return 0;
	end
	
	if me.nFaction <= 0 then
		Dialog:Say("对不起，你还没有加入门派，无法参加问答。");
		return 0;
	end
	
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("请留出1格背包空间，再来参加问答。");
		return 0;
	end
	
	local tbMemberList, nMemberCount = me.GetTeamMemberList(); 
	if tbMemberList and nMemberCount == 2 and Lib:CountTB(tbMemberList) == 2 then
		local pTeamMate = nil;
		for _, pMember in pairs(tbMemberList) do
			if pMember.szName ~= me.szName then
				pTeamMate = pMember;
			end
		end

		if pTeamMate and me.IsMarried() == 1 and pTeamMate.IsMarried() == 1 and me.GetCoupleName() == pTeamMate.szName then

			local nNearby = 0;
			local tbPlayerList = KPlayer.GetAroundPlayerList(me.nId, 50);
			if tbPlayerList then
				for _, pPlayer in ipairs(tbPlayerList) do
					if pPlayer.szName == pTeamMate.szName then
						nNearby = 1;
					end
				end
			end
			
			if nNearby ~= 1 then
				Dialog:Say("对不起，请你的侠侣来到你身边再一起答题。");
				return 0;
			end
			
			if pTeamMate.GetTask(tbSeventhEvening.TASKID_GROUP, tbSeventhEvening.TASK_GET_SHIJI) ~= 1 then
				Dialog:Say("对不起，请你的侠侣先领取鹊桥仙诗集，再来一起答题。");
				return 0;
			end
			
			if pTeamMate.GetTask(tbSeventhEvening.TASKID_GROUP, tbSeventhEvening.TASK_DAILY_QUESTION) == 1 then
				Dialog:Say("对不起，今天你的侠侣已经答过题了。");
				return 0;
			end
			
			if pTeamMate.nLevel < 60 then
				Dialog:Say("对不起，你的侠侣等级不满60级，无法参加问答。");
				return 0;
			end
			
			if pTeamMate.nFaction < 0 then
				Dialog:Say("对不起，你的侠侣还没有加入门派，无法参加问答。");
				return 0;
			end
			
			if pTeamMate.CountFreeBagCell() < 1 then
				Dialog:Say("请你的侠侣留出1格背包空间。");
				return 0;
			end
				
			me.Msg("你们是侠侣，可以组队共享答题成绩，答题过程中不可离开队伍,也不能离开他/她身边。");
			pTeamMate.Msg("你们是侠侣，可以共享答题成绩，答题过程中不可离开队伍,也不能离开他/她身边。");
			pTeamMate.SetTask(tbSeventhEvening.TASKID_GROUP, tbSeventhEvening.TASK_DAILY_QUESTION, 1);
		end
	end
	
	-- 设置任务变量
	me.SetTask(tbSeventhEvening.TASKID_GROUP, tbSeventhEvening.TASK_DAILY_QUESTION, 1);
	
	-- 开始答题
	Question:Ask_Stream(2, 7, "SpecialEvent.SeventhEvening.Kuixing:OnQuestionCallBack");	
end

function tbNpc:OnQuestionCallBack(nRet)
	
	if not nRet then
		return 0;
	end
	
	local pCouple = nil;
	local tbMemberList, nMemberCount = me.GetTeamMemberList();
	if tbMemberList and nMemberCount == 2 and Lib:CountTB(tbMemberList) == 2 then
		local pTeamMate = nil;
		for _, pMember in pairs(tbMemberList) do
			if pMember.szName ~= me.szName then
				pTeamMate = pMember;
			end
		end
		if pTeamMate and me.IsMarried() == 1 and pTeamMate.IsMarried() == 1 and me.GetCoupleName() == pTeamMate.szName then
			local nNearby = 0;
			local tbPlayerList = KPlayer.GetAroundPlayerList(me.nId, 50);
			if tbPlayerList then
				for _, pPlayer in ipairs(tbPlayerList) do
					if pPlayer.szName == pTeamMate.szName then
						nNearby = 1;
					end
				end
			end
			if nNearby == 1 then
				pCouple = pTeamMate;
			end
		end
	end
	
	if nRet == 7 then
		if me.FindTitle(unpack(tbSeventhEvening.tbKuixingTitleId)) == 0 then
			me.AddTitle(unpack(tbSeventhEvening.tbKuixingTitleId));
		end
		for i = 1, 7 do
			local nId = MathRandom(11, 66);
			me.SetTask(tbSeventhEvening.TASKID_GROUP, nId, 1);
		end
		if pCouple then
			if pCouple.FindTitle(unpack(tbSeventhEvening.tbKuixingTitleId)) == 0 then
				pCouple.AddTitle(unpack(tbSeventhEvening.tbKuixingTitleId));
			end	
			for i = 1, 7 do
				local nId = MathRandom(11, 66);
				pCouple.SetTask(tbSeventhEvening.TASKID_GROUP, nId, 1);
			end
			me.AddItem(unpack(tbSeventhEvening.tbYanhuaBoxId));
			pCouple.AddItem(unpack(tbSeventhEvening.tbYanhuaBoxId));
			
			tbSeventhEvening:AddXialvPoint(me, pCouple, 5);
		end
	end
	
	if pCouple then
		pCouple.Msg(string.format("恭喜你，答对了%s道题。只有7题全部答对，才有机会获得诗集中文字。", nRet));
		Dbg:WriteLog("SeventhEvening", "10年七夕", pCouple.szAccount, pCouple.szName, string.format("魁星巧问，由侠侣共享答对题目数：%s", nRet));
	end
	
	me.Msg(string.format("恭喜你，答对了%s道题。只有7题全部答对，才有机会获得诗集中文字。", nRet));
	Dbg:WriteLog("SeventhEvening", "10年七夕", me.szAccount, me.szName, string.format("魁星巧问，答对题目数：%s", nRet));
end

function tbNpc:OnGetAward()
	
	if self:CheckState() ~= 2 then
		Dialog:Say("对不起，现在不是领取奖励的时候，请到时再来。");
		return 0;
	end
	
	if me.GetTask(tbSeventhEvening.TASKID_GROUP, tbSeventhEvening.TASK_SHIJI_AWARD) == 1 then
		Dialog:Say("对不起，你已经领取过诗集奖励了。");
		return 0;
	end
	
	local nBox = tbSeventhEvening:GetShijiAward(me);
	if nBox <= 0 then
		Dialog:Say("对不起，你领取不到任何奖励");
		return 0;
	end
	
	local nNeed = KItem.GetNeedFreeBag(
		tbSeventhEvening.tbShijiBoxId[1], 
		tbSeventhEvening.tbShijiBoxId[2], 
		tbSeventhEvening.tbShijiBoxId[3], 
		tbSeventhEvening.tbShijiBoxId[4], 
		nil, nBox
	);
	if me.CountFreeBagCell() < nNeed then
		Dialog:Say(string.format("请留出%s格背包空间。", nNeed));
		return 0;
	end
	
	local tbFind = me.FindItemInBags(unpack(tbSeventhEvening.tbShijiId));
	if not tbFind or #tbFind <= 0 then
		Dialog:Say("对不起，请带上鹊桥仙诗集后再来领奖。");
		return 0;
	end
	
	for _, tbItem in pairs(tbFind) do
		me.DelItem(tbItem.pItem);
		break;
	end
	
	me.AddStackItem(
		tbSeventhEvening.tbShijiBoxId[1], 
		tbSeventhEvening.tbShijiBoxId[2], 
		tbSeventhEvening.tbShijiBoxId[3], 
		tbSeventhEvening.tbShijiBoxId[4],
		nil, nBox
	);
	
	me.SetTask(tbSeventhEvening.TASKID_GROUP, tbSeventhEvening.TASK_SHIJI_AWARD, 1);
end

function tbNpc:DailyEvent()
	
	if self:CheckState() ~= 1 then
		return 0;
	end
	
	me.SetTask(SpecialEvent.SeventhEvening.TASKID_GROUP, SpecialEvent.SeventhEvening.TASK_DAILY_QUESTION, 0);
end

PlayerSchemeEvent:RegisterGlobalDailyEvent({SpecialEvent.SeventhEvening.Kuixing.DailyEvent, SpecialEvent.SeventhEvening.Kuixing});
