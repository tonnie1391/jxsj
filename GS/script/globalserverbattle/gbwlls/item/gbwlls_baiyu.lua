-- 白玉
local tbItem = Item:GetClass("baiyu");

function tbItem:OnUse()
	local nFlag = Player:AddRepute(me, 12, 1, 100);

	if (0 == nFlag) then
		return;
	elseif (1 == nFlag) then
		me.Msg("您已经达到跨服武林联赛声望最高等级，将无法使用白玉");
		return;
	end
	return 1;
end