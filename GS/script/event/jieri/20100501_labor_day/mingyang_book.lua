-- 文件名　：mingyang_book.lua
-- 创建者　：jiazhenwei
-- 创建时间：2010-03-31 16:53:48
-- 描  述  ：

if MODULE_GC_SERVER then
	return 0;
end

local tbBook = Item:GetClass("mingyang_book");
SpecialEvent.LaborDay = SpecialEvent.LaborDay or {};
local LaborDay = SpecialEvent.LaborDay or {};

function tbBook:GetTip()
	local szTip = "";
	for i, szName in ipairs(LaborDay.tbName) do
		local nFlag = me.GetTask(LaborDay.TASKID_GROUP, LaborDay.TASKID_BOOK + i - 1);
		local szColor = "white";
		if nFlag ~= 1 then 
			szColor = "gray"; 
		end
		local szMsg = string.format("<color=%s>", szColor);
		szTip = szTip..Lib:StrFillL("", 5)..szMsg .. Lib:StrFillL(szName, 5).."<color>";
		if math.fmod(i, 3) == 0 then
			szTip = szTip .."\n";
		end
	end	
	return szTip;
end
