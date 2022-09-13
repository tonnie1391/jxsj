--大会-战队操作
--孙多良
--2008.09.11

function Wldh:CreateLeague(tbMemberList, szLeagueName, nType)
	local nLGType = Wldh:GetLGType(nType);
	if League:FindLeague(nLGType, szLeagueName) then
		return 0;
	end
	local nSync = 1;
	League:AddLeague(nLGType, szLeagueName, 1);
	League:SetLeagueTask(nLGType, szLeagueName, self.LGTASK_MTYPE, nType, nSync);
	League:SetLeagueTask(nLGType, szLeagueName, self.LGTASK_RANK, 0, nSync);
	League:SetLeagueTask(nLGType, szLeagueName, self.LGTASK_WIN, 0, nSync);
	League:SetLeagueTask(nLGType, szLeagueName, self.LGTASK_TIE, 0, nSync);
	League:SetLeagueTask(nLGType, szLeagueName, self.LGTASK_TOTAL, 0, nSync);
	League:SetLeagueTask(nLGType, szLeagueName, self.LGTASK_TIME, 0, nSync);
	League:SetLeagueTask(nLGType, szLeagueName, self.LGTASK_EMY1, 0, nSync);
	League:SetLeagueTask(nLGType, szLeagueName, self.LGTASK_EMY2, 0, nSync);
	League:SetLeagueTask(nLGType, szLeagueName, self.LGTASK_EMY3, 0, nSync);
	League:SetLeagueTask(nLGType, szLeagueName, self.LGTASK_EMY4, 0, nSync);
	League:SetLeagueTask(nLGType, szLeagueName, self.LGTASK_EMY5, 0, nSync);
	League:SetLeagueTask(nLGType, szLeagueName, self.LGTASK_ATTEND, 0, nSync);
	League:SetLeagueTask(nLGType, szLeagueName, self.LGTASK_ENTER, 0, nSync);
	
	for nId, tbPlayer in ipairs(tbMemberList) do
		local szLog = string.format("【建立战队】[%s][%s]", szLeagueName, tbPlayer.szName);
		Wldh:WriteLog(szLog);
		League:AddMember(nLGType, szLeagueName, tbPlayer.szName, nSync)
		local nCaptain = 0;
		if nId == 1 then
			nCaptain = 1;
		end
		League:SetMemberTask(nLGType, szLeagueName, tbPlayer.szName, self.LGMTASK_JOB, 		nCaptain, 			nSync);
		League:SetMemberTask(nLGType, szLeagueName, tbPlayer.szName, self.LGMTASK_FACTION, 	tbPlayer.nFaction or 0, 	nSync);
		League:SetMemberTask(nLGType, szLeagueName, tbPlayer.szName, self.LGMTASK_ROUTEID, 	tbPlayer.nRouteId or 0, 	nSync);
		League:SetMemberTask(nLGType, szLeagueName, tbPlayer.szName, self.LGMTASK_CAMP, 	tbPlayer.nCamp or 0, 	nSync);
		League:SetMemberTask(nLGType, szLeagueName, tbPlayer.szName, self.LGMTASK_SEX, 	  	tbPlayer.nSex or 0, 		nSync);
		League:SetMemberTask(nLGType, szLeagueName, tbPlayer.szName, self.LGMTASK_SERIES,  	tbPlayer.nSeries or 0, 	nSync);
	end
	
	if (MODULE_GC_SERVER) then
		GlobalExcute{"Wldh:CreateLeague", tbMemberList, szLeagueName, nType};
	end
end

function Wldh:BreakLeague(nLGType, szMemberName)
	local szLeagueName = League:GetMemberLeague(nLGType, szMemberName);
	if not szLeagueName then
		return 0;
	end
	League:DelLeague(nLGType, szLeagueName);
end

function Wldh:GetLeagueMemberList(nLGType, szLeagueName)
	local tbPlayerList = League:GetMemberList(nLGType, szLeagueName);
	local tbWldhPlayerList = {};
	local szCaptain = "";
	
	for _, szMemberName in pairs(tbPlayerList) do
		local nCaptain = League:GetMemberTask(nLGType, szLeagueName, szMemberName, Wldh.LGMTASK_JOB);
		if nCaptain == 1 then
			table.insert(tbWldhPlayerList, 1, szMemberName);
			szCaptain = szMemberName;
		else
			table.insert(tbWldhPlayerList, szMemberName);
		end
	end
	
	if szCaptain ~= tbWldhPlayerList[1] then
		for nId, szMemberName in pairs(tbWldhPlayerList) do
			if nId == 1 then
				League:SetMemberTask(nLGType, szLeagueName, tbWldhPlayerList[1], Wldh.LGMTASK_JOB, 1);
			else
				League:SetMemberTask(nLGType, szLeagueName, tbWldhPlayerList[1], Wldh.LGMTASK_JOB, 0);
			end
		end
	end
	
	return tbWldhPlayerList;
end

--排序
--先按积分排行，再按胜场数，再按平场数，再按时间
local function OnSort(tbA, tbB)
	if Wldh.nFinalLocalType == 1 then
		if tbA.nAdvRank ~= tbB.nAdvRank then
			if tbB.nAdvRank == 0 then
				return tbA.nAdvRank > tbB.nAdvRank;
			elseif tbA.nAdvRank == 0 then
				return tbA.nAdvRank > tbB.nAdvRank;
			else
				return tbA.nAdvRank < tbB.nAdvRank;
			end
		end
	end
	
	if tbA.nPoint ~= tbB.nPoint then
		return tbA.nPoint > tbB.nPoint
	end

	if tbA.nWin ~= tbB.nWin then
		return tbA.nWin > tbB.nWin
	end
	
	if tbA.nTie ~= tbB.nTie then
		return tbA.nTie > tbB.nTie
	end
	
	--if tbA.nTotal ~= tbB.nTotal then
	--	return tbA.nTotal > tbB.nTotal;
	--end
		
	return tbA.nTime < tbB.nTime
end

function Wldh:SetRankData(nLGType, tbData, nMacthType, szTitle, nRankParam1, nRankParam2, nRankParam3, nRankParam4)
	local nLadderType = Ladder:GetType(nRankParam1, nRankParam2, nRankParam3, nRankParam4);
	local tbLadderInfo = {}
	for nRank, tbLeague in ipairs(tbData) do
		if nRank > 10 then
			break;
		end
		local tbMemberList = Wldh:GetLeagueMemberList(nLGType, tbLeague.szName);
		local tbList = {};
		for i, szName in ipairs(tbMemberList) do
			local nCaptain = League:GetMemberTask(nLGType, tbLeague.szName, szName, self.LGMTASK_JOB)
			local nFaction = GetPlayerInfoForLadderGC(szName) and GetPlayerInfoForLadderGC(szName).nFaction or 0;
			local nRouteId = GetPlayerInfoForLadderGC(szName) and GetPlayerInfoForLadderGC(szName).nRoute or 0;
			local szFaction = Player:GetFactionRouteName(nFaction, nRouteId);
			if nCaptain == 1 then
				table.insert(tbList, 1, {szName, szFaction});
			else
				table.insert(tbList, {szName, szFaction});
			end
		end
		local szMemberMsg = "";--"  " .. Lib:StrFillL("战队成员",17) .. "门派路线".."\n\n<color=yellow>";
		for i, tbMem in ipairs(tbList) do
			szMemberMsg = szMemberMsg .. tbMem[1] .. "|" .. tbMem[2].."\n";
		end
		
		local tbMemberInfo = {
			dwImgType = 2,
			szName = tbLeague.szName,
			szTxt1 = string.format("总积分:%s",tbLeague.nPoint),
			szTxt2 = string.format("胜:%s  平:%s  负:%s", tbLeague.nWin, tbLeague.nTie, (tbLeague.nTotal - tbLeague.nWin - tbLeague.nTie) ),
			szTxt3 = string.format("比赛时间:%s", Lib:TimeFullDesc(tbLeague.nTime)),
			szTxt4 = "",
			szTxt5 = "",
			szTxt6 = "",
			szContext = szMemberMsg,
			};
		table.insert(tbLadderInfo, tbMemberInfo);
	end
	SetShowLadder(nLadderType, szTitle, string.len(szTitle)+1, tbLadderInfo);
end

-- 设置大会显示榜名字
function Wldh:SetShowLadderName(szTitle, nRankParam1, nRankParam2, nRankParam3, nRankParam4)
	SetShowLadderName(Ladder:GetType(nRankParam1, nRankParam2, nRankParam3, nRankParam4), szTitle, string.len(szTitle)+1);
end

--比赛结束后战队排名
function Wldh:LeagueRank(nType, bRead, bFinal)
	Wldh.nFinalLocalType = bFinal or 0;
	local nMapLinkType = Wldh:GetMapLinkType(nType);
	local nLGType 	   = Wldh:GetLGType(nType);
	if nMapLinkType == Wldh.MAP_LINK_TYPE_RANDOM then
		local pLeagueSet 	= KLeague.GetLeagueSetObject(nLGType);
		local pLeagueItor 	= pLeagueSet.GetLeagueItor();
		local pLeague 		= pLeagueItor.GetCurLeague();
		self.RankLeagueList[nType] = {};
		self.RankLeagueId[nType]   = 1;
		while(pLeague) do
			local nWin = pLeague.GetTask(self.LGTASK_WIN);
			local nTie = pLeague.GetTask(self.LGTASK_TIE);
			local nTotal = pLeague.GetTask(self.LGTASK_TOTAL);
			local nTime = pLeague.GetTask(self.LGTASK_TIME);
			local nAdvRank	= pLeague.GetTask(self.LGTASK_RANK_ADV);
			local nLoss = nTotal - nWin - nTie;
			local nPoint = nWin * Wldh.MACTH_POINT_WIN + nTie * Wldh.MACTH_POINT_TIE + nLoss * Wldh.MACTH_POINT_LOSS;
			if nTotal > 0 then
				table.insert(self.RankLeagueList[nType], {szName = pLeague.szName, nWin = nWin, nTie = nTie, nTotal = nTotal, nTime = nTime, nPoint = nPoint, nAdvRank = nAdvRank});				
			end
			pLeague = pLeagueItor.NextLeague();
		end
		
		if #self.RankLeagueList[nType] > 0 then
			table.sort(self.RankLeagueList[nType], OnSort);
		end
		if (MODULE_GC_SERVER and bRead ~= 1) then	
			--当届前10名入榜.
			Wldh:SetRankData(nLGType, self.RankLeagueList[nType], nMapLinkType, Wldh.LADDER_ID[nType][1], 0, Wldh.LADDER_ID[nType][2], Wldh.LADDER_ID[nType][3], Wldh.LADDER_ID[nType][4]);
			GlobalExcute{"Ladder:RefreshLadderName"};
		end
		if #self.RankLeagueList[nType] > 0 then
			Timer:Register(1, self.LeagueRankFrame, self, nType, nMapLinkType, bRead, bFinal);
		end
	end
	
	--门派类型
	if nMapLinkType == Wldh.MAP_LINK_TYPE_FACTION then
		local pLeagueSet 	= KLeague.GetLeagueSetObject(nLGType);
		local pLeagueItor 	= pLeagueSet.GetLeagueItor();
		local pLeague 		= pLeagueItor.GetCurLeague();
		self.RankLeagueList[nType] = {};
		self.RankLeagueId[nType]   = 1;
		while(pLeague) do
			local nWin = pLeague.GetTask(self.LGTASK_WIN);
			local nTie = pLeague.GetTask(self.LGTASK_TIE);
			local nTotal = pLeague.GetTask(self.LGTASK_TOTAL);
			local nTime = pLeague.GetTask(self.LGTASK_TIME);
			local nFaction = 0;
			local tbMember = Wldh:GetLeagueMemberList(nLGType, pLeague.szName);
			if (tbMember) then
				nFaction	= League:GetMemberTask(nLGType, pLeague.szName, tbMember[1], Wldh.LGMTASK_FACTION);
			end
			local nAdvRank	= pLeague.GetTask(self.LGTASK_RANK_ADV);
			local nLoss = nTotal - nWin - nTie;
			local nPoint = nWin * Wldh.MACTH_POINT_WIN + nTie * Wldh.MACTH_POINT_TIE + nLoss * Wldh.MACTH_POINT_LOSS;
			if nTotal > 0 then
				if not self.RankLeagueList[nType][nFaction] then
					self.RankLeagueList[nType][nFaction] = {};
				end
				table.insert(self.RankLeagueList[nType][nFaction], {szName = pLeague.szName, nWin = nWin, nTie = nTie, nTotal = nTotal, nTime = nTime, nPoint = nPoint, nAdvRank = nAdvRank});
			end
			pLeague = pLeagueItor.NextLeague();
		end
		for nFaction, tbLeagueList in pairs(self.RankLeagueList[nType]) do
			if #tbLeagueList > 0 then
				table.sort(self.RankLeagueList[nType][nFaction], OnSort);
			end
		end
		
		if (MODULE_GC_SERVER and bRead ~= 1) then	
			--当届前10名入榜.
			for nFaction=1, 12 do
				local szFaction		= Player:GetFactionRouteName(nFaction);
				local nLadderType	= Ladder:GetType(0, Wldh.LADDER_ID[nType][2], Wldh.LADDER_ID[nType][3], nFaction);
				DelShowLadder(nLadderType);
				if (0 == CheckShowLadderExist(nLadderType)) then
					AddNewShowLadder(nLadderType);
				end
				Wldh:SetShowLadderName(szFaction, 0, Wldh.LADDER_ID[nType][2], Wldh.LADDER_ID[nType][3], nFaction);
				Wldh:SetRankData(nLGType, self.RankLeagueList[nType][nFaction] or {}, nMapLinkType, Wldh.LADDER_ID[nType][1], 0, Wldh.LADDER_ID[nType][2], Wldh.LADDER_ID[nType][3], nFaction);
			end
			GlobalExcute{"Ladder:RefreshLadderName"};
		end
		Timer:Register(1, self.LeagueRankFrame, self, nType, nMapLinkType, bRead, bFinal);
	end
	Wldh.nFinalLocalType = 0;
end

--分帧存储
function Wldh:LeagueRankFrame(nType, nMapLinkType, bRead, bFinal)
	local nLGType = Wldh:GetLGType(nType);
	if nMapLinkType == self.MAP_LINK_TYPE_RANDOM then
		local nCount = 0;
		for nRank = self.RankLeagueId[nType], #self.RankLeagueList[nType] do
			if nCount >= self.RankFrameCount then
				self.RankLeagueId[nType] = nRank;
				return 1;
			end
			if bRead ~= 1 then
				League:SetLeagueTask(nLGType, self.RankLeagueList[nType][nRank].szName, Wldh.LGTASK_RANK, nRank, 1);
			end
			if (MODULE_GC_SERVER) then
				if bFinal == 1 and nRank > 0 then
					local szLeagueName = self.RankLeagueList[nType][nRank].szName;
					local nRankAdv 	= League:GetLeagueTask(nLGType, szLeagueName, Wldh.LGTASK_RANK_ADV);
					local nTotle 	= League:GetLeagueTask(nLGType, szLeagueName, self.LGTASK_TOTAL);
					local nCurRank = nRank;
					if nCurRank == 1 and nRankAdv == 2 then
						nCurRank = 2;
					end
					for _, szMemberName in pairs(Wldh:GetLeagueMemberList(nLGType, szLeagueName)) do
						local nId = KGCPlayer.GetPlayerIdByName(szMemberName);
						if nId then
							SetPlayerSportTask(nId, Wldh.GBTASKID_GROUP, Wldh.GBTASKID_FINAL_ID[nType], nCurRank);
							SetPlayerSportTask(nId, Wldh.GBTASKID_GROUP, Wldh.GBTASKID_ATTEND_ID[nType], nTotle);
						end
					end
				end
			end
			Wldh:WriteLog(string.format("%s排名:战队:%s\t排名:%s", self:GetName(nType), self.RankLeagueList[nType][nRank].szName, nRank));
			nCount = nCount + 1;
		end
		if (MODULE_GC_SERVER) then
			GlobalExcute({"Wldh:LeagueRank", nType});
		end
	end
	
	if nMapLinkType == self.MAP_LINK_TYPE_FACTION then
		local nCount = 0;
		local nRankFaction = self.RankLeagueId[nType];
		if self.RankLeagueList[nType][nRankFaction] then
			for nRank, tbLeagueInfo in ipairs(self.RankLeagueList[nType][nRankFaction]) do
				if bRead ~= 1 then
					League:SetLeagueTask(nLGType, tbLeagueInfo.szName, Wldh.LGTASK_RANK, nRank, 1);
				end
				if (MODULE_GC_SERVER) then
					if bFinal == 1 and nRank > 0 then
						local szLeagueName = tbLeagueInfo.szName;
						local nRankAdv 	= League:GetLeagueTask(nLGType, szLeagueName, Wldh.LGTASK_RANK_ADV);
						local nTotle 	= League:GetLeagueTask(nLGType, szLeagueName, self.LGTASK_TOTAL);
						local nCurRank = nRank;
						if nCurRank == 1 and nRankAdv == 2 then
							nCurRank = 2;
						end
						for _, szMemberName in pairs(Wldh:GetLeagueMemberList(nLGType, szLeagueName)) do
							local nId = KGCPlayer.GetPlayerIdByName(szMemberName);
							if nId then
								SetPlayerSportTask(nId, Wldh.GBTASKID_GROUP, Wldh.GBTASKID_FINAL_ID[nType], nCurRank);
								SetPlayerSportTask(nId, Wldh.GBTASKID_GROUP, Wldh.GBTASKID_ATTEND_ID[nType], nTotle);
								SetPlayerSportTask(nId, Wldh.GBTASKID_GROUP, Wldh.GBTASKID_FACTION_ID, nRankFaction);
							end
						end
					end
				end				
				Wldh:WriteLog(string.format("%s类型武林大会排名:门派Id%s\t战队:%s\t排名:%s", self:GetName(nType), nRankFaction, tbLeagueInfo.szName, nRank));
			end
		end
		if nRankFaction < 12 then
			self.RankLeagueId[nType] = self.RankLeagueId[nType] + 1;
			return 1;
		end
		
		if (MODULE_GC_SERVER) then
			GlobalExcute({"Wldh:LeagueRank", nType});
		end
	end
	return 0;
end

function Wldh:GCStartLoadDate()
	local nType = self:GetCurGameType();
	if nType > 0 then
		self:LeagueRank(nType, 1);
	end
end

if (MODULE_GC_SERVER) then
	GCEvent:RegisterGCServerStartFunc(Wldh.GCStartLoadDate, Wldh);
end
