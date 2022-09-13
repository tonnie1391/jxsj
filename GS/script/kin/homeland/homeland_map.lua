-------------------------------------------------------
-- 文件名　: homeland_map.lua
-- 创建者　：huangxiaoming
-- 创建时间：2011-07-07 10:23:16
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\kin\\homeland\\homeland_def.lua")

local tbMap = Map:GetClass(HomeLand.MAP_TEMPLATE);
HomeLand.Map = tbMap;

function tbMap:OnEnter()
	local nTargetMapId = HomeLand:GetMapIdByPlayerId(me.nId)
	if nTargetMapId == 0 or nTargetMapId ~= me.nMapId then	-- 不是自己的家族领地
		Dialog:SendBlackBoardMsg(me, "这不是你的家族领地，我还是送你回去吧。");
		me.NewWorld(unpack(HomeLand.DEFAULT_POS));
		return;
	end
	me.SetFightState(0);
	local nKinId, nMemberId = me.GetKinMember();
	local cKin = KKin.GetKin(nKinId);
	SpecialEvent.tbKinPlant_2011:AddGroundNpc(nKinId, me.nMapId);
	KinPlant:AddGroundNpc(nKinId, me.nMapId);
	if cKin then
		StatLog:WriteStatLog("stat_info", "jiazulingdi", "comein", me.nId, cKin.GetName());
	end
end
