-- 文件名　：yuelao.lua
-- 创建者　：furuilei
-- 创建时间：2009-12-07 11:08:45
-- 功能描述：结婚npc，月老

local tbNpc = Npc:GetClass("marry_yuelao");
--==========================================================

tbNpc.LEVEL_PINGMIN		= 1;	-- 平民
tbNpc.LEVEL_GUIZU		= 2;	-- 贵族
tbNpc.LEVEL_WANGHOU		= 3;	-- 王侯
tbNpc.LEVEL_HUANGJIA	= 4;	-- 皇家

tbNpc.MINLEVEL_APPWEDDING	= 69;	-- 求婚的最低等级要求

tbNpc.MONEY_BASE = 200000;		-- 首次修改婚期需要上缴费用20W
tbNpc.RETE = 5;					-- 每次修改，需要缴纳费用是上次的5倍

tbNpc.tbLibaoGDPL = {"18-1-603-1", "18-1-603-2", "18-1-603-3", "18-1-603-4",
					"18-1-594-1", "18-1-594-2", "18-1-594-3", "18-1-594-4"};

tbNpc.tbWeddingInfo = {
	[tbNpc.LEVEL_PINGMIN]	= {szName = "Hiệp Sĩ",},
	[tbNpc.LEVEL_GUIZU]		= {szName = "Quý Tộc",},
	[tbNpc.LEVEL_WANGHOU]	= {szName = "Vương Hầu",},
	[tbNpc.LEVEL_HUANGJIA]	= {szName = "Hoàng Gia",},
	};

--==========================================================

function tbNpc:OnDialog()
	if (Marry:CheckState() == 0) then
		return 0;
	end
	local szMsg = "<color=red>Ngươi muốn gì ở ta?<color>";
	local tbOpt = {};
	table.insert(tbOpt, {"<color=yellow>Tham gia hôn lễ<color>", Marry.SelectServer, Marry});
	table.insert(tbOpt, {"Chọn ngày tổ chức hôn lễ", self.AppWeddingDlg, self});
	table.insert(tbOpt, {"Tham quan điểm tổ chức", self.PreViewWeddingPlaceDlg, self});
	table.insert(tbOpt, {"Xem tin tức hôn lễ", self.QueryWeddingInfoDlg, self});
	table.insert(tbOpt, {"Nhận tín vật", self.GetWeddingRing, self});
	table.insert(tbOpt, {"Quan hệ hiệp lữ", self.XiufuCoupleRelationDlg, self});
	table.insert(tbOpt, {"Nhận lại danh hiệu hiệp lữ", self.GetCoupleTitleDlg, self});
	table.insert(tbOpt, "Kết thúc đối thoại");
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:QueryWeddingInfoDlg()
	local szMsg = "Ngươi có thể xem tin tức của ngươi và người khác.";
	local tbOpt = {
		{"Xem tin tức của bản thân", self.QueryMyWeddingInfo, self},
		{"Xem tin tức của người khác", self.QueryOthersWeddingInfo, self},
		{"Xem tin tức theo ngày", self.QuerySpedayWedingInfo, self},
		{"Quay lại", self.OnDialog, self},
		};
	Dialog:Say(szMsg, tbOpt);
end

-- 查询自己的婚礼信息
function tbNpc:QueryMyWeddingInfo()
	Marry:QueryWedding(1, me.szName);
end

-- 查询他人的婚礼信息
function tbNpc:QueryOthersWeddingInfo()
	Dialog:AskString("Nhập tên", 16, self.OnAcceptSpeMsg, self);
end

function tbNpc:OnAcceptSpeMsg(szPlayerName)
	local nLen = GetNameShowLen(szPlayerName);
	if nLen <= 0 or nLen > 32 then
		Dialog:Say("Độ dài không chính xác.");
		return;
	end
	Marry:QueryWedding(1, szPlayerName);
end

-- 查找指定日期的婚礼信息
function tbNpc:QuerySpedayWedingInfo()
	local szMsg = "Hãy chọn ngày muốn xem";
	local tbOpt = self:GetQueryDate();
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:GetQueryDate()
	local nCurTime = GetTime();
	local tbOpt = {};
	for i = 0, 6 do
		local nTime = nCurTime + i * 3600 * 24;
		local nDate = tonumber(os.date("%Y%m%d", nTime));
		local szDate = tostring(os.date("%Y-%m-%d", nTime));
		table.insert(tbOpt, {szDate, self.QueryByDate, self, nDate});
	end
	return tbOpt;
end

function tbNpc:QueryByDate(nDate)
	Marry:QueryWedding(2, nDate);
end

function tbNpc:CheckLevel(nLevel)
	if (not nLevel) then
		return 0;
	end
	if (nLevel < self.LEVEL_PINGMIN or nLevel > self.LEVEL_HUANGJIA) then
		return 0;
	end
	
	return 1;
end

--=====================================================================

function tbNpc:CanXiufuCoupleRelation()
	local szErrMsg = "";
	
	local bHasPreWedding, szCoupleName, nPreWeddingDate, nWeddingLevel = Marry:CheckPreWedding(me.szName);
	if (0 == bHasPreWedding) then
		szErrMsg = "Chưa tổ chức hôn lễ, không thể khôi phục quan hệ hiệp lữ.";
		return 0, szErrMsg;
	end
	
	local tblMemberList, nMemberCount = me.GetTeamMemberList()
	if (nMemberCount ~= 2) then
		szErrMsg = "Cần tổ đội 2 người đến để thực hiện.";
		return 0, szErrMsg;
	end
	
	local cTeamMate = tblMemberList[1];
	for _, pPlayer in pairs(tblMemberList) do
		if (pPlayer.szName ~= me.szName) then
			cTeamMate = pPlayer;
			break;
		end
	end
	
	if (me.IsMarried() == 1 or cTeamMate.IsMarried() == 1) then
		szErrMsg = "Ngươi chưa kết hôn, không thể khôi phục quan hệ hiệp lữ.";
		return 0, szErrMsg;
	end
	
	local bHasPreWedding, szCoupleName, nPreWeddingDate, nWeddingLevel = Marry:CheckPreWedding(me.szName);
	if (szCoupleName ~= cTeamMate.szName) then
		szErrMsg = "Đồng đội không phải hiệp lữ.";
		return 0, szErrMsg;
	end
	
	local nCurDate = tonumber(os.date("%Y%m%d", GetTime()));
	local nCurHour = tonumber(os.date("%H", GetTime()));
	if (nCurDate <= nPreWeddingDate or (nCurDate == nPreWeddingDate + 1 and nCurHour < 7)) then
		szErrMsg = "Buổi lễ vẫn chưa kết thúc. Không thể khôi phục.";
		return 0, szErrMsg;
	end
	
	if (me.IsAccountLock() ~= 0 or cTeamMate.IsAccountLock() ~= 0) then
		szErrMsg = "Tài khoản đang bị khóa.";
		return 0, szErrMsg;
	end
	
	return 1;
end

function tbNpc:XiufuCoupleRelationDlg()
	
	local nRet, _, nPreDate = Marry:CheckPreWedding(me.szName);
	if nRet == 1 then
		if nPreDate < 20100601 then
			Dialog:Say("Ngày không hợp lệ.");
			return 0;
		end
	end
	
	local bCanOpt, szErrMsg = self:CanXiufuCoupleRelation();
	if (0 == bCanOpt) then
		if (szErrMsg ~= "") then
			Dialog:Say(szErrMsg);
		end
		return 0;
	end
	
	local szMsg = "Hãy dùng tùy chọn này để khôi phục quan hệ hiệp lữ khi không thể tham dự lễ cưới.";
	
	local tblMemberList, nMemberCount = me.GetTeamMemberList()
	if (nMemberCount ~= 2) then
		return 0;
	end

	local tbOpt = {
		{"Khôi phục", self.XiufuCoupleRelation, self, tblMemberList[1].szName, tblMemberList[2].szName},
		{"Khi khác ta sẽ quay lại"},
		};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:XiufuCoupleRelation(szName1, szName2)
	local pMale = KPlayer.GetPlayerByName(szName1);
	local pFemale = KPlayer.GetPlayerByName(szName2);
	if (not pMale or not pFemale) then
		return 0;
	end
	if (pMale.nSex == 1) then
		pMale, pFemale = pFemale, pMale;
	end
	Relation:AddRelation_GS(pMale.szName, pFemale.szName, Player.emKPLAYERRELATION_TYPE_COUPLE, 1);
	pMale.Msg("Khôi phục thành công, bạn và "..pFemale.szName.." đã trở thành hiệp lữ.");
	pFemale.Msg("Khôi phục thành công, bạn và "..pMale.szName.." đã trở thành hiệp lữ.");
	
	Marry:SetTitle(pMale, pFemale);
	
	local szLog = string.format("%s 与 %s 修复侠侣关系", pMale.szName, pFemale.szName);
	Dbg:WriteLog("Marry", "结婚系统", szLog);
	
	pMale.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("与 %s 修复为夫妻", pFemale.szName));
	pFemale.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("与 %s 修复为夫妻", pMale.szName));
end

--=====================================================================

function tbNpc:GetWeddingRing()

--	if (0 ~= me.GetTask(Marry.TASK_GROUP_ID, Marry.TASK_GET_WEDDING_RING)) then
--		Dialog:Say("你已经领取过侠侣信物了，不要重复领取。");
--		return 0;
--	end
	
	local szCoupleName = me.GetCoupleName();
	if (not szCoupleName or szCoupleName == "") then
		Dialog:Say("Chưa kết hôn. Không thể nhận tín vật.");
		return 0;
	end
	
	local nWeddingLevel = me.GetTask(Marry.TASK_GROUP_ID, Marry.TASK_WEDDING_LEVEL);
	if (nWeddingLevel <= 0 or nWeddingLevel > 4) then
		return 0;
	end
	
	if (me.CountFreeBagCell() < 1) then
		Dialog:Say("Hành trang không đủ 1 ô trống.");
		return 0;
	end
	
	local pItem = me.AddItem(18, 1, 595, nWeddingLevel);
	if (pItem) then
		pItem.SetCustom(Item.CUSTOM_TYPE_EVENT, szCoupleName);
--		me.SetTask(Marry.TASK_GROUP_ID, Marry.TASK_GET_WEDDING_RING, 1);
		
		Dbg:WriteLog("Marry", "结婚系统", me.szAccount, me.szName, "领取了结婚戒指");
	end
end

function tbNpc:PreViewWeddingPlaceDlg()
	local tbNpc = Npc:GetClass("marry_yuelao2");
	tbNpc:OnDialog();
end

-- 前往指定地图参观婚礼场地
function tbNpc:PreViewWeddingPlace(nLevel)
	if (0 == self:CheckLevel(nLevel)) then
		return 0;
	end
	
	local tbMap = Marry.MAP_PREVIEW_INFO[nLevel];
	if tbMap then
		me.NewWorld(unpack(tbMap));
	end
end

function tbNpc:CheckWeddingCond(nLevel)
	if (0 == self:CheckLevel(nLevel)) then
		return 0;
	end
	
	local szErrMsg = "";
	local tblMemberList, nMemberCount = me.GetTeamMemberList()
	if (2 ~= nMemberCount) then
		szErrMsg = "Hãy vào cùng tổ đội và đến đây.";
		return 0, szErrMsg;
	end
	local cTeamMate	= tblMemberList[1];
	for i = 1, #tblMemberList do
		if (tblMemberList[i].szName ~= me.szName) then
			cTeamMate = tblMemberList[i];
		end
	end
	
	if (me.nLevel < self.MINLEVEL_APPWEDDING or
		cTeamMate.nLevel < self.MINLEVEL_APPWEDDING) then
		szErrMsg = string.format("Đẳng cấp chưa đạt <color=yellow>%s<color>.", self.MINLEVEL_APPWEDDING);
		return 0, szErrMsg;
	end
	
	if (me.nSex ~= 0 or cTeamMate.nSex ~= 1) then
		szErrMsg = "Hãy để Phu quân tương lai định ngày tổ chức hôn lễ.";
		return 0, szErrMsg;
	end
	
	if (1 == me.IsMarried() or 1 == cTeamMate.IsMarried()) then
		szErrMsg = "Ngươi đã có hiệp lữ rồi, còn đến đây làm gì?";
		return 0, szErrMsg;
	end
	
	local bIsNearby = 0;
	local tbPlayerList = KPlayer.GetAroundPlayerList(me.nId, 50);
	if (tbPlayerList) then
		for _, pPlayer in ipairs(tbPlayerList) do
			if (pPlayer.szName == cTeamMate.szName) then
				bIsNearby = 1;
			end
		end
	end
	if (0 == bIsNearby) then
		szErrMsg = "Hãy mang đồng đội đến đây";
		return 0, szErrMsg;
	end
	
	local nReSelectTime = me.GetTask(Marry.TASK_GROUP_ID, Marry.TASK_TIME_RESELECTDATE);
	if (nReSelectTime > 0) then
		local nNeedMoney = self.MONEY_BASE * nReSelectTime;
		if (me.nCashMoney < nNeedMoney) then
			szErrMsg = string.format("Ngươi cần <color=yellow>%s<color> ngày để khôi phục, và cần <color=yellow>%s<color> lượng bạc.",
				nReSelectTime, nNeedMoney);
			return 0, szErrMsg;
		end
	end
	
	if Marry:CheckQiuhun(me, cTeamMate) ~= 1 then
		szErrMsg = "Hãy gửi yêu cầu nạp cát trước, sau đó đến tìm ta. Yêu cầu mua Túi quà lễ từ Vạn Hữu Toàn và sử dụng Thẻ nạp cát.";
		return 0, szErrMsg;
	end
	
	return 1;
end

function tbNpc:AppWeddingDlg()
	
--	local nDate = me.GetTask(Marry.TASK_GROUP_ID , Marry.TASK_RESERVE_DATE);
--	local nLevel = me.GetTask(Marry.TASK_GROUP_ID , Marry.TASK_WEDDING_LEVEL);
--	local nRet = Marry:CheckPreWedding(me.szName);
--	if nRet == 0 and nDate > 0 and nLevel > 0 then
--		me.SetTask(Marry.TASK_GROUP_ID, Marry.TASK_WEDDING_LEVEL, 0);
--		me.SetTask(Marry.TASK_GROUP_ID, Marry.TASK_RESERVE_DATE, 0);
--		me.SetTask(Marry.TASK_GROUP_ID, Marry.TASK_RESERVE_MAPLEVEL, 0);
--		me.SetTask(Marry.TASK_GROUP_ID, Marry.TASK_TIME_RESELECTDATE, 0);
--	end
	
	if me.nSex == 1 then
		Dialog:Say("Người nam có thể mua Túi quà lễ tại Vạn Hữu Toàn.\n<color=green>Gợi ý: \n1. Có thể mua Túi quà lễ tại thương nhân buổi lễ.\n2. Nếu người nữ mua nhầm Túi quà lễ có thể đổi lại Hoa Tình.\n3. Có thể mua Túi quà lễ cấp cao hơn để thay thế cho dự định ban đầu.<color>");
		return 0;
	end
	
	if (me.IsMarried() == 1) then
		Dialog:Say("Ngươi đã kết hôn rồi!");
		return 0;
	end
	
	local szMsg = "Hãy chọn cấp độ của hôn lễ.\n<color=green>Gợi ý: \n1. Có thể mua Túi quà lễ tại thương nhân buổi lễ.\n2. Nếu người nữ mua nhầm Túi quà lễ có thể đổi lại Hoa Tình.\n3. Có thể mua Túi quà lễ cấp cao hơn để thay thế cho dự định ban đầu.\n<color>";
	local bNeedCompensation = Marry:CheckCompensation(me.szName);
	if (bNeedCompensation == 1) then
		me.SetTask(Marry.TASK_GROUP_ID, Marry.TASK_TIME_RESELECTDATE, 0);
		if (2 > me.CountFreeBagCell()) then
			szMsg = szMsg .. string.format("\n<color=red>Hành trang không đủ %s ô trống<color>", 2);
			Dialog:Say(szMsg);
			return 0;
		end
	else
		if (me.CountFreeBagCell() < 1) then
			szMsg = szMsg .. "\n<color=red>Hành trang không đủ 1 ô trống<color>";
			Dialog:Say(szMsg);
			return 0;
		end
	end
	
	local nReSelectTime = me.GetTask(Marry.TASK_GROUP_ID, Marry.TASK_TIME_RESELECTDATE);
	if (nReSelectTime > 0) then
		local nNeedMoney = self.MONEY_BASE * nReSelectTime;
		szMsg = szMsg .. string.format("\n<color=red>Lưu ý:<color> Đã chọn lại <color=yellow>%s<color>, đồng thời sẽ tiêu hao <color=yellow>%s<color> lượng bạc.",
			nReSelectTime, nNeedMoney);
	end
	
	local tbOpt = {
		{"Đặt lễ", self.GetLibao, self},
		{"Để ta suy nghĩ lại"},
		};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:GetLibao()
	Dialog:OpenGift("Hãy đặt vào Túi quà lễ.<color=green>\nCó thể đặt Túi quà lễ cao cấp hơn để thay đổi cấp độ hôn lễ ban đầu.<color>", nil, {self.OnOpenGiftOk, self});
end

function tbNpc:ChechItem(tbItem)
	local bRighitItem = 0;
	for _, szGDPL in pairs(self.tbLibaoGDPL) do
		local szItem = string.format("%s-%s-%s-%s",tbItem[1].nGenre, tbItem[1].nDetail,
			tbItem[1].nParticular, tbItem[1].nLevel);
		if (szGDPL == szItem) then
			bRighitItem = 1;
			break;
		end
	end
	return bRighitItem;
end

function tbNpc:OnOpenGiftOk(tbItemObj)
	if (Lib:CountTB(tbItemObj) ~= 1) then
		Dialog:Say("Vật phẩm không đúng.");
		return 0;
	end
	
	local tbItem = tbItemObj[1];
	if (self:ChechItem(tbItem) == 0) then
		Dialog:Say("Vật phẩm không đúng.");
		return 0;
	end
	
	local pItem = tbItem[1];
	
	local tbQiuhunLibao = Item:GetClass("marry_xinhunlibao");
	if (tbQiuhunLibao:IsNewItem(pItem) ~= 1) then
		Dialog:Say("Túi quà lễ này đã được sử dụng.");
		return 0;
	end

	local nWeddingLevel = pItem.nLevel;
	
	local nPreWeddingLevel = me.GetTask(Marry.TASK_GROUP_ID, Marry.TASK_WEDDING_LEVEL);
	if (pItem.nLevel < nPreWeddingLevel) then
		Dialog:Say("Không thể thực hiện, hãy đặt Túi quà lễ đồng cấp hoặc cao cấp hơn.");
		return 0;
	end
	
	local bCanWedding, szErrMsg = self:CheckWeddingCond(nWeddingLevel);
	if (0 == bCanWedding) then
		if (szErrMsg and szErrMsg ~= "") then
			Dialog:Say(szErrMsg);
		end
		return 0;
	end
	
	local tblMemberList, nMemberCount = me.GetTeamMemberList()
	if (2 ~= nMemberCount) then
		return 0;
	end
	local cTeamMate	= tblMemberList[1];
	for i = 1, #tblMemberList do
		if (tblMemberList[i].szName ~= me.szName) then
			cTeamMate = tblMemberList[i];
		end
	end
	
	if (pItem.szCustomString and pItem.szCustomString ~= "" and
		cTeamMate.szName ~= pItem.szCustomString) then
		Dialog:Say(string.format("Túi quà lễ này chỉ có thể được sử dụng để xác định và sửa đổi ngày lễ với <color=yellow>%s<color>.",
			pItem.szCustomString));
		return 0;
	end

	-- self:SelectDate(pItem, nWeddingLevel, nPlaceLevel);
	local szMsg = string.format("Ngươi chắc chắn dùng Túi quà lễ này đặt hôn lễ <color=yellow>%s<color> chứ?",
		self.tbWeddingInfo[nWeddingLevel].szName);
	local tbOpt = {
		{"Đồng ý", self.SureAppWedding, self, pItem.dwId},
		{"Để ta suy nghĩ thêm"},
		};
	Dialog:Say(szMsg, tbOpt);
end

-- 是否确定要预定婚期
function tbNpc:SureAppWedding(dwItemId)
	local pItem = KItem.GetObjById(dwItemId);
	if (not pItem) then
		return;
	end
	local nWeddingLevel = pItem.nLevel;
	local szMsg = "Tùy theo cấp độ của Túi quà lễ mà hôn lễ có thể được đặt ở những vị trí sau:";
	local tbOpt = {};
	for i = nWeddingLevel, self.LEVEL_PINGMIN, -1 do
		local szOpt = string.format("Hôn lễ %s", self.tbWeddingInfo[i].szName);
		table.insert(tbOpt, {szOpt, self.SelectDate, self, dwItemId, i});
	end
	table.insert(tbOpt, {"Kết thúc đối thoại"});
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:SelectWeddingPlace(nWeddingLevel, nPlaceLevel)
	local szMsg = "Đặt Túi quà lễ để kiểm tra cấp độ tương ứng";
	local tbOpt = {
		{"Đặt lễ", self.GetLibao, self, nWeddingLevel, nPlaceLevel},
		{"Kết thúc đối thoại"},
		};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:GetDateOpt(dwItemId, nPlaceLevel, nStartOrderTime)
	local tbOpt = {};
	local pItem = KItem.GetObjById(dwItemId);
	if (not pItem) then
		return;
	end
	local nWeddingLevel = pItem.nLevel;
	if (nWeddingLevel == self.LEVEL_HUANGJIA) then
		local nTuesdayTime = 0;
		local nTime = GetTime();
		if (nStartOrderTime) then
			nTime = nStartOrderTime;
		end
		for i = 1, 7 do
			nTime = nTime + 3600 * 24;
			local nWeekday = tonumber(os.date("%w", nTime));
			if (2 == nWeekday) then
				nTuesdayTime = nTime;
				break;
			end
		end
	
		local nStartTime = nTuesdayTime;
		local nEndTime = nTuesdayTime + 3600 * 24 * 6;
		for i = 1, 4 do
			local szStartDay = os.date("%Y-%m-%d", nStartTime);
			local szEndDay = os.date("%Y-%m-%d", nEndTime);
			local szOpt = string.format("<color=yellow>%s - %s<color>", szStartDay, szEndDay);
			local nDate = tonumber(os.date("%Y%m%d", nStartTime));
			if (Marry:CheckAddWedding(nWeddingLevel, nDate) == 1) then
				table.insert(tbOpt, {szOpt, self.GetDateOpt_HuangJia, self, dwItemId, nPlaceLevel, nStartTime});
			end
			
			nStartTime = nStartTime + 3600 * 24 * 7;
			nEndTime = nEndTime + 3600 * 24 * 7;
		end
	else
		local nTime = GetTime();
		if (nStartOrderTime) then
			nTime = nStartOrderTime;
		end
		for i = 1, 7 do
			nTime = nTime + 3600 * 24;
			local szDate = tostring(os.date("%Y-%m-%d", nTime));
			local nDate = tonumber(os.date("%Y%m%d", nTime));
			if (Marry:CheckAddWedding(nWeddingLevel, nDate) == 1) then
				table.insert(tbOpt, {string.format("<color=yellow>%s<color>", szDate), self.SelectCertainDate, self, dwItemId, nPlaceLevel, nTime});
			end
		end
	end
	table.insert(tbOpt, {"Trở về", self.SureAppWedding, self, dwItemId});
	return tbOpt;
end

-- 皇家婚礼的再次选择日期选项（因为皇家婚礼的举办时间是一周只举行一次，需要再次确定是在那天举行婚礼）
function tbNpc:GetDateOpt_HuangJia(dwItemId, nPlaceLevel, nStartTime)
	local szMsg = "Hãy chọn thời gian cụ thể";
	local tbOpt = {};
	for i = 0, 6 do
		local nTime = nStartTime + i * 3600 * 24;
		local szDate = tostring(os.date("%Y-%m-%d", nTime));
		local nDate = tonumber(os.date("%Y%m%d", nTime));
		table.insert(tbOpt, {string.format("<color=yellow>%s<color>", szDate), self.SelectCertainDate, self, dwItemId, nPlaceLevel, nTime});
	end
	table.insert(tbOpt, {"Trở về", self.SureAppWedding, self, dwItemId});
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:SelectDate(dwItemId, nPlaceLevel)
	local szMsg = "Hãy chọn ngày";
	local nStartOrderTime = Lib:GetDate2Time(Marry.START_TIME) - 3600 * 24;
	if GetTime() > nStartOrderTime then
		nStartOrderTime = GetTime();
	end
	local tbOpt = self:GetDateOpt(dwItemId, nPlaceLevel, nStartOrderTime);
	if (#tbOpt == 1) then
		szMsg = "Thời gian này đã hết hạn, hãy chọn ngày khác.";
	end
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:CheckDate(nTime, nWeddingLevel)
	local szErrMsg = "";
	local nOk = Marry:CheckAddWedding(nWeddingLevel, nTime);
	if nOk ~= 1 then
		szErrMsg = "Thời gian này đã hết hạn, hãy chọn ngày khác.";
		return 0, szErrMsg;
	end
	return 1;
end

function tbNpc:SelectCertainDate(dwItemId, nPlaceLevel, nTime)
	local nDate = tonumber(os.date("%Y%m%d", nTime));
	local pItem = KItem.GetObjById(dwItemId);
	if (not pItem) then
		return 0;
	end
	local bCanSelect, szErrMsg = self:CheckDate(nDate, pItem.nLevel);
	if (0 == bCanSelect) then
		if (szErrMsg ~= "") then
			Dialog:Say(szErrMsg,
				{{"Chọn lại", self.SelectDate, self, dwItemId, nPlaceLevel},
				{"Kết thúc đối thoại"},}
				);
		end
		return 0;
	end
	
	local szDate = tostring(os.date("%Y-%m-%d", nTime));
	local szMsg = string.format("Ngươi đã chọn <color=yellow>%s<color> cử hành hôn lễ, chắc chắn chứ?", szDate);
	local tbOpt = {
		{"Xác nhận", self.SureSelectDate, self, dwItemId, nPlaceLevel, nTime},
		{"Chọn lại ngày", self.SelectDate, self, dwItemId, nPlaceLevel},
		{"Kết thúc đối thoại"},
		};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:SureSelectDate(dwItemId, nPlaceLevel, nTime)
	local pItem = KItem.GetObjById(dwItemId);
	if (not pItem) then
		return 0;
	end
	
	local nDate = tonumber(os.date("%Y%m%d", nTime));
	local nCurDate = tonumber(os.date("%Y%m%d", GetTime()));
	if (nDate <= nCurDate) then
		Dialog:Say("Không thể đặt ngày này.");
		return 0;
	end
	local nWeddingLevel = pItem.nLevel;
	local bCanWedding, szErrMsg = self:CheckWeddingCond(nWeddingLevel);
	if (0 == bCanWedding) then
		if (szErrMsg and szErrMsg ~= "") then
			Dialog:Say(szErrMsg);
		end
		return 0;
	end
	
	local tblMemberList, nMemberCount = me.GetTeamMemberList()
	if (2 ~= nMemberCount) then
		return 0;
	end
	
	local cTeamMate	= tblMemberList[1];
	for i = 1, #tblMemberList do
		if (tblMemberList[i].szName ~= me.szName) then
			cTeamMate = tblMemberList[i];
		end
	end
	
	-- 服务器增加预订婚礼
	local nWeddingLevel = pItem.nLevel;
	if Marry:CheckAddWedding(nWeddingLevel, nDate) ~= 1 then
		return 0;
	end
	
	local nRet, _, nPreDate = Marry:CheckPreWedding(me.szName);
	local nReSelectTime = me.GetTask(Marry.TASK_GROUP_ID, Marry.TASK_TIME_RESELECTDATE);
	if (1 == nRet and nReSelectTime > 0) then
		local nCurDate = tonumber(os.date("%Y%m%d", GetTime()));
		local nCurTime = tonumber(os.date("%H%M", GetTime()));
		
		-- 上午11:50之后就不要重新选择婚礼了
		if (nPreDate == nCurDate and nCurTime >= 1150 and nCurTime < 1200) then
			Dialog:Say("Buổi lễ sắp diễn ra, quá muộn để đặt lễ.");
			return 0;
		elseif (nPreDate == nCurDate and nCurTime >= 1200) then
			Dialog:Say("Buổi lễ đã diễn ra, quá muộn để đặt lễ.");
			return 0;
		elseif (nPreDate < nCurDate) then
			Dialog:Say("Buổi lễ đã bắt đầu, không thể lên kế hoạch lại.");
			return 0;
		end
	end
	
	Marry:AddWedding_GS(nWeddingLevel, nDate, {me.szName, cTeamMate.szName, nPlaceLevel}, dwItemId, nTime);
end

function tbNpc:GetCoupleTitleDlg()
	local szMsg = "Nếu danh hiệu hiệp lữ biến mất, ta có thể thêm lại cho ngươi!";
	local tbOpt = {
		{"Khôi phục", self.GetCoupleTitle, self},
		{"Để ta suy nghĩ thêm"},
		};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:GetCoupleTitle()
	local szCoupleName = me.GetCoupleName();
	if (not szCoupleName) then
		Dialog:Say("Ngươi chưa có hiệp lữ");
		return 0;
	end
	
	local tblMemberList, nMemberCount = me.GetTeamMemberList()
	if (2 ~= nMemberCount) then
		Dialog:Say("Phải có đủ 2 thành viên trong tổ đội.");
		return 0;
	end
	local cTeamMate	= tblMemberList[1];
	for i = 1, #tblMemberList do
		if (tblMemberList[i].szName ~= me.szName) then
			cTeamMate = tblMemberList[i];
		end
	end
	
	if (szCoupleName ~= cTeamMate.szName) then
		Dialog:Say("Đồng đội không phải hiệp lữ của ngươi.");
		return 0;
	end
	
	Marry:SetTitle(me, cTeamMate)
	Dialog:Say("Đã khôi phục danh hiệu hiệp lữ.");
	Setting:SetGlobalObj(cTeamMate);
	Dialog:Say("Đã khôi phục danh hiệu hiệp lữ.");
	Setting:RestoreGlobalObj();
end
