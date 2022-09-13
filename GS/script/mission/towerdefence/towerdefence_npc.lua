--竞技赛npc
--孙多良
--2008.12.25

--报名
function TowerDefence:OnDialog_SignUp(nSure)
	
	if self:CheckState() == 0 then
		Dialog:Say("Hoạt động đã kết thúc.")
		return 0;
	end
	
	
	if self.nReadyTimerId <= 0 or Timer:GetRestTime(self.nReadyTimerId) <= TowerDefence.DEF_READY_TIME_ENTER  then
		Dialog:Say("Thời gian thi đấu <color=yellow>10:00 - 14:00 và 17:00 - 23:00<color>; Báo danh trong 4 phút 30 giây.\n\n<color=red>Lúc này không thể đăng ký.<color>");
		return 0;
	end
	
	if me.nTeamId <= 0 then
		if nSure == 1 then
			self:OnDialogApplySignUp();
			return 0;
		end		
		if me.nLevel < self.DEF_PLAYER_LEVEL or me.nFaction <= 0 then
			Dialog:Say("Cấp độ phải lớn hơn 60 và đã gia nhập môn phái.");
			return 0;
		end
		if self:IsSignUpByAward(me) == 1 then
			Dialog:Say("Phần thưởng lần thi đấu trước vẫn chưa nhận!");
			return 0;
		end		
		if self:IsSignUpByTask(me) == 0 then
			Dialog:Say("Hôm nay ngươi đã tham gia quá nhiều, hãy nghỉ ngơi.");
			return 0;
		end
		
		if me.GetEquip(Item.EQUIPPOS_MASK) then
			Dialog:Say("Không được mang Mặt nạ khi tham gia trò chơi.");
			return 0;
		end	
		local tbOpt = {
			{"Ta muốn tham gia", self.OnDialog_SignUp, self, 1},
			{"Để ta suy nghĩ lại"},
			};
		Dialog:Say("Ngươi muốn tham gia chứ?", tbOpt);
		return 0;
	end
	

	if me.IsCaptain() == 0 then
		Dialog:Say("Không phải đội trưởng, không thể đăng ký.");
		return 0;
	end
	local tbPlayerList = KTeam.GetTeamMemberList(me.nTeamId);
	
	if nSure == 1 then
		self:OnDialogApplySignUp(tbPlayerList);
		return 0;
	end
	
	local tbOpt = {
		{"Đưa chúng tôi đi", self.OnDialog_SignUp, self, 1},
		{"Để chúng tôi xem xét lại"},
		};
	Dialog:Say(string.format("Đội của ngươi có <color=yellow>%s người<color>, chắc chắn tham gia chứ?", #tbPlayerList), tbOpt);
	return 0;
end

function TowerDefence:OnDialogApplySignUp(tbPlayerList)	
	if not tbPlayerList then
		GCExcute{"TowerDefence:ApplySignUp",{me.nId}};
		return 0;
	end
	if Lib:CountTB(tbPlayerList) > self.DEF_PLAYER_TEAM then
		Dialog:Say("Nhóm của ngươi quá nhiều người, tối đa là 4 người thôi.");
		return 0;
	end
	local nMapId, nPosX, nPosY	= me.GetWorldPos();
	for _, nPlayerId in pairs(tbPlayerList) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if not pPlayer then
			Dialog:Say("Không thể bắt đầu.");
			return 0;
		end		
		if pPlayer.nLevel < self.DEF_PLAYER_LEVEL or pPlayer.nFaction <= 0 then
			Dialog:Say(string.format("Đồng đội <color=yellow>%s<color> chưa đủ điều kiện tham gia.", pPlayer.szName));
			return 0;
		end
		if self:IsSignUpByAward(pPlayer) == 1 then
			Dialog:Say(string.format("<color=yellow>%s<color> chưa nhận thưởng đợt trước.", pPlayer.szName));
			return 0;
		end				
		
		if self:IsSignUpByTask(pPlayer) == 0 then
			Dialog:Say(string.format("<color=yellow>%s<color>đã hết lượt tham gia.", pPlayer.szName));
			return 0;
		end
		if pPlayer.GetEquip(Item.EQUIPPOS_MASK) then
			Dialog:Say(string.format("%s đang trang bị Mặt nạ", pPlayer.szName));
			return 0;
		end
		local nMapId2, nPosX2, nPosY2	= pPlayer.GetWorldPos();
		local nDisSquare = (nPosX - nPosX2)^2 + (nPosY - nPosY2)^2;
		if nMapId2 ~= nMapId or nDisSquare > 400 then
			Dialog:Say("Đồng đội không ở quanh đây.");
			return 0;
		end
		if not pPlayer or pPlayer.nMapId ~= nMapId then
			Dialog:Say("Đồng đội không ở quanh đây.");
			return 0;
		end
	end
	GCExcute{"TowerDefence:ApplySignUp", tbPlayerList};
	return 0;
end

function TowerDefence:IsSignUpByTask(pPlayer)
	TowerDefence:TaskDayEvent();
	local nCount = pPlayer.GetTask(self.TSK_GROUP, self.TSK_ATTEND_COUNT);
	local nExCount = pPlayer.GetTask(self.TSK_GROUP, self.TSK_ATTEND_EXCOUNT)
	if nCount <= 0 and nExCount <= 0 then
		return 0, 0 ,0;
	end
	return nCount + nExCount, nCount, nExCount;
end

function TowerDefence:IsSignUpByAward(pPlayer)
	return pPlayer.GetTask(self.TSK_GROUP, self.TSK_ATTEND_AWARD);
end

function TowerDefence:Npc_ProductTD()
	local tbITem = Item:GetClass("td_fuzou");
	local szMsg = "Tại đây ngươi có thể cải tạo Hồn Tổ Tiên giúp dễ dàng dành chiến thắng hơn.";
	local tbOpt = {
		{"Tìm hiểu hoạt động", TowerDefence.OnAbout, TowerDefence},
		{"Tiến hành cải tạo", tbITem.OpenProduct, tbITem, 1},
		{"Ta chỉ xem qua"},
	};
	Dialog:Say(szMsg, tbOpt);
end

function TowerDefence:OnAbout()
	local szMSg = "Xin chào! Ngươi cần biết điều gì?";
	local tbOpt = {};
	for i, tbMsg in pairs(self.tbAbout) do
		table.insert(tbOpt, {tbMsg[1], self.AboutInfo, self, i});
	end
	table.insert(tbOpt, {"Tôi hiểu"});
	Dialog:Say(szMSg, tbOpt);
end

function TowerDefence:AboutInfo(nSel)
	local szMSg = self.tbAbout[nSel][2];
	Dialog:Say(szMSg,{{"Ta hiểu rồi", self.OnAbout, self}});
end

TowerDefence.tbAbout = {
{"Thời gian sự kiện",string.format([[11:00~14:00; 17:00~23:00]])
},
{"Cách thức đăng ký",[[
    Sau khi hoạt động mở ra, người chơi cấp 30 trở lên có thể đến các thôn tân thủ tìm Án Nhược Tuyết báo danh tham gia, ngày hoạt động mỗi ngày có 2 cơ hội. Tham gia thi đấu phải có Tổ Tiên Bảo Hộ riêng, Tổ Tiên Bảo Hộ có thể dùng phương thức nhất định thu được, đồng thời còn có thể tiến hành cải tạo thêm, làm cho nó có các loại năng lực đặc thù.]]
},
{"Làm thế nào để có Tổ Tiên Bảo Hộ",[[
    Cách lấy Tổ Tiên Bảo Hộ: Mua Tổ Tiên Bảo Hộ ở cửa hàng nơi Án Nhược Tuyết, bạn có thể bỏ ra 500 đồng thăng cấp lên Tổ Tiên Bảo Hộ-Phượng Hoàng.]]
},
{"Cải tạo Tổ Tiên Bảo Hộ",[[
    Tổ Tiên Bảo Hộ có 5 loại kỹ năng để lựa chọn
    <color=yellow>Có thể lựa chọn:<color>
    -Định: Gây sát thương và định thân mục tiêu
    -Lui: Gây sát thương và đẩy lùi mục tiêu；
    -Chậm: Gây sát thương và làm chậm mục tiêu；
    -Loạn: Gây sát thương và hỗn loạn mục tiêu；
    -Ngất: Gây sát thương và làm choáng mục tiêu；
    
	<color=yellow>Lưu ý: <color>Tổ Tiên Bảo Hộ và Tổ Tiên Bảo Hộ-Phượng Hoàng khác nhau chính là Tổ Tiên Bảo Hộ bình thường chỉ có thể cải tạo một loại kỹ năng công kích, mà Tổ Tiên Bảo Hộ-Phượng Hoàng có thể đồng thời lựa chọn cải tạo hai loại kỹ năng.]]
},
{"Nội dung trò chơi",[[
    Quái vật từ khu vực bắt đầu tiến vào khu vực, sau đó di chuyển dọc theo hai bên thông đạo, tổng số quái vật ở mỗi bên đều giống nhau, đi đến khu vực tranh đoạt hội hợp, sau đó dừng lại một chút, sẽ đi ra khỏi điểm kết thúc, quái vật biến mất.
	
    Sau khi cấp độ mở ra, 30 giây sau bắt đầu đánh quái, quái vật mỗi một phút xuất hiện một lần, tổng cộng 12 lần, trong đó Tinh anh và Thủ lĩnh sẽ phóng thích kỹ năng công kích phạm vi để thương tổn thực vật. Người chơi tấn công quái vật bằng cách trồng cây. Nếu một lượt quái vật nhanh chóng kết thúc, sau đó ngay lập tức làm mới một lượt.
	
    Trong quá trình thi đấu, mua thực vật cần dùng quân bàn trong bản đồ ngũ độc bí thuật thương nhân mua, mỗi một đợt quái sau khi bị tiêu diệt tất cả người chơi đều sẽ đạt được quân phí. Các khoản kiếm được sẽ được hiển thị trong thời gian thực trên giao diện khách hàng để người chơi có thể biết số lượng quân đội hiện tại của họ.]]
},
{"Cách thức tính thắng bại",[[
    Người chơi tiêu diệt quái vật sẽ nhận được điểm, sau khi hoạt động kết thúc dựa trên thứ hạng điểm mà người chơi kiếm được, nhận phần thưởng.]]
},
}
