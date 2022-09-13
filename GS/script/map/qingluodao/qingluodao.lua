-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest2 = Map:GetClass(2286); -- 地图Id

-- 定义玩家进入事件
function tbTest2:OnEnter(szParam)
	--第一次进入青螺岛，并且上次的重生点是桃溪镇，就改为青螺岛药商处
	local nLastRevMapId = me.GetRevivePos() or 0;
	if nLastRevMapId and GetMapType(nLastRevMapId) == "taoxizhen" then
		me.SetRevivePos(2286, 1);
	end
end;

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(55); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	--第一次进入青螺岛，并且上次的重生点是桃溪镇，就改为青螺岛药商处
	local nLastRevMapId = me.GetRevivePos() or 0;
	if nLastRevMapId and GetMapType(nLastRevMapId) == "taoxizhen" then
		me.SetRevivePos(55, 1);
	end
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap	= tbTest:GetTrapClass("to_zhuyingfang")

-- 定义玩家Trap事件
function tbTestTrap:OnPlayer()	
	me.NewWorld(198,1575,3725)	-- 传送,[地图Id,坐标X,坐标Y]	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_dilao")

function tbTestTrap2:OnPlayer()	
	me.NewWorld(198,1802,3864)	-- 传送,[地图Id,坐标X,坐标Y]
	--[[ local task_value = me.GetTask(1022,1)
	if (task_value == 1) then 
		me.NewWorld(198,1802,3864)	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);
		return;
	else
		return;
	end]]--	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap3	= tbTest:GetTrapClass("to_peiyifei")

function tbTestTrap3:OnPlayer()
	me.NewWorld(403,1603,3219)
	--[[ local task_value = me.GetTask(1022,2)
	if (task_value == 1) then 
		me.NewWorld(198,1578,3941)	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(0);
		return;
	else
		return;
	end	]]--		
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap4	= tbTest:GetTrapClass("to_qiuzhishui")

function tbTestTrap4:OnPlayer()
	me.NewWorld(404,1619,3220)
	--[[local task_value = me.GetTask(1022,3)
	if (task_value == 1) then 
		me.NewWorld(198,1669,3946)	-- 传送,[地图Id,坐标X,坐标Y]	
		me.SetFightState(0);
		return;
	else
		return;
	end	]]--	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap5	= tbTest:GetTrapClass("to_shangrentouling")

function tbTestTrap5:OnPlayer()
	me.NewWorld(198,1886,3851)
	--[[local task_value = me.GetTask(1022,4)
	if (task_value == 1) then 
		me.NewWorld(198,1886,3851)	-- 传送,[地图Id,坐标X,坐标Y]	
		me.SetFightState(1);
		return;
	else
		return;
	end	]]--		
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap6	= tbTest:GetTrapClass("to_shenmixiaojing")

function tbTestTrap6:OnPlayer()
	local task_value = me.GetTask(1022,5)
	if (task_value == 1) then 
		return;
	else
		return;
	end	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap7	= tbTest:GetTrapClass("to_xingying")

function tbTestTrap7:OnPlayer()

end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap8	= tbTest:GetTrapClass("to_xingtianling")

function tbTestTrap8:OnPlayer()
	local task_value = me.GetTask(1022,6)
	if (task_value == 1) then 
		return;
	else
		return;
	end	
end;

-- 定义Npc Trap事件
function tbTestTrap:OnNpc()
	
end;

