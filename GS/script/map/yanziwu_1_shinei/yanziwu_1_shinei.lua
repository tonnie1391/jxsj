-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(200); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap	= tbTest:GetTrapClass("to_exit5")

-- 定义玩家Trap事件
function tbTestTrap:OnPlayer()
	me.NewWorld(60,1484,2977)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_exit6")

-- 定义玩家Trap事件
function tbTestTrap2:OnPlayer()
	me.NewWorld(60,1494,3268)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap3	= tbTest:GetTrapClass("to_exit8")

-- 定义玩家Trap事件
function tbTestTrap3:OnPlayer()
	me.NewWorld(60,1420,2712)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap4	= tbTest:GetTrapClass("to_exit9")

-- 定义玩家Trap事件
function tbTestTrap4:OnPlayer()
	me.NewWorld(60,1287,3204)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap5	= tbTest:GetTrapClass("to_exit10")

-- 定义玩家Trap事件
function tbTestTrap5:OnPlayer()
    me.NewWorld(60,1363,2731)	-- 传送,[地图Id,坐标X,坐标Y]
    me.SetFightState(1);
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap6	= tbTest:GetTrapClass("to_exit11")

-- 定义玩家Trap事件
function tbTestTrap6:OnPlayer()	

end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap7	= tbTest:GetTrapClass("to_exit21")

-- 定义玩家Trap事件
function tbTestTrap7:OnPlayer()
	me.NewWorld(60,1533,3020)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap8	= tbTest:GetTrapClass("to_exit22")

-- 定义玩家Trap事件
function tbTestTrap8:OnPlayer()
	me.NewWorld(200,1596,3240)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(0);	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap9	= tbTest:GetTrapClass("to_exit23")

-- 定义玩家Trap事件
function tbTestTrap9:OnPlayer()
	me.NewWorld(60,1442,3119)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);	
end;

-- 定义Npc Trap事件
function tbTestTrap:OnNpc()
	
end;

