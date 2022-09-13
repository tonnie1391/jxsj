-- 文件名　：define.lua
-- 创建者　：huangxiaoming
-- 创建时间：2011-05-17 09:46:10
-- 描  述  ：

if not MODULE_GC_SERVER then
	return;
end

Require("\\script\\event\\specialevent\\duanwu2011\\duanwu2011_def.lua");
SpecialEvent.DuanWu2011 = SpecialEvent.DuanWu2011 or {};
local tbDuanWu2011 = SpecialEvent.DuanWu2011 or {};

function tbDuanWu2011:Init()
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	if nDate > self.CLEARBUF_DAY then
		SetGblIntBuf(GBLINTBUF_DUANWU2011, 0, 1, {});	-- 没有用
		return 1;
	end
	if self.IS_OPEN ~= 1 then 
		return 0;
	end
	if nDate < self.OPEN_DAY or nDate > self.RANK_CLOSE_DAY then -- 忠魂积分延迟一天
		return 0;
	end
	self:LoadDataBuf();
	self:UpdateKinMedalsRank();
end

-- 定时刷新鱼
function SpecialEvent:RefreshFish_GC(nSeg)
	if tbDuanWu2011:CheckOpen() ~= 1 then
		return 0;
	end
	GlobalExcute{"SpecialEvent.DuanWu2011:RefreshNpc"};
	Dialog:GlobalNewsMsg_GC("端午忠魂活动已经开启，贪食的鱼儿出现在新手村和城市河道中，请侠客们速速前往投粽喂食");
	Dialog:GlobalMsg2SubWorld_GC("端午忠魂活动已经开启，贪食的鱼儿出现在新手村和城市河道中，请侠客们速速前往投粽喂食");
end

-- 定时清除鱼
function SpecialEvent:CleanFish_GC(nSeg)
	if tbDuanWu2011:CheckOpen() ~= 1 then
		return 0;
	end
	GlobalExcute{"SpecialEvent.DuanWu2011:CleanAllShoal"};
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	if nDate == tbDuanWu2011.CLOSE_DAY then
		Dialog:GlobalNewsMsg_GC("路漫漫其修远兮，夜深了，鱼儿沉入河底休息，端午鱼群明年再和侠客们见面。");
		Dialog:GlobalMsg2SubWorld_GC("路漫漫其修远兮，夜深了，鱼儿沉入河底休息，端午鱼群明年再和侠客们见面。");
	else
		Dialog:GlobalNewsMsg_GC("路漫漫其修远兮，夜深了，鱼儿沉入河底休息，端午鱼群明早再和侠客们见面。");
		Dialog:GlobalMsg2SubWorld_GC("路漫漫其修远兮，夜深了，鱼儿沉入河底休息，端午鱼群明早再和侠客们见面。");
	end
end

-- 每天12点更新
function SpecialEvent:UpdateDuanWuGame_GC(nSeg)
	if tbDuanWu2011.IS_OPEN ~= 1 then 
		return 0;
	end
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	if nDate < tbDuanWu2011.OPEN_DAY or nDate > tbDuanWu2011.RANK_CLOSE_DAY  then
		return 0;
	end
	if nDate == tbDuanWu2011.OPEN_DAY or not tbDuanWu2011.nDataVer then -- 第一天开启活动
		tbDuanWu2011:LoadDataBuf();
	end
	tbDuanWu2011:UpdateKinMedalsRank();
end

-- 更新家族排名积分
function tbDuanWu2011:UpdateKinMedalsRank()
	local nDay = Lib:GetLocalDay(GetTime());--tonumber(GetLocalDate("%Y%m%d"));
	if self.nDataVer < nDay then
		local nPreVer = self.nDataVer;
		self.nDataVer = nDay;
		self.tbYestodayRank = {};
		if nPreVer == nDay - 1 then
			for nRank, tbTemp in ipairs(self.tbTodayRank) do
				if nRank > self.MAX_AWARD_RANK then
					break;
				end
				self.tbYestodayRank[nRank] = {};
				self.tbYestodayRank[nRank][1] = tbTemp[1];
				self.tbYestodayRank[nRank][2] = tbTemp[2];
			end
		end
		self.tbTodayRank = {};
		self.tbKinId2Rank = {};
		self.tbAwardRecord = {};
		self:SaveMedalsRank_GC();
		GlobalExcute{"SpecialEvent.DuanWu2011:LoadDataBuf"};
	end
end

-- 增加端午积分
function tbDuanWu2011:AddMedals_GC(nKinId, nPoint, nPlayerId)
	self:AddMedalsPoint(nKinId, nPoint);
	GlobalExcute{"SpecialEvent.DuanWu2011:AddMedalsPoint", nKinId, nPoint};
end

-- 存盘
function tbDuanWu2011:SaveMedalsRank_GC()
	local tbData = {};
	tbData.nDataVer = self.nDataVer;
	tbData.tbTodayRank = self.tbTodayRank;
	tbData.tbYestodayRank = self.tbYestodayRank;
	tbData.tbAwardRecord = self.tbAwardRecord;
	SetGblIntBuf(GBLINTBUF_DUANWU2011, 0, 1, tbData);
end

-- 领取忠魂袋
function tbDuanWu2011:GetMedalsAward_GC(nKinId, nMemberId, nPlayerId)
	if Kin:CheckSelfRight(nKinId, nMemberId, 2) ~= 1 then
		GlobalExcute{ "SpecialEvent.DuanWu2011:GetMedalsAward_GS2", -1, nKinId, nMemberId, nPlayerId};
		return 0;
	end
	for i = 1, self.MAX_AWARD_RANK do
		if self.tbYestodayRank[i] and self.tbYestodayRank[i][1] == nKinId and not self.tbAwardRecord[nKinId] then
			self.tbAwardRecord[nKinId] = 1;
			GlobalExcute{ "SpecialEvent.DuanWu2011:GetMedalsAward_GS2", 1, nKinId, nMemberId, nPlayerId};
			return 1;
		end
	end
	GlobalExcute{ "SpecialEvent.DuanWu2011:GetMedalsAward_GS2", -1, nKinId, nMemberId, nPlayerId};
	return 0;
end

function tbDuanWu2011:OnRecConnectEvent(nConnectId)
	if self.IS_OPEN ~= 1 then 
		return 0;
	end
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	if nDate < self.OPEN_DAY or nDate > self.RANK_CLOSE_DAY then -- 忠魂积分延迟一天
		return 0;
	end
	self:SaveMedalsRank_GC();
	GSExcute(nConnectId, {"SpecialEvent.DuanWu2011:LoadDataBuf"});
end


GCEvent:RegisterGCServerStartFunc(SpecialEvent.DuanWu2011.Init, SpecialEvent.DuanWu2011);
GCEvent:RegisterGCServerShutDownFunc(SpecialEvent.DuanWu2011.SaveMedalsRank_GC, SpecialEvent.DuanWu2011);

GCEvent:RegisterGS2GCServerStartFunc(SpecialEvent.DuanWu2011.OnRecConnectEvent, SpecialEvent.DuanWu2011);