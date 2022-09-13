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
			Dbg:WriteLog("CastleFight", "Quyết chiến Dạ Lam Quan", pPlayer.szAccount, pPlayer.szName, szLog);
			return 1;
		end
	end
	Dbg:WriteLog("CastleFight","Quyết chiến Dạ Lam Quan", szLog);
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
				pPlayer.Msg(string.format("Xin chúc mừng bạn đã giành <color=yellow>%s<color> điểm Vinh dự Dạ Lam Quan. Sau khi kết thúc, Tần Oa sẽ theo xếp hạng để trao phần thưởng.", nHonor));
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
