-- 文件名　：define.lua
-- 创建者　：jiazhenwei
-- 创建时间：2009-12-28 11:41:23
-- 描  述  ：
SpecialEvent.ZhenZai = SpecialEvent.ZhenZai or {};
local ZhenZai = SpecialEvent.ZhenZai or {};

ZhenZai.nLevel 			= 60;    				--玩家等级限制
ZhenZai.tbXiWang 		= {18,1,937,1}; 		--希望之种
ZhenZai.tbBaoXiang 		= {18,1,936,1};			--宝箱：第一千零一个愿望
ZhenZai.tbVowXiang 	= {18,1,935,1};			--愿望盒子
ZhenZai.nTrapNumber 		= 2010;			--1001个愿望后大家可以领奖励
ZhenZai.nGetFudaiMaxNum 	= 5; 				--许愿前5次获得福袋和有几率的奖励
ZhenZai.VowTreeOpenTime	= 20100420;		--许愿树，年画收集开启时间
ZhenZai.VowTreeCloseTime	= 20100511;		--许愿树，年画收集结束时间
ZhenZai.tbVowTree_Title 		= {6, 26, 1, 9};		--称号奖励：第一千零一个愿望
ZhenZai.tbPingAnYiJia		= {6, 25, 1, 9};		--平安一家称号
ZhenZai.nOutTime			= 201005120000;	--物品过期时间
ZhenZai.bPartOpen 			= EventManager.IVER_nPartOpen;						--开放开关
ZhenZai.nVowTreeTemplId	= 6814;


ZhenZai.tbVowTreePosition = {29, 47040/32, 120992/32};		--许愿树的位置(地图id，x坐标，y坐标)
ZhenZai.tbTransferCondition = {["fight"] = 1, ["village"] = 1, ["faction"] = 1, ["city"] = 1};	--希望之种传送的限制(map的classname)


--taskId
ZhenZai.TASKID_GROUP			= 2121;	--任务变量组
ZhenZai.TASKID_TIME			= 1;				--时间
ZhenZai.TASKID_COUNT			= 2;				--第几次许愿 
ZhenZai.TASKID_ISGETAWARD		= 3;				--是否已经领奖
ZhenZai.TASKID_TIMEEx			= 8;				--领奖的时间记录
ZhenZai.TASKID_GETPINGAN		= 7;				--是否已经领奖

--数据管理
ZhenZai.nVowTreenId =  ZhenZai.nVowTreenId or 0;		--许愿树dwId
