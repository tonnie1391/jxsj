-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(479); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;


-------------- 【离开朱熹房间】---------------
local tbTestTrap	= tbTest:GetTrapClass("to_linanfu")

-- 定义玩家Trap事件
function tbTestTrap:OnPlayer()	
	local task_value = me.GetTask(1022,134)
	if (task_value == 1) then 	
		me.NewWorld(480,1530,3956);	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);
		return;
	elseif (task_value == 2) then 	
		me.NewWorld(481,1530,3956);	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);
		return;
	elseif (task_value == 3) then 	
		me.NewWorld(482,1530,3956);	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);
		return;
	else
		me.NewWorld(29,1530,3956);	-- 传送,[地图Id,坐标X,坐标Y]	
		me.SetFightState(0)
	end
end;

