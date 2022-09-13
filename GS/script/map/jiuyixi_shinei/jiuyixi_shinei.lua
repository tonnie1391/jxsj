-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(217); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【韩忠房去室外--21去室外】 ---------------
local tbTestTrap	= tbTest:GetTrapClass("to_exit21")

-- 定义玩家Trap事件
function tbTestTrap:OnPlayer()
	me.NewWorld(106,1609,3568)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;

-------------- 【离开钱秉诚--26去室外】 ---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_exit26")

-- 定义玩家Trap事件
function tbTestTrap2:OnPlayer()
	me.NewWorld(106,1609,3600)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;

-------------- 【离开主管房宋东来--29去室外】 ---------------
local tbTestTrap3	= tbTest:GetTrapClass("to_exit29")

-- 定义玩家Trap事件
function tbTestTrap3:OnPlayer()
	me.NewWorld(106,1623,3603)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;

-------------- 【离开天王分舵娄一关--27去室外】 ---------------
local tbTestTrap4	= tbTest:GetTrapClass("to_exit27")

-- 定义玩家Trap事件
function tbTestTrap4:OnPlayer()
	me.NewWorld(106,1781,3419)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;




