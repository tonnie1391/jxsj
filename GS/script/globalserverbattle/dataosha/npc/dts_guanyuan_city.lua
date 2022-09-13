-- 文件名　：dts_guanyuan_city.lua
-- 创建者　：jiazhenwei
-- 创建时间：2009-10-13
-- 描  述  ：临安大逃杀接引


local tbNpc = Npc:GetClass("dataosha_city");

function tbNpc:OnDialog()
	DaTaoSha:PlayerOnLogin();
	local tbOpt = {};
	local szMsg = string.format("Bây giờ chưa đến thời gian tham gia hoạt động.\n\nThời gian hoạt động:\n<color=yellow>%s đến %s\n+ 10 giờ-14 giờ\n+ 18 giờ-23 giờ<color>\n\n<color=red>Lưu ý: Tối thứ 7 không mở.<color>", os.date("%Y-%m-%d",Lib:GetDate2Time(DaTaoSha.nStatTime)), os.date("%Y-%m-%d",Lib:GetDate2Time(DaTaoSha.nEndTime)));
	local nTime = tonumber(GetLocalDate("%H%M"));
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	local nWeek = tonumber(GetLocalDate("%w"));
	local nAllTimes = GetPlayerSportTask(me.nId,DaTaoSha.GBTSKG_DATAOSHA, DaTaoSha.GBTASKID_ATTEND_ALLNUM) or 0;
	local nGlobalBatch = GetPlayerSportTask(me.nId,DaTaoSha.GBTSKG_DATAOSHA, DaTaoSha.GBTASKID_BATCH) or 0;
	local nLimitTime = me.GetTask(DaTaoSha.TASKID_GROUP, DaTaoSha.TASKID_LIMIT_TIMES);
	local nTickets = me.GetTask(DaTaoSha.TASKID_GROUP, DaTaoSha.TASKID_TICKETS);	
	--传送
	if nGlobalBatch ~= DaTaoSha.nBatch then
		nAllTimes = 0;
	end
	if nDate >= DaTaoSha.nStatTime and nDate <= DaTaoSha.nEndTime then
		if (nTime >= DaTaoSha.OPENTIME[1] and nTime <= DaTaoSha.CLOSETIME[1]) or (nTime >= DaTaoSha.OPENTIME[2] and nTime <= DaTaoSha.CLOSETIME[2] and nWeek ~= 6) then
			szMsg = string.format("Chiến thần Lý Nhược Thủy và Tuyết Hồn đang ở Di tích Hàn Vũ, chờ chư vị đại hiệp đến tiếp nhận khiêu chiến\n\n<color=yellow>Tham gia 1 lần hoạt động sẽ tiêu hao 1 cơ hội khiêu chiến và tư cách khiêu chiến. Dùng Hàn Vũ Hồn Châu sẽ nhận được tư cách.<color>\n\n<color=yellow>Cơ hội khiêu chiến còn: %s lần\nTư cách khiêu chiến còn: %s lần\nSố lần đã tham gia: %s/%s lần<color>", nLimitTime - nAllTimes, nTickets - nAllTimes, nAllTimes, DaTaoSha.nMaxTime);
			table.insert(tbOpt,  {"Đến điểm báo danh Di tích Hàn Vũ", self.TransToServer, self  });
		end
	end
	--about
	table.insert(tbOpt,  {"Quy tắc hoạt động", self.Introduction, self});
	--领取本场
	table.insert(tbOpt,  {"Nhận phần thưởng", DaTaoSha.GetAwardForMe, DaTaoSha  });
	--领取终场
	if DaTaoSha:CheckFinalAwardDate() == 1 then
		table.insert(tbOpt,  {"Nhận phần thưởng cuối cùng", DaTaoSha.GetGlobalAwardForMe, DaTaoSha  });
	end	
	table.insert(tbOpt, {"Kết thúc đối thoại"});
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:BuyAge(bFlag)
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	if me.GetTask(2189, 520) == nDate then
		Dialog:Say("Mỗi ngày chỉ có thể mua được 1 lần.");
		return 0;
	end
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ 1 ô trống.");
		return 0;
	end
	if me.GetJbCoin() < 200 then
		Dialog:Say("Không đủ 200 đồng trong người.");
		return 0;
	end
	if not bFlag then
		Dialog:Say("<color=yellow>4月26日——5月2日期间<color>，每天可以在我这儿以<color=green>200金币的价格购买一个游龙阁开心蛋<color>，祝你天天开心哦。\n\n您是否确定花费<color=yellow>200金币<color>购买1个开心蛋？", {{"Xác nhận", self.BuyAge, self, 1},{"Để ta suy nghĩ thêm"}})
		return 0;
	end
	local bRet = me.ApplyAutoBuyAndUse(90, 1, 0);
	if (bRet == 1) then
		me.SetTask(2189, 520, nDate);
		Item:GetClass("youlongge_happyegg"):OnLoginDay(nUse);
		if me.GetTask(2106, 4) < 7 then
			me.SetTask(2106, 4, me.GetTask(2106, 4) + 1);
		end
		Dialog:Say("恭喜您成功购买了1个开心蛋");
	end
end

function tbNpc:TransToServer()
	local nAllTimes = GetPlayerSportTask(me.nId,DaTaoSha.GBTSKG_DATAOSHA, DaTaoSha.GBTASKID_ATTEND_ALLNUM) or 0;
	local nGlobalBatch = GetPlayerSportTask(me.nId,DaTaoSha.GBTSKG_DATAOSHA, DaTaoSha.GBTASKID_BATCH) or 0;
	local nLimitTime = me.GetTask(DaTaoSha.TASKID_GROUP, DaTaoSha.TASKID_LIMIT_TIMES);
	local nTickets = me.GetTask(DaTaoSha.TASKID_GROUP, DaTaoSha.TASKID_TICKETS);
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));	
	if nGlobalBatch ~= DaTaoSha.nBatch then
		nAllTimes = 0;
	end
	if nAllTimes >= DaTaoSha.nMaxTime then
		Dialog:Say("Đã đạt đến giới hạn, không thể tiếp tục tham gia.");
		return 0;
	end
	if nLimitTime <= 0 or nLimitTime <= nAllTimes then
		Dialog:Say("Đã hết lượt tham gia hôm nay, mai hãy quay lại.");
		return 0;
	end	
	if nTickets <= 0 or nTickets <= nAllTimes then
		Dialog:Say("Không có tư cách tham gia, có thể sử dụng Nguyệt Ảnh Thạch để mua Hàn Vũ Hồn Châu để nhận tư cách tham dự.");
		return 0;
	end
	if me.nLevel < DaTaoSha.PLAYER_ATTEND_LEVEL  then
		Dialog:Say(string.format("Đẳng cấp chưa đạt %s, không thể tham gia.",DaTaoSha.PLAYER_ATTEND_LEVEL));
		return;
	end
	if me.nFaction <= 0 then
		Dialog:Say("Chưa gia nhập môn phái, không thể tham gia.");
		return;
	end	
	Transfer:NewWorld2GlobalMap(me);
	me.SendMsgToFriend(string.format("%s tham gia “Di tích Hàn Vũ”", me.szName));
end

function tbNpc:Introduction(nFlag)	
	local szMsg = "Giới thiệu Di tích Hàn Vũ:"
	local tbOpt ={
		{"Thời gian hoạt động", self.Introduction, self, 1},
		{"Yêu cầu sự kiện", self.Introduction, self, 2},
		{"Tính lượt và Cách đăng ký", self.Introduction, self, 3},
		{"Các giai đoạn", self.Introduction, self, 4},
		{"Phần thưởng", self.Introduction, self, 5},
		{"Quay lại trang trước", self.OnDialog, self }
			};
	local tbMsg = {string.format("<color=green>Thời gian hoạt động:\n  <color>%s đến %s\n+ 10 giờ-14 giờ\n+ 18 giờ-23 giờ<color>\n\n<color=red>Lưu ý: Tối thứ 7 không mở.<color>",os.date("%Y-%m-%d",Lib:GetDate2Time(DaTaoSha.nStatTime)), os.date("%Y-%m-%d",Lib:GetDate2Time(DaTaoSha.nEndTime))),
		"<color=green>Yêu cầu sự kiện:\n  <color>Đạt cấp 60 và đã gia nhập môn phái.",
		string.format([[
		<color=green>Cách tính lượt tham gia:<color>		
	  Nhân sĩ được tăng <color=yellow>5 lượt<color> tham gia mỗi ngày, tối đa <color=yellow>15 lượt<color>. <color=yellow>Tham gia sự kiện cần 1 lượt tham gia và 1 tư cách tham gia<color>. Để nhận tư cách tham gia cần sử dụng <color=yellow>Hàn Vũ Hồn Châu<color>mua tại Long Ngũ Thái Gia. Trong thời gian sự kiện, tham gia tối đa là <color=yellow>%s lượt<color>.

		<color=green>Cách đăng ký: <color>
	  Nhân sĩ đủ điều kiện có thể tham gia ở <color=yellow>Cô bé bán diêm<color> tại Lâm An, hoặc gặp <color=yellow>Lý Nhược Thủy<color> tại Đảo Anh Hùng. Số lượng nhóm phải là 3 và chỉ có đội trưởng mới có quyền đăng ký. Dĩ nhiên vẫn có thể tham gia cá nhân, hệ thống sẽ tự bắt cặp.
		]],DaTaoSha.nMaxTime),
		
		[[
		<color=green>Giai đoạn chờ đợi: <color>
	  Sau khi đăng ký thành công, bạn sẽ vào khu vực chờ, khi có 66 người tại địa điểm, tất cả các hiệp sĩ sẽ được chia thành 22 nhóm để vào địa điểm tổ chức sự kiện.
		<color=green>Giai đoạn chuẩn bị:<color>
	  Thời gian chuẩn bị 3 phút để vào địa điểm tổ chức sự kiện. Các chiến binh có thể chọn môn phái thông qua lệnh bài môn phái trong hành trang. Và mở rương vào phút cuối của giai đoạn chuẩn bị để lấy đạo cụ.
		<color=green>Gian đoạn hoạt động:<color>
	  Hoạt động được chia thành ba giai đoạn, và trong mỗi giai đoạn, cần sống sót càng nhiều càng tốt. Ngoài vòng 3, đánh bại các NPC sẽ mang lại cho Hàn Vũ Phù Thạch.
		<color=green>Gian đoạn nghỉ ngơi:<color>
	  Sau vòng 1 và vòng 2 của sự kiện, sẽ có một khoảng thời gian nghỉ ngơi, các Thương nhân sẽ được làm mới tại điểm sinh của chiến binh, đồng thời có thể dùng Hàn Vũ Phù Thạch để mua vật phẩm.
		<color=green>Khác:<color>
	  Ở vòng 1 và vòng 2, chỉ cần có người trong đội sống sót đến hết màn này thì tất cả thành viên trong đội đều có thể bước vào màn tiếp theo. Ở vòng 3, nếu có nhiều hơn một đội còn lại trong giai đoạn thứ ba, sẽ không có người chiến thắng trong sự kiện này.
		]],
		string.format([[
		<color=green>Phần thưởng:<color>
	  1. Sau mỗi lượt tham gia, đối thoại với Cô bé bán diêm để nhận thưởng.
	  2. Sau khi kết thúc sự kiện, nhân vật đạt top 30 sẽ nhận được Tuyết Hồn Lệnh.
		<color=green>Thời gian nhận thưởng:<color>
	  %s đến %s

	]],os.date("%Y-%m-%d",Lib:GetDate2Time(DaTaoSha.DEF_GLOBALAWARD_DATE_BEGIN)), os.date("%Y-%m-%d",Lib:GetDate2Time(DaTaoSha.DEF_GLOBALAWARD_DATE_END))),
		}
	if nFlag then
		tbOpt = {{"Quay lại trang trước", self.Introduction, self }}
		szMsg = tbMsg[nFlag];
	end
	Dialog:Say(szMsg, tbOpt);
end
