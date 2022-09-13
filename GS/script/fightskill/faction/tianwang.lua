Require("\\script\\fightskill\\fightskill.lua")
local nA0 = FightSkill.tbParam.nSadd;	--攻速类攻击技能+1的成长系数
local nA1 = FightSkill.tbParam.nSadd1;	--格斗类攻击技能+1的成长系数
local nS01 = FightSkill.tbParam.nS1;	--技能1级的数值系数
local nS20 = FightSkill.tbParam.nS20;	--技能20级的数值系数

--天王
local tb	= {
	--枪天
	huifengluoyan={ --回风落雁_20
		appenddamage_p= {{{1,50},{20,50},{21,50*nA1}}},
		physicsenhance_p={{{1,10},{10,100},{20,200},{21,200*nA1}}},
		physicsdamage_v={
			[1]={{1,30*0.9},{10,165*1.1},{20,315*0.9},{21,315*nA1*0.9}},
			[3]={{1,30*1.1},{10,165*1.1},{20,315*1.1},{21,315*nA1*1.1}}
			},
	--	attackrating_p={{{1,20},{20,50}}},
		skill_cost_v={{{1,2},{20,20},{21,20}}},
		state_hurt_attack={{{1,15},{10,30},{20,35}},{{1,18},{20,18}}},
		seriesdamage_r={0},--={{{1,50},{20,100},{21,100}}},
		addskilldamagep={43, {{1,2},{20,30},{21,35}},1},
		addskilldamagep2={44, {{1,2},{20,30},{21,35}}},
		addskilldamagep3={47, {{1,2},{20,10},{21,12}},1},
		addskilldamagep4={48, {{1,2},{20,10},{21,12}}},
	},
	tianwangqiangfa={ --天王枪法_10
		addphysicsdamage_p={{{1,5},{10,165},{12,198}}},
		attackratingenhance_p={{{1,50},{10,135},{12,162}}},
		deadlystrikeenhance_r={{{1,30},{10,50},{11,55}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	duanhunci={ --断魂刺_10
		state_fixed_attack={{{1,35},{10,85},{12,90}},{{1,18*2},{20,18*2}}},
		state_hurt_attack={{{1,27},{10,54},{11,56}},{{1,18},{20,18}}},
		missile_hitcount={{{1,3},{10,3},{11,4},{12,4}}},
		skill_mintimepercast_v={{{1,3*18},{10,3*18}}},
		skill_mintimepercastonhorse_v={{{1,3*18},{10,3*18}}},
		skill_cost_v={{{1,20},{10,50},{11,50}}},
		skill_attackradius={550},
		skill_param1_v={32},
	},
	yangguansandie={ --阳关三叠_20
		appenddamage_p= {{{1,50},{20,50},{21,50*nA1}}},
		physicsenhance_p={{{1,10},{10,100},{20,182},{21,182*nA1}}},
		physicsdamage_v={
			[1]={{1,300*0.9},{10,390*0.9},{20,490*0.9},{21,490*nA1*0.9}},
			[3]={{1,300*1.1},{10,390*1.1},{20,490*1.1},{21,490*nA1*1.1}}
			},
	--	attackrating_p={{{1,30},{20,60}}},
		skill_cost_v={{{1,20},{20,50},{21,50}}},
		state_hurt_attack={{{1,15},{10,35},{20,40},{21,41}},{{1,18},{20,18}}},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		addskilldamagep={47, {{1,2},{20,30},{21,35}},1},
		addskilldamagep2={48, {{1,2},{20,30},{21,35}}},
	},
	jingxinjue={ --静心诀_10
		lifemax_p={{{1,10},{20,80},{21,82}}},
		poisontimereduce_p={{{1,5},{20,30},{23,35}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	jingleipotian={ --惊雷破天_10
		autoskill={{{1,10},{2,10}},{{1,1},{10,10}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	jingleipotian_child={ --惊雷破天子
		prop_invincibility={1},
		skill_statetime={{{1,18*1},{10,18*2.5},{11,18*2.6}}},
	},
	jingleipotian_child2={ --惊雷破天子子
		deadlystrikeenhance_r={{{1,50},{10,240},{11,260}}},
		state_hurt_attackrate={{{1,15},{10,80},{11,84}}},
		skill_statetime={{{1,18*3},{10,18*15},{11,18*15}}},
	},
	tianwangzhanyi={ --天王战意_20
		addphysicsdamage_p={{{1,25},{20,210},{21,219}}},
		deadlystrikeenhance_r={{{1,10},{20,50},{21,55}}},
		state_hurt_attackrate={{{1,15},{20,80},{23,90}}},
		skill_mintimepercast_v={{{1,15*18},{10,15*18}}},
		skill_mintimepercastonhorse_v={{{1,15*18},{10,15*18}}},
		skill_cost_v={{{1,300},{20,500},{21,500}}},
		skill_statetime={300*18},
	},
	tianwangzhanyi_ally={ --天王战意_20
		addphysicsdamage_p={{{1,15},{20,60},{21,63}}},
		deadlystrikeenhance_r={{{1,10},{20,30},{21,33}}},
		state_hurt_attackrate={{{1,10},{20,45},{23,49}}},
		skill_statetime={300*18},
	},
	zhuixingzhuyue={ --追星逐月
		appenddamage_p= {{{1,60*nS01},{10,60},{20,60*nS20},{21,60*nS20*nA1}}},
		physicsenhance_p={{{1,120*nS01},{10,120},{20,120*nS20},{21,120*nS20*nA1}}},
		physicsdamage_v={
			[1]={{1,660*0.9*nS01},{10,660*0.9},{20,660*0.9*nS20},{21,660*0.9*nS20*nA1}},
			[3]={{1,660*1.1*nS01},{10,660*1.1},{20,660*1.1*nS20},{21,660*1.1*nS20*nA1}}
			},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		skill_cost_v={{{1,22},{20,45},{21,45}}},
		state_hurt_attack={{{1,15},{10,25},{20,30}},{{1,18},{20,18}}},
		missile_hitcount={{{1,3},{20,3}}},
	},
	tiangangzhanqi={ --天罡战气
	--	state_hurt_attackrate={{{1,10},{20,100}}},
		state_weak_resistrate={{{1,10},{10,100},{20,150}}},
		lifereplenish_p={{{1,5},{20,20},{21,21}}},
		attackratingenhance_p={{{1,50},{20,100}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	xuezhanbafang={ --血战八方
		skilldamageptrim={{{1,1},{10,10}}},
		skillselfdamagetrim={{{1,1},{10,10}}},
		state_hurt_attacktime={{{1,10},{10,80}}},
		state_weak_resisttime={{{1,10},{10,120}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},

	pijingzhanji={ --中级秘籍：披荆斩棘
		addenchant={14, {{1,1}, {2, 2}}},
		--addskillcastrange={41, 0, {{1,25}, {10, 250}}},
		--addrunattackspeed={41, 0, {{1,2}, {10, 18}}},
		addstartskill={41, 1224, {{1,1}, {10, 10}}},
		skill_skillexp_v=FightSkill.tbParam.tbMidBookSkillExp,
		skill_statetime={{{1,-1},{2,-1}}},
	},
	pijingzhanji_child={ --中级秘籍：披荆斩棘
		state_hurt_ignore={1},
		state_slowall_ignore={1},
		state_stun_ignore={1},
		state_fixed_ignore={1},
		--ignoreskill={{{1,50},{2,50}},0,{{1,5},{2,5}}},
		skill_statetime={{{1,18},{2,18}}},
	},
	pijingzhanji_child2={ --中级秘籍：乘风破浪子
		missile_missrate={{{1,50},{2,50}}},
		ignoreskill={{{1,100},{2,100}},0,{{1,5},{2,5}}},
		skill_statetime={{{1,18},{2,18}}},
	},
	benleizuanlongqiang={ --奔雷钻龙枪_10
		appenddamage_p= {{{1,100*0.7*1.30},{10,100*1.30},{11,100*nA1*1.30}}},
		physicsenhance_p={{{1,150*0.7*1.30},{10,150*1.30},{11,150*nA1*1.30}}},
		physicsdamage_v={
			[1]={{1,375*0.9*0.7*1.30},{10,375*0.9*1.30},{11,375*0.9*nA1*1.30}},
			[3]={{1,375*1.1*0.7*1.30},{10,375*1.1*1.30},{11,375*1.1*nA1*1.30}}
			},
		seriesdamage_r={0},--={{{1,250},{10,250},{11,250}}},
		state_hurt_attack={{{1,15},{10,60},{11,63}},{{1,18},{10,18}}},
		missile_hitcount={{{1,11},{10,11}}},
		runattack_damageadded={-15},

		skill_missilenum_v={7,1},
		skill_mintimepercast_v={{{1,20*18},{10,20*18}}},
		skill_mintimepercastonhorse_v={{{1,20*18},{10,20*18}}},
		skill_cost_v={{{1,180},{10,180},{11,180}}},
	},
	benleizuanlongqiang2={ --奔雷钻龙枪_10
		appenddamage_p= {{{1,100*0.7*1.30},{10,100*1.30},{11,100*nA1*1.30}}},
		physicsenhance_p={{{1,150*0.7*1.30},{10,150*1.30},{11,150*nA1*1.30}}},
		physicsdamage_v={
			[1]={{1,375*0.9*0.7*1.30},{10,375*0.9*1.30},{11,375*0.9*nA1*1.30}},
			[3]={{1,375*1.1*0.7*1.30},{10,375*1.1*1.30},{11,375*1.1*nA1*1.30}}
			},
		seriesdamage_r={0},--={{{1,250},{10,250},{11,250}}},
		state_hurt_attack={{{1,15},{10,60},{11,63}},{{1,18},{10,18}}},
		missile_hitcount={{{1,11},{10,11}}},
		runattack_damageadded={-15},
	},
	benleizuanlongqiang_child={ --奔雷钻龙枪免疫
		ignoredebuff={{{1,32767},{2,32767}}},
		addenchant={32, {{1,1}, {2, 2}}},
		--prop_invincibility={1},
		redeivedamage_dec_p2={{{1,300},{10,300}}},
		skill_statetime={{{1,18*60},{2,18*60}}},
	},
	qiangtianadvancedbook={ --枪天高级秘籍_10
		autoskill={{{1,43},{2,43}},{{1,1},{10,10}}},
		skilldamageptrim		={{{1,6},{10,60},{11,62}}},
		skillselfdamagetrim		={{{1,6},{10,60},{11,62}}},
		skill_statetime={{{1,-1},{2,-1}}},
		skill_skillexp_v=FightSkill.tbParam.tbHighBookSkillExp,
	},
	qiangtianadvancedbook_child={ --枪天高级秘籍加攻击_10
		skilldamageptrim		={{{1,1},{10,5},{11,5}}},
		skillselfdamagetrim		={{{1,1},{10,5},{11,5}}},
		superposemagic={{{1,60},{10,600},{11,600}}},
		skill_statetime={{{1,5*18},{10,5*18},{12,5.5*18}}},
		skill_startevent={{{1,1660},{10,1660}}},
		skill_eventskilllevel={{{1,1},{10,10}}},
		--skill_showevent={{{1,1},{10,1}}},
	},
	qiangtianadvancedbook_child2={ --枪天高级秘籍减攻击_10
		skilldamageptrim		={{{1,-1},{10,-10},{11,-10}}},
		skillselfdamagetrim		={{{1,-1},{10,-10},{11,-10}}},
		superposemagic={{{1,12},{10,12}}},
		skill_statetime={{{1,3*18},{10,3*18}}},
	},
	qiangtian120={ --枪天120_10
		state_hurt_ignore={1},
		state_weak_ignore={1},
		state_slowall_ignore={1},
		state_stun_ignore={1},
		state_fixed_ignore={1},
		skill_statetime={{{1,6*18},{10,15*18},{11,16*18}}},
		autoskill={{{1,70},{2,70}},{{1,1},{10,10}}},
		skill_cost_v={{{1,500},{10,500}}},
		skill_mintimepercast_v={{{1,37.5*18},{10,37.5*18}}},
		skill_mintimepercastonhorse_v={{{1,37.5*18},{10,37.5*18}}},
	},
	qiangtian120_child={ --枪天120_子_10
		state_hurt_ignore={1},
		state_weak_ignore={1},
		state_slowall_ignore={1},
		state_stun_ignore={1},
		skill_statetime={{{1,2*18},{10,2*18},{11,2*18}}},
	},
	--锤天
	xingyunjue={ --行云诀_20
		appenddamage_p= {{{1,80},{20,80},{21,80*nA1}}},
		physicsenhance_p={{{1,5},{10,50},{20,100},{21,100*nA1}}},
		physicsdamage_v={
			[1]={{1,50*0.9},{10,140*0.9},{20,240*0.9},{21,240*nA1*0.9}},
			[3]={{1,50*1.1},{10,140*1.1},{20,240*1.1},{21,240*nA1*1.1}}
			},
	--	attackrating_p={{{1,50},{20,100}}},
		skill_cost_v={{{1,2},{20,20},{21,20}}},
		state_hurt_attack={{{1,15},{10,20},{20,25},{21,25},{22,26}},{{1,18},{20,18}}},
		seriesdamage_r={0},--={{{1,50},{20,100},{21,100}}},
		addskilldamagep={53, {{1,2},{20,30},{21,35}},1},
		addskilldamagep2={54, {{1,2},{20,30},{21,35}}},
		addskilldamagep3={56, {{1,2},{20,10},{21,12}},1},
		addskilldamagep4={57, {{1,2},{20,10},{21,12}}},
	},
	tianwangchuifa={ --天王锤法_10
		addphysicsdamage_p={{{1,5},{10,145},{12,174}}},
		attackratingenhance_p={{{1,50},{10,200},{11,220}}},
		deadlystrikeenhance_r={{{1,30},{10,50},{11,55}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	jingxinshu={ --静心术_20
		lifemax_p={{{1,10},{20,80},{21,82}}},
		poisontimereduce_p={{{1,5},{20,30},{23,35}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	zhuifengjue={ --追风诀_20
		appenddamage_p= {{{1,75},{20,75},{21,75*nA1}}},
		physicsenhance_p={{{1,5},{10,68},{20,128},{21,128*nA1}}},
		physicsdamage_v={
			[1]={{1,150*0.9},{10,195*0.9},{20,245*0.9},{21,245*nA1*0.9}},
			[3]={{1,150*1.1},{10,195*1.1},{20,245*1.1},{21,245*nA1*1.1}}
			},
	--	attackrating_p={{{1,80},{20,120}}},
		skill_cost_v={{{1,20},{20,50},{21,50}}},
		state_hurt_attack={{{1,15},{10,20},{20,25},{21,25},{22,26}},{{1,18},{20,18}}},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		addskilldamagep={56, {{1,2},{20,30},{21,35}},1},
		addskilldamagep2={57, {{1,2},{20,30},{21,35}}},
	},
	tianwangbensheng={ --天王本生_10
		autoskill={{{1,11},{2,11}},{{1,1},{10,10}}},
		autoskill2={{{1,65},{2,65}},{{1,1},{10,10}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	tianwangbensheng_child={ --天王本生子
		--prop_invincibility={1},
		--dynamicmagicshieldbymaxhp_p={2000,100};
		--posionweaken={9999999,100};
		redeivedamage_dec_p={10000},
		--damage_return_receive_p={-100},
		ignoredebuff={{{1,32767},{2,32767}}},
		removestate={{{1,800},{2,800}}},
		skill_statetime={{{1,18*2},{10,18*5},{11,18*5.25}}},
	},
	tianwangbensheng_child2={ --天王本生子2_10
		decautoskillcdtime={260,11,{{1,18*45},{10,18*45}}},
		skill_statetime={{{1,60*18},{10,60*18},{11,60*18}}},
	},

	jinzhongzhao={ --金钟罩_20
		damage_physics_resist={{{1,10},{10,50},{20,150},{21,157}}},
		damage_poison_resist={{{1,10},{10,50},{20,150},{21,157}}},
		damage_cold_resist={{{1,10},{10,50},{20,150},{21,157}}},
		damage_light_resist={{{1,10},{10,50},{20,150},{21,157}}},
		state_hurt_attackrate={{{1,10},{20,80},{21,84}}},
		skill_cost_v={{{1,300},{20,500},{21,500}}},
		skill_mintimepercast_v={{{1,15*18},{10,15*18}}},
		skill_mintimepercastonhorse_v={{{1,15*18},{10,15*18}}},
		skill_statetime={300*18},
	},
	jinzhongzhao_ally={ --金钟罩_20
		damage_physics_resist={{{1,10},{10,30},{20,60},{21,63}}},
		damage_poison_resist={{{1,10},{10,30},{20,60},{21,63}}},
		damage_cold_resist={{{1,10},{10,30},{20,60},{21,63}}},
		damage_light_resist={{{1,10},{10,30},{20,60},{21,63}}},
		skill_statetime={300*18},
	},
	chenglongjue={ --乘龙诀_20
		appenddamage_p= {{{1,65*nS01},{10,65},{20,65*nS20},{21,65*nS20*nA1}}},
		physicsenhance_p={{{1,100*nS01},{10,100},{20,100*nS20},{21,100*nS20*nA1}}},
		physicsdamage_v={
			[1]={{1,250*0.9*nS01},{10,250*0.9},{20,250*0.9*nS20},{21,250*0.9*nS20*nA1}},
			[3]={{1,250*1.1*nS01},{10,250*1.1},{20,250*1.1*nS20},{21,250*1.1*nS20*nA1}}
			},
		--timingdamage={{{1,1},{20,20},{21,21}},1803,10},
		--skill_statetime={5.5*18},
		skill_cost_v={{{1,22},{20,45},{21,45}}},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		state_hurt_attack={{{1,15},{10,25},{20,35}},{{1,18},{20,18}}},
		missile_hitcount={{{1,4},{20,4}}},
	},
	daoxutian={ --倒虚天_20
	--	state_hurt_attackrate={{{1,10},{20,100}}},
		state_weak_resistrate={{{1,10},{10,100},{20,150}}},
		lifereplenish_p={{{1,5},{20,25},{21,26}}},
		ignoredefenseenhance_v={{{1,50},{10,200},{20,250}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	bumieshayi={ --不灭杀意_10
		skilldamageptrim={{{1,1},{10,10}}},
		skillselfdamagetrim={{{1,1},{10,10}}},
		state_hurt_attacktime={{{1,10},{10,80}}},
		state_weak_resisttime={{{1,10},{10,120}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},

	--[[旧斩龙诀存档
	zhanlongjue={ --斩龙诀_10
		addedwith_enemycount={{{1,1183},{10,1183}},{{1,3},{10,10},{11,11}}, {{1,1600},{10,1600}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	zhanlongjue_child={ --斩龙诀子_10
		damage_all_resist={{{1,10},{2,10}}},
		allseriesstateresistrate={{{1,26},{2,26}}},
		state_fixed_resistrate={{{1,26},{2,26}}},
		deadlystrikeenhance_r={{{1,24},{2,24}}},
		addphysicsdamage_p={{{1,20},{2,20}}},
		skill_statetime={{{1,18*2.5},{2,18*2.5}}},
	},]]
	zhanlongjue={ --斩龙诀_10
		--appenddamage_p= {{{1,65*nS01},{10,65},{11,65*nA1}}},
		floatdamage_p = {
			[1] = {{1,2.5*0.8*650*nS01},{10,2.5*0.8*650},{11,2.5*0.8*650*nA1}},
			[2] = {{1,2.5*1.2*650*nS01},{10,2.5*1.2*650},{11,2.5*1.2*650*nA1}},
		},
		--physicsenhance_p={{{1,100*nS01},{10,100},{11,100*nA1}}},--转成1300点点伤加下面去了
		physicsdamage_v={
			[1]={{1,2.5*0.8*1550*nS01},{10,2.5*0.8*1550},{11,2.5*0.8*1550*nA1}},
			[3]={{1,2.5*1.2*1550*nS01},{10,2.5*1.2*1550},{11,2.5*1.2*1550*nA1}}
			},
		timingdamage={{{1,6},{10,15},{11,16}},1803,20},
		skill_statetime={10*18},
		
		seriesdamage_r={0},--={250},
		state_hurt_attack={{{1,44},{10,80},{11,84}},{{1,2*18},{10,2*18}}},
		missile_hitcount={{{1,9},{10,9}}},
		
		skill_cost_v={45*10},
		skill_cost_buff1layers_v={1279,3,0},--消耗3层乾坤倒悬
		skill_mintimepercast_v={{{1,6},{10,6}}},
		skill_mintimepercastonhorse_v={{{1,6},{10,6}}},
	},
	zhanlongjue_child={ --斩龙诀子_10
		floatdamage_p = {
			[1] = {{1,2.5*0.8*650*nS01},{10,2.5*0.8*650},{11,2.5*0.8*650*nA1}},
			[2] = {{1,2.5*1.2*650*nS01},{10,2.5*1.2*650},{11,2.5*1.2*650*nA1}},
		},
		--physicsenhance_p={{{1,100*nS01},{10,100},{11,100*nA1}}},--转成1300点点伤加下面去了
		physicsdamage_v={
			[1]={{1,2.5*0.8*1550*nS01},{10,2.5*0.8*1550},{11,2.5*0.8*1550*nA1}},
			[3]={{1,2.5*1.2*1550*nS01},{10,2.5*1.2*1550},{11,2.5*1.2*1550*nA1}}
			},
		timingdamage={{{1,6},{10,15},{11,16}},1803,20},
		skill_statetime={10*18},
		
		seriesdamage_r={0},--={250},
		state_hurt_attack={{{1,44},{10,80},{11,84}},{{1,2*18},{10,2*18}}},
		missile_hitcount={{{1,9},{10,9}}},
	},
	zhanlongjue_buff={ --斩龙诀免疫
		ignoredebuff={{{1,32767},{2,32767}}},
		--prop_invincibility={1},
		skill_statetime={{{1,18*60},{2,18*60}}},
	},
	zhanlongjue_dot={ --斩龙诀_10
		--由于格斗技必须是子技能来生效,而角色基本是不会有子技能的,所以调用子技能的时候无法取到角色所学的生效的技能等级
		--最后技能调用都使用1级的子技能,各等级值只能设成一样的
		seriesdamage_r={0},--={250},
	},
	chuitianadvancedbook={ --锤天高级秘籍_10
		autoskill={{{1,48},{2,48}},{{1,1},{10,10}}},
		skill_statetime={{{1,-1},{2,-1}}},
		skill_skillexp_v=FightSkill.tbParam.tbHighBookSkillExp,
	},
	chuitianadvancedbook_child={ --锤天高级秘籍_10
		skilldamageptrim		={{{1,1},{10,10},{11,11}}},
		skillselfdamagetrim		={{{1,1},{10,10},{11,11}}},
		superposemagic={{{1,2},{10,10},{11,10}}},
		skill_statetime={{{1,6.5*18},{2,6.5*18}}},
	},
	chuitian120={ --锤天120_10
		destory_missile={{{1,10},{10,100},{11,100}}},
		redeivedamage_dec_p2={{{1,3},{10,30},{11,33}}},
	},
	chuitian120_team={ --锤天120_队友_10
		redeivedamage_dec_p2={{{1,1},{10,15},{11,16}}},
	},
	
	huifengluoyan3={ --回风落雁_20
		appenddamage_p= {{{1,50},{20,50},{21,50*nA1}}},
		physicsenhance_p={{{1,10},{10,100},{20,200},{21,200*nA1}}},
		physicsdamage_v={
			[1]={{1,30*0.9},{10,165*1.1},{20,315*0.9},{21,315*nA1*0.9}},
			[3]={{1,30*1.1},{10,165*1.1},{20,315*1.1},{21,315*nA1*1.1}}
			},
	--	attackrating_p={{{1,20},{20,50}}},
		skill_cost_v={{{1,2},{20,20},{21,20}}},
		state_hurt_attack={{{1,15},{10,30},{20,35}},{{1,18},{20,18}}},
		seriesdamage_r={0},--={{{1,50},{20,100},{21,100}}},
		addskilldamagep={2981, {{1,2},{20,30},{21,35}},1},
		addskilldamagep2={2982, {{1,2},{20,30},{21,35}}},
		addskilldamagep3={2983, {{1,2},{20,10},{21,12}},1},
		addskilldamagep4={2984, {{1,2},{20,10},{21,12}}},
	},
	yangguansandie3={ --阳关三叠_20
		appenddamage_p= {{{1,50},{20,50},{21,50*nA1}}},
		physicsenhance_p={{{1,10},{10,100},{20,182},{21,182*nA1}}},
		physicsdamage_v={
			[1]={{1,300*0.9},{10,390*0.9},{20,490*0.9},{21,490*nA1*0.9}},
			[3]={{1,300*1.1},{10,390*1.1},{20,490*1.1},{21,490*nA1*1.1}}
			},
	--	attackrating_p={{{1,30},{20,60}}},
		skill_cost_v={{{1,20},{20,50},{21,50}}},
		state_hurt_attack={{{1,15},{10,35},{20,40},{21,41}},{{1,18},{20,18}}},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		addskilldamagep={2983, {{1,2},{20,30},{21,35}},1},
		addskilldamagep2={2984, {{1,2},{20,30},{21,35}}},
	},
	zhuixingzhuyue3={ --追星逐月
		appenddamage_p= {{{1,60*nS01},{10,60},{20,60*nS20},{21,60*nS20*nA1}}},
		physicsenhance_p={{{1,120*nS01},{10,120},{20,120*nS20},{21,120*nS20*nA1}}},
		physicsdamage_v={
			[1]={{1,660*0.9*nS01},{10,660*0.9},{20,660*0.9*nS20},{21,660*0.9*nS20*nA1}},
			[3]={{1,660*1.1*nS01},{10,660*1.1},{20,660*1.1*nS20},{21,660*1.1*nS20*nA1}}
			},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		skill_cost_v={{{1,22},{20,45},{21,45}}},
		state_hurt_attack={{{1,15},{10,25},{20,30}},{{1,18},{20,18}}},
		missile_hitcount={{{1,3},{20,3}}},
	},
	tianwangdaofa={ --天王枪法_10
		deadlystrikedamageenhance_p={{{1,25},{10,125}}},
		addphysicsdamage_p={{{1,5},{10,165},{12,198}}},
		attackratingenhance_p={{{1,50},{10,135},{12,162}}},
		deadlystrikeenhance_r={{{1,30},{10,50},{11,55}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	duanhunci3={ --断魂刺_10
		state_fixed_attack={{{1,35},{10,85},{12,90}},{{1,18*2},{20,18*2}}},
		state_hurt_attack={{{1,27},{10,54},{11,56}},{{1,18},{20,18}}},
		missile_hitcount={{{1,3},{10,3},{11,4},{12,4}}},
		skill_mintimepercast_v={{{1,3*18},{10,3*18}}},
		skill_mintimepercastonhorse_v={{{1,3*18},{10,3*18}}},
		skill_cost_v={{{1,20},{10,50},{11,50}}},
		skill_attackradius={550},
		skill_param1_v={32},
	},
	pijingzhanji3={ --中级秘籍：披荆斩棘
		addenchant={43, {{1,1}, {2, 2}}},
		--addskillcastrange={41, 0, {{1,25}, {10, 250}}},
		--addrunattackspeed={41, 0, {{1,2}, {10, 18}}},
		addstartskill={2985, 1224, {{1,1}, {10, 10}}},
		skill_skillexp_v=FightSkill.tbParam.tbMidBookSkillExp,
		skill_statetime={{{1,-1},{2,-1}}},
	},
	
	tianwangdao110={ --天王枪法_10
		autoskill={{{1,146},{2,146}},{{1,1},{10,10}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	tianwangdao110_child={ --天王枪法_10
		ignoredebuff={{{1,32767},{2,32767}}},
		skill_statetime={{{1,18*1},{2,18*1.25}}},
	},
	daotianadvancedbook={ --枪天高级秘籍_10
		autoskill={{{1,147},{2,147}},{{1,1},{10,10}}},
		skilldamageptrim		={{{1,6},{10,60},{11,62}}},
		skillselfdamagetrim		={{{1,6},{10,60},{11,62}}},
		skill_statetime={{{1,-1},{2,-1}}},
		skill_skillexp_v=FightSkill.tbParam.tbHighBookSkillExp,
	},
	daotianadvancedbook_child={ --枪天高级秘籍加攻击_10
		deadlystrikeenhance_r={{{1,5},{10,50}}},
		deadlystrikedamageenhance_p={{{1,1},{10,5}}},
		superposemagic={{{1,10},{10,10},{21,11}}},
		skill_statetime={{{1,5*18},{10,5*18},{12,6*18}}},
	},
	
}

FightSkill:AddMagicData(tb)

local tbSkill	= FightSkill:GetClass("jingleipotian");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbCCInfo	= KFightSkill.GetSkillInfo(tbChildInfo.tbEvent.nStartSkillId, tbChildInfo.tbEvent.nLevel);
	local szMsg	= string.format("Khi sinh lực giảm xuống 25%%, xác suất thi triển: <color=gold>%d%%<color>\nKhông thọ thương, duy trì <color=Gold>%s giây<color>\nChí mạng <color=gold>tăng %s<color>\nXác suất gây thọ thương <color=gold>tăng %s<color>, duy trì <color=gold>%s giây<color>\nThời gian giãn cách: <color=Gold>%s giây<color>",
		tbAutoInfo.nPercent,
		FightSkill:Frame2Sec(tbChildInfo.nStateTime),
		tbCCInfo.tbWholeMagic["deadlystrikeenhance_r"][1],
		tbCCInfo.tbWholeMagic["state_hurt_attackrate"][1],
		FightSkill:Frame2Sec(tbCCInfo.nStateTime),
		FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime));
	return szMsg;
end;

local tbSkill	= FightSkill:GetClass("tianwangbensheng");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local szMsg = ""
	local tbMsg = {};
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0)
	szMsg = szMsg..string.format("Khi sinh lực giảm xuống 25%%, xác suất thi triển: <color=gold>%d%%<color>\n", tbAutoInfo.nPercent);
	szMsg = szMsg.."    ".."<color=green>Thiên Vương Bản Sinh<color>\n";
	for i=1, #tbMsg do
		szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	szMsg = string.gsub(szMsg, "Hóa giải và miễn dịch trạng thái bất lợi", "    Hóa giải và miễn dịch trạng thái bất lợi");
	szMsg = szMsg.."\nGiãn cách thi triển: <color=Gold>"..FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime).." giây<color>";
	return szMsg;
end;

--[[
function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local nPerCastTime = (tbAutoInfo.nPerCastTime - KFightSkill.GetAutoSkillCDTimeAddition(tbSkillInfo.nId, tbAutoInfo.nId));
	if (nPerCastTime < 0) then
		nPerCastTime = 0;
	end
	local szMsg	= string.format("生命降到25%%时触发几率：<color=gold>%d%%<color>\n不受任何伤害技能影响，持续<color=Gold>%s秒<color>\n触发间隔时间：<color=Gold>%s秒<color>",
		tbAutoInfo.nPercent,
		FightSkill:Frame2Sec(tbChildInfo.nStateTime),
		FightSkill:Frame2Sec(nPerCastTime));
	return szMsg;
end;]]

function tbSkill:GetAutoDesc2(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local szMsg = ""
	if tbAutoInfo.nPercent >= 1 then
		szMsg = szMsg.."\nKhi bị tấn công, có <color=Gold>"..tbAutoInfo.nPercent.."%<color> nhận được hiệu quả:\n"
		szMsg = szMsg.."    ".."<color=green>Bất khuất<color>\n";
		local tbMsg = {};
		FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0)
		for i=1, #tbMsg do
			szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
		end
	end
	return szMsg;
end

local tbSkill	= FightSkill:GetClass("qiangtianadvancedbook");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local szMsg = ""
	local tbMsg = {};
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0)
	szMsg = szMsg.."Khi đánh trúng sẽ tự cộng dồn 2 trạng thái sau:\n";
	szMsg = szMsg.."    ".."<color=green>Liên Hoàn Đoạt Mệnh<color>\n";
	for i=1, #tbMsg do
		szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	--子技能描述
	tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel, me, 1);
	local tbChildInfo2	= KFightSkill.GetSkillInfo(tbChildInfo.tbEvent.nStartSkillId, tbChildInfo.tbEvent.nLevel)
	local tbMsg2 = {};
	szMsg = szMsg.."\n";
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg2, tbChildInfo2, 0)
	for i=1, #tbMsg2 do
		szMsg = szMsg.."    "..tostring(tbMsg2[i])..(i ~= #tbMsg2 and "\n" or "");
	end
	--szMsg = szMsg.."\n触发间隔时间：<color=Gold>"..FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime).."秒<color>";
	return szMsg;
end;

local tbSkill	= FightSkill:GetClass("chuitianadvancedbook");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local szMsg = ""
	local tbMsg = {};
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0)
	szMsg = szMsg.."Bị đánh tự động cộng dồn trạng thái:\n";
	szMsg = szMsg.."    ".."<color=green>Càn Khôn Đảo Huyền<color>\n";
	for i=1, #tbMsg do
		szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	szMsg = szMsg.."\nGiãn cách thi triển: <color=Gold>"..FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime).." giây<color>";
	return szMsg;
end;

local tbSkill = FightSkill:GetClass("qiangtian120")

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	--[[local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local szMsg = ""
	local tbMsg = {};
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0)
	for i=1, #tbMsg do
		szMsg = szMsg..""..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end]]
	local szMsg = "Trong trạng thái này, đồng đội xung quanh có thể nhận hiệu quả miễn dịch ngoài bất động";
	return szMsg;
end

local tbSkill	= FightSkill:GetClass("tianwangdao110");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local szMsg = ""
	if tbAutoInfo.nPercent >= 1 then
		szMsg = szMsg.."\nKhi bị tấn công, có <color=Gold>"..tbAutoInfo.nPercent.."%<color> nhận được hiệu quả:\n"
		szMsg = szMsg.."    ".."<color=green>Chinh Chiến Bát Phương<color>\n";
		local tbMsg = {};
		FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0)
		for i=1, #tbMsg do
			szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
		end
	end
	szMsg = szMsg.."\nGiãn cách thi triển: <color=Gold>"..FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime).." giây<color>";
	return szMsg;
end;

local tbSkill	= FightSkill:GetClass("daotianadvancedbook");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local szMsg = ""
	local tbMsg = {};
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0)
	szMsg = szMsg.."Khi đánh trúng sẽ tự cộng dồn trạng thái sau:\n";
	szMsg = szMsg.."    ".."<color=green>Kinh Lôi Trảm<color>\n";
	for i=1, #tbMsg do
		szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	--子技能描述
	tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel, me, 1);
	local tbChildInfo2	= KFightSkill.GetSkillInfo(tbChildInfo.tbEvent.nStartSkillId, tbChildInfo.tbEvent.nLevel)
	local tbMsg2 = {};
	szMsg = szMsg.."\n";
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg2, tbChildInfo2, 0)
	for i=1, #tbMsg2 do
		szMsg = szMsg.."    "..tostring(tbMsg2[i])..(i ~= #tbMsg2 and "\n" or "");
	end
	szMsg = szMsg.."Giãn cách thi triển: <color=Gold>"..FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime).." giây<color>";
	return szMsg;
end;
