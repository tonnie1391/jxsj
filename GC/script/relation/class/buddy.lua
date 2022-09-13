--=================================================
-- 文件名　：buddy.lua
-- 创建者　：furuilei
-- 创建时间：2010-08-30 10:07:19
-- 功能描述：指定密友逻辑
--=================================================

Require("\\script\\relation\\relation_logic.lua");
local tbBuddy = {};

if (not MODULE_GC_SERVER and not MODULE_GAMESERVER) then
	return;
end

--=================================================
--============= MODULE_GC_SERVER ==================
--=================================================

if (MODULE_GC_SERVER) then

tbBuddy.BUDDY_MIN_LEVEL = 61;		-- 建立指定密友关系需要的最低等级
tbBuddy.BUDDY_MIN_FAVOR = 2501;		-- 建立指定密友关系至少需要2501的亲密度（6级）
tbBuddy.BUDDY_MIN_FAVOR_LEVEL = 6;	-- 建立指定密友关系至少需要6级亲密度（2501点）

-- 创建人际关系的条件判断
function tbBuddy:CanCreateRelation(nRole, nAppId, nDstId)
	if (not nRole or not nAppId or not nDstId) then
		return 0;
	end
	
	if (0 == nRole) then
		nAppId, nDstId = nDstId, nAppId;
	end
	
	local nAppLevel = KGCPlayer.OptGetTask(nAppId, KGCPlayer.LEVEL);
	local nDstLevel = KGCPlayer.OptGetTask(nDstId, KGCPlayer.LEVEL);
	if (nAppLevel < self.BUDDY_MIN_LEVEL or nDstLevel < self.BUDDY_MIN_LEVEL) then
		Relation:SetInfoMsg(string.format("添加失败，要成为指定密友需要等级达到%s级。", self.BUDDY_MIN_LEVEL));
		return 0;
	end
	
	local nFavor = KRelation.GetFriendFavor(nAppId, nDstId);
	if (nFavor < self.BUDDY_MIN_FAVOR) then
		Relation:SetInfoMsg(string.format("添加失败，要成为密友需要亲密度等级达到%s级。", self.BUDDY_MIN_FAVOR_LEVEL));
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

Relation:Register(Player.emKPLAYERRELATION_TYPE_BUDDY, tbBuddy)
