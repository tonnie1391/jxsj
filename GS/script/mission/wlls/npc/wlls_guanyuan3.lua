--联赛会场官员
--孙多良
--2008.09.12

local tbNpc = Npc:GetClass("wlls_guanyuan3");

function tbNpc:OnDialog()
	Player.tbOnlineExp:CloseOnlineExp();
	local nReturn, szMsgInFor = self:CreateMsg();
	local szMsg = string.format(szMsgInFor);
	local tbOpt = 
	{
		{"我要查询相关赛况", Wlls.DialogNpc.QueryMatch, Wlls.DialogNpc},
		{"Kết thúc đối thoại"},
	};

	local tbMTCfg = Wlls:GetMacthTypeCfg(Wlls:GetMacthType());

	if (not GLOBAL_AGENT) then
		local nRet1 = Wlls:OnCheckAwardSingle(me);
		local nRet2 = Wlls:OnCheckWldhRep(me);
		if nRet1 == 1 and nRet2 ~= 1 then
			szMsg = szMsg .. "\n\n每次获得胜利都可以到我这里领取一个联赛礼包，不过官府仓库有限，只能保留最后一次的<color=yellow>联赛礼包<color>，为避免损失，请各位侠客及时来领取。";
		elseif nRet1 == 1 and nRet2 == 1 then
			szMsg = szMsg .. "\n\n每次获得胜利都可以到我这里领取一个联赛礼包和一次武林大会英豪令兑换武林大会声望的机会，不过官府仓库有限，只能保留最后一次的<color=yellow>联赛礼包<color>和<color=yellow>兑换机会<color>，为避免损失，请各位侠客及时来领取。";
		elseif nRet1 ~= 1 and nRet2 == 1 then
			szMsg = szMsg .. "\n\n每次获得胜利都可以获得一次武林大会英豪令兑换武林大会声望的机会，要及时领取，我可不会帮你记着。";
		end
		if nRet1 == 1 then
			table.insert(tbOpt, 1, {"<color=yellow>领取联赛礼包<color>", Wlls.OnGetAwardSingle, Wlls});
		end
		if nRet2 == 1 then
			table.insert(tbOpt, 1, {"<color=yellow>使用英豪令兑换<color>", Wlls.OnGetAwardSingleWithWldhRep, Wlls});
		end

		if (tbMTCfg) then
			local nSType = tbMTCfg.tbMacthCfg.nSeries;
			if (nSType and Wlls.LEAGUE_TYPE_SERIES_RESTRAINT == nSType) then
				local szLeagueName = League:GetMemberLeague(Wlls.LGTYPE, me.szName);
				table.insert(tbOpt, {"<color=yellow>我要更换参赛五行<color>", Wlls.DialogNpc.OnChangeSeries, Wlls.DialogNpc, szLeagueName});
			end;	
		end
	end

	if nReturn == 1 then
		table.insert(tbOpt, 1, {"参加比赛", self.AttendGame, self});
	end

	if (not GLOBAL_AGENT) then
		if Wlls:GetMacthState() == Wlls.DEF_STATE_ADVMATCH then
			table.insert(tbOpt, 2, {"<color=yellow>观看八强赛战况<color>", Wlls.OnLookDialog, Wlls});	
		end
	end
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:AttendGame(nFlag)

	local tbMTCfg = Wlls:GetMacthTypeCfg(Wlls:GetMacthType());
	if (tbMTCfg) then
		local nSType = tbMTCfg.tbMacthCfg.nSeries;
		if (nSType and Wlls.LEAGUE_TYPE_SERIES_RESTRAINT == nSType) then
			local szLName = League:GetMemberLeague(Wlls.LGTYPE, me.szName);
			local tbLList	= Wlls:GetLeagueMemberList(szLName);
			local nSer=-1;
			if (tbLList) then
				for nId, szMName in ipairs(tbLList) do
					local nSeries	= League:GetMemberTask(Wlls.LGTYPE, szLName, szMName, Wlls.LGMTASK_SERIES);
					if (nSer == -1) then
						nSer = nSeries;
					else
						if (0 == Wlls:IsSeriesRestraint(nSer, nSeries)) then
							Dialog:Say("队伍报名的五行不是相克五行，请到联赛官员那里更换为相克五行。");
							return;
						end;
					end;
				end;
			end;
		end;	
	end	
	
	local nReturn, szMsgInFor = self:CreateMsg();
	if nReturn == 0 then
		Dialog:Say(szMsgInFor);
		return 0;
	end
	if not nFlag then
		for _, tbItem in pairs(Wlls.ForbidItem) do
			if #me.FindItemInBags(unpack(tbItem)) > 0 then
				local szMsg = "会场官员：您身上带有<color=red>禁止使用的药箱<color>，进入比赛将无法使用该类药箱，您确定要进入赛场吗？";
				local tbOpt = 
				{
					{"确定进入赛场", self.AttendGame, self, 1},
					{"Kết thúc đối thoại"},
				};
				Dialog:Say(szMsg, tbOpt);
				return 0;	
			end
		end
	end
	local szLeagueName = League:GetMemberLeague(Wlls.LGTYPE, me.szName);
	local nPlayerCount = Wlls:GetMacthTypeCfg(Wlls:GetMacthType()).tbMacthCfg.nPlayerCount;	
	if League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_ENTER) >= nPlayerCount and (not nFlag or nFlag == 1) then
		local szMsg = string.format("会场官员：本届联赛只允许<color=yellow>%s人<color>参加比赛，你的战队已有<color=yellow>%s个<color>成员进入了准备场，你将<color=yellow>做为替补进入准备场<color>，如果其他队员离开准备场，你将<color=yellow>自动转为正式比赛成员<color>。", nPlayerCount, nPlayerCount)
		local tbOpt = 
		{
			{"以替补身份进入赛场", self.AttendGame, self, 2},
			{"Kết thúc đối thoại"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end

	if Wlls:GetMacthLevelCfgType() == Wlls.MAP_LINK_TYPE_SERIES then
		--未开发
		--判断自己现在的五行和报名时战队记录中的五行是否相符，不符不允许进场；
		local nOrgSereis	= League:GetMemberTask(Wlls.LGTYPE, szLeagueName, me.szName, Wlls.LGMTASK_SERIES);
		if (me.nSeries <= 0) then
			Dialog:Say("武林联赛官员：你还没有任何五行，请尽快加入门派，再来报名参加联赛！");
			return 0;
		end
		if (nOrgSereis > 0 and nOrgSereis ~= me.nSeries) then
			local szOrgSereis = string.format(Wlls.SERIES_COLOR[nOrgSereis], Env.SERIES_NAME[nOrgSereis]);
			local szSereis = string.format(Wlls.SERIES_COLOR[me.nSeries], Env.SERIES_NAME[me.nSeries]);
			Dialog:Say(string.format("会场官员：你报名的是<color=yellow>%s<color>系五行，所以你只能以<color=yellow>%s<color>系五行参加比赛！\n", szOrgSereis, szOrgSereis));
			return 0;			
		end
	end	
	
	if Wlls:GetMacthLevelCfgType() == Wlls.MAP_LINK_TYPE_FACTION then
		--未开发
		--判断自己现在的门派和报名时战队记录中的五行是否相符，不符不允许进场；
		local nFaction	= League:GetMemberTask(Wlls.LGTYPE, szLeagueName, me.szName, Wlls.LGMTASK_FACTION);
		if (nFaction ~= me.nFaction) then
			local szOrgFac	= Player:GetFactionRouteName(nFaction);
			local szNowFac	= Player:GetFactionRouteName(me.nFaction);
			local szMsg = string.format("会场官员：你报名的是<color=yellow>%s<color>门派赛，所以你只能以<color=yellow>%s<color>门派身份参加比赛！\n", szOrgFac, szOrgFac)
			Dialog:Say(szMsg);
			return 0;
		end
	end
	
	local nSeriesType = Wlls:GetMacthTypeCfg(Wlls:GetMacthType()).tbMacthCfg.nSeries;
	if (Wlls.LEAGUE_TYPE_SERIES_RESTRAINT == nSeriesType) then -- 五行相克赛
		local nSeries	= League:GetMemberTask(Wlls.LGTYPE, szLeagueName, me.szName, Wlls.LGMTASK_SERIES);
		if (nSeries ~= me.nSeries) then
			local szOrg = Env.SERIES_NAME[nSeries];
			local szMsg = string.format("会场官员：你报名的是五行相克赛，报名时的五行是<color=yellow>%s<color>系，所以你只能以<color=yellow>%s<color>系五行参加比赛！\n", szOrg, szOrg);
			Dialog:Say(szMsg);
			return 0;
		end
	end
	
	local nGameLevel = League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_MLEVEL);
	local nCaptain = League:GetMemberTask(Wlls.LGTYPE, szLeagueName, me.szName, Wlls.LGMTASK_JOB);
	if not nCaptain then
		Dialog:Say("你好，很抱歉，您的战队出现异常情况，请联系客服处理您战队的异常情况。");
		print([[\script\mission\wlls\npc\wlls_guanyuan3.lua]], "line:136", "league member error!");
		return 0;
	end
	GCExcute{"Wlls:EnterReadyMap", me.nId, szLeagueName, nGameLevel, me.nMapId, {nFaction = me.nFaction, nSeries= me.nSeries, nCamp=me.GetCamp()}, nCaptain};
end

function tbNpc:CreateMsg()
	local nMacthType = Wlls:GetMacthType();
	local tbMacthCfg = Wlls:GetMacthTypeCfg(nMacthType);	
	if not tbMacthCfg then
		return 0, "会场官员：武林联赛功能还未开启。";
	end
	if Wlls:GetMacthState() == Wlls.DEF_STATE_REST then
		return 0, "会场官员：现在是比赛间歇期！";
	end
	local szLeagueName = League:GetMemberLeague(Wlls.LGTYPE, me.szName);
	if not szLeagueName then
		return 0, "会场官员：您还没有战队！";
	end
	
	if League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_MSESSION) ~= Wlls:GetMacthSession() then
		return 0, "会场官员：您的战队不是本届联赛建立的战队，不符合要求！";
	end
	
	local nGameLevel = League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_MLEVEL);
	local nTime = GetTime();
	--八强赛

	local szGameLevelName = Wlls.MACTH_LEVEL_NAME[Wlls.MACTH_ADV];
	if (GLOBAL_AGENT and GbWlls:CheckOpenGoldenGbWlls() == 1) then
		szGameLevelName = GbWlls.MACTH_LEVEL_NAME[Wlls.MACTH_ADV];
	end
	
	if Wlls:GetMacthState() == Wlls.DEF_STATE_ADVMATCH then
		if nGameLevel ~= Wlls.MACTH_ADV then
			return 0, string.format("会场官员：现在是%s联赛决赛期，你的战队不是%s联赛战队！", szGameLevelName, szGameLevelName);
		end
		
		if Wlls.AdvMatchState == 0 then
			return 0, string.format("会场官员：现在是%s联赛决赛期，第一场八强赛将在<color=yellow>19:00<color>开启，请耐心等待！\n\n<color=yellow>你可以在会场内按～键查看赛况<color>", szGameLevelName);
		end
		
		if Wlls:IsAdvMacthLeague(szLeagueName) ~= 1 then
			return 0, string.format("会场官员：您不是本场%s联赛决赛期的战队，无法参加本场决赛期的比赛。\n\n<color=yellow>你可以在会场内按～键查看赛况<color>",szGameLevelName);
		end
		
		if Wlls.ReadyTimerId > 0 then
			local nRestTime = math.floor(Timer:GetRestTime(Wlls.ReadyTimerId)/Env.GAME_FPS);
			if nRestTime >= Wlls.MACTH_TIME_READY_LASTENTER/Env.GAME_FPS then
				return 1, string.format("会场官员：比赛正在报名阶段，等待您的报名。\n\n离比赛开始还剩余<color=yellow>%s<color>，请尽快报名参赛。\n\n<color=yellow>你可以在会场内按～键查看赛况<color>", Lib:TimeFullDesc(nRestTime));
			end
		end
		
		local nHourMin = tonumber(os.date("%H%M", nTime));
		if nHourMin > Wlls.CALEMDAR.tbAdvMatch[#Wlls.CALEMDAR.tbAdvMatch] then
			return 0, "会场官员：本届武林联赛已经完满结束！";
		end
		for nId, nMatchTime in pairs(Wlls.CALEMDAR.tbAdvMatch) do
			if nHourMin < nMatchTime then
				return 0, string.format("会场官员：下场是%s联赛比赛。\n\n比赛类型是<color=yellow>%s强赛<color>\n\n比赛将在<color=yellow>%s<color>开始！\n\n<color=yellow>你可以在会场内按～键查看赛况<color>", szGameLevelName, Wlls.MACTH_STATE_ADV_TASK[nId], Wlls.Fun:Number2Time(nMatchTime));
			end
		end
		return 0, "会场官员：请稍等，比赛马上就要开始！\n\n<color=yellow>你可以在会场内按～键查看赛况<color>";
	end
	
	
	if League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_TOTAL) >= Wlls.MACTH_ATTEND_MAX then
		return 0, string.format("会场官员：您的战队已参加满<color=yellow>%s场<color>，完成了所有比赛，请等待比赛结果！", Wlls.MACTH_ATTEND_MAX);
	end
	
	if Wlls.ReadyTimerId > 0 then
		local nRestTime = math.floor(Timer:GetRestTime(Wlls.ReadyTimerId)/Env.GAME_FPS);
		if nRestTime >= Wlls.MACTH_TIME_READY_LASTENTER/Env.GAME_FPS then
			return 1, string.format("会场官员：比赛正在报名阶段，等待您的报名。\n\n离比赛开始还剩余<color=yellow>%s<color>，请尽快报名参赛。", Lib:TimeFullDesc(nRestTime));
		end
	end
	
	local nWeek = tonumber(os.date("%w", nTime));
	local nHourMin = tonumber(os.date("%H%M", nTime));
	local nDay = tonumber(os.date("%d", nTime));
	local tbCalemdar = Wlls.CALEMDAR.tbCommon;
	
	if Wlls.CALEMDAR.tbWeekDay[nWeek] then
		tbCalemdar = Wlls.CALEMDAR.tbWeekend;
	end
	
	local szGameStart = "会场官员：";
	for nReadyId, tbMission in pairs(Wlls.MissionList[Wlls.MACTH_PRIM]) do
		if tbMission:IsOpen() ~= 0 then
			szGameStart = szGameStart .. "比赛已经开始了！\n\n";
			break;
		end
	end
	
	if Wlls:GetMatchEndForDate(nDay) == 1 and nHourMin > tbCalemdar[#tbCalemdar] then
		return 0, string.format("%s本届联赛循环赛场次已全部举行完，%s联赛将会进入八强赛期！", szGameStart, szGameLevelName);
	end
	
	if nHourMin > tbCalemdar[#tbCalemdar] then
		return 0, string.format("%s今天的联赛场次已全部结束，请明天再来参赛！", szGameStart);
	end	
	if nHourMin < tbCalemdar[1] then
		return 0, string.format("%s下场比赛的时间为<color=yellow>%s<color>！", szGameStart, Wlls.Fun:Number2Time(tbCalemdar[1]));
	end
	for nId, nMatchTime in ipairs(tbCalemdar) do
		if nHourMin > nMatchTime and tbCalemdar[nId+1] and nHourMin <= tbCalemdar[nId+1] then
			return 0, string.format("%s下场比赛的时间为<color=yellow>%s<color>！", szGameStart, Wlls.Fun:Number2Time(tbCalemdar[nId+1]));
		end
	end
	return 0, "会场官员：请稍等，比赛马上就要开始！";
end

