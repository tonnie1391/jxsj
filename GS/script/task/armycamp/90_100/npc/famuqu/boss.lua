
-- 第二层左边的 BOSS
local tbNpc_1	= Npc:GetClass("famuquboss");

function tbNpc_1:OnDeath(pNpc)
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	Task.tbArmyCampInstancingManager:ShowTip(me, "Lối vào mật đạo đã được mở!");
	tbInstancing.nFaMuQuTrapOpen = 1;
end

