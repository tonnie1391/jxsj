Require("\\script\\fightskill\\enchant\\enchant.lua");

local tb	= 
{
	amtieuadd =
	{
		{
			RelatedSkillId = 3007,
			magic = 
			{
				missile_ablility = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,10}, {10, 30}, {11, 30}}},
					value2 = {SkillEnchant.OP_SET,  {{1,0}, {10, 0}}},
				},
			},
		},
		
		{
			RelatedSkillId = 3008,
			magic = 
			{
				missile_ablility = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,10}, {10, 30}, {11, 30}}},
					value2 = {SkillEnchant.OP_SET,  {{1,2}, {10, 2}}},
				},	
			},
		},
	},
	
	--ÖÐ¼¶ÃØ¼®£ºº¬É³ÉäÓ°
	hanshasheyingadd =
	{
		{
			RelatedSkillId = 64,--ÃÔÓ°×Ý
			magic = 
			{
				skill_param1_v = 
				{
					value1 = {SkillEnchant.OP_MUL,  {{1,20}, {10, 50}, {12, 55}}},
				},
			},
		},
		
		{
			RelatedSkillId = 72,--Ð¡Àî·Éµ¶
			magic = 
			{
				skill_attackradius = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,30}, {10, 80}, {12, 88}}},
				},
				missile_range = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,1}, {10, 3}, {11, 3}}},
					value3 = {SkillEnchant.OP_ADD,  {{1,1}, {10, 3}, {11, 3}}},
				},
			},
		},
		
		{
			RelatedSkillId = 69,--¶¾´Ì¹Ç
			magic = 
			{
				skill_mintimepercast_v = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,-9}, {5, -18}, {10, -27}, {11, -27}}},
				},
			},
		},
		
		{
			RelatedSkillId = 73,--²øÉí´Ì
			magic = 
			{
				skill_mintimepercast_v = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,-9}, {5, -18}, {10, -27}, {11, -27}}},
				},
			},
		},
		
		{
			RelatedSkillId = 71,--¹´»êÚå
			magic = 
			{
				skill_mintimepercast_v = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,-9}, {5, -18}, {10, -27}, {11, -27}}},
				},
			},
		},
		
		{
			RelatedSkillId = 263,--ÎüÐÇÕó
			magic = 
			{
				skill_mintimepercast_v = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,-9}, {5, -18}, {10, -27}, {11, -27}}},
				},
			},
		},
		
		{
			RelatedSkillId = 74,--ÂÒ»·»÷
			magic = 
			{
				skill_mintimepercast_v = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,-9}, {5, -18}, {10, -27}, {11, -27}}},
				},
			},
		},
	},
	
	--ÖÐ¼¶ÃØ¼®£ºÂþÌì»¨Óê
	mantianhuayuadd =
	{
		{
			RelatedSkillId = 64,--ÃÔÓ°×Ý
			magic = 
			{
				skill_param1_v = 
				{
					value1 = {SkillEnchant.OP_MUL,  {{1,5}, {10, 50}, {12, 55}}},
				},
				skill_mintimepercastonhorse_v = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,-9}, {10, -2*18}, {11, -2*18}}},
				},
			},
		},
		
		--[[
		{
			RelatedSkillId = 266,--¶Ï½îÈÐ
			magic = 
			{
				missile_speed_v = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,6}, {10, 15}, {11, 15}}},
				},
				skill_missilenum_v = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,2}, {4,2}, {5,4},{10, 4}}},
				},
				skill_mintimepercast_v = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,-18}, {10, -18*5}, {12, -18*5.5}}},
				},
				skill_mintimepercastonhorse_v = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,-18}, {10, -18*5}, {12, -18*5.5}}},
				},
			},
		},
		
		{
			RelatedSkillId = 63,
			magic = 
			{
				missile_speed_v = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,4}, {10, 10}, {11, 11}}},
				},
				missile_range = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,1}, {10, 1}}},
					value3 = {SkillEnchant.OP_ADD,  {{1,1}, {10, 1}}},
				},
			},
		},]]
	},
	
	--»ú¹ØÃØÊõ
	jiguanmishuadd =
	{
		{
			RelatedSkillId = 69,--¶¾´Ì¹Ç
			magic = 
			{
				skill_maxmissile = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,1},{6,2},{10,2},{11,2}}},
				},
				missile_lifetime_v = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,10*18}, {10,20*18}, {12,22*18}}},
				},
			},
		},
		{
			RelatedSkillId = 71,--¹´»êÚå
			magic = 
			{
				skill_maxmissile = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,0},{2,1},{7,2},{10,2},{11,2}}},
				},
				missile_lifetime_v = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,0*18}, {2,10*18}, {10, 20*18}, {12,22*18}}},
				},
			},
		},
		{
			RelatedSkillId = 883,--¹´»êÚå×Ó
			magic = 
			{
				skill_maxmissile = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,0},{2,1},{7,2},{10,2},{11,2}}},
				},
			},
		},
		{
			RelatedSkillId = 263,--ÎüÐÇÕó
			magic = 
			{
				skill_maxmissile = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,0},{2,0},{3,1},{8,2},{10,2},{11,2}}},
				},
				missile_lifetime_v = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,0*18}, {2,0*18}, {3,10*18}, {10, 20*18}, {12,22*18}}},
				},
			},
		},
		{
			RelatedSkillId = 73,--²øÉí´Ì
			magic = 
			{
				skill_maxmissile = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,0},{3,0},{4,1},{9,2},{10,2},{11,2}}},
				},
				missile_lifetime_v = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,0*18}, {3,0*18}, {4,10*18}, {10,20*18}, {12,22*18}}},
				},
			},
		},
		{
			RelatedSkillId = 74,--ÂÒ»·»÷
			magic = 
			{
				skill_maxmissile = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,0},{4,0},{5,1},{10,2},{11,2}}},
				},
				missile_lifetime_v = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,0*18}, {4,0*18}, {5,10*18}, {10, 20*18}, {12,22*18}}},
				},
			},
		},
	},
	--ÏÝÚå120
	xianjing120add =
	{
		{
			RelatedSkillId = 64,
			magic = 
			{
				skill_param1_v = 
				{
					value1 = {SkillEnchant.OP_MUL,  {{1,50}, {10, 50}}},
				},
				skill_mintimepercast_v = 
				{
					value1 = {SkillEnchant.OP_MUL, {{1, -90}, {10, -90}}},
				},
			},
		},
	},

};


SkillEnchant:AddBooksInfo(tb)