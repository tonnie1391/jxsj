Require("\\script\\event\\manager\\define.lua");

local EventKind = {};
EventManager.EventKind.Module.item_useitem = EventKind;

function EventKind:OnUse()
	--物品使用脚本	
	return EventManager.EventKind.Module.default.OnUse(self);
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
	return {};
end
