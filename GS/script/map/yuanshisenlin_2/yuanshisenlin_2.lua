-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(74); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap	= tbTest:GetTrapClass("to_shandi")

-- 定义玩家Trap事件
function tbTestTrap:OnPlayer()
	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_yucangfeng")

-- 定义玩家Trap事件
function tbTestTrap2:OnPlayer()
	me.NewWorld(424,1605,3218);
	--[[local task_value = me.GetTask(1022,26)
	if (task_value == 1) then 	
		me.NewWorld(424,1605,3218)	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(0);
		return;
	else
		me.NewWorld(413,1756,3727)	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);		
		return;
	end]]--	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap3	= tbTest:GetTrapClass("to_yinfang")

-- 定义玩家Trap事件
function tbTestTrap3:OnPlayer()
	me.NewWorld(423,1554,3120);
	--[[local task_value = me.GetTask(1022,27)
	if (task_value == 1) then 	
		me.NewWorld(205,1578,3850)	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(0);
		return;
	else
		return;
	end ]]--
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap4	= tbTest:GetTrapClass("to_yintong")

-- 定义玩家Trap事件
function tbTestTrap4:OnPlayer()
	me.NewWorld(422,1528,3125);
	--[[local task_value = me.GetTask(1022,28)
	if (task_value == 1) then 	
		me.NewWorld(205,1655,3842)	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(0);
		return;
	else
		return;
	end	]]--		
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap5	= tbTest:GetTrapClass("to_wuguigu")

-- 定义玩家Trap事件
function tbTestTrap5:OnPlayer()
	local task_value = me.GetTask(1022,29)
	if (task_value == 1) then 	
		return;
	else
		me.NewWorld(74,1875,3625)	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);
		TaskAct:Talk("谷内凶险，还是不要进去了。");
		return;
	end	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap6	= tbTest:GetTrapClass("to_ganlugu")

-- 定义玩家Trap事件
function tbTestTrap6:OnPlayer()		
	me.NewWorld(414,1596,3217);	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap7	= tbTest:GetTrapClass("to_dingtaoling1")

-- 定义玩家Trap事件
function tbTestTrap7:OnPlayer()
	me.NewWorld(425,1604,3189);
	--[[local task_value = me.GetTask(1022,31)
	if (task_value == 1) then 	
		me.NewWorld(205,1667,3949)	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);
		return;
	else
		return;
	end	]]--
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap8	= tbTest:GetTrapClass("to_dingtaoling2")

-- 定义玩家Trap事件
function tbTestTrap8:OnPlayer()
	me.NewWorld(425,1604,3189);
	--[[local task_value = me.GetTask(1022,31)
	if (task_value == 1) then 	
		me.NewWorld(205,1754,3955)	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);
		return;
	else
		return;
	end	]]--
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap9	= tbTest:GetTrapClass("to_nvwushouling")

-- 定义玩家Trap事件
function tbTestTrap9:OnPlayer()
	me.NewWorld(421,1619,3220);
	--[[local task_value = me.GetTask(1022,32)
	if (task_value == 1) then 	
		me.NewWorld(205,1767,3736)	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);
		return;
	else
		return;
	end	]]--
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap10	= tbTest:GetTrapClass("to_gexialing")

-- 定义玩家Trap事件
function tbTestTrap10:OnPlayer()
	if (me.nSex == 1) then
		me.NewWorld(427,1609,3252)	-- 传送,[地图Id,坐标X,坐标Y]	
		me.SetFightState(1);
	else
    		me.NewWorld(426,1609,3252)	-- 传送,[地图Id,坐标X,坐标Y]
    		me.SetFightState(1);
	end
	--[[local task_value = me.GetTask(1022,33)
	if (task_value == 1) then 	
		if (me.nSex == 1) then
			me.NewWorld(205,1825,3091)	-- 传送,[地图Id,坐标X,坐标Y]	
			me.SetFightState(1);
		else
    		me.NewWorld(205,1823,2978)	-- 传送,[地图Id,坐标X,坐标Y]
    		me.SetFightState(1);
		end
	else
		return;
	end]]--	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap11	= tbTest:GetTrapClass("to_shedong")

-- 定义玩家Trap事件
function tbTestTrap11:OnPlayer()
	me.NewWorld(412,1603,3225);
	--[[local task_value = me.GetTask(1022,31)
	if (task_value == 1) then 	
		me.NewWorld(205,1754,3955)	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);
		return;
	else
		return;
	end	]]--
end;
-- 定义Npc Trap事件
function tbTestTrap:OnNpc()
	
end;

