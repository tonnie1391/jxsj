-- 文件名　：mask_card.lua
-- 创建者　：jiazhenwei
-- 创建时间：2010-03-19 18:55:03
-- 描  述  ：道具卡片

local tbItem = Item:GetClass("mask_card");

tbItem.tbMask = {	{1, 13, 42, 1},
				{1, 13, 43, 1},
			   };

function tbItem:OnUse()
	local szInfo = "请选择你想要的面具：";
	local tbOpt ={
			{"[面具]圣诞老人(3天)",	self.AddMask, self, 1, it.dwId},
			{"[面具]圣诞少女(3天)", self.AddMask, self, 2, it.dwId},
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
	