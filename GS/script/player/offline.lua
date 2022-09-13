-- 文件名　：offline.lua
-- 创建者　：FanZai
-- 创建时间：2007-12-22 10:01:14
-- 文件说明：离线托管相关

Require("\\script\\player\\player.lua");

local tbOffline		= Player.tbOffline or {};	-- 支持重载
Player.tbOffline	= tbOffline;

tbOffline.LEVEL_MIN			= 20;		-- 小于此级别不得参与离线托管

tbOffline.TIME_MIN			= 60 * 5;	-- 离线托管敏感时间（托管小于此时间则不触发离线托管相关事件）

tbOffline.TIME_DAY_USE		= 3600 * 18;	-- 每天最大离线托管时间

tbOffline.TIME_BAJUWAN_ADD	= 3600 * 8;		-- 白驹丸增加托管时间

tbOffline.MAX_ADDEXP_ONCE	= 10 * 10000 * 10000;	-- 一次最多增加经验10E

tbOffline.POINT_ADD_PERHOUR	= 30;			-- 每小时获得精力活力

tbOffline.DEFAULTBAIJUTYPE	= 3;

tbOffline.COINLIMIT			= 99999999;

tbOffline.CHANGE_MULT		= 1.5; -- 增加经验

tbOffline.DEF_COMBINSERVER_GIVETIME = 180; -- 合服后合服奖励的天数
tbOffline.DEF_COZONE_COMPOSE_MINDAY	= 7;

tbOffline.BAIJU_DEFINE		= {		-- 各种白驹丸参数设定 -- 现在因为客户端已经不放置warelist文件，所以目前不能取到物品的价格
	{								-- 临时的只能暂定这一类价格，今后一定要改，尤其是价格变动的时候
		szName		= "Thường",	-- 名称
		nExpMultply	= 1,			-- 经验获得倍数
		nTaskId		= 1,			-- 剩余时间记录变量
		nWareId		= 1,
		nCoin		= tbOffline.COINLIMIT,
		nShowFlag	= 0,
	}, {
		szName		= "Đại",
		nExpMultply	= 1.3,
		nTaskId		= 2,
		nWareId		= 2,
		nCoin		= tbOffline.COINLIMIT,
		nShowFlag	= 0,
	}, {
		szName		= "Cường hiệu",
		nExpMultply	= 1.6,
		nTaskId		= 3,
		nWareId		= 3,
		nCoin		= tbOffline.COINLIMIT,
		nShowFlag	= 0,
	},
	{
		szName		= "Đặc hiệu",
		nExpMultply	= 2.0,
		nTaskId		= 4,
		nWareId		= 52,
		nCoin		= tbOffline.COINLIMIT,
		nShowFlag	= 0,
	},
};

tbOffline.tbBaijuInfo = {
	[1] = {szGDPL = {18, 1, 71, 1}, nCost = 36},
	[2] = {szGDPL = {18, 1, 71, 2}, nCost = 180},
	[3] = {szGDPL = {18, 1, 71, 3}, nCost = 540},
	[4] = {szGDPL = {18, 1, 71, 4}, nCost = 1480},
	};

tbOffline.MAPID_FOBID	= {
	[222]	= 1,	-- 汴京府大牢
	[223]	= 1,	-- 临安府大牢
	[399]	= 1,	-- 天牢
	[1497]	= 1,	-- 桃源入口1
	[1498]	= 1,	-- 桃源入口2
	[1499]	= 1,	-- 桃源入口3
	[1500]	= 1,	-- 桃源入口4
	[1501]	= 1,	-- 桃源入口5
	[1502]	= 1,	-- 桃源入口6
	[1503]	= 1,	-- 桃源入口7
	
};

-- 等级信息表
if (MODULE_GAMESERVER) then
	tbOffline.tbLevelInfo = {
		{
			nLevel	= 69,
			nTimeTskId	= -1,
		},
		{
			nLevel	= 79,
			nTimeTskId	= DBTASD_SERVER_SETMAXLEVEL79,
		},
		{
			nLevel	= 89,
			nTimeTskId	= DBTASD_SERVER_SETMAXLEVEL89,
		},
		{
			nLevel	= 99,
			nTimeTskId	= DBTASD_SERVER_SETMAXLEVEL99,
		},
		{
			nLevel	= 150,
			nTimeTskId	= DBTASD_SERVER_SETMAXLEVEL150,
		},
	};
end

tbOffline.TSKGID	= 5;
tbOffline.TSKID_AUTO_CLOSED			= 11;	-- 是否已禁止自动托管
tbOffline.TSKID_OFFLINE_STARTTIME	= 12;	-- 开始离线托管的时间（只记录在线托管的情况）
tbOffline.TSKID_ADD_EXP1			= 13;	-- 本次托管可以给玩家加上的经验（低于10E的数位）
tbOffline.TSKID_ADD_EXP2			= 14;	-- 本次托管可以给玩家加上的经验（10E以上的数位）
tbOffline.TSKID_WASTE_TIME			= 15;	-- 玩家因没有白驹丸浪费掉的托管时间（玩家可以用钱补上）
tbOffline.TSKID_WASTE_START_LEVEL	= 16;	-- 玩家浪费掉的托管时间起始等级
tbOffline.TSKID_WASTE_START_EXP		= 17;	-- 玩家浪费掉的托管时间起始经验
tbOffline.TSKID_USED_OFFLINE_TIME	= 18;	-- 某天已使用的离线托管时间（DayNum*3600*24+UsedTimeSec）
tbOffline.TSKID_WASTE_LEVELLIMIT	= 19;	-- 当前离线托管的最高等级
tbOffline.TSKID_WASTE_OLDMULT_LIVETIME = 20; -- 旧倍率下玩家的离线时间
tbOffline.TSKID_COZONE_GIVEOFFLINETIME_FLAG = 21; -- 合服离线托管时间奖励
tbOffline.TSKID_SERVERSTART_TIME = 22; -- 在玩家身上记录开服时间，若非0且与当前区服开服时间有偏差则补并服经验
tbOffline.TSKID_COZONE_GIVEOFFLINE_TIME = 24; -- 记录因更新前合服但又需要改变上限的标记，给已领的玩家奖励
tbOffline.TSKID_EX_OFFLINE_TIME 	= 25; -- 额外离线时间（单位分钟）
tbOffline.TSKID_TOTALUSEBAIJUTIME	= 100;	-- 玩家使用离线托管的累计总时间(给内部人员使用，检查)

tbOffline.nNowTimeDayUse 			= 0;	-- 每天能累积的离线托管时间
tbOffline.EXGIVEENDTIME				= 1260230400; -- 开始补偿因合服在服务器更新之前，但是又要修改合服奖励上限的时间

-- 比较函数
tbOffline._Cmp	= function (nNumA, nNumB)
	return nNumA < nNumB;
end

function tbOffline:OnUpdateLevelInfo()
	for key, tbLevel in ipairs(self.tbLevelInfo) do
		local nTskId = tbLevel.nTimeTskId;
		local nTime  = 0;
		if (nTskId < 0) then
			nTime = -1;
		elseif (nTskId > 0) then
			nTime = KGblTask.SCGetDbTaskInt(nTskId);
		end
		local tbLevelExp = {};
		if (nTime > 0 or nTime == -1) then
			tbLevelExp = self:CaluLevelExp(1, tbLevel.nLevel);
		end
		tbLevel.nTime = nTime;
		tbLevel.tbLevelExp = tbLevelExp;
	end
end

function tbOffline:Init()
	local bInited	= (self.tbLevelData and 1) or 0;
	
	-- 玩家各个级别 升级经验、基准经验
	self.tbLevelData	= {};
	local tbFileData	= Lib:LoadTabFile("\\setting\\player\\attrib_level.txt");
	for nRow, tbRow in ipairs(tbFileData) do
		local nLevel	= tonumber(tbRow.LEVEL);
		local nUpExp	= tonumber(tbRow.EXP_UPGRADE);
		local nBaseExp	= tonumber(tbRow.BASE_AWARD_EXP);
		local nEffect	= Player:GetLevelEffect(nLevel);
		if (nLevel) then
			self.tbLevelData[nLevel]	= {
				nUpExp		= nUpExp,
				nBaseExpSec	= nBaseExp / 60,
				nEffect		= nEffect,
			};
		end
	end

	if (bInited == 1) then
		self:_LoadBaijuCoin();
	else
		tbOffline.nDTime	= 0;
		if not GLOBAL_AGENT then
			PlayerEvent:RegisterGlobal("OnLogin", self.OnLogin, self);
		end
	end
end

-- 获得经验总值
function tbOffline:GetLevelExp(nLevel, nCurExp, nLevelLimit)
	local nExp = 0;
	if (nLevel <= 0 or nLevelLimit <= 0) then
		return 0;
	end

	if (nLevel > nLevelLimit) then
		return 0;
	end

	if (MODULE_GAMESERVER) then
		for key, tbLevel in ipairs(self.tbLevelInfo) do
			if (tbLevel.nTime == 0) then
				break;
			end
			if (nLevelLimit == tbLevel.nLevel) then
				nExp = tbLevel.tbLevelExp[nLevel];
				break;
			end
		end
	end
	if (MODULE_GAMECLIENT) then -- 客户端计算当前等级到等级上限的经验总值，每次计算
		local nLimit = me.GetTask(self.TSKGID, self.TSKID_WASTE_LEVELLIMIT);
		if (nLevelLimit > nLimit) then
			return 0;
		end
		for nCurLevel = nLevel, nLevelLimit do
			nExp = nExp + self.tbLevelData[nCurLevel].nUpExp;
		end
	end
	nExp = nExp - nCurExp;
	if (nExp < 0) then
		nExp = 0;
	end
	return nExp;
end

-- 服务端计算当前等级到等级上限的经验总值，服务端只算一次
function tbOffline:CaluLevelExp(nLowLevel, nHighLevel)
	local tbLevelTotalExp = {};
	if (nLowLevel <= 0) then
		self:WriteLog("CaluLevelExp", "nLowLevel < the really low level");
		nLowLevel = 1;
	end
	if (nHighLevel > #self.tbLevelData) then
		nHighLevel = #self.tbLevelData;
	end
	for i = nHighLevel, nLowLevel, -1 do
		local nExp = 0;
		if (self.tbLevelData[i] and self.tbLevelData[i].nUpExp) then
			nExp = self.tbLevelData[i].nUpExp
		end

		if (i == nHighLevel) then
			tbLevelTotalExp[i] = nExp;
		else
			tbLevelTotalExp[i] = nExp + tbLevelTotalExp[i + 1];
		end
	end
	return tbLevelTotalExp;
end

-- 加载白驹丸的价格
function tbOffline:_LoadBaijuCoin()
	local tbData = Lib:LoadTabFile("\\setting\\ibshop\\warelist.txt");
	assert(tbData);
	
	local nTime			= GetTime();
	local nDay			= Lib:GetLocalDay(nTime);		
	local nStartTime	= KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME);
	local nStartDay		= Lib:GetLocalDay(nStartTime);
	
	for _, tbRow in ipairs(tbData) do
		local nWareId	= tonumber(tbRow.WareId);
		for key, tbValue in pairs(self.BAIJU_DEFINE) do
			if (tbValue.nWareId == nWareId) then
				if (tbRow.nTimeFrameStartSale) then
					tbValue.nTimeFrameStartSale = tonumber(tbRow.nTimeFrameStartSale);
					self:WriteLog(tbValue.szName, "nTimeFrameStartSale", tbValue.nTimeFrameStartSale);
				end
				
				if (tbRow.nTimeFrameEndSale) then
					tbValue.nTimeFrameEndSale = tonumber(tbRow.nTimeFrameEndSale);
					self:WriteLog(tbValue.szName, "nTimeFrameEndSale", tbValue.nTimeFrameEndSale);
				end
				if (tbValue.nTimeFrameStartSale) then
					self:WriteLog("_LoadBaijuCoin", tbValue.szName, "tbValue.nTimeFrameStartSale and tbValue.nTimeFrameEndSale", tbValue.nTimeFrameStartSale, tbValue.nTimeFrameEndSale);
				end
				if (tbValue.nTimeFrameStartSale and tbValue.nTimeFrameEndSale) then
					local nStartSaleDay = nStartDay + tbValue.nTimeFrameStartSale;
					local nEndSaleDay	= nStartDay + tbValue.nTimeFrameEndSale;
					if (nDay >= nStartSaleDay and nDay <= nEndSaleDay) then
						tbValue.nCoin		= tonumber(tbRow.nOrgPrice);
						tbValue.nShowFlag	= 1;
					end
				else
					tbValue.nCoin = tonumber(tbRow.nOrgPrice);
					tbValue.nShowFlag	= 1;
				end
				
				self:WriteLog(tbValue.szName, tbValue.nCoin);
				break;
			end
		end
	end
end

function tbOffline:GetAddExp(pPlayer)
	local nAddExp1	= pPlayer.GetTask(self.TSKGID, self.TSKID_ADD_EXP1);
	local nAddExp2	= pPlayer.GetTask(self.TSKGID, self.TSKID_ADD_EXP2);
	local nAddExp	= nAddExp1 + self.MAX_ADDEXP_ONCE * nAddExp2;
	return nAddExp, nAddExp1, nAddExp2;
end

function tbOffline:SetAddExp(pPlayer, nAddExp)
	local nAddExp1	= math.mod(nAddExp, self.MAX_ADDEXP_ONCE);
	local nAddExp2	= math.floor(nAddExp / self.MAX_ADDEXP_ONCE);
	pPlayer.SetTask(self.TSKGID, self.TSKID_ADD_EXP1, nAddExp1);
	pPlayer.SetTask(self.TSKGID, self.TSKID_ADD_EXP2, nAddExp2);
end

function tbOffline:AddExp(pPlayer, nAddExp1, nAddExp2)
	if (nAddExp2 >= 1) then
		self:WriteLog("AddExp", string.format("Give player %s max exp count %d", pPlayer.szName, nAddExp2));
	end	
	for i = 1, nAddExp2 do
		pPlayer.AddExp(self.MAX_ADDEXP_ONCE);
	end
	self:WriteLog("AddExp", string.format("Give player %s exp :%d", pPlayer.szName, nAddExp1));
	pPlayer.AddExp(nAddExp1);
	pPlayer.SetTask(self.TSKGID, self.TSKID_ADD_EXP1, 0);
	pPlayer.SetTask(self.TSKGID, self.TSKID_ADD_EXP2, 0);
end

function tbOffline:OnLogin(bExchangeServer)
	-- 跨服什么都不作
	if (bExchangeServer == 1) then
		me.SyncTaskGroup(self.TSKGID);	-- 可能客户端界面尚未关闭
		return;
	end
	
	self:SyncBaiJuDefine();

	-- 补漏掉的经验
	local nAddExp, nAddExp1, nAddExp2	= self:GetAddExp(me);
	if (nAddExp > 0) then
		self:AddExp(me, nAddExp1, nAddExp2);
	end

	local bPoped	= self:ProcessOfflineTime();

	if (bPoped ~= 1) then
		self:ProcessWasteTime();
	end
end

-- 获取白驹丸的倍率 因为可能会根据玩家的下线时间不同改变倍率
function tbOffline:GetBaijuMult(nType, nLastLiveTime)
	local nMult = self.BAIJU_DEFINE[nType].nExpMultply;
	if (nLastLiveTime >= 1226444400) then -- 当离线时间是在2008年11月12日8点之前都视为用的是旧倍率
		nMult = self.BAIJU_DEFINE[nType].nExpMultply * self.CHANGE_MULT;
	end
	return nMult;
end

function tbOffline:CaluDayDefUseTime(nLastSaveTime)
	local nDayUseTime = self.TIME_DAY_USE;
	if (nLastSaveTime < 1226444400) then -- 当离线时间是在2008年11月12日8点之前都视为用的是旧倍率
		nDayUseTime = 3600 * 16;
	end
	return nDayUseTime;
end

-- 同步白驹配置到客户端
function tbOffline:SyncBaiJuDefine()
	self.nNowTimeDayUse = self:CaluDayDefUseTime(me.nLastSaveTime);
	local tbBaiDefine	= {};
	local nTime			= GetTime();
	local nDay			= Lib:GetLocalDay(nTime);		
	local nStartTime	= KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME);
	local nStartDay		= Lib:GetLocalDay(nStartTime);
	for key, tbDefine in ipairs(self.BAIJU_DEFINE) do
		-- 说明有时间限制
		local tbDe = {};
		tbDe.szName			= tbDefine.szName; 		-- 名称
		tbDe.nExpMultply	= tbDefine.nExpMultply;	-- 经验获得倍数
		tbDe.nTaskId		= tbDefine.nTaskId;		-- 剩余时间记录变量
		tbDe.nWareId		= tbDefine.nWareId;
		tbDe.nCoin			= tbDefine.nCoin;
		tbDe.nShowFlag 		= 0;
		if (tbDefine.nTimeFrameStartSale and tbDefine.nTimeFrameStartSale > 0) then
			local nStartSaleDay = nStartDay + tbDefine.nTimeFrameStartSale;
			local nEndSaleDay	= nStartDay + tbDefine.nTimeFrameEndSale;
			if (nDay >= nStartSaleDay and nDay <= nEndSaleDay) then
				tbDe.nShowFlag = 1;
			end
		else
			tbDe.nShowFlag 	= 1;
		end
		tbBaiDefine[#tbBaiDefine + 1] = tbDe;
	end
	me.CallClientScript({"Player.tbOffline:GetBaiJuDefine", tbBaiDefine, self.nNowTimeDayUse});
end

-- 记录玩家白驹使用的总时间
function tbOffline:_AddTotalTime(pPlayer, nTime)
	if (nTime <= 0) then
		return;
	end
	local nTotalTime = pPlayer.GetTask(self.TSKGID, self.TSKID_TOTALUSEBAIJUTIME) + nTime;
	pPlayer.SetTask(self.TSKGID, self.TSKID_TOTALUSEBAIJUTIME, nTotalTime);
end

function tbOffline:OnStallStateChange(nStallState)
	-- 摆摊结束后稍等片刻即下线
	Player:RegisterTimer(20 * Env.GAME_FPS, self.OnOfflineTimeout, self);
end

function tbOffline:ClearWasterValue(pPlayer)
	if (pPlayer.GetTask(self.TSKGID, self.TSKID_WASTE_TIME) <= 0) then
		return;
	end
	
	pPlayer.SetTask(self.TSKGID, self.TSKID_WASTE_TIME, 0);
	pPlayer.SetTask(self.TSKGID, self.TSKID_WASTE_START_LEVEL, 0);
	pPlayer.SetTask(self.TSKGID, self.TSKID_WASTE_START_EXP, 0);
	self:WriteLog("ClearWasterValue", "Player " .. pPlayer.szName .. " get on the level limit, so clear all waster time!");
end

-- *******获取合服优惠奖励经验，合服10天后过期*******
function tbOffline:CoZoneAddOfflineTime()
	--print("合服优惠，增加离线托管时间")
	local nRestTime = 0;
	local nNowTime = GetTime()
	local nGbCoZoneTime = KGblTask.SCGetDbTaskInt(DBTASK_COZONE_TIME); 
	local nZoneStartTime = KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME);
	local nCurZoneStartTime = me.GetTask(self.TSKGID, self.TSKID_SERVERSTART_TIME);
	local bAddExp = 0;
	if (nCurZoneStartTime ~= nZoneStartTime) then
		if (nCurZoneStartTime > 0 and nCurZoneStartTime < nZoneStartTime) then
			--bAddExp = 1; --暂时不用此判断，待去掉临时判断后开启
		end
		me.SetTask(self.TSKGID, self.TSKID_SERVERSTART_TIME, nZoneStartTime);
	end
	if nNowTime > nGbCoZoneTime and nNowTime < nGbCoZoneTime + 10 * 24 * 60 * 60 and me.nLevel >= 50 then
		local nSelfCoZoneTime = me.GetTask(self.TSKGID, self.TSKID_COZONE_GIVEOFFLINETIME_FLAG);
	--	print(nSelfCoZoneTime);
	--	print(nGbCoZoneTime);
		if nSelfCoZoneTime < nGbCoZoneTime then
			-- 如果是从服玩家
			if me.IsSubPlayer() == 1 then  -- 判断自己的名字是否在优惠列表上
				-- 加上合并的两个服的开服时间差
				nRestTime = math.max(KGblTask.SCGetDbTaskInt(DBTASK_SERVER_STARTTIME_DISTANCE), self.DEF_COZONE_COMPOSE_MINDAY * 24 * 3600);
				nRestTime = math.min(self.DEF_COMBINSERVER_GIVETIME * 24 * 3600 * 0.75, nRestTime * 0.75)
			else
				-- 主服玩家可以补偿7天奖励
				nRestTime = self.DEF_COZONE_COMPOSE_MINDAY * 0.75 * 24 * 3600;			
			end
			me.SetTask(self.TSKGID, self.TSKID_COZONE_GIVEOFFLINETIME_FLAG, GetTime());
			me.SetTask(self.TSKGID, self.TSKID_COZONE_GIVEOFFLINE_TIME, self.EXGIVEENDTIME);
			self:WriteLog("CoZoneAddOfflineTime Main", me.szName, nRestTime);	
			--- 合服奖励标记需要修改
		end
	end
	return nRestTime;
end

--额外离线时间
function tbOffline:CalcExOffLineTime()
	local nTimeSec = me.GetTask(self.TSKGID, self.TSKID_EX_OFFLINE_TIME);
	me.SetTask(self.TSKGID, self.TSKID_EX_OFFLINE_TIME, 0);
	return nTimeSec;
end

--增加额外离线时间
function tbOffline:AddExOffLineTime(nMin)
	local nTimeSec = me.GetTask(self.TSKGID, self.TSKID_EX_OFFLINE_TIME);
	me.SetTask(self.TSKGID, self.TSKID_EX_OFFLINE_TIME, nTimeSec + nMin*60);
	return 1;
end


-- 处理下线时间，返回：是否有托管报告消息弹出
function tbOffline:ProcessOfflineTime()
	if (self.MAPID_FOBID[me.nMapId] == 1) then	-- 禁止地图
		return 0;
	end
	
	local nNowTime		= self:GetTime();
	
	if (me.GetTask(self.TSKGID, self.TSKID_AUTO_CLOSED) == 1) then
		return 0;
	end
	
	if (me.nLevel < self.LEVEL_MIN) then
		return 0;
	end          

	
	-- 注：2038年以后要注意nLastTime的负号问题
	local nLastTime		= me.GetTask(self.TSKGID, self.TSKID_OFFLINE_STARTTIME);
	if (nLastTime <= 0) then	-- 上次下线之前没有在线托管，按实际下线时间计算
		nLastTime	= me.nLastSaveTime;
	else
		me.SetTask(self.TSKGID, self.TSKID_OFFLINE_STARTTIME, 0);
	end
	self:WriteLog("ProcessOfflineTime", string.format("%s Last Logout time and now login time: %d %d", me.szName, nLastTime, nNowTime));
	if (nLastTime <= 0) then	-- 此玩家第一次登入游戏
		return 0;
	end

	local nOffTime, nOffLiveTime, nTodayUsedtime, nNowDay = self:CalcOfflineTime(nNowTime, nLastTime, self.nNowTimeDayUse);
	
	self:WriteLog("ProcessOfflineTime", string.format("%s nOffLiveTime, nTodayUsedtime = %d, %d", me.szName, nOffLiveTime, nTodayUsedtime));

	-- 算出最终的离线托管有效时间
	
	-- 计算各种白驹丸效果
	local szMsg	= "";
	local nRestTime		= nOffLiveTime;
	local nTotalAddExp	= 0;
	local nTotalAddPoint= 0;
	local nCurLevel		= me.nLevel;
	local nCurExp		= me.GetExp();	
	local nLogAddTime	= 0;
	local nLevelLimit	= self:GetLevelLimit(nLastTime);
	local nExOffTime	= self:CalcExOffLineTime() + self:CoZoneAddOfflineTime(); -- ******额外时间和合服优惠*******
	
	nRestTime = nRestTime + nExOffTime;

	self:WriteLog("ProcessOfflineTime", me.szName, "nCurLevel, nCurExp, nLevelLimit ", nCurLevel, nCurExp, nLevelLimit);
	local nLevelTotalExp = self:GetLevelExp(nCurLevel, nCurExp, nLevelLimit);

	-- 这里会有问题就是可能下线时间不长，可是却有上次未补时间，所以导致有白驹丸的情况下还会跳出购买白驹丸
	if (nRestTime <= 0) then
		-- 对于满级满经验了需要做删除剩余时间
		if (nLevelTotalExp <= 0) then
			self:ClearWasterValue(me);
		end
		return 0;
	end
	
	-- 保存本日上限
	me.SetTask(self.TSKGID, self.TSKID_USED_OFFLINE_TIME, nNowDay * 3600 * 24 + nTodayUsedtime);

	
	-- 如果玩家身上已经有了使用白驹丸的时间，计算使用后的经验
	for nType = #self.BAIJU_DEFINE, 1, -1 do
		local tbBaiJu		= self.BAIJU_DEFINE[nType];
		local nBaiJuTime	= me.GetTask(self.TSKGID, tbBaiJu.nTaskId);
		local nUseBaiJuTime	= math.min(nBaiJuTime, nRestTime);
		local nMultply	= self:GetBaijuMult(nType, nLastTime);
		local nAddExp, nAddPoint, nFinalLevel, nFinalExp, nUseRestTime = self:CalcAddExp(nUseBaiJuTime, nCurLevel, nCurExp, nType, nLevelTotalExp, nMultply);
		nTotalAddExp	= nTotalAddExp + nAddExp;
		nLevelTotalExp	= nLevelTotalExp - nAddExp;
		nTotalAddPoint	= nTotalAddPoint + nAddPoint;
		nRestTime		= nRestTime - (nUseBaiJuTime - nUseRestTime);
		nBaiJuTime		= nBaiJuTime - (nUseBaiJuTime - nUseRestTime);
		nLogAddTime		= nLogAddTime + nUseBaiJuTime - nUseRestTime; 

		self:_AddTotalTime(me, nUseBaiJuTime - nUseRestTime);
		self:WriteLog("ProcessOfflineTime", string.format("Player %s use BaiJu %s , Original BaiJu Time is %d; Used Baiju Time is %d; Rest Baiju Time is %d  !", me.szName, self.BAIJU_DEFINE[nType].szName, me.GetTask(self.TSKGID, tbBaiJu.nTaskId), nUseBaiJuTime - nUseRestTime, nBaiJuTime));		
		me.SetTask(self.TSKGID, tbBaiJu.nTaskId, nBaiJuTime);
		szMsg	= string.format("<bclr=Blue>%s<bclr> %s %s<color=Yellow>%9d<color>\n",
			tbBaiJu.szName, self:GetDTimeShortDesc(nUseBaiJuTime - nUseRestTime), self:GetDTimeShortDesc(nBaiJuTime), nAddExp) .. szMsg;
		nCurLevel	= nFinalLevel;
		nCurExp		= nFinalExp;
	end
	-- 保存待加经验
	self:SetAddExp(me, nTotalAddExp);

	-- 对于满级满经验了需要做删除
	if (nLevelTotalExp <= 0) then
		self:ClearWasterValue(me);
	elseif (nRestTime > 0) then	-- 保存剩余时间
		local bNewRestTime		= 1;	-- 是否要记录本次剩余时间
		local nDefaultUseType	= self.DEFAULTBAIJUTYPE;	-- 默认玩家会使用最高等级白驹丸
		local nTotalExp 		= self:GetLevelExp(nCurLevel, nCurExp, nLevelLimit);
		local nMultply			= self:GetBaijuMult(nDefaultUseType, nLastTime);
		local nNowAddExp, nAddPoint, nFinalLevel, nFinalExp, nUseRestTime = self:CalcAddExp(nRestTime, nCurLevel, nCurExp, nDefaultUseType, nTotalExp, nMultply);
		
		local nLastWasteTime	= me.GetTask(self.TSKGID, self.TSKID_WASTE_TIME);
		if (nLastWasteTime > nRestTime) then	-- 只有当上次浪费时间比这次多的时候，才有可能超过本次获得经验
			local nWasteLevelLimit	= me.GetTask(self.TSKGID, self.TSKID_WASTE_LEVELLIMIT);
			if (nWasteLevelLimit <= 0) then
				nWasteLevelLimit = 69;
			end
			local nWasterTotalExp 	= self:GetLevelExp(nCurLevel, nCurExp, nWasteLevelLimit);
			local nLastWastLevel	= me.GetTask(self.TSKGID, self.TSKID_WASTE_START_LEVEL);
			local nLastWastExp		= me.GetTask(self.TSKGID, self.TSKID_WASTE_START_EXP);
			local nLastWasterLiveTime = me.GetTask(self.TSKGID, self.TSKID_WASTE_OLDMULT_LIVETIME);
			local nMultply			= self:GetBaijuMult(nDefaultUseType, nLastWasterLiveTime);
			local nLastWastAddExp	= self:CalcAddExp(nLastWasteTime, nLastWastLevel, nLastWastExp, nDefaultUseType, nWasterTotalExp, nMultply);
			if (nLastWastAddExp >= nNowAddExp) then	-- 过去的遗漏时间比现在的还有价值
				bNewRestTime	= 0;
				nRestTime = nLastWasteTime;
			end
		end
		if (bNewRestTime == 1) then
			me.SetTask(self.TSKGID, self.TSKID_WASTE_TIME, nRestTime);
			me.SetTask(self.TSKGID, self.TSKID_WASTE_START_LEVEL, nCurLevel);
			me.SetTask(self.TSKGID, self.TSKID_WASTE_START_EXP, nCurExp);
			me.SetTask(self.TSKGID, self.TSKID_WASTE_LEVELLIMIT, nLevelLimit);
			me.SetTask(self.TSKGID, self.TSKID_WASTE_OLDMULT_LIVETIME, nLastTime);
		end
	end
	
	self:WriteLog("ProcessOfflineTime", string.format("%s The really rest time is %d, nTotalAddExp " .. nTotalAddExp .. ", nTotalAddPoint %d !", me.szName, nLogAddTime, nTotalAddPoint));
	if (nTotalAddExp <= 0 and nTotalAddPoint <= 0) then
		return 0;
	end

	KStatLog.ModifyAdd("roleinfo", me.szName, "Tổng thời gian ủy thác", nOffLiveTime);
	
	szMsg	= string.format("           \"Uy thac roi mang\"\n" .. 
		"Ngay offline: %s\n" ..
		"Ngay online: %s\n" .. 
		"Thoi gian offline: %s\n" ..
		"Them thoi gian: %s\n" ..
		"Uy thac co hieu luc: %s\n" ..
		"Nhan kinh nghiem: <color=Yellow>%.f<color> diem\n" ..
		"Luc dau: %s\n" ..
		"Dat duoc: %s\n" ..
		"Loai   Thoi gian dung   Con   Nhan duoc\n",
		self:GetTimeDesc(nLastTime), self:GetTimeDesc(nNowTime), self:GetDTimeDesc(nOffTime), self:GetDTimeDesc(nExOffTime), self:GetDTimeDesc(nOffLiveTime),
		nTotalAddExp, self:GetLevelDesc(me.nLevel, me.GetExp()), self:GetLevelDesc(nCurLevel, nCurExp)) .. szMsg;

	if (nLevelLimit < 150 and nLevelLimit > 0) then
		szMsg = szMsg .. string.format("Bạn tiến hành ủy thác rời mạng trước khi server mở cấp <color=yellow>%d<color>, kinh nghiệm rời mạng lần này bạn chỉ có thể tăng tối đa đến cấp <color=yellow>%d<color>!\n", nLevelLimit, nLevelLimit);
	end
	Dialog:Say(szMsg, {string.format("Nhận %.f kinh nghiệm", nTotalAddExp), self.OnGetExp, self, nTotalAddPoint});
	
	return 1;
end

-- 计算托管时间
-- 返回值：nOffTime 离线时间, nOffLiveTime 有效托管时间, nTodayUsedtime 今天使用时间, nNowDay 天数
function tbOffline:CalcOfflineTime(nNowTime, nLastTime, nNowTimeDayUse)
	assert(nNowTimeDayUse and nNowTimeDayUse > 0);
	local nOffTime	= nNowTime - nLastTime;	-- 离线时间
	if (nOffTime < self.TIME_MIN) then
		-- 下线时间太短，可能是跨服或断线，忽略不计
		return 0, 0, 0, 0;
	end
	
	-- 计算有效托管时间有多长
	local nOffLiveTime		= 0;
	local nTodayUsedtime	= 0;
	local nNowDay	= Lib:GetLocalDay(nNowTime);
	local nPassDay	= nNowDay - Lib:GetLocalDay(nLastTime);	-- 经过的天数
	if (nPassDay <= 0) then	-- 没有跨天
		nTodayUsedtime	= self:GetUsedOfflineTime(nNowTime);
		if (nTodayUsedtime >= nNowTimeDayUse) then		-- 今天已经没有可用托管时间
			return 0, 0, nTodayUsedtime, nNowDay;
		end
		nOffLiveTime	= math.min(nOffTime, nNowTimeDayUse - nTodayUsedtime);
		nTodayUsedtime	= nTodayUsedtime + nOffLiveTime;
	else	-- 跨天了
		local nLastUsedtime		= self:GetUsedOfflineTime(nLastTime);
		local nLastDaySec		= Lib:GetLocalDayTime(nLastTime);
		local nNowDaySec		= Lib:GetLocalDayTime(nNowTime);
		local nLastOffLiveTime	= math.min(nNowTimeDayUse - nLastUsedtime, 3600 * 24 - nLastDaySec);
		nTodayUsedtime	= math.min(self.nNowTimeDayUse, nNowDaySec);
		nOffLiveTime	= nLastOffLiveTime + nTodayUsedtime + nNowTimeDayUse * (nPassDay - 1);
	end
	return nOffTime, nOffLiveTime, nTodayUsedtime, nNowDay;
end

function tbOffline:GetTodayRestOfflineTime()
	if (me.nLevel < self.LEVEL_MIN) then
		return 0;
	end

	local nNowTime = self:GetTime();
	if (not self.tbLevelData) then
		self:WriteLog("GetTodayRestOfflineTime", "self.tbLevelData is nil");
		return 0;
	end
	local nLimitLevel = #self.tbLevelData;
	
	if (nLimitLevel <= 0) then
		self:WriteLog("GetTodayRestOfflineTime", "self.tbLevelData is no date");
		return 0;
	end
	
	-- TODO:有一种危险就是可能没有填上限
	if (nLimitLevel > 0 and me.nLevel > nLimitLevel) then
		return 0;
	end

	if (nLimitLevel > 0 and me.nLevel == nLimitLevel and me.GetExp() + 1 >= self.tbLevelData[me.nLevel].nUpExp) then -- 说明下一等级就是上限等级
		return 0;
	end

	local nTodayRestTime	= self.nNowTimeDayUse - self:GetUsedOfflineTime(nNowTime);
	if (nTodayRestTime < 0) then
		nTodayRestTime = 0;
	end

	return nTodayRestTime;
end

-- 提示玩家补充浪费的托管时间
function tbOffline:ProcessWasteTime()
	local nWasteTime		= me.GetTask(self.TSKGID, self.TSKID_WASTE_TIME);
	local nWasteLevelLimit	= me.GetTask(self.TSKGID, self.TSKID_WASTE_LEVELLIMIT);
	local nLastWastLevel	= me.GetTask(self.TSKGID, self.TSKID_WASTE_START_LEVEL);
	local nLastWastExp		= me.GetTask(self.TSKGID, self.TSKID_WASTE_START_EXP);
	local nCurLevel			= me.nLevel;
	local nCurExp			= me.GetExp();
	local nLevelTotalExp	= self:GetLevelExp(nCurLevel, nCurExp, nWasteLevelLimit);
	local nLastWasterLiveTime = me.GetTask(self.TSKGID, self.TSKID_WASTE_OLDMULT_LIVETIME);
	local nMultply			= self:GetBaijuMult(self.DEFAULTBAIJUTYPE, nLastWasterLiveTime);
	local nNowAddExp		= self:CalcAddExp(nWasteTime, nLastWastLevel, nLastWastExp, self.DEFAULTBAIJUTYPE, nLevelTotalExp, nMultply);

	self:WriteLog("ProcessWasteTime", string.format("Player %s have nWasteTime %d, nNowAddExp " .. nNowAddExp .. " !", me.szName, nWasteTime));
	if (nWasteTime > 0 and nNowAddExp > 0) then
		me.SyncTaskGroup(self.TSKGID);	-- 打开界面之前需要同步数据
		me.CallClientScript({"UiManager:OpenWindow", "UI_TRUSTEE"});
	end
end

function tbOffline:GetPillInfo()
	local tbPillInfo	= {};
	local tbWasterInfo	= self:GetWasteInfo();
	for nType, tbBaiJu in ipairs(self.BAIJU_DEFINE) do
		local nNeedCount	= math.ceil(tbWasterInfo.nWasteTime / self.TIME_BAJUWAN_ADD);
		tbPillInfo[nType]	= {
			tbBaiJu.szName,
			tbBaiJu.nCoin,
			tbBaiJu.nExpMultply,
			nNeedCount,
			tbBaiJu.nShowFlag,
		};
	end
	
	return tbPillInfo;
end

function tbOffline:GetWasteInfo(nBaiJuType)
	if (not nBaiJuType) then -- 这里的参数可以不填，不填表示默认白驹丸的类型
		nBaiJuType = 1;
	end
	local nCurLevel		= me.nLevel;
	local nCurExp		= me.GetExp();
	local nStartLevel	= me.GetTask(self.TSKGID, self.TSKID_WASTE_START_LEVEL);
	local nStartExp		= me.GetTask(self.TSKGID, self.TSKID_WASTE_START_EXP);
	local nLevelLimit	= me.GetTask(self.TSKGID, self.TSKID_WASTE_LEVELLIMIT);
	local nWasteTime	= me.GetTask(self.TSKGID, self.TSKID_WASTE_TIME);
	local nLevelTotalExp= self:GetLevelExp(nCurLevel, nCurExp, nLevelLimit);
	local nLastWasterLiveTime = me.GetTask(self.TSKGID, self.TSKID_WASTE_OLDMULT_LIVETIME);
	local nMultply		= self:GetBaijuMult(nBaiJuType, nLastWasterLiveTime);
	local nAddExp, nAddPoint, nToLevel, nToExp, nRestTime = self:CalcAddExp(nWasteTime, nStartLevel, nStartExp, nBaiJuType, nLevelTotalExp, nMultply);
	local nEndLevel, nEndExp = self:GetFinalLevel(nCurLevel, nCurExp, nAddExp);

	local tbWasteInfo	= {
		nWasteTime		= nWasteTime - nRestTime,
		szStartLevel	= self:GetLevelShortDesc(nCurLevel, nCurExp),
		nToLevel		= nEndLevel,
		nToExp			= nEndExp,
		nAddExp			= nAddExp,
	};
	
	return tbWasteInfo;
end

function tbOffline:GetBuyInfo(nType, nCount)
	local tbBaiJu		= self.BAIJU_DEFINE[nType];
	assert(tbBaiJu.nCoin and tbBaiJu.nCoin > 0);

	local nAddTime		= self.TIME_BAJUWAN_ADD * nCount;
	local nUseBaiJuTime	= me.GetTask(self.TSKGID, self.TSKID_WASTE_TIME);
	local nLevelLimit	= me.GetTask(self.TSKGID, self.TSKID_WASTE_LEVELLIMIT);
	local nStartLevel	= me.GetTask(self.TSKGID, self.TSKID_WASTE_START_LEVEL);
	local nStartExp		= me.GetTask(self.TSKGID, self.TSKID_WASTE_START_EXP);
	
	if (nUseBaiJuTime > nAddTime) then
		nUseBaiJuTime	= nAddTime;
	end

	-- 这里算的是经验
	local nCurLevel		= me.nLevel;
	local nCurExp		= me.GetExp();
	local nLevelTotalExp= self:GetLevelExp(nCurLevel, nCurExp, nLevelLimit);
	local nLastWasterLiveTime = me.GetTask(self.TSKGID, self.TSKID_WASTE_OLDMULT_LIVETIME);
	local nMultply		= self:GetBaijuMult(nType, nLastWasterLiveTime);
	local nAddExp, nAddPoint, nToLevel, nToExp, nUseRestTime = self:CalcAddExp(nUseBaiJuTime, nStartLevel, nStartExp, nType, nLevelTotalExp, nMultply);
	local nEndLevel, nEndExp = self:GetFinalLevel(nCurLevel, nCurExp, nAddExp);
	local tbCount		= self:CalcuCount(nCount, tbBaiJu);

	local tbBuyInfo	= {
		nBuyType		= nType,
		szBuyName		= tbBaiJu.szName,
		nBuyCount		= nCount,
		tbCount			= tbCount;
		nCoinCost		= tbBaiJu.nCoin * tbCount.nCoinCount,		-- 金币花费的个数
		nBindCoinCost	= tbBaiJu.nCoin * tbCount.nBindCoinCount,	-- 绑定金币花费的个数
		nAddExp			= nAddExp,
		nAddPoint		= nAddPoint,
		szCurLevel		= self:GetLevelShortDesc(nCurLevel, nCurExp),
		szToLevel		= self:GetLevelShortDesc(nEndLevel, nEndExp),
		nRestTime		= nAddTime - (nUseBaiJuTime - nUseRestTime),
		nLevelLimit		= nLevelLimit;
	};
	
	if (tbBuyInfo.nRestTime < 0) then
		tbBuyInfo.nRestTime	= 0;
	end
	
	return tbBuyInfo;
end

function tbOffline:CalcuCount(nCount, tbBaiJu)
	local nBindCoin 		= me.nBindCoin;
	local nCoin				= me.nCoin;
	local tbCount 			= {};
	assert(tbBaiJu.nCoin and tbBaiJu.nCoin > 0);
	local nBindCoinCount	= math.floor(nBindCoin / tbBaiJu.nCoin); -- 用绑定金币能买白驹的个数
	local nTempCoinCount	= math.floor(nCoin / tbBaiJu.nCoin);
	local nCoinCount		= 0;
	if (nCount - nBindCoinCount > 0) then
		nCoinCount = nCount - nBindCoinCount;
	else
		nBindCoinCount = nCount;
	end
	if (IVER_g_nSdoVersion == 0) then		--zjq mod 09.3.2 盛大模式无法得知金币，默认最大购买
		if (nTempCoinCount >= 0 and nCoinCount > nTempCoinCount) then
			nCoinCount = nTempCoinCount;
		end
	end
	tbCount.nBindCoinCount	= nBindCoinCount;
	tbCount.nCoinCount		= nCoinCount;
	return tbCount;
end

-- 浪费掉
function tbOffline:OnWaste()
	local nWasteTime	= me.GetTask(self.TSKGID, self.TSKID_WASTE_TIME);
	Dialog:Say("Muốn sử dụng hết thời gian ủy thác không?"..self:GetDTimeDesc(nWasteTime),
		{"Phải", self.OnWaste_Sure, self}, {"Nhấn nhầm rồi", self.OnWaste_Cancle, self})
end
function tbOffline:OnWaste_Sure()
	me.SetTask(self.TSKGID, self.TSKID_WASTE_TIME, 0);
	me.SetTask(self.TSKGID, self.TSKID_WASTE_START_LEVEL, 0);
	me.SetTask(self.TSKGID, self.TSKID_WASTE_START_EXP, 0);
	me.Msg("Đã xóa thời gian ủy thác còn lại!");
end
function tbOffline:OnWaste_Cancle()
	self:ProcessWasteTime();
end

-- 给经验
function tbOffline:OnGetExp(nTotalAddPoint)
	local nAddExp, nAddExp1, nAddExp2	= self:GetAddExp(me);
	if (nAddExp > 0) then
		self:AddExp(me, nAddExp1, nAddExp2);
	end
--	me.ChangeCurMakePoint(nTotalAddPoint);
--	me.ChangeCurGatherPoint(nTotalAddPoint);
	self:ProcessWasteTime();
end

-- 补托管时间
function tbOffline:OnBuy(nType, nCount)
	if (EventManager.IVER_bOpenAccountLockNotEvent == 1) and (me.IsAccountLock() ~= 0) then
		me.Msg("Tài khoản đang khóa, không thực hiện thao tác này được!");		
		Account:OpenLockWindow(me);	
		return 0;
	end
	local tbBaiJu		= self.BAIJU_DEFINE[nType];
	local tbCount		= self:CalcuCount(nCount, tbBaiJu);
	assert(tbBaiJu.nCoin and tbBaiJu.nCoin > 0);
	local nNeedBindCoin	= tbBaiJu.nCoin * tbCount.nBindCoinCount;
	local nNeedCoin		= tbBaiJu.nCoin * tbCount.nCoinCount;
	
	local nHaveBuy		= 0;
	
	if (nNeedBindCoin > 0) then
		self:CastBindCoin(nNeedBindCoin, self.OnCastCoin, self, me, nType, tbCount.nBindCoinCount); -- 绑定金币
		nHaveBuy = 1;
	end
	self:CastIBCoin(nNeedCoin, me, nType, tbCount.nCoinCount, nHaveBuy);	
end

-- 消耗金币
function tbOffline:CastIBCoin(nCoin, pPlayer, nType, nCount, nHaveBuy)
	if (not nCount or nCount <= 0) then
		return;
	end
	
	if (self.BAIJU_DEFINE[nType].nCoin == self.COINLIMIT) then
		self:WriteLog("CastIBCoin", string.format("Player %s buy %s is wrong price!", pPlayer.szName, self.BAIJU_DEFINE[nType].szName));
		return;
	end
	--zjq mod 09.2.27 盛大模式下，不判断金币数量，直接购买
	if (IVER_g_nSdoVersion == 0) then
		if (me.nCoin < nCoin or me.nCoin == 0) then
			if (nHaveBuy == 0) then
			pPlayer.Msg("Không đủ đồng, hãy mang đủ đồng để đăng nhập lại sử dụng Bạch Câu Hoàn bổ sung hoặc bổ sung qua Kỳ Trân Các. Thời gian ủy thác này sẽ lưu lại.");
			end
			return;
		end
	end

	local nWare	= self.BAIJU_DEFINE[nType].nWareId;
	self:WriteLog("CastIBCoin", string.format("%s dùng đồng mua %d %s", pPlayer.szName, nCount, self.BAIJU_DEFINE[nType].szName));
	pPlayer.ApplyAutoBuyAndUse(nWare, nCount);
	pPlayer.CallClientScript({"Ui:ServerCall", "UI_HELPSPRITE", "OnUpdatePage_Page1"});
end

function tbOffline:CastBindCoin(nCoin, ...)
	assert(me.nBindCoin >= nCoin and nCoin > 0);
	--TODO  绑定金币
	me.AddBindCoin(-nCoin, Player.emKBINDCOIN_COST_OFFLINE);
	Lib:CallBack(arg);	-- 绑定金币扣除成功后回调
	local szLogMsg = string.format("Mua Bạch Câu Hoàn ủy thác rời mạng tốn " .. nCoin .. " khóa"..IVER_g_szCoinName);
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_BINDCOIN, szLogMsg);
	szLogMsg = string.format("Mua " .. arg[5] .. " ủy thác rời mạng" .. self.BAIJU_DEFINE[arg[4]].szName);
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_BINDCOIN, szLogMsg);
	local tbGdpl = self.tbBaijuInfo[arg[4]].szGDPL;
	Dbg:WriteLogEx(Dbg.LOG_INFO, "CostBindCoinOnLogin", me.szName, string.format("%s,%s,%s,%s,%s,%s", me.szAccount, tbGdpl[1], tbGdpl[2], tbGdpl[3], tbGdpl[4], arg[5]));
end

function tbOffline:OnCastCoin(pPlayer, nType, nCount, bNoOpenWnd)
	self:WriteLog("OnCastCoin", string.format("%s tiêu hao %d %s", pPlayer.szName, nCount, self.BAIJU_DEFINE[nType].szName));

	local nWasteTime	= pPlayer.GetTask(self.TSKGID, self.TSKID_WASTE_TIME);
	local nStartLevel	= pPlayer.GetTask(self.TSKGID, self.TSKID_WASTE_START_LEVEL);
	local nStartExp		= pPlayer.GetTask(self.TSKGID, self.TSKID_WASTE_START_EXP);
	local nLevelLimit	= pPlayer.GetTask(self.TSKGID, self.TSKID_WASTE_LEVELLIMIT);
	local nLastWasterLiveTime = me.GetTask(self.TSKGID, self.TSKID_WASTE_OLDMULT_LIVETIME);
	local nMultply		= self:GetBaijuMult(nType, nLastWasterLiveTime);
	local tbBaiJu		= self.BAIJU_DEFINE[nType];
	local nRestTime		= pPlayer.GetTask(self.TSKGID, tbBaiJu.nTaskId) + self.TIME_BAJUWAN_ADD * nCount;
	
	-- 计算现在要使用的白驹时间
	local nUseBaiJuTime	= nWasteTime;
	if (nUseBaiJuTime > nRestTime) then
		nUseBaiJuTime	= nRestTime;
	end
	
	-- 保存剩余托管时间
	nRestTime	= nRestTime - nUseBaiJuTime;
	pPlayer.SetTask(self.TSKGID, tbBaiJu.nTaskId, nRestTime);

	-- 补浪费时间
	if (nUseBaiJuTime > 0) then
		-- 记LOG
		KStatLog.ModifyAdd("roleinfo", me.szName, "Tổng thời gian ủy thác", nUseBaiJuTime);
		
		-- 加经验
		local nLevelTotalExp= self:GetLevelExp(me.nLevel, me.GetExp(), nLevelLimit);
		local nAddExp, nAddPoint, nToLevel, nToExp, nUseRestTime = self:CalcAddExp(nUseBaiJuTime, nStartLevel, nStartExp, nType, nLevelTotalExp, nMultply);
		while (nAddExp > self.MAX_ADDEXP_ONCE) do
			pPlayer.AddExp(self.MAX_ADDEXP_ONCE);
			nAddExp	= nAddExp - self.MAX_ADDEXP_ONCE;
		end
		pPlayer.AddExp(nAddExp);
		
		self:_AddTotalTime(me, nUseBaiJuTime - nUseRestTime);
		
		-- 加精力活力
--		me.ChangeCurMakePoint(nAddPoint);
--		me.ChangeCurGatherPoint(nAddPoint);
		self:WriteLog("OnCastCoin", string.format("Give %s the exp " .. nAddExp .. " and point %d.", pPlayer.szName, nAddPoint));
		
		-- 保存剩余浪费时间
		nWasteTime	= nWasteTime - (nUseBaiJuTime - nUseRestTime);
		if (nUseRestTime > 0) then -- 如果补白驹的剩余时间有多，需要加回去
			nRestTime = nRestTime + nUseRestTime;
			pPlayer.SetTask(self.TSKGID, tbBaiJu.nTaskId, nRestTime);
		end
		if ((nLevelTotalExp - nAddExp) <= 0) then
			nWasteTime = 0;
			bNoOpenWnd = 1;
		end
		
		-- 满级满经验的时候把剩余未补时间全部清了
		if (nLevelTotalExp <= 0) then
			nWasteTime = 0;
		end
		
		if (nWasteTime >= 0) then
			pPlayer.SetTask(self.TSKGID, self.TSKID_WASTE_TIME, nWasteTime);
			pPlayer.SetTask(self.TSKGID, self.TSKID_WASTE_START_LEVEL, nToLevel);
			pPlayer.SetTask(self.TSKGID, self.TSKID_WASTE_START_EXP, nToExp);
--			if (bNoOpenWnd ~= 1) then
--				self:ProcessWasteTime();	-- 再次打开界面，继续买
--			end
		else
			pPlayer.SetTask(self.TSKGID, self.TSKID_WASTE_TIME, 0);
			pPlayer.SetTask(self.TSKGID, self.TSKID_WASTE_START_LEVEL, 0);
			pPlayer.SetTask(self.TSKGID, self.TSKID_WASTE_START_EXP, 0);
		end
		
		-- 给提示
		local szMsg	= string.format("Bổ sung %s, còn %s chưa bổ sung.",
			self:GetDTimeDesc(nUseBaiJuTime - nUseRestTime), self:GetDTimeDesc(nWasteTime));
		if (nLevelLimit < 150 and nLevelLimit > 0) then
			szMsg = szMsg .. string.format("Bạn tiến hành ủy thác rời mạng trước khi server mở cấp <color=yellow>%d<color>, nên kinh nghiệm rời mạng lần này chỉ có thể tăng tối đa đến cấp <color=yellow>%d<color>!\n", nLevelLimit, nLevelLimit);
		end

		me.Msg(szMsg);
	end

	local szMsg	= string.format("Bạch Câu Hoàn %s còn: %s", tbBaiJu.szName, self:GetDTimeDesc(nRestTime));
	pPlayer.Msg(szMsg);
	pPlayer.CallClientScript({"Ui:ServerCall", "UI_HELPSPRITE", "OnUpdatePage_Page1"});
end

function tbOffline:TryOffline()
	if GLOBAL_AGENT then		-- 全局服务器禁离线挂机
		return 0;
	end
	if (self.MAPID_FOBID[me.nMapId] == 1) then	-- 禁止地图
		return 0;
	end
	
	local nStallState	= me.nStallState;
	if (nStallState ~= Player.STALL_STAT_STALL_SELL and nStallState ~= Player.STALL_STAT_OFFER_BUY) then	-- 摆摊中
		return 0;
	end

	local nTotalBaiJuTime	= 0;
	for nType, tbBaiJu in ipairs(self.BAIJU_DEFINE) do
		nTotalBaiJuTime	= nTotalBaiJuTime + me.GetTask(self.TSKGID, tbBaiJu.nTaskId);
	end
	if (nTotalBaiJuTime <= 0) then
		return 0;	-- 已经没有白驹丸时间
	end
	
	
	-- 计算可托管时间
	local nTotalLiveTime	= 0;
	local nNowTime			= self:GetTime();
	local nRestDayTime		= 3600 * 24 - Lib:GetLocalDayTime(nNowTime);
	local nDayUsedTime		= self:GetUsedOfflineTime(nNowTime);	-- 今天的已用托管时间
	local nRestDayUseTime	= self.nNowTimeDayUse - nDayUsedTime;		-- 今天的可用托管时间
	if (nRestDayUseTime >= nRestDayTime) then
		nRestDayUseTime	= nRestDayUseTime;
	end
	if (nRestDayUseTime >= nTotalBaiJuTime) then	-- 托管在当天结束
		nTotalLiveTime	= nTotalBaiJuTime;
	else
		nTotalBaiJuTime	= nTotalBaiJuTime - nRestDayUseTime;
		nTotalLiveTime	= nRestDayUseTime;
		nTotalLiveTime	= nTotalLiveTime + math.floor(nTotalBaiJuTime / self.nNowTimeDayUse) * 3600 * 24;
		nTotalLiveTime	= nTotalLiveTime + math.mod(nTotalBaiJuTime, self.nNowTimeDayUse);
	end
	
	me.SetTask(self.TSKGID, self.TSKID_OFFLINE_STARTTIME, nNowTime);
	
	self:Dbg("Begin Offline", me.szName, nTotalLiveTime);

	Player:RegisterTimer(nTotalLiveTime * Env.GAME_FPS, self.OnOfflineTimeout, self);
	
	PlayerEvent:Register("OnStallStateChange", self.OnStallStateChange, self);
	
	return 1;
end

-- 返回当前是否可以进入休眠状态
function tbOffline:CanSleep()
	if (self.MAPID_FOBID[me.nMapId] == 1) then	-- 禁止地图
		return 0;
	end
	
	local nStallState	= me.nStallState;
	if (nStallState == Player.STALL_STAT_STALL_SELL or nStallState == Player.STALL_STAT_OFFER_BUY) then	-- 摆摊中
		return 0;
	end
	
	local pNpc	= me.GetFollowNpc();
	if (pNpc) then	-- 正在跟随
		return 0;
	end
	
	return 1;
end

function tbOffline:OnOfflineTimeout()
	self:Dbg("OnOfflineTimeout", me.szName);
	me.KickOut();
	return 0;
end

-- 计算在特定情形下会获得多少经验（只算一种白驹丸）
-- 参数 nTime , nStartLevel, nStartExp, nBaiJuType, nNowLevelLimit
-- 返回 nAddExp 要加的经验, nAddPoint 要加的精力活力, nFinalLevel 最终等级, nFinalExp 最终经验, nRestTime 剩余的有效时间
function tbOffline:CalcAddExp(nTime, nStartLevel, nStartExp, nBaiJuType, nLevelTotalExp, nExpMultply)
	local nTotalLevelExp = nLevelTotalExp;
	local nRestTime	= nTime;
	if (nRestTime <= 0) then
		return 0, 0, nStartLevel, nStartExp, 0;
	end

	if (nTotalLevelExp <= 0) then
		return 0, 0, nStartLevel, nStartExp, nRestTime;
	end

	assert(nExpMultply and nExpMultply > 0);

	local nAddExp		= 0;
	local nAddPoint		= 0;
	local nFinalLevel	= #self.tbLevelData;
	local nFinalExp		= self.tbLevelData[nFinalLevel].nUpExp;
	local nCurExp		= nStartExp;

	for nCurLevel = nStartLevel, #self.tbLevelData do
		local tbCurLevel	= self.tbLevelData[nCurLevel];				-- 本级别数据
		local nCurAddExpSec	= tbCurLevel.nBaseExpSec * nExpMultply;		-- 本级别每秒的经验增加量
		local nCurRestExp	= math.min(tbCurLevel.nUpExp - nCurExp, nTotalLevelExp);				-- 本级别剩余经验

		local nCurRestTime	= math.ceil(nCurRestExp / nCurAddExpSec);	-- 升级前本级别还可以加多少秒经验
		if (nCurRestExp < 0) then	-- 经验溢出？
			Dbg:WriteLogEx(Dbg.LOG_ERROR, "Player", "tbOffline:CalcAddExp nCurRestExp < 0 ???",
				nStartLevel, nStartExp, nCurLevel, nCurExp, tbCurLevel.nUpExp);
			nCurRestTime	= 0;
		end
		local nCurAddTime	= math.min(nRestTime, nCurRestTime);	-- 实际可以加多少秒
	
		local nCurAddExp	= nCurAddExpSec * nCurAddTime;			-- 实际可以加多少经验
		local nCurAddPoint	= tbCurLevel.nEffect * self.POINT_ADD_PERHOUR * nCurAddTime / 3600;

		nCurAddExp 		= math.min(nCurAddExp, nTotalLevelExp);
		nTotalLevelExp	= nTotalLevelExp - nCurAddExp;
		nAddExp		= nAddExp + nCurAddExp;
		nAddPoint	= nAddPoint + nCurAddPoint;	
		nRestTime	= nRestTime - nCurAddTime;
		if (nCurAddExp < nCurRestExp) then	-- 还不够升级
			nFinalLevel	= nCurLevel;
			nFinalExp	= nCurExp + nCurAddExp;
			break;
		end
		
		if (nRestTime <= 0) then
			nFinalLevel	= nCurLevel;
			nFinalExp	= nCurExp + nCurAddExp;
			break;
		end
		
		if (nTotalLevelExp <= 0) then
			nFinalLevel	= nCurLevel;
			nFinalExp	= nCurExp + nCurAddExp;
			break;
		end
		
		nCurExp	= nCurAddExp - nCurRestExp;	-- 升级后，剩这么多经验
	end
	
	nAddExp		= math.floor(nAddExp);
	nAddPoint	= math.floor(nAddPoint);
	
	return nAddExp, nAddPoint, nFinalLevel, nFinalExp, nRestTime;
end

function tbOffline:GetLevelLimit(nTime)
	local nResultLevel = 69;
	for i=2, #self.tbLevelInfo do
		local nLevelTime = self.tbLevelInfo[i].nTime;
		if (nLevelTime == 0) then
			break;
		end
		if (nTime < nLevelTime) then
			break;
		elseif (nTime >= nLevelTime) then
			nResultLevel = self.tbLevelInfo[i].nLevel;
		end
	end
	return nResultLevel;
end

-- 计算当天已经使用的离线托管时间
function tbOffline:GetUsedOfflineTime(nNowTime)
	local nUsed	= me.GetTask(self.TSKGID, self.TSKID_USED_OFFLINE_TIME);
	local nDay	= Lib:GetLocalDay(nNowTime);
	if (math.floor(nUsed / (3600 * 24)) == nDay) then	-- 当天使用过
		return math.mod(nUsed, 3600 * 24);
	else
		return 0;
	end
end

-- 计算如果增加了特定经验，可以到达多少等级
--	返回：	nFinalLevel, nFinalExp
function tbOffline:GetFinalLevel(nStartLevel, nStartExp, nAddExp)
	local nCurExp	= nStartExp + nAddExp;
	for nCurLevel = nStartLevel, #self.tbLevelData do
		local tbLevel	= self.tbLevelData[nCurLevel];	-- 本级别数据
		if (nCurExp < tbLevel.nUpExp) then
			return nCurLevel, nCurExp;
		end
		
		nCurExp	= nCurExp - tbLevel.nUpExp;	-- 升级后，剩这么多经验
	end

	-- 达到等级上限
	local nFinalLevel	= #self.tbLevelData;
	local nFinalExp		= self.tbLevelData[nFinalLevel].nUpExp;
	
	return nFinalLevel, nFinalExp;
end

-- 返回时刻描述字符串
function tbOffline:GetTimeDesc(nTime)
	return os.date("<color=Yellow>%y-%m-%d,%H giờ %M phút %S giây<color>", nTime);
end

-- 返回时间定长描述字符串
function tbOffline:GetDTimeShortDesc(nDTime)
	return string.format("<color=Yellow>%8s<color>", Lib:TimeDesc(nDTime));
end

-- 返回时间完整描述字符串
function tbOffline:GetDTimeDesc(nDTime)
	return string.format("<color=Yellow>%s<color>", Lib:TimeFullDesc(nDTime));
end

-- 返回级别定长描述字符串
function tbOffline:GetLevelShortDesc(nLevel, nExp)
	return string.format("Cấp %.2f", nLevel + nExp / self.tbLevelData[nLevel].nUpExp);
end

-- 返回级别描述字符串
function tbOffline:GetLevelDesc(nLevel, nExp)
	return string.format("<color=Green>Cấp %d %.1f%%<color>", nLevel, nExp * 100 / self.tbLevelData[nLevel].nUpExp);
end

-- 包装GetTime
function tbOffline:GetTime()
	return GetTime() + self.nDTime;
end

function tbOffline:GM()
	DoScript("\\script\\player\\offline.lua");
	DoScript("\\script\\item\\class\\baijuwan.lua");
	Dialog:Say("offline GM~",
		{"Mạo danh online", self.OnLogin, self, 0},
		{"Mạo danh offline", me.SaveQuickly},
		{"Thiết lập thời gian lệch", Dialog.AskString, Dialog, "Nhập vào số giây di chuyển yêu cầu+/-", 10, self.GM_DTime, self},
		{"Cho Bạch Câu", self.GM_Get, self},
		"over");
end

function tbOffline:GM_DTime(szDTime)
	self.nDTime	= self.nDTime + Lib:Str2Val(szDTime);
	local szMsg	= string.format("Thời gian lệch %s%s, thời gian mô phỏng hiện tại: %s", (self.nDTime >= 0) and "+" or "-",
		self:GetDTimeDesc(math.abs(self.nDTime)), self:GetTimeDesc(self:GetTime()));
	me.Msg(szMsg);
	me.CallClientScript({"Player.tbOffline:SetTime", szDTime});
end

function tbOffline:SetTime(szDTime)
	self.nDTime	= self.nDTime + Lib:Str2Val(szDTime);
	local szMsg	= string.format("Thời gian lệch %s%s, thời gian mô phỏng hiện tại: %s", (self.nDTime >= 0) and "+" or "-",
		self:GetDTimeDesc(math.abs(self.nDTime)), self:GetTimeDesc(self:GetTime()));
end

function tbOffline:GM_Get()
	me.AddItem(18, 1, 71, 1);
	me.AddItem(18, 1, 71, 2);
	me.AddItem(18, 1, 71, 3);
	me.AddItem(18, 1, 71, 4);
end

-- 调试
function tbOffline:Dbg(...)
	Dbg:Output("Player", "Offline", unpack(arg));
end

function tbOffline:WriteLog(...)
	if (MODULE_GAMESERVER) then
		Dbg:WriteLogEx(Dbg.LOG_INFO, "Player", "Offline", unpack(arg));
	end
	if (MODULE_GAMECLIENT) then
		Dbg:Output("Player", "Offline", unpack(arg));
	end
end

tbOffline:Init();

if (MODULE_GAMESERVER) then
	ServerEvent:RegisterServerStartFunc(tbOffline._LoadBaijuCoin, tbOffline);
end

if (MODULE_GAMECLIENT) then
	function tbOffline:GetBaiJuDefine(tbBaiDefine, nNowTimeDayUse)
		self.nNowTimeDayUse = nNowTimeDayUse;
		self.BAIJU_DEFINE = tbBaiDefine;
	end
end

--houxuan
function tbOffline:GetLeftBaiJuTime(pPlayer)
	--获取当前每种白驹的剩余时间,依次是小白，大白，强白，特白,以秒为单位
	local nLeftBaiJuTime = 0;
	for nIndex, v in ipairs(self.BAIJU_DEFINE) do
		nLeftBaiJuTime = nLeftBaiJuTime + pPlayer.GetTask(self.TSKGID, v.nTaskId);
	end;
	return nLeftBaiJuTime;
end

-- 计算当天已经使用的离线托管时间
function tbOffline:GetNowDayUsedOfflineTime(pPlayer, nNowTime)
	local nUsed	= pPlayer.GetTask(self.TSKGID, self.TSKID_USED_OFFLINE_TIME);
	local nDay	= Lib:GetLocalDay(nNowTime);
	if (math.floor(nUsed / (3600 * 24)) == nDay) then	-- 当天使用过
		return math.mod(nUsed, 3600 * 24);
	else
		return 0;
	end
end

function tbOffline:AddNowDayUsedTime(pPlayer, nAddTime, nNowTime)
	local nTodayUsedtime	= self:GetNowDayUsedOfflineTime(pPlayer, nNowTime);
	local nNowDay			= Lib:GetLocalDay(nNowTime);
	pPlayer.SetTask(self.TSKGID, self.TSKID_USED_OFFLINE_TIME, nNowDay * 3600 * 24 + nTodayUsedtime + nAddTime);
end

--获取当天的剩余离线修炼时间
function tbOffline:GetLeftOfflineTime(pPlayer)
	local nNowTime = self:GetTime();
	return self.TIME_DAY_USE - self:GetNowDayUsedOfflineTime(pPlayer, nNowTime);
end

function tbOffline:GetRemainBaijuTime(pPlayer)
	local tbLeftBaiJuTime = {};
	local nAllBaiJuTime = 0;
	for nIndex, v in ipairs(self.BAIJU_DEFINE) do
		tbLeftBaiJuTime[nIndex] = pPlayer.GetTask(self.TSKGID, v.nTaskId);
		nAllBaiJuTime = nAllBaiJuTime + tbLeftBaiJuTime[nIndex];
	end;
	--白驹时间用完，直接返回
	return nAllBaiJuTime;
end

function tbOffline:CheckIsFullLevel(pPlayer)
	local nCurMaxLevel = KPlayer.GetMaxLevel();
	local nAllExp = self.tbLevelData[nCurMaxLevel].nUpExp;
	local nCurExp = pPlayer.GetExp();
	if (pPlayer.nLevel >= nCurMaxLevel and nCurExp >= nAllExp) then
		--超出了等级上限，不做处理，直接返回
		return 1;
	end;
	return 0;
end

function tbOffline:AddSpecialExp(pPlayer, nTime, nStateFlag) -- nStateFlag 记录是在那种情况下使用此函数算经验, 可以不填，这里1表示在线托管
	local nNowTime = self:GetTime();
	local nUsedTime = self:GetNowDayUsedOfflineTime(pPlayer, nNowTime);
	local nLeftTime = self.TIME_DAY_USE - nUsedTime;
	if (nLeftTime < nTime) then
		return 3;
	end;
	
	--获取当前每种白驹的剩余时间,依次是小白，大白，强白，特白
	local tbLeftBaiJuTime = {};
	local nAllBaiJuTime = 0;
	for nIndex, v in ipairs(self.BAIJU_DEFINE) do
		tbLeftBaiJuTime[nIndex] = pPlayer.GetTask(self.TSKGID, v.nTaskId);
		nAllBaiJuTime = nAllBaiJuTime + tbLeftBaiJuTime[nIndex];
	end;
	--白驹时间用完，直接返回
	if (nAllBaiJuTime <= 0) then
		return 2;
	end
	
	--否则计算玩家可以得到的经验值
	local nExp = 0;
	local nSpecialTime = nTime;
	local nIndex = #tbLeftBaiJuTime;
	local nCurLevel = pPlayer.nLevel;
	local tbLevel = self.tbLevelData[nCurLevel];	--取得当前等级的基准经验值
	local nLevelBaseExp = tbLevel.nBaseExpSec  * self.CHANGE_MULT;		--离线状态下每秒钟的经验倍数
	
	while (nIndex > 0 and nSpecialTime > 0) do
		local nCurTime = tbLeftBaiJuTime[nIndex];
		local tbData = self.BAIJU_DEFINE[nIndex];
		if (nCurTime > 0) then
			if (nSpecialTime > nCurTime) then
				nExp = nExp + nCurTime * tbData.nExpMultply * nLevelBaseExp;	--时间？分？秒？
				nSpecialTime = nSpecialTime - nCurTime;
				tbLeftBaiJuTime[nIndex] = 0;
			else
				nExp = nExp + nSpecialTime * tbData.nExpMultply * nLevelBaseExp;
				tbLeftBaiJuTime[nIndex] = nCurTime - nSpecialTime;
				nSpecialTime = 0;
			end;
		end;
		nIndex  = nIndex - 1;
	end;
	nExp = math.floor(nExp);
	
	--看是否超出当前的等级上限
	local nCurMaxLevel = KPlayer.GetMaxLevel();
	local nAllExp = self.tbLevelData[nCurMaxLevel].nUpExp;
	local nCurExp = pPlayer.GetExp();
	if (nCurExp + nExp > nAllExp) then
		--超出了等级上限，不做处理，直接返回
		return 1;
	end;
	
	--没有超出则给玩家加经验，减去白驹时间
	pPlayer.AddExp(nExp);
	
	if (nStateFlag and nStateFlag == 1) then
		Player.tbOnlineExp:GiveExpInfo(pPlayer, nExp);
	end
	
	--修改各种白驹的时间
	for nIndex, v in ipairs(self.BAIJU_DEFINE) do
		local nBaiJuTime = pPlayer.GetTask(self.TSKGID, v.nTaskId);
		local nLeftTime = tbLeftBaiJuTime[nIndex];
		if (nLeftTime ~= nBaiJuTime) then
			pPlayer.SetTask(self.TSKGID, v.nTaskId, nLeftTime);
		end;
	end;
	
	--修改玩家当天的离线修炼时间
	self:AddNowDayUsedTime(pPlayer, nTime, nNowTime);
	if (nAllBaiJuTime < nTime) then
		return 2;
	end
	return 1;
end;

-- 检查是否有资格可以领因服务器在更新前合服但是有需要更改补偿上限的函数
function tbOffline:CheckExGive()
	local nRestTime = 0;
	local nNowTime = GetTime()
	local nGbCoZoneTime = KGblTask.SCGetDbTaskInt(DBTASK_COZONE_TIME); 
	local nZoneStartTime = KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME);
	local nCurZoneStartTime = me.GetTask(self.TSKGID, self.TSKID_SERVERSTART_TIME);
	local bAddExp = 0;
	if (me.IsSubPlayer() == 0) then
		return 0;
	end

	if (nNowTime < self.EXGIVEENDTIME) then
		return 0;
	end
	
	if nNowTime > nGbCoZoneTime and nNowTime < nGbCoZoneTime + 10 * 24 * 60 * 60 and me.nLevel >= 50 then
		local nSelfCoZoneTime = me.GetTask(self.TSKGID, self.TSKID_COZONE_GIVEOFFLINETIME_FLAG);
		if nSelfCoZoneTime ~= nGbCoZoneTime then
			return 0;
		end
		
		local nFlag = me.GetTask(self.TSKGID, self.TSKID_COZONE_GIVEOFFLINE_TIME);
		if (nFlag > 0 and nFlag >= self.EXGIVEENDTIME) then
			return 0;
		end
		
		return 1;
	end
	return 0;
end

function tbOffline:OnSureGetExCompensationOffline()
	if (self:CheckExGive() == 0) then
		return 0;
	end
	local bAddExp = 0;
	local nOrgWasterTime = me.GetTask(self.TSKGID, self.TSKID_WASTE_TIME);
	if bAddExp == 1 or me.IsSubPlayer() == 1 then  -- 判断自己的名字是否在优惠列表上
		-- 加上合并的两个服的开服时间差
		local nRestTime = 0;
		nRestTime = math.min(self.DEF_COMBINSERVER_GIVETIME * 24 * 3600 * 0.75, KGblTask.SCGetDbTaskInt(DBTASK_SERVER_STARTTIME_DISTANCE) * 0.75)
		nRestTime = nRestTime - 90 * 24 * 3600 * 0.75;
		if (nRestTime < 0) then
			nRestTime = 0;
		end
		if (nRestTime > 0) then
			me.SetTask(self.TSKGID, self.TSKID_WASTE_TIME, nOrgWasterTime + nRestTime)
			me.Msg(string.format("Bạn đã nhận thời gian bồi thường gộp server là %d giờ", math.floor(nRestTime / 3600)));
		end
		me.SetTask(self.TSKGID, self.TSKID_COZONE_GIVEOFFLINE_TIME, self.EXGIVEENDTIME);
		self:WriteLog("GiveExOfflineTime", me.szName, nOrgWasterTime, nRestTime, GetTime());
	end
	return 1;
end

-- 因服务器在更新前合服
-- 这个函数已经在第一次登入后领取了更新前合服奖励后才操作，这样就不用关心离线托管托管时间的潜规则了
function tbOffline:GiveExOfflineTime()
	if (self:CheckExGive() == 0) then
		return 0;
	end

	local nGbCoZoneTime = KGblTask.SCGetDbTaskInt(DBTASK_COZONE_TIME);
	local szTime = os.date("%Y-%m-%d", nGbCoZoneTime + 10 * 24 * 60 * 60);
	Dialog:Say(string.format("Bạn có thể nhận bồi thường thời gian ủy thác rời mạng khi gộp server trước khi %s, đồng ý?", szTime), 
			{
				{"Đồng ý", self.OnSureGetExCompensationOffline, self},
				{"Để suy nghĩ lại đã"},
			}
		);
end

--==================================================

-- 玩家退出挽留界面操作（购买白驹）
function tbOffline:Detain_BuyBaijuDlg()
	local szMsg = string.format(" Khi đạt cấp độ 20, bằng hữu có thể sử dụng Bạch Câu Hoàn để nhận 8 giờ ủy thác offline, tối đa 18 giờ mỗi ngày.\n Mua Bạch Câu Hoàn tại Kỳ Trân Các bằng %s hoặc %s khóa.", IVER_g_szCoinName, IVER_g_szCoinName);
	local tbOpt = {
		{string.format("Mua Bạch Câu Hoàn (36 %s khóa)", IVER_g_szCoinName), self.BuyBaiju, self, 1},
		{string.format("Mua Đại Bạch Câu Hoàn (180 %s khóa)", IVER_g_szCoinName), self.BuyBaiju, self, 2},
		{"Để ta suy nghĩ thêm"},
		};
	Dialog:Say(szMsg, tbOpt);
end

function tbOffline:BuyBaiju(nIndex)
	if (not nIndex or not self.tbBaijuInfo[nIndex]) then
		return;
	end
	
	local tbInfo = self.tbBaijuInfo[nIndex];
	if (me.CountFreeBagCell() < 1) then
		me.Msg("Hành trang không đủ 1 ô trống");
		return;
	end
	
	if (me.nBindCoin < tbInfo.nCost) then
		me.Msg(string.format("%s khóa không mang đủ, hãy quay lại khi có nhiều %s khóa hơn.", IVER_g_szCoinName, IVER_g_szCoinName));
		return;
	end
	
	if me.AddBindCoin(-tbInfo.nCost, Player.emKBINDCOIN_COST_BAIJU_LOGOUT) == 1 then
		local pItem = me.AddItem(unpack(tbInfo.szGDPL));
		if (pItem) then
			pItem.Bind(1);
			Dbg:WriteLog("Onffline", "成功购买白驹丸", tbInfo.nCost, nIndex);
		end
	end	
end

--end
