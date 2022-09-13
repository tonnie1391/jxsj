-- 文件名　：wlls_looker.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-07-07 17:24:20
-- 描  述  ：联赛观战
Wlls.LOOK_READYID = 1;	--类型
Wlls.LOOK_PKID 	  = 2;	--类型
Wlls.LOOK_PLAYER_MAX 	  = 50;	--观战人数；每个场的最大人数

function Wlls:OnLookDialog(nReadyId, nSure)
	if Wlls.GameState <= 0 and Wlls.GameState > 2 then
		Dialog:Say("观战只能在报名准备阶段报名观战，现在不能进行观战。");
		return 0;			
	end
	
	if me.nLevel < 100 then
		Dialog:Say("必须等级达到100级以上才有资格观战。");
		return 0;				
	end
	
	if Wlls.GameState == 1 and Wlls.ReadyTimerId > 0 and Timer:GetRestTime(Wlls.ReadyTimerId) <= Wlls.MACTH_TIME_READY_LASTENTER then
		Dialog:Say("比赛的战队正在进入比赛场，请稍后几秒，等待比赛选手入场后，再进入观战。");
		return 0;
	end
 
	if Wlls:GetMacthLevelCfgType() == Wlls.MAP_LINK_TYPE_RANDOM then
		nReadyId = 1;
	end
	
	if not nSure and Wlls:GetMacthLevelCfgType() == Wlls.MAP_LINK_TYPE_SERIES then
		local szMsg = "现在正在进行门派赛八强赛！\n请选择你想要观战的门派？";
		local tbOpt = {
			{"金系八强赛", self.OnLookDialog, self, 1, 1},
			{"木系八强赛", self.OnLookDialog, self, 2, 1},
			{"水系八强赛", self.OnLookDialog, self, 3, 1},
			{"火系八强赛", self.OnLookDialog, self, 4, 1},
			{"土系八强赛", self.OnLookDialog, self, 5, 1},
			{"我只是看看"},
			};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end	
	
	if not nSure and Wlls:GetMacthLevelCfgType() == Wlls.MAP_LINK_TYPE_FACTION then
		local szMsg = "现在正在进行门派赛八强赛！\n请选择你想要观战的门派？";
		local tbOpt = {};
		for i=1, Env.FACTION_NUM  do
			table.insert(tbOpt, {Player:GetFactionRouteName(i).."八强赛", self.OnLookDialog, self, i, 1});
		end
		table.insert(tbOpt, {"Để ta suy nghĩ lại"});
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	
	local tbPlayerList = Wlls:GetAdvMatchLeagueList(nReadyId);
	if #tbPlayerList <= 0 then
		Dialog:Say("没有参赛队伍或比赛还没开始，现在不能进行观战。");
		return 0;
	end
	local nLevel = Wlls.MACTH_STATE_ADV_TASK[Wlls.AdvMatchState];
	if not nLevel or nLevel <= 0 then
		Dialog:Say("比赛还没开始，现在不能进行观战。");
		return 0;		
	end
	
	local szGameLevelName = Wlls.MACTH_LEVEL_NAME[2];
	if (GLOBAL_AGENT and GbWlls:CheckOpenGoldenGbWlls() == 1) then
		szGameLevelName = GbWlls.MACTH_LEVEL_NAME[2];
	end
	local szMsg = string.format("现在正在进行<color=yellow>%s联赛%s强赛<color>。\n选择你想观看的联赛战队", szGameLevelName, nLevel);
	local tbOpt = {};
	if nLevel == 8 then
		for i=1, 4 do
			if tbPlayerList[i] or tbPlayerList[9-i] then
				local szLeagueA = "<color=gray>无队伍<color>";
				local szLeagueB = "<color=gray>无队伍<color>";
				local szName1 = "";
				local szName2 = "";
				if tbPlayerList[i] then
					szLeagueA = string.format("<color=gold>%s<color>", tbPlayerList[i].szName);
					szName1 = tbPlayerList[i].szName;
				end
				if tbPlayerList[9-i] then
					szLeagueB = string.format("<color=gold>%s<color>", tbPlayerList[9-i].szName);
					szName2 = tbPlayerList[9-i].szName;
				end
				local szSelect = string.format("%s Vs %s",szLeagueA, szLeagueB);
				table.insert(tbOpt, {szSelect, self.OnLookInto, self, szName1, szName2, nReadyId});
			end
		end		
	end
	
	if nLevel == 4 then
		for i=1, 2 do
			if tbPlayerList[i] or tbPlayerList[i+2] then
				local szLeagueA = "<color=gray>无队伍<color>";
				local szLeagueB = "<color=gray>无队伍<color>";
				local szName1 = "";
				local szName2 = "";				
				if tbPlayerList[i] then
					szLeagueA = string.format("<color=gold>%s<color>", tbPlayerList[i].szName);
					szName1 = tbPlayerList[i].szName;
				end
				if tbPlayerList[i+2] then
					szLeagueB = string.format("<color=gold>%s<color>", tbPlayerList[i+2].szName);
					szName2 = tbPlayerList[i+2].szName;
				end
				local szSelect = string.format("%s Vs %s",szLeagueA, szLeagueB);
				table.insert(tbOpt, {szSelect, self.OnLookInto, self, szName1, szName2, nReadyId});
			end
		end				
	end
	
	if nLevel == 2 then
		if tbPlayerList[1] or tbPlayerList[2] then
			local szLeagueA = "<color=gray>无队伍<color>";
			local szLeagueB = "<color=gray>无队伍<color>";
				local szName1 = "";
				local szName2 = "";			
			if tbPlayerList[1] then
				szLeagueA = string.format("<color=gold>%s<color>", tbPlayerList[1].szName);
				szName1 = tbPlayerList[1].szName;
			end
			if tbPlayerList[2] then
				szLeagueB = string.format("<color=gold>%s<color>", tbPlayerList[2].szName);
				szName2 = tbPlayerList[2].szName;
			end
			local szSelect = string.format("%s Vs %s",szLeagueA, szLeagueB);
			table.insert(tbOpt, {szSelect, self.OnLookInto, self, szName1, szName2, nReadyId});
		end		
	end	

	
	table.insert(tbOpt, {"Để ta suy nghĩ lại"});
	Dialog:Say(szMsg, tbOpt);
end

function Wlls:OnLookInto(szLeagueName, szLeagueName2, nReadyId)
	if Wlls.GameState <= 0 and Wlls.GameState > 2 then
		Dialog:Say("观战只能在报名准备阶段报名观战，现在不能进行观战。");
		return 0;			
	end
	
	if Wlls.GameState == 1 and Wlls.ReadyTimerId > 0 and Timer:GetRestTime(Wlls.ReadyTimerId) <= Wlls.MACTH_TIME_READY_LASTENTER then
		Dialog:Say("比赛的战队正在进入比赛场，请稍后几秒，等待比赛选手入场后，再进入观战。");
		return 0;
	end
 	
 	local nMapId = 0;
 	local nPosX	 = 0;
 	local nPosY	 = 0;
 	local nType  = 0;
	if Wlls.GameState == 2 then
		if not Wlls.LookerLeagueMap[szLeagueName] or not Wlls.LookerLeagueMap[szLeagueName2] then
			Dialog:Say("你选择的观战队伍不在比赛场或者他的比赛已经结束。");		
			return 0;
		end
		nMapId, nPosX, nPosY = unpack(Wlls.LookerLeagueMap[szLeagueName]);
		nType = Wlls.LOOK_PKID;
	else
		local tbMacthLevelCfg = self:GetMacthLevelCfg(self:GetMacthType(), 2);
		local tbPos = self.MACTH_TRAP_ENTER[MathRandom(1, #self.MACTH_TRAP_ENTER)];
		nMapId = tbMacthLevelCfg.tbReadyMap[nReadyId];
		nPosX, nPosY = unpack(tbPos);
		nType  = Wlls.LOOK_READYID;
	end
	
 	if Wlls.LookPlayerCount[szLeagueName] and Wlls.LookPlayerCount[szLeagueName] >= self.LOOK_PLAYER_MAX then
 		Dialog:Say("该场比赛的观战人数已满。");
		return 0;		
 	end	
	
	if nMapId == 0 or nPosX == 0 or nPosY == 0 or nType == 0 then
		return 0;
	end
	Looker:SetParamStr(1, szLeagueName);
	Looker:SetParamStr(2, szLeagueName2);
	Looker:Join(me, nType, nMapId, nPosX, nPosY, 0);
end

--观者者进入准备场回调
function Wlls:LookOnEnterReady()
	--print("Wlls:LookOnEnterReady");
	if Wlls.ReadyTimerId <= 0 then
		Looker:Leave(me);
		return 0;
	end
	local szLookLeagueName = Looker:GetParamStr(1);
	local szLookLeagueName2 = Looker:GetParamStr(2);
	local szUiName1 = "<color=gray>Không có tổ đội<color>";
	local szUiName2 = "<color=gray>Không có tổ đội<color>";
	if szLookLeagueName ~= "" then
		szUiName1 = string.format("<color=gold>%s<color>", szLookLeagueName);
	end
	if szLookLeagueName2 ~= "" then
		szUiName2 = string.format("<color=gold>%s<color>", szLookLeagueName2);
	end	
	
	local nReadyId = Wlls:GetMacthMapSeriesId(2, me.nMapId, 0);
	local nLastFrameTime = tonumber(Timer:GetRestTime(Wlls.ReadyTimerId));
	local szMsg = "<color=green>Thời gian còn lại: <color=white>%s<color>";
	Wlls:OpenSingleUi(me, szMsg, nLastFrameTime);
	Wlls:UpdateMsgUi(me, string.format("\n<color=green>Chiến đội: \n<color=gold>%s<color> Vs <color=gold>%s<color>\n\n<color=green>Chờ đợi đến khi bắt đầu<color>", szUiName1, szUiName2));
	Dialog:SendBlackBoardMsg(me, "Đã vào khu chuẩn bị, khi thời gian kết thúc, sẽ tự động tham chiến.")
	me.Msg("Đã vào khu chuẩn bị, <color=yellow>Sau khi thời gian kết thúc<color>, bạn sẽ <color=yellow>tự tham chiến<color>.");
	local nUsefulTime = 15 * 60 * 18;
	Wlls:SyncAdvMatchUiSingle(me, nReadyId, nUsefulTime);
	Wlls.tbLook[nReadyId] = Wlls.tbLook[nReadyId] or {};
	Wlls.tbLook[nReadyId][szLookLeagueName] = Wlls.tbLook[nReadyId][szLookLeagueName] or {};
	Wlls.tbLook[nReadyId][szLookLeagueName][me.nId] = 1;
	GlobalExcute({"Wlls:AddLooker", szLookLeagueName});
end

--观者者离开准备场回调--0则为离开观战;1则为进入另一个观战场
function Wlls:LookOnLeaveReady()
	--print("Wlls:LookOnLeaveReady");
	local szLookLeagueName = Looker:GetParamStr(1);
	Wlls:CloseSingleUi(me);
	local nReadyId = Wlls:GetMacthMapSeriesId(2, me.nMapId, 0);
	if Wlls.tbLook and Wlls.tbLook[nReadyId] and Wlls.tbLook[nReadyId][szLookLeagueName] then
		Wlls.tbLook[nReadyId][szLookLeagueName][me.nId] = nil;
	end
	GlobalExcute({"Wlls:MinusLooker", szLookLeagueName});
end

--观者者进入比赛场回调
function Wlls:LookOnEnterPk()
	local szLookLeagueName = Looker:GetParamStr(1);
	if not self.LookerLeagueMap[szLookLeagueName] or not self.LookerLeagueMap[szLookLeagueName][4] then
		Looker:Leave(me);
		return 0;
	end
	local tbMis = self.LookerLeagueMap[szLookLeagueName][4];
	local szMacthName = tbMis.tbLeagueList[szLookLeagueName].szMacthName;
	local szMsg = string.format(Wlls.MIS_UI[2][1], szLookLeagueName, szMacthName);
	local szMsg2 = string.format(Wlls.MIS_UI_LOOKER, szMacthName, 0, szLookLeagueName, 0);
	Wlls:OpenSingleUi(me, szMsg..Wlls.MIS_UI[2][2], tbMis:GetStateLastTime());
	Wlls:UpdateMsgUi(me, szMsg2);
	
	tbMis:JoinLooker(szLookLeagueName, me.nId);
	
	Dialog:SendBlackBoardMsg(me, "进入比赛场,比赛即将开始");
	if Wlls.tbLookerReady[me.nId] then
		Wlls.tbLookerReady[me.nId] = nil;
		return 0;
	end
	GlobalExcute({"Wlls:AddLooker", szLookLeagueName});
	--print("Wlls:LookOnEnterPk");
end

--观者者离开比赛场回调
function Wlls:LookOnLeavePk()
	--print("Wlls:LookOnLeavePk");
	local szLookLeagueName = Looker:GetParamStr(1);
	if not self.LookerLeagueMap[szLookLeagueName] or not self.LookerLeagueMap[szLookLeagueName][4] then
		Wlls:CloseSingleUi(me);
		return 0;
	end
	local tbMis = self.LookerLeagueMap[szLookLeagueName][4];
	
	if (0 == tbMis:LeaveLooker(szLookLeagueName, me.nId)) then
		Wlls:CloseSingleUi(me);
		return 0;
	end
	
	Wlls:CloseSingleUi(me);
	GlobalExcute({"Wlls:MinusLooker", szLookLeagueName});
end

function Wlls:AddLooker(szLeagueName)
	Wlls.LookPlayerCount[szLeagueName] = Wlls.LookPlayerCount[szLeagueName] or 0;
	Wlls.LookPlayerCount[szLeagueName] = Wlls.LookPlayerCount[szLeagueName] + 1;
end

function Wlls:MinusLooker(szLeagueName)
	Wlls.LookPlayerCount[szLeagueName] = Wlls.LookPlayerCount[szLeagueName] or 0;
	--print(szLeagueName, Wlls.LookPlayerCount[szLeagueName]);
	if Wlls.LookPlayerCount[szLeagueName] > 0 then
		Wlls.LookPlayerCount[szLeagueName] = (Wlls.LookPlayerCount[szLeagueName] - 1);
	end
	--print(szLeagueName, Wlls.LookPlayerCount[szLeagueName]);
end
