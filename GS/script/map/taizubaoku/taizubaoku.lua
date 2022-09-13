-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(553); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【离开太祖宝库】---------------
local tbTestTrap1	= tbTest:GetTrapClass("to_exit553")

-- 定义玩家Trap事件
function tbTestTrap1:OnPlayer()	

local task_value = me.GetTask(1024,2)
	if (task_value == 3) then 
		 me.NewWorld(551,1636,3066)	-- 传送,[地图Id,坐标X,坐标Y]	
		 me.SetFightState(1)
	     return;		 		 
	else
		 me.NewWorld(552,1636,3066)	-- 传送,[地图Id,坐标X,坐标Y]	
		 me.SetFightState(1)
		 return;
	end		
end;
