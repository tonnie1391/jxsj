local tb	= Task:GetTarget("WithProcessByMutiMap");
tb.szTargetName	= "WithProcessByMutiMap";
tb.REFRESH_FRAME	= 18;

function tb:Init(nNpcTempId, szMapId, nIntervalTime, szProcessInfo, szSucMsg, szFailedMsg,  tbItem, nNeedCount, szDynamicDesc, szStaticDesc, szBeforePop, szLaterPop, szPos, nReviveTime)
	self.nNpcTempId			= nNpcTempId;
	self.szNpcName			= KNpc.GetNameByTemplateId(nNpcTempId);
	self.szMapId			= szMapId;
	local tbMap				= Lib:SplitStr(szMapId);
	
	self.tbMapId = {};
	local nMapNameId = 0;
	for nIndex, szMapId in pairs(tbMap) do
		local nMapId = tonumber(szMapId);
		if (IsMapLoaded(nMapId) == 1) then
			self.tbMapId[nMapId] = 1;
			if (nMapNameId <= 0) then
				nMapNameId = nMapId;
			end
		end
	end

	self.szMapName			= Task:GetMapName(nMapNameId);
	self.nIntervalTime 		= nIntervalTime * tb.REFRESH_FRAME;
	self.szProcessInfo		= szProcessInfo or "Đang tiến hành";
	self.szSucMsg			= szSucMsg or "Thành công";
	self.szFailedMsg		= szFailedMsg or "Thất bại";
	self.ItemList			= self:ParseItem(tbItem);
	self.nNeedCount			= nNeedCount;
	self.szDynamicDesc		= szDynamicDesc;
	self.szStaticDesc	  	= szStaticDesc;
	self.szBeforePop		= szBeforePop;
	self.szLaterPop			= szLaterPop;
	
	if (MODULE_GAMESERVER) then
		self.tbNpcSet		= self:CreatNpc(szPos);
	end
	if (not self.tbNpcSet) then
		self.tbNpcSet		= self:ParsePos(szPos);
	end
	self.nReviveTime		= tonumber(nReviveTime);
	self:RegistStaticTimer();
end;


function tb:ParsePos(szPos)
	local tbRet = {};
	
	if (szPos and szPos ~= "") then
		local tbTrack = Lib:SplitStr(szPos, "\n")
		for i=1, #tbTrack do
			if (tbTrack[i] and tbTrack[i] ~= "") then
				local tbPos = Lib:SplitStr(tbTrack[i]);
				local tbInfo = {};
				for nMapId, _ in pairs(self.tbMapId) do
					tbInfo.nMapId = nMapId;
					tbInfo.nX = tonumber(tbPos[1]);
					tbInfo.nY = tonumber(tbPos[2]);					
				end
				tbRet[#tbRet + 1] = tbInfo;
			end
		end
	end
	
	return tbRet;
end

function tb:RegistStaticTimer()
	if (not MODULE_GAMESERVER or self.nStaticTimerId) then
		return;
	end
	local nIsHaveMap = 0;
	for nMapId, _ in pairs(self.tbMapId) do
		if SubWorldID2Idx(nMapId) >= 0 then
			nIsHaveMap = 1;
			break;
		end
	end
		
	if (nIsHaveMap == 0 or #self.tbNpcSet <= 0) then
		return;
	end
		
	self.nStaticTimerId = Timer:Register(self.REFRESH_FRAME, self.OnStaticTimer, self);
	return 1;
end

function tb:UnRegistStaticTimer()
	if (MODULE_GAMESERVER and self.nStaticTimerId) then
		Timer:Close(self.nStaticTimerId);
		self.nStaticTimerId	= nil;
	end;
end

function tb:OnStaticTimer()
	for _,item in ipairs(self.tbNpcSet) do
		if (item.nNpcIdx <= 0) then
			if (not item.nReviveTime) then
				return;
			end
			if (item.nReviveTime <= 0) then
				local pNpc	= KNpc.Add2(self.nNpcTempId, 1, -1, item.nMapId, item.nMapPosX, item.nMapPosY);
				item.nNpcIdx = pNpc.dwId;
				Task.tbToBeDelNpc[pNpc.dwId] = 1;
				item.nReviveTime = nil;
			else
				item.nReviveTime = item.nReviveTime - 1;
			end
		else	
			local pNpc = KNpc.GetById(item.nNpcIdx);
			if (not pNpc) then
				print("[Task Error]: TaskNpcMiss!" , self.nNpcTempId, item.nMapPosX, item.nMapPosY);
				local pNpc = KNpc.Add2(self.nNpcTempId, 1, -1, item.nMapId, item.nMapPosX, item.nMapPosY);
				item.nNpcIdx = pNpc.dwId;
				Task.tbToBeDelNpc[pNpc.dwId] = 1;
				item.nReviveTime = nil;				
			end;
		end;
	end
end

function tb:CreatNpc(szPos)
	local tbRet = {};
	local tbMapId = {};

	for nMapId, _ in pairs(self.tbMapId) do
		if SubWorldID2Idx(nMapId) >= 0 then
			tbMapId[nMapId] = 1;
		end
	end

	if (Lib:CountTB(tbMapId) <= 0) then
		return {};
	end

	if (szPos and szPos ~= "") then
		local tbTrack = Lib:SplitStr(szPos, "\n")
		for i=1, #tbTrack do
			if (tbTrack[i] and tbTrack[i] ~= "") then
				local tbPos = Lib:SplitStr(tbTrack[i]);
				for nMapId, _ in pairs(tbMapId) do
					local tbInfo = {};
					tbInfo.nMapPosX = tonumber(tbPos[1]);
					tbInfo.nMapPosY = tonumber(tbPos[2]);
					tbInfo.nMapId = nMapId;
					local pNpc = KNpc.Add2(self.nNpcTempId, 1, -1, tbInfo.nMapId, tbInfo.nMapPosX, tbInfo.nMapPosY);
					if (not pNpc or pNpc.nIndex == 0) then
						print("[Task Error]:"..self.nNpcTempId.."  Thêm thất bại!");
						return {};
					end

					Task.tbToBeDelNpc[pNpc.dwId] = 1;
					tbInfo.nNpcIdx = pNpc.dwId;
					tbInfo.nReviveTime = -1;
					tbRet[#tbRet + 1] = tbInfo;
				end
			end
		end
	end
	return tbRet;
end


function tb:ParseItem(szItemSet)
	local tbRet = {};
	local tbItem = Lib:SplitStr(szItemSet, "\n")
	for i=1, #tbItem do
		if (tbItem[i] and tbItem[i] ~= "") then
			local tbTemp = loadstring(string.gsub(tbItem[i],"{.+,(.+),(.+),(.+),(.+),(.+),(.+)}", "return {tonumber(%1),tonumber(%2),tonumber(%3),tonumber(%4),tonumber(%5),tonumber(%6)}"))()
			for i = 1, tbTemp[6] do
				table.insert(tbRet, {tbTemp[1],tbTemp[2],tbTemp[3],tbTemp[4],tbTemp[5]});
			end
		end
	end
	
	return tbRet;
end;


function tb:Start()
	self.nCount = 0;
	self:Register();
end;

function tb:Save(nGroupId, nStartTaskId)
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	self.tbSaveTask	= {	-- 这里保存下来，以后随时可以自行同步客户端
		nGroupId		= nGroupId,
		nStartTaskId	= nStartTaskId,
	};
	pPlayer.SetTask(nGroupId, nStartTaskId, self.nCount);
	
	return 1;
end;


function tb:Load(nGroupId, nStartTaskId)
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	self.tbSaveTask	= {	-- 这里保存下来，以后随时可以自行同步客户端
		nGroupId		= nGroupId,
		nStartTaskId	= nStartTaskId,
	};
	self.nCount		= pPlayer.GetTask(nGroupId, nStartTaskId);
	if (not self:IsDone()) then	-- 本目标是一旦达成后不会失效的
		self:Register();
	end;
	
	return 1;
end;


function tb:IsDone()
	return self.nCount >= self.nNeedCount;
end;


function tb:GetDesc()
	local bHasTag = 0;
	local bTagStart, bTagEnd = string.find(self.szDynamicDesc, "%%d");
	if (bTagEnd) then
		bHasTag = bHasTag + 1;	
		bTagStart, bTagEnd = string.find(self.szDynamicDesc, "%%d", bTagEnd + 1);
		if (bTagEnd) then
			bHasTag = bHasTag + 1;
		end
	end
	
	if (bHasTag == 1) then
		return string.format(self.szDynamicDesc, self.nCount);
	elseif (bHasTag == 2) then
		return string.format(self.szDynamicDesc, self.nCount, self.nNeedCount);
	else
		return self.szDynamicDesc;
	end
end;


function tb:GetStaticDesc()
	return self.szStaticDesc;
end;




function tb:Close(szReason)
	self:UnRegister();
end;


function tb:Register()
	self.tbTask:AddExclusiveDialog(self.nNpcTempId, self.SelectOpenBox, self);
end;

function tb:UnRegister()
	self.tbTask:RemoveNpcExclusiveDialog(self.nNpcTempId);
end;


function tb:SelectOpenBox()
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	local nMyMapId = pPlayer.GetMapId();
	if (not self.tbMapId[nMyMapId]) then
		pPlayer.Msg("Không phải bản đồ cần mở"..self.szNpcName.."Hãy đến "..self.szMapName)
		return;
	end

	local nIsCanDoTarget, szErrorMsg = Task:IsCanDoTargetSpeCondition(pPlayer, self.tbTask.nTaskId, self.tbTask.nCurStep);
	if (nIsCanDoTarget ~= 1) then
		pPlayer.Msg(szErrorMsg);
		return;
	end 
	
	if (self:IsDone()) then
		pPlayer.Msg(self.szFailedMsg)
		return;
	end;
	
	self.nCurTagIdx = him.dwId;
	
	Task:SetProgressTag(self, pPlayer);
	KTask.StartProgressTimer(pPlayer, self.nIntervalTime, self.szProcessInfo);
end;


function tb:OnProgressFull()
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end

	local nExist = 0;
	for _, item in ipairs(self.tbNpcSet) do
		if (item.nNpcIdx == self.nCurTagIdx) then
			nExist = 1;
			item.nNpcIdx = -1;
			item.nReviveTime = self.nReviveTime;
			local pNpc = KNpc.GetById(self.nCurTagIdx);
			if (not pNpc or pNpc.nIndex == 0) then
				return;
			end
			Task.tbToBeDelNpc[pNpc.dwId] = 0;
			pNpc.Delete();
			break;
		end
	end
	if (nExist ~= 1) then
		return;
	end
	
	local nTotleCount = #self.ItemList;
	
	
	if (nTotleCount > 0 and TaskCond:CanAddItemsIntoBag(self.ItemList) ~= 1) then
		pPlayer.Msg("Túi đã đầy, không thể chứa vật phẩm mới!")
		return;
	end
	
	pPlayer.Msg(self.szSucMsg);
	self.nCount	= self.nCount + 1;
	local tbSaveTask	= self.tbSaveTask;
	if (MODULE_GAMESERVER and tbSaveTask) then	-- 自行同步到客户端，要求客户端刷新
		pPlayer.SetTask(tbSaveTask.nGroupId, tbSaveTask.nStartTaskId, self.nCount, 1);
		KTask.SendRefresh(pPlayer, self.tbTask.nTaskId, self.tbTask.nReferId, tbSaveTask.nGroupId);
	end;
	
	for _, tbItem in ipairs(self.ItemList) do
		Task:AddItem(pPlayer, tbItem);
	end
	
	if (self:IsDone()) then
		pPlayer.Msg("Mục tiêu:"..self:GetStaticDesc());
		self:UnRegister()	-- 本目标是一旦达成后不会失效的
		self.tbTask:OnFinishOneTag();
	end
end;
