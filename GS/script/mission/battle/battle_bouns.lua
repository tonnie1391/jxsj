-----------------------------------------------------
--文件名		：	battle_bouns.lua
--创建者		：	zhouchenfei
--创建时间		：	2007-10-23
--功能描述		：	战场中的分值处理
------------------------------------------------------

-- 重置积分
function Battle:ResetBonus(pPlayer, nNowTime)
	pPlayer.Msg("积分被清空！");
	pPlayer.SetTask(self.TSKGID, self.TSK_BTPLAYER_TOTALBOUNS, 0);
	pPlayer.SetTask(self.TSKGID, self.TSK_BTPLAYER_LASTBOUNSTIME, nNowTime);
end

-- 重置使用积分上限
function Battle:OnWeekEvent_ResetUseBouns()
	local nUseBouns	 = me.GetTask(self.TSKGID, self.TSK_BTPLAYER_USEBOUNS);
	Battle:DbgWrite(Dbg.LOG_INFO, "OnWeekEvent_ResetUseBouns", self.TSKGID, self.TSK_BTPLAYER_USEBOUNS, 0);
	me.SetTask(self.TSKGID, self.TSK_BTPLAYER_USEBOUNS, 0);
end

-- 检查是否是新的一周
function Battle:CheckNewWeek(pPlayer, nNowTime)
	local nLastTime		  	= pPlayer.GetTask(self.TSKGID, self.TSK_BTPLAYER_LASTBOUNSTIME);
	local nLastDay 			= math.ceil(nLastTime / (3600 * 24));
	local nNowDay			= math.ceil(nNowTime / (3600 * 24));
	
	if (nNowDay <= nLastDay) then
		return;
	end

	-- 从星期天开始算,为一个星期的第一天
	nLastDay 			= nLastDay - 4;
	nNowDay				= nNowDay - 4;
	local nLastWeek		= math.floor(nLastDay / 7);
	local nNowWeek		= math.floor(nNowDay / 7);
	if (nNowWeek > nLastWeek) then
		return 1;
	end
	return 0;
end

-- 处理连斩积分奖励
function Battle:ProcessSeriesBouns(tbKillerBattleInfo, tbDeathBattleInfo)
	local nMeRank			= tbDeathBattleInfo.nRank;
	local nPLRank			= tbKillerBattleInfo.nRank;
	local pPlayer			= tbKillerBattleInfo.pPlayer;
	-- 符合连斩条件 计算有效连斩
	if (5 >= (nPLRank - nMeRank)) then
		local nSeriesKill	= tbKillerBattleInfo.nSeriesKill + 1;
		tbKillerBattleInfo.nSeriesKill	= nSeriesKill;

		if (math.fmod(nSeriesKill, 3) == 0) then	
			tbKillerBattleInfo.nTriSeriesNum	= tbKillerBattleInfo.nTriSeriesNum + 1;
			self:AddShareBouns(tbKillerBattleInfo, self.SERIESKILLBOUNS)
			tbKillerBattleInfo.pPlayer.Msg(string.format("Quân %s - %s %s liên tiếp tiêu diệt %d quân địch, nhận thưởng Liên Trảm %d điểm tích lũy.", Battle.NAME_CAMP[tbKillerBattleInfo.tbCamp.nCampId], Battle.NAME_RANK[tbKillerBattleInfo.nRank], tbKillerBattleInfo.pPlayer.szName, tbKillerBattleInfo.nSeriesKill, self.SERIESKILLBOUNS));
		end

		if (tbKillerBattleInfo.nMaxSeriesKill < nSeriesKill) then
			tbKillerBattleInfo.nMaxSeriesKill = nSeriesKill;
		end
	end
	
	-- 计算连斩	
	local nSeriesKillNum	= tbKillerBattleInfo.nSeriesKillNum + 1;
	tbKillerBattleInfo.nSeriesKillNum	= nSeriesKillNum;
	pPlayer.ShowSeriesPk(1, nSeriesKillNum, 60);
	if (tbKillerBattleInfo.nMaxSeriesKillNum < nSeriesKillNum) then
		tbKillerBattleInfo.nMaxSeriesKillNum = nSeriesKillNum;
	end
	local tbAchievementSeriesKill = 
	{
		[3] = 138,
		[10] = 139,
		[30] = 140,
		[50] = 141,
		[100] = 142,
	};
	if tbAchievementSeriesKill[nSeriesKillNum] then
		Achievement:FinishAchievement(pPlayer, tbAchievementSeriesKill[nSeriesKillNum]);	--连斩。
	end
	Achievement:FinishAchievement(pPlayer, 125);	--个人击退一名敌对玩家。
	Achievement:FinishAchievement(pPlayer, 126);	--个人击退20名敌对玩家
	Achievement:FinishAchievement(pPlayer, 127);	--个人击退200名敌对玩家。
end

-- 获得杀死玩家积分奖励
function Battle:GiveKillerBouns(tbKillerBattleInfo, tbDeathBattleInfo)
	tbKillerBattleInfo.nKillPlayerNum	= tbKillerBattleInfo.nKillPlayerNum + 1;
	
	-- 要不要做安全性检测呢？
	local nMeRank		= tbDeathBattleInfo.nRank;
	local nPLRank		= tbKillerBattleInfo.nRank;
	
	local nRadioRank	= 1;
	nRadioRank			= (10 - (nPLRank - nMeRank)) / 10;
	local nPoints		= math.floor(Battle.tbBonusBase.KILLPLAYER * nRadioRank);
	local nBounsDif		= self:AddShareBouns(tbKillerBattleInfo, nPoints)
	if (nBounsDif > 0) then
		tbKillerBattleInfo.nKillPlayerBouns = tbKillerBattleInfo.nKillPlayerBouns + nPoints;
	end
end

-- 获得战旗积分奖励
function Battle:GetTheFlagBouns(tbBattleInfo)
	local nCamp				= tbBattleInfo.tbCamp.nCampId;
	local nBounsDif 		= self:AddShareBouns(tbBattleInfo, Battle.tbBonusBase.SNAPFLAG)
	if (nBounsDif > 0) then
		tbBattleInfo.nFlagsBouns = tbBattleInfo.nFlagsBouns + Battle.tbBonusBase.SNAPFLAG;
	end
	tbBattleInfo.nFlagNum	= tbBattleInfo.nFlagNum + 1;
end

-- 获得珍宝积分奖励
function Battle:GetTheTreasure(tbBattleInfo)
	local nCamp				= tbBattleInfo.tbCamp.nCampId;
	local nBounsDif 		= self:AddShareBouns(tbBattleInfo, Battle.tbBonusBase.GETITEM)
	if (nBounsDif > 0) then
		tbBattleInfo.nTreasureBouns = tbBattleInfo.nTreasureBouns + Battle.tbBonusBase.GETITEM;
	end
	tbBattleInfo.nTreasure	= tbBattleInfo.nTreasure + 1;
end

-- 积分换经验
function Battle:BounsChangeExp(nLevel, nBouns)
	local nExp = 0;
	if (nLevel < 40) then
		return 0;
	end
	
	if (nLevel > 120) then
		nLevel = 120;
	end
	
	nExp = math.floor(( 700 + math.floor(( nLevel - 40 ) / 5 ) * 100 ) * 60 * 7 /3000 )	* nBouns -- 1个积分点的基础经验值
	
	local nKinId = me.dwKinId;
	local cKin = KKin.GetKin(nKinId);
	if (cKin) then
		local nWeeklyTask = cKin.GetWeeklyTask();
		if (Kin.TASK_BATTLE == nWeeklyTask) then
			nExp = math.floor(nExp * 1.5);
		end
	end
	return nExp;
end

-- 战局结束时的声望按排名奖励
function Battle:AwardFinalShengWang(tbPlayerList)
	local nNowShengWang = 0;
	local nMaxRank		= 0;
	local nIndex		= 0;
	for i = 1, #tbPlayerList do
		local tbBattleInfo 	= tbPlayerList[i];
		local nNowShengWang	= 0;
		local nRankSheng	= 0;
		local nBounsSheng	= 0;
		if (1 == i) then
			nRankSheng = Battle.tbRANKSHENGWANG[1];
		elseif (2 <= i and 4 >= i) then
			nRankSheng = Battle.tbRANKSHENGWANG[2];
		elseif (5 <= i and 10 >= i) then
			nRankSheng = Battle.tbRANKSHENGWANG[3];
		elseif (11 <= i and 20 >= i) then
			nRankSheng = Battle.tbRANKSHENGWANG[4];
		end
		
		for key, tbRankBouns in ipairs(Battle.tbBOUNSSHENGWANG) do
			if (tbBattleInfo.nBouns >= tbRankBouns[1]) then
				nBounsSheng = tbRankBouns[2];
				break;
			end
		end
		nNowShengWang = nRankSheng;
		if (nBounsSheng > nNowShengWang) then
			nNowShengWang = nBounsSheng;
		end
		local nCamp			= tbBattleInfo.tbCamp.nCampId;
		tbBattleInfo.nShengWang 	= tbBattleInfo.nShengWang + nNowShengWang;
		tbBattleInfo.pPlayer.Msg(string.format("Xếp hạng: <color=green>%d<color>, bạn nhận được <color=white>%d<color> điểm danh vọng chiến trường.", i, tbBattleInfo.nShengWang));
	end
end

-- 战局结束时的声望按排名奖励
function Battle:AwardFinalHonor(tbPlayerList)
	local nNowHonor = 0;
	local nMaxRank		= 0;
	local nIndex		= 0;
	for i = 1, #tbPlayerList do
		local tbBattleInfo 	= tbPlayerList[i];
		local nNowHonor	= 0;
		local nRankHonor	= 0;
		local nBounsHonor	= 0;
		if (1 == i) then
			nRankHonor = Battle.tbRANKHONOR[1];
		elseif (2 <= i and 5 >= i) then
			nRankHonor = Battle.tbRANKHONOR[2];
		elseif (6 <= i and 10 >= i) then
			nRankHonor = Battle.tbRANKHONOR[3];
		elseif (11 <= i and 20 >= i) then
			nRankHonor = Battle.tbRANKHONOR[4];
		end
		
		for key, tbRankBouns in ipairs(Battle.tbBOUNSHONOR) do
			if (tbBattleInfo.nBouns >= tbRankBouns[1]) then
				nBounsHonor = tbRankBouns[2];
				break;
			end
		end
		nNowHonor = nRankHonor;
		if (nBounsHonor > nNowHonor) then
			nNowHonor = nBounsHonor;
		end
		local nCamp			= tbBattleInfo.tbCamp.nCampId;
		tbBattleInfo.nHonor = tbBattleInfo.nHonor + nNowHonor;
		tbBattleInfo.pPlayer.Msg(string.format("Xếp hạng: <color=green>%d<color>, nhận được <color=white>%d<color> danh vọng chiến trường.", i, tbBattleInfo.nHonor));
	end
end

-- 战局结束时的功勋按排名奖励
function Battle:AwardFinalGongXun(tbPlayerList)
--	local nNowGongXun 	= 0;
--	local nMaxRank		= 0;
--	local nIndex		= 0;
--	for i = 1, #tbPlayerList do
--		if (i > nMaxRank) then
--			nIndex = nIndex + 1;
--			if (not self.tbGONGXUNRANK[nIndex]) then
--		--		print("self.tbSHENGWANGRANK[nIndex] error (Battle:AwardFinalGongXun(tbPlayerList, tbBattleAwardSheng))");
--			end
--			nMaxRank		= self.tbGONGXUNRANK[nIndex][1];
--			nNowGongXun		= self.tbGONGXUNRANK[nIndex][2];
--		end
--		local tbBattleInfo 	= tbPlayerList[i];
--		local nGongXun 		= tbBattleInfo.nGongXun + nNowGongXun;
--		local nCamp			= tbBattleInfo.tbCamp.nCampId;
--		tbBattleInfo.pPlayer.Msg(string.format("排名为：<color=green>%d<color>，你获得了<color=white>%d<color>点战场功勋值奖励。", i, nGongXun));
--		tbBattleInfo.nGongXun = nGongXun;
--	end
end

function Battle:AwardFinalWeiWang(tbPlayerList, nBattleLevel)
	if (not tbPlayerList) then
		return;
	end
	local nFlag = 0;
	local nOpenTime = KGblTask.SCGetDbTaskInt(DBTASD_SERVER_SETMAXLEVEL99);
	if (nOpenTime <= 0) then
		nFlag = 1;
	else
		if (nBattleLevel >= 2) then
			nFlag = 1;
		end
	end
	for i, v in ipairs(tbPlayerList) do
		if (self.tbWeiWangRank[1] == i) then
			self:AwardWeiWang(v, 10, 50);	-- 冠军有6点威望
		elseif (self.tbWeiWangRank[1] < i and self.tbWeiWangRank[2] >= i) then
			self:AwardWeiWang(v, 8, 40);
		elseif (i > self.tbWeiWangRank[2] and self.tbWeiWangRank[3] >= i) then
			self:AwardWeiWang(v, 6, 30);
		else
			if (nFlag == 1) then
				local nBouns = v.nBouns;
				if (4500 <= nBouns) then
					self:AwardWeiWang(v, 5, 20, 1);
				elseif (3000 <= nBouns) then
					self:AwardWeiWang(v, 4, 20, 1);
				elseif (1800 <= nBouns) then
					self:AwardWeiWang(v, 3, 15, 1);
				elseif (1500 <= nBouns) then
					self:AwardWeiWang(v, 2, 15, 1);
				elseif (1200 <= nBouns) then
					self:AwardWeiWang(v, 2, 10, 1);
				elseif (800 <= nBouns) then
					self:AwardWeiWang(v, 1, 10, 1);
				elseif (500 <= nBouns) then
					self:AwardWeiWang(v, 0, 10, 1);
				end			
			end
		end
	end
end

function Battle:AwardFinalOffer(tbPlayerList, nBattleLevel)
	if (not tbPlayerList) then
		return;
	end 
	local nStockBaseCount = 0;
	for i, v in ipairs(tbPlayerList) do
		if (i >= 1 and i <= 3) then
			self:AwardOffer(v, 150);	-- 前3名有150的贡献度
			nStockBaseCount = 100;
		elseif (4 <= i and 10 >= i) then
			self:AwardOffer(v, 120);	-- 前10名有120的贡献度
			nStockBaseCount = 80;
		elseif (i >= 10 and 20 >= i) then
			self:AwardOffer(v, 100);	-- 前20名有100的贡献度
			nStockBaseCount = 60;
		else
			local nBouns = v.nBouns;
			if (5000 <= nBouns) then
				self:AwardOffer(v, 80); -- 5000积分以上的有80的贡献度
				nStockBaseCount = 50;
			elseif (5000 > nBouns and 4000 <= nBouns) then
				self:AwardOffer(v, 60); -- 4000积分以上的有60的贡献度
				nStockBaseCount = 30;
			elseif (4000 > nBouns and 3000 <= nBouns) then
				self:AwardOffer(v, 40);	-- 3000积分以上的有40的贡献度
				nStockBaseCount = 20;
			elseif (3000 > nBouns and 1500 <= nBouns) then
				self:AwardOffer(v, 30);	-- 1500积分以上的有30的贡献度
				nStockBaseCount = 10;
			end
		end
		
		if (i > 0 and i <= 20 and nBattleLevel == 3) then
			-- 成就：高级战场前20名
			Achievement_ST:FinishAchievement(v.pPlayer.nId, Achievement_ST.BATTLE_GAOJI_20);
		end
	end
end

function Battle:AwardOffer(tbBattleInfo, nOffer)
	local pPlayer = tbBattleInfo.pPlayer;
	if (not pPlayer) then
		return 0;
	end
end

function Battle:AwardWeiWang(tbBattleInfo, nWeiWang, nGongXian, nFlag)
	local pPlayer = tbBattleInfo.pPlayer;
	if (not pPlayer) then
		return 0;
	end
	
	if TimeFrame:GetState("Keyimen") == 1 and nWeiWang > 0 then
		Item:ActiveDragonBall(pPlayer);
	end
	
	-- 加入帮会，并且帮会通过考验期 by zhangjinpin@kingsoft
	if nFlag == 1 then
		if not pPlayer.dwTongId or pPlayer.dwTongId == 0 then
			return 0;
		end
	
		local pTong = KTong.GetTong(pPlayer.dwTongId);
		if not pTong or pTong.GetTestState() ~= 0 then
			return 0;
		end
	end
	-- end

	if tbBattleInfo.tbMission and tbBattleInfo.tbMission.nBattleLevel then
		if tbBattleInfo.tbMission.nBattleLevel == 1 and TimeFrame:GetStateGS("OpenOneFengXiangBattle") == 1 then
			nWeiWang = math.floor(nWeiWang / 2);
		end
		pPlayer.AddKinReputeEntry(nWeiWang, "battle");
	end
end

function Battle:AwardFinalXinDe(tbPlayerList)
	if (not tbPlayerList) then
		return;
	end
	for i = 1, #tbPlayerList do
		if (1 == i) then
			self:AwardXinDe(tbPlayerList[i].pPlayer, 300000);	-- 冠军由6点威望
		elseif (2 <= i and 10 >= i) then
			self:AwardXinDe(tbPlayerList[i].pPlayer, 200000);
		else
			local nBouns = tbPlayerList[i].nBouns;
			if (3000 < nBouns) then
				self:AwardXinDe(tbPlayerList[i].pPlayer, 150000);
			elseif (3000 >= nBouns and 500 <= nBouns) then
				self:AwardXinDe(tbPlayerList[i].pPlayer, 100000);
			end
		end
	end	
end

function Battle:AwardXinDe(pPlayer, nXinDe)
	if (nXinDe <= 0) then
		return;
	end
	Setting:SetGlobalObj(pPlayer);
	Task:AddInsight(nXinDe);
	Setting:RestoreGlobalObj();
end

function Battle:AwardFinalBouns(tbPlayerList, nBattleLevel)
	if (not tbPlayerList) then
		return;
	end

	local nNowTimes 	= 0;
	local nMaxRank		= 0;
	local nIndex		= 0;
	for i = 1, #tbPlayerList do
		if (i > nMaxRank) then
			nIndex = nIndex + 1;
			if (not self.tbBOUNSTIMESRANK[nIndex]) then
				print("self.tbBOUNSTIMESRANK[nIndex] error (Battle:AwardFinalBouns(tbPlayerList))");
			end
			nMaxRank		= self.tbBOUNSTIMESRANK[nIndex][1];
			nNowTimes		= self.tbBOUNSTIMESRANK[nIndex][2];
		end
		local tbBattleInfo 	= tbPlayerList[i];
		local nOrgBouns = tbBattleInfo.pPlayer.GetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_BOUNS_TOTAL_WEEK);
		local nNowBouns = tbBattleInfo.nBouns * nNowTimes + nOrgBouns;
		tbBattleInfo.pPlayer.SetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_BOUNS_TOTAL_WEEK, nNowBouns);
		local nCurMax = KGblTask.SCGetDbTaskInt(Battle.DBTASK_SONGJIN_BOUNS_MAX);
		if (nCurMax < nNowBouns) then
			KGblTask.SCSetDbTaskStr(Battle.DBTASK_SONGJIN_BOUNS_MAX, tbBattleInfo.pPlayer.szName);
			KGblTask.SCSetDbTaskInt(Battle.DBTASK_SONGJIN_BOUNS_MAX, nNowBouns);	
		end
		local nNowBouns = nOrgBouns * nNowTimes;
		if (EventManager.IVER_bOpenTiFu == 1) then
			tbBattleInfo.pPlayer.SetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_BOUNS_TOTALBOUNS_AWARD, tbBattleInfo.nBouns * nNowTimes);
		end
		tbBattleInfo.pPlayer.SetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_TOTALBOUNS, 0);

		tbBattleInfo.pPlayer.Msg(string.format("Xếp hạng: <color=green>%d<color>, nhận được <color=white>%s<color> điểm phần thưởng.", i, nNowTimes));
	end
end

if (EventManager.IVER_bOpenTiFu == 1) then
	--体服，获得10W银和七玄
	function Battle:Award_TestServer(pPlayer)
		if pPlayer then
			local pItem = pPlayer.AddItem(18,1,1,7);
			if pItem then
				pItem.Bind(1);
			end
			pPlayer.Earn(100000, Player.emKEARN_EVENT);
		end
	end
end

-- 奖励积分大于3000的玩家可以获得物质奖励
function Battle:AwardFinalGoods(tbPlayerList, nBattleLevel)
	if (not tbPlayerList) then
		return;
	end
	
	local nItemId = self.tbPaiItemId[nBattleLevel];
	for i = 1, #tbPlayerList do
		local nBouns	= tbPlayerList[i].nBouns;
		local pPlayer	= tbPlayerList[i].pPlayer;
		if (self.tbAWARDBOUNS[1] <= nBouns) then
			pPlayer.SetTask(self.TSKGID, self.TSK_BTPLAYER_ZHANCHANGLINGPAI, nItemId);
			pPlayer.SetTask(self.TSKGID, self.TSK_BTPLAYER_FUDAI ,2);
			Dialog:SendInfoBoardMsg(pPlayer, "Gặp Hiệu Úy Mộ Binh ở Báo danh chiến trường nhận thưởng.");
		elseif (self.tbAWARDBOUNS[2] <= nBouns) then
			pPlayer.SetTask(self.TSKGID, self.TSK_BTPLAYER_FUDAI ,1);
			Dialog:SendInfoBoardMsg(pPlayer, "Gặp Hiệu Úy Mộ Binh ở Báo danh chiến trường nhận thưởng.");
		end
		if (nBouns > 0) then
			pPlayer.SetTask(self.TSKGID, self.TSK_BTPLAYER_BOUNSFORWARD, 1);
		end
	end	
end

-- 奖励真元经验，只有主真元才能添加经验
function Battle:AwardZhenYuanExp(tbPlayerList)
	if not tbPlayerList then
		return;
	end
	
	local nLastAwardRank = 1;
	for i = 1, #tbPlayerList do
		local pPlayer	= tbPlayerList[i].pPlayer;
		local pZhenYuan = pPlayer.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_ZHENYUAN_MAIN, 0);
		
		local nExpAdded = 0;
		if i == 1 then
			nExpAdded = self.tbZhenYuanExpAward[1];
		elseif i <= 3 then
			nExpAdded = self.tbZhenYuanExpAward[3];
		elseif i <= 10 then
			nExpAdded = self.tbZhenYuanExpAward[10];
		elseif i <=20 then
			nExpAdded = self.tbZhenYuanExpAward[20];
		end		

		-- 超过名次了就不用再循环了
		if nExpAdded == 0 then
			break;
		end		
		
		-- pZhenYuan可以为nil,表示全部要累积
		Item.tbZhenYuan:AddExp(pZhenYuan, nExpAdded, Item.tbZhenYuan.EXPWAY_BATTLE, pPlayer);		
	end
end

-- 师徒成就：战场
function Battle:GetAchievement(tbPlayerList, nBattleLevel)
	if (not tbPlayerList) then
		return;
	end
	-- nBattleLevel = 1（初级 扬州），2（中级 凤翔），3（高级 襄阳）
	for i = 1, #tbPlayerList do
		local pPlayer = tbPlayerList[i].pPlayer;
		-- 目前成就系统里面只需要添加扬州战场成就，如果以后要添加其他的，可以在这里补充
		if (pPlayer and nBattleLevel == 1) then
			Achievement_ST:FinishAchievement(pPlayer.nId, Achievement_ST.BATTLE_YANGZHOU);
		end
	end
end

-- 获得一个战场令牌
function Battle:AwardGood(pPlayer, nItemId, nPaiCount, nFuCount, nBouns, nBattleLevel)
	local nFreeCount, tbExecute = SpecialEvent.ExtendAward:DoCheck("Battle", pPlayer, nBouns, nBattleLevel);
	
	if (pPlayer.CountFreeBagCell() < (nPaiCount + nFuCount + nFreeCount) * Battle.nTimes ) then
		return 0;
	end
	for i = 1, Battle.nTimes do
		if (nPaiCount > 0) then
			pPlayer.AddItem(18,1,112,nItemId);
			self:WriteLog("AwardGood", string.format("Give player %s a zhanchanglingpai", pPlayer.szName));
			pPlayer.SetTask(self.TSKGID, self.TSK_BTPLAYER_ZHANCHANGLINGPAI, 0);
		end
		if (nFuCount > 0) then
			for i=1, nFuCount do
				local pItem = pPlayer.AddItem(18,1,734,1);
				assert(pItem);
				self:WriteLog("AwardGood", string.format("Give player %s a fudai", pPlayer.szName));
				--local szDate = os.date("%Y/%m/%d/%H/%M/%S", GetTime() + 3600 * 48);
				--pPlayer.SetItemTimeout(pItem, szDate);
				--pItem.Sync();
			end
			pPlayer.SetTask(self.TSKGID, self.TSK_BTPLAYER_FUDAI, 0);
		end
		if (nBouns > 0) then
			local nMyUserBouns		= self:GetMyUseBouns();
			local nFinalBouns		= nBouns;
			if (nMyUserBouns + nBouns > self.BATTLES_POINT2EXP_MAXEXP) then
				nFinalBouns = self.BATTLES_POINT2EXP_MAXEXP - nMyUserBouns;
			end
			local nExp 				= self:BounsChangeExp(pPlayer.nLevel, nFinalBouns) * self.BOUNS2EXPMUL;
			if (nExp > 0) then
				pPlayer.AddExp2(nExp,"battle"); -- mod zounan 修改经验接口
			end
			self:AddUseBouns(pPlayer, nFinalBouns, nMyUserBouns);
			pPlayer.SetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_TOTALBOUNS, 0);
		end
		SpecialEvent.ExtendAward:DoExecute(tbExecute);
	end
	return 1;
end

function Battle:WeekBounsChangeExp(pPlayer, nBouns)
	if (nBouns <= 0) then
		return 0;
	end
	local nMyUserBouns	= pPlayer.GetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_BOUNS_TOTAL_USE_WEEK);
	local nFinalBouns	= nBouns;
	if (nMyUserBouns + nBouns > self.BATTLES_POINT2EXP_MAXEXP) then
		nFinalBouns = self.BATTLES_POINT2EXP_MAXEXP - nMyUserBouns;
	end
	local nExp 				= self:BounsChangeExp(pPlayer.nLevel, nFinalBouns) * self.BOUNS2EXPMUL;
	if (nExp > 0) then
		pPlayer.AddExp2(nExp,"battle"); -- mod zounan 修改经验接口
	end
	nMyUserBouns = nMyUserBouns + nFinalBouns;
	pPlayer.SetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_BOUNS_TOTAL_USE_WEEK, nMyUserBouns);
	Battle:RefreshBattleWeekBouns(pPlayer);
end

-- 更新每天玩家最大功勋值
function Battle:UpdatePlayerHonorAndShengWang(tbPlayerList)
	for _, tbBattleInfo in pairs(tbPlayerList) do
		tbBattleInfo:SetPlayerHonor();
		tbBattleInfo:SetPlayerShengWang();
	end
end

-- 如果玩家的身份是未出师弟子，那么他的师徒任务当中的宋金战场次数加1
function Battle:UpdateShiTuBattleCount(tbPlayerList, bNewBattle)
	if (not tbPlayerList) then
		return;
	end
	local tbItem = Item:GetClass("teacher2student");
	for i, v in ipairs(tbPlayerList) do
		local pPlayer = v.pPlayer;
		if (pPlayer) then
			if (pPlayer.GetTrainingTeacher()) then
				local nEnterBattleTime = 0;
				if bNewBattle == 1 then
					nEnterBattleTime = v.nEnterBattleTime;
				else
					local tbBattleInfo	= Battle:GetPlayerData(pPlayer);
					nEnterBattleTime = tbBattleInfo.nEnterBattleTime;
				end
				local nCurTime = GetTime();
				local nInBattleTime = nCurTime - nEnterBattleTime;
				if (tbItem.BATTLE_VALID_TIME <= nInBattleTime) then
					local nNeed_Battle = pPlayer.GetTask(Relation.TASK_GROUP, Relation.TASK_ID_SHITU_BATTLE) + 1;
					pPlayer.SetTask(Relation.TASK_GROUP, Relation.TASK_ID_SHITU_BATTLE, nNeed_Battle);
				end
			end
		end
	end
end

-- 计算离上次更新时间过了多少天
function Battle:CalculateDay(nLastTime, nNowTime)
	local nLastDay 	= math.ceil(nLastTime / (3600 * 24));
	local nNowDay	= math.ceil(nNowTime / (3600 * 24));
	local nDays		= nNowDay - nLastDay;
	if (nDays < 0) then
		nDays = 0;
	end
	return nDays;
end

-- 清零
function Battle:ClearBouns(pPlayer)
	self:SetTotalBouns(pPlayer, 0);
end

-- 个人玩家奖励
function Battle:AwardPlayerList(tbPlayerReaultList, nBattleLevel, bNewBattle)
	self:AwardFinalHonor(tbPlayerReaultList);
	self:AwardFinalShengWang(tbPlayerReaultList);
	self:UpdatePlayerHonorAndShengWang(tbPlayerReaultList);
	self:UpdateShiTuBattleCount(tbPlayerReaultList, bNewBattle);
	self:AwardFinalWeiWang(tbPlayerReaultList, nBattleLevel);
	self:AwardFinalOffer(tbPlayerReaultList, nBattleLevel);
	self:AwardFinalXinDe(tbPlayerReaultList);
	self:AwardFinalGoods(tbPlayerReaultList, nBattleLevel);
	self:GetAchievement(tbPlayerReaultList, nBattleLevel);
	-- if (EventManager.IVER_bOpenTiFu == 1) then
		self:TiFuFinalAward(tbPlayerReaultList, nBattleLevel);
	-- end
	self:AwardZhenYuanExp(tbPlayerReaultList);		-- 添加真元经验
	--self:AwardFinalBouns(tbPlayerReaultList);
	self:_WriteBattleRankLog(tbPlayerReaultList, bNewBattle);
end

function Battle:_WriteBattleRankLog(tbPlayerList, bNewBattle)
	local nTime = GetTime();
	local szLog = "";
	local nFirst = 0;
	local tbTotalLogItem = {};
	local nTotalBouns = 0;
	for i = 1, #tbPlayerList do
		local tbBattleInfo = tbPlayerList[i];
		if (tbBattleInfo) then
			local szExMsg = "";
			if (nFirst > 0) then
				local szTime = os.date("[%Y-%m-%d %H:%M:%S]", nTime);
				szExMsg = szTime .. "\tINFO\t[BattleLog]\tBattleRank\t";
			end
			nFirst = 1;
			local nHonorLevel = tbBattleInfo.pPlayer.GetHonorLevel();
			local szItem = "";
			for szName, nNum in pairs(tbBattleInfo.tbLogData) do
				szItem = szItem .. "," .. szName..":"..nNum;
				if (not tbTotalLogItem[szName]) then
					tbTotalLogItem[szName] = 0;
				end
				tbTotalLogItem[szName] = tbTotalLogItem[szName] + nNum;
			end

			szItem = nHonorLevel .. szItem;
			if bNewBattle == 1 then
				nTotalBouns = tbBattleInfo.nKillPlayerBouns;
				szExMsg = szExMsg .. string.format("%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n", tbBattleInfo.tbMission.nSeqNum, tbBattleInfo.tbMission.nSeqNum, tbBattleInfo.tbMission.nLevel, tbBattleInfo.tbMission.szBattleName, tbBattleInfo.pPlayer.szName, i, tbBattleInfo.szFacName, tbBattleInfo:GetKinTongName(), tbBattleInfo.nKillPlayerNum, tbBattleInfo.nMaxSeriesKillNum, tbBattleInfo:KillNpcNum(), tbBattleInfo.nBouns, szItem);
			else
				nTotalBouns = tbBattleInfo.tbMission.nLog_KillBouns;
				szExMsg = szExMsg .. string.format("%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n", tbBattleInfo.tbMission.nSeqNum, tbBattleInfo.tbMission.nBattleSeq, tbBattleInfo.tbMission.nBattleLevel, tbBattleInfo.tbMission.szBattleName, tbBattleInfo.pPlayer.szName, i, tbBattleInfo.szFacName, tbBattleInfo:GetKinTongName(), tbBattleInfo.nKillPlayerNum, tbBattleInfo.nMaxSeriesKillNum, tbBattleInfo.nKillNpcNum, tbBattleInfo.nBouns, szItem);
			end			
			szLog = szLog .. szExMsg;
			if (math.fmod(i,10) == 0) then
				Dbg:WriteLogEx(Dbg.LOG_INFO, "BattleLog", "BattleRank", szLog);
				szLog = "";
				nFirst = 0;
			end
		end
	end
	if (nFirst > 0) then
		Dbg:WriteLogEx(Dbg.LOG_INFO, "BattleLog", "BattleRank", szLog);
	end
	
	local szMsg = "";
	for	szName, nNum in pairs(tbTotalLogItem) do
		szMsg = szMsg .. szName .. ": " .. nNum .. ",";
	end
	local nTotalPlayer = 0;
	if (tbPlayerList) then
		nTotalPlayer = #tbPlayerList;
	end
	szMsg = szMsg .. "nTotalPlayer: " .. nTotalPlayer .. " , " .. "nTotalKillBouns: " .. nTotalBouns;
	Dbg:WriteLogEx(Dbg.LOG_INFO, "BattleLog", "ItemTotalDropNum", szMsg);
end

function Battle:ProcessAchievement(tbPlayerReaultList, nWinCampId, nRuleType)
	for i = 1, #tbPlayerReaultList do
		local tbBattleInfo 	= tbPlayerReaultList[i];
		local nCampId = tbBattleInfo.tbCamp.nCampId;
		Achievement:FinishAchievement(tbBattleInfo.pPlayer, self.ACHIEVEMENT_ID_FIGHT_FOR_CAMP[nCampId]);
		Achievement:FinishAchievement(tbBattleInfo.pPlayer, self.ACHIEVEMENT_ID_MODE[nRuleType]);
		for _, nId in pairs(self.ACHIEVEMENT_ID_JOIN_SONGJINBATTLE) do
			Achievement:FinishAchievement(tbBattleInfo.pPlayer, nId);
		end
		if (nWinCampId == nCampId) then
			Achievement:FinishAchievement(tbBattleInfo.pPlayer, self.ACHIEVEMENT_ID_FIGHT_WIN);
			Achievement:FinishAchievement(tbBattleInfo.pPlayer, self.ACHIEVEMENT_ID_JOIN_SONGJINBATTLE_WIN);
		end
		
		if (1 == i) then
			Achievement:FinishAchievement(tbBattleInfo.pPlayer, self.ACHIEVEMENT_ID_PLAYER_FIRST_RANK);
		end
		
		for nRank, nId in pairs(self.ACHIEVEMENT_ID_FINAL_LIST) do
			if (i <= nRank) then
				Achievement:FinishAchievement(tbBattleInfo.pPlayer, nId);
			end
		end
	end
end

function Battle:_BTPrint(tbPlayerReaultList)
	print("szName, nBouns, nGongXun, nShengWang");
	for _, tbBattleInfo in ipairs(tbPlayerReaultList) do
		print(tbBattleInfo.pPlayer.szName, tbBattleInfo.nBouns, tbBattleInfo.nGongXun, tbBattleInfo.nShengWang);
	end
end

-- 累加积分--TODO
function Battle:AddUseBouns(pPlayer, nChangeBouns, nMyUserBouns)
	if (0 == nChangeBouns) then
		return;
	end
	pPlayer.SetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_USEBOUNS, nChangeBouns + nMyUserBouns);
end

-- 获得已用积分记录--TODO
function Battle:GetMyUseBouns()
	local nMyBouns = me.GetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_USEBOUNS);
	return nMyBouns;
end

function Battle:AddShareBouns(tbBattleInfo, nBouns)
	local tbShareTeamMember = tbBattleInfo.pPlayer.GetTeamMemberList(1);
	if (not tbShareTeamMember) then
		return tbBattleInfo:AddBounsWithCamp(nBouns);
	end
	
	local nResult	= 0;	
	local nCount	= #tbShareTeamMember;
	if (0 < nCount) then
		local nTimes	= self.tbPOINT_TIMES_SHARETEAM[nCount];
		local nPoints	= nBouns * nTimes;
		nResult			= tbBattleInfo:AddBounsWithCamp(nPoints);
	end

-- 组队共享暂时不用
--	for _, pPlayer in pairs(tbShareTeamMember) do
--		if (pPlayer.nId ~= tbBattleInfo.pPlayer.nId) then
--			local nFaction, nRoutId = self:GetFactionNumber(pPlayer);
--			if (0 ~= nFaction) then
--				local nTimes	= self.tbPOINT_TIMES_SHAREFACTION[nFaction][nRoutId];
--				local nPoints	= nBouns * nTimes;
--				self:GetPlayerData(pPlayer):AddBounsWithCamp(nPoints);
--			end
--		end
--	end
	return nResult;
end

function Battle:GetFactionNumber(pPlayer)
	local nFaction 	= pPlayer.nFaction;
	if (0 == nFaction) then
		Battle:DbgOut("GetFactionNumber", pPlayer.szName, "Chưa gia nhập môn phái!");
		return 0;
	end
	local nRouteId	= pPlayer.nRouteId;
	if (0 == nRouteId) then
		Battle:DbgOut("GetFactionNumber", pPlayer.szName, "Chưa chọn nhánh, không thể nhận Mật tịch môn phái!");
		return 0;
	end
	return nFaction, nRouteId;
end

function Battle:OnWeekEvent_ResetBattleHonor()
	-- TODO 排名
	local pPlayer = me;
	for i = self.TSK_BTPLAYER_HONOR1, self.TSK_BTPLAYER_HONOR4, 1 do
		pPlayer.SetTask(self.TSKGID, i, 0);
	end
end

function Battle:GetRemainJunXu()
	local nRemainJunXu = me.GetTask(self.TSKGID, self.TSK_BTPLAYER_JUNXU);
	return nRemainJunXu;
end

function Battle:RefreshBattleWeekBouns(pPlayer)
	local nNowWeekBouns = pPlayer.GetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_BOUNS_TOTAL_WEEK);
	local nUseWeekBouns	= pPlayer.GetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_BOUNS_TOTAL_USE_WEEK);
	local nNowTime = GetTime()
	local nLastReWeek = Lib:GetLocalWeek(pPlayer.GetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_BOUNS_TOTAL_RETIME));
	local nNowWeek = Lib:GetLocalWeek(nNowTime);

	if (nNowWeek == nLastReWeek) then
		return 0;
	end
	
	if (nNowWeekBouns - nUseWeekBouns > 0) then
		return 1;
	end
	
	pPlayer.SetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_BOUNS_TOTAL_WEEK, 0);
	pPlayer.SetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_BOUNS_TOTAL_USE_WEEK, 0);
	pPlayer.SetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_BOUNS_TOTAL_RETIME, GetTime());
	return 0;
end


PlayerSchemeEvent:RegisterGlobalWeekEvent({Battle.OnWeekEvent_ResetUseBouns, Battle});
PlayerSchemeEvent:RegisterGlobalWeekEvent({Battle.OnWeekEvent_ResetBattleHonor, Battle});

-- 为体服添加获取特定奖励的接口
function Battle:TiFuFinalAward(tbPlayerList, nBattleLevel)
	local nAwardLevel = 1;   -- 奖励等级从1级开始	

	for i = 1, #tbPlayerList do
		local tbBattleInfo 	= tbPlayerList[i];
		local pPlayer = tbBattleInfo.pPlayer;
				
		local nRet = 1;
		nRet, nAwardLevel = self:CanGetTiFuAward(i, nAwardLevel, tbBattleInfo);
		if nRet == 0 then
			break;
		end
		
		local nCurRank = self.tbAwardCondition[nAwardLevel] or -1;  -- 当前奖励名次在nCurRank以内的玩家
		
		-- 获取到的奖励情况
		local nMoney = self.tbTiFuAwardList[nCurRank]["money"];
		local tbXuanjing = self.tbTiFuAwardList[nCurRank]["xuanjing"];
		local nZhenYuanTime = self.tbTiFuAwardList[nCurRank]["zhenyuanexp"] or 0;
		local nXuanJing = 0;

		local szMsg = "";
		if nCurRank == -1 then	-- 得的是积分上限奖励
			szMsg = szMsg..string.format("Điểm thưởng: nhận được <color=green>%d<color>", tbBattleInfo.nBouns);
		else		-- 得的是排名奖励
			szMsg = szMsg..string.format("Xếp hạng: <color=green>%d<color>, nhận được ", i);
		end
		for nLevel, nCount in pairs(tbXuanjing) do
			nXuanJing = nXuanJing * 1000 + nLevel * 10 + nCount
			local szName = KItem.GetNameById(18, 1, 1, nLevel);
			szMsg = szMsg..string.format("%d %s，", nCount, szName);
		end
		szMsg = szMsg..string.format("%d bạc khóa, %d thời gian tu luyện Chân Nguyên. Đến Hiệu Úy Mộ Binh để nhận thưởng.", nMoney, nZhenYuanTime);
		pPlayer.Msg(szMsg);
		
		pPlayer.SetTask(self.TSKGID, self.TSK_BTPLAYER_AWARDRANK, nCurRank);
	end
end

function Battle:CanGetTiFuAward(nRank, nAwardLevel, tbBattleInfo)
	 -- 当前奖励名次在nCurRank以内的玩家
	local nCurAwardRank = self.tbAwardCondition[nAwardLevel] or -1;	
	
	-- 如果不能拿到名次奖励了，看能不能拿到积分上限奖励
	if nCurAwardRank == -1 then
		-- 不能领到积分上限奖励，循环也不用再做了，退出
		if tbBattleInfo.nBouns < self.AWARDBONUS_LEAST then
			-- 如果这位已经领不到奖了，那他以后的更不可能领到奖了，break掉
			return 0;
		end	
	else		-- 领取名次奖励
		if nRank > nCurAwardRank then  -- 当前名次超过了可以领取对应奖励的等级，看能不能领取下一奖励等级的奖励
			return self:CanGetTiFuAward(nRank, nAwardLevel + 1, tbBattleInfo);
		end 
	end
	
	return 1, nAwardLevel;
end
