-- 文件名  : zhounianqing2011_gc.lua
-- 创建者  : zhongjunqi
-- 创建时间: 2011-06-14 09:52:57
-- 描述    : 三周年庆 佳肴活动

if not MODULE_GC_SERVER then
	return;
end

Require("\\script\\event\\specialevent\\zhounianqing2011\\zhounianqing2011_def.lua");

SpecialEvent.ZhouNianQing2011 = SpecialEvent.ZhouNianQing2011 or {};
local ZhouNianQing2011 = SpecialEvent.ZhouNianQing2011;

-- 定时任务枚举
local TIMER_STATE_BEGIN_JIAYAO = 1;		-- 佳肴开始
local TIMER_STATE_END_JIAYAO = 2;		-- 佳肴结束
local TIMER_STATE_CHECK_ZHUFUSHU = 3;	-- 祝福树刷新
local TIMER_STATE_CHECK_WREATH = 4;		-- 花坛刷新

local TIMER_CHECK_JIAYAO	= 10*60;		-- 佳肴活动的检测时间为10分钟
local JIAYAO_MAX_INTERVAL	= 30*60;		-- 一次刷新出来的桌子，最多30分钟

function ZhouNianQing2011:Init()
	if self.bIsOpen ~= 1 then
		return;
	end
	
	local nNowTime = tonumber(GetLocalDate("%Y%m%d"));
	if nNowTime > self.nHuaTuanJinCuEndTime then
		return;
	end
	self.nLastRefreshTime = 0;			-- 记录最后一次刷新佳肴的时间
	self.nJiaYaoCount = 0;						-- 每天刷新佳肴的计数
	
--	local nTaskId = KScheduleTask.AddTask("ZhouNianQing2011", "SpecialEvent", "ZhouNianQing2011_StartEvent");

--	KScheduleTask.RegisterTimeTask(nTaskId, ZhouNianQing2011.nStartTimePerDay, TIMER_STATE_BEGIN_JIAYAO);
--	KScheduleTask.RegisterTimeTask(nTaskId, ZhouNianQing2011.nEndTimePerDay, TIMER_STATE_END_JIAYAO);
--	KScheduleTask.RegisterTimeTask(nTaskId, ZhouNianQing2011.nZhuFuShuTime, TIMER_STATE_CHECK_ZHUFUSHU);
--	KScheduleTask.RegisterTimeTask(nTaskId, ZhouNianQing2011.nZhuFuShuTime, TIMER_STATE_CHECK_WREATH);
	
	Timer:Register(TIMER_CHECK_JIAYAO * Env.GAME_FPS, self.CheckJiaYao, self);	-- 定时检测是否异常
end

-- 检测是否在佳肴活动时间
function ZhouNianQing2011:CheckJiaYaoTime()
	-- 日期
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	if (nNowDate > self.nEndTime or nNowDate < self.nStartTime) then
		return 0;
	end
	local nNowTime = tonumber(GetLocalDate("%H%M"));
	if (nNowTime > self.nEndTimePerDay or nNowTime < self.nStartTimePerDay) then
		return 0;
	end
	return 1;
end

-- 佳肴检测，用于出现异常的时候，保证活动能够继续进行
function ZhouNianQing2011:CheckJiaYao()
	local nNowTime = GetTime();
	if (nNowTime - self.nLastRefreshTime > JIAYAO_MAX_INTERVAL) then		-- 大于30分钟没有吃完则刷新
		self:RefreshJiaYao();
	end
	return nil;
end

-- 所有菜被吃光了，准备下一桌
function ZhouNianQing2011:AllJiaYaoDeath()
	-- 判断上轮上菜的时间是否够20分钟
	local nNowTime = GetTime();
	if (nNowTime > self.nLastRefreshTime + self.nRefreshMinInterval) then
		return self:RefreshJiaYao();
	else	-- 凑够20分钟刷新
		local nDual = self.nRefreshMinInterval - (nNowTime - self.nLastRefreshTime);
		return Timer:Register(nDual * Env.GAME_FPS, self.RefreshJiaYao, self);
	end
end

-- 刷新佳肴
function ZhouNianQing2011:RefreshJiaYao()
	-- 判断活动是否关闭了
	if (self:CheckJiaYaoTime() == 0) then
		-- 关闭佳肴
		GlobalExcute({"SpecialEvent.ZhouNianQing2011:CloseJiaYao"});		-- 关闭所有桌子
		return 0;
	end
	-- 记录佳肴的开始时间
	self.nLastRefreshTime = GetTime();
	-- 通知GS开始刷桌子
	local nMapId = MathRandom(1, 8);			-- 随机8个新手村
	GlobalExcute({"SpecialEvent.ZhouNianQing2011:RefreshJiaYao", nMapId});		-- 刷新佳肴
	self.nJiaYaoCount = self.nJiaYaoCount + 1;
	if (self.nJiaYaoCount == 1) then			-- 每天第一次
		GlobalExcute({"SpecialEvent.ZhouNianQing2011:Announce", 1});
	else
		GlobalExcute({"SpecialEvent.ZhouNianQing2011:Announce", 2});
	end
	return 0;
end

-- 活动开始和结束
function SpecialEvent:ZhouNianQing2011_StartEvent(nState)
	if (nState == TIMER_STATE_BEGIN_JIAYAO) then
		self.nJiaYaoCount = 0;
		ZhouNianQing2011:RefreshJiaYao();
	elseif (nState == TIMER_STATE_END_JIAYAO) then
		-- 通知GS把所有桌子删除
		GlobalExcute({"SpecialEvent.ZhouNianQing2011:CloseJiaYao"});		-- 关闭所有桌子
	elseif (nState == TIMER_STATE_CHECK_ZHUFUSHU) then
		local nNowTime = tonumber(GetLocalDate("%Y%m%d"));
		if (nNowTime > ZhouNianQing2011.nEndTime) then			-- 活动结束
			-- 通知GS删除祝福树
			GlobalExcute({"SpecialEvent.ZhouNianQing2011:CloseZhuFuShu"});		-- 关闭祝福树
		elseif (nNowTime >= ZhouNianQing2011.nStartTime) then	-- 活动已经开始
			-- 通知GS进行添加树，gc只负责通知，由gs自行决定是否添加（会多次通知，防止GS重启后没有树）
			GlobalExcute({"SpecialEvent.ZhouNianQing2011:OpenZhuFuShu"});		-- 开启祝福树
		end
	elseif (nState == TIMER_STATE_CHECK_WREATH) then		-- 花坛刷新
		local nNowTime = tonumber(GetLocalDate("%Y%m%d"));
		if (nNowTime > ZhouNianQing2011.nHuaTuanJinCuEndTime) then			-- 活动结束
			-- 通知GS删除花坛
			GlobalExcute({"SpecialEvent.ZhouNianQing2011:CloseWreath"});		-- 关闭
		elseif (nNowTime >= ZhouNianQing2011.nHuaTuanJinCuStartTime) then	-- 活动已经开始
			-- 通知GS进行添加树，gc只负责通知，由gs自行决定是否添加（会多次通知，防止GS重启后没有树）
			GlobalExcute({"SpecialEvent.ZhouNianQing2011:OpenWreath"});		-- 开启
		end
	end
end

GCEvent:RegisterGCServerStartFunc(ZhouNianQing2011.Init, ZhouNianQing2011);
