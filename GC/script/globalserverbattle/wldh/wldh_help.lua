--武林武林大会帮助锦囊
--孙多良
--2009.08.26

function Wldh:UpdateNewsFinalList(nType, nIsFinal)
	local nKey = self.LADDER_ID[nType][5];
	local szTitle = self.LADDER_ID[nType][1].."决赛战报";
	nIsFinal = nIsFinal or 0;
	if nIsFinal > Wldh.MACTH_TIME_ADVMATCH_MAX then
		szTitle = self.LADDER_ID[nType][1].."最终决赛成绩";
	end
	local nAddTime = GetTime();
	local nEndTime = nAddTime + 3600 * 24 * 30;
	local nMapLinkType = Wldh:GetMapLinkType(nType);
	local szMsg	= "";
	if not Wldh.AdvMatchLists[nType] then
		return 0;
	end
	for nReadyId, tbList in pairs(Wldh.AdvMatchLists[nType]) do
		szMsg = szMsg .. Wldh:GetAdvHelpNewsInfor(tbList, nMapLinkType, nReadyId)
	end
	Task.tbHelp:AddDNews(nKey, szTitle, szMsg, nEndTime, nAddTime);
end

--获得帮助
function Wldh:GetAdvHelpNewsInfor(tbLeague, nMapLinkType, nReadyId)
	local szMsg = "";
	local tbVsTemp = {2,4,8,16,32};
	if nMapLinkType == self.MAP_LINK_TYPE_RANDOM then
		if tbLeague[2][1] and #tbLeague[2][1].tbResult >= 3 then
			if tbLeague[1] and tbLeague[1][1] then
				szMsg = szMsg .. "\n<color=red>最终武林大会冠军：".. tbLeague[1][1].szName .. "<color>\n";
			else
				szMsg = szMsg .. "\n<color=red>最终武林大会冠军：因双方战平而无冠军，两队均为第二名<color>\n";
			end
		end
		for _, nVsType in ipairs(tbVsTemp) do
			local tbVsList = tbLeague[nVsType];
			if tbVsList and #tbVsList > 0 then
				szMsg = szMsg .. string.format("<color=yellow>%s强赛对阵表<color>\n\n", nVsType);
				for nRank=1, (nVsType / 2) do
					local nVsRank = nVsType - nRank + 1;
					local szName  = "<color=gray>无参赛队伍<color>";
					local szVsName  = "<color=gray>无参赛队伍<color>";
					if tbVsList[nRank] then
						szName = "<color=pink>" .. tbVsList[nRank].szName .. "<color>";
					end
					
					if tbVsList[nVsRank] then
						szVsName ="<color=pink>" .. tbVsList[nVsRank].szName .. "<color>";
					end
					szMsg = szMsg .. Lib:StrFillR(szName, 37) .. Lib:StrFillC("对阵", 8) .. szVsName .. "\n";
				end
				szMsg = szMsg .. "\n";
			end
			if nVsType >= 16 and tbLeague[16] and #tbLeague[16] > 0 then
				break;
			end
		end
	end
	
	if nMapLinkType == self.MAP_LINK_TYPE_FACTION then
		local szFaction = Player:GetFactionRouteName(nReadyId);
		if tbLeague[2][1] and #tbLeague[2][1].tbResult >= 3 then
			if tbLeague[1] and tbLeague[1][1] then
				szMsg = szMsg .. string.format("\n<color=red>%s最终武林大会冠军：%s<color>\n", szFaction, tbLeague[1][1].szName);
			else
				szMsg = szMsg .. string.format("\n<color=red>%s最终武林大会冠军：因双方战平而无冠军，两队均为第二名<color>\n", szFaction);
			end
		end
		local nNew = 0;
		for _, nVsType in ipairs(tbVsTemp) do

			local tbVsList = tbLeague[nVsType];
			if tbVsList and #tbVsList > 0 then
				if nVsType >= 8 and nNew == 0 then
					szMsg = szMsg .. "<color=yellow>" .. szFaction .. string.format("门派赛%s强赛对阵表已产生<color>\n\n", nVsType);
					break;
				end
				nNew = 1;
				szMsg = szMsg .. "<color=yellow>" .. szFaction .. string.format("门派赛%s强赛对阵表<color>\n\n", nVsType);
				for nRank=1, (nVsType / 2) do
					local nVsRank = nVsType - nRank + 1;
					local szName  = "<color=gray>无参赛队伍<color>";
					local szVsName  = "<color=gray>无参赛队伍<color>";
					if tbVsList[nRank] then
						szName = "<color=pink>" .. tbVsList[nRank].szName .. "<color>";
					end
					
					if tbVsList[nVsRank] then
						szVsName ="<color=pink>" .. tbVsList[nVsRank].szName .. "<color>";
					end
					szMsg = szMsg .. Lib:StrFillR(szName, 37) .. Lib:StrFillC("对阵", 8) .. szVsName .. "\n";
				end
				szMsg = szMsg .. "\n";
				break;
			end
		end
		if tbLeague[32][1] then
			szMsg = szMsg .. "\n";
		end
	end
	return szMsg;
end
