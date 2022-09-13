local tbPawn = Npc:GetClass("xoyonpc_invade_pawn");
local tbBoss = Npc:GetClass("xoyonpc_invade_boss");

function tbPawn:OnArrive(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);	
	local tbRoom = pNpc.GetTempTable("XoyoGame").tbRoom;
	if tbRoom and tbRoom.szName == "RoomInvade" then
		tbRoom:PawnArrive();
	end
end

function tbPawn:OnDeath(pKiller)
	local tbRoom = him.GetTempTable("XoyoGame").tbRoom;
	if tbRoom and tbRoom.szName == "RoomInvade" then
		tbRoom:PawnDie(him);
	end
end

function tbBoss:OnLifePercentReduceHere(nPercent)
	return;
end

function tbBoss:OnDeath()
	local tbRoom = him.GetTempTable("XoyoGame").tbRoom;
	if tbRoom and tbRoom.szName == "RoomInvade" then
		tbRoom:BossDie();
	end
end