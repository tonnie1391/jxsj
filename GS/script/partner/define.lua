------------------------------------------------------
-- 文件名　：define.lua
-- 创建者　：dengyong
-- 创建时间：2009-12-02 09:34:46
-- 描  述  ：同伴的宏定义
------------------------------------------------------

if not Partner then
	Partner = {};
end

-- 相关配置文件路径
Partner.SUPERPATH 				 = "\\setting\\partner\\";	-- 文件目录路径

Partner.LEVELSETTINGFILENAME  	 = "levelsetting.txt";		-- 经验配置表
Partner.PARTNERATTRIBFILENAME    = "partner.txt";			-- 属性配置表
Partner.NPCEXPFILENAME	 		 = "npcexp.txt";			-- NPC经验掉落表
Partner.SKILLRULEFILENAME		 = "skillrule.txt";			-- 技能生成规则表
Partner.SKIllSETTINGFILENAME	 = "skillsetting.txt";		-- 技能模板表
Partner.POTENTIALTEMPFILENAME	 = "potential.txt";			-- 潜能分配模板表
Partner.STARLEVELFILENAME		 = "starlevel.txt";			-- 星级表
Partner.BASEVALUEFILENAME		 = "basevalue.txt";			-- 默认价值量表
Partner.MAINTENANCEFILENAME		 = "maintenance.txt";		-- 维护表
Partner.TALENTLEVELFILENAME	 	 = "talentlevel.txt";		-- 领悟度升级表
Partner.ITEMTALENTVALUEFILENAME  = "itemtalentvalue.txt";	-- 道具领悟度兑换表
Partner.EXPBOOKFILENAME			 = "partnerexpbook.txt";	-- 同伴经验书经验表	
Partner.PARTNERSKILLTIPFILENAME	 = "partnerskilltip.txt";	-- 同伴技能TIP信息
Partner.PERSUADEINFOFILENAME	 = "persuade.txt";			-- NPC模板ID与同伴ID映射表

Partner.PARTNERLIMIT_MIN		 = 5;		-- 一个玩家默认状态下最多只能有3个同伴
Partner.PARTNERLIMIT_MAX		 = 6;		-- 最多能开到6个同伴
Partner.PERSUADELEVELLIMIT		 = 100;		-- 玩家到100级以后才能说服同伴
Partner.MAXPERSUADEDISTANCE		 = 520;		-- 玩家说服NPC的时候，与NPC的距离不能大于520
Partner.SHAREEXPDISTANCE		 = 500;		-- 杀死NPC的时候，与NPC的距离在该值内的队友都能分享经验和亲密度
Partner.CALLPROCESSTIME			 = 15;		-- 召唤同伴的时候，需要读条15秒
Partner.CONVERTPROCESSTIME		 = 3;		-- 真元转化的时候，读条时间3秒

Partner.VAULE_TO_FIGHTPOWER		 = 20000000;	-- 同伴价值量转战斗力的比例
Partner.FIGHTPOWER_RATE_UNREADY	 = 20;		-- 袖手旁观状态下，同伴只能增加战斗力的20%

Partner.LEVELTOUPSKILL    		 = 5;		-- 同伴每升5级才有机会升级技能点
Partner.LEVELEXPSTROE			 = 10;		-- 同伴最多能积攒5级的经验
Partner.MAXLEVEL 				 = 120;		-- 同伴最大能达到120级

Partner.TAlENT_MIN		  		 = 40;		-- 领悟度最低为50
Partner.TALENT_MAX 	  		 	 = 100;		-- 领悟度最高为100
Partner.TALENT_DECREASE  		 = 10;		-- 同伴每升一个技能，扣除10点领悟度

Partner.FRIENDSHIP_SHUYUAN		 = 4000;	-- 同伴亲密度小于40点，不可召唤
Partner.FRIENDSHIP_MAX	 		 = 10000;	-- 同伴亲密度到达最大，不再增加	
Partner.FRIENDSHIP_INIT			 = 6000;	-- 初始时同伴的亲密度
Partner.FRIENDSHIP_DECMAX 		 = 200;		-- 每天能亲密度的最大衰减值（按总量为10000算）
Partner.FRIENDSHIP_TIMEDIFF		 = 36;		-- 每隔多少时间（秒）删除一点亲密
Partner.FRIENDSHIP_DECLEVEL		 = 30;		-- 同伴等级大于30级了才掉亲密，才能使用精魄增加亲密度

Partner.SKILLMAXLEVEL			 = 6;		-- 同伴的每个技能等级最大为6
Partner.SKILLUPRATEMIN			 = 30;		-- 默认的同伴技能提升最小概率

Partner.POTENTIAL_MIN			 = 16;		-- 初始潜能随机的最小值
Partner.POTENTIAL_MAX			 = 24;		-- 初始潜能随机的最大值

Partner.SKILLCOUNTMIN 			 = 2;		-- 目前配置文件中设定每个同伴最小技能数为2
Partner.SKILLCOUNTMAX 			 = 10;		-- 目前配置文件中设定每个同伴最大技能数为10
Partner.BICHUSKILLCOUNT			 = 3;		-- 目前配置文件中设定每个同伴最多会有三个必出技能
Partner.MAXSTARLEVEL			 = 20;		-- starlevel配置文件中最大的Level
Partner.DISSOLVELEVELLIMIT		 = 50;		-- 大于该等级的同伴解散时需要到龙五太爷那儿解散

Partner.nPersuadeSkillId 		 = 1526;	-- 说服状态技能ID
Partner.nBePersuadeSkillId		 = 1527;	-- 被说服状态技能ID
Partner.DELDEBUFF_SKILLID		 = 1600;	-- 申请删除同伴DEBUFF
Partner.PEELDEBUFF_SKILLID		 = 1601;	-- 申请洗同伴等级的DEBUFF技能ID 
Partner.CHUSHOUXIANGZHUID		 = 1602;	-- 出手状态技能ID
Partner.BINDPARTEQ_SKILLIED		 = 1449;	-- 申请解绑同伴装备的DEBUFF技能ID

Partner.EFFECTTIME				 = 5;		-- 每隔5分钟同伴出来施放一次技能
Partner.tbSeries				 = {1, 2, 3, 4, 5, -1};		-- 五行表，分别表示：金，木，水，火，土，任意

Partner.TASK_PEEL_PARTNER_GROUPID = 2085;
Partner.TASK_PEEL_PARTNER_SUBID   = 2;
Partner.TASK_DEL_PARTNER_GROUPID  = Partner.TASK_PEEL_PARTNER_GROUPID;
Partner.TASK_DEL_PARTNER_SUBID	  = 3;	
Partner.TASK_BIND_PARTNEREQ_GROUPID	= Partner.TASK_PEEL_PARTNER_GROUPID;	-- 解绑同伴装备主任务变量
Partner.TASK_BIND_PARTNEREQ_SUBID = 4;										-- 解绑同伴装备子任务变量
Partner.PEELLIMITSTARLEVEL 		  = 6.5;
Partner.DELLIMITSTARLEVEL		  = 5.5;
Partner.DELLIMITSKILLCOUNT		  = 4;
Partner.PEEL_USABLE_MINTIME		  = 30;	-- 高星级的同伴申请洗等级在3小时后才起效
Partner.PEEL_USABLE_MAXTIME 	  = 30 * 60;	-- 高星级的同伴申请洗等级在6小时后失效
Partner.DEL_USABLE_MINTIME		  = Partner.PEEL_USABLE_MINTIME;
Partner.DEL_USABLE_MAXTIME		  = Partner.PEEL_USABLE_MAXTIME;
Partner.BIND_PARTNERQUIP_MINTIME  = 30;	-- 3天后可解绑同伴装备
Partner.BIND_PARTNERQUIP_MAXTIME  = 30 * 60;	-- 4天后申请解绑失效

Partner.PEEL_VALUERATE			  = 0.9;		-- 剥离时计算返还价值量的百分比

Partner.TASK_FINDPARTNER_MAIN    = "01CF";	-- 寻找同伴任务的主任务ID，16进制，说服一个同伴
Partner.TASK_FINDPARTNER_SUB	 = "0290";	-- 寻找同伴任务的子任务ID，16进制
Partner.TASK_LEVELUP_MAIN		 = "01D0";	-- 结伴上路任务的主任务ID，16进制，提升同伴等级
Partner.TASK_LEVELUP_SUB		 = "0291";	-- 结伴上路任务的子任务ID，16进制
Partner.TASK_SKILLUP_MAIN		 = "01D1";	-- 更加强大任务的主任务ID，16进制，提升技能,领悟度等级
Partner.TASK_SKILLUP_SUB		 = "0292";	-- 更加强大任务的子任务ID，16进制
Partner.TASKID_MAIN  			 = 1024;	-- 主任务变量
Partner.TASKID_FINDPARTNER		 = 63;		-- 寻找同伴子任务变量
Partner.TASKID_LEVELUP			 = 64;		-- 结伴上路子任务变量
Partner.TASKID_SKILLUP			 = 65;		-- 更加强大子任务变量
Partner.TASKID_TALENTUP			 = 66;		-- 领悟度上升任务的子任务变量
-- 以下宏需要与程序中的枚举值保持一致
Partner.emKPARTNERATTRIBTYPE_TEMPID 		= 0;	-- 模板ID
Partner.emKPARTNERATTRIBTYPE_EXP 			= 1;	-- 经验
Partner.emKPARTNERATTRIBTYPE_LEVEL 			= 2;	-- 等级
Partner.emKPARTNERATTRIBTYPE_FRIENDSHIP 	= 3;	-- 亲密度
Partner.emKPARTNERATTRIBTYPE_TALENT 		= 4;	-- 领悟度
Partner.emKPARTNERATTRIBTYPE_DECRFSLASTTIME	= 5;	-- 上次衰减亲密度的时间
Partner.emKPARTNERATTRIBTYPE_DECRFSTODAY	= 6;	-- 当天衰减亲密度总值
Partner.emKPARTNERATTRIBTYPE_PotentialTemp	= 7;	-- 同伴加成潜能的分配模板ID
Partner.emKPARTNERATTRIBTYPE_PotentialPoint = 8;    -- 未分配的潜能点余额
Partner.emKPARTNERATTRIBTYPE_CREATETIME 	= 9;    -- 同伴创建时间
Partner.emKPARTNERATTRIBTYPE_SKILLBOOK 	= 10;    -- 同伴研习的技能书数量

Partner.CONVERTYPE_BEGIN	= 4;	-- 档次为4以上（包括4）的才可以被转成真元

Partner.VALUE_CALC_MAX_NUM	= 4;	-- 只计入价值量最高的4个同伴到财富里

Partner.bOpenPartner = EventManager.IVER_bOpenPartner; -- 同伴活动开关

-- 月影之石的GDPL0.9
Partner.tbMoonStone = 
{
	nGenre = 18, nDetail = 1, nParticular = 476, nLevel = 1
};

-- 同伴精华液的GDP
Partner.tbPartnerJinghua = 
{
	nGenre = 18, nDetail = 1, nParticular = 565,
}

-- 稚嫩的同伴的GDP
Partner.tbChildPartner = 
{
	nGenre = 18, nDetail = 1, nParticular = 567,
}


Partner.tbFsTalRate = 
{--技能个数，  领悟度曲线上限，该技能个数对应的最高同伴档次（对应maintenance.txt中的skilluprate列）。
	[2]	 = 		{45, 40},
	[3]	 = 		{65, 50},
	[4]	 = 		{85, 70},
	[5]  = 		{95, 80},
	[6]  = 		{100, 100},
	[7]  = 		{100, 100},
}

--三个级别同伴技能书的价值量   
Partner.tbBookValue =  
{
	600000,    --初级      
	3000000,  --中级       
	18000000 --高级        
}; 

Partner.szGiftContent = "Tách Vô Thượng Tinh Hoa ở chỗ Long Ngũ Thái Gia. Tặng quà cho đồng hành có thể giúp người đó tăng lĩnh ngộ.\nQuà được tặng: <color=yellow>Huyền Tinh, Hồn Thạch, Thỏi vàng, Thành phẩm Tiêu Dao Cốc, Thành phẩm Lãnh thổ chiến, Thành phẩm Tần Lăng, Tinh Hoa<color>.\n<color=green>Có thể tách Vô Thượng Tinh Hoa ở chỗ Long Ngũ Thái Gia<color>";