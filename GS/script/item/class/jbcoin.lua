
local tbItem = Item:GetClass("hopqua");

function tbItem:OnUse()
	DoScript("\\script\\item\\class\\jbcoin.lua");
	-- if me.szAccount ~= "tonnie" then
		-- me.Msg("Chức năng đang bảo trì!")
		-- return;
	-- end
	if me.CountFreeBagCell() < 1 then
		me.Msg("Hành trang không đủ chỗ trống!");
		return 0;
	end
	me.ApplyAutoBuyAndUse(1220 + it.nLevel, it.nCount); 
	it.Delete(me);
end

local tbItem = Item:GetClass("tuidong");
function tbItem:OnUse()
	return 1;
end
