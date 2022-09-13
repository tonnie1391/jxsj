-------------------------------------------------------
-- 文件名　 : superbattle_mission.lua
-- 创建者　 : zhangjinpin@kingsoft
-- 创建时间 : 2011-06-02 15:33:15
-- 文件描述 :
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\globalserverbattle\\superbattle\\superbattle_def.lua");

local tbMission = SuperBattle.Mission or Mission:New();
SuperBattle.Mission = tbMission;

-- 开启游戏
function tbMission:OnOpen()
	self:GoNextState();
end

-- 结束游戏
function tbMission:OnClose()

	-- 将所有玩家传回英雄岛
	local tbPlayerList = self:GetPlayerList();
	for i, pPlayer in pairs(tbPlayerList) do
		Transfer:NewWorld2GlobalMap(pPlayer, SuperBattle.TRANS_POS);
	end
end

-- 玩家加入
function tbMission:OnJoin(nGroupId)

	-- 自定义阵营
	me.nExtensionGroupId = nGroupId;

	-- 仇杀、切磋
	me.ForbidEnmity(1);
	me.ForbidExercise(1);
	me.TeamApplyLeave();

	-- 第一次要初始化
	if not SuperBattle.tbPlayerData[me.szName] then
		-- 战斗数据
		SuperBattle:InitPlayer_GS(me.szName, nGroupId, Transfer:GetMyGateway(me));
		-- 参加次数
		local nAttDay = GetPlayerSportTask(me.nId, SuperBattle.GA_TASK_GID, SuperBattle.GA_TASK_DAY) or 0;
		local nAttCount = GetPlayerSportTask(me.nId, SuperBattle.GA_TASK_GID, SuperBattle.GA_TASK_COUNT) or 0;
		local nDate = tonumber(GetLocalDate("%Y%m%d"));
		if nAttDay < nDate then
			SetPlayerSportTask(me.nId, SuperBattle.GA_TASK_GID, SuperBattle.GA_TASK_DAY, nDate);
			nAttCount = 0;
		end
		SetPlayerSportTask(me.nId, SuperBattle.GA_TASK_GID, SuperBattle.GA_TASK_COUNT, nAttCount + 1);
		
		--数据修正
		local nGABoxCount = GetPlayerSportTask(me.nId, SuperBattle.GA_TASK_GID, SuperBattle.GA_TASK_BOX);
		local nBoxCount = me.GetTask(SuperBattle.TASK_GID, SuperBattle.TASK_BOX);
		if math.floor(nGABoxCount / 100) < nBoxCount then
			SetPlayerSportTask(me.nId, SuperBattle.GA_TASK_GID, SuperBattle.GA_TASK_BOX, nBoxCount*100);
		end
		
		local nTotalExp = GetPlayerSportTask(me.nId, SuperBattle.GA_TASK_GID, SuperBattle.GA_TASK_EXP) or 0;
		local nExp = me.GetTask(SuperBattle.TASK_GID, SuperBattle.TASK_EXP);
		if nTotalExp < nExp then
			SetPlayerSportTask(me.nId, SuperBattle.GA_TASK_GID, SuperBattle.GA_TASK_EXP, nExp);
		end
		--数据修正end
		
		-- statlog
		local nCurPower = Player.tbFightPower:GetFightPower(me);
		SuperBattle:StatLog("start", me.nId, SuperBattle:GetSession(), me.nFaction, me.nRouteId, SuperBattle:GetMantleLevel(me), me.GetHonorLevel(), nCurPower, nGroupId);
	end

	-- 增加头衔
	SuperBattle:AddPlayerTitle(me, nGroupId);

	-- 更新右侧信息
	local nRemainTime = self:GetRemainTime();
	self:OpenRightUI(me, self.szRightTitle, nRemainTime);
	self:UpdateSingleRightUI(me);

	-- 提示信息
	if self.nWarState <= SuperBattle.WAR_INIT then
		SuperBattle:SendMessage(me, SuperBattle.MSG_BOTTOM, "Trận chiến chưa bắt đầu, hãy kiên nhẫn chờ đợi!");
	else
		SuperBattle:SendMessage(me, SuperBattle.MSG_BOTTOM, "Trận chiến đã bắt đầu, hãy anh dũng tiến lên!");
	end
	
	-- balance
	if Newland:CheckIsBalance() == 1 then
		Newland:AddBalance(me);
	end
end

-- 获取剩余时间
function tbMission:GetRemainTime()
	local nRemainTime = 0;
	if self.nWarState == SuperBattle.WAR_INIT then
		nRemainTime = (self.nInitTime - GetTime() + SuperBattle.READY_TIME) * Env.GAME_FPS;
	elseif self.nWarState == SuperBattle.WAR_CAMPFIGHT then
		nRemainTime = (self.nCampFightTime - GetTime() + SuperBattle.CAMPFIGHT_TIME) * Env.GAME_FPS;
	elseif self.nWarState == SuperBattle.WAR_ADMIRAL then
		nRemainTime = (self.nAdmiralTime - GetTime() + SuperBattle.ADMIRAL_TIME) * Env.GAME_FPS;
	elseif self.nWarState == SuperBattle.WAR_MARSHAL then
		nRemainTime = (self.nMarshalTime - GetTime() + SuperBattle.MARSHAL_TIME) * Env.GAME_FPS;
	end
	return nRemainTime;
end

-- 玩家离开
function tbMission:OnLeave(nGroupId, szReason)

	-- 自定义阵营
	me.nExtensionGroupId = 0;

	-- 仇杀、切磋
	me.ForbidEnmity(0);
	me.ForbidExercise(0);
	me.TeamApplyLeave();

	-- 自定义头衔
	SuperBattle:RemovePlayerTitle(me, nGroupId);

	-- 关闭右侧界面
	self:CloseRightUI(me);
	
	-- 清除小地图
	SuperBattle:ClearMiniMap(me);
	
	-- balance
	if Newland:CheckIsBalance() == 1 then
		Newland:RemoveBalance(me);
	end
	
	me.SetHighLightPointEx(0, 0, 0, 0, 0);
	
	-- 删除buffer
	if me.GetSkillState(SuperBattle.DIE_BUFFER_ID) > 0 then
		me.RemoveSkillState(SuperBattle.DIE_BUFFER_ID);
	end
end

-- 初始化游戏
function tbMission:InitGame(nMapId)
	
	self.nMapId 			= nMapId
	self.nInitTime 			= GetTime();
	self.nEndTime 			= self.nInitTime + SuperBattle.READY_TIME + SuperBattle.CAMPFIGHT_TIME + SuperBattle.ADMIRAL_TIME + SuperBattle.MARSHAL_TIME;
	self.nWarState 			= SuperBattle.WAR_INIT;
	self.szRightTitle		= "<color=white>Thời gian chuẩn bị: %s<color>";

	self.tbMisCfg =
	{
		tbCamp				= {1, 2},						-- 临时阵营
		nPkState			= Player.emKPK_STATE_EXTENSION,	-- 自定义模式
		nInBattleState		= 1,							-- 禁止不同阵营组队
		nDeathPunish		= 1,							-- 无死亡惩罚
		nOnDeath			= 1,							-- 玩家死亡回调
		nForbidStall		= 1,							-- 禁止摆摊
		nDisableOffer		= 1,							-- 禁止收购
		nDisableFriendPlane = 1,							-- 禁止好友界面
		nDisableStallPlane	= 1,							-- 禁止交易界面
		nDisableSeriesPK	= 1,							-- 关闭通用连斩
	};

	-- 创建频道
	local tbSongIcon =
	{
		"\\image\\ui\\001a\\main\\chatchanel\\chanel_song.spr",
		"\\image\\ui\\001a\\main\\chatchanel\\btn_chanel_song.spr"
	};
	local tbJinIcon	=
	{
		"\\image\\ui\\001a\\main\\chatchanel\\chanel_jin.spr",
		"\\image\\ui\\001a\\main\\chatchanel\\btn_chanel_jin.spr"
	};

	self.tbMisCfg.tbChannel =
	{
		[1] = {"Mông Cổ", 20, tbSongIcon[1], tbSongIcon[2]},
		[2] = {"Tây Hạ", 20, tbJinIcon[1], tbJinIcon[2]},
	};
	
	-- 游戏阶段
	self.tbMisEventList =
	{
		{1, SuperBattle.READY_TIME * Env.GAME_FPS, "State_CampFight"},		-- 准备阶段
		{2, SuperBattle.CAMPFIGHT_TIME * Env.GAME_FPS, "State_Admiral"},	-- 营地阶段
		{3, SuperBattle.ADMIRAL_TIME * Env.GAME_FPS, "State_Marshal"},		-- 将军阶段
		{4, SuperBattle.MARSHAL_TIME * Env.GAME_FPS, "State_EndGame"},		-- 元帅阶段
	};

	self:Open();
end

-- 营地争夺阶段
function tbMission:State_CampFight()

	self.nCampFightTime		= GetTime();
	self.nWarState 			= SuperBattle.WAR_CAMPFIGHT;
	self.szRightTitle 		= "<color=white>Thời gian đoạt kỳ: %s<color>";

	-- 刷旗子
	for i, tbInfo in pairs(SuperBattle.POLE_POS) do
		local nMapX, nMapY = unpack(tbInfo.tbPos);
		SuperBattle:AddPole(tbInfo.tbCamp[tbInfo.nOrgCamp], self.nMapId, nMapX, nMapY, tbInfo.nOrgCamp, i);
	end

	-- 刷将军
	for nCamp, tbInfo in pairs(SuperBattle.ADMIRAL_POS) do
		for _, tbCamp in pairs(tbInfo) do
			local nMapX, nMapY = unpack(tbCamp.tbPos);
			SuperBattle:AddAdmiral(tbCamp.nStand, self.nMapId, nMapX, nMapY, nCamp);
		end
	end

	-- 刷元帅
	for nCamp, tbInfo in pairs(SuperBattle.MARSHAL_POS) do
		local nMapX, nMapY = unpack(tbInfo.tbPos);
		SuperBattle:AddMarshal(tbInfo.nStand, self.nMapId, nMapX, nMapY, nCamp);
	end

	-- 开启一次右边的界面
	local tbPlayerList = self:GetPlayerList();
	for _, pPlayer in pairs(tbPlayerList) do
		self:OpenRightUI(pPlayer, self.szRightTitle, self:GetRemainTime());
	end
	
	local szMsg = "Chiến trường đã mở, giai đoạn đoạt kỳ bắt đầu!";
	self:BroadCastMission(SuperBattle.MSG_BOTTOM, szMsg);
	self:BroadCastMission(SuperBattle.MSG_CHANNEL, szMsg);
end

-- 将军护卫阶段
function tbMission:State_Admiral()

	self.nAdmiralTime		= GetTime();
	self.nWarState 			= SuperBattle.WAR_ADMIRAL;
	self.szRightTitle 		= "<color=white>Thời gian bảo vệ: %s<color>";

	SuperBattle:ClearAdmiral();

	-- 刷将军
	for nCamp, tbInfo in pairs(SuperBattle.ADMIRAL_POS) do
		for _, tbCamp in pairs(tbInfo) do
			local nMapX, nMapY = unpack(tbCamp.tbPos);
			SuperBattle:AddAdmiral(tbCamp.nFight, self.nMapId, nMapX, nMapY, nCamp, 1);
		end
	end

	-- 开启一次右边的界面
	local tbPlayerList = self:GetPlayerList();
	for _, pPlayer in pairs(tbPlayerList) do
		self:OpenRightUI(pPlayer, self.szRightTitle, self:GetRemainTime());
	end
	
	local szMsg = "Tướng lĩnh đã xuất chiến, hộ tống để tiêu diệt kẻ địch.";
	self:BroadCastMission(SuperBattle.MSG_BOTTOM, szMsg);
	self:BroadCastMission(SuperBattle.MSG_CHANNEL, szMsg);
end

-- 元帅护卫阶段
function tbMission:State_Marshal()

	self.nMarshalTime		= GetTime();
	self.nWarState 			= SuperBattle.WAR_MARSHAL;
	self.szRightTitle 		= "<color=white>Thời gian còn lại: %s<color>";

	SuperBattle:ClearMarshal();

	-- 刷元帅
	for nCamp, tbInfo in pairs(SuperBattle.MARSHAL_POS) do
		local nMapX, nMapY = unpack(tbInfo.tbPos);
		SuperBattle:AddMarshal(tbInfo.nMove, self.nMapId, nMapX, nMapY, nCamp, 1, 1);
	end

	-- 开启一次右边的界面
	local tbPlayerList = self:GetPlayerList();
	for _, pPlayer in pairs(tbPlayerList) do
		self:OpenRightUI(pPlayer, self.szRightTitle, self:GetRemainTime());
	end
	
	local szMsg = "Nguyên Soái song phương xuất trận, hãy chiến đấu đến cùng!";
	self:BroadCastMission(SuperBattle.MSG_BOTTOM, szMsg);
	self:BroadCastMission(SuperBattle.MSG_CHANNEL, szMsg);
end

-- 游戏结束
function tbMission:State_EndGame()

	-- 胜负阵营
	local nWinner = 0;
	if SuperBattle.tbCampData[1].nPoint > SuperBattle.tbCampData[2].nPoint then
		nWinner = 1;
	elseif SuperBattle.tbCampData[1].nPoint < SuperBattle.tbCampData[2].nPoint then
		nWinner = 2;
	end

	-- 放大积分
	local nRate = 0;
	local tbPlayerList = self:GetPlayerList();
	for _, pPlayer in pairs(tbPlayerList) do
		local nCamp = self:GetPlayerGroupId(pPlayer);
		if nWinner == 0 then
			nRate = 0.1;
		elseif nWinner == nCamp then
			nRate = 0.15;
		else
			nRate = 0.05;
		end
		local nPoint = SuperBattle:GetPlayerTypeData(pPlayer, "nPoint");
		SuperBattle:AddPlayerPoint(pPlayer, math.floor(nPoint * nRate));
	end

	-- 结束通告
	local szMsg = "Chiến trường Thái Thạch Cơ kết thúc, ";
	if nWinner == 0 then
		szMsg = string.format("%s bất phân thắng bại", szMsg);
	else
		szMsg = string.format("%s phe %s dành chiến thắng!", SuperBattle:GetCampName(nWinner), szMsg);
	end
	
	self:BroadCastMission(SuperBattle.MSG_BOTTOM, szMsg);
	self:BroadCastMission(SuperBattle.MSG_CHANNEL, szMsg);
	SuperBattle:StopGame_GS(nWinner);
	
	return 0;
end

-- 死亡回调
function tbMission:OnDeath(pKillerNpc)

	-- 获得阵营
	local nCamp = self:GetPlayerGroupId(me);

	-- 获得击杀者
	local pKiller = pKillerNpc.GetPlayer();
	if pKiller then

		-- 判断披风
		local nMantleLevel = SuperBattle:GetMantleLevel(me);
--		if nMantleLevel >= SuperBattle.MANTLE_LEVEL then

			-- 击杀回调
			SuperBattle:OnKillPlayer(pKiller, me);

			-- 披风路线log
			Dbg:WriteLog("SuperBattle", "Mông Cổ-Tây Hạ LSV",
				string.format("Người hạ gục: %s, Phi phong: %s, Môn phái: %s, Phe: %s", pKiller.szName, SuperBattle:GetMantleLevel(pKiller), pKiller.nFaction, pKiller.nRouteId),
				string.format("Người bị hạ: %s, Phi phong: %s, Môn phái: %s, Phe: %s", me.szName, nMantleLevel, me.nFaction, me.nRouteId)
			);

			SuperBattle:StatLog("kill", me.nId, SuperBattle:GetSession(), me.GetHonorLevel(), nMantleLevel, me.nFaction, me.nRouteId,
				pKiller.szName, pKiller.GetHonorLevel(), SuperBattle:GetMantleLevel(pKiller), pKiller.nFaction, pKiller.nRouteId);
--		end
	end
	
	me.ReviveImmediately(1);
	me.SetFightState(0);
	local nRand = MathRandom(1, #SuperBattle.CAMP_POS[nCamp]);
	local nMapX, nMapY = unpack(SuperBattle.CAMP_POS[nCamp][nRand]);
	me.NewWorld(self.nMapId, nMapX, nMapY);
end

-- 广播消息
function tbMission:BroadCastMission(nType, szMsg)
	local tbPlayerList = self:GetPlayerList();
	for _, pPlayer in pairs(tbPlayerList) do
		SuperBattle:SendMessage(pPlayer, nType, szMsg);
	end
end

-- 更新小地图
function tbMission:UpdateMiniMap()
	local tbPlayerList = self:GetPlayerList();
	for _, pPlayer in pairs(tbPlayerList) do
		SuperBattle:OnUpdateMiniMap(pPlayer);
	end
end

-- 更新头衔
function tbMission:UpdatePlayerRank()
	local tbPlayerList = self:GetPlayerList();
	for _, pPlayer in pairs(tbPlayerList) do
		local nCamp = self:GetPlayerGroupId(pPlayer);
		SuperBattle:AddPlayerTitle(pPlayer, nCamp);
	end
end

-- 更新所有玩家右侧信息
function tbMission:UpdateAllRightUI()
	local tbPlayerList = self:GetPlayerList();
	for _, pPlayer in pairs(tbPlayerList) do
		self:UpdateSingleRightUI(pPlayer);
	end
end

-- 开启右侧信息
function tbMission:OpenRightUI(pPlayer, szTitle, nRemainFrame)
	if not pPlayer then
		return 0;
	end
	Dialog:SetBattleTimer(pPlayer, szTitle, nRemainFrame);
	local szMsg = string.format("\n<color=green>Chiến tích cá nhân: <color=yellow>%s\n<color=green>Xếp hạng cá nhân: <color=yellow>%s\n<color=green>Hạ gục: <color=yellow>%s<color>\n", 0, 0, 0);
	if pPlayer.GetTask(1022, 233) == 1 then
		szMsg = string.format("%s\n<color=white>[Thái Thạch Cơ-Anh Hùng Lộ]\n\n<color=yellow>Đoạt chiến kỳ\nĐạt 1500 chiến tích\nHoàn thành chiến dịch\n", szMsg);
	elseif pPlayer.GetTask(1022, 234) == 1 then
		szMsg = string.format("%s\n<color=white>[Thái Thạch Cơ-Bách Xích Cân Đầu]\n\n<color=yellow>Chiến thắng trở về\n", szMsg);
	end
	Dialog:SendBattleMsg(pPlayer, szMsg, 1);
	Dialog:ShowBattleMsg(pPlayer, 1, 0);
end

-- 关闭信息界面
function tbMission:CloseRightUI(pPlayer)
	if not pPlayer then
		return 0;
	end
	Dialog:ShowBattleMsg(pPlayer, 0, 0);
end

-- 更新右侧信息
function tbMission:UpdateSingleRightUI(pPlayer)
	if not pPlayer then
		return 0;
	end
	local tbPlayerData = SuperBattle:GetPlayerData(pPlayer);
	if not tbPlayerData then
		return 0;
	end
	local szMsg = string.format("\n<color=green>Chiến tích cá nhân: <color=yellow>%s\n<color=green>Xếp hạng cá nhân: <color=yellow>%s\n<color=green>Hạ gục: <color=yellow>%s<color>\n", tbPlayerData.nPoint, tbPlayerData.nSort, tbPlayerData.nKillCount);
	if pPlayer.GetTask(1022, 233) == 1 then
		szMsg = string.format("%s\n<color=white>[Thái Thạch Cơ-Anh Hùng Lộ]\n\n<color=yellow>Đoạt chiến kỳ\nĐạt 1500 chiến tích\nHoàn thành chiến dịch\n", szMsg);
	elseif pPlayer.GetTask(1022, 234) == 1 then
		szMsg = string.format("%s\n<color=white>[Thái Thạch Cơ-Bách Xích Cân Đầu]\n\n<color=yellow>Chiến thắng trở về\n", szMsg);
	end
	Dialog:SendBattleMsg(pPlayer, szMsg, 1);
end

-- 每隔5秒更新战报
function tbMission:TimerSyncReportData()

	local tbCampSongData = SuperBattle:GetCampData(1);
	local tbCampJinData = SuperBattle:GetCampData(2);
	
	local tbPlayerList = {};
	for i, tbInfo in ipairs(SuperBattle.tbSortPlayer) do
		if i > 20 then
			break;
		end
		local pPlayer = KPlayer.GetPlayerByName(tbInfo.szPlayerName);
		local tbPlayerData = SuperBattle.tbPlayerData[tbInfo.szPlayerName];
		local szFaction = pPlayer and Player:GetFactionRouteName(pPlayer.nFaction, pPlayer.nRouteId) or "Không xác định";
		tbPlayerList[i] =
		{
			["nCamp"] 				= tbPlayerData.nCamp,
			["szFaction"] 			= szFaction,
			["szPlayerName"] 		= tbInfo.szPlayerName,
			["szGateway"]	 		= tbPlayerData.szGateway,
			["nKillCount"] 			= tbPlayerData.nKillCount,
			["nMaxSeriesKill"] 		= tbPlayerData.nMaxSeriesKill,
			["nPoint"]				= tbPlayerData.nPoint,
		};
	end
	
	for _, pPlayer in pairs(self:GetPlayerList()) do
		local tbInfo = {};
		local tbPlayerData = SuperBattle:GetPlayerData(pPlayer);
		if tbPlayerData then
			tbInfo.tbPlayerInfo =
			{
				["szBattleName"]		= "Hồi Mộng Thái Thạch Cơ",
				["nCamp"]				= tbPlayerData.nCamp,
				["nBattleMode"] 		= 1,
				["nMyCampNum"] 			= self:GetPlayerCount(tbPlayerData.nCamp),
				["nEnemyCampNum"] 		= self:GetPlayerCount(3 - tbPlayerData.nCamp),
				["nRemainTime"]	 		= self.nEndTime - GetTime(),
				["nKillPlayerNum"] 		= tbPlayerData.nKillCount,
				["nKillPlayerPoint"] 	= tbPlayerData.nPoint - tbPlayerData.nCampPoint - tbPlayerData.nAdmiralPoint - tbPlayerData.nMarshalPoint,
				["nCampPoint"]			= tbPlayerData.nCampPoint,
				["nAdmiralPoint"]		= tbPlayerData.nAdmiralPoint,
				["nMarshalPoint"]		= tbPlayerData.nMarshalPoint,
				["nPoint"] 				= tbPlayerData.nPoint,
				["nListRank"] 			= tbPlayerData.nSort,
				["nMaxSeriesKill"] 		= tbPlayerData.nMaxSeriesKill,
				["nSeriesKill"]	 		= tbPlayerData.nCurSeriesKill,
				["nTotalSongPoint"] 	= tbCampSongData.nPoint,
				["nTotalJinPoint"]		= tbCampJinData.nPoint,
				["nCampSongPoint"] 		= tbCampSongData.nCamp,
				["nCampJinPoint"]		= tbCampJinData.nCamp,
			};
			tbInfo.tbPlayerList 		= tbPlayerList;
			Dialog:SyncCampaignDate(pPlayer, "superbattle_report", tbInfo, 15 * Env.GAME_FPS);
		end
	end
end

