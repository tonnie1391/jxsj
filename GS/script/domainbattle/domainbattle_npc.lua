
--
-- 领土争夺战对话逻辑

-- 领土战期间车夫对话逻辑

local tbXuanZhan = Npc:GetClass("xuanzhan");
function Domain:BattleChefu(nStartNo, nSelMapId)
	nStartNo = nStartNo or 1
	local nCount = 0;
	local nMaxNo = nStartNo + 10;
	local nState = self:GetBattleState()
	local pTong = KTong.GetTong(me.dwTongId);
	if not pTong then
		Dialog:Say("Bạn không trong bang hội, không thể sử dụng Xa phu chinh chiến!")
		return 0;
	end
	if nState ~= self.BATTLE_STATE and nState ~= self.PRE_BATTLE_STATE then
		Dialog:Say("Hiện không phải thời kỳ chinh chiến, không thể sử dụng Xa phu chinh chiến!");
		return 0;
	end
	self:CheckTask(me);
	local nMapId = me.GetTask(self.TASK_GROUP_ID, self.CHUANSONG_ID)
	if nMapId == 0 and nSelMapId then
		me.SetTask(self.TASK_GROUP_ID, self.CHUANSONG_ID, nSelMapId)
		Dialog:Say("Thiết lập thành công!",
			{
				{"Lập tức đưa ta đi tới", self.BattleChefu, self},
				{"Không có chuyện gì"},
			})
	elseif nMapId == 0 then
		local tbOpt = {}
		local pDomainItor = pTong.GetDomainItor()
		local nCurDomainId = pDomainItor.GetCurDomainId()
		while (nCurDomainId and nCurDomainId ~= 0) do
			nCount = nCount + 1;
			if nCount >= nStartNo and nCount < nMaxNo then
				local nFightMapId = self:GetDomainFightMap(nCurDomainId);
				local szMapName = GetMapNameFormId(nFightMapId);
				if szMapName ~= "" then
					table.insert(tbOpt, {szMapName, self.BattleChefu, self, nil, nFightMapId});
				end
				
			elseif nCount >= nMaxNo then
				break;
			end
			nCurDomainId = pDomainItor.NextDomainId();
		end
		if nStartNo > 1 then
			table.insert(tbOpt, {"Trang trước", self.BattleChefu, self, math.max(1, nStartNo - 10)});
		end
		if nCount >= nMaxNo then
			table.insert(tbOpt, {"Trang sau", self.BattleChefu, self, nMaxNo});
		end
		if #tbOpt > 0 then
			table.insert(tbOpt, {"Không cần đâu"});
			Dialog:Say("Xin mời lựa chọn điểm đến Lãnh thổ chiến, <color=red>một khi bạn đã lựa chọn thì không thể thay đổi<color>, bạn chỉ có thể chọn <color=red>lãnh thổ bang hội đã chiếm đóng<color> là điểm đến, bạn lựa chọn khu vực nào để sử dụng Xa phu chinh chiến?",
				tbOpt)
		else
			Dialog:Say("Bang hội của bạn hiện chưa có lãnh thổ, không thể sử dụng Xa phu chinh chiến!");
		end
	else
		local nDomainId = self:GetMapDomain(nMapId);
		if nDomainId then
			local tbCenter = self:GetCenterRange(nDomainId)
			if tbCenter then
				local nRet, szMsg = Map:CheckTagServerPlayerCount(nMapId)
				if nRet == 1 then
					me.NewWorld(nMapId, tbCenter.nX, tbCenter.nY);
				else
					me.Msg(szMsg);
				end
			end
		end
	end
end

Domain.MAX_OPTIONS = 8; -- 分页显示时一页容纳的选项


-- 奖励Npc响应对话
function Domain:AwardDialog()
	if (self:GetBattleState() == self.PRE_BATTLE_STATE or self:GetBattleState() == self.BATTLE_STATE) then
		Dialog:Say("Trong thời kỳ tuyên chiến và chinh chiến không thể nhận thưởng, hãy quay lại sau khi thời gian chính chiến kết thúc.");
		return 0;
	end
	local pTong = KTong.GetTong(me.dwTongId);
	if not pTong then
		Dialog:Say("Bạn chưa có bang hội, không thể sử dụng chức năng Lãnh thổ chiến.")
		return 0;
	end
	Dialog:Say("  Tranh đoạt lãnh thổ kết thúc, mới được đến nhận thưởng. Chiến công càng cao, thưởng càng nhiều. "..
			  "Nhận thưởng sau khi kết thúc Tranh đoạt lãnh thổ, nếu không sẽ mất.\n  Xếp hạng chiến công trong bang như sau:\n<color=green>"..(pTong.GetDomainResult() or "Không có xếp hạng chiến công"),
		{
			{"Nhận thưởng danh vọng", self.ReciveSystemAward, self, 0},
			{"Nhận quân hưởng", self.ReciveTongAward, self, 0, 0},
			{"Đặt ngạch quân hưởng", self.SetTongAward, self, 0, 0},
			{"Thuyết minh phần thưởng", self.Award_Intro, self},
			{"Trở về trang trước", tbXuanZhan.OnDialog, tbXuanZhan},
			{"Kết thúc đối thoại"},
		}
	);		
end

function Domain:DlgJunXu()
	Dialog:Say([[    Mỗi lần tranh đoạt lãnh thổ, thành viên bang hội đều có thể đến nhận quân nhu.
    Mỗi lần phát cho mỗi người <color=green>1 rương<color> quân nhu.
    Nếu muốn nhận nhiều quân nhu hơn, phải mời Bang chủ đến thiết lập mức quân nhu trong thời gian tranh đoạt lãnh thổ (20:00~21:30). Sau khi thiết lập, bạn có thể nhận nhiều quân nhu hơn.
    Nếu chưa nhận quân nhu của lần tranh đoạt lãnh thổ này thì số quân nhu đó sẽ bị xóa trong lần tuyên chiến sau.]],
		{
			{"Nhận quân nhu", self.FatchJunXu, self},
			{"Nhận rương thuốc miễn phí hôm nay", SpecialEvent.tbMedicine_2012.GetMedicine, SpecialEvent.tbMedicine_2012},
			{"Thiết lập quân nhu bang hội", self.SetJunXu, self},
			{"Trở về trang trước", tbXuanZhan.OnDialog, tbXuanZhan},
			{"Kết thúc đối thoại"},
		})
end

function Domain:CheckDeclareWarRight(nTongId)
	local nSelfKinId, nSelfMemberId = me.GetKinMember();
	local nMasterCheck, cMember = Tong:CheckSelfRight(nTongId, nSelfKinId, nSelfMemberId, Tong.POW_MASTER);
	local nGeneralCheck, cMember = Tong:CheckSelfRight(nTongId, nSelfKinId, nSelfMemberId, Tong.POW_WAR);

	if nGeneralCheck ~= 1 then
		Dialog:Say("Ngươi không có quyền tuyên chiến.");
		return 0;
	end
	return 1;
end

function Domain:DeclareWar_Confirm(nDomainId, nTongId)	
	local tbDlg = {
		{"Xác nhận", self.DeclareWar_GS1, self, nDomainId, nTongId},
		{"Để ta suy nghĩ thêm"},
	}
	local szDomainName = self:GetDeclareTongNames(nDomainId);
	if  szDomainName then
		Dialog:Say("    Ngươi chắc chắn tuyên chiến <color=yellow>"..self:GetDomainName(nDomainId)..
			"<color> trong lần tranh đoạt lãnh thổ này?\n<color=yellow>Các Bang hội cùng tuyên chiến tại điểm này gồm: \n<color><color=green>"..
			szDomainName.."<color>", tbDlg);
	else
		Dialog:Say("    Ngươi chắc chắn tuyên chiến <color=yellow>"..self:GetDomainName(nDomainId).."<color> trong lần tranh đoạt lãnh thổ này?", tbDlg);
	end
end

-- 选择要宣战的新手村
function Domain:SelectVillageToAttack(nPageStart)
	self:CheckDeclareWarRight(me.dwTongId);
	local nStart = nPageStart or 1;
	local tbDlg = {};
	local tbDomain = self:GetDomains();
	local nDomainVersion = self:GetDomainVersion();
	local nPos = 0;
	for nDomainId, szDomainName in pairs(tbDomain) do
		if self:GetDomainType(nDomainId) == "village" and self:GetBorderDomains(nDomainVersion, nDomainId) then
			nPos = nPos + 1;
			if nPos >= nStart and nPos < nStart + self.MAX_OPTIONS then -- 一页显示几个结果
				if self:GetReputeParam(nDomainId) and self:GetReputeParam(nDomainId) > 0 then
					szDomainName = szDomainName.."(cấp lãnh thổ <color=yellow>"..self:GetReputeParam(nDomainId).."<color>)";
				end
				local tbTmp = {szDomainName, self.DeclareWar_Confirm, self, nDomainId, me.dwTongId};
				table.insert(tbDlg, tbTmp);
			end
		end
	end
	if nPos >= nStart + self.MAX_OPTIONS then
		table.insert(tbDlg, {"Trang sau", self.ListNativeVillage, self, nStart + self.MAX_OPTIONS});
	end
	table.insert(tbDlg, {"Đóng lại"});

	Dialog:Say("Bang hội của bạn hiện chưa có lãnh thổ, chỉ có thể chọn Lãnh thổ thuộc Tân Thủ Thôn để tiến hành tuyên chiến:", tbDlg);
end

-- 选择要宣战的非新手村
function Domain:SelectNonVillageToAttack(nPageStart)
	self:CheckDeclareWarRight(me.dwTongId);
	local nStart = nPageStart or 1;
	local tbDlg = {};
	local tbDomain = self:GetDomains();
	local nDomainVersion = self:GetDomainVersion()
	local nPos = 0;
	for nDomainId, szDomainName in pairs(tbDomain) do
		if self:GetDomainType(nDomainId) ~= "village" 
			and self:GetDomainOwner(nDomainId) == 0 
			and self:GetBorderDomains(nDomainVersion, nDomainId) then
			nPos = nPos + 1;
			if self:GetReputeParam(nDomainId) and self:GetReputeParam(nDomainId) > 0 then
				szDomainName = szDomainName.."<color=yellow>(cấp "..self:GetReputeParam(nDomainId)..")<color>";
			end
			if nPos >= nStart and nPos < nStart + self.MAX_OPTIONS then -- 一页显示几个结果
				local tbTmp = {szDomainName, self.DeclareWar_Confirm, self, nDomainId, me.dwTongId};
				table.insert(tbDlg, tbTmp);
			end
		end
	end
	if nStart > self.MAX_OPTIONS then
		table.insert(tbDlg, {"Trang trước", self.SelectNonVillageToAttack, self, nStart - self.MAX_OPTIONS});
	end
	if nPos >= nStart + self.MAX_OPTIONS then
		table.insert(tbDlg, {"Trang sau", self.SelectNonVillageToAttack, self, nStart + self.MAX_OPTIONS});
	end
	table.insert(tbDlg, {"Đóng lại"});

	Dialog:Say("Chọn mục tiêu bang hội của bạn muốn tuyên chiến:", tbDlg);
end

-- 宣战对话框
function Domain:DeclareWar_Intro()
	local nState = self:GetBattleState();
	local szSay = [[    Mỗi lần tranh đoạt lãnh thổ trước nửa tiếng (20:00~20:30) là thời kỳ tuyên chiến.
    Bang chủ hòa có tuyên chiến quyền hạn đích thành viên khả dĩ tại tuyên chiến kỳ nội tuyển trạch một khối lãnh thổ làm bản thứ lãnh thổ chiến đích tuyên chiến mục tiêu. Xác định tuyên chiến mục tiêu hậu, bang hội thành viên tức khả tại chinh chiến trong lúc đánh tuyên chiến mục tiêu.
    <color=green>Khi tấn công Tân Thủ Thông chưa bị bang hội chiếm lĩnh, trước tiên phải tiến hành tuyên chiến<color>
    Lựa chọn mục tiêu tuyên chiến, chỉ bang chủ mới có thể đổi mục tiêu tuyên chiến.
    
]]

	if nState ~= self.PRE_BATTLE_STATE then
		szSay = szSay..[[
	<color=yellow>Chưa đến thời kỳ tuyên chiến.<color>
 		]]
		Dialog:Say(szSay);
		return 0;
	end
	local nTongId = me.dwTongId;
	local tbToAttack = self:GetDomainToAttack(nTongId);
	local nDelareNum = self:GetConzoneDelareNum(nTongId);
	if nDelareNum > 0 then
		szSay = szSay..string.format("  <color=gold>Bang hội của bạn trước đó đã chiếm lĩnh %d lãnh thổ, bởi vậy lần này hợp phục hậu đích lần đầu tiên lãnh thổ chiến trung，bang hội của bạn có thể <color=green>trực tiếp tuyên chiến %d lãnh thổ chưa bị chiếm lĩnh.<color><color>",
			nDelareNum, nDelareNum);
	end
	if #tbToAttack == 0 then
		szSay = szSay..[[
		<color=yellow><enter>  Bang hội của bạn chưa tuyên chiến, bang chủ hoặc trưởng lão chiến tranh cần tuyên chiến trước 20:30 để xác định mục tiêu chinh chiến, nếu không sẽ không có quyền tấn công.<color>
		]]
	else
		local szDeclareInfo = "";
		for i = 1, #tbToAttack do
			local szDomainName = Domain:GetDomainName(tbToAttack[i]);
			local nFightMap = self:GetDomainFightMap(tbToAttack[i]) or 0;
			local szFightMap = GetMapNameFormId(nFightMap);
			if szDomainName and szFightMap then
				szDeclareInfo = szDeclareInfo..string.format("\n<color=green>Lãnh thổ %s<color> (Bản đồ tranh đoạt: <color=gold>%s<color>)",
					szDomainName, szFightMap)
			end
		end
		szSay = szSay.."<color=yellow>Tranh đoạt lãnh thổ bang hội tuyên chiến với các mục tiêu:<color>"..szDeclareInfo;
	end
	
	local tbOpt = {}
	local nTongId = me.dwTongId;
	local nSelfKinId, nSelfMemberId = me.GetKinMember()
	local nGeneralCheck, cMember = Tong:CheckSelfRight(nTongId, nSelfKinId, nSelfMemberId, Tong.POW_WAR);

	if nGeneralCheck == 1 then
		table.insert(tbOpt, {"Chọn mục tiêu tuyên chiến", self.SelectDomainToAttack, self});
	end
	table.insert(tbOpt, {"Trở về trang trước", tbXuanZhan.OnDialog, tbXuanZhan});
	table.insert(tbOpt, {"Kết thúc đối thoại"});
	Dialog:Say(szSay,tbOpt);
end

-- 设置主城对话框
function Domain:SelectCapital_Intro()
	local szSay = [[    Sau khi Bang hội chiếm lãnh thổ bên ngoài Tân Thủ Thôn, có thể chọn 1 lãnh thổ trong đó làm thành chính của Bang hội. Khi canh giữ thành chính, thành viên Bang hội có thể nhận trạng thái hỗ trợ tăng năng lực phòng thủ.
    Sau khi Bang hội khác công hạ thành chính, phải thiết lập lại thành chính khác. Sau khi thiết lập, nếu muốn đổi phải trả 1 chi phí nhất định, do đó hãy thận trọng quyết định.
    Chỉ Bang chủ mới có quyền thiết lập và thay đổi thành chính.
    <color=red>Chú ý: Trong lúc tranh đoạt lãnh thổ (lúc truyên chiến, lúc chinh chiến, lúc ngừng chiến đấu) đều không thể thay đổi thành chính!<color>
]]

	local tbOpt =
	 {
		{"Thiết lập hoặc thay đổi thành chính", self.SelectCapital, self},
		{"Trở về trang trước", tbXuanZhan.OnDialog, tbXuanZhan},
		{"Để ta suy nghĩ đã"},
	}
	Dialog:Say(szSay,tbOpt);
end

function Domain:SelectDomainToAttack(nPageStart)
	local nStart = nPageStart or 1;
	local tbDlg = {};
	local nState = self:GetBattleState();
	if nState ~= self.PRE_BATTLE_STATE then
		Dialog:Say("Hiện tại không cho phép tuyên chiến! Thời kỳ tuyên chiến (20:00~20:30).");
		return 0;
	end
	
	local pTong = KTong.GetTong(me.dwTongId);
	if pTong == nil then
		Dialog:Say("Bạn chưa vào bang, không thể sử dụng chức năng lãnh thổ chiến!");
		return 0;
	end
	local nUnionId = pTong.GetBelongUnion();
	if nUnionId ~= 0 and KUnion.GetUnion(nUnionId) then
		local nState = Union:GetUnionDomainDecleaarState(nUnionId);
		if nState < 0 then
			Dialog:Say("Tổng số lãnh thổ liên minh lớn hơn số bang hội, không thể tiếp tục xâm chiếm vùng lãnh thổ khác!")
			return 0;
		elseif nState == 0 then				-- 联盟当前状态只能宣新手村
			self:SelectVillageToAttack();
			return 1;
		elseif nState == 1 then			-- 联盟当前状态可宣战任意白城
			self:SelectNonVillageToAttack(nPageStart);
			return 1;
		end
	else		-- 无联盟才有合服补偿
		local nDomainCount = pTong.GetDomainCount();
		local cItor = pTong.GetDomainItor();
		local nDelareNum = self:GetConzoneDelareNum(me.dwTongId)
		if nDomainCount == 0 and nDelareNum == 0 then		-- 没有领土并且没有合服补偿，选择新手村宣战
			self:SelectVillageToAttack();
			return 1;
		elseif nDelareNum > 0 then	-- 有合服补偿，可宣战任意地图
			self:SelectNonVillageToAttack(nPageStart);		
			return 1;
		end
		if nDomainCount == 1 and cItor then
			local nIdTmp = cItor.GetCurDomainId();
			if self:GetDomainType(nIdTmp) == "village" then -- 只占有新手村
				self:SelectNonVillageToAttack(nPageStart);
				return 1;
			end
		end
	end
	local tbAdjacency = self:GetAdjacency(me.dwTongId);
	local nPos = 0;
	if tbAdjacency then
		for nDomainId, nOwnerTongId in pairs(tbAdjacency) do
			if (nOwnerTongId == nil or nOwnerTongId == 0) and self:GetDomainType(nDomainId) ~= "village" then
				nPos = nPos + 1;
				if nPos >= nStart and nPos < nStart + self.MAX_OPTIONS then -- 一页显示几个结果	
					local szDomainName = self:GetDomainName(nDomainId)
					if self:GetReputeParam(nDomainId) and self:GetReputeParam(nDomainId) > 0 then
						szDomainName = szDomainName.."<color=yellow>(cấp "..self:GetReputeParam(nDomainId)..")<color>";
					end	
					local tbTmp = {szDomainName, self.DeclareWar_Confirm, self, nDomainId, me.dwTongId};
					table.insert(tbDlg, tbTmp);
				end
			end	
		end
	end
	if nStart > self.MAX_OPTIONS then
		table.insert(tbDlg, {"Trang trước", self.SelectDomainToAttack, self, nStart - self.MAX_OPTIONS});
	end
	if nPos >= nStart + self.MAX_OPTIONS then
		table.insert(tbDlg, {"Trang sau", self.SelectDomainToAttack, self, nStart + self.MAX_OPTIONS});
	end
	if #tbDlg > 0 then
		table.insert(tbDlg, {"Đóng lại"});
		Dialog:Say("Có thể tấn công lãnh thổ lân cận đã bị chiếm lĩnh. Bang của bạn có thể tuyên chiến với lãnh thổ:", tbDlg);
	else
		Dialog:Say("Có thể tấn công lãnh thổ lân cận đã bị chiếm lĩnh. Bang của bạn không thể tuyên chiến lãnh thổ.");
	end
end

-- 选择主城
function Domain:SelectCapital(nPageStart)
	local nStart = nPageStart or 1;
	local tbDlg = {};
	local cTong = KTong.GetTong(me.dwTongId);
	if cTong == nil then
		Dialog:Say("Chưa vào bang, không thể sử dụng chức năng lãnh thổ chiến.");
		return 0;
	end
	if self:GetBattleState() ~= self.NO_BATTLE then
		Dialog:Say("Tranh đoạt lãnh thổ đã bắt đầu, không thể thay đổi thành chính.");
		return 0;
	end
	local nSelfKinId, nSelfMemberId = me.GetKinMember();
	local nMasterCheck, cMember = Tong:CheckSelfRight(me.dwTongId, nSelfKinId, nSelfMemberId, Tong.POW_MASTER);
	if nMasterCheck ~= 1 then
		Dialog:Say("Chỉ có Bang chủ mới có quyền thay đổi thành chính.");
		return 0;
	end

	if cTong.GetDomainCount() == 0 then
		Dialog:Say("Bang hội của bạn hiện chưa có lãnh thổ, hãy chiếm lãnh thổ rồi quay trở lại sau.");
		return 0;
	end

	local nPos = 0;
	local cItor = cTong.GetDomainItor();
	for i = 1, cTong.GetDomainCount() do
		local nDomainId = cItor.GetCurDomainId();
		nPos = nPos + 1;
		if nPos >= nStart and nPos < nStart + self.MAX_OPTIONS then -- 一页显示几个结果		
			local tbTmp = {self:GetDomainName(nDomainId), Tong.SetCapital_GS1, Tong,
				 me.dwTongId, nDomainId};
			table.insert(tbDlg, tbTmp);
		end
		cItor.NextDomain();
	end
	if nPos >= nStart + self.MAX_OPTIONS then
		table.insert(tbDlg, {"Trang sau", self.SelectCapital, self, nStart + self.MAX_OPTIONS});
	end
	table.insert(tbDlg, {"Đóng lại"});
	
	local nCapital = cTong.GetCapital();
	if nCapital == 0 then
		Dialog:Say("Bang hội của bạn chưa thiết lập thành chính.\nChọn tên lãnh thổ muốn làm thành chính.", tbDlg);
	else
		Dialog:Say("Thành chính của bang hội là <color=green>"..self:GetDomainName(nCapital).."<color>.\nChọn tên lãnh thổ muốn đổi làm thành chính.", tbDlg);
	end
end

-- 设置军需
function Domain:SetJunXu(nType, nLevel, nNum, nConfirm)
	local nTongId = me.dwTongId
	local nSelfKinId, nSelfMemberId = me.GetKinMember();
	local nMasterCheck, cMember = Tong:CheckSelfRight(nTongId, nSelfKinId, nSelfMemberId, Tong.POW_MASTER);
	local nCurState = self:GetBattleState();
	if nMasterCheck ~= 1 then
		Dialog:Say("Chỉ có Bang chủ mới có thể thiết lập ngạch quân nhu.");
		return 0;
	end
	if nCurState ~= self.PRE_BATTLE_STATE and nCurState ~= self.BATTLE_STATE then
		Dialog:Say("Chỉ trong thời kỳ tuyên chiến (20:00~21:30) mới có thể thiết lập ngạch quân nhu.");
		return 0;
	end
	
	local pTong = KTong.GetTong(me.dwTongId);
	local nJunXuNo = pTong.GetDomainJunXunNo();
	local nCurNo = KGblTask.SCGetDbTaskInt(DBTASK_DOMAIN_BATTLE_NO);
	local nMedicineLevel = self:GetMedicineLevel(pTong.GetDomainJunXunType());
	local nHelpfulLevel = self:GetHelpfulLevel(pTong.GetDomainJunXunType());
	if nJunXuNo == nCurNo and nMedicineLevel > 0 and nHelpfulLevel > 0 then
		Dialog:Say("Bang hội của bạn đã thiết lập ngạch quân nhu Lãnh thổ chiến.");
		return 0;
	end
	
	-- 选择要设置的军需
	if not nType then
		self:SelectSetType();
		return 0;
	end
	
	if nType == self.JUNXU_HELPFUL and not nNum and not nConfirm then
		local tbDlg = {};
		local szMsg = "";
		if nLevel == 1 then 
			szMsg = "<color=yellow>Hồi huyết đơn (tiểu) <color>Đơn giá: \n    <color=yellow>10 vạn<color>lượng.\n\n    建设资金在帮会成员领取军需的时候扣除.购买了行军丹(tiểu)后，本次领土战<color=red>将无法再购买<color>行军丹(trung).\n"
		else
			szMsg = "<color=yellow>Hồi huyết đơn (trung) <color>Đơn giá: \n    <color=yellow>40 vạn<color>lượng.\n\n    建设资金在帮会成员领取军需的时候扣除.购买了行军丹(trung)后，本次领土战<color=red>将无法再购买<color>行军丹(tiểu).\n"
		end
		table.insert(tbDlg, {"Mỗi người <color=green>1<color>", self.SetJunXu, self, nType, nLevel, self.JUNXU_HELPFUL_MAX_NUM});
		table.insert(tbDlg, {"Để ta suy nghĩ đã."});
		Dialog:Say(szMsg, tbDlg);
		return 0;
	end
	
	-- 确认
	if not nConfirm or nConfirm ~= 1 then
		local szTypeName = self.JUNXU_NAME[nType][nLevel];
		local szPrice = "";
		if nType == self.JUNXU_MEDICINE and nLevel == 1 then 
			szPrice = "mỗi rương quân nhu cần hao phí <color=yellow>3000<color> quỹ xây dựng bang hội."
		elseif nType == self.JUNXU_MEDICINE and nLevel == 2 then
			szPrice = "mỗi rương quân nhu cần hao phí <color=yellow>8 vạn<color> quỹ xây dựng bang hội."
		elseif nType == self.JUNXU_HELPFUL and nLevel == 1 then 
			szPrice = "mỗi rương quân nhu cần hao phí <color=yellow>10 vạn<color> quỹ xây dựng bang hội."
		elseif nType == self.JUNXU_HELPFUL and nLevel == 1 then 	
			szPrice = "mỗi rương quân nhu cần hao phí <color=yellow>40 vạn<color> quỹ xây dựng bang hội."
		end
		Dialog:Say("Thiết lập cho mỗi người "..szTypeName.." <color=green>bổ sung "..nNum.." rương<color> quân nhu, "..szPrice.." bạn có chắc chắn?",
		{
			{"Xác nhận", self.SetJunXu, self, nType, nLevel, nNum, 1},
			{"Kết thúc đối thoại"},
		})
		return 0;
	end
	GCExcute{"Domain:SetJunXu_GC", nTongId, nType, nLevel, nNum};
end

-- 选择设置军需的类型
function Domain:SelectSetType(nType, nLevel)	
	local pTong = KTong.GetTong(me.dwTongId);
	local nJunXuNo = pTong.GetDomainJunXunNo();
	local nCurNo = KGblTask.SCGetDbTaskInt(DBTASK_DOMAIN_BATTLE_NO);
	local nMedicineLevel = self:GetMedicineLevel(pTong.GetDomainJunXunType());
	local nHelpfulLevel = self:GetHelpfulLevel(pTong.GetDomainJunXunType());
	if not nType then 
		local tbDlg = {};
		if nJunXuNo ~= nCurNo or nMedicineLevel == 0 then
			table.insert(tbDlg, {"Thuốc trung cấp (rương), hồi phục huyết, nội", self.SelectSetType, self, self.JUNXU_MEDICINE, 1});
			table.insert(tbDlg, {"Thuốc cao cấp (rương), đại lượng hồi phục huyết, nội", self.SelectSetType, self, self.JUNXU_MEDICINE, 2});
		end
		if nJunXuNo ~= nCurNo or nHelpfulLevel == 0 then
			table.insert(tbDlg, {"Hành quân đan (tiểu), tăng lực công kích, lượng máu đạt mức cao nhất, tăng kháng", self.SetJunXu, self, self.JUNXU_HELPFUL, 1});
			table.insert(tbDlg, {"Hành quân đan (trung), tăng lực công kích mức cao nhất, lượng máu đạt mức cao nhất, tăng kháng", self.SetJunXu, self, self.JUNXU_HELPFUL, 2});
		end
		table.insert(tbDlg, {"Để ta suy nghĩ thêm."});
		Dialog:Say("    Ở đây ta cung cấp nhiều loại quân nhu:\n", tbDlg);
		return 0;
	end
	if nLevel then
		local tbDlg = {};
		local szMsg = "";
		if nLevel == 1 then 
			szMsg = "<color=yellow>Thuốc trung cấp <color>đơn giá: \n    <color=yellow>3000<color> lượng.\n\n    Kiến thiết tài chính tại bang hội thành viên lĩnh quân nhu thì trục tương khấu trừ. Mua liễu trung cấp dược hậu, bản thứ lãnh thổ chiến <color=red> tương vô pháp tái mua <color> cao cấp dược. Nâm muốn cho bang hội thành viên mỗi người năng lĩnh nhiều ít tương? \n"
		else
			szMsg = "<color=yellow>Thuốc cao cấp <color>đơn giá: \n    <color=yellow>8 vạn<color> lượng.\n\n    Kiến thiết tài chính tại bang hội thành viên lĩnh quân nhu thì trục tương khấu trừ. Mua liễu cao cấp dược hậu, bản thứ lãnh thổ chiến <color=red> tương vô pháp tái mua <color> trung cấp dược. Nâm muốn cho bang hội thành viên mỗi người năng lĩnh nhiều ít tương?\n"
		end
		for i = 1, self.JUNXU_MEDICINE_MAX_NUM do
			table.insert(tbDlg, {"Mỗi người <color=green>"..i.."<color> rương", self.SetJunXu, self, nType, nLevel, i});
		end
		table.insert(tbDlg, {"Để ta suy nghĩ thêm."});
		Dialog:Say(szMsg, tbDlg);
		return 0;
	end
	
	return 0;
end

-- 领取军需
function Domain:FatchJunXu(nType, nParticular, nConfirm, nLevel)
	local pTong = KTong.GetTong(me.dwTongId);
	if not pTong then
		Dialog:Say("Bạn chưa vào bang, không thể sử dụng chức năng Lãnh thổ chiến!");
		return 0;
	end
	
	local nCurState = self:GetBattleState();
	if nCurState ~= self.PRE_BATTLE_STATE and nCurState ~= self.BATTLE_STATE then
		Dialog:Say("Chỉ trong thời kỳ tuyên chiến (20:00~21:30) mới có thể nhận quân nhu.");
		return 0;
	end
	
	local nKinId, nMemberId = me.GetKinMember();
	if Kin:HaveFigure(nKinId, nMemberId, Kin.FIGURE_REGULAR) ~= 1 then
		Dialog:Say("Bạn không phải thành viên chính thức bang hội, không thể tham gia tranh đoạt lãnh thổ, bang chủ không thiết lập ngạch quân nhu cho bạn!");
		return 0;
	end

	local nCurNo = KGblTask.SCGetDbTaskInt(DBTASK_DOMAIN_BATTLE_NO);
	local nJunXuNo = pTong.GetDomainJunXunNo();
	local nSelfNum = me.GetTask(self.TASK_GROUP_ID, self.JUNXU_NUM);
	local nSelfMedicineNo = me.GetTask(self.TASK_GROUP_ID, self.JUNXU_MEDICINE_NO);
	-- 如果这场没领过，清空上次的记录.
	if nSelfMedicineNo ~= nCurNo then
		nSelfNum = 0;
	end
	local nMedicineMoney = 0;
	local nMedicineNum = 0;
	local nMedicineLevel = self:GetMedicineLevel(pTong.GetDomainJunXunType());
	-- 如果设置了药
	if nMedicineLevel > 0 and nJunXuNo == nCurNo then 
		nMedicineNum = pTong.GetDomainJunXunMedicineNum();
		nMedicineMoney = self.JUNXU_MEDICINE_PRICE[nMedicineLevel] * nMedicineNum;	
	end
	
	local nSelfHelpfulNo = me.GetTask(self.TASK_GROUP_ID, self.JUNXU_HELPFUL_NO);
	local nHelpfulMoney = 0;
	local nHelpfulNum = 0;
	local nHelpfulLevel = self:GetHelpfulLevel(pTong.GetDomainJunXunType());
	-- 如果设置了辅助	
	if nHelpfulLevel > 0 and nJunXuNo == nCurNo then 
		nHelpfulMoney = self.JUNXU_HELPFUL_PRICE[nHelpfulLevel];
		nHelpfulNum = self.JUNXU_HELPFUL_MAX_NUM;
	end
	
	local nJunXuNum = nMedicineNum + self.DEFAULT_JUNXU;

	if nSelfMedicineNo == nCurNo and nSelfHelpfulNo == nCurNo and nJunXuNum == nSelfNum then
		Dialog:Say("Bạn đã nhận hết quân nhu rồi.");
		return 0;
	end
	
	if not nType then
		local szMsg = "Bạn có thể nhận:\n";
		local tbOpt = {};

		if nSelfNum < self.DEFAULT_JUNXU then
			szMsg = szMsg.."Thuốc trung cấp miễn phí <color=green>"..self.DEFAULT_JUNXU.."<color> rương\n";
			if nMedicineLevel > 0 then 
				szMsg = szMsg.." Bổ sung "..self.JUNXU_NAME[self.JUNXU_MEDICINE][nMedicineLevel].."<color=green>"..nMedicineNum.."<color> rương\n";
			end
			table.insert(tbOpt, {"Nhận thuốc miễn phí", self.FatchJunXu, self, self.JUNXU_MEDICINE});
		end
		if nSelfNum < nJunXuNum and nSelfNum >= self.DEFAULT_JUNXU and nJunXuNo == nCurNo then
			szMsg = szMsg.." Bổ sung "..self.JUNXU_NAME[self.JUNXU_MEDICINE][nMedicineLevel].."<color=green>"..nJunXuNum - nSelfNum.."<color> rương\n";
			table.insert(tbOpt, {"Nhận thuốc", self.FatchJunXu, self, self.JUNXU_MEDICINE});
		end
		if nHelpfulMoney > 0 and nSelfHelpfulNo ~= nCurNo and nJunXuNo == nCurNo then
			szMsg = szMsg..self.JUNXU_NAME[self.JUNXU_HELPFUL][nHelpfulLevel].."<color=green>"..nHelpfulNum.."<color>\n";
			table.insert(tbOpt, {"Nhận quân hành đơn", self.FatchJunXu, self, self.JUNXU_HELPFUL, self.JUNXU_HELPFUL_PARTICULAR[nHelpfulLevel]});
		end
		if #tbOpt == 0 then
			szMsg = "    Bạn đã nhận tất cả quân nhu. Để có thể nhận nhiều hơn, bang chủ cần đặt thêm quân nhu."
			table.insert(tbOpt, {"Kết thúc đối thoại"});	
		else
			table.insert(tbOpt, {"Tạm thời chưa nhận"});
		end
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	
	if not nParticular then
		local szMsg = "Bạn muốn nhận: \n";
		local szSize = "";
		if nMedicineLevel == 1 or nSelfNum < self.DEFAULT_JUNXU then
			szSize = "(trung)";
		else
			szSize = "(đại)";
		end

		local tbOpt =
		{
			{"Nhận hồi huyết đơn"..szSize, self.FatchJunXu, self, self.JUNXU_MEDICINE, self.JUNXU_MEDICINE_PARTICULAR[1]},
			{"Nhận hồi nộ đơn"..szSize, self.FatchJunXu, self, self.JUNXU_MEDICINE, self.JUNXU_MEDICINE_PARTICULAR[2]},
			{"Nhận càn khôn tạo hóa hoàn"..szSize, self.FatchJunXu, self, self.JUNXU_MEDICINE, self.JUNXU_MEDICINE_PARTICULAR[3]},
			{"Kết thúc đối thoại"},
		}
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	
	if not nConfirm then
		local nLevel = 0;
		if nType == self.JUNXU_MEDICINE and nSelfNum >= self.DEFAULT_JUNXU then
			nLevel = nMedicineLevel;
		elseif nType == self.JUNXU_MEDICINE and nSelfNum < self.DEFAULT_JUNXU then
			nLevel = 1;
		elseif nType == self.JUNXU_HELPFUL then
			nLevel = nHelpfulLevel;
		end
		
		local szName = "";
		if nType == self.JUNXU_MEDICINE	then		 
			szName = self.JUNXU_NAME[nType][nLevel].." "..self.JUNXU_MEDICINE_NAME[self.JUNXU_MEDICINE][nParticular];
		else
			szName = self.JUNXU_NAME[nType][nLevel];
		end		 
		
		local szMsg = "Bạn xác nhận nhận "..szName.."?\n";
		local tbOpt = {};
		if nType == self.JUNXU_MEDICINE then
			tbOpt = 
			{
				{"Xác nhận",  self.FatchJunXu, self, nType, nParticular, 1, nLevel},
				{"Tạm thời chưa nhận"}
			};
		else
			tbOpt = 
			{
				{"Xác nhận",  self.FatchJunXu, self, nType, nParticular, 1, nLevel},
				{"Tạm thời chưa nhận"}
			};
		end
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end	
	
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ, làm trống rồi nhận lại!");
		return 0;
	end

	
	local nJunXuMoney = 0;
	local nSelfNo = 0;
	if nType == self.JUNXU_MEDICINE then
		nSelfNo = self.JUNXU_MEDICINE_NO;
		nJunXuMoney = self.JUNXU_MEDICINE_PRICE[nLevel];
		-- 第一个免费
		--if nSelfNum == 0 then
		--	me.SetTask(self.TASK_GROUP_ID, nSelfNo, nCurNo);
		--	me.SetTask(self.TASK_GROUP_ID, self.JUNXU_NUM, nSelfNum + 1);			
		--	return Domain:FatchJunXu_GS2(me.dwTongId, me.nId, self.JUNXU_MEDICINE, nParticular, nLevel, 1, 0);
		--end
		-- 如果不是第1个，检测够不够钱
		if nMedicineMoney > 0 and Tong:CanCostedBuildFund(me.dwTongId, 0, 0, nJunXuMoney, 0) ~= 1 then
			Dialog:Say("    Bang hội của bạn trong tuần đã tiêu hao quỹ xây đạt đến giới hạn, không thể  nhận thêm quân nhu, <color=yellow>Bang chủ<color> cần thiết lập mức chi tiêu quỹ xây cao hơn!");
			return 0;
		end
		me.SetTask(self.TASK_GROUP_ID, nSelfNo, nCurNo);
		me.SetTask(self.TASK_GROUP_ID, self.JUNXU_NUM, nSelfNum + 1);
		return GCExcute{"Domain:FatchJunXu_GC", me.dwTongId, me.nId, nType, nParticular, nLevel};
	elseif nType == self.JUNXU_HELPFUL then
		nSelfNo = self.JUNXU_HELPFUL_NO;
		nJunXuMoney = self.JUNXU_HELPFUL_PRICE[nLevel];
		if nHelpfulMoney > 0 and Tong:CanCostedBuildFund(me.dwTongId, 0, 0, nJunXuMoney, 0) ~= 1 then
			Dialog:Say("    Bang hội của bạn trong tuần đã tiêu hao quỹ xây đạt đến giới hạn, không thể  nhận thêm quân nhu, <color=yellow>Bang chủ<color> cần thiết lập mức chi tiêu quỹ xây cao hơn!");
			return 0;
		end
		me.SetTask(self.TASK_GROUP_ID, nSelfNo, nCurNo);
		return GCExcute{"Domain:FatchJunXu_GC", me.dwTongId, me.nId, nType, nParticular, nLevel};
	end	
	
end

function Domain:Award_Intro(nType)
	local szMsg = "Ngươi cần ta giải đáp rõ ràng về cái gì?";
	local tbOpt = {}
	if nType == 1 then
		szMsg = [[
    Lãnh thổ tranh đoạt chiến đích trong bảo khố tương khả dĩ tùy cơ khai ra các loại tài liệu.
    Tại lãnh thổ chiến quan viên chỗ khả dĩ mua đáo các loại tài liệu đích chế tác bản vẽ, sử dụng hậu khả dĩ học được tài liệu đích gia công hòa chế tạo phương pháp.
    Tài liệu chỉ có kinh qua gia công, chế tạo lưỡng đạo trình tự làm việc hậu, tài năng biến thành tăng danh vọng đích đạo cụ.
    Danh vọng đạt được nhất định đẳng cấp khả mua bất đồng đích luyện hóa bản vẽ, tái phối dĩ tương ứng trang bị khả dĩ luyện hóa ra canh cụ cường lực thuộc tính đích sáo trang.
]];
		table.insert(tbOpt, {"Trở về trang trước", self.Award_Intro, self});
	elseif nType == 2 then
		szMsg = [[    Mỗi lần lãnh thổ chiến thu được <color=green> công trạng cá nhân <color>, cùng với bang hội công chiếm được <color=green>số lượng lãnh thổ<color>, tương quyết định thưởng cho đích trong bảo khố tương số lượng. Bởi vậy, thu được càng nhiều trong bảo khố tương đích cách hữu:
1. Thu được càng nhiều đích công huân, đề thăng tại bang hội trung đích công huân bài danh;
2. Chỉnh thể đề thăng bang hội thực lực, công chiếm càng nhiều đích lãnh thổ.
    Đặc biệt địa, cá nhân công huân cấp bậc bỉ bang hội lãnh thổ số lượng quan trọng hơn, sở dĩ tại một khối lãnh thổ số lượng ít bang hội đạt được giác cao cá nhân công huân cấp bậc đích vai, khả năng yếu bỉ tại một khối lãnh thổ số lượng rất nhiều đích bang hội nhưng đạt được giác thấp cá nhân công huân cấp bậc đích vai thu được càng nhiều đích trong bảo khố tương.
]];
		table.insert(tbOpt, {"Trở về trang trước", self.Award_Intro, self});
	else
		table.insert(tbOpt, {"Rương lãnh thổ", self.Award_Intro, self, 1});
		table.insert(tbOpt, {"Làm thế nào để nhận được rương lãnh thổ", self.Award_Intro, self, 2});
		table.insert(tbOpt, {"Trở về trang trước", self.AwardDialog, self});
	end
	Dialog:Say(szMsg, tbOpt);
end

-- 设置过药
function Domain:HasSetMedicine(nTongId)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then 
		return 0;
	end
	local nLevel = self:GetMedicineLevel(pTong.GetDomainJunXunType());
	local nJunXuNo = pTong.GetDomainJunXunNo();
	local nCurNo = KGblTask.SCGetDbTaskInt(DBTASK_DOMAIN_BATTLE_NO);
	if nCurNo == nJunXuNo and nLevel > 0 then
		return 1;
	end
end

-- 设置过辅助
function Domain:HasSetHelpful(nTongId)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then 
		return 0;
	end
	local nLevel = self:GetHelpfulLevel(pTong.GetDomainJunXunType());
	local nJunXuNo = pTong.GetDomainJunXunNo();
	local nCurNo = KGblTask.SCGetDbTaskInt(DBTASK_DOMAIN_BATTLE_NO);
	if nCurNo == nJunXuNo and nLevel > 0 then
		return 1;
	end
end

