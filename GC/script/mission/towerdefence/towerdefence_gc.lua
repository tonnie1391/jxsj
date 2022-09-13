--¾º¼¼Èü
--Ëï¶àÁ¼
--2008.12.25

Require("\\script\\mission\\towerdefence\\towerdefence_def.lua")

if (not MODULE_GC_SERVER) then
	return 0;
end

function TowerDefence:ApplySignUp(tbPlayerList)
	local nAttendMap = 0;
	for nMapId, tbGroup in pairs(self.tbGroupLists) do
		if tbGroup.nPlayerMax + #tbPlayerList <= self.DEF_PLAYER_MAX then
			nAttendMap = nMapId;
			break;
		end
	end
	if nAttendMap == 0 then
		GlobalExcute{"TowerDefence:SignUpFail", tbPlayerList};
		return 0;
	end
	self:JoinGroupList(nAttendMap, tbPlayerList);
	GlobalExcute{"TowerDefence:JoinGroupList", nAttendMap, tbPlayerList};
	GlobalExcute{"TowerDefence:SignUpSucess", nAttendMap, tbPlayerList};
end

function TowerDefence:StartEvent()
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	if nCurDate <= TowerDefence.SNOWFIGHT_STATE[1] then
		local nType = Ladder:GetType(0, 2, 2, 3);
		Ladder:ClearTotalLadderData(nType,10,0,1);
		DelShowLadder(nType);
	end
end

GCEvent:RegisterGCServerStartFunc(TowerDefence.StartEvent, TowerDefence);
