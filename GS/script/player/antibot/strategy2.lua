-- 文件名　：strategy2.lua
-- 创建者　：houxuan
-- 创建时间：2008-12-22 19:05:57

--策略对象1
Require("\\script\\player\\antibot\\antibot.lua");

local tbStrategy2 = Player.tbAntiBot.tbStrategy2 or {};
Player.tbAntiBot.tbStrategy2 = tbStrategy2;

tbStrategy2.TSK_USED_TIME		= Player.tbAntiBot.STRATEGY_BEGIN + 10;		--已经用过的时间
tbStrategy2.TSK_TOTAL_TIME		= Player.tbAntiBot.STRATEGY_BEGIN + 11;		--总时间

function tbStrategy2:OnExecute(pPlayer, nState, nIndex)	
	local tbAnti = Player.tbAntiBot;
	local nTotalTime = pPlayer.GetTask(tbAnti.TSKGID, self.TSK_TOTAL_TIME);
	if (nTotalTime == 0) then	--随机1 - 120分钟，丢入天牢
		nTotalTime = MathRandom(1, 120);		--TODO:范围缩小 15分钟到两个小时
		nTotalTime = nTotalTime * 60;  --计算出总共有多少秒
		pPlayer.SetTask(tbAnti.TSKGID, self.TSK_TOTAL_TIME, nTotalTime);
	end
	
	local nLeftTime = nTotalTime - pPlayer.GetTask(tbAnti.TSKGID, self.TSK_USED_TIME); --以秒为单位
	if (nLeftTime < 0 ) then
		nLeftTime = 1;
	end
	Player:RegisterTimer(nLeftTime * Env.GAME_FPS, tbAnti.tbStrategy.Agent, tbAnti.tbStrategy, pPlayer, nIndex);
	
	local tbSelf = Player:GetPlayerTempTable(pPlayer);
	tbSelf.AntiBot_nStartTime = GetTime();
	return 0;
end

function tbStrategy2:OnSave(pPlayer)
	local tbAnti = Player.tbAntiBot;
	local nLastTime = Player:GetPlayerTempTable(pPlayer).AntiBot_nStartTime;
	if (not nLastTime) then
		return 0;
	end
	local nAddTime = GetTime() - nLastTime;
	local nUsedTime = pPlayer.GetTask(tbAnti.TSKGID, self.TSK_USED_TIME);
	local nTotalTime = pPlayer.GetTask(tbAnti.TSKGID, self.TSK_TOTAL_TIME);
	if (nUsedTime <= nTotalTime) then
		pPlayer.SetTask(tbAnti.TSKGID, self.TSK_USED_TIME, nUsedTime + nAddTime);
	end
	return 1;
end

function tbStrategy2:OnClear(pPlayer)
	--清除任务变量值
	local tbAnti = Player.tbAntiBot;
	pPlayer.SetTask(tbAnti.TSKGID, self.TSK_USED_TIME, 0);
	pPlayer.SetTask(tbAnti.TSKGID, self.TSK_TOTAL_TIME, 0);
	return 0;
end

function tbStrategy2:GetLogMsg(pPlayer)
	local szMsg = string.format("策略名：延时2-10小时丢入天牢\t判定为外挂后，延迟%d小时进行丢天牢的处理", 
		pPlayer.GetTask(Player.tbAntiBot.TSKGID, tbStrategy2.TSK_TOTAL_TIME) / 3600);
	return szMsg;
end
