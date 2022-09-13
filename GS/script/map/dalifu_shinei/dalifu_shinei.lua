-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(165); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【离开段智兴房间】---------------
local tbTestTrap1	= tbTest:GetTrapClass("to_exit13")

-- 定义玩家Trap事件
function tbTestTrap1:OnPlayer()	
	me.NewWorld(28,1764,3306)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0)
end;


-------------- 【离开刀皇后房间】---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_exit14")

-- 定义玩家Trap事件
function tbTestTrap2:OnPlayer()	
	me.NewWorld(28,1719,3289)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0)
end;


-------------- 【罗雪房间】---------------
local tbTestTrap3	= tbTest:GetTrapClass("to_exit15")

-- 定义玩家Trap事件
function tbTestTrap3:OnPlayer()	
	me.NewWorld(28,1651,3465)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0)
end;

-------------- 【乔桑梓房间】---------------
local tbTestTrap4	= tbTest:GetTrapClass("to_exit16")

-- 定义玩家Trap事件
function tbTestTrap4:OnPlayer()	
	me.NewWorld(28,1611,3501)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0)
end;


-------------- 【萧贵妃房间】---------------
local tbTestTrap5	= tbTest:GetTrapClass("to_exit12")

-- 定义玩家Trap事件
function tbTestTrap5:OnPlayer()	
	me.NewWorld(28,1782,3356)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0)
end;


-------------- 【离开萧贵妃密室】---------------
local tbTestTrap6	= tbTest:GetTrapClass("to_exit11")

-- 定义玩家Trap事件
function tbTestTrap6:OnPlayer()	
	me.NewWorld(165,1978,3492)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0)
end;

-------------- 【萧贵妃密室】---------------
local tbTestTrap7	= tbTest:GetTrapClass("to_guifeimishi")

-- 定义玩家Trap事件
function tbTestTrap7:OnPlayer()	
	me.NewWorld(165,1837,3513)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0)
end;
