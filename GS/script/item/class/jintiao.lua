
local tbItem = Item:GetClass("jintiao");
tbItem.GETMONEY = 
{
	[1] = {150000, 200000},
	[2] = {1500000, 2000000},
};
tbItem.ExReturnBindMoney = 0; --返还获得绑银的百分比绑银
function tbItem:OnUse()
	local nGetMoney = self.GETMONEY[it.nLevel][1];
	local nGetBindMoney = self.GETMONEY[it.nLevel][2];

	local szMsg = string.format("Bạn sử dụng <color=yellow>%s<color> có thể nhận được 1 trong 2:\n\n    <color=yellow>%s Bạc<color>\n    <color=yellow>%s Bạc khóa<color>\n\nChọn 1 trong 2, bạn muốn đổi lấy gì?", it.szName, nGetMoney, nGetBindMoney);
	local tbOpt = {
		{"Đổi bạc thường", self.SureUse, self, it, 1},
		{"Đổi bạc khóa", self.SureUse, self, it, 2},
		{"Để ta suy nghĩ đã"},
	}
	Dialog:Say(szMsg, tbOpt);
	return 0;
end

function tbItem:SureUse(pItem, nType, nSure)
	if not pItem then
		return
	end
	local szItemName = pItem.szName;
	local nIbValue = pItem.nBuyPrice;
	local nGetMoney = self.GETMONEY[pItem.nLevel][nType];
	local nGetBindMoney = self.GETMONEY[pItem.nLevel][2];
	local szType = "Bạc";
	if nType == 2 then
		szType = "Bạc khóa";
	end
	if not nSure then
		local szMsg = string.format("Bạn xác nhận đổi <color=yellow>%s %s<color> không?", nGetMoney, szType);
		local tbOpt = {
			{"Xác nhận", self.SureUse, self, pItem, nType, 1},
			{"Để ta suy nghĩ đã"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	if nType == 1 then
		if me.nCashMoney + nGetMoney > me.GetMaxCarryMoney() then
			me.Msg("Sau khi sử dụng, bạc trên người bạn sẽ quá giới hạn cho phép, hãy kiểm tra lại trước khi sử dụng.");
			return 0;
		end
	else
		if me.GetBindMoney() + nGetMoney + math.floor(self.ExReturnBindMoney * nGetBindMoney / 100) > me.GetMaxCarryMoney() then
			me.Msg("Sau khi sử dụng, bạc khóa trên người bạn sẽ quá giới hạn cho phép, hãy kiểm tra lại trước khi sử dụng.");
			return 0;
		end
	end

	if me.DelItem(pItem, Player.emKLOSEITEM_JINTIAO) ~= 1 then
		Dbg:WriteLog(me.szName, "Del Item:", szItemName, "Không");
		return 0;
	end
	if self.ExReturnBindMoney > 0 then
		me.AddBindMoney(math.floor(self.ExReturnBindMoney * nGetBindMoney / 100), Player.emKBINDMONEY_ADD_JITIAO);
		KStatLog.ModifyAdd("bindjxb", "Thỏi vàng", "Tổng", math.floor(self.ExReturnBindMoney * nGetBindMoney / 100));	
	end

	local szMoneyType = "Bạc khóa";
	if nType == 1 then
		me.Earn(nGetMoney, Player.emKEARN_TASK_JITIAO);
		Dbg:WriteLog(me.szName, "Use Item:", szItemName, "GetMoney:", nGetMoney);
		KStatLog.ModifyAdd("jxb", "Thỏi vàng", "Tổng", nGetMoney);	
	else
		szMoneyType = szMoneyType.." khóa";
		me.AddBindMoney(nGetMoney, Player.emKBINDMONEY_ADD_JITIAO);
		Spreader:AddConsume(nIbValue, 1, szItemName);
		KStatLog.ModifyAdd("bindjxb", "Thỏi vàng", "Tổng", nGetMoney);			
	end

	Dbg:WriteLog("use jintiao", me.szAccount, me.szName,  string.format("Sử dụng %s được %d %s", szItemName, nGetMoney, szMoneyType));
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("%s sử dụng %s được %d %s", me.szName, szItemName, nGetMoney, szMoneyType));
end
