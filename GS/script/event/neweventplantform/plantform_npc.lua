-- 文件名　:plantform_npc.lua
-- 创建者　:jiazhenwei
-- 创建时间:2011-09-20 20:20:24
-- 功能    :无差别竞技

local tbNpc = NewEPlatForm.tbNpc or {};
NewEPlatForm.tbNpc = tbNpc;
tbNpc.tbMsg = {
	"Hoạt động thi đấu thú vị vẫn chưa mở. Hãy cố gắng chờ đợi!",
	"Hoạt động lần này là: <color=yellow>%s<color>\nSố lần có thể tham gia hôm nay: <color=yellow>%s<color>\nSố lần đã tham gia trong tháng: <color=yellow>%s/24<color>\n",
	}

function tbNpc:OnDialog()
	Player.tbOnlineExp:CloseOnlineExp();
	NewEPlatForm:ChangeEventCount(me);
	local nCount =NewEPlatForm:GetPlayerEventCount(me);
	local nAllCount =NewEPlatForm:GetPlayerTotalCount(me);
	local nMacthType = NewEPlatForm:GetMacthType();
	local tbMacth	= NewEPlatForm:GetMacthTypeCfg(nMacthType);
	local nReturn, szMsgInFor = self:CreateMsg(me);
	local szMsg = "";
	if tbMacth then
		szMsg = string.format(self.tbMsg[2], tbMacth.szName, nCount, nAllCount);
		if nReturn == 0 then
			szMsg = szMsg.."\n<color=green>Thông tin hoạt động hiện tại:\n"..szMsgInFor.."<color>";
		elseif nReturn == 2 then
			szMsg = szMsg.."\n<color=red>Rất tiếc, bạn không đủ điều kiện để tham gia!<color>";
		elseif nReturn == 1 then
			szMsg = szMsg.."\n<color=green>"..szMsgInFor.."<color>";
		end
	else
		szMsg = self.tbMsg[1];
	end
	
	local tbOpt = {
		{"Tham gia trò chơi", self.AttendGame, self, nMacthType},
		{"Nhận phần thưởng tháng", NewEPlatForm.GetPlayerAward_Month, NewEPlatForm},
		{"Cửa hàng", self.BuyEventItem, self},
		-- {"[Bạc khóa] Cửa hàng", self.BuyEventItem, self, 1},
		{"Mua trang bị thường", self.BuyReputeItem, self},
		{"Mua trang bị Hoàng Kim", self.BuyReputeItem, self, 1},
		{"Tra cứu",self.Query, self},
		{"Kết thúc đối thoại"}};
	local nSec = tonumber(KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME));
	local nServerOpenDate = tonumber(os.date("%Y%m", nSec));
	if me.nKinFigure == 1 and nServerOpenDate == Kin.GOLD_LS_SERVERDAY then
		table.insert(tbOpt, 1, {"<color=yellow>Kiểm tra điểm của Gia tộc thứ hạng cao<color>", SpecialEvent.tbGoldBar.QueryKinGrade, SpecialEvent.tbGoldBar, me});
	end
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:BuyEventItem(nFlag)
	if not nFlag then
		me.OpenShop(239, 3, 100);
		-- me.OpenShop(239, 1, 100);
		return;
	end
	me.OpenShop(239, 7, 100);
end

function tbNpc:BuyReputeItem(nFlag)
	if not nFlag then
		local nFaction = me.nFaction;
		if nFaction <= 0 then
			Dialog:Say("Chưa gia nhập môn phái không thể tham gia.");
			return 0;
		end
		me.OpenShop(233+me.nSeries - 1, 1, 100, me.nSeries) --使用声望购买
	else
		me.OpenShop(215, 1, 100)
	end
end

function tbNpc:AttendGame(nMacthType, nAttendType, nFlag)
	if not nAttendType and (nMacthType == 3 or nMacthType == 4) then
		local tbMacth	= NewEPlatForm:GetMacthTypeCfg(nMacthType);
		Dialog:Say(string.format("Hoạt động tuần này: <color=yellow>%s<color>, bạn lựa chọn thi đấu theo tổ đội hay cá nhân?", tbMacth.szName), {"Tham gia một mình",self.AttendGame, self, nMacthType, 1}, {"Tham gia theo đội",self.AttendGame, self, nMacthType, 2},{"Để ta suy nghĩ thêm"});
		return;
	end
	if not nAttendType or nAttendType == 1 then
		if NewEPlatForm:CheckMonthAward(me) == 1 then
			Dialog:Say("Bạn chưa nhận phần thưởng tháng trước.", {{"Nhận", NewEPlatForm.GetPlayerAward_Month, NewEPlatForm}, {"Để ta suy nghĩ thêm"}});
			return 0;
		end
		
		local nReturn, szMsgInFor = self:CreateMsg(me);
		if nReturn == 2 then
			Dialog:Say("Bạn "..szMsgInFor);
			return 0;
		elseif nReturn == 0 then
			Dialog:Say(szMsgInFor);
			return 0;
		end
		
		if not nFlag then
			for _, tbItem in pairs(NewEPlatForm.ForbidItem) do
				if #me.FindItemInBags(unpack(tbItem)) > 0 then
					local szMsg = "Bạn có mang <color=red>Vật phẩm cấm sử dụng<color>, vật phẩm sẽ không thể sử dụng khi vào thi đấu. Bạn chắc chứ?";
					local tbOpt = 
					{
						{"Xác nhận vào", self.AttendGame, self, nMacthType, nAttendType, 1},
						{"Để ta suy nghĩ thêm"},
					};
					Dialog:Say(szMsg, tbOpt);
					return 0;	
				end
			end
		end	
		GCExcute{"NewEPlatForm:EnterReadyMap", {me.nId}, me.szName, me.nMapId};
	elseif nAttendType == 2 then
		if me.nTeamId <= 0 then
			Dialog:Say("Bạn không có tổ đội.");
			return;
		end
		if me.IsCaptain() == 0 then
			Dialog:Say("Bạn không phải đội trưởng.");
			return 0;
		end
		local tbPlayerList = KTeam.GetTeamMemberList(me.nTeamId);
		if Lib:CountTB(tbPlayerList) > NewEPlatForm.DEF_PLAYER_TEAM then
			Dialog:Say("Có quá nhiều thành viên trong đội. Tối đa là 4 người!");
			return 0;
		end
		local tbPlayerId = {};
		local bForbidItem = 0;
		local szDialogMsg = "";
		local szItemInfo = "Vật phẩm mang theo của nhóm:";
		local nMapId, nPosX, nPosY = me.GetWorldPos();
		for _, nPlayerId in pairs(tbPlayerList) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if not pPlayer then
				Dialog:Say("Có thành viên chưa đến, hãy đợi anh ấy!");
				return 0;
			end
			local nMapId2, nPosX2, nPosY2	= pPlayer.GetWorldPos();
			local nDisSquare = (nPosX - nPosX2)^2 + (nPosY - nPosY2)^2;
			if nMapId2 ~= nMapId or nDisSquare > 400 then
				Dialog:Say("Đồng đội phải ở gần mới có thể vào.");
				return 0;
			end
			--local nAwardFlag = pPlayer.GetTask(NewEPlatForm.TASKID_GROUP, NewEPlatForm.TASKID_AWARDFLAG);
			--if (0 < nAwardFlag) then
			--	Dialog:Say("玩家<color=yellow>"..pPlayer.szName.."<color>上场奖励还没有领取。");
			--	return 0;
			--end
			if NewEPlatForm:CheckMonthAward(pPlayer) == 1 then
				Dialog:Say("Người chơi <color=yellow>"..pPlayer.szName.."<color> chưa nhận phần thưởng tháng trước.");
				return 0;
			end
			local nReturn, szMsgInFor, szItemName = self:CreateMsg(pPlayer);
			if nReturn == 2 then
				Dialog:Say("Người chơi <color=yellow>"..pPlayer.szName.."<color>"..szMsgInFor);
				return 0;
			elseif nReturn == 0 then
				Dialog:Say(szMsgInFor);
				return 0;
			end
			if szDialogMsg == "" then
				szDialogMsg = szMsgInFor;
			end
			szItemInfo = szItemInfo..pPlayer.szName..":"..szItemName.."\n";
			table.insert(tbPlayerId, nPlayerId);
			for _, tbItem in pairs(NewEPlatForm.ForbidItem) do
				if bForbidItem == 0 and #pPlayer.FindItemInBags(unpack(tbItem)) > 0 then
					bForbidItem = 1;
					break;
				end
			end
		end
		if not nFlag then
			local szMsg = "Bạn chắc chắn muốn vào?";
			local tbOpt = 
			{
				{"Chắc chắn", self.AttendGame, self, nMacthType, nAttendType, 1},
				{"Để ta suy nghĩ thêm"},
			};
			Dialog:Say(szDialogMsg.."\n"..szItemInfo.."\n"..szMsg, tbOpt);
			return 0;
		end
		GCExcute{"NewEPlatForm:EnterReadyMap", tbPlayerId, me.szName, me.nMapId};
	end
end

function tbNpc:CreateMsg(pPlayer)
	if NewEPlatForm:GetMatchState() == NewEPlatForm.DEF_STATE_CLOSE then
		return 0, "Hoạt động chưa bắt đầu, vui lòng đợi.";
	end
	
	if NewEPlatForm:GetMacthSession() <= 0 then
		return 0, "Hoạt động chưa bắt đầu, vui lòng đợi.";
	end	
	
	local nMacthType = NewEPlatForm:GetMacthType();
	local tbMacth	= NewEPlatForm:GetMacthTypeCfg(nMacthType);

	if not tbMacth then
		return 0, "Hoạt động chưa bắt đầu, vui lòng đợi.";
	end
	
	local nWeek = tonumber(GetLocalDate("%w"));
	if not NewEPlatForm.tbStartTime[nWeek] then
		return 0, "Trờ chơi mở vào Thứ 2, Thứ 4, Thứ 6 và Chủ nhật hàng tuần. Hôm nay tạm nghỉ. Hãy quay lại sau.";
	end
	
	local tbMacthCfg	= tbMacth.tbMacthCfg;
	
	if (pPlayer.nLevel < tbMacthCfg.nMinLevel) then
		return 2, string.format("Đẳng cấp chưa đủ %d!", tbMacthCfg.nMinLevel);
	end
	
	if (pPlayer.nFaction <= 0) then
		return 2, "Chưa gia nhập môn phái.";
	end
	if (pPlayer.nKinFigure <= 0) then
		return 2, "Chưa gia nhập Gia tộc.";
	end
	if (tbMacthCfg.nBagNeedFree and tbMacthCfg.nBagNeedFree > 0) then
		if (pPlayer.CountFreeBagCell() < tbMacthCfg.nBagNeedFree) then
			return 2, string.format("Hành trang không đủ %s ô trống.", tbMacthCfg.nBagNeedFree);
		end
	end
	
	local szItemName = "";
	if (tbMacthCfg and tbMacthCfg.tbJoinItem and #tbMacthCfg.tbJoinItem > 0) then
		local nEnterFlag = NewEPlatForm:CheckEnterCount(pPlayer, tbMacthCfg.tbJoinItem);
		local szMsg = "";
		local nNameCount = 0;
		for _, tbItemInfo in pairs(tbMacthCfg.tbJoinItem) do
			if (tbItemInfo.tbItem) then
				local szName = NewEPlatForm:GetItemName(tbItemInfo.tbItem);
				if (szName and string.len(szName) > 0) then
					if (nNameCount > 0) then
						szMsg = string.format("%s <color=white>hoặc<color>", szMsg);
					end
					
					szMsg = string.format("%s %s", szMsg, szName);
					nNameCount = nNameCount + 1;
					szItemName = szName;
				end
			end
		end
		if (string.len(szMsg) <= 0) then
			szMsg = "活动道具";
		end
		if (nEnterFlag <= 0) then
			return 2, string.format("Không có <color=yellow>%s<color>, không thể tham gia.", szMsg);
		elseif (nEnterFlag > 1) then
			return 2, string.format("Chỉ có thể mang 1 <color=yellow>%s<color> trên người. Hãy cất bớt rồi tham gia lại.", szMsg);
		end
		
		local nItemFlag, szItemMsg = NewEPlatForm:ProcessItemCheckFun(pPlayer, tbMacthCfg.tbJoinItem);
		if (0 == nItemFlag) then
			return 2, "<color=yellow>"..szItemMsg.."<color> cần được cải tạo.";
		else 
			szItemName = szItemMsg;
		end
	end
		
	local nTime = GetTime();
	local nWeek = tonumber(os.date("%w", nTime));
	local nHourMin = tonumber(os.date("%H%M", nTime));
	local nDay = tonumber(os.date("%d", nTime));
	
	NewEPlatForm:ChangeEventCount(pPlayer);
	
	local nCount = NewEPlatForm:GetPlayerEventCount(pPlayer);
	
	if (nCount <= 0) then
		return 2, string.format("Đã tham gia <color=yellow>%s<color> nhiều lần trong ngày. Hãy quay lại vào ngày mai.", tbMacth.szName);
	end	
	
	local nAllCount = NewEPlatForm:GetPlayerTotalCount(pPlayer);
	if nAllCount >= NewEPlatForm.nMaxAllCount then
		return 2, string.format("Đã tham gia <color=yellow>%s<color> nhiều lần trong tháng. Hãy quay lại vào tháng sau.", NewEPlatForm.nMaxAllCount);
	end
	
	if pPlayer.GetEquip(Item.EQUIPPOS_MASK) then
		return 2, string.format("%s đang trang bị mặt nạ, không được trang bị mặt nạ.", tbMacth.szName);
	end	
	
	if NewEPlatForm.ReadyTimerId > 0 then
		local nRestTime = math.floor(Timer:GetRestTime(NewEPlatForm.ReadyTimerId)/Env.GAME_FPS);
		if nRestTime >= NewEPlatForm.MACTH_TIME_READY_LASTENTER/Env.GAME_FPS then
			return 1, string.format("Thi đấu đang trong giai đoạn đăng ký.\nCòn <color=yellow>%s<color> nữa sẽ bắt đầu, hãy nhanh chóng đăng ký.", Lib:TimeFullDesc(nRestTime)), szItemName;
		end
	end

	local tbCalemdar = NewEPlatForm.CALEMDAR;
	
	local szGameStart = tbMacth.szName;
	local nFlag		  = 0;
	for nReadyId, tbMissions in pairs(NewEPlatForm.MissionList) do
		for _, tbMission in pairs(tbMissions) do
			if tbMission:IsOpen() ~= 0 then
				nFlag = 1;
				break;
			end
		end
		if (1 == nFlag) then
			break;
		end
	end
	if (nFlag == 1) then
		szGameStart = szGameStart .. "Trò chơi đã bắt đầu!\n\n";
	end

	if nHourMin > tbCalemdar[#tbCalemdar] then
		return 0, "\nHoạt động hôm nay đã kết thúc, quay lại vào ngày mai!";
	end	
	
	if nHourMin < tbCalemdar[1] then
		return 0, string.format("Thời gian vòng kế: <color=yellow>%s<color>", NewEPlatForm.Fun:Number2Time(tbCalemdar[1]));
	end
	
	for nId, nMatchTime in ipairs(tbCalemdar) do
		if nHourMin > nMatchTime and tbCalemdar[nId+1] and nHourMin <= tbCalemdar[nId+1] then
			return 0, string.format("Thời gian vòng kế: <color=yellow>%s<color>", NewEPlatForm.Fun:Number2Time(tbCalemdar[nId+1]));
		end
	end
	return 0, "Vui lòng đợi, trò chơi sắp bắt đầu!";
end

--查询
function tbNpc:Query()
	local nMacthType = NewEPlatForm:GetMacthType();
	local tbEvent = {"Đua thuyền Rồng","Ném tuyết", "Bảo vệ Hồn Tổ Tiên", "Dạ Lam Quan"};
	local szMsg = "Thứ tự các hoạt động: "
	for i, szName in ipairs(tbEvent) do
		if nMacthType == i then
			szMsg = szMsg.."<color=yellow>"..szName.."<color> -> ";
		else
			szMsg = szMsg..szName.." -> ";
		end
	end
	szMsg = szMsg.."\n\nHoạt động diễn ra hàng tuần, mỗi tuần một loại.\nThời gian mở hoạt động: <color=green>Cùng thời gian mở máy chủ<color>\nThời gian hoạt động mỗi ngày: <color=green>11:00-14:00 17:00-22:30 cứ mỗi phút thứ 15 và 45 sẽ có một trận.<color>";
	Dialog:Say(szMsg);
end
