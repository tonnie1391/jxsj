-- playerforbidgetitem.lua
-- zhouchenfei
-- 2010-12-21 16:38:17

Player.tbForbid_EventFlag = {
		["playerpray"] = 1,
		["onlineaward"] = 1,
	};

function Player:SetForbidGetItem(nFlag)
	me.GetTempTable("Player").nForbidGetItemFlag = nFlag or 0;
end

function Player:CheckForbidGetItem(szEventName)
	local nFlag = me.GetTempTable("Player").nForbidGetItemFlag or 0;

	if (nFlag == 0) then
		return 0;
	end
	
	if (self.tbForbid_EventFlag[szEventName] and self.tbForbid_EventFlag[szEventName] == 1) then
		me.Msg("此功能在这里已被禁止使用！");
		return 1;
	end
	
	return 0;
end

