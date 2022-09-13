-- 文件名　：strategy3.lua
-- 创建者　：houxuan
-- 创建时间：2008-12-22 08:54:28

Require("\\script\\player\\antibot\\antibot.lua");

--玩家登陆2-5次之后，丢入天牢
local tbStrategy3 = Player.tbAntiBot.tbStrategy3 or {};
Player.tbAntiBot.tbStrategy3 = tbStrategy3;

--记录玩家在被怀疑为外挂之后的登陆次数的任务变量
tbStrategy3.TSK_LOGINCOUNT		=	Player.tbAntiBot.STRATEGY_BEGIN + 20;

--玩家在被怀疑为外挂之后，当其登陆次数达到某一个值时，丢入天牢
tbStrategy3.TSK_DEFINEPOINT		=	Player.tbAntiBot.STRATEGY_BEGIN + 21;

--在线时间至少为1个小时，超过一个小时也行
tbStrategy3.ONLINE_TIME			= 1 * 60 * 60;

--记录被判定为外挂后的在线时间的任务变量
tbStrategy3.TSK_ONLINE_TIME		= Player.tbAntiBot.STRATEGY_BEGIN + 22;

function tbStrategy3:OnExecute(pPlayer, nState, nIndex)
	local tbAnti = Player.tbAntiBot;
	local nDefinePnt = pPlayer.GetTask(tbAnti.TSKGID, self.TSK_DEFINEPOINT);
	local nLoginCnt = pPlayer.GetTask(tbAnti.TSKGID, self.TSK_LOGINCOUNT);
	
	--更新时间
	local tbSelf = Player:GetPlayerTempTable(pPlayer);
	tbSelf.AntiBot_nStrategy3Start = GetTime();
	
	if (nDefinePnt == 0) then
		--第一次登陆，需产生随机种子
		nDefinePnt = MathRandom(10, 16);
		pPlayer.SetTask(tbAnti.TSKGID, self.TSK_DEFINEPOINT, nDefinePnt);
		return 0;
	end
	if (nState ~= tbAnti.PLAYER_LOGIN) then		--不是玩家登陆过程，直接返回
		return 0;
	end
	if (nLoginCnt < nDefinePnt) then
		nLoginCnt = nLoginCnt + 1;
		pPlayer.SetTask(tbAnti.TSKGID, self.TSK_LOGINCOUNT, nLoginCnt);
		if (nLoginCnt < nDefinePnt) then
			return 0;
		end
	end
	--登陆次数已达到，判断在线时间是否达到1小时
	local nOnLineTime = pPlayer.GetTask(tbAnti.TSKGID, self.TSK_ONLINE_TIME);
	if (nOnLineTime >= self.ONLINE_TIME) then
		Player.tbAntiBot.tbStrategy:Agent(pPlayer, nIndex);
	end
	return 1;
end

function tbStrategy3:OnClear(pPlayer)
	local tbAnti = Player.tbAntiBot;
	--清除该策略所用的任务变量值
	pPlayer.SetTask(tbAnti.TSKGID, self.TSK_DEFINEPOINT, 0);
	pPlayer.SetTask(tbAnti.TSKGID, self.TSK_LOGINCOUNT, 0);
	pPlayer.SetTask(tbAnti.TSKGID, self.TSK_ONLINE_TIME, 0);
	return 0;
end

function tbStrategy3:OnSave(pPlayer)
	local tbAnti = Player.tbAntiBot;
	local nLastTime = Player:GetPlayerTempTable(pPlayer).AntiBot_nStrategy3Start;
	if (not nLastTime) then
		return 0;
	end
	local nAddTime = GetTime() - nLastTime;
	local nUsedTime = pPlayer.GetTask(tbAnti.TSKGID, self.TSK_ONLINE_TIME);
	pPlayer.SetTask(tbAnti.TSKGID, self.TSK_ONLINE_TIME, nUsedTime + nAddTime);
	return 1;
end

function tbStrategy3:GetLogMsg(pPlayer)
	local szMsg = string.format("策略名：随机登陆10-16次并且在线时间超过1个小时丢入天牢\t被判定为外挂后，登陆%d次丢入天牢\t判定为外挂后的在线时间%.1f小时", 
		pPlayer.GetTask(Player.tbAntiBot.TSKGID, self.TSK_DEFINEPOINT), pPlayer.GetTask(Player.tbAntiBot.TSKGID, self.TSK_ONLINE_TIME) / 3600);
	return szMsg;
end
