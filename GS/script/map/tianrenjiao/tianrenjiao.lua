--天忍教

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(10); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;


tbTest:GetTrapClass("to_bingqipu").OnPlayer	= function (self)
	me.NewWorld(147,1605,3230)	-- 传送,[地图Id,坐标X,坐标Y]	
end;

tbTest:GetTrapClass("to_fangjupu").OnPlayer	= function (self)
	me.NewWorld(147,1728,3235)	-- 传送,[地图Id,坐标X,坐标Y]	
end;

tbTest:GetTrapClass("to_yaodian").OnPlayer	= function (self)
	me.NewWorld(147,1842,3230)	-- 传送,[地图Id,坐标X,坐标Y]	
end;

tbTest:GetTrapClass("to_zahuodian").OnPlayer	= function (self)
	me.NewWorld(147,1948,3229)	-- 传送,[地图Id,坐标X,坐标Y]	
end;

-- 定义Npc Trap事件
tbTest:GetTrapClass("digong_yunzhongzhen").OnNpc	= function (self)
	him.AI_ClearPath();
	him.AI_AddMovePos(51424, 109664);
	him.SetNpcAI(9, 0, 1,-1, 0, 0, 0, 0, 0, 0, 0);
end;

tbTest:GetTrapClass("digong_bianjingfu").OnNpc	= function (self)
	him.AI_ClearPath();
	him.AI_AddMovePos(52608, 111776);
	him.SetNpcAI(9, 0, 1,-1, 0, 0, 0, 0, 0, 0, 0);
end;

tbTest:GetTrapClass("digong_tianrenjiaojindi").OnNpc	= function (self)
	him.AI_ClearPath();
	him.AI_AddMovePos(56000, 104832);
	him.SetNpcAI(9, 0, 1,-1, 0, 0, 0, 0, 0, 0, 0);
end;

tbTest:GetTrapClass("digong_liangshanpo").OnNpc	= function (self)
	him.AI_ClearPath();
	him.AI_AddMovePos(58112, 118752);
	him.SetNpcAI(9, 0, 1,-1, 0, 0, 0, 0, 0, 0, 0);	
end;
