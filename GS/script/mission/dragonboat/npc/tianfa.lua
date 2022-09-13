local tbNpc = Npc:GetClass("dragonboat_tianfa");

function tbNpc:OnDialog()
	local tb = him.GetTempTable("Npc");
	if not tb.DragonBoat then
		return 0;
	end
	
	local tbMis = Esport.DragonBoat:GetPlayerMission(me);
	if not tbMis or tbMis:IsOpen() ~= 1 then
		return 0;
	end
	if tbMis:GetPlayerGroupId(me) <= 0 or tbMis:GetRank(me) >= Esport.DragonBoat.DEF_FINISH_RANK then
		return 0;
	end
	
	local nGroup = tb.DragonBoat.nGroup;
	local nPoint = tb.DragonBoat.nPoint;
	Esport.DragonBoat:OnPlayerType3(nGroup, nPoint);
	him.Delete();
end
