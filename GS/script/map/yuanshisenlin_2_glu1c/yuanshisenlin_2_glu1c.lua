-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(414); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;


-------------- 定义特定Trap点回调 ---------------
local tbTestTrap	= tbTest:GetTrapClass("ceng12yuanshisenlin")

-- 定义玩家Trap事件
function tbTestTrap:OnPlayer()
	me.NewWorld(74,1757,3660)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap2	= tbTest:GetTrapClass("ceng12ceng2")

-- 定义玩家Trap事件
function tbTestTrap2:OnPlayer()
	me.NewWorld(415,1596,3217);	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);
end;

-- 定义Npc Trap事件
function tbTestTrap:OnNpc()
	
end;
