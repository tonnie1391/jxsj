
do return end
Require("\\script\\event\\manager\\define.lua");

local EventKind = {};
EventManager.EventKind.Npc.Announce = EventKind;

function EventKind:ExeStartFun()
	local nFlag, szMsg = EventManager.tbFun:CheckParam(self.tbEventPart.tbParam);
	if nFlag == 1 then
		return 0;
	end
	
	EventManager.tbFun:ExeParam(self.tbEventPart.tbParam);
	return 0;
end

function EventKind:ExeEndFun()
	return 0;
end