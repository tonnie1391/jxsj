-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(408); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap	= tbTest:GetTrapClass("hd2yanziwu")

-- 定义玩家Trap事件
function tbTestTrap:OnPlayer()
	me.NewWorld(60,1287,3204)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);	
end;