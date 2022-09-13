-------------------------------------------------------
-- 文件名　：army_supplybag.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-09-08 14:41:59
-- 文件描述：
-------------------------------------------------------

local tbItem = Item:GetClass("army_supplybag");

function tbItem:OnUse()
	
	local nShengWang = 300;
	
	local nTimes = tonumber(it.GetExtParam(1));
	if nTimes > 0 then
		nShengWang = nShengWang * nTimes;
	end
	
	local nFlag = Player:AddRepute(me, 1, 2, nShengWang);
	
	if (0 == nFlag) then
		return;
	elseif (1 == nFlag) then
		me.Msg("您的军营声望已经达到上限！");
		return;
	end
	
	return 1;	
end;