
-- 背包脚本
-- zhengyuhua

local tbBag = Item:GetClass("extbag");

function tbBag:GetTip()
	if it.GetBagPosLimit() > 0 then
		return string.format("<color=gold>该背包只能放在第%d个背包栏里！", it.GetBagPosLimit());
	end
	return ""
end





