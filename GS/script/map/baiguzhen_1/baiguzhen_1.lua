-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(816); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【百蛊洞2层】---------------
local tbTestTrap1	= tbTest:GetTrapClass("to_2ceng")

-- 定义玩家Trap事件
function tbTestTrap1:OnPlayer()	
	   me.NewWorld(817,1603,3225);	-- 传送,[地图Id,坐标X,坐标Y]	
	   me.SetFightState(1);
	
end;

-------------- 【洱海摩岩】---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_erhaimoyan")

-- 定义玩家Trap事件
function tbTestTrap2:OnPlayer()	
	   me.NewWorld(91,1841,3238);	-- 传送,[地图Id,坐标X,坐标Y]	
	   me.SetFightState(1);
	
end;