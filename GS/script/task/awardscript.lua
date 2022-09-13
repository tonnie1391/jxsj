
-- 每周前4次日常剧情副本，给玩家派发2w绑定银两。在奖励面板显示，4次之后，奖励面板显示银两为0两，并在任务结束时告知：本周已领取完4次不绑定银两。
-- "Task:Award_1(20000)"
function Task:Award_1(nMoney, nTaskId)
	local tbNow	= os.date("*t", GetTime());
	local nAwardTime = me.GetTask(2043, 100);
	
	if (nAwardTime >= 4) then
		me.Msg("获得0两绑定银两。");
		return;
	end
	
	nAwardTime = nAwardTime + 1;
	
	me.SetTask(2043, 100, nAwardTime);
	
	me.AddBindMoney(nMoney, Player.emKBINDMONEY_ADD_TASK_ARMYCAMP);
	KStatLog.ModifyAdd("jxb", "[产出]军营任务", "总量", nMoney);
	
	Task:TskProduceLog(nTaskId, Task.TSKPRO_LOG_TYPE_BINDMONEY, nMoney);
end

-- 每周前4次日常剧情副本，给玩家派发3点江湖威望。在奖励面板显示，4次之后，奖励面板显示江湖威望0点，并在任务结束时告知：本周已领取完4次江湖威望。
-- "Task:Award_2(3)"
function Task:Award_2(nWeiWang)
	local tbNow	= os.date("*t", GetTime());
	local nAwardTime = me.GetTask(2043, 101);
	
	if (nAwardTime >= 4) then
		me.Msg("获得0点江湖威望");
		return;
	end
	
	nAwardTime = nAwardTime + 1;
	
	me.SetTask(2043, 101, nAwardTime);
	
	me.AddKinReputeEntry(nWeiWang);
	Dbg:WriteLogEx(Dbg.LOG_INFO, "Task", "Award_2", me.szName, string.format("Award WeiWang %d", nWeiWang));
end

-- 奖励绑定魂石
function Task:Award_3(nCount)
	if (nCount <= 0) then
		return 0;
	end
	me.AddStackItem(18,1,205,1, {bForceBind = 1}, nCount);
	Dbg:WriteLogEx(Dbg.LOG_INFO, "Task", "Award_3", me.szName, string.format("Award hunshi %d", nCount));
end

function Task:WeekClearAwardTaskValue()
	me.SetTask(2043, 100, 0);
	me.SetTask(2043, 101, 0);
end


PlayerSchemeEvent:RegisterGlobalWeekEvent({Task.WeekClearAwardTaskValue, Task});