--移民服务器
--孙多良
--2008.09.10
--下次开放记得改为申请时记玩家任务变量做为领奖的标志。


local tbCS = {};
SpecialEvent.ChangeServer = tbCS;
----移民(转服申请)Start---
tbCS.CS_TIME_START = 200806271400;	--申请开启时间
tbCS.CS_TIME_END   = 200806302400;	--申请结束时间
tbCS.CS_TIME_CEND  = 200806302300;	--取消申请结束时间
tbCS.CS_APPLY  = 1;	--申请
tbCS.CS_CANCEL = 2;	--取消申请
tbCS.CS_SURECANCEL= 3;--确定取消申请
tbCS.CS_APPLY_SURE = 4; --确定申请
tbCS.WAREID = 35;		--移民证奇珍阁ID
tbCS.LEAGUE_TYPE = 4;	--战队类型
tbCS.JBCOIN = 200;		--需要金币或绑定金币,优先绑定金币
tbCS.LOGMODEL = "ChangeServer"
--申请转服服务器
tbCS.SERVER = 
{
	["gate0103"] = {nMax=2000, szOutName="青螺岛"},	--永乐镇
	["gate0104"] = {nMax=1500, szOutName="青螺岛"}, --稻香村
	["gate0102"] = {nMax=2000, szOutName="青螺岛"}, --龙门镇
	["gate0101"] = {nMax=1500, szOutName="青螺岛"}, --云中镇
	["gate0110"] = {nMax=1000, szOutName="青螺岛"}, --九老峰
	["gate0109"] = {nMax=1000, szOutName="青螺岛"}, --铸剑坊
	["gate0107"] = {nMax=500, szOutName="青螺岛"}, --龙泉村
	["gate0108"] = {nMax=500, szOutName="青螺岛"}, --巴陵县
	["gate0201"] = {nMax=1500, szOutName="湖畔竹林"}, --长江河谷
	["gate0202"] = {nMax=1500, szOutName="湖畔竹林"}, --雁荡龙秋
}

--转服后领取奖励服务器
tbCS.Award_SERVER = 
{
	["gate0118"] = 20080622240000,	--风陵渡
	["gate0112"] = 20080630240000,	--青螺岛
	["gate0210"] = "\\setting\\event\\changeserver\\award_gate0210.txt",	--湖畔竹林 --读取奖励名单
}

tbCS.Award_TIME_START	= 200807010000;
tbCS.Award_TIME_END 	= 200807082400;
tbCS.Award_TASK_GROUP 	= 2027;
tbCS.Award_TASK_ID	 	= 3;
tbCS.Award_COIN			= 10000;

--申请移民----------------------------------------------------------------------------------------
function tbCS:CheckState()
	local nNowDate = tonumber(GetLocalDate("%Y%m%d%H%M"));
	local szServer = GetGatewayName();
	if nNowDate >= self.CS_TIME_START and nNowDate < self.CS_TIME_END and self.Award_SERVER[szServer] ~= nil  then
		return 1;
	end
	return 0;
end

function tbCS:ApplyChangeServer(nFlag)
	local nDate = tonumber(GetLocalDate("%Y%m%d%H%M"));
	if nDate < self.CS_TIME_START then
		Dialog:Say("移民申请将在6月27日14：00开启，请届时再来。");
		return 0;
	end
	if nDate >= self.CS_TIME_END then
		Dialog:Say("移民申请已经截至，请等待下一次移民机会。");
		return 0;		
	end
	
	local nKinId, nKinMemId = me.GetKinMember();
	if nKinId > 0 then
		if me.nKinFigure == Kin.FIGURE_CAPTAIN then
			Dialog:Say("家族族长及帮会帮主不能申请，如要申请移民，请先移交族长或帮主的职位。");
			return 0;
		end
	end
	if me.nLevel < 50 then
		Dialog:Say("等级必须在50级以上才有资格申请移民。");
		return 0;
	end

	local tbOpt = {};
	if me.GetTempTable("League").nChangeServer == 1 then
		Dialog:Say("您刚刚进行了移民的操作，请稍后再进行操作。");
		return 0;
	end
	local nCount = League:GetLeagueCount(self.LEAGUE_TYPE);
	local szServer = GetGatewayName();	
	if nFlag == self.CS_APPLY or nFlag == self.CS_APPLY_SURE then
		--申请移民
		if League:FindLeague(self.LEAGUE_TYPE, me.szName) ~= nil then
			Dialog:Say("您已经成功申请了移民。");
			return 0;
		end
		if self.SERVER[szServer] == nil or nCount >= self.SERVER[szServer].nMax then
			Dialog:Say("目前移民报名名额已满，您稍候再来吧，或者也可以等待下一次移民。");
			return 0;
		end
		
		if me.nBindCoin < self.JBCOIN and me.GetJbCoin() < self.JBCOIN then
			Dialog:Say(string.format("移民申请费消耗%s金币或%s绑定金币，请带足申请费再来申请。", self.JBCOIN, self.JBCOIN));
			return 0;
		end
		if nFlag == self.CS_APPLY then
			tbOpt = {
				{"我确定要移民", self.ApplyChangeServer, self, self.CS_APPLY_SURE},
				{"我再考虑考虑"},		
			}
			Dialog:Say(string.format("移民申请将消耗%s金币或%s绑定金币,<color=red>您确定要移民吗?确定将会扣除绑定金币或金币<color>", self.JBCOIN, self.JBCOIN),tbOpt);
			return 0;
		end
		if me.nBindCoin >= self.JBCOIN then
			me.AddBindCoin(-self.JBCOIN, Player.emKBINDCOIN_COST_CHANGESERVER)
			Dbg:WriteLog(self.LOGMODEL, me.szName, "AddBindCoin", -self.JBCOIN)
			self:ApplyChangeServer_GS1(me.nId)
		else
			me.ApplyAutoBuyAndUse(self.WAREID, 1);
			Dbg:WriteLog(self.LOGMODEL, me.szName, "ApplyAutoBuyAndUse", self.WAREID)
		end
		me.GetTempTable("League").nChangeServer = 1;
		Player:RegisterTimer(Env.GAME_FPS * 30, self.InvalidRequest, self, me.nId);
		Dialog:Say("您已成功提出申请，详情请注意查收邮件。");
		--扣除金币.
		return 0;
	end
	
	--取消移民申请
	if nFlag == self.CS_CANCEL or nFlag == self.CS_SURECANCEL then
		if nDate >= self.CS_TIME_CEND then
			Dialog:Say("已经过了移民取消时间，您不能取消移民。");
			return 0;
		end
		if League:FindLeague(self.LEAGUE_TYPE, me.szName) == nil then
			Dialog:Say("您没有进行过移民申请。");
			return 0;
		end
		if nFlag == self.CS_SURECANCEL then
			--确定取消移民
			self:CancelChangeServer_GS1(me.nId)
			me.GetTempTable("League").nChangeServer = 1;
			Player:RegisterTimer(Env.GAME_FPS * 30, self.InvalidRequest, self, me.nId);
			Dialog:Say("您已成功提出取消申请。");
			return 0;
		end
		
		tbOpt = {
			{"是的，我确定", self.ApplyChangeServer, self, self.CS_SURECANCEL},
			{"我还是再考虑考虑吧"},
		}
		Dialog:Say("如果取消移民申请，申请费将不会返还，您确定要取消吗？", tbOpt);
		return 0;
	end
	
	tbOpt = {
		{"是的，我确定要移民", self.ApplyChangeServer, self, self.CS_APPLY},
		{"我要取消移民", self.ApplyChangeServer, self, self.CS_CANCEL},
		{"关于移民介绍", self.ChangeServerAbout, self};
		{"结束对话"},
	}
	if nDate >= self.CS_TIME_START and nDate < self.CS_TIME_END then
		local szMsg = string.format("进行移民会将您移到<color=red>【%s】<color>服务器（7月1日开放），移民成功后您将会获得<color=yellow>10000绑定金币<color>作为移民补偿，移民申请费为<color=yellow>200绑定金币或金币<color>，您是否确定要移民？\n\n", self.SERVER[szServer].szOutName );
		if self.SERVER[szServer] == nil or self.SERVER[szServer].nMax - nCount <= 0 then
			szMsg = string.format("%s<color=green>名额已满，您等待下一次移民吧<color>", szMsg);
		else
			szMsg = string.format("%s<color=green>当前还剩余移民名额：%s<color>", szMsg, self.SERVER[szServer].nMax - nCount);
		end
		Dialog:Say(szMsg, tbOpt);
	end
end

function tbCS:ChangeServerAbout()
	Dialog:Say("移民须知\n  移民申请时间：6月27日14：00—6月30日24：00。\n  申请费用：200绑定金币或200金币（优先扣除绑定金币） ，申请成功即扣除身上绑定金币或金币。\n  已成功报名的角色，在此期间如想取消，可去新手村活动推广员处取消移民资格（申请移民时已交纳的报名费不退还）。\n  家族族长及帮会帮主不能申请，如要申请移民，请先移交族长或帮主的职位。\n  如申请名额已满，不能再申请，但期间如有人取消申请，会空出申请名额。")
end

function tbCS:InvalidRequest(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if pPlayer == nil then
		return 0;
	end	
	pPlayer.GetTempTable("League").nChangeServer = nil;
	return 0;
end

function tbCS:ApplyChangeServer_GS1(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if pPlayer == nil then
		return 0;
	end
	local nCount = League:GetLeagueCount(self.LEAGUE_TYPE);
	local szServer = GetGatewayName();
	if self.SERVER[szServer] == nil or nCount >= self.SERVER[szServer].nMax then
		pPlayer.Msg("目前移民报名名额已满，您稍候再来吧，或者也可以等待下一次移民。");
		return 0;
	end
	if League:FindLeague(self.LEAGUE_TYPE, pPlayer.szName) ~= nil then
		pPlayer.Msg("您已经成功申请了移民。");
		return 0;
	end
	GCExcute({"SpecialEvent.ChangeServer:ApplyChangeServer_GC", nPlayerId, pPlayer.szName});
end

function tbCS:ApplyChangeServer_GC(nPlayerId, szPlayerName)
	local szServer = GetGatewayName();
	League:AddLeague(self.LEAGUE_TYPE, szPlayerName);
	local szTilte = "移民申请成功";
	local szContent = string.format("<color=yellow>您的移民申请已经被受理。<color>您将会在7月1日后被转移到同区<color=red>【%s】<color>服务器，届时请从该服务器登陆游戏。\n   在6月30日23：00前，您可以在活动推广员处取消移民申请。\n   移民时，您的家族帮会信息及邮件，金币交易所挂单都会丢失，请在移民前删除所有邮件并取消金币交易单，否则损失将由您自己承担。\n   移民成功后，您可以在%s服务器活动推广员处领取<color=yellow>10000绑定金币<color>作为移民补偿",self.SERVER[szServer].szOutName, self.SERVER[szServer].szOutName);
	_G.SendMailGC(nPlayerId, szTilte, szContent);
	Dbg:WriteLog(self.LOGMODEL, szPlayerName, "AddLeague");
end

function tbCS:CancelChangeServer_GS1(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if pPlayer == nil then
		return 0;
	end
	if League:FindLeague(self.LEAGUE_TYPE, pPlayer.szName) == nil then
		pPlayer.Msg("您没有进行过移民申请。");
		return 0;
	end
	GCExcute({"SpecialEvent.ChangeServer:CancelChangeServer_GC", nPlayerId, pPlayer.szName});
end

function tbCS:CancelChangeServer_GC(nPlayerId, szPlayerName)
	League:DelLeague(self.LEAGUE_TYPE, szPlayerName);
	Dbg:WriteLog(self.LOGMODEL, szPlayerName, "DelLeague");
end

function tbCS:OutPutLog()
	local pLeagueSet = KLeague.GetLeagueSetObject(self.LEAGUE_TYPE);
	local szServer = GetGatewayName();
	Dbg:WriteLog(self.LOGMODEL, "----StartOutLog----");
	Dbg:WriteLog(self.LOGMODEL, "MaxPlayerSum:", pLeagueSet.nLeagueCount);
	local pLeagueItor = pLeagueSet.GetLeagueItor();
	local pLeague =  pLeagueItor.GetCurLeague();
	local nCount = 1;
	while(pLeague) do
		Dbg:WriteLog(self.LOGMODEL, nCount, "PlayerName:", pLeague.szName, szServer);
		pLeague = pLeagueItor.NextLeague();
		nCount = nCount + 1;
	end
	Dbg:WriteLog(self.LOGMODEL, "----EndOutLog----");
end

--申请移民end----------------------------------------------------------------------------------------

--移民奖励----------------------------------------------------------------------------------------

function tbCS:CheckAward()
	local nNowDate = tonumber(GetLocalDate("%Y%m%d%H%M"));
	local szServer = GetGatewayName();
	if nNowDate >= self.Award_TIME_START and nNowDate < self.Award_TIME_END and self.Award_SERVER[szServer] ~= nil  then
		return 1;
	end
	return 0;
end

function tbCS:CheckAwardList()
	local nDate = tonumber(me.GetRoleCreateTime());
	local nNowDate = tonumber(GetLocalDate("%Y%m%d%H%M"));
	if me.nLevel < 50 then
		return 0, "对不起，您没有资格领取移民奖励。必须50级以上移民玩家才能领取。";
	end
	if nNowDate < self.Award_TIME_START then
		return 0, "对不起，领取奖励还没开始。";
	end
	if nNowDate >= self.Award_TIME_END then
		return 0, "对不起，领取奖励已经结束。";
	end
	if me.GetTask(self.Award_TASK_GROUP, self.Award_TASK_ID) == 2 then
		return 0, "您已领取过奖励了。";
	end
	local szServer = GetGatewayName();
	
	if type(self.Award_SERVER[szServer]) == "string" then
		if self.AwardList[szServer] == nil or self.AwardList[szServer][me.szName] == nil then
			return 0, "您不是移民过来的，没有资格领取移民奖励。";
		end
	elseif type(self.Award_SERVER[szServer]) == "number" then
		if nDate > self.Award_SERVER[szServer] then
			return 0, "您不是移民过来的，没有资格领取移民奖励。";
		end
	else
		return 0, "您不是移民过来的，没有资格领取移民奖励。";
	end
	return 1;
end

function tbCS:LoadAwardList()
	self.AwardList = {};
	for szgate, szPath in pairs(self.Award_SERVER) do
		if type(szPath) == "string" then
			local tbFile = Lib:LoadTabFile(szPath);
			if not tbFile then
				return
			end
			for nId, tbParam in ipairs(tbFile) do
				local szGateWay = tbParam.GATEWAY;
				if self.AwardList[szGateWay] == nil then
					self.AwardList[szGateWay] = {}
				end
				self.AwardList[szGateWay][tbParam.NAME] = 1;
			end
		end
	end 
end

function tbCS:GetServerAward(nFlag)
	local nCheck, szMsg = self:CheckAwardList()
	if nCheck == 0 then
		Dialog:Say(szMsg);
		return 0;
	end
	local szServer = GetGatewayName();
	local nAddCoin = self.Award_COIN
	local szMsg = "    您是新移民过来的玩家，将可以领取<color=yellow>10000绑定金币<color>的移民奖励，您确定现在领取吗?\n<color=red>领取截至时间：2008-07-08 24:00<color>";
	if szServer == "gate0118" then
		nAddCoin = 5500;
		szMsg = "    您是第一批新移民的玩家，还可以再次领取<color=yellow>5500绑定金币<color>的移民奖励，您确定现在领取吗？\n<color=red>领取截至时间：2008-07-08 24:00<color>";
	end
	if not nFlag then
		local tbOpt = 
		{
			{"我要现在领取", self.GetServerAward, self, 1},
			{"我再考虑考虑"},
		}
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	me.AddBindCoin(nAddCoin, Player.emKBINDCOIN_ADD_CHANGESERVER_AWARD);
	me.SetTask(self.Award_TASK_GROUP, self.Award_TASK_ID, 2);
	Dbg:WriteLog("GetChangeServerAward", me.szName, "GetBindCoin", nAddCoin);
	szMsg = string.format("您成功领取了<color=yellow>%s绑定金币<color>。", nAddCoin)
	Dialog:Say(szMsg);
	me.Msg(szMsg)
end




if (MODULE_GAMESERVER) then

SpecialEvent.ChangeServer:LoadAwardList()

end
--移民end----------------------------------------------------------------------------------------