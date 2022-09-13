-- 文件名　：returnjifen.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-06-01 16:34:19
--积分商城积分返还券


local tbItem = Item:GetClass("returnjifen");

function tbItem:OnUse()
	local nCount = tonumber(it.GetExtParam(1));
	if nCount <= 0 then
		me.Msg("道具出问题，请联系GM");
		return 0;
	end
	local nTolCount = me.GetTask(2070, 9);
	me.SetTask(2070, 9,nTolCount + nCount);
	me.Msg(string.format("恭喜您获得<color=yellow>%s<color>消耗积分返还点。", nCount));
	return 1;
end

