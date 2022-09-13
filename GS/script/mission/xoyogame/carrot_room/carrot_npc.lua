local tbCarrot = Npc:GetClass("xoyonpc_carrot") -- id:4658
local tbBreakEvent = {
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
	};

tbCarrot.PICK_TIME = 2.5; --采集时间（秒）

function tbCarrot:OnDialog()
	if me.CountFreeBagCell() < 1 then
		me.Msg("你的背包已经满啦！");
		return;
	end
		
	GeneralProcess:StartProcess("采萝卜...", self.PICK_TIME * Env.GAME_FPS, 
			{self.PickCallback, self, me.nId, him.dwId}, nil, tbBreakEvent);
end

function tbCarrot:PickCallback(nPlayerId, dwNpcId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	local pNpc = KNpc.GetById(dwNpcId);
	if not pPlayer or not pNpc then
		return;
	end
	if pPlayer.CountFreeBagCell() < 1 then
		pPlayer.Msg("你的背包已经满啦！");
		return;
	end
	
	local tbRoom = pNpc.GetTempTable("XoyoGame").tbRoom;
	if tbRoom then
		tbRoom:PlayerGotCarrot(pPlayer, pNpc);
	end
	
	pNpc.Delete();
end


local tbCarrotSkill = Npc:GetClass("xoyonpc_carrot_skill")
tbCarrotSkill.PICK_TIME = 2.5;

function tbCarrotSkill:OnDialog()
	return;
end

