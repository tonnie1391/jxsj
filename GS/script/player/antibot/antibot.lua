-- 文件名　：antibot.lua
-- 创建者　：houxuan
-- 创建时间：2008-12-22 08:53:30

-----------------------------------------开发说明---------------------------
--	1，打分项目 存储于tbAntiBot.tbItemList，tbItemList[key] = v, v + tbAntiBot.TSK_ERR_BEGINID记录该打分项判定
--		某个玩家出现异常次数的任务变量，v + tbAntiBot.TSK_TOTAL_BEGINID 记录该打分项记录对某个玩家执行判断次数的任务变量
--  2，策略起始任务变量
--     对每一种策略，分配了从1-9十个任务变量值，起始值是tbAntiBot.STRATEGY_BEGIN = 300，第一个策略可以使用的是300-309，
--	   第二个是310-319，依次类推....
--	   每种策略有对应的序号，并且是依次递增的，前一种注册过的策略的序号是4，则新编写的策略的序号必须是5

local tbAntiBot = Player.tbAntiBot or {};
Player.tbAntiBot = tbAntiBot;

local AntiEnum = tbAntiBot.tbenum or {};
tbAntiBot.tbenum = AntiEnum;
AntiEnum.WriteLog = 1;
AntiEnum.NoWriteLog = 0;

tbAntiBot.TSKGID				= 2058;	--任务变量的groupID
tbAntiBot.TSK_MANAGEWAY			= 1;	--被处理的方式
tbAntiBot.TSK_MANAGERESULT		= 2;	

--处理的结果(0表示还未被处理，1表示已经被成功处理过，2表示被处理过但处理失败,3表示未做丢天牢的处理)
AntiEnum.NOT_EXECUTE			= 0;
AntiEnum.EXECUTE_SUCCESS		= 1;
AntiEnum.EXECUTE_FAIL			= 2;
AntiEnum.NOT_PUTIN_PRISON		= 3;

tbAntiBot.TSK_CRITICAL_TIME		= 3;	--记录玩家的得分第一次超过超过临界值时的时间(年月日)

tbAntiBot.TSK_ALL_PAY			= 4;	--玩家从首登开始到现在，账号上的充值总数
tbAntiBot.TSK_MONTIME			= 5;	--上一次统计充值的时间，以年月为单位
tbAntiBot.TSK_MONTHPAY			= 6;	--上一次统计时的充值金额

tbAntiBot.TSK_LAST_SCORE		= 7;	--记录玩家上一次的打分的实际得分值
tbAntiBot.TSK_MONEY_RECORD		= 8;	--玩家的充值超过tbAntiBot.MIN_MONEY时是否记录过，如果已经记录过就不再记录了

--DONE:新增加一个任务变量，记录获取玩家的得分时的实际得分值
tbAntiBot.TSK_ACTUAL_SCORE		= 9;	--每次打分时，获取玩家的实际得分值

--打分项目表
tbAntiBot.TSK_ERR_BEGINID		= 100;	--记录打分错误结果的起始任务变量
tbAntiBot.TSK_TOTAL_BEGINID		= 200;	--记录总的打分次数的起始任务变量

--策略起始任务变量
tbAntiBot.STRATEGY_BEGIN		= 300;	--所有的策略要使用的任务变量的起始值

------------配置项部分---------------

tbAntiBot.ENABLE_ANTIBOT		= 0;	--1表示执行反外挂系统，0表示不执行
tbAntiBot.DEFAULT_OPERATE		= 1; 	--0表示进行处理时，不丢天牢，只是写日志记录; 非0表示丢天牢并写日志(默认为0)

--保存玩家得分时，定义写入log的几种方式	
tbAntiBot.LOG_NEVER_WRITE		= 1;	--1,不写入
tbAntiBot.LOG_WRTIE_ONCE		= 2;	--2,超过临界值时写入一次，以后不再写
tbAntiBot.LOG_INTERVAL_WRITE	= 3;	--3,超过临界值以及每次和前一次保存时保存分数时相比波动5分写一次(默认为此种方式)
tbAntiBot.WRITELOG_TYPE			= tbAntiBot.LOG_INTERVAL_WRITE;		--默认为每变化几分写一次log

tbAntiBot.SCORE_INTERVAL		= 5;	--分数每变化5分(至少5分)写一次log

tbAntiBot.CRITICAL_VALUE		= 60;	--判定为外挂的百分比临界值(0~100之间)
tbAntiBot.MIN_TOTAL_COUNT		= 3;	--至少被外挂处理机制处理过3次
tbAntiBot.CRITICAL_LEVEL		= 50;	--判定为外挂后，角色等级到达50级时丢入天牢
tbAntiBot.MIN_MONEY				= 48;	--同一个账号充值累计达到48元就不进行处理，但仍旧打分

--玩家的状态
tbAntiBot.PLAYER_LOGIN				= 0;	--玩家处于正在登陆状态
tbAntiBot.Player_CHANGESERVER_LOGIN	= 1;	--玩家处于切换服务器时的登陆状态
tbAntiBot.PLAYER_LOGOUT				= 2;	--玩家正在登出
tbAntiBot.PLAYER_GAMERUNNING 		= 3;	--玩家正在游戏中

--记录获取过客户端信息的角色，以IP为主键
tbAntiBot.tbRecord 					= {}
--每天最多获取多少个
tbAntiBot.EACH_DAY_NUMBER			= 20;	--获取20个来自不同IP客户端的进程信息

--tbAntiBot下的一些子表
tbAntiBot.tbStrategy = {}


--同步调用处理函数,确认某个玩家使用外挂后，随机选择一个策略进行处理
function tbAntiBot:ApplyStrategy (pPlayer, nState, nLogFlag, nStrategyIndex)
	local tbList = self.tbStrategy.tbStrategyList;
	local nIndex = 1;
	local nListCount = #tbList;
	if (nStrategyIndex) then
		nIndex = nStrategyIndex;
	else
		nIndex = MathRandom(2, nListCount);
	end
	local tbOne = tbList[nIndex];
	pPlayer.SetTask(self.TSKGID, self.TSK_MANAGEWAY, nIndex);	--写入应用的策略
	if (nLogFlag == AntiEnum.WriteLog) then
		local szLogMsg = string.format("[反外挂]：策略应用\t账号：%s\t角色名：%s\t等级：%d\tIP地址：%s\t应用的策略：%s\t应用策略的时间：%s\t%s", pPlayer.szAccount, pPlayer.szName, pPlayer.nLevel, pPlayer.GetPlayerIpAddress(), tbOne.szName, GetLocalDate("%Y\\%m\\%d  %H:%M:%S"), tbAntiBot.tbScore:ScoreLog(pPlayer));
		pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_ANTIBOT_PROCESS, szLogMsg);
	end
	tbOne.func(tbOne.obj, pPlayer, nState, nIndex);
	return 0;	--返回0结束调用它的Timer
end

--外挂入口函数，玩家登录时，会调用此函数
function tbAntiBot:Entrance(szAccountName, szRoleName, nState)
	if (self.ENABLE_ANTIBOT == 0) then	--不做反外挂的处理，直接返回
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerByName(szRoleName);
	if (not pPlayer) then
		Dbg:Output("Player", "Cannot get player object by Rolename "..szRoleName);
		return 0;
	end;
	local nScore = self:GetRoleScore(pPlayer);
	if (nScore >= self.CRITICAL_VALUE) then		
		local nFirstTime = pPlayer.GetTask(self.TSKGID, self.TSK_CRITICAL_TIME);
		if (nFirstTime == 0) then					--第一次得分超过临界值，记录时间和得分
			local nDay = tonumber(GetLocalDate("%Y%m%d"));
			pPlayer.SetTask(self.TSKGID, self.TSK_CRITICAL_TIME, nDay);
			local szLogMsg = string.format("[反外挂]：玩家得分第一次超过临界值\t账号：%s\t角色名：%s\t等级：%d\tIP地址：%s\t得分第一次超过临界值的时间:%s\t得分：%d\t得分临界值：%d\t%s", szAccountName, szRoleName, pPlayer.nLevel, pPlayer.GetPlayerIpAddress(), GetLocalDate("%Y\\%m\\%d  %H:%M:%S"), nScore, self.CRITICAL_VALUE, tbAntiBot.tbScore:ScoreLog(pPlayer));
			pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_ANTIBOT_SCORE, szLogMsg);
		end
		self:RecordClientProInfo(pPlayer);		--获取客户端的进程信息
	else
		return 0;	 --得分小于临界值，不处理
	end
	local nResult = pPlayer.GetTask(self.TSKGID, self.TSK_MANAGERESULT);
	if (nResult == AntiEnum.EXECUTE_SUCCESS) then			--已经成功处理，不需要再进行处理
		return 0;
	end
	local nMoney = self:GetPlayerPay(pPlayer);
	if (nMoney >= self.MIN_MONEY) then
		local nDate = tonumber(GetLocalDate("%Y%m%d"));
		local nTskValue = pPlayer.GetTask(self.TSKGID, self.TSK_MONEY_RECORD);
		
		if (nDate ~= nTskValue) then		--今天还未记录过
			local szMsgLog = string.format("[反外挂]：怀疑为外挂但充值超过%d元\t账号：%s\t角色：%s\t等级：%d\tIP地址：%s\t得分：%d\t累计充值：%d元\t记录时间：%s\t不作处理\t%s", self.MIN_MONEY, pPlayer.szAccount, pPlayer.szName, pPlayer.nLevel, pPlayer.GetPlayerIpAddress(), nScore, nMoney, GetLocalDate("%Y\\%m\\%d  %H:%M:%S"), tbAntiBot.tbScore:ScoreLog(pPlayer));
			pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_ANTIBOT_PROCESS, szMsgLog);
			pPlayer.SetTask(self.TSKGID, self.TSK_MONEY_RECORD, nDate);
		end
		return 0;
	end
	
	local nWay = pPlayer.GetTask(self.TSKGID, self.TSK_MANAGEWAY);
	if (nWay == 0) then				
		if (pPlayer.nLevel < self.CRITICAL_LEVEL) then	--50级以下的玩家，固定使用策略1进行处理，50级以上的玩家，在除了策略1中的其他策略中随机选择一个进行处理。
			self:ApplyStrategy (pPlayer, nState, AntiEnum.WriteLog, 1);
		else
			self:ApplyStrategy (pPlayer, nState, AntiEnum.WriteLog);
		end
	elseif (nState == self.PLAYER_LOGIN or nState == self.Player_CHANGESERVER_LOGIN) then --只有在登录时才执行一次未执行完成的策略
		self:ApplyStrategy (pPlayer, nState, AntiEnum.NoWriteLog, nWay);
	end
	--0表示应用策略时需要写log记录使用的策略，1表示不需要记录
	return 1;
end

--TODO:修改GetPlayerPay(pPlayer)的实现，当月充值不少于48元则才不会关天牢
--得到玩家充值总金额

function tbAntiBot:GetPlayerPay(pPlayer)
	if (not pPlayer) then
		return 0;
	end
	return pPlayer.GetExtMonthPay();
end

--[[
--function tbAntiBot:GetPlayerPay(pPlayer)
--	local nAll 		= pPlayer.GetTask(self.TSKGID, self.TSK_ALL_PAY);	--累计总充值金额
--	local nLastMonth= pPlayer.GetTask(self.TSKGID, self.TSK_MONTIME);   --最近一次充值月份
--	local nLastPay	= pPlayer.GetTask(self.TSKGID, self.TSK_MONTHPAY);  --最近一次充值金额
	
--	local nThisMonth= tonumber(GetLocalDate("%Y%m"));
--	local nThisPay	= pPlayer.GetExtMonthPay();
	
--	if (nLastMonth == nThisMonth) then		--同一个月内登陆的
--		if (nThisPay == nLastPay) then
--			return nAll;
--		else								--当月统计过的充值和当月充值不相等，则需要累加到累计值		
--			nAll = nAll + (nThisPay - nLastPay);			
--		end
--	elseif (nLastMonth < nThisMonth) then	--到了新的一个月
--		nAll = nAll + nThisPay;
--		pPlayer.SetTask(self.TSKGID, self.TSK_MONTIME, nThisMonth);	--更新统计月份
--	end

--	pPlayer.SetTask(self.TSKGID, self.TSK_ALL_PAY, nAll);		--更新总的统计金额
--	pPlayer.SetTask(self.TSKGID, self.TSK_MONTHPAY, nThisPay); 	--更新当月已经统计过的充值金额
--	return nAll;
--end
--]]


--根据nResult的值，修改玩家的任务变量值，被判定为外挂的次数，总的判定次数
function tbAntiBot:OnSaveRoleScore(szAccountName, szRoleName, szItemName, bResult)
	if (self.ENABLE_ANTIBOT == 0) then	--不做反外挂的处理，直接返回
		return 0;
	end
	
	local pPlayer = KPlayer.GetPlayerByName(szRoleName);
	if (not pPlayer) then
		Dbg:Output("Player", "Cannot get player object by Rolename "..szRoleName);
		return 0;
	end;	
	local tbItemList = Player.tbAntiBot.tbScore.tbItemList;
	local tbOne = tbItemList[szItemName];
	if (not tbOne) then
		Dbg:Output("Player", szItemName.."is not in tbItemList, please check it.");
		return 0;
	end	
	--调用打分条目的保存函数来保存分值
	tbOne.fnAddScore(tbOne.obj, pPlayer, bResult, tbOne.nId);
	pcall(tbAntiBot.Entrance, tbAntiBot, szAccountName, szRoleName, self.PLAYER_GAMERUNNING);
	return 1;
end

--获取玩家的得分
function tbAntiBot:GetRoleScore(pPlayer)
	local nRetScore = 0;
	--玩家是否被判定为外挂
	if (pPlayer.GetTask(self.TSKGID, self.TSK_CRITICAL_TIME) > 0 ) then  --在某个时间被记录为外挂，得分至少为临界值
		nRetScore = self.CRITICAL_VALUE;
	end
	
	--调用打分项目自己的函数实现
	local tbList = tbAntiBot.tbScore.tbItemList;
	local nScore = 0;
	for key, tbOne in pairs(tbList) do
		nScore = nScore + tbOne.fnGetScore(tbOne.obj, pPlayer, tbOne.nId);
	end
	if (nScore > 100) then
		nScore = 100;
	end
	pPlayer.SetTask(self.TSKGID, self.TSK_ACTUAL_SCORE, nScore);
	local nLastScore = pPlayer.GetTask(self.TSKGID, self.TSK_LAST_SCORE);
	if (nLastScore == 0) then
		pPlayer.SetTask(self.TSKGID, self.TSK_LAST_SCORE, nScore);
		nLastScore = nScore;
	end
	
	--日志记录处理(被判定为外挂之后才记录)
	if (pPlayer.GetTask(self.TSKGID, self.TSK_CRITICAL_TIME) > 0 and  self.WRITELOG_TYPE == self.LOG_INTERVAL_WRITE and math.abs(nLastScore - nScore) >= self.SCORE_INTERVAL) then
		--写log
		local szLogMsg = string.format("[反外挂]：得分变化超过%d分\t账号：%s\t角色名：%s\t等级：%d\tIP地址:%s\t时间：%s\t此次得分：%d\t上一次记录时的得分：%d\t%s", self.SCORE_INTERVAL, pPlayer.szAccount, pPlayer.szName, pPlayer.nLevel, pPlayer.GetPlayerIpAddress(), GetLocalDate("%Y\\%m\\%d  %H:%M:%S"), nScore, nLastScore, tbAntiBot.tbScore:ScoreLog(pPlayer));
		pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_ANTIBOT_SCORE, szLogMsg);
		--更新上一次保存的分数
		pPlayer.SetTask(self.TSKGID, self.TSK_LAST_SCORE, nScore);
	end
	if (nScore > nRetScore) then
		nRetScore = nScore;
	end
	return nRetScore;
end

--判断是否是被反外挂系统丢进天牢的
function tbAntiBot:IsKilledByAntiBot(pPlayer)
	if (not pPlayer) then
		return 0;
	end
	if (pPlayer.GetTask(self.TSKGID, self.TSK_MANAGERESULT) == AntiEnum.EXECUTE_SUCCESS) then
		return 1;
	end
	return 0;
end

--清除玩家的数据,将玩家设置为无罪的,将会清除掉所有和反外挂相关的任务变量值
function tbAntiBot:SetPlayerInnocent(szRoleName)
	local pPlayer = KPlayer.GetPlayerByName(szRoleName);
	if (not pPlayer) then
		Dbg:Output("Player", "Cannot get player object by Rolename "..szRoleName);
		return 0;
	end;
	--local nResult = pPlayer.GetTask(self.TSKGID, self.TSK_MANAGERESULT);
	--if (not (pPlayer.GetArrestTime() ~= 0 and nResult == AntiEnum.EXECUTE_SUCCESS)) then	--确认玩家是否在天牢中
	--	Dbg:Output("Player", "player "..szRoleName.." is not in prison.");
	--	return 0;
	--end
	
	--Player:SetFree(szRoleName);
	
	local nStrategyIndex = pPlayer.GetTask(self.TSKGID, self.TSK_MANAGEWAY);
	local tbOne = self.tbStrategy.tbStrategyList[nStrategyIndex];
	if (not tbOne) then
		Dbg:Output("Player", "Get strategy by index "..nStrategyIndex.." is not exist.");
		return 1;
	end
	local szLogMsg = string.format("[反外挂]：释放玩家\t账号：%s\t角色：%s\t被判定为外挂的时间：%s\t释放的时间：%s\t使用的处理策略：%d\t", pPlayer.szAccount, pPlayer.szName, tostring(pPlayer.GetTask(self.TSKGID, self.TSK_CRITICAL_TIME)), GetLocalDate("%Y\\%m\\%d  %H:%M:%S"), nStrategyIndex);
	local szMsg1 = tbOne.fnGetLogMsg(tbOne.obj, pPlayer);
	local szMsg2 = tbAntiBot.tbScore:ScoreLog(pPlayer);
	szLogMsg = szLogMsg..szMsg1.."\t"..szMsg2;
	
	tbOne.fnClear(tbOne.obj, pPlayer);
	Player.tbAntiBot.tbScore:ClearAllScore(pPlayer);
	--清除和反外挂相关的任务变量值
	pPlayer.SetTask(self.TSKGID, self.TSK_MANAGEWAY, 0);		--处理方式
	pPlayer.SetTask(self.TSKGID, self.TSK_MANAGERESULT, 0);		--处理结果
	pPlayer.SetTask(self.TSKGID, self.TSK_CRITICAL_TIME, 0);	--判断为外挂的时间
	pPlayer.SetTask(self.TSKGID, self.TSK_LAST_SCORE, 0);		--上一次的实际得分值
	pPlayer.SetTask(self.TSKGID, self.TSK_ACTUAL_SCORE, 0);		--实际得分值
	pPlayer.SetTask(self.TSKGID, self.TSK_MONEY_RECORD, 0);		--
	pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_ANTIBOT_PROCESS, szLogMsg);
	return 2;
end

--将直接丢入天牢的玩家解救出来的接口
function tbAntiBot:SaveFromPrison(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return 0;
	end
	if (pPlayer.GetArrestTime() == 0) then	-- 玩家不在天牢中
		return 0;
	end
	Player:SetFree(pPlayer.szName);
	local szMsg = string.format("[反外挂]：释放玩家(释放直接丢天牢的角色)\t账号：%s\t角色：%s\t释放的时间：%s", me.szAccount, me.szName, GetLocalDate("%Y\\%m\\%d  %H:%M:%S"));
	pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_ANTIBOT_PROCESS, szMsg);
end

--收集客户端的进程信息，每天收集5个不相同的客户端进程信息，以IP来区分
function tbAntiBot:RecordClientProInfo(pPlayer)
	local szDate = tostring(GetLocalDate("%Y%m%d"));
	local tbCurDay = self.tbRecord[szDate];
	if (not tbCurDay) then
		for key, tbOne in pairs(self.tbRecord) do		--释放先前的表
			self.tbRecord[key] = nil;
		end
		
		tbCurDay = {};		--创建新的一天的信息记录表
		self.tbRecord[szDate] = tbCurDay;
		tbCurDay.nCount = 0;
	end
	if (tbCurDay.nCount >= self.EACH_DAY_NUMBER) then	--已经达到了记录次数，直接返回
		return 0;
	end
	local szIP = pPlayer.GetPlayerIpAddress();
	if (not szIP) then
		return 0;
	end
	--去掉IP地址中附带的端口号
	szIP = string.sub(szIP, 1, string.find(szIP, ":") - 1);
	if (tbCurDay[szIP]) then  --该IP上的进程信息已经记录过了
		return 0;
	end
	
	tbCurDay[szIP] = 1;
	tbCurDay.nCount = tbCurDay.nCount + 1;
	
	--默认获取所有进程的简单信息,如果客户端发送过来的数据过大，则有可能把玩家踢下线	
	Player.tbAntiBot.tbCProInfo:CollectClientProInfo("", pPlayer.szName);		
	return 1;
end

--玩家登陆时调用
function tbAntiBot:OnLogin(bExchangeServerComing)
	if (self.ENABLE_ANTIBOT == 0) then	--不做反外挂的处理，直接返回
		return 0;
	end
	
	local tbAntiBot = Player.tbAntiBot;
	if (tbAntiBot) then
		local nState = tbAntiBot.Player_CHANGESERVER_LOGIN;
		if (bExchangeServerComing ~= 1) then	--下线之后的登陆
			nState = tbAntiBot.PLAYER_LOGIN;
		end
		tbAntiBot.tbRecover:RecoverPlayer(me);	--恢复误判
		pcall(tbAntiBot.Entrance, tbAntiBot, me.szAccount, me.szName, nState);
	end
	return 0;
end

--玩家下线时调用
function tbAntiBot:OnLogout(szReason)
	if (self.ENABLE_ANTIBOT == 0) then	--不做反外挂的处理，直接返回
		return 0;
	end
	
	local nWay = me.GetTask(self.TSKGID, self.TSK_MANAGEWAY);
	local tbOne = self.tbStrategy.tbStrategyList[nWay];
	if (tbOne and tbOne.fnSave) then
		tbOne.fnSave(tbOne.obj, me);
	end
	return 0;
end

--注册事件
PlayerEvent:RegisterGlobal("OnLogin", Player.tbAntiBot.OnLogin, Player.tbAntiBot);

PlayerEvent:RegisterGlobal("OnLogout", Player.tbAntiBot.OnLogout, Player.tbAntiBot);
