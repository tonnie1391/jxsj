--神秘疆绳
--sunduoliang
--2008.10.30

local tbItem = Item:GetClass("shenmijiangsheng");

tbItem.tbHorse = 
{
	{1, 12, 17, 3},	--奇珍阁（乌云踏雪）
	{1, 12, 19, 3}, --奇珍阁（绝影）
	{1, 12, 20, 3}, --奇珍阁（照夜玉狮子）
	{1, 12, 21, 3}, --奇珍阁（汗血宝马）
}

tbItem.nLimitTime = Item.IVER_nShenMiHorse;

function tbItem:OnUse()
	local szMsg = "Dây cương thần bí có thể bắt được ngựa tốt, hãy lựa chọn thật chuẩn xác nhé.\n<color=red>(Ngựa nhận được sẽ tự khóa với nhân vật)<color>";
	local tbOpt = {};
	local nLimitTime = it.GetExtParam(1);
	if (not nLimitTime or nLimitTime <= 0) then
		nLimitTime = self.nLimitTime;
	end
	for nId, tbHorse in ipairs(self.tbHorse) do
		local szName = KItem.GetNameById(unpack(tbHorse));
		table.insert(tbOpt, {szName, self.GetHorse, self, it.dwId, nId, nLimitTime});
	end
	table.insert(tbOpt, {"Để ta suy nghĩ lại"});
	Dialog:Say(szMsg, tbOpt);
end

function tbItem:GetHorse(nItemId, nId, nLimitTime, nFlag)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	if not nFlag then
		local szMsg= string.format("Bạn chọn <color=yellow>%s<color>, sau khi sử dụng sẽ <color=red>tự động khóa<color>, bạn chắc chứ?", KItem.GetNameById(unpack(self.tbHorse[nId])));
		local tbOpt = 
		{
			{"Xác nhận", self.GetHorse, self, nItemId, nId, nLimitTime, 1},
			{"Để ta suy nghĩ lại"},
		}
		Dialog:Say(szMsg, tbOpt);
		return;
	end
	if me.DelItem(pItem) ~= 1 then
		return
	end
	local pAddItem = me.AddItem(unpack(self.tbHorse[nId]));
	if pAddItem then
		pAddItem.Bind(1);
		me.SetItemTimeout(pAddItem, os.date("%Y/%m/%d/%H/%M/%S", GetTime() + nLimitTime * 24 * 3600), 0);
		me.Msg(string.format("Bạn nhận được một <color=yellow>%s<color>", pAddItem.szName));
	end
end
