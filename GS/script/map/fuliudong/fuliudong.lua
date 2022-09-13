-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(129); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【落女洞】---------------
local tbTestTrap	= tbTest:GetTrapClass("to_luonvdong")

-- 定义玩家Trap事件
function tbTestTrap:OnPlayer()	
	me.NewWorld(814,1603,3224)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)	
end;
