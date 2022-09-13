-- 文件名　：plantform_rule_gs.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-09-20 20:54:43
-- 功能    ：无差别竞技

if (MODULE_GC_SERVER) then
	return 0;
end

--玩家进入准备场比赛场地 
function NewEPlatForm:SetStateJoinIn(nGroupId)
	me.ClearSpecialState()		--清除特殊状态
	me.RemoveSkillStateWithoutKind(Player.emKNPCFIGHTSKILLKIND_CLEARDWHENENTERBATTLE) --清除状态
	me.DisableChangeCurCamp(1);	--设置与帮会有关的变量，不允许在竞技场战改变某个帮会阵营的操作
	me.SetFightState(1);	  	--设置战斗状态
	me.SetLogoutRV(1);		--玩家退出时，保存RV并，在下次等入时用RV(城市重生点，非退出点)
	me.ForbidEnmity(1);	--禁止仇杀
	me.DisabledStall(1);		--摆摊
	me.ForbitTrade(1);		--交易
	me.ForbidExercise(1);	-- 禁止切磋
	--me.nPkModel = Player.emKPK_STATE_PRACTISE;
	me.SetCurCamp(nGroupId);
	me.TeamDisable(1);			--禁止组队
	me.TeamApplyLeave();		--离开队伍
	me.StartDamageCounter();	--开始计算伤害
	Faction:SetForbidSwitchFaction(me, 1); -- 进入准备场比赛场就不能切换门派
	me.SetDisableZhenfa(1);
	me.nForbidChangePK	= 1;
end

--玩家离开准备场比赛场地
function NewEPlatForm:LeaveGame()
	me.SetFightState(0);
	me.SetCurCamp(me.GetCamp());
	me.StopDamageCounter();	-- 停止伤害计算
	me.DisableChangeCurCamp(0);
	me.nPkModel = Player.emKPK_STATE_PRACTISE;--关闭PK开关
	me.nForbidChangePK	= 0;
	me.SetDeathType(0);
	me.RestoreMana();
	me.RestoreLife();
	me.RestoreStamina();
	me.DisabledStall(0);	--摆摊
	me.TeamDisable(0);		--禁止组队
	me.ForbitTrade(0);		--交易
	me.ForbidEnmity(0);
	me.ForbidExercise(0);		-- 切磋
	Faction:SetForbidSwitchFaction(me, 0); -- 进入准备场比赛场就切换门派还原
	me.SetDisableZhenfa(0);
	me.LeaveTeam();
	--me.SetLogoutRV(0);
	--me.SetLogOutState(0);       --玩家下线时也可以调到LOGOUT
end
 
function NewEPlatForm:ClearReadyMap()
end

--进入比赛场匹配规则
function NewEPlatForm:EnterPkMapRule()
	local tbMCfg = self:GetMacthTypeCfg(self:GetMacthType());
	if (not tbMCfg) then
		return 0;
	end

	local tbMacthCfg = tbMCfg.tbMacthCfg;
	for nReadyId, tbMissions in pairs(self.MissionList) do
		if not self.GroupList[nReadyId] then
			self.GroupList[nReadyId] = {};
		end		
		self:OnMacthPkStart_Single(tbMissions, nReadyId);
	end		
end

function NewEPlatForm:OnMacthPkStart_Single(tbMissions, nReadyId)	
	local tbCfg			 = self:GetMacthTypeCfg(self:GetMacthType());
	if (not tbCfg) then
		self:WriteLog("OnMacthPkStart_Single", "error OnMacthPkStart_Single not tbCfg");
		return 0;
	end
	local nGamePlayerMax = self.nCurMatchMaxTeamCount;
	local nGamePlayerMin = self.nCurMatchMinTeamCount;
	local nMemPlayerMin = self.nMemPlayerCount;
	
	local nReadyMapId	 = tbCfg.tbReadyMap[nReadyId];
	
	if (not nReadyMapId or nReadyMapId <= 0) then
		return 0;
	end	
	local tbList = self.GroupList[nReadyId];
	local nGroupDivide  = 0;
	local tbKickPlayerList = {};
	local nDynMapIndex	= 1;	
	local tbMission = nil;
	local tbMisFlag	= {};
	local nDynId	= 0;	
	for nId, tbMis in pairs(tbMissions) do
		if (not tbMisFlag[nId] or tbMisFlag[nId] ~= 1) then
			tbMission = tbMis;
			tbMisFlag[nId] = 1;
			nDynId = nId;
			break;
		end
	end
	local tbTempList = {};
	local tbSelectGroupId = {};
	for szLeagueName, tbGroup in pairs(tbList) do
		if szLeagueName ~= "nLeagueCount" and not tbSelectGroupId[szLeagueName] then
			tbTempList[szLeagueName] = tbTempList[szLeagueName] or {};
			if (#tbGroup == nMemPlayerMin) then
				for i = 1, #tbGroup do
					table.insert(tbTempList[szLeagueName], tbGroup[i]);
				end
				tbSelectGroupId[szLeagueName] = 1;
			elseif #tbGroup > 0 then
				local nNeedNum = nMemPlayerMin - #tbGroup;
				for i = 1, #tbGroup do
					table.insert(tbTempList[szLeagueName], tbGroup[i]);
				end
				tbSelectGroupId[szLeagueName] = 1;
				for szLeagueNameEx, tbGroupEx in pairs(tbList) do
					if not tbSelectGroupId[szLeagueNameEx] and #tbGroupEx > 0 then
						if #tbGroupEx == nNeedNum then
							for i = 1, #tbGroupEx do
								table.insert(tbTempList[szLeagueName], tbGroupEx[i]);
							end
							tbSelectGroupId[szLeagueNameEx] = 1;
							nNeedNum = 0;
							break;
						elseif #tbGroupEx < nNeedNum then
							for i = 1, #tbGroupEx do
								table.insert(tbTempList[szLeagueName], tbGroupEx[i]);	
							end
							tbSelectGroupId[szLeagueNameEx] = 1; 	
							nNeedNum = nNeedNum - #tbGroupEx;
							if #tbTempList[szLeagueName] == nMemPlayerMin then
								break;
							end
						end
					end
				end
			end
		end
	end
	local tbTempListEx = {};
	tbSelectGroupId = {};
	--把四个四个人的组到一起成为8个人的组
	local nCount = 0;
	for szLeagueName, tbPlayerlist in pairs(tbTempList) do
		if not tbSelectGroupId[szLeagueName] then
			local nIndex = #tbTempListEx;
			if #tbPlayerlist == nMemPlayerMin then
				if nCount == 0 then
					 tbTempListEx[nIndex+ 1] =  tbTempListEx[nIndex + 1] or {};
					 tbTempListEx[nIndex + 1][szLeagueName] = tbPlayerlist;
					 tbSelectGroupId[szLeagueName] = 1;
				elseif nCount == 1 then
					 tbTempListEx[nIndex] =  tbTempListEx[nIndex] or {};
					 tbTempListEx[nIndex][szLeagueName] = tbPlayerlist;
					 tbSelectGroupId[szLeagueName] = 1;
				end
				 nCount  = nCount + 1;
				 if nCount == 2 then
				 	nCount = 0;
				end
			else
				tbTempListEx[nIndex + 1] =  tbTempListEx[nIndex + 1] or {};
				tbTempListEx[nIndex + 1][szLeagueName] = tbPlayerlist;
				nCount = 0;
			end
		end
	end
	for i, tbTList in ipairs(tbTempListEx) do
		if Lib:CountTB(tbTList) == 2 then
			for szLeagueName, tbPlayerlist in pairs(tbTList) do
				for _, nPlayerId in ipairs(tbPlayerlist) do
					local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
					if pPlayer then
						local nCurMapId = pPlayer.GetWorldPos();
						local nListCount = #tbPlayerlist;
						if (nListCount >= nMemPlayerMin and nCurMapId == nReadyMapId and tbMission) then
							local tbEnterPos	= tbMission:GetEnterPos();
							local nCount		= self:GetPlayerEventCount(pPlayer);
							local nAllCount		= self:GetPlayerTotalCount(pPlayer);
							if (tbEnterPos and nCount > 0 and nAllCount <= self.nMaxAllCount) then
								if (tbEnterPos[1][1] > 0) then
									local tbTemp = {};
									tbTemp.szLeagueName = szLeagueName;
									tbTemp.tbPlayerList = {pPlayer.nId};
									self:SetPlayerDynId(pPlayer, nDynId);
									local nCount = self:GetPlayerEventCount(pPlayer);
									nCount = math.max(nCount - 1, 0);
									tbMission:JoinGame(tbTemp, 0, tbCfg.tbMacthCfg.tbJoinItem, nMemPlayerMin);
									self:UseMatchItem(pPlayer, 1, tbCfg.tbMacthCfg.tbJoinItem, tbCfg.tbMacthCfg.nEnterItemCount);
									self:SetPlayerEventCount(pPlayer, nCount);
									self:AddPlayerTotalCount(pPlayer, 1);
									nGroupDivide = nGroupDivide + 1;
									local tbAchievent = self.tbAchievement[self:GetMacthType()];
									if tbAchievent then
										Achievement:FinishAchievement(pPlayer, tbAchievent[1]);
										Achievement:FinishAchievement(pPlayer, tbAchievent[2]);
									end
									StatLog:WriteStatLog("stat_info", "kin_sports", "join", pPlayer.nId, self:GetMacthType());
								end
							else
								table.insert(tbKickPlayerList, pPlayer);
							end
						else
							table.insert(tbKickPlayerList, pPlayer);					
						end
					end
					if nGroupDivide >= nGamePlayerMax then
						nGroupDivide = 0;
						nDynMapIndex = nDynMapIndex + 1;
			
						for nId, tbMis in pairs(tbMissions) do
							if (not tbMisFlag[nId] or tbMisFlag[nId] ~= 1) then
								tbMission = tbMis;
								tbMisFlag[nId] = 1;
								break;
							end
						end	
					end
				end
			end
		else
			for szLeagueName, tbPlayerlist in pairs(tbTList) do
				for _, nPlayerId in ipairs(tbPlayerlist) do
					local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
					if pPlayer then
						table.insert(tbKickPlayerList, pPlayer);
					end
				end
			end
		end
	end
	for _, pPlayer in pairs(tbKickPlayerList) do
		self:KickPlayer(pPlayer);
		local szMsg = string.format("Bạn được chỉ định ngẫu nhiên vào nhóm không đủ %d người. Kết thúc trò chơi.", nGamePlayerMin);
		Dialog:SendBlackBoardMsg(pPlayer, szMsg);
		pPlayer.Msg(string.format("<color=green>%s<color>",szMsg));
		pPlayer.AddStackItem(18, 1, 80, 1,nil, 3);		--改福袋为3个
		pPlayer.AddBindMoney(20000);		--增加绑银20000
	end
	self.GroupList[nReadyId] = nil;
end

--加载单场奖励
function NewEPlatForm:SendResult(tbPlayerList, nReadyId)
	if (not tbPlayerList) then
		return;
	end
	-- 这里奖励要改一下
	for nRank, tbGroup in ipairs(tbPlayerList) do
		if (tbGroup.tbPlayerList) then
			for nIndex, nPlayerId in pairs(tbGroup.tbPlayerList) do
				local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
				self:GiveWeleeAwardToPlayer(pPlayer, nRank);
			end
		end
	end
end

function NewEPlatForm:GiveWeleeAwardToPlayer(pPlayer, nRank)
	if (not pPlayer or not nRank or nRank <= 0) then
		return 0;
	end
	local nSession			= self:GetMacthSession();
	local nMacthType		= self:GetMacthType();
	local tbMacth			= self:GetMacthTypeCfg(nMacthType);
	local szMatchName		= "Thi đấu gia tộc";
	if (tbMacth) then
		szMatchName	= szMatchName..": "..tbMacth.szName;
	end
	if (nRank > 0 and nRank <= 3) then
		local szMsg = string.format("trong %s giành được hạng <color=yellow>%d<color>!", szMatchName, nRank);
		Player:SendMsgToKinOrTong(pPlayer, szMsg, 1);
	end
	--去掉单场奖励，改为直接给（以声望和经验为主）
	--local nAwardFlag = self:SetAwardFlagParam(0, nSession, nRank);
	--self:SetAwardParam(pPlayer, nAwardFlag);
	if self.tbWeleeAward[nRank] then
		pPlayer.AddExp(pPlayer.GetBaseAwardExp() * self.tbWeleeAward[nRank][1]);
		pPlayer.AddBindMoney(self.tbWeleeAward[nRank][2]);
		pPlayer.AddRepute(10,2,self.tbWeleeAward[nRank][3]);
		pPlayer.SetTask(self.TASKID_GROUP, self.TASKID_AWARD_HANDON, -1);
		if self.tbWeleeAward[nRank][4] > 0 then
			pPlayer.AddKinReputeEntry(self.tbWeleeAward[nRank][4], "kingame_quwei");
		end
		self:AddKinGrade(nRank, pPlayer);
	end
	Dbg:WriteLog("NewEPlatForm","趣味竞技单场奖励", nMacthType, tbMacth.szName, pPlayer.szName, nRank);
	pPlayer.Msg(string.format("Bạn đã giành được vị trí thứ <color=yellow>%d<color> trong cuộc đua này.", nRank));	
	
	if nRank <= 6 then
		local tbRank = 
		{
			[1] = 1.5,
			[2] = 1.3,
			[3] = 1.1,
			[4] = 0.9,
			[5] = 0.7,
			[6] = 0.5,
		};
		local nMulti = tbRank[nRank] and tbRank[nRank] or 1;
		local tbInfo = Kinsalary.EVENT_TYPE[Kinsalary.EVENT_JINGJI];
		Kinsalary:AddSalary_GS(pPlayer, Kinsalary.EVENT_JINGJI, tbInfo.nRate * nMulti);
	end
	
	--家族竞技、趣味竞技指引任务变量
	if pPlayer.GetTask(1022,238) ~= 1 then
		pPlayer.SetTask(1022,238, 1);
	end
	
	SpecialEvent.ActiveGift:AddCounts(pPlayer, 14);
	SpecialEvent.BuyOver:AddCounts(pPlayer, SpecialEvent.BuyOver.TASK_THIDAUGIATOC);
end

function NewEPlatForm:AddKinGrade(nRank, pPlayer)
	local nGrade = self.tbWeleeGrade[nRank];
	if nGrade  then
		local nKinId, nMemberId = pPlayer.GetKinMember();
		GCExcute({"NewEPlatForm:AddKinGradeEx", nKinId, nMemberId, nGrade, pPlayer.nId});
	end
end

function NewEPlatForm:OnLogin(bExchangeServerComing)
	if (bExchangeServerComing ~= 1) then
		self:ChangeEventCount(me);
	end
end

PlayerEvent:RegisterGlobal("OnLogin", NewEPlatForm.OnLogin, NewEPlatForm);
