-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(211); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【离开李元霸房】---------------
local tbTestTrap1	= tbTest:GetTrapClass("to_exit7")

-- 定义玩家Trap事件
function tbTestTrap1:OnPlayer()	
	me.NewWorld(95,1850,3377)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;

-------------- 【离开佛堂】 ---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_exit6")

function tbTestTrap2:OnPlayer()	
	me.NewWorld(95,1818,3824)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;
