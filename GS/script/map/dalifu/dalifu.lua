-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(28); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【段智兴房间】---------------
local tbTestTrap1	= tbTest:GetTrapClass("to_duanzhixing")

-- 定义玩家Trap事件
function tbTestTrap1:OnPlayer()	
	me.NewWorld(165,1609,3666)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0)
end;


-------------- 【刀皇后房间】---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_daohuanghou")

-- 定义玩家Trap事件
function tbTestTrap2:OnPlayer()	
	   me.NewWorld(165,1724,3663)	-- 传送,[地图Id,坐标X,坐标Y]	
	   me.SetFightState(0)
	
end;


-------------- 【罗雪房间】---------------
local tbTestTrap3	= tbTest:GetTrapClass("to_luoxue")

-- 定义玩家Trap事件
function tbTestTrap3:OnPlayer()	
	me.NewWorld(165,1836,3665)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0)
end;

-------------- 【乔桑梓房间】---------------
local tbTestTrap4	= tbTest:GetTrapClass("to_qiaosangzi")

-- 定义玩家Trap事件
function tbTestTrap4:OnPlayer()	
	me.NewWorld(165,1946,3654)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0)
end;


-------------- 【萧贵妃房间】---------------
local tbTestTrap5	= tbTest:GetTrapClass("to_xiaoguifei")

-- 定义玩家Trap事件
function tbTestTrap5:OnPlayer()	
	me.NewWorld(165,1950,3494)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0)
end;



-------------- 【密道===剑阁蜀道19号】---------------
local tbTestTrap6	= tbTest:GetTrapClass("to_dalimidao")

-- 定义玩家Trap事件
function tbTestTrap6:OnPlayer()	
	
local task_value = me.GetTask(1024,14)
	if (task_value == 1) then 
		me.NewWorld(216,1770,3734)	-- 传送,[地图Id,坐标X,坐标Y]	
		me.SetFightState(1)
		return;
	else
	   return;
	end		
end;

-------------- 【大理皇宫】---------------
local tbTestTrap7	= tbTest:GetTrapClass("to_huanggong")

-- 定义玩家Trap事件
function tbTestTrap7:OnPlayer()	
	me.NewWorld(819,1578,3243)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0)
end;
