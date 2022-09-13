-- 文件名　：newbattle_cpalyer.lua
-- 创建者　：LQY
-- 创建时间：2012-07-19 16:53:36
-- 说　　明：存储Player所有数据的类

local tbPLBase	= NewBattle.tbPlayerBase or {};
NewBattle.tbPlayerBase = tbPLBase;
function tbPLBase:init(nPlayerId, nGounpId, tbMission)
	self.nPlayerId			= nPlayerId;
	self.nGounpId           = nGounpId;
	self.nSeriesKillNum		= 0;			-- 连斩数
	self.nMaxSeriesKillNum	= 0;			-- 最大连斩数
	self.nTransferCD		= 0;			-- 个人传送CD
	self.nBouns				= 0;			-- 战局积分
	self.nKillPlayerNum		= 0;			-- 杀死玩家个数
	self.nKillPlayerBouns	= 0;			-- 杀敌玩家积分
	self.nBeenKilledNum		= 0;			-- 被杀数
	self.nRank				= 1;			-- 排名
	self.nTitle				= 1;			-- 官衔
	self.bFristBlood		= 0;			-- 一血
	self.nAlreadyAddCount 	= 0;			-- 是否已增加本日宋金数量
	self.nShengWang			= 0;			-- 声望
	self.nHonor				= 0;			-- 荣誉
	self.tbLogData		= {};
	
	-- 为了和老宋金奖励对接添加的属性
	self.pPlayer			= KPlayer.GetPlayerObjById(nPlayerId);
	self.tbCamp				= {};
	self.tbCamp.nCampId		= nGounpId;
	self.nEnterBattleTime	= GetTime();
	self.tbMission			= tbMission;
	self.szFacName			= Player:GetFactionRouteName(self.pPlayer.nFaction, self.pPlayer.nRouteId);	-- 玩家门派名称
	
	self.tbKillNum 			=				-- 摧毁数量
	{
		["ZHANCHE"]		=	0,
		["JIANTA"] 		= 	0,
		["PAOTAI"]		=	0,
		["SHOUHUZHE"]	=	0,
		["LONGMAI"]	 	= 	0,
		["JUNDUI"]		= 	0,
	};
	self.tbKillPoint 		=				--摧毁得分
	{
		["ZHANCHE"]		=	0,
		["JIANTA"] 		= 	0,
		["PAOTAI"]		=	0,
		["SHOUHUZHE"]	=	0,
		["LONGMAI"]	 	= 	0,
	};
	self.tbDefPoint 	=					--守护得分
	{
		["PAOTAI"]		=	0,
		["SHOUHUZHE"]	=	0,
		["LONGMAI"]		=	0,
	};
	self.nTimeDeath         = nTimeDeath or 0;
end

--能否使用召唤石
function tbPLBase:CanUseStone()
	local nPass = Lib:GetLocalDayTime() - self.nTransferCD;
	if nPass >= NewBattle.PLAYERTRANSFERCD  then
		self.nTransferCD = Lib:GetLocalDayTime();
		return 1;
	end
	return 0, NewBattle.PLAYERTRANSFERCD - nPass;
end

--获取pPlayer
function tbPLBase:GetPlayer()
	local pPlayer = KPlayer.GetPlayerObjById(self.nPlayerId);
	return pPlayer and pPlayer or nil;
end

-- 玩家被杀
function tbPLBase:AddBeenKill(tbKillers, bCarrie)

	self.nBeenKilledNum = self.nBeenKilledNum + 1;

	--是被玩家杀的
	if tbKillers then
		local szKillName = "";
		for _,tbKiller in pairs(tbKillers) do
			szKillName = szKillName..tbKiller:GetPlayer().szName.." %s ";
		end
		if(#tbKillers == 1) then
			szKillName = string.format(szKillName, "");
		else
			szKillName = string.format(szKillName, "và","Chiến Xa");
		end
		local pPlayerme = self:GetPlayer();
		if bCarrie and pPlayerme then
			NewBattle:SendMsg2Player(pPlayerme,"Bạn bị <color=yellow>"..szKillName.."<color> đánh trọng thương!", 1);
		end
		for _,tbKiller in pairs(tbKillers) do
			if bCarrie then
				local pKiller = tbKiller:GetPlayer();
				if pKiller then
					NewBattle:SendMsg2Player(pKiller,"<color=yellow>"..pPlayerme.szName.."<color> bị bạn đánh trọng thương!", 1);
				end
			end
			if self.nSeriesKillNum >= NewBattle.SERIESPK_NAME[1][1] then
				local pPlayerme = self:GetPlayer();
				if pPlayerme then
					local szMsg = string.format("<color=yellow>%s<color> hạ gục <color=yellow>%s<color> hoàn thành <color=white>%d<color> liên trảm, đạt  <color=yellow><bclr=red>[%s]<bclr><color>!", szKillName, pPlayerme.szName, self.nSeriesKillNum, NewBattle:GetSeriesPkName(self.nSeriesKillNum));
					NewBattle.Mission:BroadCastMission(szMsg,NewBattle.SYSTEMRED_MSG,0);
				end

			end
			--一血处理
			if not NewBattle.Mission.bFristBlood or NewBattle.Mission.bFristBlood == 0 then
				local pPlayerme = self:GetPlayer();
				if pPlayerme then
					local szMsg = string.format("<color=yellow>%s<color> hạ gục <color=yellow>%s<color> nhận được <color=yellow><bclr=red>Chiến Công Đầu<bclr><color>!",szKillName,pPlayerme.szName);
					NewBattle.Mission:BroadCastMission(szMsg,NewBattle.SYSTEMRED_MSG,0);
					--记录首杀者ID
					NewBattle.Mission.bFristBlood = 1;
					for _,tbKiller in pairs(tbKillers) do
						tbKiller.bFristBlood = 1;
						tbKiller:AddPoint(NewBattle.FRISTBLOODPOINT, "Bạn nhận được <color=yellow>[Chiến Công Đầu]<color> tích lũy tăng <color=yellow>%d<color> điểm!");						
					end
				end
			end
			tbKiller:AddKill(self);
		end
	end

	--连斩数清零
	self.nSeriesKillNum = 0;
end

--玩家杀人
function tbPLBase:AddKill(tbBeKill)
	self.nKillPlayerNum = self.nKillPlayerNum + 1;
	self.nKillPlayerBouns = self.nKillPlayerBouns + 1;
	self:SeriesKill();
	self:AddKillPoint(tbBeKill);	
end

--玩家杀人获得积分
function tbPLBase:AddKillPoint(tbBeKill)
	local nSelf = self.nKillPlayerBouns;
	local nTag = tbBeKill.nKillPlayerBouns;
	local nBase = NewBattle.KILL_BASEPOINT;
	local nPoint = math.floor(nBase * ((nTag + nBase) / (nSelf + nBase))^ 0.5);
	--连斩加成
	if self.nSeriesKillNum >= 3 then
		nPoint = nPoint * (NewBattle.SERIESPKPOINT + 1);
	end
	self.nKillPlayerBouns = self.nKillPlayerBouns + nPoint;
	self:AddPoint(nPoint, "你击杀玩家获得个人积分<color=yellow>%d<color>点！");
end
	
	
--玩家连斩处理
function tbPLBase:SeriesKill()
	self.nSeriesKillNum = self.nSeriesKillNum + 1;
	if self.nSeriesKillNum  > self.nMaxSeriesKillNum then
		self.nMaxSeriesKillNum = self.nSeriesKillNum;
	end

	--显示连斩
	if self.nSeriesKillNum >= NewBattle.SERIESPK_NAME[1][1] then
		local pPlayer = self:GetPlayer();
		if pPlayer then
			--只在刚达到连斩等级时广播
			local szSerName,nR = NewBattle:GetSeriesPkName(self.nSeriesKillNum);
			if nR == 1 then
				local szMsg = string.format("Người chơi <color=yellow>%s<color> hoàn thành <color=white>%d<color> liên trảm, đạt <color=yellow><bclr=red>[%s]<bclr><color>!",pPlayer.szName,self.nSeriesKillNum,szSerName);
				NewBattle.Mission:BroadCastMission(szMsg,NewBattle.SYSTEMRED_MSG,0);
			end
			pPlayer.ShowSeriesPk(1,self.nSeriesKillNum,30);
		end
	end
end

--守护NPC得分
function tbPLBase:DefNpc(szType)
	self.tbDefPoint[szType] = self.tbDefPoint[szType] + NewBattle.DEFPOINTRULE[szType];
	self:AddPoint(NewBattle.DEFPOINTRULE[szType], "Bảo vệ <color=yellow>"..NewBattle.NPC_CNAME[szType].."<color> tích lũy tăng <color=yellow>%d<color> điểm.");
end

--玩家击杀NPC得分
function tbPLBase:KillNpc(szType, nPlayerCount, bFirst, tbPlayers)
	local tbPoint = NewBattle.KILLPOINTRULE[szType];
	local nCount = nPlayerCount or 1;
	if not tbPoint then
		return;
	end
	self.tbKillNum[szType] = self.tbKillNum[szType] + 1;
	local nSelfBoun = tbPoint[1] / nCount;
	self:AddPoint(nSelfBoun, tbPoint[3]);
	self.tbKillPoint[szType] = self.tbKillPoint[szType] + nSelfBoun;
	--阵营共享分处理
	if bFirst == 1 and tbPoint[2] > 0 then
		local tbIsHere = {};
		for _, tbPlayer in ipairs(tbPlayers) do
			tbIsHere[tbPlayer.nPlayerId] = 1;
			local pPlayer = KPlayer.GetPlayerObjById(tbPlayer.nPlayerId)
			if szType == "LONGMAI" then
		
			elseif szType == "SHOUHUZHE" then
				
			elseif szType == "PAOTAI" then
				
			elseif szType == "JIANTA" then
				
			elseif szType == "ZHANCHE" then
				
			end 
	
		end
		local tbGroupPlayers = NewBattle.Mission:GetPlayerList(self.nGounpId);
		if tbGroupPlayers then
			for _,pPlayer in ipairs(tbGroupPlayers) do
				if not tbIsHere[pPlayer.nId] then
					local tbPlayer = NewBattle.Mission.tbCPlayers[pPlayer.nId];
					if tbPlayer then
						tbPlayer:AddPoint(tbPoint[2], "Nhận điểm chia sẻ từ Đại Doanh <color=yellow>%d<color> điểm.");
					end
				end
			end
		end
	end
end

--玩家获得积分
function tbPLBase:AddPoint(nPoint, szMsg)
	if nPoint <= 0 then
		return;
	end 
	nPoint = math.floor(nPoint);
	self.nBouns = self.nBouns + nPoint;
	self:ProcessRank()		-- 称号
	local pPlayer = self:GetPlayer();
	if pPlayer then
		-- 当玩家目前战场分数达到1500就累加一次今天参加宋金次数
		if (self.nAlreadyAddCount == 0 and self.nBouns >= Battle.DEF_SONGJIN_JOINCOUNT_MINBOUNS) then
			local nNum = pPlayer.GetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_DAY_JOIN_COUNT) + 1;
			pPlayer.SetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_DAY_JOIN_COUNT, nNum);
			self.nAlreadyAddCount = 1;
		end
		local nBouns = pPlayer.GetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_TOTALBOUNS);
		nBouns = nBouns + nPoint;
		self:SetTotalBouns(nBouns);
		NewBattle:SendMsg2Player(pPlayer, string.format(szMsg, nPoint), 1);		
	end
	
end

-- 设置总积分
function tbPLBase:SetTotalBouns(nPoint)
	local pPlayer = self:GetPlayer();
	if pPlayer then
		pPlayer.SetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_TOTALBOUNS, nPoint);
	end
end


--胜负加分
function tbPLBase:WinLostAddPoint(nWiner)
	self:AddPoint(100, "Nhận thêm <color=yellow>%d<color> tích lũy");
	if nWiner == 0 then
		self:AddPoint(self.nBouns * NewBattle.BATTLEPOINTRULE["DRAW"] / 100, "Trận chiến bất phân thắng bại, nhận <color=yellow>%d<color> tích lũy!")
		return;
	end
	if nWiner ~= self.nGounpId then
		self:AddPoint(self.nBouns * NewBattle.BATTLEPOINTRULE["LOST"] / 100, "Chiến bại, nhận <color=yellow>%d<color> tích lũy!")
		return;
	end
	if nWiner == self.nGounpId then
		self:AddPoint(self.nBouns * NewBattle.BATTLEPOINTRULE["WIN"] / 100, "Chiến thắng, nhận <color=yellow>%d<color> tích lũy!")
		return;
	end

end

-- 处理官衔相关信息
function tbPLBase:ProcessRank()
	local nTitle 	= 0;
	if (self.nTitle >= 10) then
		return;
	end
	for i = #Battle.TAB_RANKBONUS, 1, -1 do
		if (self.nBouns >= Battle.TAB_RANKBONUS[i] and -1 ~= Battle.TAB_RANKBONUS[i]) then
			nTitle = i;
			break;
		end
	end
	if (self.nTitle == nTitle) then
		return;
	end

	assert(self.nTitle < nTitle);
	local pPlayer = self:GetPlayer();
	if not pPlayer then
		return;
	end
	pPlayer.AddTitle(2, self.nGounpId, nTitle, 0);
	local tbAchievement = 
	{
		[5] = 135,
		[7] = 136,
		[9] = 137,
	}
	if tbAchievement[nTitle] then
		Achievement:FinishAchievement(pPlayer, tbAchievement[nTitle]);
	end
	
	self.nTitle	= nTitle;
	return nTitle;
end


-- 添加角色声望
function tbPLBase:SetPlayerShengWang()
	self.pPlayer.AddRepute(2, NewBattle.Mission.nLevel, self.nShengWang);
end

-- 添加角色荣誉
function tbPLBase:SetPlayerHonor()
	local nAddHonor = 0;
	local nMinId	= 0;
	local nMinHonor = self.nHonor;
	for i = Battle.TSK_BTPLAYER_HONOR1, Battle.TSK_BTPLAYER_HONOR4, 1 do
		local nHonor = self.pPlayer.GetTask(Battle.TSKGID, i);
		if (nMinHonor > nHonor) then
			nMinId = i;
			nMinHonor = nHonor;
		end
	end
	if (nMinId > 0) then
		nAddHonor = self.nHonor - nMinHonor;
		PlayerHonor:AddPlayerHonor(self.pPlayer, PlayerHonor.HONOR_CLASS_BATTLE, 0, nAddHonor);
		self.pPlayer.SetTask(Battle.TSKGID, nMinId, self.nHonor);
	end
end

function tbPLBase:GetKinTongName()
	local pPlayer	= self:GetPlayer();
	if not  pPlayer then
		return "Vô";
	end
	local nTongId		= pPlayer.dwTongId;
	local pTong			= KTong.GetTong(nTongId);
	local szTKName		= "Vô";
	
	if (pTong) then
		szTKName	= "(Bang hội) " .. pTong.GetName();
	else
		local nKinID = pPlayer.GetKinMember();					--
		--DEBUG BEGIN
		if NewBattle.__DEBUG then
			 print("nKinID", nKinID);
		end
		--
		--DEBUG END
		if nKinID then
			if (nKinID > 0) then
				local pKin		= KKin.GetKin(nKinID);
				if (pKin) then
					szTKName	= "(Gia tộc) " .. pKin.GetName();
				end
			end
		end
	end

	return szTKName;			-- 家族帮会名，有帮会计帮会，无帮会计家族
end

--获得杀死载具数量
function tbPLBase:KillNpcNum()
	local nNum = 0;
	for _, nN in pairs(self.tbKillNum) do
		nNum = nNum + nN;
	end
	return nNum;
end

--击杀野生NPC得分
function tbPLBase:OnKillNpc(nId)
	if not NewBattle.FIGHTNPC_NAME[nId] then
		return;
	end
	local szNpcName = NewBattle.FIGHTNPC_NAME[nId];
	local nPoint = NewBattle.BATTLE_NPCPOINT[szNpcName];
	self.tbKillNum.JUNDUI = self.tbKillNum.JUNDUI + 1;
	local szMsg  = string.format("Hạ gục %s-%s nhận được ", NewBattle.POWER_CNAME[NewBattle:GetEnemy(self.nGounpId)], NewBattle.BATTLE_NPCNAME[szNpcName])
	self:AddPoint(nPoint, szMsg.."<color=yellow>%d<color> điểm tích lũy.");
end
