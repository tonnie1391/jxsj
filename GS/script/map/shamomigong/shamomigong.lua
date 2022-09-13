-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(101); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【去旅店】---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_lvdian")

-- 定义玩家Trap事件
function tbTestTrap2:OnPlayer()	
	me.NewWorld(543,1605,3189)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;



-------------- 【一品堂兵营】 ---------------
local tbTestTrap7	= tbTest:GetTrapClass("to_chalahan")

function tbTestTrap7:OnPlayer()
  
local task_value = me.GetTask(1024,25)
	if (task_value == 2) then 
         TaskAct:Talk("<npc=971>:\"什么人胆敢乱闯军营？\"")
		 return;
	else	
     	 me.NewWorld(544,1633,3239)	-- 传送,[地图Id,坐标X,坐标Y]	
		 me.SetFightState(1)
		return; 
	end		

end	
