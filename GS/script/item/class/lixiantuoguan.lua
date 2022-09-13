-- 文件名　：lixiantuoguan.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-06-15 11:45:20
--离线托管丸
-- ExtParam1:多少分钟离线托管时间

local tbBase = Item:GetClass("lixiantuoguan");

function tbBase:OnUse()
	local nHour = tonumber(it.GetExtParam(1));
	if nHour > 0 then
		Player.tbOffline:AddExOffLineTime(nHour * 60);
		me.Msg(string.format("Nhận thêm <color=yellow>%s giờ<color> tu luyện ngoại tuyến.", nHour));
		local szLog = string.format("%s sử dụng %s nhận được %s thời gian tu luyện ngoại tuyến", me.szName, it.szName, nHour);
		Dbg:WriteLog("UseItem",  szLog);
	end	
	return 1;
end

function tbBase:GetTip()
	local szTip = "";
	local nHour =tonumber(it.GetExtParam(1));
	if nHour > 0 then
		szTip = szTip .. string.format("<color=green>Nhận %s giờ tu luyện ngoại tuyến<color>", nHour);
	end	
	return szTip
end

