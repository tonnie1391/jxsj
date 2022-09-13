-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(429); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap	= tbTest:GetTrapClass("2ceng2jianxingfeng")

-- 定义玩家Trap事件
function tbTestTrap:OnPlayer()
	me.NewWorld(48,1789,3293)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1);
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap2	= tbTest:GetTrapClass("zhongxin2bianyuan")

-- 定义玩家Trap事件
function tbTestTrap2:OnPlayer()
	me.NewWorld(429,1641,3138)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap3	= tbTest:GetTrapClass("bianyuan2zhongxin")

-- 定义玩家Trap事件
function tbTestTrap3:OnPlayer()
	me.NewWorld(429,1608,3201)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1);
end;


-- 定义Npc Trap事件
function tbTestTrap:OnNpc()
	
end;

