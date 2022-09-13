-------------------------------------------------------
-- 文件名　：newland_npc_pole.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-09-17 09:54:40
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\globalserverbattle\\newland\\newland_def.lua");

local tbNpc = Npc:GetClass("newland_npc_pole");

-- 死亡回调
function tbNpc:OnDeath(pNpcKiller)
	
	-- 找到击杀玩家
	local pPlayer = pNpcKiller.GetPlayer();
	
	-- 回调系统
	if Newland.tbPole[him.dwId] then
		Newland:OnOccupyPole(pPlayer, him.dwId);
	end
	
	if not pPlayer then
		return 0;
	end
	
	-- 所属阵营
	local nGroupIndex = Newland:GetPlayerGroupIndex(pPlayer);
	if nGroupIndex <= 0 then
		return 0;
	end
	
	-- 频道公告
	local szGroupName = Newland:GetGroupNameByIndex(nGroupIndex);
	local nMapLevel = Newland:GetMapLevel(him.nMapId);
	local szMsg = string.format("[%s chiến báo]<color=yellow>[%s]<color>-<color=green>[%s]<color> chiếm lĩnh <color=yellow>[%s]<color>", Newland.MAP_LEVEL_NAME[nMapLevel] or "Không rõ", szGroupName, me.szName, him.szName);
	
	Newland:BroadCast_GS(szMsg, Newland.SYSTEM_CHANNEL_MSG);
	StatLog:WriteStatLog("stat_info", "newland", "capture", pPlayer.nId, szGroupName, GetLocalDate("%Y_%m_%d_%H_%M"), him.szName, him.nMapId);
end
