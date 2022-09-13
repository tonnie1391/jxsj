-- 
-- 领土争夺战标志NPC
-- zhengyuhua
--

local tbNpc = Npc:GetClass("domain_towernpc")
	
function tbNpc:OnDeath(pKiller)
	local nMapId = him.GetWorldPos()
	if not Domain.tbGame[nMapId] then		-- 不在征战地图
		return 0;	
	end
	Domain.tbGame[nMapId]:OnTowerNpcDeath(him, pKiller);
end


