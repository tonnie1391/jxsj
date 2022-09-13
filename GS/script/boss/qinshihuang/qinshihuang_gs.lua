-------------------------------------------------------
-- 文件名　：qinshihuang.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-06-04 16:14:13
-- 文件描述：fix skill state bug 2009-6-23
-------------------------------------------------------

Require("\\script\\boss\\qinshihuang\\qinshihuang_def.lua");

if not MODULE_GAMESERVER then
	return 0;
end

local tbQinshihuang = Boss.Qinshihuang;

-- 消息封装
function tbQinshihuang:SendMessage(pPlayer, nType, szMsg)
	if nType == self.MSG_CHANNEL then
		pPlayer.Msg(szMsg);
	elseif nType == self.MSG_BOTTOM then
		Dialog:SendBlackBoardMsg(pPlayer, szMsg);
	elseif nType == self.MSG_MIDDLE then
		Dialog:SendInfoBoardMsg(pPlayer, szMsg);
	end
end

-- 广播消息
function tbQinshihuang:BroadCast(nType, szMsg)
	if nType == self.MSG_TOP then
		KDialog.NewsMsg(1, Env.NEWSMSG_NORMAL, szMsg);
	elseif nType == self.MSG_GLOBAL then
		KDialog.MsgToGlobal(szMsg);	
	else
		GCExcute({"Boss.Qinshihuang:BroadCast_GC", szMsg, nType});
	end
end

-- 广播回调
function tbQinshihuang:OnBroadCast(szMsg, nType)
	for nPlayerId, _ in pairs(self.tbPlayerList) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			self:SendMessage(pPlayer, nType, szMsg);
		end
	end
end

-- 计时器触发
function tbQinshihuang:OnTimer()

	-- 遍历玩家列表
	if self.tbPlayerList then		
		for nPlayerId, tbPlayerMap in pairs(self.tbPlayerList) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				local nTime = GetTime() - pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_START_TIME);
				local nUseTime = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_USE_TIME);
				if  nUseTime + nTime > self.MAX_DAILY_TIME or self:_CheckState() ~= 1 then
					pPlayer.SetFightState(0);
					self:_MapResetState(pPlayer);
					local szMsg = "Bên trong Tần Lăng độc khí rất nặng, cơ thể mệt mỏi không còn chút sức lực, hãy nghỉ ngơi chút nữa!";
					self:SendMessage(pPlayer, self.MSG_CHANNEL, szMsg);
					self:SendMessage(pPlayer, self.MSG_BOTTOM, szMsg);
					pPlayer.NewWorld(self:GetLeaveMapPos());
				elseif self:_CheckTime() == 1 and pPlayer.nFightState > 0 and pPlayer.nPkModel ~= Player.emKPK_STATE_TONG then
					self:_MapSetState(pPlayer);
					local szMsg = "Tần Thủy Hoàng sắp xuất hiện. Chế độ PK chuyển sang Bang hội.";
					self:SendMessage(pPlayer, self.MSG_CHANNEL, szMsg);
					self:SendMessage(pPlayer, self.MSG_BOTTOM, szMsg);
				end
			else
				self.tbPlayerList[nPlayerId] = nil;
			end
		end
	end
	
	-- 同步帮会坐标
	for nMapId, _ in pairs(self.MAP_LIST) do
		if SubWorldID2Idx(nMapId) >= 0 then
			for nTongId, _ in pairs(self.tbTongList) do
				SetMapHighLightPointEx(nMapId, 3, 12, 6000, 0, 1, nTongId);
			end
		end
	end

	return 5 * Env.GAME_FPS;
end

-- 初始化
function tbQinshihuang:Init()
	self.nTimerId = Timer:Register(5 * Env.GAME_FPS, self.OnTimer, self);
end

-- 增加玩家
function tbQinshihuang:AddPlayer(nPlayerId, nMapLevel)
	
	if self:_CheckState() ~= 1 then
		return;
	end
	
	-- 通过ID找玩家对象
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	
	-- 取剩余时间任务变量(秒)
	local nUseTime = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_USE_TIME);
	if nUseTime > self.MAX_DAILY_TIME then
		return;
	end
	
	-- 标记玩家, 地图等级.进入时间
	self.tbPlayerList[nPlayerId] = {};
	self.tbPlayerList[nPlayerId].nMapLevel = nMapLevel;
	self.tbPlayerList[nPlayerId].nStartTime = GetTime();
	
	-- 帮会列表
	if pPlayer.dwTongId > 0 then
		self.tbTongList[pPlayer.dwTongId] = 1;
	end
	
	-- 开启计时
	local nFrame = (self.MAX_DAILY_TIME - nUseTime) * Env.GAME_FPS;
	self:OpenRightUI(pPlayer, nFrame);
	
	-- 设置开始时间
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_START_TIME, self.tbPlayerList[nPlayerId].nStartTime);
	
	-- 设置保护
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_PROTECT, 1);
	pPlayer.SetLogoutRV(1);
end

-- 移除玩家
function tbQinshihuang:RemovePlayer(nPlayerId)
	
	-- 通过ID找玩家对象
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	
	-- 找不到返回
	if not pPlayer then
		
		-- 容错，再判断下表中有没有数据，有就清掉
		if self.tbPlayerList[nPlayerId] then
			self.tbPlayerList[nPlayerId] = nil;
		end
		
		return;
	end
	
	if self.tbPlayerList[nPlayerId] then
		
		-- 取剩余时间
		local nTime = GetTime() - self.tbPlayerList[nPlayerId].nStartTime;
		local nUseTime = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_USE_TIME);
		
		nUseTime = nUseTime + nTime;
		
		if nUseTime > self.MAX_DAILY_TIME then
			nUseTime = self.MAX_DAILY_TIME;
		end

		-- 设任务变量
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_USE_TIME, nUseTime);
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_START_TIME, 0);
	end

	-- 移除列表
	self.tbPlayerList[nPlayerId] = nil
	
	-- 关闭界面
	self:CloseRightUI(pPlayer);
	
	-- 设置保护
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_PROTECT, 0);
end	

-- 开启右侧计时界面
function tbQinshihuang:OpenRightUI(pPlayer, nRemainFrame)
	
	-- 右侧显示
	local szMsg = "<color=green>Thời gian còn lại: <color=white>%s<color>";
	
	-- 开启界面
	Dialog:SetBattleTimer(pPlayer, szMsg, nRemainFrame);
	Dialog:SendBattleMsg(pPlayer, "<taskid=529>", 1);
	Dialog:ShowBattleMsg(pPlayer, 1, 0);
end

-- 关闭右侧计时界面
function tbQinshihuang:CloseRightUI(pPlayer)
	Dialog:ShowBattleMsg(pPlayer, 0, 0);
end

-- 默认的回程点
function tbQinshihuang:GetLeaveMapPos()
	local tbNpc = Npc:GetClass("chefu");
	for _, tbMapInfo in ipairs(tbNpc.tbCountry) do
		if SubWorldID2Idx(tbMapInfo.nId) >= 0 then
			local nRandomPos = MathRandom(1, #tbMapInfo.tbSect)
			return tbMapInfo.nId, tbMapInfo.tbSect[nRandomPos][1], tbMapInfo.tbSect[nRandomPos][2];
		end
	end
	return 5, 1580, 3029;
end

-- 每天重置为2小时	
function tbQinshihuang:DailyEvent()
		
	if self:_CheckState() ~= 1 then
		return;
	end
	
	-- 如果玩家在地图中
	if self.tbPlayerList[me.nId] then
		
		-- 重置时间变量
		me.SetTask(self.TASK_GROUP_ID, self.TASK_START_TIME, GetTime());
		self.tbPlayerList[me.nId].nStartTime = GetTime();
		
		-- 更新界面
		self:OpenRightUI(me, self.MAX_DAILY_TIME * Env.GAME_FPS);
	end
	
	-- 记录玩家进入过秦始皇陵的天数
	if me.GetTask(self.TASK_GROUP_ID, self.TASK_USE_TIME) ~= 0 then
		StudioScore:OnActivityFinish("huangling", me);
		Stats.Activity:AddCount(me, Stats.TASK_COUNT_QINSHIHUANG, 1);
	end
	
	me.SetTask(self.TASK_GROUP_ID, self.TASK_USE_TIME, 0);
	
	-- 清空每天使用的炼化声望物品数
	me.SetTask(self.TASK_GROUP_ID, self.TASK_REFINE_ITEM, 0);
	
	-- 删除任务

	if Task:GetPlayerTask(me).tbTasks[529] then
	me.Msg("Thật không may, hôm qua nhiệm vụ Tần Lăng hết hạn hoàn thành.");
		Task:CloseTask(529, "failed");
	end
	
	--每日任务清0
	me.SetTask(1025, 77, 0);
end

function tbQinshihuang:WeekEvent()
	--每周任务清0
	me.SetTask(1025, 78, 0);
end

-- 使用夜明珠回调
function tbQinshihuang:OnUseYemingzhu(nPlayerId)
	
	-- 通过ID找玩家对象
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then		
		return;
	end
	
	-- 判断列表中有这个人
	if not self.tbPlayerList[nPlayerId] then
		Dialog:SendInfoBoardMsg(pPlayer, "<color=red>Vật phẩm chỉ có thể sử dụng bên trong Tần Lăng!<color>");
		return;
	end
	
	-- 取buff等级
	local nSkillLevel, _, nSkillFrame = pPlayer.GetSkillState(1413);
	
	-- 当前地图级别
	local nMapLevel = self.tbPlayerList[nPlayerId].nMapLevel;
	
	-- 玩家荣誉等级
	local nHonorLevel = pPlayer.GetHonorLevel();
	
	-- 不需要加buff
	if not self.tbYemingzhu[nMapLevel][nHonorLevel] or self.tbYemingzhu[nMapLevel][nHonorLevel] <= 0 then
		local szMsg = "Cơ thể vẫn còn khả năng chống lại khí độc, không cần sử dụng thêm!";
		self:SendMessage(pPlayer, self.MSG_CHANNEL, szMsg);
		self:SendMessage(pPlayer, self.MSG_MIDDLE, szMsg);
		return;
	end
	
	local nBaseFrame = 60 * 60 * Env.GAME_FPS;
	
	-- 已经有buffer
	if nSkillLevel > 0 then
		
		-- buffer比地图等级高，比如4层buffer人在3层
		if nSkillLevel > nMapLevel - 1 then
			local szMsg = string.format("Bạn đã nhận được hiệu quả Dạ Minh Châu rồi, không thể tiếp tục sử dụng!", nSkillLevel + 1, nMapLevel);
			self:SendMessage(pPlayer, self.MSG_CHANNEL, szMsg);
			self:SendMessage(pPlayer, self.MSG_MIDDLE, szMsg);
			return;
			
		-- buffer和地图等级匹配，可以累加
		elseif nSkillLevel == nMapLevel - 1 then
			if nSkillFrame + nBaseFrame > 10 * 60 * 60 * Env.GAME_FPS then
				Dialog:Say(string.format("Xin lỗi, %s hiệu quả Dạ Minh Châu là khoảng hơn 10 giờ, không thể tiếp tục sử dụng.", nMapLevel));
				return;
			else
				nSkillFrame = nSkillFrame + nBaseFrame;
			end
		
		-- buffer比地图等级低，清0重加
		else
			nSkillFrame = nBaseFrame;
		end
	else
		nSkillFrame = nBaseFrame;
	end
	
	-- 得到需要的夜明珠数量
	local nNum = tonumber(self.tbYemingzhu[nMapLevel][nHonorLevel]);
	
	-- 判断身上夜明珠数量
	local nFind = pPlayer.GetItemCountInBags(18, 1, 357, 1);
	
	if nFind < nNum then
		Dialog:Say("Số lượng Dạ Minh Châu trên người không đủ.", {"Tôi biết rồi"});
		return;
	end
	
	-- 扣除夜明珠
	local bRet = pPlayer.ConsumeItemInBags(nNum, 18, 1, 357, 1);
	
	-- todo: check return
	pPlayer.AddSkillState(1413, nMapLevel - 1, 1, nSkillFrame, 1, 1);
	
	-- 成就，使用夜明珠
	if self.MAP_LIST[me.nMapId] then
		Achievement:FinishAchievement(pPlayer, 331);
	end
end

-- 需要数量
function tbQinshihuang:GetCostNum(pPlayer)
	
	local nPlayerId = pPlayer.nId;
	
	-- 判断列表中有这个人
	if not self.tbPlayerList[nPlayerId] then
		return 0;
	end
	
	-- 当前地图级别
	local nMapLevel = self.tbPlayerList[nPlayerId].nMapLevel;
	
	-- 玩家荣誉等级
	local nHonorLevel = pPlayer.GetHonorLevel();
	
	local nNum = self.tbYemingzhu[nMapLevel][nHonorLevel];
	
	-- 不需要加buff
	if not nNum then
		return 0;
	end
	
	return nNum;
end

-- 加负面buff，恢复正面buff
function tbQinshihuang:OnMapEffect(nPlayerId, nMapLevel)
	
	-- 通过ID找玩家对象
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	
	-- 找不到返回
	if not pPlayer then		
		return;
	end
	
	-- 当前地图级别
	local nMapLevel = self.tbPlayerList[nPlayerId].nMapLevel;
	
	-- 玩家荣誉等级
	local nHonorLevel = PlayerHonor:GetPlayerMaxHonorLevel(pPlayer);
	
	-- 不需要加buff
	if not self.tbYemingzhu[nMapLevel][nHonorLevel] or self.tbYemingzhu[nMapLevel][nHonorLevel] <= 0 then
		return;
	end
	
	-- 加负面buff(10小时)
	pPlayer.AddSkillState(1412, nMapLevel - 1, 1, 10 * 60 * 60 * Env.GAME_FPS, 1, 1);
	
	self:SendMessage(pPlayer, self.MSG_BOTTOM, "Khí độc Tần Lăng khuếch tán, bạn khó có thể di chuyển, theo truyền thuyết trong giang hồ sử dụng <color=yellow>Dạ Minh Châu<color> có thể chống lại khí độc!");
	self:SendMessage(pPlayer, self.MSG_CHANNEL, string.format("Bạn hiện tại đang bước vào tầng %d Tần Lăng, do khí độc Tần Lăng khuếch tán, bạn khó có thể di chuyển, <color=yellow>theo truyền thuyết trong giang hồ sử dụng Dạ Minh Châu có thể chống lại khí độc<color>.", nMapLevel));
	
	-- 恢复正面buff
	local nBuffLevel = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_BUFF_LEVEL);
	local nBuffFrame = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_BUFF_FRAME);
	
	-- 如果有时间，并且不小于当前负buff等级
	if nBuffLevel > 0 and nBuffFrame > 36 and nBuffLevel >= nMapLevel - 1 then
		pPlayer.AddSkillState(1413, nBuffLevel, 1, nBuffFrame, 1, 1);
	
	-- 否则就清了
	else
		if pPlayer.GetSkillState(1413) > 0 then
			pPlayer.RemoveSkillState(1413);
		end
	end
end

-- 清楚所有buff，记录正面buff属性
function tbQinshihuang:OnMapLeave(nPlayerId, nMapLevel)
	
	-- 通过ID找玩家对象
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	
	-- 找不到返回
	if not pPlayer then		
		return;
	end
	
	-- 出错了#-#
	if not self.tbPlayerList[nPlayerId] then
		Dbg:WriteLog("Boss_Qinling", "Vượt qua bản đồ bất thường", pPlayer.szName, pPlayer.szAccount);
		return;
	end
	
	-- 记录正面buff
	local nSkillLevel, _, nEndFrame = pPlayer.GetSkillState(1413);
	
	if nSkillLevel > 0 and nEndFrame > 36 then
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_BUFF_LEVEL, nSkillLevel);
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_BUFF_FRAME, nEndFrame);
	else		
		-- 玩家荣誉等级
		local nHonorLevel = PlayerHonor:GetPlayerMaxHonorLevel(pPlayer);
		
		if pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_BUFF_LEVEL) + 1 >= nMapLevel then
			if self.tbYemingzhu[nMapLevel][nHonorLevel] and self.tbYemingzhu[nMapLevel][nHonorLevel] > 0 then
				pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_BUFF_LEVEL, 0);
				pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_BUFF_FRAME, 0);
			end
		end
	end
	
	-- 正负buff全清了
	if pPlayer.GetSkillState(1412) > 0 then
		pPlayer.RemoveSkillState(1412);
	end
	
	if pPlayer.GetSkillState(1413) > 0 then
		pPlayer.RemoveSkillState(1413);
	end
end

-- 记录秦始皇ID
function tbQinshihuang:OnProtectBoss(nIndex, nTempId, nStep, tbDamage)	
	
	local tbBoss = self.tbBoss[nIndex]; 
	if not tbBoss then
		return;
	end
	
	tbBoss.nTempId = nTempId
	tbBoss.nStep = nStep;
	tbBoss.tbDamage = tbDamage or {};
	
	-- 公告	
	local szMsg = string.format("Sát thương Tần Thủy Hoàng nhiều nhất: \n", tbBoss.szName);
	
	-- 排序
	local tbSort = {unpack(tbDamage)};
	table.sort(tbSort, self._SortDamage);
	
	-- 输出信息
	for i = 1, 3 do
		if tbSort[i] then
			local szCaptainName = nil;
			if tbSort[i].nPlayerId > 0 then
				if tbSort[i].nTeamId == 0 then
					szCaptainName = KGCPlayer.GetPlayerName(tbSort[i].nPlayerId);
				else
					local tbPlayer = KTeam.GetTeamMemberList(tbSort[i].nTeamId) or {};
					if tbPlayer[1] then
						szCaptainName = KGCPlayer.GetPlayerName(tbPlayer[1]);
					end
				end
			end
			if szCaptainName then
				szMsg = szMsg .. string.format("<color=green>Hạng %d: <color>", i) .. "<color=yellow>Đội của " .. szCaptainName .. "<color>\n";
			end
		end
	end
	
	-- 广播给玩家
	self:BroadCast(self.MSG_CHANNEL, szMsg);
end

tbQinshihuang._SortDamage = function(tbDamage1, tbDamage2)
	return tbDamage1.nDamage > tbDamage2.nDamage;
end

-- 返回步骤
function tbQinshihuang:GetBossStep(nIndex)
	local tbBoss = self.tbBoss[nIndex];
	if tbBoss then
		return tbBoss.nStep or 0;
	end
	return 0;
end

-- 恢复战斗
function tbQinshihuang:RecoverBoss(nRate, nIndex)
	
	local tbBoss = self.tbBoss[nIndex];
	if not tbBoss or not tbBoss.nTempId then
		return;
	end
	
	local pTempNpc = KNpc.GetById(tbBoss.nTempId);
	if pTempNpc then
		pTempNpc.Delete();
	end
	
	-- 战斗秦始皇
	local pNpc = KNpc.Add2(tbBoss.nNpcId, 120, -1, tbBoss.tbPos[1], tbBoss.tbPos[2], tbBoss.tbPos[3]);
	
	pNpc.AddLifePObserver(80);
	pNpc.AddLifePObserver(50);
	pNpc.AddLifePObserver(20);
	
	-- 设置掉落物品的时候是否回调脚本
	pNpc.SetLoseItemCallBack(1);
	
	if pNpc then 
		local nReduceLife = math.floor(pNpc.nMaxLife * nRate);
		pNpc.ReduceLife(nReduceLife);
		
		-- 恢复伤害记录
		for i = 1, 3 do
			if tbBoss.tbDamage[i] then			
				pNpc.SetDamageTable(i,
					tbBoss.tbDamage[i].nTeamId,
					tbBoss.tbDamage[i].nPlayerId,
					tbBoss.tbDamage[i].nTime,
					tbBoss.tbDamage[i].nDamage
				);
			end
		end
	end
end

-- 死亡计数
function tbQinshihuang:AddDeathCount(nIndex)
	
	local tbBoss = self.tbBoss[nIndex];
	if not tbBoss then
		return;
	end
	
	if not tbBoss.nDeathCount then
		tbBoss.nDeathCount = 0;
	end
	
	tbBoss.nDeathCount = tbBoss.nDeathCount + 1;
	
	if (tbBoss.nStep == 1 and tbBoss.nDeathCount == 4) then
		self:RecoverBoss(0.21, nIndex);
		
	elseif (tbBoss.nStep == 2 and tbBoss.nDeathCount == 8) then
		self:RecoverBoss(0.51, nIndex);
		
	elseif (tbBoss.nStep == 3 and tbBoss.nDeathCount == 12) then
		self:RecoverBoss(0.81, nIndex);
	end
end

-- 清boss信息
function tbQinshihuang:ClearInfo(nIndex)

	GCExcute({"Boss.Qinshihuang:ClearBossReal_GC"});
	
	local tbBoss = self.tbBoss[nIndex];
	if not tbBoss then
		return;
	end
	
	tbBoss.nStep = nil;
	tbBoss.nDeathCount = nil;
	tbBoss.tbDamage = nil;
	tbBoss.nTempId = nil;
	tbBoss.tbPos = nil;
	tbBoss.nIndex = nil;
	tbBoss.nNpcId = nil;
	tbBoss.szName = nil;
end

-- 清传送npc
function tbQinshihuang:ClearPassNpc()
	for _, nNpcDwId in pairs(self.tbPasser) do
		local pNpc = KNpc.GetById(nNpcDwId);
		if pNpc then
			pNpc.Delete();
		end
	end
	self._nPasserEffect = 0;
end

-- 死亡事件
function tbQinshihuang:OnPlayerDeath(pKillerNpc)
	
	-- 成就，秦陵内击杀玩家
	if pKillerNpc then
		local pPlayer = pKillerNpc.GetPlayer();
		if pPlayer and self.tbPlayerList[pPlayer.nId] then
			Achievement:FinishAchievement(pPlayer, 334);
			Achievement:FinishAchievement(pPlayer, 335);
			if pKillerNpc.nKind == 1 then
				DataLog:WriteELog(pPlayer.szName, 2, 2, me.szName, me.nMapId);
			end
		end
	end
		
	if self.tbPlayerList[me.nId] then
		
		if self.tbPlayerList[me.nId].nMapLevel == 1 then
			me.SetTask(self.TASK_GROUP_ID, self.TASK_REVTIME, GetTime());
		end
		
		if self.tbPlayerList[me.nId].nMapLevel > 3 then
			me.ReviveImmediately(1);
			me.SetFightState(0);
			self:_MapResetState(me);
			me.NewWorld(1538, 1762, 3191);		-- 第三层的安全区			
			
		else
			me.ReviveImmediately(1);
			me.SetFightState(0);
			self:_MapResetState(me);
			me.NewWorld(1536, 1567, 3629);		-- 第一层的安全区			
		end
	end
end

-- 保存真的秦皇mapid
function tbQinshihuang:OnBossReal_GS(nRealMap)
	
	self.tbBoss.nRealMap = nRealMap;
	
	-- 刷传送点
	local tbPos = 
	{
		[1] = {1536, 1401, 3620, "Tần lăng tầng 3"},    
		[2] = {1536, 1591, 3449, "Tần lăng tầng 5"},
		[3] = {1539, 1609, 3899, "Tần lăng tầng 5"},
		[4] = {1539, 1985, 3532, "Tần lăng tầng 5"},
	};
	for i = 1, 4 do
		if SubWorldID2Idx(tbPos[i][1]) >= 0 then
			local pNpc = KNpc.Add2(6794, 120, -1, tbPos[i][1], tbPos[i][2], tbPos[i][3]);
			if pNpc then
				pNpc.szName = tbPos[i][4];
				table.insert(self.tbPasser, pNpc.dwId);
			end
			self._nPasserEffect = 1;
		end
	end
end

-- call boss 回调
function tbQinshihuang:OnBossCallOut(pNpc)
		
	local tbBoss = 
	{
		[2426] = 1,
		[2474] = 1,
		[2475] = 1,
		[2451] = 2,
		[2452] = 2,
		[2453] = 2,
		[2454] = 2,
		[2455] = 2,
	};
	
	local nType = tbBoss[pNpc.nTemplateId];
	if not nType then
		return 0;
	end
	
	-- 秦始皇
	if nType == 1 then
		
		local tbFloor = {[1536] = "Tầng 1", [1538] = "Tầng 3", [1540] = "Tầng 5"};
		local nMapId, nMapX, nMapY = pNpc.GetWorldPos();
		local nIndex = self.tbMapIndex[nMapId];
		if nIndex then
			
			-- 初始化boss信息
			local tbBoss = {};
			tbBoss.nStep = 0;
			tbBoss.nDeathCount = 0;
			tbBoss.nTempId = nil;
			tbBoss.tbDamage = {};
			tbBoss.tbPos = {nMapId, nMapX, nMapY};
			tbBoss.nIndex = nIndex;
			tbBoss.nNpcId = pNpc.nTemplateId;
			tbBoss.szName = pNpc.szName;
			
			-- 秦始皇编号
			self.tbBoss[nIndex] = tbBoss;
			
			GCExcute({"Boss.Qinshihuang:OnBossReal_GC"});
		end
		
		-- 秦始皇
		local szMsg = string.format("<color=green>Theo lời kể của những kẻ trộm mộ thuật lại, tại %s Tần Lăng, %s đã thức tỉnh!<color>", tbFloor[nMapId] or "đâu đó", pNpc.szName);
		self:BroadCast(self.MSG_TOP, szMsg);
		self:BroadCast(self.MSG_GLOBAL, szMsg);
		
		pNpc.AddLifePObserver(80);
		pNpc.AddLifePObserver(50);
		pNpc.AddLifePObserver(20);
		
		-- 设置掉落物品的时候是否回调脚本
		pNpc.SetLoseItemCallBack(1);
		
		-- 成就，刷出秦始皇
		local tbPlayerList = KPlayer.GetMapPlayer(pNpc.nMapId);
		for _, pPlayer in pairs(tbPlayerList) do
			Achievement:FinishAchievement(pPlayer, 350);
		end
		
		return 1;
		
	elseif nType == 2 then
		
		-- 小boss
		local szMsg = string.format("Nghe nói cách đó không xa %s đã xuất hiện!", pNpc.szName);
		self:BroadCast(self.MSG_CHANNEL, szMsg);
		self:BroadCast(self.MSG_BOTTOM, szMsg);
		
		return 1;
	end
	
	return 0;
end

-- gc to gs
function tbQinshihuang:DoUpdateQinBoss(nTemplateId, nMapId, nMapX, nMapY)
	
	local nMapIndex = SubWorldID2Idx(nMapId);
	
	if nMapIndex < 0 then
		return;
	end	

	if Boss.tbUniqueBossCallOut[nTemplateId] then
		return;
	end	
	
	-- add npc 
	local pNpc = KNpc.Add2(nTemplateId, 120, -1, nMapId, nMapX, nMapY, 0, 1);
		
	if pNpc then
		
		-- flag
		Boss.tbUniqueBossCallOut[nTemplateId] = 1;
		
		local szMsg = string.format("Nghe nói cách đó không xa %s đã xuất hiện!", pNpc.szName);
		self:BroadCast(self.MSG_CHANNEL, szMsg);
		self:BroadCast(self.MSG_BOTTOM, szMsg);
	end
end

function tbQinshihuang:DoOpenQinFive()
	self.bOpenQinFive = 1;
end

function tbQinshihuang:DoCloseQinFive()
	self.bOpenQinFive = 0;
	self:ClearPassNpc();
end

function tbQinshihuang:CheckOpenQinFive()
	return self.bOpenQinFive;
end

function tbQinshihuang:_CloseSystem()	
	if self.tbPlayerList then	
		for nPlayerId, tbPlayerMap in pairs(self.tbPlayerList) do	
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				pPlayer.SetFightState(0);
				pPlayer.NewWorld(self:GetLeaveMapPos());			
			else
				self.tbPlayerList[nPlayerId] = nil;
			end
		end
	end
	self._bOpen = 0;
end

function tbQinshihuang:_OpenSystem()
	self._bOpen = 1;
end

function tbQinshihuang:_CheckState()
	return self._bOpen;
end

function tbQinshihuang:OnPlayerLogin()

	if self.MAP_LIST[me.nMapId] then
		return;
	end
	
	local nProtect = me.GetTask(self.TASK_GROUP_ID, self.TASK_PROTECT);
	if nProtect ~= 1 then
		return;
	end
	
	me.nPkModel = Player.emKPK_STATE_PRACTISE;
	me.nForbidChangePK	= 0;
	me.DisabledStall(0);

	if me.GetSkillState(1412) > 0 then
		me.RemoveSkillState(1412);
	end
	
	if me.GetSkillState(1413) > 0 then
		me.RemoveSkillState(1413);
	end
	
	me.SetTask(self.TASK_GROUP_ID, self.TASK_PROTECT, 0);
end

function tbQinshihuang:_CheckTime()
	local nTime = tonumber(GetLocalDate("%H%M"))
	local tbTime = nil;
	if (EventManager.IVER_bOpenTiFu == 1) then
		tbTime = 
		{			
			{0900, 1030},
			{1300, 1430},
			{1700, 1830},
			{2100, 2230},
			{0100, 0230},
			{0500, 0630},
		};
	else
		tbTime = 
		{
			{1500, 1630},
			{2200, 2330},
		};
	end
	for _, tbInfo in pairs(tbTime) do
		if nTime >= tbInfo[1] and nTime <= tbInfo[2] then
			return 1;
		end
	end
	return 0;
end

function tbQinshihuang:_MapSetState(pPlayer)
	pPlayer.nPkModel = Player.emKPK_STATE_TONG;
	pPlayer.DisabledStall(1);	
	pPlayer.nForbidChangePK	= 1;
end

function tbQinshihuang:_MapResetState(pPlayer)
	pPlayer.DisabledStall(0);
	pPlayer.nForbidChangePK	= 0;
end

-- 注册玩家每日事件
PlayerSchemeEvent:RegisterGlobalDailyEvent({Boss.Qinshihuang.DailyEvent, Boss.Qinshihuang});

-- 注册每周事件
PlayerSchemeEvent:RegisterGlobalWeekEvent({Boss.Qinshihuang.WeekEvent, Boss.Qinshihuang});



-- 注册启动事件
ServerEvent:RegisterServerStartFunc(Boss.Qinshihuang.Init, Boss.Qinshihuang);

-- 注册死亡事件
if Boss.Qinshihuang.nEventDeathId then
	PlayerEvent:UnRegisterGlobal("OnDeath", Boss.Qinshihuang.nEventDeathId)	
end
Boss.Qinshihuang.nEventDeathId = PlayerEvent:RegisterGlobal("OnDeath", Boss.Qinshihuang.OnPlayerDeath, Boss.Qinshihuang);

-- 注册登陆事件
if Boss.Qinshihuang.nEventLoginId then
	PlayerEvent:UnRegisterGlobal("OnLogin", Boss.Qinshihuang.nEventLoginId)	
end
Boss.Qinshihuang.nEventLoginId = PlayerEvent:RegisterGlobal("OnLogin", Boss.Qinshihuang.OnPlayerLogin, Boss.Qinshihuang);
