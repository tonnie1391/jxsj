-- 文件名　：badge.lua
-- 创建者　：furuilei
-- 创建时间：2010-05-18 14:19:16
-- 功能描述：盛夏徽章

SpecialEvent.tbWroldCup = SpecialEvent.tbWroldCup or {};
local tbEvent = SpecialEvent.tbWroldCup;

local tbItem = Item:GetClass("worldcup_badge");

function tbItem:OnUse()
--	if (tbEvent:CheckOpenState() == 0) then
--		return 0;
--	end
	if (Player:AddRepute(me, 5, 5, tbEvent.REPUTE_PER_BADGE)==1) then
		Dialog:Say("您的声望已达上限！");
		return 0;
	end
	return 1;
end
