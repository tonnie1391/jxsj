-- 文件名　：newserverevent_def.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-11-09 16:35:40
-- 描述：新服固定活动define

SpecialEvent.NewServerEvent =  SpecialEvent.NewServerEvent or {};
local NewServerEvent = SpecialEvent.NewServerEvent;

NewServerEvent.nEndDate = 14;	--新服固定活动，14天后结束
NewServerEvent.nTaskId = 2183;		--新服活动的玩家变量组id

------------家族活动
NewServerEvent.nCallKinBossTimeStart = 1830;	--家族招boss的开始时间
NewServerEvent.nCallKinBossTimeEnd   = 2300;	--家族招boss的结束时间
NewServerEvent.nMaxOpenBoxCount		 = 4;		--家族每个人每天可以开启宝箱的次数
NewServerEvent.tbIbShopCallBossGDPL	 = {18,1,1520,1};	--奇珍阁自动使用，使用后给一个召唤boss令牌gdpl
NewServerEvent.tbCallBossGDPL		 = {18,1,1520,2};	--召唤boss令牌gdpl
NewServerEvent.tbBoxGDPL			 = {18,1,1522,1};	--开箱子给的东西
NewServerEvent.nPlayerOpenBoxCountGroupId = 1;	--玩家每天开箱子的个数
NewServerEvent.nPlayerOpenBoxTimeGroupId  = 2;	--玩家每天开箱子的时间
NewServerEvent.nKinBossTemplateId = 9820;	--家族召唤boss的模板id
NewServerEvent.nBoxTemplateId	  = 9819;	--家族召唤boss的宝箱模板id
NewServerEvent.nCallBossWareId	  = 521;	--金币购买的家族召唤boss的wareid
NewServerEvent.nCallBossNeedCoin  = 300;	--购买召唤令需要的金币
NewServerEvent.nCallBossMaxCount  = 4;		--每天可召唤boss的最大次数
NewServerEvent.nBuyBossMaxCount   = 3;		--每天可购买的令牌最大个数
NewServerEvent.nFreeBossMaxCount  = 4;		--每天可免费领取的令牌最大个数
NewServerEvent.szAnnounceKinEvent = "<color=yellow>[HOẠT ĐỘNG MÁY CHỦ MỚI]<color> đã mở, hãy đến <color=green>Bạch Thu Lâm<color> tại Tân Thủ Thôn nhận <color=yellow>Lệnh bài gọi BOSS<color> để khiêu chiến ở các điểm Luyện công!";
NewServerEvent.nAnnounceKinEventDelay = 20 * 60 * Env.GAME_FPS;	--通知延迟
NewServerEvent.nAnnounceKinEventMaxCount = 12;	--通知次数
NewServerEvent.nKinBoxExistDelay = 10 * 60 * Env.GAME_FPS;	--宝箱存在时间
NewServerEvent.nBossExistDelay = 30 * 60 * Env.GAME_FPS;	--boss存在时间

-----------献花活动
NewServerEvent.nCanGiveFlowerLevel = 20;	--大于等于20级的玩家可以送花
NewServerEvent.tbFlowerLeavesGDPL = {18,1,1521,1};	--玫瑰花瓣gdpl
NewServerEvent.tbFlowerGDPL		 = 	{18,1,1521,2};	--玫瑰花gdpl
NewServerEvent.nFireTemplateId = 9821;			--红烛的模板id
NewServerEvent.nCanGiveFlowerMaxCount = 3;		--男性每天可送出的最多的花的数量
NewServerEvent.nCanGetFlowerMaxCount = 5;		--女性每天可以接受的花的数量
NewServerEvent.nUseFlowerTimeGroupId = 3;		--使用（包括赠送和接受）的时间
NewServerEvent.nUseFlowerCountGroupId = 4;		--使用（包括赠送和接受）的次数
NewServerEvent.tbFirePrizeGDPl  = {18,1,1524,1}; --点蜡烛给的东西
NewServerEvent.nFireGiveExpCount = 30;		--蜡烛给多少次经验后消失
NewServerEvent.nFireGiveExpRate	 = 4 * 5;		--蜡烛给的经验的倍率,5分钟的4倍经验
NewServerEvent.nMakeFlowerJinghuo = 60;	--做花消耗的精活
NewServerEvent.nFireGiveExpDelay = 10 * Env.GAME_FPS;	--给经验的间隔
NewServerEvent.nFlowerLeavesCost  = 100;		--买花瓣需要的绑定银两
NewServerEvent.nFireExpRange = 25;	--使用蜡烛队友的范围和给经验的范围

----------------年兽派利------------------------
NewServerEvent.nWelFareAnnounceBeforeTime = 1925;	--提前公告的时间
NewServerEvent.nWelFareAnnounceBeforeDelay = 60 * Env.GAME_FPS;	--提前公告的间隔
NewServerEvent.nWelFareAnnounceBeforeCount = 5;		--提前公告的次数
NewServerEvent.nWelFareBeginTime = 1930;	--派利开始时间
NewServerEvent.nWelFareEndTime =   2030;	--派利结束时间
NewServerEvent.nWelFareDelay   = 60 * 60 * Env.GAME_FPS;	--派利持续时间
NewServerEvent.nDialogNpcTime = 60 * Env.GAME_FPS;	--对话npc时间
NewServerEvent.nWerFareAnnounceDelay = 10 * 60 * Env.GAME_FPS;	--活动开始后每10分钟公告一次
NewServerEvent.nWerFareAnnounceCount = 7;	--活动开始后公告的次数，第7次公告神兽消失
NewServerEvent.nWelFareGiveExpDelay  = 15 * Env.GAME_FPS;	--给经验的时间间隔
NewServerEvent.nWelFareAddBoxDelay   = 60 * Env.GAME_FPS;	--给宝箱的时间间隔
NewServerEvent.nWelFareGiveExpCount  = 240;	    --发放240经验
NewServerEvent.nWelFareGiveBoxCount  = 60;	    --发放60次宝箱
NewServerEvent.nWelFareGetBoxPlayerCount = 10;  --每次可接受的宝箱的玩家个数
NewServerEvent.nWelFareGetBoxMaxCount = 5;	    --每个玩家每天最多可以获得的宝箱个数
NewServerEvent.nWelFareBaseLevel	= 20;		--获得派利的最低等级
NewServerEvent.nWelFareNpcTemplateId = 11122;	--派利的npc模板id
NewServerEvent.nWelFareNpcDialogTemplateId = 11123;	--派利的npc模板id
NewServerEvent.nWelFareBoxGDPL = {18,1,1523,1};	--派利给的宝箱gdpl
NewServerEvent.nWelFareNeedCell = 1;			--需要的背包空间
NewServerEvent.nWelFareGiveExpRate = 4 * 60;	--每次给的经验的倍率,乘60是一个小时的经验
NewServerEvent.nWelFareGetPrizeRange = 25;		--派利的范围,格子
NewServerEvent.nWelFareGetBoxTimeGroupId  = 5;	--上次获取宝箱的时间任务变量id
NewServerEvent.nWelFareGetBoxCountGroupId = 6;	--获取宝箱个数的任务变量id
NewServerEvent.szAnnounceBefore 	= "Tiểu Long Nữ sắp xuất hiện tại <color=green>Lâm An, Đại Lý và Tương Dương<color>, hãy chuẩn bị tinh thần chào đón!";
NewServerEvent.szAnnounceBegin 		= "Tiểu Long Nữ đã xuất hiện tại <color=green>Lâm An, Đại Lý và Tương Dương<color>, hãy theo chân <color=yellow>Tiểu Long Nữ<color> để nhận nhiều phần thưởng!";
NewServerEvent.szAnnounceEnd 		= "Tiểu Long Nữ đã rời Kinh thành, hãy đợi vào những đợt sau!";
NewServerEvent.nWelSkillId = 1564;	--发箱子时候放的特效

NewServerEvent.TASK_GETITEM_DATE		= 7;		--获得站立奖励的日期
NewServerEvent.TASK_GETITEM			= 8;		--获得站立奖励的个数
NewServerEvent.nMaxGetItemDay		= 10;		--每天最多获取10个

NewServerEvent.nMaxRate = 10000;

NewServerEvent.tbAwardList = {
	[1723] = {"bindcoin", 1000, 0},
	[2739] = {"bindcoin", 1500, 1723},
	[3295] = {"bindcoin", 2000, 2739},
	[3333] = {"bindcoin", 4000, 3295},
	[5056] = {"bindmoney", 100000, 3333},
	[6073] = {"bindmoney", 150000, 5056},
	[6629] = {"bindmoney", 200000, 6073},
	[6667] = {"bindmoney", 400000, 6629},
	[8167] = {"Exp", 300, 6667},
	[9167] = {"Exp", 450, 8167},
	[10000] = {"Exp", 600, 9167},
	}


--加载npc路线
local function LoadRoad()
	if not NewServerEvent.tbWelFareAiPosInfo then
		NewServerEvent.tbWelFareAiPosInfo = {};
	else
		return 0;
	end
	local szFile = "\\setting\\event\\newserverevent\\road.txt";
	local tbFile = Lib:LoadTabFile(szFile);
	if not tbFile then
		print("New Server Event","Load Npc Ai Road Error",szFile);
		return 0;
	end
	for _,tbInfo in ipairs(tbFile) do
		local nMapId = tonumber(tbInfo.MapId);
		if not NewServerEvent.tbWelFareAiPosInfo[nMapId] then
			NewServerEvent.tbWelFareAiPosInfo[nMapId] = {};
		end
		local tbTemp = {tonumber(tbInfo.ROADX),tonumber(tbInfo.ROADY)};
		table.insert(NewServerEvent.tbWelFareAiPosInfo[nMapId],tbTemp);
	end
end

if MODULE_GAMESERVER then
	LoadRoad();
end
