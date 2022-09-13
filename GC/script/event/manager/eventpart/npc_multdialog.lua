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
EventManager.EventKind.Module.npc_multdialog = EventKind;

function EventKind:OnDialog(szMsgFlag)
	if not szMsgFlag then
		 
		local szMsg 	= EventManager.tbFun:SplitStr(EventManager.tbFun:GetParam(self.tbEventPart.tbParam, "SetLayer1Msg")[1] or "你好，有什么需要帮忙吗？")[1];
		local tbSelect 	= EventManager.tbFun:GetParam(self.tbEventPart.tbParam, "SetLayer2Msg");
		
		local tbOpt = {};
		for nId, szSelect in ipairs(tbSelect) do
			local tbParam = EventManager.tbFun:SplitStr(szSelect);
			table.insert(tbOpt, {EventManager.tbFun:StrVal(tbParam[1]), self.OnDialog, self, tbParam[2] or "你好，有什么需要帮忙吗？"});
		end
		table.insert(tbOpt, {"结束对话"});
		Dialog:Say(EventManager.tbFun:StrVal(szMsg), tbOpt);
		return 0;
	end
	Dialog:Say(szMsgFlag);
	return 0;
end

