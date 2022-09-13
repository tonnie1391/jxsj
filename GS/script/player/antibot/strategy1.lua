-- 文件名　：strategy1.lua
-- 创建者　：houxuan
-- 创建时间：2008-12-22 19:05:44

Require("\\script\\player\\antibot\\antibot.lua");

local tbStrategy1 = Player.tbAntiBot.tbStrategy1 or {};
Player.tbAntiBot.tbStrategy1 = tbStrategy1;

--执行策略
function tbStrategy1:OnExecute(pPlayer, nState, nIndex)
	PlayerEvent:Register("OnLevelUp", tbStrategy1.OnLevelUp, tbStrategy1);
	return 1;
end

--升级时响应的函数
function tbStrategy1:OnLevelUp(nLevel)
	local tbAnti = Player.tbAntiBot;
	local nResult = me.GetTask(tbAnti.TSKGID, tbAnti.TSK_MANAGERESULT);		--获取处理的结果
	if (nResult == tbAnti.tbenum.EXECUTE_SUCCESS) then	--已经处理过了
		return 0;
	end
	if (nLevel == Player.tbAntiBot.CRITICAL_LEVEL) then
		Player.tbAntiBot.tbStrategy:Agent(me, 1);
	end
	return 0;
end

--清除策略所使用的数据
function tbStrategy1:OnClear(pPlayer)
	local szMsg = string.format("策略名：等级到达50级后丢入天牢。");
	return szMsg;
end

function tbStrategy1:GetLogMsg(pPlayer)
	return "";
end
