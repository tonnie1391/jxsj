-------------------------------------------------------
-- 文件名　：marry_wedding.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-01-05 00:39:01
-- 文件描述：
-------------------------------------------------------


Require("\\script\\marry\\logic\\marry_def.lua");

if (not MODULE_GAMESERVER) then
	return 0;
end

-- tbMissionInfo = {MaleName, FemaleName, MapLevel, ServerIndex, MissionIndex, WeddingLevel, StartDate};

-- 清除全局数据表
function Marry:ClearBuffer_GS()
	self.tbGlobalBuffer = {[1] = {}, [2] = {}, [3] = {}, [4] = {}};
end

-- 同步数据
function Marry:SyncBuffer_GS(tbInfo, nWeddingLevel, nDate, nIndex)

	-- 平民和贵族
	if nWeddingLevel <= 2 then
		if not self.tbGlobalBuffer[nWeddingLevel][nDate] then
			self.tbGlobalBuffer[nWeddingLevel][nDate] = {};
		end
		self.tbGlobalBuffer[nWeddingLevel][nDate][nIndex] = tbInfo;
		
	-- 王侯和皇家
	else
		self.tbGlobalBuffer[nWeddingLevel][nDate] = tbInfo;
	end
end

-- 合服数据
function Marry:ClearCozoneBuffer_GS()
	self.tbCozoneBuffer = {[1] = {}, [2] = {}, [3] = {}, [4] = {}};
end

function Marry:SyncCozoneBuffer_GS(tbInfo, nWeddingLevel, nDate, nIndex)
	if not self.tbCozoneBuffer[nWeddingLevel][nDate] then
		self.tbCozoneBuffer[nWeddingLevel][nDate] = {};
	end
	self.tbCozoneBuffer[nWeddingLevel][nDate][nIndex] = tbInfo;
end

-- 增加婚礼
function Marry:AddWedding_GS(nWeddingLevel, nDate, tbInfo, dwItemId, nTime)
	
	-- 系统开关
	if Marry:CheckState() ~= 1 then
		return 0;
	end
	
	GCExcute({"Marry:AddWedding_GC", nWeddingLevel, nDate, tbInfo, dwItemId, nTime});
end

-- 删除婚礼
function Marry:RemoveWedding_GS(nWeddingLevel, nDate, tbInfo)
	
	-- 系统开关
	if Marry:CheckState() ~= 1 then
		return 0;
	end
	
	GCExcute({"Marry:RemoveWedding_GC", nWeddingLevel, nDate, tbInfo});
end

-- 删除指定角色的婚期
function Marry:RemovePlayerWedding(szPlayerName)
	if self:CheckPreWedding(szPlayerName) == 1 then
		GCExcute({"Marry:RemovePlayerWedding_GC", szPlayerName});
	end
end

-- 删除合服婚礼
function Marry:RemoveCozoneWedding_GS(nWeddingLevel, nDate, tbInfo)
	
	-- 系统开关
	if Marry:CheckState() ~= 1 then
		return 0;
	end
	
	GCExcute({"Marry:RemoveCozoneWedding_GC", nWeddingLevel, nDate, tbInfo});
end

-- 同步 mission info
function Marry:SyncMissionInfo_GS(tbInfo)
	self.tbMissionInfo[tbInfo.MissionIndex] = tbInfo;
end

-- 同步 mission map
function Marry:SyncMissionMap_GS(tbMissionMap)
	self.tbMissionMap = tbMissionMap;
end

-- 补偿的时候计算需要多少背包空间
function Marry:CalcNeedBag_Compensation()
	local nNeedBag = 0;
	local bNeedCompensation, szDstName, nData, nWeddingLevel, nMapLevel = Marry:CheckCompensation(me.szName);
	if (bNeedCompensation == 1) then
		local tbCompensation = Marry.TB_COMPENSATION[nWeddingLevel];
		if (tbCompensation) then
			nNeedBag = tbCompensation.nCount or 0;
		end
	end
	
	return nNeedBag;
end

-- gc增加婚礼回调
function Marry:AddWeddingResult_GS(nRet, tbInfo, dwItemId, nTime, nDate)
	
	if not tbInfo then
		return 0;
	end
	
	local szMaleName = tbInfo[1];
	local szFemaleName = tbInfo[2];
	local nMapLevel = tbInfo[3];
	
	local pMale = KPlayer.GetPlayerByName(szMaleName);
	local pFemale = KPlayer.GetPlayerByName(szFemaleName);
	if not pMale or not pFemale then
		return 0;
	end
	
	if nRet ~= 1 then
		
		Setting:SetGlobalObj(pMale);
		Dialog:Say("Ngày kết hôn đã hết hạn, hãy chọn ngày lại.");
		Setting:RestoreGlobalObj();
		
		Setting:SetGlobalObj(pFemale);
		Dialog:Say("Ngày kết hôn đã hết hạn, hãy chọn ngày lại.");
		Setting:RestoreGlobalObj();
		
	else
		local pItem = KItem.GetObjById(dwItemId);
		if not pItem then
			return 0;
		end
		
		-- me设为男方
		Setting:SetGlobalObj(pMale);
		
		local pFinalItem = me.AddItem(pItem.nGenre, pItem.nDetail, 594, pItem.nLevel);
		if pFinalItem then
			pFinalItem.Bind(1);
			pFinalItem.SetCustom(Item.CUSTOM_TYPE_EVENT, pFemale.szName);
			pItem.Delete(me);
		end
		
		-- 如果是补偿婚期，也需要把原来的婚期删除
		local bNeedCompensation = Marry:CheckCompensation(szMaleName);
		if (bNeedCompensation == 1) then
			local nPreWeddingLevel = me.GetTask(Marry.TASK_GROUP_ID, Marry.TASK_WEDDING_LEVEL);
			local nPreWeddingDate = me.GetTask(Marry.TASK_GROUP_ID, Marry.TASK_RESERVE_DATE);
			local nPreWeddingMapLevel = me.GetTask(Marry.TASK_GROUP_ID, Marry.TASK_RESERVE_MAPLEVEL);
			
			local bOk, szMateName, nDate, nWeddingLevel, nMapLevel = Marry:CheckPreWedding(me.szName);
			if bOk == 1 and szMateName == pFemale.szName and nDate == nPreWeddingDate and nWeddingLevel == nPreWeddingLevel and nMapLevel == nPreWeddingMapLevel then
				Marry:RemoveWedding_GS(nPreWeddingLevel, nPreWeddingDate, {me.szName, pFemale.szName, nPreWeddingMapLevel});
			else
				Dbg:WriteLog("Marry", "结婚系统", me.szAccount, me.szName, "补偿婚礼，修改婚期数据有问题。");
			end
			
			-- 补偿婚礼，给予玩家道具
			self:GetCompensation(nWeddingLevel);
			
			local szLog = "补偿婚期，免费重新选择婚期。";
			Dbg:WriteLog("Marry", "结婚系统", "重新设置典礼日期", me.szAccount, me.szName, szLog);
		end
		
		-- 如果是重新设置婚期，把原来的婚期删除
		local nReSelectTime = me.GetTask(Marry.TASK_GROUP_ID, Marry.TASK_TIME_RESELECTDATE);
		if nReSelectTime > 0 then
			local nPreWeddingLevel = me.GetTask(Marry.TASK_GROUP_ID, Marry.TASK_WEDDING_LEVEL);
			local nPreWeddingDate = me.GetTask(Marry.TASK_GROUP_ID, Marry.TASK_RESERVE_DATE);
			local nPreWeddingMapLevel = me.GetTask(Marry.TASK_GROUP_ID, Marry.TASK_RESERVE_MAPLEVEL);
			
			local bOk, szMateName, nDate, nWeddingLevel, nMapLevel = Marry:CheckPreWedding(me.szName);
			if bOk == 1 and szMateName == pFemale.szName and nDate == nPreWeddingDate and nWeddingLevel == nPreWeddingLevel and nMapLevel == nPreWeddingMapLevel then
				Marry:RemoveWedding_GS(nPreWeddingLevel, nPreWeddingDate, {me.szName, pFemale.szName, nPreWeddingMapLevel});
			else
				Dbg:WriteLog("Marry", "结婚系统", me.szAccount, me.szName, "修改婚期数据有问题。");
			end
			
			local nNeedMoney = 200000 * nReSelectTime;
			me.CostMoney(nNeedMoney, Player.emKPAY_EVENT);
			
			local szLog = string.format("第%s次修改典礼日期，扣除费用%s两。", nReSelectTime, nNeedMoney);
			Dbg:WriteLog("Marry", "结婚系统", "重新设置典礼日期", me.szAccount, me.szName, szLog);
		end
		
		me.SetTask(Marry.TASK_GROUP_ID, Marry.TASK_TIME_RESELECTDATE, nReSelectTime + 1);
		
		-- 分别为双方记录下预订婚礼的场地等级，婚礼等级，以及预订婚礼的日期
		local szDate = tostring(os.date("%Y-%m-%d", nTime));
		Dialog:Say(string.format("Đặt lễ thành công vào: <color=yellow>%s<color>", szDate));
		me.SetTask(Marry.TASK_GROUP_ID , Marry.TASK_WEDDING_LEVEL, pFinalItem.nLevel);
		me.SetTask(Marry.TASK_GROUP_ID , Marry.TASK_RESERVE_DATE, nDate);
		me.SetTask(Marry.TASK_GROUP_ID , Marry.TASK_RESERVE_MAPLEVEL, nMapLevel);
		
		local szBroadcastMsg = string.format("[<color=yellow>%s<color>] và [<color=yellow>%s<color>] đặt %s <color=yellow>%s<color> tại %s.",
			me.szName, pFemale.szName, Marry.WEDDING_LEVEL_NAME[pFinalItem.nLevel], szDate, Marry.MAP_LEVEL_NAME[nMapLevel]);
			
		me.SendMsgToFriend(szBroadcastMsg);
		me.SendMsgToKinOrTong(0, szBroadcastMsg);
		me.Msg(string.format("Đặt lễ thành công vào: <color=yellow>%s<color>", szDate));
		
		local tbFriendList = me.GetRelationList(Player.emKPLAYERRELATION_TYPE_BIDFRIEND);
		for _, szName in pairs(tbFriendList or {}) do
			KPlayer.SendMail(szName, "Thiệp hồng", szBroadcastMsg);
		end
		
		Dbg:WriteLog("Marry", "结婚系统", me.szName, me.szAccount, pFemale.szName, pFemale.szAccount,
			string.format("申请日期：%s", os.date("%Y-%m-%d", GetTime())),
			string.format("预定日期：%s", szDate),
			string.format("婚礼档次：%s", pFinalItem.nLevel),
			string.format("地图类型：%s", Marry.MAP_LEVEL_NAME[nMapLevel])
		);
		-- 恢复本来me
		Setting:RestoreGlobalObj();
		
		-- me设为女方
		Setting:SetGlobalObj(pFemale);
		Dialog:Say(string.format("Đặt lễ thành công vào: <color=yellow>%s<color>", szDate));
		me.SetTask(Marry.TASK_GROUP_ID , Marry.TASK_WEDDING_LEVEL, pFinalItem.nLevel);
		me.SetTask(Marry.TASK_GROUP_ID , Marry.TASK_RESERVE_DATE, nDate);
		me.SetTask(Marry.TASK_GROUP_ID , Marry.TASK_RESERVE_MAPLEVEL, nMapLevel);
		
		me.SendMsgToFriend(szBroadcastMsg);
		me.SendMsgToKinOrTong(0, szBroadcastMsg);
		me.Msg(string.format("Đặt lễ thành công vào: <color=yellow>%s<color>", szDate));
		
		local tbFriendList = me.GetRelationList(Player.emKPLAYERRELATION_TYPE_BIDFRIEND);
		for _, szName in pairs(tbFriendList) do
			KPlayer.SendMail(szName, "Thiệp hồng", szBroadcastMsg);
		end
		
		-- 恢复本来me
		Setting:RestoreGlobalObj();
	end
end

-- 补偿婚礼，获取道具
function Marry:GetCompensation(nWeddingLevel)
	local tbCompensation = Marry.TB_COMPENSATION[nWeddingLevel];
	if (not tbCompensation) then
		return;
	end
	local nCount = tbCompensation.nCount;
	local tbGDPL = tbCompensation.tbGDPL;
	local szItemName = KItem.GetNameById(unpack(tbGDPL));
	me.AddStackItem(tbGDPL[1], tbGDPL[2], tbGDPL[3], tbGDPL[4],	nil, nCount);
	
	local szLog = string.format("补偿婚礼，给予道具%s个%s", nCount, szItemName);
	Dbg:WriteLog("Marry", "结婚系统", "补偿婚礼给予道具", me.szAccount, me.szName, szLog);
end

-- 每天中午12点开启所有婚礼
function Marry:StartWedding_GS()
	
	-- 系统开关
	if Marry:CheckState() ~= 1 then
		return 0;
	end
	
	for _, tbInfo in pairs(self.tbMissionInfo) do
		if tbInfo.ServerIndex == GetServerId() then
			self:ApplyDynMap(tbInfo);
		end
	end
end

-- 每天早上8点关闭副本
function Marry:CloseWedding_GS()
	
	-- 系统开关
	if Marry:CheckState() ~= 1 then
		return 0;
	end
	
	-- 遍历mission列表
	for nDynMapId, tbMission in pairs(self.tbMissionList) do
		
		-- 得到全局mission表的索引
		local nIndex = self.tbMapTempList.tbMapInfo[nDynMapId].MissionIndex;
			
		-- 释放gs maptemp表
		self.tbMapTempList.nCount = self.tbMapTempList.nCount - 1;
		self.tbMapTempList.tbMapList[nDynMapId].nFlag = 0;
		self.tbMapTempList.tbMapInfo[nDynMapId] = nil;
		
		-- 关闭mission
		self.tbMissionList[nDynMapId]:Close();
		self.tbMissionList[nDynMapId] = nil;
		
		-- 清除该地图npc
		ClearMapNpc(nDynMapId, 0);
		
		-- 通知gc该地图被释放
		GCExcute({"Marry:FreeDynMap_GC", nDynMapId, nIndex});
	end
	
	-- 置空gs mission信息
	self.tbMissionInfo = {};
end

-- 申请动态地图
function Marry:ApplyDynMap(tbInfo)
	
	-- 地图信息列表，记录每个服务器动态地图加载信息，以及地图的归属
	if not self.tbMapTempList then
		self.tbMapTempList = {};
		self.tbMapTempList.tbMapList = {};	-- 标记地图是否被占用
		self.tbMapTempList.tbMapInfo = {};	-- 记录地图信息
		self.tbMapTempList.nCount = 0;		-- 动态地图数量
	end
	
	for nDynMapId, tbRow in pairs(self.tbMapTempList.tbMapList) do

		-- 找到空闲的动态地图
		if tbRow.nFlag == 0 and tbRow.nMapLevel == tbInfo.MapLevel then
			
			-- gs完成回调
			self.tbMapTempList.nCount = self.tbMapTempList.nCount + 1;
			self:OnLoadMapFinish(tbInfo, nDynMapId);
			
			-- 通知gc
--			GCExcute({"Marry:ApplyDynMap_GC", nDynMapId, tbInfo.MissionIndex});
			return 1;
		end
	end
	
	-- 判断地图上限
	if self.tbMapTempList.nCount >= self.MAX_MAP_APPLY + 2 then
		return 0;
	end
	
	-- 找不到则申请新的动态地图
	if Map:LoadDynMap(Map.DYNMAP_TREASUREMAP, self.MAP_TEMPLATE_INFO[tbInfo.MapLevel][1], {self.OnLoadMapFinish, self, tbInfo}) == 1 then
		self.tbMapTempList.nCount = self.tbMapTempList.nCount + 1;
		return 1;
	end
	
	return 0;
end

-- 动态地图回调
function Marry:OnLoadMapFinish(tbInfo, nDynMapId)
	
	-- 生成的新地图
	if not self.tbMapTempList.tbMapList[nDynMapId] then
		self.tbMapTempList.tbMapList[nDynMapId] = {};
		self.tbMapTempList.tbMapList[nDynMapId].nMapLevel = tbInfo.MapLevel;
	end
	
	-- 标记占用
	self.tbMapTempList.tbMapList[nDynMapId].nFlag = 1;
	
	-- 保存地图信息
	self.tbMapTempList.tbMapInfo[nDynMapId] = tbInfo;
	
	-- 计算结束时间
	local nStartTime = GetTime();
	local nEndTime = nStartTime + 60 * 60 * 19;
	
	-- 地图事件
	self:LinkMapTrap(tbInfo.MapLevel, self.MAP_TEMPLATE_INFO[tbInfo.MapLevel][1]);
	
	-- 申请mission
	self.tbMissionList[nDynMapId] = Lib:NewClass(self.Mission);
	self.tbMissionList[nDynMapId]:StartGame(tbInfo.MaleName, tbInfo.FemaleName, nDynMapId, tbInfo.MapLevel, tbInfo.WeddingLevel, nStartTime, nEndTime);
	ResetMapNpc(nDynMapId);
	GCExcute({"Marry:ApplyDynMap_GC", nDynMapId, tbInfo.MissionIndex});
end

-- 从月老处选择婚礼准备场
function Marry:SelectServer(nFrom)
	
	-- 系统开关
	if Marry:CheckState() ~= 1 then
		return 0;
	end
	
	local tbOpt = {};
	local nCount = 10;
	local nLast = nFrom or 0;
	
	for nIndex, nDynMapId in next, self.tbMissionMap, nFrom do
		
		if nCount <= 0 then
			tbOpt[#tbOpt + 1] = {"Tiếp theo", self.SelectServer, self, nLast};
			break;
		end
		
		local nServerIndex = self.tbMissionInfo[nIndex].ServerIndex;
		local szMaleName = self.tbMissionInfo[nIndex].MaleName;
		local szFemaleName = self.tbMissionInfo[nIndex].FemaleName;
		local szMsg = string.format("<color=yellow>%s - %s<color>", szMaleName, szFemaleName);
		
		tbOpt[#tbOpt + 1] = {szMsg, self.DoSelectServer, self, nServerIndex};
		nCount = nCount - 1;
		nLast = nLast + 1;
	end
	
	tbOpt[#tbOpt + 1] = {"Kết thúc đối thoại"};	
	Dialog:Say("Ngươi định tham dự lễ cưới của ai?", tbOpt);	
end

-- 进入准备场
function Marry:DoSelectServer(nServerIndex)
	if self.MAP_SIGNUP_POS[nServerIndex] then
		me.NewWorld(unpack(self.MAP_SIGNUP_POS[nServerIndex]));
	end
end

-- 参加婚礼
function Marry:AttendWedding(nFrom)
	
	-- 系统开关
	if Marry:CheckState() ~= 1 then
		return 0;
	end
	
	local tbOpt = {};
	local nCount = 10;
	local nLast = nFrom or 0;
	
	for nIndex, nDynMapId in next, self.tbMissionMap, nFrom do
		
		if nCount <= 0 then
			tbOpt[#tbOpt + 1] = {"Tiếp theo", self.AttendWedding, self, nLast};
			break;
		end
		
		if self.tbMissionList[nDynMapId] and SubWorldID2Idx(nDynMapId) >= 0 then
			local nMapLevel = self.tbMissionInfo[nIndex].MapLevel;
			local szMaleName = self.tbMissionInfo[nIndex].MaleName;
			local szFemaleName = self.tbMissionInfo[nIndex].FemaleName;
			local szMsg = string.format("<color=yellow>%s - %s<color>", szMaleName, szFemaleName);
			tbOpt[#tbOpt + 1] = {szMsg, self.DoAttendWedding, self, nDynMapId, szMaleName, szFemaleName, nMapLevel};
			nCount = nCount - 1;
			nLast = nLast + 1;
		end
	end
	
	tbOpt[#tbOpt + 1] = {"Kết thúc đối thoại"};	
	Dialog:Say("Ngươi định tham dự tiệc cưới của ai?", tbOpt);
end

-- 确认对话
function Marry:DoAttendWedding(nDynMapId, szMaleName, szFemaleName, nMapLevel, nSure)
	
	-- 不在这台服务器或者副本加载失败
	if SubWorldID2Idx(nDynMapId) < 0 or not self.tbMissionList[nDynMapId] then
		return 0;
	end
	
	-- 人数超过上限
	if self:GetCurPlayerCount(nDynMapId) >= self:GetMaxPlayerCount(nDynMapId) then
		Dialog:Say("Xin lỗi, đã quá đông người tham gia, không thể vào thêm.")
		return 0;
	end
	
--	if not nSure then
--		local szMsg = string.format("你确定要参加<color=yellow>[%s]<color>和<color=yellow>[%s]<color>的典礼么？", szMaleName, szFemaleName);
--		local tbOpt = 
--		{
--			{"Xác nhận", self.DoAttendWedding, self, nDynMapId, szMaleName, szFemaleName, nMapLevel, 1},
--			{"Để ta suy nghĩ thêm"},
--		}
--		Dialog:Say(szMsg, tbOpt);
--		return 0;
--	end
	
	-- 判断权限
	if Marry:GetWeddingPlayerLevel(nDynMapId, me.szName) <= 0 then
		
		-- 家族或者好友
		if self:CheckFriendOrKin(me, szMaleName, szFemaleName) == 1 then
			Marry:SetWeddingPlayerLevel(nDynMapId, me.szName, 1);
			
		-- 邀请函
		else
			local nFindItem = 0;
			local tbFind = me.FindItemInBags(unpack(self.ITEM_YAOQINGHAN_ID));
			for _, tbItem in pairs(tbFind or {}) do
				if tbItem.pItem and tbItem.pItem.szCustomString == szMaleName then
					me.DelItem(tbItem.pItem);
					nFindItem = 1;
					break;
				end
			end
			
			local tbFindGM = me.FindItemInBags(unpack(self.ITEM_GM_ID));
			if tbFindGM and #tbFindGM >= 1 then
				nFindItem = 1;
			end
				
			if nFindItem ~= 1 then
				Dialog:Say("Xin lỗi, ngươi không nhận được lời mời từ chủ hôn.\nNgươi có thể yêu cầu chủ hôn hoặc mật hữu của họ <color=yellow>mời ngươi tham gia<color>. Tất nhiên, <color=yellow>hảo hữu<color> hoặc <color=yellow>thành viên cùng Bang hội<color> sẽ được trực tiếp tham dự.");
				return 0;
			end
			Marry:SetWeddingPlayerLevel(nDynMapId, me.szName, 1);
		end
	end

	-- 动态地图只能从本服进入
	me.NewWorld(nDynMapId, self.MAP_TEMPLATE_INFO[nMapLevel][2], self.MAP_TEMPLATE_INFO[nMapLevel][3]);
	self.tbMissionList[nDynMapId]:JoinPlayer(me, 1);
end

function Marry:ApplyJoinMission_GS(nPlayerId, nDynMapId)
	if SubWorldID2Idx(nDynMapId) < 0 then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	self.tbMissionList[nDynMapId]:JoinPlayer(pPlayer, 1);
end

-- 判断家族好友
function Marry:CheckFriendOrKin(pPlayer, szMaleName, szFemaleName)
	
	-- 家族
	local nKinId = pPlayer.GetKinMember();	
	local nKinIdMale = KKin.GetPlayerKinMember(KGCPlayer.GetPlayerIdByName(szMaleName));
	local nKinIdFemale = KKin.GetPlayerKinMember(KGCPlayer.GetPlayerIdByName(szFemaleName));
	
	local pKin = KKin.GetKin(nKinId);
	local pKinMale = KKin.GetKin(nKinIdMale);
	local pKinFemale = KKin.GetKin(nKinIdFemale);
	
	-- 家族自动加入
	if pKin then
		if pKinMale and nKinId == nKinIdMale then
			return 1;
		end
		if pKinFemale and nKinId == nKinIdFemale then
			return 1;
		end
	end
	
	-- 好友自动加入
	if pPlayer.IsFriendRelation(szMaleName) == 1 or pPlayer.IsFriendRelation(szFemaleName) == 1 then
		return 1;
	end
	
	return 0;	
end

-- 检查是否是需要补偿的玩家（也就是延迟发布，但是玩家并没有退订婚礼的玩家）
function Marry:CheckCompensation(szName)
	for nWeddingLevel, tbMap in pairs(self.tbGlobalBuffer) do
		for nDate, tbRow in pairs(tbMap) do
			if (nDate <= 20100601) then
				if nWeddingLevel <= 2 then
					for nIndex, tbInfo in pairs(tbRow) do
						if szName == tbInfo[1] then
							return 1, tbInfo[2], nDate, nWeddingLevel, tbInfo[3];
						elseif szName == tbInfo[2] then
							return 1, tbInfo[1], nDate, nWeddingLevel, tbInfo[3];
						end
					end
				else
					if szName == tbRow[1] then
						return 1, tbRow[2], nDate, nWeddingLevel, tbRow[3];
					elseif szName == tbRow[2] then
						return 1, tbRow[1], nDate, nWeddingLevel, tbRow[3];
					end
				end
			end
		end
	end
	return 0;
end

-- 判断合服婚期
function Marry:CheckCozoneWedding(szName)
	for nWeddingLevel, tbMap in pairs(self.tbCozoneBuffer) do
		for nDate, tbRow in pairs(tbMap) do
			for nIndex, tbInfo in pairs(tbRow) do
				if szName == tbInfo[1] then
					return 1, tbInfo[2], nDate, nWeddingLevel, tbInfo[3];
				elseif szName == tbInfo[2] then
					return 1, tbInfo[1], nDate, nWeddingLevel, tbInfo[3];
				end
			end
		end
	end
	return 0;
end

-- 婚礼查询功能
function Marry:QueryWedding(nType, varQuery, nFrom)
	
	-- 系统开关
	if Marry:CheckState() ~= 1 then
		return 0;
	end
	
	-- 按名字查询
	if nType == 1 then
		for nWeddingLevel, tbMap in pairs(self.tbGlobalBuffer) do
			for nDate, tbRow in pairs(tbMap) do
				
				local nYear = math.floor(nDate / 10000);
				local nMonth = math.mod(math.floor(nDate / 100), 100);
				local nDay = math.mod(nDate, 100);
				
				local szMsg = string.format("<color=yellow>%s<color> Thông tin buổi lễ\n\n", varQuery);
				szMsg = szMsg .. string.format("Ngày diễn ra: <color=green>%s-%s-%s<color>\n", nYear, nMonth, nDay);
				szMsg = szMsg .. string.format("Cấp độ: <color=green>%s<color>\n", self.WEDDING_LEVEL_NAME[nWeddingLevel]);
				
				if nWeddingLevel <= 2 then
					for nIndex, tbInfo in pairs(tbRow) do
						if varQuery == tbInfo[1] or varQuery == tbInfo[2] then
							szMsg = szMsg .. string.format("Địa điểm: <color=green>%s<color>\n", self.MAP_LEVEL_NAME[tbInfo[3]]);
							Dialog:Say(szMsg);
							return 0;
						end
					end
				elseif varQuery == tbRow[1] or varQuery == tbRow[2] then
					szMsg = szMsg .. string.format("Địa điểm: <color=green>%s<color>\n", self.MAP_LEVEL_NAME[tbRow[3]]);
					Dialog:Say(szMsg);
					return 0;
				end
			end
		end
		Dialog:Say("Không thể kiểm tra.")
		
	-- 按日期查询
	elseif nType == 2 then
		
		local nYear = math.floor(varQuery / 10000);
		local nMonth = math.mod(math.floor(varQuery / 100), 100);
		local nDay = math.mod(varQuery, 100);
		
		local szMsg = "";
		local tbNpc = Npc:GetClass("marry_yuelao");
		local tbOpt = {{"<color=green>Quay lại<color>", tbNpc.QuerySpedayWedingInfo, tbNpc}, {"Ta hiểu rồi"}};
		local szTitle = string.format("<color=yellow>%s-%s-%s<color> gồm có:\n\n", nYear, nMonth, nDay);
		
		for nWeddingLevel, tbMap in pairs(self.tbGlobalBuffer) do
			
			local tbDate = tbMap[varQuery];
			if tbDate then
				local tbColor = 
				{
					[1] = "<color=green>",
					[2] = "<color=blue>",
					[3] = "<color=purple>",
					[4] = "<color=gold>",
				};
				local szColor = tbColor[nWeddingLevel] or "<color=orange>";
				if nWeddingLevel <= 2 then
					local nCount = 8;
					local nLast = nFrom or 1;
					for i = nLast, #tbDate do
						szMsg = szMsg .. string.format("%s%s<color>", szColor, Lib:StrFillR(tbDate[i][1], 16))
							.. " - " .. string.format("%s%s<color>\n", szColor, Lib:StrFillL(tbDate[i][2], 16));
						nCount = nCount - 1;
						nLast = nLast + 1;
						if nCount <= 0 then
							table.insert(tbOpt, 1, {"<color=green>Tiếp theo<color>", self.QueryWedding, self, nType, varQuery, nLast});
							break;
						end
					end
				elseif not nFrom then
					szMsg = string.format("%s%s<color>", szColor, Lib:StrFillR(tbDate[1], 16))
						.. " - " .. string.format("%s%s<color>\n", szColor, Lib:StrFillL(tbDate[2], 16)) .. szMsg;
				end
			end
		end
	
		Dialog:Say(szTitle .. szMsg, tbOpt);
	end
end

-- 判断是否是婚礼地图
function Marry:CheckWeddingMap(nMapId)
	if not self.tbMapTempList then
		return 0;
	end
	if self.tbMapTempList.tbMapList[nMapId] then
		return 1;
	end
	return 0;
end

-- 得到婚礼地图等级
function Marry:GetWeddingMapLevel(nMapId)
	if not self.tbMapTempList then
		return 0;
	end
	if self.tbMapTempList.tbMapInfo[nMapId] then
		return self.tbMapTempList.tbMapInfo[nMapId].MapLevel;
	end
	return 0;
end

-- 得到地图婚礼步骤
function Marry:GetWeddingStep(nMapId)
	if self.tbMissionList[nMapId] then
		return self.tbMissionList[nMapId]:GetCurStep();
	end
	return 0;
end

-- 设置地图婚礼步骤
function Marry:SetWeddingStep(nMapId, nStep)
	if self.tbMissionList[nMapId] then
		self.tbMissionList[nMapId]:SetCurStep(nStep);
	end
end

-- 得到实际婚礼的等级(可能不同于地图)
function Marry:GetWeddingLevel(nMapId)
	if self.tbMissionList[nMapId] then
		return self.tbMissionList[nMapId]:GetWeddingLevel();
	end
	return 0;
end

-- 设置婚礼等级
function Marry:SetWeddingLevel(nMapId, nLevel)
	if self.tbMissionList[nMapId] then
		self.tbMissionList[nMapId]:SetWeddingLevel(nLevel);
	end
end

-- 得到地图婚礼主人的名字
function Marry:GetWeddingOwnerName(nMapId)
	if self.tbMissionList[nMapId] then
		return self.tbMissionList[nMapId]:GetWeddingOwnerName();
	end
	return nil;
end

-- 得到玩家权限等级
function Marry:GetWeddingPlayerLevel(nMapId, szPlayerName)
	if self.tbMissionList[nMapId] then
		return self.tbMissionList[nMapId]:GetPlayerLevel(szPlayerName);
	end
	return 0;
end

-- 设置玩家权限等级
function Marry:SetWeddingPlayerLevel(nMapId, szPlayerName, nLevel)
	if self.tbMissionList[nMapId] then
		self.tbMissionList[nMapId]:SetPlayerLevel(szPlayerName, nLevel);
	end
end

-- 判断某玩家是否在台上
function Marry:CheckPlayerOnStage(nMapId, szPlayerName)
	if self.tbMissionList[nMapId] then
		return self.tbMissionList[nMapId]:CheckPlayerOnStage(szPlayerName);
	end
	return 0;
end

-- 增加台上玩家
function Marry:AddPlayerOnStage(nMapId, szPlayerName)
	if self.tbMissionList[nMapId] then
		self.tbMissionList[nMapId]:AddPlayerOnStage(szPlayerName);
	end
end

-- 删除台上玩家
function Marry:RemovePlayerOnStage(nMapId, szPlayerName)
	if self.tbMissionList[nMapId] then
		self.tbMissionList[nMapId]:RemovePlayerOnStage(szPlayerName);
	end
end

-- 当前地图权限列表
function Marry:GetAllPermission(nMapId)
	if self.tbMissionList[nMapId] then
		return self.tbMissionList[nMapId]:GetAllPermission();
	end
	return nil;
end

-- 得到地图人数上限
function Marry:GetMaxPlayerCount(nMapId)
	if self.tbMissionList[nMapId] then
		return self.tbMissionList[nMapId]:GetMaxPlayerCount();
	end
	return 0;
end

-- 增加地图人数上限
function Marry:AddMaxPlayerCount(nMapId, nCount)
	if self.tbMissionList[nMapId] then
		self.tbMissionList[nMapId]:AddMaxPlayerCount(nCount);
	end
end

-- 增加花童
function Marry:AddHuaTong(nMapId, nNpcId)
	if self.tbMissionList[nMapId] then
		self.tbMissionList[nMapId]:AddHuaTong(nNpcId);
	end
end

-- 返回花童列表
function Marry:GetHuaTongList(nMapId)
	if self.tbMissionList[nMapId] then
		return self.tbMissionList[nMapId]:GetHuaTongList();
	end
	return nil;
end

-- 对话文字
function Marry:GetNpcTalk(nMapId, nLevel, nNpcId)
	if self.tbMissionList[nMapId] then
		return self.tbMissionList[nMapId]:GetNpcTalk(nLevel, nNpcId);
	end
	return nil;
end

-- 得到表演状态
function Marry:GetPerformState(nMapId)
	if self.tbMissionList[nMapId] then
		return self.tbMissionList[nMapId]:GetPerformState();
	end
	return 0;
end

-- 设置表演状态
function Marry:SetPerformState(nMapId, nState)
	if self.tbMissionList[nMapId] then
		self.tbMissionList[nMapId]:SetPerformState(nState);
	end
end

-- 得到礼包信息
function Marry:GetLibaoInfo(nMapId)
	if self.tbMissionList[nMapId] then
		return self.tbMissionList[nMapId]:GetLibaoInfo();
	end
	return nil;
end


-- 设置礼包信息
function Marry:SetLibaoInfo(nMapId, tbInfo)
	if self.tbMissionList[nMapId] then
		self.tbMissionList[nMapId]:SetLibaoInfo(tbInfo);
	end	
end

-- 获得第几道菜
function Marry:GetFoodStep(nMapId)
	if self.tbMissionList[nMapId] then
		return self.tbMissionList[nMapId]:GetFoodStep();
	end
	return 0;
end

-- 设置第几道菜
function Marry:SetFoodStep(nMapId, nStep)
	if self.tbMissionList[nMapId] then
		self.tbMissionList[nMapId]:SetFoodStep(nStep);
	end	
end

-- 获取当前第几个小游戏
function Marry:GetMiniGameStep(nMapId)
	if self.tbMissionList[nMapId] then
		return self.tbMissionList[nMapId]:GetMiniGameStep();
	end
	return 0;
end

-- 设置当前第几个小游戏
function Marry:SetMiniGameStep(nMapId, nStep)
	if self.tbMissionList[nMapId] then
		self.tbMissionList[nMapId]:SetMiniGameStep(nStep);
	end	
end

-- 获取主持人id
function Marry:GetWithnessesId(nMapId)
	if self.tbMissionList[nMapId] then
		return self.tbMissionList[nMapId]:GetWithnessesId();
	end
	return 0;
end

-- 保存主持人id
function Marry:SetWitnessesId(nMapId, nWitnessesId)
	if self.tbMissionList[nMapId] then
		self.tbMissionList[nMapId]:SetWitnessesId(nWitnessesId);
	end		
end

-- 踢出副本
function Marry:KickPlayer(nMapId, pPlayer)
	if self.tbMissionList[nMapId] then
		self.tbMissionList[nMapId]:SetPlayerLevel(pPlayer.szName, 0);
		self.tbMissionList[nMapId]:KickPlayer(pPlayer);
	end		
end

-- 烟火状态
function Marry:GetFireState(nMapId)
	if self.tbMissionList[nMapId] then
		return self.tbMissionList[nMapId]:GetFireState();
	end
	return 0;
end

-- 设置烟火
function Marry:SetFireState(nMapId, nFireWork)
	if self.tbMissionList[nMapId] then
		self.tbMissionList[nMapId]:SetFireState(nFireWork);
	end	
end

-- 使用一道菜
function Marry:SetDinner(nMapId, szPlayerName, nDinner)
	if self.tbMissionList[nMapId] then
		self.tbMissionList[nMapId]:SetDinner(szPlayerName, nDinner);
	end
end

-- 获取使用菜数
function Marry:GetDinner(nMapId, szPlayerName)
	if self.tbMissionList[nMapId] then
		return self.tbMissionList[nMapId]:GetDinner(szPlayerName);
	end
	return 0;
end

-- 获得副本地图人数
function Marry:GetCurPlayerCount(nMapId)
	if self.tbMissionList[nMapId] then
		return self.tbMissionList[nMapId]:GetCurPlayerCount();
	end
	return 0;
end

-- 增加副本地图人数
function Marry:AddCurPlayerCount(nMapId, nCount)
	if self.tbMissionList[nMapId] then
		self.tbMissionList[nMapId]:AddCurPlayerCount(nCount);
		self.tbMissionList[nMapId]:UpdateAllRightUI();
	end	
end

-- 获取抽奖次数
function Marry:GetTicket(nMapId)
	if self.tbMissionList[nMapId] then
		return self.tbMissionList[nMapId]:GetTicket();
	end
	return 0;
end

-- 抽奖一次
function Marry:AddTicket(nMapId)
	if self.tbMissionList[nMapId] then
		self.tbMissionList[nMapId]:AddTicket();
	end
end

-- 更新右侧信息
function Marry:UpdateRightUI(nMapId, szMsg)
	if self.tbMissionList[nMapId] then
		self.tbMissionList[nMapId]:UpdateRightUI(szMsg);
	end
end

-- 返回所有玩家列表
function Marry:GetAllPlayers(nMapId)
	if self.tbMissionList[nMapId] then
		return self.tbMissionList[nMapId]:GetPlayerList();
	end
	return nil;
end

-- 获取外部timer
function Marry:GetSpecTimer(nMapId, szKey)
	if self.tbMissionList[nMapId] then
		return self.tbMissionList[nMapId]:GetSpecTimer(szKey);
	end
	return nil;
end

-- 增加外部timer
function Marry:AddSpecTimer(nMapId, szKey, nTimerId)
	if self.tbMissionList[nMapId] then
		self.tbMissionList[nMapId]:AddSpecTimer(szKey, nTimerId);
	end
end

-- 清除外部timer
function Marry:ClearSpecTimer(nMapId, szKey)
	if self.tbMissionList[nMapId] then
		self.tbMissionList[nMapId]:ClearSpecTimer(szKey);
	end
end

-- 获取来访npc
function Marry:GetVisitorNpc(nMapId)
	if self.tbMissionList[nMapId] then
		return self.tbMissionList[nMapId]:GetVisitorNpc();
	end
	return nil;
end

-- 设置来访npc
function Marry:SetVisitorNpc(nMapId, tbInfo)
	if self.tbMissionList[nMapId] then
		self.tbMissionList[nMapId]:SetVisitorNpc(tbInfo);
	end
end

-- 光环称号
function Marry:SetTitle(pMan, pWoman)

	if not pMan or not pWoman then
		return 0;
	end
	
	-- 娘子相公称号
	pMan.AddSpeTitle(string.format("Hiệp lữ của %s", pWoman.szName), GetTime() + 5000 * 60 * 60 * 24, "gold");
	pWoman.AddSpeTitle(string.format("Hiệp lữ của %s", pMan.szName), GetTime() + 5000 * 60 * 60 * 24, "gold");
end

-- 高级称号
function Marry:SetAdvTitle(pPlayer, nSex)

	if not pPlayer then
		return 0;
	end
	
	-- 男性称号
	if nSex == 0 then
		pPlayer.AddTitle(unpack(self.TITLE_ID[1]));
		pPlayer.SetCurTitle(unpack(self.TITLE_ID[1]));
		
	-- 女性称号
	elseif nSex == 1 then
		pPlayer.AddTitle(unpack(self.TITLE_ID[2]));
		pPlayer.SetCurTitle(unpack(self.TITLE_ID[2]));
	end
end

-- 为当前地图所有玩家发送信息（屏幕中央的文字）
function Marry:SendMapMsg(nMapId, szMsg)
	if self:CheckWeddingMap(nMapId) ~= 1 then
		return 0;
	end
	local tbPlayerList = self:GetAllPlayers(nMapId);
	for _, pPlayer in pairs(tbPlayerList or {}) do
		Dialog:SendInfoBoardMsg(pPlayer, szMsg);
	end
end

-- 读取npc坐标
function Marry:LoadNpcPos()
	local tbMap = {};
	local tbFile = Lib:LoadTabFile(self.MARRY_NPC_POS_PATH);
	
	if not tbFile then
		return;
	end

	for _, tbRow in pairs(tbFile) do
		local nMapId = tonumber(tbRow.MapId);
		if SubWorldID2Idx(nMapId) >= 0 then		
			if not tbMap[nMapId] then
				tbMap[nMapId] = {};
			end		
			table.insert(tbMap[nMapId], 
				{
					nNpcId = tonumber(tbRow.NpcId),
					nMapX = tonumber(tbRow.MapX),
					nMapY = tonumber(tbRow.MapY),
					nType = tonumber(tbRow.Type),
				}
			);
		end
	end
	
	self.tbSpecNpcPos = tbMap;
end

-- 刷出npc
function Marry:AddSpecNpc_GS(tbName)
	if not self.tbSpecNpcPos then
		self:LoadNpcPos();
	end
	for nMapId, tbInfo in pairs(self.tbSpecNpcPos or {}) do
		for _, tbMap in pairs(tbInfo) do
			local tbLvlName = tbName[tbMap.nType];
			if tbLvlName then
				local pNpc = KNpc.Add2(tbMap.nNpcId, 100, -1, nMapId, tbMap.nMapX, tbMap.nMapY);
				if pNpc then
					--pNpc.SetTitle(string.format("<color=orange>%s的%s<color>", tbLvlName[1] or "系统", pNpc.szName));
					pNpc.GetTempTable("Marry").szMaleName = tbLvlName[1];
					pNpc.GetTempTable("Marry").szFemaleName = tbLvlName[2];
				end
			end
		end
	end
end

-- 清除npc
function Marry:ClearSpecNpc_GS()
	local tbNpcName = {"Hoàng Gia Quản Gia", "Hoàng Gia Khánh Điển", "Hoàng Gia Tân Hỷ", "Vương Hầu Quản Gia", "Vương Hầu Khánh Điển", "Vương Hầu Tân Hỷ"};
	for nMapId, _ in pairs(self.tbSpecNpcPos or {}) do
		for _, szNpcName in pairs(tbNpcName) do
			ClearMapNpcWithName(nMapId, szNpcName);
		end
	end
end

-- 得到当前周皇家婚礼信息
function Marry:GetCurWeekSuperInfo(nDay)
	
	local tbInfo = nil;
	local szDate = "";
	local nTime = GetTime() + (nDay or 0) * 24 * 3600;
	local tbTime = os.date("*t", nTime);
	
	for i = 1, 7 do
		
		local nTmpDay = 0;
		if tbTime.wday > 2 then
			nTmpDay = i + 2;
		else
			nTmpDay = i - 5;
		end
		
		local nTmpDate = tonumber(os.date("%Y%m%d", nTime + nTmpDay * 24 * 3600 - tbTime.wday * 24 * 3600));
		if self.tbGlobalBuffer[4][nTmpDate] then
			szDate = os.date("%Y-%m-%d", nTime + nTmpDay * 24 * 3600 - tbTime.wday * 24 * 3600);
			tbInfo = self.tbGlobalBuffer[4][nTmpDate];
			break;
		end
	end
	
	if tbInfo then
		return 1, tbInfo[1], tbInfo[2], tbInfo[3], szDate;
	end
	
	return nil;
end

function Marry:DeleverLijin_GS(nServerId, szMaleName, szFemaleName, nSum)
	if (not nServerId or not szMaleName or not szFemaleName or not nSum or nSum <= 0) then
		return;
	end
	if (nServerId ~= GetServerId()) then
		return;
	end
	
	local nSendMoney = math.floor(nSum / 2);
	local szTitle = "Tiền Mừng Lễ";
	local szDate = tostring(os.date("%Y-%m-%d", GetTime()));
	local szContent = string.format("Lúc <color=green>%s<color> tại buổi lễ, các vị khách mời đã mừng <color=yellow>%s<color> bạc, Số tiền này sẽ được chia đều cho 2 hiệp lữ.\n", szDate, nSum);
	szContent = szContent .. "   Đó là một buổi lễ trọng đại. Chúc 2 hiệp lữ răng long đầu bạc.";
	KPlayer.SendMail(szMaleName, szTitle, szContent, 0, nSendMoney);
	KPlayer.SendMail(szFemaleName, szTitle, szContent, 0, nSendMoney);
	
	Dbg:WriteLog("Marry", "结婚系统", string.format("%s跟%s的典礼礼金总额：%s", szMaleName, szFemaleName, nSum));
end

-- 开启系统
function Marry:_Start_GS()
	self.OPEN_STATE = 1;
end
