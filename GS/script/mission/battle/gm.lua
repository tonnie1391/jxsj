

function Battle:GM()
	local tbOpt	= {};
	tbOpt[#tbOpt + 1]	= {"Đồ Hỗ trợ", "Battle:GM_GetEquip"};
	
	local tbMission	= nil;
	for nLevel = 1, 3 do
		for i = 1, 3 do
			tbMission	= self:GetMission(nLevel, i);
			if (tbMission) then
				break;
			end
		end
		if (tbMission) then
			break;
		end
	end
	
	if (tbMission) then
		if (tbMission.nState == 1) then
			tbOpt[#tbOpt + 1]	= {"Bắt đầu Khai chiến", "Battle:GM_Start"};
		end
		tbOpt[#tbOpt + 1]	= {"Kết Thúc trận chiến", "Battle:GM_Close"};
	else
		-- for nRuleId, tbRule in ipairs(self.tbRuleBases) do
			-- tbOpt[#tbOpt + 1]	= {"Khai chiến-"..tbRule.szRuleName, "Battle:GM_Open", nRuleId};
		-- end
		-- for nRuleId, tbRule in ipairs(self.tbRuleBases) do
			-- tbOpt[#tbOpt + 1]	= {"Khai chiến-九曲之战"..tbRule.szRuleName, "Battle:GM_OpenSp", nRuleId};
		-- end
		-- for nRuleId, tbRule in ipairs(self.tbRuleBases) do
			-- tbOpt[#tbOpt + 1]	= {"Khai chiến-蟠龙谷之战"..tbRule.szRuleName, "Battle:GM_OpenSp1", nRuleId};
		-- end		
		for nRuleId, tbRule in pairs(self.tbRuleBases) do
			if (tbRule.szRuleName) then
				tbOpt[#tbOpt + 1]	= {"Mở Gia Dụ Quan-"..tbRule.szRuleName, "Battle:GM_OpenSp_JiaYuGuan", nRuleId};
			end
		end
	end
	
	-- tbOpt[#tbOpt + 1]	= {"去方报名点-宋", "Battle:GM_GotoSignUp", Battle.CAMPID_SONG};
	-- tbOpt[#tbOpt + 1]	= {"去方报名点-金", "Battle:GM_GotoSignUp", Battle.CAMPID_JIN};


	--tbOpt[#tbOpt + 1]	= {"提升等级-初", "Battle:GM_LevelUp", 1};
	--tbOpt[#tbOpt + 1]	= {"提升等级-中", "Battle:GM_LevelUp", 2};
	--tbOpt[#tbOpt + 1]	= {"提升等级-高", "Battle:GM_LevelUp", 3};
	-- tbOpt[#tbOpt + 1]	= {"Vật phẩm 1", "Battle:GM_Equipment"};
	-- tbOpt[#tbOpt + 1]	= {"Vật phẩm 2", "Battle:GM_Equipment1"};
	
	tbOpt[#tbOpt + 1]	= {"Kết thúc đối thoại"};

	Dialog:Say("Mông Cổ - Tây Hạ <pic=42>", tbOpt);
end

function Battle:GM_Equipment()
	local tbTmpNpc	= Npc:GetClass("tmpnpc");
	tbTmpNpc:OnDialog();
end

function Battle:GM_Equipment1()
	local tbTmpNpc	= Npc:GetClass("tmpnpc2");
	tbTmpNpc:OnDialog();
end

--测试装备领取
function Battle:GM_GetEquip()
	local tbTmpNpc	= Npc:GetClass("getequip");
	tbTmpNpc:OnDialog();
end


function Battle:GM_Open(nRuleId, nSeqNum)
	if nSeqNum == nil then
		nSeqNum = 1;
	end
	for nLevel = 1, 3 do
		local tbMission	= self:GetMission(nLevel);
		if (tbMission) then
			me.Msg(string.format("--宋金[%s] 正在进行中，请先关闭！", tbMission:GetFullName()));
		else
			local szBattleTime = GetLocalDate("%y%m%d%H");
			self:OpenBattle(1, nLevel, 190 + nLevel - 1, string.format("（调试版%d）", nLevel), nRuleId, 1, nSeqNum, 1, szBattleTime);
			self:OpenBattle(1, nLevel, 266 + nLevel - 1, string.format("（调试版%d）", nLevel), nRuleId, 1, nSeqNum, 2, szBattleTime);
			if (nLevel == 1) then
				print("第三场1");
				self:OpenBattle(1, nLevel, 284, string.format("（调试版%d）", nLevel), nRuleId, 1, nSeqNum, 3, szBattleTime);
			end
			
			if (EventManager.IVER_bOpenTiFu == 1) then
				if (nLevel == 2) then
					print("第三场1");
					self:OpenBattle(1, nLevel, 290, string.format("（调试版%d）", nLevel), nRuleId, nSeqNum, 1, szBattleTime);
					self:OpenBattle(1, nLevel, 264, string.format("（调试版%d）", nLevel), nRuleId, nSeqNum, 2, szBattleTime);
					self:OpenBattle(1, nLevel, 188, string.format("（调试版%d）", nLevel), nRuleId, nSeqNum, 3, szBattleTime);
				end
			end
			
			tbMission	= self:GetMission(nLevel, 1);
			if (tbMission) then
				me.Msg(string.format("--宋金[%s]一 成功开启！", tbMission:GetFullName()));
			end
			tbMission	= self:GetMission(nLevel, 2);
			if (tbMission) then
				me.Msg(string.format("--宋金[%s]二  成功开启！", tbMission:GetFullName()));
			end

			if (nLevel == 1) then
				print("第三场");
				tbMission	= self:GetMission(nLevel, 3);
				if (tbMission) then
					me.Msg(string.format("--宋金[%s]三  成功开启！", tbMission:GetFullName()));
				end
			end

		end
	end
end

function Battle:GM_OpenSp(nRuleId, nSeqNum)
	if nSeqNum == nil then
		nSeqNum = 1;
	end
	for nLevel = 1, 3 do
		local tbMission	= self:GetMission(nLevel);
		if (tbMission) then
			me.Msg(string.format("--宋金[%s] 正在进行中，请先关闭！", tbMission:GetFullName()));
		else
			local szBattleTime = GetLocalDate("%y%m%d%H");
			self:OpenBattle(1, nLevel, 187 + nLevel - 1, string.format("（调试版%d）", nLevel), nRuleId, 1, nSeqNum, 1, szBattleTime);
			self:OpenBattle(1, nLevel, 263 + nLevel - 1, string.format("（调试版%d）", nLevel), nRuleId, 1, nSeqNum, 2, szBattleTime);
			tbMission	= self:GetMission(nLevel, 1);
			if (tbMission) then
				me.Msg(string.format("--宋金[%s]一 成功开启！", tbMission:GetFullName()));
			end
			tbMission	= self:GetMission(nLevel, 2);
			if (tbMission) then
				me.Msg(string.format("--宋金[%s]二  成功开启！", tbMission:GetFullName()));
			end
		end
	end
end

function Battle:GM_OpenSp1(nRuleId, nSeqNum)
	if nSeqNum == nil then
		nSeqNum = 1;
	end
	for nLevel = 1, 3 do
		local tbMission	= self:GetMission(nLevel);
		if (tbMission) then
			me.Msg(string.format("--宋金[%s] 正在进行中，请先关闭！", tbMission:GetFullName()));
		else
			local szBattleTime = GetLocalDate("%y%m%d%H");
			self:OpenBattle(1, nLevel, 193 + nLevel - 1, string.format("（调试版%d）", nLevel), nRuleId, 1, nSeqNum, 1, szBattleTime);
			self:OpenBattle(1, nLevel, 269 + nLevel - 1, string.format("（调试版%d）", nLevel), nRuleId, 1, nSeqNum, 2, szBattleTime);
			tbMission	= self:GetMission(nLevel, 1);
			if (tbMission) then
				me.Msg(string.format("--宋金[%s]一 成功开启！", tbMission:GetFullName()));
			end
			tbMission	= self:GetMission(nLevel, 2);
			if (tbMission) then
				me.Msg(string.format("--宋金[%s]二  成功开启！", tbMission:GetFullName()));
			end
		end
	end
end

function Battle:GM_OpenSp_JiaYuGuan(nRuleId, nSeqNum)
	if nSeqNum == nil then
		nSeqNum = 1;
	end
	for nLevel = 1, 3 do
		local tbMission	= self:GetMission(nLevel);
		if (tbMission) then
			me.Msg(string.format("--宋金[%s] 正在进行中，请先关闭！", tbMission:GetFullName()));
		else
			local szBattleTime = GetLocalDate("%y%m%d%H");
			self:OpenBattle(1, nLevel, 1635 + nLevel*3 - 3, string.format("（调试版%d）", nLevel), nRuleId, 2, nSeqNum, 1, szBattleTime);
			self:OpenBattle(1, nLevel, 1636 + nLevel*3 - 3, string.format("（调试版%d）", nLevel), nRuleId, 2, nSeqNum, 2, szBattleTime);
			tbMission	= self:GetMission(nLevel, 1);
			if (tbMission) then
				me.Msg(string.format("--Chiến trường [%s] đã mở!", tbMission:GetFullName()));
			end
			tbMission	= self:GetMission(nLevel, 2);
			if (tbMission) then
				me.Msg(string.format("--Chiến trường [%s] đã mở!", tbMission:GetFullName()));
			end
		end
	end
end

function Battle:GM_Start()
	local tbBackupData		= self.tbBTPLNUM_LOWBOUND;
	self.tbBTPLNUM_LOWBOUND	= {0, 0, 0};
	for nLevel = 1, 3 do
		for i=1, 3 do
			local tbMission	= self:GetMission(nLevel, i);
			if (not tbMission) then
				me.Msg(string.format("--宋金[%s] 未开启，无法开战！", self.NAME_GAMELEVEL[nLevel]));
			elseif (tbMission.nState ~= 1) then
				me.Msg(string.format("--宋金[%s] 状态不对，无法开战！", tbMission:GetFullName()));
			else
				tbMission.nSignUpMsgCount	= 1;
				tbMission:GoNextState();
				me.Msg(string.format("--宋金[%s] 报名结束，开始战斗！", tbMission:GetFullName()));
			end
		end
	end
	self.tbBTPLNUM_LOWBOUND	= tbBackupData;
end

function Battle:GM_Close(nRuleId)
	for nLevel = 1, 3 do
		for i=1, 3 do
			local tbMission	= self:GetMission(nLevel, i);
			if (tbMission) then
				self:CloseBattle(nLevel, tbMission.nBattleKey, i);
				me.Msg(string.format("--宋金[%s] 关闭成功！", tbMission:GetFullName()));
			else
				me.Msg(string.format("--宋金[%s] 未开启，无法关闭！", self.NAME_GAMELEVEL[nLevel]));
			end
		end
	end
end

function Battle:GM_CloseOneBattle(nLevel, nSeq)
	local tbMission	= self:GetMission(nLevel, nSeq);
	if (tbMission) then
		self:CloseBattle(nLevel, tbMission.nBattleKey, nSeq);
		me.Msg(string.format("--宋金[%s] 关闭成功！", tbMission:GetFullName()));
	else
		me.Msg(string.format("--宋金[%s] 未开启，无法关闭！", self.NAME_GAMELEVEL[nLevel]));
	end
end

function Battle:GM_StartOnBattle(nLevel, nSeq)
	local tbBackupData		= self.tbBTPLNUM_LOWBOUND;
	self.tbBTPLNUM_LOWBOUND	= {0, 0, 0};

	local tbMission	= self:GetMission(nLevel, nSeq);
	if (not tbMission) then
		me.Msg(string.format("--宋金[%s] 未开启，无法开战！", self.NAME_GAMELEVEL[nLevel]));
	elseif (tbMission.nState ~= 1) then
		me.Msg(string.format("--宋金[%s] 状态不对，无法开战！", tbMission:GetFullName()));
	else
		tbMission.nSignUpMsgCount	= 1;
		tbMission:GoNextState();
		me.Msg(string.format("--宋金[%s] 报名结束，开始战斗！", tbMission:GetFullName()));
	end

	self.tbBTPLNUM_LOWBOUND	= tbBackupData;
end

function Battle:GM_GotoOneSignUp(nCampId, nBattleSeq)
	local nLevel	= Battle:GetJoinLevel(me);
	
	if (nLevel <= 0) then
		me.Msg("您的等级不足以参加宋金，请先提升等级！");
		return;
	end
	
	if (self.MAPID_LEVEL_CAMP[nLevel][nBattleSeq]) then
		local nMapId	= self.MAPID_LEVEL_CAMP[nLevel][nBattleSeq][nCampId];
		me.NewWorld(nMapId, 1686, 3276);
		me.Msg(string.format("根据您的等级，已将您传送至%s方%s报名点%d！",
			Battle.NAME_CAMP[nLevel], Battle.NAME_GAMELEVEL[nLevel], nBattleSeq));
	end	
end

function Battle:GM_GotoSignUp(nCampId)
	local nLevel	= Battle:GetJoinLevel(me);
	
	if (nLevel <= 0) then
		me.Msg("您的等级不足以参加宋金，请先提升等级！");
		return;
	end
	local tbOpt = {};
	for i=1, #self.MAPID_LEVEL_CAMP[nLevel] do
		tbOpt[#tbOpt + 1] = { string.format("报名点%d", i), "Battle:GM_GotoOneSignUp", nCampId, i};
	end
	Dialog:Say("Bạn chọn chiến trường nào?", tbOpt);
end

function Battle:GM_LevelUp(nLevel)
	local nMyLevel		= me.nLevel;
	local nNextLevel	= Battle.LEVEL_LIMIT[nLevel+1] or 200;
	local tbLevelDesc	= { "初", "中", "高" };
	local szLevelName	= string.format("%s(%s级)", Battle.NAME_GAMELEVEL[nLevel], tbLevelDesc[nLevel]);
	if (nMyLevel >= nNextLevel) then
		me.Msg(string.format("您的级别过高，不能降级参加 %s 了！", szLevelName));
	else
		ST_LevelUp(Battle.LEVEL_LIMIT[nLevel] - me.nLevel);
		me.Msg(string.format("您的等级已符合 %s 的等级需求！", szLevelName));
	end
	me.AddFightSkill("梯云纵", 60);
	me.AddFightSkill("无形蛊", 60);
end

function Battle:AddBounsNoCamp(nBouns)
	local tbTempDate = Battle:GetPlayerData(me);
	if (not tbTempDate) then
		me.Msg("Hiện tại chiến trường chưa mở cửa, không có dữ liệu người chơi");
		return;
	end
	
	if (tbTempDate.tbMission.nState ~= 2) then
		me.Msg("Trận đấu chưa bắt đầu, không thể mở thêm");
		return;
	end
	tbTempDate:AddBounsWithoutCamp(nBouns);
end

function Battle:AddBounsCamp(nBouns)
	local tbTempDate = Battle:GetPlayerData(me);
	if (not tbTempDate) then
		me.Msg("Hiện tại chiến trường chưa mở cửa, không có dữ liệu người chơi");
		return;
	end
	
	if (tbTempDate.tbMission.nState ~= 2) then
		me.Msg("Trận đấu chưa bắt đầu, không thể mở thêm");
		return;
	end
	tbTempDate:AddBounsWithCamp(nBouns);
end
