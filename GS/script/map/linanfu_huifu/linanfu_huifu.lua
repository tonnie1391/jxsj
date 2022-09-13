-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(486); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【朱熹府邸---1】---------------
local tbTestTrap	= tbTest:GetTrapClass("to_zhuxifu")

-- 定义玩家Trap事件
function tbTestTrap:OnPlayer()	
	me.NewWorld(487,1554,3119)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0)
end;

-------------- 【赵汝愚府邸---1】---------------
local tbTestTrap1	= tbTest:GetTrapClass("to_zhaoruyu")

-- 定义玩家Trap事件
function tbTestTrap1:OnPlayer()	
	me.NewWorld(485,1555,3119)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(0)
end;

-------------- 【范围保护---2】---------------
local tbTestTrap2	= tbTest:GetTrapClass("huifu1trap")

-- 定义玩家Trap事件
function tbTestTrap2:OnPlayer()	
	me.NewWorld(486,1616,3829)	-- 传送,[地图Id,坐标X,坐标Y]
	TaskAct:Talk("现在不是闲逛的时候，还是先去办正事吧。");	
	me.SetFightState(1)
end;

-------------- 【范围保护---3】---------------
local tbTestTrap3	= tbTest:GetTrapClass("huifu2trap")

-- 定义玩家Trap事件
function tbTestTrap3:OnPlayer()	
	me.NewWorld(486,1577,3875)	-- 传送,[地图Id,坐标X,坐标Y]	
	TaskAct:Talk("现在不是闲逛的时候，还是先去办正事吧。");	
	me.SetFightState(1)
end;

-------------- 【范围保护---4】---------------
local tbTestTrap4	= tbTest:GetTrapClass("huifu3trap")

-- 定义玩家Trap事件
function tbTestTrap4:OnPlayer()	
	me.NewWorld(486,1527,3824)	-- 传送,[地图Id,坐标X,坐标Y]	
	TaskAct:Talk("现在不是闲逛的时候，还是先去办正事吧。");	
	me.SetFightState(1)
end;

-------------- 【范围保护---5】---------------
local tbTestTrap5	= tbTest:GetTrapClass("huifu4trap")

-- 定义玩家Trap事件
function tbTestTrap5:OnPlayer()	
	me.NewWorld(486,1509,3940)	-- 传送,[地图Id,坐标X,坐标Y]	
	TaskAct:Talk("现在不是闲逛的时候，还是先去办正事吧。");	
	me.SetFightState(1)
end;

-------------- 【范围保护---6】---------------
local tbTestTrap6	= tbTest:GetTrapClass("huifu5trap")

-- 定义玩家Trap事件
function tbTestTrap6:OnPlayer()	
	me.NewWorld(486,1526,3964)	-- 传送,[地图Id,坐标X,坐标Y]	
	TaskAct:Talk("现在不是闲逛的时候，还是先去办正事吧。");	
	me.SetFightState(1)
end;