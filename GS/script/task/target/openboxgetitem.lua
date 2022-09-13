
local tb	= Task:GetTarget("OpenBoxGetItem");
tb.szTargetName	= "OpenBoxGetItem";

-- 箱子的模板Id，地图Id, 箱子的对话内容, 重复信息，开箱子后得到的道具，开始泡泡，结束泡泡
function tb:Init(nNpcTempId, nMapId, szOption, szMsg, szRepeatMsg, tbItem, szBeforePop, szLaterPop)
	self.nNpcTempId	= nNpcTempId;
	self.szNpcName	= KNpc.GetNameByTemplateId(nNpcTempId);
	self.nMapId		= nMapId;
	self.szMapName	= Task:GetMapName(nMapId);
	self.szOption	= szOption;
	self.szMsg		= szMsg;
	if (szRepeatMsg ~= "") then
		self.szRepeatMsg	= szRepeatMsg;
	end;
	
	self.ItemList	= self:ParseItem(tbItem);
	self.szBeforePop	= szBeforePop;
	self.szLaterPop		= szLaterPop;
end;

function tb:Start()
	self.bDone		= 0;
	self:Register();
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

function tb:Save(nGroupId, nStartTaskId)
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	self.tbSaveTask	= {	-- 这里保存下来，以后随时可以自行同步客户端
		nGroupId		= nGroupId,
		nStartTaskId	= nStartTaskId,
	};
	pPlayer.SetTask(nGroupId, nStartTaskId, self.bDone);
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
	self.bDone		= pPlayer.GetTask(nGroupId, nStartTaskId);
	if (not self:IsDone() or self.szRepeatMsg) then	-- 本目标是一旦达成后不会失效的
		self:Register();
	end;
	return 1;
end;

function tb:IsDone()
	return self.bDone == 1;
end;

function tb:GetDesc()
	return self:GetStaticDesc();
end;

function tb:GetStaticDesc()
	local szMsg	= "开启 ";
	if (self.nMapId ~= 0) then
		szMsg	= szMsg..self.szMapName.."的 ";
	end;
	szMsg	= szMsg..string.format("%s ", self.szNpcName);
	return szMsg;
end;


function tb:Close(szReason)
	self:UnRegister();
end;


function tb:Register()
	self.tbTask:AddNpcMenu(self.nNpcTempId, self.nMapId, self.szOption, self.OnTalkNpc, self);
end;

function tb:UnRegister()
	self.tbTask:RemoveNpcMenu(self.nNpcTempId);
end;

function tb:OnTalkNpc()
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	if (self.nMapId ~= 0 and self.nMapId ~= pPlayer.GetMapId()) then
		pPlayer.Msg("你要开启的不是本地图的"..self.szNpcName.."请前往"..self.szMapName)
		return;
	end;
	
	if (self:IsDone()) then
		if (self.szRepeatMsg) then
			TaskAct:Talk(self.szRepeatMsg);
		end;
		return;
	end;
	
	local tbOpt =
	{
        { "开启", 			self.SelectOpenBox,	self },
        { "暂时不开"},
    };

    Dialog:Say("打开我里面有意想不到惊喜！", tbOpt);
end;

-- 玩家选择打开箱子[S]
-- 1.向客户端发送协议让客户端设置进度条?
function tb:SelectOpenBox()
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	self.bDone	= 1;
	local tbSaveTask	= self.tbSaveTask;
	if (MODULE_GAMESERVER and tbSaveTask) then	-- 自行同步到客户端，要求客户端刷新
		pPlayer.SetTask(tbSaveTask.nGroupId, tbSaveTask.nStartTaskId, self.bDone, 1);
		KTask.SendRefresh(pPlayer, self.tbTask.nTaskId, self.tbTask.nReferId, tbSaveTask.nGroupId);
	end;
	pPlayer.Msg("Mục tiêu: "..self:GetStaticDesc());
	
	for _, tbItem in ipairs(self.ItemList) do
		Task:AddItem(pPlayer, tbItem);
	end
	
	if (not self.szRepeatMsg) then
		self:UnRegister()	-- 本目标是一旦达成后不会失效的
	end;
	
	self.tbTask:OnFinishOneTag();
end;

--[[
-- 2.客户端设置进度条并设置它的完成回掉
function tb:SetProgressBar()
end;

-- 客户端进度条完成回掉，通知服务端给奖励
function tb:OnProgressFull()
end;

-- 3.服务端为玩家添加物品，目标完成
function tb:OnGiveItem()
	
end;
--]]
