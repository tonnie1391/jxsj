--=================================================
-- 文件名　：blacklist.lua
-- 创建者　：furuilei
-- 创建时间：2010-08-30 10:06:34
-- 功能描述：黑名单逻辑
--=================================================

Require("\\script\\relation\\relation_logic.lua");
local tbBlackList = {};

if (not MODULE_GC_SERVER and not MODULE_GAMESERVER) then
	return;
end

if (MODULE_GC_SERVER) then
	
end

if (MODULE_GAMESERVER) then
	
end

Relation:Register(Player.emKPLAYERRELATION_TYPE_BLACKLIST, tbBlackList)
