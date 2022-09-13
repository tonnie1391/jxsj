-- 文件名  : castlefight_building.lua
-- 创建者  : zounan
-- 创建时间: 2010-11-23 14:37:14
-- 描述    : 

local tbNpc = Npc:GetClass("castlefight_building");

function tbNpc:OnDeath(pKiller)
	local tbMission = him.GetTempTable("Npc").tbMission;
	
	if not tbMission or tbMission:IsPlaying() == 0 then
		return;
	end
	local pPlayer = pKiller.GetPlayer();			
	if not pPlayer then	
		local nPlayerId = CastleFight:GetNpcOwnerId(pKiller);
		if nPlayerId <= 0 then
			return;
		end
	end
	tbMission:OnNpcDeath(him, pKiller);
end
