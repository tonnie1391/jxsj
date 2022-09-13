--
-- FileName: wuyimeijiujie_def.lua
-- Author: hanruofei
-- Time: 2011/4/21 15:25
-- Comment: 五一美酒节常量定义
--

Require("\\script\\event\\jieri\\20110501_meijiujie\\wuyimeijiujie_base_def.lua");

SpecialEvent.tbMeijiujie20110501 =  SpecialEvent.tbMeijiujie20110501 or {};
local tbMeijiujie20110501 = SpecialEvent.tbMeijiujie20110501;

------------------------------
-- 活动控制变量
------------------------------
tbMeijiujie20110501.nMinLevel 	= 60;		-- 参加活动的最小等级
tbMeijiujie20110501.nUpperRank 	= 3000; 	-- 财富荣誉排名上限，所有的无效排名都认为是3000
tbMeijiujie20110501.bIsNpcCalled = 0; 		-- 活动相关NPC已经Call出来了

------------------------------
-- 与刷篝火和刷酒坛有关
------------------------------


-- 活动中要刷新篝火的位置
tbMeijiujie20110501.tbGouhuoPositions = {};
local tbData = Lib:LoadTabFile("\\setting\\event\\jieri\\20110501_meijiujie\\gouhuopositions.txt");
if tbData then
	for _, v in ipairs(tbData) do
		table.insert(tbMeijiujie20110501.tbGouhuoPositions, {tonumber(v.nMapId), {tonumber(v.TRAPX), tonumber(v.TRAPY), }});
	end
else
	print("Load 五一美酒节篝火位置文件失败");
end
   

tbMeijiujie20110501.nGouhuoNpcTemplateId	= 9542; 						-- 篝火NPC的模板ID(因为要在篝火周围饮酒)

-- 活动中各地图中刷新酒坛的位置
tbMeijiujie20110501.tbJiutanPositions = {};
local tbData = Lib:LoadTabFile("\\setting\\event\\jieri\\20110501_meijiujie\\jiutanpositions.txt");
if tbData then
	for _, v in ipairs(tbData) do
		local nMapId = tonumber(v.nMapId);
		local tbPos = {tonumber(v.TRAPX), tonumber(v.TRAPY), };
		local tbItem = tbMeijiujie20110501.tbJiutanPositions[nMapId] or {};
		tbMeijiujie20110501.tbJiutanPositions[nMapId] = tbItem;
		table.insert(tbItem, tbPos);
	end
else
	print("Load 五一美酒节酒坛位置文件失败");
end
tbMeijiujie20110501.tbJiutanNpcTemplateIds 			= {9538, 9539, 9540, 9541}; -- 所有酒坛的NPC的模板ID列表


------------------------------
-- 与开心酒杯有关
------------------------------
tbMeijiujie20110501.nMaxUseCountOfKaixinjiubei 	= 3;				-- 一个开心酒杯的最多可以取多少次酒
tbMeijiujie20110501.nGenInfoIndexOfUsedCount 	= 1;				-- 记录酒杯已经使用次数的变量在GenInfo中的索引
tbMeijiujie20110501.tbKaixinjiubeiGDPL 			= {18,1,1281,2};	-- 开心酒杯的GDPL
-- 各种酒
tbMeijiujie20110501.tbWines =
{
	{18, 1, 1281, 3},
	{18, 1, 1281, 4},
	{18, 1, 1281, 5},
	{18, 1, 1281, 6},
	{18, 1, 1281, 7},
	{18, 1, 1281, 8},
	{18, 1, 1281, 9},
	{18, 1, 1281, 10},
	{18, 1, 1281, 11},
};
------------------------------
-- 与取酒有关
------------------------------
tbMeijiujie20110501.nMaxCount 				   				= 15; 				-- 活动期间最多可以取酒多少次
tbMeijiujie20110501.nMaxUseCountPerDay		   				= 3; 				-- 每天最多可以领酒多少次
tbMeijiujie20110501.nDurationWhileGettingWine 				= 2 * Env.GAME_FPS;	-- 取酒时的读条时间(单位：帧)
tbMeijiujie20110501.szMsgWhileGettingWine 					= "对酒当歌...";		-- 取酒时的读条提示
tbMeijiujie20110501.nFreeCellCountNeededWhileGettingWine 	= 1;	-- 点击酒坛取酒的时候，需要多少背包空间
tbMeijiujie20110501.nExpWhenGetWine							= 30;	-- 取酒成功获得多少经验

------------------------------
-- 与饮酒和召唤舞者有关
------------------------------
tbMeijiujie20110501.tbDancers 				= {[1] = 9536, [0] = 9537,}; 	-- {男舞者模板ID， 女舞者模板ID}
tbMeijiujie20110501.nDurationWhileDrinking = 2 * Env.GAME_FPS;	-- 饮酒时的读条时间(单位：帧)
tbMeijiujie20110501.szMsgWhileDrinking 		= "饮酒中...";					-- 饮酒时的读条提示
tbMeijiujie20110501.szMsgCalledADancer 		= "你仿佛看见一个开心舞者"; 	-- 召唤出一个开心舞者的提示信息
tbMeijiujie20110501.nValidRange				= 100; 				-- 在篝火多少范围内可以饮酒和召唤NPC
tbMeijiujie20110501.nDistanceNoNpc  		= 5; 				-- 舞者周围不能有NPC的范围
tbMeijiujie20110501.nMaxDeltaX 				= 20; 				-- 召唤的舞者与玩家的X最大偏移量
tbMeijiujie20110501.nMaxDeltaY 				= 20; 				-- 召唤的舞者与玩家的Y最大偏移量
tbMeijiujie20110501.nMinDeltaX 				= 2; 				-- 召唤的舞者与玩家的X最小偏移量
tbMeijiujie20110501.nMinDeltaY 				= 2; 				-- 召唤的舞者与玩家的Y最小偏移量
-- 各种酒与其空瓶的GDPL的对应关系
tbMeijiujie20110501.tbJiupingMaps =
{
	["18,1,1281,3"] =  {18,1,1281,12},
	["18,1,1281,4"] =  {18,1,1281,13},
	["18,1,1281,5"] =  {18,1,1281,14},
	["18,1,1281,6"] =  {18,1,1281,15},
	["18,1,1281,7"] =  {18,1,1281,16},
	["18,1,1281,8"] =  {18,1,1281,17},
	["18,1,1281,9"] =  {18,1,1281,18},
	["18,1,1281,10"] = {18,1,1281,19},
	["18,1,1281,11"] = {18,1,1281,20},
};
tbMeijiujie20110501.nEmptyJiupingDisappearTime	= 201105112359;  -- 空的酒瓶的消失时间
tbMeijiujie20110501.tbLaodonglibaoGDPL = {18, 1, 1281, 1};  -- 劳动礼包GDPL

------------------------------
-- 与舞者给玩家周期性加经验有关
------------------------------
tbMeijiujie20110501.nBindMoneyEverytime 	= 660;						-- 每次加多少绑银
tbMeijiujie20110501.nExpCoeEverytime 		= 0.85;						-- 每次加多少经验
tbMeijiujie20110501.tbProAddBindMoney 		= {1, 33}; 					-- 加绑银的几率区间
tbMeijiujie20110501.tbProAddExp 			= {34, 100}; 				-- 加经验的几率区间
tbMeijiujie20110501.nBuffDuration 			= 10;						-- 加经验和绑银的buff的持续时间(单位：秒)
tbMeijiujie20110501.nSkillId 				= 377;						-- 玩家在舞者周围并且是在舞者招出来的前3分（加经验和绑银）的时候的buff
tbMeijiujie20110501.nAroundDistance 		= 20;						-- 距离舞者多少范围的队友会增加队伍加成系数
tbMeijiujie20110501.nCycleTime 				= 5 * Env.GAME_FPS; 		-- 加奖励的周期
tbMeijiujie20110501.nAwardDuration 			= 3 * 60 * Env.GAME_FPS;	-- 加奖励持续多长时间
tbMeijiujie20110501.nDistanceNoAward 		= 20; 						-- 超过舞者多少距离就没有经验
tbMeijiujie20110501.szMsgFarwayFromDancer 	= "您距离您的舞者过远，将无法得到奖励！";		-- 远离舞者的提示

------------------------------
-- 与舞蹈结束的奖励有关
------------------------------
tbMeijiujie20110501.szMsgNotifyRandomBox 	= "这是劳动者的节日，快快去卖火柴的小女孩处领取你的节日礼物吧。"; -- 舞蹈结束，提示领箱子
tbMeijiujie20110501.nCannotAwardDuration 	= 3 * 60; -- 召唤了舞者后多长时间才能领取礼包

------------------------------
-- 获得空酒瓶
------------------------------
tbMeijiujie20110501.szMsgGetEmptyGlassA = "你获得了一个%s, 你已经获得过这种酒瓶。";
tbMeijiujie20110501.szMsgGetEmptyGlassB = "并获得了一个空的%s。";

------------------------------
-- 兑换奖励
------------------------------
tbMeijiujie20110501.szMsgDuijiang = "你获得了%s瓶%s。";

------------------------------
-- 与奖励有关
------------------------------
--{奖励级别，需要的酒瓶数，判定奖励级别的数值, 奖励}
tbMeijiujie20110501.tbAwards =
{
	{1, 1, 30, {1, {18, 1, 1281, 21}}}, 	
	{2, 2, 60, {2, {18, 1, 1281, 21}}},
	{3, 3, 90, {3, {18, 1, 1281, 21}}},
	{4, 4, 120, {4, {18, 1, 1281, 21}}},
	{5, 5, 150, {5, {18, 1, 1281, 21}}},
	{6, 6, 180, {3, {18, 1, 1281, 22}}},
	{7, 7, 300, {5, {18, 1, 1281, 22}}},
	{8, 8, 600, {1, {18, 1, 1281, 23}}},
	{9, 9, 1200, {2, {18, 1, 1281, 23}}},
};

-- 几率对应的系数
tbMeijiujie20110501.tbMapProToCoe =
{
	{004687, 0.25,},
	{043750, 0.25,},
	{087500, 0.5,},
	{175000, 0.75,},
	{350000, 1,},
	{175000, 1.3,},
	{087500, 1.6,},
	{043750, 2,},
	{021875, 4,},
	{010938, 8,},
};

------------------------------
-- 跟小女孩、酒坛对话时的信息
------------------------------
tbMeijiujie20110501.szMsgOnDialog = [[对酒当歌，人生几何！<color=gold>4月30日-5月4日<color>期间每天在我这买一个开心酒杯，可在城市中心广场任意酒坛上领取瓶酒。<enter>   每天上午<color=gold>10：00-14：00；18：00-23：00<color>在城市的五一篝火附近使用酒瓶可召出开心舞者，获得<color=green>经验绑银<color>以及<color=green>五一劳动者宝箱<color><color=pink>。<enter><color>   <color=yellow>5月4日23点到5月11日23点29分<color>，把<color=pink>空瓶子<color>都交给我，你将获得惊喜的<color=green>五一终极奖励<color>。]];


------------------------------
-- 与任务相关
------------------------------
tbMeijiujie20110501.TASK_GROUP_ID			= 2163; -- 五一美酒节相关人物变量的组
tbMeijiujie20110501.DATE_ID					= 1; -- 记录日期的任务变量的ID
tbMeijiujie20110501.USED_COUNT_ID			= 2; -- 记录每天领酒的次数
tbMeijiujie20110501.HAS_AWARD_ID			= 3; -- 记录玩家在什么时候召唤了一个舞者，用于判断玩家是否可以再召唤，以及，玩家是否可以领取礼包
tbMeijiujie20110501.AWARD_LEVEL_ID			= 4; -- 玩家奖励级别，一开始就确定了
tbMeijiujie20110501.JIU_START_ID			= 5; -- 获得的酒的类型在tbMeijiujie20110501.tbWines的索引值的第一个存储的地方
tbMeijiujie20110501.JIU_END_ID				= 19; -- 获得的酒的类型在tbMeijiujie20110501.tbWines的索引值的最后一个存储的地方
