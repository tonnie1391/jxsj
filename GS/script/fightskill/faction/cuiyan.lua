Require("\\script\\fightskill\\fightskill.lua")
local nA0 = FightSkill.tbParam.nSadd;	--攻速类攻击技能+1的成长系数
local nA1 = FightSkill.tbParam.nSadd1;	--格斗类攻击技能+1的成长系数
local nS01 = FightSkill.tbParam.nS1;	--技能1级的数值系数
local nS20 = FightSkill.tbParam.nS20;	--技能20级的数值系数

--翠烟
local tb	= {
	--剑翠
	fengjuancanxue={ --风卷残雪_20
		appenddamage_p= {{{1,100},{20,100},{21,100*nA0}}},
		colddamage_v={
			[1]={{1,50*0.9},{10,410*1.1},{20,810*0.9},{21,810*nA0*0.9}},
			[3]={{1,50*1.1},{10,410*1.1},{20,810*1.1},{21,810*nA0*1.1}}
		},
		state_slowall_attack={{{1,15},{10,30},{20,35},{21,36}},{{1,27},{20,45},{21,45}}},
		seriesdamage_r={0},--={{{1,50},{20,100},{21,100}}},
		skill_cost_v={{{1,10},{20,50},{21,50}}},
		addskilldamagep={114, {{1,2},{20,30},{21,35}},1},
		addskilldamagep2={117, {{1,2},{20,10},{21,12}},1},
		addskilldamagep3={118, {{1,2},{20,10},{21,12}}},
	},
	cuiyanjianfa={ --翠烟剑法_10
		addcoldmagic_v={{{1,15},{10,300},{11,330}}},
		deadlystrikeenhance_r={{{1,30},{10,50},{11,55}}},
		castspeed_v={{{1,5},{10,15},{11,16},{12,17},{13,17}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	hutihanbing={ --护体寒冰_10
		rangedamagereturn_p={{{1,5},{10,20},{11,21}}},
		adddefense_v={{{1,100},{10,200},{11,210}}},
		lifemax_p={{{1,15},{10,45},{14,54}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	bihaichaosheng={ --碧海潮生_20
		appenddamage_p= {{{1,100},{10,110},{20,120},{21,120*nA0}}},
		colddamage_v={
			[1]={{1,400*0.9},{10,490*0.9},{20,540*0.9},{21,540*nA0*0.9}},
			[3]={{1,400*1.1},{10,490*1.1},{20,540*1.1},{21,540*nA0*1.1}}
		},
		state_slowall_attack={{{1,30},{10,45},{20,50},{21,51}},{{1,27},{20,45},{21,45}}},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		skill_cost_v={{{1,50},{20,150},{21,150}}},
		addskilldamagep={117, {{1,2},{20,30},{21,35}},1},
		addskilldamagep2={118, {{1,2},{20,30},{21,35}}},
		missile_hitcount={{{1,5},{5,5},{10,6},{15,6},{20,7},{21,7}}},
	},
	xueying={ --雪影_20
		fastwalkrun_p={{{1,10},{20,40},{21,41}}},
		state_burn_resisttime={{{1,15},{20,135},{21,141}}},
		skill_cost_v={{{1,100},{10,150},{20,300},{21,300}}},
		skill_statetime={300*18},
	},
	xuanbingwuxi={ --玄冰无息_10
		autoskill={{{1,15},{2,15}},{{1,1},{10,10}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	xuanbingwuxi_child={ --玄冰无息子_10
		state_freeze_attack={{{1,25},{10,75},{11,80}},{{1,18*1.5},{10,18*3},{11,18*3.1}}},
		missile_hitcount={{{1,3},{10,5},{11,5}}},
	},
	xuanbingwuxi_self={ --玄冰无息自身
		damage_all_resist={{{1,800},{10,1200},{11,1220}}},
		skill_statetime={{{1,18*1},{10,18*1.5},{12,18*1.6}}},
	},
	xueyinghongchen_team={ --雪映红尘_20
		lifereplenish_p={{{1,5},{20,15},{21,16}}},
		manareplenish_p={{{1,2},{20,10},{21,11}}},
	},
	xueyinghongchen={ --雪映红尘
		lifereplenish_p={{{1,10},{20,30},{21,31}}},
		manareplenish_p={{{1,10},{20,20},{21,21}}},
	},
	bingxinxianzi={ --冰心仙子
		--keephide={0},
		appenddamage_p= {{{1,90*nS01},{10,90},{20,90*nS20},{21,90*nS20*nA0}}},
		colddamage_v={
			[1]={{1,400*0.9*nS01},{10,400*0.9},{20,400*0.9*nS20},{21,400*0.9*nS20*nA0}},
			[3]={{1,400*1.1*nS01},{10,400*1.1},{20,400*1.1*nS20},{21,400*1.1*nS20*nA0}}
			},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		skill_cost_v={{{1,100},{20,200},{21,200}}},
		skill_flyevent={{{1,118},{20,118}},{{1,3},{2,3}}},
		skill_showevent={{{1,2},{20,2}}},
		missile_hitcount={{{1,5},{5,5},{10,6},{15,6},{20,7},{21,7}}},
	},
	fengxuebingtian={ --风雪冰天，冰心仙子第二式
		appenddamage_p= {{{1,35*nS01},{10,35},{20,35*nS20},{21,35*nS20*nA0}}},
		colddamage_v={
			[1]={{1,225*0.9*nS01},{10,225*0.9},{20,225*0.9*nS20},{21,225*0.9*nS20*nA0}},
			[3]={{1,225*1.1*nS01},{10,225*1.1},{20,225*1.1*nS20},{21,225*1.1*nS20*nA0}}
			},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		state_slowall_attack={{{1,30},{10,45},{20,50}},{{1,27},{20,45},{21,45}}},
		missile_hitcount={{{1,2},{10,3},{20,4},{21,4}}},
	},
	bingguxuexin={ --冰骨雪心_20
		state_slowall_attackrate={{{1,10},{20,100}}},
		state_burn_resistrate={{{1,10},{10,100},{20,150}}},
		castspeed_v={{{1,10},{10,16},{20,26},{23,29},{24,29}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	fuyunsanxue={ --浮云散雪
		skilldamageptrim={{{1,1},{10,10}}},
		skillselfdamagetrim={{{1,1},{10,10}}},
		state_slowall_attacktime={{{1,10},{10,80}}},
		state_burn_resisttime={{{1,10},{10,120}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	
	yudalihua={ --中级秘籍：雨打梨花
		state_fixed_ignore={1},
		state_palsy_ignore={1},
		state_confuse_ignore={1},
		state_knock_ignore={1},
		state_drag_ignore={1},
		state_freeze_ignore={1},
		skill_mintimepercast_v={{{1,40*18},{10,20*18},{11,20*18}}},
		skill_mintimepercastonhorse_v={{{1,40*18},{10,20*18},{11,20*18}}},
		skill_skillexp_v=FightSkill.tbParam.tbMidBookSkillExp,
		skill_statetime={{{1,18*0.5},{10,18*5},{12,18*5.5}}},
	},
	yudalihua_child={ --中级秘籍：雨打梨花
		damage_cold_resist={{{1,-110},{10,-200},{11,-210}}},
		state_slowall_attack={{{1,35},{10,80},{12,85}},{{1,18*3},{10,18*5},{11,18*5}}},
		missile_hitcount={{{1,3},{2,3}}},
		skill_statetime={{{1,18*2},{10,18*5},{11,18*5}}},
	},	
	yudalihua_child2={ --中级秘籍：春泥护花
		state_palsy_resistrate		={{{1,26},{10,260},{11,286}}},
		state_confuse_resistrate	={{{1,26},{10,260},{11,286}}},
		state_knock_resistrate		={{{1,26},{10,260},{11,286}}},
		state_drag_resistrate		={{{1,26},{10,260},{11,286}}},
		skill_statetime={300*18},
	},	
	shimianmaifu_self={ --十面埋伏自身_10
		addenchant={31, {{1,1}, {2, 2}}},
		skilldamageptrim={{{1,2},{10,20}}},
		skillselfdamagetrim={{{1,2},{10,20}}},
		skill_statetime={{{1,18*30},{10,18*30}}},
		skill_startevent={{{1,1193},{10,1193}}},
		skill_eventskilllevel={{{1,1},{10,10},{11,10}}},
		skill_showevent={{{1,1},{10,1}}},
		skill_cost_v={{{1,100},{10,100},{11,100}}},
		skill_mintimepercast_v={{{1,80*18},{10,80*18},{11,80*18}}},
		skill_mintimepercastonhorse_v={{{1,80*18},{10,80*18},{11,80*18}}},
	},
	shimianmaifu={ --十面埋伏_队友_10
		autoskill={{{1,71},{2,71}},{{1,1},{10,10}}},
		skill_statetime={{{1,10*18},{10,15*18},{11,15*18}}},
		--missile_hitcount={{{1,6},{10,12}}},
	},
	shimianmaifu_child={ --十面埋伏_队友_子_10
		hide={0,{{1,2*18},{10,2*18}}, 2},
	},

	jiancuiadvancedbook={ --剑翠高级秘籍_飞絮飘花_10
		--skill_cost_v={{{1,200},{10,200}}},
		appenddamage_p= {{{1,15*0.5},{10,15},{11,15*1.05}}},
		colddamage_v={
			[1]={{1,67.5*0.9*0.5},{10,67.5*0.9},{11,67.5*0.9*1.05}},
			[3]={{1,67.5*1.1*0.5},{10,67.5*1.1},{11,67.5*1.1*1.05}}
			},
		seriesdamage_r={0},--={{{1,250},{10,250}}},
		state_slowall_attack={{{1,3},{10,30}},{{1,45},{10,45}}},
		state_fixed_attack={{{1,1},{10,15}},{{1,18*3},{10,18*3}}},
	},
	jiancuiadvancedbook_fellow={ --剑翠高级秘籍_10
		skill_cost_v={{{1,200},{10,200}}},
		skill_mintimepercast_v={{{1,15*18},{10,15*18}}},
		skill_mintimepercastonhorse_v={{{1,15*18},{10,15*18}}},
		skill_skillexp_v=FightSkill.tbParam.tbHighBookSkillExp,
		skill_maxmissile={{{1,3},{10,3}}},
	},
	jiancui120={ --剑翠120_10
		autoskill={{{1,53},{2,53}},{{1,1},{10,10}}},
		skill_statetime={{{1,15*18},{2,15*18}}},
		skill_cost_v={{{1,500},{10,500}}},
		skill_mintimepercast_v={{{1,10*18},{10,10*18}}},
		skill_mintimepercastonhorse_v={{{1,10*18},{10,10*18}}},
	},
	jiancui120_child={ --剑翠120_子_10
		appenddamage_p= {{{1,75*0.7},{10,75},{11,75*nA0}}},
		colddamage_v={
			[1]={{1,350*0.9*0.7},{10,350*0.9},{11,350*0.9*nA0}},
			[3]={{1,350*1.1*0.7},{10,350*1.1},{11,350*1.1*nA0}}
			},
		seriesdamage_r={0},--={{{1,250},{10,250}}},
		state_slowall_attack={{{1,45},{10,50}},{{1,45},{10,45}}},
	},
	
	--刀翠
	fenghuaxueyue={ --风花雪月_20
		appenddamage_p= {{{1,100},{20,100},{21,100*nA0}}},
		seriesdamage_r={0},--={{{1,50},{20,100},{21,100}}},
		physicsenhance_p={{{1,10},{10,100},{20,150},{21,157}}},
		colddamage_v={
			[1]={{1,50*0.85},{10,245*0.9},{20,450*0.9},{21,450*nA0*0.9}},
			[3]={{1,50*1.15},{10,245*1.1},{20,450*1.1},{21,450*nA0*1.1}}
		},
		state_hurt_attack={{{1,15},{20,35},{21,36}},{{1,18},{20,18}}},
		state_slowall_attack={{{1,30},{10,45},{20,50},{21,51}},{{1,27},{20,45},{21,45}}},
		skill_cost_v={{{1,2},{20,20},{21,20}}},
		addskilldamagep={123, {{1,2},{20,30},{21,35}},1},
		addskilldamagep2={125, {{1,2},{20,10},{21,12}},1},
		addskilldamagep3={126, {{1,2},{20,10},{21,12}}},
		missile_speed_v={40},
		missile_range={1,0,1},
	--	attackrating_p={{{1,20},{20,70}}},
	},
	cuiyandaofa={ --翠烟刀法_10
		addphysicsdamage_p={{{1,10},{10,150},{11,165}}},
		attackratingenhance_p={{{1,50},{10,150},{11,165}}},
		deadlystrikeenhance_r={{{1,30},{10,50},{11,55}}},
		attackspeed_v={{{1,5},{10,15},{11,16},{12,17},{13,17}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	yuxueyin={ --御雪隐_10
		hide={0,{{1,5*18},{10,30*18},{13,33*18}}, 1},
		keephide={1},
		cri_resist={{{1,1},{10,12000},{11,12700}}},
		autoskill={{{1,136},{2,136}},{{1,1},{10,10}}},
		autoskill2={{{1,120},{2,120}},{{1,1},{10,10}}},
		skill_cost_v={{{1,50},{10,100},{11,100}}},
		skill_statetime={{{1,5*18},{10,30*18},{13,33*18}}},
		skill_mintimepercast_v={{{1,60*18},{10,20*18},{11,20*18}}},
		skill_mintimepercastonhorse_v={{{1,60*18},{10,20*18},{11,20*18}}},
	},
	yuxueyin_child={ --御雪隐_被击删除隐身
		clearhide={1},
	},
	liufenghuixue={ --流风回雪_20
		autoskill={{{1,121},{2,121}},{{1,1},{20,20}}},
		deadlystrikeenhance_r={{
			{ 1,100  },
			{ 2,187  },
			{ 3,283  },
			{ 4,417  },
			{ 5,535  },
			{ 6,667  },
			{ 7,853  },
			{ 8,1023 },
			{ 9,1214 },
			{10,1492 },
			{11,1753 },
			{12,2142 },
			{13,2518 },
			{14,2971 },
			{15,3688 },
			{16,4433 },
			{17,5407 },
			{18,7147 },
			{19,9276 },
			{20,14000},
			{21,14700}}},
		attackspeed_v={{{1,5},{20,100},{21,100}}},
		keephide={1},
		skill_cost_v={{{1,50},{20,100},{21,100}}},
		skill_statetime={{{1,30*18},{20,30*18}}},
		skill_mintimepercast_v={{{1,60*18},{20,10*18},{21,10*18}}},
		skill_mintimepercastonhorse_v={{{1,60*18},{20,10*18},{21,10*18}}},
	},
	liufenghuixue_child={ --流风回雪_子_20
		fastwalkrun_p={{{1,10},{20,40},{21,41}}},
		skill_statetime={300*18},
	},
	muyeliuxing={ --牧野流星_20
		appenddamage_p= {{{1,50},{20,50},{21,50*nA0}}},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		physicsenhance_p={{{1,50},{10,86},{20,126},{21,126*nA0}}},
		colddamage_v={
			[1]={{1,100*0.95},{10,190*0.9},{20,290*0.95},{21,290*nA0*0.95}},
			[3]={{1,100*1.05},{10,190*1.1},{20,290*1.05},{21,290*nA0*1.05}}
		},
		state_hurt_attack={{{1,5},{20,15},{21,16}},{{1,18},{20,18}}},
		state_slowall_attack={{{1,30},{10,45},{20,50},{21,51}},{{1,27},{20,45},{21,46}}},
		skill_cost_v={{{1,20},{20,50},{21,50}}},
		addskilldamagep={125, {{1,2},{20,30},{21,35}},1},
		addskilldamagep2={126, {{1,2},{20,30},{21,35}}},
		missile_range={1,0,1},
	--	attackrating_p={{{1,30},{20,90}}},
	},
	bingxinqianying={ --冰心倩影_20
		autoskill={{{1,122},{2,122}},{{1,1},{20,20}}},
		attackratingenhance_p={{{1,10},{20,200},{21,210}}},
		--adddefense_v={{{1,50},{10,150},{20,200},{22,220}}},
		deadlystrikedamageenhance_p={{{1,1},{20,20},{21,21}}},
		state_palsy_resisttime		={{{1,26},{20,260},{21,286}}},
		state_confuse_resisttime	={{{1,26},{20,260},{21,286}}},
		state_knock_resistrate		={{{1,26},{20,260},{21,286}}},
		state_drag_resisttime		={{{1,26},{20,260},{21,286}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	bingxinqianying_child={ --冰心倩影_子_20
		adddefense_v	={{{1,-5},{20,-50},{22,-55}}},
		ignoreskill		={{{1,-1},{20,-20},{22,-22}},0,{{1,3},{2,3}}},
		superposemagic	={{{1,10},{20,10},{22,10}}},
		skill_statetime={{{1,3.5*18},{2,3.5*18}}},
	},
	bingzongwuying={ --冰踪无影
		appenddamage_p= {{{1,35*nS01},{10,35},{20,35*nS20},{21,35*nS20*nA0}}},
		physicsenhance_p={{{1,80*nS01},{10,80},{20,80*nS20},{21,80*nS20*nA0}}},
		colddamage_v={
			[1]={{1,350*0.9*nS01},{10,350*0.9},{20,350*0.9*nS20},{21,350*0.9*nS20*nA0}},
			[3]={{1,350*1.1*nS01},{10,350*1.1},{20,350*1.1*nS20},{21,350*1.1*nS20*nA0}}
			},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		skill_cost_v={{{1,50},{20,100},{21,100}}},
		--attackrating_p={{{1,100},{20,100}}},
		state_hurt_attack={{{1,5},{20,20}},{{1,18},{20,18}}},
		state_slowall_attack={{{1,5},{20,15}},{{1,27},{20,45},{21,45}}},
		skill_startevent={{{1,126},{20,126}}},
		skill_showevent={{{1,1},{20,1}}},
		missile_hitcount={{{1,3},{20,3}}},
		missile_range={2,1,2},
	},
	bingxinxuelian={ --冰心雪莲，冰踪无影第二式
		appenddamage_p= {{{1,60*nS01},{10,60},{20,60*nS20},{21,60*nS20*nA0}}},
		physicsenhance_p={{{1,150*nS01},{10,150},{20,150*nS20},{21,150*nS20*nA0}}},
		colddamage_v={
			[1]={{1,750*0.9*nS01},{10,750*0.9},{20,750*0.9*nS20},{21,750*0.9*nS20*nA0}},
			[3]={{1,750*1.1*nS01},{10,750*1.1},{20,750*1.1*nS20},{21,750*1.1*nS20*nA0}}
			},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		state_slowall_attack={{{1,10},{10,25},{20,35}},{{1,27},{20,45},{21,45}}},
		missile_hitcount={{{1,3},{20,3}}},
		missile_range={3,0,3},
	},
	bingjiyugu={ --冰肌玉骨_20
	--	state_hurt_attackrate={{{1,10},{20,100}}},
		state_slowall_attackrate={{{1,10},{20,100}}},
		state_burn_resistrate={{{1,10},{10,100},{20,150}}},
		attackspeed_v={{{1,10},{10,16},{20,26},{23,29},{24,29}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	qianlibingfeng={ --千里冰封
		skilldamageptrim={{{1,1},{10,10}}},
		skillselfdamagetrim={{{1,1},{10,10}}},
		--state_hurt_attacktime={{{1,10},{20,135}}},
		state_slowall_attacktime={{{1,10},{10,80}}},
		state_burn_resisttime={{{1,10},{10,120}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	
	taxuewuhen={ --中级秘籍：踏雪无痕
		addenchant={8, {{1,1}, {2, 2}}},
		--addmissilespeed={120, 0, {{1,6}, {10, 15}}},
		autoskill={{{1,28},{2,28}},{{1,1},{10,10}}},
		skill_skillexp_v=FightSkill.tbParam.tbMidBookSkillExp,
		skill_statetime={{{1,-1},{2,-1}}},
		--{szMagicName = "addmissilespeed", tbValue = {120, 0, {{1,6}, {10, 15}}}},
		--{szMagicName = "addmissilerange", tbValue = {123, {{1,1}, {10, 1}}}},
		--{szMagicName = "addmissilerange", tbValue = {125, {{1,1}, {10, 1}}}},
		--{szMagicName = "autoskill", tbValue = {{{1,28},{2,28}},{{1,1},{10,10}}}},
		--{szMagicName = "skill_skillexp_v", tbValue = FightSkill.tbParam.tbMidBookSkillExp},
		--{szMagicName = "skill_statetime", tbValue = {{{1,-1},{2,-1}}}},
	},
	
	taxuewuhen_child={ --中级秘籍：踏雪无痕
		fastwalkrun_p={{{1,-20},{10,-40},{11,-40}}},
		skill_statetime={{{1,18*3},{10,18*6},{11,18*7}}},
	},
	taxuewuhen_child2={ --中级秘籍：踏雪无痕
		state_hurt_ignore={1},
		state_slowall_ignore={1},
		state_fixed_ignore={1},
		state_palsy_ignore={1},
		state_knock_ignore={1},
		skill_statetime={{{1,18*1.5},{10,18*3},{11,18*3}}},
	},
	
	guiqulaixi={ --寒月烟锁_10
		autoskill={{{1,36},{2,36}},{{1,1},{10,10}}},
		deadlystrikedamageenhance_p={{{1,13},{10,40},{11,42}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	guiqulaixi_child={ --寒月烟锁_10
		redeivedamage_dec_p2={{{1,-2},{10,-40},{11,-42}}},
		skilldamageptrim={{{1,-2},{10,-40},{12,-42}}},
		skillselfdamagetrim={{{1,-2},{10,-40},{12,-42}}},
		skill_statetime={{{1,2*60*18},{2,2*60*18}}},
	},
	daocuiadvancedbook={ --刀翠高级秘籍_夜来西风_10
		keephide={1},
		state_freeze_attack={{{1,25},{10,75}},{{1,18*3},{10,18*7.5},{11,18*8}}},
		state_fixed_attack={{{1,25},{10,75}},{{1,18*3},{10,18*7.5},{11,18*8}}},
		missile_hitcount={{{1,2},{10,11},{11,12}}},
		skill_cost_v={{{1,100},{10,100}}},
		skill_mintimepercast_v={{{1,45*18},{10,45*18}}},
		skill_mintimepercastonhorse_v={{{1,45*18},{10,45*18}}},
		skill_skillexp_v=FightSkill.tbParam.tbHighBookSkillExp,
	},
	daocui120={ --刀翠120_10
		skilldamageptrim={{{1,1},{10,10},{12,11}}},
		skillselfdamagetrim={{{1,1},{10,10},{12,11}}},
		autoskill={{{1,57},{2,57}},{{1,1},{10,10}}},
		keephide={1},
		skill_cost_v={{{1,100},{10,100}}},
		skill_mintimepercast_v={{{1,3*18},{10,3*18}}},
		skill_mintimepercastonhorse_v={{{1,3*18},{10,3*18}}},
		skill_statetime={300*18},
	},
	daocui120_child={ --刀翠120_伤害增加_10
		autoskill={{{1,58},{2,58}},{{1,1},{10,10}}},
		skilldamageptrim={{{1,1},{10,10},{12,11}}},
		skillselfdamagetrim={{{1,1},{10,10},{12,11}}},
		superposemagic={{{1,3},{10,30}}},
		skill_statetime={{{1,90*18},{2,90*18}}},
	},
	daocui120_child1={ --刀翠120_子1_10
		skill_appendskill={{{1,1648},{10,1648}},{{1,1},{10,10}}},
	},
	daocui120_child2={ --刀翠120_子2_不中隐身_10
		autoskill={{{1,72},{2,72}},{{1,1},{10,10}}},
		keephide={1},
		skill_statetime={{{1,18},{2,18}}},
	},
}

FightSkill:AddMagicData(tb)

local tbSkill	= FightSkill:GetClass("yuxueyin");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	return string.format("<color=gold>[御雪隐]<color>状态消失同时也会强制解除隐身");
end
function tbSkill:GetAutoDesc2(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local szMsg	= string.format("被攻击<color=gold>%s次<color>后解除本状态\n<color=gold>%s秒<color>内的多次攻击只会被当做1次攻击",
		tbAutoInfo.nCastCount,
		FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime)
		);
	--[[local tbMsg = {};
	local szMsg = "";
	szMsg = szMsg.."被攻击对自身释放：\n";
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0);
	for i=1, #tbMsg do
		szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	szMsg = szMsg.."\n触发间隔：<color=Gold>"..FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime).."秒<color>";]]
	return szMsg;
end;
--[[
function tbSkill:GetAutoDesc2(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbMsg = {};
	local szMsg = "";
	szMsg = szMsg.."状态消失时对自身释放：\n";
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0);
	for i=1, #tbMsg do
		szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	szMsg = szMsg.."\n触发间隔：<color=Gold>"..FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime).."秒<color>";
	return szMsg;
end;]]
local tbSkill	= FightSkill:GetClass("liufenghuixue");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local szMsg	= string.format("攻击<color=gold>%s次<color>后效果消失", tbAutoInfo.nCastCount);
	return szMsg;
end;

local tbSkill	= FightSkill:GetClass("bingxinqianying");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbMsg = {};
	local szMsg = "";
	
	szMsg = szMsg.."\n每<color=gold>"..FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime).."秒<color>自动对附近敌人释放：\n";
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0);
	for i=1, #tbMsg do
		szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	return szMsg;
end;

local tbSkill	= FightSkill:GetClass("xuanbingwuxi");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbCCInfo	= KFightSkill.GetSkillInfo(tbChildInfo.tbEvent.nStartSkillId, tbChildInfo.tbEvent.nLevel);
	local szMsg	= string.format("生命降到25%%时触发几率：<color=gold>%d%%<color>\n最多同时影响目标：<color=gold>%d个<color>\n造成周围对手冻结的几率：<color=gold>%s%%<color>，持续<color=gold>%s秒<color>\n自身所有抗性：<color=gold>增加%s<color>，持续<color=gold>%s秒<color>\n触发间隔时间：<color=Gold>%s秒<color>",
		tbAutoInfo.nPercent,
		tbChildInfo.nMissileHitcount,
		tbChildInfo.tbWholeMagic["state_freeze_attack"][1],
		FightSkill:Frame2Sec(tbChildInfo.tbWholeMagic["state_freeze_attack"][2]),
		tbCCInfo.tbWholeMagic["damage_all_resist"][1],
		FightSkill:Frame2Sec(tbCCInfo.nStateTime),
		FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime));
	return szMsg;
end;

local tbSkill	= FightSkill:GetClass("taxuewuhen");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbChildInfo2	= KFightSkill.GetSkillInfo(tbChildInfo.tbEvent.nStartSkillId, tbChildInfo.tbEvent.nLevel);
	local szMsg	= string.format("\n<color=green>子招式<color>\n造成会心一击时触发几率：<color=gold>%d%%<color>\n对手移动速度<color=gold>降低%d%%<color>，持续<color=gold>%s秒<color>\n自身<color=gold>免疫受伤、迟缓、定身、麻痹和击退效果<color>，持续<color=gold>%s秒<color>\n触发间隔时间：<color=Gold>%s秒<color>",
		tbAutoInfo.nPercent,
		-tbChildInfo.tbWholeMagic["fastwalkrun_p"][1],
		FightSkill:Frame2Sec(tbChildInfo.nStateTime),
		FightSkill:Frame2Sec(tbChildInfo2.nStateTime),
		FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime));
	return szMsg;
end;

local tbSkill	= FightSkill:GetClass("guiqulaixi");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbMsg = {};
	local szMsg = "";
	szMsg = szMsg.."\n重伤敌对玩家时使其：\n";
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0);
	for i=1, #tbMsg do
		szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	szMsg = szMsg.."\n触发间隔：<color=Gold>"..FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime).."秒<color>";
	return szMsg;
end;

local tbSkill	= FightSkill:GetClass("jiancui120");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbMsg = {};
	local szMsg = ""
	szMsg = szMsg.."被攻击时自动还击：\n";
	szMsg = szMsg.."    <color=green>冰心玉棱<color>\n";
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0);
	for i=1, #tbMsg do
		szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	szMsg = szMsg.."\n最多生效<color=gold>"..tbAutoInfo.nCastCount.."<color>次";
	return szMsg;
end;

local tbSkill	= FightSkill:GetClass("daocui120");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbChildInfo2 = KFightSkill.GetSkillInfo(1648, tbAutoInfo.nSkillLevel);
	
	local tbMsg = {};
	local szMsg = "";
	szMsg = szMsg.."<color=green>黯相望<color>\n";
	szMsg = szMsg.."每<color=gold>"..FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime).."<color>秒自动叠加以下状态：\n";
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo2, 0);
	for i=1, #tbMsg do
		szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	szMsg = szMsg.."\n<color=gold>非隐身状态叠加速度加倍<color>";
	return szMsg;
end;

local tbSkill	= FightSkill:GetClass("daocui120_child");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local szMsg	= string.format("攻击命中<color=gold>%s次<color>后效果消失",tbAutoInfo.nCastCount);
	return szMsg;
end;

local tbSkill	= FightSkill:GetClass("daocui120_child2");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local szMsg	= string.format("立刻获得一次伤害增加",tbAutoInfo.nCastCount);
	return szMsg;
end;

local tbSkill	= FightSkill:GetClass("shimianmaifu");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local szMsg	= string.format("使用技能后<color=gold>%s秒<color>内恢复隐身\n多个<color=red>同等级<color>效果持续时间叠加",FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime));
	return szMsg;
end;

local tbSkill = FightSkill:GetClass("jiancuiadvancedbook_fellow")

function tbSkill:GetExtraDesc(tbInfo)
	if (not tbInfo) then
		return "";
	end
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbInfo.nId, tbInfo.nLevel,me,1);
	local tbCCInfo		= KFightSkill.GetSkillInfo(tbChildInfo.tbEvent.nFlySkillId, tbChildInfo.tbEvent.nLevel, me, 1)
	
	local tbMsg = {};
	local szMsg = "";
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbCCInfo, 0);
	for i=1, #tbMsg do
		szMsg = szMsg..""..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	
	--[[local szMsg	= string.format("五行相克：<color=gold>%s点<color>\n冰攻攻击：<color=gold>%d到%d点<color>\n发挥基础攻击力：<color=gold>%d%%<color>\n造成迟缓几率：<color=gold>%d%%<color>，持续<color=gold>%s秒<color>\n造成定身几率：<color=gold>%d%%<color>，持续<color=gold>%d秒<color>",		
		tbCCInfo.tbWholeMagic["seriesdamage_r"][1],
		tbCCInfo.tbWholeMagic["colddamage_v"][1],
		tbCCInfo.tbWholeMagic["colddamage_v"][3],
		tbCCInfo.tbWholeMagic["appenddamage_p"][1],	
		tbCCInfo.tbWholeMagic["state_slowall_attack"][1],
		FightSkill:Frame2Sec(tbCCInfo.tbWholeMagic["state_slowall_attack"][2]),	
		tbCCInfo.tbWholeMagic["state_fixed_attack"][1],
		FightSkill:Frame2Sec(tbCCInfo.tbWholeMagic["state_fixed_attack"][2])
	);]]
	--local szMsg = string.format("wuxxk%d",tbCCInfo.tbWholeMagic["seriesdamage_r"][1])
	return szMsg;
end;