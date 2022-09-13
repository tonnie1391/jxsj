-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(67); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap	= tbTest:GetTrapClass("to_gongshentai")

-- 定义玩家Trap事件
function tbTestTrap:OnPlayer()
	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_ninglizhou")

-- 定义玩家Trap事件
function tbTestTrap2:OnPlayer()

end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap3	= tbTest:GetTrapClass("to_tianxingdian")

-- 定义玩家Trap事件
function tbTestTrap3:OnPlayer()
	me.NewWorld(452,1527,3126);
	--[[local task_value = me.GetTask(1022,75)
	if (task_value == 1) then 
		me.NewWorld(203,1619,3220)	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(0);	
		return;
	else
		return;
	end	]]--		
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap4	= tbTest:GetTrapClass("to_weichangfeng")

-- 定义玩家Trap事件
function tbTestTrap4:OnPlayer()

end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap5	= tbTest:GetTrapClass("to_wusajusuo")

-- 定义玩家Trap事件
function tbTestTrap5:OnPlayer()
	me.NewWorld(451,1619,3220);
	--[[local task_value = me.GetTask(1022,74)
	if (task_value == 1) then 
		me.NewWorld(203,1577,3849)	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(0);	
		return;
	else
		return;
	end	]]--
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap6	= tbTest:GetTrapClass("to_yelvchou")

-- 定义玩家Trap事件
function tbTestTrap6:OnPlayer()	

end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap7	= tbTest:GetTrapClass("to_zhongchengdian")

-- 定义玩家Trap事件
function tbTestTrap7:OnPlayer()
	me.NewWorld(453,1555,3120)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(0);
	return;
end;

-- 定义Npc Trap事件
function tbTestTrap:OnNpc()
	
end;
