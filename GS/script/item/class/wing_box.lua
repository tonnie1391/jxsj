-- 文件名　：wing_box.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-02-13 16:06:57
-- 描述：情人节翅膀宝箱

local tbItem = Item:GetClass("wing_box");

tbItem.tbGarmentList = {
		[Env.SEX_MALE]		= {1,25,38,1},
		[Env.SEX_FEMALE] 	= {1,25,39,1},
	};
	
tbItem.nLiveTime = 3600 * 24 * 9;
	
function tbItem:OnUse()
	local nSex = me.nSex;
	if not nSex then
		return;
	end
	self:OnSureGiveWing(nSex,it.dwId);	
end	
	
function tbItem:OnSureGiveWing(nSex,nItemId)
	if me.CountFreeBagCell() < 1 then
		Dialog:Say((string.format("你的背包不足，需要%s格背包空间。", 1)));
		return 0;
	end
	
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	
	local tbWingInfo = self.tbGarmentList[nSex];
	local pIt = me.AddItem(unpack(tbWingInfo));
	local szDate = os.date("%Y/%m/%d/%H/%M/%S", GetTime() + self.nLiveTime);
	me.SetItemTimeout(pIt,szDate);
	
	pItem.Delete(me);
end