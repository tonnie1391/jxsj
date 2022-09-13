--联赛-战队操作
--孙多良
--2008.09.11

function Wlls:CreateLeague(tbMemberList, szLeagueName, nMacthLevel, nExParam)
	if League:FindLeague(self.LGTYPE, szLeagueName) then
		return 0;
	end
	local nSync = 1;
	League:AddLeague(self.LGTYPE, szLeagueName, 1);
	League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_MSESSION, self:GetMacthSession(), nSync);
	League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_MTYPE, self:GetMacthType(), nSync);
	League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_MEXPARAM, nExParam, nSync);
	League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_MLEVEL, nMacthLevel, nSync);
	League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_RANK, 0, nSync);
	League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_WIN, 0, nSync);
	League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_TIE, 0, nSync);
	League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_TOTAL, 0, nSync);
	League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_TIME, 0, nSync);
	League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_EMY1, 0, nSync);
	League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_EMY2, 0, nSync);
	League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_EMY3, 0, nSync);
	League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_EMY4, 0, nSync);
	League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_EMY5, 0, nSync);
	League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_ATTEND, 0, nSync);
	League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_ENTER, 0, nSync);
	League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_ADV_ID, 0, nSync);
	League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_RANK_ADV, 0, nSync);
	local nTime	= GetTime();
	local tbPlayerJoinList = {};
	local nGateway = 0;
	for nId, tbPlayer in ipairs(tbMemberList) do
		League:AddMember(self.LGTYPE, szLeagueName, tbPlayer.szName, nSync)
		-- 设置玩家的联赛届数
		if (MODULE_GC_SERVER) then
			Wlls:SetPlayerSession(tbPlayer.szName, self:GetMacthSession());
			if (GLOBAL_AGENT) then
				GbWlls:ResetPlayerGbWllsInfo(tbPlayer.szName, nMacthLevel, tbPlayer.nExParam);
				GbWlls:SendJoinMsg_GB(tbPlayer.szName);
			end
		elseif (MODULE_GAMESEVER and not GLOBAL_AGENT) then
			Wlls:SetPlayerIsLeagueFlag(tbPlayer.szName, 1);
		end
		local nCaptain = 0;
		if nId == 1 then
			nCaptain = 1;
		end
		tbPlayerJoinList[#tbPlayerJoinList + 1] = tbPlayer.szName;
		League:SetMemberTask(self.LGTYPE, szLeagueName, tbPlayer.szName, self.LGMTASK_JOB, 		nCaptain, 			nSync);
		League:SetMemberTask(self.LGTYPE, szLeagueName, tbPlayer.szName, self.LGMTASK_FACTION, 	tbPlayer.nFaction, 	nSync);
		League:SetMemberTask(self.LGTYPE, szLeagueName, tbPlayer.szName, self.LGMTASK_ROUTEID, 	tbPlayer.nRouteId, 	nSync);
		League:SetMemberTask(self.LGTYPE, szLeagueName, tbPlayer.szName, self.LGMTASK_CAMP, 	tbPlayer.nCamp, 	nSync);
		League:SetMemberTask(self.LGTYPE, szLeagueName, tbPlayer.szName, self.LGMTASK_SEX, 	  	tbPlayer.nSex, 		nSync);
		League:SetMemberTask(self.LGTYPE, szLeagueName, tbPlayer.szName, self.LGMTASK_SERIES,  	tbPlayer.nSeries, 	nSync);
		League:SetMemberTask(self.LGTYPE, szLeagueName, tbPlayer.szName, self.LGMTASK_GBWLLSLEVEL,  tbPlayer.nMyGameLevel, nSync);
		League:SetMemberTask(self.LGTYPE, szLeagueName, tbPlayer.szName, self.LGMTASK_GBWLLSGATEWAY,  tbPlayer.nGateway, nSync);
		nGateway = tbPlayer.nGateway;
		if (MODULE_GC_SERVER) then
			local szLogKey = "Wlls_JoinLeague";
			if (GLOBAL_AGENT) then
				szLogKey = "GbWlls_JoinLeague"
			end
			Dbg:WriteLogEx(Dbg.LOG_INFO, szLogKey, tbPlayer.szName, szLeagueName, tbPlayer.nLevel, Player:GetFactionRouteName(tbPlayer.nFaction, tbPlayer.nRouteId), os.date("%Y-%m-%d",nTime));
		end
	end
	
	if (GLOBAL_AGENT and MODULE_GC_SERVER) then
		GbWlls:SendPlayerJoinOrLeave_GB(tbPlayerJoinList, nGateway);
	end
	
	League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_GATEWAY, nGateway, nSync);
	
	if (MODULE_GC_SERVER) then
		GlobalExcute{"Wlls:CreateLeague", tbMemberList, szLeagueName, nMacthLevel, nExParam};
	end
end

-- 从数据库中获取所有战队的信息
function Wlls:_GetWllsLeague()
	print("Get WllsLeague start.......");
	local nLgType		= self.LGTYPE;
	local pLeagueSet 	= KLeague.GetLeagueSetObject(nLgType);
	local pLeagueItor 	= pLeagueSet.GetLeagueItor();
	local pLeague 		= pLeagueItor.GetCurLeague();
	local tbLeagueList 	= {};
	local tbWllsLeagueList = {};
	local nMemberCount		= 0;
	local nRealMemberCount	= 0;
	while(pLeague) do
		table.insert(tbLeagueList, pLeague.szName);
		nMemberCount = nMemberCount + 1;
		local szName = pLeague.szName;
		local tbOneLeague = self:_GetWllsOneLeagueInfo(nLgType, szName);
		if (tbOneLeague) then
			tbWllsLeagueList[szName] = tbOneLeague;
			nRealMemberCount = nRealMemberCount + 1;
		end
		pLeague = pLeagueItor.NextLeague();
	end
	-- 先注释如果要删除的话把注释去了
--	for ni, szLeagueName in pairs(tbLeagueList) do
--		League:DelLeague(nLgType, szLeagueName, 1);
--	end

	print("Get Wlls League from database number is " .. nMemberCount .. " , real get the League number is " .. nRealMemberCount);
	print("Get WllsLeague end.......");
	return tbWllsLeagueList;
end

-- 从数据库中获取一个战队的信息
function Wlls:_GetWllsOneLeagueInfo(nLgType, szLeagueName)
	if not League:FindLeague(nLgType, szLeagueName) then
		print("Type " .. nLgType .. " szLeagueName : " .. szLeagueName .. "is not exist!!!!");
		return nil;
	end
	local tbLeagueList	= {};
	local tbInfo		= {};
	tbLeagueList.tbInfo = {};
	local tbTaskData	= KLeague.GetLeagueTaskAllData(nLgType, szLeagueName);
	if (not tbTaskData) then
		print("Type " .. nLgType .. " szLeagueName : " .. szLeagueName .. ", TaskData is not exist!!!!");
		return nil;		
	end
	for nTaskId, nTaskValue in pairs(tbTaskData) do
		tbInfo[nTaskId]	= nTaskValue;
	end

	
	tbLeagueList.tbInfo = tbInfo;
	
	local tbMemberList = {};
	tbLeagueList.tbMemberList = {};
	
	local tbMember	= League:GetMemberList(nLgType, szLeagueName);

	if (not tbMember) then
		print("League " .. szLeagueName .. " member is not exist!!!!!");
		return tbLeagueList;
	end

	for _, szName in ipairs(tbMember) do
		local tbOneMember = {};
		local tbMemberTaskData = KLeague.GetLeagueMemberTaskAllData(nLgType, szLeagueName, szName);
		if (tbMemberTaskData) then
			for nTaskId, nTaskValue in pairs(tbMemberTaskData) do
				tbOneMember[nTaskId] = nTaskValue;
			end
			tbMemberList[szName] = tbOneMember;
		end
	end
	tbLeagueList.tbMemberList = tbMemberList;

	return tbLeagueList;
end

-- 合并战队
function Wlls:_SetWllsLeague(nLgType, tbWllsLeagueList)
	print("Set WllsLeague start.......");
	if (not tbWllsLeagueList) then
		print("The tbWllsLeagueList is not exist!!!!!");
		return;
	end
	for szName, tbOneLeague in pairs(tbWllsLeagueList) do
		local szLeagueName	= self:_GetRightName(nLgType, szName);
		if (szLeagueName and string.len(szLeagueName) > 0) then
			local tbInfo		= tbOneLeague.tbInfo or {};
			League:AddLeague(nLgType, szLeagueName);
			for nTaskId, nValue in pairs(tbInfo) do
				League:SetLeagueTask(nLgType, szLeagueName, nTaskId, nValue);
			end
			local tbMemberList = tbOneLeague.tbMemberList or {};
			for szName, tbPlayer in pairs(tbMemberList) do
				League:AddMember(nLgType, szLeagueName, szName)
				for nTaskId, nTaskValue in pairs(tbPlayer) do
					League:SetMemberTask(nLgType, szLeagueName, szName, nTaskId, nTaskValue);
				end
			end
		end
	end
	print("Set WllsLeague end.......");
end

-- 获取战队名
function Wlls:_GetRightName(nLgType, szName)
	local szLeagueName = szName;
	if (not szLeagueName or string.len(szLeagueName) <= 0) then
		print("The szLeagueName is illige!!!");
		return szLeagueName;
	end
	while(League:FindLeague(nLgType, szLeagueName)) do
		local tbParam = Lib:SplitStr(szLeagueName, "@");
		if (tbParam[2]) then
			tbParam[2] = tbParam[2] + 1;
		else
			tbParam[2] = "1";
		end
		szLeagueName = tbParam[1] .. "@" .. tbParam[2];
	end
	return szLeagueName;
end

function Wlls:JoinLeague(szLeagueName, tbJoinPlayerIdList)
	local nMatchLevel = League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_MLEVEL);
	local tbJoinList = {};
	local nTime	= GetTime();
	for _, tbPlayer in pairs(tbJoinPlayerIdList) do
		local szName = tbPlayer.szName;
		if szName and not League:GetMemberLeague(Wlls.LGTYPE, szName) then
			League:AddMember(self.LGTYPE, szLeagueName, szName);
			if (MODULE_GC_SERVER) then
				Wlls:SetPlayerSession(tbPlayer.szName, self:GetMacthSession());
				if (GLOBAL_AGENT) then
					GbWlls:ResetPlayerGbWllsInfo(szName, nMatchLevel, tbPlayer.nExParam);
					GbWlls:SendJoinMsg_GB(tbPlayer.szName);
				else
					GlobalExcute{"Wlls:SetPlayerIsLeagueFlag", szName, 1};
				end
			end
			if (MODULE_GC_SERVER) then
				local szLogKey = "Wlls_JoinLeague";
				if (GLOBAL_AGENT) then
					szLogKey = "GbWlls_JoinLeague"
				end
				Dbg:WriteLogEx(Dbg.LOG_INFO, szLogKey, tbPlayer.szName, szLeagueName, tbPlayer.nLevel, Player:GetFactionRouteName(tbPlayer.nFaction, tbPlayer.nRouteId), os.date("%Y-%m-%d",nTime));
			end			
			League:SetMemberTask(self.LGTYPE, szLeagueName, szName, self.LGMTASK_FACTION, tbPlayer.nFaction);
			League:SetMemberTask(self.LGTYPE, szLeagueName, szName, self.LGMTASK_ROUTEID, tbPlayer.nRouteId);
			League:SetMemberTask(self.LGTYPE, szLeagueName, szName, self.LGMTASK_CAMP, 	  tbPlayer.nCamp);
			League:SetMemberTask(self.LGTYPE, szLeagueName, szName, self.LGMTASK_SEX, 	  tbPlayer.nSex);
			League:SetMemberTask(self.LGTYPE, szLeagueName, szName, self.LGMTASK_SERIES,  tbPlayer.nSeries);
			League:SetMemberTask(self.LGTYPE, szLeagueName, szName, self.LGMTASK_GBWLLSLEVEL,  tbPlayer.nMyGameLevel);
			tbJoinList[#tbJoinList + 1] = szName;
		end
	end

	if (GLOBAL_AGENT and MODULE_GC_SERVER) then
		local nGateway = League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_GATEWAY);
		GbWlls:SendPlayerJoinOrLeave_GB(tbJoinList, nGateway);
	end

end

function Wlls:LeaveLeague(szMemberName, nGameLevel, nQLeave)
	local szLeagueName = League:GetMemberLeague(self.LGTYPE, szMemberName);
	if not szLeagueName then
		return 0;
	end
	local nGateway = League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_GATEWAY);
	if League:GetMemberCount(self.LGTYPE, szLeagueName) <= 1 then
		League:DelLeague(self.LGTYPE, szLeagueName);
		self:SetPlayerSession(szMemberName, 0);
		if (MODULE_GC_SERVER and not GLOBAL_AGENT) then
			GlobalExcute{"Wlls:SetPlayerIsLeagueFlag", szMemberName, 0};
		end

		if (MODULE_GC_SERVER and GLOBAL_AGENT) then
			GbWlls:SendPlayerJoinOrLeave_GB({szMemberName,}, nGateway, 1);
		end
		return 0;
	end
	
	--马上离开战队
	if nQLeave == 1 then
		League:DelMember(self.LGTYPE, szLeagueName, szMemberName);
		self:SetPlayerSession(szMemberName, 0);		
		if (MODULE_GC_SERVER and not GLOBAL_AGENT) then
			GlobalExcute{"Wlls:SetPlayerIsLeagueFlag", szMemberName, 0};
		end
		
		if (MODULE_GC_SERVER and GLOBAL_AGENT) then
			GbWlls:SendPlayerJoinOrLeave_GB({szMemberName,}, nGateway, 1);
		end
		return 0;
	end
	
	local tbLeagueMemberList = Wlls:GetLeagueMemberList(szLeagueName);
	local tbAdv = {};
	local nCaptain = League:GetMemberTask(Wlls.LGTYPE, szLeagueName, szMemberName, Wlls.LGMTASK_JOB);
	if nGameLevel == Wlls.MACTH_ADV then
		for _, szName in pairs(tbLeagueMemberList) do
			if Wlls:GetGameLevelForRank(szName, nGameLevel) == Wlls.MACTH_ADV then
				table.insert(tbAdv, szName);
			end
		end
		if Wlls:GetGameLevelForRank(szMemberName, nGameLevel) == Wlls.MACTH_ADV then
			if #tbAdv <= 1 then
				self:SetTeamPlayerSportValue(szLeagueName, GbWlls.GBTASKID_SESSION, 0);
				League:DelLeague(self.LGTYPE, szLeagueName);
				if (MODULE_GC_SERVER and GLOBAL_AGENT) then
					GbWlls:SendPlayerJoinOrLeave_GB(tbLeagueMemberList, nGateway, 1);
				end
				return 0;
			end
		end
		
		if nCaptain == 1 then
			for _, szName in pairs(tbAdv) do
				if szName ~= szMemberName then
					League:DelMember(self.LGTYPE, szLeagueName, szMemberName);
					self:SetPlayerSession(szMemberName, 0);
					if (MODULE_GC_SERVER and not GLOBAL_AGENT) then
						GlobalExcute{"Wlls:SetPlayerIsLeagueFlag", szMemberName, 0};
					end
					
					if (MODULE_GC_SERVER and GLOBAL_AGENT) then
						GbWlls:SendPlayerJoinOrLeave_GB({szMemberName,}, nGateway, 1);
					end
					
					League:SetMemberTask(Wlls.LGTYPE, szLeagueName, szName, Wlls.LGMTASK_JOB, 1);
					return 0;
				end
			end
			
			for _, szName in pairs(tbLeagueMemberList) do
				if szName ~= szMemberName then
					League:SetMemberTask(Wlls.LGTYPE, szLeagueName, szName, Wlls.LGMTASK_JOB, 1);
					break;
				end
			end
			League:DelMember(self.LGTYPE, szLeagueName, szMemberName);
			if (MODULE_GC_SERVER and GLOBAL_AGENT) then
				GbWlls:SendPlayerJoinOrLeave_GB({szMemberName,}, nGateway, 1);
			end			
			self:SetPlayerSession(szMemberName, 0);
			if (MODULE_GC_SERVER and not GLOBAL_AGENT) then
				GlobalExcute{"Wlls:SetPlayerIsLeagueFlag", szMemberName, 0};
			end
			return 0;
		end
		League:DelMember(self.LGTYPE, szLeagueName, szMemberName);
		if (MODULE_GC_SERVER and GLOBAL_AGENT) then
			GbWlls:SendPlayerJoinOrLeave_GB({szMemberName,}, nGateway, 1);
		end
		self:SetPlayerSession(szMemberName, 0);
		if (MODULE_GC_SERVER and not GLOBAL_AGENT) then
			GlobalExcute{"Wlls:SetPlayerIsLeagueFlag", szMemberName, 0};
		end
	elseif nGameLevel == Wlls.MACTH_PRIM then
		if nCaptain == 1 then
			for _, szName in pairs(tbLeagueMemberList) do
				if szName ~= szMemberName then
					League:SetMemberTask(Wlls.LGTYPE, szLeagueName, szName, Wlls.LGMTASK_JOB, 1);
					break;
				end
			end
			League:DelMember(self.LGTYPE, szLeagueName, szMemberName);
			self:SetPlayerSession(szMemberName, 0);
			if (MODULE_GC_SERVER and not GLOBAL_AGENT) then
				GlobalExcute{"Wlls:SetPlayerIsLeagueFlag", szMemberName, 0};
			end			
			return 0;
		end
		League:DelMember(self.LGTYPE, szLeagueName, szMemberName);
		self:SetPlayerSession(szMemberName, 0);
		if (MODULE_GC_SERVER and not GLOBAL_AGENT) then
			GlobalExcute{"Wlls:SetPlayerIsLeagueFlag", szMemberName, 0};
		end	
	end
end

function Wlls:BreakLeague(szMemberName)
	local szLeagueName = League:GetMemberLeague(Wlls.LGTYPE, szMemberName);
	if not szLeagueName then
		return 0;
	end
	if (GLOBAL_AGENT) then
		self:SetTeamPlayerSportValue(szLeagueName, GbWlls.GBTASKID_SESSION, 0);
	end
	League:DelLeague(self.LGTYPE, szLeagueName);
end

function Wlls:GetLeagueMemberList(szLeagueName)
	local tbPlayerList = League:GetMemberList(Wlls.LGTYPE, szLeagueName);
	local tbWllsPlayerList = {};
	local szCaptain = "";
	
	for _, szMemberName in pairs(tbPlayerList) do
		local nCaptain = League:GetMemberTask(Wlls.LGTYPE, szLeagueName, szMemberName, Wlls.LGMTASK_JOB);
		if nCaptain == 1 then
			table.insert(tbWllsPlayerList, 1, szMemberName);
			szCaptain = szMemberName;
		else
			table.insert(tbWllsPlayerList, szMemberName);
		end
	end
	
	if szCaptain ~= tbWllsPlayerList[1] then
		for nId, szMemberName in pairs(tbWllsPlayerList) do
			if nId == 1 then
				League:SetMemberTask(Wlls.LGTYPE, szLeagueName, tbWllsPlayerList[1], Wlls.LGMTASK_JOB, 1);
			else
				League:SetMemberTask(Wlls.LGTYPE, szLeagueName, tbWllsPlayerList[1], Wlls.LGMTASK_JOB, 0);
			end
		end
	end
	
	return tbWllsPlayerList;
end

--排序
--先按积分排行，再按胜场数，再按平场数，再按时间
local function OnSort(tbA, tbB)
	if Wlls.nFinalLocalType == 1 then
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

function Wlls:SetRankData(tbData, nMacthType, szTitle, nRankParam1, nRankParam2, nRankParam3, nRankParam4)
	local tbLadderInfo = {}
	for nRank, tbLeague in ipairs(tbData) do
		if nRank > 10 then
			break;
		end
		local tbMemberList = Wlls:GetLeagueMemberList(tbLeague.szName);
		local tbList = {};
		for i, szName in ipairs(tbMemberList) do
			local nCaptain = League:GetMemberTask(self.LGTYPE, tbLeague.szName, szName, self.LGMTASK_JOB)
			--local nFaction = League:GetMemberTask(self.LGTYPE, tbLeague.szName, szName, self.LGMTASK_FACTION)
			--local nRouteId = League:GetMemberTask(self.LGTYPE, tbLeague.szName, szName, self.LGMTASK_ROUTEID);
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
			szTxt1 = string.format("Tổng điểm: %s",tbLeague.nPoint),
			szTxt2 = string.format("Lần: %s", Lib:Transfer4LenDigit2CnNum(tbLeague.nSession)),
			szTxt3 = Wlls.SEASON_TB[tbLeague.nSession][4],
			szTxt4 = string.format("Thắng: %s  Hòa: %s  Bại: %s", tbLeague.nWin, tbLeague.nTie, (tbLeague.nTotal - tbLeague.nWin - tbLeague.nTie) ),
			szTxt5 = string.format("Thời gian thi đấu: %s", Lib:TimeFullDesc(tbLeague.nTime)),
			szTxt6 = "",
			szContext = szMemberMsg,
			};
		table.insert(tbLadderInfo, tbMemberInfo);
	end
	SetShowLadder(Ladder:GetType(nRankParam1, nRankParam2, nRankParam3, nRankParam4), szTitle, string.len(szTitle)+1, tbLadderInfo);
end

-- 设置联赛显示榜名字
function Wlls:SetShowLadderName(szTitle, nRankParam1, nRankParam2, nRankParam3, nRankParam4)
	SetShowLadderName(Ladder:GetType(nRankParam1, nRankParam2, nRankParam3, nRankParam4), szTitle, string.len(szTitle)+1);
end

--一届比赛结束后战队排名
function Wlls:LeagueRankFinal()
	local nFinalType = 1;
	self:LeagueRank(nFinalType, 1);
end

--比赛结束后战队排名
function Wlls:LeagueRank(nFinalType, nUpdateNews)
	local szPrimName = "Bảng xếp hạng Sơ cấp";
	local szAdvName	= "Bảng xếp hạng Cao cấp";
	if (GLOBAL_AGENT and GbWlls:CheckOpenGoldenGbWlls() == 1) then
		szPrimName = "Bảng xếp hạng Cao cấp";
		szAdvName = "Bảng xếp hạng Vô địch";
	end

	Wlls.nFinalLocalType = nFinalType or 0;	
	local nRankSession = KGblTask.SCGetDbTaskInt(Wlls.GTASK_MACTH_SESSION);
	if nFinalType == 1 then
		nRankSession = KGblTask.SCGetDbTaskInt(Wlls.GTASK_MACTH_LASTSESSION);
	end
	local tbMacthCfg = Wlls:GetMacthTypeCfg(Wlls:GetMacthType(nRankSession))
	local tbLogMemberCount = {[Wlls.MACTH_PRIM]={},[Wlls.MACTH_ADV]={}};
	--随机类型
	if tbMacthCfg.nMapLinkType == Wlls.MAP_LINK_TYPE_RANDOM then
		local pLeagueSet 	= KLeague.GetLeagueSetObject(Wlls.LGTYPE);
		local pLeagueItor 	= pLeagueSet.GetLeagueItor();
		local pLeague 		= pLeagueItor.GetCurLeague();
		self.RankLeagueList = {[Wlls.MACTH_PRIM]={},[Wlls.MACTH_ADV]={}};
		self.RankLeagueId = {[Wlls.MACTH_PRIM]=1,[Wlls.MACTH_ADV]=1};
		while(pLeague) do
			local nWin = pLeague.GetTask(self.LGTASK_WIN);
			local nTie = pLeague.GetTask(self.LGTASK_TIE);
			local nTotal = pLeague.GetTask(self.LGTASK_TOTAL);
			local nTime = pLeague.GetTask(self.LGTASK_TIME);
			local nSession = pLeague.GetTask(self.LGTASK_MSESSION);
			local nGameLevel = pLeague.GetTask(self.LGTASK_MLEVEL);
			local nAdvRank	= pLeague.GetTask(self.LGTASK_RANK_ADV);
			local nLoss = nTotal - nWin - nTie;
			local nPoint = nWin * Wlls.MACTH_POINT_WIN + nTie * Wlls.MACTH_POINT_TIE + nLoss * Wlls.MACTH_POINT_LOSS;
			if nSession == nRankSession and nTotal > 0 then
				table.insert(self.RankLeagueList[nGameLevel], {nSession = nSession, szName = pLeague.szName, nWin = nWin, nTie = nTie, nTotal = nTotal, nTime = nTime, nPoint = nPoint, nAdvRank = nAdvRank});
				--记录log
				local nMemberCount = League:GetMemberCount(Wlls.LGTYPE, pLeague.szName);
				if nMemberCount and not tbLogMemberCount[nGameLevel][nMemberCount] then
					tbLogMemberCount[nGameLevel][nMemberCount] = 0;
				end
				tbLogMemberCount[nGameLevel][nMemberCount] = tbLogMemberCount[nGameLevel][nMemberCount] + nMemberCount;
				
			end
			pLeague = pLeagueItor.NextLeague();
		end
		if #self.RankLeagueList[Wlls.MACTH_PRIM] > 0 then
			table.sort(self.RankLeagueList[Wlls.MACTH_PRIM], OnSort);
		end
		if #self.RankLeagueList[Wlls.MACTH_ADV] > 0 then
			table.sort(self.RankLeagueList[Wlls.MACTH_ADV], OnSort);
		end
		if (MODULE_GC_SERVER) then	
			--当届前10名入榜.
			Wlls:SetRankData(self.RankLeagueList[Wlls.MACTH_PRIM], tbMacthCfg.nMapLinkType, szPrimName, 0, Ladder.LADDER_CLASS_WLLS, 1, 0);
			Wlls:SetRankData(self.RankLeagueList[Wlls.MACTH_ADV], tbMacthCfg.nMapLinkType, szAdvName, 0, Ladder.LADDER_CLASS_WLLS, 2, 0);
			GlobalExcute{"Ladder:RefreshLadderName"};
		end
		-- 这个会有问题，在下下届前仔细思考一下，会无法清除上届榜
		if #self.RankLeagueList[Wlls.MACTH_PRIM] > 0 then
			Timer:Register(1, self.LeagueRankFrame, self, Wlls.MACTH_PRIM, tbMacthCfg.nMapLinkType, nFinalType)
		end
		if #self.RankLeagueList[Wlls.MACTH_ADV] > 0 then
			Timer:Register(1, self.LeagueRankFrame, self, Wlls.MACTH_ADV, tbMacthCfg.nMapLinkType, nFinalType)
		end
	end
	
	--五行类型
	if tbMacthCfg.nMapLinkType == Wlls.MAP_LINK_TYPE_SERIES then
		--未开发
		local pLeagueSet 	= KLeague.GetLeagueSetObject(Wlls.LGTYPE);
		local pLeagueItor 	= pLeagueSet.GetLeagueItor();
		local pLeague 		= pLeagueItor.GetCurLeague();
		self.RankLeagueList = {[Wlls.MACTH_PRIM]={},[Wlls.MACTH_ADV]={}};
		self.RankLeagueId = {[Wlls.MACTH_PRIM]=1,[Wlls.MACTH_ADV]=1};
		for i=1, 5 do
			self.RankLeagueList[Wlls.MACTH_PRIM][i] = {};
			self.RankLeagueList[Wlls.MACTH_ADV][i] = {};
		end
		while(pLeague) do
			local nWin = pLeague.GetTask(self.LGTASK_WIN);
			local nTie = pLeague.GetTask(self.LGTASK_TIE);
			local nTotal = pLeague.GetTask(self.LGTASK_TOTAL);
			local nTime = pLeague.GetTask(self.LGTASK_TIME);
			local nSession = pLeague.GetTask(self.LGTASK_MSESSION);
			local nGameLevel = pLeague.GetTask(self.LGTASK_MLEVEL);
			local nSereis = 0;
			local tbMember = Wlls:GetLeagueMemberList(pLeague.szName);
			if (tbMember) then
				nSereis	= League:GetMemberTask(Wlls.LGTYPE, pLeague.szName, tbMember[1], Wlls.LGMTASK_SERIES);
			end
			local nAdvRank	= pLeague.GetTask(self.LGTASK_RANK_ADV);
			local nLoss = nTotal - nWin - nTie;
			local nPoint = nWin * Wlls.MACTH_POINT_WIN + nTie * Wlls.MACTH_POINT_TIE + nLoss * Wlls.MACTH_POINT_LOSS;
			if nSession == nRankSession and nTotal > 0 then
				if not self.RankLeagueList[nGameLevel][nSereis] then
					self.RankLeagueList[nGameLevel][nSereis] = {};
				end
				table.insert(self.RankLeagueList[nGameLevel][nSereis], {nSession = nSession, szName = pLeague.szName, nWin = nWin, nTie = nTie, nTotal = nTotal, nTime = nTime, nPoint = nPoint, nAdvRank = nAdvRank});
				
				--记录log
				local nMemberCount = League:GetMemberCount(Wlls.LGTYPE, pLeague.szName);
				if nMemberCount and not tbLogMemberCount[nGameLevel][nMemberCount] then
					tbLogMemberCount[nGameLevel][nMemberCount] = 0;
				end
				tbLogMemberCount[nGameLevel][nMemberCount] = tbLogMemberCount[nGameLevel][nMemberCount] + nMemberCount;
			
			end
			pLeague = pLeagueItor.NextLeague();
		end
		for nSereis, tbLeagueList in pairs(self.RankLeagueList[Wlls.MACTH_PRIM]) do
			if #tbLeagueList > 0 then
				table.sort(self.RankLeagueList[Wlls.MACTH_PRIM][nSereis], OnSort);
			end
		end
		for nSereis, tbLeagueList in pairs(self.RankLeagueList[Wlls.MACTH_ADV]) do
			if #tbLeagueList > 0 then
				table.sort(self.RankLeagueList[Wlls.MACTH_ADV][nSereis], OnSort);
			end
		end
		
		if (MODULE_GC_SERVER) then	
			--当届前10名入榜.
			for nSereis=1, 5 do
				local szSereis = Env.SERIES_NAME[nSereis];
				local nLadderType	= Ladder:GetType(0, Ladder.LADDER_CLASS_WLLS, 1, nSereis);
				if (0 == CheckShowLadderExist(nLadderType)) then
					AddNewShowLadder(nLadderType);
				end
				Wlls:SetShowLadderName(szSereis, 0, Ladder.LADDER_CLASS_WLLS, 1, nSereis);
				
				nLadderType	= Ladder:GetType(0, Ladder.LADDER_CLASS_WLLS, 2, nSereis);
				if (0 == CheckShowLadderExist(nLadderType)) then
					AddNewShowLadder(nLadderType);
				end
				Wlls:SetShowLadderName(szSereis, 0, Ladder.LADDER_CLASS_WLLS, 2, nSereis);
			end
			
			for nSereis in pairs(self.RankLeagueList[Wlls.MACTH_PRIM]) do
				Wlls:SetRankData(self.RankLeagueList[Wlls.MACTH_PRIM][nSereis], tbMacthCfg.nMapLinkType, szPrimName, 0, Ladder.LADDER_CLASS_WLLS, 1, nSereis);
			end
			
			for nSereis in pairs(self.RankLeagueList[Wlls.MACTH_ADV]) do
			    Wlls:SetRankData(self.RankLeagueList[Wlls.MACTH_ADV][nSereis], tbMacthCfg.nMapLinkType, szAdvName, 0, Ladder.LADDER_CLASS_WLLS, 2, nSereis);
				-- Player:GetFactionRouteName(nFaction);
			end
			GlobalExcute{"Ladder:RefreshLadderName"};
		end

		Timer:Register(1, self.LeagueRankFrame, self, Wlls.MACTH_PRIM, tbMacthCfg.nMapLinkType, nFinalType)
		Timer:Register(1, self.LeagueRankFrame, self, Wlls.MACTH_ADV, tbMacthCfg.nMapLinkType, nFinalType)		
	end
	
	--门派类型
	if tbMacthCfg.nMapLinkType == Wlls.MAP_LINK_TYPE_FACTION then
		local pLeagueSet 	= KLeague.GetLeagueSetObject(Wlls.LGTYPE);
		local pLeagueItor 	= pLeagueSet.GetLeagueItor();
		local pLeague 		= pLeagueItor.GetCurLeague();
		self.RankLeagueList = {[Wlls.MACTH_PRIM]={},[Wlls.MACTH_ADV]={}};
		self.RankLeagueId = {[Wlls.MACTH_PRIM]=1,[Wlls.MACTH_ADV]=1};
		while(pLeague) do
			local nWin = pLeague.GetTask(self.LGTASK_WIN);
			local nTie = pLeague.GetTask(self.LGTASK_TIE);
			local nTotal = pLeague.GetTask(self.LGTASK_TOTAL);
			local nTime = pLeague.GetTask(self.LGTASK_TIME);
			local nSession = pLeague.GetTask(self.LGTASK_MSESSION);
			local nGameLevel = pLeague.GetTask(self.LGTASK_MLEVEL);
			local nFaction = 0;
			local tbMember = Wlls:GetLeagueMemberList(pLeague.szName);
			if (tbMember) then
				nFaction	= League:GetMemberTask(Wlls.LGTYPE, pLeague.szName, tbMember[1], Wlls.LGMTASK_FACTION);
			end
			local nAdvRank	= pLeague.GetTask(self.LGTASK_RANK_ADV);
			local nLoss = nTotal - nWin - nTie;
			local nPoint = nWin * Wlls.MACTH_POINT_WIN + nTie * Wlls.MACTH_POINT_TIE + nLoss * Wlls.MACTH_POINT_LOSS;
			if nSession == nRankSession and nTotal > 0 then
				if not self.RankLeagueList[nGameLevel][nFaction] then
					self.RankLeagueList[nGameLevel][nFaction] = {};
				end
				table.insert(self.RankLeagueList[nGameLevel][nFaction], {nSession = nSession, szName = pLeague.szName, nWin = nWin, nTie = nTie, nTotal = nTotal, nTime = nTime, nPoint = nPoint, nAdvRank = nAdvRank});
				
				--记录log
				local nMemberCount = League:GetMemberCount(Wlls.LGTYPE, pLeague.szName);
				if nMemberCount and not tbLogMemberCount[nGameLevel][nMemberCount] then
					tbLogMemberCount[nGameLevel][nMemberCount] = 0;
				end
				tbLogMemberCount[nGameLevel][nMemberCount] = tbLogMemberCount[nGameLevel][nMemberCount] + nMemberCount;
			
			end
			pLeague = pLeagueItor.NextLeague();
		end
		for nFaction, tbLeagueList in pairs(self.RankLeagueList[Wlls.MACTH_PRIM]) do
			if #tbLeagueList > 0 then
				table.sort(self.RankLeagueList[Wlls.MACTH_PRIM][nFaction], OnSort);
			end
		end
		for nFaction, tbLeagueList in pairs(self.RankLeagueList[Wlls.MACTH_ADV]) do
			if #tbLeagueList > 0 then
				table.sort(self.RankLeagueList[Wlls.MACTH_ADV][nFaction], OnSort);
			end
		end
		
		if (MODULE_GC_SERVER) then	
			--当届前10名入榜.
			for nFaction=1, Env.FACTION_NUM do
				local szFaction		= Wlls.LADDER_FACTIONNAME[nFaction];
				local nLadderType	= Ladder:GetType(0, Ladder.LADDER_CLASS_WLLS, 1, nFaction);
				if (0 == CheckShowLadderExist(nLadderType)) then
					AddNewShowLadder(nLadderType);
				end
				Wlls:SetShowLadderName(szFaction, 0, Ladder.LADDER_CLASS_WLLS, 1, nFaction);
				
				nLadderType	= Ladder:GetType(0, Ladder.LADDER_CLASS_WLLS, 2, nFaction);
				if (0 == CheckShowLadderExist(nLadderType)) then
					AddNewShowLadder(nLadderType);
				end
				Wlls:SetShowLadderName(szFaction, 0, Ladder.LADDER_CLASS_WLLS, 2, nFaction);
			end
			
			for nFaction in pairs(self.RankLeagueList[Wlls.MACTH_PRIM]) do
				Wlls:SetRankData(self.RankLeagueList[Wlls.MACTH_PRIM][nFaction], tbMacthCfg.nMapLinkType, szPrimName, 0, Ladder.LADDER_CLASS_WLLS, 1, nFaction);
			end
			
			for nFaction in pairs(self.RankLeagueList[Wlls.MACTH_ADV]) do
			    Wlls:SetRankData(self.RankLeagueList[Wlls.MACTH_ADV][nFaction], tbMacthCfg.nMapLinkType, szAdvName, 0, Ladder.LADDER_CLASS_WLLS, 2, nFaction);
				local szFaction = Wlls.LADDER_FACTIONNAME[nFaction];
				-- Player:GetFactionRouteName(nFaction);
			end
			GlobalExcute{"Ladder:RefreshLadderName"};
		end

		Timer:Register(1, self.LeagueRankFrame, self, Wlls.MACTH_PRIM, tbMacthCfg.nMapLinkType, nFinalType)
		Timer:Register(1, self.LeagueRankFrame, self, Wlls.MACTH_ADV, tbMacthCfg.nMapLinkType, nFinalType)
	end	
	
	--更新每周战报
	if nUpdateNews == 1 then
		Wlls:UpdateHelpNews(nRankSession, nFinalType);
	end
	
	--log统计
	if nFinalType == 1 then
		for nLevel, tbMemberCount in pairs(tbLogMemberCount) do
			for nCount, nSum in pairs(tbMemberCount) do
				Wlls:WriteLog(string.format("%s级联赛结束,队伍里面队员数量是%s的队伍数:%s", nLevel, nCount, nSum));
			end
		end
	end
end

--分帧存储
function Wlls:LeagueRankFrame(nGameLevel, nType, nFinalType)
	
	if nType == self.MAP_LINK_TYPE_RANDOM then
		local nCount = 0;
		for nRank = self.RankLeagueId[nGameLevel], #self.RankLeagueList[nGameLevel] do
			if nCount >= self.RankFrameCount then
				self.RankLeagueId[nGameLevel] = nRank;
				return 1;
			end
			League:SetLeagueTask(Wlls.LGTYPE, self.RankLeagueList[nGameLevel][nRank].szName, Wlls.LGTASK_RANK, nRank, 1);
			if (GLOBAL_AGENT and MODULE_GC_SERVER) then
				self:SetTeamPlayerRank(self.RankLeagueList[nGameLevel][nRank].szName, nRank, nFinalType);
			end
			if (MODULE_GC_SERVER) and nFinalType == 1 then
				--增加荣誉值.
				local nGameLevel = League:GetLeagueTask(Wlls.LGTYPE, self.RankLeagueList[nGameLevel][nRank].szName, Wlls.LGTASK_MLEVEL);
				local nSession = League:GetLeagueTask(Wlls.LGTYPE, self.RankLeagueList[nGameLevel][nRank].szName, Wlls.LGTASK_MSESSION);
				local nGameType = Wlls:GetMacthType(nSession)
				local nLevelSep = Wlls:GetAwardLevelSep(nGameLevel, nSession, nRank);
				if nLevelSep > 0 then
					if Wlls.AWARD_FINISH_LIST[nGameLevel][nSession][nLevelSep].honor then
						local nHonor = Wlls.AWARD_FINISH_LIST[nGameLevel][nSession][nLevelSep].honor[1];
						local tbMemberList = Wlls:GetLeagueMemberList(self.RankLeagueList[nGameLevel][nRank].szName);
						for _, szName in ipairs(tbMemberList) do
							Wlls:AddHonor(szName, nHonor);							
						end
					end
				end
				Wlls:WriteLog(string.format("%s届%s级最终联赛排名:战队:%s\t排名:%s", nSession, nGameLevel, self.RankLeagueList[nGameLevel][nRank].szName, nRank));
				
				if (not GLOBAL_AGENT) then
					local tbMemberList = Wlls:GetLeagueMemberList(self.RankLeagueList[nGameLevel][nRank].szName);
					for _, szName in ipairs(tbMemberList) do
						local nPlayerId = KGCPlayer.GetPlayerIdByName(szName);
						StatLog:WriteStatLog("stat_info", "local_wlls", "fight_award_output", nPlayerId, string.format("%s,%s,%s,%s,%s", nSession, nGameType, nGameLevel, self.RankLeagueList[nGameLevel][nRank].szName, nRank));
					end
				end
			end
			Wlls:WriteLog(string.format("%s级联赛排名:战队:%s\t排名:%s", nGameLevel, self.RankLeagueList[nGameLevel][nRank].szName, nRank));
			nCount = nCount + 1;
		end
		if (MODULE_GC_SERVER) then
			GlobalExcute({"Wlls:LeagueRank", nFinalType});
		end
	end
	
	if nType == self.MAP_LINK_TYPE_SERIES then
		--未开发
		local nCount = 0;
		for nSeries, tbLeagueList in pairs(self.RankLeagueList[nGameLevel]) do
			for nRank, tbLeagueInfo in ipairs(tbLeagueList) do
				League:SetLeagueTask(Wlls.LGTYPE, tbLeagueInfo.szName, Wlls.LGTASK_RANK, nRank, 1);
				if (GLOBAL_AGENT and MODULE_GC_SERVER) then
					self:SetTeamPlayerRank(tbLeagueInfo.szName, nRank, nFinalType);
				end				
				if (MODULE_GC_SERVER) and nFinalType == 1 then
					--增加荣誉值.
					local nGameLevel = League:GetLeagueTask(Wlls.LGTYPE, tbLeagueInfo.szName, Wlls.LGTASK_MLEVEL);
					local nSession = League:GetLeagueTask(Wlls.LGTYPE, tbLeagueInfo.szName, Wlls.LGTASK_MSESSION);
					local nGameType = Wlls:GetMacthType(nSession)
					local nLevelSep = Wlls:GetAwardLevelSep(nGameLevel, nSession, nRank);
					if nLevelSep > 0 then
						if Wlls.AWARD_FINISH_LIST[nGameLevel][nSession][nLevelSep].honor then
							local nHonor = Wlls.AWARD_FINISH_LIST[nGameLevel][nSession][nLevelSep].honor[1];
							local tbMemberList = Wlls:GetLeagueMemberList(tbLeagueInfo.szName);
							for _, szName in ipairs(tbMemberList) do
								Wlls:AddHonor(szName, nHonor);
							end
						end
					end

					if (not GLOBAL_AGENT) then
						local tbMemberList = Wlls:GetLeagueMemberList(tbLeagueInfo.szName);
						for _, szName in ipairs(tbMemberList) do
							local nPlayerId = KGCPlayer.GetPlayerIdByName(szName);
							StatLog:WriteStatLog("stat_info", "local_wlls", "fight_award_output", nPlayerId, string.format("%s,%s,%s,%s,%s", nSession, nGameType, nGameLevel, tbLeagueInfo.szName, nRank));
						end
					end

					Wlls:WriteLog(string.format("%s届%s级最终联赛排名:战队:%s\t排名:%s", nSession, nGameLevel, tbLeagueInfo.szName, nRank));
				end
				Wlls:WriteLog(string.format("%s级联赛排名:战队:%s\t排名:%s", nGameLevel, tbLeagueInfo.szName, nRank));
			end
		end
		if (MODULE_GC_SERVER) then
			GlobalExcute({"Wlls:LeagueRank", nFinalType});
		end
	end
	
	if nType == self.MAP_LINK_TYPE_FACTION then
		local nCount = 0;
		for nFaction, tbLeagueList in pairs(self.RankLeagueList[nGameLevel]) do
			for nRank, tbLeagueInfo in ipairs(tbLeagueList) do
				League:SetLeagueTask(Wlls.LGTYPE, tbLeagueInfo.szName, Wlls.LGTASK_RANK, nRank, 1);
				if (GLOBAL_AGENT and MODULE_GC_SERVER) then
					self:SetTeamPlayerRank(tbLeagueInfo.szName, nRank, nFinalType);
				end
				if (MODULE_GC_SERVER) and nFinalType == 1 then
					--增加荣誉值.
					local nGameLevel = League:GetLeagueTask(Wlls.LGTYPE, tbLeagueInfo.szName, Wlls.LGTASK_MLEVEL);
					local nSession = League:GetLeagueTask(Wlls.LGTYPE, tbLeagueInfo.szName, Wlls.LGTASK_MSESSION);
					local nGameType = Wlls:GetMacthType(nSession)
					local nLevelSep = Wlls:GetAwardLevelSep(nGameLevel, nSession, nRank);
					if nLevelSep > 0 then
						if Wlls.AWARD_FINISH_LIST[nGameLevel][nSession][nLevelSep].honor then
							local nHonor = Wlls.AWARD_FINISH_LIST[nGameLevel][nSession][nLevelSep].honor[1];
							local tbMemberList = Wlls:GetLeagueMemberList(tbLeagueInfo.szName);
							for _, szName in ipairs(tbMemberList) do
								Wlls:AddHonor(szName, nHonor);
							end
						end
					end

					if (not GLOBAL_AGENT) then
						local tbMemberList = Wlls:GetLeagueMemberList(tbLeagueInfo.szName);
						for _, szName in ipairs(tbMemberList) do
							local nPlayerId = KGCPlayer.GetPlayerIdByName(szName);
							StatLog:WriteStatLog("stat_info", "local_wlls", "fight_award_output", nPlayerId, string.format("%s,%s,%s,%s,%s", nSession, nGameType, nGameLevel, tbLeagueInfo.szName, nRank));
						end
					end

					Wlls:WriteLog(string.format("%s届%s级最终联赛排名:战队:%s\t排名:%s", nSession, nGameLevel, tbLeagueInfo.szName, nRank));
				end
				Wlls:WriteLog(string.format("%s级联赛排名:战队:%s\t排名:%s", nGameLevel, tbLeagueInfo.szName, nRank));
			end
		end
		if (MODULE_GC_SERVER) then
			GlobalExcute({"Wlls:LeagueRank", nFinalType});
		end
	end

	if (MODULE_GC_SERVER) and nFinalType == 1 then
		local szLastPrimName = "Bảng xếp hạng Sơ cấp";
		local szLastAdvName	= "Bảng xếp hạng Cao cấp";
		if (GLOBAL_AGENT and GbWlls:CheckOpenGoldenGbWlls() == 1) then
			szLastPrimName = "Bảng xếp hạng Cao cấp";
			szLastAdvName = "Bảng xếp hạng Vô địch";
		end
		local nNowLadderType 	= 0;
		local nLastLadderType 	= 0;
		local szTitle			= "";
		if (Wlls.MACTH_PRIM == nGameLevel) then
			nNowLadderType		= 1;
			nLastLadderType		= 4;
			szTitle = szLastPrimName;
		else
			nNowLadderType		= 2;
			nLastLadderType		= 5;
			szTitle = szLastAdvName;		
		end
		--清除上届排行榜
		for i=0, Env.FACTION_NUM do
			if GetShowLadder(Ladder:GetType(0, Ladder.LADDER_CLASS_WLLS, nLastLadderType, i)) then
				DelShowLadder(Ladder:GetType(0, Ladder.LADDER_CLASS_WLLS, nLastLadderType, i));
			end
		end
		
		--把当届排行保存到上届排行,并清除当届榜
		for i=0, Env.FACTION_NUM do
			local nNowLadderType	= Ladder:GetType(0, Ladder.LADDER_CLASS_WLLS, nNowLadderType, i);
			local nLastLadderType	= Ladder:GetType(0, Ladder.LADDER_CLASS_WLLS, nLastLadderType, i);
			
			local tbNowLadder = GetShowLadder(nNowLadderType);
			if tbNowLadder then
				SetShowLadder(nLastLadderType, szTitle, string.len(szTitle)+1, tbNowLadder);
				local szName = GetShowLadderName(nNowLadderType);
				if (szName and string.len(szName) > 0) then
					if (0 == CheckShowLadderExist(nLastLadderType)) then
						AddNewShowLadder(nLastLadderType);
					end					
					SetShowLadderName(nLastLadderType, szName, string.len(szName) + 1);
				end
				DelShowLadder(nNowLadderType);
			end
		end
		GlobalExcute{"Ladder:RefreshLadderName"};
		
		--手动更新荣誉排行..
		local nLadderId = Ladder:GetType(0, Ladder.LADDER_CLASS_WLLS, 3, 0)
		RefreshHonorLadderData(nLadderId, 3, 0);
		Wlls:UpdateWllsHonorLadder();
	end
	if nFinalType == 1 then
		Wlls.AdvMatchLists = {};
	end
	return 0;
end

function Wlls:SetFactionElectPlayer()
	-- 判断是都已经开启联赛且已经进行了一届了
	local nLastRankSession = KGblTask.SCGetDbTaskInt(Wlls.GTASK_MACTH_LASTSESSION);
	if (nLastRankSession <= 0) then
		return;
	end
	if (GLOBAL_AGENT) then
		return 0;
	end
	--门派大师兄选取候选人名单。
	for nFaction = 1, Env.FACTION_NUM do
		local tbLadder = GetShowLadder(Ladder:GetType(0, 4, 1, nFaction));
		if tbLadder then
			for _, tbInfo in pairs(tbLadder) do
				local nPlayerId = KGCPlayer.GetPlayerIdByName(tbInfo.szName);
				if nPlayerId and nPlayerId > 0 then
					SetCurCandidate(nFaction, nPlayerId);
					-- by zhangjinpin@kingsoft
					KGCPlayer.SetPlayerPrestige(nPlayerId, KGCPlayer.GetPlayerPrestige(nPlayerId) + 100);
					Dbg:WriteLog("Wlls", "门派大师兄候选人", tbInfo.szName, "增加江湖威望100点");
					-- end
				end
			end
		end
	end
end

--比赛开始前,清除不同赛制不同届建立的战队.
function Wlls:LeagueClearSession()
	local pLeagueSet 	= KLeague.GetLeagueSetObject(Wlls.LGTYPE);
	local pLeagueItor 	= pLeagueSet.GetLeagueItor();
	local pLeague 		= pLeagueItor.GetCurLeague();
	self.ClsLeagueList = {};
	self.ClsLeagueId = 1;
	while(pLeague) do
		if (pLeague.GetTask(Wlls.LGTASK_MTYPE) ~= self:GetMacthType() or 
		pLeague.GetTask(Wlls.LGTASK_MSESSION) ~= self:GetMacthSession()) then
			table.insert(self.ClsLeagueList, pLeague.szName);
		end
		pLeague = pLeagueItor.NextLeague();
	end

	if #self.ClsLeagueList > 0 then
		Timer:Register(1, self.LeagueClearSessionFrame, self)
	end
end

function Wlls:LeagueClearSessionFrame()
	local nCount = 0;
	for nRank = self.ClsLeagueId, #self.ClsLeagueList do
		if nCount >= self.RankFrameCount then
			self.ClsLeagueId = nRank;
			return 1;
		end
		League:DelLeague(Wlls.LGTYPE, self.ClsLeagueList[nRank], 1);
		nCount = nCount + 1;
	end
	if (MODULE_GC_SERVER) then
		GlobalExcute({"Wlls:LeagueClearSession"});
	end
	return 0;
end

function Wlls:LoadWllsRank()
	Wlls.nFinalLocalType	= 0;
	local nMatchState		= Wlls:GetMacthState();
	local nFinalType		= 0;
	if (nMatchState ~= Wlls.DEF_STATE_MATCH and nMatchState ~= Wlls.DEF_STATE_ADVMATCH) then
		return;
	end
	local nRankSession	= KGblTask.SCGetDbTaskInt(Wlls.GTASK_MACTH_SESSION);
	local tbMacthCfg	= Wlls:GetMacthTypeCfg(Wlls:GetMacthType(nRankSession))
	--随机类型
	if tbMacthCfg.nMapLinkType == Wlls.MAP_LINK_TYPE_RANDOM then
		local pLeagueSet 	= KLeague.GetLeagueSetObject(Wlls.LGTYPE);
		local pLeagueItor 	= pLeagueSet.GetLeagueItor();
		local pLeague 		= pLeagueItor.GetCurLeague();
		self.RankLeagueList = {[Wlls.MACTH_PRIM]={},[Wlls.MACTH_ADV]={}};
		self.RankLeagueId = {[Wlls.MACTH_PRIM]=1,[Wlls.MACTH_ADV]=1};
		while(pLeague) do
			local nWin = pLeague.GetTask(self.LGTASK_WIN);
			local nTie = pLeague.GetTask(self.LGTASK_TIE);
			local nTotal = pLeague.GetTask(self.LGTASK_TOTAL);
			local nTime = pLeague.GetTask(self.LGTASK_TIME);
			local nSession = pLeague.GetTask(self.LGTASK_MSESSION);
			local nGameLevel = pLeague.GetTask(self.LGTASK_MLEVEL);
			local nAdvRank	= pLeague.GetTask(self.LGTASK_RANK_ADV);
			local nLoss = nTotal - nWin - nTie;
			local nPoint = nWin * Wlls.MACTH_POINT_WIN + nTie * Wlls.MACTH_POINT_TIE + nLoss * Wlls.MACTH_POINT_LOSS;
			if nSession == nRankSession and nTotal > 0 then
				table.insert(self.RankLeagueList[nGameLevel], {nSession = nSession, szName = pLeague.szName, nWin = nWin, nTie = nTie, nTotal = nTotal, nTime = nTime, nPoint = nPoint, nAdvRank = nAdvRank});				
			end
			pLeague = pLeagueItor.NextLeague();
		end
		if #self.RankLeagueList[Wlls.MACTH_PRIM] > 0 then
			table.sort(self.RankLeagueList[Wlls.MACTH_PRIM], OnSort);
		end
		if #self.RankLeagueList[Wlls.MACTH_ADV] > 0 then
			table.sort(self.RankLeagueList[Wlls.MACTH_ADV], OnSort);
		end
		
		if #self.RankLeagueList[Wlls.MACTH_PRIM] > 0 then
			Timer:Register(1, self.LeagueRankFrame, self, Wlls.MACTH_PRIM, tbMacthCfg.nMapLinkType, nFinalType)
		end
		if #self.RankLeagueList[Wlls.MACTH_ADV] > 0 then
			Timer:Register(1, self.LeagueRankFrame, self, Wlls.MACTH_ADV, tbMacthCfg.nMapLinkType, nFinalType)
		end
	end
	
	--五行类型
	if tbMacthCfg.nMapLinkType == Wlls.MAP_LINK_TYPE_SERIES then
		--未开发
		local pLeagueSet 	= KLeague.GetLeagueSetObject(Wlls.LGTYPE);
		local pLeagueItor 	= pLeagueSet.GetLeagueItor();
		local pLeague 		= pLeagueItor.GetCurLeague();
		self.RankLeagueList = {[Wlls.MACTH_PRIM]={},[Wlls.MACTH_ADV]={}};
		self.RankLeagueId = {[Wlls.MACTH_PRIM]=1,[Wlls.MACTH_ADV]=1};
		while(pLeague) do
			local nWin = pLeague.GetTask(self.LGTASK_WIN);
			local nTie = pLeague.GetTask(self.LGTASK_TIE);
			local nTotal = pLeague.GetTask(self.LGTASK_TOTAL);
			local nTime = pLeague.GetTask(self.LGTASK_TIME);
			local nSession = pLeague.GetTask(self.LGTASK_MSESSION);
			local nGameLevel = pLeague.GetTask(self.LGTASK_MLEVEL);
			local nSeries = 0;
			local tbMember = Wlls:GetLeagueMemberList(pLeague.szName);
			if (tbMember) then
				nSeries	= League:GetMemberTask(Wlls.LGTYPE, pLeague.szName, tbMember[1], Wlls.LGMTASK_SERIES);
			end
			local nAdvRank	= pLeague.GetTask(self.LGTASK_RANK_ADV);
			local nLoss = nTotal - nWin - nTie;
			local nPoint = nWin * Wlls.MACTH_POINT_WIN + nTie * Wlls.MACTH_POINT_TIE + nLoss * Wlls.MACTH_POINT_LOSS;
			if nSession == nRankSession and nTotal > 0 then
				if not self.RankLeagueList[nGameLevel][nSeries] then
					self.RankLeagueList[nGameLevel][nSeries] = {};
				end
				table.insert(self.RankLeagueList[nGameLevel][nSeries], {nSession = nSession, szName = pLeague.szName, nWin = nWin, nTie = nTie, nTotal = nTotal, nTime = nTime, nPoint = nPoint, nAdvRank = nAdvRank});
			end
			pLeague = pLeagueItor.NextLeague();
		end
		for nSeries, tbLeagueList in pairs(self.RankLeagueList[Wlls.MACTH_PRIM]) do
			if #tbLeagueList > 0 then
				table.sort(self.RankLeagueList[Wlls.MACTH_PRIM][nSeries], OnSort);
			end
		end
		for nSeries, tbLeagueList in pairs(self.RankLeagueList[Wlls.MACTH_ADV]) do
			if #tbLeagueList > 0 then
				table.sort(self.RankLeagueList[Wlls.MACTH_ADV][nSeries], OnSort);
			end
		end

		Timer:Register(1, self.LeagueLoadRankFrame, self, Wlls.MACTH_PRIM, tbMacthCfg.nMapLinkType, nFinalType)
		Timer:Register(1, self.LeagueLoadRankFrame, self, Wlls.MACTH_ADV, tbMacthCfg.nMapLinkType, nFinalType)
	end
	
	--门派类型
	if tbMacthCfg.nMapLinkType == Wlls.MAP_LINK_TYPE_FACTION then
		local pLeagueSet 	= KLeague.GetLeagueSetObject(Wlls.LGTYPE);
		local pLeagueItor 	= pLeagueSet.GetLeagueItor();
		local pLeague 		= pLeagueItor.GetCurLeague();
		self.RankLeagueList = {[Wlls.MACTH_PRIM]={},[Wlls.MACTH_ADV]={}};
		self.RankLeagueId = {[Wlls.MACTH_PRIM]=1,[Wlls.MACTH_ADV]=1};
		while(pLeague) do
			local nWin = pLeague.GetTask(self.LGTASK_WIN);
			local nTie = pLeague.GetTask(self.LGTASK_TIE);
			local nTotal = pLeague.GetTask(self.LGTASK_TOTAL);
			local nTime = pLeague.GetTask(self.LGTASK_TIME);
			local nSession = pLeague.GetTask(self.LGTASK_MSESSION);
			local nGameLevel = pLeague.GetTask(self.LGTASK_MLEVEL);
			local nFaction = 0;
			local tbMember = Wlls:GetLeagueMemberList(pLeague.szName);
			if (tbMember) then
				nFaction	= League:GetMemberTask(Wlls.LGTYPE, pLeague.szName, tbMember[1], Wlls.LGMTASK_FACTION);
			end
			local nAdvRank	= pLeague.GetTask(self.LGTASK_RANK_ADV);
			local nLoss = nTotal - nWin - nTie;
			local nPoint = nWin * Wlls.MACTH_POINT_WIN + nTie * Wlls.MACTH_POINT_TIE + nLoss * Wlls.MACTH_POINT_LOSS;
			if nSession == nRankSession and nTotal > 0 then
				if not self.RankLeagueList[nGameLevel][nFaction] then
					self.RankLeagueList[nGameLevel][nFaction] = {};
				end
				table.insert(self.RankLeagueList[nGameLevel][nFaction], {nSession = nSession, szName = pLeague.szName, nWin = nWin, nTie = nTie, nTotal = nTotal, nTime = nTime, nPoint = nPoint, nAdvRank = nAdvRank});
			end
			pLeague = pLeagueItor.NextLeague();
		end
		for nFaction, tbLeagueList in pairs(self.RankLeagueList[Wlls.MACTH_PRIM]) do
			if #tbLeagueList > 0 then
				table.sort(self.RankLeagueList[Wlls.MACTH_PRIM][nFaction], OnSort);
			end
		end
		for nFaction, tbLeagueList in pairs(self.RankLeagueList[Wlls.MACTH_ADV]) do
			if #tbLeagueList > 0 then
				table.sort(self.RankLeagueList[Wlls.MACTH_ADV][nFaction], OnSort);
			end
		end

		Timer:Register(1, self.LeagueLoadRankFrame, self, Wlls.MACTH_PRIM, tbMacthCfg.nMapLinkType, nFinalType)
		Timer:Register(1, self.LeagueLoadRankFrame, self, Wlls.MACTH_ADV, tbMacthCfg.nMapLinkType, nFinalType)
	end	

end

--分帧存储
function Wlls:LeagueLoadRankFrame(nGameLevel, nType, nFinalType)
	if nType == self.MAP_LINK_TYPE_RANDOM then
		local nCount = 0;
		for nRank = self.RankLeagueId[nGameLevel], #self.RankLeagueList[nGameLevel] do
			if nCount >= self.RankFrameCount then
				self.RankLeagueId[nGameLevel] = nRank;
				return 1;
			end
			League:SetLeagueTask(Wlls.LGTYPE, self.RankLeagueList[nGameLevel][nRank].szName, Wlls.LGTASK_RANK, nRank, 1);
			if (GLOBAL_AGENT and MODULE_GC_SERVER) then
				self:SetTeamPlayerRank(self.RankLeagueList[nGameLevel][nRank].szName, nRank, nFinalType);
			end
			
			nCount = nCount + 1;
		end
	end
	
	if nType == self.MAP_LINK_TYPE_SERIES then
		--未开发
		local nCount = 0;
		for nSereis, tbLeagueList in pairs(self.RankLeagueList[nGameLevel]) do
			for nRank, tbLeagueInfo in ipairs(tbLeagueList) do
				League:SetLeagueTask(Wlls.LGTYPE, tbLeagueInfo.szName, Wlls.LGTASK_RANK, nRank, 1);
				if (GLOBAL_AGENT and MODULE_GC_SERVER) then
					self:SetTeamPlayerRank(tbLeagueInfo.szName, nRank, nFinalType);
				end				
			end
		end		
	end
	
	if nType == self.MAP_LINK_TYPE_FACTION then
		local nCount = 0;
		for nFaction, tbLeagueList in pairs(self.RankLeagueList[nGameLevel]) do
			for nRank, tbLeagueInfo in ipairs(tbLeagueList) do
				League:SetLeagueTask(Wlls.LGTYPE, tbLeagueInfo.szName, Wlls.LGTASK_RANK, nRank, 1);
				if (GLOBAL_AGENT and MODULE_GC_SERVER) then
					self:SetTeamPlayerRank(tbLeagueInfo.szName, nRank, nFinalType);
				end
			end
		end
	end
	return 0;
end

function Wlls:GetLadderPart(nLadderType, nStart, nLength)
	local nMatchState		= Wlls:GetMacthState();
	if (nMatchState ~= Wlls.DEF_STATE_MATCH and nMatchState ~= Wlls.DEF_STATE_ADVMATCH) then
		return;
	end
	local nRankSession	= KGblTask.SCGetDbTaskInt(Wlls.GTASK_MACTH_SESSION);
	local tbMacthCfg	= Wlls:GetMacthTypeCfg(Wlls:GetMacthType(nRankSession))	
	
	local tbLadder	= {};
	local nMaxList	= 0;
	local _, nClass, nType, nNum = Ladder:GetClassByType(nLadderType);
	local nGameLevel = nType;

	if (not self.RankLeagueList) then
		return;
	end

	if (not self.RankLeagueList[nGameLevel]) then
		return;
	end

	local tbList	= {};
	if tbMacthCfg.nMapLinkType == self.MAP_LINK_TYPE_RANDOM then
		tbList	= self.RankLeagueList[nGameLevel];
	end
	
	if tbMacthCfg.nMapLinkType == self.MAP_LINK_TYPE_SERIES then
		--未开发
		tbList	= self.RankLeagueList[nGameLevel][nNum];
	end
	
	if tbMacthCfg.nMapLinkType == self.MAP_LINK_TYPE_FACTION then
		tbList	= self.RankLeagueList[nGameLevel][nNum];
	end
	
	if (not tbList or #tbList <= 0) then
		return;
	end
	nMaxList		= #tbList;
	local nMaxNum	= math.min(math.min(5000, nStart + nLength - 1), nMaxList);
	
	if (nStart > nMaxNum) then
		return;
	end
	for i=nStart, nMaxNum do
		local tbInfo		= tbList[i];
		local tbTmp 		= {};
		tbTmp.dwValue		= tbInfo.nPoint;
		tbTmp.szPlayerName	= tbInfo.szName;
		tbLadder[#tbLadder + 1] = tbTmp;
	end
	return tbLadder, nMaxList;
end

function Wlls:GetWllsLadderRankByName(nLadderType, szName, nSearchType)
	local nMatchState		= Wlls:GetMacthState();
	if (nMatchState ~= Wlls.DEF_STATE_MATCH and nMatchState ~= Wlls.DEF_STATE_ADVMATCH) then
		return 0;
	end
	local nRankSession	= KGblTask.SCGetDbTaskInt(Wlls.GTASK_MACTH_SESSION);
	local tbMacthCfg	= Wlls:GetMacthTypeCfg(Wlls:GetMacthType(nRankSession))	
	
	local tbLadder	= {};
	local nMaxList	= 0;
	local nRank		= 0;
	local _, nClass, nType, nNum = Ladder:GetClassByType(nLadderType);
	local nGameLevel = nType;
	
	if (not self.RankLeagueList) then
		return nRank;
	end
	
	if (not self.RankLeagueList[nGameLevel]) then
		return nRank;
	end
	
	local tbList	= {};
	if tbMacthCfg.nMapLinkType == self.MAP_LINK_TYPE_RANDOM then
		tbList	= self.RankLeagueList[nGameLevel];
	end
	
	if tbMacthCfg.nMapLinkType == self.MAP_LINK_TYPE_SERIES then
		--未开发
		tbList	= self.RankLeagueList[nGameLevel][nNum];
	end
	
	if tbMacthCfg.nMapLinkType == self.MAP_LINK_TYPE_FACTION then
		tbList	= self.RankLeagueList[nGameLevel][nNum];
	end
	
	if (not tbList or #tbList <= 0) then
		return nRank;
	end
	
	nMaxList			= #tbList;
	local nMaxNum		= math.min(5000, nMaxList);
	local szTeamName	= nil;
	
	if (Ladder.SEARCHTYPE_PLAYERNAME == nSearchType) then
		szTeamName	= League:GetMemberLeague(Wlls.LGTYPE, szName);
	elseif (Ladder.SEARCHTYPE_WLLSTEAMNAME == nSearchType) then
		szTeamName	= szName;
	end
	
	if (not szTeamName) then
		return nRank;
	end	

	-- 这里是全搜索的不过也可以根据战队的信息进行搜索 
	for i=1, nMaxNum do
		local tbInfo = tbList[i];
		if (tbInfo.szName == szTeamName) then
			nRank = i;
			break;
		end
	end
	return nRank;
end

function Wlls:Test_SetTeamWin(szName, nCount)
	local szLeagueName = League:GetMemberLeague(Wlls.LGTYPE, szName);
	if not szLeagueName then
		return 0;
	end	
	League:SetLeagueTask(Wlls.LGTYPE,szLeagueName,Wlls.LGTASK_WIN,nCount);
	if (GLOBAL_AGENT) then
		self:SetTeamPlayerSportValue(szLeagueName, GbWlls.GBTASKID_MATCH_WIN_AWARD, nCount);
	end
end

function Wlls:Test_SetTeamTotal(szName, nCount)
	local szLeagueName = League:GetMemberLeague(Wlls.LGTYPE, szName);
	if not szLeagueName then
		return 0;
	end	
	League:SetLeagueTask(Wlls.LGTYPE,szLeagueName,Wlls.LGTASK_TOTAL,nCount);
end

function Wlls:Test_SetTeamTie(szName, nCount)
	local szLeagueName = League:GetMemberLeague(Wlls.LGTYPE, szName);
	if not szLeagueName then
		return 0;
	end	
	League:SetLeagueTask(Wlls.LGTYPE,szLeagueName,Wlls.LGTASK_TIE,nCount);
	if (GLOBAL_AGENT) then
		self:SetTeamPlayerSportValue(szLeagueName, GbWlls.GBTASKID_MATCH_TIE_AWARD, nCount);
	end
end

function Wlls:Test_SetTeamRank(szName, nRank)
	local szLeagueName = League:GetMemberLeague(Wlls.LGTYPE, szName);
	if not szLeagueName then
		return 0;
	end	
	League:SetLeagueTask(Wlls.LGTYPE,szLeagueName,Wlls.LGTASK_RANK,nRank);
end

function Wlls:Test_SetTeamLost(szName, nCount)
	if (GLOBAL_AGENT) then
		self:SetTeamPlayerSportValue(szLeagueName, GbWlls.GBTASKID_MATCH_LOSE_AWARD, nCount);
	end
end

if (MODULE_GC_SERVER) then
	GCEvent:RegisterGCServerStartFunc(Wlls.LoadWllsRank, Wlls);
end

if (MODULE_GAMESERVER) then
	ServerEvent:RegisterServerStartFunc(Wlls.LoadWllsRank, Wlls);
end
