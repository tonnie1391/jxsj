-- 文件名　：manager.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-01-23 15:23:28
-- 描  述  ：

-----------GAMEGCSERVER 函数START-----
if (MODULE_GC_SERVER) then
	
--nEventId:事件Id
--nPatch:任务变量批次
function EventManager:SetEventBatch(nEventId, nTaskBatch)
	if not EventManager.EventManager.tbEvent then
		return 0;
	end
	Dbg:WriteLog("EventManager", "SetEventBatch", nEventId, nTaskBatch);
	return EventManager.EventManager:ChangeEventTaskBatch(nEventId, nTaskBatch);
end

--nEventId:事件Id
--szName
function EventManager:SetEventName(nEventId, szName)
	if not EventManager.EventManager.tbEvent then
		return 0;
	end	
	Dbg:WriteLog("EventManager", "SetEventName", nEventId, szName);
	return EventManager.EventManager:ChangeEventName(nEventId, szName);
end

--nEventId:事件Id
--szDesc
function EventManager:SetEventDesc(nEventId, szDesc)
	if not EventManager.EventManager.tbEvent then
		return 0;
	end	
	Dbg:WriteLog("EventManager", "SetEventDesc", nEventId, szDesc);
	return EventManager.EventManager:ChangeEventDesc(nEventId, szDesc);
end

--nEventId:事件Id
--szName
function EventManager:SetEventPartName(nEventId, nPartId, szName)
	if not EventManager.EventManager.tbEvent then
		return 0;
	end	
	Dbg:WriteLog("EventManager", "SetEventPartName", nEventId, nPartId, szName);
	return EventManager.EventManager:ChangeEventPartName(nEventId, nPartId, szName);
end

--nEventId:事件Id
--szSubKind
function EventManager:SetEventSubKind(nEventId, nPartId, szSubKind)
	if not EventManager.EventManager.tbEvent then
		return 0;
	end	
	Dbg:WriteLog("EventManager", "SetEventSubKind", nEventId, nPartId, szSubKind);
	return EventManager.EventManager:ChangeEventPartSubKind(nEventId, nPartId, szSubKind);
end

--nEventId:事件Id
--nStartDate:开始日期：YYYYmmddHHMM or YYYYmmdd
--nEndDate:结束日期：YYYYmmddHHMM or YYYYmmdd
function EventManager:SetEventDate(nEventId, nStartDate, nEndDate)
	if not EventManager.EventManager.tbEvent then
		return 0;
	end
	
	if nStartDate ~= 0 and string.len(nStartDate) < 12 then
		nStartDate = nStartDate * 10^(12-string.len(nStartDate));
	end
	if nEndDate ~= 0 and string.len(nEndDate) < 12 then
		nEndDate = nEndDate * 10^(12-string.len(nEndDate));
	end
	Dbg:WriteLog("EventManager", "SetEventDate", nEventId, nStartDate, nEndDate);
	return EventManager.EventManager:ChangeEventTime(nEventId, nStartDate, nEndDate);
end

--nEventId:事件Id
--nPartId: 子事件Id
--nStartDate:开始日期：YYYYmmddHHMM or YYYYmmdd
--nEndDate:结束日期：YYYYmmddHHMM or YYYYmmdd
function EventManager:SetPartDate(nEventId, nPartId, nStartDate, nEndDate)
	if not EventManager.EventManager.tbEvent then
		return 0;
	end	
	if nStartDate ~= 0 and string.len(nStartDate) < 12 then
		nStartDate = nStartDate * 10^(12-string.len(nStartDate));
	end
	if nEndDate ~= 0 and string.len(nEndDate) < 12 then
		nEndDate = nEndDate * 10^(12-string.len(nEndDate));
	end
	Dbg:WriteLog("EventManager", "SetPartDate", nEventId, nPartId, nStartDate, nEndDate);
	return EventManager.EventManager:ChangeEventPartTime(nEventId, nPartId, nStartDate, nEndDate);
end

--nEventId:事件Id
--nPartId: 子事件Id
--nParam:  参数项
--szParam: 修改参数
function EventManager:SetPartParam(nEventId, nPartId, nParam, szParam)
	if not EventManager.EventManager.tbEvent then
		return 0;
	end	
	if szParam ~= "" then
		Dbg:WriteLog("EventManager", "SetPartParam", nEventId, nPartId, nParam, szParam);
	end
	return EventManager.EventManager:ChangeEventPartParam(nEventId, nPartId, nParam, szParam);
end

--更新事件；
function EventManager:UpdateEvent(nEventId)
	if not EventManager.EventManager.tbEvent then
		return 0;
	end	
	Dbg:WriteLog("EventManager", "UpdateEvent", nEventId);
	Timer:Register(2*18, EventManager.EventManager.UpdateSingleEvent, EventManager.EventManager, nEventId);
end

end

--重载文件.测试使用;
function EventManager:DoScript()
	EventManager.EventManager:DoScript();
end

function EventManager:GetClass(szClass)
	if EventManager.EventKind.ExClass[szClass] == nil then
		EventManager.EventKind.ExClass[szClass] = {};
	end
	return EventManager.EventKind.ExClass[szClass];
end

function EventManager:GetItemClass(szClass)
	if not szClass or szClass == 0 then
		return {};
	end
	if EventManager.EventItem[szClass] == nil then
		EventManager.EventItem[szClass] = {};
	end
	return EventManager.EventItem[szClass];
end

function EventManager:GetItemIdClass(szClass)
	if not szClass or szClass == "" then
		return {};
	end
	if EventManager.EventItemId[szClass] == nil then
		EventManager.EventItemId[szClass] = {};
	end
	return EventManager.EventItemId[szClass];
end

function EventManager:GetNpcClass(varNpcId, bCreate)
	if not varNpcId then
		return;
	end
	varNpcId = tonumber(varNpcId) or varNpcId;
	if bCreate == 1 then
		if EventManager.EventNpc[varNpcId] == nil then
			EventManager.EventNpc[varNpcId] = {};
			EventManager.EventNpc[varNpcId].tbEventDialog = {};
		end
	end
	return EventManager.EventNpc[varNpcId];
end

function EventManager:GetTask(nTaskId)
	local nTaskPacth = tonumber(EventManager:GetTempTable().BASE_nTaskBatch) or 0;
	if nTaskPacth and nTaskPacth > 0 then
		local nOrgTaskPacth = me.GetTask(EventManager.TASK_PACTH_GROUP_ID, nTaskId);
		if nOrgTaskPacth < nTaskPacth then
			me.SetTask(EventManager.TASK_PACTH_GROUP_ID, nTaskId, nTaskPacth);
			me.SetTask(EventManager.TASK_GROUP_ID, nTaskId, 0);
			--me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("[活动]玩家参加活动批次更改：%s -> %s",nOrgTaskPacth, nTaskPacth));
			self:WriteLog(string.format("[活动]玩家参加活动批次更改：(2026,%s) %s -> %s", nTaskId, nOrgTaskPacth, nTaskPacth), me);
		end
	end
	return me.GetTask(EventManager.TASK_GROUP_ID, nTaskId);
end

function EventManager:SetTask(nTaskId, nValue)
	return me.SetTask(EventManager.TASK_GROUP_ID, nTaskId, nValue);
end

function EventManager:ShowTask(nTaskId)
	me.Msg(""..self:GetTask(nTaskId));
	print("EventManager ShowTask:", self:GetTask(nTaskId));
end

function EventManager:GetEventPartTable(nEventId, nEventPartId)
	if not EventManager.EventManager.tbEvent[nEventId] or not EventManager.EventManager.tbEvent[nEventId].tbEventPart[nEventPartId] then
		return;
	end
	return EventManager.EventManager.tbEvent[nEventId].tbEventPart[nEventPartId].tbEventPart;
end

function EventManager:GetEventTable(nEventId)
	return EventManager.EventManager.tbEvent[nEventId].tbEventPart;
end

function EventManager:GetEventTableEx(nEventId)
	return EventManager.EventManager.tbEvent[nEventId];
end

--事件Id, 小事件Id，类项（是否只做检查），是否回调自己，是否往下执行 ,提示类型（默认左下角msg，1－dialog）,类型：0.默认，1.物品, 是否读取过进度条
function EventManager:GotoEventPartTable(nEventId, nEventPartId, nType, nCheck, nIsStopNext, nMsgType, nKind, nDelayCheck)
	nIsStopNext = tonumber(nIsStopNext) or 1;
	nType		= tonumber(nType) or 0;
	nCheck		= tonumber(nCheck) or 0;
	nMsgType	= tonumber(nMsgType) or 0;
	nKind		= tonumber(nKind) or 0;
	nDelayCheck	= tonumber(nDelayCheck) or 0;
	local tbNextParam = self:GetEventPartTable(nEventId, nEventPartId).tbParam;	
	if not tbNextParam then
		return 1, "CheckTaskGotoEvent出错，找不到跳转事件";
	end
	local nFlag, szMsg = EventManager.tbFun:CheckParam(tbNextParam);
	if nFlag == 1 then
		if (szMsg) then
			if nMsgType == 1 then
				Dialog:Say(szMsg);
			else
				me.Msg(szMsg);
			end
		end
		return 1, szMsg;
	end
	local nSetGlobalObj = 0;
	local tbGRoleArgs = Dialog:GetMyDialog().tbGRoleArgs;
	if tbGRoleArgs then
		if tbGRoleArgs.npcId then
			local pNpc = KNpc.GetById((tbGRoleArgs.npcId)or 0);
			if pNpc then
				Setting:SetGlobalObj(nil, pNpc);
				nSetGlobalObj = 1;
			end
		end
	end
	
	--只做条件检查
	if nType == 1 then
		if nSetGlobalObj == 1 then
			Setting:RestoreGlobalObj();
		end
		return 0;
	end
	
	local nGetTempType = self:GetTempTable().nType or 0;
	if nGetTempType == 2 then
		if not self:GetTempTable().tbParam or not self:GetTempTable().tbParam.nItemId then
			if nSetGlobalObj == 1 then
				Setting:RestoreGlobalObj();
			end
			return 1, "找不到该物品.";
		end
		local nItemId = self:GetTempTable().tbParam.nItemId;
		local pItem = KItem.GetObjById(nItemId);
		if not pItem then
			if nSetGlobalObj == 1 then
				Setting:RestoreGlobalObj();
			end			
			return 1, "找不到该物品.";
		end
		if me.IsHaveItemInBags(pItem) ~= 1 then
			if nSetGlobalObj == 1 then
				Setting:RestoreGlobalObj();
			end			
			return 1, "找不到该物品.";
		end
	end
	
	local tbSelect = EventManager.tbFun:GetParam(tbNextParam,"AddSelect", 1)
	if nCheck == 0 and #tbSelect > 0 then
		local tbParam = EventManager.tbFun:SplitStr(tbSelect[1]);
		local tbOpt = {
				{EventManager.tbFun:StrVal(tbParam[2] or "确定领取"), self.GotoEventPartTable, self, nEventId, nEventPartId, nType, 1, nIsStopNext, nMsgType, nKind},
				{EventManager.DIALOG_CLOSE},
			};
		Dialog:Say(EventManager.tbFun:StrVal(tbParam[1] or "您好，有什么需要帮助吗？"), tbOpt);
		if nSetGlobalObj == 1 then
			Setting:RestoreGlobalObj();
		end		
		return nIsStopNext;
	end
	if nDelayCheck == 0 then
		local tbLinkParam = EventManager.tbFun:GetParam(tbNextParam, "SetLink", 1);
		local nDelay = 0;
		for _, szParam in pairs(tbLinkParam) do
			local tbParam = EventManager.tbFun:SplitStr(szParam);
			nDelay = tbParam[2] or 0;
			nDelay = tonumber(nDelay) or 0;
			break;
		end
		if nDelay > 0 then
			local tbEvent = 
			{
				Player.ProcessBreakEvent.emEVENT_MOVE,
				Player.ProcessBreakEvent.emEVENT_ATTACK,
				Player.ProcessBreakEvent.emEVENT_ATTACKED,
				Player.ProcessBreakEvent.emEVENT_SITE,
				Player.ProcessBreakEvent.emEVENT_USEITEM,
				Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
				Player.ProcessBreakEvent.emEVENT_DROPITEM,
				Player.ProcessBreakEvent.emEVENT_SENDMAIL,
				Player.ProcessBreakEvent.emEVENT_TRADE,
				Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
				Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
				Player.ProcessBreakEvent.emEVENT_LOGOUT,
				Player.ProcessBreakEvent.emEVENT_DEATH,
			}
		
			GeneralProcess:StartProcess("请等待...", nDelay * Env.GAME_FPS, 
					{self.GotoEventPartTable, self, nEventId, nEventPartId, nType, nCheck, nIsStopNext, nMsgType, nKind, 1}, nil, tbEvent);
			return 0;
		end
	end
	local nFlag, szMsg = EventManager.tbFun:ExeParam(tbNextParam);
	if nFlag == 1 then
		if szMsg then
			me.Msg(szMsg)
		end
		if nSetGlobalObj == 1 then
			Setting:RestoreGlobalObj();
		end		
		return 1, szMsg;
	end
	if nSetGlobalObj == 1 then
		Setting:RestoreGlobalObj();
	end
	
	--使用物品类型
	if nKind == 1 then
		--如果是CreateLink则返回不删除物品
		if nFlag == 3 then
			return 1;
		end
		return 0;
	end
	
	return nIsStopNext;
end

function EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam, nCheckType)
	nEventPartId = tonumber(nEventPartId) or 0;
	if nEventPartId > 0 then
		local nEventId 	= tonumber(EventManager.tbFun:GetParam(tbGParam, "__nEventId")[1]);
		local nPartId 	= tonumber(EventManager.tbFun:GetParam(tbGParam, "__nPartId")[1]);
		if nEventPartId == nPartId then
			print("【活动系统】Error!!!CheckTaskGotoEvent重复调用自己");
			return 0;
		end
		return EventManager:GotoEventPartTable(nEventId, nEventPartId, nCheckType);
	else
		return 1, EventManager.tbFun:StrVal((szReturnMsg or ""));
	end
	return 0;
end

function EventManager:WriteLog(szLog, pPlayer)
	if pPlayer then
		Setting:SetGlobalObj(pPlayer);
		local nEventId = EventManager:GetTempTable().nCurEventId or 0;
		local nPartId = EventManager:GetTempTable().nCurPartId or 0;	
		StatLog:WriteStatLog("stat_info", "eventmanager", tostring(nEventId*10000+nPartId), pPlayer.nId, nEventId, nPartId, szLog)
		--Dbg:WriteLogEx(1, "EventManager", me.szAccount or "", me.szName or "", nEventId..","..nPartId..","..(szLog or ""));
		Setting:RestoreGlobalObj()
	else
		StatLog:WriteStatLog("stat_info", "eventmanager", 0, 0, 0, 0, szLog);
		--Dbg:WriteLogEx(1, "EventManager",  string.format("%s", szLog));
	end
end

function EventManager:NpcDeathApi(szClassName, pNpc, pPlayer, ...)
	if not pNpc or not pPlayer then
		return 0;
	end
	Setting:SetGlobalObj(pPlayer, pNpc);
	local nNpcType 	= pNpc.GetNpcType();
	
	local tbNpc = nil;
	if nNpcType == 1 then --精英
		tbNpc = EventManager:GetNpcClass("_JINGYING");
		if tbNpc ~= nil and tbNpc.OnEventDeath ~= nil then
			tbNpc:OnEventDeath(unpack(arg));
		end
		local nFreeCount, tbFunExecute = SpecialEvent.ExtendAward:DoCheck("JYAndSLDeath"); 
		SpecialEvent.ExtendAward:DoExecute(tbFunExecute);		
	end
	
	if nNpcType == 2 then --首领
		tbNpc = EventManager:GetNpcClass("_SHOULING");
		if tbNpc ~= nil and tbNpc.OnEventDeath ~= nil then
			tbNpc:OnEventDeath(unpack(arg));
		end
		
		local nFreeCount, tbFunExecute = SpecialEvent.ExtendAward:DoCheck("JYAndSLDeath"); 
		SpecialEvent.ExtendAward:DoExecute(tbFunExecute);		
	end
	
	tbNpc = EventManager:GetNpcClass("_ALLNPC");
	if tbNpc ~= nil and tbNpc.OnEventDeath ~= nil then
		tbNpc:OnEventDeath(unpack(arg));
	end
	
	tbNpc = EventManager:GetNpcClass(pNpc.nTemplateId);
	if tbNpc ~= nil and tbNpc.OnEventDeath ~= nil then
		tbNpc:OnEventDeath(unpack(arg));
	end
	
	if szClassName then
		tbNpc = EventManager:GetNpcClass(szClassName);
		if tbNpc ~= nil and tbNpc.OnEventDeath ~= nil then
			tbNpc:OnEventDeath(unpack(arg));
		end		
	end
	Setting:RestoreGlobalObj();
end

--玩家临时table
function EventManager:GetTempTable(nEventId, nPartId)
	local tbTable = me.GetTempTable("EventManager");
	tbTable.MyTable = tbTable.MyTable or {};
	if not nEventId and not nPartId then
		return tbTable.MyTable;	
	end
	tbTable.MyTable[nEventId] = tbTable.MyTable[nEventId] or {};
	if not nPartId then
		return tbTable.MyTable[nEventId];
	end
	tbTable.MyTable[nEventId][nPartId] = tbTable.MyTable[nEventId][nPartId] or {};
	return tbTable.MyTable[nEventId][nPartId];
end

--公用的临时table
function EventManager:GetLibTable(nEventId, nPartId)
	self.LibTable = self.LibTable or {};
	if not nEventId and not nPartId then
		return self.LibTable;
	end
	self.LibTable.MyTable = self.LibTable.MyTable or {};
	self.LibTable.MyTable[nEventId] = self.LibTable.MyTable[nEventId] or {};
	if not nPartId then
		return self.LibTable.MyTable[nEventId];
	end
	self.LibTable.MyTable[nEventId][nPartId] = self.LibTable.MyTable[nEventId][nPartId] or {};
	return self.LibTable.MyTable[nEventId][nPartId];
end

function EventManager:CheckFun(szFun, ...)
	if not EventManager.tbFun.tbLimitParamFun[szFun] then
		print("【活动系统】", "CheckFun找不到该函数类型", szFun);
		return 1;
	end
	local fnFun = EventManager.tbFun.tbLimitParamFun[szFun];
	if not fnFun then
		print("【活动系统】", "CheckFun找不到该函数类型", szFun);
		return 1;		
	end
	local szArg = "";
	for nId, szValue in ipairs(arg) do
		if nId == #arg then
			szArg = szArg .. string.format([["%s"]],szValue);
		else
			szArg = szArg .. string.format([["%s"]],szValue) .. ",";
		end
	end
	return EventManager.tbFun[fnFun](EventManager.tbFun, szArg);
end

function EventManager:ExeFun(szFun, ...)
	if not EventManager.tbFun.tbExeParamFun[szFun] then
		print("【活动系统】", "CheckFun找不到该函数类型", szFun);
		return 1;
	end
	local fnFun = EventManager.tbFun.tbExeParamFun[szFun];
	if not fnFun then
		print("【活动系统】", "CheckFun找不到该函数类型", szFun);
		return 1;		
	end
	local szArg = "";
	for nId, szValue in ipairs(arg) do
		if nId == #arg then
			szArg = szArg .. string.format([["%s"]],szValue);
		else
			szArg = szArg .. string.format([["%s"]],szValue) .. ",";
		end
	end
	return EventManager.tbFun[fnFun](EventManager.tbFun, szArg);
end

function EventManager:CheckszFun(szFun, szParam)
	if not EventManager.tbFun.tbLimitParamFun[szFun] then
		print("【活动系统】", "CheckFun找不到该函数类型", szFun);
		return 1;
	end
	local fnFun = EventManager.tbFun.tbLimitParamFun[szFun];
	if not fnFun then
		print("【活动系统】", "CheckFun找不到该函数类型", szFun);
		return 1;		
	end
	return EventManager.tbFun[fnFun](EventManager.tbFun, szParam);
end

function EventManager:ExeszFun(szFun, szParam)
	if not EventManager.tbFun.tbExeParamFun[szFun] then
		print("【活动系统】", "CheckFun找不到该函数类型", szFun);
		return 1;
	end
	local fnFun = EventManager.tbFun.tbExeParamFun[szFun];
	if not fnFun then
		print("【活动系统】", "CheckFun找不到该函数类型", szFun);
		return 1;		
	end
	return EventManager.tbFun[fnFun](EventManager.tbFun, szParam);
end
