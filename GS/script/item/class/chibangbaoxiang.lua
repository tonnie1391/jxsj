-- 文件名　：chibangbaoxiang.lua
-- 创建者　：sunduoliang
-- 创建时间：2012-06-29 09:15:26
-- 功能    ：翅膀宝箱。

local tbItem = Item:GetClass("chibangbangxiang");
tbItem.ExParam = 1;	--有效期（天）
tbItem.Def_Day = 7; --默认有效期7天
tbItem.tbList = {
	--对应宝箱等级
	[1] = {
			[0] = {1,26,38,1}, --男性翅膀
			[1] = {1,26,39,1}, --女性翅膀
		  },
	[2] = {
			[0] = {1,26,40,1}, --男性翅膀
			[1] = {1,26,41,1}, --女性翅膀
		  },
}
function tbItem:OnUse()
	if me.CountFreeBagCell() < 1  then
		Dialog:Say("Hành trang không đủ 1 ô trống.", {"Ta hiểu rồi"});
		return 0;
	end
	local nDay = it.GetExtParam(self.ExParam) or 0;
	if nDay == 0 then
		nDay = self.Def_Day;
	end
	local nLevel = it.nLevel;
	if not self.tbList[nLevel] or not self.tbList[nLevel][me.nSex] then
		Dialog:Say("物品不存在。", {"Ta hiểu rồi"});
		return 0;		
	end
	local pItem = me.AddItem(unpack(self.tbList[nLevel][me.nSex]));
	if pItem then
		pItem.Bind(1);
		me.SetItemTimeout(pItem, 60*24*nDay, 0);
	end
	return 1;
end
