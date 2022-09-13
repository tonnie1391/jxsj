
local tbNpc = Npc:GetClass("heartmonster")

function tbNpc:OnDeath(pKiller)
	local pPlayer = pKiller.GetPlayer();
	if not pPlayer then
		return 0;
	end
	local tbTmp = him.GetTempTable("KinGame");
	local tbHeartMonster = KinGame.tbHeartMonster;
	local nMapId 	= him.nMapId;
	local nPosX 	= math.floor(tbHeartMonster.MONSTERROOM[tbTmp.nRoomId].tbPlayerOut[1]/32);
	local nPosY		=	math.floor(tbHeartMonster.MONSTERROOM[tbTmp.nRoomId].tbPlayerOut[2]/32);
	local pGame =  KinGame:GetGameObjByMapId(nMapId) --获得对象
	pGame:DelHeartRoomNpc(pPlayer.nId, him.dwId);
	local pItem = pPlayer.AddItemEx(unpack(tbHeartMonster.MIYAO_ITEM_ID));
	if pItem then
		me.SetItemTimeout(pItem, tbHeartMonster.MIYAO_ITEM_TIME);
		pItem.Sync();
		pPlayer.Msg("您战胜了心魔，获得了秘药。");
	else
		pPlayer.Msg("你的背包已满！");
	end
	KinGame:GiveEveryOneAward(nMapId);
	tbHeartMonster:AddMonsterItem(tbTmp.nRoomId, nMapId);
	pPlayer.NewWorld(nMapId, nPosX, nPosY);
end

