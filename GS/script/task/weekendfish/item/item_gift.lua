Require("\\script\\task\\weekendfish\\weekendfish_def.lua")

-- 奖励的箱子
local tbClass = Item:GetClass("weekendfish_gift");

function tbClass:OnUse()
	local nLevel = it.nLevel;
	if me.CountFreeBagCell() < 2 then
		Dialog:Say("Hành trang không đủ chỗ trống, hãy sắp xếp đủ<color=yellow>2 ô trống<color>.");
		return 0;
	end
	local tbRandomItem = Item:GetClass("randomitem");
	local nRet = tbRandomItem:OnUse();
	if nRet ~= 1 then
		return 0;
	end
	if me.CountFreeBagCell() < 2 then
		return 1;
	end
	if  WeekendFish.RANK_FRAGMENT[nLevel] then
		local nRand = MathRandom(10000);
		if nRand <= WeekendFish.RANK_FRAGMENT[nLevel] then
			local pItem = me.AddItem(unpack(WeekendFish.ITEM_FRAGMENT_ID));
			if pItem then
				me.SendMsgToFriend(string.format("Hảo hữu [<color=yellow>%s<color>] nhận được %s(không khóa), thật may mắn!", me.szName, it.szName));
	       		Player:SendMsgToKinOrTong(me, string.format(" nhận được %s (không khóa), thật may mắn!", it.szName));
	       		KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, string.format("%s nhận được %s (không khóa), thật may mắn!", me.szName, it.szName));
				StatLog:WriteStatLog("stat_info", "fishing", "repute_item", me.nId, 1);
			else
				Dbg:WriteLog("WeekendFish", "add_suipian_failure", me.szName, nLevel);
			end
		end
	end
	if WeekendFish.DONGXUANHANTIE[nLevel] and TimeFrame:GetServerOpenDay() > WeekendFish.ACCELERATE_DAYLIMIT then
		local nRand = MathRandom(10000);
		if nRand <= WeekendFish.DONGXUANHANTIE[nLevel] then
			local pItem = me.AddItem(unpack(WeekendFish.ITEM_DONGXUANHANTIE));
			if not pItem then
				Dbg:WriteLog("WeekendFish", "add_dongxuanhantie_failure", me.szName, nLevel);
			end
		end
	end
	return 1;
end