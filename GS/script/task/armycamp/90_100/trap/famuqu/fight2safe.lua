local tbMap	= Map:GetClass(557);
local tbTrap_1 = tbMap:GetTrapClass("to_fight");

function tbTrap_1:OnPlayer()
	me.NewWorld(me.nMapId, 1651,3603);
	me.SetFightState(1);
end

local tbTrap_2 = tbMap:GetTrapClass("to_safe");

function tbTrap_2:OnPlayer()
	me.NewWorld(me.nMapId, 1643,3621);
	me.SetFightState(0);
end
