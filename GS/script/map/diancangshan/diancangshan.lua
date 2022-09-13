-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(98); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【进入别院--战斗7房非战斗20房】---------------
local tbTestTrap1	= tbTest:GetTrapClass("to_bieyuan")

-- 定义玩家Trap事件
function tbTestTrap1:OnPlayer()	
	local task_value = me.GetTask(1024,10)
	if (task_value == 1) then 
		me.NewWorld(533,1597,3251)	-- 传送,[地图Id,坐标X,坐标Y]	
		me.SetFightState(1);
	  	return; 	  			
 	elseif (task_value == 2) then 
	  	me.NewWorld(534,1597,3251);	-- 传送,[地图Id,坐标X,坐标Y]	
		me.SetFightState(0);
		return;
  	else
  		return;
	end
end	


-------------- 【山寨，单人18，双人19】 ---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_shanzhai")
function tbTestTrap2:OnPlayer()
	
local task_value = me.GetTask(1024,9)
	  if (task_value == 1) then 
		me.NewWorld(531,1605,3188);	-- 传送,[地图Id,坐标X,坐标Y]	
	  	me.SetFightState(0);
	  	return; 
  	elseif (task_value == 2) then 
	  	me.NewWorld(532,1605,3188);	-- 传送,[地图Id,坐标X,坐标Y]	
		me.SetFightState(0);
		return;
  	else
  		return;
	end
end	



 

