--江湖威望令牌
--孙多良
--2008.10.30

local tbItem = Item:GetClass("jianghuweiwanglingpai");
tbItem.tbEffect = 
{
	[1] = 20;
}
function tbItem:OnUse()
	me.AddKinReputeEntry(self.tbEffect[it.nLevel]);
	-- me.Msg(string.format("您获得了<color=yellow>%s点<color>江湖威望",self.tbEffect[it.nLevel]))
	return 1;
end
