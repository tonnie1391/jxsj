-- 文件名  : qiannianrenshen.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-07-12 17:25:02
-- 描述    : 千年人参

--VN--
local tbItem 	= Item:GetClass("qiannianrenshen");

function tbItem:OnUse()
	if me.nLevel <= 50 then		
		Dialog:Say("您的等级还没有超过50级，不能使用这个物品。");
		return 0;
	end
	if me.nLevel >= 105 then
		Dialog:Say("您的等级已经达到或超过了105级，不能使用这个物品。");
		return 0;
	end
	me.AddLevel(105 - me.nLevel);
	return 1;
end
