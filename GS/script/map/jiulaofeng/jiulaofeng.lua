-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(51); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap	= tbTest:GetTrapClass("to_biyueshantang")

-- 定义玩家Trap事件
function tbTestTrap:OnPlayer()
	local task_value = me.GetTask(1022,34)
	if (task_value == 1) then 	
		return;
	else
		me.NewWorld(51,1572,3153)	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);
		me.Msg("内有贵客，闲杂人等不得入内。");
		return;
	end	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_xingzaineiying")

-- 定义玩家Trap事件
function tbTestTrap2:OnPlayer()
	--local task_value = me.GetTask(1022,35)
	--if (task_value == 2) then 
		me.NewWorld(454,1554,3119)	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(0);
		return;
	--[[else
		me.NewWorld(197,1572,3727);	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);
		return;
	end]]--
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap3	= tbTest:GetTrapClass("to_ciyunan")

-- 定义玩家Trap事件
function tbTestTrap3:OnPlayer()
	me.NewWorld(456,1619,3220)
	--[[local task_value = me.GetTask(1022,36)
	if (task_value == 1) then 	
		me.NewWorld(197,1579,3848)	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(0);
		return;
	else
		return;
	end	]]--
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap4	= tbTest:GetTrapClass("to_chouxuewoshi")

-- 定义玩家Trap事件
function tbTestTrap4:OnPlayer()
	me.NewWorld(457,1606,3209)
	--[[local task_value = me.GetTask(1022,37)
	if (task_value == 1) then 	
		me.NewWorld(457,1606,3209)	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(0);
		return;
	else
		return;
	end	]]--
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap5	= tbTest:GetTrapClass("to_jianxueting")

-- 定义玩家Trap事件
function tbTestTrap5:OnPlayer()
	local task_value = me.GetTask(1022,38)
	if (task_value == 1) then 	
		return;
	else
		me.NewWorld(51,1436,3429)	-- 传送,[地图Id,坐标X,坐标Y]
		TaskAct:Talk("内有贵客，闲杂人等不得入内。");
		return;
	end	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap6	= tbTest:GetTrapClass("to_xingzaidamen")

-- 定义玩家Trap事件
function tbTestTrap6:OnPlayer()	
	--[[local task_value = me.GetTask(1022,35)
	if (task_value == 1) then
		me.NewWorld(197,1572,3727);	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);
		return;
	else
		return;
	end]]--
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap7	= tbTest:GetTrapClass("to_houshanxiaojing")

-- 定义玩家Trap事件
function tbTestTrap7:OnPlayer()	
	me.NewWorld(197,1679,3721);
	--[[local task_value = me.GetTask(1022,39)
	if (task_value == 1) then 	
		me.NewWorld(197,1679,3721);	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);
		return;
	else
		return;
	end	]]--
end;

-- 定义Npc Trap事件
function tbTestTrap:OnNpc()
	
end;

