-- 

local tbMap	= Map:GetClass(557);
local tbTrap_1 = tbMap:GetTrapClass("guanka1a");

function tbTrap_1:OnPlayer()
	local nSubWorld, _, _	= me.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if (tbInstancing.tbBarrierPairs[2][3] ~= 1) then
		me.NewWorld(nSubWorld, 1935, 3306);
		Task.tbArmyCampInstancingManager:ShowTip(me, "Lối đi bị khóa chặt, có vẻ như đã bị khóa bởi 1 cơ quan.");
	end
end

local tbTrap_2 = tbMap:GetTrapClass("guanka1b");

function tbTrap_2:OnPlayer()
	local nSubWorld, _, _	= me.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if (tbInstancing.tbBarrierPairs[1][3] ~= 1) then
		me.NewWorld(nSubWorld, 1925,3292);
		Task.tbArmyCampInstancingManager:ShowTip(me, "Lối đi bị khóa chặt, có vẻ như đã bị khóa bởi 1 cơ quan.");
	end
end

local tbTrap_3 = tbMap:GetTrapClass("guanka2a");

function tbTrap_3:OnPlayer()
	local nSubWorld, _, _	= me.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if (tbInstancing.tbBarrierPairs[4][3] ~= 1) then
		me.NewWorld(nSubWorld, 2006, 3353);
		Task.tbArmyCampInstancingManager:ShowTip(me, "Lối đi bị khóa chặt, có vẻ như đã bị khóa bởi 1 cơ quan.");
	end
end


local tbTrap_4 = tbMap:GetTrapClass("guanka2b");

function tbTrap_4:OnPlayer()
	local nSubWorld, _, _	= me.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if (tbInstancing.tbBarrierPairs[3][3] ~= 1) then
		me.NewWorld(nSubWorld, 2000, 3334);
		Task.tbArmyCampInstancingManager:ShowTip(me, "Lối đi bị khóa chặt, có vẻ như đã bị khóa bởi 1 cơ quan.");
	end
end


local tbTrap_5 = tbMap:GetTrapClass("guanka3a");

function tbTrap_5:OnPlayer()
	local nSubWorld, _, _	= me.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if (tbInstancing.tbBarrierPairs[6][3] ~= 1) then
		me.NewWorld(nSubWorld, 1975, 3426);
		Task.tbArmyCampInstancingManager:ShowTip(me, "Lối đi bị khóa chặt, có vẻ như đã bị khóa bởi 1 cơ quan.");
	end
end


local tbTrap_6 = tbMap:GetTrapClass("guanka3b");

function tbTrap_6:OnPlayer()
	local nSubWorld, _, _	= me.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if (tbInstancing.tbBarrierPairs[5][3] ~= 1) then
		me.NewWorld(nSubWorld, 1963, 3455);
		Task.tbArmyCampInstancingManager:ShowTip(me, "Lối đi bị khóa chặt, có vẻ như đã bị khóa bởi 1 cơ quan.");
	end
end


local tbTrap_7 = tbMap:GetTrapClass("guanka3aa");
function tbTrap_7:OnPlayer()
	local nSubWorld, _, _	= me.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if (tbInstancing.tbBarrierPairs[6][3] ~= 1) then
		me.NewWorld(nSubWorld, 1961, 3437);
		Task.tbArmyCampInstancingManager:ShowTip(me, "Lối đi bị khóa chặt, có vẻ như đã bị khóa bởi 1 cơ quan.");
	end
end



local tbTrap_8 = tbMap:GetTrapClass("guanka3bb");
function tbTrap_8:OnPlayer()
	local nSubWorld, _, _	= me.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if (tbInstancing.tbBarrierPairs[5][3] ~= 1) then
		me.NewWorld(nSubWorld, 1952, 3441);
		Task.tbArmyCampInstancingManager:ShowTip(me, "Lối đi bị khóa chặt, có vẻ như đã bị khóa bởi 1 cơ quan.");
	end
end


local tbTrapBack = tbMap:GetTrapClass("to_famuqu");

function tbTrapBack:OnPlayer()
	me.NewWorld(me.nMapId, 1842, 3399);
end
