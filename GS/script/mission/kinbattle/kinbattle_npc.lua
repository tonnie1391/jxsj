-------------------------------------------------------
-- 文件名　：kinbattle_npc.lua
-- 创建者　：huangxiaoming
-- 创建时间：2010-12-7 10:15:46
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return 0;
end

Require("\\script\\mission\\kinbattle\\kinbattle_def.lua");

local tbNpc = KinBattle.Npc or {};
KinBattle.Npc = tbNpc;

function tbNpc:OnDialogField()
	if KinBattle.OPEN_STATE ~= 1 then
		Dialog:Say("家族战场暂未开放！");
		return 0;
	end
	local szMsg = "   近日，我这里可以为各大家族提供互相竞技的PK场所。\n   双方各给我<color=yellow>20万家族资金<color>我就为你们开启场地，不过，<color=yellow>双方必须都有人到场，且至少共20人参战<color>，否则场地无法开启。预定成功之后不管是否开启将不会退还家族资金。";
	local tbOpt = {};
	local nCaptain = KinBattle:CheckKinCaptain(me);
	if nCaptain == 1 then
		table.insert(tbOpt, {"预订战场", self.ReserveMatch, self});
	end
	if KinBattle:CheckJoin(me) == 0 then
		table.insert(tbOpt, {"<color=gray>进入战场<color>", self.JoinMatch, self});
	else
		table.insert(tbOpt, {"进入战场", self.JoinMatch, self});
	end
	table.insert(tbOpt, {"观看家族战", KinBattle.OnLookDialog, KinBattle});
	table.insert(tbOpt, {"个人战绩", self.QueryResult, self});
	table.insert(tbOpt, {"Kết thúc đối thoại"});
	Dialog:Say(szMsg, tbOpt);
end


function tbNpc:ReserveMatch(nMapType, nTimeIndex, nLookMode, nConfirm)
	local tbMemberList, nMemberCount = me.GetTeamMemberList();
	if not tbMemberList or nMemberCount ~= 2 then
		Dialog:Say("请双方<color=yellow>族长组队<color>来预订家族战场地。\n" .. KinBattle.BAOMING_INFO);
		return 0;
	end
	if me.IsCaptain() ~= 1 then
		Dialog:Say("让你们<color=yellow>队长<color>跟我谈吧。\n" .. KinBattle.BAOMING_INFO);
		return 0;
	end
	local pTeamMate = nil;
	for _, pMember in pairs(tbMemberList) do
		if pMember.szName ~= me.szName then
			pTeamMate = pMember;
		end
	end
	if not pTeamMate then
		return 0;
	end
	if pTeamMate.nMapId ~= me.nMapId then
		Dialog:Say("双方族长必须在同一地图！\n".. KinBattle.BAOMING_INFO);
		return 0;
	end
	local nCaptain, nKinId, nMemberId = KinBattle:CheckKinCaptain(me);
	local nCaptainMate, nKinIdMate, nMemberIdMate = KinBattle:CheckKinCaptain(pTeamMate);
	if nCaptain ~= 1 or nCaptainMate ~= 1 then
		Dialog:Say("请双方<color=yellow>族长组队<color>来预订家族战场地。请确保族长账号已解锁！\n" .. KinBattle.BAOMING_INFO);
		return 0;
	end
	local nMissionId = KinBattle:FindMissionId(nKinId, nKinIdMate);
	if nMissionId > 0 then
		Dialog:Say("无法预定，队伍中有家族正在进行家族战！\n" .. KinBattle.BAOMING_INFO);
		return 0;
	end
	if not nMapType then
		local szMsg = "<color=yellow>请选择家族战地图。<color>";
		local tbOpt = {};
		for i = 1, #KinBattle.MAP_TYPE_DEC do
			local tbTemp = nil;
			if not KinBattle.MAP_TYPE_COUNT[i] or KinBattle.MAP_TYPE_COUNT[i] == 0 then
				tbTemp = {string.format("<color=gray>%s<color>", KinBattle.MAP_TYPE_DEC[i][1] .. KinBattle.MAP_TYPE_DEC[i][2]), self.ReserveMatch, self, i};
			else
				tbTemp = {KinBattle.MAP_TYPE_DEC[i][1] .. KinBattle.MAP_TYPE_DEC[i][2], self.ReserveMatch, self, i};
			end
			table.insert(tbOpt, tbTemp);
		end
		table.insert(tbOpt, {"我还是再想想吧"});
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	if not KinBattle.MAP_TYPE_COUNT or KinBattle.MAP_TYPE_COUNT[nMapType] == 0 then
		Dialog:Say("该地图还未开放，敬请期待！");
		return 0;
	end
	local nMapIndex = KinBattle:CheckHaveFreeBattle(nMapType)
	if nMapIndex <= 0 then
		Dialog:Say("对不起，所有的家族战场地都已经被预订，请稍后再来预定。");
		return 0;
	end
	if not nTimeIndex then
		local szMsg = "<color=yellow>请选择家族战持续时间。<color>";
		local tbOpt = {};
		for i = 1, #KinBattle.TIMER_GAME_DEC do
			local tbTemp = {KinBattle.TIMER_GAME_DEC[i], self.ReserveMatch, self, nMapType, i};
			table.insert(tbOpt, tbTemp);
		end
		table.insert(tbOpt, {"我还是再想想吧"});
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	if not nLookMode then
		local szMsg = string.format("<color=yellow>是否允许其他玩家前来观战？<color>\n1、最多%s人；\n2、参战家族成员不可观战。\n", KinBattle.MAX_LOOKER_COUNT);
		local tbOpt = 
		{
			{"允许观战", self.ReserveMatch, self, nMapType, nTimeIndex, 1},
			{"禁止观战", self.ReserveMatch, self, nMapType, nTimeIndex, 2},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	local cKin = KKin.GetKin(nKinId);
	local cKinMate = KKin.GetKin(nKinIdMate);
	if not cKinMate or not cKin then
		return 0;
	end
	local szKinNameMate = cKinMate.GetName();
	local szKinName = cKin.GetName();
	local nCheckResult = KinBattle:CheckHaveEnoughMoney(nKinId, nKinIdMate);
	if nCheckResult > 0 then
		if not nConfirm then		
			local szMsg = string.format("<color=green>%s<color> VS <color=green>%s<color>\n对战地图：<color=green>%s<color>\n对战时间：<color=green>%s<color>\n其他人员：<color=green>%s<color>\n\n<color=red>请注意：<color>\n1、两个家族均需扣除<color=yellow>20万家族资金<color>；\n2、战斗开启时，准备场中必须至少有<color=yellow>20人到场，且双方都有人到场<color>；\n3、预定成功之后不管是否开启将不会退还家族资金。\n\n确定预定？",szKinName, szKinNameMate, KinBattle.MAP_TYPE_DEC[nMapType][1], KinBattle.TIMER_GAME_DEC[nTimeIndex], KinBattle.LOOKER_MODE_DEC[nLookMode]);
			local tbOpt =
			{
				{"确认", self.ReserveMatch, self, nMapType, nTimeIndex, nLookMode, 1},
				{"我还是再想想吧"},
			};
			Dialog:Say(szMsg, tbOpt);
			return 0;
		end
		if nConfirm == 1 and not nRespond then
			local szMsg = string.format("<color=green>%s<color>家族申请与您的家族对战。\n对战地图：<color=green>%s<color>\n对战时间：<color=green>%s<color>\n其他人员：<color=green>%s<color>\n\n<color=red>请注意：<color>\n1、两个家族均需扣除<color=yellow>20万家族资金<color>；\n2、战斗开启时，准备场中必须至少有<color=yellow>20人到场，且双方都有人到场<color>；\n3、预定成功之后不管是否开启将不会退还家族资金。\n\n确定参加？",  szKinName, KinBattle.MAP_TYPE_DEC[nMapType][1], KinBattle.TIMER_GAME_DEC[nTimeIndex], KinBattle.LOOKER_MODE_DEC[nLookMode]);
			local tbOpt =
			{
				{"同意", self.ConfirmMatch, self, 1, nMapType, nTimeIndex, nLookMode, nConfirm},
				{"拒绝",  self.ConfirmMatch, self, 0},
			};
			Setting:SetGlobalObj(pTeamMate);
			Dialog:Say(szMsg,tbOpt)
			Setting:RestoreGlobalObj();
			return 0;
		end
		if nCheckResult > 0 then
			GCExcute{"KinBattle:ReserveMatch_GC", pTeamMate.nId, nKinIdMate, nMemberIdMate, me.nId, nKinId, nMemberId,  nTimeIndex, nMapType, nLookMode};
		end
	end
	if nCheckResult == -1 then
		Dialog:Say("对不起，队伍中家族资金正在使用中，请先处理所有家族资金请求。");
	end
	if nCheckResult == -2 then
		Dialog:Say("对不起,请确认双方家族有足够的家族资金，开启家族战需要消耗双方家族各<color=yellow>20万家族资金<color>。");
	end
end

function tbNpc:ConfirmMatch(nRespond, nMapType, nTimeIndex, nLookMode, nConfirm)
	local tbMemberList, nMemberCount = me.GetTeamMemberList();
	if not tbMemberList or nMemberCount ~= 2 then
		return 0;
	end
	if not tbMemberList or nMemberCount ~= 2 then
		return 0;
	end
	if me.IsCaptain() == 1 then
		return 0;
	end
	local pTeamMate = nil;
	for _, pMember in pairs(tbMemberList) do
		if pMember.szName ~= me.szName then
			pTeamMate = pMember;
		end
	end
	if not pTeamMate then
		return 0;
	end
	if pTeamMate.nMapId ~= me.nMapId then
		return 0;
	end
	if not nRespond or nRespond ~= 1 then
		pTeamMate.Msg("对方拒绝了您的请求!");
		return 0;
	end
	local nCaptain, nKinId, nMemberId = KinBattle:CheckKinCaptain(me);
	local nCaptainMate, nKinIdMate, nMemberIdMate = KinBattle:CheckKinCaptain(pTeamMate);
	if nCaptain ~= 1 or nCaptainMate ~= 1 then
		return 0;
	end
	local nMissionId = KinBattle:FindMissionId(nKinId, nKinIdMate);
	if nMissionId > 0 then
		return 0;
	end
	if not nMapType then
		return 0;
	end
	if nMapType ~= 1 then
		return 0;
	end
	local nMapIndex = KinBattle:CheckHaveFreeBattle(nMapType)
	if nMapIndex == -1 then
		return 0;
	end
	if not nTimeIndex then
		return 0;
	end
	local nCheckResult = KinBattle:CheckHaveEnoughMoney(nKinId, nKinIdMate);
	if nCheckResult > 0 then
		return GCExcute{"KinBattle:ReserveMatch_GC", pTeamMate.nId, nKinIdMate, nMemberIdMate, me.nId, nKinId, nMemberId,  nTimeIndex, nMapType, nLookMode};
	end
end

function tbNpc:JoinMatch()
	local nKinId, nMemberId = me.GetKinMember();
	if nKinId == 0 or nMemberId == 0 then
		Dialog:Say("你还没有家族，也想来参战？");
		return 0;
	end
	local nMapIndex, nCampIndex = KinBattle:FindMissionId(nKinId);
	if nMapIndex == -1 then
		Dialog:Say("你的家族未开启家族战！");
		return 0;
	end
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	local cMember = cKin.GetMember(nMemberId)
	if not cMember then
		return 0;
	end
	if cMember.GetFigure() == Kin.FIGURE_SIGNED then
		Dialog:Say("记名成员无法参加！");
		return 0;
	end
	me.NewWorld(KinBattle.MAP_LIST[nMapIndex][nCampIndex + 1], KinBattle.PREPARE_POS[1], KinBattle.PREPARE_POS[2]);
end

function tbNpc:QueryResult()
	local nKinMatchTimes = 0;
	local nKinId, nMemberId = me.GetKinMember();
	local cKin = KKin.GetKin(nKinId);
	if cKin then
		nKinMatchTimes = cKin.GetBattleCount();
	end
	local nMatchTimes = me.GetTask(KinBattle.TASK_GROUP_ID, KinBattle.TASK_MATCH_COUNT);
	local nKillTimes = me.GetTask(KinBattle.TASK_GROUP_ID, KinBattle.TASK_KILL);
	local nMaxSeries = me.GetTask(KinBattle.TASK_GROUP_ID, KinBattle.TASK_MAX_SERIES);
	local nMaxKillTimes = me.GetTask(KinBattle.TASK_GROUP_ID, KinBattle.TASK_MAX_KILL);
	local nLastKillTimes = me.GetTask(KinBattle.TASK_GROUP_ID, KinBattle.TASK_LAST_KILL);
	local nLastMaxSeries = me.GetTask(KinBattle.TASK_GROUP_ID, KinBattle.TASK_LAST_MAXSERIES);
	local szLastMaxKillTitle = "Vô";
	local szLastMaxSeriesTitle = "Vô";
	local szMaxKillTitle = "Vô";
	local szMaxSeriesTitle = "Vô";
	local nLastMaxKillLevel = 0;
	local nLastMaxSeriesLevel = 0;
	local nMaxKillLevel = 0;
	local nMaxSeriesLevel = 0;
	for i = #KinBattle.SPECIAL_TITLE[2], 1, -1 do
		if nLastMaxKillLevel == 0 and nLastKillTimes >= KinBattle.SPECIAL_TITLE[2][i].nLimit then
			szLastMaxKillTitle = KinBattle.SPECIAL_TITLE[2][i].szTitle;
			nLastMaxKillLevel = i;
		end
		if nMaxKillLevel == 0 and nMaxKillTimes >= KinBattle.SPECIAL_TITLE[2][i].nLimit then
			szMaxKillTitle = KinBattle.SPECIAL_TITLE[2][i].szTitle;
			nMaxKillLevel = i;
		end
	end
	for i = #KinBattle.SPECIAL_TITLE[1], 1, -1 do
		if nLastMaxSeriesLevel == 0 and nLastMaxSeries >= KinBattle.SPECIAL_TITLE[1][i].nLimit then
			szLastMaxSeriesTitle = KinBattle.SPECIAL_TITLE[1][i].szTitle;
			nLastMaxSeriesLevel = i;
		end
		if nMaxSeriesLevel == 0 and nMaxSeries >= KinBattle.SPECIAL_TITLE[1][i].nLimit then
			szMaxSeriesTitle = KinBattle.SPECIAL_TITLE[1][i].szTitle;
			nMaxSeriesLevel = i;
		end
	end
	local szMsg = string.format([[<color=green>
		------<color=yellow>上场战绩<color>------
		
		杀人：<color=white>%s<color>  称号：<color=white>%s<color>
		连斩：<color=white>%s<color>  称号：<color=white>%s<color>
		
		-------<color=yellow>总战绩<color>-------
		
		家族开战：<color=white>%s<color>
		个人参战：<color=white>%s<color>
		总杀人数：<color=white>%s<color>
		单场杀人：<color=white>%s<color>  称号：<color=white>%s<color>
		单场连斩：<color=white>%s<color>  称号：<color=white>%s<color>
		]], 
	Lib:StrFillL(nLastKillTimes, 3), szLastMaxKillTitle, Lib:StrFillL(nLastMaxSeries, 3), szLastMaxSeriesTitle, 
	nKinMatchTimes, nMatchTimes, nKillTimes, Lib:StrFillL(nMaxKillTimes, 3), szMaxKillTitle, Lib:StrFillL(nMaxSeries, 3), szMaxSeriesTitle);
	Dialog:Say(szMsg);
end
