Require("\\script\\task\\weekendfish\\weekendfish_def.lua")

-- 精致鱼饵粉
local tbClass = Item:GetClass("weekendfish_material_fishbait");

function tbClass:OnUse()
	if  WeekendFish:CheckPlayerLimit(me) ~= 1 then
		me.Msg("Nhân vật dưới cấp 30 không được thao tác.");
		return 0;
	end
	if GetMapType(me.nMapId) ~= "city" and GetMapType(me.nMapId) ~= "village" then
		me.Msg("Chỉ có thể chế tạo trong thành thị và tân thủ thôn.");
		return 0;
	end
	local nTodayRemainNum, szMsg = WeekendFish:CheckTodayMakeRemainNum(me);
	if nTodayRemainNum <= 0 then
		me.Msg(szMsg);
		return 0;
	end
	local szMsg = string.format("Ngươi còn có thể chế tạo <color=yellow>%s mồi câu<color> trong hôm nay.\n\nNgươi chắc chứ?", nTodayRemainNum);
	local tbOpt = 
	{
		{"Chế tạo", self.MakeFishBait, self, nTodayRemainNum},
		{"Để ta suy nghĩ thêm"},	
	};
	Dialog:Say(szMsg, tbOpt);
	return 0;
end

function tbClass:MakeFishBait(nNum)
	Dialog:AskNumber("Nhập số lượng:", nNum, WeekendFish.MakeFishBaitDlg, WeekendFish);
end
