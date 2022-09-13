-- 文件名  : fightafter_def.lua
-- 创建者  : zounan
-- 创建时间: 2010-07-23 15:57:30
-- 描述    : 一些定义

FightAfter.EXPIRY_DATE =  3600*24;      --有效期 1天 = 24*3600秒;

FightAfter.tbInstanceBuffer = FightAfter.tbInstanceBuffer or {};
FightAfter.tbPlayerInstanceList = FightAfter.tbPlayerInstanceList or {};	

-- 传送符
FightAfter.TB_NEW_WORLD	=
{
	[1]	= { 1, 1389, 3102 },
 	[2]	= { 2, 1785, 3586 },	
 	[3]	= { 3, 1693, 3288 },
 	[4]	= { 4, 1624, 3253 },	
 	[5]	= { 5, 1597, 3131 },	
 	[6]	= { 6, 1572, 3106 },
 	[7]	= { 7, 1510, 3268 },
 	[8]	= { 8, 1721, 3381 },

 	[26]	= { 26, 1641, 3129 },
	[25]	= { 25, 1630, 3169 },
 	[29]	= { 29, 1605, 3946 },
	[24]	= { 24, 1767, 3540 },
 	[28]	= { 28, 1439, 3366 },
 	[27]	= { 27, 1666, 3260 },
 	[23]	= { 23, 1486, 3179 },
};

--关系加成
FightAfter.emRELATION_NONE		   			= 0;   -- 无
FightAfter.emRELATION_TMPFRIEND   			= 1;   -- 临时好友
FightAfter.emRELATION_BIDFRIEND   			= 2;   -- 普通好友
FightAfter.emRELATION_TONGFRIEND			= 3;   -- 帮会好友
FightAfter.emRELATION_KINFRIEND				= 4;   -- 家族好友
FightAfter.emRELATION_COUPLE				= 5;   -- 夫妻
FightAfter.emRELATION_BLACK					= 6;   -- 黑名单
FightAfter.emRELATION_ENEMEY				= 7;   -- 仇人

FightAfter.RALATION_BUFFER = FightAfter.RALATION_BUFFER or {};
FightAfter.BUFFER_MAX		= 10;	-- 最多10%
FightAfter.RelationInfo = "\\setting\\fightafter\\relationinfo.txt"; --关系加成表

FightAfter.emTYPE_TREASURE					= 1;
FightAfter.emTYPE_XOYOGAME					= 2;

FightAfter.BOX_TIMES	= 1;  -- 箱子奖励翻倍




