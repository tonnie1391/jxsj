-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(198); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap	= tbTest:GetTrapClass("to_exit17")

-- 定义玩家Trap事件
function tbTestTrap:OnPlayer()	
	me.NewWorld(55,1811,3456)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_exit24")

-- 定义玩家Trap事件
function tbTestTrap2:OnPlayer()
	me.NewWorld(55,1729,3208)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1);
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap3	= tbTest:GetTrapClass("to_exit25")

-- 定义玩家Trap事件
function tbTestTrap3:OnPlayer()
	me.NewWorld(55,1653,3371)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap4	= tbTest:GetTrapClass("to_exit26")

-- 定义玩家Trap事件
function tbTestTrap4:OnPlayer()	
	me.NewWorld(55,1833,3477)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1);
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap5	= tbTest:GetTrapClass("to_exit27")

-- 定义玩家Trap事件
function tbTestTrap5:OnPlayer()
	me.NewWorld(55,1810,3487)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap6	= tbTest:GetTrapClass("to_floor2")

-- 定义玩家Trap事件
function tbTestTrap6:OnPlayer()
	--local task_value = me.GetTask(1022,8)
	if (task_value == 1) then 
		return;
	else
		me.NewWorld(198,1656,3840)	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);
		return;
	end	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap7	= tbTest:GetTrapClass("to_floor3")

-- 定义玩家Trap事件
function tbTestTrap7:OnPlayer()
	local task_value = me.GetTask(1022,9)
	if (task_value == 1) then 
		return;
	else
		me.NewWorld(198,1729,3858)	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);
		return;
	end	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap8	= tbTest:GetTrapClass("to_exit21")

-- 定义玩家Trap事件
function tbTestTrap8:OnPlayer()	
	--me.NewWorld(198,1590,3839)
	me.NewWorld(55,1614,3198)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap9	= tbTest:GetTrapClass("to_exit22")

-- 定义玩家Trap事件
function tbTestTrap9:OnPlayer()
	me.NewWorld(198,1590,3839)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(0);	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap10	= tbTest:GetTrapClass("to_exit23")

-- 定义玩家Trap事件
function tbTestTrap10:OnPlayer()
	me.NewWorld(198,1666,3831)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);	
end;

-- 定义Npc Trap事件
function tbTestTrap:OnNpc()
	
end;

