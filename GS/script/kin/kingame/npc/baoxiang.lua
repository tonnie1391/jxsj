local tbNpc = Npc:GetClass("kingame_baoxiang")

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

function tbNpc:OnDialog()
	GeneralProcess:StartProcess("打开铜钱箱中...", 10 * Env.GAME_FPS, {self.DoPickUp, self, me.nId, him.dwId}, nil, tbEvent);	
	return 0;
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
		local pGame =  KinGame:GetGameObjByMapId(pNpc.nMapId) --获得对象
		local nCountMax = pGame:GetPlayerCount();
		local nAwardMultip = pGame.nAwardMultip;
		local nExCount = (nCountMax * nAwardMultip) - nCountMax;
		local nExPlayer = KinGame:GetRandomTable(nCountMax, nExCount);
		local tbPlayer = pGame:GetPlayerList();
		for ni, pGamePlayer in pairs(tbPlayer) do
			KinGame:GiveAwardItem(pGamePlayer, 1);
			if nExPlayer[ni] == 1 then
				KinGame:GiveAwardItem(pGamePlayer, 1);
			end
		end
		pNpc.Delete();
		return 0;
end