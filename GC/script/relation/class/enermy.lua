--=================================================
-- 文件名　：enermy.lua
-- 创建者　：furuilei
-- 创建时间：2010-08-30 10:08:16
-- 功能描述：仇人关系逻辑
--=================================================

Require("\\script\\relation\\relation_logic.lua");
local tbEnermy = {};

if (not MODULE_GC_SERVER and not MODULE_GAMESERVER) then
	return;
end

if (MODULE_GC_SERVER) then
	
end

if (MODULE_GAMESERVER) then
	
end

Relation:Register(Player.emKPLAYERRELATION_TYPE_ENEMEY, tbEnermy)
