--·¥Ä¾Çø--Àë¿ªöùÉñµî

local tbMap	= Map:GetClass(557);
local tbTrap_1 = tbMap:GetTrapClass("to_exitshanzhuang");

function tbTrap_1:OnPlayer()
	me.NewWorld(me.nMapId, 1630, 3638);
	me.SetFightState(0);
	TaskAct:StepOverEvent("Àë¿ª·üÅ£É½×¯¾ÉÖ·");
end


