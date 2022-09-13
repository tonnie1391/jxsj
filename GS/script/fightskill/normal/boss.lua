--boss技能
local tb	= {
	--------------------------------55级世界boss级家族boss用技能-----------------------
	boss_jinzhongzhao={ --金钟罩
		fastwalkrun_p={{{1,60},{20,60}}},
		state_hurt_ignore={1},
		state_weak_ignore={1},
		state_slowall_ignore={1},
		state_burn_ignore={1},
		state_stun_ignore={1},
		damage_all_resist={{{1,80},{2,80},{10,100},{20,260}}},
		skill_statetime={{{1,18*180},{20,18*300}}}
	},
	boss_duanhunci={ --断魂刺
		state_fixed_attack={{{1,100},{10,100},{20,100}},{{1,18*1.5},{20,18*1.5}}},
		skill_eventskilllevel={{{1,1},{2,2},{3,3}}},
		skill_collideevent={{{1,551},{2,551},{3,564}}},
	--	skill_cost_v={{{1,20},{20,50}}},
	},
	boss_yangguansandie={ --阳关三叠
	--	physicsenhance_p={{{1,5},{10,140},{20,240}}},
		physicsdamage_v={
			[1]={{1,600*0.9},{2,400*0.9}},
			[3]={{1,600*1.1},{2,400*1.1}}
			},
	--	attackrating_p={{{1,30},{20,60}}},
		state_hurt_attack={{{1,50},{20,50}},{{1,18*1.5},{20,18*1.5}}},
		skill_deadlystrike_r={{{1,150},{20,150}}},
		seriesdamage_r={0},--={{{1,100},{20,100}}},
	},
	boss_shizihou={ --狮子吼
		state_fixed_attack={{{1,85},{10,85},{20,100}},{{1,18*3},{20,18*3}}},
	},
	boss_fixed={ --定身
		state_fixed_attack={{{1,50},{20,50}},{{1,18*5},{20,18*5}}},
	},
	boss_fixedaoe={ --定身全屏攻击
		physicsdamage_v={
			[1]={{1,1200*0.9},{2,1000*0.9},{20,1200*0.9}},
			[3]={{1,1200*1.1},{2,1000*1.1},{20,1200*1.1}}
			},
		skill_deadlystrike_r={{{1,150},{20,150}}},
		seriesdamage_r={0},--={{{1,100},{20,100}}},		
		},
	boss_qixingluoshagun={ --七星罗刹棍
	--	physicsenhance_p={{{1,10},{20,400}}},
	--	attackrating_p={{{1,10},{20,30}}},
		physicsdamage_v={
			[1]={{1,800*0.9},{2,550*0.9},{20,1000*0.9}},
			[3]={{1,800*1.1},{2,550*1.1},{20,1000*1.1}}
			},
		state_hurt_attack={{{1,50},{20,50}},{{1,18*1.5},{20,18*1.5}}},
		skill_deadlystrike_r={{{1,150},{20,150}}},
		seriesdamage_r={0},--={{{1,100},{20,100}}},
	},
	boss_xingyunjue={ --行云诀
	--	physicsenhance_p={{{1,5},{10,95},{20,145}}},
	--	attackrating_p={{{1,50},{20,100}}},
		physicsdamage_v={
			[1]={{1,350*0.9},{2,300*0.9},{20,1000*0.9}},
			[3]={{1,350*1.1},{2,300*1.1},{20,1000*1.1}}
			},
		state_hurt_attack={{{1,50},{20,50}},{{1,18*1.5},{20,18*1.5}}},
		skill_deadlystrike_r={{{1,150},{20,150}}},
		seriesdamage_r={0},--={{{1,100},{20,100}}},
	},

	boss_dot={ --dot诅咒
		fastlifereplenish_v={{{1,-100},{2,-100}}},
		skill_statetime={{{1,18*10},{2,18*10}}}
	},
	boss_miqipiaozong={ --弥气飘踪
		ignoreskill={{{1,50},{10,100},{20,100}},0,{{1,2},{2,2}}},
		state_hurt_ignore={1},
		state_weak_ignore={1},
		state_slowall_ignore={1},
		state_burn_ignore={1},
		state_stun_ignore={1},
		skill_statetime={{{1,18*180},{20,18*300}}},
	},
	boss_jiugongfeixing={ --九宫飞星
	--	physicsenhance_p={{{1,5},{20,190}}},
	--	attackrating_p={{{1,12},{20,99}}},
		state_hurt_attack={{{1,45},{20,45}},{{1,18*1.5},{20,18*1.5}}},
		state_weak_attack={{{1,75},{20,75}},{{1,18*5},{20,18*5}}},
		seriesdamage_r={0},--={{{1,500},{2,500},{3,250},{4,250}}},
		poisondamage_v={{{1,550},{2,75},{3,37},{20,1000}},{{1,9*1},{2,9*10},{3,9*10},{20,9*1}}},
		skill_deadlystrike_r={{{1,150},{20,150}}},
	},
	boss_tiangangdisha={ --天罡地煞
		seriesdamage_r={0},--={{{1,100},{20,500}}},
		state_weak_attack={{{1,75},{20,75}},{{1,18*5},{20,18*5}}},
		poisondamage_v={{{1,300},{2,200},{20,1000}},{{1,9*5},{20,9*5}}},
		skill_deadlystrike_r={{{1,150},{20,150}}},
	},
	boss_sanhuabiao={ --散花镖
	--	physicsenhance_p={{{1,5},{10,68},{20,118}}},
	--	attackrating_p={{{1,12},{20,100}}},
		state_hurt_attack={{{1,40},{20,40}},{{1,18*1.5},{20,18*1.5}}},
		state_weak_attack={{{1,75},{20,75}},{{1,18*5},{20,18*5}}},
		seriesdamage_r={0},--={{{1,100},{2,500},{3,100},{20,500}}},
		poisondamage_v={{{1,200},{2,75},{3,150},{4,100},{20,1000}},{{1,9*4},{2,9*15},{3,9*4},{4,9*4}}},
		skill_deadlystrike_r={{{1,150},{20,150}}},
	},
	boss_tianluodiwang={ --天罗地网
--		physicsenhance_p={{{1,5},{10,95},{20,125}}},
--		attackrating_p={{{1,12},{20,250}}},
		state_hurt_attack={{{1,45},{20,45}},{{1,18*1.5},{20,18*1.5}}},
		state_weak_attack={{{1,75},{20,75}},{{1,18*5},{20,18*5}}},
		seriesdamage_r={0},--={{{1,100},{20,100}}},
		poisondamage_v={{{1,150},{2,100}},{{1,9*5},{2,9*5}}},
		skill_deadlystrike_r={{{1,150},{20,150}}},
	},
	boss_foxinciyou={ --佛心慈佑
		lifemax_p={{{1,30},{20,50}}},
	},
	boss_xueying={ --雪影
		fastwalkrun_p={{{1,40},{20,40}}},
		state_hurt_ignore={1},
		state_weak_ignore={1},
		state_slowall_ignore={1},
		state_burn_ignore={1},
		state_stun_ignore={1},
		state_burn_resisttime={{{1,200},{20,200}}},
		skill_statetime={{{1,18*180},{20,18*300}}}
	},
	boss_cihangpudu={ --慈航普渡
		fastlifereplenish_v={{
			{1,15000},
			{2,99999},		--高攻击小兵用
			{3,-5000},
			{4,   600},
			{20,50000},
		}},
		fastmanareplenish_v={{
			{1,15000},
			{2,99999},		--高攻击小兵用
			{3,-5000},
			{4,   600},
			{20,50000},
		}},
		skill_statetime={{
			{1,18*5},
			{2,18*2},
			{3,-1},
			{4,18*2},
			{5,-1},
			{6,-1},
		}}
	},
	boss_suddendeath={	--召唤小兵用生命周期
		suddendeath={
			{	{1,100},
				{2,100}
			},
			{	{1,18*60*3},
				{2,18*3}}
			},
	},
	boss_muyeliuxing={ --牧野流星
		seriesdamage_r={0},--={{{1,100},{20,100}}},
	--	physicsenhance_p={{{1,10},{20,110}}},
		colddamage_v={
			[1]={{1,550*0.9},{2,444*0.9},{20,1000*0.9}},
			[3]={{1,550*1.1},{2,444*1.1},{20,1000*1.1}}
		},
		state_slowall_attack={{{1,50},{20,50}},{{1,18*5},{20,18*5}}},
		skill_deadlystrike_r={{{1,150},{20,150}}},
	--	attackrating_p={{{1,30},{20,90}}},
	},
	boss_sixiangtonggui={ --四象同归
		colddamage_v={
			[1]={{1,750*0.9},{2,600*0.9},{20,1000*0.9}},
			[3]={{1,750*1.1},{2,600*1.1},{20,1000*1.1}}
		},
		state_slowall_attack={{{1,50},{20,50}},{{1,18*10},{20,18*10}}},
		seriesdamage_r={0},--={{{1,100},{20,500}}},
		skill_deadlystrike_r={{{1,150},{20,150}}},
	},
	boss_bihaichaosheng={ --碧海潮生
		colddamage_v={
			[1]={{1,600*0.9},{2,400*0.9},{20,1000*0.9}},
			[3]={{1,600*1.1},{2,400*1.1},{20,1000*1.1}}
		},
		state_slowall_attack={{{1,50},{20,50}},{{1,18*5},{20,18*5}}},
		seriesdamage_r={0},--={{{1,100},{20,500}}},
		skill_deadlystrike_r={{{1,150},{20,150}}},
	},
	boss_huabuliushou={ --滑不溜手
		fastwalkrun_p={{{1,30},{20,40}}},
		state_hurt_ignore={1},
		state_weak_ignore={1},
		state_slowall_ignore={1},
		state_burn_ignore={1},
		state_stun_ignore={1},
		state_hurt_resisttime={{{1,150},{20,250}}},
		skill_statetime={{{1,18*180},{20,18*300}}},
		skill_deadlystrike_r={{{1,150},{20,150}}},
	},
	boss_huanyingfeihu={ --幻影飞狐
		attackratingenhance_p={{{1,-150},{20,-250}}},
		deadlystrikeenhance_r={{{1,-50},{20,-150}}},
		skill_statetime={{{1,18*180},{20,18*300}}}
	},
	boss_limoduohun={ --厉魔夺魂
		addphysicsdamage_p={{{1,-50},{20,-100}},0,0},
	--	skill_cost_v={{{1,20},{20,20}}},
		skill_statetime={{{1,18*180},{20,18*360}}}
	},
	boss_tuishantianhai={ --推山填海
		seriesdamage_r={0},--={{{1,100},{20,100}}},
		firedamage_v={
			[1]={{1,350*0.9},{2,300*0.8},{20,1000*0.9}},
			[3]={{1,350*1.1},{2,300*1.2},{20,1000*1.1}}
		},
		state_burn_attack={{{1,45},{20,45}},{{10,18*3},{20,18*3}}},
		skill_missilenum_v={{{1,8},{20,8}}},
		skill_deadlystrike_r={{{1,150},{20,150}}},
	},
	boss_kanglongyouhui={ --亢龙有悔
		seriesdamage_r={0},--={{{1,100},{2,500},{3,100}}},
		firedamage_v={
			[1]={{1,600*0.9},{2,1000*0.5},{3,400*0.8},{20,1000*0.9}},
			[3]={{1,600*1.1},{2,1000*1.5},{3,400*1.2},{20,1000*1.1}}
		},
		state_burn_attack={{{1,45},{20,45}},{{1,18*3},{20,18*3}}},
		skill_missilenum_v={{{1,15},{20,15}}},
		skill_deadlystrike_r={{{1,150},{20,150}}},
	},
	boss_bangdaegou={ --棒打恶狗
		seriesdamage_r={0},--={{{1,100},{20,100}}},
	--	physicsenhance_p={{{1,5},{10,23},{20,43}}},
		firedamage_v={
			[1]={{1,650*0.9},{2,450*0.9},{20,1000*0.9}},
			[3]={{1,650*1.1},{2,450*1.1},{20,1000*1.1}}
		},
		state_hurt_attack={{{1,35},{10,35},{20,35}},{{1,18*1.5},{20,18*1.5}}},
		state_burn_attack={{{1,45},{20,45}},{{1,18*3},{20,18*3}}},
		attackrating_p={{{1,100},{20,100}}},
		skill_deadlystrike_r={{{1,150},{20,150}}},
	},
	boss_tanzhilieyan={ --弹指烈焰
		seriesdamage_r={0},--={{{1,100},{2,100}}},
		firedamage_v={
			[1]={{1,300*0.9},{2,200*0.9}},
			[3]={{1,300*1.1},{2,200*1.1}}
		},
		state_burn_attack={{{1,45},{20,45}},{{1,18*3},{20,18*3}}},
		skill_deadlystrike_r={{{1,150},{20,150}}},
	},
	boss_yanmentuobo={ --沿门托钵
		seriesdamage_r={0},--={{{1,100},{20,100}}},
	--	physicsenhance_p={{{1,5},{10,50},{20,100}}},
		firedamage_v={
			[1]={{1,550*0.9},{2,400*0.9}},
			[3]={{1,550*1.1},{2,400*1.1}}
		},
		state_hurt_attack={{{1,35},{10,35},{20,35}},{{1,18*1.5},{20,18*1.5}}},
		state_burn_attack={{{1,45},{20,45}},{{1,18*3},{20,18*3}}},
		skill_deadlystrike_r={{{1,150},{20,150}}},
	},
	boss_zhenwuqijie={ --真武七截
		addphysicsmagic_p={{{1,5},{20,5}}},
	},
	boss_yiqisanqing={ --一气三清
		addphysicsdamage_p={{{1,20},{20,50}},0,0},
		addphysicsmagic_p={{{1,20},{20,50}}},
		skill_statetime={{{1,18*180},{20,18*300}}}
	},
	boss_qingfengfu={ --清风符
		fastwalkrun_p={{{1,40},{20,50}}},
		state_hurt_ignore={1},
		state_weak_ignore={1},
		state_slowall_ignore={1},
		state_burn_ignore={1},
		state_stun_ignore={1},
		skill_statetime={{{1,18*180},{20,18*300}}}
	},
	boss_bojierfu={ --剥及而复
		lightingdamage_v={
			[1]={{1,700*0.9},{2,500*0.9},{20,1000*0.9}},
			[3]={{1,700*1.1},{2,500*1.1},{20,1000*1.1}}
		},
		state_stun_attack={{{1,45},{20,45}},{{1,18*2},{20,18*2}}},
		seriesdamage_r={0},--={{{1,100},{20,500}}},
		skill_deadlystrike_r={{{1,150},{20,150}}},
	},
	boss_sanhuantaoyue={ --三环套月
		seriesdamage_r={0},--={{{1,100},{20,100}}},
		physicsenhance_p={{{1,50},{2,50},{10,203},{20,353}}},
		lightingdamage_v={
			[1]={{1,600*0.9},{2,400*0.9},{20,1000*0.9}},
			[3]={{1,600*1.1},{2,400*1.1},{20,1000*1.1}}
		},
		state_stun_attack={{{1,45},{20,45}},{{1,18*2},{20,18*2}}},
		skill_deadlystrike_r={{{1,150},{20,150}}},
	--	attackrating_p={{{1,50},{20,100}}},
	},
	boss_kuangfengzhoudian={ --狂风骤电
		seriesdamage_r={0},--={{{1,100},{20,100}}},
	--	physicsenhance_p={{{1,5},{10,50},{20,73}}},
		lightingdamage_v={
			[1]={{1,750*0.9},{2,500*0.9},{20,1000*0.9}},
			[3]={{1,750*1.1},{2,500*1.1},{20,1000*1.1}}
		},
		state_stun_attack={{{1,45},{20,45}},{{1,18*2},{20,18*2}}},
		skill_deadlystrike_r={{{1,150},{20,150}}},
	--	attackrating_p={{{1,50},{20,100}}},
	},
	boss_wuwowujian={ --无我无剑
	--	missile_hitcount={{{1,3},{5,4},{10,5},{15,6},{16,6}}},
		lightingdamage_v={
			[1]={{1,550*0.9},{2,400*0.9},{20,1000*0.9}},
			[3]={{1,550*1.1},{2,400*0.9},{20,1000*1.1}}
		},
		state_stun_attack={{{1,45},{20,45}},{{1,18*2},{20,18*2}}},
		seriesdamage_r={0},--={{{1,100},{20,100}}},
		skill_deadlystrike_r={{{1,150},{20,150}}},
	--	skill_cost_v={{{1,100},{20,150}}}
	},
	--------------------------------75级世界boss级家族boss用技能-----------------------
	boss_rage={ --狂暴状态
		attackspeed_v={{{1,40},{20,90}}},
		fastwalkrun_p={{{1,40},{20,60}}},
		--addphysicsdamage_p={{{1,50},{20,200}}},
		addphysicsdamage_v={{{1,500},{20,200}}},
		addphysicsmagic_v={{{1,500},{20,200}}},
		skill_statetime={{{1,18*45},{20,18*300}}}
	},
	boss_resistcurse={ --单体全抗诅咒
		damage_all_resist={{{1,-500},{2,-5000}}},
		skill_statetime={{{1,18*3},{20,18*300}}}
	},
	boss_sectorknockback={ --扇形击退
		state_knock_attack={{{1,100},{2,100}},{{1,16},{2,16}},{{1,32},{2,32}}},
	},
	boss_longaoe={ --长吟唱大范围攻击
		physicsdamage_v={
			[1]={{1,1200*0.9},{20,1000*0.9}},
			[3]={{1,1200*1.1},{20,1000*1.1}}
			},
		--state_hurt_attack={{{1,40},{20,30}},{{1,18*1},{20,18*1}}},
		--skill_deadlystrike_r={{{1,150},{20,150}}},
		seriesdamage_r={0},--={{{1,500},{20,500}}},
	},
	boss_longaoe_child={ --长吟唱大范围攻击子
		physicsdamage_v={
			[1]={{1,1000*0.9},{20,1000*0.9}},
			[3]={{1,1000*1.1},{20,1000*1.1}}
			},
		--state_hurt_attack={{{1,40},{20,30}},{{1,18*1},{20,18*1}}},
		--skill_deadlystrike_r={{{1,150},{20,150}}},
		seriesdamage_r={0},--={{{1,500},{20,500}}},
	},
	boss_areafix={ --大范围定身,2级为逍遥谷墨君使用
		state_fixed_attack={{{1,90},{2,50}},{{1,18*3},{2,18*10}}},
	},
	boss_stealhpknockback={ --近身高攻吸血击退
		physicsdamage_v={
			[1]={{1,3000*0.9},{2,2000*0.9},{20,1500*0.9}},
			[3]={{1,3000*1.1},{2,2000*1.1},{20,1500*1.1}}
			},
		state_knock_attack={{{1,100},{2,100}},{{1,16},{2,16}},{{1,32},{2,32}}},
		seriesdamage_r={0},--={{{1,500},{20,500}}},
		steallife_p={{{1,1000},{2,1500}}},
	},
	boss_ragegold={ --金系怒气攻击
		appenddamage_p= {{{1,0},{10,0},{20,0}}},
		physicsdamage_v={
			[1]={	{1,600*0.9},--金系75级boss
					{2,300*0.9},--家族副本75级boss
					{3,300*0.9},--??
					{4,250*0.9},--90级藏宝图boss
					{5,350*0.9},--100级藏宝图boss
					{20,1000*0.9}},
			[3]={	{1,600*1.1},
					{2,300*1.1},
					{3,300*1.1},
					{4,250*1.1},
					{5,350*1.1},
					{20,1000*1.1}}
			},
		state_hurt_attack={{{1,40},{20,40}},{{1,18*1},{20,18*1}}},
		skill_deadlystrike_r={100000},
		seriesdamage_r={0},--={{{1,500},{20,500}}},
	},
	boss_areamanyattack={ --自身范围多段攻击
		physicsdamage_v={
			[1]={{1,900*0.9},{2,450*0.9},{20,1000*0.9}},
			[3]={{1,900*1.1},{2,450*1.1},{20,1000*1.1}}
			},
		state_hurt_attack={{{1,10},{20,10}},{{1,18*1},{20,18*1}}},
		skill_deadlystrike_r={{{1,150},{20,150}}},
		seriesdamage_r={0},--={{{1,500},{20,500}}},
	},
	boss_pojiedaofa={ --远程直线穿透攻击
		physicsdamage_v={
			[1]={{1,2000*0.9},{2,1000*0.9}},
			[3]={{1,2000*1.1},{2,1000*1.1}}
			},
		state_hurt_attack={{{1,40},{20,40}},{{1,18*1},{20,18*1}}},
		skill_deadlystrike_r={{{1,150},{20,150}}},
		seriesdamage_r={0},--={{{1,500},{20,500}}},
	},
	boss_fumodaofa={ --远程直线单体攻击
		physicsdamage_v={
			[1]={{1,2000*0.9},{2,1000*0.9}},
			[3]={{1,2000*1.1},{2,1000*1.1}}
			},
		state_hurt_attack={{{1,40},{2,40}},{{1,18*1},{20,18*1}}},
		skill_deadlystrike_r={{{1,150},{20,150}}},
		seriesdamage_r={0},--={{{1,500},{20,500}}},
	},
	boss_meleeattack={ --近身定点攻击
		physicsdamage_v={
			[1]={{1,1800*0.9},{2,500*0.8},{3,900*0.9},{4,300*0.9},{20,1000*0.9}},
			[3]={{1,1800*1.1},{2,500*1.2},{3,900*1.1},{4,300*1.1},{20,1000*1.1}}
			},
		state_hurt_attack={{{1,40},{2,50},{3,40},{4,50}},{{1,18*1},{20,18*1}}},
		skill_deadlystrike_r={{{1,150},{20,150}}},
		seriesdamage_r={0},--={{{1,500},{20,500}}},
	},
	boss_callnpc={ --召唤小兵
		missile_callnpc={	--npcid*65536+nLevel
			{	{ 1,2418 * 65536 + 75},		--弱弹幕小兵
				{ 2,2419 * 65536 + 75},		--强弹幕小兵
				{ 3,2412 * 65536 + 75},		--常用小兵
				{ 4,2413 * 65536 + 75},		--高攻小兵
				{ 5,2414 * 65536 + 75},		--诅咒小兵
				{ 6,2415 * 65536 + 75},		--无形蛊小兵
				{ 7,2416 * 65536 + 75},		--群攻小兵
				{ 8,2417 * 65536 + 75},		--自我复制小兵
				{ 9,2420 * 65536 + 75},		--自我复制小兵召唤自身
				
				{10,3596 * 65536 + 150},	--召唤木桩诱骗自动战斗

				{11,2989 * 65536 + 75},		--弱弹幕小兵
				{12,2990 * 65536 + 75},		--强弹幕小兵
				{13,2983 * 65536 + 75},		--常用小兵
				{14,2984 * 65536 + 75},		--高攻小兵
				{15,2985 * 65536 + 75},		--诅咒小兵
				{16,2986 * 65536 + 75},		--无形蛊小兵
				{17,2987 * 65536 + 75},		--群攻小兵
				{18,2988 * 65536 + 75},		--自我复制小兵
				{19,2991 * 65536 + 75},		--自我复制小兵召唤自身

			},
			{{ 1,18*180},{ 3,18*180},{ 4,0},{ 5,18*180},{ 9,18*180},{10,18*180},	},	--npc生存时间,0为无限
			{{1,-1},{9,-1}},	--npcseries
		},
		skill_missilenum_v={	--用子弹数来设置召唤npc的数量
			{	{ 1,3},
				{ 2,2},
				{ 3,5},
				{ 4,3},
				{ 5,2},
				{ 6,1},
				{ 7,3},
				{ 8,3},
				{ 9,1},
				
				{10,3},
				
				{11,2},
				{12,1},
				{13,3},
				{14,2},
				{15,1},
				{16,1},
				{17,2},
				{18,2},
				{19,1},
			}
		},
	},
	boss_ragewood={ --木系怒气攻击
		appenddamage_p= {{{1,0},{10,0},{11,25},{20,0}}},
		state_hurt_attack={{{1,5},{20,5}},{{1,18*1},{20,18*1}}},
		state_weak_attack={{{1,35},{20,35}},{{1,18*5},{20,18*5}}},
		poisondamage_v={	{	{1,1000},--75级世界boss
								{2,500},--家族副本75级世界boss
								{3,500},--高级藏宝图boss
								{4,450},--80-90级任务副本boss
								{5,650},--100级藏宝图
								{11,1},--唐羽用木系怒气技能
								},
							{	{1,9*1},
								{20,9*1}}},
		skill_deadlystrike_r={1900},
		seriesdamage_r={0},--={{{1,500},{20,500}}},
	},
	boss_barrage_centipede={ --蜈蚣型弹幕
		state_hurt_attack={{{1,5},{20,5}},{{1,18*1},{20,18*1}}},
		state_weak_attack={{{1,35},{20,35}},{{1,18*5},{20,18*5}}},
		poisondamage_v={{{1,100},{2,50}},{{1,9*10},{20,9*10}}},
		skill_deadlystrike_r={{{1,150},{20,150}}},
		seriesdamage_r={0},--={{{1,500},{20,500}}},
	},
	boss_barrage_jiugongfeixing={ --九宫飞星弹幕
		state_hurt_attack={{{1,5},{20,5}},{{1,18*1},{20,18*1}}},
		state_weak_attack={{{1,35},{20,35}},{{1,18*5},{20,18*5}}},
		poisondamage_v={{{1,100},{2,50}},{{1,9*10},{20,9*10}}},
		skill_deadlystrike_r={{{1,150},{20,150}}},
		seriesdamage_r={0},--={{{1,500},{20,500}}},
	},
	boss_barrage_xiaoli={ --小李飞刀弹幕及子子
		state_hurt_attack={{{1,5},{20,5}},{{1,18*1},{20,18*1}}},
		state_weak_attack={{{1,35},{20,35}},{{1,18*5},{20,18*5}}},
		poisondamage_v={{{1,100},{2,50}},{{1,9*10},{20,9*10}}},
		skill_deadlystrike_r={{{1,150},{20,150}}},
		seriesdamage_r={0},--={{{1,500},{20,500}}},
	},
	boss_barrage_xiaoli_child1={ --小李飞刀弹幕子子子
		poisondamage_v={{{1,100},{2,50},{20,100}},{{1,9*10},{20,9*10}}},
		skill_deadlystrike_r={{{1,150},{20,150}}},
		seriesdamage_r={0},--={{{1,500},{20,500}}},
		state_slowall_attack={{{1,45},{20,45}},{{1,18*3},{20,18*3}}},
	},
	boss_barrage_spray={ --扫射弹幕
		state_hurt_attack={{{1,5},{20,5}},{{1,18*1},{20,18*1}}},
		state_weak_attack={{{1,35},{20,35}},{{1,18*5},{20,18*5}}},
		poisondamage_v={{{1,100},{2,50},{20,1050}},{{1,9*10},{20,9*10}}},
		skill_deadlystrike_r={{{1,150},{20,150}}},
		seriesdamage_r={0},--={{{1,500},{20,500}}},
	},
	boss_barrage_round={ --环形攻击弹幕
		state_hurt_attack={{{1,5},{20,5}},{{1,18*1},{20,18*1}}},
		state_weak_attack={{{1,35},{20,35}},{{1,18*5},{20,18*5}}},
		poisondamage_v={{{1,100},{2,50},{20,1050}},{{1,9*10},{20,9*10}}},
		skill_deadlystrike_r={{{1,150},{20,150}}},
		seriesdamage_r={0},--={{{1,500},{20,500}}},
	},
	boss_barrage_sixiang={ --四象同归弹幕
		state_hurt_attack={{{1,5},{20,5}},{{1,18*1},{20,18*1}}},
		state_weak_attack={{{1,35},{20,35}},{{1,18*5},{20,18*5}}},
		poisondamage_v={{{1,100},{2,50},{20,1050}},{{1,9*10},{20,9*10}}},
		skill_deadlystrike_r={{{1,150},{20,150}}},
		seriesdamage_r={0},--={{{1,500},{20,500}}},
	},
	boss_barrage_lineround={ --直线环行攻击弹幕
		state_hurt_attack={{{1,5},{20,5}},{{1,18*1},{20,18*1}}},
		state_weak_attack={{{1,35},{20,35}},{{1,18*5},{20,18*5}}},
		poisondamage_v={{{1,100},{2,75},{3,50},{4,37},{20,1050}},{{1,9*10},{20,9*10}}},
		skill_deadlystrike_r={{{1,150},{20,150}}},
		seriesdamage_r={0},--={{{1,500},{20,500}}},
	},
	boss_jiugongfeixingmelee={ --九宫飞星格斗
		state_hurt_attack={{{1,5},{20,5}},{{1,18*1},{20,18*1}}},
		state_weak_attack={{{1,35},{20,35}},{{1,18*5},{20,18*5}}},
		seriesdamage_r={0},--={{{1,500},{20,500}}},
		poisondamage_v={{{1,100},{2,50},{20,100}},{{1,9*10},{20,9*10}}},
		skill_deadlystrike_r={{{1,150},{20,150}}},
	},
	boss_barrage_tianluodiwang={ --天罗地网弹幕
		state_hurt_attack={{{1,5},{20,5}},{{1,18*1},{20,18*1}}},
		state_weak_attack={{{1,35},{20,35}},{{1,18*5},{20,18*5}}},
		poisondamage_v={{{1,75},{2,37}},{{1,9*10},{20,9*10}}},
		skill_deadlystrike_r={{{1,150},{20,150}}},
		seriesdamage_r={0},--={{{1,500},{20,500}}},
	},
	boss_ragewater_child1={	--水系怒气攻击子_冻结
		state_freeze_attack={{{1,100},{2,100}},{{1,18*2.5},{2,18*2.5}}},
	},
	boss_ragewater_child2={ --水系怒气攻击子子_冰暴
		appenddamage_p= {{{1,0},{10,0},{20,0}}},
		seriesdamage_r={0},--={{{1,500},{20,500}}},
		colddamage_v={
			[1]={	{1,600*0.9},--75级世界boss
					{2,300*0.9},--家族副本75级世界boss
					{3,1000*0.9},--高级藏宝图boss
				},
			[3]={	{1,600*1.1},
					{2,300*1.1},
					{3,1000*1.1},
				}
		},
		skill_deadlystrike_r={100000}
	},
	boss_meleeaoe={ --近身小范围攻击
		seriesdamage_r={0},--={{{1,500},{20,500}}},
		colddamage_v={
			[1]={{1,1800*0.9},{2,1500*0.9},{3,2000*0.5},{4,900*0.9},{5,750*0.9},{6,1000*0.5},{20,1000*0.9}},
			[3]={{1,1800*1.1},{2,1500*1.1},{3,2000*1.5},{4,900*1.1},{5,750*1.1},{6,1000*1.5},{20,1000*1.1}}
		},
		state_slowall_attack={{{1,75},{2,50},{3,35},{20,35}},{{1,18*3},{20,18*3}}},
		skill_deadlystrike_r={{{1,150},{20,150}}},
	},
	boss_fengjuancanxue={ --boss风卷残雪
		seriesdamage_r={0},--={{{1,500},{20,500}}},
		colddamage_v={
			[1]={{1,100*0.8},{2,750*0.8},{20,1000*0.9}},
			[3]={{1,100*1.2},{2,750*1.2},{20,1000*1.1}}
		},
		state_slowall_attack={{{1,50},{2,25},{20,35}},{{1,18*3},{20,18*3}}},
		skill_deadlystrike_r={{{1,150},{20,150}}},
	},
	boss_meleesingle={ --boss近身单体
		seriesdamage_r={0},--={{{1,500},{20,500}}},
		colddamage_v={
			[1]={{1,2000*0.9},{2,1000*0.9}},
			[3]={{1,2000*1.1},{2,1000*1.1}}
		},
		skill_deadlystrike_r={{{1,150},{20,150}}},
	},
	boss_wangushixin={ --万蛊蚀心
		damage_all_resist={{{1,-80},{10,-50},{20,-80}}},
		skill_statetime={{{1,18*60},{20,18*90}}}
	},
	boss_limoduohun2={ --厉魔夺魂2
		addphysicsdamage_p={{{1,-150},{20,-50}}},
		addphysicsmagic_p={{{1,-150},{20,-50}}},
		skill_statetime={{{1,18*60},{20,18*90}}}
	},
	boss_bingpohanguang={ --冰魄寒光
		fastwalkrun_p={{{1,-50},{20,-30}}},
		skill_statetime={{{1,18*60},{20,18*90}}}
	},
	boss_wuxinggu={ --无形蛊
		poisondamage_v={{{1,50},{20,1050}},{{1,9*1},{20,9*1}}},
		state_hurt_attack={{{1,25},{20,25}},{{1,18*1},{20,18*1}}},
	},
	boss_wateraoe_big={ --水系大范围攻击
		seriesdamage_r={0},--={{{1,500},{20,500}}},
		state_slowall_attack={{{1,35},{20,35}},{{1,18*3},{20,18*3}}},
		colddamage_v={
			[1]={{1,1500*0.8},{2,750*0.8},{20,1000*0.9}},
			[3]={{1,1500*1.2},{2,750*1.2},{20,1000*1.1}}
		},
		skill_deadlystrike_r={{{1,150},{20,150}}},
	},
	boss_wateraoe_small={ --水系小范围攻击
		seriesdamage_r={0},--={{{1,500},{20,500}}},
		state_slowall_attack={{{1,35},{20,35}},{{1,18*3},{20,18*3}}},
		colddamage_v={
			[1]={{1,1800*0.9},{2,900*0.8},{20,1000*0.9}},
			[3]={{1,1800*1.1},{2,900*1.2},{20,1000*1.1}}
		},
		skill_deadlystrike_r={{{1,150},{20,150}}},
	},
	boss_hurtslowall={ --高后仰迟缓单体
		state_hurt_attack={{{1,75},{20,75}},{{1,18*1},{20,18*1}}},
		state_slowall_attack={{{1,75},{20,75}},{{1,18*3},{20,18*3}}},
	},
	boss_rageattack={ --狂暴减抗加攻
--		addphysicsdamage_p={{{1,50},{20,200}}},
--		addphysicsmagic_p={{{1,50},{20,200}}},
		damage_all_resist={{{1,-500},{2,-500}}},
		addfiremagic_v={{{1,200},{20,1000}}},
		addfiredamage_v={{{1,200},{20,1000}}},
		skill_statetime={{{1,18*300},{20,18*300}}}
	},
	boss_firesquare={ --方形火阵
		seriesdamage_r={0},--={{{1,500},{20,500}}},
		firedamage_v={
			[1]={{1,1800*0.8},{10,260},{20,485*0.9}},
			[3]={{1,1800*1.2},{10,260},{20,485*1.1}}
		},
		state_burn_attack={{{1,35},{20,40}},{{1,18*3},{20,18*3}}},
	},
	boss_chiyanshitian={ --赤焰蚀天
		damage_fire_resist={{{1,-300},{20,-1000}}},
		skill_statetime={{{1,18*15},{20,18*20}}}
	},
	boss_allslowrun={ --全屏降跑速
		fastwalkrun_p={{{1,-60},{20,-60}}},
		skill_statetime={{{1,18*30},{20,18*90}}}
	},
	boss_confuse_middle={ --中范围混乱
		state_confuse_attack={{{1,100},{20,100}},{{1,18*5},{20,18*5}}},
	},
	boss_fireball={ --陨石雨
		seriesdamage_r={0},--={{{1,500},{20,500}}},
		firedamage_v={
			[1]={{1,450*0.8},{1,350*0.8},{10,260},{20,485*0.9}},
			[3]={{1,450*1.2},{1,350*1.2},{10,260},{20,485*1.1}}
		},
		state_stun_attack={{{1,5},{10,5},{20,5}},{{1,18*3},{20,18*3}}},
	},
	boss_roundfirewall={ --自身圆形火墙
		seriesdamage_r={0},--={{{1,500},{20,500}}},
		firedamage_v={
			[1]={{1,500*0.8},{10,260},{20,485*0.9}},
			[3]={{1,500*1.2},{10,260},{20,485*1.1}}
		},
	},
	boss_firetrap={ --火攻陷阱
		seriesdamage_r={0},--={{{1,100},{20,500}}},
		firedamage_v={
			[1]={{1,2450*0.8},{2,1450*0.8},{10,260},{20,485*0.9}},
			[3]={{1,2450*1.2},{2,1450*1.2},{10,260},{20,485*1.1}}
		},
	},
	boss_firetrap_child={ --火攻陷阱子
		seriesdamage_r={0},--={{{1,500},{20,500}}},
		firedamage_v={
			[1]={{1,1450*0.8},{2,750*0.8},{10,260},{20,485*0.9}},
			[3]={{1,1450*1.2},{2,750*1.2},{10,260},{20,485*1.1}}
		},
	},
	boss_ragefire={ --火系怒气攻击
		appenddamage_p= {{{1,0},{10,0},{20,0}}},
		seriesdamage_r={0},--={{{1,500},{20,500}}},
		firedamage_v={
			[1]={	{1,550*0.8},--75级世界boss
					{2,350*0.8},--家族副本75级世界boss
					{3,350*0.8},--高级藏宝图boss
					{4,550*0.8},--100级藏宝图boss
					{10,160},--中级藏宝图boss
					{20,485*0.9}},
			[3]={	{1,550*1.2},
					{2,350*1.2},
					{3,350*1.2},
					{4,550*0.8},--100级藏宝图boss
					{10,160},
					{20,485*1.1}}
		},
		skill_deadlystrike_r={100000}
	},
	boss_tuishantianhai2={ --推山填海2
		seriesdamage_r={0},--={{{1,500},{20,500}}},
		firedamage_v={
			[1]={{1,750*0.8},{2,350*0.8},{10,260},{20,485*0.9}},
			[3]={{1,750*1.2},{2,350*1.2},{10,260},{20,485*1.1}}
		},
	},
	boss_bangdaegou2={ --棒打恶狗2,扇形击退灼伤
		seriesdamage_r={0},--={{{1,500},{20,500}}},
		firedamage_v={
			[1]={{1,1800*0.8},{10,260},{20,485*0.9}},
			[3]={{1,1800*1.2},{10,260},{20,485*1.1}}
		},
		state_burn_attack={{{1,100},{20,100}},{{10,18*5},{20,18*5}}},
		state_knock_attack={{{1,100},{2,100}},{{1,16},{2,16}},{{1,32},{2,32}}},
	},
	boss_tianwailiuxing={ --天外流星
		appenddamage_p= {{{1,0},{10,0},{20,0}}},
		seriesdamage_r={0},--={{{1,500},{20,500}}},
		firedamage_v={
			[1]={{1,1600*0.8},{2,800*0.8},{10,560},{20,485*0.9}},
			[3]={{1,1600*1.2},{2,800*1.2},{10,760},{20,485*1.1}}
		},
		skill_deadlystrike_r={200}
	},
	boss_yehuofencheng={ --业火焚城
		appenddamage_p= {{{1,100},{10,0},{20,100}}},
		seriesdamage_r={0},--={{{1,500},{10,500},{20,500}}},
		firedamage_v={
			[1]={{1,350*0.8},{2,250*0.8},{10,80},{20,485*0.9}},
			[3]={{1,350*1.2},{2,250*1.2},{10,150},{20,485*1.1}}
		},
		skill_deadlystrike_r={200}
	},
	boss_highreturn={ --强化反弹
		addphysicsdamage_p={{{1,500},{20,300}}},
		addphysicsmagic_p={{{1,500},{20,300}}},
		skill_statetime={{{1,18*30},{20,18*30}}}
	},
	boss_highreturn_child={ --强化反弹子
		meleedamagereturn_p={{{1,500},{20,300}}},
		rangedamagereturn_p={{{1,500},{20,300}}},
		poisondamagereturn_p={{{1,500},{20,300}}},
		skill_statetime={{{1,18*15},{20,18*15}}}
	},
	boss_silence={ --持续扣内沉默
		fastmanareplenish_v={{{1,-99999},{20,-99999}}},
		skill_statetime={{{1,18*30},{20,18*30}}}
	},
	boss_slowknock={ --降跑速击退
		fastwalkrun_p={{{1,-119},{20,-119}}},
		skill_statetime={{{1,18*30},{20,18*90}}}
	},
	boss_slowknock_child={ --降跑速击退子
		state_knock_attack={{{1,100},{2,100}},{{1,16},{2,16}},{{1,32},{2,32}}},
	},
	boss_hpreplenishdown={ --回血效率降低
		lifereplenish_p={{{1,-100},{20,-100}}},
		skill_statetime={{{1,18*40},{20,18*30}}}
	},
	boss_hpmaxdown={ --生命最大值降低
		lifemax_p={{{1,-65},{20,-50}}},
		skill_statetime={{{1,18*45},{20,18*30}}}
	},
	boss_mpmaxdown={ --内力最大值降低
		manamax_p={{{1,-65},{20,-50}}},
		skill_statetime={{{1,18*60},{20,18*30}}}
	},
	boss_lightresdown={ --雷抗降低
		damage_light_resist={{{1,-300},{20,-500}}},
		skill_statetime={{{1,18*60},{20,18*90}}}
	},
	boss_attackratingdown={ --幻影飞狐
		attackratingenhance_p={{{1,-100},{20,-150}}},
		skill_statetime={{{1,18*60},{20,18*300}}}
	},
	boss_physicsdamagegdown={ --减外攻加内攻
		addphysicsdamage_p={{{1,-300},{20,-300}}},
		addphysicsmagic_p={{{1,300},{20,300}}},
		skill_statetime={{{1,18*45},{20,18*45}}}
	},
	boss_physicsmagicdown={ --减内攻加外攻
		addphysicsdamage_p={{{1,300},{20,300}}},
		addphysicsmagic_p={{{1,-300},{20,-300}}},
		skill_statetime={{{1,18*45},{20,18*45}}}
	},
	boss_rageearth={	--土系怒气攻击,1级为75级boss用,2级为家族75级boss用,3级为80-90级任务副本用
		appenddamage_p= {{{1,0},{10,0},{20,0}}},
		state_stun_attack={{{1,45},{2,45}},{{1,18*2},{2,18*2}}},
		lightingdamage_v={
			[1]={{1,500*0.9},{2,250*0.9},{3,200*0.9},{20,1000*0.9}},
			[3]={{1,500*1.1},{2,250*1.1},{3,200*1.1},{20,1000*1.1}}
		},
		skill_deadlystrike_r={100000},
		seriesdamage_r={0},--={{{1,500},{20,500}}},
	},
	boss_rageearth_child={	--土系怒气攻击子子_圆形延时
		appenddamage_p= {{{1,0},{10,0},{20,0}}},
		lightingdamage_v={
			[1]={{1,500*0.9},{2,250*0.9},{20,1000*0.9}},
			[3]={{1,500*1.1},{2,250*1.1},{20,1000*1.1}}
		},
		skill_deadlystrike_r={100000},
		seriesdamage_r={0},--={{{1,500},{20,500}}},
	},
	boss_followmanyattack={	--跟随多段攻击
		lightingdamage_v={
			[1]={{1,1500*0.9},{2,800*0.9},{3,1*0.9},{20,1000*0.9}},
			[3]={{1,1500*1.1},{2,800*1.1},{3,1*1.1},{20,1000*1.1}}
		},
		skill_deadlystrike_r={{{1,150},{20,150}}},
		state_stun_attack={{{1,75},{20,75}},{{1,18*1},{20,18*1}}},
		seriesdamage_r={0},--={{{1,500},{20,500}}},
	},
	boss_followmanyattack_child={	--跟随多段攻击
		lightingdamage_v={
			[1]={{1,1500*0.9},{2,800*0.9},{20,1000*0.9}},
			[3]={{1,1500*1.1},{2,800*1.1},{20,1000*1.1}}
		},
		skill_deadlystrike_r={{{1,150},{20,150}}},
		state_stun_attack={{{1,100},{20,100}},{{1,18*1},{20,18*1}}},
		seriesdamage_r={0},--={{{1,500},{20,500}}},
	},
	boss_kuangleizhendi={	--狂雷震地
		lightingdamage_v={
			[1]={{1,1500*0.9},{2,600*0.9},{20,1000*0.9}},
			[3]={{1,1500*1.1},{2,600*1.1},{20,1000*1.1}}
		},
		skill_deadlystrike_r={{{1,150},{20,150}}},
		state_stun_attack={{{1,35},{20,35}},{{1,18*2},{20,18*2}}},
		seriesdamage_r={0},--={{{1,500},{20,500}}},
	},
	boss_tianjixunlei={	--天际迅雷
		lightingdamage_v={
			[1]={{1,1000*0.9},{2,600*0.9},{10,260},{20,1000*0.9}},
			[3]={{1,1000*1.1},{2,600*1.1},{10,260},{20,1000*1.1}}
		},
		skill_deadlystrike_r={{{1,150},{20,150}}},
		state_stun_attack={{{1,35},{20,35}},{{1,18*1.5},{20,18*1.5}}},
		seriesdamage_r={0},--={{{1,500},{20,500}}},
	},
	boss_tianjixunlei_child={	--天际迅雷_雷阵
		lightingdamage_v={
			[1]={{1,750*0.9},{2,450*0.9},{10,260},{20,1000*0.9}},
			[3]={{1,750*1.1},{2,450*1.1},{10,260},{20,1000*1.1}}
		},
		skill_deadlystrike_r={{{1,150},{20,150}}},
		state_stun_attack={{{1,35},{20,35}},{{1,18*1.5},{20,18*1.5}}},
		seriesdamage_r={0},--={{{1,500},{20,500}}},
	},
	boss_autoqiwutuisan={ --自动释放清除纯阳
		autoskill={{{1,19},{2,19}},{{1,1},{10,10}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	boss_eliminatemagicshield={	--清除纯阳无极
		--removestate={{{1,497},{2,161},{3,132},{10,694}}},
		removeshield={1},
		--skill_statetime={{{1,18*20},{19,18*60},{20,-1}}},
	},
	boss_weakenmanashield={ --降低坐忘抵消伤害比率
		manashield_p={{{1,-55},{10,-100},{20,-200}}},
		skill_statetime={{{1,18*300},{19,18*300},{20,-1}}},
	},
	boss_duchuanran={ --30秒内传染毒伤害
		infectpoison={{{1,10},{10,100},{20,200}}},
		skill_statetime={{{1,18*30},{19,18*30}}},
	},
-------------------------------------------------120级boss-------------------------------------------
	boss_seriesattack={ --附带5种五行效果
		skill_deadlystrike_r={{{1,150},{20,150}}},
		state_stun_attack={{{1,2},{10,40}},{{1,18*1},{20,18*1}}},
		state_hurt_attack={{{1,2},{10,40}},{{1,18*1},{20,18*1}}},
		state_weak_attack={{{1,2},{10,40}},{{1,18*3},{20,18*3}}},
		state_burn_attack={{{1,2},{10,40}},{{1,18*3},{20,18*3}}},
		state_slowall_attack={{{1,2},{10,40}},{{1,18*2.5},{20,18*2.5}}},
	},
	boss_neigongmianyi_120={ --内功免疫
		ignoreskill={{{1,10},{10,100}},0,{{1,2},{2,2}}},
	},
	boss_waigongmianyi_120={ --外功免疫
		ignoreskill={{{1,10},{10,100}},0,{{1,4},{2,4}}},
	},
	boss_hitadd={ --命中提高
		attackratingenhance_p={{{1,500},{10,500}}},
		ignoreresist_p={{{1,0},{10,0},{11,200}},{{1,0},{10,0},{11,100}}},
	},
--秦始皇陵debuff
	qinshihuang_debuff={
		damage_all_resist		={{{1,-999},{10,-999}}},
		skilldamageptrim		={{{1,-90},{10,-90}}},
		skillselfdamagetrim		={{{1,-90},{10,-90}}},
		fastwalkrun_p			={{{1,-80},{10,-80}}},
	},
	qinshihuang_buff={
		damage_all_resist		={{{1,999},{10,999}}},
		skilldamageptrim		={{{1,90},{10,90}}},
		skillselfdamagetrim		={{{1,90},{10,90}}},
		fastwalkrun_p			={{{1,80},{10,80}}},
	},
---------------------------------------------------跨服白虎堂----------------------------------------	
	kfbhtbossjineng={ --跨服白虎boss技能1_10
		appenddamage_p= {{{1,300},{10,300}}},
	},
	kfbhtbossjineng_child={ --跨服白虎boss技能1子_10
		appenddamage_p= {{{1,10000},{10,10000}}},
	},
	kfbhtbossjineng_child2={ --跨服白虎boss技能1子子_10
		appenddamage_p= {{{1,300},{10,300}}},
		physicsenhance_p={{{1,125},{10,125}}},
		seriesdamage_r={0},--={{{1,250},{10,250}}},
		state_stun_attack={{{1,40},{10,40}},{{1,18*1},{10,18*1}}},
		state_hurt_attack={{{1,40},{10,40}},{{1,18*1},{10,18*1}}},
		state_weak_attack={{{1,40},{10,40}},{{1,18*3},{10,18*3}}},
		state_burn_attack={{{1,40},{10,40}},{{1,18*3},{10,18*3}}},
		state_slowall_attack={{{1,40},{10,40}},{{1,18*2.5},{10,18*2.5}}},
	},
	zhaohuannpc={ --召唤npc
		missile_callnpc={{{1,7286 * 65536 + 75},{10,7286 * 65536 + 75}},{{1,18*60},{10,18*60}},{{1,-1},{10,-1}}},
	},
	bhtbosswuxinggu={ --boss变态无形蛊_10
		appenddamage_p= {{{1,20},{10,20}}},
		fastlifereplenish_v={{{1,-400},{10,-400}}},
		fastmanareplenish_v={{{1,-250},{10,-250}}},
		faststaminareplenish_v={{{1,-150},{10,-150}}},
		missile_hitcount={{{1,10},{10,10}}},
		skill_appendskill={{{1,1836},{10,1836}},{{1,1},{10,10}}},
	},
	bhtbosswuxinggu_child={ --boss变态无形蛊子_10
		skilldamageptrim={{{1,20},{10,20}}},
		rangedamagereturn_p={{{1,10},{10,10}}},
	},
	bhtmiaoshazidan={ --秒杀子弹
		appenddamage_p= {{{1,10000},{10,10000}}},
	},
	kubhtnormalattack2={ --慕容燕攻击技能2
		physicsenhance_p={{{1,0},{2,0}}},
		seriesdamage_r={0},--={{{1,265},{10,265}}},
		skill_deadlystrike_r={{{1,212},{10,212}}},
		state_slowall_attack={{{1,15},{10,15}},{{1,18*2},{10,18*2}}},
	},
	kubhtnormalattack1={ --慕容燕攻击技能1
		physicsenhance_p={{{1,0},{2,0}}},
		seriesdamage_r={0},--={{{1,265},{10,265}}},
		skill_deadlystrike_r={{{1,212},{10,212}}},
		state_slowall_attack={{{1,15},{10,15}},{{1,18*2},{10,18*2}}},
	},
---------------------------------------------------克夷门战场----------------------------------------	
	boss_autodmg_state={ --自动伤害
		autoskill={{{1,119},{2,119}},{{1,1},{10,10}}},
		skill_statetime={{{1,-1},{20,-1}}},
	},
}

FightSkill:AddMagicData(tb)
