-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(546); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【离开聚义楼】---------------
local tbTestTrap1	= tbTest:GetTrapClass("to_exit546")

-- 定义玩家Trap事件
function tbTestTrap1:OnPlayer()	
	me.NewWorld(109,1697,3282)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;


-------------- 【阁楼】---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_gelou")

-- 定义玩家Trap事件
function tbTestTrap2:OnPlayer()	
	me.NewWorld(547,1582,3211)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0)
end;

