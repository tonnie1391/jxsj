-- 文件名　：201112_xmas_def.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-11-25 11:35:50
-- 描述：2011圣诞define

SpecialEvent.Xmas2011 =  SpecialEvent.Xmas2011 or {};
local Xmas2011 = SpecialEvent.Xmas2011;

Xmas2011.nEventBeginTime = 20111222; 
Xmas2011.nEventEndTime	=  20120103;

--活动是否开启，gs和gc通用
function Xmas2011:IsEventOpen()
	local nTime = tonumber(os.date("%Y%m%d",GetTime()));
	if nTime < self.nEventBeginTime or nTime >= self.nEventEndTime then
		return 0;
	end
	return 1;
end

---------------------public---------------------------
Xmas2011.nTaskGroupId = 2185;	--活动相关任务变量组id

Xmas2011.szMaskNeedName = "圣诞";	--面具需要和圣诞相关才能进行活动

Xmas2011.tbEventFunction = --活动系统对应的函数接口
{
	[1] = "OnGiveMaskBox",--领面具
	[2] = "OnGetPrizeSock",--领装满礼物的袜子
	[3] = "OnGetSnowBase",	--领取雪人底座
	[4] = "OnJoinXmasMission",	--圣诞关卡
};

Xmas2011.szDecorationPosFile = "\\setting\\event\\jieri\\201112_xmas\\decorationpos.txt";	--装饰npc的位置信息

---------------------给面具活动------------------------
Xmas2011.tbMaskGdpl	 =  {18,1,1530,1}	;--给的面具的gdpl

Xmas2011.nGetMaskBaseLevel = 50;	--领面具的等级需求

Xmas2011.tbMaskDetailGdpl = 	--给的面具细类的gdpl
{
	[1] = {1,13,160,10},
	[2]	= {1,13,161,10},
	[3] = {1,13,162,10},
	[4]	= {1,13,163,10},
};

Xmas2011.nHasGetMaskTaskId = 1;	--是否已经领取过面具了

----------------------找袜子活动----------------------
Xmas2011.nSockEventBaseLevel = 50;	--要求的最低等级

Xmas2011.nGetSockMaxCount = 2;	--每人每天最大领取的袜子数量

Xmas2011.nLastGetSockTimeTaskId = 2;	--上次领取袜子的时间

Xmas2011.nHasGetSockCountTaskId = 3;	--已经领取过的袜子数量

Xmas2011.nLastGetSockLevelTaskId = 4;	--上次领取的袜子的level，用于领取装满礼物袜子判断

Xmas2011.nStandNpcTemplateId = 9823;	--站立的圣诞老人

Xmas2011.nStandNpcLiveTime = 30 * Env.GAME_FPS;	--站立的圣诞老人存在时间

Xmas2011.nWalkNpcTemplateId = 9824;		--行走的圣诞老人

Xmas2011.nGetSockRequireRange = 30;		--队伍领取袜子需要在一起的距离

Xmas2011.nStarNpcTemplateId = 9825;		--放置的星星模板id

Xmas2011.nOpenStarRequireRange = 5;	--每个星星中间需要的间隔

Xmas2011.nStarLiveTime =  60 * 60 * Env.GAME_FPS;	--星星npc存在时间，帧为单位

Xmas2011.nSockLiveTime = 3 * 60 * 60;	--袜子的存在时间,秒为单位

Xmas2011.nNpcBeginWalkTimeDay = 1100;	--开始游行的白天时间

Xmas2011.nNpcEndWalkTimeDay = 1400;		--结束游行的白天时间

Xmas2011.nNpcBeginWalkTimeNight = 1900;	--开始游行的晚上时间

Xmas2011.nNpcEndWalkTimeNight = 2200;	--结束游行的晚上时间

Xmas2011.nWalkEventDelayTime = 3 * 60 * 60 * Env.GAME_FPS;	--活动开始的计时器

Xmas2011.nWalkNpcCastSkillDelayTime = 10 * Env.GAME_FPS;	--站立npc释放特效的间隔

Xmas2011.tbWalkNpcSkillId = {1564,1567,1562};		--行走npc释放的特效

Xmas2011.szWalkNpcAiRouteFile = "\\setting\\event\\jieri\\201112_xmas\\walknpcroute.txt";

Xmas2011.tbNpcAiRouteMaxStep = --每个城市ai路线数的最大值
{
	[28] = 8,
	[29] = 15,
	[25] = 11,
};

Xmas2011.tbPrizeSockGdpl = {18,1,1531,1};--装满礼物的袜子

Xmas2011.tbSockGdp = {18,1,1532};	--普通袜子的gdp，用于寻找身上的袜子

Xmas2011.tbSockGdpl = --普通袜子
{
	{18,1,1532,1},
	{18,1,1532,2},
	{18,1,1532,3},
	{18,1,1532,4},
	{18,1,1532,5},
};

Xmas2011.tbPrizeRandomItemId = 
{
	[1] = 272,
	[2] = 273,
	[3] = 274;	--礼物袜子的随机物品id
};

Xmas2011.szNotifyMsgPerHour = "圣诞老人驾着雪橇在襄阳、大理、临安出现了！快去找他领取圣诞袜子，寻找拥有另一只袜子的队友！卖火柴的小女孩在等着你们！";

Xmas2011.nNotifyTime = 60 * 60 * Env.GAME_FPS;	--通告的时间间隔

Xmas2011.nNotifyMaxCount = 3;	--通知的最大次数

Xmas2011.nUpStarSkillId = 1977;	--放星星的特效

---------------------堆雪人
Xmas2011.nMakeSnowBoyBaseLevel = 50;	--堆雪人的等级限制

Xmas2011.nMakeSnowBoyRequirePlayerCount = 3;	--需要3名玩家组队

Xmas2011.nLastGetSnowBaseTimeTaskId = 5;	--上次领取雪人底座的时间

Xmas2011.nHasGetSnowBaseCountTaskId = 6;	--已经领取雪人底座的数量

Xmas2011.nLastGetSnowPrizeTimeTaskId = 7;	--上次领取雪人奖励的时间

Xmas2011.nHasGetSnowPrizeCountTaskId = 8;	--已经领取雪人奖励的次数

Xmas2011.nGetSnowBaseMaxCount = 1;	--每人每天最多可以领1个雪人底座

Xmas2011.nGetSnowPrizeMaxCount = 1;	--每人每天最多可以领1次雪人奖励

Xmas2011.nSnowBaseTemplateId = 9826; --冰座npc

Xmas2011.nDropSnowBaseRequireRange = 10;	--每个冰座中间需要的间隔

Xmas2011.nSnowBaseLiveTime = 60 * 60 * Env.GAME_FPS;	--冰座存在时间

Xmas2011.nUnFinishSnowBoyTemplateId = 9827; --未完成的雪人

Xmas2011.nUnFinSnowBoyLiveTime = 60 * 60 * Env.GAME_FPS;	--未完成的雪人的存在时间

Xmas2011.nSnowBoyTemplateId = 9828; --完成的雪人

Xmas2011.nNeedSnowBallCount = 15;	--需要交15个雪团

Xmas2011.nSnowBoyLiveTime = 60 * 60 * Env.GAME_FPS;	--雪人的存在时间

Xmas2011.tbSnowBaseItemGdpl = {18,1,1533,1};	--雪人冰座gdpl

Xmas2011.tbNormalSnowBallGdpl = {18,1,1534,1};	--脏兮兮的雪花团子

Xmas2011.tbSnowBallGdpl = {18,1,1535,1};	--莹白的雪花团子

Xmas2011.nForbidMakeSkillId = 2328;	--冻得手通红 技能id

Xmas2011.nForbidMakeTime = 10 * Env.GAME_FPS;	--冻得手通红 时间

Xmas2011.nInputStringMaxLength = 6;	--输入字符的最大长度，汉字3个

Xmas2011.nGiveSnowboyPrizeCount = 3;	--每人给3个奖励

Xmas2011.tbSnowPrizeGdpl = 
{
	[1] = {18,1,1538,1},   --<146
	[2] = {18,1,1544,1},   -- 146 - 365
	[3] = {18,1,1597,1},   -- > 365
};	--雪人给的奖励

Xmas2011.nMakeSnowBallNeedGTMK = 300;	--做雪球需要的精活

------------------雪城建设
Xmas2011.nCheckAddSnowManTime = 0000;	--每天0点检测是否要刷雪人了

Xmas2011.nProduceSnowManBaseLevel = 50;	--参加雪城建设的等级需求

Xmas2011.nLastProduceSnowManTimeTaskId = 9;	--上次参加雪城建设的时间

Xmas2011.nHasGiveSnowBallCountTaskId = 10;	--已经上交雪团的个数

Xmas2011.nCanGiveSnowBallMaxCount = 10;	--每个人每天可以上交的雪团的数量

Xmas2011.nHasGetSnowManFinalPrizeTaskId = 11;	--是否领取过雪人的最终奖励

Xmas2011.nSnowManTemplateId = 9830;	-- 雪城建设的npc模板id

Xmas2011.tbSnowManPosInfo = {29,1625,3944};	--雪人的pos

Xmas2011.nFinishProduceNeedMaxCount = 15000;	--雪人建成需要的最大雪球数量

Xmas2011.tbReturnPrizePreOneTime = {
	[1]={18,1,1539,1},  --<146      
	[2]={18,1,1594,1},  -- 146 - 365
	[3]={18,1,1598,1},  -- >365    
};	--每交一个雪团返还的箱子

Xmas2011.nFinalPrizeCount = 18;	--最终给18个箱子

Xmas2011.tbReturnPrizeFinal = {
	[1]={18,1,1540,1},  -- <146      
	[2]={18,1,1595,1},  -- 146 - 365
	[3]={18,1,1599,1},  -- >365    
};	    --雪人建成后给的最终奖励

Xmas2011.nSyncProduceProgressTimeDelay = 5 * 60 * Env.GAME_FPS;	--同步雪人建设进度的时间

Xmas2011.szNotifyProduceMsg = "雪城建设正在紧张进行中，大家可到临安府赠予雪人滚滚【莹白的雪花团子】，当即即可获得丰厚奖励。";

Xmas2011.nNotifyProduceTime = 54 * 60 * Env.GAME_FPS;	--54分钟公告一次

-----------圣诞关卡
Xmas2011.nJoinXmasMissionBaseLevel = 50;	--参加圣诞关卡的等级需求

Xmas2011.szGameName = "圣诞关卡";	--关卡名字

Xmas2011.nJoinXmasGameBaseMemberCount = 6;			--参加圣诞关卡需要的队伍最低人数

Xmas2011.tbJoinXmasGameNeedItem = {18,1,1536,1};	--进入关卡需要的道具gdpl

Xmas2011.nXmasGameType = 2;	--圣诞管卡的type

Xmas2011.nXmasGameId = 1;	--圣诞关卡的id

Xmas2011.nNeedStonePieceCount = 20;	--20个碎片换一个箱子
Xmas2011.nNeedMoonStoneCount = 20;	--需要20个月影
Xmas2011.tbStoneBoxGdpl	 = {18,1,1542,1};--宝箱gdpl
Xmas2011.nBoxMaxStack = 100;	--宝箱最大的叠加数
Xmas2011.tbStonePieceGdpl = {18,1,1541,1}; --碎片gdpl
Xmas2011.tbMoonStoneGdpl = {18,1,476,1};	--月影的gdpl

---家族关卡的圣诞boss
Xmas2011.tbKinGameXmasBossTemplateId = 
{
	[1] = 9837,	--老关卡
	[2] = 9836, --新关卡
}	--家族关卡boss

Xmas2011.nWaitNpcTemplateId = 2976;	

Xmas2011.nWaitTime = 10;	--等待10秒删除特效npc

Xmas2011.tbNoramlDropFile = 
{
	[1] = "\\setting\\event\\jieri\\201112_xmas\\christboss_1.txt",	
	[2] = "\\setting\\event\\jieri\\201112_xmas\\christboss_2.txt",
	[3] = "\\setting\\event\\jieri\\201112_xmas\\christboss_3.txt",
}

Xmas2011.szMaskDropFile = "\\setting\\event\\jieri\\201112_xmas\\christboss_mask.txt";

Xmas2011.szStoneDropFile = "\\setting\\event\\jieri\\201112_xmas\\christboss_stone.txt";

-----------下雪
Xmas2011.nBeginSnowTime = 1000;	--开始下雪时间
Xmas2011.nEndSnowTime 	= 2300;	--下雪结束时间
Xmas2011.nSnowWeatherId = 3;	--下雪的天气id
Xmas2011.nSnowDelayTime = 5 * 60 * Env.GAME_FPS;	--每次下雪持续时间
Xmas2011.nSnowCheckTime = 30 * 60 * Env.GAME_FPS;	--下雪间隔时间
Xmas2011.tbSnowCityId = {23,24,25,26,27,28,29};	--下雪城市的id