
-- 装备，秘籍修为配置

Require("\\script\\item\\externsetting\\externsetting.lua");

------------------------------------------------------------------------------------------
-- initialize

local tbBookSetting = Item.tbExternSetting:GetClass("book");

tbBookSetting.TABLEFILE_LEVELKARMA	= "levelkarma.txt";
tbBookSetting.TABLEFILE_HIGH_LEVELKARMA	= "high_levelkarma.txt";
tbBookSetting.MIN_LEVEL				= 1;			-- 秘籍等级下限
tbBookSetting.MAX_LEVEL				= 100;			-- 秘籍等级上限

------------------------------------------------------------------------------------------
-- interface

function tbBookSetting:Load(szPath)

	local bRet = 1;

	if (1 ~= self:LoadLevelKaram(szPath)) then
		bRet = 0;
	end

	return	bRet;

end

------------------------------------------------------------------------------------------
-- private

function tbBookSetting:LoadLevelKaram(szDir)
	local szFile;

	self.m_tbLevelKarma = {};
	szFile = szDir..self.TABLEFILE_LEVELKARMA;
	self:ReadLevelKaram(szFile, self.m_tbLevelKarma);

	self.m_tbHighLevelKarma = {};
	szFile = szDir..self.TABLEFILE_HIGH_LEVELKARMA;	
	return self:ReadLevelKaram(szFile, self.m_tbHighLevelKarma);
end

function tbBookSetting:ReadLevelKaram(szFile, tbLevel)
	local pTabFile = KIo.OpenTabFile(szFile);
	if (not pTabFile) then
		print("文件"..szFile.."打不开！");
		return 0;
	end

	for i = self.MIN_LEVEL, self.MAX_LEVEL do
		tbLevel[i] = pTabFile.GetInt(1 + i, 2);
	end

	KIo.CloseTabFile(pTabFile);
	return 1;

end