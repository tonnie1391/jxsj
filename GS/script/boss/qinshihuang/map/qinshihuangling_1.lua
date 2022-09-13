-------------------------------------------------------
-- 文件名　：qinshihuangling_1.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-06-09 11:23:12
-- 文件描述：
-------------------------------------------------------


-------------- 定义特定地图回调 ---------------
local tbMap = Map:GetClass(1536);

-- 定义玩家进入事件
function tbMap:OnEnter(szParam)
	
	DataLog:WriteELog(me.szName, 2, 3, me.nMapId);
	
	-- 判断剩余时间
	local nUseTime = me.GetTask(Boss.Qinshihuang.TASK_GROUP_ID, Boss.Qinshihuang.TASK_USE_TIME);
	
	-- 剩余时间为0
	if nUseTime >= Boss.Qinshihuang.MAX_DAILY_TIME then
		me.NewWorld(Boss.Qinshihuang:GetLeaveMapPos());
		me.SetFightState(0);
		return;
	end
	
	-- 战斗保护
	Player:AddProtectedState(me, 6);
	
	-- 加入当前地图的列表
	Boss.Qinshihuang:AddPlayer(me.nId, 1);
	
	-- 地图对玩家影响
	Boss.Qinshihuang:OnMapEffect(me.nId, 1);
end;

-- 定义玩家离开事件
function tbMap:OnLeave(szParam)

	-- 清除地图效果
	Boss.Qinshihuang:OnMapLeave(me.nId, 1);
			
	-- 移出当前地图的列表
	Boss.Qinshihuang:RemovePlayer(me.nId);
	
	DataLog:WriteELog(me.szName, 2, 4, me.nMapId);
end;


-------------- 定义特定Trap点回调 ---------------

-- 进入2层点1
local tbTrap1 = tbMap:GetTrapClass("trap_f2_1");

function tbTrap1:OnPlayer()
	me.SetFightState(1);
	if Boss.Qinshihuang:_CheckTime() == 1 then
		Boss.Qinshihuang:_MapSetState(me);
	end
	me.NewWorld(1537, 1700, 3372);
end;


-- 进入2层点2
local tbTrap2 = tbMap:GetTrapClass("trap_f2_2");

function tbTrap2:OnPlayer()
	me.SetFightState(1);
	if Boss.Qinshihuang:_CheckTime() == 1 then
		Boss.Qinshihuang:_MapSetState(me);
	end
	me.NewWorld(1537, 1893, 3143);
end;

-- 进入安全区1
local tbSafeIn1 = tbMap:GetTrapClass("trap_safe_in_1");

function tbSafeIn1:OnPlayer()
	me.NewWorld(1536, 1567, 3629);
	me.SetFightState(0);
	Boss.Qinshihuang:_MapResetState(me);
end;

-- 进入安全区2
local tbSafeIn2 = tbMap:GetTrapClass("trap_safe_in_2");

function tbSafeIn2:OnPlayer()
	me.NewWorld(1536, 1567, 3629);
	me.SetFightState(0);
	Boss.Qinshihuang:_MapResetState(me);
end;

-- 进入安全区3
local tbSafeIn3 = tbMap:GetTrapClass("trap_safe_in_3");

function tbSafeIn3:OnPlayer()
	me.NewWorld(1536, 1567, 3629);
	me.SetFightState(0);
	Boss.Qinshihuang:_MapResetState(me);
end;

-- 离开安全区1
local tbSafeOut1 = tbMap:GetTrapClass("trap_safe_out_1");

function tbSafeOut1:OnPlayer()
	local nTime = GetTime() - me.GetTask(Boss.Qinshihuang.TASK_GROUP_ID, Boss.Qinshihuang.TASK_REVTIME);
	if nTime < 10 then
		Dialog:SendBlackBoardMsg(me, string.format("Đừng nóng vội, hãy chờ %s giây nữa để tiếp tục chiến đấu.", 10 - nTime));
		return 0;
	end
	me.NewWorld(1536, 1534, 3662);
	me.SetFightState(1);
	Player:AddProtectedState(me, 3);
	if Boss.Qinshihuang:_CheckTime() == 1 then
		Boss.Qinshihuang:_MapSetState(me);
	end
end;

-- 离开安全区2
local tbSafeOut2 = tbMap:GetTrapClass("trap_safe_out_2");

function tbSafeOut2:OnPlayer()
	local nTime = GetTime() - me.GetTask(Boss.Qinshihuang.TASK_GROUP_ID, Boss.Qinshihuang.TASK_REVTIME);
	if nTime < 10 then
		Dialog:SendBlackBoardMsg(me, string.format("Đừng nóng vội, hãy chờ %s giây nữa để tiếp tục chiến đấu.", 10 - nTime));
		return 0;
	end
	me.NewWorld(1536, 1600, 3675);
	me.SetFightState(1);
	Player:AddProtectedState(me, 3);
	if Boss.Qinshihuang:_CheckTime() == 1 then
		Boss.Qinshihuang:_MapSetState(me);
	end
end;

-- 离开安全区3
local tbSafeOut3 = tbMap:GetTrapClass("trap_safe_out_3");

function tbSafeOut3:OnPlayer()
	local nTime = GetTime() - me.GetTask(Boss.Qinshihuang.TASK_GROUP_ID, Boss.Qinshihuang.TASK_REVTIME);
	if nTime < 10 then
		Dialog:SendBlackBoardMsg(me, string.format("Đừng nóng vội, hãy chờ %s giây nữa để tiếp tục chiến đấu.", 10 - nTime));
		return 0;
	end
	me.NewWorld(1536, 1600, 3600);
	me.SetFightState(1);
	Player:AddProtectedState(me, 3);
	if Boss.Qinshihuang:_CheckTime() == 1 then
		Boss.Qinshihuang:_MapSetState(me);
	end
end;
