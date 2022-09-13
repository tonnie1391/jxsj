local tbLottery = Item:GetClass("luckylottery");

function tbLottery:OnUse()
	me.AddBindCoin(Lottery.BASE_BIND_COIN);
	Lottery:UseTicket(me.szName, me.nId);
	--StatLog:WriteStatLog("stat_info", "mid_autumn2011", "yutu_card",me.nId,  1);
	return 1;
	--it.Delete(me);
end
