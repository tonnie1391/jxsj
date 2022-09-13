-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(216); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)

end;

		
-------------- 【离开吴德房子----28去室外】 ---------------
local tbTestTrap1	= tbTest:GetTrapClass("to_exit28")

function tbTestTrap1:OnPlayer()
		me.NewWorld(104,1793,3526)	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);	
end;

-------------- 【离开唐缺房子----14去室外】 ---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_exit14")

function tbTestTrap2:OnPlayer()
		me.NewWorld(104,1927,3311)	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);	
end;



-------------- 【离开信使房子----20去室外】 ---------------
local tbTestTrap3	= tbTest:GetTrapClass("to_exit20")

function tbTestTrap3:OnPlayer()
		me.NewWorld(104,1612,3565)	-- 传送,[地图Id,坐标X,坐标Y]	
		me.SetFightState(1);
end;




-------------- 【离开唐缺房子----15去室外】 ---------------
local tbTestTrap4	= tbTest:GetTrapClass("to_exit15")

function tbTestTrap4:OnPlayer()
		me.NewWorld(104,1927,3311)	-- 传送,[地图Id,坐标X,坐标Y]	
		me.SetFightState(1);
end;


-------------- 【离开唐石房子----26去室外】 ---------------
local tbTestTrap5	= tbTest:GetTrapClass("to_exit26")

function tbTestTrap5:OnPlayer()
		me.NewWorld(104,1895,3321)	-- 传送,[地图Id,坐标X,坐标Y]	
		me.SetFightState(1);
end;

