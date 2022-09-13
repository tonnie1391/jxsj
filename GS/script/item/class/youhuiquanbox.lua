local tbQuanBox = Item:GetClass("youhuiquanbox");

tbQuanBox.tbQuanList = {
		[1] = {
			szName = "3折9级玄晶优惠券",
			tbItem = {
				{18,1,395,1,0,1}, 
				},
			nNeedFree = 1,
		},
		[2] = {
			szName = "3折购买精气散和活气散优惠券",
			tbItem = {
				{18,1,1703,1,1,1}, 
				{18,1,1704,1,1,1},
			},
			nNeedFree = 2,
		},
	};

function tbQuanBox:OnUse()
	local szMsg = "优惠券宝箱，里面有各种优惠券，你想选择领取哪一个呢：";
	local tbOpt = {};

	for i, tbItem in pairs(self.tbQuanList) do
		local tbOneItem = tbItem.tbItem;
		local szTip = "<item=".. tbOneItem[1][1] .. "," .. tbOneItem[1][2] .. "," .. 
					tbOneItem[1][3] .. "," .. tbOneItem[1][4]..">"
		local tbInfo = {tbItem.szName .. szTip, self.OnGetItem, self, it.dwId, i};
		table.insert(tbOpt, tbInfo);
	end	
	
	table.insert(tbOpt, {"Để ta suy nghĩ lại"});
	
	Dialog:Say(szMsg, tbOpt);
	
	return 0;
end

function tbQuanBox:OnGetItem(dwId, nIndex, nCheck)
	local pItem = KItem.GetObjById(dwId);
	if not pItem then
		Dialog:Say("你的优惠券已过期。");
		return 0;
	end

	local tbItem = self.tbQuanList[nIndex];
	local nNeedFree = 0;
	
	if (not tbItem) then
		Dialog:Say("道具异常");
		return 0;
	end
	
	for i, tbOneItem in pairs(tbItem.tbItem) do
		nNeedFree = nNeedFree + tbOneItem[6];
	end
	
	if (nNeedFree > me.CountFreeBagCell()) then
		Dialog:Say(string.format("您的背包剩余空间不足%s，请整理后再来领取！", nNeedFree));
		return 0;
	end
	
	if (not nCheck or nCheck ~= 1) then
		Dialog:Say(string.format("您确定领取<color=yellow>%s<color>吗？", tbItem.szName), {
				{"Xác nhận", self.OnGetItem, self, dwId, nIndex, 1},
				{"Để ta suy nghĩ thêm"},
			});
		return 0;
	end

	local nRet = pItem.Delete(me);
	if nRet ~= 1 then
		return 0;
	end	
	
	StatLog:WriteStatLog("stat_info", "award_choose", "get_tickit", me.nId, tbItem.szName);
	
	for i, tbOneItem in pairs(tbItem.tbItem) do
		for j=1, tbOneItem[6] do
			local pOneItem = me.AddItem(tbOneItem[1], tbOneItem[2], tbOneItem[3], tbOneItem[4]);
			if (pOneItem) then
				if (tbOneItem[5] == 1) then
					pOneItem.Bind(1);
				end
			end
		end
	end
	
	return 1;
end

