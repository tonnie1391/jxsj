-------------------------------------------------------
-- 文件名　：kinbattle_npc_houyingenter.lua
-- 创建者　：huangxiaoming
-- 创建时间：2010-12-07 16:48:15
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\mission\\kinbattle\\kinbattle_def.lua");

local tbNpc = Npc:GetClass("kinbattle_npc_houyingenter");

function tbNpc:OnDialog()
	local tbPlayerInfo = KinBattle:GetPlayerInfo(me);
	local tbMission = tbPlayerInfo.tbMission;
	if not tbMission then
		me.NewWorld(unpack(KinBattle.DEFAULT_POS));
		return 0;
	end
	local tbCamp = tbPlayerInfo.tbCamp;
	tbCamp:TransToPrepare(me);
end
