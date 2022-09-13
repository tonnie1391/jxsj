-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(212); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【离开别院战斗】---------------
local tbTestTrap1	= tbTest:GetTrapClass("to_exit7")

-- 定义玩家Trap事件
function tbTestTrap1:OnPlayer()	
	me.NewWorld(98,1826,3260)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)  
end;

-------------- 【离开别院对话】 ---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_exit20")

function tbTestTrap2:OnPlayer()	
	me.NewWorld(98,1826,3260)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1)  	
end;

-------------- 【离开山寨】 ---------------
local tbTestTrap3	= tbTest:GetTrapClass("to_exit18")

function tbTestTrap3:OnPlayer()
		me.NewWorld(98,1826,3694)	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1)  	
end;
		
-------------- 【离开山寨】 ---------------
local tbTestTrap4	= tbTest:GetTrapClass("to_exit19")

function tbTestTrap4:OnPlayer()
		me.NewWorld(98,1826,3694)	-- 传送,[地图Id,坐标X,坐标Y]	
		me.SetFightState(1)  
end;
