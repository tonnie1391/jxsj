-- 文件名　：newbattle_mission.lua
-- 创建者　：LQY
-- 创建时间：2012-07-18 15:02:23
if not MODULE_GAMESERVER then
	return;
end
Require("\\script\\mission\\newbattle\\newbattle_def.lua");

local tbMission = NewBattle.Mission or Mission:New();
NewBattle.Mission = tbMission;

--记录玩家信息类
tbMission.tbCPlayers = tbMission.tbCPlayers or {};

--小地图标志点配置
tbMission.tbMiniMapConfig =
{	--存活情况table,坐标点,宋军标志,金军标志,名称,是否区分阵营
	[1] = {"tbArrowLive", 		"POS_JIANTA", 		13, 17, 	"Tiễn Tháp", 	0},
	[2] = {"tbTowerLive", 		"POS_PAOTAI", 		15, 15, 	"Pháo Tháp", 	0},
	[3]	= {"tbLongMaiLive", 	"POS_LONGMAI", 		14, 14, 	"Long Mạch", 	0},
	[4]	= {"tbShouhuzheLive", 	"POS_SHOUHUZHE", 	9, 	9, 		"Thủ Hộ Giả", 	0},
	[5]	= {"tbCarLive", 		"tbPos_ZhanChe", 	16, 18, 	"Chiến Xa", 	1},
};

function tbMission:OnOpen()
	--注册信息更新时钟
	NewBattle:AddTimer("BattleUpdate", NewBattle.UPDATE_TIME, self.OnUpdateTime, self);

	--初始化战场数据
	self.bFristBlood 		= 0;			--一血清零
	self.nTransStoneOwner	= 0;			--传送石中立
	self.IsFighted			= 0;			--是否开战过
	self.tbTip			= 					--提示
	{
		["XIA"]		=	{{2,1}},
		["MENG"]	=	{{2,1}},
		
	};
	
	self.tbTowerCount		=				--双方炮台数量
	{
		["XIA"] 	= 2,
		["MENG"] 	= 2,
	};
	self.tbLongMaiLiveWL 	= 				--双方龙脉存活判断胜负
	{
		["XIA"] 	= 1,
		["MENG"]	= 1,
	};
	self.tbLongMaiLive 	= 					--双方龙脉存活小地图用
	{
		["XIA"] 	= {0},
		["MENG"]	= {0},
	};
	self.tbLongMaipNpcId	=				--龙脉NpcId
	{
		["XIA"]		= 0;
		["MENG"]	= 0;
	};
	self.tbTowerLive		=				--双方炮台存活
	{
		["XIA"] 	= {0, 0},
		["MENG"] 	= {0, 0},
	};
	self.tbArrowLive 		= 				--双方箭塔存活情况
	{
		["XIA"] 	= {0, 0, 0, 0, 0},
		["MENG"]	= {0, 0, 0, 0, 0},
	};
	self.tbCarLive 			= 				--双方Chiến Xa存活情况
	{
		["XIA"] 	= {0, 0, 0, 0, 0, 0, 0, 0},
		["MENG"] 	= {0, 0, 0, 0, 0, 0, 0, 0},
	};
	self.tbShouhuzheLive 			= 		--双方守护者存活情况
	{
		["XIA"] 	= {0},
		["MENG"] 	= {0},
	};
	self.tbShouhuzheShow			=		--守护者是否已刷
	{
		["XIA"] 	= 0,
		["MENG"] 	= 0,		
	};
	
	NewBattle.tbpNpcCars = 
	{
		["XIA"] 	= {},
		["MENG"]	= {},
	};
	--清空玩家信息表
	self.tbCPlayers = {};

	--清空攻击检测列表
	self.tbAttackCheak = {};

	self.nWiner		=	0;						--胜利者

	self:IniteUseNpcs();						--刷新功能NPC
	--
	--DEBUG BEGIN
	if NewBattle.__DEBUG then
	  	print("★★Mission Open");
	end
	--
	--DEBUG END

	self:GoNextState();
end

--把所有玩家都传出去
function tbMission:MoveAllPlayerOut(tbList)
	local tbPlayerList = tbList or self:GetPlayerList();
	for _, pPlayer in pairs(tbPlayerList) do
		if pPlayer.GetCarrierNpc() then		--下车
			pPlayer.LandOffCarrier();
		end
		--传出去
		NewBattle:MovePlayerOut(pPlayer, self:GetPlayerGroupId(pPlayer));
	end
	return 0;
end

--信息更新时钟
function tbMission:OnUpdateTime()
	self:OnUpdate();
	return NewBattle.UPDATE_TIME;
end

--更新数据
function tbMission:OnUpdate()
	if self:IsOpen() == 0 then
		return 0;
	end
	--更新所有玩家右侧信息
	self:UpdateAllRightUI();
	--更新小地图
	self:UpdateMiniMap();
	--排序
	self:SortPlayer();
	--更新战报
	self:UpdateReport();
end

--获得排行列表
function tbMission:GetRankList()
	local tbList = self:SortPlayer();
	local tbRankList = {};
	for n, tbData in ipairs(tbList) do
		tbRankList[n] = self.tbCPlayers[tbData.nPlayerId];
	end
	return tbRankList;

end
--排序
function tbMission:SortPlayer()
	self.tbReportPlayerList = {};
	local tbPlayers = self:GetPlayerList(0);
	if tbPlayers then
		for _, pPlayer in ipairs(tbPlayers) do
			local tbPlayer = self.tbCPlayers[pPlayer.nId];
			local szTongName = "Không có Bang";
			local nTongId = pPlayer.dwTongId;
			if nTongId > 0 then
				local pTong = KTong.GetTong(nTongId);
				if pTong then
					szTongName = pTong.GetName();	
				end
			end
			table.insert(self.tbReportPlayerList,
				 {
				 	nPlayerId		= pPlayer.nId,
				 	nCamp 			= tbPlayer.nGounpId, 
				 	szFaction 		= Lib:StrFillC(Player:GetFactionRouteName(pPlayer.nFaction, pPlayer.nRouteId), 10),
				 	szPlayerName 	= pPlayer.szName,
					szTong			= szTongName,
				 	nKillCount		= Lib:StrFillC(tbPlayer.nKillPlayerNum, 10),
					nMaxSeriesKill	= Lib:StrFillC(tbPlayer.nMaxSeriesKillNum, 10),
				 	nPoint			= math.floor(tbPlayer.nBouns),		
				 	bFirstBlood		= tbPlayer.bFristBlood,
				 });
		end
	end
	--根据个人分数排序
	table.sort(self.tbReportPlayerList,function(tbA,tbB) return tbA.nPoint > tbB.nPoint end);
	--排序后保存个人排名
	for n, tbData in ipairs(self.tbReportPlayerList) do 
		local tbPlayer = self.tbCPlayers[tbData.nPlayerId];
		tbPlayer.nRank = n;
	end
	return self.tbReportPlayerList;
end

-- 更新战报
function tbMission:UpdateReport()
	local tbPlayers = self:GetPlayerList(0);
	local tbTopReportPlayerList = {};
	for i = 1, 20 do		--只同步前20个
		tbTopReportPlayerList[i] = self.tbReportPlayerList[i];
	end
	local tbPlayerCount = 
	{
		[0] = 0,
		[1] = 0,
		[2] = 0,
	}
	tbPlayerCount[0] = self:GetPlayerCount(0);
	tbPlayerCount[1] = self:GetPlayerCount(1);
	tbPlayerCount[2] = self:GetPlayerCount(2);
	if tbPlayers then
		for _, pPlayer in ipairs(tbPlayers) do
			local tbPlayer = self.tbCPlayers[pPlayer.nId];
			local tbData = {tbPlayerList = tbTopReportPlayerList,tbPlayerInfo = {}};
			local tbPlayerInfo = tbData.tbPlayerInfo;
			tbPlayerInfo.szBattleName 		= "Băng Hỏa Liên Thành";
			tbPlayerInfo.nCamp				= tbPlayer.nGounpId;
			tbPlayerInfo.nBattleMode 		= 1;
			tbPlayerInfo.nMyCampNum 		= tbPlayerCount[tbPlayer.nGounpId];
			tbPlayerInfo.nEnemyCampNum 		= tbPlayerCount[0] - tbPlayerCount[tbPlayer.nGounpId];
			tbPlayerInfo.nKillPlayerNum		= tbPlayer.nKillPlayerNum;
			tbPlayerInfo.nKillPlayerPoint	= tbPlayer.nKillPlayerBouns
			tbPlayerInfo.nKillJianTaCount	= tbPlayer.tbKillNum.JIANTA;
			tbPlayerInfo.nKillJianTaPoint	= tbPlayer.tbKillPoint.JIANTA;
			tbPlayerInfo.nKillZhanCheCount	= tbPlayer.tbKillNum.ZHANCHE;
			tbPlayerInfo.nKillZhanChePoint	= tbPlayer.tbKillPoint.ZHANCHE;
			tbPlayerInfo.nKillPaoTaiCount	= tbPlayer.tbKillNum.PAOTAI;
			tbPlayerInfo.nKillPaoTaiPoint	= tbPlayer.tbKillPoint.PAOTAI;
			tbPlayerInfo.nDefPaoTaiPoint	= tbPlayer.tbDefPoint.PAOTAI;
			tbPlayerInfo.nDefShouHuzhePoint	= tbPlayer.tbDefPoint.SHOUHUZHE;
			tbPlayerInfo.nDefLongMaiPoint	= tbPlayer.tbDefPoint.LONGMAI;
			tbPlayerInfo.nPoint				= math.floor(tbPlayer.nBouns);
			tbPlayerInfo.nListRank			= tbPlayer.nRank;
			tbPlayerInfo.nMaxSeriesKill		= tbPlayer.nMaxSeriesKillNum;
			tbPlayerInfo.nSeriesKill		= tbPlayer.nSeriesKillNum;
			tbPlayerInfo.nBattleState		= NewBattle.nBattle_State;
			--tbPlayerInfo.nRemainTime		= Lib:TimeFullDesc(self:GetRemainTime());
			-- 不想模仿，但是没专门的接口啊- -
			pPlayer.CallClientScript({"me.SetCampaignDate", "newbattle_report", tbData, NewBattle.UPDATE_TIME});
		end
	end 
end

-- 

-- 广播消息给阵营
function tbMission:BroadCastMission(szMsg, nType, nGroupId)
	local nMsgType = nType or NewBattle.SYSTEM_CHANNEL_MSG;
	local nGroup = nGroupId or 0;
	local tbPlayers = self:GetPlayerList(nGroup);
	if tbPlayers then
		for _, pPlayer in ipairs(tbPlayers) do
			if pPlayer then
				NewBattle:SendMsg2Player(pPlayer, szMsg, nMsgType);
			end
		end
	end
end

--设置所有人的战场时钟
function tbMission:SetAllBattleTime(szMsg,nTime)
	local tbPlayerList = self:GetPlayerList();
	for _, pPlayer in ipairs(tbPlayerList) do
		Dialog:SetBattleTimer(pPlayer, szMsg, nTime);
	end
end

--设置所有人战斗状态
function tbMission:SetAllFightState(nState)
	local tbPlayerList = self:GetPlayerList();
	for _, pPlayer in ipairs(tbPlayerList) do
		pPlayer.SetFightState(nState)
	end
end

-- 开启右侧信息
function tbMission:OpenRightUI(pPlayer)
	if not pPlayer then
		return 0;
	end
	Dialog:SendBattleMsg(pPlayer, "", 1);
	Dialog:ShowBattleMsg(pPlayer, 1, 0)
end

-- 关闭信息界面
function tbMission:CloseRightUI(pPlayer)
	if not pPlayer then
		return 0;
	end
	Dialog:ShowBattleMsg(pPlayer, 0, 0);
end

-- 更新所有玩家右侧信息
function tbMission:UpdateAllRightUI()
	local tbPlayerList = self:GetPlayerList(0);
	for _, pPlayer in ipairs(tbPlayerList) do
		self:UpdateSingleRightUI(pPlayer);
	end
end

-- 更新一个玩家右侧信息
function tbMission:UpdateSingleRightUI(pPlayer)
	if not pPlayer then
		return 0;
	end
	local szMsg = "";
	if NewBattle.nBattle_State == NewBattle.BATTLE_STATES.SIGNUP then
		szMsg="<color=cyan>Hãy chuẩn bị cho cuộc đại chiến<color>";
	elseif  NewBattle.nBattle_State == NewBattle.BATTLE_STATES.FIGHT then
		szMsg = "Lỗi!";
		local tbPlayer = self.tbCPlayers[pPlayer.nId];
		local szPower = NewBattle.POWER_ENAME[tbPlayer.nGounpId];
		if tbPlayer then
			szMsg= string.format([[
				<color=green>Xếp hạng: <color><color=blue>%d<color>
				<color=green>Tích lũy cá nhân: <color><color=yellow>%d<color>
				<color=green>Hạ người chơi: <color><color=red>%d<color>
				]],
				tbPlayer.nRank,
				tbPlayer.nBouns,
				tbPlayer.nKillPlayerNum
			);
			for _, tbData in pairs(self.tbTip[szPower]) do
				szMsg = szMsg.."\n<color=cyan>"..NewBattle.TIPVALUE[tbData[1]][tbData[2]].."<color>";
			end
		end
	end	
	Dialog:SendBattleMsg(pPlayer, szMsg, 1);
	--Dialog:ShowBattleMsg(pPlayer, 1, 0)
end

-- 结束游戏
function tbMission:OnClose()
	--print("关闭MISSION")
	-- 按名次给奖励
	NewBattle.nBattle_State = NewBattle.BATTLE_STATES.CLOSED;
	ClearMapNpc(self.nMapId);
	if self.IsFighted == 1 then
		local tbPlayerReaultList	= self:GetRankList();
		-- 给好友，或家族，帮会成员发送信息
		self:SendMsgOther(tbPlayerReaultList);
		self:SetEventManager(tbPlayerReaultList);
		Battle:AwardPlayerList(tbPlayerReaultList, self.nLevel, 1);
		Battle:ProcessAchievement(tbPlayerReaultList, nWinCampId, self.nRuleType);
	end
	
	-- 数据埋点 结束角色信息  账号，角色，积分
	for _, tbPlayer in pairs(self.tbCPlayers) do
		local pPlayer = tbPlayer:GetPlayer();
		local nPlayerId = pPlayer and pPlayer.nId or 0;
		StatLog:WriteStatLog("stat_info", "ganluocheng", "join", nPlayerId, tbPlayer.nBouns);
	end	
	self:MoveAllPlayerOut();

end


-- 给好友，或家族，帮会成员发送信息
function tbMission:SendMsgOther(tbPlayerReaultList)
	local szMsg = "Hảo hữu [%s] đạt hạng %d trên Chiến Trường-Băng Hỏa Liên Thành";
	for n, tbPlayer in pairs(tbPlayerReaultList) do
		if (n >= 4) then
			break;
		end
		local pPlayer = tbPlayer.pPlayer;
		if (pPlayer) then
			local szFriendMsg = string.format(szMsg, pPlayer.szName, n);
			pPlayer.SendMsgToFriend(szFriendMsg);
			Player:SendMsgToKinOrTong(pPlayer, " đạt hạng ".. n .." trên Chiến Trường-Băng Hỏa Liên Thành", 0);
		end		
	end
end

-- 活动系统掉名次
function tbMission:SetEventManager(tbPlayerReaultList)	
	for n, tbPlayer in pairs(tbPlayerReaultList) do
		local pPlayer = tbPlayer.pPlayer;
		if (pPlayer) then			
			local _, tbFunExecute = SpecialEvent.ExtendAward:DoCheck("BattleFirst", pPlayer, n);
			SpecialEvent.ExtendAward:DoExecute(tbFunExecute);
		end		
	end
end


-- 玩家加入
function tbMission:OnJoin(nGroupId)
	--
	--DEBUG BEGIN
	if NewBattle.__DEBUG then
	  me.Msg(me.szName.." tham chiến.");
	end
	--
	--DEBUG END

	-- 仇杀、切磋
	me.ForbidEnmity(1);
	me.ForbidExercise(1);
	me.TeamApplyLeave();

	--开启右侧信息
 	self:OpenRightUI(me);
 		
	me.GetNpc().SetCampCustomRelation(1,NewBattle.FIGHT_RELATION.PLAYER);
	
	-- 添加称号
	me.AddTitle(2, nGroupId, 1, 0);

	-- 新建玩家CLASS
	if not self.tbCPlayers[me.nId] then
		self.tbCPlayers[me.nId] = Lib:NewClass(NewBattle.tbPlayerBase, me.nId, nGroupId, self);
	else
		self.tbCPlayers[me.nId].nGounpId = nGroupId;
	end
	
	local szMsg = "Mẹo, chọn cổ máy muốn thao tác, ấn <color=yellow>“N”<color> để thao tác."
	NewBattle:SendMsg2Player(me, szMsg, NewBattle.BOTTOM_BLACK_MSG);

	Dialog:SetBattleTimer(me, self.szRightTitle,self:GetRemainTime());
	me.SetTask(NewBattle.TK_PLAYERCARRIERSKILLS_TASKGROUP, NewBattle.TK_PLAYERISINNEWBATTLE, 1);
end

-- 获取剩余时间
function tbMission:GetRemainTime()
	if not self.tbNowStateTimer then
		return 0;
	end
	return self.tbNowStateTimer:GetRestTime();
end

-- 玩家离开
function tbMission:OnLeave(nGroupId, szReason)
	-- 自定义阵营
	me.nExtensionGroupId = 0;

	-- 仇杀、切磋
	me.ForbidEnmity(0);
	me.ForbidExercise(0);
	me.TeamApplyLeave();
	me.SetFightState(0);

	--关闭右侧界面
	self:CloseRightUI(me)
	
	--去除称号
	me.RemoveTitle(2, nGroupId, self.tbCPlayers[me.nId].nTitle, 0);
	me.SetTask(NewBattle.TK_PLAYERCARRIERSKILLS_TASKGROUP, NewBattle.TK_PLAYERISINNEWBATTLE, 0);
	
	--移出玩家
	NewBattle:PlayerLeave(me);
	
end

-- 初始化游戏
function tbMission:InitGame(nMapId, nLevel, szBattleTime, nSeqNum, nBattleSeq)
	self.tbNpcLevel			= NewBattle.BATTLE_NPCLEVEL[nLevel];
	self.nMapId				= nMapId;
	self.nLevel				= nLevel;
	self.nSeqNum			= nSeqNum;
	self.nBattleSeq			= nBattleSeq;
	self.szRightTitle		= "<color=green>Thời gian báo danh: <color><color=white>%s<color>\n";
	self.szBattleName 		= "Băng Hỏa Liên Thành";
	self.nBattleKey		= tonumber(szBattleTime..nBattleSeq..nSeqNum);
	local tbSongIcon 	= {"\\image\\ui\\001a\\main\\chatchanel\\chanel_song.spr", 	"\\image\\ui\\001a\\main\\chatchanel\\btn_chanel_song.spr"};
	local tbKingIcon	= {"\\image\\ui\\001a\\main\\chatchanel\\chanel_jin.spr",	"\\image\\ui\\001a\\main\\chatchanel\\btn_chanel_jin.spr"};
	local tbChannel		=
	{
		[Wldh.Battle.CAMPID_SONG]	= {string.format("Mông Cổ-%s %d", Battle.NAME_GAMELEVEL[self.nLevel], nSeqNum), 20, tbSongIcon[1], tbSongIcon[2]},
		[Wldh.Battle.CAMPID_JIN]	= {string.format("Tây Hạ-%s %d", Battle.NAME_GAMELEVEL[self.nLevel], nSeqNum), 20, tbKingIcon[1], tbKingIcon[2]},
	};
	self.tbMisCfg =
	{
		tbCamp				= {1, 2, 3},					-- 临时阵营
		nPkState			= Player.emKPK_STATE_CAMP,		-- PK状态
		tbChannel			= tbChannel,					-- 聊天频道
		nInBattleState		= 1,							-- 禁止不同阵营组队
		nDeathPunish		= 1,							-- 无死亡惩罚
		nOnDeath			= 1,							-- 玩家死亡回调
		nForbidStall		= 1,							-- 禁止摆摊
		nDisableOffer		= 1,							-- 禁止收购
		nDisableFriendPlane = 1,							-- 禁止好友界面
		nDisableStallPlane	= 1,							-- 禁止交易界面
		nDisableSeriesPK	= 1,							-- 关闭通用连斩
		nOnKillNpc			= 1,							-- 开启NPC死亡回调
	};

	-- 游戏阶段
	self.tbMisEventList =
	{
		{1, NewBattle.TIME_SIGN, "State_Fight"},			-- 报名准备阶段
		{2, NewBattle.TIME_FIGHT, "State_GameFinish"},		-- 战斗阶段
		{3, NewBattle.TIME_BOOM, "State_Boom"},				-- 爆机阶段

	};
	self:Open();
end

--战斗阶段
function tbMission:State_Fight()
	--
	--DEBUG BEGIN
	if NewBattle.__DEBUG then
	  print("Giai doan chien dau!");
	end
	--
	--DEBUG END

	local nXia = self:GetPlayerCount(1);
	local nMeng = self:GetPlayerCount(2);
	--如果人数不足以开启战场
	if nXia < NewBattle.MINPLAYER or nMeng < NewBattle.MINPLAYER then
		--跳到下一阶段
		self:BroadCastMission("Lực lượng không đủ, sau 10 giây sẽ được đưa trở về.", nil, 0)
		Timer:Register(10 * Env.GAME_FPS, NewBattle.CloseMission, NewBattle, self.nLevel, self.nSeqNum);
		return;
	end
	local tbPlayerList	= self:GetPlayerList();
	for _, pPlayer in pairs(tbPlayerList) do
		pPlayer.SetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_KEY, self.nBattleKey);
		pPlayer.SetTask(Battle.TSKGID, Battle.TASKID_BTCAMP, self:GetPlayerGroupId(pPlayer));		
		-- 记录玩家参加宋金战场的次数
		Stats.Activity:AddCount(pPlayer, Stats.TASK_COUNT_BATTLE, 1);
		local nTimes = pPlayer.GetTask(SpecialEvent.tbPJoinEventTimes.TASKGID, SpecialEvent.tbPJoinEventTimes.TASK_JOIN_BATTLE);
		pPlayer.SetTask(SpecialEvent.tbPJoinEventTimes.TASKGID, SpecialEvent.tbPJoinEventTimes.TASK_JOIN_BATTLE, nTimes + 1);
	end
	self:BroadCastMission("Chiến trường <color=yellow>Băng Hỏa Liên Thành<color> chính thức bắt đầu!", NewBattle.SYSTEMBLACK_MSG,0);
	self.IsFighted = 1;	--开启了战场
	self.szRightTitle		= "<color=green>Thời gian còn lại: <color><color=white>%s<color>\n";
	self:SetAllBattleTime(self.szRightTitle, NewBattle.TIME_FIGHT)
	NewBattle.nBattle_State = NewBattle.BATTLE_STATES.FIGHT;
	--初始化NPC
	self:IniteNpcs();
	
end
--战斗结束
function tbMission:State_GameFinish()
	--
	--DEBUG BEGIN
	if NewBattle.__DEBUG then
	  print("战斗结束");
	end
	--
	--DEBUG END
	self:AllCarrierLoadOff()
	self.szRightTitle = "<color=green>Trận chiến kết thúc: <color><color=white>%s<color>";
	self:SetAllBattleTime(self.szRightTitle, NewBattle.TIME_BOOM)
	self:SetAllFightState(0);
	NewBattle:CloseAllTimer();
	self.nWiner = self:WinOrLose()
	--胜负加分
	self:WinLostAddPoint();
	
	NewBattle.nBattle_State = NewBattle.BATTLE_STATES.FINISH;
	--GC公告天下
	GCExcute{"NewBattle:FinishFight_GC", self.nLevel, self.nWiner};
	local tbPlayerList = self:GetPlayerList();
	for _, pPlayer in ipairs(tbPlayerList) do
		pPlayer.CallClientScript({"UiManager:OpenWindow", "UI_NEWBATTLE"});
	end	
end

-- 全体下车
function tbMission:AllCarrierLoadOff()
	local tbPlayerList = self:GetPlayerList();
	for _, pPlayer in pairs(tbPlayerList) do
		if pPlayer.GetCarrierNpc() then		--下车
			pPlayer.LandOffCarrier();
		end
	end
end

--爆机阶段
function tbMission:State_Boom()
	--print("爆机")
	if self.nWiner == 1 or self.nWiner == 2 then
		self:BroadCastMission("Chiến lược gia <color=yellow>Băng Hỏa Liên Thành<color> chính là bạn!", NewBattle.SYSTEMBLACK_MSG,self.nWiner);
	end
	Timer:Register(2 * Env.GAME_FPS, NewBattle.CloseMission, NewBattle, self.nLevel, self.nSeqNum);
	
end

--胜负加分
function tbMission:WinLostAddPoint()
	if self.nWiner >= 3 then
		return;
	end
	local tbPlayers = self:GetPlayerList(0);
	for _, pPlayer in ipairs(tbPlayers) do
		self.tbCPlayers[pPlayer.nId]:WinLostAddPoint(self.nWiner);
	end
end


-- 死亡回调
function tbMission:OnDeath(pKillerNpc)
	if NewBattle.nBattle_State ~= NewBattle.BATTLE_STATES.FIGHT then
		return;
	end
	local pKiller = nil;
	--获取杀手
	if pKillerNpc then
		pKiller = pKillerNpc.GetPlayer();
	end
	if pKiller then
		self.tbCPlayers[me.nId]:AddBeenKill({self.tbCPlayers[pKiller.nId]});
		Merchant:TryGiveToken_Songjin_PLayer(pKiller, me.nId, self.tbCPlayers[me.nId].nTitle);
	else
		--如果是载具
		if pKillerNpc.IsCarrier() == 1 then
			
			--数据埋点 资源击杀玩家  账号(被杀)，角色(被杀)，资源模版ID
			StatLog:WriteStatLog("stat_info", "ganluocheng", "res_kill", me.nId, pKillerNpc.nTemplateId);
		
			local tbpPlayers = pKillerNpc.GetCarrierPassengers();
			local tbPlayers = {};
			for _, pPlayer in pairs(tbpPlayers) do
				table.insert(tbPlayers, self.tbCPlayers[pPlayer.nId]);
				Merchant:TryGiveToken_Songjin_PLayer(pPlayer, me.nId, self.tbCPlayers[me.nId].nTitle);
			end
			self.tbCPlayers[me.nId]:AddBeenKill(tbPlayers, 1);
		else
			self.tbCPlayers[me.nId]:AddBeenKill();
		end

	end
	--立刻复活
	me.SetFightState(0);
	me.ReviveImmediately(1);
	local nPower = self:GetPlayerGroupId(me);
	if not nPower then
		return;
	end
	--设置保护时间
	Player:AddProtectedState(me, NewBattle.PLAYERPROTECTEDTIME);

	--传送回复活点
	local tbPoint = NewBattle:GetRandomPoint(NewBattle.POS_READY[NewBattle.POWER_ENAME[nPower]]);
	--传送到一个随机出生点
	me.NewWorld(self.nMapId,unpack(tbPoint));

end


-- 杀NPC
function tbMission:OnKillNpc()
	self.tbCPlayers[me.nId]:OnKillNpc(him.nTemplateId);
	Merchant:TryGiveToken_Songjin(me, him.nTemplateId);
end

--NPC被击杀死亡处理
function tbMission:OnNpcDeath(szType, pKillerNpc, pNpc)
	--获取杀手
	local pKiller = nil;
	if pKillerNpc then
		pKiller = pKillerNpc.GetPlayer();
	end
	
	local tbInfo = pNpc.GetTempTable("Npc");
	local nLiveTime = Lib:GetLocalDayTime() - tbInfo.nAddTime;
	if pKiller then
		self.tbCPlayers[pKiller.nId]:KillNpc(szType, 1, 1,{self.tbCPlayers[pKiller.nId]});	
		--数据埋点 资源被消灭（玩家）  账号，角色，资源模版ID，存活时间
		StatLog:WriteStatLog("stat_info", "ganluocheng", "res_dead", pKiller.nId, pKillerNpc.nTemplateId, nLiveTime);
	else
		--如果是载具
		if pKillerNpc.IsCarrier() == 1 then
			--数据埋点 NULL NULL 资源被消灭（资源）  杀手资源模版ID，被杀资源模版ID，存活时间
			StatLog:WriteStatLog("stat_info", "ganluocheng", "res_dead", 0, pNpc.nTemplateId, pKillerNpc.nTemplateId, nLiveTime);	
			
			local tbpPlayers = pKillerNpc.GetCarrierPassengers();
			local tbPlayers = {};
			for _, pPlayer in pairs(tbpPlayers) do
				table.insert(tbPlayers, self.tbCPlayers[pPlayer.nId]);
			end
			--设置小队中第一个加分玩家，对阵营共享分进行不重复处理。
			local bFirstGet = 1;
			for _, tbPlayer in pairs(tbPlayers) do
				tbPlayer:KillNpc(szType, #tbPlayers, bFirstGet, tbPlayers);
				bFirstGet = 0;
			end
		end
	end
end

--刷新功能NPC
function tbMission:IniteUseNpcs()
	--刷召唤师
	for szPower,tbData in pairs(NewBattle.POS_ZHAOHUANSHI) do
		for n,tbPoint in pairs(tbData) do
			local pNpc = KNpc.Add2(NewBattle.ZHAOHUANSHI_ID,1, -1,self.nMapId, unpack(tbPoint));
			if pNpc then
				local tbInfo = pNpc.GetTempTable("Npc");
				tbInfo.nPower = NewBattle.POWER_NUM[szPower];
				tbInfo.nIo	  = n;		--内外
				--pNpc.SetVirtualRelation(Player.emKPK_STATE_CAMP, NewBattle.POWER_NUM[szPower]);
			end
		end
	end
	--刷新龙脉
	for szPower, nPower in pairs(NewBattle.POWER_NUM) do
		local pNpc = KNpc.Add2(NewBattle.LONGMAI_ID[szPower], self.tbNpcLevel.LONGMAI, 0, self.nMapId, NewBattle.POS_LONGMAI[szPower][1], NewBattle.POS_LONGMAI[szPower][2], 0, 1)
		if pNpc then
			-- 阵营为中立，不能被攻击
			pNpc.SetCurCamp(0);
			pNpc.SetCampCustomRelation(1,NewBattle.FIGHT_RELATION.LONGMAI);
			pNpc.AddLifePObserver(NewBattle.LONGMAIBLOODBIANSHEN);
			local tbInfo = pNpc.GetTempTable("Npc");
			tbInfo.nPower = nPower;
			tbInfo.szType = "LONGMAI";
			tbInfo.nAddTime = Lib:GetLocalDayTime();
			self.tbLongMaipNpcId[szPower] = pNpc.dwId;
			pNpc.AddSkillState(NewBattle.WUDITEXIAO[szPower], 20, 1, 60 * 60 * Env.GAME_FPS);
			pNpc.SetTitle("<color=yellow>"..NewBattle.POWER_CNAME[nPower].."-Long Mạch<color>");
			self:AddBeAttackCheak(pNpc);
			--NewBattle:AddTimer("DefLongMai"..szPower, NewBattle.DEFPOINTTIME, NewBattle.Mission.DefAddPoint,  NewBattle.Mission, "LONGMAI", tbInfo.nPower, pNpc.dwId);	
		end	
	end
	--刷BUFF NPC
	for szPower, tbData in pairs(NewBattle.POS_BUFFS) do
		for _, tbPos in ipairs(tbData) do
			local pNpc = KNpc.Add2(NewBattle.BUFF_ID[szPower], 1, 0, self.nMapId, tbPos[1], tbPos[2], 0, 1)
		end		
	end
end

--初始化所有NPC信息
function tbMission:IniteNpcs()
	--召唤石
	local  pNpc = KNpc.Add2(NewBattle.STONE_ID,self.tbNpcLevel.ZHAOHUANSHI, 0, self.nMapId, unpack(NewBattle.POS_CHUANSONGSTONE));
	if pNpc then
		pNpc.SetTitle("<color=white>Trung lập<color>");
		local tbInfo = pNpc.GetTempTable("Npc");
		tbInfo.nPower = 0;
		pNpc.SetCurCamp(3);
		--pNpc.SetVirtualRelation(Player.emKPK_STATE_CAMP,3);
		--pNpc.SetCampCustomRelation(1,NewBattle.FIGHT_RELATION.ZHAOHUANSHI);
	end

	--箭塔们
	for szPower,tbData in pairs(NewBattle.POS_JIANTA) do
		for n,tbPoint in ipairs(tbData) do
			pNpc = KNpc.Add2(NewBattle.JIANTA_ID[szPower], self.tbNpcLevel.JIANTA, 0,self.nMapId,unpack(tbPoint));
			if pNpc then
				pNpc.SetCampCustomRelation(1,NewBattle.FIGHT_RELATION.JIANTA);
				local tbInfo = pNpc.GetTempTable("Npc");
				tbInfo.nNum = n;
				tbInfo.nPower = NewBattle.POWER_NUM[szPower];
				tbInfo.nAddTime = Lib:GetLocalDayTime();
				pNpc.SetFightState(1);
				pNpc.SetCurCamp(NewBattle.POWER_NUM[szPower]);
				pNpc.szName = NewBattle.POWER_CNAME[tbInfo.nPower].."-Tiễn Tháp";
				self.tbArrowLive[szPower][n] = 1;
			end
		end
	end

	
	--战斗NPC们
	self:CallFightNpc();

	--启动Chiến Xa工厂计时器
	NewBattle:AddTimer("MakeCar",NewBattle.MAKECARTIME, self.MakeCars, self);

	--启动炮台刷新计时器
	NewBattle:AddTimer("PAOTAI",NewBattle.MAKEPAOTAI, self.MakePaoTai, self);
	
	--启动被攻击检测计时器
	NewBattle:AddTimer("BEATTACK",Env.GAME_FPS, self.BeAttackCheak, self);
end

--刷战斗NPC，小兵兵们
function tbMission:CallFightNpc()
	local tbPoses = Lib:LoadTabFile("\\setting\\mission\\newbattle\\newbattle_npc.txt");
	if not tbPoses then
		return;
	end
	for _, tbPos in ipairs(tbPoses) do
		local nPower = tonumber(tbPos.POWER);
		local szType = tbPos.TYPE;
		--print(NewBattle.FIGHTNPC_ID[nPower][szType], self.tbNpcLevel[szType], 0, self.nMapId, tbPos.POS_X, tbPos.POS_Y);
		local pNpc = KNpc.Add2(NewBattle.FIGHTNPC_ID[nPower][szType], self.tbNpcLevel[szType], 0, self.nMapId, tonumber(tbPos.POS_X), tonumber(tbPos.POS_Y), 1);
		--if pNpc then
			--pNpc.SetCurCamp(nPower);
		--end
	end
end

--炮台刷新计时器
function tbMission:MakePaoTai()
	for szPower,tbData in pairs(NewBattle.POS_PAOTAI) do
		for n,tbPoint in ipairs(tbData) do
			local pNpc = KNpc.Add2(NewBattle.PAOTAI_ID[szPower], self.tbNpcLevel.PAOTAI, 0, self.nMapId, unpack(tbPoint));
			if pNpc then
				pNpc.SetCampCustomRelation(1,NewBattle.FIGHT_RELATION.PAOTAI);
				local tbInfo = pNpc.GetTempTable("Npc");
				tbInfo.nNum = n;
				tbInfo.szType = "PAOTAI";
				tbInfo.nAddTime = Lib:GetLocalDayTime();
				self.tbTowerLive[szPower][n] = 1;
				pNpc.SetFightState(1);
				tbInfo.nPower = NewBattle.POWER_NUM[szPower];
				pNpc.SetCurCamp(NewBattle.POWER_NUM[szPower]);
				pNpc.szName = NewBattle.POWER_CNAME[tbInfo.nPower].."-Pháo Tháp";
				NewBattle:AddTimer("DefPaoTai"..szPower..n, NewBattle.DEFPOINTTIME, self.DefAddPoint, self, "PAOTAI", tbInfo.nPower, pNpc.dwId);
				self:AddBeAttackCheak(pNpc);
				self:AddTip(szPower, 3, 1);
				self:AddTip(szPower, 4, 1);
			end
		end
	end
	self:BroadCastMission("Pháo Tháp hai bên đã được làm mới.", NewBattle.BOTTOM_BLACK_MSG,0);
	return 0;
end

--Chiến Xa工厂
function tbMission:MakeCars()
	local tbPaoNumn =
	{
		["XIA"] 	= {};
	 	["MENG"] 	= {};
	};
	for n,value in pairs(self.tbCarLive.XIA) do
		if value == 0 then
			table.insert(tbPaoNumn.XIA, n);
		end
	end
	for n,value in pairs(self.tbCarLive.MENG) do
		if value == 0 then
			table.insert(tbPaoNumn.MENG, n);
		end
	end
	for szPower, tbN in pairs(tbPaoNumn) do
		if #tbN <= 3 then		--最多五辆
			return NewBattle.MAKECARTIME;
		end
		if #tbN > 0 then
			local n = tbN[MathRandom(1, #tbN)];
			local pNpc = KNpc.Add2(NewBattle.ZHANCHE_ID[szPower], self.tbNpcLevel.ZHANCHE, 0,self.nMapId, unpack(NewBattle.POS_ZHANCHE[szPower][n]));
			if pNpc then
				pNpc.SetCampCustomRelation(1,NewBattle.FIGHT_RELATION.ZHANCHE);	
				self.tbCarLive[szPower][n] = 1;
				local tbInfo = pNpc.GetTempTable("Npc");
				tbInfo.nPower = NewBattle.POWER_NUM[szPower];
				tbInfo.nNum = n;
				tbInfo.nAddTime = Lib:GetLocalDayTime();
				pNpc.SetFightState(1);
				pNpc.SetCurCamp(NewBattle.POWER_NUM[szPower]);
				pNpc.szName = NewBattle.POWER_CNAME[tbInfo.nPower].."-Chiến Xa";
				NewBattle:SaveCardwId(szPower, n, pNpc.dwId);
				local szMsg = string.format("Xuất hiện 1 <color=yellow>Chiến Xa<color> tại <pos=%d,%d,%d>",self.nMapId,unpack(NewBattle.POS_ZHANCHE[szPower][n]));
				self:BroadCastMission(szMsg,NewBattle.SYSTEM_CHANNEL_MSG, NewBattle.POWER_NUM[szPower]);
				self:BroadCastMission("Xuất hiện 1 <color=yellow>Chiến Xa<color> ở Đại Doanh!",NewBattle.BOTTOM_BLACK_MSG, NewBattle.POWER_NUM[szPower]);
				self:RemoveTip(szPower, 1, 2);
				self:AddTip(szPower, 1, 2);
			end
		end
	end
end

--胜负判断
function tbMission:WinOrLose()
	--没开战
	if self.IsFighted == 0 then
		return 3;
	end
	if self.tbLongMaiLiveWL.XIA + self.tbLongMaiLiveWL.MENG == 0 then
		--都没了- -肿么可能
		return 9;
	end
	if self.tbLongMaiLiveWL.XIA == 0 then
		return 2;		--金胜
	end
	if self.tbLongMaiLiveWL.MENG == 0 then
		return 1;		--宋胜
	end

	--[[龙脉安好时判断炮台数量，已取消
	if self.tbLongMaiLive.XIA[1] + self.tbLongMaiLive.XIA[1] == 2 then
		if self.tbTowerCount.XIA > self.tbTowerCount.MENG then
			return 1;	--宋胜
		end
		if self.tbTowerCount.XIA < self.tbTowerCount.MENG then
			return 2;	--金胜
		end
		if self.tbTowerCount.XIA == self.tbTowerCount.MENG then
			return 0;	--平局
		end
	end
	--]]

	return 0;			--平局
end

--炮台死亡
function tbMission:PaoTaiOnDeath(nNum, nPower)

	self.tbTowerCount[NewBattle.POWER_ENAME[nPower]] = self.tbTowerCount[NewBattle.POWER_ENAME[nPower]] - 1;
	self:BroadCastMission(NewBattle:GetColStr(NewBattle.POWER_CNAME[nPower].."-", nPower).."Pháo Tháp đã bị phá hủy!", NewBattle.SYSTEMBLACK_MSG,0);
	self.tbTowerLive[NewBattle.POWER_ENAME[nPower]][nNum] = 0;
	for szPower, n in pairs(self.tbTowerCount) do
		if n <= 0 and self.tbShouhuzheShow[szPower] == 0 then
			local pNpc = KNpc.Add2(NewBattle.SHOUHUZHE_ID[szPower], self.tbNpcLevel.SHOUHUZHE, -1,self.nMapId, unpack(NewBattle.POS_SHOUHUZHE[szPower]));
			if pNpc then				
				local tbInfo = pNpc.GetTempTable("Npc");
				tbInfo.nPower = nPower;
				tbInfo.nAddTime = Lib:GetLocalDayTime();
				pNpc.SetCurCamp(nPower);
				self.tbShouhuzheLive[szPower][1] = 1;
				self:BroadCastMission(NewBattle:GetColStr(NewBattle.POWER_CNAME[nPower].."-", nPower).."Pháo Tháp bị phá hủy, <color=red>Thủ Hộ Giả<color> xuất hiện", NewBattle.SYSTEMBLACK_MSG, 0);
				NewBattle:AddTimer("DefShouHuZhe"..szPower, NewBattle.DEFPOINTTIME, self.DefAddPoint, self, "SHOUHUZHE", tbInfo.nPower, pNpc.dwId);
				self.tbShouhuzheShow[szPower] = 1;
				self:AddTip(szPower, 3, 2);
				self:AddTip(NewBattle:GetEnemy(szPower), 4, 2);
			end
		end
	end
end

--复活箭塔
function tbMission:JianTaFuHuo(nNum, nPower)
	local szPower = NewBattle.POWER_ENAME[nPower];
	--print(NewBattle.JIANTA_ID[szPower],50, -1,self.nMapId, unpack(NewBattle.POS_JIANTA[szPower][nNum]));
	local pNpc = KNpc.Add2(NewBattle.JIANTA_ID[szPower],self.tbNpcLevel.JIANTA, 0,self.nMapId,unpack(NewBattle.POS_JIANTA[szPower][nNum]));
		if pNpc then
			pNpc.SetCampCustomRelation(1,NewBattle.FIGHT_RELATION.JIANTA);
			local tbInfo = pNpc.GetTempTable("Npc");
			tbInfo.nNum = nNum;
			tbInfo.nPower = nPower;
			tbInfo.nAddTime = Lib:GetLocalDayTime();
			pNpc.SetFightState(1);
			pNpc.SetCurCamp(nPower);
			pNpc.szName = NewBattle.POWER_CNAME[nPower].."-Tháp Tiễn";
			--pNpc.SetVirtualRelation(Player.emKPK_STATE_CAMP,nPower);
			NewBattle.Mission.tbArrowLive[szPower][nNum] = 1;
			local szMsg = string.format("Tại <pos=%d,%d,%d>, <color=yellow>Tiễn Tháp<color> đã được phục hồi.",self.nMapId,unpack(NewBattle.POS_JIANTA[szPower][nNum]));
			self:BroadCastMission(szMsg,NewBattle.SYSTEM_CHANNEL_MSG, nPower);
		end
	return 0;
end

--守护建筑加分
function tbMission:DefAddPoint(szType, nPower, dwId)
	local pNpc = KNpc.GetById(dwId);
	if not pNpc then
		return 0;
	end
	--取周围玩家
	local tbPlayerList = KNpc.GetAroundPlayerList(dwId, NewBattle.DEF_DIS);
	if tbPlayerList then
		for _, pPlayer in ipairs(tbPlayerList) do
			local nPlayerPower = self:GetPlayerGroupId(pPlayer);
			if nPlayerPower == nPower then
				local tbPlayer = self.tbCPlayers[pPlayer.nId];
				tbPlayer:DefNpc(szType);
			end
		end
	end
	return 	NewBattle.DEFPOINTTIME;
end

--更新小地图
function tbMission:UpdateMiniMap()
	if self:IsOpen() == 0 then
		return 0;
	end
	--同步同阵营信息
	SetMapHighLightPointEx(self.nMapId, 1, 12, NewBattle.UPDATE_TIME /  Env.GAME_FPS * 1000, 0, 1, 1);
	SetMapHighLightPointEx(self.nMapId, 1, 12, NewBattle.UPDATE_TIME /  Env.GAME_FPS * 1000, 0, 1, 2);
	--更新Chiến Xa位置数据
	NewBattle.tbPos_ZhanChe = {["XIA"] = {}, ["MENG"] = {}};
	for szPower, tbData in pairs(NewBattle.tbpNpcCars) do
		for n, nId in pairs(tbData) do
			if nId ~= 0 then
				local pNpc = KNpc.GetById(nId);
				if pNpc then
					local _, nPosX, nPosY = pNpc.GetWorldPos();
					NewBattle.tbPos_ZhanChe[szPower][n] = {nPosX, nPosY};
				end
			else
				NewBattle.tbPos_ZhanChe[szPower][n] = nil;
			end	
		end
	end
	--更新存活信息
	local tbMinPos = {};
	--箭塔 炮台 Chiến Xa 龙脉 守护者
	for m,tbConfig in ipairs(self.tbMiniMapConfig) do
		for szPower, tbData in pairs(self[tbConfig[1]]) do
			for nNum, nLive in ipairs(tbData) do
				if nLive == 1 then
					local tbPoint = NewBattle[tbConfig[2]][szPower];
					if type(tbPoint[nNum]) == "table" then
						tbPoint = tbPoint[nNum];
					end
					table.insert(tbMinPos, {m, szPower, tbPoint[1], tbPoint[2], nNum});
				end
			end
		end
	end
	
	--更新小地图标志	
	local tbPlayers = self:GetPlayerList(0);
	if tbPlayers then
		for _, pPlayer in ipairs(tbPlayers) do
			for n, tbData in ipairs(tbMinPos) do
				local tbMinConfig = self.tbMiniMapConfig[tbData[1]];
				local nPower = NewBattle.POWER_NUM[tbData[2]];
				local nAttackPic = nil;
				local BeAttack = nil;
				local tbPlayer = self.tbCPlayers[pPlayer.nId];
				if tbData[1] == 2 or tbData[1] == 3 then
					BeAttack = self:GetBeAttack(tbData[1], nPower, tbData[5]);
				end
				local nAttackPic = (BeAttack == 1) and 5 or nil;
				if tbMinConfig[6] == 1 then
					local szPlayerPower = NewBattle.POWER_ENAME[tbPlayer.nGounpId];
					if tbData[2] == szPlayerPower then
						pPlayer.SetHighLightPoint(tbData[3],tbData[4], nAttackPic or ((nPower == 1) and tbMinConfig[3] or tbMinConfig[4]),tonumber(n..nPower..tbData[1]),NewBattle.POWER_CNAME[nPower].."-"..tbMinConfig[5], NewBattle.UPDATE_TIME /  Env.GAME_FPS * 1000);
					end
				else
					pPlayer.SetHighLightPoint(tbData[3],tbData[4], nAttackPic or ((nPower == 1) and tbMinConfig[3] or tbMinConfig[4]),tonumber(n..nPower..tbData[1]),NewBattle.POWER_CNAME[nPower].."-"..tbMinConfig[5], NewBattle.UPDATE_TIME /  Env.GAME_FPS * 1000);
				end				
			end
			--召唤石
			local tbPic = 
			{
				[1] = 7,
				[2] = 8,
				[0] = 11;
			};
			pPlayer.SetHighLightPoint(NewBattle.POS_CHUANSONGSTONE[1],NewBattle.POS_CHUANSONGSTONE[2],tbPic[self.nTransStoneOwner],100,"Đá Triệu Hồi ("..NewBattle.POWER_CNAME[self.nTransStoneOwner]..")", NewBattle.UPDATE_TIME /  Env.GAME_FPS * 1000);
		end
	end
end

-- 龙脉爆机特效
function tbMission:Boom(szPower, pSkiller)
	self.nBoomRound = 0;
	NewBattle:AddTimer("Boom", 1, self.BoomTimer,self,szPower, pSkiller,10);
end

-- 龙脉爆机特效TIMER
function tbMission:BoomTimer(szPower, pSkiller, nRound)
	local nBoom = self.nBoom or 1;
	self.nBoom = nBoom;
	local nBoomRound = self.nBoomRound or 0;
	self.nBoomRound = nBoomRound;
	local tbP = NewBattle.POS_BOOM[szPower][nBoom];
	pSkiller.CastSkill(NewBattle.BOOM_ID, 1, tbP[1] * 32, tbP[2] * 32);	
	if self.nBoom < #NewBattle.POS_BOOM[szPower] then
		self.nBoom = self.nBoom + 1;	
	else
		self.nBoom = 1;
		self.nBoomRound = self.nBoomRound + 1;
	end
	if self.nBoomRound >= nRound then
		return 0;	
	end
	return;
end

--为某阵营增加提示
function tbMission:AddTip(szPower, nType, nP)
	local tbRule = 
	{
		[2] = 1,
		[3] = 1,
		[4] = 1,
	};
	if tbRule[nType] then
		self:RemoveTip(szPower, nType);
	end
	table.insert(self.tbTip[szPower], {nType, nP});
end
--为某阵营移除提示
function tbMission:RemoveTip(szPower, nType, nP)
	for n, tbData in ipairs(self.tbTip[szPower]) do
		if tbData[1] == nType and tbData[2] == (nP or tbData[2]) then
			table.remove(self.tbTip[szPower], n);
		end
	end
end

-- 被攻击检测
function tbMission:BeAttackCheak()
	for nId, tbNpc in pairs(self.tbAttackCheak) do
		local pNpc = KNpc.GetById(nId);
		if pNpc then
			local nPercent = (pNpc.nCurLife / pNpc.nMaxLife) * 100;
			if tbNpc.nOldPercent > nPercent then
				tbNpc.OnAttack = 1;
				self:BeAttackCallBack(pNpc, tbNpc);
			else
				tbNpc.OnAttack = 0;
			end
			tbNpc.nOldPercent = nPercent;
		else
			table.remove(self.tbAttackCheak, nId);
		end
	end
end
-- NPC加入被攻击检测
function tbMission:AddBeAttackCheak(pNpc)
	local tbInfo = pNpc.GetTempTable("Npc");	
	self.tbAttackCheak[pNpc.dwId] = {nOldPercent = 100, OnAttack = 0, nTime = 0, nNum = tbInfo.nNum or 1, szType = tbInfo.szType, nPower = tbInfo.nPower};
end

-- NPC被攻击回调
function tbMission:BeAttackCallBack(pNpc, tbNpc)
	local szName = "";	
	local szPos	= "";
	local nPass = Lib:GetLocalDayTime() - tbNpc.nTime;
	if nPass < NewBattle.BEATTACKTIME  then
		return;
	end
	tbNpc.nTime = Lib:GetLocalDayTime();
	if tbNpc.szType == "PAOTAI" then
		szName = "Pháo Tháp";
		local nMapId, nX, nY = pNpc.GetWorldPos();
		szPos = string.format("<pos=%d,%d,%d>", nMapId, nX, nY);
	end
	if tbNpc.szType == "LONGMAI" then
		szName = "Long Mạch";
	end
	local szMsg = string.format("<color=yellow>%s<color> phe ta bị tấn công, hãy nhanh chân đến %s cứu viện!", szName, szPos);
	self:BroadCastMission(szMsg,NewBattle.SYSTEM_CHANNEL_MSG, tbNpc.nPower);
end

function tbMission:GetBeAttack(m ,nPower, nNum)
	local szType = (m == 2) and "PAOTAI" or "LONGMAI";
	for _, tbNpc in pairs(self.tbAttackCheak) do
		if tbNpc.szType == szType and tbNpc.nPower == nPower and tbNpc.nNum == nNum then
			return tbNpc.OnAttack;
		end
	end
	return 0;
end
