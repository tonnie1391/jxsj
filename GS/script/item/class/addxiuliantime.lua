--修炼丹
--sunduoliang
--2008.11.24

local tbItem = Item:GetClass("addxiuliantime");
 
function tbItem:OnUse()
	local nTime = tonumber(it.GetExtParam(1));
	local tbXiuLianZhu = Item:GetClass("xiulianzhu");
	if tbXiuLianZhu:GetReTime() + nTime > 14 then
		Dialog:Say(string.format("您的剩余修炼时间将超过14个小时，不能使用%s！", it.szName))
		return 0;
	end
	tbXiuLianZhu:AddRemainTime(nTime * 60);
	me.Msg(string.format("您的修炼时间增加了<color=green>%s小时<color>。", nTime));
	return 1;
end
