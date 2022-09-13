--
-- FileName: limittime_gc.lua
-- Author: zhongjunqi
-- Time: 2012/7/10 09:34
-- Comment: 防沉迷系统
--

if not MODULE_GC_SERVER then
	return;
end

Require("\\script\\player\\limittime\\limittime_def.lua");

Player.tbLimitTime  = Player.tbLimitTime or {};
local tbLimitTime = Player.tbLimitTime;

-- 记录玩家注册事件，下线的时候要踢出的
tbLimitTime.tbPlayerEventId = tbLimitTime.tbPlayerEventId or {};

function tbLimitTime:_OnLogin(nPlayerId, nLimitTimeData)
	if (not nLimitTimeData or nLimitTimeData < 0) then
		return;
	elseif (self.nLimitTime <= nLimitTimeData) then		-- 超时了，直接踢出，不应该出现这个情况
		local szName = KGCPlayer.GetPlayerName(nPlayerId);
		if (szName) then
			GlobalExcute{"GM:KickOut", szName};
		end
	else
		-- 注册定时器，到点就踢下线
		self.tbPlayerEventId[nPlayerId] = Timer:Register((self.nLimitTime - nLimitTimeData) * Env.GAME_FPS, self.OnLimitTimeout, self, nPlayerId);
	end
end

function tbLimitTime:_OnLogout(nPlayerId)
	-- 清除定时器
	local nEventId = self.tbPlayerEventId[nPlayerId];
	if (nEventId) then
		Timer:Close(nEventId);
		self.tbPlayerEventId[nPlayerId] = nil;
	end
end

function tbLimitTime:OnLimitTimeout(nPlayerId)
	local szName = KGCPlayer.GetPlayerName(nPlayerId);
	if (szName) then
		GM:KickOut(szName, "防沉迷时间到，强制下线。");
		local nEventId = self.tbPlayerEventId[nPlayerId];
		if (nEventId) then
			self.tbPlayerEventId[nPlayerId] = nil;
		end		
	end
	return 0;
end

