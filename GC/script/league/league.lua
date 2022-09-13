--战队相关

League.LEAGUE_TYPE = 
	{
		LEAGUETYPE_NONE 				= 0,
		LEAGUETYPE_MATCH				= 1,	-- 联赛
		LEAGUETYPE_SONGJINBATTLE		= 2,	-- 宋金
		LEAGUETYPE_TRANS_ZONE			= 3,	-- 转服
		LEAGUETYPE_TRANS_ZONE_NEW		= 4,	
		LEAGUETYPE_MATCH_NEW			= 5,	
		LEAGUETYPE_OLDPLAYER			= 6,	-- 老玩家回归
		LEAGUETYPE_EVENTPLANTFORM		= 7,	-- 家族竞技平台
		
		-- 跨服武林联赛
		LEAGUETYPE_WLDH_SINGLE_FACTION	= 8,	-- 单人门派赛
		LEAGUETYPE_WLDH_DOUBLE			= 9,	-- 双人赛
		LEAGUETYPE_WLDH_DATTLE			= 10,	-- 团体赛
		LEAGUETYPE_WLDH_TRIANGLE		= 11,	-- 三人赛
		LEAGUETYPE_WLDH_FIFTH_SERIES	= 12,	-- 五行五人赛
		LEAGUETYPE_WLDH_CHANNEL			= 13,	-- 跨服联赛聊天频道用战队
		LEAGUETYPE_XKLAND				= 14,	-- 铁浮城战队
		
		LEAGUETYPE_VITUAL_JB			= 65535,-- 虚拟金币
		LEAGUETYPE_RESERVED				= 65536,-- 系统保留
		
		LEAGUETYPE_MODULE_STATE	,
	}

--战队历史记录，战队变量对应的描述
League.LEAGUE_HISTORY_TASKSTR = 
{
	--联赛类型
	[League.LEAGUE_TYPE.LEAGUETYPE_MATCH_NEW] = 
		{
			[1] = "届数",
			[4] = "联赛等级",
			[5] = "循环赛排名",
			[6] = "胜利场次",
			[7] = "平局场次",
			[8] = "总场次",
			[17] = "八强赛排名",
		},
	[League.LEAGUE_TYPE.LEAGUETYPE_EVENTPLANTFORM] = 
		{
			[1] = "届数",
			[4] = "联赛等级",
			[5] = "循环赛排名",
			[6] = "胜利场次",
			[7] = "平局场次",
			[8] = "总场次",
			[17] = "八强赛排名",
		},
};


--战队操作(数据写操作都要在GC执行)----------

--获得战队数量
function League:GetLeagueCount(nType)
	local pLeagueSet = KLeague.GetLeagueSetObject(nType);
	if pLeagueSet ~= nil then
		return pLeagueSet.nLeagueCount;
	end
end

--增加战队 (nSync==nil or 0 代表默认同步，否则1为不同步)
function League:AddLeague(nType, szLeagueName, nSync)
	if not nSync or nSync == 0 then
		return KLeague.AddLeague(nType, szLeagueName);
	else
		local pLeagueSet = KLeague.GetLeagueSetObject(nType);
		return pLeagueSet.AddLeague(szLeagueName);
	end
end

--删除战队
function League:DelLeague(nType, szLeagueName, nSync)
	if not nSync or nSync == 0 then
		return KLeague.DelLeague(nType, szLeagueName);
	else
		local pLeagueSet = KLeague.GetLeagueSetObject(nType);
		return pLeagueSet.DelLeague(szLeagueName);
	end
end

--查找战队(返回战队对象,没找到则返回nil)
function League:FindLeague(nType, szLeagueName)
	local pLeagueSet = KLeague.GetLeagueSetObject(nType);
	return pLeagueSet.FindLeague(szLeagueName);
end

--获得战队成员数量(返回成员数量,没找到则返回nil)
function League:GetMemberCount(nType, szLeagueName)
	return KLeague.GetLeagueMemberCount(nType, szLeagueName)
end

--获得战队任务变量(返回变量值,没找到战队则返回nil)
function League:GetLeagueTask(nType, szLeagueName, nTaskId)
	return KLeague.GetLeagueTask(nType, szLeagueName, nTaskId)
end

--设置战队任务变量(成功设置返回1,没找到战队则返回nil)
function League:SetLeagueTask(nType, szLeagueName, nTaskId, nTaskValue, nSync)
	if not nSync or nSync == 0 then
		return KLeague.SetLeagueTask(nType, szLeagueName, nTaskId, nTaskValue)
	else
		local pLeagueSet = KLeague.GetLeagueSetObject(nType);
		local pLeague 	 = pLeagueSet.FindLeague(szLeagueName);
		if pLeague then
			return pLeague.SetTask(nTaskId, nTaskValue);
		end
	end
	return;
end

-- 添加战队并把成员也加进去
function League:CreateLeagueWithMember(nType, szLeagueName, tbMemberList)
	if League:FindLeague(nType, szLeagueName) then
		return 0;
	end
	local nSync = 1;
	League:AddLeague(nType, szLeagueName, nSync);

	for nId, tbPlayer in ipairs(tbMemberList) do
		League:AddMember(nType, szLeagueName, tbPlayer.szName, nSync)
	end
	if (MODULE_GC_SERVER) then
		GlobalExcute{"League:CreateLeagueWithMember", nType, szLeagueName, tbMemberList};
	end	
end
--战队成员操作---------------

--增加战队成员
function League:AddMember(nType, szLeagueName, szMemberName, nSync)
	if not nSync or nSync == 0 then
		return KLeague.AddLeagueMember(nType, szLeagueName, szMemberName);
	else
		local pLeagueSet = KLeague.GetLeagueSetObject(nType);
		return pLeagueSet.AddLeagueMember(szLeagueName, szMemberName);
	end
end

--删除战队成员
function League:DelMember(nType, szLeagueName, szMemberName, nSync)
	local pLeagueSet = KLeague.GetLeagueSetObject(nType);
	local nLeague = pLeagueSet.DelLeagueMember(szLeagueName, szMemberName);	
	if (MODULE_GC_SERVER) and nLeague and (nSync == nil or nSync == 0) then
		GlobalExcute({"League:DelMember", nType, szLeagueName, szMemberName, nSync});
	end
end

--查找成员所在的战队名(返回战队名,没找到则返回nil)
function League:GetMemberLeague(nType, szMemberName)
	local szLeagueName = KLeague.GetMemberLeague(nType, szMemberName);
	if szLeagueName and not League:FindLeague(nType, szLeagueName) then
		if (not MODULE_GC_SERVER) then
			GCExcute({"League:RepairMemberLeague", nType, szLeagueName, szMemberName})
		else
			League:RepairMemberLeague(nType, szLeagueName, szMemberName)
		end
		return nil
	end
	return szLeagueName
end

--战队数据错误修复
function League:RepairMemberLeague(nType, szLeagueName, szMemberName)
	KLeague.RepairMemberLeague(nType, szLeagueName, szMemberName);
	if (MODULE_GC_SERVER) then
		GlobalExcute({"League:RepairMemberLeague", nType, szLeagueName, szMemberName});
	end
	if (MODULE_GAMESERVER) then
		local pPlayer = KPlayer.GetPlayerByName(szMemberName);
		if (pPlayer) then
			pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("战队数据错误修复 战队名：%s, 玩家名：%s，类型：%d", szLeagueName, szMemberName, nType));
		end
		Dbg:WriteLogEx(Dbg.LOG_INFO, "League", "RepairMemberLeague", szMemberName, szLeagueName, nType, "战队数据错误修复");
	end
end

--查找成员(返回成员对象,没找到则返回nil)
function League:FindMember(nType, szLeagueName, szMemberName)
	local pLeagueSet = KLeague.GetLeagueSetObject(nType);
	local pLeague 	 = pLeagueSet.FindLeague(szLeagueName);
	local pMember;
	if pLeague then
		pMember = pLeague.GetMember(szMemberName)
	end
	return pMember;
end

--获得成员任务变量(返回变量值,没找到则返回nil)
function League:GetMemberTask(nType, szLeagueName, szMemberName, nTaskId)
	return KLeague.GetLeagueMemberTask(nType, szLeagueName, szMemberName, nTaskId);
end

--设置成员任务变量(成功设置返回1,没找到则返回nil)
function League:SetMemberTask(nType, szLeagueName, szMemberName, nTaskId, nTaskValue, nSync)
	if not nSync or nSync == 0 then
		return KLeague.SetLeagueMemberTask(nType, szLeagueName, szMemberName, nTaskId, nTaskValue);
	else
		local pLeagueSet = KLeague.GetLeagueSetObject(nType);
		local pLeague 	 = pLeagueSet.FindLeague(szLeagueName);
		if pLeague then
			local pMember = pLeague.GetMember(szMemberName);
			if pMember then
				return pMember.SetTask(nTaskId, nTaskValue);
			end
		end
	end
	return;
end

--获得战队的所有成员列表
function League:GetMemberList(nType, szLeagueName)
	local tbMemberList = {};
	local pLeague = self:FindLeague(nType, szLeagueName);
	if not pLeague then
		return tbMemberList;
	end
	local pMemberItor = pLeague.GetMemberItor();
	local pMember =  pMemberItor.GetCurMember();
	while(pMember) do
		table.insert(tbMemberList, pMember.szName)
		pMember = pMemberItor.NextMember();
	end
	return tbMemberList;
end



--清空所有战队列表
function League:ClearLeague(nType)
	local pLeagueSet 	= KLeague.GetLeagueSetObject(nType);
	local pLeagueItor 	= pLeagueSet.GetLeagueItor();
	local pLeague 		= pLeagueItor.GetCurLeague();
	local tbLeagueList 	= {};
	while(pLeague) do
		table.insert(tbLeagueList, pLeague.szName);
		pLeague = pLeagueItor.NextLeague();
	end
	for ni, szLeagueName in pairs(tbLeagueList) do
		League:DelLeague(nType, szLeagueName, 1);
	end
	if (MODULE_GC_SERVER) then
		GlobalExcute({"League:ClearLeague", nType});
	end
end


--调试操作

--输出所有战队列表
function League:_DebugGetLeagueList(nType)
	local pLeagueSet = KLeague.GetLeagueSetObject(nType);
	print("----LEAGUE LIST----");
	print("LEAGUE COUNT:", pLeagueSet.nLeagueCount);
	print("序列","战队名")
	local pLeagueItor = pLeagueSet.GetLeagueItor();
	local pLeague =  pLeagueItor.GetCurLeague();
	local nCount = 1;
	while(pLeague) do
		print(nCount, pLeague.szName);
		pLeague = pLeagueItor.NextLeague();
		nCount = nCount + 1;
	end
	print("----EndOutLog----");
	if MODULE_GAMESERVER then
		GCExcute({"League:_DebugGetLeagueList", nType});	
	end
end

--输出战队的所有成员列表
function League:_DebugGetMemberList(nType, szLeagueName)
	local pLeague = self:FindLeague(nType, szLeagueName);
	if not pLeague then
		print(szLeagueName,"战队不存在");
		return
	end
	print("----"..szLeagueName.."LEAGUE LIST----");
	print("LEAGUE MEMBER COUNT:", pLeague.nMemberCount);
	print("序列","成员名")
	local pMemberItor = pLeague.GetMemberItor();
	local pMember =  pMemberItor.GetCurMember();
	local nCount = 1;
	while(pMember) do
		print(nCount, pMember.szName);
		pMember = pMemberItor.NextMember();
		nCount = nCount + 1;
	end
	print("----EndOutLog----");
	if MODULE_GAMESERVER then
		GCExcute({"League:_DebugGetMemberList", nType, szLeagueName});	
	end
end


--战队系统写历史文件，平台查询使用。
--文件保存于\gamecenter\playerladder\leaguehistory\lgtype(类型号)_(日期号).txt
--nLgType：战队类型
--...扩展参数想存的战队的任务变量值
function League:WriteFileHisory(nLgType, ...)
	local nSec = GetTime();
	local szDay = os.date("%d",nSec);
	local szDate = os.date("%Y%m%d%H%M",nSec);
	local szOutFile = "\\playerladder\\leaguehistory\\lgtype"..nLgType.."_"..szDay..".txt";
	local szTitle = "Date\tLeagueName\tLeagueMembers";
	if arg then
		for _, nTaskId in ipairs(arg) do
				local nValue = "LeagueTask_"..nTaskId;
				szTitle = szTitle .. "\t" ..nValue;
		end
	end
	szTitle = szTitle .."\r\n";
	KFile.WriteFile(szOutFile, szTitle);
	local pLeagueSet = KLeague.GetLeagueSetObject(nLgType);
	local pLeagueItor = pLeagueSet.GetLeagueItor();
	local pLeague =  pLeagueItor.GetCurLeague();
	local nCount = 1;
	while(pLeague) do
		local szLeagueName = pLeague.szName;
		local szTask = "";
		for _, nTaskId in ipairs(arg) do
			local nValue = KLeague.GetLeagueTask(nLgType, szLeagueName, nTaskId) or 0;
			szTask = szTask .. "\t" ..nValue;
		end
		local pMemberItor = pLeague.GetMemberItor();
		local pMember =  pMemberItor.GetCurMember();
		local szMemberNames = "";
		local nMemCount = 1;
		while(pMember) do
			local nSplit = ",";
			if nMemCount == 1 then
				nSplit = "";
			end
			szMemberNames = szMemberNames .. nSplit ..pMember.szName;
			pMember = pMemberItor.NextMember();
			nMemCount = nMemCount + 1;
		end
		local szContent = szDate .. "\t".. szLeagueName.."\t"..szMemberNames .. szTask .."\r\n";
		KFile.AppendFile(szOutFile, szContent);	
		pLeague = pLeagueItor.NextLeague();
		nCount = nCount + 1;
	end
end

--通过战队名获取历史信息
--日期格式:YYYYMMDD
function League:GetFileHistoryInforByLeague(nLgType, nDate, szLeagueName)
	local nSec = Lib:GetDate2Time(nDate)
	local szDay = os.date("%d",nSec);
	local nNeedDate = tonumber(os.date("%Y%m%d",nSec));
	local szFile = "\\playerladder\\leaguehistory\\lgtype"..nLgType.."_"..szDay..".txt";
	self.tbLeagueHistory = self.tbLeagueHistory or {};
	self.tbLeagueHistory[nLgType] = self.tbLeagueHistory[nLgType] or {};
	self.tbLeagueHistory[nLgType][nDate] = self.tbLeagueHistory[nLgType][nDate] or {};
	local tbFileTitle = {["LeagueName"]="战队名",["LeagueMembers"]="成员列表",["Date"]="日期"};
	if not self.tbLeagueHistory[nLgType][nDate].tbLeagues then
		local tbFileData = Lib:LoadTabFile(szFile)
		if not tbFileData then
			return "该日期的历史数据不存在";
		end
		for _, tbData in pairs(tbFileData) do
			local nFileSec = Lib:GetDate2Time(tonumber(tbData.Date));
			local nFileDate = tonumber(os.date("%Y%m%d",nFileSec));
			local szDateOut = os.date("%Y-%m-%d %H:%M", nFileSec);
			if nNeedDate == nFileDate then
				self.tbLeagueHistory[nLgType][nDate].tbLeagues = self.tbLeagueHistory[nLgType][nDate].tbLeagues or {};
				local tbLeagues = self.tbLeagueHistory[nLgType][nDate].tbLeagues;
				tbLeagues[tbData.LeagueName] = {};
				tbLeagues[tbData.LeagueName].LeagueMembers = tbData.LeagueMembers;
				tbLeagues[tbData.LeagueName].Date = szDateOut;
				for szKey, szValue in pairs(tbData) do
					if not tbFileTitle[szKey] then
						tbLeagues[tbData.LeagueName][szKey] = szValue;
					end
				end
			end
		end
	end
	if not self.tbLeagueHistory[nLgType][nDate].tbLeagues then
		return "该日期的历史数据不存在";
	end
	if not self.tbLeagueHistory[nLgType][nDate].tbLeagues[szLeagueName] then
		return "没有该战队历史数据";
	end
	local tbResult = {};
	for szKey, szValue in pairs(self.tbLeagueHistory[nLgType][nDate].tbLeagues[szLeagueName]) do
		if tbFileTitle[szKey] then
			table.insert(tbResult, 1, self:GetHistoryTaskName(nLgType, szKey)..":"..szValue);
		else
			table.insert(tbResult, self:GetHistoryTaskName(nLgType, szKey)..":"..szValue);
		end
	end
	local szResult = "\n".."QueryLeagueName:"..szLeagueName.."\n"..table.concat(tbResult, "\n");
	return szResult
end

--通过成员名获取战队历史数据
--日期格式:YYYYMMDD
function League:GetFileHistoryInforByMember(nLgType, nDate, szMember)
	local nSec = Lib:GetDate2Time(nDate)
	local szDay = os.date("%d",nSec);
	local nNeedDate = tonumber(os.date("%Y%m%d",nSec));
	local szFile = "\\playerladder\\leaguehistory\\lgtype"..nLgType.."_"..szDay..".txt";
	self.tbLeagueHistory = self.tbLeagueHistory or {};
	self.tbLeagueHistory[nLgType] = self.tbLeagueHistory[nLgType] or {};
	self.tbLeagueHistory[nLgType][nDate] = self.tbLeagueHistory[nLgType][nDate] or {};
	local tbFileTitle = {["LeagueName"]="战队名",["LeagueMembers"]="成员列表",["Date"]="日期"};
	if not self.tbLeagueHistory[nLgType][nDate].tbMembers then
		local tbFileData = Lib:LoadTabFile(szFile)
		if not tbFileData then
			return "该日期的历史数据不存在";
		end
		for _, tbData in pairs(tbFileData) do
			local nFileSec = Lib:GetDate2Time(tonumber(tbData.Date));
			local nFileDate = tonumber(os.date("%Y%m%d",nFileSec));
			local szDateOut = os.date("%Y-%m-%d %H:%M", nFileSec);
			if nNeedDate == nFileDate then
				self.tbLeagueHistory[nLgType][nDate].tbMembers = self.tbLeagueHistory[nLgType][nDate].tbMembers or {};
				local tbMembers = self.tbLeagueHistory[nLgType][nDate].tbMembers;
				local tbFileMember = Lib:SplitStr(tbData.LeagueMembers);
				for _, szFileMember in pairs(tbFileMember) do
					if szFileMember ~= "" then
						tbMembers[szFileMember] = {};
						tbMembers[szFileMember].LeagueName = tbData.LeagueName;
						tbMembers[szFileMember].LeagueMembers = tbData.LeagueMembers;
						tbMembers[szFileMember].Date = szDateOut;
						for szKey, szValue in pairs(tbData) do
							if not tbFileTitle[szKey] then
								tbMembers[szFileMember][szKey] = szValue;
							end
						end
					end
				end
			end
		end
	end
	if not self.tbLeagueHistory[nLgType][nDate].tbMembers then
		return "该日期的历史数据不存在";
	end
	if not self.tbLeagueHistory[nLgType][nDate].tbMembers[szMember] then
		return "没有该成员的战队历史数据";
	end
	local tbResult = {};
	for szKey, szValue in pairs(self.tbLeagueHistory[nLgType][nDate].tbMembers[szMember]) do
		if tbFileTitle[szKey] then
			table.insert(tbResult, 1, self:GetHistoryTaskName(nLgType, szKey)..":"..szValue);
		else
			table.insert(tbResult, self:GetHistoryTaskName(nLgType, szKey)..":"..szValue);
		end
	end
	local szResult = "\n".."QueryMemberName:"..szMember.."\n"..table.concat(tbResult, "\n");
	return szResult	
end

--通过战队类型和历史log类型获得描述
--派对League.LEAGUE_HISTORY_TASKSTR表来使用
function League:GetHistoryTaskName(nLgType, szKey)
	if not League.LEAGUE_HISTORY_TASKSTR[nLgType] then
		return szKey;
	end
	local tbTask = Lib:SplitStr(szKey, "_");
	if tbTask and tbTask[1] and tbTask[1] == "LeagueTask" then
		if tonumber(tbTask[2]) then
			return League.LEAGUE_HISTORY_TASKSTR[nLgType][tonumber(tbTask[2])] or szKey;
		end
	end
	return szKey;
end
