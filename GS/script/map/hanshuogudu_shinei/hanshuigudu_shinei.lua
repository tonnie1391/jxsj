-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(207); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【离开丐帮分舵1木场左--21去室外】 ---------------
local tbTestTrap1	= tbTest:GetTrapClass("to_exit21")

function tbTestTrap1:OnPlayer()
	me.NewWorld(88,1631,3705)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;

-------------- 【离开丐帮分舵2木场右--18去室外】 ---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_exit18")

function tbTestTrap2:OnPlayer()
	me.NewWorld(88,1668,3795)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;


-------------- 【离开山神庙--23去室外】 ---------------
local tbTestTrap3	= tbTest:GetTrapClass("to_exit23")

function tbTestTrap3:OnPlayer()
	me.NewWorld(88,1882,3831)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;


-------------- 【第一次去丐帮分舵内部的另外一间房子17号】---------------
local tbTestTrap4	= tbTest:GetTrapClass("to_gaibangfenduo2")

-- 定义玩家Trap事件
function tbTestTrap4:OnPlayer()	
	me.NewWorld(207,1575,3725)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;

-------------- 【离开这间17去21】 ---------------
local tbTestTrap5	= tbTest:GetTrapClass("to_exit17")

function tbTestTrap5:OnPlayer()
	me.NewWorld(207,1580,3847)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;

-------------- 【去密道1--24号】 ---------------
local tbTestTrap6	= tbTest:GetTrapClass("to_midao1")

function tbTestTrap6:OnPlayer()	
	me.NewWorld(207,1802,3864)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;

-------------- 【离开密道1--24去18】 ---------------
local tbTestTrap7	= tbTest:GetTrapClass("to_exit24")

function tbTestTrap7:OnPlayer()
	me.NewWorld(207,1673,3728)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;

-------------- 【去密道2--25号】 ---------------
local tbTestTrap8	= tbTest:GetTrapClass("to_midao2")

function tbTestTrap8:OnPlayer()
	me.NewWorld(207,1886,3851)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;

-------------- 【离开密道2--25去24】 ---------------
local tbTestTrap9	= tbTest:GetTrapClass("to_exit25")

function tbTestTrap9:OnPlayer()
	me.NewWorld(207,1802,3864)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;

-------------- 【去密道3--20号】 ---------------
local tbTestTrap10	= tbTest:GetTrapClass("to_midao3")

function tbTestTrap10:OnPlayer()
	me.NewWorld(207,1867,3737)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;

-------------- 【离开密道3--20去25】 ---------------
local tbTestTrap11	= tbTest:GetTrapClass("to_exit20")

function tbTestTrap11:OnPlayer()
	me.NewWorld(207,1886,3851)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;

-------------- 【去密道4--16号】 ---------------
local tbTestTrap12	= tbTest:GetTrapClass("to_midao4")

function tbTestTrap12:OnPlayer()
	me.NewWorld(207,1928,3596)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;

-------------- 【离开密道4--16去20】 ---------------
local tbTestTrap13	= tbTest:GetTrapClass("to_exit16")

function tbTestTrap13:OnPlayer()
	me.NewWorld(207,1867,3737)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;

-------------- 【去密道出口--16号】 ---------------
local tbTestTrap14	= tbTest:GetTrapClass("to_midaochukou")

function tbTestTrap14:OnPlayer()
	me.NewWorld(88,1687,3892)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;

-------------- 【去愚叟后院--29号】 ---------------
local tbTestTrap15	= tbTest:GetTrapClass("to_yusouhouyuan")

function tbTestTrap15:OnPlayer()

	me.NewWorld(207,1861,3954)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
	
end;


-------------- 【离开愚叟后院--29去28】 ---------------
local tbTestTrap16	= tbTest:GetTrapClass("to_exit29")

function tbTestTrap16:OnPlayer()
	me.NewWorld(207,1756,3953)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0)
end;


-------------- 【离开愚叟家--28去室外】 ---------------
local tbTestTrap17	= tbTest:GetTrapClass("to_exit28")

function tbTestTrap17:OnPlayer()
	me.NewWorld(88,1909,3624)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;

-------------- 【离开贼穴--19去室外】 ---------------
local tbTestTrap18	= tbTest:GetTrapClass("to_exit19")

function tbTestTrap18:OnPlayer()
	me.NewWorld(88,1853,3210)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;


-------------- 【离开军营内--22去室外】 ---------------
local tbTestTrap19	= tbTest:GetTrapClass("to_exit22")

function tbTestTrap19:OnPlayer()
	me.NewWorld(88,1743,3351)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;


-------------- 【离开寇锐小屋1--26去室外】 ---------------
local tbTestTrap20	= tbTest:GetTrapClass("to_exit26")

function tbTestTrap20:OnPlayer()
	me.NewWorld(88,1705,3484)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;


-------------- 【离开寇锐小屋2--27去室外】 ---------------
local tbTestTrap21	= tbTest:GetTrapClass("to_exit27")

function tbTestTrap21:OnPlayer()
	me.NewWorld(88,1705,3484)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;


-------------- 【嘉王龙王庙】 ---------------
local tbTestTrap22	= tbTest:GetTrapClass("to_exit14")

function tbTestTrap22:OnPlayer()
	me.NewWorld(88,1882,3831)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;
