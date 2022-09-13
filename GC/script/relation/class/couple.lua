--=================================================
-- 文件名　：couple.lua
-- 创建者　：furuilei
-- 创建时间：2010-08-30 10:07:48
-- 功能描述：夫妻关系逻辑
--=================================================

Require("\\script\\relation\\relation_logic.lua");
local tbCouple = {};

if (not MODULE_GC_SERVER and not MODULE_GAMESERVER) then
	return;
end





--=================================================
--============= MODULE_GC_SERVER ==================
--=================================================


if (MODULE_GC_SERVER) then

-- 创建人际关系判断
function tbCouple:CanCreateRelation(nRole, nAppId, nDstId)
	if (not nRole or not nAppId or not nDstId) then
		return 0;
	end
	
	if (nRole == 0) then
		nAppId, nDstId = nDstId, nAppId;
	end
	
	-- 配偶只能有一个
	if (KRelation.GetOneRelationCount(nAppId, Player.emKPLAYERRELATION_TYPE_COUPLE, 1) >= 1 or
		KRelation.GetOneRelationCount(nDstId, Player.emKPLAYERRELATION_TYPE_COUPLE, 0) >= 1) then
		Relation:SetInfoMsg("添加失败，要知道知己的数量只能有1个。");
		return 0;
	end
	
	-- 性别一直不能结婚
	if (KGCPlayer.OptGetTask(nAppId, KGCPlayer.SEX) == KGCPlayer.OptGetTask(nDstId, KGCPlayer.SEX)) then
		Relation:SetInfoMsg("添加失败，同性别的玩家是不能结为知己的。");
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

Relation:Register(Player.emKPLAYERRELATION_TYPE_COUPLE, tbCouple)
