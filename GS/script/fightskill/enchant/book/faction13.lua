Require("\\script\\fightskill\\enchant\\enchant.lua");

local tb	= 
{
	--中级秘籍：强化诅咒区域_10
	sxgm_book2add =
	{
		{
			RelatedSkillId = 2841,
			magic = 
			{
				lifereplenish_p = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,-1}, {9,-3}, {10,-4}, {11,-4}}},
				},
				superposemagic = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,1}, {10, 10}, {11, 11}}},
					--value3 = {SkillEnchant.OP_ADD,  {{1,1}, {10, 10}, {11, 11}}},
				},
				skill_statetime = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,4*18}, {10, 4*18}, {11, 4*18}}},
				},
			},
		},
	},
	
	--杀闪精通_20
	sxgm_40add =
	{
		{--强化禁
			RelatedSkillId = 2817,
			magic = 
			{
				damage_inc_p = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,1}, {20,4}, {21,4}}},
				},
			},
		},
		{--强化绝
			RelatedSkillId = 2818,
			magic = 
			{
				allspecialstateresistrate = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,2}, {20,40}, {21,42}}},
				},
			},
		},
	},

	--冲刺需要扣除1点飞针
	fzgm_atk_30add =
	{
		{
			RelatedSkillId = 2827,
			magic = 
			{
				skill_cost_buff1layers_v = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,2846}, {20,2846}}},
					value2 = {SkillEnchant.OP_ADD,  {{1,1}, {20,1}}},
					value3 = {SkillEnchant.OP_ADD,  {{1,1}, {20,1}}},
				},
			},
		},
	},
	--存针
	fzgm_book2add =
	{
		{--强化冰魄银针
			RelatedSkillId = 2850,
			magic = 
			{
				appenddamage_p = 
				{
					value1 = {SkillEnchant.OP_MUL,  {{1,5}, {10,50}, {12,55}}},
				},
				lifereplenish_p = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,-4}, {10,-35}, {11,-37}}},
				},
				skill_statetime = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,5*18}, {10,5*18}, {11,5*18}}},
				},
			},
		},
		{--强化玉蜂针
			RelatedSkillId = 2824,
			magic = 
			{
				appenddamage_p = 
				{
					value1 = {SkillEnchant.OP_MUL,  {{1,5}, {10,50}, {12,55}}},
				},
				fastwalkrun_p = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,-8}, {10,-80}, {11,-80}}},
				},
				skill_statetime = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,6*18}, {10,6*18}, {11,6*18}}},
				},
			},
		},
	},
	--集中攻击_10
	fzgm_60_b_add =
	{
		{--10级技能只能攻击一个目标
			RelatedSkillId = 2821,
			magic = 
			{
				missile_hitcount = 
				{
					value1 = {SkillEnchant.OP_SET,  {{1,1}, {20,1}}},
				},
			},
		},
		{--50级技能只能攻击一个目标
			RelatedSkillId = 2823,
			magic = 
			{
				missile_hitcount = 
				{
					value1 = {SkillEnchant.OP_SET,  {{1,1}, {20,1}}},
				},
			},
		},
		{--90级技能只能攻击一个目标
			RelatedSkillId = 2825,
			magic = 
			{
				missile_hitcount = 
				{
					value1 = {SkillEnchant.OP_SET,  {{1,1}, {20,1}}},
				},
			},
		},
	},
	--五气朝元禁用轻功
	banjump =
	{
		{--轻功耗体增加
			RelatedSkillId = 10,
			magic = 
			{
				skill_cost_v = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,99999}, {20,99999}}},
				},
			},
		},
	},
};


SkillEnchant:AddBooksInfo(tb)
