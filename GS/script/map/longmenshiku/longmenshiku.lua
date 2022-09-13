-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(107); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【去第一美的房子---6号】---------------
local tbTestTrap1	= tbTest:GetTrapClass("to_diyimei")

-- 定义玩家Trap事件
function tbTestTrap1:OnPlayer()	
	me.NewWorld(218,1722,3306)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);	
end;


-------------- 【去妙法真人的房子---26号】---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_miaofazhenren")

-- 定义玩家Trap事件
function tbTestTrap2:OnPlayer()	
	me.NewWorld(218,1578,3941)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0);
end;



-------------- 【去地窖---17号】---------------
local tbTestTrap3	= tbTest:GetTrapClass("to_dijiao")

-- 定义玩家Trap事件
function tbTestTrap3:OnPlayer()	

local task_value = me.GetTask(1024,23)
	if (task_value == 1) then 
		me.NewWorld(218,1578,3728)	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);
		return;
	else
		me.NewWorld(218,1664,3610)
		me.SetFightState(1);
		return;
	end		
end;

