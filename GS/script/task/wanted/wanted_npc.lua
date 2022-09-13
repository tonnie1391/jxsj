--官府通缉任务
--孙多良
--2008.08.06
Require("\\script\\task\\wanted\\wanted_def.lua");

function Wanted:OnDialog()
	local nFlag = self:Check_Task();
	if nFlag == 1 then
		self:OnDialog_Finish()
	elseif nFlag == 2 then
		local nSec = self:GetTask(self.TASK_ACCEPT_TIME);
		if nSec > 0 and tonumber(os.date("%Y%m%d",GetTime())) > tonumber(os.date("%Y%m%d",nSec)) then
			--如果任务已经过期但未完成；
			self:CancelTask(1);
			me.Msg("Thật không may, nhiệm vụ đã quá hạn hoàn thành. Phải hoàn thành nhiệm vụ trong ngày.");
			local tbOpt = {
				{"Ta muốn nhận nhiệm vụ mới", self.OnDialog, self},
				{"Ta chưa muốn nhận nhiệm vụ"},
				};
			Dialog:Say("Thật không may, nhiệm vụ đã quá hạn hoàn thành. Phải hoàn thành trong ngày.", tbOpt);
			return 0;
		end
		self:OnDialog_NoFinish();
	elseif nFlag == 3 then
		self:OnDialog_NoAccept();
	else
		self:OnDialog_Accept();
	end
end

function Wanted:OnDialog_Accept()
	local szMsg = string.format("Bổ Đầu Hình Bộ: Gần đây bọn Hải tặc luôn gây hại cho dân, ngươi có đồng ý giúp đỡ Nha Môn bắt giữ chúng để trừ hại cho dân?\n\n<color=yellow>\nThời gian bắt đầu: %s\nThời gian kết thúc: %s\n\nHôm nay ngươi còn %s lần<color>", Lib:HourMinNumber2TimeDesc(self.DEF_DATE_START), Lib:HourMinNumber2TimeDesc(self.DEF_DATE_END), self:GetTask(self.TASK_COUNT));
	
	if (EventManager.IVER_bOpenWantedLimitTime == 0) then
		szMsg = string.format("Bổ Đầu Hình Bộ: Gần đây bọn Hải tặc luôn gây hại cho dân, ngươi có đồng ý giúp đỡ Nha Môn bắt giữ chúng để trừ hại cho dân?\n\n<color=yellow>Hôm nay ngươi còn %s lần<color>", self:GetTask(self.TASK_COUNT));
	end

	local tbOpt = {
		{"Ta muốn truy bắt Hải Tặc", self.SingleAcceptTask, self},
		{"Dùng Danh Bổ Lệnh Đổi phần thưởng", self.OnGetAward, self},
		{"Ta muốn đổi Ấn", self.OnGetAwardCallBoss, self},
		{"Ta muốn suy nghĩ thêm"},
	}
	if me.IsCaptain() == 1 then
		table.insert(tbOpt, 1, {"Ta muốn cùng đồng đội truy bắt Hải Tặc", self.CaptainAcceptTask, self})
	end
	Dialog:Say(szMsg, tbOpt);
end

function Wanted:OnDialog_NoAccept()
	local szMsg = string.format("Bổ Đầu Hình Bộ: Gần đây bọn Hải tặc luôn gây hại cho dân, ngươi có đồng ý giúp đỡ Nha Môn bắt giữ chúng để trừ hại cho dân? Nhưng ta thấy ngươi vẫn chưa đủ thực lực, sau khi đạt cấp 50 hãy quay lại tìm ta.");
	local tbOpt = {
		{"Tôi biết rồi"},
	}
	Dialog:Say(szMsg, tbOpt);
end

function Wanted:OnDialog_Finish()
	local nTask = Task:GetPlayerTask(me).tbTasks[self.TASK_MAIN_ID].nReferId;
	local szMsg = self:CreateText(nTask)
	local tbOpt = {
		{"Hoàn thành nhiệm vụ, đến nhận thưởng", self.FinishTask, self},
		{"Dùng Danh Bổ Lệnh Đổi phần thưởng", self.OnGetAward, self},
		{"Ta muốn đổi Ấn", self.OnGetAwardCallBoss, self},
		{"Ta muốn suy nghĩ thêm"},	
	}
	Dialog:Say(szMsg, tbOpt);
end

function Wanted:OnDialog_NoFinish()
	local nTask = Task:GetPlayerTask(me).tbTasks[self.TASK_MAIN_ID].nReferId;
	local szMsg = self:CreateText(nTask)
	local tbOpt = {
		{"Ta muốn hủy nhiệm vụ", self.CancelTask, self},
		{"Dùng Danh Bổ Lệnh Đổi phần thưởng", self.OnGetAward, self},
		{"Ta muốn đổi Ấn", self.OnGetAwardCallBoss, self},
		{"Ta muốn suy nghĩ thêm"},	
	};
	Dialog:Say(szMsg, tbOpt);
end

function Wanted:CreateText(nTask)
	local szMsg = string.format("Tên nhiệm vụ: [<color=green>Tuy bắt Hải Tặc %s<color>]\nMiêu tả nhiệm vụ: Nghe nói<color=green> Hải Tặc %s<color> gần đây xuất hiện tại <color=yellow>%s<color>, tọa độ <color=yellow>(%s,%s)<color>, ngươi phải truy bắt hắn về quy án, khôi phục an ninh nơi đó.",self.TaskFile[nTask].szTaskName, self.TaskFile[nTask].szTaskName, self.TaskFile[nTask].szMapName, math.floor(self.TaskFile[nTask].nPosX/8), math.floor(self.TaskFile[nTask].nPosY/16));
	return szMsg;	
end

function Wanted:OnGetAward()
	local szMsg = "Bổ Đầu Hình Bộ: Bọn Hải tặc đã bị bắt về quy án, triều đình ban thưởng. Các vị đại hiệp có thể đem Danh Bổ Lệnh đến đổi phần thưởng.";
	local tbOpt = 
	{
		{"Ta muốn đổi Võ Lâm Mật Tịch (sơ)",self.OnGift, self, self.ITEM_WULINMIJI},
		{"Ta muốn đổi Tẩy Tủy Kinh (sơ)",self.OnGift, self, self.ITEM_XISUIJING},
		{"Để ta suy nghĩ đã"}
	}
	Dialog:Say(szMsg, tbOpt);
end

function Wanted:OnGift(tbItem)
	local tbParam = {
		tbAward = {
			{
				nGenre 		= tbItem[1][1],
				nDetail 	= tbItem[1][2],
				nParticular = tbItem[1][3],
				nLevel 		= tbItem[1][4],
				nCount		= 1,
			}
		},
		tbMareial = {
			{
				nGenre 		= self.ITEM_MINGBULING[1], 
				nDetail 	= self.ITEM_MINGBULING[2], 
				nParticular = self.ITEM_MINGBULING[3], 
				nLevel 		= self.ITEM_MINGBULING[4],
				nCount		= tbItem[2],
			}
		}
		};
	local szContent = string.format("\nĐổi <color=yellow>%s<color> cần <color=yellow>%s<color> <color=yellow>%s<color>", KItem.GetNameById(unpack(tbItem[1])),tbItem[2], KItem.GetNameById(unpack(self.ITEM_MINGBULING)));
	Wanted.Gift:OnOpen(szContent, tbParam)
end

function Wanted:OnGetAwardCallBoss(nSure)
	if nSure == 1 then
		if me.CountFreeBagCell() < 1 then
			Dialog:Say("Khoảng trống trong túi không đủ, hãy để trống ít nhất 1 ô");
			return 0;
		end
		if me.dwCurGTP < self.DEF_PAYGTP then
			Dialog:Say(string.format("Hoạt lực của bạn không đủ %s điểm, cần %s điểm Tinh Lực và %s điểm Hoạt Lực ", self.DEF_PAYGTP, self.DEF_PAYGTP, self.DEF_PAYMKP));
			return 0;
		end
		if me.dwCurMKP < self.DEF_PAYMKP then
			Dialog:Say(string.format("Tinh lực của bạn không đủ %s điểm, cần %s điểm Tinh Lực và %s điểm Hoạt Lực ", self.DEF_PAYMKP, self.DEF_PAYGTP, self.DEF_PAYMKP));	
			return 0;
		end		
		
		for nLevel=1, 5 do
			local tbItem = me.FindItemInBags(self.ITEM_MINGBUXIANG[1],self.ITEM_MINGBUXIANG[2],self.ITEM_MINGBUXIANG[3],nLevel);
			if #tbItem <= 0 then
				Dialog:Say(string.format([[  Để đổi <color=yellow> Phong Ấn Hắc Ám <color> cần <color=yellow>:
					
    Các mảnh Ấn (Kim)
    Các mảnh Ấn (Mộc)
    Các mảnh Ấn (Thủy)
    Các mảnh Ấn (Hỏa)
    Các mảnh Ấn (Thổ)
    Tinh lực %s
    Hoạt lực %s
    <color>
  Thiếu nguyên liệu, bạn không thể mua lại.
		]], self.DEF_PAYGTP, self.DEF_PAYMKP));
				return 0;
			end
		end
		
		me.ChangeCurGatherPoint(-self.DEF_PAYGTP);		--减精力
		me.ChangeCurMakePoint(-self.DEF_PAYMKP);		--减活力
		for nLevel=1, 5 do
			me.ConsumeItemInBags2(1, self.ITEM_MINGBUXIANG[1],self.ITEM_MINGBUXIANG[2],self.ITEM_MINGBUXIANG[3], nLevel);
		end
		local tbItemInfo = {bForceBind=1};
		local pItem = me.AddItemEx(self.ITEM_CALLBOSSLP[1],self.ITEM_CALLBOSSLP[2],self.ITEM_CALLBOSSLP[3],self.ITEM_CALLBOSSLP[4], tbItemInfo);
		if not pItem then
			Dbg:WriteLog("Wanted", "ChangeCallBoss", "AddItem Not!!!", me.szName);
		end
		
		local tbOpt = {
			{"Tiếp tục đổi", self.OnGetAwardCallBoss, self},
			{"Ta không muốn"},
		}
		Dialog:Say("Ngươi có muốn tiếp tục đổi?", tbOpt);
		return 0;
	end
	local szMsg = string.format([[  Để đổi <color=yellow> Phong Ấn Hắc Ám <color> cần <color=yellow>:
		
    Mảnh Phong Ấn (Kim)
    Mảnh Phong Ấn (Mộc)
    Mảnh Phong Ấn (Thủy)
    Mảnh Phong Ấn (Hỏa)
    Mảnh Phong Ấn (Thổ)
    %s điểm Tinh Lực
    %s điểm Hoạt Lực
    <color>
  Ngươi có muốn đổi không?. 
		]], self.DEF_PAYGTP, self.DEF_PAYMKP);
	local tbOpt = {
			{"Tôi chắc chắn muốn đổi", self.OnGetAwardCallBoss, self, 1},
			{"Thôi sợ quá, không đổi nữa"},
		};
	Dialog:Say(szMsg, tbOpt);
end
