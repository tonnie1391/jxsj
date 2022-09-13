
-- 夜明珠箱
-- By Peres 2009/06/18 22:53

------------------------------------------------------------------------------------------
-- initialize

local tbXiang = Item:GetClass("qinling_yemingzhuxiang");

------------------------------------------------------------------------------------------

tbXiang.tbHunShi = {18,1,357,1};

-- 返回值：	0不删除、1删除
function tbXiang:OnUse()
	local nNum = 100;
	local nBind = it.IsBind() or 0;
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ chỗ trống.");
		return 0;
	end
	local tbItemInfo = {bForceBind = nBind};
	me.AddStackItem(self.tbHunShi[1], self.tbHunShi[2], self.tbHunShi[3], self.tbHunShi[4], tbItemInfo, nNum);
	return 1;
end
