--武林联赛
--孙多良
--2008.09.12

local tbNpc = {};
Wlls.DialogNpc = tbNpc;

function tbNpc:OnDialog(nGameLevel, nFlag)
	if me.nMapId ~= 23 then
		Dialog:Say("Quan Liên Đấu: Hãy đến báo danh ở Biện Kinh!");
		return 0;
	end
	if Wlls:GetMacthSession() <= 0 then
		Dialog:Say("Quan Liên Đấu: Chưa mở liên đấu!");
		return 0;
	end
	
	if nGameLevel == Wlls.MACTH_ADV and Wlls:GetMacthSession() < Wlls.MACTH_ADV_START_MISSION then
		Dialog:Say("Quan Liên Đấu: Võ lâm Liên Đấu chưa mở, hãy ghi danh vào lúc khác.");
		return 0;
	end

	-- 修正因合服问题而导致无法领奖的问题
	local nSession = Wlls:GetMacthSession();
	if (me.GetTask(Wlls.TASKID_GROUP, Wlls.TASKID_MATCH_FINISH) > nSession) then
		Dbg:WriteLog("Wlls", "ErrorAwardFlag", me.szName, me.GetTask(Wlls.TASKID_GROUP, Wlls.TASKID_MATCH_FINISH), nSession);
		me.SetTask(Wlls.TASKID_GROUP, Wlls.TASKID_MATCH_FINISH, nSession);
	end
	
	local nCheck, nRank = Wlls:OnCheckAward(me, nGameLevel);
	if nCheck == 1 and not nFlag then
		local tbSel = {
			{"Nhận phần thưởng liên đấu", Wlls.OnGetAward, Wlls, nGameLevel},
			{"Trở về",self.OnDialog, self, nGameLevel, 1},
			{"Kết thúc đối thoại"},
		}
		Dialog:Say(string.format("Quan Liên Đấu: Chiến đội của bạn xếp hạng <color=yellow>%s<color>, Sau khi nhận thưởng chiến đội sẽ giải tán, Bạn có muốn nhận không?", nRank), tbSel);
		return 0;		
	end
	local nMacthType = Wlls:GetMacthType();
	local tbMacthCfg = Wlls:GetMacthTypeCfg(nMacthType);
	local szGameLevelName = Wlls.MACTH_LEVEL_NAME[nGameLevel];
	if (GLOBAL_AGENT and GbWlls:CheckOpenGoldenGbWlls() == 1) then
		szGameLevelName = GbWlls.MACTH_LEVEL_NAME[nGameLevel];
	end

	local szDesc = (tbMacthCfg and tbMacthCfg.szDesc) or "";
	local szMsg = string.format("Quan liên đấu %s: Từ xưa đến nay, đạo võ thuật chỉ nhân thêm và tiếp tục lưu truyền. Loại hình võ lâm liên đấu đợt này là %s\n\n<color=yellow>Võ lâm liên đấu %s<color>\n", szGameLevelName, szDesc, Wlls.DEF_STATE_MSG[Wlls:GetMacthState()]);
	local tbOpt = 
	{
		{string.format("Đến nơi liên đấu %s", szGameLevelName), self.EnterGame, self, nGameLevel},
		{string.format("Chiến đội liên đấu của ta"), self.MyLeague, self, nGameLevel},
		{"Xem tình hình trận đấu", self.QueryMatch, self},
		{"Mua trang bị danh vọng liên đấu", self.BuyEquire, self},
		{string.format("Giới thiệu Võ Lâm Liên Đấu %s", szGameLevelName), self.About, self, nGameLevel},
		{"Ta chỉ đến xem"},
	};
	if Wlls:GetMacthState() == Wlls.DEF_STATE_REST then
		table.insert(tbOpt, 5, {string.format("Nhận phần thưởng Võ Lâm Liên Đấu %s", szGameLevelName), Wlls.OnGetAward, Wlls, nGameLevel});
	end
	
	if Wlls:GetMacthState() == Wlls.DEF_STATE_ADVMATCH then
		table.insert(tbOpt, 2, {"<color=yellow>Xem trận chung kết<color>", Wlls.OnLookDialog, Wlls});	
	end
	
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:EnterGame(nGameLevel)
	if me.GetTiredDegree1() == 2 then
		Dialog:Say("Bạn quá mệt mỏi!");
		return;
	end
	local szGameLevelName = Wlls.MACTH_LEVEL_NAME[nGameLevel];
	if (GLOBAL_AGENT and GbWlls:CheckOpenGoldenGbWlls() == 1) then
		szGameLevelName = GbWlls.MACTH_LEVEL_NAME[nGameLevel];
	end
	if Wlls:GetMacthState() == Wlls.DEF_STATE_CLOSE then
		Dialog:Say("Quan Liên Đấu: Giải đấu này chưa mở, xin vui lòng tham khảo các thông tin có liên quan trên trang chủ và diễn đàn.");
		return 0;		
	end
	if Wlls:GetMacthState() == Wlls.DEF_STATE_REST then
		Dialog:Say(string.format("Quan Liên Đấu: Giờ là thời gian giải lao Võ Lâm Liên Đấu %s, hội trường tạm thời không mở cửa, đến thời gian thi đấu hãy quay lại!", szGameLevelName));
		return 0;		
	end
	
	local szLeagueName = League:GetMemberLeague(Wlls.LGTYPE, me.szName);
	if not szLeagueName then
		Dialog:Say(string.format("Quan Liên Đấu %s: Danh sách giải đấu và hồ sơ thi đấu chưa có nhóm của bạn. Đối thoại <color=yellow>Quan liên đấu<color>, lựa chọn <color=yellow>Chiến đội<color>, và chọn thành viên vào Chiến đội của mình!", szGameLevelName));
		return 0;
	end
	
	local nLevel = League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_MLEVEL);
	if nLevel ~= nGameLevel then
		Dialog:Say(string.format("Quan Liên Đấu %s: Danh sách giải đấu và hồ sơ thi đấu chưa có nhóm của bạn. Đối thoại <color=yellow>Quan liên đấu<color>, lựa chọn <color=yellow>Chiến đội<color>, và chọn thành viên vào Chiến đội của mình!", szGameLevelName));
		return 0;		
	end
	
	local nMacthType = League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_MTYPE);
	if nMacthType ~= Wlls:GetMacthType() then
		Dialog:Say(string.format("Quan Liên Đấu %s: Danh sách giải đấu và hồ sơ thi đấu chưa có nhóm của bạn. Đối thoại <color=yellow>Quan liên đấu<color>, lựa chọn <color=yellow>Chiến đội<color>, và chọn thành viên vào Chiến đội của mình!", szGameLevelName));
		return 0;		
	end

	if (Wlls:GetMacthLevelCfgType() == Wlls.MAP_LINK_TYPE_RANDOM) then
		if (GLOBAL_AGENT) then
			local tbMTCfg = Wlls:GetMacthTypeCfg(Wlls:GetMacthType());
			if (tbMTCfg) then
				local nSType = tbMTCfg.tbMacthCfg.nSeries;
				if (nSType and Wlls.LEAGUE_TYPE_SERIES_RESTRAINT == nSType) then
					local nSeries	= League:GetMemberTask(Wlls.LGTYPE, szLeagueName, me.szName, Wlls.LGMTASK_SERIES);
					if (nSeries ~= me.nSeries) then
						local szOrg = Env.SERIES_NAME[nSeries] or "Không rõ Ngũ hành";
						local szMsg = string.format("Quan Liên Đấu: Bạn đăng ký ngũ hành tương khắc là hệ <color=yellow>%s<color>. Nên chỉ có người hệ <color=yellow>%s<color> mới có thể tham gia!\n", szOrg, szOrg);
						Dialog:Say(szMsg);
						return 0;
					end
				end;	
			end
		end
	end

	if Wlls:GetMacthLevelCfgType() == Wlls.MAP_LINK_TYPE_SERIES then
		--未开发
		--判断自己现在的五行和报名时战队记录中的五行是否相符, 不符不允许进场；
		local nOrgSereis	= League:GetMemberTask(Wlls.LGTYPE, szLeagueName, me.szName, Wlls.LGMTASK_SERIES);
		if (me.nSeries <= 0) then
			Dialog:Say("Quan Liên Đấu: Bạn chưa gia nhập môn phái, hãy tìm cho mình 1 môn phái thích hợp.");
			return 0;
		end
		if (nOrgSereis > 0 and nOrgSereis ~= me.nSeries) then
			local szOrgSereis = string.format(Wlls.SERIES_COLOR[nOrgSereis], Env.SERIES_NAME[nOrgSereis]);
			local szSereis = string.format(Wlls.SERIES_COLOR[me.nSeries], Env.SERIES_NAME[me.nSeries]);
			Dialog:Say(string.format("Quan Liên Đấu: 5 yếu tố %s ngũ hành %s không phù hợp, thay thế báo danh 5 yếu tố", szSereis, szOrgSereis));
			return 0;			
		end
	end	
	
	if Wlls:GetMacthLevelCfgType() == Wlls.MAP_LINK_TYPE_FACTION then
		--未开发
		--判断自己现在的门派和报名时战队记录中的五行是否相符, 不符不允许进场；		
	end
	
	me.SetLogoutRV(1);
	Wlls:KickPlayer(me, "Bạn đã nhập địa điểm tổ chức giải đấu, sau khi bắt đầu đăng ký, bạn và đồng đội của bạn có thể<color=yellow>Địa điểm quan chức<color>Văn phòng đăng ký tham gia trong cuộc thi này.", nGameLevel);
	Dialog:SendBlackBoardMsg(me, "Chào mừng các bạn đến địa điểm tổ chức giải đấu.");
end

function tbNpc:BuyEquire()
	me.OpenShop(134, 1) --使用声望购买
end

function tbNpc:MyLeague(nGameLevel)
	if Wlls:GetMacthState() == Wlls.DEF_STATE_CLOSE then
		Dialog:Say("Quan Liên Đấu: Liên đấu chưa mở, hãy theo dõi thông báo.");
		return 0;		
	end
	if not Wlls:GetMacthTypeCfg(Wlls:GetMacthType()) then
		Dialog:Say("Quan Liên Đấu: Lượt đấu kế tiếp chưa mở, hãy theo dõi thông báo.");
		return 0;
	end
	
	if (GLOBAL_AGENT and GbWlls:GetGblWllsOpenState() == 0) then
		Dialog:Say("Quan Liên Đấu: Liên đấu chưa mở, hãy theo dõi thông báo.");
		return 0;
	end
	
	local nQuFlag = GbWlls:CheckWllsQualition(me);
	if (nQuFlag == 0) then
		local szMsg = "Quan Liên Đấu: Đã đăng ký ở Liên đấu khác, không thể tham gia!";
		if (GLOBAL_AGENT) then
			szMsg = "Quan Liên Đấu: Đã đăng ký ở máy chủ khác, không thể tham gia!"; 
		end
		Dialog:Say(szMsg);
		return 0;
	end
	
	local szGameLevelName = Wlls.MACTH_LEVEL_NAME[nGameLevel];
	if (GLOBAL_AGENT and GbWlls:CheckOpenGoldenGbWlls() == 1) then
		szGameLevelName = GbWlls.MACTH_LEVEL_NAME[nGameLevel];
	end
	local szGameTypeName = Wlls:GetMacthTypeCfg(Wlls:GetMacthType()).szName;
	local nGamePlayerMax = Wlls:GetMacthTypeCfg(Wlls:GetMacthType()).tbMacthCfg.nMemberCount;
	local nPlayerMax	 = Wlls:GetMacthTypeCfg(Wlls:GetMacthType()).tbMacthCfg.nPlayerCount;
	local szMsg = "";
	local tbOpt = {};
	local szLeagueName = League:GetMemberLeague(Wlls.LGTYPE, me.szName);
	if not szLeagueName then
		szMsg = string.format("Quan Liên Đấu: Liên đấu <color=yellow>%s<color> lần này là <color=yellow>%s đấu.<color> Ngươi có thể chọn chiến đội mà mình muốn thiết lập, nếu trận đấu nhiều người ngươi có thể gia nhập vào chiến đội của người khác. Đội trưởng và người chơi khác sau khi tạo nhóm, sẽ đến chỗ<color=yellow> Quan Liên Đấu %s,<color> chọn <color=yellow>Chiến đội liên đấu của ta,<color> nhập nhóm của mình vào chiến đội của nhóm là được. Thành viên tối đa của chiến đội liên đấu lần này là <color=yellow>%s người<color>.", szGameLevelName, szGameTypeName, szGameLevelName, nGamePlayerMax);
		if nGamePlayerMax > nPlayerMax then
			szMsg = szMsg .. string.format("\n\n<color=yellow>%s trong danh sách chiến đội, %s tên thành viên dự bị <color>\nKhi đã sẵn sàng, nhập địa điểm thi đấu cho các thành viên chính thức, các thành viên của cuộc thi chính thức rời khỏi địa điểm thi đấu<color=yellow>Thành viên dự bị sẽ tự động được chuyển thành thành viên chính thức<color>.", nPlayerMax, nGamePlayerMax - nPlayerMax);
		end
		tbOpt = {
			{string.format("Thiết lập chiến đội võ lâm liên đấu %s", szGameLevelName), self.CreateLeague, self, nGameLevel},
			{"Ta chỉ đến xem"},
		};
	else
		local szMemberMsg = self:GetLeagueInfoMsg(szLeagueName);
		local nCaptain = League:GetMemberTask(Wlls.LGTYPE, szLeagueName, me.szName, Wlls.LGMTASK_JOB);
		if nCaptain == 1 then
			szMsg = szMemberMsg.."\nNgươi có thể thêm thành viên hoặc rời chiến đội.\n\nQuy trình thêm: Trong thời gian nghỉ ngơi và thi đấu, có thể tạo chiến đội.\nQuy trình rời: Trong giai đoạn nghỉ ngơi có thể rời chiến đội, đội trưởng sẽ được bổ nhiệm cho một thành viên khác, nếu không còn thành viên, chiến đội sẽ giải tán. Trong giai đoạn thi đấu, không thể rời chiến đội.";
			tbOpt = {
				{"Rời khỏi chiến đội", self.LeaveLeague, self, nGameLevel},
				{"Kiểm tra chiến tích chiến đội", self.QueryLeague, self},
				{"Ta chỉ đến xem"},
			};
			
			if #League:GetMemberList(Wlls.LGTYPE, szLeagueName)< nGamePlayerMax and League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_MSESSION) == Wlls:GetMacthSession() then
				if (GLOBAL_AGENT) then
					local nTeamLevel = League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_MLEVEL);
					if (nTeamLevel ~= nGameLevel) then
						local szTeamLevelName = Wlls.MACTH_LEVEL_NAME[nTeamLevel];
						if (GLOBAL_AGENT and GbWlls:CheckOpenGoldenGbWlls() == 1) then
							szTeamLevelName = GbWlls.MACTH_LEVEL_NAME[nTeamLevel];
						end
						Dialog:Say(string.format("Ngươi đã đăng ký tham gia Liên Đấu %s hãy tìm Quan Liên Đấu %s!", szTeamLevelName, szTeamLevelName));
						return 0;
					end
				end
				table.insert(tbOpt, 1 , {"Gia nhập nhóm vào chiến đội", self.JoinLeague, self, nGameLevel});
			end
			
		else
			szMsg = szMemberMsg.."\nNgươi có thể lựa chọn rời chiến đội.\n\nQuy trình rời: Trong giai đoạn nghỉ ngơi, có thể rời chiến đội. Lập chiến đội mới hoặc tham gia cùng người chơi khác. Trong giai đoạn thi đấu, nếu đã tham gia thì không thể rời chiến đội.";
			tbOpt = {			
				{"Rời chiến đội", self.LeaveLeague, self, nGameLevel},
				{"Kiểm tra chiến tích chiến đội", self.QueryLeague, self},
				{"Ta chỉ đến xem"},
			};
		end
		
		-- 五行相克双人赛
		if (Wlls:GetMacthTypeCfg(Wlls:GetMacthType()).tbMacthCfg.nSeries == Wlls.LEAGUE_TYPE_SERIES_RESTRAINT) then
			table.insert(tbOpt, 3, {"<color=yellow>Thay đổi Ngũ hành<color>", self.OnChangeSeries, self, szLeagueName});
		end
	end
	Dialog:Say(szMsg,tbOpt);
end

function tbNpc:CheckChangeSeries(szLeagueName, pMe)
	local nCaptain = League:GetMemberTask(Wlls.LGTYPE, szLeagueName, pMe.szName, Wlls.LGMTASK_JOB);
	if (1 ~= nCaptain) then
		return 0, "Ngươi không phải đội trưởng không thể thay đổi ngũ hành!";
	end
	
	local tbLeagueList		= Wlls:GetLeagueMemberList(szLeagueName);
	local tbTeamMemberList	= KTeam.GetTeamMemberList(pMe.nTeamId);
	
	if (not tbTeamMemberList) then
		return 0, "Hãy lập lại chiến đội sau khi thay đổi ngũ hành.";
	end
	
	if (#tbTeamMemberList ~= #tbLeagueList) then
		return 0, "Số lượng thành viên không đủ để thành lập chiến đội.";
	end

	local nMapId, nPosX, nPosY	= pMe.GetWorldPos();
	
	for _, nPlayerId in ipairs(tbTeamMemberList) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	
		if not pPlayer or pPlayer.nMapId ~= nMapId then
			return 0, "Đồng đội không có mặt ở đây.";
		end

		local nMapId2, nPosX2, nPosY2	= pPlayer.GetWorldPos();
		local nDisSquare = (nPosX - nPosX2)^2 + (nPosY - nPosY2)^2;
		if nMapId2 ~= nMapId or nDisSquare > 400 then
			return 0, "Đồng đội không có mặt ở đây.";
		end
	
		local nFindFlag = 0;
		for nId, szMemberName in ipairs(tbLeagueList) do
			if (pPlayer.szName == szMemberName) then
				nFindFlag = 1;
				break;
			end
		end

		if (0 == nFindFlag) then
			return 0, string.format("%s không phải thành viên, thay thế thất bại.", pPlayer.szName);
		end
		
		if (pPlayer.szName ~= pMe.szName) then
			if (0 == Wlls:IsSeriesRestraint(pPlayer.nSeries, pMe.nSeries)) then
				return 0, "Thành viên không đúng ngũ hành tương khắc, không thể thay đổi.";
			end
		end
				
	end
	return 1;	
end

function tbNpc:OnChangeSeries(szLeagueName)
	local szMemberMsg	= "Ngũ hành chiến đội hiện tại: ";
	local szOrgMsg		= "Ngũ hành chiến đội thi đấu: ";
	local nFlag, szResult = self:CheckChangeSeries(szLeagueName, me);
	if (0 == nFlag) then
		Dialog:Say(szResult);
		return 0;
	end

	local tbLeagueList	= Wlls:GetLeagueMemberList(szLeagueName);
	local tbTeamList	= KTeam.GetTeamMemberList(me.nTeamId);
	for nId, szMemberName in ipairs(tbLeagueList) do
		local pPlayer	= KPlayer.GetPlayerByName(szMemberName);
		local nSeries	= League:GetMemberTask(Wlls.LGTYPE, szLeagueName, pPlayer.szName, Wlls.LGMTASK_SERIES);
		if (not pPlayer) then
			Dialog:Say(string.format("%s không ở gần đây.", szMemberName));
			return 0;
		end
		if nId == 1 then
			szMemberMsg = string.format("%s Đội trưởng: <color=yellow>%s<color>, Hệ %s, ", szMemberMsg, szMemberName, string.format(Wlls.SERIES_COLOR[pPlayer.nSeries], Env.SERIES_NAME[pPlayer.nSeries]));
			szOrgMsg = string.format("%s Đội trưởng: <color=yellow>%s<color>, Hệ %s, ", szOrgMsg, szMemberName, string.format(Wlls.SERIES_COLOR[nSeries], Env.SERIES_NAME[nSeries]));
			if #tbLeagueList > 1 then
				szMemberMsg = string.format("%s Thành viên: ", szMemberMsg);
				szOrgMsg = string.format("%s Thành viên: ", szOrgMsg);
			else
				szMemberMsg = string.format("%s<color=gray>Không có<color>\n", szMemberMsg);
				szOrgMsg = string.format("%s<color=gray>Không có<color>\n", szOrgMsg);
			end
		else
			szMemberMsg = string.format("%s<color=yellow>%s<color>, Hệ %s", szMemberMsg, szMemberName, string.format(Wlls.SERIES_COLOR[pPlayer.nSeries], Env.SERIES_NAME[pPlayer.nSeries]));
			szOrgMsg = string.format("%s<color=yellow>%s<color>, Hệ %s", szOrgMsg, szMemberName, string.format(Wlls.SERIES_COLOR[nSeries], Env.SERIES_NAME[nSeries]));
			if nId < #tbLeagueList then
				szMemberMsg = string.format("%s, ", szMemberMsg);
				szOrgMsg = string.format("%s, ", szOrgMsg);
			end
		end
	end
	local szMsg = string.format("%s;\n%s;\nThay đổi gnũ hành hiện tại?", szOrgMsg, szMemberMsg);
	Dialog:Say(szMsg,
		{
			{"Đồng ý", self.OnSureChangeSeries, self, szLeagueName},
			{"Không"},	
		});
end

function tbNpc:OnSureChangeSeries(szLeagueName)
	local nFlag, szResult = self:CheckChangeSeries(szLeagueName, me);
	if (0 == nFlag) then
		Dialog:Say(szResult);
		return 0;
	end
	
	local szMemberMsg = "";
	local tbTeamList	= KTeam.GetTeamMemberList(me.nTeamId);
	local tbLeagueList	= Wlls:GetLeagueMemberList(szLeagueName);
	for nId, szMemberName in ipairs(tbLeagueList) do
		local pPlayer	= KPlayer.GetPlayerByName(szMemberName);
		if (not pPlayer) then
			Dialog:Say(string.format("%s không ở gần đây.", szMemberName));
			return 0;
		end
		League:SetMemberTask(Wlls.LGTYPE, szLeagueName, szMemberName, Wlls.LGMTASK_SERIES, pPlayer.nSeries);
		
		if nId == 1 then
			szMemberMsg = string.format("%sĐội trưởng:  <color=yellow>%s<color>, Hệ %s, ", szMemberMsg, szMemberName, string.format(Wlls.SERIES_COLOR[pPlayer.nSeries], Env.SERIES_NAME[pPlayer.nSeries]));
			if #tbLeagueList > 1 then
				szMemberMsg = string.format("%s Thành viên: ", szMemberMsg);
			else
				szMemberMsg = string.format("%s<color=gray>Không có<color>\n", szMemberMsg);
			end
		else
			szMemberMsg = string.format("%s<color=yellow>%s<color>, Hệ %s", szMemberMsg, szMemberName, string.format(Wlls.SERIES_COLOR[pPlayer.nSeries], Env.SERIES_NAME[pPlayer.nSeries]));
			if nId < #tbLeagueList then
				szMemberMsg = string.format("%s, ", szMemberMsg);
			end
		end		
	end
	
	Dialog:Say(string.format("Thay đổi thành công, ngũ hành sau khi thay đổi: %s.", szMemberMsg));
end

function tbNpc:GetLeagueInfoMsg(szLeagueName)
	local tbLeagueList = Wlls:GetLeagueMemberList(szLeagueName);
	local szMemberMsg = string.format("Quan Liên Đấu: \nChiến đội của bạn: <color=yellow>%s<color>\n", szLeagueName);
	for nId, szMemberName in ipairs(tbLeagueList) do
		if nId == 1 then
			szMemberMsg = string.format("%sĐội trưởng:  <color=yellow>%s<color>\n", szMemberMsg, szMemberName);
			
			if #tbLeagueList > 1 then
				szMemberMsg = string.format("%s Thành viên: ", szMemberMsg);
			else
				szMemberMsg = string.format("%s<color=gray>Không có<color>\n", szMemberMsg);
			end 
		else
			szMemberMsg = string.format("%s <color=yellow>%s<color>", szMemberMsg, szMemberName);
			if nId < #tbLeagueList then
				szMemberMsg = string.format("%s, ", szMemberMsg);
			end
		end
	end
	return 	szMemberMsg;
end

function tbNpc:QueryLeague(szFindName)
	local szLeagueName = szFindName;
	if not szLeagueName then
		szLeagueName = League:GetMemberLeague(Wlls.LGTYPE, me.szName);
		if not szLeagueName then
			Dialog:Say("Quan Liên Đấu: Ngươi không có chiến đội!");
			return 0;
		end
	end
	local tbLeagueList = Wlls:GetLeagueMemberList(szLeagueName);
	local szMemberMsg = self:GetLeagueInfoMsg(szLeagueName);
	local nMSession = League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_MSESSION);
	local nMType = League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_MTYPE);
	local nMLevel = League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_MLEVEL);
	local nRank = League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_RANK);
	local nWin = League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_WIN);
	local nTie = League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_TIE);
	local nTotal = League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_TOTAL);
	local nTime = League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_TIME);
	local nRankAdv	= League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_RANK_ADV);
	local nLoss = nTotal-nWin-nTie;
	if not Wlls.MACTH_TYPE[nMType] then
		Dialog:Say("Quan Liên Đấu: 战队出现异常!");
		return 
	end
	local szMacthName = Wlls:GetMacthTypeCfg(nMType).szName;
	local szMacthLevel = Wlls.MACTH_LEVEL_NAME[nMLevel];
	if (GLOBAL_AGENT and GbWlls:CheckOpenGoldenGbWlls() == 1) then
		szMacthLevel = GbWlls.MACTH_LEVEL_NAME[nMLevel];
	end
	local nPoint = nWin * Wlls.MACTH_POINT_WIN + nTie * Wlls.MACTH_POINT_TIE + nLoss * Wlls.MACTH_POINT_LOSS;
	local szRate = 100.00;
	if nTotal > 0 then
		szRate = string.format("%.2f", (nWin/nTotal)*100) .. "%";
	else
		szRate = "Vô";
	end
	local szRank = "";
	if nRank > 0 then
		szRank = string.format("\nXếp hạng: <color=white>%s<color>", nRank);
	end
	local tbAdvMsg = {
		[0] = "Không phải 8 đội mạnh nhất",
		[1]	= "Vô địch 4",
		[2]	= "Chung kết 5",
		[4] = "Tứ kết 6",
		[8] = "Thi đấu vào tứ kết 7",
	};
	szRank = szRank .. string.format("\n\nTình hình trận 8 đội mạnh nhất：<color=white>%s<color>", tbAdvMsg[nRankAdv]);
	
	szMemberMsg = string.format([[%s<color=green>
--Thành tích chiến đội--
Số đợt liên đấu：<color=white>Đợt thứ %s<color> 
Tham gia thi đấu：<color=white>%s<color> 
Đẳng cấp：<color=white>%s<color> 
Tổng số trận：<color=white>%s<color> 
Tỷ lệ thắng：<color=white>%s<color>
Tổng tích lũy：<color=white>%s<color>
Thắng：<color=white>%s<color>  Hòa：<color=white>%s<color>  Thua：<color=white>%s <color>
Thời gian thi đấu tích lũy：<color=white>%s<color>
%s

<color=red>Danh sách thi đấu 8 đội mạnh sẽ được cập nhật lúc 0 giờ ngày 28<color>
]],szMemberMsg, Lib:Transfer4LenDigit2CnNum(nMSession), szMacthName, szMacthLevel, nTotal, szRate, nPoint, nWin, nTie, nLoss, Lib:TimeFullDesc(nTime), szRank);
		Dialog:Say(szMemberMsg, {{"Quay lại", self.QueryMatch, self}, {"Kết thúc đối thoại"}});
end

function tbNpc:QueryMatch()
	local szGameLevel1Name = Wlls.MACTH_LEVEL_NAME[Wlls.MACTH_PRIM];
	local szGameLevel2Name = Wlls.MACTH_LEVEL_NAME[Wlls.MACTH_ADV];
	if (GLOBAL_AGENT and GbWlls:CheckOpenGoldenGbWlls() == 1) then
		szGameLevel1Name = GbWlls.MACTH_LEVEL_NAME[Wlls.MACTH_PRIM];
		szGameLevel2Name = GbWlls.MACTH_LEVEL_NAME[Wlls.MACTH_ADV];
	end

	local szMsg = string.format("Quan Liên Đấu: Minh chủ võ lâm có tổ chức Võ lâm liên đấu %s và Võ lâm liên đấu %s. Những người có thành tích xuất sắc sẽ được nhận thưởng. Ngươi cũng có thể tra cứu thành tích Võ lâm liên đấu %s và Võ lâm liên đấu %s tại đây.", szGameLevel1Name, szGameLevel2Name, szGameLevel1Name, szGameLevel2Name);
	local tbOpt = {
		{"Tra cứu người chơi khác", self.QueryOtherMatch, self, 1},
		{"Tra cứu chiến đội", self.QueryOtherMatch, self, 2},
		{"Tra cứu thành tích cá nhân", self.QueryMyMatch, self},
		{"Kết thúc đối thoại"},
	};
	local szLeagueName = League:GetMemberLeague(Wlls.LGTYPE, me.szName);
	if szLeagueName then
		table.insert(tbOpt, 1 , {"Kiểm tra chiến đội này", self.QueryLeague, self})
	end	
	Dialog:Say(szMsg, tbOpt)
end

function tbNpc:QueryMyMatch()
	local nTotal = me.GetTask(Wlls.TASKID_GROUP, Wlls.TASKID_MATCH_TOTLE);
	local nWin = me.GetTask(Wlls.TASKID_GROUP, Wlls.TASKID_MATCH_WIN);
	local nTie = me.GetTask(Wlls.TASKID_GROUP, Wlls.TASKID_MATCH_TIE);
	local nFirst = me.GetTask(Wlls.TASKID_GROUP, Wlls.TASKID_MATCH_FIRST);
	local nSecond = me.GetTask(Wlls.TASKID_GROUP, Wlls.TASKID_MATCH_SECOND);
	local nThird = me.GetTask(Wlls.TASKID_GROUP, Wlls.TASKID_MATCH_THIRD);
	local nBest = me.GetTask(Wlls.TASKID_GROUP, Wlls.TASKID_MATCH_BEST);
	local nLost = nTotal - nWin - nTie;
	local szMsg = string.format([[<color=green>
		--Lịch sử chiến tích--
		
		Tổng:     <color=white>%s<color>
		Thắng:    <color=white>%s<color>
		Hòa:    <color=white>%s<color>
		Thua:    <color=white>%s<color>
		
		Quán quân:    <color=white>%s<color>
		Á quân:    <color=white>%s<color>
		Quý quân:    <color=white>%s<color>
		
		Hạng cao nhất:    <color=white>%s<color>
		
	<color=red>Thứ hạng được cập nhật sau khi nhận thưởng cuối giải đấu<color>]], 
	nTotal, nWin, nTie, nLost, 
	nFirst, nSecond, nThird, nBest);
	Dialog:Say(szMsg, {{"Quay lại", self.QueryMatch, self}, {"Kết thúc đối thoại"}});
end

function tbNpc:QueryOtherMatch(nType, nFlag, szText)
	local szType = "Tên đội";
	if nType == 1 then
		szType = "Tên nhân vật";
	end
	
	if not nFlag then
		Dialog:AskString(string.format("Nhập lại %s: ",szType), 16, self.QueryOtherMatch, self, nType, 1);
		return
	end
	--名字合法性检查
	local nLen = GetNameShowLen(szText);
	if nLen < 4 or nLen > 16 then
		Dialog:Say(string.format("%s của bạn quá dài.", szType));
		return 0;
	end
	
	--是否允许的单词范围
	if KUnify.IsNameWordPass(szText) ~= 1 then
		Dialog:Say(string.format("%s của bạn chứa ký tự không hợp lệ", szType));
		return 0;
	end
	
	--是否包含敏感字串
	if IsNamePass(szText) ~= 1 then
		Dialog:Say(string.format("%s của bạn chứa ký tự không hợp lệ", szType));
		return 0;
	end
	
	if nType == 2 then
		if not League:FindLeague(Wlls.LGTYPE, szText) then
			Dialog:Say("Giải đấu tra cứu không tồn tại.");
			return 0;
		end
		--显示战队情况
		self:QueryLeague(szText);
	end
	if nType == 1 then
		if not League:GetMemberLeague(Wlls.LGTYPE, szText) then
			Dialog:Say("Người chơi tra cứu không nằm trong giải đấu.");
			return 0;
		end
		self:QueryLeague(League:GetMemberLeague(Wlls.LGTYPE, szText));
	end
end

function tbNpc:CreateLeague(nGameLevel, szCreateLeagueName, nCreateFlag)
	local nMacthType = Wlls:GetMacthType();
	local tbMacthCfg = Wlls:GetMacthTypeCfg(nMacthType);
	local szGameLevelName = Wlls.MACTH_LEVEL_NAME[nGameLevel];
	if (GLOBAL_AGENT and GbWlls:CheckOpenGoldenGbWlls() == 1) then
		szGameLevelName = GbWlls.MACTH_LEVEL_NAME[nGameLevel];
	end
	local szGameLevel1Name = Wlls.MACTH_LEVEL_NAME[Wlls.MACTH_PRIM];
	if (GLOBAL_AGENT and GbWlls:CheckOpenGoldenGbWlls() == 1) then
		szGameLevel1Name = GbWlls.MACTH_LEVEL_NAME[Wlls.MACTH_PRIM];
	end
	local szGameLevel2Name = Wlls.MACTH_LEVEL_NAME[Wlls.MACTH_ADV];
		if (GLOBAL_AGENT and GbWlls:CheckOpenGoldenGbWlls() == 1) then
		szGameLevel2Name = GbWlls.MACTH_LEVEL_NAME[Wlls.MACTH_ADV];
	end
	if not tbMacthCfg then
		Dialog:Say("Quan Liên Đấu: Liên đấu chưa mở, hãy theo dõi thông báo!");
		return 0;
	end
	local nMaxLevel = Wlls.PLAYER_ATTEND_LEVEL;
	if (GLOBAL_AGENT) then
		nMaxLevel = GbWlls.DEF_MIN_PLAYERLEVEL;
	end
	if me.nLevel < nMaxLevel then
		Dialog:Say(string.format("Quan Liên Đấu %s: Đẳng cấp ngươi chưa đạt <color=yellow>%s<color>, làm sao có thể đặt chân đến nơi này!", szGameLevelName, Wlls.PLAYER_ATTEND_LEVEL));
		return 0;		
	end
	if me.nTeamId <= 0 then
		Dialog:Say("Quan Liên Đấu: Trước hết hãy lập tổ đội!");
		return 0;
	end
	if me.IsCaptain() == 0 then
		Dialog:Say("Quan Liên Đấu: Hãy kêu Trưởng nhóm tới đây!");
		return 0;
	end
	local szLeagueName = League:GetMemberLeague(Wlls.LGTYPE, me.szName);
	if szLeagueName then
		Dialog:Say("Quan Liên Đấu: Ngươi đã có chiến đội rồi kia mà!");
		return 0;
	end
	if Wlls:GetGameLevelForRank(me.szName, nGameLevel) > nGameLevel then
		local szRankName = "Điểm danh vọng";
		if (GLOBAL_AGENT) then
			szRankName = "";
		end
		Dialog:Say(string.format("Quan Liên Đấu: Võ lâm liên đấu %s để tuyển chọn người hậu khởi, %s của ngươi đã đạt <color=yellow>Hạng %s<color>, hãy tham gia Võ lâm Liên đấu %s đi!", szGameLevel1Name, szRankName, Wlls.SEASON_TB[Wlls:GetMacthSession()][3], szGameLevel2Name));
		return 0;
	elseif  Wlls:GetGameLevelForRank(me.szName, nGameLevel) < nGameLevel then
		if (GLOBAL_AGENT) then
			Dialog:Say(string.format("Quan Liên Đấu %s: Liên đấu là nơi anh hùng luận kiếm trên thiên hạ, Vinh dự Tài phú chưa đạt <color=yellow>Hạng %s<color>, xếp hạng Liên đấu chưa đạt <color=yellow>Hạng %s<color>, trình độ còn yếu kém, e rằng ngươi không phải đối thủ của các vị tiền bối. Hãy trở về luyện thêm đi.", szGameLevel2Name, GbWlls.DEF_ADV_MAXGBWLLS_MONEY_RANK, GbWlls.DEF_ADV_MAXGBWLLS_WLLS_RANK));
		else
			Dialog:Say(string.format("Quan Liên Đấu %s: Liên đấu là nơi anh hùng luận kiếm trên thiên hạ, xếp hạng Liên đấu chưa đạt <color=yellow>Hạng %s<color>, trình độ còn yếu kém, e rằng ngươi không phải đối thủ của các vị tiền bối. Hãy trở về luyện thêm đi.", szGameLevel2Name, Wlls.SEASON_TB[Wlls:GetMacthSession()][3]));
		end
		return 0;		
	end
	
	if (GLOBAL_AGENT) then
		local nEnterFlag = GbWlls:GetGbWllsEnterFlag(me);
		if (nEnterFlag ~= 1) then
			Dialog:Say("Quan Liên Đấu: 你没有通过<color=yellow>跨服联赛报名官<color>报名进入, 不能建立战队.");
			return 0;
		end
		
		if (GbWlls:CheckSiguUpTime(GetTime()) == 0) then
			Dialog:Say("Quan Liên Đấu: Không phải giai đoạn đăng ký, không thể lập chiến đội.")
			return 0;
		end
	end
	
	local tbTeamMemberList = KTeam.GetTeamMemberList(me.nTeamId);
	if not tbTeamMemberList then
		Dialog:Say("Quan Liên Đấu: Phải có tổ đội mới có thể lập chiến đội!");
		return 0;
	end
	local nFlag, szMsg = Wlls:CheckCreateLeague(me, tbTeamMemberList, tbMacthCfg, nGameLevel);
	if nFlag == 1 then
		Dialog:Say(szMsg);
		return 0;
	end
	
	if not szCreateLeagueName then
		Dialog:AskString("Hãy nhập tên: ", 12, self.CreateLeague, self, nGameLevel);
		return 0;
	end
	
	--名字合法性检查
	local nLen = GetNameShowLen(szCreateLeagueName);
	if nLen < 6 or nLen > 12 then
		Dialog:Say("Tên không hợp lệ.");
		return 0;
	end
	
	--是否允许的单词范围
	if KUnify.IsNameWordPass(szCreateLeagueName) ~= 1 then
		Dialog:Say("您的战队名字含有非法字符.");
		return 0;
	end
	
	--是否包含敏感字串
	if IsNamePass(szCreateLeagueName) ~= 1 then
		Dialog:Say("您的战队名字含有非法的敏感字符.");
		return 0;
	end

	if League:FindLeague(Wlls.LGTYPE, szCreateLeagueName) then
		Dialog:Say("您取的战队名已存在, 请重新建立战队");
		return 0;
	end
	
	if tbMacthCfg.nMapLinkType == Wlls.MAP_LINK_TYPE_SERIES then
		if (not nCreateFlag or nCreateFlag <= 0) then
			local nSeries = -1;
			local szMsg = "";
			local tbOpt	= {};
			for _, nPlayerId in ipairs(tbTeamMemberList) do
				local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
				if (pPlayer.nSeries <= 0) then
					szMsg = "你的战队中有队友未加入门派.";
					break;
				end
				
				if (nSeries <= 0) then
					nSeries = pPlayer.nSeries;
					local szSereis = string.format(Wlls.SERIES_COLOR[nSeries], Env.SERIES_NAME[nSeries]);
					szMsg	= string.format("您确定要以Hệ %s参加%s五行赛吗？", szSereis, szSereis);
					tbOpt	= {
							{"Xác nhận", self.CreateLeague, self, nGameLevel, szCreateLeagueName, 1},
							{"Để ta suy nghĩ thêm"},
						}; 
				else
					if (nSeries ~= pPlayer.nSeries) then
						szMsg = "你的战队中有队友门派不一致.";
						break;				
					end
				end
			end
			Dialog:Say(szMsg, tbOpt);
			return 0;
		end
	end
		
	if (tbMacthCfg.nMapLinkType == Wlls.MAP_LINK_TYPE_FACTION) then
		if (not nCreateFlag or nCreateFlag <= 0) then
			local nFaction = 0;
			local szMsg = "";
			local tbOpt	= {};
			for _, nPlayerId in ipairs(tbTeamMemberList) do
				local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
				if (pPlayer.nFaction <= 0) then
					szMsg = "你的战队中有队友未加入门派.";
					break;
				end
				
				if (nFaction <= 0) then
					nFaction = pPlayer.nFaction;
					local szFaction = Player:GetFactionRouteName(nFaction);
					szMsg	= string.format("您确定要以%s门派参加%s门派单人赛吗？", szFaction, szFaction);
					tbOpt	= {
							{"Xác nhận", self.CreateLeague, self, nGameLevel, szCreateLeagueName, 1},
							{"Để ta suy nghĩ thêm"},
						}; 
				else
					if (nFaction ~= pPlayer.nFaction) then
						szMsg = "你的战队中有队友门派不一致.";
						break;				
					end
				end
			end
			Dialog:Say(szMsg, tbOpt);
			return 0;
		end
	end
		
	-- 五行相克赛
	if (tbMacthCfg.tbMacthCfg.nSeries == Wlls.LEAGUE_TYPE_SERIES_RESTRAINT) then
		if (not nCreateFlag or nCreateFlag <= 0) then
			local nSeries	= -1;
			local nNoFlag	= 0;
			local szSeriesMsg = "";		
			for _, nPlayerId in ipairs(tbTeamMemberList) do
				local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
				if (nSeries == -1) then
					nSeries = pPlayer.nSeries;
				else
					if (0 == Wlls:IsSeriesRestraint(nSeries, pPlayer.nSeries)) then
						nNoFlag = 1;
						break;
					end
				end
				szSeriesMsg = string.format("%s %s Hệ %s, ", szSeriesMsg, pPlayer.szName, string.format(Wlls.SERIES_COLOR[pPlayer.nSeries], Env.SERIES_NAME[pPlayer.nSeries]));
			end
			if (1 == nNoFlag) then
				Dialog:Say("这届联赛是相克双人赛, 你们之间没有相克关系, 还是选好五行再来参赛吧.");
				return 0;
			else
				szSeriesMsg = string.format("当前报名五行为: %s确定以当前五行参赛吗？", szSeriesMsg);
				local tbOpt	= {
						{"Xác nhận", self.CreateLeague, self, nGameLevel, szCreateLeagueName, 1},
						{"Để ta suy nghĩ thêm"},
					}; 
				Dialog:Say(szSeriesMsg, tbOpt);
				return 0;
			end
		end
	end
	
	--记录扩展参数
	local nExParam = 0;
	--if tbMacthCfg.nMapLinkType == Wlls.MAP_LINK_TYPE_SERIES then
	--	nExParam = me.nFaction;
	--end
	
	local tbMemberList = {};
	for _, nPlayerId in ipairs(tbTeamMemberList) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			--pPlayer.SetTask(Wlls.TASKID_GROUP, Wlls.TASKID_MATCH_FINISH, 0);--清除奖励领取选项.
			pPlayer.SetTask(Wlls.TASKID_GROUP, Wlls.TASKID_HELP_SESSION, Wlls:GetMacthSession());--设置帮助锦囊显示信息
			pPlayer.SetTask(Wlls.TASKID_GROUP, Wlls.TASKID_HELP_TOTLE, 0);
			pPlayer.SetTask(Wlls.TASKID_GROUP, Wlls.TASKID_HELP_WIN, 0);
			pPlayer.SetTask(Wlls.TASKID_GROUP, Wlls.TASKID_HELP_TIE, 0);
			local nMyGameLevel	= Wlls:GetGameLevelForRank(pPlayer.szName, nGameLevel);
			local nGateway		= 0;
			local nExParam = 0;			
			if (GLOBAL_AGENT) then
				local szGateway = Transfer:GetMyGateway(pPlayer);
				nGateway = tonumber(string.sub(szGateway, 5, 8)) or 0;
				if (tbMacthCfg.nMapLinkType == Wlls.MAP_LINK_TYPE_FACTION) then
					nExParam = pPlayer.nFaction;
				end
			end
			
			table.insert(tbMemberList, {
				nId=nPlayerId,
				szName=pPlayer.szName,
				nFaction=pPlayer.nFaction, 
				nRouteId=pPlayer.nRouteId, 
				nSex=pPlayer.nSex, 
				nCamp=pPlayer.GetCamp(), 
				nSeries=pPlayer.nSeries,
				nMyGameLevel = nMyGameLevel,
				nGateway = nGateway,
				nExParam = nExParam,
				nLevel	= pPlayer.nLevel,
				});
			pPlayer.Msg(string.format("您成为了<color=yellow>%s<color>联赛战队的一员, 请在比赛期内, 进入联赛会场, 在<color=yellow>会场官员处报名参加比赛<color>.您可以到联赛官员处查询和操作本战队相关信息.", szCreateLeagueName));
			Dialog:SendBlackBoardMsg(pPlayer, string.format("您成功成为了%s联赛战队的成员", szCreateLeagueName));				
			if (GLOBAL_AGENT) then
				local szGbMsg = string.format(GbWlls.MSG_JOIN_SUCCESS_FOR_MY, Wlls:GetMacthSession(), tbMacthCfg.szName);
				pPlayer.Msg(szGbMsg);
			end
			--成就
			if (not GLOBAL_AGENT) then
				local tbAchievement = Wlls.tbAchievementApply;
				if tbAchievement[nMacthType] then
					Achievement:FinishAchievement(pPlayer, tbAchievement[nMacthType]);
				end
			end
			--成就end
					
		end
	end
	me.Msg(szMsg);
	Dialog:Say(szMsg);
	GCExcute{"Wlls:CreateLeague", tbMemberList, szCreateLeagueName, nGameLevel, nExParam};

	
		
end

function tbNpc:JoinLeague(nGameLevel)
	local nMacthType = Wlls:GetMacthType();
	local tbMacthCfg = Wlls:GetMacthTypeCfg(nMacthType);
	if not tbMacthCfg then
		Dialog:Say("Quan Liên Đấu: Liên đấu vẫn chưa bắt đầu, hãy theo dõi thông báo!");
		return 0;
	end 
	if me.nTeamId <= 0 then
		Dialog:Say("Quan Liên Đấu: Đội trưởng phải tổ đội cùng thành viên mới có thể tham gia!");
		return 0;
	end
	if me.IsCaptain() == 0 then
		Dialog:Say("Quan Liên Đấu: 你必须是队伍的队长才能将队员组入战队!");
		return 0;
	end
	local szLeagueName = League:GetMemberLeague(Wlls.LGTYPE, me.szName);
	if not szLeagueName then
		Dialog:Say("Quan Liên Đấu: 您还没创建战队!");
		return 0;
	end
	local nGameLevel = League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_MLEVEL);
	if League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_MSESSION) ~= Wlls:GetMacthSession() then
		Dialog:Say("Quan Liên Đấu: 您的战队参加的联赛已结束!");
		return 0;
	end
	local nCaptain = League:GetMemberTask(Wlls.LGTYPE, szLeagueName, me.szName, Wlls.LGMTASK_JOB);
	if not nCaptain or nCaptain == 0 then
		Dialog:Say("Quan Liên Đấu: 只有战队队长才有资格邀请其他成员加入战队!");
		return 0;
	end
	
	local tbTeamMemberList = KTeam.GetTeamMemberList(me.nTeamId);
	if not tbTeamMemberList then
		Dialog:Say("Quan Liên Đấu: 你必须是队伍的队长才能将队员组入战队!");
		return 0;
	end

	if (GLOBAL_AGENT) then
		if (GbWlls:CheckSiguUpTime(GetTime()) == 0) then
			Dialog:Say("Quan Liên Đấu: 现在不是报名时段, 无法让队员加入战队.")
			return 0;
		end
	end

	local tbPlayerList = League:GetMemberList(Wlls.LGTYPE, szLeagueName);
	local tbJoinPlayerIdList = {};
	for _, nPlayerId in pairs(tbTeamMemberList) do
		if me.nId ~= nPlayerId then
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if not pPlayer then
				Dialog:Say("Đồng đội không có mặt ở đây.");
				return 0;
			end
			local nMyGameLevel = Wlls:GetGameLevelForRank(pPlayer.szName, nGameLevel)

			local nExParam = 0;
			if (tbMacthCfg.nMapLinkType == Wlls.MAP_LINK_TYPE_FACTION) then
				nExParam = pPlayer.nFaction;
			end
		
			local nGateway		= 0;
			if (GLOBAL_AGENT) then
				local szGateway = Transfer:GetMyGateway(pPlayer);
				nGateway = tonumber(string.sub(szGateway, 5, 8)) or 0;
			end
			
			table.insert(tbJoinPlayerIdList, {
				nId=nPlayerId,
				szName=pPlayer.szName,
				nFaction=pPlayer.nFaction, 
				nRouteId=pPlayer.nRouteId, 
				nSex=pPlayer.nSex, 
				nCamp=pPlayer.GetCamp(), 
				nSeries=pPlayer.nSeries,
				nMyGameLevel = nMyGameLevel,
				nExParam = nExParam,
				nGateway = nGateway,
				nLevel	= pPlayer.nLevel,
				});
		end
	end
	if #tbJoinPlayerIdList <= 0 then
		Dialog:Say("Quan Liên Đấu: 您的队伍中没有队员!");
		return 0;
	end
	local nMyGameLevel = Wlls:GetGameLevelForRank(me.szName, nGameLevel);
	local nExParam = 0;
	if (tbMacthCfg.nMapLinkType == Wlls.MAP_LINK_TYPE_FACTION) then
		nExParam = me.nFaction;
	end

	local nGateway		= 0;
	if (GLOBAL_AGENT) then
		local szGateway = Transfer:GetMyGateway(me);
		nGateway = tonumber(string.sub(szGateway, 5, 8)) or 0;
	end

	table.insert(tbJoinPlayerIdList, 1, {
		nId=me.nId,
		szName=me.szName,
		nFaction=me.nFaction, 
		nRouteId=me.nRouteId, 
		nSex=me.nSex,
		nCamp=me.GetCamp(), 
		nSeries=me.nSeries,
		nGateway = nGateway,
		nGameLevel = nGameLevel,
		nExParam = nExParam,
		nLevel	= me.nLevel,
		});
	local nFlag, szMsg = Wlls:CheckJoinLeague(me, szLeagueName, tbPlayerList, tbJoinPlayerIdList, tbMacthCfg, nGameLevel);
	if nFlag == 1 then
		Dialog:Say(szMsg);
		return 0;
	end
	Dialog:Say("Quan Liên Đấu: 您的战队成功加入了新的战队成员!");
	for _, tbPlayer in pairs(tbJoinPlayerIdList) do
		local pPlayer = KPlayer.GetPlayerObjById(tbPlayer.nId);
		if pPlayer then
			if pPlayer.GetTask(Wlls.TASKID_GROUP, Wlls.TASKID_HELP_SESSION) ~= Wlls:GetMacthSession() then
				--pPlayer.SetTask(Wlls.TASKID_GROUP, Wlls.TASKID_MATCH_FINISH, 0);--清除奖励领取选项.
				pPlayer.SetTask(Wlls.TASKID_GROUP, Wlls.TASKID_HELP_SESSION, Wlls:GetMacthSession());--设置帮助锦囊显示信息
				pPlayer.SetTask(Wlls.TASKID_GROUP, Wlls.TASKID_HELP_TOTLE, 0);
				pPlayer.SetTask(Wlls.TASKID_GROUP, Wlls.TASKID_HELP_WIN, 0);
				pPlayer.SetTask(Wlls.TASKID_GROUP, Wlls.TASKID_HELP_TIE, 0);
			end
			local szBlackMsg = string.format("您成功成为了%s联赛战队的成员", szLeagueName);
			local szMsg = string.format("您成为了<color=yellow>%s<color>联赛战队的一员, 请在比赛期内, 进入联赛会场, 在会场官员处报名参加比赛.您可以到联赛官员处查询和操作本战队相关信息.", szLeagueName);
			if tbPlayer.nId == me.nId then
				szBlackMsg = "您的战队成功加入了新的战队成员";
				szMsg = "您的战队<color=yellow>成功加入了新的成员<color>, 请在比赛期内, 进入联赛会场, 在会场官员处报名参加比赛.您可以到联赛官员处查询和操作本战队相关信息.";
			else
				--成就
				if (not GLOBAL_AGENT) then
					local tbAchievement = Wlls.tbAchievementApply;
					if tbAchievement[nMacthType] then
						Achievement:FinishAchievement(pPlayer, tbAchievement[nMacthType]);
					end
				end
			end
			pPlayer.Msg(szMsg);
			Dialog:SendBlackBoardMsg(pPlayer, szBlackMsg);	
		end
	end
	GCExcute{"Wlls:JoinLeague", szLeagueName, tbJoinPlayerIdList};
end

function tbNpc:LeaveLeague(nGameLevel, nFlag)
	local szLeagueName = League:GetMemberLeague(Wlls.LGTYPE, me.szName);
	if not szLeagueName then
		Dialog:Say("Quan Liên Đấu: 您没有战队!");
		return 0;
	end
	local nSession = League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_MSESSION);
	if League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_ATTEND) > 0 and nSession == Wlls:GetMacthSession() then
		Dialog:Say("Quan Liên Đấu: 您的战队已参加过本届比赛,您不能退出战队.");
		return 0;
	end
	if nFlag == 1 then
		Dialog:Say("Quan Liên Đấu: 成功退出战队.");
		-- 只有非全局服务器才能设置
		if (not GLOBAL_AGENT) then
			Wlls:SetPlayerSession(me.szName, 0);
		end
		GCExcute{"Wlls:LeaveLeague", me.szName, nGameLevel};
		return 0;
	end
	local szMsg = "";
	local tbOpt = {
		{"确定要退出", self.LeaveLeague, self, nGameLevel, 1},
		{"Để ta suy nghĩ lại"},
	}
	--如果高级联赛, 退出特殊判断
	if nGameLevel == Wlls.MACTH_ADV and Wlls:GetGameLevelForRank(me.szName, nGameLevel) == Wlls.MACTH_ADV then
		local tbLeagueMemberList = Wlls:GetLeagueMemberList(szLeagueName);
		local tbAdv = {};
		for _, szName in pairs(tbLeagueMemberList) do
			if Wlls:GetGameLevelForRank(szName, nGameLevel) == Wlls.MACTH_ADV then
				table.insert(tbAdv, szName);
			end
		end
		if #tbAdv <= 1 then
			if (GLOBAL_AGENT) then
				szMsg = string.format("Quan Liên Đấu: 你退出战队后, 剩余队员联赛资格没有达到高级跨服联赛的要求, 本战队将会解散.<color=red>你退出战队后, 将无法领取本战队的排名奖励, <color>你确定要退出战队吗？");
			else
				szMsg = string.format("Quan Liên Đấu: 你退出战队后, 剩余队员不是联赛荣誉排行榜前<color=yellow>%s名<color>, 本战队将会解散.<color=red>你退出战队后, 将无法领取本战队的排名奖励, <color>你确定要退出战队吗？", Wlls.SEASON_TB[Wlls:GetMacthSession()][3]);
			end
			Dialog:Say(szMsg, tbOpt);
			return 0;
		end
	end
	
	local nCaptain = League:GetMemberTask(Wlls.LGTYPE, szLeagueName, me.szName, Wlls.LGMTASK_JOB);
	if nCaptain == 1 then
		szMsg = "Quan Liên Đấu: 你退出战队后, 队长资格将移交其他的队员；如果没有剩余队员, 本战队将会解散.<color=red>你退出战队后, 将无法领取本战队的排名奖励, <color>你确定要退出战队吗？"
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	szMsg = "Quan Liên Đấu: <color=red>你退出战队后, 将无法领取该战队的排名奖励, <color>你确定要退出战队吗？";
	Dialog:Say(szMsg, tbOpt);	
end

function tbNpc:BreakLeague()
	local szLeagueName = League:GetMemberLeague(Wlls.LGTYPE, me.szName);
	if not szLeagueName then
		Dialog:Say("Quan Liên Đấu: 您没有战队!");
		return 0;
	end
	if League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_ATTEND) > 0 then
		Dialog:Say("Quan Liên Đấu: 您的战队已参加过本届比赛,不能解散战队.");
		return 0;
	end	
	GCExcute{"Wlls:BreakLeague", me.szName};
end

tbNpc.tbAbout = 
{

	[1] = [[
	1）你可以在各大城市的初级（高级）武林联赛官员处报名建立联赛战队.
	
	2）联赛类型为多人赛时, 战队建立后, 战队队长可以在初级（高级）武林联赛官员处将其他符合条件的人加入自己的战队.
	
	3）比赛日, 战队成员与初级（高级）武林联赛官员对话进入联赛会场, 与会场官员对话, 报名参加当日比赛.
	
	4）报名后, 战队成员进入联赛准备场, 待准备时间结束, 则进入比赛场正式开始比赛.]],
	[2] = [[
    1）武林联赛每个<color=yellow>赛季为1个月<color>, 每月<color=yellow>7-28号<color>为比赛期, 其中<color=yellow>7-27<color>号为循环赛时间, <color=yellow>28号<color>为高级联赛决赛时间, 初级联赛没有决赛.循环赛<color=yellow>前8名的队伍<color>有资格参加最后的决赛, 联赛前8名排名以决赛名次为准, 其他名次以循环赛为准.联赛全赛季（3个星期）共<color=yellow>150场比赛<color>, 每个战队最多可参加<color=yellow>36场<color>比赛, 决赛的场次不计算在36场之内.	
   
    2）具体比赛时间为
    周一-周五（每天6场）: <color=yellow>20: 00、20: 15、20: 30、20: 45、21: 00、21: 15<color>
    周六-周日（每天10场）: <color=yellow>15: 00、15: 15、15: 30、15: 45、16: 00、16: 15、19: 00、19: 15、19: 30、19: 45、20: 00<color>
    28日（共5场）: <color=yellow>19: 00、19: 15、19: 30、19: 45<color>

    3）每场比赛准备时间为<color=yellow>5分钟<color>, 比赛时间为<color=yellow>10分钟<color>.

    4）最终决赛共有5场, 19: 00为8强进4强, 19: 15为4强进决赛, 19: 30、19: 45、20: 00为冠亚军决赛, 双方需要打满3场, 各队伍没有参加决赛的自动判负.
	]],
	[3] = [[
	1）武林联赛分为初级武林联赛和高级武林联赛.你需要加入战队才能参加联赛.
	
	2）初级武林联赛战队参赛条件: 战队成员为100级以上, 已加入门派, 且不能为联赛荣誉点排行榜Hạng %s（根据联赛类型不同, 所需条件也不同）.<color=yellow>（高级联赛将在第三届联赛开放）<color>
	
	3）高级武林联赛战队参赛条件: 战队成员为100级以上, 已加入门派, 且战队队长为联赛荣誉点排行榜Hạng %s.<color=yellow>（高级联赛将在第三届联赛开放）<color>
	]],
	[4] = [[
	1）联赛类型为多人赛时, 战队队长可以与其他人组队, 在各大城市的初级（高级）武林联赛官员处, 选择将队伍中的成员, 加入本战队.
	
	2）在赛季期内, 凡是没有参加过比赛的战队, 其战队成员都可以在各大城市的初级（高级）武林联赛官员处选择退出战队.
	
	3）若高级武林联赛的参赛战队由于战队队长退出战队, 导致队长不是联赛荣誉点排行榜Hạng %s, 则该战队丧失参赛资格.<color=yellow>（高级联赛将在第三届联赛开放）<color>
	]],
	[5] = [[
	1）比赛过程中本方将对方队员全部重伤时判胜.
	
	2）在比赛过程中如对方队员同时不在比赛场内, 则本方直接获胜.
	
	3）在比赛时间结束后, 双方仍未分出胜负, 则判定剩余人数多的战队获胜；如果双方剩余人数相同, 则以双方所有队员有效受伤总量来判断胜负,有效受伤总量小的一方获胜.有效受伤总量相同, 则判平.
	
	4）参加比赛, 轮空的战队直接判胜.轮空获胜比赛时间按5分钟计算.
	]],
	[6] = [[
	1）	常规比赛奖励: 每场比赛打完, 无论胜负平, 参赛玩家都能获得经验、联赛声望和联赛荣誉点的奖励.
	
	2）	最终排名奖励: 根据联赛的最终排名, 参赛玩家能获得经验、联赛声望和联赛荣誉点奖励.同时排名前列的玩家可以领取特殊的联赛称号奖励.
	]],
}

function tbNpc:About()
	local tbOpt = 
	{
		{"参赛流程", self.AboutInfo, self, 1},
		{"赛程时间", self.AboutInfo, self, 2},
		{"参赛条件", self.AboutInfo, self, 3},
		{"战队的相关操作", self.AboutInfo, self, 4},
		{"如何判定胜负", self.AboutInfo, self, 5},
		{"联赛奖励", self.AboutInfo, self, 6},
		{"Kết thúc đối thoại"},
	}
	
	Dialog:Say("Quan Liên Đấu: 武林联赛为每个月举行一届的竞技活动.你可以参加联赛, 与众多武林高手一起争夺武林至高荣誉.想查询武林联赛相关信息吗?选择你想要查询的信息.", tbOpt);
end

function tbNpc:AboutInfo(nType)
	if not Wlls.SEASON_TB[Wlls:GetMacthSession()] then
		Dialog:Say("Quan Liên Đấu: 下届武林联赛还未确定类型, hãy theo dõi thông báo.");
		return 0;
	end
	local nRank = Wlls.SEASON_TB[Wlls:GetMacthSession()][3];
	Dialog:Say(string.format(self.tbAbout[nType], nRank, nRank), {{"Quay lại", self.About, self},{"Kết thúc đối thoại"}});
end
