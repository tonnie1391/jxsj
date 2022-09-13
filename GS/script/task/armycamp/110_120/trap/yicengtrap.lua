
local tbMap = Map:GetClass(493);
local tbTrap3 = tbMap:GetTrapClass("trap3");

tbTrap3.tbSendPos = {1000, 3000};

function tbTrap3:OnPlayer()
	local nSubWorld, _, _	= me.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	
	if (tbInstancing.nTrap3Pass == 0) then
		me.NewWorld(me.nMapId, self.tbSendPos[1],self.tbSendPos[2]);
	end;
end;

local tbMap = Map:GetClass(493);
local tbTrap4 = tbMap:GetTrapClass("to_ceng2");

tbTrap4.tbSendPos = {1880, 3455};

function tbTrap4:OnPlayer()
	local nSubWorld, _, _	= me.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	
	if (tbInstancing.nTrap4Pass == 1) then
		me.NewWorld(me.nMapId, self.tbSendPos[1],self.tbSendPos[2]);
	end;
end;

