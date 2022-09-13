-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(488); -- 地图Id

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

-------------- 【神父密室---1】---------------
local tbTestTrap1	= tbTest:GetTrapClass("to_mishi")

-- 定义玩家Trap事件
function tbTestTrap1:OnPlayer()	
	local task_value = me.GetTask(1022,140)
	if (task_value == 1) then 	
		me.NewWorld(489,1611,3216)	-- 传送,[地图Id,坐标X,坐标Y]	
		me.SetFightState(0)
		return;
	end
end;
