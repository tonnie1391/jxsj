--武林联赛
--孙多良
--2008.09.17
Require("\\script\\mission\\wlls\\wlls_def.lua")

--加载联赛表
function Wlls:LoadGameTable()
	local tbFile = Lib:LoadTabFile(string.format("\\setting\\mission\\%s\\league_table.txt", Wlls.DEF_FILE_ADDRESS));
	if not tbFile then
		return
	end
	for nId, tbParam in ipairs(tbFile) do
		if nId > 1 then
			local nSession 		= tonumber(tbParam.Session);
			if (nSession) then
				local nLeagueType 	= tonumber(tbParam.LeagueType);
				local szAwardFile 	= tbParam.AwardFile;
				local szAwardSegFile= tbParam.AwardSegFile;
				local nAdvRank 		= tonumber(tbParam.AdvRank);
				local nPreMaxLeague	= tonumber(tbParam.PreMaxLeague) or 200;
				local szDesc 		= tbParam.Desc;
				local nPrimRank		= tonumber(tbParam.PrimRank); -- 跨服联赛用
				local nOpenTime		= tonumber(tbParam.OpenTime) or 0;
				Wlls.SEASON_TB[nSession] = {nLeagueType, szAwardFile, nAdvRank, szDesc, nPreMaxLeague, nPrimRank};
				
				if (not GLOBAL_AGENT) then
					Wlls.DATE_TO_SESSION[nOpenTime] = nSession;
				end
				
				if not MODULE_GAMECLIENT then
					--加载奖励分段表
					self:LoadGameAwardLevel(szAwardSegFile, nSession);
				end
			end
		end
	end
	
end

--加载联赛类型表
function Wlls:LoadGameType()
	local tbFile = Lib:LoadTabFile(string.format("\\setting\\mission\\%s\\league_type.txt", Wlls.DEF_FILE_ADDRESS));
	if not tbFile then
		return
	end
	Wlls.MACTH_TYPE = {};
	local tbFileName = {};
	local tbFileTrap = {};
	--local tbFileAward = {};
	for nId, tbParam in ipairs(tbFile) do
		if nId > 1 then
			local nLeagueType = tonumber(tbParam.LeagueType);
			if tbParam.FileName ~= "" then
				tbFileName[nLeagueType] = tbParam.FileName;
			end
			if tbParam.FileNameTrap ~= "" then
				tbFileTrap[nLeagueType] = tbParam.FileNameTrap;
			end
			--if tbParam.FileAwardSeg ~= "" then
			--	tbFileAward[nLeagueType] = tbParam.FileAwardSeg;
			--end
			Wlls.MACTH_TYPE[nLeagueType] = tbParam.ClassName;
		end
	end
	Wlls.MacthType = {};
	for nType, szClassName in pairs(Wlls.MACTH_TYPE) do
		Wlls.MacthType[szClassName] = {};
		Wlls.MacthType[szClassName].tbMacthCfg 	= {};
		Wlls.MacthType[szClassName].tbMacthCfg.tbWeekend 	= {};
		Wlls.MacthType[szClassName].tbMacthCfg.tbCommon 	= {};
		Wlls.MacthType[szClassName].tbMacthCfg.tbAdvMatch 	= {};
		Wlls.MacthType[szClassName].tbMacthCfg.tbPKTime_Common = {};
		Wlls.MacthType[szClassName].tbMacthCfg.tbPKTime_Adv = {};
		Wlls.MacthType[szClassName].tbMacthCfg.nMissionType = 0;
		Wlls.MacthType[szClassName].tbMacthCfg.nMinPlayerPkNum = 0;
		Wlls.MacthType[szClassName].PrimMacth 	= {tbIntoMap={},tbReadyMap={},tbMacthMap={}, tbMacthMapPatch={}};
		Wlls.MacthType[szClassName].AdvMacth 	= {tbIntoMap={},tbReadyMap={},tbMacthMap={}, tbMacthMapPatch={}};
		
		if tbFileName[nType] then
			local tbTypeFile = Lib:LoadTabFile(string.format("\\setting\\mission\\%s\\league_type\\%s", Wlls.DEF_FILE_ADDRESS, tbFileName[nType]));
			if not tbTypeFile then
				print("【武林联赛】读取文件错误，文件不存在", tbFileName[nType]);
				return
			end
			for nId, tbParam in ipairs(tbTypeFile) do
				if nId > 1 then
					local szName 		= tbParam.Name;
					local nMapLinkType  = tonumber(tbParam.MapLinkType);
					local nMemberCount  = tonumber(tbParam.MemberCount);
					local nPlayerCount  = tonumber(tbParam.PlayerCount);
					local nSex  		= tonumber(tbParam.Sex);
					local nCamp  		= tonumber(tbParam.Camp);
					local nSeries 	 	= tonumber(tbParam.Series);
					local nFaction  	= tonumber(tbParam.Faction);
					local nTeacher  	= tonumber(tbParam.Teacher);
					local szDesc  		= tbParam.Desc;
					local nPriIntoMap  	= tonumber(tbParam.PriIntoMap);
					local nPriReadyMap  = tonumber(tbParam.PriReadyMap);
					local nPriMacthMap  = tonumber(tbParam.PriMacthMap);
					local nPriMacthMapPatch = tonumber(tbParam.PriMacthMapPatch);
					local nAdvIntoMap  	= tonumber(tbParam.AdvIntoMap);
					local nAdvReadyMap  = tonumber(tbParam.AdvReadyMap);
					local nAdvMacthMap  = tonumber(tbParam.AdvMacthMap);
					local nAdvMacthMapPatch  = tonumber(tbParam.AdvMacthMapPatch);
					local nTimeWeekend	= tonumber(tbParam.Time_Weekend);
					local nTimeCommon	= tonumber(tbParam.Time_Common);
					local nTimeAdvMatch	= tonumber(tbParam.Time_AdvMatch);
					local nReadyTime_Common	= tonumber(tbParam.ReadyTime_Common);
					local nPKTime_Common	= tonumber(tbParam.PKTime_Common);
					local nReadyTime_Adv	= tonumber(tbParam.ReadyTime_Adv);
					local nPKTime_Adv		= tonumber(tbParam.PKTime_Adv);
					local nChooseTime_Common	= tonumber(tbParam.PkChooseTime_Common);
					local nChooseTime_Adv	= tonumber(tbParam.PkChooseTime_Adv);
					local nMissionType		= tonumber(tbParam.MissionType);
					local nMinPlayerPkNum	= tonumber(tbParam.MinPkPlayerNum);
					local nMatchTimeBye		= tonumber(tbParam.MatchTimeBye);
					local nTotalMatchTime	= tonumber(tbParam.TotalMatchTime);
					
					if szName and szName ~= "" then
						Wlls.MacthType[szClassName].szName = szName;
					end
					if szDesc and szDesc ~= "" then
						Wlls.MacthType[szClassName].szDesc = szDesc;
					end					
					if nMapLinkType then
						Wlls.MacthType[szClassName].nMapLinkType = nMapLinkType;
					end
					if nMemberCount then
						Wlls.MacthType[szClassName].tbMacthCfg.nMemberCount = nMemberCount;
					end
					if nPlayerCount then
						Wlls.MacthType[szClassName].tbMacthCfg.nPlayerCount = nPlayerCount;
					end					
					if nSex then
						Wlls.MacthType[szClassName].tbMacthCfg.nSex = nSex;
					end
					if nCamp then
						Wlls.MacthType[szClassName].tbMacthCfg.nCamp = nCamp;
					end
					if nSeries then
						Wlls.MacthType[szClassName].tbMacthCfg.nSeries = nSeries;
					end
					if nFaction then
						Wlls.MacthType[szClassName].tbMacthCfg.nFaction = nFaction;
					end
					if nTeacher then
						Wlls.MacthType[szClassName].tbMacthCfg.nTeacher = nTeacher;
					end
					
					if (nMinPlayerPkNum) then
						Wlls.MacthType[szClassName].tbMacthCfg.nMinPlayerPkNum = nMinPlayerPkNum;
					end
					
					if (nMissionType) then
						Wlls.MacthType[szClassName].tbMacthCfg.nMissionType = nMissionType;
					end
					
					if (nReadyTime_Common) then
						Wlls.MacthType[szClassName].tbMacthCfg.nReadyTime_Common = nReadyTime_Common;
					end

					if (nReadyTime_Adv) then
						Wlls.MacthType[szClassName].tbMacthCfg.nReadyTime_Adv = nReadyTime_Adv;
					end

					if (nMatchTimeBye) then
						Wlls.MacthType[szClassName].tbMacthCfg.nMatchTimeBye = nMatchTimeBye;
					end

					if (nTotalMatchTime) then
						Wlls.MacthType[szClassName].tbMacthCfg.nTotalMatchTime = nTotalMatchTime;
					end

					if (nPKTime_Common) then
--						Wlls.MacthType[szClassName].tbMacthCfg.nPKTime_Common = nPKTime_Common;
						table.insert(Wlls.MacthType[szClassName].tbMacthCfg.tbPKTime_Common, nPKTime_Common);
					end

					if (nPKTime_Adv) then
--						Wlls.MacthType[szClassName].tbMacthCfg.nPKTime_Adv = nPKTime_Adv;
						table.insert(Wlls.MacthType[szClassName].tbMacthCfg.tbPKTime_Adv, nPKTime_Adv);
					end

					if (nChooseTime_Common) then
						Wlls.MacthType[szClassName].tbMacthCfg.nChooseTime_Common	= nChooseTime_Common;
					end
					
					if (nChooseTime_Adv) then
						Wlls.MacthType[szClassName].tbMacthCfg.nChooseTime_Adv		= nChooseTime_Adv;
					end
					
					if (nTimeCommon) then
						table.insert(Wlls.MacthType[szClassName].tbMacthCfg.tbCommon, nTimeCommon);
					end

					if (nTimeWeekend) then
						table.insert(Wlls.MacthType[szClassName].tbMacthCfg.tbWeekend, nTimeWeekend);
					end

					if (nTimeAdvMatch) then
						table.insert(Wlls.MacthType[szClassName].tbMacthCfg.tbAdvMatch, nTimeAdvMatch);
					end
					
					if nPriIntoMap then
						table.insert(Wlls.MacthType[szClassName].PrimMacth.tbIntoMap, nPriIntoMap);
					end
					if nPriReadyMap then
						table.insert(Wlls.MacthType[szClassName].PrimMacth.tbReadyMap, nPriReadyMap);
					end
					if nPriMacthMap then
						table.insert(Wlls.MacthType[szClassName].PrimMacth.tbMacthMap, nPriMacthMap);
					end
					if nPriMacthMapPatch then
						table.insert(Wlls.MacthType[szClassName].PrimMacth.tbMacthMapPatch, nPriMacthMapPatch);
					end					
					if nAdvIntoMap then
						table.insert(Wlls.MacthType[szClassName].AdvMacth.tbIntoMap, nAdvIntoMap);
					end
					if nAdvReadyMap then
						table.insert(Wlls.MacthType[szClassName].AdvMacth.tbReadyMap, nAdvReadyMap);
					end
					if nAdvMacthMap then
						table.insert(Wlls.MacthType[szClassName].AdvMacth.tbMacthMap, nAdvMacthMap);
					end		
					if nAdvMacthMapPatch then
						table.insert(Wlls.MacthType[szClassName].AdvMacth.tbMacthMapPatch, nAdvMacthMapPatch);
					end																								
				end
			end
			
			if not Wlls.MacthType[szClassName].szName then
				Wlls.MacthType[szClassName].szName = "【未填写类型】";
			end
			if not Wlls.MacthType[szClassName].szDesc then
				Wlls.MacthType[szClassName].szDesc = "【未填写描述】";
			end
			if not Wlls.MacthType[szClassName].nMapLinkType then
				Wlls.MacthType[szClassName].nMapLinkType = 1;
			end
			if not Wlls.MacthType[szClassName].tbMacthCfg.nMemberCount then
				Wlls.MacthType[szClassName].tbMacthCfg.nMemberCount = 0;
			end			
			if not Wlls.MacthType[szClassName].tbMacthCfg.nPlayerCount then
				Wlls.MacthType[szClassName].tbMacthCfg.nPlayerCount = 0;
			end
			if not Wlls.MacthType[szClassName].tbMacthCfg.nSex then
				Wlls.MacthType[szClassName].tbMacthCfg.nSex = 0;
			end
			if not Wlls.MacthType[szClassName].tbMacthCfg.nCamp then
				Wlls.MacthType[szClassName].tbMacthCfg.nCamp = 0;
			end
			if not Wlls.MacthType[szClassName].tbMacthCfg.nSeries then
				Wlls.MacthType[szClassName].tbMacthCfg.nSeries = 0;
			end
			if not Wlls.MacthType[szClassName].tbMacthCfg.nFaction then
				Wlls.MacthType[szClassName].tbMacthCfg.nFaction = 0;
			end
			if not Wlls.MacthType[szClassName].tbMacthCfg.nTeacher then
				Wlls.MacthType[szClassName].tbMacthCfg.nTeacher = 0;
			end
		end
		--加载pk场传入坐标
		if tbFileTrap[nType] then
			local tbTypeFile = Lib:LoadTabFile(string.format("\\setting\\mission\\%s\\league_trap\\%s", Wlls.DEF_FILE_ADDRESS, tbFileTrap[nType]));
			if not tbTypeFile then
				print("【武林联赛】读取文件错误，文件不存在", tbFileTrap[nType]);
				return
			end
			self.PosGamePk[nType] = {};
			for nId, tbParam in ipairs(tbTypeFile) do
				local nPosX = math.floor((tonumber(tbParam.TRAPX) )/32);
				local nPosY = math.floor((tonumber(tbParam.TRAPY) )/32);
				self.PosGamePk[nType][nId] = {nPosX, nPosY};
			end
		end
	end
	if (GLOBAL_AGENT) then
		GbWlls.MACTH_TYPE	= Wlls.MACTH_TYPE;
		GbWlls.MacthType	= Wlls.MacthType;
	end
end

--加载奖励分层表
function Wlls:LoadGameAwardLevel(szFileName, nSession)
	local tbFile = Lib:LoadTabFile(string.format("\\setting\\mission\\%s\\league_award\\%s", Wlls.DEF_FILE_ADDRESS, szFileName));
	if not tbFile then
		return
	end
	if not self.AWARD_LEVEL[nSession] then
		self.AWARD_LEVEL[nSession] = {[Wlls.MACTH_PRIM] = {}, [Wlls.MACTH_ADV] = {}};
	end
	for nId, tbParam in ipairs(tbFile) do
		if nId > 1 then
			local nLevelType = tonumber(tbParam.LevelType);
			local nLevel1 = tonumber(tbParam.Level1) or -1;
			local nLevel2 = tonumber(tbParam.Level2) or -1;
			if nLevel1 >= 0 then
				self.AWARD_LEVEL[nSession][Wlls.MACTH_PRIM][nLevelType] = nLevel1;
			end
			if nLevel2 >= 0 then
				self.AWARD_LEVEL[nSession][Wlls.MACTH_ADV][nLevelType] = nLevel2;
			end
		end
	end
end

function Wlls:LoadGameAward()
	Wlls.AWARD_SINGLE_LIST[Wlls.MACTH_PRIM] = {};
	Wlls.AWARD_SINGLE_LIST[Wlls.MACTH_ADV] = {};
	Wlls.AWARD_FINISH_LIST[Wlls.MACTH_PRIM] = {};
	Wlls.AWARD_FINISH_LIST[Wlls.MACTH_ADV] = {};
	for nSession, tbSession in pairs(self.SEASON_TB) do
		if tbSession[2] then
			self:LoadGameAwardBase("\\setting\\mission\\"..Wlls.DEF_FILE_ADDRESS.."\\league_award\\"..tbSession[2].."_lv1.txt", Wlls.MACTH_PRIM, nSession);
			self:LoadGameAwardBase("\\setting\\mission\\"..Wlls.DEF_FILE_ADDRESS.."\\league_award\\"..tbSession[2].."_lv2.txt", Wlls.MACTH_ADV, nSession);
		end
	end
end

--加载奖励
function Wlls:LoadGameAwardBase(szPath, nGameLevel, nSession)
	local tbFile = Lib:LoadTabFile(szPath)
	if not tbFile then
		return
	end
	for nId, tbParam in ipairs(tbFile) do
		if nId > 1 then
			
			local szWin = tbParam.Win;
			local szTie = tbParam.Tie;
			local szLost = tbParam.Lost;
			
			if not Wlls.AWARD_SINGLE_LIST[nGameLevel][nSession] then
				Wlls.AWARD_SINGLE_LIST[nGameLevel][nSession] = {};
				Wlls.AWARD_SINGLE_LIST[nGameLevel][nSession].Win = {};
				Wlls.AWARD_SINGLE_LIST[nGameLevel][nSession].Tie = {};
				Wlls.AWARD_SINGLE_LIST[nGameLevel][nSession].Lost = {};
			end
			if szWin and szWin ~= "" then
				local szType, Value = self:GetSplitValue(szWin)
				if not Wlls.AWARD_SINGLE_LIST[nGameLevel][nSession].Win[szType] then
					Wlls.AWARD_SINGLE_LIST[nGameLevel][nSession].Win[szType] = {};
				end
				table.insert(Wlls.AWARD_SINGLE_LIST[nGameLevel][nSession].Win[szType], Value);
			end
			if szTie and szTie ~= "" then
				local szType, Value = self:GetSplitValue(szTie)
				if not Wlls.AWARD_SINGLE_LIST[nGameLevel][nSession].Tie[szType] then
					Wlls.AWARD_SINGLE_LIST[nGameLevel][nSession].Tie[szType] = {};
				end
				table.insert(Wlls.AWARD_SINGLE_LIST[nGameLevel][nSession].Tie[szType], Value);
			end	
			if szLost and szLost ~= "" then
				local szType, Value = self:GetSplitValue(szLost)
				if not Wlls.AWARD_SINGLE_LIST[nGameLevel][nSession].Lost[szType] then
					Wlls.AWARD_SINGLE_LIST[nGameLevel][nSession].Lost[szType] = {};
				end
				table.insert(Wlls.AWARD_SINGLE_LIST[nGameLevel][nSession].Lost[szType], Value);
			end
			
			if not Wlls.AWARD_FINISH_LIST[nGameLevel][nSession] then
				Wlls.AWARD_FINISH_LIST[nGameLevel][nSession] = {};
			end		
			for nId in pairs(self.AWARD_LEVEL[nSession][nGameLevel]) do
				if not Wlls.AWARD_FINISH_LIST[nGameLevel][nSession][nId] then
					Wlls.AWARD_FINISH_LIST[nGameLevel][nSession][nId] = {};
				end
				local szAward = tbParam["RankType"..nId];
				if szAward and szAward ~= "" then
					local szType, Value = self:GetSplitValue(szAward)
					if not Wlls.AWARD_FINISH_LIST[nGameLevel][nSession][nId][szType] then
						Wlls.AWARD_FINISH_LIST[nGameLevel][nSession][nId][szType] = {};
					end
					table.insert(Wlls.AWARD_FINISH_LIST[nGameLevel][nSession][nId][szType], Value);
				end
			end
		end
	end
end

function Wlls:GetSplitValue(szStr)
		szStr = Lib:ClearStrQuote(szStr);
		local nSit = string.find(szStr, "=");
		if nSit ~= nil then
			local szFlag = string.sub(szStr, 1, nSit - 1);
			local szContent = string.sub(szStr, nSit + 1, string.len(szStr));
			if tonumber(szContent) then
				return szFlag, tonumber(szContent);
			end
			local tbLit = Lib:SplitStr(szContent, ",");
			for nId, nNum in ipairs(tbLit) do
				tbLit[nId] = tonumber(nNum);
			end
			return szFlag, tbLit;
		end
		return "", "";
end

Wlls:LoadGameTable();

if not MODULE_GAMECLIENT then
Wlls:LoadGameType();
Wlls:LoadGameAward();
end
