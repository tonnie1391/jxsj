Require("\\script\\fightskill\\fightskill.lua")
local nA0 = FightSkill.tbParam.nSadd;	--攻速类攻击技能+1的成长系数
local nA1 = FightSkill.tbParam.nSadd1;	--格斗类攻击技能+1的成长系数
local nS01 = FightSkill.tbParam.nS1;	--技能1级的数值系数
local nS20 = FightSkill.tbParam.nS20;	--技能20级的数值系数

--少林
local tb	= {
	--刀少
	fumodaofa={ --伏魔刀法_20
		appenddamage_p= {{{1,100},{20,100},{21,100*nA0}}},
		physicsenhance_p={{{1,5},{10,50},{20,100},{21,100*nA0}}},
		physicsdamage_v={
			[1]={{1,20*0.9},{10,110*0.9},{20,310*0.9},{21,310*nA0*0.9}},
			[3]={{1,20*1.1},{10,110*1.1},{20,310*1.1},{21,310*nA0*1.1}}
			},
	--	attackrating_p={{{1,50},{20,100}}},
		skill_cost_v={{{1,2},{20,20},{21,20}}},
		state_hurt_attack={{{1,15},{10,35},{20,40},{21,41}},{{1,18},{20,18}}},
		seriesdamage_r={0},--={{{1,50},{20,100},{21,100}}},
		addskilldamagep={24, {{1,2},{20,30},{21,35}},1},
		addskilldamagep2={27, {{1,2},{20,10},{21,12}},1},
	},
	shaolindaofa={ --少林刀法_10
		addphysicsdamage_p={{{1,50},{10,200},{11,220}}},
		attackratingenhance_p={{{1,50},{10,150},{11,165}}},
		deadlystrikeenhance_r={{{1,30},{10,50},{11,55}}},
		attackspeed_v={{{1,5},{10,15},{11,16},{12,17},{13,17}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	yijinjing={ --易筋经_10
		lifemax_p={{{1,10},{10,45},{11,48},{12,51},{13,55}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	pojiedaofa={ --破戒刀法_20
		appenddamage_p= {{{1,45},{20,45},{21,45*nA0}}},
		physicsenhance_p={{{1,50},{10,77},{20,110},{21,110*nA0}}},
		physicsdamage_v={
			[1]={{1,280*0.9},{10,550*0.9},{20,750*0.9},{21,750*nA0*0.9}},
			[3]={{1,280*1.1},{10,550*1.1},{20,750*1.1},{21,750*nA0*1.1}}
			},
	--	attackrating_p={{{1,30},{20,100}}},
		skill_cost_v={{{1,20},{20,50},{21,50}}},
		state_hurt_attack={{{1,15},{10,20},{20,30},{21,31}},{{1,18},{20,18}}},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		addskilldamagep={27, {{1,2},{20,30},{21,35}},1},
		missile_range={1,0,1},
	},
	aluohanshengong={ --阿罗汉神功_20
		meleedamagereturn_p={{{1,10},{10,30},{20,40},{22,45}}},
		rangedamagereturn_p={{{1,10},{10,30},{20,40},{22,45}}},
		--skill_cost_v={{{1,2},{20,25}}},
	},
	aluohanshengong_team={ --阿罗汉神功_队友
		meleedamagereturn_p={{{1,5},{10,15},{20,20},{22,23}}},
		rangedamagereturn_p={{{1,5},{10,15},{20,20},{22,23}}},
	},
	xianglongfuhu={ --降龙伏虎_10
		poisondamagereturn_p={{{1,10},{10,40},{12,45}}},
		autoskill={{{1,9},{2,9}},{{1,1},{10,10}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	xianglongfuhu_child={ --降龙伏虎子
		state_slowall_attack={{{1,15},{10,60},{11,65},{12,70},{13,75}},{{1,18*2},{10,18*3.5},{11,18*3.5}}},
		missile_hitcount={{{1,3},{10,5},{11,5}}},
		missile_range={13,0,13},
	},
	xianglongfuhu_child2={ --降龙伏虎子子
		state_hurt_ignore={1},
		state_weak_ignore={1},
		state_slowall_ignore={1},
		state_stun_ignore={1},
		state_fixed_ignore={1},
		skill_statetime={{{1,18*3},{10,18*7},{13,18*10}}},
	},
	putixinfa={ --菩提心法     _20
		state_hurt_resisttime={{{1,30},{10,85},{20,125},{21,130}}},
		state_weak_resisttime={{{1,30},{10,85},{20,125},{21,130}}},
		state_slowall_resisttime={{{1,30},{10,85},{20,125},{21,130}}},
	--	state_burn_resisttime={{{1,5},{10,100},{20,200}}},
		state_stun_resisttime={{{1,30},{10,85},{20,125},{21,130}}},
		state_fixed_resisttime={{{1,30},{10,85},{20,125},{21,130}}},
		skill_statetime={300*18},
		skill_cost_v={{{1,300},{20,500},{21,500}}},
	},
	tianzhujuedao={ --天竺绝刀_20
		appenddamage_p= {{{1,50*nS01},{10,50},{20,50*nS20},{21,50*nS20*nA0}}},
		physicsenhance_p={{{1,115*nS01},{10,115},{20,115*nS20},{21,115*nS20*nA0}}},
		physicsdamage_v={
			[1]={{1,775*0.9*nS01},{10,775*0.9},{20,775*0.9*nS20},{21,775*0.9*nS20*nA0}},
			[3]={{1,775*1.1*nS01},{10,775*1.1},{20,775*1.1*nS20},{21,775*1.1*nS20*nA0}}
			},
		skill_cost_v={{{1,50},{20,100},{21,100}}},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		state_hurt_attack={{{1,20},{10,25},{20,30}},{{1,18},{20,18}}},
		missile_hitcount={{{1,5},{10,5},{20,5},{21,5}}},
	},
	hunyuanyiqi={ --混元一气
		attackspeed_v={{{1,10},{10,16},{20,26},{23,29},{24,29}}},
		state_hurt_attackrate={{{1,10},{20,100}}},
		state_weak_resistrate={{{1,10},{10,100},{20,150}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	rulaiqianye={	--如来千叶
		skilldamageptrim={{{1,1},{10,10}}},
		skillselfdamagetrim={{{1,1},{10,10}}},
		state_hurt_attacktime={{{1,10},{10,80}}},
		state_weak_resisttime={{{1,10},{10,120}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	
	damobixigong={ --中级秘籍：达摩闭息功
		addenchant={7, {{1,1}, {2, 2}}},
		--addmissilerange={24, {{1,1}, {10, 1}}},
		--addskillslowstaterate={251, 0, {{1,7}, {10, 25}}},
		--addmissilerange2={251, {{1,2}, {10, 6}}},
		decautoskillcdtime={250, 9, {{1,18},{10, 18*5},{11, 18*5.5}}},
		state_hurt_resistrate		={{{1,5},{10,20},{11,21}}},
		state_weak_resistrate		={{{1,5},{10,20},{11,21}}},
		state_slowall_resistrate	={{{1,5},{10,20},{11,21}}},
		state_stun_resistrate		={{{1,5},{10,20},{11,21}}},
		state_fixed_resistrate		={{{1,5},{10,20},{11,21}}},
		skill_skillexp_v=FightSkill.tbParam.tbMidBookSkillExp,
		skill_statetime={{{1,-1},{2,-1}}},
	},
	chanyuangong={ --禅圆功_10
		strength_v={{{1,60},{10,150},{12,165}}},
		dexterity_v={{{1,32},{10,80},{11,84}}},
		vitality_v={{{1,60},{10,150},{12,165}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	daoshaoadvancedbook = { --刀少高级秘籍_10
		state_fixed_attack={{{1,35},{10,85},{12,90}},{{1,18*2.5},{10,18*2.5}}},
		state_drag_attack={{{1,35},{10,85},{12,90}},{{1,14},{10,14}},{{1,32},{2,32}}},
		steallifeenhance_p={{{1,-4},{10,-40},{11,-42}},{{1,100},{10,100}}},
		npcdamageadded={{{1,-999},{10,-999}}},--避免刀少开高密站怪堆,只是该属性角色状态属性总和为负数无效
		skill_statetime={{{1,6*18},{2,6*18}}},
		missile_drag={1},
		missile_hitcount={{{1,3},{10,8}}},
		skill_cost_v={{{1,100},{10,100}}},
		skill_mintimepercast_v={{{1,15*18},{10,15*18}}},
		skill_mintimepercastonhorse_v={{{1,15*18},{10,15*18}}},
		skill_skillexp_v=FightSkill.tbParam.tbHighBookSkillExp,
	},
	daoshao120={ --刀少120_10
		autoskill={{{1,95},{2,95}},{{1,1},{10,10}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	daoshao120_child={ --刀少120子_10
		autoskill={{{1,54},{2,54}},{{1,1},{10,10}}},
		--autoskill2={{{1,139},{2,139}},{{1,1},{10,10}}},
		dynamicmagicshield_v={{{1,300},{10,3000},{11,3150}},99},
		posionweaken={{{1,300},{10,3000},{11,3150}},99},
		deadlystrikeenhance_r={{{1,20},{10,200},{11,200*1.05}}},
		deadlystrikedamageenhance_p={{{1,10},{10,100},{11,105}}},
		skill_statetime={{{1,7.5*18},{2,7.5*18}}},
		
		--skill_startevent={818},
		--skill_eventskilllevel={{{1,1},{20,20}}},
		--skill_showevent={0},
	},
	daoshao120_child2={ --刀少120子2_10
		dynamicmagicshield_v={{{1,-25},{10,-250},{12,-275}},99},
		posionweaken={{{1,-25},{10,-250},{12,-275}},99},
		superposemagic	={{{1,12},{10,12}}},
		--deadlystrikeenhance_r={{{1,20},{10,200},{11,210}}},
		--deadlystrikedamageenhance_p={{{1,10},{10,100},{11,105}}},
		skill_statetime={{{1,7.5*18},{2,7.5*18}}},
	},
	daoshao120_child3={ --刀少120子3_10
		removestate={{{1,2856},{2,2856}}},--清除降低化解伤害的效果,就相当于再次触发时可重置效果
	},

	--棍少
	pudugunfa={ --普渡棍法_20
		appenddamage_p= {{{1,100},{20,100},{21,100*nA0}}},
		physicsenhance_p={{{1,20},{10,110},{20,160},{21,160*nA0}}},
		physicsdamage_v={
			[1]={{1,50*0.9},{10,230*0.9},{20,380*0.9},{21,380*nA0*0.9}},
			[3]={{1,50*1.1},{10,230*1.1},{20,380*1.1},{21,380*nA0*1.1}}
			},
		--	attackrating_p={{{1,30},{20,100}}},
		skill_cost_v={{{1,2},{20,20},{21,20}}},
		state_hurt_attack={{{1,15},{10,40},{20,45},{21,46}},{{1,18},{20,18}}},
		seriesdamage_r={0},--={{{1,50},{20,100},{21,100}}},
		addskilldamagep={33, {{1,2},{20,30},{20,35}},1},
		addskilldamagep2={36, {{1,2},{20,10},{21,12}},1},
	},
	shaolingunfa={ --少林棍法_10
		addphysicsdamage_p={{{1,10},{10,150},{11,165}}},
		attackratingenhance_p={{{1,50},{10,135},{12,162}}},
		deadlystrikeenhance_r={{{1,30},{10,50},{11,55}}},
		attackspeed_v={{{1,10},{10,20},{11,21},{12,22},{13,22}}},
		lifemax_p={{{1,5},{10,20},{11,22}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	shizihou={ --狮子吼_10
	--群战中作用较大
	--对目标造成stun状态的几率较高
	--1场战斗中可使用2~5次
	--? 20级与1级时，如何体现出区别，升级带来的更多效果与更多消耗之间的关系
		state_fixed_attack={{{1,35},{10,70},{11,73}},{{1,18*2.5},{20,18*2.5}}},
		state_hurt_attack={{{1,27},{10,54},{11,56}},{{1,18*1.5},{20,18*1.5}}},
		missile_hitcount={{{1,3},{10,5},{11,5}}},
		skill_mintimepercast_v={{{1,5*18},{10,5*18}}},
		skill_mintimepercastonhorse_v={{{1,5*18},{10,5*18}}},
		skill_cost_v={{{1,50},{10,100},{11,100}}},
	},
	fumogunfa={ --伏魔棍法_20
		appenddamage_p= {{{1,100},{20,100},{21,100*nA0}}},
		physicsenhance_p={{{1,85},{10,130},{20,180},{21,180*nA0}}},
		physicsdamage_v={
			[1]={{1,500*0.9},{10,590*0.9},{20,690*0.9},{21,690*nA0*0.9}},
			[3]={{1,500*1.1},{10,590*0.9},{20,690*1.1},{21,690*nA0*1.1}}
			},
	--	attackrating_p={{{1,30},{20,90}}},
		skill_cost_v={{{1,20},{20,50},{21,50}}},
		state_hurt_attack={{{1,15},{10,35},{20,40},{21,41}},{{1,18},{20,18}}},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		addskilldamagep={36, {{1,2},{20,30},{21,35}},1},
	},
	budongmingwang={ --不动明王_10
		adddefense_v={{{1,20},{10,150},{11,165}}},
		poisondamagereturn_p={{{1,10},{10,40},{12,45}}},
		--lifemax_p={{{1,30},{10,60},{20,80}}},
		autoskill={{{1,2},{2,2}},{{1,1},{20,20}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	budongmingwang_child={ --不动明王子_10
		--平均触发间隔3+5秒
		adddefense_v={{{1,-30},{10,-300},{11,-330}}},--由于减速部分+1不会成长,所以减闪避每+1增加10%
		fastwalkrun_p={{{1,-3},{10,-30},{11,-30}}},
		skill_statetime={{{1,18*8},{10,18*8},{11,18*8}}},
		superposemagic={{{1,2},{10,2},{11,2}}},
		missile_hitcount={{{1,3},{10,3},{11,3}}},
	},
	yigujing={ --易骨经_20
		lifemax_p={{{1,10},{20,50},{21,52}}},
		lifereplenish_p={{{1,5},{20,20},{21,21}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	qixingluoshagun={ --七星罗刹棍
		appenddamage_p= {{{1,105*nS01},{10,105},{20,105*nS20},{21,105*nS20*nA0}}},
		physicsenhance_p={{{1,175*nS01},{10,175},{20,175*nS20},{21,175*nS20*nA0}}},
		physicsdamage_v={
			[1]={{1,750*0.9*nS01},{10,750*0.9},{20,750*0.9*nS20},{21,750*0.9*nS20*nA0}},
			[3]={{1,750*1.1*nS01},{10,750*1.1},{20,750*1.1*nS20},{21,750*1.1*nS20*nA0}}
			},
		skill_cost_v={{{1,50},{20,100},{21,100}}},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		state_hurt_attack={{{1,25},{10,45},{20,50}},{{1,18},{20,18}}},
		missile_hitcount={{{1,5},{5,6},{10,7},{15,8},{20,9},{21,9}}},
	},
	damowujing={ --达摩武经
		castspeed_v={{{1,10},{10,16},{20,26},{23,29},{24,29}}},
		state_hurt_attackrate={{{1,10},{20,100}}},
		state_weak_resistrate={{{1,10},{10,100},{20,150}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	wuxiangshengong={ --无相神功
		skilldamageptrim={{{1,1},{10,10}}},
		skillselfdamagetrim={{{1,1},{10,10}}},
		state_hurt_attacktime={{{1,10},{10,80}}},
		state_weak_resisttime={{{1,10},{10,120}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	
	jingangbuhuai={ --中级秘籍：金刚不坏
		autoskill={{{1,24},{2,24}},{{1,1},{10,10}}},
		skill_skillexp_v=FightSkill.tbParam.tbMidBookSkillExp,
		skill_statetime={{{1,-1},{2,-1}}},
	},
	jingangbuhuai_child={ --中级秘籍：金刚不坏
		dynamicmagicshieldbymaxhp_p={{{1,1000},{10,1000},{12,1000}},{{1,35},{10,75},{11,76}}},
		posionweaken={{{1,999999},{10,999999},{12,999999}},{{1,35},{10,75},{11,76}}},
		meleedamagereturn_p={{{1,5},{10,30},{12,33}}},
		rangedamagereturn_p={{{1,5},{10,30},{12,33}}},
		fastwalkrun_p={{{1,10},{10,40},{11,40}}},
		--poisondamagereturn_p={{{1,10},{10,60}}},
		skill_statetime={{{1,3*18},{10,6*18}}},
	},
	
	zuibaxiangun={ --醉八仙棍_10
		state_drag_attack={{{1,35},{10,85},{11,89}},{{1,14},{10,14},{11,14}},{{1,32},{2,32}}},
		state_fixed_attack={{{1,35},{10,85},{11,89}},{{1,18*2.5},{10,18*2.5}}},
		missile_hitcount={{{1,3},{10,8},{11,8}}},
		skill_cost_v={{{1,50},{10,100},{11,100}}},
		skill_mintimepercast_v={{{1,12*18},{10,12*18}}},
		skill_mintimepercastonhorse_v={{{1,12*18},{10,12*18}}},
	},
	gunshaoadvancedbook={ --棍少高级秘籍技能
		autoskill={{{1,40},{2,40}},{{1,1},{20,20}}},
		skill_statetime={{{1,-1},{10,-1}}},
		skill_skillexp_v=FightSkill.tbParam.tbHighBookSkillExp,
	},
	gunshaoadvancedbook_child={ --棍少高级秘籍状态
		state_hurt_ignore={1},
		state_weak_ignore={1},
		state_slowall_ignore={1},
		state_stun_ignore={1},
		state_fixed_ignore={1},
		skill_statetime={{{1,18*3},{10,18*3}}},
	},
	gunshao120={ --棍少120_疯魔棍法_10
		autoskill2={{{1,101},{2,101}},{{1,1},{10,10}}},
		autoskill={{{1,113},{2,113}},{{1,1},{10,10}}},
		skill_statetime={{{1,-1},{10,-1}}},
	},
	gunshao120_child={ --棍少120状态
		--steallifeenhance_p={{{1,5},{10, 50},{11, 50}},100},
		damage_return_receive_p={{{1,-75},{10,-75},{11,-75}}},
		autoskill={{{1,102},{2,102}},{{1,2},{10,20},{11,21}}},
		addenchant={33, {{1,1}, {2, 2}}},
		reducenextcasttime_p={31, {{1,5}, {10, 50}, {11, 50}}},
		reducenextcasttime_p2={821, {{1,5}, {10, 50}, {11, 50}}},
		skill_statetime={{{1,18*5},{10,18*5}}},
	},
	--[[
	--摩诃无量七伤拳存档
	gunshao120={ --棍少120_10_已经有人加10级了...只好保留10级,
		skilldamageptrim	={{{1, 2},{10,7},{11,7}}},--每次=1%提升太大了,转到意义不大的叠加次数上...
		skillselfdamagetrim	={{{1, 2},{10,7},{11,7}}},
		steallifeenhance_p	={{{1,-5},{10,-5},{11,-5}},{{1,100},{10,100}}},
		superposemagic		={{{1,2},{2,3},{10,10},{11,11}}},
		skill_statetime={{{1,60*60*18},{10,60*60*18}}},
	},
	gunshao120_child={ --棍少120附属技能_1
		removestate={822},
		--addstartskill={36,808,1},
		lifereplenish_p={5},
		steallifeenhance_p={5,100},
		addenchant={35, {{1,1}, {2, 2}}},
		skill_statetime={60*60*18},
	},]]
	pudugunfa3={ --普渡棍法_20
		appenddamage_p= {{{1,100},{20,100},{21,100*nA0}}},
		physicsenhance_v={
			[1]={{1,50*0.9},{10,230*0.9},{20,380*0.9},{21,380*nA0*0.9}},
			[3]={{1,50*1.1},{10,230*1.1},{20,380*1.1},{21,380*nA0*1.1}}
			},
		skill_cost_v={{{1,2},{20,20},{21,20}}},
		state_hurt_attack={{{1,15},{10,40},{20,45},{21,46}},{{1,18},{20,18}}},
		seriesdamage_r={0},--={{{1,50},{20,100},{21,100}}},
		addskilldamagep={2995, {{1,2},{20,30},{20,35}},1},
		addskilldamagep2={2997, {{1,2},{20,10},{21,12}},1},
	},
	shaolingunfa3={ --少林棍法_10
		addphysicsmagic_p={{{1,10},{10,150},{11,165}}},
		deadlystrikeenhance_r={{{1,30},{10,50},{11,55}}},
		castspeed_v={{{1,10},{10,20},{11,21},{12,22},{13,22}}},
		lifemax_p={{{1,5},{10,20},{11,22}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	fumogunfa3={ --伏魔棍法_20
		appenddamage_p= {{{1,100},{20,100},{21,100*nA0}}},
		physicsenhance_v={
			[1]={{1,500*0.9},{10,590*0.9},{20,690*0.9},{21,690*nA0*0.9}},
			[3]={{1,500*1.1},{10,590*0.9},{20,690*1.1},{21,690*nA0*1.1}}
			},
		skill_cost_v={{{1,20},{20,50},{21,50}}},
		state_hurt_attack={{{1,15},{20,75},{21,77}},{{1,18},{20,18}}},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		addskilldamagep={2997, {{1,2},{20,30},{21,35}},1},
	},
	qixingluoshagun3={ --七星罗刹棍
		appenddamage_p= {{{1,105*nS01},{10,105},{20,105*nS20},{21,105*nS20*nA0}}},
		physicsenhance_v={
			[1]={{1,750*0.9*nS01},{10,750*0.9},{20,750*0.9*nS20},{21,750*0.9*nS20*nA0}},
			[3]={{1,750*1.1*nS01},{10,750*1.1},{20,750*1.1*nS20},{21,750*1.1*nS20*nA0}}
			},
		skill_cost_v={{{1,50},{20,100},{21,100}}},
		seriesdamage_r={{{1,100},{20,250},{21,250}}},
		state_hurt_attack={{{1,25},{10,45},{20,50}},{{1,18},{20,18}}},
		state_stun_attack={{{1,3},{10,3}},{{1,18*2},{20,18*2}}},
	},
	mizhonghuanying3={ --迷踪幻影
		addedwith_enemycount={{{1,2999},{10,2999}}, {{1,5},{10,15}}, {{1,1600},{10,1600}}},
		skill_statetime={{{1,-1},{2,-1}}}
	},
	mizhonghuanying3_child={ --迷踪幻影子
		lifemax_v={{{1,50},{10,500}}},
		lifemax_p={{{1,5},{10,10},{13,11}}},
		skill_statetime={{{1,18*1},{10,18*3}}},
	},
	chanyuangong3={ --禅圆功_10
		vitality_v={{{1,60},{10,150},{12,165}}},
		energy_v={{{1,60},{10,150},{12,165}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	yiyangzhi3={ --一阳指_10
		state_fixed_attack={{{1,50},{10,85},{13,85}},{{1,18*3},{10,18*3.5},{13,18*4.5}}},
		state_drag_attack={{{1,40},{10,50},{11,50}},{{1,25},{10,25},{11,25}},{{1,32},{2,32}}},
		skill_cost_v={{{1,20},{10,50},{11,50}}},
		skill_attackradius={600},
		skill_mintimepercast_v={18*10},
		skill_mintimepercastonhorse_v={18*10},
		missile_speed_v={100},
	},
	baibuchuanyang3={ --中级秘籍：百步穿杨
		fastwalkrun_p={{{1,10},{10,30},{11,30}}},
		addenchant={44, {{1,1}, {2, 2}}},
		skill_skillexp_v=FightSkill.tbParam.tbMidBookSkillExp,
		skill_statetime={{{1,-1},{2,-1}}},
	},
	nhulaithanchuong={ --高级秘籍
		autoskill={{{1,148},{10,148}},{{1,1},{10,10}}},
		skill_statetime={{{1,-1},{10,-1}}},
		skill_skillexp_v=FightSkill.tbParam.tbHighBookSkillExp,
	},
	
	nhulaithanchuong_child={ --高级秘籍子
		appenddamage_p= {{{1,10*0.7*1.2},{10,10*1.2},{11,10*1.2*1.05}}},
		physicsenhance_v={
			[1]={{1,350*0.9*0.7*1.2},{10,350*0.9*1.2},{11,350*0.9*1.2*1.05}},
			[3]={{1,830*1.1*0.7*1.2},{10,830*1.1*1.2},{11,830*1.1*1.2*1.05}},
			},
		seriesdamage_r={{{1,250},{10,250}}},
		state_hurt_attack={{{1,12},{10,85}},{{1,18*1.5},{10,18*2.5},{15,18*3}}},
		missile_hitcount={{{1,3},{10,8},{11,8}}},
	},
}

FightSkill:AddMagicData(tb)

local tbSkill	= FightSkill:GetClass("budongmingwang");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbMsg = {};
	local szMsg = "";
	local szMsg = szMsg.."\n";
	szMsg = szMsg.."Bị đánh trúng <color=gold>"..tbAutoInfo.nPercent.."%<color> thi triển trạng thái với kẻ địch xung quanh:\n";
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0);
	for i=1, #tbMsg do
		szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	szMsg = szMsg.."\nGiãn cách thi triển: <color=Gold>"..FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime).." giây<color>";
	return szMsg;
end;

local tbSkill	= FightSkill:GetClass("xianglongfuhu");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbCCInfo	= KFightSkill.GetSkillInfo(tbChildInfo.tbEvent.nStartSkillId, tbChildInfo.tbEvent.nLevel);
	local nRate = tbChildInfo.tbWholeMagic["state_slowall_attack"][1];
	local nPerCastTime = (tbAutoInfo.nPerCastTime - KFightSkill.GetAutoSkillCDTimeAddition(tbSkillInfo.nId, tbAutoInfo.nId));
	
	if (nPerCastTime < 0) then
		nPerCastTime = 0;
	end
	local szMsg	= string.format("\n<color=green>Chiêu thức con<color>\nKhi bị đánh trúng thi triển: <color=gold>%d%%<color>\nẢnh hưởng tối đa: <color=gold>%d<color>\nLàm chậm đối thủ: <color=gold>%d%%<color>, duy trì <color=gold>%s giây<color>\nMiễn dịch trạng thái thọ thương, suy yếu, làm chậm, choáng, bất động, duy trì <color=gold>%s giây<color>\nGiãn cách thi triển: <color=Gold>%s giây<color>",
		tbAutoInfo.nPercent,
		tbChildInfo.nMissileHitcount,
		nRate,
		FightSkill:Frame2Sec(tbChildInfo.tbWholeMagic["state_slowall_attack"][2]),
		FightSkill:Frame2Sec(tbCCInfo.nStateTime),
		FightSkill:Frame2Sec(nPerCastTime));
	return szMsg;
end;

local tbSkill	= FightSkill:GetClass("jingangbuhuai");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbMsg = {};
	local szMsg = "";
	szMsg = szMsg.."Khi sinh lực giảm đến 25% <color=gold>"..tbAutoInfo.nPercent.."%<color> tự động nhận được các trạng thái sau:\n";
	szMsg = szMsg.."    <color=green>Kim Cang Bất Hoại<color>\n";
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0);
	for i=1, #tbMsg do
		szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	szMsg = string.gsub(szMsg, "Vượt quá sát thương ban đầu", "    Vượt quá sát thương ban đầu");
	szMsg = szMsg.."\nGiãn cách thi triển: <color=Gold>"..FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime).." giây<color>";
	return szMsg;
end;

local tbSkill	= FightSkill:GetClass("gunshaoadvancedbook");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbMsg = {};
	local szMsg = "";
	szMsg = szMsg.."Bị đánh trúng nhận trạng thái:\n";
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0);
	for i=1, #tbMsg do
		szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	szMsg = szMsg.."\nGiãn cách thi triển: <color=Gold>"..FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime).." giây<color>";
	return szMsg;
end;

local tbSkill	= FightSkill:GetClass("daoshao120");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbMsg = {};
	local szMsg = "";
	szMsg = szMsg.."Khi bị tấn công tự động nhận trạng thái sau:\n";
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0);
	for i=1, #tbMsg do
		szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	szMsg = szMsg.."\nGiãn cách thi triển: <color=Gold>"..FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime).." giây<color>";
	return szMsg;
end;

local tbSkill	= FightSkill:GetClass("daoshao120_child");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local szMsg	= string.format("Bị đánh <color=gold>%s<color> lần mất hiệu quả",
		tbAutoInfo.nCastCount);
	return szMsg;
end;

--[[
local tbSkill	= FightSkill:GetClass("daoshao120_child");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local szMsg	= string.format("每次被攻击化解伤害效果减少<color=gold>1/12<color>");
	return szMsg;
end;
function tbSkill:GetAutoDesc2(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local szMsg	= "";
	return szMsg;
end;
]]
local tbSkill = FightSkill:GetClass("gunshao120")

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbMsg = {};
	local szMsg = "";
	szMsg = szMsg.."Mỗi lần đánh trúng kẻ địch có xác suất <color=gold>"..tbAutoInfo.nPercent.."%<color> tự động thi triển;";
	return szMsg;
end;

function tbSkill:GetAutoDesc2(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbMsg = {};
	local szMsg = "";
	szMsg = szMsg.."Mỗi lần đánh trúng kẻ địch khi tấn công gần <color=gold>"..tbAutoInfo.nPercent.."%<color> tự động thi triển:\n";
	szMsg = szMsg.."    <color=green>Phong Ma Côn Pháp<color>\n";
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0);
	for i=1, #tbMsg do
		szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	-- szMsg = string.gsub(szMsg, "<color=orange>Túy Bát Tiên Côn<color>的施展", "    <color=orange>Túy Bát Tiên Côn<color>的施展");
	--szMsg = szMsg.."\n触发间隔：<color=Gold>"..FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime).."秒<color>";
	return szMsg;
end;


local tbSkill = FightSkill:GetClass("gunshao120_child")

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	--local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbMsg = {};
	local szMsg = "";

	szMsg = szMsg.."Mỗi nửa giây thi triển thêm <color=green>["..FightSkill:GetSkillName(tbAutoInfo.nSkillId).."]<color>: <color=gold>cấp "..tbAutoInfo.nSkillLevel.."<color>";
	return szMsg;
end;

local tbSkill	= FightSkill:GetClass("nhulaithanchuong");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbChildInfo2	= KFightSkill.GetSkillInfo(tbChildInfo.tbEvent.nVanishedSkillId, tbChildInfo.tbEvent.nLevel, me, 1)
	local szMsg = ""
	szMsg = szMsg.."Khi bị tấn công có xác suất <color=gold>"..tbAutoInfo.nPercent.."%<color> thi triển:\n";
	szMsg = szMsg.."    <color=green>Như Lai Thần Chưởng<color>\n";
	local tbMsg = {};
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo2, 0);
	for i=1, #tbMsg do
		szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	szMsg = szMsg.."\nGiãn cách thi triển: <color=Gold>"..FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime).." giây<color>";
	return szMsg;
end;
