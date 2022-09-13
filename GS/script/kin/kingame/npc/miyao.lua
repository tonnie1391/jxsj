local tbNpc = Npc:GetClass("kingame_miyao")
function tbNpc:OnDialog()
	if me.CountFreeBagCell() <= 0 then
		me.Msg("背包已满，请清理背包空间。")
		return 0;
	end
	local tbEvent = 
	{
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
		Player.ProcessBreakEvent.emEVENT_SITE,
		Player.ProcessBreakEvent.emEVENT_USEITEM,
		Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
		Player.ProcessBreakEvent.emEVENT_DROPITEM,
		Player.ProcessBreakEvent.emEVENT_SENDMAIL,
		Player.ProcessBreakEvent.emEVENT_TRADE,
		Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
		Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
		Player.ProcessBreakEvent.emEVENT_DEATH,
		Player.ProcessBreakEvent.emEVENT_ATTACKED,
	}
	GeneralProcess:StartProcess("采集中...", 10 * Env.GAME_FPS, {self.DoPickUp, self, me.nId, him.dwId}, nil, tbEvent);
end

function tbNpc:DoPickUp(nPlayerId, nNpcId)
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer == nil then
			return 0;
		end
		local pNpc = KNpc.GetById(nNpcId);
		if not pNpc then
			return 0
		end
		local tbHeartMonster = KinGame.tbHeartMonster;
		local tbTmp 			= pNpc.GetTempTable("KinGame");
		local nRoomId 		= tbTmp.nRoomId;
		local nMapId 				= pNpc.nMapId;
		local nPlayerPosX 	= math.floor(tbHeartMonster.MONSTERROOM[nRoomId].tbPlayerIn[1]/32);
		local nPlayerPosY		=	math.floor(tbHeartMonster.MONSTERROOM[nRoomId].tbPlayerIn[2]/32);	
		local nNpcPosX 			= math.floor(tbHeartMonster.MONSTERROOM[nRoomId].tbNpcPos[1]/32);
		local nNpcPosY			=	math.floor(tbHeartMonster.MONSTERROOM[nRoomId].tbNpcPos[2]/32);
		local pHeartNpc		= KNpc.Add2(tbHeartMonster.MONSTERID, me.nLevel, pPlayer.nSeries, nMapId, nNpcPosX, nNpcPosY);	
		
		if pHeartNpc == nil then
			return 0;
		end
		local tbTmp 			= pHeartNpc.GetTempTable("KinGame");
		local pGame =  KinGame:GetGameObjByMapId(nMapId) --获得对象
		pGame:AddHeartRoomNpc(nPlayerId, pHeartNpc.dwId);
		tbTmp.nRoomId 		= nRoomId;
		pPlayer.NewWorld(nMapId,	nPlayerPosX,	nPlayerPosY)		
		pNpc.Delete();
		Dialog:SendBlackBoardMsg(pPlayer, "你感觉到一阵头晕……")
end
