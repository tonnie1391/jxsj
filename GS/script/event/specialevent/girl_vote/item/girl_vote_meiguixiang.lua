-- 文件名　：girl_vote_meiguixiang.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-06-23 11:52:36
-- 描  述  ：

------------------------------------------------------------------------------------------
-- initialize

local tbXiang = Item:GetClass("girl_vote_meiguixiang");

------------------------------------------------------------------------------------------

-- 返回值：	0不删除、1删除
function tbXiang:OnUse()
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ chỗ trống.");
		return 0;
	end
	local tbItemInfo = {};
	me.AddStackItem(18, 1, 373, 1, tbItemInfo, 99);
	return 1;
end
