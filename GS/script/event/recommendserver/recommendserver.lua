
local tbServer = {};
SpecialEvent.RecommendServer = tbServer;

tbServer.TASK_GOURP_ID 		= 2027;
tbServer.TASK_REGISTER_ID	=	4;
tbServer.TASK_LEVEL_ID 		= 
{
	[30] = 5,
	[40] = 6,
	[50] = 7,
	[60] = 8,
}
tbServer.LEVELSORT = {30, 40, 50, 60}
tbServer.TIME_LAST	= 30;	--持续20天.

tbServer.nOpenFlag	= EventManager.IVER_bOpenRecommendServer;

tbServer.DIALOGTXT 	=
{
	szRecommed 	= "推荐,确定要登记吗?",
	szAward 	= nil,
	szAbout		= string.format("首先，必须在10级以前在活动推广员处登记确认能领取入驻奖励。然后您在%s天内达到30，40，50，60级时，就能领取相应的奖励", tbServer.TIME_LAST),
	szNoAward	= "非常遗憾，您的截至领奖时间是<color=yellow>%s<color> ，不能领取入驻奖励。",
	szFinAward	= "您已经领完了该推荐服务器的所有入驻奖励", 
	szGetAward	= "领取%s级奖励",
	szGetAwardFin = "您成功领取了%s级<color=yellow>推荐服务器<color>活动奖励",
	szClose 	= "推荐服务器活动已结束，非常抱歉您不能再参加登记入驻服务器活动。",
	szNoFreeBag	= "对不起,您的背包空间不足。"
}
tbServer.AWARD = nil;

tbServer.__AWARD_1 = 
{
	[30] = {nBindCoin = 1000},
	[40] = {tbItem = {21, 5, 1, 1}},
	[50] = {nBindCoin = 3000},
	[60] = {nBindCoin = 6000},
}

tbServer.__AWARD_2 = 
{
	[30] = {nBindMoney = 100000},
	[40] = {nBindCoin = 1000},
	[50] = {nBindCoin = 3000},
	[60] = {nBindCoin = 5000},
}

tbServer.__szAward_1 = string.format("欢迎您入驻本推荐服务器，在您达到对应等级时，可以在各城市新手村活动推广员处领取以下奖励：\n   30级：1000绑定%s\n   40级：12格背包\n   50级：3000绑定%s\n   60级：6000绑定%s\n   注意：您只有在%s天内(<color=yellow>%%s<color>前)达到上述等级后才可以获得相应奖励", IVER_g_szCoinName, IVER_g_szCoinName, IVER_g_szCoinName, tbServer.TIME_LAST)

tbServer.__szAward_2 = string.format("欢迎您入驻本推荐服务器，在您达到对应等级时，可以在各城市新手村活动推广员处领取以下奖励：\n   30级：100000绑定银两\n   40级：1000绑定%s\n   50级：3000绑定%s\n   60级：5000绑定%s\n   注意：您只有在%s天内(<color=yellow>%%s<color>前)达到上述等级后才可以获得相应奖励", IVER_g_szCoinName, IVER_g_szCoinName, IVER_g_szCoinName, tbServer.TIME_LAST)

function tbServer:RefreshAward()
	if SpecialEvent:IsWellfareStarted_Remake() == 1 then
		self.AWARD = self.__AWARD_2;
		self.DIALOGTXT.szAward = self.__szAward_2;
	else
		self.AWARD = self.__AWARD_1;
		self.DIALOGTXT.szAward = self.__szAward_1;
	end
end

function tbServer:OnDialog(nFlag)
	if (self.nOpenFlag == 0) then
		Dialog:Say("您好！");
		return 0;
	end
	
	self:RefreshAward();
	local tbOpt = {};
	if me.GetTask(self.TASK_GOURP_ID, self.TASK_REGISTER_ID) ~= 0 then
		if self:CheckGetAward() == 1 then
			Dialog:Say(self.DIALOGTXT.szFinAward);
			return 0;
		end
		local szDate = os.date("%Y-%m-%d %H:%M:%S", (me.GetTask(self.TASK_GOURP_ID, self.TASK_REGISTER_ID) + self.TIME_LAST*86400));	
		if me.GetTask(self.TASK_GOURP_ID, self.TASK_REGISTER_ID) + self.TIME_LAST * 86400 < GetTime() then
			Dialog:Say(string.format(self.DIALOGTXT.szNoAward, szDate));
			return 0;
		end
		if nFlag ~= nil then
			if self.TASK_LEVEL_ID[nFlag] == nil or me.GetTask(self.TASK_GOURP_ID, self.TASK_LEVEL_ID[nFlag]) ~= 0 then
				return 0;
			end
			if self.AWARD[nFlag].tbItem ~= nil then
				if me.CountFreeBagCell() < 1 then
					Dialog:Say(self.DIALOGTXT.szNoFreeBag);
					return 0;
				end
			end
			self:GetAward(nFlag);
			Dialog:Say(string.format(self.DIALOGTXT.szGetAwardFin, nFlag));
			return 0;
		end
		local tbSort = {};
		for nId, nLevel in ipairs(self.LEVELSORT) do
			if self.TASK_LEVEL_ID[nLevel] then
				table.insert(tbSort, {nLevel, self.TASK_LEVEL_ID[nLevel]});
			end
		end
		
		for nId, tbItem in ipairs(tbSort) do
			if me.nLevel >= tbItem[1] then
				if me.GetTask(self.TASK_GOURP_ID, tbItem[2]) == 0 then
					table.insert(tbOpt, {string.format(self.DIALOGTXT.szGetAward, tbItem[1]), self.OnDialog, self, tbItem[1]});
				end
			end
		end

		table.insert(tbOpt, {"Kết thúc đối thoại"});
		Dialog:Say(string.format(self.DIALOGTXT.szAward, szDate), tbOpt);
		return 0;
	end
	if KGblTask.SCGetDbTaskInt(DBTASD_SERVER_RECOMMEND_TIME) == 0 then
		Dialog:Say(self.DIALOGTXT.szClose);
		return 0;
	end	
	if me.GetTask(self.TASK_GOURP_ID, self.TASK_REGISTER_ID) <= KGblTask.SCGetDbTaskInt(DBTASD_SERVER_RECOMMEND_TIME) then
		table.insert(tbOpt, {"我确定要登记", self.OnRecommend, self})
		table.insert(tbOpt, {"查看领奖规则", self.OnAbout, self});
		table.insert(tbOpt, {"Để ta suy nghĩ lại"})
		Dialog:Say(self.DIALOGTXT.szRecommed, tbOpt);
		return 0;
	end
	Dialog:Say("您已进行了登记。");
end

function c2s:Dialog2TuiGuanyuan(...)
	if GLOBAL_AGENT then
		return 0;
	end
	local nFlag = KItem.CheckLimitUse(me.nMapId, "REMOTE_CHUANGSONG");
	if nFlag ~= 1 then
		me.Msg("该地图不允许领取推荐服奖励！");
		return;
	end
	SpecialEvent.RecommendServer:OnDialog();
end

function tbServer:OnAbout()
	Dialog:Say(self.DIALOGTXT.szAbout);
end

function tbServer:GetAward(nLevel)
	if self.AWARD[nLevel] == nil then
		return 0;
	end
	if self.TASK_LEVEL_ID[nLevel] == nil or me.GetTask(self.TASK_GOURP_ID, self.TASK_LEVEL_ID[nLevel]) ~= 0 then
		return 0;
	end
	
	me.SetTask(self.TASK_GOURP_ID, self.TASK_LEVEL_ID[nLevel], 1);
	
	if self.AWARD[nLevel].tbItem then
		local pItem = me.AddItem(unpack(self.AWARD[nLevel].tbItem));
		if pItem then
			pItem.Bind(1);
			me.Msg(string.format("Chúc mừng nhận được một <color=yellow>%s<color>", pItem.szName))
			Dbg:WriteLog("PlayerEvent.RecommendServer", me.szName..",推荐服务器成功领取奖励:", pItem.szName);
		else
			Dbg:WriteLog("PlayerEvent.RecommendServer", me.szName..",推荐服务器失败领取奖励:", self.AWARD[nLevel].tbItem[1], self.AWARD[nLevel].tbItem[2], self.AWARD[nLevel].tbItem[3], self.AWARD[nLevel].tbItem[4]);
		end
		return 0;
	end
	
	if self.AWARD[nLevel].nBindCoin then
		me.AddBindCoin(self.AWARD[nLevel].nBindCoin, Player.emKBINDCOIN_ADD_EVENT)
		me.Msg(string.format("恭喜您获得<color=yellow>%s绑定%s<color>", self.AWARD[nLevel].nBindCoin, IVER_g_szCoinName))
		Dbg:WriteLog("PlayerEvent.RecommendServer", me.szName..",推荐服务器领取奖励:", "绑定Coin", self.AWARD[nLevel].nBindCoin);
		KStatLog.ModifyAdd("bindcoin", "[产出]推荐服奖励", "总量", self.AWARD[nLevel].nBindCoin);
		return 0;
	end
	
	if self.AWARD[nLevel].nBindMoney then
		me.AddBindMoney(self.AWARD[nLevel].nBindMoney, Player.emKBINDMONEY_ADD_EVENT)
		me.Msg(string.format("恭喜您获得<color=yellow>%s绑定银两<color>", self.AWARD[nLevel].nBindMoney))
		Dbg:WriteLog("PlayerEvent.RecommendServer", me.szName..",推荐服务器领取奖励:", "绑定银两", self.AWARD[nLevel].nBindMoney);
		KStatLog.ModifyAdd("bindjxb", "[产出]推荐服奖励", "总量", self.AWARD[nLevel].nBindMoney);
		return 0;
	end
end


function tbServer:CheckRecommend()
	if (self.nOpenFlag == 0) then
		return 0;
	end
	
	if me.GetTask(self.TASK_GOURP_ID, self.TASK_REGISTER_ID) ~= 0 then	
		if me.GetTask(self.TASK_GOURP_ID, self.TASK_REGISTER_ID) + self.TIME_LAST * 86400 <= GetTime() then
			return 0;
		end
		return 1;
	end
	return 0;
end

function tbServer:CheckGetAward()
	if (self.nOpenFlag == 0) then
		return 0;
	end
	
	for nLevel, nTaskId in pairs(self.TASK_LEVEL_ID) do
		if me.GetTask(self.TASK_GOURP_ID, nTaskId) == 0 then
			return 0;
		end
	end
	return 1;
end

function tbServer:OnRecommend()
	if KGblTask.SCGetDbTaskInt(DBTASD_SERVER_RECOMMEND_TIME) == 0 then
		Dialog:Say(self.DIALOGTXT.szClose);
		return 0;
	end		
	me.SetTask(self.TASK_GOURP_ID, self.TASK_REGISTER_ID, GetTime());
	Dialog:Say("您成功进行了登记。");
end

--nDate格式如(2008-6-25):20080625
function tbServer:SetDate(nDate)
	if string.len(nDate) ~= 8 then
		return
	end
	local nDateTemp = nDate*10000;
	local nSec = Lib:GetDate2Time(nDateTemp);
	if nSec then
		KGblTask.SCSetDbTaskInt(DBTASD_SERVER_RECOMMEND_TIME, nSec);
	end
	return GetLocalDate("%c", nSec);
end

function tbServer:Close()
	KGblTask.SCSetDbTaskInt(DBTASD_SERVER_RECOMMEND_TIME, 0);
	KGblTask.SCSetDbTaskInt(DBTASD_SERVER_RECOMMEND_CLOSE, 0);
	return 0;
end

function tbServer:DayClose()
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	KGblTask.SCSetDbTaskInt(DBTASD_SERVER_RECOMMEND_CLOSE, nDate);
	self:OnDayClose();
end

function tbServer:OnDayClose()
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	if KGblTask.SCGetDbTaskInt(DBTASD_SERVER_RECOMMEND_CLOSE) == 0 then
		return 0;
	end
	if nDate > KGblTask.SCGetDbTaskInt(DBTASD_SERVER_RECOMMEND_CLOSE) then
		self:Close();
		return 0;
	end
	if nDate == KGblTask.SCGetDbTaskInt(DBTASD_SERVER_RECOMMEND_CLOSE) then
		local nGetTime =GetLocalDate("%H")*3600 + GetLocalDate("%M")*60 + GetLocalDate("%S");
		local nEndTime = 24 *3600 ;
		local nTime = nEndTime - nGetTime;
		if nTime > 0 then
			Timer:Register(nTime * Env.GAME_FPS, self.Close, self);
		end
	end
	return 0;
end

function tbServer:OnLoginRegister()
	if KGblTask.SCGetDbTaskInt(DBTASD_SERVER_RECOMMEND_TIME) == 0 then
		return 0;
	end
	if me.GetTask(self.TASK_GOURP_ID, self.TASK_REGISTER_ID) == 0 and self:CheckGetAward() == 0 then
		me.SetTask(self.TASK_GOURP_ID, self.TASK_REGISTER_ID, GetTime());
		return 0;
	end
	if me.GetTask(self.TASK_GOURP_ID, self.TASK_REGISTER_ID) < KGblTask.SCGetDbTaskInt(DBTASD_SERVER_RECOMMEND_TIME) and self:CheckGetAward() == 0 then
		me.SetTask(self.TASK_GOURP_ID, self.TASK_REGISTER_ID, GetTime());
	end
	return 0;
end

