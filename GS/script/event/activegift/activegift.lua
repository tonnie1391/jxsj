-- 文件名　：activegift.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-11-01 09:20:04
-- 功能    ：活跃度

SpecialEvent.ActiveGift = SpecialEvent.ActiveGift or {};
local ActiveGift = SpecialEvent.ActiveGift;

--增加一个活跃度活动的次数
function ActiveGift:AddCounts(pPlayer, nId)
	if GLOBAL_AGENT then
		return 0;
	end	
	if self.nOpen ~= 1 then
		return 0;
	end	
	local tbActive = self.tbActiveInfo[nId];
	if not tbActive then
		return;
	end
	Setting:SetGlobalObj(pPlayer);	
	local nRet, szErrorMsg = self:CheckCanAddActive(nId);	
	if nRet ~= 1 then
		Setting:RestoreGlobalObj();
		return;
	end
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	local nDate = me.GetTask(self.nTaskGroupId, tbActive.nActiveId);
	local nTimes = me.GetTask(self.nTaskGroupId, tbActive.nSubId);
	if nNowDate ~= nDate  then
		me.SetTask(self.nTaskGroupId, nId, nNowDate);
		nTimes = 0;
	end
	me.SetTask(self.nTaskGroupId, tbActive.nSubId, nTimes + 1);
	if nTimes + 1 >= tbActive.nMaxCount then	
		self:AddActive(tbActive.nGrade, nId);
	end
	Setting:RestoreGlobalObj();
end

--增加活跃度
function ActiveGift:AddActive(nGrade, nId)
	--增加每天累计
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	local nDate = me.GetTask(self.nTaskGroupId, self.nActiveTime);
	local nLastGrade = me.GetTask(self.nTaskGroupId, self.nActiveGrade);
	if nDate ~= nNowDate then
		me.SetTask(self.nTaskGroupId, self.nActiveTime, nNowDate);
		nLastGrade = 0;
	end
	local nTotalGrade = 0;
	if nLastGrade < self.nMaxActiveGrade then
		nTotalGrade = math.min(nLastGrade + nGrade, self.nMaxActiveGrade);
		me.SetTask(self.nTaskGroupId, self.nActiveGrade, nTotalGrade);
		me.Msg("Bạn nhận được <color=yellow>"..nTotalGrade-nLastGrade.."<color> điểm năng động");		--完成提示
		--log
		StatLog:WriteStatLog("stat_info", "online_award", "get_active_point", me.nId, nId..","..(nTotalGrade-nLastGrade));
		if nTotalGrade >= self.nMaxActiveGrade then
			me.Msg("Năng động trong ngày đã đạt mức tối đa");		--完成提示
		end
	else
		me.Msg("Năng động trong ngày đã đạt mức cao nhất, không thể tích lũy thêm");		--完成提示
		return;
	end
	
	--增加月累计
	local nMonthTime = me.GetTask(self.nTaskGroupId, self.nMonthActiveTime);
	local nMonthActiveGrade = me.GetTask(self.nTaskGroupId, self.nMonthActiveGrade);
	local nNowMonth = tonumber(GetLocalDate("%m"));
	if nMonthTime ~= nNowMonth then
		me.SetTask(self.nTaskGroupId, self.nMonthActiveTime, nNowMonth);
		nMonthActiveGrade = 0;
	end
	
	if nMonthActiveGrade < self.nMaxMonthActive then
		nMonthActiveGrade = math.min(nMonthActiveGrade + nTotalGrade-nLastGrade, self.nMaxMonthActive);
		me.SetTask(self.nTaskGroupId, self.nMonthActiveGrade, nMonthActiveGrade);
	end	
end

--获得活跃度奖励
function ActiveGift:GetActiveAward(nId)
	if GLOBAL_AGENT then
		return 0;
	end
	local nRet, szErrorMsg = self:CheckCanGetAward(1, nId);
	if nRet == 0 then
		me.Msg(szErrorMsg);
		return;
	end
	nRet, szErrorMsg = self:CheckGetAward(me, self.tbActiveAward[nId].tbParam);
	if nRet == 0 then
		me.Msg(szErrorMsg);
		return;
	end
	self:DoExcute(me, self.tbActiveAward[nId].tbParam);
	self:AddAwardTask(nId, self.nActiveAwardNum, self.nActiveAwardTime, "%Y%m%d");
	if self.tbAwardName[nId] then
		me.SendMsgToFriend(string.format("Đồng đội [<color=yellow>%s<color>] nhận được 1 <color=yellow>%s<color>, năng động hiện tại <color=yellow>%s<color> điểm. Ấn phím (J) để kiểm tra năng động của bản thân.", me.szName, self.tbAwardName[nId], me.GetTask(self.nTaskGroupId, self.nActiveGrade)));
	end
	Dbg:WriteLog("ActiveGift", "Phan thuong nang dong "..nId);
end

--获得月累计奖励
function ActiveGift:GetMonthAward(nId)
	if GLOBAL_AGENT then
		return 0;
	end
	if self.nOpen ~= 1 then
		me.Msg("Tính năng tạm khóa!");
		return 0;
	end
	local nRet, szErrorMsg = self:CheckCanGetAward(2, nId);
	if nRet == 0 then
		me.Msg(szErrorMsg);
		return;
	end	
	nRet, szErrorMsg = self:CheckGetAward(me, self.tbMonthAward[nId].tbParam);
	if nRet == 0 then
		me.Msg(szErrorMsg);
		return;
	end
	self:DoExcute(me, self.tbMonthAward[nId].tbParam);	
	self:AddAwardTask(nId, self.nMonthAwardNum, self.nMonthAwardTime, "%m");	
	Dbg:WriteLog("ActiveGift", "Tich luy thuong ngay "..nId);
end

--领取奖励加变量
function ActiveGift:AddAwardTask(nId, nTask, nTimes, szStyleData)
	if GLOBAL_AGENT then
		return 0;
	end
	if self.nOpen ~= 1 then
		me.Msg("Tính năng tạm khóa!");
		return 0;
	end
	if not nId or nId <= 0 then
		return;
	end
	if nTask and nTimes and szStyleData then
		local nNowDate = tonumber(GetLocalDate(szStyleData));
		local nDate = me.GetTask(self.nTaskGroupId, nTimes);
		local nTotalGrade = me.GetTask(self.nTaskGroupId, nTask);
		if nDate ~= nNowDate then
			me.SetTask(self.nTaskGroupId, nTimes, nNowDate);
			nTotalGrade = 0;
		end
		me.SetTask(self.nTaskGroupId, nTask, nTotalGrade + math.pow(10, nId - 1));	
	end
end


-------------------------------------------------------
-- c2s call
-------------------------------------------------------
-- 活跃度奖励
function c2s:GetActiveGiftAward(nId)
	if GLOBAL_AGENT then
		return 0;
	end
	SpecialEvent.ActiveGift:GetActiveAward(nId);
end

-- 累计天数奖励
function c2s:GetActiveMonthAward(nId)
	if GLOBAL_AGENT then
		return 0;
	end
	SpecialEvent.ActiveGift:GetMonthAward(nId)
end

