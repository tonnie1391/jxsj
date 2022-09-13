--竞技赛（奖励）
--sunduoliang
--2008.12.30

--单场奖励
--nResult:1 A胜, 2A负, 3 平
function TowerDefence:AwardSingleSport(tbListA, tbListB, nResult, tbGrade_player)
	
	--平
	if nResult == 3 then
		for _, nId in pairs(tbListA) do
			local pPlayer = KPlayer.GetPlayerObjById(nId);
			if pPlayer then
				self:AwardSingleTie(pPlayer)
			end
		end
		
		for _, nId in pairs(tbListB) do
			local pPlayer = KPlayer.GetPlayerObjById(nId);
			if pPlayer then
				self:AwardSingleTie(pPlayer)
			end
		end				
		return 0;
	end
	
	local tbWin = tbListA;	
	local tbLost = tbListB;
	local tbWin_Ex = tbGrade_player[1];
	local tbList_Ex = tbGrade_player[2];
	--胜者
	if nResult == 2 then
		tbWin = tbListB;
		tbLost = tbListA;
		tbWin_Ex = tbGrade_player[2];
		tbList_Ex = tbGrade_player[1];
	end
	
	for _, nId in pairs(tbWin) do
		local pPlayer = KPlayer.GetPlayerObjById(nId);
		if pPlayer then
			local nGrade = self:FindTb(tbWin_Ex, pPlayer.szName);
			self:AwardSingleWin(pPlayer,nGrade)
		end
	end
	
	for _, nId in pairs(tbLost) do
		local pPlayer = KPlayer.GetPlayerObjById(nId);
		if pPlayer then
			local nGrade = self:FindTb(tbList_Ex, pPlayer.szName);
			self:AwardSingleLost(pPlayer,nGrade)
		end
	end
end

function TowerDefence:AwardSingleWin(pPlayer,nGrade)
	pPlayer.SetTask(TowerDefence.TSK_GROUP, TowerDefence.TSK_ATTEND_AWARD, nGrade);
	pPlayer.SetTask(TowerDefence.TSK_GROUP, TowerDefence.TSK_ATTEND_WIN, pPlayer.GetTask(TowerDefence.TSK_GROUP, TowerDefence.TSK_ATTEND_WIN) + 1);
	self:AddHonor(pPlayer.szName, self.DEF_POINT_WIN);	
	pPlayer.Msg("恭喜你队伍获得了胜利")
	self:WriteLog("恭喜你队伍获得了胜利", pPlayer.nId);
end

function TowerDefence:AwardSingleLost(pPlayer,nGrade)
	if nGrade == 1 then
		pPlayer.SetTask(TowerDefence.TSK_GROUP, TowerDefence.TSK_ATTEND_AWARD, 3);
	end
	self:AddHonor(pPlayer.szName, self.DEF_POINT_LOST);
	pPlayer.Msg("很遗憾，你队伍在本场比赛中失利了，下次继续加油。");
	self:WriteLog("恭喜你队伍获得了失败", pPlayer.nId);
end

function TowerDefence:AwardSingleTie(pPlayer)
	pPlayer.SetTask(TowerDefence.TSK_GROUP, TowerDefence.TSK_ATTEND_TIE, pPlayer.GetTask(TowerDefence.TSK_GROUP, TowerDefence.TSK_ATTEND_TIE) + 1);	
	self:AddHonor(pPlayer.szName, self.DEF_POINT_TIE);
	pPlayer.Msg("很遗憾，你队伍在本场比赛中和对手打平了，下次继续加油。");
	self:WriteLog("恭喜你队伍获得了平局", pPlayer.nId);
end

function TowerDefence:FindTb(tbGrade,szName)
	for i, _ in ipairs(tbGrade) do
		if tbGrade[i][1] == szName then
			return i;
		end
	end
end
