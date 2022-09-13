-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(404); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap	= tbTest:GetTrapClass("qiuzhishui2qingluodao")

-- 定义玩家Trap事件
function tbTestTrap:OnPlayer()
	me.NewWorld(55,1810,3487)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);	
end;