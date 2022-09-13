-- 文件名　：title_card.lua
-- 创建者　：zounan
-- 创建时间：2010-04-28 17:03:47
-- 描  述  ：


--冲级
local tbItem = Item:GetClass("title_card");

tbItem.tbTitle = {6, 28, 1, 9};	

function tbItem:OnUse()
	me.AddTitle(unpack(self.tbTitle));
	return 1;
end



--推广
local tbItem2 = Item:GetClass("title_card_2");

tbItem2.tbTitle = {	[0] = {6, 27, 1, 9},
					[1] = {6, 27, 2, 9}
			   };

function tbItem2:OnUse()
	me.AddTitle(unpack(self.tbTitle[me.nSex]));
	return 1;
end
