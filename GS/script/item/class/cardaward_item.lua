-- 文件名　：cardaward_item.lua
-- 创建者　：jiazhenwei
-- 创建时间：2012-05-17 17:43:51
-- 功能    ：绑银界面


local tbItem = Item:GetClass("Card_BindMoney");

function tbItem:OnUse()
	local nBindMoney = me.GetTask(2192, 43);
	if me.GetBindMoney() + nBindMoney > me.GetMaxCarryMoney() then
		Dialog:Say("您身上的绑定银两过多，请整理下。");
		return 0;
	end
	me.AddBindMoney(nBindMoney);
	me.SetTask(2192,43,0);
	return 1;
end

function tbItem:GetTip()
	local nBindMoney = me.GetTask(2192, 43);
	return string.format("钱袋已经累积的绑定银两：<color=green>%s<color>", nBindMoney);
end
