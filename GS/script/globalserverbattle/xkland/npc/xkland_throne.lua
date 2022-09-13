-------------------------------------------------------
-- 文件名　：xkland_throne.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-05-13 16:26:19
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\globalserverbattle\\xkland\\xkland_def.lua");

local tbNpc = Npc:GetClass("xkland_throne");

function tbNpc:OnDialog()
	
	local nGroupIndex = Xkland:GetGroupIndex(me);
	if nGroupIndex <= 0 or Xkland:CheckOccupyThrone(nGroupIndex) ~= 1 then
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
	local nGroupIndex = Xkland:GetGroupIndex(me);
	if nGroupIndex <= 0 or Xkland:CheckOccupyThrone(nGroupIndex) ~= 1 then
		return 0;
	end
	
	-- 频道公告
	local szGroupName = Xkland:GetGroupNameByIndex(nGroupIndex);
	local szMsg = string.format("<color=green>%s<color>的<color=yellow>%s<color>占领了%s。", szGroupName, me.szName, pNpc.szName);
	
	Xkland:BroadCast_GS(szMsg, Xkland.MIDDLE_RED_MSG);
	Xkland:BroadCast_GS(szMsg, Xkland.SYSTEM_CHANNEL_MSG);
	
	local nGroupIndex = Xkland:GetGroupIndex(me);
	Xkland:OnOccupyThrone(me.szName, nGroupIndex);
	
	-- buffer
	me.AddSkillState(Xkland.THRONE_BUFFER, 1, 1, Xkland.THRONE_BUFFER_TIME, 1, 1);
	me.NewWorld(unpack(Xkland.THRONE_POS));
end
