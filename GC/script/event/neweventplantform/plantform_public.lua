-- 文件名　：plantform_public.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-09-20 20:54:33
-- 功能    ：无差别竞技

function NewEPlatForm:GetMatchState()
	return KGblTask.SCGetDbTaskInt(self.GTASK_MACTH_STATE)
end

--无差别竞技取代家族竞技（没有开启的始终开启）
function NewEPlatForm:SetMatchStart()
	local nState = KGblTask.SCGetDbTaskInt(self.GTASK_MACTH_STATE);
	if nState == self.DEF_STATE_CLOSE then
		KGblTask.SCSetDbTaskInt(self.GTASK_MACTH_STATE, self.DEF_STATE_STAR);
	end
	--96天的时候关闭掉
	--if TimeFrame:GetServerOpenDay() >= self.nCloseDay and nState == self.DEF_STATE_STAR then
	--	KGblTask.SCSetDbTaskInt(self.GTASK_MACTH_STATE, self.DEF_STATE_CLOSE);
	--end
	--return 0;	
end

-- 1表示通过，0表示未通过
function NewEPlatForm:ProcessItemCheckFun(pPlayer, tbJoinItem)
	if (not pPlayer or not tbJoinItem) then
		return 0, "没有竞技活动所需要的物品";
	end
	
	local tbItemList = {};
	local tbItemListInfo = {};
	for _, tbItemInfo in pairs(tbJoinItem) do
		if (tbItemInfo.tbItem) then
			local tbInfo = pPlayer.FindItemInBags(unpack(tbItemInfo.tbItem));
			if (tbInfo and #tbInfo > 0) then
				tbItemList = tbInfo;
				tbItemListInfo = tbItemInfo;
				break;
			end
		end
	end
	if (not tbItemList) then
		return 0, "身上没有竞技活动所需的物品";
	end

	local pItem = nil;
	for _, tbItemInfo in pairs(tbItemList) do
		if (tbItemInfo.pItem) then
			pItem = tbItemInfo.pItem;
			break;
		end
	end
	if (not pItem) then
		return 0, "身上没有竞技活动所需的物品";
	end
	
	local szClassName = pItem.szClass;
	if (szClassName and szClassName ~= "") then
		local tbItem = Item:GetClass(szClassName);
		if (tbItem and tbItem.ItemCheckFun) then
			return tbItem:ItemCheckFun(pItem), pItem.szName;
		end
	end

	return 1, pItem.szName;
end

--获得赛制类型配置表
function NewEPlatForm:GetMacthTypeCfg(nMacthType)
	if not nMacthType or nMacthType <= 0 then
		return
	end
	return self.MacthType[self.MACTH_TYPE[nMacthType]];
end

function NewEPlatForm:GetItemName(tbItem)
	return KItem.GetNameById(unpack(tbItem));
end

function NewEPlatForm:UseMatchItem(pPlayer, nDelCount, tbJoinItem, nUseLimitCount)
	if (not pPlayer or not nDelCount or nDelCount <= 0 or not tbJoinItem or not nUseLimitCount or nUseLimitCount <= 0) then
		NewEPlatForm:WriteLog("UseMatchItem", "[ERROR] There is not pPlayer or not nDelCount or nDelCount <= 0 or not tbItemList or not nUseLimitCount or nUseLimitCount <= 0");
		return 0;
	end
	local tbItemList = {};
	local tbItemListInfo = {};
	for _, tbItemInfo in pairs(tbJoinItem) do
		if (tbItemInfo.tbItem) then
			local tbInfo = pPlayer.FindItemInBags(unpack(tbItemInfo.tbItem));
			if (tbInfo and #tbInfo > 0) then
				tbItemList = tbInfo;
				tbItemListInfo = tbItemInfo;
				break;
			end
		end
	end
	if (not tbItemList) then
		NewEPlatForm:WriteLog("[ERROR] UseMatchItem", "There is no tbItemList", pPlayer.szName);
		return 0;
	end

	local pItem = nil;
	for _, tbItemInfo in pairs(tbItemList) do
		if (tbItemInfo.pItem) then
			pItem = tbItemInfo.pItem;
			break;
		end
	end
	if (not pItem) then
		NewEPlatForm:WriteLog("[ERROR] UseMatchItem", "There is no pItem", pPlayer.szName);
		return 0;
	end
	local nWear  = nUseLimitCount - pItem.GetGenInfo(1, 0);
	if nWear <= 1 then
		pPlayer.DelItem(pItem);
	else
		pItem.Bind(1);
		pItem.SetGenInfo(1, pItem.GetGenInfo(1, 0) + 1);
		pPlayer.Msg(string.format("减少一次%s使用次数！", pItem.szName));
		pItem.Sync();
	end
	
	if (tbItemListInfo and tbItemListInfo.tbItemSkill and #tbItemListInfo.tbItemSkill > 0) then
		pPlayer.AddSkillState(unpack(tbItemListInfo.tbItemSkill));
	end
	
	return 1;
end

function NewEPlatForm:CheckEnterCount(pPlayer, tbJoinItem)
	if (not tbJoinItem or not pPlayer) then
		return -1;
	end
	local nCount = 0;
	for _, tbItemInfo in pairs(tbJoinItem) do
		if (tbItemInfo.tbItem and #tbItemInfo.tbItem > 0) then
			nCount = nCount + pPlayer.GetItemCountInBags(unpack(tbItemInfo.tbItem));
		end
	end
	
	return nCount;
end

--获得赛制类型,Int
function NewEPlatForm:GetMacthType(nSession)
	if not nSession then
		if not self.SEASON_TB[KGblTask.SCGetDbTaskInt(self.GTASK_MACTH_SESSION)] then
			return 0;
		end
		return self.SEASON_TB[KGblTask.SCGetDbTaskInt(self.GTASK_MACTH_SESSION)][1];
	
	else
		if not self.SEASON_TB[nSession] then
			return 0;
		end
		return self.SEASON_TB[nSession][1];
	end
	return 0;
end

--改类型
function NewEPlatForm:GameSessionChange()
	local nServerStarDay = KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME);
	local nServerStarDayEx = tonumber(os.date("%Y%m%d", nServerStarDay));
	local nServerStarWeek = Lib:GetLocalWeek(nServerStarDay);
	--开服在20120717之前服务器，从这个日期开始算界数
	if nServerStarDayEx < 20120717 and tonumber(GetLocalDate("%Y%m%d")) > 20120717 then
		nServerStarWeek = Lib:GetLocalWeek(Lib:GetDate2Time(20120717));
	end
	local nWeek = Lib:GetLocalWeek(GetTime());
	local nType = KGblTask.SCGetDbTaskInt(self.GTASK_MACTH_SESSION);
	local nNextType = math.fmod(nWeek - nServerStarWeek + 1, 4);
	if nType == nNextType then
		return;
	end
	if nNextType == 0 then
		nNextType = 4;
	end
	KGblTask.SCSetDbTaskInt(self.GTASK_MACTH_SESSION, nNextType);
end

--设置联赛届数
function NewEPlatForm:GetMacthSession()
	return KGblTask.SCGetDbTaskInt(self.GTASK_MACTH_SESSION);
end

--进入准备场
function NewEPlatForm:AddGroupMember(nReadyId, szLeagueName, nPlayerId)
	if not self.GroupList[nReadyId] then
		self.GroupList[nReadyId] = {};
	end	
	self.GroupList[nReadyId][szLeagueName] = self.GroupList[nReadyId][szLeagueName] or {};
	table.insert(self.GroupList[nReadyId][szLeagueName], nPlayerId);
end

--退出准备场
function NewEPlatForm:DelGroupMember(nReadyId, szLeagueName, nPlayerId)
	if not self.GroupList[nReadyId] or not  self.GroupList[nReadyId][szLeagueName] then
		return
	end		
	local nIndex = 0;
	for i, nId in ipairs(self.GroupList[nReadyId]) do
		if nId == nPlayerId then
			nIndex = i;
			break;
		end
	end
	table.remove(self.GroupList[nReadyId], nIndex);
	local bRemoveGroup = 0;
	if #self.GroupList[nReadyId] <= 0 then
		self.GroupList[nReadyId][szLeagueName] = nil
		bRemoveGroup = 1;
	end
	if (MODULE_GC_SERVER) then
		KGblTask.SCSetDbTaskInt(self.GTASK_MACTH_MAP_STATE, 0);
		if bRemoveGroup == 1 then
			self.GroupList[nReadyId].nLeagueCount = self.GroupList[nReadyId].nLeagueCount - 1;
		end
	else
		GCExcute{"NewEPlatForm:DelGroupMember", nReadyId, szLeagueName, nPlayerId};
	end
end

function NewEPlatForm:UpdateMatchTime()	
	local nRankSession	= self:GetMacthSession();
	self.nCurEventType = nRankSession;
	local tbMCfg		= self:GetMacthTypeCfg(self:GetMacthType(nRankSession));
	if (not tbMCfg) then
		return;
	end
	local tbCfg			= tbMCfg.tbMacthCfg;
	local nReadyTime	= 0;
	local nRankTime		= 0;
	local nPkTime		= 0;	

	if (not tbCfg.nReadyTime_Common or tbCfg.nReadyTime_Common <= 0 or not tbCfg.nPKTime_Common or tbCfg.nPKTime_Common <= 0 ) then
		return;
	end
	nReadyTime	= Env.GAME_FPS * tbCfg.nReadyTime_Common;		--准备场准备时间;
	nRankTime 	= Env.GAME_FPS * (tbCfg.nPKTime_Common + 10);	--准备时间结束进入比赛后多少时间更新排行;
	nPkTime		= Env.GAME_FPS * tbCfg.nPKTime_Common;
	self.nCurReadyMaxCount	= tbMCfg.tbMacthCfg.nWeleeReadyMaxTeam;
	self.MACTH_ATTEND_MAX = tbCfg.nPlayCount_Player;
	self.nCurMatchMaxTeamCount	= tbMCfg.tbMacthCfg.nMeleeMaxCount;
	self.nCurMatchMinTeamCount	= tbMCfg.tbMacthCfg.nMeleeMinCount;
	self.nMemPlayerCount			= tbMCfg.tbMacthCfg.nPlayerCount;
	
	self.tbEventTime = {nReadyTime, nPkTime, nRankTime};

	local tbCfg			= tbMCfg.tbMacthCfg;

	if (tbCfg and tbCfg.tbCommon and #tbCfg.tbCommon > 0) then
		self.CALEMDAR = tbCfg.tbCommon;
	end

	if (MODULE_GC_SERVER) then
		GlobalExcute{"NewEPlatForm:UpdateMatchTime"};
	end
end

function NewEPlatForm:GetPlayerReadyId(pPlayer)
	if (not pPlayer) then
		return 0;
	end
	local nReadyId	= 0;
	nReadyId	= pPlayer.GetTask(self.TASKID_GROUP, self.TASKID_ENTER_READY);
	return nReadyId;
end

function NewEPlatForm:GetPlayerDynId(pPlayer)
	if (not pPlayer) then
		return 0;
	end

	local nDynId	= 0;
	nDynId		= pPlayer.GetTask(self.TASKID_GROUP, self.TASKID_ENTER_DYN);
	return nDynId;
end

function NewEPlatForm:SetPlayerReadyId(pPlayer, nReadyId)
	if (pPlayer and nReadyId) then
		pPlayer.SetTask(self.TASKID_GROUP, self.TASKID_ENTER_READY, nReadyId);
	end	
end

function NewEPlatForm:SetPlayerDynId(pPlayer, nDynId)
	if (pPlayer and nDynId) then
		pPlayer.SetTask(self.TASKID_GROUP, self.TASKID_ENTER_DYN, nDynId);
	end
end

--获得每个准备场最大战队数
function NewEPlatForm:GetPreMaxLeague()
	return self.nCurReadyMaxCount;
end

-- 设置个人参加活动次数
function NewEPlatForm:SetPlayerEventCount(pPlayer, nCount)
	if (not pPlayer) then
		return;
	end
	pPlayer.SetTask(self.TASKID_GROUP, self.TASKID_DALIYEVENTCOUNT, nCount);
end

function NewEPlatForm:AddPlayerTotalCount(pPlayer, nCount)
	if (not pPlayer or not nCount or nCount <= 0) then
		return 0;
	end
	
	local nLastCount = self:GetPlayerTotalCount(pPlayer);
	self:SetPlayerTotalCount(pPlayer, nLastCount + nCount);
end

function NewEPlatForm:SetPlayerTotalCount(pPlayer, nCount)
	if (not pPlayer or not nCount) then
		return 0;
	end
	pPlayer.SetTask(self.TASKID_GROUP, self.TASKID_MATCH_TOTLE, nCount);
end

function NewEPlatForm:GetPlayerTotalCount(pPlayer)
	if (not pPlayer) then
		return 0;
	end
	return pPlayer.GetTask(self.TASKID_GROUP, self.TASKID_MATCH_TOTLE);
end

function NewEPlatForm:ChangeEventCount(pPlayer)
	--活动还没开启的不累积	
	if self:GetMatchState() == self.DEF_STATE_CLOSE then
		return 0;
	end
	local nCreatTime = Lib:GetDate2Time(me.GetRoleCreateDate());
	local nNowTime = tonumber(GetLocalDate("%Y%m%d"));
	local nTime = pPlayer.GetTask(self.TASKID_GROUP, self.TASKID_COUNTCHANGETIME);
	local nCount =  pPlayer.GetTask(self.TASKID_GROUP, self.TASKID_DALIYEVENTCOUNT);	
	if nTime == 0 then
		nTime = nCreatTime;
	end
	local nTimesDay = Lib:GetLocalDay(nTime);
	local nNowDay = Lib:GetLocalDay(GetTime());
	
	if nNowDay > nTimesDay then
		nCount = nCount + (nNowDay - nTimesDay) * 2;
	end	
	nCount = math.min(nCount, self.MACTH_MAX_JOINCOUNT);	--最大累积14次	
	pPlayer.SetTask(self.TASKID_GROUP, self.TASKID_COUNTCHANGETIME, Lib:GetDate2Time(nNowTime));
	pPlayer.SetTask(self.TASKID_GROUP, self.TASKID_DALIYEVENTCOUNT, nCount);
	----------------------------------------------------------------------------------------------------------
	--每月总场数轮转
	local nMonthNow = tonumber(GetLocalDate("%m"));
	local nMonths = pPlayer.GetTask(self.TASKID_GROUP, self.TASKID_MATCH_MONTH);
	if nMonths ~= nMonthNow then
		 pPlayer.SetTask(self.TASKID_GROUP, self.TASKID_MATCH_MONTH, nMonthNow);
		 pPlayer.SetTask(self.TASKID_GROUP, self.TASKID_MATCH_TOTLE, 0);
	end
end

-- 获取个人参加活动次数
function NewEPlatForm:GetPlayerEventCount(pPlayer)
	if (not pPlayer) then
		return 0;
	end
	return pPlayer.GetTask(self.TASKID_GROUP, self.TASKID_DALIYEVENTCOUNT);
end

function NewEPlatForm:GetEventCount(pPlayer)
	if (not pPlayer) then
		return 0;
	end	
	return self:GetPlayerEventCount(pPlayer);
end

function NewEPlatForm:GetPlayerCountChangeTime(pPlayer)
	return pPlayer.GetTask(self.TASKID_GROUP, self.TASKID_COUNTCHANGETIME);
end

function NewEPlatForm:SetPlayerCountChangeTime(pPlayer, nTime)
	return pPlayer.SetTask(self.TASKID_GROUP, self.TASKID_COUNTCHANGETIME, nTime);
end

function NewEPlatForm:WriteLog(...)
	if (MODULE_GC_SERVER) then
		Dbg:WriteLog("NewEPlatForm", "家族竞技活动", unpack(arg));
	end
	
	if (MODULE_GAMESERVER) then
		Dbg:WriteLogEx(Dbg.LOG_INFO, "NewEPlatForm", unpack(arg));	
	end		
end

function NewEPlatForm:SetAwardParam(pPlayer, nFlag)
	if (not pPlayer) then
		return;
	end
	pPlayer.SetTask(self.TASKID_GROUP, self.TASKID_AWARDFLAG, nFlag);
end

function NewEPlatForm:GetAwardParam(pPlayer)
	if (not pPlayer) then
		return 0;
	end
	return pPlayer.GetTask(self.TASKID_GROUP, self.TASKID_AWARDFLAG);
end

function NewEPlatForm:GetLeaveMapPos()	
	local tbNpc = Npc:GetClass("chefu");
	for _, tbMapInfo in ipairs(tbNpc.tbCountry) do
		if SubWorldID2Idx(tbMapInfo.nId) >= 0 then
			local nRandomPos = MathRandom(1, #tbMapInfo.tbSect)
			return tbMapInfo.nId, tbMapInfo.tbSect[nRandomPos][1],tbMapInfo.tbSect[nRandomPos][2];
		end
	end
	return 5, 1580, 3029;
end	

--个人上线累计次数
function NewEPlatForm:PlayerLogin()
	
end

function NewEPlatForm:AddKinGradeEx(nKinId, nMemberId, nGrade, nPlayerId)
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		return 0;
	end
	local pMember = pKin.GetMember(nMemberId);
	if not pMember then
		return;
	end
	local nMonthNow = tonumber(GetLocalDate("%m"));
	--家族积分
	local nKinMonth = pKin.GetKinGameMonth();
	local nKinTotalGrade = pKin.GetKinGameGrade();
	if nMonthNow ~= nKinMonth then
		if nMonthNow == math.fmod(nKinMonth, 12) + 1 then
			pKin.SetKinGameGradeLast(nKinTotalGrade);
		else
			pKin.SetKinGameGradeLast(0);
		end
		pKin.SetKinGameMonth(nMonthNow);
		nKinTotalGrade = 0;
	end
	pKin.SetKinGameGrade(nKinTotalGrade + nGrade);
	--成员积分
	local nMemMonth = pMember.GetKinGameMonth();
	local nMemTotalGrade = pMember.GetKinGameGrade();
	if nMonthNow ~= nMemMonth then
		pMember.SetKinGameMonth(nMonthNow);
		nMemTotalGrade = 0;
	end
	pMember.SetKinGameGrade(nMemTotalGrade + nGrade);
	if MODULE_GC_SERVER then
		GlobalExcute{"NewEPlatForm:AddKinGradeEx", nKinId, nMemberId, nGrade, nPlayerId};
	end
	if MODULE_GAMESERVER then
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer and nMemTotalGrade + nGrade >= 27 then
			Achievement:FinishAchievement(pPlayer, 506);
		end
		return KKinGs.KinClientExcute(nKinId, {"Kin:AddKinGrade_C2", nMemberId, nGrade});
	end
end

function NewEPlatForm:GetKinMonthAward(nKinId, nMemberId, nPlayerId)
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		if MODULE_GC_SERVER then
			GlobalExcute{"NewEPlatForm:GetKinMonthAwardFailed", nPlayerId};
		end
		if MODULE_GAMESERVER then
			self:GetKinMonthAwardFailed(pPlayerId);
		end
		return 0;
	end
	local pMember = pKin.GetMember(nMemberId);
	if not pMember then
		if MODULE_GC_SERVER then
			GlobalExcute{"NewEPlatForm:GetKinMonthAwardFailed", nPlayerId};
		end
		if MODULE_GAMESERVER then
			self:GetKinMonthAwardFailed(pPlayerId);
		end
		return 0;
	end
	local nKinMonth = pKin.GetKinGameMonth();
	local nKinTotalGrade = pKin.GetKinGameGrade();
	local nKinTotalGradeLast= pKin.GetKinGameGradeLast();
	local nNowMonth = tonumber(GetLocalDate("%m"));
	local nKinGrade = 0;
	if nNowMonth == math.fmod(nKinMonth, 12) + 1 then
		nKinGrade = nKinTotalGrade;
	elseif nNowMonth == nKinMonth then
		nKinGrade = nKinTotalGradeLast;
	end
	local nMemMonth = pMember.GetKinGameMonth();
	local nMemGrade = pMember.GetKinGameGrade();
	local nSelfMonth = 0;
	if nNowMonth == math.fmod(nMemMonth, 12) + 1 then
		nSelfMonth = nMemGrade;
	end
	local nRank = 0;
	local nLadderType	= Ladder:GetType(0, Ladder.LADDER_CLASS_LADDER, Ladder.LADDER_TYPE_LADDER_EVENTPLANT, Ladder.LADDER_TYPE_LADDER_EVENTPLANT_PRETEAM);
	local tbLadder = GetShowLadder(nLadderType) or {};
	for nId, tbInfo in ipairs(tbLadder) do
		if pKin.GetName() == tbInfo.szName then
			nRank = nId;
			break;
		end
	end
	if nSelfMonth >= self.nPayerGradeLimit and nKinGrade >= self.nKinGradeLimit and nRank > 0 then
		pMember.SetKinGameMonth(nNowMonth);
		pMember.SetKinGameGrade(0);
		if MODULE_GC_SERVER then
			GlobalExcute{"NewEPlatForm:GetKinMonthAward", nKinId, nMemberId, nPlayerId};
		end
		if MODULE_GAMESERVER then
			self:AddMonthAwardEx(nPlayerId, nRank, nSelfMonth, nKinGrade);
		end
		return;
	end
	if MODULE_GC_SERVER then
		GlobalExcute{"NewEPlatForm:GetKinMonthAwardFailed", nPlayerId};
	end
	if MODULE_GAMESERVER then
		self:GetKinMonthAwardFailed(pPlayerId);
	end
	return;
end


if (MODULE_GC_SERVER) then
	GCEvent:RegisterGCServerStartFunc(NewEPlatForm.UpdateMatchTime, NewEPlatForm);
end

if (MODULE_GAMESERVER) then
	ServerEvent:RegisterServerStartFunc(NewEPlatForm.UpdateMatchTime, NewEPlatForm);	
	PlayerEvent:RegisterOnLoginEvent(NewEPlatForm.PlayerLoginRV, NewEPlatForm);
end
