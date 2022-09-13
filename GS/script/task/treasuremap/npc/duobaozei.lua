
local tbNpc = Npc:GetClass("duobaozei");

function tbNpc:OnDeath(pNpc)
	
	local pPlayer, pOrgPlayer = nil, nil;
	if him.GetTempTable("TreasureMap").nPlayerId then
		pOrgPlayer	= KPlayer.GetPlayerObjById(him.GetTempTable("TreasureMap").nPlayerId);
		
		if pOrgPlayer then
			pPlayer = pOrgPlayer;
		else
			pPlayer = pNpc.GetPlayer();
		end;
	else
		pPlayer = pNpc.GetPlayer();
	end;
	
	if (pPlayer) then
		print ("Kill MuggerId: "..pNpc.nTemplateId);
		if him.nTemplateId == TreasureMap.nMuggerId then
			pPlayer.DropRateItem(TreasureMap.szDuoBaoZeiDropFilePath, TreasureMap.nDuoBaoZeiDropCount, -1, -1, him);
		elseif him.nTemplateId == TreasureMap.nMuggerId_Level2 then
			pPlayer.DropRateItem(TreasureMap.szDuoBaoZeiDrop_Level2, TreasureMap.nDuoBaoZeiDropCount, -1, -1, him);
		elseif him.nTemplateId == TreasureMap.nMuggerId_Level3 then
			pPlayer.DropRateItem(TreasureMap.szDuoBaoZeiDrop_Level3, TreasureMap.nDuoBaoZeiDropCount, -1, -1, him);
		end;
	end
end

