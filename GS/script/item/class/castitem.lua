------------------------------------------------------
-- 文件名　：castitem.lua
-- 创建者　：dengyong
-- 创建时间：2012-02-20 09:30:16
-- 描  述  ：精铸图纸
------------------------------------------------------
local tbCastItem = Item:GetClass("castitem");

function tbCastItem:GetTip(nState)
	local szTip = "";
	local nEnhId = Item:GetExCastEnhId(it.GetExtParam(1), it.GetExtParam(2));
	local tbAttrib = KItem.GetExCastAttrib(nEnhId);
	if not tbAttrib then
		return szTip;
	end
	
	local tbEnhanceMa = tbAttrib.tbEnhMa;
	szTip = szTip .. "Thuộc tính cường hóa:";
	for i, tbMA in pairs(tbEnhanceMa) do
		local szDesc = self:GetMagicAttribDescEx(tbMA.szName, self:BuildMARange(tbMA.tbRange));
		if szDesc ~= "" then
			szTip = szTip.."\n"..Lib:StrFillL(string.format("(+ %d)", tbMA.nTimes), 12)..szDesc;
		end
	end
	
	local tbStrengthenMA = tbAttrib.tbStrMa;
	szTip = szTip .. "\n\nThuộc tính sửa trang bị:";
	for i, tbMA in pairs(tbStrengthenMA) do
		local szDesc = self:GetMagicAttribDescEx(tbMA.szName, self:BuildMARange(tbMA.tbRange));
		if szDesc ~= "" then
			szTip = szTip.."\n"..Lib:StrFillL(string.format("(+ %d)", tbMA.nTimes), 12)..szDesc;
		end
	end	
	
	return szTip;
end

function tbCastItem:GetMagicAttribDescEx(szName, tbLow, tbHigh)
	if szName == "" then
		return	"";
	end
	local szDesc = FightSkill:GetExtentMagicDesc(szName, tbLow, tbHigh);
	return szDesc;
end

function tbCastItem:BuildMARange(tbRange)
	local tbLow  = {};
	local tbHigh = {};
	for _, tb in ipairs(tbRange) do
		table.insert(tbLow, tb.nMin);
		table.insert(tbHigh, tb.nMax);
	end
	return tbLow, tbHigh;
end