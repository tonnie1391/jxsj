--=================================================
-- 文件名　：trained.lua
-- 创建者　：furuilei
-- 创建时间：2010-08-30 10:10:10
-- 功能描述：师徒关系逻辑（出师的师徒关系，也就是师徒密友）
--=================================================

Require("\\script\\relation\\relation_logic.lua");
local tbTrained = {};

if (not MODULE_GC_SERVER and not MODULE_GAMESERVER) then
	return;
end

if (MODULE_GC_SERVER) then
	
end

if (MODULE_GAMESERVER) then
	
end

Relation:Register(Player.emKPLAYERRELATION_TYPE_TRAINED, tbTrained)
