--=================================================
-- 文件名　：sibling.lua
-- 创建者　：furuilei
-- 创建时间：2010-08-30 10:09:11
-- 功能描述：结拜关系逻辑（目前还没有这个关系，不过先把这个东动写上吧）
--=================================================

Require("\\script\\relation\\relation_logic.lua");
local tbSibling = {};

if (not MODULE_GC_SERVER and not MODULE_GAMESERVER) then
	return;
end

if (MODULE_GC_SERVER) then
	
end

if (MODULE_GAMESERVER) then
	
end

Relation:Register(Player.emKPLAYERRELATION_TYPE_SIBLING, tbSibling)
