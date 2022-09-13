-- Map 的例子加测试
-- 欢迎删除

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(63); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap	= tbTest:GetTrapClass("to_xixiang")

-- 定义玩家Trap事件
function tbTestTrap:OnPlayer()
	me.NewWorld(462,1528,3126);
	--[[local task_value = me.GetTask(1022,43)
	if (task_value == 1) then 	
		me.NewWorld(201,1654,3841);	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(0);
		return;
	else
		return;
	end	]]--
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_zhengting")

-- 定义玩家Trap事件
function tbTestTrap2:OnPlayer()
	me.NewWorld(463,1555,3120);	
	--[[local task_value = me.GetTask(1022,44)
	if (task_value == 1) then 	
		me.NewWorld(201,1726,3856);	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(0);
		return;
	else
		return;
	end	]]--
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap3	= tbTest:GetTrapClass("to_zhuozheju")

-- 定义玩家Trap事件
function tbTestTrap3:OnPlayer()
	me.NewWorld(461,1611,3216);
	--[[local task_value = me.GetTask(1022,45)
	if (task_value == 1) then 	
		me.NewWorld(201,1800,3865);	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(0);
		return;
	else
		return;
	end	]]--
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap4	= tbTest:GetTrapClass("to_buyige")

-- 定义玩家Trap事件
function tbTestTrap4:OnPlayer()
	local task_value = me.GetTask(1022,46)
	if (task_value == 1) then 	
		me.NewWorld(460,1607,3208);	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(0);
		return;
	else
		me.NewWorld(459,1607,3208)	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(0);
		return;
	end	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap5	= tbTest:GetTrapClass("to_jianlongdong")

-- 定义玩家Trap事件
function tbTestTrap5:OnPlayer()
	me.NewWorld(458,1609,3455);
	--[[local task_value = me.GetTask(1022,47)
	if (task_value == 1) then 	
		me.NewWorld(201,1572,3727);	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);
		return;
	else
		return;
	end	]]--
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap6	= tbTest:GetTrapClass("to_liechang")

-- 定义玩家Trap事件
function tbTestTrap6:OnPlayer()	
	local task_value = me.GetTask(1022,48)
	if (task_value == 1) then 	
		TaskAct:Talk("湖畔猎场，非请勿进。");
		return;
	else
		me.NewWorld(63,1624,3263)	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);
		return;
	end	
end;

-- 定义Npc Trap事件
function tbTestTrap:OnNpc()
	
end;

