
-- 防守NPC脚本

local tbNpc = Npc:GetClass("defendnpc_jiangling");

function tbNpc:OnDeath(pKiller)
	local pPlayer = pKiller.GetPlayer()
	if not pPlayer then
		return
	end
	local nMapId = him.GetWorldPos()
	if not Domain.tbGame[nMapId] then		-- 不在征战地图
		return 0;	
	end
	local nRate = 0.1;
	if Domain.CLOSE_SHARE == 1 then
		nRate = 0;
	end
	Domain.tbGame[nMapId]:AddPlayerScore(pPlayer, Domain.SCORE_JIANGLING, math.floor(Domain.SCORE_JIANGLING * nRate), "击退"..him.szName);
	Domain.tbGame[nMapId]:AddTeamTask(pPlayer, Domain.KILL_PLAYER);
end




