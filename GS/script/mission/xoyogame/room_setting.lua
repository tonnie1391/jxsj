--- 房间设置

Require("\\script\\mission\\xoyogame\\room_base.lua");
Require("\\script\\player\\define.lua");
Require("\\script\\mission\\xoyogame\\hellxoyo\\baicaoyuan.lua")
Require("\\script\\mission\\xoyogame\\hellxoyo\\xuehaiwuya.lua")
Require("\\script\\mission\\xoyogame\\hellxoyo\\yinhuapopo.lua")
Require("\\script\\mission\\xoyogame\\hellxoyo\\roomLv7.lua")

XoyoGame.RoomSetting = {};
local BaseRoom = XoyoGame.BaseRoom
local RoomSetting = XoyoGame.RoomSetting;

RoomSetting.tbRoom = {};
local tbRoom = RoomSetting.tbRoom;

-- 全拷贝table，注意不能出现table环链~否则会死循环
local function CopyTable(tbSourTable, tbDisTable)
	if not tbSourTable or not tbDisTable then
		return 0;
	end
	for varField, varData in pairs(tbSourTable) do
		if type(varData) == "table" then
			tbDisTable[varField] = {}
			CopyTable(varData, tbDisTable[varField]);
		else
			tbDisTable[varField] = varData;
		end
	end
end

-- 触发条件格式
-- {nLockId, nLockState}	锁ID，锁状态

-- AI类型,定义在xoyogame_def.lua 下要保持一致
-- 移动 	AI_MOVE, szRoad, nLockId, [nAttact, bRetort, bArriveDel]		按路线移动到本地图某个区域(具体路线要制定好，否则怪物可能穿越障碍行走)
-- 循环移动 AI_RECYLE_MOVE,	szRoad, [nAttact, bRetort, nTimes]				按路线循环移动
-- 攻击目标 AI_ATTACK, szNpc, nCamp											攻击目标为szNpc，改变NPC阵营

-- EVENT类型
-- 添加NPC		ADD_NPC, nIndex, nNum, nLock, szGroup, szPointName, [nTimes, nFrequency, szTimerName]
-- 删除npc		DEL_NPC, szGroup
-- 更改trap 	CHANGE_TRAP, ClassName, tbPoint
-- 执行脚本		DO_SCRIPT, szCmd
-- 更改战斗状态 CHANGE_FIGHT, nPlayerGroup, nFightState, nPkModel, [nCamp]	-- 房间内全体玩家
-- 目标信息 	TARGET_INFO, nPlayerGroup, szInfo							-- 在即时战报中显示信息(房间内全体成员)
-- 时间信息 	TIME_INFO, nPlayerGroup, szTimeInfo, nLock					-- 在即时战报中某个锁处的显示倒计时(改锁必须已经开始，否则执行无效)
-- 关闭即时消息 CLOSE_INFO, nPlayerGroup									-- 
-- 传送玩家		NEW_WORLD_PLAYER, nPlayerGroup, nX, nY						-- 
-- 改变NPC的AI	CHANGE_NPC_AI, szGroup, nAIType, ... 			-- 改变某群组NPC的AI
-- 电影模式		MOVIE_DIALOG, nPlayerGroup, szDialog
-- 黑条字模 	BLACK_MSG, nPlayerGroup, szDialog
-- 增加篝火		ADD_GOUHUO, nMinute, nBaseMultip, szGroup, szPointName		-- nMinute 时间（分钟）, nBaseMultip 经验倍数，第一个队伍有效
-- NPC发话		SEND_CHAT, szGroup, szChat
-- 给玩家加称号 ADD_TITLE， nPlayerGroup, nGenre, nDetail, nLevel, nParam
-- 删除地图npc，DEL_MAP_NPC,只针对6,7,8难度的关卡地图, DEL_MAP_NPC,无参数
-- npc释放技能, NPC_CAST_SKILL,szGroup,nSkillId,nLevel,nX,nY,bBroadcast（npc组名，技能id，技能等级，释放坐标x，y，是否广播）
-- npc血量注册回调(一定要放在ADD_NPC之后)，NPC_BLOOD_PERCENT,szGroup,{nPercent1,EventType1,arg},{nPercent2,EventType2,arg},npc组名，nPercent到多少血量回调，EventType要回调的事件类型，arg要回调的事件的参数
-- npc移除技能状态，NPC_BLOOD_PERCENT,szGroup,nSkillId,npc组名，技能id
-- 玩家设置技能使用状态，PLAYER_SET_FORBID_SKILL,nPlayerGroup,nSkillId,bUse,玩家组，技能id，bUse:禁用还是可用(1禁用，0可用)
-- 房间内所有玩家加一个状态，PLAYER_ADD_EFFECT ,nPlayerGroup,nSkillId,nLevel,bBroadCast,玩家组，技能id,技能等级,是否广播
-- 房间内所有玩家移除一个状态，PLAYER_REMOVE_EFFECT,,nPlayerGroup,nSkillId,玩家组，技能id
-- npc移除一个技能状态，NPC_REMOVE_SKILL,szGroup,nSkillId,组名，技能id
-- npc向玩家释放技能,NPC_CAST_SKILL_TO_PLAYER,szGroup,nSkillId,nLevel,bBroadcast,nRange,nRandomCount,
-- npc组名，技能id，技能等级，是否广播，,nRange为nil或者-1则向房间内所有玩家释放，否则向nRange范围内的玩家释放，
-- nRandomCount,如果不存在，则是向全体释放，如果为0，不进行任何操作，大于1，则随机选择nRandomCount个玩家进行释放
-- 按百分比设置npc血量，NPC_SET_LIFE,szGroup,nPercent,npc组名，血量百分比
-- 给npc添加技能，用于npc ai，ADD_NPC_SKILL,szGroup,nSkillId1,nLevel1,nSkillId2,nLevel2,nSkillId3,nLevel3
-- 锁结构
-- nTime, nNum, tbPrelock = {, ...}, tbEvent = {}
-- 

-- 等级1房间

-- 1,6 房间锁结构完全一致~先写模板再复制
tbRoom[1] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 1,						-- 房间等级(1~5)
	nMapIndex		= 1,						-- 地图组的索引,若对应的索引地图是个table，则应写成{nIndex,nMapIndex}
	tbBeginPoint	= {41952 / 32, 80064 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3139, nLevel = -1, nSeries = -1},		-- 野狼1
		[2] = {nTemplate = 3140, nLevel = -1, nSeries = -1},		-- 野狼2
		[3] = {nTemplate = 3141, nLevel = -1, nSeries = -1},		-- 野狼3
		[4] = {nTemplate = 3218, nLevel = -1, nSeries =	-1},		-- 狼王
		
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.MOVIE_DIALOG, -1, "此处似乎是一个被废弃的农舍，周围的林子里也静的出奇，还是小心行动为妙……"},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 240, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "不知从哪冒出这么多猛兽！先把它们清理掉再说吧。"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "没想到这些野兽竟如此凶悍，看来我们只能换条路再想办法前进了……"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 0, nNum = 32,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 2, 3, "guaiwu", "1_yelang_1"},		-- 刷怪
				{XoyoGame.ADD_NPC, 2, 2, 3, "guaiwu", "1_yelang_2"},		-- 刷怪
				{XoyoGame.ADD_NPC, 3, 28, 3, "guaiwu", "1_yelang_3"},		-- 刷怪
				{XoyoGame.TARGET_INFO, -1, "Tiêu diệt 32 Sói Hoang"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				
			},
			tbUnLockEvent = 
			{
			},
		},
		[4] = {nTime = 0, nNum = 1,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 4, 1, 4, "guaiwu", "1_langwang"},		-- 王
				{XoyoGame.MOVIE_DIALOG, -1, "前面山顶传来一声长啸，看来有更凶猛的野兽在等着我们了……"},
				{XoyoGame.TARGET_INFO, -1, "Tiêu diệt Sói chúa"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.MOVIE_DIALOG, -1, "成功的干掉了这些凶猛的野兽，坐下来烤烤火，休息一下，等待下一个挑战吧。"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "1_gouhuo"},
			},
		},
	}
}

tbRoom[2] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 1,						-- 房间等级(1~5)
	nMapIndex		= 1,						-- 地图组的索引
	tbBeginPoint	= {48032 / 32, 85024 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3142, nLevel = -1, nSeries = -1},		-- 黑熊1
		[2] = {nTemplate = 3143, nLevel = -1, nSeries = -1},		-- 黑熊2
		[3] = {nTemplate = 3144, nLevel = -1, nSeries = -1},		-- 黑熊3
		[4] = {nTemplate = 3219, nLevel = -1, nSeries =	-1},		-- 熊王
		[5] = {nTemplate = 3271, nLevel = 75, nSeries =	1},		-- 任鑫
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 5, 1, 0, "liehu", "2_renxin"},		-- 刷怪
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.MOVIE_DIALOG, -1, "前面有间农舍，过去找那位大叔问问路吧……"},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 240, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3271>：“最近这山里的熊瞎子老不安分，可惜我这农活忙得走不开，看你们几个身手应该不错，去帮我收拾下这些猛兽吧。”"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3271>：“没想到你们几个实力如此不济……想继续闯谷恐怕是凶多吉少。我看你们还是换条安全点的路吧。”"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 0, nNum = 28,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 2, 3, "guaiwu", "2_heixiong_1"},		-- 刷怪
				{XoyoGame.ADD_NPC, 2, 2, 3, "guaiwu", "2_heixiong_2"},		-- 刷怪
				{XoyoGame.ADD_NPC, 3, 24, 3, "guaiwu", "2_heixiong_3"},		-- 刷怪
				{XoyoGame.TARGET_INFO, -1, "Tiêu diệt 28 Gấu Đen"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				
			},
			tbUnLockEvent = 
			{
			},
		},
		[4] = {nTime = 0, nNum = 1,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 4, 0, "guaiwu", "2_heixiong_4"},		-- 刷怪
				{XoyoGame.ADD_NPC, 4, 1, 4, "guaiwu", "2_xiongwang"},		-- 王
				{XoyoGame.MOVIE_DIALOG, -1, "吊桥那边传来阵阵嘶吼，帮人帮到底，过去干掉剩余的猛兽吧。"},
				{XoyoGame.TARGET_INFO, -1, "Tiêu diệt Gấu Chúa"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3271>：“干得不错嘛！别急别急，坐下来烤烤火，休息一会，前方的道路自然会为你们开启。”"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "2_gouhuo"},
			},
		},
	}
}

tbRoom[3] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 1,						-- 房间等级(1~5)
	nMapIndex		= 1,						-- 地图组的索引
	tbBeginPoint	= {52832 / 32, 77408 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3147, nLevel = -1, nSeries = -1},		-- 黄虎
		[2] = {nTemplate = 3251, nLevel = -1, nSeries =	-1},		-- 机关
		[3] = {nTemplate = 3220, nLevel = -1, nSeries =	-1},		-- 虎王
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "一片奇怪的区域，山坡下隐约感觉到一股杀气，还是小心为妙。"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 240, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "山坡下突然出现了4尊白虎雕像，周围聚集了许多猛虎，事有蹊跷，去调查一下那些雕像吧。"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "jiguan"},			-- 石堆
				{XoyoGame.MOVIE_DIALOG, -1, "探险不适合我们，换条路看看有没有什么体力活可以做吧。"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 0, nNum = 4,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 24, 0, "guaiwu", "3_huanghu_3"},		-- 刷怪
				{XoyoGame.ADD_NPC, 2, 4, 3, "jiguan", "3_shidui_jiguan"},			-- 机关
				{XoyoGame.TARGET_INFO, -1, "Điều tra 4 bức tượng được bảo vệ bởi Hổ Vàng"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				
			},
			tbUnLockEvent = 
			{
			},
		},
		[4] = {nTime = 0, nNum = 1,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 4, 0, "guaiwu", "3_huanghu_4"},		-- 刷怪
				{XoyoGame.ADD_NPC, 3, 1, 4, "guaiwu", "3_huwang"},		-- 王
				{XoyoGame.MOVIE_DIALOG, -1, "调查了所有雕像机关后，一声震耳的虎啸从来时的山坡方向传来，过去探个究竟吧。"},
				{XoyoGame.TARGET_INFO, -1, "Tiêu diệt Hổ Chúa"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.MOVIE_DIALOG, -1, "经过一番激战，是该坐下来烤烤火，休息一会，等待一下个挑战了。"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "3_gouhuo"},
			},
		},
	}
}

tbRoom[4] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 1,						-- 房间等级(1~5)
	nMapIndex		= 1,						-- 地图组的索引
	tbBeginPoint	= {54400 / 32, 97600 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3148, nLevel = -1, nSeries = -1},		-- 鳄鱼1
		[2] = {nTemplate = 3149, nLevel = -1, nSeries = -1},		-- 鳄鱼2
		[3] = {nTemplate = 3150, nLevel = -1, nSeries = -1},		-- 鳄鱼3
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.MOVIE_DIALOG, -1, "此处靠水，风景优雅，应该可以钓钓鱼，休息一下啦。"},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = {},
		},
		[2] = {nTime = 240, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "不好！水中竟然有鳄鱼，我们被包围了。赶紧杀出一条血路冲出去吧。"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.MOVIE_DIALOG, -1, "似乎是嫌我们皮糙肉厚，鳄鱼对我们失去了兴趣，全部爬回了水里。看来我们只能换条路再想办法前进了……"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 0, nNum = 40,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 2, 3, "guaiwu", "4_eyu_1"},		-- 刷怪
				{XoyoGame.ADD_NPC, 2, 2, 3, "guaiwu", "4_eyu_2"},		-- 刷怪
				{XoyoGame.ADD_NPC, 3, 36, 3, "guaiwu", "4_eyu_3"},		-- 刷怪
				{XoyoGame.TARGET_INFO, -1, "Tiêu diệt 40 Cá Sấu"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},	
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.MOVIE_DIALOG, -1, "终于干掉了所有鳄鱼，可以休息一会烤烤火了，逍遥谷中凶险异常，我们得认真面对下一项挑战啊。"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "4_gouhuo"},
			},
		},
	}
}

tbRoom[5] = {}
CopyTable(tbRoom[2], tbRoom[5])
tbRoom[5].tbBeginPoint	= {56544 / 32, 90144 / 32};
tbRoom[5].NPC[1].nTemplate = 3148;
tbRoom[5].NPC[2].nTemplate = 3149;
tbRoom[5].NPC[3].nTemplate = 3150;
tbRoom[5].NPC[4].nTemplate = 3224;
tbRoom[5].NPC[5] = {nTemplate = 3272, nLevel = 75, nSeries =	2};
tbRoom[5].LOCK[1].tbStartEvent[1] = {XoyoGame.ADD_NPC, 5, 1, 0, "liehu", "5_rensen"};
tbRoom[5].LOCK[1].tbStartEvent[2] = {XoyoGame.MOVIE_DIALOG, -1, "前面有间农舍，过去找那位大叔问问路吧……"};
tbRoom[5].LOCK[2].tbStartEvent[1]	=	{XoyoGame.MOVIE_DIALOG, -1, "<npc=3272>：“最近也不知哪里来了这么多鳄鱼，害得我都不敢出去捕鱼了，你们几个来得正好！去帮我收拾下这些猛兽吧。”"};
tbRoom[5].LOCK[2].tbUnLockEvent[1] = {XoyoGame.MOVIE_DIALOG, -1, "<npc=3272>：“没想到你们几个实力如此不济……想继续闯谷恐怕是凶多吉少。我看你们还是换条安全点的路吧。”"};
tbRoom[5].LOCK[3].tbStartEvent[1] = {XoyoGame.ADD_NPC, 1, 2, 3, "guaiwu", "5_eyu_1"};		-- 刷怪
tbRoom[5].LOCK[3].tbStartEvent[2] = {XoyoGame.ADD_NPC, 2, 2, 3, "guaiwu", "5_eyu_2"};		-- 刷怪
tbRoom[5].LOCK[3].tbStartEvent[3] = {XoyoGame.ADD_NPC, 3, 28, 3, "guaiwu", "5_eyu_3"};		-- 刷怪
tbRoom[5].LOCK[3].tbStartEvent[4] = {XoyoGame.TARGET_INFO, -1, "Tiêu diệt 32 Cá Sấu"};
tbRoom[5].LOCK[3].nNum = 32
tbRoom[5].LOCK[4].tbStartEvent = 
{
	{XoyoGame.ADD_NPC, 4, 1, 4, "guaiwu", "5_shuangtougui"},		-- 王
	{XoyoGame.MOVIE_DIALOG, -1, "渔船附近传来一阵响动，好像是有什么东西上了岸，过去看看吧。"},
	{XoyoGame.TARGET_INFO, -1, "Tiêu diệt Dị Thú"},	
}
tbRoom[5].LOCK[4].tbUnLockEvent = 
{	
	{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
	{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
	{XoyoGame.CLOSE_INFO, -1},
	{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
	{XoyoGame.MOVIE_DIALOG, -1, "<npc=3272>：“干得不错嘛！别急别急，坐下来烤烤火，休息一会，前方的道路自然会为你们开启。”"},
	{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "5_gouhuo"},
}

tbRoom[6] = {}
CopyTable(tbRoom[1], tbRoom[6])
tbRoom[6].tbBeginPoint	= {53280 / 32, 89920 / 32};
tbRoom[6].NPC[1].nTemplate = 3148;
tbRoom[6].NPC[2].nTemplate = 3149;
tbRoom[6].NPC[3].nTemplate = 3150;
tbRoom[6].NPC[4].nTemplate = 3221;
tbRoom[6].LOCK[1].tbStartEvent[1] = {XoyoGame.MOVIE_DIALOG, -1, "此处水流涔涔，水草萋萋，但这水中似乎有些异动，得多加小心。"};
tbRoom[6].LOCK[2].tbStartEvent[1]	=	{XoyoGame.MOVIE_DIALOG, -1, "果然！数十条鳄鱼突然从水中冒了出来，先杀光它们再寻找闯谷的道路吧。"};
tbRoom[6].LOCK[2].tbUnLockEvent[1] = {XoyoGame.MOVIE_DIALOG, -1, "似乎是嫌我们皮糙肉厚，鳄鱼对我们失去了兴趣，全部爬回了水里。哎……刚入谷就遇此猛兽，真不知前面还有什么凶险等着我们。"};
tbRoom[6].LOCK[3].tbStartEvent[1] = {XoyoGame.ADD_NPC, 1, 2, 3, "guaiwu", "6_eyu_1"};		-- 刷怪
tbRoom[6].LOCK[3].tbStartEvent[2] = {XoyoGame.ADD_NPC, 2, 2, 3, "guaiwu", "6_eyu_2"};		-- 刷怪
tbRoom[6].LOCK[3].tbStartEvent[3] = {XoyoGame.ADD_NPC, 3, 24, 3, "guaiwu", "6_eyu_3"};		-- 刷怪
tbRoom[6].LOCK[3].tbStartEvent[4] = {XoyoGame.TARGET_INFO, -1, "Tiêu diệt 28 Cá Sấu"};
tbRoom[6].LOCK[3].nNum = 28
tbRoom[6].LOCK[4].tbStartEvent = 
{
	{XoyoGame.ADD_NPC, 1, 2, 0, "guaiwu", "6_eyu_4"},		--刷怪
	{XoyoGame.ADD_NPC, 4, 1, 4, "guaiwu", "6_eyuwang"},		-- 王
	{XoyoGame.MOVIE_DIALOG, -1, "刚杀完一批，又有几只更为凶猛的鳄鱼爬上了来。真是没完没了，没办法，杀！"},
	{XoyoGame.TARGET_INFO, -1, "Tiêu diệt Cá Sấu Chúa"},
}
tbRoom[6].LOCK[4].tbUnLockEvent = 
{	
	{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
	{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
	{XoyoGame.CLOSE_INFO, -1},
	{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
	{XoyoGame.MOVIE_DIALOG, -1, "杀死了这头巨鳄，这片区域应该安全了。休息下，烤烤火，等待接下来的挑战吧。"},
	{XoyoGame.DEL_NPC, "guaiwu"},
	{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "6_gouhuo"},
}

-- 护送筱潞
tbRoom[7] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 1,						-- 房间等级(1~5)
	nMapIndex		= 1,						-- 地图组的索引
	tbBeginPoint	= {50560 / 32, 85952 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3141, nLevel = -1, nSeries = -1},		-- 狼
		[2] = {nTemplate = 3273, nLevel = 25, nSeries = 3},		-- 任淼
		[3] = {nTemplate = 3262, nLevel = -1, nSeries =	-1},		-- 筱潞护送
		[4] = {nTemplate = 3286, nLevel = 25, nSeries = 3},		-- 任淼战斗
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 2, 1, 0, "liehu", "7_renmiao"},
				{XoyoGame.ADD_NPC, 3, 1, 5, "husong", "7_xiaolu"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3273>：“各位大侠，帮个忙好吗？最近谷中野狼肆虐，我娘子出去好久了，我很担心她，可是又要照顾家中的孩子而不能脱身，如果各位能够把我娘子带回来，我会非常感激你们的。对了，你们顺着这条路往下走应该就能找到她了。”"},
				{XoyoGame.TARGET_INFO, -1, "Tìm và hộ tống Tiểu Lộ về nhà"},
			},
			tbUnLockEvent = {},
		},
		[2] = {nTime = 240, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "husong"},
				{XoyoGame.DEL_NPC, "liehu"},
				{XoyoGame.DEL_NPC, "liehu_zhandou"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3273>：“非常抱歉，我刚刚太冲动了。你们赶紧走吧，我需要冷静一下……前方的道路待会就会开启，你们好自为之。”\n说完，他便回到了屋内，我们隐约还能听到里面传来的婴儿的啼哭声……"},
			},
		},
		[3] = {nTime = 5, nNum = 0,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "前方有位女子被狼群围困，她应该就是我们要找的人了。"},
				{XoyoGame.ADD_NPC, 1, 32, 0, "guaiwu", "7_yelang_3"},		-- 刷怪
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = {},
		},
		[4] = {nTime = 0, nNum = 1,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.CHANGE_NPC_AI, "husong", XoyoGame.AI_MOVE, "lv1_7_xiaolu", 4, 100, 1},	-- 护送AI
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "husong"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3273>：“各位大侠的大恩大德我们今生难报。来来来，喝口酒，烤烤火，待会前方的道路就会开启了。”"},	
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "7_gouhuo"},
			}
		},
		[5] = {nTime = 0, nNum = 1,
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "liehu"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.ADD_NPC, 4, 1, 6, "liehu_zhandou", "7_renmiao"},		-- 刷怪
				{XoyoGame.MOVIE_DIALOG, -1, "眼看着娘子在自己视线中倒下，那位猎户似乎发了狂，我们是不是应该去安抚一下他呢？"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại Nhậm Diễu"},
				{XoyoGame.FINISH_ACHIEVE, -1,201}, -- 任淼成就
			},
		},	
		[6] = {nTime = 0, nNum = 1,
			tbPrelock = {5},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3273>：“各位，非常抱歉。看着自己娘子死在面前，我无法控制自己的情绪了。现在冷静下来想想，也不能责怪你们。各位休息下，烤烤火吧，前方的道路待会就会开启。”"},	
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "7_gouhuo"},
			},
		},
	}
}

tbRoom[8] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 1,						-- 房间等级(1~5)
	nMapIndex		= 1,						-- 地图组的索引
	tbBeginPoint	= {44736 / 32, 87968 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3147, nLevel = -1, nSeries = -1},		-- 黄虎
		[2] = {nTemplate = 3223, nLevel = -1, nSeries = -1},		-- 马王
		[3] = {nTemplate = 3274, nLevel = -1, nSeries =	4},		-- 护送NPC
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 3, 1, 2, "husong", "8_renyan"},
				{XoyoGame.MOVIE_DIALOG, -1, "前方有一位身形彪悍的猎户，过去找他问问路吧。"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 240, nNum = 1,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "husong"},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3274>：“完了完了！今天又得挨老大批了！你们咋这么不中用呢？”"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 5, nNum = 0,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3274>：“你们来得正好，俺正愁找不到人帮手呢。这山顶有一匹无人能驯服的马王，俺们超哥吩咐俺今天内把它带回去，不过这一路上猛虎挡道，俺一个人搞不定哇……”"},
				{XoyoGame.ADD_NPC, 1, 28, 0, "guaiwu", "8_huanghu_3"},		-- 刷怪
				{XoyoGame.TARGET_INFO, -1, "Hộ tống Nhậm Diệm lên đỉnh đồi"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = {},
		},
		[4] = {nTime = 0, nNum = 1,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.CHANGE_NPC_AI, "husong", XoyoGame.AI_MOVE, "lv1_8_renyan", 4, 100, 1},	-- 护送AI
			},
			tbUnLockEvent = 
			{
				{XoyoGame.ADD_NPC, 2, 1, 5, "guaiwu", "8_mawang"},		-- 刷怪
				{XoyoGame.MOVIE_DIALOG, -1, "终于来到了山顶，前方果然出现了一匹彪悍的野马，帮助任焱将他制服吧。"},
				{XoyoGame.TARGET_INFO, -1, "Thích sát Ngựa Chúa"},
			},
		},
		[5] = {nTime = 0, nNum = 1,
			tbPrelock = {4},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3274>：“谢了哈，俺先回去交差了，哥几个先在这烤烤火，待会前方的道路自然会开启的。”"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "husong"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "8_gouhuo"},
			},
		},
	}
}


tbRoom[9] = {}
CopyTable(tbRoom[4], tbRoom[9]);
tbRoom[9].tbBeginPoint	= {47872 / 32, 98816 / 32};
tbRoom[9].NPC[1].nTemplate = 3145;
tbRoom[9].NPC[2].nTemplate = 3146;
tbRoom[9].NPC[3].nTemplate = 3147;
tbRoom[9].LOCK[1].tbStartEvent[1] = {XoyoGame.MOVIE_DIALOG, -1, "看着这片开阔的区域，心情也跟着舒畅起来。不过，树林里似乎传来了猛兽的气息……还是小心为妙。"};
tbRoom[9].LOCK[2].tbStartEvent[1]	=	{XoyoGame.MOVIE_DIALOG, -1, "果然！数十头猛虎从林中蹿出，先杀光它们再寻找闯谷的道路吧。"};
tbRoom[9].LOCK[2].tbUnLockEvent[1] = {XoyoGame.MOVIE_DIALOG, -1, "似乎是嫌我们皮糙肉厚，老虎们对我们失去了兴趣，全部消失在密林里。哎……刚入谷就遇此猛兽，真不知前面还有什么凶险等着我们。"};
tbRoom[9].LOCK[2].tbUnLockEvent[2] = {XoyoGame.DEL_NPC, "guaiwu"};
tbRoom[9].LOCK[3].tbStartEvent[1] = {XoyoGame.ADD_NPC, 1, 2, 3, "guaiwu", "9_huanghu_1"};		-- 刷怪
tbRoom[9].LOCK[3].tbStartEvent[2] = {XoyoGame.ADD_NPC, 2, 2, 3, "guaiwu", "9_huanghu_2"};		-- 刷怪
tbRoom[9].LOCK[3].tbStartEvent[3] = {XoyoGame.ADD_NPC, 3, 36, 3, "guaiwu", "9_huanghu_3"};		-- 刷怪
tbRoom[9].LOCK[3].tbStartEvent[4] = {XoyoGame.TARGET_INFO, -1, "Tiêu diệt 40 Hổ Vàng"};
tbRoom[9].LOCK[3].tbUnLockEvent = 
{	
	{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
	{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
	{XoyoGame.CLOSE_INFO, -1},
	{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
	{XoyoGame.MOVIE_DIALOG, -1, "扫清了林中的猛虎，这片区域应该安全了。休息下，烤烤火，等待接下来的挑战吧。"},
	{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "9_gouhuo"},
}

tbRoom[10] = {}
CopyTable(tbRoom[4], tbRoom[10]);
tbRoom[10].tbBeginPoint	= {45984 / 32, 95616 / 32};
tbRoom[10].NPC[1].nTemplate = 3142;
tbRoom[10].NPC[2].nTemplate = 3143;
tbRoom[10].NPC[3].nTemplate = 3144;
tbRoom[10].LOCK[1].tbStartEvent[1] = {XoyoGame.MOVIE_DIALOG, -1, "看着这片开阔的区域，心情也跟着舒畅起来。不过，树林里似乎传来了猛兽的气息……还是小心为妙。"};
tbRoom[10].LOCK[2].tbStartEvent[1]	=	{XoyoGame.MOVIE_DIALOG, -1, "果然！数十头黑熊从林中蹿出，先杀光它们再寻找闯谷的道路吧。"};
tbRoom[10].LOCK[2].tbUnLockEvent[1] = {XoyoGame.MOVIE_DIALOG, -1, "似乎是嫌我们皮糙肉厚，熊瞎子也对我们失去了兴趣，全部消失在密林里。哎……刚入谷就遇此猛兽，真不知前面还有什么凶险等着我们。"};
tbRoom[10].LOCK[2].tbUnLockEvent[2] = {XoyoGame.DEL_NPC, "guaiwu"};
tbRoom[10].LOCK[3].tbStartEvent[1] = {XoyoGame.ADD_NPC, 1, 2, 3, "guaiwu", "10_heixiong_1"};		-- 刷怪
tbRoom[10].LOCK[3].tbStartEvent[2] = {XoyoGame.ADD_NPC, 2, 2, 3, "guaiwu", "10_heixiong_2"};		-- 刷怪
tbRoom[10].LOCK[3].tbStartEvent[3] = {XoyoGame.ADD_NPC, 3, 36, 3, "guaiwu", "10_heixiong_3"};		-- 刷怪
tbRoom[10].LOCK[3].tbStartEvent[4] = {XoyoGame.TARGET_INFO, -1, "Tiêu diệt 40 Gấu Đen"};
tbRoom[10].LOCK[3].tbUnLockEvent = 
{	
	{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
	{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
	{XoyoGame.CLOSE_INFO, -1},
	{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
	{XoyoGame.MOVIE_DIALOG, -1, "扫清了林中的黑熊，这片区域应该安全了。休息下，烤烤火，等待接下来的挑战吧。"},
	{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "10_gouhuo"},
}

tbRoom[11] = {}
CopyTable(tbRoom[4], tbRoom[11]);
tbRoom[11].tbBeginPoint	= {50848 / 32, 96320 / 32};
tbRoom[11].NPC[1].nTemplate = 3139;
tbRoom[11].NPC[2].nTemplate = 3140;
tbRoom[11].NPC[3].nTemplate = 3141;
tbRoom[11].LOCK[1].tbStartEvent[1] = {XoyoGame.MOVIE_DIALOG, -1, "看着这片开阔的区域，心情也跟着舒畅起来。不过，树林里似乎传来了猛兽的气息……还是小心为妙。"};
tbRoom[11].LOCK[2].tbStartEvent[1]	=	{XoyoGame.MOVIE_DIALOG, -1, "果然！数十头野狼从林中蹿出，先杀光它们再寻找闯谷的道路吧。"};
tbRoom[11].LOCK[2].tbUnLockEvent[1] = {XoyoGame.MOVIE_DIALOG, -1, "似乎是嫌我们皮糙肉厚，狼群也对我们失去了兴趣，全部消失在密林里。哎……刚入谷就遇此猛兽，真不知前面还有什么凶险等着我们。"};
tbRoom[11].LOCK[2].tbUnLockEvent[2] = {XoyoGame.DEL_NPC, "guaiwu"};
tbRoom[11].LOCK[3].tbStartEvent[1] = {XoyoGame.ADD_NPC, 1, 2, 3, "guaiwu", "11_yelang_1"};		-- 刷怪
tbRoom[11].LOCK[3].tbStartEvent[2] = {XoyoGame.ADD_NPC, 2, 2, 3, "guaiwu", "11_yelang_2"};		-- 刷怪
tbRoom[11].LOCK[3].tbStartEvent[3] = {XoyoGame.ADD_NPC, 3, 36, 3, "guaiwu", "11_yelang_3"};		-- 刷怪
tbRoom[11].LOCK[3].tbStartEvent[4] = {XoyoGame.TARGET_INFO, -1, "Tiêu diệt 40 Sói Hoang"};
tbRoom[11].LOCK[3].tbUnLockEvent = 
{	
	{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
	{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
	{XoyoGame.CLOSE_INFO, -1},
	{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
	{XoyoGame.MOVIE_DIALOG, -1, "扫清了林中的野狼，这片区域应该安全了。休息下，烤烤火，等待接下来的挑战吧。"},
	{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "11_gouhuo"},
}

tbRoom[12] = {}
CopyTable(tbRoom[4], tbRoom[12]);
tbRoom[12].tbBeginPoint	= {51200 / 32, 102112 / 32};
tbRoom[12].NPC[1].nTemplate = 3142;
tbRoom[12].NPC[2].nTemplate = 3143;
tbRoom[12].NPC[3].nTemplate = 3144;
tbRoom[12].NPC[4] = {nTemplate = 3275, nLevel = -1, nSeries = 5};
tbRoom[12].LOCK[1].tbStartEvent[1] = {XoyoGame.MOVIE_DIALOG, -1, "这片空旷的区域中，只有一位神情凝重的猎户，似乎将有什么事情发生。"};
tbRoom[12].LOCK[1].tbStartEvent[2] = {XoyoGame.ADD_NPC, 4, 1, 0, "liehu", "12_renyao"};		-- 猎户
tbRoom[12].LOCK[2].tbStartEvent[1]	=	{XoyoGame.MOVIE_DIALOG, -1, "<npc=3275>：“各位，我们被熊瞎子包围了。我跟它们斗了几个时辰了，不知各位可否帮我杀死他们呢？小心！又来了！”"};
tbRoom[12].LOCK[2].tbUnLockEvent[1] = {XoyoGame.MOVIE_DIALOG, -1, "似乎是嫌我们皮糙肉厚，熊瞎子也对我们失去了兴趣，全部消失在密林里。哎……刚入谷就遇此猛兽，真不知前面还有什么凶险等着我们。"};
tbRoom[12].LOCK[2].tbUnLockEvent[2] = {XoyoGame.DEL_NPC, "guaiwu"};
tbRoom[12].LOCK[3].tbStartEvent[1] = {XoyoGame.ADD_NPC, 1, 2, 3, "guaiwu", "12_heixiong_1"};		-- 刷怪
tbRoom[12].LOCK[3].tbStartEvent[2] = {XoyoGame.ADD_NPC, 2, 2, 3, "guaiwu", "12_heixiong_2"};		-- 刷怪
tbRoom[12].LOCK[3].tbStartEvent[3] = {XoyoGame.ADD_NPC, 3, 36, 3, "guaiwu", "12_heixiong_3"};		-- 刷怪
tbRoom[12].LOCK[3].tbStartEvent[4] = {XoyoGame.TARGET_INFO, -1, "Tiêu diệt 40 Gấu Đen"};
tbRoom[12].LOCK[3].tbUnLockEvent = 
{	
	{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
	{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
	{XoyoGame.CLOSE_INFO, -1},
	{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
	{XoyoGame.MOVIE_DIALOG, -1, "扫清了林中的黑熊，这片区域应该安全了。休息下，烤烤火，等待接下来的挑战吧。"},
	{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "12_gouhuo"},
}


-- 等级2房间
tbRoom[13] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 2,						-- 房间等级(1~5)
	nMapIndex		= 2,						-- 地图组的索引
	tbBeginPoint	= {54528 / 32, 97600 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3151, nLevel = -1, nSeries = -1},		-- 花豹1
		[2] = {nTemplate = 3152, nLevel = -1, nSeries = -1},		-- 花豹2
		[3] = {nTemplate = 3153, nLevel = -1, nSeries = -1},		-- 花豹3
		[4] = {nTemplate = 3221, nLevel = -1, nSeries = -1},		-- 巨鳄
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.MOVIE_DIALOG, -1, "凉亭、瀑布，谷中风景果然别致……但总觉得这水中有些异样，还是小心行动为妙……"},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 240, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "林子里突然蹿出一群花豹，看来又免不了一场恶战了……"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.MOVIE_DIALOG, -1, "没想到这些野兽竟如此凶悍，看来我们只能换条路再想办法前进了……"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 0, nNum = 32,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 2, 3, "guaiwu", "13_huabao_1"},		-- 刷怪
				{XoyoGame.ADD_NPC, 2, 2, 3, "guaiwu", "13_huabao_2"},		-- 刷怪
				{XoyoGame.ADD_NPC, 3, 28, 3, "guaiwu", "13_huabao_3"},		-- 刷怪
				{XoyoGame.TARGET_INFO, -1, "Tiêu diệt 32 Báo Đốm"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				
			},
			tbUnLockEvent = 
			{
			},
		},
		[4] = {nTime = 0, nNum = 2,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 4, 2, 4, "guaiwu", "13_jue"},		-- 王
				{XoyoGame.MOVIE_DIALOG, -1, "身后的深潭里冒出阵阵气泡，似乎有什么东西爬上了岸……过去看看再说。"},
				{XoyoGame.TARGET_INFO, -1, "Tiêu diệt thủy đàm biên đích mãnh thú"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.MOVIE_DIALOG, -1, "恶战之后，还是先坐下来烤烤火，休息一下，等待下一个挑战吧。"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "13_gouhuo"},
			},
		},
	}
}

-- 护送王老汉
tbRoom[14] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 2,						-- 房间等级(1~5)
	nMapIndex		= 2,						-- 地图组的索引
	tbBeginPoint	= {59488 / 32, 96224 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3157, nLevel = -1, nSeries = -1},		-- 机关斧手1
		[2] = {nTemplate = 3159, nLevel = -1, nSeries = -1},		-- 机关斧手2
		[3] = {nTemplate = 3161, nLevel = -1, nSeries = -1},		-- 机关兽1
		[4] = {nTemplate = 3162, nLevel = -1, nSeries = -1},		-- 机关兽2
		[5] = {nTemplate = 3263, nLevel = -1, nSeries =	-1},		-- 护送NPC王老汉
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 5, 1, 2, "husong", "14_wanglaohan"},
				{XoyoGame.MOVIE_DIALOG, -1, "逍遥谷地形错综复杂，也不知道现在到底身处何处，还是找这谷中居民问问路吧。"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 240, nNum = 1,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "husong"},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3263>：“哎哟……我的腰啊！你们还是送我回家养伤吧。以你们这种实力也别往谷深处去了，太危险了！”"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 5, nNum = 0,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3263>：“哎！谷中那狂人整的这些机关玩意又出来捣乱了，想出去采点药都不安生。你们几个看上去挺强的，就帮老汉一把吧。”"},
				{XoyoGame.ADD_NPC, 1, 2, 0, "guaiwu", "14_jiguanfushou_1"},		-- 刷怪
				{XoyoGame.ADD_NPC, 2, 16, 0, "guaiwu", "14_jiguanfushou_2"},		-- 刷怪
				{XoyoGame.ADD_NPC, 3, 16, 0, "guaiwu", "14_xiaoxingjiguanshou_2"},		-- 刷怪
				{XoyoGame.ADD_NPC, 4, 2, 0, "guaiwu", "14_xiaoxingjiguanshou_1"},		-- 刷怪
				{XoyoGame.TARGET_INFO, -1, "Hộ tống Vương Lão Hán"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = {},
		},
		[4] = {nTime = 0, nNum = 1,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.CHANGE_NPC_AI, "husong", XoyoGame.AI_MOVE, "lv2_14_wanglaohan", 4, 100, 1},	-- 护送AI
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3263>：“你们果然很强，要是有机会碰上制造这些机关兽的主，一定要帮我好好教训一下他！老汉我先走了，你们烤烤火，一会前方的道路自然会开启的。”"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "husong"},
				{XoyoGame.FINISH_ACHIEVE, -1,203}, -- achieve 
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "14_gouhuo"},
			},
		},
	}
}

tbRoom[15] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 2,						-- 房间等级(1~5)
	nMapIndex		= 2,						-- 地图组的索引
	tbBeginPoint	= {63456 / 32, 99104 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3151, nLevel = -1, nSeries = -1},		-- 花豹1
		[2] = {nTemplate = 3152, nLevel = -1, nSeries = -1},		-- 花豹2
		[3] = {nTemplate = 3153, nLevel = -1, nSeries = -1},		-- 花豹3
		[4] = {nTemplate = 3224, nLevel = -1, nSeries = -1},		-- 异兽
		[5] = {nTemplate = 3274, nLevel = -1, nSeries =	4},		-- 任焱
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 5, 1, 2, "husong", "15_renyan"},
				{XoyoGame.MOVIE_DIALOG, -1, "前面的亭子那有一位猎户打扮的大叔，看上去忧心忡忡，过去问问情况吧。"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 240, nNum = 1,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "husong"},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3274>：“没想到你们这么不中用……俺先撤了……路在何方？你们自己慢慢找吧。”"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 5, nNum = 0,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3274>：“最近谷里居民抱怨说这湖里有水怪伤人，俺老大超哥派俺过来查探，不想碰上豹群……哥几个，帮个手吧。”"},
				
			},
			tbUnLockEvent = {},
		},
		[4] = {nTime = 0, nNum = 32,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.CHANGE_NPC_AI, "husong", XoyoGame.AI_MOVE, "lv2_15_renyan", 0, 100, 1},	-- 护送AI
				{XoyoGame.ADD_NPC, 1, 2, 4, "guaiwu", "15_huabao_1"},		-- 刷怪
				{XoyoGame.ADD_NPC, 2, 2, 4, "guaiwu", "15_huabao_2"},		-- 刷怪
				{XoyoGame.ADD_NPC, 3, 28, 4, "guaiwu", "15_huabao_3"},		-- 刷怪
				{XoyoGame.TARGET_INFO, -1, "Cùng Nhậm Diệm tiêu diệt 32 Báo Đốm"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = {},
		},
		[5] = {nTime = 0, nNum = 1,
			tbPrelock = {4},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "湖里冒出阵阵气泡，似乎有什么东西爬上了岸……"},
				{XoyoGame.ADD_NPC, 4, 1, 5, "guaiwu", "15_shuiguai"},		-- 刷怪
				{XoyoGame.TARGET_INFO, -1, "Cùng Nhậm Diệm tiêu diệt Dị Thú"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3274>：“哥几个，谢了哈！不过你们继续往深入谷里可能会遇上俺老大，他脾气不太好，你们最好小心点。待会前方的道路就会开启，你们先烤烤火吧。俺先走了哈。”"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "husong"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "15_gouhuo"},
			},
		},
	}
}

tbRoom[16] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 2,						-- 房间等级(1~5)
	nMapIndex		= 2,						-- 地图组的索引
	tbBeginPoint	= {50976 / 32, 109408 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3139, nLevel = -1, nSeries = -1},		-- 狼
		[2] = {nTemplate = 3140, nLevel = -1, nSeries = -1},		-- 狼
		[3] = {nTemplate = 3141, nLevel = -1, nSeries = -1},		-- 狼
		[4] = {nTemplate = 3218, nLevel = -1, nSeries = -1},		-- 狼王
		[5] = {nTemplate = 3275, nLevel = -1, nSeries = 5};			--任垚
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 5, 1, 2, "husong", "16_renyao"},
				{XoyoGame.MOVIE_DIALOG, -1, "周围云雾缭绕，好像到了山顶，亭子那有一位猎户打扮的大叔，过去问问路吧。"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 240, nNum = 1,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "husong"},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3275>：“哇噻！这群畜生好生凶猛！我先撤了……路在何方？你们自己慢慢找吧。”"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 5, nNum = 0,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3275>：“最近狼群肆虐，害得人们都不敢上山来观赏风景，我奉老大之命来收拾这群猛兽，不过好像数量有些多，你们……不介意帮我个忙吧。”"},
			},
			tbUnLockEvent = {},
		},
		[4] = {nTime = 0, nNum = 28,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.CHANGE_NPC_AI, "husong", XoyoGame.AI_MOVE, "lv2_16_renyao", 0, 100, 1},	-- 护送AI
				{XoyoGame.ADD_NPC, 1, 2, 4, "guaiwu", "16_yelang_1"},		-- 刷怪
				{XoyoGame.ADD_NPC, 2, 2, 4, "guaiwu", "16_yelang_2"},		-- 刷怪
				{XoyoGame.ADD_NPC, 3, 24, 4, "guaiwu", "16_yelang_3"},		-- 刷怪
				{XoyoGame.TARGET_INFO, -1, "Cùng Nhậm Nghiêu tiêu diệt 28 Sói Hoang"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = {},
		},
		[5] = {nTime = 0, nNum = 1,
			tbPrelock = {4},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "林中传来一声长啸，看来是狼群的首领出现了……"},
				{XoyoGame.ADD_NPC, 3, 8, 0, "guaiwu", "16_langwanghuwei"},		-- 刷怪
				{XoyoGame.ADD_NPC, 4, 1, 5, "guaiwu", "16_langwang"},		-- 刷怪
				{XoyoGame.TARGET_INFO, -1, "Cùng Nhậm Nghiêu tiêu diệt Sói chúa"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3275>：“呼！终于清静了。待会前方的道路就会开启，你们先烤烤火吧。在下先告辞了。”"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "husong"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "16_gouhuo"},
			},
		},
	}
}

tbRoom[17] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 2,						-- 房间等级(1~5)
	nMapIndex		= 2,						-- 地图组的索引
	tbBeginPoint	= {54432 / 32, 108160 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3139, nLevel = -1, nSeries = -1},		-- 狼1
		[2] = {nTemplate = 3140, nLevel = -1, nSeries = -1},		-- 狼2
		[3] = {nTemplate = 3141, nLevel = -1, nSeries = -1},		-- 狼3
		[4] = {nTemplate = 3218, nLevel = -1, nSeries = -1},		-- 狼王
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.MOVIE_DIALOG, -1, "周围云雾缭绕，好像到了山顶，但前方能听到阵阵狼嚎，还是小心行动为妙。"},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 240, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "果然，从四周林子里窜出一群野狼，为了避免成为他们的美食，只有拼了！"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.MOVIE_DIALOG, -1, "没想到这些野兽竟如此凶悍，看来我们只能换条路再想办法前进了……"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 0, nNum = 28,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 2, 3, "guaiwu", "17_yelang_1"},		-- 刷怪
				{XoyoGame.ADD_NPC, 2, 2, 3, "guaiwu", "17_yelang_2"},		-- 刷怪
				{XoyoGame.ADD_NPC, 3, 24, 3, "guaiwu", "17_yelang_3"},		-- 刷怪
				{XoyoGame.TARGET_INFO, -1, "Tiêu diệt 28 Sói Hoang"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				
			},
			tbUnLockEvent = 
			{
			},
		},
		[4] = {nTime = 0, nNum = 1,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 8, 0, "guaiwu", "17_langwanghuwei"},		-- 刷怪
				{XoyoGame.ADD_NPC, 4, 1, 4, "guaiwu", "17_langwang"},		-- 王
				{XoyoGame.MOVIE_DIALOG, -1, "林中传来一声长啸，看来是狼群的首领出现了……"},
				{XoyoGame.TARGET_INFO, -1, "Tiêu diệt Sói Chúa"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.MOVIE_DIALOG, -1, "恶战之后，还是先坐下来烤烤火，休息一下，等待下一个挑战吧。"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "17_gouhuo"},
			},
		},
	}
}

tbRoom[18] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 2,						-- 房间等级(1~5)
	nMapIndex		= 2,						-- 地图组的索引
	tbBeginPoint	= {61920 / 32, 111168 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3154, nLevel = -1, nSeries = -1},		-- 猴子1
		[2] = {nTemplate = 3155, nLevel = -1, nSeries = -1},		-- 猴子2
		[3] = {nTemplate = 3156, nLevel = -1, nSeries = -1},		-- 猴子3
		[4] = {nTemplate = 3284, nLevel = -1, nSeries = 1},		-- 任鑫
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 4, 1, 2, "husong", "18_renxin"},
				{XoyoGame.MOVIE_DIALOG, -1, "小桥、流水、桃花，真是美不胜收！不过我们是来闯谷的，还是先找前边那位大叔问个路吧。"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 240, nNum = 1,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "husong"},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3284>：“哎呀！该死的猴子把我的新衣服弄破了，回去定遭娘子毒打，这可如何是好，如何是好啊！我……先闪了，你们自己想办法找路吧。”"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 5, nNum = 0,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3284>：“几位少侠，是不是觉得这桃花很美啊，不过近来山上的野猴却时常来捣乱，你们要不要随我一起教训一下这些泼猴？”"},
				
			},
			tbUnLockEvent = {},
		},
		[4] = {nTime = 0, nNum = 16,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.CHANGE_NPC_AI, "husong", XoyoGame.AI_MOVE, "lv2_18_renxin", 0, 100, 1},	-- 护送AI
				{XoyoGame.ADD_NPC, 3, 8, 4, "guaiwu", "18_yehou_1"},		-- 刷怪
				{XoyoGame.ADD_NPC, 3, 8, 4, "guaiwu", "18_yehou_2"},		-- 刷怪
				{XoyoGame.TARGET_INFO, -1, "Cùng Nhậm Hâm dạy lũ Khỉ Hoang 1 bài học"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = {},
		},
		[5] = {nTime = 0, nNum = 16,
			tbPrelock = {4},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3284>：“哎呀！吃饭时间到了，不及时赶回去可是要被娘子打的，剩下的任务就交给你们了，我闪先。”"},
				{XoyoGame.DEL_NPC, "husong"},
				{XoyoGame.ADD_NPC, 1, 2, 5, "guaiwu", "18_yehou_3"},		-- 刷怪
				{XoyoGame.ADD_NPC, 3, 14, 5, "guaiwu", "18_yehou_4"},		-- 刷怪
				{XoyoGame.TARGET_INFO, -1, "Tiêu diệt Khỉ Hoang"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "收拾了捣乱的猴子，终于可以休息下了，先烤烤火，等待下一场挑战吧。"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "husong"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "18_gouhuo"},
			},
		},
	}
}

tbRoom[19] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 2,						-- 房间等级(1~5)
	nMapIndex		= 2,						-- 地图组的索引
	tbBeginPoint	= {48640 / 32, 118272 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3157, nLevel = -1, nSeries = -1},		-- 机关人1
		[2] = {nTemplate = 3160, nLevel = -1, nSeries = -1},		-- 机关人2
		[3] = {nTemplate = 3159, nLevel = -1, nSeries = -1},		-- 机关人3
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.MOVIE_DIALOG, -1, "此地阴气极重，不知道待会会有什么鬼东西冒出来，还是小心行动为妙。"},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = {},
		},
		[2] = {nTime = 240, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "果然，四周冒出来许多机关斧手，看来想要继续闯谷，只有一战了！"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.MOVIE_DIALOG, -1, "转瞬之间所有机关人都消失不见，只剩下狼狈不堪的我们。逍遥谷果然比想象的要艰险许多……"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 0, nNum = 36,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 2, 3, "guaiwu", "19_liezhijiguanren_1"},		-- 刷怪
				{XoyoGame.ADD_NPC, 2, 2, 3, "guaiwu", "19_liezhijiguanren_2"},		-- 刷怪
				{XoyoGame.ADD_NPC, 3, 32, 3, "guaiwu", "19_liezhijiguanren_3"},		-- 刷怪
				{XoyoGame.TARGET_INFO, -1, "Tiêu diệt 36 Cơ Quan Thủ Phủ"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},	
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.MOVIE_DIALOG, -1, "真是一场恶战啊！要是有机会碰上制造这些机关人的主，一定要好好教训一下他！暂时还是先烤火休息下，等待下一个挑战吧。"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "19_gouhuo"},
			},
		},
	}
}

tbRoom[20] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 2,						-- 房间等级(1~5)
	nMapIndex		= 2,						-- 地图组的索引
	tbBeginPoint	= {52000 / 32, 118144 / 32},-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3157, nLevel = -1, nSeries = -1},		-- 机关人1
		[2] = {nTemplate = 3160, nLevel = -1, nSeries =	-1},		-- 机关人2
		[3] = {nTemplate = 3159, nLevel = -1, nSeries =	-1},		-- 机关人3
		[4] = {nTemplate = 3252, nLevel = -1, nSeries =	-1},		-- 机关
		[5] = {nTemplate = 3253, nLevel = -1, nSeries =	-1},		-- 机关
		[6] = {nTemplate = 3254, nLevel = -1, nSeries =	-1},		-- 机关
		[7] = {nTemplate = 3255, nLevel = -1, nSeries =	-1},		-- 机关
		[8] = {nTemplate = 3256, nLevel = -1, nSeries =	-1},		-- 路障NPC
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "似乎闯入了一个地下密道，前路也被阻住，看来要先找到打开这些铁栅栏的机关才能离开这里。"},
				{XoyoGame.ADD_NPC, 8, 3, 0, "zhangai1", "20_luzhang_1"},		-- 障碍
				{XoyoGame.ADD_NPC, 8, 3, 0, "zhangai2", "20_luzhang_2"},		-- 障碍
				{XoyoGame.CHANGE_TRAP, "20_trap_1", {52192 / 32, 117664 / 32}},
				{XoyoGame.CHANGE_TRAP, "20_trap_2", {52896 / 32, 115008 / 32}},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 240, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "jiguan"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.MOVIE_DIALOG, -1, "转瞬之间所有机关人都消失不见，只剩下迷失在密道里的我们……逍遥谷果然比想象的要艰险许多。"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 0, nNum = 2,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 2, 0, "guaiwu", "20_liezhijiguanren_1"},		-- 怪物
				{XoyoGame.ADD_NPC, 2, 2, 0, "guaiwu", "20_liezhijiguanren_2"},		-- 怪物
				{XoyoGame.ADD_NPC, 3, 28, 0, "guaiwu", "20_liezhijiguanren_3"},		-- 怪物
				{XoyoGame.ADD_NPC, 4, 1, 3, "jiguan", "20_jiguan_1"},		-- 机关1
				{XoyoGame.ADD_NPC, 5, 1, 3, "jiguan", "20_jiguan_2"},		-- 机关1
				{XoyoGame.ADD_NPC, 6, 1, 4, "jiguan", "20_jiguan_3"},		-- 机关2
				{XoyoGame.ADD_NPC, 7, 1, 5, "jiguan", "20_jiguan_4"},		-- 机关3
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				{XoyoGame.TARGET_INFO, -1, "Mở khóa tất cả các cơ quan bí mật, tìm đường thoát"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "zhangai1"},
				{XoyoGame.CHANGE_TRAP, "20_trap_1", nil},
				
			},
		},
		[4] = {nTime = 0, nNum = 1,
			tbPrelock = {3},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "zhangai2"},
				{XoyoGame.CHANGE_TRAP, "20_trap_2", nil},
			},
		},
		[5] = {nTime = 0, nNum = 1,
			tbPrelock = {4},
			tbStartEvent = 
			{
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.MOVIE_DIALOG, -1, "终于找到了密道的出口！先停下来烤火烤火，等待下一个挑战吧。"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "20_gouhuo"},
			},
		},
	}
}

-- 护送王老汉
tbRoom[21] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 2,						-- 房间等级(1~5)
	nMapIndex		= 2,						-- 地图组的索引
	tbBeginPoint	= {56512 / 32, 123264 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3157, nLevel = -1, nSeries = -1},		-- 机关斧手1
		[2] = {nTemplate = 3161, nLevel = -1, nSeries = -1},		-- 机关兽1
		[3] = {nTemplate = 3263, nLevel = -1, nSeries =	-1},		-- 护送NPC王老汉
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 3, 1, 2, "husong", "21_wanglaohan"},
				{XoyoGame.MOVIE_DIALOG, -1, "似乎闯入了一个地下密道，也不知出路在哪。前面有个老伯，过去问问他吧。"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 240, nNum = 1,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "husong"},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3263>：“哎哟……我的腰啊！你们还是送我回家养伤吧。以你们这种实力也别往谷深处去了，太危险了！”"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 5, nNum = 0,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3263>：“知道吗？这逍遥谷里产的仙灵果可是炼药的极品哦，谷里有位爷经常高价找我收呢。这不，今天又采了点，正想回家，却又遇上这些机关人。要不你们帮老汉我开条路，我给你们指明闯谷的道路，如何？”"},
				{XoyoGame.ADD_NPC, 1, 18, 0, "guaiwu", "21_jiguanfushou_1"},		-- 刷怪
				{XoyoGame.ADD_NPC, 2, 12, 0, "guaiwu", "21_xiaoxingjiguanshou_1"},		-- 刷怪
				{XoyoGame.TARGET_INFO, -1, "Hộ tống Vương Lão Hán"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = {},
		},
		[4] = {nTime = 0, nNum = 1,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.CHANGE_NPC_AI, "husong", XoyoGame.AI_MOVE, "lv2_21_wanglaohan_1", 4, 20, 1},	-- 护送AI
			},
			tbUnLockEvent = {},
		},
		[5] = {nTime = 0, nNum = 6,
			tbPrelock = {4},
			tbStartEvent = 
			{
				{XoyoGame.BLACK_MSG, -1, "王老汉：“哎哟我的妈啊！咋还有埋伏呢！吾命休矣！”"},
				{XoyoGame.ADD_NPC, 2, 6, 5, "guaiwu", "21_xiaoxingjiguanshou_2"},		-- 刷怪
			},
			tbUnLockEvent = {},
		},
		[6] = {nTime = 0, nNum = 1,
			tbPrelock = {5},
			tbStartEvent = 
			{
				{XoyoGame.BLACK_MSG, -1, "王老汉：“总算捡回一条命，赶紧离开这鬼地方吧。”"},
				{XoyoGame.CHANGE_NPC_AI, "husong", XoyoGame.AI_MOVE, "lv2_21_wanglaohan_2", 6, 100, 1},	-- 护送AI	
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3263>：“你们真是好心人啊，要是有机会碰上制造这些机关人的主，一定要帮我好好教训一下他！老汉我先走了，你们烤烤火，一会前方的道路自然会开启的。”"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "husong"},
				{XoyoGame.FINISH_ACHIEVE, -1,203}, -- achieve 
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "21_gouhuo"},
			},
		},
	}
}

tbRoom[22] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 2,						-- 房间等级(1~5)
	nMapIndex		= 2,						-- 地图组的索引
	tbBeginPoint	= {46336 / 32, 123136 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3163, nLevel = -1, nSeries = -1},		-- 蝮蛇1
		[2] = {nTemplate = 3164, nLevel = -1, nSeries = -1},		-- 蝮蛇2
		[3] = {nTemplate = 3165, nLevel = -1, nSeries = -1},		-- 蝮蛇3
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.MOVIE_DIALOG, -1, "似乎进入了一个废弃的山洞，周围的石头缝里传来阵阵响动，看来是闯进蛇窝了……"},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = {},
		},
		[2] = {nTime = 240, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "蛇！全是蛇！看来它们是嗅到了食物的味道……管不了那么多了，杀出一条血路吧！"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.MOVIE_DIALOG, -1, "转瞬之间剩下的毒蛇都逃进了石缝里，只剩下狼狈不堪的我们。哎，连几条蛇都收拾不掉，看来前方更是凶多吉少了。"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 0, nNum = 36,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 2, 3, "guaiwu", "22_fushe_1"},		-- 刷怪
				{XoyoGame.ADD_NPC, 2, 2, 3, "guaiwu", "22_fushe_2"},		-- 刷怪
				{XoyoGame.ADD_NPC, 3, 32, 3, "guaiwu", "22_fushe_3"},		-- 刷怪
				{XoyoGame.TARGET_INFO, -1, "Tiêu diệt 36 Rắn Hổ"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},	
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.MOVIE_DIALOG, -1, "终于把这窝蛇消灭干净，可以安心烤火休息，等待下一个挑战了。"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "22_gouhuo"},
			},
		},
	}
}

tbRoom[23] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 2,						-- 房间等级(1~5)
	nMapIndex		= 2,						-- 地图组的索引
	tbBeginPoint	= {52096 / 32, 124448 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3166, nLevel = -1, nSeries = -1},		-- 叛军士兵1
		[2] = {nTemplate = 3167, nLevel = -1, nSeries = -1},		-- 叛军士兵2
		[3] = {nTemplate = 3168, nLevel = -1, nSeries = -1},		-- 叛军统领1
		[4] = {nTemplate = 3169, nLevel = -1, nSeries = -1},		-- 叛军统领2
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.MOVIE_DIALOG, -1, "这山洞灯火通明，物资丰富，而且连投石机这种大规模杀伤性武器都有，究竟是什么人藏匿在此呢？"},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = {},
		},
		[2] = {nTime = 240, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "叛军统领：“居然有人发现了我们的秘密基地，兄弟们，别留活口，给我杀！”"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.MOVIE_DIALOG, -1, "只听见洞外有人大吼一声：萧捕头来了！顷刻间，剩下的叛军都已逃匿无踪，只剩下一个疑问萦绕在我们心中：萧捕头是何许人也？"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 0, nNum = 32,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 26, 3, "guaiwu", "23_panjunshibing_2"},		-- 刷怪
				{XoyoGame.ADD_NPC, 2, 2, 3, "guaiwu", "23_panjunshibing_1"},		-- 刷怪
				{XoyoGame.ADD_NPC, 3, 2, 3, "guaiwu", "23_panjuntongling_1"},		-- 刷怪
				{XoyoGame.ADD_NPC, 4, 2, 3, "guaiwu", "23_panjuntongling_2"},		-- 刷怪
				{XoyoGame.TARGET_INFO, -1, "Ngăn cản tất cả Phản Quân"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},	
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.MOVIE_DIALOG, -1, "还好只是些杂鱼部队，轻松收拾了他们以后，可以安心烤火休息，等待下一个挑战了。"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "23_gouhuo"},
			},
		},
	}
}

tbRoom[24] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 2,						-- 房间等级(1~5)
	nMapIndex		= 2,						-- 地图组的索引
	tbBeginPoint	= {55968 / 32, 126048 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3166, nLevel = -1, nSeries = -1},		-- 叛军士兵1
		[2] = {nTemplate = 3168, nLevel = -1, nSeries = -1},		-- 叛军统领1
		[3] = {nTemplate = 3169, nLevel = -1, nSeries = -1},		-- 叛军统领2
		[4] = {nTemplate = 3225, nLevel = -1, nSeries = -1},		-- 煞大目
		[5] = {nTemplate = 3264, nLevel = -1, nSeries =	-1},		-- 萧不实
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 5, 1, 6, "husong", "24_xiaobushi"},
				{XoyoGame.MOVIE_DIALOG, -1, "进入了一个灯火通明的山洞，前方有个貌似忠良的大叔，找他问个路吧。"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 240, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "husong"},
				{XoyoGame.MOVIE_DIALOG, -1, "与煞大目恶战一番之后，未能将其制服，却被他从密道逃脱……\n身后传来萧捕头的声音：“人呢？跑啦？！我靠！10级磨刀石白吃了……我的银子啊……”"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 5, nNum = 0,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3264>：“我乃威震四海的萧不实，萧神捕！近日接到密报，有一股叛乱势力藏匿在逍遥谷研制大规模杀伤性武器，他们的头目应该就藏在此地，你们要不要和我一起进去将他捉拿归案？”"},
				
			},
			tbUnLockEvent = {},
		},
		[4] = {nTime = 0, nNum = 27,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.CHANGE_NPC_AI, "husong", XoyoGame.AI_MOVE, "lv2_24_xiaobushi", 0, 100, 1},	-- 护送AI
				{XoyoGame.ADD_NPC, 1, 24, 4, "guaiwu", "24_panjunshibing"},		-- 刷怪
				{XoyoGame.ADD_NPC, 2, 3, 4, "guaiwu", "24_panjuntongling"},		-- 刷怪
				{XoyoGame.TARGET_INFO, -1, "Cùng Tiêu Bất Thực bắt giữ Thủ Lĩnh Phản Quân"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = {},
		},
		[5] = {nTime = 0, nNum = 1,
			tbPrelock = {4},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "山洞深入传来一声怒吼：“该死的萧捕头！老和本大爷作对，老子今天和你拼了！兄弟们，抄家伙，上！”\n<npc=3264>：“哎呀……磨刀石没了！你们几个先顶着，我去去就来。”\n说完一溜烟就不见了踪影。"},
				{XoyoGame.DEL_NPC, "husong"},
				{XoyoGame.ADD_NPC, 3, 4, 0, "guaiwu", "24_panjuntongling_2"},		-- 刷怪
				{XoyoGame.ADD_NPC, 4, 1, 5, "guaiwu", "24_shadamu"},		-- 刷怪
				{XoyoGame.TARGET_INFO, -1, "Đánh bại Sát Đại Mục"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "打败了煞大目，但是却被他从密道逃跑了。\n山洞里只留下他悲情的怒吼：“我还会回来的……”"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "husong"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "24_gouhuo"},
			},
		},
		[6] = {nTime = 0, nNum = 1,
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3264>：“你们这群小贼给我等着，萧爷爷我吃了10级磨刀石再来会你们！”\n说完一溜烟就不见了踪影，看来这残局得靠我们自己来收拾了……"},
			},
		},
	}
}


-- 3级房间
tbRoom[25] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 3,						-- 房间等级(1~5)
	nMapIndex		= 3,						-- 地图组的索引
	tbBeginPoint	= {50656 / 32, 85824 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
		-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3265, nLevel = -1, 	nSeries = -1},		-- 晓菲护送
		[2] = {nTemplate = 3170, nLevel = -1, 	nSeries = -1}, 		-- 雪人
		[3] = {nTemplate = 3231, nLevel = 75, 	nSeries = -1}, 		-- 柳阔
		[4] = {nTemplate = 3326, nLevel = -1, 	nSeries = -1}, 		-- 秘宝
		[5] = {nTemplate = 6563, nLevel = -1, 	nSeries = -1}, 		-- 情花
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3265>：“几位哥哥姐姐，晓菲听说逍遥谷里有很多好玩的东西，所以偷偷溜了进来，可是却在这迷路了……你们能帮帮我吗？”"},
				{XoyoGame.ADD_NPC, 5, 4, 0, "qinghua", "25_qinghua"},		-- 情花
				{XoyoGame.ADD_NPC, 1, 1, 2, "husong", "25_xiaofei"},		-- 护送NPC				
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = {},
		},
		[2] = {nTime = 360, nNum = 1,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "husong"},
				{XoyoGame.MOVIE_DIALOG, -1, "一群雪人把晓菲扛起，消失在风雪之中，我们能做的也只有祈求上苍保佑这位大小姐福大命大了……"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.ADD_NPC, 4, 6, 0, "mibao", "25_shandingxueren_1"},
			},
		},
		[3] = {nTime = 5, nNum = 0,
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3265>：“瞧，那边几棵树上有些奇怪的文字，可能是走出这雪山的关键，你们陪晓菲去看看吧。”"},
				{XoyoGame.TARGET_INFO, -1, "Cùng Hiểu Phi tìm đường ra khỏi núi tuyết"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
		},
		[4] = {nTime = 0, nNum = 1,	
			tbPrelock = {3},
			tbStartEvent = {
				{XoyoGame.CHANGE_NPC_AI, "husong", XoyoGame.AI_MOVE, "lv3_25_xiaofei_1", 4, 100, 1},	-- 护送AI
			},
			tbUnLockEvent = {},
		},
		[5] = {nTime = 0, nNum = 10,	
			tbPrelock = {4},
			tbStartEvent = {
				{XoyoGame.BLACK_MSG, -1, "刚走到树下，突然间冒出一群凶猛的雪人直扑晓菲……"},
				{XoyoGame.ADD_NPC, 2, 10, 5, "guaiwu", "25_shandingxueren_1"},
			},
			tbUnLockEvent = {},
		},
		[6] = {nTime = 0, nNum = 1,	
			tbPrelock = {5},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3265>：“哇……吓死晓菲了，还好有你们在。树上的秘文我认识，再去下一棵树那看看吧。”"},
				{XoyoGame.CHANGE_NPC_AI, "husong", XoyoGame.AI_MOVE, "lv3_25_xiaofei_2", 6, 100, 1},	-- 护送AI
			},
			tbUnLockEvent = {},
		},
		[7] = {nTime = 0, nNum = 10,	
			tbPrelock = {6},
			tbStartEvent = {
				{XoyoGame.BLACK_MSG, -1, "晓菲正准备解读第二棵树上的秘文，又冒出一群凶恶的雪人……"},
				{XoyoGame.ADD_NPC, 2, 10, 7, "guaiwu", "25_shandingxueren_2"},
			},
			tbUnLockEvent = {},
		},
		[8] = {nTime = 0, nNum = 1,	
			tbPrelock = {7},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3265>：“好！这个也解读完了。继续，下一个！”"},
				{XoyoGame.CHANGE_NPC_AI, "husong", XoyoGame.AI_MOVE, "lv3_25_xiaofei_3", 8, 100, 1},	-- 护送AI
			},
			tbUnLockEvent = {},
		},
		[9] = {nTime = 0, nNum = 10,	
			tbPrelock = {8},
			tbStartEvent = {
				{XoyoGame.BLACK_MSG, -1 , "又是雪人……有完没完啊！"},
				{XoyoGame.ADD_NPC, 2, 10, 9, "guaiwu", "25_shandingxueren_3"},
			},
			tbUnLockEvent = {},
		},
		[10] = {nTime = 0, nNum = 1,	
			tbPrelock = {9},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3265>：“耶！只剩最后一个了，马上就能离开这鬼地方咯。”"},
				{XoyoGame.CHANGE_NPC_AI, "husong", XoyoGame.AI_MOVE, "lv3_25_xiaofei_4", 10, 0, 1},	-- 护送AI
			},
			tbUnLockEvent = {},
		},
		[11] = {nTime = 0, nNum = 10,	
			tbPrelock = {10},
			tbStartEvent = {
				{XoyoGame.BLACK_MSG, -1, "果然……还有埋伏……这些雪人到底想干啥啊？"},
				{XoyoGame.ADD_NPC, 2, 10, 11, "guaiwu", "25_shandingxueren_4"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "husong"},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3265>：“(*^__^*) 嘻嘻……任务完成！这些树上写的是：当雪之女王归来之时，吾族之秘宝才会重现光芒！究竟是什么意思呢？好啦，各位哥哥姐姐，晓菲先去找好玩的东西啦，后会有期咯。”"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.FINISH_ACHIEVE, -1,205}, -- achieve 
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "25_gouhuo"},
				{XoyoGame.CHANGE_FIGHT, -1, 0, Player.emKPK_STATE_PRACTISE},
			},
		},
	},
}

tbRoom[26] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 3,						-- 房间等级(1~5)
	nMapIndex		= 3,						-- 地图组的索引
	tbBeginPoint	= {54720 / 32, 84992 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
		-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3156, nLevel = -1, 	nSeries = -1},		-- 猴子
		[2] = {nTemplate = 3157, nLevel = -1, 	nSeries = -1},		-- 机关斧手1
		[3] = {nTemplate = 3158, nLevel = -1, 	nSeries = -1},		-- 机关斧手2
		[4] = {nTemplate = 3159, nLevel = -1, 	nSeries = -1},		-- 机关斧手3
		[5] = {nTemplate = 3160, nLevel = -1, 	nSeries = -1},		-- 机关斧手4
		[6] = {nTemplate = 3289, nLevel = -1, 	nSeries = -1}, 		-- 石碑机关
		[7] = {nTemplate = 3231, nLevel = 75, 	nSeries = -1}, 		-- 柳阔
		[8] = {nTemplate = 6563, nLevel = -1, 	nSeries = -1}, 		-- 情花
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "逍遥谷里气象万千，居然还有此雪山绝景，果然神奇！"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.ADD_NPC, 8, 4, 0, "qinghua", "26_qinghua"},		-- 情花
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = {},
		},
		[2] = {nTime = 360, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.MOVIE_DIALOG, -1, "没想到这里风景秀丽却机关重重，太危险了，换条安全的路再前进吧。"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 0, nNum = 24,
			tbPrelock = {1},
			tbStartEvent = {
				{XoyoGame.MOVIE_DIALOG, -1, "雪山上哪儿跑出来这么多野猴？真令人扫兴！干掉它们再说。"},
				{XoyoGame.ADD_NPC, 1, 24, 3, "guaiwu", "26_xueyuan"},
				{XoyoGame.TARGET_INFO, -1, "Tiêu diệt 24 Khỉ Hoang"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = {},
		},
		[4] = {nTime = 0, nNum = 1,	
			tbPrelock = {3},
			tbStartEvent = {
				{XoyoGame.BLACK_MSG, -1, "坡上似乎有什么动静，上去调查一番吧。"},
				{XoyoGame.ADD_NPC, 6, 1, 4, "jiguan", "26_shibei"},
				{XoyoGame.TARGET_INFO, -1, "Khảo sát bia đá"},
			},
			tbUnLockEvent = {},
		},
		[5] = {nTime = 0, nNum = 16,	
			tbPrelock = {4},
			tbStartEvent = {
				{XoyoGame.ADD_NPC, 2, 4, 5, "guaiwu", "26_jiguanfushou_1"},
				{XoyoGame.ADD_NPC, 3, 4, 5, "guaiwu", "26_jiguanfushou_2"},
				{XoyoGame.ADD_NPC, 4, 4, 5, "guaiwu", "26_jiguanfushou_3"},
				{XoyoGame.ADD_NPC, 5, 4, 5, "guaiwu", "26_jiguanfushou_4"},
				{XoyoGame.TARGET_INFO, -1, "Loại bỏ tất cả Cơ Quan Thủ Phủ"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "能够死里逃生真不容易，坐下来休息下烤烤火继续出发吧。"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},	
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "26_guohuo"},
				{XoyoGame.CHANGE_FIGHT, -1, 0, Player.emKPK_STATE_PRACTISE},
			},
		},			
	}
}

tbRoom[27] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 3,						-- 房间等级(1~5)
	nMapIndex		= 3,						-- 地图组的索引
	tbBeginPoint	= {56896 / 32, 84320 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
		-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3139, nLevel = -1, 	nSeries = -1},		-- 野狼1
		[2] = {nTemplate = 3140, nLevel = -1, 	nSeries = -1},		-- 野狼2
		[3] = {nTemplate = 3141, nLevel = -1, 	nSeries = -1},		-- 野狼3
		[4] = {nTemplate = 3275, nLevel = -1, 	nSeries = -1},		-- 任垚
		[5] = {nTemplate = 3218, nLevel = -1, 	nSeries = -1},		-- 狼王
		[6] = {nTemplate = 3288, nLevel = -1, 	nSeries = -1},		-- 任垚（强攻）
		[7] = {nTemplate = 3232, nLevel = 75, 	nSeries = -1}, 		-- 柳阔
		[8] = {nTemplate = 6563, nLevel = -1, 	nSeries = -1}, 		-- 情花
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "前面那个猎户好像在哪里见过，过去看看吧。"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.ADD_NPC, 8, 5, 0, "qinghua", "27_qinghua"},		-- 情花
				{XoyoGame.TARGET_INFO, -1, ""},
				{XoyoGame.ADD_NPC, 4, 1, 0, "baohu", "27_renyao"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
			},
		},
		[2] = {nTime = 360, nNum = 0,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3275>：“我听说这一带的野狼变得异常了，特地过来看看，结果被它们重伤，为了村子的安全，你们几个可以帮我杀死这些野兽吗？”"},
				{XoyoGame.ADD_NPC, 1, 1, 4, "guaiwu", "27_yelang_1"},
				{XoyoGame.ADD_NPC, 2, 1, 4, "guaiwu", "27_yelang_2"},
				{XoyoGame.ADD_NPC, 3, 18, 4, "guaiwu", "27_yelang_3"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				{XoyoGame.TARGET_INFO, -1, "Tiêu diệt 20 Sói Hoang"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "只听见得一声奇怪的吼声，余下的狼群全部逃回山中。我们心中充满问号：到底是谁有这么大的威慑力？"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 30, nNum = 0,
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = {},
		},
		[4] = {nTime = 0, nNum = 20, 
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = {},
		},
		[5] = {nTime = 0, nNum = 1,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.BLACK_MSG, -1, "不好，狼群开始袭击任垚，快保护他！"},
				{XoyoGame.TARGET_INFO, -1, "Bảo vệ Nhậm Nghiêu, đông thời tiêu diệt 20 Sói Hoang"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "baohu"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[6]:Close()"},
				{XoyoGame.BLACK_MSG, -1, "任垚：你们顶住，我去找救兵。"},
				{XoyoGame.DO_SCRIPT, "for i = 10, 14 do self.tbLock[i]:Close() end"},
			},
		},
		[6] = {nTime = 150, nNum = 0,
			tbPrelock = {3},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "baohu"},
			},
		},
		[7] = {nTime = 0, nNum = 1,
			tbPrelock = {6},
			tbStartEvent = 
			{
				{XoyoGame.BLACK_MSG, -1, "任垚：我休息好了，来助你们一臂之力！"},
				{XoyoGame.ADD_NPC, 6, 1, 7, "qiangren", "27_renyao_1"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.BLACK_MSG, -1, "任垚：哎呀！妈呀！"},
			},
		},
		[8] = {nTime = 0, nNum = 4,
			tbPrelock = {4},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 4, 8, "guaiwu", "27_yelang_4"},
				{XoyoGame.BLACK_MSG, -1, "又冲了几头狼出来！"},
				{XoyoGame.TARGET_INFO, -1, "Kiên trì hay thắng lợi"},
			},
			tbUnLockEvent = {},
		},
		[9] = {nTime = 0, nNum = 1,
			tbPrelock = {8},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 5, 1, 9, "guaiwu", "27_langwang"},
				{XoyoGame.ADD_NPC, 1, 4, 0, "guaiwu", "27_yelang_5"},
				{XoyoGame.BLACK_MSG, -1, "狼王终于出现了，胜利就在眼前。"},
				{XoyoGame.TARGET_INFO, -1, "Tiêu diệt Sói Chúa"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3288>:“咦，狼怎么就全没了？哇哈哈哈，小朋友们，干得不错啊，来烤烤火休息一下吧。”"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[3]:Close()"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "27_renyao_1"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "27_guohuo"},
				{XoyoGame.CHANGE_FIGHT, -1, 0, Player.emKPK_STATE_PRACTISE},
			},
		},
		[10] = {nTime = 30, nNum = 0,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 3, 1, 0, "husong", "27_yelang_6"},
				{XoyoGame.ADD_NPC, 3, 1, 0, "husong", "27_yelang_6"},
				{XoyoGame.CHANGE_NPC_AI, "husong", XoyoGame.AI_MOVE, "lv3_27_yelang", 5, 0, 0, 1},
			},
			tbUnLockEvent = {},
		},		
	}
}
    for i = 1, 4 do
    	local nNpcIdx = 3;
    	if i > 3 then
    		nNpcIdx = 2;
    	end
    	tbRoom[27].LOCK[10 + i] = {nTime = 30, nNum = 0,
				tbPrelock = {9 + i},
				tbStartEvent = 
			    {
			      {XoyoGame.ADD_NPC, 3, 1, 0, "husong"..i, "27_yelang_6"},
				    {XoyoGame.ADD_NPC, nNpcIdx, 1, 0, "husong"..i, "27_yelang_6"},
				    {XoyoGame.CHANGE_NPC_AI, "husong"..i, XoyoGame.AI_MOVE, "lv3_27_yelang", 5, 0, 0, 1},
				},
				tbUnLockEvent = {},
		};
	end

tbRoom[28] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 3,						-- 房间等级(1~5)
	nMapIndex		= 3,						-- 地图组的索引
	tbBeginPoint	= {51744 / 32, 90720 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
		-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3171, nLevel = -1, 	nSeries = -1},		-- 果农1
		[2] = {nTemplate = 3172, nLevel = -1, 	nSeries = -1},		-- 果农2
		[3] = {nTemplate = 3173, nLevel = -1, 	nSeries = -1},		-- 果农3
		[4] = {nTemplate = 3257, nLevel = -1, 	nSeries = -1},		-- 袋子机关
		[5] = {nTemplate = 3231, nLevel = 75, 	nSeries = -1}, 		-- 柳阔
		[6] = {nTemplate = 6563, nLevel = -1, 	nSeries = -1}, 		-- 情花
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "似乎进入了一个果园，在逍遥谷中走了这么久，终于有一个有吃的东西的地方了，都快饿死了。"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.ADD_NPC, 6, 5, 0, "qinghua", "28_qinghua"},		-- 情花
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = {},
		},
		[2] = {nTime = 360, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.MOVIE_DIALOG, -1, "哎，这年头想填饱肚子都不是一件容易的事啊。没办法，饿着肚子另寻他路吧。"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 0, nNum = 1,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 4, 1, 3, "jiguan", "28_guolan"},
				{XoyoGame.MOVIE_DIALOG, -1, "四下里找找看有没有什么能填饱肚子的东西"},
				{XoyoGame.TARGET_INFO, -1, "Tìm trong vườn xem có gì ăn được không"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = {},
		},
		[4] = {nTime = 0, nNum = 40,	
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 2, 4, "guaiwu", "28_guonong_1"},
				{XoyoGame.ADD_NPC, 2, 2, 4, "guaiwu", "28_guonong_2"},
				{XoyoGame.ADD_NPC, 3, 36, 4, "guaiwu", "28_guonong_3"},
				{XoyoGame.BLACK_MSG, -1, "不好！偷东西被发现了，一群凶神恶煞的果农朝我们扑了过来……。"},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại 40 Quả Nông"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "28_gouhuo"},
				{XoyoGame.MOVIE_DIALOG, -1, "赶跑了果农，坐下来先把肚子填饱，休息下继续出发。"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.CHANGE_FIGHT, -1, 0, Player.emKPK_STATE_PRACTISE},	
			},
		},
	}
}

tbRoom[29] = 	
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 3,						-- 房间等级(1~5)
	nMapIndex		= 3,						-- 地图组的索引
	tbBeginPoint	= {56160 / 32, 89056 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3174, nLevel = -1, nSeries = -1},		-- 劣质机关人
		[2] = {nTemplate = 3175, nLevel = -1, nSeries = -1},		-- 劣质机关人
		[3] = {nTemplate = 3176, nLevel = -1, nSeries = -1},		-- 劣质机关人
		[4] = {nTemplate = 3227, nLevel = -1, nSeries =	-1},		-- 紫苑
		[5] = {nTemplate = 3232, nLevel = 75, 	nSeries = -1}, 		-- 柳阔
		[6] = {nTemplate = 6563, nLevel = -1, 	nSeries = -1}, 		-- 情花
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "前面有户人家，过去看看有没有人能给我们指点下闯谷的路吧。"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.ADD_NPC, 6, 4, 0, "qinghua", "29_qinghua"},		-- 情花
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 360, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3227>：“就这点三脚猫功夫？没意思，不跟你们玩了，本姑娘我找别人去。”"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 120, nNum = 0,		-- 计时锁
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = {},
		},
		[4] = {nTime = 0, nNum = 30,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "又有机关人出来作乱了？做点好事，清理掉这些东西吧。"},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại tất cả Cơ Quan Nhân Thô"},
				{XoyoGame.ADD_NPC, 1, 2, 4, "guaiwu", "29_liezhijiguanren_1"},		-- 刷怪
				{XoyoGame.ADD_NPC, 2, 2, 4, "guaiwu", "29_liezhijiguanren_2"},		-- 刷怪
				{XoyoGame.ADD_NPC, 3, 26, 4, "guaiwu", "29_liezhijiguanren"},		-- 刷怪
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = {},
		},
		[5] = {nTime = 0, nNum = 1,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.BLACK_MSG, -1, "紫苑：“为什么要破坏我辛辛苦苦做出来的机关人？赔！”"},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại Tử Uyển và tất cả Cơ Quan Nhân"},
				{XoyoGame.ADD_NPC, 4, 1, 5, "guaiwu", "29_ziyuan"},		-- 刷怪
			},
			tbUnLockEvent = 
			{
				
			},
		},
		[6] = {nTime = 0, nNum = 0,		-- 结束锁
			tbPrelock = {4,5},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "哎，好心做坏事……哎，什么江湖啊……算了，先烤烤火吧。"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "29_gouhuo"},
				{XoyoGame.CHANGE_FIGHT, -1, 0, Player.emKPK_STATE_PRACTISE},
			},
		},
	}
}

tbRoom[30] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 3,						-- 房间等级(1~5)
	nMapIndex		= 3,						-- 地图组的索引
	tbBeginPoint	= {55168 / 32, 94656 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3141, nLevel = -1, nSeries = -1},		-- 狼
		[2] = {nTemplate = 3266, nLevel = -1, nSeries =	-1},		-- 护送NPC
		[3] = {nTemplate = 3232, nLevel = 75, nSeries = -1}, 		-- 柳阔
		[4] = {nTemplate = 3155, nLevel = -1, nSeries = -1},		-- 猴子1
		[5] = {nTemplate = 3156, nLevel = -1, nSeries = -1},		-- 猴子2
		[6] = {nTemplate = 3304, nLevel = -1, nSeries = -1},		-- 机关
		[7] = {nTemplate = 6563, nLevel = -1, 	nSeries = -1}, 		-- 情花
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "好大一片西瓜地，好大的西瓜。咦？怎么还有一位愁容满面的瓜农，过去问问情况吧。"},
				{XoyoGame.ADD_NPC, 2, 1, 2, "husong", "30_yunsongxiguademache"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.ADD_NPC, 7, 4, 0, "qinghua", "30_qinghua"},		-- 情花
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
			},
		},
		[2] = {nTime = 360, nNum = 1,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "瓜农：天啊，都怪你太没用了。哎哟，我这可怎么向谷主交差啊……"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "husong"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 0, nNum = 1,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "瓜农：我最近按照谷主的要求培育了一种新型西瓜。现在谷主要我把成果运过去，可是大部分西瓜都被一群猴子抢走了，哎，不知各位能不能帮我夺回来。"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				{XoyoGame.ADD_NPC, 4, 2, 0, "guaiwu", "30_yehou_1"},
				{XoyoGame.ADD_NPC, 5, 12, 0, "guaiwu", "30_yehou_2"},
				{XoyoGame.ADD_NPC, 6, 1, 3, "jiguan", "30_yehou_1"},
				{XoyoGame.TARGET_INFO, -1, "Xuống dưới tìm dưa hấu"},
			},
			tbUnLockEvent = {},
		},
		[4] = {nTime = 10, nNum = 0,
			tbPrelock = {3},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.CHANGE_NPC_AI, "husong", XoyoGame.AI_MOVE, "lv3_30_yunsongxiguademache", 5, 100, 1},	-- 护送AI
				{XoyoGame.ADD_NPC, 1, 30, 0, "guaiwu", "30_yelang"},
				{XoyoGame.BLACK_MSG, -1, "瓜农：这下可以给谷主送去了，又要劳烦各位了。"},
				{XoyoGame.TARGET_INFO, -1, "Hộ tống Xe vận chuyển dưa hấu"},
			},
		},
		[5] = {nTime = 0, nNum = 1,
			tbPrelock = {4},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "瓜农：“几位辛苦了，来吃口西瓜休息一下吧，我得继续赶路，先走了。待会前方的道路自会为你们打开。”"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "husong"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "30_gouhuo"},
				{XoyoGame.CHANGE_FIGHT, -1, 0, Player.emKPK_STATE_PRACTISE},
			},
		},
	}
}

tbRoom[31] = {}
CopyTable(tbRoom[28], tbRoom[31]);
tbRoom[31].tbBeginPoint	= {47456 / 32, 95584 / 32};
tbRoom[31].LOCK[3].tbStartEvent[1] = {XoyoGame.ADD_NPC, 4, 1, 3, "jiguan", "31_guolan"}
tbRoom[31].LOCK[4].tbStartEvent[1] = {XoyoGame.ADD_NPC, 1, 2, 4, "guaiwu", "31_guonong_1"}
tbRoom[31].LOCK[4].tbStartEvent[2] = {XoyoGame.ADD_NPC, 2, 2, 4, "guaiwu", "31_guonong_2"}
tbRoom[31].LOCK[4].tbStartEvent[3] = {XoyoGame.ADD_NPC, 3, 36, 4, "guaiwu", "31_guonong_3"}
tbRoom[31].LOCK[4].tbUnLockEvent[1] = {XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "31_gouhuo"}

tbRoom[32] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 3,						-- 房间等级(1~5)
	nMapIndex		= 3,						-- 地图组的索引
	tbBeginPoint	= {50720 / 32, 98784 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3179, nLevel = -1, nSeries = -1},		-- 幽灵
		[2] = {nTemplate = 3267, nLevel = -1, nSeries =	-1},		-- 护送周大飞
		[3] = {nTemplate = 3231, nLevel = 75, nSeries =	-1},		-- 柳阔
		[4] = {nTemplate = 3325, nLevel = -1, nSeries =	-1},		-- 秘宝
		[5] = {nTemplate = 6563, nLevel = -1, 	nSeries = -1}, 		-- 情花
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "此地阴气极重，不知道隐藏着什么样的危机。咦，前面有个人，过去问问情况吧。"},
				{XoyoGame.ADD_NPC, 2, 1, 3, "husong", "32_zhoudafei"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.ADD_NPC, 5, 4, 0, "qinghua", "32_qinghua"},		-- 情花
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 360, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "转瞬之间，周大飞和所有幽灵都消失不见，只留下惊魂未定的我们和一堆散发着奇怪光芒的物体，难道……这就是传说中的秘宝？"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "husong"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.ADD_NPC, 4, 6, 0, "mibao", "32_mibao"},		-- 秘宝
			},
		},
		[3] = {nTime = 0, nNum = 1,		-- 大飞死亡
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3267>：“为什么……我又要死在这种地方……究竟还要等多少年，我才能离开这鬼地方啊？”"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "husong"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[4] = {nTime = 5, nNum = 0,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3267>：“你们……是活人？太好了！求求你们带我离开鬼地方吧。这里好多幽灵，太可怕了。瞧，它们又出来了。”"},
				{XoyoGame.TARGET_INFO, -1, "Hộ tống Chu Đại Phi"},
				{XoyoGame.ADD_NPC, 1, 36, 0, "guaiwu", "32_youmingjianke"},		-- 刷怪
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = {},
		},
		[5] = {nTime = 0, nNum = 1,
			tbPrelock = {4},
			tbStartEvent = 
			{
				{XoyoGame.CHANGE_NPC_AI, "husong", XoyoGame.AI_MOVE, "lv3_32_zhoudafei", 5, 100, 1},	-- 护送AI
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3267>：“谢谢你们，我终于可以重见天日了，哈哈哈！哎？为什么……为什么我的身体在消失，为什么？我不要回到那个地方……不要啊……”\n转眼间，周大飞的身体已飞灰湮灭，只留下一堆篝火。算了，不去想那么多，专心烤火吧。"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "husong"},
				{XoyoGame.FINISH_ACHIEVE, -1,206}, -- achieve 
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "32_gouhuo"},
				{XoyoGame.CHANGE_FIGHT, -1, 0, Player.emKPK_STATE_PRACTISE},
			},
		},
	}
}

tbRoom[33] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 3,						-- 房间等级(1~5)
	nMapIndex		= 3,						-- 地图组的索引
	tbBeginPoint	= {50432 / 32, 106496 / 32},-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3174, nLevel = -1, nSeries = -1},		-- 机关木人
		[2] = {nTemplate = 3175, nLevel = -1, nSeries = -1},		-- 机关木人
		[3] = {nTemplate = 3176, nLevel = -1, nSeries = -1},		-- 机关木人
		[4] = {nTemplate = 3228, nLevel = -1, nSeries = -1},		-- 秦仲
		[5] = {nTemplate = 3290, nLevel = -1, nSeries =	-1},		-- 路障NPC
		[6] = {nTemplate = 3232, nLevel = 75, 	nSeries = -1}, 		-- 柳阔
		[7] = {nTemplate = 6563, nLevel = -1, 	nSeries = -1}, 		-- 情花
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "此地甚为阴森，前路也被障碍阻住，待会肯定不会有什么好事发生。"},
				{XoyoGame.ADD_NPC, 5, 2, 0, "zhangai1", "33_luzhang"},		-- 障碍
				{XoyoGame.ADD_NPC, 7, 3, 0, "qinghua", "33_qinghua"},		-- 情花
				{XoyoGame.CHANGE_TRAP, "33_trap_1", {51552 / 32, 107360 / 32}},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 360, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "转眼间，所有敌人都消失无踪，难道我们刚刚是在做梦？"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.DEL_NPC, "guaiwu"},	
			},
		},
		[3] = {nTime = 0, nNum = 30,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 2, 3, "guaiwu", "33_jiguanmuren_1"},		-- 怪物
				{XoyoGame.ADD_NPC, 2, 2, 3, "guaiwu", "33_jiguanmuren_2"},		-- 怪物
				{XoyoGame.ADD_NPC, 3, 26, 3, "guaiwu", "33_jiguanmuren_3"},		-- 怪物
				{XoyoGame.TARGET_INFO, -1, "Đánh bại 30 Cơ Quan Nhân Thô"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				
			},
			tbUnLockEvent = {},
		},
		[4] = {nTime = 0, nNum = 1,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 3, 12, 0, "guaiwu", "33_jiguanmuren_4"},		-- 怪物
				{XoyoGame.ADD_NPC, 4, 1, 4, "guaiwu", "33_qinzhong"},
				{XoyoGame.DEL_NPC, "zhangai1"},
				{XoyoGame.CHANGE_TRAP, "33_trap_1", nil},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3228>：“居然能打败我制造的机关人，实力不赖嘛，过来陪我玩玩吧。”\n前方的铁栅栏好像打开了，过去瞧瞧是什么人在挑衅。"},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại Tần Trọng"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "有惊无险的击败了秦仲。不过真是怪人处处有，逍遥谷里特别多，他们怎么就老喜欢整这些机关玩意来折磨人呢？"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},	
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "33_gouhuo"},
				{XoyoGame.CHANGE_FIGHT, -1, 0, Player.emKPK_STATE_PRACTISE},
			},
		},
	}
}

tbRoom[34] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 3,						-- 房间等级(1~5)
	nMapIndex		= 3,						-- 地图组的索引
	tbBeginPoint	= {53248 / 32, 104448 / 32},-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3177, nLevel = -1, nSeries = -1},		-- 幽冥鬼
		[2] = {nTemplate = 3178, nLevel = -1, nSeries = -1},		-- 幽冥鬼
		[3] = {nTemplate = 3179, nLevel = -1, nSeries = -1},		-- 幽冥鬼
		[4] = {nTemplate = 3229, nLevel = -1, nSeries = -1},		-- 鬼王
		[5] = {nTemplate = 3276, nLevel = -1, nSeries = -1},		-- 木桩
		[6] = {nTemplate = 3277, nLevel = -1, nSeries = -1},		-- 木桩
		[7] = {nTemplate = 3278, nLevel = -1, nSeries = -1},		-- 木桩
		[8] = {nTemplate = 3232, nLevel = 75, 	nSeries = -1}, 		-- 柳阔
		[9] = {nTemplate = 6563, nLevel = -1, 	nSeries = -1}, 		-- 情花
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "此地甚为阴森，待会肯定不会有好事发生。千万别出现那种东西啊！"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.ADD_NPC, 9, 4, 0, "qinghua", "34_qinghua"},		-- 情花
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 360, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "转眼间，所有幽灵都消失无踪，难道我们刚刚是在做梦？"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.DEL_NPC, "guaiwu"},	
			},
		},
		[3] = {nTime = 0, nNum = 34,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 2, 3, "guaiwu", "34_youminggui_1"},		-- 怪物
				{XoyoGame.ADD_NPC, 2, 2, 3, "guaiwu", "34_youminggui_2"},		-- 怪物
				{XoyoGame.ADD_NPC, 3, 30, 3, "guaiwu", "34_youminggui_3"},		-- 怪物
				{XoyoGame.TARGET_INFO, -1, "Đánh bại 34 U Minh Quỷ"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				
			},
			tbUnLockEvent = {},
		},
		[4] = {nTime = 0, nNum = 1,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 3, 12, 0, "guaiwu", "34_youminggui_4"},		-- 怪物
				{XoyoGame.ADD_NPC, 4, 1, 4, "guaiwu", "34_youmingguiwang"},		-- 怪物
				{XoyoGame.ADD_NPC, 5, 1, 0, "guaiwu", "34_muzhuang_1"},
				{XoyoGame.ADD_NPC, 6, 1, 0, "guaiwu", "34_muzhuang_2"},
				{XoyoGame.ADD_NPC, 7, 1, 0, "guaiwu", "34_muzhuang_3"},
				{XoyoGame.BLACK_MSG, -1, "突然感觉到前方传来一股强烈的寒气，似乎有更为强悍的厉鬼出现了"},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại U Minh Quỷ Vương"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "干掉了鬼王，这儿应该安全了。先烤烤火，休息下吧。"},
				{XoyoGame.DEL_NPC, "guaiwu"},	
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "34_gouhuo"},
				{XoyoGame.CHANGE_FIGHT, -1, 0, Player.emKPK_STATE_PRACTISE},
			},
		},
	}
}




-- BOSS房间
tbRoom[37] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 3,						-- 房间等级(1~5)
	nMapIndex		= 3,						-- 地图组的索引
	tbBeginPoint	= {58464 / 32, 91808 / 32},-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3180, nLevel = -1, nSeries = -1},		-- 幼犬
		[2] = {nTemplate = 3240, nLevel = -1, nSeries =	-1},		-- 旺才
		[3] = {nTemplate = 3241, nLevel = -1, nSeries =	1},		-- 木超
		[4] = {nTemplate = 3232, nLevel = 75, 	nSeries = -1}, 		-- 柳阔
		[5] = {nTemplate = 6563, nLevel = -1, 	nSeries = -1}, 		-- 情花
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "似乎闯入了一户猎户人家……四下里找找看有没有人可以问问路吧。"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.ADD_NPC, 5, 5, 0, "qinghua", "37_qinghua"},		-- 情花
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 360, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "人没找着，倒是冒出几条猎犬朝我们扑了过来，赶跑它们再说"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "逍遥谷中果然藏龙卧虎，还是换条路继续前进吧。"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.DEL_NPC, "guaiwu"},	
			},
		},
		[3] = {nTime = 90, nNum = 0,		-- 计时刷boss
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = {},
		},
		[4] = {nTime = 0, nNum = 9,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 9, 4, "guaiwu", "37_liequan"},		-- 怪物
				{XoyoGame.TARGET_INFO, -1, "Đánh bại tất cả Chó Săn"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbLock[3]:Close()"},
			},
		},
		[5] = {nTime = 0, nNum = 1,
			tbPrelock = {{3,4}},
			tbStartEvent = 
			{
				{XoyoGame.BLACK_MSG, -1, "什么人敢在我的地盘捣乱！活得不耐烦了？"},
				{XoyoGame.ADD_NPC, 2, 1, 0, "guaiwu", "37_wangcai"},
				{XoyoGame.ADD_NPC, 3, 1, 5, "guaiwu", "37_muchao"},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại Mộc Siêu"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "这位猎户骁勇善战，能够脱险已是万幸，好好整顿下。"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "37_gouhuo"},
				{XoyoGame.CHANGE_FIGHT, -1, 0, Player.emKPK_STATE_PRACTISE},
			},
		},
	}
}

-- 猜谜房间
tbRoom[35]  = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= BaseRoom.GuessRule,		-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 3,						-- 房间等级(1~5)
	nMapIndex		= 3,						-- 地图组的索引
	tbBeginPoint	= {53440 / 32,	93312 / 32},-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3279, nLevel = 99, nSeries = -1},
		[2] = {nTemplate = 3231, nLevel = 75, 	nSeries = -1}, 		-- 柳阔
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3279>：“哈哈哈，闯荡逍遥谷的侠士们，让我来考考你们对这个江湖的了解程度吧。请你们双方的队长来我这接受考验吧。”"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = {},
		},
		[2] = {nTime = 360, nNum = 0,
			tbPrelock = {1};
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 2, "datinpc", "35_jiutiandaoren"},			-- 答题NPC
				{XoyoGame.ADD_NPC, 2, 1, 0, "shangren", "35_liukuo"},			-- 答题NPC
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				{XoyoGame.TARGET_INFO, -1, "Do đội trưởng trả lời cửu thiên đạo nhân vài vấn đề"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "datinpc"},
				{XoyoGame.DO_SCRIPT, "self:CheckWinner()"},		-- 手动判胜负
				{XoyoGame.DO_SCRIPT, "self:TeamBlackMsg(self.tbWinner, '我们果然是才智兼备啊')"};
				{XoyoGame.DO_SCRIPT, "self:FinishAchieve2(self.tbWinner, 207)"};
				{XoyoGame.DO_SCRIPT, "self:TeamBlackMsg(self.tbLoser, '哎，看来我们对这个江湖的了解程度还不够啊')"};
			},
		},
	}
}

-- PK房间
tbRoom[36] = 
{
	fnPlayerGroup 	= BaseRoom.PKGroup,			-- PK分组
	fnDeath			= BaseRoom.PKDeath,			-- PK房间死亡脚本;
	fnWinRule		= BaseRoom.PKWinRule,		-- PK胜利条件
	nRoomLevel		= 3,						-- 房间等级(1~5)
	nMapIndex		= 3,						-- 地图组的索引
	tbBeginPoint	= {{47104/32, 89120/32}, {48512/32, 87648/32}},-- 起始点，
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "对面似乎也是对逍遥谷充满好奇心的人，也不知道他们的功夫怎么样，去试他一试吧。"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, "Quân ta tiêu diệt: 0\nQuân địch tiêu diệt: 0"},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 360, nNum = 0,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian PK: %s<color>", 2},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_CAMP},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self:CheckWinner()"},		-- 手动判胜负
				{XoyoGame.DO_SCRIPT, "self:TeamBlackMsg(self.tbWinner, '看来还是我们队伍技高一筹啊')"};
				{XoyoGame.DO_SCRIPT, "self:TeamBlackMsg(self.tbLoser, '对方实力太强，我们还需多多磨练啊')"};
			},
		},
	}
}

-- 等级4 房间 
tbRoom[38] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 4,						-- 房间等级(1~5)
	nMapIndex		= 4,						-- 地图组的索引
	tbBeginPoint	= {62016 / 32, 106592 / 32},-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3280, nLevel = -1, nSeries = -1},		-- 翠小鸥
		[2] = {nTemplate = 3183, nLevel = -1, nSeries =	-1},		-- 闯谷贼
		[3] = {nTemplate = 3188, nLevel = -1, nSeries =	-1},		-- 闯谷贼头领
		[4] = {nTemplate = 3301, nLevel = 35, nSeries = -1},        -- 萧不实
		[5] = {nTemplate = 3321, nLevel = 35, nSeries = -1},        -- 箱子
		[6] = {nTemplate = 6563, nLevel = -1, nSeries = -1}, 		-- 情花
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 0, "baohu", "38_cuixiaoou"},		-- 保护NPC
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3280>：最近谷里来了好多凶神恶煞的贼人，爸爸妈妈又出去了，小鸥好害怕妈妈辛苦培育的宝贝被贼人们抢走了，你们能帮帮我吗？"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
				{XoyoGame.ADD_NPC, 6, 6, 0, "qinghua", "38_qinghua"},		-- 情花
			},
			tbUnLockEvent = 
			{
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
			},
		},
		[2] = {nTime = 30, nNum = 0,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 2, 2, 0, "guaiwu1_1", "38_chuangguzei_1"},
				{XoyoGame.ADD_NPC, 2, 2, 0, "guaiwu2_1", "38_chuangguzei_2"},
				{XoyoGame.CHANGE_NPC_AI, "guaiwu1_1", XoyoGame.AI_MOVE, "lv4_38_chuangguzei_1", 10, 0, 0, 1},	-- 寻路
				{XoyoGame.CHANGE_NPC_AI, "guaiwu2_1", XoyoGame.AI_MOVE, "lv4_38_chuangguzei_2", 10, 0, 0, 1},   -- 寻路
			},
			tbUnLockEvent = {},
		},
		[10] = {nTime = 0, nNum = 1,
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "baohu"},
				{XoyoGame.DO_SCRIPT, "for i = 2, 9 do self.tbLock[i]:Close() end"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[11]:Close()"},
			},
		},
		[11] = {nTime = 240, nNum = 0,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 11},
				{XoyoGame.TARGET_INFO, -1, "Bảo vệ Thúy Tiểu Âu"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbLock[10]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[12]:Close()"},
			},
		},
		[12] = {nTime = 480, nNum = 0,
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.MOVIE_DIALOG, -1, "就在这时，小鸥站了起来！原来刚才她是装死的。幸好这位机智的小女孩向萧捕头说明了情况，我才能逃过一劫，真是谢天谢地啊。\n<npc=3280>：太好了，恶人们都走了！你们去看看我家的宝贝吧。应该就藏在瀑布下面。"},
				{XoyoGame.ADD_NPC, 5, 6, 0, "baoxiang", "38_baoxiang"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[13]:Close()"},
			},
		},
		[13] = {nTime = 0, nNum = 1, 
			tbPrelock = {10},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 2, 20, 0, "guaiwu", "38_chuanguzei_4"},
				{XoyoGame.ADD_NPC, 4, 1, 13, "guaiwu", "38_xiaobushi"},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3264>: 我接到线报说，此处强盗出没，危害百姓生活因此过来看看。没想到你们这群没有人性畜生，连个小女孩都不放过！今天就要让你们尝尝萧某的厉害！"},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại Tiêu Bất Thực"},
				{XoyoGame.FINISH_ACHIEVE, -1,208}, -- achieve 
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 12},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},
				{XoyoGame.MOVIE_DIALOG, -1, "经过一场艰难的战斗，我们终于制住了萧捕头。和萧捕头一番解释之后，他相信了我们，并带着小鸥的尸首离开了这里。我们也该休息下然后继续前进了。"},
				{XoyoGame.CLOSE_INFO, -1},
				--{XoyoGame.FINISH_ACHIEVE, -1,208}, -- achieve 
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[12]:Close()"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "38_gouhuo"},
			},
		},
		[14] = {nTime = 240, nNum = 0,
			tbPrelock = {11},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.MOVIE_DIALOG, -1, "这群强盗太难缠了。这是，传来一声巨吼：萧某在此！谁敢造次！声毕，只见那群强盗一溜烟作鸟兽散。只留下手舞足蹈的翠小鸥和狼狈不堪的我们。"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.DEL_NPC, "baohu"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[15]:Close()"},
			},
		},
		[15] = {nTime = 0, nNum = 2,
			tbPrelock = {11},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "抵挡了一阵，但是还是有大批强盗涌了过来。想要真正保护小鸥，必须要收拾掉他们的头领才行"},
				{XoyoGame.ADD_NPC, 2, 18, 0, "guaiwu", "38_chuangguzei_3"},
				{XoyoGame.ADD_NPC, 3, 2, 15, "guaiwu", "38_chuangguzeitouling_3"},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại 2 Thủ Lĩnh Sấm Cốc Tặc"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 14},
			},
			tbUnLockEvent =
			{
				{XoyoGame.MOVIE_DIALOG, -1, "成功阻止了闯谷贼伤害小鸥。过去和小鸥聊聊天，休息一下，再继续前进吧。"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[14]:Close()"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "38_gouhuo"},
			},
		},
	},
}
	for i = 1, 7 do
			local nNpcIdx = 2;
			local nLockTime = 30;
			local nNpcCount = 2;
			if i > 6 then
				nNpcIdx = 3;
				nLockTime = 30;
				nNpcCount = 1;
			end
			tbRoom[38].LOCK[2 + i] = {nTime = nLockTime, nNum = 0,
				tbPrelock = {1 + i},
				tbStartEvent = 
					{
						{XoyoGame.ADD_NPC, nNpcIdx, nNpcCount, 0, "guaiwu"..i.."_1", "38_chuangguzei_1"},
						{XoyoGame.ADD_NPC, nNpcIdx, nNpcCount, 0, "guaiwu"..i.."_2", "38_chuangguzei_2"},
						{XoyoGame.CHANGE_NPC_AI, "guaiwu"..i.."_1", XoyoGame.AI_MOVE, "lv4_38_chuangguzei_1", 10, 0, 0, 1},	-- 寻路
						{XoyoGame.CHANGE_NPC_AI, "guaiwu"..i.."_2", XoyoGame.AI_MOVE, "lv4_38_chuangguzei_2", 10, 0, 0, 1},	-- 寻路
					},
				tbUnLockEvent = {},
			};
		end

tbRoom[39] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 4,						-- 房间等级(1~5)
	nMapIndex		= 4,						-- 地图组的索引
	tbBeginPoint	= {57376 / 32, 107424 / 32},-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3258, nLevel = -1, nSeries = -1},		-- 袋子
		[2] = {nTemplate = 3185, nLevel = -1, nSeries =	-1},		-- 闯谷贼
		[3] = {nTemplate = 3184, nLevel = -1, nSeries =	-1},		-- 闯谷贼
		[4] = {nTemplate = 3183, nLevel = -1, nSeries =	-1},		-- 闯谷贼
		[5] = {nTemplate = 3188, nLevel = -1, nSeries =	-1},		-- 闯谷贼头领
		[6] = {nTemplate = 6563, nLevel = -1, nSeries = -1}, 		-- 情花
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				
				{XoyoGame.MOVIE_DIALOG, -1, "这地方怎么连个鬼影都没？真怪异！四处找找看有什么可疑的东西没。"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
				{XoyoGame.ADD_NPC, 6, 6, 0, "qinghua", "39_qinghua"},		-- 情花
			},
			tbUnLockEvent = {},
		},
		[2] = {nTime = 480, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "jiguan"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[3]:Close()"},
				{XoyoGame.MOVIE_DIALOG, -1, "闯谷贼头领：“你们几个家伙还算有点真本事，好汉不吃眼前亏，兄弟们，撤！\n转眼间，所有贼人都逃匿无踪……”"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 0, nNum = 1,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 3, "jiguan", "39_zhuangyoubaowudedaizi"},		-- 机关
				{XoyoGame.TARGET_INFO, -1, "Chung quanh tìm xem khán có cái gì khả nghi gì đó"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = {}
		},
		[4] = {nTime = 0, nNum = 32,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.DEL_NPC, "jiguan"},		-- 机关
				{XoyoGame.ADD_NPC, 2, 3, 4, "guaiwu", "39_chuangguzei_1"},	
				{XoyoGame.ADD_NPC, 2, 3, 4, "guaiwu", "39_chuangguzei_2"},	
				{XoyoGame.ADD_NPC, 4, 26, 4, "guaiwu", "39_chuangguzei_3"},	
				{XoyoGame.TARGET_INFO, -1, "Đánh bại tất cả Sấm Cốc Tặc đang phục kích bên trong"},
			},
			tbUnLockEvent = {}
		},
		[5] = {nTime = 0, nNum = 1,
			tbPrelock = {4},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "闯谷贼头领：“一群废物，几个毛头小子都搞不定。本大爷来会会你们！”"},
				{XoyoGame.ADD_NPC, 5, 1, 5, "guaiwu", "39_chuangguzeitouling"},
				{XoyoGame.ADD_NPC, 3, 2, 0, "guaiwu", "39_chuangguzei_4"},
				{XoyoGame.ADD_NPC, 2, 2, 0, "guaiwu", "39_chuangguzei_4"},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại Thủ Lĩnh Sấm Cốc Tặc"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "击败了埋伏在此的所有恶人。可以安心烤下火，准备迎接最后的挑战了。"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "39_gouhuo"},
			}
		},
	},
}

tbRoom[40] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 4,						-- 房间等级(1~5)
	nMapIndex		= 4,						-- 地图组的索引
	tbBeginPoint	= {51200 / 32, 104160 / 32},-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3322, nLevel = -1, nSeries =	-1},		-- 石碑机关
		[2] = {nTemplate = 3276, nLevel = 1, nSeries =	-1},		-- 木桩机关_可被攻击
		[3] = {nTemplate = 3323, nLevel = -1, nSeries =	-1},		-- 木桩机关_不可攻击
		[4] = {nTemplate = 3324, nLevel = -1, nSeries =	-1},		-- 狂暴机关人_无形蛊
		[5] = {nTemplate = 3194, nLevel = -1, nSeries =	-1},		-- 狂暴机关人_普通
		[6] = {nTemplate = 6563, nLevel = -1, nSeries = -1}, 		-- 情花
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "这片竹林之中竟然有户人家，过去看看能否讨碗水喝吧。"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
				{XoyoGame.ADD_NPC, 6, 6, 0, "qinghua", "40_qinghua"},		-- 情花
			},
			tbUnLockEvent = 
			{
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
			},
		},
		[2] = {nTime = 480, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "guaiwu1"},
				{XoyoGame.DEL_NPC, "guaiwu2"},
				{XoyoGame.DEL_NPC, "guaiwu3"},
				{XoyoGame.DEL_NPC, "guaiwu4"},
				{XoyoGame.DEL_NPC, "jiguan1"},
				{XoyoGame.DEL_NPC, "jiguan2"},
				{XoyoGame.DEL_NPC, "jiguan3"},
				{XoyoGame.DEL_NPC, "jiguan4"},
				{XoyoGame.MOVIE_DIALOG, -1, "（一个奇怪的声音再次响起）“旅人啊，你们没有资格获得宝藏！”"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 0, nNum = 0,
			tbPrelock = {6,9,12,15},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.MOVIE_DIALOG, -1, "（一个奇怪的声音再次响起）“神奇的旅人啊，你们竟然可以解开我设下的机关。想必你们听过很多‘此地无银三百两’的故事，不过此地真的无银！哇哈哈哈哈哈。”"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "40_jiguan_1"},
			},
		},
		[4] = {nTime = 30, nNum = 1,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 4, "jiguan", "40_shibei"},
				{XoyoGame.MOVIE_DIALOG , -1, "奇怪，竟然没人在家。院子里好像立着一块石碑，上面写的竟然是“此地无银！！”"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				{XoyoGame.TARGET_INFO, -1, "Mau đào lên xem có gì!"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "诶，好像触动了什么东西！\n（一个奇怪的声音）“旅人啊，想要获得宝藏就去解开所有的机关吧。提醒你们，机关的守护兽是很忠诚的。”"},
				{XoyoGame.ADD_NPC, 2, 1, 5, "guaiwu1", "40_jiguan_1"},
				{XoyoGame.ADD_NPC, 2, 1, 8, "guaiwu2", "40_jiguan_2"},
				{XoyoGame.ADD_NPC, 2, 1, 11, "guaiwu3", "40_jiguan_3"},
				{XoyoGame.ADD_NPC, 2, 1, 14, "guaiwu4", "40_jiguan_4"},
				{XoyoGame.ADD_NPC, 4, 3, 0, "guaiwu1", "40_kuangbaojiguanren_1"},
				{XoyoGame.ADD_NPC, 4, 3, 0, "guaiwu2", "40_kuangbaojiguanren_2"},
				{XoyoGame.ADD_NPC, 4, 3, 0, "guaiwu3", "40_kuangbaojiguanren_3"},
				{XoyoGame.ADD_NPC, 4, 3, 0, "guaiwu4", "40_kuangbaojiguanren_4"},
				{XoyoGame.DEL_NPC, "jiguan"},
				{XoyoGame.TARGET_INFO, -1, "Mở 4 cơ quan. Lưu ý, phải mở kịp thời, các quái bảo vệ sẽ liên tục xuất hiện."},
			},
		},
		[5] = {nTime = 0, nNum = 1,
			tbPrelock = {4},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 2, 1, 5, "guaiwu1", "40_jiguan_1"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.ADD_NPC, 3, 1, 6, "jiguan1", "40_jiguan_1"},
			},
		},
		[6] = {nTime = 0, nNum = 1,
			tbPrelock = {5},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.ADD_NPC, 5, 12, 0, "guaiwu", "40_kuangbaojiguanren_1.0"},
				{XoyoGame.ADD_NPC, 5, 3, 0, "guaiwu", "40_kuangbaojiguanren_1"},
				{XoyoGame.BLACK_MSG, -1, "又出现了一批守卫。"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[7]:Close()"},
				{XoyoGame.DO_SCRIPT, "for i = 1, 30 do self.tbLock[10 + 8 * i]:Close() end"},
			},
		},
		[7] = {nTime = 15, nNum = 0,
			tbPrelock = {5},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "jiguan1"},
				{XoyoGame.DEL_NPC, "guaiwu1"},
				{XoyoGame.ADD_NPC, 2, 1, 17, "guaiwu1", "40_jiguan_1"},
				{XoyoGame.ADD_NPC, 4, 3, 0, "guaiwu1", "40_kuangbaojiguanren_1"},
			},
		},
		[8] = {nTime = 0, nNum = 1,
			tbPrelock = {4},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.ADD_NPC, 3, 1, 9, "jiguan2", "40_jiguan_2"},
			},
		},
		[9] = {nTime = 0, nNum = 1,
			tbPrelock = {8},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.ADD_NPC, 5, 12, 0, "guaiwu", "40_kuangbaojiguanren_2.0"},
				{XoyoGame.ADD_NPC, 5, 3, 0, "guaiwu", "40_kuangbaojiguanren_2"},
				{XoyoGame.BLACK_MSG, -1, "又出现了一批守卫。"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[10]:Close()"},
				{XoyoGame.DO_SCRIPT, "for i = 1, 30 do self.tbLock[12 + 8 * i]:Close() end"},
			},
		},
		[10] = {nTime = 15, nNum = 0,
			tbPrelock = {8},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "jiguan2"},
				{XoyoGame.DEL_NPC, "guaiwu2"},
				{XoyoGame.ADD_NPC, 2, 1, 19, "guaiwu2", "40_jiguan_2"},
				{XoyoGame.ADD_NPC, 4, 3, 0, "guaiwu2", "40_kuangbaojiguanren_2"},
			},
		},
		[11] = {nTime = 0, nNum = 1,
			tbPrelock = {4},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.ADD_NPC, 3, 1, 12, "jiguan3", "40_jiguan_3"},
			},
		},
		[12] = {nTime = 0, nNum = 1,
			tbPrelock = {11},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.ADD_NPC, 5, 12, 0, "guaiwu", "40_kuangbaojiguanren_3.0"},
				{XoyoGame.ADD_NPC, 5, 3, 0, "guaiwu", "40_kuangbaojiguanren_3"},
				{XoyoGame.BLACK_MSG, -1, "又出现了一批守卫。"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[13]:Close()"},
				{XoyoGame.DO_SCRIPT, "for i = 1, 30 do self.tbLock[14 + 8 * i]:Close() end"},
			},
		},
		[13] = {nTime = 15, nNum = 0,
			tbPrelock = {11},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "jiguan3"},
				{XoyoGame.DEL_NPC, "guaiwu3"},
				{XoyoGame.ADD_NPC, 2, 1, 21, "guaiwu3", "40_jiguan_3"},
				{XoyoGame.ADD_NPC, 4, 3, 0, "guaiwu3", "40_kuangbaojiguanren_3"},
			},
		},
		[14] = {nTime = 0, nNum = 1,
			tbPrelock = {4},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.ADD_NPC, 3, 1, 15, "jiguan4", "40_jiguan_4"},
			},
		},
		[15] = {nTime = 0, nNum = 1,
			tbPrelock = {14},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.ADD_NPC, 5, 12, 0, "guaiwu", "40_kuangbaojiguanren_4.0"},
				{XoyoGame.ADD_NPC, 5, 3, 0, "guaiwu", "40_kuangbaojiguanren_4"},
				{XoyoGame.BLACK_MSG, -1, "又出现了一批守卫。"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[16]:Close()"},
				{XoyoGame.DO_SCRIPT, "for i = 1, 30 do self.tbLock[16 + 8 * i]:Close() end"},
			},
		},
		[16] = {nTime = 15, nNum = 0,
			tbPrelock = {14},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "jiguan4"},
				{XoyoGame.DEL_NPC, "guaiwu4"},
				{XoyoGame.ADD_NPC, 2, 1, 23, "guaiwu4", "40_jiguan_4"},
				{XoyoGame.ADD_NPC, 4, 3, 0, "guaiwu4", "40_kuangbaojiguanren_4"},
			},
		},
		[17] = {nTime = 0, nNum = 1,
			tbPrelock = {7},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.ADD_NPC, 3, 1, 6, "jiguan1", "40_jiguan_1"},
			},
		},
		[18] = {nTime = 15, nNum = 0,
			tbPrelock = {17},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "jiguan1"},
				{XoyoGame.DEL_NPC, "guaiwu1"},
				{XoyoGame.ADD_NPC, 2, 1, 25, "guaiwu1", "40_jiguan_1"},
				{XoyoGame.ADD_NPC, 4, 3, 0, "guaiwu1", "40_kuangbaojiguanren_1"},
			},
		},
		[19] = {nTime = 0, nNum = 1,
			tbPrelock = {10},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.ADD_NPC, 3, 1, 9, "jiguan2", "40_jiguan_2"},
			},
		},
		[20] = {nTime = 15, nNum = 0,
			tbPrelock = {19},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "jiguan2"},
				{XoyoGame.DEL_NPC, "guaiwu2"},
				{XoyoGame.ADD_NPC, 2, 1, 27, "guaiwu2", "40_jiguan_2"},
				{XoyoGame.ADD_NPC, 4, 3, 0, "guaiwu2", "40_kuangbaojiguanren_2"},
			},
		},
		[21] = {nTime = 0, nNum = 1,
			tbPrelock = {13},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.ADD_NPC, 3, 1, 12, "jiguan3", "40_jiguan_3"},
			},
		},
		[22] = {nTime = 15, nNum = 0,
			tbPrelock = {21},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "jiguan3"},
				{XoyoGame.DEL_NPC, "guaiwu3"},
				{XoyoGame.ADD_NPC, 2, 1, 29, "guaiwu3", "40_jiguan_3"},
				{XoyoGame.ADD_NPC, 4, 3, 0, "guaiwu3", "40_kuangbaojiguanren_3"},
			},
		},
		[23] = {nTime = 0, nNum = 1,
			tbPrelock = {16},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.ADD_NPC, 3, 1, 15, "jiguan4", "40_jiguan_4"},
			},
		},
		[24] = {nTime = 15, nNum = 0,
			tbPrelock = {23},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "jiguan4"},
				{XoyoGame.DEL_NPC, "guaiwu4"},
				{XoyoGame.ADD_NPC, 2, 1, 31, "guaiwu4", "40_jiguan_4"},
				{XoyoGame.ADD_NPC, 4, 3, 0, "guaiwu4", "40_kuangbaojiguanren_4"},
			},
		},
	},
}

for i = 2, 30 do
	tbRoom[40].LOCK[9 + 8 * i] = {nTime = 0, nNum = 1,
		tbPrelock = {2 + 8 * i},
		tbStartEvent = {},
		tbUnLockEvent = 
		{
			{XoyoGame.ADD_NPC, 3, 1, 6, "jiguan1", "40_jiguan_1"},
		},
	};
	tbRoom[40].LOCK[10 + 8 * i] = {nTime = 15, nNum = 0,
		tbPrelock = {9 + 8 * i},
		tbStartEvent = {},
		tbUnLockEvent = 
		{
			{XoyoGame.DEL_NPC, "jiguan1"},
			{XoyoGame.DEL_NPC, "guaiwu1"},
			{XoyoGame.ADD_NPC, 2, 1, 17 + 8 * i, "guaiwu1", "40_jiguan_1"},
			{XoyoGame.ADD_NPC, 4, 3, 0, "guaiwu1", "40_kuangbaojiguanren_1"},
		},
	};
	tbRoom[40].LOCK[11 + 8 * i] = {nTime = 0, nNum = 1,
		tbPrelock = {4 + 8 * i},
		tbStartEvent = {},
		tbUnLockEvent = 
		{
			{XoyoGame.ADD_NPC, 3, 1, 9, "jiguan2", "40_jiguan_2"},
		},
	};
	tbRoom[40].LOCK[12 + 8 * i] = {nTime = 15, nNum = 0,
		tbPrelock = {11 + 8 * i},
		tbStartEvent = {},
		tbUnLockEvent = 
		{
			{XoyoGame.DEL_NPC, "jiguan2"},
			{XoyoGame.DEL_NPC, "guaiwu2"},
			{XoyoGame.ADD_NPC, 2, 1, 19 + 8 * i, "guaiwu2", "40_jiguan_2"},
			{XoyoGame.ADD_NPC, 4, 3, 0, "guaiwu2", "40_kuangbaojiguanren_2"},
		},
	};
	tbRoom[40].LOCK[13 + 8 * i] = {nTime = 0, nNum = 1,
		tbPrelock = {6 + 8 * i},
		tbStartEvent = {},
		tbUnLockEvent = 
		{
			{XoyoGame.ADD_NPC, 3, 1, 12, "jiguan3", "40_jiguan_3"},
		},
	};
	tbRoom[40].LOCK[14 + 8 * i] = {nTime = 15, nNum = 0,
		tbPrelock = {13 + 8 * i},
		tbStartEvent = {},
		tbUnLockEvent = 
		{
			{XoyoGame.DEL_NPC, "jiguan3"},
			{XoyoGame.DEL_NPC, "guaiwu3"},
			{XoyoGame.ADD_NPC, 2, 1, 21 + 8 * i, "guaiwu3", "40_jiguan_3"},
			{XoyoGame.ADD_NPC, 4, 3, 0, "guaiwu3", "40_kuangbaojiguanren_3"},
		},
	};
	tbRoom[40].LOCK[15 + 8 * i] = {nTime = 0, nNum = 1,
		tbPrelock = {8 + 8 * i},
		tbStartEvent = {},
		tbUnLockEvent = 
		{
			{XoyoGame.ADD_NPC, 3, 1, 15, "jiguan4", "40_jiguan_4"},
		},
	};
	tbRoom[40].LOCK[16 + 8 * i] = {nTime = 15, nNum = 0,
		tbPrelock = {8 + 8 * i},
		tbStartEvent = {},
		tbUnLockEvent = 
		{
			{XoyoGame.DEL_NPC, "jiguan4"},
			{XoyoGame.DEL_NPC, "guaiwu4"},
			{XoyoGame.ADD_NPC, 2, 1, 23 + 8 * i, "guaiwu4", "40_jiguan_4"},
			{XoyoGame.ADD_NPC, 4, 3, 0, "guaiwu4", "40_kuangbaojiguanren_4"},
		},
	};
end

tbRoom[41] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 4,						-- 房间等级(1~5)
	nMapIndex		= 4,						-- 地图组的索引
	tbBeginPoint	= {56288 / 32, 115680 / 32},-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3281, nLevel = -1, nSeries =	-1},		-- 菁华
		[2] = {nTemplate = 3154, nLevel = -1, nSeries =	-1},		-- 野猴
		[3] = {nTemplate = 3155, nLevel = -1, nSeries =	-1},		-- 野猴
		[4] = {nTemplate = 3156, nLevel = -1, nSeries =	-1},		-- 野猴
		[5] = {nTemplate = 3222, nLevel = -1, nSeries =	-1},		-- 野猴王
		[6] = {nTemplate = 6563, nLevel = -1, nSeries = -1}, 		-- 情花
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 0, "baishe", "41_jinghua"},	
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3281>：“瞧这桃花开的，真是美啊！但山上的野猴们好像已经按耐不住了，老围着我家的桃树打转，帮我赶走它们吧。”"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
				{XoyoGame.ADD_NPC, 6, 6, 0, "qinghua", "41_qinghua"},		-- 情花
			},
			tbUnLockEvent = {},
		},
		[2] = {nTime = 480, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[3]:Close()"},
				{XoyoGame.MOVIE_DIALOG, -1, "大战一场以后，其他猴子都受到惊吓逃回了山上，没想到我们连几只猴子都收拾不了，惭愧啊。"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 0, nNum = 32,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 2, 2, 3, "guaiwu", "41_yehou_1"},	
				{XoyoGame.ADD_NPC, 3, 2, 3, "guaiwu", "41_yehou_2"},	
				{XoyoGame.ADD_NPC, 4, 28, 3, "guaiwu", "41_yehou_3"},	
				{XoyoGame.TARGET_INFO, -1, "Tiêu diệt 32 Khỉ Hoang"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = {}
		},
		[4] = {nTime = 0, nNum = 1,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 4, 6, 0, "guaiwu", "41_yehou_4"},	
				{XoyoGame.ADD_NPC, 5, 1, 4, "guaiwu", "41_houwang"},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại Khỉ Chúa"},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3281>：“这些猴子都是受那只猴王指示的，顺手也把它赶走吧。”"}
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3281>：“各位幸苦了，来休息下，烤烤火，再往前走就到了逍遥谷的最深处了。”"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "41_gouhuo"},
			}
		},
	},
}

tbRoom[42] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 4,						-- 房间等级(1~5)
	nMapIndex		= 4,						-- 地图组的索引
	tbBeginPoint	= {61216 / 32, 114016 / 32},-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3268, nLevel = -1, nSeries = -1},		-- 香玉仙
		[2] = {nTemplate = 3191, nLevel = -1, nSeries =	-1},		-- 机关巨狼
		[3] = {nTemplate = 3159, nLevel = -1, nSeries =	-1},		-- 机关斧手
		[4] = {nTemplate = 3242, nLevel = -1, nSeries =	-1},		-- 完美机关巨狼
		[5] = {nTemplate = 6563, nLevel = -1, nSeries = -1}, 		-- 情花
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "前面那个……难道是？人见人爱，花见花开的香玉仙？"},
				{XoyoGame.ADD_NPC, 1, 1, 2, "husong", "42_xiangyuxian"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
				{XoyoGame.ADD_NPC, 5, 6, 0, "qinghua", "42_qinghua"},		-- 情花
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 240, nNum = 1,		-- 4分钟内或目标死亡
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbLock[5]:Close()"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "husong"},
				{XoyoGame.MOVIE_DIALOG, -1, "香玉仙已身受重伤晕了过了，我们也还是速速逃离此地吧"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 5, nNum = 0,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3268>：听说此地有个能造出完美机关兽的天才，本想来拜会他一下，却没想到他的机关兽如此凶悍……前方有座民房，你们能送我到那让我疗下伤吗？"},
				{XoyoGame.ADD_NPC, 2, 16, 0, "guaiwu", "42_jiguanjulang"},		-- 刷怪
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				{XoyoGame.TARGET_INFO, -1, "Hộ tống Hương Ngọc Tiên đến khu dân cư chữa bệnh"},
			},
			tbUnLockEvent = {},
		},
		[4] = {nTime = 0, nNum = 1,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.CHANGE_NPC_AI, "husong", XoyoGame.AI_MOVE, "lv4_42_xiangyuxian", 4, 100, 1, 1},	-- 护送AI
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
			},
		},
		[5] = {nTime = 480, nNum = 0,
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbLock[6]:Close()"},
				{XoyoGame.DEL_NPC, "guaiwu1"},
				{XoyoGame.MOVIE_DIALOG, -1, "这些机关兽过于凶悍！我们还是速速逃离此地吧。"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[6] = {nTime = 0, nNum = 16,
			tbPrelock = {4},
			tbStartEvent = 
			{
				{XoyoGame.BLACK_MSG, -1, "又冒出一堆机关狼，把它们全部清理掉吧！"},
				{XoyoGame.ADD_NPC, 2, 14, 6, "guaiwu1", "42_jiguanjulang"},		-- 刷怪
				{XoyoGame.ADD_NPC, 4, 2, 6, "guaiwu1", "42_jiguanjulang"},		-- 刷怪
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 5},
				{XoyoGame.TARGET_INFO, -1, "Tiêu diệt tất cả Cơ Quan Cự Lang"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[5]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.MOVIE_DIALOG, -1, "终于搞定了这些机关狼，真是一场恶战啊，弄出这些鬼东西的人到底是何方神圣呢？"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "42_jiguanjulang"},
			},
		},
	}
}

tbRoom[43] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 4,						-- 房间等级(1~5)
	nMapIndex		= 4,						-- 地图组的索引
	tbBeginPoint	= {64768 / 32, 116832 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3189, nLevel = -1, nSeries = -1},		-- 机关巨狼1
		[2] = {nTemplate = 3190, nLevel = -1, nSeries = -1},		-- 机关巨狼2
		[3] = {nTemplate = 3191, nLevel = -1, nSeries = -1},		-- 机关巨狼3
		[4] = {nTemplate = 3154, nLevel = -1, nSeries =	-1},		-- 野猴1
		[5] = {nTemplate = 3155, nLevel = -1, nSeries =	-1},		-- 野猴2
		[6] = {nTemplate = 3156, nLevel = -1, nSeries =	-1},		-- 野猴3
		[7] = {nTemplate = 3259, nLevel = -1, nSeries =	-1},		-- 野果机关
		[8] = {nTemplate = 6563, nLevel = -1, nSeries = -1}, 		-- 情花
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.MOVIE_DIALOG, -1, "此处风景秀丽，真叫人流连忘返啊。"},
				{XoyoGame.TARGET_INFO, -1, ""},
				{XoyoGame.ADD_NPC, 8, 6, 0, "qinghua", "43_qinghua"},		-- 情花
			},
			tbUnLockEvent = 
			{
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
			},
		},
		[2] = {nTime = 480, nNum = 0,	
			tbPrelock = {1},
		    tbStartEvent = {},
		    tbUnLockEvent = 
		    {
		    	{XoyoGame.MOVIE_DIALOG, -1, "可恶，没力气了，只能眼睁睁看着该死的猴子逃走。真不甘心！"},
		    	{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
		    },
		  },
		[3] = {nTime = 300, nNum = 0,
		 	tbPrelock = {1},
		 	tbStartEvent = 
		 	{
		 		{XoyoGame.ADD_NPC, 1, 2, 4, "guaiwu", "43_jiguanjulang_1"},
		    	{XoyoGame.ADD_NPC, 2, 2, 4, "guaiwu", "43_jiguanjulang_2"},
		    	{XoyoGame.ADD_NPC, 3, 24, 4, "guaiwu", "43_jiguanjulang_3"},
		    	{XoyoGame.MOVIE_DIALOG, -1, "该死的！那些机关物又出现了，为什么老是阴魂不散呢？难道是最近坏事做多了？？"},
				{XoyoGame.TARGET_INFO, -1, "Trong 5 phút tiêu diệt 28 Cơ Quan Cự Lang"},
		    	{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 3},
	    	},
		 	tbUnLockEvent = 
		 	{
		 		{XoyoGame.DEL_NPC, "guaiwu"},
		 		{XoyoGame.MOVIE_DIALOG, -1, "可恶，这些机关物太强悍了！也不知道造了什么孽，真是的！"},
		 		{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
		 		{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
	 		},
		 },
		 [4] = {nTime = 0, nNum = 28,
		 	tbPrelock = {1},
		 	tbStartEvent = {},
		 	tbUnLockEvent = 
		 	{
		 		{XoyoGame.MOVIE_DIALOG, -1, "在逍遥谷中走了这么久，累了，肚子也饿了。在附近找点野果吃吃吧。"},
		 		{XoyoGame.DO_SCRIPT, "self.tbLock[3]:Close()"},
	 		},
		 },
		 [5] = {nTime = 60, nNum = 0,
		 	tbPrelock = {4},
		 	tbStartEvent = 
		 	{
		 		{XoyoGame.ADD_NPC, 7, 1, 6, "jiguan", "43_yeguo"},
				{XoyoGame.TARGET_INFO, -1, "Hái 1 Trái Dại"},
		 		{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
	 	    },
		    tbUnLockEvent = 
		    {
		    	{XoyoGame.DEL_NPC, "jiguan"},
		    	{XoyoGame.DO_SCRIPT, "self.tbLock[6]:Close()"},
	    	},
		  },
		  [6] = {nTime = 0, nNum = 1,
		  	tbPrelock = {4},
		  	tbStartEvent = {},
		  	tbUnLockEvent = 
		  	{
		  	    {XoyoGame.DO_SCRIPT, "self.tbLock[5]:Close()"},
		  	},
		  },
		  [7] = {nTime = 0, nNum = 14,
		  	tbPrelock = {{5, 6}},
		  	tbStartEvent = 
		  	{
		  		{XoyoGame.ADD_NPC, 4, 1, 7, "guaiwu", "43_yehou_1"},
		  		{XoyoGame.ADD_NPC, 5, 1, 7, "guaiwu", "43_yehou_2"},
		  		{XoyoGame.ADD_NPC, 6, 12, 7, "guaiwu", "43_yehou_3"},
		  		{XoyoGame.BLACK_MSG, -1, "一群猴子抢走了我们的果子，可恶，非得教训教训它们。"},
				{XoyoGame.TARGET_INFO, -1, "Dạy lũ Khỉ Hoang 1 bài học"},
	  		},
		    tbUnLockEvent = 
		    {
		    	{XoyoGame.MOVIE_DIALOG, -1, "赶走了可恶的猴子，拿回了果子。这次的遭遇真令人不悦。好好休息下，准备继续前进吧。"},
		    	{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "43_yeguo"},
			},
		},
	}
}

tbRoom[44] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 4,						-- 房间等级(1~5)
	nMapIndex		= 4,						-- 地图组的索引
	tbBeginPoint	= {60576 / 32, 130688 / 32},-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3189, nLevel = -1, nSeries = -1},		-- 机关巨狼
		[2] = {nTemplate = 3190, nLevel = -1, nSeries =	-1},		-- 机关巨狼
		[3] = {nTemplate = 3191, nLevel = -1, nSeries =	-1},		-- 机关巨狼
		[4] = {nTemplate = 3242, nLevel = -1, nSeries =	-1},		-- 机关巨狼boss
		[5] = {nTemplate = 3289, nLevel = -1, nSeries =	-1},		-- 石碑
		[6] = {nTemplate = 6563, nLevel = -1, nSeries = -1}, 		-- 情花
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "没想到谷中还有如此规模宏大的地下宫殿……四周连个鬼影都没有，看来得小心行动才行。"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
				{XoyoGame.ADD_NPC, 6, 6, 0, "qinghua", "44_qinghua"},		-- 情花
			},
			tbUnLockEvent = {},
		},
		[2] = {nTime = 480, nNum = 0,		-- 总时间
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "jiguan"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.MOVIE_DIALOG, -1, "这些鬼东西凶猛无比，还是速速离开此地为妙。"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 0, nNum = 12,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "两块石碑凭空出现，有必要先调查一下。"},
				{XoyoGame.ADD_NPC, 5, 1, 4, "jiguan", "44_shibei_1"},		-- 石碑
				{XoyoGame.ADD_NPC, 5, 1, 5, "jiguan", "44_shibei_2"},		-- 石碑
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				{XoyoGame.TARGET_INFO, -1, "Khảo sát bia đá"},
			},
			tbUnLockEvent = 
			{
				
			},
		},
		[4] = {nTime = 0, nNum = 1,
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 6, 3, "guaiwu", "44_jiguanjulang_1"},		-- 机关巨狼
			},
		},
		[5] = {nTime = 0, nNum = 1,
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.ADD_NPC, 2, 6, 3, "guaiwu", "44_jiguanjulang_2"},		-- 机关巨狼
			},
		},
		[6] = {nTime = 0, nNum = 0,
			tbPrelock = {4,5},
			tbStartEvent = 
			{
				{XoyoGame.TARGET_INFO, -1, "Tiêu diệt tất cả Cơ Quan Cự Lang"},
			},
			tbUnLockEvent = {},
		},
		[7] = {nTime = 0, nNum = 1,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.BLACK_MSG, -1, "地宫中传来一声巨响，似乎有更为凶猛的怪物出现了……"},
				{XoyoGame.ADD_NPC, 3, 20, 0, "guaiwu", "44_jiguanjulang_3"},		-- 机关巨狼
				{XoyoGame.ADD_NPC, 4, 1, 7, "guaiwu", "44_wanmeidejiguanjulang"},		-- 完美的机关巨狼
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				{XoyoGame.TARGET_INFO, -1, "Tiêu diệt Cơ Quan Cự Lang Hoàn Mỹ"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.MOVIE_DIALOG, -1, "经过一场恶战，终于干掉了这恐怖的巨兽。整理一下行装，准备迎接最后的挑战吧。"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "44_gouhuo"},
			},
		},
	},
}

tbRoom[45] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 4,						-- 房间等级(1~5)
	nMapIndex		= 4,						-- 地图组的索引
	tbBeginPoint	= {61760 / 32, 132864 / 32},-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3280, nLevel = -1, nSeries = -1},		-- 崔鸥
		[2] = {nTemplate = 3260, nLevel = -1, nSeries = -1},		-- 宝箱机关
		[3] = {nTemplate = 3261, nLevel = -1, nSeries = -1},		-- 真宝箱
		[4] = {nTemplate = 3298, nLevel = -1, nSeries = -1},		-- 机关1
		[5] = {nTemplate = 3299, nLevel = -1, nSeries = -1},		-- 机关2
		[6] = {nTemplate = 3300, nLevel = -1, nSeries = -1},		-- 机关3
		[7] = {nTemplate = 3192, nLevel = -1, nSeries =	-1},		-- 机关人爆伤害
		[8] = {nTemplate = 3193, nLevel = -1, nSeries =	-1},		-- 机关人反弹
		[9] = {nTemplate = 3194, nLevel = -1, nSeries =	-1},		-- 机关人普通
		[10] = {nTemplate = 3176, nLevel = -1, nSeries =	-1},		-- 机关人剑段
		[11] = {nTemplate = 3256, nLevel = -1, nSeries =	-1},		-- 障碍
		[12] = {nTemplate = 3242, nLevel = -1, nSeries =	-1},		-- 机关狼
		[13] = {nTemplate = 6563, nLevel = -1, nSeries = -1}, 		-- 情花
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 2, "husong", "45_cuixiaoou"},		-- 崔鸥
				{XoyoGame.ADD_NPC, 11, 6, 0, "tiezha", "45_zhangai"},		-- 障碍
				{XoyoGame.CHANGE_TRAP, "45_trap", {63232 / 32, 134336 / 32}},
				{XoyoGame.MOVIE_DIALOG, -1, "这阴森的地宫中居然有个小女孩！太诡异了。"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
				{XoyoGame.ADD_NPC, 13, 6, 0, "qinghua", "45_qinghua"},		-- 情花
			},
			tbUnLockEvent = {},
		},
		[2] = {nTime = 480, nNum = 1,		-- 总时间
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "husong"},
				{XoyoGame.DEL_NPC, "jiguan"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3280>：哇……这里好可怕！爸爸妈妈，小鸥不敢乱跑了，小鸥要回家……"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 5, nNum = 0,		-- 任务开始
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3280>：听说这里面有很多好玩的东西，哥哥姐姐，你们能陪我一起玩会吗？"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TARGET_INFO, -1, "Chơi cùng Thúy Tiểu Âu"},
			},
			tbUnLockEvent = {},
		},
		[4] = {nTime = 0, nNum = 1,		--	开始护送
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.CHANGE_NPC_AI, "husong", XoyoGame.AI_MOVE, "lv4_45_cuixiaoou_1", 4, 0, 1},	-- 护送AI
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3280>：啊，那边有个好奇怪的石像！哥哥姐姐，你们去调查一下吧。"},
				{XoyoGame.ADD_NPC, 4, 1, 5, "jiguan", "45_jiguan_1"},		-- 机关1	
			},
		},
		[5] = {nTime = 0, nNum = 1,
			tbPrelock = {4},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.ADD_NPC, 9, 12, 6, "guaiwu", "45_jiguanren_1"},		-- 机关人
			},
		},
		[6] = {nTime = 0, nNum = 12,
			tbPrelock = {5},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "tiezha"},
				{XoyoGame.CHANGE_TRAP, "45_trap", nil},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3280>：哥哥姐姐好厉害哇！铁门开了耶，继续走吧。"},
				{XoyoGame.CHANGE_NPC_AI, "husong", XoyoGame.AI_MOVE, "lv4_45_cuixiaoou_2", 7, 0, 1},	-- 护送AI
			},
		},
		[7] = {nTime = 0, nNum = 1,
			tbPrelock = {6},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3280>：咦？发现宝藏咯！哥哥姐姐快去打开吧。"},
				{XoyoGame.ADD_NPC, 2, 1, 8, "jiguan", "45_baoxiang_2"},		-- 宝箱
				{XoyoGame.ADD_NPC, 3, 2, 16, "jiguan", "45_kongbaoxiang_2"},		-- 空宝箱
			},
		},
		[8] = {nTime = 0, nNum = 1,
			tbPrelock = {7},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.ADD_NPC, 9, 6, 9, "guaiwu", "45_jiguanren_2"},		-- 机关人
				{XoyoGame.ADD_NPC, 7, 2, 9, "guaiwu", "45_jiguanren_2_bao"},		-- 机关人
			},
		},
		[9] = {nTime = 0, nNum = 8,
			tbPrelock = {8},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3280>：原来是陷阱……吓死小鸥了。哥哥姐姐，你们没受伤吧？"},
				{XoyoGame.CHANGE_NPC_AI, "husong", XoyoGame.AI_MOVE, "lv4_45_cuixiaoou_3", 10, 0, 1},	-- 护送AI
			},
		},
		[10] = {nTime = 0, nNum = 1,
			tbPrelock = {9},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3280>：啊？又有一个奇怪的雕像！哥哥姐姐，你们敢去调查么？"},
				{XoyoGame.ADD_NPC, 5, 1, 11, "jiguan", "45_jiguan_2"},		-- 机关2
			},
		},
		[11] = {nTime = 0, nNum = 1,
			tbPrelock = {10},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.ADD_NPC, 9, 10, 12, "guaiwu", "45_jiguanren_3"},		-- 机关人
				{XoyoGame.ADD_NPC, 8, 2, 12, "guaiwu", "45_jiguanren_3_fandan"},		-- 机关人
			},
		},
		[12] = {nTime = 0, nNum = 12,
			tbPrelock = {11},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3280>：哥哥姐姐们好强啊！又把这些怪东西收拾了。(*^__^*) 嘻嘻……"},
				{XoyoGame.CHANGE_NPC_AI, "husong", XoyoGame.AI_MOVE, "lv4_45_cuixiaoou_4", 13, 0, 1},	-- 护送AI
			},
		},
		[13] = {nTime = 0, nNum = 1,
			tbPrelock = {12},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3280>：啊？好像到尽头了，台子上又有个奇怪的雕像耶……"},
				{XoyoGame.ADD_NPC, 6, 1, 14, "jiguan", "45_jiguan_shibei"},		-- 机关2
			},
		},
		[14] = {nTime = 0, nNum = 1,
			tbPrelock = {13},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.ADD_NPC, 12, 1, 15, "guaiwu", "45_jiguanjulang"},		-- 机关狼
				{XoyoGame.ADD_NPC, 10, 3, 0, "guaiwu", "45_jiguanren_4"},		-- 机关人
			},
		},
		[15] = {nTime = 0, nNum = 1,
			tbPrelock = {14},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "husong"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.FINISH_ACHIEVE, -1,209}, -- achieve 
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3280>：耶！哥哥姐姐，你们太棒了！啊？要回家了，不然会被妈妈骂的。哥哥姐姐下次要来我家做客哦。"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "45_gouhuo"},
			},
		},
		[16] = {nTime = 0, nNum = 2,
			tbPrelock = {7},
			tbStartEvent = {},
			tbUnLockEvent = {},
		},
	},
}

-- 
tbRoom[46] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 4,						-- 房间等级(1~5)
	nMapIndex		= 4,						-- 地图组的索引
	tbBeginPoint	= {66624 / 32, 131904 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3265, nLevel = -1, nSeries = -1},		-- 护送NPC
		[2] = {nTemplate = 3256, nLevel = -1, nSeries =	-1},		-- 障碍
		[3] = {nTemplate = 3252, nLevel = -1, nSeries =	-1},		-- 机关
		[4] = {nTemplate = 3253, nLevel = -1, nSeries =	-1},		-- 机关
		[5] = {nTemplate = 3192, nLevel = -1, nSeries =	-1},		-- 狂暴机关人_爆伤害
		[6] = {nTemplate = 3194, nLevel = -1, nSeries =	-1},		-- 狂暴机关人_普通
		[7] = {nTemplate = 3189, nLevel = -1, nSeries =	-1},		-- 机关巨狼_高速无形蛊
		[8] = {nTemplate = 3190, nLevel = -1, nSeries =	-1},		-- 机关巨狼_雷阵
		[9] = {nTemplate = 3191, nLevel = -1, nSeries =	-1},		-- 机关巨狼_普通
		[10] = {nTemplate = 6563, nLevel = -1, nSeries = -1}, 		-- 情花
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 2, "husong", "46_xiaofei"},
				{XoyoGame.ADD_NPC, 2, 3, 0, "zhangai1", "46_luzhang"},
				{XoyoGame.CHANGE_TRAP, "46_trap", {64320 / 32, 132320 / 32}}, 
				{XoyoGame.MOVIE_DIALOG, -1, "隐约听到这地宫中有少女的求救声，不知道是不是幻觉，姑且过去看看吧。"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
				{XoyoGame.ADD_NPC, 10, 6, 0, "qinghua", "46_qinghua"},		-- 情花
			},
			tbUnLockEvent = {},
		},
		[2] = {nTime = 480, nNum = 1,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "jiguan"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "husong"},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3265>：……………………"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 0, nNum = 2,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3265>：“人家好不容易才从雪山逃出来，没想到又被关在这了，这些机关人好可怕。呜……我可不想成为这里的一堆白骨哇……你们快帮帮我吧。”"},
				{XoyoGame.ADD_NPC, 3, 1, 3, "jiguan", "46_shibei_1"},				-- 机关
				{XoyoGame.ADD_NPC, 4, 1, 3, "jiguan", "46_shibei_2"},				-- 机关
				{XoyoGame.ADD_NPC, 5, 12, 0, "guaiwu", "46_kuangbaojiguanren"},		-- 怪物
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				{XoyoGame.TARGET_INFO, -1, "Giải cứu Hiểu Phi bị mắc kẹt"},
			},
			tbUnLockEvent = {},
		},
		[4] = {nTime = 0, nNum = 1,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3265>：“铁门消失了，赶紧离开这鬼地方吧。”"},
				{XoyoGame.CHANGE_NPC_AI, "husong", XoyoGame.AI_MOVE, "lv4_46_xiaofei", 4, 100, 1},	-- 护送AI
				{XoyoGame.DEL_NPC, "zhangai1"},
				{XoyoGame.ADD_NPC, 8, 28, 0, "guaiwu", "46_jiguanjulang"},		-- 怪物
				{XoyoGame.CHANGE_TRAP, "46_trap", nil},
				{XoyoGame.TARGET_INFO, -1, "Bảo vệ Hiểu Phi"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "husong"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3265>：“你们真是好心人，听说再往前走就是逍遥谷的最深处了，不知道有没有机会见到传说中英俊潇洒的谷主呢，先走一步了哟。”\n说完，这位冒失的大小姐又不知跑到什么地方去了……"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "46_gouhuo"},
			},
		},
	}
}


tbRoom[47] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 4,						-- 房间等级(1~5)
	nMapIndex		= 4,						-- 地图组的索引
	tbBeginPoint	= {65088 / 32, 135744 / 32},-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3182, nLevel = -1, nSeries =	-1},		-- 闯谷贼_移动快
		[2] = {nTemplate = 3185, nLevel = -1, nSeries =	-1},		-- 闯谷贼_全屏回血
		[3] = {nTemplate = 3183, nLevel = -1, nSeries =	-1},		-- 闯谷贼_普通
		[4] = {nTemplate = 3188, nLevel = -1, nSeries =	-1},		-- 闯谷贼头领
		[5] = {nTemplate = 3291, nLevel = -1, nSeries =	-1},		-- 闯谷贼_普通
		[6] = {nTemplate = 3292, nLevel = -1, nSeries =	-1},		-- 闯谷贼头领
		[7] = {nTemplate = 3242, nLevel = -1, nSeries =	-1},		-- 完美的机关巨狼
		[8] = {nTemplate = 3261, nLevel = -1, nSeries =	-1},		-- 宝箱
		[9] = {nTemplate = 6563, nLevel = -1, nSeries = -1}, 		-- 情花
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				
				{XoyoGame.MOVIE_DIALOG, -1, "居然找到了地宫中的宝藏库，不过好像已经有人捷足先登了，先教训一下这些家伙吧！"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
				{XoyoGame.ADD_NPC, 9, 6, 0, "qinghua", "47_qinghua"},		-- 情花
			},
			tbUnLockEvent = {},
		},
		[2] = {nTime = 480, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "guaiwu2"},
				{XoyoGame.DEL_NPC, "guaiwu3"},
				{XoyoGame.DEL_NPC, "jiguan"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[3]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[9]:Close()"},
				{XoyoGame.MOVIE_DIALOG, -1, "这些鬼东西凶猛无比，还是速速离开此地为妙。"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 0, nNum = 20,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 3, "guaiwu", "47_chuangguzei_1"},	
				{XoyoGame.ADD_NPC, 2, 1, 3, "guaiwu", "47_chuangguzei_2"},	
				{XoyoGame.ADD_NPC, 3, 18, 3, "guaiwu", "47_chuangguzei_3"},	
				{XoyoGame.TARGET_INFO, -1, "Đánh bại 20 kẻ lạ đột nhập"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
			},
			tbUnLockEvent = {}
		},
		[4] = {nTime = 0, nNum = 2,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "从地宫深入传来搏斗的声音，前方定有蹊跷，过去看看。"},
				{XoyoGame.ADD_NPC, 5, 8, 10, "guaiwu2", "47_chuangguzei_4"},
				{XoyoGame.ADD_NPC, 6, 2, 10, "guaiwu3", "47_chuangguzeitouling"},
				{XoyoGame.ADD_NPC, 7, 2, 4, "guaiwu", "47_wanmeidejiguanjulang"},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại Cơ Quan Cự Lang Hoàn Mỹ"},
				{XoyoGame.CHANGE_NPC_AI, "guaiwu2", XoyoGame.AI_ATTACK, "", 0},	-- 改变阵营AI
				{XoyoGame.CHANGE_NPC_AI, "guaiwu3", XoyoGame.AI_ATTACK, "", 0},	-- 改变阵营AI
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3292>：“几位大侠真是仗义！行走江湖，最重要的就是一个“<color=gold>义<color>”字，这里的宝箱就留给你们作为谢礼吧。兄弟们，快出来谢谢几位救命恩人！”"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 4, 150, "gouhuo", "47_gouhuo"},
			},
		},
		[5] = {nTime = 0, nNum = 0,
			tbPrelock = {4},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 8, 6, 0, "jiguan", "47_baoxiang"},	
			},
			tbUnLockEvent = {},
		},
		[6] = {nTime = 3, nNum = 0,
			tbPrelock = {4},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.ADD_NPC, 2, 6, 10, "guaiwu2", "47_chuangguzei_5"},	
				{XoyoGame.ADD_NPC, 3, 6, 10, "guaiwu2", "47_chuangguzei_5"},
				{XoyoGame.ADD_NPC, 6, 2, 10, "guaiwu3", "47_chuangguzei_5"},
				{XoyoGame.CHANGE_NPC_AI, "guaiwu2", XoyoGame.AI_ATTACK, "", 0},	-- 改变阵营AI
				{XoyoGame.CHANGE_NPC_AI, "guaiwu3", XoyoGame.AI_ATTACK, "", 0},	-- 改变阵营AI		
			},
		},
		[7] = {nTime = 3, nNum = 0,
			tbPrelock = {6},
			tbStartEvent = {},
			tbUnLockEvent = {},
		},
		[8] = {nTime = 8, nNum = 0,
			tbPrelock = {7},
			tbStartEvent = 
			{
				{XoyoGame.SEND_CHAT, "guaiwu2", "谢大侠救命之恩！"},
			},
			tbUnLockEvent = {},
		},
		[9] = {nTime = 0, nNum = 0,
			tbPrelock = {8},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.BLACK_MSG, -1, "贼的话都当真！不知道行走江湖最重要的是一个“<color=gold>诈<color>”字么？"},
				{XoyoGame.SEND_CHAT, "guaiwu3", "小的们，上！干掉他们！"},
				{XoyoGame.TARGET_INFO, -1, "Nguy hiêm! Đánh bại tất cả bọn cướp!"},
				{XoyoGame.CHANGE_NPC_AI, "guaiwu2", XoyoGame.AI_ATTACK, "", 5},	-- 改变阵营AI
				{XoyoGame.CHANGE_NPC_AI, "guaiwu3", XoyoGame.AI_ATTACK, "", 5},	-- 改变阵营AI
			},
		},
		[10] = {nTime = 0, nNum = 24,
			tbPrelock = {9},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "出来走江湖真是大意不得啊！"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.FINISH_ACHIEVE, -1,210}, -- achieve 
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
			},
		},
	}
}

-- PK房间
tbRoom[48] = 
{
	fnPlayerGroup 	= BaseRoom.PKGroup,			-- PK分组
	fnDeath			= BaseRoom.PKDeath,			-- PK房间死亡脚本;
	fnWinRule		= BaseRoom.PKWinRule,		-- PK胜利条件
	nRoomLevel		= 1,						-- 房间等级(1~5)
	nMapIndex		= 1,						-- 地图组的索引
	tbBeginPoint	= {{65696/32, 121984/32}, {65600/32, 122144/32}},-- 起始点，
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "对面似乎也是对逍遥谷充满好奇心的人，也不知道他们的功夫怎么样，去试他一试吧。"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, "Quân ta tiêu diệt: 0\nQuân địch tiêu diệt: 0"},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 480, nNum = 0,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian PK: %s<color>", 2},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_CAMP},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self:CheckWinner()"},		-- 手动判胜负
				{XoyoGame.DO_SCRIPT, "self:TeamBlackMsg(self.tbWinner, '看来还是我们队伍技高一筹啊')"};
				{XoyoGame.DO_SCRIPT, "self:TeamBlackMsg(self.tbLoser, '对方实力太强，我们还是快溜吧')"};
			},
		},
	}
}

-- 宝箱房间
tbRoom[49] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 4,						-- 房间等级(1~5)
	nMapIndex		= 4,						-- 地图组的索引
	tbBeginPoint	= {65696 / 32, 121984 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3261, nLevel = -1, nSeries = -1},		-- 箱子
		[2] = {nTemplate = 6563, nLevel = -1, nSeries = -1}, 		-- 情花
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "宝藏！哈哈！终于让我们找到了！不过……好像还有其他人也找到了这里……"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
				{XoyoGame.ADD_NPC, 2, 6, 0, "qinghua", "49_qinghua"},		-- 情花
			},
			tbUnLockEvent = {},
		},
		[2] = {nTime = 480, nNum = 0,
			tbPrelock = {1},
			tbStartEvent = 
			{},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "休息好了，准备迎接下一场挑战吧。"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbTeam[2].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
			},
		},
		[3] = {nTime = 0, nNum = 0,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 10, 0, "xiangzi", "49_baoxiang"},
				{XoyoGame.TARGET_INFO, -1, "Mở rương báu"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				
			},
			tbUnLockEvent = {},
		},
		[4] = {nTime = 120, nNum = 0,
			tbPrelock = {3},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "xiangzi"},
				{XoyoGame.ADD_NPC, 1, 10, 0, "xiangzi", "49_baoxiang"},
			}, 
		},
		[5] = {nTime = 120, nNum = 0,
			tbPrelock = {4},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "xiangzi"},
				{XoyoGame.ADD_NPC, 1, 12, 0, "xiangzi", "49_baoxiang"},
			},
		},
		[6] = {nTime = 120, nNum = 0,
			tbPrelock = {5},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "xiangzi"},
				{XoyoGame.ADD_NPC, 1, 12, 0, "xiangzi", "49_baoxiang"},
			},
		},
		[7] = {nTime = 60, nNum = 0,
			tbPrelock = {6},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "xiangzi"},
				{XoyoGame.ADD_NPC, 1, 12, 0, "xiangzi", "49_baoxiang"},
			},
		},
	}
}

tbRoom[50] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 4,						-- 房间等级(1~5)
	nMapIndex		= 4,						-- 地图组的索引
	tbBeginPoint	= {61312 / 32, 121920 / 32},-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3243, nLevel = 1, nSeries =	-1},		-- 兔子
		[2] = {nTemplate = 3244, nLevel = -1, nSeries =	4},		-- 夏小倩
		[3] = {nTemplate = 3241, nLevel = -1, nSeries =	1},		-- 木超
		[4] = {nTemplate = 6563, nLevel = -1, nSeries = -1}, 		-- 情花
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				
				{XoyoGame.MOVIE_DIALOG, -1, "好大一间农舍，想必是个大户人家，不过主人哪去了呢？"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
				{XoyoGame.ADD_NPC, 4, 6, 0, "qinghua", "50_qinghua"},		-- 情花
			},
			tbUnLockEvent = {},
		},
		[2] = {nTime = 480, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "boss"},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3244>：“算了……火也发过了，架也打了，为了几只兔子没必要弄出人命。我去山里再抓两只来，你们好自为之。”"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 60, nNum = 0,		-- 计时刷boss
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3244>：“你们是什么人？想对我的兔兔干什么？”"}
			},
		},
		[4] = {nTime = 0, nNum = 6,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "院子里蹦出几只兔子，看上去十分肥美，味道一定不错！趁主人不在，偷偷猎几只先"},
				{XoyoGame.ADD_NPC, 1, 6, 4, "guaiwu", "50_tuzi"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},	
				{XoyoGame.TARGET_INFO, -1, "Lấy một ít thịt thỏ để nhậu nào"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3244>：“你们是什么人？居然连这么可爱的兔兔都下得了手！太可恶了！”"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[3]:Close()"},
			},
		},
		[5] = {nTime = 0, nNum = 1,
			tbPrelock = {{3,4}},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 2, 1, 5, "boss", "50_xiaxiaoqian"},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại Hạ Tiểu Sảnh"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "boss"},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3244>：为什么……为什么……要伤害我的小兔……"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[6]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "50_gouhuo"},
			},
		},
		[6] = {nTime = 100, nNum = 0,		-- 计时改阵营
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3244>：“好累啊，休息一会先o(∩_∩)o...”"},
				{XoyoGame.CHANGE_NPC_AI, "boss", XoyoGame.AI_ATTACK, "", 0},	-- 改变阵营AI
			},
		},
		[7] = {nTime = 15, nNum = 0,		-- 计时对话
			tbPrelock = {6},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3241>：“倩倩，俺给你送元宵来了。”\n<npc=3244>：“超哥，有人欺负我!!”\n<npc=3241>：“嘿！什么人这么大胆！！不想活了？”"},
				{XoyoGame.ADD_NPC, 3, 1, 0, "boss", "50_xiaxiaoqian"},
				{XoyoGame.CHANGE_NPC_AI, "boss", XoyoGame.AI_ATTACK, "", 0},	-- 改变阵营AI
			},
		},
		[8] = {nTime = 5, nNum = 0,		-- 计时改阵营
			tbPrelock = {7},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.CHANGE_NPC_AI, "boss", XoyoGame.AI_ATTACK, "", 5},	-- 改变阵营AI
			},
		},
	}
}

tbRoom[51] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 4,						-- 房间等级(1~5)
	nMapIndex		= 4,						-- 地图组的索引
	tbBeginPoint	= {61056 / 32, 142176 / 32},-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3245, nLevel = -1, nSeries =	3},		-- 胡坤
		[2] = {nTemplate = 3242, nLevel = -1, nSeries =	-1},		-- 完美机关狼
		[3] = {nTemplate = 3190, nLevel = -1, nSeries =	-1},		-- 剧毒机关狼
		[4] = {nTemplate = 3302, nLevel = -1, nSeries =	-1},		-- 胡坤分身
		[5] = {nTemplate = 6563, nLevel = -1, nSeries = -1}, 		-- 情花
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				
				{XoyoGame.MOVIE_DIALOG, -1, "一股强烈的杀气迎面扑来，看来前方绝不会有什么好角色在等着我们。"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
				{XoyoGame.ADD_NPC, 5, 6, 0, "qinghua", "51_qinghua"},		-- 情花
			},
			tbUnLockEvent = {},
		},
		[2] = {nTime = 480, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},	
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3245>：“没想到你们就这点能耐，不陪你们玩了……影遁！”"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 60, nNum = 0,		-- 刷怪
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.BLACK_MSG, -1	, "胡坤：“杀戮吧！我的杰作！”"},
				{XoyoGame.ADD_NPC, 2, 4, 0, "fenshen", "51_xiaobin"},
			},
		},
		[4] = {nTime = 30, nNum = 0,		-- 删怪
			tbPrelock = {3},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "fenshen"},
			},
		},
		[5] = {nTime = 240, nNum = 0,		-- 刷怪
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.BLACK_MSG, -1, "胡坤：“禁术！影分身！”"},
				{XoyoGame.ADD_NPC, 4, 4, 0, "fenshen2", "51_xiaobin"},
			},
		},
		[6] = {nTime = 20, nNum = 0,		-- 删怪
			tbPrelock = {5},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "fenshen2"},
			},
		},
		[7] = {nTime = 0, nNum = 1,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3245>：“能来到这里，证明你们不是泛泛之辈。来吧！让我将你们的身体改造成最杰出的作品吧！”"},
				{XoyoGame.ADD_NPC, 1, 1, 7, "guaiwu", "51_hukun"},	
				{XoyoGame.TARGET_INFO, -1, "Đánh bại Hồ Khôn"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				-- {XoyoGame.FINISH_ACHIEVE, -1,202}, -- achieve 胡坤
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3245>：“可恶……难道是我的作品还不够完美……等着瞧！下次要让你们见识到真正的恐怖……禁术！影遁！”\n转眼间，这个神秘的狂徒已遁去无踪……经历了一场恶战的我们还是先休息休息，烤烤火吧。"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[3]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[5]:Close()"},
				{XoyoGame.DEL_NPC, "fenshen"},
				{XoyoGame.DEL_NPC, "fenshen2"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "51_gouhuo"},
			},
		},
	}
}


-- 等级5 房间 

-- 52, 54
tbRoom[52] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 5,						-- 房间等级(1~5)
	nMapIndex		= 5,						-- 地图组的索引
	tbBeginPoint	= {50080 / 32, 105984 / 32},-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3195, nLevel = -1, nSeries = -1},		-- 远征军
		[2] = {nTemplate = 3196, nLevel = -1, nSeries =	-1},		-- 远征军
		[3] = {nTemplate = 3197, nLevel = -1, nSeries =	-1},		-- 督军
		[4] = {nTemplate = 3246, nLevel = -1, nSeries =	-1},		-- 监军
		[5] = {nTemplate = 6563, nLevel = -1, nSeries = -1}, 		-- 情花
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "这儿环境不错，是个休息的好地方。"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
				{XoyoGame.ADD_NPC, 5, 6, 0, "qinghua", "52_qinghua"},		-- 情花
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "督军：“搜，给我仔细的搜！一定要找到传说中的魔枪！什么？前面有人？抓过来问问!”"}
			},
		},
		[2] = {nTime = 600, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "监军：“什么，侦查队那边有魔枪的线索！算你们运气好，今天就放过你们了。兄弟们，撤！”"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.DEL_NPC, "guaiwu"},	
			},
		},
		[3] = {nTime = 0, nNum = 34,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 4, 3, "guaiwu", "52_yuanzhengjun_1"},
				{XoyoGame.ADD_NPC, 2, 26, 3, "guaiwu", "52_yuanzhengjun_2"},	
				{XoyoGame.ADD_NPC, 4, 4, 3, "guaiwu", "52_dujun"},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại 30 Quân Viễn Chinh, 4 Đốc quân"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = 
			{
			},
		},
		[4] = {nTime = 0, nNum = 1,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 3, 1, 4, "guaiwu", "52_jianjun"},
				{XoyoGame.MOVIE_DIALOG, -1, "监军：“没用的东西，几个毛贼都搞不定！非得要本大爷亲自动手么！”"},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại Giám Quân"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "52_gouhuo"},
				{XoyoGame.MOVIE_DIALOG, -1, "监军：“你们这群毛贼，竟敢在太岁头上动土，胆子不小。你们等着，看我以后怎么收拾你们！”"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
			},
	   }
  },
 }

tbRoom[54] = {}
CopyTable(tbRoom[52], tbRoom[54])
tbRoom[54].tbBeginPoint	= {43776 / 32, 89024 / 32};
tbRoom[54].LOCK[3].tbStartEvent[1] = {XoyoGame.ADD_NPC, 1, 4, 3, "guaiwu", "54_yuanzhengjun_1"};
tbRoom[54].LOCK[3].tbStartEvent[2] = {XoyoGame.ADD_NPC, 2, 26, 3, "guaiwu", "54_yuanzhengjun_2"};
tbRoom[54].LOCK[3].tbStartEvent[3] = {XoyoGame.ADD_NPC, 4, 4, 3, "guaiwu", "54_dujun"};
tbRoom[54].LOCK[4].tbStartEvent[1] = {XoyoGame.ADD_NPC, 3, 1, 4, "guaiwu", "54_jianjun"};
tbRoom[54].LOCK[4].tbUnLockEvent[1] = {XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "54_gouhuo"};


tbRoom[53] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 5,						-- 房间等级(1~5)
	nMapIndex		= 5,						-- 地图组的索引
	tbBeginPoint	= {45856 / 32, 95360 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3204, nLevel = -1, nSeries = -1},		-- 捕快
		[2] = {nTemplate = 3205, nLevel = -1, nSeries =	-1},		-- 武装捕快
		[3] = {nTemplate = 3208, nLevel = -1, nSeries =	-1},		-- 寻宝者（护送）
		[4] = {nTemplate = 3260, nLevel = -1, nSeries =	-1},		-- 宝箱机关
		[5] = {nTemplate = 3206, nLevel = -1, nSeries =	-1},		-- 追踪者
		[6] = {nTemplate = 3207, nLevel = -1, nSeries =	-1},		-- 寻宝者（战斗）
		[7] = {nTemplate = 3318, nLevel = 35, nSeries =	-1},		-- 宝箱
		[8] = {nTemplate = 6563, nLevel = -1, nSeries = -1}, 		-- 情花
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 3, 1, 10, "husong", "53_xunbaozhe_husong"},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3208>：你们可不可以不要突然出现啊，差点没被水给噎死。哎，继续喝点水。"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.ADD_NPC, 8, 6, 0, "qinghua", "53_qinghua"},		-- 情花
			},
			tbUnLockEvent = {},
		},
		[2] = {nTime = 600, nNum = 0,      -- 总计时
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "这世道变化也忒大了吧。我们都在这江湖上混了这么久了，竟然连这点事都做不好。哎！这是什么江湖啊！"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.DEL_NPC, "husong"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "jiguan"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[3]:Close()"},
				
			},
		},
		[3] = {nTime = 5, nNum = 0,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3208>：我们相聚就是缘分呐。既然有缘分就劳烦各位送我到前方的亭子那休息下吧，要知道我在谷里也走了很久了。"},
			},
			tbUnLockEvent = {},
		},
		[4] = {nTime = 0, nNum = 1,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 15, 0, "guaiwu3", "53_guaiwu_1"},
				{XoyoGame.CHANGE_NPC_AI, "husong", XoyoGame.AI_MOVE, "lv5_53_xunbaozhe_1", 4, 100, 0},	-- 护送AI
				{XoyoGame.TARGET_INFO, -1, "Hộ tống Tầm Bảo Giả"},
			},
			tbUnLockEvent = {},
		},
		[5] = {nTime = 5, nNum = 0,
			tbPrelock = {4},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3208>：我发现前方的高地上有个箱子，说不定里面有宝藏哦，你们要不要也一起去看看啊。"},
				{XoyoGame.TARGET_INFO, -1, "Bảo vệ Tầm Bảo Giả"},
			},
		},
		[6] = {nTime = 0, nNum = 1,
			tbPrelock = {5},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 2, 8, 0, "guaiwu4", "53_guaiwu_2"},
				{XoyoGame.CHANGE_NPC_AI, "husong", XoyoGame.AI_MOVE, "lv5_53_xunbaozhe_2", 6, 100, 0},
			},
			tbUnLockEvent = {},
		},
		[7] = {nTime = 0, nNum = 1,
			tbPrelock = {6},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 4, 1, 7, "jiguan", "53_jiguan"},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3208>：各位，我实在走不动了，麻烦你们去看看箱子里面装着什么吧。"},
				{XoyoGame.TARGET_INFO, -1, "Mở rương"},
			},
			tbUnLockEvent = {},
		},
		[8] = {nTime = 0, nNum = 2,
			tbPrelock = {7},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 5, 2, 8, "guaiwu", "53_boss"},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3206>：呔，放下你们手中的圣物！！你们这群强盗，准备好受死吧！！"},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại 2 Truy Tông Giả"},
			},
			tbUnLockEvent = {},
		},
		[9] = {nTime = 0, nNum = 1,
			tbPrelock = {8},
			tbStartEvent = 
			{
				{XoyoGame.DEL_NPC, "husong"},
				{XoyoGame.ADD_NPC, 6, 1, 9, "guaiwu", "53_xunbaozhe_zhandou"},
				{XoyoGame.MOVIE_DIALOG, -1, "就在我们努力击退追踪者之时，我们身后传来一阵阴笑。\n<npc=3206>：可恶，没想到你们这群帮凶还真了得。不过俺们是不会放弃的，拼死也要保护圣物。你们接招吧，C4迦楼罗！\n夺回圣物也许可以平息他们的怒火。"},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại Tầm Bảo Giả"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.MOVIE_DIALOG, -1, "虽然击败了寻宝者，但是还是没能制止C4迦楼罗的发动，哎，找个好地方，等着爆炸的风暴把我们带出逍遥谷吧。"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "53_xunbaozhe_zhandou"},
			},
		},
		[10] = {nTime = 0, nNum = 1,
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = {},
		},
		[11] = {nTime = 0, nNum = 23,
			tbPrelock = {10},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 2, 15, 11, "guaiwu", "53_guaiwu_1"},
				{XoyoGame.ADD_NPC, 2, 8, 11, "guaiwu", "53_guaiwu_2"},
				{XoyoGame.DEL_NPC, "guaiwu4"},
				{XoyoGame.DEL_NPC, "guaiwu3"},
				{XoyoGame.BLACK_MSG, -1, "武装捕快：大家一起上啊，把这些帮凶也缉拿归案。"},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại 23 Bổ Khoái Vũ Trang"},
			},
		},
		[12] = {nTime = 0, nNum = 2,
			tbPrelock = {11},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 5, 2, 12, "guaiwu", "53_boss"},
				{XoyoGame.ADD_NPC, 7, 6, 0, "baoxiang", "53_guaiwu_1"},
				{XoyoGame.BLACK_MSG, -1, "不好，有强烈的杀气。"},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại 2 Truy Tông Giả"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3206>：可恶，没想到你们这群帮凶还真了得。不过俺们也是不吃素的，接招吧C4迦楼罗！！\n<playername>:切，我们正愁没法出谷呢，这下好了，可以借着爆炸飞出谷咯。"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},				
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "53_boss"},
			},
		},
	}
}

tbRoom[55] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 5,						-- 房间等级(1~5)
	nMapIndex		= 5,						-- 地图组的索引
	tbBeginPoint	= {46784 / 32, 86432 / 32},-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3199, nLevel = -1, nSeries = -1},		-- 强盗雷阵
		[2] = {nTemplate = 3202, nLevel = -1, nSeries = -1},		-- 强盗回血
		[3] = {nTemplate = 3200, nLevel = -1, nSeries = -1},		-- 强盗普通
		[4] = {nTemplate = 3198, nLevel = -1, nSeries = -1},		-- 强盗内免
		[5] = {nTemplate = 3201, nLevel = -1, nSeries = -1},		-- 强盗外免
		[6] = {nTemplate = 3203, nLevel = -1, nSeries = -1},		-- 强盗头领
		[7] = {nTemplate = 6563, nLevel = -1, nSeries = -1}, 		-- 情花
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "逍遥谷山清水秀，的确是居住佳所。前方有两户人家，过去问问路吧。"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
				{XoyoGame.ADD_NPC, 7, 6, 0, "qinghua", "55_qinghua"},		-- 情花
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 600, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3203>：“你们还算有点能耐，好汉不吃眼前亏！弟兄们，撤！”"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.DEL_NPC, "guaiwu"},	
			},
		},
		[3] = {nTime = 0, nNum = 32,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3203>：“什么？找不到七彩仙丹！把外面那几个路人抓过来问问！”"},
				{XoyoGame.ADD_NPC, 1, 9, 3, "guaiwu", "55_qiangdao_1"},
				{XoyoGame.ADD_NPC, 2, 5, 3, "guaiwu", "55_qiangdao_2"},
				{XoyoGame.ADD_NPC, 3, 18, 3, "guaiwu", "55_qiangdao_3"},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại 32 Cường Đạo"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				
			},
			tbUnLockEvent = {},
		},
		[4] = {nTime = 0, nNum = 2,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3203>：“格老子！还有点实力嘛。大爷我来会会你们！”"},
				{XoyoGame.ADD_NPC, 4, 4, 0, "guaiwu", "55_qiangdao_4"},
				{XoyoGame.ADD_NPC, 5, 4, 0, "guaiwu", "55_qiangdao_5"},
				{XoyoGame.ADD_NPC, 6, 2, 4, "guaiwu", "55_qiangdaotouling"},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại 2 Thủ Lĩnh Cường Đạo"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "收拾了一帮武林中的败类，心中无比畅快。休息一下，准备离谷吧。"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.DEL_NPC, "guaiwu"},	
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "55_gouhuo"},
			},
		},
	}
}

tbRoom[56] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 5,						-- 房间等级(1~5)
	nMapIndex		= 5,						-- 地图组的索引
	tbBeginPoint	= {51840 / 32, 92544 / 32},-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3209, nLevel = -1, nSeries = -1},		-- 曹操
		[2] = {nTemplate = 3235, nLevel = -1, nSeries =	-1},		-- 周瑜
		[4] = {nTemplate = 3236, nLevel = -1, nSeries =	-1},		-- 魏兵
		[5] = {nTemplate = 3282, nLevel = -1, nSeries =	-1},		-- 吴兵
		[6] = {nTemplate = 3289, nLevel = -1, nSeries =	-1},		-- 机关
		[8] = {nTemplate = 3228, nLevel = -1, nSeries =	4},			-- 秦仲
		[9] = {nTemplate = 3227, nLevel = -1, nSeries =	2},			-- 紫苑
		[10] = {nTemplate = 6563, nLevel = -1, nSeries = -1}, 		-- 情花
	},
	-- 锁结构
	LOCK = 
	{
	    -- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.MOVIE_DIALOG, -1, "诶，这里是什么地方？只有3个机关人和2个石碑在北方和西方的民屋那杵着，去看看吧。"},
				{XoyoGame.TARGET_INFO, -1, ""},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.ADD_NPC, 10, 6, 0, "qinghua", "56_qinghua"},		-- 情花
			},
			tbUnLockEvent = {},
		},
		[2] = {nTime = 0, nNum = 1,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "这个石碑有点古怪，调查看看。"},
				{XoyoGame.ADD_NPC, 1, 1, 0, "boss1", "56_caocao"},
				{XoyoGame.ADD_NPC, 6, 1, 2, "jiguan", "56_wei_jiguan"},
				{XoyoGame.TARGET_INFO, -1, "Mở cơ quan"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "jiguan"},
				{XoyoGame.DEL_NPC, "boss2"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[3]:Close()"},
			},
		},
		[3] = {nTime = 0, nNum = 1,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 2, 2, 0, "boss2", "56_zhouyu"},
				{XoyoGame.ADD_NPC, 6, 1, 3, "jiguan", "56_shu_jiguan"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "jiguan"},
				{XoyoGame.DEL_NPC, "boss1"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
			},
		},
		[4] = {nTime = 120, nNum = 0,
			tbPrelock = {2},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 4, 30, 0, "guaiwu1", "56_shibing_wei"},
				{XoyoGame.ADD_NPC, 5, 20, 0, "guaiwu2", "56_shibing_shu"},
				{XoyoGame.CHANGE_NPC_AI, "guaiwu2", XoyoGame.AI_ATTACK, "", 5},	-- 改变阵营AI
				{XoyoGame.MOVIE_DIALOG, -1, "一群机关人突然出现还对打起来！！真是有意思。我们也去凑凑热闹吧。"},
				{XoyoGame.TARGET_INFO, -1, "Loại trừ tất cả Ngô Binh"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[10]:Close()"},
			},
			tbUnLockEvent = {},
		},
		[5] = {nTime = 120, nNum = 0,
			tbPrelock = {4},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 4, 27, 0, "guaiwu1", "56_shibing_shu"},
				{XoyoGame.BLACK_MSG, -1, "看样子是魏兵开始大举进攻了。"},
			},
			tbUnLockEvent = {},
		},
		[6] = {nTime = 0, nNum = 2,
			tbPrelock = {5},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 5, 20, 0, "guaiwu2", "56_shibing_wei"},
				{XoyoGame.ADD_NPC, 2, 2, 6, "boss2", "56_zhouyu"},
				{XoyoGame.DEL_NPC, "guaiwu1"},
				{XoyoGame.CHANGE_NPC_AI, "guaiwu2", XoyoGame.AI_ATTACK, "", 5},
				{XoyoGame.CHANGE_NPC_AI, "boss2", XoyoGame.AI_ATTACK, "", 5},
				{XoyoGame.BLACK_MSG, -1, "不好，魏兵在一阵火光之后全都消失了，同时出现大量吴兵。"},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại Thống Lĩnh Ngô Quân"},
			},
			tbUnLockEvent = {},
		},
		[7] = {nTime = 0, nNum = 2,
			tbPrelock = {{6, 10}},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 8, 1, 7, "guaiwu", "56_qinzhong"},
				{XoyoGame.ADD_NPC, 9, 1, 7, "guaiwu", "56_ziyuan"},
				{XoyoGame.DEL_NPC, "guaiwu1"},
				{XoyoGame.DEL_NPC, "guaiwu2"},
				{XoyoGame.DEL_NPC, "boss1"},
				{XoyoGame.DEL_NPC, "boss2"},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3227>：我是说我们的演习为什么会出现错误，原来又是你们这群莫名其妙的家伙在捣乱。上次摧毁我杰作的账还没算呢！！\n<npc=3228>：师妹，别生气。让我们一起教训教训这群狂妄的家伙。"},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại Tử Uyển và Tần Trọng"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},
				{XoyoGame.FINISH_ACHIEVE, -1,212}, -- achieve 
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "56_qinzhong"},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3227>：为什么？？这是为什么？？\n<npc=3228>：师妹等等我！！\n这两位才是莫名其妙呢。"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[11]:Close()"},
			},
		},
		[8] = {nTime = 120, nNum = 0,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 4, 30, 0, "guaiwu1", "56_shibing_wei"},
				{XoyoGame.ADD_NPC, 5, 20, 0, "guaiwu2", "56_shibing_shu"},
				{XoyoGame.CHANGE_NPC_AI, "guaiwu1", XoyoGame.AI_ATTACK, "", 5},	-- 改变阵营AI
				{XoyoGame.MOVIE_DIALOG, -1, "一群机关人突然出现还对打起来！！真是有意思。我们也去凑凑热闹吧。"},
				{XoyoGame.TARGET_INFO, -1, "Loại trừ tất cả Ngụy Binh"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[6]:Close()"},			
			},
			tbUnLockEvent = {},
		},
		[9] = {nTime = 120, nNum = 0,
			tbPrelock = {8},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 4, 27, 0, "guaiwu1", "56_shibing_shu"},
				{XoyoGame.CHANGE_NPC_AI, "guaiwu1", XoyoGame.AI_ATTACK, "", 5},
				{XoyoGame.BLACK_MSG, -1, "不好，魏兵开始大举进攻了。"},
			},
			tbUnLockEvent = {},
		},
		[10] = {nTime = 0, nNum = 1,
			tbPrelock = {9},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 10, "boss1", "56_caocao"},
				{XoyoGame.CHANGE_NPC_AI, "boss1", XoyoGame.AI_ATTACK, "", 5},
				{XoyoGame.BLACK_MSG, -1, "是时候反攻了。"},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại Thống Lĩnh Kỵ Binh"},
			},
			tbUnLockEvent = {},
		},
		[11] = {nTime = 600, nNum = 0,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 11},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "guaiwu1"},
				{XoyoGame.DEL_NPC, "guaiwu2"},
				{XoyoGame.DEL_NPC, "boss1"},
				{XoyoGame.DEL_NPC, "boss2"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[7]:Close()"},
				{XoyoGame.MOVIE_DIALOG, -1, "这里就是什么地方？到处都是乱七八糟的玩意。真是莫名其妙。"},
			},
		},
	}
}

tbRoom[57] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 5,						-- 房间等级(1~5)
	nMapIndex		= 5,						-- 地图组的索引
	tbBeginPoint	= {50592 / 32, 96704 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3305, nLevel = -1, nSeries = -1},		-- 木桩
		[2] = {nTemplate = 3313, nLevel = -1, nSeries = -1},		-- 完美的机关巨狼
		[3] = {nTemplate = 3175, nLevel = -1, nSeries = -1},		-- 劣质机关人
		[4] = {nTemplate = 3306, nLevel = 65, nSeries = -1},		-- 太极
		[5] = {nTemplate = 3311, nLevel = -1, nSeries = -1},		-- 阳仪
		[6] = {nTemplate = 3312, nLevel = -1, nSeries = -1},		-- 阴仪
		[7] = {nTemplate = 3307, nLevel = -1, nSeries = -1},		-- 东宫苍龙
		[8] = {nTemplate = 3308, nLevel = -1, nSeries = -1},		-- 西宫白虎
		[9] = {nTemplate = 3309, nLevel = -1, nSeries = -1},		-- 南宫朱雀
		[10] = {nTemplate = 3310, nLevel = -1, nSeries = -1},		-- 北宫玄武
		[11] = {nTemplate = 3298, nLevel = -1, nSeries = -1},		-- 机关
		[12] = {nTemplate = 6563, nLevel = -1, nSeries = -1}, 		-- 情花
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "有本事就试着从这个机关遍布的区域逃出来吧。\n看来的拿出点真本事了。这里地上有好多坑，得小心有什么厉害的机关。"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.CHANGE_TRAP, "57_trap_1", {50976 / 32, 97568 / 32}},
				{XoyoGame.ADD_NPC, 12, 6, 0, "qinghua", "57_qinghua"},		-- 情花
			},
			tbUnLockEvent = {},
		},
	    [2]= {nTime = 600, nNum = 0,
	    	tbPrelock = {1},
	    	tbStartEvent = 
	    	{
	    		{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 2},
	    	},
	    	tbUnLockEvent = 
	    	{
	    		{XoyoGame.MOVIE_DIALOG, -1, "你们的能力也不过尔尔，杀掉你们会脏了我的手。马上从我的眼前消失！！"},
	    		{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
	    		{XoyoGame.DEL_NPC, "guaiwu"},
	    		{XoyoGame.DEL_NPC, "luzhang"},
	    		{XoyoGame.DEL_NPC, "jiguan"},
	    		{XoyoGame.CHANGE_TRAP, "57_trap_1", nil},
	    		{XoyoGame.CHANGE_TRAP, "57_trap_2", nil},
	    		{XoyoGame.CHANGE_TRAP, "57_trap_3", nil},
	    		{XoyoGame.DO_SCRIPT, "self.tbLock[4]:Close()"},
	    	},
	    },
	    [3] = {nTime = 120, nNum = 0,
	    	tbPrelock = {1},
	    	tbStartEvent = 
	    	{
	    		{XoyoGame.BLACK_MSG, -1, "地下出现了机关，好像很恐怖的样子。"},
				{XoyoGame.TARGET_INFO, -1, "Giữ trong 2 phút"},
	    	},
	    	tbUnLockEvent = 
	    	{
	    		{XoyoGame.DEL_NPC, "guaiwu4"},
	    		{XoyoGame.DEL_NPC, "guaiwu5"},
	    		{XoyoGame.DEL_NPC, "guaiwu6"},
	    		{XoyoGame.CHANGE_TRAP, "57_trap_1", {52192 / 32, 96032 / 32}},
	    		{XoyoGame.CHANGE_TRAP, "57_trap_2", {52192 / 32, 96032 / 32}},
	    	},
	    },
	    [4] = {nTime = 20, nNum = 0,
	    	tbPrelock = {1},
	    	tbStartEvent = 
	    	{
	    		{XoyoGame.ADD_NPC, 1, 5, 0, "guaiwu1", "57_tumuzhuang"},
	    	},
	    	tbUnLockEvent = {},
	    },
	    [5] = {nTime = 20, nNum = 0,
	    	tbPrelock = {4},
	    	tbStartEvent = 
	    	{
	    		{XoyoGame.ADD_NPC, 1, 5, 0, "guaiwu2", "57_tumuzhuang"},
	    	},
	    	tbUnLockEvent = {},
	    },
	    [6] = {nTime = 0, nNum = 1,
	    	tbPrelock = {3},
	    	tbStartEvent = 
	    	{
	    		{XoyoGame.ADD_NPC, 11, 1, 6, "jiguan", "57_jiguan_2"},
	    		{XoyoGame.BLACK_MSG, -1, "前往下片区域看看"},
				{XoyoGame.TARGET_INFO, -1, "Mở cơ quan tiếp theo"},
	    	},
	    	tbUnLockEvent = {},
	    },
	    [7] = {nTime = 120, nNum = 0,
	    	tbPrelock = {6},
	        tbStartEvent = 
	        {
	        	{XoyoGame.BLACK_MSG, -1, "又出现了恐怖的机关巨狼，当心啊。"},
				{XoyoGame.TARGET_INFO, -1, "Giữ trong 2 phút"},
	        },
	        tbUnLockEvent = 
	        {
	        	{XoyoGame.DEL_NPC, "guaiwu1"},
	    		{XoyoGame.DEL_NPC, "guaiwu2"},
	    		{XoyoGame.DEL_NPC, "guaiwu3"},
	        	{XoyoGame.CHANGE_TRAP, "57_trap_2", {53504 / 32, 94880 / 32}},
	    		{XoyoGame.CHANGE_TRAP, "57_trap_3", {53504 / 32, 94880 / 32}},
	        },
	    },
	    [8] = {nTime = 20, nNum = 0,
	    	tbPrelock = {6},
	    	tbStartEvent = 
	    	{
	    		{XoyoGame.ADD_NPC, 2, 1, 0, "guaiwu1", "57_wanmeidejiguanjulang"},
	        	{XoyoGame.CHANGE_NPC_AI, "guaiwu1", XoyoGame.AI_RECYLE_MOVE, "lv5_57_wanmeidejiguanjulang", 0, 0, 120},
	        },
	        tbUnLockEvent = {},
	    },
	    [9] = {nTime = 20, nNum = 0,
	    	tbPrelock = {8},
	    	tbStartEvent = 
	    	{
	    		{XoyoGame.ADD_NPC, 2, 2, 0, "guaiwu2", "57_wanmeidejiguanjulang"},
	        	{XoyoGame.CHANGE_NPC_AI, "guaiwu2", XoyoGame.AI_RECYLE_MOVE, "lv5_57_wanmeidejiguanjulang", 0, 0, 120},
	        },
	        tbUnLockEvent = {},
	    },
	    [10] = {nTime = 20, nNum = 0,
	    	tbPrelock = {9},
	    	tbStartEvent = 
	    	{
	    		{XoyoGame.ADD_NPC, 2, 4, 0, "guaiwu3", "57_wanmeidejiguanjulang"},
	        	{XoyoGame.CHANGE_NPC_AI, "guaiwu3", XoyoGame.AI_RECYLE_MOVE, "lv5_57_wanmeidejiguanjulang", 0, 0, 120},
	        },
	        tbUnLockEvent = {},
	    },
	    [11] = {nTime = 0, nNum = 1,
	    	tbPrelock = {7},
	    	tbStartEvent = 
	    	{
	    		{XoyoGame.ADD_NPC, 11, 1, 11, "jiguan", "57_jiguan_3"},
	    		{XoyoGame.BLACK_MSG, -1, "前往下片区域看看"},
				{XoyoGame.TARGET_INFO, -1, "Mở cơ quan tiếp theo"},
	    	},
	    	tbUnLockEvent = {},
	    },
	    [12] = {nTime = 0, nNum = 20,
	    	tbPrelock = {11},
	    	tbStartEvent = 
	    	{
	    		{XoyoGame.BLACK_MSG, -1, "似乎过关的秘密在这些机关人身上。"},
				{XoyoGame.TARGET_INFO, -1, "Giết 20 Cơ Quan Nhân Thô"},
	    	},
	    	tbUnLockEvent = 
	    	{
	    		{XoyoGame.DEL_NPC, "guaiwu"},
	    		{XoyoGame.CHANGE_TRAP, "57_trap_3", nil},
	    		{XoyoGame.BLACK_MSG, -1, "可以前往机关阵的最后区域了。"},
	    	},
	    },
	    [13] = {nTime = 0, nNum = 1,
	    	tbPrelock = {12},
	    	tbStartEvent = 
	    	{
	    		{XoyoGame.ADD_NPC, 4, 1, 13, "guaiwu", "57_taiji"},
				{XoyoGame.TARGET_INFO, -1, "Tiêu diệt tất cả cơ quan"},
	    	},
	    	tbUnLockEvent = {},
	    },
	    [14] = {nTime = 0, nNum = 2,
	    	tbPrelock = {13},
	    	tbStartEvent = 
	    	{
	    		{XoyoGame.ADD_NPC, 5, 1, 14, "guaiwu", "57_liangyi_yang"},
	    		{XoyoGame.ADD_NPC, 6, 1, 14, "guaiwu", "57_liangyi_yin"},
	    	},
	    	tbUnLockEvent = {},
	    },
	    [15] = {nTime = 0, nNum = 4,
	    	tbPrelock = {14},
	    	tbStartEvent = 
	    	{
	    		{XoyoGame.ADD_NPC, 7, 1, 15, "guaiwu", "57_donggongcanglong"},
	    		{XoyoGame.ADD_NPC, 8, 1, 15, "guaiwu", "57_xigongbaihu"},
	    		{XoyoGame.ADD_NPC, 9, 1, 15, "guaiwu", "57_nangongzhuque"},
	    		{XoyoGame.ADD_NPC, 10, 1, 15, "guaiwu", "57_beigongxuanwu"},
	    	},
	    	tbUnLockEvent = 
	    	{
	    		{XoyoGame.MOVIE_DIALOG, -1, "有惊无险的逃出了机关大阵。胡坤的能力真是令人叫绝，有机会还要会会这位机关大师。"},
	    		{XoyoGame.CHANGE_TRAP, "57_trap_1", nil},
	    		{XoyoGame.CHANGE_TRAP, "57_trap_2", nil},
	    		{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "57_taiji"},
	    		{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},
			    {XoyoGame.CLOSE_INFO, -1},
			    {XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
			    {XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
			},
		},
		[16] = {nTime = 20, nNum = 0,
			tbPrelock = {5},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 5, 0, "guaiwu3", "57_tumuzhuang"},
			},
			tbUnLockEvent = {},
		},
		[17] = {nTime = 20, nNum = 0,
			tbPrelock = {16},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 5, 0, "guaiwu4", "57_tumuzhuang"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu1"},
			},
		},
		[18] = {nTime = 20, nNum = 0,
			tbPrelock = {17},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 5, 0, "guaiwu5", "57_tumuzhuang"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu2"},
			},
		},
		[19] = {nTime = 20, nNum = 0,
			tbPrelock = {18},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 5, 0, "guaiwu6", "57_tumuzhuang"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu3"},
			},
		},
		[20] = {nTime = 20, nNum = 0,
			tbPrelock = {19},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu4"},
				{XoyoGame.DEL_NPC, "guaiwu5"},
				{XoyoGame.DEL_NPC, "guaiwu6"},
			},
		},
		[21] = {nTime = 15, nNum = 0,
			tbPrelock = {11},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 3, 3, 12, "guaiwu", "57_xiaoguai"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},
			},
		},
    }
}

for i = 1, 22 do
	tbRoom[57].LOCK[21 + i] = {nTime = 15, nNum = 0,
		tbPrelock = {20 + i},
		tbStartEvent = 
		{
			{XoyoGame.ADD_NPC, 3, 3, 12, "guaiwu"..i, "57_xiaoguai"},
		},
		tbUnLockEvent = 
		{
			{XoyoGame.DEL_NPC, "guaiwu"..i},
		},
	};
end

tbRoom[58] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 5,						-- 房间等级(1~5)
	nMapIndex		= 5,						-- 地图组的索引
	tbBeginPoint	= {54432 / 32, 103232 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3166, nLevel = -1, nSeries = -1},		-- 叛军士兵1
		[2] = {nTemplate = 3168, nLevel = -1, nSeries = -1},		-- 叛军统领1
		[3] = {nTemplate = 3169, nLevel = -1, nSeries = -1},		-- 叛军统领2
		[4] = {nTemplate = 3226, nLevel = -1, nSeries = -1},		-- 煞大目
		[5] = {nTemplate = 3264, nLevel = -1, nSeries =	-1},		-- 萧不实
		[6] = {nTemplate = 3242, nLevel = -1, nSeries =	-1},		-- 完美的机关巨狼
		[7] = {nTemplate = 3301, nLevel = 35, nSeries =	-1},		-- 强攻NPC
		[8] = {nTemplate = 6563, nLevel = -1, nSeries = -1}, 		-- 情花
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 5, 1, 6, "husong", "58_butou"},
				{XoyoGame.MOVIE_DIALOG, -1, "前面那位……难道是传说中的神捕？"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
				{XoyoGame.ADD_NPC, 8, 6, 0, "qinghua", "58_qinghua"},		-- 情花
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 600, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "husong"},
				{XoyoGame.MOVIE_DIALOG, -1, "这是什么江湖啦！！"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 5, nNum = 0,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3264>：“是的！我就是传说中的萧神捕！你们几个，咋这么眼熟呢？哦，对了，我听说叛军首领煞大目就藏着在这附近，你们要不要和我一起将他捉拿归案？”"},
				
			},
			tbUnLockEvent = {},
		},
		[4] = {nTime = 0, nNum = 1,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.CHANGE_NPC_AI, "husong", XoyoGame.AI_MOVE, "lv5_58_butou", 4, 100, 1},	-- 护送AI
				{XoyoGame.ADD_NPC, 1, 15, 0, "guaiwu", "58_panjunshibing_1"},		-- 刷怪
				{XoyoGame.ADD_NPC, 1, 15, 0, "guaiwu", "58_panjunshibing_2"},		-- 刷怪
				{XoyoGame.TARGET_INFO, -1, "Cùng Tiêu Bất Thực bắt giữ Thủ Lĩnh Phản Quân"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = {},
		},
		[5] = {nTime = 0, nNum = 1,
			tbPrelock = {{4,6}},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "前方传来一声巨吼：“你煞爷爷在此，带种的就过来抓我啊！”\n<npc=3264>：“上次让你跑了，今天我要让你知道我的厉害！”\n只见萧捕头刚拔出刀，便痛苦的倒在地上呻吟到：“哎哟咧，哎哟列，我的肚子啊。你们几个先过去帮我把他拿住了，我去去就来。”说完一溜烟跑了。"},
				{XoyoGame.DEL_NPC, "husong"},
				{XoyoGame.ADD_NPC, 3, 4, 0, "guaiwu", "58_panjunshouling"},		-- 刷怪
				{XoyoGame.ADD_NPC, 4, 1, 5, "guaiwu", "58_shadamu"},		-- 刷怪
				{XoyoGame.TARGET_INFO, -1, "Đánh bại Phản Quân và Sát Đại Mục"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = {},
		},
		[6] = {nTime = 0, nNum = 1,
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3264>：“你们这群小贼给我等着，萧爷爷我吃了10级护甲片再来会你们！”\n说完一溜烟就不见了踪影。突然传来一声巨吼：“萧不实啊萧不实，你也有今天！！”"},
			},
		},
		[7] = {nTime = 0, nNum = 1,
			tbPrelock = {5},
			tbStartEvent = 
			{
				{XoyoGame.BLACK_MSG, -1, "萧不实:主人，我终于拿到了《葵木宝典》了，您就快天下无敌了"},
				{XoyoGame.ADD_NPC, 6, 2, 0, "guaiwu", "58_wanmeidejiguanjulang"},
				{XoyoGame.ADD_NPC, 7, 1, 7, "guaiwu", "58_xiaobushi"},
				{XoyoGame.TARGET_INFO, -1, "Phía Tây, không cho Tiêu Bất Thực thoát"},
			},
			tbUnLockEvent=
			{
				{XoyoGame.MOVIE_DIALOG, -1, "没想到竟然是胡坤的走狗。不过这个机关人也太像真的了。"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "husong"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "58_gouhuo"},
			},
		},
	}
}

tbRoom[59] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 5,						-- 房间等级(1~5)
	nMapIndex		= 5,						-- 地图组的索引
	tbBeginPoint	= {56960 / 32, 95104 / 32},-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3210, nLevel = -1, nSeries = -1},		-- 侍卫迟缓
		[2] = {nTemplate = 3211, nLevel = -1, nSeries = -1},		-- 侍卫混乱
		[3] = {nTemplate = 3212, nLevel = -1, nSeries = -1},		-- 侍卫拉人
		[4] = {nTemplate = 3213, nLevel = -1, nSeries = -1},		-- 侍卫雷阵
		[5] = {nTemplate = 3291, nLevel = -1, nSeries = -1},		-- 闯谷贼
		[6] = {nTemplate = 3292, nLevel = -1, nSeries = -1},		-- 闯谷贼头领
		[7] = {nTemplate = 3317, nLevel = 35, nSeries = -1},		-- 宝箱
		[8] = {nTemplate = 6563, nLevel = -1, nSeries = -1}, 		-- 情花
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "前方杀气极重，最好不要乱动。"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
				{XoyoGame.ADD_NPC, 8, 6, 0, "qinghua", "59_qinghua"},		-- 情花
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 599, nNum = 0,		-- 总计时分支1
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3292>：“弟兄们，看看这附近有什么值钱的东西，全部拿走！”\n<npc=3210>：“前方乃是逍遥谷禁地！擅闯者死！”"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbLock[3]:Close()"},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3292>：“果然有点实力。好汉不吃眼前亏，弟兄们，撤！”"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.DEL_NPC, "guaiwu"},	
			},
		},
		[3] = {nTime = 600, nNum = 0,		-- 总计时分支2
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "shiwei_2"},	
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3210>：“时候不早，诸位也该离谷了。今日就此别过，有缘再见。”"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "59_gouhuo"},
			},
		},
		[4] = {nTime = 0, nNum = 32,		--	杀贼进分支2
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 5, 32, 4, "guaiwu", "59_chuangguzei"},
				{XoyoGame.TARGET_INFO, -1, "Ai giúp? Hãy đưa ra quyết định."},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 8},
				
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbLock[5]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
			},
		},
		[5] = {nTime = 0, nNum = 4,		--	杀侍卫进分支1
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 5, "shiwei", "59_shiwei_1"},
				{XoyoGame.ADD_NPC, 2, 1, 5, "shiwei", "59_shiwei_2"},
				{XoyoGame.ADD_NPC, 3, 1, 5, "shiwei", "59_shiwei_3"},
				{XoyoGame.ADD_NPC, 4, 1, 5, "shiwei", "59_shiwei_4"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 8},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbLock[4]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[3]:Close()"},
			},
		},
		[6] = {nTime = 0, nNum = 4,		--	分支1
			tbPrelock = {5},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 5, 4, 0, "guaiwu", "59_chuangguzei_2"},
				{XoyoGame.ADD_NPC, 6, 4, 6, "guaiwu", "59_chuangguzeitouling"},
				{XoyoGame.ADD_NPC, 7, 3, 0, "baoxiang", "59_chuangguzei_2"},
				{XoyoGame.ADD_NPC, 7, 3, 0, "baoxiang", "59_chuangguzeitouling"},	
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3292>：“这里可是逍遥谷藏宝之地，我们正愁没人收拾这些烦人的侍卫呢，这下好了，一群笨蛋帮了我们不少忙，哈哈哈哈哈”"},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại Thủ Lĩnh Sấm Cốc Tặc"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3292>：“没想到你们这些家伙这么强……真是失算……”"},
				{XoyoGame.DEL_NPC, "guaiwu"},	
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "59_gouhuo"},
			},
		},
		[7] = {nTime = 0, nNum = 4,		--	分支2
			tbPrelock = {4},
			tbStartEvent = 
			{
				{XoyoGame.DEL_NPC, "shiwei"},	
				{XoyoGame.ADD_NPC, 1, 1, 7, "shiwei_2", "59_shiwei_5"},
				{XoyoGame.ADD_NPC, 2, 1, 7, "shiwei_2", "59_shiwei_6"},
				{XoyoGame.ADD_NPC, 3, 1, 7, "shiwei_2", "59_shiwei_7"},
				{XoyoGame.ADD_NPC, 4, 1, 7, "shiwei_2", "59_shiwei_8"},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3210>：“多谢几位侠士帮忙，几位武功高强，不如咱们切磋一下？”"},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại Trưởng Thị Vệ"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3210>：“几位果然实力非凡，我等甘拜下风！”"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "59_gouhuo"},	
			},
		},
		[8] = {nTime = 599, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = {},
		},
	}
}

tbRoom[60] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,		-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 5,						-- 房间等级(1~5)
	nMapIndex		= 5,						-- 地图组的索引
	tbBeginPoint	= {57024 / 32, 88480 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3294, nLevel = -1, nSeries = -1},		-- 侍卫
		[2] = {nTemplate = 3295, nLevel = -1, nSeries = -1},		-- 侍卫
		[3] = {nTemplate = 3296, nLevel = -1, nSeries = -1},		-- 侍卫
		[4] = {nTemplate = 3297, nLevel = -1, nSeries = -1},		-- 侍卫
		[5] = {nTemplate = 3214, nLevel = -1, nSeries = -1},		-- 竹叶青
		[6] = {nTemplate = 3215, nLevel = -1, nSeries = -1},		-- 石横霞
		[7] = {nTemplate = 3216, nLevel = -1, nSeries = -1},		-- 羌郭来
		[8] = {nTemplate = 3217, nLevel = -1, nSeries = -1},		-- 吴建
		[9] = {nTemplate = 6563, nLevel = -1, nSeries = -1}, 		-- 情花
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "此处瀑布如此壮观，真叫人流连忘返。"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
				{XoyoGame.ADD_NPC, 9, 6, 0, "qinghua", "60_qinghua"},		-- 情花
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 598, nNum = 0,		-- 总计时侍卫未杀死
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "侍卫：“谷主有好生之德，今日就饶汝等一命，请速速离谷，勿再来犯！”"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[4]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[3]:Close()"},
			},
		},
		[3] = {nTime = 600, nNum = 0,		-- 总计时杀死侍卫
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3214>：“能与我等战成均势，果然是后生可畏，不过今日时候不早，诸位也该离谷了，来日有缘再战。”"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[5]:Close()"},	
			},
		},
		[4] = {nTime = 0, nNum = 28,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "？？：四大护法在此清修，谁敢打扰！！"},
				{XoyoGame.ADD_NPC, 1, 7, 4, "guaiwu", "60_shiwei_1"},
				{XoyoGame.ADD_NPC, 2, 7, 4, "guaiwu", "60_shiwei_2"},
				{XoyoGame.ADD_NPC, 3, 7, 4, "guaiwu", "60_shiwei_3"},
				{XoyoGame.ADD_NPC, 4, 7, 4, "guaiwu", "60_shiwei_4"},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại 28 Thị Vệ"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
			},
		},
		[5] = {nTime = 0, nNum = 4,
			tbPrelock = {4},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 5, 1, 5, "guaiwu", "60_zhuyeqing"},
				{XoyoGame.ADD_NPC, 6, 1, 5, "guaiwu", "60_shihengxia"},
				{XoyoGame.ADD_NPC, 7, 1, 5, "guaiwu", "60_qiangguolai"},
				{XoyoGame.ADD_NPC, 8, 1, 5, "guaiwu", "60_wujian"},
				{XoyoGame.MOVIE_DIALOG, -1, "？？：能击败谷中侍卫，看来诸位武功相当了得，就让我们来讨教一番吧"},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại Trúc Diệp Thanh, Thạch Hoàng Hà, Khương Quách Lai, Ngô Kiến"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 3},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3214>：“果然是后生可畏，看来我等在这谷中习武多年，也只是井底之蛙啊！”"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[3]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.FINISH_ACHIEVE, -1,222}, -- achieve 
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "60_gouhuo"},
			},
		},
	}
}


tbRoom[61] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 5,						-- 房间等级(1~5)
	nMapIndex		= 5,						-- 地图组的索引
	tbBeginPoint	= {54176 / 32, 82464 / 32},-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3268, nLevel = -1, nSeries = 3},			-- 香玉仙
		[2] = {nTemplate = 3176, nLevel = -1, nSeries =	-1},		-- 劣质机关人
		[3] = {nTemplate = 3191, nLevel = -1, nSeries =	-1},		-- 机关狼
		[4] = {nTemplate = 3157, nLevel = -1, nSeries =	-1},		-- 机关斧手
		[5] = {nTemplate = 3192, nLevel = -1, nSeries =	-1},		-- 狂暴机关人
		[6] = {nTemplate = 3242, nLevel = -1, nSeries =	-1},		-- 完美机关狼
		[7] = {nTemplate = 3162, nLevel = -1, nSeries =	-1},		-- 小机关兽
		[8] = {nTemplate = 3245, nLevel = -1, nSeries =	-1},		-- 胡坤
		[9] = {nTemplate = 3305, nLevel = -1, nSeries =	-1},		-- 突木桩
		[10] = {nTemplate = 6563, nLevel = -1, nSeries = -1}, 		-- 情花
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 2, "husong", "61_xiangyuxian"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.MOVIE_DIALOG, -1, "前面那个……难道是？人见人爱，花见花开的香玉仙？"},
				{XoyoGame.TARGET_INFO, -1, ""},
				{XoyoGame.ADD_NPC, 10, 6, 0, "qinghua", "61_qinghua"},		-- 情花
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 360, nNum = 1,		-- 计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "husong"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[5]:Close()"},
				{XoyoGame.MOVIE_DIALOG, -1, "一道黑影从我们面前闪过，掳走了香玉仙，转瞬间，这些机关怪兽也消失的无影无踪……"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 5, nNum = 0,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3268>：“几位少侠好生眼熟，不知道能不能帮小女子一个忙？”\n<playername>:“请讲！”\n<npc=3268>：“刚刚有个狂徒说是对我一见钟情，想与我交好。我不依，他便放出好多恐怖的机关怪兽来威胁我，你们能保护我离开这里吗？”"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TARGET_INFO, -1, "Hộ tống Hương Ngọc Tiên"},
			},
			tbUnLockEvent = {},
		},
		[4] = {nTime = 0, nNum = 1,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.CHANGE_NPC_AI, "husong", XoyoGame.AI_MOVE, "lv5_61_xiangyuxian", 4, 10, 1, 1},	-- 护送AI
				{XoyoGame.ADD_NPC, 2, 6, 0, "guaiwu", "61_liezhijiguanren"},		-- 刷怪
				{XoyoGame.ADD_NPC, 3, 6, 0, "guaiwu", "61_jiguanjulang"},		-- 刷怪
				{XoyoGame.ADD_NPC, 4, 3, 0, "guaiwu", "61_jiguanfushou"},		-- 刷怪
				{XoyoGame.ADD_NPC, 5, 6, 0, "guaiwu", "61_kuangbaojiguanren"},		-- 刷怪
				{XoyoGame.ADD_NPC, 6, 2, 0, "guaiwu", "61_wanmeijiguanlang"},		-- 刷怪
				{XoyoGame.ADD_NPC, 7, 3, 0, "guaiwu", "61_xiaoxingjiguanshou"},		-- 刷怪
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
			},
		},
		[5] = {nTime = 600, nNum = 0,		-- 计时
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 5},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DEL_NPC, "boss"},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3245>：“香香，难道我们真的有缘无分？”胡坤喃喃自语，消失在密林中……\n<npc=3268>：“那个疯子走了？真是太谢谢了！诶呀，天色不早，我该离谷了，出去后要是有机会再见我一定送把好武器给你们。”"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "61_gouhuo"},
			},
		},
		[6] = {nTime = 0, nNum = 1,
			tbPrelock = {4},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3268>：“呼，终于可以松一口气了。啊？那家伙好像追来了，我先藏起来，你们帮我拖住他。”\n<npc=3245>：“香香，你为什么不肯接受我？！我知道你藏在这里，我一定会找到你的！”"},
				{XoyoGame.ADD_NPC, 8, 1, 6, "boss", "61_hukun"},		-- 胡坤
				{XoyoGame.TARGET_INFO, -1, "Đánh bại Hồ Khôn"},
				{XoyoGame.FINISH_ACHIEVE, -1,202}, -- achieve 胡坤
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[5]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[7]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[9]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[11]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[12]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3268>：“你们打败那个大坏蛋了？真是太谢谢了！诶呀，天色不早，我该离谷了，出去后要是有机会再见我一定送把好武器给你们。”"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "61_gouhuo"},
			},
		},
		[7] = {nTime = 60, nNum = 0,		-- 刷怪
			tbPrelock = {4},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.BLACK_MSG, -1	, "胡坤：“给我死！禁术：木毒阵”"},
				{XoyoGame.ADD_NPC, 9, 32, 0, "fenshen", "61_fenshen"},
			},
		},
		[8] = {nTime = 30, nNum = 0,		-- 删怪
			tbPrelock = {7},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "fenshen"},
			},
		},
		[9] = {nTime = 120, nNum = 0,		-- 刷怪
			tbPrelock = {4},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.BLACK_MSG, -1, "胡坤：“还不死？！超·禁术：木毒海”"},
				{XoyoGame.ADD_NPC, 9, 65, 0, "fenshen2", "61_fenshen_2"},
			},
		},
		[10] = {nTime = 30, nNum = 0,		-- 删怪
			tbPrelock = {9},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "fenshen2"},
			},
		},
		[11] = {nTime = 58, nNum = 0,		-- 刷怪
			tbPrelock = {4},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.SEND_CHAT, "boss", "想知道地狱是什么样子吗？"},
			},
		},
		[12] = {nTime = 118, nNum = 0,		-- 刷怪
			tbPrelock = {4},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.SEND_CHAT, "boss", "地狱可是有18层的，我这就送你们过去！"},
			},
		},
	}
}

-- 宝箱房间
tbRoom[62] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 5,						-- 房间等级(1~5)
	nMapIndex		= 5,						-- 地图组的索引
	tbBeginPoint	= {67520 / 32, 93600 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3303, nLevel = -1, nSeries = -1},		-- 箱子
		[2] = {nTemplate = 6563, nLevel = -1, nSeries = -1}, 		-- 情花
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "宝藏！哈哈！终于让我们找到了！不过……好像还有其他人也找到了这里……"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
				{XoyoGame.ADD_NPC, 2, 12, 0, "qinghua", "62_qinghua"},		-- 情花
			},
			tbUnLockEvent = {},
		},
		[2] = {nTime = 600, nNum = 0,
			tbPrelock = {1},
			tbStartEvent = 
			{},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "休息好了，可以离开逍遥谷了"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbTeam[2].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
			},
		},
		[3] = {nTime = 0, nNum = 0,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 10, 0, "xiangzi", "62_baoxiang"},
				{XoyoGame.TARGET_INFO, -1, "Lấy kho báu ở trong rương"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				
			},
			tbUnLockEvent = {},
		},
		[4] = {nTime = 120, nNum = 0,
			tbPrelock = {3},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "xiangzi"},
				{XoyoGame.ADD_NPC, 1, 10, 0, "xiangzi", "62_baoxiang"},
			},
		},
		[5] = {nTime = 120, nNum = 0,
			tbPrelock = {4},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "xiangzi"},
				{XoyoGame.ADD_NPC, 1, 10, 0, "xiangzi", "62_baoxiang"},
			},
		},
		[6] = {nTime = 120, nNum = 0,
			tbPrelock = {5},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "xiangzi"},
				{XoyoGame.ADD_NPC, 1, 12, 0, "xiangzi", "62_baoxiang"},
			},
		},
		[7] = {nTime = 120, nNum = 0,
			tbPrelock = {6},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "xiangzi"},
				{XoyoGame.ADD_NPC, 1, 12, 0, "xiangzi", "62_baoxiang"},
			},
		},
		[8] = {nTime = 60, nNum = 0,
			tbPrelock = {7},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "xiangzi"},
				{XoyoGame.ADD_NPC, 1, 12, 0, "xiangzi", "62_baoxiang"},
			},
		},
	}
}

tbRoom[63] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 5,						-- 房间等级(1~5)
	nMapIndex		= 5,						-- 地图组的索引
	tbBeginPoint	= {56096 / 32, 76960 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3303, nLevel = -1, nSeries = -1},		-- 箱子
		[2] = {nTemplate = 6563, nLevel = -1, nSeries = -1}, 		-- 情花
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "宝藏！哈哈！终于让我们找到了！不过……好像还有其他人也找到了这里……"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
				{XoyoGame.ADD_NPC, 2, 10, 0, "qinghua", "63_qinghua"},		-- 情花
			},
			tbUnLockEvent = {},
		},
		[2] = {nTime = 600, nNum = 0,
			tbPrelock = {1},
			tbStartEvent = 
			{},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "休息好了，可以离开逍遥谷了"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbTeam[2].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
			},
		},
		[3] = {nTime = 0, nNum = 0,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 10, 0, "xiangzi", "63_baoxiang"},
				{XoyoGame.TARGET_INFO, -1, "Mở rương báu"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				
			},
			tbUnLockEvent = {},
		},
		[4] = {nTime = 120, nNum = 0,
			tbPrelock = {3},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "xiangzi"},
				{XoyoGame.ADD_NPC, 1, 10, 0, "xiangzi", "63_baoxiang"},
			},
		},
		[5] = {nTime = 120, nNum = 0,
			tbPrelock = {4},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "xiangzi"},
				{XoyoGame.ADD_NPC, 1, 10, 0, "xiangzi", "63_baoxiang"},
			},
		},
		[6] = {nTime = 120, nNum = 0,
			tbPrelock = {5},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "xiangzi"},
				{XoyoGame.ADD_NPC, 1, 12, 0, "xiangzi", "63_baoxiang"},
			},
		},
		[7] = {nTime = 120, nNum = 0,
			tbPrelock = {6},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "xiangzi"},
				{XoyoGame.ADD_NPC, 1, 12, 0, "xiangzi", "63_baoxiang"},
			},
		},
		[8] = {nTime = 60, nNum = 0,
			tbPrelock = {7},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "xiangzi"},
				{XoyoGame.ADD_NPC, 1, 12, 0, "xiangzi", "63_baoxiang"},
			},
		},
	}
}

tbRoom[64] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 5,						-- 房间等级(1~5)
	nMapIndex		= 5,						-- 地图组的索引
	tbBeginPoint	= {64896 / 32, 84736 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3247, nLevel = -1, nSeries = 5},		-- 墨君
		[2] = {nTemplate = 3248, nLevel = -1, nSeries = -1},		-- 男弟子
		[3] = {nTemplate = 3249, nLevel = -1, nSeries = -1},		-- 女弟子
		[4] = {nTemplate = 6563, nLevel = -1, nSeries = -1}, 		-- 情花
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "这里似乎是一个私塾，不知是何人居住在此。"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
				{XoyoGame.ADD_NPC, 4, 6, 0, "qinghua", "64_qinghua"},		-- 情花
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 600, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3247>：“好好好，打住打住！你们功夫火候还差那么点，不过老夫很开心，来，先休息会，待会老夫送你们离开逍遥谷。”"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.DEL_NPC, "guaiwu"},
			},
		},
		[3] = {nTime = 0, nNum = 1,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3247>：“有朋自远方来，不亦说乎。哈哈哈哈哈！好久没有外人来老夫这光顾了。来来来，陪我活动活动筋骨吧。”"},
				{XoyoGame.ADD_NPC, 1, 1, 3, "guaiwu", "64_mojun"},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại Mặc Quân"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3247>：“好久没有这么爽快的打上一场了，各位功夫着实不错，来，喝喝酒，休息一下，老夫会送各位离开逍遥谷的。”"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "64_gouhuo"},
			},
		},
		[4] = {nTime = 120, nNum = 0,
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.ADD_NPC, 2, 1, 0, "guaiwu1_1", "64_nandizi"},
				{XoyoGame.ADD_NPC, 3, 1, 0, "guaiwu1_2", "64_nvdizi"},
				{XoyoGame.CHANGE_NPC_AI, "guaiwu1_1", XoyoGame.AI_MOVE, "lv5_64_nandizi", 0, 100, 1},
				{XoyoGame.CHANGE_NPC_AI, "guaiwu1_2", XoyoGame.AI_MOVE, "lv5_64_nvdizi", 0, 100, 1},
				{XoyoGame.BLACK_MSG, -1, "后方传来童男童女声，似乎是来帮助他们老师的。"},
			},
		},
		[5] = {nTime = 60, nNum = 0,
			tbPrelock = {4},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.ADD_NPC, 2, 1, 0, "guaiwu2_1", "64_nandizi"},
				{XoyoGame.ADD_NPC, 3, 1, 0, "guaiwu2_2", "64_nvdizi"},
				{XoyoGame.CHANGE_NPC_AI, "guaiwu2_1", XoyoGame.AI_MOVE, "lv5_64_nandizi", 0, 100, 1},
				{XoyoGame.CHANGE_NPC_AI, "guaiwu2_2", XoyoGame.AI_MOVE, "lv5_64_nvdizi", 0, 100, 1},
			},
		},
		[6] = {nTime = 60, nNum = 0,
			tbPrelock = {5},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.ADD_NPC, 2, 1, 0, "guaiwu1_1", "64_nandizi"},
				{XoyoGame.ADD_NPC, 3, 1, 0, "guaiwu1_2", "64_nvdizi"},
				{XoyoGame.CHANGE_NPC_AI, "guaiwu1_1", XoyoGame.AI_MOVE, "lv5_64_nandizi", 0, 100, 1},
				{XoyoGame.CHANGE_NPC_AI, "guaiwu1_2", XoyoGame.AI_MOVE, "lv5_64_nvdizi", 0, 100, 1},
			},
		},
		[7] = {nTime = 60, nNum = 0,
			tbPrelock = {6},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.ADD_NPC, 2, 1, 0, "guaiwu1_1", "64_nandizi"},
				{XoyoGame.ADD_NPC, 3, 1, 0, "guaiwu1_2", "64_nvdizi"},
				{XoyoGame.CHANGE_NPC_AI, "guaiwu1_1", XoyoGame.AI_MOVE, "lv5_64_nandizi", 0, 100, 1},
				{XoyoGame.CHANGE_NPC_AI, "guaiwu1_2", XoyoGame.AI_MOVE, "lv5_64_nvdizi", 0, 100, 1},
			},
		},
		[8] = {nTime = 60, nNum = 0,
			tbPrelock = {7},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.ADD_NPC, 2, 1, 0, "guaiwu1_1", "64_nandizi"},
				{XoyoGame.ADD_NPC, 3, 1, 0, "guaiwu1_2", "64_nvdizi"},
				{XoyoGame.CHANGE_NPC_AI, "guaiwu1_1", XoyoGame.AI_MOVE, "lv5_64_nandizi", 0, 100, 1},
				{XoyoGame.CHANGE_NPC_AI, "guaiwu1_2", XoyoGame.AI_MOVE, "lv5_64_nvdizi", 0, 100, 1},
			},
		},
	}
}

tbRoom[65] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 5,						-- 房间等级(1~5)
	nMapIndex		= 5,						-- 地图组的索引
	tbBeginPoint	= {61952 / 32, 86432 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3250, nLevel = -1, nSeries = 2},		-- 唐羽
		[2] = {nTemplate = 6563, nLevel = -1, nSeries = -1}, 		-- 情花

	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "竹林、竹子搭的擂台、竹屋……这里，难道是蜀中唐门？"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
				{XoyoGame.ADD_NPC, 2, 6, 0, "qinghua", "65_qinghua"},		-- 情花
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 600, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3250>：“年轻人呐，你们还得多多修炼啊。我好长时间没有激烈运动过了，今天动了下就腰酸背痛腿抽筋了，哎，回去休息啰。”"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.DEL_NPC, "guaiwu"},
			},
		},
		[3] = {nTime = 0, nNum = 1,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3250>：“在这谷里住了这么久，很少能看到生面孔呢。看几位应该身手不错，来陪老夫过上几招吧，不知道你们有没有本领接老夫十招呢？”"},
				{XoyoGame.ADD_NPC, 1, 1, 3, "guaiwu", "65_tangyu"},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại Đường Vũ"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3250>：“哎，不承认不行了啊，人呐，到了这个年龄，是该好好休息了，舞刀弄枪这种事，还是适合你们年轻人去做。年轻真好啊。”"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "65_gouhuo"},
			},
		},
	}
}

tbRoom[66] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 4,						-- 房间等级(1~5)
	nMapIndex		= 4,						-- 地图组的索引
	tbBeginPoint	= {70016 / 32, 125824 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板			等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 		nLevel, 		nSeries }
		[1] = {nTemplate = 3320, nLevel = -1, nSeries = 2},		-- boss
		[2] = {nTemplate = 6563, nLevel = -1, nSeries = -1}, 		-- 情花
	},
	--锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3320>：逍遥谷中的外人是越来越多了，欺负过我弟弟的人也是越来越多了。我这个做哥哥的实在看不下去了，一定要教训教训你们。想当年师傅传授技巧时，我为了我弟弟放弃了学艺，但是师傅他老人家被我的行动所感动，传授了他不为人所知的一面给我。今天我就要让你们知道什么叫做生不如死。"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.ADD_NPC, 2, 6, 0, "qinghua", "66_qinghua"},		-- 情花
			},
			tbUnLockEvent = {},
		},
		[2] = {nTime = 480, nNum = 0,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 2},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "boss"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3320>:啊！弟弟啊，你来了，看哥哥帮你教训这群。。可恶，竟然趁我分神之际溜走了。哼！你们下次别落在我手里！"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[3]:Close()"},},
		},
		[3] = {nTime = 0, nNum = 1,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 3, "boss", "66_huqian"},
			{XoyoGame.TARGET_INFO, -1, "Đánh bại Hồ Càn"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3320>：不！这不是真的！弟弟，做哥哥的对不起你，没能帮你报仇！师傅啊，徒儿不孝，给您老抹黑了！"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "66_huqian"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
			},
		},
	}
}

tbRoom[67] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 5,						-- 房间等级(1~5)
	nMapIndex		= 5,						-- 地图组的索引
	tbBeginPoint	= {59968 / 32, 74336 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 3314, nLevel = -1, nSeries = 3},		-- 小怪1
		[2] = {nTemplate = 3315, nLevel = -1, nSeries = 3},		-- 小怪1
		[3] = {nTemplate = 3316, nLevel = -1, nSeries = 3},		-- boss
		[4] = {nTemplate = 6563, nLevel = -1, nSeries = -1}, 		-- 情花
		

	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "传说中的房间？？！！难道我们又遇到逍遥谷中的高人啦？？"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
				{XoyoGame.ADD_NPC, 4, 6, 0, "qinghua", "67_qinghua"},		-- 情花
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3314>：大胆，女儿家的闺房中的岂容尔等擅闯!\n囧rz,果然是这样。"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
			},
		},
		[2] = {nTime = 0, nNum = 3,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 2, "guaiwu", "67_shinv_1_1"},
				{XoyoGame.ADD_NPC, 2, 2, 2, "guaiwu", "67_shinv_2_1"},
				{XoyoGame.TARGET_INFO, -1, "Giải thích với các cô nương ở đây"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.BLACK_MSG, -1, "不管用？继续吧。"},
			},
		},
		[3] = {nTime = 0, nNum = 3,
			tbPrelock = {2},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 3, "guaiwu", "67_shinv_1_2"},
				{XoyoGame.ADD_NPC, 2, 2, 3, "guaiwu", "67_shinv_2_2"},
				{XoyoGame.TARGET_INFO, -1, "Không làm? Tiếp tục."},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.BLACK_MSG, -1, "看来还得继续。"},
			},
		},
		[4] = {nTime = 0, nNum = 3,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 4, "guaiwu", "67_shinv_1_3"},
				{XoyoGame.ADD_NPC, 2, 2, 4, "guaiwu", "67_shinv_2_3"},
				{XoyoGame.TARGET_INFO, -1, "看来还得继续。"},
			},
			tbUnLockEvent = {},
		},
		[5] = {nTime = 5, nNum = 0,
			tbPrelock = {4},
			tbStartEvent = 
			{
				{XoyoGame.CHANGE_TRAP, "67_trap", {58400 / 32, 74336 / 32}},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3316>：哎哟喂，想不到会有谷外之人来到这里，既然是这样就让奴家好好伺候各位吧。\n- -b，这里究竟是什么地方。"},
			},
			tbUnLockEvent = {},
			},
		[6] = {nTime = 0, nNum = 1,
			tbPrelock = {5},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 3, 1, 6, "guaiwu", "67_boss"},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại Diệp Tịnh"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3316>：各位真是太强了，Haa，下次记得再来找奴家玩，Haa。"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[7]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "67_gouhuo"},
				{XoyoGame.CHANGE_TRAP, "67_trap", nil},
			},
		},
		[7] = {nTime = 600, nNum = 0,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 7},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=3316>：哎哟，时候不早了，奴家要去泡温泉啦。你们下次再来陪奴家玩吧，haa。"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[6]:Close()"},
				{XoyoGame.CHANGE_TRAP, "67_trap", nil},
			},
		},
	}
}

Require("\\script\\mission\\xoyogame\\carrot_room\\carrot.lua")

-- 拔萝卜（配置表已关闭本房间，因为房间玩家不回血，与菜回血技能相冲突，月菜技能不能删除）
tbRoom[68] = 
{
	DerivedRoom		= XoyoGame.RoomCarrot;
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= XoyoGame.RoomCarrot.PlayerDeath,
	fnWinRule		= BaseRoom.PKWinRule2,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 3,						-- 房间等级(1~5)
	nMapIndex		= 3,						-- 地图组的索引
	tbBeginPoint	= {49664/32, 94112/32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 4000, nLevel = -1, nSeries = -1},		-- 萝卜

		-- 技能
		[2] = {nTemplate = 4290, nLevel = -1, nSeries = -1},
		[3] = {nTemplate = 4291, nLevel = -1, nSeries = -1},
		[4] = {nTemplate = 4292, nLevel = -1, nSeries = -1},
		[5] = {nTemplate = 4293, nLevel = -1, nSeries = -1},
		[6] = {nTemplate = 4294, nLevel = -1, nSeries = -1},

		-- 陷阱
		[7] = {nTemplate = 4295, nLevel = -1, nSeries = -1},
		[8] = {nTemplate = 4296, nLevel = -1, nSeries = -1},
		[9] = {nTemplate = 4297, nLevel = -1, nSeries = -1},
		[10] = {nTemplate = 4298, nLevel = -1, nSeries = -1},
		[11] = {nTemplate = 4299, nLevel = -1, nSeries = -1},
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 20, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.MOVIE_DIALOG, -1, "此处似乎是一个拔萝卜的好地方……"},
				{XoyoGame.TARGET_INFO, -1, ""},
				{XoyoGame.TRANSFORM_CHILD},
				{XoyoGame.CHANGE_CAMP, 1, 1},
				{XoyoGame.CHANGE_CAMP, 2, 2},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_CAMP},
			},
		},
		[2] = {nTime = 390 - 20 - 1, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self:BeginPick();"},
				{XoyoGame.DO_SCRIPT, "self:SetPlayerLife();"},
				{XoyoGame.MOVIE_DIALOG, -1, "不知从哪冒出这么多萝卜！先把它们吃掉再说。"},
				{XoyoGame.TARGET_INFO, -1, "Bên ta có 0 La Bặc\nBên họ có 0 La Bặc"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				{XoyoGame.ADD_NPC, 1, 4, 0, "carrot", "68_carrot", 20, 15, "add_carrot"},
				{XoyoGame.ADD_NPC, {2,3,4,5,6}, 4, 0, "skill", "68_skill", 20, 15, "add_skill"},
				{XoyoGame.ADD_NPC, {7,8,9,10,11}, 4, 0, "trap", "68_trap", 20, 15, "add_trap"},
				{XoyoGame.DO_SCRIPT, "self:Phrase1Logic();"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "carrot"},
				{XoyoGame.DEL_NPC, "skill"},
				{XoyoGame.DEL_NPC, "trap"},
				{XoyoGame.TARGET_INFO, -1, ""},
				{XoyoGame.CHANGE_FIGHT, -1, 0, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.DO_SCRIPT, "self:FinishMsg()"},
			},
		},
	}
}

Require("\\script\\mission\\xoyogame\\hide_and_seek\\hide_and_seek.lua");

--捉小偷
tbRoom[69] = 
{
	DerivedRoom		= XoyoGame.RoomHideAndSeek;
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,
	fnWinRule		= XoyoGame.RoomHideAndSeek.WinRule,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 5,						-- 房间等级(1~5)
	nMapIndex		= 6,						-- 地图组的索引
	tbBeginPoint	= {{1880, 3447}, {1717, 3611}},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.MOVIE_DIALOG, -1, "这里是小调皮们玩捉小偷的地方，既然来到这里就和他们一起玩游戏吧。"},
				{XoyoGame.TARGET_INFO, -1, ""},
				{XoyoGame.TRANSFORM_CHILD_2},
				{XoyoGame.SET_SKILL, -1, 1430},
				{XoyoGame.DISABLE_SWITCH_SKILL, -1, 1},
				--{XoyoGame.SHOW_NAME_AND_LIFE, 0},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_CAMP},
			},
		},
		[2] = {nTime = 290, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "宝果子、二丫、小荷、小楚这四个捣蛋鬼已经藏好了，他们四个中只有一个是真正的小偷，你要在时间结束前抓住他。找对的有奖，找错了要受罚。如果想知道谁是真的小偷，那就去问小神童易周和小机灵易凡吧！"},
				--{XoyoGame.TIME_INFO, -1, "<color=green>捉迷藏剩余时间%s<color>", 2},
				{XoyoGame.TARGET_INFO, -1, "Bắt 0 tên vô lại"},
				{XoyoGame.DO_SCRIPT, "self:NewRound()"}
			},
			tbUnLockEvent = 
			{
				{XoyoGame.TARGET_INFO, -1, ""},
				--{XoyoGame.SHOW_NAME_AND_LIFE, 1},
			},
		},
	}
}

Require("\\script\\mission\\xoyogame\\invade\\invade.lua");

-- 金军入侵
tbRoom[70] = 
{                          
	DerivedRoom		= XoyoGame.RoomInvade,
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= XoyoGame.RoomInvade.WinRule,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 5,						-- 房间等级(1~5)
	nMapIndex		= 6,						-- 地图组的索引
	tbBeginPoint	= {1670, 3650},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 4652, nLevel = -1, nSeries = -1},		-- 门a1
		[2] = {nTemplate = 4653, nLevel = -1, nSeries = -1},		-- 门a2
		[3] = {nTemplate = 4654, nLevel = -1, nSeries = -1},		-- 门b1
		[4] = {nTemplate = 4655, nLevel = -1, nSeries = -1},		-- 门b2
		[5] = {nTemplate = 4656, nLevel = -1, nSeries = -1},		-- 开关a1
		[6] = {nTemplate = 4657, nLevel = -1, nSeries = -1},		-- 开关a2
		[7] = {nTemplate = 4658, nLevel = -1, nSeries = -1},		-- 开关b1
		[8] = {nTemplate = 4659, nLevel = -1, nSeries = -1},		-- 开关b2
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.MOVIE_DIALOG, -1, "根据探子回报，金军已经集结在城门外，并兵分两路准备进犯本城，请各位大侠全力击退金军，万不可让他们攻到内城门口。"},
				{XoyoGame.TARGET_INFO, -1, ""},
				{XoyoGame.ADD_NPC, 1, 1, 0, "gate_a1", "70_gate_a1"}, -- 这几个写在 lv1里面了
				{XoyoGame.ADD_NPC, 2, 1, 0, "gate_a2", "70_gate_a2"},
				{XoyoGame.ADD_NPC, 3, 1, 0, "gate_b1", "70_gate_b1"},
				{XoyoGame.ADD_NPC, 4, 1, 0, "gate_b2", "70_gate_b2"},
				{XoyoGame.ADD_NPC, 5, 1, 3, "switch_a1", "70_switch_a1"},
				{XoyoGame.ADD_NPC, 6, 1, 5, "switch_a2", "70_switch_a2"},
				{XoyoGame.ADD_NPC, 7, 1, 4, "switch_b1", "70_switch_b1"},
				{XoyoGame.ADD_NPC, 8, 1, 6, "switch_b2", "70_switch_b2"},
				{XoyoGame.NPC_CAN_TALK, "switch_a1", 0},
				{XoyoGame.NPC_CAN_TALK, "switch_a2", 0},
				{XoyoGame.NPC_CAN_TALK, "switch_b1", 0},
				{XoyoGame.NPC_CAN_TALK, "switch_b2", 0},
				{XoyoGame.CHANGE_TRAP, "to_trapA1", {1709, 3468}},
				{XoyoGame.CHANGE_TRAP, "to_trapA2", {1868, 3391}},
				{XoyoGame.CHANGE_TRAP, "to_trapB1", {1858, 3629}},
				{XoyoGame.CHANGE_TRAP, "to_trapB2", {1939, 3464}},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_CAMP},
			},
		},
		[2] = {nTime = 630 - 15 - 1, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "战鼓已经响起，金军已经开始进攻了！"},
				{XoyoGame.TARGET_INFO, -1, "Đẩy lùi quân xâm lược"},
				{XoyoGame.DO_SCRIPT, "self:AddJinJun();"}
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self:FinishMsg()"},
				--{XoyoGame.MOVIE_DIALOG, -1, "想不到金军如此凶悍，竟然一路攻破内城，我军已经战败！"},
				--{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 0, nNum = 1, -- switch_a1 -> trap_a1, gate_a1
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = {
				{XoyoGame.DEL_NPC, "gate_a1"},
				{XoyoGame.CHANGE_TRAP, "to_trapA1", nil},
				},
		},
		[4] = {nTime = 0, nNum = 1, -- switch_b1 -> trap_b1, gate_b1
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = {
				{XoyoGame.DEL_NPC, "gate_b1"},
				{XoyoGame.CHANGE_TRAP, "to_trapB1", nil},
				},
		},
		[5] = {nTime = 0, nNum = 1, -- switch_a2 -> trap_a2, gate_a2
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = {
				{XoyoGame.DEL_NPC, "gate_a2"},
				{XoyoGame.CHANGE_TRAP, "to_trapA2", nil},
				},
		},
		[6] = {nTime = 0, nNum = 1, -- switch_b2 -> trap_b2, gate_b2
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = {
				{XoyoGame.DEL_NPC, "gate_b2"},
				{XoyoGame.CHANGE_TRAP, "to_trapB2", nil},
				},
		},
		[7] = {nTime = 120 + 15, nNum = 0, -- a1, b1在这段时间之后开启
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = {
				{XoyoGame.NPC_CAN_TALK, "switch_a1", 1},
				{XoyoGame.NPC_CAN_TALK, "switch_b1", 1},
				},
		},
		[8] = {nTime = 300 + 15, nNum = 0, -- a2, b2在这段时间之后开启
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = {
				{XoyoGame.NPC_CAN_TALK, "switch_a2", 1},
				{XoyoGame.NPC_CAN_TALK, "switch_b2", 1},
				},
		},
		[9] = {nTime = 0, nNum = 0,
			  tbPrelock = {1},
			  tbStartEvent = { 
			  	{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s\nThời gian mở cổng 1：%s\nThời gian mở cổng 2：%s<color>\n", {2, 7, 8}},     
				}
		},
		
	}
}

Require("\\script\\mission\\xoyogame\\thief\\thief.lua");

-- 飞贼
tbRoom[71] = 
{
	DerivedRoom		= XoyoGame.RoomThief;
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 5,						-- 房间等级(1~5)
	nMapIndex		= 6,						-- 地图组的索引
	tbBeginPoint	= {1600, 3784},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = {},
	
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.MOVIE_DIALOG, -1, "山顶有官府捕快，难道是在抓飞贼？"},
				{XoyoGame.TARGET_INFO, -1, ""},
				{XoyoGame.CHANGE_CAMP, 1, 1},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_CAMP},
			},
		},
		[2] = {nTime = 630 - 15 - 1, nNum = 0,		-- 计时
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "飞贼把赃物交给了一个叫张德恒的人，抓到他夺回青花瓷瓶。"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				{XoyoGame.TARGET_INFO, -1, "<color=red>Tìm Trương Đức Hằng đoạt lại bảo vật<color>"},
				{XoyoGame.DO_SCRIPT, "self:AddThief()"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "if self:IsWin() == 1 then self.tbTeam[1].bIsWiner = 1 end"},
				{XoyoGame.DO_SCRIPT, [[
					if self:IsWin() == 1 then 
						self:MovieDialog(-1, "一切告一段落，休息一下继续我们的旅程。");
					else
						self:MovieDialog(-1, "没能够人赃并获，真是功亏一篑啊！");
					end
					]]},
				
				
				{XoyoGame.TARGET_INFO, -1, ""},
			},
		},
	}
}

-- 宝玉（boss）
tbRoom[72] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 5,						-- 房间等级(1~5)
	nMapIndex		= 6,						-- 地图组的索引
	tbBeginPoint	= {1564, 3506},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 4665, nLevel = -1, nSeries = 1},		-- 宝玉

	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "不知不觉中，已经来到了逍遥谷深处，前面有座大宅子。"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 600, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=4665>：“稍微活动了一下筋骨，让你们领教一下逍遥谷大公子的厉害。。”"},
				{XoyoGame.CHANGE_FIGHT, -1, 0, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.PLAYER_REMOVE_EFFECT,-1,1464},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.DEL_NPC, "guaiwu"},
			},
		},
		[3] = {nTime = 0, nNum = 1,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=4665>：“来者何人敢擅闯逍遥谷，大观园岂是你们说来就来说走就走的！！！”"},
				{XoyoGame.ADD_NPC, 1, 1, 3, "guaiwu", "72_baoyu"},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại Bảo Ngọc"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=4665>：“你们果然有两下子，本公子今天认栽了。”"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.CHANGE_FIGHT, -1, 0, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.PLAYER_REMOVE_EFFECT,-1,1464},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "72_gouhuo"},
			},
		},
	}
}

-- 莺莺（boss）
tbRoom[73] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 4,						-- 房间等级(1~5)
	nMapIndex		= 4,						-- 地图组的索引
	tbBeginPoint	= {1852, 3879},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 4666, nLevel = -1, nSeries = 3},		-- 莺莺
		[2] = {nTemplate = 4667, nLevel = -1, nSeries = -1},		-- 老妈子
		[3] = {nTemplate = 6563, nLevel = -1, nSeries = -1}, 		-- 情花
		
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "不知不觉中来到了一片花开柳绿的区域，四处转转先。"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
				{XoyoGame.ADD_NPC, 3, 6, 0, "qinghua", "73_qinghua"},		-- 情花
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 480, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=4666>：“让你们知道本小姐的厉害，敢在逍遥谷中撒野的人还真不多见。”"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.DEL_NPC, "guaiwu"},
			},
		},
		[3] = {nTime = 0, nNum = 14,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=4666>：“张妈李妈，看看前面那群人是什么来头。”"},
				{XoyoGame.ADD_NPC, 2, 14, 3, "guaiwu", "73_laomazi"},				
				{XoyoGame.TARGET_INFO, -1, "Đánh bại Lão Ma Tử"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = {},
		},
		[4] = {nTime = 0, nNum = 1,		-- 总计时
			tbPrelock = {3},		
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=4666>：“你们想干什么，非要逼得本小姐出手不是？”"},
				{XoyoGame.ADD_NPC, 1, 1, 4, "guaiwu", "73_yingying"},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại Oanh Oanh"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=4666>：“哼！我要回去找爹爹告状去，你们跑不了的。”"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "73_gouhuo"},
			},
		},
	}
}

-- 信春哥得永生
tbRoom[74] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 2,						-- 房间等级(1~5)
	nMapIndex		= 2,						-- 地图组的索引
	tbBeginPoint	= {1628 , 3079},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 4668, nLevel = -1, nSeries = -1},		-- 干柴
		[2] = {nTemplate = 4669, nLevel = -1, nSeries = -1},		-- 烈火
		[3] = {nTemplate = 4670, nLevel = -1, nSeries = -1},		-- 工匠徒弟
		[4] = {nTemplate = 4671, nLevel = -1, nSeries = -1},		-- 工匠师傅
				
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 3, 1, 0, "tudi", "74_gongjiangtudi"},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=4670>：“好累啊，每天都有干不尽的活。”"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 240, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=4670>：“师傅不在，我们搞点活动娱乐下吧，那边有几堆火，你们帮我点起来。”"},		
				{XoyoGame.TARGET_INFO, -1, "Trợ giúp Công Tượng Đồ Đệ đốt lửa"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},	
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=4670>：“你们靠不住，还是我自己来吧。”"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.DEL_NPC, "liehuo"},
			},
		},
		[3] = {nTime = 0, nNum = 1,		-- 篝火1
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 3, "ganchai1", "74_chun1"},				
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "ganchai1"},		
				{XoyoGame.ADD_NPC, 2, 1, 0, "liehuo", "74_chun1"},			
			},
		},
		[4] = {nTime = 0, nNum = 1,		-- 篝火2
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 4, "ganchai2", "74_chun2"},				
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "ganchai2"},		
				{XoyoGame.ADD_NPC, 2, 1, 0, "liehuo", "74_chun2"},			
			},
		},
		[5] = {nTime = 0, nNum = 1,		-- 篝火3
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 5, "ganchai3", "74_chun3"},				
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "ganchai3"},		
				{XoyoGame.ADD_NPC, 2, 1, 0, "liehuo", "74_chun3"},			
			},
		},
		[6] = {nTime = 0, nNum = 1,		-- 篝火4
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 6, "ganchai4", "74_chun4"},				
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "ganchai4"},		
				{XoyoGame.ADD_NPC, 2, 1, 0, "liehuo", "74_chun4"},			
			},
		},
		[7] = {nTime = 0, nNum = 1,		-- 篝火5
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 7, "ganchai5", "74_chun5"},				
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "ganchai5"},		
				{XoyoGame.ADD_NPC, 2, 1, 0, "liehuo", "74_chun5"},			
			},
		},
		[8] = {nTime = 0, nNum = 1,		-- 篝火6
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 8, "ganchai6", "74_chun6"},				
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "ganchai6"},		
				{XoyoGame.ADD_NPC, 2, 1, 0, "liehuo", "74_chun6"},			
			},
		},
		[9] = {nTime = 0, nNum = 1,		-- 篝火7
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 9, "ganchai7", "74_chun7"},				
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "ganchai7"},		
				{XoyoGame.ADD_NPC, 2, 1, 0, "liehuo", "74_chun7"},			
			},
		},
		[10] = {nTime = 0, nNum = 1,		-- 篝火8
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 10, "ganchai8", "74_chun8"},				
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "ganchai8"},		
				{XoyoGame.ADD_NPC, 2, 1, 0, "liehuo", "74_chun8"},			
			},
		},
		[11] = {nTime = 0, nNum = 1,		-- 篝火9
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 11, "ganchai9", "74_chun9"},				
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "ganchai9"},		
				{XoyoGame.ADD_NPC, 2, 1, 0, "liehuo", "74_chun9"},			
			},
		},
		[12] = {nTime = 0, nNum = 1,		-- 篝火10
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 12, "ganchai10", "74_chun10"},				
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "ganchai10"},		
				{XoyoGame.ADD_NPC, 2, 1, 0, "liehuo", "74_chun10"},			
			},
		},
		[13] = {nTime = 0, nNum = 1,		-- 篝火11
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 13, "ganchai11", "74_chun11"},				
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "ganchai11"},		
				{XoyoGame.ADD_NPC, 2, 1, 0, "liehuo", "74_chun11"},			
			},
		},
		[14] = {nTime = 5, nNum = 0,		-- 阶段休息
			tbPrelock = {3,4,5,6,7,8,9,10,11,12,13},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=4670>：“休息一下，我们再继续。”"},			
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=4670>：“再来再来。”"},					
			},
		},
		[15] = {nTime = 0, nNum = 1,		-- 篝火12
			tbPrelock = {14},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 15, "ganchai12", "74_chun12"},				
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "ganchai12"},		
				{XoyoGame.ADD_NPC, 2, 1, 0, "liehuo", "74_chun12"},			
			},
		},
		[16] = {nTime = 0, nNum = 1,		-- 篝火13
			tbPrelock = {14},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 16, "ganchai13", "74_chun13"},				
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "ganchai13"},		
				{XoyoGame.ADD_NPC, 2, 1, 0, "liehuo", "74_chun13"},			
			},
		},
		[17] = {nTime = 0, nNum = 1,		-- 篝火14
			tbPrelock = {14},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 17, "ganchai14", "74_chun14"},				
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "ganchai14"},		
				{XoyoGame.ADD_NPC, 2, 1, 0, "liehuo", "74_chun14"},			
			},
		},
		[18] = {nTime = 0, nNum = 1,		-- 篝火15
			tbPrelock = {14},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 18, "ganchai15", "74_chun15"},				
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "ganchai15"},		
				{XoyoGame.ADD_NPC, 2, 1, 0, "liehuo", "74_chun15"},		
			},
		},
		[19] = {nTime = 0, nNum = 1,		-- 篝火16
			tbPrelock = {14},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 19, "ganchai16", "74_chun16"},				
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "ganchai16"},		
				{XoyoGame.ADD_NPC, 2, 1, 0, "liehuo", "74_chun16"},	
			},
		},
		[20] = {nTime = 0, nNum = 1,		-- 篝火17
			tbPrelock = {14},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 20, "ganchai17", "74_chun17"},				
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "ganchai17"},		
				{XoyoGame.ADD_NPC, 2, 1, 0, "liehuo", "74_chun17"},			
			},
		},
		[21] = {nTime = 0, nNum = 1,		-- 篝火18
			tbPrelock = {14},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 21, "ganchai18", "74_chun18"},				
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "ganchai18"},		
				{XoyoGame.ADD_NPC, 2, 1, 0, "liehuo", "74_chun18"},			
			},
		},
		[22] = {nTime = 0, nNum = 1,		-- 篝火19
			tbPrelock = {14},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 22, "ganchai19", "74_chun19"},				
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "ganchai19"},		
				{XoyoGame.ADD_NPC, 2, 1, 0, "liehuo", "74_chun19"},			
			},
		},
		[23] = {nTime = 0, nNum = 1,		-- 篝火20
			tbPrelock = {14},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 23, "ganchai20", "74_chun20"},				
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "ganchai20"},		
				{XoyoGame.ADD_NPC, 2, 1, 0, "liehuo", "74_chun20"},			
			},
		},
		[24] = {nTime = 0, nNum = 1,		-- 篝火21
			tbPrelock = {14},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 24, "ganchai21", "74_chun21"},				
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "ganchai21"},		
				{XoyoGame.ADD_NPC, 2, 1, 0, "liehuo", "74_chun21"},			
			},
		},
		[25] = {nTime = 0, nNum = 1,		-- 篝火22
			tbPrelock = {14},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 25, "ganchai22", "74_chun22"},				
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "ganchai22"},		
				{XoyoGame.ADD_NPC, 2, 1, 0, "liehuo", "74_chun22"},			
			},
		},
		[26] = {nTime = 5, nNum = 0,		-- 阶段休息
			tbPrelock = {15,16,17,18,19,20,21,22,23,24,25},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=4670>：“休息一下，我们再继续。”"},			
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=4670>：“再接再厉，就快完成了。”"},					
			},
		},
		[27] = {nTime = 0, nNum = 1,		-- 篝火23
			tbPrelock = {26},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 27, "ganchai23", "74_chun23"},				
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "ganchai23"},		
				{XoyoGame.ADD_NPC, 2, 1, 0, "liehuo", "74_chun23"},			
			},
		},
		[28] = {nTime = 0, nNum = 1,		-- 篝火24
			tbPrelock = {26},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 28, "ganchai24", "74_chun24"},				
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "ganchai24"},		
				{XoyoGame.ADD_NPC, 2, 1, 0, "liehuo", "74_chun24"},			
			},
		},
		[29] = {nTime = 0, nNum = 1,		-- 篝火25
			tbPrelock = {26},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 29, "ganchai25", "74_chun25"},				
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "ganchai25"},		
				{XoyoGame.ADD_NPC, 2, 1, 0, "liehuo", "74_chun25"},			
			},
		},
		[30] = {nTime = 0, nNum = 1,		-- 篝火26
			tbPrelock = {26},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 30, "ganchai26", "74_chun26"},				
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "ganchai26"},		
				{XoyoGame.ADD_NPC, 2, 1, 0, "liehuo", "74_chun26"},			
			},
		},
		[31] = {nTime = 0, nNum = 1,		-- 篝火27
			tbPrelock = {26},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 31, "ganchai27", "74_chun27"},				
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "ganchai27"},		
				{XoyoGame.ADD_NPC, 2, 1, 0, "liehuo", "74_chun27"},			
			},
		},
		[32] = {nTime = 0, nNum = 1,		-- 篝火28
			tbPrelock = {26},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 32, "ganchai28", "74_chun28"},				
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "ganchai28"},		
				{XoyoGame.ADD_NPC, 2, 1, 0, "liehuo", "74_chun28"},			
			},
		},
		[33] = {nTime = 0, nNum = 1,		-- 篝火29
			tbPrelock = {26},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 33, "ganchai29", "74_chun29"},				
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "ganchai29"},		
				{XoyoGame.ADD_NPC, 2, 1, 0, "liehuo", "74_chun29"},			
			},
		},
		[34] = {nTime = 0, nNum = 1,		-- 篝火30
			tbPrelock = {26},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 34, "ganchai30", "74_chun30"},				
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "ganchai30"},		
				{XoyoGame.ADD_NPC, 2, 1, 0, "liehuo", "74_chun30"},			
			},
		},
		[35] = {nTime = 0, nNum = 1,		-- 篝火31
			tbPrelock = {26},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 35, "ganchai31", "74_chun31"},				
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "ganchai31"},		
				{XoyoGame.ADD_NPC, 2, 1, 0, "liehuo", "74_chun31"},			
			},
		},
		[36] = {nTime = 0, nNum = 1,		-- 篝火32
			tbPrelock = {26},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 36, "ganchai32", "74_chun32"},				
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "ganchai32"},		
				{XoyoGame.ADD_NPC, 2, 1, 0, "liehuo", "74_chun32"},			
			},
		},
		[37] = {nTime = 0, nNum = 1,		-- 篝火33
			tbPrelock = {26},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 37, "ganchai33", "74_chun33"},				
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "ganchai33"},		
				{XoyoGame.ADD_NPC, 2, 1, 0, "liehuo", "74_chun33"},			
			},
		},
		[38] = {nTime = 30, nNum = 0,
			tbPrelock = {27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=4670>：“都完成了，我的杰作漂亮吧。信春哥，得永生，心情愉快起来了。”"},		
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},	
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.FINISH_ACHIEVE, -1,214}, -- achieve 
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "74_gouhuo"},	
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "liehuo"},
			},
		},
	}
}

-- 军旗操演
tbRoom[75] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 3,						-- 房间等级(1~5)
	nMapIndex		= 3,						-- 地图组的索引
	tbBeginPoint	= {1495, 2772},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 4672, nLevel = -1, nSeries = -1},		-- 逍遥谷教官
		[2] = {nTemplate = 4673, nLevel = -1, nSeries = -1},		-- 逍遥谷军旗		
		[3] = {nTemplate = 4674, nLevel = -1, nSeries = -1},		-- 护旗卫兵
		[4] = {nTemplate = 6563, nLevel = -1, 	nSeries = -1}, 		-- 情花
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 1, "jiaotou", "75_jiaotou"},	
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=4672>：“我军屡战屡败，究其原因就是军纪不严，军威不振。”"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.ADD_NPC, 4, 3, 0, "qinghua", "75_qinghua"},		-- 情花
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 360, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.TARGET_INFO, -1, "Hoàn thành sáu đạo quân lệnh đích thao diễn"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},	
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=4672>：“唉，看来你们还需要些操练。”"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.DEL_NPC, "guaiwu"},
			},
		},
		[3] = {nTime = 0 , nNum = 1,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=4672>：“第一道军令：右边的平台有一面军旗，速速给我取来。”"},
				{XoyoGame.ADD_NPC, 2, 1, 3, "guaiwu", "75_junqi4"},				
			},
			tbUnLockEvent = {},
		},	
		[4] = {nTime = 0 , nNum = 3,		-- 总计时
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 3, 3, 4, "guaiwu", "75_weibing11"},				
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=4672>：“第二道军令：左边的平台有一面军旗，速速给我取来。”"},				
			},
		},		
		[5] = {nTime = 0 , nNum = 1,		-- 总计时
			tbPrelock = {4},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 2, 1, 5, "guaiwu", "75_junqi7"},				
			},
			tbUnLockEvent = {},
		},	
		[6] = {nTime = 0 , nNum = 5,		-- 总计时
			tbPrelock = {5},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 3, 5, 6, "guaiwu", "75_weibing21"},				
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=4672>：“第三道军令：左右两边的平台各有一面军旗，速速给我取来。”"},				
			},
		},	
		[7] = {nTime = 0 , nNum = 1,		-- 总计时
			tbPrelock = {6},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 2, 1, 7, "guaiwu", "75_junqi2"},				
			},
			tbUnLockEvent = {},
		},	
		[8] = {nTime = 0 , nNum = 4,		-- 总计时
			tbPrelock = {7},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 3, 4, 8, "guaiwu", "75_weibing31"},				
			},
			tbUnLockEvent = {},
		},
		[9] = {nTime = 0 , nNum = 1,		-- 总计时
			tbPrelock = {6},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 2, 1, 9, "guaiwu", "75_junqi8"},				
			},
			tbUnLockEvent = {},
		},	
		[10] = {nTime = 0 , nNum = 4,		-- 总计时
			tbPrelock = {9},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 3, 4, 10, "guaiwu", "75_weibing32"},				
			},
			tbUnLockEvent = {},
		},	
		[11] = {nTime = 5 , nNum = 0,		-- 总计时
			tbPrelock = {8 ,10},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=4672>：“第四道军令：左右两边的平台各有一面军旗，速速给我取来。”"},		
			},
			tbUnLockEvent = {},
		},			
		[12] = {nTime = 0 , nNum = 1,		-- 总计时
			tbPrelock = {11},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 2, 1, 12, "guaiwu", "75_junqi1"},				
			},
			tbUnLockEvent = {},
		},	
		[13] = {nTime = 0 , nNum = 4,		-- 总计时
			tbPrelock = {12},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 3, 4, 13, "guaiwu", "75_weibing41"},				
			},
			tbUnLockEvent = {},
		},
		[14] = {nTime = 0 , nNum = 1,		-- 总计时
			tbPrelock = {11},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 2, 1, 14, "guaiwu", "75_junqi6"},				
			},
			tbUnLockEvent = {},
		},	
		[15] = {nTime = 0 , nNum = 5,		-- 总计时
			tbPrelock = {14},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 3, 5, 15, "guaiwu", "75_weibing42"},				
			},
			tbUnLockEvent = {},
		},			
		[16] = {nTime = 5 , nNum = 0,		-- 总计时
			tbPrelock = {13 ,15},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=4672>：“第五道军令：两边的平台共有三面军旗，速速给我取来。”"},		
			},
			tbUnLockEvent = {},
		},			
		[17] = {nTime = 0 , nNum = 1,		-- 总计时
			tbPrelock = {16},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 2, 1, 17, "guaiwu", "75_junqi3"},				
			},
			tbUnLockEvent = {},
		},	
		[18] = {nTime = 0 , nNum = 3,		-- 总计时
			tbPrelock = {17},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 3, 3, 18, "guaiwu", "75_weibing51"},				
			},
			tbUnLockEvent = {},
		},
		[19] = {nTime = 0 , nNum = 1,		-- 总计时
			tbPrelock = {16},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 2, 1, 19, "guaiwu", "75_junqi5"},				
			},
			tbUnLockEvent = {},
		},	
		[20] = {nTime = 0 , nNum = 4,		-- 总计时
			tbPrelock = {19},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 3, 4, 20, "guaiwu", "75_weibing52"},				
			},
			tbUnLockEvent = {},
		},	
		[21] = {nTime = 0 , nNum = 1,		-- 总计时
			tbPrelock = {16},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 2, 1, 21, "guaiwu", "75_junqi7"},				
			},
			tbUnLockEvent = {},
		},	
		[22] = {nTime = 0 , nNum = 5,		-- 总计时
			tbPrelock = {21},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 3, 5, 22, "guaiwu", "75_weibing53"},				
			},
			tbUnLockEvent = {},
		},	
		[23] = {nTime = 5 , nNum = 0,		-- 总计时
			tbPrelock = {18 ,20, 22},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=4672>：“第六道军令：两边的平台各有两面军旗，速速给我取来。”"},		
			},
			tbUnLockEvent = {},
		},
		[24] = {nTime = 0 , nNum = 1,		-- 总计时
			tbPrelock = {23},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 2, 1, 24, "guaiwu", "75_junqi2"},				
			},
			tbUnLockEvent = {},
		},	
		[25] = {nTime = 0 , nNum = 4,		-- 总计时
			tbPrelock = {24},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 3, 4, 25, "guaiwu", "75_weibing61"},				
			},
			tbUnLockEvent = {},
		},
		[26] = {nTime = 0 , nNum = 1,		-- 总计时
			tbPrelock = {23},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 2, 1, 26, "guaiwu", "75_junqi4"},				
			},
			tbUnLockEvent = {},
		},	
		[27] = {nTime = 0 , nNum = 4,		-- 总计时
			tbPrelock = {26},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 3, 4, 27, "guaiwu", "75_weibing62"},				
			},
			tbUnLockEvent = {},
		},	
		[28] = {nTime = 0 , nNum = 1,		-- 总计时
			tbPrelock = {23},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 2, 1, 28, "guaiwu", "75_junqi6"},				
			},
			tbUnLockEvent = {},
		},	
		[29] = {nTime = 0 , nNum = 4,		-- 总计时
			tbPrelock = {28},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 3, 4, 29, "guaiwu", "75_weibing63"},				
			},
			tbUnLockEvent = {},
		},
		[30] = {nTime = 0 , nNum = 1,		-- 总计时
			tbPrelock = {23},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 2, 1, 30, "guaiwu", "75_junqi8"},				
			},
			tbUnLockEvent = {},
		},	
		[31] = {nTime = 0 , nNum = 4,		-- 总计时
			tbPrelock = {30},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 3, 4, 31, "guaiwu", "75_weibing64"},				
			},
			tbUnLockEvent = {},
		},	
		[32] = {nTime = 5, nNum = 0,
			tbPrelock = {25, 27, 29, 31},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=4672>：“如果部下都如你们这般优秀，定可成就一番惊天大业。”"},				
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "75_gouhuo"},
			},
		},
	}
}

tbRoom[76] = {}
CopyTable(tbRoom[23], tbRoom[76]);
tbRoom[76].nMapIndex = 3;
tbRoom[76].tbBeginPoint	= {53344 / 32, 93152 / 32};
tbRoom[76].LOCK[1].tbStartEvent[2] = {XoyoGame.MOVIE_DIALOG, -1, "这里风光明媚，会有什么惊奇在此等待我们呢？"};
tbRoom[76].LOCK[2].tbStartEvent[1] = {XoyoGame.MOVIE_DIALOG, -1, "叛军统领：“居然有人发现了我们的聚会地点，兄弟们，别留活口，给我杀！”"};
tbRoom[76].LOCK[2].tbUnLockEvent[2] = {XoyoGame.MOVIE_DIALOG, -1, "只听见有人大吼一声：萧捕头来了！顷刻间，剩下的叛军都已逃匿无踪，只剩下一个疑问萦绕在我们心中：萧捕头是何许人也？"};
tbRoom[76].LOCK[3].tbStartEvent[1] = {XoyoGame.ADD_NPC, 1, 26, 3, "guaiwu", "76_panjunshibing_2"};
tbRoom[76].LOCK[3].tbStartEvent[2] = {XoyoGame.ADD_NPC, 2, 2, 3, "guaiwu", "76_panjunshibing_1"};
tbRoom[76].LOCK[3].tbStartEvent[3] = {XoyoGame.ADD_NPC, 3, 2, 3, "guaiwu", "76_panjuntongling_1"};
tbRoom[76].LOCK[3].tbStartEvent[4] = {XoyoGame.ADD_NPC, 4, 2, 3, "guaiwu", "76_panjuntongling_2"};
tbRoom[76].LOCK[3].tbUnLockEvent[6] = {XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "76_gouhuo"};

tbRoom[77] = {}
CopyTable(tbRoom[34], tbRoom[77]);
tbRoom[77].nMapIndex = 5;
tbRoom[77].tbBeginPoint	= {55520 / 32, 78496 / 32};
tbRoom[77].LOCK[1].tbStartEvent[3] = {XoyoGame.ADD_NPC, 9, 4, 0, "qinghua", "77_qinghua"};
tbRoom[77].LOCK[3].tbStartEvent[1] = {XoyoGame.ADD_NPC, 1, 2, 3, "guaiwu", "77_youminggui_1"};
tbRoom[77].LOCK[3].tbStartEvent[2] = {XoyoGame.ADD_NPC, 2, 2, 3, "guaiwu", "77_youminggui_2"};
tbRoom[77].LOCK[3].tbStartEvent[3] = {XoyoGame.ADD_NPC, 3, 30, 3, "guaiwu", "77_youminggui_3"};
tbRoom[77].LOCK[4].tbStartEvent[1] = {XoyoGame.ADD_NPC, 3, 12, 0, "guaiwu", "77_youminggui_4"};
tbRoom[77].LOCK[4].tbStartEvent[2] = {XoyoGame.ADD_NPC, 4, 1, 4, "guaiwu", "77_youmingguiwang"};
tbRoom[77].LOCK[4].tbStartEvent[3] = {XoyoGame.ADD_NPC, 5, 1, 0, "guaiwu", "77_muzhuang_1"};
tbRoom[77].LOCK[4].tbStartEvent[4] = {XoyoGame.ADD_NPC, 6, 1, 0, "guaiwu", "77_muzhuang_2"};
tbRoom[77].LOCK[4].tbStartEvent[5] = {XoyoGame.ADD_NPC, 7, 1, 0, "guaiwu", "77_muzhuang_3"};
tbRoom[77].LOCK[4].tbStartEvent[6] = {XoyoGame.BLACK_MSG, -1, "突然感到背后传来一股强烈的寒气，赶紧顺着来路回去看看有什么东西！"};
tbRoom[77].LOCK[4].tbUnLockEvent[7] = {XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "77_gouhuo"};
-- 红莲使者-火蓬春（boss）
tbRoom[78] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 6,						-- 房间等级(1~5)
	nMapIndex		= {7,1},					-- 地图组的索引
	tbBeginPoint	= {1593, 3226},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 6735, nLevel = -1, nSeries = 5},		-- 火蓬春

	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "天色以近傍晚，前方有袅袅炊烟，这香气，附近有人在烹烧野味！"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 450, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=6735>：“就这点能耐还敢抢老子的东西。”"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.DEL_NPC, "guaiwu"},
			},
		},
		[3] = {nTime = 0, nNum = 1,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=6735>：“哪里来的野小子，敢动我红莲使者的晚餐。”"},
				{XoyoGame.ADD_NPC, 1, 1, 3, "guaiwu", "78_huopengchun"},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại Hỏa Bồng Xuân"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=6735>：“也罢，这次老子认栽了。。。”"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.CHANGE_FIGHT, -1, 0, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "78_gouhuo"},
			},
		},
	}
}

-- 寒冰之女-风雪晴（boss）
tbRoom[79] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 6,						-- 房间等级(1~5)
	nMapIndex		= {7,2},						-- 地图组的索引
	tbBeginPoint	= {1608, 3214},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 6736, nLevel = -1, nSeries =  4},		-- 风雪晴
		[2] = {nTemplate = 7350, nLevel = -1, nSeries = -1},		--雪人傀儡
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "这谷中天气当真变幻莫测，怎么突然感到阵阵寒意来袭。"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 480, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=6736>：“你们这点本事，和老娘还差五百年呢。”"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.DEL_NPC, "boss"},
				{XoyoGame.DEL_NPC, "xueren"},
			},
		},
		[3] = {nTime = 0, nNum = 1,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=6736>：“进入和寒冰女王的领域，看来一场恶战在所难免了。”"},
				{XoyoGame.ADD_NPC, 1, 1, 3, "boss", "79_fengxueqing"},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại Phong Tuyết Tình"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=6736>：“你们有点本事，可是你们不会一直走运下去的。。”"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[4]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[5]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.CHANGE_FIGHT, -1, 0, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "79_gouhuo"},
			},
		},
		[4] = {nTime = 150,nNum = 0,
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{},
		},
		[5] = {nTime = 300,nNum = 0,
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{},
		},
		[6] = {nTime = 0,nNum = 1,
			tbPrelock = {4},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 2, 1, 6, "xueren", "79_fengxueqing"},
				{XoyoGame.CHANGE_NPC_AI, "boss", XoyoGame.AI_ATTACK, "", 0},
				{XoyoGame.NPC_CAST_SKILL,"boss",1462,1},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.CHANGE_NPC_AI, "boss", XoyoGame.AI_ATTACK, "", 5},
				{XoyoGame.NPC_REMOVE_SKILL,"boss",1462},
			},
		},
		[7] = {nTime = 0,nNum = 1,
			tbPrelock = {5},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 2, 1, 7, "xueren", "79_fengxueqing"},
				{XoyoGame.CHANGE_NPC_AI, "boss", XoyoGame.AI_ATTACK, "", 0},
				{XoyoGame.NPC_CAST_SKILL,"boss",1462,1},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.CHANGE_NPC_AI, "boss", XoyoGame.AI_ATTACK, "", 5},
				{XoyoGame.NPC_REMOVE_SKILL,"boss",1462},
			},
		},
	}
}

-- 七心海棠-慕容素（boss）
tbRoom[80] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 6,						-- 房间等级(1~5)
	nMapIndex		= {7,3},						-- 地图组的索引
	tbBeginPoint	= {1601, 3244},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 6737, nLevel = -1, nSeries = 2},		-- 慕容素
		[2] = {nTemplate = 7351, nLevel = -1, nSeries = -1},

	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "这关看来也没什么稀奇的啦。"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 480, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=6737>：“你们为什么不和我玩啊，真无趣啊！”"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "jiangshi"},
			},
		},
		[3] = {nTime = 0, nNum = 1,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=6737>：“大哥哥，大姐姐，你们来陪我玩好吗，我们玩毒毒的游戏，如果你们死不了就是你们赢了。”"},
				{XoyoGame.ADD_NPC, 1, 1, 3, "guaiwu", "80_murongsu"},
				{XoyoGame.NPC_BLOOD_PERCENT,
					"guaiwu",
					{75,XoyoGame.ADD_NPC,2,50,0,"jiangshi","80_jiangshi"},
					{50,XoyoGame.ADD_NPC,2,50,0,"jiangshi","80_jiangshi"},
				 	{20,XoyoGame.ADD_NPC,2,50,0,"jiangshi","80_jiangshi"},		
				},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại Mộ Dung Tố"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=6737>：“不好玩，不好玩。我只用了三成功力了啦。。”"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.DEL_NPC,"jiangshi"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.CHANGE_FIGHT, -1, 0, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "80_gouhuo"},
			},
		},
	}
}

-- 金毛狮王-谢无忌（boss）
tbRoom[81] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 6,						-- 房间等级(1~5)
	nMapIndex		= {7,4},						-- 地图组的索引
	tbBeginPoint	= {1629, 3236},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 6738, nLevel = -1, nSeries = 1},		-- 谢无忌

	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "这里地势空旷，但怎么总是隐隐感到有那么点不安，难道是霸气外露。"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 480, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=6738>：“你们这功力，怎是一个弱字可以形容的！”"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.DEL_NPC, "guaiwu"},
			},
		},
		[3] = {nTime = 0, nNum = 1,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=6738>：“你们是何人，谁允许你们在逍遥谷随便走动的？”"},
				{XoyoGame.ADD_NPC, 1, 1, 3, "guaiwu", "81_xiewuji"},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại Tạ Vô Kỵ"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=6738>：“此地地势狭窄，无法发挥我的功力，待得来日你们到得襄阳，再行比试。”"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.CHANGE_FIGHT, -1, 0, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "81_gouhuo"},
			},
		},
	}
}

-- 银花婆婆（boss）
tbRoom[82] = 
{
	DerivedRoom		= XoyoGame.RoomYinHua;
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 7,						-- 房间等级(1~5)
	nMapIndex		= {7,5},						-- 地图组的索引
	tbBeginPoint	= {1586, 3197},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		-- [1] = {nTemplate = 7303, nLevel = -1, nSeries = 2},		-- 银花婆婆

	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "你进入了一块空地，远远听到有人在怒吼。"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 480, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=7303>：“快把我姐姐叫出来，不然我不客气了。”"},
				{XoyoGame.DO_SCRIPT, "self:CreateNpc()"},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại Ngân Hoa Bà Bà"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self:Clear()"},
				{XoyoGame.CHANGE_FIGHT, -1, 0, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=7303>：“快叫我姐姐金花婆婆出来！”"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
	}
}

-- 喜多多（boss）
tbRoom[83] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 6,						-- 房间等级(1~5)
	nMapIndex		= {7,6},						-- 地图组的索引
	tbBeginPoint	= {1605, 3217},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 7332, nLevel = -1, nSeries = -1},		-- 喜多多
		[2] = {nTemplate = 7333, nLevel = -1, nSeries = -1},		-- 多多连珠

	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "速速把我夫君交出来，不然我要不客气了。"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 480, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = 
			{},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=7332>：“螳臂当车，不自量力！”"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.DEL_NPC, "boss"},
				{XoyoGame.DEL_NPC, "guaiwu"},
			},
		},
		[3] = {nTime = 0, nNum = 1,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=7332>：“你们是何人，速速放我夫君出来见我”"},
				{XoyoGame.ADD_NPC, 1, 1, 3, "boss", "83_xiduoduo"},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại Hỷ Đa Đa"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=7332>：“好吧，看你们功力也不至于瞒我，我去别处寻找便是。”"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.DO_SCRIPT, "for i = 4,17 do self.tbLock[i]:Close() end"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.CHANGE_FIGHT, -1, 0, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "83_gouhuo"},
			},
		},
		[4] = {nTime = 60, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = {},
		},
		[5] = {nTime = 18, nNum = 0,		-- 总计时
			tbPrelock = {4},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC,2,1,4,"guaiwu","83_xiduoduo"},
				{XoyoGame.NPC_CAST_SKILL,"guaiwu",1884,10,nil,nil,1},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC,"guaiwu"},
			},
		},
		[6] = {nTime = 60, nNum = 0,		-- 总计时
			tbPrelock = {4},
			tbStartEvent = {},
			tbUnLockEvent = {},
		},
		[7] = {nTime = 18, nNum = 0,		-- 总计时
			tbPrelock = {6},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC,2,1,4,"guaiwu","83_xiduoduo"},
				{XoyoGame.NPC_CAST_SKILL,"guaiwu",1884,10,nil,nil,1},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC,"guaiwu"},
			},
		},
		[8] = {nTime = 60, nNum = 0,		-- 总计时
			tbPrelock = {6},
			tbStartEvent = {},
			tbUnLockEvent = {},
		},
		[9] = {nTime = 18, nNum = 0,		-- 总计时
			tbPrelock = {8},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC,2,1,4,"guaiwu","83_xiduoduo"},
				{XoyoGame.NPC_CAST_SKILL,"guaiwu",1884,10,nil,nil,1},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC,"guaiwu"},
			},
		},
		[10] = {nTime = 60, nNum = 0,		-- 总计时
			tbPrelock = {8},
			tbStartEvent = {},
			tbUnLockEvent = {},
		},
		[11] = {nTime = 18, nNum = 0,		-- 总计时
			tbPrelock = {10},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC,2,1,4,"guaiwu","83_xiduoduo"},
				{XoyoGame.NPC_CAST_SKILL,"guaiwu",1884,10,nil,nil,1},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC,"guaiwu"},
			},
		},
		[12] = {nTime = 60, nNum = 0,		-- 总计时
			tbPrelock = {10},
			tbStartEvent = {},
			tbUnLockEvent = {},
		},
		[13] = {nTime = 18, nNum = 0,		-- 总计时
			tbPrelock = {12},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC,2,1,4,"guaiwu","83_xiduoduo"},
				{XoyoGame.NPC_CAST_SKILL,"guaiwu",1884,10,nil,nil,1},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC,"guaiwu"},
			},
		},
		[14] = {nTime = 60, nNum = 0,		-- 总计时
			tbPrelock = {12},
			tbStartEvent = {},
			tbUnLockEvent = {},
		},
		[15] = {nTime = 18, nNum = 0,		-- 总计时
			tbPrelock = {14},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC,2,1,4,"guaiwu","83_xiduoduo"},
				{XoyoGame.NPC_CAST_SKILL,"guaiwu",1884,10,nil,nil,1},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC,"guaiwu"},
			},
		},
		[16] = {nTime = 60, nNum = 0,		-- 总计时
			tbPrelock = {14},
			tbStartEvent = {},
			tbUnLockEvent = {},
		},
		[17] = {nTime = 18, nNum = 0,		-- 总计时
			tbPrelock = {16},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC,2,1,4,"guaiwu","83_xiduoduo"},
				{XoyoGame.NPC_CAST_SKILL,"guaiwu",1884,10,nil,nil,1},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC,"guaiwu"},
			},
		},
	}
}

--学海无涯
tbRoom[84] = 
{
	DerivedRoom		= XoyoGame.RoomXueHaiWuYa;
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 6,						-- 房间等级(1~5)
	nMapIndex		= {7,7},					-- 地图组的索引
	tbBeginPoint	= {1599, 3207},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
	--	[1] = {nTemplate = 7334, nLevel = -1, nSeries = 2},		-- 银花婆婆

	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "你进入了逍遥谷外一块平地，远远看到一个人影"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 480, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=7334>:你们各个都是孤孤单单的，看我来教训你们"},
				{XoyoGame.DO_SCRIPT, "self:CreateNpc()"},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại Hàn Đan"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self:Clear()"},
				{XoyoGame.CHANGE_FIGHT, -1, 0, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=7334>:我已经不能改变很多事情了。"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
	}
}

-- 百草园
tbRoom[85] = 
{
	DerivedRoom		= XoyoGame.RoomBaiCaoYuan;
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 7,						-- 房间等级(1~5)
	nMapIndex		= {8,2},						-- 地图组的索引
	tbBeginPoint	= {1617, 3235},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
	--	[1] = {nTemplate = 7335, nLevel = -1, nSeries = 2},		-- 银花婆婆

	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "你来到一片种满花草的园子"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 480, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=7335>:谁也不许进入我的园子！"},
				{XoyoGame.DO_SCRIPT, "self:CreateNpc()"},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại Người làm vườn Trịnh Vũ Hoa"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self:Clear()"},
				{XoyoGame.CHANGE_FIGHT, -1, 0, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=7335>:等有本事了再来闯我的百草园吧！"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
	}
}

tbRoom[86] = --四散人出关
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 6,						-- 房间等级(1~5)
	nMapIndex		= {8,1},					-- 地图组的索引
	tbBeginPoint	= {1597, 3357},-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 7338, nLevel = -1, nSeries = -1},		-- 散人礼信
		[2] = {nTemplate = 7340, nLevel = -1, nSeries = -1},		-- 散人哑哑
		[3] = {nTemplate = 7339, nLevel = -1, nSeries = -1},		-- 散人柳雨凝
		[4] = {nTemplate = 7341, nLevel = -1, nSeries = -1},		-- 散人诗经
		[5] = {nTemplate = 7342, nLevel = -1, nSeries = -1},		-- 定身npc
		[6] = {nTemplate = 7343, nLevel = -1, nSeries = -1},		-- 喷火的花
		[7] = {nTemplate = 3192, nLevel = -1, nSeries =	-1},		-- 机关人爆伤害
		[8] = {nTemplate = 3193, nLevel = -1, nSeries =	-1},		-- 机关人反弹
		[9] = {nTemplate = 3194, nLevel = -1, nSeries =	-1},		-- 机关人普通
		[10] = {nTemplate = 3176, nLevel = -1, nSeries = -1},	    -- 机关人剑段
		[11] = {nTemplate = 3256, nLevel = -1, nSeries = -1},	    -- 障碍
		[12] = {nTemplate = 3242, nLevel = -1, nSeries = -1},	    -- 机关狼
		[14] = {nTemplate = 7345, nLevel = -1, nSeries = -1}, 		-- 多多连珠
		[15] = {nTemplate = 7344, nLevel = -1, nSeries = -1}, 		-- 机关
		[16] = {nTemplate = 7392, nLevel = -1, nSeries = -1},		-- 障碍
	},
	-- 锁结构                                                                                                                                                                                                                                                     
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
				{XoyoGame.CHANGE_TRAP, "86_trap1", {51584/32,107648/32}},
				{XoyoGame.CHANGE_TRAP, "86_trap2", {52512/32,107328/32}},
				{XoyoGame.CHANGE_TRAP, "86_trap3", {51008/32,104640/32}},
				{XoyoGame.CHANGE_TRAP, "86_trap4", {51328/32,103680/32}},
				{XoyoGame.ADD_NPC,16,5,0,"shuijing1","86_shuijing1"},
				{XoyoGame.ADD_NPC,16,4,0,"shuijing2","86_shuijing2"},
				{XoyoGame.ADD_NPC,16,4,0,"shuijing3","86_shuijing3"},
				{XoyoGame.ADD_NPC,16,5,0,"shuijing4","86_shuijing4"},	
			},
			tbUnLockEvent = {},
		},
		[2] = {nTime = 480, nNum = 0,		-- 总时间
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "这人目露凶光，恐怕对我们不利。"},
				{XoyoGame.ADD_NPC, 1, 1, 3, "bossA", "86_bossA"},		-- 散人A
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},	
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC,"bossB"},
				{XoyoGame.DEL_NPC,"bossA"},
				{XoyoGame.DEL_NPC,"bossC"},
				{XoyoGame.DEL_NPC,"bossD"},
				{XoyoGame.DEL_NPC,"shuijing1"},
				{XoyoGame.DEL_NPC,"shuijing2"},
				{XoyoGame.DEL_NPC,"shuijing3"},
				{XoyoGame.DEL_NPC,"shuijing4"},
				{XoyoGame.DEL_NPC,"xiaoguai1"},
				{XoyoGame.DEL_NPC,"dingshen1"},
				{XoyoGame.DEL_NPC,"xiaoguai2"},
				{XoyoGame.DEL_NPC,"penhuohua"},
				{XoyoGame.DEL_NPC,"duoduo"},
				{XoyoGame.DEL_NPC,"jiguan"},
				{XoyoGame.DEL_NPC,"dingshen2"},
				{XoyoGame.CHANGE_FIGHT, -1, 0, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.CHANGE_TRAP, "86_trap1", nil},
				{XoyoGame.CHANGE_TRAP, "86_trap2", nil},
				{XoyoGame.CHANGE_TRAP, "86_trap3", nil},
				{XoyoGame.CHANGE_TRAP, "86_trap4", nil},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=7338>：无知小贼，还不速速离去，免得扰了我们清静……"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 0, nNum = 1,		-- 任务开始
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=7338>：速来受死。"},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại Thư Mời"},
			},
			tbUnLockEvent = {
			    {XoyoGame.TARGET_INFO, -1, "Tiến về phía trước, cẩn thận cạm bẩy"},
				{XoyoGame.CHANGE_TRAP, "86_trap1", nil},
				{XoyoGame.DEL_NPC,"shuijing1"},
				{XoyoGame.ADD_NPC, 9, 12, 5, "xiaoguai1", "86_xiaoguai1"},				-- 机关人
				{XoyoGame.ADD_NPC, 5, 1, 0, "dingshen1", "86_dingshen1"},               -- 定身npc
			},
		},
		[4] = {nTime = 15, nNum = 0,		--	散人B开始活动
			tbPrelock = {3},
			tbStartEvent = 
			{},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=7340>：前面小贼莫跑，待我追上便给好友报此一仇。"},
				{XoyoGame.ADD_NPC, 2, 1, 0, "bossB", "86_bossB"},		--散人B
				{XoyoGame.ADD_NPC_SKILL,"bossB",2080,1},	--测试用必杀技
				{XoyoGame.CHANGE_NPC_AI, "bossB",XoyoGame.AI_MOVE,"lv7_86_bossB",0,100,0,0,5,100},	-- 自动走路释放技能AI（不会啊不会）	
			},
		},
		[5] = {nTime = 0, nNum = 12 ,
			tbPrelock = {3},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "dingshen1"},
				{XoyoGame.CHANGE_TRAP, "86_trap2", nil},
				{XoyoGame.DEL_NPC,"shuijing2"},
				{XoyoGame.ADD_NPC, 9, 12, 6, "xiaoguai2", "86_xiaoguai2"},		-- 机关人
				{XoyoGame.ADD_NPC, 6, 6, 0, "penhuohua", "86_penhuohua"},       -- 喷火npc
				{XoyoGame.ADD_NPC, 14, 1,0, "duoduo", "86_duoduolianzhu"},      -- 多多连珠
			},
		},
		[6] = {nTime = 0, nNum = 12,
			tbPrelock = {5},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=7340>：等着吧，前面还有精通机关的老友等着你们，受死吧"},
				{XoyoGame.DEL_NPC, "penhuohua"},
				{XoyoGame.DEL_NPC, "duoduo"},
				{XoyoGame.CHANGE_TRAP, "86_trap3", nil},
				{XoyoGame.DEL_NPC,"shuijing3"},
				{XoyoGame.ADD_NPC, 3, 1, 7, "bossC", "86_bossC"},		-- 散人C
				{XoyoGame.ADD_NPC, 15, 1, 8, "jiguan", "86_kaimenjiguan"},		-- 机关
				{XoyoGame.NPC_CAN_TALK,"jiguan",0},
			},
		},
		[7] = {nTime = 0, nNum = 1,
			tbPrelock = {6},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.NPC_CAN_TALK,"jiguan",1},
			},
		},
		[8] = {nTime = 0, nNum = 1,
			tbPrelock = {7},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.CHANGE_TRAP, "86_trap4", nil},
				{XoyoGame.DEL_NPC,"shuijing4"},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=7341>：你们竟然连她也杀了，我自然不能饶过你们……"},
				{XoyoGame.ADD_NPC, 5, 1, 0, "dingshen2", "86_dingshen2"},		-- 定身npc
				{XoyoGame.ADD_NPC, 4, 1, 9, "bossD", "86_bossD"},		-- 散人D
			},
		},
		[9] = {nTime = 0, nNum = 1,
			tbPrelock = {8},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.DEL_NPC,"bossB"},
				{XoyoGame.DEL_NPC,"bossA"},
				{XoyoGame.DEL_NPC,"bossC"},
				{XoyoGame.DEL_NPC,"bossD"},
				{XoyoGame.DEL_NPC,"xiaoguai1"},
				{XoyoGame.DEL_NPC,"dingshen1"},
				{XoyoGame.DEL_NPC,"xiaoguai2"},
				{XoyoGame.DEL_NPC,"penhuohua"},
				{XoyoGame.DEL_NPC,"duoduo"},
				{XoyoGame.DEL_NPC,"jiguan"},
				{XoyoGame.DEL_NPC,"dingshen2"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.CHANGE_FIGHT, -1, 0, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=7339>：既然被你们逃了出去，也罢，不要让我再看到你们。"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "86_gouhuo"},
			},
		},
	}
}


-- 璇静双姝（boss）
tbRoom[87] = 
{
	DerivedRoom		= XoyoGame.RoomXuanjingShuangZhu,
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 7,						-- 房间等级(1~5)
	nMapIndex		= {8,4},					-- 地图组的索引
	tbBeginPoint	= {1588, 3200},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 6739, nLevel = -1, nSeries = 5},		-- 叶璇
		[2] = {nTemplate = 6740, nLevel = -1, nSeries = 4},		-- 叶静
		[3] = {nTemplate = 6741, nLevel = -1, nSeries = 5},		-- 叶璇2
		[4] = {nTemplate = 6742, nLevel = -1, nSeries = 4},		-- 叶静2

	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "这股阴森的气息，仿佛我们来到了一个不该来的地方。"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 480, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "“胜败乃兵家常事，大侠请重新来过。”"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.DEL_NPC, "yejing"},
				{XoyoGame.DEL_NPC, "yexuan"},
				{XoyoGame.DEL_NPC, "yejing2"},
				{XoyoGame.DEL_NPC, "yexuan2"},				
			},
		},
		[3] = {nTime = 0, nNum = 1,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=6739>：“妹子，我们这片林子有客人到了呢，看来今天谷里来了了不起的人物了呢。”<end><npc=6740>：“姐姐，好久没看到您显露功夫了，不如今天露一手给小妹开开眼啊！”<end>"},
				{XoyoGame.ADD_NPC, 1, 1, 3, "yexuan", "87_yexuan"},
				{XoyoGame.TARGET_INFO, -1, "Hạ gục Diệp Toàn"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=6739>：“妹子，姐姐先去疗伤，去去就来！”"},
				{XoyoGame.DO_SCRIPT, "self:RecordBlood([[yejing]])"},		-- 记录叶静血量
				{XoyoGame.DO_SCRIPT, "for i = 7,22 do self.tbLock[i]:Close() end"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[4]:Close()"},
				{XoyoGame.DEL_NPC, "yejing"},
			},
		},
		[4] = {nTime = 0, nNum = 1,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 2, 1, 4, "yejing", "87_yejing"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=6740>：“姐姐，妹妹先去疗伤，去去就来！”"},
				{XoyoGame.DO_SCRIPT, "self:RecordBlood([[yexuan]])"},		-- 记录叶璇血量
				{XoyoGame.DO_SCRIPT, "for i = 7,22 do self.tbLock[i]:Close() end"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[3]:Close()"},
				{XoyoGame.DEL_NPC, "yexuan"},
			},
		},
		[5] = {nTime = 0, nNum = 1,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 4, 1, 5, "yejing2", "87_yejing"},
				{XoyoGame.DO_SCRIPT,"self:SetNpcBlood([[yejing2]])"},
				{XoyoGame.TARGET_INFO, -1, "Hạ gục Diệp Tịnh"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "“一场苦战，也许这是我们进入逍遥谷以来最强的对手了。”"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.CHANGE_FIGHT, -1, 0, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "87_gouhuo"},
			},
		},
		[6] = {nTime = 0, nNum = 1,
			tbPrelock = {4},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 3, 1, 6, "yexuan2", "87_yexuan"},
				{XoyoGame.DO_SCRIPT,"self:SetNpcBlood([[yexuan2]])"},
				{XoyoGame.TARGET_INFO, -1, "Hạ gục Toàn Tịnh"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "“一场苦战，也许这是我们进入逍遥谷以来最强的对手了。”"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.CHANGE_FIGHT, -1, 0, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "87_gouhuo"},
			},
		},
		[7] = {nTime = 5, nNum = 0,
			tbPrelock = {1},
			tbStartEvent = 
			{},
			tbUnLockEvent = 
			{
				{XoyoGame.NPC_CAST_SKILL,"yexuan",2087,10,nil,nil,1},
				{XoyoGame.NPC_CAST_SKILL,"yejing",2088,20,nil,nil,1},
			},
		},
		[8] = {nTime = 30, nNum = 0,
			tbPrelock = {7},
			tbStartEvent = 
			{},
			tbUnLockEvent = 
			{
				{XoyoGame.NPC_CAST_SKILL,"yejing",2087,10,nil,nil,1},
				{XoyoGame.NPC_CAST_SKILL,"yexuan",2088,20,nil,nil,1},
			},
		},
		[9] = {nTime = 30, nNum = 0,
			tbPrelock = {8},
			tbStartEvent = 
			{},
			tbUnLockEvent = 
			{
				{XoyoGame.NPC_CAST_SKILL,"yexuan",2087,10,nil,nil,1},
				{XoyoGame.NPC_CAST_SKILL,"yejing",2088,20,nil,nil,1},
			},
		},
		[10] = {nTime = 30, nNum = 0,
			tbPrelock = {9},
			tbStartEvent = 
			{},
			tbUnLockEvent = 
			{
				{XoyoGame.NPC_CAST_SKILL,"yejing",2087,10,nil,nil,1},
				{XoyoGame.NPC_CAST_SKILL,"yexuan",2088,20,nil,nil,1},
			},
		},
		[11] = {nTime = 30, nNum = 0,
			tbPrelock = {10},
			tbStartEvent = 
			{},
			tbUnLockEvent = 
			{
				{XoyoGame.NPC_CAST_SKILL,"yexuan",2087,10,nil,nil,1},
				{XoyoGame.NPC_CAST_SKILL,"yejing",2088,20,nil,nil,1},
			},
		},
		[12] = {nTime = 30, nNum = 0,
			tbPrelock = {11},
			tbStartEvent = 
			{},
			tbUnLockEvent = 
			{
				{XoyoGame.NPC_CAST_SKILL,"yejing",2087,10,nil,nil,1},
				{XoyoGame.NPC_CAST_SKILL,"yexuan",2088,20,nil,nil,1},
			},
		},
		[13] = {nTime = 30, nNum = 0,
			tbPrelock = {12},
			tbStartEvent = 
			{},
			tbUnLockEvent = 
			{
				{XoyoGame.NPC_CAST_SKILL,"yexuan",2087,10,nil,nil,1},
				{XoyoGame.NPC_CAST_SKILL,"yejing",2088,20,nil,nil,1},
			},
		},
		[14] = {nTime = 30, nNum = 0,
			tbPrelock = {13},
			tbStartEvent = 
			{},
			tbUnLockEvent = 
			{
				{XoyoGame.NPC_CAST_SKILL,"yejing",2087,10,nil,nil,1},
				{XoyoGame.NPC_CAST_SKILL,"yexuan",2088,20,nil,nil,1},
			},
		},
		[15] = {nTime = 30, nNum = 0,
			tbPrelock = {14},
			tbStartEvent = 
			{},
			tbUnLockEvent = 
			{
				{XoyoGame.NPC_CAST_SKILL,"yexuan",2087,10,nil,nil,10},
				{XoyoGame.NPC_CAST_SKILL,"yejing",2088,20,nil,nil,20},
			},
		},
		[16] = {nTime = 30, nNum = 0,
			tbPrelock = {15},
			tbStartEvent = 
			{},
			tbUnLockEvent = 
			{
				{XoyoGame.NPC_CAST_SKILL,"yejing",2087,10,nil,nil,1},
				{XoyoGame.NPC_CAST_SKILL,"yexuan",2088,20,nil,nil,1},
			},
		},
		[17] = {nTime = 30, nNum = 0,
			tbPrelock = {16},
			tbStartEvent = 
			{},
			tbUnLockEvent = 
			{
				{XoyoGame.NPC_CAST_SKILL,"yexuan",2087,10,nil,nil,1},
				{XoyoGame.NPC_CAST_SKILL,"yejing",2088,20,nil,nil,1},
			},
		},
		[18] = {nTime = 30, nNum = 0,
			tbPrelock = {17},
			tbStartEvent = 
			{},
			tbUnLockEvent = 
			{
				{XoyoGame.NPC_CAST_SKILL,"yejing",2087,10,nil,nil,1},
				{XoyoGame.NPC_CAST_SKILL,"yexuan",2088,20,nil,nil,1},
			},
		},
		[19] = {nTime = 30, nNum = 0,
			tbPrelock = {18},
			tbStartEvent = 
			{},
			tbUnLockEvent = 
			{
				{XoyoGame.NPC_CAST_SKILL,"yexuan",2087,10,nil,nil,1},
				{XoyoGame.NPC_CAST_SKILL,"yejing",2088,20,nil,nil,1},
			},
		},
		[20] = {nTime = 30, nNum = 0,
			tbPrelock = {19},
			tbStartEvent = 
			{},
			tbUnLockEvent = 
			{
				{XoyoGame.NPC_CAST_SKILL,"yejing",2087,10,nil,nil,1},
				{XoyoGame.NPC_CAST_SKILL,"yexuan",2088,20,nil,nil,1},
			},
		},
		[21] = {nTime = 30, nNum = 0,
			tbPrelock = {20},
			tbStartEvent = 
			{},
			tbUnLockEvent = 
			{
				{XoyoGame.NPC_CAST_SKILL,"yexuan",2087,10,nil,nil,1},
				{XoyoGame.NPC_CAST_SKILL,"yejing",2088,20,nil,nil,1},
			},
		},
		[22] = {nTime = 30, nNum = 0,
			tbPrelock = {21},
			tbStartEvent = 
			{},
			tbUnLockEvent = 
			{
				{XoyoGame.NPC_CAST_SKILL,"yejing",2087,10,nil,nil,1},
				{XoyoGame.NPC_CAST_SKILL,"yexuan",2088,20,nil,nil,1},
			},
		},
	}
}

-- 影之白秋琳（boss）
tbRoom[88] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 7,						-- 房间等级(1~5)
	nMapIndex		= {8,3},					-- 地图组的索引
	tbBeginPoint	= {1598, 3197},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 6743, nLevel = -1, nSeries = 5},		-- 白秋琳站立
		[2] = {nTemplate = 6755, nLevel = -1, nSeries = 5},		-- 白秋琳护送1
		[3] = {nTemplate = 6756, nLevel = -1, nSeries = 5},		-- 白秋琳护送2
		[4] = {nTemplate = 6744, nLevel = -1, nSeries = 5},		-- 白秋琳冻结
		[5] = {nTemplate = 6745, nLevel = -1, nSeries = 5},		-- 白秋琳战斗
		[6] = {nTemplate = 6749, nLevel = -1, nSeries = 5},		-- 高升站立
		[7] = {nTemplate = 6757, nLevel = -1, nSeries = 5},		-- 高升护送
		[8] = {nTemplate = 6759, nLevel = -1, nSeries = 5},		-- 高升战斗
		[9] = {nTemplate = 6750, nLevel = -1, nSeries = 5},		-- 崔剑站立
		[10] = {nTemplate = 6758, nLevel = -1, nSeries = 5},		-- 崔剑护送
		[11] = {nTemplate = 6760, nLevel = -1, nSeries = 5},		-- 崔剑战斗
		[12] = {nTemplate = 6761, nLevel = -1, nSeries = 5},		-- 黑山妖王
		[13] = {nTemplate = 6746, nLevel = -1, nSeries = 3},		-- 暗影白秋琳
		[14] = {nTemplate = 6747, nLevel = -1, nSeries = 3},		-- 暗影白秋琳战斗

	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "义军首领白秋琳带着两位义军精英，此刻都在逍遥谷，莫非有什么大事。！"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
				{XoyoGame.ADD_NPC, 1, 1, 0, "zhanli_bai", "88_baiqiulin1"},
				{XoyoGame.ADD_NPC, 6, 1, 0, "zhanli_gao", "88_gaosheng1"},
				{XoyoGame.ADD_NPC, 9, 1, 0, "zhanli_cui", "88_cuijian1"},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 480, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},			
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=6743>：“让他跑掉了，下次一定不能放过他。”"},
				{XoyoGame.DEL_NPC,"zhandou_gao"},
				{XoyoGame.DEL_NPC,"zhandou_cui"},
				{XoyoGame.DEL_NPC,"boss"},
				{XoyoGame.DEL_NPC,"dongjie_bai"},
				{XoyoGame.DEL_NPC,"zhandou_bai"},
				{XoyoGame.CHANGE_FIGHT, -1, 0, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 3, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.SEND_CHAT, "zhanli_bai", "远远的感到，这山坡之上有古怪的妖气，我们上去看看走吧！"},
			},
			tbUnLockEvent = {},
		},
		[4] = {nTime = 0, nNum = 1,		-- 护送白秋琳先走
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.DEL_NPC, "zhanli_bai"},
				{XoyoGame.ADD_NPC, 2, 1, 0, "husong_bai", "88_baiqiulin1"},
				{XoyoGame.CHANGE_NPC_AI, "husong_bai", XoyoGame.AI_MOVE, "lv7_88_baiqiulin1", 4, 100, 1},	-- 护送AI
				{XoyoGame.ADD_NPC, 12, 1, 0, "heishan", "88_heishanyaowang"},
			},
			tbUnLockEvent = {},
		},
		[5] = {nTime = 0, nNum = 1,		--  一起走
			tbPrelock = {4},
			tbStartEvent = 
			{
				{XoyoGame.CHANGE_NPC_AI, "husong_bai", XoyoGame.AI_MOVE, "lv7_88_baiqiulin2", 5, 100, 1},	-- 护送AI
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "husong_bai"},
				{XoyoGame.ADD_NPC, 1, 1, 0, "zhanli_bai", "88_baiqiulin2"},
				{XoyoGame.SEND_CHAT, "zhanli_bai", "<pic=2>!!!"},
			},
		},
		[6] = {nTime = 0, nNum = 1,		-- 一起走
			tbPrelock = {4},
			tbStartEvent = 
			{
				{XoyoGame.DEL_NPC, "zhanli_gao"},
				{XoyoGame.ADD_NPC, 7, 1, 0, "husong_gao", "88_baiqiulin1"},
				{XoyoGame.CHANGE_NPC_AI, "husong_gao", XoyoGame.AI_MOVE, "lv7_88_gaosheng", 6, 100, 1},	-- 护送AI
			},
			tbUnLockEvent =
			{
				{XoyoGame.DEL_NPC, "husong_gao"},
				{XoyoGame.ADD_NPC, 6, 1, 0, "zhanli_gao", "88_gaosheng2"},
				{XoyoGame.SEND_CHAT, "zhanli_gao", "<pic=32>"},
			},
		},
		[7] = {nTime = 0, nNum = 1,		-- 一起走
			tbPrelock = {4},
			tbStartEvent = 
			{
				{XoyoGame.DEL_NPC, "zhanli_cui"},
				{XoyoGame.ADD_NPC, 10, 1, 0, "husong_cui", "88_baiqiulin1"},
				{XoyoGame.CHANGE_NPC_AI, "husong_cui", XoyoGame.AI_MOVE, "lv7_88_cuijian", 7, 100, 1},	-- 护送AI
			},
			tbUnLockEvent =
			{
				{XoyoGame.DEL_NPC, "husong_cui"},
				{XoyoGame.ADD_NPC, 9, 1, 0, "zhanli_cui", "88_cuijian2"},
				{XoyoGame.SEND_CHAT, "zhanli_cui", "<pic=32>"},
			},
		},
		[8] = {nTime = 2, nNum = 0,		--  一起走
			tbPrelock = {5},
			tbStartEvent = 
			{
				{XoyoGame.SEND_CHAT, "heishan", "白秋琳，义军众位，我等你们好久了。"},
			},
			tbUnLockEvent = {},
		},
		[9] = {nTime = 3, nNum = 0,		--  对话
			tbPrelock = {8},
			tbStartEvent = 
			{
				{XoyoGame.SEND_CHAT, "zhanli_bai", "去年清明的禅境花园一战，你不是已经死了吗？怎么出现在这里。"},
			},
			tbUnLockEvent = {},
		},
		[10] = {nTime = 3, nNum = 0,		--  对话
			tbPrelock = {9},
			tbStartEvent = 
			{
				{XoyoGame.SEND_CHAT, "heishan", "本王怎么可能如此轻易的被几株蘑菇打败啊。"},
			},
			tbUnLockEvent = {},
		},
		[11] = {nTime = 3, nNum = 0,		--  对话
			tbPrelock = {10},
			tbStartEvent = 
			{
				{XoyoGame.SEND_CHAT, "heishan", "天堂有路你不走，地狱无门自来投。"},
			},
			tbUnLockEvent = {},
		},
		[12] = {nTime = 3, nNum = 0,		--  对话
			tbPrelock = {11},
			tbStartEvent = 
			{
				{XoyoGame.SEND_CHAT, "heishan", "本来打算找个良辰吉日本王亲自去伏牛山找你，没想到今天却送上门来了。"},
			},
			tbUnLockEvent = {},
		},
		[13] = {nTime = 2, nNum = 0,		--  对话
			tbPrelock = {12},
			tbStartEvent = 
			{
				{XoyoGame.SEND_CHAT, "heishan", "也罢，今日的逍遥谷便是你的葬身之地。"},
			},
			tbUnLockEvent = {},
		},
		[14] = {nTime = 2, nNum = 0,		--  对话
			tbPrelock = {13},
			tbStartEvent = 
			{
				{XoyoGame.SEND_CHAT, "zhanli_bai", "你这妖孽也太过狂妄，你道我们当真惧怕你不成？"},
			},
			tbUnLockEvent = {},
		},
		[15] = {nTime = 1, nNum = 0,		--  对话
			tbPrelock = {14},
			tbStartEvent = 
			{
				{XoyoGame.SEND_CHAT, "heishan", "哈哈哈，那就让你们见识一下我的手段，你看看，这是什么？"},
			},
			tbUnLockEvent = {},
		},
		[16] = {nTime = 1, nNum = 0,		--  对话
			tbPrelock = {15},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 13, 1, 0, "anying_1", "88_anyingbaiqiulin"},
			},
			tbUnLockEvent =
			{
				{XoyoGame.SEND_CHAT, "zhanli_bai", "<pic=66>"},
				{XoyoGame.SEND_CHAT, "zhanli_gao", "<pic=66>"},
				{XoyoGame.SEND_CHAT, "zhanli_cui", "<pic=66>"},
			},
		},
		[17] = {nTime = 3, nNum = 0,		--  对话
			tbPrelock = {16},
			tbStartEvent = 
			{
				{XoyoGame.SEND_CHAT, "heishan", "惊讶吗？"},
			},
			tbUnLockEvent = {},
		},
		[18] = {nTime = 3, nNum = 0,		--  对话
			tbPrelock = {17},
			tbStartEvent = 
			{
				{XoyoGame.SEND_CHAT, "zhanli_bai", "这……这是什么？"},
			},
			tbUnLockEvent = {},
		},
		[19] = {nTime = 3, nNum = 0,		--  对话
			tbPrelock = {18},
			tbStartEvent = 
			{
				{XoyoGame.SEND_CHAT, "heishan", "我来告诉你，这就是真实的你。"},
			},
			tbUnLockEvent = {},
		},
		[20] = {nTime = 3, nNum = 0,		--  对话
			tbPrelock = {19},
			tbStartEvent = 
			{
				{XoyoGame.SEND_CHAT, "heishan", "下面就由她陪你们玩玩吧，本王还有其他事情要做。哈哈哈哈~~"},
			},
			tbUnLockEvent = {},
		},
		[21] = {nTime = 5, nNum = 0,		--  对话
			tbPrelock = {20},
			tbStartEvent = 
			{
				{XoyoGame.SEND_CHAT, "zhanli_bai", "来者不善，兄弟们准备战斗！"},
				{XoyoGame.DEL_NPC, "zhanli_gao"},
				{XoyoGame.DEL_NPC, "zhanli_cui"},
				{XoyoGame.DEL_NPC, "heishan"},
				{XoyoGame.ADD_NPC, 8, 1, 0, "zhandou_gao", "88_gaosheng2"},
				{XoyoGame.ADD_NPC, 11, 1, 0, "zhandou_cui", "88_cuijian2"},
			},
			tbUnLockEvent = {},
		},
		[22] = {nTime = 0, nNum = 1,
			tbPrelock = {21},
			tbStartEvent = 
			{
				{XoyoGame.DEL_NPC, "zhanli_bai"},
				{XoyoGame.ADD_NPC, 4, 1, 0, "dongjie_bai", "88_baiqiulin2"},
				{XoyoGame.DEL_NPC, "anying_1"},
				{XoyoGame.ADD_NPC, 14, 1, 22, "boss", "88_anyingbaiqiulin"},
				{XoyoGame.NPC_BLOOD_PERCENT,
					"boss",
					{10,XoyoGame.DEL_NPC,"dongjie_bai"},
					{10,XoyoGame.ADD_NPC,5,1,0,"zhandou_bai","88_baiqiulin2"},
					{10,XoyoGame.BLACK_MSG,-1,"我的事情，我自己来解决！"},
				},
				{XoyoGame.TARGET_INFO, -1, "Hạ Ảo Ảnh Bạch Thu Lâm"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=6743>：“逍遥谷竟然有这等人物潜伏其中，不能等闲视之了。”"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.DEL_NPC,"zhandou_gao"},
				{XoyoGame.DEL_NPC,"zhandou_cui"},
				{XoyoGame.DEL_NPC,"boss"},
				{XoyoGame.DEL_NPC,"zhandou_bai"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.CHANGE_FIGHT, -1, 0, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.FINISH_ACHIEVE,-1,368},	--完成成就
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "88_gouhuo"},
			},
		},
	}
}

-- 逍遥谷主（boss）
tbRoom[89] = 
{
	DerivedRoom		= XoyoGame.RoomXoyoGuzhu,
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 8,						-- 房间等级(1~5)
	nMapIndex		= {9,1},					-- 地图组的索引
	tbBeginPoint	= {1590, 3231},				-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 6751, nLevel = -1, nSeries = 3},		-- 谷主1
		[2] = {nTemplate = 6752, nLevel = -1, nSeries = 3},		-- 谷主2
		[3] = {nTemplate = 6753, nLevel = -1, nSeries = 3},		-- 谷主3
		[4] = {nTemplate = 6754, nLevel = -1, nSeries = 3},		-- 谷主4

	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "经历了重重险关，这里应该就是逍遥谷主的宅邸了！"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 600, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=6751>：“最快乐的寂寞是独处，最寂寞的快乐是无敌，我在这里等你。”"},
				{XoyoGame.CHANGE_FIGHT, -1, 0, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[9]:Close()"},
				{XoyoGame.DEL_NPC, "boss4"},
				{XoyoGame.DEL_NPC, "boss1"},
				{XoyoGame.DEL_NPC, "boss2"},
				{XoyoGame.DEL_NPC, "boss3"},
			},
		},
		[3] = {nTime = 0, nNum = 1,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=6751>：“利剑之道，凌厉刚猛，无坚不摧。”"},
				{XoyoGame.ADD_NPC, 1, 1, 3, "boss1", "89_guzhu1"},
				{XoyoGame.NPC_BLOOD_PERCENT,
					"boss1",
					{51,XoyoGame.CHANGE_NPC_AI, "boss1", XoyoGame.AI_ATTACK, "", 0},
					{51,XoyoGame.DO_SCRIPT, "self:RecordBlood([[boss1]])"},
					{51,XoyoGame.NEW_WORLD_PLAYER,-1,1537,3304},
					{51,XoyoGame.DO_SCRIPT, "self.tbLock[4]:UnLock()"},
					{51,XoyoGame.DO_SCRIPT, "self.tbLock[3]:Close()"},
				},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại Độc Cô Kiếm"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=6751>：“你们赢了，这逍遥谷所有的这一切都将臣服于你。”"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[4]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.CHANGE_FIGHT, -1, 0, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				--{XoyoGame.NEW_MSG_PLAYER,"通过了地狱第八关",XoyoGame.TOALLGAMESERVER},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "89_gouhuo1"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "89_gouhuo2"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "89_gouhuo3"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "89_gouhuo4"},
			},
		},
		[4] = {nTime = 150, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self:RecordBlood([[boss1]])"},
				{XoyoGame.NEW_WORLD_PLAYER,-1,1537,3304},
				{XoyoGame.DO_SCRIPT, "self.tbLock[3]:Close()"},
			},
		},
		[5] = {nTime = 0, nNum = 1,
			tbPrelock = {4},
			tbStartEvent = 
			{
				{XoyoGame.DEL_NPC, "boss1"},
				{XoyoGame.ADD_NPC, 2, 1, 5, "boss2", "89_guzhu2"},
				{XoyoGame.DO_SCRIPT,"self:SetNpcBlood([[boss2]])"},
				{XoyoGame.NPC_BLOOD_PERCENT,
					"boss2",
					{26,XoyoGame.CHANGE_NPC_AI, "boss2", XoyoGame.AI_ATTACK, "", 0},
					{26,XoyoGame.DO_SCRIPT, "self:RecordBlood([[boss2]])"},
					{26,XoyoGame.NEW_WORLD_PLAYER,-1,1699,3286},
					{26,XoyoGame.DO_SCRIPT, "self.tbLock[6]:UnLock()"},
					{26,XoyoGame.DO_SCRIPT, "self.tbLock[5]:Close()"},
					
				},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại Độc Cô Kiếm"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=6751>：“你们赢了，这逍遥谷所有的这一切都将臣服于你。”"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[6]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.CHANGE_FIGHT, -1, 0, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				--{XoyoGame.NEW_MSG_PLAYER,"通过了地狱第八关",XoyoGame.TOALLGAMESERVER},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "89_gouhuo1"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "89_gouhuo2"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "89_gouhuo3"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "89_gouhuo4"},
			},
		},
		[6] = {nTime = 150, nNum = 0,		-- 总计时
			tbPrelock = {4},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self:RecordBlood([[boss2]])"},
				{XoyoGame.NEW_WORLD_PLAYER,-1,1699,3286},
				{XoyoGame.DO_SCRIPT, "self.tbLock[5]:Close()"},
			},
		},
		[7] = {nTime = 0, nNum = 1,
			tbPrelock = {6},
			tbStartEvent = 
			{
				{XoyoGame.DEL_NPC, "boss2"},
				{XoyoGame.ADD_NPC, 3, 1, 7, "boss3", "89_guzhu3"},
				{XoyoGame.DO_SCRIPT,"self:SetNpcBlood([[boss3]])"},
				{XoyoGame.NPC_BLOOD_PERCENT,
					"boss3",
					{11,XoyoGame.CHANGE_NPC_AI, "boss3", XoyoGame.AI_ATTACK, "", 0},
					{11,XoyoGame.DO_SCRIPT, "self:RecordBlood([[boss3]])"},
					{11,XoyoGame.NEW_WORLD_PLAYER,-1,1622,3389},
					{11,XoyoGame.DO_SCRIPT,"self.tbLock[8]:UnLock()"},
					{11,XoyoGame.DO_SCRIPT,"self.tbLock[7]:Close()"},
				},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại Độc Cô Kiếm"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=6751>：“你们赢了，这逍遥谷所有的这一切都将臣服于你。”"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[8]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.CHANGE_FIGHT, -1, 0, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				--{XoyoGame.NEW_MSG_PLAYER,"通过了地狱第八关",XoyoGame.TOALLGAMESERVER},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "89_gouhuo1"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "89_gouhuo2"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "89_gouhuo3"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "89_gouhuo4"},
			},
		},
		[8] = {nTime = 150, nNum = 0,		-- 总计时
			tbPrelock = {6},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self:RecordBlood([[boss3]])"},
				{XoyoGame.NEW_WORLD_PLAYER,-1,1622,3389},
				{XoyoGame.DO_SCRIPT, "self.tbLock[7]:Close()"},
			},
		},
		[9] = {nTime = 0, nNum = 1,
			tbPrelock = {8},
			tbStartEvent = 
			{
				{XoyoGame.DEL_NPC, "boss3"},
				{XoyoGame.ADD_NPC, 4, 1, 9, "boss4", "89_guzhu4"},
				{XoyoGame.DO_SCRIPT,"self:SetNpcBlood([[boss4]])"},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại Độc Cô Kiếm"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=6751>：“你们赢了，这逍遥谷所有的这一切都将臣服于你。”"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.CHANGE_FIGHT, -1, 0, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "89_gouhuo1"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "89_gouhuo2"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "89_gouhuo3"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "89_gouhuo4"},
			},
		},
	}
}

tbRoom[90] = {}
CopyTable(tbRoom[87], tbRoom[90]);
tbRoom[90].nMapIndex = {8,5};
tbRoom[90].DerivedRoom = XoyoGame.RoomXuanjingShuangZhu;

tbRoom[91] = {}
CopyTable(tbRoom[88], tbRoom[91]);
tbRoom[91].nMapIndex = {8,6};

tbRoom[92] = {}
CopyTable(tbRoom[87], tbRoom[92]);
tbRoom[92].nMapIndex = {8,7};
tbRoom[92].DerivedRoom = XoyoGame.RoomXuanjingShuangZhu;

tbRoom[93] = {}
CopyTable(tbRoom[89], tbRoom[93]);
tbRoom[93].nMapIndex = {9,2};
tbRoom[93].DerivedRoom = XoyoGame.RoomXoyoGuzhu;

tbRoom[94] = {}
CopyTable(tbRoom[89], tbRoom[94]);
tbRoom[94].nMapIndex = {9,3};
tbRoom[94].DerivedRoom = XoyoGame.RoomXoyoGuzhu;

tbRoom[95] = {}
CopyTable(tbRoom[89], tbRoom[95]);
tbRoom[95].nMapIndex = {9,4};
tbRoom[95].DerivedRoom = XoyoGame.RoomXoyoGuzhu;

tbRoom[96] = {}
CopyTable(tbRoom[89], tbRoom[96]);
tbRoom[96].nMapIndex = {9,5};
tbRoom[96].DerivedRoom = XoyoGame.RoomXoyoGuzhu;

tbRoom[97] = {}
CopyTable(tbRoom[89], tbRoom[97]);
tbRoom[97].nMapIndex = {9,6};
tbRoom[97].DerivedRoom = XoyoGame.RoomXoyoGuzhu;

tbRoom[98] = {}
CopyTable(tbRoom[89], tbRoom[98]);
tbRoom[98].nMapIndex = {9,7};
tbRoom[98].DerivedRoom = XoyoGame.RoomXoyoGuzhu;

tbRoom[99] = {}
CopyTable(tbRoom[86], tbRoom[99]);
tbRoom[99].nMapIndex = {7,8};

tbRoom[100] = {}
CopyTable(tbRoom[88], tbRoom[100]);
tbRoom[100].nMapIndex = {8,8};

tbRoom[101] = {}
CopyTable(tbRoom[89], tbRoom[101]);
tbRoom[101].nMapIndex = {9,8};
tbRoom[101].DerivedRoom = XoyoGame.RoomXoyoGuzhu;

-- 等级15房间

tbRoom[102] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 15,						-- 房间等级(1~5)
	nMapIndex		= {10,1},						-- 地图组的索引,若对应的索引地图是个table，则应写成{nIndex,nMapIndex}
	tbBeginPoint	= {64640 / 32, 123008 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 10183, nLevel = -1, nSeries = -1},		-- 金军溃兵
		[2] = {nTemplate = 10184, nLevel = -1, nSeries = -1},		-- 金军溃兵-无形蛊
	
		
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.MOVIE_DIALOG, -1, "仔细搜索金国军队的散兵游勇，不要让他们逃出这里！"},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 270, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "果然不出所料！尽速将这些溃兵消灭吧！"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "没想到困兽犹斗之兵竟然如此凶悍，看来我们无法阻止他们逃跑了……"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 0, nNum = 36,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1,32, 3, "guaiwu", "102_kuibing_1"},		-- 刷怪
				{XoyoGame.ADD_NPC, 2, 4, 3, "guaiwu", "102_kuibing_2"},		-- 刷怪
				{XoyoGame.TARGET_INFO, -1, "Hạ 36 Kim Bại Binh"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.MOVIE_DIALOG, -1, "成功的阻拦了这些金军的溃兵，坐下来烤烤火，休息一下，等待下一个挑战吧。"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "102_gouhuo"},
			},
		},
	}
}

tbRoom[103] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 15,						-- 房间等级(1~5)
	nMapIndex		= {10,1},						-- 地图组的索引,若对应的索引地图是个table，则应写成{nIndex,nMapIndex}
	tbBeginPoint	= {62208 / 32, 124256 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 10185, nLevel = -1, nSeries = -1},		-- 流寇
		[2] = {nTemplate = 10228, nLevel = -1, nSeries = -1},		-- 流寇头子
	
		
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.MOVIE_DIALOG, -1, "不知为何，总感觉危险正在接近，还是保持警惕的好……"},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 270, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "是四处流窜烧杀抢掠的贼寇，居然这么巧碰到了他们聚集的窝点，不能放过他们！"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "只不过是流寇，实力却如此强大，看来我们无法阻止他们了……"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 0, nNum = 32,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 32, 3, "guaiwu", "103_liukou"},		-- 刷怪
				{XoyoGame.TARGET_INFO, -1, "Hạ 32 Lưu Khấu"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				
			},
			tbUnLockEvent = 
			{
			},
		},
		[4] = {nTime = 0, nNum = 1,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 2, 1, 4, "guaiwu", "103_liukoutouzi"},		-- 刷怪
				{XoyoGame.MOVIE_DIALOG, -1, "首恶必惩，击杀这个流寇首领！免得以后再去蛊惑平民。"},
				{XoyoGame.TARGET_INFO, -1, "Hạ gục Thủ Lĩnh Lưu Khấu"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.MOVIE_DIALOG, -1, "成功的剿灭了流寇，坐下来烤烤火，休息一下，等待下一个挑战吧。"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "103_gouhuo"},
			},
		},
	}
}


--劫狱
tbRoom[104] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 15,						-- 房间等级(1~5)
	nMapIndex		= {10,2},						-- 地图组的索引
	tbBeginPoint	= {51328 / 32, 105952 / 32},-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 10194, nLevel = -1, nSeries = -1},		-- 劫狱者
		[2] = {nTemplate = 10195, nLevel = -1, nSeries = -1},		-- 越狱犯人
		[3] = {nTemplate = 10236, nLevel = -1, nSeries = -1},		-- 劫狱者首领
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "监牢里最近收押了几名罪大恶极的犯人，为防止有人前来劫狱，捕头请我们前来协助看守。一定不能让这些货色得逞"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 270, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "jiguan"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.MOVIE_DIALOG, -1, "犯人居然趁我们被缠住的时候溜走了……这下该如何是好，只能与捕头商议该如何补救了"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 0, nNum = 8,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 8, 3, "guaiwu", "104_jieyuzhe_1"},		-- 劫狱者1
				{XoyoGame.ADD_NPC, 2, 1, 0, "guaiwu", "104_yueyuzhe_1"},		-- 越狱者1
				{XoyoGame.MOVIE_DIALOG, -1, "居然真的敢来，还是乖乖的伏法吧！"},	
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				{XoyoGame.TARGET_INFO, -1, "Hạ 8 Kẻ cướp ngục"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},				
			},
		},
		[4] = {nTime = 0, nNum = 8,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 8, 4, "guaiwu", "104_jieyuzhe_2"},		-- 劫狱者2
				{XoyoGame.ADD_NPC, 2, 1, 0, "guaiwu", "104_yueyuzhe_2"},		-- 越狱者2
				{XoyoGame.BLACK_MSG, -1, "又出现了新的劫狱者，不要让他们顺利逃脱！"},	
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				{XoyoGame.TARGET_INFO, -1, "Hạ 8 Kẻ cướp ngục"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},				
			},
		},
		[5] = {nTime = 0, nNum = 8,
			tbPrelock = {4},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 8, 5, "guaiwu", "104_jieyuzhe_3"},		-- 劫狱者3
				{XoyoGame.ADD_NPC, 2, 1, 0, "guaiwu", "104_yueyuzhe_3"},		-- 越狱者3
				{XoyoGame.BLACK_MSG, -1, "又来了一波劫狱者，不要让他们顺利逃脱！"},	
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				{XoyoGame.TARGET_INFO, -1, "Hạ 8 Kẻ cướp ngục"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},				
			},
		},
		[6] = {nTime = 0, nNum = 1,
			tbPrelock = {5},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 3, 1, 6, "guaiwu", "104_jieyuzhe_4"},		-- 劫狱者4
				{XoyoGame.ADD_NPC, 2, 3, 0, "guaiwu", "104_yueyuzhe_4"},		-- 越狱者4
				{XoyoGame.MOVIE_DIALOG, -1, "看来这次行动的首领出现了。声东击西的计策么，居然亲自来劫狱。想必是很重要的犯人。既然来了，说不得，要请留下喝茶详细叙说叙说才是。"},	
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				{XoyoGame.TARGET_INFO, -1, "Hạ Thủ lĩnh Cướp Ngục"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.MOVIE_DIALOG, -1, "犯下累累罪行者，就不要妄图能脱离正义的审判了。我们没有辜负捕头的信任，休息一下吧。"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "104_gouhuo"},
			},
		},
	}
}

--天机秘境
tbRoom[105] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 15,						-- 房间等级(1~5)
	nMapIndex		= {10,3},						-- 地图组的索引,若对应的索引地图是个table，则应写成{nIndex,nMapIndex}
	tbBeginPoint	= {51776 / 32, 103744 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 10186, nLevel = -1, nSeries = 	-1},		-- 机关
		[2] = {nTemplate = 10187, nLevel = -1, nSeries =	-1},	-- 机关守卫
		[3] = {nTemplate = 10237, nLevel = -1, nSeries =	-1},	-- 天机道童
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.MOVIE_DIALOG, -1, "我们明明在谷中闯荡，为何突然来到这个诡异的地方。人生地疏，先仔细查看一番为上。"},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 270, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = 
			{
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "想必是我们没有通过此地主人的考验，也只能期待他能让我们尽速离去了。"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 0, nNum = 1,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 3, "jiguan", "105_jiguan_1"},		-- 刷怪
				{XoyoGame.ADD_NPC, 2, 4, 0, "guaiwu", "105_jiguanshou_1"},	-- 刷怪
				{XoyoGame.MOVIE_DIALOG, -1, "这里应该是人为设置的迷阵密境之类，就待我等闯上一闯！"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TARGET_INFO, -1, "Mở cơ quan phía Nam"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				
			},
			tbUnLockEvent = 
			{
			},
		},
		[4] = {nTime = 0, nNum = 1,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 4, "jiguan", "105_jiguan_2"},		-- 刷怪
				{XoyoGame.ADD_NPC, 2, 4, 0, "guaiwu", "105_jiguanshou_2"},	-- 刷怪
				{XoyoGame.MOVIE_DIALOG, -1, "还应该有别的机关，我们再去仔细寻找吧。"},
				{XoyoGame.TARGET_INFO, -1, "Mở cơ quan phía Bắc"},
				
			},
			tbUnLockEvent = 
			{
			},
		},
		[5] = {nTime = 0, nNum = 20,
			tbPrelock = {4},
			tbStartEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.ADD_NPC, 2, 20, 5, "guaiwu2", "105_jiguanshou_3"},	-- 大波怪
				{XoyoGame.MOVIE_DIALOG, -1, "大批机关兽突然从密境中央出现，击败它们！"},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại 20 Cơ Quan Thú"},
			},
			tbUnLockEvent = 
			{
			},
		},
		[6] = {nTime = 0, nNum = 1,
			tbPrelock = {5},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 3, 1, 6, "guaiwu2", "105_tianjidaotong"},	-- 道童
				{XoyoGame.MOVIE_DIALOG, -1, "旁边有个小童的身影在探头探脑，过去问问情形顺便教训一下这个恶作剧的小孩。"},
				{XoyoGame.TARGET_INFO, -1, "Dạy cho Thiên Cơ Đạo Đồng 1 trận"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.MOVIE_DIALOG, -1, "出口慢慢的浮现了出来，看来成功通过了密境。先休息一下吧，如有机会真想见见这个神秘的人物。"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "105_gouhuo"},
			},
		},
	}
}

tbRoom[106] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 15,						-- 房间等级(1~5)
	nMapIndex		= {10,4},						-- 地图组的索引,若对应的索引地图是个table，则应写成{nIndex,nMapIndex}
	tbBeginPoint	= {51520 / 32, 84736 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 10188, nLevel = -1, nSeries = -1},		-- 马鹿
		[2] = {nTemplate = 10189, nLevel = -1, nSeries = -1},		-- 野狼
		
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.MOVIE_DIALOG, -1, "这附近有很多猎物，大家屏息静气，静待猎物出现。"},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 270, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "一群马鹿慢慢的走了过来，运气不错！"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "居然被这些野狼把难得的猎物偷走了，看来真的是修行不足啊，还是回去多多锻炼才是……"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 0, nNum = 32,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 32, 3, "guaiwu", "106_malu"},		-- 刷怪
				{XoyoGame.TARGET_INFO, -1, "Tiêu diệt 32 Mã Lộc"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				
			},
			tbUnLockEvent = 
			{
			},
		},
		[4] = {nTime = 0, nNum = 4,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 2, 4, 4, "guaiwu", "106_yelang"},		-- 王
				{XoyoGame.MOVIE_DIALOG, -1, "一群野狼妄图抢夺我们的猎物，教训这些无耻的家伙！"},
				{XoyoGame.TARGET_INFO, -1, "Tiêu diệt 4 Sói Hoang"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.MOVIE_DIALOG, -1, "狩猎收获颇丰，又成功的教训了偷食的野狼。坐下来烤烤火，休息一下，等待下一个挑战吧。"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "106_gouhuo"},
			},
		},
	}
}

--猴子偷西瓜		
tbRoom[107] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 15,						-- 房间等级(1~5)
	nMapIndex		= {10,4},						-- 地图组的索引
	tbBeginPoint	= {54304 / 32, 95424 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 10192, nLevel = -1, nSeries = -1},		-- 西瓜机关
		[2] = {nTemplate = 10193, nLevel = -1, nSeries = -1},		-- 野猴
		[3] = {nTemplate = 10238, nLevel = -1, nSeries = -1},		-- 野猴王
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.MOVIE_DIALOG, -1, "近日有很多灾民辗转而来，口粮渐渐成了问题，军需官老王分身乏术，请我们在谷中看看能不能寻到什么食物。"},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = {},
		},
		[2] = {nTime = 270, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = 
			{
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.MOVIE_DIALOG, -1, "这下杯具了，西瓜都被猴子抢走了，只好在去寻找别的食物。也不知道猴子是怎么想的，他们会吃西瓜么……"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 0, nNum = 8,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 8, 3, "jiguan", "107_xigua"},		-- 刷怪
				{XoyoGame.TARGET_INFO, -1, "Thu thập 8 Dưa Hấu"},
				{XoyoGame.MOVIE_DIALOG, -1, "这里的地上居然生长着些西瓜，应该勉强可以充作一部分口粮吧。"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},	
			},
			tbUnLockEvent = 
			{				
			},
		},	
		[4] = {nTime = 0, nNum = 20,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 2, 20, 4, "guaiwu", "107_yehou"},		-- 刷怪
				{XoyoGame.TARGET_INFO, -1, "Tiêu diệt 20 Khỉ Hoang"},
				{XoyoGame.MOVIE_DIALOG, -1, "怎么突然出现这么多的猴子？该死，难道是冲着这些西瓜来的！快点赶走它们！"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},	
			},
			tbUnLockEvent = 
			{
			},
		},
		[5] = {nTime = 0, nNum = 1,
			tbPrelock = {4},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 3, 1, 5, "guaiwu", "107_yehouwang"},		-- 刷怪王
				{XoyoGame.TARGET_INFO, -1, "Tiêu diệt Chúa Khỉ Hoang"},
				{XoyoGame.MOVIE_DIALOG, -1, "这只大猴子的猴子王么？长的大又怎么样，想抢东西照打不误！"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.MOVIE_DIALOG, -1, "总算保住了这些食物，真不理解那些猴子，他们会吃西瓜么……烤火休息一下吧"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "107_gouhuo"},
			},
		},
	}
}	


--等级16房间
--襄阳防守战
tbRoom[108] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 16,						-- 房间等级(1~5)
	nMapIndex		= {11,1},						-- 地图组的索引,若对应的索引地图是个table，则应写成{nIndex,nMapIndex}
	tbBeginPoint	= {48064 / 32, 102848 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 10222, nLevel = -1, nSeries = -1},		-- 攻城士兵
		[2] = {nTemplate = 10223, nLevel = -1, nSeries = -1},		-- 攻城统帅
		[3] = {nTemplate = 10239, nLevel = -1, nSeries = -1},		-- 掩护士兵
	},
	-- 锁结构
	LOCK =
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.MOVIE_DIALOG, -1, "襄阳城乃国之要塞，不容有失！我等奉命防守城侧，防止敌人潜入破坏。"},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 270, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "发现敌人的踪迹了！他们果然企图从这里攻入，不能让他们得逞！"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "居然失手让敌人突破了防守，这下糟糕了。得马上禀报统帅，但愿不要无法挽回吧。"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 0, nNum = 5,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 3, "guaiwu", "108_shibing1_1"},		-- 刷怪
				{XoyoGame.ADD_NPC, 1, 1, 3, "guaiwu2", "108_shibing2_1"},		-- 刷怪
				{XoyoGame.ADD_NPC, 1, 1, 3, "guaiwu4", "108_shibing4_1"},		-- 刷怪
				{XoyoGame.ADD_NPC, 1, 1, 3, "guaiwu5", "108_shibing5_1"},		-- 刷怪
				{XoyoGame.ADD_NPC, 2, 1, 3, "guaiwu3", "108_tongshuai_1"},		-- 刷怪
				{XoyoGame.ADD_NPC, 3, 10, 0, "guaiwu6", "108_shibing_1"},		-- 刷怪
				{XoyoGame.MOVIE_DIALOG, -1, "敌人开始进攻了，襄阳城高墙厚，敌军虽然人多势众也都无用！，只需要消灭敌军携带攻城器械的先登死士和先登统帅即可！"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TARGET_INFO, -1, "Ngăn chặn binh sĩ đến gần cổng thành"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				
			},
			tbUnLockEvent = 
			{
			},
		},
		[4] = {nTime = 0, nNum = 1,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.CHANGE_NPC_AI, "guaiwu", XoyoGame.AI_MOVE, "lv16_108_gongcheng_1", 4, 0, 1, 1},	-- 护送AI
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[5]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[6]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[7]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[8]:Close()"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "guaiwu2"},
				{XoyoGame.DEL_NPC, "guaiwu3"},
				{XoyoGame.DEL_NPC, "guaiwu4"},
				{XoyoGame.DEL_NPC, "guaiwu5"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.MOVIE_DIALOG, -1, "居然失手让敌人突破了防守，这下糟糕了。得马上禀报统帅，但愿不要无法挽回吧。"},
			},
		},
		[5] = {nTime = 0, nNum = 1,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.CHANGE_NPC_AI, "guaiwu2", XoyoGame.AI_MOVE, "lv16_108_gongcheng_2", 5, 0, 1, 1},	-- 护送AI
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[4]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[6]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[7]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[8]:Close()"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "guaiwu2"},
				{XoyoGame.DEL_NPC, "guaiwu3"},
				{XoyoGame.DEL_NPC, "guaiwu4"},
				{XoyoGame.DEL_NPC, "guaiwu5"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.MOVIE_DIALOG, -1, "居然失手让敌人突破了防守，这下糟糕了。得马上禀报统帅，但愿不要无法挽回吧。"},
			},
		},
		[6] = {nTime = 0, nNum = 1,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.CHANGE_NPC_AI, "guaiwu3", XoyoGame.AI_MOVE, "lv16_108_gongcheng_3", 6, 0, 1, 1},	-- 护送AI
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[4]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[5]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[7]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[8]:Close()"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "guaiwu2"},
				{XoyoGame.DEL_NPC, "guaiwu3"},
				{XoyoGame.DEL_NPC, "guaiwu4"},
				{XoyoGame.DEL_NPC, "guaiwu5"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.MOVIE_DIALOG, -1, "居然失手让敌人突破了防守，这下糟糕了。得马上禀报统帅，但愿不要无法挽回吧。"},
			},
		},
		[7] = {nTime = 0, nNum = 1,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.CHANGE_NPC_AI, "guaiwu4", XoyoGame.AI_MOVE, "lv16_108_gongcheng_4", 7, 0, 1, 1},	-- 护送AI
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[4]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[5]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[6]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[8]:Close()"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "guaiwu2"},
				{XoyoGame.DEL_NPC, "guaiwu3"},
				{XoyoGame.DEL_NPC, "guaiwu4"},
				{XoyoGame.DEL_NPC, "guaiwu5"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.MOVIE_DIALOG, -1, "居然失手让敌人突破了防守，这下糟糕了。得马上禀报统帅，但愿不要无法挽回吧。"},
			},
		},
		[8] = {nTime = 0, nNum = 1,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.CHANGE_NPC_AI, "guaiwu5", XoyoGame.AI_MOVE, "lv16_108_gongcheng_5", 8, 0, 1, 1},	-- 护送AI
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[4]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[5]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[6]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[7]:Close()"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "guaiwu2"},
				{XoyoGame.DEL_NPC, "guaiwu3"},
				{XoyoGame.DEL_NPC, "guaiwu4"},
				{XoyoGame.DEL_NPC, "guaiwu5"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.MOVIE_DIALOG, -1, "居然失手让敌人突破了防守，这下糟糕了。得马上禀报统帅，但愿不要无法挽回吧。"},
			},
		},
		[9] = {nTime = 0, nNum = 5,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 9, "guaiwu7", "108_shibing1_2"},		-- 刷怪
				{XoyoGame.ADD_NPC, 1, 1, 9, "guaiwu8", "108_shibing2_2"},		-- 刷怪
				{XoyoGame.ADD_NPC, 1, 1, 9, "guaiwu10", "108_shibing4_2"},		-- 刷怪
				{XoyoGame.ADD_NPC, 1, 1, 9, "guaiwu11", "108_shibing5_2"},		-- 刷怪
				{XoyoGame.ADD_NPC, 2, 1, 9, "guaiwu9", "108_tongshuai_2"},		-- 刷怪
				{XoyoGame.ADD_NPC, 3, 10, 0, "guaiwu6", "108_shibing_2"},		-- 刷怪
				{XoyoGame.BLACK_MSG, -1, "敌人加强了进攻力度，一定要守住！"},
				{XoyoGame.TARGET_INFO, -1, "Ngăn chặn binh sĩ đến gần cổng thành"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				
			},
			tbUnLockEvent = 
			{
			},
		},
		[10] = {nTime = 0, nNum = 1,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.CHANGE_NPC_AI, "guaiwu7", XoyoGame.AI_MOVE, "lv16_108_gongcheng_1", 10, 0, 1, 1},	-- 护送AI
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[11]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[12]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[13]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[14]:Close()"},
				{XoyoGame.DEL_NPC, "guaiwu7"},
				{XoyoGame.DEL_NPC, "guaiwu8"},
				{XoyoGame.DEL_NPC, "guaiwu9"},
				{XoyoGame.DEL_NPC, "guaiwu10"},
				{XoyoGame.DEL_NPC, "guaiwu11"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.MOVIE_DIALOG, -1, "居然失手让敌人突破了防守，这下糟糕了。得马上禀报统帅，但愿不要无法挽回吧。"},
			},
		},
		[11] = {nTime = 0, nNum = 1,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.CHANGE_NPC_AI, "guaiwu8", XoyoGame.AI_MOVE, "lv16_108_gongcheng_2", 11, 0, 1, 1},	-- 护送AI
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[10]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[12]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[13]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[14]:Close()"},
				{XoyoGame.DEL_NPC, "guaiwu7"},
				{XoyoGame.DEL_NPC, "guaiwu8"},
				{XoyoGame.DEL_NPC, "guaiwu9"},
				{XoyoGame.DEL_NPC, "guaiwu10"},
				{XoyoGame.DEL_NPC, "guaiwu11"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.MOVIE_DIALOG, -1, "居然失手让敌人突破了防守，这下糟糕了。得马上禀报统帅，但愿不要无法挽回吧。"},
			},
		},
		[12] = {nTime = 0, nNum = 1,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.CHANGE_NPC_AI, "guaiwu9", XoyoGame.AI_MOVE, "lv16_108_gongcheng_3", 12, 0, 1, 1},	-- 护送AI
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[10]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[11]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[13]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[14]:Close()"},
				{XoyoGame.DEL_NPC, "guaiwu7"},
				{XoyoGame.DEL_NPC, "guaiwu8"},
				{XoyoGame.DEL_NPC, "guaiwu9"},
				{XoyoGame.DEL_NPC, "guaiwu10"},
				{XoyoGame.DEL_NPC, "guaiwu11"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.MOVIE_DIALOG, -1, "居然失手让敌人突破了防守，这下糟糕了。得马上禀报统帅，但愿不要无法挽回吧。"},
			},
		},
		[13] = {nTime = 0, nNum = 1,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.CHANGE_NPC_AI, "guaiwu10", XoyoGame.AI_MOVE, "lv16_108_gongcheng_4", 13, 0, 1, 1},	-- 护送AI
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[10]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[11]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[12]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[14]:Close()"},
				{XoyoGame.DEL_NPC, "guaiwu7"},
				{XoyoGame.DEL_NPC, "guaiwu8"},
				{XoyoGame.DEL_NPC, "guaiwu9"},
				{XoyoGame.DEL_NPC, "guaiwu10"},
				{XoyoGame.DEL_NPC, "guaiwu11"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.MOVIE_DIALOG, -1, "居然失手让敌人突破了防守，这下糟糕了。得马上禀报统帅，但愿不要无法挽回吧。"},
			},
		},
		[14] = {nTime = 0, nNum = 1,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.CHANGE_NPC_AI, "guaiwu11", XoyoGame.AI_MOVE, "lv16_108_gongcheng_5", 14, 0, 1, 1},	-- 护送AI
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[10]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[11]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[12]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[13]:Close()"},
				{XoyoGame.DEL_NPC, "guaiwu7"},
				{XoyoGame.DEL_NPC, "guaiwu8"},
				{XoyoGame.DEL_NPC, "guaiwu9"},
				{XoyoGame.DEL_NPC, "guaiwu10"},
				{XoyoGame.DEL_NPC, "guaiwu11"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.MOVIE_DIALOG, -1, "居然失手让敌人突破了防守，这下糟糕了。得马上禀报统帅，但愿不要无法挽回吧。"},
			},
		},
		[15] = {nTime = 0, nNum = 5,
			tbPrelock = {9},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 15, "guaiwu12", "108_shibing1_3"},		-- 刷怪
				{XoyoGame.ADD_NPC, 1, 1, 15, "guaiwu13", "108_shibing2_3"},		-- 刷怪
				{XoyoGame.ADD_NPC, 1, 1, 15, "guaiwu15", "108_shibing4_3"},		-- 刷怪
				{XoyoGame.ADD_NPC, 1, 1, 15, "guaiwu16", "108_shibing5_3"},		-- 刷怪
				{XoyoGame.ADD_NPC, 2, 1, 15, "guaiwu14", "108_tongshuai_3"},	-- 刷怪
				{XoyoGame.ADD_NPC, 3, 10, 0, "guaiwu6", "108_shibing_3"},		-- 刷怪
				{XoyoGame.BLACK_MSG, -1, "最后一波攻势了！坚持住！"},
				{XoyoGame.TARGET_INFO, -1, "Ngăn chặn binh sĩ đến gần cổng thành"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "总算成功抵挡住了敌人的进攻，先烤烤火休息一下吧！"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "108_gouhuo"},
			},
		},
		[16] = {nTime = 0, nNum = 1,
			tbPrelock = {9},
			tbStartEvent = 
			{
				{XoyoGame.CHANGE_NPC_AI, "guaiwu12", XoyoGame.AI_MOVE, "lv16_108_gongcheng_1", 16, 0, 1, 1},	-- 护送AI
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[17]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[18]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[19]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[20]:Close()"},
				{XoyoGame.DEL_NPC, "guaiwu12"},
				{XoyoGame.DEL_NPC, "guaiwu13"},
				{XoyoGame.DEL_NPC, "guaiwu14"},
				{XoyoGame.DEL_NPC, "guaiwu15"},
				{XoyoGame.DEL_NPC, "guaiwu16"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.MOVIE_DIALOG, -1, "居然失手让敌人突破了防守，这下糟糕了。得马上禀报统帅，但愿不要无法挽回吧。"},
			},
		},
		[17] = {nTime = 0, nNum = 1,
			tbPrelock = {9},
			tbStartEvent = 
			{
				{XoyoGame.CHANGE_NPC_AI, "guaiwu13", XoyoGame.AI_MOVE, "lv16_108_gongcheng_2", 17, 0, 1, 1},	-- 护送AI
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[16]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[18]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[19]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[20]:Close()"},
				{XoyoGame.DEL_NPC, "guaiwu12"},
				{XoyoGame.DEL_NPC, "guaiwu13"},
				{XoyoGame.DEL_NPC, "guaiwu14"},
				{XoyoGame.DEL_NPC, "guaiwu15"},
				{XoyoGame.DEL_NPC, "guaiwu16"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.MOVIE_DIALOG, -1, "居然失手让敌人突破了防守，这下糟糕了。得马上禀报统帅，但愿不要无法挽回吧。"},
			},
		},
		[18] = {nTime = 0, nNum = 1,
			tbPrelock = {9},
			tbStartEvent = 
			{
				{XoyoGame.CHANGE_NPC_AI, "guaiwu14", XoyoGame.AI_MOVE, "lv16_108_gongcheng_3", 18, 0, 1, 1},	-- 护送AI
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[16]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[17]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[19]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[20]:Close()"},
				{XoyoGame.DEL_NPC, "guaiwu12"},
				{XoyoGame.DEL_NPC, "guaiwu13"},
				{XoyoGame.DEL_NPC, "guaiwu14"},
				{XoyoGame.DEL_NPC, "guaiwu15"},
				{XoyoGame.DEL_NPC, "guaiwu16"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.MOVIE_DIALOG, -1, "居然失手让敌人突破了防守，这下糟糕了。得马上禀报统帅，但愿不要无法挽回吧。"},
			},
		},
		[19] = {nTime = 0, nNum = 1,
			tbPrelock = {9},
			tbStartEvent = 
			{
				{XoyoGame.CHANGE_NPC_AI, "guaiwu15", XoyoGame.AI_MOVE, "lv16_108_gongcheng_4", 19, 0, 1, 1},	-- 护送AI
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[16]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[17]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[18]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[20]:Close()"},
				{XoyoGame.DEL_NPC, "guaiwu12"},
				{XoyoGame.DEL_NPC, "guaiwu13"},
				{XoyoGame.DEL_NPC, "guaiwu14"},
				{XoyoGame.DEL_NPC, "guaiwu15"},
				{XoyoGame.DEL_NPC, "guaiwu16"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.MOVIE_DIALOG, -1, "居然失手让敌人突破了防守，这下糟糕了。得马上禀报统帅，但愿不要无法挽回吧。"},
			},
		},
		[20] = {nTime = 0, nNum = 1,
			tbPrelock = {9},
			tbStartEvent = 
			{
				{XoyoGame.CHANGE_NPC_AI, "guaiwu16", XoyoGame.AI_MOVE, "lv16_108_gongcheng_5", 20, 0, 1, 1},	-- 护送AI
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[16]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[17]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[18]:Close()"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[19]:Close()"},
				{XoyoGame.DEL_NPC, "guaiwu12"},
				{XoyoGame.DEL_NPC, "guaiwu13"},
				{XoyoGame.DEL_NPC, "guaiwu14"},
				{XoyoGame.DEL_NPC, "guaiwu15"},
				{XoyoGame.DEL_NPC, "guaiwu16"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
				{XoyoGame.MOVIE_DIALOG, -1, "居然失手让敌人突破了防守，这下糟糕了。得马上禀报统帅，但愿不要无法挽回吧。"},
			},
		},
	}
}


--逃出古墓禁地
tbRoom[109] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 16,						-- 房间等级(1~5)
	nMapIndex		= {11,2},						-- 地图组的索引
	tbBeginPoint	= {50496 / 32, 104512 / 32},-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 10190, nLevel = -1, nSeries = -1},		-- 机关
		[2] = {nTemplate = 10191, nLevel = -1, nSeries = -1},		-- 古墓派追兵
		[3] = {nTemplate = 10240, nLevel = -1, nSeries = -1},		-- 追兵头1
		[4] = {nTemplate = 10241, nLevel = -1, nSeries = -1},		-- 追兵头2
		[5] = {nTemplate = 10242, nLevel = -1, nSeries = -1},		-- 追兵头3

	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "不小心误入了古墓派的地域，听闻外人入古墓派者必杀无赦，还是先逃命要紧。"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 270, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "jiguan"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.MOVIE_DIALOG, -1, "古墓派果然名不虚传，只能祈祷他们能听信我们的解释，让我们平安离去了。"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 0, nNum = 1,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.BLACK_MSG, -1, "古墓密道机关重重，一边解开机关一边前进"},
				{XoyoGame.ADD_NPC, 1, 1, 3, "jiguan", "109_jiguan_1"},		-- 机关1		
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				{XoyoGame.TARGET_INFO, -1, "Mở đường hầm bí mật phía trước"},
			},
			tbUnLockEvent = 
			{				
			},
		},
		[4] = {nTime = 0, nNum = 8,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 2, 8, 4, "guaiwu", "109_zhuibing_1"},		-- 追兵1
				{XoyoGame.BLACK_MSG, -1, "古墓派的守卫弟子追上来了，快点打发掉他们！"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TARGET_INFO, -1, "Hạ 8 Đệ Tử Cổ Mộ"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.BLACK_MSG, -1, "快点去解开前面的机关吧！"},
			},
		},
		[5] = {nTime = 0, nNum = 1,
			tbPrelock = {4},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 5, "jiguan", "109_jiguan_2"},		-- 机关2		
				{XoyoGame.TARGET_INFO, -1, "Mở đường hầm bí mật phía trước"},			},
			tbUnLockEvent = 
			{				
			},
		},
		[6] = {nTime = 0, nNum = 9,
			tbPrelock = {5},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 2, 8, 6, "guaiwu", "109_zhuibing_2"},		-- 追兵2	
				{XoyoGame.ADD_NPC, 3, 1, 6, "guaiwu", "109_zhuibing1_1"},		-- 追兵头11
				{XoyoGame.BLACK_MSG, -1, "啧，追兵的速度不慢，我们也得加快速度！"},
				{XoyoGame.TARGET_INFO, -1, "Hạ 8 Đệ Tử Cổ Mộ và Tề Ỷ Kiếm"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.BLACK_MSG, -1, "下一个机关就在前面！"},
			},
		},
		[7] = {nTime = 0, nNum = 1,
			tbPrelock = {6},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 7, "jiguan", "109_jiguan_3"},		-- 机关3		
				{XoyoGame.TARGET_INFO, -1, "Mở đường hầm bí mật phía trước"},			},
			tbUnLockEvent = 
			{				
			},
		},
		[8] = {nTime = 0, nNum = 9,
			tbPrelock = {7},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 2, 8, 8, "guaiwu", "109_zhuibing_3"},		-- 追兵3		
				{XoyoGame.ADD_NPC, 4, 1, 8, "guaiwu", "109_zhuibing2_1"},		-- 追兵头21	
				{XoyoGame.BLACK_MSG, -1, "真是没完没了，快点解决掉他们！"},
				{XoyoGame.TARGET_INFO, -1, "Hạ 8 Đệ Tử Cổ Mộ và Lệ Lăng Tiêu"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.BLACK_MSG, -1, "前方就是道路尽头了，继续向前解开剩下的机关！"},
			},
		},
		[9] = {nTime = 0, nNum = 1,
			tbPrelock = {8},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 9, "jiguan", "109_jiguan_4"},		-- 机关4	
				{XoyoGame.TARGET_INFO, -1, "Mở đường hầm bí mật phía trước"},			},
			tbUnLockEvent = 
			{				
			},
		},
		[10] = {nTime = 0, nNum = 3,
			tbPrelock = {9},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 3, 1, 10, "guaiwu", "109_zhuibing1_2"},		-- 追兵头12
				{XoyoGame.ADD_NPC, 4, 1, 10, "guaiwu", "109_zhuibing2_2"},		-- 追兵头22
				{XoyoGame.ADD_NPC, 5, 1, 10, "guaiwu", "109_zhuibing3"},		-- 追兵头3	
			    {XoyoGame.MOVIE_DIALOG, -1, "这里是通道尽头了，追来的这三个人看来是有些地位的弟子，迅速摆脱他们我们就安全了！"},
			    {XoyoGame.TARGET_INFO, -1, "Hạ Tề Ỷ Kiếm, Lệ Lăng Tiêu và Mai Thắng Vân"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "终于成功摆脱了追兵！先停下来烤烤火，然后再离开这里吧。"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "109_gouhuo"},
			},
		},
	}
}	

--棋武士 待定
tbRoom[110] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 16,						-- 房间等级(1~5)
	nMapIndex		= {11,3},						-- 地图组的索引,若对应的索引地图是个table，则应写成{nIndex,nMapIndex}
	tbBeginPoint	= {51936 / 32, 103840 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 10208, nLevel = -1, nSeries = -1},		-- 汉卒
		[2] = {nTemplate = 10209, nLevel = -1, nSeries = -1},		-- 汉炮
		[3] = {nTemplate = 10210, nLevel = -1, nSeries = -1},		-- 汉车
		[4] = {nTemplate = 10211, nLevel = -1, nSeries = -1},		-- 汉马
		[5] = {nTemplate = 10212, nLevel = -1, nSeries = -1},		-- 汉相
		[6] = {nTemplate = 10213, nLevel = -1, nSeries = -1},		-- 汉士
		[7] = {nTemplate = 10214, nLevel = -1, nSeries = -1},		-- 汉军棋将
		[8] = {nTemplate = 10215, nLevel = -1, nSeries = -1},		-- 楚兵
		[9] = {nTemplate = 10216, nLevel = -1, nSeries = -1},		-- 楚炮
		[10] = {nTemplate = 10217, nLevel = -1, nSeries = -1},		-- 楚车
		[11] = {nTemplate = 10218, nLevel = -1, nSeries = -1},		-- 楚马
		[12] = {nTemplate = 10219, nLevel = -1, nSeries = -1},		-- 楚象
		[13] = {nTemplate = 10220, nLevel = -1, nSeries = -1},		-- 楚士
		[14] = {nTemplate = 10221, nLevel = -1, nSeries = -1},		-- 楚军棋将
		
		
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.MOVIE_DIALOG, -1, "义军出奇思妙想，以棋局为形，演练军势。现下棋武坪上有汉楚两营士兵在互相操演。此前不曾见过此等操演方式，今次定要好好观摩一番。"},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 270, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "两营士兵列阵了！可是看起来有些奇怪……"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "果然久经训练的精锐之兵，不是我等未曾配合的初练之军可以抵挡的。还是先行退去好好研习武艺兵法为上。"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 0, nNum = 7,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "为何汉营士兵少了这许多，这一局又如何公平。说不得我等要下场助上一臂之力了！"},
				{XoyoGame.ADD_NPC, 1, 5, 0, "guaiwu", "110_hanbing"},		-- 刷怪
				{XoyoGame.ADD_NPC, 2, 1, 0, "guaiwu", "110_hanpao"},		-- 刷怪
				{XoyoGame.ADD_NPC, 3, 1, 0, "guaiwu", "110_hanche"},		-- 刷怪
				{XoyoGame.ADD_NPC, 4, 1, 0, "guaiwu", "110_hanma"},			-- 刷怪
				{XoyoGame.ADD_NPC, 5, 1, 0, "guaiwu", "110_hanxiang"},		-- 刷怪
				{XoyoGame.ADD_NPC, 6, 2, 0, "guaiwu", "110_hanshi"},		-- 刷怪
				{XoyoGame.ADD_NPC, 7, 1, 0, "guaiwu", "110_hanwang"},		-- 刷怪
				{XoyoGame.ADD_NPC, 8, 5, 3, "guaiwu2", "110_chubing"},		-- 刷怪
				{XoyoGame.ADD_NPC, 9, 2, 3, "guaiwu2", "110_chupao"},		-- 刷怪
				{XoyoGame.CHANGE_NPC_AI, "guaiwu", XoyoGame.AI_ATTACK, "", 0},	-- 改变阵营AI
				{XoyoGame.TARGET_INFO, -1, "Đánh bại tất cả binh sĩ"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				
			},
			tbUnLockEvent = 
			{
			},
		},
		[4] = {nTime = 0, nNum = 6,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "坚持住！击溃其第二阵攻势！"},
				{XoyoGame.ADD_NPC, 10, 2, 4, "guaiwu2", "110_chuche"},		-- 刷怪
				{XoyoGame.ADD_NPC, 11, 2, 4, "guaiwu2", "110_chuma"},		-- 刷怪
				{XoyoGame.ADD_NPC, 12, 2, 4, "guaiwu2", "110_chuxiang"},	-- 刷怪
				{XoyoGame.TARGET_INFO, -1, "Đánh bại tất cả binh sĩ"},
			},
			tbUnLockEvent = 
			{
			},
		},
		[5] = {nTime = 0, nNum = 3,
			tbPrelock = {4},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 13, 2, 5, "guaiwu2", "110_chushi"},		-- 刷怪
				{XoyoGame.ADD_NPC, 14, 1, 5, "guaiwu2", "110_chujiang"},	-- 刷怪
				{XoyoGame.MOVIE_DIALOG, -1, "此局已近终盘！尽速将敌将困杀之！"},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại tất cả binh sĩ và phiến quân còn lại"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.MOVIE_DIALOG, -1, "参与棋武操演，自身也获得了一些兵法上的感悟。休息一下，烤烤火吧！"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "110_gouhuo"},
			},
		},
	}
}				

--婚宴
tbRoom[111] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 16,						-- 房间等级(1~5)
	nMapIndex		= {11,4},						-- 地图组的索引,若对应的索引地图是个table，则应写成{nIndex,nMapIndex}
	tbBeginPoint	= {47200 / 32, 105344 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 10224, nLevel = -1, nSeries = -1},		-- 新郎
		[2] = {nTemplate = 10225, nLevel = -1, nSeries = -1},		-- 新娘
		[3] = {nTemplate = 10226, nLevel = -1, nSeries = -1},		-- 恶霸
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.MOVIE_DIALOG, -1, "风闻此间恶名遍播的恶霸头子今日娶亲，娶的也是一手上沾了不知多少血腥的女魔头。如此奸邪之辈，我等岂能让其如意？这就前去大闹一场吧！"},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 270, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = 
			{
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "没想到这伙强人的实力如此强大，趁事情没糟风紧扯呼吧！技艺不精害死人呐……"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 0, nNum = 32,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "场面还挺盛大的。马上对这些淫邪之徒进行惩戒，蹂躏之！"},
				{XoyoGame.ADD_NPC, 3, 32, 3, "guaiwu", "111_eba"},		-- 刷怪
				{XoyoGame.TARGET_INFO, -1, "Hạ 32 Ác Bá"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = 
			{
			},
		},
		[4] = {nTime = 0, nNum = 2,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 4, "jiangyou", "111_xinlang"},		-- 刷怪
				{XoyoGame.ADD_NPC, 2, 1, 4, "jiangyou", "111_xinniang"},	-- 刷怪
				{XoyoGame.MOVIE_DIALOG, -1, "击溃了贺喜的喽啰们，眼前就是这奸邪之辈了，蹂躏之！"},
				{XoyoGame.TARGET_INFO, -1, "Hạ Lưu Nhất Gia và Chung Đa Diêm"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.MOVIE_DIALOG, -1, "好好的惩戒了此间恶人，真是大快人心！好好休息一下吧！"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "111_gouhuo"},
			},
		},
	}
}

--夺宝
tbRoom[112] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 16,						-- 房间等级(1~5)
	nMapIndex		= {11,5},						-- 地图组的索引
	tbBeginPoint	= {50880 / 32, 100064 / 32},-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 10196, nLevel = -1, nSeries = -1},		-- 埋藏的宝物
		[2] = {nTemplate = 10197, nLevel = -1, nSeries = -1},		-- 守宝贼
		[3] = {nTemplate = 10245, nLevel = -1, nSeries = -1},		-- 丁格

	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "收到消息得知，近期几宗失窃案被窃的宝物都被贼人埋藏在此处，仔细搜索，莫要惊动了贼人。"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 270, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "jiguan"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.MOVIE_DIALOG, -1, "贼人已经警觉，势必无法成功夺回宝物，只能先行撤退，容后再议了"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 0, nNum = 9,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 3, "jiguan", "112_baowu_1"},		    -- 埋藏的宝物1
				{XoyoGame.ADD_NPC, 2, 8, 3, "guaiwu", "112_shoubaozei_1"},		-- 守宝贼1
				{XoyoGame.BLACK_MSG, -1, "前往西侧搜索，趁贼人看守不严，迅速取走宝物!"},	
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				{XoyoGame.TARGET_INFO, -1, "Tìm kiếm kho báu và hạ 8 tên Thủ Bảo Tặc"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.BLACK_MSG, -1, "宝物没有藏在这里，继续搜索！"},		
			},
		},
		[4] = {nTime = 0, nNum = 9,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 4, "jiguan", "112_baowu_2"},		-- 埋藏的宝物2
				{XoyoGame.ADD_NPC, 2, 8, 4, "guaiwu", "112_shoubaozei_2"},		-- 守宝贼2
				{XoyoGame.BLACK_MSG, -1, "前往南侧搜索，趁贼人看守不严，迅速取走宝物!"},	
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				{XoyoGame.TARGET_INFO, -1, "Tìm kiếm kho báu và hạ 8 tên Thủ Bảo Tặc"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.BLACK_MSG, -1, "真是狡兔三窟，一定要找到宝物埋藏在哪里！"},				
			},
		},
		[5] = {nTime = 0, nNum = 9,
			tbPrelock = {4},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 5, "jiguan", "112_baowu_3"},		-- 埋藏的宝物3
				{XoyoGame.ADD_NPC, 2, 8, 5, "guaiwu", "112_shoubaozei_3"},		-- 守宝贼3
				{XoyoGame.BLACK_MSG, -1, "前往东侧搜索，趁贼人看守不严，迅速取走宝物!"},	
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				{XoyoGame.TARGET_INFO, -1, "Tìm kiếm kho báu và hạ 8 tên Thủ Bảo Tặc"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.BLACK_MSG, -1, "这里还是没有宝物，继续搜索！"},				
			},
		},
		[6] = {nTime = 0, nNum = 1,
			tbPrelock = {5},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 6, "jiguan", "112_baowu_4"},		-- 埋藏的宝物4
				{XoyoGame.BLACK_MSG, -1, "这里居然有个没人看守的宝物箱，打开看看"},	
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				{XoyoGame.TARGET_INFO, -1, "Kiểm tra Bảo Rương"},
			},
			tbUnLockEvent = 
			{
			},
		},
		[7] = {nTime = 0, nNum = 1,
			tbPrelock = {6},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 3, 1, 7, "guaiwu", "112_dingge"},		-- 丁格
				{XoyoGame.MOVIE_DIALOG, -1, "眼前腾的一声出现了一个人影，拿起地上的宝物就准备逃走，看着身手多半就是江湖上出名的飞贼王了，有趣得紧，今日定要砸了他的招牌。"},	
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				{XoyoGame.TARGET_INFO, -1, "Hạ Đinh Cách"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.MOVIE_DIALOG, -1, "成功夺回了全部被窃的财物，顺便教训了号称专业夺宝的飞贼王，先烤烤火，休息一下吧！"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "112_gouhuo"},			
			},
		},
	}
}	

--护送小丽影
tbRoom[113] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 16,						-- 房间等级(1~5)
	nMapIndex		= {11,6},						-- 地图组的索引
	tbBeginPoint	= {51168 / 32, 103136 / 32},	-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
		-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 10198, nLevel = -1, 	nSeries = -1},		-- 小丽影护送
		[2] = {nTemplate = 10199, nLevel = -1, 	nSeries = -1}, 		-- 大飞贼
		[3] = {nTemplate = 10244, nLevel = -1, 	nSeries = -1}, 		-- 辰大飞
		[4] = {nTemplate = 10243, nLevel = -1, 	nSeries = -1}, 		-- 小蘑菇
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "那边有一个小姑娘，一个人在逍遥谷里做什么，我们过去看看"},
				{XoyoGame.ADD_NPC, 1, 1, 3, "husong", "113_xiaoliying"},		-- 护送NPC				
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = {},
		},
		[2] = {nTime = 270, nNum = 1,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "husong"},
				{XoyoGame.MOVIE_DIALOG, -1, "趁我们不注意，一个大飞贼一把抄起小丽影，大笑着夺路而去，只能懊悔的看着他们的背影祈祷小丽影平安了。"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 0, nNum = 1,		-- 小丽影死亡
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "趁我们不注意，一个大飞贼一把抄起小丽影，大笑着夺路而去，只能懊悔的看着他们的背影祈祷小丽影平安了。"},
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "husong"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[4] = {nTime = 1, nNum = 0,
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=10198>：“大哥哥大姐姐们好~我在谷里采蘑菇，你们要不要跟我一起来啊~^_^”"},
				{XoyoGame.TARGET_INFO, -1, "Hộ tống Tiểu Lệ Ảnh"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
		},
		[5] = {nTime = 0, nNum = 1,	
			tbPrelock = {4},
			tbStartEvent = {
				{XoyoGame.CHANGE_NPC_AI, "husong", XoyoGame.AI_MOVE, "lv16_113_xiaoliying_1", 5, 100, 1},	-- 护送AI
			},
			tbUnLockEvent = {},
		},
		[6] = {nTime = 4, nNum = 0,	
			tbPrelock = {5},
			tbStartEvent = 
			{
				{XoyoGame.SEND_CHAT, "husong", "采蘑菇的小姑娘，啦啦，背着一个小箩筐，啦啦啦……"},
			},
			tbUnLockEvent = {},
		},
		[7] = {nTime = 0, nNum = 4,	
			tbPrelock = {6},
			tbStartEvent =
			{
				{XoyoGame.ADD_NPC, 4, 4, 7, "guaiwu", "113_xiaomogu_1"},
				{XoyoGame.MOVIE_DIALOG, -1, "小丽影：“咦这里有好多小蘑菇！哥哥姐姐等我一下喔，我采一点回去给妈妈！"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TARGET_INFO, -1, "Thu thập 4 Nấm Nhỏ"},
			},
			tbUnLockEvent = {},
		},
		[8] = {nTime = 0, nNum = 8,	
			tbPrelock = {7},
			tbStartEvent = {
				{XoyoGame.ADD_NPC, 2, 8, 8, "guaiwu", "113_dafeizei_1"},
				{XoyoGame.MOVIE_DIALOG, -1, "突然出现了许多黑衣人，看起来是冲着小丽影来的，保护好她！"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TARGET_INFO, -1, "Bảo vệ Tiểu Lệ Ảnh, hạ gục 8 Đại Phi Tặc"},
			},
			tbUnLockEvent = {},
		},
		[9] = {nTime = 0, nNum = 1,	
			tbPrelock = {8},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=10198>：“啊！吓死我了，那些人是大飞贼，呜呜呜好可怕，我要回家！”"},
				{XoyoGame.CHANGE_NPC_AI, "husong", XoyoGame.AI_MOVE, "lv16_113_xiaoliying_2", 9, 100, 1},	-- 护送AI
			},
			tbUnLockEvent = {},
		},
		[10] = {nTime = 4, nNum = 0,	
			tbPrelock = {9},
			tbStartEvent = 
			{
				{XoyoGame.SEND_CHAT, "husong", "哥哥姐姐你们喜欢吃蘑菇吗？对身体很好哦"},
			},
			tbUnLockEvent = {},
		},
		[11] = {nTime = 0, nNum = 4,	
			tbPrelock = {10},
			tbStartEvent =
			{
				{XoyoGame.ADD_NPC, 4, 4, 11, "guaiwu", "113_xiaomogu_2"},
				{XoyoGame.MOVIE_DIALOG, -1, "小丽影：“这里也有好多小蘑菇噢！"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TARGET_INFO, -1, "Thu thập 4 Nấm Nhỏ"},
			},
			tbUnLockEvent = {},
		},
		[12] = {nTime = 0, nNum = 8,	
			tbPrelock = {11},
			tbStartEvent = {
				{XoyoGame.ADD_NPC, 2, 8, 12, "guaiwu", "113_dafeizei_2"},
				{XoyoGame.MOVIE_DIALOG, -1, "又有一批大飞贼出现了，真是变态啊！快赶走他们！"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TARGET_INFO, -1, "Bảo vệ Tiểu Lệ Ảnh, hạ gục 8 Đại Phi Tặc"},
			},
			tbUnLockEvent = {},
		},
		[13] = {nTime = 0, nNum = 1,	
			tbPrelock = {12},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=10198>：“呜呜呜，为什么他们总是缠着我！”"},
				{XoyoGame.CHANGE_NPC_AI, "husong", XoyoGame.AI_MOVE, "lv16_113_xiaoliying_3", 13, 100, 1},	-- 护送AI
			},
			tbUnLockEvent = {},
		},
		[14] = {nTime = 4, nNum = 0,	
			tbPrelock = {13},
			tbStartEvent = 
			{
				{XoyoGame.SEND_CHAT, "husong", "采姑娘的小蘑菇，啦啦……咦？哪里不对的样子<pic=29>"},
			},
			tbUnLockEvent = {},
		},
		[15] = {nTime = 0, nNum = 4,	
			tbPrelock = {14},
			tbStartEvent =
			{
				{XoyoGame.ADD_NPC, 4, 4, 15, "guaiwu", "113_xiaomogu_3"},
				{XoyoGame.MOVIE_DIALOG, -1, "小丽影：“采了小蘑菇回去给妈妈煮汤喝！"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TARGET_INFO, -1, "Thu thập 4 Nấm Nhỏ"},
			},
			tbUnLockEvent = {},
		},
		[16] = {nTime = 0, nNum = 9,	
			tbPrelock = {15},
			tbStartEvent = {
				{XoyoGame.ADD_NPC, 2, 8, 16, "guaiwu", "113_dafeizei_3"},
				{XoyoGame.ADD_NPC, 3, 1, 16, "guaiwu", "113_chendafei"},
				{XoyoGame.BLACK_MSG, -1, "大飞贼的首领辰大飞出现了！一定要为民除害！"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TARGET_INFO, -1, "Bảo vệ Tiểu Lệ Ảnh, hạ gục 8 Đại Phi Tặc"},
			},
			tbUnLockEvent =
			{
				{XoyoGame.DEL_NPC, "husong"},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=10198>：“谢谢哥哥姐姐！我家就在谷外马上就到了，就不麻烦哥哥姐姐了。有空的话一定要再来找我玩啊~”"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
				{XoyoGame.ADD_GOUHUO, 2, 150, "gouhuo", "113_gouhuo"},
			},
		},
	},
}	
			
--等级17房间
--王重阳与林朝英
tbRoom[114] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 17,						-- 房间等级(1~5)
	nMapIndex		= {12,1},						-- 地图组的索引
	tbBeginPoint	= {51872 / 32, 102752 / 32},-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 10200, nLevel = -1, nSeries =	-1},		-- 王重阳
		[2] = {nTemplate = 10201, nLevel = -1, nSeries =	-1},		-- 林朝英
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "终南山下，绝谷幽幽，此等幽然静谧之处，让人不禁想要驻足……前方似有男女二人争执，不如上前一看究竟。"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = {},
		},
		[2] = {nTime = 480, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = 
			{
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.DEL_NPC, "guaiwu2"},
				{XoyoGame.DEL_NPC, "guaiwu3"},
				{XoyoGame.MOVIE_DIALOG, -1, "江湖前辈果然难以匹敌，此等家务事我等卷入已是不该，还是速速退去吧。"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 0, nNum = 1,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=10201>：“哪里来的小辈，看架势也不是这老东西的弟子，来得好！你们面前之人，负心薄幸，始乱终弃，速速与老身将其狠狠教训一番”"},
				{XoyoGame.ADD_NPC, 1, 1, 3, "guaiwu", "114_wangchongyang"},  --王重阳
				{XoyoGame.ADD_NPC, 2, 1, 0, "guaiwu2", "114_linchaoying"},   --林朝英
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				{XoyoGame.TARGET_INFO, -1, "Hỗ trợ Lâm Triều Anh đánh bại Vương Trùng Dương"},
				{XoyoGame.CHANGE_NPC_AI, "guaiwu2", XoyoGame.AI_ATTACK, "", 0},	-- 改变阵营AI
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=10200>：“唉……朝英，你又何苦斤斤计较于此，你先冷静一番，我再来与你相叙”"},
				{XoyoGame.DEL_NPC, "guaiwu2"},
			},
		},
		[4] = {nTime = 0, nNum = 1,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=10201>：“走……走了？就这么走了？是谁让你走的？是谁赶你走的？是，是你们！你们几个小辈气走了他，给我纳命来！”"},
				{XoyoGame.ADD_NPC, 2, 1, 4, "guaiwu3", "114_linchaoying2"},   --林朝英
				{XoyoGame.TARGET_INFO, -1, "Đánh bại Lâm Triều Anh"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=10201>：“我这是怎么了……怎么会去为难几名江湖小辈……罢了，罢了……你们去吧……”"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
			},
		},
	}
}	

--剑神
tbRoom[115] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 17,						-- 房间等级(1~5)
	nMapIndex		= {12,2},						-- 地图组的索引
	tbBeginPoint	= {51392 / 32, 102048 / 32},-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 10202, nLevel = -1, nSeries = -1},		-- 守护剑灵
		[2] = {nTemplate = 10203, nLevel = -1, nSeries = -1},		-- 剑碑机关
		[3] = {nTemplate = 10204, nLevel = -1, nSeries = -1},		-- 剑神
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "数十年前，有一块天外陨铁坠落在这里，一位绝世名匠将其打造为一柄绝世神剑藏于此处。此地也就更名为神剑岭，我们当仔细探访这把剑的下落。"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = 
			{
			},
		},
		[2] = {nTime = 480, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = {},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "jiguan"},
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.MOVIE_DIALOG, -1, "眼前的一切皆于飘渺中化去，仿佛根本从未存在过一样……看来欲得此剑，还须足够机缘"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 0, nNum = 4,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 2, 4, 3, "jiguan", "115_jianling"},		-- 机关	
				{XoyoGame.MOVIE_DIALOG, -1, "有几座石碑立在各个角落，看起来十分突兀，不如去调查一下。"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TARGET_INFO, -1, "Khám phá Bia Kiếm ở bốn hướng"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = 
			{
			},
		},
		[4] = {nTime = 0, nNum = 10,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 10, 4, "guaiwu", "115_jiguan"},		-- 刷怪	
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=10202>:“无论因何原因来到此地，还望各位能速速离去，此地非凡人驻留之所。”"},	
				{XoyoGame.TARGET_INFO, -1, "Đại bại Thủ Hộ Kiếm Linh cản đường"},
			},
			tbUnLockEvent = 
			{				
			},
		},
		[5] = {nTime = 0, nNum = 1,
			tbPrelock = {4},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 3, 1, 5, "guaiwu", "115_jianshen"},		-- Boss	
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=10204>：“既从来出来，仍当往来处去。诸位为当时英雄豪杰，以贪念夺其神，妄失性命，岂非不智之极？”"},
				{XoyoGame.TARGET_INFO, -1, "Hạ gục Kiếm Thần"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=10204>：“既然汝等有心求剑，吾亦不妨以实相告。当年神匠本欲将陨铁打造成神剑，但又担心被心术不正之辈以之为祸苍生。故他将陨铁融入凡铁，打造成了万件农具分发给了山侧之民。此等仁心，吾自当守之。”"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
			},
		},
	}
}

--剑与杨往
tbRoom[116] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 17,						-- 房间等级(1~5)
	nMapIndex		= {12,3},						-- 地图组的索引
	tbBeginPoint	= {51488 / 32, 102428 / 32},-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 10205, nLevel = -1, nSeries =	-1},		-- 杨往
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 1, 0, "guaiwu", "116_yangwang"},  --杨往
				{XoyoGame.CHANGE_NPC_AI, "guaiwu", XoyoGame.AI_ATTACK, "", 0},	-- 改变阵营AI
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=10205>：“传说中有位武林前辈在此处峭壁之上修行过，并将其佩剑以及生平所学留在了此处。若是传闻非虚，能与我胸中所学印证一番，我的武功必定可以独步天下了，哈哈哈哈！”"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = {},
		},
		[2] = {nTime = 480, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = 
			{
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.MOVIE_DIALOG, -1, "望着将我们轻松击败，狂妄大笑离去的杨往的背影，日后其必将因为自身的大意而付出惨痛的代价，我们也只能祈祷他生命无虞了。"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 0, nNum = 1,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=10205>：“剑冢……？哈哈，剑冢，没错，就是此处了！待我仔细查探一番”"},
				{XoyoGame.CHANGE_NPC_AI, "guaiwu", XoyoGame.AI_MOVE, "lv17_116_yangwang", 3, 100, 1},
				{XoyoGame.TARGET_INFO, -1, "Đi cùng Dương Vãng điều tra"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = 
			{
			},
		},
		[4] = {nTime = 0, nNum = 1,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=10205>：“唔，唔。这大侠也不过如此，这把剑倒是不错，我与之有缘，就收下了。既然有所得，几位就来陪我印证一下吧，看我的武艺精进了多少。”"},
				{XoyoGame.ADD_NPC, 1, 1, 4, "guaiwu2", "116_yangwang1"},  --杨往
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TARGET_INFO, -1, "Đánh bại Dương Vãng"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "<npc=10205>：“看来我真的是井底之蛙，大侠所言十年练剑，十年悟剑，当真金玉良言。在下先行拜别，日后若再相见，定好好报答各位点拨之恩！”"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
			},
		},
	}
}	

--神秘人
tbRoom[117] = 
{
	fnPlayerGroup 	= nil,						-- 玩家分群函数,不填则默认1支队伍1个群体
	fnDeath			= nil,						-- 房间死亡脚本; 不填则默认
	fnWinRule		= nil,						-- 胜利条件，竞赛类的房间需要重定义，其他一般不需要填
	nRoomLevel		= 17,						-- 房间等级(1~5)
	nMapIndex		= {12,4},						-- 地图组的索引
	tbBeginPoint	= {52992 / 32, 103840 / 32},-- 起始点，格式根据fnPlayerGroup需求而定，默认是{nX,nY}
	-- 房间涉及的NPC种类
	NPC = 
	{
-- 		编号  	npc模板				等级(-1默认)	5行(默认-1)
-- E.g  [0] = {nTemplate, 			nLevel, 		nSeries }
		[1] = {nTemplate = 10206, nLevel = -1, nSeries =	-1},		-- 黑衣人
		[2] = {nTemplate = 10207, nLevel = -1, nSeries =	-1},		-- 神秘人
	},
	-- 锁结构
	LOCK = 
	{
		-- 1号锁不能不填，默认1号为起始锁
		[1] = {nTime = 15, nNum = 0,
			tbPrelock = {},
			tbStartEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "这群黑衣人不知什么来头，在营中放了一把火就匆匆潜入谷中，定要拿下他们问个究竟！"},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian chuẩn bị: %s<color>", 1},
				{XoyoGame.TARGET_INFO, -1, ""},
			},
			tbUnLockEvent = {},
		},
		[2] = {nTime = 480, nNum = 0,		-- 总计时
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.DEL_NPC, "guaiwu"},
				{XoyoGame.MOVIE_DIALOG, -1, "我们的实力，还远远不足以探究真相啊…………"},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ thất bại"},
			},
		},
		[3] = {nTime = 0, nNum = 12,
			tbPrelock = {1},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 1, 12, 3, "guaiwu", "117_heiyiren"},  --黑衣人
				{XoyoGame.MOVIE_DIALOG, -1, "发现他们了，不要让他们跑了！"},
				{XoyoGame.CHANGE_FIGHT, -1, 1, Player.emKPK_STATE_PRACTISE},
				{XoyoGame.TIME_INFO, -1, "<color=green>Thời gian còn lại: %s<color>", 2},
				{XoyoGame.TARGET_INFO, -1, "Hạ 12 Hắc Y Nhân"},

			},
			tbUnLockEvent = 
			{
			},
		},
		[4] = {nTime = 0, nNum = 1,
			tbPrelock = {3},
			tbStartEvent = 
			{
				{XoyoGame.ADD_NPC, 2, 1, 4, "guaiwu", "117_shenmiren"},  --神秘人
				{XoyoGame.MOVIE_DIALOG, -1, "这些贼人也不知道什么来头，一个个溜得飞快……你，你是，恩师？！不，非我族类其心必异，你这奸细，杀人凶手。今日就纳命来吧！"},
				{XoyoGame.TARGET_INFO, -1, "Hạ Người Thần Bí"},
			},
			tbUnLockEvent = 
			{
				{XoyoGame.MOVIE_DIALOG, -1, "神秘人一言不发的离去了。仔细想来，似乎是那些黑衣人故意将我等引来此地，这里面会不会有什么阴谋？"},
				{XoyoGame.DO_SCRIPT, "self.tbTeam[1].bIsWiner = 1"},		-- 完成任务设置标志
				{XoyoGame.DO_SCRIPT, "self.tbLock[2]:Close()"},
				{XoyoGame.CLOSE_INFO, -1},
				{XoyoGame.TARGET_INFO, -1, "Nhiệm vụ hoàn thành"},
			},
		},
	}
}			
