-------------------------------------------------------
-- 文件名　：SeventhEvening_xiguniang.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-07-27 11:32:40
-- 文件描述：
-------------------------------------------------------

local tbNpc = Npc:GetClass("QX_xiguniang");
SpecialEvent.SeventhEvening = SpecialEvent.SeventhEvening or {};
local tbSeventhEvening = SpecialEvent.SeventhEvening;

function tbNpc:OnDialog()
	local nTime = tonumber(GetLocalDate("%Y%m%d"));
	if nTime > 20100907 then
		Dialog:Say("喜姑娘："..me.szName..", xin chào!");
		return 0;
	end
	local szMsg = "七夕期间，凡是参加各种活动的侠侣。都可以在本服务器侠侣幸福榜上找到自己，种植侠侣同心树积5分；共同参加魁星巧问答对7题积5分；赠送对方金鹊礼包积3分。活动积分在本服务器排名靠前的侠侣们将得到七夕特色称号和象征着甜蜜和美满的幸福大礼包。";
	local tbOpt = 
	{
		{"查看侠侣幸福榜", tbSeventhEvening.QueryXialv, tbSeventhEvening},
		{"查询侠侣幸福积分", self.QueryXialvPoint, self},
		{"传送到玉露村", self.OnTransfer, self},
		{"领取最终奖励",self.GetAword, self},
		{"Để ta suy nghĩ thêm"},
	};
	
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:OnTransfer()
	if me.nLevel < 60 then
		Dialog:Say("对不起，你的等级不满60级，无法前往玉露村。");
		return 0;
	end
	if not Task:GetPlayerTask(me).tbTasks[473] then
		Dialog:Say("对不起，只有您接受了同心情缘任务才能前往玉露村。");
		return 0;
	end
	local tbPos = {587, 1561, 3208};
	local nOk, szError = Map:CheckTagServerPlayerCount(tbPos[1]);
	if nOk ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	me.SetFightState(1);
	me.NewWorld(unpack(tbPos));
end

function tbNpc:QueryXialvPoint()
	local nPoint = me.GetTask(tbSeventhEvening.TASKID_GROUP , tbSeventhEvening.TASK_XIALV_POINT);
	if nPoint <= 0 then
		Dialog:Say("对不起，你现在还没有获得任何侠侣幸福积分。");
		return 0;
	end
	Dialog:Say(string.format("你当前的侠侣幸福积分为：<color=yellow>%s<color>", nPoint));
end

function tbNpc:GetAword()	
	local nTime = tonumber(GetLocalDate("%Y%m%d%H%M"));
	if nTime < 201009010010 or nTime >= 201009080000 then
		Dialog:Say("现在不是领奖的时间。");
		return 0;
	end
	local nRank = tbSeventhEvening:GetRank();
	if nRank == 0 then
		Dialog:Say("你好像没有奖励可以领取哦。");
		return 0;
	end
	if me.GetTask(tbSeventhEvening.TASKID_GROUP, tbSeventhEvening.TASKID_ISGETAWORD) == 1 then
		Dialog:Say("你已经领过奖励了吧。");
		return 0;
	end
	--背包判定
	if me.CountFreeBagCell() < 2 then
		Dialog:Say("需要预留2格背包空间，去整理下再来吧。",{"知道了"});
		return;
	end
	if nRank > 0 then		
		me.AddItem(unpack(tbSeventhEvening.tbAwordFinal));
		if nRank == 1 then
			me.AddTitle(unpack(tbSeventhEvening.tbTitleAword[1]));
			me.AddItem(unpack(tbSeventhEvening.tbMaskAword[me.nSex + 1]));
		else
			me.AddTitle(unpack(tbSeventhEvening.tbTitleAword[2]));
		end
	end
	me.SetTask(tbSeventhEvening.TASKID_GROUP, tbSeventhEvening.TASKID_ISGETAWORD, 1);
	Dbg:WriteLog("SeventhEvening", "10年七夕", "领取幸福榜奖励", string.format("角色名：%s获得第%s名奖励。", me.szName, nRank));
end
