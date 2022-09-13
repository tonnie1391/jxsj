 --
-- FileName: limittime_gs.lua
-- Author: zhongjunqi
-- Time: 2012/7/10 09:34
-- Comment: 防沉迷系统
--
 
if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\player\\limittime\\limittime_def.lua");

Player.tbLimitTime  = Player.tbLimitTime or {};
local tbLimitTime = Player.tbLimitTime;

function tbLimitTime:_OnLogin(bExchangeServerComing)
	if (bExchangeServerComing ~= 1) then
		local nLimitTimeData = me.GetLimitTimeInfo();
		if (nLimitTimeData >= 0) then
			GCExcute({"Player.tbLimitTime:_OnLogin", me.nId, nLimitTimeData});
		end
	end
end

function tbLimitTime:_OnLogout(szReason)
	if (szReason ~= "SwitchServer") then
		local nLimitTimeData = me.GetLimitTimeInfo();
		if (nLimitTimeData >= 0) then
			GCExcute({"Player.tbLimitTime:_OnLogout", me.nId});
		end
	end
end

if (MODULE_GAMESERVER) then
	-- 注册通用上线事件
	tbLimitTime.nLoginEventId = PlayerEvent:RegisterGlobal("OnLogin", tbLimitTime._OnLogin, tbLimitTime);
	
	-- 注册通用下线事件
	tbLimitTime.nLogoutEventId = PlayerEvent:RegisterGlobal("OnLogout", tbLimitTime._OnLogout, tbLimitTime);
end
