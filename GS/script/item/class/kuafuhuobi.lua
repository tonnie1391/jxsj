-------------------------------------------------------------------
--Describe:	增加武林大会专用绑银道具

local tbKuaFuHuoBi = Item:GetClass("kuafuhuobi");

function tbKuaFuHuoBi:OnUse()
	local nValue = it.GetExtParam(1);
	if nValue <= 0 then
		return 0;
	end
	if GLOBAL_AGENT then
		me.Msg("对不起，您身上的武林大会专用银两请在普通服务器里使用。")
		return 0;
	end
	local nCurrentMoney = KGCPlayer.OptGetTask(me.nId, KGCPlayer.TSK_CURRENCY_MONEY);
	if nCurrentMoney + nValue <= me.GetMaxCarryMoney() then
		me.AddGlbBindMoney(nValue);
		return 1;
	else
		me.Msg("对不起，您身上的武林大会专用银两在使用该道具后将会达到上限，还不能使用。")
		return 0;
	end
end
