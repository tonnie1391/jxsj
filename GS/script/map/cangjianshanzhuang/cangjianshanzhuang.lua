-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(477); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap	= tbTest:GetTrapClass("cangjian")

-- 定义玩家Trap事件
function tbTestTrap:OnPlayer()
	me.NewWorld(477,1689,3030);
	TaskAct:Talk("未经此地主人许可，客人不得进入后院。");
end;

-- 定义Npc Trap事件
function tbTestTrap:OnNpc()
	
end;
