-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(215); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【去迦音室外---21号去室外】---------------
local tbTestTrap1	= tbTest:GetTrapClass("to_exit21")

-- 定义玩家Trap事件
function tbTestTrap1:OnPlayer()	
	me.NewWorld(102,1722,3790)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);	
	
	end;
