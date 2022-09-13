-------------------------------------------------------
-- 文件名　：qinshihuangling_2.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-06-09 12:47:18
-- 文件描述：
-------------------------------------------------------


-------------- 定义特定地图回调 ---------------
local tbMap = Map:GetClass(1537);

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
	Boss.Qinshihuang:AddPlayer(me.nId, 2);
	
	-- 地图对玩家影响
	Boss.Qinshihuang:OnMapEffect(me.nId, 2);
	
	if Boss.Qinshihuang:_CheckTime() == 1 then
		Boss.Qinshihuang:_MapSetState(me);
	end
end;

-- 定义玩家离开事件
function tbMap:OnLeave(szParam)
	
	-- 清除地图效果
	Boss.Qinshihuang:OnMapLeave(me.nId, 2);
			
	-- 移出当前地图的列表
	Boss.Qinshihuang:RemovePlayer(me.nId);
	
	DataLog:WriteELog(me.szName, 2, 4, me.nMapId);
end;


-------------- 定义特定Trap点回调 ---------------

-- 进入3层点1
local tbTrap1 = tbMap:GetTrapClass("trap_f3_1");

function tbTrap1:OnPlayer()
	me.SetFightState(1);
	if Boss.Qinshihuang:_CheckTime() == 1 then
		Boss.Qinshihuang:_MapSetState(me);
	end
	me.NewWorld(1538, 1469, 3245);
end;

-- 进入3层点2
local tbTrap2 = tbMap:GetTrapClass("trap_f3_2");

function tbTrap2:OnPlayer()
	me.SetFightState(1);
	if Boss.Qinshihuang:_CheckTime() == 1 then
		Boss.Qinshihuang:_MapSetState(me);
	end
	me.NewWorld(1538, 1549, 3170);
end;

-- 返回1层点1
local tbTrap3 = tbMap:GetTrapClass("trap_f1_1");

function tbTrap3:OnPlayer()
	me.SetFightState(1);
	if Boss.Qinshihuang:_CheckTime() == 1 then
		Boss.Qinshihuang:_MapSetState(me);
	end
	me.NewWorld(1536, 1768, 4012);
end;

-- 返回1层点2
local tbTrap4 = tbMap:GetTrapClass("trap_f1_2");

function tbTrap4:OnPlayer()
	me.SetFightState(1);
	if Boss.Qinshihuang:_CheckTime() == 1 then
		Boss.Qinshihuang:_MapSetState(me);
	end
	me.NewWorld(1536, 1928, 3847);
end;
