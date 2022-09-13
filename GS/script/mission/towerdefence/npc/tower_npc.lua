-- 文件名　：tower_npc.lua
-- 创建者　：jiazhenwei
-- 创建时间：2010-03-09 09:44:29
-- 描  述  ：tower 

local tbNpc = Npc:GetClass("td_tower");
tbNpc.tbLifeAbout = {100, 200, 300};		--每种等级植物的生命值

function tbNpc:OnDeath(pNpcKiller)	
	local tbMission = him.GetTempTable("Npc").tbMission;	
	if not tbMission then
		return;
	end	
	if tbMission:IsOpen() ~= 1 then
		return;
	end
	tbMission:DelTower(him.dwId);
	return;
end
