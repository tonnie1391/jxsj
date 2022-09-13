-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(539); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;


-------------- 【离开路边小屋】 ---------------
local tbTestTrap3	= tbTest:GetTrapClass("to_exit539")

function tbTestTrap3:OnPlayer()
		me.NewWorld(104,1612,3565)	-- 传送,[地图Id,坐标X,坐标Y]	
		me.SetFightState(1);
end;

