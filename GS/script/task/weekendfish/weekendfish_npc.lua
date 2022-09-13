-- 文件名　：weekendfish_npc.lua
-- 创建者　：huangxiaoming
-- 创建时间：2011-08-05 14:06:00
-- 描  述  ：

Require("\\script\\task\\weekendfish\\weekendfish_def.lua")

local tbClass = Npc:GetClass("weekednfish_npc");

function tbClass:OnDialog()
	local szMsg = "Xin chào! Ta có thể giúp gì cho ngươi?\n";
	local tbOpt = {};
	local tbDuanWu2011 = SpecialEvent.DuanWu2011 or {};
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	if WeekendFish:CheckOpen() == 1 then
		szMsg = "    Thứ 7 và Chủ nhật hàng tuần <color=green>10:00-14:00 và 16:00-20:00<color>, cá sẽ xuất hiện ở các vùng nước trên thế giới. Mua cần câu, mồi và đừng quên <color=yellow>Cẩm nang cá<color> sẽ giúp ngươi giám định loại cá. Mỗi ngày có thể bắt tối đa <color=yellow>50 con cá<color>.";
		if WeekendFish:CheckCanAcceptTask(me) == 1 then
			table.insert(tbOpt, {"<color=yellow>Nhận nhiệm vụ câu cá<color>", self.OnDialog_Accept, self});
		elseif WeekendFish:CheckCanAwardTask(me) == 1 then
			table.insert(tbOpt, {"<color=yellow>Hoàn thành nhiệm vụ<color>", self.OnDialog_Finish, self});
		end
		if WeekendFish:CheckCanHandInFish(me) == 1 then
			local nHandinNum = WeekendFish:GetTodyRemainHandInFishNum(me);
			table.insert(tbOpt, {"<color=pink>Nộp cá<color>", self.OnDialog_HandIn, self, nHandinNum});
		end
		if WeekendFish:CheckCanChangeAward(me) == 1 then
			table.insert(tbOpt, {"Nhận phần thưởng", self.OnDialog_Award, self});
		end
		table.insert(tbOpt, {"<color=blue>Xem xếp hạng<color>", self.OnDialog_LuckFishRank, self});
		-- table.insert(tbOpt, {"Giới thiệu", self.Introduce, self});
		table.insert(tbOpt, {"<color=green>Cửa hàng Ngư cụ<color>", self.OpenFishShop, self});
	end
	if tbDuanWu2011.IS_OPEN == 1 and nDate >= tbDuanWu2011.OPEN_DAY then
		table.insert(tbOpt, {"Mở cửa hàng danh vọng", tbDuanWu2011.OpenShop, tbDuanWu2011});
		table.insert(tbOpt, {"Đổi đai lưng", tbDuanWu2011.ChangeDuanWuBelt, tbDuanWu2011});
	end
	table.insert(tbOpt, {"Ta chỉ xem qua thôi"});
	Dialog:Say(szMsg, tbOpt);
	return 1;
end

function tbClass:OpenFishShop()
	if WeekendFish._OPEN ~= 1 then
		Dialog:Say("渔夫用具商店暂时关闭");
		return 0;
	end
	me.OpenShop(200, 1);
end

function tbClass:Introduce()
	Task.tbHelp:OpenNews(5, "周末钓鱼活动");
end

function tbClass:OnDialog_Accept()
	local szMsg = "  Nhận nhiệm vụ câu cá vào Thứ 7 và Chủ nhật, sau khi hoàn thành sẽ nhận được <color=yellow>Kinh nghiệm khủng<color>, <color=yellow>Chứng nhận thủy sản<color> và <color=yellow>nhân đôi phần thưởng<color>.\n  Sau khi hoàn thành nhiệm vụ, ngươi sẽ nhận được <color=green>Chúc phúc của Tần Oa<color>, khi nhận nhiệm vụ ở tuần tới, để bắt được những con cá nặng hơn.\n<color=yellow>Lưu ý: Có thể nhận nhiệm vụ cá nhân hoặc tổ đội.<color>";
	local tbOpt = {
		{"<color=yellow>Nhận nhiệm vụ cá nhân<color>", self.SingleAcceptTask, self},
		{"Để ta suy nghĩ lại"},
	};
	if me.IsCaptain() == 1 then
		table.insert(tbOpt, 1, {"Nhận nhiệm vụ tổ đội", self.CaptainAcceptTask, self});
	end
	Dialog:Say(szMsg, tbOpt);
end

-- 单人接任务
function tbClass:SingleAcceptTask()
	self:AcceptTask(1);
end

-- 队长接任务
function tbClass:CaptainAcceptTask(nFlag)
	local nRes, szMsg = WeekendFish:CheckCanAcceptTask(me);
	if nRes ~= 1 then
		Dialog:Say(szMsg);
		return 0;
	end
	local tbTeamMembers, nMemberCount	= me.GetTeamMemberList();
	local tbPlayerName	 = {};
	if (not tbTeamMembers) then
		Dialog:Say("Tần Oa: Ngươi không nằm trong tổ đội nào!");
		return;
	end
	local nTaskValue = 0;
	if nFlag == 1 then
		nTaskValue = WeekendFish:RandTeamFishShareTaskList();
		me.SetTask(WeekendFish.TASK_GROUP, WeekendFish.TASK_TEAM_IDGROUP, nTaskValue);
		self:AcceptTask();
	end
	local szCaptainName = me.szName;
	for i = 1, nMemberCount do
		if me.nPlayerIndex ~= tbTeamMembers[i].nPlayerIndex  and me.nMapId == tbTeamMembers[i].nMapId then
			Setting:SetGlobalObj(tbTeamMembers[i]);
			if WeekendFish:CheckCanAcceptTask(me) == 1 then
				if nFlag and nFlag == 1 then
					WeekendFish:ClearTaskValue(me);
					me.SetTask(WeekendFish.TASK_GROUP, WeekendFish.TASK_TEAM_IDGROUP, nTaskValue);
					local szMsg = string.format("Tần Oa: Đội trưởng <color=yellow>%s<color> muốn chia sẻ nhiệm vụ câu cá, ngươi đồng ý chứ?", szCaptainName);
					local tbOpt = 
					{
						{"Vâng", self.AcceptTask, self},
						{"Không nhận"},	
					};
					Dialog:Say(szMsg, tbOpt);
				else
					table.insert(tbPlayerName, {tbTeamMembers[i].nPlayerIndex, tbTeamMembers[i].szName});
				end
			end
			Setting:RestoreGlobalObj()
		end
	end
	if nFlag and nFlag == 1 then
		return;
	end
	if #tbPlayerName <= 0 then
		Dialog:Say("Tần Oa: Hiện tại chưa có đồng đội nào đủ điều kiện nhận nhiệm vụ\n");
		return;
	end
	local szMembersName = "\n";
	for i = 1, #tbPlayerName do
		szMembersName = szMembersName .. "<color=yellow>"..tbPlayerName[i][2].."<color>\n";
	end
	local szMsg = string.format("Tần Oa: Những đồng đội có thể chia sẻ nhiệm vụ gồm:\n%s\nNgươi có chắc muốn chia sẻ nhiệm vụ chứ?", szMembersName);
	local tbOpt = 
	{
		{"Đúng vậy", self.CaptainAcceptTask, self, 1},
		{"Không chia sẻ"},	
	};
	Dialog:Say(szMsg, tbOpt);
end

function tbClass:AcceptTask(nClearGroupTask)
	local nRes, szMsg = WeekendFish:CheckCanAcceptTask(me);
	if nRes ~= 1 then
		Dialog:Say(szMsg);
		return 0;
	end
	if nClearGroupTask and nClearGroupTask == 1 then
		WeekendFish:ClearTaskValue(me);
	end
	local nPreAcceptDay = me.GetTask(WeekendFish.TASK_GROUP, WeekendFish.TASK_ACCEPT_DAY);
	local tbResult = Task:DoAccept(WeekendFish.TASK_MAIN_ID, WeekendFish.TASK_MAIN_ID);
	if not tbResult then
		Dialog:Say("Nhiệm vụ đã đầy, không thể nhận thêm");
		return 0;
	end
	local nWeek = tonumber(GetLocalDate("%W"));
	local nTaskWeek = me.GetTask(WeekendFish.TASK_GROUP, WeekendFish.TASK_ACHIEVEBUF_WEEK);
	local nTimes = me.GetTask(WeekendFish.TASK_GROUP, WeekendFish.TASK_ACHEIVEBUF_NUM);
	if ((nWeek == nTaskWeek + 1 or nWeek < nTaskWeek) and nTimes == 2) or (nPreAcceptDay == 0) then	-- 上一周做了两次或是第一次接任务
		me.SetTask(WeekendFish.TASK_GROUP, WeekendFish.TASK_ACHIEVEBUF_WEEK, nWeek);
		me.SetTask(WeekendFish.TASK_GROUP, WeekendFish.TASK_ACHEIVEBUF_NUM, 0);
		me.AddSkillState(WeekendFish.STATE_SKILLID, 1, 1, WeekendFish.STATE_TIME, 1, 0, 1);
	end	
	if nClearGroupTask == 1 then -- 单人接任务
		StatLog:WriteStatLog("stat_info", "fishing", "get_task", me.nId, 1, 0);
	else
		local tbTeamMembers, nMemberCount	= me.GetTeamMemberList();
		StatLog:WriteStatLog("stat_info", "fishing", "get_task", me.nId, nMemberCount, me.nTeamId);
	end
	Dialog:SendBlackBoardMsg(me, "Nhận được Chứng nhận thủy sản, có thể nhân đôi tổng phần thưởng");
	if nPreAcceptDay == 0 then
		me.Msg("Nhận nhiệm vụ lần đầu tiên sẽ nhận được Chúc phúc Tần Oa. Chúc phúc sẽ tăng cơ hội bắt được cá nặng hơn. Ngươi có thể nhận được Chúc phúc khi hoàn thành nhiệm vụ câu cá 2 lần trong tuần và nhận nhiệm vụ vào tuần sau.");
	end
end

function tbClass:OnDialog_Finish()
	if WeekendFish:CheckCanAwardTask(me) == 1 then
		WeekendFish:ShowAwardDialog();
	end
end


-- 兑换奖励
function tbClass:OnDialog_HandIn(nHandinNum)
	Dialog:OpenGift(string.format("Hãy đặt cá cần nộp cho ta, ngươi còn có thể nộp <color=yellow>%s con cá<color> trong hôm nay", nHandinNum), nil, {self.OnHandInFish, self});
end

function tbClass:OnHandInFish(tbItem)
	local nRes, szMsg = WeekendFish:CheckCanHandInFish(me);
	if nRes ~= 1 then
		Dialog:Say(szMsg);
	end
	if #tbItem <= 0 then
		return 0;
	end
	local nTempNum = 0;
	for _, tbTemp in pairs(tbItem) do
		local pItem = tbTemp[1];
		if WeekendFish:CheckIsFish(pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel) ~= 1 then
			Dialog:Say("Ta chỉ lấy cá, đừng mang thứ khác cho ta.");
			return 0;
		end
		nTempNum = nTempNum + 1;
	end
	local nTodayHandInNum = me.GetTask(WeekendFish.TASK_GROUP, WeekendFish.TASK_HANDIN_NUM);
	if nTodayHandInNum + nTempNum > WeekendFish.MAX_FISH_DAYTIMES then
		Dialog:Say("Ngươi đã giao đủ 50 con cá. Phần này ta không nhận nữa.");
		return 0;
	end
	local nHandInNum = 0;
	local tbTaskFishWeight = {0,0,0};	-- 3种任务鱼的重量
	local nWeightSum = 0;
	for _, tbTemp in pairs(tbItem) do
		local pItem = tbTemp[1];
		local nWeight = pItem.GetGenInfo(1,0);	-- 重量
		local nTaskId = WeekendFish:GetFishTaskId(pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel);
		if me.DelItem(pItem) ~= 1 then
			Dbg:WriteLog("WeekendFish", "fish2award_failure", me.szName, string.format("%s,%s,%s,%s", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel));
		else
			if nTaskId > 0 and nTaskId <= 3 then
				tbTaskFishWeight[nTaskId] = tbTaskFishWeight[nTaskId] + nWeight;
			end
			nWeightSum = nWeightSum + nWeight;
			nHandInNum = nHandInNum + 1;
		end
	end
	WeekendFish:AddTaskFishRank(me, tbTaskFishWeight);	-- 增加鱼排行榜自己的积分
	me.SetTask(WeekendFish.TASK_GROUP, WeekendFish.TASK_HANDIN_NUM, nTodayHandInNum + nHandInNum);
	local nTodayHandInWeight = me.GetTask(WeekendFish.TASK_GROUP, WeekendFish.TASK_HANDIN_WEIGHT) + nWeightSum
	me.SetTask(WeekendFish.TASK_GROUP, WeekendFish.TASK_HANDIN_WEIGHT, nTodayHandInWeight);
	if nTodayHandInWeight >= 1000 then
		Achievement:FinishAchievement(me, 388);
	end
	if nTodayHandInWeight >= 1500 then
		Achievement:FinishAchievement(me, 389);
	end
	if nTodayHandInWeight >= 1700 then
		Achievement:FinishAchievement(me, 390);
	end
	local nRemainHandInNum = WeekendFish.MAX_FISH_DAYTIMES - nTodayHandInNum - nHandInNum;	
	local szMsg = string.format("  Ngươi đã giao <color=yellow>%s cân cá<color>, vẫn còn <color=yellow>%s con cá<color> chưa được giao. Nhưng nếu ngươi không muốn câu thêm, có thể nhận ngay phần thưởng.\n\n<color=red>Lưu ý: Mỗi ngày chỉ có thể nhận thưởng 1 lần.<color>\n", nTodayHandInWeight, nRemainHandInNum);
	local tbOpt =
	{
		{"Ta sẽ tiếp tục câu cá"},
		{"Thôi, ta muốn nhận thưởng", self.OnDialog_Award, self},	
	};
	if nRemainHandInNum > 0 then
		table.insert(tbOpt, 1, {"<color=yellow>Ta muốn nộp thêm cá<color>", self.OnDialog_HandIn, self, nRemainHandInNum});
	end
	Dialog:Say(szMsg, tbOpt);
end

function tbClass:OnDialog_Award(nSure)
	local nRes, szMsg = WeekendFish:CheckCanChangeAward(me);
	if nRes ~= 1 then
		Dialog:Say(szMsg);
	end
	local nWeightSum = me.GetTask(WeekendFish.TASK_GROUP, WeekendFish.TASK_HANDIN_WEIGHT);
	if nWeightSum < WeekendFish.AWARD_LEVEL[2][1] then
		Dialog:Say(string.format("Ngươi chỉ mới nộp <color=yellow>%s cân<color>. Yêu cầu tối thiểu là 120 cân mới có thể nhận thưởng.", nWeightSum));
		return 0;
	end
	local nAwardType = 1;
	for i = #WeekendFish.AWARD_LEVEL, 1, -1 do
		if nWeightSum >= WeekendFish.AWARD_LEVEL[i][1] then
			nAwardType = i;
			break;
		end
	end
	local nAwardTypeNoRecom = 1;
	local nWeightSumNoRecom = math.floor(nWeightSum * WeekendFish.AWARD_NORECOMMENDATION);
	for i = #WeekendFish.AWARD_LEVEL, 1, -1 do
		if nWeightSumNoRecom >= WeekendFish.AWARD_LEVEL[i][1] then
			nAwardTypeNoRecom = i;
			break;
		end
	end
	local nRecommendationFlag = 0;
	local tbFind = me.FindItemInBags(unpack(WeekendFish.ITEM_RECOMMENDATION));
	if tbFind[1] then
		nRecommendationFlag = 1;
	end
	local nHandInNum = me.GetTask(WeekendFish.TASK_GROUP, WeekendFish.TASK_HANDIN_NUM);
	if not nSure then
		local szMsg = "";
		if nRecommendationFlag == 0 then
			szMsg = string.format("   Gút chóp! Ngươi đã nộp <color=yellow>%s/%s<color> con cá, tổng trọng lượng <color=yellow>%s cân<color>, ngươi <color=red>không có<color> <color=yellow>Chứng nhận thủy sản<color> ta chỉ có thể giao cho ngươi <color=yellow>phần thưởng cấp %s<color>. Nếu có Chứng nhận thủy sản, ta sẽ giao cho ngươi <color=yellow>phần thưởng cấp %s<color> Phần thưởng được chia thành <color=yellow>7 cấp độ<color>.\n   Chứng nhận thủy sản có thể nhận thông qua <color=yellow>Hoàn thành nhiệm vụ<color> và sẽ hết hạn vào 23:30 cùng ngày.\n\n<color=red>Lưu ý: Mỗi ngày chỉ có thể nhận thưởng 1 lần.<color>\n", nHandInNum, WeekendFish.MAX_FISH_DAYTIMES, nWeightSum, nAwardTypeNoRecom, nAwardType);
		else
			szMsg = string.format("   Gút chóp! Ngươi đã nộp <color=yellow>%s/%s<color> con cá, tổng trọng lượng <color=yellow>%s cân<color>, vì ngươi có Chứng nhận thủy sản, ta có thể giao cho ngươi <color=yellow>phần thưởng cấp %s<color> Phần thưởng được chia thành <color=yellow>7 cấp độ<color>. Ngươi muốn nhận chứ?\n\n<color=red>Lưu ý: Mỗi ngày chỉ có thể nhận thưởng 1 lần.<color>\n", nHandInNum, WeekendFish.MAX_FISH_DAYTIMES, nWeightSum, nAwardType);
		end
		local tbOpt =
		{
			{"Xác nhận lãnh phần thưởng", self.OnDialog_Award, self, 1},
			{"Để ta suy nghĩ thêm"},	
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	local tbAward = {};
	if nRecommendationFlag == 1 then
		tbAward = WeekendFish.AWARD_LEVEL[nAwardType];
	else
		tbAward = WeekendFish.AWARD_LEVEL[nAwardTypeNoRecom];
	end
	local nBagCount = 0;
	for i = 2, #tbAward do
		nBagCount = nBagCount + tbAward[i];
	end
	if me.CountFreeBagCell() < nBagCount then
		Dialog:Say(string.format("Hành trang cần <color=yellow>%s ô trống<color>.", nBagCount));
		return 0;
	end
	if nRecommendationFlag == 1 then
		me.ConsumeItemInBags(1, WeekendFish.ITEM_RECOMMENDATION[1], WeekendFish.ITEM_RECOMMENDATION[2], WeekendFish.ITEM_RECOMMENDATION[3], WeekendFish.ITEM_RECOMMENDATION[4], -1);
	end
	me.SetTask(WeekendFish.TASK_GROUP, WeekendFish.TASK_HANDIN_AWARD, 1);
	me.SetTask(WeekendFish.TASK_GROUP, WeekendFish.TASK_HANDIN_WEIGHT, 0);
	for i = 2, #tbAward do
		if tbAward[i] > 0 then
			for j = 1, tbAward[i] do
				local pItem = me.AddItem(WeekendFish.ITEM_AWARD_BOX[1], WeekendFish.ITEM_AWARD_BOX[2], WeekendFish.ITEM_AWARD_BOX[3], WeekendFish.ITEM_AWARD_BOX[4] + i - 2);
				if pItem then
					pItem.Bind(1);
				end
			end
		end
	end
	StatLog:WriteStatLog("stat_info", "fishing", "fish_award", me.nId, nWeightSum, nRecommendationFlag, nHandInNum);
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, 
			string.format("Cau ca cuoi tuan: Nguoi choi %s,  Trong luong: %s, Chung nhan thuy san: %s", 
			me.szName, nWeightSum, nRecommendationFlag));
end

-- 排行榜
function tbClass:OnDialog_LuckFishRank()
	local nRes ,szMsg = WeekendFish:CheckViewLuckRank();
	if nRes ~= 1 then
		Dialog:Say(szMsg);
		return 0;
	end
	local tbTaskList = {};
	tbTaskList[1] = KGblTask.SCGetDbTaskInt(DBTASK_WEEKENDFISH_TASK_ID1);
	tbTaskList[2] = KGblTask.SCGetDbTaskInt(DBTASK_WEEKENDFISH_TASK_ID2);
	tbTaskList[3] = KGblTask.SCGetDbTaskInt(DBTASK_WEEKENDFISH_TASK_ID3);
	local tbOpt = {};
	for i = 1, 3 do
		local tbInfo = {string.format("Bảng xếp hạng <color=yellow>[%s]<color>", KItem.GetNameById(unpack(WeekendFish.ITEM_FISH_ID[tbTaskList[i]]))),self.OnDialog_ViewLunckFishRank, self, i, tbTaskList[i]};
		table.insert(tbOpt, tbInfo);
	end
	
	if (WeekendFish.tbLuckFishRank_Ex) then
		for nType, tbRank in pairs(WeekendFish.tbLuckFishRank_Ex) do
			if (#tbRank > 0) then
				local tbInfo = {string.format("Bảng xếp hạng <color=yellow>cá thứ %s<color>", nType), self.OnDialog_ViewLunckFishRank_Ex, self, nType};
				table.insert(tbOpt, tbInfo);
			end
		end
	end
	
	table.insert(tbOpt, {"Ta chỉ đi ngang qua"});
	szMsg = "   Mỗi tuần ta chọn 3 loại cá làm cá may mắn tuần, người chơi có trọng lượng cá may mắn cao nhất sẽ được phần thưởng xếp hạng may mắn. <color=green>Hạng 1<color> được <color=yellow>sọt cá 18 ô<color>, <color=green>hạng 2 đến 5<color> được <color=yellow>sọt cá 15 ô<color>. Sọt cá có thể gắn vào vị trí túi mở rộng.\n\n<color=green>Thời gian nhận thưởng: 23:32 Chủ nhật đến 23:32 Thứ 6 tuần sau<color>";
	Dialog:Say(szMsg, tbOpt);
end

function tbClass:OnDialog_ViewLunckFishRank(nType, nFishSort)
	local nRes ,szMsg = WeekendFish:CheckViewLuckRank();
	if nRes ~= 1 then
		Dialog:Say(szMsg);
		return 0;
	end
	if not WeekendFish.tbLuckFishRank then
		Dialog:Say("Không tìm thấy bảng xếp hạng");
		return 0;
	end
	local nWeek = tonumber(GetLocalDate("%W"));
	if nWeek ~= me.GetTask(WeekendFish.TASK_GROUP, WeekendFish.TASK_RANK_WEEK) then
		me.SetTask(WeekendFish.TASK_GROUP, WeekendFish.TASK_RANK_WEEK, nWeek);
		me.SetTask(WeekendFish.TASK_GROUP, WeekendFish.TASK_WEIGHT_FISH1, 0);
		me.SetTask(WeekendFish.TASK_GROUP, WeekendFish.TASK_WEIGHT_FISH2, 0);
		me.SetTask(WeekendFish.TASK_GROUP, WeekendFish.TASK_WEIGHT_FISH3, 0);
	end
	local szFishName = KItem.GetNameById(unpack(WeekendFish.ITEM_FISH_ID[nFishSort]));
	if not WeekendFish.tbLuckFishRank[nType] or #WeekendFish.tbLuckFishRank[nType] == 0 then
		Dialog:Say(string.format("  Hôm nay chưa ai đến giao %s, nhanh chóng đi câu đi, thành tựu mới và phần thưởng đang chờ ngươi.", szFishName));
		return 0;
	end
	local szMsg = "";
	local nFishWeight = me.GetTask(WeekendFish.TASK_GROUP, WeekendFish.TASK_WEIGHT_FISH1 + nType - 1);
	if nFishWeight > 0 then
		szMsg = szMsg .. string.format("Lần này ngươi đã giao <color=yellow>%s cân<color> <color=green>%s<color>\n\n", nFishWeight, szFishName);
	end
	szMsg = szMsg .. "<color=yellow>----Xếp hạng cá may mắn----<color>\n\n";
	for nRank = 1, #WeekendFish.tbLuckFishRank[nType] do
		szMsg = szMsg .. string.format("<color=yellow>%s<color>%s %s\n", Lib:StrFillC("Hạng: " .. nRank .. " ", 8), Lib:StrFillC(WeekendFish.tbLuckFishRank[nType][nRank][1], 16), Lib:StrFillC(WeekendFish.tbLuckFishRank[nType][nRank][2] .. " cân", 8));
	end
	local tbOpt = {}
	if WeekendFish:CheckCanAwardLuckRank(me, nType) > 0 then
		table.insert(tbOpt, {"Nhận phần thưởng cá may mắn", WeekendFish.GetLuckFishAward, WeekendFish, me.nId, nType});
	end
	table.insert(tbOpt, {"Ta hiểu rồi"});
	Dialog:Say(szMsg , tbOpt);
end

function tbClass:OnDialog_ViewLunckFishRank_Ex(nType)
	local nRes ,szMsg = WeekendFish:CheckViewLuckRank();
	if nRes ~= 1 then
		Dialog:Say(szMsg);
		return 0;
	end
	if not WeekendFish.tbLuckFishRank_Ex then
		Dialog:Say("Không tìm thấy bảng xếp hạng");
		return 0;
	end
	local nWeek = tonumber(GetLocalDate("%W"));
	if nWeek ~= me.GetTask(WeekendFish.TASK_GROUP, WeekendFish.TASK_RANK_WEEK) then
		me.SetTask(WeekendFish.TASK_GROUP, WeekendFish.TASK_RANK_WEEK, nWeek);
		me.SetTask(WeekendFish.TASK_GROUP, WeekendFish.TASK_WEIGHT_FISH1, 0);
		me.SetTask(WeekendFish.TASK_GROUP, WeekendFish.TASK_WEIGHT_FISH2, 0);
		me.SetTask(WeekendFish.TASK_GROUP, WeekendFish.TASK_WEIGHT_FISH3, 0);
	end
	local tbOpt = {}
	if WeekendFish:CheckCanAwardLuckRank(me, nType) > 0 then
		table.insert(tbOpt, {"Nhận phần thưởng cá may mắn", WeekendFish.GetLuckFishAward, WeekendFish, me.nId, nType});
	end
	szMsg = "Nhận giải thưởng câu cá cuối tuần:";
	table.insert(tbOpt, {"Ta hiểu rồi"});
	Dialog:Say(szMsg , tbOpt);
end

