--机关箱

local tbItem = Item:GetClass("army_bag")

function tbItem:GetTip(nState)
	local nLevel = me.GetReputeLevel(1,3);
	local nMachineCoin = me.GetMachineCoin();
	local szTip = string.format("<color=green>Cơ Quan Học Tạo Đồ: %s<enter><enter>", nLevel);
	szTip = string.format("%s độ bền của cơ quan: %s<color>", szTip, nMachineCoin);
	return szTip;
end
