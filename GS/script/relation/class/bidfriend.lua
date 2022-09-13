--=================================================
-- 文件名　：bidfriend.lua
-- 创建者　：furuilei
-- 创建时间：2010-08-30 10:05:20
-- 功能描述：普通好友逻辑
--=================================================

Require("\\script\\relation\\relation_logic.lua");
local tbBidFriend = {};

if (not MODULE_GC_SERVER and not MODULE_GAMESERVER) then
	return;
end

if (MODULE_GC_SERVER) then





	
end
















if (MODULE_GAMESERVER) then

-- 加完普通好友之后的统一回调
function tbBidFriend:ProcessAfterAddRelation_GS(nRole, nAppId, nDstId)
	if (not nRole or not nAppId or not nDstId) then
		return;
	end
	
	local pPlayerApp = KPlayer.GetPlayerObjById(nAppId);
	local pPlayerDst = KPlayer.GetPlayerObjById(nDstId);
	if (pPlayerApp) then
		pPlayerApp.SetTask(Player.TSKGROUP_NEWPLAYER_GUIDE, Player.TSKID_NEWPLAYER_FRIEND, 1);
	end
	if (pPlayerDst) then
		pPlayerDst.SetTask(Player.TSKGROUP_NEWPLAYER_GUIDE, Player.TSKID_NEWPLAYER_FRIEND, 1);
	end
	
end



end

Relation:Register(Player.emKPLAYERRELATION_TYPE_BIDFRIEND, tbBidFriend)
