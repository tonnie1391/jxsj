-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(548); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【离开蟒蛇洞】---------------
local tbTestTrap1	= tbTest:GetTrapClass("to_exit548")

-- 定义玩家Trap事件
function tbTestTrap1:OnPlayer()	
	me.NewWorld(110,1505,3311)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;

-------------- 【前往峡谷1234】 ---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_xiagu")
function tbTestTrap2:OnPlayer()
  
local task_value = me.GetTask(1024,2)
	if (task_value == 1) then 
     	 me.NewWorld(549,1606,3220)	-- 传送,[地图Id,坐标X,坐标Y]	
		 me.SetFightState(1)
	     return;
    elseif (task_value == 2) then
		 me.NewWorld(550,1606,3220)	-- 传送,[地图Id,坐标X,坐标Y]	
		 me.SetFightState(1)
		 return;
    elseif (task_value == 3) then
		 me.NewWorld(551,1606,3220)	-- 传送,[地图Id,坐标X,坐标Y]	
		 me.SetFightState(1)
		 return;		 		 
	else
		 me.NewWorld(552,1606,3220)	-- 传送,[地图Id,坐标X,坐标Y]	
		 me.SetFightState(1)
		 return;
	end		
end;

