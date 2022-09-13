-- 文件名　：laxin_award.lua
-- 创建者　：zhaoyu
--[[
1022	226	226	10月拉新任务可见可接条件		1		
1022	227	227	6种礼包任务变量判断1-6		1		
1: taobao 20
2: qq 10
3: qq 30
4: mobile 50
5: taobao 5
6: taobao 10
nType szCardId szCardPass
10元Q币卡 ?pl me.AddItem(18,1,689,1)
30元Q币卡 ?pl me.AddItem(18,1,689,2)
50元移动充值卡 ?pl me.AddItem(18,1,690,1)
5元淘宝红包 ?pl me.AddItem(18,1,691,1)
10元淘宝红包 ?pl me.AddItem(18,1,691,2)
20元淘宝代金券 ?pl me.AddItem(18,1,692,1)

]]--

if (not MODULE_GAMESERVER) then
	return
end

Require("\\script\\event\\specialevent\\laxin2010\\laxin2010.lua");

for szClassName,_ in pairs(SpecialEvent.tbLaXin2010.tbClass2Type) do	
	local tbItem = Item:GetClass(szClassName);

	function tbItem:OnUse()
		return SpecialEvent.tbLaXin2010:UseItem(me.nId, it);
	end
	
	function tbItem:InitGenInfo()
		it.SetTimeOut(0, SpecialEvent.tbLaXin2010:GetItemTimeout());
		return	{ };
	end
end
