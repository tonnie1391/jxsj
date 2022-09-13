-------------------------------------------------------
-- 文件名　：wldh_battle_league.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-08-26 09:08:45
-- 文件描述：
-------------------------------------------------------

Require("\\script\\globalserverbattle\\wldh\\battle\\wldh_battle_def.lua");

local tbBattle = Wldh.Battle;

tbBattle.MATCH_TYPE = 10;

--LG Task ID--
tbBattle.LGTASK_RANK	= 1;		--战队获得名次（比赛结束后排序获得）
tbBattle.LGTASK_WIN		= 2;		--胜利次数
tbBattle.LGTASK_TIE		= 3;		--平局次数
tbBattle.LGTASK_TOTAL	= 4;		--参赛次数(失败次数 = TOTAL - WIN - TIE)
tbBattle.LGTASK_FINAL 	= 5;		--决赛排名(1-冠军.2-亚军.3-四强)
tbBattle.LGTASK_LAST	= 6;		--最后一次对手

--LG MemberTask ID--
tbBattle.LGMTASK_JOB		= 1;	--职位:0、队员；1、队长
tbBattle.LGMTASK_FACTION	= 2;	--门派
tbBattle.LGMTASK_ROUTEID	= 3;	--路线
tbBattle.LGMTASK_SEX		= 4;	--性别
tbBattle.LGMTASK_SERIES		= 5;	--五行

-- 创建战队
function tbBattle:CreateLeague(szLeagueName)
	
	if League:FindLeague(self.MATCH_TYPE, szLeagueName) then
		return 0;
	end
	
	local nSync = nil;
	League:AddLeague(self.MATCH_TYPE, szLeagueName, nSync);
	
	League:SetLeagueTask(self.MATCH_TYPE, szLeagueName, self.LGTASK_RANK, 0, nSync);
	League:SetLeagueTask(self.MATCH_TYPE, szLeagueName, self.LGTASK_WIN, 0, nSync);
	League:SetLeagueTask(self.MATCH_TYPE, szLeagueName, self.LGTASK_TIE, 0, nSync);
	League:SetLeagueTask(self.MATCH_TYPE, szLeagueName, self.LGTASK_TOTAL, 0, nSync);
	League:SetLeagueTask(self.MATCH_TYPE, szLeagueName, self.LGTASK_FINAL, 0, nSync);
	League:SetLeagueTask(self.MATCH_TYPE, szLeagueName, self.LGTASK_LAST, 0, nSync);
end

-- 临时创建12个战队
function tbBattle:_TestCreate(tbLeague)
	for _, szLeagueName in pairs(tbLeague) do
		self:CreateLeague(szLeagueName);
	end
end

-- 测试删除
function tbBattle:_TestDelete()
	local tbLeagueList = self:GetLeagueList() or {};
	for _, szLeagueName in pairs(tbLeagueList) do
		League:DelLeague(self.MATCH_TYPE, szLeagueName);
	end
end

-- 保存结果
function tbBattle:GetResult(szLeagueName, nResult, szMatchName)

	local nWin = League:GetLeagueTask(self.MATCH_TYPE, szLeagueName, self.LGTASK_WIN);
	local nTie = League:GetLeagueTask(self.MATCH_TYPE, szLeagueName, self.LGTASK_TIE);
	local nTotal = League:GetLeagueTask(self.MATCH_TYPE, szLeagueName, self.LGTASK_TOTAL);
	
	if nResult == self.RESULT_WIN then
		nWin = nWin + 1;
		League:SetLeagueTask(self.MATCH_TYPE, szLeagueName, self.LGTASK_WIN, nWin);
		
		-- 设任务变量
		--local tbMember = self:GetLeagueMemberList(szLeagueName);
		--for _, szMemberName in pairs(tbMember or {}) do
		--	local nId = KGCPlayer.GetPlayerIdByName(szMemberName);
		--	if nId then
		--		SetPlayerSportTask(nId, Wldh.GBTASKID_GROUP, Wldh.GBTASKID_BATTLE_WIN_ID, nWin);
		--	end
		--end
		
	elseif nResult == self.RESULT_TIE then
		nTie = nTie + 1;
		League:SetLeagueTask(self.MATCH_TYPE, szLeagueName, self.LGTASK_TIE, nTie);
	end
	
	nTotal = nTotal + 1;
	League:SetLeagueTask(self.MATCH_TYPE, szLeagueName, self.LGTASK_TOTAL, nTotal);
	
	-- add last match name
	if szMatchName then
		local nLastId = tonumber(KLib.String2Id(szMatchName));
		League:SetLeagueTask(self.MATCH_TYPE, szLeagueName, self.LGTASK_LAST, nLastId);
	end
end

-- 解散战队
function tbBattle:BreakLeague(szMemberName)
	local szLeagueName = League:GetMemberLeague(self.MATCH_TYPE, szMemberName);
	if not szLeagueName then
		return 0;
	end
	League:DelLeague(self.MATCH_TYPE, szLeagueName);
end

-- 添加成员
function tbBattle:AddMember(szLeagueName, tbMember)
	
	local nSync = nil;
	
	League:AddMember(self.MATCH_TYPE, szLeagueName, tbMember.szName, nSync);
	League:SetMemberTask(self.MATCH_TYPE, szLeagueName, tbMember.szName, self.LGMTASK_JOB, tbMember.nCaptain, nSync);
	League:SetMemberTask(self.MATCH_TYPE, szLeagueName, tbMember.szName, self.LGMTASK_FACTION, tbMember.nFaction, nSync);
	League:SetMemberTask(self.MATCH_TYPE, szLeagueName, tbMember.szName, self.LGMTASK_ROUTEID, tbMember.nRouteId, nSync);
	League:SetMemberTask(self.MATCH_TYPE, szLeagueName, tbMember.szName, self.LGMTASK_SEX, tbMember.nSex, nSync);
	League:SetMemberTask(self.MATCH_TYPE, szLeagueName, tbMember.szName, self.LGMTASK_SERIES, tbMember.nSeries, nSync);
end

function tbBattle:RemoveMember(szLeagueName, szMemberName)
	League:DelMember(self.MATCH_TYPE, szLeagueName, szMemberName, nil);
end

function tbBattle:LeaveLeague(szMemberName)
	local szLeagueName = League:GetMemberLeague(Wldh.Battle.MATCH_TYPE, szMemberName);
	if szLeagueName then
		self:RemoveMember(szLeagueName, szMemberName)
	end
end

-- 返回所有战队的名字
function tbBattle:GetLeagueList()

	local pLeagueSet = KLeague.GetLeagueSetObject(self.MATCH_TYPE);
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
function tbBattle:GetLeagueMemberList(szLeagueName)
	
	local tbPlayerList = League:GetMemberList(self.MATCH_TYPE, szLeagueName);
	local tbWldhPlayerList = {};
	local szCaptain = "";
	
	for _, szMemberName in pairs(tbPlayerList) do
		local nCaptain = League:GetMemberTask(self.MATCH_TYPE, szLeagueName, szMemberName, Wldh.LGMTASK_JOB);
		if nCaptain == 1 then
			table.insert(tbWldhPlayerList, 1, szMemberName);
			szCaptain = szMemberName;
		else
			table.insert(tbWldhPlayerList, szMemberName);
		end
	end
	
	-- 没有队长
	if szCaptain ~= tbWldhPlayerList[1] then
		for nId, szMemberName in pairs(tbWldhPlayerList) do
			if nId == 1 then
				League:SetMemberTask(self.MATCH_TYPE, szLeagueName, tbWldhPlayerList[1], Wldh.LGMTASK_JOB, 1);
			else
				League:SetMemberTask(self.MATCH_TYPE, szLeagueName, tbWldhPlayerList[1], Wldh.LGMTASK_JOB, 0);
			end
		end
	end
	
	return tbWldhPlayerList;
end

-- 排序：先按积分排行，再按胜场数，再按平场数
tbBattle._Sort = function(tbA, tbB)
	
	if Wldh.Battle:CheckTime() == 2 then
		if tbA.nFinal ~= tbB.nFinal then
			if tbB.nFinal == 0 then
				return tbA.nFinal > tbB.nFinal;
			elseif tbA.nFinal == 0 then
				return tbA.nFinal > tbB.nFinal;
			else
				return tbA.nFinal < tbB.nFinal;
			end
		end
	end
	
	if tbA.nPoint ~= tbB.nPoint then
		return tbA.nPoint > tbB.nPoint;
	end

	if tbA.nWin ~= tbB.nWin then
		return tbA.nWin > tbB.nWin;
	end
	
	if tbA.nTie ~= tbB.nTie then
		return tbA.nTie > tbB.nTie;
	end
	
	return tbA.nLastPoint > tbB.nLastPoint;
end

-- 设置排行
function tbBattle:SetRankData(nLGType, tbData, nMacthType, szTitle, nRankParam1, nRankParam2, nRankParam3, nRankParam4)

	local tbLadderInfo = {}
	for nRank, tbLeague in ipairs(tbData) do

		-- 最多10个
		if nRank > 10 then
			break;
		end
	
		local tbMemberInfo = 
		{
			dwImgType = 2,
			szName = tbLeague.szName,
			szTxt1 = string.format("总积分:%s",tbLeague.nPoint),
			szTxt2 = string.format("胜:%s  平:%s  负:%s", tbLeague.nWin, tbLeague.nTie, (tbLeague.nTotal - tbLeague.nWin - tbLeague.nTie) ),
			szTxt3 = "",
			szTxt4 = "",
			szTxt5 = "",
			szTxt6 = "",
			szContext = "",
		};
		table.insert(tbLadderInfo, tbMemberInfo);
	end
	
	SetShowLadder(Ladder:GetType(nRankParam1, nRankParam2, nRankParam3, nRankParam4), szTitle, string.len(szTitle) + 1, tbLadderInfo);
end

-- 比赛结束后战队排名
function tbBattle:LeagueRank(bFinal)

	local nType 		= 5;
	local pLeagueSet 	= KLeague.GetLeagueSetObject(self.MATCH_TYPE);
	local pLeagueItor 	= pLeagueSet.GetLeagueItor();
	local pLeague 		= pLeagueItor.GetCurLeague();
	
	self.tbLeagueRank = {};
	
	while(pLeague) do
		
		local nWin = pLeague.GetTask(self.LGTASK_WIN);
		local nTie = pLeague.GetTask(self.LGTASK_TIE);
		local nTotal = pLeague.GetTask(self.LGTASK_TOTAL);
		local nLoss = nTotal - nWin - nTie;
		local nPoint = nWin * Wldh.MACTH_POINT_WIN + nTie * Wldh.MACTH_POINT_TIE + nLoss * Wldh.MACTH_POINT_LOSS;
		
		-- 决赛名次
		local nFinal = pLeague.GetTask(self.LGTASK_FINAL);
		
		-- 上一场对手的积分
		local nLastPoint = 0;
		local nLastId = KLib.Number2UInt(pLeague.GetTask(self.LGTASK_LAST));
		local szLastMatchName = self.tbLeagueId_Name[nLastId]
		
		if szLastMatchName then
			local nMatchWin = League:GetLeagueTask(self.MATCH_TYPE, szLastMatchName, self.LGTASK_WIN);
			local nMatchTie = League:GetLeagueTask(self.MATCH_TYPE, szLastMatchName, self.LGTASK_TIE);
			local nMatchTotal = League:GetLeagueTask(self.MATCH_TYPE, szLastMatchName, self.LGTASK_TOTAL);
			local nMatchLoss = nMatchTotal - nMatchWin - nMatchTie;
			nLastPoint = nMatchWin * Wldh.MACTH_POINT_WIN + nMatchTie * Wldh.MACTH_POINT_TIE + nMatchLoss * Wldh.MACTH_POINT_LOSS;
		end
		
		if nTotal > 0 then
			table.insert(self.tbLeagueRank, {szName = pLeague.szName, nWin = nWin, nTie = nTie, nTotal = nTotal, nPoint = nPoint, nFinal = nFinal, nLastPoint = nLastPoint});				
		end
		
		pLeague = pLeagueItor.NextLeague();
	end
	
	if #self.tbLeagueRank > 0 then
		table.sort(self.tbLeagueRank, self._Sort);
	end
	
	if MODULE_GC_SERVER then	
		
		-- 当届前10名入榜.
		self:SetRankData(self.MATCH_TYPE, self.tbLeagueRank, Wldh.MAP_LINK_TYPE_RANDOM, 
			Wldh.LADDER_ID[nType][1], 0, Wldh.LADDER_ID[nType][2], Wldh.LADDER_ID[nType][3], Wldh.LADDER_ID[nType][4]);
		
		GlobalExcute{"Ladder:RefreshLadderName"};
	end
	
	if #self.tbLeagueRank > 0 then
		for nRank = 1, #self.tbLeagueRank do
			League:SetLeagueTask(self.MATCH_TYPE, self.tbLeagueRank[nRank].szName, self.LGTASK_RANK, nRank, 1);
		end
			
		if MODULE_GC_SERVER then
			
			-- 设任务变量(分帧)
			if bFinal == 1 then
				Timer:Register(1, self.FrameSave, self);
			end
			
			GlobalExcute({"Wldh.Battle:LeagueRank"});
		end
	end
end

function tbBattle:FrameSave()

	if not self.nFrame then
		self.nFrame = 1;
	end
		
	if self.nFrame > #self.tbLeagueRank then
		return 0;
	end
	
	local tbMember = self:GetLeagueMemberList(self.tbLeagueRank[self.nFrame].szName);
	for _, szMemberName in pairs(tbMember or {}) do
		local nId = KGCPlayer.GetPlayerIdByName(szMemberName);
		if nId then
			SetPlayerSportTask(nId, Wldh.GBTASKID_GROUP, Wldh.GBTASKID_BATTLE_RANK_ID, self.nFrame);
		end
	end
	
	self.nFrame = self.nFrame + 1;
	return 1;
end

-- 清理战队数据
function tbBattle:ClearLeague()
	Timer:Register(1, Wldh.Battle.FrameClearLeague, Wldh.Battle);
end

function tbBattle:FrameClearLeague()
	
	local tbType = {8, 9, 10, 11, 12};
	
	if not self.nClearFrame then
		self.nClearFrame = 1;
	end
	
	if self.nClearFrame > #tbType then
		return 0;
	end
	
	local nType = tbType[self.nClearFrame];
	League:ClearLeague(nType);
	
	self.nClearFrame = self.nClearFrame + 1;	
	return 1;
end
