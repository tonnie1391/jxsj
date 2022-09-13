-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(166); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【离开赵汝愚房间】---------------
local tbTestTrap1	= tbTest:GetTrapClass("to_exit13")

-- 定义玩家Trap事件
function tbTestTrap1:OnPlayer()	
	me.NewWorld(29,1581,3818)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0)
end;


-------------- 【离开韩侂胄】---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_exit14")

-- 定义玩家Trap事件
function tbTestTrap2:OnPlayer()	
	me.NewWorld(29,1415,3964)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0)
end;


-------------- 【离开小蛮房间】---------------
local tbTestTrap3	= tbTest:GetTrapClass("to_exit15")

-- 定义玩家Trap事件
function tbTestTrap3:OnPlayer()	
	me.NewWorld(29,1430,3964)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0)
end;

-------------- 【离开苏放房间】---------------
local tbTestTrap4	= tbTest:GetTrapClass("to_exit16")

-- 定义玩家Trap事件
function tbTestTrap4:OnPlayer()	
	me.NewWorld(29,1640,3868)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0)
end;


-------------- 【离开太后房间】---------------
local tbTestTrap5	= tbTest:GetTrapClass("to_exit9")

-- 定义玩家Trap事件
function tbTestTrap5:OnPlayer()	
	me.NewWorld(29,1447,3896)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0)
end;


-------------- 【离开大殿】---------------
local tbTestTrap6	= tbTest:GetTrapClass("to_exit10")

-- 定义玩家Trap事件
function tbTestTrap6:OnPlayer()	
	me.NewWorld(29,1491,3761)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0)
end;



-------------- 【离开赵淳房间】---------------
local tbTestTrap7	= tbTest:GetTrapClass("to_exit7")

-- 定义玩家Trap事件
function tbTestTrap7:OnPlayer()	
	me.NewWorld(29,1491,3761)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0)
end;

-------------- 【离开吴氏房间-留正】---------------
local tbTestTrap8	= tbTest:GetTrapClass("to_exit8")

-- 定义玩家Trap事件
function tbTestTrap8:OnPlayer()	
	me.NewWorld(29,1491,3761)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0)
end;

-------------- 【离开吴氏房间】---------------
local tbTestTrap9	= tbTest:GetTrapClass("to_exit11")

-- 定义玩家Trap事件
function tbTestTrap9:OnPlayer()	
	me.NewWorld(29,1491,3761)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0)
end;

-------------- 【离开吴氏】---------------
local tbTestTrap10	= tbTest:GetTrapClass("to_exit12")

-- 定义玩家Trap事件
function tbTestTrap10:OnPlayer()	
	me.NewWorld(29,1491,3761)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0)
end;
