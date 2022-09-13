-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(29); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【赵汝愚---13】---------------
local tbTestTrap1	= tbTest:GetTrapClass("to_zhaoruyu")

-- 定义玩家Trap事件
function tbTestTrap1:OnPlayer()	
local task_value = me.GetTask(1022,137)
	if (task_value == 1) then 
		me.NewWorld(485,1555,3119)	-- 传送,[地图Id,坐标X,坐标Y]	
		me.SetFightState(0)
	else
		me.NewWorld(515,1555,3119)	-- 传送,[地图Id,坐标X,坐标Y]	
		me.SetFightState(0)
	end		
end;


-------------- 【韩侂胄房间--14】---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_hantuozhou")

-- 定义玩家Trap事件
function tbTestTrap2:OnPlayer()
local task_value = me.GetTask(1022,153)
	if (task_value == 1) then 
		me.NewWorld(809,1555,3119)	-- 传送,[地图Id,坐标X,坐标Y]	
		me.SetFightState(1)
	else
		me.NewWorld(516,1555,3119)	-- 传送,[地图Id,坐标X,坐标Y]	
		me.SetFightState(1)
	end		
end;


-------------- 【赵府偏厢】---------------
local tbTestTrap3	= tbTest:GetTrapClass("to_xiaoman")

-- 定义玩家Trap事件
function tbTestTrap3:OnPlayer()	
	me.NewWorld(517,1528,3125)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0)
end;

-------------- 【苏放房间---16】---------------
local tbTestTrap4	= tbTest:GetTrapClass("to_sufang")

-- 定义玩家Trap事件
function tbTestTrap4:OnPlayer()	
	me.NewWorld(522,1582,3213)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;



-------------- 【灵隐寺---9】---------------
local tbTestTrap5	= tbTest:GetTrapClass("to_lingyinsi")

-- 定义玩家Trap事件
function tbTestTrap5:OnPlayer()	
local task_value = me.GetTask(1024,38)
	if (task_value == 1) then 
		 TaskAct:Talk("<npc=949>:\"皇后娘娘等下要来上香还愿，闲杂人等不得入内。\"")
	     return;
	else
		 me.NewWorld(524,1639,3246)	-- 传送,[地图Id,坐标X,坐标Y]	
		 me.SetFightState(1)
		return;
	end		
end;

-------------- 【知春台---10】---------------
local tbTestTrap6	= tbTest:GetTrapClass("to_zhichuntai")

-- 定义玩家Trap事件
function tbTestTrap6:OnPlayer()	
	me.NewWorld(478,1611,3224)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;

-------------- 【朱熹府邸---11】---------------
local tbTestTrap7	= tbTest:GetTrapClass("to_zhuxifu")

-- 定义玩家Trap事件
function tbTestTrap7:OnPlayer()	
	local task_value = me.GetTask(1022,141)
	if (task_value == 1) then 
		me.NewWorld(487,1554,3119)	-- 传送,[地图Id,坐标X,坐标Y]	
		me.SetFightState(0)
	elseif (task_value == 2) then
		me.NewWorld(805,1554,3119)	-- 传送,[地图Id,坐标X,坐标Y]	
		me.SetFightState(1)
	else
		me.NewWorld(479,1554,3119)	-- 传送,[地图Id,坐标X,坐标Y]	
		me.SetFightState(0)
	end		
end;

-------------- 【彭龟年府邸---12】---------------
local tbTestTrap8	= tbTest:GetTrapClass("to_pengfu")

-- 定义玩家Trap事件
function tbTestTrap8:OnPlayer()	
	me.NewWorld(483,1527,3126)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0)
end;
-------------- 【朱熹密室---11】---------------
local tbTestTrap9	= tbTest:GetTrapClass("to_mishi")

-- 定义玩家Trap事件
function tbTestTrap9:OnPlayer()	
	local task_value = me.GetTask(1022,152)
	if (task_value == 1) then 
		me.NewWorld(806,1625,3218)	-- 传送,[地图Id,坐标X,坐标Y]	
		me.SetFightState(0)
	elseif (task_value == 2) then
		me.NewWorld(807,1625,3218)	-- 传送,[地图Id,坐标X,坐标Y]	
		me.SetFightState(0)
	else
		return;
	end		
end;
----------------------------------------------------------------------

-------------- 【韩皇后寝宫】---------------
local tbTestTrap11	= tbTest:GetTrapClass("to_hanhuanghouqingong")

-- 定义玩家Trap事件
function tbTestTrap11:OnPlayer()	
	me.NewWorld(565,1580,3214)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0)
end;

-------------- 【玉暖阁】---------------
local tbTestTrap12	= tbTest:GetTrapClass("to_yunuange")

-- 定义玩家Trap事件
function tbTestTrap12:OnPlayer()	
	me.NewWorld(566,1580, 3214)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0)
end;

-------------- 【金悦轩】---------------
local tbTestTrap13	= tbTest:GetTrapClass("to_jinyuexuan")

-- 定义玩家Trap事件
function tbTestTrap13:OnPlayer()	
	me.NewWorld(567, 1579, 3214)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0)
end;

-------------- 【皇宫大殿】---------------
local tbTestTrap14	= tbTest:GetTrapClass("to_huanggongdadian")

-- 定义玩家Trap事件
function tbTestTrap14:OnPlayer()	
	me.NewWorld(568,1578,3259)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0)
end;
