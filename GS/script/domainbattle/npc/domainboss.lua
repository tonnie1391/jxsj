
-- 领土战BOSS

local tbNpc = Npc:GetClass("domainboss")

function tbNpc:OnDeath(pKiller)
	local nMapId = him.GetWorldPos()
	if not Domain.tbGame[nMapId] then		-- 不在征战地图
		return 0;	
	end
	Domain.tbGame[nMapId]:OnBossDeath(him, pKiller);
end


