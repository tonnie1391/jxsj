-- 文件名　：item_mask.lua
-- 创建者　：huangxiaoming
-- 创建时间：2011-01-6 17:55:03
-- 描  述  ：

local tbItem = Item:GetClass("mask_nianshou");

tbItem.tbMask = 
{	
	{1, 13, 134, 1},
	{1, 13, 135, 1},
};

function tbItem:OnUse()
	local szInfo = "请选择你想要的面具：";
	local tbOpt ={
			{"[面具]月月姐(3天)",	self.AddMask, self, 1, it.dwId},
			{"[面具]财神哥(3天)", self.AddMask, self, 2, it.dwId},
			{"Đóng lại"},
		};
	Dialog:Say(szInfo,tbOpt);
	return 0;
end

function tbItem:AddMask(nType, nItemId)
	local pItem =  KItem.GetObjById(nItemId);
	if pItem then
		pItem.Delete(me);
		me.AddItem(unpack(self.tbMask[nType]));
	end
end
	