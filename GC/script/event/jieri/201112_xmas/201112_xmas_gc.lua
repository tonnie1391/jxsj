-- 文件名　：201112_xmas_gc.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-11-29 15:23:37
-- 描述：2011圣诞gc

if not MODULE_GC_SERVER then
	return;
end

Require("\\script\\event\\jieri\\201112_xmas\\201112_xmas_def.lua");

SpecialEvent.Xmas2011 =  SpecialEvent.Xmas2011 or {};
local Xmas2011 = SpecialEvent.Xmas2011;

local BEGIN_CITY_WALK_DAY_STATE = 1;
local BEGIN_CITY_WALK_NIGHT_STATE = 2;
local CHECK_ADD_SNOWMAN = 3;
local CHECK_BGEIN_SNOW = 4;
local CHECK_END_SNOW = 5;	

function Xmas2011:OnXmasInit()
	local nTaskId = KScheduleTask.AddTask("Xmas2011", "SpecialEvent", "OnXmas2011Start");
	KScheduleTask.RegisterTimeTask(nTaskId,self.nNpcBeginWalkTimeDay,BEGIN_CITY_WALK_DAY_STATE);
	KScheduleTask.RegisterTimeTask(nTaskId,self.nNpcBeginWalkTimeNight,BEGIN_CITY_WALK_NIGHT_STATE);
	KScheduleTask.RegisterTimeTask(nTaskId,self.nCheckAddSnowManTime,CHECK_ADD_SNOWMAN);
	KScheduleTask.RegisterTimeTask(nTaskId,self.nBeginSnowTime,CHECK_BGEIN_SNOW);
	KScheduleTask.RegisterTimeTask(nTaskId,self.nEndSnowTime,CHECK_END_SNOW);
end

function SpecialEvent:OnXmas2011Start(nState)
	if nState == BEGIN_CITY_WALK_DAY_STATE or nState == BEGIN_CITY_WALK_NIGHT_STATE then
		Xmas2011:StartWalkAroundCity();	--圣诞老人开始行走城市
	elseif nState == CHECK_ADD_SNOWMAN then
		Xmas2011:AddSnowManAndDecoration();	--加大雪人和装饰
	elseif nState == CHECK_BGEIN_SNOW then
		Xmas2011:ProcessSnowTimer(1);	--开始下雪的计时器
	elseif nState == CHECK_END_SNOW then
		Xmas2011:ProcessSnowTimer(0);	--结束下雪的计时器
	end
end

function Xmas2011:ProcessSnowTimer(nFlag)
	if self:IsEventOpen() ~= 1 then
		return 0;
	end
	GlobalExcute({"SpecialEvent.Xmas2011:ProcessSnowTimer_GS",nFlag});
end


function Xmas2011:AddSnowManAndDecoration()
	if self:IsEventOpen() ~= 1 then
		return 0;
	end
	GlobalExcute({"SpecialEvent.Xmas2011:AddSnowManAndDecoration_GS"});
end


function Xmas2011:StartWalkAroundCity()
	if self:IsEventOpen() ~= 1 then
		return 0;
	end
	GlobalExcute({"SpecialEvent.Xmas2011:StartWalkAroundCity_GS"});
end


--同步雪城建设的进度
function Xmas2011:OnSyncProduceProcess(nProcess)
	local nCurrentProcess = KGblTask.SCGetDbTaskInt(DBTASK_XMAS_SNOWMAN_PROCESS) or 0;
	nCurrentProcess = nCurrentProcess + (nProcess or 0);
	if nCurrentProcess >= self.nFinishProduceNeedMaxCount then
		nCurrentProcess = self.nFinishProduceNeedMaxCount;
	end
	KGblTask.SCSetDbTaskInt(DBTASK_XMAS_SNOWMAN_PROCESS,nCurrentProcess);
end


if tonumber(os.date("%Y%m%d",GetTime())) < Xmas2011.nEventEndTime then
	GCEvent:RegisterGCServerStartFunc(Xmas2011.OnXmasInit,Xmas2011);
end