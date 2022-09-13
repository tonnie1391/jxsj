-------------------------------------------------------
-- 文件名　：atlantis_npc_mover.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2011-03-21 19:47:26
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\boss\\atlantis\\atlantis_def.lua");

local tbNpc = Npc:GetClass("atlantis_npc_mover");

-- 死亡事件
function tbNpc:OnDeath(pNpcKiller)
	Atlantis:OnMoverDeath(him);
end;
