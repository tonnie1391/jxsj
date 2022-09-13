-- 文件名　：lockmis_test.lua
-- 创建者　：zounan
-- 创建时间：2009-12-24 09:56:50
-- 描  述  ：LockMis测试/范例
Require("\\script\\mission\\lockmis_base.lua");

-- 建立一个LockMis类
local tbTest = Mission:NewLock();



--玩家加入LockMis 后调用
function tbTest:OnLockMisJoin(nGroupId)
	print("【LockMis】 BaseClass: OnLockMisJoin", me.szName);
end

--玩家加入LockMis 后调用
function tbTest:OnLockMisLeave(nGroupId, szReason)
	print("【LockMis】 BaseClass: OnLockMisLeave", me.szName);
end

-- 在Mission被关闭“前”被调用 MISSION里面的回调函数
function tbTest:OnClose()
	print("【MISSION】 => OnClose()");
end

--在LockMis被关闭“后”被调用
function tbTest:OnGameClose()
	print("【LockMis】 BaseClass: OnGameClose");
end

--++地图事件接口

function tbTest:OnMapTrap(szClassName)
	print("【LockMis】 BaseClass: OnMapTrap", me.szName, szClassName);
end

-- 开启活动
--参数 nMapId： 与地图绑定
--bMapTrap： 加载TRAP点
function tbTest:StartGameEx(nMapId, bMapTrap)
	nMapId = 1693;
	bMapTrap = 1;
	self:InitGame(nMapId);        -- MISSION与MAP绑定
	-- 设定可选配置项
	self.tbMisCfg	= {
-- 一般不用MISSION里的ENTERPOS和LEAVEPOS
--		tbEnterPos	= {[0] = {1, 1658, 3555}},	-- 进入坐标
		tbLeavePos	= {[0] = {1, 1600, 3200}},	-- 离开坐标
		nDeathPunish   = 1,
		nPkState       = Player.emKPK_STATE_PRACTISE,
--		nOnDeath 	   = 1,        -- 死亡脚本可用
--		nOnKillNpc 	   = 1,        -- NPC死亡函数		
		nFightState	   = 1,
		nForbidStall   = 1,        -- 禁止摆摊
	}
	self.tbLockMisCfg = self:GetLockMisCfg(1);    -- 参数为副本ID 
	--tbLockMisCfg 的格式
	--[[
	self.tbLockMisCfg = {         
		LOCK = {                  -- 锁结构 与逍遥谷大体相同  
			[1] = {nTime = 15, nNum = 0,
				tbPrelock = {},
				tbStartEvent = {         --事件函数在文件末
				{"MovieDialog",-1,"<playername>: 啊，这位兄台，你怎么了？<end>"},	
				{"AddNpc",6130,100,-1,1,4,"heiyiren","heiyiren_2"},
				},

				tbUnLockEvent = 
				{
				},
			},
			[2] = {nTime = 240, nNum = 0,		
				tbPrelock = {1},
				tbStartEvent  = {},
				tbUnLockEvent = {
				{"GameLose", -1},
				},
			},
		},
		tbTrap = {               -- TRAP点
			tbSrcTrap = {        -- 踩的TRAP点
				["trap_1"] = {{1600,3200},{1600,3201},},				
				},
			tbDesTrap = {       -- 踩到TRAP点后的传送点
				["trap_1"] = {1658, 3555},				
				},	
			
		},
		tbNpcPoint = {          -- NPC的出生点
			   ["heiyiren"] = {{1600,3200},{1600,3201},},
		},	
		tbRoad = {          -- NPC AI路线表 TODO 
		},		
	};
	--]]
	self:JoinPlayer(me, MathRandom(2));	-- 加入一个玩家
    -- 参数bMapTrap
    -- 0 : 不加载TRAP点 加载过一次TRAP后就不用加载TRAP点了 
	-- 1 ：第一次初始化的时候加要加载	
	self:StartGame(bMapTrap);      
end

-- 加入活动
function tbTest:JoinGame()
	self:JoinPlayer(me, MathRandom(2));
end

-- 结束活动
function tbTest:EndGame()
	self:CloseGame();
end


-- Mission没有Id，需要找个地方将类保存起来，否则丢了找不回来
GM.testLockMis	= tbTest;

-- GM指令
function GM.testLcStartGame()
	DoScript("\\script\\mission\\lockmis_base.lua");
	DoScript("\\script\\mission\\lockmis_test.lua");
	GM.testLockMis:StartGameEx();
end

function GM.testLcJoinGame()
	GM.testLockMis:JoinGame();
end

function GM.testLcEndGame()
	GM.testLockMis:EndGame();
end

--+++++++++++++
-- 锁结构
-- nTime, nNum, tbPrelock = {, ...}, tbEvent = {}

--++++++++++++

-- EVENT类型
--注:  以下nPlayerGroup均指player加入MISSION时的分组,若相对MISSION内所有玩家执行事件 则将nPlayerGroup 设为 -1 即可 
--    nX, nY 为非32位地图坐标

-- 添加NPC		AddNpc, nTemplateId,nLevel,nSeries, nNum, nLock, szGroup, szPointName, [nTimes, nFrequency, szTimerName]
-- 删除npc		DelNpc, szGroup
-- 更改trap		ChangeTrap, ClassName, nX,nY       --指的是玩家踩到该TRAP点后传送到的坐标(本地图内)
-- 删除trap		DelTrap , ClassName,               --玩家踩到TRAP点后不进行传送而已
-- 给TRAP加锁	AddTrapLock, szClassName, nLock    --玩家踩到TRAP点后若该TRAP点没有传送坐标 则对nLock进行一次解锁操作，解锁后失效即再踩不会继续解锁

-- 传送玩家		NewWorld， nPlayerGroup, nX, nY,[nMapId]    --如果nMapId不存在的话 则默认传送到本地图
-- 设置临时阵	ChangeCamp, nPlayerGroup, nCamp
-- 目标信息 		SetTagetInfo, nPlayerGroup, szInfo		-- 在即时战报中显示信息(nPlayerGroup中的成员)
-- 时间信息		SetTimeInfo, nPlayerGroup, szTimeInfo, nLock	-- 在即时战报中某个锁处的显示倒计时(该锁必须已经开始，否则执行无效)
-- 关闭即时消息 CloseInfo, nPlayerGroup				

-- 电影模式		MovieDialog, nPlayerGroup, szDialog
-- 黑条字模 		BlackMsg, nPlayerGroup, szDialog
-- 聊天栏公告   SendPlayerMsg,nPlayerGroup,szDiaolog

-- 玩家保护     AddProtectedState, nPlayerGroup, nSec          --  给玩家nSec秒的保护时间
-- NPC发话		SendNpcChat, szGroup, szChat
-- NPC血量触发  AddNpcLifePObserver,szGroup, nPercent          -- szGroup中的pNpc血量降低到nPercent时, 解锁。注意 对调用该指令后 新加入szGroup中的NPC无效
-- 对话NPC几率触发    AddDiaologNpcRate, szNpcGroup, nRate     -- 对话NPC有nRate/100w 的概率解锁 如果 nRate为nil 则 100% 解锁 --即对于默认的对话NPC 100%解锁

-- 游戏胜利		GameWin, nPlayerGroup                    -- 此事件执行后 因为MISSION 已经关闭故不能再执行其他事件 
-- 游戏失败		GameLose,nPlayerGroup	                 -- 此事件执行后 因为MISSION 已经关闭故不能再执行其他事件


-- NPC AI   TODO
-- 改变NPC的AI	CHANGE_NPC_AI, szGroup, nAIType, ... 			-- 改变某群组NPC的AI
-- AI类型
-- 移动     AI_MOVE, szRoad, nLockId, [nAttact, bRetort, bArriveDel]		按路线移动到本地图某个区域(具体路线要制定好，否则怪物可能穿越障碍行走)
-- 循环移动 AI_RECYLE_MOVE,	szRoad, [nAttact, bRetort, nTimes]				按路线循环移动
-- 攻击目标 AI_ATTACK, szNpc, nCamp											攻击目标为szNpc，改变NPC阵营