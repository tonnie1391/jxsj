-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(108); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【去太后銮驾---26号】---------------
local tbTestTrap1	= tbTest:GetTrapClass("to_taihouluanjia")

-- 定义玩家Trap事件
function tbTestTrap1:OnPlayer()	
	me.NewWorld(219,1578,3941)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(0);
	
end;


-------------- 【去中央密室---20号】---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_zhongyangmishi")

-- 定义玩家Trap事件
function tbTestTrap2:OnPlayer()	
 
	me.NewWorld(219,1867,3737)	-- 传送,[地图Id,坐标X,坐标Y]
	me.SetFightState(1);
	
end;


-------------- 【去尸芋花---29号】---------------
local tbTestTrap3	= tbTest:GetTrapClass("to_shiyuhua")

-- 定义玩家Trap事件
function tbTestTrap3:OnPlayer()	
	me.NewWorld(219,1861,3954)	-- 传送,[地图Id,坐标X,坐标Y]	
end;

