-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(201); -- 地图Id

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
	me.NewWorld(63,1591,3433)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1);
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_exit21")

-- 定义玩家Trap事件
function tbTestTrap2:OnPlayer()
	me.NewWorld(63,1827,3410)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap3	= tbTest:GetTrapClass("to_exit22")

-- 定义玩家Trap事件
function tbTestTrap3:OnPlayer()
	me.NewWorld(63,1557,3542)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap4	= tbTest:GetTrapClass("to_exit23")

-- 定义玩家Trap事件
function tbTestTrap4:OnPlayer()	
	me.NewWorld(63,1573,3561)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap5	= tbTest:GetTrapClass("to_exit24")

-- 定义玩家Trap事件
function tbTestTrap5:OnPlayer()
	me.NewWorld(63,1686,3424)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap6	= tbTest:GetTrapClass("to_exit25")

-- 定义玩家Trap事件
function tbTestTrap6:OnPlayer()	
	me.NewWorld(63,1827,3410)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);
end;

-- 定义Npc Trap事件
function tbTestTrap:OnNpc()
	
end;

