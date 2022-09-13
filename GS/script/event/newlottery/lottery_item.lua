-- 文件名　：lottery_item.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-09-18 19:12:43
-- 描  述  ：

local tbLottery = Item:GetClass("newluckylottery");

function tbLottery:OnUse()
	local nDate =  tonumber(GetLocalDate("%Y%m%d"));
	if nDate < NewLottery:GetFirstDate() then
		Dialog:Say("抽奖还未开启呢，请过些天再使用吧");
		return;
	end
	if it.nLevel == 1 then
		me.AddBindCoin(NewLottery.BASE_BIND_COIN, Player.emKBINDCOIN_ADD_LOTTERY_ITEM);
	else
		if  me.GetBindMoney() + NewLottery.BASE_BIND_MONEY >  me.GetMaxCarryMoney() then
			me.Msg("您的绑银已达上限，还是整理下再使用吧！");
			return 0;
		end
		me.AddBindMoney(NewLottery.BASE_BIND_MONEY, Player.emKBINDCOIN_ADD_EVENT);
	end
	local nIsStudioRole = IpStatistics:IsStudioRole(me);
	NewLottery:UseTicket(me.szName, me.nId, nIsStudioRole);
	return 1;
	--it.Delete(me);
end
