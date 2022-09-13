--活动平台
--zhouchenfei
--2009.08.20

local tbNpc = EPlatForm.tbNpc or {};
EPlatForm.tbNpc = tbNpc;

function tbNpc:OnDialog()
	if me.GetTiredDegree1() == 2 then
		me.Msg("您太累了，还是休息下吧！");
		return;
	end
	Player.tbOnlineExp:CloseOnlineExp();

	local nReturn, szMsgInFor = self:CreateMsg();
	
	if (2 == nReturn) then
		local szMsg = "现在是家族预选赛，你的队伍还处在验证确认阶段。";

		local szLeagueName = League:GetMemberLeague(EPlatForm.LGTYPE, me.szName);
		local szMemberMsg = "";
		if szLeagueName then
			local tbLeagueList = EPlatForm:GetLeagueMemberList(szLeagueName);
			szMemberMsg = self:GetLeagueInfoMsg(szLeagueName);
			szMemberMsg = string.format("战队信息：\n%s", szMemberMsg);
		end
		
		local tbOpt = {
			{"更换队员", self.OnChangeTeamMember, self, me.szName},
			{"确认验证", self.OnCheckTeam, self, me.szName},
			{"Để ta suy nghĩ lại"},
		};
		local szLeagueName = League:GetMemberLeague(EPlatForm.LGTYPE, me.szName);
		if (not szLeagueName) then
			Dialog:Say(string.format("您不是参加家族预选赛阶段活动的成员！\n%s", szMemberMsg));
			return 0;
		end
		
		local nCaptain = League:GetMemberTask(EPlatForm.LGTYPE, szLeagueName, me.szName, EPlatForm.LGMTASK_JOB);
		if (nCaptain ~= 1) then
			szMsg = string.format("%s你不是临时战队队长，不能确认验证。", szMsg);
			tbOpt = {"Ta chỉ đến xem thôi"};
		end
		szMsg = string.format("%s\n%s", szMsg, szMemberMsg);
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end

	local tbOpt = 
	{
		{"Kết thúc đối thoại"},
	};
--	if EPlatForm:OnCheckAwardSingle(me) == 1 then
--		szMsg = szMsg .. "\n\n每次获得胜利都可以到我这里领取一个联赛礼包，不过官府仓库有限，只能保留最后一次的<color=yellow>联赛礼包<color>，为避免损失，请各位侠客及时来领取。";
--		table.insert(tbOpt, 1, {"<color=yellow>领取联赛礼包<color>", EPlatForm.OnGetAwardSingle, EPlatForm});
--	end
	if nReturn == 1 then
		table.insert(tbOpt, 1, {"参加比赛", self.AttendGame, self});
	end
	Dialog:Say(szMsgInFor, tbOpt);
end

function tbNpc:AttendGame(nFlag)

	local tbMTCfg = EPlatForm:GetMacthTypeCfg(EPlatForm:GetMacthType());

	local nReturn, szMsgInFor = self:CreateMsg();
	if nReturn == 0 then
		Dialog:Say(szMsgInFor);
		return 0;
	end
	
	if (tbMTCfg) then
		if (tbMTCfg.tbMacthCfg and tbMTCfg.tbMacthCfg.tbJoinItem and #tbMTCfg.tbMacthCfg.tbJoinItem > 0) then
			local nEnterFlag = EPlatForm:CheckEnterCount(me, tbMTCfg.tbMacthCfg.tbJoinItem);
			local szMsg = "";
			local nNameCount = 0;
			for _, tbItemInfo in pairs(tbMTCfg.tbMacthCfg.tbJoinItem) do
				if (tbItemInfo.tbItem) then
					local szName = EPlatForm:GetItemName(tbItemInfo.tbItem);
					if (szName and string.len(szName) > 0) then
						if (nNameCount > 0) then
							szMsg = string.format("%s<color=white>或<color>", szMsg);
						end
						
						szMsg = string.format("%s%s", szMsg, szName);
						nNameCount = nNameCount + 1;
					end
				end
			end
			if (string.len(szMsg) <= 0) then
				szMsg = "活动道具";
			end
			if (nEnterFlag <= 0) then
				Dialog:Say(string.format("你身上没有<color=yellow>%s<color>，不能参加活动", szMsg));
				return 0;
			elseif (nEnterFlag > 1) then
				Dialog:Say(string.format("你身上<color=yellow>%s<color>携带数量只能是一个，请取出背包中多余的道具，再来参加活动吧！", szMsg));
				return 0;
			end
			
			local nItemFlag, szItemMsg = EPlatForm:ProcessItemCheckFun(me, tbMTCfg.tbMacthCfg.tbJoinItem);
			if (0 == nItemFlag) then
				Dialog:Say(szItemMsg);
				return 0;
			end
		end
	end
	
	if not nFlag then
		for _, tbItem in pairs(EPlatForm.ForbidItem) do
			if #me.FindItemInBags(unpack(tbItem)) > 0 then
				local szMsg = "您身上带有<color=red>禁止使用的药箱<color>，进入比赛将无法使用该类药箱，您确定要进入赛场吗？";
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
	local szLeagueName	= me.szName;
	local nCaptain		= 1;
	if (EPlatForm:GetMacthState() ~= EPlatForm.DEF_STATE_MATCH_1) then
		szLeagueName = League:GetMemberLeague(EPlatForm.LGTYPE, me.szName);
		local nPlayerCount = EPlatForm:GetMacthTypeCfg(EPlatForm:GetMacthType()).tbMacthCfg.nPlayerCount;	
		if League:GetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_ENTER) >= nPlayerCount and (not nFlag or nFlag == 1) then
			local szMsg = string.format("本届活动只允许<color=yellow>%s人<color>参加比赛，你的战队已有<color=yellow>%s个<color>成员进入了准备场，你将<color=yellow>做为替补进入准备场<color>，如果其他队员离开准备场，你将<color=yellow>自动转为正式比赛成员<color>。", nPlayerCount, nPlayerCount)
			local tbOpt = 
			{
				{"以替补身份进入赛场", self.AttendGame, self, 2},
				{"Kết thúc đối thoại"},
			};
			Dialog:Say(szMsg, tbOpt);
			return 0;
		end
		nCaptain = League:GetMemberTask(EPlatForm.LGTYPE, szLeagueName, me.szName, EPlatForm.LGMTASK_JOB);
	end
	GCExcute{"EPlatForm:EnterReadyMap", me.nId, szLeagueName, me.nMapId, {nFaction = me.nFaction, nSeries= me.nSeries, nCamp=me.GetCamp()}, nCaptain};
end

function tbNpc:OnChangeTeamMember(szName)
	local szMsg = "";
	if (not szName) then
		return;
	end
	
	if (szName ~= me.szName) then
		return;
	end
	
	local nFlag = self:OnCheckChangeTeamMember(me);
	if (0 >= nFlag) then
		return 0;
	end
	
	local tbChangeMem = {};
	
	local tbTeamMemberList = KTeam.GetTeamMemberList(me.nTeamId);
	for _, nPlayerId in pairs(tbTeamMemberList) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		local szLeague = League:GetMemberLeague(EPlatForm.LGTYPE, pPlayer.szName);	
		if (me.szName ~= pPlayer.szName) then
			local tbInfo = {};
			tbInfo[1] = pPlayer.szName;
			tbInfo[2] = szLeague;
			tbChangeMem[#tbChangeMem + 1] = tbInfo;
		end
	end
	
	if (#tbChangeMem < 2) then
		return 0;
	end
	local szMsg = string.format("你确定要将<color=yellow>%s<color>队队员<color=yellow>%s<color>和<color=green>%s<color>队队员<color=green>%s<color>互相更换吗？", tbChangeMem[1][2], tbChangeMem[1][1], tbChangeMem[2][2], tbChangeMem[2][1]);
	Dialog:Say(szMsg, 
	{
		{"确定更换", self.OnSureChangeMember, self, me.szName},
		{"Để ta suy nghĩ lại"},	
	});
end

function tbNpc:OnSureChangeMember(szName)
	if (not szName or szName ~= me.szName) then
		return 0;
	end

	local nFlag = self:OnCheckChangeTeamMember(me);
	if (0 >= nFlag) then
		return 0;
	end
	
	local tbChangeMem = {};

	local tbTeamMemberList = KTeam.GetTeamMemberList(me.nTeamId);
	for _, nPlayerId in pairs(tbTeamMemberList) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		local szLeague = League:GetMemberLeague(EPlatForm.LGTYPE, pPlayer.szName);	
		if (me.szName ~= pPlayer.szName) then
			local tbInfo = {};
			tbInfo.szName = pPlayer.szName;
			tbInfo.szLeagueName = szLeague;
			tbInfo.nFaction = pPlayer.nFaction;
			tbInfo.nRouteId	= pPlayer.nRouteId;
			tbInfo.nCamp	= 0;
			tbInfo.nSex		= pPlayer.nSex;
			tbInfo.nSeries	= pPlayer.nSeries;	
			tbChangeMem[#tbChangeMem + 1] = tbInfo;
		end
	end
	
	if (#tbChangeMem < 2) then
		return 0;
	end
	
	GCExcute{"EPlatForm:ChangeTeamMemeber", szName, tbChangeMem};

	return 1;
end

function tbNpc:OnCheckChangeTeamMember(pMyPlayer)
	local szLeagueName = League:GetMemberLeague(EPlatForm.LGTYPE, pMyPlayer.szName);	

	if pMyPlayer.nTeamId <= 0 then
		Dialog:Say("必须组队才能建立战队！");
		return 0;
	end

	if pMyPlayer.IsCaptain() == 0 then
		Dialog:Say("必须是队长才能建立战队！");
		return 0;
	end	

	if (not szLeagueName) then
		Dialog:Say("您没有家族预选赛资格！");
		return 0;
	end
	
	local nCaptain = League:GetMemberTask(EPlatForm.LGTYPE, szLeagueName, pMyPlayer.szName, EPlatForm.LGMTASK_JOB);
	if (1 ~= nCaptain) then
		Dialog:Say("你不是战队的队长，不能申请更换队员！");
		return 0;
	end

	local tbTeamMemberList = KTeam.GetTeamMemberList(pMyPlayer.nTeamId);
	
	if (not tbTeamMemberList) then
		Dialog:Say("更换队员需要组队，且队员就在附近");
		return 0;
	end
	
	if (#tbTeamMemberList ~= 3) then
		Dialog:Say("队伍的人数与申请更换人数不一致，申请更换队员需要一名战队队长，两名需要更换的队员！");
		return 0;
	end
	
	local nMapId, nPosX, nPosY	= pMyPlayer.GetWorldPos();
	local szTempLeagueName = "";
	local tbChangeMem		= {};
	for _, nPlayerId in pairs(tbTeamMemberList) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if not pPlayer then
			Dialog:Say("您的申请更换的队员必须在这附近。");
			return 0;
		end
		local nMapId2, nPosX2, nPosY2	= pPlayer.GetWorldPos();
		local nDisSquare = (nPosX - nPosX2)^2 + (nPosY - nPosY2)^2;
		if nMapId2 ~= nMapId or nDisSquare > 400 then
			Dialog:Say("您的申请更换的队员必须在这附近。");
			return 0;
		end		
		if not pPlayer or pPlayer.nMapId ~= nMapId then
			Dialog:Say("您的申请更换的队员必须在这附近。");
			return 0;
		end
		
		local szLeague = League:GetMemberLeague(EPlatForm.LGTYPE, pPlayer.szName);
		if not szLeague then
			Dialog:Say(string.format("队伍中<color=yellow>%s<color>没有家族预选赛资格，不能更换。", pPlayer.szName));
			return 0;
		end
		
		local nSession = League:GetLeagueTask(EPlatForm.LGTYPE, szLeague, EPlatForm.LGTASK_MTYPE);
		
		if (nSession > 0) then
			Dialog:Say(string.format("%s队员所在的战队已经是通过确认的战队，不能更换队伍了！", pPlayer.szName));
			return 0;
		end
		
		local szKinName = EPlatForm:GetKinNameFromLeagueName(szLeague);
		if (not szKinName) then
			Dialog:Say("战队不是家族战队");
			return 0;
		end

		local pKin = KKin.GetKin(pPlayer.dwKinId);
		if (not pKin) then
			Dialog:Say(string.format("队员%s无家族", pPlayer.szName));
			return 0;			
		end

		if (pKin.GetName() ~= szKinName) then
			Dialog:Say(string.format("队员%s报名时的家族和你报名时的家族不一致，不能更换队员", pPlayer.szName));
			return 0;
		end
		
		if (pMyPlayer.szName ~= pPlayer.szName) then
			local nCaptain = League:GetMemberTask(EPlatForm.LGTYPE, szLeague, pPlayer.szName, EPlatForm.LGMTASK_JOB);
			if (1 == nCaptain) then
				Dialog:Say(string.format("%s是%s队的队长，不能作为更换队员！", pPlayer.szName, szLeague));
				return 0;
			end
			if (string.len(szTempLeagueName) <= 0) then
				szTempLeagueName = szLeague;
			else
				if (szTempLeagueName == szLeague) then
					Dialog:Say("您的队伍中更换的队员是同一战队的！");
					return 0;
				end
				local szKinA = EPlatForm:GetKinNameFromLeagueName(szTempLeagueName);
				local szKinB = EPlatForm:GetKinNameFromLeagueName(szLeague);
				
				if (szKinA ~= szKinB) then
					Dialog:Say("您的队伍中更换的队员不在同一个家族！");
					return 0;					
				end
			end
		end
	end
	return 1;
end

function tbNpc:OnCheckTeam(szName)
	if (not szName or me.szName ~= szName) then
		return 0;
	end
	local szLeagueName = League:GetMemberLeague(EPlatForm.LGTYPE, szName);
	if not szLeagueName then
		Dialog:Say("没有加入任何战队")
		return 0;
	end
	
	local nCaptain = League:GetMemberTask(EPlatForm.LGTYPE, szLeagueName, szName, EPlatForm.LGMTASK_JOB);

	if (1 ~= nCaptain) then
		Dialog:Say("只有队长才能申请确认！");
		return 0;
	end

	Dialog:Say("队长验证确认参加家族预选赛队伍：", 
		{
			{"更换战队名字并确认", self.OnSureTeam, self, szName, 2},
			{"直接确认", self.OnSureTeam, self, szName, 1, szLeagueName},
			{"Để ta suy nghĩ lại"},
		});

	return 0;
end

function tbNpc:OnSureTeam(szName, nNameFlag, szCreateLeagueName)
	if (not szName or me.szName ~= szName) then
		return 0;
	end
	--=========================这里的名字包括了家族名
	if (not szCreateLeagueName) then
		if (2 == nNameFlag) then
			Dialog:AskString("请输入战队名：", 8, self.OnSureTeam, self, szName, 2);
		else
			Dialog:Say("没有战队名");
		end
		return 0;
	end
	
	local szLeague = League:GetMemberLeague(EPlatForm.LGTYPE, szName);
	if not szLeague then
		Dialog:Say("没有加入任何战队")
		return 0;
	end

	local nCaptain = League:GetMemberTask(EPlatForm.LGTYPE, szLeague, szName, EPlatForm.LGMTASK_JOB);

	if (1 ~= nCaptain) then
		Dialog:Say("只有队长才能申请确认！");
		return 0;
	end
	
	-- 是新取的名字
	if (2 == nNameFlag) then
	--名字合法性检查
		local szKinName = EPlatForm:GetKinNameFromLeagueName(szLeague);
		if (not szKinName) then
			Dialog:Say("原战队名有误");
			return 0;			
		end
		local nLen = GetNameShowLen(szCreateLeagueName);
		if nLen < 6 or nLen > 8 then
			Dialog:Say("您的战队名字的字数达不到要求,必须要3到4个汉字之间。");
			return 0;
		end
		
		--是否允许的单词范围
		if KUnify.IsNameWordPass(szCreateLeagueName) ~= 1 then
			Dialog:Say("您的战队名字含有非法字符。");
			return 0;
		end
		
		--是否包含敏感字串
		if IsNamePass(szCreateLeagueName) ~= 1 then
			Dialog:Say("您的战队名字含有非法的敏感字符。");
			return 0;
		end

		szCreateLeagueName = string.format("%s_%s", szKinName, szCreateLeagueName);

		if League:FindLeague(EPlatForm.LGTYPE, szCreateLeagueName) then
			Dialog:Say("战队名字<color=yellow>%s<color>已经存在，请更换名字！");
			return 0;
		end	
	end

	local nType, szMsg = EPlatForm:ProcessCreateFormatTeam(szName, szCreateLeagueName, nNameFlag);
	if (szMsg) then
		Dialog:Say(szMsg);
	end
	return 1;
end

function tbNpc:CreateMsg()	
	if EPlatForm:GetMacthSession() <= 0 then
		return 0, "活动还未开启。";
	end	
	
	local nMacthType = EPlatForm:GetMacthType();
	local tbMacth	= EPlatForm:GetMacthTypeCfg(nMacthType);

	if not tbMacth then
		return 0, "活动还未开启。";
	end	
	
	local tbMacthCfg	= tbMacth.tbMacthCfg;

	if EPlatForm:GetMacthState() == EPlatForm.DEF_STATE_CLOSE then
		return 0, "本届活动暂时未开放, 请留意相关信息。";		
	end	
	
	if EPlatForm:GetMacthState() == EPlatForm.DEF_STATE_REST then
		return 0, "现在是活动间歇期！";
	end
	
	if (me.nLevel < tbMacthCfg.nMinLevel) then
		return 0, string.format("你的修为不足，%d级以后我一定带你去哦！", tbMacthCfg.nMinLevel);
	end
	
	if (me.IsFreshPlayer() == 1) then
		return 0, "你目前尚未加入门派，武艺不精，还是等加入门派后再来把！";
	end

	if (tbMacthCfg.nBagNeedFree and tbMacthCfg.nBagNeedFree > 0) then
		if (me.CountFreeBagCell() < tbMacthCfg.nBagNeedFree) then
			return 0, string.format("Hành trang không đủ chỗ trống%s，不能进去！", tbMacthCfg.nBagNeedFree);
		end
	end	
	
	local nMatchState = EPlatForm:GetMacthState();

	local nTime = GetTime();
	local nWeek = tonumber(os.date("%w", nTime));
	local nHourMin = tonumber(os.date("%H%M", nTime));
	local nDay = tonumber(os.date("%d", nTime));
	
	if (nMatchState == EPlatForm.DEF_STATE_MATCH_2 or nMatchState == EPlatForm.DEF_STATE_ADVMATCH) then
		local szLeagueName = League:GetMemberLeague(EPlatForm.LGTYPE, me.szName);
		if not szLeagueName then
			return 0, "你没有资格参加比赛哦，需要建立了战队才行啊。";
		end
		if League:GetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_MSESSION) ~= EPlatForm:GetMacthSession() then
			return 0, "您的战队不是本次活动建立的战队，不符合要求！";
		end
	
		local nFlag = League:GetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_MTYPE);
		if (nMatchState == EPlatForm.DEF_STATE_MATCH_2 and 0 == nFlag) then
			return 2;
		end

		--八强赛
		if nMatchState == EPlatForm.DEF_STATE_ADVMATCH then			
			if EPlatForm.AdvMatchState == 0 then
				return 0, "现在是家族活动决赛期，第一场八强赛将在<color=yellow>21:30<color>开启，请耐心等待！\n\n<color=yellow>你可以在准备场和比赛场内按～键查看赛况<color>";			
			end
			
			if EPlatForm:IsAdvMacthLeague(szLeagueName) ~= 1 then
				return 0, "会场官员：您不是本场家族活动决赛期的战队，无法参加本场决赛期的比赛。\n\n<color=yellow>你可以在准备场和比赛场内按～键查看赛况<color>";
			end
			
			if me.GetEquip(Item.EQUIPPOS_MASK) then
				return 0, string.format("%s不允许戴面具参加，请把面具摘下再来找我吧。", tbMacth.szName);
			end				
			
			if EPlatForm.ReadyTimerId > 0 then
				local nRestTime = math.floor(Timer:GetRestTime(EPlatForm.ReadyTimerId)/Env.GAME_FPS);
				if nRestTime >= EPlatForm.MACTH_TIME_READY_LASTENTER/Env.GAME_FPS then
					return 1, string.format("比赛正在报名阶段，等待您的报名。\n\n离比赛开始还剩余<color=yellow>%s<color>，请尽快报名参赛。\n\n<color=yellow>你可以在准备场和比赛场内按～键查看赛况<color>", Lib:TimeFullDesc(nRestTime));
				end
			end

			if nHourMin > EPlatForm.CALEMDAR.tbAdvMatch[#EPlatForm.CALEMDAR.tbAdvMatch] then
				return 0, "本届家族活动已经完满结束！";
			end
			for nId, nMatchTime in pairs(EPlatForm.CALEMDAR.tbAdvMatch) do
				if nHourMin < nMatchTime then
					return 0, string.format("下场是活动比赛。\n\n比赛类型是<color=yellow>%s强赛<color>\n\n比赛将在<color=yellow>%s<color>开始！\n\n<color=yellow>你可以在准备场和比赛场内按～键查看赛况<color>", EPlatForm.MACTH_STATE_ADV_TASK[nId], EPlatForm.Fun:Number2Time(nMatchTime));				
				end
			end
			return 0, "请稍等，比赛马上就要开始！\n\n<color=yellow>你可以在准备场和比赛场内按～键查看赛况<color>";
		end

		if (nMatchState == EPlatForm.DEF_STATE_MATCH_2) then
			EPlatForm:UpdateTeamDailyEventCount(szLeagueName);
			local nCount = EPlatForm:GetTeamEventCount(szLeagueName);
			if (nCount <= 0) then
				return 0, string.format("您的战队今天已经参加多次<color=yellow>%s<color>活动了，回去休息下明天再来吧。", tbMacth.szName);
			end
		end		
	elseif (nMatchState == EPlatForm.DEF_STATE_MATCH_1) then
		EPlatForm:UpdatePlayerDailyEventCount(me);
		local nCount = EPlatForm:GetPlayerEventCount(me);
		local nTotalCount = EPlatForm:GetPlayerTotalCount(me);
		if (nTotalCount >= EPlatForm.DEF_MAX_TOTALCOUNT) then
			return 0, string.format("您已经完成了家族选拔赛的所有%d场比赛！", EPlatForm.DEF_MAX_TOTALCOUNT);
		end
		
		if (nCount <= 0) then
			return 0, string.format("您今天已经参加多次<color=yellow>%s<color>活动了，回去休息下明天再来吧。", tbMacth.szName);
		end
	end

	if me.GetEquip(Item.EQUIPPOS_MASK) then
		return 0, string.format("%s不允许戴面具参加，请把面具摘下再来找我吧。", tbMacth.szName);
	end	
	
	if EPlatForm.ReadyTimerId > 0 then
		local nRestTime = math.floor(Timer:GetRestTime(EPlatForm.ReadyTimerId)/Env.GAME_FPS);
		if nRestTime >= EPlatForm.MACTH_TIME_READY_LASTENTER/Env.GAME_FPS then
			return 1, string.format("比赛正在报名阶段，等待您的报名。\n\n离比赛开始还剩余<color=yellow>%s<color>，请尽快报名参赛。", Lib:TimeFullDesc(nRestTime));
		end
	end

	local tbCalemdar = EPlatForm.CALEMDAR.tbCommon;
	
	if (nMatchState > EPlatForm.DEF_STATE_MATCH_1) then
		tbCalemdar = EPlatForm.CALEMDAR.tbCommon_Adv;
	end
	
	if (nMatchState == EPlatForm.DEF_STATE_ADVMATCH) then
		tbCalemdar = EPlatForm.CALEMDAR.tbAdvMatch;
	end
	
	local szGameStart = tbMacth.szSignNpcName;
	local nFlag		  = 0;
	for nReadyId, tbMissions in pairs(EPlatForm.MissionList) do
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
		szGameStart = szGameStart .. "比赛已经开始了！\n\n";
	end
	
	if EPlatForm:GetMatchEndForDate(nDay) == 1 and nMatchState == EPlatForm.DEF_STATE_MATCH_2 and nHourMin > tbCalemdar[#tbCalemdar] then
		return 0, string.format("%s本届家族预选赛活动场次已全部举行完，将会进入八强赛期！", szGameStart);
	end
	
	if nHourMin > tbCalemdar[#tbCalemdar] then
		return 0, string.format("%s今天的家族活动场次已全部结束，请明天再来参赛！", szGameStart);
	end	
	if nHourMin < tbCalemdar[1] then
		return 0, string.format("%s下场比赛的时间为<color=yellow>%s<color>！", szGameStart, EPlatForm.Fun:Number2Time(tbCalemdar[1]));
	end
	for nId, nMatchTime in ipairs(tbCalemdar) do
		if nHourMin > nMatchTime and tbCalemdar[nId+1] and nHourMin <= tbCalemdar[nId+1] then
			return 0, string.format("%s下场比赛的时间为<color=yellow>%s<color>！", szGameStart, EPlatForm.Fun:Number2Time(tbCalemdar[nId+1]));
		end
	end
	return 0, "请稍等，比赛马上就要开始！";
end

function tbNpc:QueryMatch()
	local nState = EPlatForm:GetMacthState();
	
	local nPlayerMonthScore	= EPlatForm:GetPlayerMonthScore(me.szName);
	local nKinScore			= EPlatForm:GetPlatformKinScore(me.nId);
	local nPlayerScore		= EPlatForm:GetHonor(me.szName);
	
	local szMsg = string.format([[个人本月获得积分：    <color=yellow>%d<color>
个人总积分：          <color=green>%d<color>
家族本月积分：        <color=red>%d<color>

]], nPlayerMonthScore, nPlayerScore, nKinScore);
	
	if (nState ~= EPlatForm.DEF_STATE_MATCH_1) then
		local szLeagueName = League:GetMemberLeague(EPlatForm.LGTYPE, me.szName);
		if szLeagueName then
			local tbLeagueList = EPlatForm:GetLeagueMemberList(szLeagueName);
			local szMemberMsg = self:GetLeagueInfoMsg(szLeagueName);
			local nMSession = League:GetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_MSESSION);
			local nMType = League:GetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_MTYPE);
			local nRank = League:GetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_RANK);
			local nWin = League:GetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_WIN);
			local nTie = League:GetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_TIE);
			local nTotal = League:GetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_TOTAL);
			local nRankAdv	= League:GetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_RANK_ADV);
			local nLoss = nTotal-nWin-nTie;
			if (nMType <= 0 and szMemberMsg) then
				Dialog:Say(string.format("%s\n%s", szMsg, szMemberMsg));
				return 0;
			end
			local tbMfg = EPlatForm:GetMacthTypeCfg(nMType);
			if (not tbMfg) then
				Dialog:Say("活动未开启");
				return 0;
			end
			local szMacthName = EPlatForm:GetMacthTypeCfg(nMType).szName;
			local nPoint = nWin * EPlatForm.MACTH_POINT_WIN + nTie * EPlatForm.MACTH_POINT_TIE + nLoss * EPlatForm.MACTH_POINT_LOSS;
			local szRate = 100.00;
			if nTotal > 0 then
				szRate = string.format("%.2f", (nWin/nTotal)*100) .. "％";
			else
				szRate = "Vô";
			end
			local szRank = "";
			if nRank > 0 then
				szRank = string.format("\n战队排名：<color=white>%s<color>", nRank);
			end
			local tbAdvMsg = {
				[0] = "无八强赛资格",
				[1]	= "冠军",
				[2]	= "进入决赛",
				[4] = "进入四强赛",
				[8] = "进入八强赛",
			};
			if (tbAdvMsg[nRankAdv]) then
				szRank = szRank .. string.format("\n\n战队八强赛情况：<color=white>%s<color>", tbAdvMsg[nRankAdv]);
			end

			
			szMemberMsg = string.format([[%s<color=green>
		--战队战绩--
活动届数：<color=white>第%s届<color> 
参加比赛：<color=white>%s<color> 
总 场 数：<color=white>%s<color> 
胜    率：<color=white>%s<color>
总 积 分：<color=white>%s<color>
胜：<color=white>%s<color>  平：<color=white>%s<color>  负：<color=white>%s <color>		
%s

<color=red>八强赛名单在%d号0点更新<color>
		]],szMemberMsg, Lib:Transfer4LenDigit2CnNum(nMSession), szMacthName, nTotal, szRate, nPoint, nWin, nTie, nLoss, szRank, EPlatForm.DATE_START_DAY[1][4]);
			szMsg = string.format("%s\n%s\n", szMsg, szMemberMsg);
		end
	end
	Dialog:Say(szMsg);		
end

function tbNpc:GetLeagueInfoMsg(szLeagueName)
	local tbLeagueList = EPlatForm:GetLeagueMemberList(szLeagueName);
	local szMemberMsg = string.format("所在战队：<color=yellow>%s<color>\n", szLeagueName);
	for nId, szMemberName in ipairs(tbLeagueList) do
		if nId == 1 then
			szMemberMsg = string.format("%s战队队长：<color=yellow>%s<color>\n", szMemberMsg, szMemberName);
			
			if #tbLeagueList > 1 then
				szMemberMsg = string.format("%s战队队员：", szMemberMsg);
			else
				szMemberMsg = string.format("%s<color=gray>无战队队员<color>\n", szMemberMsg);
			end 
		else
			szMemberMsg = string.format("%s<color=yellow>%s<color>", szMemberMsg, szMemberName);
			if nId < #tbLeagueList then
				szMemberMsg = string.format("%s，", szMemberMsg);
			end
		end
	end
	return 	szMemberMsg;
end

