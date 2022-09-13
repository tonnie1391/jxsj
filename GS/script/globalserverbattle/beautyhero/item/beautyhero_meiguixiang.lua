-- 文件名  : beautyhero_meiguixiang.lua
-- 创建者  : zounan
-- 创建时间: 2010-10-13 09:28:53
-- 描述    : 

local tbXiang = Item:GetClass("beautyhero_meiguixiang");

------------------------------------------------------------------------------------------

-- 返回值：	0不删除、1删除
function tbXiang:OnUse()
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ chỗ trống.");
		return 0;
	end
	local tbItemInfo = {};
	me.AddStackItem(18, 1, 1037, 1, tbItemInfo, 100);
	return 1;
end
