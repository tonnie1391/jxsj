--=================================================
-- 文件名　：tmpfriend.lua
-- 创建者　：furuilei
-- 创建时间：2010-08-30 09:10:27
-- 功能描述：临时好友逻辑
--=================================================

Require("\\script\\relation\\relation_logic.lua");
local tbTmpFriend = {};

if (not MODULE_GC_SERVER and not MODULE_GAMESERVER) then
	return;
end

if (MODULE_GC_SERVER) then
	
end

if (MODULE_GAMESERVER) then
	
end

Relation:Register(Player.emKPLAYERRELATION_TYPE_TMPFRIEND, tbTmpFriend)
