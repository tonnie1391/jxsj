Require("\\script\\fightskill\\fightskill.lua")
local nA0 = FightSkill.tbParam.nSadd;	--攻速类攻击技能+1的成长系数
local nA1 = FightSkill.tbParam.nSadd1;	--格斗类攻击技能+1的成长系数
local nS01 = FightSkill.tbParam.nS1;	--技能1级的数值系数
local nS20 = FightSkill.tbParam.nS20;	--技能20级的数值系数

--大理段氏
local tb	= {
	--指段氏
	shenzhidianxue={ --神指点穴_20
		appenddamage_p= {{{1,90},{20,90},{21,90*nA1}}},
		seriesdamage_r={0},--={{{1,50},{20,100},{21,100}}},
		physicsenhance_p={{{1,5},{10,50},{20,70},{21,70*nA1}}},
		colddamage_v={
			[1]={{1,20*0.9},{10,150*0.9},{20,230*0.9},{21,230*nA1*0.9}},
			[3]={{1,20*1.1},{10,150*1.1},{20,230*1.1},{21,230*nA1*1.1}}
		},
		state_hurt_attack={{{1,15},{20,35},{21,36}},{{1,18},{20,18}}},
		state_slowall_attack={{{1,15},{10,30},{20,35},{21,36}},{{1,18},{20,36},{21,36}}},
		skill_cost_v={{{1,2},{20,20},{21,21}}},
		addskilldamagep={217, {{1,2},{20,30},{21,31}},1},
		addskilldamagep2={218, {{1,2},{20,30},{21,35}}},
		addskilldamagep3={223, {{1,2},{20,10},{21,12}},1},
		addskilldamagep4={224, {{1,2},{20,10},{21,12}}},
	--	attackrating_p={{{1,20},{20,70}}},
	},
	duanshizhifa={ --段氏指法_10
		addphysicsdamage_p={{{1,10},{10,150},{11,165}}},
		attackratingenhance_p={{{1,50},{10,150},{11,165}}},
		deadlystrikeenhance_r={{{1,30},{10,50},{11,55}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	yiyangzhi={ --一阳指_10
		state_fixed_attack={{{1,50},{10,85},{13,95}},{{1,18*3},{10,18*3.5},{13,18*4.5}}},
		skill_cost_v={{{1,20},{10,50},{11,50}}},
		skill_attackradius={600},
		skill_mintimepercast_v={18*10},
		skill_mintimepercastonhorse_v={18*10},
		missile_speed_v={100},
	},
	yizhiqiankun={ --一指乾坤_20
		appenddamage_p= {{{1,50},{20,50},{21,50*nA1}}},
		physicsenhance_p={{{1,50},{10,95},{20,145},{21,145*nA1}}},
		colddamage_v={
			[1]={{1,600*0.95},{10,780*0.95},{20,890*0.95},{21,890*nA1*0.95}},
			[3]={{1,600*1.05},{10,780*1.05},{20,890*1.05},{21,890*nA1*1.05}}
		},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		state_hurt_attack={{{1,15},{10,30},{20,35},{21,36}},{{1,18},{20,18}}},
		state_slowall_attack={{{1,20},{10,30},{20,35},{21,36}},{{1,18},{20,36}}},
		skill_cost_v={{{1,20},{20,50},{21,50}}},
		addskilldamagep={223, {{1,2},{20,30},{21,35}},1},
		addskilldamagep2={224, {{1,2},{20,30},{21,35}}},
	--	attackrating_p={{{1,30},{20,80}}},
	},
	lingboweibu={ --凌波微步_20
		fastwalkrun_p={{{1,40},{20,100},{21,110}}},
		ignoreskill={{{1,35},{10,75},{20,95},{21,96},{22,96},{23,97}},0,{{1,3},{2,3}}},
		state_knock_resistrate={{{1,100},{20,1000},{20,1050}}},
		skill_cost_v={{{1,100},{10,150},{20,300},{21,300}}},
		skill_statetime={{{1,18*5},{20,18*15},{21,18*16}}},
		skill_mintimepercast_v={{{1,20*18},{20,45*18},{21,45*18}}},--ok
		skill_mintimepercastonhorse_v={{{1,20*18},{20,45*18},{21,45*18}}},--ok
		movewithshadow={1},
	},
	cibeijue={ --慈悲诀_10
		autoskill={{{1,17},{2,17}},{{1,1},{10,10}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	shiyuanjue={ --弑元诀_20
		autoskill={{{1,1},{2,1}},{{1,1},{20,20}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	shiyuanjue_child1={ --弑元诀子
		attackratingenhance_p={{{1,-50},{10,-100},{20,-150},{22,-165}}},
		state_stun_attack={{{1,50},{10,60},{20,70},{23,80}},{{1,18*2},{10,18*3},{20,18*3.5},{21,18*3.8}}},
		missile_hitcount={{{1,3},{10,4},{20,5},{21,5}}},
		skill_statetime={{{1,18*10},{20,18*15},{21,18*15}}},
	},
	shiyuanjue_child2={ --弑元诀子子
		state_stun_attack={{{1,50},{10,60},{20,70},{23,80}},{{1,18*2},{10,18*3},{20,18*3.5},{21,18*3.8}}},
		missile_hitcount={{{1,3},{10,4},{20,5},{21,5}}},
	},
	shiyuanjue_child3={ --弑元诀子子子
		redeivedamage_dec_p2={{{1,22},{20,60},{21,63}}},
		--state_hurt_ignore={1},
		--state_slowall_ignore={1},
		state_fixed_ignore={1},
		state_palsy_ignore={1},
		state_confuse_ignore={1},
		state_drag_ignore={1},
		state_knock_ignore={1},
		skill_statetime={18*5},
	},
	qianyangshenzhi={ --乾阳神指_20
		appenddamage_p= {{{1,65*nS01},{10,65},{20,65*nS20},{21,65*nS20*nA1}}},
		physicsenhance_p={{{1,100*nS01},{10,100},{20,100*nS20},{21,100*nS20*nA1}}},
		colddamage_v={
			[1]={{1,550*0.9*nS01},{10,550*0.9},{20,550*0.9*nS20},{21,550*0.9*nS20*nA1}},
			[3]={{1,550*1.1*nS01},{10,550*1.1},{20,550*1.1*nS20},{21,550*1.1*nS20*nA1}}
			},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		skill_cost_v={{{1,45},{20,90},{21,90}}},
		state_hurt_attack={{{1,7},{10,20},{20,25}},{{1,18},{20,18}}},
		state_slowall_attack={{{1,7},{10,20},{20,25}},{{1,18},{20,36},{21,36}}},
		missile_hitcount={{{1,5},{20,5}}},
	},
	jinyuzhifa={ --金玉指法_20
	--	state_hurt_attackrate={{{1,10},{20,100}}},
		state_slowall_attackrate={{{1,10},{20,100}}},
		state_burn_resistrate={{{1,10},{10,100},{20,150}}},
		ignoredefenseenhance_v={{{1,50},{20,180},{21,187}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	qiantianzhifa={ --乾天指法
		skilldamageptrim={{{1,1},{10,10}}},
		skillselfdamagetrim={{{1,1},{10,10}}},
		--state_hurt_attacktime={{{1,10},{20,135}}},
		state_slowall_attacktime={{{1,10},{10,80}}},
		state_burn_resisttime={{{1,10},{10,120}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},

	baibuchuanyang={ --中级秘籍：百步穿杨
		fastwalkrun_p={{{1,10},{10,30},{11,30}}},
		addenchant={17, {{1,1}, {2, 2}}},
		--addmissilespeed={237, 0, {{1,8}, {10, 35}}},
		--addskillcastrange={216, 0, {{1,48}, {10, 200}}},
		--decreaseskillcasttime={216, {{1,18}, {10, 18*3}}},
		decautoskillcdtime={220, 1, {{1,18*6}, {10, 18*15}, {11, 18*16}}},
		skill_skillexp_v=FightSkill.tbParam.tbMidBookSkillExp,
		skill_statetime={{{1,-1},{2,-1}}},
	},
	
	miaodizhi={ --妙谛指_10
		addstartskill={216, 1184, {{1,1}, {10, 10}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	miaodizhiqi={ --妙谛指气
		deadlystrikeenhance_r={{{1,150},{10,275},{11,289}}},
		skilldamageptrim={{{1,3},{10,30}}},
		skillselfdamagetrim={{{1,3},{10,30}}},
		skill_statetime={{{1,18*5},{10,18*5}}},
	},
	zhiduanadvancedbook={ --指段高级秘籍
		appenddamage_p= {{{1,65*0.7},{10,65}}},
		physicsenhance_p={{{1,100*0.7},{10,100}}},
		colddamage_v={
			[1]={{1,550*0.9*0.7},{10,550*0.9}},
			[3]={{1,550*1.1*0.7},{10,550*1.1}}
			},
		seriesdamage_r={0},--={{{1,250},{10,250}}},
		skill_cost_v={{{1,200},{10,200}}},
		--state_hurt_attack={{{1,7},{10,25}},{{1,18},{10,18}}},
		state_slowall_attack={{{1,5},{10,50}},{{1,45},{10,45}}},
		missile_hitcount={{{1,3},{10,3}}},
		skill_mintimepercast_v={{{1,45*18},{10,45*18}}},
		skill_mintimepercastonhorse_v={{{1,45*18},{10,45*18}}},
		skill_skillexp_v=FightSkill.tbParam.tbHighBookSkillExp,
	},
	zhiduan120={ --指段120_10
		changecdtype={{{1,1263},{10,1263}},{{1,200},{10,200}},{{1,100},{10,100}}},
		autoskill={{{1,66},{2,66}},{{1,1},{10,10}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	zhiduan120_child={ --指段120_子_10
		recover_usepoint={{{1,1263},{10,1263}},{{1,3},{10,34},{11,34}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},

	--气段氏
	fengyunbianhuan={ --风云变幻_20
		appenddamage_p= {{{1,100},{10,118},{20,128},{21,128*nA0}}},
		colddamage_v={
			[1]={{1,30*0.9},{10,345*0.9},{20,545*0.9},{21,545*nA0*0.9}},
			[3]={{1,30*1.1},{10,345*1.1},{20,545*1.1},{21,545*nA0*1.1}}
		},
		state_slowall_attack={{{1,15},{10,45},{20,50},{21,51}},{{1,45},{20,45}}},
		seriesdamage_r={0},--={{{1,50},{20,100},{21,100}}},
		skill_cost_v={{{1,10},{20,50},{21,50}}},
		addskilldamagep={229, {{1,2},{20,30},{21,35}},1},
		addskilldamagep2={232, {{1,2},{20,10},{21,12}},1},
		addskilldamagep3={869, {{1,2},{20,10},{21,12}}},
		addskilldamagep4={870, {{1,2},{20,10},{21,12}}},
		addskilldamagep5={871, {{1,2},{20,10},{21,12}}},
		addskilldamagep6={872, {{1,2},{20,10},{21,12}}},
		missile_range={1,0,1},
		missile_hitcount={{{1,4},{2,4}}},
	},
	duanshixinfa={ --段氏心法_10
		addcoldmagic_v={{{1,20},{10,400},{11,440}}},
		deadlystrikeenhance_r={{{1,30},{10,50},{11,55}}},
		castspeed_v={{{1,5},{10,15},{11,16},{12,17},{13,17}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	beimingshengong={ --北冥神功_10
		--dynamicmagicshield_v={{{1,50},{10,180},{11,189}},30},
		dynamicmagicshieldbymaxhp_p={{{1,12},{10,30},{11,32}},30},
		state_palsy_resistrate={{{1,100},{10,1000},{11,1050}}},
		state_confuse_resistrate={{{1,100},{10,1000},{11,1050}}},
		state_knock_resistrate={{{1,100},{10,1000},{11,1050}}},
		state_drag_resistrate={{{1,100},{10,1000},{11,1050}}},
		--skill_cost_v={{{1,2},{20,25}}},
	},
	beimingshengong_team={ --北冥神功_队友
		--dynamicmagicshield_v={{{1,30},{10,90},{12,99}},30},
		dynamicmagicshieldbymaxhp_p={{{1,6},{10,15},{11,16}},30},
	},
	jinyumantang={ --金玉满堂_20
		appenddamage_p= {{{1,50},{10,60},{20,65},{21,65*nA0}}},
		colddamage_v={
			[1]={{1,500*0.9},{10,680*0.9},{20,780*0.9},{21,780*nA0*0.9}},
			[3]={{1,500*1.1},{10,680*1.1},{20,780*1.1},{21,780*nA0*1.1}}
		},
		state_slowall_attack={{{1,15},{10,45},{20,50},{21,51}},{{1,45},{20,45}}},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		skill_cost_v={{{1,50},{20,150},{21,150}}},
		addskilldamagep={232, {{1,2},{20,30},{21,35}},1},
		addskilldamagep2={868, {{1,2},{20,30},{21,35}}},
		addskilldamagep3={869, {{1,2},{20,30},{21,35}}},
		addskilldamagep4={870, {{1,2},{20,30},{21,35}}},
		addskilldamagep5={871, {{1,2},{20,30},{21,35}}},
		addskilldamagep6={872, {{1,2},{20,30},{21,35}}},
		missile_hitcount={{{1,4},{2,4}}},
		skill_missilenum_v={{{1,2},{10,3},{15,4},{20,5},{21,5}},1},
		missile_speed_v={40},
	},
	tiannanbufa={ --天南步法_20
		fastwalkrun_p={{{1,10},{20,40},{21,41}}},
		state_burn_resisttime={{{1,10},{20,135},{21,141}}},
		skill_cost_v={{{1,100},{10,250},{20,300},{21,300}}},
		skill_statetime={300*18},
	},
	liujianqifa={ --六剑齐发
		autoskill={{{1,18},{2,18}},{{1,1},{10,10}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	liujianqifa_child={ --六剑齐发_10
		appenddamage_p= {{{1,50},{10,65},{21,65}}},
		colddamage_v={
			[1]={{1,600*0.9},{10,816*0.9},{11,856*0.9}},
			[3]={{1,600*1.1},{10,816*1.1},{11,856*1.1}}
		},
		steallife_p={{{1,100},{10,100}},{{1,100},{10,100}}},
		seriesdamage_r={0},--={{{1,100},{10,250},{11,250}}},
	},
	kurongchangong={ --枯荣禅功	_20
		addcoldmagic_v={{{1,100},{20,600},{21,660}}},
		castspeed_v={{{1,11},{20,30},{21,30}}},
		autoskill={{{1,8},{2,8}},{{1,1},{20,20}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	kurongchangong_child={ --枯荣禅功子
		addcoldmagic_v={{{1,-50},{20,-300},{21,-330}}},
		castspeed_v={{{1,-1},{20,-20},{21,-20}}},
		--fastlifereplenish_v={{{1,50},{20,400},{21,420}}},
		replenishlifebymaxhp_p={{{1,55},{20,150},{21,155}}},--这种属性+1还是不要提升5%了...
		redeivedamage_dec_p2={{{1,21},{20,40},{21,42}}},
		skill_statetime={{{1,18*10},{20,18*10},{21,18*10}}},
	},
	liumaishenjian={ --六脉神剑主_伤
		appenddamage_p= {{{1,30*nS01},{10,30},{20,30*nS20},{21,30*nS20*nA0}}},
		colddamage_v={
			[1]={{1,475*0.9*nS01},{10,475*0.9},{20,475*0.9*nS20},{21,475*0.9*nS20*nA0}},
			[3]={{1,475*1.1*nS01},{10,475*1.1},{20,475*1.1*nS20},{21,475*1.1*nS20*nA0}}
			},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		skill_cost_v={{{1,100},{20,200},{21,200}}},
		state_hurt_attack={{{1,5},{10,10},{20,15}},{{1,18},{20,18}}},
		missile_hitcount={{{1,4},{2,4}}},
		missile_range={3,0,3},
	},
	liumaishenjian_child={ --六脉神剑_减攻速_作废
		castspeed_v={{{1,-90},{2,-90}}},
		skill_statetime={{{1,18*2},{2,18*2}}},
	},
	liumaishenjian_child1={ --六脉神剑子1_灼
		state_burn_attack={{{1,5},{20,10}},{{1,36},{20,54},{21,54}}},
		missile_hitcount={{{1,4},{2,4}}},
	},
	liumaishenjian_child2={ --六脉神剑子2_缓
		appenddamage_p= {{{1,30*nS01},{10,30},{20,30*nS20},{21,30*nS20*nA0}}},
		colddamage_v={
			[1]={{1,475*0.9*nS01},{10,475*0.9},{20,475*0.9*nS20},{21,475*0.9*nS20*nA0}},
			[3]={{1,475*1.1*nS01},{10,475*1.1},{20,475*1.1*nS20},{21,475*1.1*nS20*nA0}}
			},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		state_slowall_attack={{{1,15},{10,45},{20,50}},{{1,45},{20,45}}},
		missile_hitcount={{{1,4},{2,4}}},
		missile_range={3,0,3},
	},
	liumaishenjian_child3={ --六脉神剑子3_弱
		state_weak_attack={{{1,5},{20,10}},{{1,36},{20,54},{21,54}}},
		missile_hitcount={{{1,4},{2,4}}},
	},
	liumaishenjian_child4={ --六脉神剑子4_晕
		state_stun_attack={{{1,5},{20,10}},{{1,18},{20,18}}},
		missile_hitcount={{{1,4},{2,4}}},
	},
	liumaishenjian_child5={ --六脉神剑子5_攻击
		appenddamage_p= {{{1,40*nS01},{10,40},{20,40*nS20},{21,40*nS20*nA0}}},
		colddamage_v={
			[1]={{1,610*0.9*nS01},{10,610*0.9},{20,610*0.9*nS20},{21,610*0.9*nS20*nA0}},
			[3]={{1,610*1.1*nS01},{10,610*1.1},{20,610*1.1*nS20},{21,610*1.1*nS20*nA0}}
			},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		missile_hitcount={{{1,4},{2,4}}},
		missile_range={3,0,3},
	},
	tianlongshengong={ --天龙神功_20
		state_slowall_attackrate={{{1,10},{20,100}}},
		state_burn_resistrate={{{1,10},{10,100},{20,150}}},
		castspeed_v={{{1,10},{10,16},{20,26},{23,29},{24,29}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	duanjiaqijian={ --段家气剑
		skilldamageptrim={{{1,1},{10,10}}},
		skillselfdamagetrim={{{1,1},{10,10}}},
		state_slowall_attacktime={{{1,10},{10,80}}},
		state_burn_resisttime={{{1,10},{10,120}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	
	baihongguanri={ --中级秘籍：白虹贯日
		--addmissilespeed={229, 0, {{1,6}, {10, 15}}},
		--addmissilerange={226, {{1,1}, {10, 1}}},
		addenchant={18, {{1,1}, {2, 2}}},
		--addmissilethroughrate={229, {{1,14}, {10, 100}},2},
		addpowerwhencol={229, {{1,50}, {10, 50}, {12, 55}}, {{1,50}, {10, 150}, {12, 165}}},
		skill_skillexp_v=FightSkill.tbParam.tbMidBookSkillExp,
		skill_statetime={{{1,-1},{2,-1}}},
		--{szMagicName = "addmissilespeed", tbValue = {229, 0, {{1,6}, {10, 15}}}},
		--{szMagicName = "addmissilerange", tbValue = {226, {{1,1}, {10, 1}}}},
		--{szMagicName = "addmissilethroughrate", tbValue = {226, {{1,14}, {10, 100}}}},
		--{szMagicName = "addmissilethroughrate", tbValue = {229, {{1,14}, {10, 100}},2}},
		--{szMagicName = "addpowerwhencol", tbValue = {229, {{1,50}, {10, 50}}, {{1,50}, {10, 150}}}},
		--{szMagicName = "skill_skillexp_v", tbValue = FightSkill.tbParam.tbMidBookSkillExp},
		--{szMagicName = "skill_statetime", tbValue = {{{1,-1},{2,-1}}}},
	},
	
	jingtianyijian={ --惊天一剑_10
		state_knock_attack={{{1,65},{10,100},{11,100}},{{1,2},{10,2},{11,2}},{{1,32},{2,32}}},
		state_slowall_attack={{{1,65},{10,100},{11,100}},{{1,36},{10,72},{11,72}}},
		skill_mintimepercast_v={{{1,30*18},{10,30*18},{11,29*18}}},
		skill_mintimepercastonhorse_v={{{1,30*18},{10,30*18},{11,29*18}}},
	},
	qiduanadvancedbook={ --气段高级秘籍_炼气还神_10
		lifemax_p={{{1,6},{10,60},{11,63}}},
		fastwalkrun_p={{{1,1},{10,10},{11,10}}},
		adddefense_v={{{1,20},{10,200},{11,210}}},
		autoskill={{{1,49},{2,49}},{{1,1},{10,10}}},
		skill_statetime={{{1,-1},{2,-1}}},
		skill_skillexp_v=FightSkill.tbParam.tbHighBookSkillExp,
	},
	qiduanadvancedbook_child2={ --气段高级秘籍_炼气还神_子2_10
		state_slowall_attacktime={{{1,10},{10,100},{11,105}}},
		deadlystrikeenhance_r={{{1,10},{10,100},{11,105}}},
		superposemagic={{{1,1},{10,5},{11,5}}},
		skill_statetime={{{1,22*18},{2,22*18}}},
	},
	qiduan120={ --气段120_9_注意,最高等级9级
		skill_cost_v={{{1,300},{9,300}}},
		missile_hitcount={{{1,1},{9,3},{10,3}}},
		skill_mintimepercast_v={{{1,999*18},{9,999*18}}},
		skill_mintimepercastonhorse_v={{{1,999*18},{9,999*18}}},
	},
	qiduan120_hitskill={ --气段120_9_注意,最高等级9级
		appenddamage_p= {{{1,2.2*30*0.7},{9,2.2*30},{10,2.2*30*nA0}}},
		colddamage_v={
			[1]={{1,2.2*475*0.9*0.7},{9,2.2*475*0.9},{10,2.2*475*0.9*nA0}},
			[3]={{1,2.2*475*1.1*0.7},{9,2.2*475*1.1},{10,2.2*475*1.1*nA0}}
			},
		seriesdamage_r={0},--={{{1,250},{9,250}}},
		state_slowall_attack={{{1,45},{9,50}},{{1,45},{9,45}}},
		missile_hitcount={{{1,4},{2,4}}},
		skill_appendskill={{{1,226},{9,226}},{{1,1},{9,20},{10,21}}},
		skill_appendskill2={{{1,232},{9,232}},{{1,1},{9,20},{10,21}}},
	},
	qiduan120_child = {
		magic_duck_skill={1663},
		skill_statetime={{{1,1.5*18},{2,1.5*18}}},
	},
	qiduan120_2={ --气段120_附属技能_1
		changecdtype={{{1,866},{10,866}},{{1,1300},{10,1300}},{{1,100},{10,100}}},
		autoskill={{{1,67},{2,67}},{{1,1},{10,10}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	qiduan120_2_child={ --气段120_附属技能_触发回复使用次数_10
		recover_usepoint={{{1,866},{10,866}},{{1,100},{10,100}}},
	},
}

FightSkill:AddMagicData(tb)

local tbSkill	= FightSkill:GetClass("shiyuanjue");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbMsg = {};
	local szMsg = ""
	local nPerCastTime = (tbAutoInfo.nPerCastTime - KFightSkill.GetAutoSkillCDTimeAddition(tbSkillInfo.nId, tbAutoInfo.nId));
	szMsg = szMsg.."被限制技能命中时触发几率：<color=gold>"..tbAutoInfo.nPercent.."%<color>\n";
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0);
	for i=1, #tbMsg do
		szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	szMsg = szMsg.."\n触发间隔：<color=Gold>"..FightSkill:Frame2Sec(nPerCastTime).."秒<color>";
	return szMsg;
end;
--[[
function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbCCInfo	= KFightSkill.GetSkillInfo(tbChildInfo.tbEvent.nStartSkillId, tbChildInfo.tbEvent.nLevel);
	local tbCCInfo2	= KFightSkill.GetSkillInfo(tbCCInfo.tbEvent.nStartSkillId, tbCCInfo.tbEvent.nLevel);
	local nPerCastTime = (tbAutoInfo.nPerCastTime - KFightSkill.GetAutoSkillCDTimeAddition(tbSkillInfo.nId, tbAutoInfo.nId));
	local szMsg	= string.format("被限制技能命中时触发几率：<color=gold>%d%%<color>\n最多同时影响目标：<color=gold>%d个<color>\n造成周围对手命中值：<color=gold>降低%d%%<color>，持续<color=Gold>%s秒<color>\n造成周围对手眩晕的几率：<color=gold>%d%%<color>，持续<color=gold>%s秒<color>\n自身免疫受伤、迟缓、定身、混乱、麻痹状态，持续<color=gold>%s秒<color>\n触发间隔时间：<color=Gold>%s秒<color>",
		tbAutoInfo.nPercent,
		tbChildInfo.nMissileHitcount,
		-tbChildInfo.tbWholeMagic["attackratingenhance_p"][1],
		FightSkill:Frame2Sec(tbChildInfo.nStateTime),
		tbCCInfo.tbWholeMagic["state_stun_attack"][1],
		FightSkill:Frame2Sec(tbCCInfo.tbWholeMagic["state_stun_attack"][2]),
		FightSkill:Frame2Sec(tbCCInfo2.nStateTime),
		FightSkill:Frame2Sec(nPerCastTime));
	return szMsg;
end;]]


local tbSkill	= FightSkill:GetClass("kurongchangong");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbMsg = {};
	local szMsg = ""
	szMsg = szMsg.."\n生命降到25%时自动触发：\n";
	szMsg = szMsg.."    <color=green>枯禅<color>\n";
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0);
	for i=1, #tbMsg do
		szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	szMsg = szMsg.."\n触发间隔：<color=Gold>"..FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime).."秒<color>";
	return szMsg;
end;

local tbSkill	= FightSkill:GetClass("cibeijue");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbMsg = {};
	local szMsg = ""
	szMsg = szMsg.."生命降到25%时<color=gold>"..tbAutoInfo.nPercent.."%<color>几率自动触发：\n";
	szMsg = szMsg.."    <color=green>凌波微步<color>\n";
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0);
	for i=1, #tbMsg do
		szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	szMsg = szMsg.."\n触发间隔：<color=Gold>"..FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime).."秒<color>";
	return szMsg;
end;

local tbSkill	= FightSkill:GetClass("liujianqifa");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbMsg = {};
	local szMsg = ""
	szMsg = szMsg.."生命降到25%时<color=gold>"..tbAutoInfo.nPercent.."%<color>几率自动触发：\n";
	szMsg = szMsg.."    <color=green>六剑齐发<color>\n";
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0);
	for i=1, #tbMsg do
		szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	szMsg = szMsg.."\n触发间隔：<color=Gold>"..FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime).."秒<color>";
	return szMsg;
end;

local tbSkill = FightSkill:GetClass("liumaishenjian")

function tbSkill:GetExtraDesc(tbInfo)
	if (not tbInfo) then
		return "";
	end
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbInfo.nId, tbInfo.nLevel,me,1);
	--print("~~~~~~~~~~~~~~~~~~")
	--Lib:ShowTB(tbChildInfo)
	--print("--------------------")
	local tbCCInfo1		= KFightSkill.GetSkillInfo(tbChildInfo.tbEvent.nStartSkillId, tbChildInfo.tbEvent.nLevel, me, 1)
	local tbCCInfo2		= KFightSkill.GetSkillInfo(tbCCInfo1.tbEvent.nStartSkillId, tbCCInfo1.tbEvent.nLevel, me, 1)
	local tbCCInfo3		= KFightSkill.GetSkillInfo(tbCCInfo2.tbEvent.nStartSkillId, tbCCInfo2.tbEvent.nLevel, me, 1);
	local tbCCInfo4		= KFightSkill.GetSkillInfo(tbCCInfo3.tbEvent.nStartSkillId, tbCCInfo3.tbEvent.nLevel, me, 1);
	local tbCCInfo5		= KFightSkill.GetSkillInfo(tbCCInfo4.tbEvent.nStartSkillId, tbChildInfo.tbEvent.nLevel);
	
	local szMsg	= string.format("<color=green>中冲剑<color>\n冰攻攻击：<color=gold>%s到%s点<color>\n造成迟缓的几率：<color=gold>%d%%<color>，持续<color=gold>%s秒<color>\n发挥基础攻击力：<color=gold>%s%%<color>\n<color=green>少泽剑<color>\n冰攻攻击：<color=gold>%s到%s点<color>\n发挥基础攻击力：<color=gold>%s%%<color>\n<color=green>商阳剑<color>\n造成灼伤的几率：<color=gold>%d%%<color>，持续<color=gold>%s秒<color>\n<color=green>关冲剑<color>\n造成虚弱的几率：<color=gold>%d%%<color>，持续<color=gold>%s秒<color>\n<color=green>少冲剑<color>\n造成眩晕的几率：<color=gold>%d%%<color>，持续<color=gold>%s秒<color>",
		
	tbCCInfo2.tbWholeMagic["colddamage_v"][1],
	tbCCInfo2.tbWholeMagic["colddamage_v"][3],
	tbCCInfo2.tbWholeMagic["state_slowall_attack"][1],
	FightSkill:Frame2Sec(tbCCInfo2.tbWholeMagic["state_slowall_attack"][2]),
	tbCCInfo2.nAppenDamageP,

	tbCCInfo5.tbWholeMagic["colddamage_v"][1],
	tbCCInfo5.tbWholeMagic["colddamage_v"][3],
	tbCCInfo5.nAppenDamageP,
		
	tbCCInfo1.tbWholeMagic["state_burn_attack"][1],
	FightSkill:Frame2Sec(tbCCInfo1.tbWholeMagic["state_burn_attack"][2]),
	
	tbCCInfo3.tbWholeMagic["state_weak_attack"][1],
	FightSkill:Frame2Sec(tbCCInfo3.tbWholeMagic["state_weak_attack"][2]),
		
	tbCCInfo4.tbWholeMagic["state_stun_attack"][1],
	FightSkill:Frame2Sec(tbCCInfo4.tbWholeMagic["state_stun_attack"][2]));
	return szMsg;
end

local tbSkill	= FightSkill:GetClass("qiduanadvancedbook");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbChildInfo2		= KFightSkill.GetSkillInfo(tbChildInfo.tbEvent.nVanishedSkillId, tbChildInfo.tbEvent.nLevel, me, 1)
	local szMsg	= string.format("每隔<color=gold>%d秒<color>在自身当前位置产生气场汲取真气，<color=gold>5秒<color>后凝聚成一个持续<color=gold>5秒<color>的<color=gold>气源<color>，若自身接触到<color=gold>气源<color>，则可获得<color=gold>炼神还虚<color>状态：\n    造成迟缓的时间：<color=gold>增加%d<color>\n    攻击会心一击值：<color=gold>增加%d<color>\n    最多叠加：<color=gold>%s次<color>\n    Thời gian duy trì: <color=gold>%s秒<color>",
		FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime),
		tbChildInfo2.tbWholeMagic["state_slowall_attacktime"][1],
		tbChildInfo2.tbWholeMagic["deadlystrikeenhance_r"][1],
		tbChildInfo2.tbWholeMagic["superposemagic"][1],
		FightSkill:Frame2Sec(tbChildInfo2.nStateTime)
		);
	return szMsg;
end;
local tbSkill	= FightSkill:GetClass("zhiduan120");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbMsg = {};
	local szMsg = ""
	szMsg = szMsg.."<color=green>[一阳指]<color>命中时使<color=green>[玄冰九劫]<color>可用次数回复<color=gold>"..(tbChildInfo.tbWholeMagic["recover_usepoint"][2]/100).."<color>"
	return szMsg;
end;

local tbSkill = FightSkill:GetClass("qiduan120")

function tbSkill:GetExtraDesc(tbInfo)
	if (not tbInfo) then
		return "";
	end
	local tbChildInfo	= KFightSkill.GetSkillInfo(1710, tbInfo.nLevel);
	local szMsg = ""	
	local tbMsg = {};
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0);
	--szMsg = szMsg.."\n"
	szMsg = szMsg.."对击中的每个目标释放：<color=gold>苔枝缀玉<color>\n"--..tbInfo.nLevel.."级<color>\n";
	for i=1, #tbMsg do
		szMsg = szMsg..""..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	return szMsg;
end

local tbSkill	= FightSkill:GetClass("qiduan120_2");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbMsg = {};
	local szMsg = ""
	szMsg = szMsg.."攻击命中时<color=gold>"..tbAutoInfo.nPercent.."%<color>使<color=green>[疏影]<color>可用次数回复<color=gold>1<color>"
	return szMsg;
end;
