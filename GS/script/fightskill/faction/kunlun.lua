Require("\\script\\fightskill\\fightskill.lua")
local nA0 = FightSkill.tbParam.nSadd;	--攻速类攻击技能+1的成长系数
local nA1 = FightSkill.tbParam.nSadd1;	--格斗类攻击技能+1的成长系数
local nS01 = FightSkill.tbParam.nS1;	--技能1级的数值系数
local nS20 = FightSkill.tbParam.nS20;	--技能20级的数值系数

--昆仑
local tb	= {
	--刀昆
	hufengfa={ --呼风法_20
		appenddamage_p= {{{1,100},{20,100},{21,100*nA0}}},
		seriesdamage_r={0},--={{{1,50},{20,100},{21,100}}},
		physicsenhance_p={{{1,5},{10,50},{20,100},{21,100*nA0}}},
		lightingdamage_v={
			[1]={{1,80*0.85},{10,260*0.9},{20,460*0.9},{21,460*nA0*0.9}},
			[3]={{1,80*1.15},{10,260*1.1},{20,460*1.1},{21,460*nA0*1.1}}
		},
	--	state_hurt_attack={{{1,5},{20,20}},{{1,30},{20,150}}},
		state_stun_attack={{{1,15},{10,35},{20,40},{21,41}},{{1,18},{20,18}}},
		skill_cost_v={{{1,2},{20,20},{21,20}}},
	--	attackrating_p={{{1,30},{20,80}}},
		addskilldamagep={178, {{1,2},{20,30},{21,35}},1},
		addskilldamagep2={181, {{1,2},{20,10},{21,12}},1},
		addskilldamagep3={182, {{1,2},{20,10},{21,12}}},
	},
	kunlundaofa={ --昆仑刀法_10
		addphysicsdamage_p={{{1,10},{10,105},{11,115}}},
		attackratingenhance_p={{{1,50},{10,150},{11,165}}},
		deadlystrikeenhance_r={{{1,30},{10,50},{11,55}}},
		attackspeed_v={{{1,5},{10,15},{11,16},{12,17},{13,17}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	qingfengfu={ --清风符_20
		fastwalkrun_p={{{1,10},{20,40},{21,41}}},
		state_slowall_resisttime={{{1,10},{20,135},{21,141}}},
		skill_mintimepercast_v={{{1,15*18},{10,15*18}}},
		skill_mintimepercastonhorse_v={{{1,15*18},{10,15*18}}},
		skill_cost_v={{{1,100},{20,250}}},
		skill_statetime={300*18},
	},
	qingfengfu_ally={ --清风符_友方
		fastwalkrun_p={{{1,10},{20,20},{21,21}}},
		skill_statetime={300*18},
	},
	kuangfengzhoudian={ --狂风骤电_20
		appenddamage_p= {{{1,85},{20,85},{21,85*nA0}}},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		physicsenhance_p={{{1,50},{10,100},{20,120},{21,120*nA0}}},
		lightingdamage_v={
			[1]={{1,515*0.9},{10,560*0.9},{20,610*0.95},{21,610*nA0*0.95}},
			[3]={{1,515*1.1},{10,560*1.1},{20,610*1.05},{21,610*nA0*1.05}}
		},
	--	state_hurt_attack={{{1,5},{20,20}},{{1,30},{20,150}}},
		state_stun_attack={{{1,15},{10,35},{20,40},{21,41}},{{1,18},{20,18}}},
		skill_cost_v={{{1,20},{20,50},{21,50}}},
	--	attackrating_p={{{1,50},{20,100}}},
		addskilldamagep={181, {{1,2},{20,30},{21,35}},1},
		addskilldamagep2={182, {{1,2},{20,30},{21,35}}},
		missile_hitcount={{{1,5},{10,5},{20,5},{21,5}}},
		missile_speed_v={40},
	},
	kaishenshu={ --开神术_10
		prop_showhide={1},
		skill_statetime={{{1,18*30},{10,18*60*1.5},{11,18*93}}},
		skill_cost_v={{{1,200},{10,300}}},
		skill_mintimepercast_v={{{1,5*60*18},{10,3*60*18},{11,171*18}}},
		skill_mintimepercastonhorse_v={{{1,5*60*18},{10,3*60*18},{11,171*18}}},
	},
	juyuanshu={ --聚元术
		lifemax_p={{{1,10},{10,70},{11,72}}},
		skill_statetime={300*18},
	},
	xuantianwuji={	--玄天无极_10
		--dynamicmagicshield_v={{{1,50},{10,200},{11,210}},40},
		dynamicmagicshieldbymaxhp_p={{{1,15},{10,40},{11,42}},40},
		damage_return_receive_p={{{1,-10},{10,-45},{13,-52}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	yiqisanqing={ --一气三清
		addphysicsdamage_p={{{1,15},{20,200},{21,210}}},
		attackratingenhance_p={{{1,20},{20,100},{21,105}}},
		skill_mintimepercast_v={{{1,15*18},{10,15*18}}},
		skill_mintimepercastonhorse_v={{{1,15*18},{10,15*18}}},
		skill_cost_v={{{1,100},{20,300},{21,300}}},
		skill_statetime={300*18},
	},
	yiqisanqing_ally={ --一气三清
		addphysicsdamage_p={{{1,10},{20,100}}},
		skill_statetime={300*18},
	},
	aoxuexiaofeng={ --傲雪啸风
		appenddamage_p= {{{1,65*nS01},{10,65},{20,65*nS20},{21,65*nS20*nA0}}},
		physicsenhance_p={{{1,100*nS01},{10,100},{20,100*nS20},{21,100*nS20*nA0}}},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		skill_cost_v={{{1,50},{20,100},{21,100}}},
		state_stun_attack={{{1,15},{10,35},{20,40}},{{1,18},{20,18}}},
		--skill_collideevent={{{1,182},{20,182}}},
		--skill_showevent={{{1,4},{20,4}}},
		missile_hitcount={{{1,5},{10,5},{20,5},{21,5}}},
		missile_speed_v={40},
	},
	xiaofengsanlianji={ --啸风三连击，傲雪啸风第二式
		appenddamage_p= {{{1,20*nS01},{10,20},{20,20*nS20},{21,20*nS20*nA0}}},
		physicsenhance_p={{{1,30*nS01},{10,30},{20,30*nS20},{21,30*nS20*nA0}}},
		lightingdamage_v={
			[1]={{1,375*0.9*nS01},{10,375*0.9},{20,375*0.9*nS20},{21,375*0.9*nS20*nA0}},
			[3]={{1,375*1.1*nS01},{10,375*1.1},{20,375*1.1*nS20},{21,375*1.1*nS20*nA0}}
			},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		skill_cost_v={{{1,50},{20,100},{21,100}}},
		missile_hitcount={{{1,2},{10,3},{20,3}}},
	},
	tianqingdizhuo={ --天清地浊_20
	--	state_hurt_attackrate={{{1,10},{20,100}}},
		state_stun_attackrate={{{1,10},{20,100}}},
		state_slowall_resistrate={{{1,10},{10,100},{20,150}}},
		attackspeed_v={{{1,10},{10,16},{20,26},{23,29},{24,29}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	shuangaokunlun={ --霜傲昆仑
		skilldamageptrim={{{1,1},{10,10}}},
		skillselfdamagetrim={{{1,1},{10,10}}},
	--	state_hurt_attacktime={{{1,10},{20,135}}},
		state_stun_attacktime={{{1,10},{10,80}}},
		state_slowall_resisttime={{{1,10},{10,120}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	
	liangyizhenqi={ --中级秘籍：两仪真气
		addenchant={12, {{1,1}, {2, 2}}},
		autoskill={{{1,30},{2,30}},{{1,1},{10,10}}},
		skill_skillexp_v=FightSkill.tbParam.tbMidBookSkillExp,
		skill_statetime={{{1,-1},{2,-1}}},
		--{szMagicName = "addmissilespeed", tbValue = {178, 0, {{1,2}, {10, 6}}}},
		--{szMagicName = "addmissilespeed", tbValue = {181, 0, {{1,2}, {10, 6}}}},
		--{szMagicName = "autoskill", tbValue = {{{1,30},{2,30}},{{1,1},{10,10}}}},
		--{szMagicName = "skill_statetime", tbValue = {{{1,-1},{2,-1}}}},
		--{szMagicName = "skill_skillexp_v", tbValue = FightSkill.tbParam.tbMidBookSkillExp},
	},
	liangyizhenqi_child={ --中级秘籍：两仪真气
		redeivedamage_dec_p2={{{1,200},{10,200},{11,200}}},
		fastwalkrun_p={{{1,10},{10,30},{11,30}}},
		skill_statetime={{{1,18*2},{10,18*5},{11,18*5}}},
	},
	liangyizhenqi_child2={ --中级秘籍：两仪真气
		state_knock_attack={{{1,65},{10,100},{11,100}},{{1,10},{10,15},{11,15}},{{1,32},{2,32}}},
		missile_hitcount={{{1,3},{2,3}}},
	},
	
	wurenwuwo={ --无人无我_10
		ignoredefenseenhance_v={{{1,50},{10,200},{11,210}}},
		state_stun_resisttime={{{1,60},{10,160},{11,168}}},
	},
	wurenwuwo_team={ --无人无我
		ignoredefenseenhance_v={{{1,38},{10,150},{12,165}}},
		state_stun_resisttime={{{1,45},{10,120},{11,126}}},
	},
	daokunadvancedbook={ --刀昆高级秘籍_10
		skilldamageptrim	={{{1,-1.5},{10,-15},{11,-16}}},
		skillselfdamagetrim	={{{1,-1.5},{10,-15},{11,-16}}},
		
		skill_cost_v={{{1,150},{10,150}}},
		skill_mintimepercast_v={{{1,1*18},{10,1*18}}},
		skill_mintimepercastonhorse_v={{{1,1*18},{10,1*18}}},
		skill_skillexp_v=FightSkill.tbParam.tbHighBookSkillExp,
		skill_missilenum_v={{{1,8},{10,8}},1},
		skill_maxmissile={{{1,4*8},{10,4*8}}},
		skill_statetime={{{1,18*1},{10,18*1}}},
	},
	daokunadvancedbook_child={ --刀昆高级秘籍子_10
		skilldamageptrim	={{{1,1.5},{10,15},{11,16}}},
		skillselfdamagetrim	={{{1,1.5},{10,15},{11,16}}},
		skill_statetime={{{1,18*1},{10,18*1}}},
	},
	daokun120={ --刀昆120_10
		autoskill={{{1,62},{2,62}},{{1,1},{10,10}}},
		autoskill2={{{1,133},{2,133}},{{1,1},{10,10}}},
		--addstartskill={182, 1660, {{1,1}, {10, 10}}},
		skill_statetime={{{1,-1},{10,-1}}},
	},
	daokun120_child={ --刀昆120_子2拉回_10
		state_drag_attack={{{1,35},{10,85},{11,90}},{{1,11},{10,11}},{{1,32},{2,32}}},
		ignoreskill={{{1,35},{10,75},{12,80}},{{1,1},{10,3},{11,3}},1},
		missile_drag={1},
		skill_statetime={{{1,3*18},{10,3*18}}},
	},
	daokun120_child2={ --刀昆120_子子10
		missile_random={{{1,5},{10,5},{11,5}},{{1,0},{10,0}}},
		--skill_statetime={{{1,-1},{10,-1}}},
	},
		

	--剑昆
	kuangleizhendi={ --狂雷震地_20
		appenddamage_p= {{{1,100},{20,100},{21,100*nA0}}},
		lightingdamage_v={
			[1]={{1,80*0.8},{10,215*0.9},{20,500*0.9},{21,500*nA0*0.9}},
			[3]={{1,80*1.2},{10,215*1.1},{20,500*1.1},{21,500*nA0*1.1}}
		},
		state_stun_attack={{{1,15},{10,30},{20,35},{21,36}},{{1,18},{20,18}}},
		seriesdamage_r={0},--={{{1,50},{20,100},{21,100}}},
		skill_cost_v={{{1,20},{20,50},{21,50}}},
		missile_hitcount={{{1,5},{10,5}}},
		addskilldamagep={190, {{1,2},{20,30},{21,35}},1},
		addskilldamagep2={234, {{1,2},{20,30},{21,35}}},
		addskilldamagep3={192, {{1,2},{20,10},{21,12}},1},
		missile_range={1,0,1},
	},
	kunlunjianfa={ --昆仑剑法_10
		addlightingmagic_v={{{1,5},{10,350},{11,385}}},
		deadlystrikeenhance_r={{{1,30},{10,50},{11,55}}},
		castspeed_v={{{1,5},{10,15},{11,16},{12,17},{13,17}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	tianjixunlei={ --天际迅雷_20
		appenddamage_p= {{{1,45},{20,45},{21,45*nA0}}},
		lightingdamage_v={
			[1]={{1,800*0.8},{10,1115*0.9},{20,1465*0.9},{21,1465*nA0*0.9}},
			[3]={{1,800*1.2},{10,1115*1.1},{20,1465*1.1},{21,1465*nA0*1.1}}
		},
		state_stun_attack={{{1,15},{10,30},{20,40},{21,41}},{{1,18},{20,18}}},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		skill_cost_v={{{1,50},{20,150},{21,150}}},
		missile_hitcount={{{1,3},{10,3}}},
		addskilldamagep={192, {{1,2},{20,30},{21,35}},1},
		skill_mintimepercast_v={2*18},
		skill_mintimepercastonhorse_v={2*18},
	},
	tianjixunlei_child={ --天际迅雷子
		appenddamage_p= {{{1,45},{20,45},{21,45*nA0}}},
		lightingdamage_v={
			[1]={{1,800*0.8},{10,1115*0.9},{20,1465*0.9},{21,1465*nA0*0.9}},
			[3]={{1,800*1.2},{10,1115*1.1},{20,1465*1.1},{21,1465*nA0*1.1}}
		},
		state_stun_attack={{{1,15},{10,30},{20,40}},{{1,18},{20,18}}},
		missile_hitcount={{{1,2},{10,2}}},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		missile_range={3,0,3},
	},
	zuixiancuogu={ --醉仙错骨_10
		state_stun_attack={{{1,35},{10,60},{11,61}},{{1,18*1},{10,18*2},{11,18*2.1}}},
		missile_hitcount={{{1,3},{10,5},{11,5},{12,5}}},
		skill_cost_v={{{1,50},{10,100},{20,100}}},
		skill_mintimepercast_v={{{1,60*18},{10,30*18},{11,28.5*18}}},
		skill_mintimepercastonhorse_v={{{1,60*18},{10,30*18},{11,28.5*18}}},
	},
	daoguxianfeng={ --道骨仙风_20
		damage_physics_resist={{{1,20},{20,150},{21,157}}},
		damage_cold_resist={{{1,20},{20,150},{21,157}}},
		damage_fire_resist={{{1,20},{20,150},{21,157}}},
		damage_light_resist={{{1,20},{20,150},{21,157}}},
		skill_mintimepercast_v={{{1,15*18},{10,15*18}}},
		skill_mintimepercastonhorse_v={{{1,15*18},{10,15*18}}},
		skill_cost_v={{{1,200},{20,300},{21,300}}},
		skill_statetime={300*18},
	},
	daoguxianfeng_ally={ --道骨仙风
		damage_physics_resist={{{1,10},{20,60},{21,63}}},
		damage_cold_resist={{{1,10},{20,60},{21,63}}},
		damage_fire_resist={{{1,10},{20,60},{21,63}}},
		damage_light_resist={{{1,10},{20,60},{21,63}}},
		skill_statetime={300*18},
	},
	leidongjiutian={ --雷动九天
		appenddamage_p= {{{1,175*nS01},{10,175},{20,175*nS20},{21,175*nS20*nA0}}},
		lightingdamage_v={
			[1]={{1,2250*0.9*nS01},{10,2250*0.9},{20,2250*0.9*nS20},{21,2250*0.9*nS20*nA0}},
			[3]={{1,2250*1.1*nS01},{10,2250*1.1},{20,2250*1.1*nS20},{21,2250*1.1*nS20*nA0}}
			},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		state_stun_attack={{{1,15},{10,30},{20,40}},{{1,36},{20,36}}},
		skill_cost_v={{{1,150},{20,300},{21,300}}},
		skill_mintimepercast_v={{{1,5*18},{10,5*18}}},
		skill_mintimepercastonhorse_v={{{1,5*18},{10,5*18}}},
		missile_hitcount={{{1,5},{10,7},{20,9},{21,9}}},
	},
	wuleizhengfa={ --五雷正法
		state_stun_attackrate={{{1,10},{20,100}}},
		state_slowall_resistrate={{{1,10},{10,100},{20,150}}},
		castspeed_v={{{1,10},{10,16},{20,26},{23,29},{24,29}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	hunyuanqiankun={ --混元乾坤
		skilldamageptrim={{{1,1},{10,10}}},
		skillselfdamagetrim={{{1,1},{10,10}}},
		state_stun_attacktime={{{1,10},{10,80}}},
		state_slowall_resisttime={{{1,10},{10,120}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	
	huasuiwuyi={ --中级秘籍：化髓无意
		addenchant={13, {{1,1}, {2, 2}}},
		lifemax_p={{{1,10},{10,50},{12,60}}},
		--addmissiledamagerange={234, {{1,1}, {10, 2}}},
		skill_skillexp_v=FightSkill.tbParam.tbMidBookSkillExp,
		skill_statetime={{{1,-1},{2,-1}}},
		--{szMagicName = "addmissiledamagerange", tbValue = {234, {{1,1}, {10, 2}}}},
		--{szMagicName = "decreaseskillcasttime", tbValue = {190, {{1,9}, {10, 18}}}},
		--{szMagicName = "decreaseskillcasttime", tbValue = {699, {{1,18}, {10, 18*10}}}},
		--{szMagicName = "lifemax_p", tbValue = {{{1,10},{10,50}}}},
		--{szMagicName = "skill_statetime", tbValue = {{{1,-1},{2,-1}}}},
		--{szMagicName = "skill_skillexp_v", tbValue = FightSkill.tbParam.tbMidBookSkillExp},
	},
	
	leitingjue={ --雷霆诀
		defencedeadlystrikedamagetrim={{{1,-10},{10,-20},{11,-21}}},
		state_stun_resisttime={{{1,-60},{10,-160},{11,-168}}},
		lifereplenish_p={{{1,-5},{10,-15},{11,-16}}},
		manareplenish_p={{{1,-5},{10,-10},{11,-11}}},
		missile_hitcount={{{1,7},{10,7}}},
		--skill_showevent={{{1,1},{20,1}}},
	},

	leitingjue_self={ --雷霆诀_自身
		addenchant={26, {{1,1}, {2, 2}}},
		skill_statetime={{{1,5*18},{2,5*18}}},
	},
	jiankunadvancedbook={ --剑昆高级秘籍_10
		state_float_attack={{{1,15},{10,85},{12,90}},{{1,7*18},{10,7*18}}},
		damage_all_resist={{{1,-50},{10,-200},{11,-210}}},
		missile_hitcount={{{1,5},{10,5}}},
		skill_cost_v={{{1,300},{10,300}}},
		skill_mintimepercast_v={{{1,45*18},{10,45*18}}},
		skill_mintimepercastonhorse_v={{{1,45*18},{10,45*18}}},
		skill_statetime={{{1,15*18},{10,15*18}}},
		skill_skillexp_v=FightSkill.tbParam.tbHighBookSkillExp,
	},
	jiankun120={ --剑昆120_10
		autoskill={64, {{1,1}, {2, 2}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	jiankun120_child={ --剑昆120_子_10
		redeivedamage_dec_p2={{{1,1},{10,3},{11,3}}},
		deadlystrikeenhance_r={{{1,3},{10,30},{11,30}}},
		superposemagic={{{1,6},{10,15},{11,16}}},
		skill_statetime={{{1,3*18},{10,3*18}}},
	},

	--辅助昆
	baidubuqin={ --百毒不侵
		damage_poison_resist={{{1,10},{20,100}}},
		skill_cost_v={{{1,15},{20,25}}},
		skill_statetime={{{1,18*180},{20,18*300}}},
	},
	xukongshanying={ --虚空闪影
		adddefense_v={{{1,20},{10,100},{20,200}}},
		skill_cost_v={{{1,15},{20,20}}},
		skill_statetime={{{1,18*180},{20,18*300}}},
	},
	qihanaoxue={ --欺寒傲雪
		damage_cold_resist={{{1,10},{20,100}}},
		skill_cost_v={{{1,10},{20,60}}},
		skill_statetime={{{1,18*180},{20,18*300}}},
	},
	zhenhuokangli={ --真火抗力
		damage_fire_resist={{{1,10},{20,100}}},
		skill_cost_v={{{1,80},{20,100}}},
		skill_statetime={{{1,18*180},{20,18*300}}},
	},
	jingangbupo={ --金刚不破
		damage_physics_resist={{{1,20},{20,150}}},
		skill_cost_v={{{1,100},{20,150}}},
		skill_statetime={{{1,18*180},{20,18*300}}},
	},
}

FightSkill:AddMagicData(tb)

local tbSkill = FightSkill:GetClass("aoxuexiaofeng")

function tbSkill:GetExtraDesc(tbInfo)
	if (not tbInfo) then
		return "";
	end
	local tbChildInfo	= KFightSkill.GetSkillInfo(182, tbInfo.nLevel);
	local szMsg = ""	
	local tbMsg = {};
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0);
	szMsg = szMsg.."\n"
	szMsg = szMsg.."击中每个目标时释放：\n";
	szMsg = szMsg.."<color=green>[啸风三连击] "..tbInfo.nLevel.."级<color>\n";
	for i=1, #tbMsg do
		szMsg = szMsg..""..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	return szMsg;
end

local tbSkill	= FightSkill:GetClass("liangyizhenqi");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbCCInfo	= KFightSkill.GetSkillInfo(tbChildInfo.tbEvent.nStartSkillId, tbChildInfo.tbEvent.nLevel);
	local szMsg	= string.format("\n<color=green>子招式<color>\n生命降到25%%时触发几率：<color=gold>%d%%<color>\n最多同时影响目标：<color=gold>%d个<color>\n造成击退的几率：<color=gold>%s%%<color>，击退距离<color=gold>%s<color>\n自身移动速度：<color=gold>增加%s%%<color>\n受到五行伤害：<color=gold>缩小%s%%<color>\nThời gian duy trì: <color=gold>%s秒<color>\n触发间隔时间：<color=Gold>%s秒<color>",
		tbAutoInfo.nPercent,
		tbCCInfo.nMissileHitcount,
		tbCCInfo.tbWholeMagic["state_knock_attack"][1],
		tbCCInfo.tbWholeMagic["state_knock_attack"][2] * tbCCInfo.tbWholeMagic["state_knock_attack"][3],
		tbChildInfo.tbWholeMagic["fastwalkrun_p"][1],
		tbChildInfo.tbWholeMagic["redeivedamage_dec_p2"][1],
		FightSkill:Frame2Sec(tbChildInfo.nStateTime),
		FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime)
		);
	return szMsg;
end;

local tbSkill = FightSkill:GetClass("daokunadvancedbook")

function tbSkill:GetExtraDesc(tbInfo)
	if (not tbInfo) then
		return "";
	end
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbInfo.nId, tbInfo.nLevel,me,1);
	local tbCCInfo1		= KFightSkill.GetSkillInfo(tbChildInfo.tbEvent.nCollideSkillId, tbChildInfo.tbEvent.nLevel, me, 1)
	
	local szMsg	= string.format("\n技能命中敌人时自身获得以下效果：\n<color=green>两仪化形<color>\n    发挥基础攻击力：<color=Gold>提高%d%%<color>\n    发挥技能攻击力：<color=Gold>提高%d%%<color>",		
	tbCCInfo1.tbWholeMagic["skilldamageptrim"][1],
	tbCCInfo1.tbWholeMagic["skillselfdamagetrim"][1]
	);
	return szMsg;
end

local tbSkill	= FightSkill:GetClass("daokun120");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	--local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local szMsg = "";
	local szSkillName2 = FightSkill:GetSkillName(tbAutoInfo.nSkillId);
	szMsg = szMsg..string.format("每<color=Gold>%s秒<color>第一次攻击时<color=gold>%s%%<color>释放<color=green>[%s]<color>", 
										FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime),
										tbAutoInfo.nPercent,
										szSkillName2);
	return szMsg;
end;
function tbSkill:GetAutoDesc2(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbMsg = {};
	local szMsg = "";
	local szSkillName = FightSkill:GetSkillName(tbAutoInfo.nRelativeSkillId1);
	local szSkillName2 = FightSkill:GetSkillName(tbAutoInfo.nSkillId);
	szMsg = szMsg..string.format("<color=gold>%s<color>击中时有<color=gold>%s%%<color>几率释放<color=green>[%s]<color>\n",
										szSkillName,
										tbAutoInfo.nPercent,
										szSkillName2)
	szMsg = szMsg.."    <color=green>"..szSkillName2.."<color>\n";
	szMsg = szMsg.."    <color=gold>3秒<color>内每秒生效1次\n";
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0);
	for i=1, #tbMsg do
		szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	szMsg = string.gsub(szMsg, "无法获得", "    无法获得");
	return szMsg;
end;

local tbSkill	= FightSkill:GetClass("jiankun120");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbMsg = {};
	local szMsg = "";
	szMsg = szMsg.."被击中时<color=gold>"..tbAutoInfo.nPercent.."%<color>几率获得状态：\n";
	szMsg = szMsg.."    <color=green>积壤为岳<color>".."\n";
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0);
	for i=1, #tbMsg do
		szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	--szMsg = szMsg.."\n触发间隔：<color=Gold>"..FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime).."秒<color>";
	return szMsg;
end;
