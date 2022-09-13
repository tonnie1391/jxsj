------------------------------------------------------
-- 文件名　：weekendfish_dongxuanhantie.lua
-- 创建者　：dengyong
-- 创建时间：2011-12-13 17:35:01
-- 描  述  ：冰雪宝石锦盒，固定开3-5级宝石原石
------------------------------------------------------

local tbItem = Item:GetClass("stonebox_2011xmas");

local nLevelMin 	= 3;
local nLevelMax		= 5;

function tbItem:OnUse()
	if me.CountFreeBagCell() < 1 then
		me.Msg("Hành trang không đủ chỗ trống！");
		return 0;
	end
	
	local nRes, nLevel, bSkill = self:GetRandInfo();	
	if nRes ~= 1 then
		return 0;
	end
	
	local tbGDPL = Item.tbStone:RandomStone(Item.tbStone.STONE_PRODUCE_LEVEL_HIGH, 2, bSkill, nLevel);
	if not tbGDPL then
		return 0;
	end
	
	local pItem = me.AddItemEx(unpack(tbGDPL));
	if not pItem then
		return 0;
	end
	
	Item.tbStone:BrodcastMsg(it.szName, pItem);
	return 1;
end

-- 返回值：成功/失败,石头等级,是否技能石头
function tbItem:GetRandInfo()
	if Item.tbStone:_RandomBeSkillStone(Item.tbStone.STONE_PRODUCE_LEVEL_HIGH) == 1 then
		return 1, 1, 1;
	end
	
	local tb = Item.tbStone.tbStoneLevelRandomSeed[Item.tbStone.STONE_PRODUCE_LEVEL_HIGH];
	local nSum = 0;
	
	for i = nLevelMin, nLevelMax do
		nSum = nSum + tb[i];
	end

	if nSum <= 0 then
		return 0;
	end
	
	local nRand = MathRandom(1, nSum);
	local nLevel = nLevelMin;
	for i = nLevelMin, nLevelMax do
		nRand = nRand - tb[i];
		if (nRand < 0) then
			break;
		else
			nLevel = i;
		end
	end	
	
	return 1, nLevel, 0;
end