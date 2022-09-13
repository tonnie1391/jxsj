-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(540); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【韩忠房去室外--21去室外】 ---------------
local tbTestTrap	= tbTest:GetTrapClass("to_exit540")

-- 定义玩家Trap事件
function tbTestTrap:OnPlayer()
	me.NewWorld(106,1612,3572)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;

