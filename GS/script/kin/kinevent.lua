-------------------------------------------------------------------
--File: kinevent.lua
--Author: lbh
--Date: 2007-7-9 18:02
--Describe: 游戏流程事件的家族事务（启动，退出， 日常活动等）
-------------------------------------------------------------------
if not Kin then --调试需要
	Kin = {}
	print(GetLocalDate("%Y/%m/%d/%H/%M/%S").." build ok ..")
end

Kin.nTime_BuildFlagNotice = 10;

--启动，家族初始化
function Kin:Init()
	if MODULE_GAMESERVER then
		return self:Init_GS()
	elseif MODULE_GC_SERVER then
		return self:Init_GC()
	end
end

--退出，反初始化
function Kin:UnInit()
	if MODULE_GAMESERVER then
		return self:UnInit_GS()
	elseif MODULE_GC_SERVER then
		return self:UnInit_GC()
	end
end


if MODULE_GC_SERVER then
----------------------------------------------------------------------
function Kin:Init_GC()
	local itor = KKin.GetKinItor()
	if not itor then
		return 0
	end
	local nKinId = itor.GetCurKinId()
end

function Kin:UnInit_GC()

end

-- 家族活动处理

-- 家族活动开始
function Kin:KinEventsStart()	
	--以第一个注册触发事件
	local nTaskId = KScheduleTask.AddTask("家族插旗活动", "Kin", "SechTaskStartBuildFlagTimer");
	assert(nTaskId > 0);
	KScheduleTask.RegisterTimeTask(nTaskId, 1859, 1);
	
	--如果已经过了触发时间，手动触发一次
	if tonumber(os.date("%H%M", GetTime())) > 1859 then
		Kin:SechTaskStartBuildFlagTimer();
	end
	
end

function Kin:SechTaskStartBuildFlagTimer()
	Kin:GetKinBuildFlagTime();
	if #self.BuildFlagTimeKinListIndex <= 0 then
		return 0;
	end
	
	if self.nBuildFlagTimerId and self.nBuildFlagTimerId > 0 then
		--防止重复timer启动
		Timer:Close(self.nBuildFlagTimerId);
		self.nBuildFlagTimerId = 0;
	end
	
	local nCanUseIndex = 0;
	local nCanUseTime = 0;
	local nNowTime = GetTime();
	local nNowHour = tonumber(os.date("%H", nNowTime));
	local nNowMin = tonumber(os.date("%M", nNowTime));
	local nNowTimeMin = nNowHour * 60 + nNowMin;
	
	for nIndex, nTime in ipairs(self.BuildFlagTimeKinListIndex) do
		local nBeginTime = self.nTime_BuildFlagNotice * 3;
		if nNowTimeMin <= (nTime - nBeginTime - 1) then
			nCanUseIndex = nIndex;
			nCanUseTime = (nTime - nBeginTime - nNowTimeMin);
			break;
		end
	end
	
	--没有符合的时间点
	if nCanUseIndex == 0 then
		return 0;
	end
	print("[GCINFO] SechTaskStartBuildFlagTimer begin waiting build!", nCanUseTime, nCanUseIndex)
	self.nBuildFlagTimerIndex = nCanUseIndex;
	if nCanUseTime <= 0 then
		nCanUseTime = 1; --保证不为0；
	end
	self.nBuildFlagTimerId = Timer:Register(nCanUseTime * 60*18, self.KinEventsStartBuildFlagTimer, self);
end

function Kin:KinEventsStartBuildFlagTimer()
	local nOpenTime = self.BuildFlagTimeKinListIndex[self.nBuildFlagTimerIndex];
	if not nOpenTime then
		return 0;
	end
	local tbKinList = self.tbBuildFlagTime[nOpenTime];
	if not tbKinList then
		return 0;
	end
	--每10分钟公告一次，共3次
	local tbKinBuildInfo = {};
	
	tbKinBuildInfo.tbKinList = tbKinList;
	tbKinBuildInfo.nKinBuildFlagStep = 1;

	Kin:EventAction_BuildFlag(tbKinBuildInfo);

	self.nBuildFlagTimerIndex = self.nBuildFlagTimerIndex + 1;
	local nNextOpenTime = self.BuildFlagTimeKinListIndex[self.nBuildFlagTimerIndex];
	if not nNextOpenTime then
		return 0;
	end
	return (nNextOpenTime - nOpenTime) * 60 * 18;
end

-- 家族活动:家族插旗
function Kin:EventAction_BuildFlag(tbKinBuildInfo)
	if (not tbKinBuildInfo.nKinBuildFlagStep) then
		return 0;
	end
	if tbKinBuildInfo.nKinBuildFlagStep == 1 then
		--第一步触发后续Timer
		Timer:Register(self.nTime_BuildFlagNotice*60*18, self.EventAction_BuildFlag, self, tbKinBuildInfo);
	end	
	
	--公告
	if tbKinBuildInfo.nKinBuildFlagStep <= 3 then
		for _, nKinId in ipairs(tbKinBuildInfo.tbKinList) do
			Kin:KinBuildFlagNotice(nKinId);
		end
	end
	
	--执行插旗
	if tbKinBuildInfo.nKinBuildFlagStep > 3 then
		print("[GCINFO] EventAction_BuildFlag begin build flag!");
		for _, nKinId in ipairs(tbKinBuildInfo.tbKinList) do
			Kin:KinBuildFlagNow(nKinId)
		end
		return 0;
	end
	tbKinBuildInfo.nKinBuildFlagStep = tbKinBuildInfo.nKinBuildFlagStep + 1;
	return self.nTime_BuildFlagNotice*60*18;
end

function Kin:KinBuildFlagNotice(nKinId)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then 
		return 0;
	end
	local nOrderTime = cKin.GetKinBuildFlagOrderTime();
	local nPreDay = cKin.GetTogetherTime();
	local nTime = GetTime();
	local nNowDay = tonumber(os.date("%m%d", nTime));
	local nNowHour = tonumber(os.date("%H", nTime));
	local nNowMin = tonumber(os.date("%M", nTime));
	local nNowTime = nNowHour * 60 + nNowMin;	

	if nOrderTime == 0 then
		return 0;
	end	
	if nPreDay ~= nNowDay then
		GlobalExcute{"Kin:NoticeKinBuildFlag_GS2", nKinId, nOrderTime - nNowTime};
	end
end

function Kin:KinBuildFlagNow(nKinId)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then 
		return 0;
	end
	local nOrderTime = cKin.GetKinBuildFlagOrderTime();
	local nPreDay = cKin.GetTogetherTime();
	local nTime = GetTime();
	local nNowDay = tonumber(os.date("%m%d", nTime));
	local nNowHour = tonumber(os.date("%H", nTime));
	local nNowMin = tonumber(os.date("%M", nTime));
	local nNowTime = nNowHour * 60 + nNowMin;	

	if nOrderTime == 0 then
		return 0;
	end	
	if nPreDay ~= nNowDay then
		cKin.SetTogetherTime(nNowDay);
		GlobalExcute{"Kin:KinBuildFlag_GS2", nKinId};
	end
end

local function OnSort(tbA, tbB)
	return tbA < tbB;
end


function Kin:GetKinBuildFlagTime()
	self.BuildFlagTimeKinListIndex = {};
	self.tbBuildFlagTime = {};
	local PerKinEvents_cNextKin, PerKinEvents_nNextKin = KKin.GetFirstKin();
	if not PerKinEvents_nNextKin then
		return;
	end
	local nTime = GetLocalDate("%Y-%m-%d-%H:%M");
	local nCount = 0;
	local pKin = KKin.GetKin(PerKinEvents_nNextKin);
	while(pKin) do
		if nCount > 50000 then
			break;
			--防止死循环，允许最多5万个家族
		end
		local nOrderTime = pKin.GetKinBuildFlagOrderTime();
		local nPreDay = pKin.GetTogetherTime();
		
		if (not self.tbBuildFlagTime) then
			self.tbBuildFlagTime = {};
		end
		
		if not self.tbBuildFlagTime[nOrderTime] then
			table.insert(self.BuildFlagTimeKinListIndex, nOrderTime);
			self.tbBuildFlagTime[nOrderTime] = {};
			--self.BuildFlagTimeKinListIndex[nOrderTime] = 1
		end
		table.insert(self.tbBuildFlagTime[nOrderTime], PerKinEvents_nNextKin);
		
		nCount = nCount + 1;
		PerKinEvents_cNextKin, PerKinEvents_nNextKin = KKin.GetNextKin(PerKinEvents_nNextKin);
		if not PerKinEvents_nNextKin then
			pKin = nil;
			break;
		end
		pKin = KKin.GetKin(PerKinEvents_nNextKin);
	end
	
	table.sort(self.BuildFlagTimeKinListIndex, OnSort);
end

-- 家族活动:家族关卡
--function Kin:EventAction_KinGame(nKinId)
--	print("检测家族关卡时间");
--	local cKin = KKin.GetKin(nKinId);
--	local tbOrderTime = {};
--	tbOrderTime[1] = cKin.GetKinGameOrderTime1();
--	tbOrderTime[2] = cKin.GetKinGameOrderTime2();
--	tbOrderTime[3] = cKin.GetKinGameOrderTime3();
	
--	local nPreTime = cKin.GetKinGameTime();
	
--	for n = 1, #tbTime do
--		if os.date("%w", tbOrderTime[n]) == os.date("%w", GetTime()) then
--			if os.date("%X", tbOrderTime[n]) >= os.date("%X", GetTime()) and 
--			   os.date("%W%w", nPreTime) ~= os.date("%W%w", GetTime()) then
--				cKin:SetKinGameTime(tbOrderTime[n]);
--				GlobalExcute{"KinGame:ApplyKinGame", nKinId, cKin.GetKinGameOrderMapId()};
				--GCExcute{"KinGame:ApplyKinGame_GC", nKinId, nMemberId, him.nMapId, me.nId};
--			end
--		end
--	end
--end
	
function Kin:WriteLogKinInfo()
	local szOutFile = "\\playerladder\\kin_info.txt";
	KFile.WriteFile(szOutFile, "");
	self:WriteLogKinInfoEx(KKin.GetFirstKin());	
end
	
function Kin:WriteLogKinInfoEx(PerKinEvents_cNextKin, PerKinEvents_nNextKin)
	local szOutFile = "\\playerladder\\kin_info.txt";
	if not PerKinEvents_nNextKin then
		return;
	end
	local nTime = GetLocalDate("%Y-%m-%d-%H:%M");
	local nCount = 0;
	local pKin = KKin.GetKin(PerKinEvents_nNextKin);
	while(pKin) do
		if nCount > 50000 then
			break;
			--防止死循环，允许最多5万个家族
		end
		local nRegular, nSigned, nRetire, nCaptain, nAssistant	= pKin.GetMemberCount();
		local pTong = KTong.GetTong(pKin.GetBelongTong());
		local tbText	= {
			{"家族名", pKin.GetName()},
			{"所属帮会", (pTong and pTong.GetName()) or "nil"},
			{"族长", pKin.GetMemberName(pKin.GetCaptain() or 0)},			
			{"创建时间", os.date("%Y-%m-%d %H:%M:%S", pKin.GetCreateTime())},			
			{"正式成员数", nRegular},
			{"记名成员数", nSigned},
			{"荣誉成员数", nRetire},
			{"家族总威望", pKin.GetTotalRepute()},
			{"家族ID",	PerKinEvents_nNextKin or 0},
			{"帮会ID",	pKin.GetBelongTong() or 0},
		};
		local szMsg = "【Kin】家族信息：";
		for _, tb in ipairs(tbText) do
			szMsg	= szMsg .. "\t" .. tb[1] .. ":" .. tostring(tb[2]);
		end
		szMsg = szMsg.."\n";		
		KFile.AppendFile(szOutFile, szMsg);
		nCount = nCount + 1;
		PerKinEvents_cNextKin, PerKinEvents_nNextKin = KKin.GetNextKin(PerKinEvents_nNextKin);
		if not PerKinEvents_nNextKin then
			pKin = nil;
			break;
		end
		pKin = KKin.GetKin(PerKinEvents_nNextKin);
	end
	KFile.AppendFile(szOutFile, string.format("当前服务器总家族数;%s\t%s\n",self.nCount or 0, nTime));
end

-- 在GC开始时调用的函数RegisterGCServerStartFunc里注册家族活动开始函数
GCEvent:RegisterGCServerStartFunc(Kin.KinEventsStart, Kin);
GCEvent:RegisterGCServerStartFunc(Kin.WriteLogKinInfo, Kin);
GCEvent:RegisterGCServerShutDownFunc(Kin.WriteLogKinInfo, Kin);
----------------------------------------------------------------------
end


if MODULE_GAMESERVER then
----------------------------------------------------------------------
function Kin:Init_GS()

end

function Kin:UnInit_GS()
	--同步缓存的总江湖威望价值量
	for nKinId, aKinData in pairs(self.aKinData) do
		if aKinData.nTotalReputeValue > self.CONF_VALUE2REPUTE then
			KKin.ApplyAddKinTask(nKinId, 6, math.floor(aKinData.nTotalReputeValue / self.CONF_VALUE2REPUTE))
		end
	end
end

----------------------------------------------------------------------
end
