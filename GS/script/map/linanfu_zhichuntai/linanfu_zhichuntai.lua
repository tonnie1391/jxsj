-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(478); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;


-------------- 【离开苏放房间】---------------
local tbTestTrap	= tbTest:GetTrapClass("zhichuntai2linanfu")

-- 定义玩家Trap事件
function tbTestTrap:OnPlayer()	
	me.NewWorld(29,1659,3868)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0)
end;

