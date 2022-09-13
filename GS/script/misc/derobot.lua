-------------------------------------------------------------------
--File: derobot.lua
--Author: luobaohang
--Date: 2008-12-9 19:48
--Describe: 反外挂脚本(GS、GC)
-------------------------------------------------------------------

-- 多开限制对应时间轴
DeRobot.tbLoginLimit = 
{
	[1]  = { szTimeFrame = "OpenLevel150",	nLimit = 5 },
	[2]  = { szTimeFrame = "OpenLevel99",	nLimit = 5 },
	[3]  = { szTimeFrame = "OpenLevel89",	nLimit = 5 },
	[4]  = { szTimeFrame = nil,				nLimit = 5 },
	
	-- [1]  = { szTimeFrame = "OpenLevel150",	nLimit = 5 },
	-- [2]  = { szTimeFrame = "OpenLevel99",	nLimit = 4 },
	-- [3]  = { szTimeFrame = "OpenLevel89",	nLimit = 3 },
	-- [4]  = { szTimeFrame = nil,				nLimit = 2 },
};

--体服限制多开
if (EventManager.IVER_bOpenTiFu == 1) then
	DeRobot.tbLoginLimit = 
	{
		[1]  = { szTimeFrame = "OpenLevel150",	nLimit = 2 },
		[2]  = { szTimeFrame = "OpenLevel99",	nLimit = 2 },
		[3]  = { szTimeFrame = "OpenLevel89",	nLimit = 2 },
		[4]  = { szTimeFrame = nil,				nLimit = 2 },
	};
end

DeRobot.N_CODE = 3; -- 非法客户端判定的设1，这个设3（第一版为2）
DeRobot.tbBandHwId = DeRobot.tbBandHwId or {};
DeRobot.tbHwMulti = DeRobot.tbHwMulti or {};
DeRobot.tbIpHwMulti = DeRobot.tbIpHwMulti or {};
DeRobot.tbHwBanTimer = DeRobot.tbHwBanTimer or {};
DeRobot.tbHwBanMinTimer = DeRobot.tbHwBanTimer or {};
DeRobot.BAN_MULTI_NUM = 9;	-- 此值需>=7
DeRobot.BAN_MIN_NUM = 7;	-- 此值需>=7
DeRobot.BAN_MULTI_NUM_CLIENT = 4;	-- 禁止值（客户端报的）
DeRobot.tbPermitHwId = { [0] = 1, };
DeRobot.JUDGE_MULTI_INTERVAL = 60 * 18;	-- 多开持续多少帧再禁
DeRobot.tbBattleHwCount = {};  -- 战场多开数
DeRobot.tbNewServerTimer = {};

DeRobot.TASKGID = 2178;

DeRobot.WG_CHAT_COUNT = 5;		-- 超过此人数的关键字队聊算外挂
DeRobot.WG_ACTION_COUNT = 4;	-- 超过此人数做相同动作算外挂
DeRobot.WG_LAST_USE_DAY = 100;	-- 最后一次使用外挂的日期
DeRobot.WG_LAST_USE_SKILL = 110;		-- 最后一次使用非法技能日期
DeRobot.WG_LAST_STAIN_TIME = 101;	-- 最后一次被抓的证据点

DeRobot.bOutPutDailyWGUser = 1;

function DeRobot:OnPlayerLogout()
	local szHardWareId = me.GetHardWareId();
	if (self.tbPermitHwId[szHardWareId]) then
		return
	end
	local nCurMulti = self.tbHwMulti[szHardWareId];
	if nCurMulti and nCurMulti >= self.BAN_MULTI_NUM then
		local nRet = DeRobot:JudgeIfNotBan(self.BAN_MULTI_NUM);
		if nRet ~= 0 then
			Dbg:WriteLog("DeRobot", me.szName, szHardWareId, "NotBanFor"..nRet);
		else
			me.ForbitSet(self.N_CODE, 0);
		end
	end
end

function DeRobot:ExternJudge(nBanNum)
	local szIpMul = me.GetHardWareIdPlusIp();
	local nIphwMulti = self.tbIpHwMulti[szIpMul];
	if nIphwMulti and nIphwMulti >= nBanNum then
		return 0; -- Ban
	end
	return 1; -- Not Ban
end

function DeRobot:JudgeIfNotBan(nBanNum)
	if me.nLevel > 105 or me.nLevel > KPlayer.GetMaxLevel() - 6 then
		return 2; -- Not Ban
	end
	local nFactionReputeLevel = me.GetReputeLevel(3, me.nFaction)
	if nFactionReputeLevel and nFactionReputeLevel > 1 then
		return 3;
	end
	if me.nMonCharge > 50 then
		return 4;
	end
--	if me.GetRelationCount(2) > 2 then
--		return 5;
--	end
	-- 门派竞技支线
	return self:ExternJudge(nBanNum);
end

-- 多开数量每增加3会调此函数并传入当前多开数及ip重复数
function DeRobot:OnHwMulti(szHardWareId, szIpHw, nHardWareMulti, nIpMulti)
	local nOrgHwMulti = self.tbHwMulti[szHardWareId];
	self:SetHwMulti(szHardWareId, szIpHw, nHardWareMulti, nIpMulti)
	if (nHardWareMulti >= self.BAN_MULTI_NUM and nIpMulti >= self.BAN_MULTI_NUM) then
		if (self.tbPermitHwId[szHardWareId]) then
			return;
		end
		local nBanTimer = self.tbHwBanTimer[szHardWareId];
		if not nBanTimer then -- 没有禁过才启动timer
			print("[DeRobot]", "TimerBan_"..szHardWareId, nHardWareMulti, nIpMulti);
			nBanTimer = Timer:Register(self.JUDGE_MULTI_INTERVAL, "DeRobot:DoSyncHwMulti", szHardWareId, szIpHw);
			self.tbHwBanTimer[szHardWareId] = nBanTimer;
		end
	else
		local nBanTimer = self.tbHwBanTimer[szHardWareId];
		if (nBanTimer) then
			if (nBanTimer >= 0) then  -- 启动了timer，但还没执行
				print("[DeRobot]", "CancelBan_"..szHardWareId, nHardWareMulti, nIpMulti);
				Timer:Close(nBanTimer);
			else -- 已执行禁制，解除
				print("[DeRobot]", "UnBan_"..szHardWareId, nHardWareMulti, nIpMulti);
				GlobalExcute{"DeRobot:SetHwMulti", szHardWareId, szIpHw, nHardWareMulti, nIpMulti}
			end
			self.tbHwBanTimer[szHardWareId] = nil;			
		end
	end
	-- 7
	if (nHardWareMulti >= self.BAN_MIN_NUM and nIpMulti >= self.BAN_MIN_NUM) then
		if (self.tbPermitHwId[szHardWareId]) then
			return
		end
		local nBanTimer = self.tbHwBanMinTimer[szHardWareId];
		if not nBanTimer then -- 没有禁过才启动timer
			print("[DeRobot]", "TimerMinBan_"..szHardWareId, nHardWareMulti, nIpMulti);
			nBanTimer = Timer:Register(self.JUDGE_MULTI_INTERVAL, "DeRobot:DoSyncHwMulti", szHardWareId, szIpHw, 1);
			self.tbHwBanMinTimer[szHardWareId] = nBanTimer;
		end
	else
		local nBanTimer = self.tbHwBanMinTimer[szHardWareId];	
		if (nBanTimer) then
			if (nBanTimer >= 0) then  -- 启动了timer，但还没执行
				print("[DeRobot]", "CancelBanMin_"..szHardWareId, nHardWareMulti, nIpMulti);
				Timer:Close(nBanTimer);
			else -- 已执行禁制，解除
				print("[DeRobot]", "UnBanMin_"..szHardWareId, nHardWareMulti, nIpMulti);
				GlobalExcute{"DeRobot:SetHwMulti", szHardWareId, szIpHw, nHardWareMulti, nIpMulti}
			end
			self.tbHwBanMinTimer[szHardWareId] = nil;			
		end
	end
end

function DeRobot:DoSyncHwMulti(szHardWareId, szIpHw, bMin)
	local nHardWareMulti = self.tbHwMulti[szHardWareId];
	local nIpMulti = self.tbIpHwMulti[szIpHw];
	print("[DeRobot]", "DoBan"..szHardWareId, nHardWareMulti, nIpMulti);
	GlobalExcute{"DeRobot:SetHwMulti", szHardWareId, szIpHw, nHardWareMulti, nIpMulti};
	if bMin then
		self.tbHwBanMinTimer[szHardWareId] = -1;
	else
		self.tbHwBanTimer[szHardWareId] = -1;
	end	
	return 0;
end

function DeRobot:SetHwMulti(szHardWareId, szIpHw, nHardWareMulti, nIpMulti)
	if (self.tbPermitHwId[szHardWareId]) then
		return
	end
	local nOrgHwMulti = self.tbHwMulti[szHardWareId];
	--if (not nOrgHwMulti) or nOrgHwMulti < nHardWareMulti then
		self.tbHwMulti[szHardWareId] = nHardWareMulti;
		self.tbIpHwMulti[szIpHw] = nIpMulti;
	--end	
end

function DeRobot:OnClientDetectMulti(nMulti)
	if nMulti >= self.BAN_MULTI_NUM_CLIENT then
		--me.ForbitSet(self.N_CODE, 0);
	end
end

DeRobot.tbRepairName = DeRobot.tbRepairName or {};
DeRobot.DEBAN_TIME = 1229991500;
function DeRobot:OnLoginDo(bExchange)
	local nForbitCode = me.GetTask(0, 2044);
	local nForbitTime = me.GetTask(0, 2045);
	if (nForbitCode > 0 and self.tbRepairName[me.szName] == 1) or (nForbitCode == 3 and nForbitTime > 0 and nForbitTime < self.DEBAN_TIME) then
		-- 解除封号，放出天牢
		--Player:SetFree(me);
		self.tbRepairName[me.szName] = 0;
	elseif nForbitCode == self.N_CODE then	
		Dialog:Say("Nhân vật bị khóa do đăng nhập nhiều hơn số lượng cho phép!");
		Player:RegisterTimer(18*3, DeRobot.DoKickOut, DeRobot);
	end
	
	local nLastTime = me.GetTask(self.TASKGID, DeRobot.WG_LAST_STAIN_TIME);
	for nDay, tbCatch in pairs(self.tbCatchWGList) do
		if (type(nDay) == "number" and nLastTime < tbCatch.nStainTime) then	-- 最后一次被抓的时间
			local nWDay = tonumber(os.date("%w", tbCatch.nStainTime));
			local v = self:CalcCatchValue(me, tbCatch.tbType, nDay, nWDay);
			if (v >= tbCatch.nValue) then
				self:CatchPlayer(me);
				break;
			end
		end
	end
	if (self.tbCatchWGList.nLastStainTime) then
		me.SetTask(self.TASKGID, DeRobot.WG_LAST_STAIN_TIME, self.tbCatchWGList.nLastStainTime);
	end
end

function DeRobot:DoKickOut()
	me.KickOut();
	return 0;
end

function DeRobot:OnMissionJoin(pPlayer)
	local szHardWareId, szPrintableId = pPlayer.GetHardWareId(1);
	local nCount = self.tbBattleHwCount[szHardWareId];
	if not nCount then
		nCount = 1;
	else
		nCount = nCount + 1;
	end
	self.tbBattleHwCount[szHardWareId] = nCount;
	Dbg:WriteLog("DeRobot", "BattleJoin"..nCount, pPlayer.szName, "Battle_"..szPrintableId);
end

function DeRobot:OnMissionLeave(pPlayer)
	local szHardWareId, szPrintableId = pPlayer.GetHardWareId(1);
	local nCount = self.tbBattleHwCount[szHardWareId];
	if not nCount then
		nCount = -1;
	else
		nCount = nCount - 1;
	end
	self.tbBattleHwCount[szHardWareId] = nCount;
	Dbg:WriteLog("DeRobot", "BattleLeave"..nCount, pPlayer.szName, "Battle_"..szPrintableId);
end

function DeRobot:OnMissionDeath(tbBTInfo)
	local szHardWareId = me.GetHardWareId();
	if (self.tbPermitHwId[szHardWareId]) then
		return;
	end
	local nCurMulti = self.tbHwMulti[szHardWareId];
	if nCurMulti and nCurMulti >= self.BAN_MIN_NUM then
		if tbBTInfo.nKillPlayerNum > 6 or (tbBTInfo.nBeenKilledNum + 1) % 5  ~= 0 then
			return;
		end			
		local nScore = 0;
		nScore = nScore + (tbBTInfo.nBeenKilledNum + 1) / 5 - math.floor(tbBTInfo.nKillNpcNum / 5 + tbBTInfo.nKillPlayerNum);
		nScore = nScore * 5;
		if nScore ~= 0 then
			local nRet = DeRobot:JudgeIfNotBan(self.BAN_MIN_NUM);
			if nRet ~= 0 and nRet ~= 5 then
				Dbg:WriteLog("DeRobot", me.szName, "BattleNotBanFor", nRet);	
			else
				Player.tbAntiBot:OnSaveRoleScore(me.szAccount, me.szName, "shanghui", nScore);
				Dbg:WriteLog("DeRobot", me.szName, "AddBattleScore", nScore);
			end
		end
	end
end

function DeRobot:OnFinishLinkTaskTurn()
	local szHardWareId = me.GetHardWareId();
	if (self.tbPermitHwId[szHardWareId]) then
		return
	end
	local nCurMulti = self.tbHwMulti[szHardWareId];
	if nCurMulti and nCurMulti >= self.BAN_MIN_NUM then
		local nRet = DeRobot:JudgeIfNotBan(self.BAN_MIN_NUM);
		if nRet ~= 0 then
			--Dbg:WriteLog("DeRobot", me.szName, szHardWareId, "NotBanFor"..nRet);
		else
			Player.tbAntiBot:OnSaveRoleScore(me.szAccount, me.szName, "tasklink", 10)
			--Player.tbAntiBot.tbStrategy:ImmediateAgent(me.nId);
			Dbg:WriteLog("DeRobot", me.szName, "AddLinkTaskScore");
		end
	end
end

function DeRobot:OnMerchantTask10()
	local szHardWareId = me.GetHardWareId();
	if (self.tbPermitHwId[szHardWareId]) then
		return
	end
	local nCurMulti = self.tbHwMulti[szHardWareId];
	if nCurMulti and nCurMulti >= self.BAN_MIN_NUM then
		local nRet = DeRobot:JudgeIfNotBan(self.BAN_MIN_NUM);
		if nRet ~= 0 then
			--Dbg:WriteLog("DeRobot", me.szName, szHardWareId, "NotBanFor"..nRet);
		else
			Player.tbAntiBot:OnSaveRoleScore(me.szAccount, me.szName, "shanghui", 10)
			Dbg:WriteLog("DeRobot", me.szName, "AddMerchantScore");
		end
	end
end

DeRobot.anRobotTask1 = {7, 184, 186, 187, 185, 8};
DeRobot.anRobotTask2 = {13, 175, 177, 14};
function DeRobot:OnFinishTask(nTaskId, nReferId)
	local nTask = me.GetTask(2066, 1);
	if nTask == 0 and self.anRobotTask1[1] == nReferId then
		me.SetTask(2066, 1, 2);
	elseif nTask > 0 then
		local nTask1Num = #self.anRobotTask1
		local nTask2Num = #self.anRobotTask2		
		local nRobotRefId = 0
		if nTask <= nTask1Num then -- 第一组
			nRobotRefId = self.anRobotTask1[nTask];			
		elseif nTask <= nTask1Num + nTask2Num then -- 第二组
			nRobotRefId = self.anRobotTask2[nTask - nTask1Num];
		else
			me.SetTask(2066, 1, -1);				
		end
		if nRobotRefId == nReferId then
			me.SetTask(2066, 1, nTask + 1)
		elseif nTask ~= nTask1Num + 1 then -- 不是第二组的第一个
			me.SetTask(2066, 1, -1);		
		end
		if nTask == nTask1Num + nTask2Num then -- 最后一个
			Player.tbAntiBot:OnSaveRoleScore(me.szAccount, me.szName, "roleaction", 60)
			Dbg:WriteLog("DeRobot", me.szName, "RobotLinkTask");
			me.SetTask(2066, 1, -1);
		end
	end
end

function DeRobot:gs_NewServerKick(szName)
	local pPlayer = KPlayer.GetPlayerByName(szName);
	if pPlayer then
		--pPlayer.ForbitSet(self.N_CODE, 0);
		-- 记录进入桃源的原因
		pPlayer.SetTask(SpecialEvent.HoleSolution.TASK_COMPENSATE_GROUPID, SpecialEvent.HoleSolution.TASK_SUBID_REASON, 2);
		Player:Arrest(pPlayer, 3600*24*15);
		local szMsg = szName .. "因为非法多开被关进桃源监狱。";
		pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_ANTIBOT_PROCESS, szMsg);		-- 客服日志							
		Dbg:WriteLog("DeRobot", szName, "NewServerRule");
		--pPlayer.KickOut();
	end
end

function DeRobot:gc_NewServerKick(szHardWareId, szName)
	local nPlayerServer = GCGetPlayerOnlineServer(szName);
	local nPlayerId = KGCPlayer.GetPlayerIdByName(szName);
	local szLog = "多开信息:";
	self.tbNewServerTimer[szName] = nil;
	if nPlayerServer > 0 and GCNewServerMuiOpen(szName) == 1 then
		local tbMuiInfo = GetMuiOpenPlayerList(nPlayerId);
		for _, tbInfo in ipairs(tbMuiInfo) do
			szLog = szLog .. string.format("{角色名:%s, 账号:%s, 登陆时间:%s}, ", 
				tbInfo.szName,
				tbInfo.szAccount,
				os.date("%y-%m-%d %H:%M:%S", tbInfo.nLoginTime)
			);
		end
		print(szLog);
		KGCPlayer.PlayerLog(nPlayerId, 51, szLog); -- 51 -> emKPLAYERLOG_TYPE_GM_OPERATION
		GSExcute(nPlayerServer, {"DeRobot:gs_NewServerKick", szName});
	end
	return 0;
end

function DeRobot:TellClient_LoginLimit(szName, nServerOpenDays, nLimit)
	local pPlayer = KPlayer.GetPlayerByName(szName);
	if (pPlayer) then
		pPlayer.CallClientScript({"ServerLoginLimit", GetGatewayName(), nServerOpenDays, nLimit});
	end
end

function DeRobot:AddNewServerCheck(szHardWareId, szName)
	self.tbNewServerTimer[szName] = Timer:Register(18 * MathRandom(3*60, 5*60), DeRobot.gc_NewServerKick, DeRobot, szHardWareId, szName);
end

function DeRobot:DelNewServerCheck(szHardWareId, szName)
	if (self.tbNewServerTimer[szName] == nil) then
		return;
	end
	Timer:Close(self.tbNewServerTimer[szName]);
	self.tbNewServerTimer[szName] = nil;
end

function DeRobot:GetLoginPermit(nServerOpenDays)
	local nSeverStart = tonumber(KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME));
	local nTimeStart = tonumber(os.date("%Y%m%d", nSeverStart));
	local nTimeLimit = EventManager.IVER_bOpenMutiOpenSys; -- 这个时间前开服的，都是6开限制
	if (nTimeStart < nTimeLimit) then
		return 6;
	end
	for i = 1, #self.tbLoginLimit do
		local szTimeFrame = self.tbLoginLimit[i].szTimeFrame;
		if (szTimeFrame and TimeFrame:GetState(szTimeFrame) == 1) then
			return self.tbLoginLimit[i].nLimit;
		end
	end
	return self.tbLoginLimit[#self.tbLoginLimit].nLimit;
end

function DeRobot:_CheckActionPlayer(tbPlayer)
	if (#tbPlayer < self.WG_ACTION_COUNT) then
		return 0;
	end
	
	local nCount = 0;
	for _, pPlayer in pairs(tbPlayer) do
		local nDoing = pPlayer.GetNpc().nDoing;
		if (nDoing >= 5 and nDoing <= 7) then
			nCount = nCount + 1;
		end
	end
	
	return ((nCount >= 1) and 1) or 0;
end

function DeRobot:CheckAllPlayer()
	local tbAttackCodePlayer = {};
	local tbMapPlayer = {};
	for _, pPlayer in pairs(KPlayer.GetAllPlayer()) do
		-- 攻击码
		if (pPlayer.nAttackCodeTimes > 5) then
			tbAttackCodePlayer[#tbAttackCodePlayer + 1] = pPlayer;
		end
		pPlayer.nAttackCodeTimes = 0;
		
		-- 同处攻击
		local x, y = pPlayer.GetNpc().GetDes();
		if (x == -1) then
			local pNpc = KNpc.GetByIndex(y);
			if (pNpc and pNpc.nIndex > 0 and pNpc.nKind == 1) then
				local szKey = string.format("%s_%d_%d", pPlayer.GetIp(), pPlayer.nMapId, y);
				local tbPlayer = tbMapPlayer[szKey] or {};
				tbMapPlayer[szKey] = tbPlayer;
				tbPlayer[#tbPlayer + 1] = pPlayer;
			end
		end
	end
	for szKey, tbPlayer in pairs(tbMapPlayer) do
		if (self:_CheckActionPlayer(tbPlayer) == 1) then
			self:AddPlayerWG(tbPlayer, 2);	-- 同地图同Ip同时攻击
		end
	end
	
	self:AddPlayerWG(tbAttackCodePlayer, 3);	-- 非法技能
end

-- 当天是否使用外挂
function DeRobot:IsUseWG(pPlayer)
	local nNowDay = Lib:GetLocalDay(GetTime());
	local nLastDay = pPlayer.GetTask(DeRobot.TASKGID, DeRobot.WG_LAST_USE_SKILL);
	if (nNowDay == nLastDay) then
		return 1;
	end
	
	return 0;
end

function DeRobot:AddPlayerWG(tbPlayer, nType)
	local nNow = GetTime();
	local nNowDay = Lib:GetLocalDay(nNow);
	local nNowWDay = tonumber(os.date("%w", nNow));
	local nTaskId = nNowWDay * 10 + nType;
	for _, pPlayer in pairs(tbPlayer) do
		local nLastDay = pPlayer.GetTask(self.TASKGID, DeRobot.WG_LAST_USE_DAY);
		local n = nNowDay - nLastDay;
		if (n >= 7) then	-- 超过一周间隔
			pPlayer.ClearTaskGroup(self.TASKGID);
		elseif (n > 0) then	-- 超过至少一天
			local w = nNowWDay;
			for i = 1, n do
				for j = 1, 4 do
					pPlayer.SetTask(self.TASKGID, w * 10 + j, 0);
				end
				w = w - 1;
				if (w < 0) then
					w = w + 7;
				end
			end			
		end
		pPlayer.SetTask(self.TASKGID, DeRobot.WG_LAST_USE_DAY, nNowDay);
		local nCount = pPlayer.GetTask(self.TASKGID, nTaskId) + 1;
		pPlayer.SetTask(self.TASKGID, nTaskId, nCount);
		self:DbgOut(pPlayer.szName, nTaskId, nCount);

		-- 如果不是当天，则输出屏幕
		if (nType == 3 and nCount > 5) then
			local nLastUseSkillDay = pPlayer.GetTask(self.TASKGID, DeRobot.WG_LAST_USE_SKILL);
			local nDiff = nNowDay - nLastUseSkillDay;
			if (nDiff ~= 0) then
				pPlayer.SetTask(self.TASKGID, DeRobot.WG_LAST_USE_SKILL, nNowDay);
				if (DeRobot.bOutPutDailyWGUser == 1) then
					print(string.format("DailyUseWG_%d\t%s\t%s", nNowWDay, pPlayer.szName, pPlayer.szAccount));
					StatLog:WriteStatLog("stat_info", "WG_use", "use", pPlayer.nId, 3);
				end
			end
		end
	end
end

-- nOffsetDay是说抓前几天的外挂0表示当天，-1表示昨天，-2表示前天
function DeRobot:CatchAllPlayer_GC(tbType, nValue, bTest, nOffsetDay)
	nOffsetDay = nOffsetDay or 0;
	assert(nOffsetDay <= 0 and nOffsetDay > -7);
	local nStainTime = GetTime() + (nOffsetDay * 3600 * 24);
	local nStainDay = Lib:GetLocalDay(nStainTime);
	if (bTest ~= 1) then
		self.tbCatchWGList[nStainDay] = {
			tbType = tbType,
			nValue = nValue,
			nStainTime = nStainTime,
		};
		if (nStainTime > (self.tbCatchWGList.nLastStainTime or 0)) then
			self.tbCatchWGList.nLastStainTime = nStainTime;
		end
	end
	self:SaveBuff();
	GlobalExcute({"DeRobot:CatchAllPlayer", nStainTime, tbType, nValue, bTest});
end

function DeRobot:CatchAllPlayer(nStainTime, tbType, nValue, bTest)
	local nStainDay = Lib:GetLocalDay(nStainTime);
	local nStainDay_W = tonumber(os.date("%w", nStainTime));
	if (bTest ~= 1) then
		self.tbCatchWGList[nStainDay] = {
			tbType = tbType,
			nValue = nValue,
			nStainTime = nStainTime,
		};
		if (nStainTime > (self.tbCatchWGList.nLastStainTime or 0)) then
			self.tbCatchWGList.nLastStainTime = nStainTime;
		end
	end
	local tbAllPlayer = KPlayer.GetAllPlayer();
	local szMsg = "";
	for _, pPlayer in pairs(tbAllPlayer) do
		pPlayer.SetTask(self.TASKGID, DeRobot.WG_LAST_STAIN_TIME, nStainTime);
		local v = self:CalcCatchValue(pPlayer, tbType, nStainDay, nStainDay_W);
		if (v >= nValue) then
			if (bTest == 1) then
				szMsg = szMsg .. string.format("%s %d\r\n", pPlayer.szName, v);
			else
				self:CatchPlayer(pPlayer);
			end
		end
	end
	if (bTest == 1) then
		print(szMsg);
	end
	return szMsg;
end

function DeRobot:CalcCatchValue(pPlayer, tbType, nStainDay, nStainDay_W)
	local nLastDay = pPlayer.GetTask(self.TASKGID, DeRobot.WG_LAST_USE_DAY);
	local n = nLastDay - nStainDay;
	-- 记录的是[WG_LAST_USE_DAY-6, WG_LAST_USE_DAY ]的日期如果
	if (n < 0 or n >= 7) then
		return 0;
	end
	
	local nValue = 0;
	for _, nType in pairs(tbType) do
		nValue = nValue + pPlayer.GetTask(self.TASKGID, nStainDay_W * 10 + nType);
	end
	
	return nValue;
end

function DeRobot:CatchPlayer(pPlayer)
	if (pPlayer.nLevel < 50) then
		return;
	end
	
	local nArrestDay = 7;
	local nHonorLevel = pPlayer.GetHonorLevel();
	if (nHonorLevel >= 9) then
		nArrestDay = 3;
	end
	print("CatchPlayerWG", pPlayer.szAccount, pPlayer.szName)
	pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_GM_OPERATION, "非法外挂关天牢");
	pPlayer.SetTask(SpecialEvent.HoleSolution.TASK_COMPENSATE_GROUPID, SpecialEvent.HoleSolution.TASK_SUBID_REASON, 3);
	Player:Arrest(pPlayer.szName, 3600*24*nArrestDay);
end

function DeRobot:OnServerStart()
	--Dbg.tbDbgMode.DeRobot = 1;
	self:LoadBuffer();
	SetChatCallBack("ab");
	if (self.nTimerId) then
		Timer:Close(self.nTimerId);
	end
	self.nTimerId = Timer:Register(Env.GAME_FPS * 60 * 3, "DeRobot:CheckAllPlayer");
end

--存buff
function DeRobot:SaveBuff()
	SetGblIntBuf(GBLINTBUF_DEROBOT_WG, 0, 1, self.tbCatchWGList);
end

--读buff
function DeRobot:LoadBuffer()
	local tbBuffer = GetGblIntBuf(GBLINTBUF_DEROBOT_WG, 0);
	if tbBuffer and type(tbBuffer) == "table" then
		local nNowDay = Lib:GetLocalDay();
		for nDay, tbCatch in pairs(tbBuffer) do
			if (type(nDay) == "number" and nDay + 3 < nNowDay) then
				tbBuffer[nDay] = nil;
			end
		end
		self.tbCatchWGList = tbBuffer;
		
		-- TODO:兼容老的数据格式，下个版本删除
		for nDay, tbCatch in pairs(self.tbCatchWGList) do
			if (type(tbCatch) == "table") then
				tbCatch.nStainTime = tbCatch.nStainTime or tbCatch.nTime;
				tbCatch.nTime = nil;
			end
		end
		
		self.tbCatchWGList.nLastStainTime = self.tbCatchWGList.nLastStainTime or self.tbCatchWGList.nMaxTime;
		self.tbCatchWGList.nMaxTime = nil;
		
	else
		self.tbCatchWGList = {};
	end
end

function DeRobot:ShowWG(pPlayer)
	local tbPlayer;
	if (pPlayer) then
		tbPlayer = {pPlayer};
	else
		tbPlayer = KPlayer.GetAllPlayer();
	end
	for nDay, pPlayer in ipairs(tbPlayer) do
		local szData = "";
		for w = 0, 6 do
			local tbDay = {};
			local nValue = 0;
			for t = 1, 4 do
				local v = pPlayer.GetTask(self.TASKGID, w * 10 + t);
				tbDay[t] = v;
				nValue = nValue + v;
			end
			if (nValue > 0) then
				szData = szData .. string.format("[%d]%s;", w, Lib:ConcatStr(tbDay));
			end
		end
		local szDate = "N/A";
		local nLastDay = pPlayer.GetTask(self.TASKGID, DeRobot.WG_LAST_USE_DAY);
		if (nLastDay > 0) then
			local nLastTime = nLastDay * 3600 * 24 - Lib:GetGMTSec();
			szDate = os.date("%Y-%m-%d", nLastTime);
		end
		local szMsg = string.format("%s: %s %s", pPlayer.szName, szDate, szData);
		print(szMsg);
		me.Msg(szMsg);
	end
end

function DeRobot:ClientCmd(szCmd, szType, pPlayer)
	if (not pPlayer) then
		pPlayer = me;
	end
	if (not szType) then
		szType = "ClientCmd";
	end
	pPlayer.CallClientScript({"GM:DoClientCmd", szType, szCmd});
end

if (MODULE_GC_SERVER) then
	--GCEvent:RegisterGCServerShutDownFunc(DeRobot.SaveBuff, DeRobot);
	GCEvent:RegisterGCServerStartFunc(DeRobot.LoadBuffer, DeRobot);
end

--function DeRobot:gc_ApplyNewServerLimit()
--	-- 如果关闭多开
--	if (EventManager.IVER_bOpenMutiOpenSys == 0) then
--		ModifyNewServerDays(0);
--	end
--end
--
--if (MODULE_GC_SERVER) then
--	GCEvent:RegisterGCServerStartFunc(DeRobot.gc_ApplyNewServerLimit, DeRobot);
--end

if (MODULE_GAMESERVER) then
	-- 注册通用下线事件
	PlayerEvent:RegisterGlobal("OnLogout", "DeRobot:OnPlayerLogout");
	PlayerEvent:RegisterGlobal("OnLogin", "DeRobot:OnLoginDo");
end
