-- 少林派

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(9); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;


tbTest:GetTrapClass("to_bingqipu").OnPlayer	= function (self)
	me.NewWorld(146,1605,3230)	-- 传送,[地图Id,坐标X,坐标Y]	
end;

tbTest:GetTrapClass("to_fangjupu").OnPlayer	= function (self)
	me.NewWorld(146,1728,3235)	-- 传送,[地图Id,坐标X,坐标Y]	
end;

tbTest:GetTrapClass("to_yaodian").OnPlayer	= function (self)
	me.NewWorld(146,1842,3230)	-- 传送,[地图Id,坐标X,坐标Y]	
end;

tbTest:GetTrapClass("to_zahuodian").OnPlayer	= function (self)
	me.NewWorld(146,1948,3229)	-- 传送,[地图Id,坐标X,坐标Y]	
end;


-------------- 【知客房--16号】 ---------------
local tbTestTrap1	= tbTest:GetTrapClass("to_zhikefang")

function tbTestTrap1:OnPlayer()	
	
		local task_value = me.GetTask(1024,5)
	if (task_value == 1) then 
	  me.NewWorld(146,1946,3654)	-- 传送,[地图Id,坐标X,坐标Y]	
    me.SetFightState(0);
		return;
	else
		return;
	end		
end;
