
-- 静态进度条目标
local tb	= Task:GetTarget("WithProcessStatic");
tb.szTargetName	= "WithProcessStatic";


function tb:Init(nNpcTempId, nMapId, nIntervalTime, szProcessInfo, szSucMsg, szFailedMsg,  tbItem, nNeedCount, szDynamicDesc, szStaticDesc, szBeforePop, szLaterPop, szScript)
	self.nNpcTempId			= nNpcTempId;
	self.szNpcName			= KNpc.GetNameByTemplateId(nNpcTempId);
	self.nMapId				= nMapId;
	self.szMapName			= Task:GetMapName(nMapId);
	self.nIntervalTime 		= tonumber(nIntervalTime) * 18;
	self.szProcessInfo		= szProcessInfo or "进行中";
	self.szSucMsg			= szSucMsg or "成功";
	self.szFailedMsg		= szFailedMsg or "失败";
	self.ItemList			= self:ParseItem(tbItem);
	self.nNeedCount			= nNeedCount;
	self.szDynamicDesc		= szDynamicDesc;
	self.szStaticDesc	  	= szStaticDesc;
	self.szBeforePop		= szBeforePop;
	self.szLaterPop			= szLaterPop;
	self.szScript 			= szScript;
end;

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
	-- TODO: liuchang 字符串检查
	return string.format(self.szDynamicDesc,self.nCount,self.nNeedCount);
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


-- 客户端进度条完成回掉，通知服务端给奖励
function tb:OnProgressFull()
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	local nTotleCount = #self.ItemList;
	
	if (nTotleCount > 0 and TaskCond:CanAddItemsIntoBag(self.ItemList) ~= 1) then
		pPlayer.Msg("包裹已满，无法装载新的物品！")
		return;
	end
	pPlayer.Msg(self.szSucMsg);
	self.nCount	= self.nCount + 1;
	local tbSaveTask	= self.tbSaveTask;
	if (MODULE_GAMESERVER) then	-- 自行同步到客户端，要求客户端刷新
		if self.szScript then
			Setting:SetGlobalObj(pPlayer);
			loadstring(string.format(self.szScript, self.nCurTagIdx))();
			Setting:RestoreGlobalObj();
		end
		if tbSaveTask then
			pPlayer.SetTask(tbSaveTask.nGroupId, tbSaveTask.nStartTaskId, self.nCount, 1);
			KTask.SendRefresh(pPlayer, self.tbTask.nTaskId, self.tbTask.nReferId, tbSaveTask.nGroupId);
		end
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
