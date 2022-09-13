-------------------------------------------------------
-- 文件名　：npc_defender.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-06-17 18:19:00
-- 文件描述：
-------------------------------------------------------

-- "\\setting\\npc\npc.txt"
local tbDefender = Npc:GetClass("npc_defender");

-- death event
function tbDefender:OnDeath(pNpcKiller)
	
	-- find player
	local pPlayer = pNpcKiller.GetPlayer();
	
	-- not found
	if not pPlayer then
		return 0;
	end
	
	-- get team
	local nTeamId = pPlayer.nTeamId;
	
	-- lonely
	if nTeamId == 0 then
		-- add item
		self:AddHeroItem(pPlayer);
	else
		-- deal team
		local tbPlayerId, nMemberCount = KTeam.GetTeamMemberList(nTeamId);
		
		-- add everyone
		for i, nPlayerId in pairs(tbPlayerId) do
			
			-- get team player
			local pTeamPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			
			-- in same map
			if (pTeamPlayer and pTeamPlayer.nMapId == him.nMapId) then
				-- add item
				self:AddHeroItem(pTeamPlayer);
			end
		end
	end
end;

function tbDefender:AddHeroItem(pPlayer)
	
	-- free space more then one
	if pPlayer.CountFreeBagCell() >= 1 then
		pPlayer.AddItem(22, 1, 71, 1);
		
	-- drop to map
	else
		local nMapId, nMapX, nMapY = pPlayer.GetWorldPos();
		KItem.AddItemInPos(nMapId, nMapX, nMapY, 22, 1, 71, 1, -1);
	end
end
