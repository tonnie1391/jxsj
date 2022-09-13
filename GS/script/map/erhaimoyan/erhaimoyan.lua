-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(91); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【前往鬼母前洞--25号】---------------
local tbTestTrap1	= tbTest:GetTrapClass("to_guimuqiandong")

-- 定义玩家Trap事件
function tbTestTrap1:OnPlayer()	
	me.NewWorld(209,1886,3851);	-- 传送,[地图Id,坐标X,坐标Y]	
end;

-------------- 【百蛊洞1层】---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_baiguzhen")

-- 定义玩家Trap事件
function tbTestTrap2:OnPlayer()	
	   me.NewWorld(816,1562,3255);	-- 传送,[地图Id,坐标X,坐标Y]	
	   me.SetFightState(1);
	
end;

-------------- 【仙灵洞】---------------
local tbTestTrap3	= tbTest:GetTrapClass("to_lingdong")

-- 定义玩家Trap事件
function tbTestTrap3:OnPlayer()	
	   me.NewWorld(818,1618,3158);	-- 传送,[地图Id,坐标X,坐标Y]	
	   me.SetFightState(0);
	
end;
