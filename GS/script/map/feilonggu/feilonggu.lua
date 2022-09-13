-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(511); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;



-------------- 【离开飞龙谷】 ---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_exit511")

function tbTestTrap2:OnPlayer()	
	me.NewWorld(90,1902,3160)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;

-------------- 【前往飞龙阵512】 ---------------
local tbTestTrap3	= tbTest:GetTrapClass("to_feilongzhen")

function tbTestTrap3:OnPlayer()

	me.NewWorld(512,1610,3215)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1)	
	
end;
	
