-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(561); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【进入荒屋】---------------
local tbTestTrap1	= tbTest:GetTrapClass("to_huangwu")

-- 定义玩家Trap事件
function tbTestTrap1:OnPlayer()	
	   me.NewWorld(562,1605,3210);	-- 传送,[地图Id,坐标X,坐标Y]	
	   me.SetFightState(1);
	
end;

-------------- 【王府密室】---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_wangfumishi")

-- 定义玩家Trap事件
function tbTestTrap2:OnPlayer()	
	   me.NewWorld(563,1591,3208);	-- 传送,[地图Id,坐标X,坐标Y]	
	   me.SetFightState(1);
	
end;


-------------- 【漠北草原】---------------
local tbTestTrap3	= tbTest:GetTrapClass("to_mobeicaoyuan")

-- 定义玩家Trap事件
function tbTestTrap3:OnPlayer()	
	   me.NewWorld(122,1972,3503);	-- 传送,[地图Id,坐标X,坐标Y]	
	   me.SetFightState(1);
	
end;