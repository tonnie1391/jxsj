-- 文件名　：201201_springfestival_def.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-12-26 09:28:04
-- 描述：define

SpecialEvent.SpringFestival2012 = SpecialEvent.SpringFestival2012 or {};
local SpringFestival = SpecialEvent.SpringFestival2012;

--第一阶段时间
SpringFestival.nStep1BeginTime = 20120115;
SpringFestival.nStep1EndTime = 20120130;

--第二阶段时间
SpringFestival.nStep2BeginTime = 20120131;
SpringFestival.nStep2EndTime = 20120206;

function SpringFestival:IsEventStep1Open()
	local nTime = tonumber(os.date("%Y%m%d",GetTime()));
	if nTime < self.nStep1BeginTime or nTime > self.nStep1EndTime then
		return 0;
	end
	return 1;
end

function SpringFestival:IsEventStep2Open()
	local nTime = tonumber(os.date("%Y%m%d",GetTime()));
	if nTime < self.nStep2BeginTime or nTime > self.nStep2EndTime then
		return 0;
	end
	return 1;
end

function SpringFestival:IsEventOpen()
	local nTime = tonumber(os.date("%Y%m%d",GetTime()));
	if nTime < self.nStep1BeginTime or nTime > self.nStep2EndTime then
		return 0;
	end
	return 1;
end

SpringFestival.nTaskGroupId = 2187;	 --活动相关任务变量组id

---------------拜年活动
SpringFestival.nBlessBaseLevel = 50;	--拜年需要的等级

SpringFestival.nLastGetBlessCardTimeTaskId = 1;	--上次领取拜年卡的时间

SpringFestival.nTotalGetBlessCardCountTaskId = 2;	--总共领取的拜年卡个数

SpringFestival.nLastBlessToTimeTaskId = 3;	--上次拜年的时间

SpringFestival.nBlessToCountTaskId = 4;	--当天拜年的次数

SpringFestival.nLastBlessFromTimeTaskId = 5;	--上次被拜年的时间

SpringFestival.nBlessFromCountTaskId = 6;	--被拜年的次数

SpringFestival.nGetWordCardTaskId = 7;	--存储获得到的字卡level，存储的位为3*nLevel - 2到3*nLevel

SpringFestival.nBlessToMaxCountPerDay = 5;	--每天可以拜年的最大次数

SpringFestival.nBlessFromMaxCountPerDay = 10;	--每天可以被拜年的最大次数

SpringFestival.nCanGetBlessCardMaxCount = 8;	--活动期间可以领拜年卡最大个数

SpringFestival.tbBlessCardGdpl = {18,1,1601,1};	--拜年卡的gdpl

SpringFestival.tbBlessFromPrize = {18,1,1619,1};	--被拜年的奖励

SpringFestival.nBlessToPrizeCount = 5;	--拜年的奖励箱子数量

SpringFestival.nBlessNeedRange = 50;	--拜年需要在一起的距离

SpringFestival.tbWordCardGdpl =		--字卡的gdpl
{
	{18,1,1602,1},
	{18,1,1602,2},
	{18,1,1602,3},
	{18,1,1602,4},
	{18,1,1602,5},
};

SpringFestival.tbBlessMsg = --祝福的话
{
	"送了你一份新年礼物，捂着嘴笑道：“祝你永远18岁。”",								
	"双手捧着礼物，含情脉脉的看着你说：“亲爱的，新年快乐！”",
	"眯起眼睛伸着手对你说：“恭喜发财，红包拿来！”",
	"拍着你的肩膀说道：“在我们相聚的日子里，兄弟情谊最珍稀。”",
	"为你送上了新年礼物，笑容满面的说：“走，一起下逍遥发财去。”",
	"对你爽朗的一笑：“来来来，废话不多说。开一个红包，好运吉祥送给你。”", 
	"慢蹭蹭的把礼物递到你面前，嘴里还嘀咕着：“明年记得还礼啊！”",
	"一边将礼物递给你一边擦着汗说道：“昨晚我梦到和你在宋金战场里大战了三百个回合！”",
	"送上了礼物，双手合拳向你一拜：“祝你金奖银奖天天中，5级宝石镶满身！”",
	"从身后拿出一份礼物塞给你，害羞的低下了头，什么也没有说…", 
};

SpringFestival.nCanRepeatBlessToOne = 1;	--是否可以向同一个人拜年,测试用

----道具任务变量,切忌
SpringFestival.nItemRecordBlessListGroupId = 2;	--道具上记录拜年的玩家的groupid

SpringFestival.nItemRecordBlessListTaskId  = 1;	--道具上记录拜年的玩家的taskid


----------------福袋开出额外的新年礼包
SpringFestival.nGetExtPrizeBaseLevel = 50;	--拜年需要的等级

SpringFestival.tbExtFudaiGdpl = {18,1,1624,1};	--新年福袋

SpringFestival.tbExtFudaiCount = 	--不同活动对应给的新年福袋数量
{
	[1] = 3,	--拜年活动，开启奖励宝箱时
	[2] = 15,	--祈愿，使用最终的奖券时（最多4个）
	[3] = 8,	--挂灯笼，开启宝箱时
	[4] = 9,	--聚宝盆，开启宝箱时
	[5] = 4,	--家族收红包，开启果实兑换的宝箱时
	[6] = 3,	--福袋，开启普通福袋时
	[7] = 5,	--宋金，分数达到3000以上
	[8] = 7,	--军营，通关
	[9] = 7,	--逍遥谷，通关3关以上
	[10] = 5,	--白虎堂，到达第二层
	[11] = 6,	--藏宝图，得乐坊领奖时
	[12] = 8,	--拜年，打开集卡奖励宝箱时
}
----------------福币
SpringFestival.nGetFubiBaseLevel = 50;	--拜年需要的等级

SpringFestival.tbFubiCannotUseGdpl = {18,1,1607,1};	--不能使用的福币

SpringFestival.tbFubiCanUseGdpl = {18,1,1608,1};	--可以使用的福币

SpringFestival.nFubiChangeEndTime = 20120213; --福币兑换的截止时间

function SpringFestival:IsTimeCanChangeFubi()
	local nTime = tonumber(os.date("%Y%m%d",GetTime()));
	if nTime < self.nStep2BeginTime or nTime > self.nFubiChangeEndTime then
		return 0;
	end
	return 1;
end

-----------------元宵节汤圆
SpringFestival.nYuanxiaoTableId = 9892;		--宴席npc模板id

SpringFestival.nLastGetYuanxiaoStuffTimeTaskId = 8;	--上次领取汤圆材料时间

SpringFestival.nLastUseYuanxiaoTimeTaskId = 9;	--上次使用元宵的时间

SpringFestival.nUseYuanxiaoCountTaskId = 10;	--当天已经使用元宵的次数

SpringFestival.nUseYuanxiaoTotalCountTaskId = 11;	--总共使用的元宵次数

SpringFestival.nLastEatYuanxiaoTimeTaskId = 12;	--上次吃元宵的时间

SpringFestival.nEatYuanxiaoCountTaskId = 13;	--当天吃元宵的次数

SpringFestival.nEatYuanxiaoTotalCountTaskId = 14;	--总共吃了多少次元宵

SpringFestival.nCanUseYuanxiaoMaxPerDay = 3;  --每天可以使用元宵的次数

SpringFestival.nCanUseYuanxiaoMaxTotal = 9;	--总共可以使用多少次元宵

SpringFestival.nCanEatYuanxiaoMaxPerDay = 15; --每天最多可以吃多少元宵

SpringFestival.nCanEatYuanxiaoMaxTotal = 45; --总共可以吃多少次元宵

SpringFestival.nCanEatMaxCountPerTable = 5;	--每个桌子可以被吃多少次

SpringFestival.nGetStuffBaseLevel = 50;

SpringFestival.nGetStuffNeedCell = 3;	--领取材料需要的背包空间

SpringFestival.tbYuanxiaoStuffInfo = --材料的信息
{
	{{22,1,108,1},3},
	{{22,1,109,1},3},
	{{22,1,110,1},3},
};

SpringFestival.tbDropYuanxiaoPrizeGdpl = {18,1,1625,1};	--汤圆给的奖励
SpringFestival.tbEatYuanxiaoPrizeGdpl = {18,1,1626,1};	--吃元宵的奖励

--元宵节时间
SpringFestival.nYuanxiaoBeginTime = 20120205;
SpringFestival.nYuanxiaoEndTime = 20120207;

--元宵节是否开启
function SpringFestival:IsYuanxiaoOpen()
	local nTime = tonumber(os.date("%Y%m%d",GetTime()));
	if nTime < self.nYuanxiaoBeginTime or nTime > self.nYuanxiaoEndTime then
		return 0;
	end
	return 1;
end

-----------------好运聚宝盆
SpringFestival.nGetIngotBaseLevel = 50;	--摸宝的最低等级

SpringFestival.nGetIngotMaxCountPerDay = 2;	--每人每天最多可以摸宝的次数

SpringFestival.nLastGetIngotTimeTaskId = 15;	--上次摸宝的时间

SpringFestival.nGetIngotCountTaskId = 16;	--今天已经领取过的元宝个数

SpringFestival.nLastGetIngotLevelTaskId = 17;		--上次领取元宝的level

SpringFestival.tbIngotGdp= {18,1,1610};		--元宝gdp，用于查找组队身上的元宝是否配对

SpringFestival.tbIngotGdpl = 	--元宝gdpl，每次随机给
{
	{18,1,1610,1},
	{18,1,1610,2},
	{18,1,1610,3},
	{18,1,1610,4},
	{18,1,1610,5},
	{18,1,1610,6},
}

SpringFestival.tbMatchLevel = 	--配对的元宝level对应关系
{
	[1] = 2,
	[2] = 1,
	[3] = 4,
	[4] = 3,
	[5] = 6,
	[6] = 5,
};

SpringFestival.nIngotLiveTime = 3 * 60 * 60;	--元宝存在时间

SpringFestival.nBeginGetIngotTimeDay = 1200;	--开始摸宝的白天时间

SpringFestival.nEndGetIngotTimeDay = 1400;		--结束摸宝的白天时间

SpringFestival.nBeginGetIngotTimeNight = 2000;	--开始摸宝的晚上时间

SpringFestival.nEndGetIngotTimeNight = 2200;	--结束摸宝的晚上时间

SpringFestival.nMatchIngotNeedRange = 30;	--配对需要队友在一起的距离

SpringFestival.nMatchIngotNeedMemberCount = 2;	--配对需要2个人队伍

SpringFestival.tbLipaoGdpl = {18,1,1616,1};		--配对成功给的礼炮

SpringFestival.nLipaoItemLiveTime = 3 * 60 * 60;	--得到的礼炮存在时间

SpringFestival.nLipaoNpcTemplateId = 9894;	--礼炮npc模板id

SpringFestival.nLipaoDropRange 	= 20;	--安置礼炮需要的间隔

SpringFestival.nLipaoNpcLiveTime = 60 * 60 * Env.GAME_FPS;	--礼炮npc存在时间

SpringFestival.nFireLipaoTimeDeta = 5;	--两人需要同时点礼炮的时间差

SpringFestival.tbLipaoPrizeGdpl = {18,1,1623,1};	--礼炮给的奖励的gdpl

SpringFestival.nLipaoCastSkillDelay =  30 * Env.GAME_FPS;	--礼炮释放特效间隔

SpringFestival.nLipaoSkillId = {2478};	--礼炮的技能特效

SpringFestival.szNotifyMsgPerHour = "临安符、汴京府广场中央的聚宝盆中刷新了各式宝物，各位英雄快去寻宝吧！";

SpringFestival.nNotifyTime = 20 * 60 * Env.GAME_FPS;	--通告的时间间隔

SpringFestival.nNotifyMaxCount = 6;	--通知的最大次数


---------------字卡换奖励
SpringFestival.nGiveWordCardTaskId = 18; --存储上交的字卡level，存储的位为3*nLevel - 2到3*nLevel

SpringFestival.tbWordCardPrizeInfo = --兑奖给的奖励
{
	[1] =  {{18,1,1620,1},1},
	[2] =  {{18,1,1620,1},2},
	[3] =  {{18,1,1620,1},3},
	[4] =  {{18,1,1620,1},4},
	[5] =  {{18,1,1620,1},5},		
};


--------------灯笼高高挂
SpringFestival.nDropLanternBaseLevel = 50;	--挂灯笼的等级

SpringFestival.nLastGetMatchTimeTaskId = 19;	--上次获得火折子的时间

SpringFestival.nGetMatchCountTaskId = 20;	--获得火折子的数量

SpringFestival.nLastFireLanternTimeTaskId = 21;	--上次点灯笼的时间

SpringFestival.nFireLanternCountTaskId = 22;	--点灯笼的数量

SpringFestival.nGetMatchMaxCountPerDay = 2;		--每天可以获得火折子的最大数量

SpringFestival.nFireLanternMaxCountPerDay = 2;	--每天可以点灯笼的最大数量

SpringFestival.tbMatchGdpl = {18,1,1617,1};	--未燃烧的火折子

SpringFestival.tbFireMatchGdpl = {18,1,1618,1}; --燃烧的火折子

SpringFestival.nFireLanternLiveTime = 15 * 60 * Env.GAME_FPS;	--点燃灯笼存在时间

SpringFestival.tbLanternPrizeGdpl = {18,1,1622,1};	--点灯笼的奖励

SpringFestival.nFireLanternBuffId = 2479;	--头顶buff

SpringFestival.nFireLanternBuffTime = 60 * 60 * Env.GAME_FPS;	--加的buff时间

SpringFestival.nLanternUnFireTemplateId = 9895;	--未点燃花灯的模板id

SpringFestival.nLanternTemplateId = 9896;	--点燃的花灯模板id

SpringFestival.nMakeFireMatchNeedGTMK = 780;	--制作燃烧火折子需要的精活

SpringFestival.szLanternPosFile = "\\setting\\event\\jieri\\2012_springfestival\\lantern.txt";	--花灯的pos

SpringFestival.nCheckAddLanternTime  = 0000;	--检测是否要刷花灯

----------抽奖相关
SpringFestival.nHopeBaseLevel = 50;		--等级需求

SpringFestival.nBuyHopeCardTotalTaskId = 23;	--总共购买的祈愿卡的数量

SpringFestival.nChangeLotteryCardTaskId = 24; --存储已经兑换过的抽奖卡的level，存储的位为3*nLevel - 2到3*nLevel

SpringFestival.nMaxBuyHopeCardCount = 4;	--最大购买的祈愿卡数量

SpringFestival.tbMoonStoneGdpl = {18,1,476,1};	--月影的gdpl

SpringFestival.nNeedMoonStoneCount = 1;		--需要一个月影换一个

SpringFestival.nHopeCardWareId = 589;	--金币购买祈愿卡的id

SpringFestival.nHopeCardCost = 100;		--花费100金币购买祈愿卡

SpringFestival.tbHopeCardGdpl = {18,1,1634,1};		--祈愿卡gdpl

SpringFestival.nHopeGiveBindCoin = 400;		--祈愿后给的绑金

SpringFestival.tbLotterCardGdpl = --抽奖卡gdpl
{
	{20120131,{18,1,1635,1},"正月初九",},
	{20120202,{18,1,1635,2},"正月十一",},
	{20120204,{18,1,1635,3},"正月十三",},
	{20120206,{18,1,1635,4},"正月十五",},
};

SpringFestival.nHopeBegeinDate = 20120115; --祈愿开始时间

SpringFestival.nHopeEndDate = 20120130;	--祈愿结束时间

SpringFestival.nLotteryBeginDate = 20120131; --抽奖开始日期

SpringFestival.nLotteryEndDate   = 20120209; --抽奖结束日期

SpringFestival.tbLotterCardUseTime = --抽奖卡使用时间
{
	[1] = {201201302200,201201312200},
	[2] = {201202012200,201202022200},
	[3] = {201202032200,201202042200},
	[4] = {201202052200,201202062200},
};

---祈愿的时间
function SpringFestival:IsHopeOpen()
	local nTime = tonumber(os.date("%Y%m%d",GetTime()));
	if nTime < self.nHopeBegeinDate or nTime > self.nHopeEndDate then
		return 0;
	end
	return 1;
end

--抽奖的时间
function SpringFestival:IsLotteryOpen()
	local nTime = tonumber(os.date("%Y%m%d",GetTime()));
	if nTime < self.nLotteryBeginDate or nTime > self.nLotteryEndDate then
		return 0;
	end
	return 1;
end
