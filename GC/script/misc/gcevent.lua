-- Gamecenter事件
local MAX20E = 2000000000;

--gc回调输出开关,可以自行添加,只添加要关闭输出的回调函数,建议添加频繁回调的函数，by Egg
GCEvent.OUTPUTSWITCH = 
{	
	["IbShop:AddFavoriteGoodsTimes"] = 1,
	["Player.tbGlobalFriends:gc_ApplyQureyGateway"] = 1,
	["Player.tbFightPower:UpdatePlayerExp"] = 1,
	["Player.tbGlobalFriends:gc_OnFoundGateway"] = 1,
	["Player.tbGlobalFriends:gc_OnQureyGateway"] = 1,
	["SuperBattle:CancelSignupFailed_GC"] = 1,
	["SuperBattle:SignupBattleFailed_GC"] = 1,
}

function GCEvent:OnGC2GCExecute(tbCall)
	local bOutput = 1;
	if tbCall[1] and type(tbCall[1]) == "string" then
		if self.OUTPUTSWITCH[tbCall[1]] and self.OUTPUTSWITCH[tbCall[1]] == 1 then
			bOutput = 0;
		end
	end
	if bOutput == 1 then
		print("OnGC2GCExecute", unpack(tbCall));
	end
	Lib:CallBack(tbCall);
end


function GCEvent:OnGCExcute(tbCall, nConnectId)
	local bOutput = 1;
	if tbCall[1] and type(tbCall[1]) == "string" then
		if self.OUTPUTSWITCH[tbCall[1]] and self.OUTPUTSWITCH[tbCall[1]] == 1 then
			bOutput = 0;
		end
	end
	if bOutput == 1 then
		print("OnGCExcute", unpack(tbCall));
	end
	self.nGCExecuteFromId = nConnectId;
	Lib:CallBack(tbCall);
	self.nGCExecuteFromId = nil;
end

function GCEvent:OnGBGCExcute(tbCall, nConnectId)
	local bOutput = 1;
	if tbCall[1] and type(tbCall[1]) == "string" then
		if self.OUTPUTSWITCH[tbCall[1]] and self.OUTPUTSWITCH[tbCall[1]] == 1 then
			bOutput = 0;
		end
	end
	if bOutput == 1 then
		print("OnGBGCExcute", "From ConnectId:"..nConnectId, unpack(tbCall));
	end
	self.nGBGCExcuteFromId = nConnectId;
	Lib:CallBack(tbCall);
	self.nGBGCExcuteFromId = nil;
end

-- Gamecenter初始化完毕
function GCEvent:OnGCInited()
	TimeFrame:SaveStartServerTime();	--第一次启动服务器时,自动记录开服时间;
	TimeFrame:Init();					--时间轴初始化;
	Task.tbHelp:LoadDynamicNewsGC();	--加载动态消息
	Player:SetMaxLevelGC();				--最大等级设置;
	ServerEvent:ServerListCfgInit();	--服务器列表初始化
	EventManager.EventManager:Init();	--活动系统初始化;
	
	--设置配置服务器gs总数量
	KGblTask.SCSetDbTaskInt(DBTASK_GAMESERVER_COUNT, self.SERVER_COUNT);
	
	--玩家金币交易开启
	if KGblTask.SCGetDbTaskInt(DBTASK_OPEN_COIN_TRADE) == 0 then
		KJbExchange.DelAllBill();
		KGblTask.SCSetDbTaskInt(DBTASK_OPEN_COIN_TRADE, 1);
	end
	
	--拍卖行金币交易开启
	if KGblTask.SCGetDbTaskInt(DBTASK_OPEN_COIN_AUCTION) == 0 then
		Auction:OpenAuctionCoin()
	end
	
	-- 执行服务器启动函数
	if self.tbStartFun then
		for i, tbStart in ipairs(self.tbStartFun) do
			local tbCallBack = {tbStart.fun, unpack(tbStart.tbParam)};
			Lib:CallBack(tbCallBack);
			--tbStart.fun(unpack(tbStart.tbParam));
		end
	end
end

--普通服务器启好连接上全局服务器时的回调(普通服务器和全局服务器都有)
function GCEvent:OnGlobalConnect(nConnectId)
	
	--已经注册的启好后给全局服务器回调
	if not GLOBAL_AGENT then
		if self.tbConnectGBGCServerFun then
			self.nConnectGBGCServerFunCount = 0;
			Timer:Register(1, GCEvent.OnConnectGBGCServerFun, GCEvent, nConnectId);
		end
	else
		if self.tbGBGCServerFunRecvConnect then
			for i, tbStart in ipairs(self.tbGBGCServerFunRecvConnect) do
				local tbCallBack = {unpack(tbStart)};
				table.insert(tbCallBack, nConnectId);
				Lib:CallBack(tbCallBack);
			end
		end	
	end
end

function GCEvent:OnConnectGBGCServerFun(nConnectId)
	if self.nConnectGBGCServerFunCount > (5*18*60) then
		print("Error!!!", "OnConnectGBGCServerFun", "timeout!!Can't Not GetGatewayName!!");
		return 0;
	end
	
	if GetGatewayName() == "" then
		self.nConnectGBGCServerFunCount = self.nConnectGBGCServerFunCount + 1;
		return 1;
	end
	
	if (not nConnectId) then
		print("Error!!!", "OnConnectGBGCServerFun", "nConnectId Is Null!!");
	end
	
	if self.tbConnectGBGCServerFun then
		for i, tbStart in ipairs(self.tbConnectGBGCServerFun) do
			local tbCallBack = {unpack(tbStart)};
			table.insert(tbCallBack, nConnectId);
			--GC_AllExcute(tbCallBack);
			Lib:CallBack(tbCallBack);
		end
	end
	return 0;
end

-- Gamecent正常关闭时调用
function GCEvent:OnGCUnit()
	-- 执行服务器关闭函数
	print("GCEvent:OnGCUnit");
	if self.tbShutDownFun then
		for i, tbShutDown in ipairs(self.tbShutDownFun) do
			local tbCallBack = {tbShutDown.fun, unpack(tbShutDown.tbParam)};
			Lib:CallBack(tbCallBack);
			--tbShutDown.fun(unpack(tbShutDown.tbParam));
		end
	end	
end

-- 注册普通服务器连上全局服务器时本服回调执行函数(回调第一个参数为nConnectId连接号)
-- 例子：GCEvent:RegisterConnectGBGCServerFunc({"GbWlls:SendMyWllsSession"})
function GCEvent:RegisterConnectGBGCServerFunc(tbStartFun)
	if GLOBAL_AGENT then
		return
	end
	if not self.tbConnectGBGCServerFun then
		self.tbConnectGBGCServerFun = {}
	end
	table.insert(self.tbConnectGBGCServerFun, tbStartFun);
end

-- 全局服务器收到普通服务器连接时回调执行函数
function GCEvent:RegisterGBGCServerRecvConnectFunc(tbStartFun)
	if not GLOBAL_AGENT then
		return
	end
	if not self.tbGBGCServerFunRecvConnect then
		self.tbGBGCServerFunRecvConnect = {}
	end
	table.insert(self.tbGBGCServerFunRecvConnect, tbStartFun);
end

-- 注册服务器启动执行函数
function GCEvent:RegisterGCServerStartFunc(fnStartFun, ...)
	if not self.tbStartFun then
		self.tbStartFun = {}
	end
	table.insert(self.tbStartFun, {fun=fnStartFun, tbParam=arg});
end

-- 注册服务器正常关闭执行函数
function GCEvent:RegisterGCServerShutDownFunc(fnShutDownFun, ...)
	if not self.tbShutDownFun then
		self.tbShutDownFun = {}
	end
	table.insert(self.tbShutDownFun, {fun=fnShutDownFun, tbParam=arg});
end

-- 获取从服的家族植树buf，之所以要特殊处理是因为家族id合并后会变化，
-- 而家族植树buf是以家族id作为关键字，所以先要保存成以家族名作为关键字的buf
function GCEvent:ProcessSubKinPlant()
	local tbBuf = GetGblIntBuf(GBLINTBUF_KIN_PLANT_DAILY, 0) or {};
	self.tbCoZoneSubKinPlant = {};
	for nKinId, tbInfo in pairs(tbBuf) do
		local pKin = KKin.GetKin(nKinId);
		if (pKin) then
			local szKinName = pKin.GetName();
			self.tbCoZoneSubKinPlant[szKinName] = tbInfo;
		else
			print("[GCEvent] ProcessSubKinPlant 没有家族记录 ", nKinId);
		end
	end
end

function GCEvent:ProcessMainKinPlant()
	local tbBuf = GetGblIntBuf(GBLINTBUF_KIN_PLANT_DAILY, 0) or {};
	self.tbCoZoneMainKinPlant = {};
	for nKinId, tbInfo in pairs(tbBuf) do
		local pKin = KKin.GetKin(nKinId);
		if (pKin) then
			local szKinName = pKin.GetName();
			self.tbCoZoneMainKinPlant[szKinName] = tbInfo;
		else
			print("[GCEvent] ProcessMainKinPlant 没有家族记录 ", nKinId);
		end
	end
end

function GCEvent:ProcessSubLotteryBuf()
	--print("Lottery:OnGCStart()")
	self.tbCoZoneSubLotteryBuf = {};
	local tb = {};
	local tbBuf = GetGblIntBuf(GBLINTBUF_LOTTERY_200908, 0);
	if tbBuf and type(tbBuf)=="table"  then
		tb = tbBuf;
	end
	
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"))
	local nSec = Lib:GetDate2Time(Lottery.LAST_LOTTERY_DATE) + Lottery.AWARD_KEEP_DAY*24*3600;
	local nEndDate = tonumber(os.date("%Y%m%d", nSec));
	-- 如果合服期间已经过了领奖期，那么就不用加载从服数据了
	if nCurDate < Lottery.FIRST_LOTTERY_DATE or nCurDate > nEndDate then
		tb = {};
	end
	
	for nBufId, szTblName in pairs(Lottery.tbBufId2TblName) do
		self.tbCoZoneSubLotteryBuf[szTblName] = tb[nBufId] or {};
	end
end

function GCEvent:OnCoZoneStepSubZone(szSubGcDb)	
	--KJbExchange.DelAllBill();
	
	-- 不是全局服和服就做
	if (not GLOBAL_AGENT) then
		self:CozoneFactionElecet_Load();
		Task.TaskExp:CancelAllTask();
		self.nCoZoneSubZoneTax = KGblTask.SCGetDbTaskInt(DBTASK_TRADE_CUR_TAX);
		self.nCoZoneSubZoneCoinPlayer = KGblTask.SCGetDbTaskInt(DBTASK_COIN_EXCHANGE_PAYER) * 0.9;
		self.nCoZoneSubZoneCoinPlayerRecent = KGblTask.SCGetDbTaskInt(DBTASK_COIN_EXCHANGE_PAYER_RECENT) * 0.9;
		self.nCoZoneSubZoneBaiBaoxiangCaichi	= KGblTask.SCGetDbTaskInt(DBTASK_BAIBAOXIANG_CAICHI);
		self.nCoZoneSubZoneBaZhuZhiYinMaxCount	= KGblTask.SCGetDbTaskInt(DBTASK_BAZHUZHIYIN_MAX);
		self.szCoZoneSubZoneBaZhuZhiYinMaxName	= KGblTask.SCGetDbTaskStr(DBTASK_BAZHUZHIYIN_MAX);
		self.nCoZoneSubZoneBaZhuZhiYinState 	= KGblTask.SCGetDbTaskInt(DBTASK_DOMAIN_BATTLE_STEP);
		self.nCoZoneSubZoneWanted_Now_WeekCount1	= KGblTask.SCGetDbTaskInt(DBTASD_WANTED_LV1_WEEKTASK_COUNT);
		self.nCoZoneSubZoneWanted_Last_WeekCount1	= KGblTask.SCGetDbTaskInt(DBTASD_WANTED_LV1_LASTWEEKTASK_COUNT);
		self.nCoZoneSubZoneWanted_Now_WeekCount2	= KGblTask.SCGetDbTaskInt(DBTASD_WANTED_LV2_WEEKTASK_COUNT);
		self.nCoZoneSubZoneWanted_Last_WeekCount2	= KGblTask.SCGetDbTaskInt(DBTASD_WANTED_LV2_LASTWEEKTASK_COUNT);
		self.nCoZoneSubZoneWanted_Now_WeekCount3	= KGblTask.SCGetDbTaskInt(DBTASD_WANTED_LV3_WEEKTASK_COUNT);
		self.nCoZoneSubZoneWanted_Last_WeekCount3	= KGblTask.SCGetDbTaskInt(DBTASD_WANTED_LV3_LASTWEEKTASK_COUNT);
		self.nCoZoneSubZoneWanted_Now_WeekCount4	= KGblTask.SCGetDbTaskInt(DBTASD_WANTED_LV4_WEEKTASK_COUNT);
		self.nCoZoneSubZoneWanted_Last_WeekCount4	= KGblTask.SCGetDbTaskInt(DBTASD_WANTED_LV4_LASTWEEKTASK_COUNT);
		self.nCoZoneSubZoneWanted_Now_WeekCount5	= KGblTask.SCGetDbTaskInt(DBTASD_WANTED_LV5_WEEKTASK_COUNT);
		self.nCoZoneSubZoneWanted_Last_WeekCount5	= KGblTask.SCGetDbTaskInt(DBTASD_WANTED_LV5_LASTWEEKTASK_COUNT);
		self.nCoZoneSubZoneWanted_Now_WeekCount6	= KGblTask.SCGetDbTaskInt(DBTASD_WANTED_LV6_WEEKTASK_COUNT);
		self.nCoZoneSubZoneWanted_Last_WeekCount6	= KGblTask.SCGetDbTaskInt(DBTASD_WANTED_LV6_LASTWEEKTASK_COUNT);
		self.nCoZoneSubZoneFulijinghuoWeiWang		= KGblTask.SCGetDbTaskInt(DBTASD_EVENT_PRESIGE_RESULT);
		self.nCoZoneSubZoneGuanXianNo				= KGblTask.SCGetDbTaskInt(DBTASK_OFFICIAL_MAINTAIN_NO);
	
	
		self.bCoZoneSubZoneBaZhuZhiYinGetTongAward = Domain:IsGetTongAward();
		Domain:CozoneDomain_Deal()
		self.tbCoZoneStatuData = {}
		self:OnCoZoneStatuary_Load();
		self.tbCoZoneGirlGblBuf	= GetGblIntBuf(GBLINTBUF_GIRL_VOTE, 0);
		self.tbCoZoneCompensateGmBuf = GetGblIntBuf(GBLINTBUF_COMPENSATE_GM, 0); --离线指令
		self.tbCoZoneKingeyesEventBuf = GetGblIntBuf(GBLINTBUF_KINGEYES_EVENT, 0); --活动指令
		self.tbCoZoneArrestListBuf = GetGblIntBuf(GBLINTBUF_ARREST_LIST, 0); --批量关天牢
		self.tbCoZoneBlackListBuf = GetGblIntBuf(GBLINTBUF_BLACKLIST, 0); -- 非法刷道具玩家及其所得道具名单
		self.tbCoZoneIBShopListBuf = GetGblIntBuf(GBLINTBUF_IBSHOP, 0); -- 奇珍阁物品上下架状态
		self.tbCoZoneWldhMemberListBuf = GetGblIntBuf(GBLINTBUF_WLDH_MEMBER, 0); -- 武林大会资格认定
		self.tbCoZoneVipTransferBuf = GetGblIntBuf(GBLINTBUF_VIP_REBORN, 0); -- vip转服
		-- marrry
		self.tbCoZonePropopalBuf	= GetGblIntBuf(GBLINTBUF_PROPOSAL, 0);	-- 解除订婚
		self.tbCoZoneMarryBuf		= GetGblIntBuf(GBLINTBUF_MARRY, 0);		-- 预定婚期
		self.tbCoZoneDevorceBuf		= GetGblIntBuf(GBLINTBUF_DIVORCE, 0);	-- 预定婚期
		-- end
	
		self.tbCoZonePresendCardListBuf = GetGblIntBuf(GBLINTBUF_PRESENDCARD, 0);
		
		self.tbCoZoneGbWlls8RankInfoBuf	= GetGblIntBuf(GBLINTBUF_GBWLLS_FINALPLAYERLIST, 0);
		self.nCoZoneGbWlls_StarServerRank = KGblTask.SCGetDbTaskInt(DBTASD_GBWLLS_STARSERVER_RANK);
		self.nCoZoneGbWlls_StarServerTime = KGblTask.SCGetDbTaskInt(DBTASD_GBWLLS_STARSERVER_RANK_TIME);
		
		self.tbCoGlobalFriend = GetGblIntBuf(GBLINTBUF_GLOBALFRIEND, 0);
		self.tbSubZoneQiXiBuf	= GetGblIntBuf(GBLINTBUF_QIXI_XIALV, 0); -- 七夕活动合服
		self.tbSubZoneExpTaskBuf	= GetGblIntBuf(GBLINTBUF_TASKPLATFORM, 0);
		self.tbSubZoneLiJinBuf	= GetGblIntBuf(GBLINTBUF_MARRY_LIJIN, 0);
	
		self.tbCoZoneFightAfterBuf  = GetGblIntBuf(GBLINTBUF_FIGHTAFTER, 0); -- 战后系统合服
		self.tbCoZoneGirlVoteNewBuf = GetGblIntBuf(GBLINTBUF_GIRL_VOTE_NEW, 0); -- 新美女投票合服
		self.tbCoZonePlayerBackBuf	= GetGblIntBuf(GBLINTBUF_OLDPLAYERBACK, 0);
		self.tbCoZonePlayerBackBuf1	= GetGblIntBuf(GBLINTBUF_OLDPLAYERBACK_2011_1, 0);
		self.tbCoZonePlayerBackBuf2	= GetGblIntBuf(GBLINTBUF_OLDPLAYERBACK_2011_2, 0);
		
		self.tbCoZoneLotteryBuf1 = GetGblIntBuf(GBLINTBUF_LOTTERY_YEAR, 0);
		self.tbCoZoneLotteryBuf2 = GetGblIntBuf(GBLINTBUF_LOTTERY_YEAR_COSUB, 0);
		
		self.tbCoZoneWeekFish = GetGblIntBuf(GBLINTBUF_WEEKEND_FISH, 0);
		self.tbCoZoneTransferBuf = GetGblIntBuf(GBLINTBUF_ROLE_TRANSFER, 0);
		self.tbCoZoneTransferBufFail = GetGblIntBuf(GBLINTBUF_CHANGEACOUNT_FAIL, 0);
		self.tbCoZoneXoyoKinRank = GetGblIntBuf(GBLINTBUF_XOYO_KIN_RANK, 0);
		self.tbCoZoneKeyimenBuf	= GetGblIntBuf(Keyimen.BUFFER_INDEX, 0);
		self.tbCoZoneGirlDaily	= GetGblIntBuf(GBLINTBUF_GIRL_DAILY, 0);
		self:ProcessSubKinPlant();
		self:ProcessSubLotteryBuf();
	end
	

	self.tbWllsLeagueList = Wlls:_GetWllsLeague();

	local nStart = string.find(szSubGcDb, "_");
	self.szCoZoneSubGateWay = ""; 
	if (nStart == 0) then
		self.szCoZoneSubGateWay = szSubGcDb;
	else
		self.szCoZoneSubGateWay = string.sub(szSubGcDb, 1, nStart - 1);
	end
	
	-- 子服开服时间记录，用于计算两服开服相差时间
	if not self.nSubServerStartTime then
		self.nSubServerStartTime = 0;
	end
	self.nSubServerStartTime = KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME);
	GCEvent:OnWriteSubZonePlayer();
	
	if (GLOBAL_AGENT) then
		self:OnCoZoneStepSubZone_Global();
	end
	
	return 1;
end

-- 加载从服数据
function GCEvent:OnCoZoneStepSubZone_Global()
	-- 跨服城战
	self.tbCoZoneSubNewLand_CastleBuffer	= GetGblIntBuf(GBLINTBUF_NL_CASTLE, 0) or {};
	self.tbCoZoneSubNewLand_HistoryBuffer	= GetGblIntBuf(GBLINTBUF_NL_HISTORY_EX, 0) or {};
	self.nCoZoneSubNewLand_OpenFlag			= GetGlobalSportTask(Newland.GA_DBTASK_GID, Newland.GA_DBTASK_OPEN) or 0;
	self.nCoZoneSubNewLand_Session			= GetGlobalSportTask(Newland.GA_DBTASK_GID, Newland.GA_DBTASK_SESSION) or 0;
	self.nCoZoneSubNewLand_Preiod			= GetGlobalSportTask(Newland.GA_DBTASK_GID, Newland.GA_DBTASK_PERIOD) or 0;
	self.szCoZoneSubNewLand_GateWay 		= self.szCoZoneSubGateWay;
	
	-- 跨服宋金
	self.tbCoZoneSubSuperBattle_GlobalBuffer	= GetGblIntBuf(SuperBattle.nBufferIndex, 0) or {};
	self.nCoZoneSubSuperBattle_OpenFlag			= GetGlobalSportTask(SuperBattle.GA_DBTASK_GID, SuperBattle.GA_DBTASK_OPEN) or 0;
	self.nCoZoneSubSuperBattle_Session			= GetGlobalSportTask(SuperBattle.GA_DBTASK_GID, SuperBattle.GA_DBTASK_SESSION) or 0;
	self.nCoZoneSubSuperBattle_Week				= GetGlobalSportTask(SuperBattle.GA_DBTASK_GID, SuperBattle.GA_DBTASK_WEEK) or 0;
	self.nCoZoneSubSuperBattle_SignUp			= GetGlobalSportTask(SuperBattle.GA_DBTASK_GID, SuperBattle.GA_DBTASK_SIGNUP) or 0;
	self.nCoZoneSubSuperBattle_Queue			= GetGlobalSportTask(SuperBattle.GA_DBTASK_GID, SuperBattle.GA_DBTASK_QUEUE) or 0;
	
	print("[GCEvent] OnCoZoneStepSubZone_Global ", self.szCoZoneSubNewLand_GateWay, self.nCoZoneSubNewLand_Session, self.nCoZoneSubSuperBattle_Session);
end

-- 加载主服数据
function GCEvent:OnCoZoneStepMainZone_Global()
	-- 跨服城战
	self.tbCoZoneMainNewLand_CastleBuffer	= GetGblIntBuf(GBLINTBUF_NL_CASTLE, 0) or {};
	self.tbCoZoneMainNewLand_HistoryBuffer	= GetGblIntBuf(GBLINTBUF_NL_HISTORY_EX, 0) or {};
	self.nCoZoneMainNewLand_OpenFlag		= GetGlobalSportTask(Newland.GA_DBTASK_GID, Newland.GA_DBTASK_OPEN) or 0;
	self.nCoZoneMainNewLand_Session			= GetGlobalSportTask(Newland.GA_DBTASK_GID, Newland.GA_DBTASK_SESSION) or 0;
	self.nCoZoneMainNewLand_Preiod			= GetGlobalSportTask(Newland.GA_DBTASK_GID, Newland.GA_DBTASK_PERIOD) or 0;
	self.szCoZoneMainNewLand_GateWay 		= self.szCoZoneMainGateWay;
	
	-- 跨服宋金
	self.tbCoZoneMainSuperBattle_GlobalBuffer	= GetGblIntBuf(SuperBattle.nBufferIndex, 0) or {};
	self.nCoZoneMainSuperBattle_OpenFlag		= GetGlobalSportTask(SuperBattle.GA_DBTASK_GID, SuperBattle.GA_DBTASK_OPEN) or 0;
	self.nCoZoneMainSuperBattle_Session			= GetGlobalSportTask(SuperBattle.GA_DBTASK_GID, SuperBattle.GA_DBTASK_SESSION) or 0;
	self.nCoZoneMainSuperBattle_Week			= GetGlobalSportTask(SuperBattle.GA_DBTASK_GID, SuperBattle.GA_DBTASK_WEEK) or 0;
	self.nCoZoneMainSuperBattle_SignUp			= GetGlobalSportTask(SuperBattle.GA_DBTASK_GID, SuperBattle.GA_DBTASK_SIGNUP) or 0;
	self.nCoZoneMainSuperBattle_Queue			= GetGlobalSportTask(SuperBattle.GA_DBTASK_GID, SuperBattle.GA_DBTASK_QUEUE) or 0;
	
	self.nCoZoneMainGbWlls_Session		= GetGlobalSportTask(GbWlls.GBTASK_GROUP, GbWlls.GBTASK_SESSION) or 0;
	self.nCoZoneMainGbWlls_FirstTime	= GetGlobalSportTask(GbWlls.GBTASK_GROUP, GbWlls.GBTASK_FIRSTOPENTIME) or 0;
	self.nCoZoneMainGbWlls_MatchState	= GetGlobalSportTask(GbWlls.GBTASK_GROUP, GbWlls.GBTASK_MATCH_STATE) or 0;
	self.nCoZoneMainGbWlls_Rank			= GetGlobalSportTask(GbWlls.GBTASK_GROUP, GbWlls.GBTASK_MATCH_RANK) or 0;
	self.nCoZoneMainGbWlls_OpenGolden	= GetGlobalSportTask(GbWlls.GBTASK_GROUP, GbWlls.GBTASK_MATCH_OPEN_GOLDEN) or 0;
	
	print("[GCEvent] OnCoZoneStepMainZone_Global ", self.szCoZoneMainNewLand_GateWay, self.nCoZoneMainNewLand_Session, self.nCoZoneMainSuperBattle_Session);
end

-- 全局服合并
function GCEvent:OnCoZoneStepCombinedSub_Global()
	print("[GCEvent] OnCoZoneStepCombinedSub_Global start");
	if (not GLOBAL_AGENT) then
		return 0;
	end
	self:UpdateSuperBattleBuffer();
	self:UpdateNewLandBuffer();

	SetGlobalSportTask(GbWlls.GBTASK_GROUP, GbWlls.GBTASK_SESSION, self.nCoZoneMainGbWlls_Session);
	SetGlobalSportTask(GbWlls.GBTASK_GROUP, GbWlls.GBTASK_FIRSTOPENTIME, self.nCoZoneMainGbWlls_FirstTime);
	SetGlobalSportTask(GbWlls.GBTASK_GROUP, GbWlls.GBTASK_MATCH_STATE, self.nCoZoneMainGbWlls_MatchState);
	SetGlobalSportTask(GbWlls.GBTASK_GROUP, GbWlls.GBTASK_MATCH_RANK, self.nCoZoneMainGbWlls_Rank);
	SetGlobalSportTask(GbWlls.GBTASK_GROUP, GbWlls.GBTASK_MATCH_OPEN_GOLDEN, self.nCoZoneMainGbWlls_OpenGolden);
end

function GCEvent:UpdateSuperBattleBuffer()
	print("[GCEvent] UpdateSuperBattleBuffer start ");
	if (self.nCoZoneSubSuperBattle_Session > self.nCoZoneMainSuperBattle_Session) then
		local tbTempGlobalBuffer = self.tbCoZoneSubSuperBattle_GlobalBuffer;
		local nBattleSession = self.nCoZoneSubSuperBattle_Session;
		local nBattleOpenFlag = self.nCoZoneSubSuperBattle_OpenFlag;
		local nBattleWeek = self.nCoZoneSubSuperBattle_Week;
		local nBattleSignUp = self.nCoZoneSubSuperBattle_SignUp;
		local nBattleQueue = self.nCoZoneSubSuperBattle_Queue;
		
		self.tbCoZoneSubSuperBattle_GlobalBuffer	= self.tbCoZoneMainSuperBattle_GlobalBuffer;
		self.nCoZoneSubSuperBattle_OpenFlag			= self.nCoZoneMainSuperBattle_OpenFlag;
		self.nCoZoneSubSuperBattle_Session			= self.nCoZoneMainSuperBattle_Session;
		self.nCoZoneSubSuperBattle_Week				= self.nCoZoneMainSuperBattle_Week;
		self.nCoZoneSubSuperBattle_SignUp			= self.nCoZoneMainSuperBattle_SignUp;
		self.nCoZoneSubSuperBattle_Queue			= self.nCoZoneMainSuperBattle_Queue;

		self.tbCoZoneMainSuperBattle_GlobalBuffer	= tbTempGlobalBuffer;
		self.nCoZoneMainSuperBattle_OpenFlag		= nBattleOpenFlag;
		self.nCoZoneMainSuperBattle_Session			= nBattleSession;
		self.nCoZoneMainSuperBattle_Week			= nBattleWeek;
		self.nCoZoneMainSuperBattle_SignUp			= nBattleSignUp;
		self.nCoZoneMainSuperBattle_Queue			= nBattleQueue;
	end

	if (not self.tbCoZoneSubSuperBattle_GlobalBuffer) then
		return 0;
	end
	
	local tbMainBuffer = self.tbCoZoneMainSuperBattle_GlobalBuffer;
	if (not tbMainBuffer or type(tbMainBuffer) ~= "table") then
		tbMainBuffer = {};
		self.tbCoZoneMainSuperBattle_GlobalBuffer = tbMainBuffer;
	end
	
	for j, tbPlayerInfo in pairs(self.tbCoZoneSubSuperBattle_GlobalBuffer) do
		if #tbMainBuffer == 0 then
			table.insert(tbMainBuffer, tbPlayerInfo);
		else
			local nIns = 0;
			for i = 1, #tbMainBuffer do
				if tbMainBuffer[i][2] < tbPlayerInfo[2] then
					table.insert(tbMainBuffer, i, tbPlayerInfo);
					nIns = i;
					break;
				end
			end
			if nIns == 0 then
				table.insert(tbMainBuffer, tbPlayerInfo);
			end
		end
	end

	for i = SuperBattle.MAX_BUFFER_LEN + 1, #tbMainBuffer do
		tbMainBuffer[i] = nil;
	end
	self.tbCoZoneMainSuperBattle_GlobalBuffer = tbMainBuffer;
	
	SetGblIntBuf(SuperBattle.nBufferIndex, 0, 0, self.tbCoZoneMainSuperBattle_GlobalBuffer);
	SetGlobalSportTask(SuperBattle.GA_DBTASK_GID, SuperBattle.GA_DBTASK_OPEN, self.nCoZoneMainSuperBattle_OpenFlag);
	SetGlobalSportTask(SuperBattle.GA_DBTASK_GID, SuperBattle.GA_DBTASK_SESSION, self.nCoZoneMainSuperBattle_Session);
	SetGlobalSportTask(SuperBattle.GA_DBTASK_GID, SuperBattle.GA_DBTASK_WEEK, self.nCoZoneMainSuperBattle_Week);
	SetGlobalSportTask(SuperBattle.GA_DBTASK_GID, SuperBattle.GA_DBTASK_SIGNUP, self.nCoZoneMainSuperBattle_SignUp);
	SetGlobalSportTask(SuperBattle.GA_DBTASK_GID, SuperBattle.GA_DBTASK_QUEUE, self.nCoZoneMainSuperBattle_Queue);
	print("[GCEvent] UpdateSuperBattleBuffer end ");
end

-- 合并城主
function GCEvent:CombineNewLandHistoryBuffer(tbTempBuffer, szGateWay, tbTempHistoryBuffer)
	print("[GCEvent] CombineNewLandHistoryBuffer start ", szGateWay);
	-- 将从服的历史记录插入到主服的城主历史记录里
	if (tbTempBuffer) then
		if (szGateWay and szGateWay ~= "") then
			-- 仅限大陆版合服
			local tbHistory = self.tbCoZoneMainNewLand_HistoryBuffer[szGateWay];
			if (not tbHistory) then
				tbHistory = {};
			end
			local tbSubHistory = tbTempBuffer.tbHistory or {};
			for nSession, tbInfo in pairs(tbSubHistory) do
				tbHistory[nSession] = tbInfo;
			end
			self.tbCoZoneMainNewLand_HistoryBuffer[szGateWay] = tbHistory;			
		end		
	end
	
	-- 合并之前合过服的历史记录
	if (tbTempHistoryBuffer) then
		local tbSubHistory = tbTempHistoryBuffer or {};
		for szGate, tbHis in pairs(tbSubHistory) do
			local tbTempHis = self.tbCoZoneMainNewLand_HistoryBuffer[szGate];
			if (not tbTempHis) then
				tbTempHis = tbHis or {};
			else
				for nSession, tbInfo in pairs(tbHis) do
					tbTempHis[nSession] = tbInfo;
				end
			end
			self.tbCoZoneMainNewLand_HistoryBuffer[szGate] = tbTempHis;
		end
	end
end

function GCEvent:UpdateNewLandBuffer()
	print("[GCEvent] UpdateNewLandBuffer start ");
	-- 哪个最大就用哪个作为主服的数据
	if (self.nCoZoneSubNewLand_Session > self.nCoZoneMainNewLand_Session) then
		local tbTempCastle = self.tbCoZoneSubNewLand_CastleBuffer;
		local tbTempHistory = self.tbCoZoneSubNewLand_HistoryBuffer;
		local nNLOpenFlag = self.nCoZoneSubNewLand_OpenFlag;
		local nNLSession = self.nCoZoneSubNewLand_Session;
		local nNLPeriod	= self.nCoZoneSubNewLand_Preiod;
		local szGateWay	= self.szCoZoneSubGateWay;
		
		self.tbCoZoneSubNewLand_CastleBuffer	= self.tbCoZoneMainNewLand_CastleBuffer;
		self.tbCoZoneSubNewLand_HistoryBuffer	= self.tbCoZoneMainNewLand_HistoryBuffer;
		self.nCoZoneSubNewLand_OpenFlag			= self.nCoZoneMainNewLand_OpenFlag;
		self.nCoZoneSubNewLand_Session			= self.nCoZoneMainNewLand_Session;
		self.nCoZoneSubNewLand_Preiod			= self.nCoZoneMainNewLand_Preiod;
		self.szCoZoneSubNewLand_GateWay			= self.szCoZoneMainNewLand_GateWay;

		self.tbCoZoneMainNewLand_CastleBuffer	= tbTempCastle;
		self.tbCoZoneMainNewLand_HistoryBuffer	= tbTempHistory;
		self.nCoZoneMainNewLand_OpenFlag		= nNLOpenFlag;
		self.nCoZoneMainNewLand_Session			= nNLSession;
		self.nCoZoneMainNewLand_Preiod			= nNLPeriod;
		self.szCoZoneMainNewLand_GateWay		= szGateWay;
	end

	self:CombineNewLandHistoryBuffer(self.tbCoZoneSubNewLand_CastleBuffer, self.szCoZoneSubNewLand_GateWay, self.tbCoZoneSubNewLand_HistoryBuffer);
	self:CombineNewLandHistoryBuffer(self.tbCoZoneMainNewLand_CastleBuffer, self.szCoZoneMainNewLand_GateWay);

	SetGblIntBuf(GBLINTBUF_NL_CASTLE, 0, 0, self.tbCoZoneMainNewLand_CastleBuffer);
	SetGblIntBuf(GBLINTBUF_NL_HISTORY_EX, 0, 0, self.tbCoZoneMainNewLand_HistoryBuffer);
	SetGlobalSportTask(Newland.GA_DBTASK_GID, Newland.GA_DBTASK_OPEN, self.nCoZoneMainNewLand_OpenFlag);
	SetGlobalSportTask(Newland.GA_DBTASK_GID, Newland.GA_DBTASK_SESSION, self.nCoZoneMainNewLand_Session);
	SetGlobalSportTask(Newland.GA_DBTASK_GID, Newland.GA_DBTASK_PERIOD, self.nCoZoneMainNewLand_Preiod);
	print("[GCEvent] UpdateNewLandBuffer end ");
end

function GCEvent:OnWriteSubZonePlayer()
	print("OnWriteSubZonePlayer start");
	local nCount = 0;
	local nTotalCount = 0;
	local nTotalPlayerIndex = 1;

	local szTime	= os.date("%Y%m%d%H%M%S", GetTime());
	
	local szOutFile = "\\" .. szTime .. "_subzoneplayer.txt";
	
	local szContext = "";
	KFile.WriteFile(szOutFile, "szName\n");
	local szName = KGCPlayer.GetPlayerName(nTotalPlayerIndex);
	while szName do
		local tbInfo = GetPlayerInfoForLadderGC(szName);
		if (tbInfo and tbInfo.nLevel >= 50) then
			nCount = nCount + 1;
			nTotalCount = nTotalCount + 1;
			szContext = szContext .. szName .. "\n";
			if (nCount == 100) then
				KFile.AppendFile(szOutFile, szContext);	
				szContext = "";
				nCount = 0;
			end
		end
		nTotalPlayerIndex = nTotalPlayerIndex + 1;
		if (nTotalPlayerIndex >= 99999999) then
			break;
		end
		szName = KGCPlayer.GetPlayerName(nTotalPlayerIndex);
	end
	
	if (szContext ~= "") then
		KFile.AppendFile(szOutFile, szContext);
	end
	print("OnWriteSubZonePlayer SubPlayerNum ", nTotalCount);
	print("OnWriteSubZonePlayer end");
	return 1;
end

function GCEvent:OnCoZoneStatuary_Load()
	self.tbCoZoneStatuData = {};
	local tbLoadBuf = GetGblIntBuf(GBLINTBUF_DOMAINSTATUARY, 0);
	if (not tbLoadBuf) then
		return;
	end
	
	for _, tbInfo in pairs(tbLoadBuf) do
		local tbIn = {};
		tbIn.tbPlayerInfo = tbInfo;
		self.tbCoZoneStatuData[#self.tbCoZoneStatuData + 1] = tbIn;
	end
end

function GCEvent:OnCoZoneStepMainZone(szMainGcDb)
	print("GCEvent:OnCoZoneStepMainZone");
	--KJbExchange.DelAllBill();
	
	if (not GLOBAL_AGENT) then
		self:CozoneFactionElecet_Load();
		Union:DisbandAllUnion_GC();
		self.nCoZoneMainZoneBaZhuZhiYinState = KGblTask.SCGetDbTaskInt(DBTASK_DOMAIN_BATTLE_STEP);
		self.bCoZoneMainZoneBaZhuZhiYinGetTongAward = Domain:IsGetTongAward();
		Domain:CozoneDomain_Deal()
		-- 领土战编号记录，用于标识合服后开的第一场做判断
		local nBattleNo = KGblTask.SCGetDbTaskInt(DBTASK_DOMAIN_BATTLE_NO);
		KGblTask.SCSetDbTaskInt(DBTASK_COZONE_DOMAIN_BATTLE_NO, nBattleNo);
		self:ProcessMainKinPlant();
	end
	-- 记录主服开服时间
	local nMainServerStartTime = KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME);
	print("MainZoneStartTime", nMainServerStartTime);
	-- 计算两服开服相差时间
	local nServerTimeDistance = math.abs(self.nSubServerStartTime - nMainServerStartTime);
	if self.nSubServerStartTime < nMainServerStartTime then
		error("Error: SubZone is Earlier than MainZone!!!");
		return 0;
	end
	-- 记录两服开服相差时间
	KGblTask.SCSetDbTaskInt(DBTASK_SERVER_STARTTIME_DISTANCE, nServerTimeDistance);

	local nStart = string.find(szMainGcDb, "_");
	self.szCoZoneMainGateWay = ""; 
	if (nStart == 0) then
		self.szCoZoneMainGateWay = szMainGcDb;
	else
		self.szCoZoneMainGateWay = string.sub(szMainGcDb, 1, nStart - 1);
	end
	
	if (GLOBAL_AGENT) then
		self:OnCoZoneStepMainZone_Global();
	end
	
	return 1;
end

function GCEvent:OnCoZoneStepCombinedSub()
	print("GCEvent:OnCoZoneStepCombinedSub");
	-- 门派选举数据合并

	-- 联赛数据合并
	Ladder:LoadTotalLadders();
	Wlls:_SetWllsLeague(Wlls.LGTYPE, self.tbWllsLeagueList);
	-- 清除联赛历史榜
	for i=0, 12 do
		local tbNowLadder = GetShowLadder(Ladder:GetType(0, 3, 4, i));
		if tbNowLadder then
			DelShowLadder(Ladder:GetType(0, 3, 4, i));
		end
		
		tbNowLadder = GetShowLadder(Ladder:GetType(0, 3, 5, i));
		if tbNowLadder then
			DelShowLadder(Ladder:GetType(0, 3, 5, i));
		end
	end
	
	if (not GLOBAL_AGENT) then
		self:CozoneFactionElecet_Merge();
		Union:DisbandAllUnion_GC();

		-- 排行榜重排
		PlayerHonor:OnSchemeLoadFactionHonorLadder(); -- 门派荣誉排行榜
		PlayerHonor:OnSchemeUpdateSongJinBattleHonorLadder();	-- 宋金荣誉排行榜
		Wlls:UpdateWllsHonorLadder();
		
		PlayerHonor:UpdateWuLinHonorLadder();	-- 武林荣誉排行榜
		PlayerHonor:UpdateMoneyHonorLadder();	-- 财富荣誉排行榜
		PlayerHonor:UpdateLeaderHonorLadder();	-- 领袖荣誉排行榜
		PlayerHonor:UpdateXoyoLadder(0);		-- 逍遥荣誉榜
		PlayerHonor:UpdateFightPowerHonorLadder(); -- 战斗力排行榜
		PlayerHonor:UpdateAchievementHonorLadder(); -- 成就排行榜
		PlayerHonor:UpdateLevelHonorLadder(); -- 等级排行榜
		Ladder:DailySchedule();
		PlayerHonor:OnSchemeUpdateKaimenTaskHonorLadder();
		PlayerHonor:OnSchemeUpdateHorseFragHonorLadder();	-- 新坐骑碎片交纳榜
		KGblTask.SCSetDbTaskInt(DBTASD_HONOR_LADDER_TIME, GetTime()); -- 重置荣誉等级
		KGblTask.SCAddDbTaskInt(DBTASK_TRADE_CUR_TAX, self.nCoZoneSubZoneTax)
		KGblTask.SCAddDbTaskInt(DBTASK_COIN_EXCHANGE_PAYER, self.nCoZoneSubZoneCoinPlayer);
		KGblTask.SCAddDbTaskInt(DBTASK_COIN_EXCHANGE_PAYER_RECENT, self.nCoZoneSubZoneCoinPlayerRecent);
		KGblTask.SCAddDbTaskInt(DBTASD_WANTED_LV1_WEEKTASK_COUNT, self.nCoZoneSubZoneWanted_Now_WeekCount1); -- 本周官府通缉任务数相加
		KGblTask.SCSetDbTaskInt(DBTASD_WANTED_LV1_LASTWEEKTASK_COUNT, 0); -- 上周任务数清零
		KGblTask.SCAddDbTaskInt(DBTASD_WANTED_LV2_WEEKTASK_COUNT, self.nCoZoneSubZoneWanted_Now_WeekCount2); -- 本周官府通缉任务数相加
		KGblTask.SCSetDbTaskInt(DBTASD_WANTED_LV2_LASTWEEKTASK_COUNT, 0); -- 上周任务数清零
		KGblTask.SCAddDbTaskInt(DBTASD_WANTED_LV3_WEEKTASK_COUNT, self.nCoZoneSubZoneWanted_Now_WeekCount3); -- 本周官府通缉任务数相加
		KGblTask.SCSetDbTaskInt(DBTASD_WANTED_LV3_LASTWEEKTASK_COUNT, 0); -- 上周任务数清零
		KGblTask.SCAddDbTaskInt(DBTASD_WANTED_LV4_WEEKTASK_COUNT, self.nCoZoneSubZoneWanted_Now_WeekCount4); -- 本周官府通缉任务数相加
		KGblTask.SCSetDbTaskInt(DBTASD_WANTED_LV4_LASTWEEKTASK_COUNT, 0); -- 上周任务数清零
		KGblTask.SCAddDbTaskInt(DBTASD_WANTED_LV5_WEEKTASK_COUNT, self.nCoZoneSubZoneWanted_Now_WeekCount5); -- 本周官府通缉任务数相加
		KGblTask.SCSetDbTaskInt(DBTASD_WANTED_LV5_LASTWEEKTASK_COUNT, 0); -- 上周任务数清零
		KGblTask.SCAddDbTaskInt(DBTASD_WANTED_LV6_WEEKTASK_COUNT, self.nCoZoneSubZoneWanted_Now_WeekCount6); -- 本周官府通缉任务数相加
		KGblTask.SCSetDbTaskInt(DBTASD_WANTED_LV6_LASTWEEKTASK_COUNT, 0); -- 上周任务数清零
		KGblTask.SCSetDbTaskInt(DBTASK_HOMELAND_FIRST_OPEN, 0); -- 家园重排
		KGblTask.SCSetDbTaskInt(DBTASK_OFFICIAL_MAINTAIN_NO_SUB, self.nCoZoneSubZoneGuanXianNo); -- 保存从服领土官衔流水号
		Domain.tbStatuary:ZoneMergeStatuary(self.tbCoZoneStatuData);	
		
		local nCaichi = KGblTask.SCGetDbTaskInt(DBTASK_BAIBAOXIANG_CAICHI)  + self.nCoZoneSubZoneBaiBaoxiangCaichi;
		if nCaichi > MAX20E then
			nCaichi = MAX20E
		end
		KGblTask.SCSetDbTaskInt(DBTASK_BAIBAOXIANG_CAICHI, nCaichi);
		
		-- 合服的时候要把最大霸主之印的人刷新一下
		local nCurMaxCount = KGblTask.SCGetDbTaskInt(DBTASK_BAZHUZHIYIN_MAX);
		if (nCurMaxCount < self.nCoZoneSubZoneBaZhuZhiYinMaxCount) then
			KGblTask.SCSetDbTaskStr(DBTASK_BAZHUZHIYIN_MAX, self.szCoZoneSubZoneBaZhuZhiYinMaxName);
			KGblTask.SCSetDbTaskInt(DBTASK_BAZHUZHIYIN_MAX, self.nCoZoneSubZoneBaZhuZhiYinMaxCount);
		end	
		
		-- 合服的时候发放霸主之印的帮会奖励
		if (3 == self.nCoZoneMainZoneBaZhuZhiYinState and 2 == self.nCoZoneSubZoneBaZhuZhiYinState) then
			-- 主服务器活动结束并且已经发放帮会奖励，而子服务器活动没有没有
			if (1 == self.bCoZoneMainZoneBaZhuZhiYinGetTongAward) then
				Domain.tbStatuary:AddStatuaryCompetence(self.szCoZoneSubZoneBaZhuZhiYinMaxName, Domain.tbStatuary.TYPE_EVENT_NORMAL);
				Domain:CozoneGetTongAward();
			end
		elseif (3 == self.nCoZoneMainZoneBaZhuZhiYinState and 3 == self.nCoZoneSubZoneBaZhuZhiYinState) then
			-- 两个服务器都活动结束，但是主服务器已经发放帮会奖励，而子服务器没有
			if (1 == self.bCoZoneMainZoneBaZhuZhiYinGetTongAward and 0 == self.bCoZoneSubZoneBaZhuZhiYinGetTongAward) then
				Domain.tbStatuary:AddStatuaryCompetence(self.szCoZoneSubZoneBaZhuZhiYinMaxName, Domain.tbStatuary.TYPE_EVENT_NORMAL);
				Domain:CozoneGetTongAward();
			end
		end
		
		self:CoZoneUpdateGirlVote();
		self:CoZoneUpdateCompensateGmBuf();
		self:CoZoneUpdateKingeyesEventBuf();
		self:CoZoneUpdateArrestListBuf();
		self:CoZoneUpdateBlackListBuf();
		self:CoZoneUpdateIBShopListBuf();
		self:CoZoneUpdateWldhMemberListBuf();
		self:CoZoneUpdateVipTransferBuf();
		-- marry
		self:CoZoneUpdateProposalBuf();
		self:CoZoneUpdateMarryBuf();
		self:CoZoneUpdateMarryDevorceBuf();
		-- end
		
		self:CoZoneUpdatePresendCardListBuf();
		self:CoZoneUpdateGbWlls8RankInfoListBuf();
		
		self:CoZoneUpdateGlobalFriend();
		self:CoZoneUpdateQiXiBuf();
		self:CoZoneUpdateExpTask(); -- 经验任务撤单合并
		self:CoZoneUpdateLiJinBuf();
		self:CoZoneUpdateXoyoRankList();
		self:CoZoneUpdateOldPlayerBackBuf();
		self:CoZoneUpdateFightAfterBuf();
		self:CoZoneUpdateGirlVoteNewBuf();
		self:CoZoneUpdateLotteryBuf();
		self:CoZoneUpdateWeekFish();
		self:CoZoneUpdateTransferBuf();
		self:CoZoneUpdateKinPlant();
		self:CoZoneUpdateLottery();
		self:CoZoneUpdateKeyimenBuf();
		self:CoZoneUpdateGirlDailyBuf();
		
		local nMainFulijinghuo = KGblTask.SCGetDbTaskInt(DBTASD_EVENT_PRESIGE_RESULT);
		if (nMainFulijinghuo > self.nCoZoneSubZoneFulijinghuoWeiWang) then
			KGblTask.SCSetDbTaskInt(DBTASD_EVENT_PRESIGE_RESULT, self.nCoZoneSubZoneFulijinghuoWeiWang);
		end
		
		KGblTask.SCSetDbTaskInt(DBTASK_NEW_HORSE_OWNER, 0);
		KGblTask.SCSetDbTaskStr(DBTASK_NEW_HORSE_OWNER, "");
		KGblTask.SCSetDbTaskInt(DBTASK_SUB_SET_PLAYERSPORT, 1);
	end
	
	-- 记录并服时间
	local nTime = GetTime();
	KGblTask.SetGblInt(2, 0, nTime);
	KGblTask.SCSetDbTaskInt(DBTASK_COZONE_TIME, nTime);
	-- 这里设置是设置从服全局服玩家数据

	if (not GLOBAL_AGENT) then
		local nSDate = tonumber(os.date("%Y%m%d00", nTime));
		local nEDate = tonumber(os.date("%Y%m%d24", nTime+14*86400));
		GmCmd:Openbaihutang({S = nSDate, E = nEDate, nCount=2})
		GmCmd:Openbattle({S = nSDate, E = nEDate, nCount=3})
		GmCmd:Openfactionbattle({S = nSDate, E = nEDate, nCount=3})
		GmCmd:Openkingamecoin({S = nSDate, E = nEDate, nCount=4})
		GmCmd:Opendomainbattle({S = nSDate, E = nEDate, nCount=3});
		GmCmd:Opencangbaotu({S = nSDate, E = nEDate, nCount=2});
		GmCmd:Openxoyogamecard({S = nSDate, E = nEDate, nCount=2});
	end

	KGblTask.SCSetDbTaskStr(DBTASK_COZONE_SUB_ZONE_GATEWAY, self.szCoZoneSubGateWay);
	if (GLOBAL_AGENT) then
		self:OnCoZoneStepCombinedSub_Global();
	end

	return 1;
end

function GCEvent:CoZoneUpdateGirlVote()
	print("[GCEvent] CoZoneUpdateGirlVote start");
	local nDay = tonumber(os.date("%Y%m%d", GetTime()));
	if (nDay > 20120409) then
		print("[GCEvent] CoZoneUpdateGirlVote deadline ", nDay);
		return;
	end
	local tbGirlBuf = GetGblIntBuf(GBLINTBUF_GIRL_VOTE, 0);
	if self.tbCoZoneGirlGblBuf then
		tbGirlBuf = tbGirlBuf or {};
		for szName, tbInfo in pairs(self.tbCoZoneGirlGblBuf) do
			tbGirlBuf[szName] = tbInfo;
		end
	end
	
	SpecialEvent.Girl_Vote:SetGblBuf(tbGirlBuf);
	SetGblIntBuf(GBLINTBUF_GIRL_VOTE, 0, 0, tbGirlBuf);
	print("[GCEvent] CoZoneUpdateGirlVote end");
end

function GCEvent:CoZoneUpdateCompensateGmBuf()
	local tbGirlBuf = GetGblIntBuf(GBLINTBUF_COMPENSATE_GM, 0) or {};
	if self.tbCoZoneCompensateGmBuf then
		tbGirlBuf = tbGirlBuf or {};
		for szType, tbInfo in pairs(self.tbCoZoneCompensateGmBuf) do
			tbGirlBuf[szType] = tbGirlBuf[szType] or {};
			for szName, tbPInfo in pairs(tbInfo) do
				tbGirlBuf[szType][szName] = tbPInfo;
			end
		end
	end
	SpecialEvent.CompensateGM:SetGblBuf(tbGirlBuf);
	SetGblIntBuf(GBLINTBUF_COMPENSATE_GM, 0, 0, tbGirlBuf);	
end

function GCEvent:CoZoneUpdateKingeyesEventBuf()
	print("[CoZoneUpdateKingeyesEventBuf] start!!!");
	local tbBuf = GetGblIntBuf(GBLINTBUF_KINGEYES_EVENT, 0) or {};
	if self.tbCoZoneKingeyesEventBuf then
		for EId, tbInfo in pairs(self.tbCoZoneKingeyesEventBuf) do
			tbBuf[EId] = tbBuf[EId] or {};
			tbBuf[EId].tbPart = tbBuf[EId].tbPart or {};
			if (tbInfo.tbPart) then
				for nPId, tbPInfo in pairs(tbInfo.tbPart) do
					tbBuf[EId].tbPart[nPId] = tbPInfo;
				end
			end
		end
	end
	EventManager.KingEyes:SetGblBuf(tbBuf);
	--SetGblIntBuf(GBLINTBUF_KINGEYES_EVENT, 0, 1, tbBuf);	
end

function GCEvent:CoZoneUpdateIBShopListBuf()
	IbShop:MergeCoZoneAndMainZoneBuf(self.tbCoZoneIBShopListBuf or {});
end

function GCEvent:CoZoneUpdatePresendCardListBuf()
	PresendCard:MergeCoZoneAndMainZoneBuf(self.tbCoZonePresendCardListBuf or {});
end

function GCEvent:CoZoneUpdateGbWlls8RankInfoListBuf()
	local nMainStarFlag = KGblTask.SCGetDbTaskInt(DBTASD_GBWLLS_STARSERVER_RANK);
	local nMainStarTime = KGblTask.SCGetDbTaskInt(DBTASD_GBWLLS_STARSERVER_RANK_TIME);
	
	print("[GCEvent] GbWlls Combine Main and Sub ", nMainStarFlag, nMainStarTime, self.nCoZoneGbWlls_StarServerRank, self.nCoZoneGbWlls_StarServerTime);
	
	if (self.nCoZoneGbWlls_StarServerRank > 0) then
		if (nMainStarFlag <= 0 or self.nCoZoneGbWlls_StarServerRank < nMainStarFlag) then
			KGblTask.SCSetDbTaskInt(DBTASD_GBWLLS_STARSERVER_RANK, self.nCoZoneGbWlls_StarServerRank);
			KGblTask.SCSetDbTaskInt(DBTASD_GBWLLS_STARSERVER_RANK_TIME, self.nCoZoneGbWlls_StarServerTime);
		end
	end
	GbWlls:MergeCoZoneAndMainZoneBuf(self.tbCoZoneGbWlls8RankInfoBuf or {});
end

function GCEvent:CoZoneUpdateWldhMemberListBuf()
	Wldh.Qualification:MergeCoZoneAndMainZoneBuffer(self.tbCoZoneWldhMemberListBuf or {});
end

function GCEvent:CoZoneUpdateArrestListBuf()
	GM.BatchArrest:CoZoneUpdateArrestListBuf(self.tbCoZoneArrestListBuf or {});
end

function GCEvent:CoZoneUpdateBlackListBuf()
	SpecialEvent.HoleSolution:CoZoneUpdateBlackListBuf(self.tbCoZoneBlackListBuf or {});
end

function GCEvent:CoZoneUpdateVipTransferBuf()
	VipPlayer.VipReborn:CombineBuffer(self.tbCoZoneVipTransferBuf or {});
end

-- marrry
function GCEvent:CoZoneUpdateProposalBuf()
	Marry:CozoneProposalBuffer(self.tbCoZonePropopalBuf or {});
end

function GCEvent:CoZoneUpdateMarryBuf()
	Marry:CozoneGlobalBuffer(self.tbCoZoneMarryBuf or {});
end

function GCEvent:CoZoneUpdateMarryDevorceBuf()
	Marry:CoZoneMergeDivorce(self.tbCoZoneDevorceBuf or {});
end

function GCEvent:CoZoneUpdateGlobalFriend()
	Player.tbGlobalFriends:MergeGlobalFriends(self.tbCoGlobalFriend or {});
end

function GCEvent:CoZoneUpdateQiXiBuf()
	SpecialEvent.SeventhEvening:CombineMainZoneAndSubZone(self.tbSubZoneQiXiBuf or {});
end

function GCEvent:CoZoneUpdateExpTask()
	Task.TaskExp:MergeCheXiaoBuf(self.tbSubZoneExpTaskBuf);
end

function GCEvent:CoZoneUpdateLiJinBuf()
	Marry:CozoneLijinBuffer(self.tbSubZoneLiJinBuf);
end

function GCEvent:CoZoneUpdateXoyoRankList()
	XoyoGame:ProcessCoZoneAndSubZoneBuf(self.tbCoZoneXoyoKinRank or {});
end

function GCEvent:CoZoneUpdateOldPlayerBackBuf()
	SpecialEvent.tbOldPlayerBack:MergeMainAndSubBuf(self.tbCoZonePlayerBackBuf or {}, self.tbCoZonePlayerBackBuf1 or {}, self.tbCoZonePlayerBackBuf2 or {});
end

function GCEvent:CoZoneUpdateFightAfterBuf()
	FightAfter:CoZoneFightAfterBuf(self.tbCoZoneFightAfterBuf or {});
end

function GCEvent:CoZoneUpdateGirlVoteNewBuf()
	SpecialEvent.Girl_Vote_New:CoZoneGirlVoteNewBuf(self.tbCoZoneGirlVoteNewBuf or {});
end

function GCEvent:CoZoneUpdateLotteryBuf()
	NewLottery:CozoneNewLotteryBuffer(self.tbCoZoneLotteryBuf1 or {}, self.tbCoZoneLotteryBuf2 or {});
end

function GCEvent:CoZoneUpdateWeekFish()
	WeekendFish:CozoneWeekFishBuffer(self.tbCoZoneWeekFish or {});
end

function GCEvent:CoZoneUpdateTransferBuf()
	SpecialEvent.tbRoleTransfer:CoZoneUpdateTransferBuf(self.tbCoZoneTransferBuf or {});
	SpecialEvent.tbRoleTransfer:CoZoneUpdateTransferFailedBuf(self.tbCoZoneTransferBufFail or {});
end

function GCEvent:CoZoneUpdateKinPlant()
	KinPlant:CoZoneUpdateKinPlant(self.tbCoZoneMainKinPlant, self.tbCoZoneSubKinPlant);
end

function GCEvent:CoZoneUpdateLottery()
	Lottery:CoZoneUpdateLottery(self.tbCoZoneSubLotteryBuf);
end

function GCEvent:CoZoneUpdateKeyimenBuf()
	Keyimen:CoZoneUpdateKeyimenBuf(self.tbCoZoneKeyimenBuf or {});
end

function GCEvent:CoZoneUpdateGirlDailyBuf()
	SpecialEvent.Girl_Vote:CoZoneUpdateGirlDailyBuf(self.tbCoZoneGirlDaily or {});
end

-- end

-- 加载数据进表里缓存
function GCEvent:CozoneFactionElecet_Load()
	if not self.tbFactionLastElect then
		self.tbFactionLastElect = {};
		self.tbFactionCurElect = {};
		self.tbFactionWinner = {};
	end
	for nFaction = 1, 12 do
		if not self.tbFactionLastElect[nFaction] then
			self.tbFactionLastElect[nFaction] = {};		-- 上月侯选
			self.tbFactionCurElect[nFaction] = {};		-- 本月侯选
			self.tbFactionWinner[nFaction] = {};		-- 历届优胜
		end
		local tbList = GetLastMonthCandidate(nFaction);
		if tbList then
			self.tbFactionLastElect[nFaction] = Lib:MergeTable(self.tbFactionLastElect[nFaction], tbList);
		end
		tbList = GetCurCandidate(nFaction);
		if tbList then
			self.tbFactionCurElect[nFaction] = Lib:MergeTable(self.tbFactionCurElect[nFaction], tbList);
		end
		tbList = GetAllElectWinner(nFaction);
		if tbList then			
			self.tbFactionWinner[nFaction] = Lib:MergeTable(self.tbFactionWinner[nFaction], tbList);
		end
	end
end

-- 合并保存数据
function GCEvent:CozoneFactionElecet_Merge()
	for nFaction = 1, 12 do
		-- 合并上月候选人
		local nCount = #self.tbFactionLastElect[nFaction]
		if nCount > FactionElect.KD_FACTION_CANDIDATE_MAX then
			nCount = FactionElect.KD_FACTION_CANDIDATE_MAX;
			print("门派"..nFaction.."合并上月候选人异常，合并后数据大于储存位置，正常合并前30，列表如下")
			Lib:ShowTB(self.tbFactionLastElect[nFaction]);
		end
		for i = 1, nCount do
			local tbCandidate = self.tbFactionLastElect[nFaction][i]
			local nPlayerId = KGCPlayer.GetPlayerIdByName(tbCandidate.szName)
			if nPlayerId then
				SetFactionElectRecord(FactionElect.emKFACTION_CANDIDATE_LAST_BEGIN, nFaction, i, nPlayerId);
				SetFactionElectValue(FactionElect.emKFACTION_CANDIDATE_VOTE_BEGIN + i - 1, nFaction, 0)
			end
			print("[GCEvent] CozoneFactionElecet_Merge Vote Num", tbCandidate.szName, nPlayerId, nFaction, tbCandidate.nVote);
		end
		SetFactionElectValue(FactionElect.emKFACTION_LAST_CANDIDATE_COUNT, nFaction, nCount);
		-- print("上月合并完成,结果如下:")
		-- Lib:ShowTB(GetLastMonthCandidate(nFaction));
		
		-- 合并本月候选人
		nCount = #self.tbFactionCurElect[nFaction]
		if nCount > FactionElect.KD_FACTION_CANDIDATE_MAX then
			nCount = FactionElect.KD_FACTION_CANDIDATE_MAX;
			print("门派"..nFaction.."合并本月候选人异常，合并后数据大于储存位置，正常合并前30，列表如下")
			Lib:ShowTB(self.tbFactionCurElect[nFaction]);
		end
		for i = 1, nCount do
			local tbCandidate = self.tbFactionCurElect[nFaction][i]
			SetFactionElectRecord(FactionElect.emKFACTION_CANDIDATE_CUR_BEGIN, nFaction, i, tbCandidate.nPlayerId);
		end
		SetFactionElectValue(FactionElect.emKFACTION_CANDIDATE_CUR_COUNT, nFaction, nCount);
		-- print("门派"..nFaction.."本月合并完成,结果如下:")
		-- Lib:ShowTB(GetCurCandidate(nFaction));
		--合并历届大师兄
		nCount = #self.tbFactionWinner[nFaction]
		if nCount > FactionElect.KD_FACTION_DATA_SEGMENT_LENGTH then
			nCount = FactionElect.KD_FACTION_DATA_SEGMENT_LENGTH;
			print("门派"..nFaction.."合并历届大师兄异常，合并后数据大于储存位置，正常合并前1000，列表如下")
			Lib:ShowTB(self.tbFactionWinner[nFaction]);
		end
		for i = 1, nCount do
			local tbCandidate = self.tbFactionWinner[nFaction][i]
			SetFactionElectRecord(FactionElect.emKFACTION_WINNER_RECODE_BEGIN, nFaction, i, tbCandidate.nPlayerId);
		end
		SetFactionElectValue(FactionElect.emKFACTION_WINNER_RECODE_COUNT, 1, nCount + 1);
		--print("门派"..nFaction.."历届合并完成,结果如下:")
		--Lib:ShowTB(GetAllElectWinner(nFaction));
	end
end

-- 玩家数据上线加载回调 ----

local function DescHonorJHWW(nHonor)
	if (nHonor > 1000) then
		nHonor = nHonor - 20;
	elseif (nHonor > 50) then
		nHonor = math.floor(nHonor * 0.98);
	elseif (nHonor > 1) then
		nHonor = nHonor - 1;
	else
		nHonor = 0;
	end
	-- return nHonor;
	return 0;
end

function GCEvent:DescHonorInPlayerLogin(szName, nDay)
	local nPlayerId = KGCPlayer.GetPlayerIdByName(szName);
	local nHonorJHWW =  KGCPlayer.GetPlayerPrestige(nPlayerId);
	local nHonorLXRY = GetPlayerHonorByName(szName, PlayerHonor.HONOR_CLASS_LINGXIU, 0);
	
	local nHonorMP	= GetPlayerHonorByName(szName, PlayerHonor.HONOR_CLASS_FACTION, 0);
	local nHonorSJ 	= GetPlayerHonorByName(szName, PlayerHonor.HONOR_CLASS_BATTLE, 0);
	local nHonorLS	= GetPlayerHonorByName(szName, PlayerHonor.HONOR_CLASS_WLLS, 0);

	for i = 1, nDay do
		if (nHonorJHWW > 0) then
			nHonorJHWW = DescHonorJHWW(nHonorJHWW);
		else
			break;
		end
	end
	
	local nMonth = nDay / 30;
	for i = 1, nMonth do
		if (nHonorLXRY > 0) then
			nHonorLXRY = math.floor(nHonorLXRY * 0.80);
		end
		if (nHonorMP > 0) then
			nHonorMP = math.floor(nHonorMP * 0.80);
		end
		if (nHonorLS > 0) then
			nHonorLS = math.floor(nHonorLS * 0.80);
		end
		if (nHonorSJ > 0) then
			nHonorSJ = math.floor(nHonorSJ * 0.80);
		end
	end
	
	-- KGCPlayer.SetPlayerPrestige(nPlayerId, nHonorJHWW);
	SetPlayerHonorByName(szName, PlayerHonor.HONOR_CLASS_WULIN, 0, nHonorMP + nHonorSJ + nHonorLS);
	SetPlayerHonorByName(szName, PlayerHonor.HONOR_CLASS_LINGXIU, 0, nHonorLXRY);
	
	SetPlayerHonorByName(szName, PlayerHonor.HONOR_CLASS_FACTION, 0, nHonorMP);
	SetPlayerHonorByName(szName, PlayerHonor.HONOR_CLASS_BATTLE, 0, nHonorSJ);
	SetPlayerHonorByName(szName, PlayerHonor.HONOR_CLASS_WLLS, 0, nHonorLS);
	
	for i = PlayerHonor.HONOR_CLASS_AREARBATTLE, PlayerHonor.HONOR_CLASS_KAIMENTASK do
		local nValue = GetPlayerHonorByName(szName, i, 0);
		SetPlayerHonorByName(szName, i, 0, nValue);
	end
	
	for i = 1, PlayerHonor.HONOR_CLASS_KAIMENTASK do
		SetPlayerHonorRank(nPlayerId, i, 0, 0);
	end
	

	local nValue = GetPlayerHonorByName(szName, PlayerHonor.HONOR_CLASS_EVENTPLANT_PLAYER, 0);
	SetPlayerHonorByName(szName, PlayerHonor.HONOR_CLASS_EVENTPLANT_PLAYER, 0, nValue);
	SetPlayerHonorRank(nPlayerId, PlayerHonor.HONOR_CLASS_EVENTPLANT_PLAYER, 0, 0);	
	
	for i = PlayerHonor.HONOR_CLASS_FIGHTPOWER_TOTAL, PlayerHonor.HONOR_CLASS_LADDER2 do
		local nValue = GetPlayerHonorByName(szName, i, 0);
		if i == PlayerHonor.HONOR_CLASS_LADDER1 then
			print("88888888888888***", nValue);
		end
		SetPlayerHonorByName(szName, i, 0, nValue);
		SetPlayerHonorRank(nPlayerId, i, 0, 0);	
	end
	
	Dbg:WriteLog("DescHonorInPlayerLogin", "Simp Player Login!", szName, nDay);
end