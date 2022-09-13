-- 文件名　：npc_baiqiuling.lua
-- 创建者　：huangxiaoming
-- 创建时间：2010-12-28 14:10:10
-- 描  述  ：

Require("\\script\\event\\specialevent\\nianshouseige\\nianshousiege_def.lua");
SpecialEvent.NianShouSiege = SpecialEvent.NianShouSiege or {};
local tbNianShouSiege = SpecialEvent.NianShouSiege or {};

local tbNpc = Npc:GetClass("chunjieqiuyi");

function tbNpc:OnDialog()
	if tbNianShouSiege:CheckIsOpen() == 0 then
		Dialog:Say("现在不是活动时间");
		return 0;
	end
	if me.nLevel < tbNianShouSiege.PLAYER_LEVEL_LIMIT or me.nFaction <= 0 then
		Dialog:Say("只有大于80级的非白名玩家才能参加活动");
		return 0;
	end
	local _, nTodayTimes = tbNianShouSiege:CheckDayTask(me); 
	local nAwardCount = me.GetTask(tbNianShouSiege.TASK_GROUP_ID, tbNianShouSiege.TASK_AWARD_COUNT);
	local szMsg = string.format("每次年兽攻城时，只要各位成功驱赶年兽。每位使用过鞭炮的大侠都是我的恩人，我会备上谢礼！\n<color=red>注意：鞭炮不可久存，建议在年兽即将攻城前再购买！<color>\n<color=yellow>今日秋姨送上的谢礼：%s/%s份<color>\n<color=green>一共还有%s次谢礼未领取<color>\n", 
		nTodayTimes, tbNianShouSiege.MAX_DAY_WIN_TIMES, nAwardCount);
	local tbOpt = {};
	if nAwardCount > 0 then
		table.insert(tbOpt, {"领取秋姨谢礼", self.GetAward, self, him.dwId});
	else
		table.insert(tbOpt, {"<color=gray>领取秋姨谢礼<color>", self.GetAward, self, him.dwId});
	end
	table.insert(tbOpt, {"年兽攻城时间查询", self.QueryTime, self, him.dwId});
	table.insert(tbOpt, {"活动商店", self.OpenShop, self});
	table.insert(tbOpt, {"Kết thúc đối thoại"});
	Dialog:Say(szMsg, tbOpt);
end

-- 领奖
function tbNpc:GetAward(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	if tbNianShouSiege:CheckIsOpen() == 0 then
		Dialog:Say("现在不是活动时间");
		return 0;
	end
	local nAwardCount = me.GetTask(tbNianShouSiege.TASK_GROUP_ID, tbNianShouSiege.TASK_AWARD_COUNT);
	if nAwardCount <= 0 then
		Dialog:Say("对不起，没有谢礼可以领取。");
		return 0;
	end
	local szMsg = string.format("恩人，这是我的<color=yellow>%s份<color>心意，一共<color=yellow>%s绑银<color>，作为谢礼相送！\n<color=green>好人有好报！新的一年里您一定会心想事成！<color>", nAwardCount, nAwardCount * tbNianShouSiege.AWARD_GET_BINDMOENY);
	local tbOpt = 
	{
		{"Nhận", self.GetBindMoney, self},
		{"下次再领吧"},
	}
	Dialog:Say(szMsg, tbOpt);
	
end

-- 领取一次绑银奖励
function tbNpc:GetBindMoney()
	local nAwardCount = me.GetTask(tbNianShouSiege.TASK_GROUP_ID, tbNianShouSiege.TASK_AWARD_COUNT);
	if nAwardCount < 1 then
		return 0;
	end
	local nGetBindMoney = tbNianShouSiege.AWARD_GET_BINDMOENY * nAwardCount;
	if me.GetBindMoney() + nGetBindMoney > me.GetMaxCarryMoney() then
		Dialog:Say("你获取的绑银会使你身上的绑银超出最大携带量");
		return 0;
	end
	me.AddBindMoney(nGetBindMoney);
	me.SetTask(tbNianShouSiege.TASK_GROUP_ID, tbNianShouSiege.TASK_AWARD_COUNT, 0);
	Dialog:Say(string.format("你成功领取了秋姨<color=yellow>%s份<color>谢礼", nAwardCount));
end

-- 买鞭炮
function tbNpc:OpenShop()
	me.OpenShop(186, 1);
end


-- 查看攻城时间
function tbNpc:QueryTime(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local tbOpt = 
	{
		{"返回上一层", self.OnDialog, self},
		{"Ta hiểu rồi"},	
	};
	Dialog:Say("<color=green>年兽攻城时间<color>\n<color=yellow>日期：1月28日-2月1日\n时间：12:45、13:45、18:45、19:45、20:45<color>", tbOpt);
end