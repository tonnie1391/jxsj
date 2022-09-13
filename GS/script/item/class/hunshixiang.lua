
-- 魂石箱

------------------------------------------------------------------------------------------
-- initialize

local tbXiang = Item:GetClass("hunshixiang");

------------------------------------------------------------------------------------------
tbXiang.tbLevel = 
{
	[1] = 100,
	[2] = 1000,
	[3] = 500,
}

tbXiang.tbBindParticular = 
{
	[1696] = 1,	
}

tbXiang.tbHunShi = {18,1,205,1};

-- 返回值：	0不删除、1删除
function tbXiang:OnUse()
	local nNum = self.tbLevel[it.nLevel];
	local nBind = it.IsBind() or 0;
	nBind = self.tbBindParticular[it.nParticular] or nBind;
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ chỗ trống.");
		return 0;
	end
	local tbItemInfo = {bForceBind = nBind};
	me.AddStackItem(self.tbHunShi[1], self.tbHunShi[2], self.tbHunShi[3], self.tbHunShi[4], tbItemInfo, nNum);
	return 1;
end
