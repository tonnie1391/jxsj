Require("\\script\\event\\collectcard\\define.lua")

if (not MODULE_GC_SERVER) then
	return 0;
end

local CollectCard = SpecialEvent.CollectCard;

--集满28张卡片玩家数目赠1;
function CollectCard:AddCollectCount()
	KGblTask.SCSetDbTaskInt(DBTASD_EVENT_COLLECTCARD_FINISH, KGblTask.SCGetDbTaskInt(DBTASD_EVENT_COLLECTCARD_FINISH) + 1);	
	CollectCard:WriteLog(string.format("玩家收藏满28人数赠1, 现收藏满28张玩家人数为:%s", KGblTask.SCGetDbTaskInt(DBTASD_EVENT_COLLECTCARD_FINISH)))
end

--开启黄金箱子,有几率获得黄金5环腰带
function CollectCard:GetAward_GC(nPlayerId)
	if KGblTask.SCGetDbTaskInt(DBTASD_EVENT_COLLECTCARD_BELT01) == 0 then
		SpecialEvent:CollectCard_cheduleCallOut();
	end
	KGblTask.SCSetDbTaskInt(DBTASD_EVENT_COLLECTCARD_BELT_COUNT, KGblTask.SCGetDbTaskInt(DBTASD_EVENT_COLLECTCARD_BELT_COUNT) + 1);
	if KGblTask.SCGetDbTaskInt(DBTASD_EVENT_COLLECTCARD_BELT_COUNT) == KGblTask.SCGetDbTaskInt(DBTASD_EVENT_COLLECTCARD_BELT01) then
		GlobalExcute({"SpecialEvent.CollectCard:GetAward_GS", nPlayerId, 1});
	elseif KGblTask.SCGetDbTaskInt(DBTASD_EVENT_COLLECTCARD_BELT_COUNT) == KGblTask.SCGetDbTaskInt(DBTASD_EVENT_COLLECTCARD_BELT02) then
		GlobalExcute({"SpecialEvent.CollectCard:GetAward_GS", nPlayerId, 2});
	elseif KGblTask.SCGetDbTaskInt(DBTASD_EVENT_COLLECTCARD_BELT_COUNT) == KGblTask.SCGetDbTaskInt(DBTASD_EVENT_COLLECTCARD_BELT03) then
		GlobalExcute({"SpecialEvent.CollectCard:GetAward_GS", nPlayerId, 2});
	else
		GlobalExcute({"SpecialEvent.CollectCard:GetAward_GS", nPlayerId, 0});		
	end
end

--随机幸运项目
function CollectCard:RandomAward()
	local nTime = GetTime();
	local nNowDate = tonumber(os.date("%Y%m%d", nTime));
	if KGblTask.SCGetDbTaskInt(DBTASD_EVENT_COLLECTCARD_RANDOM_DAY) == nNowDate then
		return 0;
	end
	local nRandomItemId = MathRandom(self.CARD_START_ID, self.CARD_END_ID)
	KGblTask.SCSetDbTaskInt(DBTASD_EVENT_COLLECTCARD_RANDOM, nRandomItemId);
	KGblTask.SCSetDbTaskInt(DBTASD_EVENT_COLLECTCARD_RANDOM_DAY, nNowDate);
	
	
	local szCard = self.TASK_CARD_ID[nRandomItemId][2];
	local nAddTime	= Lib:GetDate2Time(math.floor(self.TIME_STATE[1]/100));
	local nEndTime	= Lib:GetDate2Time(math.floor(self.TIME_STATE[2]/100));
	--local nEndTime_Finial	= Lib:GetDate2Time(math.floor(self.TIME_STATE[4]/100));
	
	local szTime	= os.date("%m月%d日", nTime);
	local szTitle	= string.format("%s国庆活动幸运卡民族", szTime);
	local szMsg		= string.format("<color=yellow>%s<color>国庆活动幸运卡民族：<color=yellow>%s<color>\n\n所有今天鉴定出的民族大团圆幸运卡的玩家，都可以使用换取幸运卡奖励\n\n奖励内容（二选一）：\n<color=yellow> （1）1500绑定%s \n （2）摇奖获得奇珍阁不绑定道具<color>\n\n对于没有中奖的民族大团圆卡，直接使用换取鼓励奖，使用卡片将自动收藏在民族大团圆卡收藏册内。",szTime, szCard, IVER_g_szCoinName);
	self:WriteLog("SetLuckCardNews"..szTitle..szTime..szCard);
	Task.tbHelp:SetDynamicNews(Task.tbHelp.NEWSKEYID.NEWS_LUCKCARD, szTitle, szMsg, nEndTime, nAddTime);
end

function SpecialEvent:RandomAwardNationalDay09()
	PlayerHonor:UpdateSpringHonorLadder();
	CollectCard:RandomAward();
end

--火炬手排名
function CollectCard:AddRank_GC(szName, nPoint)
	if nPoint <= KGblTask.SCGetDbTaskInt(DBTASD_EVENT_COLLECTCARD_RANK10) then
		return 0;
	end
	for ni = DBTASD_EVENT_COLLECTCARD_RANK01, DBTASD_EVENT_COLLECTCARD_RANK10 do 
		if szName == KGblTask.SCGetDbTaskStr(ni) then
			if nPoint <= KGblTask.SCGetDbTaskInt(ni) then
				return 0;
			end
			for nj = ni, DBTASD_EVENT_COLLECTCARD_RANK10 do
				if (nj + 1) <= DBTASD_EVENT_COLLECTCARD_RANK10 then				
					local nPointTemp = KGblTask.SCGetDbTaskInt(nj + 1);
					local szNameTemp = KGblTask.SCGetDbTaskStr(nj + 1);
					KGblTask.SCSetDbTaskInt(nj, nPointTemp);
					KGblTask.SCSetDbTaskStr(nj, szNameTemp);
				end
			end
			KGblTask.SCSetDbTaskInt(DBTASD_EVENT_COLLECTCARD_RANK10, 0);
			KGblTask.SCSetDbTaskStr(DBTASD_EVENT_COLLECTCARD_RANK10, "");
			break;
		end
	end
	
	for ni = (DBTASD_EVENT_COLLECTCARD_RANK10-1), DBTASD_EVENT_COLLECTCARD_RANK01, -1 do
		if nPoint > KGblTask.SCGetDbTaskInt(DBTASD_EVENT_COLLECTCARD_RANK01) then
			for nj = DBTASD_EVENT_COLLECTCARD_RANK10, DBTASD_EVENT_COLLECTCARD_RANK01 + 1, -1 do
				local nPointTemp = KGblTask.SCGetDbTaskInt(nj-1);
				local szNameTemp = KGblTask.SCGetDbTaskStr(nj-1);
				if nPointTemp ~= 0 then
					KGblTask.SCSetDbTaskInt(nj, nPointTemp);
					KGblTask.SCSetDbTaskStr(nj, szNameTemp);
				end
			end
			KGblTask.SCSetDbTaskInt(DBTASD_EVENT_COLLECTCARD_RANK01, nPoint);
			KGblTask.SCSetDbTaskStr(DBTASD_EVENT_COLLECTCARD_RANK01, szName);
			return 1;
		end
		if nPoint > KGblTask.SCGetDbTaskInt(ni+1) and nPoint <= KGblTask.SCGetDbTaskInt(ni) then
			for nj = DBTASD_EVENT_COLLECTCARD_RANK10, ni + 1, -1 do
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

--随机获得全服唯一奖励玩家
function CollectCard:RandomOnlyServerAward()
	local nPlayerMax = KGblTask.SCGetDbTaskInt(DBTASD_EVENT_COLLECTCARD_FINISH)
	local tbList = {};
	for i=1, nPlayerMax do
		tbList[i] = i;
	end
	
	for i=1, nPlayerMax do
		local nRate = MathRandom(1, (nPlayerMax + 1));
		tbList[i], tbList[nRate] = tbList[nRate], tbList[i];
	end
	if tbList[1] then
		KGblTask.SCSetDbTaskInt(DBTASD_EVENT_COLLECTCARD_BELT01, tbList[1]);
		CollectCard:WriteLog(string.format("成功设定全服唯一获得黄金令牌玩家"))		
	end
	if tbList[2] then	
		KGblTask.SCSetDbTaskInt(DBTASD_EVENT_COLLECTCARD_BELT02, tbList[2]);
		CollectCard:WriteLog(string.format("成功设定全服唯一获得白银令牌第一个玩家"))				
	end
	if tbList[3] then
		KGblTask.SCSetDbTaskInt(DBTASD_EVENT_COLLECTCARD_BELT03, tbList[3]);
		CollectCard:WriteLog(string.format("成功设定全服唯一获得白银令牌第二个玩家"))						
	end
end
-- 动态注册到时间任务系统
function CollectCard:RegisterScheduleTask()
	local nData = tonumber(GetLocalDate("%Y%m%d%H%M%S"));
	if nData < self.TIME_STATE[2] then
		local nTaskId = KScheduleTask.AddTask("国庆活动抽取幸运卡", "SpecialEvent", "CollectCard_cheduleCallOut");
		assert(nTaskId > 0);
		KScheduleTask.RegisterTimeTask(nTaskId, 0, 1); -- 0点
	end
end

--定时执行
function SpecialEvent:CollectCard_cheduleCallOut()
	local nData = tonumber(GetLocalDate("%Y%m%d%H%M%S"));
	if nData >= CollectCard.TIME_STATE[1] and nData < CollectCard.TIME_STATE[2] then
		CollectCard:RandomAward();
	end
	
	--if nData >= CollectCard.TIME_STATE[2] and KGblTask.SCGetDbTaskInt(DBTASD_EVENT_COLLECTCARD_BELT01) == 0 then
	--	CollectCard:RandomOnlyServerAward()
	--end
end

function CollectCard:SetCollectCardNews()
	local nData = tonumber(GetLocalDate("%Y%m%d%H%M%S"));
	if nData >= self.TIME_STATE[1] and nData < self.TIME_STATE[2] then
		local nAddTime	= Lib:GetDate2Time(math.floor(self.TIME_STATE[1]/100));
		for ni, tbMsg in ipairs(self.HelpSprite)do
			Task.tbHelp:SetCollectCardNews(nAddTime, nAddTime + 86400, tbMsg.szTitle, tbMsg.szMsg, ni);
		end		
	end
end

-- 清除飞絮崖荣誉，同时更新排行榜的名字
-- 只须调一次
function CollectCard:ClearSpringRecord(__debug)
	if KGblTask.SCGetDbTaskInt(DBTASK_NATIONAL_DAY_CLEAR_DATE) == 0 or __debug == 42 then
		local nLadderType = Ladder:GetType(0, Ladder.LADDER_CLASS_LADDER, Ladder.LADDER_TYPE_LADDER_ACTION, Ladder.LADDER_TYPE_LADDER_ACTION_SPRING);
		local nDataClass = PlayerHonor.HONOR_CLASS_SPRING;
		Ladder:ClearTotalLadderData(nLadderType, nDataClass, 0, 1);
		PlayerHonor:UpdateSpringHonorLadder();
		KGblTask.SCSetDbTaskInt(DBTASK_NATIONAL_DAY_CLEAR_DATE, tonumber(GetLocalDate("%Y%m%d")));
	end
end

--GCEvent:RegisterGCServerStartFunc(SpecialEvent.CollectCard.RegisterScheduleTask, SpecialEvent.CollectCard);
--GCEvent:RegisterGCServerStartFunc(SpecialEvent.CollectCard_cheduleCallOut, SpecialEvent);
--GCEvent:RegisterGCServerStartFunc(SpecialEvent.CollectCard.SetCollectCardNews, SpecialEvent.CollectCard);

GCEvent:RegisterGCServerStartFunc(SpecialEvent.CollectCard.ClearSpringRecord, SpecialEvent.CollectCard);
GCEvent:RegisterGCServerStartFunc(SpecialEvent.CollectCard.RandomAward, SpecialEvent.CollectCard);
