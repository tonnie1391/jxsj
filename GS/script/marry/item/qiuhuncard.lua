-- 文件名　：qiuhuncard.lua
-- 创建者　：furuilei
-- 创建时间：2010-01-05 12:10:17
-- 功能描述：求婚道具（求婚卡片）

local tbItem = Item:GetClass("marry_qiuhuncard");

function tbItem:OnUse()
	if (Marry:CheckState() == 0) then
		return 0;
	end
	Marry.DialogNpc:OnQiuhun(it.dwId);
end
