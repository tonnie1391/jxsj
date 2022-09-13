
-- 装备，秘籍修为配置

Require("\\script\\item\\externsetting\\externsetting.lua");

------------------------------------------------------------------------------------------
-- initialize

local tbSignetSetting = Item.tbExternSetting:GetClass("signet");

tbSignetSetting.TABLEFILE_LEVELKARMA	= "levelsetting.txt";
tbSignetSetting.MIN_LEVEL				= 1;			-- 秘籍等级下限
tbSignetSetting.MAX_LEVEL				= 999;			-- 秘籍等级上限

------------------------------------------------------------------------------------------
-- interface

function tbSignetSetting:Load(szPath)

	local bRet = 1;

	if (1 ~= self:LoadLevelSetting(szPath)) then
		bRet = 0;
	end

	return	bRet;

end

------------------------------------------------------------------------------------------
-- private

function tbSignetSetting:LoadLevelSetting(szDir)
	self.m_LevelExp = {};
	self.m_LevelValue = {};
	local tbNumColName = { Level = 1, UpgardeExp = 1, Value = 1 };
	local tbFile = Lib:LoadTabFile(szDir..self.TABLEFILE_LEVELKARMA, tbNumColName);
	if tbFile then
		for _, tbItem in pairs(tbFile) do
			local nLevel = tbItem.Level;
			self.m_LevelExp[nLevel] = tbItem.UpgardeExp;
			self.m_LevelValue[nLevel] = tbItem.Value
		end
	end
	return	1;

end
