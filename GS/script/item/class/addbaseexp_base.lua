-- 文件名　：addbaseexp_base.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-11-11 09:15:53
-- 描  述  ：增加基准经验通用
-- ExtParam1:多少分钟基准经验
-- ExtParam2:直接加多少经验值
-- ExtParam3:任务组
-- ExtParam4:任务id表示日期
-- ExtParam5:任务id表示每天的次数
-- ExtParam6:每天使用的最大次数
-- ExtParam7:任务id表示总共能使用的次数
-- ExtParam8:总共使用的最大次数
-- ExtParam9:等级要求（大于等于）
-- ExtParam10:等级要求（小于等于）

local tbBase = Item:GetClass("addbaseexp_base");

function tbBase:OnUse()
	local nValue =tonumber(it.GetExtParam(1));
	local nExpValue = tonumber(it.GetExtParam(2));
	local nTaskGroupId = tonumber(it.GetExtParam(3));
	local nTaskData = tonumber(it.GetExtParam(4));
	local nTaskTimes = tonumber(it.GetExtParam(5));
	local nTaskMaxTimes = tonumber(it.GetExtParam(6));
	local nTaskTimesAll	= tonumber(it.GetExtParam(7));
	local nTaskTimesAll_Max = tonumber(it.GetExtParam(8));
	local nLevel = tonumber(it.GetExtParam(9));
	local nLevel1 = tonumber(it.GetExtParam(10));
	
	--等级要求检查
	if nLevel and nLevel ~= 0 and me.nLevel < nLevel then
		me.Msg(string.format("Đẳng cấp chưa đạt %s!", nLevel));
		return 0;
	end
	if nLevel1 and nLevel1 ~= 0 and me.nLevel < nLevel1 then
		me.Msg(string.format("Đẳng cấp đã quá %s!", nLevel1));
		return 0;
	end

	return self:SureOnUse(nValue, nExpValue, nTaskGroupId, nTaskData, nTaskTimes, nTaskMaxTimes, nTaskTimesAll, nTaskTimesAll_Max)
end

function tbBase:SureOnUse(nValue, nExpValue, nTaskGroupId, nTaskData, nTaskTimes, nTaskMaxTimes, nTaskTimesAll, nTaskTimesAll_Max)
	if self:CheckTask(nTaskGroupId, nTaskData, nTaskTimes, nTaskMaxTimes, nTaskTimesAll, nTaskTimesAll_Max) == 0 then
		return 0;
	end
	if nValue and nValue ~= 0 then
		me.AddExp(me.GetBaseAwardExp() * nValue);
		local szLog = string.format("%s nhận được %s kinh nghiệm", me.szName, me.GetBaseAwardExp() * nValue);
		Dbg:WriteLog("UseItem",  szLog);			
		me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, szLog);	
	end
	if nExpValue and nExpValue ~= 0 then
		me.AddExp(nExpValue);
		local szLog = string.format("%s nhận được %s kinh nghiệm", me.szName, nExpValue);
		Dbg:WriteLog("UseItem",  szLog);			
		me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, szLog);
	end
	if nTaskGroupId and nTaskGroupId ~= 0 and nTaskData and nTaskTimes and nTaskMaxTimes and nTaskData ~= 0 and nTaskTimes ~= 0 and nTaskMaxTimes ~= 0 then
		me.SetTask(nTaskGroupId, nTaskTimes, me.GetTask(nTaskGroupId, nTaskTimes) + 1);
	end
	if nTaskGroupId and nTaskGroupId ~= 0 and nTaskTimesAll and nTaskTimesAll ~= 0 then
		me.SetTask(nTaskGroupId, nTaskTimesAll, me.GetTask(nTaskGroupId, nTaskTimesAll) + 1);
	end
	return 1;
end

--检查任务变量
function tbBase:CheckTask(nTaskGroupId, nTaskData, nTaskTimes, nTaskMaxTimes, nTaskTimesAll, nTaskTimesAll_Max)
	if not nTaskGroupId or nTaskGroupId == 0 then
		return 1;
	end	
	if nTaskData and nTaskTimes and nTaskMaxTimes and nTaskData ~= 0 and nTaskTimes ~= 0 and nTaskMaxTimes ~= 0 then		
		local nDate = me.GetTask(nTaskGroupId, nTaskData);
		local nNowDate = tonumber(GetLocalDate("%Y%m%d"));		
		if nDate ~= nNowDate then			
			me.SetTask(nTaskGroupId, nTaskData, nNowDate);
			me.SetTask(nTaskGroupId, nTaskTimes, 0);
		end	
		local nTimes = me.GetTask(nTaskGroupId, nTaskTimes);			
		if nTimes >= nTaskMaxTimes then
			me.Msg("Hôm nay đã hết lượt sử dụng.");
			return 0;
		end
	end
	if nTaskTimesAll and nTaskTimesAll_Max and nTaskTimesAll ~= 0 and nTaskTimesAll_Max ~= 0 then
		local nTotalCount = me.GetTask(nTaskGroupId, nTaskTimesAll);
		if nTotalCount >= nTaskTimesAll_Max then
			me.Msg("Hôm nay đã sử dụng đủ.");
			return 0;
		end
	end
	return 1
end

function tbBase:GetTip()
	local szTip = "";
	local nValue = tonumber(it.GetExtParam(1));
	local nExpValue = tonumber(it.GetExtParam(2));
	local nTaskGroupId = tonumber(it.GetExtParam(3));
	local nTaskData = tonumber(it.GetExtParam(4));
	local nTaskTimes = tonumber(it.GetExtParam(5));
	local nTaskMaxTimes = tonumber(it.GetExtParam(6));
	local nTaskTimesAll	= tonumber(it.GetExtParam(7));
	local nTaskTimesAll_Max = tonumber(it.GetExtParam(8));
	local tbColor = {"green","gray"};
	if nValue and nValue ~= 0 then
		szTip = szTip .. string.format("<color=green>Nhận được %s kinh nghiệm<color>",me.GetBaseAwardExp() * nValue);
	end
	if nExpValue and nExpValue ~= 0 then
		szTip = szTip .. string.format("<color=green>Nhận được %s kinh nghiệm<color>", nExpValue);
	end
	if nTaskGroupId and nTaskGroupId~= 0 then
		if nTaskTimes and nTaskTimes~= 0 and nTaskData and nTaskData ~= 0 and nTaskMaxTimes and nTaskMaxTimes ~= 0 then
			local nTodayCount = me.GetTask(nTaskGroupId, nTaskTimes);
			local nDate = me.GetTask(nTaskGroupId, nTaskData);
			local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
			if nNowDate ~= nDate then
				nTodayCount = 0;
			end
			local nColor = 1;
			if nTodayCount >= nTaskMaxTimes then	
				nColor = 2;
			end
			szTip = szTip .. string.format("<color=%s>\nHôm nay đã dùng %s/%s<color>", tbColor[nColor], nTodayCount, nTaskMaxTimes);
		end
		if nTaskTimesAll and nTaskTimesAll~= 0 and nTaskTimesAll_Max and nTaskTimesAll_Max ~= 0 then
			local nTotalCount = me.GetTask(nTaskGroupId, nTaskTimesAll);
			local nColor = 1;
			if nTotalCount >= nTaskTimesAll_Max then
				nColor = 2;
			end
			szTip = szTip .. string.format("<color=%s>\nHôm nay đã dùng%s/%s<color>", tbColor[nColor], nTotalCount, nTaskTimesAll_Max);
		end
	end
	return szTip;
end
