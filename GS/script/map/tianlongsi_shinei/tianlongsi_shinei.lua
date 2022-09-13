-- 天龙寺室内的脚本地图

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(220); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 离开信使小屋【17】 ---------------
local tbTestTrap	= tbTest:GetTrapClass("to_exit17")

-- 定义玩家Trap事件
function tbTestTrap:OnPlayer()
	me.NewWorld(112,1596,3609)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1)  	
end;

-------------- 离开寨主房间【18】---------------
local tbTestTrap1	= tbTest:GetTrapClass("to_exit18")

-- 定义玩家Trap事件
function tbTestTrap1:OnPlayer()
	me.NewWorld(112,1890,3637)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1)  	
end;

-------------- 离开三夫人房间【19】---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_exit19")

-- 定义玩家Trap事件
function tbTestTrap2:OnPlayer()
	me.NewWorld(112,1828,3685)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)  
end;

--------------离开道隐房间【20】---------------
local tbTestTrap3	= tbTest:GetTrapClass("to_exit20")

-- 定义玩家Trap事件
function tbTestTrap3:OnPlayer()
	me.NewWorld(112,1855,3646)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1) 
end;

-------------- 离开密室【9】---------------
local tbTestTrap4	= tbTest:GetTrapClass("to_exit9")

-- 定义玩家Trap事件
function tbTestTrap4:OnPlayer()
	me.NewWorld(112,1898,3782)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1) 
end;

-------------- 离开玄妙山庄【21】---------------
local tbTestTrap5	= tbTest:GetTrapClass("to_exit21")

-- 定义玩家Trap事件
function tbTestTrap5:OnPlayer()
	me.NewWorld(112,1721,3783)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1) 
end;

-------------- 离开观日楼一层【23】---------------
local tbTestTrap6	= tbTest:GetTrapClass("to_exit23")

-- 定义玩家Trap事件
function tbTestTrap6:OnPlayer()
	me.NewWorld(112,1634,3378)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1) 	
end;

-------------- 鬼主侍卫去鬼主房间【18-24】---------------
local tbTestTrap7	= tbTest:GetTrapClass("to_guizhudezhufang")

-- 定义玩家Trap事件
function tbTestTrap7:OnPlayer()
	me.NewWorld(220,1802,3864)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0) 
end;

-------------- 离开鬼主的房间---------------
local tbTestTrap8	= tbTest:GetTrapClass("to_exit24")

-- 定义玩家Trap事件
function tbTestTrap8:OnPlayer()
	me.NewWorld(112,1890,3637)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1) 
end;


-------------- 定义观日楼1层传送到观日楼2层【23-25】---------------
local tbTestTrap10	= tbTest:GetTrapClass("to_guanrilouerceng")

-- 定义玩家Trap事件
function tbTestTrap10:OnPlayer()
	me.NewWorld(220,1886,3851)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1) 	
end;

-------------- 定义观日楼2层传送到观日楼1层【25-23】---------------
local tbTestTrap11	= tbTest:GetTrapClass("to_exit25")

-- 定义玩家Trap事件
function tbTestTrap11:OnPlayer()
	me.NewWorld(220,1731,3840)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1) 
end;

-------------- 定义观日楼1层传送到观日楼地窖【23-26】---------------
local tbTestTrap12	= tbTest:GetTrapClass("to_guanriloudijiao")

-- 定义玩家Trap事件
function tbTestTrap12:OnPlayer()

	me.NewWorld(220,1578,3941)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0) 
end;

-------------- 定义观日楼地窖传送到观日楼1层---------------
local tbTestTrap13	= tbTest:GetTrapClass("to_exit26")

-- 定义玩家Trap事件
function tbTestTrap13:OnPlayer()
	me.NewWorld(112,1634,3378)	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1) 	
end;

