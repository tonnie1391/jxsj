-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(88); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【丐帮分舵】---------------
local tbTestTrap1	= tbTest:GetTrapClass("to_gaibangfenduo1")

-- 定义玩家Trap事件
function tbTestTrap1:OnPlayer()	
	me.NewWorld(504,1605,3189)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;

-------------- 【山神庙】 ---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_shanshenmiao")
function tbTestTrap2:OnPlayer()
  
local task_value = me.GetTask(1024,37)
	if (task_value == 1) then 
     	 me.NewWorld(506,1618,3158)	-- 传送,[地图Id,坐标X,坐标Y]	
		 me.SetFightState(0)
	     return;
    elseif (task_value == 2) then
		 me.NewWorld(507,1618,3158)	-- 传送,[地图Id,坐标X,坐标Y]	
		 me.SetFightState(0)
		 return;
	else
			return;
	end		
end;

-------------- 【丐帮秘道】--------
local tbTestTrap3	= tbTest:GetTrapClass("to_gaibangfenduo3")

function tbTestTrap3:OnPlayer()	
	me.NewWorld(505,1590,3208)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;

-------------- 【隐所】 ---------------
local tbTestTrap4	= tbTest:GetTrapClass("to_yusoujia")

function tbTestTrap4:OnPlayer()
	me.NewWorld(503,1607,3208)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;

-------------- 【山洞】 ---------------
local tbTestTrap5	= tbTest:GetTrapClass("to_zeixue")

function tbTestTrap5:OnPlayer()
	me.NewWorld(508,1613,3237)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;

-------------- 【军营内部】 ---------------
local tbTestTrap6	= tbTest:GetTrapClass("to_junyingneibu")

function tbTestTrap6:OnPlayer()
	
	me.NewWorld(509,1633,3239)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;


-------------- 【顾重颜茅屋】 ---------------
local tbTestTrap7	= tbTest:GetTrapClass("to_kouruixiaowu")

function tbTestTrap7:OnPlayer()
  
local task_value = me.GetTask(1024,1)
	if (task_value == 1) then 
     	 me.NewWorld(502,1610,3217)	-- 传送,[地图Id,坐标X,坐标Y]	
		 me.SetFightState(1)
	     return;
    elseif (task_value == 2) then
		 me.NewWorld(501,1610,3217)	-- 传送,[地图Id,坐标X,坐标Y]	
		 me.SetFightState(0)
		 return;
	else
			return;
	end		
end;
