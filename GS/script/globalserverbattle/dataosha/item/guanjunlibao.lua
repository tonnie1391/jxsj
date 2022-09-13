-- 文件名　：guanjunlibao.lua
-- 创建者　：zounan
-- 创建时间：2009-11-19 12:17:29
-- 描  述  ：冠军礼包

local tbItem = Item:GetClass("guanjunlibao");
function tbItem:OnUse()
	local nType = it.GetGenInfo(1) or 0;	
	DaTaoSha:GetCampAward(me, nType);
	return 1;
end
