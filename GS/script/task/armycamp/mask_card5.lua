-- 文件名　：mask_card.lua
-- 创建者　：jiazhenwei
-- 创建时间：2010-03-19 18:55:03
-- 描  述  ：道具卡片

local tbItem = Item:GetClass("mask_card5");

tbItem.tbMask = {	
	{1, 12, 27, 4},
	{1, 12, 49, 4},
};

function tbItem:OnUse()
	local szInfo = "请选择你想要的物品(只能选择一个喔~)，坐骑箱持续时间为40天，选择的坐骑将与箱子有效期相同：";
	local nType, nTime = it.GetTimeOut(0);
	local tbOpt ={
			{"[坐骑]吉祥虎",	self.AddMask, self, 1, it.dwId, nType, nTime },
			{"[坐骑]雪魂", self.AddMask, self, 2, it.dwId, nType, nTime},
			{"Đóng lại"},
		};
	Dialog:Say(szInfo,tbOpt);
	return 0;
end

function tbItem:AddMask(nType, nItemId, nTimeType, nTime)
	if me.CountFreeBagCell() < 1 then
		Dialog:Say(string.format("请留出<color=green>%s格<color>背包空间。", 1));
		return 0;
	end

	local pItem =  KItem.GetObjById(nItemId);
	if pItem then
		pItem.Delete(me);
		local pItemEx = me.AddItem(unpack(self.tbMask[nType]));
		if (pItemEx) then
			pItemEx.SetTimeOut(nTimeType, nTime);
			pItemEx.Sync();
		end
	end
end
	