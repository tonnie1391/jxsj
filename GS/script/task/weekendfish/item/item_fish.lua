--Require("\\script\\task\\weekendfish\\weekendfish_def.lua")

local tbClass = Item:GetClass("weekendfish_fish");

function tbClass:GetTip()
	local szTip = "";
	local nWeight = it.GetGenInfo(1,0);
	szTip = szTip .. "1 con cá nặng <color=yellow>" .. nWeight .. "<color> cân";
	return szTip;
end