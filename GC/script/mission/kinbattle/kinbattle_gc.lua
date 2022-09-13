-------------------------------------------------------
-- 文件名　：kinbattle_gc.lua
-- 创建者　：huangxiaoming
-- 创建时间：2010-12-7 10:15:46
-- 文件描述：
-------------------------------------------------------

if not MODULE_GC_SERVER then
	return;
end

Require("\\script\\mission\\kinbattle\\kinbattle_def.lua");

function KinBattle:ReserveMatch_GC(nPlayerId, nKinId, nMemberId, nPlayerIdMate, nKinIdMate, nMemberIdMate, nTimeIndex, nMapType, nLookMode)
	if KinBattle.OPEN_STATE ~= 1 then
		return 0;
	end
	local cKin = KKin.GetKin(nKinId);
	local cKinMate = KKin.GetKin(nKinIdMate);
	if not cKin or not cKinMate then
		return 0;
	end
	if Kin:CheckSelfRight(nKinId, nMemberId, 1) ~= 1 or Kin:CheckSelfRight(nKinIdMate, nMemberIdMate, 1) ~= 1 then
		return 0;
	end
	if self:CheckHaveEnoughMoney(nKinId, nKinIdMate) <= 0 then
		return 0;
	end
	if self:FindMissionId(nKinId, nKinIdMate) > 0 then
		return 0;
	end
	local nMapIndex = self:CheckHaveFreeBattle(nMapType);
	if nMapIndex == 0 then
		return 0;
	end
	self:OccupyBattle(nMapIndex, nKinId, nKinIdMate, nTimeIndex, nLookMode);
	local nMoney = cKin.GetMoneyFund();
	local nMoneyMate = cKinMate.GetMoneyFund();
	local nCurMoney = nMoney - KinBattle.MONEY_COST;
	local nCurMoneyMate = nMoneyMate - KinBattle.MONEY_COST;
	if nCurMoneyMate < 0 or nCurMoney < 0 then
		return 0;
	end
	local szKinName = cKin.GetName();
	local szKinNameMate = cKinMate.GetName();
	cKin.SetMoneyFund(nCurMoney);
	_G.KinLog(szKinName, Log.emKKIN_LOG_TYPE_KINFUND, string.format("与[%s]家族家族战报名费%s两", szKinNameMate, KinBattle.MONEY_COST));
	Dbg:WriteLog("家族资金", string.format("家族名字：%s", szKinName),string.format( "家族战报名费,对手：%s,时间：%s", szKinNameMate, KinBattle.TIMER_GAME_DEC[nTimeIndex]), string.format("金额：%s两", KinBattle.MONEY_COST));
	cKinMate.SetMoneyFund(nCurMoneyMate);
	_G.KinLog(szKinNameMate, Log.emKKIN_LOG_TYPE_KINFUND, string.format("与[%s]家族家族战报名费%s两", szKinName, KinBattle.MONEY_COST));
	Dbg:WriteLog("家族资金", string.format("家族名字：%s", szKinNameMate),string.format( "家族战报名费,对手：%s,时间：%s", szKinNameMate, KinBattle.TIMER_GAME_DEC[nTimeIndex]), string.format("金额：%s两", KinBattle.MONEY_COST));
	GlobalExcute{"KinBattle:StartMission_GS2", nKinId, nKinIdMate, nMapIndex, nTimeIndex, nCurMoney, nCurMoneyMate, nMapType, nLookMode};
	local szMsg = "[%s]家族向[%s]家族发起了挑战，10分钟后开始武艺切磋！";
	local szMsgSub = "<color=blue>[%s]<color>家族向<color=blue>[%s]<color>家族发起了挑战，10分钟后开始武艺切磋！";
	if nLookMode == 1 then
		szMsg = szMsg .. "届时各位侠士可前往公平子处观战！";
		szMsgSub = szMsgSub .. "届时各位侠士可前往公平子处观战！";
	else
		szMsg = szMsg .. "此次禁止观战！";
		szMsgSub = szMsgSub .. "此次禁止观战！";
	end
	Dialog:GlobalNewsMsg_GC(string.format(szMsg, szKinName, szKinNameMate));
	Dialog:GlobalMsg2SubWorld_GC(string.format(szMsgSub, szKinName, szKinNameMate));
end

function KinBattle:FreeBattle_GC(nIndex)
	self:FreeBattle(nIndex);
	GlobalExcute{"KinBattle:FreeBattle", nIndex};
end

function KinBattle:IncreaseBattleTime_GC(nKinId, nKinIdMate)
	self:IncreaseBattleTime(nKinId, nKinIdMate);
	GlobalExcute{"KinBattle:IncreaseBattleTime", nKinId, nKinIdMate};
end
