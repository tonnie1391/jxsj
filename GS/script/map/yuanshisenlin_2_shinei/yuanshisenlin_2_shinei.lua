-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(205); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap	= tbTest:GetTrapClass("to_exit5")

-- 定义玩家Trap事件
function tbTestTrap:OnPlayer()
	me.NewWorld(74,1859,3474)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);		
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_exit6")

-- 定义玩家Trap事件
function tbTestTrap2:OnPlayer()
	-- local task_value = me.GetTask(1022,76)
	-- if (task_value == 1) then 	
	-- return;
	-- else
		me.NewWorld(74,1754,3724);	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);
		return;
	-- end	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap3	= tbTest:GetTrapClass("to_exit8")

-- 定义玩家Trap事件
function tbTestTrap3:OnPlayer()
	local task_value = me.GetTask(1022,30)
	if (task_value == 2) then 	
		if (me.nSex == 1) then
    		me.NewWorld(205,1727,3859)	-- 传送,[地图Id,坐标X,坐标Y]
    		me.SetFightState(1);
		else
    		me.NewWorld(205,1801,3865)	-- 传送,[地图Id,坐标X,坐标Y]
    		me.SetFightState(1);
		end
	else	
		me.NewWorld(74,1757,3660)	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);
		return;
	end
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap4	= tbTest:GetTrapClass("to_exit17")

-- 定义玩家Trap事件
function tbTestTrap4:OnPlayer()
	-- local task_value = me.GetTask(1022,77)
	-- if (task_value == 1) then 	
	-- 	return;
	-- else
		me.NewWorld(74,1857,3579);	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);
		return;
	-- end	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap5	= tbTest:GetTrapClass("to_exit18")

-- 定义玩家Trap事件
function tbTestTrap5:OnPlayer()
	local task_value = me.GetTask(1022,25)
	if (task_value == 1) then 	
		return;
	else
		me.NewWorld(74,1857,3579);	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);
		return;
	end	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap6	= tbTest:GetTrapClass("to_exit19")

-- 定义玩家Trap事件
function tbTestTrap6:OnPlayer()	
	me.NewWorld(74,1612,3722)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap7	= tbTest:GetTrapClass("to_exit21")

-- 定义玩家Trap事件
function tbTestTrap7:OnPlayer()
	me.NewWorld(74,1793,3565)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1);
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap8	= tbTest:GetTrapClass("to_exit22")

-- 定义玩家Trap事件
function tbTestTrap8:OnPlayer()
	me.NewWorld(74,1793,3565)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1);
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap9	= tbTest:GetTrapClass("to_exit23")

-- 定义玩家Trap事件
function tbTestTrap9:OnPlayer()
	me.NewWorld(74,1757,3660)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap10	= tbTest:GetTrapClass("to_exit24")

-- 定义玩家Trap事件
function tbTestTrap10:OnPlayer()
    me.NewWorld(74,1757,3660)	-- 传送,[地图Id,坐标X,坐标Y]
    me.SetFightState(1);
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap11	= tbTest:GetTrapClass("to_exit25")

-- 定义玩家Trap事件
function tbTestTrap11:OnPlayer()
	me.NewWorld(74,1755,3726)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap12	= tbTest:GetTrapClass("to_exit26")

-- 定义玩家Trap事件
function tbTestTrap12:OnPlayer()
	me.NewWorld(74,1774,3487)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap13	= tbTest:GetTrapClass("to_exit27")

-- 定义玩家Trap事件
function tbTestTrap13:OnPlayer()
	me.NewWorld(74,1895,3474)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1);
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap14	= tbTest:GetTrapClass("to_exit28")

-- 定义玩家Trap事件
function tbTestTrap14:OnPlayer()
	me.NewWorld(74,1895,3474)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1);
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap15	= tbTest:GetTrapClass("to_exit3")

-- 定义玩家Trap事件
function tbTestTrap15:OnPlayer()
	me.NewWorld(74,1609,3247)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1);
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap16	= tbTest:GetTrapClass("to_exit4")

-- 定义玩家Trap事件
function tbTestTrap16:OnPlayer()
	me.NewWorld(74,1609,3247)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1);
end;

-- 定义Npc Trap事件
function tbTestTrap:OnNpc()
	
end;

