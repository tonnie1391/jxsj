-- 文件名　：201108_tanabata_gc.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-07-20 20:04:59
-- 描述：11七夕gc

if not MODULE_GC_SERVER then
	return;
end

Require("\\script\\event\\jieri\\201108_Tanabata\\201108_tanabata_def.lua");

SpecialEvent.Tanabata201108 =  SpecialEvent.Tanabata201108 or {};
local Tanabata201108 = SpecialEvent.Tanabata201108;

local TIMER_STATE_CHECK_ADD_XIQUE = 1;	--刷喜鹊state
local TIMER_STATE_ADD_NORMAL_BOSS_01 = 2;	--刷普通boss
local TIMER_STATE_ADD_NORMAL_BOSS_02 = 3;	--刷普通boss
local TIMER_STATE_ADD_BIG_BOSS = 4;			--刷最终boss
local TIMER_STATE_ADD_NORMAL_BOSS_03 = 5;	--刷普通boss



--是否开启活动
function Tanabata201108:CheckEventOpen()
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	if nNowDate >= self.nStartDay and nNowDate <= self.nEndDay then
		return 1;
	end
	return 0;	
end


--初始化
function Tanabata201108:Init()
	local nNowTime = tonumber(GetLocalDate("%Y%m%d"));
	if nNowTime > self.nEndDay then
		return;
	end
	local nTaskId = KScheduleTask.AddTask("Tanabata201108", "SpecialEvent", "OnStart_Tanabata201108");
	KScheduleTask.RegisterTimeTask(nTaskId, Tanabata201108.nCheckXiqueTime, TIMER_STATE_CHECK_ADD_XIQUE);
	KScheduleTask.RegisterTimeTask(nTaskId, Tanabata201108.nAddNormalBossTime01, TIMER_STATE_ADD_NORMAL_BOSS_01);
	KScheduleTask.RegisterTimeTask(nTaskId, Tanabata201108.nAddNormalBossTime02, TIMER_STATE_ADD_NORMAL_BOSS_02);
	KScheduleTask.RegisterTimeTask(nTaskId, Tanabata201108.nAddBigBossTime, TIMER_STATE_ADD_BIG_BOSS);
	KScheduleTask.RegisterTimeTask(nTaskId, Tanabata201108.nAddNormalBossTime03, TIMER_STATE_ADD_NORMAL_BOSS_03);
end


function SpecialEvent:OnStart_Tanabata201108(nState)
	if nState == TIMER_STATE_CHECK_ADD_XIQUE then
		Tanabata201108:AddXique_GC();
	elseif nState == TIMER_STATE_ADD_NORMAL_BOSS_01 or 
		nState == TIMER_STATE_ADD_NORMAL_BOSS_02 or 
		nState == TIMER_STATE_ADD_NORMAL_BOSS_03 then
		Tanabata201108:AddWorldNormalBoss_GC();
	elseif nState == TIMER_STATE_ADD_BIG_BOSS then
		Tanabata201108:AddWorldBigBoss_GC();
	end
end

--每日00:00检测喜鹊
function Tanabata201108:AddXique_GC()
	if self:CheckEventOpen() == 1 then
		GlobalExcute({"SpecialEvent.Tanabata201108:AddXiQue"});
	else
		GlobalExcute({"SpecialEvent.Tanabata201108:AddXiQue",1});
	end
end



--刷普通boss
function Tanabata201108:AddWorldNormalBoss_GC()
	if self:CheckEventOpen() == 1 then
		local tbPosInfo = self:GetRandomBossPos(1);
		GlobalExcute({"SpecialEvent.Tanabata201108:AddWorldNormalBoss_GS",tbPosInfo});
	end
end

--刷大boss
function Tanabata201108:AddWorldBigBoss_GC()
	if self:CheckEventOpen() == 1 then
		local tbPosInfo = self:GetRandomBossPos(2);
		GlobalExcute({"SpecialEvent.Tanabata201108:AddWorldBigBoss_GS",tbPosInfo});
	end
end
	
	
--获取随机的刷boss点
function Tanabata201108:GetRandomBossPos(nBossType)
	local tbPosInfo = {};
	local tbSelect = {};
	local nCount = 0;
	if nBossType == 1 then
		tbSelect = Tanabata201108.tbAddNormalBossPos;
		nCount = Tanabata201108.nAddNormalBossCount;
	elseif nBossType == 2 then
		tbSelect = Tanabata201108.tbAddBigBossPos;
		nCount = Tanabata201108.nAddBigBossCount;
	end
	local tbIndex = {};
	for i = 1 , #tbSelect do
		tbIndex[i] = i;
	end
	for i = 1 , nCount do
		local nPos = MathRandom(#tbIndex);
		local nIndex = tbIndex[nPos];
		local tbInfo = tbSelect[nIndex];
		local tbPos = tbInfo[2][MathRandom(#tbInfo[2])];
		table.insert(tbPosInfo,{tbInfo[1],unpack(tbPos)});
		table.remove(tbIndex,nPos);
	end
	return tbPosInfo;
end
	
	
--产出宝石开关
function Tanabata201108:SetStoneBorn(bBorn)
	if not bBorn or bBorn ~= 1 then
		return 0;
	end
	KGblTask.SCSetDbTaskInt(DBTASK_QX_STONE_BORN,bBorn);
end
	
	
--注册启动回调
if tonumber(GetLocalDate("%Y%m%d")) <= Tanabata201108.nEndDay then
	GCEvent:RegisterGCServerStartFunc(Tanabata201108.Init, Tanabata201108);
end
