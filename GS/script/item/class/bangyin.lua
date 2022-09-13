-------------------------------------------------------------------
--Describe:	增加武林大会专用绑银道具

local tbBangYin = Item:GetClass("bangyin");

function tbBangYin:OnUse()
	local nValue = it.GetExtParam(1);
	if nValue <= 0 then
		return 0;
	end
	local nCurrentMoney = KGCPlayer.OptGetTask(me.nId, KGCPlayer.TSK_CURRENCY_MONEY);
	if nCurrentMoney + nValue <= me.GetMaxCarryMoney() then
		GCExcute{"Player:Nor_DataSync_GC", me.szName, nValue}
		me.Msg("你成功增加了"..nValue.."两的武林大会专用银两。");
	else
		me.Msg("对不起，您身上的武林大会专用银两在使用该道具后将会达到上限，还不能使用。")
	end
	return 1;
end