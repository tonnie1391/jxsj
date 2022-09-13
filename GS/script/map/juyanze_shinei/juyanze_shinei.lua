-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(210); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【梁项林屋子--9号】 ---------------
local tbTestTrap1= tbTest:GetTrapClass("to_exit9")

function tbTestTrap1:OnPlayer()	
	me.NewWorld(94,1739,3829)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);	
end;

-------------- 【赌坊屋子--8号】 ---------------
local tbTestTrap2= tbTest:GetTrapClass("to_exit8")

function tbTestTrap2:OnPlayer()	
	me.NewWorld(94,1926,3260)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);	
end;


-------------- 【鲁兵--29号】 ---------------
local tbTestTrap3= tbTest:GetTrapClass("to_exit29")

function tbTestTrap3:OnPlayer()	
	me.NewWorld(94,1872,3488)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);	
end;
