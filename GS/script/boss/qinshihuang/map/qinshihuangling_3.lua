-------------------------------------------------------
-- 文件名　：qinshihuangling_3.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-06-09 13:00:28
-- 文件描述：
-------------------------------------------------------


-------------- 定义特定地图回调 ---------------
local tbMap = Map:GetClass(1538);

-- 定义玩家进入事件
function tbMap:OnEnter(szParam)
	
	DataLog:WriteELog(me.szName, 2, 3, me.nMapId);
	
	-- 判断剩余时间
	local nUseTime = me.GetTask(Boss.Qinshihuang.TASK_GROUP_ID, Boss.Qinshihuang.TASK_USE_TIME);
	
	-- 剩余时间为0
	if nUseTime >= Boss.Qinshihuang.MAX_DAILY_TIME then
		me.NewWorld(1536, 1567, 3629);		-- 第一层的安全区
		me.SetFightState(0);
		return;
	end
	
	-- 战斗保护
	Player:AddProtectedState(me, 6);
	
	-- 加入当前地图的列表
	Boss.Qinshihuang:AddPlayer(me.nId, 3);
	
	-- 地图对玩家影响
	Boss.Qinshihuang:OnMapEffect(me.nId, 3);
	
	if Boss.Qinshihuang:_CheckTime() == 1 then
		Boss.Qinshihuang:_MapSetState(me);
	end
end;

-- 定义玩家离开事件
function tbMap:OnLeave(szParam)
	
	-- 清除地图效果
	Boss.Qinshihuang:OnMapLeave(me.nId, 3);
			
	-- 移出当前地图的列表
	Boss.Qinshihuang:RemovePlayer(me.nId);
	
	DataLog:WriteELog(me.szName, 2, 4, me.nMapId);
end;


-------------- 定义特定Trap点回调 ---------------


-- 进入4层点1
local tbTrap1 = tbMap:GetTrapClass("trap_f4_1");

function tbTrap1:OnPlayer()
	me.SetFightState(1);
	me.NewWorld(1539, 1490, 3592);
end;

-- 进入4层点2
local tbTrap2 = tbMap:GetTrapClass("trap_f4_2");

function tbTrap2:OnPlayer()
	me.SetFightState(1);
	me.NewWorld(1539, 1714, 3373);
end;

-- 返回2层点1
local tbTrap3 = tbMap:GetTrapClass("trap_f2_1");

function tbTrap3:OnPlayer()
	me.SetFightState(1);
	if Boss.Qinshihuang:_CheckTime() == 1 then
		Boss.Qinshihuang:_MapSetState(me);
	end
	me.NewWorld(1537, 1962, 3660);
end;

-- 返回2层点2
local tbTrap4 = tbMap:GetTrapClass("trap_f2_2");

function tbTrap4:OnPlayer()
	me.SetFightState(1);
	if Boss.Qinshihuang:_CheckTime() == 1 then
		Boss.Qinshihuang:_MapSetState(me);
	end
	me.NewWorld(1537, 2166, 3455);
end;

-- 进入安全区1
local tbSafeIn1 = tbMap:GetTrapClass("trap_safe_in");

function tbSafeIn1:OnPlayer()
	me.NewWorld(1538, 1762, 3191);
	me.SetFightState(0);
	Boss.Qinshihuang:_MapResetState(me);
end;

-- 离开安全区1
local tbSafeOut1 = tbMap:GetTrapClass("trap_safe_out");

function tbSafeOut1:OnPlayer()
	me.NewWorld(1538, 1746, 3267);
	me.SetFightState(1);
	Player:AddProtectedState(me, 3);
	if Boss.Qinshihuang:_CheckTime() == 1 then
		Boss.Qinshihuang:_MapSetState(me);
	end
end;
