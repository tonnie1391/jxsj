-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(21); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap	= tbTest:GetTrapClass("xizuo")

-- 定义玩家Trap事件
function tbTestTrap:OnPlayer()
	local task_value = me.GetTask(1022,151)
	if (task_value == 1) then 	
		me.NewWorld(800,1605,3190);	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);
		return;
	elseif (task_value == 2) then 
		me.NewWorld(801,1605,3190);	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);
		return;
	elseif (task_value == 3) then 
		me.NewWorld(810,1605,3190);	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);
		return;
	else
		return;
	end	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap	= tbTest:GetTrapClass("qiehuan")

-- 定义玩家Trap事件
function tbTestTrap:OnPlayer()
	if (me.nFightState == 1) then 	
		me.NewWorld(21,1723,3428);	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(0);
	else
		me.NewWorld(21,1727,3436);	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);
		return;
	end	
end;

-- 定义Npc Trap事件
function tbTestTrap:OnNpc()
	
end;

