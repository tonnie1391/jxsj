Require("\\script\\fightskill\\fightskill.lua")
local nA0 = FightSkill.tbParam.nSadd;	--攻速类攻击技能+1的成长系数
local nA1 = FightSkill.tbParam.nSadd1;	--格斗类攻击技能+1的成长系数
local nS01 = FightSkill.tbParam.nS1;	--技能1级的数值系数
local nS20 = FightSkill.tbParam.nS20;	--技能20级的数值系数

--明教
local tb	= {
	--锤明教
	kaitianshi={ --开天式_20
		appenddamage_p= {{{1,100},{20,100},{21,100*nA1}}},
		physicsenhance_p={{{1,5},{10,50},{20,80},{21,80*nA1}}},
		poisondamage_v={{{1,10},{10,82},{20,132},{21,132*nA1}},{{1,2*9},{20,2*9}}},
	--	attackrating_p={{{1,5},{20,15}}},
		skill_cost_v={{{1,2},{20,20},{21,20}}},
		state_hurt_attack={{{1,15},{10,30},{20,35},{21,36}},{{1,18},{20,18}}},
		state_weak_attack={{{1,15},{10,35},{20,40},{21,41}},{{1,36},{20,54},{21,54}}},
		seriesdamage_r={0},--={{{1,50},{20,100},{21,100}}},
		addskilldamagep={202, {{1,2},{20,10},{21,12}},1},
		addskilldamagep2={203, {{1,2},{20,10},{21,12}}},
	},
	mingjiaochuifa={ --明教锤法_10
		addphysicsdamage_p={{{1,5},{10,150},{11,165}}},
		attackratingenhance_p={{{1,50},{10,150},{11,165}}},
		deadlystrikeenhance_r={{{1,30},{10,50},{11,55}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	lieyanggong={ --烈阳功_20
		lifemax_p={{{1,25},{20,125},{21,130}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	yumashu={ --驭马术_20
		state_hurt_resisttime={{{1,15},{20,100},{21,105}}},
		state_slowall_resisttime={{{1,15},{20,100},{21,105}}},
		state_stun_resisttime={{{1,15},{20,100},{21,105}}},
		--state_slowrun_resisttime={{{1,15},{20,100}}},
		state_fixed_resisttime={{{1,15},{20,100},{21,105}}},
		damage_all_resist={{{1,15},{20,100},{21,105}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	pidishi={ --劈地势_20
		appenddamage_p= {{{1,75},{20,75},{21,75*nA1}}},
		physicsenhance_p={{{1,15},{10,60},{20,110},{21,110*nA1}}},
		poisondamage_v={{{1,500},{10,770},{20,970},{21,970*nA1}},{{1,1*9},{20,1*9}}},
	--	attackrating_p={{{1,5},{20,35}}},
		skill_cost_v={{{1,100},{20,250}}},
		state_slowall_attack={{{1,50},{10,75},{20,85}},{{1,18*2},{20,18*4.5}}},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		addskilldamagep={194, {{1,2},{20,30},{21,35}},1},
		addskilldamagep2={195, {{1,2},{20,30},{21,35}}},
		addskilldamagep3={202, {{1,2},{20,20},{21,25}},1},
		addskilldamagep4={203, {{1,2},{20,20},{21,25}}},
		skill_attackradius={520},
		skill_mintimepercast_v={18*10},
		skill_mintimepercastonhorse_v={18*10},
		missile_speed_v={80},
		missile_range={2,0,2},
		missile_hitcount={{{1,5},{20,5}}},
		state_fixed_attack={{{1,50},{10,75},{20,85}},{{1,18*2},{20,18*2}}},
	},
	pidishi_child={ --劈地势子子_20
		appenddamage_p= {{{1,75},{20,75},{21,75*nA1}}},
		physicsenhance_p={{{1,15},{10,60},{20,110},{21,110*nA1}}},
		poisondamage_v={{{1,500},{10,770},{20,970},{21,970*nA1}},{{1,1*9},{20,1*9}}},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		missile_hitcount={{{1,5},{20,5}}},
	},
	kunhuyunxiao={ --困虎云啸_10
		appenddamage_p= {{{1,100},{10,100},{11,100*nA1}}},
		physicsenhance_p={{{1,15},{10,72},{11,72*nA1}}},
		poisondamage_v={{{1,5},{10,100},{11,100*nA1}},{{1,6*9},{10,6*9}}},
		seriesdamage_r={0},--={{{1,100},{10,250},{11,250}}},
		skill_cost_v={{{1,10},{10,50},{11,50}}},
		skill_mintimepercast_v={{{1,3*18},{10,3*18}}},
		skill_mintimepercastonhorse_v={{{1,3*18},{10,3*18}}},
		state_hurt_attack={{{1,30},{10,75},{13,80}},{{1,18},{10,18}}},
	},
	jingetiema_team={ --金戈铁马
		deadlystrikeenhance_r={{{1,25},{10,75},{11,79}}},
		state_hurt_attackrate={{{1,10},{10,30},{11,32}}},
	},
	jingetiema={ --金戈铁马_20
		deadlystrikeenhance_r={{{1,50},{10,150},{11,158}}},
		state_hurt_attackrate={{{1,20},{10,60},{11,63}}},
	},
	longtunshi={ --龙吞式
		appenddamage_p= {{{1,80*nS01},{10,80},{20,80*nS20},{21,80*nS20*nA1}}},
		physicsenhance_p={{{1,100*nS01},{10,100},{20,100*nS20},{21,100*nS20*nA1}}},
		poisondamage_v={{{1,100*nS01},{10,100},{20,100*nS20},{21,100*nS20*nA1}},{{1,2*9},{20,2*9}}},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		skill_cost_v={{{1,27},{20,54},{21,54}}},
		state_hurt_attack={{{1,5},{10,10},{20,15}},{{1,18},{20,18}}},
		state_weak_attack={{{1,10},{10,20},{20,25}},{{1,36},{20,54},{21,54}}},
	},
	zhenyupotianjin={ --镇狱破天劲
		state_hurt_attackrate={{{1,10},{20,100}}},
		addphysicsdamage_p={{{1,20},{20,150}}},
		state_weak_attackrate={{{1,10},{20,100}}},
		state_stun_resistrate={{{1,10},{10,100},{20,150}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	kongjuexinfa={ --空绝心法
		skilldamageptrim={{{1,1},{10,10}}},
		skillselfdamagetrim={{{1,1},{10,10}}},
		--state_hurt_attacktime={{{1,10},{20,135}}},
		state_weak_attacktime={{{1,10},{10,80}}},
		state_stun_resisttime={{{1,10},{10,120}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	
	liuxingchui={ --中级秘籍：流星锤
		addflyskill={199, 1240, {{1,1}, {10, 10}}},
		addenchant={16, {{1,1}, {2, 2}}},
		--addskillcastrange={198, 0, {{1,12}, {10, 120}}},
		--addmissilespeed={791, 0, {{1,5}, {10, 20}}},
		--addmissilerange={791, {{1,1}, {10, 1}}},
		--addmissilethroughrate={791, {{1,10}, {10, 100}}},
		addpowerwhencol={791, {{1,50}, {10,50}, {12,55}}, {{1,50}, {10, 150}, {12, 165}}},
		--decreaseskillcasttime={198, {{1,18}, {10, 18*3}}},
		skill_skillexp_v=FightSkill.tbParam.tbMidBookSkillExp,
		skill_statetime={{{1,-1},{2,-1}}},
	},
	
	jiuxihunyang={ --九曦混阳_10
		autoskill={{{1,35},{2,35}},{{1,1},{10,10}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	jiuxihunyang_child={ --九曦混阳子
		state_hurt_ignore={1},
		state_slowall_ignore={1},
		state_stun_ignore={1},
		state_fixed_ignore={1},
		replenishlifebymaxhp_p={{{1,140},{10,500},{11,525}}},
		skill_statetime={{{1,18*3},{10,18*7},{13,18*10}}},
	},
	chuimingadvancedbook={ --锤明高级秘籍_10
		state_weak_attack={{{1,20},{10,80},{12,88}},{{1,18*3},{10,18*10},{11,18*10}}},
		skilldamageptrim={{{1,-5},{10,-50},{12,-55}}},
		skillselfdamagetrim={{{1,-5},{10,-50},{12,-55}}},
		skill_mintimepercast_v={{{1,45*18},{2,45*18}}},
		skill_mintimepercastonhorse_v={{{1,45*18},{2,45*18}}},
		missile_hitcount={{{1,2},{10,6}}},
		skill_skillexp_v=FightSkill.tbParam.tbHighBookSkillExp,
		skill_cost_v={{{1,100},{10,100}}},
		skill_statetime={{{1,18*3},{10,18*7},{11,18*7}}},
	},
	jianmingadvancedbook_child={ --锤明高级秘籍_10
		state_weak_attack={{{1,20},{10,80},{12,88}},{{1,18*3},{10,18*10},{11,18*10}}},
		missile_hitcount={{{1,2},{10,15},{12,15}}},
		skilldamageptrim={{{1,-5},{10,-50},{12,-55}}},
		skillselfdamagetrim={{{1,-5},{10,-50},{12,-55}}},
		skill_statetime={{{1,18*3},{10,18*7},{11,18*7}}},
	},
	chuiming120={ --锤明120_10
		--500距离时闪避50%,近战加强型数值,且属性规则特殊,数值弹性大,额外加强影响不大
		--称1/(1-闪避率)为防御价值,1-10级价值约每级增加10%,+1后每级增加5%
		ignore_skillstyle_bydist={{
			{ 1,3835},
			{ 2,2170},
			{ 3,1615},
			{ 4,1335},
			{ 5,1170},
			{ 6,1060},
			{ 7, 980},
			{ 8, 920},
			{ 9, 875},
			{10, 835},
			{11, 820},
			{12, 805},
			{13, 790},
			{14, 780},
			{15, 770},},{{1,3},{10,3}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	--剑明教
	shenghuofenxin={ --圣火焚心_20
		appenddamage_p= {{{1,100},{20,100},{21,100*nA0}}},
		skill_cost_v={{{1,10},{20,50},{21,50}}},
		seriesdamage_r={0},--={{{1,50},{20,100},{21,100}}},
		state_weak_attack={{{1,15},{10,45},{20,50},{21,51}},{{1,36},{20,54}}},
		poisondamage_v={{{1,40},{10,130},{20,180},{21,180*nA0}},{{1,4*9},{20,4*9}}},
		skill_mintimepercast_v={{{1,2*18},{2,2*18}}},
		skill_mintimepercastonhorse_v={{{1,2*18},{2,2*18}}},
		addskilldamagep={208, {{1,2},{20,30},{21,35}},1},
		addskilldamagep2={248, {{1,2},{20,30},{21,35}}},
		addskilldamagep3={211, {{1,2},{20,10},{21,12}},1},
		missile_hitcount={{{1,2},{10,3},{11,4},{12,4}}},
		missile_range={3,0,3},
	},
	mingjiaojianfa={ --明教剑法_10
		addpoisonmagic_v={{{1,5},{10,100},{11,105}},{{1,5*9},{20,5*9}}},
		deadlystrikeenhance_r={{{1,30},{10,50},{11,55}}},
		castspeed_v={{{1,5},{10,15},{11,16},{12,17},{13,17}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	miqipiaozong={ --弥气飘踪_10
		ignoreskill={{{1,7},{10,25},{13,30}},0,{{1,2},{2,2}}},
		skill_statetime={{{1,-1},{10,-1}}},
	},
	wanwujufen={ --万物俱焚_20
		appenddamage_p= {{{1,100},{20,100},{21,100*nA0}}},
		skill_cost_v={{{1,50},{20,150},{21,150}}},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		state_weak_attack={{{1,15},{10,25},{20,30},{21,31}},{{1,36},{20,54},{21,54}}},
		poisondamage_v={{{1,500},{10,680},{20,830},{21,830*nA0}},{{1,4*9},{20,4*9}}},
		addskilldamagep={211, {{1,2},{20,30},{21,35}},1},
		skill_mintimepercast_v={{{1,2.5*18},{2,2.5*18}}},
		skill_mintimepercastonhorse_v={{{1,2.5*18},{2,2.5*18}}},
		missile_hitcount={{{1,2},{10,3},{20,3},{21,4},{22,4}}},
		missile_range={3,0,3},
	},
	wanwujufen_child={ --万物俱焚子
		appenddamage_p= {{{1,100},{20,100},{21,100*nA0}}},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		state_weak_attack={{{1,15},{10,25},{20,30},{21,31}},{{1,36},{20,54},{21,54}}},
		poisondamage_v={{{1,375},{10,510},{20,620},{21,620*nA0}},{{1,3*9},{20,3*9}}},
		missile_hitcount={{{1,2},{20,2},{21,3},{22,3}}},
		missile_range={3,0,3},
	},
	piaoyishenfa={ --飘翼身法_20
		fastwalkrun_p={{{1,10},{20,40}}},
		--skill_cost_v={{{1,100},{10,150},{20,300}}},
		state_stun_resisttime={{{1,30},{20,135}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	qiankundanuoyi={ --乾坤大挪移_10
		skill_cost_v={{{1,200},{10,500},{11,500}}},
		ignoreinitiative={{{1,1},{10,5},{11,5}}},
		ignoreskill={{{1,5},{10,50},{12,55}},0,{{1,7},{2,7}}},
		removeshield={1},
		missile_missrate={{{1,65},{10,20},{11,17}}},
		skill_mintimepercast_v={{{1,60*18},{10,60*18},{11,60*18}}},
		skill_mintimepercastonhorse_v={{{1,60*18},{10,60*18},{11,60*18}}},
		--missile_hitcount={{{1,5},{5,6},{10,7},{11,7}}},
		skill_statetime={{{1,18*15},{10,18*60},{11,18*63}}},
	},
	qiankundanuoyi_child={ --乾坤大挪移_清除武当盾
		removeshield={1},
		missile_missrate={{{1,65},{10,20},{11,17}}},
		missile_hitcount={{{1,5},{5,6},{10,7},{11,7}}},
	},
	toutianhuanri={ --偷天换日_20
		fastmanareplenish_v={{{1,-125},{20,-600},{21,-630}}},
		skill_cost_v={{{1,2},{20,25},{21,25}}},
		skill_statetime={{{1,18*3},{20,18*5},{21,18*5}}},
		skill_mintimepercast_v={{{1,60*18},{20,30*18},{21,30*18}}},
		skill_mintimepercastonhorse_v={{{1,60*18},{20,30*18},{21,30*18}}},
		missile_hitcount={{{1,1},{10,2},{20,3},{21,3}}},
	},
	toutianhuanri_self={ --偷天换日_自身
		fastlifereplenish_v={{{1,125},{20,600},{21,630}}},
		fastmanareplenish_v={{{1,125},{20,600},{21,630}}},
		skill_statetime={{{1,18*5},{20,18*10},{21,18*10}}},
	},
	shenghuoliaoyuan={ --圣火燎原
		appenddamage_p= {{{1,2*65*nS01},{10,2*65},{20,2*65*nS20},{21,2*65*nS20*nA0}}},
		poisondamage_v={{{1,2*620*nS01},{10,2*620},{20,2*620*nS20},{21,2*620*nS20*nA0}},{{1,4*9},{20,4*9}}},
		seriesdamage_r={0},--={{{1,100},{20,250},{21,250}}},
		skill_cost_v={{{1,150},{20,300},{21,300}}},
		state_weak_attack={{{1,25},{10,50},{20,64}},{{1,72},{20,72}}},
		--missile_hitcount={{{1,3},{10,4},{20,5},{21,5}}},
		skill_mintimepercast_v={{{1,3.5*18},{2,3.5*18}}},
		skill_mintimepercastonhorse_v={{{1,3.5*18},{2,3.5*18}}},
		missile_range={4,0,4},
	},
	lihuodafa={ --离火大法
		state_weak_attackrate={{{1,10},{20,100}}},
		state_stun_resistrate={{{1,10},{10,100},{20,150}}},
		castspeed_v={{{1,10},{10,16},{20,26},{23,29},{24,29}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	shenghuoshengong={ --圣火神功
		skilldamageptrim={{{1,1},{10,10}}},
		skillselfdamagetrim={{{1,1},{10,10}}},
		state_weak_attacktime={{{1,10},{10,80}}},
		state_stun_resisttime={{{1,10},{10,120}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	
	yinyunziqi={ --中级秘籍：氤氲紫气
		addenchant={4, {{1,1}, {2, 2}}},
		skill_skillexp_v=FightSkill.tbParam.tbMidBookSkillExp,
		skill_statetime={{{1,-1},{2,-1}}},
		--{szMagicName = "addignoreskillrate", tbValue = {207, 0, {{1,5}, {10, 10}}}},
		--{szMagicName = "decreaseskillcasttime", tbValue = {210, {{1,18*6}, {10, 18*15}}}},
		--{szMagicName = "decreaseskillcasttime", tbValue = {205, {{1,18*0.5}, {5, 18*1}, {10, 18*1.5}}}},
		--{szMagicName = "decreaseskillcasttime", tbValue = {208, {{1,18*0.5}, {5, 18*1}, {10, 18*1.5}}}},
		--{szMagicName = "skill_skillexp_v", tbValue = FightSkill.tbParam.tbMidBookSkillExp},
		--{szMagicName = "skill_statetime", tbValue = {{{1,-1},{2,-1}}}},
	},
	
	shenghuolingfa={ --圣火令法
		clear_cd={{{1,1}, {2,1}}},
		skill_mintimepercast_v={{{1,30*18},{10,30*18}}},
		skill_mintimepercastonhorse_v={{{1,30*18},{10,30*18}}},
		skill_statetime={{{1,18*3},{10,18*7.5},{13,18*9}}},
	},
	jianmingadvancedbook={ --剑明高级秘籍_10
		addenchant={27, {{1,1}, {2, 2}}},
		autoskill={{{1,42},{2,42}},{{1,1},{10,10}}},
		skill_statetime={{{1,-1},{2,-1}}},
		skill_skillexp_v=FightSkill.tbParam.tbHighBookSkillExp,
	},
	jianmingadvancedbook_child={ --剑明高级秘籍子
		state_fixed_attack={{{1,35},{10,75}},{{1,18*1.5},{10,18*3}}},
		missile_hitcount={{{1,3},{5,4},{10,5}}},
	},
	jianming120={ --剑明120_10
		skilldamageptrim={{{1,2},{10,20},{11,22}}},
		skillselfdamagetrim={{{1,2},{10,20},{11,22}}},
		addenchant={30, {{1,1}, {2, 2}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
}

FightSkill:AddMagicData(tb)

local tbSkill = FightSkill:GetClass("pidishi")

function tbSkill:GetExtraDesc(tbInfo)
	if (not tbInfo) then
		return "";
	end
	local tbChildInfo	= KFightSkill.GetSkillInfo(1191, tbInfo.nLevel);
	local szMsg = ""	
	local tbMsg = {};
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0);
	szMsg = szMsg.."\n"
	szMsg = szMsg.."击中每个目标时释放：\n";
	szMsg = szMsg.."<color=green>[裂地震] "..tbInfo.nLevel.."级<color>\n";
	for i=1, #tbMsg do
		szMsg = szMsg..""..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	return szMsg;
end

local tbSkill	= FightSkill:GetClass("jiuxihunyang");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local szMsg	= string.format("生命降到25%%时触发几率：<color=gold>%d%%<color>\n自身免疫受伤、迟缓、眩晕、定身状态\n每半秒生命回复：<color=gold>%s%%*生命上限<color>\nThời gian duy trì: <color=gold>%s秒<color>\n触发间隔时间：<color=Gold>%s秒<color>",
		tbAutoInfo.nPercent,
		math.floor(tbChildInfo.tbWholeMagic["replenishlifebymaxhp_p"][1]/10),
		FightSkill:Frame2Sec(tbChildInfo.nStateTime),
		FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime));
	return szMsg;
end;

local tbSkill	= FightSkill:GetClass("jianmingadvancedbook");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	--local tbCCInfo	= KFightSkill.GetSkillInfo(tbChildInfo.tbEvent.nStartSkillId, tbChildInfo.tbEvent.nLevel);
	local szMsg	= string.format("\n<color=green>子招式<color>\n被攻击命中时触发几率：<color=gold>%d%%<color>\n最多同时影响目标：<color=gold>%d个<color>\n造成攻击者定身的几率：<color=gold>%d%%<color>，持续<color=gold>%s秒<color>\n触发间隔时间：<color=Gold>%s秒<color>",
		tbAutoInfo.nPercent,
		tbChildInfo.nMissileHitcount,
		tbChildInfo.tbWholeMagic["state_fixed_attack"][1],
		FightSkill:Frame2Sec(tbChildInfo.tbWholeMagic["state_fixed_attack"][2]),
		FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime));
	return szMsg;
end;

local tbSkill = FightSkill:GetClass("qiankundanuoyi")

function tbSkill:GetExtraDesc(tbInfo)
	if (not tbInfo) then
		return "";
	end
	
	local tbSkillInfo	= KFightSkill.GetSkillInfo(tbInfo.nId, tbInfo.nLevel,me,1);

	local szMsg	= string.format("\n技能成功率：<color=gold>%s%%<color>", 100-tbSkillInfo.tbWholeMagic["missile_missrate"][1]);
	return szMsg;
end
