-------------------------------------------------------
-- 文件名　：xkland_revival.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-05-10 16:58:53
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\globalserverbattle\\xkland\\xkland_def.lua");

local tbNpc = Npc:GetClass("xkland_revival");

function tbNpc:OnDialog()
	
	if Xkland:GetSession() == 1 then
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
	GeneralProcess:StartProcess("Đang chiếm", 20 * Env.GAME_FPS, {self.OnOccupyFlag, self, him.dwId}, nil, tbBreakEvent);
end

function tbNpc:OnOccupyFlag(pNpcDwId)
	
	local pNpc = KNpc.GetById(pNpcDwId);
	if not pNpc then
		return 0;
	end
	
	-- 所属阵营
	local nGroupIndex = Xkland:GetGroupIndex(me);
	if nGroupIndex <= 0 then
		return 0;
	end
	
	-- 频道公告
	local szGroupName = Xkland:GetGroupNameByIndex(nGroupIndex);
	local szMapName = Xkland.MAP_NAME[me.nMapId];
	local szMsg = string.format("<color=green>%s<color>的<color=yellow>%s<color>占领了%s的%s。", szGroupName, me.szName, szMapName, pNpc.szName);
	
	Xkland:BroadCast_GS(szMsg, Xkland.BOTTOM_BLACK_MSG);
	Xkland:BroadCast_GS(szMsg, Xkland.SYSTEM_CHANNEL_MSG);
	
	-- 设置归属
	local nGroupIndex = Xkland:GetGroupIndex(me);
	Xkland:OnGetRevival(me.nMapId, nGroupIndex);
end
