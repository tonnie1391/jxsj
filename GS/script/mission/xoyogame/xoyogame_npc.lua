--
-- 逍遥谷 NPC逻辑

XoyoGame.TASK_GROUP_MEDICINE = 2050;
XoyoGame.TASK_GET_MEDICINE_TIME = 53;

XoyoGame.nLastBroadcast = 0;
XoyoGame.nBroadcastNpcId = 0;
XoyoGame.nBroadcastMapId = 0;

function XoyoGame:CanGetMedicine()
	if SpecialEvent: IsWellfareStarted_Remake() ~= 1 then
		return 0, "Tính năng này vẫn chưa mở.";
	end
	
	if me.nLevel < 30 then
		return 0, "Bạn phải đạt cấp 30 mới có thể nhận dược phẩm Tiêu Dao Cốc.";
	end
	
	local nTime = tonumber(os.date("%Y%m%d", GetTime()));
	local nLastTime = me.GetTask(self.TASK_GROUP_MEDICINE, self.TASK_GET_MEDICINE_TIME);
	if nTime == nLastTime then
		return 0, "Hôm nay ngươi đã nhận, mai hãy quay lại.";
	end
	
	if me.CountFreeBagCell() < 1 then
		return 0, "Túi đã đầy, chừa 1 ô trống mới có thể nhận.";
	end
	
	return 1;
end

function XoyoGame:GetMedicine()
	local nRes, szMsg = self: CanGetMedicine();
	if nRes == 0 then
		Dialog:Say(szMsg);
		return;
	end
	
	local tbOpt = {
		{"Hồi Huyết Đơn-Rương", XoyoGame.GetMedicine2, XoyoGame, 1},
		{"Hồi Nội Đơn-Rương", XoyoGame.GetMedicine2, XoyoGame, 2},
		{"Càn Khôn Tạo Hóa Hoàn-Rương", XoyoGame.GetMedicine2, XoyoGame, 3},
		{"Ta chỉ đến xem"},
		};
	Dialog:Say("Ngươi muốn nhận loại nào?", tbOpt);
end

XoyoGame.tbFreeMedicine = {
	[30] = {
		[1] = {18,1,352,5},
		[2] = {18,1,353,5},
		[3] = {18,1,354,5},
		},
	[50] = {
		[1] = {18,1,352,4},
		[2] = {18,1,353,4},
		[3] = {18,1,354,4},
		},
	[80] = {
		[1] = {18,1,352,1},
		[2] = {18,1,353,1},
		[3] = {18,1,354,1},
		},
	[90] = {
		[1] = {18,1,352,2},
		[2] = {18,1,353,2},
		[3] = {18,1,354,2},
		},
	[110] = {
		[1] = {18,1,352,3},
		[2] = {18,1,353,3},
		[3] = {18,1,354,3},
		},
	};

function XoyoGame:GetMedicine2(nType)
	local nRes, szMsg = self: CanGetMedicine();
	if nRes == 0 then
		Dialog:Say(szMsg);
		return;
	end
	
	local nLevel;
	if me.nLevel >= 110 then
		nLevel = 110;
	elseif me.nLevel >= 90 then
		nLevel = 90;
	elseif me.nLevel >= 80 then
		nLevel = 80
	elseif me.nLevel >= 50 then
		nLevel = 50;
	elseif me.nLevel >= 30 then
		nLevel = 30;
	end
	
	local pItem = me.AddItem(unpack(self.tbFreeMedicine[nLevel][nType]));
	me.SetItemTimeout(pItem, 24*60, 0)
	me.SetTask(self.TASK_GROUP_MEDICINE, self.TASK_GET_MEDICINE_TIME, tonumber(os.date("%Y%m%d", GetTime())));
	Dbg: WriteLog("XoyoGame", string.format("%s nhận được Dược Phẩm Tiêu Dao %s", me.szName, pItem.szName));
end

function XoyoGame:JieYinRen()
	Dialog:Say("Dạo này có rất nhiều người muốn đến Tiêu Dao Cốc, ngươi cũng vậy sao?",
		{
			{"Đưa ta đến cổng Tiêu Dao Cốc 1", self.ToBaoMingDian, self, 341},
			{"Đưa ta đến cổng Tiêu Dao Cốc 2", self.ToBaoMingDian, self, 342},
			{"Tự động tổ đội", self.OpenAutoTeamUi, self},
			{"Ta chỉ ghé qua thôi"},
		})
end

function XoyoGame:BroadcastRank()
	return XoyoGame:__BroadcastRank();
end

function XoyoGame:__BroadcastRank()
	if XoyoGame.nBroadcastNpcId <= 0 then
		local tbNpcList = KNpc.GetMapNpcWithName(341, "Hoàng Phỉ");
		XoyoGame.nBroadcastMapId = 341;
		if not tbNpcList or #tbNpcList == 0 then
			XoyoGame.nBroadcastMapId = 342;
			tbNpcList = KNpc.GetMapNpcWithName(342, "Hoàng Phỉ");
		end
		if not tbNpcList or #tbNpcList == 0 then
			XoyoGame.nBroadcastMapId = 0;
			return;
		end
		XoyoGame.nBroadcastNpcId = tbNpcList[1];
	end
	
	local szDesc = self: GetBroadcastRank();
	if not szDesc then
		return;
	end
	local pNpc = KNpc.GetByIndex(XoyoGame.nBroadcastNpcId);
	if not pNpc then
		return;
	end
	pNpc.SendChat(szDesc);
	if (XoyoGame.nBroadcastMapId == 0) then
		print("Error When nBroadcastMapId is 0");
		return;
	end
	local tbPlayList, nCount = KPlayer.GetMapPlayer(XoyoGame.nBroadcastMapId);
	for _, teammate in ipairs(tbPlayList) do
		teammate.Msg(szDesc, pNpc.szName);
	end;
end

function XoyoGame:GetBroadcastRank()
	local nDifficuty, nRank;
	local nMax = #XoyoGame.LevelDesp * XoyoGame.RANK_RECORD - 1;
	local nRepeat = 0;
	repeat
		nRepeat = nRepeat + 1;
		if nRepeat > nMax then
			return;
		end
		if XoyoGame.nLastBroadcast >= nMax then
			XoyoGame.nLastBroadcast = 0;
		else
			XoyoGame.nLastBroadcast = XoyoGame.nLastBroadcast + 1;
		end
		nDifficuty = math.floor(XoyoGame.nLastBroadcast / XoyoGame.RANK_RECORD) + 1;
		nRank = XoyoGame.nLastBroadcast % XoyoGame.RANK_RECORD + 1;
	until XoyoGame.tbXoyoRank[nDifficuty] and XoyoGame.tbXoyoRank[nDifficuty][nRank];
	local tbRank = XoyoGame.tbXoyoRank[nDifficuty][nRank];
	if not tbRank then
		return;
	end
	
	local szDesc = "<color=white>Tiêu Dao Cốc<color=orange>[%s]<color>    Kỷ lục Top %d:  <color=orange>%s<color>   do đội <color=yellow>%s<color> vào %s<color>"
	local szDate = os.date("%Y-%m-%d", tbRank.nDate);
	local szTimeUsed = os.date("%M phút %S", tbRank.nTime);
	local szCaptain = tbRank.tbMember[1];
	local szDifficuty = XoyoGame.LevelDesp[nDifficuty][2];
	szDesc = string.format(szDesc, szDifficuty, nRank, szTimeUsed, szCaptain, szDate);
	return szDesc;
end

function XoyoGame:WatchRecord()
	local tbOpt = {};
	for nSortIndex = 1, #XoyoGame.LevelDespSortIndex do
		local i = XoyoGame.LevelDespSortIndex[nSortIndex];
		if XoyoGame.LevelDesp[i][1] == 1 then
			table.insert(tbOpt, {XoyoGame.LevelDesp[i][2] .. ": " .. XoyoGame.LevelDesp[i][3], self.WatchRecordDetails, self, i});
		elseif XoyoGame.LevelDesp[i][1] == 0 then
			table.insert(tbOpt, {"<color=gray>" .. XoyoGame.LevelDesp[i][2] .. ": " .. XoyoGame.LevelDesp[i][3] .. "<color>", self.NotOpenDifficuty, self});
		end
	end
	table.insert(tbOpt, {"Kết thúc đối thoại"});
	Dialog:Say("Có thể tra độ khó ở đây", tbOpt);
end

function XoyoGame:WatchRecordDetails(nDifficuty)
	if not XoyoGame.tbXoyoRank[nDifficuty] or #XoyoGame.tbXoyoRank[nDifficuty] == 0 then
		Dialog:Say("Không có kỷ lục độ khó này");
		return;
	end
	local szMsg  = string.format("Đang xem <color=orange>Độ khó %s<color>, gồm:\n\n", XoyoGame.LevelDesp[nDifficuty][2]);
	for nRank, tbInfo in ipairs(XoyoGame.tbXoyoRank[nDifficuty]) do
		szMsg = szMsg .. string.format("Hạng: %d \n", nRank);
		szMsg = szMsg .. os.date("Ngày thiết lập: %Y-%m-%d\n", tbInfo.nDate);
		szMsg = szMsg .. os.date("Thời gian: <color=yellow>%M phút %S<color>\n", tbInfo.nTime);
		szMsg = szMsg .. "Đội gồm: ";
		for _, szName in ipairs(tbInfo.tbMember) do
			szMsg = szMsg .. szName .. " ";
		end
		szMsg = szMsg .. "\n\n";
	end
	Dialog:Say(szMsg);
end

function XoyoGame:TestWatch()
	local tbOpt = 
	{
		{"Gia tộc tháng trước", self.WatchPreKinRecord, self},
		{"Cá nhân tháng trước", self.WatchPreRecord, self},
		{"Dữ liệu gia tộc", self.Test_WatchKinDataRecord,self},	
	};
	Dialog:Say("Hãy chọn", tbOpt);
end

function XoyoGame:Test_WatchKinDataRecord()
	local nKinId, nMemberId = me.GetKinMember();
	local cKin = KKin.GetKin(nKinId);
	local szMsg = "Điểm cá nhân: " .. me.GetTask(self.TASK_GROUP, self.TOLL_GATE_POINT) .. "\n";
	if cKin then
		szMsg = szMsg .. string.format("Tháng: %s\nĐiểm: %s\nThời gian: %s", cKin.GetXoyoMonth(), cKin.GetXoyoPoint(), os.date("%Y-%m-%d %H:%M:%S", cKin.GetXoyoLastTime()));
	end
	Dialog:Say(szMsg);
end

function XoyoGame:WatchPreRecord()
	local tbOpt = {};
	for nSortIndex = 1, #XoyoGame.LevelDespSortIndex do
		local i = XoyoGame.LevelDespSortIndex[nSortIndex];
		if XoyoGame.LevelDesp[i][1] == 1 then
			table.insert(tbOpt, {XoyoGame.LevelDesp[i][2] .. ": " .. XoyoGame.LevelDesp[i][3], self.WatchPreRecordDetails, self, i});
		elseif XoyoGame.LevelDesp[i][1] == 0 then
			table.insert(tbOpt, {"<color=gray>" .. XoyoGame.LevelDesp[i][2] .. ": " .. XoyoGame.LevelDesp[i][3] .. "<color>", self.NotOpenDifficuty, self});
		end
	end
	table.insert(tbOpt, {"Kết thúc đối thoại"});
	Dialog:Say("Đang xem kỷ lục", tbOpt);
end

function XoyoGame:WatchPreRecordDetails(nDifficuty)
	if not XoyoGame.tbLastMonthXoyoRank[nDifficuty] or #XoyoGame.tbLastMonthXoyoRank[nDifficuty] == 0 then
		Dialog:Say("当前难度下没有任何纪录");
		return;
	end
	local szMsg  = string.format("您正在查看<color=orange>%s难度<color>下的通关纪录: \n\n", XoyoGame.LevelDesp[nDifficuty][2]);
	for nRank, tbInfo in ipairs(XoyoGame.tbLastMonthXoyoRank[nDifficuty]) do
		szMsg = szMsg .. string.format("Độ khó: %d\n", nRank);
		szMsg = szMsg .. os.date("日期: %Y-%m-%d\n", tbInfo.nDate);
		szMsg = szMsg .. os.date("用时: <color=yellow>%M:%S<color>\n", tbInfo.nTime);
		szMsg = szMsg .. "队员: ";
		for _, szName in ipairs(tbInfo.tbMember) do
			szMsg = szMsg .. szName .. " ";
		end
		szMsg = szMsg .. "\n\n";
	end
	Dialog:Say(szMsg);
end

function XoyoGame.WatchPreKinRecord()
	if not XoyoGame.tbLastMonthXoyoKinRank or #XoyoGame.tbLastMonthXoyoKinRank == 0 then
		Dialog:Say("本月暂时还没有地狱逍遥谷家族积分记录");
		return;
	end
	local szMsg = "您正在查看上月<color=yellow>地狱逍遥谷<color>家族积分记录: \n\n";
	local nKinId, nMemberId = me.GetKinMember();
	for nRank, tbInfo in ipairs(XoyoGame.tbLastMonthXoyoKinRank) do
		szMsg = szMsg .. string.format("第%d名: \n", nRank);
		szMsg = szMsg .. string.format("家族: %s\n", tbInfo.szName);
		szMsg = szMsg .. string.format("积分: %s\n", tbInfo.nPoint);
		szMsg = szMsg .. os.date("最后一次通关时间: %Y年%m月%d日%H时%M分%S秒\n\n", tbInfo.nTime);
	end
	Dialog:Say(szMsg);
end

function XoyoGame:WatchKinRecord()
	local szInfo = "<color=yellow>活动介绍: <color>家族成员击败<color=yellow>逍遥谷地狱关卡BOSS<color>，获得积分累积进行家族排名。月终排入前十名家族的正式成员和荣誉成员，在领取逍遥录奖励时将获得<color=yellow>额外20%<color>的奖励加成。\n\n"; 
	if not XoyoGame.tbXoyoKinRank or #XoyoGame.tbXoyoKinRank == 0 then
		Dialog:Say(szInfo .. "本月暂时还没有地狱关卡家族积分排行。");
		return;
	end
	local szMsg = szInfo;
	local nKinId, nMemberId = me.GetKinMember();
	local cKin = KKin.GetKin(nKinId);
	if cKin then
		local nMonth = cKin.GetXoyoMonth();
		local nTaskMonth = KGblTask.SCGetDbTaskInt(DBTASK_XOYO_RANK_LAST_MONTH, nMonth);
		if nMonth < nTaskMonth then
			szMsg  = szMsg .. "家族本月积分: <color=green>0分<color>\n\n";
		elseif nMonth == nTaskMonth then
			szMsg = szMsg .. string.format("家族本月积分: <color=green>%s分<color>\n\n", cKin.GetXoyoPoint());
		end
	end
	szMsg = szMsg .. "<color=yellow>--------地狱关卡家族积分排行-------<color>\n\n"
	for nRank, tbInfo in ipairs(XoyoGame.tbXoyoKinRank) do
		if nRank > 5 then
			break;
		end
		szMsg = szMsg .. string.format("第<color=yellow>%d<color>名: <color=green>%s分<color>\n", nRank, tbInfo.nPoint);
		szMsg = szMsg .. string.format("家 族: <color=green>%s<color>\n\n", tbInfo.szName);
	end
	local tbOpt = {};
	if #XoyoGame.tbXoyoKinRank > 5 then
		table.insert(tbOpt, {"Trang sau", XoyoGame.WatchKinRecordNextPage, XoyoGame});
	end
	table.insert(tbOpt, {"Kết thúc đối thoại"});
	Dialog:Say(szMsg, tbOpt);
end

function XoyoGame:WatchKinRecordNextPage()
	local szMsg = "<color=yellow>--------地狱关卡家族积分排行-------<color>\n\n"
	for nRank, tbInfo in ipairs(XoyoGame.tbXoyoKinRank) do
		if nRank > 5 then
			szMsg = szMsg .. string.format("第<color=yellow>%d<color>名: <color=green>%s分<color>\n", nRank, tbInfo.nPoint);
			szMsg = szMsg .. string.format("家 族: <color=green>%s<color>\n\n", tbInfo.szName);
		end
	end
	Dialog:Say(szMsg);
end

function XoyoGame:ToBaoMingDian(nMapId)
	if me.nLevel < self.MIN_LEVEL then
		Dialog:Say("Chưa đạt cấp "..self.MIN_LEVEL.." không thể tham gia!");
		return 0;
	end
	if me.GetCamp() == 0 then
		Dialog:Say("Ngươi chưa vào phái, hãy gia nhập môn phái rồi đến tìm lão phu.");
		return 0;
	end
	me.NewWorld(nMapId, unpack(self.BAOMING_IN_POS))
end

function XoyoGame:OpenAutoTeamUi()
	me.CallClientScript({ "AutoTeam: OpenUi" });
end

function XoyoGame:NotOpenDifficuty()
	Dialog:Say("Độ khó này chưa mở.");
end

function XoyoGame:DocumentDifficuty(nTeamId, nDifficuty)
	local tbMemberList, nCount = KTeam.GetTeamMemberList(nTeamId);
	for _, nPlayerId in pairs(tbMemberList) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			pPlayer.SetTask(XoyoGame.TASK_GROUP, XoyoGame.TASK_DIFFICUTY, nDifficuty);
		end
	end
end

function XoyoGame:GetOnlineTeamMember(nTeamId)
	local tbMemberList, nCount = KTeam.GetTeamMemberList(nTeamId);
	if nCount == 0 then
		return;
	end
	for _, nPlayerId in pairs(tbMemberList) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			return pPlayer;
		end
	end
end

function XoyoGame:GetDifficuty(nTeamId)
	local pPlayer = self: GetOnlineTeamMember(nTeamId);
	if not pPlayer then
		return 1; -- 防止报错
	end
	local nDifficuty = pPlayer.GetTask(XoyoGame.TASK_GROUP, XoyoGame.TASK_DIFFICUTY);
	if nDifficuty == 0 then
		nDifficuty = 1;
	end
	return nDifficuty;
end

function XoyoGame:TellLevelRequire(nDifficuty)
	local szTips = string.format(
		"Tiêu Dao Cốc <color=orange>[%s]<color> yêu cầu cả đội có cấp độ tối thiểu là <color=yellow>%d<color> mới có thể khiêu chiến.",
		XoyoGame.LevelDesp[nDifficuty][2],
		XoyoGame.DifficutyRequire[nDifficuty]);
	Dialog:Say(szTips);
end

function XoyoGame:GetTeamMinLevel(nTeamId)
	if nTeamId == 0 then
		return 0;
	end
	local tbMemberList, nMemberCount = KTeam.GetTeamMemberList(nTeamId);
	if nMemberCount == 0 then
		return 0;
	end
	local nMinLevel = 999;
	for _, nPlayerId in pairs(tbMemberList) do
		local nLevel = KGCPlayer.OptGetTask(nPlayerId, 11)
		if (nMinLevel > nLevel) then
			nMinLevel = nLevel;
		end
	end
	return nMinLevel;
end

function XoyoGame:ApplyJoinGame(nDifficuty, nGameId)
	if me.GetTiredDegree1() == 2 then
		Dialog:Say("您太累了，还是休息下吧！");
		return;
	end
	if me.nTeamId == 0 then
		Dialog:Say("1  Trong cốc địa hình phức tạp, gian nguy dị thường, vì an toàn của các ngươi, <color=green>mỗi người mỗi ngày chỉ có thể vào cốc hai lần, hơn nữa ít nhất phải có bốn người kết bạn thông hành<color>, lão phu mới cho phép các ngươi tiến vào. Được rồi, tìm đủ đồng bọn cùng nhau liền để cho đội trưởng đến báo danh với ta đi. Lão phu mỗi ngày <color=yellow>từ 0 giờ sáng đến 2 giờ sáng, 8 giờ sáng đến 23 giờ tối<color> và <color=green>cách mỗi 30 phút<color> sẽ dẫn ngươi đi.", tbOpt);
		return;
	end
	local nManagerId = him.nMapId
	if not self.tbManager[nManagerId] or not self.tbManager[nManagerId].tbData then
		me.Msg("not self.tbManager[nManagerId]")
		return 0;
	end
	local nCurTime = tonumber(os.date("%H%M", GetTime()));
	if not self.__debug_test and (nCurTime < self.START_TIME1 or nCurTime >= self.END_TIME1) and
		(nCurTime < self.START_TIME2 or nCurTime >= self.END_TIME2) then
		Dialog:Say("Hãy đến gặp lão phu từ <color=yellow>0 giờ đến 2 giờ và 08 giờ đến 23 giờ<color> mỗi ngày!")
		return 0;
	end
	local tbOpt = {};
	if not nDifficuty then
		local nIndex = 1;
		for nSortIndex = 1, #XoyoGame.LevelDespSortIndex do
			local i = XoyoGame.LevelDespSortIndex[nSortIndex];
			if XoyoGame.LevelDesp[i][1] == 1 then
				if (XoyoGame:GetTeamMinLevel(me.nTeamId) < XoyoGame.DifficutyRequire[i]) then
					tbOpt[nIndex] = { XoyoGame.LevelDesp[i][2] .. ": " .. XoyoGame.LevelDesp[i][3], self.TellLevelRequire, self, i};
				else
					tbOpt[nIndex] = { XoyoGame.LevelDesp[i][2] .. ": " .. XoyoGame.LevelDesp[i][3], self.ApplyJoinGame, self, i};
				end
				nIndex = nIndex + 1;
			elseif XoyoGame.LevelDesp[i][1] == 0 then
				tbOpt[nIndex] = { "<color=gray>" .. XoyoGame.LevelDesp[i][2] .. ": " .. XoyoGame.LevelDesp[i][3] .. "<color>", self.NotOpenDifficuty, self};
				nIndex = nIndex + 1;
			end
		end
		table.insert(tbOpt, {"Kết thúc đối thoại"});
		Dialog:Say("Gần đây rất nhiều hiệp sĩ trẻ tuổi có kinh nghiệm còn nông cũng nhao nhao đến báo danh muốn vào cốc tìm hiểu đến tột cùng, xét thấy tiêu dao cốc đặc biệt mở ra độ khó đơn giản này cho hiệp sĩ cấp 30 trở lên tham dự, hy vọng có được, có biết, có thu hoạch!\n<color=yellow>Lưu ý: Thông qua độ khó Đơn giản Tiêu Dao Cốc không thể đạt được điều kiện nhiệm vụ hiệp khách, vui lòng chọn độ khó thận trọng. <color>\n\nGiờ hãy chọn độ khó đi", tbOpt);
		return 0;
	end
	if not nGameId then
		for i, nCurGameId in pairs(self.MANAGER_GROUP[nManagerId]) do
			if self.START_SWITCH[nCurGameId] == 1 then
				local szTeamCount = "(Chưa mở)"
				if self.tbManager[nManagerId].tbData[nCurGameId] then
					if self.tbManager[nManagerId].tbData[nCurGameId] < self.MAX_TEAM then
						szTeamCount = "(Đã có "..self.tbManager[nManagerId].tbData[nCurGameId].." đội)"
					else
						szTeamCount = "(Đã đầy)";
					end
				end
				table.insert(tbOpt, {string.format("Đến Tiêu Dao Cốc %s %s", i, szTeamCount), self.ApplyJoinGame, self, nDifficuty, nCurGameId})
			end
		end
		table.insert(tbOpt, {"Ta vẫn chưa chuẩn bị xong, sẽ quay lại sau"});
		Dialog:Say("2  Trong cốc địa hình phức tạp, gian nguy dị thường, vì an toàn của các ngươi, <color=green>mỗi người mỗi ngày chỉ có thể vào cốc hai lần, hơn nữa ít nhất phải có bốn người kết bạn thông hành<color>, lão phu mới cho phép các ngươi tiến vào. Được rồi, tìm đủ đồng bọn cùng nhau liền để cho đội trưởng đến báo danh với ta đi. Lão phu mỗi ngày <color=yellow>từ 0 giờ sáng đến 2 giờ sáng, 8 giờ sáng đến 23 giờ tối<color> và <color=green>cách mỗi 30 phút<color> sẽ dẫn ngươi đi.", tbOpt);
	else
		if not self.tbManager[nManagerId].tbData[nGameId] then
			Dialog:Say("Tiêu Dao Cốc chưa mở");
			return 0;
		end
		if self.tbManager[nManagerId].tbData[nGameId] >= self.MAX_TEAM then
			Dialog:Say("Cốc đã đầy");
			return 0;
		end
		local nTeamId = me.nTeamId;
		if nTeamId == 0 then
			Dialog:Say("Ít nhất phải có 4 người, mau đi tìm đủ rồi quay lại đây.")
			return 0;
		end
		local tbMember, nMemberCount = KTeam.GetTeamMemberList(nTeamId);
		if not tbMember or nMemberCount < self.MIN_TEAM_PLAYERS then
			Dialog:Say("Ít nhất phải có 4 người, mau đi tìm đủ rồi quay lại đây.")
			return 0;
		end
		if me.nId ~= tbMember[1] then
			Dialog:Say("Hãy bảo đội trưởng đến gặp ta!")
			return 0;
		end
		for i = 1, #tbMember do
			local nRet = self: CheckPlayer(tbMember[i], nManagerId);
			if nRet ~= 1 then
				return 0;
			end
		end
		if self.tbManager[nManagerId].tbData[nGameId] >= self.MAX_TEAM then
			Dialog:Say("Đội ngũ đợi trước Tiêu Dao Cốc đã đầy");
			return 0;
		end
		
		if (nDifficuty == 9) then
			for i = 1, #tbMember do
				local pPlayer = KPlayer.GetPlayerObjById(tbMember[i]);
				if (pPlayer.nLevel >= XoyoGame.MAX_SIMPLE_XOYO_LEVEL) then
					Dialog:Say(string.format("Ngươi vừa báo danh Tiêu Dao Cốc Đơn giản (Dành cho nhân sỹ cấp 30~50), trong tổ đội có người vượt quá cấp %s, ngươi đã chọn chính xác chứ?", self.MAX_SIMPLE_XOYO_LEVEL), {
						{"Xác nhận", self.OnSureJoinGame, self, nDifficuty, nGameId},
						{"Trở về", self.ApplyJoinGame, self},
						{"Để ta suy nghĩ lại"},
					});
					return 0;
				end
			end
		end
		
		self.tbManager[nManagerId].tbData[nGameId] = self.tbManager[nManagerId].tbData[nGameId] + 1;
		self: DocumentDifficuty(nTeamId, nDifficuty);
		--StatLog: WriteStatLog("stat_info", "xoyo", "join", nTeamId, nDifficuty);
		local tbDataLog = {};
		table.insert(tbDataLog, me.nTeamId);
		
		-- 队聊提示报名成功，以及报名难度
		local szTeamMsg = string.format("Nhóm đã báo danh Tiêu Dao Cốc-<color=yellow>%s<color>", self.LevelDesp[nDifficuty][2]);
		KTeam.Msg2Team(nTeamId, szTeamMsg);
		
		for i = 1, #tbMember do
			local pPlayer = KPlayer.GetPlayerObjById(tbMember[i]);
		
			if XoyoGame.XoyoChallenge: GetXoyoluState(pPlayer) == 0 and XoyoGame.LevelDesp[nDifficuty][5] == 1 then
				local nRes, szMsg = XoyoGame.XoyoChallenge: GetXoyolu(pPlayer);
				if szMsg then
					pPlayer.Msg(szMsg);
				end
			end
			
			pPlayer.NewWorld(XoyoGame.MAP_GROUP[nGameId][1], unpack(self.GAME_IN_POS));
			table.insert(tbDataLog, pPlayer.szName);
		end
		DataLog: WriteELog(me.szName, 1, 1, unpack(tbDataLog));
	end
end

function XoyoGame:OnSureJoinGame(nDifficuty, nGameId)
	if (not nDifficuty or not nGameId) then
		return 0;
	end
	
	if me.GetTiredDegree1() == 2 then
		Dialog:Say("您太累了，还是休息下吧！");
		return;
	end
	if me.nTeamId == 0 then
		Dialog:Say("3  Trong cốc địa hình phức tạp, gian nguy dị thường, vì an toàn của các ngươi, <color=green>mỗi người mỗi ngày chỉ có thể vào cốc hai lần, hơn nữa ít nhất phải có bốn người kết bạn thông hành<color>, lão phu mới cho phép các ngươi tiến vào. Được rồi, tìm đủ đồng bọn cùng nhau liền để cho đội trưởng đến báo danh với ta đi. Lão phu mỗi ngày <color=yellow>từ 0 giờ sáng đến 2 giờ sáng, 8 giờ sáng đến 23 giờ tối<color> và <color=green>cách mỗi 30 phút<color> sẽ dẫn ngươi đi.", tbOpt); 
		return;
	end
	local nManagerId = him.nMapId
	if not self.tbManager[nManagerId] or not self.tbManager[nManagerId].tbData then
		return 0;
	end
	local nCurTime = tonumber(os.date("%H%M", GetTime()));
	if not self.__debug_test and (nCurTime < self.START_TIME1 or nCurTime >= self.END_TIME1) and
		(nCurTime < self.START_TIME2 or nCurTime >= self.END_TIME2) then
		Dialog:Say("Lão phu mỗi ngày < color=yellow>từ 8 giờ sáng đến 11 giờ tối, 0 giờ sáng đến 2 giờ sáng<color> mới có thể dẫn dắt các vị, mời các vị đến lúc đó trở lại!")
		return 0;
	end
	
	if not self.tbManager[nManagerId].tbData[nGameId] then
		Dialog:Say("Tiêu Dao Cốc chưa mở");
		return 0;
	end
	if self.tbManager[nManagerId].tbData[nGameId] >= self.MAX_TEAM then
		Dialog:Say("Đã có quá nhiều đội tham gia.");
		return 0;
	end
	local nTeamId = me.nTeamId;
	if nTeamId == 0 then
		Dialog:Say("Tổ đội ít nhất 4 người mới có thể tiến vào.")
		return 0;
	end
	local tbMember, nMemberCount = KTeam.GetTeamMemberList(nTeamId);
	if not tbMember or nMemberCount < self.MIN_TEAM_PLAYERS then
		Dialog:Say("Tổ đội ít nhất 4 người mới có thể tiến vào.")
		return 0;
	end
	if me.nId ~= tbMember[1] then
		Dialog:Say("Ngươi không phải đội trưởng.")
		return 0;
	end
	for i = 1, #tbMember do
		local nRet = self: CheckPlayer(tbMember[i], nManagerId);
		if nRet ~= 1 then
			return 0;
		end
	end
	if self.tbManager[nManagerId].tbData[nGameId] >= self.MAX_TEAM then
		Dialog:Say("Đã có quá nhiều đội tham gia.");
		return 0;
	end
	
	self.tbManager[nManagerId].tbData[nGameId] = self.tbManager[nManagerId].tbData[nGameId] + 1;
	self: DocumentDifficuty(nTeamId, nDifficuty);
	--StatLog: WriteStatLog("stat_info", "xoyo", "join", nTeamId, nDifficuty);
	local tbDataLog = {};
	table.insert(tbDataLog, me.nTeamId);
	
	-- 队聊提示报名成功，以及报名难度
	local szTeamMsg = string.format("Nhóm đã báo danh Tiêu Dao Cốc-<color=yellow>%s<color>", self.LevelDesp[nDifficuty][2]);
	KTeam.Msg2Team(nTeamId, szTeamMsg);
	
	for i = 1, #tbMember do
		local pPlayer = KPlayer.GetPlayerObjById(tbMember[i]);
	
		if XoyoGame.XoyoChallenge: GetXoyoluState(pPlayer) == 0 and XoyoGame.LevelDesp[nDifficuty][5] == 1 then
			local nRes, szMsg = XoyoGame.XoyoChallenge: GetXoyolu(pPlayer);
			if szMsg then
				pPlayer.Msg(szMsg);
			end
		end
		
		pPlayer.NewWorld(XoyoGame.MAP_GROUP[nGameId][1], unpack(self.GAME_IN_POS));
		table.insert(tbDataLog, pPlayer.szName);
	end
	DataLog: WriteELog(me.szName, 1, 1, unpack(tbDataLog));
end

function XoyoGame:CheckPlayer(nPlayerId, nMapId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer or pPlayer.nMapId ~= nMapId then
		Dialog:Say("Trong đội các ngươi có người không ở gần đây, không vào cốc được!");
		return 0;
	end
	if pPlayer.nLevel < self.MIN_LEVEL then
		Dialog:Say("Có người chưa đủ thực lực! Hãy luyện đến cấp "..self.MIN_LEVEL.." rồi quay lại đây!");
		return 0;
	end
	if pPlayer.GetCamp() == 0 then
		Dialog:Say("Có người chưa vào phái, hãy gia nhập môn phái rồi đến tìm ta");
		return 0;
	end
	if self: GetPlayerTimes(pPlayer) <= 0 then
		Dialog:Say(string.format("Nè! Nè! <color=red>%s<color>, hôm nay ngươi không thể vào Cốc nữa, muốn vào thì đợi ngày mai đi!", pPlayer.szName));
		return 0;
	end
	return 1;
end

function XoyoGame:GetPlayerTimes(pPlayer)
	return self: AddPlayerTimes(pPlayer)
end

function XoyoGame:AddPlayerTimes(pPlayer, nDirectAddTimes)
	if (not nDirectAddTimes or nDirectAddTimes ~= 1) then
		if pPlayer.nLevel < self.MIN_LEVEL then
			return 0;
		end
	end
	local nCurTime = GetTime()
	local nCurDay = Lib: GetLocalDay(nCurTime);
	local nTimes = pPlayer.GetTask(self.TASK_GROUP, self.TIMES_ID);
	local nAddDay	= pPlayer.GetTask(self.TASK_GROUP, self.ADDTIMES_TIME);
	if nAddDay == 0 then
		nTimes = self.TIMES_PER_DAY;
		pPlayer.SetTask(self.TASK_GROUP, self.TIMES_ID, nTimes);
		pPlayer.SetTask(self.TASK_GROUP, self.ADDTIMES_TIME, nCurDay);
		return nTimes;
	end
	if nCurDay >= nAddDay then
		nTimes = nTimes + (nCurDay - nAddDay) * self.TIMES_PER_DAY;
		-- TODO:  以后要删掉 -------------------------------
		local nXiuFuNum = (nCurDay - 14333) * self.TIMES_PER_DAY; -- 14334 是1970.1.1 到 2009.3.30 的天数
		if nXiuFuNum < nTimes then
			nTimes = nXiuFuNum;
		end
		-- TODO: END --------------------------------------
		if nTimes >= self.MAX_TIMES then
			nTimes = self.MAX_TIMES
		end
		pPlayer.SetTask(self.TASK_GROUP, self.TIMES_ID, nTimes);
		pPlayer.SetTask(self.TASK_GROUP, self.ADDTIMES_TIME, nCurDay);
	end
	return nTimes;
end

function XoyoGame:AddPlayerTimesOnLogin()
	self: AddPlayerTimes(me)
end
PlayerEvent: RegisterOnLoginEvent(XoyoGame.AddPlayerTimesOnLogin, XoyoGame)

------------------------------------------------------------------------------------------------------------------
--  领奖给予界面
XoyoGame.tbGift = Gift: New();

local tbGift = XoyoGame.tbGift;
tbGift.ITEM_CALSS = "xoyoitem"

function tbGift: OnOK(tbParam)
	local pItem = self: First();
	local tbItem = {};
	if not pItem then
		return 0;
	end
	while pItem do
		if pItem.szClass == self.ITEM_CALSS then
			table.insert(tbItem, pItem);
		end
		pItem = self: Next();
	end
	
	local nTimes = me.GetTask(XoyoGame.TASK_GROUP, XoyoGame.REPUTE_TIMES);
	local nDate = me.GetTask(XoyoGame.TASK_GROUP, XoyoGame.CUR_REPUTE_DATE);
	local nCurDate = tonumber(os.date("%Y%m%d",GetTime()));
	if nDate ~= nCurDate then
		nTimes = 0;
		me.SetTask(XoyoGame.TASK_GROUP, XoyoGame.CUR_REPUTE_DATE, nCurDate)
		me.SetTask(XoyoGame.TASK_GROUP, XoyoGame.REPUTE_TIMES, nTimes);
	end
	if nTimes >= XoyoGame.MAX_REPUTE_TIMES then
		Dialog:Say("Hôm nay ngươi đã đưa cho ta <color=red>"..XoyoGame.MAX_REPUTE_TIMES.."<color> bảo bối rồi, ngày mai hãy đến gặp ta!")
		return 0;
	end

	local nLevel		= me.GetReputeLevel(XoyoGame.REPUTE_CAMP, XoyoGame.REPUTE_CLASS);
	if (not nLevel) then
		print("AddRepute Repute is error ", me.szName, nClass, nCampId);
		return 0;
	else
		if (1 == me.CheckLevelLimit(XoyoGame.REPUTE_CAMP, XoyoGame.REPUTE_CLASS)) then
			me.Msg("Ngươi đã đưa ta đủ số bảo bối rồi, ta không cần nữa!");
			return 0;
		end
	end	
	
	local nRet = 0; 
	for _, pDelItem in ipairs(tbItem) do
		local nCount = pDelItem.nCount;
		if nTimes + nRet + nCount > XoyoGame.MAX_REPUTE_TIMES then	-- 交纳道具超过上限
			local nRemain = nCount - (XoyoGame.MAX_REPUTE_TIMES - nTimes - nRet)
			if nRemain > 0 and nRemain <= nCount and pDelItem.SetCount(nRemain, Item.emITEM_DATARECORD_REMOVE) == 1 then
				nRet = XoyoGame.MAX_REPUTE_TIMES - nTimes;
			end
		elseif me.DelItem(pDelItem) == 1 then
			nRet = nRet + nCount;
		end
		if nTimes + nRet >= XoyoGame.MAX_REPUTE_TIMES then
			break;
		end
	end
	if nRet == 0 then
		Dialog:Say("Ngươi đừng nghĩ là sẽ lừa được ta với món đồ vớ vẩn này!");
		return 0;
	end
	
	me.AddRepute(XoyoGame.REPUTE_CAMP, XoyoGame.REPUTE_CLASS, nRet * XoyoGame.REPUTE_VALUE);
	me.SetTask(XoyoGame.TASK_GROUP, XoyoGame.REPUTE_TIMES, nTimes + nRet);
	
	--成就
	Achievement: FinishAchievement(me, 189);
	
	Dialog:Say("Hay lắm! Chính là món ta cần!");
end

function tbGift: OnUpdate()
	self._szTitle = "Giao nộp bảo vật";
	local nTimes = me.GetTask(XoyoGame.TASK_GROUP, XoyoGame.REPUTE_TIMES);
	local nDate = me.GetTask(XoyoGame.TASK_GROUP, XoyoGame.CUR_REPUTE_DATE);
	local nCurDate = tonumber(os.date("%Y%m%d",GetTime()));
	if nDate ~= nCurDate then
		nTimes = 0;
	end
	self._szContent = "Mỗi ngày có thể giao tối đa "..XoyoGame.MAX_REPUTE_TIMES.." vật phẩm\nHôm nay đã giao <color=green> "..nTimes.."<color> "
	return 0;
end

-- ?pl DoScript("\\script\\mission\\xoyogame\\xoyogame_npc.lua")
