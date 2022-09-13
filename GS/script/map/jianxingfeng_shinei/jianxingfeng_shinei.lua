-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(196); -- 地图Id

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
	me.NewWorld(48,1794,3273)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1);
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_exit21")

-- 定义玩家Trap事件
function tbTestTrap2:OnPlayer()
	me.NewWorld(48,1766,3455)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap3	= tbTest:GetTrapClass("to_exit22")

-- 定义玩家Trap事件
function tbTestTrap3:OnPlayer()
	me.NewWorld(48,1766,3455)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1);
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap4	= tbTest:GetTrapClass("to_exit18")

-- 定义玩家Trap事件
function tbTestTrap4:OnPlayer()
	me.NewWorld(48,1789,3293)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1);
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap5	= tbTest:GetTrapClass("to_exit19")

-- 定义玩家Trap事件
function tbTestTrap5:OnPlayer()
	me.NewWorld(48,1802,3302)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1);
end;

-- 定义Npc Trap事件
function tbTestTrap:OnNpc()
	
end;

