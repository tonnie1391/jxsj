-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(509); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【离开虎师】 ---------------
local tbTestTrap19	= tbTest:GetTrapClass("to_exit509")

function tbTestTrap19:OnPlayer()
	me.NewWorld(88,1743,3351)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;

