
do return end

Require("\\script\\event\\manager\\define.lua");

local EventKind = {};
EventManager.EventKind.Double.TuoGuan = EventKind;

function EventKind:ExeStartFun()
	--Ö´ÐÐË«±¶£»
	--local szMsg = self.tbEventPart.szName .. "Ë«±¶Æô¶¯";
	--KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, szMsg);
	return 0;
end

function EventKind:ExeEndFun()
	--½áÊøË«±¶;
	--local szMsg = self.tbEventPart.szName.."Ë«±¶½áÊø";
	--KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, szMsg);
	return 0;
end