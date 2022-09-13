--伐木区--蛮瘴山

local tbMap	= Map:GetClass(557);
local tbTrap_1 = tbMap:GetTrapClass("to_manzhangshan");

function tbTrap_1:OnPlayer()
	me.NewWorld(me.nMapId, 1831, 3080);
	TaskAct:StepOverEvent("请找云大刀带路进入蛮瘴山");
end


