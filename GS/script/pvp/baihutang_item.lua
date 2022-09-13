-------------------------------------------------------------------
-- 文件名  : baihutang_item.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-10-19 11:36:59
-- 描述    : 白虎堂加次数道具
-------------------------------------------------------------------

local tbItem  = Item:GetClass("baihutangTimes");

function tbItem:OnUse()
	local nTimes =  tonumber(it.GetExtParam(1));				--每个道具添加的次数
	local nLimitLevel =  tonumber(it.GetExtParam(2));			--每个道具限制使用的等级
	local nTaskGroupId = tonumber(it.GetExtParam(3));		--任务变量
	local nTaskData = tonumber(it.GetExtParam(4));			--日期
	local nTaskTimes = tonumber(it.GetExtParam(5));			--每天使用的数量
	local nTaskTimes_Max = tonumber(it.GetExtParam(6));		--每天最大使用的数量
	
	if nLimitLevel > 0 and me.nLevel <= nLimitLevel then
		me.Msg(string.format("Cấp độ nhỏ hơn %s!", nLimitLevel))
		return 0;
	end
	if nTaskGroupId and nTaskGroupId ~= 0 then
		if nTaskData and nTaskTimes and nTaskTimes_Max and nTaskData ~= 0 and nTaskTimes ~= 0 and nTaskTimes_Max ~= 0 then		
			local nDate = me.GetTask(nTaskGroupId, nTaskData);
			local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
			if nDate ~= nNowDate then
				me.SetTask(nTaskGroupId, nTaskData, nNowDate);
				me.SetTask(nTaskGroupId, nTaskTimes, 0);
			end
			local nTimes = me.GetTask(nTaskGroupId, nTaskTimes);
			if nTimes >= nTaskTimes_Max then
				me.Msg("Hôm nay bạn đã dùng đủ, hãy quay lại vào ngày mai!");
				return 0;
			end
		end
	end
	
	local nNowTimes = me.GetTask(BaiHuTang.TSKG_PVP_ACT, BaiHuTang.TSK_BaiHuTang_PKTIMES_Ex);
	if nTimes > 0 then
		me.SetTask(BaiHuTang.TSKG_PVP_ACT, BaiHuTang.TSK_BaiHuTang_PKTIMES_Ex, nNowTimes + nTimes);
		me.SetTask(nTaskGroupId, nTaskTimes, me.GetTask(nTaskGroupId, nTaskTimes) + nTimes);
		me.Msg(string.format("Còn %s lần tham gia Bạch Hổ Đường", nTimes));
	end
	return 1;
end

function tbItem:GetTip()	
	local nTimes =  tonumber(it.GetExtParam(1));				--每个道具添加的次数
	local nLimitLevel =  tonumber(it.GetExtParam(2));			--每个道具限制使用的等级
	local nTaskGroupId = tonumber(it.GetExtParam(3));		--任务变量
	local nTaskData = tonumber(it.GetExtParam(4));			--日期
	local nTaskTimes = tonumber(it.GetExtParam(5));			--每天使用的数量
	local nTaskTimes_Max = tonumber(it.GetExtParam(6));		--每天最大使用的数量	
	local szMsg = "";
	local szColor = "green";
	if nTaskGroupId and nTaskGroupId ~= 0 then		
		if nTaskData and nTaskTimes and nTaskTimes_Max and nTaskData ~= 0 and nTaskTimes ~= 0 and nTaskTimes_Max ~= 0 then		
			local nTimes = me.GetTask(nTaskGroupId, nTaskTimes)
			local nDate = me.GetTask(nTaskGroupId, nTaskData);
			local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
			if nDate ~= nNowDate then
				nTimes = 0
			end
			if nTimes >= nTaskTimes_Max then
				szColor = "gray";
			end
			szMsg = szMsg..string.format("<color=%s>Số lần bạn có thể sử dụng %s/%s<color>", szColor, nTimes, nTaskTimes_Max);
		end
	end	
	if nLimitLevel and nLimitLevel ~= 0 then		
		szMsg = szMsg..string.format("<color=red>\nNgười chơi cấp %s có thể sử dụng<color>", nLimitLevel);
	end	
	return szMsg;
end
