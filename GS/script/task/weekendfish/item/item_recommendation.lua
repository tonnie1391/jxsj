Require("\\script\\task\\weekendfish\\weekendfish_def.lua")

-- 水产证明
local tbClass = Item:GetClass("weekendfish_recommendation");

function tbClass:InitGenInfo()
	local szDate = os.date("%Y%m%d233000", GetTime()); -- 当天有效
	it.SetTimeOut(0, Lib:GetDate2Time(szDate));
end