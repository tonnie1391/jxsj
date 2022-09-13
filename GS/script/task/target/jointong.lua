-------------------------------------------------------
-- 文件名　：jointong.lua
-- 文件描述：成为帮会正式成员
-- 创建者　：ZhangDeheng
-- 创建时间：2009-03-04 10:11:59
-------------------------------------------------------

local tb	= Task:GetTarget("JoinTong");
tb.szTargetName	= "JoinTong";
tb.REFRESH_FRAME	= 18;	-- 一秒检测一次

function tb:Init(szStaticDesc, szDynamicDesc)
	self.szStaticDesc	= szStaticDesc;
	self.szDynamicDesc	= szDynamicDesc;
end;

function tb:Start()
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	self.bDone = 1;
	if (not pPlayer.dwTongId or pPlayer.dwTongId <= 0) then
		self.bDone = 0;
	end;
	local nKinId, nMemberId = pPlayer.GetKinMember();
	if (not nKinId or not nMemberId) then
		self.bDone = 0;
	end;
	if Kin:HaveFigure(nKinId, nMemberId, Kin.FIGURE_REGULAR) ~= 1 then
		self.bDone = 0;
	end	
	if (self:IsDone()) then	-- 本目标是一旦达成后不会失效的
		pPlayer.Msg("Mục tiêu: "..self:GetStaticDesc());
		self.tbTask:OnFinishOneTag();
		return;
	end;
	
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
	pPlayer.SetTask(nGroupId, nStartTaskId, self.bDone, 1);
	
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
	
	if (self.bDone ~= 1) then
		self:Register();
	end
	
	return 1;
end;

function tb:IsDone()
	return self.bDone == 1;
end;

function tb:GetDesc()
	return self.szDynamicDesc;
end;

function tb:GetStaticDesc()
	return self.szStaticDesc;
end;

function tb:Close(szReason)
	self:UnRegister();
end;

function tb:Register()
	if (MODULE_GAMESERVER and not self.nRegisterId) then
		self.nRegisterId	= Timer:Register(self.REFRESH_FRAME, self.OnTimer, self);
	end;
end;

function tb:UnRegister()
	if (MODULE_GAMESERVER and self.nRegisterId) then
		Timer:Close(self.nRegisterId);
		self.nRegisterId	= nil;
	end;
end;

function tb:OnTimer()
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	self.bDone = 1;
	if (not pPlayer.dwTongId or pPlayer.dwTongId <= 0) then
		self.bDone = 0;
	end;
	local nKinId, nMemberId = pPlayer.GetKinMember();
	if (not nKinId or not nMemberId) then
		self.bDone = 0;
	end;
	if Kin:HaveFigure(nKinId, nMemberId, Kin.FIGURE_REGULAR) ~= 1 then
		self.bDone = 0;
	end	
	
	if (self:IsDone()) then
		local tbSaveTask	= self.tbSaveTask;
		if (MODULE_GAMESERVER and tbSaveTask) then	-- 自行同步到客户端，要求客户端刷新
			pPlayer.SetTask(tbSaveTask.nGroupId, tbSaveTask.nStartTaskId, self.bDone, 1);
			KTask.SendRefresh(pPlayer, self.tbTask.nTaskId, self.tbTask.nReferId, tbSaveTask.nGroupId);
		end;
	
		pPlayer.Msg("Mục tiêu: "..self:GetStaticDesc());
	
		self:UnRegister()	-- 本目标是一旦达成后不会失效的
	
		self.tbTask:OnFinishOneTag();
	end
end