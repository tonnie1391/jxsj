--活动-战队操作
--zhouchenfei
--2009.08.13

function EPlatForm:CreateLeague(tbMemberList, szLeagueName, nExParam)
	if League:FindLeague(self.LGTYPE, szLeagueName) then
		return 0;
	end
	local nSync = 1;
	League:AddLeague(self.LGTYPE, szLeagueName, 1);
	League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_MSESSION, self:GetMacthSession(), nSync);
	League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_MTYPE, self:GetMacthType(), nSync);
	League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_MEXPARAM, nExParam, nSync);
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
	League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_DALIYCOUNT, 2, nSync);
	League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_DALIYCHANGETIME, GetTime(), nSync);
	
	local nIsHaveCap = 0;
	 -- 寻找队长
	for nId, tbPlayer in ipairs(tbMemberList) do
		if (not tbPlayer.nCaptain) then
			tbPlayer.nCaptain = 0;
		end
		
		if (tbPlayer.nCaptain == 1) then
			nIsHaveCap = 1;
			break;
		end
	end
	
	-- 队长不在任命第一个人为队长
	if (0 == nIsHaveCap) then
		for nId, tbPlayer in ipairs(tbMemberList) do
			if (tbPlayer) then
				tbPlayer.nCaptain = 1;
				break;
			end
		end
	end
	
	for nId, tbPlayer in ipairs(tbMemberList) do
		League:AddMember(self.LGTYPE, szLeagueName, tbPlayer.szName, nSync)

		League:SetMemberTask(self.LGTYPE, szLeagueName, tbPlayer.szName, self.LGMTASK_JOB, 		tbPlayer.nCaptain, 	nSync);
		League:SetMemberTask(self.LGTYPE, szLeagueName, tbPlayer.szName, self.LGMTASK_FACTION, 	tbPlayer.nFaction, 	nSync);
		League:SetMemberTask(self.LGTYPE, szLeagueName, tbPlayer.szName, self.LGMTASK_ROUTEID, 	tbPlayer.nRouteId, 	nSync);
		League:SetMemberTask(self.LGTYPE, szLeagueName, tbPlayer.szName, self.LGMTASK_CAMP, 	0, 	nSync);
		League:SetMemberTask(self.LGTYPE, szLeagueName, tbPlayer.szName, self.LGMTASK_SEX, 	  	tbPlayer.nSex, 		nSync);
		League:SetMemberTask(self.LGTYPE, szLeagueName, tbPlayer.szName, self.LGMTASK_SERIES,  	tbPlayer.nSeries, 	nSync);
	end
	
	if (MODULE_GC_SERVER) then
		GlobalExcute{"EPlatForm:CreateLeague", tbMemberList, szLeagueName, nExParam};

		local szLog = "";
		local szMemberNameList = "";
		local nFlag = 0;
		for nId, tbPlayer in ipairs(tbMemberList) do
			if (nFlag > 0) then
				szMemberNameList = szMemberNameList .. ",";
			end
			nFlag = 1;
			szMemberNameList = szMemberNameList .. tbPlayer.szName;
		end
		szLog = string.format("%s,%s,%s", szLeagueName, #tbMemberList, szMemberNameList);
		StatLog:WriteStatLog("stat_info", "kin_game", "buildup", 0, szLog);		
	end
	return 1;
end

function EPlatForm:CreateTempLeague(tbMemberList, szLeagueName, nExParam)
	if League:FindLeague(self.LGTYPE, szLeagueName) then
		return 0;
	end
	local nSync = 1;
	League:AddLeague(self.LGTYPE, szLeagueName, 1);
	League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_MSESSION, self:GetMacthSession(), nSync);
	League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_MTYPE, 0, nSync);
	
	for nId, tbPlayer in ipairs(tbMemberList) do
		League:AddMember(self.LGTYPE, szLeagueName, tbPlayer.szName, nSync)
		local nCaptain = 0;
		if nId == 1 then
			nCaptain = 1;
		end
		League:SetMemberTask(self.LGTYPE, szLeagueName, tbPlayer.szName, self.LGMTASK_JOB, nCaptain, nSync);
	end
	
	if (MODULE_GC_SERVER) then
		GlobalExcute{"EPlatForm:CreateTempLeague", tbMemberList, szLeagueName, nExParam};
	end
end

-- 从数据库中获取所有战队的信息
function EPlatForm:_GetMatchLeague()
	print("Get Platform start.......");
	local nLgType		= self.LGTYPE;
	local pLeagueSet 	= KLeague.GetLeagueSetObject(nLgType);
	local pLeagueItor 	= pLeagueSet.GetLeagueItor();
	local pLeague 		= pLeagueItor.GetCurLeague();
	local tbLeagueList 	= {};
	local tbPlatformList = {};
	local nMemberCount		= 0;
	local nRealMemberCount	= 0;
	while(pLeague) do
		table.insert(tbLeagueList, pLeague.szName);
		nMemberCount = nMemberCount + 1;
		local szName = pLeague.szName;
		local tbOneLeague = self:_GetWllsOneLeagueInfo(nLgType, szName);
		if (tbOneLeague) then
			tbPlatformList[szName] = tbOneLeague;
			nRealMemberCount = nRealMemberCount + 1;
		end
		pLeague = pLeagueItor.NextLeague();
	end
	-- 先注释如果要删除的话把注释去了
--	for ni, szLeagueName in pairs(tbLeagueList) do
--		League:DelLeague(nLgType, szLeagueName, 1);
--	end

	print("Get EPlatForm League from database number is " .. nMemberCount .. " , real get the League number is " .. nRealMemberCount);
	print("Get Platform end.......");
	return tbPlatformList;
end

-- 从数据库中获取一个战队的信息
function EPlatForm:_GetMatchOneLeagueInfo(nLgType, szLeagueName)
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
function EPlatForm:_SetMatchLeague(nLgType, tbPlatformList)
	print("Set Platform start.......");
	if (not tbPlatformList) then
		print("The tbPlatformList is not exist!!!!!");
		return;
	end
	for szName, tbOneLeague in pairs(tbPlatformList) do
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
	print("Set Platform end.......");
end

-- 获取战队名
function EPlatForm:_GetRightName(nLgType, szName)
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

function EPlatForm:JoinLeague(szLeagueName, tbJoinPlayerIdList)
	if (not szLeagueName or not tbJoinPlayerIdList) then
		return 0;
	end

	if not League:FindLeague(self.LGTYPE, szLeagueName) then
		return 0;
	end	

	for _, tbPlayer in pairs(tbJoinPlayerIdList) do
		local szName = tbPlayer.szName;
		if szName and not League:GetMemberLeague(self.LGTYPE, szName) then
			League:AddMember(self.LGTYPE, szLeagueName, szName, 1);
			League:SetMemberTask(self.LGTYPE, szLeagueName, szName, self.LGMTASK_FACTION, tbPlayer.nFaction, 1);
			League:SetMemberTask(self.LGTYPE, szLeagueName, szName, self.LGMTASK_ROUTEID, tbPlayer.nRouteId, 1);
			League:SetMemberTask(self.LGTYPE, szLeagueName, szName, self.LGMTASK_CAMP, 	  0, 1);
			League:SetMemberTask(self.LGTYPE, szLeagueName, szName, self.LGMTASK_SEX, 	  tbPlayer.nSex, 1);
			League:SetMemberTask(self.LGTYPE, szLeagueName, szName, self.LGMTASK_SERIES,  tbPlayer.nSeries, 1);
		end
	end
	if (MODULE_GC_SERVER) then
		GlobalExcute{"EPlatForm:JoinLeague", szLeagueName, tbJoinPlayerIdList};
	end
	return 0;
end

function EPlatForm:DelMember(szLeagueName, szMemberName, bSync)
	if (not szLeagueName) then
		return 0;
	end
	
	if (not szMemberName) then
		return 0;
	end
	
	if not League:FindLeague(self.LGTYPE, szLeagueName) then
		return 0;
	end

	League:DelMember(self.LGTYPE, szLeagueName, szMemberName, 1);
	if (MODULE_GC_SERVER) then
		GlobalExcute{"EPlatForm:DelMember", szLeagueName, szMemberName};
		return 1;
	end
	return 1;	
end

function EPlatForm:LeaveLeague(szMemberName, nQLeave)
	local szLeagueName = League:GetMemberLeague(self.LGTYPE, szMemberName);
	if not szLeagueName then
		return 0;
	end
	if League:GetMemberCount(self.LGTYPE, szLeagueName) <= 1 then
		if (MODULE_GAMESERVER) then
			GCExcute{"EPlatForm:DelLeague", szLeagueName};
		elseif (MODULE_GC_SERVER) then
			self:DelLeague(szLeagueName);
		end
		return 1;
	end
	--马上离开战队
	if nQLeave == 1 then
		if (MODULE_GAMESERVER) then
			GCExcute{"EPlatForm:DelMember", szLeagueName, szMemberName};
		elseif (MODULE_GC_SERVER) then
			self:DelMember(szLeagueName, szMemberName);
		end
		return 1;
	end

	local tbLeagueMemberList = EPlatForm:GetLeagueMemberList(szLeagueName);
	local tbAdv = {};
	local nCaptain = League:GetMemberTask(EPlatForm.LGTYPE, szLeagueName, szMemberName, EPlatForm.LGMTASK_JOB);	
	
	if nCaptain == 1 then
		for _, szName in pairs(tbLeagueMemberList) do
			if szName ~= szMemberName then
				League:SetMemberTask(EPlatForm.LGTYPE, szLeagueName, szName, EPlatForm.LGMTASK_JOB);
				break;
			end
		end
	end
	if (MODULE_GAMESERVER) then
		GCExcute{"EPlatForm:DelMember", szLeagueName, szMemberName};
	elseif (MODULE_GC_SERVER) then
		self:DelMember(szLeagueName, szMemberName);
	end
	return 1;
end

function EPlatForm:BreakLeague(szMemberName)
	local szLeagueName = League:GetMemberLeague(EPlatForm.LGTYPE, szMemberName);
	if not szLeagueName then
		return 0;
	end
	if (MODULE_GAMESERVER) then
		GCExcute{"EPlatForm:DelLeague", szLeagueName};
	elseif (MODULE_GC_SERVER) then
		self:DelLeague(szLeagueName);
	end
end

function EPlatForm:GetLeagueMemberList(szLeagueName)
	local tbPlayerList = League:GetMemberList(EPlatForm.LGTYPE, szLeagueName);
	local tbWllsPlayerList = {};
	local szCaptain = "";
	
	for _, szMemberName in pairs(tbPlayerList) do
		local nCaptain = League:GetMemberTask(EPlatForm.LGTYPE, szLeagueName, szMemberName, EPlatForm.LGMTASK_JOB);
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
				League:SetMemberTask(EPlatForm.LGTYPE, szLeagueName, tbWllsPlayerList[1], EPlatForm.LGMTASK_JOB, 1);
			else
				League:SetMemberTask(EPlatForm.LGTYPE, szLeagueName, tbWllsPlayerList[1], EPlatForm.LGMTASK_JOB, 0);
			end
		end
	end
	
	return tbWllsPlayerList;
end

--排序
--先按积分排行，再按胜场数，再按平场数，再按时间
local function OnSort(tbA, tbB)
	if EPlatForm.nFinalLocalType == 1 then
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

function EPlatForm:SetRankData(tbData, szTitle, nRankParam1, nRankParam2, nRankParam3, nRankParam4)
	local tbLadderInfo = {}
	for nRank, tbLeague in ipairs(tbData) do
		if nRank > 10 then
			break;
		end
		local tbMemberList = EPlatForm:GetLeagueMemberList(tbLeague.szName);
		local tbList = {};
		for i, szName in ipairs(tbMemberList) do
			local nCaptain = League:GetMemberTask(self.LGTYPE, tbLeague.szName, szName, self.LGMTASK_JOB)
			--local nFaction = League:GetMemberTask(self.LGTYPE, tbLeague.szName, szName, self.LGMTASK_FACTION)
			--local nRouteId = League:GetMemberTask(self.LGTYPE, tbLeague.szName, szName, self.LGMTASK_ROUTEID);
			if nCaptain == 1 then
				table.insert(tbList, 1, szName);
			else
				table.insert(tbList, szName);
			end
		end
		local szMemberMsg = "";--"  " .. Lib:StrFillL("战队成员",17) .. "门派路线".."\n\n<color=yellow>";
		for i, szName in ipairs(tbList) do
			szMemberMsg = szMemberMsg .. szName .. "\n";
		end
		
		local tbMemberInfo = {
			dwImgType = 2,
			szName = tbLeague.szName,
			szTxt1 = string.format("总积分:%s",tbLeague.nPoint),
			szTxt2 = string.format("第%s届", Lib:Transfer4LenDigit2CnNum(tbLeague.nSession)),
			szTxt3 = EPlatForm.SEASON_TB[tbLeague.nSession][3],
			szTxt4 = string.format("胜:%s  平:%s  负:%s", tbLeague.nWin, tbLeague.nTie, (tbLeague.nTotal - tbLeague.nWin - tbLeague.nTie) ),
			szTxt5 = "",
			szTxt6 = "",
			szContext = szMemberMsg,
			};
		table.insert(tbLadderInfo, tbMemberInfo);
	end
	SetShowLadder(Ladder:GetType(nRankParam1, nRankParam2, nRankParam3, nRankParam4), szTitle, string.len(szTitle)+1, tbLadderInfo);
end

-- 设置联赛显示榜名字
function EPlatForm:SetShowLadderName(szTitle, nRankParam1, nRankParam2, nRankParam3, nRankParam4)
	SetShowLadderName(Ladder:GetType(nRankParam1, nRankParam2, nRankParam3, nRankParam4), szTitle, string.len(szTitle)+1);
end

--一届比赛结束后战队排名
function EPlatForm:LeagueRankFinal()
	local nFinalType = 1;
	self:LeagueRank(nFinalType, 1);
end

--比赛结束后战队排名
function EPlatForm:LeagueRank(nFinalType, nUpdateNews)
	self:WriteLog("LeagueRank", "家族竞技平台排名");
	EPlatForm.nFinalLocalType = nFinalType or 0;
	local nRankSession = KGblTask.SCGetDbTaskInt(EPlatForm.GTASK_MACTH_SESSION);
	if nFinalType == 1 then
		nRankSession = KGblTask.SCGetDbTaskInt(EPlatForm.GTASK_MACTH_LASTSESSION);
	end
	local tbMacthCfg = EPlatForm:GetMacthTypeCfg(EPlatForm:GetMacthType(nRankSession))
	if (not tbMacthCfg) then
		return 0;
	end
	
	local tbMcfg = tbMacthCfg.tbMacthCfg;
	local tbLogMemberCount = {};
	--随机类型
	
	local pLeagueSet 	= KLeague.GetLeagueSetObject(EPlatForm.LGTYPE);
	local pLeagueItor 	= pLeagueSet.GetLeagueItor();
	local pLeague 		= pLeagueItor.GetCurLeague();
	self.RankLeagueList = {};
	self.RankLeagueId = 1;
	while(pLeague) do
		local nWin = pLeague.GetTask(self.LGTASK_WIN);
		local nTie = pLeague.GetTask(self.LGTASK_TIE);
		local nTotal = pLeague.GetTask(self.LGTASK_TOTAL);
		local nTime = pLeague.GetTask(self.LGTASK_TIME);
		local nSession = pLeague.GetTask(self.LGTASK_MSESSION);
		local nAdvRank	= pLeague.GetTask(self.LGTASK_RANK_ADV);
		local nLoss = nTotal - nWin - nTie;
		local nPoint = nWin * tbMcfg.nTeamWinScore + nTie * tbMcfg.nTeamTieScore + nLoss * tbMcfg.nTeamLoseScore;
		if nSession == nRankSession and nTotal > 0 then
			table.insert(self.RankLeagueList, {nSession = nSession, szName = pLeague.szName, nWin = nWin, nTie = nTie, nTotal = nTotal, nTime = nTime, nPoint = nPoint, nAdvRank = nAdvRank});
			--记录log
			local nMemberCount = League:GetMemberCount(EPlatForm.LGTYPE, pLeague.szName);
			if nMemberCount and not tbLogMemberCount[nMemberCount] then
				tbLogMemberCount[nMemberCount] = 0;
			end
			tbLogMemberCount[nMemberCount] = tbLogMemberCount[nMemberCount] + nMemberCount;
			
		end
		pLeague = pLeagueItor.NextLeague();
	end

	if #self.RankLeagueList > 0 then
		table.sort(self.RankLeagueList, OnSort);
	end

	if (MODULE_GC_SERVER) then	
		--当届前10名入榜.
		local nLadderType	= Ladder:GetType(0, Ladder.LADDER_CLASS_LADDER, Ladder.LADDER_TYPE_LADDER_EVENTPLANT, Ladder.LADDER_TYPE_LADDER_EVENTPLANT_CURTEAM);
		if (0 == CheckShowLadderExist(nLadderType)) then
			AddNewShowLadder(nLadderType);
		end
		self:SetShowLadderName("本届活动榜", 0, Ladder.LADDER_CLASS_LADDER, Ladder.LADDER_TYPE_LADDER_EVENTPLANT, Ladder.LADDER_TYPE_LADDER_EVENTPLANT_CURTEAM);		
		self:SetRankData(self.RankLeagueList, "本届活动榜", 0, Ladder.LADDER_CLASS_LADDER, Ladder.LADDER_TYPE_LADDER_EVENTPLANT, Ladder.LADDER_TYPE_LADDER_EVENTPLANT_CURTEAM);
		GlobalExcute{"Ladder:RefreshLadderName"};
	end
	-- 这个会有问题，在下下届前仔细思考一下，会无法清除上届榜
	if #self.RankLeagueList > 0 then
		Timer:Register(1, self.LeagueRankFrame, self, nFinalType)
	end
	
	--更新每周战报
	if nUpdateNews == 1 then
		EPlatForm:UpdateHelpNews(nRankSession, nFinalType);
	end
	
	--log统计
	if nFinalType == 1 then
		for nCount, nSum in pairs(tbLogMemberCount) do
			EPlatForm:WriteLog(string.format("活动结束,队伍里面队员数量是%s的队伍数:%s", nCount, nSum));
		end
		
		if (MODULE_GC_SERVER) then
			for nRank, tbInfo in pairs(self.RankLeagueList) do
				local szLog = "";
				local szLeagueName = tbInfo.szName;
				local tbPlayerList = League:GetMemberList(EPlatForm.LGTYPE, szLeagueName);
				local szMemberNameList = "";
				for nId, szMemberName in pairs(tbPlayerList) do
					local nPlayerId = KGCPlayer.GetPlayerIdByName(szMemberName);
					StatLog:WriteStatLog("stat_info", "kin_game", "award_list", nPlayerId, string.format("%s,%s", szLeagueName, nRank));
				end
			end
		end
	end
end

--分帧存储
function EPlatForm:LeagueRankFrame(nFinalType)
	local nCount = 0;
	for nRank = self.RankLeagueId, #self.RankLeagueList do
		if nCount >= self.RankFrameCount then
			self.RankLeagueId = nRank;
			return 1;
		end
		League:SetLeagueTask(EPlatForm.LGTYPE, self.RankLeagueList[nRank].szName, EPlatForm.LGTASK_RANK, nRank, 1);
		local nSession = League:GetLeagueTask(self.LGTYPE, self.RankLeagueList[nRank].szName, self.LGTASK_MSESSION);
		if (MODULE_GC_SERVER) and nFinalType == 1 then
			--增加荣誉值.
			EPlatForm:WriteLog(string.format("%s届最终活动排名:战队:%s\t排名:%s", nSession, self.RankLeagueList[nRank].szName, nRank));
		end
		EPlatForm:WriteLog(string.format("活动排名:战队:%s\t排名:%s", self.RankLeagueList[nRank].szName, nRank));
		nCount = nCount + 1;
	end
	if (MODULE_GC_SERVER) then
		GlobalExcute({"EPlatForm:LeagueRank", nFinalType});
	end


	if (MODULE_GC_SERVER) and nFinalType == 1 then
		local szTitle			= "";

		szTitle = "上届活动榜";		
		--清除上届排行榜
		if GetShowLadder(self:GetLastEventLadderType()) then
			DelShowLadder(self:GetLastEventLadderType());
		end
	
		--把当届排行保存到上届排行,并清除当届榜

		local nNowLadderType	= self:GetCurEventLadderType();
		local nLastLadderType	= self:GetLastEventLadderType();
		
		local tbNowLadder = GetShowLadder(nNowLadderType);
		if tbNowLadder then
			SetShowLadder(nLastLadderType, szTitle, string.len(szTitle)+1, tbNowLadder);
			local szName = "上届活动榜";
			if (szName and string.len(szName) > 0) then
				if (0 == CheckShowLadderExist(nLastLadderType)) then
					AddNewShowLadder(nLastLadderType);
				end					
				SetShowLadderName(nLastLadderType, szName, string.len(szName) + 1);
			end
			DelShowLadder(nNowLadderType);
		end

		GlobalExcute{"Ladder:RefreshLadderName"};
	end
	if nFinalType == 1 then
		EPlatForm.AdvMatchLists = {};
	end
	return 0;
end

function EPlatForm:SetFactionElectPlayer()
	-- 判断是都已经开启联赛且已经进行了一届了
	local nLastRankSession = KGblTask.SCGetDbTaskInt(EPlatForm.GTASK_MACTH_LASTSESSION);
	if (nLastRankSession <= 0) then
		return;
	end
end

--比赛开始前,清除不同赛制不同届建立的战队.
function EPlatForm:LeagueClearSession()
	local pLeagueSet 	= KLeague.GetLeagueSetObject(EPlatForm.LGTYPE);
	local pLeagueItor 	= pLeagueSet.GetLeagueItor();
	local pLeague 		= pLeagueItor.GetCurLeague();
	self.ClsLeagueList = {};
	self.ClsLeagueId = 1;
	while(pLeague) do
		local nType = pLeague.GetTask(EPlatForm.LGTASK_MTYPE);
		local nSession = pLeague.GetTask(EPlatForm.LGTASK_MSESSION);
		if (nType ~= self:GetMacthType() or nSession ~= self:GetMacthSession()) then
			if (nType > 0) then
				table.insert(self.ClsLeagueList, pLeague.szName);
			elseif (nType == 0 and nSession ~= self:GetMacthSession()) then
				table.insert(self.ClsLeagueList, pLeague.szName);
			end
		end
		
		pLeague = pLeagueItor.NextLeague();
	end

	if #self.ClsLeagueList > 0 then
		Timer:Register(1, self.LeagueClearSessionFrame, self)
	end
end

function EPlatForm:LeagueClearSessionFrame()
	local nCount = 0;
	for nRank = self.ClsLeagueId, #self.ClsLeagueList do
		if nCount >= self.RankFrameCount then
			self.ClsLeagueId = nRank;
			return 1;
		end
		League:DelLeague(EPlatForm.LGTYPE, self.ClsLeagueList[nRank], 1);
		nCount = nCount + 1;
	end
	if (MODULE_GC_SERVER) then
		GlobalExcute({"EPlatForm:LeagueClearSession"});
	end
	return 0;
end

function EPlatForm:LoadMatchRank()
	EPlatForm.nFinalLocalType	= 0;
	local nMatchState		= EPlatForm:GetMacthState();
	local nFinalType		= 0;
	if (nMatchState ~= EPlatForm.DEF_STATE_MATCH_1 and nMatchState ~= EPlatForm.DEF_STATE_MATCH_2 and nMatchState ~= EPlatForm.DEF_STATE_ADVMATCH) then
		return;
	end
	local nRankSession	= KGblTask.SCGetDbTaskInt(EPlatForm.GTASK_MACTH_SESSION);
	local tbMacthCfg	= EPlatForm:GetMacthTypeCfg(EPlatForm:GetMacthType(nRankSession))

	local pLeagueSet 	= KLeague.GetLeagueSetObject(EPlatForm.LGTYPE);
	local pLeagueItor 	= pLeagueSet.GetLeagueItor();
	local pLeague 		= pLeagueItor.GetCurLeague();
	self.RankLeagueList = {};
	self.RankLeagueId	= 1;
	while(pLeague) do
		local nWin = pLeague.GetTask(self.LGTASK_WIN);
		local nTie = pLeague.GetTask(self.LGTASK_TIE);
		local nTotal = pLeague.GetTask(self.LGTASK_TOTAL);
		local nTime = pLeague.GetTask(self.LGTASK_TIME);
		local nSession = pLeague.GetTask(self.LGTASK_MSESSION);
		local nAdvRank	= pLeague.GetTask(self.LGTASK_RANK_ADV);
		local nLoss = nTotal - nWin - nTie;
		local nPoint = nWin * EPlatForm.MACTH_POINT_WIN + nTie * EPlatForm.MACTH_POINT_TIE + nLoss * EPlatForm.MACTH_POINT_LOSS;
		if nSession == nRankSession and nTotal > 0 then
			table.insert(self.RankLeagueList, {nSession = nSession, szName = pLeague.szName, nWin = nWin, nTie = nTie, nTotal = nTotal, nTime = nTime, nPoint = nPoint, nAdvRank = nAdvRank});				
		end
		pLeague = pLeagueItor.NextLeague();
	end
	if #self.RankLeagueList > 0 then
		table.sort(self.RankLeagueList, OnSort);
	end
	
	if #self.RankLeagueList > 0 then
		Timer:Register(1, self.LeagueRankFrame, self, nFinalType)
	end

end

--分帧存储
function EPlatForm:LeagueLoadRankFrame(nFinalType)
	local nCount = 0;
	for nRank = self.RankLeagueId, #self.RankLeagueList do
		if nCount >= self.RankFrameCount then
			self.RankLeagueId = nRank;
			return 1;
		end
		League:SetLeagueTask(EPlatForm.LGTYPE, self.RankLeagueList[nRank].szName, EPlatForm.LGTASK_RANK, nRank, 1);
		nCount = nCount + 1;
	end	
end

function EPlatForm:GetLadderPart(nLadderType, nStart, nLength)
	local nMatchState		= EPlatForm:GetMacthState();
	if (nMatchState ~= EPlatForm.DEF_STATE_MATCH_1 and nMatchState ~= EPlatForm.DEF_STATE_MATCH_2 and nMatchState ~= EPlatForm.DEF_STATE_ADVMATCH) then
		return;
	end
	local nRankSession	= KGblTask.SCGetDbTaskInt(EPlatForm.GTASK_MACTH_SESSION);
	local tbMacthCfg	= EPlatForm:GetMacthTypeCfg(EPlatForm:GetMacthType(nRankSession))	
	
	local tbLadder	= {};
	local nMaxList	= 0;
	local _, nClass, nType, nNum = Ladder:GetClassByType(nLadderType);

	if (not self.RankLeagueList) then
		return;
	end


	local tbList	= {};
	tbList	= self.RankLeagueList;
	
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

function EPlatForm:GetMatchLadderRankByName(nLadderType, szName, nSearchType)
	local nMatchState		= EPlatForm:GetMacthState();
	if (nMatchState ~= EPlatForm.DEF_STATE_MATCH_1 and nMatchState ~= EPlatForm.DEF_STATE_MATCH_2 and nMatchState ~= EPlatForm.DEF_STATE_ADVMATCH) then
		return 0;
	end
	local nRankSession	= KGblTask.SCGetDbTaskInt(EPlatForm.GTASK_MACTH_SESSION);
	local tbMacthCfg	= EPlatForm:GetMacthTypeCfg(EPlatForm:GetMacthType(nRankSession))	
	
	local tbLadder	= {};
	local nMaxList	= 0;
	local nRank		= 0;
	local _, nClass, nType, nNum = Ladder:GetClassByType(nLadderType);
	
	if (not self.RankLeagueList) then
		return nRank;
	end

	
	local tbList	= {};
	tbList	= self.RankLeagueList;	

	if (not tbList or #tbList <= 0) then
		return nRank;
	end
	
	nMaxList			= #tbList;
	local nMaxNum		= math.min(5000, nMaxList);
	local szTeamName	= nil;
	
	if (Ladder.SEARCHTYPE_PLAYERNAME == nSearchType) then
		szTeamName	= League:GetMemberLeague(EPlatForm.LGTYPE, szName);
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

function EPlatForm:ProcessCreateFormatTeam(szMemberName, szNewLeagueName, nNameType)
	if (not szMemberName) then
		return 0, "认证失败";
	end
	
	local szLeagueName = League:GetMemberLeague(EPlatForm.LGTYPE, szMemberName);
	if not szLeagueName then
		return 0, "没有加入任何战队";
	end
	
	if (not szNewLeagueName) then
		return 0, "战队名不能为空";
	end
	
	if nNameType and nNameType == 2 and League:FindLeague(self.LGTYPE, szNewLeagueName) then
		return 0, string.format("战队名字<color=yellow>%s<color>已经存在，请更换名字！", szNewLeagueName);
	end
	
	local nSession	= League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_MSESSION);
	local nType		= League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_MTYPE);
	
	if (nSession ~= self:GetMacthSession()) then
		return 0, "不是本届活动的战队";
	end
	
	if (nType > 0) then
		return 0, "战队已经验证确认过了";
	end
	
	local tbWllsPlayerList = {};
	
	local tbPlayerList = League:GetMemberList(EPlatForm.LGTYPE, szLeagueName);
	if (not tbPlayerList) then
		return 0, "没有成员";
	end
	
	for _, szMemName in pairs(tbPlayerList) do
		local tbInfo = {};
		tbInfo.szName = szMemName;
		tbInfo.nCaptain = League:GetMemberTask(self.LGTYPE, szLeagueName, szMemName, self.LGMTASK_JOB);
		tbInfo.nFaction	= League:GetMemberTask(self.LGTYPE, szLeagueName, szMemName, self.LGMTASK_FACTION);
		tbInfo.nRouteId	= League:GetMemberTask(self.LGTYPE, szLeagueName, szMemName, self.LGMTASK_ROUTEID);
		tbInfo.nCamp	= League:GetMemberTask(self.LGTYPE, szLeagueName, szMemName, self.LGMTASK_CAMP);
		tbInfo.nSex		= League:GetMemberTask(self.LGTYPE, szLeagueName, szMemName, self.LGMTASK_SEX);
		tbInfo.nSeries	= League:GetMemberTask(self.LGTYPE, szLeagueName, szMemName, self.LGMTASK_SERIES);
		if (szMemberName == szMemName) then
			tbInfo.nCaptain = 1;
		end

		tbWllsPlayerList[#tbWllsPlayerList + 1] = tbInfo;
	end

	if (MODULE_GAMESERVER) then
		GCExcute{"EPlatForm:DelLeague", szLeagueName};
	end

	if (MODULE_GAMESERVER) then
		GCExcute{"EPlatForm:CreateLeague", tbWllsPlayerList, szNewLeagueName, 0};
		GCExcute{"EPlatForm:AddLeagueNameInKinList", szNewLeagueName};
	end

	return 1, string.format("确认完毕，你现在的战队是：<color=yellow>%s<color>", szNewLeagueName);
end

function EPlatForm:DelLeague(szLeagueName)
	if (not szLeagueName) then
		return 0;
	end
	
	if not League:FindLeague(self.LGTYPE, szLeagueName) then
		return 0;
	end

	League:DelLeague(self.LGTYPE, szLeagueName, 1);
	if (MODULE_GC_SERVER) then
		GlobalExcute{"EPlatForm:DelLeague", szLeagueName};
	end
	return 1;
end

function EPlatForm:ShowTeam(szPlayerName)
	if (not szPlayerName) then
		return;
	end
	local szLeagueName = League:GetMemberLeague(EPlatForm.LGTYPE, szPlayerName);
	if (not szLeagueName) then
		print("没有战队信息");
		return;
	end

	local nSession	= League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_MSESSION);
	local nType		= League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_MTYPE);
	print("=======================");
	print(szLeagueName, nSession, nType);

	local tbPlayerList = League:GetMemberList(EPlatForm.LGTYPE, szLeagueName);
	if (not tbPlayerList) then
		print("没有成员");
		return;
	end
	
	for _, szMemName in pairs(tbPlayerList) do
		local tbInfo = {};
		tbInfo.szName = szMemName;
		tbInfo.nCaptain = League:GetMemberTask(self.LGTYPE, szLeagueName, szMemName, self.LGMTASK_JOB);
		tbInfo.nFaction	= League:GetMemberTask(self.LGTYPE, szLeagueName, szMemName, self.LGMTASK_FACTION);
		tbInfo.nRouteId	= League:GetMemberTask(self.LGTYPE, szLeagueName, szMemName, self.LGMTASK_ROUTEID);
		tbInfo.nCamp	= League:GetMemberTask(self.LGTYPE, szLeagueName, szMemName, self.LGMTASK_CAMP);
		tbInfo.nSex		= League:GetMemberTask(self.LGTYPE, szLeagueName, szMemName, self.LGMTASK_SEX);
		tbInfo.nSeries	= League:GetMemberTask(self.LGTYPE, szLeagueName, szMemName, self.LGMTASK_SERIES);
		if (szMemberName == szMemName) then
			tbInfo.nCaptain = 1;
		end
		Lib:ShowTB(tbInfo);
	end
	print("=======================");
	return 1;
end

if (MODULE_GC_SERVER) then
	GCEvent:RegisterGCServerStartFunc(EPlatForm.LoadMatchRank, EPlatForm);
end

if (MODULE_GAMESERVER) then
	ServerEvent:RegisterServerStartFunc(EPlatForm.LoadMatchRank, EPlatForm);
end
