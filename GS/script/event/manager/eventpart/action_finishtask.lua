-------------------------------------------------------------------
--File: 	base.lua
--Author: sunduoliang
--Date: 	2008-4-15
--Describe:	活动管理系统
--InterFace1:
--InterFace2:
--InterFace3:
-------------------------------------------------------------------
Require("\\script\\event\\manager\\define.lua");

local EventKind = {};
EventManager.EventKind.Module.action_finishtask = EventKind;


function EventKind:ExeStartFun()
	local tbTask = EventManager.tbFun:GetParam(self.tbEventPart.tbParam, "TaskFinish", 1)

	for _, varTask in pairs(tbTask) do
		local tbTask = EventManager.tbFun:SplitStr(varTask);
		local szType = tbTask[1];
		local nNeedFree = tonumber(tbTask[2]) or 0;
		SpecialEvent.ExtendAward:RegExecute(self.tbEvent.nId, self.tbEventPart.nId, szType, {EventKind.ExeTaskFinish, self}, nNeedFree, {EventKind.ExeTaskCheckFreeCount, self})
	end

	return 0;	

end

function EventKind:ExeEndFun()
	local tbTask = EventManager.tbFun:GetParam(self.tbEventPart.tbParam, "TaskFinish", 1)
	for _, varTask in pairs(tbTask) do
		local tbTask = EventManager.tbFun:SplitStr(varTask);
		local szType = tbTask[1];
		local nNeedFree = tonumber(tbTask[2]) or 0;
		SpecialEvent.ExtendAward:UnRegExecute(self.tbEvent.nId, self.tbEventPart.nId, szType, {EventKind.ExeTaskFinish, self}, nNeedFree, {EventKind.ExeTaskCheckFreeCount, self})
	end
	
	return 0;
end

function EventKind:ExeTaskFinish(pPlayer, ...)
	Setting:SetGlobalObj(pPlayer);
	EventManager:GetLibTable().tbTaskFinishArg = arg;
	local nFlag, szMsg = EventManager.tbFun:CheckParam(self.tbEventPart.tbParam);
	if nFlag and nFlag ~= 0 then
		EventManager:GetLibTable().tbTaskFinishArg = nil;
		Setting:RestoreGlobalObj();
		return 0;
	end
	local nFlag, szMsg = EventManager.tbFun:ExeParam(self.tbEventPart.tbParam);
	if nFlag and nFlag ~= 0 then
		if szMsg then
			me.Msg(szMsg);
		end
		EventManager:GetLibTable().tbTaskFinishArg = nil;
		Setting:RestoreGlobalObj();
		return 0;
	end
	EventManager:GetLibTable().tbTaskFinishArg = nil;
	Setting:RestoreGlobalObj();
end

function EventKind:ExeTaskCheckFreeCount(pPlayer, ...)
	local nFreeCount = 0;
	Setting:SetGlobalObj(pPlayer);
	EventManager:GetLibTable().tbTaskFinishArg = arg;
	local tbTask = EventManager.tbFun:GetParam(self.tbEventPart.tbParam, "TaskFinish", 1)
	for _, varTask in pairs(tbTask) do
		local tbTask = EventManager.tbFun:SplitStr(varTask);
		local szScript = tbTask[3] or "";
		if szScript ~= "" then
			nFreeCount = nFreeCount + EventManager:ExeFun("SetLuaScript", szScript);
		end
	end
	EventManager:GetLibTable().tbTaskFinishArg = nil;
	Setting:RestoreGlobalObj();
	return nFreeCount;
end
