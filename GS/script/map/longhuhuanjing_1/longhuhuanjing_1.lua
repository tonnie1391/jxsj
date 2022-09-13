-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(59); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap	= tbTest:GetTrapClass("to_jiejianchi")

-- 定义玩家Trap事件
function tbTestTrap:OnPlayer()
	local task_value = me.GetTask(1022,61)
	if (task_value == 1) then 	
		me.NewWorld(433,1555,3106)	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);
		return;
	else
		return;
	end	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_laojunyan")

-- 定义玩家Trap事件
function tbTestTrap2:OnPlayer()

end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap3	= tbTest:GetTrapClass("to_qingxuzhenshi")

-- 定义玩家Trap事件
function tbTestTrap3:OnPlayer()
	local task_value = me.GetTask(1022,62)
	if (task_value == 1) then 	
		me.NewWorld(434,1606,3209);	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(0);
		return;
	elseif (task_value == 2) then 
		me.NewWorld(435,1606,3209);	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(0);
		return;
	else
		me.NewWorld(434,1606,3209);	
		return;
	end	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap4	= tbTest:GetTrapClass("to_taoju")

-- 定义玩家Trap事件
function tbTestTrap4:OnPlayer()
	local task_value = me.GetTask(1022,63)
	if (task_value == 1) then 	
		me.NewWorld(439,1619,3220);	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(0);
		return;
	elseif (task_value == 2) then 
		me.NewWorld(440,1619,3220);	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(0);
		return;
	elseif (task_value == 3) then 
		me.NewWorld(441,1619,3220);	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(0);
		return;
	elseif (task_value == 4) then 
		me.NewWorld(442,1619,3220);	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(0);
		return;
	else
		me.NewWorld(439,1619,3220);
		return;
	end	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap5	= tbTest:GetTrapClass("to_weiju")

-- 定义玩家Trap事件
function tbTestTrap5:OnPlayer()
	me.NewWorld(443,1619,3220)-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(0);
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap6	= tbTest:GetTrapClass("to_yunlushuiju")

-- 定义玩家Trap事件
function tbTestTrap6:OnPlayer()	
	local task_value = me.GetTask(1022,65)
	if (task_value == 1) then 	
		me.NewWorld(436,1527,3126);	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(0);
		return;
	elseif (task_value == 2) then 
		me.NewWorld(437,1527,3126);	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(0);
		return;
	else
		me.NewWorld(436,1527,3126);
		return;
	end
end;

-- 定义Npc Trap事件
function tbTestTrap:OnNpc()
	
end;

