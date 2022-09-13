-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(400); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap	= tbTest:GetTrapClass("1ceng2qingluodao")

-- 定义玩家Trap事件
function tbTestTrap:OnPlayer()	
	me.NewWorld(55,1614,3198)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap2	= tbTest:GetTrapClass("1ceng22ceng")

-- 定义玩家Trap事件
function tbTestTrap2:OnPlayer()
	--local task_value = me.GetTask(1022,8)
	if (task_value == 1) then 
		return;
	else
		me.NewWorld(401,1574,3273)	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);
		return;
	end	
end;