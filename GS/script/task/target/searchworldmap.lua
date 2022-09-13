
local tb	= Task:GetTarget("SearchMapChronicle");
tb.szTargetName	= "SearchMapChronicle";

function tb:Init(nMapId, nNeedCount)
	self.nMapId	= nMapId;
	self.nNeedCount	= nNeedCount;
end;

function tb:Start()
	-- 先清空以前任务保留的地图志
	self:SetMapNum(0);
	
	-- 注册事件
	self:Register();
end;

function tb:Save(nGroupId, nStartTaskId)
	return 0;
end;

function tb:Load(nGroupId, nStartTaskId)
	self:Register();
	return 0;
end;

-- 目标关闭时注销事件
function tb:Close(szReason)
	self:UnRegister();
end;

function tb:GetDesc()
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	local nMapNum = pPlayer.GetTask(LinkTask.TSKG_LINKTASK , LinkTask.TSK_WORLDMAPNUM);
	return "寻找 "..self.szMapName.."的地图志，完成："..nMapNum.." / "..self.nNeedCount.." 张";
end;


function tb:GetStaticDesc()
	local szMsg	= "";
	local szMapName = "";	
	if (self.nMapId ~= 0) then
		szMapName	= self.szMapName;
	end;
	szMsg = szMsg.."寻找 "..self.nNeedCount.." 张"..szMapName.."的地图志";
	return szMsg;
end;


function tb:Register()
	assert(self._tbBase._tbBase)	--没有经过两次派生，脚本书写错误
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	Setting:SetGlobalObj(pPlayer);
	if (MODULE_GAMESERVER and not self.nRegisterId) then
		self.nRegisterId	= PlayerEvent:Register("OnPickUp", self.OnPickUp, self);
	end;
	Setting:RestoreGlobalObj();
end;


function tb:UnRegister()
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	Setting:SetGlobalObj(pPlayer);
	if (MODULE_GAMESERVER and self.nRegisterId) then
		PlayerEvent:UnRegister("OnPickUp", self.nRegisterId);
		self.nRegisterId	= nil;
	end;
	Setting:RestoreGlobalObj();
end;


-- 玩家捡起任何一个物品时触发
function tb:OnPickUp()
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	local nNowCount = self:GetMapCount();
	
	-- print("Item Type: "..(it.nGenre).." / "..(it.nDetail).." / "..(it.nParticular));
	
	local tbItem = LinkTask.WorldMapItemGenre;
	
	-- 如果是地图志
	if it.nGenre == tbItem[1] and it.nDetail == tbItem[2] and it.nParticular == tbItem[3] then
		nNowCount = nNowCount + 1;
		self:SetMapNum(nNowCount);
		
		-- 任务目标已经达到
		if nNowCount>=self.nNeedCount then
			self:UnRegister();
			self.tbTask:OnFinishOneTag();
			pPlayer.Msg("您已经完成了寻找"..self.szMapName.."地图志的任务！");			
			return;
		end;
		
		pPlayer.Msg("寻找"..self.szMapName.."地图志进度："..
					nNowCount.." / "..self.nNeedCount);
	end;
end;


-- 判断任务是否已经完成
function tb:IsDone()
	local nNowCount = self:GetMapCount();
	return nNowCount>=self.nNeedCount;
end;


function tb:GetMapCount()
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	return pPlayer.GetTask(LinkTask.TSKG_LINKTASK , LinkTask.TSK_WORLDMAPNUM);
end;

function tb:SetMapNum(nNum)
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	pPlayer.SetTask(LinkTask.TSKG_LINKTASK , LinkTask.TSK_WORLDMAPNUM, nNum);
end;

