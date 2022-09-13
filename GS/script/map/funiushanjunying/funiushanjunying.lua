--伏牛山军营
--90级以上允许摆摊

-------------- 定义特定地图回调 ---------------
local tbMap = Map:GetClass(556); -- 地图Id

-- 定义玩家进入事件
function tbMap:OnEnter()
	if me.nLevel < 90 then
		me.DisabledStall(1);
	end
end;

-- 定义玩家离开事件
function tbMap:OnLeave()
	me.DisabledStall(0);
end;

local tbMap2 = Map:GetClass(558); -- 地图Id

-- 定义玩家进入事件
function tbMap2:OnEnter()
	if me.nLevel < 90 then
		me.DisabledStall(1);
	end
end;

-- 定义玩家离开事件
function tbMap2:OnLeave()
	me.DisabledStall(0);
end;

local tbMap3 = Map:GetClass(559); -- 地图Id

-- 定义玩家进入事件
function tbMap3:OnEnter()
	if me.nLevel < 90 then
		me.DisabledStall(1);
	end
end;

-- 定义玩家离开事件
function tbMap3:OnLeave()
	me.DisabledStall(0);
end;
