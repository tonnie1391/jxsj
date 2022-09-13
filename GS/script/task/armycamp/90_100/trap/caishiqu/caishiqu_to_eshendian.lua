--伐木区--蛮瘴山

local tbMap	= Map:GetClass(557);
local tbTrap_1 = tbMap:GetTrapClass("to_eshendian");

function tbTrap_1:OnPlayer()
	me.NewWorld(me.nMapId, 1807, 3773);
	TaskAct:StepOverEvent("请找云小刀带路进入鳄神殿");
end


