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
EventManager.EventKind.Module.action_touchtask = EventKind;


function EventKind:ExeStartFun()
	local tbTask = EventManager.tbFun:GetParam(self.tbEventPart.tbParam, "TaskTouch", 1)

	for _, varTask in pairs(tbTask) do
		local tbTask = EventManager.tbFun:SplitStr(varTask);
		local szType = tbTask[1];
		SpecialEvent.ExtendEvent:RegExecute(szType, {EventKind.ExeTaskTouch, self})
	end

	return 0;	

end

function EventKind:ExeEndFun()
	local tbTask = EventManager.tbFun:GetParam(self.tbEventPart.tbParam, "TaskTouch", 1)
	for _, varTask in pairs(tbTask) do
		local tbTask = EventManager.tbFun:SplitStr(varTask);
		local szType = tbTask[1];
		SpecialEvent.ExtendEvent:UnRegExecute(szType, {EventKind.ExeTaskTouch, self});
	end
	
	return 0;
end

function EventKind:ExeTaskTouch(...)
	EventManager:GetLibTable().tbTaskTouchArg = arg;
	local nFlag, szMsg = EventManager.tbFun:CheckParamWithOutPlayer(self.tbEventPart.tbParam);
	if nFlag and nFlag ~= 0 then
		EventManager:GetLibTable().tbTaskTouchArg = nil;
		return 0;
	end
	local nFlag, szMsg = EventManager.tbFun:ExeParamWithOutPlayer(self.tbEventPart.tbParam);
	if nFlag and nFlag ~= 0 then
		if szMsg then
			me.Msg(szMsg);
		end
		EventManager:GetLibTable().tbTaskTouchArg = nil;
		return 0;
	end
	EventManager:GetLibTable().tbTaskTouchArg = nil;
end
