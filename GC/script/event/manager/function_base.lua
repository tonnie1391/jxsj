--base的基础函数
local tbFun = {};
EventManager.tbFunction_Base = tbFun;

function tbFun:SetTimerStart(tbSelf)
	local tbStartTime = EventManager.tbFun:GetParam(tbSelf.tbEventPart.tbParam, "TimerStart", 1);
	if #tbStartTime <= 0 then
		tbStartTime[#tbStartTime + 1] = tostring(EventManager.EVENT_TIMER_DATE_RSTART);
	end
	
	for _, szStartTime in pairs(tbStartTime) do
		local tbStr = Lib:SplitStr(szStartTime, ",");
		for _,nStartTime in pairs(tbStr) do
			if tonumber(nStartTime) ~= nil then
				local nCount = #tbSelf.tbTimer.tbStartTime;
				tbSelf.tbTimer.tbStartTime[nCount + 1] = {};
				tbSelf.tbTimer.tbStartTime[nCount + 1].tbPartDate 	= {tbSelf.tbEventPart.nStartDate, tbSelf.tbEventPart.nEndDate};
				tbSelf.tbTimer.tbStartTime[nCount + 1].nTime     	= nStartTime;
				tbSelf.tbTimer.tbStartTime[nCount + 1].nId 	   		= tbSelf.tbEventPart.nId;
				tbSelf.tbTimer.tbStartTime[nCount + 1].tbFun 	   	= {{"ExeStartFun"}, {"ExeEndFun"}};
			end
		end
	end
	return tbSelf;
end

function tbFun:SetTimerEnd(tbSelf)
	local tbEndTime = EventManager.tbFun:GetParam(tbSelf.tbEventPart.tbParam, "TimerEnd", 1);
	
	tbEndTime[#tbEndTime + 1] = tostring(EventManager.EVENT_TIMER_DATE_RSTART);
	
	for _, szEndTime in pairs(tbEndTime) do
		local tbStr = Lib:SplitStr(szEndTime, ",");
		for _,nEndTime in pairs(tbStr) do
			if tonumber(nEndTime) ~= nil and tonumber(nEndTime) ~= 0 then
				local nCount = #tbSelf.tbTimer.tbEndTime;
				tbSelf.tbTimer.tbEndTime[nCount + 1] = {};
				tbSelf.tbTimer.tbEndTime[nCount + 1].tbPartDate 	= {tbSelf.tbEventPart.nStartDate, tbSelf.tbEventPart.nEndDate};
				tbSelf.tbTimer.tbEndTime[nCount + 1].nTime 		= nEndTime;
				tbSelf.tbTimer.tbEndTime[nCount + 1].nId 		= tbSelf.tbEventPart.nId;
				tbSelf.tbTimer.tbEndTime[nCount + 1].tbFun 		={{"ExeEndFun"}};
			end
		end
	end
	return tbSelf;
end

function tbFun:SetNpc(tbSelf)
	--创建OnDialog
	if (not MODULE_GAMESERVER) then
		return tbSelf
	end	
	local tbNpcId = EventManager.tbFun:GetParam(tbSelf.tbEventPart.tbParam, "Npc", 1);
	for nNpc, szParam in pairs(tbNpcId) do
		local nCount = #tbSelf.tbDialog + 1;
		tbSelf.tbDialog[nCount] = {};
		local tbParam = EventManager.tbFun:SplitStr(szParam);
		tbSelf.tbDialog[nCount].varNpc 		= tonumber(tbParam[1]);
		tbSelf.tbDialog[nCount].tbDialog 	= {tbSelf.tbEventPart.szName, tbSelf.OnDialog, tbSelf};
	end
	local tbNpc = EventManager.tbFun:GetParam(tbSelf.tbEventPart.tbParam, "NpcType", 1);
	for nNpc, szParam in pairs(tbNpc) do
		local nCount = #tbSelf.tbDialog + 1;
		tbSelf.tbDialog[nCount] = {};
		local tbParam = EventManager.tbFun:SplitStr(szParam);
		tbSelf.tbDialog[nCount].varNpc 		= tbParam[1];
		tbSelf.tbDialog[nCount].tbDialog 	= {tbSelf.tbEventPart.szName, tbSelf.OnDialog, tbSelf};
	end	
	return tbSelf;
end

function tbFun:SetMapPath(tbSelf)
	local tbMapParam = EventManager.tbFun:GetParam(tbSelf.tbEventPart.tbParam, "SetCallNpcId", 1);
	local nCallNpcListId = 0;
	if #tbMapParam > 0 then
		nCallNpcListId = tonumber(tbMapParam[1]);
		local tbStartTime = EventManager.tbFun:GetParam(tbSelf.tbEventPart.tbParam, "TimerStart", 1);
		for _, szStartTime in pairs(tbStartTime) do
			local tbStr = Lib:SplitStr(szStartTime, ",");
			for _,nStartTime in pairs(tbStr) do
				if tonumber(nStartTime) ~= nil and tonumber(nStartTime) ~= 0 then
					local nCount = #tbSelf.tbTimer.tbStartTime;
					tbSelf.tbTimer.tbStartTime[nCount + 1] = {};
					tbSelf.tbTimer.tbStartTime[nCount + 1].tbPartDate	= {tbSelf.tbEventPart.nStartDate, tbSelf.tbEventPart.nEndDate};
					tbSelf.tbTimer.tbStartTime[nCount + 1].nTime 	 	= nStartTime;
					tbSelf.tbTimer.tbStartTime[nCount + 1].nId 	 		= tbSelf.tbEventPart.nId;
					tbSelf.tbTimer.tbStartTime[nCount + 1].tbFun 		= {{"ExeNpcStartFun", EventManager.KIND_CALLBOSS_GC, nCallNpcListId}, {"ExeEndFun", EventManager.KIND_CALLBOSS_GC, nCallNpcListId}};
				end
			end
		end
		
		local tbEndTime = EventManager.tbFun:GetParam(tbSelf.tbEventPart.tbParam, "TimerEnd", 1);
		for _, szEndTime in pairs(tbEndTime) do
			local tbStr = Lib:SplitStr(szEndTime, ",");
			for _,nEndTime in pairs(tbStr) do
				if tonumber(nEndTime) ~= nil and tonumber(nEndTime) ~= 0 then
					local nCount = #tbSelf.tbTimer.tbEndTime;
					tbSelf.tbTimer.tbEndTime[nCount + 1] = {};
					tbSelf.tbTimer.tbEndTime[nCount + 1].tbPartDate 	= {tbSelf.tbEventPart.nStartDate, tbSelf.tbEventPart.nEndDate};
					tbSelf.tbTimer.tbEndTime[nCount + 1].nTime 		= nEndTime;
					tbSelf.tbTimer.tbEndTime[nCount + 1].nId 	 	= tbSelf.tbEventPart.nId;
					tbSelf.tbTimer.tbEndTime[nCount + 1].tbFun 		={{"ExeNpcEndFun", EventManager.KIND_CALLBOSS_GC, nCallNpcListId}};
				end
			end
		end
	end
	return tbSelf;
end

function tbFun:SetDropNpc(tbSelf)
	local tbNpcId = EventManager.tbFun:GetParam(tbSelf.tbEventPart.tbParam, "DropNpc", 1);
	for nNpc, szNpcId in pairs(tbNpcId) do
		local nCount = #tbSelf.tbNpcDrop + 1;
		--local tbNpc = EventManager.tbFun:SplitStr(szNpcId);
		tbSelf.tbNpcDrop[nCount] = {}
		tbSelf.tbNpcDrop[nCount].nNpcId = tonumber(szNpcId);
		tbSelf.tbNpcDrop[nCount].tbFun = {{"ExeStartFun"},{"ExeEndFun"}};
	end
	return tbSelf;
end

function tbFun:SetDropNpcType(tbSelf)
	local tbDropNpcType = EventManager.tbFun:GetParam(tbSelf.tbEventPart.tbParam, "DropNpcType", 1);
	for nNpc, szNpcName in pairs(tbDropNpcType) do
		local tbNpc = EventManager.tbFun:SplitStr(szNpcName);
		local nCount = #tbSelf.tbNpcDrop + 1;
		tbSelf.tbNpcDrop[nCount] = {}
		tbSelf.tbNpcDrop[nCount].szNpcName = tbNpc[1];
		tbSelf.tbNpcDrop[nCount].tbFun = {{"ExeStartFun"},{"ExeEndFun"}};
	end	
	return tbSelf;
end

function tbFun:SetItem(tbSelf)
	--定义物品OnUse
	local tbItemName = EventManager.tbFun:GetParam(tbSelf.tbEventPart.tbParam, "Item", 1)
	for _, szItemName in pairs(tbItemName) do
		local tbItemName = EventManager.tbFun:SplitStr(szItemName);
		local tbEventManager_OnUse = nil;
		local tbEventManager_InitGenInfo = nil;
		local tbClass = EventManager:GetItemClass(tbItemName[1]);
		local nEventId = tbSelf.tbEvent.nId or 0;
		local nPartId  = tbSelf.tbEventPart.nId or 0;
		tbClass[nEventId] = tbClass[nEventId] or {};
		tbClass[nEventId][nPartId] = {};
		Lib:MergeFunTable(tbClass[nEventId][nPartId], tbSelf);
		
		--不重载OnUse
		local tbItem = Item:GetClass(tbItemName[1]);
		local tbUseBase = {};
		tbUseBase.OnUse=tbItem.OnUse
		if tbItem.InitGenInfo ~= Item.tbClassBase.InitGenInfo then
			tbUseBase.InitGenInfo = tbItem.InitGenInfo;
		end
		if tbItem.IsPickable ~= Item.tbClassBase.IsPickable then
			tbUseBase.IsPickable = tbItem.IsPickable;
		end
		if tbItem.PickUp ~= Item.tbClassBase.PickUp then
			tbUseBase.PickUp = tbItem.PickUp;
		end
		if tbItem.GetTip ~= Item.tbClassBase.GetTip then
			tbUseBase.GetTip = tbItem.GetTip;
		end						
		Lib:MergeFunTable(tbItem, tbSelf);
		for szKey, fnFun in pairs(tbUseBase) do
			tbItem[szKey] = fnFun;
		end
	end
	
	local tbItemNameId = EventManager.tbFun:GetParam(tbSelf.tbEventPart.tbParam, "ItemGId", 1);
	for _, szItemName in pairs(tbItemNameId) do
		local tbItemName = EventManager.tbFun:SplitStr(szItemName);
		local tbEventManager_OnUse = nil;
		local tbEventManager_InitGenInfo = nil;
		local tbClass = EventManager:GetItemIdClass(tbItemName[1]);
		local nEventId = tbSelf.tbEvent.nId or 0;
		local nPartId  = tbSelf.tbEventPart.nId or 0;
		tbClass[nEventId] = tbClass[nEventId] or {};
		tbClass[nEventId][nPartId] = {};
		Lib:MergeFunTable(tbClass[nEventId][nPartId], tbSelf);
		
		--不重载OnUse
		local tbBaseProp = KItem.GetItemBaseProp(unpack(EventManager.tbFun:SplitStr(tbItemName[1])));
		if tbBaseProp and tbBaseProp.szClass ~= "" then
			local tbItem = Item:GetClass(tbBaseProp.szClass);
			local tbUseBase = {};
			tbUseBase.OnUse=tbItem.OnUse
			if tbItem.InitGenInfo ~= Item.tbClassBase.InitGenInfo then
				tbUseBase.InitGenInfo = tbItem.InitGenInfo;
			end
			if tbItem.IsPickable ~= Item.tbClassBase.IsPickable then
				tbUseBase.IsPickable = tbItem.IsPickable;
			end
			if tbItem.PickUp ~= Item.tbClassBase.PickUp then
				tbUseBase.PickUp = tbItem.PickUp;
			end
			if tbItem.GetTip ~= Item.tbClassBase.GetTip then
				tbUseBase.GetTip = tbItem.GetTip;
			end						
			Lib:MergeFunTable(tbItem, tbSelf);
			for szKey, fnFun in pairs(tbUseBase) do
				tbItem[szKey] = fnFun;
			end
		end
	end		
	return tbSelf;
end

