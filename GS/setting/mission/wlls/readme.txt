
默认奖励表.
如果没定义每届奖励表,文件格式为 
初级：szFileName .. "_lv1.txt"
高级：szFileName .. "_lv2.txt"
如下：

第一届初级	award_session_1  则文件名为  award_session_1_lv1.txt
第二届初级	award_session_2  则文件名为  award_session_2_lv1.txt
...

第一届高级	award_session_1  则文件名为  award_session_1_lv2.txt
第二届高级	award_session_2  则文件名为  award_session_2_lv2.txt
...

类型表:
--大会场进入准备场类型，
Wlls.MAP_LINK_TYPE_RANDOM 	= 1;		--随机选择进入;随机准备场
Wlls.MAP_LINK_TYPE_SERIES 	= 2;		--五行对应类型;准备场地图编号为战队五行,比赛场也是
Wlls.MAP_LINK_TYPE_FACTION 	= 3;		--门派对应类型;准备场地图编号为战队门派,比赛场也是

--战队组队类型，
Wlls.LEAGUE_TYPE_SEX_FREE 		= 0;		--自由性别
Wlls.LEAGUE_TYPE_SEX_SINGLE 		= 1;		--同一性别;
Wlls.LEAGUE_TYPE_SEX_MIX 		= 2;		--混合性别;
Wlls.LEAGUE_TYPE_CAMP_FREE 		= 0;		--自由阵营;
Wlls.LEAGUE_TYPE_CAMP_SINGLE 		= 1;		--同一阵营;
Wlls.LEAGUE_TYPE_CAMP_MIX 		= 2;		--混合阵营;
Wlls.LEAGUE_TYPE_SERIES_FREE 		= 0;		--自由五行;
Wlls.LEAGUE_TYPE_SERIES_SINGLE 		= 1;		--同一五行;
Wlls.LEAGUE_TYPE_SERIES_MIX 		= 2;		--混合五行;
Wlls.LEAGUE_TYPE_SERIES_RESTRAINT	= 3;		--相克五行;（未开发）
Wlls.LEAGUE_TYPE_FACTION_FREE 		= 0;		--自由门派;
Wlls.LEAGUE_TYPE_FACTION_SINGLE 	= 1;		--同一门派;
Wlls.LEAGUE_TYPE_FACTION_MIX 		= 2;		--混合门派;
Wlls.LEAGUE_TYPE_TEACHER_FREE 		= 0;		--自由师徒;
Wlls.LEAGUE_TYPE_TEACHER_MIX 		= 1;		--混合师徒;

--GM指令（2009.03.12）
?gc Wlls: SetMacthSession(4);	--设置届数;
?gc Wlls: GameState0Into1();	--开启联赛进入间歇期（可建立战队，第一届）	1号0点
?gc Wlls: GameState1Into2();	--间歇期进入比赛期（荣誉衰减，上届战队清空）	7号0点	
?gc Wlls: GameState2Into3();	--比赛期进入八强期（八强赛名单战报）		28号0点	
?gc Wlls: GameState3Into1();	--八强期进入间歇期（领奖，战报）		28号24点
?gc Wlls: LeagueRank(0);	--更新排名
?gc Wlls: GamePkStart(nId);	--开启单场比赛;八强赛阶段nId的意义（1：8进4；2：4进2，3：决赛场1；4：决赛场2；5：决赛场3；）
?gc Wlls: Game8PkStart(1)	--开启八强赛（开启后自动进行5场）
?gc Wlls: UpdateHelpNews(Wlls: GetMacthSession());	--帮助锦囊战报
?gc League: SetLeagueTask(Wlls.LGTYPE,"战队名",Wlls.LGTASK_TOTAL,48); --设置总场数
?gc League: SetLeagueTask(Wlls.LGTYPE,"战队名",Wlls.LGTASK_WIN,48);   --设置胜场数（积分根据胜场数计算）
?gc Wlls.MACTH_TIME_UPDATA_RANK	= 18*600; GlobalExcute{"GM:DoCommand",[[Wlls.MACTH_TIME_UPDATA_RANK = 18*600]]};	--单场比赛开始后多久刷新排名
?gc Wlls.MACTH_TIME_READY 	= 18*60; GlobalExcute{"GM:DoCommand",[[Wlls.MACTH_TIME_READY = 18*60]]};	--准备时间;
?pl Wlls.MACTH_LEAGUE_MIN	= 2;	--准备场最少多少人才能开启
