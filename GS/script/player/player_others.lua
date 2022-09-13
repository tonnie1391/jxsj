------------------------------------------------------
-- 文件名　：others.lua
-- 创建者　：dengyong
-- 创建时间：2012-06-04 16:25:48
-- 描  述  ：player表下的某些操作
------------------------------------------------------
Require("\\script\\player\\define.lua");

Player.TASK_OTHER_GROUP			= 2000;
Player.TASK_LOCK_INPUT			= 5;

function Player:DoServerCmd(pPlayer, tbCmd)
	if not tbCmd or Lib:CountTB(tbCmd) == 0 then
		return;
	end
	pPlayer.LockClientInput();
	local tb = pPlayer.GetTempTable("Player");
	tb["ServerCmd"] = tbCmd;
	self:_ProcOneCmd(pPlayer.nId, 1);
end


function Player:_ProcOneCmd(nPlayerId, nCmdStep)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	
	local tbCmd = pPlayer.GetTempTable("Player").ServerCmd;
	if not tbCmd or Lib:CountTB(tbCmd) == 0 then
		return 0;
	end
	
	local _tbCmd = tbCmd[nCmdStep];
	if not _tbCmd then
		self:_OnCurCmdFinished(nPlayerId);
		return 0;
	end
	
	-- 所谓的前处理，因为貌似可以把所有事情都扔到action里面，目前前处理并没有应用。。
	if _tbCmd[1] then	-- beginprocess
		return;
	end
	
	if _tbCmd[2] then	-- action
		self:_SplitCmdAction(pPlayer, _tbCmd[2]);
	end
	
	if not _tbCmd[3] or _tbCmd[3] <= 0 then
		self:_OnCurCmdFinished(nPlayerId);
	else
		Timer:Register(_tbCmd[3], self._ProcOneCmd, self, nPlayerId, nCmdStep + 1);	
	end
	
	return 0;
end

function Player:_OnCurCmdFinished(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	
	local tb = pPlayer.GetTempTable("Player");
	tb["ServerCmd"] = nil;
	pPlayer.UnLockClientInput();
end

function Player:_SplitCmdAction(pPlayer, varAction)
	if type(varAction) == "string" then
		local fn = loadstring(varAction);
		if fn then
			fn(pPlayer);
		end
		return;
	end
end

function Player:_TestFunc(pPlayer)
	local tb = {};
	table.insert(tb, {nil, nil, 8});
	local sz = string.format([[local pPlayer = ...;
	        local _, x, y = %d, %d, %d;
	        pPlayer.DoCommand(4, x * 32, y * 32, 600);]],
	        GM._chariot.GetWorldPos());
	table.insert(tb, {nil, sz, 20})
	sz = string.format("local pPlayer = ...;pPlayer.LandInCarrier(%d, %d);", GM._chariot.nIndex, 0)
	table.insert(tb, {nil, sz, 30});
	sz = string.format("GM._chariot.DoCommand(3,%d,%d)", 1385*32, 3077*32)
	table.insert(tb, {nil, sz, 20});
	sz = string.format("GM._chariot.DoSkill(%d,%d,%d);",2940,1379, 3073);
	table.insert(tb, {nil, sz, 30});
	sz=string.format("GM._chariot.DoCommand(3,%d,%d)", 1374*32, 3073*32)
	table.insert(tb, {nil, sz, 20});
	sz = string.format("GM._chariot.DoSkill(%d,%d,%d);",2940,1364, 3087);
	table.insert(tb, {nil, sz, 30});
	Player:DoServerCmd(me, tb);
end
