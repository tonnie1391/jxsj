Require("\\script\\event\\manager\\define.lua");

local EventKind = {};
EventManager.EventKind.Module.boss_dropitem = EventKind;

function EventKind:ExeStartFun()
	return EventManager.EventKind.Module.default.ExeStartFun(self);
end

function EventKind:ExeEndFun()
	return EventManager.EventKind.Module.default.ExeEndFun(self);
end
