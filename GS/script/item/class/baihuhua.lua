--百合花

local tbItem = Item:GetClass("baihehua");

function tbItem:InitGenInfo()
	it.SetTimeOut(0, (GetTime() + 30 * 24 * 60 * 60));
	return {};
end

function tbItem:OnUse()
	local nExp = me.GetBaseAwardExp() * MathRandom(100, 500);
	me.AddExp(nExp);
	me.Msg("成功使用了一个<color=yellow>百合花<color>。")
	return 1;
end

