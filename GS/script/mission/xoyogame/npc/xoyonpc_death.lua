
-- 

local XoyoNpc_Death = Npc:GetClass("xoyonpc_death")

function XoyoNpc_Death:OnDeath(pKiller)
	XoyoGame:NpcUnLock(him);
	XoyoGame.XoyoChallenge:KillNpcForCard(pKiller.GetPlayer(), him);
	
	--³É¾Í
	local pPlayer = pKiller.GetPlayer();
	if pPlayer then
		Achievement:FinishAchievement(pPlayer, 200);
	end
end

--?pl DoScript("\\script\\mission\\xoyogame\\npc\\xoyonpc_death.lua")

