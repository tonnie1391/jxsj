--=================================================
-- 文件名　：intruduction.lua
-- 创建者　：furuilei
-- 创建时间：2010-08-30 10:08:44
-- 功能描述：介绍人关系逻辑
--=================================================

Require("\\script\\relation\\relation_logic.lua");
local tbIntroduction = {};

if (not MODULE_GC_SERVER and not MODULE_GAMESERVER) then
	return;
end


--=================================================
--============= MODULE_GC_SERVER ==================
--=================================================


if (MODULE_GC_SERVER) then
	

tbIntroduction.INTRODUCED_MAXLEVEL = 11;		-- 被介绍人的最高等级
tbIntroduction.INTRODUCED_MIN_DIFLEVEL = 6;		-- 介绍人与被介绍人之间的最小等级差

-- 创建人际关系的条件判断
function tbIntroduction:CanCreateRelation(nRole, nAppId, nDstId)
	if (not nRole or not nAppId or not nDstId) then
		return 0;
	end
	
	if (nRole == 0) then
		nAppId, nDstId = nDstId, nAppId;
	end
	
	local nAppLevel = KRelation.GetOneRelationCount(nAppId, Player.emKPLAYERRELATION_TYPE_INTRODUCTION, 1);
	local nDstLevel = KRelation.GetOneRelationCount(nDstId, Player.emKPLAYERRELATION_TYPE_INTRODUCTION, 0);
	if (nDstLevel > self.INTRODUCED_MAXLEVEL) then
		Relation:SetInfoMsg(string.format("添加失败，被介绍人的等级最高不能超过%s级。", self.INTRODUCED_MAXLEVEL));
		return 0;
	end
	if (nAppId - nDstLevel < self.INTRODUCED_MIN_DIFLEVEL) then
		Relation:SetInfoMsg(string.format("添加失败，介绍人的等级至少要比被介绍人的高出%s级。", self.INTRODUCED_MIN_DIFLEVEL));
		return 0;
	end
	
	return 1;
end
	
end














--=================================================
--============= MODULE_GAMESERVER =================
--=================================================


if (MODULE_GAMESERVER) then
	
end

Relation:Register(Player.emKPLAYERRELATION_TYPE_INTRODUCTION, tbIntroduction)
