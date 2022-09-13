-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(106); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 【去青滩石场韩忠--21号】---------------
local tbTestTrap	= tbTest:GetTrapClass("to_hanzhongqiushi")

-- 定义玩家Trap事件
function tbTestTrap:OnPlayer()
		
local task_value = me.GetTask(1024,16)
	if (task_value == 2) then 
		return;	
	elseif (task_value == 1) then 
		me.NewWorld(540,1619,3220)	-- 传送,[地图Id,坐标X,坐标Y]	
        me.SetFightState(0)
		return;
	else
	   return;
	end		
end

-------------- 【去青滩石场钱秉诚房--26号】 ---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_qianbingchengfang")

function tbTestTrap2:OnPlayer()	
	me.NewWorld(541,1610,3217)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;

-------------- 【去青滩石场主管房宋东来--29号】 ---------------
local tbTestTrap3	= tbTest:GetTrapClass("to_zhuguanfang")

function tbTestTrap3:OnPlayer()
	me.NewWorld(542,1605,3190)	-- 传送,[地图Id,坐标X,坐标Y]	
	me.SetFightState(1)
end;
