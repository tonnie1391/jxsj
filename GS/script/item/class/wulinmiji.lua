--武林秘籍
--孙多良
--2008.08.08

local tbItem = Item:GetClass("wulinmiji")
tbItem.tbBook =
{
	--物品等级 = {次数上限，任务变量组，任务变量, 增加技能点数量};
	[1] = {5, 2040, 5, 1}, --初级武林秘籍
	[2] = {5, 2040, 8, 1}, --中级武林秘籍
	[3] = {2, 2040, 10, 1},--粽子
}
function tbItem:OnUse()
	local tbParam = self.tbBook[it.nLevel];
	if not tbParam then
		return 0;
	end
	local nUse =  me.GetTask(tbParam[2], tbParam[3]);
	if nUse >= tbParam[1] then
		me.Msg(string.format("<color=yellow>你研习了%s本%s，已无法继续研习。", tbParam[1], it.szName));
		Dialog:SendInfoBoardMsg(me, string.format("<color=yellow>你仔细研读了%s，还是一无所获。", it.szName))
		return 0;
	end
	
	me.AddFightSkillPoint(tbParam[4]);
	me.SetTask(tbParam[2], tbParam[3], nUse +1)
	
	PlayerHonor:UpdataMaxWealth(me);		-- 更新财富最大值
	local szMsg = string.format("<color=yellow>你仔细研读了%s，似有所悟，获得了%s技能点。", it.szName, tbParam[4]);
	Dialog:SendInfoBoardMsg(me, szMsg)
	szMsg = string.format("%s您已成功研读了%s本%s。",szMsg, nUse +1, it.szName);
	me.Msg(szMsg);
	return 1;
end

function tbItem:GetTip()
	local szTip = "";
	local tbParam = self.tbBook[it.nLevel];
	local nUse =  me.GetTask(tbParam[2], tbParam[3]);
	szTip = szTip .. string.format("<color=green>已读过%s本该书<color>", nUse);
	return szTip;
end
