Require("\\script\\fightskill\\enchant\\define.lua");

local szEnchantFile = "\\setting\\fightskill\\skillenchant.txt";

if (not SkillEnchant.tbClassBase) then
	SkillEnchant.tbClassBase = {};
end	

if (not SkillEnchant.tbClass) then
	SkillEnchant.tbClass = {};
end

function SkillEnchant:GetNameById(nId)
	local tbData = Lib:LoadTabFile(szEnchantFile);
	if (not tbData) then
		return;
	end;
	for _, tb in pairs(tbData) do
		if (tonumber(tb.Id) == nId) then
			return tb.ClassName;
		end;
	end;
	return nil;
end;
	
-- 取得特定类名的Enchant类
function SkillEnchant:GetClass(szEnchantClassName, bNotCreate)
	local tbSkill = self.tbClass[szEnchantClassName];
	if (not tbSkill and bNotCreate ~= 1) then
		tbSkill	= Lib:NewClass(self.tbClassBase);
		self.tbClass[szEnchantClassName] = tbSkill;
	end
	
	return tbSkill;
end


function SkillEnchant:AddBooksInfo(tb)
	if (not tb) then
		return;
	end
	
	for szEnchantClassName, tbEnchant in pairs(tb) do
		self:GetClass(szEnchantClassName).tbEnchantData = tbEnchant;
	end
end

-- 获得一个附魔所关联的技能列表
function SkillEnchant:GetSkillList(szEnchantClassName, nEnchantLevel)
	local tbSkillList = {};
	local tbEnchant = self:GetClass(szEnchantClassName, 1);
	if (not tbEnchant) then
		return;
	end

	local tbEnchantData = tbEnchant.tbEnchantData;
	
	for _, tbEnchantSkill in ipairs(tbEnchantData) do
		tbSkillList[#tbSkillList + 1] = tbEnchantSkill.RelatedSkillId;
	end
	
	return tbSkillList;
end


-- 获得一个附魔下的一个技能的魔法属性列表
function SkillEnchant:GetMagicList(nRelatedSkillId, szEnchantClassName, nEnchantLevel)
	local tbMagicList = {};
	local tbEnchant = self:GetClass(szEnchantClassName, 1);
	assert(tbEnchant);
	local tbEnchantData = tbEnchant.tbEnchantData;
	for _,tbSkillData in ipairs(tbEnchantData) do
		if (tbSkillData.RelatedSkillId == nRelatedSkillId) then
			for nMagicType, tbMagicData in pairs(tbSkillData.magic) do
				local tbMagic = {};
				tbMagic.MagicType = nMagicType;
				if (tbMagicData["value1"]) then
					tbMagic.Value1Op = tbMagicData["value1"][1];
					tbMagic.Value1Value = FightSkill:GetPointValue(tbMagicData["value1"][2], nEnchantLevel);
				end
				if (tbMagicData["value2"]) then
					tbMagic.Value2Op = tbMagicData["value2"][1];
					tbMagic.Value2Value = FightSkill:GetPointValue(tbMagicData["value2"][2], nEnchantLevel);
				end
				if (tbMagicData["value3"]) then
					tbMagic.Value3Op = tbMagicData["value3"][1];
					tbMagic.Value3Value = FightSkill:GetPointValue(tbMagicData["value3"][2], nEnchantLevel);
				end
				if (#tbMagic) then
					tbMagicList[#tbMagicList + 1] = tbMagic;
				end
			end
		end
	end
	return tbMagicList;
end
