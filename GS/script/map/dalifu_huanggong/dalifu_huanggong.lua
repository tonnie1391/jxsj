-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(819); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【返回大理府】---------------
local tbTestTrap1	= tbTest:GetTrapClass("to_dalifu")

-- 定义玩家Trap事件
function tbTestTrap1:OnPlayer()	
	   me.NewWorld(28,1767,3302);	-- 传送,[地图Id,坐标X,坐标Y]	
	   me.SetFightState(0);
	
end;

-------------- 【皇宫后花园】---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_houyuan")

-- 定义玩家Trap事件
function tbTestTrap2:OnPlayer()	
	   me.NewWorld(820,1611,3226);	-- 传送,[地图Id,坐标X,坐标Y]	
	   me.SetFightState(0);	
end;
