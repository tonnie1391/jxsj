--伐木区--进入玄冰潭

local tbMap	= Map:GetClass(557);
local tbTrap_1 = tbMap:GetTrapClass("to_xuanbingtan");

function tbTrap_1:OnPlayer()
	me.NewWorld(me.nMapId, 1980, 2891);
	TaskAct:StepOverEvent("进入玄冰潭");
end


