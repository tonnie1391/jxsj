-- 天龙寺室内的脚本地图

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(554); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 离开 ---------------
local tbTestTrap	= tbTest:GetTrapClass("to_exit554")

-- 定义玩家Trap事件
function tbTestTrap:OnPlayer()
	me.NewWorld(112,1891,3641)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1)  	
end;
