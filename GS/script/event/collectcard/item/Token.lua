Require("\\script\\event\\collectcard\\define.lua")

local tbItem = Item:GetClass("collect_token");
local CollectCard = SpecialEvent.CollectCard;
local tbAward = 
{

	[1] = 1000,
	[2] = 3000,
	[3] = 500,	
}

function tbItem:OnUse()
	me.AddRepute(5, 2, tbAward[it.nLevel]);
	if it.nLevel ~= 3 then
		me.Msg(string.format("Nhận được <color=yellow>%s điểm<color> danh vọng Thịnh hạ 2008, đã có thể mua Yêu đái +1 kỹ năng.",tbAward[it.nLevel]))
		Dialog:SendBlackBoardMsg(me, "Đã có thể mua Yêu đái +1 kỹ năng rồi.")
	else
		me.Msg(string.format("Nhận được <color=yellow>%s điểm<color> danh vọng Thịnh hạ 2008.",tbAward[it.nLevel]))
	end
	CollectCard:WriteLog(string.format("Nhận được %s danh vọng thịnh hạ 2008", tbAward[it.nLevel]), me.nId);			
	return 1;
end


