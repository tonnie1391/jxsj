-- 文件名　：201202_loverday_def.lua
-- 创建者　：zhangjunjie
-- 创建时间：2012-02-02 15:37:06
-- 描述：define

SpecialEvent.LoverDay2012 = SpecialEvent.LoverDay2012 or {};
local LoverDay2012 = SpecialEvent.LoverDay2012;

--活动开始时间
LoverDay2012.nBegeinTime = 20120214;
LoverDay2012.nEndTime = 20120216;


--领取奖励时间
LoverDay2012.nGetPrizeBeginTime = 20120217;
LoverDay2012.nGetPrizeEndTime   = 20120219;


--任务变量组id
LoverDay2012.nTaskGroupId = 2188;

--参加等级
LoverDay2012.nJoinEventBaseLevel = 50;

--给的烟花的gdpl
LoverDay2012.tbYanhuaGdpl = {
	{18,1,988,2},
	{18,1,571,2},
	{18,1,571,3},
}

--活动是否开启
function LoverDay2012:IsEventOpen()
	local nTime = tonumber(os.date("%Y%m%d",GetTime()));
	if nTime < self.nBegeinTime or nTime > self.nEndTime then
		return 0;
	end
	return 1;
end

--是否可以领奖励的时间
function LoverDay2012:IsTimeCanGetPrize()
	local nTime = tonumber(os.date("%Y%m%d",GetTime()));
	if nTime < self.nGetPrizeBeginTime or nTime > self.nGetPrizeEndTime then
		return 0;
	end
	return 1;
end



--玫瑰情缘---------------------
LoverDay2012.nRoseLoveBeginTime = 1900;	--开始时间
LoverDay2012.nRoseLoveEndTime   = 2200;	--结束时间


function LoverDay2012:IsTimeRoseLoveBegin()
	local nTime = tonumber(os.date("%H%M",GetTime()));
	if nTime < self.nRoseLoveBeginTime or nTime >= self.nRoseLoveEndTime then
		return 0;
	end
	return 1;
end


LoverDay2012.nLastGetRoseLoveTimeTaskId = 1;	--上次接取任务的时间

LoverDay2012.nHasGetRoseLovePrizeTaskId = 2;	--是否领过奖励了

LoverDay2012.tbRoseLoveItem = {18,1,1642,1};	--活动道具

LoverDay2012.nDropFlowerRange = 10;	--放花坛的间距

LoverDay2012.nFlowerBaseNpcTemplateId = 9922;	--花坛的模板id

LoverDay2012.nFlowerFinishNpcTemplateId = 9923;	--任务完成后的模板id

LoverDay2012.nFlowerBaseLiveTime = 60 * 60 * Env.GAME_FPS;	--花坛存在时间

LoverDay2012.tbTaskNeedFlower = --所需的花朵是什么
{
	{18,1,1643,1},
	{18,1,1644,1},
	{18,1,1645,1},
	{18,1,1646,1},
};

LoverDay2012.tbTaskNeedFlowerCount = {2,3,4,5};--所需的数量

LoverDay2012.tbRoseBaseMatchRose = --不同花坛对应产出的花朵
{
	[9918] = {18,1,1643,1},
	[9919] = {18,1,1644,1},
	[9920] = {18,1,1645,1},
	[9921] = {18,1,1646,1},
}

LoverDay2012.tbRoseLovePrize = {18,1,1647,1};	--奖励道具，侠侣*2
LoverDay2012.nRoseLovePrizeCountNormal = 1;
LoverDay2012.nRoseLovePrizeCountCouple = 2;



----------爱神对对碰
LoverDay2012.nLoveMatchBeginTimeDay = 1100
LoverDay2012.nLoveMatchEndTimeDay = 1400

LoverDay2012.nLoveMatchBeginTimeNight = 1900
LoverDay2012.nLoveMatchEndTimeNight = 2100

LoverDay2012.nLastGetRingTimeTaskId = 3;	--上次获得戒指的时间
LoverDay2012.nGetRingCountStep1TaskId = 4;		--第一阶段得到戒指的数量
LoverDay2012.nGetRingCountStep2TaskId = 5;		--第二阶段得到戒指的数量

LoverDay2012.tbCanGetMaxRing = 	--每一时间段可以领取戒指的数量
{
	[0] = 1,	
	[1] = 2,
};

LoverDay2012.tbRingGdpl = --戒指的gdpl
{
	{18,1,1648,1},
	{18,1,1648,2},
	{18,1,1648,3},
};

LoverDay2012.nRingLiveTime = 3 * 60 * 60;	--戒指存在时间,3个小时

LoverDay2012.tbRingMatchItemGdpl = {18,1,1651,1};	--配对成功后给的红烛

LoverDay2012.nHongzhuNpcTemplateId = 9924;	--红烛模板id

LoverDay2012.nHongzhuNeedRange = 15;	--放红烛需要的间距

LoverDay2012.nHongzhuLiveTime = 15 * 60 * Env.GAME_FPS;	--红烛存在时间

LoverDay2012.tbGetCardRate = {1,3};	--得到卡片的概率,1/3

LoverDay2012.tbCardGdpl = {18,1,1653,1};	--卡片的gdpl

LoverDay2012.tbRingMatchPrize =
{
 	[0] =   {18,1,1661,1},	--配对奖励道具，男
 	[1] =   {18,1,1652,1},	--配对奖励道具，女
}

LoverDay2012.nRingMatchPrizeCountNormal = 1;
LoverDay2012.nRingMatchPrizeCountCouple = 2;

LoverDay2012.tbCardPrize = {18,1,1654,1};	--卡片奖励道具，普通

LoverDay2012.tbChatToFromMsg = --密聊的内容
{
	"亲，在哪里？到我这里来领取誓约奖励！",	
	"你在忙么？我想和你聊聊天。",
	"在做什么？一起去做任务好不好？",
	"情人节认识你很开心，希望我们能做个朋友！",
	"我对你一见钟情了，我愿做你的召唤兽，陪你闯危险的宇宙。",
}



-------刷npc--------
LoverDay2012.szNpcPosFile = "\\setting\\event\\jieri\\201202_loverday\\npcpos.txt";

LoverDay2012.nAddNpcTime = 0000;	--检测刷npc的时间

LoverDay2012.szRoseLoveNotify = "浪漫时刻,甜蜜分享,玫瑰情缘活动温馨开启,请各位侠客前往爱神处接受爱的祝福！";

LoverDay2012.nRoseLoveNotifyTime = 30 * 60 * Env.GAME_FPS;	--通告的时间间隔

LoverDay2012.nRoseLoveNotifyMaxCount = 6;	--通知的最大次数

LoverDay2012.szMatchNotify = "执子之手、与子偕老，爱神对对碰活动浪漫开启，甜蜜派对单身也疯狂！";

LoverDay2012.nMatchNotifyTime = 30 * 60 * Env.GAME_FPS;	--通告的时间间隔

LoverDay2012.nMatchNotifyMaxCount = 6;	--通知的最大次数