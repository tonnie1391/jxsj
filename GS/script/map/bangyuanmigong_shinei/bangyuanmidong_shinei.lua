-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(221); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【离开一等侍卫长---5号】---------------
local tbTestTrap1	= tbTest:GetTrapClass("to_exit5")

-- 定义玩家Trap事件
function tbTestTrap1:OnPlayer()	
	me.NewWorld(113,1553,3301)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;




-------------- 【离开石轩辕---21号】---------------
local tbTestTrap5	= tbTest:GetTrapClass("to_exit21")

-- 定义玩家Trap事件
function tbTestTrap5:OnPlayer()	
	me.NewWorld(113,1352,3189)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;

