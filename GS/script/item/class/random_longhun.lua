------------------------------------------------------
-- 文件名　：random_longhun.lua
-- 创建者　：dengyong
-- 创建时间：2012-03-05 17:44:20
-- 描  述  ：龙魂碎片随机箱子，其本质实际上就是randomitem
------------------------------------------------------
local tbRandomItem = Item:GetClass("randomitem");
local tbRandomLongHun = Item:GetClass("random_longhun");

function tbRandomLongHun:OnUse()
	local bStudio = IpStatistics:CheckStudioRole(me)
	local nKindId = it.GetExtParam(1);
	if bStudio == 1 and it.GetExtParam(2) ~= 0 then	-- 工作室
		nKindId = it.GetExtParam(2);
	end
	
	-- 其本质就是一个randomitem，使用randomitem的接口即可
	local nRet, szMsg = tbRandomItem:CheckCost(nKindId);
	if nRet ~= 1 then
		me.Msg(szMsg or "打开失败！");
		return 0;
	end	
	
	-- 活跃度
	SpecialEvent.ActiveGift:AddCounts(me, 49);
	
	-- 但是相比于randomitem，它多了一个副的random_id，因此原来解析extparam的下标要依次后移一位
	local nTaskGroupId = tonumber(it.GetExtParam(4));
	local nTaskpId = tonumber(it.GetExtParam(5));
	local nTaskValue = tonumber(it.GetExtParam(6));
	local nTaskData = tonumber(it.GetExtParam(7));
	local nTaskTimes = tonumber(it.GetExtParam(8));
	local nTaskTimes_Max = tonumber(it.GetExtParam(9));
	local nTaskTimes_All = tonumber(it.GetExtParam(10));
	local nTaskTimes_All_Max = tonumber(it.GetExtParam(11));
	
	-- 其本质就是一个randomitem，使用randomitem的接口即可
	return tbRandomItem:SureOnUse(nKindId, nTaskGroupId, nTaskpId, nTaskValue, nTaskData, nTaskTimes, nTaskTimes_Max, nTaskTimes_All, nTaskTimes_All_Max);
end