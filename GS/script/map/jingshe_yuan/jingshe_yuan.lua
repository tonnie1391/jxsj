-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(802); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap	= tbTest:GetTrapClass("to_wuyishan")

-- 定义玩家Trap事件
function tbTestTrap:OnPlayer()	
	me.NewWorld(120,1704,3280);	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_shutong")

-- 定义玩家Trap事件
function tbTestTrap2:OnPlayer()
	me.NewWorld(803,1625,3218);	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(0);	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap3	= tbTest:GetTrapClass("to_liniang")

-- 定义玩家Trap事件
function tbTestTrap3:OnPlayer()
	me.NewWorld(804,1528,3126);	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(0);	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap4	= tbTest:GetTrapClass("to_mudi")

-- 定义玩家Trap事件
function tbTestTrap4:OnPlayer()
	me.NewWorld(808,1594,3193);	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(0);	
end;

-- 定义Npc Trap事件
function tbTestTrap:OnNpc()
	
end;

