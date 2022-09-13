local tbItem = Item:GetClass("vn_tianlongbaoxiang");

tbItem.nTaskGroup 			=	2210;
tbItem.nTaskCheckDateUse 	=	11;
tbItem.nTaskCountUse	 	=	12;

tbItem.nMaxPerDay	 		=	40;

tbItem.tbRate				=	{4000, 3500, 500, 50, 950, 1000};

function tbItem:OnUse()
	DoScript("\\script\\item\\class\\vn_tianlongbaoxiang.lua");
	
	local nAdd = 0;	
	local nIndex = 0;
	local nRand = MathRandom(1, 10000);

	for i = 1, #self.tbRate do
		nAdd = nAdd + self.tbRate[i];
		if nAdd >= nRand then
			nIndex = i;
			break;
		end
	end
	
	if nIndex == 0 then
		me.Msg("Đã xảy ra lỗi!")
		return 0;
	end
	
	if me.CountFreeBagCell() < 3 then
		me.Msg("Hành trang không đủ chỗ trống!")
		return;
	end
	
	local nCurrentDate = tonumber(os.date("%Y%m%d", GetTime()))
	if me.GetTask(self.nTaskGroup, self.nTaskCheckDateUse) == nCurrentDate then
		if me.GetTask(self.nTaskGroup, self.nTaskCountUse) >= self.nMaxPerDay then
			Dialog:Say("Hôm nay đã sử dụng đủ rồi! Mai hãy sử dụng tiếp.")
			return;
		end
	else
		me.SetTask(self.nTaskGroup, self.nTaskCheckDateUse, nCurrentDate);
		me.SetTask(self.nTaskGroup, self.nTaskCountUse, 0);
	end
	
	if nIndex == 1 then
		me.AddExp(2000000);
	elseif nIndex == 2 then
		me.AddBindMoney(400000)
	elseif nIndex == 3 then
		me.AddStackItem(18, 1, 738, 1, {bForceBind = 1}, 1)
	elseif nIndex == 4 then
		if it.IsBind() == 1 then
			me.AddStackItem(18, 1, 377, 1, {bForceBind = 1}, 1)
		else
			me.AddStackItem(18, 1, 377, 1, {bForceBind = 0}, 1)
		end 
	elseif nIndex == 5 then
		me.AddStackItem(18, 1, 205, 1, {bForceBind = 1}, 200)
	else
		me.AddStackItem(18, 1, 20301, 1, {bForceBind = 1}, 3)
	end
	
	me.SetTask(self.nTaskGroup, self.nTaskCountUse, me.GetTask(self.nTaskGroup, self.nTaskCountUse) + 1);
	me.Msg("Hôm nay đã sử dụng <color=yellow>"..me.GetTask(self.nTaskGroup, self.nTaskCountUse).."<color> Rương Thiên Long.")
	return 1;
end
