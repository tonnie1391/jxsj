--
-- FileName: shengxia_def.lua
-- Author: lgy
-- Time: 2012/7/2 11:57
-- Comment: 2012盛夏常量定义
--
SpecialEvent.tbShengXia2012 =  SpecialEvent.tbShengXia2012 or {};
local tbShengXia2012 = SpecialEvent.tbShengXia2012;
tbShengXia2012.bOpen			   = 1;							-- 活动开关
tbShengXia2012.nStartTime		   = 20120724;					-- 活动开始时间
tbShengXia2012.nEndTime			   = 20120816;					-- 活动结束时间，这天就不能做活动了
tbShengXia2012.nStartLingJiangTime		       = 20120813;					-- 活动开始时间
tbShengXia2012.nEndLingJiangTime			   = 20120816;					-- 活动结束时间，这天就不能做活动了
tbShengXia2012.nStartJingCaiTime		       = 20120729;					-- 活动开始时间
tbShengXia2012.nEndJingCaiTime			 	   = 201208121630;					-- 活动结束时间，这天就不能做活动了
tbShengXia2012.nMinLevel		   = 50;						-- 活动最低等级要求
tbShengXia2012.nShengXiaDianCangKa = {18, 1, 1768, 1}; 			-- 盛夏典藏卡
tbShengXia2012.nShengXiaJiNianKa   = {18, 1, 1763, 1}; 			-- 盛夏纪念卡
tbShengXia2012.nShengXiaDianCangCe = {18, 1, 1767, 1}; 			-- 盛夏典藏册
tbShengXia2012.nShenghuoId 		   = {18, 1, 1769, 1};		    -- 奥运圣火
tbShengXia2012.nGanLanId           = {18, 1, 1770, 1};          --橄榄枝id
tbShengXia2012.TASKGID			   = 2197;

tbShengXia2012.BUFFER_INDEX		   = GBLINTBUF_SHENGXIA2012;
--  "足球"。。。"铁人三项"
tbShengXia2012.AoYunName = 										--奥运26项目
{
	"足球","网球","曲棍球","羽毛球","手球","排球","兵乓球",
	"篮球","游泳","田径","自行车","体操","马术","射箭",
	"射击","击剑","举重","拳击","柔道","摔跤","跆拳道",
	"皮划艇","赛艇","帆船","现代五项","铁人三项",
};
tbShengXia2012.TASK_LINGLIBAO		       = 32;                        --是否已经领取过礼包
tbShengXia2012.TASK_LINGHUOYUEDU1	       = 33;                        --领取了15点活跃度奖励
tbShengXia2012.TASK_LINGHUOYUEDU2	       = 34;                        --领取了30点活跃度奖励
tbShengXia2012.TASK_LINGHUOYUEDU3	       = 35;                        --领取了45点活跃度奖励
tbShengXia2012.TASK_LINGJIANG		       = 27;                        --是否已领集齐卡册的奖励
tbShengXia2012.TASK_DIANLIANG              = 28;                        --点亮了多少项目
tbShengXia2012.TASK_JINGCAI			       = 29;						--是否已领之前竞猜的奖励
tbShengXia2012.TASK_JINGCAIID  	           ={30, 31}        			--最多2个竞猜值
tbShengXia2012.TASK_JINGCAIBEISHU          = 36;                        --竞猜倍数
tbShengXia2012.TASK_JINGCAIDAYID           = 37;                        --竞猜流水号
tbShengXia2012.TASK_JIANDING               = 38;                        --当天鉴定卡片的次数
tbShengXia2012.TASK_HUIHUANG     	       = 39;                        --是否有辉煌之星特效
tbShengXia2012.TASK_HUIHUANGXIAOYAO        = 40;                        --是否领取辉煌之星逍遥谷奖励
tbShengXia2012.TASK_HUIHUANGJUNYING        = 41;                        --是否领取辉煌之星军营副本奖励
tbShengXia2012.TASK_YOULONG                = 42;                        --活动期间开出的游龙声望牌子总数

tbShengXia2012.nShengXia_NpcId = 10267;
tbShengXia2012.tbNpc=
{

	{29, 1634, 3912},
	{29, 1609, 3935},
	{29, 1628, 3969},
	{29, 1661, 3950},
	{24, 1730, 3511},
	{24, 1780, 3466},
	{24, 1828, 3521},
	{24, 1766, 3555},
	{25, 1638, 3188},
	{25, 1600, 3159},
	{25, 1636, 3124},
	{25, 1669, 3138}
};


tbShengXia2012.tbPaiZi	=									--牌子概率
{
		[4] = 68,
		[5] = 120,
		[6] = 156,
		[7] = 220,
		[8] = 288,
		[9] = 416,
		[10]= 588,
};

tbShengXia2012.tbNeedGanLan	=									--牌子概率
{
		[4] = 1,
		[5] = 2,
		[6] = 3,
		[7] = 5,
		[8] = 8,
		[9] = 13,
		[10]= 21,
};
tbShengXia2012.tbYouLong = {                                 
	{18,1,1251,2},    --帽子
	{18,1,1251,3},    --衣服
	{18,1,1251,1},    --护身
	{18,1,1251,4},    --腰带
	{18,1,1251,5},    --鞋子
	{18,1,1251,7},    --戒指
	};
	
	
tbShengXia2012.tbJiaZhiLiang	=									--价值量
{
    	[1] = 30000,
    	[2] = 30000,
 	[3] = 30000,
	[4] = 60000,
	[5] = 120000,
	[6] = 180000,
	[7] = 300000,
	[8] = 480000,
	[9] = 780000,
	[10]= 1260000,
};

tbShengXia2012.tbFinalAward = {
	[1] = {20, {{18,1,114,8,1}}, 1},
	[2] = {23, {{18,1,114,8,2}}, 2},
	[3] = {24, {{18,1,114,9,1}, {18,1,1730,12,1}}, 2},
	[4] = {25, {{18,1,114,9,1}, {18,1,1730,11,1}}, 2},
	[5] = {26, {{18,1,114,9,1}, {18,1,1730,10,1}}, 2},
	};
