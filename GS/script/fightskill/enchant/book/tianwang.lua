Require("\\script\\fightskill\\enchant\\enchant.lua");

local tb	= 
{
	--中级秘籍：披荆斩棘
	pijingzhanjiadd3 =
	{
		{
			RelatedSkillId = 2985,
			magic = 
			{
				skill_attackradius = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,25}, {10, 250}, {12, 275}}},
				},
				skill_param1_v = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,2}, {10, 18}, {11, 18}}},
				},
			},
		},
	},
	--中级秘籍：披荆斩棘
	pijingzhanjiadd =
	{
		{
			RelatedSkillId = 41,
			magic = 
			{
				skill_attackradius = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,25}, {10, 250}, {12, 275}}},
				},
				skill_param1_v = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,2}, {10, 18}, {11, 18}}},
				},
			},
		},
	},
	--奔雷钻龙枪状态下中级秘籍效果降低...
	benleireduce =
	{
		{
			RelatedSkillId = 1273,--连环夺命枪子
			magic = 
			{
				skilldamageptrim = 
				{
					value1 = {SkillEnchant.OP_MUL,  {{1,-100}, {10, -100}}},
				},
				skillselfdamagetrim = 
				{
					value1 = {SkillEnchant.OP_MUL,  {{1,-100}, {10, -100}}},
				},
			},
		},
		{
			RelatedSkillId = 1660,--连环夺命枪子2
			magic = 
			{
				skilldamageptrim = 
				{
					value1 = {SkillEnchant.OP_MUL,  {{1,-100}, {10, -100}}},
				},
				skillselfdamagetrim = 
				{
					value1 = {SkillEnchant.OP_MUL,  {{1,-100}, {10, -100}}},
				},
			},
		},
	},
};


SkillEnchant:AddBooksInfo(tb)
