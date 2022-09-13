Require("\\script\\fightskill\\fightskill.lua")
local nA0 = FightSkill.tbParam.nSadd;	--攻速类攻击技能+1的成长系数
local nA1 = FightSkill.tbParam.nSadd1;	--格斗类攻击技能+1的成长系数
local nS01 = FightSkill.tbParam.nS1;	--技能1级的数值系数
local nS20 = FightSkill.tbParam.nS20;	--技能20级的数值系数

--古墓派
local tb	= {
	--玉女剑法
	--[[
	----------------闪系技能-----------------
	sxgm_atk_10a={ --剑古墓1闪_初_10
		appenddamage_p= {{{1,100*0.6},{10,110*0.6},{11,110*0.6*nA0}}},
		state_stun_attack={{{1,21},{10,30},{11,31}},{{1,18},{10,18}}},
		seriesdamage_r={0},--={{{1,55},{10,100},{11,100}}},
		skill_cost_v={{{1,20},{10,20}}},
		skill_cost_buff1layers_v={2817,1,1},--扣除2闪
		skill_startevent={1978},--同时释放对npc的伤害部分
		skill_eventskilllevel={{{1,1},{10,10}}},
	},
	sxgm_atk_10a_child={ --剑古墓1闪_初_10
		appenddamage_p= {{{1,100*0.6},{10,110*0.6},{11,110*0.6*nA0}}},
		seriesdamage_r={0},--={{{1,55},{10,100},{11,100}}},
		skill_startevent={2818},--获得杀
		skill_eventskilllevel={1},
	},
	
	sxgm_atk_50a={ --剑古墓1闪_中_10
		appenddamage_p= {{{1,116*0.6},{10,126*0.6},{11,126*0.6*nA0}}},
		state_stun_attack={{{1,31},{10,40},{11,41}},{{1,18},{10,18}}},
		seriesdamage_r={0},--={{{1,130},{10,250},{11,250}}},
		skill_cost_v={{{1,50},{10,50}}},
		missile_hitcount={{{1,3},{10,3},{11,3}}},
		skill_cost_buff1layers_v={2817,1,1},--扣除2闪
		skill_startevent={1979},--同时释放对npc的伤害部分
		skill_eventskilllevel={{{1,1},{10,10}}},
	},
	sxgm_atk_50a_child={ --剑古墓1闪_中_10
		appenddamage_p= {{{1,116*0.6},{10,126*0.6},{11,126*0.6*nA0}}},
		seriesdamage_r={0},--={{{1,130},{10,250},{11,250}}},
		missile_hitcount={{{1,3},{10,3},{11,3}}},
		skill_startevent={2818},--获得杀
		skill_eventskilllevel={1},
	},
	
	sxgm_atk_90a={ --剑古墓1闪_高_10
		appenddamage_p= {{{1,130*0.6},{10,140*0.6},{11,140*0.6*nA0}}},
		state_stun_attack={{{1,41},{10,50},{11,51}},{{1,18},{10,18}}},
		seriesdamage_r={0},--={{{1,275},{10,500},{11,500}}},
		skill_cost_v={{{1,100},{10,100}}},
		missile_hitcount={{{1,5},{10,5},{11,5}}},
		skill_cost_buff1layers_v={2817,1,1},--扣除2闪
		skill_startevent={1980},--同时释放对npc的伤害部分
		skill_eventskilllevel={{{1,1},{10,10}}},
	},
	sxgm_atk_90a_child={ --剑古墓1闪_高_10
		appenddamage_p= {{{1,130*0.6},{10,140*0.6},{11,140*0.6*nA0}}},
		seriesdamage_r={0},--={{{1,275},{10,500},{11,500}}},
		missile_hitcount={{{1,5},{10,5},{11,5}}},
		skill_startevent={2818},--获得杀
		skill_eventskilllevel={1},
	},
	]]
	----------------杀系技能-----------------
	sxgm_atk10={ --剑古墓1杀_初级_20
		--appenddamage_p= {{{1,51},{20,60},{21,60*nA0}}},
		--appenddamage_p= {{{1,45*nS01},{20,45},{21,45*nA0}}},
		floatdamage_p = {
			[1] = {{1,0.8*450*nS01},{20,0.8*450},{21,0.8*450*nA0}},
			[2] = {{1,1.2*450*nS01},{20,1.2*450},{21,1.2*450*nA0}},
		},
		lightingdamage_v={
			[1]={{1,1.75*430*0.8*nS01},{20,1.75*430*0.8},{21,1.75*430*0.8*nA0}},
			[3]={{1,1.75*430*1.2*nS01},{20,1.75*430*1.2},{21,1.75*430*1.2*nA0}}
			},
		state_stun_attack={{{1,16},{20,20},{21,21}},{{1,18},{10,18}}},
		seriesdamage_r={0},--={{{1,55},{20,100},{21,100}}},
		skill_cost_v={20},
		--missile_hitcount={1},
		skill_cost_buff1layers_v={2818,1,1},--消耗1杀
		skill_startevent={2817},--获得闪
		skill_eventskilllevel={1},
	},
	sxgm_atk50={ --剑古墓1杀_中_20
		--appenddamage_p= {{{1,53*nS01},{20,53},{21,53*nA0}}},
		floatdamage_p = {
			[1] = {{1,0.8*530*nS01},{20,0.8*530},{21,0.8*530*nA0}},
			[2] = {{1,1.2*530*nS01},{20,1.2*530},{21,1.2*530*nA0}},
		},
		lightingdamage_v={
			[1]={{1,1.5*705*0.8*nS01},{20,1.5*705*0.8},{21,1.5*705*0.8*nA0}},
			[3]={{1,1.5*705*1.2*nS01},{20,1.5*705*1.2},{21,1.5*705*1.2*nA0}}
			},
		state_stun_attack={{{1,20},{20,25},{21,26}},{{1,18},{20,18}}},
		seriesdamage_r={0},--={{{1,130},{20,250},{21,250}}},
		skill_cost_v={50},
		missile_hitcount={6},
		skill_cost_buff1layers_v={2818,1,1},--消耗1杀
		skill_startevent={2817},--获得闪
		skill_eventskilllevel={1},
	},
	sxgm_atk90={ --剑古墓1杀_高_20
		--appenddamage_p= {{{1,60*nS01},{20,60},{21,60*nA0}}},
		floatdamage_p = {
			[1] = {{1,0.8*600*nS01},{20,0.8*600},{21,0.8*600*nA0}},
			[2] = {{1,1.2*600*nS01},{20,1.2*600},{21,1.2*600*nA0}},
		},
		lightingdamage_v={
			[1]={{1,1850*0.8*nS01},{20,1850*0.8},{21,1850*0.8*nA0}},
			[3]={{1,1850*1.2*nS01},{20,1850*1.2},{21,1850*1.2*nA0}}
			},
		state_stun_attack={{{1,25},{20,30},{21,31}},{{1,18},{20,18}}},
		seriesdamage_r={0},--={{{1,275},{20,500},{21,500}}},
		skill_cost_v={100},
		missile_hitcount={5},
		skill_cost_buff1layers_v={2818,1,1},--消耗1杀
		skill_startevent={2847},
		skill_eventskilllevel={{{1,1},{20,20}}},
	},
	sxgm_atk90_child={ --剑古墓1杀高_子_20
		--appenddamage_p= {{{1,71},{20,80},{21,80*nA0}}},
		--appenddamage_p= {{{1,60*nS01},{20,60},{21,60*nA0}}},
		floatdamage_p = {
			[1] = {{1,0.8*600*nS01},{20,0.8*600},{21,0.8*600*nA0}},
			[2] = {{1,1.2*600*nS01},{20,1.2*600},{21,1.2*600*nA0}},
		},
		lightingdamage_v={
			[1]={{1,1850*0.8*nS01},{20,1850*0.8},{21,1850*0.8*nA0}},
			[3]={{1,1850*1.2*nS01},{20,1850*1.2},{21,1850*1.2*nA0}}
			},
		state_stun_attack={{{1,25},{20,30},{21,31}},{{1,18},{20,18}}},
		seriesdamage_r={0},--={{{1,275},{20,500},{21,500}}},
		missile_hitcount={5},
		skill_startevent={2817},--获得闪
		skill_eventskilllevel={1},
	},
	------------------主攻技能over---------------------
	sxgm_a={ --剑古墓_闪,2817
		fastwalkrun_p={0},
		superposemagic={7,0,{{1,1},{2,2}}},
		skill_statetime={3600*18},
	},
	sxgm_b={ --剑古墓_杀,2818
		fastwalkrun_p={0},
		superposemagic={7,0,{{1,1},{2,2}}},
		skill_statetime={3600*18},
	},
	--每秒获得闪
	sxgm_get_a={ --剑古墓_获得闪
		autoskill={131,{{1,1},{10,10}}},
		skill_statetime={{{1,1*18},{2,2*18}}},
	},
	sxgm_get_b={ --剑古墓_获得杀
		autoskill={132,{{1,1},{10,10}}},
		skill_statetime={{{1,1*18},{2,2*18}}},
	},
	sxgm_get_buff={ --每级表示n秒获得1点杀或闪...
		skill_missilenum_v={{{1,1},{2,2}},1},
	},

	sxgm_30={ --古墓30_10
		missile_collzheight={9999},
		state_fixed_attack={{{1,35},{10,85},{12,90}},{{1,18*1},{10,18*1}}},
		state_stun_attack={{{1,27},{10,45},{12,50}},{{1,18*1},{10,18*1}}},
		missile_hitcount={{{1,5},{10,5},{11,5}}},
		skill_cost_v={{{1,300},{10,300},{11,300}}},

		skill_cost_buff1layers_v={2817,3,0},--消耗2闪
		skill_startevent={2818},--获得杀
		skill_eventskilllevel={3},
	},
	sxgm_30_child={ --古墓30_子_10
		missile_collzheight={9999},
		state_fixed_attack={{{1,35},{10,85},{12,90}},{{1,18*1},{10,18*1}}},
		state_stun_attack={{{1,27},{10,45},{12,50}},{{1,18*1},{10,18*1}}},
		missile_hitcount={{{1,5},{10,5},{11,5}}},
	},
	
	sxgm_40={ --杀闪精通_20
		addenchant={36, {{1,1}, {2, 2}}},
		autoskill={135,{{1,1},{10,10}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	sxgm_60={ --剑古墓长效防御_20
		cri_resist={{{1,5},{20,100},{21,115}}},
		addmaxhpbymaxmp_p={{{1,4},{20,80},{21,84}}},
		skill_statetime={300*18},
		skill_cost_v={600},
		
		--skill_cost_buff1layers_v={2817,2,0},--消耗2闪
	},
	sxgm_70={ --剑古墓被动防御_10
		autoskill={134,{{1,1},{10,10}}},
		skill_statetime={-1},
	},
	sxgm_70_child={ --剑古墓被动防御_子_10
		staticmagicshieldmax_p={{{1,6},{10,120},{11,126}},{{1,5*18},{10,5*18}}},
	},
	sxgm_110={ --剑古墓强控_110_10
		state_float_attack={{{1,15},{10,85},{12,90}},{{1,6*18},{10,6*18}}},
		missile_hitcount={{{1,7},{10,7},{11,7}}},
		skill_cost_v={500},
		skill_mintimepercast_v={{{1,15*18},{10,15*18},{11,15*18}}},
		skill_mintimepercastonhorse_v={{{1,15*18},{10,15*18},{11,15*18}}},
		--skill_cost_buff1layers_v={2817,5,1},--扣除5闪
		skill_startevent={2818},--获得杀
		skill_eventskilllevel={5},--回复5点
	},

	sxgm_atkex={ --剑古墓120_10
		missile_collzheight={9999},
		--appenddamage_p= {{{1,3*60*nS01},{10,3*60},{11,3*60*nA0}}},
		floatdamage_p = {
			[1] = {{1,0.8*3*600*nS01},{10,0.8*3*600},{11,0.8*3*600*nA0}},
			[2] = {{1,1.2*3*600*nS01},{10,1.2*3*600},{11,1.2*3*600*nA0}},
		},
		lightingdamage_v={
			[1]={{1,3*1850*0.8*nS01},{10,3*1850*0.8},{11,3*1850*0.8*nA0}},
			[3]={{1,3*1850*1.2*nS01},{10,3*1850*1.2},{11,3*1850*1.2*nA0}}
			},
		--state_stun_attack={{{1,47},{10,65},{11,66}},{{1,18},{10,18}}},
		seriesdamage_r={0},--={{{1,500},{10,500},{11,500}}},
		skill_cost_v={{{1,200},{10,200}}},
		missile_hitcount={{{1,6},{10,6},{11,6}}},
		skill_cost_buff1layers_v={2818,2,0},--消耗2杀
		--skill_startevent={2817},--获得闪
		--skill_eventskilllevel={1},--获得1闪
	},

	sxgm_book2={ --古墓中级秘籍_10
		addenchant={35, {{1,1}, {2, 2}}},
		skill_statetime={{{1,-1},{10,-1}}},
		skill_skillexp_v=FightSkill.tbParam.tbMidBookSkillExp,
	},
	sxgm_book3={ --古墓高级秘籍_10
		autoskill={137,{{1,1},{10,10}}},
		skill_statetime={{{1,-1},{10,-1}}},
		skill_skillexp_v=FightSkill.tbParam.tbHighBookSkillExp,
	},
	sxgm_book3_child={ --古墓高级秘籍_10
		--lifereplenish_p={{{1,-6},{10,-15},{11,-16}}},
		redeivedamage_dec_p2={{{1,-6},{10,-15},{11,-16}}},
		superposemagic={3},
		skill_statetime={5*18},
	},
	-----------------------------各职业常规技能-------------------------
	sxgm_20={ --玉女剑法_10
		add_physiclightdamage_p={{{1,50},{10,150},{12,165}}},
		attackratingenhance_p={{{1,50},{10,150},{12,165}}},
		--adddefense_v={{{1,50},{10,150},{11,165}}},
		deadlystrikeenhance_r={{{1,30},{10,50},{11,55}}},
		attackspeed_v={{{1,5},{10,15},{11,16},{12,17},{13,17}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	sxgm_80={ --80技能_20
		state_stun_attackrate={{{1,10},{20,100}}},
		state_slowall_resistrate={{{1,10},{10,100},{20,150}}},
		attackspeed_v={{{1,10},{10,16},{20,26},{23,29},{24,29}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	sxgm_100={ --100技能_10
		cri_resist={{{1,20},{10,200},{11,200}}},
		skilldamageptrim={{{1,1},{10,10}}},
		skillselfdamagetrim={{{1,1},{10,10}}},
		state_stun_attacktime={{{1,10},{10,80}}},
		state_slowall_resisttime={{{1,10},{10,120}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	-----------------------------古墓坐骑技能-------------------
	sxgm_horseskill1={ --初级坐骑技能_50
		lifemax_v={{{1,50},{50,350}}},
		--manamax_v={{{1,7},{50,350}}},
		skill_statetime={{{1,-1},{2,-1}}},
		skill_skillexp_v=FightSkill.tbParam.tbHorseSkillExp1,
	},
	sxgm_horseskill2={ --中级坐骑技能_50
		lifemax_v={{{1,12*0.7},{50,615*0.7}}},
		manamax_v={{{1,12*1.3},{50,615*1.3}}},
		skill_statetime={{{1,-1},{2,-1}}},
		skill_skillexp_v=FightSkill.tbParam.tbHorseSkillExp2,
	},
	sxgm_horseskill3={ --高级坐骑技能_50
		lifemax_p={{{1,13*0.9},{50,60*0.9}}},
		manamax_p={{{1,13*1.1},{50,60*1.1}}},
		skill_statetime={{{1,-1},{2,-1}}},
		skill_skillexp_v=FightSkill.tbParam.tbHorseSkillExp3,
	},
	
	lygm_horseskill1={ --初级坐骑技能_50
		lifemax_v={{{1,50},{50,350}}},
		--manamax_v={{{1,7},{50,350}}},
		skill_statetime={{{1,-1},{2,-1}}},
		skill_skillexp_v=FightSkill.tbParam.tbHorseSkillExp1,
	},
	lygm_horseskill2={ --中级坐骑技能_50
		lifemax_v={{{1,12*1.2},{50,615*1.2}}},
		manamax_v={{{1,12*0.8},{50,615*0.8}}},
		skill_statetime={{{1,-1},{2,-1}}},
		skill_skillexp_v=FightSkill.tbParam.tbHorseSkillExp2,
	},
	lygm_horseskill3={ --高级坐骑技能_50
		lifemax_p={{{1,13*1.2},{50,60*1.2}}},
		manamax_p={{{1,13*0.8},{50,60*0.8}}},
		skill_statetime={{{1,-1},{2,-1}}},
		skill_skillexp_v=FightSkill.tbParam.tbHorseSkillExp3,
	},
	-----------------------------古墓针法-------------------------

	-----------------------------主要伤害技能-------------------------
	lygm_atk_10={ --10
		--appenddamage_p= {{{1,41},{10,50},{11,50*nA0}}},
		appenddamage_p= {{{1,40*nS01},{10,40},{11,40*nA0}}},
		lightingdamage_v={
			[1]={{1,1.75*395*0.8*nS01*0.8},{10,1.75*395*0.8*0.8},{11,1.75*395*0.8*nA0*0.8}},
			[3]={{1,1.75*395*1.2*nS01*0.8},{10,1.75*395*1.2*0.8},{11,1.75*395*1.2*nA0*0.8}}
			},
		state_stun_attack={{{1,13},{10,22},{11,23}},{{1,18},{10,18}}},
		seriesdamage_r={0},--={{{1,50},{10,100},{11,100}}},
		skill_cost_v={{{1,20},{10,20}}},
		--missile_hitcount={{{1,5},{10,5},{11,5}}},
	},
	lygm_atk_50={ --10
		--appenddamage_p= {{{1,51},{10,60},{11,60*nA0}}},
		appenddamage_p= {{{1,48*nS01},{10,48},{11,48*nA0}}},
		lightingdamage_v={
			[1]={{1,645*0.8*nS01*0.8},{10,645*0.8*0.8},{11,645*0.8*nA0*0.8}},
			[3]={{1,645*1.2*nS01*0.8},{10,645*1.2*0.8},{11,645*1.2*nA0*0.8}}
			},
		state_stun_attack={{{1,21},{10,30},{11,31}},{{1,18},{10,18}}},
		seriesdamage_r={0},--={{{1,100},{10,250},{11,250}}},
		skill_cost_v={{{1,50},{10,50}}},
		missile_hitcount={{{1,2},{10,2},{11,2}}},
	},
	lygm_atk_90={ --10
		--appenddamage_p= {{{1,61},{10,70},{11,70*nA0}}},
		appenddamage_p= {{{1,56*nS01},{10,56},{11,56*nA0}}},
		lightingdamage_v={
			[1]={{1,1725*0.8*nS01},{10,1725*0.8},{11,1725*0.8*nA0}},
			[3]={{1,1725*1.2*nS01},{10,1725*1.2},{11,1725*1.2*nA0}}
			},
		state_stun_attack={{{1,28},{10,37},{11,38}},{{1,18},{10,18}}},
		seriesdamage_r={0},--={{{1,250},{10,500},{11,500}}},
		skill_cost_v={{{1,100},{10,100}}},
		missile_hitcount={{{1,3},{10,3},{11,3}}},
	},

	-----------------------------辅助伤害技能-------------------------
	lygm_atk_30={ --冰魄银针_10
		--addenchant={39, {{1,1}, {2, 2}}},
		autoskill={130, {{1,1}, {2, 2}}},
		skill_statetime={-1},
		--skill_cost_v={{{1,500},{10,500}}},
		--skill_statetime={{{1,300*18},{2,300*18}}},
	},
	lygm_atk_30_child={ --冰魄银针_伤害_10
		missile_collzheight={9999},
		--appenddamage_p= {{{1,20*0.7},{10,20},{11,20*nA0}}},
		appenddamage_p= {{{1,16*nS01},{10,16},{11,16*nA0}}},
		lightingdamage_v={
			[1]={{1,585*0.8*nS01*0.8},{10,585*0.8*0.8},{11,585*0.8*nA0*0.8}},
			[3]={{1,585*1.2*nS01*0.8},{10,585*1.2*0.8},{11,585*1.2*nA0*0.8}}
			},
		seriesdamage_r={0},--={{{1,250},{10,500},{11,500}}},
		missile_hitcount={{{1,3},{10,3},{11,3}}},
	},
	lygm_atk_30_child2={ --冰魄银针_获得1点寸寸思
		missile_collzheight={9999},
		skill_collideevent={2846},
		skill_eventskilllevel={1},
		skill_showevent={1},
	},
	lygm_atk_70={ --玉蜂针_10
		missile_collzheight={9999},
		--appenddamage_p= {{{1,30*0.7},{10,30},{11,30*nA0}}},
		appenddamage_p= {{{1,20*nS01},{10,20},{11,20*nA0}}},
		lightingdamage_v={
			[1]={{1,985*0.8*nS01},{10,985*0.8},{11,985*0.8*nA0}},
			[3]={{1,985*1.2*nS01},{10,985*1.2},{11,985*1.2*nA0}}
			},
		state_stun_attack={{{1,16},{10,25},{11,26}},{{1,2*18},{10,2*18}}},
		seriesdamage_r={0},--={{{1,275},{10,500},{11,500}}},
		skill_cost_v={{{1,500},{10,500}}},
		missile_hitcount={{{1,3},{10,3},{11,3}}},
		--skill_mintimepercast_v={1*18},
		--skill_mintimepercastonhorse_v={1*18},
		
		skill_cost_buff1layers_v={2846,2,0},
	},
	-----------------------------特色辅助技能-------------------------
	
	lygm_30={ --自动淬毒_10
		autoskill={127, {{1,1}, {2, 2}}},
		addenchant={38, {{1,1}, {2, 2}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	lygm_30_child={ --自动淬毒_子_10
		--addenchant={38, {{1,1}, {2, 2}}},
		fastwalkrun_p={0},
		superposemagic={6,0,1},
		skill_statetime={{{1,30*18},{2,30*18}}},
	},

	lygm_40={ --_10
		skill_mintimepercast_v={{{1,11*18},{20,2*18},{21,2*18}}},
		skill_mintimepercastonhorse_v={{{1,11*18},{20,2*18},{21,2*18}}},
		skill_cost_v={{{1,50},{10,50},{11,50}}},
	},
	lygm_40_child1={ --_10
		state_fixed_attack={{{1,20},{20,85},{23,90}},{{1,18*1.5},{10,18*1.5}}},
		state_stun_attack={{{1,20},{20,45},{23,50}},{{1,18*1.5},{10,18*1.5}}},
		missile_hitcount={{{1,1},{20,3},{21,4}}},
		
		skill_startevent={2848},
		skill_eventskilllevel={{{1,1},{20,20}}},
		skill_showevent={1},
	},
	lygm_40_child2={ --_10
		--castspeed_v={{{1,1},{20,10},{21,10}}},
		--fastwalkrun_p={{{1,1},{20,20},{21,21}}},
		adddefense_p={{{1,8},{20,160},{21,168}}},
		skill_statetime={{{1,15*18},{2,15*18}}},
	},
	lygm_40_child3={ --_10
		--autoskill={130,{{1,1},{10,10}}},
		--autoskill={130, {{1,1}, {2, 2}}},
		fastwalkrun_p={0},
		skill_statetime={1},
	},
	
	lygm_60_a={ --5
		damage_inc_p={{{1,-30},{5,-30},{6,-30}}},
		allspecialstateresistrate={{{1,52},{5,260},{6,273}}},
		autoskill={123,{{1,1},{5,5}}},
		skill_statetime={{{1,3*18},{2,3*18}}},
	},
	lygm_60_a2={ --5
		missile_hitcount={{{1,5},{5,5},{6,5}}},
	},
	lygm_60_a3={ --5
		--appenddamage_p= {{{1,23},{5,35},{6,35*nA0}}},
		appenddamage_p= {{{1,28*nS01},{5,28},{6,28*nA0}}},
		lightingdamage_v={
			[1]={{1,865*0.8*nS01},{5,865*0.8},{6,865*0.8*nA0}},
			[3]={{1,865*1.2*nS01},{5,865*1.2},{6,865*1.2*nA0}}
			},
		seriesdamage_r={0},--={{{1,500},{5,500},{6,500}}},
		missile_hitcount={5},
	},
	lygm_60_b={ --_5
		deadlystrikeenhance_r={{--每级+3%会心,+1的时候每级+2%,作为一定程度上减少会心递减
			{ 1, 121},
			{ 2, 259},
			{ 3, 417},
			{ 4, 600},
			{ 5, 814},
			{ 6, 894},
			{ 7, 978},
			{ 8, 1068},
			{ 9, 1164},
			{ 10,1266},}},
		deadlystrikedamageenhance_p={{{1,6},{5,30},{7,33}}},
		addenchant={37, {{1,1}, {2, 2}}},
		skill_statetime={{{1,7*18},{2,7*18}}},
	},
	lygm_60_c={ --_5
		autoskill={124,{{1,1},{5,5}}},
		redeivedamage_dec_p2={{{1,4},{5,20},{6,21}}},
		skill_statetime={{{1,7*18},{2,7*18}}},
	},
	lygm_60_c2={ --_5
		state_hurt_attack={{{1,36},{5,100},{6,105}},{{1,18*1},{10,18*1}}},
		state_fixed_attack={{{1,36},{5,100},{6,105}},{{1,18*1},{10,18*1}}},
		missile_hitcount={5},
	},

	lygm_70={ --_15
		autoskill={125,{{1,1},{10,10}}},
		autoskill2={126,{{1,1},{10,10}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	lygm_70_child1={ --_15
		damage_inc_p		={{{1,5},{15,20},{16,21}}},
		redeivedamage_dec_p2	={{{1,16},{15,30},{16,31}}},
		npcdamageadded			={{{1,16},{15,30},{16,31}}},
		skill_statetime={{{1,3*18},{2,3*18}}},
	},
	lygm_70_child2={ --_10_不得状态
		magic_duck_skill={2844},
		skill_statetime={{{1,2*18},{2,2*18}}},
	},
	
	lygm_110={ --五气朝元_保护状态_10
		magic_duck_skill={2853},
		skill_statetime={2*18},
	},
	lygm_110_dmg={ --千针诛恨_伤害_10
		missile_collzheight={9999},
		--appenddamage_p= {{{1,25*0.7},{10,25},{11,25*nA0}}},
		appenddamage_p= {{{1,20*nS01},{10,20},{11,20*nA0}}},
		lightingdamage_v={
			[1]={{1,615*0.8*nS01},{10,615*0.8},{11,615*0.8*nA0}},
			[3]={{1,615*1.2*nS01},{10,615*1.2},{11,615*1.2*nA0}}
			},
		seriesdamage_r={0},--={{{1,500},{10,500},{11,500}}},
		missile_hitcount={{{1,9},{10,9},{11,9}}},
		--removestate={2832},
	},
	lygm_110_debuff={ --黄泉蹒跚_10
		addenchant={40, {{1,1}, {2, 2}}},
		autoskill={129, {{1,1}, {2, 2}}},
		allspecialstateresistrate={{{1,-275},{10,-500},{11,-525}}},
		skill_statetime={{{1,9*18},{2,9*18}}},
		skill_cost_v={500},
		skill_cost_buff1layers_v={2846,4,0},--消耗4针
		--skill_mintimepercast_v={30*18},
		--skill_mintimepercastonhorse_v={30*18},
	},
	lygm_110_adddmg={ --受到伤害增加_10
		redeivedamage_dec_p2={{{1,-6},{10,-15}}},
		superposemagic={5,0,1},
		skill_statetime={{{1,3*18},{2,3*18}}},
	},
	
	-----------------------------秘籍技能------------------------------
	lygm_book2={ --自动隐身_10
		autoskill={138, {{1,1}, {2, 2}}},
		skill_statetime={{{1,-1},{2,-1}}},
		skill_skillexp_v=FightSkill.tbParam.tbMidBookSkillExp,
	},
	lygm_book2_child1={ --_10
		hide={0,{{1,2*18},{10,2*18}}, 1},
		missile_lifetime_v={6*18},
		missile_dmginterval={1.5*18},
	},
	
	lygm_book3={ --高级秘籍技能_10
		autoskill={128, {{1,1}, {2, 2}}},
		skill_statetime={{{1,-1},{2,-1}}},
		skill_skillexp_v=FightSkill.tbParam.tbHighBookSkillExp,
	},
	lygm_book3_child={ --高级秘籍技能_10
		state_drag_attack={{{1,40},{10,100},{11,105}},{{1,25},{10,25},{11,25}},{{1,32},{2,32}}},
		skilldamageptrim={{{1,-4},{10,-40}}},
		skillselfdamagetrim={{{1,-4},{10,-40}}},
		skill_statetime={{{1,4*18},{2,4*18}}},
	},
	-----------------------------各职业常规技能-------------------------
	lygm_20={ --20级技能_10
		--addlightingmagic_v={{{1,50},{10,500},{11,525}}},
		add_magiclightdamage_p={{{1,50},{10,150},{12,165}}},
		deadlystrikeenhance_r={{{1,30},{10,50},{11,55}}},
		castspeed_v={{{1,5},{10,15},{11,16},{12,17},{13,17}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	lygm_80={ --80技能_20
		state_stun_attackrate={{{1,10},{20,100}}},
		state_slowall_resistrate={{{1,10},{10,100},{20,150}}},
		castspeed_v={{{1,10},{10,16},{20,26},{23,29},{24,29}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	lygm_100={ --100技能_10
		skilldamageptrim={{{1,1},{10,10}}},
		skillselfdamagetrim={{{1,1},{10,10}}},
		state_stun_attacktime={{{1,10},{10,80}}},
		state_slowall_resisttime={{{1,10},{10,120}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
}

FightSkill:AddMagicData(tb)

local tbSkill = FightSkill:GetClass("sxgm_atk10")

function tbSkill:GetExtraDesc(tbInfo)
	if (not tbInfo) then
		return "";
	end
	local tbInfo2 = KFightSkill.GetSkillInfo(tbInfo.nId, tbInfo.nLevel, me, 1);
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbInfo2.tbEvent.nStartSkillId, tbInfo2.tbEvent.nLevel, me, 1);
	local szSkillName	= FightSkill:GetSkillName(tbChildInfo.nId);
	local szMsg = string.format("\n释放技能同时获得<color=gold>%d<color>层<color=green>[%s]<color>", 
			tbChildInfo.tbWholeMagic["superposemagic"][3],
			szSkillName);
	return szMsg;
end

local tbSkill = FightSkill:GetClass("sxgm_atk50")

function tbSkill:GetExtraDesc(tbInfo)
	if (not tbInfo) then
		return "";
	end
	local tbInfo2 = KFightSkill.GetSkillInfo(tbInfo.nId, tbInfo.nLevel, me, 1);
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbInfo2.tbEvent.nStartSkillId, tbInfo2.tbEvent.nLevel, me, 1);
	local szSkillName	= FightSkill:GetSkillName(tbChildInfo.nId);
	local szMsg = string.format("\n释放技能同时获得<color=gold>%d<color>层<color=green>[%s]<color>", 
			tbChildInfo.tbWholeMagic["superposemagic"][3],
			szSkillName);
	return szMsg;
end

local tbSkill = FightSkill:GetClass("sxgm_atk90")

function tbSkill:GetExtraDesc(tbInfo)
	if (not tbInfo) then
		return "";
	end
	local tbInfo2 = KFightSkill.GetSkillInfo(tbInfo.nId, tbInfo.nLevel, me, 1);
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbInfo2.tbEvent.nStartSkillId, tbInfo2.tbEvent.nLevel, me, 1);
	local tbChildInfo2	= KFightSkill.GetSkillInfo(tbChildInfo.tbEvent.nStartSkillId, tbChildInfo.tbEvent.nLevel, me, 1);
	local szSkillName	= FightSkill:GetSkillName(tbChildInfo2.nId);
	local szMsg = string.format("\n释放技能同时获得<color=gold>%d<color>层<color=green>[%s]<color>", 
			tbChildInfo2.tbWholeMagic["superposemagic"][3],
			szSkillName);
	return szMsg;
end

local tbSkill = FightSkill:GetClass("sxgm_30")

function tbSkill:GetExtraDesc(tbInfo)
	if (not tbInfo) then
		return "";
	end
	local tbInfo2 = KFightSkill.GetSkillInfo(tbInfo.nId, tbInfo.nLevel, me, 1);
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbInfo2.tbEvent.nStartSkillId, tbInfo2.tbEvent.nLevel, me, 1);
	local szSkillName	= FightSkill:GetSkillName(tbChildInfo.nId);
	local szMsg = string.format("\n释放技能同时获得<color=gold>%d<color>层<color=green>[%s]<color>", 
			tbChildInfo.tbWholeMagic["superposemagic"][3],
			szSkillName);
	return szMsg;
end

local tbSkill = FightSkill:GetClass("sxgm_110")

function tbSkill:GetExtraDesc(tbInfo)
	if (not tbInfo) then
		return "";
	end
	local tbInfo2 = KFightSkill.GetSkillInfo(tbInfo.nId, tbInfo.nLevel, me, 1);
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbInfo2.tbEvent.nStartSkillId, tbInfo2.tbEvent.nLevel, me, 1);
	local szSkillName	= FightSkill:GetSkillName(tbChildInfo.nId);
	local szMsg = string.format("\n释放技能同时获得<color=gold>%d<color>层<color=green>[%s]<color>", 
			tbChildInfo.tbWholeMagic["superposemagic"][3],
			szSkillName);
	return szMsg;
end


local tbSkill	= FightSkill:GetClass("lygm_60_a");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbChildInfo2	= KFightSkill.GetSkillInfo(2842, tbAutoInfo.nSkillLevel);
	local tbMsg = {};
	local szMsg = "";
	
	szMsg = szMsg..string.format("击中时<color=gold>%s%%<color>对最多<color=gold>%s<color>个敌人分别释放：\n    <color=green>[流光四射]<color>\n", tbAutoInfo.nPercent, tbChildInfo.nMissileHitcount);
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo2, 0);
	for i=1, #tbMsg do
		szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	--szMsg = szMsg.."\n触发间隔：<color=gold>"..FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime).."<color>秒\n"
	return szMsg;
end

local tbSkill = FightSkill:GetClass("lygm_60_a2")

function tbSkill:GetExtraDesc(tbInfo)
	if (not tbInfo) then
		return "";
	end
	local tbChildInfo	= KFightSkill.GetSkillInfo(2842, tbInfo.nLevel);
	local szMsg = ""	
	local tbMsg = {};
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0);
	szMsg = szMsg.."\n"
	szMsg = szMsg.."击中每个目标时释放：\n";
	szMsg = szMsg.."<color=green>[流光四射] "..tbInfo.nLevel.."级<color>\n";
	for i=1, #tbMsg do
		szMsg = szMsg..""..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	return szMsg;
end

local tbSkill	= FightSkill:GetClass("lygm_60_c");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbMsg = {};
	local szMsg = "";
	szMsg = szMsg.."击中时<color=gold>"..tbAutoInfo.nPercent.."<color>%自动释放：\n";
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0);
	for i=1, #tbMsg do
		szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	szMsg = szMsg.."\n触发间隔：<color=gold>"..FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime).."<color>秒\n"
	return szMsg;
end


local tbSkill	= FightSkill:GetClass("lygm_30");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbMsg = {};
	local szMsg = "";
	local szSkillName = FightSkill:GetSkillName(tbAutoInfo.nSkillId);
	szMsg = szMsg.."每<color=gold>"..FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime).."秒<color>自动获得<color=gold>1层<color><color=green>["..szSkillName.."]<color>";
	szMsg = szMsg.."，最多拥有<color=gold>"..tbChildInfo.tbWholeMagic["superposemagic"][1].."层<color>\n";
	--[[
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0);
	for i=1, #tbMsg do
		szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	szMsg = szMsg.."\n触发间隔：<color=gold>"..FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime).."<color>秒\n"
	]]
	return szMsg;
end


local tbSkill	= FightSkill:GetClass("lygm_70");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbMsg = {};
	local szMsg = "";
	szMsg = szMsg.."每<color=gold>"..FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime).."秒<color>自动获得如下状态：\n";
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0);
	for i=1, #tbMsg do
		szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	szMsg = szMsg.."\n持续时间可以叠加，最多<color=gold>10秒<color>"
	return szMsg;
end

function tbSkill:GetAutoDesc2(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbMsg = {};
	local szMsg = "";
	local nStateTime = FightSkill:Frame2Sec(tbChildInfo.nStateTime)
	szMsg = szMsg.."攻击命中后<color=gold>"..nStateTime.."秒<color>内不能再获得该效果";
	return szMsg;
end

--[[
local tbSkill = FightSkill:GetClass("lygm_atk_30")

function tbSkill:GetExtraDesc(tbInfo)
	if (not tbInfo) then
		return "";
	end

	local szMsg	= string.format("<color=gray>(状态下再次使用可关闭技能)<color>");
	return szMsg;
end]]


local tbSkill	= FightSkill:GetClass("lygm_book3");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbMsg = {};
	local szMsg = "";
	local szSkillName = FightSkill:GetSkillName(tbChildInfo.nId)
	szMsg = szMsg.."受到攻击时有<color=gold>"..tbAutoInfo.nPercent.."%<color>几率自动释放：\n";
	szMsg = szMsg.."    <color=green>"..szSkillName.."<color>：\n";
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0);
	for i=1, #tbMsg do
		szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	szMsg = szMsg.."\n触发间隔：<color=gold>"..FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime).."<color>秒"
	return szMsg;
end


local tbSkill	= FightSkill:GetClass("lygm_110_debuff");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbMsg = {};
	local szMsg = "";
	local szSkillName = FightSkill:GetSkillName(tbChildInfo.nId)
	szMsg = szMsg.."每<color=gold>"..FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime).."秒<color>对目标释放：\n";
	szMsg = szMsg.."    <color=green>["..szSkillName.."]<color>：\n";
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0);
	for i=1, #tbMsg do
		szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	szMsg = szMsg.."\n    初始位置不会被叠加<color=green>[积郁焚心]<color>效果";
	return szMsg;
end


local tbSkill	= FightSkill:GetClass("lygm_atk_30");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbMsg = {};
	local szMsg = "";
	local szSkillName = FightSkill:GetSkillName(tbAutoInfo.nRelativeSkillId1)
	szMsg = szMsg.."<color=gold>"..szSkillName.."<color>结束时释放<color=green>冰魄银针<color>：\n";
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0);
	for i=1, #tbMsg do
		szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel, me, 1);
	local tbCCInfo0		= KFightSkill.GetSkillInfo(tbChildInfo.tbEvent.nStartSkillId, tbChildInfo.tbEvent.nLevel, me, 1);
	local tbCCInfo1		= KFightSkill.GetSkillInfo(tbCCInfo0.tbEvent.nCollideSkillId, tbCCInfo0.tbEvent.nLevel, me, 1);
	local szSkillName2 = FightSkill:GetSkillName(tbCCInfo0.nId);
	local szSkillName3 = FightSkill:GetSkillName(tbCCInfo1.nId);
	szMsg = szMsg.."\n<color=gold>"..szSkillName2.."<color>击中获得<color=gold>1层<color><color=green>["..szSkillName3.."]<color>";
	szMsg = szMsg.."，最多拥有<color=gold>"..tbCCInfo1.tbWholeMagic["superposemagic"][1].."层<color>";
	--szMsg = szMsg.."\n触发间隔：<color=gold>"..FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime).."<color>秒\n"
	return szMsg;
end

local tbSkill	= FightSkill:GetClass("lygm_40_child3");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbMsg = {};
	local szMsg = "";
	local szSkillName = FightSkill:GetSkillName(tbAutoInfo.nRelativeSkillId1)
	szMsg = szMsg.."<color=gold>"..szSkillName.."<color>结束时释放<color=green>冰魄银针<color>：\n";
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0);
	for i=1, #tbMsg do
		szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	return szMsg;
end

local tbSkill	= FightSkill:GetClass("sxgm_get_a");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbMsg = {};
	local szMsg = "";
	szMsg = szMsg.."每隔<color=gold>"..FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime).."秒<color>自动获得：\n";
	local szSkillName = FightSkill:GetSkillName(tbAutoInfo.nSkillId)
	szMsg = szMsg.."<color=green>["..szSkillName.."]<color>\n"
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0);
	for i=1, #tbMsg do
		szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	return szMsg;
end

local tbSkill	= FightSkill:GetClass("sxgm_get_b");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbMsg = {};
	local szMsg = "";
	szMsg = szMsg.."每隔<color=gold>"..FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime).."秒<color>自动获得：\n";
	local szSkillName = FightSkill:GetSkillName(tbAutoInfo.nSkillId)
	szMsg = szMsg.."<color=green>["..szSkillName.."]<color>\n"
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0);
	for i=1, #tbMsg do
		szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	return szMsg;
end


local tbSkill	= FightSkill:GetClass("sxgm_70");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbMsg = {};
	local szMsg = "";
	szMsg = szMsg.."生命值下降到<color=gold>50%<color>以下时自动释放以下技能：\n";
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0);
	for i=1, #tbMsg do
		szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	szMsg = string.gsub(szMsg, "，持续时间", "\n    持续时间");
	szMsg = szMsg.."\n自动释放间隔：<color=gold>"..FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime).."<color>秒\n"
	return szMsg;
end


local tbSkill	= FightSkill:GetClass("sxgm_40");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbMsg = {};
	local szMsg = "";
	local szSkillName = FightSkill:GetSkillName(tbAutoInfo.nSkillId);
	local nSup = FightSkill:Frame2Sec(tbChildInfo.tbWholeMagic["superposemagic"][3]);
	nSup = (nSup==0) and 1 or nSup;
	szMsg = szMsg..string.format("每隔<color=gold>%s秒<color>自动获得<color=gold>%d<color>层<color=green>[%s]<color>",
				FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime),
				nSup,
				szSkillName);
	--FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0);
	--for i=1, #tbMsg do
	--	szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	--end
	return szMsg;
end

local tbSkill	= FightSkill:GetClass("lygm_book2");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbMsg = {};
	local szMsg = "";
	local szSkillName = FightSkill:GetSkillName(tbAutoInfo.nRelativeSkillId1)
	local szSkillName2 = FightSkill:GetSkillName(tbAutoInfo.nSkillId)
	szMsg = szMsg.."<color=green>"..szSkillName.."<color>状态用尽时";
	szMsg = szMsg..string.format("自动释放持续<color=gold>%s秒<color>的烟雾弹，自身处于烟雾附近时可以保持隐身状态",
	FightSkill:Frame2Sec(tbChildInfo.tbWholeMagic["missile_lifetime_v"][1]))
	--FightSkill:Frame2Sec(tbChildInfo.tbWholeMagic["missile_dmginterval"][1]),
	--FightSkill:Frame2Sec(tbChildInfo.tbWholeMagic["hide"][2]))
	szMsg = szMsg.."\n自动释放间隔：<color=gold>"..FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime).."<color>秒\n"
	return szMsg;
end

local tbSkill	= FightSkill:GetClass("sxgm_book3");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbMsg = {};
	local szMsg = "";
	szMsg = szMsg.."攻击时<color=gold>"..tbAutoInfo.nPercent.."%<color>几率自动对敌人施加如下状态：\n";
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0);
	for i=1, #tbMsg do
		szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	szMsg = szMsg.."\n触发间隔：<color=gold>"..FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime).."<color>秒\n"
	return szMsg;
end