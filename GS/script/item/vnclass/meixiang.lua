--文件名  : meixiang.lua
--创建者  : jiazhenwei
--创建日期: 2010-06-02 11:38:20
--描 述 :煤箱  VN


local tbXiang = Item:GetClass("meixiang");

------------------------------------------------------------------------------------------
tbXiang.tbLevel = 
{
	[1] = 10,
	[2] = 100,
}
tbXiang.tbHunShi = {18,1,951,1};

-- 返回值：	0不删除、1删除
function tbXiang:OnUse()
	local nNum = self.tbLevel[it.nLevel];	
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ chỗ trống.");
		return 0;
	end	
	me.AddStackItem(self.tbHunShi[1], self.tbHunShi[2], self.tbHunShi[3], self.tbHunShi[4], nil, nNum);
	return 1;
end
