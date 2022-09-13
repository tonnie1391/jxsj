-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(401); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap	= tbTest:GetTrapClass("2ceng21ceng")

-- 定义玩家Trap事件
function tbTestTrap:OnPlayer()	
	me.NewWorld(400,1625,3218)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(0);	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap2	= tbTest:GetTrapClass("2ceng23ceng")

-- 定义玩家Trap事件
function tbTestTrap2:OnPlayer()
	local task_value = me.GetTask(1022,9)
	if (task_value == 1) then 
		return;
	else
		me.NewWorld(402,1604,3257)	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);
		return;
	end	
end;