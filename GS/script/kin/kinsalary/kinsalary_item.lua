-------------------------------------------------------
-- 文件名　：kinsalary_item.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2012-07-02 11:31:58
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\kin\\kinsalary\\kinsalary_def.lua");

-- 金元宝
local tbYuanbao = Item:GetClass("kinsalary_yuanbao");
function tbYuanbao:OnUse()
	local nAddJinDing = 1000;
	local nCurJinDing = me.GetTask(Kinsalary.TASK_GID, Kinsalary.TASK_JINDING);
	if nCurJinDing + nAddJinDing > Kinsalary.MAX_NUMBER then
		Dialog:Say("您的家族金锭将超出上限，请在金锭商店中消费一些才可继续获得。");
		return 0;
	end
	me.SetTask(Kinsalary.TASK_GID, Kinsalary.TASK_JINDING, nAddJinDing + nCurJinDing);
	Kinsalary:SendMessage(me, Kinsalary.MSG_CHANNEL, string.format("你获得了%s家族金锭", nAddJinDing));
	StatLog:WriteStatLog("stat_info", "family_salary", "open_yuanbao", me.nId, nAddJinDing);
	return 1;
end

-- 家族银箱
local tbYinxiang = Item:GetClass("kinsalary_yinxiang");
function tbYinxiang:OnUse()
	local nOpenDay = math.floor((GetTime() - KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME)) / (60 * 60 * 24));
	local tbAward = Lib._CalcAward:RandomAward(3, 4, 2, Kinsalary.MAX_BIND_VALUE, Lib:_GetXuanReduce(nOpenDay), {8, 2, 0});
	local nMaxMoney = Kinsalary:GetMaxMoney(tbAward);
	if nMaxMoney + me.GetBindMoney() > me.GetMaxCarryMoney() then
		Dialog:Say("对不起，您身上的绑定银两可能会超出上限，请整理后再来领取。");
		return 0;
	end
	local nNeed = 1;
	if me.CountFreeBagCell() < nNeed then
		Dialog:Say(string.format("请留出%s格背包空间。", nNeed));
		return 0;
	end
	Kinsalary:RandomAward(me, tbAward, 1);
	return 1;
end

-- 家族金箱
local tbJinxiang = Item:GetClass("kinsalary_jinxiang");
function tbJinxiang:OnUse()
	local nOpenDay = math.floor((GetTime() - KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME)) / (60 * 60 * 24));
	local tbAward = Lib._CalcAward:RandomAward(3, 4, 2, Kinsalary.MAX_NOBIND_VALUE, Lib:_GetXuanReduce(nOpenDay), {8, 2, 0});
	local nMaxMoney = Kinsalary:GetMaxMoney(tbAward);
	if nMaxMoney + me.GetBindMoney() > me.GetMaxCarryMoney() then
		Dialog:Say("对不起，您身上的绑定银两可能会超出上限，请整理后再来领取。");
		return 0;
	end
	local nNeed = 1;
	if me.CountFreeBagCell() < nNeed then
		Dialog:Say(string.format("请留出%s格背包空间。", nNeed));
		return 0;
	end
	Kinsalary:RandomAward(me, tbAward, 1);
	return 1;
end
