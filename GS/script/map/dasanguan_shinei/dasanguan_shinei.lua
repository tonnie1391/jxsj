-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(206); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【剑冢前往接引使--1去17房】---------------
local tbTestTrap1	= tbTest:GetTrapClass("to_jianzhongmishi")

-- 定义玩家Trap事件
function tbTestTrap1:OnPlayer()	
	me.NewWorld(206,1575,3725)	-- 传送,[地图Id,坐标X,坐标Y]	
 	me.SetFightState(1);
 		
end;
		

-------------- 【接引使去李全泰17--21号】 ---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_mishichukou")

function tbTestTrap2:OnPlayer()	
	me.NewWorld(206,1580,3847)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0);
 	
end;



-------------- 【李全泰房子出去剑冢外--21号出室外】 ---------------
local tbTestTrap3	= tbTest:GetTrapClass("to_jianzhongwai")

function tbTestTrap3:OnPlayer()
	me.NewWorld(87,1916,3324)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1);
		
end;

-------------- 【离开1去室外】 ---------------
local tbTestTrap4	= tbTest:GetTrapClass("to_exit1")

function tbTestTrap4:OnPlayer()
	me.NewWorld(87,1917,3323)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1);

end;

-------------- 【离开17去1】 ---------------
local tbTestTrap5	= tbTest:GetTrapClass("to_exit17")

function tbTestTrap5:OnPlayer()
	me.NewWorld(206,1597,3031)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1);
end;


-------------- 【离开21去17】 ---------------
local tbTestTrap6	= tbTest:GetTrapClass("to_exit21")

function tbTestTrap6:OnPlayer()
	me.NewWorld(206,1586,3697)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1);

	
end;
