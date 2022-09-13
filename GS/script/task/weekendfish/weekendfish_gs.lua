-- 文件名　：weekendfish_gs.lua
-- 创建者　：huangxiaoming
-- 创建时间：2011-08-05 14:12:10
-- 描  述  ：

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\task\\weekendfish\\weekendfish_def.lua")

-- 检查玩家
function WeekendFish:CheckPlayerLimit(pPlayer)
	if pPlayer.nLevel < self.PLAYER_LEVEL_LIMIT or pPlayer.nFaction <= 0 then
		return 0, "Nhân vật có đẳng cấp dưới 30 và chưa nhập môn phái không thể thao tác."
	end
	return 1;
end


-- 检查今日可做鱼饵的个数
function WeekendFish:CheckTodayMakeRemainNum(pPlayer)
	local nWeek = tonumber(GetLocalDate("%w"));
	local nFlag = 0;
	for _, nTemp in pairs(WeekendFish.TB_ACCEPTTASKWEEKDAY) do
		if nTemp == nWeek then
			nFlag = 1;
			break;
		end
	end
	if nFlag ~= 1 then
		return 0, "鱼饵只有在周六或者周日才能制作，不要心急哦。";
	end
	local nDay = Lib:GetLocalDay(GetTime());
	local nTaskDay = pPlayer.GetTask(self.TASK_GROUP, self.TASK_MAKE_DAY);
	if nTaskDay < nDay then
		pPlayer.SetTask(self.TASK_GROUP, self.TASK_MAKE_DAY, nDay);
		pPlayer.SetTask(self.TASK_GROUP, self.TASK_TODAY_MAKE_NUM, 0);
	end
	local nTodayNum = pPlayer.GetTask(self.TASK_GROUP, self.TASK_TODAY_MAKE_NUM);
	local nCanMakeNum = self.DAY_MAKE_NUM_LIMIT - nTodayNum;
	if nCanMakeNum <= 0 then
		return 0, "你今天已经做了50个鱼饵了，无法再制作。";
	end
	return nCanMakeNum;
end

-- 做鱼饵检查
function WeekendFish:CheckCanMakeBait(pPlayer, nNum)
	if self:CheckOpen() ~= 1 then
		return 0, "该活动暂时关闭";
	end
	if self:CheckPlayerLimit(pPlayer) ~= 1 then
		return 0, "Nhân vật có đẳng cấp dưới 30 và chưa nhập môn phái không thể thao tác."
	end
	if GetMapType(pPlayer.nMapId) ~= "city" and GetMapType(pPlayer.nMapId) ~= "village" then
		return 0, "该物品只能在各大新手村和城市使用";
	end
	nNum = nNum or 1;
	local szErrMsg = "";
	if pPlayer.CountFreeBagCell() < 1 then
		szErrMsg = "需要<color=yellow>1格<color>背包空间，请整理下再来吧！";
		return 0, szErrMsg;
	end
	local nNeedGTPMKP = self.NUM_GTPMKP_MAKE * nNum;
	if (pPlayer.dwCurGTP < nNeedGTPMKP or pPlayer.dwCurMKP < nNeedGTPMKP) then
		szErrMsg = string.format("您的精活不足，制作<color=yellow>%s个<color>鱼饵需要消耗精力和活力各<color=yellow>%s点<color>。",nNum, nNeedGTPMKP);
		return 0, szErrMsg;
	end
	local nCanMakeNum = self:CheckTodayMakeRemainNum(pPlayer);
	if nCanMakeNum < nNum then
		szErrMsg = string.format("您今日最多还能制作<color>%s个<color>鱼饵。", nCanMakeNum);
		return 0, szErrMsg;
	end
	local nMaterialCount = pPlayer.GetItemCountInBags(unpack(self.ITEM_MATERIAL_FISHBAILT_FINE));
	if nMaterialCount < nNum then
		szErrMsg = "您身上的鱼饵粉数量不足，鱼饵粉可以在新手村秦洼的渔具商店处购买。";
		return 0, szErrMsg;
	end
	return 1;
end

-- 做鱼饵(有bug，经常回调不到)
function WeekendFish:MakeFishBaitDlg(nCount, nSure)
	if nCount <= 0 then
		return 0;
	end
	local nRet, szErrMsg = self:CheckCanMakeBait(me, nCount);
	if nRet ~= 1 then
		Dialog:Say(szErrMsg);
		return 0;
	end
	if not nSure then
		local szMsg = string.format("Chế tạo <color=yellow>%s mồi câu<color> cần đủ Tinh lực và Hoạt lực <color=yellow>%s điểm<color> mỗi loại và <color=yellow>%s Bột câu cá<color>. Câu cá bằng loại mồi này sẽ hiệu quả hơn loại mồi thô thông thường.\n\nXác nhận chế tạo chứ?", nCount, nCount * self.NUM_GTPMKP_MAKE, nCount);
		local tbOpt = 
		{
			{"Xác nhận", self.MakeFishBaitDlg, self, nCount, 1},
			{"Để ta suy nghĩ thêm"},	
		};
		Dialog:Say(szMsg, tbOpt);
		return 1;
	end
	local tbEvent = 
	{
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
		Player.ProcessBreakEvent.emEVENT_SITE,
		Player.ProcessBreakEvent.emEVENT_USEITEM,
		Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
		Player.ProcessBreakEvent.emEVENT_DROPITEM,
		Player.ProcessBreakEvent.emEVENT_SENDMAIL,
		Player.ProcessBreakEvent.emEVENT_TRADE,
		Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
		Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
		Player.ProcessBreakEvent.emEVENT_DEATH,
	}
	GeneralProcess:StartProcess("Đang chế tạo...", 5 * Env.GAME_FPS, 
		{self.MakeFishBait, self, me.nId, nCount}, nil, tbEvent);
end

-- 真正做鱼饵
function WeekendFish:MakeFishBait(nPlayerId, nCount)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	if self:CheckCanMakeBait(pPlayer, nCount) ~= 1 then
		return 0;
	end
	pPlayer.ConsumeItemInBags(nCount, self.ITEM_MATERIAL_FISHBAILT_FINE[1], self.ITEM_MATERIAL_FISHBAILT_FINE[2], self.ITEM_MATERIAL_FISHBAILT_FINE[3], self.ITEM_MATERIAL_FISHBAILT_FINE[4], -1);
	local nNeedGTPMKP = self.NUM_GTPMKP_MAKE * nCount;
	pPlayer.ChangeCurGatherPoint(-nNeedGTPMKP);
	pPlayer.ChangeCurMakePoint(-nNeedGTPMKP);
	local nAddCount = pPlayer.AddStackItem(self.ITEM_FISHBAIT[2][1], self.ITEM_FISHBAIT[2][2], self.ITEM_FISHBAIT[2][3], self.ITEM_FISHBAIT[2][4], {bForceBind = 1}, nCount);
	if nAddCount < nCount then
		Dbg:WriteLog("WeekendFish", "makefishbait failed", nAddCount, nCount);
	end
	pPlayer.SetTask(self.TASK_GROUP, self.TASK_TODAY_MAKE_NUM, pPlayer.GetTask(self.TASK_GROUP, self.TASK_TODAY_MAKE_NUM) + nAddCount);
	StatLog:WriteStatLog("stat_info", "fishing", "item_proc", nPlayerId, 1, nAddCount);
	return 1;
end

-- 检查今日是否接过任务
function WeekendFish:CheckTodayHaveAcceptedTask(pPlayer)
	local nDay = Lib:GetLocalDay(GetTime());
	local nLastAcceptDay = pPlayer.GetTask(self.TASK_GROUP, self.TASK_ACCEPT_DAY);
	if nLastAcceptDay == nDay then
		return 1;
	end
	return 0;
end

-- 检查今日是否已经领过奖,1领过，0没领过
function WeekendFish:CheckTodayHaveAwardTask(pPlayer)
	if self:CheckTodayHaveAcceptedTask(pPlayer) ~= 1 then	-- 今日没接过任务肯定就没领过奖
		return -1;
	end
	local nLastAwardDay = pPlayer.GetTask(self.TASK_GROUP, self.TASK_AWARD_DAY);
	local nLastAcceptDay = pPlayer.GetTask(self.TASK_GROUP, self.TASK_ACCEPT_DAY);
	if nLastAcceptDay == nLastAwardDay then
		return 1;
	end
	return 0;
end

-- 检查能否接任务
function WeekendFish:CheckCanAcceptTask(pPlayer)
	if not pPlayer then
		return 0;
	end
	local nRes, szMsg = self:CheckAcceptTaskTime();
	if nRes ~= 1 then
		return 0 ,szMsg;
	end
	if pPlayer.nLevel < WeekendFish.PLAYER_LEVEL_LIMIT or pPlayer.nFaction <= 0 then
		return 0, "Nhân vật có đẳng cấp dưới 30 và chưa nhập môn phái không thể thao tác."
	end
	self:CheckTaskIsOverdue(pPlayer); -- 处理一下过期的任务
	if self:CheckTodayHaveAcceptedTask(pPlayer) == 1 then
		return 0, "你今日已经接过任务了哦";
	end
	return 1;
end

-- 是否完成了任务
function WeekendFish:CheckAchievedTask(pPlayer)
	for i = self.TASK_TARGET1, self.TASK_TARGET1 + self.FISH_TASK_NUM - 1 do
		if pPlayer.GetTask(self.TASK_GROUP, i) ~= self.TASK_NEED_FISH_NUM then
			return 0;
		end
	end
	return 1;
end


-- 能否交鱼
function WeekendFish:CheckCanHandInFish(pPlayer)
	if self:CheckPlayerLimit(pPlayer) ~= 1 then
		return 0, "Nhân vật có đẳng cấp dưới 30 và chưa nhập môn phái không thể thao tác."
	end
	local nRes, szMsg = self:CheckAwardTaskTime(pPlayer);
	if nRes ~= 1 then
		return 0, szMsg;
	end
	--if self:CheckTodayHaveAcceptedTask(pPlayer) ~= 1 then
	--	return 0, "您今日还没有接取钓鱼任务，换不了鱼。";
	--end
	nRes = self:GetTodyRemainHandInFishNum(pPlayer);
	if nRes == -1 then
		return 0, "今日已经领取过奖励了,再交鱼也不会有奖励了哦";
	end
	if nRes == 0 then
		return 0, "您今天已经交过50条鱼了，再多我也不收了哦。";
	end
	return 1;
end

-- 检查今日交鱼次数
function WeekendFish:GetTodyRemainHandInFishNum(pPlayer)
	local nTaskDay = pPlayer.GetTask(self.TASK_GROUP, self.TASK_HANDIN_DAY);
	local nDay = Lib:GetLocalDay(GetTime());
	if nDay > nTaskDay then
		pPlayer.SetTask(self.TASK_GROUP, self.TASK_HANDIN_DAY, nDay);
		pPlayer.SetTask(self.TASK_GROUP, self.TASK_HANDIN_AWARD, 0);
		pPlayer.SetTask(self.TASK_GROUP, self.TASK_HANDIN_NUM, 0);
		pPlayer.SetTask(self.TASK_GROUP, self.TASK_HANDIN_WEIGHT, 0);
	end
	if pPlayer.GetTask(self.TASK_GROUP, self.TASK_HANDIN_AWARD) == 1 then
		return -1;
	end
	if pPlayer.GetTask(self.TASK_GROUP, self.TASK_HANDIN_NUM) >= self.MAX_FISH_DAYTIMES then
		return 0;
	end
	return self.MAX_FISH_DAYTIMES - pPlayer.GetTask(self.TASK_GROUP, self.TASK_HANDIN_NUM);
end

-- 是否能换奖励
function WeekendFish:CheckCanChangeAward(pPlayer)
	if self:CheckPlayerLimit(pPlayer) ~= 1 then
		return 0, "Nhân vật có đẳng cấp dưới 30 và chưa nhập môn phái không thể thao tác."
	end
	local nRes, szMsg = self:CheckAwardTaskTime(pPlayer);
	if nRes ~= 1 then
		return 0, szMsg;
	end
	--if self:CheckTodayHaveAcceptedTask(pPlayer) ~= 1 then
	--	return 0, "您今日没有接取钓鱼任务，何来奖励发放呢？";
	--end
	local nTaskDay = pPlayer.GetTask(self.TASK_GROUP, self.TASK_HANDIN_DAY);
	local nDay = Lib:GetLocalDay(GetTime());
	if nDay ~= nTaskDay then
		return 0, "您今日没有上交过鱼，何来奖励发放呢？";
	
	end
	if pPlayer.GetTask(self.TASK_GROUP, self.TASK_HANDIN_AWARD) == 1 then
		return 0, "您今日已经领取过奖励了，莫要太贪心哦。";
	end
	return 1;
end

-- 检查能否领奖
function WeekendFish:CheckCanAwardTask(pPlayer)
	if not pPlayer then
		return 0;
	end
	self:CheckTaskIsOverdue(pPlayer);
	if not Task:GetPlayerTask(pPlayer).tbTasks[self.TASK_MAIN_ID] then
		return 0, "没有钓鱼任务";
	end
	local nRes, szMsg = self:CheckAwardTaskTime();
	if nRes ~= 1 then
		return 0, szMsg;
	end
	if self:CheckTodayHaveAwardTask(pPlayer) == 0 and self:CheckAchievedTask(pPlayer) == 1 then
		return 1;
	end
	return 0, "没有奖励可以领取";
end

-- 清空任务变量
function WeekendFish:ClearTaskValue(pPlayer)
	for i = 0, self.FISH_TASK_NUM - 1 do
			pPlayer.SetTask(self.TASK_GROUP,self.TASK_FISH_ID1 + i, 0);
		end
	pPlayer.SetTask(self.TASK_GROUP, self.TASK_TEAM_IDGROUP, 0);
end

-- 检查能否鉴别鱼
function WeekendFish:CheckCanDetectFish(pPlayer)
	if self:CheckOpen() ~= 1 then
		return 0, "Sự kiện vẫn chưa bắt đầu, hãy quay lại vào thứ 7 và Chủ Nhật hàng tuần. Thứ Bảy và Chủ Nhật 10:00-13:00; 16:00-19:00 là thời gian câu cá, và thời gian nhận thưởng sẽ kéo dài đến 23:30 vào tối thứ Bảy và Chủ Nhật.";
	end
	if self:CheckPlayerLimit(pPlayer) ~= 1 then
		return 0, "Nhân vật có đẳng cấp dưới 30 và chưa nhập môn phái không thể thao tác."
	end
	--if not Task:GetPlayerTask(pPlayer).tbTasks[self.TASK_MAIN_ID] then
	--	return 0, "没有钓鱼任务，不能鉴别";
	--end
	local tbNpcList = KNpc.GetAroundNpcList(pPlayer, self.MAX_FISH_RANGE);
	for _, pNpc in ipairs(tbNpcList) do
		if pNpc.nTemplateId >= self.NPC_FISH_ID[1] and pNpc.nTemplateId <= self.NPC_FISH_ID[5] then -- 如果出现不连续需要单独加判断，为了节省效率
			return 1, pNpc.dwId;
		end
	end
	return 0, "Không tìm thấy đàn cá";
end


-- 检查今日钓鱼的剩余次数
function WeekendFish:CheckTodayFishRemainNum(pPlayer)
	local nDay = Lib:GetLocalDay(GetTime());
	local nTaskDay = pPlayer.GetTask(self.TASK_GROUP, self.TASK_FISH_DAY);
	if nTaskDay < nDay then
		pPlayer.SetTask(self.TASK_GROUP, self.TASK_FISH_DAY, nDay);
		pPlayer.SetTask(self.TASK_GROUP, self.TASK_TODAY_FISHTIMES, 0);
	end
	return self.MAX_FISH_DAYTIMES - pPlayer.GetTask(self.TASK_GROUP, self.TASK_TODAY_FISHTIMES);
end

-- 检查鱼饵,返回的是随机鱼重量所用的type
function WeekendFish:CheckHaveFishBait(pPlayer)
	local nFishBaitFine = pPlayer.GetItemCountInBags(unpack(self.ITEM_FISHBAIT[2]));
	if nFishBaitFine >= 1 then
		return 2;
	end 
	local nFishBaitRough = pPlayer.GetItemCountInBags(unpack(self.ITEM_FISHBAIT[1]));
	if nFishBaitRough >= 1 then 
		return 1;
	end
	return 0;
end

-- 根据鱼饵类型和祝福返回鱼的重量等级
function WeekendFish:GetWeightType(nFishBaiType, nHaveBless)
	if nHaveBless == 1 then
		if nFishBaiType == 2 then
			return 4;
		else
			return 2;
		end
	else
		if nFishBaiType == 2 then
			return 3;
		else
			return 1;
		end
	end
	return 1;
end

-- 可否钓鱼
function WeekendFish:CheckCanFish(pPlayer)
	if self:CheckOpen() ~= 1 then
		return 0, "活动还未开启";
	end
	local nRes, szMsg1 = self:CheckPlayerLimit(pPlayer);
	if nRes ~= 1 then
		return 0, szMsg1;
	end
	local nResult, szMsg = self:CheckFishTime();
	if nResult ~= 1 then
		return 0, szMsg;
	end
	if self:CheckHaveFishBait(pPlayer) <= 0 then
		return 0, "你的身上没有鱼饵";
	end
	--[[if not Task:GetPlayerTask(pPlayer).tbTasks[self.TASK_MAIN_ID] then
		return 0, "没有接钓鱼任务";
	end
	local nDay = Lib:GetLocalDay(GetTime());
	local nLastAcceptDay = pPlayer.GetTask(self.TASK_GROUP, self.TASK_ACCEPT_DAY);
	if nLastAcceptDay ~= nDay then
		self:CancelTask(pPlayer);
		return 0, "没有钓鱼任务";
	end
	local nLastAwardDay = pPlayer.GetTask(self.TASK_GROUP, self.TASK_AWARD_DAY);
	if nLastAwardDay == nLastAcceptDay then
		self:CancelTask(pPlayer);
		return 0, "已经交过任务了";
	end]]--
	local nRemainTimes = self:CheckTodayFishRemainNum(pPlayer);
	if nRemainTimes <= 0 then
		return 0, string.format("每次最多钓%s次", self.MAX_FISH_DAYTIMES);
	end
	local nRet, nFishId = self:CheckFishNearly(pPlayer);
	if nRet == 0 then
		return 0, "周围没有可以钓的鱼群";
	end
	if nRet == -1 then
		return 0, "这个鱼群已经被人掉完了";
	end
	if nRet == -2 then
		return 0, "这个鱼群的鱼不够这么多人同时钓了，还是换一个吧";
	end
	return 1, nFishId;
end

--检查周围是否有鱼群
function WeekendFish:CheckFishNearly(pPlayer)
	local nRet = 0;
	local tbNpcList = KNpc.GetAroundNpcList(pPlayer, self.MAX_FISH_RANGE);
	for _, pNpc in ipairs(tbNpcList) do
		if pNpc.nTemplateId >= self.NPC_FISH_ID[1] and pNpc.nTemplateId <= self.NPC_FISH_ID[5] then -- 如果出现不连续需要单独加判断，为了节省效率
			local nRet1 = self:CheckHaveFish(pNpc.dwId);
			if nRet1 == -1 or nRet1 == -2 then
				nRet = nRet1;
			end
			if nRet1 == 1 then
				return 1, pNpc.dwId;
			end
		end
	end
	return nRet;
end

-- 检查该鱼群是否还有鱼
function WeekendFish:CheckHaveFish(dwNpcId)
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then
		return 0;
	end
	local tbNpcFish = pNpc.GetTempTable("Npc").tbFishInfo;
	if not tbNpcFish then
		print("tbNpcFish not found");
		return 0;
	end
	tbNpcFish.nFishTimes = tbNpcFish.nFishTimes or 0;
	if tbNpcFish.nFishTimes >= self.MAX_FISH_TIMES then
		return -1;
	end
	tbNpcFish.nFishingNum = tbNpcFish.nFishingNum or 0;	-- 正在钓这群鱼的玩家个数
	if tbNpcFish.nFishingNum >= self.MAX_FISHING_NUM or tbNpcFish.nFishingNum >= self.MAX_FISH_TIMES - tbNpcFish.nFishTimes then
		return -2;
	end
	return 1;
end


-- 获取属于玩家的鱼漂
function WeekendFish:GetOwnPlayerFloatId(pPlayer)
	local tbNpcList = KNpc.GetAroundNpcList(pPlayer, self.MAX_FLOAT_RANGE);
	local nPlayerId = pPlayer.nId;
	for _, pNpc in ipairs(tbNpcList) do
		if pNpc.nTemplateId >= self.FISH_FLOAT[1] and pNpc.nTemplateId <= self.FISH_FLOAT[5] then -- 注意鱼漂的id是连续的，不连续需要额外处理
			local tbFloatInfo = pNpc.GetTempTable("Npc").tbFloatInfo;
			if tbFloatInfo then
				if tbFloatInfo.nOwnPlayer == nPlayerId then
					return pNpc.dwId;
				end
			end
		end
	end
	return 0; -- 没有找到属于该玩家的鱼漂
end

-- 取消任务
function WeekendFish:CancelTask(pPlayer)
	if Task:GetPlayerTask(pPlayer).tbTasks[self.TASK_MAIN_ID] then
		pPlayer.Msg("Thật không may, nhiệm vụ Câu cá của bạn đã thất bại do quá hạn hoàn thành.");
		Setting:SetGlobalObj(pPlayer);
		Task:CloseTask(self.TASK_MAIN_ID, "giveup");
		Setting:RestoreGlobalObj()
	end
end

-- 检查任务是否过期,过期则取消
function WeekendFish:CheckTaskIsOverdue(pPlayer)
	if Task:GetPlayerTask(pPlayer).tbTasks[self.TASK_MAIN_ID] then
		local nDay = Lib:GetLocalDay(GetTime());
		local nLastAcceptDay = pPlayer.GetTask(self.TASK_GROUP, self.TASK_ACCEPT_DAY);
		if nLastAcceptDay ~= nDay then
			self:CancelTask(pPlayer);
			return 1;
		end
		return 0;
	end
	return 0;
end

-- 完成一种鱼的任务
function WeekendFish:AchieveTask(pPlayer, nSort)
	local nTaskIndex = 0;
	for i = 1, self.FISH_TASK_NUM do
		if pPlayer.GetTask(self.TASK_GROUP, self.TASK_FISH_ID1 + i - 1) == nSort then
			nTaskIndex = i;
			break;
		end
	end
	if nSort <= 0 then
		return 0;
	end
	local nTaskValue = pPlayer.GetTask(self.TASK_GROUP, self.TASK_TARGET1 + nTaskIndex - 1);
	local nBlackFlag = 0;	-- 是否第一次黑条提示
	if nTaskValue < self.TASK_NEED_FISH_NUM then
		nTaskValue = nTaskValue + 1;
		if nTaskValue == self.TASK_NEED_FISH_NUM then
			nBlackFlag = 1;
		end
	end
	pPlayer.SetTask(self.TASK_GROUP, self.TASK_TARGET1 + nTaskIndex - 1, nTaskValue);
	if nBlackFlag == 1 and self:CheckAchievedTask(pPlayer) == 1 then
		--pPlayer.Msg("你已完成今日钓鱼任务，赶快向秦洼领取任务奖励吧。");
		Dialog:SendBlackBoardMsg(pPlayer, "你已完成今日钓鱼任务，赶快向秦洼领取任务奖励吧");
	end
	return 1;
end
-------------------钓鱼的3个步骤------------------------------------
-- 鉴别鱼
function WeekendFish:DetectFinishSort(nPlayerId, dwFishId, dwAllodesmusId)
	local pAllodesmus = KNpc.GetById(dwAllodesmusId);
	if pAllodesmus then
		pAllodesmus.Delete();
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local pNpcFish = KNpc.GetById(dwFishId);
	if not pNpcFish then
		pPlayer.Msg("Đàn cá đã bị người khác câu hết rồi!");
		return 0;
	end
	local tbFishInfo = pNpcFish.GetTempTable("Npc").tbFishInfo;
	if not tbFishInfo then
		pPlayer.Msg("Không thể xác định được loại cá.");
		return 0;
	end
	if tbFishInfo.nSortIndex > 0 then
		pPlayer.Msg(string.format("Thủy Sản Đại Sư: \"Là đàn <color=green>%s<color> đây mà.\"", KItem.GetNameById(unpack(WeekendFish.ITEM_FISH_ID[tbFishInfo.nSortIndex]))));
	else
		pPlayer.Msg("Không thể nhận ra đây là loại cá gì.");
	end
end

-- 鉴别鱼被打断
function WeekendFish:DetectFinishSortBreak(nPlayerId, dwAllodesmusId)
	local pAllodesmus = KNpc.GetById(dwAllodesmusId);
	if pAllodesmus then
		pAllodesmus.Delete();
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	pPlayer.Msg("Vẫn chưa xác định được đàn cá là loại gì.");
end

-- 进度条读完,肯定没有钓到鱼了
function WeekendFish:ProcessFinish(nPlayerId, dwFloatId, dwFishId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		pPlayer.SetTask(WeekendFish.TASK_GROUP, WeekendFish.TASK_FISHING_STATE, 0);
		pPlayer.Msg("运气不好啊，这一钩没钓到鱼，别灰心，继续努力吧！");
	end
	local pNpcFloat = KNpc.GetById(dwFloatId);
	local pNpcFish = KNpc.GetById(dwFishId);
	if pNpcFloat then
		local tbFloatInfo = pNpcFloat.GetTempTable("Npc").tbFloatInfo;
		if not tbFloatInfo then
			pNpcFloat.Delete();
			return 0;
		end
		local nFreePos = tbFloatInfo.nPosIndex;
		if pNpcFish then
			local tbFishInfo = pNpcFish.GetTempTable("Npc").tbFishInfo;
			if not tbFishInfo then
				pNpcFloat.Delete();
				return 0;
			end
			-- 恢复一下鱼群的状态
			if tbFishInfo.tbFloatPos[nFreePos] == 1 then
				tbFishInfo.nFishingNum = tbFishInfo.nFishingNum - 1;
				tbFishInfo.tbFloatPos[nFreePos] = 0;
			end
		end
		pNpcFloat.Delete();
	end		
	return 0;
end

-- 每十秒检查一次是否有鱼上钩
function WeekendFish:DetectFishing(nPlayerId, dwFloatId, dwFishId, nStep)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	local pNpcFloat = KNpc.GetById(dwFloatId);
	local pNpcFish = KNpc.GetById(dwFishId);
	if not pPlayer then	-- 玩家不在了恢复一下鱼群状态
		if pNpcFloat then
			local tbFloatInfo = pNpcFloat.GetTempTable("Npc").tbFloatInfo;
			if not tbFloatInfo then
				pNpcFloat.Delete();
				return 0;
			end
			local nFreePos = tbFloatInfo.nPosIndex;
			if pNpcFish then
				local tbFishInfo = pNpcFish.GetTempTable("Npc").tbFishInfo;
				if not tbFishInfo then
					pNpcFloat.Delete();
					return 0;
				end
				if tbFishInfo.tbFloatPos[nFreePos] == 1 then
					tbFishInfo.nFishingNum = tbFishInfo.nFishingNum - 1;
					tbFishInfo.tbFloatPos[nFreePos] = 0;
				end
			end
			pNpcFloat.Delete();
		end		
		return 0;
	end
	if not pNpcFloat then	-- 漂不见了？不可能吧，无能为力
		return 0;
	end
	if not pNpcFish then	-- 鱼有可能被钓完了
		if pNpcFloat then
			pNpcFloat.Delete();
		end
		return 0;
	end
	local nSuccess = self:RandFishSuccess();
	local tbFloatInfo = pNpcFloat.GetTempTable("Npc").tbFloatInfo;
	if not tbFloatInfo then
		pNpcFloat.Delete();
		return 0;
	end
	tbFloatInfo.nDetectFishingTimerId = nil; -- 定时器走到先置空
	local nFishBaitType = self:CheckHaveFishBait(pPlayer);
	if nFishBaitType <= 0 then	-- 身上没有鱼饵
		local nFreePos = tbFloatInfo.nPosIndex;
		if pNpcFish then
			local tbFishInfo = pNpcFish.GetTempTable("Npc").tbFishInfo;
			if not tbFishInfo then
				pNpcFloat.Delete();
				return 0;
			end
			if tbFishInfo.tbFloatPos[nFreePos] == 1 then
				tbFishInfo.nFishingNum = tbFishInfo.nFishingNum - 1;
				tbFishInfo.tbFloatPos[nFreePos] = 0;
			end
		end
		pNpcFloat.Delete();
		return 0;
	end
	
	if nSuccess == 1 then
		--Dialog:SendBlackBoardMsg(pPlayer, "鱼儿上钩了"); -- 暂时先替着
		pNpcFloat.CastSkill(self.FLOAT_SKILLID, 1, -1, pNpcFloat.nIndex);
		tbFloatInfo.nState = 1;
		tbFloatInfo.nTimerId = Timer:Register(WeekendFish.SHINE_TIME, WeekendFish.HarvestFailure, WeekendFish, nPlayerId, dwFloatId, dwFishId);
	else	-- 没钓上鱼
		if nStep < WeekendFish.TOTAL_FISH_TIMES then
			tbFloatInfo.nDetectFishingTimerId = Timer:Register(WeekendFish.DETECT_FISHING, WeekendFish.DetectFishing, WeekendFish, nPlayerId, dwFloatId, dwFishId, nStep + 1);
		end
	end
	return 0;
end

-- 进度条被打断,需要关鱼定时器，删鱼漂
function WeekendFish:ProcessBreak(nPlayerId, dwFloatId, dwFishId, nStep)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		pPlayer.SetTask(WeekendFish.TASK_GROUP, WeekendFish.TASK_FISHING_STATE, 0);
	end
	local pNpcFloat = KNpc.GetById(dwFloatId);
	local pNpcFish = KNpc.GetById(dwFishId);
	if pNpcFloat then
		local tbFloatInfo = pNpcFloat.GetTempTable("Npc").tbFloatInfo;
		if not tbFloatInfo then
			pNpcFloat.Delete();
			return 0;
		end
		if tbFloatInfo.nDetectFishingTimerId then
			Timer:Close(tbFloatInfo.nDetectFishingTimerId);
			tbFloatInfo.nDetectFishingTimerId = nil;
		end
		local nFreePos = tbFloatInfo.nPosIndex;
		if pNpcFish then
			local tbFishInfo = pNpcFish.GetTempTable("Npc").tbFishInfo;
			if not tbFishInfo then
				pNpcFloat.Delete();
				return 0;
			end
			-- 恢复一下鱼群的状态
			if tbFishInfo.tbFloatPos[nFreePos] == 1 then
				tbFishInfo.nFishingNum = tbFishInfo.nFishingNum - 1;
				tbFishInfo.tbFloatPos[nFreePos] = 0;
			end
		end
		pNpcFloat.Delete();
		return 0;
	end	
	if not pNpcFloat then	-- 漂不见了？不可能吧，无能为力
		return 0;
	end	
	if not pNpcFish then	-- 鱼有可能被钓完了
		if pNpcFloat then
			pNpcFloat.Delete();
		end
		return 0;
	end
end

-- 到时间了没收杆
function WeekendFish:HarvestFailure(nPlayerId, dwFloatId, dwFishId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		pPlayer.SetTask(WeekendFish.TASK_GROUP, WeekendFish.TASK_FISHING_STATE, 0); -- 保证钓鱼状态的恢复
	end
	local pNpcFloat = KNpc.GetById(dwFloatId);
	local pNpcFish = KNpc.GetById(dwFishId);
	if pNpcFloat then
		local tbFloatInfo = pNpcFloat.GetTempTable("Npc").tbFloatInfo;
		if not tbFloatInfo then
			pNpcFloat.Delete();
			return 0;
		end
		local nFreePos = tbFloatInfo.nPosIndex;
		if pNpcFish then
			local tbFishInfo = pNpcFish.GetTempTable("Npc").tbFishInfo;
			if not tbFishInfo then
				pNpcFloat.Delete();
				return 0;
			end
			if tbFishInfo.tbFloatPos[nFreePos] == 1 then
				tbFishInfo.nFishingNum = tbFishInfo.nFishingNum - 1;
				tbFishInfo.tbFloatPos[nFreePos] = 0;
			end
		end
		pNpcFloat.Delete();
	end	
	if pPlayer then
		pPlayer.CloseGenerProgress();
		pPlayer.Msg("Thật tiếc, cá đã cắn câu nhưng lại chạy mất");	
		Dialog:SendBlackBoardMsg(pPlayer, "Thật tiếc, cá đã cắn câu nhưng lại chạy mất");
	end
	return 0;
end

-- 收杆
function WeekendFish:FinishFishing(nPlayerId)
	if self:CheckFishTime() ~= 1 then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	pPlayer.SetTask(WeekendFish.TASK_GROUP, WeekendFish.TASK_FISHING_STATE, 0); -- 保证钓鱼状态的恢复
	local nFloatId = self:GetOwnPlayerFloatId(pPlayer);
	if nFloatId <= 0 then
		pPlayer.Msg("Thật tiếc, cá đã cắn câu nhưng lại chạy mất");
		Dialog:SendBlackBoardMsg(pPlayer, "Thật tiếc, cá đã cắn câu nhưng lại chạy mất");
		pPlayer.CloseGenerProgress();
		return 0;
	end
	local pNpcFloat = KNpc.GetById(nFloatId);
	if not pNpcFloat then
		pPlayer.CloseGenerProgress();
		return 0;
	end
	local nNpcHideMap, nNpcHidePosX, nNpcHidePosY = pNpcFloat.GetWorldPos();
	local tbFloatInfo = pNpcFloat.GetTempTable("Npc").tbFloatInfo;
	if not tbFloatInfo then
		pPlayer.CloseGenerProgress();
		return 0;
	end

	if tbFloatInfo.nState == 1 then
		tbFloatInfo.nState = 0;
		if tbFloatInfo.nTimerId then
			Timer:Close(tbFloatInfo.nTimerId);
			tbFloatInfo.nTimerId = nil;
		end
		local nSort = self:GetRandFish(pPlayer, tbFloatInfo.nOwnFishId);
		if nSort > 0 then -- 成功掉上了鱼
			self:ReduceFish(tbFloatInfo.nOwnFishId); -- 成功被钓走鱼之后给鱼群的鱼数量-1
			self:AchieveTask(pPlayer, nSort);
			Achievement:FinishAchievement(pPlayer, 380);
			Achievement:FinishAchievement(pPlayer, 381);
			Achievement:FinishAchievement(pPlayer, 382);
			Achievement:FinishAchievement(pPlayer, 383);
			if nSort == 23 then
				Achievement:FinishAchievement(pPlayer, 385);
			end
		end
		pPlayer.CloseGenerProgress();
		return 1;
	else
		pPlayer.Msg("Cá chưa cắn câu, hãy kiên nhẫn chờ đợi");
		Dialog:SendBlackBoardMsg(pPlayer, "Cá chưa cắn câu, hãy kiên nhẫn chờ đợi");
		pPlayer.CloseGenerProgress();
		return 0;
	end
end

-- 随机上钩的鱼
function WeekendFish:GetRandFish(pPlayer, dwFishId)
	local pNpcFish = KNpc.GetById(dwFishId);
	if not pNpcFish then
		return 0;
	end
	local nFishBaitType = self:CheckHaveFishBait(pPlayer);
	if nFishBaitType <= 0 then
		pPlayer.Msg("Không có mồi câu thì làm sao câu cá được?");
		return 0;
	end
	local nFishSort = pNpcFish.GetTempTable("Npc").tbFishInfo.nSortIndex;
	if not nFishSort then
		return 0;
	end
	if pPlayer.CountFreeBagCell() < 1 then
		pPlayer.Msg("Hành trang đầy đồ thế này, đành nhìn đàn cá bơi đi thôi.");
		Dialog:SendBlackBoardMsg(pPlayer, "Hành trang đầy đồ thế này, đành nhìn đàn cá bơi đi thôi.");
		return 0;
	end
	local nIsFish = self:RandIsFish();
	if nIsFish == 1 then
		pPlayer.ConsumeItemInBags(1, self.ITEM_FISHBAIT[nFishBaitType][1], self.ITEM_FISHBAIT[nFishBaitType][2], self.ITEM_FISHBAIT[nFishBaitType][3], self.ITEM_FISHBAIT[nFishBaitType][4], -1);
		local pItem = pPlayer.AddItem(unpack(self.ITEM_FISH_ID[nFishSort]));
		if pItem then
			pItem.Bind(3);
			local szDate = os.date("%Y/%m/%d/23/30/00", GetTime()); -- 当天有效
       		pPlayer.SetItemTimeout(pItem, szDate);
       		local nHaveBless = self:CheckHaveBless(pPlayer);
       		local nWeightType = self:GetWeightType(nFishBaitType, nHaveBless);
       		local nWeight = self:RandFishWeight(nWeightType);
       		if nWeight == 50 then
       			Achievement:FinishAchievement(pPlayer, 386);
       			-- 公告
       			pPlayer.SendMsgToFriend(string.format("Hảo hữu [<color=yellow>%s<color>] bắt được cá <color=yellow>%s nặng 50 cân<color>, thật đáng gờm!", pPlayer.szName, pItem.szName));
--       			Player:SendMsgToKinOrTong(pPlayer, string.format(" bắt được cá nặng50斤的%s, thật đáng gờm!", pItem.szName));
       			KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, string.format("%s bắt được cá %s nặng 50 cân, thật đáng gờm!", pPlayer.szName, pItem.szName));
       		end
       		if nWeight >= 40 and nWeight < 50 then
       			pPlayer.SendMsgToFriend(string.format("Hảo hữu [<color=yellow>%s<color>] bắt được cá <color=yellow>%s nặng %s cân<color>, thật đáng gờm!", pPlayer.szName, pItem.szName, nWeight));
--       			Player:SendMsgToKinOrTong(pPlayer, string.format(" bắt được cá nặng%s斤的%s, thật đáng gờm!", nWeight, pItem.szName));
       		end
       		pItem.SetGenInfo(1, nWeight);-- 设置鱼的重量
       		pItem.Sync();
       		local nTodayNum = pPlayer.GetTask(self.TASK_GROUP, self.TASK_TODAY_FISHTIMES);
			pPlayer.Msg(string.format("Chúc mừng bạn đã câu được cá thứ <color=yellow>%s<color> hôm nay. Đây là <color=yellow>%s<color> nặng <color=green>%s cân<color>", nTodayNum + 1, pItem.szName, nWeight));
			pPlayer.SetTask(self.TASK_GROUP, self.TASK_TODAY_FISHTIMES, nTodayNum + 1);
			pPlayer.SetTask(self.TASK_GROUP, self.TASK_FISH_TIMES, pPlayer.GetTask(self.TASK_GROUP, self.TASK_FISH_TIMES) + 1);
			local nWeightLevel = self:GetLevelByWeight(nWeight);
			pPlayer.CastSkill(self.FISH_SUCCESS_SKILLID[nWeightLevel], 1, -1, pPlayer.GetNpc().nIndex);
			-- log
			StatLog:WriteStatLog("stat_info", "fishing", "fishing", pPlayer.nId, nFishBaitType - 1, string.format("%s-%s-%s-%s", unpack(self.ITEM_FISH_ID[nFishSort])), nWeight);
			if nTodayNum == 0 then
				pPlayer.SetTask(self.TASK_GROUP, self.TASK_FIRSTFISH_TIME, GetTime());
			end
			return nFishSort;
		else
			Dbg:WriteLog("WeekendFish", "add item failure", pPlayer.szName);
		end
	else
		local nRand = MathRandom(100)
		if nRand <= 70 then
			local nSundriesIndex = self:RandSundries();
			local pItem = pPlayer.AddItem(unpack(self.ITEM_SUNDRIES_ID[nSundriesIndex]));
			if pItem then
				pItem.Bind(1);
				pPlayer.Msg("Ai lại vứt rác dưới sông thế này!!!");
				Achievement:FinishAchievement(pPlayer, 384);
			end
		else
			local pItem = pPlayer.AddItem(18, 1, 553, 1);
			if pItem then
				pItem.Bind(1);
				pPlayer.Msg("Rác dưới sông sao lại lấp lánh thế này!?");
			end
		end
	end
	return 0;
end

-- 检查是否有秦洼的祝福
function WeekendFish:CheckHaveBless(pPlayer)
	if pPlayer.GetSkillState(self.STATE_SKILLID) > 0 then
		return 1;
	end
	return 0;
end

---------------------刷鱼--------------------------------------
function WeekendFish:RefreshFish_GS(tbRefreshFishSort)
	if ServerEvent.nStartedFlag ~= 1 then
		return 0;
	end
	if not self.tbFishMapPos then
		local tbTempFile = Lib:LoadTabFile(self.FILE_FISH_POS_PATH);
		if not tbTempFile or #tbTempFile == 0 then
			Dbg:WriteLog("WeekendFish", "load fish file failure");
			return 0;
		end
		self.tbFishMapPos = {};
		for i = 1, #tbTempFile do
			local tbTemp = {};
			local nMapId = tonumber(tbTempFile[i]["MAPID"]);
			local nPosX = tonumber(tbTempFile[i]["POSX"]) / 32;
			local nPosY = tonumber(tbTempFile[i]["POSY"]) / 32;
			if SubWorldID2Idx(nMapId) >= 0 then
				if not self.tbFishMapPos[nMapId] then
					self.tbFishMapPos[nMapId] = {};
				end
				table.insert(self.tbFishMapPos[nMapId], {nPosX, nPosY});
			end
		end
	end
	if self.nRefreshFlag and self.nRefreshFlag == 1 then
		return 0;
	end
	self.nRefreshFlag = 1;
	self.tbExistFishInfo = {};	-- 鱼群的存在情况
	for nMapId, tbTemp in pairs(self.tbFishMapPos) do
		self.tbExistFishInfo[nMapId] = {};
		for i = 1, #tbTemp do
			self.tbExistFishInfo[nMapId][i] = 0; -- 默认没有鱼
		end
	end
	self.tbRefreshFishSort = {};-- 每个地图包含的两种鱼群
	for nMapId, tbSort in pairs(tbRefreshFishSort) do
		if SubWorldID2Idx(nMapId) >= 0 then
			self.tbRefreshFishSort[nMapId] = tbSort; 
		end
	end
	for nMapId, tbSort in pairs(self.tbRefreshFishSort) do	-- 确定每个点刷几号鱼
		local tbRand = self:GetSmashTable(1, #self.tbFishMapPos[nMapId]);
		local nHalf = math.floor(self.MAX_REFRESH_NUM / 2);
		local nNum = self.MAX_REFRESH_NUM;
		if #self.tbFishMapPos[nMapId] < self.MAX_REFRESH_NUM then 
			nHalf = math.floor(#tbRand / 2);
			nNum = #self.tbFishMapPos[nMapId];
		end
		for i = 1, nHalf do	-- 前一半赋第一种鱼
			self.tbExistFishInfo[nMapId][tbRand[i]] = self.tbRefreshFishSort[nMapId][1];
		end
		for i = nHalf + 1, nNum do -- 后一半赋第二种鱼
			self.tbExistFishInfo[nMapId][tbRand[i]] = self.tbRefreshFishSort[nMapId][2];
		end
	end 
	for nMapId, tbIndex in pairs(self.tbExistFishInfo) do -- 刷出鱼
		for i = 1, #tbIndex do
			if tbIndex[i] ~= 0 then
				local nAreaId = self:GetAreaIdByFishId(tbIndex[i]);
				local pNpc = KNpc.Add2(self.NPC_FISH_ID[nAreaId], 100, -1, nMapId, self.tbFishMapPos[nMapId][i][1], self.tbFishMapPos[nMapId][i][2]);
				if pNpc then
					pNpc.GetTempTable("Npc").tbFishInfo= {};
					pNpc.GetTempTable("Npc").tbFishInfo.nExistIndex = i;	-- 地图坐标的索引
					pNpc.GetTempTable("Npc").tbFishInfo.nSortIndex = tbIndex[i]; -- 鱼的类型
				else
					Dbg:WriteLog("WeekendFish", "add fish failure");
				end
			end
		end
	end
end

-- 到时间清鱼
function WeekendFish:ClearAllFish_GS()
	if self.nRefreshFlag ~= 1 then
		return 0;
	end
	if not self.tbExistFishInfo then
		return 0;
	end
	for nMapId, _ in pairs(self.tbExistFishInfo) do
		if SubWorldID2Idx(nMapId) >= 0 then
			for i = 1, #self.NPC_FISH_ID do
				ClearMapNpcWithTemplateId(nMapId, self.NPC_FISH_ID[i]);
			end
		end
	end
	self.tbExistFishInfo = {};
	self.nRefreshFlag = 0;
end

-- 鱼群的鱼数量-1
function WeekendFish:ReduceFish(dwFishId)
	local pNpcFish = KNpc.GetById(dwFishId);
	if not pNpcFish then
		print("鱼群跑哪里去了？");
		return 0;
	end
	local tbFishInfo = pNpcFish.GetTempTable("Npc").tbFishInfo;
	if not tbFishInfo then
		pNpcFish.Delete();
		return 0;
	end
	tbFishInfo.nFishTimes = tbFishInfo.nFishTimes or 0;	
	tbFishInfo.nFishTimes = tbFishInfo.nFishTimes + 1;
	if tbFishInfo.nFishTimes >= self.MAX_FISH_TIMES then
		local nMapId = pNpcFish.GetWorldPos();
		pNpcFish.Delete();
		self:UpdateFish(nMapId, tbFishInfo.nExistIndex);
	end
end

-- 更新一个鱼群
function WeekendFish:UpdateFish(nMapId, nUpdateIndex)
	if not self.tbExistFishInfo then
		print("not self.tbExistFishInfo");
		return 0;
	end
	if not self.tbExistFishInfo[nMapId] then
		return 0;
	end
	if not self.tbFishMapPos[nMapId] then
		return 0;
	end
	if self:CheckFishTime() ~= 1 then -- 过了钓鱼时间，不刷鱼了
		return 0;
	end
	local nFishSort = self.tbExistFishInfo[nMapId][nUpdateIndex];
	if not nFishSort then
		return 0;
	end
	self.tbExistFishInfo[nMapId][nUpdateIndex] = 0;
	local tbFreeIndex = {};	-- 在tbExistFishInfo表中找寻空闲的位置
	local nIndex = 1;
	for i = 1, #self.tbExistFishInfo[nMapId] do
		if self.tbExistFishInfo[nMapId][i] == 0 then
			tbFreeIndex[nIndex] = i;	-- 记录空闲的位置
			nIndex = nIndex + 1;
		end
	end
	local tbRand = self:GetSmashTable(1, #tbFreeIndex);
	local nUpdateIndex1 = tbFreeIndex[tbRand[1]];
	self.tbExistFishInfo[nMapId][nUpdateIndex1] = nFishSort; -- 确定在新点刷的鱼的类型
	Timer:Register(self.DELAY_ADDFISH_TIME, self.AddFish, self, nMapId, nUpdateIndex1);
end

-- 指定位置添加指定索引的鱼
function WeekendFish:AddFish(nMapId, nUpdateIndex)
	if not self.tbExistFishInfo then
		print("not self.tbExistFishInfo");
		return 0;
	end
	if not self.tbExistFishInfo[nMapId] then
		return 0;
	end
	if not self.tbFishMapPos[nMapId] then
		return 0;
	end
	if self:CheckFishTime() ~= 1 then -- 过了钓鱼时间，不刷鱼了
		return 0;
	end
	local nFishSort = self.tbExistFishInfo[nMapId][nUpdateIndex];
	local tbFishPos = self.tbFishMapPos[nMapId][nUpdateIndex];
	if not nFishSort or not tbFishPos then
		return 0;
	end
	local nAreaId = self:GetAreaIdByFishId(nFishSort);
	if not nAreaId then
		return 0;
	end
	local pNpc = KNpc.Add2(self.NPC_FISH_ID[nAreaId], 100, -1, nMapId, tbFishPos[1], tbFishPos[2]);
	if pNpc then
		pNpc.GetTempTable("Npc").tbFishInfo= {};
		pNpc.GetTempTable("Npc").tbFishInfo.nExistIndex = nUpdateIndex;	-- 地图坐标的索引
		pNpc.GetTempTable("Npc").tbFishInfo.nSortIndex = nFishSort; -- 鱼的类型
	else
		Dbg:WriteLog("WeekendFish", "add fish failure");
	end
	return 0;
end

---------------兑奖 排行榜相关-------------------------
-- 检查物品是任务鱼
function WeekendFish:CheckIsFish(nGenre, nDetail, nParticular, nLevel)
	-- 连续的比较区间，如果出现不连续记得单独处理
	if nGenre == self.ITEM_FISH_ID[1][1] and nDetail == self.ITEM_FISH_ID[1][2] and nLevel == self.ITEM_FISH_ID[1][4] then
		if nParticular >= self.ITEM_FISH_ID[1][3] and nParticular <= self.ITEM_FISH_ID[25][3] then
			return 1;
		end
	end
	return 0;
end

-- 检查鱼的任务编号
function WeekendFish:GetFishTaskId(nGenre, nDetail, nParticular, nLevel)
	local tbTaskList = {};
	tbTaskList[1] = KGblTask.SCGetDbTaskInt(DBTASK_WEEKENDFISH_TASK_ID1);
	tbTaskList[2] = KGblTask.SCGetDbTaskInt(DBTASK_WEEKENDFISH_TASK_ID2);
	tbTaskList[3] = KGblTask.SCGetDbTaskInt(DBTASK_WEEKENDFISH_TASK_ID3);
	for i = 1, 3 do
		if self.ITEM_FISH_ID[tbTaskList[i]][1] == nGenre and self.ITEM_FISH_ID[tbTaskList[i]][2] == nDetail and self.ITEM_FISH_ID[tbTaskList[i]][3] == nParticular and self.ITEM_FISH_ID[tbTaskList[i]][4] == nLevel then
			return i;
		end
	end
	return 0;
end

-- 根据重量获取奖励
function WeekendFish:AddTaskFishRank(pPlayer, tbTaskFishWeight)
	local nWeek = tonumber(GetLocalDate("%W"));
	if nWeek ~= pPlayer.GetTask(self.TASK_GROUP, self.TASK_RANK_WEEK) then
		pPlayer.SetTask(self.TASK_GROUP, self.TASK_RANK_WEEK, nWeek);
		pPlayer.SetTask(self.TASK_GROUP, self.TASK_WEIGHT_FISH1, 0);
		pPlayer.SetTask(self.TASK_GROUP, self.TASK_WEIGHT_FISH2, 0);
		pPlayer.SetTask(self.TASK_GROUP, self.TASK_WEIGHT_FISH3, 0);
	end
	local nWeightFish1 = pPlayer.GetTask(self.TASK_GROUP, self.TASK_WEIGHT_FISH1) + tbTaskFishWeight[1];
	local nWeightFish2 = pPlayer.GetTask(self.TASK_GROUP, self.TASK_WEIGHT_FISH2) + tbTaskFishWeight[2];
	local nWeightFish3 = pPlayer.GetTask(self.TASK_GROUP, self.TASK_WEIGHT_FISH3) + tbTaskFishWeight[3];
	pPlayer.SetTask(self.TASK_GROUP, self.TASK_WEIGHT_FISH1, nWeightFish1);
	pPlayer.SetTask(self.TASK_GROUP, self.TASK_WEIGHT_FISH2, nWeightFish2);
	pPlayer.SetTask(self.TASK_GROUP, self.TASK_WEIGHT_FISH3, nWeightFish3);
	if nWeightFish1 > 0 then
		GCExcute{"WeekendFish:UpdateLuckFishRank_GC",1, pPlayer.szName, nWeightFish1};
	end
	if nWeightFish2 > 0 then
		GCExcute{"WeekendFish:UpdateLuckFishRank_GC",2, pPlayer.szName, nWeightFish2};
	end
	if nWeightFish3 > 0 then
		GCExcute{"WeekendFish:UpdateLuckFishRank_GC",3, pPlayer.szName, nWeightFish3};
	end
end

-- 检查是否可以查看排行榜
function WeekendFish:CheckViewLuckRank()
	if not self.nDataVer or self.nDataVer < 0 then
		return 0, "暂时还没有相关排行榜";
	end
	return 1;
end

-- 检查是否有领奖的资格
function WeekendFish:CheckCanAwardLuckRank(pPlayer, nType)
	if not self.nOpenLuckRankAward or self.nOpenLuckRankAward ~= 1 then
		return 0, "现在不在领奖时间哦，每周日23:32到下周五的23:32之间可以进行排行榜领奖。";
	end
	local nAwardFlag = self:CheckPlayerLuckAward(pPlayer.szName, nType);
	if nAwardFlag < 0 then
		return 0, "你已经领取了本轮奖励";
	end
	if nAwardFlag == 0 then
		return 0, "很遗憾你没有进入前5";
	end
	return nAwardFlag;
end

function WeekendFish:GetLuckFishAward(nPlayerId, nType)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local nRes, szMsg = self:CheckCanAwardLuckRank(pPlayer, nType);
	if nRes <= 0 then
		Dialog:Say(szMsg);
		return 0;
	end
	if pPlayer.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ chỗ trống!");
		return 0;
	end
	local nRet = GCExcute{"WeekendFish:GetLuckFishAward_GC", nPlayerId, nType};
	if nRet == 1 then
		pPlayer.AddWaitGetItemNum(1);-- 领东西的时候先锁定，防止跨服重复领取
	end
end

-- gc领奖回调
function WeekendFish:GetLuckFishAward_GS2(nFlag, nPlayerId, nType, nRank, nTBType)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if nFlag ~= 1 then
		if pPlayer then
			pPlayer.AddWaitGetItemNum(-1);
			pPlayer.Msg("领取失败！");
			Dialog:SendBlackBoardMsg(pPlayer, "领奖失败！");
		end
	else
		if (nTBType == 1) then
			self.tbLuckFishRank[nType][nRank][4] = 1;
			local nAwardLevel = self:GetAwardLevelByLuckFishRank(nRank);
			if pPlayer and nAwardLevel > 0 then
				local pItem = pPlayer.AddItem(unpack(self.ITEM_LUCKRANK_BAG[nAwardLevel]));
				if pItem then
					if nRank <= 5 then
						Achievement:FinishAchievement(pPlayer, 391);
					end
					if nRank == 1 then
						Achievement:FinishAchievement(pPlayer, 392)
					end
					pPlayer.Msg("恭喜你，领奖成功。");
					Dialog:SendBlackBoardMsg(pPlayer, "恭喜你，领奖成功。");
					Dbg:WriteLog("WeekendFish", "luckFishAward", pPlayer.szName, nAwardLevel);
				end
				pPlayer.AddWaitGetItemNum(-1);
			end
		elseif (nTBType == 2) then
			if (not self.tbLuckFishRank_Ex) then
				return 0;
			end
			
			if (not self.tbLuckFishRank_Ex[nType]) then
				return 0;
			end

			if (not self.tbLuckFishRank_Ex[nType][nRank]) then
				return 0;
			end

			if (self.tbLuckFishRank_Ex[nType][nRank][4] == 1) then
				return 0;
			end

			self.tbLuckFishRank_Ex[nType][nRank][4] = 1;
			local nAwardLevel = self:GetAwardLevelByLuckFishRank(nRank);
			if pPlayer and nAwardLevel > 0 then
				local pItem = pPlayer.AddItem(unpack(self.ITEM_LUCKRANK_BAG[nAwardLevel]));
				if pItem then
					if nRank <= 5 then
						Achievement:FinishAchievement(pPlayer, 391);
					end
					if nRank == 1 then
						Achievement:FinishAchievement(pPlayer, 392)
					end
					pPlayer.Msg("恭喜你，领奖成功。");
					Dialog:SendBlackBoardMsg(pPlayer, "恭喜你，领奖成功。");
					Dbg:WriteLog("WeekendFish", "luckFishAward", pPlayer.szName, nAwardLevel);
				end
				pPlayer.AddWaitGetItemNum(-1);
			end
		end
	end
end

function WeekendFish:ShowAwardDialog()
	local nFreeCount, tbFunExecute = SpecialEvent.ExtendAward:DoCheck("WeeklyFish") 
	if me.CountFreeBagCell() < 1 +nFreeCount then
		Dialog:Say(string.format("您背包空间不足。清理%s格空余背包", 1 + nFreeCount));
		return 0;
	end
	local tbGeneralAward = {};  -- 最后传到奖励面版脚本的数据结构
	local szAwardTalk	= '   西塞山前白鹭飞，桃花流水鳜鱼肥，青箬笠，绿蓑衣，斜风细雨不须归。这鱼肥水美的季节，正是钓鱼的好时节。感谢你帮助了我，这便是我能给你的回报。\n   你聪明智慧过我十倍，将来钓鱼的成绩定然远胜于我，这是不消说的。只盼你心头牢牢记着“钓鱼是一种快乐和一种精神”。\n   这是给予你的奖励，请务必再接再厉！\n';	-- 奖励时说的话
	local nExp = math.floor(me.GetBaseAwardExp() * WeekendFish.BASEEXP_NUM);
	tbGeneralAward.tbFix = {};
	tbGeneralAward.tbOpt = {};
	tbGeneralAward.tbRandom = {};
	table.insert(tbGeneralAward.tbFix,
					{
						szType="item", 
						varValue={self.ITEM_RECOMMENDATION[1],self.ITEM_RECOMMENDATION[2],self.ITEM_RECOMMENDATION[3],self.ITEM_RECOMMENDATION[4]}, 
						nSprIdx=0,
						szDesc="水产证书", 
						szAddParam1=1
					}
				);
	table.insert(tbGeneralAward.tbFix,
					{
						szType="exp", 
						varValue=nExp, 
						nSprIdx=0,
						szDesc="经验" .. nExp, 
					}
				);
	GeneralAward:SendAskAward(szAwardTalk, 
							  tbGeneralAward, {"WeekendFish:AwardFinish"} );	
end
-- 领奖回调
function WeekendFish:AwardFinish()
	Task:CloseTask(WeekendFish.TASK_MAIN_ID, "finish");
	local nDay = Lib:GetLocalDay(GetTime());
	if nDay ~= me.GetTask(WeekendFish.TASK_GROUP, WeekendFish.TASK_ACCEPT_DAY) then--理论上不可能不相等
		Dbg:WriteLog("WeekendFish", "领奖界面跨天", me.szName);
		nDay = me.GetTask(WeekendFish.TASK_GROUP, WeekendFish.TASK_ACCEPT_DAY);
	end
	me.SetTask(WeekendFish.TASK_GROUP, WeekendFish.TASK_AWARD_DAY, nDay);
	local nWeek = tonumber(GetLocalDate("%W"));
	local nTaskWeek = me.GetTask(WeekendFish.TASK_GROUP, WeekendFish.TASK_ACHIEVEBUF_WEEK);
	local nWeekDay = tonumber(GetLocalDate("%w"));
	local nDate = tonumber(GetLocalDate("%m%d"));
	if nWeek ~= nTaskWeek and not (nWeekDay == 0 and nDate == 101) then
		me.SetTask(WeekendFish.TASK_GROUP, WeekendFish.TASK_ACHIEVEBUF_WEEK, nWeek);
		me.SetTask(WeekendFish.TASK_GROUP, WeekendFish.TASK_ACHEIVEBUF_NUM, 0);
	end
	local nTimes = me.GetTask(WeekendFish.TASK_GROUP, WeekendFish.TASK_ACHEIVEBUF_NUM);
	me.SetTask(WeekendFish.TASK_GROUP, WeekendFish.TASK_ACHEIVEBUF_NUM, nTimes + 1);
	local nFreeCount, tbFunExecute = SpecialEvent.ExtendAward:DoCheck("WeeklyFish");
	SpecialEvent.ExtendAward:DoExecute(tbFunExecute);
	Achievement:FinishAchievement(me, 387);
	local nFirstFishTime = me.GetTask(self.TASK_GROUP, self.TASK_FIRSTFISH_TIME);
	StatLog:WriteStatLog("stat_info", "fishing", "task_comp", me.nId, 1, GetTime()-nFirstFishTime);
	
	SpecialEvent.ActiveGift:AddCounts(me, 17);		--钓鱼完成活跃度
	SpecialEvent.BuyOver:AddCounts(me, SpecialEvent.BuyOver.TASK_CAUCA);
end

-- 领奖开关
function WeekendFish:UpdateLunckRankAward_GS2(nOpen)
	self.nOpenLuckRankAward = nOpen;
end

function WeekendFish:StartEvent_GS()
	self:LoadLuckFishRank();
end

function WeekendFish:PlayerLoginEvent()
	self:CheckTaskIsOverdue(me);
	self:MergeServer();
end

-- 合服处理
function WeekendFish:MergeServer()
	if self:CheckOpen() ~= 1 then
		return;
	end
	-- 判断是否是活动期间，不是活动期间不用处理
	if self:CheckMergeServerTime() ~= 1 then
		return;
	end
	-- 是否有任务，有任务重新设置一下鱼的类别，对应到主服的幸运鱼
	if Task:GetPlayerTask(me).tbTasks[self.TASK_MAIN_ID] then
		local tbTaskList = {};
		tbTaskList[1] = KGblTask.SCGetDbTaskInt(DBTASK_WEEKENDFISH_TASK_ID1);
		tbTaskList[2] = KGblTask.SCGetDbTaskInt(DBTASK_WEEKENDFISH_TASK_ID2);
		tbTaskList[3] = KGblTask.SCGetDbTaskInt(DBTASK_WEEKENDFISH_TASK_ID3);
		local nFlag = 0;
		for i = 1, 3 do
			if me.GetTask(self.TASK_GROUP, self.TASK_FISH_ID1 + i - 1) ~= tbTaskList[i] then
				nFlag = 1;
				break;
			end
		end
		if nFlag == 1 then
			me.SetTask(WeekendFish.TASK_GROUP, WeekendFish.TASK_TEAM_IDGROUP, 0); -- 清空一下组队的任务变量
			local tbRandTaskList = self:RandPlayerFishList();
			for i = 1, 5 do
				me.SetTask(self.TASK_GROUP, self.TASK_FISH_ID1 + i - 1, tbRandTaskList[i]);
			end
			me.Msg("您的钓鱼任务，钓鱼类型已经修改，请重新登录。");
		end
		
	end
end


-- 注册启动事件
ServerEvent:RegisterServerStartFunc(WeekendFish.StartEvent_GS, WeekendFish);

PlayerEvent:RegisterOnLoginEvent(WeekendFish.PlayerLoginEvent, WeekendFish);