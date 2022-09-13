local tbNpc = Npc:GetClass("yijunshouling");

tbNpc.nTaskGroupId 		= 1021;
tbNpc.nTaskValueId		= 7;
tbNpc.nTmpDeadline		= 80204;	-- 2000年2月4日以后不会再送紫装
tbNpc.nNoviceLevelLimit = 80;		-- 新手buff领取等级限制
tbNpc.nNoviceBuffId		= 1972;		-- 新手buffid
tbNpc.nNoviceBuffTime	= 90 * 60 * 18;

function tbNpc:OnDialog()
	local nTaskValue = me.GetTask(self.nTaskGroupId, self.nTaskValueId);
	local nHasPrimerTask = me.GetTask(1025,33);	--是否有试练山庄任务
	local szDialogMsg = "Võ Lâm nay đã khác xưa, thiếu chủ phiêu bạc một mình bên ngoài, tuy có huynh đệ nghĩa quân khắp nơi giúp đỡ, ta cũng khó yên lòng…Trong lúc theo đuổi võ học, cũng cần giữ hiệp nghĩa không quên. Giang hồ xa xăm, hãy tự chăm sóc mình, đừng để ta lo lắng.";
	local tbDialogOpt = {};
	table.insert(tbDialogOpt, {"Tiêu hủy đạo cụ",  Dialog.Gift, Dialog, "Task.DestroyItem.tbGiveForm"})
	
	if SpecialEvent.NewServerEvent:IsEventOpen() == 1 then	--新服固定家族活动
		table.insert(tbDialogOpt,{"<color=yellow>2 Tuần Mở Server<color>",SpecialEvent.NewServerEvent.OnNewEvent,SpecialEvent.NewServerEvent});
	end
	if (tonumber(GetLocalDate("%y%m%d")) <= self.nTmpDeadline) then
	 	-- TODO: ZBL	仅作内网测试用
		local tbNpcBai = Npc:GetClass("tmpnpc");
		table.insert(tbDialogOpt, {"Mông Cổ Tây Hạ chuyên dùng phương án thể nghiệm nhân vật", tbNpcBai.OnDialog, tbNpcBai});
		table.insert(tbDialogOpt, {"Lập gia tộc", Kin.DlgCreateKin, Kin});
		table.insert(tbDialogOpt, {"Lập bang hội", Tong.DlgCreateTong, Tong});
	end
	if me.nLevel < self.nNoviceLevelLimit then
		table.insert(tbDialogOpt, {"<color=green>Nhận chúc phúc của Thu Lâm<color>", self.GainNoviceBuff, self});
	end

	table.insert(tbDialogOpt, {"<color=yellow>Về Đào Khê Trấn<color>", self.ComeBackNewVillage, self});
	
	table.insert(tbDialogOpt, {"Kết thúc đối thoại"});
	Dialog:Say(szDialogMsg, tbDialogOpt);
end;

function tbNpc:ComeBackNewVillage(nSure)
	if not nSure then
		local szMsg = "Thiếu hiệp, ngươi đã phiêu bạc một mình nhiều năm rồi, nếu ngươi muốn trở lại Đào Khê Trấn, Thu Di có thể nhờ người đánh xe tình nguyện đưa ngươi trở lại Đào Khê Trấn, tuy nhiên ngươi phải trả cho người đánh xe 2000 lượng bạc. Bạn có muốn vào đó ngay bây giờ không? ";
		local tbOpt = 
		{
			{"Ta đồng ý", self.ComeBackNewVillage, self, 1},
			{"Để ta suy nghĩ thêm"}		
		};
		Dialog:Say(szMsg, tbOpt);
		return;
	end	
	if me.nCashMoney < 2000 then
		Dialog:Say("Bạc trên người không đủ, cần tốn 2000 bạc.");
		return;
	end
	if me.CostMoney(2000, Player.emKPAY_EVENT) == 1 then
		me.SetTask(2027,230,1);
		me.NewWorld(2154,1814,3476);
	end
end

function tbNpc:GainNoviceBuff(nSure)
	if not nSure then
		if me.nLevel >= self.nNoviceLevelLimit then
			Dialog:Say("Mấy ngày không gặp, võ công của thiếu chủ đã có tiến bộ, sẽ bài xích chân khí bên ngoài, khó lòng truyền chân khí hộ thể cho người. Nhưng với võ công hiện thời của người, hành tẩu giang hồ sẽ không có gì khó, cố gắng tu luyện, ắt sẽ thành danh trên giang hồ.");
			return;
		end
		local szMsg = "Thiếu chủ, người một mình phiêu bạt thật không dễ, Thu Lâm tuy không thể đi theo bên cạnh, nhưng có thể truyền một đạo chân khí hộ thể cho người, có thể hỗ trợ được cho người khi gặp nguy hiểm, thế nào?\nCó muốn nhận <color=gold>Chân khí hộ thể<color>?";
		local tbOpt = 
		{
			{"Được rồi, đa tạ Thu Lâm", self.GainNoviceBuff, self, 1},
			{"Không cần đâu, ta muốn dựa vào sức mình để phiêu bạt một phen"}		
		};
		Dialog:Say(szMsg, tbOpt);
		return;
	end
	if me.nLevel >= self.nNoviceLevelLimit then
		Dialog:Say("Thiếu chủ, nội công của người đã có tiến bộ, sẽ bài xích chân khí bên ngoài, khó có thể truyền chân khí hộ thể cho người.");
		return;
	end
	local nLevel = math.ceil(me.nLevel / 10)
	me.AddSkillState(self.nNoviceBuffId, nLevel, 1, self.nNoviceBuffTime, 1, 1);
	me.Msg(string.format("Đã nhận <color=yellow>Chân khí hộ thể cấp %s<color>, tự biến mất sau khi trên mạng <color=yellow>1,5 giờ<color>, dưới <color=yellow>cấp 50<color> có thể đến Tân Thủ Thôn tìm Bạch Thu Lâm để nhận.", nLevel));
end
