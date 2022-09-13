do return end

Require("\\script\\event\\manager\\define.lua");

local EventKind = {};
EventManager.EventKind.ExAward.Battle = EventKind;

function EventKind:CreateKind()
	--调用
	EventManager.tbFunction_Base:SetTimerStart(self);
	EventManager.tbFunction_Base:SetTimerEnd(self);
end

function EventKind:ExeStartFun()
	--关于战场相关活动开关开启

	return 0;
end

function EventKind:ExeEndFun()
	--关于战场相关活动开关结束
	return 0;
end
