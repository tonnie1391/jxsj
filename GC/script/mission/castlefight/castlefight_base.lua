--竞技赛(基本公用类)
--孙多良,麦亚津
--2008.12.25

function CastleFight:GetConsoleCfg()
	local tbConsole = self:GetConsole();
	if (not tbConsole) then
		return;
	end
	return tbConsole.tbCfg;
end

function CastleFight:GetConsole()
	local tbConsole = Console:GetBase(self.DEF_EVENT_TYPE);
	if (not tbConsole) then
		return;
	end
	return tbConsole;
end

function CastleFight:WriteLog(szLog, nPlayerId)
	if nPlayerId then
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
		if (pPlayer) then
			Dbg:WriteLog("CastleFight", "决战夜岚关", pPlayer.szAccount, pPlayer.szName, szLog);
			return 1;
		end
	end
	Dbg:WriteLog("CastleFight","决战夜岚关", szLog);
end

function CastleFight:AddHonor(szName, nHonor)
	if nHonor == 0 then
		return
	end
	if MODULE_GAMESERVER then
		GCExcute{"CastleFight:AddHonor", szName, nHonor};
		
		--公告
		local nPlayerId = KGCPlayer.GetPlayerIdByName(szName);
		if nPlayerId and nPlayerId > 0 then
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				pPlayer.Msg(string.format("恭喜您获得了<color=yellow>%s<color>点夜岚关荣誉。全部活动结束后，秦洼将据此排名发放丰厚的最终奖励！", nHonor));
			end
		end
		return 0;
	end
	local nAddHonor = PlayerHonor:GetPlayerHonorByName(szName, self.DEF_HONOR_CLASS, 0) + nHonor;
	PlayerHonor:SetPlayerHonorByName(szName, self.DEF_HONOR_CLASS, 0, nAddHonor);
end

function CastleFight:SendMsgAndBroadMsg(pPlayer, szMsg)
	if (not pPlayer) then
		return 0;
	end
	pPlayer.Msg(szMsg);
	Dialog:SendInfoBoardMsg(pPlayer, szMsg);
	return 1;
end
