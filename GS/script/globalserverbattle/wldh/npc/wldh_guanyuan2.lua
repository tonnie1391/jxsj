--大会会场官员
--孙多良
--2008.09.12

local tbNpc = Npc:GetClass("Wldh_guanyuan2");

function tbNpc:OnDialog()
	local nType, nIsFinal = Wldh:GetCurGameType();
	if nType <= 0 then
		Dialog:Say("你好，有什么需要帮忙吗？");
		return 0;
	end	
	local szMsg = "";
	if nIsFinal > 0 then
		szMsg = string.format([[
   现在的赛制是<color=yellow>%s决赛<color>阶段。
   比赛时间表如下：<color=yellow>
      20：00  32进16
      20：15  16进8
      20：30  8进4
      20：45  4进2
      21：00  2进1 第一场
      21：15  2进1 第二场
      21：30  2进1 第三场<color>]], Wldh:GetName(nType));
    else
    	szMsg = string.format("现在的赛制是<color=yellow>%s<color>。\n\n比赛时间为每天20：00～22：00，每15分钟一场比赛，21：45分为最后一场比赛，请留意比赛开始时间。", Wldh:GetName(nType))
	end
	local tbOpt = 
	{
		{"我要查询相关赛况",Wldh.DialogNpc.Query, Wldh.DialogNpc},
		{"离开会场", self.LeaveHere, self},
		{"Kết thúc đối thoại"},
	};
	if Wldh.tbReadyTimer[nType] and Wldh.tbReadyTimer[nType] > 0 then
		table.insert(tbOpt, 1, {"参加比赛", self.AttendGame, self});
	end
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:LeaveHere()
	
	local nGateWay = Transfer:GetTransferGateway();
	
	if not Wldh.Battle.tbLeagueName[nGateWay] then
		me.NewWorld(1609, 1680, 3269);
		return 0;
	end
	
	local nMapId = Wldh.Battle.tbLeagueName[nGateWay][2];
	
	if nMapId then
		me.NewWorld(nMapId, 1680, 3269);
	end
	
end

function tbNpc:AttendGame(nFlag)
	local nType,nIsFinal = Wldh:GetCurGameType();
	if not Wldh.tbReadyTimer[nType] or Wldh.tbReadyTimer[nType] <= 0 then
		Dialog:Say("比赛未开始");
		return 0;
	end
	local nLGType = Wldh:GetLGType(nType);
	local szLeagueName = League:GetMemberLeague(nLGType, me.szName);
	if not szLeagueName then
		Dialog:Say("你还没有战队。");
		return 0;
	end	
	local nAdvState = Wldh.AdvMatchState[nType] or 0;
	if nAdvState > 0 then
		if Wldh:IsAdvMacthLeague(nType, nAdvState, szLeagueName) ~= 1 then
			Dialog:Say("会场官员：您不是本场武林大会决赛的参赛战队，无法参加本场决赛期的比赛。\n\n<color=yellow>你可以在会场内按～键查看赛况<color>");
			return 0;
		end
	end
	if not nFlag then
		for _, tbItem in pairs(Wldh.ForbidItem) do
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
	local nRestTime = math.floor(Timer:GetRestTime(Wldh.tbReadyTimer[nType])/Env.GAME_FPS);
	if nRestTime < Wldh.MACTH_TIME_READY_LASTENTER/Env.GAME_FPS then
		Dialog:Say("比赛报名时间已经结束，即将开始比赛。");
		return 0;
	end
	local nTotal = League:GetLeagueTask(nLGType, szLeagueName, Wldh.LGTASK_TOTAL);
	if nTotal >= Wldh.MACTH_ATTEND_MAX and nAdvState <= 0 then
		Dialog:Say("你本赛制的参赛次数已达24场，每个战队最多只能参赛24场。");
		return 0;
	end
	
	if Wldh:GetMapLinkType(nType) == Wldh.MAP_LINK_TYPE_FACTION then
		--判断自己现在的门派和报名时战队记录中的五行是否相符，不符不允许进场；
		local nFaction	= League:GetMemberTask(nLGType, szLeagueName, me.szName, Wldh.LGMTASK_FACTION);
		if (nFaction ~= me.nFaction) then
			local szOrgFac	= Player:GetFactionRouteName(nFaction);
			local szNowFac	= Player:GetFactionRouteName(me.nFaction);
			local szMsg = string.format("会场官员：你报名的是<color=yellow>%s<color>门派赛，所以你只能以<color=yellow>%s<color>门派身份参加比赛！\n", szOrgFac, szOrgFac)
			Dialog:Say(szMsg);
			return 0;
		end
	end
	
	local nSeriesType = Wldh:GetCfg(nType).nSeries;
	if (Wldh.LEAGUE_TYPE_SERIES_MIX == nSeriesType) then -- 五行五人赛
		local nSeries	= League:GetMemberTask(nLGType, szLeagueName, me.szName, Wldh.LGMTASK_SERIES);
		if (nSeries ~= me.nSeries) then
			local szOrg = Env.SERIES_NAME[nSeries] or "<color=gray>无五行<color>";
			local szMsg = string.format("会场官员：你报名的是五行相克赛，报名时的五行是<color=yellow>%s<color>系，所以你只能以<color=yellow>%s<color>系五行参加比赛！\n", szOrg, szOrg);
			Dialog:Say(szMsg);
			return 0;
		end
	end
	
	local szLeagueName = League:GetMemberLeague(nLGType, me.szName);
	if not szLeagueName then
		Dialog:Say("没有战队");
		return 0;
	end
	GCExcute{"Wldh:EnterReadyMap", me.nId, szLeagueName, nType, me.nMapId, {nFaction = me.nFaction, nSeries= me.nSeries, nCamp=me.GetCamp()}, 0};
end
