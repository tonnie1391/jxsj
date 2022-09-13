--伐木区--离开蛮瘴山

local tbMap	= Map:GetClass(557);
local tbTrap_1 = tbMap:GetTrapClass("to_exitmanzhangshan");

function tbTrap_1:OnPlayer()
	me.NewWorld(me.nMapId, 1832, 3084);
	TaskAct:StepOverEvent("离开蛮瘴山");
end


