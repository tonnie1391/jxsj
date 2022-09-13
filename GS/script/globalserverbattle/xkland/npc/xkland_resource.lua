-------------------------------------------------------
-- 文件名　：xkland_resource.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-05-10 16:58:53
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\globalserverbattle\\xkland\\xkland_def.lua");

local tbNpc = Npc:GetClass("xkland_resource");

-- 死亡回调
function tbNpc:OnDeath(pNpcKiller)
	
	-- 找到击杀玩家
	local pPlayer = pNpcKiller.GetPlayer();
	
	-- 回调系统
	if Xkland.tbResource[him.dwId] then
		Xkland:OnGetResouce(pPlayer, him.dwId);
	end
	
	if not pPlayer then
		return 0;
	end
	
	-- 所属阵营
	local nGroupIndex = Xkland:GetGroupIndex(pPlayer);
	if nGroupIndex <= 0 then
		return 0;
	end
	
	-- 频道公告
	local szGroupName = Xkland:GetGroupNameByIndex(nGroupIndex);
	local szMapName = Xkland.MAP_NAME[pPlayer.nMapId];
	local szMsg = string.format("<color=green>%s<color>的<color=yellow>%s<color>占领了%s的%s。", szGroupName, pPlayer.szName, szMapName, him.szName);
	
	Xkland:BroadCast_GS(szMsg, Xkland.BOTTOM_BLACK_MSG);
	Xkland:BroadCast_GS(szMsg, Xkland.SYSTEM_CHANNEL_MSG);
end
