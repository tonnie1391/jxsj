
local tbItem = Item:GetClass("qianlichuanyin");
local nParticular = 924;
-- 道具可增加公聊的次数
local tbUseCount = 
{
	[nParticular] = 2,
	[nParticular + 1] = 11,
};

function tbItem:OnUse()
	if (me.nLevel < 30) then
		me.Msg("角色等级大于30级才能使用此物品。");
		return 0;
	end
	local nCount = me.GetTask(ChatChannel.TASK_CHAT, 4);
	local nAdd = tbUseCount[it.nParticular];
	if (nAdd == nil or nAdd <= 0) then
		return 0;
	end
	nCount = nCount + nAdd;
	me.SetTask(ChatChannel.TASK_CHAT, 4, nCount);
	me.Msg(string.format("您的大区公聊次数增加了%d次，一共有%d次。", nAdd, nCount));
	return 1;
end
