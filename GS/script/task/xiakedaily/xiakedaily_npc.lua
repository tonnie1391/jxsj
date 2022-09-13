-- 文件名　：xiakedaily_npc.lua
-- 创建者　：huangxiaoming
-- 创建时间：2011-03-15 12:10:10
-- 描  述  ：

Require("\\script\\task\\xiakedaily\\xiakedaily_def.lua")

local tbClass = Npc:GetClass("xiakedaily");

function tbClass:OnDialog()
	local szMsg = "   Giang hồ sóng gió không ngừng, các hiệp sĩ biết cứu khốn phò nguy, nói được làm được, mới là nghĩa hiệp chân tình!\n";
	if XiakeDaily:CheckOpen() ~= 1 then
		Dialog:Say(szMsg);
		return 0;
	end
	if me.nLevel < XiakeDaily.LEVEL_LIMIT or me.nFaction <= 0 then
		Dialog:Say(szMsg .. "   Level chưa đủ 100 hoặc chưa gia nhập môn phái");
		return 0;
	end
	XiakeDaily:PredictAccept();
	local nTask1 = KGblTask.SCGetDbTaskInt(DBTASK_XIAKEDAILY_TASK_ID1);
	local nTask2 = KGblTask.SCGetDbTaskInt(DBTASK_XIAKEDAILY_TASK_ID2);
	local nTomorrowTask1 = KGblTask.SCGetDbTaskInt(DBTASK_XIAKEDAILY_TOMORROW_TASK_ID1);
	local nTomorrowTask2 = KGblTask.SCGetDbTaskInt(DBTASK_XIAKEDAILY_TOMORROW_TASK_ID2);
	local nWeekTimes = XiakeDaily:GetWeekTimes();
	local szMsgEx = "";
	if nWeekTimes == XiakeDaily.WEEK_MAX_TIMES then
		szMsgEx = "\n\n<color=red>Ngươi đã hết số lần hoàn thành nhiệm vụ<color>"
	end
	local nDayAcceptTimes = XiakeDaily:GetTask(XiakeDaily.TASK_ACCEPT_COUNT);
	local szMsg = string.format("<newdialog>   Giang hồ sóng gió không ngừng, các hiệp sĩ biết cứu khốn phò nguy, nói được làm được, mới là nghĩa hiệp chân tình!\n<color=green>             Nhiệm vụ hiệp khách hôm nay \n\n  <color><color=yellow>%s<color>   <color=yellow>%s<color>\n    %s     %s\n\nTuần này đã hoàn thành nhiệm  vụ hiệp khách <color=green>%s/%s<color> lần\nCòn nhận được <color=green>%s<color> lần.\n<color=green>Thưởng nhiệm vụ<color>  <item=18,1,1233,1><color=gold> X %s<color>%s", Lib:StrFillC(XiakeDaily.TaskFile[nTask1].szDynamicDesc, 16), Lib:StrFillC(XiakeDaily.TaskFile[nTask2].szDynamicDesc, 16), XiakeDaily.ID_TO_IMAGE[nTask1], XiakeDaily.ID_TO_IMAGE[nTask2], nWeekTimes, XiakeDaily.WEEK_MAX_TIMES, nDayAcceptTimes, XiakeDaily.AWARD_ONCE, szMsgEx);
	local nFlag = XiakeDaily:GetTask(XiakeDaily.TASK_STATE);
	local tbOpt = {};
	if nFlag == 0 and nDayAcceptTimes > 0 and nWeekTimes < XiakeDaily.WEEK_MAX_TIMES then
		table.insert(tbOpt, {"<color=yellow>Nhận nhiệm vụ hiệp khách<color>", self.OnDialog_Accept, self});
	elseif nFlag == 1 and XiakeDaily:GetTask(XiakeDaily.TASK_FIRST_TARGET) == 1 and XiakeDaily:GetTask(XiakeDaily.TASK_SECOND_TARGET) == 1 then -- 任务已完成
		table.insert(tbOpt, {"<color=yellow>Lãnh thưởng nhiệm vụ<color>", self.OnDialog_Finish, self});
	end
	table.insert(tbOpt, {"Xem nhiệm vụ ngày mai", self.QueryTomorrowTask, self});
	table.insert(tbOpt, {"Cửa hàng hiệp khách", self.OpenXiaKeShop, self});
	table.insert(tbOpt, {"Giới thiệu nhiệm vụ hiệp khách", self.Introduce, self});
	table.insert(tbOpt, {"Ta chỉ xem qua"});
	
	Dialog:Say(szMsg, tbOpt);
end

function tbClass:Introduce()
	local szMsg = "<color=green>[Sơ lược]<color>\nMỗi ngày nhận được <color=yellow>nhiệm vụ hiệp khác ngày <color>， hoàn thành trước <color=yellow>3h sáng<color>hôm sau và giao nhiệm vụ cho ta được nhận<color=yellow>2<color>hiệp khách hiệp . đạt <color=yellow>cấp 100<color>và<color=yellow>gia nhập môn phái<color>sẻ nhận được nhiệm vụ. \n\n<color=green>【Cách chơi】<color>   Mỗi ngày ta chọn ngẫu nhiên 2 mục trong<color=yellow>Tiêu dao cốc, Nhiệm vụ quân doanh, Phó bản tàng bảo đồ<color>Mỗi ngày hoàn thành nhiệm vụ hiệp khách, mỗi tuần tối đa<color=yellow>5 lần<color>, hoàn thành nhiệm vụ lần thứ 5 được nhận <color=yellow>4<color>hiệp khách lệnh，nhận tối đa <color=yellow>14<color>hiệp khách lệnh。\n\n<color=green>【Phần thưởng】<color>   hiệp khách lệnh được mua <color=yellow>[Túi Quà Nghĩa Hiệp]（7 ngày）<color>,<color=yellow>28<color>hiệp khách lệnh đổi 1<color=yellow>[Túi Quà Nghĩa Hiệp]<color>Trong túi quà có <color=yellow>9 Huyền tinh<color>哟!<color=red>Lưu ý <color>: Quân doanh cần mở Chu Tước Thạch và tiêu diệt BOSS cuối cùng, nhiệm vụ ngẫu nhiên nếu gặp được Tàng bảo đồ sẻ nhận được số lần vào Tàng bảo đồ sẻ được thêm số lần vào Tàng bảo đồ, Tiêu Dao Cốc độ khó 1 Saoo phải qua 5 ải, khó 3 sao hoặc trên 3 sao phải qua 4 ải trở lên";
	local tbOpt = 
	{
		{"Quay trở lại", self.OnDialog, self},
		{"Kết thúc đối thoại"},	
	};
	Dialog:Say(szMsg, tbOpt);
end

function tbClass:QueryTomorrowTask()
	if XiakeDaily:CheckOpen() ~= 1 then
		Dialog:Say(" Nhiệm vụ chưa mở \n");
		return 0;
	end
	local nTomorrowTask1 = KGblTask.SCGetDbTaskInt(DBTASK_XIAKEDAILY_TOMORROW_TASK_ID1);
	local nTomorrowTask2 = KGblTask.SCGetDbTaskInt(DBTASK_XIAKEDAILY_TOMORROW_TASK_ID2);
	local szMsg = string.format("<newdialog>   Giang hồ sóng gió không ngừng, các hiệp sĩ biết cứu khốn phò nguy, nói được làm được, mới là nghĩa hiệp chân tình!\n<color=green>             Nhiệm vụ ngày mai\n\n<color>  <color=yellow>%s<color>   <color=yellow>%s<color>\n    %s     %s\n", Lib:StrFillC(XiakeDaily.TaskFile[nTomorrowTask1].szDynamicDesc, 16), Lib:StrFillC(XiakeDaily.TaskFile[nTomorrowTask2].szDynamicDesc, 16),  XiakeDaily.ID_TO_IMAGE[nTomorrowTask1], XiakeDaily.ID_TO_IMAGE[nTomorrowTask2]);
	local tbOpt = 
	{
		{"Quay trở lại", self.OnDialog, self},
		{"Kết thúc đối thoại"},	
	};
	Dialog:Say(szMsg, tbOpt);
end

function tbClass:OnDialog_Accept(nSure)
	if XiakeDaily:CheckOpen() ~= 1 then
		Dialog:Say(" Giang hồ trên gió nổi mây phun, chân chính đích hiệp nghĩa chính là cấp nhân khó khăn, nói tất tín, trừ bạo giúp kẻ yếu đích hào hiệp chi sĩ.\n");
		return 0;
	end
	if me.nLevel < XiakeDaily.LEVEL_LIMIT or me.nFaction <= 0 then
		Dialog:Say("   Level chưa đủ hoặc chưa nhập Môn Phái.");
		return 0;
	end
	XiakeDaily:PredictAccept();
	local nTask1 = KGblTask.SCGetDbTaskInt(DBTASK_XIAKEDAILY_TASK_ID1);
	local nTask2 = KGblTask.SCGetDbTaskInt(DBTASK_XIAKEDAILY_TASK_ID2);
	local nFlag = XiakeDaily:GetTask(XiakeDaily.TASK_STATE);
	local nWeekTimes = XiakeDaily:GetWeekTimes();
	local nDayAcceptTimes = XiakeDaily:GetTask(XiakeDaily.TASK_ACCEPT_COUNT);
	if nFlag == 0 and nDayAcceptTimes > 0 and nWeekTimes < XiakeDaily.WEEK_MAX_TIMES then
		if nSure and nSure == 1 then
			local tbResult = Task:DoAccept(XiakeDaily.TASK_MAIN_ID, XiakeDaily.TASK_MAIN_ID);
			if not tbResult then
				Dialog:Say("Xin lỗi, nhiệm vụ của ngươi chưa làm xong ! không thể nhận nhiệm vụ");
				return 0;
			end
			if XiakeDaily.TASK_TREASUREMAP2_GROUPID[nTask1] then
				local nCount = me.GetTask(XiakeDaily.TASK_TREASUREMAP2_GROUPID[nTask1][1], XiakeDaily.TASK_TREASUREMAP2_GROUPID[nTask1][2]);
				if nCount < TreasureMap2.NUMBER_MAX_TREASURE_TIMES then
					me.SetTask(XiakeDaily.TASK_TREASUREMAP2_GROUPID[nTask1][1], XiakeDaily.TASK_TREASUREMAP2_GROUPID[nTask1][2], nCount+1);
				else
					me.Msg("Giới hạn Tàng Bảo Đồ đã đạt tối đa.");
				end
			end
			if XiakeDaily.TASK_TREASUREMAP2_GROUPID[nTask2] then
				local nCount = me.GetTask(XiakeDaily.TASK_TREASUREMAP2_GROUPID[nTask2][1], XiakeDaily.TASK_TREASUREMAP2_GROUPID[nTask2][2]);
				if nCount < TreasureMap2.NUMBER_MAX_TREASURE_TIMES then
					me.SetTask(XiakeDaily.TASK_TREASUREMAP2_GROUPID[nTask2][1], XiakeDaily.TASK_TREASUREMAP2_GROUPID[nTask2][2], nCount+1);
				else
					me.Msg("Giới hạn Tàng Bảo Đồ đã đạt tối đa.");
				end
			end
			local nTaskLogId = nTask1 + nTask2 * 100;
			StatLog:WriteStatLog("stat_info", "richangrenwu", "accept", me.nId,  me.GetHonorLevel(), nTaskLogId);
		else
			local nCount = XiakeDaily.AWARD_ONCE;
			local nWeekTimes = XiakeDaily:GetWeekTimes();
			if nWeekTimes + 1 == XiakeDaily.WEEK_MAX_TIMES then
				nCount = nCount + XiakeDaily.AWARD_EXTRA;
			end
			local szMsg = string.format("<newdialog><color=green>             Nhiệm vụ hiệp khách hôm nay \n\n<color>  <color=yellow>%s<color>   <color=yellow>%s<color>\n    %s     %s\n\n<color=green>Phần thưởng Nhiệm Vụ <color><item=18,1,1233,1><color=gold> X %s<color>", Lib:StrFillC(XiakeDaily.TaskFile[nTask1].szDynamicDesc,16), Lib:StrFillC(XiakeDaily.TaskFile[nTask2].szDynamicDesc,16), XiakeDaily.ID_TO_IMAGE[nTask1], XiakeDaily.ID_TO_IMAGE[nTask2], nCount);
			if nWeekTimes + 1 == XiakeDaily.WEEK_MAX_TIMES then
				if Item.tbStone:GetOpenDay() ~= 0 then
					szMsg = szMsg .. string.format("<item=18,1,1317,1><color=gold> X %s<color>", XiakeDaily.AWARD_STONE);
					szMsg = szMsg .. string.format("<item=18,1,1312,1,0,0,0,0,0,0,0,0,1><color=gold> X %s<color>", XiakeDaily.AWARD_STONE_KEY);
				end
			end
			local tbOpt = 
			{
				{"Đồng ý nhận", self.OnDialog_Accept, self, 1},
				{"Để ta suy nghĩ lại"},	
			};
			Dialog:Say(szMsg, tbOpt);
		end
	end
end

function tbClass:OnDialog_Finish()
	if XiakeDaily:CheckOpen() ~= 1 then
		Dialog:Say(" Nhiệm vụ hiện tại chưa mở\n");
		return 0;
	end
	if XiakeDaily:CheckTaskFinish() == 1 then
		--Task:CloseTask(XiakeDaily.TASK_MAIN_ID, "finish");
		XiakeDaily:ShowAwardDialog();
	end
end

function tbClass:OpenXiaKeShop()
	if XiakeDaily:CheckOpen() ~= 1 then
		Dialog:Say(" Nhiệm vụ hiện tại chưa mở");
		return 0;
	end
	me.OpenShop(190, 3);
end