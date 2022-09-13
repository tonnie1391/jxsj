local tbNpc = Npc:GetClass("guanxian");

function tbNpc:OnDialog()
	Dialog:Say("    Thành tích đạt được trong lãnh thổ xuất sắc trong trận chiến để giúp các nhà lãnh đạo và các cổ đông của từng thành viên thực hiện của tôi trong giải quyết công việc liên quan đến chức danh, và mua con dấu chính thức.\n    Các cấp bậc trưởng tự động, băng nhóm và xếp hạng tương quan xếp hạng.\n    Đồng cổ đông, thành viên của các chức danh do trụ sở chính thông qua các cấp.",
		{
			{"Bảo vệ quan hàm", self.DlgOfficialMaintain, self},
			{"Điều chỉnh cấp quan hàm bang", self.DlgIncreaseOfficialLevel, self},
			{"Điều chỉnh mức độ xếp hạng bang hội", self.DlgChoseOfficialLevel, self},
			{"Danh vọng lãnh thổ tạp hóa", self.OnOpenShop, self},
			{"Ta chỉ đi dạo"},
		})
end

function tbNpc:OnOpenShop()
	local nSeries = me.nSeries;
	if (nSeries == 0) then
		Dialog:Say("Bạn hãy gia nhập phái");
		return;
	end
	
	if (1 == nSeries) then
		me.OpenShop(149, 3);
	elseif (2 == nSeries) then
		me.OpenShop(150, 3);
	elseif (3 == nSeries) then
		me.OpenShop(151, 3);
	elseif (4 == nSeries) then
		me.OpenShop(152, 3);
	elseif (5 == nSeries) then
		me.OpenShop(153, 3);
	else
		Dbg:WriteLogEx(Dbg.LOG_INFO, "Quan Lãnh Thổ", me.szName, "Bạn chưa gia nhập phái", nSeries);
	end
end

-- 申请帮会官衔晋级
function tbNpc:DlgIncreaseOfficialLevel(nConfirm)
	local pTong = KTong.GetTong(me.dwTongId);
	if not pTong then
		Dialog:Say("Bạn chưa gia nhập Bang hội nên không thể thao tác");
		return 0;
	end
	
	local nKinId, nMemberId = me.GetKinMember();
	if Tong:CheckPresidentRight(me.dwTongId, nKinId, nMemberId) ~= 1 then
		Dialog:Say("Chỉ có thủ lĩnh mới có quyền điều chỉnh mức độ xếp hạng bang hội");
		return 0;
	end
	
	local nTongLevel = pTong.GetPreOfficialLevel();
	local nMaxTongLevel = pTong.GetOfficialMaxLevel();
	local nMaxLevelByDomain = Tong:GetMaxLevelByDomain(me.dwTongId);
	local nLevel = nMaxTongLevel + 1;
	local nMoney = Tong.TONG_OFFICIAL_LEVEL_CHARGE[nLevel];

	local nIncreaseNo = pTong.GetIncreaseOfficialNo();
	local nCurNo = KGblTask.SCGetDbTaskInt(DBTASK_OFFICIAL_MAINTAIN_NO);
	if nCurNo + 1 == nIncreaseNo then
		Dialog:Say("Bang hội của bạn tuần này đã cắt giảm xếp hạng \n Bang của bạn đã tăng lên <color=yellow>"..nMaxTongLevel.."<color> cấp, mức độ mới sẽ có hiệu lực vào thứ 2 tới");
		return 0;
	end

	local szDialog = "    Áp dụng nâng cấp xếp hạng vào thứ 2 tuần tới, các cổ đông có thể chọn mua quan ấn \n    Bang của bạn đã tăng lên <color=yellow>"..nMaxTongLevel.."<color> cấp, nên được thăng chức <color=yellow>"..(nMaxTongLevel+1).."<color> Mức độ cần:";
	local szCondition1 = "\n    1, Bị chiếm đóng <color=yellow>"..Tong.OFFICIAL_LEVEL_CONDITION[nLevel].."<color> lãnh thổ"
	local szCondition2 = "\n    2, Cắt giảm chi phí <color=yellow>"..tostring(nMoney / 10000).." lượng <color> xây dựng quỹ" 
	
	if not nConfirm or nConfirm ~= 1 then
		Dialog:Say(szDialog..szCondition1..szCondition2.."\n\n    Bạn muốn tăng lên cấp độ tiếp ？",
			{
				{"Xác nhận", self.IncreaseOfficialLevelConfirm, self, nLevel},
				{"Quay lại", self.OnDialog, self},
				{"Để ta suy nghĩ thêm"},
			});
		return 0;
	end
	
	if nMaxTongLevel == #Tong.OFFICIAL_LEVEL_CONDITION then
		Dialog:Say("Bang của bạn đã được thăng đến cấp cao nhất");
		return 0;
	elseif nMaxTongLevel >= nMaxLevelByDomain and nMaxTongLevel < #Tong.OFFICIAL_LEVEL_CONDITION then
		Dialog:Say("    Không đủ số lãnh thổ yêu cầu.");
		return 0;
	end

	if Tong:CanCostedBuildFund(me.dwTongId, nKinId, nMemberId, nMoney, 0) ~= 1 then
		Dialog:Say("    Bang của bạn có thể dùng các quỹ khác thay cho quỹ xây dựng bị thiếu");
		return 0;
	end
	
	return GCExcute{"Tong:IncreaseOfficialLevel_GC",  me.dwTongId, nKinId, nMemberId};
end

function tbNpc:IncreaseOfficialLevelConfirm(nLevel)
	local pTong = KTong.GetTong(me.dwTongId);
	if not pTong then
		return 0;
	end
	
	Dialog:Say("    Khuyến khích tăng đến "..Tong.TONG_OFFICIAL_LEVEL_CHARGE[nLevel].." Vốn xây dựng <color=yellow> Cắt giảm sau khi chiếm đóng các lãnh thổ của số lượng không đủ mức độ xếp hạng băng đảng sẽ tự động làm giảm trở lại lãnh thổ của số lượng các mức tương ứng. <color>\n bạn có chắc đã đủ các điều kiện ？",
			{
				{"Xác nhận", self.DlgIncreaseOfficialLevel, self, 1},
				{"Quay lại", self.OnDialog, self},
				{"Để ta suy nghĩ lại"},
			});
end


-- 选择帮会官衔水平
function tbNpc:DlgChoseOfficialLevel(nLevel, nConfirm)
	local pTong = KTong.GetTong(me.dwTongId);
	if not pTong then
		Dialog:Say("Bạn chưa gia nhập bang hội, không thể thực hiện thao tác này");
		return 0;
	end
	
	local nKinId, nMemberId = me.GetKinMember();
	if Tong:CheckPresidentRight(me.dwTongId, nKinId, nMemberId) ~= 1 then
		Dialog:Say("Chỉ có thủ lĩnh mới có quyền điều chỉnh mức độ xếp hạng bang");
		return 0;
	end

	local nMaxTongLevel = pTong.GetOfficialMaxLevel();
	if nMaxTongLevel == 0 then
		Dialog:Say("Đánh giá xếp hạng <color=red>0<color> cấp, xin nâng cấp xếp hạng bang");
		return 0;
	end
	
	if not nConfirm or nConfirm ~= 1 then
		local tbOpt = {};
		for i = 0, nMaxTongLevel do
			table.insert(tbOpt, 
			{
				string.format("Bảng xếp hạng <color=green>%d cấp<color>", i), 
				self.DlgChoseOfficialLevel, self, i, 1
			});
		end
		table.insert(tbOpt, {"Quay lại", self.OnDialog, self});
		table.insert(tbOpt, "Kết thúc đối thoại");	
		Dialog:Say("    Thủ lĩnh có thể được tự do lựa chọn phù hợp với tình hình thực tế của các băng nhóm bất kỳ thấp hơn so với thứ hạng hiện tại của bang, để kiểm soát số lượng thành viên của các cổ đông để có được thứ hạng.\n    Các thiết lập hiện trong tuần tới mức độ xếp hạng bang <color=yellow>"..pTong.GetOfficialLevel().."<color> cấp, bạn muốn điều chỉnh xếp hạng bang vào tuần tới ？", tbOpt);
		return 0;
	end

	return GCExcute{"Tong:ChoseOfficialLevel_GC",  me.dwTongId, nKinId, nMemberId, nLevel};
end

-- 个人官衔维护
function tbNpc:DlgOfficialMaintain(nConfirm)
	local pTong = KTong.GetTong(me.dwTongId);
	if not pTong then
		Dialog:Say("Bạn chưa gia nhập bang, không thể thực hiện thao tác vừa chọn");
		return 0;
	end
	
	local nKinId, nMemberId =  me.GetKinMember();
	if Tong:CanAppointOfficial(me.dwTongId, nKinId, nMemberId) ~= 1 then
		Dialog:Say("Thủ lĩnh và các cổ đông có cơ hội mua quan ấn");
		return 0;
	end

	local nTongLevel = pTong.GetPreOfficialLevel();
	if not nTongLevel or nTongLevel == 0 then
		Dialog:Say("Đánh giá xếp hạng <color=red>0<color> cấp, xin nâng cấp xếp hạng bang");
		return 0;
	end
	
	
	local nOfficialRank = Tong:GetOfficialRank(me.dwTongId, nKinId, nMemberId);
	if nOfficialRank == 0 then
		Dialog:Say("Bạn đang ở trong 1 bang không có thành chính, không có danh hiệu cần bảo trì");
		return 0;
	end
	
	local nCurNo = KGblTask.SCGetDbTaskInt(DBTASK_OFFICIAL_MAINTAIN_NO);
	if nCurNo == KGCPlayer.OptGetTask(me.nId, KGCPlayer.TSK_MAINTAIN_OFFICIAL_NO) then
		Dialog:Say("Duy trì xếp hạng tuần này thành công");
		return 0;
	end

	local nPersonalLevel = Tong.OFFICIAL_TABLE[nTongLevel][nOfficialRank];
	if not nPersonalLevel or nPersonalLevel < 1 then
		Dialog:Say("Bạn không có quan hàm, không cần bảo trì");
		return 0;
	end
	
	local szOfficialTitle = "";
	if Tong.IsPresident(me.dwTongId, nKinId, nMemberId) ~= 0 then
		szOfficialTitle = Tong.OFFICIAL_TITLE[nPersonalLevel];
	else 
		szOfficialTitle = Tong.OFFICIAL_TITLE_NP[nPersonalLevel];
	end
	
	if not nConfirm or nConfirm ~= 1 then
		Dialog:Say("Bạn không hoàn thành việc duy trì xếp hạng tuần này, xếp hạng <color=yellow>"..szOfficialTitle.."<color> đã bị khóa, Bạn xác nhận <color=yellow>"..Tong.OFFICIAL_CHARGE[nPersonalLevel].."<color> sử dụng tài sản cá nhân để mở khóa danh hiệu ？", 
			{
				{"Xác nhận mở khóa", self.DlgOfficialMaintain, self, 1},
				{"Quay lại", self.OnDialog, self},
				{"Để ta suy nghĩ lại"},
			});
		return 0;
	end
	-- 如果个人资产和股份不足
	local nStockAmount = Tong:CalculateStockCost(me.dwTongId, nKinId, nMemberId, tonumber(Tong.OFFICIAL_CHARGE[nPersonalLevel]));
	if not nStockAmount then
		return 0;
	end
	
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		return 0;
	end
	local pMember = pKin.GetMember(nMemberId);
	if not pMember then
		return 0;
	end
	local nPersonalStock = pMember.GetPersonalStock() - nStockAmount;
	if nPersonalStock < 0 then 
		Dialog:Say("Hãy chuẩn bị đủ tài sản cá nhân để có thể mở khóa danh hiệu.");
		return 0; 
	end
	
	return GCExcute{"Tong:OfficialMaintain_GC", me.dwTongId, nKinId, nMemberId};
end
