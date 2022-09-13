Require("\\script\\task\\weekendfish\\weekendfish_def.lua")

-- 杂物
local tbClass = Item:GetClass("weekendfish_zawu");

function tbClass:OnUse()
	if me.GetBindMoney() + WeekendFish.PRICE_ZAWU > me.GetMaxCarryMoney() then
		me.Msg("你身上的绑银即将达到上限，暂时无法使用道具获得绑银。");
		return 0;
	end
	me.AddBindMoney(WeekendFish.PRICE_ZAWU);
	return 1;
end