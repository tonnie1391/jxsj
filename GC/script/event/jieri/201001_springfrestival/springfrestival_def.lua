-- 文件名　：define.lua
-- 创建者　：jiazhenwei
-- 创建时间：2009-12-28 11:41:23
-- 描  述  ：
SpecialEvent.SpringFrestival = SpecialEvent.SpringFrestival or {};
local SpringFrestival = SpecialEvent.SpringFrestival or {};

SpringFrestival.nLevel 		= 60;    			--玩家等级限制
SpringFrestival.nGTPMkPMin_NianHua 	= 500;		--年画鉴定需要的精活
SpringFrestival.nGTPMkPMin_Couplet 	= 1000;		--春联鉴定需要的精活
SpringFrestival.tbXiWang 		= {18,1,552,1}; --希望之种
SpringFrestival.tbBaoXiang 	= {18,1,553,1};	--宝箱：第一千零一个愿望
SpringFrestival.tbVowXiang 	= {18,1,554,1};	--愿望盒子
SpringFrestival.tbCouplet_Unidentify = {18,1,555,1};--未鉴定后的对联
SpringFrestival.tbCouplet_identify 	= {18,1,555,2};	--鉴定后的对联
SpringFrestival.nTrapNumber 		= 1001;				--1001个愿望后大家可以领奖励
SpringFrestival.nGetFudaiMaxNum 	= 5; 				--许愿前5次获得福袋和有几率的奖励
SpringFrestival.nGetHuaDengMaxNum	= 5;			--每个花灯前5次给花灯宝箱·福以后给花灯宝箱
SpringFrestival.tbHuaDengBox_N 		= {18,1,568,1};		--花灯宝箱_未开放同伴
SpringFrestival.tbHuaDengBox 			= {18,1,568,2}		--花灯宝箱_已开放同伴
SpringFrestival.tbNianHua_Unidentify 	= {18,1,557,1};		--未鉴定的年画
SpringFrestival.tbNianHua_identify 	= {18,1,558};		--鉴定后的年画
SpringFrestival.tbNianHua_box		= {18,1,559,1};		--年画收藏盒
SpringFrestival.tbNianHua_book	= {18,1,560,1};		--年画收集册
SpringFrestival.tbNianHua_award	= {18,1,561,1};		--年画收集奖励宝箱_开放同伴
SpringFrestival.tbNianHua_award_N	= {18,1,561,2};		--年画收集奖励宝箱_未开放同伴
SpringFrestival.tbBaiNianAward	= {18,1,551,2}		--新年礼物[馈赠]
SpringFrestival.VowTreeOpenTime	= 20100202;		--许愿树，年画收集开启时间
SpringFrestival.VowTreeCloseTime	= 20100223;		--许愿树，年画收集结束时间
SpringFrestival.HuaDengOpenTime	= 20100202;		--花灯开启时间
SpringFrestival.HuaDengCloseTime	= 20100223;		--花灯结束时间
SpringFrestival.HuaDengOpenTime_C	= 1200;		--花灯开启的具体时间12点整
SpringFrestival.nBaiNianCount		= 15;				--玩家可以被拜年的次数
SpringFrestival.nGuessCounple_nCount	= 100		--活动期间玩家可以对春联的数目
SpringFrestival.nGuessCounple_nCount_daily	= 10		--活动期间玩家每天可以对春联的数目
SpringFrestival.tbVowTree_Title = {6, 20, 1, 9};		----称号奖励：第一千零一个愿望
SpringFrestival.nGetAward_longwu	= 10;				--龙五太爷处兑换年画收集册的次数
SpringFrestival.nOutTime	= 201002240000			--物品过期时间
SpringFrestival.bPartOpen = EventManager.IVER_nPartOpen;						--同伴开放开关

SpringFrestival.tbBaiAward = {		--拜年送新年礼物有几率获得一下东西（gdpl，几率区间）
	[1] = {{18,1,552,1}, 0, 40},			--希望之种
	[2] = {{18,1,555,1}, 40, 60},			--花灯春联
	[3] = {{18,1,557,1}, 60, 100},			--十二生肖年画[未鉴定]
	};

SpringFrestival.tbXiWangAward = {		--许愿5次之内有几率获得一下东西（gdpl，几率区间）
	[1] = {{18,1,551,1}, 0, 10},			--新年礼物
	[2] = {{18,1,555,1}, 10, 20},			--花灯春联
	[3] = {{18,1,557,1}, 20, 40},			--十二生肖年画[未鉴定]
	};

SpringFrestival.tbCouplet = {			--玩家对上春联后有几率获得一下东西（gdpl，几率区间）
	[1] = {{18,1,551,1}, 0, 15},			--新年礼物
	[2] = {{18,1,552,1}, 15, 30},			--希望之种
	[3] = {{18,1,557,1}, 30, 50},			--十二生肖年画[未鉴定]
	};	
	
SpringFrestival.tbNianHua = {			--成功鉴定一张年画后有几率获得一下东西（gdpl，几率区间）
	[1] = {{18,1,551,1}, 0, 20},			--新年礼物
	[2] = {{18,1,552,1}, 20, 35},			--希望之种
	[3] = {{18,1,555,1}, 35, 50},			--花灯春联
	};	
	
SpringFrestival.tbShengXiao = {"鼠", "牛", "虎", "兔", "龙", "蛇", "马", "羊", "猴", "鸡", "狗", "猪"};  --12生肖
SpringFrestival.nVowTreeTemplId	= 3723;			--许愿树模板id	
SpringFrestival.nHuaDengTemplId	= 3721;			--花灯模板id未点亮
SpringFrestival.nHuaDengTemplId_D	= 3722;		--花灯模板id点亮
SpringFrestival.tbVowTreePosition = {3,1631,3209};		--许愿树的位置(地图id，x坐标，y坐标)
SpringFrestival.tbTransferCondition = {["fight"] = 1, ["village"] = 1, ["faction"] = 1, ["city"] = 1};	--希望之种传送的限制(map的classname)

--taskId
SpringFrestival.TASKID_GROUP			= 2113;	--任务变量组
SpringFrestival.TASKID_TIME			= 1;				--时间
SpringFrestival.TASKID_COUNT			= 2;				--第几次许愿 
SpringFrestival.TASKID_ISGETAWARD		= 3;				--是否已经领奖
SpringFrestival.TASKID_NIANHUA_BOX 	= 4;    			--4到15用来记录收藏盒里面的年画数
SpringFrestival.TASKID_NIANHUA_BOOK 	= 16; 			--16到27用来记录收集册里面的年画种类
SpringFrestival.TASKID_GETAWARD		= 28;				--兑换收集册的次数
SpringFrestival.TASKID_BAINIANNUMBER	= 29;				--被拜年的次数
SpringFrestival.TASKID_IDENTIFYCOUPLET_NCOUNT		=30;		--玩家鉴定的对联数
SpringFrestival.TASKID_GUESSCOUPLET_NCOUNT			=31;		--玩家活动期间猜对联的数目
SpringFrestival.TASKID_GUESSYCOUPLET_NCOUNT_DAILY  	=32;		--玩家每天才对联的数目
SpringFrestival.TASKID_STONE_COUNT_MAX			  	=33;		--宝石数
SpringFrestival.TASKID_STONE_WEEK			  		=34;		--每周最多7个宝石

SpringFrestival.TASKID_GROUP_EX		= 2093	--修复变量组
SpringFrestival.TASKID_VOWTREE_TIME	= 18		--许愿树日期

SpringFrestival.tbLuckyStone  	={18,1,908,1};	       --幸运宝石	
SpringFrestival.STONE_COUNT_MAX			  	= 7;		--宝石数

--数据管理
SpringFrestival.HUADENG = SpringFrestival.HUADENG or {};			--7个城市的mapId和对应的刷点的文件明
SpringFrestival.HUADENG_POS = SpringFrestival.HUADENG_POS or {};	--7个城市花灯的刷出点（打乱取前50个）
SpringFrestival.tbCoupletList = SpringFrestival.tbCoupletList or {};			--对联
SpringFrestival.nVowTreenId =  SpringFrestival.nVowTreenId or 0;		--许愿树dwId
SpringFrestival.tbHuaDeng = SpringFrestival.tbHuaDeng or {};			--管理花灯
