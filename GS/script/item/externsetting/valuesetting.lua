
-- 装备，价值量配置初始化

Require("\\script\\item\\externsetting\\externsetting.lua");

------------------------------------------------------------------------------------------
-- initialize

local tbValueSetting = Item.tbExternSetting:GetClass("value");

tbValueSetting.TABLEFILE_MAGICCOMBINE			= "magic_combine.txt";
tbValueSetting.TABLEFILE_EQUIPRANDPOS			= "equip_random_pos.txt";
tbValueSetting.TABLEFILE_EQUIPLEVEL				= "equip_level.txt";
tbValueSetting.TABLEFILE_ENHANCEVALUE			= "enhance_value.txt";
tbValueSetting.TABLEFILE_EQUIPTYPERATE			= "equip_type_rate.txt";
tbValueSetting.TABLEFILE_STARLEVEL_REPRESENT	= "equip_starlevel_represent.txt";
tbValueSetting.TABLEFILE_STARLEVEL_VALUE		= "equip_starlevel_value.txt";
tbValueSetting.TABLEFILE_STARLEVEL_REPAIR		= "equip_starlevel_repair.txt";
tbValueSetting.TABLEFILE_STRENGTHEN				= "strengthen_value.txt";

------------------------------------------------------------------------------------------
-- interface

function tbValueSetting:Load(szPath)		-- 回调函数接口，装载配置

	local bRet = 1;
	local tbProc =
	{
		self.LoadMaigcCombine,
		self.LoadEquipRandPos,
		self.LoadEquipLevel,
		self.LoadEnhanceValue,
		self.LoadStarLevel,
		self.LoadEquipTypeRate,
		self.LoadStrengthenValue,
	};

	for _, fnProc in ipairs(tbProc) do
		if (fnProc(self, szPath) ~= 1) then
			bRet = 0;
		end
	end

	return bRet;

end

------------------------------------------------------------------------------------------
-- private

function tbValueSetting:LoadMaigcCombine(szDir)

	self.m_tbMagicCombine = {};

	local szFile = szDir..self.TABLEFILE_MAGICCOMBINE;
	local pTabFile = KIo.OpenTabFile(szFile);
	if (not pTabFile) then
		print("文件"..szFile.."打不开！");
		return	0;
	end

	local nWidth  = pTabFile.GetWidth();
	if (nWidth ~= pTabFile.GetHeight()) then
		print("文件"..szFile.."格式不正确：长宽不等！");
		KIo.CloseTabFile(pTabFile);
		return	0;
	end

	local tbMagicH = {};		-- 魔法属性（横向）
	local tbMagicV = {};		-- 魔法属性（纵向）
	for i = 3, nWidth do
		table.insert(tbMagicH, pTabFile.GetStr(2, i));
		local szMagic = pTabFile.GetStr(i, 2);
		table.insert(tbMagicV, szMagic);
		self.m_tbMagicCombine[szMagic] = {};
	end

	for i = 1, #tbMagicV do
		for j = i, #tbMagicH do
			local nRate = pTabFile.GetInt(i + 2, j + 2, 100);
			self.m_tbMagicCombine[tbMagicV[i]][tbMagicH[j]] = nRate;
			self.m_tbMagicCombine[tbMagicV[j]][tbMagicH[i]] = nRate;
		end
	end

	KIo.CloseTabFile(pTabFile);
	return	1;

end

function tbValueSetting:LoadEquipRandPos(szDir)

	self.m_tbEquipRandPos = {};

	local szFile = szDir..self.TABLEFILE_EQUIPRANDPOS;
	local pTabFile = KIo.OpenTabFile(szFile);
	if (not pTabFile) then
		print("文件"..szFile.."打不开！");
		return	0;
	end

	for i = 1, Item.COUNT_RANDOM do
		self.m_tbEquipRandPos[i] = pTabFile.GetInt(i + 1, 2, 100);
	end

	KIo.CloseTabFile(pTabFile);
	return	1;

end

function tbValueSetting:LoadEquipLevel(szDir)

	self.m_tbEquipLevel = {};

	local szFile = szDir..self.TABLEFILE_EQUIPLEVEL;
	local pTabFile = KIo.OpenTabFile(szFile);
	if (not pTabFile) then
		print("文件"..szFile.."打不开！");
		return	0;
	end

	for i = Item.MIN_LEVEL, Item.MAX_EQUIP_LEVEL do
		self.m_tbEquipLevel[i] = pTabFile.GetInt(i + 1, 2, 100);
	end

	KIo.CloseTabFile(pTabFile);
	return	1;

end

function tbValueSetting:LoadEnhanceValue(szDir)

	self.m_tbEnhanceValue = {};

	local szFile = szDir..self.TABLEFILE_ENHANCEVALUE;
	local pTabFile = KIo.OpenTabFile(szFile);
	if (not pTabFile) then
		print("文件"..szFile.."打不开！");
		return	0;
	end

	for i = 1, Item.MAX_EQUIP_ENHANCE do
		self.m_tbEnhanceValue[i] = pTabFile.GetInt(i + 1, 2);
	end

	KIo.CloseTabFile(pTabFile);
	return	1;

end

-- 读取改造价值量表
function tbValueSetting:LoadStrengthenValue(szDir)

	self.m_tbStrengthenValue = {};

	local szFile = szDir..self.TABLEFILE_STRENGTHEN;
	local pTabFile = KIo.OpenTabFile(szFile);
	if (not pTabFile) then
		print("文件"..szFile.."打不开！");
		return	0;
	end

	for i = 1, Item.MAX_EQUIP_ENHANCE do
		local nTime = pTabFile.GetInt(i + 1, 1);
		self.m_tbStrengthenValue[nTime] = pTabFile.GetInt(i + 1, 2);
	end

	KIo.CloseTabFile(pTabFile);
	return	1;

end


function tbValueSetting:LoadStarLevel(szDir)

	self.m_tbStarLevelInfo = {};

	local pTabFileRepresent	= nil;
	local pTabFileValue		= nil;
	local pTabFileRepair	= nil;

	local function Release()
		KIo.CloseTabFile(pTabFileRepresent);
		KIo.CloseTabFile(pTabFileValue);
		KIo.CloseTabFile(pTabFileRepair);
	end

	local szFileRepresent = szDir..self.TABLEFILE_STARLEVEL_REPRESENT;
	pTabFileRepresent = KIo.OpenTabFile(szFileRepresent);
	if (not pTabFileRepresent) then
		print("文件"..szFileRepresent.."打不开！");
		Release();
		return	0;
	end

	local szFileValue = szDir..self.TABLEFILE_STARLEVEL_VALUE;
	pTabFileValue = KIo.OpenTabFile(szFileValue);
	if (not pTabFileValue) then
		print("文件"..szFileValue.."打不开！");
		Release();
		return	0;
	end

	local szFileRepair = szDir..self.TABLEFILE_STARLEVEL_REPAIR;
	pTabFileRepair = KIo.OpenTabFile(szFileRepair);
	if (not pTabFileRepair) then
		print("文件"..szFileRepair.."打不开！");
		Release();
		return	0;
	end

	local nHeight = pTabFileRepresent.GetHeight();
	for i = 2, nHeight do
		local nStarLevel = pTabFileRepresent.GetInt(i, "STAR_LEVEL");
		local tbInfo =
		{
			nStarLevel 	= nStarLevel,
			szNameColor = pTabFileRepresent.GetStr(i, "NAME_COLOR"),
			szTransIcon = pTabFileRepresent.GetStr(i, "TRANSPARENCY_ICON"),
			nEmptyStar 	= pTabFileRepresent.GetInt(i, "EMPTY_STAR"),
			nFillStar	= pTabFileRepresent.GetInt(i, "FILL_STAR"),
		};
		self.m_tbStarLevelInfo[nStarLevel] = tbInfo;
	end

	nHeight = pTabFileValue.GetHeight();
	for i = 2, nHeight do
		local nDetailType = pTabFileValue.GetInt(i, "EQUIP_DETAIL_TYPE");
		local nStarLevel = pTabFileValue.GetInt(i, "STAR_LEVEL");
		local tbInfo = self.m_tbStarLevelInfo[nStarLevel];
		if (not tbInfo) then
			print("文件"..szFileValue.."第"..i.."行STAR_LEVEL错误！");
			Release();
			return 0;
		end
		if (not tbInfo.tbEquipLvlVal) then
			tbInfo.tbEquipLvlVal = {};
		end
		if (not tbInfo.tbEquipLvlVal[nDetailType]) then
			tbInfo.tbEquipLvlVal[nDetailType] = {};
		end
		for j = Item.MIN_LEVEL, Item.MAX_EQUIP_LEVEL do
			tbInfo.tbEquipLvlVal[nDetailType][j] = pTabFileValue.GetInt(i, "EQUIP_LEVEL_"..j, -1);
		end
	end

	nHeight = pTabFileRepair.GetHeight();
	for i = 2, nHeight do
		local nStarLevel = pTabFileRepair.GetInt(i, "STAR_LEVEL");
		local tbInfo = self.m_tbStarLevelInfo[nStarLevel];
		if (not tbInfo) then
			print("文件"..szFileRepair.."第"..i.."行STAR_LEVEL错误！");
			Release();
			return 0;
		end
		tbInfo.nRepairMoney   = pTabFileRepair.GetInt(i, "MONEY");
		tbInfo.nRepairItemDur = pTabFileRepair.GetInt(i, "ITEM_DURABILITY");
	end

	Release();
	return	1;

end

function tbValueSetting:LoadEquipTypeRate(szDir)

	self.m_tbEquipTypeRate = {};

	local szFile = szDir..self.TABLEFILE_EQUIPTYPERATE;
	local pTabFile = KIo.OpenTabFile(szFile);
	if (not pTabFile) then
		print("文件"..szFile.."打不开！");
		return	0;
	end

	for i, v in ipairs(pTabFile.AsTable()) do
		self.m_tbEquipTypeRate[i] = tonumber(v[2]);
	end

	KIo.CloseTabFile(pTabFile);
	return	1;

end
