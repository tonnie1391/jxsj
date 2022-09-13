-- 文件名  : castlefight_soldier.lua
-- 创建者  : zounan
-- 创建时间: 2010-11-11 10:17:53
-- 描述    : 

local tbNpc = Npc:GetClass("castlefight_soldier");

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

--[[
local tbNpc = Npc:GetClass("castlefight_building");

function tbNpc:OnDeath(pKiller)
	local tbMission = him.GetTempTable("Npc").tbMission;
	
	if not tbMission or tbMission:IsPlaying() == 0 then
		return;
	end
	tbMission:OnNpcDeath(him, pKiller);
end
--]]