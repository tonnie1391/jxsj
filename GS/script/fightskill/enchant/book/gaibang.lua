Require("\\script\\fightskill\\enchant\\enchant.lua");

local tb	= 
{
	--中级秘籍：神龙摆尾
	shengongbaiweiadd =
	{
		{
			RelatedSkillId = 128,--见人伸手
			magic = 
			{
				missile_ablility = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,14}, {10, 100}, {11, 100}}},
					value2 = {SkillEnchant.OP_SET,  {{1,0}, {10, 0}}},
				},
			},
		},
		
		{
			RelatedSkillId = 808,--亢龙有悔
			magic = 
			{
				missile_speed_v = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,6}, {10, 15}, {11, 16}}},
				},
				--missile_ablility = 
				--{
				--	value1 = {SkillEnchant.OP_ADD,  {{1,14}, {10, 100}, {11, 100}}},
				--	value2 = {SkillEnchant.OP_SET,  {{1,2}, {10, 2}}},
				--},
			},
		},
		
		{
			RelatedSkillId = 489,--时乘六龙
			magic = 
			{
				skill_mintimepercast_v = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,-1*18}, {10, -5*18}, {12, -5.5*18}}},
				},
				skill_mintimepercastonhorse_v = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,-1*18}, {10, -5*18}, {12, -5.5*18}}},
				},
			},
		},
		
		{
			RelatedSkillId = 134,--飞龙在天
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
			RelatedSkillId = 135,--龙战于野
			magic = 
			{
				missile_range = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,1}, {10, 3}, {11, 3}}},
					value3 = {SkillEnchant.OP_ADD, {{1,1}, {10, 3}, {11, 3}}},
				},
			},
		},
	},
	--擒龙功
	qinlonggongadd =
	{
		{
			RelatedSkillId = 490,
			magic = 
			{
				state_palsy_attack = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,7}, {10, 20}}},
					value2 = {SkillEnchant.OP_ADD,  {{1,18*1.5},{10,18*2.5}}},
				},
			},
		},
	},

	--棍丐120
	gungai120add =
	{
		{
			RelatedSkillId = 141,--天下无狗817
			magic = 
			{
				state_knock_attack = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1, 6},{10,15},{10,15}}},
					value2 = {SkillEnchant.OP_ADD,  {{1, 6},{10,15}}},
					value3 = {SkillEnchant.OP_ADD,  {{1,17},{10,17}}},
				},
			},
		},
		{
			RelatedSkillId = 845,--打狗棍法伤害
			magic = 
			{
				state_drag_attack = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1, 3},{10,30},{11,30}}},
					value2 = {SkillEnchant.OP_ADD,  {{1, 1},{10,10}}},
					value3 = {SkillEnchant.OP_ADD,  {{1,32},{10,32}}},
				},
			},
		},
	},
};


SkillEnchant:AddBooksInfo(tb)