--¾º¼¼Èü
--Ëï¶àÁ¼
--2008.12.25

if (not MODULE_GC_SERVER) then
	return 0;
end

function Esport:ApplySignUp(tbPlayerList)
	local nAttendMap = 0;
	for nMapId, tbGroup in pairs(self.tbGroupLists) do
		if tbGroup.nPlayerMax + #tbPlayerList <= self.DEF_PLAYER_MAX then
			nAttendMap = nMapId;
			break;
		end
	end
	if nAttendMap == 0 then
		GlobalExcute{"Esport:SignUpFail", tbPlayerList};
		return 0;
	end
	self:JoinGroupList(nAttendMap, tbPlayerList);
	GlobalExcute{"Esport:JoinGroupList", nAttendMap, tbPlayerList};
	GlobalExcute{"Esport:SignUpSucess", nAttendMap, tbPlayerList};
end
