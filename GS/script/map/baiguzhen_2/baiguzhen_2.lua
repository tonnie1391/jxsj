-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(817); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【百蛊洞1层】---------------
local tbTestTrap1	= tbTest:GetTrapClass("to_1ceng")

-- 定义玩家Trap事件
function tbTestTrap1:OnPlayer()	
	   me.NewWorld(816,1602,3090);	-- 传送,[地图Id,坐标X,坐标Y]	
	   me.SetFightState(1);
	
end;
