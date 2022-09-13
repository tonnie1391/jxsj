-- 文件名  : beautyhero_meigui.lua
-- 创建者  : zounan
-- 创建时间: 2010-11-04 17:49:15
-- 描述    : 

local tbItem = Item:GetClass("beautyhero_meigui");
tbItem.COIN = 150;


function tbItem:OnUse()
	me.AddBindCoin(self.COIN);
	return 1;
end