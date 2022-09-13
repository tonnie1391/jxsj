Require("\\script\\item\\class\\equip.lua");

------------------------------------------------------------------------------------------
-- initialize

local tbSignet = Item:NewClass("signet", "equip");
if not tbSignet then
	tbSignet = Item:GetClass("signet");
end

------------------------------------------------------------------------------------------
-- public

tbSignet.SERIES_PROPERTY = 
{
	{2, 4},
	{5,	1},
	{4, 5},
	{1, 3},
	{3, 2},
}

tbSignet.EXPLAIN = 
{
	["seriesenhance"]	= { szExpain = "Cường hóa hiệu quả khắc chế đối với %s ", tbSeries = {2,5,4,1,3} },
	["seriesabate"] 	= { szExpain = "Nhược hóa hiệu quả khắc chế đối với %s", tbSeries = {4,1,5,3,2} },
}

function tbSignet:GetTip(nState)		-- 获取印章Tip
	local szTip = "";
	szTip = szTip..self:Tip_ReqAttrib();
	szTip = szTip..self:Tip_Durability();
	szTip = szTip..self:Tip_Level();
	szTip = szTip..self:Tip_Series(nState);
	szTip = szTip..self:Tip_BaseAttrib(nState);
	return szTip;
end

function tbSignet:Tip_BaseAttrib(nState)	-- 获得Tip字符串：基础属性

	local szTip = "";
	local tbAttrib = it.GetBaseAttrib();	-- 获得道具基础属性

	for i, tbMA in ipairs(tbAttrib) do
		local szDesc = self:GetMagicAttribDesc(tbMA.szName, tbMA.tbValue);
		local nLevel, nExp, nUpgradeExp = Item:CalcUpgrade(it, i, 0);
		local bInvalid = it.IsInvalid();
		if (szDesc ~= "") and (nLevel > 0) then
			if nLevel >= Item.tbMAX_SIGNET_LEVEL[it.nLevel] then 
				nExp = 0;
				nUpgradeExp = 0;
			end
			if bInvalid == 1 then
				szTip = szTip..string.format("\n<color=gray>"..Lib:StrFillL(szDesc, 18).."(Tu vi %d/%d)<color>", nExp, nUpgradeExp);
			else
				szTip = szTip..string.format("\n"..Lib:StrFillL(szDesc, 18).."(Tu vi %d/%d)", nExp, nUpgradeExp);
			end
		end
		szTip = szTip..self:GetMagicExplain(tbMA.szName);
	end

	if szTip ~= "" then
		return	"\n<color=greenyellow>"..szTip.."<color>";
	end

	return szTip;

end

function tbSignet:GetMagicExplain(szName)
	local szTip = "";
	if self.EXPLAIN[szName] then
		local nSeries = it.nSeries;
		if self.EXPLAIN[szName].tbSeries[nSeries] then
			szTip = szTip.."\n<color=white>——"..string.format(self.EXPLAIN[szName].szExpain, Item.TIP_SERISE[self.EXPLAIN[szName].tbSeries[nSeries]]).."<color>\n";
		end
	end
	
	return szTip;
end

function tbSignet:CalcValueInfo()
	local nValue = it.nOrgValue;
	local tbSetting = Item:GetExternSetting("signet", it.nVersion);
	if tbSetting then
		for i = 1, Item.SIGNET_ATTRIB_NUM do
			local nLevel = it.GetGenInfo(2 * i - 1);
			if tbSetting.m_LevelValue[nLevel] then
				nValue = nValue + tbSetting.m_LevelValue[nLevel];
			end
		end
	end
	
	local nStarLevel, szNameColor, szTransIcon = Item:CalcStarLevelInfo(it.nVersion, it.nDetail, it.nLevel, nValue);
	return	nValue, nStarLevel, szNameColor, szTransIcon;
end