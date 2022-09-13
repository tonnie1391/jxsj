--伐木区--离开玄冰潭

local tbMap	= Map:GetClass(557);
local tbTrap_1 = tbMap:GetTrapClass("to_exitxuanbingtan");

function tbTrap_1:OnPlayer()
	me.NewWorld(me.nMapId, 1927, 2947);
	TaskAct:StepOverEvent("来到蛮瘴山");
end


