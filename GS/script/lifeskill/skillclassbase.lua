

local tbClassBase	= {};
LifeSkill._tbSkillClassBase	= tbClassBase;



------------------------------------------------------
-- Get·½·¨
function tbClassBase:GetName()
	return self.tbSkillData.Name;
end;


function tbClassBase:GetGene()
	return self.tbSkillData.Gene;
end;


function tbClassBase:GetBelong()
	return self.tbSkillData.Belong;
end
	
function tbClassBase:GetIcon()
	return self.tbSkillData.Icon;
end

function tbClassBase:GetDesc()
	return self.tbSkillData.Desc;
end

function tbClassBase:GetBGM()
	return self.tbSkillData.BGM;
end
	
function tbClassBase:GetMaxLevel()
	return self.tbSkillData.MaxLevel;
end
