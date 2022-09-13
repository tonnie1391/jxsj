-- 文件名　：newbattle_gs.lua
-- 创建者　：LQY
-- 创建时间：2012-07-18 15:02:18
-- 说	明 ：新宋金战场的GS实现
-- 哇！小朋友们大家好~还记得我是谁吗？
if not MODULE_GAMESERVER then
	return;
end
Require("\\script\\mission\\newbattle\\newbattle_def.lua");

NewBattle.tbNewBattleOpen = NewBattle.tbNewBattleOpen or 
{
	[1] = {0, 0},
	[2] = {0, 0},
	[3] = {0, 0},
};
--启动战场活动，进入第一个阶段
function NewBattle:StartNewBattle_GS(dwBattleLevel, nSeqNum, nBattleSeq)
	if(self.CanStartBattle() ~= 1) then
		return 0;
	end
	--
	--DEBUG BEGIN
	if NewBattle.__DEBUG then
	  	print("启动战场_GS");
	end
	--
	--DEBUG END

	if not NewBattle.TB_MAP_BATTLE[dwBattleLevel][nSeqNum] then
		return 0;
	end

	--地图所在GS判断
	if SubWorldID2Idx(NewBattle.TB_MAP_BATTLE[dwBattleLevel][nSeqNum]) < 0 then

		--DEBUG BEGIN
		if NewBattle.__DEBUG then
		  print(dwBattleLevel,"Mission地图不科学！");
		end
		--DEBUG END
		return 0;
	end

	--Mission是否开放
	if self.Mission:IsOpen() ~= 0 then

		--DEBUG BEGIN
		if NewBattle.__DEBUG then
		  print("Mission尚未关闭，无法打开！");
		end
		--DEBUG END

		return 0;
	end
	--初始化MISSION
	local szBattleTime = GetLocalDate("%m%d%H");
	self.Mission:InitGame(NewBattle.TB_MAP_BATTLE[dwBattleLevel][nSeqNum], dwBattleLevel, szBattleTime, nSeqNum, nBattleSeq);

	--置活动状态
	self.nBattle_State = self.BATTLE_STATES.SIGNUP;

	--初始化表
	self.tbPlayerList = {};			--玩家列表
	self.tbTimers = {};				--计时器列表

	if self.Mission:IsOpen() == 1 then
		GCExcute({"NewBattle:BattleOpen_GC", dwBattleLevel, nSeqNum});
	else
		--记log
	end

end

-- 同步开放信息
function NewBattle:UpdateOpen_GS(tbNewBattleOpen)
	if tbNewBattleOpen and type(tbNewBattleOpen) == "table" then
		self.tbNewBattleOpen = tbNewBattleOpen;
	end
end

-- 成功开启一个战场
function NewBattle:BattleOpen_GS(dwBattleLevel, nSeqNum)
	local szMsg = string.format("Băng Hỏa Liên Thành\nThời gian báo danh %d phút. Điều kiện tham gia: Nhân vật cấp %d trở lên.", self.TIME_SIGN / (Env.GAME_FPS * 60), Battle.LEVEL_LIMIT[1]);
	KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, szMsg);
	self.tbNewBattleOpen[dwBattleLevel][nSeqNum] = 1;
end

--玩家能否加入某一阵营
function NewBattle:CanPlayerJoinPower(pPlayer, nType)
	if self.nBattle_State == self.BATTLE_STATES.CLOSED then
		return 0, "战场尚未开放。"
	end
	if self:FindPlayer(pPlayer.nId) ~= 0 then
		return 0, "你已经报过名了！";
	end
	if pPlayer.IsFreshPlayer() == 1 then
		return 0, "你目前尚未加入门派，武艺不精，还是等加入门派后再来把！";
	end
	if pPlayer.GetTiredDegree1() == 2 then
		return 0, "您太累了，还是休息下吧！";
	end
	if (not self.Mission) then
		Dialog:Say("开赴战场的大军尚未出发，请继续勤加操练，等候我们的通知。");
		return;
	end
	local nXia,nMeng = self:GetPlayerCount();
	if(nType == 1 and nXia - nMeng >= self.SIGNLIMIT) then
		return 0, "宋军报名人数太多，大侠还是稍等片刻再来吧！";
	end
	if(nType == 2 and nMeng - nXia >= self.SIGNLIMIT) then
		return 0, "金军报名人数太多，大侠还是稍等片刻再来吧！";
	end
	if(nType == 1 and nXia >= NewBattle.MAXPLAYER) then
		return 0 , "宋军报名人数已达上线，大侠还是去金军吧！";
	end

	if(nType == 2 and nMeng >= NewBattle.MAXPLAYER) then
		return 0 , "金军报名人数已达上线，大侠还是去宋军吧！";
	end
	return 1;
end

--将玩家传回
function NewBattle:MovePlayerOut(pPlayer, nPower)
	if not nPower then
		local nMapId, nMapX, nMapY = Boss.Qinshihuang:GetLeaveMapPos();
		pPlayer.NewWorld(nMapId, nMapX, nMapY);
		return;
	end
	pPlayer.SetFightState(0);
	pPlayer.NewWorld(NewBattle.TB_MAP_BAOMING[NewBattle.Mission.nLevel][NewBattle.Mission.nSeqNum][nPower],unpack(NewBattle:GetRandomPoint(NewBattle.POS_BAOMING)));
end

--获取两个阵营的报名人数 宋,金
function NewBattle:GetPlayerCount()
	local nXia	 = 0;
	local nMeng	 = 0;
	for i, tbInfo in ipairs(self.tbPlayerList) do
		if tbInfo.nPower == 1 then
			nXia = nXia + 1;
		elseif tbInfo.nPower == 2 then
			nMeng = nMeng + 1;
		end
	end
	return nXia,nMeng;
end

--发送信息到玩家
function NewBattle:SendMsg2Player(pPlayer,szMsg,nType)
	local nMsgType = nType or NewBattle.SYSTEM_CHANNEL_MSG;
	if not pPlayer then
		return;
	end
	for _,szType in ipairs(self.MSGSENDRULE[nMsgType]) do
		if szType == "CHANNEL" then
			KDialog.Msg2PlayerList({pPlayer}, szMsg, "Hệ thống");
		end
		if szType == "BLACK" then
			Dialog:SendBlackBoardMsg(pPlayer, szMsg);
		end
		if szType == "RED" then
			Dialog:SendInfoBoardMsg(pPlayer, szMsg);
		end
	end
end

-- 查找玩家
function NewBattle:FindPlayer(nPlayerId)
	for i, tbInfo in ipairs(self.tbPlayerList) do
		if tbInfo.nId == nPlayerId then
			return i,tbInfo;
		end
	end
	return 0;
end

--新玩家加入
function NewBattle:PlayerJoin(pPlayer, nType)
	if not pPlayer then
		return;
	end
	table.insert(self.tbPlayerList, {nId = pPlayer.nId, nPower = nType});
	self:SendMsg2Player(pPlayer, "Đã gia nhập doanh trại phe "..self.POWER_CNAME[nType]);
	local nDbTskId_PlCnt = Battle.DBTASKID_PLAYER_COUNT[self.Mission.nLevel][self.Mission.nSeqNum][nType];
	local tbCount = {0,0};
	tbCount[1], tbCount[2] = self:GetPlayerCount();
	KGblTask.SCSetTmpTaskInt(nDbTskId_PlCnt, tbCount[nType]);
end

--玩家离开
function NewBattle:PlayerLeave(pPlayer)
	if not pPlayer then
		return;
	end
	for i,tbPlayer in ipairs(self.tbPlayerList) do
		if tbPlayer.nId == pPlayer.nId then
			table.remove(self.tbPlayerList, i);
			local nDbTskId_PlCnt = Battle.DBTASKID_PLAYER_COUNT[self.Mission.nLevel][self.Mission.nSeqNum][tbPlayer.nPower];
			local tbCount = {0,0};
			tbCount[1], tbCount[2] = self:GetPlayerCount();
			KGblTask.SCSetTmpTaskInt(nDbTskId_PlCnt, tbCount[tbPlayer.nPower]);
		end
	end

	--self:SendMsg2Player(pPlayer,"你已离开"..self.POWER_NAME[nType].."军阵营");
end

--关闭MISSION
function NewBattle:CloseMission(dwBattleLevel, nSeqNum)
	if self.Mission:IsOpen() ~= 0 then
		self.Mission:Close();
		GCExcute({"NewBattle:BattleClose_GC", dwBattleLevel, nSeqNum});
	end
	return 0;
end

-- 关闭一个战场
function NewBattle:BattleClose_GS(dwBattleLevel, nSeqNum)
	--local szMsg = string.format("宋金大战一触即发，目前正进入报名阶段，欲参战者请尽快从七大城市中的战场募兵官或使用宋金诏书前往宋金战场报名点报名，报名剩余时间:%d分。参战条件:等级不小于%d级。", self.TIME_SIGN / (Env.GAME_FPS * 60), Battle.LEVEL_LIMIT[1]);
	--KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, szMsg);
	self.tbNewBattleOpen[dwBattleLevel][nSeqNum] = 0;
end

--载具快捷键处理
function NewBattle:SwitchCarrier(nPlayerId, nNpcId)
	-- TODO 还得加个地图判断啊，同一个GS就可以按N，看起来不科学
	if NewBattle.nBattle_State ~= NewBattle.BATTLE_STATES.FIGHT then
		return;
	end

	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	local bOnCarrier = (pPlayer.GetCarrierNpc()) and 1 or 0;
	if bOnCarrier == 1 then
		pPlayer.LandOffCarrier();
		return;
	else
		if not nNpcId then
			return;
		end
		local pNpc = KNpc.GetById(nNpcId);
		if not pNpc then
			return;
		end
		local tbInfo = pNpc.GetTempTable("Npc");
		--判断一下是不是载具
		if pNpc.IsCarrier() == 1 then
			--判断载具归属
			local nPlayerPower = self.Mission:GetPlayerGroupId(pPlayer);
			if not nPlayerPower then
				return;
			end
			if nPlayerPower ~= tbInfo.nPower then
				pPlayer.Msg("Không phải là Chiến Xa của Phe ta.");
				return;
			end

			--判断与载具的距离
			local nMapId1, nPosX1, nPosY1 = pPlayer.GetWorldPos();
			local nMapId2, nPosX2, nPosY2 = pNpc.GetWorldPos();
			local nDis	= ((nPosX1-nPosX2)^2 + (nPosY1-nPosY2)^2)^0.5;
			if nDis > NewBattle.CARRIERDISLIMIT then
				pPlayer.Msg("Khoảng cách quá xa.");
				return;
			end
			
			--数据埋点，玩家控制资源记录  账号，角色，控制的资源模版ID
			StatLog:WriteStatLog("stat_info", "ganluocheng", "res_use", pPlayer.nId, pNpc.nTemplateId);
			
			--下马
			pPlayer.RideHorse(0);
			--GeneralProcess:StartProcess("乘坐载具……",self.GETCARRIERTIME, {self.OnCarrierProcess, self, nPlayerId, nNpcId}, nil, self.tbCarrierBreakEvent);
			Npc.tbCarrier:LandInCarrier(pNpc, me);
		else
			pPlayer.Msg("Không thể lên Chiến Xa!");
		end
	end
end

--登录载具读条回调, 作废
function NewBattle:OnCarrierProcess(nPlayerId, nNpcId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		pPlayer.Msg("Chiến Xa đã biến mất.");
		return;
	end
	--判断与载具的距离
	local nMapId1, nPosX1, nPosY1 = pPlayer.GetWorldPos();
	local nMapId2, nPosX2, nPosY2 = pNpc.GetWorldPos();
	local nDis	= ((nPosX1-nPosX2)^2 + (nPosY1-nPosY2)^2)^0.5;
	if nDis > NewBattle.CARRIERDISLIMIT then
		pPlayer.Msg("距离太远了，无法乘坐载具。");
		return;
	end
	pPlayer.CallClientScript({"me.LandInSelCarrier"});
end

-- C2S 玩家上下载具
function c2s:PlayerSwitchCarrier(nNpcId)
	if GLOBAL_AGENT then
		return 0;
	end
	NewBattle:SwitchCarrier(me.nId, nNpcId);
end
