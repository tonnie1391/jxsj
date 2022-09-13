-- 文件名　：strategy.lua
-- 创建者　：houxuan
-- 创建时间：2008-12-22 08:54:20

Require("\\script\\player\\antibot\\antibot.lua");

local tbBase = Player.tbAntiBot.tbStrategy or {};
Player.tbAntiBot.tbStrategy = tbBase;

tbBase.tbStrategyList = {};

--注册新策略函数
function tbBase:RegisterNewStrategy(nIndex, szName, tbStrategyOne, fnExecute, fnClear, fnGetLogMsg, fnSave)
	if ((not tbStrategyOne) or (not fnExecute) or (not fnClear) or (not szName) or (not fnGetLogMsg)) then
		return 0;
	end
	local tbList = tbBase.tbStrategyList;
	local nListCount = #tbList;
	
	--要求注册的策略的序号必须连续
	if (nListCount + 1 ~= nIndex) then
		Dbg:Outptut("Error", "Strategy index is not sequential.");
		return 0;
	end
	if (tbList[nIndex] ~= nil) then
		Dbg:Output("Error", "Strategy "..szName.."is already register.");
		return 0;
	end;
	
	local tbOne = {};
	tbOne.obj = tbStrategyOne;
	tbOne.func = fnExecute;
	tbOne.fnClear = fnClear;
	tbOne.fnGetLogMsg = fnGetLogMsg;
	tbOne.fnSave = fnSave;
	tbOne.szName = szName;
	tbList[nIndex] = tbOne;
	return 1;
end

--直接进行丢天牢的处理的接口
function tbBase:ImmediateAgent(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return 0;
	end

	if (pPlayer.GetArrestTime() == 0) then
		local szLogMsg = string.format("[反外挂]：直接丢天牢(使用了第三方辅助工具)：\t账号：%s\t角色：%s\t等级：%d\tIP地址：%s\t丢入天牢的时间：%s\t处理成功。", 
			pPlayer.szAccount, pPlayer.szName, pPlayer.nLevel, pPlayer.GetPlayerIpAddress(), GetLocalDate("%Y\\%m\\%d  %H:%M:%S"));		
		pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_ANTIBOT_PROCESS, szLogMsg);	
		Player:Arrest(pPlayer.szName, 0);    --打入天牢
	end
	return 1;
end

--做丢天牢的处理
function tbBase:Agent(pPlayer, nIndex)
	if (not pPlayer) then
		return 0;
	end
	
	local tbAnti = Player.tbAntiBot;
	if (tbAnti.DEFAULT_OPERATE == 0) then 		--只写日志记录，不丢入天牢
		if (pPlayer.GetTask(tbAnti.TSKGID, tbAnti.TSK_MANAGERESULT) == tbAnti.tbenum.NOT_PUTIN_PRISON) then
			return 0;							--已经记录过日志，直接返回
		end
		pPlayer.SetTask(tbAnti.TSKGID, tbAnti.TSK_MANAGERESULT, tbAnti.tbenum.NOT_PUTIN_PRISON);
		local szLogMsg = string.format("[反外挂]：丢天牢处理结果：\t账号：%s\t角色：%s\t等级：%d\tIP地址：%s\t时间：%s\t策略名：%s\t策略信息：%s\t%s\t只是写日志记录，并未做丢入天牢的处理", 
			pPlayer.szAccount, pPlayer.szName, pPlayer.nLevel, pPlayer.GetPlayerIpAddress(), GetLocalDate("%Y\\%m\\%d  %H:%M:%S"), tbBase.tbStrategyList[nIndex].szName, tbBase.tbStrategyList[nIndex].fnGetLogMsg(tbBase.tbStrategyList[nIndex].obj, pPlayer), tbAnti.tbScore:ScoreLog(pPlayer));
		pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_ANTIBOT_PROCESS, szLogMsg);
		return 0;
	end
	
	--DONE:在丢入天牢之前，获取玩家的真实得分，如果真实得分小于临界值，则不做丢天牢的处理
	--玩家的打分项不会清除，但是对玩家应用的策略会清除掉
	if (pPlayer.GetTask(tbAnti.TSKGID, tbAnti.TSK_ACTUAL_SCORE) < tbAnti.CRITICAL_VALUE) then
		--玩家此时的得分小于临界值，不丢天牢，清除应用在玩家身上的策略
		pPlayer.SetTask(tbAnti.TSKGID, tbAnti.TSK_MANAGEWAY, 0);
		local tbOne = self.tbStrategyList[nIndex];
		if (tbOne) then
			tbOne.fnClear(tbOne.obj, pPlayer);
		end
		pPlayer.SetTask(tbAnti.TSKGID, tbAnti.TSK_CRITICAL_TIME, 0);
		--写log日志
		local szLogMsg = string.format("[反外挂]：分数小于临界值不做丢天牢的处理：\t账号：%s\t角色：%s\t等级：%d\tIP地址：%s\t时间：%s\t策略名：%s\t策略信息：%s\t%s",
			pPlayer.szAccount, pPlayer.szName, pPlayer.nLevel, pPlayer.GetPlayerIpAddress(), GetLocalDate("%Y\\%m\\%d  %H:%M:%S"), tbBase.tbStrategyList[nIndex].szName, tbBase.tbStrategyList[nIndex].fnGetLogMsg(tbBase.tbStrategyList[nIndex].obj, pPlayer), tbAnti.tbScore:ScoreLog(pPlayer));
		pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_ANTIBOT_PROCESS, szLogMsg);
		--print(szLogMsg);
		return 0;
	end
	
	pPlayer.SetTask(tbAnti.TSKGID, tbAnti.TSK_MANAGERESULT, tbAnti.tbenum.EXECUTE_SUCCESS);
	--如果玩家不在天牢中
	if (pPlayer.GetArrestTime() == 0) then
		local szLogMsg = string.format("[反外挂]：丢天牢处理结果：\t账号：%s\t角色：%s\t等级：%d\tIP地址：%s\t丢入天牢的时间：%s\t策略名：%s\t策略信息：%s\t%s\t处理成功。", 
			pPlayer.szAccount, pPlayer.szName, pPlayer.nLevel, pPlayer.GetPlayerIpAddress(), GetLocalDate("%Y\\%m\\%d  %H:%M:%S"), tbBase.tbStrategyList[nIndex].szName, tbBase.tbStrategyList[nIndex].fnGetLogMsg(tbBase.tbStrategyList[nIndex].obj, pPlayer), tbAnti.tbScore:ScoreLog(pPlayer));		
		pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_ANTIBOT_PROCESS, szLogMsg);	
		Player:Arrest(pPlayer.szName, 0);    --打入天牢
	end
	return 0;			--返回0结束Timer
end

--注意：不要修改策略注册顺序
---------------策略前的序号必须依次递增，不能改变已经注册的策略的序号---------------------------
Require("\\script\\player\\antibot\\strategy1.lua");
Require("\\script\\player\\antibot\\strategy2.lua");
Require("\\script\\player\\antibot\\strategy3.lua");

local tbTmp = Player.tbAntiBot.tbStrategy1;
tbBase:RegisterNewStrategy(1, "等级到达50级直接丢入天牢", tbTmp, tbTmp.OnExecute, tbTmp.OnClear, tbTmp.GetLogMsg);

tbTmp = Player.tbAntiBot.tbStrategy2;
tbBase:RegisterNewStrategy(2, "延时2-10小时丢入天牢", tbTmp, tbTmp.OnExecute, tbTmp.OnClear, tbTmp.GetLogMsg, tbTmp.OnSave);

tbTmp = Player.tbAntiBot.tbStrategy3;
tbBase:RegisterNewStrategy(3, "随机登陆10-16次并且在线时间超过1个小时", tbTmp, tbTmp.OnExecute, tbTmp.OnClear, tbTmp.GetLogMsg, tbTmp.OnSave);
