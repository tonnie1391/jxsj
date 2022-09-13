--官府通缉任务
--孙多良
--2008.08.05
Require("\\script\\task\\wanted\\wanted_def.lua");

--测试使用,完成任务
function Wanted:_Test_FinishTask()
	if Task:GetPlayerTask(me).tbTasks[Wanted.TASK_MAIN_ID] then
		for _, tbCurTag in ipairs(Task:GetPlayerTask(me).tbTasks[Wanted.TASK_MAIN_ID].tbCurTags) do
			if (tbCurTag.OnKillNpc) then
				if (tbCurTag:IsDone()) then
					--杀死Boss玩家的队友身上有任务完成时调用	
					if me.GetTask(Wanted.TASK_GROUP, Wanted.TASK_FINISH) == 1 then
						me.SetTask(Wanted.TASK_GROUP, Wanted.TASK_FINISH, 0);
					end
					break;
				end;
				tbCurTag.nCount	= tbCurTag.nCount + 1;		
				local tbSaveTask	= tbCurTag.tbSaveTask;
				if (MODULE_GAMESERVER and tbSaveTask) then	-- 自行同步到客户端，要求客户端刷新
					tbCurTag.me.SetTask(tbSaveTask.nGroupId, tbSaveTask.nStartTaskId, tbCurTag.nCount, 1);
					KTask.SendRefresh(tbCurTag.me, tbCurTag.tbTask.nTaskId, tbCurTag.tbTask.nReferId, tbSaveTask.nGroupId);
				end;
								
				if (tbCurTag:IsDone()) then	-- 本目标是一旦达成后不会失效的
					tbCurTag.me.Msg("Mục tiêu: "..tbCurTag:GetStaticDesc());
					tbCurTag.tbTask:OnFinishOneTag();
				end;
				
				--杀死Boss玩家的队友身上有任务完成时调用				
				if me.GetTask(Wanted.TASK_GROUP, Wanted.TASK_FINISH) == 1 then
					me.SetTask(Wanted.TASK_GROUP, Wanted.TASK_FINISH, 0);
				end
			end
		end;
	end
end

function Wanted:GetLevelGroup(nLevel)
	if nLevel < self.LIMIT_LEVEL then
		return 0;
	end
	local nMax = 0;
	for ni, nLevelSeg in ipairs(self.LevelGroup) do
		if nLevel <= nLevelSeg then
			return ni;
		end
		nMax = ni;
	end
	return nMax;
end

function Wanted:GetTask(nTaskId)
	return me.GetTask(self.TASK_GROUP, nTaskId);
end

function Wanted:SetTask(nTaskId, nValue)
	return me.DirectSetTask(self.TASK_GROUP, nTaskId, nValue);
end

function Wanted:Check_Task()
	if me.nLevel < self.LIMIT_LEVEL then
		return 3;
	end
	if self:GetTask(self.TASK_FIRST) == 0 then
		if self:GetTask(self.TASK_COUNT) == 0 then
			self:SetTask(self.TASK_COUNT, self.Day_COUNT);
		end
		self:SetTask(self.TASK_FIRST, 1);
	end
	--if self:GetTask(self.TASK_ACCEPT_ID) <= 0 then
	--	return 0;
	--end
	local tbTask = Task:GetPlayerTask(me).tbTasks[self.TASK_MAIN_ID];
	if not tbTask then
		--self:SetTask(self.TASK_ACCEPT_ID, 0);
		return 0;	--未接任务
	end
	
	if self:CheckTaskFinish() == 1 then
		return 1;	--已完成
	else
		return 2;	--未完成
	end
	return 0;
end

function Wanted:CheckLimitTask()
	local nCurTime = tonumber(GetLocalDate("%H%M"));
	if (EventManager.IVER_bOpenWantedLimitTime == 1) then
		local szNoOpenMsg = string.format("Bổ Đầu Hình Bộ: Nha môn đang đóng cửa nghỉ ngơi. Hãy quay lại vào khung giờ Nha môn mở cửa.\n\nThời gian mở cửa: %s\nThời gian đóng cửa: %s", Lib:HourMinNumber2TimeDesc(self.DEF_DATE_START), Lib:HourMinNumber2TimeDesc(self.DEF_DATE_END));
		if self.DEF_DATE_START > self.DEF_DATE_END then
			if nCurTime < self.DEF_DATE_START and nCurTime > self.DEF_DATE_END then 
				Dialog:Say(szNoOpenMsg);
				return 0;
			end
		else
			if nCurTime < self.DEF_DATE_START or nCurTime > self.DEF_DATE_END then
				Dialog:Say(szNoOpenMsg);
				return 0;
			end
		end
	end
	
	--if me.GetTask(1022,107) ~= 1 then
	--	Dialog:Say("Bổ Đầu Hình Bộ: 大侠，您必须完成50级主线任务,这样才能证明您具有能力参加缉捕任务。");
	--	return 0;
	--end
	
	--江湖威望判断
	if (me.nPrestige < self.LIMIT_REPUTE) then
		local szFailDesc = "Uy danh giang hồ chưa đạt 20, không thể nhận nhiệm vụ.";
		Dialog:Say(szFailDesc);
		return 0;
	end
	
	local nType = self:GetLevelGroup(me.nLevel);
	if nType <= 0 then
		Dialog:Say("Bổ Đầu Hình Bộ: Đại hiệp, hãy tìm hắn ta ở các nơi hắn hay đến. ");
		return 0;
	end
	if self:GetTask(self.TASK_COUNT) <= 0 then
		Dialog:Say("Bổ Đầu Hình Bộ: Đã hết số lần nhiệm vụ trong ngày, vui lòng quay lại vào ngày mai.")
		return 0;
	end
	return 1;	
end

-- 检测任务除了交物品任务之外还有没有未完成的目标
function Wanted:CheckTaskFinish()
	local tbTask	 	= Task:GetPlayerTask(me).tbTasks[self.TASK_MAIN_ID];
	
	-- 还有未完成的目标
	for _, tbCurTag in pairs(tbTask.tbCurTags) do
		if (not tbCurTag:IsDone()) then
			return 0;
		end;
	end;
	
	-- 全部目标完成
	return 1;
end;

function Wanted:SingleAcceptTask()
	if me.GetTiredDegree1() == 2 then
		Dialog:Say("Bạn mệt mỏi rồi!");
		return;
	end
	if self:Check_Task() ~= 0 then
		return 0;
	end
	if self:CheckLimitTask() ~= 1 then
		return 0;
	end
	local nType = self:GetLevelGroup(me.nLevel);
	local tbOpt = {};
	for i=1, nType do 
		if self.DEF_Adv_LEVEL[i] then
		--如果是高级大盗需按时间轴
			if TimeFrame:GetState("OpenAdvWanted") == 1 then
				table.insert(tbOpt, {string.format("%s",self.LevelGroupName[i]), self.GetRandomTask, self, i});
			end
		else
			table.insert(tbOpt, {string.format("%s",self.LevelGroupName[i]), self.GetRandomTask, self, i});
		end
	end
	table.insert(tbOpt, {"Để ta suy nghĩ lại"});
	Dialog:Say("Bạn có thể nhận các nhiệm vụ sau đây, nhiệm vụ cấp càng cao càng khó.\n\n<color=yellow>Nhiệm vụ chỉ có thể hoàn thành trong ngày.<color>", tbOpt);
end

function Wanted:GetRandomTask(nLevelSeg)
	if self:CheckLimitTask() ~= 1 then
		return 0;
	end	
	--初级大盗
	if nLevelSeg <= 5 then	
		if self.TaskLevelSeg[nLevelSeg] then
		local nTaskCount = self:GetCurNeedTaskCount(nLevelSeg);
			local nP = MathRandom(1, nTaskCount);
			local nTaskId = self.TaskLevelSeg[nLevelSeg][nP];
			self:AcceptTask(nTaskId, nLevelSeg);
			return nTaskId;
		end
		return 0;
	end
	
	--高级大盗特殊处理
	local nPlayerActionKind = Player:GetActionKind(me.szName);
	local nActionKind = Wanted.ACTION_KIND[nPlayerActionKind] or 0;
	if self.TaskLevelSegActionKind[nLevelSeg] and
		self.TaskLevelSegActionKind[nLevelSeg][nActionKind] then
		--local nTaskCount = self:GetCurNeedTaskCount(nLevelSeg, #self.TaskLevelSegActionKind[nLevelSeg][nActionKind]);
		local nTaskCount = self.DEF_ACTION_KIND[nActionKind];
		if nTaskCount > #self.TaskLevelSegActionKind[nLevelSeg][nActionKind] then
			nTaskCount = #self.TaskLevelSegActionKind[nLevelSeg][nActionKind];
		end
		local nP = MathRandom(1, nTaskCount);
		local nTaskId = self.TaskLevelSegActionKind[nLevelSeg][nActionKind][nP];
		if not nTaskId then
			return 0;
		end
		self:AcceptTask(nTaskId, nLevelSeg);
		return nTaskId;
	end
end

function Wanted:GetCurNeedTaskCount(nLevelSeg)
	-- 根据服务器情况减少任务数量，增加争夺点
	-- 跟进上周人数获得可接任务数
	local nWeekTask = Wanted:GetNeedTaskCountByLastWeek(nLevelSeg);
	local nTimeTask = Wanted:GetNeedTaskCountByTimeFrame(nLevelSeg);
	local nTaskCount = nWeekTask;
	if nTimeTask < nTaskCount then
		nTaskCount = nTimeTask;
	end
	if nTaskCount > #self.TaskLevelSeg[nLevelSeg] then
		nTaskCount = #self.TaskLevelSeg[nLevelSeg];
	end
	if nTaskCount < 1 then
		nTaskCount = 1;
	end
	
	if nLevelSeg < 6 and EventManager.IVER_bOpenWantedLimit == 1  then
		nTaskCount = #self.TaskLevelSeg[nLevelSeg];
	end
	
	return nTaskCount
end

function Wanted:GetNeedTaskCountByLastWeek(nLevelSeg)
	local nLastWeekCount = KGblTask.SCGetDbTaskInt(self.DEF_SAVE_TASK[nLevelSeg][2]);
	local nFlag = -1;
	local nTaskCount = 0;
	if nLastWeekCount <= 0 then
		-- 第一次取最大值
		for _, tbParam in pairs(self.TaskWeekSeg[nLevelSeg]) do
			if nTaskCount < tbParam.nTaskCount then
				nTaskCount = tbParam.nTaskCount;
			end
		end
		return nTaskCount;
	end

	for _, tbParam in pairs(self.TaskWeekSeg[nLevelSeg]) do
		if nFlag < tbParam.nLastWeekSum and nLastWeekCount >= tbParam.nLastWeekSum then
			nTaskCount = tbParam.nTaskCount;
			nFlag = tbParam.nLastWeekSum;
		end
	end
	return nTaskCount;
end

function Wanted:GetNeedTaskCountByTimeFrame(nLevelSeg)
	local nCurOpenServerDay = TimeFrame:GetServerOpenDay();
	local nFlag = -1;
	local nTaskCount = 0;
	for _, tbParam in pairs(self.TaskTimeSeg[nLevelSeg]) do
		if nFlag < tbParam.nTimeDay and nCurOpenServerDay >= tbParam.nTimeDay then
			nTaskCount = tbParam.nTaskCount;
			nFlag = tbParam.nTimeDay;
		end
	end
	return nTaskCount;	
end

function Wanted:AcceptTask(nTaskId, nLevelSeg)
	if self:Check_Task() ~= 0 then
		return 0;
	end
	if self:CheckLimitTask() ~= 1 then
		return 0;
	end
	Task:DoAccept(self.TASK_MAIN_ID, nTaskId);
	self:SetTask(self.TASK_ACCEPT_ID, nTaskId);
	self:SetTask(self.TASK_LEVELSEG, nLevelSeg);
	self:SetTask(self.TASK_FINISH, 1);
	self:SetTask(self.TASK_COUNT, self:GetTask(self.TASK_COUNT) -1);
	self:SetTask(self.TASK_ACCEPT_TIME, GetTime());
	local nRLevel = self:GetTask(self.TASK_100SEG_RANLEVEL);
	if nRLevel == 0 then
		local nRLevel = MathRandom(1,5);
		self:SetTask(self.TASK_100SEG_RANLEVEL, nRLevel);
	end
	-- 记录参加次数
	local nNum = me.GetTask(StatLog.StatTaskGroupId , 4) + 1;
	me.SetTask(StatLog.StatTaskGroupId , 4, nNum);
	
	-- 记录玩家参加官府通缉的次数
	Stats.Activity:AddCount(me, Stats.TASK_COUNT_WANTED, 1);
	
	--接任务log
	DataLog:WriteELog(me.szName, 3, 1, nTaskId);
	
end

function Wanted:CaptainAcceptTask()
	local tbTeamMembers, nMemberCount	= me.GetTeamMemberList();
	local tbPlayerName	 = {};
	if (not tbTeamMembers) then
		Dialog:Say("Bổ Đầu Hình Bộ: Ngươi không có tổ đội!");
		return;
	end
	if self:Check_Task() ~= 0 then
		return 0;
	end
	if self:CheckLimitTask() ~= 1 then
		return 0;
	end
	local nType = self:GetLevelGroup(me.nLevel);
	local tbOpt = {};
	for i=1, nType do
		if self.DEF_Adv_LEVEL[i] then
		--如果是高级大盗需按时间轴
			if TimeFrame:GetState("OpenAdvWanted") == 1 then
				table.insert(tbOpt, {string.format("%s",self.LevelGroupName[i]), self.TeamAcceptTask, self, i});
			end
		else
			table.insert(tbOpt, {string.format("%s",self.LevelGroupName[i]), self.TeamAcceptTask, self, i});
		end
	end
	table.insert(tbOpt, {"Để ta suy nghĩ đã"});
	Dialog:Say("Bạn có thể nhận các nhiệm vụ sau đây, nhiệm vụ cấp càng cao càng khó.", tbOpt);
		
end

function Wanted:TeamAcceptTask(nLevelSeg, nFlag)
	local tbTeamMembers, nMemberCount	= me.GetTeamMemberList();
	local tbPlayerName	 = {};
	if (not tbTeamMembers) then
		Dialog:Say("Bổ Đầu Hình Bộ: Ngươi không có tổ đội!");
		return;
	end
	local nTeamTaskId = 0;
	if nFlag == 1 then
		nTeamTaskId = self:GetRandomTask(nLevelSeg);
	end
	local nOldIndex	= me.nPlayerIndex
	local nCaptainLevel	= me.nLevel;	-- 队长的等级
	local szCaptainName =  me.szName;	-- 队长的名字
	
	for i=1, nMemberCount do
		if (nOldIndex ~= tbTeamMembers[i].nPlayerIndex) then
			Setting:SetGlobalObj(tbTeamMembers[i]);
			if self:Check_Task() == 0 and self:CheckLimitTask() == 1 and self:GetLevelGroup(me.nLevel) >= nLevelSeg then
					if nFlag == 1 and nTeamTaskId > 0 then
						local szMsg = string.format("Bổ Đầu Hình Bộ: Đội trưởng <color=yellow>%s<color> có nhiệm vụ muốn chia sẻ: nhiệm vụ cấp %s - <color=green>Truy bắt Hải Tặc %s<color>, ngươi có sẵn sàng nhận không?", szCaptainName, (40 + nLevelSeg*10),self.TaskFile[nTeamTaskId].szTaskName);
						local tbOpt = 
						{
							{"Được", self.AcceptTask, self, nTeamTaskId, nLevelSeg},
							{"Không"},
						}
						Dialog:Say(szMsg, tbOpt);
					else
						table.insert(tbPlayerName, {tbTeamMembers[i].nPlayerIndex, tbTeamMembers[i].szName});
					end
			end;
			Setting:RestoreGlobalObj()
		end;
	end;
	
	if nFlag == 1 then
		return
	end
	
	if #tbPlayerName <= 0 then
		Dialog:Say("Bổ Đầu Hình Bộ: Các thành viên trong đội không thể chia sẻ nhiệm vụ, cần đáp ứng các điều kiện sau:<color=yellow>\n\n    Cấp độ phù hợp với đội trưởng và nhiệm vụ\n    Chưa nhận bất kỳ nhiệm vụ Truy nã nào\n    Vẫn còn số lần tham gia truy bắt Hải Tặc\n    Trong phạm vi gần đội trưởng\n    Đã hoàn thành nhiệm vụ chính tuyến cấp 50\n    Uy danh giang hồ đạt 20 điểm<color>\n");
		return;
	end;
	
	local szMembersName	= "\n";
	
	for i=1, #tbPlayerName do
		szMembersName = szMembersName.."<color=yellow>"..tbPlayerName[i][2].."<color>\n";
	end;
	local szMsg = string.format("Bổ Đầu Hình Bộ: Nhiệm vụ có thể chia sẻ với đồng đội:\n%s\nNgươi có muốn chia sẻ?", szMembersName);
	local tbOpt = 
	{
		{"Có", self.TeamAcceptTask, self, nLevelSeg, 1},
		{"Không"},
	}
	Dialog:Say(szMsg, tbOpt);	
end

function Wanted:CancelTask(nFlag)
	if self:Check_Task() ~= 2 then
		return 0;
	end
	if nFlag == 1 then
		self:SetTask(self.TASK_ACCEPT_ID, 0);
		self:SetTask(self.TASK_FINISH, 0);
		self:SetTask(self.TASK_ACCEPT_TIME, 0);
		self:SetTask(self.TASK_100SEG_RANLEVEL, 0);
		Task:CloseTask(self.TASK_MAIN_ID, "giveup");
		return;
	end
	local szMsg = "Bổ Đầu Hình Bộ: Ngươi có chắc chắn muốn hủy nhiệm vụ?";
	local tbOpt = {
		{"Ta muốn hủy nhiệm vụ", self.CancelTask, self, 1},
		{"Để ta suy nghĩ đã"}
	}
	Dialog:Say(szMsg, tbOpt);
	return;
end

function Wanted:FinishTask()
	if self:Check_Task() ~= 1 then
		return 0;
	end	
	self:ShowAwardDialog()	
end

-- 师徒成就：官府通缉
function Wanted:GetAchievement(pPlayer)
	if (not pPlayer) then
		return;
	end
	
	-- nLevle的具体数值对应等级和配置文件"\\setting\\task\\wanted\\level_group.txt"相同
	local nLevel = self:GetTask(self.TASK_LEVELSEG);
	local nAchievementId = 0;
	if (1 == nLevel) then
		nAchievementId = Achievement_ST.TONGJI_55;
	elseif (2 == nLevel) then
		nAchievementId = Achievement_ST.TONGJI_65;
	elseif (3 == nLevel) then
		nAchievementId = Achievement_ST.TONGJI_75;
	elseif (4 == nLevel) then
		nAchievementId = Achievement_ST.TONGJI_85;
	elseif (nLevel >= 5) then
		nAchievementId = Achievement_ST.TONGJI_95;
	end
	
	Achievement_ST:FinishAchievement(pPlayer.nId, nAchievementId);
end

function Wanted:AwardFinish()
	if self:Check_Task() ~= 1 then
		return 0;
	end
	local nTaskId 		= self:GetTask(self.TASK_ACCEPT_ID);
	local nTaskLevel 	= self.TaskFile[nTaskId].nLevelSeg;
	self:SetTask(self.TASK_LEVELSEG, 0);
	self:SetTask(self.TASK_ACCEPT_ID, 0);
	self:SetTask(self.TASK_FINISH, 0);
	self:SetTask(self.TASK_100SEG_RANLEVEL, 0);
	self:SetTask(self.TASK_ACCEPT_TIME, 0);

	local tbLevel = 	
	{
		[1] = 0.6,
		[2] = 0.7,
		[3] = 0.8,
		[4] = 0.9,
		[5] = 1.0,
		[6] = 1.0,
	};
	local nMulti = tbLevel[nTaskLevel] and tbLevel[nTaskLevel] or 1;
	local tbInfo = Kinsalary.EVENT_TYPE[Kinsalary.EVENT_DADAO];
	Kinsalary:AddSalary_GS(me, Kinsalary.EVENT_DADAO, tbInfo.nRate * nMulti);
	
	if (me.GetTrainingTeacher()) then	-- 如果玩家的身份是徒弟，那么师徒任务当中的通缉任务次数加1
		-- local tbItem = Item:GetClass("teacher2student");
		local nNeed_Wanted = me.GetTask(Relation.TASK_GROUP, Relation.TASK_ID_SHITU_WANTED) + 1;
		me.SetTask(Relation.TASK_GROUP, Relation.TASK_ID_SHITU_WANTED, nNeed_Wanted);
	end
	Task:CloseTask(self.TASK_MAIN_ID, "finish");
	
	--额外奖励
	local nFreeCount, tbFunExecute = SpecialEvent.ExtendAward:DoCheck("FinishWanted", me);
	SpecialEvent.ExtendAward:DoExecute(tbFunExecute);
	
	--完成次数累积
	local nTimes = me.GetTask(SpecialEvent.tbPJoinEventTimes.TASKGID, SpecialEvent.tbPJoinEventTimes.TASK_FINISH_WANTED);
	me.SetTask(SpecialEvent.tbPJoinEventTimes.TASKGID, SpecialEvent.tbPJoinEventTimes.TASK_FINISH_WANTED, nTimes + 1);
	
	-- 师徒成就：官府通缉
	self:GetAchievement(me);
	
	-- 增加完成次数
	GCExcute({"Wanted:AddFinishTaskCount_GC", nTaskLevel});
	
	SpecialEvent.ActiveGift:AddCounts(me, 22);		--完成一次大盗活跃度
	SpecialEvent.BuyOver:AddCounts(me, SpecialEvent.BuyOver.TASK_TRUYNA);
	
	--完成Log
	DataLog:WriteELog(me.szName, 3, 4, nTaskId);

end



-- 根据选取出来的奖励表构成奖励面版
function Wanted:ShowAwardDialog()
	local tbGeneralAward = {};  -- 最后传到奖励面版脚本的数据结构
	local szAwardTalk	= "Kể từ hòa nghị Long Hưng, các nơi có chút bình yên. Nhưng gần đây xuất hiện không ít Hải Tặc quấy nhiễu dân lành. Để khôi phục trị an, Hình Bộ nha môn ra lệnh truy nã Hải Tặc, kêu gọi người trong Võ Lâm tương trợ, vì dân trừ hại. Đại hiệp, Danh Bổ Lệnh này cho ngài, hy vọng ngài có thể giúp dân truy bắt Hải Tặc.";	-- 奖励时说的话

	tbGeneralAward.tbFix	= {};
	tbGeneralAward.tbOpt = {};
	tbGeneralAward.tbRandom = {};
	local nNum = self.AWARD_LIST[self:GetTask(self.TASK_LEVELSEG)] or 0;
	local nXiangNum = self.AWARD_LIST2[self:GetTask(self.TASK_LEVELSEG)] or 0;
	local nFreeCount = SpecialEvent.ExtendAward:DoCheck("FinishWanted");
	local nNeedFreeNum = 0;
	local nNeedFreeXiangNum = 0;
	if nNum > 0 then
		nNeedFreeNum = 1;
	end
	if nXiangNum > 0 then
		nNeedFreeXiangNum = 1;
	end
	if me.CountFreeBagCell() < (nNeedFreeNum + nNeedFreeXiangNum + nFreeCount) then
		Dialog:Say(string.format("Hành trang không đủ ô trống. Cần ít nhất %s ô trống để nhận thưởng.", (1 + nFreeCount)));
		return 1;
	end
	if nNum > 0 then
		table.insert(tbGeneralAward.tbFix,
					{
						szType="item", 
						varValue={self.ITEM_MINGBULING[1],self.ITEM_MINGBULING[2],self.ITEM_MINGBULING[3],self.ITEM_MINGBULING[4]}, 
						nSprIdx="",
						szDesc="Danh Bổ Lệnh", 
						szAddParam1=nNum
					}
				);
		table.insert(tbGeneralAward.tbFix,
					{
						szType="bindmoney", 
						varValue=50000, 
						nSprIdx=1,
						szDesc="Bạc khóa", 
						szAddParam1=1
					}
				);
				
	end
	if nXiangNum > 0 then
		local nRLevel = self:GetTask(self.TASK_100SEG_RANLEVEL);
		if nRLevel == 0 then
			local nRLevel = MathRandom(1,5);
			self:SetTask(self.TASK_100SEG_RANLEVEL, nRLevel);
		end
		table.insert(tbGeneralAward.tbFix,
					{
						szType="item", 
						varValue={self.ITEM_MINGBUXIANG[1],self.ITEM_MINGBUXIANG[2],self.ITEM_MINGBUXIANG[3], nRLevel}, 
						nSprIdx="",
						szDesc="Mảnh Phong Ấn", 
						szAddParam1=nXiangNum,
					}
				);
		end
	GeneralAward:SendAskAward(szAwardTalk, 
							  tbGeneralAward, {"Wanted:AwardFinish", Wanted.AwardFinish} );
end;

function Wanted:Day_SetTask(nDay)
	if me.nLevel < self.LIMIT_LEVEL then
		return 0;
	end
	local nCount = self.Day_COUNT * nDay;
	if self:GetTask(self.TASK_COUNT) + nCount > self.LIMIT_COUNT_MAX then
		nCount = self.LIMIT_COUNT_MAX - self:GetTask(self.TASK_COUNT);
	end
	self:SetTask(self.TASK_COUNT, self:GetTask(self.TASK_COUNT) + nCount);
	if self:GetTask(self.TASK_FIRST) == 0 then
		self:SetTask(self.TASK_FIRST, 1);
	end
	local nFlag = self:Check_Task();
	local nSec = self:GetTask(self.TASK_ACCEPT_TIME);
	if nFlag == 2 and nSec > 0 and tonumber(os.date("%Y%m%d",GetTime())) > tonumber(os.date("%Y%m%d",nSec)) then
		--如果任务已经过期但未完成；
		self:CancelTask(1);
		me.Msg("Nhiệm vụ thất bại do quá hạn. Nhiệm vụ chỉ có thể hoàn thành trong ngày.");
	end
end

PlayerSchemeEvent:RegisterGlobalDailyEvent({Wanted.Day_SetTask, Wanted});

--随机召唤boss
function Wanted:GetRandomBossInfor()
	local nCurOpenServerDay = TimeFrame:GetServerOpenDay();
	local nFlag = -1;
	local nSegId = 0;
	for nId, nOpenServerDay in pairs(self.CallBossRateSeg) do
		if nFlag < nOpenServerDay and nCurOpenServerDay >= nOpenServerDay then
			nSegId = nId;
			nFlag = nOpenServerDay;
		end
	end
	local nRateSum = 0;
	local nCurRate = MathRandom(1, self.CallBossRate[nSegId].nMaxRate);
	for _, tbBoss in pairs(self.CallBossRate[nSegId].tbBoss) do
		nRateSum = nRateSum + tbBoss.nRate;
		if nCurRate <= nRateSum then
			return tbBoss.tbNpcInFor;
		end
	end
	return;
end

function Wanted:ReRandomTask(nSeg, tbTaskLevelSeg)
	if not self.TaskLevelSeg then
		return;
	end
	self.TaskLevelSeg[nSeg] = tbTaskLevelSeg;
	self.TaskLevelSegActionKind[nSeg] = {};
	for _, nTaskId in ipairs(self.TaskLevelSeg[nSeg]) do
		local nActionKind = self.TaskFile[nTaskId].nActionKind;
		self.TaskLevelSegActionKind[nSeg][nActionKind] = self.TaskLevelSegActionKind[nSeg][nActionKind] or {};
		table.insert(self.TaskLevelSegActionKind[nSeg][nActionKind], nTaskId);
	end
end
