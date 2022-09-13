--王老吉活动
--孙多良
--2008.08.22

if (not MODULE_GC_SERVER) then
	return
end


Require("\\script\\event\\wanglaoji\\wanglaoji_def.lua")

local WangLaoJi = SpecialEvent.WangLaoJi;

function WangLaoJi:ReSort()
	if not self.TIME_STATE_WEEK[tonumber(GetLocalDate("%Y%m%d"))] then
		return 0;
	end
	KGblTask.SCSetDbTaskInt(DBTASD_EVENT_KEEP10, self.TIME_STATE_WEEK[tonumber(GetLocalDate("%Y%m%d"))]);
	local nPoint = KGblTask.SCGetDbTaskInt(DBTASD_EVENT_SORT01);
	local szName = KGblTask.SCGetDbTaskStr(DBTASD_EVENT_SORT01);
	if nPoint >= self.DEF_WEEK_GRAGE then
		local nSort01 = self.KEEP_SORT[KGblTask.SCGetDbTaskInt(DBTASD_EVENT_KEEP10)]
		KGblTask.SCSetDbTaskInt(nSort01, nPoint);
		KGblTask.SCSetDbTaskStr(nSort01, szName);
		
		--最后一周不进行删除清空第一名
		if KGblTask.SCGetDbTaskInt(DBTASD_EVENT_KEEP10) < 10 then
			for i=DBTASD_EVENT_SORT02, DBTASD_EVENT_SORT21 do
				KGblTask.SCSetDbTaskInt(i-1, KGblTask.SCGetDbTaskInt(i));
				KGblTask.SCSetDbTaskStr(i-1, KGblTask.SCGetDbTaskStr(i));
			end
			KGblTask.SCSetDbTaskInt(DBTASD_EVENT_SORT21, 0);
			KGblTask.SCSetDbTaskStr(DBTASD_EVENT_SORT21, "");
		end
	end

	if KGblTask.SCGetDbTaskInt(DBTASD_EVENT_KEEP10) >= 10 then
		for i=1, 10 do
			local ni = self.KEEP_SORT[i]
			local szName = KGblTask.SCGetDbTaskStr(ni);
			local nPoint = KGblTask.SCGetDbTaskInt(ni);
			if nPoint >= self.DEF_WEEK_EXGRAGE then
				local nCount = math.floor((nPoint - self.DEF_WEEK_EXGRAGE) / self.DEF_WEEK_EXPREGRAGE) + 1
				if nCount > 5 then
					nCount = 5;
				end
				local szTitle = "防上火行动额外奖励";
				local szMsg = string.format("    鉴于您在“<color=yellow>江湖防上火行动<color>”中的积极表现，以%s的高分夺得了周第一,鉴于您的大量付出，特此奖励<color=yellow>盛夏活动青铜令牌%s个<color>，请尽快到<color=yellow>盛夏活动推广员<color>处领取最终活动奖励。如果超过1个月没有领取，将<color=red>失去领奖资格<color>。", nPoint, nCount);
				SendMailGC(szName, szTitle, szMsg);
			end
			Dbg:WriteLog("SpecialEvent.WangLaoJi", "王老吉活动", "最终排名名单",string.format("第%s周",i), szName, "积分:"..nPoint);
		end
		local nRank = 0;
		for i=DBTASD_EVENT_SORT01, DBTASD_EVENT_SORT20 do
			nRank = nRank + 1;
			local nPoint = KGblTask.SCGetDbTaskInt(i);
			local szName = KGblTask.SCGetDbTaskStr(i);
			if i ~= DBTASD_EVENT_SORT01 and nPoint >= self.DEF_WEEK_GRAGE then
				local szTitle = "防上火行动额外奖励";
				local szMsg = string.format("    非常遗憾您没能在”<color=yellow>江湖防上火行动<color>”中获得周第一,但鉴于您在活动中的积极表现,特别奖励您<color=yellow>一个盛夏活动青铜令牌<color>, 请尽快到<color=yellow>盛夏活动推广员<color>处领取最终活动奖励。请在<color=yellow>12月2日24点前<color>领取，否则将失去领奖资格。", nPoint);
				SendMailGC(szName, szTitle, szMsg);
			end			
			Dbg:WriteLog("SpecialEvent.WangLaoJi", "王老吉活动", "最终排名名单1-20名",string.format("第%s名",nRank), szName, "积分:"..nPoint);
		end
	end
end

function WangLaoJi:DoSort(nPoint, szName)
	local nDefStart = DBTASD_EVENT_SORT01;
	local nDefEnd   = DBTASD_EVENT_SORT21;
	if nPoint <= KGblTask.SCGetDbTaskInt(nDefEnd) then
		return 0;
	end
	for ni = nDefStart, nDefEnd do 
		if szName == KGblTask.SCGetDbTaskStr(ni) then
			if nPoint <= KGblTask.SCGetDbTaskInt(ni) then
				return 0;
			end
			for nj = ni, nDefEnd do
				if (nj + 1) <= nDefEnd then				
					local nPointTemp = KGblTask.SCGetDbTaskInt(nj + 1);
					local szNameTemp = KGblTask.SCGetDbTaskStr(nj + 1);
					KGblTask.SCSetDbTaskInt(nj, nPointTemp);
					KGblTask.SCSetDbTaskStr(nj, szNameTemp);
				end
			end
			KGblTask.SCSetDbTaskInt(nDefEnd, 0);
			KGblTask.SCSetDbTaskStr(nDefEnd, "");
			break;
		end
	end
	
	for ni = (nDefEnd-1), nDefStart, -1 do
		if nPoint > KGblTask.SCGetDbTaskInt(nDefStart) then
			for nj = nDefEnd, nDefStart + 1, -1 do
				local nPointTemp = KGblTask.SCGetDbTaskInt(nj-1);
				local szNameTemp = KGblTask.SCGetDbTaskStr(nj-1);
				if nPointTemp ~= 0 then
					KGblTask.SCSetDbTaskInt(nj, nPointTemp);
					KGblTask.SCSetDbTaskStr(nj, szNameTemp);
				end
			end
			KGblTask.SCSetDbTaskInt(nDefStart, nPoint);
			KGblTask.SCSetDbTaskStr(nDefStart, szName);
			return 1;
		end
		if nPoint > KGblTask.SCGetDbTaskInt(ni+1) and nPoint <= KGblTask.SCGetDbTaskInt(ni) then
			for nj = nDefEnd, ni + 1, -1 do
				local nPointTemp = KGblTask.SCGetDbTaskInt(nj-1);
				local szNameTemp = KGblTask.SCGetDbTaskStr(nj-1);
				KGblTask.SCSetDbTaskInt(nj, nPointTemp);
				KGblTask.SCSetDbTaskStr(nj, szNameTemp);
			end
			KGblTask.SCSetDbTaskInt(ni+1, nPoint);
			KGblTask.SCSetDbTaskStr(ni+1, szName);
			return 1;
		end
	end	
end

-- 动态注册到时间任务系统
function WangLaoJi:RegisterScheduleTask()
	local nData = tonumber(GetLocalDate("%Y%m%d"));
	if nData < self.TIME_STATE_NEW[3] then
		local nTaskId = KScheduleTask.AddTask("王老吉防上火行动", "SpecialEvent", "WangLaoJi_cheduleCallOut");
		assert(nTaskId > 0);
		KScheduleTask.RegisterTimeTask(nTaskId, 0, 1);
	end
end

--定时执行
function SpecialEvent:WangLaoJi_cheduleCallOut()
	local nData = tonumber(GetLocalDate("%Y%m%d"));
	local nWeek = tonumber(GetLocalDate("%w"))
	if nData >= WangLaoJi.TIME_STATE_NEW[1] and nData <= WangLaoJi.TIME_STATE_NEW[3] then
		if nWeek == 2 then
			WangLaoJi:ReSort();
		end
	end
	if nData < WangLaoJi.TIME_STATE_NEW[3] then
		WangLaoJi:SetNews();
	end
end

function WangLaoJi:SetNews()
	local nData = tonumber(GetLocalDate("%Y%m%d"));
	if nData < WangLaoJi.TIME_STATE[3] then
		local nAddTime = Lib:GetDate2Time(math.floor(SpecialEvent.WangLaoJi.TIME_STATE[1]*10000));
		local nEndTime = Lib:GetDate2Time(math.floor(SpecialEvent.WangLaoJi.TIME_STATE[3]*10000));
		Task.tbHelp:SetDynamicNews(self.NEWS_INFO[1].nKey, self.NEWS_INFO[1].szTitle, self.NEWS_INFO[1].szMsg, nEndTime, nAddTime);
	end
	if nData < WangLaoJi.TIME_STATE_NEW[3] then
		local nAddTime = Lib:GetDate2Time(math.floor(SpecialEvent.WangLaoJi.TIME_STATE_NEW[1]*10000));
		local nEndTime = Lib:GetDate2Time(math.floor(SpecialEvent.WangLaoJi.TIME_STATE_NEW[3]*10000));
		Task.tbHelp:SetDynamicNews(self.NEWS_INFO[2].nKey, self.NEWS_INFO[2].szTitle, self.NEWS_INFO[2].szMsg, nEndTime, nAddTime);
		Task.tbHelp:SetDynamicNews(self.NEWS_INFO[3].nKey, self.NEWS_INFO[3].szTitle, self.NEWS_INFO[3].szMsg, nEndTime, nAddTime);
	end
end

--WangLaoJi:RegisterScheduleTask()
GCEvent:RegisterGCServerStartFunc(SpecialEvent.WangLaoJi.SetNews, SpecialEvent.WangLaoJi);
