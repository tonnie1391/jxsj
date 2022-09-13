-------------------------------------------------------
-- 文件名　：biddingmoney.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-06-13 16:14:28
-- 文件描述：
-------------------------------------------------------

local tbItem = Item:GetClass("biddingmoney");

function tbItem:OnUse()
	
	local nValue = it.GetExtParam(1);
	if nValue <= 0 then
		return 0;
	end

	local nCurrentMoney = KGCPlayer.OptGetTask(me.nId, KGCPlayer.TSK_CURRENCY_MONEY);
	if nCurrentMoney + nValue <= me.GetMaxCarryMoney() then
		me.AddGlbBindMoney(nValue);
	end
	
	return 1;
end
