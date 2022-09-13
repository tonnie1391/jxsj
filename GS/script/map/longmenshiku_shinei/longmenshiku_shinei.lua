-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(218); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【离开第一美的房子---6号】---------------
local tbTestTrap1	= tbTest:GetTrapClass("to_exit6")

-- 定义玩家Trap事件
function tbTestTrap1:OnPlayer()	
	me.NewWorld(107,1709,3242)	-- 传送,[地图Id,坐标X,坐标Y]	
end;


-------------- 【离开妙法真人的房子---26号】---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_exit26")

-- 定义玩家Trap事件
function tbTestTrap2:OnPlayer()	
	me.NewWorld(107,1681,3454)	-- 传送,[地图Id,坐标X,坐标Y]	
end;



-------------- 【离开地窖---17号】---------------
local tbTestTrap3	= tbTest:GetTrapClass("to_exit17")

-- 定义玩家Trap事件
function tbTestTrap3:OnPlayer()	
	me.NewWorld(107,1710,3459)	-- 传送,[地图Id,坐标X,坐标Y]	
end;


-------------- 【去怪老头---17到13号】---------------
local tbTestTrap4	= tbTest:GetTrapClass("to_guailaotou")

-- 定义玩家Trap事件
function tbTestTrap4:OnPlayer()	
	
local task_value = me.GetTask(1024,23)
	if (task_value == 2) then 
		me.NewWorld(218,1664,3610)	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);
		return;
	else
		return;
	end		
end;	

-------------- 【离开怪老头---13号】---------------
local tbTestTrap5	= tbTest:GetTrapClass("to_exit13")

-- 定义玩家Trap事件
function tbTestTrap5:OnPlayer()	
	me.NewWorld(107,1710,3459)	-- 传送,[地图Id,坐标X,坐标Y]	
end;
