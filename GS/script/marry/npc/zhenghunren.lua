-- 文件名　：zhenghunren.lua
-- 创建者　：furuilei
-- 创建时间：2009-12-30 17:31:20
-- 功能描述：典礼npc（证婚人）

local tbNpc = Npc:GetClass("marry_zhenghunren");

--====================================================

tbNpc.OP_MSG_CHAT		= 1;	-- 发送对话信息
tbNpc.OP_MSG_FILM		= 2;	-- 电影字幕
tbNpc.OP_MSG_HEITIAO	= 3;	-- 黑条信息
tbNpc.OP_MSG_CHANNEL	= 4;	-- 聊天栏信息
tbNpc.OP_MSG_INFOBOARD	= 5;	-- 中央黄色字信息
tbNpc.OP_SKILL			= 6;	-- 释放技能

-- 证婚人的对话以及操作。1,2,3,4分别代表平民到皇家4个档次的证婚人
tbNpc.tbOpt = {
	[1] = {
		[1] = {nOpt = tbNpc.OP_MSG_HEITIAO, tbInfo = {szMsg = "司仪义军首领白秋琳走上了典礼台。", nStayTime = 2}},	
		[2] = {nOpt = tbNpc.OP_MSG_INFOBOARD, tbInfo = {szMsg = "司仪已到场，各位来宾请到礼台周围来，典礼即将开始。", nStayTime = 1}},
		[3] = {nOpt = tbNpc.OP_MSG_CHANNEL, tbInfo = {szMsg = "司仪已到场，各位来宾请到礼台周围来，典礼即将开始。", nStayTime = 1}},
		[4] = {nOpt = tbNpc.OP_MSG_INFOBOARD, tbInfo = {szMsg = "幸福的篝火已点燃，典礼台周围的宾客将会获得巨额经验，快来啊。", nStayTime = 8}},			
		[5] = {nOpt = tbNpc.OP_MSG_INFOBOARD, tbInfo = {szMsg = "司仪已到场，各位来宾请到礼台周围来，典礼即将开始。", nStayTime = 1}},
		[6] = {nOpt = tbNpc.OP_MSG_CHANNEL, tbInfo = {szMsg = "司仪已到场，各位来宾请到礼台周围来，典礼即将开始。", nStayTime = 1}},
		[7] = {nOpt = tbNpc.OP_MSG_INFOBOARD, tbInfo = {szMsg = "幸福的篝火已点燃，典礼台周围的宾客将会获得巨额经验，快来啊。", nStayTime = 8}},		
		[8] = {nOpt = tbNpc.OP_MSG_INFOBOARD, tbInfo = {szMsg = "司仪已到场，各位来宾请到礼台周围来，典礼即将开始。", nStayTime = 1}},
		[9] = {nOpt = tbNpc.OP_MSG_CHANNEL, tbInfo = {szMsg = "司仪已到场，各位来宾请到礼台周围来，典礼即将开始。", nStayTime = 1}},
		[10] = {nOpt = tbNpc.OP_MSG_INFOBOARD, tbInfo = {szMsg = "幸福的篝火已点燃，典礼台周围的宾客将会获得巨额经验，快来啊。", nStayTime = 8}},			
		[11] = {nOpt = tbNpc.OP_MSG_FILM, tbInfo = {szMsg = "<npc=6656>：“诸位父老乡亲，义军的兄弟姐妹们。”<end><npc=6656>：“承蒙大家厚爱，有幸在这里为二位主持典礼。”<end><npc=6656>：“心情非常，非常激动。”<end><npc=6656>：“在义军众多兄弟姐妹中，他们俩都是出类拔萃，一表人才。”<end><npc=6656>：“只看那大侠相貌堂堂，玉树临风。”<end><npc=6656>：“又见那女侠闭月羞花，倾国倾城。”<end><npc=6656>：“他俩人必定是天造地设的一对璧人。”<end><npc=6656>：“列祖列宗在上，我白秋琳在此见证二位今日结为侠侣。”<end>", nStayTime = 1}},
		[12] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "诸位父老乡亲，义军的兄弟姐妹们。", nStayTime = 4}},
		[13] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "承蒙大家厚爱，有幸在这里为二位主持典礼。", nStayTime = 4}},
		[14] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "心情非常，非常激动。", nStayTime = 4}},
		[15] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "在义军众多兄弟姐妹中，他们俩都是出类拔萃，一表人才。", nStayTime = 4}},
		[16] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "只看这位大侠相貌堂堂，玉树临风。", nStayTime = 4}},
		[17] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "又见那边女侠闭月羞花，倾国倾城。", nStayTime = 4}},
		[18] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "他俩人必定是天造地设的一对璧人。", nStayTime = 4}},		
		[19] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "列祖列宗在上，我白秋琳在此见证二位今日结为侠侣。", nStayTime = 4}},
		[20] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "下面听我指示……", nStayTime = 3}},
		[21] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "一拜天地！", nStayTime = 1}},
		[22] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1560, tbSkillPos = {1762, 3150} , nStayTime = 2}},
		[23] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1559, tbSkillPos = {1762, 3150} , nStayTime = 3}},	
		[24] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "祝福二位大富大贵！", nStayTime = 1}},	
		[25] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1561, tbSkillPos = {1762, 3150} , nStayTime = 5}},		
		[26] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "二拜高堂！", nStayTime = 1}},
		[27] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1557, tbSkillPos = {1762, 3150} , nStayTime = 2}},
		[28] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1559, tbSkillPos = {1762, 3150} ,  nStayTime = 3}},	
		[29] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "祝福二位幸福美满！", nStayTime = 1}},
		[30] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1561, tbSkillPos = {1762, 3150} , nStayTime = 5}},	
		[31] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "侠侣对拜！", nStayTime = 1}},
		[32] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1556, tbSkillPos = {1762, 3150} ,  nStayTime = 2}},
		[33] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1559, tbSkillPos = {1762, 3150} ,  nStayTime = 3}},		
		[34] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "祝福二位永结同心！", nStayTime = 1}},
		[35] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1561, tbSkillPos = {1762, 3150} , nStayTime = 5}},	
		[36] = {nOpt = tbNpc.OP_MSG_FILM, tbInfo = {szMsg = "<npc=6656>：“下面我宣布，你二人正式结为侠侣。”<end><npc=6656>：“从今往后自当彼此尊重，相互扶持。”<end><npc=6656>：“白头偕老，相濡以沫，祝福你们。”<end>", nStayTime = 1}},
		[37] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "下面我宣布，你二人正式结为侠侣。", nStayTime = 4}},
		[38] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "从今往后自当彼此尊重，相互扶持。", nStayTime = 4}},
		[39] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "白头偕老，相濡以沫，祝福你们。", nStayTime = 4}},
		[40] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1561,  tbSkillPos = {1762, 3150} , nStayTime = 2}},		
		[41] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1558,  tbSkillPos = {1762, 3150} , nStayTime = 3}},	
		},
	[2] = {
		[1] = {nOpt = tbNpc.OP_MSG_HEITIAO, tbInfo = {szMsg = "司仪义军首领白秋琳走上了典礼台。", nStayTime = 2}},	
		[2] = {nOpt = tbNpc.OP_MSG_INFOBOARD, tbInfo = {szMsg = "司仪已到场，各位来宾请到礼台周围来，典礼即将开始。", nStayTime = 1}},
		[3] = {nOpt = tbNpc.OP_MSG_CHANNEL, tbInfo = {szMsg = "司仪已到场，各位来宾请到礼台周围来，典礼即将开始。", nStayTime = 1}},
		[4] = {nOpt = tbNpc.OP_MSG_INFOBOARD, tbInfo = {szMsg = "幸福的篝火已点燃，典礼台周围的宾客将会获得巨额经验，快来啊。", nStayTime = 8}},			
		[5] = {nOpt = tbNpc.OP_MSG_INFOBOARD, tbInfo = {szMsg = "司仪已到场，各位来宾请到礼台周围来，典礼即将开始。", nStayTime = 1}},
		[6] = {nOpt = tbNpc.OP_MSG_CHANNEL, tbInfo = {szMsg = "司仪已到场，各位来宾请到礼台周围来，典礼即将开始。", nStayTime = 1}},
		[7] = {nOpt = tbNpc.OP_MSG_INFOBOARD, tbInfo = {szMsg = "幸福的篝火已点燃，典礼台周围的宾客将会获得巨额经验，快来啊。", nStayTime = 8}},		
		[8] = {nOpt = tbNpc.OP_MSG_INFOBOARD, tbInfo = {szMsg = "司仪已到场，各位来宾请到礼台周围来，典礼即将开始。", nStayTime = 1}},
		[9] = {nOpt = tbNpc.OP_MSG_CHANNEL, tbInfo = {szMsg = "司仪已到场，各位来宾请到礼台周围来，典礼即将开始。", nStayTime = 1}},
		[10] = {nOpt = tbNpc.OP_MSG_INFOBOARD, tbInfo = {szMsg = "幸福的篝火已点燃，典礼台周围的宾客将会获得巨额经验，快来啊。", nStayTime = 8}},			
		[11] = {nOpt = tbNpc.OP_MSG_FILM, tbInfo = {szMsg = "<npc=6656>：“诸位父老乡亲，义军的兄弟姐妹们。”<end><npc=6656>：“承蒙大家厚爱，有幸在这里为二位主持典礼。”<end><npc=6656>：“心情非常，非常激动。”<end><npc=6656>：“在义军众多兄弟姐妹中，他们俩都是出类拔萃，一表人才。”<end><npc=6656>：“只看那大侠相貌堂堂，玉树临风。”<end><npc=6656>：“又见那侠女闭月羞花，倾国倾城。”<end><npc=6656>：“他俩人必定是天造地设的一对璧人。”<end><npc=6656>：“列祖列宗在上，我白秋琳在此见证二位今日结为侠侣。”<end>", nStayTime = 1}},
		[12] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "诸位父老乡亲，义军的兄弟姐妹们。", nStayTime = 4}},
		[13] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "承蒙大家厚爱，有幸在这里为二位主持典礼。", nStayTime = 4}},
		[14] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "心情非常，非常激动。", nStayTime = 4}},
		[15] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "在义军众多兄弟姐妹中，他们俩都是出类拔萃，一表人才。", nStayTime = 4}},
		[16] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "只看这位大侠相貌堂堂，玉树临风。", nStayTime = 4}},
		[17] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "又见那边侠女闭月羞花，倾国倾城。", nStayTime = 4}},
		[18] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "他俩人必定是天造地设的一对璧人。", nStayTime = 4}},		
		[19] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "列祖列宗在上，我白秋琳在此见证二位今日结为侠侣。", nStayTime = 4}},
		[20] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "下面听我指示……", nStayTime = 3}},
		[21] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "一拜天地！", nStayTime = 1}},
		[22] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1560, tbSkillPos = {1603, 3170} , nStayTime = 2}},
		[23] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1559, tbSkillPos = {1603, 3170} , nStayTime = 3}},	
		[24] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "祝福二位大富大贵！", nStayTime = 1}},	
		[25] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1561, tbSkillPos = {1603, 3170} , nStayTime = 5}},		
		[26] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "二拜高堂！", nStayTime = 1}},
		[27] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1557, tbSkillPos = {1603, 3170} , nStayTime = 2}},
		[28] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1559, tbSkillPos = {1603, 3170} ,  nStayTime = 3}},	
		[29] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "祝福二位幸福美满！", nStayTime = 1}},
		[30] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1561, tbSkillPos = {1603, 3170} , nStayTime = 5}},	
		[31] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "侠侣对拜！", nStayTime = 1}},
		[32] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1556, tbSkillPos = {1603, 3170} ,  nStayTime = 2}},
		[33] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1559, tbSkillPos = {1603, 3170} ,  nStayTime = 3}},		
		[34] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "祝福二位永结同心！", nStayTime = 1}},
		[35] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1561, tbSkillPos = {1603, 3170} , nStayTime = 5}},	
		[36] = {nOpt = tbNpc.OP_MSG_FILM, tbInfo = {szMsg = "<npc=6656>：“下面我宣布，你二人正式结为侠侣。”<end><npc=6656>：“从今往后自当彼此尊重，相互扶持。”<end><npc=6656>：“白头偕老，相濡以沫，祝福你们。”<end>", nStayTime = 1}},
		[37] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "下面我宣布，你二人正式结为侠侣。", nStayTime = 4}},
		[38] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "从今往后自当彼此尊重，相互扶持。", nStayTime = 4}},
		[39] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "白头偕老，相濡以沫，祝福你们。", nStayTime = 4}},
		[40] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1561,  tbSkillPos = {1603, 3170} , nStayTime = 2}},		
		[41] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1558,  tbSkillPos = {1603, 3170} , nStayTime = 3}},	
		},
	[3] = {
		[1] = {nOpt = tbNpc.OP_MSG_HEITIAO, tbInfo = {szMsg = "司仪义军首领白秋琳走上了典礼台。", nStayTime = 2}},	
		[2] = {nOpt = tbNpc.OP_MSG_INFOBOARD, tbInfo = {szMsg = "司仪已到场，各位来宾请到礼台周围来，典礼即将开始。", nStayTime = 1}},
		[3] = {nOpt = tbNpc.OP_MSG_CHANNEL, tbInfo = {szMsg = "司仪已到场，各位来宾请到礼台周围来，典礼即将开始。", nStayTime = 1}},
		[4] = {nOpt = tbNpc.OP_MSG_INFOBOARD, tbInfo = {szMsg = "幸福的篝火已点燃，典礼台周围的宾客将会获得巨额经验，快来啊。", nStayTime = 8}},			
		[5] = {nOpt = tbNpc.OP_MSG_INFOBOARD, tbInfo = {szMsg = "司仪已到场，各位来宾请到礼台周围来，典礼即将开始。", nStayTime = 1}},
		[6] = {nOpt = tbNpc.OP_MSG_CHANNEL, tbInfo = {szMsg = "司仪已到场，各位来宾请到礼台周围来，典礼即将开始。", nStayTime = 1}},
		[7] = {nOpt = tbNpc.OP_MSG_INFOBOARD, tbInfo = {szMsg = "幸福的篝火已点燃，典礼台周围的宾客将会获得巨额经验，快来啊。", nStayTime = 8}},		
		[8] = {nOpt = tbNpc.OP_MSG_INFOBOARD, tbInfo = {szMsg = "司仪已到场，各位来宾请到礼台周围来，典礼即将开始。", nStayTime = 1}},
		[9] = {nOpt = tbNpc.OP_MSG_CHANNEL, tbInfo = {szMsg = "司仪已到场，各位来宾请到礼台周围来，典礼即将开始。", nStayTime = 1}},
		[10] = {nOpt = tbNpc.OP_MSG_INFOBOARD, tbInfo = {szMsg = "幸福的篝火已点燃，典礼台周围的宾客将会获得巨额经验，快来啊。", nStayTime = 8}},			
		[11] = {nOpt = tbNpc.OP_MSG_FILM, tbInfo = {szMsg = "<npc=6656>：“诸位父老乡亲，义军的兄弟姐妹们。”<end><npc=6656>：“承蒙大家厚爱，有幸在这里为二位侠侣主持典礼。”<end><npc=6656>：“心情非常，非常激动。”<end><npc=6656>：“在义军众多兄弟姐妹中，他们俩都是出类拔萃，一表人才。”<end><npc=6656>：“只看那大侠相貌堂堂，玉树临风。”<end><npc=6656>：“又见那侠女闭月羞花，倾国倾城。”<end><npc=6656>：“他俩人必定是天造地设的一对璧人。”<end><npc=6656>：“列祖列宗在上，我白秋琳在此见证二位今日结为侠侣。”<end>", nStayTime = 1}},
		[12] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "诸位父老乡亲，义军的兄弟姐妹们。", nStayTime = 4}},
		[13] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "承蒙大家厚爱，有幸在这里为二位主持典礼。", nStayTime = 4}},
		[14] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "心情非常，非常激动。", nStayTime = 4}},
		[15] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "在义军众多兄弟姐妹中，他们俩都是出类拔萃，一表人才。", nStayTime = 4}},
		[16] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "只看这位大侠相貌堂堂，玉树临风。", nStayTime = 4}},
		[17] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "又见那边侠女闭月羞花，倾国倾城。", nStayTime = 4}},
		[18] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "他俩人必定是天造地设的一对璧人。", nStayTime = 4}},		
		[19] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "列祖列宗在上，我白秋琳在此见证二位今日结为侠侣。", nStayTime = 4}},
		[20] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "下面听我指示……", nStayTime = 3}},
		[21] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "一拜天地！", nStayTime = 1}},
		[22] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1560, tbSkillPos = {1694, 3085} , nStayTime = 2}},
		[23] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1559, tbSkillPos = {1694, 3085} , nStayTime = 3}},	
		[24] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "祝福二位大富大贵！", nStayTime = 1}},	
		[25] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1561, tbSkillPos = {1694, 3085} , nStayTime = 5}},		
		[26] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "二拜高堂！", nStayTime = 1}},
		[27] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1557, tbSkillPos = {1694, 3085} , nStayTime = 2}},
		[28] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1559, tbSkillPos = {1694, 3085} ,  nStayTime = 3}},	
		[29] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "祝福二位幸福美满！", nStayTime = 1}},
		[30] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1561, tbSkillPos = {1694, 3085} , nStayTime = 5}},	
		[31] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "侠侣对拜！", nStayTime = 1}},
		[32] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1556, tbSkillPos = {1694, 3085} ,  nStayTime = 2}},
		[33] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1559, tbSkillPos = {1694, 3085} ,  nStayTime = 3}},		
		[34] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "祝福二位永结同心！", nStayTime = 1}},
		[35] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1561, tbSkillPos = {1694, 3085} , nStayTime = 5}},	
		[36] = {nOpt = tbNpc.OP_MSG_FILM, tbInfo = {szMsg = "<npc=6656>：“下面我宣布，你二人正式结为侠侣。”<end><npc=6656>：“从今往后自当彼此尊重，相互扶持。”<end><npc=6656>：“白头偕老，相濡以沫，祝福你们。”<end>", nStayTime = 1}},
		[37] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "下面我宣布，你二人正式结为侠侣。", nStayTime = 4}},
		[38] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "从今往后自当彼此尊重，相互扶持。", nStayTime = 4}},
		[39] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "白头偕老，相濡以沫，祝福你们。", nStayTime = 4}},
		[40] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1561,  tbSkillPos = {1694, 3085} , nStayTime = 2}},		
		[41] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1558,  tbSkillPos = {1694, 3085} , nStayTime = 3}},	
		},
	[4] = {
		[1] = {nOpt = tbNpc.OP_MSG_HEITIAO, tbInfo = {szMsg = "司仪义军首领白秋琳走上了典礼台。", nStayTime = 2}},	
		[2] = {nOpt = tbNpc.OP_MSG_INFOBOARD, tbInfo = {szMsg = "司仪已到场，各位来宾请到礼台周围来，典礼即将开始。", nStayTime = 1}},
		[3] = {nOpt = tbNpc.OP_MSG_CHANNEL, tbInfo = {szMsg = "司仪已到场，各位来宾请到礼台周围来，典礼即将开始。", nStayTime = 1}},
		[4] = {nOpt = tbNpc.OP_MSG_INFOBOARD, tbInfo = {szMsg = "幸福的篝火已点燃，典礼台周围的宾客将会获得巨额经验，快来啊。", nStayTime = 8}},			
		[5] = {nOpt = tbNpc.OP_MSG_INFOBOARD, tbInfo = {szMsg = "司仪已到场，各位来宾请到礼台周围来，典礼即将开始。", nStayTime = 1}},
		[6] = {nOpt = tbNpc.OP_MSG_CHANNEL, tbInfo = {szMsg = "司仪已到场，各位来宾请到礼台周围来，典礼即将开始。", nStayTime = 1}},
		[7] = {nOpt = tbNpc.OP_MSG_INFOBOARD, tbInfo = {szMsg = "幸福的篝火已点燃，典礼台周围的宾客将会获得巨额经验，快来啊。", nStayTime = 8}},		
		[8] = {nOpt = tbNpc.OP_MSG_INFOBOARD, tbInfo = {szMsg = "司仪已到场，各位来宾请到礼台周围来，典礼即将开始。", nStayTime = 1}},
		[9] = {nOpt = tbNpc.OP_MSG_CHANNEL, tbInfo = {szMsg = "司仪已到场，各位来宾请到礼台周围来，典礼即将开始。", nStayTime = 1}},
		[10] = {nOpt = tbNpc.OP_MSG_INFOBOARD, tbInfo = {szMsg = "幸福的篝火已点燃，典礼台周围的宾客将会获得巨额经验，快来啊。", nStayTime = 8}},			
		[11] = {nOpt = tbNpc.OP_MSG_FILM, tbInfo = {szMsg = "<npc=6656>：“诸位父老乡亲，义军的兄弟姐妹们。”<end><npc=6656>：“承蒙大家厚爱，有幸在这里为二位主持典礼。”<end><npc=6656>：“心情非常，非常激动。”<end><npc=6656>：“在义军众多兄弟姐妹中，他们俩都是出类拔萃，一表人才。”<end><npc=6656>：“只看那大侠相貌堂堂，玉树临风。”<end><npc=6656>：“又见那侠女闭月羞花，倾国倾城。”<end><npc=6656>：“他们必定是天造地设的一对璧人。”<end><npc=6656>：“列祖列宗在上，我白秋琳在此见证二位今日结为侠侣。”<end>", nStayTime = 1}},
		[12] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "诸位父老乡亲，义军的兄弟姐妹们。", nStayTime = 4}},
		[13] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "承蒙大家厚爱，有幸在这里为二位主持典礼。", nStayTime = 4}},
		[14] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "心情非常，非常激动。", nStayTime = 4}},
		[15] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "在义军众多兄弟姐妹中，他们俩都是出类拔萃，一表人才。", nStayTime = 4}},
		[16] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "只看这位大侠相貌堂堂，玉树临风。", nStayTime = 4}},
		[17] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "又见那边侠女闭月羞花，倾国倾城。", nStayTime = 4}},
		[18] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "他俩人必定是天造地设的一对璧人。", nStayTime = 4}},		
		[19] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "列祖列宗在上，我白秋琳在此见证二位今日结为侠侣。", nStayTime = 4}},
		[20] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "下面听我指示……", nStayTime = 3}},
		[21] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "一拜天地！", nStayTime = 1}},
		[22] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1560, tbSkillPos = {1591, 3216} , nStayTime = 2}},
		[23] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1559, tbSkillPos = {1591, 3216} , nStayTime = 3}},	
		[24] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "祝福二位大富大贵！", nStayTime = 1}},	
		[25] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1561, tbSkillPos = {1591, 3216} , nStayTime = 5}},		
		[26] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "二拜高堂！", nStayTime = 1}},
		[27] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1557, tbSkillPos = {1591, 3216} , nStayTime = 2}},
		[28] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1559, tbSkillPos = {1591, 3216} ,  nStayTime = 3}},	
		[29] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "祝福二位幸福美满！", nStayTime = 1}},
		[30] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1561, tbSkillPos = {1591, 3216} , nStayTime = 5}},	
		[31] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "侠侣对拜！", nStayTime = 1}},
		[32] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1556, tbSkillPos = {1591, 3216} ,  nStayTime = 2}},
		[33] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1559, tbSkillPos = {1591, 3216} ,  nStayTime = 3}},		
		[34] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "祝福二位永结同心！", nStayTime = 1}},
		[35] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1561, tbSkillPos = {1591, 3216} , nStayTime = 5}},	
		[36] = {nOpt = tbNpc.OP_MSG_FILM, tbInfo = {szMsg = "<npc=6656>：“下面我宣布，你二人正式结为侠侣。”<end><npc=6656>：“从今往后自当彼此尊重，相互扶持。”<end><npc=6656>：“白头偕老，相濡以沫，祝福你们。”<end>", nStayTime = 1}},
		[37] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "下面我宣布，你二人正式结为侠侣。", nStayTime = 4}},
		[38] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "从今往后自当彼此尊重，相互扶持。", nStayTime = 4}},
		[39] = {nOpt = tbNpc.OP_MSG_CHAT, tbInfo = {szMsg = "白头偕老，相濡以沫，祝福你们。", nStayTime = 4}},
		[40] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1561,  tbSkillPos = {1591, 3216} , nStayTime = 2}},		
		[41] = {nOpt = tbNpc.OP_SKILL, tbInfo = {nSkillId = 1558,  tbSkillPos = {1591, 3216} , nStayTime = 3}},	
		},
	};

--====================================================

function tbNpc:GetOptList(nWeddingMapLevel)
	return self.tbOpt[nWeddingMapLevel] or {};
end

function tbNpc:GetZhenghunNpc(nMapId)
	local nNpcId = Marry:GetWithnessesId(nMapId);
	return KNpc.GetById(nNpcId);
end

function tbNpc:GetCurStep(nMapId)
	local pNpc = self:GetZhenghunNpc(nMapId);
	if (not pNpc) then
		return 0;
	end
	
	local tbNpcData = pNpc.GetTempTable("Marry") or {};
	return tbNpcData.nCurZhenghunStep or 0;
end

function tbNpc:AddCurStep(nMapId)
	local pNpc = self:GetZhenghunNpc(nMapId);
	if (not pNpc) then
		return 0;
	end
	
	local tbNpcData = pNpc.GetTempTable("Marry") or {};
	tbNpcData.nCurZhenghunStep = tbNpcData.nCurZhenghunStep or 0;
	tbNpcData.nCurZhenghunStep = tbNpcData.nCurZhenghunStep + 1;
end

-- 证婚人开始活动
function tbNpc:Start(nMapId, nWeddingMapLevel, tbCoupleName)
	local tbOptList = self:GetOptList(nWeddingMapLevel);
	if (#tbOptList == 0) then
		return 0;
	end

	Marry:SetPerformState(nMapId, 1);
	Timer:Register(1, self.NextStep, self, nMapId, tbOptList, tbCoupleName);
end

function tbNpc:NextStep(nMapId, tbOptList, tbCoupleName)
	local nCurStep = self:GetCurStep(nMapId);
	if (0 == nCurStep) then
		Marry:SetPerformState(nMapId, 0);
		local tbNpc = Npc:GetClass("marry_jixiang");
		tbNpc:Marry(tbCoupleName, nMapId);
		return 0;
	end
	
	local tbCurOptInfo = tbOptList[nCurStep];
	if (not tbCurOptInfo) then
		Marry:SetPerformState(nMapId, 0);
		local tbNpc = Npc:GetClass("marry_jixiang");
		tbNpc:Marry(tbCoupleName, nMapId);
		return 0;
	end
	
	local nStayTime = self:DoOpt(nMapId, tbCurOptInfo);
	self:AddCurStep(nMapId);
	if (nStayTime == 0) then
		nStayTime = 1;
	end
	if (not self.nPlayTime) then
		self.nPlayTime = 1;
	end
	self.nPlayTime = self.nPlayTime + nStayTime;
	return nStayTime;
end

function tbNpc:DoOpt(nMapId, tbCurOptInfo)
	local nStayTime = 0;
	local nOpt = tbCurOptInfo.nOpt;
	if (self.OP_MSG_CHAT == nOpt) then
		nStayTime = self:Play_SendChat(nMapId, tbCurOptInfo.tbInfo);
	elseif (self.OP_MSG_FILM == nOpt) then
		nStayTime = self:Play_Film(nMapId, tbCurOptInfo.tbInfo);
	elseif (self.OP_MSG_HEITIAO == nOpt) then
		nStayTime = self:Play_Heitiao(nMapId, tbCurOptInfo.tbInfo);
	elseif (self.OP_MSG_CHANNEL == nOpt) then
		nStayTime = self:Play_Channel(nMapId, tbCurOptInfo.tbInfo);
	elseif (self.OP_MSG_INFOBOARD == nOpt) then
		nStayTime = self:Play_InfoBordMsg(nMapId, tbCurOptInfo.tbInfo);
	elseif (self.OP_SKILL == nOpt) then
		nStayTime = self:Play_CastSkill(nMapId, tbCurOptInfo.tbInfo);
	end
	return nStayTime * Env.GAME_FPS;
end

function tbNpc:GetAllPlayers(nMapId)
	local tbPlayerList = Marry:GetAllPlayers(nMapId) or {};
	return tbPlayerList;
end

-- 表演（头顶上说话）
function tbNpc:Play_SendChat(nMapId, tbCurInfo)
	local pNpc = self:GetZhenghunNpc(nMapId);
	if (pNpc) then
		pNpc.SendChat(tbCurInfo.szMsg);
	end
	return tbCurInfo.nStayTime;
end

-- 表演（电影模式）
function tbNpc:Play_Film(nMapId, tbCurInfo)
	local tbPlayerList = self:GetAllPlayers(nMapId);
	for _, pPlayer in pairs(tbPlayerList) do
		Setting:SetGlobalObj(pPlayer);
		TaskAct:Talk(tbCurInfo.szMsg);
		Setting:RestoreGlobalObj();
	end
	return tbCurInfo.nStayTime;
end

-- 表演（黑条信息）
function tbNpc:Play_Heitiao(nMapId, tbCurInfo)
	local tbPlayerList = self:GetAllPlayers(nMapId);
	for _, pPlayer in pairs(tbPlayerList) do
		Dialog:SendBlackBoardMsg(pPlayer, tbCurInfo.szMsg);
	end
	return tbCurInfo.nStayTime;
end

-- 表演（聊天频道信息）
function tbNpc:Play_Channel(nMapId, tbCurInfo)
	local tbPlayerList = self:GetAllPlayers(nMapId);
	local pNpc = self:GetZhenghunNpc(nMapId);
	for _, pPlayer in pairs(tbPlayerList) do
		Setting:SetGlobalObj(pPlayer);
		me.Msg(tbCurInfo.szMsg, pNpc.szName);
		Setting:RestoreGlobalObj();
	end
	return tbCurInfo.nStayTime;
end

-- 表演（屏幕中央信息）
function tbNpc:Play_InfoBordMsg(nMapId, tbCurInfo)
	local tbPlayerList = self:GetAllPlayers(nMapId);
	local szMsg = string.format("<color=yellow>%s<color>", tbCurInfo.szMsg)
	for _, pPlayer in pairs(tbPlayerList) do
		Dialog:SendInfoBoardMsg(pPlayer, szMsg);
	end
	return tbCurInfo.nStayTime;
end

-- 表演（释放技能）
function tbNpc:Play_CastSkill(nMapId, tbCurInfo)
	local pNpc = self:GetZhenghunNpc(nMapId);
	local nSkillLevel = tbCurInfo.nSkillLevel or 1;
	if (pNpc) then
		pNpc.CastSkill(tbCurInfo.nSkillId, nSkillLevel, unpack(tbCurInfo.tbSkillPos));
	end
	return tbCurInfo.nStayTime;
end

--=============================================================================

-- 玩家点击证婚人触发的对话
function tbNpc:OnDialog()
	local szMsg = "你可以从这里领取侠侣信物。也可以去江津村找老月领取。";
	local tbOpt = {
		{"领取侠侣信物", self.GetWeddingRing, self},
		{"一会再说吧"},
		};
		
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:GetWeddingRing()
	local tbYuelao = Npc:GetClass("marry_yuelao");
	tbYuelao:GetWeddingRing()
end
