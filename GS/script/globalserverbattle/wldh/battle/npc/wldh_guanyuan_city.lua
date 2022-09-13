-------------------------------------------------------
-- 文件名　：wldh_guanyuan_city.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-09-02 11:15:59
-- 文件描述：
-------------------------------------------------------

Require("\\script\\globalserverbattle\\wldh\\battle\\wldh_battle_def.lua");

-- 临安武林大会官员
local tbNpc = Npc:GetClass("wldh_guanyuan_city");

function tbNpc:OnDialog()
	
	if (IVER_g_nSdoVersion == 1) then
		local szMsg = "您好！我能为你做些什么吗？您可在这儿换取120级马，购买跨服联赛声望装备。";
		local tbOpt = {};
		local tbGbWllsNpc = Npc:GetClass("gbwlls_guanyuan1");
		if (tbGbWllsNpc) then
			tbOpt[#tbOpt + 1] = {"雕像相关", tbGbWllsNpc.OnAboutStatuary, tbGbWllsNpc};
			tbOpt[#tbOpt + 1] = {"跨服联赛声望装备相关", tbGbWllsNpc.OnAboutGbWllsRepute, tbGbWllsNpc};
		end
		table.insert(tbOpt, {"Ta hiểu rồi"});
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	

	local szMsg = "太遗憾了！你没有获得武林大会的参赛许可，不能前往赛场。";
	local tbOpt = {
		{"<color=green>购买武林大会戒指<color>", self.OpenShop, self},
		{"查询武林大会专用绑银", self.AskForCurrencyMoney, self},
		};
		
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	
	if (Wldh:CheckIsOpen() == 1) then
		-- 资格判定	
		if Wldh.Qualification:CheckMember(me) > 0 then
			
			szMsg = "恭喜你获得参加武林大会的资格！";
			table.insert(tbOpt, 1, {"前往武林大会赛场", self.TransToServer, self});
			if nCurDate >= Wldh.STATE3_DATE[1] and nCurDate <= Wldh.STATE3_DATE[2] then
				table.insert(tbOpt, 2, {"领取小型赛决赛奖励",self.GetMiniFinalAward, self});
			end
			if nCurDate >= Wldh.STATE5_DATE[1] and nCurDate <= Wldh.STATE5_DATE[2] then
				table.insert(tbOpt, 2, {"领取团体赛决赛奖励",self.GetTeamFinalAward, self});
			end
			if nCurDate >= Wldh.STATE4_DATE[1] and nCurDate <= Wldh.STATE4_DATE[2] then
				table.insert(tbOpt, 2, {"团体赛奖励补领",self.GetTeamExtraAward, self});	
			end
		end
		
		if nCurDate >= Wldh.STATE4_DATE[1] and nCurDate <= Wldh.STATE4_DATE[2] then
			table.insert(tbOpt, 2, {"领取团体赛区服奖励", self.GetServerAward, self});
		end
	end

	table.insert(tbOpt, {"Ta hiểu rồi"});
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:OpenShop()
	me.OpenShop(163, 1);
end

function tbNpc:GetMiniFinalAward()
	local szMsg = "我这里可以领取小型赛决赛胜利奖励。";
	local tbOpt = {
		{"门派单人赛", self.OnGetMiniFinalAward, self, 1},
		{"双人赛", self.OnGetMiniFinalAward, self, 2},
		{"三人赛", self.OnGetMiniFinalAward, self, 3},
		{"五行五人赛", self.OnGetMiniFinalAward, self, 4},
		{"考虑一下"},
	};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:OnGetMiniFinalAward(nType, nSure)

	local nWinCount 	= GetPlayerSportTask(me.nId, Wldh.GBTASKID_GROUP, Wldh.GBTASKID_FINAL_ID[nType]) or 0;
	local nAttendTotle	= GetPlayerSportTask(me.nId, Wldh.GBTASKID_GROUP, Wldh.GBTASKID_ATTEND_ID[nType]) or 0;
	local nFaction		= GetPlayerSportTask(me.nId, Wldh.GBTASKID_GROUP, Wldh.GBTASKID_FACTION_ID) or 0;
	local nGetCount 	= me.GetTask(Wldh.TASKID_GROUP, Wldh.TASKID_Award[nType][2]);

	if nGetCount > 0 then
		Dialog:Say("你已经领取本类型最终奖励了");
		return 0;
	end
	local tbAward = Wldh:GetFinalAwardTable(nType, nWinCount, nAttendTotle);
	if not tbAward then
		Dialog:Say("你本类型比赛没有任何奖励可领取。");
		return 0;
	end
	if not nSure then
		local szMsg = string.format("你本类型比较中最终获得了<color=yellow>第%s名<color>的好成绩，参加总场数为<color=yellow>%s场<color>，你确定要领取最终奖励吗？", nWinCount, nAttendTotle);
		local tbOpt = {
			{"确定领取", self.OnGetMiniFinalAward, self, nType, 1},
			{"考虑一下"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	
	if tbAward.tbAward and tbAward.tbAward.nNeedBag and me.CountFreeBagCell() < tbAward.tbAward.nNeedBag then
		Dialog:Say(string.format("你的背包空间不足，需要%s格背包空间。", tbAward.tbAward.nNeedBag));
		return 0;
	end	
	me.SetTask(Wldh.TASKID_GROUP, Wldh.TASKID_Award[nType][2], nWinCount);
	if tbAward.nHonor then
		Wlls:AddHonor(me.szName, tbAward.nHonor);
	end
	if tbAward.tbAward then
		if tbAward.tbAward.item then
			for _, tbItem in pairs(tbAward.tbAward.item) do
				local nAddCount = me.AddStackItem(tbItem[1][1], tbItem[1][2], tbItem[1][3], tbItem[1][4], {bForceBind=tbItem[3]}, tbItem[2]);	
				if nAddCount > 0 then
					--
				end
			end
		end
		if tbAward.tbAward.title then
			me.AddTitle(unpack(tbAward.tbAward.title));
			me.SetCurTitle(unpack(tbAward.tbAward.title));
		end
		if tbAward.tbAward.factiontitle and nFaction > 0 then
			local nGenre = tbAward.tbAward.factiontitle[1];
			local nDetail = tbAward.tbAward.factiontitle[2];
			local nLevel = Wldh.AWARD_FINISH_TITLE_LIST[nFaction][tbAward.tbAward.factiontitle[3]];
			me.AddTitle(nGenre, nDetail, nLevel, 0);
			me.SetCurTitle(nGenre, nDetail, nLevel, 0);
		end
	end
	
	-- 打满24场，江湖威望150
	if nAttendTotle >= 24 then
		me.AddKinReputeEntry(150);
	end
	
	local szLog = string.format("【领取小型赛最终奖励】类型：%s, 排名：%s, 场次:%s", nType, nWinCount, nAttendTotle);
	Wldh:WriteLog(szLog, me.nId);
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, szLog);
	
	-- 公告提示
	local nGateWay = Transfer:GetTransferGateway();
	local szServerName = Wldh.Battle.tbLeagueName[nGateWay][1];
	
	local szAnncone = string.format("<color=green>%s玩家：%s<color>在武林大会%s中获得了<color=red>第%s名<color>的好成绩！！！", szServerName, me.szName, Wldh.LADDER_ID[nType][1], nWinCount);
	local szKinOrTong = string.format("在武林大会%s中获得了<color=red>第%s名<color>的好成绩。", Wldh.LADDER_ID[nType][1], nWinCount);
	local szFriend = string.format("Hảo hữu [<color=green>%s<color>]在武林大会%s中获得了<color=red>第%s名<color>的好成绩。", me.szName, Wldh.LADDER_ID[nType][1], nWinCount);
	
	-- 前4名
	if nWinCount <= 4 then
		GCExcute({"Wldh:Gc_Anncone", szAnncone});
		Player:SendMsgToKinOrTong(me, szKinOrTong, 1);
	
	-- 前8名
	elseif nWinCount <= 8 then
		KDialog.NewsMsg(1, Env.NEWSMSG_NORMAL, szAnncone);
		Player:SendMsgToKinOrTong(me, szKinOrTong, 1);
	
	-- 前32名
	else
		Player:SendMsgToKinOrTong(me, szKinOrTong, 0);
	end
	
	-- 好友公告
	me.SendMsgToFriend(szFriend);
	
	Dialog:Say("成功领取了奖励。");
end

-- 团体赛决赛奖励
function tbNpc:GetTeamFinalAward(nSure)

	local nAttend = GetPlayerSportTask(me.nId, Wldh.GBTASKID_GROUP, Wldh.GBTASKID_BATTLE_ATTEND_ID) or 0;
	local nRank = GetPlayerSportTask(me.nId, Wldh.GBTASKID_GROUP, Wldh.GBTASKID_BATTLE_RANK_ID) or 0;
	
	local tbAward = nil;
	
	-- 前4名
	if nRank >= 1 and nRank <= 4 then
		if Wldh.Qualification:CheckMember(me) == 2 then
			tbAward = Wldh.Battle.tbAward[nRank].Captain;
		elseif Wldh.Qualification:CheckMember(me) == 1 then
			tbAward = Wldh.Battle.tbAward[nRank].Member;
		end
	elseif nAttend >= Wldh.Battle.MAX_MATCH then
	
		if Wldh.Qualification:CheckMember(me) == 2 then
			tbAward = Wldh.Battle.tbAward.Normal.Captain;
		elseif Wldh.Qualification:CheckMember(me) == 1 then
			tbAward = Wldh.Battle.tbAward.Normal.Member;
		end
	end
	
	if not tbAward then
		Dialog:Say("对不起，你所在的战队没有奖励可以领取。");
		return 0;
	end

	if not nSure then
		local szMsg = string.format("这里可以领取团体赛最终奖励，你确定要领取吗？");
		local tbOpt = {
			{"确定领取", self.GetTeamFinalAward, self, 1},
			{"考虑一下"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	
	local nAward = me.GetTask(Wldh.Battle.TASK_GROUP_ID, Wldh.Battle.TASKID_AWARD);
	if nAward > 0 then
		Dialog:Say("你已经领取了团体赛奖励，不能再领了。");
		return 0;
	end
	
	if tbAward.nNeedBag and me.CountFreeBagCell() < tbAward.nNeedBag then
		Dialog:Say(string.format("你的背包空间不足，需要%s格背包空间。", tbAward.nNeedBag));
		return 0;
	end	

	me.SetTask(Wldh.Battle.TASK_GROUP_ID, Wldh.Battle.TASKID_AWARD, 1);
	me.AddStackItem(tbAward.Item[1], tbAward.Item[2], tbAward.Item[3], tbAward.Item[4], {bForceBind=1}, tbAward.Num);
	
	-- 称号
	if tbAward.Title then
		me.AddTitle(tbAward.Title[1], tbAward.Title[2], tbAward.Title[3], tbAward.Title[4]);
		me.SetCurTitle(tbAward.Title[1], tbAward.Title[2], tbAward.Title[3], tbAward.Title[4]);
	end
	local szLog = string.format("【领取团体赛最终奖励】排名：%s, 场次:%s, 资格类型:%s", nRank, nAttend, Wldh.Qualification:CheckMember(me) or 0);
	Wldh:WriteLog(szLog, me.nId);
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, szLog);	
	Dialog:Say("成功领取了奖励。");
end

-- 团体赛奖励补领
function tbNpc:GetTeamExtraAward(nSure)
	
	local tbAward = nil;
	
	if Wldh.Qualification:CheckMember(me) == 2 then
		tbAward = Wldh.Battle.tbAward.Normal.Captain;
	elseif Wldh.Qualification:CheckMember(me) == 1 then
		tbAward = Wldh.Battle.tbAward.Normal.Member;
	end
	
	if not tbAward then
		Dialog:Say("对不起，你所在的战队没有奖励可以领取。");
		return 0;
	end

	local nAward = me.GetTask(Wldh.Battle.TASK_GROUP_ID, Wldh.Battle.TASKID_AWARD);
	if nAward > 0 then
		Dialog:Say("你已经领取了团体赛奖励，不能再领了。");
		return 0;
	end
	
	if not nSure then
		local szMsg = string.format("这里可以领取团体赛最终奖励，你确定要领取吗？");
		local tbOpt = {
			{"确定领取", self.GetTeamExtraAward, self, 1},
			{"考虑一下"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	
	if tbAward.nNeedBag and me.CountFreeBagCell() < tbAward.nNeedBag then
		Dialog:Say(string.format("你的背包空间不足，需要%s格背包空间。", tbAward.nNeedBag));
		return 0;
	end	

	me.SetTask(Wldh.Battle.TASK_GROUP_ID, Wldh.Battle.TASKID_AWARD, 1);
	me.AddStackItem(tbAward.Item[1], tbAward.Item[2], tbAward.Item[3], tbAward.Item[4], {bForceBind=1}, tbAward.Num);
	
	-- 称号
	if tbAward.Title then
		me.AddTitle(tbAward.Title[1], tbAward.Title[2], tbAward.Title[3], tbAward.Title[4]);
		me.SetCurTitle(tbAward.Title[1], tbAward.Title[2], tbAward.Title[3], tbAward.Title[4]);
	end
	
	local szLog = string.format("【领取团体赛补充奖励】资格类型:%s", Wldh.Qualification:CheckMember(me) or 0);
	Wldh:WriteLog(szLog, me.nId);
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, szLog);
	
	Dialog:Say("成功领取了奖励。");
end

-- 团体赛区服奖励
function tbNpc:GetServerAward(nSure)
	
	if Wldh.Qualification:CheckServer() ~= 1 then
		Dialog:Say("对不起，你所在的区服没有参加武林大会，不能领取区服奖励。");
		return 0;
	end
	
	if me.nLevel < 90 then
		Dialog:Say("你的等级太低，无法领取奖励。");
		return 0;
	end
	
	if not nSure then
		local szMsg = string.format("这里可以领取团体赛区服奖励，你确定要领取吗？");
		local tbOpt = {
			{"确定领取", self.GetServerAward, self, 1},
			{"考虑一下"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	
	local nServer = me.GetTask(Wldh.Battle.TASK_GROUP_ID, Wldh.Battle.TASKID_SERVER);
	if nServer > 0 then
		Dialog:Say("你今日已经领取过区服奖励，不能再领了。");
		return 0;
	end
	
	local tbAward = nil;	
	local tbFinalGateWay = {};
	for i = 1, 4 do
		local nFinalGW = GetGlobalSportTask(Wldh.Battle.GBTASK_BATTLE_GROUP, Wldh.Battle.GBTASK_BATTLE_FINAL[i]);
		if nFinalGW > 0 then
			tbFinalGateWay[nFinalGW] = i;
		end
	end
	
	local nGateWay = tonumber(string.sub(GetGatewayName(), 5, 8));
	local nLinkGW = Wldh.COZONE_LIST[nGateWay];
	
	if tbFinalGateWay[nGateWay] or (nLinkGW and tbFinalGateWay[nLinkGW]) then
		tbAward = Wldh.Battle.tbServerAward[tbFinalGateWay[nGateWay]];
	else
		tbAward = Wldh.Battle.tbServerAward.Normal;
	end
	
	if not tbAward then
		return 0;
	end
	
	local nDay = me.GetTask(Wldh.Battle.TASK_GROUP_ID, Wldh.Battle.TASKID_SERVER_DAY);
	if nDay >= tbAward.Day then
		Dialog:Say("你已经领取完所有区服奖励。");
		return 0;
	end
	
	-- 1.福袋
	for i = 1, tbAward.Fudai do
		me.AddItem(18, 1, 80, 1);
	end
	
	-- 2.修炼时间
	if tbAward.Xiulian > 0 then
		me.SetTask(1023, 7, me.GetTask(1023, 7) + tbAward.Xiulian * 10);
	end
	
	-- 3.幸运时间
	me.AddSkillState(880, tbAward.Xingyun, 1, 30 * 60 * Env.GAME_FPS, 1, 0, 1);
	
	-- 4.经验时间
	me.AddSkillState(879, tbAward.Exp, 1, 60 * 60 * Env.GAME_FPS, 1, 0, 1);
	
	-- 5.磨刀护甲五行
	if tbAward.Level > 0 then
		me.AddSkillState(385, tbAward.Level, 1, 60 * 60 * Env.GAME_FPS, 1, 0, 1);
		me.AddSkillState(386, tbAward.Level, 1, 60 * 60 * Env.GAME_FPS, 1, 0, 1);
		me.AddSkillState(387, tbAward.Level, 1, 60 * 60 * Env.GAME_FPS, 1, 0, 1);
	end
	
	-- 烟花
	me.CastSkill(307, 1, -1, me.GetNpc().nIndex);
	
	me.SetTask(Wldh.Battle.TASK_GROUP_ID, Wldh.Battle.TASKID_SERVER, 1);
	me.SetTask(Wldh.Battle.TASK_GROUP_ID, Wldh.Battle.TASKID_SERVER_DAY, nDay + 1);
	local szLog = "【领取团体赛区服奖励】";
	Wldh:WriteLog(szLog, me.nId);
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, szLog);	
	Dialog:Say("成功领取了奖励。");
end

function tbNpc:TransToServer()

	-- 门派限制
	if me.nFaction <= 0 then
		Dialog:Say("必须加入门派的玩家才能参与武林大会。");
		return;
	end
	
	-- 判断是否有战队
	local nGateWay = Transfer:GetTransferGateway();
	if nGateWay <= 0  then
		nGateWay = tonumber(string.sub(GetGatewayName(), 5, 8));
		me.SetTask(Transfer.tbServerTaskId[1], Transfer.tbServerTaskId[2], nGateWay);
	end
	
	-- 判断队长
	if Wldh.Qualification:CheckMember(me) == 2 then
		me.SetTask(Wldh.Battle.TASK_GROUP_ID, Wldh.Battle.TASKID_CAPTAIN, 1);
	end
	
	local nMapId = Wldh.Battle.tbLeagueName[nGateWay][2];
	if not nMapId then
		Dialog:Say("你所在的区服不允许进入英雄岛。");
		return 0;
	end
	
	-- 实际这里是跨服操作
	local nCanSure = Map:CheckGlobalPlayerCount(nMapId);
	if nCanSure < 0 then
		me.Msg("Đường phía trước bị chặn.");
		return 0;
	end
	if nCanSure == 0 then
		me.Msg("武林大会场地人数已满，请稍后再尝试。");
		return 0;
	end
	Transfer:NewWorld2GlobalMap(me);
end

-- 查询武林大会专用绑银
function tbNpc:AskForCurrencyMoney()
	local nCurrentMoney = KGCPlayer.OptGetTask(me.nId, KGCPlayer.TSK_CURRENCY_MONEY);
	if nCurrentMoney >= 0 then
		Dialog:Say("你当前的武林大会专用银两为<color=gold>"..nCurrentMoney.."<color>。");
	else
		Dialog:Say("获取不了你当前的武林大会专用银两。");
	end
	return 0;
end

function Wldh.Battle:DailyEvent()
	me.SetTask(Wldh.Battle.TASK_GROUP_ID, Wldh.Battle.TASKID_SERVER, 0);
end;

PlayerSchemeEvent:RegisterGlobalDailyEvent({Wldh.Battle.DailyEvent, Wldh.Battle});
