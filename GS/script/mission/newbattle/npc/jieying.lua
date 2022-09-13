-- 文件名　：jieying.lua
-- 创建者　：LQY
-- 创建时间：2012-07-19 08:39:27
--

local tbNpc = Npc:GetClass("NewBattle_jieying")

function tbNpc:OnDialog(szCamp)
	if NewBattle.Mission:IsOpen() == 1 then
		self.tbMission = NewBattle.Mission;
	else
		self.tbMission = nil;
	end
	self.nCampId = (szCamp == "song")and  1 or 2;
	self.tbDialog	= Battle.tbCampDialog[self.nCampId];
	self.nLevel		= self.nLevel or 0;
	self.nMapId 	=  him.GetWorldPos();
	if self.nLevel == 0 then
		for nLvl, tbMaps in pairs(NewBattle.TB_MAP_BAOMING) do
			for _,tbM in pairs(tbMaps) do
				if tbM[nCampId] == nMapId then
					self.nLevel = nLvl;
				end
			end		
		end	
	end
	self.tbBattleSeq = NewBattle.tbNewBattleSeq[self.nLevel];
	if (me.IsFreshPlayer() == 1) then
		Dialog:Say("Chưa gia nhập môn phái không thể vào chiến trường.");
		return;
	end
	
	if (Battle:GetJoinLevel(me) ~= self.nLevel) then
		Dialog:Say("Trình độ quá kém, về tu luyện thêm đi.");
		return;
	end

	if not GLOBAL_AGENT then
		if (0 == self:AwardGood()) then
--			return;
--		end
	--	if (2 == self:ProcessBattleBouns()) then
		--	Dialog:Say("本周周积分将会刷新，您还有积分没兑换掉，去<color=yellow>报名点军需官<color>那儿兑换完积分再来吧！");
			return;
		end
	end

	Battle:DbgOut("tbNpcBase:OnDialog", self, self.nMapId, self.tbMission);
	if (not self.tbMission) then
		Dialog:Say("Quân đội vẫn chưa đến thời gian xuất phát. Hãy tiếp tục tập luyện và đợi có thông báo!");
		return;
	end
	
	local szDialogMsg = "    Ngươi muốn tham gia chiến trường Băng Hỏa Liên Thành chứ? Hãy kêu gọi hảo hữu và lập tổ đội để cùng chiến đấu.";
	local nXia, nJing = NewBattle:GetPlayerCount();
	local tbDialogOpt = {};
	if szCamp == "jin" then
		table.insert(tbDialogOpt,{"Vào phe <color=pink>Tây Hạ<color> (<color=cyan>"..nJing.."<color>) người".." "..((nJing - nXia >=NewBattle.SIGNLIMIT or nJing >= NewBattle.MAXPLAYER) and "<color=red>●<color>" or "<color=green>●<color>"), self.JoinBattle, self, 2});
	elseif szCamp == "song" then
		table.insert(tbDialogOpt,{"Vào phe <color=orange>Mông Cổ<color> (<color=cyan>"..nXia.." người<color>)".." "..((nXia - nJing >=NewBattle.SIGNLIMIT or nXia >= NewBattle.MAXPLAYER) and "<color=red>●<color>" or "<color=green>●<color>"), self.JoinBattle, self, 1});
	end
	table.insert(tbDialogOpt,{"Ta chỉ xem qua"});
	Dialog:Say(szDialogMsg, tbDialogOpt);
end

function tbNpc:JoinBattle(nType)

	local n,szMsg = NewBattle:CanPlayerJoinPower(me, nType);
	if n == 0 then
		Dialog:Say(szMsg);
		return;
	end
	if NewBattle.nBattle_State == 3 then
	--记录玩家参加宋金战场的次数
		local nBTKey = self.tbMission.nBattleKey;
		local bIsDiffBattle = Battle:IsDiffBattle(me, nBTKey)
		if (bIsDiffBattle and 1 == bIsDiffBattle) then
			Stats.Activity:AddCount(pPlayer, Stats.TASK_COUNT_BATTLE, 1);
			local nTimes = me.GetTask(SpecialEvent.tbPJoinEventTimes.TASKGID, SpecialEvent.tbPJoinEventTimes.TASK_JOIN_BATTLE);
			me.SetTask(SpecialEvent.tbPJoinEventTimes.TASKGID, SpecialEvent.tbPJoinEventTimes.TASK_JOIN_BATTLE, nTimes + 1);
		end
		
		me.SetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_KEY, self.tbMission.nBattleKey);
		me.SetTask(Battle.TSKGID, Battle.TASKID_BTCAMP, self.nCampId);
	end
	NewBattle:PlayerJoin(me, nType);
	me.NewWorld(NewBattle.Mission.nMapId, unpack(NewBattle:GetRandomPoint(NewBattle.POS_READY[NewBattle.POWER_ENAME[nType]])));
end


-- 奖励上一场宋金战场的积分对应的奖励，返回1表示继续，返回0表示不用继续了
function tbNpc:AwardGood()
	-- 判断是否能给予奖励
	local pPlayer = me;
	if (self.tbMission) then
		local nCampId		= pPlayer.GetTask(Battle.TSKGID, Battle.TASKID_BTCAMP);
		local nMyBTKey		= pPlayer.GetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_KEY);
		local nBTKey		= self.tbMission.nBattleKey;
		local nDiaFlag		= 0;

		local nBattleSeqA	= math.fmod(nMyBTKey, 10);
		local nBattleSeqB	= math.fmod(nBTKey, 10);
		local nBattleTimeA	= nMyBTKey - nBattleSeqA;
		local nBattleTimeB	= nBTKey - nBattleSeqB;

		-- id不一样表示可能是同一时间段不同场次，可能是不同一时间段
		if (nMyBTKey ~= nBTKey) then
			-- 如果是同一时间段的表示这个玩家可能从另一个场次出来到其他场次
			if (nBattleTimeA == nBattleTimeB) then
				nDiaFlag = 1;
			end
		else -- 相同id

			-- 同一场次却不是同一阵营
			if (0 ~= nCampId and self.nCampId ~= nCampId) then
				nDiaFlag = 2;
			-- 如果战局开始了就不能领了，直接继续下面对话
			elseif (NewBattle.nBattle_State == 3) then
				return 1;
			end		
		end

		if (nDiaFlag == 1) then
			Dialog:Say(string.format(self.tbDialog[8], Battle.NAME_GAMELEVEL[self.nLevel], self.tbBattleSeq[nBattleSeqA], Battle.NAME_CAMP[nCampId]));
			return 0;
		elseif (nDiaFlag == 2) then
			Dialog:Say(self.tbDialog[5]);
			return 0;
		end
	end

	local nAwardPai = pPlayer.GetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_ZHANCHANGLINGPAI);
	local nAwardFu	= pPlayer.GetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_FUDAI);
	local nBouns	= pPlayer.GetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_TOTALBOUNS);
	
	local nAwardRank, nMoney, tbXuanjing, nExpTime = nil, 0, {}, 0;
	-- if (EventManager.IVER_bOpenTiFu == 1) then
		nAwardRank = pPlayer.GetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_AWARDRANK);
		nMoney, tbXuanjing, nExpTime = 0, {}, 0;
		if (nAwardRank ~= 0) then
			if Battle.tbTiFuAwardList[nAwardRank] then
				nMoney = Battle.tbTiFuAwardList[nAwardRank]["money"];
				tbXuanjing = Battle.tbTiFuAwardList[nAwardRank]["xuanjing"];
				nExpTime = Battle.tbTiFuAwardList[nAwardRank]["zhenyuanexp"];
			end
		end
	-- end
	
	if (nAwardPai + nAwardFu + nBouns > 0) then
		local nPaiCount		= 0;
		local nFuCount		= 0;
		local szMsg = string.format("Tích lũy của bạn là %d", nBouns);
		local nFinalBouns	= 0;
		
		if (nBouns > 0) then
			nFinalBouns = nBouns;
			local nMyUse = pPlayer.GetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_USEBOUNS);
			if (nMyUse + nBouns > Battle.BATTLES_POINT2EXP_MAXEXP) then
				nFinalBouns = Battle.BATTLES_POINT2EXP_MAXEXP - nMyUse;
			end
		end
		
		if (nMoney > 0) then
			szMsg = szMsg..string.format(", nhận được %d bạc", nMoney);
		end
		
		if (nFinalBouns > 0) then
			szMsg = szMsg .. string.format(", có thể nhận được %d phần thưởng kinh nghiệm", nFinalBouns);
		elseif (nFinalBouns == 0 and nBouns > 0) then
			szMsg = szMsg .. string.format(", kinh nghiệm tuần này đã đạt giới hạn tuần <color=yellow>500.000<color> điểm, sẽ không thể nhận thêm.");
		end
		
		if (nAwardPai > 0 and nAwardFu > 0) then
			szMsg = szMsg .. string.format(", nhận được 1 phần thưởng chiến trường %svà 2 Thương hội thư quyển", Battle.NAME_GAMELEVEL[nAwardPai]);
			nPaiCount	= 1;
			nFuCount	= nAwardFu;
		elseif (nAwardFu > 0) then
			szMsg = szMsg .. ", nhận được 1 Thương hội thư quyển";
			nFuCount = nAwardFu;
		end
		local tbOpt = { 
			{"Đồng ý", self.OnAwardGood, self, pPlayer, nAwardPai, nPaiCount, nFuCount, nBouns, nFinalBouns, nMoney, tbXuanjing, nExpTime}, 
			{"Ta nhận sau"},
		};
		local _, _, szExtendInfo = SpecialEvent.ExtendAward:DoCheck("Battle", pPlayer, nBouns, self.nLevel);
		Dialog:Say(szMsg..szExtendInfo..", ngươi muốn nhận ngay bây giờ?", tbOpt);
		return 0;
	end
	return 1;
end

function tbNpc:OnAwardGood(pPlayer, nItemId, nPaiCount, nFuCount, nBouns, nFinalBouns, nMoney, tbXuanJing, nExpTime)
	local nCount = 0;
	local szMsg1 = szMsg1 or "";
	for i, v in pairs(tbXuanJing) do
		nCount = nCount + v;
	end
	if (pPlayer.CountFreeBagCell() < nCount) then
		pPlayer.Msg("Hành trang không đủ chỗ trống.");
		return 0;
	end
	if (0 == Battle:AwardGood(pPlayer, nItemId, nPaiCount, nFuCount, nBouns, self.nLevel)) then
		-- 保存玩家义军令牌的等级
		pPlayer.Msg("Hành trang không đủ chỗ trống.");
		return 0;
	else
		local nAwardRank = pPlayer.GetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_AWARDRANK);
		me.Earn(nMoney, Player.emKEARN_EVENT);
		for i, v in pairs(tbXuanJing) do
			me.AddStackItem(18, 1, 1, i, nil, v);
		end
		
		Item.tbZhenYuan:AddExp(nil, nExpTime, 0, me);
		me.SetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_AWARDRANK, 0)
		
		if (nMoney > 0) then
			szMsg1 = szMsg1..string.format(", nhận được %d bạc", nMoney);
		end
		local szMsg = string.format("Điểm tích lũy cuối cùng là %d", nBouns);
		if (nFinalBouns > 0) then
			szMsg = szMsg .. szMsg1 .. string.format(", nhận được %d phần thưởng kinh nghiệm.", nFinalBouns);
		elseif (nFinalBouns == 0 and nBouns > 0) then
			szMsg = szMsg .. string.format(", kinh nghiệm tuần này đã đạt giới hạn tuần <color=yellow>500.000<color> điểm, sẽ không thể nhận thêm.");
		end
		if (nPaiCount > 0) then
			szMsg = szMsg .. string.format(", nhận được 1 phần thưởng chiến trường %s và 2 Thương hội thư quyển.", Battle.NAME_GAMELEVEL[nItemId]);
		elseif (nFuCount > 0) then
			szMsg = szMsg .. ", nhận được 1 Thương hội thư quyển.";
		end
		pPlayer.Msg(szMsg);
		-- 参加了一次宋金
		StudioScore:OnActivityFinish("songjin", pPlayer);
		SpecialEvent.ActiveGift:AddCounts(pPlayer, 31);		--领取宋金奖励完成一场宋金活跃度
		SpecialEvent.BuyOver:AddCounts(pPlayer, SpecialEvent.BuyOver.TASK_TONGKIM);
	end
	return;
end
	