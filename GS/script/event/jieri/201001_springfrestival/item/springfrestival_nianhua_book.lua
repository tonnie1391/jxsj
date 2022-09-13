-- 文件名　：nianhua_book.lua
-- 创建者　：jiazhenwei
-- 创建时间：2009-12-29 10:37:41
-- 描  述  ：年画收集册

local tbBook = Item:GetClass("collectionbook");
SpecialEvent.SpringFrestival = SpecialEvent.SpringFrestival or {};
local SpringFrestival = SpecialEvent.SpringFrestival or {};

function tbBook:InitGenInfo()
	-- 设定有效期限
	local nSec = Lib:GetDate2Time(SpringFrestival.nOutTime)
	it.SetTimeOut(0, nSec);
	return	{ };
end

function tbBook:GetTip()
	local szTip = "";
	for i, szName in ipairs(SpringFrestival.tbShengXiao) do
		local nFlag = me.GetTask(SpringFrestival.TASKID_GROUP, SpringFrestival.TASKID_NIANHUA_BOOK + i - 1) or 0;
		local szColor = "white";		
		if nFlag ~= 1 then 
			szColor = "gray"; 
		end	
		local szMsg = string.format("<color=%s>", szColor);		
		szTip = szTip..Lib:StrFillL("", 5)..szMsg .. Lib:StrFillL(szName, 5).."<color>";
		if math.fmod(i, 4) == 0 then
			szTip = szTip .."\n";
		end
	end	
	return szTip;
end
