local tbItem = Item:GetClass("vnqiannianlingguo");

tbItem.nTaskGroup 			=	2210;
tbItem.nTaskCheckDateUse 	=	16;
tbItem.nTaskCountUse	 	=	17;

tbItem.nMaxPerDay	 		=	20;

function tbItem:OnUse()
	DoScript("\\script\\item\\vnclass\\vnqiannianlingguo.lua");
	
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

	me.AddExp(me.GetBaseAwardExp() * 1000);
	
	me.SetTask(self.nTaskGroup, self.nTaskCountUse, me.GetTask(self.nTaskGroup, self.nTaskCountUse) + 1);
	me.Msg("Hôm nay đã sử dụng <color=yellow>"..me.GetTask(self.nTaskGroup, self.nTaskCountUse).."<color> Thiên Niên Linh Quả.")
	return 1;
end

local tbItem2 = Item:GetClass("vnlingguopacket");
function tbItem2:OnUse()
	DoScript("\\script\\item\\vnclass\\vnqiannianlingguo.lua");
	
	if me.CountFreeBagCell() < 2 then
		me.Msg("Hành trang không đủ chỗ trống!")
		return;
	end
	
	me.AddStackItem(18, 1, 20301, 1,nil, 10);
	return 1;
end
