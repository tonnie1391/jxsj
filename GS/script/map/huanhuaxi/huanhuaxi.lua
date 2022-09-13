-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(90); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【丹青生】---------------
local tbTestTrap1	= tbTest:GetTrapClass("to_danqingsheng")

-- 定义玩家Trap事件
function tbTestTrap1:OnPlayer()	
	me.NewWorld(510,1605,3189)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;

-------------- 【飞龙谷】 ---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_mayigu")

function tbTestTrap2:OnPlayer()	
	me.NewWorld(511,1579,3224)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(0)	
end;

