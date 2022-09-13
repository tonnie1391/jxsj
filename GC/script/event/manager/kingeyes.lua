-- 文件名　：kingeyes.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-09-01 11:20:39
-- 描  述  ：运营平台支持
Require("\\script\\event\\manager\\function.lua");

local tbEyes = EventManager.KingEyes;
tbEyes.EVENT_PARAM_MAX = EventManager.EVENT_PARAM_MAX; -- ExParam参数数目
tbEyes.EVENT_QUESTPARAM_MAX = 10;		--调查问卷参数数目
tbEyes.EVENT_OPEN  = 20;			--运营平台开启活动的eventId

if (MODULE_GC_SERVER) then
	
function tbEyes:GetGblBuf()
	self.tbGblBuf = self.tbGblBuf or {};
	return self.tbGblBuf;
end

function tbEyes:SetGblBuf(tbBuf)
	self.tbGblBuf = tbBuf;
	SetGblIntBuf(GBLINTBUF_KINGEYES_EVENT, 0, 1, tbBuf);              --set buff 
end

--获得当前活动开启中的事件
function tbEyes:GetGblBufCurEffectString()
	local tbBuff = self:GetGblBuf();
	local szReMsg = "\n";
	local nCurDate = tonumber(GetLocalDate("%Y%m%d%H%M"));
	for nEId, tbEvent in pairs(tbBuff) do
		if tbEvent.tbPart then
			for nPId, tbPard in pairs(tbEvent.tbPart) do
				local nHaveType = 0;
				local tbParam = EventManager.tbFun:GetParam(tbPard.tbExParam, "Npc", 1);
				if (#tbParam > 0 or nEId == self.EVENT_OPEN) then
					local szIsOpen = "已开启";
					if tbPard.nEndDate > 0 and nCurDate > tbPard.nEndDate then
						szIsOpen = "已过期";
					end
					if tbPard.nStartDate > 0 and nCurDate < tbPard.nStartDate then 
						szIsOpen = "未开启";
					end
					local szNpc = "【Other】";
					if tbParam[1] then
						szNpc = "【Npc:"..tbParam[1].."】";
						nHaveType = 1;
					end
					
					szReMsg = szReMsg ..string.format("%s\t%s\t%s\t%s\t%s\t%s\t%s\n", nEId, nPId,tbPard.nStartDate,tbPard.nEndDate,szIsOpen,szNpc, tbPard.szName or "未知任务");
				end
				tbParam = EventManager.tbFun:GetParam(tbPard.tbExParam, "ItemGId", 1);
				if (#tbParam > 0 or nEId == self.EVENT_OPEN) then
					local szIsOpen = "已开启";
					if tbPard.nEndDate > 0 and nCurDate > tbPard.nEndDate then
						szIsOpen = "已过期";
					end
					if tbPard.nStartDate > 0 and nCurDate < tbPard.nStartDate then 
						szIsOpen = "未开启";
					end
					local szItem = "【Other】";
					if tbParam[1] then
						szItem = "【Item:"..tbParam[1].."】";
					end
					if nHaveType == 1 or tbParam[1] then
						szReMsg = szReMsg ..string.format("%s\t%s\t%s\t%s\t%s\t%s\t%s\n", nEId, nPId,tbPard.nStartDate,tbPard.nEndDate,szIsOpen,szItem,tbPard.szName or "未知任务");
					end
				end
			end
		end	
	end
	return szReMsg;
end

function tbEyes:CloseEvent(nEId, nPId)
	local tbBuff = self:GetGblBuf();
	if not tbBuff[nEId] then
		return 0;
	end
	if not tbBuff[nEId].tbPart or not tbBuff[nEId].tbPart[nPId] then
		return 0;
	end
	local tbEvent = {};
	tbEvent[nEId] = {};
	tbEvent[nEId].tbPart = {};
	tbEvent[nEId].tbPart[nPId] = tbBuff[nEId].tbPart[nPId];
	tbEvent[nEId].tbPart[nPId].nStartDate = 200909010000;
	tbEvent[nEId].tbPart[nPId].nEndDate =   200909020000;
	self:SaveBuf(tbEvent);    
	self:UpdateEvent(tbEvent);
	return 1;
end

function tbEyes:LoadFile(szPath, szQuestPlayerListPath)
	local tbFile = Lib:LoadTabFile(szPath);
	if not tbFile then
		print("EventManager.KingEyes文件加载错误~~~", szPath);
		return;
	end
	local nQuestType = 0;
	local nTmpEventId;
	local nTmpPartId;
	if szQuestPlayerListPath then
		nQuestType = 1;
	end
	local tbEvent = {};
	for nId, tbParam in ipairs(tbFile) do	
		local nEventId = tonumber(tbParam.EventId) or 0;
		local nPartId  = tonumber(tbParam.PartId) or 0; 
		nTmpEventId = nTmpEventId or nEventId;
		nTmpPartId  = nTmpPartId or nPartId;
		local nStartDate = EventManager.tbFun:ClearString(tbParam.StartDate);
		local nEndDate = EventManager.tbFun:ClearString(tbParam.EndDate);
	    nStartDate , nEndDate = EventManager.tbFun:DateFormat(nStartDate, nEndDate);		
		if not nEndDate then
			print("EventManager.KingEyes【活动系统出错】时间格式出错");
			return;
		end	
		tbEvent[nEventId] = tbEvent[nEventId] or {};
		tbEvent[nEventId].tbPart = tbEvent[nEventId].tbPart or {};
		tbEvent[nEventId].tbPart[nPartId] = {};	
		tbEvent[nEventId].tbPart[nPartId].szName = EventManager.tbFun:ClearString(tbParam.Name);
		tbEvent[nEventId].tbPart[nPartId].szSubKind = EventManager.tbFun:ClearString(tbParam.SubKind);
		if tbEvent[nEventId].tbPart[nPartId].szSubKind == "" then
			tbEvent[nEventId].tbPart[nPartId].szSubKind = "default";
		end
		--tbEvent[nEventId].tbPart[nPartId].szExClass; --不需要exclass
		tbEvent[nEventId].tbPart[nPartId].nStartDate = nStartDate;
		tbEvent[nEventId].tbPart[nPartId].nEndDate =   nEndDate;
		tbEvent[nEventId].tbPart[nPartId].tbExParam = {};
		for nParam = 1, self.EVENT_PARAM_MAX do
			local szParamName = string.format("ExParam%s", nParam);
			local szParam = EventManager.tbFun:ClearString(tbParam[szParamName]);
			tbEvent[nEventId].tbPart[nPartId].tbExParam [nParam] = szParam;
      	end
      	
      	tbEvent[nEventId].tbPart[nPartId].tbQuestParam = {};	--调查问卷弹出条件
      	tbEvent[nEventId].tbPart[nPartId].nQuestType = nQuestType; --调查问卷弹出条件方式（0，条件，1，按名单）;
      	for nParam = 1, self.EVENT_QUESTPARAM_MAX do
      		local szParamName = string.format("QuestParam%s", nParam);
			local szParam = EventManager.tbFun:ClearString(tbParam[szParamName]);
			tbEvent[nEventId].tbPart[nPartId].tbQuestParam [nParam] = szParam;
      	end
		table.insert(tbEvent[nEventId].tbPart[nPartId].tbQuestParam, string.format("__nEventId:%s", nEventId));
		table.insert(tbEvent[nEventId].tbPart[nPartId].tbQuestParam, string.format("__nPartId:%s", nPartId));
   end
   
   if nQuestType == 1 and nTmpEventId and nTmpPartId then
   		SpecialEvent.Questionnaires:KingEyesLoadFile(nTmpEventId, nTmpPartId, szQuestPlayerListPath);
   end
   
   self:SaveBuf(tbEvent);
   return tbEvent;
end  

function tbEyes:SaveBuf(tbEvent)
	local tbBuf = self:GetGblBuf();
	for nEId, tbEventData in pairs(tbEvent) do
		tbBuf[nEId] 			= tbBuf[nEId] or {};
		tbBuf[nEId].szName 		= tbEventData.szName or tbBuf[nEId].szName;
		tbBuf[nEId].nStartDate 	= tbEventData.nStartDate or tbBuf[nEId].nStartDate;
		tbBuf[nEId].nEndDate 	= tbEventData.nEndDate or tbBuf[nEId].nEndDate;
		tbBuf[nEId].szDesc		= tbEventData.szDesc or tbBuf[nEId].szDesc;
		tbBuf[nEId].nTaskBatch	= tbEventData.nTaskBatch or tbBuf[nEId].nTaskBatch;
		if tbEventData.tbPart then
			for nPId, tbPartData in pairs(tbEventData.tbPart) do
				tbBuf[nEId].tbPart 		= tbBuf[nEId].tbPart or {};
				tbBuf[nEId].tbPart[nPId] = tbPartData;
			end
		end
	end
	self:SetGblBuf(tbBuf);
end
        
function tbEyes:LoadBuf()
	local tbBuf = self:GetGblBuf();
	local tbQuestBuf = SpecialEvent.Questionnaires:GetGblBuf(); --调查问卷
	--去除过期事件
	local nCurDate = tonumber(GetLocalDate("%Y%m%d%H%M"));
	local tbClearEventId = {};
	for nEventId , tbTempEvent  in pairs(tbBuf) do
		if tbTempEvent.nEndDate and tbTempEvent.nEndDate < nCurDate then
			table.insert(tbClearEventId, nEventId);
		else
	  		for nPartId , tbPart in pairs(tbTempEvent.tbPart) do
			        	if tbPart.nEndDate and tbPart.nEndDate < nCurDate then
			        		tbTempEvent.tbPart[nPartId] = nil;
			        		
			        		--调查问卷
			        		if tbQuestBuf and tbQuestBuf[nEventId] and tbQuestBuf[nEventId][nPartId] then
			        			tbQuestBuf[nEventId][nPartId] = nil;
			        		end			        		
			        	end	        	
			end
			--event下没有part删掉整个event
			if Lib:CountTB(tbTempEvent.tbPart) <= 0 then
				table.insert(tbClearEventId, nEventId);
			end
		end
	end	
	
	for _, nEventId in pairs(tbClearEventId) do
		tbBuf[nEventId] = nil;
	end
	
	self:SetGblBuf(tbBuf); --保存修改后的table
	SpecialEvent.Questionnaires:SetGblBuf(tbQuestBuf);	--调查问卷
	return tbBuf;
end

function tbEyes:UpdateEvent(tbEvent)                               
	for nEventId , tbTempEvent  in pairs(tbEvent) do
		if tbTempEvent.szName then
			EventManager:SetEventName(nEventId, tbTempEvent.szName);
		end
		
		if tbTempEvent.szDesc then
			EventManager:SetEventDesc(nEventId, tbTempEvent.szDesc);
		end
		
		if tbTempEvent.nStartDate and tbTempEvent.nStartDate >= 0 and 
			tbTempEvent.nEndDate and tbTempEvent.nEndDate >= 0 then
			EventManager:SetEventDate(nEventId, tbTempEvent.nStartDate, tbTempEvent.nEndDate);
		end
		
		if tbTempEvent.nTaskBatch then
			EventManager:SetEventBatch(nEventId, tbTempEvent.nTaskBatch);
		end

		if tbTempEvent.tbPart then
	  		for nPartId , tbPart in pairs(tbTempEvent.tbPart) do
				if tbPart.szName then
					EventManager:SetEventPartName(nEventId, nPartId, tbPart.szName);
				end
				if tbPart.szSubKind and tbPart.szSubKind ~= "" and tbPart.szSubKind ~= "default" then
					EventManager:SetEventSubKind(nEventId, nPartId, tbPart.szSubKind);
				end
				if tbPart.nStartDate and tbPart.nStartDate >= 0 and tbPart.nEndDate and tbPart.nEndDate >= 0 then
	           		EventManager:SetPartDate(nEventId, nPartId, tbPart.nStartDate, tbPart.nEndDate)
	           	end
				if tbPart.tbExParam then
		           	for nParam , szParam in pairs(tbPart.tbExParam) do
						EventManager:SetPartParam(nEventId, nPartId, nParam, szParam);
					end
				end
				
				if tbPart.tbQuestParam and EventManager.tbFun:GetParam(tbPart.tbQuestParam, "LinkQuestUrl", 1)[1] then
					SpecialEvent.Questionnaires:SendDataGC(nEventId, nPartId, tbPart.nStartDate, tbPart.nEndDate, tbPart.nQuestType, tbPart.tbQuestParam);
				end
			end
		    EventManager:UpdateEvent(nEventId);
		end
	end
	return 1;
end

function tbEyes:GCStartEvent()
	if not self.tbGblBuf then
		self.tbGblBuf = self.tbGblBuf or {};
		local tbBuff = GetGblIntBuf(GBLINTBUF_KINGEYES_EVENT, 0);
		if tbBuff and type(tbBuff) == "table" then
			self.tbGblBuf = tbBuff;
		end
	end
end

function tbEyes:GCReloadEventByFile(szPath, szPlayerListPath)
	local tbEvent = self:LoadFile(szPath, szPlayerListPath);
	if tbEvent then
		return self:UpdateEvent(tbEvent);
	end
	return 0;
end

function tbEyes:GSReloadEvent()
	self:GCStartEvent();
	SpecialEvent.Questionnaires:GCStartEvent();
	local tbEvent = self:LoadBuf();
	self:UpdateEvent(tbEvent);
end

end