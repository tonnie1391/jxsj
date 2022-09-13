-- 文件名　：visitornpc.lua
-- 创建者　：furuilei
-- 创建时间：2009-12-10 11:52:28
-- 功能描述：典礼到访npc

local tbManager = {};
Marry.VisitorManager = tbManager;

--=============================================================
tbManager.NPC_EXIST_TIME = 18 * 10;

tbManager.OP_MSG_CHAT		= 1;	-- 发送对话信息
tbManager.OP_MSG_FILM		= 2;	-- 电影字幕
tbManager.OP_MSG_HEITIAO	= 3;	-- 黑条信息
tbManager.OP_MSG_CHANNEL	= 4;	-- 聊天栏信息
tbManager.OP_MSG_INFOBOARD	= 5;	-- 中央黄色字信息
tbManager.OP_SKILL		= 6;	-- 释放技能

tbManager.TB_PATH_POSFILE = {
	[1] = "\\setting\\marry\\visitornpc_1.txt",
	[2] = "\\setting\\marry\\visitornpc_2.txt",
	[3] = "\\setting\\marry\\visitornpc_3.txt",
	[4] = "\\setting\\marry\\visitornpc_4.txt",
	};
	
tbManager.TB_NPCID = {
	[1] = {6589, 6590, 6591, 6592, 6593, 6594},
	[2] = {6583, 6584, 6585, 6586, 6587, 6588},
	[3] = {6569, 6570, 6567, 6575, 6579, 6580, 6581, 6582},
	[4] = {6572, 6568, 6571, 6574, 6573, 6576, 6577, 6578},
	};

tbManager.TB_OPT = {
	[1] = {
		[6589] = {
		[1] = {nOpt = tbManager.OP_MSG_HEITIAO, tbInfo = {szMsg = "武器锻造大师甜酒叔到了！", nStayTime = 5}},
		[2] = {nOpt = tbManager.OP_MSG_FILM, tbInfo = {szMsg = "<npc=6589>：“美丽的女侠好比水果酒。”<end><npc=6589>：“大侠就是那酒杯。”<end><npc=6589>：“恭喜你！酒与杯从此形影不离。”<end><npc=6589>：“祝福你！两人永不分离！”<end><npc=6589>：“美酒沁人心脾，却不及你们二人情意重！”<end><npc=6589>：“甜酒叔希望你们二人好好过日子。”<end><npc=6589>：“往后常回来看看！”<end><npc=6589>：“义军的这些叔父姐姐们想着你们！”<end>", nStayTime = 1}},
		[3] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "美丽的女侠好比水果酒。", nStayTime = 3}},
		[4] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "大侠就是那酒杯。", nStayTime = 3}},
		[5] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "恭喜你！酒与杯从此形影不离。", nStayTime = 3}},
		[6] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "祝福你！两人永不分离！", nStayTime = 3}},
		[7] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "美酒沁人心脾，却不及你们二人情意重！", nStayTime = 3}},
		[8] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "甜酒叔希望你们二人好好过日子。", nStayTime = 3}},
		[9] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "往后常回来看看！", nStayTime = 3}},
		[10] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "义军的这些叔父姐姐们想着你们！", nStayTime = 1}},
		[11] = {nOpt = tbManager.OP_SKILL, tbInfo = {nSkillId = 1561, tbSkillPos = {1762, 3150} , nStayTime = 3}},
		[12] = {nOpt = tbManager.OP_MSG_INFOBOARD, tbInfo = {szMsg = "义军<color=red>甜酒叔<color>祝福二位侠侣生活幸福，形影不离！", nStayTime = 1}},
		[13] = {nOpt = tbManager.OP_MSG_CHANNEL, tbInfo = {szMsg = "义军<color=gold>甜酒叔<color>为典礼送上祝福，祝愿二位侠侣生活幸福，形影不离！", nStayTime = 8}},
		},
		[6590] = {
		[1] = {nOpt = tbManager.OP_MSG_HEITIAO, tbInfo = {szMsg = "五毒教彩蝶仙子蝶飘飘到了！", nStayTime = 5}},
		[2] = {nOpt = tbManager.OP_MSG_FILM, tbInfo = {szMsg = "<npc=6590>：“你是扬起千千遍遍的风。”<end><npc=6590>：“她是雪地里闪闪的白光。”<end><npc=6590>：“你是拂照在田野里的太阳。”<end><npc=6590>：“她是夜空里的星星！”<end><npc=6590>：“我日夜在明暗黑白之中，在几个势力中斡旋！”<end><npc=6590>：“已是身心俱疲。”<end><npc=6590>：“今日得知二位好事，定要前来祝贺！”<end><npc=6590>：“祝二位侠侣，好事连连，好梦圆圆！”<end>", nStayTime = 1}},
		[3] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "你是扬起千千遍遍的风。", nStayTime = 3}},
		[4] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "她是雪地里闪闪的白光。", nStayTime = 3}},
		[5] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "你是拂照在田野里的太阳。", nStayTime = 3}},
		[6] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "她是夜空里的星星！", nStayTime = 3}},
		[7] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "我日夜在明暗黑白之中，在几个势力中斡旋！", nStayTime = 3}},
		[8] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "已是身心俱疲。", nStayTime = 3}},
		[9] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "今日得知二位好事，定要前来祝贺！", nStayTime = 3}},
		[10] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "祝二位侠侣，好事连连，好梦圆圆！", nStayTime = 1}},
		[11] = {nOpt = tbManager.OP_SKILL, tbInfo = {nSkillId = 1561, tbSkillPos = {1762, 3150} , nStayTime = 3}},
		[12] = {nOpt = tbManager.OP_MSG_INFOBOARD, tbInfo = {szMsg = "彩蝶仙子<color=red>蝶飘飘<color>祝福二位侠侣好事连连，好梦圆圆！", nStayTime = 1}},
		[13] = {nOpt = tbManager.OP_MSG_CHANNEL, tbInfo = {szMsg = "彩蝶仙子<color=gold>蝶飘飘<color>为典礼送上祝福，祝愿二位侠侣好事连连，好梦圆圆！", nStayTime = 8}},
		},
		[6591] = {
		[1] = {nOpt = tbManager.OP_MSG_HEITIAO, tbInfo = {szMsg = "逍遥谷秦仲来了！", nStayTime = 5}},
		[2] = {nOpt = tbManager.OP_MSG_FILM, tbInfo = {szMsg = "<npc=6591>：“没有幻想、没有期望，就如同鸟儿被捆住了翅膀。”<end><npc=6591>：“我秦仲希望二位。”<end><npc=6591>：“互相扶持，飞出一片更高，更广的天空。”<end><npc=6591>：“祝福二位侠侣。”<end><npc=6591>：“和和美美，欢欢喜喜。”<end>", nStayTime = 1}},
		[3] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "没有幻想、没有期望，就如同鸟儿被捆住了翅膀。", nStayTime = 3}},
		[4] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "我秦仲希望二位。", nStayTime = 3}},
		[5] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "互相扶持，飞出一片更高，更广的天空。", nStayTime = 3}},
		[6] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "祝福二位侠侣。", nStayTime = 3}},
		[7] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "和和美美，欢欢喜喜。", nStayTime = 1}},
		[8] = {nOpt = tbManager.OP_SKILL, tbInfo = {nSkillId = 1561, tbSkillPos = {1762, 3150} , nStayTime = 3}},
		[9] = {nOpt = tbManager.OP_MSG_INFOBOARD, tbInfo = {szMsg = "逍遥谷<color=red>秦仲<color>祝福二位侠侣和和美美，欢欢喜喜！", nStayTime = 1}},
		[10] = {nOpt = tbManager.OP_MSG_CHANNEL, tbInfo = {szMsg = "逍遥谷<color=gold>秦仲<color>为典礼送上祝福，祝愿二位侠侣和和美美，欢欢喜喜！", nStayTime = 8}},
		},
		[6592] = {
		[1] = {nOpt = tbManager.OP_MSG_HEITIAO, tbInfo = {szMsg = "殷方，这个名字好熟悉，他也来了吗？", nStayTime = 5}},
		[2] = {nOpt = tbManager.OP_MSG_FILM, tbInfo = {szMsg = "<npc=6592>：“在对的时间，遇见对的人，是一生幸福；”<end><npc=6592>：“在对的时间，遇见错的人，是一场心伤”<end><npc=6592>：“在错的时间，遇见错的人，是一段荒唐；”<end><npc=6592>：“在错的时间，遇见对的人，是一阵叹息。”<end><npc=6592>：“你们的相遇，相知让我欣慰。”<end><npc=6592>：“我深深的为你祝福，青妹。”<end>", nStayTime = 1}},
		[3] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "在对的时间，遇见对的人，是一生幸福；", nStayTime = 3}},
		[4] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "在对的时间，遇见错的人，是一场心伤", nStayTime = 3}},
		[5] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "在错的时间，遇见错的人，是一段荒唐；", nStayTime = 3}},
		[6] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "在错的时间，遇见对的人，是一阵叹息。", nStayTime = 3}},
		[7] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "你们的相遇，相知让我欣慰。", nStayTime = 1}},
		[8] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "我深深的为你祝福，青妹。", nStayTime = 1}},
		[9] = {nOpt = tbManager.OP_SKILL, tbInfo = {nSkillId = 1561, tbSkillPos = {1762, 3150} , nStayTime = 3}},
		[10] = {nOpt = tbManager.OP_MSG_INFOBOARD, tbInfo = {szMsg = "<color=red>殷方<color>祝福二位侠侣永远相知！", nStayTime = 1}},
		[11] = {nOpt = tbManager.OP_MSG_CHANNEL, tbInfo = {szMsg = "<color=gold>殷方<color>为典礼送上祝福，祝愿二位侠侣永远相知！", nStayTime = 8}},
		},
		[6593] = {
		[1] = {nOpt = tbManager.OP_MSG_HEITIAO, tbInfo = {szMsg = "逍遥谷紫苑来了！", nStayTime = 5}},
		[2] = {nOpt = tbManager.OP_MSG_FILM, tbInfo = {szMsg = "<npc=6593>：“两情相悦的最高境界是什么？是相对两无厌。”<end><npc=6593>：“祝福二位侠侣永结同心。”<end><npc=6593>：“相约永久恭贺典礼之禧。”<end><npc=6593>：“你们本就是天生一对，地造一双。”<end><npc=6593>：“而今共偕连理，今后更需彼此宽容、互相照顾。”<end><npc=6593>：“祝福你们！”<end>", nStayTime = 1}},
		[3] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "两情相悦的最高境界是什么？是相对两无厌。", nStayTime = 3}},
		[4] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "祝福二位侠侣永结同心。", nStayTime = 3}},
		[5] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "相约永久恭贺典礼之禧。", nStayTime = 3}},
		[6] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "你们本就是天生一对，地造一双。", nStayTime = 3}},
		[7] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "而今共偕连理，今后更需彼此宽容、互相照顾。", nStayTime = 3}},
		[8] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "祝福你们！", nStayTime = 1}},
		[9] = {nOpt = tbManager.OP_SKILL, tbInfo = {nSkillId = 1561, tbSkillPos = {1762, 3150} , nStayTime = 3}},
		[10] = {nOpt = tbManager.OP_MSG_INFOBOARD, tbInfo = {szMsg = "逍遥谷<color=red>紫苑<color>祝福二位侠侣喜结良缘，百年好合！", nStayTime = 1}},
		[11] = {nOpt = tbManager.OP_MSG_CHANNEL, tbInfo = {szMsg = "逍遥谷<color=gold>紫苑<color>为典礼送上祝福，祝愿二位侠侣喜结良缘，百年好合！", nStayTime = 8}},
		},
		[6594] = {
		[1] = {nOpt = tbManager.OP_MSG_HEITIAO, tbInfo = {szMsg = "殷童，熟悉的背影，她来了！", nStayTime = 5}},
		[2] = {nOpt = tbManager.OP_MSG_FILM, tbInfo = {szMsg = "<npc=6594>：“如果缘尽也硬要牵扯。”<end><npc=6594>：“原本的美好就会变成种束缚。”<end><npc=6594>：“变成个你我都困在其中的牢笼。”<end><npc=6594>：“古筝的知己是手。”<end><npc=6594>：“泪的知己是喜。”<end><npc=6594>：“知己的知己是一辈子！”<end><npc=6594>：“一楼哥哥，你的心上人是她”<end><npc=6594>：“那么，请好好的珍惜她，把她放在心上。”<end><npc=6594>：“请你一定要比我幸福。”<end>", nStayTime = 1}},
		[3] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "如果缘尽也硬要牵扯。", nStayTime = 3}},
		[4] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "原本的美好就会变成种束缚。", nStayTime = 3}},
		[5] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "变成个你我都困在其中的牢笼。", nStayTime = 3}},
		[6] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "古筝的知己是手。", nStayTime = 3}},
		[7] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "泪的知己是喜。", nStayTime = 3}},
		[8] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "知己的知己是一辈子！", nStayTime = 3}},
		[9] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "一楼哥哥，你的心上人是她", nStayTime = 3}},
		[10] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "那么，请好好的珍惜她，把她放在心上。", nStayTime = 3}},
		[11] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "请你一定要比我幸福。", nStayTime = 1}},
		[12] = {nOpt = tbManager.OP_SKILL, tbInfo = {nSkillId = 1561, tbSkillPos = {1762, 3150} , nStayTime = 3}},
		[13] = {nOpt = tbManager.OP_MSG_INFOBOARD, tbInfo = {szMsg = "<color=red>殷童<color>祝福二位侠侣白头偕老，永结同心！", nStayTime = 1}},
		[14] = {nOpt = tbManager.OP_MSG_CHANNEL, tbInfo = {szMsg = "<color=gold>殷童<color>为典礼送上祝福，祝愿二位侠侣白头偕老，永结同心！", nStayTime = 8}},
		},
	},
	[2] = {
		[6583] = {
		[1] = {nOpt = tbManager.OP_MSG_HEITIAO, tbInfo = {szMsg = "辣手神医张善德到了！", nStayTime = 5}},
		[2] = {nOpt = tbManager.OP_MSG_FILM, tbInfo = {szMsg = "<npc=6583>：“洋溢在喜悦的天堂。”<end><npc=6583>：“披着闪闪月光。”<end><npc=6583>：“堪叹：只羡鸳鸯不羡仙。”<end><npc=6583>：“请伸出双手，接往盈盈的祝福。”<end><npc=6583>：“让幸福绽放灿烂的花朵！”<end><npc=6583>：“迎向你们未来的日子，祝二位侠侣幸福。”<end><npc=6583>：“并带上我深深的祝福！”<end>", nStayTime = 1}},
		[3] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "洋溢在喜悦的天堂。", nStayTime = 3}},
		[4] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "披着闪闪月光。", nStayTime = 3}},
		[5] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "堪叹：只羡鸳鸯不羡仙。", nStayTime = 3}},
		[6] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "请伸出双手，接往盈盈的祝福。", nStayTime = 3}},
		[7] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "让幸福绽放灿烂的花朵！", nStayTime = 3}},
		[8] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "迎向你们未来的日子，祝二位侠侣幸福。", nStayTime = 3}},
		[9] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "并带上我深深的祝福！", nStayTime = 1}},
		[10] = {nOpt = tbManager.OP_SKILL, tbInfo = {nSkillId = 1561, tbSkillPos = {1603, 3170} , nStayTime = 3}},
		[11] = {nOpt = tbManager.OP_MSG_INFOBOARD, tbInfo = {szMsg = "辣手神医<color=red>张善德<color>祝福二位侠侣喜结良缘，百年好合！", nStayTime = 1}},
		[12] = {nOpt = tbManager.OP_MSG_CHANNEL, tbInfo = {szMsg = "辣手神医<color=gold>张善德<color>为典礼送上祝福，祝愿二位侠侣喜结良缘，百年好合！", nStayTime = 8}},
		},
		[6584] = {
		[1] = {nOpt = tbManager.OP_MSG_HEITIAO, tbInfo = {szMsg = "武当前辈一叶真人到了！", nStayTime = 5}},
		[2] = {nOpt = tbManager.OP_MSG_FILM, tbInfo = {szMsg = "<npc=6584>：“由相知而相爱。”<end><npc=6584>：“由相爱而更加相知。”<end><npc=6584>：“人们常说的神仙眷侣就是你们了！”<end><npc=6584>：“祝二位相知岁岁年年！”<end><npc=6584>：“我武当弟子纷纷要求我带来祝福！”<end><npc=6584>：“他们希望二位不要在举办典礼后。”<end><npc=6584>：“便忘了自身武艺的精进。”<end><npc=6584>：“待到来年，希望二位再到武当一聚。”<end>", nStayTime = 1}},
		[3] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "由相知而相爱。", nStayTime = 3}},
		[4] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "由相爱而更加相知。", nStayTime = 3}},
		[5] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "人们常说的神仙眷侣就是你们了！", nStayTime = 3}},
		[6] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "祝二位相知岁岁年年！", nStayTime = 3}},
		[7] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "我武当弟子纷纷要求我带来祝福！", nStayTime = 3}},
		[8] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "他们希望二位不要在举办典礼后。", nStayTime = 3}},
		[9] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "便忘了自身武艺的精进。", nStayTime = 3}},
		[10] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "待到来年，希望二位再到武当一聚。", nStayTime = 1}},
		[11] = {nOpt = tbManager.OP_SKILL, tbInfo = {nSkillId = 1561, tbSkillPos = {1603, 3170} , nStayTime = 3}},
		[12] = {nOpt = tbManager.OP_MSG_INFOBOARD, tbInfo = {szMsg = "武当前辈<color=red>一叶真人<color>祝福二位侠侣相知岁岁年年！", nStayTime = 1}},
		[13] = {nOpt = tbManager.OP_MSG_CHANNEL, tbInfo = {szMsg = "武当前辈<color=gold>一叶真人<color>为典礼送上祝福，祝愿二位侠侣相知岁岁年年！", nStayTime = 8}},
		},
		[6585] = {
		[1] = {nOpt = tbManager.OP_MSG_HEITIAO, tbInfo = {szMsg = "江湖人称母大虫的柔小翠也来贺喜了！", nStayTime = 5}},
		[2] = {nOpt = tbManager.OP_MSG_FILM, tbInfo = {szMsg = "<npc=6585>：“男人在纳吉前，觉得适合自己的女侠很少。”<end><npc=6585>：“结成侠侣后，觉得适合自己的女侠很多。”<end><npc=6585>：“喂，嘿嘿……干嘛用奇怪的眼神看着我。”<end><npc=6585>：“我只是开个玩笑嘛。”<end><npc=6585>：“今天，我是来真诚的祝福二位的哦。”<end><npc=6585>：“白头偕老，永结同心。”<end>", nStayTime = 1}},
		[3] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "男人在纳吉前，觉得适合自己的女侠很少。", nStayTime = 3}},
		[4] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "结成侠侣后，觉得适合自己的女侠很多。", nStayTime = 3}},
		[5] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "喂，嘿嘿……干嘛用奇怪的眼神看着我。", nStayTime = 3}},
		[6] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "我只是开个玩笑嘛。", nStayTime = 3}},
		[7] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "今天，我是来真诚的祝福二位的哦。", nStayTime = 3}},
		[8] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "白头偕老，永结同心。", nStayTime = 1}},
		[9] = {nOpt = tbManager.OP_SKILL, tbInfo = {nSkillId = 1561, tbSkillPos = {1603, 3170} , nStayTime = 3}},
		[10] = {nOpt = tbManager.OP_MSG_INFOBOARD, tbInfo = {szMsg = "<color=red>柔小翠<color>祝福二位白头偕老，永结同心！", nStayTime = 1}},
		[11] = {nOpt = tbManager.OP_MSG_CHANNEL, tbInfo = {szMsg = "<color=gold>柔小翠<color>为典礼送上祝福，祝愿二位侠侣白头偕老，永结同心！", nStayTime = 8}},
		},
		[6586] = {
		[1] = {nOpt = tbManager.OP_MSG_HEITIAO, tbInfo = {szMsg = "柔弱的少女夏小倩也来贺喜了！", nStayTime = 5}},
		[2] = {nOpt = tbManager.OP_MSG_FILM, tbInfo = {szMsg = "<npc=6586>：“今天，是二位大喜的日子。”<end><npc=6586>：“逍遥谷谷主批准我过来贺喜的请求。”<end><npc=6586>：“侠侣的欢乐虽然是甜美无比。”<end><npc=6586>：“但只有在光荣与善良存在的地方才能生存。”<end><npc=6586>：“希望二位日后多来逍遥谷看看我们。”<end><npc=6586>：“在我心中也有自己的心上人。”<end><npc=6586>：“我也盼望自己能与心上人一起。”<end><npc=6586>：“一起闯天下。”<end><npc=6586>：“小倩脾气不好，二位不要嫉恨。”<end><npc=6586>：“小倩真心的希望二位幸福美满。”<end>", nStayTime = 1}},
		[3] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "今天，是二位大喜的日子。", nStayTime = 3}},
		[4] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "逍遥谷谷主批准我过来贺喜的请求。", nStayTime = 3}},
		[5] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "侠侣的欢乐虽然是甜美无比。", nStayTime = 3}},
		[6] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "但只有在光荣与善良存在的地方才能生存。", nStayTime = 3}},
		[7] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "希望二位日后多来逍遥谷看看我们。", nStayTime = 3}},
		[8] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "在我心中也有自己的心上人。", nStayTime = 3}},
		[9] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "我也盼望自己能与心上人一起。", nStayTime = 3}},
		[10] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "一起闯天下。", nStayTime = 3}},
		[11] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "小倩脾气不好，二位不要嫉恨。", nStayTime = 3}},
		[12] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "小倩真心的希望二位幸福美满。", nStayTime = 1}},
		[13] = {nOpt = tbManager.OP_SKILL, tbInfo = {nSkillId = 1561, tbSkillPos = {1603, 3170} , nStayTime = 3}},
		[14] = {nOpt = tbManager.OP_MSG_INFOBOARD, tbInfo = {szMsg = "<color=red>夏小倩<color>祝福二位白头偕老，幸福美满！", nStayTime = 1}},
		[15] = {nOpt = tbManager.OP_MSG_CHANNEL, tbInfo = {szMsg = "<color=gold>夏小倩<color>为典礼送上祝福，祝愿二位侠侣白头偕老，幸福美满！", nStayTime = 8}},
		},
		[6587] = {
		[1] = {nOpt = tbManager.OP_MSG_HEITIAO, tbInfo = {szMsg = "酒楼老板大老白来了！", nStayTime = 5}},
		[2] = {nOpt = tbManager.OP_MSG_FILM, tbInfo = {szMsg = "<npc=6587>：“恭喜你们，找到共度一生的知己。”<end><npc=6587>：“这是人生大事。”<end><npc=6587>：“相信你们做出的是最明智的决定。”<end><npc=6587>：“结成侠侣以后，你们可别忘了我们。”<end><npc=6587>：“有了新的收获，新鲜的经历。”<end><npc=6587>：“可别忘了给我讲讲！”<end>", nStayTime = 1}},
		[3] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "恭喜你们，找到共度一生的知己。", nStayTime = 3}},
		[4] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "这是人生大事。", nStayTime = 3}},
		[5] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "相信你们做出的是最明智的决定。", nStayTime = 3}},
		[6] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "举行典礼以后，你们小两口可别忘了我们。", nStayTime = 3}},
		[7] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "有了新的收获，新鲜的经历。", nStayTime = 3}},
		[8] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "别忘了给我讲讲！", nStayTime = 1}},
		[9] = {nOpt = tbManager.OP_SKILL, tbInfo = {nSkillId = 1561, tbSkillPos = {1603, 3170} , nStayTime = 3}},
		[10] = {nOpt = tbManager.OP_MSG_INFOBOARD, tbInfo = {szMsg = "酒楼老板<color=red>大老白<color>祝福二位喜结良缘，百年好合！", nStayTime = 1}},
		[11] = {nOpt = tbManager.OP_MSG_CHANNEL, tbInfo = {szMsg = "酒楼老板<color=gold>大老白<color>为典礼送上祝福，祝愿二位侠侣喜结良缘，百年好合！", nStayTime = 8}},
		},
		[6588] = {
		[1] = {nOpt = tbManager.OP_MSG_HEITIAO, tbInfo = {szMsg = "逍遥四仙的唐羽来了！", nStayTime = 5}},
		[2] = {nOpt = tbManager.OP_MSG_FILM, tbInfo = {szMsg = "<npc=6588>：“爱得愈深，苛求得愈切。”<end><npc=6588>：“所以爱人之间不可能没有意气的争执。”<end><npc=6588>：“老夫也是过来人，年轻的时候，也是英俊潇洒风流倜傥啊。”<end><npc=6588>：“可惜啊可惜，可惜岁月不饶人。”<end><npc=6588>：“老夫还想再年轻五十岁！”<end><npc=6588>：“珍惜眼前人吧！”<end>", nStayTime = 1}},
		[3] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "爱得愈深，苛求得愈切。", nStayTime = 3}},
		[4] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "所以爱人之间不可能没有意气的争执。", nStayTime = 3}},
		[5] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "老夫也是过来人，年轻的时候，也是英俊潇洒风流倜傥啊。", nStayTime = 3}},
		[6] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "可惜啊可惜，可惜岁月不饶人。", nStayTime = 3}},
		[7] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "老夫还想再年轻五十岁！", nStayTime = 3}},
		[8] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "珍惜眼前人吧！", nStayTime = 1}},
		[9] = {nOpt = tbManager.OP_SKILL, tbInfo = {nSkillId = 1561, tbSkillPos = {1603, 3170} , nStayTime = 3}},
		[10] = {nOpt = tbManager.OP_MSG_INFOBOARD, tbInfo = {szMsg = "逍遥四仙<color=red>唐羽<color>祝福二位珍惜彼此，美满，幸福！", nStayTime = 1}},
		[11] = {nOpt = tbManager.OP_MSG_CHANNEL, tbInfo = {szMsg = "逍遥四仙<color=gold>唐羽<color>为典礼送上祝福，祝愿二位侠侣珍惜彼此，美满，幸福！", nStayTime = 8}},
		},
	},
	[3] = {		
		[6569] = {
		[1] = {nOpt = tbManager.OP_MSG_HEITIAO, tbInfo = {szMsg = "翠烟门掌门人尹筱雨到了！", nStayTime = 5}},
		[2] = {nOpt = tbManager.OP_MSG_FILM, tbInfo = {szMsg = "<npc=6569>：“真羡慕你们。”<end><npc=6569>：“我相信，我也终能等到我生命中的良人。”<end><npc=6569>：“我相信，我与耶律楚材，也会等到这么一天。”<end><npc=6569>：“今日，我代表翠烟门的姐妹们送上祝福。”<end><npc=6569>：“愿天下有情人终成眷属！”<end><npc=6569>：“前生注定，喜结良缘。”<end>	<npc=6569>：“典礼大喜！百年好合！”<end>", nStayTime = 1}},
		[3] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "真羡慕你们。", nStayTime = 3}},
		[4] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "我相信，我也终能等到我生命中的良人。", nStayTime = 3}},
		[5] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "我相信，我与耶律楚材，也会等到这么一天。", nStayTime = 3}},
		[6] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "今日，我代表翠烟门的姐妹们送上祝福。", nStayTime = 3}},
		[7] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "愿天下有情人终成眷属！", nStayTime = 3}},
		[8] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "前生注定，喜结良缘。", nStayTime = 3}},
		[9] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "典礼大喜！百年好合！", nStayTime = 1}},
		[10] = {nOpt = tbManager.OP_SKILL, tbInfo = {nSkillId = 1561, tbSkillPos = {1694, 3085} , nStayTime = 3}},
		[11] = {nOpt = tbManager.OP_MSG_INFOBOARD, tbInfo = {szMsg = "翠烟门掌门人<color=red>尹筱雨<color>祝福二位侠侣喜结良缘，百年好合！", nStayTime = 1}},
		[12] = {nOpt = tbManager.OP_MSG_CHANNEL, tbInfo = {szMsg = "翠烟门掌门人<color=gold>尹筱雨<color>为典礼送上祝福，祝愿二位侠侣喜结良缘，百年好合！", nStayTime = 8}},
		},
		[6570] = {
		[1] = {nOpt = tbManager.OP_MSG_HEITIAO, tbInfo = {szMsg = "天忍教教主完颜襄到了！", nStayTime = 5}},
		[2] = {nOpt = tbManager.OP_MSG_FILM, tbInfo = {szMsg = "<npc=6570>：“曾经有一份真挚的感情放在我面前。”<end><npc=6570>：“我没有珍惜。”<end><npc=6570>：“当我失去它的时候。”<end><npc=6570>：“我才后悔莫及。”<end><npc=6570>：“人世间最痛苦的事莫过于此！”<end><npc=6570>：“如果上天能够给我一个再来一次的机会。”<end><npc=6570>：“我会对筱雨说三个字<color=red>'我爱你'<color>！”<end><npc=6570>：“如果非要在这份爱上加上一个期限。”<end><npc=6570>：“我希望是<color=red>'一万年'<color>！”<end>", nStayTime = 1}},
		[3] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "曾经有一份真挚的感情放在我面前。", nStayTime = 3}},
		[4] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "我没有珍惜。", nStayTime = 3}},
		[5] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "当我失去它的时候。", nStayTime = 3}},
		[6] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "我才后悔莫及。", nStayTime = 3}},
		[7] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "人世间最痛苦的事莫过于此！", nStayTime = 3}},		
		[8] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "如果上天能够给我一个再来一次的机会！", nStayTime = 3}},
		[9] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "我会对筱雨说三个字'我爱你'！", nStayTime = 3}},
		[10] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "如果非要在这份爱上加上一个期限。", nStayTime = 3}},		
		[11] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "我希望是'一万年'！", nStayTime = 1}},
		[12] = {nOpt = tbManager.OP_SKILL, tbInfo = {nSkillId = 1561, tbSkillPos = {1694, 3085} , nStayTime = 3}},
		[13] = {nOpt = tbManager.OP_MSG_INFOBOARD, tbInfo = {szMsg = "天忍教教主<color=red>完颜襄<color>祝福二位侠侣年年岁岁永相随！", nStayTime = 1}},
		[14] = {nOpt = tbManager.OP_MSG_CHANNEL, tbInfo = {szMsg = "天忍教教主<color=gold>完颜襄<color>为典礼送上祝福，祝愿二位侠侣年年岁岁永相随！", nStayTime = 8}},
		},
		[6567] = {
		[1] = {nOpt = tbManager.OP_MSG_HEITIAO, tbInfo = {szMsg = "一个黑色的身影一闪而过，莫非是哪路豪侠到场？", nStayTime = 5}},
		[2] = {nOpt = tbManager.OP_MSG_FILM, tbInfo = {szMsg = "<npc=6567>：“在江湖飘了这么久。”<end><npc=6567>：“我陈无命何尝不想安安定定。”<end><npc=6567>：“我想有个家。”<end><npc=6567>：“一个不需要华丽的地方。”<end><npc=6567>：“在我疲倦的时候。”<end><npc=6567>：“我会想到它。”<end><npc=6567>：“在我受惊吓的时候。”<end><npc=6567>：“我才不会害怕。”<end><npc=6567>：“我好羡慕你们！”<end><npc=6567>：“珍惜彼此，祝你们美满，幸福！”<end>", nStayTime = 1}},
		[3] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "在江湖飘了这么久。", nStayTime = 3}},
		[4] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "我陈无命何尝不想安安定定。", nStayTime = 3}},
		[5] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "我想有个家。", nStayTime = 3}},
		[6] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "一个不需要华丽的地方。", nStayTime = 3}},
		[7] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "在我疲倦的时候。", nStayTime = 3}},
		[8] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "我会想到它。", nStayTime = 3}},
		[9] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "在我受惊吓的时候。", nStayTime = 3}},
		[10] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "我才不会害怕。", nStayTime = 3}},
		[11] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "我好羡慕你们！", nStayTime = 3}},
		[12] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "珍惜彼此，祝你们美满，幸福！", nStayTime = 1}},
		[13] = {nOpt = tbManager.OP_SKILL, tbInfo = {nSkillId = 1561, tbSkillPos = {1694, 3085} , nStayTime = 13}},
		[14] = {nOpt = tbManager.OP_MSG_INFOBOARD, tbInfo = {szMsg = "快刀侠客<color=red>陈无命<color>祝福二位侠侣珍惜彼此，美满，幸福！", nStayTime = 1}},
		[15] = {nOpt = tbManager.OP_MSG_CHANNEL, tbInfo = {szMsg = "快刀侠客<color=gold>陈无命<color>为典礼送上祝福，祝愿二位侠侣珍惜彼此，美满，幸福！", nStayTime = 8}},
		},
		[6575] = {
		[1] = {nOpt = tbManager.OP_MSG_HEITIAO, tbInfo = {szMsg = "又是一位江湖豪杰，女侠杨柳到了！", nStayTime = 5}},
		[2] = {nOpt = tbManager.OP_MSG_FILM, tbInfo = {szMsg = "<npc=6575>：“承诺，是一生一世的。”<end><npc=6575>：“终生相守的誓言。”<end><npc=6575>：“信物，是承诺的烙印。”<end><npc=6575>：“信物好比承诺，拿在手上，也就是放在心里。”<end><npc=6575>：“一旦拥有，别无所求！”<end><npc=6575>：“因为拥有的，是那份不能割舍的情意。”<end>", nStayTime = 1}},
		[3] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "承诺，是一生一世的。", nStayTime = 3}},
		[4] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "终生相守的誓言。", nStayTime = 3}},
		[5] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "信物，是承诺的烙印。", nStayTime = 3}},
		[6] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "信物好比承诺，拿在手上，也就是放在心里。", nStayTime = 3}},
		[7] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "一旦拥有，别无所求！", nStayTime = 3}},
		[8] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "因为拥有的，是那份不能割舍的情意。", nStayTime = 1}},
		[9] = {nOpt = tbManager.OP_SKILL, tbInfo = {nSkillId = 1561, tbSkillPos = {1694, 3085} , nStayTime = 3}},
		[10] = {nOpt = tbManager.OP_MSG_INFOBOARD, tbInfo = {szMsg = "女侠<color=red>杨柳<color>祝福二位侠侣典礼大喜，百年好合！", nStayTime = 1}},
		[11] = {nOpt = tbManager.OP_MSG_CHANNEL, tbInfo = {szMsg = "女侠<color=gold>杨柳<color>为二位送上祝福，祝愿二位侠侣典礼大喜，百年好合！", nStayTime = 8}},
		},		
		[6579] = {
		[1] = {nOpt = tbManager.OP_MSG_HEITIAO, tbInfo = {szMsg = "当朝一品大员赵汝愚赵大人到了！", nStayTime = 5}},
		[2] = {nOpt = tbManager.OP_MSG_FILM, tbInfo = {szMsg = "<npc=6579>：“因为你的到来，寂寞孤独悄然离去。”<end><npc=6579>：“因为你的到来，充实欢乐骤然而至！”<end><npc=6579>：“祝你们共享幸福。”<end><npc=6579>：“共擎风雨，白头偕老。”<end><npc=6579>：“祝你们青春美丽！”<end><npc=6579>：“人生美好，生命无憾。”<end><npc=6579>：“今天在二位侠侣步入神圣典礼殿堂的时候。”<end><npc=6579>：“我代表各位来宾衷心地祝福大侠、女侠。”<end><npc=6579>：“幸福美满，天长地久。”<end>", nStayTime = 1}},
		[3] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "因为你的到来，寂寞孤独悄然离去。", nStayTime = 3}},
		[4] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "因为你的到来，充实欢乐骤然而至！", nStayTime = 3}},
		[5] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "祝你们共享幸福。", nStayTime = 3}},
		[6] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "共擎风雨，白头偕老。", nStayTime = 3}},
		[7] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "祝你们青春美丽！", nStayTime = 3}},
		[8] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "人生美好，生命无憾。", nStayTime = 3}},
		[9] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "今天在二位侠侣步入神圣典礼殿堂的时候。", nStayTime = 3}},
		[10] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "我代表各位来宾衷心地祝福大侠、女侠。", nStayTime = 3}},
		[11] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "幸福美满，天长地久。", nStayTime = 1}},
		[12] = {nOpt = tbManager.OP_SKILL, tbInfo = {nSkillId = 1561, tbSkillPos = {1694, 3085} , nStayTime = 3}},
		[13] = {nOpt = tbManager.OP_MSG_INFOBOARD, tbInfo = {szMsg = "<color=red>赵汝愚<color>赵大人祝福二位侠侣幸福美满，天长地久！", nStayTime = 1}},
		[14] = {nOpt = tbManager.OP_MSG_CHANNEL, tbInfo = {szMsg = "<color=gold>赵汝愚<color>赵大人为典礼送上祝福，祝愿二位侠侣幸福美满，天长地久！", nStayTime = 8}},
		},
		[6580] = {
		[1] = {nOpt = tbManager.OP_MSG_HEITIAO, tbInfo = {szMsg = "义军首饰制造大师郝漂靓到了！", nStayTime = 5}},
		[2] = {nOpt = tbManager.OP_MSG_FILM, tbInfo = {szMsg = "<npc=6580>：“爱情！！！”<end><npc=6580>：“这不是一颗心去敲打另一颗心。”<end><npc=6580>：“而是两颗心共同撞击的火花。”<end><npc=6580>：“生活！！！”<end><npc=6580>：“是平平凡凡的每一天。”<end><npc=6580>：“组成让你毕生难忘的经历。”<end><npc=6580>：“侠侣嘛！！？”<end><npc=6580>：“等漂靓姐我举行典礼了以后自然会总结出来。”<end><npc=6580>：“希望你们恩爱。”<end><npc=6580>：“漂靓姐我等不及要带你们的宝宝玩儿咯。”<end>", nStayTime = 1}},
		[3] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "爱情！！！", nStayTime = 3}},
		[4] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "这不是一颗心去敲打另一颗心。", nStayTime = 3}},
		[5] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "而是两颗心共同撞击的火花。", nStayTime = 3}},
		[6] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "生活！！！", nStayTime = 3}},
		[7] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "是平平凡凡的每一天。", nStayTime = 3}},
		[8] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "组成让你毕生难忘的经历。", nStayTime = 3}},
		[9] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "婚姻嘛！！？", nStayTime = 3}},
		[10] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "等漂靓姐我举行典礼了以后自然会总结出来。", nStayTime = 3}},
		[11] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "希望你们恩爱。", nStayTime = 3}},
		[12] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "漂靓姐我等不及要带你们的宝宝玩儿咯。", nStayTime = 1}},
		[13] = {nOpt = tbManager.OP_SKILL, tbInfo = {nSkillId = 1561, tbSkillPos = {1694, 3085} , nStayTime = 3}},
		[14] = {nOpt = tbManager.OP_MSG_INFOBOARD, tbInfo = {szMsg = "义军<color=red>郝漂靓<color>祝福二位侠侣恩爱，天长地久！", nStayTime = 1}},
		[15] = {nOpt = tbManager.OP_MSG_CHANNEL, tbInfo = {szMsg = "义军<color=gold>郝漂靓<color>为典礼送上祝福，祝愿二位侠侣恩爱，天长地久！", nStayTime = 8}},
		},
		[6581] = {
		[1] = {nOpt = tbManager.OP_MSG_HEITIAO, tbInfo = {szMsg = "天王帮老前辈杨瑛到了！", nStayTime = 5}},
		[2] = {nOpt = tbManager.OP_MSG_FILM, tbInfo = {szMsg = "<npc=6581>：“老身腿脚不灵便了。”<end><npc=6581>：“来迟了一步，希望二位侠侣见谅。”<end><npc=6581>：“说点啥呢？”<end><npc=6581>：“大侠啊，多理解媳妇，做女人的，不容易。”<end><npc=6581>：“女侠啊，和婆婆好好相处，相夫教子。”<end><npc=6581>：“百年恩爱双心结。”<end><npc=6581>：“千里姻缘一线牵！”<end><npc=6581>：“惜缘，惜缘！”<end>", nStayTime = 1}},
		[3] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "老身腿脚不灵便了。", nStayTime = 3}},
		[4] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "来迟了一步，希望二位侠侣见谅。", nStayTime = 3}},
		[5] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "说点啥呢？", nStayTime = 3}},
		[6] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "大侠啊，多理解媳妇，做女人的，不容易。", nStayTime = 3}},
		[7] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "女侠啊，和婆婆好好相处，相夫教子。", nStayTime = 3}},
		[8] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "百年恩爱双心结。", nStayTime = 3}},
		[9] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "千里姻缘一线牵！", nStayTime = 3}},
		[10] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "惜缘，惜缘！", nStayTime = 1}},
		[11] = {nOpt = tbManager.OP_SKILL, tbInfo = {nSkillId = 1561, tbSkillPos = {1694, 3085} , nStayTime = 3}},
		[12] = {nOpt = tbManager.OP_MSG_INFOBOARD, tbInfo = {szMsg = "天王帮老前辈<color=red>杨瑛<color>祝福二位侠侣百年恩爱双心结！", nStayTime = 1}},
		[13] = {nOpt = tbManager.OP_MSG_CHANNEL, tbInfo = {szMsg = "天王帮老前辈<color=gold>杨瑛<color>为典礼送上祝福，祝愿二位侠侣百年恩爱双心结！", nStayTime = 8}},
		},
		[6582] = {
		[1] = {nOpt = tbManager.OP_MSG_HEITIAO, tbInfo = {szMsg = "唐门门主唐晓到了！", nStayTime = 5}},
		[2] = {nOpt = tbManager.OP_MSG_FILM, tbInfo = {szMsg = "<npc=6582>：“情是一片炽热狂迷的痴心。”<end><npc=6582>：“一团无法扑灭的烈火。”<end><npc=6582>：“一种永不满足的欲望。”<end><npc=6582>：“一分如糖似蜜的喜悦。”<end><npc=6582>：“一阵如痴如醉的疯狂。”<end><npc=6582>：“一种没有安宁的劳苦。”<end><npc=6582>：“和没有劳苦的安宁！”<end><npc=6582>：“而你们的相伴，一定是情意的升华。”<end><npc=6582>：“缘定三生，永结同心。”<end>", nStayTime = 1}},
		[3] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "情是一片炽热狂迷的痴心。", nStayTime = 3}},
		[4] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "一团无法扑灭的烈火。", nStayTime = 3}},
		[5] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "一种永不满足的欲望。", nStayTime = 3}},
		[6] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "一分如糖似蜜的喜悦。", nStayTime = 3}},
		[7] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "一阵如痴如醉的疯狂。", nStayTime = 3}},
		[8] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "一种没有安宁的劳苦。", nStayTime = 3}},
		[9] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "和没有劳苦的安宁！", nStayTime = 3}},
		[10] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "而你们的相伴，一定是情意的升华。", nStayTime = 3}},
		[11] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "缘定三生，永结同心。", nStayTime = 1}},
		[12] = {nOpt = tbManager.OP_SKILL, tbInfo = {nSkillId = 1561, tbSkillPos = {1694, 3085} , nStayTime = 3}},
		[13] = {nOpt = tbManager.OP_MSG_INFOBOARD, tbInfo = {szMsg = "唐门门主<color=red>唐晓<color>祝福二位侠侣缘定三生，永结同心！", nStayTime = 1}},
		[14] = {nOpt = tbManager.OP_MSG_CHANNEL, tbInfo = {szMsg = "唐门门主<color=gold>唐晓<color>为典礼送上祝福，祝愿二位侠侣缘定三生，永结同心！", nStayTime = 8}},
		},
	},
	[4] = {
		[6572] = {
		[1] = {nOpt = tbManager.OP_MSG_HEITIAO, tbInfo = {szMsg = "大理府段皇爷驾到！！", nStayTime = 5}},
		[2] = {nOpt = tbManager.OP_MSG_FILM, tbInfo = {szMsg = "<npc=6572>：“两情若是长久时，又岂在朝朝暮暮。”<end><npc=6572>：“只要爱情纯洁，花开花谢就永好。”<end><npc=6572>：“只要情真意切，月缺月圆便常圆。”<end><npc=6572>：“只要心心相印，山远水远不算远。”<end><npc=6572>：“只要相亲相爱，千难万难不觉难。”<end><npc=6572>：“罗贵妃，你能理解我吗？”<end>", nStayTime = 1}},
		[3] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "两情若是长久时，又岂在朝朝暮暮。", nStayTime = 3}},
		[4] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "只要爱情纯洁，花开花谢就永好。", nStayTime = 3}},
		[5] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "只要情真意切，月缺月圆便常圆。", nStayTime = 3}},
		[6] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "只要心心相印，山远水远不算远。", nStayTime = 3}},
		[7] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "只要相亲相爱，千难万难不觉难。", nStayTime = 3}},
		[8] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "罗贵妃，你能理解我吗？", nStayTime = 1}},		
		[9] = {nOpt = tbManager.OP_SKILL, tbInfo = {nSkillId = 1561, tbSkillPos = {1591, 3216} , nStayTime = 3}},
		[10] = {nOpt = tbManager.OP_MSG_INFOBOARD, tbInfo = {szMsg = "大理段氏门主<color=red>段智兴<color>祝福二位侠侣心心相印！", nStayTime = 1}},
		[11] = {nOpt = tbManager.OP_MSG_CHANNEL, tbInfo = {szMsg = "大理段氏门主<color=gold>段智兴<color>为典礼送上祝福，祝愿二位侠侣心心相印！", nStayTime = 8}},
		},
		[6568] = {
		[1] = {nOpt = tbManager.OP_MSG_HEITIAO, tbInfo = {szMsg = "天王帮帮主杨铁心到了！", nStayTime = 5}},
		[2] = {nOpt = tbManager.OP_MSG_FILM, tbInfo = {szMsg = "<npc=6568>：“来晚了一步，没抢到沙发。”<end><npc=6568>：“你们本就是天生一对，地造一双。”<end><npc=6568>：“而今共偕连理。”<end><npc=6568>：“今后更需彼此宽容、互相照顾。”<end><npc=6568>：“我代表天王帮祝福你们！”<end><npc=6568>：“在将来的日子里。”<end><npc=6568>：“我天王帮还需要二位的相助。”<end><npc=6568>：“我们要走的路还很长。”<end>", nStayTime = 1}},
		[3] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "来晚了一步，没抢到沙发。", nStayTime = 3}},
		[4] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "你们本就是天生一对，地造一双。", nStayTime = 3}},
		[5] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "而今共偕连理。", nStayTime = 3}},
		[6] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "今后更需彼此宽容、互相照顾。", nStayTime = 3}},
		[7] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "我代表天王帮祝福你们！", nStayTime = 3}},
		[8] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "在将来的日子里。", nStayTime = 3}},
		[9] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "我天王帮还需要二位的相助。", nStayTime = 3}},
		[10] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "我们要走的路还很长。", nStayTime = 1}},
		[11] = {nOpt = tbManager.OP_SKILL, tbInfo = {nSkillId = 1561, tbSkillPos = {1591, 3216} , nStayTime = 3}},
		[12] = {nOpt = tbManager.OP_MSG_INFOBOARD, tbInfo = {szMsg = "天王帮帮主<color=red>杨铁心<color>祝福二位侠侣家庭和睦，和谐幸福！", nStayTime = 1}},
		[13] = {nOpt = tbManager.OP_MSG_CHANNEL, tbInfo = {szMsg = "天王帮帮主<color=gold>杨铁心<color>为典礼送上祝福，祝愿二位侠侣家庭和睦，和谐幸福！", nStayTime = 8}},
		},
		[6571] = {
		[1] = {nOpt = tbManager.OP_MSG_HEITIAO, tbInfo = {szMsg = "武学宗师王重阳大师到了！！", nStayTime = 5}},
		[2] = {nOpt = tbManager.OP_MSG_FILM, tbInfo = {szMsg = "<npc=6571>：“无量天尊，贫道来也。”<end><npc=6571>：“茫茫人海中找到了你的另一半。”<end><npc=6571>：“分明是千年前的一段缘。”<end><npc=6571>：“十年修得同船渡。”<end><npc=6571>：“百年修得共枕眠！”<end><npc=6571>：“无数个偶然堆积而成的必然。”<end><npc=6571>：“怎能不是三生石上精心镌刻的结果呢？”<end><npc=6571>：“用真心呵护这份缘吧。”<end><npc=6571>：“武当弟子祝福你们。”<end>", nStayTime = 1}},
		[3] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "无量天尊，贫道来也。", nStayTime = 3}},
		[4] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "茫茫人海中找到了你的另一半。", nStayTime = 3}},
		[5] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "分明是千年前的一段缘。", nStayTime = 3}},
		[6] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "十年修得同船渡。", nStayTime = 3}},
		[7] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "百年修得共枕眠！", nStayTime = 3}},		
		[8] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "无数个偶然堆积而成的必然。", nStayTime = 3}},
		[9] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "怎能不是三生石上精心镌刻的结果呢？", nStayTime = 3}},
		[10] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "用真心呵护这份缘吧。", nStayTime = 3}},		
		[11] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "武当弟子祝福你们。", nStayTime = 1}},
		[12] = {nOpt = tbManager.OP_SKILL, tbInfo = {nSkillId = 1561, tbSkillPos = {1591, 3216} , nStayTime = 3}},
		[13] = {nOpt = tbManager.OP_MSG_INFOBOARD, tbInfo = {szMsg = "武学宗师<color=red>王重阳<color>祝福二位侠侣一心向善！", nStayTime = 1}},
		[14] = {nOpt = tbManager.OP_MSG_CHANNEL, tbInfo = {szMsg = "武学宗师<color=gold>王重阳<color>为典礼送上祝福，祝愿二位侠侣一心向善！", nStayTime = 8}},
		},
		[6574] = {
		[1] = {nOpt = tbManager.OP_MSG_HEITIAO, tbInfo = {szMsg = "右丞相韩侂胄韩大人大驾光临！！", nStayTime = 5}},
		[2] = {nOpt = tbManager.OP_MSG_FILM, tbInfo = {szMsg = "<npc=6574>：“今天，艳阳高照，天赐良缘。”<end><npc=6574>：“高朋满座，同贺新禧！”<end><npc=6574>：“在今天的大喜日子里。”<end><npc=6574>：“我谨代表枢密院，翰林院东西两院的各位首长。”<end><npc=6574>：“向两位侠侣表示热烈地祝贺和美好地祝愿！”<end><npc=6574>：“衷心地希望你们，在今后的日子里。”<end><npc=6574>：“能够勤奋工作、互敬互爱，孝敬老人、关爱孩子。”<end><npc=6574>：“事业红红火火，家庭甜甜蜜蜜。”<end><npc=6574>：“谢谢！”<end>", nStayTime = 1}},
		[3] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "今天，艳阳高照，天赐良缘。", nStayTime = 3}},
		[4] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "高朋满座，同贺新禧！", nStayTime = 3}},
		[5] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "在今天的大喜日子里。", nStayTime = 3}},
		[6] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "我谨代表枢密院，翰林院东西两院的各位首长。", nStayTime = 3}},
		[7] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "向两位侠侣表示热烈地祝贺和美好地祝愿！", nStayTime = 3}},		
		[8] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "衷心地希望你们，在今后的日子里。", nStayTime = 3}},
		[9] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "能够勤奋工作、互敬互爱，孝敬老人、关爱孩子。", nStayTime = 3}},
		[10] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "事业红红火火，家庭甜甜蜜蜜。", nStayTime = 3}},		
		[11] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "谢谢！ ", nStayTime = 1}},
		[12] = {nOpt = tbManager.OP_SKILL, tbInfo = {nSkillId = 1561, tbSkillPos = {1591, 3216} , nStayTime = 3}},
		[13] = {nOpt = tbManager.OP_MSG_INFOBOARD, tbInfo = {szMsg = "右丞相<color=red>韩侂胄<color>祝福二位侠侣事业红红火火，家庭甜甜蜜蜜！", nStayTime = 1}},
		[14] = {nOpt = tbManager.OP_MSG_CHANNEL, tbInfo = {szMsg = "右丞相<color=gold>韩侂胄<color>为典礼送上祝福，祝愿二位侠侣事业红红火火，家庭甜甜蜜蜜！", nStayTime = 8}},
		},
		[6573] = {
		[1] = {nOpt = tbManager.OP_MSG_HEITIAO, tbInfo = {szMsg = "义军毕在遇大将军到了！！", nStayTime = 5}},
		[2] = {nOpt = tbManager.OP_MSG_FILM, tbInfo = {szMsg = "<npc=6573>：“老夫看着你们俩相识相知，甚感欣慰。”<end><npc=6573>：“让我们为善良的人儿起舞！”<end><npc=6573>：“为快乐的人儿歌唱。”<end><npc=6573>：“为幸福的人儿举杯。”<end><npc=6573>：“愿他们的人生之路永远洒满阳光！”<end><npc=6573>：“吃尽天下美味不要浪费。”<end><npc=6573>：“喝尽人间美酒不要喝醉。”<end><npc=6573>：“吃好，喝好，大家好！”<end>", nStayTime = 1}},
		[3] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "老夫看着你们俩相识相知，甚感欣慰。", nStayTime = 3}},
		[4] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "让我们为善良的人儿起舞！", nStayTime = 3}},
		[5] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "为快乐的人儿歌唱。", nStayTime = 3}},
		[6] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "为幸福的人儿举杯。", nStayTime = 3}},
		[7] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "愿他们的人生之路永远洒满阳光！", nStayTime = 3}},		
		[8] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "吃尽天下美味不要浪费。", nStayTime = 3}},
		[9] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "喝尽人间美酒不要喝醉。", nStayTime = 3}},	
		[10] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "吃好，喝好，大家好！", nStayTime = 1}},
		[11] = {nOpt = tbManager.OP_SKILL, tbInfo = {nSkillId = 1561, tbSkillPos = {1591, 3216} , nStayTime = 3}},
		[12] = {nOpt = tbManager.OP_MSG_INFOBOARD, tbInfo = {szMsg = "<color=red>毕在遇<color>大将军祝福二位侠侣侠侣白头偕老！", nStayTime = 1}},
		[13] = {nOpt = tbManager.OP_MSG_CHANNEL, tbInfo = {szMsg = "<color=gold>毕在遇<color>大将军为典礼送上祝福，祝愿二位侠侣白头偕老！", nStayTime = 8}},
		},
		[6576] = {
		[1] = {nOpt = tbManager.OP_MSG_HEITIAO, tbInfo = {szMsg = "义军防具制造大师沈荷叶到了！！", nStayTime = 5}},
		[2] = {nOpt = tbManager.OP_MSG_FILM, tbInfo = {szMsg = "<npc=6576>：“为你们祝福，为你们欢笑。”<end><npc=6576>：“因为在今天，我的内心也跟你一样的欢腾、快乐！”<end><npc=6576>：“今天，我作为义军时尚潮流的代表。”<end><npc=6576>：“祝你们，百年好合，白头到老！”<end><npc=6576>：“养个胖小子！”<end><npc=6576>：“他的衣服荷叶姐以后全包了。”<end>", nStayTime = 1}},
		[3] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "为你们祝福，为你们欢笑。", nStayTime = 3}},
		[4] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "因为在今天，我的内心也跟你一样的欢腾、快乐！", nStayTime = 3}},
		[5] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "今天，我作为义军时尚潮流的代表。", nStayTime = 3}},
		[6] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "祝你们，百年好合，白头到老！", nStayTime = 3}},
		[7] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "养个胖小子！", nStayTime = 3}},		
		[8] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "他的衣服荷叶姐以后全包了。", nStayTime = 1}},
		[9] = {nOpt = tbManager.OP_SKILL, tbInfo = {nSkillId = 1561, tbSkillPos = {1591, 3216} , nStayTime = 3}},
		[10] = {nOpt = tbManager.OP_MSG_INFOBOARD, tbInfo = {szMsg = "义军<color=red>沈荷叶<color>祝福二位侠侣才子佳人，永结同心！", nStayTime = 1}},
		[11] = {nOpt = tbManager.OP_MSG_CHANNEL, tbInfo = {szMsg = "义军<color=gold>沈荷叶<color>为典礼送上祝福，祝愿二位侠侣才子佳人，永结同心！", nStayTime = 8}},
		},
		[6577] = {
		[1] = {nOpt = tbManager.OP_MSG_HEITIAO, tbInfo = {szMsg = "蒙古大汗铁木真千里迢迢来到典礼现场！", nStayTime = 5}},
		[2] = {nOpt = tbManager.OP_MSG_FILM, tbInfo = {szMsg = "<npc=6577>：“你是那疾驰的箭，她就是你翎旁的风声。”<end><npc=6577>：“你是那负伤的鹰，她就是抚慰你的月光。”<end><npc=6577>：“你是那昂然的松，她就是缠绵的藤萝。”<end><npc=6577>：“愿，二位天长地久。”<end><npc=6577>：“姑娘啊，他永是你的知己。”<end><npc=6577>：“你是他生生世世的心上人。”<end>", nStayTime = 1}},
		[3] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "你是那疾驰的箭，她就是你翎旁的风声。", nStayTime = 3}},
		[4] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "你是那负伤的鹰，她就是抚慰你的月光。", nStayTime = 3}},
		[5] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "你是那昂然的松，她就是缠绵的藤萝。", nStayTime = 3}},
		[6] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "愿，二位天长地久。", nStayTime = 3}},
		[7] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "姑娘啊，他永是你的知己。", nStayTime = 3}},		
		[8] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "你是他生生世世的心上人。", nStayTime = 1}},
		[9] = {nOpt = tbManager.OP_SKILL, tbInfo = {nSkillId = 1561, tbSkillPos = {1591, 3216} , nStayTime = 3}},
		[10] = {nOpt = tbManager.OP_MSG_INFOBOARD, tbInfo = {szMsg = "蒙古大汗<color=red>铁木真<color>祝福二位侠侣生生世世，相扶相依！", nStayTime = 1}},
		[11] = {nOpt = tbManager.OP_MSG_CHANNEL, tbInfo = {szMsg = "蒙古大汗<color=gold>铁木真<color>为典礼送上祝福，祝愿二位侠侣生生世世，相扶相依！", nStayTime = 8}},
		},
		[6578] = {
		[1] = {nOpt = tbManager.OP_MSG_HEITIAO, tbInfo = {szMsg = "大文豪辛弃疾到了！", nStayTime = 5}},
		[2] = {nOpt = tbManager.OP_MSG_FILM, tbInfo = {szMsg = "<npc=6578>：“俗话说：'有缘千里来相会'。”<end><npc=6578>：“由于出类拔萃，因此，一经相遇，就一见钟情，一看倾心。”<end><npc=6578>：“两颗真诚的心撞在了一起。”<end><npc=6578>：“闪烁出爱情的火花。”<end><npc=6578>：“他们相爱了。”<end><npc=6578>：“他们志同道合。”<end><npc=6578>：“他们的结合是天生一对，地作一双。”<end><npc=6578>：“在他们新的生活即将开始的时候。”<end><npc=6578>：“我希望大侠、女侠互谅所短，互见所长。”<end><npc=6578>：“至死不渝，幸福无疆。”<end>", nStayTime = 1}},
		[3] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "俗话说：'有缘千里来相会'。", nStayTime = 3}},
		[4] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "由于出类拔萃，因此，一经相遇，就一见钟情，一看倾心。", nStayTime = 3}},
		[5] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "两颗真诚的心撞在了一起。", nStayTime = 3}},
		[6] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "闪烁出爱情的火花。", nStayTime = 3}},
		[7] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "他们相爱了。", nStayTime = 2}},		
		[8] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "他们志同道合。", nStayTime = 2}},
		[9] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "他们的结合是天生一对，地作一双。", nStayTime = 3}},
		[10] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "在他们新的生活即将开始的时候。", nStayTime = 3}},
		[11] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "我希望大侠、女侠互谅所短，互见所长。", nStayTime = 3}},		
		[12] = {nOpt = tbManager.OP_MSG_CHAT, tbInfo = {szMsg = "至死不渝，幸福无疆。", nStayTime = 1}},
		[13] = {nOpt = tbManager.OP_SKILL, tbInfo = {nSkillId = 1561, tbSkillPos = {1591, 3216} , nStayTime = 3}},
		[14] = {nOpt = tbManager.OP_MSG_INFOBOARD, tbInfo = {szMsg = "大文豪<color=red>辛弃疾<color>祝福二位侠侣至死不渝，幸福无疆！", nStayTime = 1}},
		[15] = {nOpt = tbManager.OP_MSG_CHANNEL, tbInfo = {szMsg = "大文豪<color=gold>辛弃疾<color>为典礼送上祝福，祝愿二位侠侣至死不渝，幸福无疆！", nStayTime = 8}},
		},
	},
	}
	
	
--=============================================================
	
function tbManager:Open(nMapId)
	local tbVisitorNpcPos = self:GetVisitorPos(nMapId);
	if (not tbVisitorNpcPos) then
		return;
	end	
	Marry:SetPerformState(nMapId, 1);
	
	local nTimerId = Timer:Register(1, self.Perform, self, nMapId, tbVisitorNpcPos);
	Marry:AddSpecTimer(nMapId, "visitornpc", nTimerId);
end

function tbManager:GetVisitorPos(nMapId)
	local nMapLevel = Marry:GetWeddingMapLevel(nMapId);
	if (not self.TB_PATH_POSFILE[nMapLevel]) then
		return;
	end
	local tbPosSetting = Lib:LoadTabFile(self.TB_PATH_POSFILE[nMapLevel]);
	
	local tbPos = {};
	-- 加载来访npc坐标
	for nRow, tbRowData in pairs(tbPosSetting) do
		local tbTemp = {};
		tbTemp[1] = tonumber(tbRowData["PosX"]);
		tbTemp[2] = tonumber(tbRowData["PosY"]);
		table.insert(tbPos, tbTemp);
	end
	return tbPos;
end

-- 来访npc表演
function tbManager:Perform(nMapId, tbVisitorNpcPos)
	local tbCurNpcInfo = self:GetCurNpcInfo(nMapId, tbVisitorNpcPos);
	if (not tbCurNpcInfo) then
		Marry:SetPerformState(nMapId, 0);
		return 0;
	end
	
	local nNpcIndex = tbCurNpcInfo.nNpcIndex;
	local nCurSkillIndex = tbCurNpcInfo.nCurSkillIndex
	local nWeddingMapLevel = Marry:GetWeddingMapLevel(nMapId);
	local nNpcTemplateId = self.TB_NPCID[nWeddingMapLevel][nNpcIndex];
	local tbCurInfo = self.TB_OPT[nWeddingMapLevel][nNpcTemplateId][nCurSkillIndex];
	local nNpcId = tbCurNpcInfo.nNpcId;
	
	if (not nNpcId and not tbCurInfo) then
		Marry:SetPerformState(nMapId, 0);
		return 0;
	end
	
	local nNextTime = self:Play(nMapId, nNpcId, tbCurInfo);
	if (0 == nNextTime) then
		Marry:SetPerformState(nMapId, 0);
	end
	return nNextTime;
	-- return self:Play(nMapId, nNpcId, tbCurInfo);
end

-- 获取当前npc的操作信息（返回值pNpc, tbInfo）
function tbManager:GetCurNpcInfo(nMapId, tbVisitorNpcPos)
	local tbCurNpcInfo = Marry:GetVisitorNpc(nMapId);
	-- 头一次召唤来访npc
	if (not tbCurNpcInfo) then
		return self:AddNewVisitorNpc(nMapId, 0, tbVisitorNpcPos);
	end
	
	local nNpcIndex = tbCurNpcInfo.nNpcIndex;
	local nNpcId = tbCurNpcInfo.nNpcId;
	local nCurSkillIndex = tbCurNpcInfo.nCurSkillIndex + 1;
	local nWeddingMapLevel = Marry:GetWeddingMapLevel(nMapId);
	local nNpcTemplateId = self.TB_NPCID[nWeddingMapLevel][nNpcIndex];
	local tbCurOpt = self.TB_OPT[nWeddingMapLevel][nNpcTemplateId][nCurSkillIndex];
	-- 每一个来访npc表演完之后，召唤下一个npc继续
	if (not tbCurOpt) then
		return self:AddNewVisitorNpc(nMapId, nNpcIndex, tbVisitorNpcPos);
	end
	
	-- 当前的来访npc还没有表演完，继续进行下一个步骤的表演
	tbCurNpcInfo.nCurSkillIndex = nCurSkillIndex;
	Marry:SetVisitorNpc(nMapId, tbCurNpcInfo);
	return tbCurNpcInfo;
end

-- 增加一个新的来访npc
function tbManager:AddNewVisitorNpc(nMapId, nCurNpcIndex, tbVisitorNpcPos)
	local nNpcIndex = nCurNpcIndex + 1;
	local nWeddingMapLevel = Marry:GetWeddingMapLevel(nMapId);
	if (not self.TB_NPCID[nWeddingMapLevel][nNpcIndex] or not tbVisitorNpcPos) then
		return;
	end

	local nNpcTemplateId = self.TB_NPCID[nWeddingMapLevel][nNpcIndex];
	local tbNpcPos = tbVisitorNpcPos[nNpcIndex];
	if (not tbNpcPos) then
		return;
	end
	local pNpc = KNpc.Add2(nNpcTemplateId , 120, -1, nMapId, unpack(tbNpcPos));
	if (not pNpc) then
		return;
	end
	
	local tbNpcInfo = {};
	tbNpcInfo.nNpcIndex = nNpcIndex;
	tbNpcInfo.nNpcId = pNpc.dwId;
	tbNpcInfo.nCurSkillIndex = 1;
	
	Marry:SetVisitorNpc(nMapId, tbNpcInfo);
	
	return tbNpcInfo;
end

function tbManager:Play(nMapId, nNpcId, tbCurInfo)
	local nStayTime = 0;
	local nOptType = tbCurInfo.nOpt;
	if (self.OP_MSG_CHAT == nOptType) then
		nStayTime = self:Play_SendChat(nNpcId, tbCurInfo.tbInfo);
	elseif (self.OP_MSG_FILM == nOptType) then
		nStayTime = self:Play_Film(nMapId, tbCurInfo.tbInfo);
	elseif (self.OP_MSG_HEITIAO == nOptType) then
		nStayTime = self:Play_Heitiao(nMapId, tbCurInfo.tbInfo);
	elseif (self.OP_MSG_CHANNEL == nOptType) then
		nStayTime = self:Play_Channel(nMapId, nNpcId, tbCurInfo.tbInfo);
	elseif (self.OP_MSG_INFOBOARD == nOptType) then
		nStayTime = self:Play_InfoBordMsg(nMapId, tbCurInfo.tbInfo);
	elseif (self.OP_SKILL == nOptType) then
		nStayTime = self:Play_CastSkill(nNpcId, tbCurInfo.tbInfo);
	end
	return nStayTime * Env.GAME_FPS;
end

function tbManager:GetAllPlayers(nMapId)
	local tbPlayerList = Marry:GetAllPlayers(nMapId) or {};
	return tbPlayerList;
end

-- 表演（头顶上说话）
function tbManager:Play_SendChat(nNpcId, tbCurInfo)
	local pNpc = KNpc.GetById(nNpcId);
	if (pNpc) then
		pNpc.SendChat(tbCurInfo.szMsg);
	end
	return tbCurInfo.nStayTime;
end

-- 表演（电影模式）
function tbManager:Play_Film(nMapId, tbCurInfo)
	local tbPlayerList = self:GetAllPlayers(nMapId);
	for _, pPlayer in pairs(tbPlayerList) do
		Setting:SetGlobalObj(pPlayer);
		TaskAct:Talk(tbCurInfo.szMsg);
		Setting:RestoreGlobalObj();
	end
	return tbCurInfo.nStayTime;
end

-- 表演（黑条信息）
function tbManager:Play_Heitiao(nMapId, tbCurInfo)
	local tbPlayerList = self:GetAllPlayers(nMapId);
	for _, pPlayer in pairs(tbPlayerList) do
		Dialog:SendBlackBoardMsg(pPlayer, tbCurInfo.szMsg);
	end
	return tbCurInfo.nStayTime;
end

-- 表演（聊天频道信息）
function tbManager:Play_Channel(nMapId, nNpcId, tbCurInfo)
	local tbPlayerList = self:GetAllPlayers(nMapId);
	local pNpc = KNpc.GetById(nNpcId);
	for _, pPlayer in pairs(tbPlayerList) do
		Setting:SetGlobalObj(pPlayer);
		me.Msg(tbCurInfo.szMsg, pNpc.szName);
		Setting:RestoreGlobalObj();
	end
	return tbCurInfo.nStayTime;
end

function tbManager:Play_InfoBordMsg(nMapId, tbCurInfo)
	local tbPlayerList = self:GetAllPlayers(nMapId);
	local szMsg = string.format("<color=yellow>%s<color>", tbCurInfo.szMsg)
	for _, pPlayer in pairs(tbPlayerList) do
		Dialog:SendInfoBoardMsg(pPlayer, szMsg);
	end
	return tbCurInfo.nStayTime;
end

-- 表演（释放技能）
function tbManager:Play_CastSkill(nNpcId, tbCurInfo)
	local pNpc = KNpc.GetById(nNpcId);
	if (pNpc) then
		pNpc.CastSkill(tbCurInfo.nSkillId, 1, unpack(tbCurInfo.tbSkillPos));
	end
	return tbCurInfo.nStayTime;
end
