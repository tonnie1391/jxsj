Require("\\script\\fightskill\\enchant\\enchant.lua");

local tb	= 
{
	--中级秘籍：金顶绵掌
	jindingmianzhangadd =
	{
		{
			RelatedSkillId = 480,--不灭不绝子
			magic = 
			{
				replenishlifebymaxhp_p = 
				{
					value1 = {SkillEnchant.OP_MUL, {{1,10}, {10, 100}, {11, 105}}},
				},
			},
		},
		
		{
			RelatedSkillId = 103,--金顶佛光
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
			RelatedSkillId = 98,--慈航普渡
			magic = 
			{
				skill_statetime = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,1*18}, {10, 10*18}, {11, 10.5*18}}},
				},
			},
		},
	},
	--波罗心经
	fue80add =
	{
		{
			RelatedSkillId = 277,--梦蝶子
			magic = 
			{
				missile_range = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,2}, {20, 22}, {21, 22}}},
					value3 = {SkillEnchant.OP_ADD, {{1,2}, {20, 22}, {21, 22}}},
				},
			},
		},
		{
			RelatedSkillId = 276,--佛心慈佑子
			magic = 
			{
				missile_range = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,2}, {20, 22}, {21, 22}}},
					value3 = {SkillEnchant.OP_ADD, {{1,2}, {20, 22}, {21, 22}}},
				},
			},
		},
		{
			RelatedSkillId = 241,--流水诀
			magic = 
			{
				missile_range = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,2}, {20, 22}, {21, 22}}},
					value3 = {SkillEnchant.OP_ADD, {{1,2}, {20, 22}, {21, 22}}},
				},
			},
		},
		{
			RelatedSkillId = 278,--清音梵唱
			magic = 
			{
				missile_range = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,2}, {20, 22}, {21, 22}}},
					value3 = {SkillEnchant.OP_ADD, {{1,2}, {20, 22}, {21, 22}}},
				},
			},
		},
		{
			RelatedSkillId = 882,--普度众生
			magic = 
			{
				missile_range = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,2}, {20, 22}, {21, 22}}},
					value3 = {SkillEnchant.OP_ADD, {{1,2}, {20, 22}, {21, 22}}},
				},
			},
		},
	},
	--中级秘籍：渡元功
	duyuangongadd =
	{
		{
			RelatedSkillId = 107,--佛音战意
			magic = 
			{
				state_slowall_attack = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,1}, {10, 9}, {11, 9}}},
				},
			},
		},
		
		{
			RelatedSkillId = 98,--慈航普渡
			magic = 
			{
				replenishlifebymaxhp_p = 
				{
					value1 = {SkillEnchant.OP_MUL, {{1,1}, {10, 10}, {11, 11}}},
				},
				missile_range = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,2}, {10, 6}, {11, 6}}},
					value3 = {SkillEnchant.OP_ADD, {{1,2}, {10, 6}, {11, 6}}},
				},
			},
		},
		
		{
			RelatedSkillId = 101,--佛心慈佑
			magic = 
			{
				lifemax_p = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,14}, {10, 50}, {12, 55}}},
				},
				manamax_p = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1, 7}, {10, 25}, {12, 27}}},
				},
			},
		},
		
		{
			RelatedSkillId = 276,--佛心慈佑_队友
			magic = 
			{
				lifemax_p = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,14}, {10, 50}, {12, 55}}},
				},
				manamax_p = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1, 7}, {10, 25}, {12, 27}}},
				},
			},
		},
		
		{
			RelatedSkillId = 110,--佛光普照
			magic = 
			{
				skill_mintimepercast_v = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,-12*18}, {10, -30*18}, {12, -33*18}}},
				},
				skill_mintimepercastonhorse_v = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,-12*18}, {10, -30*18}, {12, -33*18}}},
				},
			},
		},
	},
	--高级秘籍：
	fueadvancedbookadd =
	{	
		
		{
			RelatedSkillId = 98,--慈航普渡
			magic = 
			{
				replenishlifebymaxhp_p = 
				{
					value1 = {SkillEnchant.OP_MUL, {{1,1}, {10, 10}, {11, 11}}},
				},
			},
		},
		
		{
			RelatedSkillId = 101,--佛心慈佑
			magic = 
			{
				lifemax_p = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,14}, {10, 50}, {12, 55}}},
				},
				manamax_p = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1, 7}, {10, 25}, {12, 27}}},
				},
			},
		},
		
		{
			RelatedSkillId = 276,--佛心慈佑_队友
			magic = 
			{
				lifemax_p = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,14}, {10, 50}, {12, 55}}},
				},
				manamax_p = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1, 7}, {10, 25}, {12, 27}}},
				},
			},
		},
		
		{
			RelatedSkillId = 108,--清音梵唱
			magic = 
			{
				allseriesstateresisttime = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,15}, {10, 45}, {14, 54}}},
				},
			},
		},
		{
			RelatedSkillId = 278,--清音梵唱_队友
			magic = 
			{
				allseriesstateresisttime = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,12}, {10, 35}, {14, 42}}},
				},				
			},
		},

		{
			RelatedSkillId = 482,--普渡众生
			magic = 
			{
				damage_all_resist = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,10}, {10, 30}, {12, 33}}},
				},
			},
		},
		{
			RelatedSkillId = 882,--清音梵唱_队友
			magic = 
			{
				damage_all_resist = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,5}, {10, 25}, {12, 27}}},
				},
			},
		},
	},
};


SkillEnchant:AddBooksInfo(tb)