-- 文件名　：kuafubaihu_mission.lua
-- 创建者　：zhangjunjie
-- 创建时间：2010-12-13 17:54:04
-- 描述：跨服白虎mission


Require("\\script\\kuafubaihu\\kuafubaihu_def.lua")

local tbBase = Mission:New();
KuaFuBaiHu.tbMissionBase = tbBase;

function tbBase:OnStart(nMapId)
	--设置Mission的tbMisCfg
	if IsMapLoaded(nMapId) == 0 then	--如果地图没加载，则mission创建失败
		Dbg:WriteLogEx(2, "KuafuBaiHu","Mission Create Failed! nMapId:",nMapId);
		return 0;
	end
	self.tbMisCfg =
	{
		nOnDeath = 1;
		nDeathPunish = 1;
		tbLeavePos    = {};
		tbDeathRevPos = {};
		nPkState =  Player.emKPK_STATE_EXTENSION;
		nForbidSwitchFaction	= 1,
		nOnMovement		= 1,								-- 参加某项活动
		nDisableFriendPlane = 1,							-- 禁止好友界面
		nDisableStallPlane	= 1,							-- 禁止交易界面
		nForbidStall		= 1,							-- 禁止摆摊
		nDisableOffer		= 1,							-- 禁止收购
	}
	self.nMapId = nMapId;
	self:Reset();
end


function tbBase:Reset()
	--初始化状态数据
	self.nStep 		= 1;	-- 第几步,起始为第一步
	self.nPlayerCount = 0;	--玩家数量
	self.bCanJoin	= 1;	--当前时间是否可以加入
	self.tbGroupId = {};		--自定义分组id
	self.tbGroups = {};
	self.nServerId = 0;
	self.nBossCount = 0;		--用来记录各BOSS的死亡情况
	self.tbBoss	=	{
		[1]	= {id = KuaFuBaiHu.tbNpcId["dadao1"],level = KuaFuBaiHu.tbNpcLevel["dadao1"],pos = KuaFuBaiHu.tbNpcPos["dadao1"]},
		[2]	= {id = KuaFuBaiHu.tbNpcId["dadao2"],level = KuaFuBaiHu.tbNpcLevel["dadao2"],pos = KuaFuBaiHu.tbNpcPos["dadao2"]},
		[3] = {id = KuaFuBaiHu.tbNpcId["dadao3"],level = KuaFuBaiHu.tbNpcLevel["dadao3"],pos = KuaFuBaiHu.tbNpcPos["dadao3"]},
		[4]	= {id = KuaFuBaiHu.tbNpcId["shiyuejiaotu"],level = KuaFuBaiHu.tbNpcLevel["shiyuejiaotu"],pos = KuaFuBaiHu.tbNpcPos["shiyuejiaotu"]},
	}
	for _,tbBoss in ipairs(self.tbBoss) do
		self.nBossCount = self.nBossCount + #tbBoss.id;
	end
	self.tbPlayers = {};
	self.tbTimers = {};
	ClearMapNpc(self.nMapId);
	ClearMapObj(self.nMapId);
end

function tbBase:Begin()
	self:Reset();
	self:InitGame();
end

function tbBase:InitGame()
	self:AddNormalNpc();
	self.nServerId = GetServerId() ;
	self:TimerStart();
end


function tbBase:GetPlayerCount()
	return self.nPlayerCount or 0;
end

function tbBase:AddPlayerCount()
	self.nPlayerCount = (self.nPlayerCount or 0) + 1
end


function tbBase:DelPlayerCount()
	self.nPlayerCount = self.nPlayerCount - 1;
	if self.nPlayerCount < 0 then
		self.nPlayerCount = 0;
	end
end

function tbBase:DelBoss()
	self.nBossCount = self.nBossCount - 1;
	if self.nBossCount < 0 then
		self.nBossCount = 0;
	end
end

function tbBase:BeforeLeave(nGroupId, szReason)
	self:DelPlayerCount();
end

function tbBase:OnLeave(nGroupId, szReason)
	self:SetLeaveFightState(me);
	KuaFuBaiHu:RemovePlayerTitle(me);
	self:SyncPlayerData();
	self:WriteLeaveLog();
end


function tbBase:WriteLeaveLog()
	----------数据埋点------------------------------------------------------------
	local nUnionId = me.GetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_UNION_ID);--联盟id
	local nTongId  = me.GetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_TONG_ID); --获取帮会id
	local nScoresGet = me.GetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_CURRENT_GET_SCORES) or 0;
	local szGate = me.GetTaskStr(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_SERVER_NAME);	--服务器名
	local szTongName = me.GetTaskStr(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_TONG_NAME); --帮会名
	local nCampId = ( nUnionId ~= 0 and nUnionId) or nTongId;
	local nMapId  = self.nMapId;
	local szLogMsg = string.format("%s,%s,%d,%d,%d",szGate,szTongName,nCampId,nMapId,nScoresGet);
	StatLog:WriteStatLog("stat_info", "kuafubaihu","leave", me.nId, szLogMsg);
	-------------------------------------------------------------------------------	
end

function tbBase:SyncPlayerData()	--离开mission时候进行积分同步
	local nScoresGet = me.GetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_CURRENT_GET_SCORES);
	local nScoresRegion = GetPlayerSportTask(me.nId,KuaFuBaiHu.GB_TASK_GID,KuaFuBaiHu.GB_TASK_SCORES) or 0;
	local nNewScores = nScoresGet + nScoresRegion;
	SetPlayerSportTask(me.nId,KuaFuBaiHu.GB_TASK_GID,KuaFuBaiHu.GB_TASK_SCORES,nNewScores);
	Dbg:WriteLogEx(2, "KuafuBaiHu","out mission or logout or death:",me.szName,me.nId,nScoresGet);
end

function tbBase:OnDeath(pKillerPlayer)
	me.SetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_OUT_FOR_DEATH,1);
	local pKiller = pKillerPlayer.GetPlayer();
	if  pKiller then
		--local tbPlayer, nCount = KPlayer.GetMapPlayer(me.nMapId);
		local tbPlayer, nCount = self:GetPlayerList();
		if (nCount > 2 ) then
			local szMsgToOther = "<color=green>" .. pKiller.szName .."<color>击退了闯堂者<color=yellow>" .. me.szName .. "<color>。";
			KDialog.Msg2PlayerList(tbPlayer, szMsgToOther, "系统提示");
		end	
		local nScoresGet = pKiller.GetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_CURRENT_GET_SCORES);
		pKiller.SetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_CURRENT_GET_SCORES,nScoresGet + KuaFuBaiHu.nScoreKillPlayer); 
		local nTotalcoresGet = pKiller.GetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_GB_TOTAL_SCORES);
		pKiller.SetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_GB_TOTAL_SCORES, nTotalcoresGet + KuaFuBaiHu.nScoreKillPlayer); 
		KuaFuBaiHu:ChangeScoresShow(pKiller);
		pKiller.Msg("击退了闯堂者<color=yellow>" .. me.szName .. "<color>获得<color=yellow>" ..KuaFuBaiHu.nScoreKillPlayer.. "点<color>积分。");
		Dbg:WriteLogEx(2, "KuafuBaiHu",self.nMapId,"Killer:",pKiller.szName,"dead:",me.szName);
	end
	self:WriteDeathLog(pKillerPlayer);	--死亡时数据埋点
	me.ReviveImmediately(1);
	self:KickPlayer(me);	--死亡了要kick
	KuaFuBaiHu:NewWorld2GlobalMap(me);	--在全区服传送传到全区gs上的地图	
end

function tbBase:WriteDeathLog(pKillerPlayer)
	local pKiller = pKillerPlayer.GetPlayer();
	if not pKiller then
		return;
	end
	----------数据埋点------------------------------------------------------------
	local nUnionId = me.GetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_UNION_ID);--联盟id
	local nTongId  = me.GetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_TONG_ID); --获取帮会id
	local szGate = me.GetTaskStr(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_SERVER_NAME);	--服务器名
	local szTongName = me.GetTaskStr(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_TONG_NAME); --帮会名
	local nCampId = ( nUnionId ~= 0 and nUnionId) or nTongId;
	local nMapId  = self.nMapId;
	local szKillerName = pKiller.szName;
	local nUnionIdKiller = pKiller.GetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_UNION_ID);--联盟id
	local nTongIdKiller  = pKiller.GetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_TONG_ID); --获取帮会id
	local szGateKiller = pKiller.GetTaskStr(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_SERVER_NAME);	--服务器名
	local szTongNameKiller = pKiller.GetTaskStr(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_TONG_NAME); --帮会名
	local nCampIdKiller = ( nUnionIdKiller ~= 0 and nUnionIdKiller) or nTongIdKiller;
	local szLogMsg = string.format("%s,%s,%d,%d,%s,%s,%d,%s",szGate,szTongName,nCampId,nMapId,szKillerName,szTongNameKiller,nCampIdKiller,szGateKiller);
	StatLog:WriteStatLog("stat_info", "kuafubaihu","kill", me.nId, szLogMsg);
	-------------------------------------------------------------------------------	
end


function tbBase:CanJoinIn()
	return self.bCanJoin;
end

function tbBase:AddNormalNpc()
	local nMapId = self.nMapId;
	local nTmpId = KuaFuBaiHu.tbNpcId["shiyuelolo"][1];	--小怪只有一种id
	local nLevel = KuaFuBaiHu.tbNpcLevel["shiyuelolo"];
	for _,tbPos in pairs(KuaFuBaiHu.tbNpcPos["shiyuelolo"]) do
		KNpc.Add2(nTmpId, nLevel, -1, nMapId, tbPos.nX / 32, tbPos.nY / 32, 1); --小怪重生
	end
end

function tbBase:CallBoss(nStep)
	local nMapId = self.nMapId;
	local pBoss  = nil;
	if nStep >= KuaFuBaiHu.STEP_END - 1 then	--第五步为GameOver,所以应该退出
		return 0;
	end
	local tbTmpId = self.tbBoss[nStep].id;
	local nLevel = self.tbBoss[nStep].level;
	for nIndex,tbPos in pairs(self.tbBoss[nStep].pos) do
		pBoss = KNpc.Add2(tbTmpId[nIndex], nLevel, -1, nMapId, tbPos.nX / 32, tbPos.nY / 32);
		Npc:RegPNpcOnDeath(pBoss, self.OnDeath_Boss, self);
	end
	local tbPlayerList,nCount = self:GetPlayerList();
	if nStep == 4 then
		local szMsg = string.format("蚀月教徒<color=green>%s<color>现身了，请迅速击杀！",pBoss and pBoss.szName or "");
		self:RegisterBloodPercent(pBoss,unpack(KuaFuBaiHu.tbFinalBossBloodPercent));
		if nCount > 0 then
			KDialog.Msg2PlayerList(tbPlayerList, szMsg, "系统提示");
			for _,pPlayer in pairs(tbPlayerList) do
				if pPlayer then
					KuaFuBaiHu:ShowInfoBoard(pPlayer, szMsg);
				end
			end
		end
	else
		local szMsg = string.format("密室内出现几个江洋大盗，快将他们捉拿！");
		if nCount > 0 then
			KDialog.Msg2PlayerList(tbPlayerList, szMsg, "系统提示");
			for _,pPlayer in pairs(tbPlayerList) do
				if pPlayer then
					KuaFuBaiHu:ShowInfoBoard(pPlayer, szMsg);
				end
			end
		end
	end
	return 1;
end

--给npc注册血量触发回调
function tbBase:RegisterBloodPercent(pNpc,...)
	if not pNpc then
		return;
	end
	local tbPercent = arg;
	for i = 1,#tbPercent do
		pNpc.AddLifePObserver(tbPercent[i]);
	end
end

function tbBase:OnDeath_Boss(pNpc)
	local pKillerPlayer = pNpc.GetPlayer();
	local nStep = self.nStep;
	if nStep >= KuaFuBaiHu.STEP_END then
		return 0;
	end
	self:DelBoss();	--死一个boss，减少一个
	if self:IsBossClear() == 1 then	--boss干净了，完成任务
		local tbPlayerList,nCount = self:GetPlayerList();
		local szMsg = "贼人已经全部被击退，可以出去了！";
		if nCount > 0 then
			KDialog.Msg2PlayerList(tbPlayerList,szMsg, "系统提示");
			for _,pPlayer in pairs(tbPlayerList) do
				if pPlayer then
					KuaFuBaiHu:ShowInfoBoard(pPlayer, szMsg);
				end
			end
		end
		KNpc.Add2(KuaFuBaiHu.tbNpcId["chuansongmen"][1], 30, -1, self.nMapId, KuaFuBaiHu.tbTransferDoorPos.nX / 32, KuaFuBaiHu.tbTransferDoorPos.nY/32);		
	end
end

function tbBase:IsBossClear()		--boss是否清除干净
	if self.nBossCount ~= 0 then
		return 0;
	else
		return 1;
	end
end

function tbBase:OnGameOver()	--时间到了，游戏结束
	local tbPlayerList,nCount = self:GetPlayerList();
	local szMsg = "密室不可久留，请下次再来！";
	if nCount > 0 then
		KDialog.Msg2PlayerList(tbPlayerList, szMsg, "系统提示");
	end
	return 0;
end

function tbBase:TimerStart(szFunction)
	if szFunction then
		local fncExcute = self[szFunction];
		if fncExcute then
			local nRet = fncExcute(self,self.nStep);
			if nRet and nRet == 0 then
				return 0;
			end
		end
		self.nStep = self.nStep + 1;
		if (self.nStep >= KuaFuBaiHu.STEP_END) then
			return 0;
		end
		if self.nStep == 3 then
			self.bCanJoin = 0;	--超过35分钟，则不能进入
		end
	end
	local tbTimer = KuaFuBaiHu.tbTimerFunc[self.nStep];
	if not tbTimer then
		return 0;
	end
	Dbg:WriteLogEx(2, "KuafuBaiHu", tbTimer[2], tbTimer[3], self.nStep);
	self:CreateTimer(tbTimer[2],self.TimerStart,self,tbTimer[3]);
	return 0;
end


function tbBase:OnJoin(nGroupId)
	if self:IsGroupExist(nGroupId) == 0 then
		table.insert(self.tbGroupId,nGroupId);
	end
	local nIndex = self:GetGroupIndex(nGroupId);
	self:SetJoinPKState(me,nIndex); --nGroupId通过任务变量传进，该任务变量为玩家在本服的帮会id
	KuaFuBaiHu:AddPlayerTitle(me,nIndex);--给玩家加上标题
	local szMsg = string.format("密室内随时会出现江洋大盗，请夺回他们身上的残页！");
	KuaFuBaiHu:ShowInfoBoard(me,szMsg);
	me.Msg(szMsg,"系统提示");
end

function tbBase:SetJoinPKState(pPlayer,nGroupId)
	pPlayer.nExtensionGroupId = nGroupId;
	-- 仇杀、切磋
	pPlayer.SetFightState(1);
	pPlayer.ForbidEnmity(1);
	pPlayer.ForbidExercise(1);
	pPlayer.DisabledStall(1);
	pPlayer.nForbidChangePK = 1;
end


function tbBase:SetLeaveFightState(pPlayer)
	pPlayer.SetFightState(0);
	pPlayer.DisabledStall(0);	--摆摊
	pPlayer.nForbidChangePK	= 0;
	pPlayer.ForbidEnmity(1);
	pPlayer.ForbidExercise(1);
end

function tbBase:GetGroupIndex(nCamp)	--获取阵营在group中的索引
	for nIndex,nId in pairs(self.tbGroupId) do
		if nCamp == nId then
			return nIndex;
		end
	end
	return 0;
end


function tbBase:IsGroupExist(nCamp)		--当前阵营是否存在于自定义分组中
	for _,nID in pairs(self.tbGroupId) do
		if nCamp == nID then
			return 1;
		end
	end
	return 0;
end

function tbBase:GetGroupsCount()	--当前mission下的阵营数量
	return #self.tbGroupId;
end

function tbBase:IsMapFull()	--地图是否满员
	if self.nPlayerCount > KuaFuBaiHu.FIGHT_MAX_PLAYER then
		return 1;
	else
		return 0;
	end
end

function tbBase:OnClose()		--关闭将maplist该id设为未使用状态
	for nIndex,tbMis in pairs(KuaFuBaiHu.tbMissionList) do
		if self.nMapId == tbMis.nMapId then
			table.remove(KuaFuBaiHu.tbMissionList,nIndex);
		end
	end
	local tbPlayerList = self:GetPlayerList();
	for i, pPlayer in pairs(tbPlayerList) do
		KuaFuBaiHu:NewWorld2GlobalMap(pPlayer);
	end
end









