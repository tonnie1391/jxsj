-- 文件名　：card_collection.lua
-- 创建者　：furuilei
-- 创建时间：2010-05-17 10:59:45
-- 功能描述：卡片收集册

SpecialEvent.tbWroldCup = SpecialEvent.tbWroldCup or {};
local tbEvent = SpecialEvent.tbWroldCup;
local tbItem = Item:GetClass("card_collection");

function tbItem:OnUse()
	if (tbEvent:GetOpenState() ~= 1 and tbEvent:GetOpenState() ~= 2) then
		return 0;
	end
	local nMyValue = tbEvent:CalcCardCollectionValue();
	me.CallClientScript({"SpecialEvent.tbWroldCup:OpenCollectionWnd_Client", tbEvent.tbTeamLevel, nMyValue});
	return 0;
end

