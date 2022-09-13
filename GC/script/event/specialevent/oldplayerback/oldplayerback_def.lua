-- 文件名  : oldplayerback_def.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-08-30 16:35:46
-- 描述    :  老玩家回归

SpecialEvent.tbOldPlayerBack = SpecialEvent.tbOldPlayerBack or {};
local tbOldPlayerBack = SpecialEvent.tbOldPlayerBack or {};

tbOldPlayerBack.tbOldPlayerInfo = tbOldPlayerBack.tbOldPlayerInfo or {};	--老玩家回归数据
tbOldPlayerBack.tbOldPlayerInfo[1] = tbOldPlayerBack.tbOldPlayerInfo[1] or {};
tbOldPlayerBack.tbOldPlayerInfo[2] = tbOldPlayerBack.tbOldPlayerInfo[2] or {};
tbOldPlayerBack.tbOldPlayerInfo2 = tbOldPlayerBack.tbOldPlayerInfo2 or {};
tbOldPlayerBack.tbOldPlayerInfo3 = tbOldPlayerBack.tbOldPlayerInfo3 or {};
tbOldPlayerBack.tbOldPlayerBackOct = tbOldPlayerBack.tbOldPlayerBackOct or {};
-- tbOldPlayerInfo[1]    去新服  [szNewAccount] = {gateway，充值额度，szOldAccount，领取情况7位01数字，表示1,30,50,69,79,89,99段领取情况，1为还没有领取，0为领过了}
--tbOldPlayerInfo[2]	     老服玩家回归 	[szAccount] = {充值额度，最后登录时间}

tbOldPlayerBack.tbLevel = {{1,20},{30,10},{50,10},{69,10},{79,20},{89,30}};	--等级段
tbOldPlayerBack.nAwardState = 1111111;		--领取的标志，分别表示上面等级段领取情况
tbOldPlayerBack.nRateBindCoin = 100 * 0.8;		--绑金比例
tbOldPlayerBack.nRateBindMoney = 10000 * 0.2;	--绑银比例
tbOldPlayerBack.nRate2NewPlayer_Coin = 0.5;		--去新服充值绑金参数
tbOldPlayerBack.nRate2NewPlayer_Money = 0.5;		--去新服充值绑银参数
tbOldPlayerBack.nRateOldPlayerBack = 0.25;	--老服玩家充值参数
tbOldPlayerBack.nReBackCoinRate = 0.3;		--绑金直接返还比例
tbOldPlayerBack.nCloseDate	= {20121215,20121115};	--结束时间
tbOldPlayerBack.nRoleCreateDate = 20120801;	--老玩家创建角色必须在这之前
tbOldPlayerBack.nCoinNeed	= 150;		--玩家消耗或者充值最小值必须大于500
tbOldPlayerBack.nKinAwardMaxCount = 10;	--最多可获得多少次家族奖励

tbOldPlayerBack.GTASK_BUFF	= 11;	--buff批次 每次+2,（1作为活动批次，2作为清buff批次）
tbOldPlayerBack.nBatch = 4;		--家族变量批次
tbOldPlayerBack.nActiveBatch	= 3;	--账号激活批次


tbOldPlayerBack.TASK_GID 			= 2138;	--任务组

tbOldPlayerBack.TASK_TASKID_ACTIVATE_OLD_LAST	= 72;	--上次激活老玩家标志
tbOldPlayerBack.TASK_TASKID_ACTIVATE_OLD	= 143;	--激活老玩家标志
tbOldPlayerBack.TASK_TASKID_ACTIVATE_NEW	= 144;	--激活老玩家标志
tbOldPlayerBack.TASK_TASKID_EQUIT_NEW		= 145;	--转新服装备奖励
tbOldPlayerBack.TASK_TASKID_ITEM_NEW		= 146;	--转新服物品奖励
tbOldPlayerBack.TASK_TASKID_ITEM_OLD_TIMES		= 147;	--老玩家绑金，绑银，经验，机会领取
tbOldPlayerBack.TASK_TASKID_ITEM_OLD_TITLE		= 148;	--title领取
tbOldPlayerBack.TASK_TASKID_ITEM_OLD_BAG		= 149;	--包裹领取
tbOldPlayerBack.TASK_TASKID_ITEM_OLD_SIGNET		= 79;	--印鉴领取
tbOldPlayerBack.TASK_TASKID_ITEM_OLD_EQUIT		= 80;	--装备同伴领取
tbOldPlayerBack.TASK_TASKID_ITEM_OLD_ITEM		= 81;		--2折魂石券
tbOldPlayerBack.TASK_TASKID_BANDCOIN_RETURN	= 11;		--绑金返还数量（注：已经长期在用，不能改动的值）
tbOldPlayerBack.TASK_TASKID_EVENT_XOYO		= 150;	--逍遥
tbOldPlayerBack.TASK_TASKID_EVENT_BAIHU		= 151;	--白虎
tbOldPlayerBack.TASK_TASKID_EVENT_WANTED	= 152;	--大盗
tbOldPlayerBack.TASK_TASKID_EVENT_SONGJIN	= 153;	--宋金
tbOldPlayerBack.TASK_TASKID_EVENT_XIAKE		= 154;	--侠客
tbOldPlayerBack.TASK_TASKID_KIN				= 155;	--老玩家家族发放奖励
tbOldPlayerBack.TASK_TASKID_KIN_GETAWARD	= 156;		--获得老玩家家族发放奖励
tbOldPlayerBack.TASK_TASKID_ACTIVATE_TIME	= 157;	--激活时间

tbOldPlayerBack.TASK_TASKID_TELL		= 121;	--上线通知发邮件


tbOldPlayerBack.nCreatDateLimit = 20120912;		--转新服限制建号时间


--额外奖励物品奖励
tbOldPlayerBack.tbAward2Old = {
	[1] = {"特殊称号",1,{6, 55, 1,1}},
	[2] = {"曼陀罗花", 2, {18,1,1782,1}},
	--[2] = {"西域龙魂包", 2, {21,9,11,1}},
--	[2] = {"珍贵翅膀", 2, {1,26,38,1}, 7*24*3600},
	--[3] = {{"金系西域龙魂印鉴", 2, {1, 18, 6, 1}, 5 * 24 * 3600}, {"木系西域龙魂印鉴", 2, {1, 18, 7, 1}, 5 * 24 * 3600}, {"水系西域龙魂印鉴", 2, {1, 18, 8, 1}, 5 * 24 * 3600}, {"火系西域龙魂印鉴", 2, {1, 18, 9, 1}, 5 * 24 * 3600}, {"土系西域龙魂印鉴", 2, {1, 18, 10, 1}, 5 * 24 * 3600}},
	--[4] = {{"10级%4装备套装", 2, {18,1,1209,1}}, {"夏侯小小（四技能）", 2, {18, 1, 666, 1}}, {"萧不实（五技能）", 2, {18, 1, 666, 2}}, {"纤纤（六技能）", 2, {18, 1, 666, 9}}},
	--[5] = {"2折魂石箱（1000个）优惠券6张", 2, {18,1,1696,1,6}, 30 * 24 * 3600, 6},
	}

tbOldPlayerBack.tbItem2NewExBag = {21, 8, 13, 1};


--新服装备奖励
tbOldPlayerBack.tbEquit2New = {
	};

tbOldPlayerBack.tbItemReturn = {18,1,1211,1};		--查看绑金返还情况和任务完成情况