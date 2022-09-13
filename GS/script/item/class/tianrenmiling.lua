local tbTianRen = Item:GetClass("tianrenmiling");

function tbTianRen:OnUse()
	local nRet, szMsg = Map:CheckTagServerPlayerCount(202)
	if nRet ~= 1 then
		me.Msg(szMsg);
		return 0;
	end
	me.NewWorld(202,1585,3716)
	return 1;
end
