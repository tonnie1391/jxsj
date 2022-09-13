-- Map 的例子加测试
-- 欢迎删除！

-------------- 定义特定地图回调 ---------------
local tbTest = Map:GetClass(60); -- 地图Id

-- 定义玩家进入事件
function tbTest:OnEnter(szParam)
	
end;

-- 定义玩家离开事件
function tbTest:OnLeave(szParam)
	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap	= tbTest:GetTrapClass("to_baishan1")

-- 定义玩家Trap事件
function tbTestTrap:OnPlayer()
	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap2	= tbTest:GetTrapClass("to_baishan2")

-- 定义玩家Trap事件
function tbTestTrap2:OnPlayer()

end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap3	= tbTest:GetTrapClass("to_cangyunxuan")

-- 定义玩家Trap事件
function tbTestTrap3:OnPlayer()
	me.NewWorld(410,1606,3209);
	--[[local task_value = me.GetTask(1022,16)
	if (task_value == 1) then 	
		me.NewWorld(200,1580,3847)	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(0);
		return;
	else
		TaskAct:Talk("藏云轩藏龙卧虎，非请勿进。");
		return;
	end	]]--		
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap4	= tbTest:GetTrapClass("to_dishuidong")

-- 定义玩家Trap事件
function tbTestTrap4:OnPlayer()
	me.NewWorld(409,1609,3455);
	--[[local task_value = me.GetTask(1022,17)
	if (task_value == 1) then 	
		me.NewWorld(200,1809,3449)	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);
		return;
	else
		TaskAct:Talk("神秘的洞口，还是不要进去为好。");
		return;
	end	]]--
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap5	= tbTest:GetTrapClass("to_fengyan")

-- 定义玩家Trap事件
function tbTestTrap5:OnPlayer()

end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap6	= tbTest:GetTrapClass("to_houdao")

-- 定义玩家Trap事件
function tbTestTrap6:OnPlayer()	
	me.NewWorld(408,1609,3455);
	--[[local task_value = me.GetTask(1022,18)
	if (task_value == 1) then 	
		me.NewWorld(200,1698,3453)	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);
		return;
	else
		TaskAct:Talk("神秘的洞口，还是不要进去为好。");
		return;
	end	]]--
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap7	= tbTest:GetTrapClass("to_huweipo")

-- 定义玩家Trap事件
function tbTestTrap7:OnPlayer()
	--[[local task_value = me.GetTask(1022,14)
	if (task_value == 1) then 	
		return;
	else
		TaskAct:Talk("这里是丐帮白山石场，无特殊事情不得入内。");
		me.NewWorld(60,1448,2801)	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);
		return;
	end	]]--
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap8	= tbTest:GetTrapClass("to_liugui")

-- 定义玩家Trap事件
function tbTestTrap8:OnPlayer()
	me.NewWorld(411,1605,3190);
	--[[local task_value = me.GetTask(1022,19)
	if (task_value == 1) then 	
		me.NewWorld(200,1729,3858)	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(0);
		return;
	else
		TaskAct:Talk("长江别院，非请勿进");
		return;
	end	]]--
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap9	= tbTest:GetTrapClass("to_menghuxiang1")

-- 定义玩家Trap事件
function tbTestTrap9:OnPlayer()
	me.NewWorld(407,1560,3257);
	--[[local task_value = me.GetTask(1022,15)
	if (task_value == 1) then 	
		me.NewWorld(407,1585,3456)	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);
		return;
	else
		TaskAct:Talk("猛虎巷凶险，不到万不得已还是不去为好");
		return;
	end	]]--
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap10	= tbTest:GetTrapClass("to_tingtaoge")

-- 定义玩家Trap事件
function tbTestTrap10:OnPlayer()
	local task_value = me.GetTask(1022,20)
	if (task_value == 1) then 	
		return;
	else
		TaskAct:Talk("此地为丐帮接待贵宾处所，外来人等不得入内。");
		me.NewWorld(60,1473,3131)	-- 传送,[地图Id,坐标X,坐标Y]
		return;
	end	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap11	= tbTest:GetTrapClass("to_waizhong")
	
-- 定义玩家Trap事件
function tbTestTrap11:OnPlayer()
	me.NewWorld(405,1589,3205);
	me.SetFightState(1);
	--[[local task_value = me.GetTask(1022,21)
	if (task_value == 1) then 	
		me.NewWorld(200,1602,3318)	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(0);
		return;
	else
		TaskAct:Talk("祭奠礼期间，进入外英雄冢请到执法弟子处登记。");
		return;
	end	]]--	
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap12	= tbTest:GetTrapClass("to_xiaojing")

-- 定义玩家Trap事件
function tbTestTrap12:OnPlayer()

end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap13	= tbTest:GetTrapClass("to_yingsunjiao")

-- 定义玩家Trap事件
function tbTestTrap13:OnPlayer()
	me.NewWorld(406,1638,3064);
	--[[local task_value = me.GetTask(1022,22)
	if (task_value == 1) then 	
		me.NewWorld(200,1722,3306)	-- 传送,[地图Id,坐标X,坐标Y]
		me.SetFightState(1);
		return;
	else
		return;
	end	]]--
end;

-------------- 定义特定Trap点回调 ---------------
local tbTestTrap13	= tbTest:GetTrapClass("to_jingyueyan")

-- 定义玩家Trap事件
function tbTestTrap13:OnPlayer()
	me.NewWorld(200,1889,3448)	-- 传送,[地图Id,坐标X,坐标Y]	
end;

-- 定义Npc Trap事件
function tbTestTrap:OnNpc()
	
end;
