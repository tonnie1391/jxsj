--活动平台
--zhouchenfei
--2009.08.11
Require("\\script\\event\\eventplantform\\plantform_def.lua")

--加载联赛表
function EPlatForm:LoadGameTable()
	local tbFile = Lib:LoadTabFile("\\setting\\event\\eventplantform\\plantform_table.txt")
	if not tbFile then
		return
	end
	for nId, tbParam in ipairs(tbFile) do
		if nId > 1 then
			local nSession 		= tonumber(tbParam.Session);
			local nEventType 	= tonumber(tbParam.EventType);
			local szAwardFile 	= tbParam.AwardFile;
			local szAwardSegFile= tbParam.AwardSegFile;
			local nPreMaxLeague	= tonumber(tbParam.PreMaxLeague) or 200;
			local szDesc 		= tbParam.Desc;
			local nMatchDate	= tonumber(tbParam.MatchDate);
			EPlatForm.SEASON_TB[nSession] = {nEventType, szAwardFile, szDesc, nPreMaxLeague};
			EPlatForm.DATE_TO_SESSION[nMatchDate] = nSession;

			if not MODULE_GAMECLIENT then
			--加载奖励分段表
				self:LoadGameAwardRank(szAwardSegFile, nSession);
			end
		end
	end
	
end

--加载联赛类型表
function EPlatForm:LoadGameType()
	local tbFile = Lib:LoadTabFile("\\setting\\event\\eventplantform\\plantform_type.txt")
	if not tbFile then
		return
	end
	EPlatForm.MACTH_TYPE = {};
	local tbFileName = {};
	local tbFileTrap = {};
	local szBaseMission = "";
	--local tbFileAward = {};
	local tbBaseMission = {};
	for nId, tbParam in ipairs(tbFile) do
		if nId > 1 then
			local nEventType = tonumber(tbParam.EventType);
			if tbParam.FileName ~= "" then
				tbFileName[nEventType] = tbParam.FileName;
			end
			if tbParam.FileNameTrap ~= "" then
				tbFileTrap[nEventType] = tbParam.FileNameTrap;
			end
			--if tbParam.FileAwardSeg ~= "" then
			--	tbFileAward[nLeagueType] = tbParam.FileAwardSeg;
			--end
			EPlatForm.MACTH_TYPE[nEventType] = tbParam.ClassName;
			if (tbParam.MissionType ~= "" and tbParam.ClassName and tbParam.ClassName ~= "") then
				tbBaseMission[tbParam.ClassName] = tbParam.MissionType;
			end
		end
	end
	EPlatForm.MacthType = {};
	for nType, szClassName in pairs(EPlatForm.MACTH_TYPE) do
		EPlatForm.MacthType[szClassName] = {};
		EPlatForm.MacthType[szClassName].tbMacthCfg					= {};
		EPlatForm.MacthType[szClassName].tbMacthCfg.tbWeekend 			= {};
		EPlatForm.MacthType[szClassName].tbMacthCfg.tbCommon			= {};
		EPlatForm.MacthType[szClassName].tbMacthCfg.tbWeekend_Adv		= {};
		EPlatForm.MacthType[szClassName].tbMacthCfg.tbCommon_Adv		= {};	
		EPlatForm.MacthType[szClassName].tbMacthCfg.tbAdvMatch			= {};
		EPlatForm.MacthType[szClassName].tbMacthCfg.szBaseMission		= tbBaseMission[szClassName] or "";
		EPlatForm.MacthType[szClassName].tbDynMapLists	= {};
		EPlatForm.MacthType[szClassName].tbReadyMap 	= {};
		EPlatForm.MacthType[szClassName].tbMacthMap 	= {};
		EPlatForm.MacthType[szClassName].tbReadyPos		= {};
		EPlatForm.MacthType[szClassName].tbPkPos		= {};
		
		if tbFileName[nType] then
			local tbTypeFile = Lib:LoadTabFile("\\setting\\event\\eventplantform\\plantform_type\\"..tbFileName[nType])
			if not tbTypeFile then
				print("【活动平台】读取文件错误，文件不存在", tbFileName[nType]);
				return
			end
			for nId, tbParam in ipairs(tbTypeFile) do
				if nId > 1 then
					local szName 		= tbParam.Name;
					local szSignNpcName	= tbParam.SignNpcName;
					local nMemberCount  = tonumber(tbParam.MemberCount);
					local nPlayerCount  = tonumber(tbParam.PlayerCount);
					local nMeleeMaxCount	= tonumber(tbParam.MeleeMaxCount);
					local nMeleeMinCount	= tonumber(tbParam.MeleeMinCount);
					local nMinLevel		= tonumber(tbParam.MinLevel);
					local szDesc  		= tbParam.Desc;
					local nAdvIntoMap  	= tonumber(tbParam.IntoMap);
					local nAdvReadyMap  = tonumber(tbParam.ReadyMap);
					local nAdvMacthMap  = tonumber(tbParam.MacthMap);
					local nTimeCommonEnd	= tonumber(tbParam.Time_Common_End);
					local nTimeCommonStart	= tonumber(tbParam.Time_Common_Start);
					local nTimeCommonLong	= tonumber(tbParam.Time_Common_Long);
					local nTimeCommon_Adv_End	= tonumber(tbParam.Time_Common_Adv_End);
					local nTimeCommon_Adv_Start	= tonumber(tbParam.Time_Common_Adv_Start);
					local nTimeCommon_Adv_Long	= tonumber(tbParam.Time_Common_Adv_Long);
					local nTimeAdvMatch		= tonumber(tbParam.Time_AdvMatch);
					local nReadyTime_Common	= tonumber(tbParam.ReadyTime_Common);
					local nPKTime_Common	= tonumber(tbParam.PKTime_Common);
					local nReadyTime_Adv	= tonumber(tbParam.ReadyTime_Adv);
					local nPKTime_Adv		= tonumber(tbParam.PKTime_Adv);
					local nReadyTime_Sec	= tonumber(tbParam.ReadyTime_Sec);
					local nPKTime_Sec		= tonumber(tbParam.PKTime_Sec);
					local nMinTeamCount	= tonumber(tbParam.MinTeamCount);
					local nPlayCount_Player = tonumber(tbParam.PlayCount_Player);
					local nPlayCount_Team 	= tonumber(tbParam.PlayCount_Team);
					local szJoinItem		= tbParam.JoinItem;
					local nEnterItemCount	= tonumber(tbParam.EnterItemMaxCount);
					local nTeamWinScore		= tonumber(tbParam.TeamWinScore);
					local nTeamTieScore		= tonumber(tbParam.TeamTieScore);
					local nTeamLoseScore	= tonumber(tbParam.TeamLoseScore);
					local nMaxKinToNextRank	= tonumber(tbParam.MaxKinToNextRank);
					local nMinPlayerToNextScore = tonumber(tbParam.MinPlayerToNextScore);
					local szSkillId			= tbParam.ItemEffect;
					local nKinAwardNum		= tonumber(tbParam.KinAwardNum);
					local nSecReadyMaxTeam	= tonumber(tbParam.SecTeamMaxReadyCount);
					local nWeleeReadyMaxTeam	= tonumber(tbParam.MeleeMaxReadyCount);
					local nBagNeedFree		= tonumber(tbParam.BagNeedFree);

					
					if szName and szName ~= "" then
						EPlatForm.MacthType[szClassName].szName = szName;
					end
					
					if (szSignNpcName and szSignNpcName ~= "") then
						EPlatForm.MacthType[szClassName].szSignNpcName = szSignNpcName;
					end
					
					if szDesc and szDesc ~= "" then
						EPlatForm.MacthType[szClassName].szDesc = szDesc;
					end
					if nMemberCount then
						EPlatForm.MacthType[szClassName].tbMacthCfg.nMemberCount = nMemberCount;
					end
					if nPlayerCount then
						EPlatForm.MacthType[szClassName].tbMacthCfg.nPlayerCount = nPlayerCount;
					end
					
					if (nMeleeMaxCount) then
						EPlatForm.MacthType[szClassName].tbMacthCfg.nMeleeMaxCount = nMeleeMaxCount;
					end
					
					if (nMeleeMinCount) then
						EPlatForm.MacthType[szClassName].tbMacthCfg.nMeleeMinCount = nMeleeMinCount;
					end					
					
					if (nMinLevel) then
						EPlatForm.MacthType[szClassName].tbMacthCfg.nMinLevel	= nMinLevel;
					end
					
					if (nMinTeamCount) then
						EPlatForm.MacthType[szClassName].tbMacthCfg.nMinTeamCount = nMinTeamCount;
						EPlatForm.MACTH_LEAGUE_MIN	 = nMinTeamCount;
					end

					if (nPlayCount_Player) then
						EPlatForm.MacthType[szClassName].tbMacthCfg.nPlayCount_Player = nPlayCount_Player;
					end
					
					if (nPlayCount_Team) then
						EPlatForm.MacthType[szClassName].tbMacthCfg.nPlayCount_Team = nPlayCount_Team;
					end

					if (szJoinItem and string.len(szJoinItem) > 0) then
						local tbItem = Lib:SplitStr(szJoinItem);
						if (#tbItem > 0) then
							local tbInfo = {};
							for _, nId in ipairs(tbItem) do
								tbInfo[#tbInfo + 1] = tonumber(nId);
							end
							local tbItemSkill = {};
							if (szSkillId and szSkillId ~= "") then
								local tbList = Lib:SplitStr(szSkillId);
								for i, nId in ipairs(tbList) do
									tbList[i] = tonumber(nId);
								end
								tbItemSkill = tbList;
							end
							local tbItemInfo = {tbItem = tbInfo, tbItemSkill = tbItemSkill};
							if (not EPlatForm.MacthType[szClassName].tbMacthCfg.tbJoinItem) then
								EPlatForm.MacthType[szClassName].tbMacthCfg.tbJoinItem = {};
							end
							table.insert(EPlatForm.MacthType[szClassName].tbMacthCfg.tbJoinItem, tbItemInfo);
						end
					end
					
					if (nEnterItemCount) then
						EPlatForm.MacthType[szClassName].tbMacthCfg.nEnterItemCount = nEnterItemCount;
					end
					
					if (nReadyTime_Common) then
						EPlatForm.MacthType[szClassName].tbMacthCfg.nReadyTime_Common = nReadyTime_Common;
					end

					if (nReadyTime_Adv) then
						EPlatForm.MacthType[szClassName].tbMacthCfg.nReadyTime_Adv = nReadyTime_Adv;
					end

					if (nPKTime_Common) then
						EPlatForm.MacthType[szClassName].tbMacthCfg.nPKTime_Common = nPKTime_Common;
					end

					if (nPKTime_Adv) then
						EPlatForm.MacthType[szClassName].tbMacthCfg.nPKTime_Adv = nPKTime_Adv;
					end
					
					if (nReadyTime_Sec) then
						EPlatForm.MacthType[szClassName].tbMacthCfg.nReadyTime_Sec = nReadyTime_Sec;
					end					
					
					if (nPKTime_Sec) then
						EPlatForm.MacthType[szClassName].tbMacthCfg.nPKTime_Sec = nPKTime_Sec;
					end
					
					if (nTeamWinScore) then
						EPlatForm.MacthType[szClassName].tbMacthCfg.nTeamWinScore = nTeamWinScore;
					end

					if (nTeamTieScore) then
						EPlatForm.MacthType[szClassName].tbMacthCfg.nTeamTieScore = nTeamTieScore;
					end

					if (nTeamLoseScore) then
						EPlatForm.MacthType[szClassName].tbMacthCfg.nTeamLoseScore = nTeamLoseScore;
					end
					
					if (nSecReadyMaxTeam) then
						EPlatForm.MacthType[szClassName].tbMacthCfg.nSecReadyMaxTeam = nSecReadyMaxTeam;
					end
					
					if (nWeleeReadyMaxTeam) then
						EPlatForm.MacthType[szClassName].tbMacthCfg.nWeleeReadyMaxTeam = nWeleeReadyMaxTeam;
					end
					
					if (nKinAwardNum) then
						EPlatForm.MacthType[szClassName].tbMacthCfg.nKinAwardNum = nKinAwardNum;
					end
					
					if (nBagNeedFree) then
						EPlatForm.MacthType[szClassName].tbMacthCfg.nBagNeedFree = nBagNeedFree;
					end
					
					if (nTimeCommonStart and nTimeCommonEnd and nTimeCommonLong and 
						nTimeCommonStart > 0 and nTimeCommonEnd > 0 and nTimeCommonLong > 0) then
						local nTime = nTimeCommonStart;
						while nTime < nTimeCommonEnd do
							table.insert(EPlatForm.MacthType[szClassName].tbMacthCfg.tbCommon, nTime);
							nTime = nTime + nTimeCommonLong
							local nMod = math.fmod(nTime, 100);
							if (nMod >= 60) then
								nTime = nTime + 100 - 60;
							end
						end
					end

					if (nTimeCommon_Adv_Start and nTimeCommon_Adv_End and nTimeCommon_Adv_Long and
						nTimeCommon_Adv_Start > 0 and nTimeCommon_Adv_End > 0 and nTimeCommon_Adv_Long > 0) then
						local nTime = nTimeCommon_Adv_Start;
						while (nTime < nTimeCommon_Adv_End) do
							table.insert(EPlatForm.MacthType[szClassName].tbMacthCfg.tbCommon_Adv, nTime);
							nTime = nTime + nTimeCommon_Adv_Long;
							local nMod = math.fmod(nTime, 100);
							if (nMod >= 60) then
								nTime = nTime + 100 - 60;
							end							
						end
					end

					if (nTimeAdvMatch) then
						table.insert(EPlatForm.MacthType[szClassName].tbMacthCfg.tbAdvMatch, nTimeAdvMatch);
					end

					if nAdvReadyMap then
						table.insert(EPlatForm.MacthType[szClassName].tbReadyMap, nAdvReadyMap);
					end
					if nAdvMacthMap then
						table.insert(EPlatForm.MacthType[szClassName].tbMacthMap, nAdvMacthMap);
					end
					
					if (nMinPlayerToNextScore) then
						self.DEF_MIN_KINSCORE_PLAYER = nMinPlayerToNextScore;
					end
					
					if (nMaxKinToNextRank) then
						self.MAX_KINRANK_NEXTMATCH = nMaxKinToNextRank;
					end
				end
			end
			
			if not EPlatForm.MacthType[szClassName].szName then
				EPlatForm.MacthType[szClassName].szName = "【未填写类型】";
			end
			if not EPlatForm.MacthType[szClassName].szDesc then
				EPlatForm.MacthType[szClassName].szDesc = "【未填写描述】";
			end

			if not EPlatForm.MacthType[szClassName].tbMacthCfg.nMemberCount then
				EPlatForm.MacthType[szClassName].tbMacthCfg.nMemberCount = 0;
			end			
			if not EPlatForm.MacthType[szClassName].tbMacthCfg.nPlayerCount then
				EPlatForm.MacthType[szClassName].tbMacthCfg.nPlayerCount = 0;
			end
			if not EPlatForm.MacthType[szClassName].tbMacthCfg.nMeleeMaxCount then
				EPlatForm.MacthType[szClassName].tbMacthCfg.nMeleeMaxCount = 0;
			end
			if not EPlatForm.MacthType[szClassName].tbMacthCfg.nMeleeMinCount then
				EPlatForm.MacthType[szClassName].tbMacthCfg.nMeleeMinCount = 0;
			end			
			if not EPlatForm.MacthType[szClassName].tbMacthCfg.nMinLevel then
				EPlatForm.MacthType[szClassName].tbMacthCfg.nMinLevel = 99999;
			end
			
			if (not EPlatForm.MacthType[szClassName].tbMacthCfg.nTeamWinScore) then
				EPlatForm.MacthType[szClassName].tbMacthCfg.nTeamWinScore = 3;
			end

			if (not EPlatForm.MacthType[szClassName].tbMacthCfg.nTeamTieScore) then
				EPlatForm.MacthType[szClassName].tbMacthCfg.nTeamTieScore = 2;
			end	

			if (not EPlatForm.MacthType[szClassName].tbMacthCfg.nTeamLoseScore) then
				EPlatForm.MacthType[szClassName].tbMacthCfg.nTeamLoseScore = 1;
			end			

		end
		--加载pk场传入坐标
		if tbFileTrap[nType] then
			local tbTypeFile = Lib:LoadTabFile("\\setting\\event\\eventplantform\\plantform_trap\\"..tbFileTrap[nType]);
			if not tbTypeFile then
				print("【活动平台】读取文件错误，文件不存在", tbFileTrap[nType]);
				return
			end
			for nId, tbParam in ipairs(tbTypeFile) do
				local nPosX = tonumber(tbParam.PK_TRAPX);
				local nPosY = tonumber(tbParam.PK_TRAPY);
				if (nPosX and nPosY) then
					EPlatForm.MacthType[szClassName].tbPkPos[nId] = { math.floor(nPosX/32), math.floor(nPosY/32)};					
				end

				nPosX = tonumber(tbParam.READY_TRAPX);
				nPosY = tonumber(tbParam.READY_TRAPY);
				if (nPosX and nPosY) then
					EPlatForm.MacthType[szClassName].tbReadyPos[nId] = { math.floor(nPosX/32), math.floor(nPosY/32)};					
				end		
			end
		end
	end
end

--加载奖励分层表
function EPlatForm:LoadGameAwardRank(szFileName, nSession)
	local tbFile = Lib:LoadTabFile("\\setting\\event\\eventplantform\\plantform_award\\"..szFileName);
	if not tbFile then
		return
	end
	if not self.AWARD_LEVEL[nSession] then
		self.AWARD_LEVEL[nSession] = {[EPlatForm.MATCH_WELEE] = {}, [EPlatForm.MATCH_TEAMMATCH] = {}, [EPlatForm.MATCH_KINAWARD] = {}};
	end
	for nId, tbParam in ipairs(tbFile) do
		if nId > 1 then
			local nLevelType = tonumber(tbParam.LevelType);
			local nLevel1 = tonumber(tbParam.WeleeRank) or -1;
			local nLevel2 = tonumber(tbParam.PvpRank) or -1;
			if nLevel1 >= 0 then
				self.AWARD_LEVEL[nSession][EPlatForm.MATCH_WELEE][nLevelType] = nLevel1;
			end
			if nLevel2 >= 0 then
				self.AWARD_LEVEL[nSession][EPlatForm.MATCH_TEAMMATCH][nLevelType] = nLevel2;
				self.AWARD_LEVEL[nSession][EPlatForm.MATCH_KINAWARD][nLevelType] = nLevel2;
			end
		end
	end
end

function EPlatForm:LoadGameAward()
	EPlatForm.AWARD_SINGLE_LIST = {};
	EPlatForm.AWARD_FINISH_LIST = {};
	EPlatForm.AWARD_WELEE_LIST = {};
	EPlatForm.AWARD_KIN_LIST	= {};
	for nSession, tbSession in pairs(self.SEASON_TB) do
		if tbSession[2] then
			self:LoadGameAwardWeleeMatch("\\setting\\event\\eventplantform\\plantform_award\\"..tbSession[2].."_part1.txt", nSession, EPlatForm.MATCH_WELEE);
			self:LoadGameAwardTeamMatch("\\setting\\event\\eventplantform\\plantform_award\\"..tbSession[2].."_part2.txt", nSession, EPlatForm.MATCH_TEAMMATCH);
			self:LoadGameAwardKinMatch("\\setting\\event\\eventplantform\\plantform_award\\"..tbSession[2].."_part3.txt", nSession, EPlatForm.MATCH_KINAWARD);
		end
	end
end

--加载奖励
function EPlatForm:LoadGameAwardTeamMatch(szPath, nSession, nPart)
	local tbFile = Lib:LoadTabFile(szPath)
	if not tbFile then
		return
	end
	for nId, tbParam in ipairs(tbFile) do
		if nId > 1 then
			
			local szWin = tbParam.Win;
			local szTie = tbParam.Tie;
			local szLost = tbParam.Lost;
			
			if not EPlatForm.AWARD_SINGLE_LIST[nSession] then
				EPlatForm.AWARD_SINGLE_LIST[nSession] = {};
				EPlatForm.AWARD_SINGLE_LIST[nSession].Win = {};
				EPlatForm.AWARD_SINGLE_LIST[nSession].Tie = {};
				EPlatForm.AWARD_SINGLE_LIST[nSession].Lost = {};
			end
			if szWin and szWin ~= "" then
				local szType, Value = self:GetSplitValue(szWin)
				if not EPlatForm.AWARD_SINGLE_LIST[nSession].Win[szType] then
					EPlatForm.AWARD_SINGLE_LIST[nSession].Win[szType] = {};
				end
				table.insert(EPlatForm.AWARD_SINGLE_LIST[nSession].Win[szType], Value);
			end
			if szTie and szTie ~= "" then
				local szType, Value = self:GetSplitValue(szTie)
				if not EPlatForm.AWARD_SINGLE_LIST[nSession].Tie[szType] then
					EPlatForm.AWARD_SINGLE_LIST[nSession].Tie[szType] = {};
				end
				table.insert(EPlatForm.AWARD_SINGLE_LIST[nSession].Tie[szType], Value);
			end	
			if szLost and szLost ~= "" then
				local szType, Value = self:GetSplitValue(szLost)
				if not EPlatForm.AWARD_SINGLE_LIST[nSession].Lost[szType] then
					EPlatForm.AWARD_SINGLE_LIST[nSession].Lost[szType] = {};
				end
				table.insert(EPlatForm.AWARD_SINGLE_LIST[nSession].Lost[szType], Value);
			end
			
			if not EPlatForm.AWARD_FINISH_LIST[nSession] then
				EPlatForm.AWARD_FINISH_LIST[nSession] = {};
			end		
			for nId in pairs(self.AWARD_LEVEL[nSession][nPart]) do
				if not EPlatForm.AWARD_FINISH_LIST[nSession][nId] then
					EPlatForm.AWARD_FINISH_LIST[nSession][nId] = {};
				end
				local szAward = tbParam["RankType"..nId];
				if szAward and szAward ~= "" then
					local szType, Value = self:GetSplitValue(szAward)
					if not EPlatForm.AWARD_FINISH_LIST[nSession][nId][szType] then
						EPlatForm.AWARD_FINISH_LIST[nSession][nId][szType] = {};
					end
					table.insert(EPlatForm.AWARD_FINISH_LIST[nSession][nId][szType], Value);
				end
			end
		end
	end
end

--加载奖励
function EPlatForm:LoadGameAwardKinMatch(szPath, nSession, nPart)
	local tbFile = Lib:LoadTabFile(szPath)
	if not tbFile then
		return
	end
	for nId, tbParam in ipairs(tbFile) do
		if nId > 1 then	
			if not EPlatForm.AWARD_KIN_LIST[nSession] then
				EPlatForm.AWARD_KIN_LIST[nSession] = {};
			end
			for nId in pairs(self.AWARD_LEVEL[nSession][nPart]) do
				if not EPlatForm.AWARD_KIN_LIST[nSession][nId] then
					EPlatForm.AWARD_KIN_LIST[nSession][nId] = {};
				end
				local szAward = tbParam["RankType"..nId];
				if szAward and szAward ~= "" then
					local szType, Value = self:GetSplitValue(szAward)
					if not EPlatForm.AWARD_KIN_LIST[nSession][nId][szType] then
						EPlatForm.AWARD_KIN_LIST[nSession][nId][szType] = {};
					end
					table.insert(EPlatForm.AWARD_KIN_LIST[nSession][nId][szType], Value);
				end
			end
		end
	end
end

--加载奖励
function EPlatForm:LoadGameAwardWeleeMatch(szPath, nSession, nPart)
	local tbFile = Lib:LoadTabFile(szPath)
	if not tbFile then
		return
	end
	for nId, tbParam in ipairs(tbFile) do
		if nId > 1 then
			if not EPlatForm.AWARD_WELEE_LIST[nSession] then
				EPlatForm.AWARD_WELEE_LIST[nSession] = {};
			end		
			for nId in pairs(self.AWARD_LEVEL[nSession][nPart]) do
				if not EPlatForm.AWARD_WELEE_LIST[nSession][nId] then
					EPlatForm.AWARD_WELEE_LIST[nSession][nId] = {};
				end
				local szAward = tbParam["RankType"..nId];
				if szAward and szAward ~= "" then
					local szType, Value = self:GetSplitValue(szAward)
					if not EPlatForm.AWARD_WELEE_LIST[nSession][nId][szType] then
						EPlatForm.AWARD_WELEE_LIST[nSession][nId][szType] = {};
					end
					table.insert(EPlatForm.AWARD_WELEE_LIST[nSession][nId][szType], Value);
				end
			end
		end
	end
end

function EPlatForm:GetSplitValue(szStr)
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

EPlatForm:LoadGameTable();

if not MODULE_GAMECLIENT then
EPlatForm:LoadGameType();
EPlatForm:LoadGameAward();
end
