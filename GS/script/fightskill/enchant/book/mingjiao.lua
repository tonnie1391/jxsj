Require("\\script\\fightskill\\enchant\\enchant.lua");

local tb	= 
{
	--中级秘籍：流星锤
	liuxingchuiadd =
	{
		{
			RelatedSkillId = 198,--劈地式_主
			magic = 
			{
				skill_attackradius = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,12}, {10, 120}, {11, 120}}},
				},
				skill_mintimepercast_v = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,-18}, {10, -18*3}, {11, -18*3}}},
				},
				skill_mintimepercastonhorse_v = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,-18}, {10, -18*3}, {11, -18*3}}},
				},
			},
		},
		
		{
			RelatedSkillId = 791,--劈地式子弹
			magic = 
			{
				missile_speed_v = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,5}, {10, 20}, {11, 21}}},
				},
				missile_range = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,1}, {10, 3}, {11, 3}}},
					value3 = {SkillEnchant.OP_ADD,  {{1,1}, {10, 3}, {11, 3}}},
				},
				missile_ablility = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,10}, {10, 100}, {11, 100}}},
					value2 = {SkillEnchant.OP_SET,  {{1,2}, {10, 2}}},
				},
			},
		},
	},
	
	--中级秘籍：氤氲紫气
	yinyunziqiadd =
	{
		{
			RelatedSkillId = 207,--弥气飘踪
			magic = 
			{
				ignoreskill = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,5}, {10, 10}, {11, 11}}},
				},
			},
		},
		
		{
			RelatedSkillId = 210,--乾坤大挪移
			magic = 
			{
				skill_mintimepercast_v = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,-18*6}, {10, -18*15}, {11, -18*15}}},
				},
				skill_mintimepercastonhorse_v = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,-18*6}, {10, -18*15}, {11, -18*15}}},
				},
			},
		},
		
		{
			RelatedSkillId = 205,--圣火焚心
			magic = 
			{
				skill_mintimepercast_v = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,-18*0.5}, {5, -18*1}, {10, -18*1.5}, {11, -18*1.5}}},
				},
				skill_mintimepercastonhorse_v = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,-18*0.5}, {5, -18*1}, {10, -18*1.5}, {11, -18*1.5}}},
				},
			},
		},
		
		{
			RelatedSkillId = 208,--万物俱焚
			magic = 
			{
				skill_mintimepercast_v = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,-18*0.5}, {5, -18*1}, {10, -18*1.5}, {11, -18*1.5}}},
				},
				skill_mintimepercastonhorse_v = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,-18*0.5}, {5, -18*1}, {10, -18*1.5}, {11, -18*1.5}}},
				},
			},
		},
	
		{
			RelatedSkillId = 771,--偷天换日自身
			magic = 
			{
				fastlifereplenish_v = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,60}, {10, 600}, {11, 630}}},
				},
				fastmanareplenish_v = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,30}, {10, 300}, {11, 315}}},
				},
			},
		},
		
		{
			RelatedSkillId = 770,--偷天换日
			magic = 
			{
				fastmanareplenish_v = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,-30}, {10,-300}, {11,-315}}},
				},
			},
		},
	},
	--牧野鹰扬
	muyeyingyangadd =
	{
		{
			RelatedSkillId = 205,--圣火焚心
			magic = 
			{
				state_fixed_attack = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,1}, {10, 5}, {11, 5}}},
					value2 = {SkillEnchant.OP_ADD, {{1,18*1.5}, {10, 18*1.5}}},
				},
			},
		},
		
		{
			RelatedSkillId = 208,--万物俱焚
			magic = 
			{
				state_fixed_attack = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,3}, {10, 25}, {11, 26}}},
					value2 = {SkillEnchant.OP_ADD, {{1,18*1.5}, {10, 18*1.5}}},
				},
			},
		},
		{
			RelatedSkillId = 248,--万物俱焚_子
			magic = 
			{
				state_fixed_attack = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,3}, {10, 25}, {11, 26}}},
					value2 = {SkillEnchant.OP_ADD, {{1,18*1.5}, {10, 18*1.5}}},
				},
			},
		},
		{
			RelatedSkillId = 211,--圣火燎原
			magic = 
			{
				state_fixed_attack = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,1}, {10, 10}, {11, 11}}},
					value2 = {SkillEnchant.OP_ADD, {{1,18*1.5}, {10, 18*1.5}}},
				},
			},
		},
	},
	--剑明120
	jianming120add =
	{
		{
			RelatedSkillId = 205,--圣火焚心
			magic = 
			{
				missile_range = 
				{
					value3 = {SkillEnchant.OP_ADD, {{1,1}, {10, 2}, {11, 2}}},
				},
			},
		},
		{
			RelatedSkillId = 248,--万物俱焚_子
			magic = 
			{
				missile_range = 
				{
					value3 = {SkillEnchant.OP_ADD, {{1,1}, {10, 2}, {11, 2}}},
				},
			},
		},
		{
			RelatedSkillId = 211,--圣火燎原
			magic = 
			{
				missile_range = 
				{
					--value1 = {SkillEnchant.OP_ADD, {{1,1}, {10, 2}, {11, 2}}},
					value3 = {SkillEnchant.OP_ADD, {{1,1}, {10, 2}, {11, 2}}},
				},
			},
		},
	},
};


SkillEnchant:AddBooksInfo(tb)