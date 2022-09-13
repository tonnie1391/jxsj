-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(513); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【离开千琼宫】 ---------------
local tbTestTrap4	= tbTest:GetTrapClass("to_exit513")

function tbTestTrap4:OnPlayer()
	me.NewWorld(87,1917,3323)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1);

end;

-------------- 【去天外天】 ---------------
local tbTestTrap5	= tbTest:GetTrapClass("to_tianwaitian")

function tbTestTrap5:OnPlayer()
	me.NewWorld(514,1611,3226)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0);
end;


-------------- 【离开21去17】 ---------------
local tbTestTrap6	= tbTest:GetTrapClass("to_exit21")

function tbTestTrap6:OnPlayer()
	me.NewWorld(206,1586,3697)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1);

	
end;
