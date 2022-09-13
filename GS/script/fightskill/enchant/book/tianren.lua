Require("\\script\\fightskill\\enchant\\enchant.lua");

local tb	=
{
	--ÖÐ¼¶ÃØ¼®£º±ÌÔÂ·ÉÐÇ
	biyuefeixingadd =
	{
		{
			RelatedSkillId = 787,--»ÃÓ°×·»êÇ¹&×Ó
			magic =
			{
				missile_range =
				{
					value1 = {SkillEnchant.OP_ADD, {{1,1}, {10, 1}}},
					value3 = {SkillEnchant.OP_ADD, {{1,1}, {10, 1}}},
				},
			},
		},

		{
			RelatedSkillId = 492,--»ÃÓ°×·»êÇ¹
			magic =
			{
				skill_mintimepercast_v =
				{
					value1 = {SkillEnchant.OP_ADD, {{1,-18}, {10, -18*10}, {11, -18*10}}},
				},
				skill_mintimepercastonhorse_v =
				{
					value1 = {SkillEnchant.OP_ADD, {{1,-18}, {10, -18*10}, {11, -18*10}}},
				},
			},
		},

		{
			RelatedSkillId = 148,--Ä§ÒôÊÉÆÇ×Óµ¯
			magic =
			{
				missile_range =
				{
					value1 = {SkillEnchant.OP_ADD, {{1,2}, {10, 4}, {11, 4}}},
					value3 = {SkillEnchant.OP_ADD, {{1,2}, {10, 4}, {11, 4}}},
				},
			},
		},
	},
	--¸ß¼¶ÃØ¼®£º
	zhanrenadvancedbookadd =
	{
		{
			RelatedSkillId = 492,--»ÃÓ°×·»êÇ¹
			magic =
			{
				skill_mintimepercast_v =
				{
					value1 = {SkillEnchant.OP_ADD, {{1,-18*0.5}, {10, -18*2.5}, {11, -18*2.5}}},
				},
				skill_mintimepercastonhorse_v =
				{
					value1 = {SkillEnchant.OP_ADD, {{1,-18*0.5}, {10, -18*2.5}, {11, -18*2.5}}},
				},
			},
		},
		{
			RelatedSkillId = 787,--»ÃÓ°×·»êÇ¹
			magic =
			{
				state_zhican_attack =
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,40},{10,100},{11,105}}},
					value2 = {SkillEnchant.OP_ADD,  {{1,2.5*18},{10,2.5*18}}},
				},
			},
		},
		{
			RelatedSkillId = 148,--Ä§ÒôÊÉÆÇ
			magic =
			{
				skill_mintimepercast_v =
				{
					value1 = {SkillEnchant.OP_ADD, {{1,-18}, {10, -18*10}, {11, -18*10}}},
				},
				skill_mintimepercastonhorse_v =
				{
					value1 = {SkillEnchant.OP_ADD, {{1,-18}, {10, -18*10}, {11, -18*10}}},
				},
			},
		},

		{
			RelatedSkillId = 847,--·ÉºèÎÞ¼£
			magic =
			{
				skill_mintimepercast_v =
				{
					value1 = {SkillEnchant.OP_ADD, {{1,-18}, {10, -18*15}, {11, -18*15}}},
				},
				skill_mintimepercastonhorse_v =
				{
					value1 = {SkillEnchant.OP_ADD, {{1,-18}, {10, -18*15}, {11, -18*15}}},
				},
			},
		},
	},
	--ÖÐ¼¶ÃØ¼®£ºÐþÚ¤ÎüÐÇ
	xuanmingxixingadd =
	{
		{
			RelatedSkillId = 494,--ÐþÚ¤ÎüÐÇ
			magic =
			{
				skill_mintimepercast_v =
				{
					value1 = {SkillEnchant.OP_ADD, {{1,-18}, {10, -18*10}, {11, -18*10}}},
				},
				skill_mintimepercastonhorse_v =
				{
					value1 = {SkillEnchant.OP_ADD, {{1,-18}, {10, -18*10}, {11, -18*10}}},
				},
				missile_range =
				{
					value1 = {SkillEnchant.OP_ADD, {{1,2}, {10, 6}, {11, 6}}},
					value3 = {SkillEnchant.OP_ADD, {{1,2}, {10, 6}, {11, 6}}},
				},
				missile_lifetime_v =
				{
					value1 = {SkillEnchant.OP_ADD, {{1,18}, {10, 18*5}, {11, 18*5}}},
				},
			},
		},

		{
			RelatedSkillId = 151,--µ¯Ö¸ÁÒÑæ
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
			RelatedSkillId = 153,--ÍÆÉ½Ìîº£
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
	},
	--¸ß¼¶ÃØ¼®:¾ÅÇúÒ»ºÏÇ¹
	jiuquadd =
	{
		{
			RelatedSkillId = 847,--·ÉºèÎÞ¼£
			magic =
			{
				floatdamage_p =
				{
					value1 = {SkillEnchant.OP_MUL, {{1,-30}, {10, -30}, {12, -25}}},
					value2 = {SkillEnchant.OP_MUL, {{1,-30}, {10, -30}, {12, -25}}},
				},
			},
		},
		{
			RelatedSkillId = 1178,--·ÉºèÎÞ¼£_¶ÔÍæ¼ÒÉËº¦
			magic =
			{
				floatdamage_p =
				{
					value1 = {SkillEnchant.OP_MUL, {{1,-30}, {10, -30}, {12, -25}}},
					value2 = {SkillEnchant.OP_MUL, {{1,-30}, {10, -30}, {12, -25}}},
				},
			},
		},
	},
};


SkillEnchant:AddBooksInfo(tb)