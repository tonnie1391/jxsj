-- 文件名　：plantform_file.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-09-20 20:54:11
-- 功能    ：无差别竞技


Require("\\script\\event\\neweventplantform\\plantform_def.lua")

--加载联赛表
function NewEPlatForm:LoadGameTable()
	local tbFile = Lib:LoadTabFile("\\setting\\event\\neweventplantform\\plantform_table.txt")
	if not tbFile then
		return
	end
	for nId, tbParam in ipairs(tbFile) do
		if nId > 1 then
			local nSession 		= tonumber(tbParam.Session);
			local nEventType 	= tonumber(tbParam.EventType);
			local szAwardFile 	= tbParam.AwardFile;			
			local szDesc 		= tbParam.Desc;
			self.SEASON_TB[nSession] = {nEventType, szAwardFile, szDesc};			
			self:LoadGameAward(szAwardFile, nSession);	
		end
	end	
end


--加载奖励
function NewEPlatForm:LoadGameAward(szFileName, nSession)
	local szPath = "\\setting\\event\\neweventplantform\\plantform_award\\"..szFileName;
	local tbFile = Lib:LoadTabFile(szPath)
	if not tbFile then
		return
	end
	for nId, tbParam in ipairs(tbFile) do
		if nId > 0 then
			if not self.AWARD_WELEE_LIST[nSession] then
				self.AWARD_WELEE_LIST[nSession] = {};
			end
			for nId = 1, 8 do
				if not self.AWARD_WELEE_LIST[nSession][nId] then
					self.AWARD_WELEE_LIST[nSession][nId] = {};
				end
				local szAward = tbParam["RankType"..nId];
				if szAward and szAward ~= "" then
					local szType, Value = self:GetSplitValue(szAward);
					table.insert(self.AWARD_WELEE_LIST[nSession][nId], {szType, Value});
				end
			end
		end
	end
end


--加载联赛类型表
function NewEPlatForm:LoadGameType()
	local tbFile = Lib:LoadTabFile("\\setting\\event\\neweventplantform\\plantform_type.txt")
	if not tbFile then
		return
	end
	self.MACTH_TYPE = {};
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
			self.MACTH_TYPE[nEventType] = tbParam.ClassName;
			if (tbParam.MissionType ~= "" and tbParam.ClassName and tbParam.ClassName ~= "") then
				tbBaseMission[tbParam.ClassName] = tbParam.MissionType;
			end
		end
	end
	self.MacthType = {};
	for nType, szClassName in pairs(self.MACTH_TYPE) do
		self.MacthType[szClassName] = {};
		self.MacthType[szClassName].tbMacthCfg					= {};
		self.MacthType[szClassName].tbMacthCfg.tbWeekend 			= {};
		self.MacthType[szClassName].tbMacthCfg.tbCommon			= {};
		self.MacthType[szClassName].tbMacthCfg.tbWeekend_Adv		= {};
		self.MacthType[szClassName].tbMacthCfg.tbCommon_Adv		= {};	
		self.MacthType[szClassName].tbMacthCfg.tbAdvMatch			= {};
		self.MacthType[szClassName].tbMacthCfg.szBaseMission		= tbBaseMission[szClassName] or "";
		self.MacthType[szClassName].tbDynMapLists	= {};
		self.MacthType[szClassName].tbReadyMap 	= {};
		self.MacthType[szClassName].tbMacthMap 	= {};
		self.MacthType[szClassName].tbReadyPos		= {};
		self.MacthType[szClassName].tbPkPos		= {};
		
		if tbFileName[nType] then
			local tbTypeFile = Lib:LoadTabFile("\\setting\\event\\neweventplantform\\plantform_type\\"..tbFileName[nType])
			if not tbTypeFile then
				print("【活动平台】读取文件错误，文件不存在", tbFileName[nType]);
				return
			end
			for nId, tbParam in ipairs(tbTypeFile) do
				if nId > 1 then
					local szName 		= tbParam.Name;
					local nPlayerCount  = tonumber(tbParam.PlayerCount);
					local nMeleeMaxCount	= tonumber(tbParam.MeleeMaxCount);
					local nMeleeMinCount	= tonumber(tbParam.MeleeMinCount);
					local nMinLevel		= tonumber(tbParam.MinLevel);
					local szDesc  		= tbParam.Desc;
					local nAdvReadyMap  = tonumber(tbParam.ReadyMap);
					local nAdvMacthMap  = tonumber(tbParam.MacthMap);
					local nTimeCommonEnd	= tonumber(tbParam.Time_Common_End);
					local nTimeCommonStart	= tonumber(tbParam.Time_Common_Start);
					local nTimeCommonLong	= tonumber(tbParam.Time_Common_Long);
					local nReadyTime_Common	= tonumber(tbParam.ReadyTime_Common);
					local nPKTime_Common	= tonumber(tbParam.PKTime_Common);
					local nPlayCount_Player = tonumber(tbParam.PlayCount_Player);
					local nWeleeReadyMaxTeam	= tonumber(tbParam.MeleeMaxReadyCount);
					local nBagNeedFree		= tonumber(tbParam.BagNeedFree);
					local szJoinItem		= tbParam.JoinItem;
					local szSkillId			= tbParam.ItemEffect;
					local nEnterItemCount	= tonumber(tbParam.EnterItemMaxCount);
					if szName and szName ~= "" then
						self.MacthType[szClassName].szName = szName;
					end					
					
					if szDesc and szDesc ~= "" then
						self.MacthType[szClassName].szDesc = szDesc;
					end
					if nPlayerCount then
						self.MacthType[szClassName].tbMacthCfg.nPlayerCount = nPlayerCount;
					end
					
					if (nMeleeMaxCount) then
						self.MacthType[szClassName].tbMacthCfg.nMeleeMaxCount = nMeleeMaxCount;
					end
					
					if (nMeleeMinCount) then
						self.MacthType[szClassName].tbMacthCfg.nMeleeMinCount = nMeleeMinCount;
					end					
					
					if (nMinLevel) then
						self.MacthType[szClassName].tbMacthCfg.nMinLevel	= nMinLevel;
					end
					
					if (nPlayCount_Player) then
						self.MacthType[szClassName].tbMacthCfg.nPlayCount_Player = nPlayCount_Player;
					end
					
					if (nBagNeedFree) then
						self.MacthType[szClassName].tbMacthCfg.nBagNeedFree = nBagNeedFree;
					end
					
					if (nReadyTime_Common) then
						self.MacthType[szClassName].tbMacthCfg.nReadyTime_Common = nReadyTime_Common;
					end

					if (nPKTime_Common) then
						self.MacthType[szClassName].tbMacthCfg.nPKTime_Common = nPKTime_Common;
					end		
					
					if nAdvReadyMap then
						table.insert(self.MacthType[szClassName].tbReadyMap, nAdvReadyMap);
					end
					if nAdvMacthMap then
						table.insert(self.MacthType[szClassName].tbMacthMap, nAdvMacthMap);
					end
					
					if (nWeleeReadyMaxTeam) then
						self.MacthType[szClassName].tbMacthCfg.nWeleeReadyMaxTeam = nWeleeReadyMaxTeam;
					end
					
					if (nTimeCommonStart and nTimeCommonEnd and nTimeCommonLong and 
						nTimeCommonStart > 0 and nTimeCommonEnd > 0 and nTimeCommonLong > 0) then
						local nTime = nTimeCommonStart;
						while nTime < nTimeCommonEnd do
							table.insert(self.MacthType[szClassName].tbMacthCfg.tbCommon, nTime);
							nTime = nTime + nTimeCommonLong
							local nMod = math.fmod(nTime, 100);
							if (nMod >= 60) then
								nTime = nTime + 100 - 60;
							end
						end
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
							if (not self.MacthType[szClassName].tbMacthCfg.tbJoinItem) then
								self.MacthType[szClassName].tbMacthCfg.tbJoinItem = {};
							end
							table.insert(self.MacthType[szClassName].tbMacthCfg.tbJoinItem, tbItemInfo);
						end
					end
					if (nEnterItemCount) then
						self.MacthType[szClassName].tbMacthCfg.nEnterItemCount = nEnterItemCount;
					end
				end
			end
			
			if not self.MacthType[szClassName].szName then
				self.MacthType[szClassName].szName = "【未填写类型】";
			end
			if not self.MacthType[szClassName].szDesc then
				self.MacthType[szClassName].szDesc = "【未填写描述】";
			end

			if not self.MacthType[szClassName].tbMacthCfg.nPlayerCount then
				self.MacthType[szClassName].tbMacthCfg.nPlayerCount = 0;
			end
			if not self.MacthType[szClassName].tbMacthCfg.nMeleeMaxCount then
				self.MacthType[szClassName].tbMacthCfg.nMeleeMaxCount = 0;
			end
			if not self.MacthType[szClassName].tbMacthCfg.nMeleeMinCount then
				self.MacthType[szClassName].tbMacthCfg.nMeleeMinCount = 0;
			end			
			if not self.MacthType[szClassName].tbMacthCfg.nMinLevel then
				self.MacthType[szClassName].tbMacthCfg.nMinLevel = 99999;
			end
		end
		--加载pk场传入坐标
		if tbFileTrap[nType] then
			local tbTypeFile = Lib:LoadTabFile("\\setting\\event\\neweventplantform\\plantform_trap\\"..tbFileTrap[nType]);
			if not tbTypeFile then
				print("【活动平台】读取文件错误，文件不存在", tbFileTrap[nType]);
				return
			end
			for nId, tbParam in ipairs(tbTypeFile) do
				local nPosX = tonumber(tbParam.PK_TRAPX);
				local nPosY = tonumber(tbParam.PK_TRAPY);
				if (nPosX and nPosY) then
					self.MacthType[szClassName].tbPkPos[nId] = { math.floor(nPosX/32), math.floor(nPosY/32)};					
				end

				nPosX = tonumber(tbParam.READY_TRAPX);
				nPosY = tonumber(tbParam.READY_TRAPY);
				if (nPosX and nPosY) then
					self.MacthType[szClassName].tbReadyPos[nId] = { math.floor(nPosX/32), math.floor(nPosY/32)};					
				end		
			end
		end
	end
end

function NewEPlatForm:GetSplitValue(szStr)
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

if not MODULE_GAMECLIENT then
	NewEPlatForm:LoadGameTable();
	NewEPlatForm:LoadGameType();
end
