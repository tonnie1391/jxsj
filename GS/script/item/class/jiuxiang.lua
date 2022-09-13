local tbItem = Item:GetClass("jiuxiang");
tbItem.tbJiu =
{
	{"Rượu Tây Bắc Vọng", 48},
	{"Rượu Đạo Hoa Hương", 49},
	{"Rượu Nữ Nhi Hồng", 50},
	{"Rượu Hạnh Hoa Thôn", 51},
	{"Rượu Thiêu Đao Tử", 52},
}

function tbItem:OnUse()
			   
	if it.GetGenInfo(1) >= it.GetExtParam(1) then
		if (me.DelItem(it, Player.emKLOSEITEM_USE) ~= 1) then
			return;
		end
	end
	
	local tbOpt = {}
	for i, tbJiu in pairs(self.tbJiu) do
		table.insert(tbOpt, {tbJiu[1], self.OnOpenItem, self, tbJiu[2], it.dwId});
	end
	table.insert(tbOpt, {"Để ta suy nghĩ đã"});
	local szMsg = "\nChọn rượu bạn cần.";
	Dialog:Say(szMsg, tbOpt)
end

function tbItem:OnOpenItem(nJiuPrap, nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 1;
	end
	local nMaxTakeOutCount = pItem.GetExtParam(1) - pItem.GetGenInfo(1);
	Dialog:AskNumber("Nhập số lượng: ", nMaxTakeOutCount, self.OnUseTakeOut, self, nJiuPrap, nItemId);
end

function tbItem:OnUseTakeOut(nJiuPrap, nItemId, nTakeOutCount)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 1;
	end
	if nTakeOutCount <= 0 then
		return 0;
	end
	local nTakeOutCountSure = nTakeOutCount;
	if nTakeOutCount > pItem.GetExtParam(1) - pItem.GetGenInfo(1) then
		nTakeOutCountSure = pItem.GetExtParam(1) - pItem.GetGenInfo(1);
	end
	if me.CountFreeBagCell() < nTakeOutCountSure then
		Dialog:Say("Túi bạn không đủ chỗ.");
		return 0;
	end	
	for ni=1, nTakeOutCountSure do
		local pAddItem = me.AddItem(18,1,nJiuPrap,1);
		if pAddItem then
			pItem.SetGenInfo(1, pItem.GetGenInfo(1) + 1);
			if pItem.GetGenInfo(1) >= pItem.GetExtParam(1) then
				break;
			end
		end
	end
	pItem.Sync();
	if pItem.GetGenInfo(1) >= pItem.GetExtParam(1) then
		if (me.DelItem(pItem, Player.emKLOSEITEM_USE) ~= 1) then
			return;
		end
	end
end

function tbItem:GetTip(nState)
	local szTip = "";
	szTip = szTip..string.format("<color=gold>Nhấp chuột phải để mở<color>\n");
	szTip = szTip..string.format("<color=yellow>Rượu lâu năm còn: %s bình<color>",(it.GetExtParam(1) - it.GetGenInfo(1)));	
	return	szTip;
end

