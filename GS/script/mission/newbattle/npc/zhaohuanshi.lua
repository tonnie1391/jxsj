-- 文件名　：zhaohuanshi.lua
-- 创建者　：LQY
-- 创建时间：2012-07-22 08:42:01
-- 说　　明：召唤师

local tbNpc = Npc:GetClass("NewBattle_zhaohuanshi")

function tbNpc:OnDialog()
	local tbInfo = him.GetTempTable("Npc");
	local nPower = nil;
	if NewBattle.Mission:IsOpen() == 1 then
		nPower = NewBattle.Mission:GetPlayerGroupId(me);
	end
	if nPower == -1 or nPower ~= tbInfo.nPower then
		Dialog:Say("Cha chả! Sao ngươi lại lẻn vào được nơi đây? Người đâu, bắt hắn lại!");
		return;
	end	
	local szDialogMsg = "Tráng sĩ, ngươi muốn đến đâu? Ta sẽ đưa ngươi 1 đoạn.";
	local tbDialogOpt = {
		{"Đến <color=yellow>Đá Triệu Hồi<color>", self.GoTransfer, self},
		{"Hướng dẫn <color=yellow>Băng Hỏa Liên Thành<color>", self.Guize,self},
		{"Quay về nơi báo danh", self.GoBaoMingDian, self, nPower},
		};	
	if tbInfo.nIo == 0 then		--大营召唤师
		table.insert(tbDialogOpt,{"Về đại bản doanh",self.GoBackCamp,self});
	end
	table.insert(tbDialogOpt,{"Ta chỉ đến xem thôi"});
	Dialog:Say(szDialogMsg, tbDialogOpt);
end

--传送到前线
function tbNpc:GoTransfer()
	if NewBattle.nBattle_State ~= NewBattle.BATTLE_STATES.FIGHT then
		Dialog:Say("Chưa đến giai đoạn chiến đấu, không thể truyền tống.");
		return;
	end
	local tbInfo	=	him.GetTempTable("Npc");
	local nPower = NewBattle.Mission:GetPlayerGroupId(me);
	if nPower == -1 or nPower ~= tbInfo.nPower  or NewBattle.Mission.nTransStoneOwner ~= nPower then
		Dialog:Say("Xin lỗi, <color=yellow>Đã Triệu Hồi<color> chưa được chiếm lĩnh.");
		return;
	end
	local tbPlayer = NewBattle.Mission.tbCPlayers[me.nId];
	if not tbPlayer then
		Dialog:Say("Ai đó???");
		return;
	end
	local n, nSec = tbPlayer:CanUseStone();
	if n == 0 then
		Dialog:Say(string.format("Hãy đợi thêm <color=red>%d giây<color> để truyền tống.", nSec));
		return;
	end
	GeneralProcess:StartProcess("Đang truyền tống...",5 * 18, {self.GoTransferProcess, self, me.nId, tbInfo.nPower}, nil, NewBattle.tbCarrierBreakEvent);

end
--传送到前线读条回调
function tbNpc:GoTransferProcess(nPlayerId, nNpcPower)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end	
	local nPower = NewBattle.Mission:GetPlayerGroupId(pPlayer);
	if nPower == -1 or nPower ~= nNpcPower  or NewBattle.Mission.nTransStoneOwner ~= nPower then
		Dialog:Say("Xin lỗi, <color=yellow>Đá Triệu Hồi<color> chưa được chiếm lĩnh.");
		return;
	end		
	me.SetFightState(1);
	me.Msg("冰与火的召唤~~");
	Player:AddProtectedState(me,NewBattle.PLAYERPROTECTEDTIME);
	me.NewWorld(NewBattle.Mission.nMapId,unpack(NewBattle:GetRandomPoint(NewBattle.POS_CHUANSONG)));
end

--传送到大营 作废
function tbNpc:GoCamp()
	local tbInfo	= him.GetTempTable("Npc");
	local nPower 	= NewBattle.Mission:GetPlayerGroupId(me);
	local szPower	= NewBattle.POWER_ENAME[nPower];
	if nPower == -1 or nPower ~= tbInfo.nPower then
		Dialog:Say("Ai đó???");
		return;
	end
	me.SetFightState(1);
	me.NewWorld(NewBattle.Mission.nMapId,unpack(NewBattle:GetRandomPoint(NewBattle.POS_BRON[szPower])));
end

--传送到保护区 作废
function tbNpc:GoBackCamp()
	local tbInfo	= him.GetTempTable("Npc");
	local nPower 	= NewBattle.Mission:GetPlayerGroupId(me);
	local szPower	= NewBattle.POWER_ENAME[nPower];
	if nPower == -1 or nPower ~= tbInfo.nPower then
		Dialog:Say("Ai đó???");
		return;
	end
	me.SetFightState(0);
	me.NewWorld(NewBattle.Mission.nMapId,unpack(NewBattle:GetRandomPoint(NewBattle.POS_READY[szPower])));
end

--回到报名点
function tbNpc:GoBaoMingDian(nPower)
	me.SetFightState(0);
	NewBattle:MovePlayerOut(me, nPower)
end

-- 战场规则
function tbNpc:Guize()
	Dialog:Say([[
		
				    <color=yellow>Giới thiệu Băng Hỏa Liên Thành:<color>	
							
				· Mỗi ngày nhận 2 rương thuốc miễn phí.
				   
				· Sau khi khai cuộc doanh trại 2 bên sẽ xuất hiện <color=blue>Chiến Xa, Tháp Tiễn, Tháp Pháo<color>. Người chơi sử dụng Chiến Xa để phá công trình đối phương. Ấn <color=red>phím “N”<color> để thao tác nhanh với công trình.
				   
				· Trung tâm có <color=blue>Đá Triệu Hồi<color>, sau khi chiếm lĩnh sẽ có thể đến <color=blue>Triệu Hồi Sư<color> để đến Đá Triệu Hồi nhanh chóng.
				   
				· Hạ gục <color=blue>người chơi, chiến xa, NPC<color> để nhận <color=red>tích lũy<color>, bảo vệ <color=blue>Tháp Pháo, Long Mạch<color> cũng có thể nhận tích lũy.
   	]]
		, {"Trang sau", self.Guize2, self});
end

-- 战场规则
function tbNpc:Guize2()
	Dialog:Say([[
		
				    <color=yellow>Giới thiệu Băng Hỏa Liên Thành:<color>	
				  
				· Người chơi <color=red>không thể tấn công<color> được <color=blue>Tháp Tiễn, Tháp Pháo và Long Mạch<color>, chỉ có thể dùng <color=red>Chiến Xa<color> mới có thể phá hủy <color=blue>Tháp Tiễn, Tháp Pháo và Long Mạch<color>
				  
				· Bất kỳ <color=yellow>Long Mạch<color> phe nào bị hủy, phe đã phá hủy Long Mạch của đối phương sẽ dành <color=red>chiến thắng<color>.
				  
				· Khi bắt đầu trận chiến Long Mạch được <color=red>trạng thái bảo vệ<color>, chỉ có phá hủy Tháp Pháo, hạ <color=blue>Long Mạch Hộ Thủ<color> mới có thể tấn công Long Mạch.
   	]]
		, {"Trang trước", self.Guize, self});
end
