-------------------------------------------------------
-- 文件名　：domaintask_gc.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-06-18 06:46:54
-- 文件描述：
-------------------------------------------------------

Require("\\script\\domainbattle\\task\\domaintask_def.lua");

if (not MODULE_GC_SERVER) then
	return 0;
end

local tbDomainTask = Domain.DomainTask;

-- tasklist
function Domain:AddDefender_Normal_GC()
	
	local tbMap = 
	{
		[1] = 1,
		[2] = 1,
		[3] = 1,
		[4] = 1,
		[5] = 1,
	};
	
	local nDay = tonumber(os.date("%w", GetTime()));

	if not tbMap[nDay] then
		return;
	end
	
	GlobalExcute({"Domain.DomainTask:AddDefender_GS"});
end

function Domain:AddDefender_Weekend_GC()
	
	local tbMap = 
	{
		[0] = 1,
		[6] = 1, 
	};
	
	local nDay = tonumber(os.date("%w", GetTime()));
	
	if not tbMap[nDay] then
		return;
	end

	GlobalExcute({"Domain.DomainTask:AddDefender_GS"});
end

-- clear npc
function Domain:ClearDefender_Normal_GC()
	GlobalExcute({"Domain.DomainTask:ClearDefender_GS"});
end

function Domain:ClearDefender_Weekend_GC()
	GlobalExcute({"Domain.DomainTask:ClearDefender_GS"});
end

-- update labber
function Domain:RefreshKaimenHonor()
	
	local nStep = KGblTask.SCGetDbTaskInt(DBTASK_DOMAIN_BATTLE_STEP);
	if nStep == 2 then
		PlayerHonor:OnSchemeUpdateKaimenTaskHonorLadder();
		GlobalExcute{"Ladder:RefreshLadderName"};
	end
end

function Domain:CheckDomainTask_GC()
		
	-- domainbattle times
	local nDomainTimes = KGblTask.SCGetDbTaskInt(DBTASK_DOMAIN_BATTLE_NO);
	
	-- task start time
	local nDomainOpenTime = KGblTask.SCGetDbTaskInt(DBTASK_DOMAINTASK_OPENTIME);
	
	-- not set
	if nDomainOpenTime == 0 then
		
		local nNowDate = tonumber(GetLocalDate("%Y%m%d%H%M"));
		
		if nDomainTimes >= 20 and nNowDate > Domain.DomainTask.START_TIME then
			
			-- set start time
			KGblTask.SCSetDbTaskInt(DBTASK_DOMAINTASK_OPENTIME, GetTime());
				
			-- set domainbattle step
			local nStep = KGblTask.SCGetDbTaskInt(DBTASK_DOMAIN_BATTLE_STEP);
			
			if nStep < 2 then
				KGblTask.SCSetDbTaskInt(DBTASK_DOMAIN_BATTLE_STEP, 2);
			end	
		end
	else
		-- get time
		local nNowTime	= GetTime();
		local nNowDay	= Lib:GetLocalDay(nNowTime);
		local nLastDay	= Lib:GetLocalDay(nDomainOpenTime);
		local nDetDay	= nNowDay - nLastDay;
		
		-- cozone time
		local nExtraTime	= 0;
		local nCozoneTime	= KGblTask.SCGetDbTaskInt(DBTASK_COZONE_TIME);
		local nVailDay		= math.floor(Domain.DomainTask.VAILD_OPEN_TIME / (3600 * 24));
		local nCozoneDay	= Lib:GetLocalDay(nCozoneTime);
		if nCozoneTime > nDomainOpenTime and nCozoneDay < nLastDay + nVailDay then
			nExtraTime = math.floor(Domain.DomainTask.EXTRA_COZONE_TIME / (3600 * 24));
		end

		-- need set
		if nDetDay >= nVailDay + nExtraTime then
			
			local nStep = KGblTask.SCGetDbTaskInt(DBTASK_DOMAIN_BATTLE_STEP);

			if nStep < 3 then
				KGblTask.SCSetDbTaskInt(DBTASK_DOMAIN_BATTLE_STEP, 3);
				PlayerHonor:OnSchemeUpdateKaimenTaskHonorLadder();
				Domain:GetTongAward_GC();
			end
		end
	end
end

function Domain:StartEvent_Task()
	local nTime = tonumber(GetLocalDate("%H%M"));
	if nTime >= 2300 then
		Domain:CheckDomainTask_GC();
	end
end

GCEvent:RegisterGCServerStartFunc(Domain.StartEvent_Task, Domain);
