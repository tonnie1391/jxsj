--阵法技能
local tb	= {
	wuxingzhen={
		lifemax_p=			{{{1,1},{5,5}}},
		expenhance_p=		{{{1,1},{5,5}}},
		lucky_v=			{{{1,1},{5,5}}},
		manareplenish_v=	{{{1,2},{5,10}}},
	},
--克制五行阵法系列之近距离效果
	zhenfa1_5_n={
		lifemax_p=			{{{1,5},{5,25}}},
		manamax_p=			{{{1,5},{5,25}}},
		lifereplenish_p=	{{{1,2},{5,10}}},
		manareplenish_p=	{{{1,2},{5,10}}},
		adddefense_v=		{{{1,30},{5,150}}},
	},
--克制五行阵法系列之远距离效果
	zhenfa1_f={
		state_hurt_resistrate=	{{{1,15},{5,75}}},
		damage_physics_resist=	{{{1,16},{5,80}}},
	},
	zhenfa2_f={
		state_weak_resistrate=	{{{1,15},{5,75}}},
		damage_physics_resist=	{{{1,8},{5,40}}},
		damage_poison_resist=	{{{1,10},{5,50}}},
	},
	zhenfa3_f={
		state_slowall_resistrate=	{{{1,15},{5,75}}},
		damage_physics_resist=		{{{1,8},{5,40}}},
		damage_cold_resist=			{{{1,10},{5,50}}},
	},
	zhenfa4_f={
		state_burn_resistrate=	{{{1,15},{5,75}}},
		damage_physics_resist=	{{{1,8},{5,40}}},
		damage_fire_resist=		{{{1,10},{5,50}}},
	},
	zhenfa5_f={
		state_stun_resistrate=	{{{1,15},{5,75}}},
		damage_physics_resist=	{{{1,8},{5,40}}},
		damage_light_resist=	{{{1,10},{5,50}}},
	},
--提高攻击力和攻击效果
	zhenfa6_n={
		skilldamageptrim=		{{{1,1},{5,5}}},
		skillselfdamagetrim=	{{{1,1},{5,5}}},
		ignoredefenseenhance_v=	{{{1,30},{5,150}}},
	},
	zhenfa6_f={
		state_weak_attackrate=		{{{1,15},{5,75}}},
		state_stun_attackrate=		{{{1,15},{5,75}}},
		state_burn_attackrate=		{{{1,15},{5,75}}},
		state_hurt_attackrate=		{{{1,15},{5,75}}},
		state_slowall_attackrate=	{{{1,15},{5,75}}},
	},
--加会心伤害
	zhenfa7_n={
		deadlystrikedamageenhance_p={{{1,3},{5,15}}},
	},
	zhenfa7_f={
		deadlystrikedamageenhance_p={{{1,3},{5,15}}},
	},
--减会心伤害
	zhenfa8_n={
		defencedeadlystrikedamagetrim={{{1,3},{5,15}}},
	},
	zhenfa8_f={
		defencedeadlystrikedamagetrim={{{1,3},{5,15}}},
	},
--远程反弹,补充防具只有近程反弹属性
	zhenfa9_n={
		rangedamagereturn_p={{{1,2},{5,10}}},
	},
	zhenfa9_f={
		rangedamagereturn_p={{{1,3},{5,15}}},
	},
--减少受到的反弹伤害
	zhenfa10_n={
		damage_return_receive_p={{{1,-2},{5,-10}}},
	},
	zhenfa10_f={
		damage_return_receive_p={{{1,-4},{5,-20}}},
	},
--加幸运
	baihuazhen={
		lucky_v={{{1,5},{2,10},{55,275},{56,275}}},
	},

--高级阵法
--闪内功攻击
	zhenfa11_n={
		ignoreskill={{{1,1},{5,7}},0,{{1,2},{2,2}}},
	},
	zhenfa11_f={
		ignoreskill={{{1,1},{5,8}},0,{{1,2},{2,2}}},
	},
--闪外功攻击
	zhenfa12_n={
		ignoreskill={{{1,1},{5,7}},0,{{1,4},{2,4}}},
	},
	zhenfa12_f={
		ignoreskill={{{1,1},{5,8}},0,{{1,4},{2,4}}},
	},
--吸血
	zhenfa13_n={
		steallifeenhance_p={{{1,1},{5,5}},{{1,100},{5,100}}},
	},
	zhenfa13_f={
		steallifeenhance_p={{{1,1},{5,5}},{{1,100},{5,100}}},
		npcdamageadded={{{1,-10},{5,-50}}},
	},
--吸内
	zhenfa14_n={
		steallifeenhance_p={{{1,1},{5,2}},{{1,100},{5,100}}},
		stealmanaenhance_p={{{1,1},{5,3}},{{1,100},{5,100}}},
	},
	zhenfa14_f={
		steallifeenhance_p={{{1,1},{5,3}},{{1,100},{5,100}}},
		stealmanaenhance_p={{{1,1},{5,2}},{{1,100},{5,100}}},
		npcdamageadded={{{1,-10},{5,-50}}},
	},
--减自身会心伤害,减少受会心几率
	zhenfa15_n={
		deadlystrikedamageenhance_p={{{1,-3},{5,-15}}},
		cri_resist={{{1,40},{5,200}}},
	},
	zhenfa15_f={
		deadlystrikedamageenhance_p={{{1,-3},{5,-15}}},
		cri_resist={{{1,40},{5,200}}},
	},
--潜能增加
	zhenfa16_n={
		strength_v		={{{1,13},{5,130}}},
		energy_v		={{{1,13},{5,130}}},
	},
	zhenfa16_f={
		dexterity_v		={{{1,13},{5,130}}},
		vitality_v		={{{1,13},{5,130}}},
	},
--加30%防减20%攻击
	zhenfa17_n={
		skilldamageptrim		={{{1,-2},{5,-10}}},
		skillselfdamagetrim		={{{1,-2},{5,-10}}},
		redeivedamage_dec_p2	={{{1,3},{5,15}}},
	},
	zhenfa17_f={
		skilldamageptrim		={{{1,-2},{5,-10}}},
		skillselfdamagetrim		={{{1,-2},{5,-10}}},
		redeivedamage_dec_p2	={{{1,3},{5,15}}},
	},
--加30%攻击减20%防
	zhenfa18_n={
		skilldamageptrim		={{{1,3},{5,15}}},
		skillselfdamagetrim		={{{1,3},{5,15}}},
		redeivedamage_dec_p2	={{{1,-2},{5,-10}}},
	},
	zhenfa18_f={
		skilldamageptrim		={{{1,3},{5,15}}},
		skillselfdamagetrim		={{{1,3},{5,15}}},
		redeivedamage_dec_p2	={{{1,-2},{5,-10}}},
	},
}

FightSkill:AddMagicData(tb)
