-- 昆仑派室内


-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(149); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;


tbTest:GetTrapClass("to_exit1").OnPlayer	= function (self)
	me.NewWorld(12,1732,3298)	-- 传送,[地图Id,坐标X,坐标Y]	
end;

tbTest:GetTrapClass("to_exit2").OnPlayer	= function (self)
	me.NewWorld(12,1751,3320)	-- 传送,[地图Id,坐标X,坐标Y]	
end;

tbTest:GetTrapClass("to_exit3").OnPlayer	= function (self)
	me.NewWorld(12,1835,3411)	-- 传送,[地图Id,坐标X,坐标Y]	
end;

tbTest:GetTrapClass("to_exit4").OnPlayer	= function (self)
	me.NewWorld(12,1851,3426)	-- 传送,[地图Id,坐标X,坐标Y]	
end;
