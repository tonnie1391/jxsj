-------------------------------------------------------
-- 文件名　：wldh_battle_bouns.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-08-21 09:05:08
-- 文件描述：
-------------------------------------------------------

Require("\\script\\globalserverbattle\\wldh\\battle\\wldh_battle_def.lua");

local tbBattle = Wldh.Battle;

-- 处理连斩积分奖励
function tbBattle:ProcessSeriesBouns(tbKillerBattleInfo, tbDeathBattleInfo)
	
	local nMeRank	= tbDeathBattleInfo.nRank;
	local nPLRank	= tbKillerBattleInfo.nRank;
	
	-- 符合连斩条件 计算有效连斩
	if 5 >= (nPLRank - nMeRank) then
		local nSeriesKill = tbKillerBattleInfo.nSeriesKill + 1;
		tbKillerBattleInfo.nSeriesKill = nSeriesKill;

		if math.fmod(nSeriesKill, 3) == 0 then	
			tbKillerBattleInfo.nTriSeriesNum = tbKillerBattleInfo.nTriSeriesNum + 1;
			self:AddShareBouns(tbKillerBattleInfo, self.SERIESKILLBOUNS)
			tbKillerBattleInfo.pPlayer.Msg(string.format("%s方%s %s连续击退敌人%d名，获得%d积分的连斩奖励。", 
				Wldh.Battle.NAME_CAMP[tbKillerBattleInfo.tbCamp.nCampId], Wldh.Battle.NAME_RANK[tbKillerBattleInfo.nRank], tbKillerBattleInfo.pPlayer.szName, tbKillerBattleInfo.nSeriesKill, self.SERIESKILLBOUNS));
		end

		if tbKillerBattleInfo.nMaxSeriesKill < nSeriesKill then
			tbKillerBattleInfo.nMaxSeriesKill = nSeriesKill;
		end
	end
	
	-- 计算连斩	
	local nSeriesKillNum = tbKillerBattleInfo.nSeriesKillNum + 1;
	tbKillerBattleInfo.nSeriesKillNum = nSeriesKillNum;

	if tbKillerBattleInfo.nMaxSeriesKillNum < nSeriesKillNum then
		tbKillerBattleInfo.nMaxSeriesKillNum = nSeriesKillNum;
	end
end

-- 获得杀死玩家积分奖励
function tbBattle:GiveKillerBouns(tbKillerBattleInfo, tbDeathBattleInfo)
	
	tbKillerBattleInfo.nKillPlayerNum = tbKillerBattleInfo.nKillPlayerNum + 1;
	
	local nMeRank		= tbDeathBattleInfo.nRank;
	local nPLRank		= tbKillerBattleInfo.nRank;
	
	local nRadioRank	= 1;
	nRadioRank			= (10 - (nPLRank - nMeRank)) / 10;
	local nPoints		= math.floor(Wldh.Battle.tbBounsBase.KILLPLAYER * nRadioRank);
	local nBounsDif		= self:AddShareBouns(tbKillerBattleInfo, nPoints)
	
	if nBounsDif > 0 then
		tbKillerBattleInfo.nKillPlayerBouns = tbKillerBattleInfo.nKillPlayerBouns + nPoints;
	end
end

function tbBattle:AddShareBouns(tbBattleInfo, nBouns)
	
	local tbShareTeamMember = tbBattleInfo.pPlayer.GetTeamMemberList(1);
	
	if (not tbShareTeamMember) then
		return tbBattleInfo:AddBounsWithCamp(nBouns);
	end
	
	local nResult	= 0;	
	local nCount	= #tbShareTeamMember;
	
	if 0 < nCount then
		local nTimes	= self.tbPOINT_TIMES_SHARETEAM[nCount];
		local nPoints	= nBouns * nTimes;
		nResult			= tbBattleInfo:AddBounsWithCamp(nPoints);
	end

	return nResult;
end

