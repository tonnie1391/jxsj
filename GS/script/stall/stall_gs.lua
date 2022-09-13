-------------------------------------------------------------------
--File		: stall_gs.lua
--Author	: ZouYing
--Date		: 2008-6-10 11:48
--Describe	: 摆摊服务器脚本
-------------------------------------------------------------------
if not MODULE_GAMESERVER then
	return;
end

Stall.TASK_GROUP_ID		= 2032; -- 摆摊许可id
Stall.TASK_TOTAL_TIME	= 1;	-- 许可摆摊累计时间,记录是分钟数

Stall.tbTimeIdList		= {};

function Stall:OnStartStall(pPlayer)
	local nLeftTime	= pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_TOTAL_TIME);
	assert(nLeftTime > 0);
	
	local szTime = Lib:TimeDesc(nLeftTime);
	local szMsg	= string.format("你还剩余 %s 摆摊时间。", szTime);
	pPlayer.Msg(szMsg);
	
	local nTimerId = Timer:Register(nLeftTime * Env.GAME_FPS,  self.StallOver, self, pPlayer.nId);
	self.tbTimeIdList[pPlayer.nId]	= nTimerId;
end

function Stall:StallOver(nPlayerId)
	local pPlayer	= KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		pPlayer.ExitStallState();
	end
	return 0;
end

function Stall:CloseTimeId(pPlayer)
	local nTimeId	= self.tbTimeIdList[pPlayer.nId];

	if (not nTimeId) then
		return;
	end
	local nLeftTime	= tonumber(Timer:GetRestTime(nTimeId));
	if (nLeftTime > 0) then
		Timer:Close(nTimeId);
	end
	local szTime = Lib:TimeDesc(nLeftTime / Env.GAME_FPS);
	local szMsg	= string.format("你还剩余 %s 摆摊时间。", szTime);
	pPlayer.Msg(szMsg);
	self.tbTimeIdList[pPlayer.nId] = nil;
end

function Stall:OnStallStateChange(nStallState)
	if (nStallState == Player.STALL_STAT_OFFER_BUY or nStallState == Player.STALL_STAT_STALL_SELL )then
		self:OnStartStall(me);
	elseif(nStallState == Player.STALL_STAT_NORMAL) then
		self:CloseTimeId(me);
	end
end

PlayerEvent:RegisterGlobal("OnStallStateChange", Stall.OnStallStateChange, Stall);
