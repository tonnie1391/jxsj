-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(565); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【离开韩皇后寝宫】---------------
local tbTestTrap6	= tbTest:GetTrapClass("to_exit565")

-- 定义玩家Trap事件
function tbTestTrap6:OnPlayer()	
	me.NewWorld(29,1705,3862)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0)
end;
