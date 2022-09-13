-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(208); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【离开丹青生房--27去室外】---------------
local tbTestTrap1	= tbTest:GetTrapClass("to_exit27")

-- 定义玩家Trap事件
function tbTestTrap1:OnPlayer()	
	me.NewWorld(90,1700,3545)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1)	
	
end;

-------------- 【离开麻衣谷--8去室外】 ---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_exit8")

function tbTestTrap2:OnPlayer()	
	me.NewWorld(90,1902,3160)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;

-------------- 【麻衣谷去木人阵--8去9】 ---------------
local tbTestTrap3	= tbTest:GetTrapClass("to_murenzhen")

function tbTestTrap3:OnPlayer()

	me.NewWorld(208,1698,3453)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1)	
	
end;
	

-------------- 【木人阵出口--9去8】 ---------------
local tbTestTrap4	= tbTest:GetTrapClass("to_murenzhenchukou")

function tbTestTrap4:OnPlayer()
	
	me.NewWorld(208,1628,3449)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0);
	
end;
	
