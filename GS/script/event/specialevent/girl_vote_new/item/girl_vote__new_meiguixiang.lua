-- 文件名  : girl_vote__new_meiguixiang.lua
-- 创建者  : zounan
-- 创建时间: 2010-10-13 09:26:07
-- 描述    : 
------------------------------------------------------------------------------------------
-- initialize

local tbXiang = Item:GetClass("girl_vote_new_meiguixiang");

------------------------------------------------------------------------------------------

-- 返回值：	0不删除、1删除
function tbXiang:OnUse()
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ chỗ trống.");
		return 0;
	end
	local tbItemInfo = {};
	me.AddStackItem(18, 1, 1023, 1, tbItemInfo, 100);
	return 1;
end
