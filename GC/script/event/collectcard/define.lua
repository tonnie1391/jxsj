
if not SpecialEvent.CollectCard then
	SpecialEvent.CollectCard = {};
end
local CollectCard = SpecialEvent.CollectCard;
CollectCard.TIME_STATE	=
{
	20090921000000,	--卡片收集开启
	20091011000000,	--卡片收集结束，卡册兑换奖励开始,
	20091018000000,	--卡册兑换奖励结束，火炬评选开始,
--	20080831220000,	--火炬评选结束,领取火炬奖励开始
--	20080914240000,	--领取火炬奖励结束
}

CollectCard.CARD_BAG = {18,1,461,1}; --卡册
CollectCard.ITEM_CARD_ORG = {18,1,402,1}; --盛夏活动卡（未鉴定）
CollectCard.TASK_GROUP_ID = 2069;

CollectCard.TASK_COUNT_ID	= 1;	--民族大团圆卡（未鉴定）每天使用数量
CollectCard.TASK_DATE_ID	= 2;	--民族大团圆卡（未鉴定）天
CollectCard.TASK_COLLECT_COUNT	= 3;	--民族大团圆卡（未鉴定）已开数量
CollectCard.TASK_COLLECT_FINISH	= 4;	--收集满56张标志
CollectCard.TASK_CARD_BAG_AWARD_FINISH = 70;				--卡册换取奖励，标志安全起见


CollectCard.AWARD_WEIWANG 	   = {{30,1}};	--威望对应奖励活动卡{达到威望，活动卡个数}
CollectCard.CARD_DATA_LIMIT_MAX = 8;--民族大团圆卡（未鉴定）每天最大使用数量
CollectCard.CARD_LIMIT_MAX = 100;	--民族大团圆卡（未鉴定）最大使用数量
--CollectCard.ITEM_GOLDTOKEN = {18,1,179,2};	--黄金令牌
--CollectCard.ITEM_WHITETOKEN = {18,1,179,1};	--白银令牌
--CollectCard.ITEM_GOLDHUOJU = {18,1,182,4};	--黄金火炬

CollectCard.AWARD_CARD_BASEEXP = 60;		--普通奖励
CollectCard.AWARD_CARD_BINDMONEY = 5000;	--普通奖励
CollectCard.AWARD_CARD_COIN = 50;			--普通奖励

CollectCard.AWARD_LUCKCARD_BASEEXP = 60;		--幸运奖励
CollectCard.AWARD_LUCKCARD_BINDMONEY = 50000;	--幸运奖励
CollectCard.AWARD_LUCKCARD_COIN = 500;			--幸运奖励

CollectCard.FILE_BAOXIANG = "\\setting\\event\\collectcard\\baoxiang.txt"

CollectCard.TASK_CARD_ID =
{
	--物品Id = {变量，名字};
	[403] = {6 ,"蒙古族    "},
	[404] = {7 ,"回族      "},
	[405] = {8 ,"藏族      "},
	[406] = {9 ,"维吾尔族  "},
	[407] = {10,"苗族      "},
	[408] = {11,"彝族      "},
	[409] = {12,"壮族      "},
	[410] = {13,"布依族    "},
	[411] = {14,"朝鲜族    "},
	[412] = {15,"满族      "},
	[413] = {16,"侗族      "},
	[414] = {17,"瑶族      "},
	[415] = {18,"白族      "},
	[416] = {19,"土家族    "},
	[417] = {20,"哈尼族    "},
	[418] = {21,"哈萨克族  "},
	[419] = {22,"傣族      "},
	[420] = {23,"黎族      "},
	[421] = {24,"傈僳族    "},
	[422] = {25,"佤族      "},
	[423] = {26,"畲族      "},
	[424] = {27,"高山族    "},
	[425] = {28,"拉祜族    "},
	[426] = {29,"水族      "},
	[427] = {30,"东乡族    "},
	[428] = {31,"纳西族    "},
	[429] = {32,"景颇族    "},
	[430] = {33,"柯尔克孜族"},
	[431] = {34,"土族      "},
	[432] = {35,"达斡尔族  "},
	[433] = {36,"仫佬族    "},
	[434] = {37,"羌族      "},
	[435] = {38,"布朗族    "},
	[436] = {39,"撒拉族    "},
	[437] = {40,"毛南族    "},
	[438] = {41,"仡佬族    "},
	[439] = {42,"锡伯族    "},
	[440] = {43,"阿昌族    "},
	[441] = {44,"普米族    "},
	[442] = {45,"塔吉克族  "},
	[443] = {46,"怒族      "},
	[444] = {47,"乌孜别克族"},
	[445] = {48,"俄罗斯族  "},
	[446] = {49,"鄂温克族  "},
	[447] = {50,"德昂族    "},
	[448] = {51,"保安族    "},
	[449] = {52,"裕固族    "},
	[450] = {53,"京族      "},
	[451] = {54,"塔塔尔族  "},
	[452] = {55,"独龙族    "},
	[453] = {56,"鄂伦春族  "},
	[454] = {57,"赫哲族    "},
	[455] = {58,"门巴族    "},
	[456] = {59,"珞巴族    "},
	[457] = {60,"基诺族    "},
	[458] = {61,"汉族      "},
}
--  [459] = "千里共婵娟"

CollectCard.CARD_START_ID = 403;	--体育卡开始ID
CollectCard.CARD_END_ID	  = 458;	--体育卡结束ID

function CollectCard:__debug_clear_my_card_record()
	for _, tbData in pairs(self.TASK_CARD_ID) do
		local nTaskId = tbData[1];
		me.SetTask(self.TASK_GROUP_ID, nTaskId, 0);
	end
	
	me.SetTask(self.TASK_GROUP_ID, self.TASK_COUNT_ID, 0 );
	me.SetTask(self.TASK_GROUP_ID, CollectCard.TASK_DATE_ID, 0);
	me.SetTask(self.TASK_GROUP_ID, CollectCard.TASK_COLLECT_COUNT, 0);
	me.SetTask(self.TASK_GROUP_ID, CollectCard.TASK_COLLECT_FINISH, 0);
	me.Msg("清除完成")
end

function CollectCard:__debug_pritnt_luckycard()
	local nLuckyCardId = KGblTask.SCGetDbTaskInt(DBTASD_EVENT_COLLECTCARD_RANDOM);
	if nLuckyCardId == 0 then
		me.Msg("无幸运卡");
	else
		if self.TASK_CARD_ID[nLuckyCardId] then
			me.Msg(self.TASK_CARD_ID[nLuckyCardId][2]);
		else
			me.Msg("有bug: ", nLuckyCardId);
		end
	end
end


--  [奖励等级] --> {[CARD_BAG_AWARD表索引] --> 对应的奖品所需的卡片数量, ...}
-- 
CollectCard.CARD_BAG_AWARD_STEP = 
{
	--  [1] [2] [3] [4] [5] [6] [7]
	[1]={28, 26, 23, 20, 16, 12, 4},	--收集总数少于40张奖励表
	[2]={28, 26, 23, 0, 0, 0, 0},		--收集总数40-49张奖励表
	[3]={28, 26, 0, 0, 0, 0, 0},		--收集总数50张奖励表
}

CollectCard.CARD_BAG_AWARD =
{
	[1] = {18,1,178,4}, --盛夏活动黄金宝箱
	[2] = {18,1,178,3}, --盛夏活动白银宝箱
	[3] = {18,1,178,2}, --盛夏活动青铜宝箱
	[4] = {18,1,178,1}, --盛夏活动黑铁宝箱
	[5] = {18,1,114,6}, --绑定的6级玄晶
	[6] = {18,1,114,5}, --绑定的5级玄晶
	[7] = {18,1,114,4}, --绑定的4级玄晶
}

--CollectCard.HUOJU_AWARD_STEP = {10000, 3500, 1000, 300, 80, 20}
--CollectCard.HUOJU_AWARD =
--{
--	[1] = {tbItem={18,1,179,2}, nBind=1, nTimeLimit = 43200}, --黄金令牌
--	[2] = {tbItem={18,1,179,1}, nBind=1, nTimeLimit = 43200}, --白银令牌
--	[3] = {tbItem={18,1,1,10}, nBind=1}, --10级玄晶
--	[4] = {tbItem={18,1,1,9}, nBind=1}, --9级玄晶
--	[5] = {tbItem={18,1,1,8}, nBind=1}, --8级玄晶
--	[6] = {tbItem={18,1,1,7}, nBind=1}, --7级玄晶
--}

function CollectCard:WriteLog(szLog, nPlayerId)
	if nPlayerId then
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
		if (pPlayer) then
			Dbg:WriteLog("SpecialEvent.CollectCard", "盛夏活动卡收集", pPlayer.szAccount, pPlayer.szName, szLog);
			return 1;
		end
	end
	Dbg:WriteLog("SpecialEvent.CollectCard", "盛夏活动卡收集", szLog);

end

local __get_boots_1 = function(pPlayer)
	pPlayer.AddRepute(10,1,1500);
	return {};
end

local __get_boots_2 = function(pPlayer)
	pPlayer.AddRepute(10,1,500);
	return {};
end

CollectCard.tbFinalAwardNationalDay09 = 
{-- 名次   gdpl       数量
	{1,   {repute={10,1,1500}},0},	--声望
	{10,  {repute={10,1,500}},0},	--声望
	{100, {item={18,1,462,1}},5},
	{500, {item={18,1,462,1}},3},
	{1000,{item={18,1,355,1}},2},
	{2000,{item={18,1,355,1}},1},
	{3000,{item={18,1,114,8}},1},
};

-- 09年国庆卡片收集活动结束后奖励
-- 有奖return {g,d,p,l}, nNum 
-- 没奖return nil
function CollectCard:GetFinalAwardNationalDay09(nRank, nCardNum, pPlayer)
	if (nRank <= 0 or nRank > 3000) then
		if nCardNum >= 60 then
			return 2, {18,1,114,8}, 1;
		else
			return 0;
		end
	end
	
	for _, tbData in ipairs(self.tbFinalAwardNationalDay09) do
		if nRank <= tbData[1] then
			if tbData[2].repute then
				return 1, tbData[2].repute, tbData[3];
			end
			if tbData[2].item then
				return 2, tbData[2].item, tbData[3];
			end
		end
	end
	return 0;
end

