--竞技赛（奖励）
--sunduoliang
--2008.12.30

--单场奖励
--nResult:1 A胜, 2A负, 3 平
function Esport:AwardSingleSport(tbListA, tbListB, nResult)
	
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
	--胜者
	if nResult == 2 then
		tbWin = tbListB;
		tbLost = tbListA;
	end
	
	for _, nId in pairs(tbWin) do
		local pPlayer = KPlayer.GetPlayerObjById(nId);
		if pPlayer then
			self:AwardSingleWin(pPlayer)
		end
	end
	
	for _, nId in pairs(tbLost) do
		local pPlayer = KPlayer.GetPlayerObjById(nId);
		if pPlayer then
			self:AwardSingleLost(pPlayer)
		end
	end
end

function Esport:AwardSingleWin(pPlayer)
	pPlayer.SetTask(Esport.TSK_GROUP, Esport.TSK_ATTEND_AWARD, 1);
	pPlayer.SetTask(Esport.TSK_GROUP, Esport.TSK_ATTEND_WIN, pPlayer.GetTask(Esport.TSK_GROUP, Esport.TSK_ATTEND_WIN) + 1);
	pPlayer.AddExp(pPlayer.GetBaseAwardExp() * self.DEF_PLAYER_EXP_WIN);
	self:AddHonor(pPlayer.szName, self.DEF_POINT_WIN)
	for i=1,3 do
		local pItem = pPlayer.AddItem(18,1,80,1);
		if pItem then
			pItem.Bind(1);
		end
	end
	pPlayer.Msg("恭喜你队伍获得了胜利")
	self:WriteLog("恭喜你队伍获得了胜利", pPlayer.nId);
end

function Esport:AwardSingleLost(pPlayer)
	pPlayer.AddExp(pPlayer.GetBaseAwardExp() * self.DEF_PLAYER_EXP_LOST);
	self:AddHonor(pPlayer.szName, self.DEF_POINT_LOST)
	for i=1,3 do
		local pItem = pPlayer.AddItem(18,1,80,1);
		if pItem then
			pItem.Bind(1);
		end
	end	
	pPlayer.Msg("很遗憾，你队伍在本场比赛中失利了，下次继续加油。")
	self:WriteLog("恭喜你队伍获得了失败", pPlayer.nId);
end

function Esport:AwardSingleTie(pPlayer)
	pPlayer.AddExp(pPlayer.GetBaseAwardExp() * self.DEF_PLAYER_EXP_LOST);
	pPlayer.SetTask(Esport.TSK_GROUP, Esport.TSK_ATTEND_TIE, pPlayer.GetTask(Esport.TSK_GROUP, Esport.TSK_ATTEND_TIE) + 1);	
	self:AddHonor(pPlayer.szName, self.DEF_POINT_TIE)
	for i=1,3 do
		local pItem = pPlayer.AddItem(18,1,80,1);
		if pItem then
			pItem.Bind(1);
		end
	end
	pPlayer.Msg("很遗憾，你队伍在本场比赛中和对手打平了，下次继续加油。")
	self:WriteLog("恭喜你队伍获得了平局", pPlayer.nId);
end
