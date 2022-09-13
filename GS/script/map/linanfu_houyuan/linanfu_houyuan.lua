-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(484); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【彭龟年府邸---1】---------------
local tbTestTrap	= tbTest:GetTrapClass("to_pengfu")

-- 定义玩家Trap事件
function tbTestTrap:OnPlayer()	
	me.NewWorld(483,1527,3126)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0)
end;

-------------- 【范围保护---2】---------------
local tbTestTrap2	= tbTest:GetTrapClass("trappeng1")

-- 定义玩家Trap事件
function tbTestTrap2:OnPlayer()	
	me.NewWorld(484,1767,3926)	-- 传送,[地图Id,坐标X,坐标Y]
	TaskAct:Talk("现在不是闲逛的时候，还是先去办正事吧。");	
	me.SetFightState(1)
end;

-------------- 【范围保护---3】---------------
local tbTestTrap3	= tbTest:GetTrapClass("trappeng3")

-- 定义玩家Trap事件
function tbTestTrap3:OnPlayer()	
	me.NewWorld(484,1727,3031)	-- 传送,[地图Id,坐标X,坐标Y]	
	TaskAct:Talk("现在不是闲逛的时候，还是先去办正事吧。");	
	me.SetFightState(1)
end;

-------------- 【范围保护---4】---------------
local tbTestTrap4	= tbTest:GetTrapClass("trappeng4")

-- 定义玩家Trap事件
function tbTestTrap4:OnPlayer()	
	me.NewWorld(483,1700,4103)	-- 传送,[地图Id,坐标X,坐标Y]	
	TaskAct:Talk("现在不是闲逛的时候，还是先去办正事吧。");	
	me.SetFightState(1)
end;