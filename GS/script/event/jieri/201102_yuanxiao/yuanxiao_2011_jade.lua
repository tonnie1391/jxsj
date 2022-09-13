-------------------------------------------------------
-- 文件名　：yuanxiao_2011_jade.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2011-01-06 17:27:15
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\event\\jieri\\201102_yuanxiao\\yuanxiao_2011_def.lua");

-- 金珍珠
local tbItem = Item:GetClass("jade2011");
local tbYuanxiao_2011 = SpecialEvent.Yuanxiao_2011;

function tbItem:OnUse()	
	tbYuanxiao_2011:InitGame(me);
	self:OnDialog(it.dwId);
end

function tbItem:OnDialog(dwItemId)	
	
	if tbYuanxiao_2011:CheckState(me) == 0 then
		return 0;
	end
	
	local nType = me.GetTask(tbYuanxiao_2011.TASK_GID, tbYuanxiao_2011.TASK_AWARD_TYPE);
	local nStartLevel = me.GetTask(tbYuanxiao_2011.TASK_GID, tbYuanxiao_2011.TASK_START_LEVEL);
	local nStepLevel = me.GetTask(tbYuanxiao_2011.TASK_GID, tbYuanxiao_2011.TASK_STEP_LEVEL);
	
	local nCurLevel = nStartLevel + nStepLevel - 1;
	local nItemCount = tbYuanxiao_2011.TYPE_LEVEL_VALUE[nType].tbLevel[nCurLevel];
	local szItemName = tbYuanxiao_2011.TYPE_LEVEL_VALUE[nType].szName;
	local szCurItem = string.format("%s%s", Item:FormatMoney(nItemCount), szItemName);
	
	local szTip = "";
	local szNextItem = "";
	if nStepLevel >= tbYuanxiao_2011.MAX_STEP_LEVEL then
		szNextItem = "Vô";
		szTip = "<color=green>恭喜您！已经开到最高层！<color>";
	else
		local nNextCount = tbYuanxiao_2011.TYPE_LEVEL_VALUE[nType].tbLevel[nCurLevel + 1];
		szNextItem = string.format("%s%s", Item:FormatMoney(nNextCount), szItemName);
		szTip = "<color=red>注意：<color=orange>如果您打开下一层失败了，金珍珠将被损毁，您无法获得任何奖励。层数越高，失败的可能性越大！请三思而后行！<color>";
	end
	
	local szMsg = string.format([[
金珍珠：金珠玉翠，内藏玄机
	
    当前奖励：<color=green>%s<color>
    下层奖励：<color=yellow>%s<color>
    已开层数：<color=yellow>%s/%s<color>
	
%s
]], szCurItem, szNextItem, nStepLevel, tbYuanxiao_2011.MAX_STEP_LEVEL, szTip);

	local tbOpt = {};
	if tbYuanxiao_2011:CheckState(me) == 2 then
		table.insert(tbOpt, 1, {"我想好了，我要打开下一层", tbYuanxiao_2011.GetContinueResult, tbYuanxiao_2011, dwItemId});
	end
	table.insert(tbOpt, {"我不玩了，我要领取当前奖励", tbYuanxiao_2011.GetAward, tbYuanxiao_2011, dwItemId});
	Dialog:Say(szMsg, tbOpt);
end
