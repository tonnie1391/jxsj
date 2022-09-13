-- 文件名　：girl_vote_def.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-06-05 14:14:15
-- 描  述  ：

SpecialEvent.Girl_Vote = SpecialEvent.Girl_Vote or {};
local tbGirl = SpecialEvent.Girl_Vote;

tbGirl.TSK_GROUP 				= 2189;
tbGirl.TSKSTR_FANS_NAME 		= {1, 250};	--存储美女名和票数,最多50个美女，共250个任务变量(变量不能更换,用了偏移处理)
tbGirl.TSK_FANS_GATEWAYID 		= {260, 510};	--存储决赛投票的玩家区服(变量不能更换,用了偏移处理)
tbGirl.TSK_Vote_Girl 				= 256;	--记录美女报名后的标志，预防出问题后可以查询到哪些美女报名了；
tbGirl.TSK_Award_State1 			= 257;	--领奖
tbGirl.TSK_Award_StateEx1			= 258;	--粉丝领奖
tbGirl.TSK_FANS_CLEAR	 		= 259;	--第二轮记录任务变量清0标志;
tbGirl.TSK_Award_State2	 		= 511; 	--决赛领奖
tbGirl.TSK_Award_StateEx2			= 512;	--决赛粉丝领奖
tbGirl.TSK_Award_Buff	 			= 513; 	--技能buff任务变量（记录时间）
tbGirl.TSK_Award_Buff_Level			= 514; 	--技能buff任务变量（记录等级）

tbGirl.TSK_WorldMsg_Num			= 515; 	--发世界公告的次数
tbGirl.TSK_Award_Title_Day			= 516; 	--投票期间每日领取title

tbGirl.TSK_Renzheng_Buff			= 517; 	--美女认证技能buff任务变量（记录时间）

tbGirl.TSK_Award_Buff_2	 		= 518; 	--技能buff任务变量（记录时间）
tbGirl.TSK_Award_Buff_Level_2		= 519; 	--技能buff任务变量（记录等级）

tbGirl.DEF_TASK_OFFSET 	 		= 259; 	--粉丝存储美女和区服变量偏移值
tbGirl.DEF_TASK_SAVE_FANS		= 10; 	--多少个任务变量记录一个投票玩家和票数(影响TSKSTR_FANS_NAME存储的美女数量)

tbGirl.ITEM_MEIGUI				= {18,1,373,1}; --玫瑰
tbGirl.ITEM_MEIGUI_KING			= {18,1,373,2}; --玫瑰
tbGirl.ITEM_MEIGUI_REBACK 		= {18,1,374,1}; --红颜的回赠
tbGirl.ITEM_MEIGUI_REBACK_Old 	= {18,1,374,2}; --红颜的回赠
tbGirl.DEF_AWARD_ALL_RANK 		= 20; 	--前20名
tbGirl.DEF_AWARD_PASS_RANK 		= 10; 	--前10名入围
tbGirl.DEF_AWARD_TICKETS 		= 499; 	--499票

tbGirl.DEF_FINISH_MATCH_TITLE 	= {6,95,2,6};		--入围第二轮的角色

tbGirl.DEF_SKILL_LASTTIME 		= 24*3600;	--光环技能持续时间,如果光环技能异常消失,根据这个时间自动补给

tbGirl.DEF_AWARD_LIST = {
	--初赛前20名里，不是入围前10名的玩家奖励
	[1] = {
		skill= {{1826,2,2,18 * 365 * tbGirl.DEF_SKILL_LASTTIME, 1,0,1}, 1},
		title= {6,95,4,0},
		mask = {1,13,27, 1, 24*30*60},
		freebag=1,	--背包空间
	},
	--初赛前20名里，入围前10名奖励
	[2] = {
		skill= {{1827, 3,2,18 * 365 * tbGirl.DEF_SKILL_LASTTIME, 1,0,1}, 1},
		title= {6,95,3,0},
		item = {18,1,1,10, nil, 1},
		mask = {1,13,26,1, 24*365*60},
		freebag=2,	--背包空间
	},	
	--初赛前20名或达到499票的美女追随者奖励
	[3] = {
		skill= {{2526,1,2,18 * 30 * tbGirl.DEF_SKILL_LASTTIME, 1,0,1}, 1},
		title= {6,96,1,10},
		freebag=0,	--背包空间
	},
	--决赛全区全服前10名奖励
	[4] = {
		skill= {{1828,4,2,18 * 365 * tbGirl.DEF_SKILL_LASTTIME, 1,0,1}, 1},
		title= {6,95,5,9},
		item = {18,1,1,10, nil, 10},
		output = {{1,26,37,1,365*24*60},{1,25,37,1,365*24*60}},
		freebag=12,	--背包空间
	},
	--决赛全区全服第一名奖励
	[5] = {
		equip = {18,1,1663,3, {bForceBind=1}, 1},
		title = {6,95,6,0},
		item = {18,1,1,10, nil, 10},
		output = {{1,26,37,1,365*24*60},{1,25,37,1,365*24*60}},
		freebag=13,	--背包空间
	},	
	--决赛全区全服前10名粉丝奖励
	[6] = {
		skill= {{2526,2,2,18 * 90 * tbGirl.DEF_SKILL_LASTTIME, 1,0,1}, 1},
		title= {6,97,1,10},
		freebag=0,	--背包空间
	},
};

tbGirl.STATE	=	
{
	20120228,	--1.开始报名
	20120305,	--2.开始投票，产出玫瑰
	20120311,		--3.结束报名
	20120316,	--4.结束投票
	20120319,	--5.第二轮投票
	20120330,	--6.第二轮结束，结束产出玫瑰
	20120406,	--7.查询结束
	20120417,	--8.全部完毕
};

tbGirl.STATE_AWARD	=
{
	20120406,	--1.初赛领奖开始时间
	20120410,	--2.初赛领奖结束时间
	20120406,	--3.决赛领奖开始时间
	20120417,	--4.决赛领奖结束时间
	20120420,	--5.(清除初赛,决赛数据)
};

--合区表,区服Id索引
tbGirl.GATEWAY_TRANS = 
{
	--原区服 = 合入服
	--gate0425 = {"gate0423"},
}

tbGirl.nSkillVote = 1829;		--组队投票一次超过9朵特效技能
tbGirl.nGirlLogoTime	= 365*24*3600	--美女认证时间

tbGirl.nMinWorldMsg = 99;	--获得发送世界公告最低玫瑰数

tbGirl.nDayTitle = 99;	--获得每日的称号，最低玫瑰数

--送别人的对话
tbGirl.tbWorldMsg = {
	"快带着你的玫瑰去投她一票吧。",
	"剑侠世界武林第一美女宝座花落谁家还看各位侠士。",
	"武林第一美女争夺激烈，快去看看。",
	"谁才是最美的，答案尽在各位侠士手中。",
	"武林第一美女谁与争锋。",
	};


--------------------------------------------------------------
--美女认证-daily

tbGirl.TSK_Mail				= 521; 	--邮件发送情况
tbGirl.TSK_AttendTime			= 522; 	--参加时间
tbGirl.TSK_LogoIndex			= 523; 	--logo类型
tbGirl.TSK_nLogoTime			= 524; 	--logo时间
tbGirl.TSK_GetFreeItem			= 525; 	--是否获取过道具

tbGirl.tbInfoLogo = {{1, 180*24*3600, {18,1,1708,1}, "v字标志"}};	--图标类型，天数，需求的报名道具

tbGirl.nOpenTime				= 16;		--开服16天开启
tbGirl.nEndTime				= 29		--开服29天结束


