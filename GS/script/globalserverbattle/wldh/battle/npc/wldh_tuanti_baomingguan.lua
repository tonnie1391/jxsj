-------------------------------------------------------
-- 文件名　：wldh_tuanti_baomingguan.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-09-02 14:55:20
-- 文件描述：
-------------------------------------------------------

Require("\\script\\globalserverbattle\\wldh\\battle\\wldh_battle_def.lua");

local tbNpc = Npc:GetClass("wldh_tuanti_baomingguan");

function tbNpc:OnDialog()
	if me.GetCamp() == 6 then
		Dialog:Say("记者记得要用GM卡哦！！！！！！")
		return;
	end
	
	-- 加上保护
	local nGateWay = Transfer:GetTransferGateway();
	if not Wldh.Battle.tbLeagueName[nGateWay] then
		return;
	end
	
	-- 取战斗名字
	local szLeagueName = Wldh.Battle.tbLeagueName[nGateWay][1];
	
	-- 没有该战队，先建立战队
	if not League:FindLeague(Wldh.Battle.MATCH_TYPE, szLeagueName) then
		Wldh.Battle:CreateLeague(szLeagueName);
	end
	
	-- 玩家不在战队中，则加入
	if not League:GetMemberLeague(Wldh.Battle.MATCH_TYPE, me.szName) then
		
		local nCaptain = me.GetTask(Wldh.Battle.TASK_GROUP_ID, Wldh.Battle.TASKID_CAPTAIN);
		
		-- 加入战队
		local tbMember = 
		{
			szName = me.szName,
			nCaptain = nCaptain,
			nFaction = me.nFaction,
			nRouteId = me.nRouteId,
			nSex = me.nSex,
			nSeries = me.nSeries,
		};
		
		-- 写操作GC执行
		GCExcute({"Wldh.Battle:AddMember", szLeagueName, tbMember});
		me.Msg(string.format("你已经成功加入战队：<color=yellow>%s<color>", szLeagueName));
	end
	
	local tbOpt = 
	{
		{"查看今日比赛对阵", self.ViewGroup, self},
		{"前往团体赛准备场", self.TransToMap, self},	
		{"查询团体赛成绩", self.QueryResult, self},
		{"我还要想想"},
	}
	
	local szMsg = string.format([[大型团体赛由来自同一地方的所有选手共同参与，同时对抗其他地方的选手。
		
比赛期间的周六、周日，每天<color=green>22:00~23:00<color>进行一场比赛(既10月10.11.17.18.24.25日)。
积分排名<color=green>前4<color>的服务器代表队，于11月02日(星期一)展开决赛。]]);

	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:ViewGroup()
	
	if not Wldh.Battle.tbGroupIndex then
		Dialog:Say("今日团体赛对阵表尚未产生。", {"Ta hiểu rồi"});
		return;
	end
	
	local szMsg = "本日团体赛对阵表：\n\n\n";
	
	for i = 1, #Wldh.Battle.tbGroupIndex do 
		
		-- 对阵双方
		local szLeagueNameSong = Wldh.Battle.tbLeagueName[Wldh.Battle.tbGroupIndex[i][1]][1];
		local szLeagueNameJin= Wldh.Battle.tbLeagueName[Wldh.Battle.tbGroupIndex[i][2]][1];
		
		szMsg = szMsg .. string.format("赛场%d：", i) .. "<color=yellow>" .. szLeagueNameSong .."<color>" 
			.. " vs " .. "<color=yellow>" .. szLeagueNameJin .. "<color>\n";
	end
	
	Dialog:Say(szMsg, {"Ta hiểu rồi。"});
end

function tbNpc:TransToMap()
	
	local szLeagueName = League:GetMemberLeague(Wldh.Battle.MATCH_TYPE, me.szName);
	
	-- 判断是否有战队
	if not szLeagueName then
		return;
	end
	
	-- 确定自己的战队哪个赛场
	local szMsg = "";
	local tbOpt = {};
	local tbGroup = Wldh.Battle:GetGroupByLeagueName(szLeagueName);
		
	if tbGroup then
		szMsg = string.format("你的战队今日将在<color=yellow>%d号<color>赛场<color=yellow>%s方<color>比赛。要传送过去么？",
			tbGroup[1], Wldh.Battle.NAME_CAMP[tbGroup[2]]);
		
		tbOpt = {{"传送到团体赛准备场", self.DoTrans, self, tbGroup[1]}, {"Để ta suy nghĩ thêm"}};
	else
		szMsg = "你的战队今日没有比赛。";
		tbOpt = {{"Ta hiểu rồi"}};
	end
	
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:DoTrans(nBattleIndex)
	
	if Wldh.Battle.MAPID_SIGNUP[nBattleIndex] then
		
		local nMapId = Wldh.Battle.MAPID_SIGNUP[nBattleIndex];
		me.NewWorld(nMapId, unpack(Wldh.Battle.POS_SIGNUP[MathRandom(1, 3)]));
	end	
end

function tbNpc:QueryResult()

	local szMsg = "你可以在我这儿查询团体赛相关赛况。";
	local tbOpt = 
	{
		{"查询本战队赛况", self.QueryLeague, self},
		{"查询其他人赛况", self.QueryOther, self, 1},
		{"查询其他战队赛况", self.QueryOther, self, 2},
		{"Kết thúc đối thoại"},
	};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:QueryLeague(szFindName)

	local szLeagueName = szFindName;
	if not szLeagueName then
		szLeagueName = League:GetMemberLeague(Wldh.Battle.MATCH_TYPE, me.szName);
		if not szLeagueName then
			Dialog:Say("官员：您还没有战队！", {{"Quay lại", self.QueryResult, self}, {"Kết thúc đối thoại"}});
			return 0;
		end
	end
	
	local nRank = League:GetLeagueTask(Wldh.Battle.MATCH_TYPE, szLeagueName, Wldh.Battle.LGTASK_RANK);
	local nWin = League:GetLeagueTask(Wldh.Battle.MATCH_TYPE, szLeagueName, Wldh.Battle.LGTASK_WIN);
	local nTie = League:GetLeagueTask(Wldh.Battle.MATCH_TYPE, szLeagueName, Wldh.Battle.LGTASK_TIE);
	local nTotal = League:GetLeagueTask(Wldh.Battle.MATCH_TYPE, szLeagueName, Wldh.Battle.LGTASK_TOTAL);
	local nLoss = nTotal - nWin - nTie;
	
	local szMacthName = "武林大会团体赛";
	local nPoint = nWin * Wldh.MACTH_POINT_WIN + nTie * Wldh.MACTH_POINT_TIE + nLoss * Wldh.MACTH_POINT_LOSS;
	local szRate = 100.00;
	
	if nTotal > 0 then
		szRate = string.format("%.2f", (nWin/nTotal)*100) .. "％";
	else
		szRate = "Vô";
	end
	
	local szRank = "";
	if nRank > 0 then
		szRank = string.format("\n战队排名：<color=green>%s<color>", nRank);
	end
	
	local szName = string.format("\n所在战队：<color=green>%s<color>\n", szLeagueName);
	local szMemberMsg = string.format([[
%s
赛制类型：<color=green>%s<color> 
总 场 数：<color=green>%s<color> 
胜    率：<color=green>%s<color>
总 积 分：<color=green>%s<color>
胜：<color=green>%s<color>  平：<color=green>%s<color>  负：<color=green>%s <color>
%s
]], szName, szMacthName, nTotal, szRate, nPoint, nWin, nTie, nLoss, szRank);
	
	Dialog:Say(szMemberMsg, {{"Quay lại", self.QueryResult, self}, {"Kết thúc đối thoại"}});
end

function tbNpc:QueryOther(nType, nFlag, szText)

	local szType = "战队名";
	if nType == 1 then
		szType = "角色名";
	end
	
	if not nFlag then
		Dialog:AskString(string.format("请输入%s：",szType), 16, self.QueryOther, self, nType, 1);
		return
	end
	
	--名字合法性检查
	local nLen = GetNameShowLen(szText);
	if nLen < 4 or nLen > 16 then
		Dialog:Say(string.format("您的%s的字数达不到要求。", szType), {{"Quay lại", self.QueryResult, self}, {"Kết thúc đối thoại"}});
		return 0;
	end
	
	--是否允许的单词范围
	if KUnify.IsNameWordPass(szText) ~= 1 then
		Dialog:Say(string.format("您的%s含有非法字符。", szType), {{"Quay lại", self.QueryResult, self}, {"Kết thúc đối thoại"}});
		return 0;
	end
	
	--是否包含敏感字串
	if IsNamePass(szText) ~= 1 then
		Dialog:Say(string.format("您的%s含有非法的敏感字符。", szType), {{"Quay lại", self.QueryResult, self}, {"Kết thúc đối thoại"}});
		return 0;
	end
	
	if nType == 2 then
		if not League:FindLeague(Wldh.Battle.MATCH_TYPE, szText) then
			Dialog:Say("您查询的武林大会战队不存在。", {{"Quay lại", self.QueryResult, self}, {"Kết thúc đối thoại"}});
			return 0;
		end
		
		--显示战队情况
		self:QueryLeague(szText);
	end
	
	if nType == 1 then
		local szLeagueName = League:GetMemberLeague(Wldh.Battle.MATCH_TYPE, szText);
		if not szLeagueName then
			Dialog:Say("您查找的玩家不在武林大会战队中。", {{"Quay lại", self.QueryResult, self}, {"Kết thúc đối thoại"}});
			return 0;
		end
		self:QueryLeague(szLeagueName);
	end
end
