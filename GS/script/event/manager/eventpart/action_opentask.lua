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
EventManager.EventKind.Module.action_opentask = EventKind;


function EventKind:ExeStartFun()
	local nFlag, szMsg = EventManager.tbFun:ExeParamWithOutPlayer(self.tbEventPart.tbParam);
	if nFlag and nFlag ~= 0 then
		return 0;
	end
end

function EventKind:ExeEndFun()
	local nFlag, szMsg = EventManager.tbFun:ExeParamCloseEvent(self.tbEventPart.tbParam);
	if nFlag and nFlag ~= 0 then
		return 0;
	end	
	return 0;
end
