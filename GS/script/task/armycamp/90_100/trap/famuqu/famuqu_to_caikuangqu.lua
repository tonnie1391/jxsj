-- 伐木区到采矿区
local tbMap	= Map:GetClass(557);
local tbTrap_1 = tbMap:GetTrapClass("to_caikuanqu");

function tbTrap_1:OnPlayer()
	local nSubWorld, _, _	= me.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	
	if (tbInstancing.nFaMuQuTrapOpen ~= 1) then
		me.NewWorld(me.nMapId, 1842, 3399);
		Task.tbArmyCampInstancingManager:ShowTip(me, "Phải tiêu diệt Quản đốc Thợ mỏ mới có thể vào!");
	else
		me.NewWorld(me.nMapId, 1913,3316);
		Task.tbArmyCampInstancingManager:ShowTip(me, "Đã vào Tê Giác Khoáng");
	end
end
