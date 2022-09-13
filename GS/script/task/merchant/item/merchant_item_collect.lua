
local tbItem = Item:GetClass("merchant_collect")

function tbItem:InitGenInfo()
	-- 设定有效期限
	it.SetTimeOut(1, 120 * 60);
	return	{ };
end
