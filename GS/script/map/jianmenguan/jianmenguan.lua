-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(111); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【硝石谷】---------------
local tbTestTrap1	= tbTest:GetTrapClass("to_xiaoshigu")

-- 定义玩家Trap事件
function tbTestTrap1:OnPlayer()	
	me.NewWorld(545,1703,3291)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;

