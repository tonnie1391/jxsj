-------------------------------------------------------
-- 文件名　：newland_mission.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-09-03 15:24:36
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\globalserverbattle\\Newland\\Newland_def.lua");

local tbMission = Newland.Mission or Mission:New();
Newland.Mission = tbMission;

-- 开启游戏
function tbMission:OnOpen()

end

-- 结束游戏
function tbMission:OnClose()
	
	-- 将所有玩家传回英雄岛
	local tbPlayerList = self:GetPlayerList();
	for i, pPlayer in pairs(tbPlayerList) do
		-- balance
		if Newland:CheckIsBalance() == 1 then
			Newland:RemoveBalance(pPlayer);
		end
		Transfer:NewWorld2GlobalMap(pPlayer);
	end
end

-- 玩家加入
function tbMission:OnJoin(nGroupId)
	
	-- 自定义阵营
	me.nExtensionGroupId = nGroupId;
	
	-- 仇杀、切磋
	me.ForbidEnmity(1);
	me.ForbidExercise(1);
	
	-- 从岛上进入要离队
	if me.GetTask(Newland.TASK_GID, Newland.TASK_LAND_ENTER) == 1 then
		me.TeamApplyLeave();
		me.SetTask(Newland.TASK_GID, Newland.TASK_LAND_ENTER, 0);
	end
	
	-- 第一次要初始化
	if not Newland.tbPlayerBuffer[me.szName] then
		GCExcute({"Newland:InitPlayer_GA", me.szName, nGroupId});
	end
	
	-- 增加头衔
	Newland:AddPlayerTitle(me, nGroupId);
	
	-- 更新右侧信息
	local nRemainTime = self:GetRemainTime();
	self:OpenRightUI(me, self.szRightTitle, nRemainTime);
	self:UpdateSingleRightUI(me);
	
	if self.nPlayState == 0 then
		Dialog:SendBlackBoardMsg(me, "Trận chiến chưa bắt đầu! Hãy kiên nhẫn chờ đợi!");
	elseif self.nPlayState == 1 then
		Dialog:SendBlackBoardMsg(me, "Trận chiến đã diễn ra, hãy ra sức dẹp giặc!");
	end
	
	--修正数据
	local nTotalBox = GetPlayerSportTask(me.nId, Newland.GA_TASK_GID, Newland.GA_TASK_WAR_BOX) or 0;
	local nGetBox = me.GetTask(Newland.TASK_GID, Newland.TASK_WAR_BOX);
	if nTotalBox < nGetBox * 100 then
		SetPlayerSportTask(me.nId, Newland.GA_TASK_GID, Newland.GA_TASK_WAR_BOX, nGetBox * 100); 
	end
	
	local nTotalTimes = GetPlayerSportTask(me.nId, Newland.GA_TASK_GID, Newland.GA_TASK_WAR_EXP) or 0;
	local nGetTimes = me.GetTask(Newland.TASK_GID, Newland.TASK_WAR_EXP);
	if nTotalTimes < nGetTimes then
		SetPlayerSportTask(me.nId, Newland.GA_TASK_GID, Newland.GA_TASK_WAR_EXP, nGetTimes); 
	end
	--修正数据end
	
end

-- 获取剩余时间
function tbMission:GetRemainTime()
	local nRemainTime = 0;
	if self.nPlayState == 0 then
		nRemainTime = (self.nInitTime - GetTime() + Newland.READY_TIME) * Env.GAME_FPS;
	elseif self.nPlayState == 1 then
		nRemainTime = (self.nEndTime - GetTime()) * Env.GAME_FPS;
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
	
	-- 自定义头衔
	Newland:RemovePlayerTitle(me, nGroupId);
	
	-- 失去王座	
	if Newland.tbThrone.szPlayerName == me.szName then
		Newland:OnLoseThrone(me.szName, nGroupId);
	end
	
	-- 删除buffer
	if me.GetSkillState(Newland.THRONE_BUFFER) > 0 then
		me.RemoveSkillState(Newland.THRONE_BUFFER);
	end
	
	-- 关闭右侧界面
	self:CloseRightUI(me);
	
	-- 清除小地图
	Newland:ClearMiniMap(me);
end

-- 初始化游戏
function tbMission:InitGame(nTime, nMaxGroup)
	
	self.nInitTime 			= nTime;
	self.nMaxGroup 			= nMaxGroup;
	self.nPlayState 		= 0;
	self.szRightTitle		= "<color=white>Thời gian chuẩn bị: %s<color>";
	
	self.tbMisCfg = 
	{
		nPkState			= Player.emKPK_STATE_EXTENSION,	-- 自定义战斗模式
		nInBattleState		= 1,							-- 禁止不同阵营组队
		nDeathPunish		= 1,							-- 无死亡惩罚
		nOnDeath			= 1,							-- 玩家死亡回调
		nForbidStall		= 1,							-- 禁止摆摊
		nDisableOffer		= 1,							-- 禁止收购
		nDisableFriendPlane = 1,							-- 禁止好友界面
		nDisableStallPlane	= 1,							-- 禁止交易界面		
	};
	
	local tbIcon = 
	{
		"\\image\\ui\\001a\\main\\chatchanel\\chanel_fight.spr", 
		"\\image\\ui\\001a\\main\\chatchanel\\btn_chanel_fight.spr"
	};
	
	-- 创建频道
	self.tbMisCfg.tbCamp = {};
	self.tbMisCfg.tbChannel = {};
	for i = 1, nMaxGroup do
		local tbTree = Newland:GetMapTreeByIndex(i);
		self.tbMisCfg.tbCamp[i] = tbTree[0];
		self.tbMisCfg.tbChannel[i] = {string.format("Thiết Phù Thành %s", i), 20, tbIcon[1], tbIcon[2]};
	end
	
	self:Open();
end

-- 开始比赛
function tbMission:StartGame(nTime)
	
	self.nStartTime 		= nTime;
	self.nEndTime			= nTime + Newland.PLAY_TIME;
	self.nPlayState 		= 1;
	self.szRightTitle 		= "<color=white>Thời gian còn lại: %s<color>";
	
	-- 刷柱子
	for nLevel, tbMapId in pairs(Newland.MAP_LIST) do
		for _, nMapId in pairs(tbMapId) do
			if SubWorldID2Idx(nMapId) >= 0 then
				local nMapLevel = Newland:GetMapLevel(nMapId);
				if nMapLevel > 0 then
					local tbInfo = Newland.POLE_LIST[nMapLevel];
					for _, tbPos in pairs(tbInfo or {}) do
						local nMapX, nMapY = unpack(tbPos);
						Newland:AddNewPole(Newland.POLE_ID, nMapId, nMapX, nMapY);
					end
				end
			end
		end 
	end
	
	-- 开启一次右边的界面
	local tbPlayerList = self:GetPlayerList();	
	for _, pPlayer in pairs(tbPlayerList) do
		self:OpenRightUI(pPlayer, self.szRightTitle, self:GetRemainTime());
	end
	
	-- 计时器
	self:CreateTimer(Newland.UPDATE_POINT_TIME, Newland.TimerUpdatePoint, Newland);
end

-- 每隔5秒更新战报
function tbMission:TimerSyncReportData()

	if Newland:GetWarState() ~= Newland.WAR_START then
		return 0;
	end
	
	local nGMMsgFlag = 0;
	local tbPlayerList = self:GetPlayerList();
	
	-- 遍历所有玩家列表
	for _, pPlayer in pairs(tbPlayerList) do
		local tbPlayer = Newland.tbPlayerBuffer[pPlayer.szName];
		if tbPlayer then
			local tbInfo 				= {};
			local nGroupIndex 			= self:GetPlayerGroupId(pPlayer);
			tbInfo.szTongName 			= Newland.tbGroupBuffer[nGroupIndex].szTongName;
			tbInfo.nMemberCount 		= Newland:GetGroupMemberCount(nGroupIndex);
			tbInfo.nRemainTime 			= self.nEndTime - GetTime();
			tbInfo.tbPlayerScore 		= {};
			tbInfo.tbGroupScore 		= {};
			tbInfo.tbPlayerScore.nPoint 		= tbPlayer[2];
			tbInfo.tbPlayerScore.nSort 			= Newland:GetPlayerSort(pPlayer.szName);
			tbInfo.tbPlayerScore.tbKiller 		= {nCount = tbPlayer[3], nScore = tbPlayer[2] - tbPlayer[8] * Newland.OCCUPY_POLE_POINT - tbPlayer[7] * Newland.PROTECT_POINT - tbPlayer[9] * Newland.PLAYER_THRONE_POINT};
			tbInfo.tbPlayerScore.tbPole 		= {nCount = tbPlayer[8], nScore = tbPlayer[8] * Newland.OCCUPY_POLE_POINT};
			tbInfo.tbPlayerScore.tbProtect 		= {nCount = tbPlayer[7], nScore = tbPlayer[7] * Newland.PROTECT_POINT};
			tbInfo.tbPlayerScore.tbThrone 		= {nCount = tbPlayer[9], nScore = tbPlayer[9] * Newland.PLAYER_THRONE_POINT};
			for nSort, tbGroup in ipairs(Newland.tbSortGroup) do
				table.insert(tbInfo.tbGroupScore, {
					szTongName = tbGroup.szTongName, 
					nPoint = tbGroup.nPoint,
				});
			end
			Dialog:SyncCampaignDate(pPlayer, "Newland_report", tbInfo, Newland.SYNC_DATE_TIME * Env.GAME_FPS);
			
			if nGMMsgFlag == 0 and Newland.GMPlayerList then
				nGMMsgFlag = 1;
				for nId in pairs(Newland.GMPlayerList) do
					local pGmPlayer = KPlayer.GetPlayerObjById(nId);
					if pGmPlayer then
						local nGmIndex = Newland:GetPlayerGroupIndex(pGmPlayer);
						if nGmIndex == nGroupIndex then
							Dialog:SyncCampaignDate(pGmPlayer, "Newland_report", tbInfo, Newland.SYNC_DATE_TIME * Env.GAME_FPS);
						end
					end
				end
			end
		end
	end
end

-- 死亡回调
function tbMission:OnDeath(pKillerNpc)
	
	-- 获得阵营
	local nGroupIndex = self:GetPlayerGroupId(me);
	
	-- 判断王座
	if Newland.tbThrone.szPlayerName == me.szName then
		Newland:OnLoseThrone(me.szName, nGroupIndex);
		if me.GetSkillState(Newland.THRONE_BUFFER) > 0 then
			me.RemoveSkillState(Newland.THRONE_BUFFER);
		end
	end
	
	-- 获得击杀者
	local pKillerPlayer = pKillerNpc.GetPlayer();
	if pKillerPlayer then

		-- 判断披风(雏凤)
		local pItem = me.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_MANTLE, 0);
		if pItem and pItem.nLevel >= Newland.MANTLE_LEVEL then
		
			-- 击杀回调
			Newland:OnKillPlayer(pKillerPlayer, me);
			
			local pKillerItem = pKillerPlayer.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_MANTLE, 0);
			local nMantleLevel = pKillerItem and pKillerItem.nLevel or 0;
			
			-- 披风路线log
			Dbg:WriteLog("Newland", "跨服城战", 
				string.format("击杀者：%s，披风等级：%s，门派：%s，路线：%s", pKillerPlayer.szName, nMantleLevel, pKillerPlayer.nFaction, pKillerPlayer.nRouteId),
				string.format("被杀者：%s，披风等级：%s，门派：%s，路线：%s", me.szName, pItem.nLevel, me.nFaction, me.nRouteId)
			);
			
			StatLog:WriteStatLog("stat_info", "newland", "kill", me.nId, me.GetHonorLevel(), pItem.nLevel, me.nFaction, me.nRouteId,
				pKillerPlayer.szName, pKillerPlayer.GetHonorLevel(), nMantleLevel, pKillerPlayer.nFaction, pKillerPlayer.nRouteId, me.nMapId);
		end
	end
	
	-- 回到1层复活点
	local nMapId = Newland:GetLevelMapIdByIndex(nGroupIndex, 1);
	local tbTree = Newland:GetMapTreeByIndex(nGroupIndex);
	if nMapId and tbTree then
		me.ReviveImmediately(1);
		local nOk, szError = Map:CheckTagServerPlayerCount(nMapId);
		if nOk ~= 1 then
			Dialog:Say(szError);
			return 0;
		end
		me.SetFightState(0);
		local nMapX, nMapY = unpack(Newland.REVIVAL_LIST[tbTree[0]]);
		me.NewWorld(nMapId, nMapX, nMapY);
	end
end

-- 设置buffer
function tbMission:SetGroupBuffer(nGroupIndex, nBufferId, nBufferLevel)
	local tbPlayerList = self:GetPlayerList(nGroupIndex);
	for _, pPlayer in pairs(tbPlayerList) do
		pPlayer.RemoveSkillState(nBufferId);
		if nBufferLevel > 0 then
			pPlayer.AddSkillState(nBufferId, nBufferLevel, 1, 2 * 60 * 60 * Env.GAME_FPS, 1, 1);
		end
	end
end

-- 更新小地图
function tbMission:UpdateMiniMap()
	local tbPlayerList = self:GetPlayerList();
	for _, pPlayer in pairs(tbPlayerList) do
		Newland:OnUpdateMiniMap(pPlayer);
	end
end

-- 更新头衔
function tbMission:UpdatePlayerRank()
	local tbPlayerList = self:GetPlayerList();
	for _, pPlayer in pairs(tbPlayerList) do
		local nGroupIndex = self:GetPlayerGroupId(pPlayer);
		Newland:AddPlayerTitle(pPlayer, nGroupIndex);
	end
end

-- 开启右侧信息
function tbMission:OpenRightUI(pPlayer, szTitle, nRemainFrame)
	if not pPlayer then
		return 0;
	end
	Dialog:SetBattleTimer(pPlayer, szTitle, nRemainFrame);
	local szMsg = string.format("\n<color=green>Tích lũy cá nhân: <color=yellow>%s\n<color=green>Xếp hạng cá nhân: <color=yellow>%s\n<color=green>Tích lũy Bang hội: <color=yellow>%s<color>\n<color=green>Xếp hạng Bang hội: <color=yellow>%s<color>\n", 0, 0, 0, 0); 
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
	if not Newland.tbPlayerBuffer[pPlayer.szName] then
		return 0;
	end
	local nPlayerPoint = Newland.tbPlayerBuffer[pPlayer.szName][2];
	local nPlayerSort = Newland:GetPlayerSort(pPlayer.szName);
	local nGroupIndex = self:GetPlayerGroupId(pPlayer);
	local nGroupPoint = Newland.tbWarBuffer[nGroupIndex].nPoint;
	local nGroupSort = Newland:GetGroupSort(nGroupIndex);
	local szMsg = string.format("\n<color=green>Tích lũy cá nhân: <color=yellow>%s\n<color=green>Xếp hạng cá nhân: <color=yellow>%s\n<color=green>Tích lũy Bang hội: <color=yellow>%s<color>\n<color=green>Xếp hạng Bang hội: <color=yellow>%s<color>\n", nPlayerPoint, nPlayerSort, nGroupPoint, nGroupSort); 
	Dialog:SendBattleMsg(pPlayer, szMsg, 1);
end

-- 更新所有玩家右侧信息
function tbMission:UpdateAllRightUI()
	local tbPlayerList = self:GetPlayerList();	
	for _, pPlayer in pairs(tbPlayerList) do
		self:UpdateSingleRightUI(pPlayer);
	end
end

-- 广播消息
function tbMission:BroadCastMission(szMsg, nType)
	local tbPlayerList = self:GetPlayerList();
	for _, pPlayer in pairs(tbPlayerList) do
		Newland:BroadCastPlayer(pPlayer, szMsg, nType);
	end
end
