-------------------------------------------------------
-- 文件名　：keyimen_gs.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2012-02-22 11:31:58
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\boss\\keyimen\\keyimen_def.lua");

-------------------------------------------------------
-- 功能函数
-------------------------------------------------------

-- 消息封装
function Keyimen:SendMessage(pPlayer, nType, szMsg)
	if nType == self.MSG_CHANNEL then
		pPlayer.Msg(szMsg);
	elseif nType == self.MSG_BOTTOM then
		Dialog:SendBlackBoardMsg(pPlayer, szMsg);
	elseif nType == self.MSG_MIDDLE then
		Dialog:SendInfoBoardMsg(pPlayer, szMsg);
	end
end

-- 广播消息
function Keyimen:BroadCast(nType, szMsg)
	if nType == self.MSG_TOP then
		KDialog.NewsMsg(1, Env.NEWSMSG_NORMAL, szMsg);
	elseif nType == self.MSG_GLOBAL then
		KDialog.MsgToGlobal(szMsg);	
	else
		GCExcute({"Keyimen:BroadCast_GC", szMsg, nType});
	end
end

-- 广播回调
function Keyimen:OnBroadCast(szMsg, nType)
	for szPlayerName, _ in pairs(self.tbPlayerList) do
		local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
		if pPlayer then
			self:SendMessage(pPlayer, nType, szMsg);
		end
	end
end

-- 关闭信息界面
function Keyimen:CloseRightUI(pPlayer)
	Dialog:ShowBattleMsg(pPlayer, 0, 0);
end

-- 更新右侧信息
function Keyimen:UpdateRightUI(pPlayer)
	
	if not self.tbPlayerList[pPlayer.szName] then
		self:CloseRightUI(pPlayer);
		return 0;
	end
	
	if Lib:CountTB(self.tbDamageList) <= 0 then
		self:CloseRightUI(pPlayer);
		return 0;
	end
	
	local szMsg = "";
	for nBossDwId, tbInfo in pairs(self.tbDamageList) do
		if tbInfo.nMapId == pPlayer.nMapId then
			local tbDamage = tbInfo.tbDamage;
			szMsg = szMsg .. string.format("<color=yellow>\n[%s]\n\n<color>", tbInfo.szName);
			for i = 1, 3 do
				local nKinId = tbDamage[i].dwKinId;
				local pKin = KKin.GetKin(nKinId);
				if pKin then
					local nTime = math.floor(tbDamage[i].nTime / Env.GAME_FPS) + 50;
					local nDamage = math.floor(tbDamage[i].nDamage / 1000);
					local szKinName = pKin.GetName();
					szMsg = szMsg .. string.format("<color=green>%s. Gia tộc: <color=cyan>%s<color>\n   <color=green>Sát thương: <color=cyan>%s<color>\n   <color=green>Thời gian: <color=cyan>%s<color>\n<color>", i, szKinName, nDamage, nTime);
				else
					szMsg = szMsg .. string.format("<color=green>%s. - Chưa có thông tin -\n<color>", i);
				end
			end
		end;
	end
	
	Dialog:SetBattleTimer(pPlayer, "", nil);
	Dialog:SendBattleMsg(pPlayer, szMsg, 1);
	Dialog:ShowBattleMsg(pPlayer, 1, 0);
end

-- 批量更新
function Keyimen:UpdateAllRightUI()
	for szPlayerName, _ in pairs(self.tbPlayerList) do
		local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
		if pPlayer then
			self:UpdateRightUI(pPlayer);
		end
	end
end

-- 获取披风等级
function Keyimen:GetMantleLevel(pPlayer)
	local pItem = pPlayer.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_MANTLE, 0);
	if not pItem then
		return 0;
	end
	return pItem.nLevel;
end

-- 传送到回程点
function Keyimen:SafeLeave(pPlayer)
	local nMapId, _, nMapX, nMapY = pPlayer.GetDeathRevivePos();
	pPlayer.NewWorld(nMapId, nMapX / 32, nMapY / 32);
end

-------------------------------------------------------
-- 入口相关
-------------------------------------------------------

function Keyimen:CheckPlayer(pPlayer)
	
	-- 系统开关
	if self:CheckIsOpen() ~= 1 then
		self:SendMessage(pPlayer, self.MSG_MIDDLE, "Xin lỗi, nơi này chưa thể vào.");
		return 0;
	end
	
	-- 加入家族
	local nKinId, nMemberId = pPlayer.GetKinMember();	
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		self:SendMessage(pPlayer, self.MSG_MIDDLE, "Hãy gia nhập <color=yellow>Gia tộc<color> trước khi vào.");
		return 0;
	end
	
	-- 记名限制
	if pPlayer.nKinFigure == Kin.FIGURE_SIGNED then
		self:SendMessage(pPlayer, self.MSG_MIDDLE, "Thành viên <color=yellow>Chính thức<color> hoặc <color=yellow>Vinh dự<color> mới có thể vào.");
		return 0;
	end
	
	-- 等级限制
	if pPlayer.nLevel < self.MIN_LEVEL then
		self:SendMessage(pPlayer, self.MSG_MIDDLE, "Đạt <color=yellow>cấp độ 100<color> mới có thể vào bản đồ");
		return 0;
	end
	
	-- 披风限制
	if self:GetMantleLevel(pPlayer) < self.MIN_MANTLE then
		self:SendMessage(pPlayer, self.MSG_MIDDLE, "Cần trang bị phi phong <color=yellow>Hỗn Thiên<color> mới có thể tiến vào");
		return 0;
	end
	
	return 1;
end

-- 增加玩家
function Keyimen:AddPlayer(pPlayer)
	
	-- 设置状态
	pPlayer.nForbidChangePK = 1;					-- 禁止切换状态
	pPlayer.nPkModel = Player.emKPK_STATE_TONG;		-- 改为帮会模式
	pPlayer.SetLogoutRV(1);							-- 下线保护
	
	-- 玩家列表
	self.tbPlayerList[pPlayer.szName] = {};
	self.tbPlayerList[pPlayer.szName].nKillCount = 0;
	self.tbPlayerList[pPlayer.szName].nKinId = pPlayer.GetKinMember();
	self.tbPlayerList[pPlayer.szName].nTongId = pPlayer.dwTongId;
	
	-- 家族列表
	local nKinId = pPlayer.GetKinMember();
	local pKin = KKin.GetKin(nKinId);
	if pKin then
		if not self.tbKinList[nKinId] then
			self.tbKinList[nKinId] = {};
		end
		self.tbKinList[nKinId][pPlayer.szName] = 1;
	end
	
	-- 帮会列表
	local nTongId = pPlayer.dwTongId
	local pTong = KTong.GetTong(nTongId);
	if pTong then
		if not self.tbTongList[nTongId] then
			self.tbTongList[nTongId] = {};
		end
		self.tbTongList[nTongId][pPlayer.szName] = 1;
	end
	
	-- 保护时间
	Player:AddProtectedState(pPlayer, self.SUPER_TIME);
	
	-- 装备磨损
	pPlayer.AddSkillState(self.SKLLL_EQUIP_ID, 5, 1, 3600 * 10 * Env.GAME_FPS, 1, 1);
	self:SendMessage(pPlayer, self.MSG_CHANNEL, "Nhận được hiệu ứng <color=yellow>Tiêu Yên Thực Giáp<color>");
	
	-- 伤害加成
	local nCamp = self.MAP_LIST[pPlayer.nMapId];
	if nCamp > 0 and nCamp == 3 - Keyimen:GetTongCamp(nTongId) then
		pPlayer.AddSkillState(self.SKLLL_DAMAGE_ID, 8, 1, 3600 * Env.GAME_FPS, 1, 1);
		self:SendMessage(pPlayer, self.MSG_CHANNEL, "Nhận được hiệu ứng <color=yellow>Tiêm Binh Lợi Nhẫn<color>");
	end
	
	pPlayer.SetTask(self.TASK_GID, self.TASK_PROTECT, 1);
	self:SendMessage(pPlayer, self.MSG_BOTTOM, "Đã vào bản đồ <color=blue>Hình thức PK Bang hội<color>");
	
	local nDate = tonumber(GetLocalDate("%Y%m%d"))
	if pPlayer.GetTask(self.TASK_GID, self.TASK_ENTERMAP) ~= nDate then
		pPlayer.SetTask(self.TASK_GID, self.TASK_ENTERMAP, nDate);
		StatLog:WriteStatLog("stat_info", "keyimen_battle", "enter_map", pPlayer.nId, pPlayer.nMapId);
	end
end

-- 移除玩家
function Keyimen:RemovePlayer(pPlayer)

	-- 战斗状态
	pPlayer.nForbidChangePK = 0;
	pPlayer.nPkModel = Player.emKPK_STATE_PRACTISE;
	
	-- 移除列表
	if self.tbPlayerList[pPlayer.szName] then
		local nKinId = self.tbPlayerList[pPlayer.szName].nKinId;
		if self.tbKinList[nKinId] then
			self.tbKinList[nKinId][pPlayer.szName] = nil;
		end
		local nTongId = self.tbPlayerList[pPlayer.szName].nTongId;
		if self.tbTongList[nTongId] then
			self.tbTongList[nTongId][pPlayer.szName] = nil;
		end 
		self.tbPlayerList[pPlayer.szName] = nil;
	end
	
	-- 关闭界面
	self:CloseRightUI(pPlayer);
	
	-- 装备磨损
	if pPlayer.GetSkillState(self.SKLLL_EQUIP_ID) > 0 then
		pPlayer.RemoveSkillState(self.SKLLL_EQUIP_ID);
	end
	
	-- 伤害加成
	if pPlayer.GetSkillState(self.SKLLL_DAMAGE_ID) > 0 then
		pPlayer.RemoveSkillState(self.SKLLL_DAMAGE_ID);
	end
	
	pPlayer.SetTask(self.TASK_GID, self.TASK_PROTECT, 0);
	pPlayer.SetTask(self.TASK_GID, self.TASK_REVTIME, 0);
end

-------------------------------------------------------
-- 怪物相关
-------------------------------------------------------

-- 更新伤害
function Keyimen:UpdateBossDamage(nNpcDwId)
	
	local pNpc = KNpc.GetById(nNpcDwId)
	if not pNpc then
		return 0;
	end
	
	-- 获取伤害表
	local tbDamage = pNpc.GetKinDamageTable();
	if not tbDamage or #tbDamage <= 0 then
		return 0;
	end
	
	-- 排序表
	table.sort(tbDamage, function(a, b) return a.nDamage > b.nDamage end);

	-- 记录信息
	if not self.tbDamageList[nNpcDwId] then
		self.tbDamageList[nNpcDwId] = {};
	end

	self.tbDamageList[nNpcDwId].szName = pNpc.szName;
	self.tbDamageList[nNpcDwId].nMapId = pNpc.nMapId;
	self.tbDamageList[nNpcDwId].tbDamage = tbDamage;
	
	-- 更新右侧信息
	self:UpdateAllRightUI();
	
	return Env.GAME_FPS;
end

-- 刷新大boss
function Keyimen:UpdateBoss_GS(nBossId, nMapId, nMapX, nMapY, nCamp)
	
	if SubWorldID2Idx(nMapId) < 0 then
		return 0;
	end
	
	if self.tbActiveList[nBossId] then
		return 0;
	end
	
	local pNpc = KNpc.Add2(nBossId, self.NPC_LEVEL, -1, nMapId, nMapX, nMapY);
	if pNpc then
		self:BroadCast(self.MSG_BOTTOM, string.format("Thống soái <color=cyan>%s<color> cuối cùng đã xuất hiện trên Chiến trường Di Khắc Môn!", pNpc.szName));
		self:BroadCast(self.MSG_GLOBAL, string.format("<color=cyan>Một tiếng sấm lớn, Thống soái %s cuối cùng đã xuất hiện trên Chiến trường Di Khắc Môn!<color>", pNpc.szName));
		self.tbBossList[pNpc.dwId] = {};
		self.tbBossList[pNpc.dwId].nType = self.BOSS_TYPE;
		self.tbBossList[pNpc.dwId].nCamp = nCamp;
		self.tbBossList[pNpc.dwId].nStep = 1;
		self.tbBossList[pNpc.dwId].nTimer = self:StartTimer(Env.GAME_FPS, self.UpdateBossDamage, "UpdateBossDamage" .. pNpc.dwId, pNpc.dwId);
		for i, tbInfo in ipairs(self.BOSS_STEP) do
			pNpc.AddLifePObserver(tbInfo[1]);
		end
		pNpc.AddLifePObserver(20);
		self.tbActiveList[nBossId] = 1;
		StatLog:WriteStatLog("stat_info", "keyimen_battle", "born_boss", 0, nBossId, nMapId);
	end
end

-- 刷新小boss
function Keyimen:UpdateGuard_GS(nGuardId, nMapId, nMapX, nMapY, nCamp)

	if SubWorldID2Idx(nMapId) < 0 then
		return 0;
	end
	
	if self.tbActiveList[nGuardId] then
		return 0;
	end

	local pNpc = KNpc.Add2(nGuardId, self.NPC_LEVEL, -1, nMapId, nMapX, nMapY);
	if pNpc then
		self:BroadCast(self.MSG_BOTTOM, string.format("Vào thời điểm quan trọng, <color=green>%s<color> đã xuất chiến!<color>", pNpc.szName));
		self:BroadCast(self.MSG_CHANNEL, string.format("<color=green>Thời điểm quan trọng nhất, %s đã xuất hiện, mau tìm kiếm!<color>", pNpc.szName));
		self.tbBossList[pNpc.dwId] = {};
		self.tbBossList[pNpc.dwId].nType = self.GUARD_TYPE;
		self.tbBossList[pNpc.dwId].nCamp = nCamp;
		self.tbActiveList[nGuardId] = 1;
		StatLog:WriteStatLog("stat_info", "keyimen_battle", "born_boss", 0, nGuardId, nMapId);
	end
end

-- 刷新随机boss
function Keyimen:UpdateMonster_GS(nMonsterId, nMapId, nMapX, nMapY)

	if SubWorldID2Idx(nMapId) < 0 then
		return 0;
	end
	
	if self.tbActiveList[nMonsterId] then
		return 0;
	end
	
	local pNpc = KNpc.Add2(nMonsterId, self.NPC_LEVEL, -1, nMapId, nMapX, nMapY);
	if pNpc then
		local szMsg = string.format("<color=yellow>%s<color> đã xuất hiện, mau chóng tìm kiếm!", pNpc.szName);
		self:BroadCast(self.MSG_BOTTOM, szMsg);
		self:BroadCast(self.MSG_CHANNEL, szMsg);
		self.tbBossList[pNpc.dwId] = {};
		self.tbBossList[pNpc.dwId].nType = self.MONSTER_TYPE;
		self.tbActiveList[nMonsterId] = 1;
	end
end

-- boss死亡
function Keyimen:OnBossDeath(nBossDwId)
	
	local tbInfo = self.tbBossList[nBossDwId];
	if not tbInfo then
		return 0;
	end
	
	for _, nServantDwId in pairs(tbInfo.tbServant or {}) do
		local pNpc = KNpc.GetById(nServantDwId);
		if pNpc then
			pNpc.Delete();
		end
	end
	
	self:ClearTimer("UpdateBossDamage" .. nBossDwId);
	self.tbDamageList[nBossDwId] = nil
	self.tbBossList[nBossDwId] = nil;
	
	self:UpdateAllRightUI();
end

-- 刷出boss仆人
function Keyimen:OnAddServant(nBossDwId, nServantDwId)
	local tbInfo = self.tbBossList[nBossDwId];
	if not tbInfo then
		return 0;
	end
	if not tbInfo.tbServant then
		tbInfo.tbServant = {};
	end
	table.insert(tbInfo.tbServant, nServantDwId);
end

-- 更新幽玄龙柱
function Keyimen:UpdateDragon_GS(nNpcId, nMapId, nMapX, nMapY, nCamp, nIndex)
	
	-- 地图检测
	if SubWorldID2Idx(nMapId) < 0 then
		return 0;
	end

	if self:CheckPeriod() ~= 1 then
		return 0;
	end
	
	-- 隔1帧在刷出来
	Timer:Register(Env.GAME_FPS, self.OnUpdateDragon_GS, self, nNpcId, nMapId, nMapX, nMapY, nCamp, nIndex);
end

-- 刷出幽玄龙柱
function Keyimen:OnUpdateDragon_GS(nNpcId, nMapId, nMapX, nMapY, nCamp, nIndex)
	if self:CheckPeriod() ~= 1 then
		return 0;
	end
	
	local pNpc = KNpc.Add2(nNpcId, self.NPC_LEVEL, -1, nMapId, nMapX, nMapY);
	if pNpc then
		self.tbDragonList[pNpc.dwId] = {};
		self.tbDragonList[pNpc.dwId].nType = self.DRAGON_TYPE;
		self.tbDragonList[pNpc.dwId].nNpcId = nNpcId;
		self.tbDragonList[pNpc.dwId].nMapId = nMapId;
		self.tbDragonList[pNpc.dwId].nMapX = nMapX;
		self.tbDragonList[pNpc.dwId].nMapY = nMapY
		self.tbDragonList[pNpc.dwId].nCamp = nCamp;
		self.tbDragonList[pNpc.dwId].nIndex = nIndex;
	end
	return 0;
end

-- 龙柱重生
function Keyimen:RebornDragon_GS(nNpcdwId)
	if self:CheckPeriod() ~= 1 then
		return 0;
	end
	local tbInfo = self.tbDragonList[nNpcdwId];
	if not tbInfo then
		return 0;
	end
	self.tbDragonList[nNpcdwId] = nil;
	self:UpdateDragon_GS(tbInfo.nNpcId, tbInfo.nMapId, tbInfo.nMapX, tbInfo.nMapY, tbInfo.nCamp, tbInfo.nIndex);
end

-- 刷出赤焰龙魂
function Keyimen:UpdateDialogNpc(nNpcdwId, nTongId, szTongName)
	
	local tbInfo = self.tbDragonList[nNpcdwId];
	if not tbInfo then
		return 0;
	end
	
	-- 帮会未选择阵营
	local nCamp = self:GetTongCamp(nTongId)
	if nCamp <= 0 or 3 - nCamp ~= tbInfo.nCamp then
		self:RebornDragon_GS(nNpcdwId);
		return 0;
	end
	
	-- 帮会未开启任务
	local tbTask = self.tbTongBuffer[nTongId].tbTask;
	if not tbTask then
		self:RebornDragon_GS(nNpcdwId);
		return 0;
	end
	
	-- 是否为目标龙魂
	local nFind = 0;
	for i, nValue in ipairs(tbTask) do
		if tbInfo.nIndex == nValue then
			nFind = i;
			break;
		end
	end
	
	-- npc记录帮会id和索引
	if nFind > 0 then
		local pNpc = KNpc.Add2(self.NPC_DIALOG_LIST[nFind], self.NPC_LEVEL, -1, tbInfo.nMapId, tbInfo.nMapX, tbInfo.nMapY);
		if pNpc then
			pNpc.GetTempTable("Keyimen").nTongId = nTongId;
			pNpc.GetTempTable("Keyimen").nIndex = nFind;
			pNpc.SetTitle(string.format("<color=gold>%s-Long Hồn Sứ<color>", szTongName));
			local szMsg = string.format("Thành viên Bang hội đã  phóng thích %s <pos=%s,%s,%s>, mau đến đó...", pNpc.szName, tbInfo.nMapId, tbInfo.nMapX, tbInfo.nMapY);
			KTong.Msg2Tong(nTongId, szMsg, 0);
			Timer:Register(self.DIALOG_TIME * Env.GAME_FPS, self.OnDelDialogNpc, self, pNpc.dwId, nNpcdwId);
		end
	else
		self:RebornDragon_GS(nNpcdwId);
	end
end

-- 删除赤焰龙魂
function Keyimen:OnDelDialogNpc(nNpcdwId, nDragonDwId)
	local pNpc = KNpc.GetById(nNpcdwId);
	if pNpc then
		pNpc.Delete();
	end
	self:RebornDragon_GS(nDragonDwId);
	return 0;
end

-------------------------------------------------------
-- 阵营相关
-------------------------------------------------------

-- 判断选择阵营
function Keyimen:GetTongPreCamp(nTongId)
	local tbInfo = self.tbTongBuffer[nTongId];
	if not tbInfo then
		return 0;
	end
	return tbInfo.nPreCamp or 0;
end

-- 帮会选择阵营
function Keyimen:TongSignup_GS(nTongId, nCamp)
	GCExcute({"Keyimen:TongSignup_GC", nTongId, nCamp});
end

-- 读取玩家阵营
function Keyimen:GetPlayerTongCamp(pPlayer)
	return self:GetTongCamp(pPlayer.dwTongId);
end

-- 家族插旗判定
function Keyimen:CheckKinFlag_GS(pPlayer, nTongId, nKinId)
	
	-- 选择阵营
	local nCamp = self:GetTongCamp(nTongId);
	if nCamp <= 0 then
		return 0;
	end
	
	local nMapCamp = self.MAP_LIST[pPlayer.nMapId];
	if nMapCamp ~= 3 - nCamp then
		return 0;
	end
	
	-- 第一次插旗
	local tbInfo = self.tbKinBuffer[nKinId];
	if not tbInfo then
		return 1;
	end
	
	-- 道具锁
	if tbInfo.nTmpLock then
		return 0;
	end
	
	-- 时间间隔
	local nTime = GetTime() - (tbInfo.nFlagTime or 0);
	if nTime < self.FLAG_INTERVAL then
		return nTime - self.FLAG_INTERVAL;
	end
	
	return 1;
end

-- 家族插旗申请
function Keyimen:KinFlag_GS(pPlayer, nTongId, nKinId)
	if not self.tbKinBuffer[nKinId] then
		self.tbKinBuffer[nKinId] = {};
	end
	self.tbKinBuffer[nKinId].nTmpLock = 1;
	local nMapId, nMapX, nMapY = pPlayer.GetWorldPos();
	GCExcute({"Keyimen:KinFlag_GC", pPlayer.nId, nTongId, nKinId, {nMapId, nMapX, nMapY}});
end

-- 获取旗子坐标
function Keyimen:GetKinFlagPos(nKinId)
	local tbInfo = self.tbKinBuffer[nKinId];
	if not tbInfo then
		return 0;
	end
	local nFlagTime = GetTime() - (tbInfo.nFlagTime or 0);
	if nFlagTime > self.FLAG_TIME then
		return 0;
	end
	return self.FLAG_TIME - nFlagTime, tbInfo.tbFlagPos;
end

-- 家族插旗失败
function Keyimen:KinFlagFailed_GS(nPlayerId, nKinId)
	local tbInfo = self.tbKinBuffer[nKinId];
	if tbInfo then
		tbInfo.nTmpLock = nil;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		self:SendMessage(pPlayer, self.MSG_CHANNEL, "Cắm cờ thất bại.");
	end
end

-- 家族插旗成功
function Keyimen:KinFlagSuccess_GS(nPlayerId, nTongId, nKinId, tbPos)
	local nMapId, nMapX, nMapY = unpack(tbPos);
	if SubWorldID2Idx(nMapId) >= 0 then
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			self:SendMessage(pPlayer, self.MSG_CHANNEL, "Cắm cờ thành công, hãy thông báo cho mọi người.");
			KKin.Msg2Kin(nKinId, string.format("<color=yellow>%s<color> tại doanh trại đối phương đã cắm cờ, thành viên gia tộc có thể trực tiếp truyền tống.", pPlayer.szName), 0);
		end
		local nCamp = self:GetTongCamp(nTongId);
		if self.CAMP_FLAG_LIST[nCamp] then
			local pNpc = KNpc.Add2(self.CAMP_FLAG_LIST[nCamp], self.NPC_LEVEL, -1, nMapId, nMapX, nMapY);
			if pNpc then
				local pKin = KKin.GetKin(nKinId);
				if pKin then
					pNpc.szName = string.format("Cờ Gia tộc [%s]", pKin.GetName());
				end
				Timer:Register(self.FLAG_TIME * Env.GAME_FPS, self.OnTimerDelNpc, self, pNpc.dwId);
			end
		end
	end
end

function Keyimen:OnTimerDelNpc(dwNpcId)
	local pNpc = KNpc.GetById(dwNpcId);
	if pNpc then
		pNpc.Delete();
	end
	return 0;
end

-- 帮会开启任务
function Keyimen:TongStartTask_GS(nTongId)
	GCExcute({"Keyimen:TongStartTask_GC", nTongId});
end

-- 检测任务是否完成
function Keyimen:CheckPlayerTaskFinish(pPlayer)
	for i, nTask in ipairs(self.TASK_FINISH) do
		if pPlayer.GetTask(self.TASK_GID, nTask) ~= 1 then
			return 0;
		end
	end
	return 1;
end

-- 获取帮会任务id
function Keyimen:GetPlayerTongTask(pPlayer)
	local nTongId = pPlayer.dwTongId;
	local nCamp = self:GetTongCamp(nTongId)
	if nCamp <= 0 then
		return nil;
	end
	local tbTask = self.tbTongBuffer[nTongId].tbTask;
	return tbTask;
end

-- 完成任务
function Keyimen:FinishTaskAward(pPlayer)
	
	-- 最后传到奖励面版脚本的数据结构
	local tbGeneralAward = {};
	local szAwardTalk = "\n    Xin chúc mừng! Cuối cùng Kiếm Thế đã trở lại yên bình, đây là phần thưởng của ngươi.\n";	-- 奖励时说的话
	
	tbGeneralAward.tbFix = {};
	tbGeneralAward.tbOpt = {};
	tbGeneralAward.tbRandom = {};
	
	-- 背包空间
	local nNeed = 3;
	if pPlayer.CountFreeBagCell() < nNeed then
		self:SendMessage(pPlayer, self.MSG_MIDDLE, (string.format("Hành trang cần %s ô trống.", nNeed)));
		return 0;
	end
	table.insert(tbGeneralAward.tbFix,
		{
			szType = "exp", 
			varValue = self.AWARD_EXP, 
			nSprIdx = "",
			szDesc = "Kinh nghiệm", 
		}
	);
	table.insert(tbGeneralAward.tbFix,
		{
			szType = "item", 
			varValue = {18, 1, 1800, 1}, 
			nSprIdx = "",
			szDesc = "Thỏi bạc", 
			szAddParam1 = 1,
		}
	);
	table.insert(tbGeneralAward.tbFix,
		{
			szType = "item", 
			varValue = {18, 1, 1801, 1}, 
			nSprIdx = "",
			szDesc = "Long Cẩm Ngọc Hạp", 
			szAddParam1 = 1,
		}
	);
	table.insert(tbGeneralAward.tbFix,
		{
			szType = "item", 
			varValue = {18, 1, 1802, 1}, 
			nSprIdx = "",
			szDesc = "Long Ảnh Ngọc Hạp", 
			szAddParam1 = 1,
		}
	);
	GeneralAward:SendAskAward(szAwardTalk, tbGeneralAward, {"Keyimen:OnFinishTaskAward", me.nId});
end

function Keyimen:OnFinishTaskAward(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	pPlayer.SetTask(self.TASK_GID, self.TASK_STATE, 2);
	Task:CloseTask(self.TASK_MAIN_ID, "finish");
	StatLog:WriteStatLog("stat_info", "keyimen_battle", "task_output", pPlayer.nId, 1);
end
-------------------------------------------------------
-- buffer
-------------------------------------------------------

-- load buffer
function Keyimen:LoadBuffer_GS(nIndex)
	local szBuffer = self.GBLBUFFER_LIST[nIndex];
	if not szBuffer then
		return 0;
	end
	local tbBuffer = GetGblIntBuf(nIndex, 0);
	if tbBuffer and type(tbBuffer) == "table" then
		self[szBuffer] = tbBuffer
	end
end

-- clear buffer
function Keyimen:ClearBuffer_GS(nIndex)
	local szBuffer = self.GBLBUFFER_LIST[nIndex];
	if not szBuffer then
		return 0;
	end
	self[szBuffer] = {};
end

-- 启动事件
function Keyimen:StartEvent()
	for nIndex, _ in pairs(self.GBLBUFFER_LIST) do
		self:LoadBuffer_GS(nIndex);
	end
	self:StartTimer(self.DAEMON_TIME * Env.GAME_FPS, self.TimerDeamon, "TimerDeamon");
end

-- 守护timer
function Keyimen:TimerDeamon()
	for szPlayerName, tbInfo in pairs(self.tbPlayerList) do
		local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
		if pPlayer then
			local nKinId = pPlayer.GetKinMember();
			local pKin = KKin.GetKin(nKinId);
			if not pKin then
				self:SafeLeave(pPlayer);
			end
		else
			self.tbPlayerList[szPlayerName] = nil;
		end
	end
	for nMapId, nCamp in pairs(self.MAP_LIST) do
		if SubWorldID2Idx(nMapId) >= 0 then
			for nTongId, _ in pairs(self.tbTongList) do
				SetMapHighLightPointEx(nMapId, 3, 12, 6000, 0, 1, nTongId);
			end
		end
	end
	return self.DAEMON_TIME * Env.GAME_FPS;
end

-- 取消任务
function Keyimen:TaskFailed()
	local tbTask = {{497, 522}, {60002, 60002}};
	for _, tbTaskMain in pairs(tbTask) do
		for i = tbTaskMain[1], tbTaskMain[2] do
			if Task:GetPlayerTask(me).tbTasks[i] then
				self:SendMessage(me, self.MSG_CHANNEL, "Nhiệm vụ thất bại, lần sau hãy nhanh chóng hoàn thành!");
				Task:CloseTask(i, "giveup");
			end
		end
	end
    tbTask = {{239, 280}};
    for _, tbTaskId in pairs(tbTask) do
    	for i = tbTaskId[1], tbTaskId[2] do
    		me.SetTask(1022, i, 0);
    	end
    end
    for _, nTask in ipairs(self.TASK_FINISH) do
    	me.SetTask(self.TASK_GID, nTask, 0);
    end
    me.SetTask(self.TASK_GID, self.TASK_STATE, 0);
    me.GetTask(self.TASK_GID, self.TASK_CAMP, 0);
end

-- 每日事件
function Keyimen:PlayerDailyEvent()
	me.SetTask(self.TASK_GID, self.TASK_GET_PAD, 0);
	self:TaskFailed();
end

-- 玩家死亡回调
function Keyimen:OnPlayerDeath(pKillerNpc)
	for nMapId, _ in pairs(self.MAP_LIST) do
		if SubWorldID2Idx(nMapId) >= 0 and me.nMapId == nMapId then
			me.ReviveImmediately(1);
			local nCamp = self:GetPlayerTongCamp(me);
			local tbPos = self.REVIVAL_LIST[nCamp];
			if tbPos then
				me.SetFightState(0);
				me.SetTask(self.TASK_GID, self.TASK_REVTIME, GetTime());
				me.NewWorld(unpack(tbPos));
			else
				self:SafeLeave(me);
			end
		end
	end
end

-- 玩家登陆回调
function Keyimen:OnPlayerLogin(bExchangeServerComing)
	if bExchangeServerComing ~= 1 then
		if me.GetSkillState(self.SKLLL_EQUIP_ID) > 0 then
			me.RemoveSkillState(self.SKLLL_EQUIP_ID);
		end
		if me.GetSkillState(self.SKLLL_DAMAGE_ID) > 0 then
			me.RemoveSkillState(self.SKLLL_DAMAGE_ID);
		end
		if me.GetTask(self.TASK_GID, self.TASK_PROTECT) == 1 then
			me.SetLogoutRV(0);
			me.nForbidChangePK = 0;
			me.nPkModel = Player.emKPK_STATE_PRACTISE;
			me.SetTask(self.TASK_GID, self.TASK_PROTECT, 0);
		end
	end
end

function Keyimen:ClearAllDragon()
	if (not self.tbDragonList) then
		return 0;
	end
	for dwId, tbInfo in pairs(self.tbDragonList) do
		local pNpc = KNpc.GetById(dwId);
		if pNpc then
			pNpc.Delete();
		end
	end
	self.tbDragonList = {};
	return 1;
end

-- 注册玩家每日事件
PlayerSchemeEvent:RegisterGlobalDailyEvent({Keyimen.PlayerDailyEvent, Keyimen});

-- 注册启动事件
ServerEvent:RegisterServerStartFunc(Keyimen.StartEvent, Keyimen);

-- 注册死亡事件
if Keyimen.nEventDeathId then
	PlayerEvent:UnRegisterGlobal("OnDeath", Keyimen.nEventDeathId)	
end
Keyimen.nEventDeathId = PlayerEvent:RegisterGlobal("OnDeath", Keyimen.OnPlayerDeath, Keyimen);

-- 注册登陆事件
if Keyimen.nEventLoginId then
	PlayerEvent:UnRegisterGlobal("OnLogin", Keyimen.nEventLoginId)	
end
Keyimen.nEventLoginId = PlayerEvent:RegisterGlobal("OnLogin", Keyimen.OnPlayerLogin, Keyimen);
