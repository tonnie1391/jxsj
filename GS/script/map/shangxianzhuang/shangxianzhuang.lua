-- 天龙寺室内的脚本地图

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(555); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 离开 ---------------
local tbTestTrap	= tbTest:GetTrapClass("to_exit555")

-- 定义玩家Trap事件
function tbTestTrap:OnPlayer()
	me.NewWorld(112,1721,3785)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1)  	
end;
