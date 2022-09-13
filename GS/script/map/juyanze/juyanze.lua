-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(94); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;


-------------- 【梁项林屋子--527】 ---------------
local tbTestTrap1	= tbTest:GetTrapClass("to_liangxianglin")

function tbTestTrap1:OnPlayer()	
	
	me.NewWorld(527,1600,3237)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1);	
end;



-------------- 【鲁兵--526】 ---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_lubing")

function tbTestTrap2:OnPlayer()	
	
	me.NewWorld(526,1617,3217)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0);	
end;



-------------- 【赌坊---525】 ---------------
local tbTestTrap3	= tbTest:GetTrapClass("to_dufang")

function tbTestTrap3:OnPlayer()	
	
	me.NewWorld(525,1611,3224)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1);	
end;

