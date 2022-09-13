-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(66); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap	= tbTest:GetTrapClass("to_chuzuan")

-- 定义玩家Trap事件
function tbTestTrap:OnPlayer()
	me.NewWorld(446,1637,3245);	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(0);	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_huifengjiao")

-- 定义玩家Trap事件
function tbTestTrap2:OnPlayer()
	local task_value = me.GetTask(1022,69)
	if (task_value == 1) then 	
		me.NewWorld(448,1632,3240);	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(0);
		return;
	elseif (task_value == 2) then 
		me.NewWorld(449,1632,3240);	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(0);
		return;
	else
		me.NewWorld(448,1632,3240);
		return;
	end	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap3	= tbTest:GetTrapClass("to_jingangling")

-- 定义玩家Trap事件
function tbTestTrap3:OnPlayer()
	local task_value = me.GetTask(1022,70)
	if (task_value == 1) then 	
		me.NewWorld(444,1622,3562);	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);
		return;
	elseif (task_value == 2) then 
		me.NewWorld(445,1622,3562);	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(0);
		return;
	else
		return;
	end	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap4	= tbTest:GetTrapClass("to_pomiao")

-- 定义玩家Trap事件
function tbTestTrap4:OnPlayer()

end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap5	= tbTest:GetTrapClass("to_qianfoxiagu1")

-- 定义玩家Trap事件
function tbTestTrap5:OnPlayer()

end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap6	= tbTest:GetTrapClass("to_qianfoxiagu2")

-- 定义玩家Trap事件
function tbTestTrap6:OnPlayer()	
	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap5	= tbTest:GetTrapClass("to_qianfoxiagu3")

-- 定义玩家Trap事件
function tbTestTrap5:OnPlayer()

end;

-- 定义Npc Trap事件
function tbTestTrap:OnNpc()
	
end;

