--昆仑派

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(12); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;


tbTest:GetTrapClass("to_bingqipu").OnPlayer	= function (self)
	me.NewWorld(149,1605,3230)	-- 传送,[地图Id,坐标X,坐标Y]	
end;

tbTest:GetTrapClass("to_fangjupu").OnPlayer	= function (self)
	me.NewWorld(149,1728,3235)	-- 传送,[地图Id,坐标X,坐标Y]	
end;

tbTest:GetTrapClass("to_yaodian").OnPlayer	= function (self)
	me.NewWorld(149,1842,3230)	-- 传送,[地图Id,坐标X,坐标Y]	
end;

tbTest:GetTrapClass("to_zahuodian").OnPlayer	= function (self)
	me.NewWorld(149,1948,3229)	-- 传送,[地图Id,坐标X,坐标Y]	
end;
