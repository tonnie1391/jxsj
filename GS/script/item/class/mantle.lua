
-- 披风脚本
-- zhengyuhua

Require("\\script\\item\\class\\equip.lua");

------------------------------------------------------------------------------------------
-- initialize

local tbMantle = Item:NewClass("mantle", "equip");
if not tbMantle then
	tbMantle = Item:GetClass("mantle");
end

function tbMantle:GetTip(nState, tbEnhRandMASS, tbEnhEnhMASS)		-- 获取套装装备Tip

	local szTip = "";

	if (Item.EQUIPPOS_MANTLE ~= it.nEquipPos) then
		return	szTip;
	end

	szTip = szTip.."<color=white>";
	szTip = szTip..self:Tip_ReqAttrib();
	szTip = szTip..self:Tip_Durability();
	szTip = szTip..self:Tip_Level();
	szTip = szTip..self:Tip_Series(nState);
	szTip = szTip.."<color>";
	szTip = szTip.."<color=gold>"..self:Tip_BaseAttrib(nState).."<color>";
	szTip = szTip..self:Tip_RepairInfo(nState);
	szTip = szTip..self:Tip_ActiveRuleAttrib(nState);
	return	Lib:StrTrim(szTip, "\n");
end

function tbMantle:CalcValueInfo()
	local nValue = it.nOrgValue;
	local nStarLevel, szNameColor, szTransIcon = Item:CalcStarLevelInfo(it.nVersion, it.nDetail, it.nLevel, nValue);
	return	nValue, nStarLevel, szNameColor, szTransIcon;
end
