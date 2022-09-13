-- 文件名　：zongziskill.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-05-18 11:56:26
-- 描  述  ：

local tbItem = Item:GetClass("canghaiyueming")
tbItem.tbBook =
{ --物品等级 = {次数上限，任务变量组，任务变量, 增加技能数量};
  2, 2040, 21, 1,
}
function tbItem:OnUse()
	local tbParam = self.tbBook;
	if not tbParam then
		return 0;
	end
	local nUse =  me.GetTask(tbParam[2], tbParam[3]);
	if nUse >= tbParam[1] then
		me.Msg(string.format("<color=yellow>你食用了%s个%s，已不能吃得下了。", tbParam[1], it.szName));
		Dialog:SendInfoBoardMsg(me, string.format("<color=yellow>你咬了一口%s，觉得无味。", it.szName))
		return 0;
	end
	
	me.AddFightSkillPoint(tbParam[4]);
	me.SetTask(tbParam[2], tbParam[3], nUse +1)
	
	PlayerHonor:UpdataMaxWealth(me);		-- 更新财富最大值
	local szMsg = string.format("<color=yellow>你食用了%s，似有所悟，获得了%s技能点。", it.szName, tbParam[4]);
	Dialog:SendInfoBoardMsg(me, szMsg)
	szMsg = string.format("%s您已食用了%s个%s。",szMsg, nUse +1, it.szName);
	me.Msg(szMsg);
	
	return 1;
end

function tbItem:GetTip()
	local szTip = "";
	local tbParam = self.tbBook;
	local nUse =  me.GetTask(tbParam[2], tbParam[3]);
	szTip = szTip .. string.format("<color=green>已食用%s/%s个<color>", nUse, self.tbBook[1]);
	return szTip;
end
