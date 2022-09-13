
Merchant.TASK_GOURP 	= 2036; --任务组
Merchant.TASK_OPEN 		= 1;	--开始任务标志,0为可接任务，1为不可接任务。
Merchant.TASK_STEP_COUNT= 2;	--进行到任务的第几步骤
Merchant.TASK_NOWTASK 	= 3;	--当前任务Id	
Merchant.TASK_TYPE 	  	= 4;	--任务类型
Merchant.TASK_STEP 	  	= 5;	--任务步骤类型,1为普通步骤,2为10的倍数步骤,3为100的倍数步骤
Merchant.TASK_LEVEL		= 6;	--等级段任务,50为50级任务,60为达到60级才有的任务.
Merchant.TASK_ACCEPT_WEEK_TIME = 7;		--接受任务的周
Merchant.TASK_ACCEPT_STEP_TIME = 8; 	--接受步骤的时间，秒GETTIME()
Merchant.TASK_ACCEPT_TASK_TIME = 9; 	--完成任务的累积时间，秒
Merchant.TASK_RESET_NEWTYPE    = 10; 	--商人任务更换新类型标志（原步骤数/10）

Merchant.TASK_ITEM_FIX	= 
{
 -- 等级  任务变量,累计最大值,名称
	[1] = {nTask=11, nMax=3,  szName= "Lệnh bài Đại Tướng Mông Cổ Tây Hạ", nLiveTime = 3600*2},		--商会牌子1
	[2] = {nTask=12, nMax=6,  szName= "Lệnh bài Phó Tướng Mông Cổ Tây Hạ", nLiveTime = 3600*2},		--商会牌子2
	[3] = {nTask=13, nMax=15, szName= "Lệnh bài Thống Lĩnh Mông Cổ Tây Hạ", nLiveTime = 3600*2},		--商会牌子3
	[4] = {nTask=14, nMax=9,  szName= "Lệnh Bài Bạch Hổ Đường 3", nLiveTime = 3600*2, hide = 1},	--商会牌子4
	[5] = {nTask=15, nMax=9,  szName= "Lệnh Bài Bạch Hổ Đường 2", nLiveTime = 3600*2, hide = 1},	--商会牌子5
	[6] = {nTask=16, nMax=15, szName= "Lệnh Bài Bạch Hổ Đường 1", nLiveTime = 3600*2, hide = 1},	--商会牌子6
	[7] = {nTask=17, nMax=10, szName= "Lệnh bài Tiêu Dao cấp 5"},		--商会牌子7
	[8] = {nTask=18, nMax=10, szName= "Lệnh bài Tiêu Dao cấp 4"},		--商会牌子8
	[9] = {nTask=19, nMax=10, szName= "Lệnh bài Tiêu Dao cấp 3"},		--商会牌子8
	[10]= {nTask=20, nMax=10, szName= "Lệnh bài Tiêu Dao cấp 2"},		--商会牌子8
	[11]= {nTask=22, nMax=10, szName= "Lệnh bài Gia tộc (sơ)", item = {18,1,110,1}},		--商会牌子8
	[12]= {nTask=23, nMax=10, szName= "Lệnh bài thi đấu Môn phái", item = {18,1,81,1}},		--商会牌子8
};

Merchant.tbOtherItem = {
	[11] = {18,1,110,1},
	[12] = {18,1,81,1},
	}

Merchant.TASK_STONE_AWARD    = 21; 	--宝石奖励标记，1有奖励，0无奖励

-- 杀死NPC/玩家对应跌落表的索引(汉语拼音)
Merchant.KILL_SONGJIN_DAJIANG			= 1;
Merchant.KILL_SONGJIN_DAJIANG_PLAYER	= 2;
Merchant.KILL_SONGJIN_FUJIANG			= 3;
Merchant.KILL_SONGJIN_FUJIANG_PLAYER	= 4;
Merchant.KILL_SONGJIN_TONGLING			= 5;
Merchant.KILL_SONGJIN_TONGLING_PLAYER	= 6;
Merchant.KILL_BAIHUTANG_3				= 7;
Merchant.KILL_BAIHUTANG_2				= 8;
Merchant.KILL_BAIHUTANG_1				= 9;

-- 杀死NPC/玩家对应跌落表
Merchant.TASK_NPC_DROP = 
{
	[Merchant.KILL_SONGJIN_DAJIANG			]= {nLevel = 1, nRate = 100},
	[Merchant.KILL_SONGJIN_DAJIANG_PLAYER	]= {nLevel = 1, nRate = 100},
	[Merchant.KILL_SONGJIN_FUJIANG			]= {nLevel = 2, nRate = 100},
	[Merchant.KILL_SONGJIN_FUJIANG_PLAYER	]= {nLevel = 2, nRate = 100},
	[Merchant.KILL_SONGJIN_TONGLING			]= {nLevel = 3, nRate = 100},
	[Merchant.KILL_SONGJIN_TONGLING_PLAYER	]= {nLevel = 3, nRate = 100},
	[Merchant.KILL_BAIHUTANG_3				]= {nLevel = 4, nRate = 10},
	[Merchant.KILL_BAIHUTANG_2				]= {nLevel = 5, nRate = 8},
	[Merchant.KILL_BAIHUTANG_1				]= {nLevel = 6, nRate = 5},
}

-- 宋金死亡玩家掉令牌时间记录
Merchant.tbSongjin_Kill_Player_Time = {};
Merchant.SONGJIN_KILL_PLAYER_INTERVAL = 5*60; --宋金杀玩家拿令牌的时间间隔

Merchant.TASKDATA_ID 		= 50000; --主任务ID
Merchant.TASKDATA_MAXCOUNT 	= 40; 	 --最大任务步骤次数

Merchant.DERIVEL_ITEM	= {20,1,481,1}; 	--送信ID
Merchant.MERCHANT_BOX_ITEM	= {18,1,288,1}; 	--商会收集箱

Merchant.FILE_PATH		= "\\setting\\task\\merchant\\";	--表格路径
Merchant.FILE_SELECT	= "type_select.txt";	--选择类型表；
Merchant.FILE_AWARD		= "award_step.txt";		--奖励表；
Merchant.FILE_RANDOM_NPC= "random_npc.txt";		--随机npc表；

Merchant.TYPE_DELIVERITEM	= 1;		--旧类型商会
Merchant.TYPE_BUYITEM		= 2;		--旧类型商会
Merchant.TYPE_FINDITEM		= 3;		--旧类型商会
Merchant.TYPE_COLLECTITEM	= 4;		--旧类型商会
Merchant.TYPE_DELIVERITEM_NEW	= 5;
Merchant.TYPE_BUYITEM_NEW		= 6;
Merchant.TYPE_FINDITEM_NEW		= 7;
Merchant.TYPE_COLLECTITEM_NEW	= 8;




Merchant.SETP_NORMAL	= 1;
Merchant.SETP_HARD		= 2;
Merchant.SETP_HARDEST	= 3;


Merchant.NPC_ID	= 2965;	--任务npcID

Merchant.NPCLIST = {};	--随机商会npc dwid表；

Merchant.TYPE_DESCRIPT = {
	"将商会信笺送到指定NPC处（神秘商人在各大门派随机出现）",
	"帮商会去指定地点购买特产（神秘商人在各大门派随机出现）",
	"帮商会收集指定装备和道具（所需各种装备生活技能均可制作）",
	"去指定地点采集指定物品（部分物品有怪物守护,请务必组队前往）",
	};
	
Merchant.AWARD_ZHENYUANEXP = 50;		-- 完成10次获得50分钟的基准经验
Merchant.AWARD_INTERVAL	   = 10;		-- 每10轮奖励一次	

-- 注意table的格式要与Merchant:LoadAwardFile()中读出来的一致
Merchant.tbStoneAward = 
{
	[Merchant.TASKDATA_MAXCOUNT] =
	{
		{
			szName = "蒙尘的宝石",
			nGenre	= 18,
			nDetail = 1,
			nParticular = 1317,
			nLevel	= 1,
			nSeries = 0,
			nNum	= 2,
			nMoney = 0,
			nBindMoney = 0,
			nBaseExp = 0,
		},
	}
}