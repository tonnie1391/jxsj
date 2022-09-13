-- 文件名　：test.lua
-- 创建者　：FanZai
-- 创建时间：2007-10-11 09:46:18
-- 文件说明：Mission测试/范例


-- 建立一个Mission类
local tbTest = Mission:New();

-- 当Mission被开启“后”被调用
function tbTest:OnOpen()
	print("TestMission => OnOpen()");
end;

-- 在Mission被关闭“前”被调用
function tbTest:OnClose()
	print("TestMission => OnClose()");
end;

-- 当玩家加入Mission“后”被调用
function tbTest:OnJoin(nGroupId)
	print("TestMission => OnJoin("..me.szName..","..nGroupId..")");
end;

-- 当玩家离开Mission“前”被调用
function tbTest:BeforeLeave(nGroupId, szReason)
	print("TestMission => BeforeLeave("..me.szName..","..nGroupId..","..szReason..")");
end

-- 当玩家离开Mission“后”被调用
function tbTest:OnLeave(nGroupId, szReason)
	print("TestMission => OnLeave("..me.szName..","..nGroupId..","..szReason..")");
end;

-- 开启活动
function tbTest:StartGame()
	-- 设定可选配置项
	self.tbMisCfg	= {
		tbEnterPos	= {[0] = {1, 1658, 3555}},	-- 进入坐标
		tbLeavePos	= {[0] = {1, 1764, 3554}},	-- 离开坐标
		nFightState	= 1,						-- 战斗状态
		tbCamp		= {[1] = 1, [2] = 3},		-- 分别设定阵营
		nForbidTeam	= 1,
	}
	
	self.tbMisEventList	= {
		{"StartEvent", Env.GAME_FPS * 60, ""},
	};
	
	self:Open();		-- 开启Mission
	
	self:JoinPlayer(me, MathRandom(2));	-- 加入一个玩家
	
	self:BroadcastMsg("Mission Opened!!!", "test");	-- 广播消息
	
	self:ForEachCall("Dialog:Say", "Hello world！");	-- 为每个玩家执行
	
	self.tbTimer	= self:CreateTimer(36, self.OnTimer, self);
end

-- 加入活动
function tbTest:JoinGame()
	self:JoinPlayer(me, MathRandom(2));
end

-- 结束活动
function tbTest:EndGame()
	self:Close();
end

-- 输出信息
function tbTest:PrintGame()
	self:BroadcastMsg(tostring(self.tbTimer:GetRestTime()));
end

-- 定时触发
function tbTest:OnTimer()
	self:BroadcastMsg("Active");
	--self:ForEachCall(self.OnActive, self);
end

function tbTest:OnActive()
	self:ChangePlayerGroup(me, MathRandom(2));
end

-- Mission没有Id，需要找个地方将类保存起来，否则丢了找不回来
GM.testMession	= tbTest;

-- GM指令
function GM.testStartGame()
	DoScript("\\script\\mission\\mission.lua");
	DoScript("\\script\\mission\\test.lua");
	GM.testMession:StartGame();
end

function GM.testJoinGame()
	GM.testMession:JoinGame();
end

function GM.testEndGame()
	GM.testMession:EndGame();
end

function GM.testPrint()
	GM.testMession:PrintGame();
end

