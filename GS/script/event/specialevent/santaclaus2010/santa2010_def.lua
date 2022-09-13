-- 文件名　：define.lua
-- 创建者　：huangxiaoming
-- 创建时间：2010-1-25 10:10:10
-- 描  述  ：
SpecialEvent.Santa2010 = SpecialEvent.Santa2010 or {};
local tbSanta = SpecialEvent.Santa2010 or {};

tbSanta.SANTA_CLAUS_ID		= 7250;			-- 圣诞老人id
tbSanta.SANTA_BOX_ID		= {18,1,1108,1};-- 圣诞宝箱ID
tbSanta.SKILL_LIST			= {1563, 1567};	-- 圣诞老人技能
tbSanta.TASK_GROUP_ID		= 2027;			-- 已拿的箱子个数任务组id
tbSanta.TASK_BOX_COUNT		= 177;			-- 已拿的箱子个数任务id

tbSanta.MAX_TAKE_BOX_COUNT	= 100;			-- 本次活动最多可获取的箱子个数
tbSanta.LEVEL_LIMIT			= 60;			-- 参加活动的等级限制
tbSanta.SPEED				= 10;			-- 圣诞老人跑速
tbSanta.PREPARE_TIME		= 5 * 60 * 18;	-- 提前公告时间
tbSanta.DURATION_TIME		= 10 * 60 * 18;	-- 圣诞老人持续时间
tbSanta.TOTAL_TIME			= tbSanta.PREPARE_TIME + tbSanta.DURATION_TIME	-- 圣诞老人从公告到消失的总时间
tbSanta.RANGE_EXP			= 45;			-- 给予经验的范围
tbSanta.RANGE_BOX			= 45;			-- 给予圣诞宝箱的范围
tbSanta.BASE_EXP_MULTIPLE	= 1;			-- 每次给予基础经验的倍数
tbSanta.INTERVAL_EXP		= 5 * 18;		-- 给予经验的间隔
tbSanta.INTERVAL_BOX		= 20 * 18;		-- 宝箱刷新间隔
tbSanta.INTERVAL_CHAT		= 5 * 18;		-- npc说话的间隔和释放技能的间隔
tbSanta.TIMES_REFRESH_BOX 	= math.floor(tbSanta.DURATION_TIME / tbSanta.INTERVAL_BOX);		-- 最多刷箱子次数
tbSanta.TIMES_EXP			= math.floor(tbSanta.DURATION_TIME / tbSanta.INTERVAL_EXP);		-- 最多发经验次数
tbSanta.TIMES_CHAT			= math.floor(tbSanta.DURATION_TIME / tbSanta.INTERVAL_CHAT);	-- 最多讲话和释放技能的次数



tbSanta.OPEN_DAY	= 20101221;	-- 圣诞活动开启时间
tbSanta.CLOSE_DAY 	= 20110102;	-- 圣诞活动结束时间

tbSanta.MAX_BOX_PRODUCT_NUM	= 5;			-- 一次最多箱子产出总数

tbSanta.SANTA_CLAUS_BORN_POS =
{
	[1] = {28, 1497, 3277},--大理
	[2] = {29, 1629, 3951},--临安
};
tbSanta.TB_ROUTE = 
{
	"\\setting\\event\\specialevent\\santaclaus2010\\dali_route.txt", 
	"\\setting\\event\\specialevent\\santaclaus2010\\linan_route.txt",
};


tbSanta.MSG_INFO =
{
	[1] = "本次圣诞老人的礼物已经全部送出，请大家期待13:45圣诞老人再次降临，祝大家节日好心情！",
	[2] = "本次圣诞老人的礼物已经全部送出，请大家期待18:45圣诞老人再次降临，祝大家节日好心情！",
	[3] = "本次圣诞老人的礼物已经全部送出，请大家期待19:45圣诞老人再次降临，祝大家节日好心情！",
	[4] = "本次圣诞老人的礼物已经全部送出，请大家期待20:45圣诞老人再次降临，祝大家节日好心情！",
	[5] = "今日圣诞老人的礼物已经全部送出，请大家期待明日圣诞老人再次降临，祝大家节日好心情！",
	[6] = "本次圣诞老人的礼物已经全部送出，请大家下次再来！"
};

tbSanta.SANTACLAUS_CHAT = 
{
	[1] = "大家只要靠近我，就会持续获得经验~",
	[2] = "我的包里有数不清的宝物，靠近我才有几率得到",
	[3] = "祝大家节日愉快，游戏开心！",
	[4] = "麻烦将是暂时的，朋友总是永恒的！",
	[5] = "许个美丽的心愿祝你爱情甜甜！",
	[6] = "许个美好的心愿祝你快乐连连！",
	[7] = "许个美妙的心愿祝你事业圆圆！",
};