-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(517); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【离开小蛮房间】---------------
local tbTestTrap3	= tbTest:GetTrapClass("to_exit517")

-- 定义玩家Trap事件
function tbTestTrap3:OnPlayer()	
	me.NewWorld(29,1430,3964)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0)
end;

