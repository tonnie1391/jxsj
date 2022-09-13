-------------------------------------------------------
-- 文件名　：newland_npc_throne.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-09-19 09:41:33
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\globalserverbattle\\newland\\newland_def.lua");

local tbNpc = Npc:GetClass("newland_npc_throne");

function tbNpc:OnDialog()
	
	local nGroupIndex = Newland:GetPlayerGroupIndex(me);
	if nGroupIndex <= 0 or Newland:CheckOccupyThrone(nGroupIndex) ~= 1 then
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
	GeneralProcess:StartProcess("Đang chiếm", 20 * Env.GAME_FPS, {self.OnOccupyThrone, self, him.dwId}, nil, tbBreakEvent);
end

-- 占领王座
function tbNpc:OnOccupyThrone(pNpcDwId)
	
	local pNpc = KNpc.GetById(pNpcDwId);
	if not pNpc then
		return 0;
	end
	
	-- 所属阵营
	local nGroupIndex = Newland:GetPlayerGroupIndex(me);
	if nGroupIndex <= 0 or Newland:CheckOccupyThrone(nGroupIndex) ~= 1 then
		return 0;
	end
	
	-- 频道公告
	local szGroupName = Newland:GetGroupNameByIndex(nGroupIndex);
	local szMsg = string.format("<color=yellow>[%s]<color>-<color=green>[%s]<color>cai trị %s.", szGroupName, me.szName, pNpc.szName);
	
	Newland:BroadCast_GS(szMsg, Newland.MIDDLE_RED_MSG);
	Newland:BroadCast_GS(szMsg, Newland.SYSTEM_CHANNEL_MSG);
	
	local nGroupIndex = Newland:GetPlayerGroupIndex(me);
	Newland:OnOccupyThrone(me.szName, nGroupIndex, pNpc.dwId);
	
	-- buffer
	me.AddSkillState(Newland.THRONE_BUFFER, 1, 1, Newland.THRONE_BUFFER_TIME, 1, 1);
	me.NewWorld(unpack(Newland.THRONE_POS));
	
	-- log
	StatLog:WriteStatLog("stat_info", "newland", "capture", me.nId, szGroupName, GetLocalDate("%Y_%m_%d_%H_%M"), pNpc.szName, pNpc.nMapId);
end
