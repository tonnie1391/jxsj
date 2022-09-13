-- 文件名　：lihua.lua
-- 创建者　：furuilei
-- 创建时间：2009-11-30 15:58:51
-- 功能描述：求婚道具（礼花）

local tbItem = Item:GetClass("marry_qiuhunlihua");

function tbItem:OnUse()
	local nCount = it.nCount;
	if (nCount <= 0) then
		return 0;
	end
	
	local nLevel = it.nLevel;
		
	if (1 == nLevel) then
		me.CastSkill(1528, 11, -1, me.GetNpc().nIndex);
	elseif (2 == nLevel) then
		me.CastSkill(1528, 12, -1, me.GetNpc().nIndex);
	elseif (3 == nLevel) then
		me.CastSkill(1528, 13, -1, me.GetNpc().nIndex);
	elseif (4 == nLevel) then
		me.CastSkill(1528, 14, -1, me.GetNpc().nIndex);
	end
	
	return 1;
end
