-- 文件名　：horse_box_base.lua
-- 创建者　：jiazhenwei
-- 创建时间：2012-02-09 15:00:19
-- 功能    ：马牌箱子，从箱子中取出马牌，时间继承箱子
  
local tbItem = Item:GetClass("horse_box_base1");

tbItem.tbHorse = {
	--{天数，{id，名字}--道具1，{id，名字}--道具2}
	[1] = {40, {{1, 12, 27, 4}, "[坐骑]吉祥虎"}, {{1, 12, 54, 4}, "[坐骑]月华·澜"}},
	[2] = {40, {{1, 12, 63, 4}, "[坐骑]绝世雪羽"}},
};

function tbItem:OnUse()	
	local nCount  = it.GetExtParam(1);
	if not self.tbHorse[nCount] then
		Dialog:Say("道具异常！");
		return 0;
	end
	local szInfo = string.format("请选择你想要的物品(只能选择一个喔~)，坐骑箱持续时间为%s天，选择的坐骑将与箱子有效期相同：", self.tbHorse[nCount][1]);
	local nType, nTime = it.GetTimeOut(0);
	local tbOpt ={};
	
	if (self.tbHorse[nCount][2]) then
		tbOpt[#tbOpt + 1] = {self.tbHorse[nCount][2][2], self.AddMask, self, 2, it.dwId, nType, nTime, nCount};
	end
	
	if (self.tbHorse[nCount][3]) then
		tbOpt[#tbOpt + 1] = {self.tbHorse[nCount][3][2], self.AddMask, self, 3, it.dwId, nType, nTime, nCount};
	end
	tbOpt[#tbOpt + 1] = {"Đóng lại"};
	Dialog:Say(szInfo,tbOpt);
	return 0;
end

function tbItem:AddMask(nType, nItemId, nTimeType, nTime, nCount)
	if me.CountFreeBagCell() < 1 then
		Dialog:Say(string.format("请留出<color=green>%s格<color>背包空间。", 1));
		return 0;
	end

	local pItem =  KItem.GetObjById(nItemId);
	if pItem then
		pItem.Delete(me);
		local pItemEx = me.AddItem(unpack(self.tbHorse[nCount][nType][1]));
		if (pItemEx) then
			pItemEx.SetTimeOut(nTimeType, nTime);
			pItemEx.Sync();
		end
	end
end
	
