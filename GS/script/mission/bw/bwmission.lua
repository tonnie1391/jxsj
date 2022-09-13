--//比武擂台 Mission主文件脚本
-- //处理开启Mission，关闭Mission，角色加入/离开Mission 后的回掉
Require("\\script\\mission\\bw\\bwhead.lua");

local tbTest = BiWu.tbMisBase or Mission:New();	-- 支持重载

-- 当Mission被开启“后”被调用
function tbTest:OnOpen()	--InitMission()
	self.nState		= 1;
end;

-- 在Mission被关闭“前”被调用
function tbTest:OnClose()	--EndMission()
	BiWu:GameOver(self);	--仅仅将角色送出擂台
	
	BiWu.tbMission[self.nMapId]	= nil;	--直接注销吧 都不记得用了哪些了
end;

-- 当玩家加入Mission“后”被调用
function tbTest:OnJoin(nGroupId)
	BiWu:SetStateJoinin(nGroupId);--加入后 设置状态
end;

-- 当玩家离开Mission“后”被调用
function tbTest:OnLeave(nGroupId)	--OnLeave(RoleIndex)
	local pPlayer = me;
	if (self.nState == 1 or self.nState == 2) then
		local szMsg = me.szName.."退出了擂台。";
		self:BroadcastMsg(szMsg);
		self:AddDamageOnLeave(nGroupId);
		if (me.GetTask(BiWu.TSKG_BIWU, BiWu.TSK_DEATH_STATE) == 1) then
			self.tbDeathCnt[nGroupId] = self.tbDeathCnt[nGroupId] - 1;
		end;
		
	end;
	me.SetTask(BiWu.TSKG_BIWU, BiWu.TSK_DEATH_STATE, 0);
	self:DeleteTimeInfo(pPlayer);
	BiWu:LeaveGame();
end;

-- //当玩家离开或死亡时，将他自身的受伤量加到小组中
function tbTest:AddDamageOnLeave(nGroupId)

	if (nGroupId ~= 1 and nGroupId ~= 2) then
		return 0;
	end;
	local nDamage = ST_GetDamageCounter();
	if (not self.tbSumDamageCnt) then
		self.tbSumDamageCnt = {0, 0};
	end;
	self.tbSumDamageCnt[nGroupId] = self.tbSumDamageCnt[nGroupId] + nDamage;
	
end;

-- 开启活动
function tbTest:InitGame(nMapId, nType, tbTeamKey, tbCaptainName, tbCaptainId)
	local nMapType = BiWu.TB_MAPID_MAPTYPE[nMapId];

	-- 设定可选配置项
	self.tbMisCfg	= {
		tbEnterPos		= {	[1] = {nMapId, unpack(BiWu.TB_MAPTYPE_MAPDEC[nMapType].tbCampPos[1])},
							[2] = {nMapId, unpack(BiWu.TB_MAPTYPE_MAPDEC[nMapType].tbCampPos[2])},
							[3] = {nMapId, unpack(BiWu.TB_MAPTYPE_MAPDEC[nMapType].tbCampPos[3])},},	-- 进入坐标
		tbDeathRevPos	= {	[1] = {nMapId, unpack(BiWu.TB_MAPTYPE_MAPDEC[nMapType].tbCampPos[1])},
							[2] = {nMapId, unpack(BiWu.TB_MAPTYPE_MAPDEC[nMapType].tbCampPos[2])},
							[3] = {nMapId, unpack(BiWu.TB_MAPTYPE_MAPDEC[nMapType].tbCampPos[3])},},	-- 进入坐标
--		nFightState	= 1,						-- 战斗状态
		nPkState		= Player.emKPK_STATE_CAMP,			-- 加入时禁止切换PK模式
		nDeathPunish	= 1,		-- 加入时禁止死亡惩罚
		tbCamp			= {[1] = 1, [2] = 2, [3] = 0},		-- 分别设定阵营
		nForbidTeam		= 1,			-- 加入时退出队伍、禁止组队
		nOnDeath		= 1,	-- 开启玩家死亡回调 self.OnDeath
		nInBattleState	= 1,	-- 战场模式
	};
	
	self:Open();		-- 开启Mission
	
	self.tbTimer1		= self:CreateTimer(BiWu.TIMER_1, self.OnSmallTimer, self);	-- 定时公告
	self.tbTimer2		= self:CreateTimer(BiWu.TIMER_2, self.OnTotalTimer, self);	-- 擂台总时间
	self.nMapId			= nMapId;
	self.szMapName		= GetMapNameFormId(nMapId);
	self.nWorldIdx		= SubWorldID2Idx(nMapId);
	self.nType			= nType;
	self.szType			= string.format("%dV%d", nType, nType)
	self.tbCaptainName	= tbCaptainName;
	self.tbCaptainId	= tbCaptainId;
	self.tbTeamKey	=	tbTeamKey;
	self.tbDeathCnt	=	{0,0};
end

-- //SmallTimer的定时调用
function tbTest:OnSmallTimer()

	local oldWorld = SubWorld;
	--SubWorld = self.nIdx

	if not self.nState or self.nState == 3 then
		return 0
	end;
	if not self.nNewsValue then
		self.nNewsValue = 1;
	else
		self.nNewsValue = self.nNewsValue + 1;
	end;
	
	local tbCaptainName = self.tbCaptainName;		--获取两队队长的名字；

	if (self.nState == 1) then 	--报名阶段
		local szMsg = self:OnReportSignState(self.nNewsValue);
		self:OnNoticeCaptain(szMsg);	--通知队长 报名阶段及比赛key
	elseif (self.nState == 2) then --开战了
		self:OnReportCompeteState();
	elseif (tbCurBiWuMapDec.nState == 3) then  --战斗结束了
		self:BroadcastMsg("战斗结束！");
		return 0;	--关闭Timer1
	end;
	--SubWorld = oldWorld;
end;

-- //TotalTimer的定时调用
function tbTest:OnTotalTimer()
	--Battle:CloseBattle(self.nBattleLevel, self.nBattleId);
	self:DecideBWState("OnTotalTimer");
	return 0;	-- 关闭Timer
end;

-- //结束后5秒计时
function tbTest:OnLastTimer()
	self:Close();		--结束 将场内选手送出
	return 0;	-- 关闭Timer
end;

function tbTest:OnNoticeCaptain(szTimeMsg)
	if (self.nType < 1 or szTimeMsg == 0) then
		return
	end;
	
	local i;
	
	local szName, nKey, szMsg;
	local pPlayer = nil;
	for i = 1, 2 do
		szName = self.tbCaptainName[i];	
		pPlayer = KPlayer.SearchPlayer(szName);
		if (pPlayer ~= nil) then
			Setting:SetGlobalObj(pPlayer);
			if (self.nType == 1) then
				local nMstGroup		= self:GetPlayerGroupId(KPlayer.GetPlayerObjById(self.tbCaptainId[i]));
				if (nMstGroup <= 0) then
					local szMsg = string.format("你是<color=yellow> %s<color>擂台赛的参赛方，比赛为<color=yellow> %d<color>对<color=yellow> %d<color>的比赛，请进快入场。",
										self.szMapName, self.nType, self.nType);
					me.Msg(szMsg);
					me.Msg(szTimeMsg);
				end;
				
			else
				nKey = self.tbTeamKey[i];		--GetMissionV(MS_TEAMKEY[i]);
				szMsg = string.format("你是<color=yellow> %s<color>擂台赛的参赛方，比赛为<color=yellow> %d<color>对<color=yellow> %d<color>的比赛，入场号为<color=yellow>[%d]<color>，请快点通知你的队友入场。",
							self.szMapName, self.nType, self.nType, nKey);
				me.Msg(szMsg);
				local nMstGroup		= self:GetPlayerGroupId(KPlayer.GetPlayerObjById(self.tbCaptainId[i]));
				if (nMstGroup <= 0) then
					me.Msg(szTimeMsg);
				end;
			end;
			Setting:RestoreGlobalObj();

		end
	end;
end;


-- //在报名期间，系统定期通知玩家当前的报名情况
function tbTest:OnReportSignState(nValue)
	if (nValue == BiWu.GO_TIME) then
		if (self:DecideBWState("OnOpen") ==  1) then
			return 0;
		end;
	
		self.nState = 2;
		self:BroadcastMsg("擂台赛入场已经截止，进入擂台赛准备时间！");
	
		local szMsg = string.format("%s比武场 <color=yellow>%s<color>小组 与 <color=yellow>%s<color>小组 的比武擂台赛入场已截止，比赛正式开始！",
						self.szMapName,self.tbCaptainName[1], self.tbCaptainName[2]	);
--		KDialog.NewsMsg(1, Env.NEWSMSG_NORMAL, szMsg);
		
		local tbAllPlayer = self:GetPlayerList();
		for _, pPlayer in pairs(tbAllPlayer) do
			self:ShowTimeInfo(pPlayer);
		end

		return 0;
	end;
	
	local nRestMin = math.floor((BiWu.GO_TIME - nValue) / 3);
	local nRestSec = math.mod((BiWu.GO_TIME - nValue),3) * 20;
	local szMsg;

	if (nRestMin > 0) and (nRestSec == 0) then
		szMsg = string.format("Thời gian còn lại: <color=yellow>%d<color> phút", nRestMin);
		self:BroadcastMsg(szMsg);
		
	elseif (nRestMin == 0 and nRestSec > 0) then
		szMsg = string.format("Thời gian còn lại: <color=yellow>%d<color> giây",nRestSec);
		self:BroadcastMsg(szMsg);
	end;
	return szMsg;
end;

-- //比赛过程中的公告,双方受伤总量及比赛时间
function tbTest:OnReportCompeteState()
	local nValue = self.nNewsValue;
	if (nValue < BiWu.GO_TIME * 2) then
		self:DecideBWState("OnOpen")
		return 0;
	end;
	
	if (nValue == BiWu.GO_TIME * 2) then
		if (self:DecideBWState("OnOpen") ==  1) then
			return 0;
		end;
		self:BroadcastMsg("擂台赛准备时间结束，比赛正式开始！");
		self:OnBwStartToFight(1);	--the param stand for group ID;
		self:OnBwStartToFight(2);
	end;
	
	if (self:DecideBWState("OnSmallTimer") == 1) then	--战斗进行过程中，系统定期通知各方的阵亡情况
		return 0;
	end;
--	local nLastFrame = (math.floor(Timer:GetRestTime(self.tbTimer2.nRegisterId)/18));
--	local nRestMin = math.floor(nLastFrame / 60);
--	local nRestSec = math.mod(nLastFrame,60);
--	self:BroadcastMsg(string.format("战斗阶段：双方目前正在比赛中。剩余时间<color=yellow>%d<color>分<color=yellow>%d<color>秒。",
--								 nRestMin, nRestSec));
	for i = 1, 2 do
		local nDamageCnt = self:CalceGroupDamageCnt(i);
		self:BroadcastMsg(i,string.format("我方所受伤害总量为<color=green>%d",nDamageCnt));
	end;
end;


--将一个组的人都变成战斗状态
function tbTest:OnBwStartToFight(nGroupID)
	if (nGroupID < 0) then
		return
	end;
	
	local nType		= self.nType;	--参加比赛的类型
	local nTaskid_Count	= BiWu.TSK_TB_COUNT[nType];		--参加比赛的场次
	
	local tbGroupPlayer	= self:GetPlayerList(nGroupID);	--角色
	
	local nCaptionId	= 0;
	local pPlayer = KPlayer.GetPlayerObjById(self.tbCaptainId[nGroupID]);	--队长的Obj
	local nMstGroup		= self:GetPlayerGroupId(pPlayer);
	if (nMstGroup > 0) then
		nCaptionId	= self.tbCaptainId[nGroupID];
	else
		pPlayer = tbGroupPlayer[1]
		nCaptionId	= pPlayer.nId;
	end;
	
	
	Setting:SetGlobalObj(pPlayer);
	if (me.GetCamp() == 0) then
		for i = 1, #tbGroupPlayer do
			local pMemPlayer = tbGroupPlayer[i];
			if (pMemPlayer.GetCamp() ~= 0) then
				nCaptionId = pMemPlayer.nId;
				break
			end;
		end;
	end;
	Setting:RestoreGlobalObj();

	-- 如果队长在，以队长组队，如果队长不在场内找第一个人组队
	local bp		= KTeam.CreateTeam(nCaptionId);
	
	for i = 1, #tbGroupPlayer do
		Setting:SetGlobalObj(tbGroupPlayer[i]);
	
		
		-- 创建队伍成功，把同阵营的成员组到队伍中
		if (me.nId ~= nCaptionId and bp == 1) then
			KTeam.ApplyJoinPlayerTeam(nCaptionId, me.nId);
		end;
		
		me.SetFightState(1);					--开战斗
		me.SetTask(BiWu.TSKG_BIWU, nTaskid_Count, me.GetTask(BiWu.TSKG_BIWU, nTaskid_Count)+1);	--参战场次＋1；
		Setting:RestoreGlobalObj();
	end;

end;


-- //获得组nGroupId的被伤害总量
function tbTest:CalceGroupDamageCnt(nGroupId)
	local tbGroupPlayer, nGroupCnt = self:GetPlayerList(nGroupId);
	
	local nSumDag = 0;--ST_GetDamageCounter();
	for i = 1, #tbGroupPlayer do
		Setting:SetGlobalObj(tbGroupPlayer[i]);
		nSumDag = nSumDag + ST_GetDamageCounter();
		Setting:RestoreGlobalObj();
	end;
	
	if (not self.tbSumDamageCnt) then
		self.tbSumDamageCnt = {0, 0};
	end;
	nSumDag = nSumDag + self.tbSumDamageCnt[nGroupId];
	return nSumDag;
end;


function tbTest:DecideBWState(szBiWuEvent)

	if (szBiWuEvent == "OnDeath" and self.nState ~= 2) then
		return 0;
	end;
	
	if (self.nState == 3) then
		return 0;
	end;
	
	local szWinWindow = "比武结束，胜负已分，你技高一筹。";
	local szLoseWindow = "比武结束，胜负已分，你甘拜下风。";
	local szTieWindow = "比武结束，双方不分伯仲，旗鼓相当。"
	
	if (self.nType > 1) then
		szWinWindow = "比武结束，胜负已分，你方技高一筹。";
		szLoseWindow = "比武结束，胜负已分，你方甘拜下风。";
	end;
	
	local tbCloseMsg  = {
		-- //OnDeath
		["OnDeath"] = {
			[1] = "%s擂台赛双方同归于尽，%s小组 与 %s小组打为平手！",
			[2] = "%s擂台赛战斗结束，<color=yellow>%s<color>小组 在比赛中击败了 <color=yellow>%s<color>小组，取得了最终的胜利!",
			},
		};
	tbCloseMsg["OnTotalTimer"] = {
		-- //OnTotalTimer
			[1] = "%s擂台赛双方同时离场，%s小组 与 %s小组 被判成平手！",
			[2] ="%s擂台赛战斗结束，%s小组与 %s小组双方握手言和！",
			[3] = "%s擂台赛战斗结束，%s小组人数多于 %s小组人数，取得了最终的胜利！",
			[4] = "%s擂台赛战斗结束，%s小组伤害总量少于 %s小组伤害总量，取得了最终的胜利！",
		};
	tbCloseMsg["OnOpen"] = {
		-- //OnOpen
			[1] ="%s擂台赛入场时间到，比赛双方<color=yellow> %s<color>小组 与<color=yellow> %s<color>小组 没有准时入场，放弃比赛！",
			[2] ="%s擂台赛入场时间到，<color=yellow> %s<color>小组 被判为获胜！<color=yellow> %s<color>小组 没有准时入场。",
		};
	tbCloseMsg["OnSmallTimer"] = {
		-- //OnSmallTimer
		[1] = "%s擂台赛双方同时离场，<color=yellow>%s<color>小组 与 <color=yellow>%s<color>小组 被判成平手！",
		[2] = tbCloseMsg["OnDeath" ][2],
	};
	
	local szMsg = "";
	local nWinGroup = 0;
	local szCaptainName = self.tbCaptainName;
	local nGroup1PlayerCount = self:GetPlayerCount(1)	-	self.tbDeathCnt[1];
	local nGroup2PlayerCount = self:GetPlayerCount(2)	-	self.tbDeathCnt[2];
--	print(szBiWuEvent, nGroup1PlayerCount, nGroup2PlayerCount,self:GetPlayerCount(1),self:GetPlayerCount(2))
	if (szBiWuEvent == "OnTotalTimer") then
		local nGroup1Damage = self:CalceGroupDamageCnt(1);
		local nGroup2Damage = self:CalceGroupDamageCnt(2);
		if (nGroup1PlayerCount == nGroup2PlayerCount) then	--比赛结束时 双方人数相同
			if (nGroup1Damage < nGroup2Damage) then	--被伤害量比较 小的一方获胜
				szMsg = string.format(tbCloseMsg[szBiWuEvent][4], 
						self.szMapName, szCaptainName[1], szCaptainName[2]);
				nWinGroup = 1;
			elseif (nGroup1Damage > nGroup2Damage) then
				szMsg = string.format(tbCloseMsg[szBiWuEvent][4],
						self.szMapName, szCaptainName[2], szCaptainName[1]);
				nWinGroup = 2;
			else											--不然就打平
				szMsg = string.format(tbCloseMsg[szBiWuEvent][2],
						self.szMapName, szCaptainName[1], szCaptainName[2]);
				nWinGroup = 0;
			end;
		elseif (nGroup1PlayerCount > nGroup2PlayerCount) then	--人数多的一方 获胜
			szMsg = string.format(tbCloseMsg[szBiWuEvent][3],
						self.szMapName, szCaptainName[1], szCaptainName[2]);
			nWinGroup = 1;
		else
			szMsg = string.format(tbCloseMsg[szBiWuEvent][3],
						self.szMapName, szCaptainName[2], szCaptainName[1]);
			nWinGroup = 2;
		end;
	else
		if (nGroup1PlayerCount <= 0 and nGroup2PlayerCount <= 0) then	--比赛过程中 只考虑人数为0时结束比赛
			szMsg = string.format(tbCloseMsg[szBiWuEvent][1],
						self.szMapName, szCaptainName[1], szCaptainName[2]);
			nWinGroup = 0;
		elseif (nGroup1PlayerCount <= 0) then
		
			szMsg = string.format(tbCloseMsg[szBiWuEvent][2],
						self.szMapName, szCaptainName[2], szCaptainName[1]);
			nWinGroup = 2;
		elseif (nGroup2PlayerCount <= 0) then
			szMsg = string.format(tbCloseMsg[szBiWuEvent][2],
						self.szMapName, szCaptainName[1], szCaptainName[2]);
			nWinGroup = 1;
		else
			return 0;	--比赛过程中 如果两边都有选手在场 不继续向下
		end;
		Timer:Close(self.tbTimer2.nRegisterId);
	end;
	
--	if (nWinGroup == 1) then
--		self:ForEachCall(1, me.CallClientScript({"uiInfoBoard:OnOpen", szWinWindow}));
--		self:ForEachCall(2, me.CallClientScript({"uiInfoBoard:OnOpen", szLoseWindow}));
--	elseif (nWinGroup == 2) then
--		self:ForEachCall(2, me.CallClientScript({"uiInfoBoard:OnOpen", szWinWindow}));
--		self:ForEachCall(1, me.CallClientScript({"uiInfoBoard:OnOpen", szLoseWindow}));
--	end;
	
	if (nWinGroup == 1) then
		self:BiWuWindowMsg(1, szWinWindow);
		self:BiWuWindowMsg(2, szLoseWindow);
	elseif (nWinGroup == 2) then
		self:BiWuWindowMsg(2, szWinWindow);
		self:BiWuWindowMsg(1, szLoseWindow);
	else
		self:BiWuWindowMsg(1, szTieWindow);
		self:BiWuWindowMsg(2, szTieWindow);
	end;
	
	
	--暂时取消此种记录胜负方式
	--self:AddWinState(self, nWinGroup);	--给获胜方加胜利场次 失败方清连胜场次
	self:BroadcastMsg(szMsg);		--Msg2MSAll(self.MISSIONID,str1)
	local pPlayer = nil;
	local szName = "";
	for i = 1, 2 do
		szName = self.tbCaptainName[i];	
		pPlayer = KPlayer.SearchPlayer(szName);
		if (pPlayer ~= nil) then
			Setting:SetGlobalObj(pPlayer);
			local nMstGroup		= self:GetPlayerGroupId(KPlayer.GetPlayerObjById(self.tbCaptainId[i]));
			if (nMstGroup <= 0) then
					me.Msg(szMsg);
			end
			Setting:RestoreGlobalObj();
		end
	end
--	KDialog.NewsMsg(1, Env.NEWSMSG_NORMAL, szMsg);
	self.nState = 3;		----改变场内状态 准备结束
--	self:Close();		--结束 将场内选手送出
	self.tbTimer3	= self:CreateTimer(BiWu.TIMER_3, self.OnLastTimer, self);	-- 擂台5秒后送出选手
	return 1;
end;


-- //擂台中角色死亡时处理
function tbTest:OnDeath(pKillerNpc)
	local szCaptainName = self.tbCaptainName;
	
	local pKillerPlayer = pKillerNpc.GetPlayer();
	local pOldPlayer  = PlayerIndex; --死者 或者用 me?
	local pOldMe = me;
	local szDeathName = me.szName;
	local nDeathGroupId	= self:GetPlayerGroupId(me);
	local szMsg;
	
	local nLaunCamp;
	if (pKillerPlayer) then
		local szKillerName = pKillerPlayer.szName--GetName();
		
		local nKillerGroupId	= self:GetPlayerGroupId(pKillerPlayer);
		if (nKillerGroupId == 1 or nKillerGroupId == 2) then
			szMsg  = string.format("%s多人擂台赛战斗中，<color=yellow>%s<color>队的<color=yellow>%s<color>在比赛中击倒了 <color=yellow>%s<color>队的<color=yellow>%s<color>。", 
							self.szMapName, szCaptainName[nKillerGroupId], szKillerName,
											szCaptainName[nDeathGroupId], szDeathName);
			self:BroadcastMsg(szMsg);
		end
	end;
	
--	if (szMsg ~= nil) then
--		self:KickPlayer(me);
--	end;
	--SetCurCamp(0,1);
	self.tbDeathCnt[nDeathGroupId] = self.tbDeathCnt[nDeathGroupId] + 1;
	me.SetTask(BiWu.TSKG_BIWU, BiWu.TSK_DEATH_STATE, 1);
	me.ReviveImmediately(0);
	local _, x, y = me.GetWorldPos();	
	me.CastSkill(BiWu.nHideSkillId, 1, x, y);	--死亡后变为观众，释放隐形技能
	--me.SetHide(1)		--观众设置隐形状态 取代旧命令 ChangeOwnFeature(0, 0, -1, -1, -1, -1, -1);
	me.Msg("系统消息：你暂时变为隐身状态。");
	-- 处理场内人数变化时 比赛的走向（结束？or 继续？）
	self:DecideBWState("OnDeath");
end;


function tbTest:BiWuWindowMsg(nGroupId, szMsg)
	local tbPlayer, nCount	= self:GetPlayerList(nGroupId);
	local pPlayerOld	= me;
	for _, pPlayer in ipairs(tbPlayer) do
		me	= pPlayer;
		me.CallClientScript({"Ui:ServerCall", "UI_INFOBOARD", "OnOpen", szMsg});
	end
	me	= pPlayerOld;
end;

-- //显示即时信息：剩余时间
function tbTest:ShowTimeInfo(pPlayer)
	Dialog:ShowBattleMsg(pPlayer, 1, 0);
	Dialog:SendBattleMsg(pPlayer, "")
	local nRemainFrame		= Timer:GetRestTime(self.tbTimer2.nRegisterId);
	local szMsgFormat		= "<color=green>Thời gian còn lại: <color> <color=white>%s<color>";
	Dialog:SetBattleTimer(pPlayer, szMsgFormat, nRemainFrame);
end;


function tbTest:DeleteTimeInfo(pPlayer)
	Dialog:ShowBattleMsg(pPlayer, 0, Env.GAME_FPS);
end;


BiWu.tbMisBase = tbTest;
