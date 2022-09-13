-------------------------------------------------------
-- 文件名　：xkland_league.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-04-08 17:03:16
-- 文件描述：
-------------------------------------------------------

Require("\\script\\globalserverbattle\\xkland\\xkland_def.lua");

Xkland.LEAGUE_TYPE = 14;

-- 战队任务变量
Xkland.LGTASK_GROUP_INDEX		= 1; 	-- 军团编号
Xkland.LGTASK_TONG_COUNT		= 2;	-- 军团帮会数量

-- 成员任务变量
Xkland.LGMTASK_CAPTAIN			= 1;	-- 是否队长(领袖)
Xkland.LGMTASK_GROUP_INDEX		= 2;	-- 军团索引
Xkland.LGMTASK_GATEWAY			= 3;	-- 所在区服

-- 创建战队
function Xkland:CreateLeague(szLeagueName, nLeagueIndex, tbCaptain)
	
	if League:FindLeague(self.LEAGUE_TYPE, szLeagueName) then
		return 0;
	end
	
	local nSync = nil;
	League:AddLeague(self.LEAGUE_TYPE, szLeagueName, nSync);
	
	League:SetLeagueTask(self.LEAGUE_TYPE, szLeagueName, self.LGTASK_GROUP_INDEX, nLeagueIndex, nSync);
	League:SetLeagueTask(self.LEAGUE_TYPE, szLeagueName, self.LGTASK_TONG_COUNT, 1, nSync);
	
	self:AddLeagueMember(szLeagueName, tbCaptain);
end

-- 解散战队
function Xkland:BreakLeague(szMemberName)
	
	local szLeagueName = League:GetMemberLeague(self.LEAGUE_TYPE, szMemberName);
	if not szLeagueName then
		return 0;
	end
	
	League:DelLeague(self.LEAGUE_TYPE, szLeagueName);
end

-- 添加成员
function Xkland:AddLeagueMember(szLeagueName, tbMember)
	
	local nSync = nil;
	
	League:AddMember(self.LEAGUE_TYPE, szLeagueName, tbMember.szPlayerName, nSync);
	League:SetMemberTask(self.LEAGUE_TYPE, szLeagueName, tbMember.szPlayerName, self.LGMTASK_CAPTAIN, tbMember.nCaptain, nSync);
	League:SetMemberTask(self.LEAGUE_TYPE, szLeagueName, tbMember.szPlayerName, self.LGMTASK_GROUP_INDEX, tbMember.nGroupIndex, nSync);
	League:SetMemberTask(self.LEAGUE_TYPE, szLeagueName, tbMember.szPlayerName, self.LGMTASK_GATEWAY, tbMember.nGateWay, nSync);
end

-- 减少成员
function Xkland:RemoveLeagueMember(szLeagueName, szMemberName)
	League:DelMember(self.LEAGUE_TYPE, szLeagueName, szMemberName, nil);
end

-- 成员离队
function Xkland:LeaveLeague(szMemberName)
	local szLeagueName = League:GetMemberLeague(self.LEAGUE_TYPE, szMemberName);
	if szLeagueName then
		self:RemoveLeagueMember(szLeagueName, szMemberName)
	end
end

-- 返回所有战队的名字
function Xkland:GetLeagueList()

	local pLeagueSet = KLeague.GetLeagueSetObject(self.LEAGUE_TYPE);
	local pLeagueItor = pLeagueSet.GetLeagueItor();
	local pLeague =  pLeagueItor.GetCurLeague();
	
	local tbLeagueList = {};
	
	while(pLeague) do
		table.insert(tbLeagueList, pLeague.szName);
		pLeague = pLeagueItor.NextLeague();
	end
	
	return tbLeagueList;
end

-- 得到成员列表
function Xkland:GetLeagueMemberList(szLeagueName)
	
	local tbPlayerList = League:GetMemberList(self.LEAGUE_TYPE, szLeagueName);
	local tbResult = {};
	local szCaptain = "";
	
	-- 保证第一顺位是队长
	for _, szMemberName in pairs(tbPlayerList) do
		local nCaptain = League:GetMemberTask(self.LEAGUE_TYPE, szLeagueName, szMemberName, self.LGMTASK_CAPTAIN);
		if nCaptain == 1 then
			table.insert(tbResult, 1, szMemberName);
			szCaptain = szMemberName;
		else
			table.insert(tbResult, szMemberName);
		end
	end
	
	-- 没有队长
	if szCaptain ~= tbResult[1] then
		for nId, szMemberName in pairs(tbResult) do
			if nId == 1 then
				League:SetMemberTask(self.LEAGUE_TYPE, szLeagueName, tbResult[1], self.LGMTASK_CAPTAIN, 1);
			else
				League:SetMemberTask(self.LEAGUE_TYPE, szLeagueName, tbResult[1], self.LGMTASK_CAPTAIN, 0);
			end
		end
	end
	
	return tbResult;
end

function Xkland:_ShowLeagueMember()
	local tbLeagueList = Xkland:GetLeagueList();
	for _, szLeagueName in pairs(tbLeagueList) do
		print("------------"..szLeagueName.."-----------");
		local tbPlayerList = League:GetMemberList(self.LEAGUE_TYPE, szLeagueName);
		for _, szMemberName in pairs(tbPlayerList) do
			print(szMemberName);
		end
		print("-----------------------");
	end
end
