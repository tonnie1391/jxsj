-- 文件名　：console_gc.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-04-23 10:04:34
-- 描  述  ：--控制台

if (not MODULE_GC_SERVER) then
	return 0;
end

Console.Base = Console.Base or {};
local tbBase = Console.Base;

function tbBase:StartSignUp()
	if (self.tbTimerList and self.tbTimerList.nReadyId and self.tbTimerList.nReadyId > 0) then
		Timer:Close(self.tbTimerList.nReadyId);
		self.tbTimerList.nReadyId = nil;
	end	
	
	self:Init();
	local nDegree = self.nDegree;
	self.nState 	  = 1;
	
	self.tbTimerList.nReadyId = Timer:Register(self.tbCfg.nReadyTime, self.OnStartMission, self)
	GlobalExcute{"Console:StartSignUp", nDegree};
end

function tbBase:ApplySignUp(tbPlayerList)
	local nAttendMap = 0;
	for nMapId, tbGroup in pairs(self.tbGroupLists) do
		if tbGroup.nPlayerMax + #tbPlayerList <= self.DEF_PLAYER_MAX then
			nAttendMap = nMapId;
			break;
		end
	end
	if nAttendMap == 0 then
		GlobalExcute{"Console:SignUpFail", tbPlayerList};
		return 0;
	end
	
	self:JoinGroupList(nAttendMap, tbPlayerList);
	GlobalExcute{"Console:JoinGroupList", nAttendMap, tbPlayerList};
	GlobalExcute{"Console:SignUpSucess", nAttendMap, tbPlayerList};
end

function tbBase:GetPlayerData(nMapId, nId)
	return self.tbPlayerData[nMapId][nId];
end

function tbBase:OnStartMission()
	local nDegree = self.nDegree;
	self.nState 	  = 2;
	self.tbTimerList.nReadyId = nil;
	GlobalExcute{"Console:OnStartMission", nDegree};
	return 0;
end

function tbBase:RegisterScheduleTask()
end
