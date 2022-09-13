-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(209); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【前往鬼母后洞--29号】---------------
local tbTestTrap1	= tbTest:GetTrapClass("to_guimuhoudong")

-- 定义玩家Trap事件
function tbTestTrap1:OnPlayer()	
	me.NewWorld(209,1861,3954)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;

-------------- 【离开鬼母后洞--29去25号】---------------
local tbTestTrap1	= tbTest:GetTrapClass("to_exit29")

-- 定义玩家Trap事件
function tbTestTrap1:OnPlayer()	
	me.NewWorld(209,1886,3834)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0)
end;


-------------- 【离开鬼母前洞--25去室外】---------------
local tbTestTrap1	= tbTest:GetTrapClass("to_exit25")

-- 定义玩家Trap事件
function tbTestTrap1:OnPlayer()	
	me.NewWorld(91,1659,3658)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;
