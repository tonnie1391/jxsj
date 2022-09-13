--- 进度条目标
local tb	= Task:GetTarget("WithProcess");
tb.szTargetName	= "WithProcess";
tb.REFRESH_FRAME	= 18;

function tb:Init(nNpcTempId, nMapId, nIntervalTime, szProcessInfo, szSucMsg, szFailedMsg,  tbItem, nNeedCount, szDynamicDesc, szStaticDesc, szBeforePop, szLaterPop, szPos, nReviveTime)
	self.nNpcTempId			= nNpcTempId;
	self.szNpcName			= KNpc.GetNameByTemplateId(nNpcTempId);
	self.nMapId				= nMapId;
	self.szMapName			= Task:GetMapName(nMapId);
	self.nIntervalTime 		= nIntervalTime * tb.REFRESH_FRAME;
	self.szProcessInfo		= szProcessInfo or "进行中";
	self.szSucMsg			= szSucMsg or "成功";
	self.szFailedMsg		= szFailedMsg or "失败";
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
				tbRet[i] = {};
				local tbPos = Lib:SplitStr(tbTrack[i]);
				tbRet[i].nX = tonumber(tbPos[1]);
				tbRet[i].nY = tonumber(tbPos[2]);
			end
		end
	end
	
	return tbRet;
end

function tb:RegistStaticTimer()
	if (MODULE_GAMESERVER and not self.nStaticTimerId) then
		if (self.nMapId >= 0 and #self.tbNpcSet >= 1) then
			self.nStaticTimerId = Timer:Register(self.REFRESH_FRAME, self.OnStaticTimer, self);
		end
	end;
end

function tb:UnRegistStaticTimer()
	if (MODULE_GAMESERVER and self.nStaticTimerId) then
		Timer:Close(self.nStaticTimerId);
		self.nStaticTimerId	= nil;
	end;
end

function tb:OnStaticTimer()
	local oldHim = him;
	for _,item in ipairs(self.tbNpcSet) do
		if (item.nNpcIdx <= 0) then
			if (not item.nReviveTime) then
				return;
			end
			if (item.nReviveTime <= 0) then
				him	= KNpc.Add2(self.nNpcTempId, 1, -1, self.nMapId, item.nMapPosX, item.nMapPosY);
				item.nNpcIdx = him.dwId;
				Task.tbToBeDelNpc[him.dwId] = 1;
				item.nReviveTime = nil;
			else
				item.nReviveTime = item.nReviveTime - 1;
			end
		else	
			local pNpc = KNpc.GetById(item.nNpcIdx);
			if (not pNpc) then
				print("[Task Error]: TaskNpcMiss！" , self.nNpcTempId, item.nMapPosX, item.nMapPosY);
				him	= KNpc.Add2(self.nNpcTempId, 1, -1, self.nMapId, item.nMapPosX, item.nMapPosY);
				item.nNpcIdx = him.dwId;
				Task.tbToBeDelNpc[him.dwId] = 1;
				item.nReviveTime = nil;				
			end;
		end;
	end
	him = oldHim;
end

function tb:CreatNpc(szPos)
	local tbRet = {};
	local oldhim = him;
	if SubWorldID2Idx(self.nMapId) < 0 then
		return {};
	end
	if (szPos and szPos ~= "") then
		local tbTrack = Lib:SplitStr(szPos, "\n")
		for i=1, #tbTrack do
			if (tbTrack[i] and tbTrack[i] ~= "") then
				tbRet[i] = {};
				local tbPos = Lib:SplitStr(tbTrack[i]);
				tbRet[i].nMapPosX = tonumber(tbPos[1]);
				tbRet[i].nMapPosY = tonumber(tbPos[2]);
				him	= KNpc.Add2(self.nNpcTempId, 1, -1, self.nMapId, tbRet[i].nMapPosX, tbRet[i].nMapPosY);
				if (not him or him.nIndex == 0) then
					print("[Task Error]:"..self.nNpcTempId.."  添加失败！");
					return {};
				end
				Task.tbToBeDelNpc[him.dwId] = 1;
				tbRet[i].nNpcIdx = him.dwId;
				tbRet[i].nReviveTime = -1;
			end
		end
	end
	
	him = oldhim;
	
	return tbRet;
end


function tb:ParseItem(szItemSet)
	local tbRet = {};
	local tbItem = Lib:SplitStr(szItemSet, "\n")
	for i=1, #tbItem do
		if (tbItem[i] and tbItem[i] ~= "") then
			-- 每行的物品格式：{物品名, nGenre, nDetail, nParticular, nLevel, nSeries, nItemNum}
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


-- 玩家选择打开箱子[S]
function tb:SelectOpenBox()
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	if (self.nMapId ~= 0 and self.nMapId ~= pPlayer.GetMapId()) then
		pPlayer.Msg("你要开启的不是本地图的"..self.szNpcName.."请前往"..self.szMapName)
		return;
	end;
	
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
	local oldHim = him;
	local nExist = 0;
	for _, item in ipairs(self.tbNpcSet) do
		if (item.nNpcIdx == self.nCurTagIdx) then
			nExist = 1;
			item.nNpcIdx = -1;
			item.nReviveTime = self.nReviveTime;
			him = KNpc.GetById(self.nCurTagIdx);
			if (not him or him.nIndex == 0) then
				him = oldHim;
				return;
			end
			Task.tbToBeDelNpc[him.dwId] = 0;
			him.Delete();
			break;
		end
	end
	him = oldHim;
	if (nExist ~= 1) then
		return;
	end
	
	local nTotleCount = #self.ItemList;
	
	
	--if (TaskCond:HaveBagSpace(nTotleCount) ~= 1) then
	if (nTotleCount > 0 and TaskCond:CanAddItemsIntoBag(self.ItemList) ~= 1) then
		pPlayer.Msg("包裹已满，无法装载新的物品！")
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
		pPlayer.Msg("Mục tiêu: "..self:GetStaticDesc());
		self:UnRegister()	-- 本目标是一旦达成后不会失效的
		self.tbTask:OnFinishOneTag();
	end
end;
