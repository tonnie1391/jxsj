-- 文件名　：returnbindcoin.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-06-01 16:33:48
--绑金返还券

local tbItem = Item:GetClass("returnbindcoin");

function tbItem:OnUse()
	local nCount = tonumber(it.GetExtParam(1));
	if nCount <= 0 then
		me.Msg("道具出问题，请联系GM");
		return 0;
	end
	local nTolCount = me.GetTask(2138, 11);
	if nTolCount + nCount > 2000000000 then
		me.Msg("您的返还点过多，暂时不能使用这个道具。");
		return 0;
	end
	me.SetTask(2138,11,nTolCount + nCount);
	me.Msg(string.format("恭喜您获得<color=yellow>%s<color>消耗返还绑金点。", nCount));
	return 1;
end
