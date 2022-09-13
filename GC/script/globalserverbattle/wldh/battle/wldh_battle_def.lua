-------------------------------------------------------
-- 文件名　：wldh_battle_def.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-08-20 09:56:23
-- 文件描述：继承修改宋金的设计
-------------------------------------------------------

local tbBattle = Wldh.Battle or {};
Wldh.Battle = tbBattle;

-- 计时器相关
tbBattle.TIMER_SIGNUP		= Env.GAME_FPS * 60 * 10;	-- 报名时间（等待开局时间）
tbBattle.TIMER_SIGNUP_MSG	= Env.GAME_FPS * 60 * 5;	-- 报名期间的广播消息
tbBattle.TIMER_GAME			= Env.GAME_FPS * 60 * 50;	-- 比赛时间（等待比赛结束时间）
tbBattle.TIMER_GAME_MSG		= Env.GAME_FPS * 20;		-- 比赛期间的广播消息
tbBattle.TIMER_SYNCDATA		= Env.GAME_FPS * 10;		-- 比赛期间的同步客户端数据
tbBattle.TIMER_ADD_BOUNS	= Env.GAME_FPS * 60;		-- 每分钟加一次积分

tbBattle.TIME_DEATHWAIT		= 10;	-- 死亡后需要在后营等待的秒数
tbBattle.TIME_PLAYER_STAY 	= 120;	-- 在后营最多可待120秒
tbBattle.TIME_PALYER_LIVE 	= 60;	-- 60秒死相时间 

tbBattle.CAMPID_SONG		= 1;	-- 宋方ID;
tbBattle.CAMPID_JIN			= 2;	-- 金方ID;

tbBattle.NAME_CAMP			= {"宋", "金"};				-- 阵营名
tbBattle.NPC_CAMP_MAP		= {1, 2};					-- 宋金双方的NPC阵营（颜色）

tbBattle.NPCID_WUPINBAOGUANYUAN		= 2599;				-- 储物箱ID
tbBattle.NPCID_HOUYINGJUNYIGUAN		= 3705;				-- 军需官ID
tbBattle.NPCID_CHEFU				= 3700;				-- 车夫ID

-- 战场人数计数，全局变量4组
tbBattle.DBTASKID_PLAYER_COUNT	= 
{
	[1] = {DBTASK_WLDH_BATTLE_SONG1, DBTASK_WLDH_BATTLE_JIN1},
	[2] = {DBTASK_WLDH_BATTLE_SONG2, DBTASK_WLDH_BATTLE_JIN2},
	[3] = {DBTASK_WLDH_BATTLE_SONG3, DBTASK_WLDH_BATTLE_JIN3},
	[4] = {DBTASK_WLDH_BATTLE_SONG4, DBTASK_WLDH_BATTLE_JIN4},
	[5] = {DBTASK_WLDH_BATTLE_SONG5, DBTASK_WLDH_BATTLE_JIN5},
	[6] = {DBTASK_WLDH_BATTLE_SONG6, DBTASK_WLDH_BATTLE_JIN6},
};

-- 比赛结果
tbBattle.RESULT_WIN		= 1;		-- 宋方获胜
tbBattle.RESULT_TIE		= 0;		-- 平局
tbBattle.RESULT_LOSE	= -1;		-- 金方获胜

-- 人数限制
tbBattle.BTPLNUM_LOWBOUND	= 0;	-- 战场开战双方最少人数下限
tbBattle.BTPLNUM_HIGHBOUND	= 150;	-- 双方阵营限定参战最大人数

-- 特殊技能处理
tbBattle.SKILL_DAMAGEDEFENCE_ID 	= 395;						-- 战意技能id
tbBattle.SKILL_DAMAGEDEFENCE_TIME	= Env.GAME_FPS * 60 * 3;	-- 战意时间

-- 共享积分
tbBattle.tbPOINT_TIMES_SHARETEAM 	= {1, 1, 1, 1, 1, 1};		-- 9屏内同队玩家数量下的共享积分比例

-- 报名点mapid
tbBattle.MAPID_SIGNUP = 
{
	[1] = 1623,
	[2] = 1624,
	[3] = 1625,
	[4] = 1626,
	[5] = 1627,
	[6] = 1628,
};

-- 报名点pos
tbBattle.POS_SIGNUP	= 
{
	[1] = {1671, 3281},
	[2] = {1672, 3305},
	[3] = {1688, 3306},
};

-- 赛场地图id
tbBattle.MAPID_MATCH = 
{
	[1] = 1631,
	[2] = 1632,
	[3] = 1633,
	[4] = 1634,
	[5] = 1629,
	[6] = 1630,
}

-- 角色战场记录
tbBattle.TASK_GROUP_ID					= 2102;				-- 任务变量GroupId
tbBattle.TASKID_CAMP					= 11;				-- 战场阵营
tbBattle.TASKID_PLAYER_KEY				= 12;				-- 战场key
tbBattle.TASKID_INDEX					= 13;				-- 哪块场地
tbBattle.TASKID_CAPTAIN					= 14;				-- 是否是队长
tbBattle.TASKID_AWARD					= 15;				-- 是否领取决赛奖励
tbBattle.TASKID_SERVER					= 16;				-- 是否领取区服奖励
tbBattle.TASKID_SERVER_DAY				= 17;				-- 区服奖励领取天数
				
-- 积分信息
tbBattle.tbBounsBase = 
{
	KILLPLAYER = 75,
	MAXSERIESKILL = 150,
};
	
-- 连斩积分
tbBattle.SERIESKILLBOUNS = 150;
	
-- 各等级官衔所需积分
tbBattle.RANKBOUNS = {0, -1, 1000, -1, 3000, -1, 6000, -1, 10000, -1};	

-- 官衔名字
tbBattle.NAME_RANK = 
{
	"<color=white>士兵<color>", 
	"<color=white>勇士<color>",
	"<color=0xa0ff>校尉<color>", 
	"<color=0xa0ff>都尉<color>",
	"<color=yellow>统领<color>",
	"<color=yellow>正将<color>",
	"<color=0xff>副将<color>",  
	"<color=0xff>统制<color>",
	"<color=yellow><bclr=red>大将<bclr><color>", 
	"<color=yellow><bclr=red>元帅<bclr><color>",
};

-- 文字信息
tbBattle.MSG_CAMP_RESULT = 
{
	[tbBattle.RESULT_WIN]	= "%s 结束。%s方势如破竹，大获全胜。",
	[tbBattle.RESULT_TIE]	= "%s 结束。双方未分胜负，当择日再战 。",
	[tbBattle.RESULT_LOSE]	= "%s 结束。%s方力战不敌，鸣金收兵。",
};

-- 体服战队
tbBattle.tbLeagueName = 
{
	[101] = {"云中镇",   1609},
	[102] = {"龙门镇",   1610},
	[103] = {"永乐镇",   1611},
	[104] = {"稻香村",   1612},
	[105] = {"江津村",   1613},
	[107] = {"龙泉村",   1614},
	[108] = {"巴陵县",   1615},
	[110] = {"九老峰",   1644},
	[112] = {"青螺岛",   1645},
	[113] = {"燕子坞",   1646},
	[114] = {"浣花溪",   1647},
	[116] = {"响水洞",   1648},
	[118] = {"风陵渡",   1649},
	[201] = {"长江河谷", 1609},
	[202] = {"雁荡龙湫", 1610},
	[203] = {"洞庭湖畔", 1611},
	[207] = {"茶马古道", 1612},
	[209] = {"龙虎幻境", 1613},
	[210] = {"湖畔竹林", 1614},
	[213] = {"暮雪山庄", 1615},
	[215] = {"怡情山庄", 1644},
	[301] = {"剑门关",   1609},
	[302] = {"武夷山",   1610},
	[304] = {"锁云渊",   1611},
	[307] = {"岳阳楼",   1612},
	[308] = {"采石矶",   1613},
	[312] = {"梁山泊",   1614},
	[316] = {"寒波谷",   1615},
	[321] = {"雁鸣湖",   1644},
	[401] = {"甘露谷",   1609},
	[403] = {"二龙山",   1610},
	[404] = {"罗霄山",   1611},
	[405] = {"凌绝峰",   1612},
	[408] = {"快活林",   1613},
	[409] = {"藏云轩",   1614},
	[410] = {"摘星坪",   1615},
	[414] = {"飞龙堡",   1644},
	[416] = {"轩辕谷",   1645},
	[420] = {"忘情溪",   1646},
	[421] = {"昆仑关",   1647},
	[422] = {"满江红",   1648},
	[426] = {"西江月",   1649},
	[501] = {"逍遥客栈", 1609},
	[504] = {"春梅雅筑", 1610},
	[509] = {"华山绝顶", 1611},
	[511] = {"天涯海角", 1612},
	[512] = {"苏堤春晓", 1613},
	[514] = {"碧潭幽谷", 1614},
	[602] = {"栖霞宫",   1609},
	[603] = {"日月潭",   1610},
	[605] = {"雁门关",   1611},
	[606] = {"莫高窟",   1612},
	[611] = {"清心潭",   1613},
	[616] = {"翠竹溪",   1614},
	[618] = {"凤凰山",   1615},
	[620] = {"鸣沙山",   1644},
	[621] = {"阳关曲",   1645},
}

-- 网关id
tbBattle.tbLGName_GateWay = {};
for nId, tbInfo in pairs(tbBattle.tbLeagueName) do
	tbBattle.tbLGName_GateWay[tbInfo[1]] = nId;
end

-- 战队id
tbBattle.tbLeagueId_Name = {};
for _, tbInfo in pairs(tbBattle.tbLeagueName) do
	local nLeagueId = tonumber(KLib.String2Id(tbInfo[1]));
	tbBattle.tbLeagueId_Name[nLeagueId] = tbInfo[1];
end

-- 试炼谷mapid
tbBattle.tbShiliangu = 
{
	[1] = 1616,
	[2] = 1617,
	[3] = 1618,
	[4] = 1619,
	[5] = 1620,
	[6] = 1621,
	[7] = 1622,
};

-- 时间点
tbBattle.FINAL_TIME	= 20091102;
tbBattle.PRE_TIME =
{
	{20091010, 20091011},
	{20091017, 20091018},
	{20091024, 20091025},
}

-- 全局变量组
tbBattle.GBTASK_BATTLE_GROUP = 1;
tbBattle.GBTASK_BATTLE_FINAL = 
{
	[1] = 11,
	[2] = 12,
	[3] = 13,
	[4] = 14,
};

-- 最多参加24场
tbBattle.MAX_MATCH = 6;

-- 奖励列表
tbBattle.tbAward = 
{
	[1] = { 
		Captain = { Item = {18, 1, 487, 1}, Num = 48, nNeedBag = 1, Title = {11, 5, 1, 0}},
		Member = { Item = {18, 1, 488, 1}, Num = 5, nNeedBag = 5, Title = {11, 5, 5, 0}},	
	},
	[2] = { 
		Captain = { Item = {18, 1, 487, 1}, Num = 16, nNeedBag = 1, Title = {11, 5, 2, 0}},
		Member = { Item = {18, 1, 488, 1}, Num = 3, nNeedBag = 3, Title = {11, 5, 6, 0}},
	},
	[3] = { 
		Captain = { Item = {18, 1, 487, 1}, Num = 8, nNeedBag = 1, Title = {11, 5, 3, 0}},
		Member = { Item = {18, 1, 488, 1}, Num = 2, nNeedBag = 2, Title = {11, 5, 7, 0}},
	},
	[4] = { 
		Captain = { Item = {18, 1, 487, 1}, Num = 8, nNeedBag = 1, Title = {11, 5, 4, 0}},
		Member = { Item = {18, 1, 488, 1}, Num = 2, nNeedBag = 2, Title = {11, 5, 8, 0}},
	},
	Normal = {
		Captain = { Item = {18, 1, 488, 1}, Num = 5, nNeedBag = 5},
		Member = { Item = {18, 1, 488, 1}, Num = 1, nNeedBag = 1},
	},
};

tbBattle.tbServerAward = 
{
	[1] = { Fudai = 2, Xiulian = 0.5, Xingyun = 3, Exp = 8, Level = 7, Day = 20 },
	[2] = { Fudai = 1, Xiulian = 0.5, Xingyun = 1, Exp = 7, Level = 6, Day = 20 },
	[3] = { Fudai = 1, Xiulian = 0.5, Xingyun = 1, Exp = 7, Level = 6, Day = 10 },
	[4] = { Fudai = 1, Xiulian = 0.5, Xingyun = 1, Exp = 7, Level = 6, Day = 10 },
	Normal = { Fudai = 1, Xiulian = 0, Xingyun = 1, Exp = 7, Level = 0, Day = 5 },
};

function tbBattle:CheckTime()
	
	if Wldh.IS_OPEN == 0 then
		return 0;
	end

	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	
	for _, tbTime in pairs(self.PRE_TIME) do
		if nNowDate >= tbTime[1] and nNowDate <= tbTime[2] then
			return 1;
		end
	end
	
	if nNowDate == self.FINAL_TIME then
		return 2;
	end

	return 0;
end
