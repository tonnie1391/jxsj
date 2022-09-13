
-- ×°±¸£¬ÃØ¼®ÐÞÎªÅäÖÃ

Require("\\script\\item\\externsetting\\externsetting.lua");

------------------------------------------------------------------------------------------
-- initialize

local tbRefineSetting = Item.tbExternSetting:GetClass("refine");

tbRefineSetting.TABLEFILE_REFINE			= "refine.txt";
tbRefineSetting.TABLEFILE_REFINE_EX			= "refineex.txt";
tbRefineSetting.TABLEFILE_REFINE_REQUIRE	= "refinerequire.txt";
tbRefineSetting.REQUIRE_MAX					= 2
tbRefineSetting.PATH						= "\\setting\\item\\001\\extern\\refine\\";

------------------------------------------------------------------------------------------
-- interface

function tbRefineSetting:Load(szPath)

	local bRet = 1;

	if (1 ~= self:LoadRefine(szPath)) then
		bRet = 0;
	end

	return	bRet;

end

------------------------------------------------------------------------------------------
-- private

function tbRefineSetting:LoadRefine(szDir)
	self.m_tbRefine = {};
	self.m_tbRefineRequire = {};
	self.m_tbRefineEx = {};
	local tbNumColName = 
	{
		RefineId		= 1,
		Index			= 1,
		ProduceGenre	= 1,
		ProduceDetail	= 1,
		ProduceParti	= 1,
		ProduceLevel	= 1,
		Faction			= 1,
		AttRoute		= 1,
		Sex				= 1,
		EquipGenre		= 1,
		EquipDetail		= 1,
		EquipParti		= 1,
		EquipLevel		= 1,
		Fee				= 1,
	};
	local tbFile = Lib:LoadTabFile(szDir..self.TABLEFILE_REFINE, tbNumColName);
	if tbFile then
		for _, tbItem in pairs(tbFile) do
			local nRefineId = tbItem.RefineId;
			if not self.m_tbRefine[nRefineId] then
				self.m_tbRefine[nRefineId] = {};
			end
			local tbTemp = {}
			tbTemp.nFaction = tbItem.Faction or -1;
			tbTemp.nAttRoute = tbItem.AttRoute or -1;
			tbTemp.nSex	= tbItem.Sex or -1;
			tbTemp.nFee = tbItem.Fee or 0;
			tbTemp.tbEquip = {tbItem.EquipGenre, tbItem.EquipDetail, tbItem.EquipParti, tbItem.EquipLevel};
			tbTemp.tbProduce = {tbItem.ProduceGenre, tbItem.ProduceDetail, tbItem.ProduceParti, tbItem.ProduceLevel}
			self.m_tbRefine[nRefineId][tbItem.Index] = tbTemp
		end
	end
	local tbNumColName = { RefineId = 1 }
	for i = 1, self.REQUIRE_MAX do
		tbNumColName["Require"..i.."Genre"]		= 1;
		tbNumColName["Require"..i.."Detail"]	= 1;
		tbNumColName["Require"..i.."Particular"]= 1;
		tbNumColName["Require"..i.."Level"]		= 1;
		tbNumColName["Require"..i.."Count"]		= 1;
	end
	local tbRefineRequire = Lib:LoadTabFile(szDir..self.TABLEFILE_REFINE_REQUIRE, tbNumColName);
	if tbRefineRequire then
		for _, tbItem in pairs(tbRefineRequire) do
			local nRefineId = tbItem.RefineId;
			if not self.m_tbRefineRequire[nRefineId] then
				self.m_tbRefineRequire[nRefineId] = {};
			end
			for i = 1, self.REQUIRE_MAX do
				self.m_tbRefineRequire[nRefineId][i] = 
				{
					tbItem["Require"..i.."Genre"],
					tbItem["Require"..i.."Detail"],
					tbItem["Require"..i.."Particular"],
					tbItem["Require"..i.."Level"],
					nCount = tbItem["Require"..i.."Count"],
				};
			end
		end
	end
	
	local tbNumColName  = 
	{
		RefineId		= 1,
		Detail			= 1,
		RequirRefineLev = 1,
		ResRefineLev	= 1,
		AddValue		= 1,
		AddFightPower	= 1,
	}
	local tbRefineEx = Lib:LoadTabFile(szDir..self.TABLEFILE_REFINE_EX, tbNumColName);
	if tbRefineEx then
		for _, tbItem in pairs(tbRefineEx) do
			local nRefineId = tbItem.RefineId;
			if not self.m_tbRefineEx[nRefineId] then
				self.m_tbRefineEx[nRefineId] = {};
			end
		
			local tbTemp = {};
			tbTemp.nDetail = tonumber(tbItem.Detail);
			tbTemp.nRequirRefineLev = tonumber(tbItem.RequirRefineLev);
			tbTemp.nResRefineLev =tonumber( tbItem.ResRefineLev);
			tbTemp.nAddValue = tonumber(tbItem.AddValue);
			tbTemp.nAddFightPower = tonumber(tbItem.AddFightPower);
			tbTemp.nFee = tonumber(tbItem.Fee);
			self.m_tbRefineEx[nRefineId] = tbTemp;
		end
	end
	
	return	1;
end

function tbRefineSetting:GetExEquipRefineInfo(nDetail, nExRefineLev)
	local tbRefineInfo = nil;
	for _nRefineId, tbInfo in pairs(self.m_tbRefineEx) do
		if tbInfo.nDetail == nDetail and tbInfo.nResRefineLev == nExRefineLev then
			tbRefineInfo = tbInfo;
		end
	end
	
	return tbRefineInfo;
end