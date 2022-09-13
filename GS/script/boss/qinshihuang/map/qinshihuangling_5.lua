-------------------------------------------------------
-- 文件名　：qinshihuangling_5.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-06-09 13:06:16
-- 文件描述：
-------------------------------------------------------

-------------- 定义特定地图回调 ---------------
local tbMap = Map:GetClass(1540);

-- 定义玩家进入事件
function tbMap:OnEnter(szParam)
	
	DataLog:WriteELog(me.szName, 2, 3, me.nMapId);
	
	-- 判断剩余时间
	local nUseTime = me.GetTask(Boss.Qinshihuang.TASK_GROUP_ID, Boss.Qinshihuang.TASK_USE_TIME);
	
	-- 剩余时间为0
	if nUseTime >= Boss.Qinshihuang.MAX_DAILY_TIME or Boss.Qinshihuang:CheckOpenQinFive() ~= 1 then
		me.NewWorld(1538, 1762, 3191);		-- 第三层的安全区
		me.SetFightState(0);
		return;
	end
	
	-- 战斗保护
	Player:AddProtectedState(me, 6);
	
	-- 地图对玩家影响
	Boss.Qinshihuang:AddPlayer(me.nId, 5);
	
	-- 地图对玩家影响
	Boss.Qinshihuang:OnMapEffect(me.nId, 5);
	
	Boss.Qinshihuang:_MapSetState(me);
	
	-- 成就：成功进入秦始皇陵5层
	Achievement_ST:FinishAchievement(me.nId, Achievement_ST.QINSHIHUANG_5);
	
end;

-- 定义玩家离开事件
function tbMap:OnLeave(szParam)
	
	-- 清除地图效果
	Boss.Qinshihuang:OnMapLeave(me.nId, 5);
			
	-- 移出当前地图的列表
	Boss.Qinshihuang:RemovePlayer(me.nId);
	
	if Boss.Qinshihuang:_CheckTime() ~= 1 then
		Boss.Qinshihuang:_MapResetState(me);
	end
	
	DataLog:WriteELog(me.szName, 2, 4, me.nMapId);
end;

-------------- 定义特定Trap点回调 ---------------

-- 返回4层点1
local tbTrap1 = tbMap:GetTrapClass("trap_f4_1");

function tbTrap1:OnPlayer()
	me.SetFightState(1);
	me.NewWorld(1539, 1892, 3856);
end;

-- 返回4层点2
local tbTrap2 = tbMap:GetTrapClass("trap_f4_2");

function tbTrap2:OnPlayer()
	me.SetFightState(1);
	me.NewWorld(1539, 1938, 3799);
end;
