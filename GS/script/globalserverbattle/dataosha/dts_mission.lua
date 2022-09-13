-- 文件名　：dts_mission.lua
-- 创建者　：zounan1@kingsoft.com
-- 创建时间：2009-10-30 11:48:45
-- 描  述  ：大逃杀mission
if (MODULE_GC_SERVER) then
	return 0;
end
Require("\\script\\globalserverbattle\\dataosha\\dts_def.lua");
-- 建立一个Mission类
local MissionBase = Mission:New();
DaTaoSha.GameMission = MissionBase;

-- 开启活动
-- 场地Id, 赛制等级
function MissionBase:Init(nMapId, nLevel)
	-- 设定可选配置项
	self.tbMisCfg	= {
		tbEnterPos		= {},					-- 进入坐标		
		nPkState		= Player.emKPK_STATE_BUTCHER, --屠杀模式
		nInLeagueState  = 1,
		nDeathPunish	= 1,
		nOnDeath 		= 1, 	-- 死亡脚本可用
		nOnKillNpc 		= 1,
		nButcheStamina  = 1,
		nForbidTeam		= 1,    --禁止组队
		nForbidSwitchFaction = 1, -- 禁止切换门派
		nForbidStall	= 1,    --禁止摆摊
	}
	self.nMapId = nMapId;
	self.nLevel = nLevel;
	self.tbMisEventList	= DaTaoSha.MIS_LIST;
	self.tbPlayers	 = {};
	self.tbGroups    = {};
	self.tbTimers	 = {};
	self.nStateJour  = 0;
	self.nGroupCount = 0;						--本场队伍数量(动态变化)
	self.nGroupMax	 = 0;						--本场最大队伍(固定)
	self.nIsGamOver  = 0;  						--游戏是否结束
	self.nIsFight    = 0; 						-- 玩家是否在战斗中
	self.nMonsterRefreshCount = 0;				--怪刷新了几次
	self.tbNpcId 	  = {}; 					--怪物ID表
	self.tbMerchantId = {}; 					--商人ID表
	self.tbRound1ChestsId   = {}; 				--宝箱ID表
--	self.tbGroupName  = {}; --存储各组的玩家名列表 不随玩家下线和离开MISSION而改变 用于 给队伍奖励 和 冠军广播 
--	self.tbPlayerEx   = {};  -- 玩家ID表作为索引  用于 查找玩家所在组 以及玩家在该MISSION中所得积分
--	self.tbLevelUpMgr = {};  -- 分帧处理升级事件
	
	self.nUiMsgState  = 0;
	self.nIsCamp	  = 0;
	
	self.tbBirthPoint = {};  -- 出生点 DaTaoSha.MACTH_BIRTH的拷贝
	for i , tbBirthPoint in ipairs(DaTaoSha.MACTH_BIRTH) do
		self. tbBirthPoint[i] = {};
		for nIndex, tbData in ipairs(tbBirthPoint) do
			self.tbBirthPoint[i][nIndex] = {};
			self.tbBirthPoint[i][nIndex][1] = tbData[1];
			self.tbBirthPoint[i][nIndex][2] = tbData[2];
		end
	end	
	for nIndex, tbBirthPoint in ipairs(self.tbBirthPoint) do
		Lib:SmashTable(tbBirthPoint);
	end
end

--开始比赛
function MissionBase:StartGame()
	self:GetReady();
	self:GoNextState();	
end

function MissionBase:OnJoin(nGroupId)	
	self.nGroupCount = #self.tbGroups;
	self.nGroupMax = self.nGroupCount;
	self.tbGroups[nGroupId].nLifeCount = (self.tbGroups[nGroupId].nLifeCount or 0) + 1;
	--self.tbPlayerEx[me.nId].nGroupId = nGroupId;
end


-- 当玩家离开Mission“后”被调用
function MissionBase:OnLeave(nGroupId, nState)	
	local tbPlayer , nCount  = self:GetPlayerList();	
	
	-- award --
	 local nAwardType = self.nRound;
	 if self.nIsGamOver ~= 0 and self.nIsCamp == 1 then
		nAwardType = 4;
	 end
	 --第三阶段没杀人的且不是冠军的，算第2阶段
	 if self.nRound == 3 and nAwardType ~= 4 and not self.tbGroups[nGroupId].nRound3KillCount then
	 	nAwardType = 2;
	end
	 
	 if DaTaoSha:IsPlayerDeath(me) == 0 then
		self.tbGroups[nGroupId].nLifeCount = self.tbGroups[nGroupId].nLifeCount - 1;
	elseif nAwardType == 4 then
		StatLog:WriteStatLog("stat_info", "dataosha", "save", me.nId, me.nTeamId);
	end
	 
	DaTaoSha:AddLadderScore_GS(me, nAwardType, self.tbGroups[nGroupId][me.szName] or 0);		--加积分
	DaTaoSha:AddGameResult_GS(me, nAwardType);		--加本场奖励
	
	--聊天设回来
	me.SetChannelState(-1, 0);
	
	--log
	local nWuQi, nFangJu, nShouShi = self:GetEquitInfo(me);
	local nLevelType = "kill";
	if nAwardType == 3 and self.nIsGamOver == 1 then
		nLevelType = "equal";
	elseif nAwardType == 4 then
		nLevelType = "win";
	end
	StatLog:WriteStatLog("stat_info", "dataosha", "state", me.nId, string.format("%s,%s,%s,%s,%s,%s", me.nTeamId, self.nRound, nLevelType, nWuQi, nFangJu, nShouShi));
	--Dbg:WriteLogEx(1, "dataosha", "state", me.szAccount, me.szName,	string.format("%s,%s,%s,%s,%s,%s", me.nTeamId, self.nRound, nLevelType, nWuQi, nFangJu, nShouShi));

	
	me.LeaveTeam(); --离队
	
	--刷新快捷键
	--me.SetTask(Item.TSKGID_SHORTCUTBAR, Item.TSKID_SHORTCUTBAR_FLAG, me.GetTask(DaTaoSha.TASKID_GROUP, DaTaoSha.TASKID_SHORTCUT1));
	--me.SetTask(FightSkill.TSKGID_LEFT_RIGHT_SKILL, FightSkill.TSKID_LEFT_RIGHT_SKILL, me.GetTask(DaTaoSha.TASKID_GROUP, DaTaoSha.TASKID_SHORTCUT2));
	--FightSkill:RefreshShortcutWindow(me);
	
	self:ClearPlayer(me);
	self:Transfer(me);
	if self.nIsGamOver ~= 0 then   --mission已经close了
		return;
	end
	me.Msg("Bạn và đồng đội đã thất bại. Hãy đến <color=yellow>Cô bé bán diêm<color> để nhận thưởng!");
	Dialog:SendBlackBoardMsg(me, "Bạn và đồng đội đã thất bại. Hãy tiếp tục cố gắng!");
	if self:GetPlayerCount(nGroupId) == 0  then
		self.nGroupCount = self.nGroupCount - 1;
	end
	--刷新BATTLE界面
	local szMsg = "";
	for nGroupId, tbData in ipairs(self.tbGroups) do
		if not tbData.nKillCount  then
			tbData.nKillCount = 0;
		end
		self:UpdateBattleMsgEx(nGroupId);
	end
	--判断比赛是否可以结束		
	if  self.nGroupCount < 2 then
		local nCampGroup = 1;
		for nGroupId, tbGroup in ipairs(self.tbGroups) do
			if tbGroup.n ~= 0 then
				nCampGroup = nGroupId;
				break;
			end
		end
		self:OnGameOverCamp(nCampGroup);
	end	
	--判断第一阶段是否可以结束
	if self.nIsFight == 1 and self.nIsGamOver == 0 then
		if self.nRound ~= 3 and self.nGroupCount <= DaTaoSha.DEF_ROUND_COUNTLIMIT[self.nRound] then
			self.nIsFight = 0;
			local nTime = self:GetStateLastTime();
			StatLog:WriteStatLog("stat_info", "dataosha", "waste_time", 0, string.format("%s,%s", self.nRound, math.floor((10 * 60 * 18 - nTime) / 18)))
			--Dbg:WriteLogEx(1, "dataosha", "waste_time", string.format("%s,%s", self.nRound, math.floor((10 * 60 * 18 - nTime) / 18)));
			self:GoNextState();
		end
	end
	
	--踢掉掉线导致队伍生命不足的队伍
	if DaTaoSha:IsPlayerDeath(me) == 0 then
		if self.tbGroups[nGroupId].nLifeCount <= 0 then
			local tbPlayer = self:GetPlayerList(nGroupId);
			for _, pPlayer in pairs(tbPlayer) do
				if pPlayer ~= me then
					self:KickPlayer(pPlayer, 0);
			 		pPlayer.Msg("Đã rời khỏi!");
			 	end
			end
		end
	end
	
	--关闭雪花效果
	me.CallClientScript({"DaTaoSha:CloseTimer"});
	me.CallClientScript({"DaTaoSha:RefreshShortcutWindow"});
end

--比赛结束 有冠军
function MissionBase:OnGameOverCamp(nGroupId)
	self.nIsGamOver = 1;
	self.nIsCamp	= 1;
	self:ClearNpc(self.tbNpcId); 	
	local szMsg2 = "Trận đấu kết thúc, xin chúc mừng bạn đã chiến thắng";
	self:BroadcastBlackBoardMsg(szMsg2);
	local szMsg3 = "Chúc mừng bạn và đồng đội. Hãy đến <color=yellow>Cô bé bán diêm<color> nhận thưởng!";
	self:BroadcastMsg(0, szMsg3, "Đội");
	self:SendBattleMsg2All("<color=green>Rời khỏi trong %s giây<enter>", DaTaoSha.TIME_GAMEOVER);
	self:Rest();	
	self:CreateTimer(Env.GAME_FPS * DaTaoSha.TIME_GAMEOVER, self.EndGame, self);		
--	Dbg:WriteLog("玩家 ", szName,"  获得了大逃杀冠军");
end

--比赛结束 没冠军
function MissionBase:OnGameOverNoCamp()
	if self.nIsGamOver ~= 0 then
		return 0;
	end
	self.nIsCamp	= 0;
	self.nIsGamOver = 1;
	self:BroadcastBlackBoardMsg("Vòng 3 kết thúc, không đội nào giành được Quán Quân.");
	local szMsg = "Giai đoạn 3 kết thúc. Hãy đến <color=yellow>Cô bé bán diêm<color> nhận thưởng!";
	self:BroadcastMsg(0, szMsg, "Đội");
	self:SendBattleMsg2All("<color=green>Rời khỏi trong %s giây<enter>", DaTaoSha.TIME_GAMEOVER);
	self:Rest();	
	self:CreateTimer(Env.GAME_FPS * DaTaoSha.TIME_GAMEOVER, self.EndGame, self);
	return 0;
end

-- 加入活动
function MissionBase:JoinGame(pPlayer, nGroup)
	self:JoinPlayer(pPlayer, nGroup);
end

-- 结束活动
function MissionBase:EndGame()
	self.nIsGameOver = 1;
	DaTaoSha:MissionClose(self.nLevel, self.nMapId);
	ClearMapNpc(self.nMapId);
	ClearMapObj(self.nMapId);
	self:Close();
	--DaTaoSha:OnRefreshLadder_GS();
	return 0;
end

function MissionBase:GetGameState()
	return self.nStateJour;
end

--消息显示:战场消息
function MissionBase:SendBattleMsg2All(szMsg, nTime)
	local tbPlayer = self:GetPlayerList();	
	for _, pPlayer in pairs(tbPlayer) do
		if nTime then
			Dialog:SetBattleTimer(pPlayer, szMsg, nTime*60*Env.GAME_FPS);
		else
			Dialog:SendBattleMsg(pPlayer, "");
		end
		Dialog:ShowBattleMsg(pPlayer, 1, 0);
	end
end

--显示杀人数 剩余队伍数等消息
function MissionBase:SendBattleMsg2Group(szMsg, nGroupId)
	local tbPlayer = self:GetPlayerList(nGroupId);
	for _ , pPlayer  in pairs(tbPlayer) do
		Dialog:SendBattleMsg(pPlayer, szMsg, 1);
	end	
end

function MissionBase:UpdateBattleMsg(pPlayer)
	local nGroupId = self:GetPlayerGroupId(pPlayer);
	if nGroupId == -1 then
		return;
	end
	local szMsg = string.format(DaTaoSha.MISSION_BATTLE_MSG, self.tbGroups[nGroupId].nLifeCount, self.nGroupCount, self.tbGroups[nGroupId].nKillCount or 0, self.tbGroups[nGroupId][pPlayer.szName] or 0);
	self:SendBattleMsg2Group(szMsg, nGroupId);
end

function MissionBase:UpdateBattleMsgEx(nGroupId)
	local szSateMsg = DaTaoSha.MISSION_UI_EXTEND_MSG[self.nUiMsgState] or "";
	if not nGroupId or nGroupId == 0 then		
		for nGroupId2, tbGroup in pairs(self.tbGroups) do
			if nGroupId2 > 0 then
				local tbPlayer = self:GetPlayerList(nGroupId2);
				for _, pPlayer in pairs(tbPlayer) do
					local szMsg = string.format(DaTaoSha.MISSION_BATTLE_MSG, self.tbGroups[nGroupId2].nLifeCount, self.nGroupCount, self.tbGroups[nGroupId2].nKillCount or 0, self.tbGroups[nGroupId2][pPlayer.szName] or 0);
					szMsg = szMsg..szSateMsg;
					Dialog:SendBattleMsg(pPlayer, szMsg, 1);
				end
			end
		end
	else
		local tbPlayer = self:GetPlayerList(nGroupId);		
		for _, pPlayer in pairs(tbPlayer) do
			local szMsg = string.format(DaTaoSha.MISSION_BATTLE_MSG, self.tbGroups[nGroupId].nLifeCount, self.nGroupCount, self.tbGroups[nGroupId].nKillCount or 0, self.tbGroups[nGroupId][pPlayer.szName] or 0);
			szMsg = szMsg..szSateMsg;
			Dialog:SendBattleMsg(pPlayer, szMsg, 1);
		end	
	end
end

--[[
function MissionBase:BroadcastMsg(nGroupId, szMsg, szName)
	self:_MustOpen();
	
	if (type(nGroupId) == "string") then
		szName		= szMsg;
		szMsg		= nGroupId;
		nGroupId	= 0;
	end
	local tbPlayer, nCount	= self:GetPlayerList(nGroupId);
	if (nCount > 0) then
		KDialog.Msg2PlayerList(tbPlayer, szMsg, szName or "系统");
	end
end
--]]
--消息显示:黑条消息  nGroupId 默认为0
function MissionBase:BroadcastBlackBoardMsg(szMsg, nGroupId)
	local tbPlayer = self:GetPlayerList(nGroupId);
	for _ , pPlayer  in pairs(tbPlayer) do
		Dialog:SendBlackBoardMsg(pPlayer, szMsg);
	end	
end	

--消息显示:电影模式  nGroupId 默认为0
function MissionBase:BroadcastMovie(szMovie, nGroupId)
	
	local tbPlayer = self:GetPlayerList(nGroupId);
	for _ , pPlayer  in pairs(tbPlayer) do
		Setting:SetGlobalObj(pPlayer);
		TaskAct:Talk(szMovie);
		Setting:RestoreGlobalObj();
	end	
end

--比赛开始的准备
function MissionBase:GetReady()
	self.nRound = 1;
	self:NewField(self.nRound);
	self:Rest();
	for nGroupId, tbGroup in pairs(self.tbGroups) do
		if nGroupId > 0 then
			self:RandomSeries(nGroupId);	--	随机五行	
			self:CreatTeam(nGroupId);      --组队
		end
	end
	self:SetPlayerState();
	Timer:Register(Env.GAME_FPS * 10, self.SetTeamChannel, self);
	self:AddMissionItem(); 
	self:BroadcastBlackBoardMsg( "Có 3 phút để chuẩn bị, vật phẩm cần thiết có trong hành trang.");
	self:SendBattleMsg2All("<color=green>Giai đoạn chuẩn bị.<enter>Thời gian còn lại: <color=white>%s<color><enter>", DaTaoSha.TIME_RELAX);
	self:UpdateBattleMsgEx(0);
	self:OpenXueHua();
end	

--开启雪花效果
function MissionBase:OpenXueHua()
	if DaTaoSha.bIsOpenXueHua ~= 1 then
		return;
	end
	local tbPlayer = self:GetPlayerList();	
	for _, pPlayer in pairs(tbPlayer) do
		pPlayer.CallClientScript({"DaTaoSha:OpenTimer"});
	end	
end

function MissionBase:Round1Start()
	if self.nIsGamOver ~= 0 then
		return 0;
	end
	self.nUiMsgState = self.nUiMsgState + 1;
	self.nRound = 1;
	self:BroadcastBlackBoardMsg("Vòng 1 bắt đầu, hãy cố gắng sống sót!");
	self:SendBattleMsg2All("<color=green>Giai đoạn 1<enter>Thời gian còn lại: <color=white>%s<color><enter>", DaTaoSha.TIME_ROUND1);
	self:UpdateBattleMsgEx(0);
	self:CheckLingpai();        -- 查看玩家是否用了令牌
	self:ClearChests();         
	self:StartPk();
	Timer:Register(Env.GAME_FPS * 60, self.Round1RefreshNpc, self);
	self:WriteLogInfo(1);                                    
end

function MissionBase:Round1Relax()
	if self.nIsGamOver ~= 0 then
		return 0;
	end
	self.nUiMsgState = self.nUiMsgState + 1;
	self:Rest();
	self:BroadcastBlackBoardMsg("Vòng 1 kết thúc, <color=yellow>Thương Nhân Vật Tư<color> cung cấp bảo vật xuất hiện!");
	self:SendBattleMsg2All("<color=green>Giai đoạn nghỉ ngơi 1.<enter>Thời gian còn lại: <color=white>%s<color><enter>", DaTaoSha.TIME_RELAX);
	self:UpdateBattleMsgEx(0);
	self:ClearNpc(self.tbNpcId);
	self:CallMerchant(1);
end

function MissionBase:Round2Start()
	if self.nIsGamOver ~= 0 then
		return 0;
	end
	self.nUiMsgState = self.nUiMsgState + 1;
	self.nRound = 2;
	self:ClearNpc(self.tbMerchantId);
	self:NewField(self.nRound);
	self:BroadcastBlackBoardMsg("Vòng 2 bắt đầu, hãy cố gắng sống sót!");
	self:SendBattleMsg2All("<color=green>Giai đoạn 2<enter>Thời gian còn lại: <color=white>%s<color><enter>", DaTaoSha.TIME_ROUND2);
	self:UpdateBattleMsgEx(0);
	self:StartPk();
	Timer:Register(Env.GAME_FPS * 60, self.Round2RefreshNpc, self);
	self:WriteLogInfo(2);
end

function MissionBase:Round2Relax()
	if self.nIsGamOver ~= 0 then
		return 0;
	end
	self.nUiMsgState = self.nUiMsgState + 1;
	self:BroadcastBlackBoardMsg("Vòng 2 kết thúc, <color=yellow>Thương Nhân Vật Tư<color> cung cấp bảo vật xuất hiện!");
	self:SendBattleMsg2All("<color=green>Giai đoạn nghỉ ngơi 2.<enter>Thời gian còn lại: <color=white>%s<color><enter>", DaTaoSha.TIME_RELAX);
	self:UpdateBattleMsgEx(0);
	self:Rest();
	self:ClearNpc(self.tbNpcId);
	self:CallMerchant(2);
end

function MissionBase:Round3Start()
	if self.nIsGamOver ~= 0 then
		return 0;
	end
	self.nUiMsgState = self.nUiMsgState + 1;
	self.nRound = 3;
	self:ClearNpc(self.tbMerchantId);
	self:NewField(self.nRound);
	self:BroadcastBlackBoardMsg("Vòng 3 bắt đầu, hãy hạ gục hết các đội còn lại!");
	self:SendBattleMsg2All("<color=green>Giai đoạn 3<enter>Thời gian còn lại: <color=white>%s<color><enter>", DaTaoSha.TIME_ROUND3);
	self:UpdateBattleMsgEx(0);
	self:StartPk();
	self:WriteLogInfo(2);
end

-- 设置pk状态
function MissionBase:StartPk()
	self.nIsFight = 1;
	local tbPlayer, nCount = self:GetPlayerList();
	for _, pPlayer in pairs(tbPlayer) do
		pPlayer.SetFightState(1);		
		pPlayer.SendSyncData();
	end
	return 0;
end

-- 设置休息状态
function MissionBase:Rest()
	self.nIsFight = 0;
	local tbPlayer, nCount = self:GetPlayerList();
	for _, pPlayer in pairs(tbPlayer) do
		pPlayer.SetFightState(0);
		if DaTaoSha:IsPlayerDeath(pPlayer) == 1 then	
			DaTaoSha:ClearPlayerDeath(pPlayer);
			local nGroupId = self:GetPlayerGroupId(pPlayer);
			if not nGroupId then
				print("Mission有问题");
				break;
			end		
			self.tbGroups[nGroupId].nLifeCount = self.tbGroups[nGroupId].nLifeCount +1;
		end		
	end
end

-- 第一轮刷怪
function MissionBase:Round1RefreshNpc()
	return self:__RefreshNpc(1);
end

-- 第二轮刷怪
function MissionBase:Round2RefreshNpc()
	return self:__RefreshNpc(2);
end

function MissionBase:__RefreshNpc(nRound)
	self.nMonsterRefreshCount = self.nMonsterRefreshCount + 1;
	if self.nMonsterRefreshCount >= DaTaoSha.MIS_MONSTER_REFRESH_COUNT or self.nIsFight == 0 then
		self.nMonsterRefreshCount = 0;
		return 0;
	end	
	for i = 1, #DaTaoSha.MACTH_MONSTER_TRAP[nRound] do		
		local pNpc = KNpc.Add2(DaTaoSha.NPC_ID, 120, -1, self.nMapId, DaTaoSha.MACTH_MONSTER_TRAP[nRound][i][1],DaTaoSha.MACTH_MONSTER_TRAP[nRound][i][2] );
		if pNpc then
			table.insert(self.tbNpcId, pNpc.dwId);
		end
	end
	return DaTaoSha.MIS_MONSTER_REFRESH_TIME  * 60 * Env.GAME_FPS;
end

function MissionBase:CheckLingpai()
	local tbPlayer = nil;
	for nGroupId, tbGroup in ipairs(self.tbGroups) do
		tbPlayer = self:GetPlayerList(nGroupId);
		for _ , pPlayer in pairs(tbPlayer) do
			self:ClearLingpai(pPlayer, 1);	 
		end
	end
end

function  MissionBase:NewField(nRound)
	local tbBirthPoint = self.tbBirthPoint[nRound];
	local nPos = 1;
	local nTmp = 1;
	for nGroupId, tbGroup in pairs(self.tbGroups) do
		if nGroupId > 0 then
			nTmp = nPos;
			if #tbBirthPoint < nPos then
				nTmp = MathRandom(1, #tbBirthPoint);			
			end
			local tbPlayer = self:GetPlayerList(nGroupId);
			for _, pPlayer in pairs(tbPlayer) do
				pPlayer.NewWorld(self.nMapId, tbBirthPoint[nTmp][1] , tbBirthPoint[nTmp][2]);				
				Player:AddProtectedState(pPlayer, DaTaoSha.TIME_PROTECT2);  --传送保护
			end
			nPos = nPos + 1;
		end
	end
end

function MissionBase:CallChests()
	if self.nIsGamOver ~= 0 then
		return 0;
	end
	self.nUiMsgState = 1;
	self:BroadcastBlackBoardMsg("Mở rương vật tư để đạo cụ hỗ trợ.", 0);
	local tbBirthPoint = self.tbBirthPoint[1];
	local pNpc = nil;
	for nId , tbPos in ipairs(tbBirthPoint) do
		if nId > self.nGroupMax then
			break;
		end
		if #self:GetPlayerIdList(nId) > 0 then
			pNpc = KNpc.Add2(DaTaoSha.CHESTS_ID, 1, -1, self.nMapId, tbPos[1], tbPos[2], 1, 2);	
			if  pNpc then
				pNpc.GetTempTable("Npc").tbGroup = self.tbGroups[nId];
				if self.tbGroups[nId].n > 0 then
					local pPlayer = KPlayer.GetPlayerObjById(self.tbGroups[nId][1]);
					if pPlayer then
						pNpc.szName = "Rương vật tư-"..pPlayer.szName;
					end
				end
				table.insert(self.tbRound1ChestsId, pNpc.dwId);
			end
		end
	end
	self:UpdateBattleMsgEx(0);
end

function MissionBase:ClearChests()
	local pNpc = nil;
	for _, dwId in ipairs(self.tbRound1ChestsId) do
		local pNpc = KNpc.GetById(dwId);
		if pNpc then
			pNpc.Delete();
		end
	end
end

function MissionBase:CallMerchant(nRound)
	for i = 1, #DaTaoSha.MACTH_MERCHANT_TRAP[nRound] do
		local pNpc = KNpc.Add2(DaTaoSha.MERCHANT_ID, 109, -1, self.nMapId, DaTaoSha.MACTH_MERCHANT_TRAP[nRound][i][1],DaTaoSha.MACTH_MERCHANT_TRAP[nRound][i][2] );
		if pNpc then
			table.insert(self.tbMerchantId, pNpc.dwId);
		end
	end
end

function MissionBase:ClearNpc(tbNpcId)
	for _, dwId in ipairs(tbNpcId) do
		local pNpc = KNpc.GetById(dwId);
		if pNpc then
			pNpc.Delete();
		end
	end
	tbNpcId = {};
end

--增加令牌和铜钱道具
function MissionBase:AddMissionItem()
	local tbPlayer, nCount = self:GetPlayerList();
	local pItem = nil;
	for _, pPlayer in pairs(tbPlayer) do
		pItem = pPlayer.AddItem(unpack(DaTaoSha.MONEY));  
		if pItem then
			pItem.Bind(1);
		end		
		pItem = pPlayer.AddItem(unpack(DaTaoSha.LingPai));
		if pItem then
			pItem.Bind(1);
		end
	end		
end

--清除背包上的令牌， nIsSelectFaction = 0表示清的时候不需要给角色设上门派， 1表示需要
function MissionBase:ClearLingpai(pPlayer, nIsSelectFaction)
	local tbFind = pPlayer.FindItemInBags(unpack(DaTaoSha.LingPai));	
	for nId , tbLingPai in pairs(tbFind) do
		if nIsSelectFaction == 1 and nId == 1 then
			local nSeries = self:GetPlayerSelecetSeries(pPlayer);
			if nSeries then
				self:SelectRoute(pPlayer, MathRandom(1,2));	
			else                                --给玩家随机选个职业及路线
				local tbSeries = self:GetGroupSeries(pPlayer);
				local nSeries = 0;
				for nS ,_ in pairs(tbSeries) do
					nSeries = nS;
				end	
				if nSeries ~= 0 then 					
					local nFaction = self:SelectSeries(pPlayer, nSeries);
					self:SelectRoute(pPlayer, MathRandom(1,2));
				end
			end	 
		end
		tbLingPai["pItem"].Delete(pPlayer);
 	end	
end

function MissionBase:ClearTongqianItem(pPlayer)
	local tbFind = pPlayer.FindItemInBags(unpack(DaTaoSha.MONEY));	
	for nId, tbTongqian in pairs(tbFind) do
		tbTongqian["pItem"].Delete(pPlayer);
	end	
end

function MissionBase:SetPlayerState()
	local tbPlayer = self:GetPlayerList();
	for _ , pPlayer in pairs(tbPlayer) do
		pPlayer.GetNpc().SetTrickName("Nhân vật thần bí");
		--只允许近聊
		pPlayer.SetChannelState(-1, 1);
		pPlayer.SetChannelState(7, 0);
		pPlayer.FightPowerEffect(0);		--战斗力无效
	end
end

function MissionBase:SetTeamChannel()
	local tbPlayer = self:GetPlayerList();
	for _ , pPlayer in pairs(tbPlayer) do
		pPlayer.CallClientScript({"SetCurrentChannelName", "Team"}); --将聊天栏设为队聊
	end	
	return 0;
end	

function MissionBase:ClearPlayer(pPlayer)
	pPlayer.ClearState(0, 0xffffffff, 0, 1); -- 清BUFF	
 	DaTaoSha:CloseSingleUi(pPlayer);		 -- 清界面
	pPlayer.GetNpc().SetTrickName("");
	pPlayer.CallClientScript({"SetCurrentChannelName", "NearBy"});  --将聊天栏改成近聊
	
	-- 删除身上物品	
	local tbBag = {
		Item.ROOM_EQUIP,	-- 装备着的
		Item.ROOM_EQUIPEX,	-- 装备切换空间
		Item.ROOM_MAINBAG,	-- 主背包			
		Item.ROOM_EXTBAG1,	-- 扩展背包1
		Item.ROOM_EXTBAG2,	-- 扩展背包2
		Item.ROOM_EXTBAG3,	-- 扩展背包3
		Item.ROOM_EXTBAGBAR,	-- 扩展背包放置栏
		};
	local tbEquit = {};
	local pItem = nil;
	for i = 1, #tbBag do 
		tbEquit = pPlayer.FindAllItem(tbBag[i]);	
		for _,nIndex in pairs(tbEquit) do 
			pItem = KItem.GetItemObj(nIndex);
			if pItem then
				pItem.Delete(pPlayer);
			end	
		end	
	end	
end

--添加秘籍
function MissionBase:AddMiji(pPlayer, nFactionId, nRoute)
	local tbEquip = DaTaoSha.EUQIP_ITEM[self.nLevel][nFactionId][nRoute][pPlayer.nSex];
	if (not tbEquip) then
		return;
	end
	for i = 1, 2 do
		local pMiji = pPlayer.AddItem(tbEquip[#tbEquip][1], tbEquip[#tbEquip][2], tbEquip[#tbEquip][3], tbEquip[#tbEquip][4] + i - 1); -- 中级秘籍(最后一个)
		if not pMiji then
			return;
		end
		if i == 2 then
			pPlayer.AutoEquip(pMiji);
		end
		pPlayer.UpdateBook(100,0);
		local tbSkill =	-- 秘籍所对应技能ID列表
		{
			pMiji.GetExtParam(17),
			pMiji.GetExtParam(18),
			pMiji.GetExtParam(19),
			pMiji.GetExtParam(20),
		};
	
		for _, nSkill in ipairs(tbSkill) do
			if nSkill and nSkill > 0 then
				pPlayer.AddFightSkill(nSkill, 10);	-- 角色没有秘籍对应的技能，则加上该技能
			end
		end		
	end
end

--给马
function MissionBase:AddHorse(pPlayer)
	local tbHorse = DaTaoSha.HORSE[self.nLevel];
	local pItem = pPlayer.AddItem(unpack(tbHorse[MathRandom(1, #tbHorse)]));
	if pItem then
		pItem.Bind(1);
		pPlayer.AutoEquip(pItem);	
	end	
end

-- 有玩家挂了
function MissionBase:OnDeath(pKillerNpc) 
	local nGroupId = self:GetPlayerGroupId(me);
	if nGroupId == -1 then
		return;
	end
	self.tbGroups[nGroupId].nLifeCount = self.tbGroups[nGroupId].nLifeCount - 1;
	local	szMsg = string.format("<color=yellow>%s<color> đã trọng thương!", me.szName);
	self:BroadcastMsg(nGroupId, szMsg, "Đội");	
	if self.tbGroups[nGroupId].nLifeCount <= 0 then
		local tbPlayer = self:GetPlayerList(nGroupId);
		local nValue = 0;
		local nCount = 0;
		DaTaoSha:SetPlayerDeath(me);
		for _, pPlayer in pairs(tbPlayer) do
			self:KickPlayer(pPlayer, 0);
		 	pPlayer.Msg("Tạm dừng cuộc chiến!");
		end
	else
		me.ReviveImmediately(1);
		self:SetPlayerDeath(me);
		self:BroadcastBlackBoardMsg(szMsg, nGroupId);
		self:UpdateBattleMsgEx(nGroupId);
	end
	--杀人者算人头
	local pKillerPlayer = pKillerNpc.GetPlayer();
	if  pKillerPlayer then
		local nKillerGroupId = self:GetPlayerGroupId(pKillerPlayer);
		if nKillerGroupId == -1 then
			return;
		end
		
		if not self.tbGroups[nKillerGroupId].nKillCount then --算人头
			self.tbGroups[nKillerGroupId].nKillCount = 1;
		else	
			self.tbGroups[nKillerGroupId].nKillCount = self.tbGroups[nKillerGroupId].nKillCount + 1;
		end
		--记录第三阶段是否杀过人，队伍
		if self.nRound == 3 and not self.tbGroups[nKillerGroupId].nRound3KillCount then			
			self.tbGroups[nKillerGroupId].nRound3KillCount = 1;			
		end
		
		if not self.tbGroups[nKillerGroupId][pKillerPlayer.szName] then	--记到个人头上
			self.tbGroups[nKillerGroupId][pKillerPlayer.szName] = 1;
		else
			self.tbGroups[nKillerGroupId][pKillerPlayer.szName] = self.tbGroups[nKillerGroupId][pKillerPlayer.szName] + 1;
		end
		self:UpdateBattleMsgEx(nKillerGroupId);		
		
		if self.nRound <= 2 then
			local tbPlayer = self:GetPlayerList(nKillerGroupId);
			for _, pPlayer in pairs(tbPlayer) do
				if DaTaoSha:IsPlayerDeath(pPlayer) == 0 then  
					local nCount = DaTaoSha.MIS_KILL_PLAYER_EARN;
					if pPlayer.nId == pKillerPlayer.nId then
						nCount = DaTaoSha.MIS_KILL_PLAYER_EARN_S;
					end
					local nAddCount = pPlayer.AddStackItem(DaTaoSha.MONEY[1],DaTaoSha.MONEY[2],DaTaoSha.MONEY[3],DaTaoSha.MONEY[4],nil, nCount);		
					if nAddCount == 0 then
						pPlayer.Msg("Hành trang đã đầy, không thể nhận thêm Hàn Vũ Phù Thạch!");
					end
				end
			end
			KTeam.Msg2Team(pKillerPlayer.nTeamId, string.format("<color=yellow>%s<color> hạ gục Người thần bí, mỗi thành viên nhận được %s Hàn Vũ Phù Thạch, và cho bản thân %s Hàn Vũ Phù Thạch, đồng đội trong khu an toàn không thể nhận!", pKillerPlayer.szName, DaTaoSha.MIS_KILL_PLAYER_EARN, DaTaoSha.MIS_KILL_PLAYER_EARN_S));
		end
	end		
end

-- 有npc挂了
function MissionBase:OnKillNpc()
	--me.DropRateItem(DaTaoSha.DROPRATE_PATH.szNpc_droprate, 1, -1, -1, him);
	local nGroupId = self:GetPlayerGroupId(me);
	if nGroupId == -1 then
		return;
	end
	local tbPlayer = self:GetPlayerList(nGroupId);
	for _, pPlayer in pairs(tbPlayer) do
		if DaTaoSha:IsPlayerDeath(pPlayer) == 0 then  
			local nAddCount = pPlayer.AddStackItem(DaTaoSha.MONEY[1],DaTaoSha.MONEY[2],DaTaoSha.MONEY[3],DaTaoSha.MONEY[4],nil,DaTaoSha.MIS_KILL_NPC_EARN);		
			if nAddCount == 0 then
				pPlayer.Msg("Hành trang đã đầy, không thể nhận thêm Hàn Vũ Phù Thạch!");
			end
		end
	end
	KTeam.Msg2Team(me.nTeamId,"<color=yellow>"..me.szName.."<color> hạ gục Cơ Quan Nhân, mỗi thành viên nhận được "..DaTaoSha.MIS_KILL_NPC_EARN.." Hàn Vũ Phù Thạch, đồng đội trong khu an toàn không thể nhận!");
end

--每个组都随机三个五行系
function MissionBase:RandomSeries(nGroupId)
	local tbRandomSeries = {1,2,3,4,5};
	local tbSelectSeries = {};
	local j = 1;
	for i = 1, 3 do
		j = MathRandom(1, #tbRandomSeries);
		tbSelectSeries[tbRandomSeries[j]] = 1;
		table.remove(tbRandomSeries, j);
	end
	self.tbGroups[nGroupId].tbSelectSeries = tbSelectSeries;
	return tbSelectSeries; 
end

--玩家选择了一个五行系
function MissionBase:SelectSeries(pPlayer, nSeries)
	local nGroupId = self:GetPlayerGroupId(pPlayer);
	if  nGroupId == -1 then
		return;
	end			
 	self.tbGroups[nGroupId].tbSelectSeries[nSeries] = nil;
 	if not self.tbGroups[nGroupId].tbSeries then
		self.tbGroups[nGroupId].tbSeries = {};
	end
	self.tbGroups[nGroupId].tbSeries[pPlayer.nId] = nSeries;
 	return self:RandomFaction(pPlayer,nGroupId, nSeries);  -- 随机选门派
end

--随机选择一个该系的门派 注意：返回的是该门派在该系中的索引 详见 dts_def.lua中的 DaTaoSha.FACTION
function MissionBase:RandomFaction(pPlayer, nGroupId, nSeries)
	local tbFaction = {};
	for i = 1, 3 do  -- 一个系最多三个门派
		if not DaTaoSha.FACTION[nSeries][i] then
			break;
		end
		if DaTaoSha.FACTION[nSeries][i].nSexLimit == -1 or 
		   DaTaoSha.FACTION[nSeries][i].nSexLimit == pPlayer.nSex then
			table.insert(tbFaction,i);
		end
	end	
	local nRandom = MathRandom(1, #tbFaction);
	if not self.tbGroups[nGroupId].tbFaction then
		self.tbGroups[nGroupId].tbFaction = {};
	end
	self.tbGroups[nGroupId].tbFaction[pPlayer.nId] = tbFaction[nRandom];
	--给队伍提示
	local szMsg = string.format("Người chơi <color=yellow>%s<color> chọn ngẫu nhiên <color=yellow>%s<color> và <color=yellow>%s<color>.",pPlayer.szName,DaTaoSha.FACTION[nSeries].szSeriesName, DaTaoSha.FACTION[nSeries][tbFaction[nRandom]].szFactionName);
	self:BroadcastMsg(nGroupId, szMsg, "Đội");
	pPlayer.Msg(szMsg);
	
	return tbFaction[nRandom];
end

--选择路线
function MissionBase:SelectRoute(pPlayer,nRoute)
	local nGroupId = self:GetPlayerGroupId(pPlayer);
	if  nGroupId == -1 then
		return;
	end
	local nSeries  = self.tbGroups[nGroupId].tbSeries[pPlayer.nId];
	local nFaction = self.tbGroups[nGroupId].tbFaction[pPlayer.nId];
	local nFactionId = DaTaoSha.FACTION[nSeries][nFaction].nFactionId;
	pPlayer.JoinFaction(nFactionId);
	pPlayer.SetCurCamp(1);          -- 设临时阵营 
	pPlayer.SetTask(1022,215,4095);	--设置110级技能变量
	local nAddPoint = Player:GetAddSkillPoint(DaTaoSha.DEF_MAXLEVEL[self.nLevel]);
	pPlayer.AddFightSkillPoint(nAddPoint);
	for nLevel=10, DaTaoSha.DEF_MAXLEVEL[self.nLevel], 10 do
		local nSkillId = Player:GetFactionRouteSkillId(nFactionId, nRoute, nLevel)
		local nPoint   = Player:GetSkillAutoPoint(DaTaoSha.DEF_MAXLEVEL[self.nLevel], nFactionId, nRoute, nLevel)
		
		pPlayer.LevelUpFightSkill(nRoute, nSkillId, nPoint);
		
		local nPosition = Player:GetShortcutAuto(DaTaoSha.DEF_MAXLEVEL[self.nLevel], nFactionId, nRoute, nLevel);
		if nPosition ~= 0 then
			FightSkill:SetShortcutSkill(pPlayer, nPosition, nSkillId);		--快捷键
		end
	end
	pPlayer.AddFightSkill(10, 20); -- 轻功
	Npc.tbMenPaiNpc:AddAngerMagic(pPlayer);  --怒气	
	
	-- 设置 左右快捷键 
	local nLeft  = Player:GetShortcutAuto(DaTaoSha.DEF_MAXLEVEL[self.nLevel], nFactionId, nRoute, "LeftSkill");
	local nRight = Player:GetShortcutAuto(DaTaoSha.DEF_MAXLEVEL[self.nLevel], nFactionId, nRoute, "RightSkill");
	local nSkillId = nil;
	if nLeft ~= 0 then
		nSkillId = Player:GetFactionRouteSkillId(nFactionId, nRoute, nLeft);
		if nSkillId ~= 0 then
			FightSkill:SaveLeftSkillEx(pPlayer, nSkillId);
		end
	end	
	if nRight ~= 0 then
		if nRight == -1 then
			nSkillId = 10;   -- -1表示轻功
		else
			nSkillId = Player:GetFactionRouteSkillId(nFactionId, nRoute, nRight);
		end
		if nSkillId ~= 0 then
			FightSkill:SaveRightSkillEx(pPlayer, nSkillId);
		end
	end
	
	--大红 大蓝 快捷键
	FightSkill:SetShortcutItem(pPlayer,1, DaTaoSha.MEDICINE_LIFE[self.nLevel]);
	FightSkill:SetShortcutItem(pPlayer,6, DaTaoSha.MEDICINE_MANA[self.nLevel]);
	
	--菜
	FightSkill:SetShortcutItem(pPlayer, 10, DaTaoSha.MEDICINE_CAI[self.nLevel]);
	
	--轻功
	FightSkill:SetShortcutSkill(pPlayer, 4, 10);
	
	FightSkill:RefreshShortcutWindow(pPlayer);	-- 要刷新快捷栏面板
	
	local tbEquip = DaTaoSha.EUQIP_ITEM[self.nLevel][nFactionId][nRoute][pPlayer.nSex];
	if (not tbEquip) then
		return;
	end
	for i = 1, #tbEquip - 1 do
		local tbTmp = {unpack(tbEquip[i])};
		tbTmp[6] = tbTmp[6] or DaTaoSha.ENHANCELEVEL;
		local pItem = pPlayer.AddItem(unpack(tbTmp));
		if pItem then
			pItem.Bind(1);
			pPlayer.AutoEquip(pItem);
		end
	end
	
	--披风
	local nParticularType =  (pPlayer.nSeries - 1) * 2 + pPlayer.nSex + 1;
	local pItem = pPlayer.AddItem(DaTaoSha.tbMantle[1], DaTaoSha.tbMantle[2], nParticularType, DaTaoSha.tbMantle[3]);
	if pItem then
		pItem.Bind(1);
		pPlayer.AutoEquip(pItem);
	end
	
	for i = 1, 3 do
		local pItem = pPlayer.AddItem(unpack(DaTaoSha.tbExbag_20Grid));
		if pItem then
			pItem.Bind(1);
		end
	end
	for i = 1, 3 do        --菜
		local pItem = pPlayer.AddItem(unpack(DaTaoSha.MEDICINE_CAI[self.nLevel]));
		if pItem then
			pItem.Bind(1);
		end
	end
	
	--药箱
	pPlayer.AddItem(unpack(DaTaoSha.YAOXIANG_LIFE[self.nLevel]));
	pPlayer.AddItem(unpack(DaTaoSha.YAOXIANG_MANA[self.nLevel]));
	pPlayer.AddItem(unpack(DaTaoSha.YAOXIANG_LM[self.nLevel]));
	
	
	self:AddMiji(pPlayer, nFactionId, nRoute);  --加秘籍
	self:AddHorse(pPlayer);
	--满血满魔
	pPlayer.RestoreLife();
	pPlayer.RestoreMana();
	pPlayer.RestoreStamina();
	
	--删除多余技能点
	pPlayer.AddFightSkillPoint(-pPlayer.nRemainFightSkillPoint);
	
	--给队伍提示
	local szMsg = string.format("Người chơi <color=yellow>%s<color> chọn <color=yellow>%s<color>",pPlayer.szName,DaTaoSha.FACTION[nSeries][nFaction][nRoute]);
	self:BroadcastMsg(nGroupId, szMsg, "Đội");
	return 1;
end

--返回玩家所在组还可以选择的五行系
function MissionBase:GetGroupSeries(pPlayer)
	local nGroupId = self:GetPlayerGroupId(pPlayer);
	if  nGroupId == -1 then
		return {};
	end
	return self.tbGroups[nGroupId].tbSelectSeries;
end

--得到玩家选择的五行系
function MissionBase:GetPlayerSelecetSeries(pPlayer)
	local nGroupId = self:GetPlayerGroupId(pPlayer);
	if  nGroupId == -1 then
		return;
	end
 	if not self.tbGroups[nGroupId].tbSeries  then
		return;
	end
	return self.tbGroups[nGroupId].tbSeries[pPlayer.nId];	
end

--得到玩家的门派
function MissionBase:GetPlayerFaction(pPlayer)
	local nGroupId = self:GetPlayerGroupId(pPlayer);
	if  nGroupId == -1 then
		return;
	end
 	if not self.tbGroups[nGroupId].tbFaction  then
		return;
	end
	return self.tbGroups[nGroupId].tbFaction[pPlayer.nId];	
end

function MissionBase:CreatTeam(nGroupId)
	local tbPlayer = self:GetPlayerIdList(nGroupId);
	local nCaptionId = 0;
	for i , nPlayerId in pairs(tbPlayer) do 
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			if i == 1 then				
				KTeam.CreateTeam(pPlayer.nId);	--建立队伍							
				nCaptionId = pPlayer.nId;	
		 	else
			 	KTeam.ApplyJoinPlayerTeam(nCaptionId, pPlayer.nId);	--加入队伍
			end					
			pPlayer.TeamDisable(1);
		end		
	end
end

function MissionBase:Transfer(pPlayer)
	Transfer:NewWorld2MyServer(pPlayer);
end
--[[
--分帧处理升级
function MissionBase:LevelUp_FPS()
	if #self.tbLevelUpMgr == 0 then
		return 0;
	end
	local nPlayerId = self.tbLevelUpMgr[#self.tbLevelUpMgr];
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	local nLevel  = DaTaoSha.DEF_MAXLEVEL[self.nLevel];
	if pPlayer and (self:GetPlayerGroupId(pPlayer) ~= -1) then	
		pPlayer.AddLevel(nLevel - pPlayer.nLevel);
		pPlayer.ResetFightSkillPoint();	-- 重置技能点
		pPlayer.UnAssignPotential();		-- 重置潜能点
		pPlayer.AddFightSkillPoint(-pPlayer.nRemainFightSkillPoint);	-- 清除技能点
		pPlayer.AddPotential(-pPlayer.nRemainPotential);	-- 清除潜能点
		pPlayer.JoinFaction(0);	-- 清除门派
		FightSkill:ClearShortcut(pPlayer, 1);	 --清快捷栏	
		pPlayer.SetTask(2,1,0);         --自动分配潜能点	
		pPlayer.AddFightSkillPoint(pPlayer.nLevel - 1);
		pPlayer.AddPotential(pPlayer.nLevel * 10);
		local pItem = nil;
		pItem = pPlayer.AddStackItem(DaTaoSha.MONEY[1], DaTaoSha.MONEY[2], DaTaoSha.MONEY[3], DaTaoSha.MONEY[4], nil, 5);  
		if pItem then
			pItem.Bind(1);
		end		
		pItem = pPlayer.AddItem(unpack(DaTaoSha.LingPai));
		if pItem then
			pItem.Bind(1);
		end				
	end
	self.tbLevelUpMgr[#self.tbLevelUpMgr] = nil;	
end
--]]


function MissionBase:SetPlayerDeath(pPlayer)
	local szMsg = "Bạn đã rất cố gắng. Nếu đồng đội sóng sót, bạn vẫn sẽ được đi tiếp.";
	pPlayer.Msg(szMsg);
	Dialog:SendBlackBoardMsg(pPlayer, szMsg);
	pPlayer.NewWorld(self.nMapId,1647,2891);
	pPlayer.SetFightState(0);
	DaTaoSha:SetPlayerDeath(pPlayer);
end

function MissionBase:WriteLogInfo(nFlag)
	local tbPlayer = self:GetPlayerList();	
	for _, pPlayer in pairs(tbPlayer) do
		if nFlag == 1 then
			local nType = pPlayer.GetTask(DaTaoSha.TASKID_GROUP, DaTaoSha.TASKID_SHORTCUT10);
			local szType = "";
			if nType and nType == 1 then
				szType = "one";
			elseif nType and nType == 2 then
				szType = "team";
			end
			StatLog:WriteStatLog("stat_info", "dataosha", "join", pPlayer.nId, string.format("%s,%s,%s,%s",  pPlayer.nTeamId, szType,  pPlayer.nFaction,  pPlayer.nRouteId));
			--Dbg:WriteLogEx(1, "dataosha", "join",  pPlayer.szAccount,  pPlayer.szName, string.format("%s,%s,%s,%s",  pPlayer.nTeamId, szType,  pPlayer.nFaction,  pPlayer.nRouteId));
		elseif nFlag == 2 then
			local nWuQi, nFangJu, nShouShi = self:GetEquitInfo(pPlayer);
			StatLog:WriteStatLog("stat_info", "dataosha", "state", pPlayer.nId, string.format("%s,%s,%s,%s,%s,%s", pPlayer.nTeamId, self.nRound - 1, "rest", nWuQi, nFangJu, nShouShi));
			--Dbg:WriteLogEx(1, "dataosha", "state",  pPlayer.szAccount,  pPlayer.szName,	string.format("%s,%s,%s,%s,%s", pPlayer.nTeamId, self.nRound - 1, "rest", nWuQi, nFangJu, nShouShi));	
		end
	end
end

function MissionBase:GetEquitInfo(pPlayer)
	local nWuQi = 0;
	local nFangJu = 0;
	local nShouShi = 0;
	local pEquipW = pPlayer.GetItem(Item.ROOM_EQUIP, 3, 0);
	if pEquipW and pEquipW.nEnhTimes - 10 > 0  then
		nWuQi = pEquipW.nEnhTimes - 10;
	end
	for i = 1,  3 do
		local pEquip = pPlayer.GetItem(Item.ROOM_EQUIP, i - 1, 0);	
		if pEquip and pEquip.nEnhTimes - 10 > 0  then
			nFangJu = nFangJu + pEquip.nEnhTimes - 10;
		end	
	end  	  
	for i = 4,  5 do
		local pEquip = pPlayer.GetItem(Item.ROOM_EQUIP, i, 0);
		if pEquip and pEquip.nEnhTimes - 10 > 0  then
			nFangJu = nFangJu + pEquip.nEnhTimes - 10;
		end
	end
	for i = 6,  9 do
		local pEquip = pPlayer.GetItem(Item.ROOM_EQUIP, i, 0);
		if pEquip and pEquip.nEnhTimes - 10 > 0  then
			nShouShi = nShouShi + pEquip.nEnhTimes - 10;
		end
	end
	return nWuQi, nFangJu, nShouShi;
end
