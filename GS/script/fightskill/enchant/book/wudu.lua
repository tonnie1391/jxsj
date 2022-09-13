Require("\\script\\fightskill\\enchant\\enchant.lua");

local tb	= 
{
	--中级秘籍：化血截脉
	huaxuejiemaiadd =
	{
		--[[
		{
			RelatedSkillId = 269,--瘟蛊之气
			magic = 
			{
				skill_mintimepercast_v = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,-18*6}, {10, -18*15}}},
				},
				skill_mintimepercastonhorse_v = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,-18*6}, {10, -18*15}}},
				},
			},
		},
		{
			RelatedSkillId = 774,--万蛊蚀心&子
			magic = 
			{
				skill_mintimepercast_v = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,-18*1}, {10, -18*10}}},
				},
				skill_mintimepercastonhorse_v = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,-18*1}, {10, -18*10}}},
				},
			},
		},]]
		
		{
			RelatedSkillId = 79,--无形蛊
			magic = 
			{
				fastmanareplenish_v = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,-30},{10,-75},{14,-90}}},
				},
			},
		},
	},
	
	--中级秘籍：追风毒棘
	zhuifengdujiadd =
	{
		{
			RelatedSkillId = 273,--驱毒术_子
			magic = 
			{
				missile_range = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,2}, {10, 4}, {11, 4}}},
					value3 = {SkillEnchant.OP_ADD,  {{1,2}, {10, 4}, {11, 4}}},
				},
			},
		},
		
		--[[{
			RelatedSkillId = 801,--悲魔血光
			magic = 
			{
				skill_mintimepercast_v = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,-18}, {10, -18*10}}},
				},
				skill_mintimepercastonhorse_v = 
				{
					value1 = {SkillEnchant.OP_ADD, {{1,-18}, {10, -18*10}}},
				},
			},
		},]]
	},
	--掌毒高级秘籍
	zhangduadvancedbookadd =
	{
		{
			RelatedSkillId = 93,--阴风蚀骨
			magic = 
			{
				missile_range = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,1}, {10, 3}, {11, 3}}},
					value3 = {SkillEnchant.OP_ADD,  {{1,1}, {10, 3}, {11, 3}}},
				},
			},
		},
		
		{
			RelatedSkillId = 94,--天罡毒手
			magic = 
			{
				missile_range = 
				{
					value1 = {SkillEnchant.OP_ADD,  {{1,1}, {10, 1}, {11, 1}}},
					value3 = {SkillEnchant.OP_ADD,  {{1,1}, {10, 1}, {11, 1}}},
				},
			},
		},
	},
};


SkillEnchant:AddBooksInfo(tb)