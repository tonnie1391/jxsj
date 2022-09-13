Require("\\script\\fightskill\\enchant\\enchant.lua");

local tb	= 
{
	--中级秘籍：踏雪无痕
	taxuewuhenadd =
	{
		{
			RelatedSkillId = 120,
			magic = 
			{
				missile_speed_v = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,6}, {10, 15}, {11, 16}}},
				},
				missile_range = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,1}, {10, 2}, {11, 2}}},
					value3 = {SkillEnchant.OP_ADD, {{1,1}, {10, 2}, {11, 2}}},
				},
			},
		},
		
		{
			RelatedSkillId = 123,
			magic = 
			{
				missile_range = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,1}, {10, 2}, {11, 2}}},
					value3 = {SkillEnchant.OP_ADD, {{1,1}, {10, 2}, {11, 2}}},
				},
			},
		},
		
		{
			RelatedSkillId = 125,
			magic = 
			{
				missile_range = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,1}, {10, 2}, {11, 2}}},
					value3 = {SkillEnchant.OP_ADD, {{1,1}, {10, 2}, {11, 2}}},
				},
			},
		},
		{
			RelatedSkillId = 126,
			magic = 
			{
				missile_range = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,1}, {10, 2}, {11, 2}}},
					value3 = {SkillEnchant.OP_ADD, {{1,1}, {10, 2}, {11, 2}}},
				},
			},
		},
	},
	--110技能:十面埋伏
	shimianmaifuadd =
	{
		{
			RelatedSkillId = 117,
			magic = 
			{
				keephide = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,1}, {10, 1}}},
				},
			},
		},
	},
};


SkillEnchant:AddBooksInfo(tb)