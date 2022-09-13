-- Map 的例子加测试
-- 欢迎删除！

local tbTest = Map:GetClass(835);

-------------- 定义特定地图回调 ---------------
-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	print("EnterTestMap:", me.szName);
	me.Msg("EnterTestMap");
	self:CallParam(szParam, 1);	-- 通用开关
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	print("LeaveTestMap:", me.szName);
	me.Msg("LeaveTestMap");
	self:CallParam(szParam, 0);	-- 通用开关
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap	= tbTest:GetTrapClass("fighttrap1")

-- 定义玩家Trap事件
function tbTestTrap:OnPlayer()
	print("OnPlayerTestTrap:", me.szName, me.GetMapId(), self.szName);
	me.Msg("OnPlayerTestTrap:"..self.szName);
end;

-- 定义Npc Trap事件
function tbTestTrap:OnNpc()
	print("OnNpcTestTrap:", him.szName, me.GetMapId(), self.szName);
end;

