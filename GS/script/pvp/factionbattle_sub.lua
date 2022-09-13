-------------------------------------------------------------------
--File: 	factionbattle_sub.lua
--Author: 	zhengyuhua
--Date: 	2008-2-25 9:51
--Describe:	门派竞技子功能
-------------------------------------------------------------------

if not FactionBattle then
	FactionBattle = {};
end

-- 给某个玩家箱子
function FactionBattle:GiveABoxPlayer(pPlayer)
	if not pPlayer then
		return 0;
	end
	if pPlayer.CountFreeBagCell() < 1 then	-- 背包空间不足
		pPlayer.Msg("Túi không đủ chỗ trống")
		return 0;
	end
	
		--成就 
	for i = 76,78 do
		Achievement:FinishAchievement(pPlayer, i);
	end
	-- 在新模式下，没采集一个箱子要加经验的
	if FactionBattle.FACTIONBATTLE_MODLE == FactionBattle._MODEL_NEW and FactionBattle.N_BASE_EXP_AWORD_TIME then
		local nExp = math.floor(FactionBattle.N_BASE_EXP_AWORD_TIME * pPlayer.GetBaseAwardExp() * self.AWARD_TIMES);
		if nExp and nExp > 0 then
			pPlayer.AddExp2(nExp,"pvp"); -- 加15分钟的基准经验
			Dbg:WriteLog("FactionBattle", "加采集箱子的经验_新模式", pPlayer.szName, pPlayer.nFaction, "经验:", nExp);
		end
	end
	pPlayer.AddScriptItem(unpack(self.AWARD_ITEM_ID));
end

-- 在某个点组中刷出奖励道具
function FactionBattle:FlushAwardItem(nMapId, tbPoint, nIndex, nPlayerCount)
	local nItemNum = 0;
	for i = 1, 5 do
		if self.PLAYER_COUNT_LIMIT[i] <= nPlayerCount then
			nItemNum = self.BOX_NUM[nIndex][i + 1];
		end
	end
	local nPointCount = #tbPoint;
	if nItemNum > nPointCount then
		nItemNum = nPointCount;
	end
	local tbParam = {};
	tbParam.tbTable = self;
	tbParam.fnAwardFunction = self.GiveABoxPlayer
	for i = 1 , nItemNum do
		local nRand = MathRandom(nPointCount - i + 1);
		local tbTemp = tbPoint[nRand + i - 1];
		tbPoint[nRand + i - 1] = tbPoint[i];
		tbPoint[i] = tbTemp; 
		Npc.tbXiangZiNpc:AddBox(
			nMapId, 
			tbPoint[i].nX, 
			tbPoint[i].nY, 
			FactionBattle.TAKE_BOX_TIME * Env.GAME_FPS, 
			tbParam,
			1,
			60 * 18
		);
	end
	return 0;
end

-- 冠军授予功能启动
function FactionBattle:AwardChampionStart(nFaction, nWinnerId)
	local pFlagNpc = KNpc.Add2(
		self.FLAG_NPC_TAMPLATE_ID, 
		10, 
		-1, 
		self.FACTION_TO_MAP[nFaction], 
		self.FLAG_X, 
		self.FLAG_Y
	);
	local tbTemp = pFlagNpc.GetTempTable("FactionBattle");
	tbTemp.tbFactionData = {};
	tbTemp.tbFactionData.nWinnerId = nWinnerId;
	tbTemp.tbFactionData.nFlagNpcId = pFlagNpc.dwId;	-- 记录一下NPC的Id，
	local tbData = self:GetFactionData(nFaction);
	if tbData then
		tbData.nFlagNpcId = pFlagNpc.dwId;	-- 记录一下NPC的Id
	end
	-- 这里可能有些问题啊
	tbTemp.tbFactionData.nFlagTimerId = Timer:Register(	-- 注册旗帜是删除时间
		self.FLAG_EXIST_TIME * Env.GAME_FPS,
		self.CancelAwardChampion,
		self,
		pFlagNpc.dwId
	);
end

-- 触发冠军授予
function FactionBattle:ExcuteAwardChampion(pPlayer, pNpc)
	local tbTemp = pNpc.GetTempTable("FactionBattle");
	if (not tbTemp.tbFactionData) or 
		(not tbTemp.tbFactionData.nWinnerId) or
		(tbTemp.tbFactionData.nWinnerId ~= pPlayer.nId) then
		return 0;
	end
	
	local tbData = self:GetFactionData(pPlayer.nFaction);
------------------------------------------------------------------------------------------------------------------------------
	if not tbData then
		Dbg:WriteLog("FactionBattle", "竞技模式", FactionBattle.FACTIONBATTLE_MODLE, "冠军奖励，获取门派数据为空", pPlayer.szName, pPlayer.szAccount);
		assert(false, "怎么可能啊，门派数据位空");
	end
-- 给观众发奖励，别人看你这么久，都没有什么好处的话，也太不厚道了吧~~ xuantao 2010/12/7 14:58:24
	if FactionBattle.FACTIONBATTLE_MODLE == FactionBattle._MODEL_NEW and tbData then
		--print("发奖罗~~")
		tbData:ChampionAword_New(pPlayer);
		if tbData:GetChampionAwordCount() < FactionBattle.CHAMPION_AWARD_COUNT then
			return 0;
		end
	end
------------------------------------------------------------------------------------------------------------------------------
	-- 授予称号
	pPlayer.AddTitle(self.TITLE_GROUP, self.TITLE_ID, pPlayer.nFaction, 0);
	-- 特效
	pPlayer.CastSkill(self.YANHUA_SKILL_ID, 1, -1, pPlayer.GetNpc().nIndex);
	-- 奖励
	local tbPlayer = KPlayer.GetMapPlayer(pNpc.nMapId);
	local nPlayerCount = #tbPlayer;
	if self._MODEL_OLD == FactionBattle.FACTIONBATTLE_MODLE then
		self:FlushAwardItem(
			pNpc.nMapId, 
			self.tbBoxPoint[9],
			5,
			nPlayerCount
		);	-- 临时
	end
	local nNpcMapId, nNpcPosX, nNpcPosY = pNpc.GetWorldPos();
	--刷出篝火
	local tbNpc	= Npc:GetClass("gouhuonpc");
	local pGouHuoNpc	= KNpc.Add2(self.GOUHUO_NPC_ID, 1, -1, nNpcMapId, nNpcPosX, nNpcPosY);		-- 获得篝火Npc
	--篝火参数： Id， 类型， 持续时间，跳跃时间，范围(格子直径)，倍率，酒是否有效，修理珠是否有效
	tbNpc:InitGouHuo(pGouHuoNpc.dwId, 0, self.GOUHUO_EXISTENTIME, 5, 90, self.GOUHUO_BASEMULTIP, 0, 0);
	tbNpc:StartNpcTimer(pGouHuoNpc.dwId)
	
	Timer:Close(tbTemp.tbFactionData.nFlagTimerId);
	pNpc.Delete();
	if tbData then
		tbData:MsgToMapPlayer("Tân nhân vương chưa lên võ đài nhận thưởng.")	
		tbData:ShutDown(1);		-- 圆满结束了
	end

	-- 冠军可以领取奖励
	if FactionBattle.FACTIONBATTLE_MODLE == FactionBattle._MODEL_NEW and tbData then
		Dialog:Say("Nếu không nhận thưởng lúc này, có thể đến Chưởng môn để nhận sau!", 
			{
				{"Nhận ngay", self.ExchangeExp, self, pPlayer.nId, 0, 1},
				{"Không nhận lúc này"}
			});
	end
end

-- 冠军授予超时
function FactionBattle:CancelAwardChampion(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local tbTemp = pNpc.GetTempTable("FactionBattle");
	if (tbTemp.tbFactionData) and (tbTemp.tbFactionData.nWinnerId) then
		local pPlayer = KPlayer.GetPlayerObjById(tbTemp.tbFactionData.nWinnerId);
		if pPlayer then
			Dbg:WriteLog("FactionBattle", "因超时而没领取到冠军奖励", pPlayer.szName, pPlayer.szAccount);
		end
	end
	pNpc.Delete();
end

-- 晋级送礼
function FactionBattle:PromotionAward(nMapId, nArenaId, nIndex, nPlayer1Id, nPlayer2Id, nPlayerCount)
	if not self.tbBoxPoint then
		return 0;
	end
	if FactionBattle._MODEL_OLD == FactionBattle.FACTIONBATTLE_MODLE then
		Timer:Register(self.ADD_BOX_DELAY * Env.GAME_FPS,  
			self.FlushAwardItem,
			self,
			nMapId, 
			self.tbBoxPoint[nArenaId],
			nIndex,
			nPlayerCount
		);
	end
end

-- 积分兑换经验功能
function FactionBattle:ExchangeExp(nPlayerId, bConfirm, bIgnor)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	bIgnor = bIgnor or 0;
	if not pPlayer then
		return 0;
	end
-------------------------------------------------------------------------------------------------------------------------------------
-- 设置模式，打了什么模式的比赛，就应该领取什么模式的奖励
	local nModel = KGblTask.SCGetDbTaskInt(DATASK_FACTIONBATTLE_MODEL);	-- 获取当前的比赛模式

	if nModel ~= self._MODEL_NEW and nModel ~= self._MODEL_OLD then
		--assert(false, "比赛模式都不认识，怎么办哈~~");
		nModel = self._MODEL_OLD;
	end
	
	if self.FACTIONBATTLE_MODLE ~= nModel then
		self:SetDefByMode(nModel);
	end
------------------------------------------------------------------------------------------------------------------------------------
	local nGroupId = self.TASK_GROUP_ID;
	local nDegreeId = self.DEGREE_TASK_ID;
	local nScoreId = self.SCORE_TASK_ID;
	local nElimatId = self.ELIMINATION_TASK_ID;
	local nScore = pPlayer.GetTask(nGroupId, nScoreId);
	local nElimat = pPlayer.GetTask(nGroupId, nElimatId);
	
	if self:CheckDegree(pPlayer) == 0 then	-- 检查届数
		nScore = 0;
		nElimat = 0;
	end
	local nFlag = self:GetBattleFlag(pPlayer.nFaction);
	if nFlag == 1  and bIgnor ~= 1 then
		Dialog:Say("Đang trong thời gian thi đấu không thể đổi điểm");
		return 0;
	end
	if nScore == 0 and nElimat <= 2  then
		Dialog:Say("Hiện tại không có điểm để đổi.");
		return 0;
	end
	local nExp = math.floor((nScore / 4800) * pPlayer.GetBaseAwardExp() * 90) * self.AWARD_TIMES;
	local nXiangZi = math.floor(nScore / 2400) * self.AWARD_TIMES;
	local nWeiWang = 0;
	if nScore >= 4800 then
		nWeiWang = 8;
	elseif nScore >= 4000 then
		nWeiWang = 6;
	elseif nScore >= 3200 then
		nWeiWang = 5;
	elseif nScore >= 2400 then
		nWeiWang = 4;
	end
	local nExpEx = 0;
	local nXiangZiEx = 0;
	local nStoneAward = 0;
	local szTitle = "";
	local nRank = 100;
	if nElimat > 2 then
		if self.BOX_NUM[nElimat - 2][1] == 1 then
			szTitle = "Nhận <color=red>Quán Quân<color>";
		else
			szTitle = "Nhận <color=red>"..self.BOX_NUM[nElimat - 2][1].."<color>";
		end
		if self.BOX_NUM[nElimat - 2][1] then
			nRank = self.BOX_NUM[nElimat - 2][1]
		end
		nExpEx = self.AWARD_TABLE[nElimat][4] * pPlayer.GetBaseAwardExp() * self.AWARD_TIMES;
		nXiangZiEx = self.AWARD_TABLE[nElimat][5] * self.AWARD_TIMES;
	end
	
	local tbStoneAward = self:GetStoneAward(nRank);
	if tbStoneAward then
		for _, tbSingleAward in pairs(tbStoneAward) do
			nStoneAward = nStoneAward + 1;		-- todo zjq 宝石箱子可以叠加，所以只需要一个背包空间，如果以后不能叠加要注意
		end
	end
	
	local nFreeCount, tbExecute, szExtendInfo = SpecialEvent.ExtendAward:DoCheck("FactionBattle", pPlayer, nScore, nRank, (nXiangZi + nXiangZiEx));
	if bConfirm == 1 then
		local nBagNeed = nXiangZi + nXiangZiEx + nFreeCount + nStoneAward;
		if pPlayer.CountFreeBagCell() < nBagNeed then
			local szError = string.format("Hành Trang không đủ chỗ trống, cần <color=green>%s<color> ô trống.", nXiangZi + nXiangZiEx + nFreeCount)
			pPlayer.Msg(szError);
			return 0;
		end
		for i = 1, nXiangZi + nXiangZiEx do
			pPlayer.AddScriptItem(unpack(self.AWARD_ITEM_ID));
		end
		
		-- AddStackItem里已经有LOG记录了，这里就不再做添加是否添加成功的判断了
		if (tbStoneAward) then
			for _, tbSingleAward in pairs(tbStoneAward) do
				-- 记录门派竞技日志
				pPlayer.AddStackItem(unpack(tbSingleAward));
				StatLog:WriteStatLog("stat_info", "baoshixiangqian", "menpai", me.nId, string.format("%d_%d_%d_%d,%d", 
					tbSingleAward[1], tbSingleAward[2], tbSingleAward[3], tbSingleAward[4], tbSingleAward[6]));
			end
		end		
		--pPlayer.AddExp(nExp + nExpEx); 
		pPlayer.AddExp2(nExp + nExpEx,"pvp"); -- mod zounan 修改经验接口
		pPlayer.AddKinReputeEntry(nWeiWang, "factionbattle");
		pPlayer.SetTask(nGroupId, nScoreId, 0);	-- 积分清零
		pPlayer.SetTask(nGroupId, nElimatId, 0); -- 清淘汰赛成绩
		SpecialEvent.ExtendAward:DoExecute(tbExecute);
		
		-- 为玩家参加门派竞技的计数加1
		Stats.Activity:AddCount(pPlayer, Stats.TASK_COUNT_FACTION, 1);
		if nScore >= 500 then
			SpecialEvent.tbGoldBar:AddTask(pPlayer, 10);		--金牌联赛门派竞技
		end
		Dbg:WriteLog("FactionBattle", "门派竞技模式", FactionBattle.FACTIONBATTLE_MODLE,"领取奖励", pPlayer.szName, pPlayer.szAccount,"奖励", nExpEx + nExp, nXiangZiEx + nXiangZi);
		return 0;
	end
	local szMsg = string.format("Điểm hiện tại của bạn là: <color=green>%s<color>, Có thể đổi: <color=green>%s<color> kinh nghiệm, <color=green>%s<color> bảo rương.\n", 
		nScore, nExp, nXiangZi);
	local szModeMsg = "";
	if nElimat > 2 then
		szMsg = szMsg..string.format("Với thành tích "..szTitle..", bạn có thể nhận được <color=green>%s<color> kinh nghiệm, <color=green>%s<color> bảo rương.\n",
			nExpEx, nXiangZiEx);
		szModeMsg = string.format( "Ngươi tại thi đấu thể thao thể hiện xuất sắc, "..szTitle..", do dó dành cho thêm vào thưởng cho: <color=green>%s<color> kinh nghiệm,<color=green>%s<color> cái rương \n",
			nExpEx, nXiangZiEx);
	end
	local szStoneMsg = "";
	if (tbStoneAward) then		-- 宝石
		local nStoneCount = 0;
		for _, tbSingleAward in pairs(tbStoneAward) do
			nStoneCount = tbSingleAward[6];
		end
		szStoneMsg = string.format("Ngươi cũng có thể nhận thêm <color=green>%s Mông Trần Bảo Thạch<color>", nStoneCount);		
	end
	
	if nModel == FactionBattle._MODEL_OLD then
		szMsg = szMsg .. szStoneMsg .. szExtendInfo;
	else
		szMsg = szModeMsg .. szStoneMsg .. szExtendInfo;
	end
	Dialog:Say(szMsg,
		{
			{"Ta muốn trao đổi", self.ExchangeExp, self, me.nId, 1, bIgnor},
			{"Để ta suy nghĩ đã"},
		})
end

-- 为参加者增加心得、威望、声望
function FactionBattle:AwardAttender(pPlayer, nIndex)
	self:CheckDegree(pPlayer);
	if pPlayer then
		local nOldIndex = pPlayer.GetTask(self.TASK_GROUP_ID, self.ELIMINATION_TASK_ID);
		Setting:SetGlobalObj(pPlayer);
		for i = nOldIndex + 1, nIndex do
			Task:AddInsight(self.AWARD_TABLE[i][1]);
			pPlayer.AddKinReputeEntry(self.AWARD_TABLE[i][2], "factionbattle");		-- 威望
			pPlayer.AddRepute(Player.CAMP_FACTION, me.nFaction, self.AWARD_TABLE[i][3]);
			
			-- 荣誉 
			self:AddFactionHonor(pPlayer, self.AWARD_TABLE[i][7]);
					
			-- 记录比赛成绩任务变量
			pPlayer.SetTask(self.TASK_GROUP_ID, self.ELIMINATION_TASK_ID, nIndex); 
			
			-- 增加建设资金和个人、帮主、族长的股份
			--print(pPlayer.szName, self.AWARD_TABLE[i][6], 0.7, 0.2, 0.05, 0, 0.05)
			Tong:AddStockBaseCount_GS1(pPlayer.nId, self.AWARD_TABLE[i][6], 0.7, 0.2, 0.05, 0, 0.05);
		end
		Setting:RestoreGlobalObj();
	end
end

-- 加门派荣誉
function FactionBattle:AddFactionHonor(pPlayer, nHornor)
	local nFaction = pPlayer.nFaction;
	PlayerHonor:AddPlayerHonor(pPlayer, self.HONOR_CLASS, self.HONOR_WULIN_TYPE, nHornor);
end

function FactionBattle:CheckDegree(pPlayer)
	if not pPlayer then
		return 0;
	end
	local nGroupId = self.TASK_GROUP_ID;
	local nDegreeId = self.DEGREE_TASK_ID;
	local nScoreId = self.SCORE_TASK_ID;
	local nElimatId = self.ELIMINATION_TASK_ID;
	local nDegree =	pPlayer.GetTask(nGroupId, nDegreeId)
	local nCurDegree = GetFactionBattleCurId();
	if nCurDegree ~= nDegree then	-- 届数不同，积分无效~清积分
		pPlayer.SetTask(nGroupId, nDegreeId, nCurDegree);
		pPlayer.SetTask(nGroupId, nScoreId, 0);
		pPlayer.SetTask(nGroupId, nElimatId, 0);
		return 0;
	end
	return 1;
end

function FactionBattle:DescribNewModel(nFaction)
	local function funOpenWindow()
		me.CallClientScript({"UiManager:SwitchWindow", "UI_HELPSPRITE"});
	end
	local szMsg = string.format("\n  3、Số lượng tham gia tối thiểu là %d người.", FactionBattle.MIN_ATTEND_PLAYER);
	Dialog:Say("  1、Giai đoạn 1 sẽ chia thành 2 phe để giao chiến. Phe thắng sẽ được thưởng 10% tích lũy.\n  2、Rút ngắn thời gian hoạt động." .. szMsg,
		{
			{"Mở F12", funOpenWindow},
			{"Tôi biết rồi"},
		});
end

-- 获取宝石奖励信息
function FactionBattle:GetStoneAward(nRank)
	if Item.tbStone:GetOpenDay() == 0 then
		return;
	end
	
	for _, tbAward in pairs(self.STONE_AWARD_TABLE) do
		if nRank <= tbAward[1] then
			return tbAward[2];
		end
	end	
end