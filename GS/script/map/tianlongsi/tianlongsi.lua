-- 天龙寺的脚本地图

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(112); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 大日罗 ---------------
local tbTestTrap	= tbTest:GetTrapClass("to_dariluo")

-- 定义玩家Trap事件
function tbTestTrap:OnPlayer()
	me.NewWorld(554,1604,3187)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1);
end;


-------------- 上仙庄 ---------------
local tbTestTrap1	= tbTest:GetTrapClass("to_shangxianzhuang")

-- 定义玩家Trap事件
function tbTestTrap1:OnPlayer()
	me.NewWorld(555,1554,3119)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1);
end;




