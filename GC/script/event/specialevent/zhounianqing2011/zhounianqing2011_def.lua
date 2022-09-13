-- 文件名  : zhounianqing_def.lua
-- 创建者  : zhongjunqi
-- 创建时间: 2011-06-14 09:52:57
-- 描述    : 三周年庆 佳肴活动

SpecialEvent.ZhouNianQing2011 = SpecialEvent.ZhouNianQing2011 or {};
local ZhouNianQing2011 = SpecialEvent.ZhouNianQing2011;

ZhouNianQing2011.TASKGID 	= 2167;
ZhouNianQing2011.TASK_JIAYAO_DATE	= 1;	--吃菜日期
ZhouNianQing2011.TASK_JIAYAO_COUNT	= 2;	--每天吃菜的数目
ZhouNianQing2011.TASK_GETGIFT = 3;	-- 领取礼物的标记
ZhouNianQing2011.TASK_GIFT_DATE = 4;	-- 领取礼物的日期
ZhouNianQing2011.TASK_ZHUFUCOUNT = 5;	-- 祝福次数任务ID
ZhouNianQing2011.TASK_SHOWFLOWERCOUNT = 6;	-- 摆花次数任务ID
ZhouNianQing2011.TASK_MAKEFLOWERCOUNT = 7;	-- 做花次数任务ID
ZhouNianQing2011.TASK_ZHUFU_DATE = 8;		-- 祝福日期
ZhouNianQing2011.TASK_SHOWFLOWER_DATE = 9;	-- 摆花日期
ZhouNianQing2011.TASK_MAKEFLOWER_DATE = 10;	-- 做花日期

ZhouNianQing2011.bIsOpen			= 1;		-- 活动是否开始标记
ZhouNianQing2011.nStartTime 		= 20110628;	--活动开始时间
ZhouNianQing2011.nEndTime 			= 20110704;	--活动结束时间

ZhouNianQing2011.nHuaTuanJinCuStartTime = 20110706;	-- 花团锦簇的开放时间
ZhouNianQing2011.nHuaTuanJinCuEndTime = 20110713;
ZhouNianQing2011.nFlowerStartTimePerDay = 0900;	-- 鲜花开放时间
ZhouNianQing2011.nFlowerEndTimePerDay = 2300;	-- 鲜花开放时间

ZhouNianQing2011.nStartTimePerDay	= 1000;		-- 每天佳肴开始活动的时间
ZhouNianQing2011.nEndTimePerDay		= 2300;		-- 每天佳肴结束活动的时间

ZhouNianQing2011.nZhuFuShuTime		= 0000;		-- 祝福树的检测时间，每天0点

ZhouNianQing2011.nPlayerLevelLimit = 60;	-- 祝福等级限制

ZhouNianQing2011.nRefreshMinInterval= 20*60;	-- 最小刷新周期为20分钟,单位是秒
ZhouNianQing2011.nCanEatTimesPerDay = 3;		-- 一个人每天最多能吃几道菜

ZhouNianQing2011.nMapId					= 0;	-- 当前刷新菜肴的地图
ZhouNianQing2011.nDesktopTemplateId	= 9623;		-- 桌子npc的模板id
ZhouNianQing2011.nJiaYaoTemplateId 	= 9624;		-- 菜NPC的模板id

ZhouNianQing2011.nZhuFuShuTemplateId = 9616;	-- 祝福树模板id
ZhouNianQing2011.nZhuFuShuMapId		 = 29;		-- 临安城加入祝福树

ZhouNianQing2011.tb3YearTitle 		= {6,84,1,0};		-- 08年服务器送的称号
ZhouNianQing2011.tbHappyTitle 		= {6,85,1,0};		-- 08年后服务器送的称号

ZhouNianQing2011.nMaxHuaTuanMat		= 6;		-- 每天获取的花团材料数量
ZhouNianQing2011.nMaxShowFlower		= 6;		-- 每天可以摆放鲜花的次数
ZhouNianQing2011.nMaxMakeFlower		= 6;		-- 每天最多能够做的花数
ZhouNianQing2011.nWreathTemplateId = 9617;		-- 花圃的npc模板
ZhouNianQing2011.tbFlowerTemplateId = {9618, 9619, 9620, 9621, 9622};	-- 献花的npc模板
ZhouNianQing2011.nMaxWreathRound 	= 10;		-- 可以摆放鲜花的半径
ZhouNianQing2011.nMaxFlowerCountPerWreath = 4;	-- 每个花圃可以摆放的献花数
ZhouNianQing2011.szWreathFilePath	= "\\setting\\event\\specialevent\\zhounianqing2011\\wreathpos.txt";	-- 花坛npc位置
ZhouNianQing2011.nCheckFlowerTime 	= 10*18;	-- 每10秒检测一次献花npc是否该消失	
ZhouNianQing2011.nFlowerLiveTime	= 60*60;	-- 献花的存活时间
ZhouNianQing2011.nYanHuaInterval	= 10*18;	-- 烟花每10秒钟检查一次是否释放

-- 口号
ZhouNianQing2011.tbMsg = {
	"新手村刷出了周年庆典宴席，侠客们赶快前去享用吧。",		-- 每天第一次刷出
	"新手村刷出了周年庆典宴席，侠客们赶快前去享用吧。",
};



