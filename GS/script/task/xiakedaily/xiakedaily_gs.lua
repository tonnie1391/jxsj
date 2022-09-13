-- 文件名　：xiakedaily_gs.lua
-- 创建者　：huangxiaoming
-- 创建时间：2011-03-15 12:10:10
-- 描  述  ：

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\task\\xiakedaily\\xiakedaily_def.lua")


function XiakeDaily:GetTaskValue()
	local nTaskDay = KGblTask.SCGetDbTaskInt(DBTASK_XIAKEDAILY_TASK_DAY);
	local nTask1 = KGblTask.SCGetDbTaskInt(DBTASK_XIAKEDAILY_TASK_ID1);
	local nTask2 = KGblTask.SCGetDbTaskInt(DBTASK_XIAKEDAILY_TASK_ID2);
	return nTaskDay, nTask1, nTask2;
end

function XiakeDaily:SetWeekTimes()
	local nTaskWeek = self:GetTask(self.TASK_WEEK);
	local nTaskDay = self:GetTask(self.TASK_ACCEPT_DAY);
	local nSec = Lib:GetDate2Time(nTaskDay);
	local nWeek = Lib:GetLocalWeek(nSec);
	
	if nTaskWeek ~= nWeek then
		self:SetTask(self.TASK_WEEK, nWeek);
		self:SetTask(self.TASK_WEEK_COUNT, 1);
	else
		self:SetTask(self.TASK_WEEK_COUNT, self:GetTask(self.TASK_WEEK_COUNT)+1);
	end
end

-- 获取本周完成次数
function XiakeDaily:GetWeekTimes()
	local nTaskWeek = self:GetTask(self.TASK_WEEK);
	local nTaskDay = KGblTask.SCGetDbTaskInt(DBTASK_XIAKEDAILY_TASK_DAY);
	local nSec = Lib:GetDate2Time(nTaskDay);
	local nWeek = Lib:GetLocalWeek(nSec);
	if nWeek ~= nTaskWeek then
		self:SetTask(self.TASK_WEEK, nWeek);
		self:SetTask(self.TASK_WEEK_COUNT, 0);
	end
	local nWeekTimes = self:GetTask(self.TASK_WEEK_COUNT);
	return nWeekTimes;
end

-- 获取今日剩余接取次数
function XiakeDaily:GetDayAcceptTimes()
	return self:GetTask(self.TASK_ACCEPT_COUNT);
end

function XiakeDaily:ShowAwardDialog()
	local tbGeneralAward = {};  -- 最后传到奖励面版脚本的数据结构
	local szAwardTalk	= "   Đây là phần thưởng dành cho ngươi, nhưng hãy nhớ, con đường giang hồ, không bao giờ dừng lại sự cố gắng!\n";	-- 奖励时说的话
	local nNum = self.AWARD_ONCE;
	local nStone = 0;
	local nStoneKey = 0;
	local nFreeCount = 1;
	if self:GetWeekTimes() + 1 == self.AWARDEX_WEEK_TIMES then
		nNum = nNum + self.AWARD_EXTRA;
		if Item.tbStone:GetOpenDay() ~= 0 then
			nStone = self.AWARD_STONE;
			nStoneKey = self.AWARD_STONE_KEY;
			nFreeCount = 1 + 1 + nStoneKey;
			szAwardTalk = szAwardTalk .. string.format("\n Khi hoàn thành trong tuần này <color=yellow>%s<color> lần, sẽ nhận thêm <color=yellow>%s<color> Hiệp khách lệnh", self.AWARDEX_WEEK_TIMES, self.AWARD_EXTRA);
			szAwardTalk = szAwardTalk .. string.format("\n<color=yellow>%s<color> Bảo Thạch <color=yellow>%s<color> Giải Ngọc Chùy", self.AWARD_STONE, self.AWARD_STONE_KEY);
		else
			nFreeCount = 1;
			szAwardTalk = szAwardTalk .. string.format("\n Khi hoàn thành trong tuần này <color=yellow>%s<color> lần, sẽ nhận thêm <color=yellow>%s<color> Hiệp khách lệnh", self.AWARDEX_WEEK_TIMES, self.AWARD_EXTRA);
		end
	end
	
	tbGeneralAward.tbFix = {};
	tbGeneralAward.tbOpt = {};
	tbGeneralAward.tbRandom = {};
	local nFreeCountEx, tbFunExecute = SpecialEvent.ExtendAward:DoCheck("XiaKeDaily", me, self:GetWeekTimes()); 
	if me.CountFreeBagCell() < nFreeCount + nFreeCountEx then
		Dialog:Say(string.format("Hành trang không đủ %s ô trống.", nFreeCount + nFreeCountEx));
		return 1;
	end
	if nNum > 0 then
		table.insert(tbGeneralAward.tbFix,
					{
						szType="item", 
						varValue={self.ITEM_XIAKELING[1],self.ITEM_XIAKELING[2],self.ITEM_XIAKELING[3],self.ITEM_XIAKELING[4]}, 
						nSprIdx="",
						szDesc="Hiệp khách lệnh", 
						szAddParam1=nNum
					}
				);
	end
	if nStone > 0 then
		table.insert(tbGeneralAward.tbFix,
					{
						szType="item", 
						varValue={self.ITEM_STONE[1],self.ITEM_STONE[2],self.ITEM_STONE[3],self.ITEM_STONE[4]}, 
						nSprIdx="",
						szDesc="Bảo Thạch", 
						szAddParam1=nStone
					}
				);
	end
	if (nStoneKey > 0) then
		table.insert(tbGeneralAward.tbFix,
					{
						szType="item", 
						varValue={self.ITEM_STONE_KEY[1],self.ITEM_STONE_KEY[2],self.ITEM_STONE_KEY[3],self.ITEM_STONE_KEY[4],
									0,0,0,0,0,0,1}, 
						nSprIdx="",
						szDesc="Giải Ngọc Chùy", 
						szAddParam1=nStoneKey
					}
				);
	end
	local nTask1 = self:GetTask(self.TASK_TARGET1_ID);
	local nTask2 = self:GetTask(self.TASK_TARGET2_ID);
	local nTaskLogId = nTask1 + nTask2 * 100;
	GeneralAward:SendAskAward(szAwardTalk, 
							  tbGeneralAward, {"XiakeDaily:AwardFinish", nTaskLogId, nNum, me.nId, me.GetHonorLevel()} );
end

function XiakeDaily:AwardFinish(nTaskLogId, nNum, nPlayerId, nHonorLevel)
	-- 领奖回调不判断是否过期，防止刷周次数奖励，否则有可能玩家得到奖励但没有设置周次数
	--if XiakeDaily:Check_Task() ~= 1 then
	--	return 0;
	--end
	Task:CloseTask(XiakeDaily.TASK_MAIN_ID, "finish");
	if self:GetTask(self.TASK_ACCEPT_COUNT) > 0 then
		self:SetTask(self.TASK_STATE, 0);
	else
		self:SetTask(self.TASK_STATE, 2);
	end
	me.AddKinReputeEntry(self.PRESTIGE_REPUTE, "xiakedaily")
	local nFreeCountEx, tbFunExecute = SpecialEvent.ExtendAward:DoCheck("XiaKeDaily", me, self:GetWeekTimes()); 
	SpecialEvent.ExtendAward:DoExecute(tbFunExecute)
	Achievement:FinishAchievement(me, 374);
	Achievement:FinishAchievement(me, 375);
	Achievement:FinishAchievement(me, 376);
	
	SpecialEvent.ActiveGift:AddCounts(me, 29);		--完成侠客活跃度
	
	StatLog:WriteStatLog("stat_info", "richangrenwu", "complete", nPlayerId, nHonorLevel, nTaskLogId, nNum);
	if (Item.tbStone:GetOpenDay() ~= 0) then
		if (self:GetWeekTimes() == self.AWARDEX_WEEK_TIMES) then
			-- zjq 这里可以记录日志，如果奖励固定的话
			StatLog:WriteStatLog("stat_info", "baoshixiangqian", "xiake", me.nId, string.format("%d_%d_%d_%d,%d,%d_%d_%d_%d,%d", 
								self.ITEM_STONE[1], self.ITEM_STONE[2], self.ITEM_STONE[3], self.ITEM_STONE[4], self.AWARD_STONE,
								self.ITEM_STONE_KEY[1], self.ITEM_STONE_KEY[2], self.ITEM_STONE_KEY[3], self.ITEM_STONE_KEY[4], self.AWARD_STONE_KEY));
		end
	end
end

function XiakeDaily:CheckTaskFinish()
	XiakeDaily:PredictAccept();
	local nFlag = XiakeDaily:GetTask(XiakeDaily.TASK_STATE);
	if nFlag == 1 and XiakeDaily:GetTask(XiakeDaily.TASK_FIRST_TARGET) == 1 and XiakeDaily:GetTask(XiakeDaily.TASK_SECOND_TARGET) == 1 then
		return 1;
	end
	return 0;
end

-- 预判断任务是否可接
function XiakeDaily:PredictAccept()
	if self:CheckTaskExpire() == 1 then
		self:CancelTask();
	end
	return 1;
end

-- 检查身上任务是否过期
function XiakeDaily:CheckTaskExpire()
	local nAcceptedDay = self:GetTask(self.TASK_ACCEPT_DAY);
	local nTaskDay = KGblTask.SCGetDbTaskInt(DBTASK_XIAKEDAILY_TASK_DAY);
	if nAcceptedDay < nTaskDay then
		return 1;
	end
	return 0;
end

-- 检查玩家身上是否有指定任务未完成
function XiakeDaily:CheckHasTask(pPlayer, nType, nDetail)
	if pPlayer.nLevel < XiakeDaily.LEVEL_LIMIT then
		return 0;
	end
	if self:CheckOpen() ~= 1 then
		return 0;
	end
	Setting:SetGlobalObj(pPlayer);
	XiakeDaily:PredictAccept();
	if self:GetTask(self.TASK_STATE) ~= 1 then 
		Setting:RestoreGlobalObj();
		return 0;
	end
	local nIndex = self.DETAIL_TO_INDEX[nType][nDetail];
	if not nIndex then
		Setting:RestoreGlobalObj();
		return 0;
	end
	local nCheckTask = self.TYPE_FUBENID[nType][nIndex];
	local nTask1 = KGblTask.SCGetDbTaskInt(DBTASK_XIAKEDAILY_TASK_ID1);
	local nTask2 = KGblTask.SCGetDbTaskInt(DBTASK_XIAKEDAILY_TASK_ID2);
	if nCheckTask == nTask1 then
		if self:GetTask(self.TASK_FIRST_TARGET) == 0 and self:GetTask(self.TASK_TARGET1_ID) == nCheckTask then
			Setting:RestoreGlobalObj();
			return 1;	-- 有该任务且未完成
		end
	elseif nCheckTask == nTask2 then
		if self:GetTask(self.TASK_SECOND_TARGET) == 0 and self:GetTask(self.TASK_TARGET2_ID) == nCheckTask then
			Setting:RestoreGlobalObj();
			return 1;
		end
	end
	Setting:RestoreGlobalObj();
	return 0;
end

function XiakeDaily:CancelTask()
	if Task:GetPlayerTask(me).tbTasks[self.TASK_MAIN_ID] then
		me.Msg("Thật không may, nhiệm vụ Hiệp khách của bạn đã thất bại do quá hạn hoàn thành.");
		Task:CloseTask(self.TASK_MAIN_ID, "giveup");
	end
	local nAcceptedDay = self:GetTask(self.TASK_ACCEPT_DAY);
	local nTaskDay = KGblTask.SCGetDbTaskInt(DBTASK_XIAKEDAILY_TASK_DAY);
	if nTaskDay > nAcceptedDay then -- 取消的是昨日任务则设置为可接今日任务
		self:SetTask(self.TASK_STATE, 0);
		self:SetTask(self.TASK_ACCEPT_COUNT, self.DAY_ACCEPT_TIMES);
	end
end

-- 任务统一接口
-- 参数1是活动的大类，参数2是小类，逍遥是难度，军营是具体小类，副本是副本类型加难度（比如12代表大漠古城2星）
function XiakeDaily:AchieveTask(pPlayer, nType, nDetail)
	if pPlayer.nLevel < XiakeDaily.LEVEL_LIMIT then
		return 0;
	end
	if self:CheckOpen() ~= 1 then
		return 0;
	end
	Setting:SetGlobalObj(pPlayer);
	XiakeDaily:PredictAccept();
	if self:GetTask(self.TASK_STATE) ~= 1 then
		Setting:RestoreGlobalObj();
		return 0;
	end
	
	local nIndex = self.DETAIL_TO_INDEX[nType][nDetail];
	if not nIndex then
		Setting:RestoreGlobalObj()
		return 0;
	end
	local nAchieveTask = self.TYPE_FUBENID[nType][nIndex];
	local nTask1 = KGblTask.SCGetDbTaskInt(DBTASK_XIAKEDAILY_TASK_ID1);
	local nTask2 = KGblTask.SCGetDbTaskInt(DBTASK_XIAKEDAILY_TASK_ID2);
	if nAchieveTask == nTask1 then
		if self:GetTask(self.TASK_FIRST_TARGET) == 0 and self:GetTask(self.TASK_TARGET1_ID) == nAchieveTask then
			self:SetTask(self.TASK_FIRST_TARGET, 1);
		end
	elseif nAchieveTask == nTask2 then
		if self:GetTask(self.TASK_SECOND_TARGET) == 0 and self:GetTask(self.TASK_TARGET2_ID) == nAchieveTask then
			self:SetTask(self.TASK_SECOND_TARGET, 1);
		end
	end
	if self:GetTask(self.TASK_FIRST_TARGET) == 1 and self:GetTask(self.TASK_SECOND_TARGET) == 1 then
		Dialog:SendBlackBoardMsg(pPlayer, "Đã hoàn thành nhiệm vụ hiệp khách, mau đi nhận thưởng!");
	end
	Setting:RestoreGlobalObj()
end


function XiakeDaily:CheckOpen()
	if self._OPEN ~= 1 then
		return 0;
	end
	if TimeFrame:GetState("XiakeDaily") == 1 then
		return 1;
	end
	return 0;
end

function XiakeDaily:Login_Check()
	if me.nLevel < self.LEVEL_LIMIT then
		return;
	end
	self:PredictAccept();
	self:MergeServer();
end

-- 合服处理
function XiakeDaily:MergeServer()
	if self:GetTask(self.TASK_STATE) == 1 then	-- 只有身上已经接了任务才处理
		local nTask1 = KGblTask.SCGetDbTaskInt(DBTASK_XIAKEDAILY_TASK_ID1);
		local nTask2 = KGblTask.SCGetDbTaskInt(DBTASK_XIAKEDAILY_TASK_ID2);
		local nSelfTask1 = self:GetTask(self.TASK_TARGET1_ID);
		local nSelfTask2 = self:GetTask(self.TASK_TARGET2_ID);
		if (nTask1 == nSelfTask1 and nTask2 == nSelfTask2) or (nTask1 == nSelfTask2 and nTask2 == nSelfTask1) then
			return 1;
		end
		if Task:GetPlayerTask(me).tbTasks[self.TASK_MAIN_ID] then
			Task:CloseTask(self.TASK_MAIN_ID, "giveup");
		end
		local nAcceptedDay = self:GetTask(self.TASK_ACCEPT_DAY);
		local nTaskDay = KGblTask.SCGetDbTaskInt(DBTASK_XIAKEDAILY_TASK_DAY);
		if nTaskDay <= nAcceptedDay then -- 和服重新处理次数
			self:SetTask(self.TASK_ACCEPT_DAY, nTaskDay)
			self:SetTask(self.TASK_STATE, 0);
			self:SetTask(self.TASK_ACCEPT_COUNT, self:GetTask(self.TASK_ACCEPT_COUNT) + 1); -- 加回一次
		end
	end
end

PlayerEvent:RegisterOnLoginEvent(XiakeDaily.Login_Check, XiakeDaily);