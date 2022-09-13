-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(113); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【去一等侍卫长---5号】---------------
local tbTestTrap1	= tbTest:GetTrapClass("to_yidengshiweizhang")

-- 定义玩家Trap事件
function tbTestTrap1:OnPlayer()	
	me.NewWorld(221,1602,3318)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;

-------------- 【去石轩辕---21号】---------------
local tbTestTrap5	= tbTest:GetTrapClass("to_shixuanyuan")

-- 定义玩家Trap事件
function tbTestTrap5:OnPlayer()	
	me.NewWorld(221,1580,3847)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;


