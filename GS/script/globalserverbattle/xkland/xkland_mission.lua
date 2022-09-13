-------------------------------------------------------
-- 文件名　：xkland_mission.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-04-08 15:32:22
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\globalserverbattle\\xkland\\xkland_def.lua");

local tbMission = Xkland.Mission or Mission:New();
Xkland.Mission = tbMission;

-- 开启游戏
function tbMission:OnOpen()

end

-- 结束游戏
function tbMission:OnClose()
	
	-- 将所有玩家传回英雄岛
	local tbPlayerList = self:GetPlayerList();
	for i, pPlayer in pairs(tbPlayerList) do
		Transfer:NewWorld2GlobalMap(pPlayer);
	end
end

function tbMission:OnJoin(nGroupId)
	
	-- 自定义阵营
	me.nExtensionGroupId = nGroupId;
	
	-- 仇杀、切磋
	me.ForbidEnmity(1);
	me.ForbidExercise(1);
	
	-- 从岛上进入要离队
	if me.GetTask(Xkland.TASK_GID, Xkland.TASK_LAND_ENTER) == 1 then
		me.TeamApplyLeave();
		me.SetTask(Xkland.TASK_GID, Xkland.TASK_LAND_ENTER, 0);
	end
	
	-- 第一次要初始化
	if not Xkland.tbPlayerBuffer[me.szName] then
		GCExcute({"Xkland:InitPlayer_GA", me.szName, nGroupId});
	end
		
	Xkland:AddPlayerTitle(me, nGroupId);
	
	-- 更新右侧信息
	local nRemainTime = self:GetRemainTime();
	self:OpenRightUI(me, self.szRightTitle, nRemainTime);
	self:UpdateSingleRightUI(me);
	
	-- 设置pk系数
	--me.SetPkDamageRate(20); -- 20%
end

function tbMission:GetRemainTime()
	local nRemainTime = 0;
	if self.nPlayState == 0 then
		nRemainTime = (self.nInitTime - GetTime() + Xkland.READY_TIME) * Env.GAME_FPS;
	elseif self.nPlayState == 1 then
		nRemainTime = (self.nEndTime - GetTime()) * Env.GAME_FPS;
	end
	return nRemainTime;
end

function tbMission:OnLeave(nGroupId, szReason)
	
	-- 自定义阵营
	me.nExtensionGroupId = 0;
	
	-- 仇杀、切磋
	me.ForbidEnmity(0);
	me.ForbidExercise(0);
	
	-- 自定义头衔
	Xkland:RemovePlayerTitle(me, nGroupId);
	
	-- 删除buffer
	if me.GetSkillState(Xkland.RESOURCE_BUFFER) > 0 then
		me.RemoveSkillState(Xkland.RESOURCE_BUFFER);
	end
	
	if me.GetSkillState(Xkland.THRONE_BUFFER) > 0 then
		me.RemoveSkillState(Xkland.THRONE_BUFFER);
	end
	
	if me.GetSkillState(Xkland.BALANCE_BUFFER) > 0 then
		me.RemoveSkillState(Xkland.BALANCE_BUFFER);
	end
	
	if Xkland.tbThrone.szPlayerName == me.szName then
		Xkland:OnLoseThrone(me.szName, nGroupId);
	end
	
	self:CloseRightUI(me);
	
	-- 设置pk系数
	--me.SetPkDamageRate(0); -- 25%
end

-- 初始化游戏
function tbMission:InitGame(nTime)
	
	self.nInitTime 			= nTime;
	self.nPlayState 		= 0;
	self.nRevivalGroup 		= 0;
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
			
	if Xkland:GetSession() ~= 1 then
		self.tbMisCfg.tbCamp = {1, 2};
		self.tbMisCfg.tbChannel = 
		{
			[1]	= {"守方军团", 20, tbIcon[1], tbIcon[2]},
			[2]	= {"攻方军团", 20, tbIcon[1], tbIcon[2]},
		};
	else
		self.tbMisCfg.tbCamp = {1, 1, 1, 1, 1, 1};
		self.tbMisCfg.tbChannel = 
		{
			[1]	= {"第一军团", 20, tbIcon[1], tbIcon[2]},
			[2]	= {"第二军团", 20, tbIcon[1], tbIcon[2]},
			[3]	= {"第三军团", 20, tbIcon[1], tbIcon[2]},
			[4]	= {"第四军团", 20, tbIcon[1], tbIcon[2]},
			[5]	= {"第五军团", 20, tbIcon[1], tbIcon[2]},
			[6]	= {"第六军团", 20, tbIcon[1], tbIcon[2]},
		};
	end
	
	self:Open();
end

-- 开始比赛
-- 1. 刷出资源点
-- 2. 刷出复活点柱子
-- 3. 计时器：刷渡船点
function tbMission:StartGame(nTime)
	
	self.nStartTime 		= nTime;
	self.nEndTime			= nTime + Xkland.PLAY_TIME;
	self.nPlayState 		= 1;
	self.szRightTitle 		= "<color=white>剩余攻城时间：%s<color>";
	
	-- 第一届资源点和复活点3不可用
	if Xkland:GetSession() ~= 1 then
		
		-- 刷资源点
		for nMapId, tbInfo in pairs(Xkland.RESOURCE_LIST) do
			if SubWorldID2Idx(nMapId) >= 0 then
				for nNpcId, tbPos in pairs(tbInfo) do
					Xkland:AddResource(nNpcId, tbPos);
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
	self:CreateTimer(Xkland.REFRESH_BOAT, self.TimerAddBoat, self);
	self:CreateTimer(Xkland.PROTECT_INTERVAL, self.TimerAddProtectBouns, self);
	self:CreateTimer(Xkland.SYNC_REPORT_DATA, self.TimerSyncReportData, self);
	
	-- 王座积分
	if SubWorldID2Idx(Xkland.THRONE_MAP_ID) >= 0 then
		self:CreateTimer(Xkland.THRONE_POINT_TIME, self.TimerAddThronePoint, self);
	end
end

-- 计时器增加渡传点
function tbMission:TimerAddBoat()
	
	if Xkland:GetWarState() ~= 2 then
		return 0;
	end
	
	for nMapId, tbInfo in pairs(Xkland.BOAT_LIST) do
		if SubWorldID2Idx(nMapId) >= 0 then
			for nNpcId, tbPos in pairs(tbInfo) do
				Xkland:AddBoat(nNpcId, tbPos);
			end
		end
	end
	
	local szMsg = "地图的<color=yellow>渡船点<color>已经开放了，可接引玩家前往城中。";
	Xkland:BroadCast_GS(szMsg, Xkland.BOTTOM_BLACK_MSG);
	Xkland:BroadCast_GS(szMsg, Xkland.SYSTEM_CHANNEL_MSG);
	
	-- 创建另一个计时器删除渡船点
	self:CreateTimer(Xkland.BOAT_LIVING, self.TimerRemoveBoat, self);
end

-- 计时器删除渡船点
function tbMission:TimerRemoveBoat()
	
	if Xkland:GetWarState() ~= 2 then
		return 0;
	end
	
	Xkland:RemoveBoat();
	
	-- timer只调一次
	return 0;
end

-- 每隔5秒更新战报
function tbMission:TimerSyncReportData()

	if Xkland:GetWarState() ~= 2 then
		return 0;
	end
	local nGMMsgFlag = 0;
	local tbPlayerList = self:GetPlayerList();
	for _, pPlayer in pairs(tbPlayerList) do
		local tbPlayer = Xkland.tbPlayerBuffer[pPlayer.szName];
		if tbPlayer then
			local nGroupIndex = self:GetPlayerGroupId(pPlayer);
			local tbPlayer = Xkland.tbPlayerBuffer[pPlayer.szName];
			local tbInfo = {};
			tbInfo.szJunTuanName 		= Xkland.tbGroupBuffer[nGroupIndex].szGroupName;
			tbInfo.nJunTuanPlayerNum 	= Xkland:GetGroupMemberCount(nGroupIndex);
			tbInfo.nRemainTime 			= self.nEndTime - GetTime();
			tbInfo.tbPlayerScore 		= {};
			tbInfo.tbJunTuanScore 		= {};
			tbInfo.tbPlayerScore.nTotalScore 	= tbPlayer.nPoint;
			tbInfo.tbPlayerScore.nRank 			= Xkland:GetPlayerSort(pPlayer.szName);
			tbInfo.tbPlayerScore.tbKillPeople 	= {nCount = tbPlayer.nKillCount, nScore = tbPlayer.nPoint - tbPlayer.nResource * Xkland.RESOURCE_POINT - tbPlayer.nProtect * Xkland.PROTECT_POINT};
			tbInfo.tbPlayerScore.tbGainRes 		= {nCount = tbPlayer.nResource, nScore = tbPlayer.nResource * Xkland.RESOURCE_POINT};
			tbInfo.tbPlayerScore.tbProtectRes 	= {nCount = tbPlayer.nProtect, nScore = tbPlayer.nProtect * Xkland.PROTECT_POINT};
			for nSort, tbGroup in ipairs(Xkland.tbSortGroup) do
				table.insert(tbInfo.tbJunTuanScore, {
					szJunTuanName = Xkland.tbGroupBuffer[tbGroup.nGroupIndex].szGroupName, 
					nScore = tbGroup.nPoint,
					nThrone = tbGroup.nThronePoint,
				});
			end
			Dialog:SyncCampaignDate(pPlayer, "xkland_report", tbInfo, 10 * Env.GAME_FPS);
			
			if nGMMsgFlag == 0 and Xkland.GMPlayerList then
				nGMMsgFlag =1;
				for nId in pairs(Xkland.GMPlayerList) do
					local pGmPlayer = KPlayer.GetPlayerObjById(nId);
					if pGmPlayer then
						Dialog:SyncCampaignDate(pGmPlayer, "xkland_report", tbInfo, 10 * Env.GAME_FPS);
					end
				end
			end
		end
	end
end

-- 护卫资源点积分
function tbMission:TimerAddProtectBouns()
	
	if Xkland:GetWarState() ~= 2 then
		return 0;
	end
	
	for nNpcDwId, tbInfo in pairs(Xkland.tbResource) do
		local tbPlayerList = KNpc.GetAroundPlayerList(nNpcDwId, Xkland.PROTECT_DISTANCE);
		for _, pPlayer in pairs(tbPlayerList or {}) do
			local nGroupIndex = self:GetPlayerGroupId(pPlayer);
			if nGroupIndex == tbInfo.nOwnerGroup then
				Xkland:OnProtectResource(pPlayer, Xkland.PROTECT_POINT);
			end
		end	
	end
end

-- 每分钟增加王座积分
function tbMission:TimerAddThronePoint()

	if Xkland:GetWarState() ~= 2 then
		return 0;
	end
	
	Xkland:AddThronePoint();
end

-- 死亡回调
-- 1. 如果是第一次争夺，死了以后传送回固定的复活点
-- 2. 以后的争夺，死亡传送回攻方或者守方的复活点
-- 3。死亡后，增加击杀者和城池的资金
-- 4。击杀者增加积分
function tbMission:OnDeath(pKillerNpc)
	
	-- 吊销许可证
	me.SetTask(Xkland.TASK_GID, Xkland.TASK_PASSPORT, 0);
	
	-- 获得阵营
	local nGroupIndex = self:GetPlayerGroupId(me);
	
	-- 判断王座
	if Xkland.tbThrone.szPlayerName == me.szName then
		Xkland:OnLoseThrone(me.szName, nGroupIndex);
		if me.GetSkillState(Xkland.THRONE_BUFFER) > 0 then
			me.RemoveSkillState(Xkland.THRONE_BUFFER);
		end
	end
	
	-- 获得击杀者
	local pKillerPlayer = pKillerNpc.GetPlayer();
	if pKillerPlayer then
		
		-- 击杀者阵营
		local nKillerGroup = self:GetPlayerGroupId(pKillerPlayer);
		
		-- 判断披风(雏凤)
		local pItem = me.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_MANTLE, 0);
		if pItem and pItem.nLevel >= Xkland.MANTLE_LEVEL then
			
			-- 获得绑银数量
			local nCostMoney = Xkland.MONEY_COST[pItem.nLevel].nCost;
			local tbRadio = Xkland.MONEY_COST[pItem.nLevel].tbRadio;
			
			local nRand = MathRandom(tbRadio[1], tbRadio[2]) / 10;
			local nPrviMoney = nCostMoney * nRand;
			local nSystemMoney = (nCostMoney - nPrviMoney) * tbRadio[3] / 10;
			local nCastleMoney = (nCostMoney - nPrviMoney) * tbRadio[4] / 10;
			
			-- 击杀者获得绑银
			if nPrviMoney + pKillerPlayer.GetBindMoney() <= pKillerPlayer.GetMaxCarryMoney() then
				pKillerPlayer.AddBindMoney(nPrviMoney);
				-- log
				Dbg:WriteLog("Xkland", "跨服城战", pKillerPlayer.szAccount, pKillerPlayer.szName, string.format("获得跨服绑银：%s", nPrviMoney));
			end
			
			-- 跨服全局变量记录系统绑银
			Xkland:AddSystemMoney_GS(nSystemMoney);
			
			-- 存在城的数据资金
			Xkland:AddCastleMoney_GS(nCastleMoney);
		
			-- 击杀回调
			Xkland:OnKillPlayer(pKillerPlayer, me);
			
			local pKillerItem = pKillerPlayer.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_MANTLE, 0);
			local nMantleLevel = pKillerItem and pKillerItem.nLevel or 0;
			
			-- 披风路线log
			Dbg:WriteLog("Xkland", "跨服城战", 
				string.format("击杀者：%s，披风等级：%s，门派：%s，路线：%s", pKillerPlayer.szName, nMantleLevel, pKillerPlayer.nFaction, pKillerPlayer.nRouteId),
				string.format("被杀者：%s，披风等级：%s，门派：%s，路线：%s", me.szName, pItem.nLevel, me.nFaction, me.nRouteId)
			);
		end
	end
	
	-- 第一次争夺
	if Xkland:GetSession() == 1 then
		local nRand = MathRandom(1, 6);
		local tbRevivalPos = Xkland.REVIVAL_POS_INDEX[nRand];
		if tbRevivalPos then
			me.ReviveImmediately(1);
			me.SetFightState(0);
			me.NewWorld(unpack(tbRevivalPos));
		end
		
	-- 攻防战
	else
		local nRand = MathRandom(1, 3);
		local tbRevivalPos = Xkland.REVIVAL_POS_WAR[nGroupIndex]
		if tbRevivalPos then
			me.ReviveImmediately(1);
			me.SetFightState(0);
			me.NewWorld(unpack(tbRevivalPos[nRand]));
		end
	end
end

-- 设置buffer
function tbMission:SetGroupBuffer(nBufferId, nGroupIndex, nBufferLevel)
	local tbPlayerList = self:GetPlayerList(nGroupIndex);
	for _, pPlayer in pairs(tbPlayerList) do
		pPlayer.RemoveSkillState(nBufferId);
		if nBufferLevel > 0 then
			pPlayer.AddSkillState(nBufferId, nBufferLevel, 1, 2 * 60 * 60 * Env.GAME_FPS, 1, 1);
		end
	end
end

-- 更新头衔
function tbMission:UpdatePlayerRank()
	local tbPlayerList = self:GetPlayerList();
	for _, pPlayer in pairs(tbPlayerList) do
		local nGroupIndex = self:GetPlayerGroupId(pPlayer);
		Xkland:AddPlayerTitle(pPlayer, nGroupIndex);
	end
end

-- 广播消息
function tbMission:BroadCast(szMsg, nType)
	local tbPlayerList = self:GetPlayerList();
	for _, pPlayer in pairs(tbPlayerList) do
		if nType == Xkland.SYSTEM_CHANNEL_MSG then
			pPlayer.Msg(szMsg);
		elseif nType == Xkland.BOTTOM_BLACK_MSG then
			Dialog:SendBlackBoardMsg(pPlayer, szMsg);
		elseif nType == Xkland.MIDDLE_RED_MSG then
			Dialog:SendInfoBoardMsg(pPlayer, szMsg);
		end
	end
end

-- 开启右侧信息
function tbMission:OpenRightUI(pPlayer, szTitle, nRemainFrame)
	if not pPlayer then
		return 0;
	end
	Dialog:SetBattleTimer(pPlayer, szTitle, nRemainFrame);
	local szMsg = string.format("\n<color=green>个人积分：<color=yellow>%s\n<color=green>个人排名：<color=yellow>%s\n<color=green>军团积分：<color=yellow>%s<color>\n<color=green>王座积分：<color=yellow>%s<color>\n<color=green>军 需 库：<color=yellow>%s<color>\n", 0, 0, 0, 0, 0); 
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
	if not Xkland.tbPlayerBuffer[pPlayer.szName] then
		return 0;
	end
	local nPlayerPoint = Xkland.tbPlayerBuffer[pPlayer.szName].nPoint;
	local nPlayerRank = Xkland:GetPlayerSort(pPlayer.szName);
	local nGroupIndex = self:GetPlayerGroupId(pPlayer);
	local nGroupPoint = Xkland.tbWarBuffer[nGroupIndex].nPoint;
	local nThronePoint = Xkland.tbWarBuffer[nGroupIndex].nThronePoint;
	local nRevivalMoney = Xkland.tbWarBuffer[nGroupIndex].nRevivalMoney;
	local szMsg = string.format("\n<color=green>个人积分：<color=yellow>%s\n<color=green>个人排名：<color=yellow>%s\n<color=green>军团积分：<color=yellow>%s<color>\n<color=green>王座积分：<color=yellow>%s<color>\n<color=green>军 需 库：<color=yellow>%s<color>\n", nPlayerPoint, nPlayerRank, nGroupPoint, nThronePoint, nRevivalMoney); 
	Dialog:SendBattleMsg(pPlayer, szMsg, 1);
end

-- 更新所有玩家右侧信息
function tbMission:UpdateAllRightUI()
	local tbPlayerList = self:GetPlayerList();	
	for _, pPlayer in pairs(tbPlayerList) do
		self:UpdateSingleRightUI(pPlayer);
	end
end
