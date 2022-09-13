-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(199); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap	= tbTest:GetTrapClass("to_exit3")

-- 定义玩家Trap事件
function tbTestTrap:OnPlayer()
	me.NewWorld(59,1531,2832)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);		
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_exit17")

-- 定义玩家Trap事件
function tbTestTrap2:OnPlayer()
	me.NewWorld(59,1545,3139)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1);
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap3	= tbTest:GetTrapClass("to_exit21")

-- 定义玩家Trap事件
function tbTestTrap3:OnPlayer()
    me.NewWorld(59,1475,3114)	-- 传送,[地图Id,坐标X,坐标Y]
    me.SetFightState(1);	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap4	= tbTest:GetTrapClass("to_exit22")

-- 定义玩家Trap事件
function tbTestTrap4:OnPlayer()
	me.NewWorld(59,1475,3114)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap5	= tbTest:GetTrapClass("to_exit23")

-- 定义玩家Trap事件
function tbTestTrap5:OnPlayer()
	me.NewWorld(59,1441,2588)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap6	= tbTest:GetTrapClass("to_exit24")

-- 定义玩家Trap事件
function tbTestTrap6:OnPlayer()	
	me.NewWorld(59,1531,2832)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap7	= tbTest:GetTrapClass("to_exit25")

-- 定义玩家Trap事件
function tbTestTrap7:OnPlayer()
	me.NewWorld(59,1409,2919)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap8	= tbTest:GetTrapClass("to_exit26")

-- 定义玩家Trap事件
function tbTestTrap8:OnPlayer()
	me.NewWorld(59,1531,2832)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap9	= tbTest:GetTrapClass("to_exit27")

-- 定义玩家Trap事件
function tbTestTrap9:OnPlayer()
	me.NewWorld(59,1441,2588)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap10	= tbTest:GetTrapClass("to_exit28")

-- 定义玩家Trap事件
function tbTestTrap10:OnPlayer()
	me.NewWorld(199,1667,3944)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(0);
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap11	= tbTest:GetTrapClass("to_exit29")

-- 定义玩家Trap事件
function tbTestTrap11:OnPlayer()
	me.NewWorld(59,1531,2832)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);
end;

-- 定义Npc Trap事件
function tbTestTrap:OnNpc()
	
end;

