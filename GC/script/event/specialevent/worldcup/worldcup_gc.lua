-- 文件名　：worldcup_gc.lua
-- 创建者　：furuilei
-- 创建时间：2010-05-17 09:14:51
-- 功能描述：世界杯gc逻辑

-- Require("\\script\\event\\specialevent\\worldcup\\worldcup_def.lua")
if not MODULE_GC_SERVER then
	return;
end
SpecialEvent.tbWroldCup = SpecialEvent.tbWroldCup or {};
local tbEvent = SpecialEvent.tbWroldCup;

tbEvent.nTimerId = 0;

-- 设置卡片的价值量，这个接口留给平台使用
-- 传入table记录的是各个球队的成绩
function tbEvent:SetCardValue_GC(tbInfo)
	local nInfoNum = Lib:CountTB(tbInfo or {});
	if (nInfoNum ~= self.MAX_CARD_NUM) then
		return "球队数量不对";
	end
	
	-- 根据各个球队的成绩计算相应卡片的价值量
	local tbCardValue = {};
	local tbTeamLevel = {};
	
	for i = 1, self.MAX_CARD_NUM do
		local nLevel = tonumber(tbInfo[i]) or self.tbTeamLevel[i] or self.LEVEL_GROUP_MATCH;
		if (nLevel < self.LEVEL_GROUP_MATCH or nLevel > self.LEVEL_CHAMPION) then
			return "球队等级只能在1到7之间";
		end
		local nScore = self.Score_Level[nLevel] or 1;
		tbCardValue[i] = nScore;
		tbTeamLevel[i] = nLevel;
	end
	
	-- 这个table需要存到globalbuff当中，下次启动的时候读取
	self.tbCardValue = tbCardValue;
	self.tbTeamLevel = tbTeamLevel;
	self:UpdateRank_GC();
	
	GlobalExcute({"SpecialEvent.tbWroldCup:SetCardValue_GS", tbCardValue});
	GlobalExcute({"SpecialEvent.tbWroldCup:SetTeamLevel_GS", tbTeamLevel});
	GlobalExcute({"SpecialEvent.tbWroldCup:UpdateRank_GS", tbTeamLevel});
end

function tbEvent:UpdateRank_GC()
	self.bNeecReCalcValue = 1;
	self:UpdateRank();
end

-- 把排名信息同步给gameserver
function tbEvent:Sync2GS_RankInfo(nConnectId)
	for nRank, tbInfo in pairs(self.tbRankInfo) do
		if not nConnectId then
			GlobalExcute({"SpecialEvent.tbWroldCup:Sync2GS_RankInfo_GS", nRank, tbInfo});
		else
			GSExcute(nConnectId, {"SpecialEvent.tbWroldCup:Sync2GS_RankInfo_GS", nRank, tbInfo});
		end
	end
end

function tbEvent:SyncMyRankInfo_GC(tbMyRankInfo)
	if (not tbMyRankInfo) then
		return;
	end
	if (not self.nTimerId or self.nTimerId == 0) then
		self.nTimerId = Timer:Register(60 * Env.GAME_FPS, self.Timer_UpdateRank_GC, self)
	end
	self.tbNewRankInfo = self.tbNewRankInfo or {};
	table.insert(self.tbNewRankInfo, tbMyRankInfo);
	GlobalExcute({"SpecialEvent.tbWroldCup:SyncMyRankInfo_GS", tbMyRankInfo});
end

function tbEvent:Timer_UpdateRank_GC()
	if (not self.nTimerId or self.nTimerId == 0) then
		return;
	end
	
	self:UpdateRank(self.tbNewRankInfo);
	self:Timer_SyncNewRankInfo2GS();
	GlobalExcute({"SpecialEvent.tbWroldCup:Timer_UpdateRank_GS"});
	self.tbNewRankInfo = {};
	Timer:Close(self.nTimerId);
	self.nTimerId = 0;
	return 0;
end

function tbEvent:Timer_SyncNewRankInfo2GS()
	for _, tbInfo in pairs(self.tbNewRankInfo) do
		GlobalExcute({"SpecialEvent.tbWroldCup:Timer_SyncNewRankInfo_GS", tbInfo});
	end
end

-- GC关闭事件
function SpecialEvent:SaveInfo_WorldCup()
	if tonumber(os.date("%Y%m%d", GetTime())) >= SpecialEvent.tbWroldCup.TIME_END_SCORE_CLS then
		return 0;
	end	
	SpecialEvent.tbWroldCup:Timer_UpdateRank_GC();
	SpecialEvent.tbWroldCup.tbRankInfo = SpecialEvent.tbWroldCup.tbRankInfo or {};
	SpecialEvent.tbWroldCup.tbCardValue = SpecialEvent.tbWroldCup.tbCardValue or {};
	SpecialEvent.tbWroldCup.tbTeamLevel = SpecialEvent.tbWroldCup.tbTeamLevel or {};
	local tbSave = {};
	tbSave.tbRankInfo = SpecialEvent.tbWroldCup.tbRankInfo;
	tbSave.tbCardValue = SpecialEvent.tbWroldCup.tbCardValue;
	tbSave.tbTeamLevel = SpecialEvent.tbWroldCup.tbTeamLevel;
	SetGblIntBuf(GBLINTBUF_WORLDCUP, 0, 0, tbSave);
end

-- GC启动事件
function SpecialEvent:LoadInfo_WorldCup()
	if tonumber(os.date("%Y%m%d", GetTime())) >= SpecialEvent.tbWroldCup.TIME_END_SCORE_CLS then
		SetGblIntBuf(GBLINTBUF_WORLDCUP, 0, 0, {});
		return 0;
	end
	local tbLoad = GetGblIntBuf(GBLINTBUF_WORLDCUP, 0) or {};

	if (tbLoad.tbRankInfo) then
		SpecialEvent.tbWroldCup.tbRankInfo = tbLoad.tbRankInfo;
	end
	if (tbLoad.tbCardValue) then
		SpecialEvent.tbWroldCup.tbCardValue = tbLoad.tbCardValue;
	end
	if (tbLoad.tbTeamLevel) then
		SpecialEvent.tbWroldCup.tbTeamLevel = tbLoad.tbTeamLevel;
	end
end

function SpecialEvent:SyncInfo_WorldCup(nConnectId)
	GSExcute(nConnectId, {"SpecialEvent.tbWroldCup:SetCardValue_GS", SpecialEvent.tbWroldCup.tbCardValue});
	GSExcute(nConnectId, {"SpecialEvent.tbWroldCup:SetTeamLevel_GS", SpecialEvent.tbWroldCup.tbTeamLevel});
	SpecialEvent.tbWroldCup:Sync2GS_RankInfo(nConnectId);
end

GCEvent:RegisterGCServerShutDownFunc(SpecialEvent.SaveInfo_WorldCup, SpecialEvent);
GCEvent:RegisterGCServerStartFunc(SpecialEvent.LoadInfo_WorldCup, SpecialEvent);
GCEvent:RegisterGS2GCServerStartFunc(SpecialEvent.SyncInfo_WorldCup, SpecialEvent);
