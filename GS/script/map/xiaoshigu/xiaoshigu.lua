-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(545); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【离开硝石谷】---------------
local tbTestTrap1	= tbTest:GetTrapClass("to_exit545")

-- 定义玩家Trap事件
function tbTestTrap1:OnPlayer()	
	me.NewWorld(111,1942,3204)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;

