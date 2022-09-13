Require("\\script\\fightskill\\enchant\\enchant.lua");

local tb	= 
{
	baibuchuanyangadd3 =
	{
		{
			RelatedSkillId = 2996,
			magic = 
			{
				skill_attackradius = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,48}, {10, 200}, {11, 220}}},
				},
				skill_mintimepercast_v = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,-18}, {10,-18*3}, {10,-18*3}}},
				},
				skill_mintimepercastonhorse_v = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,-18}, {10,-18*2}, {10,-18*2}}},
				},
			},
		},
		
		{
			RelatedSkillId = 3001,
			magic = 
			{
				missile_speed_v = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,8}, {10, 35}, {11, 39}}},
				},
			},
		},
	},
	--中级秘籍：达摩闭息功
	damobixigongadd =
	{
		{
			RelatedSkillId = 24,
			magic = 
			{
				missile_range = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,1}, {10, 1}}},
					value3 = {SkillEnchant.OP_ADD,  {{1,1}, {10, 1}}},
				},
			},
		},
		
		{
			RelatedSkillId = 251,
			magic = 
			{
				state_slowall_attack = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,7}, {10, 25}, {11, 26}}},
				},
				missile_range = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,2}, {10, 6}, {11, 6}}},
					value3 = {SkillEnchant.OP_ADD,  {{1,2}, {10, 6}, {11, 6}}},
				},
			},
		},
	},
	--120技能疯魔棍法
	gs120_fengmogunfa =
	{
		{
			RelatedSkillId = 31,
			magic = 
			{
				skill_mintimepercast_v = 
				{
					value1 = {SkillEnchant.OP_MUL,  {{1,-5}, {10, -50},{12,-50}}},
				},
			},
		},
		
		{
			RelatedSkillId = 821,
			magic = 
			{
				skill_mintimepercast_v = 
				{
					value1 = {SkillEnchant.OP_MUL,  {{1,-5}, {10, -50},{12,-50}}},
				},
			},
		},
	},
	--120技能降低攻击技能消耗
	gunshao_reducecost =
	{
		{
			RelatedSkillId = 29,--普渡棍法
			magic = 
			{
				skill_cost_v = 
				{
					value1 = {SkillEnchant.OP_MUL,  {{1,-100}, {10, -100}}},
				},
			},
		},
		{
			RelatedSkillId = 33,--普渡棍法
			magic = 
			{
				skill_cost_v = 
				{
					value1 = {SkillEnchant.OP_MUL,  {{1,-100}, {10, -100}}},
				},
			},
		},
		{
			RelatedSkillId = 36,--七星罗刹棍
			magic = 
			{
				skill_cost_v = 
				{
					value1 = {SkillEnchant.OP_MUL,  {{1,-100}, {10, -100}}},
				},
			},
		},
	},
};


SkillEnchant:AddBooksInfo(tb)