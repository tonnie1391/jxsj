-------------------------------------------------------
-- 文件名　 : superbattle_npc_pole.lua
-- 创建者　 : zhangjinpin@kingsoft
-- 创建时间 : 2011-06-02 15:30:39
-- 文件描述 :
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\globalserverbattle\\superbattle\\superbattle_def.lua");

local tbNpc = Npc:GetClass("superbattle_npc_pole");

function tbNpc:OnDialog()
	
	if SuperBattle:CheckOccupyPole(me, him.dwId) ~= 1 then
		return 0;
	end
	
	local tbBreakEvent = 
	{
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
		Player.ProcessBreakEvent.emEVENT_SIT,
		Player.ProcessBreakEvent.emEVENT_RIDE,
		Player.ProcessBreakEvent.emEVENT_USEITEM,
		Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
		Player.ProcessBreakEvent.emEVENT_DROPITEM,
		Player.ProcessBreakEvent.emEVENT_CHANGEEQUIP,
		Player.ProcessBreakEvent.emEVENT_SENDMAIL,		
		Player.ProcessBreakEvent.emEVENT_TRADE,
		Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
		Player.ProcessBreakEvent.emEVENT_ATTACKED,
		Player.ProcessBreakEvent.emEVENT_DEATH,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
		Player.ProcessBreakEvent.emEVENT_REVIVE,
		Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
	}
	GeneralProcess:StartProcess("Đang chiếm", 15 * Env.GAME_FPS, {self.OnOccupyPole, self, me.nId, him.dwId}, nil, tbBreakEvent);
end

function tbNpc:OnOccupyPole(pPlayerId, nNpcDwId)
	
	local pPlayer = KPlayer.GetPlayerObjById(pPlayerId);
	local pNpc = KNpc.GetById(nNpcDwId);
	if not pPlayer or not pNpc then
		return 0;
	end
	
	if SuperBattle:CheckOccupyPole(pPlayer, pNpc.dwId) ~= 1 then
		return 0;
	end
	
	SuperBattle:OccupyPole(pPlayer, pNpc.dwId);
end
