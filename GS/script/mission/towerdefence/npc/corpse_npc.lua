-- 文件名　：corpse_npc.lua
-- 创建者　：jiazhenwei
-- 创建时间：2010-03-09 09:26:23
-- 描  述  ：怪脚本

local tbNpc = Npc:GetClass("td_corpse");

function tbNpc:OnDeath(pNpcKiller)		
	local nType = him.GetTempTable("Npc").nType;
	local tbMission = him.GetTempTable("Npc").tbMission;
	if not tbMission then
		return;
	end	
	if tbMission:IsOpen() ~= 1 then
		return;
	end	
	if nType == 1 then
		tbMission:DelBoss(him.dwId, pNpcKiller.dwId);
	else
		tbMission:OnDeathNpc(him.dwId, pNpcKiller.dwId, 0);
	end
end
