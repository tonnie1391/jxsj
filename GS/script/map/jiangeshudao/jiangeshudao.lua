-- Map 的例子加测试
-- 欢迎删除！


-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(104); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;


-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【去路边小屋---20号】---------------
local tbTestTrap1	= tbTest:GetTrapClass("to_xinshi")

-- 定义玩家Trap事件
function tbTestTrap1:OnPlayer()	
	me.NewWorld(539,1605,3189)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1);
end;

-------------- 【去吴德的房子---驿馆】 ---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_wude")

function tbTestTrap2:OnPlayer()	
	me.NewWorld(535,1604,3188)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);	
end;

-------------- 【去吴曦别院---吴曦单人】 ---------------
local tbTestTrap3	= tbTest:GetTrapClass("to_tangshi")

function tbTestTrap3:OnPlayer()
	me.NewWorld(536,1527,3126)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1);
end;
		
-------------- 【去别院会客厅---探索1-对话-2】 ---------------
local tbTestTrap4	= tbTest:GetTrapClass("to_tangque")

-- 定义玩家Trap事件
function tbTestTrap4:OnPlayer()

local task_value = me.GetTask(1024,18)
	
	if (task_value == 1) then 
		me.NewWorld(537,1527,3126)	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(0);
		return;
	else
	    me.NewWorld(538,1527,3126)	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(0);
		return;
	end		
end
	

