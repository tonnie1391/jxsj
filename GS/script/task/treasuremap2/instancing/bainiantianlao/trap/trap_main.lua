
local tbPrisonMap	= Map:GetClass(1737);

local tbInsideRoom	= tbPrisonMap:GetTrapClass("inside_room");


function tbInsideRoom:OnPlayer()
	local nCaptainId = me.GetTempTable("TreasureMap2").nCaptainId;
	if not nCaptainId then
		print("ERROR,bainiantianlao_ inside room");
		return;
	end

	local tbInstancing = TreasureMap2:GetInstancingByPlayerId(nCaptainId);
	if not (tbInstancing) then
		return;
	end
	
	if (not tbInstancing.nBoss) or (tbInstancing.nBoss~=1) then
		me.NewWorld(me.nMapId, 1606, 3222);
		return;
	end;
	
end;
