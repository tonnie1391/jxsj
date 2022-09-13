----------------------------------------------------------------
	--FileName:	define.lua
	--Eider:	zhouchenfei
	--Date:		2007-10-23
	--Comment:	战场头文件
	--			功能：战场相关信息定义
----------------------------------------------------------------

-- 计时器相关
if (EventManager.IVER_bOpenTiFu == 1) then
	Battle.TIMER_SIGNUP		= Env.GAME_FPS * 60 * 5;	-- 报名时间（等待开局时间）
	Battle.TIMER_SIGNUP_MSG	= Env.GAME_FPS * 60 * 2;	-- 报名期间的广播消息
else
	Battle.TIMER_SIGNUP		= Env.GAME_FPS * 60 * 10;	-- 报名时间（等待开局时间）
	Battle.TIMER_SIGNUP_MSG	= Env.GAME_FPS * 60 * 5;	-- 报名期间的广播消息
end

Battle.TIMER_GAME		= Env.GAME_FPS * 60 * 50;	-- 比赛时间（等待比赛结束时间）
Battle.TIMER_GAME_MSG	= Env.GAME_FPS * 20;		-- 比赛期间的广播消息
Battle.TIMER_SYNCDATA	= Env.GAME_FPS * 10;		-- 比赛期间的同步客户端数据
Battle.TIMER_SYNCNPCHIGH= Env.GAME_FPS * 2;

Battle.TIME_DEATHWAIT	= 10;	-- 死亡后需要在后营等待的秒数
Battle.TIME_PLAYER_STAY = 120;	-- 在后营最多可待120秒
Battle.TIME_PALYER_LIVE = 60;	-- 60秒死相时间

Battle.SZITEMFILE = "\\setting\\battle\\songjin\\battleitem.txt";

Battle.ITEM_DROP_PROP = "\\setting\\battle\\songjin\\battleitemdrop.txt";

Battle.nTimes = 1;   	--平台开启奖励倍数

Battle.CAMPID_NEUTRAL = 0; -- 中立ID;
Battle.CAMPID_SONG	= 1;	-- 宋方ID;
Battle.CAMPID_JIN	= 2;	-- 金方ID;

Battle.LEVEL_LIMIT	= { 59, 60, 200 };		-- 进不同战场需要的等级

Battle.NAME_GAMELEVEL	= {"", "", ""}		-- 战场名
Battle.NAME_CAMP		= {"Mông Cổ", "Tây Hạ"};								-- 阵营名

Battle.NPCCAMP_MAP		= {1, 2};									-- 宋金双方的NPC阵营（颜色）

Battle.NPCID_WUPINBAOGUANYUAN		= 2599;					-- 储物箱ID
Battle.NPCID_SONGWUPINBAOGUANREN	= 2599;					-- 储物箱ID 
Battle.NPCID_JINWUPINBAOGUANREN		= 2599;					-- 储物箱ID
Battle.tbNPCID_CAMPHOUYINGJUNYIGUAN	= {2613, 2614};			-- 军需官ID
Battle.tbAWARDBOUNS					= {3000, 1500};			-- 根据积分奖励物品的积分等级
Battle.tbRANKSHENGWANG				= {400,320,280,240};	-- 排名段相关的声望奖励
Battle.tbEffectNPC					= {2350, 2351};
Battle.tbBOUNSSHENGWANG				= {
		{5000, 280},
		{4000, 240},
		{3000, 200},
		{2500, 160},
		{2000, 130},
		{1500, 100},
		{1000, 80},
		{500, 60},
	};	
	
Battle.tbRANKHONOR				= {45,40,35,30};	-- 排名段相关的荣誉奖励
Battle.tbBOUNSHONOR				= {
		{6000, 25},
		{5000, 20},
		{4000, 15},
		{3000, 10},
		{2000, 6},
		{1000, 3},
	};

Battle.NUM_TO_DROP_BOUNS = {
	[1] = {40, 7500},
	[2] = {60, 12000},
	[3] = {80, 15000},
	[4] = {120, 20000},
	[5] = {160, 30000},
};

Battle.FLAG_OPEN_DROP_ITEM = {
	[0] = 0,
	[1] = 0,
	[2] = 0,
	[3] = 0,
	[5] = 1,
};


-- 战场人数计数用全局任务变量ID
if (EventManager.IVER_bOpenTiFu == 1) then
	Battle.DBTASKID_PLAYER_COUNT	= {
		[1] = {
				{DBTASK_BATTLE_PLCNT_LEVEL1_SONG1, DBTASK_BATTLE_PLCNT_LEVEL1_JIN1},
				{DBTASK_BATTLE_PLCNT_LEVEL1_SONG2, DBTASK_BATTLE_PLCNT_LEVEL1_JIN2},
				{DBTASK_BATTLE_PLCNT_LEVEL1_SONG3, DBTASK_BATTLE_PLCNT_LEVEL1_JIN3},
			},
		[2] = {
				{DBTASK_BATTLE_PLCNT_LEVEL2_SONG1, DBTASK_BATTLE_PLCNT_LEVEL2_JIN1},
				{DBTASK_BATTLE_PLCNT_LEVEL2_SONG2, DBTASK_BATTLE_PLCNT_LEVEL2_JIN2},
				{DBTASK_BATTLE_PLCNT_LEVEL2_SONG3, DBTASK_BATTLE_PLCNT_LEVEL2_JIN3},
			},
		[3] = {
				{DBTASK_BATTLE_PLCNT_LEVEL3_SONG1, DBTASK_BATTLE_PLCNT_LEVEL3_JIN1},
				{DBTASK_BATTLE_PLCNT_LEVEL3_SONG2, DBTASK_BATTLE_PLCNT_LEVEL3_JIN2},
				{DBTASK_BATTLE_PLCNT_LEVEL3_SONG3, DBTASK_BATTLE_PLCNT_LEVEL3_JIN3},
			},
	};
else
	Battle.DBTASKID_PLAYER_COUNT	= {
		[1] = {
				{DBTASK_BATTLE_PLCNT_LEVEL1_SONG1, DBTASK_BATTLE_PLCNT_LEVEL1_JIN1},
				{DBTASK_BATTLE_PLCNT_LEVEL1_SONG2, DBTASK_BATTLE_PLCNT_LEVEL1_JIN2},
				{DBTASK_BATTLE_PLCNT_LEVEL1_SONG3, DBTASK_BATTLE_PLCNT_LEVEL1_JIN3},
			},
		[2] = {
				{DBTASK_BATTLE_PLCNT_LEVEL2_SONG1, DBTASK_BATTLE_PLCNT_LEVEL2_JIN1},
				{DBTASK_BATTLE_PLCNT_LEVEL2_SONG2, DBTASK_BATTLE_PLCNT_LEVEL2_JIN2},
			},
		[3] = {
				{DBTASK_BATTLE_PLCNT_LEVEL3_SONG1, DBTASK_BATTLE_PLCNT_LEVEL3_JIN1},
				{DBTASK_BATTLE_PLCNT_LEVEL3_SONG2, DBTASK_BATTLE_PLCNT_LEVEL3_JIN2},
			},
	};
end

Battle.tbNPCNAMETOID				= 	{							-- 阵营拼音和数字转换
											["song"] 	= Battle.CAMPID_SONG,
											["jin"]		= Battle.CAMPID_JIN,
										};		

-- 比赛结果
Battle.RESULT_WIN	= 1;											-- 宋方获胜
Battle.RESULT_TIE	= 0;											-- 平局
Battle.RESULT_LOSE	= -1;											-- 金方获胜

Battle.tbBTPLNUM_LOWBOUND	= {4, 4, 4};							-- 战场开战双方最少人数下限
if EventManager.IVER_bOpenTiFu == 1 then
	Battle.tbBTPLNUM_LOWBOUND	= {15, 15, 15};							-- 战场开战双方最少人数下限
end
Battle.BTPLNUM_HIGHBOUND	= 100;									-- 双方阵营限定参战最大人数
Battle.BTPLNUM_NUMDIF		= 3;									-- 双方平衡人数最大差
Battle.BTPLJUNXUDIAN		= 3;								 	-- 领取军需次数
Battle.BTPLJUNXUTIMEOUT		= 24 * 60 * 60 * 7;						-- 军需使用时限,按天数算
Battle.BTPLWEIWANGLIMIT		= 30;									-- 威望周最大值
Battle.BOUNS2EXPMUL			= 1000;
Battle.tbWeiWangRank		= {1,10,20};							-- 宋金奖励威望的排名

Battle.SKILL_DAMAGEDEFENCE_ID = 395;								-- 战意技能id
Battle.SKILL_DAMAGEDEFENCE_TIME	= Env.GAME_FPS * 60 * 3;			-- 战意时间

Battle.SKILL_FORBID_ID		= 122;

Battle.POINT_ADD_MAP	= {
	[Battle.RESULT_WIN]		= 1200,									-- 胜方获得积分
	[Battle.RESULT_TIE]		= 900,									-- 平局获得积分
	[Battle.RESULT_LOSE]	= 600,									-- 败方获得积分
};

Battle.POINT_LIMIT_MAP = { 20000, 30000, 40000 };

Battle.BATTLES_POINT2EXP_MAXEXP	= 500000;			--每周允许兑换的经验上限

Battle.RULE_PROTECTFLAG_CHANGESKILL		= 1160;		-- 护旗模式更换模型
Battle.RULE_PROTECTFLAG_CHANGERIGHTSKILL= 1161;		-- 护旗模式下右键技能要换成这个技能

Battle.tbPOINT_TIMES_SHARETEAM = {1, 1, 1, 1, 1, 1};		-- 9屏内同队玩家数量下的共享积分比例
Battle.tbPOINT_TIMES_SHAREFACTION = {									-- 9屏内同队玩家积分奖励
			[1] = {
					[1] = 0,			-- 刀少林
					[2]	= 0,			-- 拳少林
					[3] = 0, 			-- 棍少林
				},
			[2]	= {
					[1] = 0,			-- 刀天王
					[2] = 0, 			-- 枪天王
					[3] = 0, 			-- 锤天王
				},
			[3] = {
					[1] = 0,			-- 飞刀唐门
					[2] = 0,			-- 袖箭唐门
					[3] = 0,			-- 飞镖唐门
				},
			[4] = {
					[1] = 0,			-- 刀五毒
					[2] = 0, 			-- 掌五毒
					[3] = 0, 			-- 诅咒五毒
				},
			[5] = {
					[1] = 0,			-- 掌峨嵋
					[2]	= 0,			-- 剑峨嵋
					[3] = 0, 			-- 辅助峨嵋
				},
			[6]	= {
					[1] = 0,			-- 剑翠烟
					[2] = 0, 			-- 刀翠烟
			--		[3] = 1, 			
				},
			[7] = {
					[1] = 0,			-- 掌丐
					[2] = 0,			-- 棍丐帮
			--		[3] = 1,			
				},
			[8] = {
					[1] = 0,			-- 战天忍
					[2] = 0, 			-- 魔天忍
					[3] = 0, 			-- 诅咒天忍
				},
			[9] = {
					[1] = 0,			-- 气武当
					[2] = 0,			-- 剑武当
			--		[3] = 1,			
				},
			[10] = {
					[1] = 0,			-- 刀昆仑
					[2] = 0, 			-- 辅助昆仑
			--		[3] = 1, 			
				},
			[11] = {
					[1] = 0,			-- 气武当
					[2] = 0,			-- 剑武当
			--		[3] = 1,			
				},
			[12] = {
					[1] = 0,			-- 刀昆仑
					[2] = 0, 			-- 辅助昆仑
			--		[3] = 1, 			
				},
	};

-- 阵营、等级对应的报名点地图ID		[nCampId][nLevel]	= nMapId;
if (EventManager.IVER_bOpenTiFu == 1) then
	Battle.MAPID_LEVEL_CAMP	=	{
		-- 宋	金
		[1] = { {181, 184}, {257, 260}, {282, 283} },	-- 初级(扬州)
		[2]	= { {182, 185}, {258, 261}, {288,289}},	-- 中级(凤翔)
		[3]	= { {183, 186}, {259, 262} },	-- 高级(襄阳)
	};
else
	Battle.MAPID_LEVEL_CAMP	=	{
		-- 宋	金
		[1] = { {181, 184}, {257, 260}, {282, 283} },	-- 初级(扬州)
		[2]	= { {182, 185}, {258, 261} },	-- 中级(凤翔)
		[3]	= { {183, 186}, {259, 262} },	-- 高级(襄阳)
	};
end
-- 报名点坐标点
Battle.POS_SIGNUP	= {
	{1671, 3281},
	{1672, 3305},
	{1688, 3306},
};

Battle.tbPaiItemId	= { 1, 2, 3 };

Battle.MAXLISTNUM		= 10;										-- 排行榜最大输出人数

--角色战场记录
Battle.TSKG_BATTLE					= 3;
Battle.TSKGID						= 2001;							-- 任务变量GroupId
Battle.TASKID_BTCAMP				= 1;							-- 战场阵营
Battle.TSK_BTPLAYER_LASTBOUNSTIME	= 2;							-- 最近一次积分清零时间
Battle.TSK_BTPLAYER_TOTALBOUNS		= 3;							-- 累加积分
Battle.TSK_BTPLAYER_LASTMAXGONG		= 4;							-- 最近一次最大功勋值
Battle.TSK_BTPLAYER_TOTALGONG		= 5;							-- 累加功勋值
Battle.TSK_BTPLAYER_LASTGONGTIME	= 6;							-- 最近一次功勋更新时间
Battle.TSK_BTPLAYER_KEY				= 7;							-- 战场ID
Battle.TSK_BTPLAYER_USEBOUNS		= 8;							-- 使用积分记录
Battle.TSK_BTPLAYER_JUNXU			= 9;							-- 每日领取军需使用情况
Battle.TSK_BTPLAYER_LASTWEIWANGTIME	= 10;							-- 上次威望清零的时间
Battle.TSK_BTPLAYER_LIMITWEIWANG	= 11;							-- 周威望累积值
Battle.TSK_BTPLAYER_ZHANCHANGLINGPAI= 12;							-- 标记参加过战场的玩家是否没拿过战场令牌
Battle.TSK_BTPLAYER_FUDAI			= 13;							-- 标记福袋是否拿过
Battle.TSK_BTPLAYER_BOUNSFORWARD	= 14;							-- 标记积分是否已经兑换或存在积分兑换
Battle.TSK_BTPLAYER_HONOR1			= 15;							-- 记录参加最高的四次荣誉
Battle.TSK_BTPLAYER_HONOR2			= 16;
Battle.TSK_BTPLAYER_HONOR3			= 17;
Battle.TSK_BTPLAYER_HONOR4			= 18;
Battle.TSK_BTPLAYER_BOUNS_TOTAL_WEEK		= 19;					-- 本周累积积分
Battle.TSK_BTPLAYER_BOUNS_TOTAL_RETIME		= 20;					-- 重新刷新本周积分时间
Battle.TSK_BTPLAYER_BOUNS_TOTAL_USE_WEEK	= 21;					-- 已经兑换了本周积分
Battle.TSK_BTPLAYER_DAY_JOIN_COUNT			= 22;					-- 已经兑换了本周积分
Battle.TSK_BTPLAYER_AWARDRANK				= 23;

Battle.DBTASK_SONGJIN_BOUNS_MAX		= DBTASK_SONGJIN_BOUNS_MAX;		-- 每周最大宋金积分
Battle.DBTASK_SONGJIN_BOUNS_MAX_AWARDPLAYER	= DBTASK_SONGJIN_BOUNS_MAX_AWARDPLAYER; -- 周积分最高者的名单
Battle.DBTASK_SONGJIN_BOUNS_MAX_AWARDPLAYER_REFRESH_TIME = DBTASK_SONGJIN_BOUNS_MAX_AWARDPLAYER_REFRESH_TIME; -- 刷新周积分冠军的时间
Battle.UPDATE_MAX_WEEK_BOUNS_DAY	= 1;

Battle.tbBonusBase = {				-- 积分信息
	KILLPLAYER = 75,
	SNAPFLAG = 600,
	KILLNPC = 1,
	MAXSERIESKILL = 150,
	GETITEM = 25
};

Battle.tbTemplateId2Skill = {1632, 1639, 1634, 1641};
Battle.DEF_DEL_ZHANSHEN_SKILL_DEADLINE = 20110701;
	
Battle.SERIESKILLBOUNS	= 150;
if EventManager.IVER_bOpenTiFu == 1 then
	Battle.SERIESKILLBOUNS	= 15;
end
Battle.TAB_RANKBONUS = {0, -1, 1000, -1, 3000, -1, 6000, -1, 10000, -1};	--各等级官衔所需积分

Battle.NAME_RANK	= {
	"<color=white>Binh sĩ<color>", 
	"<color=white>Dũng sĩ<color>",
	"<color=0xa0ff>Hiệu úy<color>", 
	"<color=0xa0ff>Đô úy<color>",
	"<color=yellow>Thống lĩnh<color>",
	"<color=yellow>Chính tướng<color>",
	"<color=0xff>Phó tướng<color>",  
	"<color=0xff>Thống chế<color>",
	"<color=yellow><bclr=red>Đại tướng<bclr><color>", 
	"<color=yellow><bclr=red>Nguyên soái<bclr><color>",
};

Battle.tbSHENGWANGRANK	= 	{
								{1, 100},
								{4, 80},
								{8, 70},
								{16, 60},
								{32, 50},
								{64, 40},
								{500, 30},
							};
Battle.tbGONGXUNRANK	= 	{
								{1, 100},
								{4, 80},
								{8, 70},
								{16, 60},
								{32, 50},
								{64, 40},
								{500, 30},
							};
							
Battle.tbBOUNSTIMESRANK	=	{
								{5, 1.5},
								{10, 1.4},
								{20, 1.3},
								{40, 1.2},
								{60, 1.1},
								{500, 1},
							};
--以下是某些值记录在MissionValue中的索引位置，通过GetMissionV(MS_XXX)来获得实际的值

Battle.tbCampDialog		= 	{
		[Battle.CAMPID_SONG]	=	{
										"Hiện nay quân ta sung mãn đủ sức tiêu diệt quân Kim, sau này còn nhiều cơ hội trở tài, ngươi hãy gắng chờ đợi!",
										"Tục ngữ có câu: Thiên hạ hưng vong, thất phu hữu trách. Người Kim xua quân xâm lược là thời cơ để ta báo đáp nước nhà, chỉ cần đẳng cấp trên <color=green>%d<color>. Ngoài ra mỗi ngày các ngươi đều được nhận 1 lượng Quân nhu nhất định, phục vụ tác chiến!",
										"Xin chào, hoan nghênh gia nhập quân Tống, hiện quân Kim chưa xuất hiện, mọi người cứ nghỉ ngơi. Khi có tiếng tù, trận chiến sẽ bắt đầu. Có thể tổ đội với người khác để chiến đấu hiệu quả hơn.",
										"Thiên hạ hưng vong, thất phu hữu trách. Đây là thời cơ để ta báo đáp nước nhà. Trong chiến đấu, có thể tổ đội với nhau, hiệu quả gấp bội.",
										"Người Kim xâm lược nước ta, giết đồng bào ta, quả thật đáng ghét, ta thề quyết đấu với các ngươi đến cùng!",
										"Quan Quân Nhu: Nếu ngươi đã quyết định báo đáp nước nhà, diệt trừ giặc Kim, mỗi ngày đều có thể đến đây nhận thưởng Quân nhu, phục vụ tác chiến!",
										"Trông ngươi lén lút gian xảo, chắc chắn là gian tế nước Kim. Người đâu, mau bắt lấy hắn!",
										"Bạn đã gia nhập <color=yellow>%s%s<color> của quân <color=orange>%s<color>, lần sau lại đến vậy!"
									}, 
		[Battle.CAMPID_JIN]		=	{
										"Hiện nay quân ta sung mãn đủ sức diệt trừ quân Tống, sau này còn nhiều cơ hội trở tài, ngươi hãy gắng chờ đợi!",
										"Hỡi dũng sĩ Kim quốc, hãy giúp sức tiêu diệt quân Tống, giúp đại Kim ta hoàn thành đại nghiệp, chỉ cần trên cấp <color=green>%d<color>. Ngoài ra, mỗi ngày các ngươi còn được nhận Quân nhu phục vụ tác chiến!",
										"Xin chào, hoan nghênh gia nhập quân Kim, hiện quân Tống chưa xuất hiện, mọi người cứ nghỉ ngơi. Khi có tiếng tù, trận chiến sẽ bắt đầu. Có thể tổ đội với nhau, hiệu quả gấp bội.",
										"Thề chết tận trung với đại Kim! Hãy xông lên, hỡi các dũng sĩ! Trong chiến đấu, có thể tổ đội với nhau, hiệu quả gấp bội.",
										"Tướng sĩ nước Kim ta dũng mãnh thiện chiến, đâu thể đem so với lũ bạc nhược các ngươi!",
										"Quan Quân Nhu: Các dũng sĩ nước Kim, nếu đã tham gia hàng ngũ tiêu diệt đại Tống, mỗi ngày các ngươi đều được nhận 1 lượng Quân nhu phục vụ tác chiến!",
										"Bọn Nam Di to gan dám xâm phạm lãnh thổ đại Kim, đúng là chán sống mà!",
										"Bạn đã gia nhập <color=yellow>%s%s<color> của quân <color=purple>%s<color>, lần sau lại đến vậy!",
									},
							};
							
Battle.tbZhaomushiCampDialog = {
	"Triệu Nguyên Tịnh: Gần đây đại Tống có ý Bắc phạt, thu phục Trung Nguyên, nay hai quân đang đối đầu tại biên ải, Mộ Binh Lệnh đã truyền đi khắp nơi, ta đang định chiêu mộ nhân sĩ võ lâm, trợ giúp quân Tống khôi phục sơn hà.",
	"Hoàn Nhan Long Húc: Gần đây nước Tống lắm kẻ tiểu nhân, không tự lượng sức ý đồ chống đối đại Kim ta. Người học võ như các ngươi ở lại nước Tống cũng vô ích, chi bằng đầu quân đại Kim để được thỏa chí tung hoành.",
};

Battle.tbPlayerReply2Zhaomushi	= {
	{
		"Sự việc không thể chậm trễ, ta đang định đến <color=orange>báo danh chiến trường_Tống (%s%s).",
		"Ta tài hèn sức mọn, đợi khi tinh thông võ nghệ sẽ đến giúp ngươi."
	},
	{
		"Huynh đài nói phải lắm, ta đang định đến <color=purple>báo danh chiến trường_Kim (%s%s).",
		"Để ta về bàn bạc lại, sẽ trả lời sau.",
	},
}

Battle.MSG_CAMP_RESULT	= {
	[Battle.RESULT_WIN]		= "%s kết thúc. Quân %s thế như chẻ tre, thắng lợi tuyệt đối.",
	[Battle.RESULT_TIE]		= "%s kết thúc. Hai bên bất phân thắng bại, chọn ngày đấu tiếp.",
	[Battle.RESULT_LOSE]	= "%s kết thúc. Quân %s không chống đỡ nổi, phải rút lui.",
};

Battle.tbBattleMedType = {"小", "中", "大"};

Battle.tbBattleItem_Medicine = {
		[1] = { 56, 57, 58 },
		[2] = { 59, 60, 61 },
		[3] = { 62, 63, 64 },
}

-- if (EventManager.IVER_bOpenTiFu == 1) then
	-- 体服宋金奖励表，均为不绑定
	Battle.tbTiFuAwardList =
	{
		[1] = {["money"] = 500000, ["xuanjing"] = {[7] = 1, [6] = 2}, ["zhenyuanexp"] = 600}, -- 50W银两，一10玄一9玄
		[2] = {["money"] = 250000, ["xuanjing"] = {[7] = 1}, ["zhenyuanexp"] = 400},  -- 40W银两，三9玄
		[3] = {["money"] = 100000, ["xuanjing"] = {[6] = 2,}, ["zhenyuanexp"] = 300}; -- 30W银两，一9玄两8玄
		[10] = {["money"] = 50000, ["xuanjing"] = {[5] = 3,}, ["zhenyuanexp"] = 200}; -- 20W银两，一8玄两7玄
		[-1] = {["money"] = 5000, ["xuanjing"] = {[5] = 1}, ["zhenyuanexp"] = 100}	-- 10W银两，一7玄
	}
	
	-- 体服积分奖励上限，达到这个积分之后都会有奖励
	Battle.AWARDBONUS_LEAST = 2000;
	-- 能够领到奖励的名次条件，取小于等于
	Battle.tbAwardCondition = 
	{
		1, 2, 3, 10
	}
-- end

Battle.DEF_SONGJIN_JOINCOUNT_MINBOUNS = 1500;
-- 排名给玩家的真元经验奖励
Battle.tbZhenYuanExpAward =
{
	[1]  = 60,
	[3]  = 50,
	[10] = 30,
	[20] = 15, 
}

-- 成就系统阵营id
Battle.ACHIEVEMENT_ID_FIGHT_FOR_CAMP = {
		[Battle.CAMPID_SONG]	= 116,
		[Battle.CAMPID_JIN]		= 117,
	};

-- 宋金模式成就id
Battle.ACHIEVEMENT_ID_MODE	= {
		[1] = 120,
		[2]	= 119,
		[3] = 118,
	};
-- 宋金获取胜利成就id
Battle.ACHIEVEMENT_ID_FIGHT_WIN = 121;

-- 成就击杀玩家次数
Battle.ACHIEVEMENT_ID_KILL_PLAYER = {
		[1]		= 125,
		[20]	= 126,
		[200]	= 127,
	};

-- 成就护旗次数
Battle.ACHIEVEMENT_ID_PROTECT_FLAG = {
		[1]		= 128,
		[10]	= 129,
		[100]	= 130,
	};
	
-- 成就击杀敌方大将
Battle.ACHIEVEMENT_ID_KILL_DAJIANG	= {
		[1]		= 131,
		[10]	= 132,
	};

-- 成就组队击杀敌方元帅
Battle.ACHIEVEMENT_ID_KILL_YUANSHUAI_TEAM = 133;
-- 成就个人击杀敌方元帅
Battle.ACHIEVEMENT_ID_KILL_YUANSHUAI_PLAYER = 134;
-- 成就头衔
Battle.ACHIEVEMENT_ID_RANK = {
	[5]		= 135,
	[7]		= 136,
	[9]		= 137,
};
-- 成就连斩
Battle.ACHIEVEMENT_ID_SEREIS_KILL	= {
		[3]		= 138,
		[10]	= 139,
		[30]	= 140,
		[50]	= 141,
		[100]	= 142,
	};
-- 成就参加宋金次数
Battle.ACHIEVEMENT_ID_JOIN_SONGJINBATTLE = {
		[10]	= 143,
		[100]	= 144,
	};
-- 成就参加宋金胜利100次
Battle.ACHIEVEMENT_ID_JOIN_SONGJINBATTLE_WIN = 145;
-- 成就最后积分排名
Battle.ACHIEVEMENT_ID_FINAL_LIST = {
		[1]		= 148,
		[10]	= 147,
		[20]	= 146,
	};
-- 成就个人排名为1达到100次
Battle.ACHIEVEMENT_ID_PLAYER_FIRST_RANK	= 149;
