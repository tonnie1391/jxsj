-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(415); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap	= tbTest:GetTrapClass("ceng22ceng1")

-- 定义玩家Trap事件
function tbTestTrap:OnPlayer()
	me.NewWorld(414,1704,3299)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);		
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap2	= tbTest:GetTrapClass("ceng22jintou")

-- 定义玩家Trap事件
function tbTestTrap2:OnPlayer()
	if (me.nSex == 1) then
    		me.NewWorld(417,1594,3193)	-- 传送,[地图Id,坐标X,坐标Y]
    		me.SetFightState(1);
	else
    		me.NewWorld(416,1594,3193)	-- 传送,[地图Id,坐标X,坐标Y]
    		me.SetFightState(1);
	end
end;

-- 定义Npc Trap事件
function tbTestTrap:OnNpc()
	
end;

