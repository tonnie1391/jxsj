-- 文件名　：newbattle_gc.lua
-- 创建者　：LQY
-- 创建时间：2012-07-18 15:02:20
-- 说	明 ：新宋金战场的GC实现
if not MODULE_GC_SERVER then
	return 0;
end
Require("\\script\\mission\\newbattle\\newbattle_def.lua");

NewBattle.tbNewBattleOpen = NewBattle.tbNewBattleOpen or 
{
	[1] = {0, 0},
	[2] = {0, 0},
	[3] = {0, 0},
}

--启动战场活动，进入第一个阶段
function NewBattle:StartNewBattle_GC(dwBattleLevel, nSeqNum, nBattleSeq)
	if(self:CanStartBattle() ~= 1) then
		return 0;
	end

	--活动流水号
	local nSession = KGblTask.SCGetDbTaskInt(DBTASK_NEWBATTLE_SESSION);
	KGblTask.SCSetDbTaskInt(DBTASK_NEWBATTLE_SESSION, nSession + 1);

	--置活动状态
	--self.nBattle_State = self.BATTLE_STATES.SIGNUP;
	--GlobalExcute({"KDialog.NewsMsg", 0, Env.NEWSMSG_NORMAL, "甘罗城新战场开始报名！"});
	
	--召唤GS启动报名
	GlobalExcute{"NewBattle:StartNewBattle_GS", dwBattleLevel, nSeqNum, nBattleSeq};

end

-- 成功开启一个战场
function NewBattle:BattleOpen_GC(dwBattleLevel, nSeqNum)
	if self.tbNewBattleOpen[dwBattleLevel] then
		self.tbNewBattleOpen[dwBattleLevel][nSeqNum] = 1;
	end
	GlobalExcute{"NewBattle:BattleOpen_GS", dwBattleLevel, nSeqNum, nBattleSeq};
end

-- 关闭一个战场
function NewBattle:BattleClose_GC(dwBattleLevel, nSeqNum)
	if self.tbNewBattleOpen[dwBattleLevel] then
		self.tbNewBattleOpen[dwBattleLevel][nSeqNum] = 0;
	end
	GlobalExcute{"NewBattle:BattleClose_GS", dwBattleLevel, nSeqNum, nBattleSeq};
end
--结束战斗,没用- -
function NewBattle:FinishFight_GC(nlevel, nWiner, nSeqNum)
	
	--if self.nBattle_State == self.BATTLE_STATES.CLOSED then
		--return;
	--end

	local szMsg = "";
	if nWiner == -1 then
		return;
	end
	if nWiner == 3 then
		szMsg = "人数不足，新宋金战场未能开启。";
	elseif nWiner ==  0 then
		szMsg = "新宋金战场的最终结果为[平局]";
	else
		szMsg = string.format("[%s]在新宋金战场中获得了最终的胜利！",(nWiner == 1) and "宋军" or "金军");
	end
	--GlobalExcute({"KDialog.NewsMsg", 0, Env.NEWSMSG_NORMAL, szMsg});

end

--GS连接事件
function NewBattle:OnRecConnectEvent(nConnectId)
	GSExcute(nConnectId, {"NewBattle:UpdateOpen_GS", tbNewBattleOpen});
end

--注册GS连接事件
GCEvent:RegisterGS2GCServerStartFunc(NewBattle.OnRecConnectEvent, NewBattle);
