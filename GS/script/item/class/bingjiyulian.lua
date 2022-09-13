-------------------------------------------------------
-- 文件名　：bingjiyulian.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-05-25 14:14:49
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

local tbItem = Item:GetClass("bingjiyulian");

function tbItem:OnUse()
	if me.nLevel >= 100 then
		me.Msg("Nhân vật dưới cấp 100 mới có thể sử dụng.");
		return 0;
	end
	
	for i = 1, 10 do
		me.AddLifeSkillExp(i, 2000000);
	end
	
	me.AddLevel(100 - me.nLevel);
	return 1;
end
