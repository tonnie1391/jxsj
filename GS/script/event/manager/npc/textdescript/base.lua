-------------------------------------------------------------------
--File: 	base.lua
--Author: sunduoliang
--Date: 	2008-4-15
--Describe:	活动管理系统
--InterFace1:
--InterFace2:
--InterFace3:
-------------------------------------------------------------------
do return end
Require("\\script\\event\\manager\\define.lua");

local EventKind = {};
EventManager.EventKind.Npc.TextDescript = EventKind;

function EventKind:OnDialog()
	EventManager.tbFun:ExeParam(self.tbEventPart.tbParam)
	return 0;
end
