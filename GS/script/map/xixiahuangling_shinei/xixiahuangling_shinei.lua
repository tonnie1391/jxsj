-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(219); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【离开太后銮驾---26号】---------------
local tbTestTrap1	= tbTest:GetTrapClass("to_exit26")

-- 定义玩家Trap事件
function tbTestTrap1:OnPlayer()	
	me.NewWorld(108,1948,3148)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1);
end;


-------------- 【离开中央密室---20号】---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_exit20")

-- 定义玩家Trap事件
function tbTestTrap2:OnPlayer()	
	me.NewWorld(108,1917,3258)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);	
end;



-------------- 【离开尸芋花---29号】---------------
local tbTestTrap3	= tbTest:GetTrapClass("to_exit29")

-- 定义玩家Trap事件
function tbTestTrap3:OnPlayer()	
	me.NewWorld(108,1781,3587)	-- 传送,[地图Id,坐标X,坐标Y]	
end;


