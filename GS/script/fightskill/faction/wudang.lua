Require("\\script\\fightskill\\fightskill.lua")
local nA0 = FightSkill.tbParam.nSadd;	--攻速类攻击技能+1的成长系数
local nA1 = FightSkill.tbParam.nSadd1;	--格斗类攻击技能+1的成长系数
local nS01 = FightSkill.tbParam.nS1;	--技能1级的数值系数
local nS20 = FightSkill.tbParam.nS20;	--技能20级的数值系数

--武当
local tb	= {
	--气武
	bojierfu={ --剥及而复
		appenddamage_p= {{{1,100},{20,100},{21,100*nA0}}},
		lightingdamage_v={
			[1]={{1,5*0.8},{10,140*0.9},{20,425*0.9},{21,425*nA0*0.9}},
			[3]={{1,5*1.2},{10,140*1.1},{20,425*1.1},{21,425*nA0*1.1}}
		},
		state_stun_attack={{{1,15},{10,35},{20,40},{21,41}},{{1,18},{20,18}}},
		seriesdamage_r={0},--={{{1,50},{20,100},{21,100}}},
		skill_cost_v={{{1,20},{20,50},{21,50}}},
		addskilldamagep={162, {{1,2},{20,30},{21,35}},1},
		addskilldamagep2={165, {{1,2},{20,10},{21,12}},1},
	},
	wudangquanfa={ --武当拳法_10
		addlightingmagic_v={{{1,5},{10,340},{11,374}}},
		--manashield_p={{{1,-5},{10,-15},{20,-15}}},
		deadlystrikeenhance_r={{{1,30},{10,50},{11,55}}},
		castspeed_v={{{1,10},{10,15},{11,16},{12,17},{13,17}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	zuowangwuwo={ --坐忘无我_10
		manashield_p={{{1,15},{10,70},{12,77}}},
		state_freeze_resistrate={{{1,260},{10,260},{11,260}}},
		state_slowall_resisttime={{{1,30},{10,135}}},
		skill_statetime={300*18},
		skill_cost_v={{{1,50},{10,168},{11,168}}},
	},
	wuwowujian={ --无我无剑_20
		appenddamage_p= {{{1,35},{20,35},{21,35*nA0}}},
		missile_hitcount={{{1,3},{5,4},{10,5},{15,6},{16,6},{21,6},{22,6}}},
		lightingdamage_v={
			[1]={{1,550*0.8},{10,640*0.9},{20,695*0.9},{21,695*nA0*0.9}},
			[3]={{1,550*1.2},{10,640*1.1},{20,695*1.1},{21,695*nA0*1.1}}
		},
		state_stun_attack={{{1,10},{10,15},{20,20},{21,21}},{{1,18},{20,18}}},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		skill_cost_v={{{1,50},{20,150},{21,150}}},
		addskilldamagep={165, {{1,2},{20,30},{21,35}},1},
	},
	tiyunzong={ --梯云纵_20
		fastwalkrun_p={{{1,10},{20,60},{21,61}},{{1,-1},{20,-1}}},
--		state_slowall_resisttime={{{1,10},{20,35}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	chunyangwuji={ --纯阳无极_10
		staticmagicshieldcur_p ={{{1,170},{10,306},{11,316}},{{1,15*18},{10,30*18},{11,30*18}}},
		skill_mintimepercast_v={{{1,60*18},{10,30*18},{11,30*18}}},
		skill_mintimepercastonhorse_v={{{1,60*18},{10,30*18},{11,30*18}}},
	},
	zhenwuqijie_team={ --真武七截
		addphysicsmagic_p={{{1,35},{20,140},{21,147}}},
	},
	zhenwuqijie={ --真武七截_20
		addphysicsmagic_p={{{1,50},{20,200},{21,210}}},
		--skill_cost_v={{{1,2},{20,25}}},
	},
	tiandiwuji={ --天地无极
		appenddamage_p= {{{1,45*nS01},{10,45},{20,45*nS20},{21,45*nS20*nA0}}},
		lightingdamage_v={
			[1]={{1,825*0.9*nS01},{10,825*0.9},{20,825*0.9*nS20},{21,825*0.9*nS20*nA0}},
			[3]={{1,825*1.1*nS01},{10,825*1.1},{20,825*1.1*nS20},{21,825*1.1*nS20*nA0}}
			},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		skill_cost_v={{{1,100},{20,200},{21,200}}},
		state_stun_attack={{{1,12},{10,17},{20,22}},{{1,18},{20,18}}},
		missile_hitcount={{{1,5},{5,6},{10,8},{15,9},{20,10},{21,10}}},
	},
	taijiwuyi={ --太极无意_20
		state_stun_attackrate={{{1,10},{20,100}}},
		state_slowall_resistrate={{{1,10},{10,100},{20,150}}},
		castspeed_v={{{1,10},{10,16},{20,26},{23,29},{24,29}}},
		changecdtype={{{1,852},{10,852}},{{1,100},{10,100}},{{1,100},{10,100}}},--万剑归宗
		autoskill={{{1,73},{2,73}},{{1,1},{10,10}}},--攻击命中触发5秒内回复万剑归宗
		skill_statetime={{{1,-1},{2,-1}}},
	},
	taijiwuyi_child={ --太极无意子_1_5秒内回复万剑归宗
		autoskill={{{1,94},{2,94}},{{1,1},{10,10}}},
		skill_statetime={{{1,5*18},{2,5*18}}},
	},
	taijiwuyi_child2={ --太极无意子_2_触发回复万剑归宗
		recover_usepoint={{{1,852},{10,852}},{{1,4},{10,4}}},
	},
	taijishengong={ --太极神功
		skilldamageptrim={{{1,1},{10,10}}},
		skillselfdamagetrim={{{1,1},{10,10}}},
		state_stun_attacktime={{{1,10},{10,80}}},
		state_slowall_resisttime={{{1,10},{10,120}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	
	liangyixinfa={ --中级秘籍：两仪心法
		autoskill={{{1,29},{2,29}},{{1,1},{10,10}}},
		skill_skillexp_v=FightSkill.tbParam.tbMidBookSkillExp,
		skill_statetime={{{1,-1},{2,-1}}},
	},
	liangyixinfa_child={ --中级秘籍：两仪心法
		deadlystrikeenhance_r={{{1,180},{10,450},{11,475}}},
		skill_statetime={{{1,18*3},{10,18*5},{11,18*5}}},
	},
	liangyixinfa_child2={ --中级秘籍：两仪心法子2
		prop_invincibility={1},
		skill_statetime={{{1,18*1},{10,18*2},{11,18*2.1}}},
	},
	
	wudangjiuyanggong={ --武当九阳功_10
		attackenhancebycostmana_p={{{1,3},{10,30},{12,33}}},
		state_stun_attackrate={{{1,55},{10,100},{10,105}}},
		--skill_mintimepercast_v={{{1,60*18},{10,30*18},{11,30*18}}},
		--skill_mintimepercastonhorse_v={{{1,60*18},{10,30*18},{11,30*18}}},
		skill_statetime={{{1,-1},{10,-1}}},
	},	
	qiwuadvancedbook={ --高级秘籍
		autoskill={{{1,44},{10,44}},{{1,1},{10,10}}},
		skill_statetime={{{1,-1},{10,-1}}},
		skill_skillexp_v=FightSkill.tbParam.tbHighBookSkillExp,
	},
	
	qiwuadvancedbook_child={ --高级秘籍子
		appenddamage_p= {{{1,100*0.7*1.2},{10,100*1.2},{11,100*1.2*1.05}}},
		lightingdamage_v={
			[1]={{1,1650*0.9*0.7*1.2},{10,1650*0.9*1.2},{11,1650*0.9*1.2*1.05}},
			[3]={{1,1830*1.1*0.7*1.2},{10,1830*1.1*1.2},{11,1830*1.1*1.2*1.05}},
			},
		seriesdamage_r={0},--={{{1,250},{10,250}}},
		--state_stun_attack={{{1,12},{10,22}},{{1,18},{10,18}}},
		missile_hitcount={{{1,3},{10,8},{11,8}}},
	},
	qiwu120={ --气武120_10
		appenddamage_p= {{{1,40*0.7},{10,40},{11,40*nA0}}},
		lightingdamage_v={
			[1]={{1,600*0.7},{10,600},{11,600*nA0}},
			[3]={{1,750*0.7},{10,750},{11,750*nA0}},
			},
		seriesdamage_r={0},--={{{1,250},{10,250}}},
		skill_cost_v={{{1,999},{10,999}}},
		skill_mintimepercast_v={{{1,300*18},{10,300*18}}},
		skill_mintimepercastonhorse_v={{{1,300*18},{10,300*18}}},
		missile_hitcount={{{1,15},{10,15}}},
	},
	qiwu120_child={ --气武120_子_10
		deadlystrikeenhance_r={{{1,40*.7},{10,40},{11,40*nA0}}},
		superposemagic={{{1,99},{10,99}}},
		skill_statetime={{{1,15*18},{10,15*18}}},
		--removestate={{{1,861},{2,861}}},  --剑心通明清除圣火令法,避免万剑归宗无限施放
	},
	qiwu120_child2={ --气武120_子子_10
		removestate={{{1,861},{2,861}}},  --剑心通明清除圣火令法,避免万剑归宗无限施放
	},
	--剑武
	jianfeijingtian={ --剑飞惊天_20
		appenddamage_p= {{{1,50},{20,50},{21,50*nA0}}},
		seriesdamage_r={0},--={{{1,50},{20,100},{21,100}}},
		physicsenhance_p={{{1,5},{10,32},{20,62},{21,62*nA0}}},
		lightingdamage_v={
			[1]={{1,25*0.9},{15,205*0.9},{20,355*0.9},{21,355*nA0*0.9}},
			[3]={{1,25*1.1},{15,205*1.1},{20,355*1.1},{21,355*nA0*1.1}}
		},
--		state_hurt_attack={{{1,5},{20,10}},{{1,20},{20,30}}},
		state_stun_attack={{{1,15},{10,35},{20,40},{21,41}},{{1,18},{20,18}}},
--		skill_attackradius={{{1,300},{20,300}}},
		skill_cost_v={{{1,2},{20,20},{21,20}}},
	--	attackrating_p={{{1,50},{20,100}}},
		addskilldamagep={169, {{1,2},{20,30},{21,35}},1},
		addskilldamagep2={171, {{1,2},{20,10},{21,12}},1},
		--addskilldamagep3={173, {{1,2},{20,10},{21,12}}},
	},
	wudangjianfa={ --武当剑法_10
		addphysicsdamage_p={{{1,35},{10,130},{11,143}}},
	--	addphysicsdamage_v={{{1,30},{10,300},{20,420}},0,{{1,12},{2,12}}},
		attackratingenhance_p={{{1,50},{10,200},{11,220}}},
		adddefense_v={{{1,50},{10,150},{11,165}}},
		deadlystrikeenhance_r={{{1,30},{10,50},{11,55}}},
		attackspeed_v={{{1,10},{10,25},{11,26},{12,27},{13,27}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	wuwoxinfa={ --无我心法_10
		manashield_p={{{1,20},{10,85},{11,89}}},
		state_freeze_resistrate={{{1,260},{10,260},{11,260}}},
		state_slowall_resisttime={{{1,30},{10,135},{11,145}}},
		skill_statetime={300*18},
		skill_cost_v={{{1,50},{20,300}}},
	},
	sanhuantaoyue={ --三环套月
		appenddamage_p= {{{1,25},{20,25},{21,25*nA0}}},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		physicsenhance_p={{{1,35},{10,71},{20,91},{21,91*nA0}}},
		lightingdamage_v={
			[1]={{1,350*0.8},{10,440*0.9},{20,495*0.9},{21,495*nA0*0.9}},
			[3]={{1,350*1.2},{10,440*1.1},{20,495*1.1},{21,495*nA0*1.1}}
		},
		state_stun_attack={{{1,10},{10,35},{20,40},{21,41}},{{1,18},{20,18}}},
--		state_hurt_attack={{{1,1},{20,30}},{{1,10},{20,100}}},
		skill_cost_v={{{1,20},{20,50}}},
	--	attackrating_p={{{1,50},{20,100}}},
		addskilldamagep={171, {{1,2},{20,30},{21,35}},1},
		--addskilldamagep2={173, {{1,2},{20,30},{21,35}}},
	},
	taiyizhenqi={ --太一真气
		--autoskill={{{1,39},{2,39}},{{1,1},{10,10}}},
		ignoreattackontime={{{1,18*12},{10,18*6},{13,18*5}}, {{1,18*0.5},{10,18*0.5}}},
		skill_statetime={{{1,-1},{2,-1}}}
	},
	taiyizhenqi_child={ --太一真气
		ignoreskill={{{1,100},{10,100},{11,100}},0,{{1,3},{2,3}}},
		state_hurt_ignore={1},
		state_slowall_ignore={1},
		state_stun_ignore={1},
		state_fixed_ignore={1},
		skill_statetime={{{1,18},{2,18}}},
	},
	qixingjue={ --七星诀
		attackratingenhance_p={{{1,30},{20,100},{21,105}}},
		adddefense_v={{{1,50},{20,300},{21,315}}},
		--skill_cost_v={{{1,2},{20,25}}},
	},
	qixingjue_team={ --七星诀
		attackratingenhance_p={{{1,20},{20,50},{22,55}}},
		adddefense_v={{{1,25},{20,150},{22,165}}},
	},
	renjianheyi={ --人剑合一
		appenddamage_p= {{{1,35*nS01},{10,35},{20,35*nS20},{21,35*nS20*nA0}}},
		physicsenhance_p={{{1,80*nS01},{10,80},{20,80*nS20},{21,80*nS20*nA0}}},
		lightingdamage_v={
			[1]={{1,350*0.9*nS01},{10,350*0.9},{20,350*0.9*nS20},{21,350*0.9*nS20*nA0}},
			[3]={{1,350*1.1*nS01},{10,350*1.1},{20,350*1.1*nS20},{21,350*1.1*nS20*nA0}}
			},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		skill_cost_v={{{1,50},{20,100},{21,100}}},
		state_stun_attack={{{1,12},{10,25},{20,35}},{{1,18},{20,18}}},
		state_hurt_attack={{{1,10},{20,15}},{{1,18},{20,18}}},
		skill_startevent={{{1,172},{20,172}}},
		skill_showevent={{{1,1},{20,1}}},
		missile_hitcount={{{1,3},{10,4},{20,5},{21,5}}},
	},
	taijijianyi={ --太极剑意，人剑合一第二式
		state_stun_attack={{{1,10},{10,35},{20,40}},{{1,18},{20,18}}},
		missile_hitcount={{{1,3},{10,4},{20,5},{21,5}}},
	},
	xuanyiwuxiang={ --玄一无象，人剑合一第三式
		seriesdamage_r={0},--={{{1,20},{20,120}}},
		lightingdamage_v={
			[1]={{1,10},{20,1000}},
			[3]={{1,10},{20,1000}}
		},
	},
	jianqizongheng={ --剑气纵横_20
	--	state_hurt_attackrate={{{1,10},{20,100}}},
		state_stun_attackrate={{{1,5},{20,50},{21,52}}},
		state_slowall_resistrate={{{1,10},{10,100},{20,150},{21,157}}},
		attackspeed_v={{{1,6},{20,16},{23,19},{24,19}}},
		manamax_p={{{1,25},{10,45},{20,55},{21,57}}},
		skill_statetime={{{1,-1},{2,-1}}}
	},
	taijijianfa={ --太极剑法
		skilldamageptrim={{{1,1},{10,10}}},
		skillselfdamagetrim={{{1,1},{10,10}}},
		--state_hurt_attacktime={{{1,10},{20,135}}},
		state_stun_attacktime={{{1,10},{10,80}}},
		state_slowall_resisttime={{{1,10},{10,120}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	
	liuxingganyue={ --中级秘籍：流星赶月
		appenddamage_p= {{{1,140*0.7},{10,140},{11,140*nA0}}},
		seriesdamage_r={0},--={{{1,100},{10,250},{11,250}}},
		physicsenhance_p={{{1,125*0.7},{10,125},{11,125*nA0}}},
		lightingdamage_v={
			[1]={{1,1000*0.9*0.7},{10,1000*0.9},{11,1000*0.9*nA0}},
			[3]={{1,1000*1.1*0.7},{10,1000*1.1},{11,1000*1.1*nA0}}
		},
		state_fixed_attack={{{1,35},{10,85},{12,90}},{{1,18*2},{20,18*2}}},
		skill_cost_v={{{1,50},{10,100},{11,100}}},
		skill_mintimepercast_v={{{1,6*18},{10,6*18},{11,6*18}}},
		skill_mintimepercastonhorse_v={{{1,6*18},{10,6*18},{11,6*18}}},
		missile_hitcount={{{1,3},{2,3}}},
		skill_skillexp_v=FightSkill.tbParam.tbMidBookSkillExp,
	},
	liuxingganyue_child={ --中级秘籍：流星赶月
		appenddamage_p= {{{1,30*0.7},{10,30},{11,30*nA0}}},
		seriesdamage_r={0},--={{{1,100},{10,250},{11,250}}},
		physicsenhance_p={{{1,30*0.7},{10,30},{11,30*nA0}}},
		lightingdamage_v={
			[1]={{1,350*0.9*0.7},{10,350*0.9},{11,350*0.9*nA0}},
			[3]={{1,350*1.1*0.7},{10,350*1.1},{11,350*1.1*nA0}}
		},
		state_fixed_attack={{{1,35},{10,85},{12,90}},{{1,18*2},{20,18*2}}},
		skill_cost_v={{{1,50},{10,100},{11,100}}},
		missile_hitcount={{{1,2},{2,2}}},
	},
	liuxingganyue_child2={ --中级秘籍：流星赶月
		state_hurt_ignore={1},
		state_slowall_ignore={1},
		state_stun_ignore={1},
		state_fixed_ignore={1},
		attackspeed_v={{{1,20},{10,100},{11,100}}},
		skill_statetime={{{1,18*1.5},{2,18*1.5}}},
	},
	
	mizhonghuanying={ --迷踪幻影
		ignoreskill={{{1,2},{10,20},{11,21}},0,{{1,6},{2,6}}},
		--steallifeenhance_p={{{1,4},{10,4}},{{1,100},{10,100}}},
		--stealmanaenhance_p={{{1,4},{10,4}},{{1,100},{10,100}}},
		addedwith_enemycount={{{1,1185},{10,1185}},{{1,3},{10,10},{11,11},{12,11}}, {{1,1600},{10,1600}}},
		skill_statetime={{{1,-1},{2,-1}}}
	},
	mizhonghuanying_child={ --迷踪幻影子
		ignoreskill={{{1,4},{10,4}},0,{{1,6},{2,6}}},
		steallifeenhance_p={{{1,4},{10,4}},{{1,100},{10,100}}},
		stealmanaenhance_p={{{1,4},{10,4}},{{1,100},{10,100}}},
		skill_statetime={{{1,18*2},{2,18*2}}},
	},
	jianwuadvancedbook={ --剑武高级秘籍_10
		appenddamage_p= {{{1,55*0.7},{10,55},{14,55*1.2}}},
		physicsenhance_p={{{1,125*0.7},{10,125},{14,125*1.2}}},
		lightingdamage_v={
			[1]={{1,550*0.9*0.7},{10,550*0.9},{14,550*0.9*1.2}},
			[3]={{1,550*1.1*0.7},{10,550*1.1},{14,550*1.1*1.2}}
			},
		seriesdamage_r={0},--={{{1,250},{10,250}}},
		skill_cost_v={{{1,1000},{10,1000}}},
		skill_mintimepercast_v={{{1,60*18},{10,60*18}}},
		skill_mintimepercastonhorse_v={{{1,60*18},{10,60*18}}},
		skill_skillexp_v=FightSkill.tbParam.tbHighBookSkillExp,
	},
	jianwuadvancedbook_fellow={ --剑武高级秘籍_10
		skill_maxmissile={{{1,3},{10,3}}},
	},
	jianwu120={ --剑武120_10
		appenddamage_p= {{{1,88*0.7},{10,88},{14,88*1.2}}},
		physicsenhance_p={{{1,200*0.7},{10,200},{14,200*1.2}}},
		lightingdamage_v={
			[1]={{1,880*0.9*0.7},{10,880*0.9},{14,880*0.9*1.2}},
			[3]={{1,880*1.1*0.7},{10,880*1.1},{14,880*1.1*1.2}}
			},
		seriesdamage_r={0},--={{{1,250},{10,250}}},
		skill_mintimepercast_v={{{1,3*18},{10,3*18}}},
		skill_mintimepercastonhorse_v={{{1,3*18},{10,3*18}}},
		--autoskill={{{1,61},{2,61}},{{1,1},{10,10}}},
		--skill_statetime={{{1,180*18},{2,180*18}}},
		skill_cost_v={{{1,300},{10,300}}},
		missile_hitcount={{{1,5},{2,5}}},
	},
	jianwu120_child={ --剑武120_子
		appenddamage_p= {{{1,33*0.7},{10,33},{14,33*1.2}}},
		physicsenhance_p={{{1,75*0.7},{10,75},{14,75*1.2}}},
		lightingdamage_v={
			[1]={{1,330*0.9*0.7},{10,330*0.9},{14,330*0.9*1.2}},
			[3]={{1,330*1.1*0.7},{10,330*1.1},{14,330*1.1*1.2}}
			},
		seriesdamage_r={0},--={{{1,250},{10,250}}},
		
		autoskill={{{1,77},{2,77}},{{1,1},{10,10}}},
		skill_statetime={{{1,7*18},{2,7*18}}},
		missile_hitcount={{{1,5},{2,5}}},
		skill_maxmissile={{{1,2},{10,2}}},
	},
	jianwu120_child2={ --剑武120_子子_10
		fastwalkrun_p={{{1,-1},{10,-5},{11,-5}}},
		allseriesstateresisttime={{{1,-5},{10,-25},{13,-25}}},
		superposemagic={{{1,2},{10,20},{11,21}}},
		skill_statetime={{{1,5*18},{2,5*18}}},
	},
}

FightSkill:AddMagicData(tb)

local tbSkill	= FightSkill:GetClass("liangyixinfa");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbChildInfo2	= KFightSkill.GetSkillInfo(tbChildInfo.tbEvent.nStartSkillId, tbChildInfo.tbEvent.nLevel);
	local szMsg	= string.format("<color=orange>纯阳无极<color>被破盾时触发几率：<color=gold>%d%%<color>\n攻击会心一击值：<color=gold>%d<color>，持续<color=Gold>%s秒<color>\n<color=gold>无敌%s秒<color>\n触发间隔时间：<color=Gold>%s秒<color>",
		tbAutoInfo.nPercent,
		tbChildInfo.tbWholeMagic["deadlystrikeenhance_r"][1],
		FightSkill:Frame2Sec(tbChildInfo.nStateTime),
		FightSkill:Frame2Sec(tbChildInfo2.nStateTime),
		FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime));
	return szMsg;
end;

local tbSkill	= FightSkill:GetClass("qiwuadvancedbook");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local szMsg = ""
	szMsg = szMsg.."被击中时<color=gold>"..tbAutoInfo.nPercent.."%<color>几率自动释放：\n";
	szMsg = szMsg.."    <color=green>游龙八卦掌<color>\n";
	local tbMsg = {};
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0);
	for i=1, #tbMsg do
		szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	return szMsg;
end;

--[[
local tbSkill	= FightSkill:GetClass("jianwu120");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbAutoInfo2	= KFightSkill.GetAutoInfo(tbChildInfo.tbWholeMagic["autoskill"][1], tbChildInfo.tbWholeMagic["autoskill"][2]);
	local tbChildInfo2	= KFightSkill.GetSkillInfo(tbAutoInfo2.nSkillId, tbAutoInfo2.nSkillLevel);
	local szMsg = ""
	szMsg = szMsg.."使曾经靠近过自己的敌人在接下来的<color=Gold>"..FightSkill:Frame2Sec(tbChildInfo.nStateTime).."秒<color>内,每<color=Gold>"..FightSkill:Frame2Sec(tbAutoInfo2.nPerCastTime).."秒<color>获得：\n";
	szMsg = szMsg.."    <color=green>云海迷茫<color>\n";
	local tbMsg = {};
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo2, 0);
	for i=1, #tbMsg do
		szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	--szMsg = szMsg.."\n触发间隔：<color=Gold>"..FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime).."秒<color>";
	return szMsg;
end;]]

local tbSkill	= FightSkill:GetClass("jianwu120_child");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local szMsg = ""	
	local tbMsg = {};
	szMsg = szMsg.."同时向敌人追加以下状态：\n";
	szMsg = szMsg.."    每秒自动获得<color=green>[云遮雾绕]<color>\n";
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0);
	for i=1, #tbMsg do
		szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	--szMsg = szMsg.."\n触发间隔：<color=Gold>"..FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime).."秒<color>";
	return szMsg;
end;

local tbSkill = FightSkill:GetClass("qiwu120")

function tbSkill:GetExtraDesc(tbInfo)
	if (not tbInfo) then
		return "";
	end
	local tbChildInfo	= KFightSkill.GetSkillInfo(1666, tbInfo.nLevel);
	local szMsg = ""	
	local tbMsg = {};
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0);
	szMsg = szMsg.."\n"
	szMsg = szMsg.."击中每个目标时释放：\n";
	szMsg = szMsg.."<color=green>[归宗剑] "..tbInfo.nLevel.."级<color>\n";
	for i=1, #tbMsg do
		szMsg = szMsg..""..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	return szMsg;
end

local tbSkill	= FightSkill:GetClass("taijiwuyi");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbAutoInfo2	= KFightSkill.GetAutoInfo(tbChildInfo.tbWholeMagic["autoskill"][1], tbChildInfo.tbWholeMagic["autoskill"][2]);
	local tbChildInfo2	= KFightSkill.GetSkillInfo(tbAutoInfo2.nSkillId, tbAutoInfo2.nSkillLevel);
	local tbMsg = {};
	local szMsg = ""
	szMsg = szMsg.."攻击命中后<color=gold>"..FightSkill:Frame2Sec(tbChildInfo.nStateTime).."秒内<color>每秒回复<color=green>[万剑归宗]<color>可用次数<color=gold>"..(tbChildInfo2.tbWholeMagic["recover_usepoint"][2]/100).."<color>"
	return szMsg;
end;

local tbSkill	= FightSkill:GetClass("taijiwuyi_child");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local szMsg = ""	
	local tbMsg = {};
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0);
	szMsg = szMsg.."\n每：<color=Gold>"..FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime).."秒<color>自动对自身释放\n";
	for i=1, #tbMsg do
		szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	--szMsg = szMsg.."\n触发间隔：<color=Gold>"..FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime).."秒<color>";
	return szMsg;
end;
