-- 文件名　：zhangonglibao.lua
-- 创建者　：jiazhenwei
-- 创建时间：2010-04-29 17:24:45
-- 描  述  ：

SpecialEvent.LaborDay = SpecialEvent.LaborDay or {};
local LaborDay = SpecialEvent.LaborDay or {};

local tbItem = Item:GetClass("zhangonglibao");
function tbItem:OnUse()
	if me.CountFreeBagCell() < 2 then
		local szAnnouce = "Hành trang không đủ ，请留出2格空间再试。";
		me.Msg(szAnnouce);
		return 0;
	end
	local nResult = Item:GetClass("randomitem"):SureOnUse(LaborDay.nZhangonglibao, LaborDay.TASKID_GROUP, nil, nil, LaborDay.TASKID_DAY, LaborDay.TASKID_EVERY, LaborDay.nTaskTimes_Max, LaborDay.TASKID_ALL, LaborDay.nTaskTimes_All_Max);
	local nRate = Random(100);
	if nResult == 1 and nRate <= LaborDay.nRate_zhongzi then		
		me.AddItem(unpack(LaborDay.tbZhongzi));
	end
	return nResult;
end
