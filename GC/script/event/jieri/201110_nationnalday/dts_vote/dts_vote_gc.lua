-- 文件名　：dts_vote_gc.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-09-07 20:25:20
-- 功能    ：

if (not MODULE_GC_SERVER) then
	return 0;
end

if GLOBAL_AGENT then
	return 0;
end

Require("\\script\\event\\jieri\\201110_nationnalday\\dts_vote\\dts_vote_def.lua");
local tbDtsVote = SpecialEvent.Dts_Vote;

function tbDtsVote:Dts_Vote_Rank()
	if not GLOBAL_AGENT then
		tbDtsVote:Rank();
	end
end

function tbDtsVote:StartEvent()
	if self:GetState() ==  self.emVOTE_STATE_NONE then
		return;
	end	
	self.tbGblBuf = {};
	local tbBuf = GetGblIntBuf(GBLINTBUF_Dts_Vote, 0);
	if tbBuf and type(tbBuf)=="table"  then
		self.tbGblBuf = tbBuf;
	end
	self:Rank();
	SpecialEvent:OnCreatAwardList_Dts(1);
end

local function OnSort(tbA, tbB)
	return tbA.nTickets > tbB.nTickets;
end

function tbDtsVote:Rank()	
	if not self.tbGblBuf then
		return;
	end	
	local tbBuf = self:GetGblBuf();
	self.tbRank = {};
	local tbRank = self.tbRank;

	for szName,tbInfo in pairs(tbBuf) do
		self:AddIntoTable(tbRank,{szName = szName,nTickets = tbInfo.nTickets});
	end
		
	self:SyncRank();
end

function tbDtsVote:SyncRank(nServerId)
	nServerId = nServerId or -1;
	for nIndex, tbInfo in ipairs(self.tbRank or {}) do
		GSExcute(nServerId, {"SpecialEvent.Dts_Vote:OnRecRank", nIndex, tbInfo});
	end		
end

function tbDtsVote:SaveBuffer()
	local tbBuf = self:GetGblBuf();
	SetGblIntBuf(GBLINTBUF_Dts_Vote, 0, 1, tbBuf);
end

function tbDtsVote:GetGblBuf()
	self.tbGblBuf = self.tbGblBuf or {};
	return self.tbGblBuf;
end

function tbDtsVote:SetGblBuf(tbBuf)
	self.tbGblBuf = tbBuf;
end

function tbDtsVote:BufVoteTicket(szName, nTickets, tbFans)
	local tbBuf = self:GetGblBuf();
	tbBuf[szName] = tbBuf[szName] or {};
	tbBuf[szName].nTickets = (tbBuf[szName].nTickets or 0) + nTickets;
	tbBuf[szName].tbFans = 	tbBuf[szName].tbFans or {};	
	tbBuf[szName].tbFans[#(tbBuf[szName].tbFans) + 1] = tbFans;
	
	self:SetGblBuf(tbBuf);
	GlobalExcute({"SpecialEvent.Dts_Vote:OnRecConnectMsg", szName, tbBuf[szName]});
	GlobalExcute({"SpecialEvent.Dts_Vote:OnVoteTickest", szName, tbFans.szName,nTickets});
	Dbg:WriteLog("SpecialEvent.Dts_Vote", string.format("%s投了%d票给%s",tbFans.szName,nTickets,szName));
end

function tbDtsVote:OnRecConnectEvent(nConnectId)
	if self:GetState() ==  self.emVOTE_STATE_NONE then
		return;
	end	
	if self.tbGblBuf then
		for szName, tbInfo in pairs(self.tbGblBuf) do
			GlobalExcute({"SpecialEvent.Dts_Vote:OnRecConnectMsg", szName, tbInfo});
		end
	end

	self:SyncRank(nConnectId);
end

-- 一个简单的 插入排序
function tbDtsVote:AddIntoTable(tbTable, tbInfo)
	if #tbTable == 0 then
		tbTable[1] = tbInfo;
		return;
	end
	
	local nInSert = 0;
	for i = #tbTable, 1, -1 do
		if  OnSort(tbTable[i],tbInfo) == true then
			nInSert = i;
			break;
		end	
	end
	
	if #tbTable < self.DEF_SORT_MAX_NUM then
		tbTable[#tbTable + 1] = {};
	end
		
	for i = #tbTable - 1, nInSert + 1, -1 do
		tbTable[i+1] = tbTable[i];
	end
	if nInSert < #tbTable then
		tbTable[nInSert + 1] = tbInfo;
	end
end

--生成奖励表
function tbDtsVote:GenerateAwardTable(tbPlayerInfo)
	if Lib:CountTB(tbPlayerInfo) <= 0 then
		return;
	end
	local tbAwardList = {};		--中奖的情况[szName]=nCount
	local tbVoteTicketsCount = {};	--投奖的情况[szName]=nCount
	local tbBuf = self:GetGblBuf();
	local nTotleTicketsInSys = 0;	--奖池
	for szName, tb in pairs(tbBuf) do
		for _, tbFansEx in ipairs (tb.tbFans) do
			if tbPlayerInfo[szName] then
				if not tbAwardList[tbFansEx.szName] then
					tbAwardList[tbFansEx.szName] = 1;
				else
					tbAwardList[tbFansEx.szName] = tbAwardList[tbFansEx.szName] + 1;
				end
			end
			if not tbVoteTicketsCount[tbFansEx.szName] then
				tbVoteTicketsCount[tbFansEx.szName] = 1;
			else
				tbVoteTicketsCount[tbFansEx.szName] = tbVoteTicketsCount[tbFansEx.szName] + 1;
			end
		end
		nTotleTicketsInSys = nTotleTicketsInSys + tb.nTickets;
	end	
	nTotleTicketsInSys = nTotleTicketsInSys * self.nPerValue + self.nMinValue;			--奖池重新换算
	local nCoinCount = math.floor(nTotleTicketsInSys * self.tbCoinRate );				--奖池绑金数量
	local nBoxCount = math.floor(nTotleTicketsInSys * self.tbBoxRate / self.tbBoxValue);	--箱子的个数
	
	local nTotleTickets = 0;	--总权重	
	for szName, nCount in pairs(tbAwardList) do
		local nCountEx = self.tbRate[nCount];	--根据中的个数换算为权重
		nTotleTickets = nTotleTickets +  nCountEx;
		tbAwardList[szName] = {tbVoteTicketsCount[szName], nCount, nCountEx};
	end
	
	local nCountMaxThr = 0;		--投票数大于等于3且中了奖的玩家
	--计算投了三票且中了奖的人
	for szName, nCount in pairs(tbVoteTicketsCount) do
		if nCount >= 3 and tbAwardList[szName] then
			nCountMaxThr = nCountMaxThr + 1;
		end
	end
	
	local nBoxPerCount = math.floor(nBoxCount / nCountMaxThr);	--大于等于3的玩家每人可以获得箱子
	local nRandCount = math.fmod(nBoxCount,  nCountMaxThr);		--大于等于3的玩家平均分掉后剩余箱子
	
	local nTicketsOne =  math.floor(nCoinCount / nTotleTickets);		-- 计算每股奖励
	
	local nPaifaCount = 0;	--派发的数量
	for szName, tb in pairs (tbAwardList) do
		local nTicketsVoted = tb[1];	--投的票
		local nTicketsVoting = tb[2];	--中的票
		tbAwardList[szName][1]  = nTicketsVoting;
		tbAwardList[szName][2] = nTicketsOne * tb[3];
		if nTicketsVoted >= 3 then
			if nPaifaCount < nRandCount then
				tbAwardList[szName][3] = nBoxPerCount + 1;
				nPaifaCount = nPaifaCount + 1;
			else
				tbAwardList[szName][3] = nBoxPerCount;
			end
		else
			tbAwardList[szName][3] = 0;
		end
		--生成奖励名单
		StatLog:WriteStatLog("stat_info", "mid_autumn2011", "bingo", KGCPlayer.GetPlayerIdByName(szName), string.format("%s,%s,%s,%s", szName, tbAwardList[szName][1], tbAwardList[szName][2], tbAwardList[szName][3]));
	end	
	SetGblIntBuf(GBLINTBUF_Dts_Vote2, 0, 1, tbAwardList);
	GlobalExcute({"SpecialEvent.Dts_Vote:Loadbuff"});
end

--大逃杀结束第二天0点05分生成奖励，10分开始领取奖
function SpecialEvent:OnCreatAwardList_Dts(bStar)
	--投票期间和投票最后一天的下一天每天0:05存一次buff并排序
	if not bStar and (SpecialEvent.Dts_Vote:GetState() == SpecialEvent.Dts_Vote.emVOTE_STATE_SIGN or tonumber(GetLocalDate("%Y%m%d")) == 20111001) then
		SpecialEvent.Dts_Vote:Dts_Vote_Rank();
		SpecialEvent.Dts_Vote:SaveBuffer();
	end
	local nFlag = KGblTask.SCGetDbTaskInt(DBTASK_DTSVOTE_TASK_ID);
	if tonumber(GetLocalDate("%Y%m%d")) ~= SpecialEvent.Dts_Vote.TIME_AWARD_START or nFlag == 1 then
		return;
	end
	local nType = Ladder:GetType(0, 2, 2, 9);
	local tbPlayerInfo = {};
	for i = 1, 10 do
		local tbInfor = GetPlayerLadderInfoByRank(nType, i);
		if not tbInfor then
			break;
		end
		tbPlayerInfo[tbInfor.szPlayerName] = 1;
	end
	SpecialEvent.Dts_Vote:GenerateAwardTable(tbPlayerInfo);
	KGblTask.SCSetDbTaskInt(DBTASK_DTSVOTE_TASK_ID, 1);
end

function SpecialEvent:DtsVote_Msg()
	if SpecialEvent.Dts_Vote:GetState() ~= SpecialEvent.Dts_Vote.emVOTE_STATE_SIGN then
		return;
	end
	local szMsg = string.format("寒武勇士大猜想活动正在紧锣密鼓的举行中，当前奖池为%s绑金和%s个原矿箱子，还不快快行动，大奖等你来拿！", SpecialEvent.Dts_Vote:GenAwardInfo());
	Dialog:GlobalNewsMsg_GC(szMsg);
	Dialog:GlobalMsg2SubWorld_GC(szMsg);
end

--10月12号凌晨 0点05，生成奖励
function tbDtsVote:RegisterScheduleTask_GC()
	--每天存buff和最终奖励生成
	local nTaskId = KScheduleTask.AddTask("SpecialEvent", "SpecialEvent", "OnCreatAwardList_Dts");
	KScheduleTask.RegisterTimeTask(nTaskId, 0005, 1);
	--投票期间每天公告
	local nTask = 0;
	local nTaskIdEx = KScheduleTask.AddTask("SpecialEvent", "SpecialEvent", "DtsVote_Msg");
	for i = 0, 2300, 100 do
		for _, nTime in ipairs(self.TIME_SCHTASK) do
			nTask = nTask + 1;
			local nTimeEx = i + nTime;
			-- 时间执行点注册
			KScheduleTask.RegisterTimeTask(nTaskIdEx, nTimeEx, nTask);
		end
	end
end

if tbDtsVote.IS_OPEN == 1 then
	GCEvent:RegisterGCServerStartFunc(SpecialEvent.Dts_Vote.RegisterScheduleTask_GC, SpecialEvent.Dts_Vote);
	GCEvent:RegisterGCServerStartFunc(SpecialEvent.Dts_Vote.StartEvent, SpecialEvent.Dts_Vote);
	GCEvent:RegisterGCServerShutDownFunc(SpecialEvent.Dts_Vote.SaveBuffer, SpecialEvent.Dts_Vote);
	GCEvent:RegisterGS2GCServerStartFunc(SpecialEvent.Dts_Vote.OnRecConnectEvent,SpecialEvent.Dts_Vote);
end
