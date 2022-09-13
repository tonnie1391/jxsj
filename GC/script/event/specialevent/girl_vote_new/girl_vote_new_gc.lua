-- 文件名  : girl_vote_new_gc.lua
-- 创建者  : zounan
-- 创建时间: 2010-09-21 11:58:17
-- 描述    : 

if (not MODULE_GC_SERVER) then
	return 0;
end

Require("\\script\\event\\specialevent\\girl_vote_new\\girl_vote_new_def.lua");
local tbGirl = SpecialEvent.Girl_Vote_New;

function SpecialEvent:Girl_Vote_New_Rank()
	if not GLOBAL_AGENT then
		tbGirl:Rank();
	end
end

if GLOBAL_AGENT then
	return 0;
end

function tbGirl:StartEvent()
	if self:GetState() ==  self.emVOTE_STATE_NONE then
		return;
	end	
	self.tbGblBuf = {};
	local tbBuf = GetGblIntBuf(GBLINTBUF_GIRL_VOTE_NEW, 0);
	if tbBuf and type(tbBuf)=="table"  then
		self.tbGblBuf = tbBuf;
	end
	self:Rank();
end

local function OnSort(tbA, tbB)
	if tbA.nTickets == tbB.nTickets then
		tbA.nSort = tbA.nSort or 99;
		tbB.nSort = tbB.nSort or 99;
		return tbA.nSort < tbB.nSort;
	end
	return tbA.nTickets > tbB.nTickets;
end

function tbGirl:Rank()	
	if not self.tbGblBuf then
		return;
	end

--	if self.TIME_AWARD_START

	local tbBuf = self:GetGblBuf();
	self.tbRank = {};
	local tbRank = self.tbRank;

	for szName,tbInfo in pairs(tbBuf) do	
		self:AddIntoTable(tbRank,{szName = szName,nTickets = tbInfo.nTickets,nSort = tbInfo.nSort or 99});
	end
	
	-- 加上权重 -- 以后排序票数一致时就以这个为基准
	for nIndex, tbInfo in ipairs(tbRank) do
		tbBuf[tbInfo.szName].nSort = nIndex;
	end	
	SetGblIntBuf(GBLINTBUF_GIRL_VOTE_NEW, 0, 1, tbBuf);
	self:SyncRank();
end

function tbGirl:SyncRank(nServerId)
	nServerId = nServerId or -1;
	for nIndex, tbInfo in ipairs(self.tbRank or {}) do
		GSExcute(nServerId, {"SpecialEvent.Girl_Vote_New:OnRecRank", nIndex, tbInfo});
	end		
end

function tbGirl:SaveBuffer()
	local tbBuf = self:GetGblBuf();
	SetGblIntBuf(GBLINTBUF_GIRL_VOTE_NEW, 0, 1, tbBuf);
end
function tbGirl:GetGblBuf()
	self.tbGblBuf = self.tbGblBuf or {};
	return self.tbGblBuf;
end

function tbGirl:SetGblBuf(tbBuf)
	self.tbGblBuf = tbBuf;
end

function tbGirl:SignUpBuf(nServerId, szName,nPlayerId)
	if KGblTask.SCGetDbTaskInt(DBTASK_GIRL_VOTE_MAX_NEW) >=50000 then
		--Dialog:Say("本服务器报名人数太多了,已达上限,请和游戏管理员联系.");
		GSExcute(-1, {"SpecialEvent.Girl_Vote_New:OnSignUp",nPlayerId,0});
		return 0;
	end	
	local tbBuf = self:GetGblBuf();
	if tbBuf[szName] then
		GSExcute(-1, {"SpecialEvent.Girl_Vote_New:OnSignUp",nPlayerId,1});
		GlobalExcute({"SpecialEvent.Girl_Vote_New:OnRecConnectMsg", szName, tbBuf[szName]});
		return 1;
	end
	tbBuf[szName] = {nTickets = 0,tbFans = {},};

	KGblTask.SCSetDbTaskInt(DBTASK_GIRL_VOTE_MAX_NEW, (KGblTask.SCGetDbTaskInt(DBTASK_GIRL_VOTE_MAX_NEW) + 1));
	GlobalExcute({"SpecialEvent.Girl_Vote_New:OnRecConnectMsg", szName, tbBuf[szName]});
	GSExcute(-1, {"SpecialEvent.Girl_Vote_New:OnSignUp",nPlayerId,1});
	self:SetGblBuf(tbBuf);
end


function tbGirl:BufVoteTicket(szName, nTickets, tbFans)
	local tbBuf = self:GetGblBuf();
	tbBuf[szName] = tbBuf[szName] or {};
	tbBuf[szName].nTickets = (tbBuf[szName].nTickets or 0) + nTickets;
	tbBuf[szName].tbFans = 	tbBuf[szName].tbFans or {};
	local nIndex = self:FindFans(tbBuf[szName].tbFans,tbFans.szName);
	if nIndex == 0 then
		tbBuf[szName].tbFans[#(tbBuf[szName].tbFans) + 1] = tbFans;
	else	
		tbBuf[szName].tbFans[nIndex].nTickets = tbFans.nTickets;
	end

	if #(tbBuf[szName].tbFans) > 1 then
		table.sort(tbBuf[szName].tbFans,OnSort);
	end
	
	
	for i = self.DEF_FANS_MAX_NUM + 1 , #(tbBuf[szName].tbFans) do
		tbBuf[szName].tbFans[i] = nil;		
	end
	
	-- 加上权重 -- 以后排序票数一致时就以这个为基准
	for i = 1, #(tbBuf[szName].tbFans) do
		tbBuf[szName].tbFans[i].nSort = i;		
	end
	
	self:SetGblBuf(tbBuf);
	GlobalExcute({"SpecialEvent.Girl_Vote_New:OnRecConnectMsg", szName, tbBuf[szName]});
	GlobalExcute({"SpecialEvent.Girl_Vote_New:OnVoteTickest", szName, tbFans.szName,nTickets});
	Dbg:WriteLog("SpecialEvent.Girl_Vote_New", string.format("%s投了%d票给%s",tbFans.szName,nTickets,szName));
end

function tbGirl:OnRecConnectEvent(nConnectId)
	if self:GetState() ==  self.emVOTE_STATE_NONE then
		return;
	end	
	if self.tbGblBuf then
		for szName, tbInfo in pairs(self.tbGblBuf) do
			GlobalExcute({"SpecialEvent.Girl_Vote_New:OnRecConnectMsg", szName, tbInfo});
		end
	end

	self:SyncRank(nConnectId);
end

--一些与逻辑不大相关的函数
function tbGirl:FindFans(tbFans,szName)
	for nIndex, tbInfo in ipairs(tbFans) do
		if tbInfo.szName == szName then
			return nIndex;
		end
	end
	return 0;
end


-- 一个简单的 插入排序
function tbGirl:AddIntoTable(tbTable, tbInfo)
	
  --tbRank, {szName = szName,nTickets = tbInfo.nTickets,nSort = tbInfo.nSort or 0});	
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

function tbGirl:CoZoneGirlVoteNewBuf(tbSubBuf)
	print("CombinSubZoneAndMainZone CoZoneGirlVoteNewBuf start");
	tbSubBuf = tbSubBuf or {};
 	self.tbGblBuf = {};
	local tbBuf = GetGblIntBuf(GBLINTBUF_GIRL_VOTE_NEW, 0);
	if tbBuf and type(tbBuf)=="table"  then
		self.tbGblBuf = tbBuf;
	end
	
	for szName, tbInfo in pairs(tbSubBuf) do
		self.tbGblBuf[szName] = tbInfo;
	end

	SetGblIntBuf(GBLINTBUF_GIRL_VOTE_NEW, 0, 1, self.tbGblBuf);
	print("CombinSubZoneAndMainZone CoZoneGirlVoteNewBuf end");
end 
  
  



if tbGirl.IS_OPEN == 1 then
GCEvent:RegisterGCServerStartFunc(SpecialEvent.Girl_Vote_New.StartEvent, SpecialEvent.Girl_Vote_New);
GCEvent:RegisterGCServerShutDownFunc(SpecialEvent.Girl_Vote_New.SaveBuffer, SpecialEvent.Girl_Vote_New);
GCEvent:RegisterGS2GCServerStartFunc(SpecialEvent.Girl_Vote_New.OnRecConnectEvent,SpecialEvent.Girl_Vote_New);
end
