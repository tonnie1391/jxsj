-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(72); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap	= tbTest:GetTrapClass("to_chunmeiyazhu")

-- 定义玩家Trap事件
function tbTestTrap:OnPlayer()
	local task_value = me.GetTask(1022,51)
	if (task_value == 1) then 	
		me.NewWorld(464,1528,3126);	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(0);
		return;
	elseif (task_value == 2) then 
		me.NewWorld(465,1528,3126);	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(0);
		return;
	elseif (task_value == 3) then 
		me.NewWorld(466,1528,3126);	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(0);
		return;
	else
		me.NewWorld(464,1528,3126);
		return;
	end	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_chunmeiyazhu2")

-- 定义玩家Trap事件
function tbTestTrap2:OnPlayer()
	local task_value = me.GetTask(1022,52)
	if (task_value == 1) then 	
		me.NewWorld(468,1528,3126);	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(0);
		return;
	elseif (task_value == 2) then 
		me.NewWorld(467,1528,3126);	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(0);
		return;
	else
		me.NewWorld(467,1528,3126);
		return;
	end	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap3	= tbTest:GetTrapClass("to_guanyi")

-- 定义玩家Trap事件
function tbTestTrap3:OnPlayer()
	local task_value = me.GetTask(1022,53)
	if (task_value == 1) then
		return;
	else
		me.NewWorld(72,1960,3473)	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);
		TaskAct:Talk("内有贵客，非请勿进。");
		return;
	end			
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap4	= tbTest:GetTrapClass("to_guanyi2")

-- 定义玩家Trap事件
function tbTestTrap4:OnPlayer()
	local task_value = me.GetTask(1022,54)
	if (task_value == 1) then 	
		me.NewWorld(469,1617,3201);	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(0);
		return;
	elseif (task_value == 2) then 
		me.NewWorld(470,1617,3201);	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);
		return;
	else
		me.NewWorld(470,1617,3201);
		return;
	end	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap5	= tbTest:GetTrapClass("to_pinhetang")

-- 定义玩家Trap事件
function tbTestTrap5:OnPlayer()
	me.NewWorld(475,1554,3119);
	--[[local task_value = me.GetTask(1022,55)
	if (task_value == 1) then 	
		me.NewWorld(475,1554,3119);	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(0);
		return;
	else
		return;
	end	]]--
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap6	= tbTest:GetTrapClass("to_qiushuangge")

-- 定义玩家Trap事件
function tbTestTrap6:OnPlayer()	
	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap7	= tbTest:GetTrapClass("to_xiacengzhenfa")

-- 定义玩家Trap事件
function tbTestTrap7:OnPlayer()
	local task_value = me.GetTask(1022,56)
	if (task_value == 1) then 	
		me.NewWorld(471,1632,3212);	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);
		return;	
	else
		me.NewWorld(472,1660,3177);
		return;
	end	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap8	= tbTest:GetTrapClass("to_xuanyuedazhen")

-- 定义玩家Trap事件
function tbTestTrap8:OnPlayer()
	me.NewWorld(473,1619,3209);	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);
	--[[local task_value = me.GetTask(1022,56)
	if (task_value == 1) then 	
		me.NewWorld(204,1858,3956);	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);
		return;
	elseif (task_value == 2) then 
		me.NewWorld(204,1608,3716);	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);
		return;
	elseif (task_value == 3) then 
		me.NewWorld(204,1756,3956);	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);
		return;		
	else
		me.NewWorld(204,1608,3716);
		return;
	end	]]--
end;

-- 定义Npc Trap事件
function tbTestTrap:OnNpc()
	
end;

