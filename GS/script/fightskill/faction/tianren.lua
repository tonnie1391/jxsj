Require("\\script\\fightskill\\fightskill.lua")
local nA0 = FightSkill.tbParam.nSadd;	--攻速类攻击技能+1的成长系数
local nA1 = FightSkill.tbParam.nSadd1;	--格斗类攻击技能+1的成长系数
local nS01 = FightSkill.tbParam.nS1;	--技能1级的数值系数
local nS20 = FightSkill.tbParam.nS20;	--技能20级的数值系数

--天忍
local tb	= {
	--战忍
	canyangruxue={ --残阳如血_20
		appenddamage_p= {{{1,100},{20,100},{21,100*nA0}}},
		seriesdamage_r={0},--={{{1,50},{20,100},{21,100}}},
		physicsenhance_p={{{1,35},{10,53},{20,76},{21,76*nA0}}},
		firedamage_v={
			[1]={{1,60*0.85},{10,375*0.9},{20,625*0.85},{21,625*nA0*0.85}},
			[3]={{1,60*1.15},{10,375*1.1},{20,625*1.15},{21,625*nA0*1.15}}
		},
		state_hurt_attack={{{1,15},{10,35},{20,40},{21,41}},{{1,18},{20,18}}},
		state_burn_attack={{{1,15},{10,35},{20,40},{21,41}},{{1,36},{20,54},{21,54}}},
		skill_cost_v={{{1,2},{20,20},{21,20}}},
		addskilldamagep={146, {{1,2},{20,30},{21,35}},1},
		addskilldamagep2={149, {{1,2},{20,10},{21,12}},1},
	--	attackrating_p={{{1,20},{20,60}}},
	},
	tianrenmaofa={ --天忍矛法_10
		addphysicsdamage_p={{{1,25},{10,130},{11,143}}},
		attackratingenhance_p={{{1,50},{10,150},{11,165}}},
		deadlystrikeenhance_r={{{1,30},{10,50},{11,55}}},
		attackspeed_v={{{1,10},{10,35},{11,36},{12,37},{13,37}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	huanyingzhuihunqiang={ --幻影追魂枪_10
		state_drag_attack={{{1,40},{10,100},{11,100}},{{1,25},{10,25},{11,25}},{{1,32},{2,32}}},
		fastwalkrun_p={{{1,-10},{10,-30},{11,-31}}},
		skill_statetime={{{1,18*2},{10,18*4},{11,18*4}}},
		skill_cost_v={{{1,20},{20,50},{21,50}}},
		skill_mintimepercast_v={{{1,20*18},{10,20*18},{11,20*18},{12,20*18}}},
		skill_mintimepercastonhorse_v={{{1,20*18},{10,20*18},{11,20*18},{12,20*18}}},
		missile_range={1,0,1},
	},
	huanyingzhuihunqiang_child={ --幻影追魂枪子子
		--faststaminareplenish_v={{{1,-50},{10,-100}}},
		fastwalkrun_p={{{1,-10},{10,-30},{11,-31}}},
		skill_statetime={{{1,18*2},{10,18*4},{11,18*4}}}
	},
	jinchantuoqiao={ --金蝉脱壳_20
		state_hurt_resisttime={{{1,30},{20,170},{21,177}}},
		adddefense_v={{{1,50},{10,150},{20,360},{21,375}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	liehuoqingtian={ --烈火情天_20
		appenddamage_p= {{{1,75},{10,93},{20,104},{21,104*nA0}}},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		physicsenhance_p={{{1,50},{10,68},{20,88},{21,88*nA0}}},
		firedamage_v={
			[1]={{1,700*0.9},{10,835*0.9},{20,935*0.9},{21,935*nA0*0.9}},
			[3]={{1,700*1.1},{10,835*1.1},{20,935*1.1},{21,935*nA0*1.1}}
		},
		state_hurt_attack={{{1,15},{10,35},{20,50},{21,51}},{{1,18},{20,18}}},
		state_burn_attack={{{1,15},{10,35},{20,40},{21,41}},{{1,36},{20,54},{21,54}}},
		skill_cost_v={{{1,20},{20,50},{21,50}}},
	--	attackrating_p={{{1,30},{20,90}}},
		steallife_p={{{1,1},{20,5},{21,6}},{{1,100},{20,100}}},
		stealmana_p={{{1,1},{20,5},{21,6}},{{1,100},{20,100}}},
		addskilldamagep={149, {{1,2},{20,30},{21,35}},1},
	},
	beisuqingfeng={ --悲酥清风_10
		autoskill={{{1,4},{2,4}},{{1,1},{10,10}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	beisuqingfeng_child={ --悲酥清风子_10
		state_hurt_resisttime={{{1,-15},{10,-125},{11,-130}}},
		attackratingenhance_p={{{1,-20},{10,-150},{12,-162}}},
		--skill_cost_v={{{1,100},{10,150},{11,150}}},
		adddefense_v={{{1,-50},{10,-150},{11,-155}}},
		missile_hitcount={{{1,3},{10,5},{11,5},{12,5}}},
		skill_statetime={180*18},
	},
	moyinshipo={ --魔音噬魄_20
		state_confuse_attack={{{1,40},{20,80},{23,85}},{{1,18*3},{20,18*6},{21,18*6}}},
		state_burn_attack={{{1,25},{20,75},{23,80}},{{1,18*2},{20,18*3},{21,18*3}}},
		skill_cost_v={{{1,200},{20,500},{21,500}}},
		skill_mintimepercast_v={{{1,45*18},{20,35*18},{21,34*18}}},
		skill_mintimepercastonhorse_v={{{1,45*18},{20,35*18},{21,34*18}}},
		missile_hitcount={{{1,3},{5,4},{10,5},{15,6},{16,6}}},
		missile_range={13,0,13},
	},
	moyinshipo_child={ --魔音噬魄子
		autoskill={{{1,20},{2,20}},{{1,1},{10,10}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	moyinshipo_child2={ --魔音噬魄子子
		state_confuse_attack={{{1,100},{20,100}},{{1,18*3},{20,18*6},{21,18*6}}},
		state_burn_attack={{{1,25},{20,100},{21,100}},{{1,18*2},{20,18*3},{21,18*3}}},
		missile_hitcount={{{1,3},{5,4},{10,5},{15,6},{16,6}}},
	},
	yunlongji={ --云龙击
		appenddamage_p= {{{1,105*nS01},{10,105},{20,105*nS20},{21,105*nS20*nA0}}},
		physicsenhance_p={{{1,145*nS01},{10,145},{20,145*nS20},{21,145*nS20*nA0}}},
		firedamage_v={
			[1]={{1,1000*0.9*nS01},{10,1000*0.9},{20,1000*0.9*nS20},{21,1000*0.9*nS20*nA0}},
			[3]={{1,1000*1.1*nS01},{10,1000*1.1},{20,1000*1.1*nS20},{21,1000*1.1*nS20*nA0}}
			},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		skill_cost_v={{{1,50},{20,100},{21,100}}},
		state_hurt_attack={{{1,15},{10,35},{20,50}},{{1,18},{20,18}}},
		state_burn_attack={{{1,15},{10,35},{20,40}},{{1,36},{20,54},{21,54}}},
		steallife_p={{{1,1},{20,10}},{{1,100},{20,100}}},
		stealmana_p={{{1,1},{20,10}},{{1,100},{20,100}}},
		missile_hitcount={{{1,3},{10,4},{20,5},{21,5}}},
	},
	tianmojieti={ --天魔解体
		state_hurt_attackrate={{{1,10},{20,100}}},
		--state_burn_attackrate={{{1,10},{20,100}}},
		state_stun_resistrate={{{1,10},{10,100},{20,150}}},
		state_hurt_resistrate={{{1,10},{10,100},{20,150}}},
		attackspeed_v={{{1,10},{10,16},{20,26},{23,29},{24,29}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	moyanzaitian={ --魔炎在天
		skilldamageptrim={{{1,1},{10,10}}},
		skillselfdamagetrim={{{1,1},{10,10}}},
		--state_hurt_attacktime={{{1,10},{20,135}}},
		state_burn_attacktime={{{1,10},{10,80}}},
		state_hurt_resisttime={{{1,10},{10,120}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	
	biyuefeixing={ --中级秘籍：碧月飞星
		addenchant={10, {{1,1}, {2, 2}}},
		--adddragspeed={787, 0, {{1,2}, {10, 18}}},	
		damage_return_receive_p={{{1,-10},{10,-30},{11,-36}}},
		--decreaseskillcasttime={492, {{1,18}, {10, 18*10}}},
		skill_skillexp_v=FightSkill.tbParam.tbMidBookSkillExp,
		skill_statetime={{{1,-1},{2,-1}}},
		--{szMagicName = "adddragspeed", tbValue = {787, 0, {{1,2}, {10, 18}}}},
		--{szMagicName = "addmissilerange", tbValue = {787, {{1,1}, {10, 1}}}},
		--{szMagicName = "addmissilerange", tbValue = {148, {{1,2}, {10, 4}}}},
		--{szMagicName = "damage_return_receive_p", tbValue = {{{1,-10},{10,-30}}}},
		--{szMagicName = "decreaseskillcasttime", tbValue = {492, {{1,18}, {10, 18*10}}}},
		--{szMagicName = "skill_skillexp_v", tbValue = FightSkill.tbParam.tbMidBookSkillExp},
		--{szMagicName = "skill_statetime", tbValue = {{{1,-1},{2,-1}}}},
	},
	
	feihongwuji={ --飞鸿无迹_10
		--appenddamage_p= {{{1,268*nS01},{10,268},{11,268*nA0}}},
		floatdamage_p = {
			[1] = {{1,0.8*2680*nS01},{10,0.8*2680},{11,0.8*2680*nA0}},
			[2] = {{1,1.2*2680*nS01},{10,1.2*2680},{11,1.2*2680*nA0}},
		},
		physicsenhance_p={{{1,370*nS01},{10,370},{11,370*nA0}}},
		firedamage_v={
			[1]={{1,2550*0.8*0.7},{10,2550*0.8},{11,2550*0.8*nA0}},
			[3]={{1,2550*1.2*0.7},{10,2550*1.2},{11,2550*1.2*nA0}}
			},
		seriesdamage_r={0},--={{{1,250},{10,250},{11,250}}},
		skill_cost_v={{{1,50},{10,100},{11,100}}},
		state_hurt_attack={{{1,35},{10,50}},{{1,18},{10,18}}},
		state_burn_attack={{{1,28},{10,40}},{{1,36},{10,54}}},
		skill_mintimepercast_v={{{1,45*18},{10,35*18},{11,34*18}}},
		skill_mintimepercastonhorse_v={{{1,45*18},{10,35*18},{11,34*18}}},
	},
	feihongwuji_dmg={ --飞鸿无迹_10
		--appenddamage_p= {{{1,268*nS01},{10,268},{11,268*nA0}}},
		floatdamage_p = {
			[1] = {{1,0.8*2680*nS01},{10,0.8*2680},{11,0.8*2680*nA0}},
			[2] = {{1,1.2*2680*nS01},{10,1.2*2680},{11,1.2*2680*nA0}},
		},
		physicsenhance_p={{{1,370*nS01},{10,370},{11,370*nA0}}},
		firedamage_v={
			[1]={{1,2550*0.8*0.7},{10,2550*0.8},{11,2550*0.8*nA0}},
			[3]={{1,2550*1.2*0.7},{10,2550*1.2},{11,2550*1.2*nA0}}
			},
		seriesdamage_r={0},--={{{1,250},{10,250},{11,250}}},
		skill_cost_v={{{1,50},{10,100},{11,100}}},
		state_hurt_attack={{{1,35},{10,50}},{{1,18},{10,18}}},
		state_burn_attack={{{1,28},{10,40}},{{1,36},{10,54}}},
		skill_mintimepercast_v={{{1,45*18},{10,35*18},{11,34*18}}},
		skill_mintimepercastonhorse_v={{{1,45*18},{10,35*18},{11,34*18}}},
		
		missile_hitcount={{{1,1},{10,1},{11,1}}},
	},
	feihongwuji_child={ --飞鸿无迹免疫
		ignoredebuff={{{1,32767},{2,32767}}},
		redeivedamage_dec_p2={{{1,200},{10,200}}},
		deadlystrikedamageenhance_p={{{1,-0},{10,-0}}},
		skill_statetime={{{1,18*5},{2,18*5}}},
	},
	zhanrenadvancedbook={ --高级秘籍技能：九曲一合枪
		addenchant={25, {{1,1}, {2, 2}}},
		autoskill={3,{{1,1},{10,10}}},
		skill_statetime={{{1,-1},{2,-1}}},
		skill_skillexp_v=FightSkill.tbParam.tbHighBookSkillExp,
	},
	zhanrenadvancedbook_child={ --九曲一合枪_会心
		autoskill={7,{{1,1},{10,10}}},
		deadlystrikeenhance_r={{{1,999},{10,9999}}},
		addenchant={34, {{1,1}, {2, 2}}},
		ignoreskill={{{1,49},{10,99},{11,99}},0,{{1,3},{2,3}}},
		skill_statetime={{{1,3*18},{2,3*18}}},
	},
	
	zhanren120={ --战忍120_10
		changecdtype		={{{1,492},{10,492}},{{1,100},{5,100},{6,200},{9,200},{10,300},{11,300}},{{1,100},{10,150},{11,150}}},--拉
		changecdtype3		={{{1,847},{10,847}},{{1,100},{5,100},{6,200},{9,200},{10,300},{11,300}},{{1,100},{10,200},{11,200}}},--冲
		changecdtype2		={{{1,148},{10,148}},{{1,100},{9,100},{10,200},{11,200}},{{1,100},{10,100},{11,100}}},--乱
		skill_statetime={{{1,-1},{2,-1}}},
	},

	--魔忍
	tanzhilieyan={ --弹指烈焰_20
		appenddamage_p= {{{1,100},{10,100},{20,100},{21,100*nA0}}},
		seriesdamage_r={0},--={{{1,50},{20,100},{21,100}}},
		firedamage_v={
			[1]={{1,60*0.9},{10,132*0.9},{20,172*0.9},{21,172*nA0*0.9}},
			[3]={{1,60*1.1},{10,132*1.1},{20,172*1.1},{21,172*nA0*1.1}}
		},
		state_burn_attack={{{1,15},{10,35},{20,40},{21,41}},{{1,36},{20,54},{21,54}}},
		skill_cost_v={{{1,10},{20,50},{21,50}}},
		missile_hitcount={{{1,2},{10,3},{11,4},{12,4}}},
		addskilldamagep={153, {{1,2},{20,30},{21,35}},1},
		addskilldamagep2={156, {{1,2},{20,10},{21,12}},1},
		addskilldamagep3={157, {{1,2},{20,10},{21,12}}},
		skill_mintimepercast_v={2*18},
		skill_mintimepercastonhorse_v={2*18},
	},
	tianrenjianfa={ --天忍刀法_10
		addfiremagic_v={{{1,50},{10,250},{11,275}}},
		deadlystrikeenhance_r={{{1,30},{10,50},{11,55}}},
		castspeed_v={{{1,5},{10,15},{11,16},{12,17},{13,17}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	tuishantianhai={ --推山填海_20
		appenddamage_p= {{{1,20},{10,20},{20,20},{21,20*nA0}}},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		firedamage_v={
			[1]={{1,150*0.95},{10,240*0.9},{20,340*0.95},{21,340*nA0*0.95}},
			[3]={{1,150*1.05},{10,240*1.1},{20,340*1.05},{21,340*nA0*1.05}}
		},
		state_burn_attack={{{1,15},{20,30},{21,31}},{{10,36},{20,36}}},
		skill_missilenum_v={{{1,2},{20,6},{21,6},{22,6}}},
		skill_cost_v={{{1,100},{20,250}}},
		missile_hitcount={{{1,2},{10,3},{11,3}}},
		addskilldamagep={156, {{1,2},{20,30},{21,35}},1},
		addskilldamagep2={157, {{1,2},{20,30},{21,35}}},
		skill_mintimepercast_v={3.5*18},
		skill_mintimepercastonhorse_v={3.5*18},
	},
	limoduohun={ --厉魔夺魂
		addphysicsdamage_p={{{1,-50},{10,-125},{12,-150}}},
		fastwalkrun_p={{{1,-10},{10,-30},{11,-30}}},
		skill_cost_v={{{1,20},{10,20}}},
		missile_hitcount={{{1,3},{10,5},{11,5},{12,5}}},
		skill_statetime={180*18},
	},
	huolianfenhua={ --火莲焚华_10
		state_burn_attack={{{1,6},{10,18},{11,19}},{{1,18*2.5},{10,18*2.5}}},
		state_drag_attack={{{1,35},{10,80}},{{1,25},{10,25},{11,25}},{{1,11},{2,11}}},
		missile_drag={1},
		missile_hitcount={{{1,3},{10,5},{11,5},{12,5}}},
		skill_cost_v={{{1,50},{10,100},{20,100}}},
		skill_mintimepercast_v={{{1,60*18},{10,30*18},{12,27*18}}},
		skill_mintimepercastonhorse_v={{{1,60*18},{10,30*18},{12,27*18}}},
		missile_range={11,0,11},
		missile_lifetime_v={5*18},
		skill_maxmissile={{{1,3},{10,3}}},
	},
	shehunluanxin={ --慑魂乱心_20
		state_palsy_attack={{{1,35},{10,65},{20,75},{23,85}},{{1,18*1.5},{10,18*2.5},{20,18*3},{21,18*3.2}}},
		skill_cost_v={{{1,300},{20,500},{21,500}}},
		skill_mintimepercast_v={{{1,45*18},{20,35*18},{21,30*18},{22,30*18}}},
		skill_mintimepercastonhorse_v={{{1,45*18},{20,35*18},{21,30*18},{22,30*18}}},
		missile_hitcount={{{1,3},{5,4},{10,5},{15,6},{16,6},{21,6},{22,6}}},
	},
	tianwailiuxing={ --天外流星
		appenddamage_p= {{{1,80*nS01},{10,80},{20,80*nS20},{21,80*nS20*nA0}}},
		firedamage_v={
			[1]={{1,750*0.9*nS01},{10,750*0.9},{20,750*0.9*nS20},{21,750*0.9*nS20*nA0}},
			[3]={{1,750*1.1*nS01},{10,750*1.1},{20,750*1.1*nS20},{21,750*1.1*nS20*nA0}}
			},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		skill_cost_v={{{1,100},{20,200},{21,200}}},
		state_burn_attack={{{1,15},{20,30}},{{10,36},{20,36}}},
		skill_vanishedevent={{{1,157},{20,157}}},
		skill_showevent={{{1,8},{20,8}}},
	},
	yehuofencheng={ --业火焚城，天外流星第二式
		appenddamage_p= {{{1,10*nS01},{10,10},{20,10*nS20},{21,10*nS20*nA0}}},
		firedamage_v={
			[1]={{1,150*0.9*nS01},{10,150*0.9},{20,150*0.9*nS20},{21,150*0.9*nS20*nA0}},
			[3]={{1,150*1.1*nS01},{10,150*1.1},{20,150*1.1*nS20},{21,150*1.1*nS20*nA0}}
			},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		state_burn_attack={{{1,5},{20,25}},{{10,9},{20,9}}},
		missile_hitcount={{{1,3},{5,4},{10,5},{15,6},{20,7},{21,7}}},
	},
	chikongmoyan={ --炽空魔焰_20
		state_burn_attackrate={{{1,10},{10,100},{20,150}}},
		state_hurt_resistrate={{{1,10},{10,100},{20,150}}},
		castspeed_v={{{1,10},{10,16},{20,26},{23,29},{24,29}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	moyanqisha={ --魔焰七杀
		skilldamageptrim={{{1,1},{10,10}}},
		skillselfdamagetrim={{{1,1},{10,10}}},
		state_burn_attacktime={{{1,10},{10,80}}},
		state_hurt_resisttime={{{1,10},{10,120}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	
	xuanmingxixing={ --中级秘籍：玄冥吸星
		addenchant={11, {{1,1}, {2, 2}}},
		--addmissilelifetime={494, 0, {{1,18}, {10, 18*5}}},
		--addmissilerange={494, {{1,2}, {10, 6}}},
		damage_return_receive_p={{{1,-10},{10,-30},{11,-36}}},
		skill_skillexp_v=FightSkill.tbParam.tbMidBookSkillExp,
		skill_statetime={{{1,-1},{2,-1}}},
		--{szMagicName = "addmissilelifetime", tbValue = {494, 0, {{1,18}, {10, 18*5}}}},
		--{szMagicName = "addmissilerange", tbValue = {494, {{1,2}, {10, 6}}}},
		--{szMagicName = "decreaseskillcasttime", tbValue = {494, {{1,18}, {10, 18*10}}}},
		--{szMagicName = "decreaseskillcasttime", tbValue = {151, {{1,18*0.5}, {5, 18*1}, {10, 18*1.5}}}},
		--{szMagicName = "decreaseskillcasttime", tbValue = {153, {{1,18*0.5}, {5, 18*1}, {10, 18*1.5}}}},
		--{szMagicName = "damage_return_receive_p", tbValue = {{{1,-10},{10,-30}}}},
		--{szMagicName = "skill_skillexp_v", tbValue = FightSkill.tbParam.tbMidBookSkillExp},
		--{szMagicName = "skill_statetime", tbValue = {{{1,-1},{2,-1}}}},
	},
	
	shufuzhou={ --束缚咒_10
		autoskill={{{1,38},{2,38}},{{1,1},{10,10}}},
		fastwalkrun_p={{{1,10},{10,30},{11,31}}},
		damage_return_receive_p={{{1,-10},{10,-30}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	shufuzhou_child={ --束缚咒子
		state_palsy_attack={{{1,35},{10,75}},{{1,18*1.5},{10,18*2.5}}},
		missile_hitcount={{{1,3},{5,4},{10,5}}},
	},
	shufuzhou_child2={ --束缚咒子子
		fastwalkrun_p={{{1,10},{10,30},{11,30}}},
		skill_statetime={{{1,6*18},{10,15*18}}},
	},
	morenadvancedbook={ --魔忍高级秘籍
		autoskill={{{1,45},{10,45}},{{1,1},{10,10}}},
		skill_statetime={{{1,-1},{10,-1}}},
		skill_skillexp_v=FightSkill.tbParam.tbHighBookSkillExp,
	},
	morenadvancedbook_child={ --魔忍高级秘籍子
		autoskill={{{1,47},{10,47}},{{1,1},{10,10}}},
		skill_statetime={{{1,60*18},{10,60*18}}},
	},
	morenadvancedbook_child2={ --魔忍高级秘籍子2
		state_stun_attack		={{{1,20},{10,100},{11,105}},{{1,18*1},{20,18*1}}},
		state_hurt_attack		={{{1,20},{10,100},{11,105}},{{1,18*1},{20,18*1}}},
		state_weak_attack		={{{1,20},{10,100},{11,105}},{{1,18*3},{20,18*3}}},
		state_burn_attack		={{{1,20},{10,100},{11,105}},{{1,18*3},{20,18*3}}},
		state_slowall_attack	={{{1,20},{10,100},{11,105}},{{1,18*2.5},{20,18*2.5}}},
	},
	moren120={ --魔忍120_10
		autoskill={{{1,60},{10,60}},{{1,1},{10,10}}},
		steallifeenhance_p={{{1,1},{10,5},{12,6}},{{1,100},{10,100}}},
		skill_cost_v={{{1,500},{10,500}}},
		--skill_mintimepercast_v={{{1,15*18},{10,15*18}}},
		--skill_mintimepercastonhorse_v={{{1,15*18},{10,15*18}}},
		skill_statetime={300*18},
	},
	moren120_child={ --魔忍120子_10
		seriesdamage_r={0},--={{{1,250},{10,250}}},
		appenddamage_p={{{1,20*0.7},{10,20},{11,20}}},
		firedamage_v={
			[1]={{1,300*0.9*0.7},{10,300*0.9},{11,300*0.9}},
			[3]={{1,300*1.1*0.7},{10,300*1.1},{11,300*1.1}}
			},
		steallife_p={{{1,20},{10,200},{11,210}},{{1,100},{10,100}}},
	},
	
	huanyingfeihu={ --幻影飞狐
		deadlystrikeenhance_r={{{1,-50},{20,-150}}},
		skill_cost_v={{{1,50},{20,500}}},
		skill_statetime={{{1,18*120},{20,18*180}}},
	},
}

FightSkill:AddMagicData(tb)

local tbSkill	= FightSkill:GetClass("beisuqingfeng");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	--local tbCCInfo	= KFightSkill.GetSkillInfo(tbChildInfo.tbEvent.nStartSkillId, tbChildInfo.tbEvent.nLevel);
	--[[local szMsg	= string.format("攻击命中敌人时自动对敌释放以下状态：\n<color=green>悲酥清风<color>\n攻击命中值比例：<color=Gold>减少%d%%<color>\n闪避值：<color=Gold>减少%d点<color>\n受到受伤的时间：<color=gold>增加%s<color>\n最多同时影响目标：<color=gold>%d个<color>\n持续时间<color=gold>%s秒<color>",
		-tbChildInfo.tbWholeMagic["attackratingenhance_p"][1],
		-tbChildInfo.tbWholeMagic["adddefense_v"][1],
		-tbChildInfo.tbWholeMagic["state_hurt_resisttime"][1],
		tbChildInfo.tbWholeMagic["missile_hitcount"][1],
		FightSkill:Frame2Sec(tbChildInfo.nStateTime));]]
	local tbMsg = {};	
	local szMsg = "";
	szMsg = szMsg.."攻击命中敌人时自动对敌释放以下诅咒：\n";
	szMsg = szMsg.."    <color=green>悲酥清风<color>\n";
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0);
	for i=1, #tbMsg do
		szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	return szMsg;
end;

local tbSkill	= FightSkill:GetClass("moyinshipo_child");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local szMsg	= string.format("重伤时触发几率：<color=gold>%d%%<color>\n最多同时影响目标：<color=gold>%d个<color>\n造成周围对手混乱的几率：<color=gold>%d%%<color>，持续<color=gold>%s秒<color>\n造成周围对手灼伤的几率：<color=gold>%d%%<color>，持续<color=gold>%s秒<color>\n触发间隔时间：<color=Gold>%s秒<color>",
		tbAutoInfo.nPercent,
		tbChildInfo.nMissileHitcount,
		tbChildInfo.tbWholeMagic["state_confuse_attack"][1],
		FightSkill:Frame2Sec(tbChildInfo.tbWholeMagic["state_confuse_attack"][2]),
		tbChildInfo.tbWholeMagic["state_burn_attack"][1],
		FightSkill:Frame2Sec(tbChildInfo.tbWholeMagic["state_burn_attack"][2]),
		FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime));
	return szMsg;
end;

local tbSkill	= FightSkill:GetClass("shufuzhou");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbCCInfo	= KFightSkill.GetSkillInfo(tbChildInfo.tbEvent.nStartSkillId, tbChildInfo.tbEvent.nLevel);
	local szMsg	= string.format("\n<color=green>子招式<color>\n被攻击命中时触发几率：<color=gold>%d%%<color>\n最多同时影响目标：<color=gold>%d个<color>\n造成攻击者麻痹的几率：<color=gold>%d%%<color>，持续<color=gold>%s秒<color>\n自身移动速度：<color=gold>增加%s%%<color>，持续<color=gold>%s秒<color>\n触发间隔时间：<color=Gold>%s秒<color>",
		tbAutoInfo.nPercent,
		tbChildInfo.nMissileHitcount,
		tbChildInfo.tbWholeMagic["state_palsy_attack"][1],
		FightSkill:Frame2Sec(tbChildInfo.tbWholeMagic["state_palsy_attack"][2]),
		tbCCInfo.tbWholeMagic["fastwalkrun_p"][1],
		FightSkill:Frame2Sec(tbCCInfo.nStateTime),
		FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime));
	return szMsg;
end;

local tbSkill	= FightSkill:GetClass("morenadvancedbook");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbAutoInfo2	= KFightSkill.GetAutoInfo(tbChildInfo.tbWholeMagic["autoskill"][1], tbChildInfo.tbWholeMagic["autoskill"][2]);
	local tbChildInfo2	= KFightSkill.GetSkillInfo(tbAutoInfo2.nSkillId, tbAutoInfo2.nSkillLevel);
	local szMsg	= string.format("攻击时对敌人附加以下状态：\n    <color=green>作茧自缚<color>\n    下<color=gold>%d次<color>攻击命中时会使自身：\n    <color=gold>%d%%的几率受伤%s秒\n    %d%%的几率虚弱%s秒\n    %d%%的几率迟缓%s秒\n    %d%%的几率灼伤%s秒\n    %d%%的几率眩晕%s秒<color>\n    Thời gian duy trì: <color=gold>%s秒<color>\n触发间隔时间：<color=gold>%s秒<color>",
		tbAutoInfo2.nCastCount,
		tbChildInfo2.tbWholeMagic["state_hurt_attack"][1],
		FightSkill:Frame2Sec(tbChildInfo2.tbWholeMagic["state_hurt_attack"][2]),
		tbChildInfo2.tbWholeMagic["state_weak_attack"][1],
		FightSkill:Frame2Sec(tbChildInfo2.tbWholeMagic["state_weak_attack"][2]),
		tbChildInfo2.tbWholeMagic["state_slowall_attack"][1],
		FightSkill:Frame2Sec(tbChildInfo2.tbWholeMagic["state_slowall_attack"][2]),
		tbChildInfo2.tbWholeMagic["state_burn_attack"][1],
		FightSkill:Frame2Sec(tbChildInfo2.tbWholeMagic["state_burn_attack"][2]),
		tbChildInfo2.tbWholeMagic["state_stun_attack"][1],
		FightSkill:Frame2Sec(tbChildInfo2.tbWholeMagic["state_stun_attack"][2]),
		FightSkill:Frame2Sec(tbChildInfo.nStateTime),
		FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime)
		);
	return szMsg;
end;

local tbSkill	= FightSkill:GetClass("morenadvancedbook_child");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local szMsg	= string.format("下<color=gold>%d次<color>攻击命中时会使自身进入异常状态：\n<color=gold>%d%%的几率受伤%s秒\n%d%%的几率虚弱%s秒\n%d%%的几率迟缓%s秒\n%d%%的几率灼伤%s秒\n%d%%的几率眩晕%s秒<color>",
		tbAutoInfo.nCastCount,
		tbChildInfo.tbWholeMagic["state_hurt_attack"][1],
		FightSkill:Frame2Sec(tbChildInfo.tbWholeMagic["state_hurt_attack"][2]),
		tbChildInfo.tbWholeMagic["state_weak_attack"][1],
		FightSkill:Frame2Sec(tbChildInfo.tbWholeMagic["state_weak_attack"][2]),
		tbChildInfo.tbWholeMagic["state_slowall_attack"][1],
		FightSkill:Frame2Sec(tbChildInfo.tbWholeMagic["state_slowall_attack"][2]),
		tbChildInfo.tbWholeMagic["state_burn_attack"][1],
		FightSkill:Frame2Sec(tbChildInfo.tbWholeMagic["state_burn_attack"][2]),
		tbChildInfo.tbWholeMagic["state_stun_attack"][1],
		FightSkill:Frame2Sec(tbChildInfo.tbWholeMagic["state_stun_attack"][2])
		);
	return szMsg;
end;

local tbSkill	= FightSkill:GetClass("zhanrenadvancedbook");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbAutoInfo2	= KFightSkill.GetAutoInfo(tbChildInfo.tbWholeMagic["autoskill"][1], tbChildInfo.tbWholeMagic["autoskill"][2]);
	local tbChildInfo2	= KFightSkill.GetSkillInfo(tbAutoInfo2.nSkillId, tbAutoInfo2.nSkillLevel);

	local tbMagic = tbChildInfo.tbWholeMagic["addenchant"]
	if (not tbMagic) then
		return "";
	end;

	local szClassName = SkillEnchant:GetNameById(tbMagic[1]);
	local tbData = SkillEnchant:GetClass(szClassName);
	if (not tbData) then
		return "";
	end;

	local szDesc = "";
	for _, tb in pairs(tbData.tbEnchantData) do
		for szName, tbMgc in pairs(tb.magic) do
			if (type(tbMgc) == "table") and tb.RelatedSkillId ~= 1178 then
				local tbData = {};
				tbData[1] = tb.RelatedSkillId;
				if (tbMgc.value1) then
					local tbPoint1 = {};
					for _, tbP in pairs(tbMgc.value1[2]) do
						tbPoint1[#tbPoint1 + 1] = {tbP[1], tbP[2]};
					end;
					tbData[2] = {};
					tbData[2].nType = tbMgc.value1[1];
					tbData[2].nPoint = Lib.Calc:Link(tbMagic[2], tbPoint1);
				end;

				if (tbMgc.value2) then
					local tbPoint2 = {};
					for _, tbP in pairs(tbMgc.value2[2]) do
						tbPoint2[#tbPoint2 + 1] = {tbP[1], tbP[2]};
					end;
					tbData[3] = {};
					tbData[3].nType = tbMgc.value2[1];
					tbData[3].nPoint = Lib.Calc:Link(tbMagic[2], tbPoint2);
				end;

				if (tbMgc.value3) then
					local tbPoint3 = {};
					for _, tbP in pairs(tbMgc.value3[2]) do
						tbPoint3[#tbPoint3 + 1] = {tbP[1], tbP[2]};
					end;
					tbData[4] = {};
					tbData[4].nType = tbMgc.value3[1];
					tbData[4].nPoint = Lib.Calc:Link(tbMagic[2], tbPoint3);
				end;
			
				--local szMsg = FightSkill:GetMagicDesc(szName, tbData, nil, nil, true);
				--Lib:ShowTB1(tbData[2]);
				--[[if (szMsg and szMsg ~= "") then
					if (szDesc ~= "") then
						szDesc = szDesc .. "\n";
					end;
					szDesc = szDesc .. szMsg;
				end;]]
				szDesc = string.format("<color=gold>飞鸿无迹<color>的发挥基础攻击力<color=gold>缩小%d%%<color>",-tbData[2]["nPoint"]);
			end;
		end;
	end;
	
	local szMsg	= string.format("<color=gold>幻影追魂枪<color>和<color=gold>魔音噬魄<color>命中时获得以下状态：\n    攻击会心一击值：<color=gold>增加%s<color>\n    %s\n    以<color=gold>%s%%<color>的几率闪避外功系和内功系攻击\n    攻击命中<color=gold>%s次<color>后效果消失\n    Thời gian duy trì: <color=gold>%s秒<color>",
			tbChildInfo.tbWholeMagic["deadlystrikeenhance_r"][1],
			szDesc,
			--180+tbChildInfo.tbWholeMagic["deadlystrikedamageenhance_p"][1],\n    但会心一击只能造成<color=gold>约%s%%<color>的攻击
			tbChildInfo.tbWholeMagic["ignoreskill"][1],
			tbAutoInfo2.nCastCount,
			FightSkill:Frame2Sec(tbChildInfo.nStateTime)
			);
	return szMsg;
end;

local tbSkill	= FightSkill:GetClass("zhanrenadvancedbook_child");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local szMsg	= string.format("攻击命中<color=gold>%s次<color>后效果消失",
		tbAutoInfo.nCastCount
		);
	return szMsg;
end;

local tbSkill	= FightSkill:GetClass("moren120");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbMsg = {};	
	local szMsg = "";
	szMsg = szMsg.."每隔<color=gold>"..FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime).."<color>秒自动释放：\n";
	szMsg = szMsg.."    <color=green>魔刀吞神<color>\n";
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0);
	for i=1, #tbMsg do
		szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	return szMsg;
end

local tbSkill = FightSkill:GetClass("moren120")

function tbSkill:GetExtraDesc(tbInfo)
	if (not tbInfo) then
		return "";
	end

	local szMsg	= string.format("<color=gray>(状态下再次使用可关闭技能)<color>");
	return szMsg;
end