-- 文件名　：wanted_fengyincanpian.lua
-- 创建者　：sunduoliang
-- 创建时间：2010-08-19 14:35:31

local tbItem = Item:GetClass("wanted_fengyincanpian");

function tbItem:OnUse()
	Wanted:OnGetAwardCallBoss();
	return 0;
end
