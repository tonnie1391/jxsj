
do return end

Require("\\script\\event\\manager\\define.lua");

local EventKind = {};
EventManager.EventKind.Item.UseItem = EventKind;

function EventKind:OnUse()
	--物品使用脚本
	local nFlag, szMsg = EventManager.tbFun:CheckParam(self.tbEventPart.tbParam);
	if nFlag == 1 then
		me.Msg(szMsg)
		return 0;
	end
	local nFlag, szMsg = EventManager.tbFun:ExeParam(self.tbEventPart.tbParam);
	if nFlag == 1 then
		if szMsg then
			me.Msg(szMsg)
		end
		return 0;
	end
	return 1;
end

function EventKind:PickUp()
	--拾取执行脚本
	return 1;
end

function EventKind:IsPickable()
	--是否允许被拾取判断脚本
	return 1;
end

function EventKind:InitGenInfo()
	--拾取执行脚本
	local tbItemLiveTime = EventManager.tbFun:GetParam(self.tbEventPart.tbParam, "SetItemLiveTime")
	for nParam, szParam in ipairs(tbItemLiveTime) do
		tbItemTime[nParam] = "SetItemLiveTime:"..szParam;
	end
	EventManager.tbFun:ExeParam(tbItemTime);
	return {};
end
