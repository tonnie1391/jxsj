-- 文件名　：define.lua
-- 创建者　：jiazhenwei
-- 创建时间：2010-03-31 14:23:35
-- 描  述  ：
SpecialEvent.LaborDay = SpecialEvent.LaborDay or {};
local LaborDay = SpecialEvent.LaborDay or {};

LaborDay.nGTPMkPMin_Couplet 	= 5000;			--鉴定消耗精活
LaborDay.OpenTime 			= 20100428;		--活动开始时间
LaborDay.CloseTime 			= 20100517;		--活动结束时间
LaborDay.tbmingyang_Unidentify	= {18,1,927};		--boss未鉴定令牌
LaborDay.tbmingyang_identify	= {18,1,926};		--boss已鉴定令牌
LaborDay.tbmingyang_book		= {18,1,929,1};		--收集册子gdpl
LaborDay.tbShengliHuiZhang		= {18,1,919,1};		--胜利徽章
LaborDay.tbZhongzi				= {18,1,295,1};		--陈年种子gdpl
LaborDay.tbName				= {"金牌","木牌","水牌","火牌","土牌"};	--tips显示用
LaborDay.nRate				= 10;				--逃跑的士兵掉率
LaborDay.nRate_zhongzi			= 10;				--战功礼包开出种子的几率
LaborDay.nZhangonglibao		= 75;				--战功礼包对应randomitem表的序号
LaborDay.nLingpaibaoxiang		= 132;			--令牌宝箱对应randomitem表的序号
LaborDay.nTaskTimes_Max		= 10;				--战功礼包每天最多开多少个
LaborDay.nTaskTimes_All_Max	= 150;			--战功礼包活动期间最多开多少个
LaborDay.nCount				= 5;				--逃跑的将军掉落次数
LaborDay.OpenTime_MY 		= 20101213;		--活动开始时间
LaborDay.CloseTime_MY			= 20110112;		--活动结束时间


LaborDay.TASKID_GROUP =2147		--任务变量组
LaborDay.TASKID_BOOK =1;		--1-5用来记录手册的牌子
LaborDay.TASKID_DAY = 10;		--日期
LaborDay.TASKID_EVERY = 11;		--战功礼包每天开的数目
LaborDay.TASKID_ALL = 12;			--战功礼包活动期间开的总数目
LaborDay.IVER_nHero = 1;			--五一劳动节活动-英雄荣誉
LaborDay.IVER_nTogether = 1;		--五一劳动节活动-共同合力
LaborDay.IVER_nHero_Famous = 1;	--五一劳动节活动-名扬英雄