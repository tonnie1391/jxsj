-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(533); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【离开别院战斗】---------------
local tbTestTrap1	= tbTest:GetTrapClass("to_exit533")

-- 定义玩家Trap事件
function tbTestTrap1:OnPlayer()	
	me.NewWorld(98,1826,3260)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)  
end;
