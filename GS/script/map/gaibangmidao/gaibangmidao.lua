-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(505); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【离开丐帮分舵2木场右--18去室外】 ---------------
local tbTestTrap1	= tbTest:GetTrapClass("to_exit505")

function tbTestTrap1:OnPlayer()
	me.NewWorld(88,1668,3795)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;


-------------- 【离开丐帮分舵2木场右--18去室外】 ---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_midaowai")

function tbTestTrap2:OnPlayer()
	me.NewWorld(88,1665,3799)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;

